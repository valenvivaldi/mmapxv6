
#include "types.h"
#include "stat.h"
#include "user.h"

#define N  1000



void
prioritytest(void)
{
  int i;
  int pid;
  printf(1, "prioritytest\n");
    pid = fork();
    for (i=0;i<4;i++){
      fork();

      if(pid==0){
        break;
      }
    }

    if(pid != 0){
      for(;;){
        setpriority(0);
      }
    }
    if(pid == 0){
        //setpriority(3);
        for(;;){
        }
      }
    }






int
main(void)
{
  prioritytest();
  exit();
}
