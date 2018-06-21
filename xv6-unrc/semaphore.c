#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "mmap.h"
#include "proc.h"
#include "spinlock.h"
#include "semaphore.h"

// Structure that contains all the semaphore of the system and LOCK to guarantee uniqueness.
struct {
  struct spinlock lock;
  struct semaphore sem[MAXSEM];
} stable;

// Initializes the LOCK of the semaphore table.
void
seminit(void)
{
  initlock(&stable.lock, "stable");
}

// Assigns a place in the open semaphore array of the process and returns the position.
static int
allocinprocess()
{
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
    s=proc->osemaphore[i];
    if(!s)
      return i;
  }
  return -1;
}

// Find the id passed as an argument between the ids of the open semaphores of the process and return its position.
static int
searchinprocess(int id)
{
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
    s=proc->osemaphore[i];
    if(s && s->id==id){
        return i;
    }
  }
  return -1;
}

// Assign a place in the semaphore table of the system and return a pointer to it.
// if the table is full, return null (0)
static struct semaphore*
allocinsystem()
{
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
    s=&stable.sem[i];
    if(s->references==0)
      return s;
  }
  return 0;
}

// If semid is -1 it creates a new traffic light and returns its id.
// if semid is greater than or equal to 0, find the semaphore in the system,
// adds references to it and returns its id.
// if there is no place in the semaphore table of the process, return -2.
// if there is no place in the system's semaphore table, return -3.
// if semid> 0 and the semaphore is not in use, return -1.
// if semid <-1 or semid> MAXSEM, return -4.
int
semget(int semid, int initvalue)
{
  int position=0,retvalue;
  struct semaphore* s;

  if(semid<-1 || semid>=MAXSEM)
    return -4;
  acquire(&stable.lock);
  position=allocinprocess();
  if(position==-1){
    retvalue=-2;
    goto retget;
  }
  if(semid==-1){
    s=allocinsystem();
    if(!s){
      retvalue=-3;
      goto retget;
    }
    s->id=s-stable.sem;
    s->value=initvalue;
    retvalue=s->id;
    goto found;
  }
  if(semid>=0){
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
      if(s->id==semid && ((s->references)>0)){
        retvalue=s->id;
        goto found;
      }
      if(s->id==semid && ((s->references)==0)){
        retvalue=-1;
        goto retget;
      }
    }
    retvalue=-5;
    goto retget;
  }
found:
  s->references++;
  proc->osemaphore[position]=s;
retget:
  release(&stable.lock);
  return retvalue;
}

// It releases the semaphore of the process if it is not in use, but only decreases the references in 1.
// if the semaphore is not in the process, return -1.
int
semfree(int semid)
{
  struct semaphore* s;
  int retvalue,pos;

  acquire(&stable.lock);
  pos=searchinprocess(semid);
  if(pos==-1){
    retvalue=-1;
    goto retfree;
  }
  s=proc->osemaphore[pos];
  if(s->references < 1){
    retvalue=-2;
    goto retfree;
  }
  s->references--;
  proc->osemaphore[pos]=0;
  retvalue=0;
retfree:
  release(&stable.lock);
  return retvalue;
}

// Decreases the value of the semaphore if it is greater than 0 but sleeps the process.
// if the semaphore is not in the process, return -1.
int
semdown(int semid)
{
  int value,pos;
  struct semaphore* s;

  acquire(&stable.lock);
  pos=searchinprocess(semid);
  if(pos==-1){
    value=-1;
    goto retdown;
  }
  s=proc->osemaphore[pos];
  while(s->value<=0){
    sleep(s,&stable.lock);
  }
  s->value--;
  value=0;
retdown:
  release(&stable.lock);
  return value;
}

// It increases the value of the semaphore and wake up processes waiting for it.
// if the semaphore is not in the process, return -1.
int
semup(int semid)
{
  struct semaphore* s;
  int pos;

  acquire(&stable.lock);
  pos=searchinprocess(semid);
  if(pos==-1){
    release(&stable.lock);
    return -1;
  }
  s=proc->osemaphore[pos];
  s->value++;
  release(&stable.lock);
  wakeup(s);
  return 0;
}

// Decrease the semaphore references.
void
semclose(struct semaphore* s)
{
  acquire(&stable.lock);

  if(s->references < 1)
    panic("semclose");
  s->references--;
  release(&stable.lock);
  return;

}

// Increase the semaphore references.
struct semaphore*
semdup(struct semaphore* s)
{
  acquire(&stable.lock);
  if(s->references<0)
    panic("semdup error");
  s->references++;
  release(&stable.lock);
  return s;
}
