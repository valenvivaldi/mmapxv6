#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"



void
mmaptest(void)
{
  int fd;
  int i;
  char* buff;
  fd=open("README",O_RDWR);
  mmap(fd,&buff);
  for(i=0;i<10000;i++){
    printf(1,"%c",buff[i] );
  }
  printf(1, "mmaptest ok\n");
}

int
main(void)
{
  mmaptest();
  exit();
}
