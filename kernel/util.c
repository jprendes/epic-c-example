// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "util.h"
#include "htif.h"

void *memset(void *s, int c, size_t n) {
    for(size_t i = 0; i < n; ++i) {
        ((char*)s)[i] = 0;
    }
    return s;
}

void *memcpy(void *dest, const void *src, size_t n) {
    for(size_t i = 0; i < n; ++i) {
        ((char*)dest)[i] = ((char*)src)[i];
    }
    return dest;
}

static unsigned strlen(const char* str) {
    long i = 0;
    while(str[i] != 0)
        ++i;
    return i;
}

void print(char *s) {
    syscall(SYS_write, 0, (uint32_t)s, (uint32_t)strlen(s), 0, 0, 0, 0);
}

void print_i64(int64_t n) {
    if (n < 0) {
        print("-");
        print_u64(-n);
    } else {
        print_u64(n);
    }
}

void print_u64(uint64_t n) {
    static char const * const digits = "0123456789ABCDEF";
    char str[sizeof(uint64_t) * 2 + 3];
    int i = sizeof(str) - 1;

    if (n == 0) {
        print("0x0");
        return;
    }

    str[i--] = '\0';

    while (n) {
        int t = n & 0x0F;
        str[i--] = digits[t];
        n = n >> 4;
    }

    str[i--] = 'x';
    str[i] = '0';

    print(str + i);
}
