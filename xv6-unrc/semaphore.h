struct semaphore{
  int id;  // semaphore identifier.
  int references;  // number of references to the semaphore.
  int value;  // semaphore value.
};
