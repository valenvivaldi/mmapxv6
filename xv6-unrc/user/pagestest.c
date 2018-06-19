
#include "types.h"
#include "stat.h"
#include "user.h"

#define N  1024



void
pagestest(int n)
{
  int i;
  int array[n];
  for(i=0;i<n;i++){
    array[i]=i;
  }
  //pagestest(n-1);
  printf(1, "pages test OK %i\n",array[n]);
}

int
main(void)
{
  pagestest(N);
  exit();
}
