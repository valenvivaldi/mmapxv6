#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"


#define S  100 //size of buffer
#define AMOUNTOFPRODUCERS 1
#define AMOUNTOFCONSUMERS 1
#define AMOUNTOFCYCLES 100  // amount of productions of the producers.


int fd=0;
int semfull;
int semempty;
int semb;

void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}


void
enqueue()
{
  semdown(semb);
  write(fd, "+1", sizeof("+1"));
  semup(semb);
}

int
unqueue()
{
  semdown(semb);
  write(fd, "-1", sizeof("-1"));
  semup(semb);
  return 0;

}

void
cons()
{
  for(;;) {
    semdown(semempty);
    unqueue();
    semup(semfull);
  }

}

void
prod()
{
  int i;
    for(i=0;i<AMOUNTOFCYCLES;i++) {
      semdown(semfull);
      enqueue();
      semup(semempty);
    }
}

void
semtest(void)
{

  int i,j;
  int pid=1;
  fd=open("register", O_CREATE|O_RDWR);

  for(i=0;i<AMOUNTOFPRODUCERS;i++){

    pid=fork();

    if(pid==0){
      printf(1,"PRODUCTOR\n" );
      break;
    }

  }
  if(pid==0){
    prod();
  }

  for(i=0;i<AMOUNTOFCONSUMERS;i++){
    pid=fork();
    if(pid==0){
      printf(1,"CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
    cons();
  }
  if(pid!=0){
    for(j=0;j<AMOUNTOFPRODUCERS+AMOUNTOFPRODUCERS;j++){
      wait();
    }
  }
}

int
main(void)
{
  semempty=semget(-1,0);
  printf(1,"despues de semget semempty\n" );

  semfull=semget(-1,S);
  printf(1,"despues de semget semfull\n" );

  semb=semget(-1,1);
  printf(1,"despues de semget semb\n" );

  semtest();
  exit();
}
