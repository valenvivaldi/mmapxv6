#include "types.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"
#include "mmap.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
mmap(int fd, int mode, char ** addr )
{
  int indexommap;
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd>=0&&fd<NOFILE&&proc->ofile[fd]!=0){
    fileformap=proc->ofile[fd];
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap=0; indexommap<MAXMAPPEDFILES; indexommap++){
    if(proc->ommap[indexommap].pfile==0){
      break;
    }
  }

  //guardar estructura
  if(indexommap<MAXMAPPEDFILES){

    proc->ommap[indexommap].pfile=fileformap;
    proc->ommap[indexommap].mode = mode;
    proc->ommap[indexommap].sz = fileformap->ip->size;

    proc->ommap[indexommap].va=proc->sz;
    proc->sz =PGROUNDUP(proc->sz+fileformap->ip->size);

    //*adrr = dir de memoria virtual donde empieza el archivo
    *addr =(void *) proc->ommap[indexommap].va;

    return 0;

  }else{
    return -2;
  }




}

int
munmap(char * addr)
{
  //ver modo de archivo
  uint indexommap, baseaddr, size;
  struct mmap filemap;


 //buscar  ommap que archivo mapeado usa esa direccion de mem
 for(indexommap=0; indexommap<MAXMAPPEDFILES; indexommap++){
   //ver que la direccion virtual no sea 0 o puntero a file null
   filemap = proc->ommap[indexommap];
   if(filemap.va!=0 && filemap.pfile){
    baseaddr=filemap.va;
    size=filemap.va+filemap.sz;
    if((uint) addr==sa)
      break;
   }
 }
 if(indexommap<MAXMAPPEDFILES){
   uint offset;
   pte_t* pte;




   for(offset=addr; offset  < size; offset += PGSIZE){
    if(pte = pgflags(proc->pgdir, offset, PTE_D)){
      if((filemap.file)->writeable){
        uint pa = PTE_ADDR(*pte);
        fileseek(filemap.pfile, offset);
        filewrite(filemap.pfile, (char*)p2v(pa), PGSIZE);
      }
    }
   }
   unmappages(proc->pgdir, baseaddr, size);

   //marcar como no usadas
   filemap.pfile=0;
   filemap.va=0;

   return 0;

 }else{
   return -1;
 }
}
