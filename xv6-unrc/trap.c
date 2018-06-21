#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "mmap.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

int
mmapin(uint cr2)
{
  int index;

  for(index=0;index<MAXMAPPEDFILES;index++){
    int va;
    int sz;
    va = proc->ommap[index].va;
    sz = proc->ommap[index].sz;

    if(cr2>=va && cr2<va+sz)
      return index;
  }
  return -1;
}



//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:

    if(proc && tf->trapno == T_PGFLT){
      uint cr2=rcr2();
      uint basepgaddr;
      int mmapid;


      //  Verify if you wanted to access a correct address but not assigned.
      //  if appropriate, assign one more page to the stack.
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
        basepgaddr=PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        break;
      }

      if ( (mmapid = mmapin(cr2)) >= 0 ) {
        int offset;

        // in ashared memory region
        basepgaddr = PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        offset = basepgaddr - proc->ommap[mmapid].va;
        fileseek(proc->ommap[mmapid].pfile, offset);
        fileread(proc->ommap[mmapid].pfile, basepgaddr, PGSIZE);
        break;
      }

    }

    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
    if(proc->ticks++ == QUANTUM-1){  // Check if the amount of ticks of the current process reached the Quantum
      //cprintf("El proceso con id %d tiene %d ticks\n",proc->pid, proc->ticks);
      proc->ticks=0;  // Restarts the amount of process ticks
      yield();
    }

  }
  // check if the number of ticks was reached to increase the ages.
  if((tf->trapno == T_IRQ0+IRQ_TIMER) && (ticks % TICKSFORAGE == 0))
    calculateaging();


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
