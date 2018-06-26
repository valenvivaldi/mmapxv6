#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "mmap.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// List the existing processes in the system and their status.
int
sys_procstat(void)
{
  cprintf("sys_procstat\n");
  procdump();  // call function defined in proc.c
  return 0;
}

// Set the priority to a process.
int
sys_setpriority(void)
{
  int level;
  //cprintf("sys_setpriority\n");
  if(argint(0, &level)<0)
    return -1;
  proc->priority=level;
  return 0;
}


int
sys_semget(void)
{
  int id, value;
  if(argint(0, &id)<0)
    return -1;
  if(argint(1, &value)<0)
    return -1;
  return semget(id,value);
}


int
sys_semfree(void)
{
  int id;
  if(argint(0, &id)<0)
    return -1;
  return semfree(id);
}


int
sys_semdown(void)
{
  int id;
  if(argint(0, &id)<0)
    return -1;
  return semdown(id);
}


int
sys_semup(void)
{
  int id;
  if(argint(0, &id)<0)
    return -1;
  return semup(id);
}

int
sys_mmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
  int fd;
  int mode;
  int addr;

  if(argint(0, &fd)<0 || argint(1, &mode)<0 ||argint(2,&addr)<0){ //PREGUNTAR
    return -1;
  }
  //cprintf("%x",addr);
  return mmap(fd,mode,(char**)addr);
}

int
sys_munmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
  return 0;
}
