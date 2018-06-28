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
  fd = open("README", O_RDONLY);
  mmap(fd, &buff);
  printf(1, "IMPRIMIO SIN MODIFICAR!!!!\n");
  for(i = 0; i < 600; i++){
    printf(1, "%c", buff[i] );
  }
  for(i = 0; i < 500; i++){
    buff[i] = 'X';
  }

  printf(1, "IMPRIMIO modificado!!!!!!!\n");
  for(i = 0 ; i < 600; i++){
    printf(1, "%c", buff[i] );
  }
  munmap(buff);
  printf(1, "mmaptest ok\n");
}

void
mmaptest2(void)
{
  int fd;
  int i;
  char* buff;
  fd = open("README", O_RDWR);
  mmap(fd, &buff);
  if(fork() == 0){
    printf(1, "IMPRIME EL HIJO!\n");
    for(i = 0; i < 600; i++){
      printf(1, "%c", buff[i] );
    }
    for(i = 0; i < 500; i++){
      buff[i] = 'X';
    }

    printf(1, "IMPRIME EL HIJO LUEGO DE MODIFICAR!!!!!!!!\n");
    for(i = 0 ; i < 600; i++){
      printf(1, "%c", buff[i] );
    }
    printf(1, "mmaptest2 ok\n");

  }else{
    wait();
  }
  exit();
}

int
main(void)
{
  //mmaptest();
  mmaptest2();
  exit();
}
