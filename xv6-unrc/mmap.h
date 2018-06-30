
struct mmap{
  struct file * pfile;  // Mapped file.
  uint va;              // Memory address where the mapped file begins.
  uint sz;              // Size of the mapped file.
};
