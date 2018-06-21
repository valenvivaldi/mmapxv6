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
  char* buff;
  fd=open("text.txt",O_RDWR);
  mmap(fd,O_RDWR,&buff);

  printf(1, "mmaptest ok\n");
}

int
main(void)
{
  mmaptest();
  exit();
}
