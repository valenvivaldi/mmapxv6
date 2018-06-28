// test that shows the problem of the consumer producer.
// -1: consumption +1: production.
// the results will be written in a file called "register" and also on the screen.

#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"

//  parameters that modify the behavior of the test (for example, quantity of producers and consumers).
#define S  10  //size of buffer
#define AMOUNTOFPRODUCERS 5  // number of producers.
#define AMOUNTOFCONSUMERS 2  // number of consumers.
#define AMOUNTOFCYCLESPROD 10  // amount of productions per producer.
#define AMOUNTOFCYCLESCONS 25  // number of consumptions per consumer.
#define TIMEPRODUCE 15  // time to produce a item.
#define TIMECONSUME 30  // time to consume a item.

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
  printf(1,"+1");
  semup(semb);
}

int
unqueue()
{
  semdown(semb);
  write(fd, "-1", sizeof("-1"));
  printf(1,"-1");
  semup(semb);
  return 0;

}

void
cons()
{
  int i;
  for(i=0;i<AMOUNTOFCYCLESCONS;i++) {
    sleep(TIMECONSUME);
    semdown(semempty);
    unqueue();
    semup(semfull);
  }
  exit();

}

void
prod()
{
  int i;
  for(i=0;i<AMOUNTOFCYCLESPROD;i++) {
    sleep(TIMEPRODUCE);
    semdown(semfull);
    enqueue();
    semup(semempty);
  }
  exit();
}

void
semtest(void)
{

  int i,j;
  int pid=1;
  fd=open("register", O_CREATE|O_RDWR);

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

  if(pid!=0){
    for(j=0;j<(AMOUNTOFPRODUCERS+AMOUNTOFPRODUCERS);j++){
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
