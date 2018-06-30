#include "types.h"
#include "mmu.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"
#include "mmap.h"
#include "memlayout.h"
#include "proc.h"


// This function takes a file (file descriptor) opened by the process and maps it into memory.
// The function saves in the parameter "addr" the memory address where the file starts,
// Returns 0,  if the mapping was successful.
// Returns -1, if the file was not opened, or it does not exist.
// Returns -2, if the process does not have more space available to do mappings.
int
mmap(int fd, char ** addr )
{
  int indexommap;
  struct file* fileformap;

  // Find the open file that you want to map in memory.
  if(fd >= 0 && fd < NOFILE && proc->ofile[fd] != 0){
    fileformap = proc->ofile[fd];
  }else{
    return -1;
  }

  // Search for a place available in the mapping of mapped files (ommap) of the process.
  for (indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
    if(proc->ommap[indexommap].pfile == 0){
      break;
    }
  }

  // Save the mmap data in the structure.
  if(indexommap < MAXMAPPEDFILES){

    proc->ommap[indexommap].pfile = fileformap;
    proc->ommap[indexommap].sz = fileformap->ip->size;

    proc->ommap[indexommap].va = proc->sz;
    proc->sz = PGROUNDUP(proc->sz + fileformap->ip->size);

    // *adrr = memory address where the mapped file begins.
    *addr = (void *) proc->ommap[indexommap].va;

    return 0;

  }else{
    return -2;
  }

}

// Receives a memory address and unmaps the file that has been mapped to that virtual address.
// if the file was modified and the mmap had write permission,
// then the modified pages on the disk file are rewritten.
// Returns 0, if munmap was successful.
// Returns -1, if the address does not belong to a file mapped by the process.
int
munmap(char * addr)
{
  uint indexommap, baseaddr, size;
  struct mmap* filemap;

  // It is verified that the address belongs to an open mmap.
  for(indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
    filemap = &proc->ommap[indexommap];
    if(filemap->va != 0 && filemap->pfile){
      baseaddr = filemap->va;
      size = filemap->va + filemap->sz;
      if((uint) addr == baseaddr)
        break;
    }
  }

  if(indexommap < MAXMAPPEDFILES){
    uint offset;
    pte_t* pte;

    // For each modified pages, that page is written on the corresponding position on the disk.
    for(offset =(uint) addr; offset  < size; offset += PGSIZE){
      pte = pgflags(proc->pgdir,(char *) offset, PTE_D);
      if(pte){
        if((filemap->pfile)->writable){
          uint pa = PTE_ADDR(*pte);
          
          fileseek(filemap->pfile, offset - (uint) addr);
          filewrite(filemap->pfile, (char*)p2v(pa), PGSIZE);
        }
      }
    }

    // All the pages of the file mapped in memory are unmapped.
    unmappages(proc->pgdir, (char*)baseaddr, size);

    // The space of the mmaps array is marked as unused (pfile = 0)
    filemap->pfile = 0;
    filemap->va = 0;

    return 0;

  }else{
    return -1;
  }
}
