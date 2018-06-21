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
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
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
    proc->sz =proc->sz+fileformap->ip->size;

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
 //buscar  ommap que archivo mapeado usa esa direccion de mem
 //verificar paginas dirty,y guardar cada pagina dirty en el archivo
return 0;
}
