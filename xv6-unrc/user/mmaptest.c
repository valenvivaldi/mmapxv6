#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"

// this function makes a mmap on the README, reads the first characters,
// then writes x on those characters and prints the mmap again. finally it does
// mmap so that the changes are saved in the file.
void
mmaptest(void)
{
  int fd;
  int i;
  char* buff;
  
  fd = open("README", O_RDONLY);
  mmap(fd, &buff);
  printf(1, "\nIMPRIMIO SIN MODIFICAR!!!!\n");

  for(i = 0; i < 600; i++){
    printf(1, "%c", buff[i] );
  }

  for(i = 0; i < 500; i++){
    buff[i] = 'X';
  }

  printf(1, "\nIMPRIMIO modificado!!!!!!!\n");
  for(i = 0 ; i < 600; i++){
    printf(1, "%c", buff[i] );
  }
  munmap(buff);
  printf(1, "\nmmaptest ok\n");
}

//this function is similar to the previous one, except that a parent process
//starts the mmap and the son (which inherits the mmap) is
//the one that makes the modifications
void
mmaptest2(void)
{
  int fd;
  int i;
  char* buff;

  fd = open("README", O_RDWR);
  mmap(fd, &buff);

  if(fork() == 0){

    printf(1, "\nIMPRIME EL HIJO!\n");
    for(i = 0; i < 600; i++){
      printf(1, "%c", buff[i] );
    }

    for(i = 0; i < 500; i++){
      buff[i] = 'X';
    }

    printf(1, "\nIMPRIME EL HIJO LUEGO DE MODIFICAR!!!!!!!!\n");
    for(i = 0 ; i < 600; i++){
      printf(1, "%c", buff[i] );
    }
    printf(1, "\nmmaptest2 ok\n");

  }else{
    wait();
  }
  exit();
}

int
main(void)
{
  printf(1, "\n----------------Maptest1----------------\n");
  mmaptest(); // this test function
  printf(1, "\n----------------Maptest2----------------\n");
  mmaptest2();
  exit();
}
