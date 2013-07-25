/*
 * Copyright (c) 2006 Tama Communications Corporation
 *
 * This file is part of GNU GLOBAL.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _CHECKALLOC_H
#define _CHECKALLOC_H
#include <stdlib.h>

void *check_malloc(size_t);
void *check_calloc(size_t, size_t);
void *check_realloc(void *, size_t);
char *check_strdup(const char *);
void check_free(void *const ptr);
#define xMalloc(n,Type)    (Type *)check_malloc((size_t)(n) * sizeof (Type))
#define xCalloc(n,Type)    (Type *)check_calloc((size_t)(n), sizeof (Type))
#define xRealloc(p,n,Type) (Type *)check_realloc((p), (n) * sizeof (Type))


#endif /* _CHECKALLOC_H */
