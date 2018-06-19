// Test that fork aging.

#include "types.h"
#include "stat.h"
#include "user.h"

#define N  1000



void
agingtest(void)
{
  int pid;
  int i;

  printf(1, "agingtest test\n");

  for(i=0;i<4;i++){
    pid=fork();

    if(pid==0)
      break;
  }
  if (pid==0){
    for(;;){
      setpriority(0);
    }
  }else{
    setpriority(3);
    for(;;){

    }
  }

  printf(1, "aging test OK\n");
}

int
main(void)
{
  agingtest();
  exit();
}
