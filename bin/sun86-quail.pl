#!/usr/bin/perl
use Encode;
use utf8;

open($fwubi_hf_src, "<", "wubi.txt") or die $!;
open($fpy, "<", "py.txt") or die $!;
open($freverse, ">", "wubi86_reverse.py") or die $!;
open($fquail, ">", "wubi86.py") or die $!;
open($fquail_el, ">", "wubi86.el") or die $!;


$el_head = <<EOC;
;; Quail package `chinese-wubi86' 
;;   Generated by Bao Haojun from FCITX
;;   Date: Wed Nov  4 08:51:19 CST 2009


(require 'quail)
(quail-define-package "chinese-wubi86" "Chinese-CNS" "五笔" t
"汉字输入∷【五笔八六】∷"

  '(("" . quail-delete-last-char)
   ([(control n)] . quail-next-translation-block)
   ([(control p)] . quail-prev-translation-block)
   ([(control g)] . quail-abort-translation)
   (" " . quail-select-current))
  nil nil nil nil)

(quail-define-rules
EOC
#`

 print $fquail_el encode_utf8($el_head);

################ build data structure from wubi.txt ################
$line = 0;
while (<$fwubi_hf_src>) {
    $line += 1;
    chomp;
    $_ = decode_utf8($_);

    next unless m/^([^a-zA-Z ]+)([a-zA-Z ]+)$/;
    @keys = split /\s+/, encode_utf8 lc $2;
    $chinese = encode_utf8 $1;

    for $key (@keys) {
        if (length(decode_utf8 $key) < 3) { #这是一个单字，我们希望取
            next if $done{$key};
            $done{$key} = 1;
        }
        next if $done{$key.$chinese};
        $done{$key.$chinese} = 1;

        push @{$quail_hash{$key}}, $chinese;

        if (length (decode_utf8 $chinese) == 1) { 
            $seq{$chinese} = $line unless $seq{$chinese};
            push @{$pinyin_helper_hash{$chinese}}, $key;
            next if (length (decode_utf8 $key) == 1);
            $key2 = substr $key, 0, 2;
            next if $done_reverse{$key2.$chinese};
            $done_reverse{$key2.$chinese} = 1;
            push @{$reverse_hash{$chinese}}, $key2;
        }
    }
}

sub print_reverse()
{
################ output the reverse (for constructing chinese phrase in wubi) ################
   
    $head = <<EOC;
#!/bin/env python
# -*- coding: utf-8 -*-
g_reverse_map = {
EOC

    $tail = <<EOC;
}
EOC

    print $freverse $head;
    @keys = sort {$seq{$a} <=> $seq{$b}} keys %reverse_hash;
    foreach $key (@keys) {
        $" = qq(", ");
        print $freverse qq/"$key" : ("@{$reverse_hash{$key}}",),/, "\n";
    }
    print $freverse encode_utf8($tail);
}

sub print_quail()
{

################ build py data struct (pinyin) ################
while (<$fpy>) {
    chomp();
    ($key, $chinese) = split;
    local $"=" ";
    push @{$py_hash{"z".$key}}, {chinese=>$chinese, wubi=>"(@{$pinyin_helper_hash{$chinese}})"};
}

    $head = <<EOC;
#!/bin/env python
# -*- coding: utf-8 -*-

g_quail_map = {
EOC

    $tail = <<EOC;
". " : ("。",),
", " : ("，",),
"? " : ("？",),
"``" : ("“",),
"`` " : ("“",),
"''" : ("”",),
"'' " : ("”",),
": " : ("：",),
":`` " : ("：“",),
":``" : ("：“",),
"` " : ("‘",),
"' " : ("’",),
"< " : ("《",),
"> " : ("》",),
"<<" : ("《",),
">>" : ("》",),
"\\\\ " : ("、",),
"! " : ("！",),
"\$ " : ("￥",),
"^ " : ("…",),
"^^ " : ("……",),
"^^" : ("……",),
"* " : ("·",),
"**" : ("×",),
"** " : ("×",),
"_ " : ("—",),
"__" : ("——",),
"( " : ("（",),
") " : ("）",),
"{ " : ("｛",),
"} " : ("｝",),
"[ " : ("［",),
"] " : ("］",),
".\\" " : ("。”",),
":\\" " : ("：“",),
".'' " : ("。”",),
".''" : ("。”",),
",'' " : ("，”",),
",''" : ("，”",),
"'', " : ("”，",),
"''. " : ("”。",),
}
EOC

    print $fquail $head;

    @keys = sort keys %quail_hash;

    foreach $key (@keys) {
        $" = qq(", ");
        print $fquail qq("$key" : ("@{$quail_hash{$key}}",),), "\n";
        $" = qq(" ");
        print $fquail_el qq(("$key" ["@{$quail_hash{$key}}"])), "\n";
    }


    @keys = sort keys %py_hash;

    foreach $key (@keys) {
        @py_data = map {$_ = ${$_}{"chinese"} . ${$_}{"wubi"} } sort {$seq{$a{"chinese"}} <=> $seq{$b{"chinese"}}} @{$py_hash{$key}};
        $" = qq(", ");
        print $fquail qq/"$key" : ("@py_data",),/, "\n";
        $" = qq(" ");
        print $fquail_el qq/("$key" ["@py_data"])/, "\n";
    }
    print $fquail encode_utf8($tail);
    print $fquail_el ")\n";
}


################ refine the data struct, most comp with len < 4 should have only 1 candidate ################
sub refine_quail()
{
    foreach $chinese (keys %pinyin_helper_hash) {
        @comps = sort @{$pinyin_helper_hash{$chinese}};
        foreach $comp (@comps) {
            if (grep /$comp./, @comps) {
                @comps = grep {$_ !~/$comp./} @comps;
            }
        }

        foreach $comp (@{$pinyin_helper_hash{$chinese}}) {
            if (!grep {$_ eq $comp} @comps) {
                @{$quail_hash{$comp}} = grep {$_ ne $chinese} @{$quail_hash{$comp}};
                if (! @{$quail_hash{$comp}}) {
                    delete $quail_hash{$comp};
                }
            }
        }
        @{$pinyin_helper_hash{$chinese}} = @comps;

        
    }
}

refine_quail();

print_reverse();
print_quail();



# #("aaaa" ["工" "恭恭敬敬"])


