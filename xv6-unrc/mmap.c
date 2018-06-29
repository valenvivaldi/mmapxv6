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


//This function takes a file opened by the process and maps it into memory.
// The function returns the memory address where the file starts

int
mmap(int fd, char ** addr )
{
  int indexommap;
  struct file* fileformap;
//Find the open file that you want to map in memory
  if(fd >= 0 && fd < NOFILE && proc->ofile[fd] != 0){
    fileformap = proc->ofile[fd];
  }else{
    return -1;
  }
  //search for a place available in the mapping of mapped files (ommap) of the process
  for (indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
    if(proc->ommap[indexommap].pfile == 0){
      break;
    }
  }

  //Save the mmap data in the structure
  if(indexommap < MAXMAPPEDFILES){

    proc->ommap[indexommap].pfile = fileformap;
    proc->ommap[indexommap].sz = fileformap->ip->size;

    proc->ommap[indexommap].va = proc->sz;
    proc->sz = PGROUNDUP(proc->sz + fileformap->ip->size);

    //*adrr = memory address where the mapped file begins
    *addr = (void *) proc->ommap[indexommap].va;

    return 0;

  }else{
    return -2;
  }

}

//receives a memory address and unmaps the file that has been mapped to that virtual address.
//if the file was modified and the mmap had write permission,
// then the modified pages on the disk file are rewritten
int
munmap(char * addr)
{

  uint indexommap, baseaddr, size;
  struct mmap* filemap;


 //it is verified that the pertenesca address to an open mmap
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



   // for each modified pages, that page is written on the corresponding position on the disk
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
   //all the pages of memory are unmapped
   unmappages(proc->pgdir, (char*)baseaddr, size);

   //the space of the mmaps array is marked as unused (pfile = 0)
   filemap->pfile = 0;
   filemap->va = 0;

   return 0;

 }else{
   return -1;
 }
}
