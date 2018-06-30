#define NPROC        64  // maximum number of processes
#define KSTACKSIZE 4096  // size of per-process kernel stack
#define NCPU          8  // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       100  // open files per system
#define NINODE       50  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  10  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data sectors in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define QUANTUM       5  // maximum number of ticks per process
#define MLFLEVELS     4  // number of levels in the MLF structure
#define TICKSFORAGE  10  // amount of ticks to increase the age of the process
#define AGEFORAGINGS  5  // age that the processes must reach to update the priority.
#define MLFMAXPRIORITY 0 // level with the highest priority in the MLF structure.
#define MAXSEM       64  // maximum number of semaphores in the system.
#define MAXPROCSEM    5  // maximum number of semaphores per process.
#define MAXSTACKPAGES 8  // maximum number of stack pages per process.
#define MAXMAPPEDFILES 5 // maximum number of mapped files per process.
