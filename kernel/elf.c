// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stddef.h>
#include <stdint.h>
#include "elf.h"
#include "util.h"

typedef struct {
    uint8_t  e_ident[16];
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint32_t e_entry;
    uint32_t e_phoff;
    uint32_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_ph_num;
    uint16_t e_shentsize;
    uint16_t e_sh_num;
    uint16_t e_shstrndx;
} Elf32_Ehdr;

typedef struct {
    uint32_t sh_name;
    uint32_t sh_type;
    uint32_t sh_flags;
    uint32_t sh_addr;
    uint32_t sh_offset;
    uint32_t sh_size;
    uint32_t sh_link;
    uint32_t sh_info;
    uint32_t sh_addralign;
    uint32_t sh_entsize;
} Elf32_Shdr;

typedef struct
{
    uint32_t p_type;
    uint32_t p_offset;
    uint32_t p_vaddr;
    uint32_t p_paddr;
    uint32_t p_filesz;
    uint32_t p_memsz;
    uint32_t p_flags;
    uint32_t p_align;
} Elf32_Phdr;

typedef struct {
    uint32_t r_offset;
    uint32_t r_info;
    int32_t  r_addend;
} Elf32_Rela;

#define Elf_Ehdr Elf32_Ehdr
#define Elf_Phdr Elf32_Phdr
#define Elf_Shdr Elf32_Shdr
#define Elf_Rela Elf32_Rela

#define PT_LOAD 1
#define SHT_RELA 4

static int check_elf(const void *data) {
    // Check alignment
    if ((size_t)data & 3)
        return 0;

    // Check magic number
    const Elf_Ehdr *eh = data;
    if (!(eh->e_ident[0] == '\177' && eh->e_ident[1] == 'E' &&
            eh->e_ident[2] == 'L' && eh->e_ident[3] == 'F')) {
        return 0;
    }

    return 1;
}

uint32_t program_flash_with_elf(const void *data, uint32_t flash_offset) {
    if (!check_elf(data))
        return 0;

    const Elf_Ehdr *eh = data;

    print("ELF:\n");
    print("  e_type      = "); print_u64(eh->e_type); print("\n");
    print("  e_machine   = "); print_u64(eh->e_machine); print("\n");
    print("  e_version   = "); print_u64(eh->e_version); print("\n");
    print("  e_entry     = "); print_u64(eh->e_entry); print("\n");
    print("  e_phoff     = "); print_u64(eh->e_phoff); print("\n");
    print("  e_shoff     = "); print_u64(eh->e_shoff); print("\n");
    print("  e_phentsize = "); print_u64(eh->e_phentsize); print("\n");
    print("  e_phnum     = "); print_u64(eh->e_ph_num); print("\n");
    print("  e_shentsize = "); print_u64(eh->e_shentsize); print("\n");
    print("  e_shnum     = "); print_u64(eh->e_sh_num); print("\n");
    print("  e_shstrndx  = "); print_u64(eh->e_shstrndx); print("\n");
    print("\n");

    int ph_num = eh->e_ph_num;
    const Elf_Phdr *ph = data + eh->e_phoff;

    for(int i = 0; i < ph_num; i++) {
        print("PH["); print_u64(i); print("]:\n");
        print("  p_type   = "); print_u64(ph[i].p_type); print("\n");
        print("  p_offset = "); print_u64(ph[i].p_offset); print("\n");
        print("  p_vaddr  = "); print_u64(ph[i].p_vaddr); print("\n");
        print("  p_paddr  = "); print_u64(ph[i].p_paddr); print("\n");
        print("  p_filesz = "); print_u64(ph[i].p_filesz); print("\n");
        print("  p_memsz  = "); print_u64(ph[i].p_memsz); print("\n");
        print("  p_align  = "); print_u64(ph[i].p_align); print("\n");
        print("\n");
        
        if(ph[i].p_type != PT_LOAD || ph[i].p_memsz == 0)
            continue;
        if((ph[i].p_paddr & SENTINEL) == 0)
            continue;

        // Load data into simulated Flash segment
        uint32_t paddr = ph[i].p_paddr;
        if(paddr & SENTINEL) {
            paddr += flash_offset;
            memcpy((void*)paddr, data + ph[i].p_offset, ph[i].p_filesz);
        }
    }

    return eh->e_entry + flash_offset;
}

rela_section_info rela_section(const void *data, int skip_sections) {
    if (!check_elf(data))
        return (rela_section_info){0, 0};

    const Elf_Ehdr *eh = data;
    const Elf_Shdr* sh = data + eh->e_shoff;

    for(int i = skip_sections; i < eh->e_sh_num; i++) {
        if(sh[i].sh_type == SHT_RELA) {
            const Elf_Rela *rela = data + sh[i].sh_offset;

            print("Found a relocation section");
            if(rela->r_offset & SENTINEL)
                print(" (in flash)");
            print("\n");

            // We don't apply relocations in Flash (e.g. .rela.text)
            if(rela->r_offset & SENTINEL)
                continue;

            return (rela_section_info){sh[i].sh_size, sh[i].sh_offset};
        }
    }

    return (rela_section_info){0, 0};
}
