
kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 fe 37 10 80       	mov    $0x801037fe,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 30 8f 10 80       	push   $0x80108f30
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 69 57 00 00       	call   801057b5 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 11 57 00 00       	call   801057d7 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 2d 57 00 00       	call   8010583e <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 ef 4e 00 00       	call   8010501b <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 b1 56 00 00       	call   8010583e <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 37 8f 10 80       	push   $0x80108f37
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 8d 26 00 00       	call   80102874 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 48 8f 10 80       	push   $0x80108f48
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 4c 26 00 00       	call   80102874 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 4f 8f 10 80       	push   $0x80108f4f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 7d 55 00 00       	call   801057d7 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 69 4e 00 00       	call   80105127 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 70 55 00 00       	call   8010583e <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 f0 53 00 00       	call   801057d7 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 56 8f 10 80       	push   $0x80108f56
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 5f 8f 10 80 	movl   $0x80108f5f,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 de 52 00 00       	call   8010583e <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 66 8f 10 80       	push   $0x80108f66
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 75 8f 10 80       	push   $0x80108f75
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 c9 52 00 00       	call   80105890 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 77 8f 10 80       	push   $0x80108f77
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 19 54 00 00       	call   80105af9 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 30 53 00 00       	call   80105a3a <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 23 6e 00 00       	call   801075c2 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 16 6e 00 00       	call   801075c2 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 09 6e 00 00       	call   801075c2 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 f9 6d 00 00       	call   801075c2 <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 a0 17 11 80       	push   $0x801117a0
801007eb:	e8 e7 4f 00 00       	call   801057d7 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 c6 49 00 00       	call   801051e9 <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010084b:	a1 58 18 11 80       	mov    0x80111858,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100879:	a1 58 18 11 80       	mov    0x80111858,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
801008b8:	a1 54 18 11 80       	mov    0x80111854,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 5c 18 11 80    	mov    %edx,0x8011185c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 d4 17 11 80    	mov    %dl,-0x7feee82c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100912:	8b 15 54 18 11 80    	mov    0x80111854,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100924:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 54 18 11 80       	push   $0x80111854
80100931:	e8 f1 47 00 00       	call   80105127 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 a0 17 11 80       	push   $0x801117a0
80100954:	e8 e5 4e 00 00       	call   8010583e <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 fb 10 00 00       	call   80101a6b <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 a0 17 11 80       	push   $0x801117a0
80100981:	e8 51 4e 00 00       	call   801057d7 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 a0 17 11 80       	push   $0x801117a0
801009a3:	e8 96 4e 00 00       	call   8010583e <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 5d 0f 00 00       	call   80101913 <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 a0 17 11 80       	push   $0x801117a0
801009cb:	68 54 18 11 80       	push   $0x80111854
801009d0:	e8 46 46 00 00       	call   8010501b <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801009de:	a1 58 18 11 80       	mov    0x80111858,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 54 18 11 80       	mov    0x80111854,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 54 18 11 80    	mov    %edx,0x80111854
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 54 18 11 80       	mov    0x80111854,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 54 18 11 80       	mov    %eax,0x80111854
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 a0 17 11 80       	push   $0x801117a0
80100a4e:	e8 eb 4d 00 00       	call   8010583e <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 b2 0e 00 00       	call   80101913 <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 ea 0f 00 00       	call   80101a6b <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a8c:	e8 46 4d 00 00       	call   801057d7 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 e0 c5 10 80       	push   $0x8010c5e0
80100ace:	e8 6b 4d 00 00       	call   8010583e <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 32 0e 00 00       	call   80101913 <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 7b 8f 10 80       	push   $0x80108f7b
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 b4 4c 00 00       	call   801057b5 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 83 8f 10 80       	push   $0x80108f83
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 9f 4c 00 00       	call   801057b5 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 0c 22 11 80 70 	movl   $0x80100a70,0x8011220c
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 08 22 11 80 5f 	movl   $0x8010095f,0x80112208
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 63 33 00 00       	call   80103ea4 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 f1 1e 00 00       	call   80102a41 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b5f:	e8 58 29 00 00       	call   801034bc <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 5c 19 00 00       	call   801024cb <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 c8 29 00 00       	call   80103548 <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 d6 03 00 00       	jmp    80100f60 <exec+0x40a>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 7e 0d 00 00       	call   80101913 <ilock>
80100b95:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b98:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b9f:	6a 34                	push   $0x34
80100ba1:	6a 00                	push   $0x0
80100ba3:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ba9:	50                   	push   %eax
80100baa:	ff 75 d8             	pushl  -0x28(%ebp)
80100bad:	e8 c9 12 00 00       	call   80101e7b <readi>
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	83 f8 33             	cmp    $0x33,%eax
80100bb8:	0f 86 51 03 00 00    	jbe    80100f0f <exec+0x3b9>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bbe:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bc4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc9:	0f 85 43 03 00 00    	jne    80100f12 <exec+0x3bc>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bcf:	e8 43 7b 00 00       	call   80108717 <setupkvm>
80100bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bdb:	0f 84 34 03 00 00    	je     80100f15 <exec+0x3bf>
    goto bad;

  // Load program into memory.
  sz = 0;
80100be1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf8:	e9 ab 00 00 00       	jmp    80100ca8 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c00:	6a 20                	push   $0x20
80100c02:	50                   	push   %eax
80100c03:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c09:	50                   	push   %eax
80100c0a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c0d:	e8 69 12 00 00       	call   80101e7b <readi>
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	83 f8 20             	cmp    $0x20,%eax
80100c18:	0f 85 fa 02 00 00    	jne    80100f18 <exec+0x3c2>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c1e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c24:	83 f8 01             	cmp    $0x1,%eax
80100c27:	75 71                	jne    80100c9a <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c29:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c2f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c35:	39 c2                	cmp    %eax,%edx
80100c37:	0f 82 de 02 00 00    	jb     80100f1b <exec+0x3c5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c43:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 64 7e 00 00       	call   80108abe <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	0f 84 b4 02 00 00    	je     80100f1e <exec+0x3c8>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6a:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c70:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c76:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c7c:	83 ec 0c             	sub    $0xc,%esp
80100c7f:	52                   	push   %edx
80100c80:	50                   	push   %eax
80100c81:	ff 75 d8             	pushl  -0x28(%ebp)
80100c84:	51                   	push   %ecx
80100c85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c88:	e8 5a 7d 00 00       	call   801089e7 <loaduvm>
80100c8d:	83 c4 20             	add    $0x20,%esp
80100c90:	85 c0                	test   %eax,%eax
80100c92:	0f 88 89 02 00 00    	js     80100f21 <exec+0x3cb>
80100c98:	eb 01                	jmp    80100c9b <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c9a:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca2:	83 c0 20             	add    $0x20,%eax
80100ca5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca8:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100caf:	0f b7 c0             	movzwl %ax,%eax
80100cb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb5:	0f 8f 42 ff ff ff    	jg     80100bfd <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbb:	83 ec 0c             	sub    $0xc,%esp
80100cbe:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc1:	e8 07 0f 00 00       	call   80101bcd <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 7a 28 00 00       	call   80103548 <end_op>
  ip = 0;
80100cce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  sz = PGROUNDUP(sz+PGSIZE);
80100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd8:	05 ff 1f 00 00       	add    $0x1fff,%eax
80100cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Save the top of the stack pages.
  proc->sstack=sz;
80100ce5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ceb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100cee:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)

  // Skip MAXSTACKPAGES-1 pages and allocate one.
  sz = PGROUNDUP(sz+(PGSIZE*(MAXSTACKPAGES-1)));
80100cf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf7:	05 ff 7f 00 00       	add    $0x7fff,%eax
80100cfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d07:	05 00 10 00 00       	add    $0x1000,%eax
80100d0c:	83 ec 04             	sub    $0x4,%esp
80100d0f:	50                   	push   %eax
80100d10:	ff 75 e0             	pushl  -0x20(%ebp)
80100d13:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d16:	e8 a3 7d 00 00       	call   80108abe <allocuvm>
80100d1b:	83 c4 10             	add    $0x10,%esp
80100d1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d25:	0f 84 f9 01 00 00    	je     80100f24 <exec+0x3ce>
    goto bad;
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;
80100d2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d31:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d38:	e9 96 00 00 00       	jmp    80100dd3 <exec+0x27d>
    if(argc >= MAXARG)
80100d3d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d41:	0f 87 e0 01 00 00    	ja     80100f27 <exec+0x3d1>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d54:	01 d0                	add    %edx,%eax
80100d56:	8b 00                	mov    (%eax),%eax
80100d58:	83 ec 0c             	sub    $0xc,%esp
80100d5b:	50                   	push   %eax
80100d5c:	e8 26 4f 00 00       	call   80105c87 <strlen>
80100d61:	83 c4 10             	add    $0x10,%esp
80100d64:	89 c2                	mov    %eax,%edx
80100d66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d69:	29 d0                	sub    %edx,%eax
80100d6b:	83 e8 01             	sub    $0x1,%eax
80100d6e:	83 e0 fc             	and    $0xfffffffc,%eax
80100d71:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d81:	01 d0                	add    %edx,%eax
80100d83:	8b 00                	mov    (%eax),%eax
80100d85:	83 ec 0c             	sub    $0xc,%esp
80100d88:	50                   	push   %eax
80100d89:	e8 f9 4e 00 00       	call   80105c87 <strlen>
80100d8e:	83 c4 10             	add    $0x10,%esp
80100d91:	83 c0 01             	add    $0x1,%eax
80100d94:	89 c1                	mov    %eax,%ecx
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da3:	01 d0                	add    %edx,%eax
80100da5:	8b 00                	mov    (%eax),%eax
80100da7:	51                   	push   %ecx
80100da8:	50                   	push   %eax
80100da9:	ff 75 dc             	pushl  -0x24(%ebp)
80100dac:	ff 75 d4             	pushl  -0x2c(%ebp)
80100daf:	e8 dd 80 00 00       	call   80108e91 <copyout>
80100db4:	83 c4 10             	add    $0x10,%esp
80100db7:	85 c0                	test   %eax,%eax
80100db9:	0f 88 6b 01 00 00    	js     80100f2a <exec+0x3d4>
      goto bad;
    ustack[3+argc] = sp;
80100dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc2:	8d 50 03             	lea    0x3(%eax),%edx
80100dc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc8:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dcf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de0:	01 d0                	add    %edx,%eax
80100de2:	8b 00                	mov    (%eax),%eax
80100de4:	85 c0                	test   %eax,%eax
80100de6:	0f 85 51 ff ff ff    	jne    80100d3d <exec+0x1e7>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100def:	83 c0 03             	add    $0x3,%eax
80100df2:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dfd:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e04:	ff ff ff 
  ustack[1] = argc;
80100e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0a:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e13:	83 c0 01             	add    $0x1,%eax
80100e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e20:	29 d0                	sub    %edx,%eax
80100e22:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2b:	83 c0 04             	add    $0x4,%eax
80100e2e:	c1 e0 02             	shl    $0x2,%eax
80100e31:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e37:	83 c0 04             	add    $0x4,%eax
80100e3a:	c1 e0 02             	shl    $0x2,%eax
80100e3d:	50                   	push   %eax
80100e3e:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e44:	50                   	push   %eax
80100e45:	ff 75 dc             	pushl  -0x24(%ebp)
80100e48:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e4b:	e8 41 80 00 00       	call   80108e91 <copyout>
80100e50:	83 c4 10             	add    $0x10,%esp
80100e53:	85 c0                	test   %eax,%eax
80100e55:	0f 88 d2 00 00 00    	js     80100f2d <exec+0x3d7>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e67:	eb 17                	jmp    80100e80 <exec+0x32a>
    if(*s == '/')
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	3c 2f                	cmp    $0x2f,%al
80100e71:	75 09                	jne    80100e7c <exec+0x326>
      last = s+1;
80100e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e76:	83 c0 01             	add    $0x1,%eax
80100e79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e83:	0f b6 00             	movzbl (%eax),%eax
80100e86:	84 c0                	test   %al,%al
80100e88:	75 df                	jne    80100e69 <exec+0x313>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e90:	83 c0 6c             	add    $0x6c,%eax
80100e93:	83 ec 04             	sub    $0x4,%esp
80100e96:	6a 10                	push   $0x10
80100e98:	ff 75 f0             	pushl  -0x10(%ebp)
80100e9b:	50                   	push   %eax
80100e9c:	e8 9c 4d 00 00       	call   80105c3d <safestrcpy>
80100ea1:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ea4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eaa:	8b 40 04             	mov    0x4(%eax),%eax
80100ead:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ec5:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ec7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecd:	8b 40 18             	mov    0x18(%eax),%eax
80100ed0:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ed6:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ed9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edf:	8b 40 18             	mov    0x18(%eax),%eax
80100ee2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ee5:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eee:	83 ec 0c             	sub    $0xc,%esp
80100ef1:	50                   	push   %eax
80100ef2:	e8 07 79 00 00       	call   801087fe <switchuvm>
80100ef7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100efa:	83 ec 0c             	sub    $0xc,%esp
80100efd:	ff 75 d0             	pushl  -0x30(%ebp)
80100f00:	e8 3f 7d 00 00       	call   80108c44 <freevm>
80100f05:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f08:	b8 00 00 00 00       	mov    $0x0,%eax
80100f0d:	eb 51                	jmp    80100f60 <exec+0x40a>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f0f:	90                   	nop
80100f10:	eb 1c                	jmp    80100f2e <exec+0x3d8>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f12:	90                   	nop
80100f13:	eb 19                	jmp    80100f2e <exec+0x3d8>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f15:	90                   	nop
80100f16:	eb 16                	jmp    80100f2e <exec+0x3d8>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f18:	90                   	nop
80100f19:	eb 13                	jmp    80100f2e <exec+0x3d8>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f1b:	90                   	nop
80100f1c:	eb 10                	jmp    80100f2e <exec+0x3d8>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f1e:	90                   	nop
80100f1f:	eb 0d                	jmp    80100f2e <exec+0x3d8>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f21:	90                   	nop
80100f22:	eb 0a                	jmp    80100f2e <exec+0x3d8>
  proc->sstack=sz;

  // Skip MAXSTACKPAGES-1 pages and allocate one.
  sz = PGROUNDUP(sz+(PGSIZE*(MAXSTACKPAGES-1)));
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;
80100f24:	90                   	nop
80100f25:	eb 07                	jmp    80100f2e <exec+0x3d8>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f27:	90                   	nop
80100f28:	eb 04                	jmp    80100f2e <exec+0x3d8>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f2a:	90                   	nop
80100f2b:	eb 01                	jmp    80100f2e <exec+0x3d8>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f2d:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f2e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f32:	74 0e                	je     80100f42 <exec+0x3ec>
    freevm(pgdir);
80100f34:	83 ec 0c             	sub    $0xc,%esp
80100f37:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f3a:	e8 05 7d 00 00       	call   80108c44 <freevm>
80100f3f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f46:	74 13                	je     80100f5b <exec+0x405>
    iunlockput(ip);
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	ff 75 d8             	pushl  -0x28(%ebp)
80100f4e:	e8 7a 0c 00 00       	call   80101bcd <iunlockput>
80100f53:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f56:	e8 ed 25 00 00       	call   80103548 <end_op>
  }
  return -1;
80100f5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f60:	c9                   	leave  
80100f61:	c3                   	ret    

80100f62 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f62:	55                   	push   %ebp
80100f63:	89 e5                	mov    %esp,%ebp
80100f65:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f68:	83 ec 08             	sub    $0x8,%esp
80100f6b:	68 89 8f 10 80       	push   $0x80108f89
80100f70:	68 60 18 11 80       	push   $0x80111860
80100f75:	e8 3b 48 00 00       	call   801057b5 <initlock>
80100f7a:	83 c4 10             	add    $0x10,%esp
}
80100f7d:	90                   	nop
80100f7e:	c9                   	leave  
80100f7f:	c3                   	ret    

80100f80 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f80:	55                   	push   %ebp
80100f81:	89 e5                	mov    %esp,%ebp
80100f83:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f86:	83 ec 0c             	sub    $0xc,%esp
80100f89:	68 60 18 11 80       	push   $0x80111860
80100f8e:	e8 44 48 00 00       	call   801057d7 <acquire>
80100f93:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f96:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100f9d:	eb 2d                	jmp    80100fcc <filealloc+0x4c>
    if(f->ref == 0){
80100f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa2:	8b 40 04             	mov    0x4(%eax),%eax
80100fa5:	85 c0                	test   %eax,%eax
80100fa7:	75 1f                	jne    80100fc8 <filealloc+0x48>
      f->ref = 1;
80100fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fb3:	83 ec 0c             	sub    $0xc,%esp
80100fb6:	68 60 18 11 80       	push   $0x80111860
80100fbb:	e8 7e 48 00 00       	call   8010583e <release>
80100fc0:	83 c4 10             	add    $0x10,%esp
      return f;
80100fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc6:	eb 23                	jmp    80100feb <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc8:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fcc:	b8 f4 21 11 80       	mov    $0x801121f4,%eax
80100fd1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fd4:	72 c9                	jb     80100f9f <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fd6:	83 ec 0c             	sub    $0xc,%esp
80100fd9:	68 60 18 11 80       	push   $0x80111860
80100fde:	e8 5b 48 00 00       	call   8010583e <release>
80100fe3:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fe6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100feb:	c9                   	leave  
80100fec:	c3                   	ret    

80100fed <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fed:	55                   	push   %ebp
80100fee:	89 e5                	mov    %esp,%ebp
80100ff0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100ff3:	83 ec 0c             	sub    $0xc,%esp
80100ff6:	68 60 18 11 80       	push   $0x80111860
80100ffb:	e8 d7 47 00 00       	call   801057d7 <acquire>
80101000:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	8b 40 04             	mov    0x4(%eax),%eax
80101009:	85 c0                	test   %eax,%eax
8010100b:	7f 0d                	jg     8010101a <filedup+0x2d>
    panic("filedup");
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 90 8f 10 80       	push   $0x80108f90
80101015:	e8 4c f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	8b 40 04             	mov    0x4(%eax),%eax
80101020:	8d 50 01             	lea    0x1(%eax),%edx
80101023:	8b 45 08             	mov    0x8(%ebp),%eax
80101026:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101029:	83 ec 0c             	sub    $0xc,%esp
8010102c:	68 60 18 11 80       	push   $0x80111860
80101031:	e8 08 48 00 00       	call   8010583e <release>
80101036:	83 c4 10             	add    $0x10,%esp
  return f;
80101039:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010103c:	c9                   	leave  
8010103d:	c3                   	ret    

8010103e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010103e:	55                   	push   %ebp
8010103f:	89 e5                	mov    %esp,%ebp
80101041:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101044:	83 ec 0c             	sub    $0xc,%esp
80101047:	68 60 18 11 80       	push   $0x80111860
8010104c:	e8 86 47 00 00       	call   801057d7 <acquire>
80101051:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	7f 0d                	jg     8010106b <fileclose+0x2d>
    panic("fileclose");
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 98 8f 10 80       	push   $0x80108f98
80101066:	e8 fb f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	8b 40 04             	mov    0x4(%eax),%eax
80101071:	8d 50 ff             	lea    -0x1(%eax),%edx
80101074:	8b 45 08             	mov    0x8(%ebp),%eax
80101077:	89 50 04             	mov    %edx,0x4(%eax)
8010107a:	8b 45 08             	mov    0x8(%ebp),%eax
8010107d:	8b 40 04             	mov    0x4(%eax),%eax
80101080:	85 c0                	test   %eax,%eax
80101082:	7e 15                	jle    80101099 <fileclose+0x5b>
    release(&ftable.lock);
80101084:	83 ec 0c             	sub    $0xc,%esp
80101087:	68 60 18 11 80       	push   $0x80111860
8010108c:	e8 ad 47 00 00       	call   8010583e <release>
80101091:	83 c4 10             	add    $0x10,%esp
80101094:	e9 8b 00 00 00       	jmp    80101124 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101099:	8b 45 08             	mov    0x8(%ebp),%eax
8010109c:	8b 10                	mov    (%eax),%edx
8010109e:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010a1:	8b 50 04             	mov    0x4(%eax),%edx
801010a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010a7:	8b 50 08             	mov    0x8(%eax),%edx
801010aa:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010ad:	8b 50 0c             	mov    0xc(%eax),%edx
801010b0:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010b3:	8b 50 10             	mov    0x10(%eax),%edx
801010b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010b9:	8b 40 14             	mov    0x14(%eax),%eax
801010bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010c9:	8b 45 08             	mov    0x8(%ebp),%eax
801010cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010d2:	83 ec 0c             	sub    $0xc,%esp
801010d5:	68 60 18 11 80       	push   $0x80111860
801010da:	e8 5f 47 00 00       	call   8010583e <release>
801010df:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e5:	83 f8 01             	cmp    $0x1,%eax
801010e8:	75 19                	jne    80101103 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010ea:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010ee:	0f be d0             	movsbl %al,%edx
801010f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010f4:	83 ec 08             	sub    $0x8,%esp
801010f7:	52                   	push   %edx
801010f8:	50                   	push   %eax
801010f9:	e8 0f 30 00 00       	call   8010410d <pipeclose>
801010fe:	83 c4 10             	add    $0x10,%esp
80101101:	eb 21                	jmp    80101124 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101103:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101106:	83 f8 02             	cmp    $0x2,%eax
80101109:	75 19                	jne    80101124 <fileclose+0xe6>
    begin_op();
8010110b:	e8 ac 23 00 00       	call   801034bc <begin_op>
    iput(ff.ip);
80101110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	50                   	push   %eax
80101117:	e8 c1 09 00 00       	call   80101add <iput>
8010111c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010111f:	e8 24 24 00 00       	call   80103548 <end_op>
  }
}
80101124:	c9                   	leave  
80101125:	c3                   	ret    

80101126 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101126:	55                   	push   %ebp
80101127:	89 e5                	mov    %esp,%ebp
80101129:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 00                	mov    (%eax),%eax
80101131:	83 f8 02             	cmp    $0x2,%eax
80101134:	75 40                	jne    80101176 <filestat+0x50>
    ilock(f->ip);
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 40 10             	mov    0x10(%eax),%eax
8010113c:	83 ec 0c             	sub    $0xc,%esp
8010113f:	50                   	push   %eax
80101140:	e8 ce 07 00 00       	call   80101913 <ilock>
80101145:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 40 10             	mov    0x10(%eax),%eax
8010114e:	83 ec 08             	sub    $0x8,%esp
80101151:	ff 75 0c             	pushl  0xc(%ebp)
80101154:	50                   	push   %eax
80101155:	e8 db 0c 00 00       	call   80101e35 <stati>
8010115a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	8b 40 10             	mov    0x10(%eax),%eax
80101163:	83 ec 0c             	sub    $0xc,%esp
80101166:	50                   	push   %eax
80101167:	e8 ff 08 00 00       	call   80101a6b <iunlock>
8010116c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010116f:	b8 00 00 00 00       	mov    $0x0,%eax
80101174:	eb 05                	jmp    8010117b <filestat+0x55>
  }
  return -1;
80101176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010117b:	c9                   	leave  
8010117c:	c3                   	ret    

8010117d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010117d:	55                   	push   %ebp
8010117e:	89 e5                	mov    %esp,%ebp
80101180:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101183:	8b 45 08             	mov    0x8(%ebp),%eax
80101186:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010118a:	84 c0                	test   %al,%al
8010118c:	75 0a                	jne    80101198 <fileread+0x1b>
    return -1;
8010118e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101193:	e9 9b 00 00 00       	jmp    80101233 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	8b 00                	mov    (%eax),%eax
8010119d:	83 f8 01             	cmp    $0x1,%eax
801011a0:	75 1a                	jne    801011bc <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	8b 40 0c             	mov    0xc(%eax),%eax
801011a8:	83 ec 04             	sub    $0x4,%esp
801011ab:	ff 75 10             	pushl  0x10(%ebp)
801011ae:	ff 75 0c             	pushl  0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 fe 30 00 00       	call   801042b5 <piperead>
801011b7:	83 c4 10             	add    $0x10,%esp
801011ba:	eb 77                	jmp    80101233 <fileread+0xb6>
  if(f->type == FD_INODE){
801011bc:	8b 45 08             	mov    0x8(%ebp),%eax
801011bf:	8b 00                	mov    (%eax),%eax
801011c1:	83 f8 02             	cmp    $0x2,%eax
801011c4:	75 60                	jne    80101226 <fileread+0xa9>
    ilock(f->ip);
801011c6:	8b 45 08             	mov    0x8(%ebp),%eax
801011c9:	8b 40 10             	mov    0x10(%eax),%eax
801011cc:	83 ec 0c             	sub    $0xc,%esp
801011cf:	50                   	push   %eax
801011d0:	e8 3e 07 00 00       	call   80101913 <ilock>
801011d5:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 50 14             	mov    0x14(%eax),%edx
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	8b 40 10             	mov    0x10(%eax),%eax
801011e7:	51                   	push   %ecx
801011e8:	52                   	push   %edx
801011e9:	ff 75 0c             	pushl  0xc(%ebp)
801011ec:	50                   	push   %eax
801011ed:	e8 89 0c 00 00       	call   80101e7b <readi>
801011f2:	83 c4 10             	add    $0x10,%esp
801011f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011fc:	7e 11                	jle    8010120f <fileread+0x92>
      f->off += r;
801011fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101201:	8b 50 14             	mov    0x14(%eax),%edx
80101204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101207:	01 c2                	add    %eax,%edx
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010120f:	8b 45 08             	mov    0x8(%ebp),%eax
80101212:	8b 40 10             	mov    0x10(%eax),%eax
80101215:	83 ec 0c             	sub    $0xc,%esp
80101218:	50                   	push   %eax
80101219:	e8 4d 08 00 00       	call   80101a6b <iunlock>
8010121e:	83 c4 10             	add    $0x10,%esp
    return r;
80101221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101224:	eb 0d                	jmp    80101233 <fileread+0xb6>
  }
  panic("fileread");
80101226:	83 ec 0c             	sub    $0xc,%esp
80101229:	68 a2 8f 10 80       	push   $0x80108fa2
8010122e:	e8 33 f3 ff ff       	call   80100566 <panic>
}
80101233:	c9                   	leave  
80101234:	c3                   	ret    

80101235 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101235:	55                   	push   %ebp
80101236:	89 e5                	mov    %esp,%ebp
80101238:	53                   	push   %ebx
80101239:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010123c:	8b 45 08             	mov    0x8(%ebp),%eax
8010123f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101243:	84 c0                	test   %al,%al
80101245:	75 0a                	jne    80101251 <filewrite+0x1c>
    return -1;
80101247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010124c:	e9 1b 01 00 00       	jmp    8010136c <filewrite+0x137>
  if(f->type == FD_PIPE)
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	8b 00                	mov    (%eax),%eax
80101256:	83 f8 01             	cmp    $0x1,%eax
80101259:	75 1d                	jne    80101278 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 40 0c             	mov    0xc(%eax),%eax
80101261:	83 ec 04             	sub    $0x4,%esp
80101264:	ff 75 10             	pushl  0x10(%ebp)
80101267:	ff 75 0c             	pushl  0xc(%ebp)
8010126a:	50                   	push   %eax
8010126b:	e8 47 2f 00 00       	call   801041b7 <pipewrite>
80101270:	83 c4 10             	add    $0x10,%esp
80101273:	e9 f4 00 00 00       	jmp    8010136c <filewrite+0x137>
  if(f->type == FD_INODE){
80101278:	8b 45 08             	mov    0x8(%ebp),%eax
8010127b:	8b 00                	mov    (%eax),%eax
8010127d:	83 f8 02             	cmp    $0x2,%eax
80101280:	0f 85 d9 00 00 00    	jne    8010135f <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101286:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010128d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101294:	e9 a3 00 00 00       	jmp    8010133c <filewrite+0x107>
      int n1 = n - i;
80101299:	8b 45 10             	mov    0x10(%ebp),%eax
8010129c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010129f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012a5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012a8:	7e 06                	jle    801012b0 <filewrite+0x7b>
        n1 = max;
801012aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012ad:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012b0:	e8 07 22 00 00       	call   801034bc <begin_op>
      ilock(f->ip);
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 40 10             	mov    0x10(%eax),%eax
801012bb:	83 ec 0c             	sub    $0xc,%esp
801012be:	50                   	push   %eax
801012bf:	e8 4f 06 00 00       	call   80101913 <ilock>
801012c4:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012c7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012ca:	8b 45 08             	mov    0x8(%ebp),%eax
801012cd:	8b 50 14             	mov    0x14(%eax),%edx
801012d0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801012d6:	01 c3                	add    %eax,%ebx
801012d8:	8b 45 08             	mov    0x8(%ebp),%eax
801012db:	8b 40 10             	mov    0x10(%eax),%eax
801012de:	51                   	push   %ecx
801012df:	52                   	push   %edx
801012e0:	53                   	push   %ebx
801012e1:	50                   	push   %eax
801012e2:	e8 eb 0c 00 00       	call   80101fd2 <writei>
801012e7:	83 c4 10             	add    $0x10,%esp
801012ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012ed:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012f1:	7e 11                	jle    80101304 <filewrite+0xcf>
        f->off += r;
801012f3:	8b 45 08             	mov    0x8(%ebp),%eax
801012f6:	8b 50 14             	mov    0x14(%eax),%edx
801012f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012fc:	01 c2                	add    %eax,%edx
801012fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101301:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	8b 40 10             	mov    0x10(%eax),%eax
8010130a:	83 ec 0c             	sub    $0xc,%esp
8010130d:	50                   	push   %eax
8010130e:	e8 58 07 00 00       	call   80101a6b <iunlock>
80101313:	83 c4 10             	add    $0x10,%esp
      end_op();
80101316:	e8 2d 22 00 00       	call   80103548 <end_op>

      if(r < 0)
8010131b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010131f:	78 29                	js     8010134a <filewrite+0x115>
        break;
      if(r != n1)
80101321:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101324:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101327:	74 0d                	je     80101336 <filewrite+0x101>
        panic("short filewrite");
80101329:	83 ec 0c             	sub    $0xc,%esp
8010132c:	68 ab 8f 10 80       	push   $0x80108fab
80101331:	e8 30 f2 ff ff       	call   80100566 <panic>
      i += r;
80101336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101339:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101342:	0f 8c 51 ff ff ff    	jl     80101299 <filewrite+0x64>
80101348:	eb 01                	jmp    8010134b <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010134a:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101351:	75 05                	jne    80101358 <filewrite+0x123>
80101353:	8b 45 10             	mov    0x10(%ebp),%eax
80101356:	eb 14                	jmp    8010136c <filewrite+0x137>
80101358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010135d:	eb 0d                	jmp    8010136c <filewrite+0x137>
  }
  panic("filewrite");
8010135f:	83 ec 0c             	sub    $0xc,%esp
80101362:	68 bb 8f 10 80       	push   $0x80108fbb
80101367:	e8 fa f1 ff ff       	call   80100566 <panic>
}
8010136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010136f:	c9                   	leave  
80101370:	c3                   	ret    

80101371 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101371:	55                   	push   %ebp
80101372:	89 e5                	mov    %esp,%ebp
80101374:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101377:	8b 45 08             	mov    0x8(%ebp),%eax
8010137a:	83 ec 08             	sub    $0x8,%esp
8010137d:	6a 01                	push   $0x1
8010137f:	50                   	push   %eax
80101380:	e8 31 ee ff ff       	call   801001b6 <bread>
80101385:	83 c4 10             	add    $0x10,%esp
80101388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	83 c0 18             	add    $0x18,%eax
80101391:	83 ec 04             	sub    $0x4,%esp
80101394:	6a 10                	push   $0x10
80101396:	50                   	push   %eax
80101397:	ff 75 0c             	pushl  0xc(%ebp)
8010139a:	e8 5a 47 00 00       	call   80105af9 <memmove>
8010139f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013a2:	83 ec 0c             	sub    $0xc,%esp
801013a5:	ff 75 f4             	pushl  -0xc(%ebp)
801013a8:	e8 81 ee ff ff       	call   8010022e <brelse>
801013ad:	83 c4 10             	add    $0x10,%esp
}
801013b0:	90                   	nop
801013b1:	c9                   	leave  
801013b2:	c3                   	ret    

801013b3 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013b3:	55                   	push   %ebp
801013b4:	89 e5                	mov    %esp,%ebp
801013b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	83 ec 08             	sub    $0x8,%esp
801013c2:	52                   	push   %edx
801013c3:	50                   	push   %eax
801013c4:	e8 ed ed ff ff       	call   801001b6 <bread>
801013c9:	83 c4 10             	add    $0x10,%esp
801013cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	83 c0 18             	add    $0x18,%eax
801013d5:	83 ec 04             	sub    $0x4,%esp
801013d8:	68 00 02 00 00       	push   $0x200
801013dd:	6a 00                	push   $0x0
801013df:	50                   	push   %eax
801013e0:	e8 55 46 00 00       	call   80105a3a <memset>
801013e5:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013e8:	83 ec 0c             	sub    $0xc,%esp
801013eb:	ff 75 f4             	pushl  -0xc(%ebp)
801013ee:	e8 01 23 00 00       	call   801036f4 <log_write>
801013f3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013f6:	83 ec 0c             	sub    $0xc,%esp
801013f9:	ff 75 f4             	pushl  -0xc(%ebp)
801013fc:	e8 2d ee ff ff       	call   8010022e <brelse>
80101401:	83 c4 10             	add    $0x10,%esp
}
80101404:	90                   	nop
80101405:	c9                   	leave  
80101406:	c3                   	ret    

80101407 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101407:	55                   	push   %ebp
80101408:	89 e5                	mov    %esp,%ebp
8010140a:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010140d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101414:	8b 45 08             	mov    0x8(%ebp),%eax
80101417:	83 ec 08             	sub    $0x8,%esp
8010141a:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010141d:	52                   	push   %edx
8010141e:	50                   	push   %eax
8010141f:	e8 4d ff ff ff       	call   80101371 <readsb>
80101424:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010142e:	e9 15 01 00 00       	jmp    80101548 <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010143c:	85 c0                	test   %eax,%eax
8010143e:	0f 48 c2             	cmovs  %edx,%eax
80101441:	c1 f8 0c             	sar    $0xc,%eax
80101444:	89 c2                	mov    %eax,%edx
80101446:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101449:	c1 e8 03             	shr    $0x3,%eax
8010144c:	01 d0                	add    %edx,%eax
8010144e:	83 c0 03             	add    $0x3,%eax
80101451:	83 ec 08             	sub    $0x8,%esp
80101454:	50                   	push   %eax
80101455:	ff 75 08             	pushl  0x8(%ebp)
80101458:	e8 59 ed ff ff       	call   801001b6 <bread>
8010145d:	83 c4 10             	add    $0x10,%esp
80101460:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101463:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010146a:	e9 a6 00 00 00       	jmp    80101515 <balloc+0x10e>
      m = 1 << (bi % 8);
8010146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101472:	99                   	cltd   
80101473:	c1 ea 1d             	shr    $0x1d,%edx
80101476:	01 d0                	add    %edx,%eax
80101478:	83 e0 07             	and    $0x7,%eax
8010147b:	29 d0                	sub    %edx,%eax
8010147d:	ba 01 00 00 00       	mov    $0x1,%edx
80101482:	89 c1                	mov    %eax,%ecx
80101484:	d3 e2                	shl    %cl,%edx
80101486:	89 d0                	mov    %edx,%eax
80101488:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148e:	8d 50 07             	lea    0x7(%eax),%edx
80101491:	85 c0                	test   %eax,%eax
80101493:	0f 48 c2             	cmovs  %edx,%eax
80101496:	c1 f8 03             	sar    $0x3,%eax
80101499:	89 c2                	mov    %eax,%edx
8010149b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149e:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014a3:	0f b6 c0             	movzbl %al,%eax
801014a6:	23 45 e8             	and    -0x18(%ebp),%eax
801014a9:	85 c0                	test   %eax,%eax
801014ab:	75 64                	jne    80101511 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
801014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b0:	8d 50 07             	lea    0x7(%eax),%edx
801014b3:	85 c0                	test   %eax,%eax
801014b5:	0f 48 c2             	cmovs  %edx,%eax
801014b8:	c1 f8 03             	sar    $0x3,%eax
801014bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014be:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014c3:	89 d1                	mov    %edx,%ecx
801014c5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c8:	09 ca                	or     %ecx,%edx
801014ca:	89 d1                	mov    %edx,%ecx
801014cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cf:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014d3:	83 ec 0c             	sub    $0xc,%esp
801014d6:	ff 75 ec             	pushl  -0x14(%ebp)
801014d9:	e8 16 22 00 00       	call   801036f4 <log_write>
801014de:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014e1:	83 ec 0c             	sub    $0xc,%esp
801014e4:	ff 75 ec             	pushl  -0x14(%ebp)
801014e7:	e8 42 ed ff ff       	call   8010022e <brelse>
801014ec:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f5:	01 c2                	add    %eax,%edx
801014f7:	8b 45 08             	mov    0x8(%ebp),%eax
801014fa:	83 ec 08             	sub    $0x8,%esp
801014fd:	52                   	push   %edx
801014fe:	50                   	push   %eax
801014ff:	e8 af fe ff ff       	call   801013b3 <bzero>
80101504:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150d:	01 d0                	add    %edx,%eax
8010150f:	eb 52                	jmp    80101563 <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101511:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101515:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010151c:	7f 15                	jg     80101533 <balloc+0x12c>
8010151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101524:	01 d0                	add    %edx,%eax
80101526:	89 c2                	mov    %eax,%edx
80101528:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010152b:	39 c2                	cmp    %eax,%edx
8010152d:	0f 82 3c ff ff ff    	jb     8010146f <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101533:	83 ec 0c             	sub    $0xc,%esp
80101536:	ff 75 ec             	pushl  -0x14(%ebp)
80101539:	e8 f0 ec ff ff       	call   8010022e <brelse>
8010153e:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101541:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101548:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010154b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154e:	39 c2                	cmp    %eax,%edx
80101550:	0f 87 dd fe ff ff    	ja     80101433 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101556:	83 ec 0c             	sub    $0xc,%esp
80101559:	68 c5 8f 10 80       	push   $0x80108fc5
8010155e:	e8 03 f0 ff ff       	call   80100566 <panic>
}
80101563:	c9                   	leave  
80101564:	c3                   	ret    

80101565 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101565:	55                   	push   %ebp
80101566:	89 e5                	mov    %esp,%ebp
80101568:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
8010156b:	83 ec 08             	sub    $0x8,%esp
8010156e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101571:	50                   	push   %eax
80101572:	ff 75 08             	pushl  0x8(%ebp)
80101575:	e8 f7 fd ff ff       	call   80101371 <readsb>
8010157a:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010157d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101580:	c1 e8 0c             	shr    $0xc,%eax
80101583:	89 c2                	mov    %eax,%edx
80101585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101588:	c1 e8 03             	shr    $0x3,%eax
8010158b:	01 d0                	add    %edx,%eax
8010158d:	8d 50 03             	lea    0x3(%eax),%edx
80101590:	8b 45 08             	mov    0x8(%ebp),%eax
80101593:	83 ec 08             	sub    $0x8,%esp
80101596:	52                   	push   %edx
80101597:	50                   	push   %eax
80101598:	e8 19 ec ff ff       	call   801001b6 <bread>
8010159d:	83 c4 10             	add    $0x10,%esp
801015a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b1:	99                   	cltd   
801015b2:	c1 ea 1d             	shr    $0x1d,%edx
801015b5:	01 d0                	add    %edx,%eax
801015b7:	83 e0 07             	and    $0x7,%eax
801015ba:	29 d0                	sub    %edx,%eax
801015bc:	ba 01 00 00 00       	mov    $0x1,%edx
801015c1:	89 c1                	mov    %eax,%ecx
801015c3:	d3 e2                	shl    %cl,%edx
801015c5:	89 d0                	mov    %edx,%eax
801015c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cd:	8d 50 07             	lea    0x7(%eax),%edx
801015d0:	85 c0                	test   %eax,%eax
801015d2:	0f 48 c2             	cmovs  %edx,%eax
801015d5:	c1 f8 03             	sar    $0x3,%eax
801015d8:	89 c2                	mov    %eax,%edx
801015da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015dd:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e2:	0f b6 c0             	movzbl %al,%eax
801015e5:	23 45 ec             	and    -0x14(%ebp),%eax
801015e8:	85 c0                	test   %eax,%eax
801015ea:	75 0d                	jne    801015f9 <bfree+0x94>
    panic("freeing free block");
801015ec:	83 ec 0c             	sub    $0xc,%esp
801015ef:	68 db 8f 10 80       	push   $0x80108fdb
801015f4:	e8 6d ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fc:	8d 50 07             	lea    0x7(%eax),%edx
801015ff:	85 c0                	test   %eax,%eax
80101601:	0f 48 c2             	cmovs  %edx,%eax
80101604:	c1 f8 03             	sar    $0x3,%eax
80101607:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010160a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010160f:	89 d1                	mov    %edx,%ecx
80101611:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101614:	f7 d2                	not    %edx
80101616:	21 ca                	and    %ecx,%edx
80101618:	89 d1                	mov    %edx,%ecx
8010161a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101621:	83 ec 0c             	sub    $0xc,%esp
80101624:	ff 75 f4             	pushl  -0xc(%ebp)
80101627:	e8 c8 20 00 00       	call   801036f4 <log_write>
8010162c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010162f:	83 ec 0c             	sub    $0xc,%esp
80101632:	ff 75 f4             	pushl  -0xc(%ebp)
80101635:	e8 f4 eb ff ff       	call   8010022e <brelse>
8010163a:	83 c4 10             	add    $0x10,%esp
}
8010163d:	90                   	nop
8010163e:	c9                   	leave  
8010163f:	c3                   	ret    

80101640 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101640:	55                   	push   %ebp
80101641:	89 e5                	mov    %esp,%ebp
80101643:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
80101646:	83 ec 08             	sub    $0x8,%esp
80101649:	68 ee 8f 10 80       	push   $0x80108fee
8010164e:	68 60 22 11 80       	push   $0x80112260
80101653:	e8 5d 41 00 00       	call   801057b5 <initlock>
80101658:	83 c4 10             	add    $0x10,%esp
}
8010165b:	90                   	nop
8010165c:	c9                   	leave  
8010165d:	c3                   	ret    

8010165e <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010165e:	55                   	push   %ebp
8010165f:	89 e5                	mov    %esp,%ebp
80101661:	83 ec 38             	sub    $0x38,%esp
80101664:	8b 45 0c             	mov    0xc(%ebp),%eax
80101667:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
8010166b:	8b 45 08             	mov    0x8(%ebp),%eax
8010166e:	83 ec 08             	sub    $0x8,%esp
80101671:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101674:	52                   	push   %edx
80101675:	50                   	push   %eax
80101676:	e8 f6 fc ff ff       	call   80101371 <readsb>
8010167b:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
8010167e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101685:	e9 98 00 00 00       	jmp    80101722 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
8010168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010168d:	c1 e8 03             	shr    $0x3,%eax
80101690:	83 c0 02             	add    $0x2,%eax
80101693:	83 ec 08             	sub    $0x8,%esp
80101696:	50                   	push   %eax
80101697:	ff 75 08             	pushl  0x8(%ebp)
8010169a:	e8 17 eb ff ff       	call   801001b6 <bread>
8010169f:	83 c4 10             	add    $0x10,%esp
801016a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a8:	8d 50 18             	lea    0x18(%eax),%edx
801016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ae:	83 e0 07             	and    $0x7,%eax
801016b1:	c1 e0 06             	shl    $0x6,%eax
801016b4:	01 d0                	add    %edx,%eax
801016b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016bc:	0f b7 00             	movzwl (%eax),%eax
801016bf:	66 85 c0             	test   %ax,%ax
801016c2:	75 4c                	jne    80101710 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016c4:	83 ec 04             	sub    $0x4,%esp
801016c7:	6a 40                	push   $0x40
801016c9:	6a 00                	push   $0x0
801016cb:	ff 75 ec             	pushl  -0x14(%ebp)
801016ce:	e8 67 43 00 00       	call   80105a3a <memset>
801016d3:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016d9:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016dd:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016e0:	83 ec 0c             	sub    $0xc,%esp
801016e3:	ff 75 f0             	pushl  -0x10(%ebp)
801016e6:	e8 09 20 00 00       	call   801036f4 <log_write>
801016eb:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016ee:	83 ec 0c             	sub    $0xc,%esp
801016f1:	ff 75 f0             	pushl  -0x10(%ebp)
801016f4:	e8 35 eb ff ff       	call   8010022e <brelse>
801016f9:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ff:	83 ec 08             	sub    $0x8,%esp
80101702:	50                   	push   %eax
80101703:	ff 75 08             	pushl  0x8(%ebp)
80101706:	e8 ef 00 00 00       	call   801017fa <iget>
8010170b:	83 c4 10             	add    $0x10,%esp
8010170e:	eb 2d                	jmp    8010173d <ialloc+0xdf>
    }
    brelse(bp);
80101710:	83 ec 0c             	sub    $0xc,%esp
80101713:	ff 75 f0             	pushl  -0x10(%ebp)
80101716:	e8 13 eb ff ff       	call   8010022e <brelse>
8010171b:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010171e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101722:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101728:	39 c2                	cmp    %eax,%edx
8010172a:	0f 87 5a ff ff ff    	ja     8010168a <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101730:	83 ec 0c             	sub    $0xc,%esp
80101733:	68 f5 8f 10 80       	push   $0x80108ff5
80101738:	e8 29 ee ff ff       	call   80100566 <panic>
}
8010173d:	c9                   	leave  
8010173e:	c3                   	ret    

8010173f <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101745:	8b 45 08             	mov    0x8(%ebp),%eax
80101748:	8b 40 04             	mov    0x4(%eax),%eax
8010174b:	c1 e8 03             	shr    $0x3,%eax
8010174e:	8d 50 02             	lea    0x2(%eax),%edx
80101751:	8b 45 08             	mov    0x8(%ebp),%eax
80101754:	8b 00                	mov    (%eax),%eax
80101756:	83 ec 08             	sub    $0x8,%esp
80101759:	52                   	push   %edx
8010175a:	50                   	push   %eax
8010175b:	e8 56 ea ff ff       	call   801001b6 <bread>
80101760:	83 c4 10             	add    $0x10,%esp
80101763:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101769:	8d 50 18             	lea    0x18(%eax),%edx
8010176c:	8b 45 08             	mov    0x8(%ebp),%eax
8010176f:	8b 40 04             	mov    0x4(%eax),%eax
80101772:	83 e0 07             	and    $0x7,%eax
80101775:	c1 e0 06             	shl    $0x6,%eax
80101778:	01 d0                	add    %edx,%eax
8010177a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010177d:	8b 45 08             	mov    0x8(%ebp),%eax
80101780:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101787:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010178a:	8b 45 08             	mov    0x8(%ebp),%eax
8010178d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101794:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101798:	8b 45 08             	mov    0x8(%ebp),%eax
8010179b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010179f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a2:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017a6:	8b 45 08             	mov    0x8(%ebp),%eax
801017a9:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b0:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017b4:	8b 45 08             	mov    0x8(%ebp),%eax
801017b7:	8b 50 18             	mov    0x18(%eax),%edx
801017ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017bd:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017c0:	8b 45 08             	mov    0x8(%ebp),%eax
801017c3:	8d 50 1c             	lea    0x1c(%eax),%edx
801017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c9:	83 c0 0c             	add    $0xc,%eax
801017cc:	83 ec 04             	sub    $0x4,%esp
801017cf:	6a 34                	push   $0x34
801017d1:	52                   	push   %edx
801017d2:	50                   	push   %eax
801017d3:	e8 21 43 00 00       	call   80105af9 <memmove>
801017d8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f4             	pushl  -0xc(%ebp)
801017e1:	e8 0e 1f 00 00       	call   801036f4 <log_write>
801017e6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017e9:	83 ec 0c             	sub    $0xc,%esp
801017ec:	ff 75 f4             	pushl  -0xc(%ebp)
801017ef:	e8 3a ea ff ff       	call   8010022e <brelse>
801017f4:	83 c4 10             	add    $0x10,%esp
}
801017f7:	90                   	nop
801017f8:	c9                   	leave  
801017f9:	c3                   	ret    

801017fa <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017fa:	55                   	push   %ebp
801017fb:	89 e5                	mov    %esp,%ebp
801017fd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101800:	83 ec 0c             	sub    $0xc,%esp
80101803:	68 60 22 11 80       	push   $0x80112260
80101808:	e8 ca 3f 00 00       	call   801057d7 <acquire>
8010180d:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101810:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101817:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
8010181e:	eb 5d                	jmp    8010187d <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101823:	8b 40 08             	mov    0x8(%eax),%eax
80101826:	85 c0                	test   %eax,%eax
80101828:	7e 39                	jle    80101863 <iget+0x69>
8010182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182d:	8b 00                	mov    (%eax),%eax
8010182f:	3b 45 08             	cmp    0x8(%ebp),%eax
80101832:	75 2f                	jne    80101863 <iget+0x69>
80101834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101837:	8b 40 04             	mov    0x4(%eax),%eax
8010183a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010183d:	75 24                	jne    80101863 <iget+0x69>
      ip->ref++;
8010183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101842:	8b 40 08             	mov    0x8(%eax),%eax
80101845:	8d 50 01             	lea    0x1(%eax),%edx
80101848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184b:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010184e:	83 ec 0c             	sub    $0xc,%esp
80101851:	68 60 22 11 80       	push   $0x80112260
80101856:	e8 e3 3f 00 00       	call   8010583e <release>
8010185b:	83 c4 10             	add    $0x10,%esp
      return ip;
8010185e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101861:	eb 74                	jmp    801018d7 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101863:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101867:	75 10                	jne    80101879 <iget+0x7f>
80101869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186c:	8b 40 08             	mov    0x8(%eax),%eax
8010186f:	85 c0                	test   %eax,%eax
80101871:	75 06                	jne    80101879 <iget+0x7f>
      empty = ip;
80101873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101876:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101879:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010187d:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
80101884:	72 9a                	jb     80101820 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101886:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010188a:	75 0d                	jne    80101899 <iget+0x9f>
    panic("iget: no inodes");
8010188c:	83 ec 0c             	sub    $0xc,%esp
8010188f:	68 07 90 10 80       	push   $0x80109007
80101894:	e8 cd ec ff ff       	call   80100566 <panic>

  ip = empty;
80101899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	8b 55 08             	mov    0x8(%ebp),%edx
801018a5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801018ad:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018c4:	83 ec 0c             	sub    $0xc,%esp
801018c7:	68 60 22 11 80       	push   $0x80112260
801018cc:	e8 6d 3f 00 00       	call   8010583e <release>
801018d1:	83 c4 10             	add    $0x10,%esp

  return ip;
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018d7:	c9                   	leave  
801018d8:	c3                   	ret    

801018d9 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018d9:	55                   	push   %ebp
801018da:	89 e5                	mov    %esp,%ebp
801018dc:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018df:	83 ec 0c             	sub    $0xc,%esp
801018e2:	68 60 22 11 80       	push   $0x80112260
801018e7:	e8 eb 3e 00 00       	call   801057d7 <acquire>
801018ec:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018ef:	8b 45 08             	mov    0x8(%ebp),%eax
801018f2:	8b 40 08             	mov    0x8(%eax),%eax
801018f5:	8d 50 01             	lea    0x1(%eax),%edx
801018f8:	8b 45 08             	mov    0x8(%ebp),%eax
801018fb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018fe:	83 ec 0c             	sub    $0xc,%esp
80101901:	68 60 22 11 80       	push   $0x80112260
80101906:	e8 33 3f 00 00       	call   8010583e <release>
8010190b:	83 c4 10             	add    $0x10,%esp
  return ip;
8010190e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101911:	c9                   	leave  
80101912:	c3                   	ret    

80101913 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101913:	55                   	push   %ebp
80101914:	89 e5                	mov    %esp,%ebp
80101916:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101919:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010191d:	74 0a                	je     80101929 <ilock+0x16>
8010191f:	8b 45 08             	mov    0x8(%ebp),%eax
80101922:	8b 40 08             	mov    0x8(%eax),%eax
80101925:	85 c0                	test   %eax,%eax
80101927:	7f 0d                	jg     80101936 <ilock+0x23>
    panic("ilock");
80101929:	83 ec 0c             	sub    $0xc,%esp
8010192c:	68 17 90 10 80       	push   $0x80109017
80101931:	e8 30 ec ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101936:	83 ec 0c             	sub    $0xc,%esp
80101939:	68 60 22 11 80       	push   $0x80112260
8010193e:	e8 94 3e 00 00       	call   801057d7 <acquire>
80101943:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101946:	eb 13                	jmp    8010195b <ilock+0x48>
    sleep(ip, &icache.lock);
80101948:	83 ec 08             	sub    $0x8,%esp
8010194b:	68 60 22 11 80       	push   $0x80112260
80101950:	ff 75 08             	pushl  0x8(%ebp)
80101953:	e8 c3 36 00 00       	call   8010501b <sleep>
80101958:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	8b 40 0c             	mov    0xc(%eax),%eax
80101961:	83 e0 01             	and    $0x1,%eax
80101964:	85 c0                	test   %eax,%eax
80101966:	75 e0                	jne    80101948 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	8b 40 0c             	mov    0xc(%eax),%eax
8010196e:	83 c8 01             	or     $0x1,%eax
80101971:	89 c2                	mov    %eax,%edx
80101973:	8b 45 08             	mov    0x8(%ebp),%eax
80101976:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101979:	83 ec 0c             	sub    $0xc,%esp
8010197c:	68 60 22 11 80       	push   $0x80112260
80101981:	e8 b8 3e 00 00       	call   8010583e <release>
80101986:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	8b 40 0c             	mov    0xc(%eax),%eax
8010198f:	83 e0 02             	and    $0x2,%eax
80101992:	85 c0                	test   %eax,%eax
80101994:	0f 85 ce 00 00 00    	jne    80101a68 <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	8b 40 04             	mov    0x4(%eax),%eax
801019a0:	c1 e8 03             	shr    $0x3,%eax
801019a3:	8d 50 02             	lea    0x2(%eax),%edx
801019a6:	8b 45 08             	mov    0x8(%ebp),%eax
801019a9:	8b 00                	mov    (%eax),%eax
801019ab:	83 ec 08             	sub    $0x8,%esp
801019ae:	52                   	push   %edx
801019af:	50                   	push   %eax
801019b0:	e8 01 e8 ff ff       	call   801001b6 <bread>
801019b5:	83 c4 10             	add    $0x10,%esp
801019b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019be:	8d 50 18             	lea    0x18(%eax),%edx
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 04             	mov    0x4(%eax),%eax
801019c7:	83 e0 07             	and    $0x7,%eax
801019ca:	c1 e0 06             	shl    $0x6,%eax
801019cd:	01 d0                	add    %edx,%eax
801019cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d5:	0f b7 10             	movzwl (%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e2:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f0:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019f4:	8b 45 08             	mov    0x8(%ebp),%eax
801019f7:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fe:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a02:	8b 45 08             	mov    0x8(%ebp),%eax
80101a05:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a0c:	8b 50 08             	mov    0x8(%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a18:	8d 50 0c             	lea    0xc(%eax),%edx
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	83 c0 1c             	add    $0x1c,%eax
80101a21:	83 ec 04             	sub    $0x4,%esp
80101a24:	6a 34                	push   $0x34
80101a26:	52                   	push   %edx
80101a27:	50                   	push   %eax
80101a28:	e8 cc 40 00 00       	call   80105af9 <memmove>
80101a2d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a30:	83 ec 0c             	sub    $0xc,%esp
80101a33:	ff 75 f4             	pushl  -0xc(%ebp)
80101a36:	e8 f3 e7 ff ff       	call   8010022e <brelse>
80101a3b:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a41:	8b 40 0c             	mov    0xc(%eax),%eax
80101a44:	83 c8 02             	or     $0x2,%eax
80101a47:	89 c2                	mov    %eax,%edx
80101a49:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a56:	66 85 c0             	test   %ax,%ax
80101a59:	75 0d                	jne    80101a68 <ilock+0x155>
      panic("ilock: no type");
80101a5b:	83 ec 0c             	sub    $0xc,%esp
80101a5e:	68 1d 90 10 80       	push   $0x8010901d
80101a63:	e8 fe ea ff ff       	call   80100566 <panic>
  }
}
80101a68:	90                   	nop
80101a69:	c9                   	leave  
80101a6a:	c3                   	ret    

80101a6b <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a6b:	55                   	push   %ebp
80101a6c:	89 e5                	mov    %esp,%ebp
80101a6e:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a71:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a75:	74 17                	je     80101a8e <iunlock+0x23>
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7a:	8b 40 0c             	mov    0xc(%eax),%eax
80101a7d:	83 e0 01             	and    $0x1,%eax
80101a80:	85 c0                	test   %eax,%eax
80101a82:	74 0a                	je     80101a8e <iunlock+0x23>
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	8b 40 08             	mov    0x8(%eax),%eax
80101a8a:	85 c0                	test   %eax,%eax
80101a8c:	7f 0d                	jg     80101a9b <iunlock+0x30>
    panic("iunlock");
80101a8e:	83 ec 0c             	sub    $0xc,%esp
80101a91:	68 2c 90 10 80       	push   $0x8010902c
80101a96:	e8 cb ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a9b:	83 ec 0c             	sub    $0xc,%esp
80101a9e:	68 60 22 11 80       	push   $0x80112260
80101aa3:	e8 2f 3d 00 00       	call   801057d7 <acquire>
80101aa8:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab1:	83 e0 fe             	and    $0xfffffffe,%eax
80101ab4:	89 c2                	mov    %eax,%edx
80101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab9:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101abc:	83 ec 0c             	sub    $0xc,%esp
80101abf:	ff 75 08             	pushl  0x8(%ebp)
80101ac2:	e8 60 36 00 00       	call   80105127 <wakeup>
80101ac7:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101aca:	83 ec 0c             	sub    $0xc,%esp
80101acd:	68 60 22 11 80       	push   $0x80112260
80101ad2:	e8 67 3d 00 00       	call   8010583e <release>
80101ad7:	83 c4 10             	add    $0x10,%esp
}
80101ada:	90                   	nop
80101adb:	c9                   	leave  
80101adc:	c3                   	ret    

80101add <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101add:	55                   	push   %ebp
80101ade:	89 e5                	mov    %esp,%ebp
80101ae0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ae3:	83 ec 0c             	sub    $0xc,%esp
80101ae6:	68 60 22 11 80       	push   $0x80112260
80101aeb:	e8 e7 3c 00 00       	call   801057d7 <acquire>
80101af0:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	8b 40 08             	mov    0x8(%eax),%eax
80101af9:	83 f8 01             	cmp    $0x1,%eax
80101afc:	0f 85 a9 00 00 00    	jne    80101bab <iput+0xce>
80101b02:	8b 45 08             	mov    0x8(%ebp),%eax
80101b05:	8b 40 0c             	mov    0xc(%eax),%eax
80101b08:	83 e0 02             	and    $0x2,%eax
80101b0b:	85 c0                	test   %eax,%eax
80101b0d:	0f 84 98 00 00 00    	je     80101bab <iput+0xce>
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b1a:	66 85 c0             	test   %ax,%ax
80101b1d:	0f 85 88 00 00 00    	jne    80101bab <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	8b 40 0c             	mov    0xc(%eax),%eax
80101b29:	83 e0 01             	and    $0x1,%eax
80101b2c:	85 c0                	test   %eax,%eax
80101b2e:	74 0d                	je     80101b3d <iput+0x60>
      panic("iput busy");
80101b30:	83 ec 0c             	sub    $0xc,%esp
80101b33:	68 34 90 10 80       	push   $0x80109034
80101b38:	e8 29 ea ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b40:	8b 40 0c             	mov    0xc(%eax),%eax
80101b43:	83 c8 01             	or     $0x1,%eax
80101b46:	89 c2                	mov    %eax,%edx
80101b48:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4b:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b4e:	83 ec 0c             	sub    $0xc,%esp
80101b51:	68 60 22 11 80       	push   $0x80112260
80101b56:	e8 e3 3c 00 00       	call   8010583e <release>
80101b5b:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b5e:	83 ec 0c             	sub    $0xc,%esp
80101b61:	ff 75 08             	pushl  0x8(%ebp)
80101b64:	e8 a8 01 00 00       	call   80101d11 <itrunc>
80101b69:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b75:	83 ec 0c             	sub    $0xc,%esp
80101b78:	ff 75 08             	pushl  0x8(%ebp)
80101b7b:	e8 bf fb ff ff       	call   8010173f <iupdate>
80101b80:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 60 22 11 80       	push   $0x80112260
80101b8b:	e8 47 3c 00 00       	call   801057d7 <acquire>
80101b90:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b9d:	83 ec 0c             	sub    $0xc,%esp
80101ba0:	ff 75 08             	pushl  0x8(%ebp)
80101ba3:	e8 7f 35 00 00       	call   80105127 <wakeup>
80101ba8:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	8b 40 08             	mov    0x8(%eax),%eax
80101bb1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bba:	83 ec 0c             	sub    $0xc,%esp
80101bbd:	68 60 22 11 80       	push   $0x80112260
80101bc2:	e8 77 3c 00 00       	call   8010583e <release>
80101bc7:	83 c4 10             	add    $0x10,%esp
}
80101bca:	90                   	nop
80101bcb:	c9                   	leave  
80101bcc:	c3                   	ret    

80101bcd <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bcd:	55                   	push   %ebp
80101bce:	89 e5                	mov    %esp,%ebp
80101bd0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101bd3:	83 ec 0c             	sub    $0xc,%esp
80101bd6:	ff 75 08             	pushl  0x8(%ebp)
80101bd9:	e8 8d fe ff ff       	call   80101a6b <iunlock>
80101bde:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101be1:	83 ec 0c             	sub    $0xc,%esp
80101be4:	ff 75 08             	pushl  0x8(%ebp)
80101be7:	e8 f1 fe ff ff       	call   80101add <iput>
80101bec:	83 c4 10             	add    $0x10,%esp
}
80101bef:	90                   	nop
80101bf0:	c9                   	leave  
80101bf1:	c3                   	ret    

80101bf2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bf2:	55                   	push   %ebp
80101bf3:	89 e5                	mov    %esp,%ebp
80101bf5:	53                   	push   %ebx
80101bf6:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bf9:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101bfd:	77 42                	ja     80101c41 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c05:	83 c2 04             	add    $0x4,%edx
80101c08:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c13:	75 24                	jne    80101c39 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c15:	8b 45 08             	mov    0x8(%ebp),%eax
80101c18:	8b 00                	mov    (%eax),%eax
80101c1a:	83 ec 0c             	sub    $0xc,%esp
80101c1d:	50                   	push   %eax
80101c1e:	e8 e4 f7 ff ff       	call   80101407 <balloc>
80101c23:	83 c4 10             	add    $0x10,%esp
80101c26:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c2f:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c35:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c3c:	e9 cb 00 00 00       	jmp    80101d0c <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c41:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c45:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c49:	0f 87 b0 00 00 00    	ja     80101cff <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c5c:	75 1d                	jne    80101c7b <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c61:	8b 00                	mov    (%eax),%eax
80101c63:	83 ec 0c             	sub    $0xc,%esp
80101c66:	50                   	push   %eax
80101c67:	e8 9b f7 ff ff       	call   80101407 <balloc>
80101c6c:	83 c4 10             	add    $0x10,%esp
80101c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c78:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	8b 00                	mov    (%eax),%eax
80101c80:	83 ec 08             	sub    $0x8,%esp
80101c83:	ff 75 f4             	pushl  -0xc(%ebp)
80101c86:	50                   	push   %eax
80101c87:	e8 2a e5 ff ff       	call   801001b6 <bread>
80101c8c:	83 c4 10             	add    $0x10,%esp
80101c8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c95:	83 c0 18             	add    $0x18,%eax
80101c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ca8:	01 d0                	add    %edx,%eax
80101caa:	8b 00                	mov    (%eax),%eax
80101cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101caf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb3:	75 37                	jne    80101cec <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc8:	8b 00                	mov    (%eax),%eax
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	50                   	push   %eax
80101cce:	e8 34 f7 ff ff       	call   80101407 <balloc>
80101cd3:	83 c4 10             	add    $0x10,%esp
80101cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cdc:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cde:	83 ec 0c             	sub    $0xc,%esp
80101ce1:	ff 75 f0             	pushl  -0x10(%ebp)
80101ce4:	e8 0b 1a 00 00       	call   801036f4 <log_write>
80101ce9:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cec:	83 ec 0c             	sub    $0xc,%esp
80101cef:	ff 75 f0             	pushl  -0x10(%ebp)
80101cf2:	e8 37 e5 ff ff       	call   8010022e <brelse>
80101cf7:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cfd:	eb 0d                	jmp    80101d0c <bmap+0x11a>
  }

  panic("bmap: out of range");
80101cff:	83 ec 0c             	sub    $0xc,%esp
80101d02:	68 3e 90 10 80       	push   $0x8010903e
80101d07:	e8 5a e8 ff ff       	call   80100566 <panic>
}
80101d0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d0f:	c9                   	leave  
80101d10:	c3                   	ret    

80101d11 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d11:	55                   	push   %ebp
80101d12:	89 e5                	mov    %esp,%ebp
80101d14:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d1e:	eb 45                	jmp    80101d65 <itrunc+0x54>
    if(ip->addrs[i]){
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d26:	83 c2 04             	add    $0x4,%edx
80101d29:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d2d:	85 c0                	test   %eax,%eax
80101d2f:	74 30                	je     80101d61 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d31:	8b 45 08             	mov    0x8(%ebp),%eax
80101d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d37:	83 c2 04             	add    $0x4,%edx
80101d3a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d3e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d41:	8b 12                	mov    (%edx),%edx
80101d43:	83 ec 08             	sub    $0x8,%esp
80101d46:	50                   	push   %eax
80101d47:	52                   	push   %edx
80101d48:	e8 18 f8 ff ff       	call   80101565 <bfree>
80101d4d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d56:	83 c2 04             	add    $0x4,%edx
80101d59:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d60:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d61:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d65:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d69:	7e b5                	jle    80101d20 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d71:	85 c0                	test   %eax,%eax
80101d73:	0f 84 a1 00 00 00    	je     80101e1a <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d79:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7c:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	8b 00                	mov    (%eax),%eax
80101d84:	83 ec 08             	sub    $0x8,%esp
80101d87:	52                   	push   %edx
80101d88:	50                   	push   %eax
80101d89:	e8 28 e4 ff ff       	call   801001b6 <bread>
80101d8e:	83 c4 10             	add    $0x10,%esp
80101d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d97:	83 c0 18             	add    $0x18,%eax
80101d9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d9d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101da4:	eb 3c                	jmp    80101de2 <itrunc+0xd1>
      if(a[j])
80101da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101db0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101db3:	01 d0                	add    %edx,%eax
80101db5:	8b 00                	mov    (%eax),%eax
80101db7:	85 c0                	test   %eax,%eax
80101db9:	74 23                	je     80101dde <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dc8:	01 d0                	add    %edx,%eax
80101dca:	8b 00                	mov    (%eax),%eax
80101dcc:	8b 55 08             	mov    0x8(%ebp),%edx
80101dcf:	8b 12                	mov    (%edx),%edx
80101dd1:	83 ec 08             	sub    $0x8,%esp
80101dd4:	50                   	push   %eax
80101dd5:	52                   	push   %edx
80101dd6:	e8 8a f7 ff ff       	call   80101565 <bfree>
80101ddb:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101dde:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de5:	83 f8 7f             	cmp    $0x7f,%eax
80101de8:	76 bc                	jbe    80101da6 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101dea:	83 ec 0c             	sub    $0xc,%esp
80101ded:	ff 75 ec             	pushl  -0x14(%ebp)
80101df0:	e8 39 e4 ff ff       	call   8010022e <brelse>
80101df5:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101df8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dfe:	8b 55 08             	mov    0x8(%ebp),%edx
80101e01:	8b 12                	mov    (%edx),%edx
80101e03:	83 ec 08             	sub    $0x8,%esp
80101e06:	50                   	push   %eax
80101e07:	52                   	push   %edx
80101e08:	e8 58 f7 ff ff       	call   80101565 <bfree>
80101e0d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e10:	8b 45 08             	mov    0x8(%ebp),%eax
80101e13:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e24:	83 ec 0c             	sub    $0xc,%esp
80101e27:	ff 75 08             	pushl  0x8(%ebp)
80101e2a:	e8 10 f9 ff ff       	call   8010173f <iupdate>
80101e2f:	83 c4 10             	add    $0x10,%esp
}
80101e32:	90                   	nop
80101e33:	c9                   	leave  
80101e34:	c3                   	ret    

80101e35 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e35:	55                   	push   %ebp
80101e36:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e38:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3b:	8b 00                	mov    (%eax),%eax
80101e3d:	89 c2                	mov    %eax,%edx
80101e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e42:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e45:	8b 45 08             	mov    0x8(%ebp),%eax
80101e48:	8b 50 04             	mov    0x4(%eax),%edx
80101e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e4e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e5b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e65:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e68:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6f:	8b 50 18             	mov    0x18(%eax),%edx
80101e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e75:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e78:	90                   	nop
80101e79:	5d                   	pop    %ebp
80101e7a:	c3                   	ret    

80101e7b <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e7b:	55                   	push   %ebp
80101e7c:	89 e5                	mov    %esp,%ebp
80101e7e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e81:	8b 45 08             	mov    0x8(%ebp),%eax
80101e84:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e88:	66 83 f8 03          	cmp    $0x3,%ax
80101e8c:	75 5c                	jne    80101eea <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e95:	66 85 c0             	test   %ax,%ax
80101e98:	78 20                	js     80101eba <readi+0x3f>
80101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ea1:	66 83 f8 09          	cmp    $0x9,%ax
80101ea5:	7f 13                	jg     80101eba <readi+0x3f>
80101ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eae:	98                   	cwtl   
80101eaf:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	75 0a                	jne    80101ec4 <readi+0x49>
      return -1;
80101eba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ebf:	e9 0c 01 00 00       	jmp    80101fd0 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ecb:	98                   	cwtl   
80101ecc:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101ed3:	8b 55 14             	mov    0x14(%ebp),%edx
80101ed6:	83 ec 04             	sub    $0x4,%esp
80101ed9:	52                   	push   %edx
80101eda:	ff 75 0c             	pushl  0xc(%ebp)
80101edd:	ff 75 08             	pushl  0x8(%ebp)
80101ee0:	ff d0                	call   *%eax
80101ee2:	83 c4 10             	add    $0x10,%esp
80101ee5:	e9 e6 00 00 00       	jmp    80101fd0 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	8b 40 18             	mov    0x18(%eax),%eax
80101ef0:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ef3:	72 0d                	jb     80101f02 <readi+0x87>
80101ef5:	8b 55 10             	mov    0x10(%ebp),%edx
80101ef8:	8b 45 14             	mov    0x14(%ebp),%eax
80101efb:	01 d0                	add    %edx,%eax
80101efd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f00:	73 0a                	jae    80101f0c <readi+0x91>
    return -1;
80101f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f07:	e9 c4 00 00 00       	jmp    80101fd0 <readi+0x155>
  if(off + n > ip->size)
80101f0c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f0f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f12:	01 c2                	add    %eax,%edx
80101f14:	8b 45 08             	mov    0x8(%ebp),%eax
80101f17:	8b 40 18             	mov    0x18(%eax),%eax
80101f1a:	39 c2                	cmp    %eax,%edx
80101f1c:	76 0c                	jbe    80101f2a <readi+0xaf>
    n = ip->size - off;
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	8b 40 18             	mov    0x18(%eax),%eax
80101f24:	2b 45 10             	sub    0x10(%ebp),%eax
80101f27:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f31:	e9 8b 00 00 00       	jmp    80101fc1 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f36:	8b 45 10             	mov    0x10(%ebp),%eax
80101f39:	c1 e8 09             	shr    $0x9,%eax
80101f3c:	83 ec 08             	sub    $0x8,%esp
80101f3f:	50                   	push   %eax
80101f40:	ff 75 08             	pushl  0x8(%ebp)
80101f43:	e8 aa fc ff ff       	call   80101bf2 <bmap>
80101f48:	83 c4 10             	add    $0x10,%esp
80101f4b:	89 c2                	mov    %eax,%edx
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 00                	mov    (%eax),%eax
80101f52:	83 ec 08             	sub    $0x8,%esp
80101f55:	52                   	push   %edx
80101f56:	50                   	push   %eax
80101f57:	e8 5a e2 ff ff       	call   801001b6 <bread>
80101f5c:	83 c4 10             	add    $0x10,%esp
80101f5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f62:	8b 45 10             	mov    0x10(%ebp),%eax
80101f65:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f6a:	ba 00 02 00 00       	mov    $0x200,%edx
80101f6f:	29 c2                	sub    %eax,%edx
80101f71:	8b 45 14             	mov    0x14(%ebp),%eax
80101f74:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f77:	39 c2                	cmp    %eax,%edx
80101f79:	0f 46 c2             	cmovbe %edx,%eax
80101f7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f82:	8d 50 18             	lea    0x18(%eax),%edx
80101f85:	8b 45 10             	mov    0x10(%ebp),%eax
80101f88:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f8d:	01 d0                	add    %edx,%eax
80101f8f:	83 ec 04             	sub    $0x4,%esp
80101f92:	ff 75 ec             	pushl  -0x14(%ebp)
80101f95:	50                   	push   %eax
80101f96:	ff 75 0c             	pushl  0xc(%ebp)
80101f99:	e8 5b 3b 00 00       	call   80105af9 <memmove>
80101f9e:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fa1:	83 ec 0c             	sub    $0xc,%esp
80101fa4:	ff 75 f0             	pushl  -0x10(%ebp)
80101fa7:	e8 82 e2 ff ff       	call   8010022e <brelse>
80101fac:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101faf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb2:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb8:	01 45 10             	add    %eax,0x10(%ebp)
80101fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fbe:	01 45 0c             	add    %eax,0xc(%ebp)
80101fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc4:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fc7:	0f 82 69 ff ff ff    	jb     80101f36 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fcd:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fd0:	c9                   	leave  
80101fd1:	c3                   	ret    

80101fd2 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fd2:	55                   	push   %ebp
80101fd3:	89 e5                	mov    %esp,%ebp
80101fd5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fdf:	66 83 f8 03          	cmp    $0x3,%ax
80101fe3:	75 5c                	jne    80102041 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fec:	66 85 c0             	test   %ax,%ax
80101fef:	78 20                	js     80102011 <writei+0x3f>
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ff8:	66 83 f8 09          	cmp    $0x9,%ax
80101ffc:	7f 13                	jg     80102011 <writei+0x3f>
80101ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80102001:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102005:	98                   	cwtl   
80102006:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
8010200d:	85 c0                	test   %eax,%eax
8010200f:	75 0a                	jne    8010201b <writei+0x49>
      return -1;
80102011:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102016:	e9 3d 01 00 00       	jmp    80102158 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010201b:	8b 45 08             	mov    0x8(%ebp),%eax
8010201e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102022:	98                   	cwtl   
80102023:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
8010202a:	8b 55 14             	mov    0x14(%ebp),%edx
8010202d:	83 ec 04             	sub    $0x4,%esp
80102030:	52                   	push   %edx
80102031:	ff 75 0c             	pushl  0xc(%ebp)
80102034:	ff 75 08             	pushl  0x8(%ebp)
80102037:	ff d0                	call   *%eax
80102039:	83 c4 10             	add    $0x10,%esp
8010203c:	e9 17 01 00 00       	jmp    80102158 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102041:	8b 45 08             	mov    0x8(%ebp),%eax
80102044:	8b 40 18             	mov    0x18(%eax),%eax
80102047:	3b 45 10             	cmp    0x10(%ebp),%eax
8010204a:	72 0d                	jb     80102059 <writei+0x87>
8010204c:	8b 55 10             	mov    0x10(%ebp),%edx
8010204f:	8b 45 14             	mov    0x14(%ebp),%eax
80102052:	01 d0                	add    %edx,%eax
80102054:	3b 45 10             	cmp    0x10(%ebp),%eax
80102057:	73 0a                	jae    80102063 <writei+0x91>
    return -1;
80102059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010205e:	e9 f5 00 00 00       	jmp    80102158 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102063:	8b 55 10             	mov    0x10(%ebp),%edx
80102066:	8b 45 14             	mov    0x14(%ebp),%eax
80102069:	01 d0                	add    %edx,%eax
8010206b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102070:	76 0a                	jbe    8010207c <writei+0xaa>
    return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 dc 00 00 00       	jmp    80102158 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010207c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102083:	e9 99 00 00 00       	jmp    80102121 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102088:	8b 45 10             	mov    0x10(%ebp),%eax
8010208b:	c1 e8 09             	shr    $0x9,%eax
8010208e:	83 ec 08             	sub    $0x8,%esp
80102091:	50                   	push   %eax
80102092:	ff 75 08             	pushl  0x8(%ebp)
80102095:	e8 58 fb ff ff       	call   80101bf2 <bmap>
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	89 c2                	mov    %eax,%edx
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 00                	mov    (%eax),%eax
801020a4:	83 ec 08             	sub    $0x8,%esp
801020a7:	52                   	push   %edx
801020a8:	50                   	push   %eax
801020a9:	e8 08 e1 ff ff       	call   801001b6 <bread>
801020ae:	83 c4 10             	add    $0x10,%esp
801020b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020b4:	8b 45 10             	mov    0x10(%ebp),%eax
801020b7:	25 ff 01 00 00       	and    $0x1ff,%eax
801020bc:	ba 00 02 00 00       	mov    $0x200,%edx
801020c1:	29 c2                	sub    %eax,%edx
801020c3:	8b 45 14             	mov    0x14(%ebp),%eax
801020c6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020c9:	39 c2                	cmp    %eax,%edx
801020cb:	0f 46 c2             	cmovbe %edx,%eax
801020ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	8d 50 18             	lea    0x18(%eax),%edx
801020d7:	8b 45 10             	mov    0x10(%ebp),%eax
801020da:	25 ff 01 00 00       	and    $0x1ff,%eax
801020df:	01 d0                	add    %edx,%eax
801020e1:	83 ec 04             	sub    $0x4,%esp
801020e4:	ff 75 ec             	pushl  -0x14(%ebp)
801020e7:	ff 75 0c             	pushl  0xc(%ebp)
801020ea:	50                   	push   %eax
801020eb:	e8 09 3a 00 00       	call   80105af9 <memmove>
801020f0:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020f3:	83 ec 0c             	sub    $0xc,%esp
801020f6:	ff 75 f0             	pushl  -0x10(%ebp)
801020f9:	e8 f6 15 00 00       	call   801036f4 <log_write>
801020fe:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102101:	83 ec 0c             	sub    $0xc,%esp
80102104:	ff 75 f0             	pushl  -0x10(%ebp)
80102107:	e8 22 e1 ff ff       	call   8010022e <brelse>
8010210c:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010210f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102112:	01 45 f4             	add    %eax,-0xc(%ebp)
80102115:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102118:	01 45 10             	add    %eax,0x10(%ebp)
8010211b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010211e:	01 45 0c             	add    %eax,0xc(%ebp)
80102121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102124:	3b 45 14             	cmp    0x14(%ebp),%eax
80102127:	0f 82 5b ff ff ff    	jb     80102088 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010212d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102131:	74 22                	je     80102155 <writei+0x183>
80102133:	8b 45 08             	mov    0x8(%ebp),%eax
80102136:	8b 40 18             	mov    0x18(%eax),%eax
80102139:	3b 45 10             	cmp    0x10(%ebp),%eax
8010213c:	73 17                	jae    80102155 <writei+0x183>
    ip->size = off;
8010213e:	8b 45 08             	mov    0x8(%ebp),%eax
80102141:	8b 55 10             	mov    0x10(%ebp),%edx
80102144:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102147:	83 ec 0c             	sub    $0xc,%esp
8010214a:	ff 75 08             	pushl  0x8(%ebp)
8010214d:	e8 ed f5 ff ff       	call   8010173f <iupdate>
80102152:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102155:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102158:	c9                   	leave  
80102159:	c3                   	ret    

8010215a <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010215a:	55                   	push   %ebp
8010215b:	89 e5                	mov    %esp,%ebp
8010215d:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102160:	83 ec 04             	sub    $0x4,%esp
80102163:	6a 0e                	push   $0xe
80102165:	ff 75 0c             	pushl  0xc(%ebp)
80102168:	ff 75 08             	pushl  0x8(%ebp)
8010216b:	e8 1f 3a 00 00       	call   80105b8f <strncmp>
80102170:	83 c4 10             	add    $0x10,%esp
}
80102173:	c9                   	leave  
80102174:	c3                   	ret    

80102175 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102175:	55                   	push   %ebp
80102176:	89 e5                	mov    %esp,%ebp
80102178:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010217b:	8b 45 08             	mov    0x8(%ebp),%eax
8010217e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102182:	66 83 f8 01          	cmp    $0x1,%ax
80102186:	74 0d                	je     80102195 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102188:	83 ec 0c             	sub    $0xc,%esp
8010218b:	68 51 90 10 80       	push   $0x80109051
80102190:	e8 d1 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010219c:	eb 7b                	jmp    80102219 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010219e:	6a 10                	push   $0x10
801021a0:	ff 75 f4             	pushl  -0xc(%ebp)
801021a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021a6:	50                   	push   %eax
801021a7:	ff 75 08             	pushl  0x8(%ebp)
801021aa:	e8 cc fc ff ff       	call   80101e7b <readi>
801021af:	83 c4 10             	add    $0x10,%esp
801021b2:	83 f8 10             	cmp    $0x10,%eax
801021b5:	74 0d                	je     801021c4 <dirlookup+0x4f>
      panic("dirlink read");
801021b7:	83 ec 0c             	sub    $0xc,%esp
801021ba:	68 63 90 10 80       	push   $0x80109063
801021bf:	e8 a2 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021c4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c8:	66 85 c0             	test   %ax,%ax
801021cb:	74 47                	je     80102214 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801021cd:	83 ec 08             	sub    $0x8,%esp
801021d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d3:	83 c0 02             	add    $0x2,%eax
801021d6:	50                   	push   %eax
801021d7:	ff 75 0c             	pushl  0xc(%ebp)
801021da:	e8 7b ff ff ff       	call   8010215a <namecmp>
801021df:	83 c4 10             	add    $0x10,%esp
801021e2:	85 c0                	test   %eax,%eax
801021e4:	75 2f                	jne    80102215 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801021e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021ea:	74 08                	je     801021f4 <dirlookup+0x7f>
        *poff = off;
801021ec:	8b 45 10             	mov    0x10(%ebp),%eax
801021ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021f2:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021f4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021f8:	0f b7 c0             	movzwl %ax,%eax
801021fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801021fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102201:	8b 00                	mov    (%eax),%eax
80102203:	83 ec 08             	sub    $0x8,%esp
80102206:	ff 75 f0             	pushl  -0x10(%ebp)
80102209:	50                   	push   %eax
8010220a:	e8 eb f5 ff ff       	call   801017fa <iget>
8010220f:	83 c4 10             	add    $0x10,%esp
80102212:	eb 19                	jmp    8010222d <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102214:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102215:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102219:	8b 45 08             	mov    0x8(%ebp),%eax
8010221c:	8b 40 18             	mov    0x18(%eax),%eax
8010221f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102222:	0f 87 76 ff ff ff    	ja     8010219e <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102228:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010222d:	c9                   	leave  
8010222e:	c3                   	ret    

8010222f <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010222f:	55                   	push   %ebp
80102230:	89 e5                	mov    %esp,%ebp
80102232:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102235:	83 ec 04             	sub    $0x4,%esp
80102238:	6a 00                	push   $0x0
8010223a:	ff 75 0c             	pushl  0xc(%ebp)
8010223d:	ff 75 08             	pushl  0x8(%ebp)
80102240:	e8 30 ff ff ff       	call   80102175 <dirlookup>
80102245:	83 c4 10             	add    $0x10,%esp
80102248:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010224b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010224f:	74 18                	je     80102269 <dirlink+0x3a>
    iput(ip);
80102251:	83 ec 0c             	sub    $0xc,%esp
80102254:	ff 75 f0             	pushl  -0x10(%ebp)
80102257:	e8 81 f8 ff ff       	call   80101add <iput>
8010225c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010225f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102264:	e9 9c 00 00 00       	jmp    80102305 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102270:	eb 39                	jmp    801022ab <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102275:	6a 10                	push   $0x10
80102277:	50                   	push   %eax
80102278:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010227b:	50                   	push   %eax
8010227c:	ff 75 08             	pushl  0x8(%ebp)
8010227f:	e8 f7 fb ff ff       	call   80101e7b <readi>
80102284:	83 c4 10             	add    $0x10,%esp
80102287:	83 f8 10             	cmp    $0x10,%eax
8010228a:	74 0d                	je     80102299 <dirlink+0x6a>
      panic("dirlink read");
8010228c:	83 ec 0c             	sub    $0xc,%esp
8010228f:	68 63 90 10 80       	push   $0x80109063
80102294:	e8 cd e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102299:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010229d:	66 85 c0             	test   %ax,%ax
801022a0:	74 18                	je     801022ba <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a5:	83 c0 10             	add    $0x10,%eax
801022a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ab:	8b 45 08             	mov    0x8(%ebp),%eax
801022ae:	8b 50 18             	mov    0x18(%eax),%edx
801022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b4:	39 c2                	cmp    %eax,%edx
801022b6:	77 ba                	ja     80102272 <dirlink+0x43>
801022b8:	eb 01                	jmp    801022bb <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022ba:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022bb:	83 ec 04             	sub    $0x4,%esp
801022be:	6a 0e                	push   $0xe
801022c0:	ff 75 0c             	pushl  0xc(%ebp)
801022c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c6:	83 c0 02             	add    $0x2,%eax
801022c9:	50                   	push   %eax
801022ca:	e8 16 39 00 00       	call   80105be5 <strncpy>
801022cf:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801022d2:	8b 45 10             	mov    0x10(%ebp),%eax
801022d5:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022dc:	6a 10                	push   $0x10
801022de:	50                   	push   %eax
801022df:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e2:	50                   	push   %eax
801022e3:	ff 75 08             	pushl  0x8(%ebp)
801022e6:	e8 e7 fc ff ff       	call   80101fd2 <writei>
801022eb:	83 c4 10             	add    $0x10,%esp
801022ee:	83 f8 10             	cmp    $0x10,%eax
801022f1:	74 0d                	je     80102300 <dirlink+0xd1>
    panic("dirlink");
801022f3:	83 ec 0c             	sub    $0xc,%esp
801022f6:	68 70 90 10 80       	push   $0x80109070
801022fb:	e8 66 e2 ff ff       	call   80100566 <panic>
  
  return 0;
80102300:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102305:	c9                   	leave  
80102306:	c3                   	ret    

80102307 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102307:	55                   	push   %ebp
80102308:	89 e5                	mov    %esp,%ebp
8010230a:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010230d:	eb 04                	jmp    80102313 <skipelem+0xc>
    path++;
8010230f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	0f b6 00             	movzbl (%eax),%eax
80102319:	3c 2f                	cmp    $0x2f,%al
8010231b:	74 f2                	je     8010230f <skipelem+0x8>
    path++;
  if(*path == 0)
8010231d:	8b 45 08             	mov    0x8(%ebp),%eax
80102320:	0f b6 00             	movzbl (%eax),%eax
80102323:	84 c0                	test   %al,%al
80102325:	75 07                	jne    8010232e <skipelem+0x27>
    return 0;
80102327:	b8 00 00 00 00       	mov    $0x0,%eax
8010232c:	eb 7b                	jmp    801023a9 <skipelem+0xa2>
  s = path;
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102334:	eb 04                	jmp    8010233a <skipelem+0x33>
    path++;
80102336:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010233a:	8b 45 08             	mov    0x8(%ebp),%eax
8010233d:	0f b6 00             	movzbl (%eax),%eax
80102340:	3c 2f                	cmp    $0x2f,%al
80102342:	74 0a                	je     8010234e <skipelem+0x47>
80102344:	8b 45 08             	mov    0x8(%ebp),%eax
80102347:	0f b6 00             	movzbl (%eax),%eax
8010234a:	84 c0                	test   %al,%al
8010234c:	75 e8                	jne    80102336 <skipelem+0x2f>
    path++;
  len = path - s;
8010234e:	8b 55 08             	mov    0x8(%ebp),%edx
80102351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102354:	29 c2                	sub    %eax,%edx
80102356:	89 d0                	mov    %edx,%eax
80102358:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010235b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010235f:	7e 15                	jle    80102376 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102361:	83 ec 04             	sub    $0x4,%esp
80102364:	6a 0e                	push   $0xe
80102366:	ff 75 f4             	pushl  -0xc(%ebp)
80102369:	ff 75 0c             	pushl  0xc(%ebp)
8010236c:	e8 88 37 00 00       	call   80105af9 <memmove>
80102371:	83 c4 10             	add    $0x10,%esp
80102374:	eb 26                	jmp    8010239c <skipelem+0x95>
  else {
    memmove(name, s, len);
80102376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102379:	83 ec 04             	sub    $0x4,%esp
8010237c:	50                   	push   %eax
8010237d:	ff 75 f4             	pushl  -0xc(%ebp)
80102380:	ff 75 0c             	pushl  0xc(%ebp)
80102383:	e8 71 37 00 00       	call   80105af9 <memmove>
80102388:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010238b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010238e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102391:	01 d0                	add    %edx,%eax
80102393:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102396:	eb 04                	jmp    8010239c <skipelem+0x95>
    path++;
80102398:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	0f b6 00             	movzbl (%eax),%eax
801023a2:	3c 2f                	cmp    $0x2f,%al
801023a4:	74 f2                	je     80102398 <skipelem+0x91>
    path++;
  return path;
801023a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023a9:	c9                   	leave  
801023aa:	c3                   	ret    

801023ab <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ab:	55                   	push   %ebp
801023ac:	89 e5                	mov    %esp,%ebp
801023ae:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023b1:	8b 45 08             	mov    0x8(%ebp),%eax
801023b4:	0f b6 00             	movzbl (%eax),%eax
801023b7:	3c 2f                	cmp    $0x2f,%al
801023b9:	75 17                	jne    801023d2 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023bb:	83 ec 08             	sub    $0x8,%esp
801023be:	6a 01                	push   $0x1
801023c0:	6a 01                	push   $0x1
801023c2:	e8 33 f4 ff ff       	call   801017fa <iget>
801023c7:	83 c4 10             	add    $0x10,%esp
801023ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023cd:	e9 bb 00 00 00       	jmp    8010248d <namex+0xe2>
  else
    ip = idup(proc->cwd);
801023d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023d8:	8b 40 68             	mov    0x68(%eax),%eax
801023db:	83 ec 0c             	sub    $0xc,%esp
801023de:	50                   	push   %eax
801023df:	e8 f5 f4 ff ff       	call   801018d9 <idup>
801023e4:	83 c4 10             	add    $0x10,%esp
801023e7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ea:	e9 9e 00 00 00       	jmp    8010248d <namex+0xe2>
    ilock(ip);
801023ef:	83 ec 0c             	sub    $0xc,%esp
801023f2:	ff 75 f4             	pushl  -0xc(%ebp)
801023f5:	e8 19 f5 ff ff       	call   80101913 <ilock>
801023fa:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801023fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102400:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102404:	66 83 f8 01          	cmp    $0x1,%ax
80102408:	74 18                	je     80102422 <namex+0x77>
      iunlockput(ip);
8010240a:	83 ec 0c             	sub    $0xc,%esp
8010240d:	ff 75 f4             	pushl  -0xc(%ebp)
80102410:	e8 b8 f7 ff ff       	call   80101bcd <iunlockput>
80102415:	83 c4 10             	add    $0x10,%esp
      return 0;
80102418:	b8 00 00 00 00       	mov    $0x0,%eax
8010241d:	e9 a7 00 00 00       	jmp    801024c9 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102422:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102426:	74 20                	je     80102448 <namex+0x9d>
80102428:	8b 45 08             	mov    0x8(%ebp),%eax
8010242b:	0f b6 00             	movzbl (%eax),%eax
8010242e:	84 c0                	test   %al,%al
80102430:	75 16                	jne    80102448 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102432:	83 ec 0c             	sub    $0xc,%esp
80102435:	ff 75 f4             	pushl  -0xc(%ebp)
80102438:	e8 2e f6 ff ff       	call   80101a6b <iunlock>
8010243d:	83 c4 10             	add    $0x10,%esp
      return ip;
80102440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102443:	e9 81 00 00 00       	jmp    801024c9 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102448:	83 ec 04             	sub    $0x4,%esp
8010244b:	6a 00                	push   $0x0
8010244d:	ff 75 10             	pushl  0x10(%ebp)
80102450:	ff 75 f4             	pushl  -0xc(%ebp)
80102453:	e8 1d fd ff ff       	call   80102175 <dirlookup>
80102458:	83 c4 10             	add    $0x10,%esp
8010245b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010245e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102462:	75 15                	jne    80102479 <namex+0xce>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	pushl  -0xc(%ebp)
8010246a:	e8 5e f7 ff ff       	call   80101bcd <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	eb 50                	jmp    801024c9 <namex+0x11e>
    }
    iunlockput(ip);
80102479:	83 ec 0c             	sub    $0xc,%esp
8010247c:	ff 75 f4             	pushl  -0xc(%ebp)
8010247f:	e8 49 f7 ff ff       	call   80101bcd <iunlockput>
80102484:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010248a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010248d:	83 ec 08             	sub    $0x8,%esp
80102490:	ff 75 10             	pushl  0x10(%ebp)
80102493:	ff 75 08             	pushl  0x8(%ebp)
80102496:	e8 6c fe ff ff       	call   80102307 <skipelem>
8010249b:	83 c4 10             	add    $0x10,%esp
8010249e:	89 45 08             	mov    %eax,0x8(%ebp)
801024a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024a5:	0f 85 44 ff ff ff    	jne    801023ef <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024af:	74 15                	je     801024c6 <namex+0x11b>
    iput(ip);
801024b1:	83 ec 0c             	sub    $0xc,%esp
801024b4:	ff 75 f4             	pushl  -0xc(%ebp)
801024b7:	e8 21 f6 ff ff       	call   80101add <iput>
801024bc:	83 c4 10             	add    $0x10,%esp
    return 0;
801024bf:	b8 00 00 00 00       	mov    $0x0,%eax
801024c4:	eb 03                	jmp    801024c9 <namex+0x11e>
  }
  return ip;
801024c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024c9:	c9                   	leave  
801024ca:	c3                   	ret    

801024cb <namei>:

struct inode*
namei(char *path)
{
801024cb:	55                   	push   %ebp
801024cc:	89 e5                	mov    %esp,%ebp
801024ce:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024d1:	83 ec 04             	sub    $0x4,%esp
801024d4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024d7:	50                   	push   %eax
801024d8:	6a 00                	push   $0x0
801024da:	ff 75 08             	pushl  0x8(%ebp)
801024dd:	e8 c9 fe ff ff       	call   801023ab <namex>
801024e2:	83 c4 10             	add    $0x10,%esp
}
801024e5:	c9                   	leave  
801024e6:	c3                   	ret    

801024e7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024e7:	55                   	push   %ebp
801024e8:	89 e5                	mov    %esp,%ebp
801024ea:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801024ed:	83 ec 04             	sub    $0x4,%esp
801024f0:	ff 75 0c             	pushl  0xc(%ebp)
801024f3:	6a 01                	push   $0x1
801024f5:	ff 75 08             	pushl  0x8(%ebp)
801024f8:	e8 ae fe ff ff       	call   801023ab <namex>
801024fd:	83 c4 10             	add    $0x10,%esp
}
80102500:	c9                   	leave  
80102501:	c3                   	ret    

80102502 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102502:	55                   	push   %ebp
80102503:	89 e5                	mov    %esp,%ebp
80102505:	83 ec 14             	sub    $0x14,%esp
80102508:	8b 45 08             	mov    0x8(%ebp),%eax
8010250b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010250f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102513:	89 c2                	mov    %eax,%edx
80102515:	ec                   	in     (%dx),%al
80102516:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102519:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010251d:	c9                   	leave  
8010251e:	c3                   	ret    

8010251f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010251f:	55                   	push   %ebp
80102520:	89 e5                	mov    %esp,%ebp
80102522:	57                   	push   %edi
80102523:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102524:	8b 55 08             	mov    0x8(%ebp),%edx
80102527:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010252a:	8b 45 10             	mov    0x10(%ebp),%eax
8010252d:	89 cb                	mov    %ecx,%ebx
8010252f:	89 df                	mov    %ebx,%edi
80102531:	89 c1                	mov    %eax,%ecx
80102533:	fc                   	cld    
80102534:	f3 6d                	rep insl (%dx),%es:(%edi)
80102536:	89 c8                	mov    %ecx,%eax
80102538:	89 fb                	mov    %edi,%ebx
8010253a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010253d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102540:	90                   	nop
80102541:	5b                   	pop    %ebx
80102542:	5f                   	pop    %edi
80102543:	5d                   	pop    %ebp
80102544:	c3                   	ret    

80102545 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102545:	55                   	push   %ebp
80102546:	89 e5                	mov    %esp,%ebp
80102548:	83 ec 08             	sub    $0x8,%esp
8010254b:	8b 55 08             	mov    0x8(%ebp),%edx
8010254e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102551:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102555:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102558:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010255c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102560:	ee                   	out    %al,(%dx)
}
80102561:	90                   	nop
80102562:	c9                   	leave  
80102563:	c3                   	ret    

80102564 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102564:	55                   	push   %ebp
80102565:	89 e5                	mov    %esp,%ebp
80102567:	56                   	push   %esi
80102568:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102569:	8b 55 08             	mov    0x8(%ebp),%edx
8010256c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010256f:	8b 45 10             	mov    0x10(%ebp),%eax
80102572:	89 cb                	mov    %ecx,%ebx
80102574:	89 de                	mov    %ebx,%esi
80102576:	89 c1                	mov    %eax,%ecx
80102578:	fc                   	cld    
80102579:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010257b:	89 c8                	mov    %ecx,%eax
8010257d:	89 f3                	mov    %esi,%ebx
8010257f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102582:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102585:	90                   	nop
80102586:	5b                   	pop    %ebx
80102587:	5e                   	pop    %esi
80102588:	5d                   	pop    %ebp
80102589:	c3                   	ret    

8010258a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010258a:	55                   	push   %ebp
8010258b:	89 e5                	mov    %esp,%ebp
8010258d:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102590:	90                   	nop
80102591:	68 f7 01 00 00       	push   $0x1f7
80102596:	e8 67 ff ff ff       	call   80102502 <inb>
8010259b:	83 c4 04             	add    $0x4,%esp
8010259e:	0f b6 c0             	movzbl %al,%eax
801025a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025a7:	25 c0 00 00 00       	and    $0xc0,%eax
801025ac:	83 f8 40             	cmp    $0x40,%eax
801025af:	75 e0                	jne    80102591 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025b5:	74 11                	je     801025c8 <idewait+0x3e>
801025b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025ba:	83 e0 21             	and    $0x21,%eax
801025bd:	85 c0                	test   %eax,%eax
801025bf:	74 07                	je     801025c8 <idewait+0x3e>
    return -1;
801025c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025c6:	eb 05                	jmp    801025cd <idewait+0x43>
  return 0;
801025c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025cd:	c9                   	leave  
801025ce:	c3                   	ret    

801025cf <ideinit>:

void
ideinit(void)
{
801025cf:	55                   	push   %ebp
801025d0:	89 e5                	mov    %esp,%ebp
801025d2:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801025d5:	83 ec 08             	sub    $0x8,%esp
801025d8:	68 78 90 10 80       	push   $0x80109078
801025dd:	68 20 c6 10 80       	push   $0x8010c620
801025e2:	e8 ce 31 00 00       	call   801057b5 <initlock>
801025e7:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801025ea:	83 ec 0c             	sub    $0xc,%esp
801025ed:	6a 0e                	push   $0xe
801025ef:	e8 b0 18 00 00       	call   80103ea4 <picenable>
801025f4:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801025f7:	a1 60 39 11 80       	mov    0x80113960,%eax
801025fc:	83 e8 01             	sub    $0x1,%eax
801025ff:	83 ec 08             	sub    $0x8,%esp
80102602:	50                   	push   %eax
80102603:	6a 0e                	push   $0xe
80102605:	e8 37 04 00 00       	call   80102a41 <ioapicenable>
8010260a:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010260d:	83 ec 0c             	sub    $0xc,%esp
80102610:	6a 00                	push   $0x0
80102612:	e8 73 ff ff ff       	call   8010258a <idewait>
80102617:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010261a:	83 ec 08             	sub    $0x8,%esp
8010261d:	68 f0 00 00 00       	push   $0xf0
80102622:	68 f6 01 00 00       	push   $0x1f6
80102627:	e8 19 ff ff ff       	call   80102545 <outb>
8010262c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010262f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102636:	eb 24                	jmp    8010265c <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102638:	83 ec 0c             	sub    $0xc,%esp
8010263b:	68 f7 01 00 00       	push   $0x1f7
80102640:	e8 bd fe ff ff       	call   80102502 <inb>
80102645:	83 c4 10             	add    $0x10,%esp
80102648:	84 c0                	test   %al,%al
8010264a:	74 0c                	je     80102658 <ideinit+0x89>
      havedisk1 = 1;
8010264c:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102653:	00 00 00 
      break;
80102656:	eb 0d                	jmp    80102665 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102658:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010265c:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102663:	7e d3                	jle    80102638 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102665:	83 ec 08             	sub    $0x8,%esp
80102668:	68 e0 00 00 00       	push   $0xe0
8010266d:	68 f6 01 00 00       	push   $0x1f6
80102672:	e8 ce fe ff ff       	call   80102545 <outb>
80102677:	83 c4 10             	add    $0x10,%esp
}
8010267a:	90                   	nop
8010267b:	c9                   	leave  
8010267c:	c3                   	ret    

8010267d <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010267d:	55                   	push   %ebp
8010267e:	89 e5                	mov    %esp,%ebp
80102680:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102683:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102687:	75 0d                	jne    80102696 <idestart+0x19>
    panic("idestart");
80102689:	83 ec 0c             	sub    $0xc,%esp
8010268c:	68 7c 90 10 80       	push   $0x8010907c
80102691:	e8 d0 de ff ff       	call   80100566 <panic>

  idewait(0);
80102696:	83 ec 0c             	sub    $0xc,%esp
80102699:	6a 00                	push   $0x0
8010269b:	e8 ea fe ff ff       	call   8010258a <idewait>
801026a0:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801026a3:	83 ec 08             	sub    $0x8,%esp
801026a6:	6a 00                	push   $0x0
801026a8:	68 f6 03 00 00       	push   $0x3f6
801026ad:	e8 93 fe ff ff       	call   80102545 <outb>
801026b2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801026b5:	83 ec 08             	sub    $0x8,%esp
801026b8:	6a 01                	push   $0x1
801026ba:	68 f2 01 00 00       	push   $0x1f2
801026bf:	e8 81 fe ff ff       	call   80102545 <outb>
801026c4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026c7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ca:	8b 40 08             	mov    0x8(%eax),%eax
801026cd:	0f b6 c0             	movzbl %al,%eax
801026d0:	83 ec 08             	sub    $0x8,%esp
801026d3:	50                   	push   %eax
801026d4:	68 f3 01 00 00       	push   $0x1f3
801026d9:	e8 67 fe ff ff       	call   80102545 <outb>
801026de:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026e1:	8b 45 08             	mov    0x8(%ebp),%eax
801026e4:	8b 40 08             	mov    0x8(%eax),%eax
801026e7:	c1 e8 08             	shr    $0x8,%eax
801026ea:	0f b6 c0             	movzbl %al,%eax
801026ed:	83 ec 08             	sub    $0x8,%esp
801026f0:	50                   	push   %eax
801026f1:	68 f4 01 00 00       	push   $0x1f4
801026f6:	e8 4a fe ff ff       	call   80102545 <outb>
801026fb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801026fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102701:	8b 40 08             	mov    0x8(%eax),%eax
80102704:	c1 e8 10             	shr    $0x10,%eax
80102707:	0f b6 c0             	movzbl %al,%eax
8010270a:	83 ec 08             	sub    $0x8,%esp
8010270d:	50                   	push   %eax
8010270e:	68 f5 01 00 00       	push   $0x1f5
80102713:	e8 2d fe ff ff       	call   80102545 <outb>
80102718:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
8010271b:	8b 45 08             	mov    0x8(%ebp),%eax
8010271e:	8b 40 04             	mov    0x4(%eax),%eax
80102721:	83 e0 01             	and    $0x1,%eax
80102724:	c1 e0 04             	shl    $0x4,%eax
80102727:	89 c2                	mov    %eax,%edx
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	8b 40 08             	mov    0x8(%eax),%eax
8010272f:	c1 e8 18             	shr    $0x18,%eax
80102732:	83 e0 0f             	and    $0xf,%eax
80102735:	09 d0                	or     %edx,%eax
80102737:	83 c8 e0             	or     $0xffffffe0,%eax
8010273a:	0f b6 c0             	movzbl %al,%eax
8010273d:	83 ec 08             	sub    $0x8,%esp
80102740:	50                   	push   %eax
80102741:	68 f6 01 00 00       	push   $0x1f6
80102746:	e8 fa fd ff ff       	call   80102545 <outb>
8010274b:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010274e:	8b 45 08             	mov    0x8(%ebp),%eax
80102751:	8b 00                	mov    (%eax),%eax
80102753:	83 e0 04             	and    $0x4,%eax
80102756:	85 c0                	test   %eax,%eax
80102758:	74 30                	je     8010278a <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010275a:	83 ec 08             	sub    $0x8,%esp
8010275d:	6a 30                	push   $0x30
8010275f:	68 f7 01 00 00       	push   $0x1f7
80102764:	e8 dc fd ff ff       	call   80102545 <outb>
80102769:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
8010276c:	8b 45 08             	mov    0x8(%ebp),%eax
8010276f:	83 c0 18             	add    $0x18,%eax
80102772:	83 ec 04             	sub    $0x4,%esp
80102775:	68 80 00 00 00       	push   $0x80
8010277a:	50                   	push   %eax
8010277b:	68 f0 01 00 00       	push   $0x1f0
80102780:	e8 df fd ff ff       	call   80102564 <outsl>
80102785:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102788:	eb 12                	jmp    8010279c <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010278a:	83 ec 08             	sub    $0x8,%esp
8010278d:	6a 20                	push   $0x20
8010278f:	68 f7 01 00 00       	push   $0x1f7
80102794:	e8 ac fd ff ff       	call   80102545 <outb>
80102799:	83 c4 10             	add    $0x10,%esp
  }
}
8010279c:	90                   	nop
8010279d:	c9                   	leave  
8010279e:	c3                   	ret    

8010279f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010279f:	55                   	push   %ebp
801027a0:	89 e5                	mov    %esp,%ebp
801027a2:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027a5:	83 ec 0c             	sub    $0xc,%esp
801027a8:	68 20 c6 10 80       	push   $0x8010c620
801027ad:	e8 25 30 00 00       	call   801057d7 <acquire>
801027b2:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801027b5:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c1:	75 15                	jne    801027d8 <ideintr+0x39>
    release(&idelock);
801027c3:	83 ec 0c             	sub    $0xc,%esp
801027c6:	68 20 c6 10 80       	push   $0x8010c620
801027cb:	e8 6e 30 00 00       	call   8010583e <release>
801027d0:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801027d3:	e9 9a 00 00 00       	jmp    80102872 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801027d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027db:	8b 40 14             	mov    0x14(%eax),%eax
801027de:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e6:	8b 00                	mov    (%eax),%eax
801027e8:	83 e0 04             	and    $0x4,%eax
801027eb:	85 c0                	test   %eax,%eax
801027ed:	75 2d                	jne    8010281c <ideintr+0x7d>
801027ef:	83 ec 0c             	sub    $0xc,%esp
801027f2:	6a 01                	push   $0x1
801027f4:	e8 91 fd ff ff       	call   8010258a <idewait>
801027f9:	83 c4 10             	add    $0x10,%esp
801027fc:	85 c0                	test   %eax,%eax
801027fe:	78 1c                	js     8010281c <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
80102800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102803:	83 c0 18             	add    $0x18,%eax
80102806:	83 ec 04             	sub    $0x4,%esp
80102809:	68 80 00 00 00       	push   $0x80
8010280e:	50                   	push   %eax
8010280f:	68 f0 01 00 00       	push   $0x1f0
80102814:	e8 06 fd ff ff       	call   8010251f <insl>
80102819:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010281c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281f:	8b 00                	mov    (%eax),%eax
80102821:	83 c8 02             	or     $0x2,%eax
80102824:	89 c2                	mov    %eax,%edx
80102826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102829:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010282b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282e:	8b 00                	mov    (%eax),%eax
80102830:	83 e0 fb             	and    $0xfffffffb,%eax
80102833:	89 c2                	mov    %eax,%edx
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	ff 75 f4             	pushl  -0xc(%ebp)
80102840:	e8 e2 28 00 00       	call   80105127 <wakeup>
80102845:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102848:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010284d:	85 c0                	test   %eax,%eax
8010284f:	74 11                	je     80102862 <ideintr+0xc3>
    idestart(idequeue);
80102851:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102856:	83 ec 0c             	sub    $0xc,%esp
80102859:	50                   	push   %eax
8010285a:	e8 1e fe ff ff       	call   8010267d <idestart>
8010285f:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102862:	83 ec 0c             	sub    $0xc,%esp
80102865:	68 20 c6 10 80       	push   $0x8010c620
8010286a:	e8 cf 2f 00 00       	call   8010583e <release>
8010286f:	83 c4 10             	add    $0x10,%esp
}
80102872:	c9                   	leave  
80102873:	c3                   	ret    

80102874 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102874:	55                   	push   %ebp
80102875:	89 e5                	mov    %esp,%ebp
80102877:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010287a:	8b 45 08             	mov    0x8(%ebp),%eax
8010287d:	8b 00                	mov    (%eax),%eax
8010287f:	83 e0 01             	and    $0x1,%eax
80102882:	85 c0                	test   %eax,%eax
80102884:	75 0d                	jne    80102893 <iderw+0x1f>
    panic("iderw: buf not busy");
80102886:	83 ec 0c             	sub    $0xc,%esp
80102889:	68 85 90 10 80       	push   $0x80109085
8010288e:	e8 d3 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102893:	8b 45 08             	mov    0x8(%ebp),%eax
80102896:	8b 00                	mov    (%eax),%eax
80102898:	83 e0 06             	and    $0x6,%eax
8010289b:	83 f8 02             	cmp    $0x2,%eax
8010289e:	75 0d                	jne    801028ad <iderw+0x39>
    panic("iderw: nothing to do");
801028a0:	83 ec 0c             	sub    $0xc,%esp
801028a3:	68 99 90 10 80       	push   $0x80109099
801028a8:	e8 b9 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801028ad:	8b 45 08             	mov    0x8(%ebp),%eax
801028b0:	8b 40 04             	mov    0x4(%eax),%eax
801028b3:	85 c0                	test   %eax,%eax
801028b5:	74 16                	je     801028cd <iderw+0x59>
801028b7:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801028bc:	85 c0                	test   %eax,%eax
801028be:	75 0d                	jne    801028cd <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028c0:	83 ec 0c             	sub    $0xc,%esp
801028c3:	68 ae 90 10 80       	push   $0x801090ae
801028c8:	e8 99 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028cd:	83 ec 0c             	sub    $0xc,%esp
801028d0:	68 20 c6 10 80       	push   $0x8010c620
801028d5:	e8 fd 2e 00 00       	call   801057d7 <acquire>
801028da:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801028dd:	8b 45 08             	mov    0x8(%ebp),%eax
801028e0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028e7:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
801028ee:	eb 0b                	jmp    801028fb <iderw+0x87>
801028f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f3:	8b 00                	mov    (%eax),%eax
801028f5:	83 c0 14             	add    $0x14,%eax
801028f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028fe:	8b 00                	mov    (%eax),%eax
80102900:	85 c0                	test   %eax,%eax
80102902:	75 ec                	jne    801028f0 <iderw+0x7c>
    ;
  *pp = b;
80102904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102907:	8b 55 08             	mov    0x8(%ebp),%edx
8010290a:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010290c:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102911:	3b 45 08             	cmp    0x8(%ebp),%eax
80102914:	75 23                	jne    80102939 <iderw+0xc5>
    idestart(b);
80102916:	83 ec 0c             	sub    $0xc,%esp
80102919:	ff 75 08             	pushl  0x8(%ebp)
8010291c:	e8 5c fd ff ff       	call   8010267d <idestart>
80102921:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102924:	eb 13                	jmp    80102939 <iderw+0xc5>
    sleep(b, &idelock);
80102926:	83 ec 08             	sub    $0x8,%esp
80102929:	68 20 c6 10 80       	push   $0x8010c620
8010292e:	ff 75 08             	pushl  0x8(%ebp)
80102931:	e8 e5 26 00 00       	call   8010501b <sleep>
80102936:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102939:	8b 45 08             	mov    0x8(%ebp),%eax
8010293c:	8b 00                	mov    (%eax),%eax
8010293e:	83 e0 06             	and    $0x6,%eax
80102941:	83 f8 02             	cmp    $0x2,%eax
80102944:	75 e0                	jne    80102926 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102946:	83 ec 0c             	sub    $0xc,%esp
80102949:	68 20 c6 10 80       	push   $0x8010c620
8010294e:	e8 eb 2e 00 00       	call   8010583e <release>
80102953:	83 c4 10             	add    $0x10,%esp
}
80102956:	90                   	nop
80102957:	c9                   	leave  
80102958:	c3                   	ret    

80102959 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102959:	55                   	push   %ebp
8010295a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010295c:	a1 34 32 11 80       	mov    0x80113234,%eax
80102961:	8b 55 08             	mov    0x8(%ebp),%edx
80102964:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102966:	a1 34 32 11 80       	mov    0x80113234,%eax
8010296b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010296e:	5d                   	pop    %ebp
8010296f:	c3                   	ret    

80102970 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102970:	55                   	push   %ebp
80102971:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102973:	a1 34 32 11 80       	mov    0x80113234,%eax
80102978:	8b 55 08             	mov    0x8(%ebp),%edx
8010297b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010297d:	a1 34 32 11 80       	mov    0x80113234,%eax
80102982:	8b 55 0c             	mov    0xc(%ebp),%edx
80102985:	89 50 10             	mov    %edx,0x10(%eax)
}
80102988:	90                   	nop
80102989:	5d                   	pop    %ebp
8010298a:	c3                   	ret    

8010298b <ioapicinit>:

void
ioapicinit(void)
{
8010298b:	55                   	push   %ebp
8010298c:	89 e5                	mov    %esp,%ebp
8010298e:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102991:	a1 64 33 11 80       	mov    0x80113364,%eax
80102996:	85 c0                	test   %eax,%eax
80102998:	0f 84 a0 00 00 00    	je     80102a3e <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010299e:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
801029a5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029a8:	6a 01                	push   $0x1
801029aa:	e8 aa ff ff ff       	call   80102959 <ioapicread>
801029af:	83 c4 04             	add    $0x4,%esp
801029b2:	c1 e8 10             	shr    $0x10,%eax
801029b5:	25 ff 00 00 00       	and    $0xff,%eax
801029ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029bd:	6a 00                	push   $0x0
801029bf:	e8 95 ff ff ff       	call   80102959 <ioapicread>
801029c4:	83 c4 04             	add    $0x4,%esp
801029c7:	c1 e8 18             	shr    $0x18,%eax
801029ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029cd:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
801029d4:	0f b6 c0             	movzbl %al,%eax
801029d7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029da:	74 10                	je     801029ec <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029dc:	83 ec 0c             	sub    $0xc,%esp
801029df:	68 cc 90 10 80       	push   $0x801090cc
801029e4:	e8 dd d9 ff ff       	call   801003c6 <cprintf>
801029e9:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029f3:	eb 3f                	jmp    80102a34 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f8:	83 c0 20             	add    $0x20,%eax
801029fb:	0d 00 00 01 00       	or     $0x10000,%eax
80102a00:	89 c2                	mov    %eax,%edx
80102a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a05:	83 c0 08             	add    $0x8,%eax
80102a08:	01 c0                	add    %eax,%eax
80102a0a:	83 ec 08             	sub    $0x8,%esp
80102a0d:	52                   	push   %edx
80102a0e:	50                   	push   %eax
80102a0f:	e8 5c ff ff ff       	call   80102970 <ioapicwrite>
80102a14:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1a:	83 c0 08             	add    $0x8,%eax
80102a1d:	01 c0                	add    %eax,%eax
80102a1f:	83 c0 01             	add    $0x1,%eax
80102a22:	83 ec 08             	sub    $0x8,%esp
80102a25:	6a 00                	push   $0x0
80102a27:	50                   	push   %eax
80102a28:	e8 43 ff ff ff       	call   80102970 <ioapicwrite>
80102a2d:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a37:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a3a:	7e b9                	jle    801029f5 <ioapicinit+0x6a>
80102a3c:	eb 01                	jmp    80102a3f <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a3e:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a3f:	c9                   	leave  
80102a40:	c3                   	ret    

80102a41 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a41:	55                   	push   %ebp
80102a42:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a44:	a1 64 33 11 80       	mov    0x80113364,%eax
80102a49:	85 c0                	test   %eax,%eax
80102a4b:	74 39                	je     80102a86 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a50:	83 c0 20             	add    $0x20,%eax
80102a53:	89 c2                	mov    %eax,%edx
80102a55:	8b 45 08             	mov    0x8(%ebp),%eax
80102a58:	83 c0 08             	add    $0x8,%eax
80102a5b:	01 c0                	add    %eax,%eax
80102a5d:	52                   	push   %edx
80102a5e:	50                   	push   %eax
80102a5f:	e8 0c ff ff ff       	call   80102970 <ioapicwrite>
80102a64:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a6a:	c1 e0 18             	shl    $0x18,%eax
80102a6d:	89 c2                	mov    %eax,%edx
80102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a72:	83 c0 08             	add    $0x8,%eax
80102a75:	01 c0                	add    %eax,%eax
80102a77:	83 c0 01             	add    $0x1,%eax
80102a7a:	52                   	push   %edx
80102a7b:	50                   	push   %eax
80102a7c:	e8 ef fe ff ff       	call   80102970 <ioapicwrite>
80102a81:	83 c4 08             	add    $0x8,%esp
80102a84:	eb 01                	jmp    80102a87 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a86:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a87:	c9                   	leave  
80102a88:	c3                   	ret    

80102a89 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a89:	55                   	push   %ebp
80102a8a:	89 e5                	mov    %esp,%ebp
80102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8f:	05 00 00 00 80       	add    $0x80000000,%eax
80102a94:	5d                   	pop    %ebp
80102a95:	c3                   	ret    

80102a96 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a96:	55                   	push   %ebp
80102a97:	89 e5                	mov    %esp,%ebp
80102a99:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102a9c:	83 ec 08             	sub    $0x8,%esp
80102a9f:	68 fe 90 10 80       	push   $0x801090fe
80102aa4:	68 40 32 11 80       	push   $0x80113240
80102aa9:	e8 07 2d 00 00       	call   801057b5 <initlock>
80102aae:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ab1:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102ab8:	00 00 00 
  freerange(vstart, vend);
80102abb:	83 ec 08             	sub    $0x8,%esp
80102abe:	ff 75 0c             	pushl  0xc(%ebp)
80102ac1:	ff 75 08             	pushl  0x8(%ebp)
80102ac4:	e8 2a 00 00 00       	call   80102af3 <freerange>
80102ac9:	83 c4 10             	add    $0x10,%esp
}
80102acc:	90                   	nop
80102acd:	c9                   	leave  
80102ace:	c3                   	ret    

80102acf <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102acf:	55                   	push   %ebp
80102ad0:	89 e5                	mov    %esp,%ebp
80102ad2:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102ad5:	83 ec 08             	sub    $0x8,%esp
80102ad8:	ff 75 0c             	pushl  0xc(%ebp)
80102adb:	ff 75 08             	pushl  0x8(%ebp)
80102ade:	e8 10 00 00 00       	call   80102af3 <freerange>
80102ae3:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ae6:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102aed:	00 00 00 
}
80102af0:	90                   	nop
80102af1:	c9                   	leave  
80102af2:	c3                   	ret    

80102af3 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102af3:	55                   	push   %ebp
80102af4:	89 e5                	mov    %esp,%ebp
80102af6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102af9:	8b 45 08             	mov    0x8(%ebp),%eax
80102afc:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b09:	eb 15                	jmp    80102b20 <freerange+0x2d>
    kfree(p);
80102b0b:	83 ec 0c             	sub    $0xc,%esp
80102b0e:	ff 75 f4             	pushl  -0xc(%ebp)
80102b11:	e8 1a 00 00 00       	call   80102b30 <kfree>
80102b16:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b19:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b23:	05 00 10 00 00       	add    $0x1000,%eax
80102b28:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b2b:	76 de                	jbe    80102b0b <freerange+0x18>
    kfree(p);
}
80102b2d:	90                   	nop
80102b2e:	c9                   	leave  
80102b2f:	c3                   	ret    

80102b30 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b30:	55                   	push   %ebp
80102b31:	89 e5                	mov    %esp,%ebp
80102b33:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b36:	8b 45 08             	mov    0x8(%ebp),%eax
80102b39:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b3e:	85 c0                	test   %eax,%eax
80102b40:	75 1b                	jne    80102b5d <kfree+0x2d>
80102b42:	81 7d 08 bc 6d 11 80 	cmpl   $0x80116dbc,0x8(%ebp)
80102b49:	72 12                	jb     80102b5d <kfree+0x2d>
80102b4b:	ff 75 08             	pushl  0x8(%ebp)
80102b4e:	e8 36 ff ff ff       	call   80102a89 <v2p>
80102b53:	83 c4 04             	add    $0x4,%esp
80102b56:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b5b:	76 0d                	jbe    80102b6a <kfree+0x3a>
    panic("kfree");
80102b5d:	83 ec 0c             	sub    $0xc,%esp
80102b60:	68 03 91 10 80       	push   $0x80109103
80102b65:	e8 fc d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b6a:	83 ec 04             	sub    $0x4,%esp
80102b6d:	68 00 10 00 00       	push   $0x1000
80102b72:	6a 01                	push   $0x1
80102b74:	ff 75 08             	pushl  0x8(%ebp)
80102b77:	e8 be 2e 00 00       	call   80105a3a <memset>
80102b7c:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b7f:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b84:	85 c0                	test   %eax,%eax
80102b86:	74 10                	je     80102b98 <kfree+0x68>
    acquire(&kmem.lock);
80102b88:	83 ec 0c             	sub    $0xc,%esp
80102b8b:	68 40 32 11 80       	push   $0x80113240
80102b90:	e8 42 2c 00 00       	call   801057d7 <acquire>
80102b95:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102b98:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b9e:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba7:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bac:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102bb1:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bb6:	85 c0                	test   %eax,%eax
80102bb8:	74 10                	je     80102bca <kfree+0x9a>
    release(&kmem.lock);
80102bba:	83 ec 0c             	sub    $0xc,%esp
80102bbd:	68 40 32 11 80       	push   $0x80113240
80102bc2:	e8 77 2c 00 00       	call   8010583e <release>
80102bc7:	83 c4 10             	add    $0x10,%esp
}
80102bca:	90                   	nop
80102bcb:	c9                   	leave  
80102bcc:	c3                   	ret    

80102bcd <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102bcd:	55                   	push   %ebp
80102bce:	89 e5                	mov    %esp,%ebp
80102bd0:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102bd3:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bd8:	85 c0                	test   %eax,%eax
80102bda:	74 10                	je     80102bec <kalloc+0x1f>
    acquire(&kmem.lock);
80102bdc:	83 ec 0c             	sub    $0xc,%esp
80102bdf:	68 40 32 11 80       	push   $0x80113240
80102be4:	e8 ee 2b 00 00       	call   801057d7 <acquire>
80102be9:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102bec:	a1 78 32 11 80       	mov    0x80113278,%eax
80102bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bf8:	74 0a                	je     80102c04 <kalloc+0x37>
    kmem.freelist = r->next;
80102bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bfd:	8b 00                	mov    (%eax),%eax
80102bff:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c04:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c09:	85 c0                	test   %eax,%eax
80102c0b:	74 10                	je     80102c1d <kalloc+0x50>
    release(&kmem.lock);
80102c0d:	83 ec 0c             	sub    $0xc,%esp
80102c10:	68 40 32 11 80       	push   $0x80113240
80102c15:	e8 24 2c 00 00       	call   8010583e <release>
80102c1a:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c20:	c9                   	leave  
80102c21:	c3                   	ret    

80102c22 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c22:	55                   	push   %ebp
80102c23:	89 e5                	mov    %esp,%ebp
80102c25:	83 ec 14             	sub    $0x14,%esp
80102c28:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c2f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c33:	89 c2                	mov    %eax,%edx
80102c35:	ec                   	in     (%dx),%al
80102c36:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c39:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c3d:	c9                   	leave  
80102c3e:	c3                   	ret    

80102c3f <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c3f:	55                   	push   %ebp
80102c40:	89 e5                	mov    %esp,%ebp
80102c42:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c45:	6a 64                	push   $0x64
80102c47:	e8 d6 ff ff ff       	call   80102c22 <inb>
80102c4c:	83 c4 04             	add    $0x4,%esp
80102c4f:	0f b6 c0             	movzbl %al,%eax
80102c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c58:	83 e0 01             	and    $0x1,%eax
80102c5b:	85 c0                	test   %eax,%eax
80102c5d:	75 0a                	jne    80102c69 <kbdgetc+0x2a>
    return -1;
80102c5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c64:	e9 23 01 00 00       	jmp    80102d8c <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c69:	6a 60                	push   $0x60
80102c6b:	e8 b2 ff ff ff       	call   80102c22 <inb>
80102c70:	83 c4 04             	add    $0x4,%esp
80102c73:	0f b6 c0             	movzbl %al,%eax
80102c76:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c79:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c80:	75 17                	jne    80102c99 <kbdgetc+0x5a>
    shift |= E0ESC;
80102c82:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c87:	83 c8 40             	or     $0x40,%eax
80102c8a:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102c8f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c94:	e9 f3 00 00 00       	jmp    80102d8c <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c9c:	25 80 00 00 00       	and    $0x80,%eax
80102ca1:	85 c0                	test   %eax,%eax
80102ca3:	74 45                	je     80102cea <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ca5:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102caa:	83 e0 40             	and    $0x40,%eax
80102cad:	85 c0                	test   %eax,%eax
80102caf:	75 08                	jne    80102cb9 <kbdgetc+0x7a>
80102cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb4:	83 e0 7f             	and    $0x7f,%eax
80102cb7:	eb 03                	jmp    80102cbc <kbdgetc+0x7d>
80102cb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102cbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cc2:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102cc7:	0f b6 00             	movzbl (%eax),%eax
80102cca:	83 c8 40             	or     $0x40,%eax
80102ccd:	0f b6 c0             	movzbl %al,%eax
80102cd0:	f7 d0                	not    %eax
80102cd2:	89 c2                	mov    %eax,%edx
80102cd4:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cd9:	21 d0                	and    %edx,%eax
80102cdb:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102ce0:	b8 00 00 00 00       	mov    $0x0,%eax
80102ce5:	e9 a2 00 00 00       	jmp    80102d8c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102cea:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cef:	83 e0 40             	and    $0x40,%eax
80102cf2:	85 c0                	test   %eax,%eax
80102cf4:	74 14                	je     80102d0a <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cf6:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cfd:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d02:	83 e0 bf             	and    $0xffffffbf,%eax
80102d05:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102d0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0d:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d12:	0f b6 00             	movzbl (%eax),%eax
80102d15:	0f b6 d0             	movzbl %al,%edx
80102d18:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d1d:	09 d0                	or     %edx,%eax
80102d1f:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102d24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d27:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102d2c:	0f b6 00             	movzbl (%eax),%eax
80102d2f:	0f b6 d0             	movzbl %al,%edx
80102d32:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d37:	31 d0                	xor    %edx,%eax
80102d39:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d3e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d43:	83 e0 03             	and    $0x3,%eax
80102d46:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102d4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d50:	01 d0                	add    %edx,%eax
80102d52:	0f b6 00             	movzbl (%eax),%eax
80102d55:	0f b6 c0             	movzbl %al,%eax
80102d58:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d5b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d60:	83 e0 08             	and    $0x8,%eax
80102d63:	85 c0                	test   %eax,%eax
80102d65:	74 22                	je     80102d89 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d67:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d6b:	76 0c                	jbe    80102d79 <kbdgetc+0x13a>
80102d6d:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d71:	77 06                	ja     80102d79 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d73:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d77:	eb 10                	jmp    80102d89 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d79:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d7d:	76 0a                	jbe    80102d89 <kbdgetc+0x14a>
80102d7f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d83:	77 04                	ja     80102d89 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d85:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d89:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d8c:	c9                   	leave  
80102d8d:	c3                   	ret    

80102d8e <kbdintr>:

void
kbdintr(void)
{
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102d94:	83 ec 0c             	sub    $0xc,%esp
80102d97:	68 3f 2c 10 80       	push   $0x80102c3f
80102d9c:	e8 3c da ff ff       	call   801007dd <consoleintr>
80102da1:	83 c4 10             	add    $0x10,%esp
}
80102da4:	90                   	nop
80102da5:	c9                   	leave  
80102da6:	c3                   	ret    

80102da7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102da7:	55                   	push   %ebp
80102da8:	89 e5                	mov    %esp,%ebp
80102daa:	83 ec 14             	sub    $0x14,%esp
80102dad:	8b 45 08             	mov    0x8(%ebp),%eax
80102db0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102db4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102db8:	89 c2                	mov    %eax,%edx
80102dba:	ec                   	in     (%dx),%al
80102dbb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dbe:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dc2:	c9                   	leave  
80102dc3:	c3                   	ret    

80102dc4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102dc4:	55                   	push   %ebp
80102dc5:	89 e5                	mov    %esp,%ebp
80102dc7:	83 ec 08             	sub    $0x8,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dd0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102dd4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dd7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ddb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ddf:	ee                   	out    %al,(%dx)
}
80102de0:	90                   	nop
80102de1:	c9                   	leave  
80102de2:	c3                   	ret    

80102de3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102de3:	55                   	push   %ebp
80102de4:	89 e5                	mov    %esp,%ebp
80102de6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102de9:	9c                   	pushf  
80102dea:	58                   	pop    %eax
80102deb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102df1:	c9                   	leave  
80102df2:	c3                   	ret    

80102df3 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102df3:	55                   	push   %ebp
80102df4:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102df6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102dfb:	8b 55 08             	mov    0x8(%ebp),%edx
80102dfe:	c1 e2 02             	shl    $0x2,%edx
80102e01:	01 c2                	add    %eax,%edx
80102e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e06:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e08:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e0d:	83 c0 20             	add    $0x20,%eax
80102e10:	8b 00                	mov    (%eax),%eax
}
80102e12:	90                   	nop
80102e13:	5d                   	pop    %ebp
80102e14:	c3                   	ret    

80102e15 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e15:	55                   	push   %ebp
80102e16:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e18:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e1d:	85 c0                	test   %eax,%eax
80102e1f:	0f 84 0b 01 00 00    	je     80102f30 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e25:	68 3f 01 00 00       	push   $0x13f
80102e2a:	6a 3c                	push   $0x3c
80102e2c:	e8 c2 ff ff ff       	call   80102df3 <lapicw>
80102e31:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e34:	6a 0b                	push   $0xb
80102e36:	68 f8 00 00 00       	push   $0xf8
80102e3b:	e8 b3 ff ff ff       	call   80102df3 <lapicw>
80102e40:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e43:	68 20 00 02 00       	push   $0x20020
80102e48:	68 c8 00 00 00       	push   $0xc8
80102e4d:	e8 a1 ff ff ff       	call   80102df3 <lapicw>
80102e52:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e55:	68 80 96 98 00       	push   $0x989680
80102e5a:	68 e0 00 00 00       	push   $0xe0
80102e5f:	e8 8f ff ff ff       	call   80102df3 <lapicw>
80102e64:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e67:	68 00 00 01 00       	push   $0x10000
80102e6c:	68 d4 00 00 00       	push   $0xd4
80102e71:	e8 7d ff ff ff       	call   80102df3 <lapicw>
80102e76:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e79:	68 00 00 01 00       	push   $0x10000
80102e7e:	68 d8 00 00 00       	push   $0xd8
80102e83:	e8 6b ff ff ff       	call   80102df3 <lapicw>
80102e88:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e8b:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e90:	83 c0 30             	add    $0x30,%eax
80102e93:	8b 00                	mov    (%eax),%eax
80102e95:	c1 e8 10             	shr    $0x10,%eax
80102e98:	0f b6 c0             	movzbl %al,%eax
80102e9b:	83 f8 03             	cmp    $0x3,%eax
80102e9e:	76 12                	jbe    80102eb2 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102ea0:	68 00 00 01 00       	push   $0x10000
80102ea5:	68 d0 00 00 00       	push   $0xd0
80102eaa:	e8 44 ff ff ff       	call   80102df3 <lapicw>
80102eaf:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102eb2:	6a 33                	push   $0x33
80102eb4:	68 dc 00 00 00       	push   $0xdc
80102eb9:	e8 35 ff ff ff       	call   80102df3 <lapicw>
80102ebe:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ec1:	6a 00                	push   $0x0
80102ec3:	68 a0 00 00 00       	push   $0xa0
80102ec8:	e8 26 ff ff ff       	call   80102df3 <lapicw>
80102ecd:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102ed0:	6a 00                	push   $0x0
80102ed2:	68 a0 00 00 00       	push   $0xa0
80102ed7:	e8 17 ff ff ff       	call   80102df3 <lapicw>
80102edc:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102edf:	6a 00                	push   $0x0
80102ee1:	6a 2c                	push   $0x2c
80102ee3:	e8 0b ff ff ff       	call   80102df3 <lapicw>
80102ee8:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102eeb:	6a 00                	push   $0x0
80102eed:	68 c4 00 00 00       	push   $0xc4
80102ef2:	e8 fc fe ff ff       	call   80102df3 <lapicw>
80102ef7:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102efa:	68 00 85 08 00       	push   $0x88500
80102eff:	68 c0 00 00 00       	push   $0xc0
80102f04:	e8 ea fe ff ff       	call   80102df3 <lapicw>
80102f09:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f0c:	90                   	nop
80102f0d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f12:	05 00 03 00 00       	add    $0x300,%eax
80102f17:	8b 00                	mov    (%eax),%eax
80102f19:	25 00 10 00 00       	and    $0x1000,%eax
80102f1e:	85 c0                	test   %eax,%eax
80102f20:	75 eb                	jne    80102f0d <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f22:	6a 00                	push   $0x0
80102f24:	6a 20                	push   $0x20
80102f26:	e8 c8 fe ff ff       	call   80102df3 <lapicw>
80102f2b:	83 c4 08             	add    $0x8,%esp
80102f2e:	eb 01                	jmp    80102f31 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f30:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f31:	c9                   	leave  
80102f32:	c3                   	ret    

80102f33 <cpunum>:

int
cpunum(void)
{
80102f33:	55                   	push   %ebp
80102f34:	89 e5                	mov    %esp,%ebp
80102f36:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f39:	e8 a5 fe ff ff       	call   80102de3 <readeflags>
80102f3e:	25 00 02 00 00       	and    $0x200,%eax
80102f43:	85 c0                	test   %eax,%eax
80102f45:	74 26                	je     80102f6d <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f47:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102f4c:	8d 50 01             	lea    0x1(%eax),%edx
80102f4f:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102f55:	85 c0                	test   %eax,%eax
80102f57:	75 14                	jne    80102f6d <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f59:	8b 45 04             	mov    0x4(%ebp),%eax
80102f5c:	83 ec 08             	sub    $0x8,%esp
80102f5f:	50                   	push   %eax
80102f60:	68 0c 91 10 80       	push   $0x8010910c
80102f65:	e8 5c d4 ff ff       	call   801003c6 <cprintf>
80102f6a:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f6d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f72:	85 c0                	test   %eax,%eax
80102f74:	74 0f                	je     80102f85 <cpunum+0x52>
    return lapic[ID]>>24;
80102f76:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f7b:	83 c0 20             	add    $0x20,%eax
80102f7e:	8b 00                	mov    (%eax),%eax
80102f80:	c1 e8 18             	shr    $0x18,%eax
80102f83:	eb 05                	jmp    80102f8a <cpunum+0x57>
  return 0;
80102f85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f8a:	c9                   	leave  
80102f8b:	c3                   	ret    

80102f8c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f8c:	55                   	push   %ebp
80102f8d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102f8f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f94:	85 c0                	test   %eax,%eax
80102f96:	74 0c                	je     80102fa4 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102f98:	6a 00                	push   $0x0
80102f9a:	6a 2c                	push   $0x2c
80102f9c:	e8 52 fe ff ff       	call   80102df3 <lapicw>
80102fa1:	83 c4 08             	add    $0x8,%esp
}
80102fa4:	90                   	nop
80102fa5:	c9                   	leave  
80102fa6:	c3                   	ret    

80102fa7 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fa7:	55                   	push   %ebp
80102fa8:	89 e5                	mov    %esp,%ebp
}
80102faa:	90                   	nop
80102fab:	5d                   	pop    %ebp
80102fac:	c3                   	ret    

80102fad <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fad:	55                   	push   %ebp
80102fae:	89 e5                	mov    %esp,%ebp
80102fb0:	83 ec 14             	sub    $0x14,%esp
80102fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb6:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fb9:	6a 0f                	push   $0xf
80102fbb:	6a 70                	push   $0x70
80102fbd:	e8 02 fe ff ff       	call   80102dc4 <outb>
80102fc2:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102fc5:	6a 0a                	push   $0xa
80102fc7:	6a 71                	push   $0x71
80102fc9:	e8 f6 fd ff ff       	call   80102dc4 <outb>
80102fce:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fd1:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fdb:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fe0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fe3:	83 c0 02             	add    $0x2,%eax
80102fe6:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fe9:	c1 ea 04             	shr    $0x4,%edx
80102fec:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102ff3:	c1 e0 18             	shl    $0x18,%eax
80102ff6:	50                   	push   %eax
80102ff7:	68 c4 00 00 00       	push   $0xc4
80102ffc:	e8 f2 fd ff ff       	call   80102df3 <lapicw>
80103001:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103004:	68 00 c5 00 00       	push   $0xc500
80103009:	68 c0 00 00 00       	push   $0xc0
8010300e:	e8 e0 fd ff ff       	call   80102df3 <lapicw>
80103013:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103016:	68 c8 00 00 00       	push   $0xc8
8010301b:	e8 87 ff ff ff       	call   80102fa7 <microdelay>
80103020:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103023:	68 00 85 00 00       	push   $0x8500
80103028:	68 c0 00 00 00       	push   $0xc0
8010302d:	e8 c1 fd ff ff       	call   80102df3 <lapicw>
80103032:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103035:	6a 64                	push   $0x64
80103037:	e8 6b ff ff ff       	call   80102fa7 <microdelay>
8010303c:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010303f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103046:	eb 3d                	jmp    80103085 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103048:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010304c:	c1 e0 18             	shl    $0x18,%eax
8010304f:	50                   	push   %eax
80103050:	68 c4 00 00 00       	push   $0xc4
80103055:	e8 99 fd ff ff       	call   80102df3 <lapicw>
8010305a:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010305d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103060:	c1 e8 0c             	shr    $0xc,%eax
80103063:	80 cc 06             	or     $0x6,%ah
80103066:	50                   	push   %eax
80103067:	68 c0 00 00 00       	push   $0xc0
8010306c:	e8 82 fd ff ff       	call   80102df3 <lapicw>
80103071:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103074:	68 c8 00 00 00       	push   $0xc8
80103079:	e8 29 ff ff ff       	call   80102fa7 <microdelay>
8010307e:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103081:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103085:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103089:	7e bd                	jle    80103048 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010308b:	90                   	nop
8010308c:	c9                   	leave  
8010308d:	c3                   	ret    

8010308e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010308e:	55                   	push   %ebp
8010308f:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103091:	8b 45 08             	mov    0x8(%ebp),%eax
80103094:	0f b6 c0             	movzbl %al,%eax
80103097:	50                   	push   %eax
80103098:	6a 70                	push   $0x70
8010309a:	e8 25 fd ff ff       	call   80102dc4 <outb>
8010309f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030a2:	68 c8 00 00 00       	push   $0xc8
801030a7:	e8 fb fe ff ff       	call   80102fa7 <microdelay>
801030ac:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801030af:	6a 71                	push   $0x71
801030b1:	e8 f1 fc ff ff       	call   80102da7 <inb>
801030b6:	83 c4 04             	add    $0x4,%esp
801030b9:	0f b6 c0             	movzbl %al,%eax
}
801030bc:	c9                   	leave  
801030bd:	c3                   	ret    

801030be <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030be:	55                   	push   %ebp
801030bf:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801030c1:	6a 00                	push   $0x0
801030c3:	e8 c6 ff ff ff       	call   8010308e <cmos_read>
801030c8:	83 c4 04             	add    $0x4,%esp
801030cb:	89 c2                	mov    %eax,%edx
801030cd:	8b 45 08             	mov    0x8(%ebp),%eax
801030d0:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801030d2:	6a 02                	push   $0x2
801030d4:	e8 b5 ff ff ff       	call   8010308e <cmos_read>
801030d9:	83 c4 04             	add    $0x4,%esp
801030dc:	89 c2                	mov    %eax,%edx
801030de:	8b 45 08             	mov    0x8(%ebp),%eax
801030e1:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801030e4:	6a 04                	push   $0x4
801030e6:	e8 a3 ff ff ff       	call   8010308e <cmos_read>
801030eb:	83 c4 04             	add    $0x4,%esp
801030ee:	89 c2                	mov    %eax,%edx
801030f0:	8b 45 08             	mov    0x8(%ebp),%eax
801030f3:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801030f6:	6a 07                	push   $0x7
801030f8:	e8 91 ff ff ff       	call   8010308e <cmos_read>
801030fd:	83 c4 04             	add    $0x4,%esp
80103100:	89 c2                	mov    %eax,%edx
80103102:	8b 45 08             	mov    0x8(%ebp),%eax
80103105:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103108:	6a 08                	push   $0x8
8010310a:	e8 7f ff ff ff       	call   8010308e <cmos_read>
8010310f:	83 c4 04             	add    $0x4,%esp
80103112:	89 c2                	mov    %eax,%edx
80103114:	8b 45 08             	mov    0x8(%ebp),%eax
80103117:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
8010311a:	6a 09                	push   $0x9
8010311c:	e8 6d ff ff ff       	call   8010308e <cmos_read>
80103121:	83 c4 04             	add    $0x4,%esp
80103124:	89 c2                	mov    %eax,%edx
80103126:	8b 45 08             	mov    0x8(%ebp),%eax
80103129:	89 50 14             	mov    %edx,0x14(%eax)
}
8010312c:	90                   	nop
8010312d:	c9                   	leave  
8010312e:	c3                   	ret    

8010312f <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010312f:	55                   	push   %ebp
80103130:	89 e5                	mov    %esp,%ebp
80103132:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103135:	6a 0b                	push   $0xb
80103137:	e8 52 ff ff ff       	call   8010308e <cmos_read>
8010313c:	83 c4 04             	add    $0x4,%esp
8010313f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103145:	83 e0 04             	and    $0x4,%eax
80103148:	85 c0                	test   %eax,%eax
8010314a:	0f 94 c0             	sete   %al
8010314d:	0f b6 c0             	movzbl %al,%eax
80103150:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103153:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103156:	50                   	push   %eax
80103157:	e8 62 ff ff ff       	call   801030be <fill_rtcdate>
8010315c:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010315f:	6a 0a                	push   $0xa
80103161:	e8 28 ff ff ff       	call   8010308e <cmos_read>
80103166:	83 c4 04             	add    $0x4,%esp
80103169:	25 80 00 00 00       	and    $0x80,%eax
8010316e:	85 c0                	test   %eax,%eax
80103170:	75 27                	jne    80103199 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103172:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103175:	50                   	push   %eax
80103176:	e8 43 ff ff ff       	call   801030be <fill_rtcdate>
8010317b:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010317e:	83 ec 04             	sub    $0x4,%esp
80103181:	6a 18                	push   $0x18
80103183:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103186:	50                   	push   %eax
80103187:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010318a:	50                   	push   %eax
8010318b:	e8 11 29 00 00       	call   80105aa1 <memcmp>
80103190:	83 c4 10             	add    $0x10,%esp
80103193:	85 c0                	test   %eax,%eax
80103195:	74 05                	je     8010319c <cmostime+0x6d>
80103197:	eb ba                	jmp    80103153 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103199:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010319a:	eb b7                	jmp    80103153 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
8010319c:	90                   	nop
  }

  // convert
  if (bcd) {
8010319d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031a1:	0f 84 b4 00 00 00    	je     8010325b <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031aa:	c1 e8 04             	shr    $0x4,%eax
801031ad:	89 c2                	mov    %eax,%edx
801031af:	89 d0                	mov    %edx,%eax
801031b1:	c1 e0 02             	shl    $0x2,%eax
801031b4:	01 d0                	add    %edx,%eax
801031b6:	01 c0                	add    %eax,%eax
801031b8:	89 c2                	mov    %eax,%edx
801031ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031bd:	83 e0 0f             	and    $0xf,%eax
801031c0:	01 d0                	add    %edx,%eax
801031c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031c8:	c1 e8 04             	shr    $0x4,%eax
801031cb:	89 c2                	mov    %eax,%edx
801031cd:	89 d0                	mov    %edx,%eax
801031cf:	c1 e0 02             	shl    $0x2,%eax
801031d2:	01 d0                	add    %edx,%eax
801031d4:	01 c0                	add    %eax,%eax
801031d6:	89 c2                	mov    %eax,%edx
801031d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031db:	83 e0 0f             	and    $0xf,%eax
801031de:	01 d0                	add    %edx,%eax
801031e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031e6:	c1 e8 04             	shr    $0x4,%eax
801031e9:	89 c2                	mov    %eax,%edx
801031eb:	89 d0                	mov    %edx,%eax
801031ed:	c1 e0 02             	shl    $0x2,%eax
801031f0:	01 d0                	add    %edx,%eax
801031f2:	01 c0                	add    %eax,%eax
801031f4:	89 c2                	mov    %eax,%edx
801031f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031f9:	83 e0 0f             	and    $0xf,%eax
801031fc:	01 d0                	add    %edx,%eax
801031fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103204:	c1 e8 04             	shr    $0x4,%eax
80103207:	89 c2                	mov    %eax,%edx
80103209:	89 d0                	mov    %edx,%eax
8010320b:	c1 e0 02             	shl    $0x2,%eax
8010320e:	01 d0                	add    %edx,%eax
80103210:	01 c0                	add    %eax,%eax
80103212:	89 c2                	mov    %eax,%edx
80103214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103217:	83 e0 0f             	and    $0xf,%eax
8010321a:	01 d0                	add    %edx,%eax
8010321c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010321f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103222:	c1 e8 04             	shr    $0x4,%eax
80103225:	89 c2                	mov    %eax,%edx
80103227:	89 d0                	mov    %edx,%eax
80103229:	c1 e0 02             	shl    $0x2,%eax
8010322c:	01 d0                	add    %edx,%eax
8010322e:	01 c0                	add    %eax,%eax
80103230:	89 c2                	mov    %eax,%edx
80103232:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103235:	83 e0 0f             	and    $0xf,%eax
80103238:	01 d0                	add    %edx,%eax
8010323a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010323d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103240:	c1 e8 04             	shr    $0x4,%eax
80103243:	89 c2                	mov    %eax,%edx
80103245:	89 d0                	mov    %edx,%eax
80103247:	c1 e0 02             	shl    $0x2,%eax
8010324a:	01 d0                	add    %edx,%eax
8010324c:	01 c0                	add    %eax,%eax
8010324e:	89 c2                	mov    %eax,%edx
80103250:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103253:	83 e0 0f             	and    $0xf,%eax
80103256:	01 d0                	add    %edx,%eax
80103258:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010325b:	8b 45 08             	mov    0x8(%ebp),%eax
8010325e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103261:	89 10                	mov    %edx,(%eax)
80103263:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103266:	89 50 04             	mov    %edx,0x4(%eax)
80103269:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010326c:	89 50 08             	mov    %edx,0x8(%eax)
8010326f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103272:	89 50 0c             	mov    %edx,0xc(%eax)
80103275:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103278:	89 50 10             	mov    %edx,0x10(%eax)
8010327b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010327e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103281:	8b 45 08             	mov    0x8(%ebp),%eax
80103284:	8b 40 14             	mov    0x14(%eax),%eax
80103287:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010328d:	8b 45 08             	mov    0x8(%ebp),%eax
80103290:	89 50 14             	mov    %edx,0x14(%eax)
}
80103293:	90                   	nop
80103294:	c9                   	leave  
80103295:	c3                   	ret    

80103296 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103296:	55                   	push   %ebp
80103297:	89 e5                	mov    %esp,%ebp
80103299:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010329c:	83 ec 08             	sub    $0x8,%esp
8010329f:	68 38 91 10 80       	push   $0x80109138
801032a4:	68 80 32 11 80       	push   $0x80113280
801032a9:	e8 07 25 00 00       	call   801057b5 <initlock>
801032ae:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
801032b1:	83 ec 08             	sub    $0x8,%esp
801032b4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032b7:	50                   	push   %eax
801032b8:	6a 01                	push   $0x1
801032ba:	e8 b2 e0 ff ff       	call   80101371 <readsb>
801032bf:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
801032c2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c8:	29 c2                	sub    %eax,%edx
801032ca:	89 d0                	mov    %edx,%eax
801032cc:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
801032d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d4:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
801032d9:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
801032e0:	00 00 00 
  recover_from_log();
801032e3:	e8 b2 01 00 00       	call   8010349a <recover_from_log>
}
801032e8:	90                   	nop
801032e9:	c9                   	leave  
801032ea:	c3                   	ret    

801032eb <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032eb:	55                   	push   %ebp
801032ec:	89 e5                	mov    %esp,%ebp
801032ee:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032f8:	e9 95 00 00 00       	jmp    80103392 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032fd:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103306:	01 d0                	add    %edx,%eax
80103308:	83 c0 01             	add    $0x1,%eax
8010330b:	89 c2                	mov    %eax,%edx
8010330d:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103312:	83 ec 08             	sub    $0x8,%esp
80103315:	52                   	push   %edx
80103316:	50                   	push   %eax
80103317:	e8 9a ce ff ff       	call   801001b6 <bread>
8010331c:	83 c4 10             	add    $0x10,%esp
8010331f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103325:	83 c0 10             	add    $0x10,%eax
80103328:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010332f:	89 c2                	mov    %eax,%edx
80103331:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103336:	83 ec 08             	sub    $0x8,%esp
80103339:	52                   	push   %edx
8010333a:	50                   	push   %eax
8010333b:	e8 76 ce ff ff       	call   801001b6 <bread>
80103340:	83 c4 10             	add    $0x10,%esp
80103343:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103349:	8d 50 18             	lea    0x18(%eax),%edx
8010334c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010334f:	83 c0 18             	add    $0x18,%eax
80103352:	83 ec 04             	sub    $0x4,%esp
80103355:	68 00 02 00 00       	push   $0x200
8010335a:	52                   	push   %edx
8010335b:	50                   	push   %eax
8010335c:	e8 98 27 00 00       	call   80105af9 <memmove>
80103361:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103364:	83 ec 0c             	sub    $0xc,%esp
80103367:	ff 75 ec             	pushl  -0x14(%ebp)
8010336a:	e8 80 ce ff ff       	call   801001ef <bwrite>
8010336f:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103372:	83 ec 0c             	sub    $0xc,%esp
80103375:	ff 75 f0             	pushl  -0x10(%ebp)
80103378:	e8 b1 ce ff ff       	call   8010022e <brelse>
8010337d:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103380:	83 ec 0c             	sub    $0xc,%esp
80103383:	ff 75 ec             	pushl  -0x14(%ebp)
80103386:	e8 a3 ce ff ff       	call   8010022e <brelse>
8010338b:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010338e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103392:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103397:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010339a:	0f 8f 5d ff ff ff    	jg     801032fd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033a0:	90                   	nop
801033a1:	c9                   	leave  
801033a2:	c3                   	ret    

801033a3 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033a3:	55                   	push   %ebp
801033a4:	89 e5                	mov    %esp,%ebp
801033a6:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033a9:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801033ae:	89 c2                	mov    %eax,%edx
801033b0:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033b5:	83 ec 08             	sub    $0x8,%esp
801033b8:	52                   	push   %edx
801033b9:	50                   	push   %eax
801033ba:	e8 f7 cd ff ff       	call   801001b6 <bread>
801033bf:	83 c4 10             	add    $0x10,%esp
801033c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c8:	83 c0 18             	add    $0x18,%eax
801033cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d1:	8b 00                	mov    (%eax),%eax
801033d3:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
801033d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033df:	eb 1b                	jmp    801033fc <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801033e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033e7:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033ee:	83 c2 10             	add    $0x10,%edx
801033f1:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033fc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103401:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103404:	7f db                	jg     801033e1 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103406:	83 ec 0c             	sub    $0xc,%esp
80103409:	ff 75 f0             	pushl  -0x10(%ebp)
8010340c:	e8 1d ce ff ff       	call   8010022e <brelse>
80103411:	83 c4 10             	add    $0x10,%esp
}
80103414:	90                   	nop
80103415:	c9                   	leave  
80103416:	c3                   	ret    

80103417 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103417:	55                   	push   %ebp
80103418:	89 e5                	mov    %esp,%ebp
8010341a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341d:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103422:	89 c2                	mov    %eax,%edx
80103424:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103429:	83 ec 08             	sub    $0x8,%esp
8010342c:	52                   	push   %edx
8010342d:	50                   	push   %eax
8010342e:	e8 83 cd ff ff       	call   801001b6 <bread>
80103433:	83 c4 10             	add    $0x10,%esp
80103436:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343c:	83 c0 18             	add    $0x18,%eax
8010343f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103442:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
80103448:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010344d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103454:	eb 1b                	jmp    80103471 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103459:	83 c0 10             	add    $0x10,%eax
8010345c:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
80103463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103466:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103469:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010346d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103471:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103476:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103479:	7f db                	jg     80103456 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010347b:	83 ec 0c             	sub    $0xc,%esp
8010347e:	ff 75 f0             	pushl  -0x10(%ebp)
80103481:	e8 69 cd ff ff       	call   801001ef <bwrite>
80103486:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103489:	83 ec 0c             	sub    $0xc,%esp
8010348c:	ff 75 f0             	pushl  -0x10(%ebp)
8010348f:	e8 9a cd ff ff       	call   8010022e <brelse>
80103494:	83 c4 10             	add    $0x10,%esp
}
80103497:	90                   	nop
80103498:	c9                   	leave  
80103499:	c3                   	ret    

8010349a <recover_from_log>:

static void
recover_from_log(void)
{
8010349a:	55                   	push   %ebp
8010349b:	89 e5                	mov    %esp,%ebp
8010349d:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034a0:	e8 fe fe ff ff       	call   801033a3 <read_head>
  install_trans(); // if committed, copy from log to disk
801034a5:	e8 41 fe ff ff       	call   801032eb <install_trans>
  log.lh.n = 0;
801034aa:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801034b1:	00 00 00 
  write_head(); // clear the log
801034b4:	e8 5e ff ff ff       	call   80103417 <write_head>
}
801034b9:	90                   	nop
801034ba:	c9                   	leave  
801034bb:	c3                   	ret    

801034bc <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801034c2:	83 ec 0c             	sub    $0xc,%esp
801034c5:	68 80 32 11 80       	push   $0x80113280
801034ca:	e8 08 23 00 00       	call   801057d7 <acquire>
801034cf:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801034d2:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034d7:	85 c0                	test   %eax,%eax
801034d9:	74 17                	je     801034f2 <begin_op+0x36>
      sleep(&log, &log.lock);
801034db:	83 ec 08             	sub    $0x8,%esp
801034de:	68 80 32 11 80       	push   $0x80113280
801034e3:	68 80 32 11 80       	push   $0x80113280
801034e8:	e8 2e 1b 00 00       	call   8010501b <sleep>
801034ed:	83 c4 10             	add    $0x10,%esp
801034f0:	eb e0                	jmp    801034d2 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034f2:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
801034f8:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034fd:	8d 50 01             	lea    0x1(%eax),%edx
80103500:	89 d0                	mov    %edx,%eax
80103502:	c1 e0 02             	shl    $0x2,%eax
80103505:	01 d0                	add    %edx,%eax
80103507:	01 c0                	add    %eax,%eax
80103509:	01 c8                	add    %ecx,%eax
8010350b:	83 f8 1e             	cmp    $0x1e,%eax
8010350e:	7e 17                	jle    80103527 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103510:	83 ec 08             	sub    $0x8,%esp
80103513:	68 80 32 11 80       	push   $0x80113280
80103518:	68 80 32 11 80       	push   $0x80113280
8010351d:	e8 f9 1a 00 00       	call   8010501b <sleep>
80103522:	83 c4 10             	add    $0x10,%esp
80103525:	eb ab                	jmp    801034d2 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103527:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010352c:	83 c0 01             	add    $0x1,%eax
8010352f:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103534:	83 ec 0c             	sub    $0xc,%esp
80103537:	68 80 32 11 80       	push   $0x80113280
8010353c:	e8 fd 22 00 00       	call   8010583e <release>
80103541:	83 c4 10             	add    $0x10,%esp
      break;
80103544:	90                   	nop
    }
  }
}
80103545:	90                   	nop
80103546:	c9                   	leave  
80103547:	c3                   	ret    

80103548 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103548:	55                   	push   %ebp
80103549:	89 e5                	mov    %esp,%ebp
8010354b:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010354e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103555:	83 ec 0c             	sub    $0xc,%esp
80103558:	68 80 32 11 80       	push   $0x80113280
8010355d:	e8 75 22 00 00       	call   801057d7 <acquire>
80103562:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103565:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010356a:	83 e8 01             	sub    $0x1,%eax
8010356d:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103572:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103577:	85 c0                	test   %eax,%eax
80103579:	74 0d                	je     80103588 <end_op+0x40>
    panic("log.committing");
8010357b:	83 ec 0c             	sub    $0xc,%esp
8010357e:	68 3c 91 10 80       	push   $0x8010913c
80103583:	e8 de cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103588:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010358d:	85 c0                	test   %eax,%eax
8010358f:	75 13                	jne    801035a4 <end_op+0x5c>
    do_commit = 1;
80103591:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103598:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
8010359f:	00 00 00 
801035a2:	eb 10                	jmp    801035b4 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801035a4:	83 ec 0c             	sub    $0xc,%esp
801035a7:	68 80 32 11 80       	push   $0x80113280
801035ac:	e8 76 1b 00 00       	call   80105127 <wakeup>
801035b1:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801035b4:	83 ec 0c             	sub    $0xc,%esp
801035b7:	68 80 32 11 80       	push   $0x80113280
801035bc:	e8 7d 22 00 00       	call   8010583e <release>
801035c1:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801035c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c8:	74 3f                	je     80103609 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035ca:	e8 f5 00 00 00       	call   801036c4 <commit>
    acquire(&log.lock);
801035cf:	83 ec 0c             	sub    $0xc,%esp
801035d2:	68 80 32 11 80       	push   $0x80113280
801035d7:	e8 fb 21 00 00       	call   801057d7 <acquire>
801035dc:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801035df:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
801035e6:	00 00 00 
    wakeup(&log);
801035e9:	83 ec 0c             	sub    $0xc,%esp
801035ec:	68 80 32 11 80       	push   $0x80113280
801035f1:	e8 31 1b 00 00       	call   80105127 <wakeup>
801035f6:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801035f9:	83 ec 0c             	sub    $0xc,%esp
801035fc:	68 80 32 11 80       	push   $0x80113280
80103601:	e8 38 22 00 00       	call   8010583e <release>
80103606:	83 c4 10             	add    $0x10,%esp
  }
}
80103609:	90                   	nop
8010360a:	c9                   	leave  
8010360b:	c3                   	ret    

8010360c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010360c:	55                   	push   %ebp
8010360d:	89 e5                	mov    %esp,%ebp
8010360f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103619:	e9 95 00 00 00       	jmp    801036b3 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010361e:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103627:	01 d0                	add    %edx,%eax
80103629:	83 c0 01             	add    $0x1,%eax
8010362c:	89 c2                	mov    %eax,%edx
8010362e:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103633:	83 ec 08             	sub    $0x8,%esp
80103636:	52                   	push   %edx
80103637:	50                   	push   %eax
80103638:	e8 79 cb ff ff       	call   801001b6 <bread>
8010363d:	83 c4 10             	add    $0x10,%esp
80103640:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103646:	83 c0 10             	add    $0x10,%eax
80103649:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103650:	89 c2                	mov    %eax,%edx
80103652:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103657:	83 ec 08             	sub    $0x8,%esp
8010365a:	52                   	push   %edx
8010365b:	50                   	push   %eax
8010365c:	e8 55 cb ff ff       	call   801001b6 <bread>
80103661:	83 c4 10             	add    $0x10,%esp
80103664:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103667:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010366a:	8d 50 18             	lea    0x18(%eax),%edx
8010366d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103670:	83 c0 18             	add    $0x18,%eax
80103673:	83 ec 04             	sub    $0x4,%esp
80103676:	68 00 02 00 00       	push   $0x200
8010367b:	52                   	push   %edx
8010367c:	50                   	push   %eax
8010367d:	e8 77 24 00 00       	call   80105af9 <memmove>
80103682:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103685:	83 ec 0c             	sub    $0xc,%esp
80103688:	ff 75 f0             	pushl  -0x10(%ebp)
8010368b:	e8 5f cb ff ff       	call   801001ef <bwrite>
80103690:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	ff 75 ec             	pushl  -0x14(%ebp)
80103699:	e8 90 cb ff ff       	call   8010022e <brelse>
8010369e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801036a1:	83 ec 0c             	sub    $0xc,%esp
801036a4:	ff 75 f0             	pushl  -0x10(%ebp)
801036a7:	e8 82 cb ff ff       	call   8010022e <brelse>
801036ac:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036b3:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036b8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036bb:	0f 8f 5d ff ff ff    	jg     8010361e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801036c1:	90                   	nop
801036c2:	c9                   	leave  
801036c3:	c3                   	ret    

801036c4 <commit>:

static void
commit()
{
801036c4:	55                   	push   %ebp
801036c5:	89 e5                	mov    %esp,%ebp
801036c7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801036ca:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036cf:	85 c0                	test   %eax,%eax
801036d1:	7e 1e                	jle    801036f1 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036d3:	e8 34 ff ff ff       	call   8010360c <write_log>
    write_head();    // Write header to disk -- the real commit
801036d8:	e8 3a fd ff ff       	call   80103417 <write_head>
    install_trans(); // Now install writes to home locations
801036dd:	e8 09 fc ff ff       	call   801032eb <install_trans>
    log.lh.n = 0; 
801036e2:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801036e9:	00 00 00 
    write_head();    // Erase the transaction from the log
801036ec:	e8 26 fd ff ff       	call   80103417 <write_head>
  }
}
801036f1:	90                   	nop
801036f2:	c9                   	leave  
801036f3:	c3                   	ret    

801036f4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036f4:	55                   	push   %ebp
801036f5:	89 e5                	mov    %esp,%ebp
801036f7:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036fa:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036ff:	83 f8 1d             	cmp    $0x1d,%eax
80103702:	7f 12                	jg     80103716 <log_write+0x22>
80103704:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103709:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
8010370f:	83 ea 01             	sub    $0x1,%edx
80103712:	39 d0                	cmp    %edx,%eax
80103714:	7c 0d                	jl     80103723 <log_write+0x2f>
    panic("too big a transaction");
80103716:	83 ec 0c             	sub    $0xc,%esp
80103719:	68 4b 91 10 80       	push   $0x8010914b
8010371e:	e8 43 ce ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103723:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103728:	85 c0                	test   %eax,%eax
8010372a:	7f 0d                	jg     80103739 <log_write+0x45>
    panic("log_write outside of trans");
8010372c:	83 ec 0c             	sub    $0xc,%esp
8010372f:	68 61 91 10 80       	push   $0x80109161
80103734:	e8 2d ce ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103739:	83 ec 0c             	sub    $0xc,%esp
8010373c:	68 80 32 11 80       	push   $0x80113280
80103741:	e8 91 20 00 00       	call   801057d7 <acquire>
80103746:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103749:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103750:	eb 1d                	jmp    8010376f <log_write+0x7b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103755:	83 c0 10             	add    $0x10,%eax
80103758:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010375f:	89 c2                	mov    %eax,%edx
80103761:	8b 45 08             	mov    0x8(%ebp),%eax
80103764:	8b 40 08             	mov    0x8(%eax),%eax
80103767:	39 c2                	cmp    %eax,%edx
80103769:	74 10                	je     8010377b <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010376b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010376f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103774:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103777:	7f d9                	jg     80103752 <log_write+0x5e>
80103779:	eb 01                	jmp    8010377c <log_write+0x88>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
8010377b:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010377c:	8b 45 08             	mov    0x8(%ebp),%eax
8010377f:	8b 40 08             	mov    0x8(%eax),%eax
80103782:	89 c2                	mov    %eax,%edx
80103784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103787:	83 c0 10             	add    $0x10,%eax
8010378a:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
80103791:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103796:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103799:	75 0d                	jne    801037a8 <log_write+0xb4>
    log.lh.n++;
8010379b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037a0:	83 c0 01             	add    $0x1,%eax
801037a3:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801037a8:	8b 45 08             	mov    0x8(%ebp),%eax
801037ab:	8b 00                	mov    (%eax),%eax
801037ad:	83 c8 04             	or     $0x4,%eax
801037b0:	89 c2                	mov    %eax,%edx
801037b2:	8b 45 08             	mov    0x8(%ebp),%eax
801037b5:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037b7:	83 ec 0c             	sub    $0xc,%esp
801037ba:	68 80 32 11 80       	push   $0x80113280
801037bf:	e8 7a 20 00 00       	call   8010583e <release>
801037c4:	83 c4 10             	add    $0x10,%esp
}
801037c7:	90                   	nop
801037c8:	c9                   	leave  
801037c9:	c3                   	ret    

801037ca <v2p>:
801037ca:	55                   	push   %ebp
801037cb:	89 e5                	mov    %esp,%ebp
801037cd:	8b 45 08             	mov    0x8(%ebp),%eax
801037d0:	05 00 00 00 80       	add    $0x80000000,%eax
801037d5:	5d                   	pop    %ebp
801037d6:	c3                   	ret    

801037d7 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801037d7:	55                   	push   %ebp
801037d8:	89 e5                	mov    %esp,%ebp
801037da:	8b 45 08             	mov    0x8(%ebp),%eax
801037dd:	05 00 00 00 80       	add    $0x80000000,%eax
801037e2:	5d                   	pop    %ebp
801037e3:	c3                   	ret    

801037e4 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037e4:	55                   	push   %ebp
801037e5:	89 e5                	mov    %esp,%ebp
801037e7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037ea:	8b 55 08             	mov    0x8(%ebp),%edx
801037ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037f3:	f0 87 02             	lock xchg %eax,(%edx)
801037f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037fc:	c9                   	leave  
801037fd:	c3                   	ret    

801037fe <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037fe:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103802:	83 e4 f0             	and    $0xfffffff0,%esp
80103805:	ff 71 fc             	pushl  -0x4(%ecx)
80103808:	55                   	push   %ebp
80103809:	89 e5                	mov    %esp,%ebp
8010380b:	51                   	push   %ecx
8010380c:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010380f:	83 ec 08             	sub    $0x8,%esp
80103812:	68 00 00 40 80       	push   $0x80400000
80103817:	68 bc 6d 11 80       	push   $0x80116dbc
8010381c:	e8 75 f2 ff ff       	call   80102a96 <kinit1>
80103821:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103824:	e8 a0 4f 00 00       	call   801087c9 <kvmalloc>
  mpinit();        // collect info about this machine
80103829:	e8 4d 04 00 00       	call   80103c7b <mpinit>
  lapicinit();
8010382e:	e8 e2 f5 ff ff       	call   80102e15 <lapicinit>
  seginit();       // set up segments
80103833:	e8 3a 49 00 00       	call   80108172 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103838:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010383e:	0f b6 00             	movzbl (%eax),%eax
80103841:	0f b6 c0             	movzbl %al,%eax
80103844:	83 ec 08             	sub    $0x8,%esp
80103847:	50                   	push   %eax
80103848:	68 7c 91 10 80       	push   $0x8010917c
8010384d:	e8 74 cb ff ff       	call   801003c6 <cprintf>
80103852:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103855:	e8 77 06 00 00       	call   80103ed1 <picinit>
  ioapicinit();    // another interrupt controller
8010385a:	e8 2c f1 ff ff       	call   8010298b <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010385f:	e8 85 d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
80103864:	e8 65 3c 00 00       	call   801074ce <uartinit>
  pinit();         // process table
80103869:	e8 ec 0d 00 00       	call   8010465a <pinit>
  tvinit();        // trap vectors
8010386e:	e8 2b 37 00 00       	call   80106f9e <tvinit>
  binit();         // buffer cache
80103873:	e8 bc c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103878:	e8 e5 d6 ff ff       	call   80100f62 <fileinit>
  seminit();       // semaphore table
8010387d:	e8 83 1a 00 00       	call   80105305 <seminit>
  iinit();         // inode cache
80103882:	e8 b9 dd ff ff       	call   80101640 <iinit>
  ideinit();       // disk
80103887:	e8 43 ed ff ff       	call   801025cf <ideinit>
  if(!ismp)
8010388c:	a1 64 33 11 80       	mov    0x80113364,%eax
80103891:	85 c0                	test   %eax,%eax
80103893:	75 05                	jne    8010389a <main+0x9c>
    timerinit();   // uniprocessor timer
80103895:	e8 61 36 00 00       	call   80106efb <timerinit>
  startothers();   // start other processors
8010389a:	e8 7f 00 00 00       	call   8010391e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010389f:	83 ec 08             	sub    $0x8,%esp
801038a2:	68 00 00 00 8e       	push   $0x8e000000
801038a7:	68 00 00 40 80       	push   $0x80400000
801038ac:	e8 1e f2 ff ff       	call   80102acf <kinit2>
801038b1:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038b4:	e8 dd 0e 00 00       	call   80104796 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801038b9:	e8 1a 00 00 00       	call   801038d8 <mpmain>

801038be <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038be:	55                   	push   %ebp
801038bf:	89 e5                	mov    %esp,%ebp
801038c1:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038c4:	e8 18 4f 00 00       	call   801087e1 <switchkvm>
  seginit();
801038c9:	e8 a4 48 00 00       	call   80108172 <seginit>
  lapicinit();
801038ce:	e8 42 f5 ff ff       	call   80102e15 <lapicinit>
  mpmain();
801038d3:	e8 00 00 00 00       	call   801038d8 <mpmain>

801038d8 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038d8:	55                   	push   %ebp
801038d9:	89 e5                	mov    %esp,%ebp
801038db:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801038de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038e4:	0f b6 00             	movzbl (%eax),%eax
801038e7:	0f b6 c0             	movzbl %al,%eax
801038ea:	83 ec 08             	sub    $0x8,%esp
801038ed:	50                   	push   %eax
801038ee:	68 93 91 10 80       	push   $0x80109193
801038f3:	e8 ce ca ff ff       	call   801003c6 <cprintf>
801038f8:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801038fb:	e8 14 38 00 00       	call   80107114 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103900:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103906:	05 a8 00 00 00       	add    $0xa8,%eax
8010390b:	83 ec 08             	sub    $0x8,%esp
8010390e:	6a 01                	push   $0x1
80103910:	50                   	push   %eax
80103911:	e8 ce fe ff ff       	call   801037e4 <xchg>
80103916:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103919:	e8 ef 14 00 00       	call   80104e0d <scheduler>

8010391e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010391e:	55                   	push   %ebp
8010391f:	89 e5                	mov    %esp,%ebp
80103921:	53                   	push   %ebx
80103922:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103925:	68 00 70 00 00       	push   $0x7000
8010392a:	e8 a8 fe ff ff       	call   801037d7 <p2v>
8010392f:	83 c4 04             	add    $0x4,%esp
80103932:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103935:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010393a:	83 ec 04             	sub    $0x4,%esp
8010393d:	50                   	push   %eax
8010393e:	68 2c c5 10 80       	push   $0x8010c52c
80103943:	ff 75 f0             	pushl  -0x10(%ebp)
80103946:	e8 ae 21 00 00       	call   80105af9 <memmove>
8010394b:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010394e:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103955:	e9 90 00 00 00       	jmp    801039ea <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
8010395a:	e8 d4 f5 ff ff       	call   80102f33 <cpunum>
8010395f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103965:	05 80 33 11 80       	add    $0x80113380,%eax
8010396a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010396d:	74 73                	je     801039e2 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010396f:	e8 59 f2 ff ff       	call   80102bcd <kalloc>
80103974:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103977:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010397a:	83 e8 04             	sub    $0x4,%eax
8010397d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103980:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103986:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398b:	83 e8 08             	sub    $0x8,%eax
8010398e:	c7 00 be 38 10 80    	movl   $0x801038be,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103997:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010399a:	83 ec 0c             	sub    $0xc,%esp
8010399d:	68 00 b0 10 80       	push   $0x8010b000
801039a2:	e8 23 fe ff ff       	call   801037ca <v2p>
801039a7:	83 c4 10             	add    $0x10,%esp
801039aa:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801039ac:	83 ec 0c             	sub    $0xc,%esp
801039af:	ff 75 f0             	pushl  -0x10(%ebp)
801039b2:	e8 13 fe ff ff       	call   801037ca <v2p>
801039b7:	83 c4 10             	add    $0x10,%esp
801039ba:	89 c2                	mov    %eax,%edx
801039bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039bf:	0f b6 00             	movzbl (%eax),%eax
801039c2:	0f b6 c0             	movzbl %al,%eax
801039c5:	83 ec 08             	sub    $0x8,%esp
801039c8:	52                   	push   %edx
801039c9:	50                   	push   %eax
801039ca:	e8 de f5 ff ff       	call   80102fad <lapicstartap>
801039cf:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d2:	90                   	nop
801039d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801039dc:	85 c0                	test   %eax,%eax
801039de:	74 f3                	je     801039d3 <startothers+0xb5>
801039e0:	eb 01                	jmp    801039e3 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801039e2:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039e3:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801039ea:	a1 60 39 11 80       	mov    0x80113960,%eax
801039ef:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039f5:	05 80 33 11 80       	add    $0x80113380,%eax
801039fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039fd:	0f 87 57 ff ff ff    	ja     8010395a <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a03:	90                   	nop
80103a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a07:	c9                   	leave  
80103a08:	c3                   	ret    

80103a09 <p2v>:
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0f:	05 00 00 00 80       	add    $0x80000000,%eax
80103a14:	5d                   	pop    %ebp
80103a15:	c3                   	ret    

80103a16 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a16:	55                   	push   %ebp
80103a17:	89 e5                	mov    %esp,%ebp
80103a19:	83 ec 14             	sub    $0x14,%esp
80103a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a23:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a27:	89 c2                	mov    %eax,%edx
80103a29:	ec                   	in     (%dx),%al
80103a2a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a2d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a31:	c9                   	leave  
80103a32:	c3                   	ret    

80103a33 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a33:	55                   	push   %ebp
80103a34:	89 e5                	mov    %esp,%ebp
80103a36:	83 ec 08             	sub    $0x8,%esp
80103a39:	8b 55 08             	mov    0x8(%ebp),%edx
80103a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a3f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a43:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a46:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a4a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a4e:	ee                   	out    %al,(%dx)
}
80103a4f:	90                   	nop
80103a50:	c9                   	leave  
80103a51:	c3                   	ret    

80103a52 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103a52:	55                   	push   %ebp
80103a53:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103a55:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103a5a:	89 c2                	mov    %eax,%edx
80103a5c:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103a61:	29 c2                	sub    %eax,%edx
80103a63:	89 d0                	mov    %edx,%eax
80103a65:	c1 f8 02             	sar    $0x2,%eax
80103a68:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a6e:	5d                   	pop    %ebp
80103a6f:	c3                   	ret    

80103a70 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a76:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a7d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a84:	eb 15                	jmp    80103a9b <sum+0x2b>
    sum += addr[i];
80103a86:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a89:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8c:	01 d0                	add    %edx,%eax
80103a8e:	0f b6 00             	movzbl (%eax),%eax
80103a91:	0f b6 c0             	movzbl %al,%eax
80103a94:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a97:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a9e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103aa1:	7c e3                	jl     80103a86 <sum+0x16>
    sum += addr[i];
  return sum;
80103aa3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103aa6:	c9                   	leave  
80103aa7:	c3                   	ret    

80103aa8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103aa8:	55                   	push   %ebp
80103aa9:	89 e5                	mov    %esp,%ebp
80103aab:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103aae:	ff 75 08             	pushl  0x8(%ebp)
80103ab1:	e8 53 ff ff ff       	call   80103a09 <p2v>
80103ab6:	83 c4 04             	add    $0x4,%esp
80103ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103abc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac2:	01 d0                	add    %edx,%eax
80103ac4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aca:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103acd:	eb 36                	jmp    80103b05 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103acf:	83 ec 04             	sub    $0x4,%esp
80103ad2:	6a 04                	push   $0x4
80103ad4:	68 a4 91 10 80       	push   $0x801091a4
80103ad9:	ff 75 f4             	pushl  -0xc(%ebp)
80103adc:	e8 c0 1f 00 00       	call   80105aa1 <memcmp>
80103ae1:	83 c4 10             	add    $0x10,%esp
80103ae4:	85 c0                	test   %eax,%eax
80103ae6:	75 19                	jne    80103b01 <mpsearch1+0x59>
80103ae8:	83 ec 08             	sub    $0x8,%esp
80103aeb:	6a 10                	push   $0x10
80103aed:	ff 75 f4             	pushl  -0xc(%ebp)
80103af0:	e8 7b ff ff ff       	call   80103a70 <sum>
80103af5:	83 c4 10             	add    $0x10,%esp
80103af8:	84 c0                	test   %al,%al
80103afa:	75 05                	jne    80103b01 <mpsearch1+0x59>
      return (struct mp*)p;
80103afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aff:	eb 11                	jmp    80103b12 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b01:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b08:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b0b:	72 c2                	jb     80103acf <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b12:	c9                   	leave  
80103b13:	c3                   	ret    

80103b14 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b14:	55                   	push   %ebp
80103b15:	89 e5                	mov    %esp,%ebp
80103b17:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b1a:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b24:	83 c0 0f             	add    $0xf,%eax
80103b27:	0f b6 00             	movzbl (%eax),%eax
80103b2a:	0f b6 c0             	movzbl %al,%eax
80103b2d:	c1 e0 08             	shl    $0x8,%eax
80103b30:	89 c2                	mov    %eax,%edx
80103b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b35:	83 c0 0e             	add    $0xe,%eax
80103b38:	0f b6 00             	movzbl (%eax),%eax
80103b3b:	0f b6 c0             	movzbl %al,%eax
80103b3e:	09 d0                	or     %edx,%eax
80103b40:	c1 e0 04             	shl    $0x4,%eax
80103b43:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b4a:	74 21                	je     80103b6d <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b4c:	83 ec 08             	sub    $0x8,%esp
80103b4f:	68 00 04 00 00       	push   $0x400
80103b54:	ff 75 f0             	pushl  -0x10(%ebp)
80103b57:	e8 4c ff ff ff       	call   80103aa8 <mpsearch1>
80103b5c:	83 c4 10             	add    $0x10,%esp
80103b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b66:	74 51                	je     80103bb9 <mpsearch+0xa5>
      return mp;
80103b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b6b:	eb 61                	jmp    80103bce <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b70:	83 c0 14             	add    $0x14,%eax
80103b73:	0f b6 00             	movzbl (%eax),%eax
80103b76:	0f b6 c0             	movzbl %al,%eax
80103b79:	c1 e0 08             	shl    $0x8,%eax
80103b7c:	89 c2                	mov    %eax,%edx
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	83 c0 13             	add    $0x13,%eax
80103b84:	0f b6 00             	movzbl (%eax),%eax
80103b87:	0f b6 c0             	movzbl %al,%eax
80103b8a:	09 d0                	or     %edx,%eax
80103b8c:	c1 e0 0a             	shl    $0xa,%eax
80103b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b95:	2d 00 04 00 00       	sub    $0x400,%eax
80103b9a:	83 ec 08             	sub    $0x8,%esp
80103b9d:	68 00 04 00 00       	push   $0x400
80103ba2:	50                   	push   %eax
80103ba3:	e8 00 ff ff ff       	call   80103aa8 <mpsearch1>
80103ba8:	83 c4 10             	add    $0x10,%esp
80103bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bb2:	74 05                	je     80103bb9 <mpsearch+0xa5>
      return mp;
80103bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bb7:	eb 15                	jmp    80103bce <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bb9:	83 ec 08             	sub    $0x8,%esp
80103bbc:	68 00 00 01 00       	push   $0x10000
80103bc1:	68 00 00 0f 00       	push   $0xf0000
80103bc6:	e8 dd fe ff ff       	call   80103aa8 <mpsearch1>
80103bcb:	83 c4 10             	add    $0x10,%esp
}
80103bce:	c9                   	leave  
80103bcf:	c3                   	ret    

80103bd0 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103bd0:	55                   	push   %ebp
80103bd1:	89 e5                	mov    %esp,%ebp
80103bd3:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bd6:	e8 39 ff ff ff       	call   80103b14 <mpsearch>
80103bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103be2:	74 0a                	je     80103bee <mpconfig+0x1e>
80103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be7:	8b 40 04             	mov    0x4(%eax),%eax
80103bea:	85 c0                	test   %eax,%eax
80103bec:	75 0a                	jne    80103bf8 <mpconfig+0x28>
    return 0;
80103bee:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf3:	e9 81 00 00 00       	jmp    80103c79 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfb:	8b 40 04             	mov    0x4(%eax),%eax
80103bfe:	83 ec 0c             	sub    $0xc,%esp
80103c01:	50                   	push   %eax
80103c02:	e8 02 fe ff ff       	call   80103a09 <p2v>
80103c07:	83 c4 10             	add    $0x10,%esp
80103c0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c0d:	83 ec 04             	sub    $0x4,%esp
80103c10:	6a 04                	push   $0x4
80103c12:	68 a9 91 10 80       	push   $0x801091a9
80103c17:	ff 75 f0             	pushl  -0x10(%ebp)
80103c1a:	e8 82 1e 00 00       	call   80105aa1 <memcmp>
80103c1f:	83 c4 10             	add    $0x10,%esp
80103c22:	85 c0                	test   %eax,%eax
80103c24:	74 07                	je     80103c2d <mpconfig+0x5d>
    return 0;
80103c26:	b8 00 00 00 00       	mov    $0x0,%eax
80103c2b:	eb 4c                	jmp    80103c79 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c30:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c34:	3c 01                	cmp    $0x1,%al
80103c36:	74 12                	je     80103c4a <mpconfig+0x7a>
80103c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c3f:	3c 04                	cmp    $0x4,%al
80103c41:	74 07                	je     80103c4a <mpconfig+0x7a>
    return 0;
80103c43:	b8 00 00 00 00       	mov    $0x0,%eax
80103c48:	eb 2f                	jmp    80103c79 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c51:	0f b7 c0             	movzwl %ax,%eax
80103c54:	83 ec 08             	sub    $0x8,%esp
80103c57:	50                   	push   %eax
80103c58:	ff 75 f0             	pushl  -0x10(%ebp)
80103c5b:	e8 10 fe ff ff       	call   80103a70 <sum>
80103c60:	83 c4 10             	add    $0x10,%esp
80103c63:	84 c0                	test   %al,%al
80103c65:	74 07                	je     80103c6e <mpconfig+0x9e>
    return 0;
80103c67:	b8 00 00 00 00       	mov    $0x0,%eax
80103c6c:	eb 0b                	jmp    80103c79 <mpconfig+0xa9>
  *pmp = mp;
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c74:	89 10                	mov    %edx,(%eax)
  return conf;
80103c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c79:	c9                   	leave  
80103c7a:	c3                   	ret    

80103c7b <mpinit>:

void
mpinit(void)
{
80103c7b:	55                   	push   %ebp
80103c7c:	89 e5                	mov    %esp,%ebp
80103c7e:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c81:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103c88:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c8b:	83 ec 0c             	sub    $0xc,%esp
80103c8e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c91:	50                   	push   %eax
80103c92:	e8 39 ff ff ff       	call   80103bd0 <mpconfig>
80103c97:	83 c4 10             	add    $0x10,%esp
80103c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ca1:	0f 84 96 01 00 00    	je     80103e3d <mpinit+0x1c2>
    return;
  ismp = 1;
80103ca7:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103cae:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb4:	8b 40 24             	mov    0x24(%eax),%eax
80103cb7:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbf:	83 c0 2c             	add    $0x2c,%eax
80103cc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ccc:	0f b7 d0             	movzwl %ax,%edx
80103ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd2:	01 d0                	add    %edx,%eax
80103cd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cd7:	e9 f2 00 00 00       	jmp    80103dce <mpinit+0x153>
    switch(*p){
80103cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdf:	0f b6 00             	movzbl (%eax),%eax
80103ce2:	0f b6 c0             	movzbl %al,%eax
80103ce5:	83 f8 04             	cmp    $0x4,%eax
80103ce8:	0f 87 bc 00 00 00    	ja     80103daa <mpinit+0x12f>
80103cee:	8b 04 85 ec 91 10 80 	mov    -0x7fef6e14(,%eax,4),%eax
80103cf5:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103cfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d00:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d04:	0f b6 d0             	movzbl %al,%edx
80103d07:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d0c:	39 c2                	cmp    %eax,%edx
80103d0e:	74 2b                	je     80103d3b <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d13:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d17:	0f b6 d0             	movzbl %al,%edx
80103d1a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d1f:	83 ec 04             	sub    $0x4,%esp
80103d22:	52                   	push   %edx
80103d23:	50                   	push   %eax
80103d24:	68 ae 91 10 80       	push   $0x801091ae
80103d29:	e8 98 c6 ff ff       	call   801003c6 <cprintf>
80103d2e:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103d31:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103d38:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d3e:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103d42:	0f b6 c0             	movzbl %al,%eax
80103d45:	83 e0 02             	and    $0x2,%eax
80103d48:	85 c0                	test   %eax,%eax
80103d4a:	74 15                	je     80103d61 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103d4c:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d51:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d57:	05 80 33 11 80       	add    $0x80113380,%eax
80103d5c:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103d61:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d66:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103d6c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d72:	05 80 33 11 80       	add    $0x80113380,%eax
80103d77:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103d79:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d7e:	83 c0 01             	add    $0x1,%eax
80103d81:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103d86:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d8a:	eb 42                	jmp    80103dce <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d95:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d99:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103d9e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da2:	eb 2a                	jmp    80103dce <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103da4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da8:	eb 24                	jmp    80103dce <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dad:	0f b6 00             	movzbl (%eax),%eax
80103db0:	0f b6 c0             	movzbl %al,%eax
80103db3:	83 ec 08             	sub    $0x8,%esp
80103db6:	50                   	push   %eax
80103db7:	68 cc 91 10 80       	push   $0x801091cc
80103dbc:	e8 05 c6 ff ff       	call   801003c6 <cprintf>
80103dc1:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103dc4:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103dcb:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103dd4:	0f 82 02 ff ff ff    	jb     80103cdc <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103dda:	a1 64 33 11 80       	mov    0x80113364,%eax
80103ddf:	85 c0                	test   %eax,%eax
80103de1:	75 1d                	jne    80103e00 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103de3:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103dea:	00 00 00 
    lapic = 0;
80103ded:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103df4:	00 00 00 
    ioapicid = 0;
80103df7:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103dfe:	eb 3e                	jmp    80103e3e <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e03:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e07:	84 c0                	test   %al,%al
80103e09:	74 33                	je     80103e3e <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e0b:	83 ec 08             	sub    $0x8,%esp
80103e0e:	6a 70                	push   $0x70
80103e10:	6a 22                	push   $0x22
80103e12:	e8 1c fc ff ff       	call   80103a33 <outb>
80103e17:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e1a:	83 ec 0c             	sub    $0xc,%esp
80103e1d:	6a 23                	push   $0x23
80103e1f:	e8 f2 fb ff ff       	call   80103a16 <inb>
80103e24:	83 c4 10             	add    $0x10,%esp
80103e27:	83 c8 01             	or     $0x1,%eax
80103e2a:	0f b6 c0             	movzbl %al,%eax
80103e2d:	83 ec 08             	sub    $0x8,%esp
80103e30:	50                   	push   %eax
80103e31:	6a 23                	push   $0x23
80103e33:	e8 fb fb ff ff       	call   80103a33 <outb>
80103e38:	83 c4 10             	add    $0x10,%esp
80103e3b:	eb 01                	jmp    80103e3e <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103e3d:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103e3e:	c9                   	leave  
80103e3f:	c3                   	ret    

80103e40 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e40:	55                   	push   %ebp
80103e41:	89 e5                	mov    %esp,%ebp
80103e43:	83 ec 08             	sub    $0x8,%esp
80103e46:	8b 55 08             	mov    0x8(%ebp),%edx
80103e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e4c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e50:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e53:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e57:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e5b:	ee                   	out    %al,(%dx)
}
80103e5c:	90                   	nop
80103e5d:	c9                   	leave  
80103e5e:	c3                   	ret    

80103e5f <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e5f:	55                   	push   %ebp
80103e60:	89 e5                	mov    %esp,%ebp
80103e62:	83 ec 04             	sub    $0x4,%esp
80103e65:	8b 45 08             	mov    0x8(%ebp),%eax
80103e68:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e6c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e70:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103e76:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e7a:	0f b6 c0             	movzbl %al,%eax
80103e7d:	50                   	push   %eax
80103e7e:	6a 21                	push   $0x21
80103e80:	e8 bb ff ff ff       	call   80103e40 <outb>
80103e85:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103e88:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e8c:	66 c1 e8 08          	shr    $0x8,%ax
80103e90:	0f b6 c0             	movzbl %al,%eax
80103e93:	50                   	push   %eax
80103e94:	68 a1 00 00 00       	push   $0xa1
80103e99:	e8 a2 ff ff ff       	call   80103e40 <outb>
80103e9e:	83 c4 08             	add    $0x8,%esp
}
80103ea1:	90                   	nop
80103ea2:	c9                   	leave  
80103ea3:	c3                   	ret    

80103ea4 <picenable>:

void
picenable(int irq)
{
80103ea4:	55                   	push   %ebp
80103ea5:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eaa:	ba 01 00 00 00       	mov    $0x1,%edx
80103eaf:	89 c1                	mov    %eax,%ecx
80103eb1:	d3 e2                	shl    %cl,%edx
80103eb3:	89 d0                	mov    %edx,%eax
80103eb5:	f7 d0                	not    %eax
80103eb7:	89 c2                	mov    %eax,%edx
80103eb9:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103ec0:	21 d0                	and    %edx,%eax
80103ec2:	0f b7 c0             	movzwl %ax,%eax
80103ec5:	50                   	push   %eax
80103ec6:	e8 94 ff ff ff       	call   80103e5f <picsetmask>
80103ecb:	83 c4 04             	add    $0x4,%esp
}
80103ece:	90                   	nop
80103ecf:	c9                   	leave  
80103ed0:	c3                   	ret    

80103ed1 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ed1:	55                   	push   %ebp
80103ed2:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ed4:	68 ff 00 00 00       	push   $0xff
80103ed9:	6a 21                	push   $0x21
80103edb:	e8 60 ff ff ff       	call   80103e40 <outb>
80103ee0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103ee3:	68 ff 00 00 00       	push   $0xff
80103ee8:	68 a1 00 00 00       	push   $0xa1
80103eed:	e8 4e ff ff ff       	call   80103e40 <outb>
80103ef2:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ef5:	6a 11                	push   $0x11
80103ef7:	6a 20                	push   $0x20
80103ef9:	e8 42 ff ff ff       	call   80103e40 <outb>
80103efe:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f01:	6a 20                	push   $0x20
80103f03:	6a 21                	push   $0x21
80103f05:	e8 36 ff ff ff       	call   80103e40 <outb>
80103f0a:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f0d:	6a 04                	push   $0x4
80103f0f:	6a 21                	push   $0x21
80103f11:	e8 2a ff ff ff       	call   80103e40 <outb>
80103f16:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f19:	6a 03                	push   $0x3
80103f1b:	6a 21                	push   $0x21
80103f1d:	e8 1e ff ff ff       	call   80103e40 <outb>
80103f22:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f25:	6a 11                	push   $0x11
80103f27:	68 a0 00 00 00       	push   $0xa0
80103f2c:	e8 0f ff ff ff       	call   80103e40 <outb>
80103f31:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f34:	6a 28                	push   $0x28
80103f36:	68 a1 00 00 00       	push   $0xa1
80103f3b:	e8 00 ff ff ff       	call   80103e40 <outb>
80103f40:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f43:	6a 02                	push   $0x2
80103f45:	68 a1 00 00 00       	push   $0xa1
80103f4a:	e8 f1 fe ff ff       	call   80103e40 <outb>
80103f4f:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f52:	6a 03                	push   $0x3
80103f54:	68 a1 00 00 00       	push   $0xa1
80103f59:	e8 e2 fe ff ff       	call   80103e40 <outb>
80103f5e:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f61:	6a 68                	push   $0x68
80103f63:	6a 20                	push   $0x20
80103f65:	e8 d6 fe ff ff       	call   80103e40 <outb>
80103f6a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f6d:	6a 0a                	push   $0xa
80103f6f:	6a 20                	push   $0x20
80103f71:	e8 ca fe ff ff       	call   80103e40 <outb>
80103f76:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103f79:	6a 68                	push   $0x68
80103f7b:	68 a0 00 00 00       	push   $0xa0
80103f80:	e8 bb fe ff ff       	call   80103e40 <outb>
80103f85:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103f88:	6a 0a                	push   $0xa
80103f8a:	68 a0 00 00 00       	push   $0xa0
80103f8f:	e8 ac fe ff ff       	call   80103e40 <outb>
80103f94:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103f97:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f9e:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fa2:	74 13                	je     80103fb7 <picinit+0xe6>
    picsetmask(irqmask);
80103fa4:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fab:	0f b7 c0             	movzwl %ax,%eax
80103fae:	50                   	push   %eax
80103faf:	e8 ab fe ff ff       	call   80103e5f <picsetmask>
80103fb4:	83 c4 04             	add    $0x4,%esp
}
80103fb7:	90                   	nop
80103fb8:	c9                   	leave  
80103fb9:	c3                   	ret    

80103fba <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fba:	55                   	push   %ebp
80103fbb:	89 e5                	mov    %esp,%ebp
80103fbd:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd3:	8b 10                	mov    (%eax),%edx
80103fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd8:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fda:	e8 a1 cf ff ff       	call   80100f80 <filealloc>
80103fdf:	89 c2                	mov    %eax,%edx
80103fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe4:	89 10                	mov    %edx,(%eax)
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 00                	mov    (%eax),%eax
80103feb:	85 c0                	test   %eax,%eax
80103fed:	0f 84 cb 00 00 00    	je     801040be <pipealloc+0x104>
80103ff3:	e8 88 cf ff ff       	call   80100f80 <filealloc>
80103ff8:	89 c2                	mov    %eax,%edx
80103ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffd:	89 10                	mov    %edx,(%eax)
80103fff:	8b 45 0c             	mov    0xc(%ebp),%eax
80104002:	8b 00                	mov    (%eax),%eax
80104004:	85 c0                	test   %eax,%eax
80104006:	0f 84 b2 00 00 00    	je     801040be <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010400c:	e8 bc eb ff ff       	call   80102bcd <kalloc>
80104011:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104014:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104018:	0f 84 9f 00 00 00    	je     801040bd <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010401e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104021:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104028:	00 00 00 
  p->writeopen = 1;
8010402b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104035:	00 00 00 
  p->nwrite = 0;
80104038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104042:	00 00 00 
  p->nread = 0;
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010404f:	00 00 00 
  initlock(&p->lock, "pipe");
80104052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104055:	83 ec 08             	sub    $0x8,%esp
80104058:	68 00 92 10 80       	push   $0x80109200
8010405d:	50                   	push   %eax
8010405e:	e8 52 17 00 00       	call   801057b5 <initlock>
80104063:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104066:	8b 45 08             	mov    0x8(%ebp),%eax
80104069:	8b 00                	mov    (%eax),%eax
8010406b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104071:	8b 45 08             	mov    0x8(%ebp),%eax
80104074:	8b 00                	mov    (%eax),%eax
80104076:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010407a:	8b 45 08             	mov    0x8(%ebp),%eax
8010407d:	8b 00                	mov    (%eax),%eax
8010407f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104083:	8b 45 08             	mov    0x8(%ebp),%eax
80104086:	8b 00                	mov    (%eax),%eax
80104088:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010408b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010408e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104091:	8b 00                	mov    (%eax),%eax
80104093:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104099:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409c:	8b 00                	mov    (%eax),%eax
8010409e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a5:	8b 00                	mov    (%eax),%eax
801040a7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ae:	8b 00                	mov    (%eax),%eax
801040b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040b6:	b8 00 00 00 00       	mov    $0x0,%eax
801040bb:	eb 4e                	jmp    8010410b <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040bd:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040c2:	74 0e                	je     801040d2 <pipealloc+0x118>
    kfree((char*)p);
801040c4:	83 ec 0c             	sub    $0xc,%esp
801040c7:	ff 75 f4             	pushl  -0xc(%ebp)
801040ca:	e8 61 ea ff ff       	call   80102b30 <kfree>
801040cf:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040d2:	8b 45 08             	mov    0x8(%ebp),%eax
801040d5:	8b 00                	mov    (%eax),%eax
801040d7:	85 c0                	test   %eax,%eax
801040d9:	74 11                	je     801040ec <pipealloc+0x132>
    fileclose(*f0);
801040db:	8b 45 08             	mov    0x8(%ebp),%eax
801040de:	8b 00                	mov    (%eax),%eax
801040e0:	83 ec 0c             	sub    $0xc,%esp
801040e3:	50                   	push   %eax
801040e4:	e8 55 cf ff ff       	call   8010103e <fileclose>
801040e9:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ef:	8b 00                	mov    (%eax),%eax
801040f1:	85 c0                	test   %eax,%eax
801040f3:	74 11                	je     80104106 <pipealloc+0x14c>
    fileclose(*f1);
801040f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f8:	8b 00                	mov    (%eax),%eax
801040fa:	83 ec 0c             	sub    $0xc,%esp
801040fd:	50                   	push   %eax
801040fe:	e8 3b cf ff ff       	call   8010103e <fileclose>
80104103:	83 c4 10             	add    $0x10,%esp
  return -1;
80104106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010410b:	c9                   	leave  
8010410c:	c3                   	ret    

8010410d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410d:	55                   	push   %ebp
8010410e:	89 e5                	mov    %esp,%ebp
80104110:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	83 ec 0c             	sub    $0xc,%esp
80104119:	50                   	push   %eax
8010411a:	e8 b8 16 00 00       	call   801057d7 <acquire>
8010411f:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104122:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104126:	74 23                	je     8010414b <pipeclose+0x3e>
    p->writeopen = 0;
80104128:	8b 45 08             	mov    0x8(%ebp),%eax
8010412b:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104132:	00 00 00 
    wakeup(&p->nread);
80104135:	8b 45 08             	mov    0x8(%ebp),%eax
80104138:	05 34 02 00 00       	add    $0x234,%eax
8010413d:	83 ec 0c             	sub    $0xc,%esp
80104140:	50                   	push   %eax
80104141:	e8 e1 0f 00 00       	call   80105127 <wakeup>
80104146:	83 c4 10             	add    $0x10,%esp
80104149:	eb 21                	jmp    8010416c <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104155:	00 00 00 
    wakeup(&p->nwrite);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	05 38 02 00 00       	add    $0x238,%eax
80104160:	83 ec 0c             	sub    $0xc,%esp
80104163:	50                   	push   %eax
80104164:	e8 be 0f 00 00       	call   80105127 <wakeup>
80104169:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104175:	85 c0                	test   %eax,%eax
80104177:	75 2c                	jne    801041a5 <pipeclose+0x98>
80104179:	8b 45 08             	mov    0x8(%ebp),%eax
8010417c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104182:	85 c0                	test   %eax,%eax
80104184:	75 1f                	jne    801041a5 <pipeclose+0x98>
    release(&p->lock);
80104186:	8b 45 08             	mov    0x8(%ebp),%eax
80104189:	83 ec 0c             	sub    $0xc,%esp
8010418c:	50                   	push   %eax
8010418d:	e8 ac 16 00 00       	call   8010583e <release>
80104192:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104195:	83 ec 0c             	sub    $0xc,%esp
80104198:	ff 75 08             	pushl  0x8(%ebp)
8010419b:	e8 90 e9 ff ff       	call   80102b30 <kfree>
801041a0:	83 c4 10             	add    $0x10,%esp
801041a3:	eb 0f                	jmp    801041b4 <pipeclose+0xa7>
  } else
    release(&p->lock);
801041a5:	8b 45 08             	mov    0x8(%ebp),%eax
801041a8:	83 ec 0c             	sub    $0xc,%esp
801041ab:	50                   	push   %eax
801041ac:	e8 8d 16 00 00       	call   8010583e <release>
801041b1:	83 c4 10             	add    $0x10,%esp
}
801041b4:	90                   	nop
801041b5:	c9                   	leave  
801041b6:	c3                   	ret    

801041b7 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041b7:	55                   	push   %ebp
801041b8:	89 e5                	mov    %esp,%ebp
801041ba:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	83 ec 0c             	sub    $0xc,%esp
801041c3:	50                   	push   %eax
801041c4:	e8 0e 16 00 00       	call   801057d7 <acquire>
801041c9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041d3:	e9 ad 00 00 00       	jmp    80104285 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041d8:	8b 45 08             	mov    0x8(%ebp),%eax
801041db:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041e1:	85 c0                	test   %eax,%eax
801041e3:	74 0d                	je     801041f2 <pipewrite+0x3b>
801041e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041eb:	8b 40 24             	mov    0x24(%eax),%eax
801041ee:	85 c0                	test   %eax,%eax
801041f0:	74 19                	je     8010420b <pipewrite+0x54>
        release(&p->lock);
801041f2:	8b 45 08             	mov    0x8(%ebp),%eax
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	50                   	push   %eax
801041f9:	e8 40 16 00 00       	call   8010583e <release>
801041fe:	83 c4 10             	add    $0x10,%esp
        return -1;
80104201:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104206:	e9 a8 00 00 00       	jmp    801042b3 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010420b:	8b 45 08             	mov    0x8(%ebp),%eax
8010420e:	05 34 02 00 00       	add    $0x234,%eax
80104213:	83 ec 0c             	sub    $0xc,%esp
80104216:	50                   	push   %eax
80104217:	e8 0b 0f 00 00       	call   80105127 <wakeup>
8010421c:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010421f:	8b 45 08             	mov    0x8(%ebp),%eax
80104222:	8b 55 08             	mov    0x8(%ebp),%edx
80104225:	81 c2 38 02 00 00    	add    $0x238,%edx
8010422b:	83 ec 08             	sub    $0x8,%esp
8010422e:	50                   	push   %eax
8010422f:	52                   	push   %edx
80104230:	e8 e6 0d 00 00       	call   8010501b <sleep>
80104235:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104238:	8b 45 08             	mov    0x8(%ebp),%eax
8010423b:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010424a:	05 00 02 00 00       	add    $0x200,%eax
8010424f:	39 c2                	cmp    %eax,%edx
80104251:	74 85                	je     801041d8 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010425c:	8d 48 01             	lea    0x1(%eax),%ecx
8010425f:	8b 55 08             	mov    0x8(%ebp),%edx
80104262:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104268:	25 ff 01 00 00       	and    $0x1ff,%eax
8010426d:	89 c1                	mov    %eax,%ecx
8010426f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104272:	8b 45 0c             	mov    0xc(%ebp),%eax
80104275:	01 d0                	add    %edx,%eax
80104277:	0f b6 10             	movzbl (%eax),%edx
8010427a:	8b 45 08             	mov    0x8(%ebp),%eax
8010427d:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104281:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104288:	3b 45 10             	cmp    0x10(%ebp),%eax
8010428b:	7c ab                	jl     80104238 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010428d:	8b 45 08             	mov    0x8(%ebp),%eax
80104290:	05 34 02 00 00       	add    $0x234,%eax
80104295:	83 ec 0c             	sub    $0xc,%esp
80104298:	50                   	push   %eax
80104299:	e8 89 0e 00 00       	call   80105127 <wakeup>
8010429e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	83 ec 0c             	sub    $0xc,%esp
801042a7:	50                   	push   %eax
801042a8:	e8 91 15 00 00       	call   8010583e <release>
801042ad:	83 c4 10             	add    $0x10,%esp
  return n;
801042b0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042b3:	c9                   	leave  
801042b4:	c3                   	ret    

801042b5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042b5:	55                   	push   %ebp
801042b6:	89 e5                	mov    %esp,%ebp
801042b8:	53                   	push   %ebx
801042b9:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801042bc:	8b 45 08             	mov    0x8(%ebp),%eax
801042bf:	83 ec 0c             	sub    $0xc,%esp
801042c2:	50                   	push   %eax
801042c3:	e8 0f 15 00 00       	call   801057d7 <acquire>
801042c8:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042cb:	eb 3f                	jmp    8010430c <piperead+0x57>
    if(proc->killed){
801042cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042d3:	8b 40 24             	mov    0x24(%eax),%eax
801042d6:	85 c0                	test   %eax,%eax
801042d8:	74 19                	je     801042f3 <piperead+0x3e>
      release(&p->lock);
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	83 ec 0c             	sub    $0xc,%esp
801042e0:	50                   	push   %eax
801042e1:	e8 58 15 00 00       	call   8010583e <release>
801042e6:	83 c4 10             	add    $0x10,%esp
      return -1;
801042e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042ee:	e9 bf 00 00 00       	jmp    801043b2 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042f3:	8b 45 08             	mov    0x8(%ebp),%eax
801042f6:	8b 55 08             	mov    0x8(%ebp),%edx
801042f9:	81 c2 34 02 00 00    	add    $0x234,%edx
801042ff:	83 ec 08             	sub    $0x8,%esp
80104302:	50                   	push   %eax
80104303:	52                   	push   %edx
80104304:	e8 12 0d 00 00       	call   8010501b <sleep>
80104309:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010430c:	8b 45 08             	mov    0x8(%ebp),%eax
8010430f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010431e:	39 c2                	cmp    %eax,%edx
80104320:	75 0d                	jne    8010432f <piperead+0x7a>
80104322:	8b 45 08             	mov    0x8(%ebp),%eax
80104325:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010432b:	85 c0                	test   %eax,%eax
8010432d:	75 9e                	jne    801042cd <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010432f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104336:	eb 49                	jmp    80104381 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104338:	8b 45 08             	mov    0x8(%ebp),%eax
8010433b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104341:	8b 45 08             	mov    0x8(%ebp),%eax
80104344:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010434a:	39 c2                	cmp    %eax,%edx
8010434c:	74 3d                	je     8010438b <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010434e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104351:	8b 45 0c             	mov    0xc(%ebp),%eax
80104354:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104357:	8b 45 08             	mov    0x8(%ebp),%eax
8010435a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104360:	8d 48 01             	lea    0x1(%eax),%ecx
80104363:	8b 55 08             	mov    0x8(%ebp),%edx
80104366:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010436c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104371:	89 c2                	mov    %eax,%edx
80104373:	8b 45 08             	mov    0x8(%ebp),%eax
80104376:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010437b:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010437d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104384:	3b 45 10             	cmp    0x10(%ebp),%eax
80104387:	7c af                	jl     80104338 <piperead+0x83>
80104389:	eb 01                	jmp    8010438c <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
8010438b:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010438c:	8b 45 08             	mov    0x8(%ebp),%eax
8010438f:	05 38 02 00 00       	add    $0x238,%eax
80104394:	83 ec 0c             	sub    $0xc,%esp
80104397:	50                   	push   %eax
80104398:	e8 8a 0d 00 00       	call   80105127 <wakeup>
8010439d:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043a0:	8b 45 08             	mov    0x8(%ebp),%eax
801043a3:	83 ec 0c             	sub    $0xc,%esp
801043a6:	50                   	push   %eax
801043a7:	e8 92 14 00 00       	call   8010583e <release>
801043ac:	83 c4 10             	add    $0x10,%esp
  return i;
801043af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043b5:	c9                   	leave  
801043b6:	c3                   	ret    

801043b7 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043b7:	55                   	push   %ebp
801043b8:	89 e5                	mov    %esp,%ebp
801043ba:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043bd:	9c                   	pushf  
801043be:	58                   	pop    %eax
801043bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043c5:	c9                   	leave  
801043c6:	c3                   	ret    

801043c7 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043c7:	55                   	push   %ebp
801043c8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043ca:	fb                   	sti    
}
801043cb:	90                   	nop
801043cc:	5d                   	pop    %ebp
801043cd:	c3                   	ret    

801043ce <make_runnable>:
} ptable;

//enqueue the process in the corresponding priority
static void
make_runnable(struct proc* p)
{
801043ce:	55                   	push   %ebp
801043cf:	89 e5                	mov    %esp,%ebp
  if(ptable.mlf[p->priority].last==0){
801043d1:	8b 45 08             	mov    0x8(%ebp),%eax
801043d4:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801043d8:	0f b7 c0             	movzwl %ax,%eax
801043db:	05 06 05 00 00       	add    $0x506,%eax
801043e0:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
801043e7:	85 c0                	test   %eax,%eax
801043e9:	75 1c                	jne    80104407 <make_runnable+0x39>
    ptable.mlf[p->priority].first = p;
801043eb:	8b 45 08             	mov    0x8(%ebp),%eax
801043ee:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801043f2:	0f b7 c0             	movzwl %ax,%eax
801043f5:	8d 90 06 05 00 00    	lea    0x506(%eax),%edx
801043fb:	8b 45 08             	mov    0x8(%ebp),%eax
801043fe:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
80104405:	eb 1f                	jmp    80104426 <make_runnable+0x58>
  } else{
    ptable.mlf[p->priority].last->next = p;
80104407:	8b 45 08             	mov    0x8(%ebp),%eax
8010440a:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010440e:	0f b7 c0             	movzwl %ax,%eax
80104411:	05 06 05 00 00       	add    $0x506,%eax
80104416:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
8010441d:	8b 55 08             	mov    0x8(%ebp),%edx
80104420:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
  ptable.mlf[p->priority].last=p;
80104426:	8b 45 08             	mov    0x8(%ebp),%eax
80104429:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010442d:	0f b7 c0             	movzwl %ax,%eax
80104430:	8d 90 06 05 00 00    	lea    0x506(%eax),%edx
80104436:	8b 45 08             	mov    0x8(%ebp),%eax
80104439:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
  p->next=0;
80104440:	8b 45 08             	mov    0x8(%ebp),%eax
80104443:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010444a:	00 00 00 
  p->age=0;
8010444d:	8b 45 08             	mov    0x8(%ebp),%eax
80104450:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
80104457:	00 00 
  p->state=RUNNABLE;
80104459:	8b 45 08             	mov    0x8(%ebp),%eax
8010445c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104463:	90                   	nop
80104464:	5d                   	pop    %ebp
80104465:	c3                   	ret    

80104466 <unqueue>:

//dequeue first element of the level "level"
static struct proc*
unqueue(int level)
{
80104466:	55                   	push   %ebp
80104467:	89 e5                	mov    %esp,%ebp
80104469:	83 ec 18             	sub    $0x18,%esp
  struct proc* p=ptable.mlf[level].first;
8010446c:	8b 45 08             	mov    0x8(%ebp),%eax
8010446f:	05 06 05 00 00       	add    $0x506,%eax
80104474:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
8010447b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!ptable.mlf[level].first)
8010447e:	8b 45 08             	mov    0x8(%ebp),%eax
80104481:	05 06 05 00 00       	add    $0x506,%eax
80104486:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
8010448d:	85 c0                	test   %eax,%eax
8010448f:	75 0d                	jne    8010449e <unqueue+0x38>
    panic("empty level");
80104491:	83 ec 0c             	sub    $0xc,%esp
80104494:	68 08 92 10 80       	push   $0x80109208
80104499:	e8 c8 c0 ff ff       	call   80100566 <panic>
  if(ptable.mlf[level].first==ptable.mlf[level].last){
8010449e:	8b 45 08             	mov    0x8(%ebp),%eax
801044a1:	05 06 05 00 00       	add    $0x506,%eax
801044a6:	8b 14 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%edx
801044ad:	8b 45 08             	mov    0x8(%ebp),%eax
801044b0:	05 06 05 00 00       	add    $0x506,%eax
801044b5:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
801044bc:	39 c2                	cmp    %eax,%edx
801044be:	75 34                	jne    801044f4 <unqueue+0x8e>
    ptable.mlf[level].last = ptable.mlf[level].first = 0;
801044c0:	8b 45 08             	mov    0x8(%ebp),%eax
801044c3:	05 06 05 00 00       	add    $0x506,%eax
801044c8:	c7 04 c5 84 39 11 80 	movl   $0x0,-0x7feec67c(,%eax,8)
801044cf:	00 00 00 00 
801044d3:	8b 45 08             	mov    0x8(%ebp),%eax
801044d6:	05 06 05 00 00       	add    $0x506,%eax
801044db:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801044e2:	8b 55 08             	mov    0x8(%ebp),%edx
801044e5:	81 c2 06 05 00 00    	add    $0x506,%edx
801044eb:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
801044f2:	eb 19                	jmp    8010450d <unqueue+0xa7>
  }else{
    ptable.mlf[level].first=p->next;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801044fd:	8b 55 08             	mov    0x8(%ebp),%edx
80104500:	81 c2 06 05 00 00    	add    $0x506,%edx
80104506:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
  }
  if(p->state!=RUNNABLE)
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 40 0c             	mov    0xc(%eax),%eax
80104513:	83 f8 03             	cmp    $0x3,%eax
80104516:	74 0d                	je     80104525 <unqueue+0xbf>
    panic("unqueue not RUNNABLE process");
80104518:	83 ec 0c             	sub    $0xc,%esp
8010451b:	68 14 92 10 80       	push   $0x80109214
80104520:	e8 41 c0 ff ff       	call   80100566 <panic>
  return p;
80104525:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104528:	c9                   	leave  
80104529:	c3                   	ret    

8010452a <levelupdate>:

//unqueue the process, it increases the priority if it corresponds, and queues it in the new level.
static void
levelupdate(struct proc* p)
{
8010452a:	55                   	push   %ebp
8010452b:	89 e5                	mov    %esp,%ebp
8010452d:	83 ec 08             	sub    $0x8,%esp
  unqueue(p->priority);
80104530:	8b 45 08             	mov    0x8(%ebp),%eax
80104533:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104537:	0f b7 c0             	movzwl %ax,%eax
8010453a:	83 ec 0c             	sub    $0xc,%esp
8010453d:	50                   	push   %eax
8010453e:	e8 23 ff ff ff       	call   80104466 <unqueue>
80104543:	83 c4 10             	add    $0x10,%esp
  if(p->priority>MLFMAXPRIORITY)
80104546:	8b 45 08             	mov    0x8(%ebp),%eax
80104549:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010454d:	66 85 c0             	test   %ax,%ax
80104550:	74 11                	je     80104563 <levelupdate+0x39>
    p->priority--;
80104552:	8b 45 08             	mov    0x8(%ebp),%eax
80104555:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104559:	8d 50 ff             	lea    -0x1(%eax),%edx
8010455c:	8b 45 08             	mov    0x8(%ebp),%eax
8010455f:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(p);
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	ff 75 08             	pushl  0x8(%ebp)
80104569:	e8 60 fe ff ff       	call   801043ce <make_runnable>
8010456e:	83 c4 10             	add    $0x10,%esp
}
80104571:	90                   	nop
80104572:	c9                   	leave  
80104573:	c3                   	ret    

80104574 <calculateaging>:

//go through MLF, looking for processes that reach AGEFORAGINGS and raise the priority.
//call procdump to show them.
void
calculateaging(void)
{
80104574:	55                   	push   %ebp
80104575:	89 e5                	mov    %esp,%ebp
80104577:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  int l;
  acquire(&ptable.lock);
8010457a:	83 ec 0c             	sub    $0xc,%esp
8010457d:	68 80 39 11 80       	push   $0x80113980
80104582:	e8 50 12 00 00       	call   801057d7 <acquire>
80104587:	83 c4 10             	add    $0x10,%esp
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
8010458a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104591:	e9 a7 00 00 00       	jmp    8010463d <calculateaging+0xc9>
    p=ptable.mlf[l].first;
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	05 06 05 00 00       	add    $0x506,%eax
8010459e:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801045a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p){
801045a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801045ac:	0f 84 87 00 00 00    	je     80104639 <calculateaging+0xc5>
      p->age++;  // increase the age to the process
801045b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045b5:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801045bc:	8d 50 01             	lea    0x1(%eax),%edx
801045bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c2:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      //procdump();
      if(p->age == AGEFORAGINGS){
801045c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045cc:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801045d3:	66 83 f8 05          	cmp    $0x5,%ax
801045d7:	75 60                	jne    80104639 <calculateaging+0xc5>
        if(ptable.mlf[p->priority].first!=p)
801045d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045dc:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801045e0:	0f b7 c0             	movzwl %ax,%eax
801045e3:	05 06 05 00 00       	add    $0x506,%eax
801045e8:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801045ef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801045f2:	74 0d                	je     80104601 <calculateaging+0x8d>
          panic("it does not eliminate the first element of the level.");
801045f4:	83 ec 0c             	sub    $0xc,%esp
801045f7:	68 34 92 10 80       	push   $0x80109234
801045fc:	e8 65 bf ff ff       	call   80100566 <panic>
        procdump();
80104601:	e8 e3 0b 00 00       	call   801051e9 <procdump>
        cprintf("/**************************************************************/\n");
80104606:	83 ec 0c             	sub    $0xc,%esp
80104609:	68 6c 92 10 80       	push   $0x8010926c
8010460e:	e8 b3 bd ff ff       	call   801003c6 <cprintf>
80104613:	83 c4 10             	add    $0x10,%esp
        levelupdate(p);  // call to levelupdate
80104616:	83 ec 0c             	sub    $0xc,%esp
80104619:	ff 75 f0             	pushl  -0x10(%ebp)
8010461c:	e8 09 ff ff ff       	call   8010452a <levelupdate>
80104621:	83 c4 10             	add    $0x10,%esp
        procdump();
80104624:	e8 c0 0b 00 00       	call   801051e9 <procdump>
        cprintf("/--------------------------------------------------------------/\n");
80104629:	83 ec 0c             	sub    $0xc,%esp
8010462c:	68 b0 92 10 80       	push   $0x801092b0
80104631:	e8 90 bd ff ff       	call   801003c6 <cprintf>
80104636:	83 c4 10             	add    $0x10,%esp
calculateaging(void)
{
  struct proc* p;
  int l;
  acquire(&ptable.lock);
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104639:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010463d:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80104641:	0f 8e 4f ff ff ff    	jle    80104596 <calculateaging+0x22>
        procdump();
        cprintf("/--------------------------------------------------------------/\n");
      }
    }
  }
  release(&ptable.lock);
80104647:	83 ec 0c             	sub    $0xc,%esp
8010464a:	68 80 39 11 80       	push   $0x80113980
8010464f:	e8 ea 11 00 00       	call   8010583e <release>
80104654:	83 c4 10             	add    $0x10,%esp
}
80104657:	90                   	nop
80104658:	c9                   	leave  
80104659:	c3                   	ret    

8010465a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010465a:	55                   	push   %ebp
8010465b:	89 e5                	mov    %esp,%ebp
8010465d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104660:	83 ec 08             	sub    $0x8,%esp
80104663:	68 f2 92 10 80       	push   $0x801092f2
80104668:	68 80 39 11 80       	push   $0x80113980
8010466d:	e8 43 11 00 00       	call   801057b5 <initlock>
80104672:	83 c4 10             	add    $0x10,%esp
}
80104675:	90                   	nop
80104676:	c9                   	leave  
80104677:	c3                   	ret    

80104678 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104678:	55                   	push   %ebp
80104679:	89 e5                	mov    %esp,%ebp
8010467b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010467e:	83 ec 0c             	sub    $0xc,%esp
80104681:	68 80 39 11 80       	push   $0x80113980
80104686:	e8 4c 11 00 00       	call   801057d7 <acquire>
8010468b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010468e:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104695:	eb 11                	jmp    801046a8 <allocproc+0x30>
    if(p->state == UNUSED)
80104697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469a:	8b 40 0c             	mov    0xc(%eax),%eax
8010469d:	85 c0                	test   %eax,%eax
8010469f:	74 2a                	je     801046cb <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046a1:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801046a8:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
801046af:	72 e6                	jb     80104697 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801046b1:	83 ec 0c             	sub    $0xc,%esp
801046b4:	68 80 39 11 80       	push   $0x80113980
801046b9:	e8 80 11 00 00       	call   8010583e <release>
801046be:	83 c4 10             	add    $0x10,%esp
  return 0;
801046c1:	b8 00 00 00 00       	mov    $0x0,%eax
801046c6:	e9 c9 00 00 00       	jmp    80104794 <allocproc+0x11c>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801046cb:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801046cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cf:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801046d6:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801046db:	8d 50 01             	lea    0x1(%eax),%edx
801046de:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801046e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046e7:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801046ea:	83 ec 0c             	sub    $0xc,%esp
801046ed:	68 80 39 11 80       	push   $0x80113980
801046f2:	e8 47 11 00 00       	call   8010583e <release>
801046f7:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801046fa:	e8 ce e4 ff ff       	call   80102bcd <kalloc>
801046ff:	89 c2                	mov    %eax,%edx
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	89 50 08             	mov    %edx,0x8(%eax)
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	8b 40 08             	mov    0x8(%eax),%eax
8010470d:	85 c0                	test   %eax,%eax
8010470f:	75 11                	jne    80104722 <allocproc+0xaa>
    p->state = UNUSED;
80104711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104714:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010471b:	b8 00 00 00 00       	mov    $0x0,%eax
80104720:	eb 72                	jmp    80104794 <allocproc+0x11c>
  }
  sp = p->kstack + KSTACKSIZE;
80104722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104725:	8b 40 08             	mov    0x8(%eax),%eax
80104728:	05 00 10 00 00       	add    $0x1000,%eax
8010472d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104730:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104737:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010473a:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010473d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104741:	ba 58 6f 10 80       	mov    $0x80106f58,%edx
80104746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104749:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010474b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010474f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104752:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104755:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010475e:	83 ec 04             	sub    $0x4,%esp
80104761:	6a 14                	push   $0x14
80104763:	6a 00                	push   $0x0
80104765:	50                   	push   %eax
80104766:	e8 cf 12 00 00       	call   80105a3a <memset>
8010476b:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010476e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104771:	8b 40 1c             	mov    0x1c(%eax),%eax
80104774:	ba ea 4f 10 80       	mov    $0x80104fea,%edx
80104779:	89 50 10             	mov    %edx,0x10(%eax)

  p->priority=0;  // initializes the priority.
8010477c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477f:	66 c7 40 7e 00 00    	movw   $0x0,0x7e(%eax)
  p->age=0;  // initialize age.
80104785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104788:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
8010478f:	00 00 
  return p;
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104794:	c9                   	leave  
80104795:	c3                   	ret    

80104796 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104796:	55                   	push   %ebp
80104797:	89 e5                	mov    %esp,%ebp
80104799:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010479c:	e8 d7 fe ff ff       	call   80104678 <allocproc>
801047a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a7:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801047ac:	e8 66 3f 00 00       	call   80108717 <setupkvm>
801047b1:	89 c2                	mov    %eax,%edx
801047b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b6:	89 50 04             	mov    %edx,0x4(%eax)
801047b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bc:	8b 40 04             	mov    0x4(%eax),%eax
801047bf:	85 c0                	test   %eax,%eax
801047c1:	75 0d                	jne    801047d0 <userinit+0x3a>
    panic("userinit: out of memory?");
801047c3:	83 ec 0c             	sub    $0xc,%esp
801047c6:	68 f9 92 10 80       	push   $0x801092f9
801047cb:	e8 96 bd ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801047d0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801047d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d8:	8b 40 04             	mov    0x4(%eax),%eax
801047db:	83 ec 04             	sub    $0x4,%esp
801047de:	52                   	push   %edx
801047df:	68 00 c5 10 80       	push   $0x8010c500
801047e4:	50                   	push   %eax
801047e5:	e8 87 41 00 00       	call   80108971 <inituvm>
801047ea:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801047ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801047f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f9:	8b 40 18             	mov    0x18(%eax),%eax
801047fc:	83 ec 04             	sub    $0x4,%esp
801047ff:	6a 4c                	push   $0x4c
80104801:	6a 00                	push   $0x0
80104803:	50                   	push   %eax
80104804:	e8 31 12 00 00       	call   80105a3a <memset>
80104809:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010480c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480f:	8b 40 18             	mov    0x18(%eax),%eax
80104812:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481b:	8b 40 18             	mov    0x18(%eax),%eax
8010481e:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104827:	8b 40 18             	mov    0x18(%eax),%eax
8010482a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010482d:	8b 52 18             	mov    0x18(%edx),%edx
80104830:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104834:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483b:	8b 40 18             	mov    0x18(%eax),%eax
8010483e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104841:	8b 52 18             	mov    0x18(%edx),%edx
80104844:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104848:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010484c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484f:	8b 40 18             	mov    0x18(%eax),%eax
80104852:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485c:	8b 40 18             	mov    0x18(%eax),%eax
8010485f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104869:	8b 40 18             	mov    0x18(%eax),%eax
8010486c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104876:	83 c0 6c             	add    $0x6c,%eax
80104879:	83 ec 04             	sub    $0x4,%esp
8010487c:	6a 10                	push   $0x10
8010487e:	68 12 93 10 80       	push   $0x80109312
80104883:	50                   	push   %eax
80104884:	e8 b4 13 00 00       	call   80105c3d <safestrcpy>
80104889:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010488c:	83 ec 0c             	sub    $0xc,%esp
8010488f:	68 1b 93 10 80       	push   $0x8010931b
80104894:	e8 32 dc ff ff       	call   801024cb <namei>
80104899:	83 c4 10             	add    $0x10,%esp
8010489c:	89 c2                	mov    %eax,%edx
8010489e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a1:	89 50 68             	mov    %edx,0x68(%eax)


  make_runnable(p);
801048a4:	83 ec 0c             	sub    $0xc,%esp
801048a7:	ff 75 f4             	pushl  -0xc(%ebp)
801048aa:	e8 1f fb ff ff       	call   801043ce <make_runnable>
801048af:	83 c4 10             	add    $0x10,%esp
}
801048b2:	90                   	nop
801048b3:	c9                   	leave  
801048b4:	c3                   	ret    

801048b5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801048b5:	55                   	push   %ebp
801048b6:	89 e5                	mov    %esp,%ebp
801048b8:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
801048bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c1:	8b 00                	mov    (%eax),%eax
801048c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801048c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801048ca:	7e 31                	jle    801048fd <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801048cc:	8b 55 08             	mov    0x8(%ebp),%edx
801048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d2:	01 c2                	add    %eax,%edx
801048d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048da:	8b 40 04             	mov    0x4(%eax),%eax
801048dd:	83 ec 04             	sub    $0x4,%esp
801048e0:	52                   	push   %edx
801048e1:	ff 75 f4             	pushl  -0xc(%ebp)
801048e4:	50                   	push   %eax
801048e5:	e8 d4 41 00 00       	call   80108abe <allocuvm>
801048ea:	83 c4 10             	add    $0x10,%esp
801048ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048f4:	75 3e                	jne    80104934 <growproc+0x7f>
      return -1;
801048f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fb:	eb 59                	jmp    80104956 <growproc+0xa1>
  } else if(n < 0){
801048fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104901:	79 31                	jns    80104934 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104903:	8b 55 08             	mov    0x8(%ebp),%edx
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	01 c2                	add    %eax,%edx
8010490b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104911:	8b 40 04             	mov    0x4(%eax),%eax
80104914:	83 ec 04             	sub    $0x4,%esp
80104917:	52                   	push   %edx
80104918:	ff 75 f4             	pushl  -0xc(%ebp)
8010491b:	50                   	push   %eax
8010491c:	e8 66 42 00 00       	call   80108b87 <deallocuvm>
80104921:	83 c4 10             	add    $0x10,%esp
80104924:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104927:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010492b:	75 07                	jne    80104934 <growproc+0x7f>
      return -1;
8010492d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104932:	eb 22                	jmp    80104956 <growproc+0xa1>
  }
  proc->sz = sz;
80104934:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010493d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010493f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104945:	83 ec 0c             	sub    $0xc,%esp
80104948:	50                   	push   %eax
80104949:	e8 b0 3e 00 00       	call   801087fe <switchuvm>
8010494e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104951:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104956:	c9                   	leave  
80104957:	c3                   	ret    

80104958 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104958:	55                   	push   %ebp
80104959:	89 e5                	mov    %esp,%ebp
8010495b:	57                   	push   %edi
8010495c:	56                   	push   %esi
8010495d:	53                   	push   %ebx
8010495e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104961:	e8 12 fd ff ff       	call   80104678 <allocproc>
80104966:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104969:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010496d:	75 0a                	jne    80104979 <fork+0x21>
    return -1;
8010496f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104974:	e9 d3 01 00 00       	jmp    80104b4c <fork+0x1f4>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104979:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010497f:	8b 10                	mov    (%eax),%edx
80104981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104987:	8b 40 04             	mov    0x4(%eax),%eax
8010498a:	83 ec 08             	sub    $0x8,%esp
8010498d:	52                   	push   %edx
8010498e:	50                   	push   %eax
8010498f:	e8 91 43 00 00       	call   80108d25 <copyuvm>
80104994:	83 c4 10             	add    $0x10,%esp
80104997:	89 c2                	mov    %eax,%edx
80104999:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010499c:	89 50 04             	mov    %edx,0x4(%eax)
8010499f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a2:	8b 40 04             	mov    0x4(%eax),%eax
801049a5:	85 c0                	test   %eax,%eax
801049a7:	75 30                	jne    801049d9 <fork+0x81>
    kfree(np->kstack);
801049a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ac:	8b 40 08             	mov    0x8(%eax),%eax
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	50                   	push   %eax
801049b3:	e8 78 e1 ff ff       	call   80102b30 <kfree>
801049b8:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801049bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801049c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801049cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049d4:	e9 73 01 00 00       	jmp    80104b4c <fork+0x1f4>
  }
  np->sz = proc->sz;
801049d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049df:	8b 10                	mov    (%eax),%edx
801049e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049e4:	89 10                	mov    %edx,(%eax)
  np->sstack = proc->sstack;
801049e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ec:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
801049f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f5:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)

  np->parent = proc;
801049fb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a02:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a05:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104a08:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a0b:	8b 50 18             	mov    0x18(%eax),%edx
80104a0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a14:	8b 40 18             	mov    0x18(%eax),%eax
80104a17:	89 c3                	mov    %eax,%ebx
80104a19:	b8 13 00 00 00       	mov    $0x13,%eax
80104a1e:	89 d7                	mov    %edx,%edi
80104a20:	89 de                	mov    %ebx,%esi
80104a22:	89 c1                	mov    %eax,%ecx
80104a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104a26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a29:	8b 40 18             	mov    0x18(%eax),%eax
80104a2c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104a33:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104a3a:	eb 43                	jmp    80104a7f <fork+0x127>
    if(proc->ofile[i])
80104a3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a45:	83 c2 08             	add    $0x8,%edx
80104a48:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a4c:	85 c0                	test   %eax,%eax
80104a4e:	74 2b                	je     80104a7b <fork+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
80104a50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a59:	83 c2 08             	add    $0x8,%edx
80104a5c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a60:	83 ec 0c             	sub    $0xc,%esp
80104a63:	50                   	push   %eax
80104a64:	e8 84 c5 ff ff       	call   80100fed <filedup>
80104a69:	83 c4 10             	add    $0x10,%esp
80104a6c:	89 c1                	mov    %eax,%ecx
80104a6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a71:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a74:	83 c2 08             	add    $0x8,%edx
80104a77:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104a7b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a7f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104a83:	7e b7                	jle    80104a3c <fork+0xe4>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++)
80104a85:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104a8c:	eb 43                	jmp    80104ad1 <fork+0x179>
    if(proc->osemaphore[i])
80104a8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a97:	83 c2 20             	add    $0x20,%edx
80104a9a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a9e:	85 c0                	test   %eax,%eax
80104aa0:	74 2b                	je     80104acd <fork+0x175>
      np->osemaphore[i] = semdup(proc->osemaphore[i]);
80104aa2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104aab:	83 c2 20             	add    $0x20,%edx
80104aae:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ab2:	83 ec 0c             	sub    $0xc,%esp
80104ab5:	50                   	push   %eax
80104ab6:	e8 71 0c 00 00       	call   8010572c <semdup>
80104abb:	83 c4 10             	add    $0x10,%esp
80104abe:	89 c1                	mov    %eax,%ecx
80104ac0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ac3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ac6:	83 c2 20             	add    $0x20,%edx
80104ac9:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++)
80104acd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104ad1:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
80104ad5:	7e b7                	jle    80104a8e <fork+0x136>
    if(proc->osemaphore[i])
      np->osemaphore[i] = semdup(proc->osemaphore[i]);

  np->cwd = idup(proc->cwd);
80104ad7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104add:	8b 40 68             	mov    0x68(%eax),%eax
80104ae0:	83 ec 0c             	sub    $0xc,%esp
80104ae3:	50                   	push   %eax
80104ae4:	e8 f0 cd ff ff       	call   801018d9 <idup>
80104ae9:	83 c4 10             	add    $0x10,%esp
80104aec:	89 c2                	mov    %eax,%edx
80104aee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104af1:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104af4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afa:	8d 50 6c             	lea    0x6c(%eax),%edx
80104afd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b00:	83 c0 6c             	add    $0x6c,%eax
80104b03:	83 ec 04             	sub    $0x4,%esp
80104b06:	6a 10                	push   $0x10
80104b08:	52                   	push   %edx
80104b09:	50                   	push   %eax
80104b0a:	e8 2e 11 00 00       	call   80105c3d <safestrcpy>
80104b0f:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b15:	8b 40 10             	mov    0x10(%eax),%eax
80104b18:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104b1b:	83 ec 0c             	sub    $0xc,%esp
80104b1e:	68 80 39 11 80       	push   $0x80113980
80104b23:	e8 af 0c 00 00       	call   801057d7 <acquire>
80104b28:	83 c4 10             	add    $0x10,%esp
  make_runnable(np);
80104b2b:	83 ec 0c             	sub    $0xc,%esp
80104b2e:	ff 75 e0             	pushl  -0x20(%ebp)
80104b31:	e8 98 f8 ff ff       	call   801043ce <make_runnable>
80104b36:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104b39:	83 ec 0c             	sub    $0xc,%esp
80104b3c:	68 80 39 11 80       	push   $0x80113980
80104b41:	e8 f8 0c 00 00       	call   8010583e <release>
80104b46:	83 c4 10             	add    $0x10,%esp

  return pid;
80104b49:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b4f:	5b                   	pop    %ebx
80104b50:	5e                   	pop    %esi
80104b51:	5f                   	pop    %edi
80104b52:	5d                   	pop    %ebp
80104b53:	c3                   	ret    

80104b54 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104b54:	55                   	push   %ebp
80104b55:	89 e5                	mov    %esp,%ebp
80104b57:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd,idsem;

  if(proc == initproc)
80104b5a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b61:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104b66:	39 c2                	cmp    %eax,%edx
80104b68:	75 0d                	jne    80104b77 <exit+0x23>
    panic("init exiting");
80104b6a:	83 ec 0c             	sub    $0xc,%esp
80104b6d:	68 1d 93 10 80       	push   $0x8010931d
80104b72:	e8 ef b9 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b77:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104b7e:	eb 48                	jmp    80104bc8 <exit+0x74>
    if(proc->ofile[fd]){
80104b80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b86:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b89:	83 c2 08             	add    $0x8,%edx
80104b8c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b90:	85 c0                	test   %eax,%eax
80104b92:	74 30                	je     80104bc4 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b9d:	83 c2 08             	add    $0x8,%edx
80104ba0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ba4:	83 ec 0c             	sub    $0xc,%esp
80104ba7:	50                   	push   %eax
80104ba8:	e8 91 c4 ff ff       	call   8010103e <fileclose>
80104bad:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104bb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bb9:	83 c2 08             	add    $0x8,%edx
80104bbc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104bc3:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104bc4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104bc8:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104bcc:	7e b2                	jle    80104b80 <exit+0x2c>
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104bce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104bd5:	eb 48                	jmp    80104c1f <exit+0xcb>
    if(proc->osemaphore[idsem]){
80104bd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104be0:	83 c2 20             	add    $0x20,%edx
80104be3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104be7:	85 c0                	test   %eax,%eax
80104be9:	74 30                	je     80104c1b <exit+0xc7>
      semclose(proc->osemaphore[idsem]);
80104beb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bf4:	83 c2 20             	add    $0x20,%edx
80104bf7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bfb:	83 ec 0c             	sub    $0xc,%esp
80104bfe:	50                   	push   %eax
80104bff:	e8 d9 0a 00 00       	call   801056dd <semclose>
80104c04:	83 c4 10             	add    $0x10,%esp
      proc->osemaphore[idsem] = 0;
80104c07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c10:	83 c2 20             	add    $0x20,%edx
80104c13:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104c1a:	00 
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104c1b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104c1f:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80104c23:	7e b2                	jle    80104bd7 <exit+0x83>
      semclose(proc->osemaphore[idsem]);
      proc->osemaphore[idsem] = 0;
    }
  }

  begin_op();
80104c25:	e8 92 e8 ff ff       	call   801034bc <begin_op>
  iput(proc->cwd);
80104c2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c30:	8b 40 68             	mov    0x68(%eax),%eax
80104c33:	83 ec 0c             	sub    $0xc,%esp
80104c36:	50                   	push   %eax
80104c37:	e8 a1 ce ff ff       	call   80101add <iput>
80104c3c:	83 c4 10             	add    $0x10,%esp
  end_op();
80104c3f:	e8 04 e9 ff ff       	call   80103548 <end_op>
  proc->cwd = 0;
80104c44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c4a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104c51:	83 ec 0c             	sub    $0xc,%esp
80104c54:	68 80 39 11 80       	push   $0x80113980
80104c59:	e8 79 0b 00 00       	call   801057d7 <acquire>
80104c5e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104c61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c67:	8b 40 14             	mov    0x14(%eax),%eax
80104c6a:	83 ec 0c             	sub    $0xc,%esp
80104c6d:	50                   	push   %eax
80104c6e:	e8 54 04 00 00       	call   801050c7 <wakeup1>
80104c73:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c76:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104c7d:	eb 3f                	jmp    80104cbe <exit+0x16a>
    if(p->parent == proc){
80104c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c82:	8b 50 14             	mov    0x14(%eax),%edx
80104c85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c8b:	39 c2                	cmp    %eax,%edx
80104c8d:	75 28                	jne    80104cb7 <exit+0x163>
      p->parent = initproc;
80104c8f:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9e:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca1:	83 f8 05             	cmp    $0x5,%eax
80104ca4:	75 11                	jne    80104cb7 <exit+0x163>
        wakeup1(initproc);
80104ca6:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104cab:	83 ec 0c             	sub    $0xc,%esp
80104cae:	50                   	push   %eax
80104caf:	e8 13 04 00 00       	call   801050c7 <wakeup1>
80104cb4:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cb7:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104cbe:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
80104cc5:	72 b8                	jb     80104c7f <exit+0x12b>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104cc7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ccd:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104cd4:	e8 f4 01 00 00       	call   80104ecd <sched>
  panic("zombie exit");
80104cd9:	83 ec 0c             	sub    $0xc,%esp
80104cdc:	68 2a 93 10 80       	push   $0x8010932a
80104ce1:	e8 80 b8 ff ff       	call   80100566 <panic>

80104ce6 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104cec:	83 ec 0c             	sub    $0xc,%esp
80104cef:	68 80 39 11 80       	push   $0x80113980
80104cf4:	e8 de 0a 00 00       	call   801057d7 <acquire>
80104cf9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104cfc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d03:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104d0a:	e9 a9 00 00 00       	jmp    80104db8 <wait+0xd2>
      if(p->parent != proc)
80104d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d12:	8b 50 14             	mov    0x14(%eax),%edx
80104d15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1b:	39 c2                	cmp    %eax,%edx
80104d1d:	0f 85 8d 00 00 00    	jne    80104db0 <wait+0xca>
        continue;
      havekids = 1;
80104d23:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d30:	83 f8 05             	cmp    $0x5,%eax
80104d33:	75 7c                	jne    80104db1 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d38:	8b 40 10             	mov    0x10(%eax),%eax
80104d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d41:	8b 40 08             	mov    0x8(%eax),%eax
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	50                   	push   %eax
80104d48:	e8 e3 dd ff ff       	call   80102b30 <kfree>
80104d4d:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5d:	8b 40 04             	mov    0x4(%eax),%eax
80104d60:	83 ec 0c             	sub    $0xc,%esp
80104d63:	50                   	push   %eax
80104d64:	e8 db 3e 00 00       	call   80108c44 <freevm>
80104d69:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d83:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d94:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104d9b:	83 ec 0c             	sub    $0xc,%esp
80104d9e:	68 80 39 11 80       	push   $0x80113980
80104da3:	e8 96 0a 00 00       	call   8010583e <release>
80104da8:	83 c4 10             	add    $0x10,%esp
        return pid;
80104dab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104dae:	eb 5b                	jmp    80104e0b <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104db0:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db1:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104db8:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
80104dbf:	0f 82 4a ff ff ff    	jb     80104d0f <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104dc5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104dc9:	74 0d                	je     80104dd8 <wait+0xf2>
80104dcb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd1:	8b 40 24             	mov    0x24(%eax),%eax
80104dd4:	85 c0                	test   %eax,%eax
80104dd6:	74 17                	je     80104def <wait+0x109>
      release(&ptable.lock);
80104dd8:	83 ec 0c             	sub    $0xc,%esp
80104ddb:	68 80 39 11 80       	push   $0x80113980
80104de0:	e8 59 0a 00 00       	call   8010583e <release>
80104de5:	83 c4 10             	add    $0x10,%esp
      return -1;
80104de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ded:	eb 1c                	jmp    80104e0b <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104def:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df5:	83 ec 08             	sub    $0x8,%esp
80104df8:	68 80 39 11 80       	push   $0x80113980
80104dfd:	50                   	push   %eax
80104dfe:	e8 18 02 00 00       	call   8010501b <sleep>
80104e03:	83 c4 10             	add    $0x10,%esp
  }
80104e06:	e9 f1 fe ff ff       	jmp    80104cfc <wait+0x16>
}
80104e0b:	c9                   	leave  
80104e0c:	c3                   	ret    

80104e0d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104e0d:	55                   	push   %ebp
80104e0e:	89 e5                	mov    %esp,%ebp
80104e10:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int l;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104e13:	e8 af f5 ff ff       	call   801043c7 <sti>

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
80104e18:	83 ec 0c             	sub    $0xc,%esp
80104e1b:	68 80 39 11 80       	push   $0x80113980
80104e20:	e8 b2 09 00 00       	call   801057d7 <acquire>
80104e25:	83 c4 10             	add    $0x10,%esp
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104e28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e2f:	eb 7d                	jmp    80104eae <scheduler+0xa1>
      if (!ptable.mlf[l].first)
80104e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e34:	05 06 05 00 00       	add    $0x506,%eax
80104e39:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104e40:	85 c0                	test   %eax,%eax
80104e42:	75 06                	jne    80104e4a <scheduler+0x3d>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104e44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e48:	eb 64                	jmp    80104eae <scheduler+0xa1>
      if (!ptable.mlf[l].first)
        continue;
      p=unqueue(l);
80104e4a:	83 ec 0c             	sub    $0xc,%esp
80104e4d:	ff 75 f4             	pushl  -0xc(%ebp)
80104e50:	e8 11 f6 ff ff       	call   80104466 <unqueue>
80104e55:	83 c4 10             	add    $0x10,%esp
80104e58:	89 45 f0             	mov    %eax,-0x10(%ebp)


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e5e:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4


      switchuvm(p);
80104e64:	83 ec 0c             	sub    $0xc,%esp
80104e67:	ff 75 f0             	pushl  -0x10(%ebp)
80104e6a:	e8 8f 39 00 00       	call   801087fe <switchuvm>
80104e6f:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e75:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104e7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e82:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e85:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e8c:	83 c2 04             	add    $0x4,%edx
80104e8f:	83 ec 08             	sub    $0x8,%esp
80104e92:	50                   	push   %eax
80104e93:	52                   	push   %edx
80104e94:	e8 15 0e 00 00       	call   80105cae <swtch>
80104e99:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104e9c:	e8 40 39 00 00       	call   801087e1 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104ea1:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ea8:	00 00 00 00 
      break;
80104eac:	eb 0a                	jmp    80104eb8 <scheduler+0xab>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104eae:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80104eb2:	0f 8e 79 ff ff ff    	jle    80104e31 <scheduler+0x24>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      break;
    }
    release(&ptable.lock);
80104eb8:	83 ec 0c             	sub    $0xc,%esp
80104ebb:	68 80 39 11 80       	push   $0x80113980
80104ec0:	e8 79 09 00 00       	call   8010583e <release>
80104ec5:	83 c4 10             	add    $0x10,%esp
  }
80104ec8:	e9 46 ff ff ff       	jmp    80104e13 <scheduler+0x6>

80104ecd <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ecd:	55                   	push   %ebp
80104ece:	89 e5                	mov    %esp,%ebp
80104ed0:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104ed3:	83 ec 0c             	sub    $0xc,%esp
80104ed6:	68 80 39 11 80       	push   $0x80113980
80104edb:	e8 2a 0a 00 00       	call   8010590a <holding>
80104ee0:	83 c4 10             	add    $0x10,%esp
80104ee3:	85 c0                	test   %eax,%eax
80104ee5:	75 0d                	jne    80104ef4 <sched+0x27>
    panic("sched ptable.lock");
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	68 36 93 10 80       	push   $0x80109336
80104eef:	e8 72 b6 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104ef4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104efa:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f00:	83 f8 01             	cmp    $0x1,%eax
80104f03:	74 0d                	je     80104f12 <sched+0x45>
    panic("sched locks");
80104f05:	83 ec 0c             	sub    $0xc,%esp
80104f08:	68 48 93 10 80       	push   $0x80109348
80104f0d:	e8 54 b6 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104f12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f18:	8b 40 0c             	mov    0xc(%eax),%eax
80104f1b:	83 f8 04             	cmp    $0x4,%eax
80104f1e:	75 0d                	jne    80104f2d <sched+0x60>
    panic("sched running");
80104f20:	83 ec 0c             	sub    $0xc,%esp
80104f23:	68 54 93 10 80       	push   $0x80109354
80104f28:	e8 39 b6 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104f2d:	e8 85 f4 ff ff       	call   801043b7 <readeflags>
80104f32:	25 00 02 00 00       	and    $0x200,%eax
80104f37:	85 c0                	test   %eax,%eax
80104f39:	74 0d                	je     80104f48 <sched+0x7b>
    panic("sched interruptible");
80104f3b:	83 ec 0c             	sub    $0xc,%esp
80104f3e:	68 62 93 10 80       	push   $0x80109362
80104f43:	e8 1e b6 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104f48:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f4e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104f57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f5d:	8b 40 04             	mov    0x4(%eax),%eax
80104f60:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f67:	83 c2 1c             	add    $0x1c,%edx
80104f6a:	83 ec 08             	sub    $0x8,%esp
80104f6d:	50                   	push   %eax
80104f6e:	52                   	push   %edx
80104f6f:	e8 3a 0d 00 00       	call   80105cae <swtch>
80104f74:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104f77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f80:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104f86:	90                   	nop
80104f87:	c9                   	leave  
80104f88:	c3                   	ret    

80104f89 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104f89:	55                   	push   %ebp
80104f8a:	89 e5                	mov    %esp,%ebp
80104f8c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104f8f:	83 ec 0c             	sub    $0xc,%esp
80104f92:	68 80 39 11 80       	push   $0x80113980
80104f97:	e8 3b 08 00 00       	call   801057d7 <acquire>
80104f9c:	83 c4 10             	add    $0x10,%esp
  if(proc->priority<MLFLEVELS-1)
80104f9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa5:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104fa9:	66 83 f8 02          	cmp    $0x2,%ax
80104fad:	77 11                	ja     80104fc0 <yield+0x37>
    proc->priority++;
80104faf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb5:	0f b7 50 7e          	movzwl 0x7e(%eax),%edx
80104fb9:	83 c2 01             	add    $0x1,%edx
80104fbc:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(proc);
80104fc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc6:	83 ec 0c             	sub    $0xc,%esp
80104fc9:	50                   	push   %eax
80104fca:	e8 ff f3 ff ff       	call   801043ce <make_runnable>
80104fcf:	83 c4 10             	add    $0x10,%esp
  sched();
80104fd2:	e8 f6 fe ff ff       	call   80104ecd <sched>
  release(&ptable.lock);
80104fd7:	83 ec 0c             	sub    $0xc,%esp
80104fda:	68 80 39 11 80       	push   $0x80113980
80104fdf:	e8 5a 08 00 00       	call   8010583e <release>
80104fe4:	83 c4 10             	add    $0x10,%esp
}
80104fe7:	90                   	nop
80104fe8:	c9                   	leave  
80104fe9:	c3                   	ret    

80104fea <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104fea:	55                   	push   %ebp
80104feb:	89 e5                	mov    %esp,%ebp
80104fed:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ff0:	83 ec 0c             	sub    $0xc,%esp
80104ff3:	68 80 39 11 80       	push   $0x80113980
80104ff8:	e8 41 08 00 00       	call   8010583e <release>
80104ffd:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105000:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105005:	85 c0                	test   %eax,%eax
80105007:	74 0f                	je     80105018 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105009:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105010:	00 00 00 
    initlog();
80105013:	e8 7e e2 ff ff       	call   80103296 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80105018:	90                   	nop
80105019:	c9                   	leave  
8010501a:	c3                   	ret    

8010501b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010501b:	55                   	push   %ebp
8010501c:	89 e5                	mov    %esp,%ebp
8010501e:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105021:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105027:	85 c0                	test   %eax,%eax
80105029:	75 0d                	jne    80105038 <sleep+0x1d>
    panic("sleep");
8010502b:	83 ec 0c             	sub    $0xc,%esp
8010502e:	68 76 93 10 80       	push   $0x80109376
80105033:	e8 2e b5 ff ff       	call   80100566 <panic>

  if(lk == 0)
80105038:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010503c:	75 0d                	jne    8010504b <sleep+0x30>
    panic("sleep without lk");
8010503e:	83 ec 0c             	sub    $0xc,%esp
80105041:	68 7c 93 10 80       	push   $0x8010937c
80105046:	e8 1b b5 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010504b:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105052:	74 1e                	je     80105072 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105054:	83 ec 0c             	sub    $0xc,%esp
80105057:	68 80 39 11 80       	push   $0x80113980
8010505c:	e8 76 07 00 00       	call   801057d7 <acquire>
80105061:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105064:	83 ec 0c             	sub    $0xc,%esp
80105067:	ff 75 0c             	pushl  0xc(%ebp)
8010506a:	e8 cf 07 00 00       	call   8010583e <release>
8010506f:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105072:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105078:	8b 55 08             	mov    0x8(%ebp),%edx
8010507b:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010507e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105084:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010508b:	e8 3d fe ff ff       	call   80104ecd <sched>

  // Tidy up.
  proc->chan = 0;
80105090:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105096:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010509d:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801050a4:	74 1e                	je     801050c4 <sleep+0xa9>
    release(&ptable.lock);
801050a6:	83 ec 0c             	sub    $0xc,%esp
801050a9:	68 80 39 11 80       	push   $0x80113980
801050ae:	e8 8b 07 00 00       	call   8010583e <release>
801050b3:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801050b6:	83 ec 0c             	sub    $0xc,%esp
801050b9:	ff 75 0c             	pushl  0xc(%ebp)
801050bc:	e8 16 07 00 00       	call   801057d7 <acquire>
801050c1:	83 c4 10             	add    $0x10,%esp
  }
}
801050c4:	90                   	nop
801050c5:	c9                   	leave  
801050c6:	c3                   	ret    

801050c7 <wakeup1>:
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
// If applicable, the priority of the process increases.
static void
wakeup1(void *chan)
{
801050c7:	55                   	push   %ebp
801050c8:	89 e5                	mov    %esp,%ebp
801050ca:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050cd:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
801050d4:	eb 45                	jmp    8010511b <wakeup1+0x54>
    if(p->state == SLEEPING && p->chan == chan){
801050d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050d9:	8b 40 0c             	mov    0xc(%eax),%eax
801050dc:	83 f8 02             	cmp    $0x2,%eax
801050df:	75 33                	jne    80105114 <wakeup1+0x4d>
801050e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050e4:	8b 40 20             	mov    0x20(%eax),%eax
801050e7:	3b 45 08             	cmp    0x8(%ebp),%eax
801050ea:	75 28                	jne    80105114 <wakeup1+0x4d>
      if (p->priority>0)
801050ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ef:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801050f3:	66 85 c0             	test   %ax,%ax
801050f6:	74 11                	je     80105109 <wakeup1+0x42>
        p->priority--;
801050f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050fb:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801050ff:	8d 50 ff             	lea    -0x1(%eax),%edx
80105102:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105105:	66 89 50 7e          	mov    %dx,0x7e(%eax)
      make_runnable(p);
80105109:	ff 75 fc             	pushl  -0x4(%ebp)
8010510c:	e8 bd f2 ff ff       	call   801043ce <make_runnable>
80105111:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105114:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
8010511b:	81 7d fc b4 61 11 80 	cmpl   $0x801161b4,-0x4(%ebp)
80105122:	72 b2                	jb     801050d6 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan){
      if (p->priority>0)
        p->priority--;
      make_runnable(p);
    }
}
80105124:	90                   	nop
80105125:	c9                   	leave  
80105126:	c3                   	ret    

80105127 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
8010512a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010512d:	83 ec 0c             	sub    $0xc,%esp
80105130:	68 80 39 11 80       	push   $0x80113980
80105135:	e8 9d 06 00 00       	call   801057d7 <acquire>
8010513a:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010513d:	83 ec 0c             	sub    $0xc,%esp
80105140:	ff 75 08             	pushl  0x8(%ebp)
80105143:	e8 7f ff ff ff       	call   801050c7 <wakeup1>
80105148:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010514b:	83 ec 0c             	sub    $0xc,%esp
8010514e:	68 80 39 11 80       	push   $0x80113980
80105153:	e8 e6 06 00 00       	call   8010583e <release>
80105158:	83 c4 10             	add    $0x10,%esp
}
8010515b:	90                   	nop
8010515c:	c9                   	leave  
8010515d:	c3                   	ret    

8010515e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010515e:	55                   	push   %ebp
8010515f:	89 e5                	mov    %esp,%ebp
80105161:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105164:	83 ec 0c             	sub    $0xc,%esp
80105167:	68 80 39 11 80       	push   $0x80113980
8010516c:	e8 66 06 00 00       	call   801057d7 <acquire>
80105171:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105174:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010517b:	eb 4c                	jmp    801051c9 <kill+0x6b>
    if(p->pid == pid){
8010517d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105180:	8b 40 10             	mov    0x10(%eax),%eax
80105183:	3b 45 08             	cmp    0x8(%ebp),%eax
80105186:	75 3a                	jne    801051c2 <kill+0x64>
      p->killed = 1;
80105188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105195:	8b 40 0c             	mov    0xc(%eax),%eax
80105198:	83 f8 02             	cmp    $0x2,%eax
8010519b:	75 0e                	jne    801051ab <kill+0x4d>
        make_runnable(p);
8010519d:	83 ec 0c             	sub    $0xc,%esp
801051a0:	ff 75 f4             	pushl  -0xc(%ebp)
801051a3:	e8 26 f2 ff ff       	call   801043ce <make_runnable>
801051a8:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
801051ab:	83 ec 0c             	sub    $0xc,%esp
801051ae:	68 80 39 11 80       	push   $0x80113980
801051b3:	e8 86 06 00 00       	call   8010583e <release>
801051b8:	83 c4 10             	add    $0x10,%esp
      return 0;
801051bb:	b8 00 00 00 00       	mov    $0x0,%eax
801051c0:	eb 25                	jmp    801051e7 <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051c2:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801051c9:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
801051d0:	72 ab                	jb     8010517d <kill+0x1f>
        make_runnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801051d2:	83 ec 0c             	sub    $0xc,%esp
801051d5:	68 80 39 11 80       	push   $0x80113980
801051da:	e8 5f 06 00 00       	call   8010583e <release>
801051df:	83 c4 10             	add    $0x10,%esp
  return -1;
801051e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051e7:	c9                   	leave  
801051e8:	c3                   	ret    

801051e9 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801051e9:	55                   	push   %ebp
801051ea:	89 e5                	mov    %esp,%ebp
801051ec:	53                   	push   %ebx
801051ed:	83 ec 44             	sub    $0x44,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051f0:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
801051f7:	e9 f6 00 00 00       	jmp    801052f2 <procdump+0x109>
    if(p->state == UNUSED)
801051fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ff:	8b 40 0c             	mov    0xc(%eax),%eax
80105202:	85 c0                	test   %eax,%eax
80105204:	0f 84 e0 00 00 00    	je     801052ea <procdump+0x101>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010520a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520d:	8b 40 0c             	mov    0xc(%eax),%eax
80105210:	83 f8 05             	cmp    $0x5,%eax
80105213:	77 23                	ja     80105238 <procdump+0x4f>
80105215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105218:	8b 40 0c             	mov    0xc(%eax),%eax
8010521b:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105222:	85 c0                	test   %eax,%eax
80105224:	74 12                	je     80105238 <procdump+0x4f>
      state = states[p->state];
80105226:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105229:	8b 40 0c             	mov    0xc(%eax),%eax
8010522c:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105233:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105236:	eb 07                	jmp    8010523f <procdump+0x56>
    else
      state = "???";
80105238:	c7 45 ec 8d 93 10 80 	movl   $0x8010938d,-0x14(%ebp)
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
8010523f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105242:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80105249:	0f b7 c8             	movzwl %ax,%ecx
8010524c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524f:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105253:	0f b7 d0             	movzwl %ax,%edx
80105256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105259:	8d 58 6c             	lea    0x6c(%eax),%ebx
8010525c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010525f:	8b 40 10             	mov    0x10(%eax),%eax
80105262:	83 ec 08             	sub    $0x8,%esp
80105265:	51                   	push   %ecx
80105266:	52                   	push   %edx
80105267:	53                   	push   %ebx
80105268:	ff 75 ec             	pushl  -0x14(%ebp)
8010526b:	50                   	push   %eax
8010526c:	68 91 93 10 80       	push   $0x80109391
80105271:	e8 50 b1 ff ff       	call   801003c6 <cprintf>
80105276:	83 c4 20             	add    $0x20,%esp
    if(p->state == SLEEPING){
80105279:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527c:	8b 40 0c             	mov    0xc(%eax),%eax
8010527f:	83 f8 02             	cmp    $0x2,%eax
80105282:	75 54                	jne    801052d8 <procdump+0xef>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105287:	8b 40 1c             	mov    0x1c(%eax),%eax
8010528a:	8b 40 0c             	mov    0xc(%eax),%eax
8010528d:	83 c0 08             	add    $0x8,%eax
80105290:	89 c2                	mov    %eax,%edx
80105292:	83 ec 08             	sub    $0x8,%esp
80105295:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105298:	50                   	push   %eax
80105299:	52                   	push   %edx
8010529a:	e8 f1 05 00 00       	call   80105890 <getcallerpcs>
8010529f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801052a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052a9:	eb 1c                	jmp    801052c7 <procdump+0xde>
        cprintf(" %p", pc[i]);
801052ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ae:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052b2:	83 ec 08             	sub    $0x8,%esp
801052b5:	50                   	push   %eax
801052b6:	68 ad 93 10 80       	push   $0x801093ad
801052bb:	e8 06 b1 ff ff       	call   801003c6 <cprintf>
801052c0:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801052c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052c7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801052cb:	7f 0b                	jg     801052d8 <procdump+0xef>
801052cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052d4:	85 c0                	test   %eax,%eax
801052d6:	75 d3                	jne    801052ab <procdump+0xc2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801052d8:	83 ec 0c             	sub    $0xc,%esp
801052db:	68 b1 93 10 80       	push   $0x801093b1
801052e0:	e8 e1 b0 ff ff       	call   801003c6 <cprintf>
801052e5:	83 c4 10             	add    $0x10,%esp
801052e8:	eb 01                	jmp    801052eb <procdump+0x102>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801052ea:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052eb:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
801052f2:	81 7d f0 b4 61 11 80 	cmpl   $0x801161b4,-0x10(%ebp)
801052f9:	0f 82 fd fe ff ff    	jb     801051fc <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801052ff:	90                   	nop
80105300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105303:	c9                   	leave  
80105304:	c3                   	ret    

80105305 <seminit>:
} stable;

// Initializes the LOCK of the semaphore table.
void
seminit(void)
{
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
80105308:	83 ec 08             	sub    $0x8,%esp
  initlock(&stable.lock, "stable");
8010530b:	83 ec 08             	sub    $0x8,%esp
8010530e:	68 dd 93 10 80       	push   $0x801093dd
80105313:	68 e0 61 11 80       	push   $0x801161e0
80105318:	e8 98 04 00 00       	call   801057b5 <initlock>
8010531d:	83 c4 10             	add    $0x10,%esp
}
80105320:	90                   	nop
80105321:	c9                   	leave  
80105322:	c3                   	ret    

80105323 <allocinprocess>:

// Assigns a place in the open semaphore array of the process and returns the position.
static int
allocinprocess()
{
80105323:	55                   	push   %ebp
80105324:	89 e5                	mov    %esp,%ebp
80105326:	83 ec 10             	sub    $0x10,%esp
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
80105329:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105330:	eb 22                	jmp    80105354 <allocinprocess+0x31>
    s=proc->osemaphore[i];
80105332:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105338:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010533b:	83 c2 20             	add    $0x20,%edx
8010533e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105342:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(!s)
80105345:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
80105349:	75 05                	jne    80105350 <allocinprocess+0x2d>
      return i;
8010534b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534e:	eb 0f                	jmp    8010535f <allocinprocess+0x3c>
allocinprocess()
{
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
80105350:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105354:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80105358:	7e d8                	jle    80105332 <allocinprocess+0xf>
    s=proc->osemaphore[i];
    if(!s)
      return i;
  }
  return -1;
8010535a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010535f:	c9                   	leave  
80105360:	c3                   	ret    

80105361 <searchinprocess>:

// Find the id passed as an argument between the ids of the open semaphores of the process and return its position.
static int
searchinprocess(int id)
{
80105361:	55                   	push   %ebp
80105362:	89 e5                	mov    %esp,%ebp
80105364:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
80105367:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010536e:	eb 2c                	jmp    8010539c <searchinprocess+0x3b>
    s=proc->osemaphore[i];
80105370:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105376:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105379:	83 c2 20             	add    $0x20,%edx
8010537c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105380:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s && s->id==id){
80105383:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
80105387:	74 0f                	je     80105398 <searchinprocess+0x37>
80105389:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010538c:	8b 00                	mov    (%eax),%eax
8010538e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105391:	75 05                	jne    80105398 <searchinprocess+0x37>
        return i;
80105393:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105396:	eb 0f                	jmp    801053a7 <searchinprocess+0x46>
searchinprocess(int id)
{
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
80105398:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010539c:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801053a0:	7e ce                	jle    80105370 <searchinprocess+0xf>
    s=proc->osemaphore[i];
    if(s && s->id==id){
        return i;
    }
  }
  return -1;
801053a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053a7:	c9                   	leave  
801053a8:	c3                   	ret    

801053a9 <allocinsystem>:

// Assign a place in the semaphore table of the system and return a pointer to it.
// if the table is full, return null (0)
static struct semaphore*
allocinsystem()
{
801053a9:	55                   	push   %ebp
801053aa:	89 e5                	mov    %esp,%ebp
801053ac:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
801053af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801053b6:	eb 2d                	jmp    801053e5 <allocinsystem+0x3c>
    s=&stable.sem[i];
801053b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053bb:	89 d0                	mov    %edx,%eax
801053bd:	01 c0                	add    %eax,%eax
801053bf:	01 d0                	add    %edx,%eax
801053c1:	c1 e0 02             	shl    $0x2,%eax
801053c4:	83 c0 30             	add    $0x30,%eax
801053c7:	05 e0 61 11 80       	add    $0x801161e0,%eax
801053cc:	83 c0 04             	add    $0x4,%eax
801053cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s->references==0)
801053d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d5:	8b 40 04             	mov    0x4(%eax),%eax
801053d8:	85 c0                	test   %eax,%eax
801053da:	75 05                	jne    801053e1 <allocinsystem+0x38>
      return s;
801053dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053df:	eb 0f                	jmp    801053f0 <allocinsystem+0x47>
static struct semaphore*
allocinsystem()
{
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
801053e1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053e5:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
801053e9:	7e cd                	jle    801053b8 <allocinsystem+0xf>
    s=&stable.sem[i];
    if(s->references==0)
      return s;
  }
  return 0;
801053eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053f0:	c9                   	leave  
801053f1:	c3                   	ret    

801053f2 <semget>:
// if there is no place in the system's semaphore table, return -3.
// if semid> 0 and the semaphore is not in use, return -1.
// if semid <-1 or semid> MAXSEM, return -4.
int
semget(int semid, int initvalue)
{
801053f2:	55                   	push   %ebp
801053f3:	89 e5                	mov    %esp,%ebp
801053f5:	83 ec 18             	sub    $0x18,%esp
  int position=0,retvalue;
801053f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  struct semaphore* s;

  if(semid<-1 || semid>=MAXSEM)
801053ff:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
80105403:	7c 06                	jl     8010540b <semget+0x19>
80105405:	83 7d 08 3f          	cmpl   $0x3f,0x8(%ebp)
80105409:	7e 0a                	jle    80105415 <semget+0x23>
    return -4;
8010540b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
80105410:	e9 0d 01 00 00       	jmp    80105522 <semget+0x130>
  acquire(&stable.lock);
80105415:	83 ec 0c             	sub    $0xc,%esp
80105418:	68 e0 61 11 80       	push   $0x801161e0
8010541d:	e8 b5 03 00 00       	call   801057d7 <acquire>
80105422:	83 c4 10             	add    $0x10,%esp
  position=allocinprocess();
80105425:	e8 f9 fe ff ff       	call   80105323 <allocinprocess>
8010542a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(position==-1){
8010542d:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105431:	75 0c                	jne    8010543f <semget+0x4d>
    retvalue=-2;
80105433:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retget;
8010543a:	e9 d0 00 00 00       	jmp    8010550f <semget+0x11d>
  }
  if(semid==-1){
8010543f:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
80105443:	75 47                	jne    8010548c <semget+0x9a>
    s=allocinsystem();
80105445:	e8 5f ff ff ff       	call   801053a9 <allocinsystem>
8010544a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!s){
8010544d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105451:	75 0c                	jne    8010545f <semget+0x6d>
      retvalue=-3;
80105453:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
      goto retget;
8010545a:	e9 b0 00 00 00       	jmp    8010550f <semget+0x11d>
    }
    s->id=s-stable.sem;
8010545f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105462:	ba 14 62 11 80       	mov    $0x80116214,%edx
80105467:	29 d0                	sub    %edx,%eax
80105469:	c1 f8 02             	sar    $0x2,%eax
8010546c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
80105472:	89 c2                	mov    %eax,%edx
80105474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105477:	89 10                	mov    %edx,(%eax)
    s->value=initvalue;
80105479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010547c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010547f:	89 50 08             	mov    %edx,0x8(%eax)
    retvalue=s->id;
80105482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105485:	8b 00                	mov    (%eax),%eax
80105487:	89 45 f4             	mov    %eax,-0xc(%ebp)
    goto found;
8010548a:	eb 61                	jmp    801054ed <semget+0xfb>
  }
  if(semid>=0){
8010548c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105490:	78 5b                	js     801054ed <semget+0xfb>
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
80105492:	c7 45 f0 14 62 11 80 	movl   $0x80116214,-0x10(%ebp)
80105499:	eb 3f                	jmp    801054da <semget+0xe8>
      if(s->id==semid && ((s->references)>0)){
8010549b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010549e:	8b 00                	mov    (%eax),%eax
801054a0:	3b 45 08             	cmp    0x8(%ebp),%eax
801054a3:	75 14                	jne    801054b9 <semget+0xc7>
801054a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a8:	8b 40 04             	mov    0x4(%eax),%eax
801054ab:	85 c0                	test   %eax,%eax
801054ad:	7e 0a                	jle    801054b9 <semget+0xc7>
        retvalue=s->id;
801054af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b2:	8b 00                	mov    (%eax),%eax
801054b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto found;
801054b7:	eb 34                	jmp    801054ed <semget+0xfb>
      }
      if(s->id==semid && ((s->references)==0)){
801054b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bc:	8b 00                	mov    (%eax),%eax
801054be:	3b 45 08             	cmp    0x8(%ebp),%eax
801054c1:	75 13                	jne    801054d6 <semget+0xe4>
801054c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c6:	8b 40 04             	mov    0x4(%eax),%eax
801054c9:	85 c0                	test   %eax,%eax
801054cb:	75 09                	jne    801054d6 <semget+0xe4>
        retvalue=-1;
801054cd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
        goto retget;
801054d4:	eb 39                	jmp    8010550f <semget+0x11d>
    s->value=initvalue;
    retvalue=s->id;
    goto found;
  }
  if(semid>=0){
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
801054d6:	83 45 f0 0c          	addl   $0xc,-0x10(%ebp)
801054da:	b8 14 65 11 80       	mov    $0x80116514,%eax
801054df:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801054e2:	72 b7                	jb     8010549b <semget+0xa9>
      if(s->id==semid && ((s->references)==0)){
        retvalue=-1;
        goto retget;
      }
    }
    retvalue=-5;
801054e4:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    goto retget;
801054eb:	eb 22                	jmp    8010550f <semget+0x11d>
  }
found:
  s->references++;
801054ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f0:	8b 40 04             	mov    0x4(%eax),%eax
801054f3:	8d 50 01             	lea    0x1(%eax),%edx
801054f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[position]=s;
801054fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105502:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105505:	8d 4a 20             	lea    0x20(%edx),%ecx
80105508:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010550b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
retget:
  release(&stable.lock);
8010550f:	83 ec 0c             	sub    $0xc,%esp
80105512:	68 e0 61 11 80       	push   $0x801161e0
80105517:	e8 22 03 00 00       	call   8010583e <release>
8010551c:	83 c4 10             	add    $0x10,%esp
  return retvalue;
8010551f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105522:	c9                   	leave  
80105523:	c3                   	ret    

80105524 <semfree>:

// It releases the semaphore of the process if it is not in use, but only decreases the references in 1.
// if the semaphore is not in the process, return -1.
int
semfree(int semid)
{
80105524:	55                   	push   %ebp
80105525:	89 e5                	mov    %esp,%ebp
80105527:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int retvalue,pos;

  acquire(&stable.lock);
8010552a:	83 ec 0c             	sub    $0xc,%esp
8010552d:	68 e0 61 11 80       	push   $0x801161e0
80105532:	e8 a0 02 00 00       	call   801057d7 <acquire>
80105537:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
8010553a:	83 ec 0c             	sub    $0xc,%esp
8010553d:	ff 75 08             	pushl  0x8(%ebp)
80105540:	e8 1c fe ff ff       	call   80105361 <searchinprocess>
80105545:	83 c4 10             	add    $0x10,%esp
80105548:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
8010554b:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010554f:	75 09                	jne    8010555a <semfree+0x36>
    retvalue=-1;
80105551:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retfree;
80105558:	eb 50                	jmp    801055aa <semfree+0x86>
  }
  s=proc->osemaphore[pos];
8010555a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105560:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105563:	83 c2 20             	add    $0x20,%edx
80105566:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010556a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(s->references < 1){
8010556d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105570:	8b 40 04             	mov    0x4(%eax),%eax
80105573:	85 c0                	test   %eax,%eax
80105575:	7f 09                	jg     80105580 <semfree+0x5c>
    retvalue=-2;
80105577:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retfree;
8010557e:	eb 2a                	jmp    801055aa <semfree+0x86>
  }
  s->references--;
80105580:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105583:	8b 40 04             	mov    0x4(%eax),%eax
80105586:	8d 50 ff             	lea    -0x1(%eax),%edx
80105589:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010558c:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[pos]=0;
8010558f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105595:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105598:	83 c2 20             	add    $0x20,%edx
8010559b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801055a2:	00 
  retvalue=0;
801055a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retfree:
  release(&stable.lock);
801055aa:	83 ec 0c             	sub    $0xc,%esp
801055ad:	68 e0 61 11 80       	push   $0x801161e0
801055b2:	e8 87 02 00 00       	call   8010583e <release>
801055b7:	83 c4 10             	add    $0x10,%esp
  return retvalue;
801055ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055bd:	c9                   	leave  
801055be:	c3                   	ret    

801055bf <semdown>:

// Decreases the value of the semaphore if it is greater than 0 but sleeps the process.
// if the semaphore is not in the process, return -1.
int
semdown(int semid)
{
801055bf:	55                   	push   %ebp
801055c0:	89 e5                	mov    %esp,%ebp
801055c2:	83 ec 18             	sub    $0x18,%esp
  int value,pos;
  struct semaphore* s;

  acquire(&stable.lock);
801055c5:	83 ec 0c             	sub    $0xc,%esp
801055c8:	68 e0 61 11 80       	push   $0x801161e0
801055cd:	e8 05 02 00 00       	call   801057d7 <acquire>
801055d2:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
801055d5:	83 ec 0c             	sub    $0xc,%esp
801055d8:	ff 75 08             	pushl  0x8(%ebp)
801055db:	e8 81 fd ff ff       	call   80105361 <searchinprocess>
801055e0:	83 c4 10             	add    $0x10,%esp
801055e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
801055e6:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801055ea:	75 09                	jne    801055f5 <semdown+0x36>
    value=-1;
801055ec:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retdown;
801055f3:	eb 48                	jmp    8010563d <semdown+0x7e>
  }
  s=proc->osemaphore[pos];
801055f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055fe:	83 c2 20             	add    $0x20,%edx
80105601:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105605:	89 45 ec             	mov    %eax,-0x14(%ebp)
  while(s->value<=0){
80105608:	eb 13                	jmp    8010561d <semdown+0x5e>
    sleep(s,&stable.lock);
8010560a:	83 ec 08             	sub    $0x8,%esp
8010560d:	68 e0 61 11 80       	push   $0x801161e0
80105612:	ff 75 ec             	pushl  -0x14(%ebp)
80105615:	e8 01 fa ff ff       	call   8010501b <sleep>
8010561a:	83 c4 10             	add    $0x10,%esp
  if(pos==-1){
    value=-1;
    goto retdown;
  }
  s=proc->osemaphore[pos];
  while(s->value<=0){
8010561d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105620:	8b 40 08             	mov    0x8(%eax),%eax
80105623:	85 c0                	test   %eax,%eax
80105625:	7e e3                	jle    8010560a <semdown+0x4b>
    sleep(s,&stable.lock);
  }
  s->value--;
80105627:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010562a:	8b 40 08             	mov    0x8(%eax),%eax
8010562d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105630:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105633:	89 50 08             	mov    %edx,0x8(%eax)
  value=0;
80105636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retdown:
  release(&stable.lock);
8010563d:	83 ec 0c             	sub    $0xc,%esp
80105640:	68 e0 61 11 80       	push   $0x801161e0
80105645:	e8 f4 01 00 00       	call   8010583e <release>
8010564a:	83 c4 10             	add    $0x10,%esp
  return value;
8010564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105650:	c9                   	leave  
80105651:	c3                   	ret    

80105652 <semup>:

// It increases the value of the semaphore and wake up processes waiting for it.
// if the semaphore is not in the process, return -1.
int
semup(int semid)
{
80105652:	55                   	push   %ebp
80105653:	89 e5                	mov    %esp,%ebp
80105655:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int pos;

  acquire(&stable.lock);
80105658:	83 ec 0c             	sub    $0xc,%esp
8010565b:	68 e0 61 11 80       	push   $0x801161e0
80105660:	e8 72 01 00 00       	call   801057d7 <acquire>
80105665:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105668:	83 ec 0c             	sub    $0xc,%esp
8010566b:	ff 75 08             	pushl  0x8(%ebp)
8010566e:	e8 ee fc ff ff       	call   80105361 <searchinprocess>
80105673:	83 c4 10             	add    $0x10,%esp
80105676:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pos==-1){
80105679:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
8010567d:	75 17                	jne    80105696 <semup+0x44>
    release(&stable.lock);
8010567f:	83 ec 0c             	sub    $0xc,%esp
80105682:	68 e0 61 11 80       	push   $0x801161e0
80105687:	e8 b2 01 00 00       	call   8010583e <release>
8010568c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010568f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105694:	eb 45                	jmp    801056db <semup+0x89>
  }
  s=proc->osemaphore[pos];
80105696:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010569c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010569f:	83 c2 20             	add    $0x20,%edx
801056a2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->value++;
801056a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ac:	8b 40 08             	mov    0x8(%eax),%eax
801056af:	8d 50 01             	lea    0x1(%eax),%edx
801056b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b5:	89 50 08             	mov    %edx,0x8(%eax)
  release(&stable.lock);
801056b8:	83 ec 0c             	sub    $0xc,%esp
801056bb:	68 e0 61 11 80       	push   $0x801161e0
801056c0:	e8 79 01 00 00       	call   8010583e <release>
801056c5:	83 c4 10             	add    $0x10,%esp
  wakeup(s);
801056c8:	83 ec 0c             	sub    $0xc,%esp
801056cb:	ff 75 f0             	pushl  -0x10(%ebp)
801056ce:	e8 54 fa ff ff       	call   80105127 <wakeup>
801056d3:	83 c4 10             	add    $0x10,%esp
  return 0;
801056d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056db:	c9                   	leave  
801056dc:	c3                   	ret    

801056dd <semclose>:

// Decrease the semaphore references.
void
semclose(struct semaphore* s)
{
801056dd:	55                   	push   %ebp
801056de:	89 e5                	mov    %esp,%ebp
801056e0:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
801056e3:	83 ec 0c             	sub    $0xc,%esp
801056e6:	68 e0 61 11 80       	push   $0x801161e0
801056eb:	e8 e7 00 00 00       	call   801057d7 <acquire>
801056f0:	83 c4 10             	add    $0x10,%esp

  if(s->references < 1)
801056f3:	8b 45 08             	mov    0x8(%ebp),%eax
801056f6:	8b 40 04             	mov    0x4(%eax),%eax
801056f9:	85 c0                	test   %eax,%eax
801056fb:	7f 0d                	jg     8010570a <semclose+0x2d>
    panic("semclose");
801056fd:	83 ec 0c             	sub    $0xc,%esp
80105700:	68 e4 93 10 80       	push   $0x801093e4
80105705:	e8 5c ae ff ff       	call   80100566 <panic>
  s->references--;
8010570a:	8b 45 08             	mov    0x8(%ebp),%eax
8010570d:	8b 40 04             	mov    0x4(%eax),%eax
80105710:	8d 50 ff             	lea    -0x1(%eax),%edx
80105713:	8b 45 08             	mov    0x8(%ebp),%eax
80105716:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
80105719:	83 ec 0c             	sub    $0xc,%esp
8010571c:	68 e0 61 11 80       	push   $0x801161e0
80105721:	e8 18 01 00 00       	call   8010583e <release>
80105726:	83 c4 10             	add    $0x10,%esp
  return;
80105729:	90                   	nop

}
8010572a:	c9                   	leave  
8010572b:	c3                   	ret    

8010572c <semdup>:

// Increase the semaphore references.
struct semaphore*
semdup(struct semaphore* s)
{
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
80105732:	83 ec 0c             	sub    $0xc,%esp
80105735:	68 e0 61 11 80       	push   $0x801161e0
8010573a:	e8 98 00 00 00       	call   801057d7 <acquire>
8010573f:	83 c4 10             	add    $0x10,%esp
  if(s->references<0)
80105742:	8b 45 08             	mov    0x8(%ebp),%eax
80105745:	8b 40 04             	mov    0x4(%eax),%eax
80105748:	85 c0                	test   %eax,%eax
8010574a:	79 0d                	jns    80105759 <semdup+0x2d>
    panic("semdup error");
8010574c:	83 ec 0c             	sub    $0xc,%esp
8010574f:	68 ed 93 10 80       	push   $0x801093ed
80105754:	e8 0d ae ff ff       	call   80100566 <panic>
  s->references++;
80105759:	8b 45 08             	mov    0x8(%ebp),%eax
8010575c:	8b 40 04             	mov    0x4(%eax),%eax
8010575f:	8d 50 01             	lea    0x1(%eax),%edx
80105762:	8b 45 08             	mov    0x8(%ebp),%eax
80105765:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
80105768:	83 ec 0c             	sub    $0xc,%esp
8010576b:	68 e0 61 11 80       	push   $0x801161e0
80105770:	e8 c9 00 00 00       	call   8010583e <release>
80105775:	83 c4 10             	add    $0x10,%esp
  return s;
80105778:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010577b:	c9                   	leave  
8010577c:	c3                   	ret    

8010577d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010577d:	55                   	push   %ebp
8010577e:	89 e5                	mov    %esp,%ebp
80105780:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105783:	9c                   	pushf  
80105784:	58                   	pop    %eax
80105785:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105788:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010578b:	c9                   	leave  
8010578c:	c3                   	ret    

8010578d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010578d:	55                   	push   %ebp
8010578e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105790:	fa                   	cli    
}
80105791:	90                   	nop
80105792:	5d                   	pop    %ebp
80105793:	c3                   	ret    

80105794 <sti>:

static inline void
sti(void)
{
80105794:	55                   	push   %ebp
80105795:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105797:	fb                   	sti    
}
80105798:	90                   	nop
80105799:	5d                   	pop    %ebp
8010579a:	c3                   	ret    

8010579b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010579b:	55                   	push   %ebp
8010579c:	89 e5                	mov    %esp,%ebp
8010579e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801057a1:	8b 55 08             	mov    0x8(%ebp),%edx
801057a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057aa:	f0 87 02             	lock xchg %eax,(%edx)
801057ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801057b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057b3:	c9                   	leave  
801057b4:	c3                   	ret    

801057b5 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801057b5:	55                   	push   %ebp
801057b6:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801057b8:	8b 45 08             	mov    0x8(%ebp),%eax
801057bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801057be:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801057c1:	8b 45 08             	mov    0x8(%ebp),%eax
801057c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801057ca:	8b 45 08             	mov    0x8(%ebp),%eax
801057cd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801057d4:	90                   	nop
801057d5:	5d                   	pop    %ebp
801057d6:	c3                   	ret    

801057d7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801057d7:	55                   	push   %ebp
801057d8:	89 e5                	mov    %esp,%ebp
801057da:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801057dd:	e8 52 01 00 00       	call   80105934 <pushcli>
  if(holding(lk))
801057e2:	8b 45 08             	mov    0x8(%ebp),%eax
801057e5:	83 ec 0c             	sub    $0xc,%esp
801057e8:	50                   	push   %eax
801057e9:	e8 1c 01 00 00       	call   8010590a <holding>
801057ee:	83 c4 10             	add    $0x10,%esp
801057f1:	85 c0                	test   %eax,%eax
801057f3:	74 0d                	je     80105802 <acquire+0x2b>
    panic("acquire");
801057f5:	83 ec 0c             	sub    $0xc,%esp
801057f8:	68 fa 93 10 80       	push   $0x801093fa
801057fd:	e8 64 ad ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105802:	90                   	nop
80105803:	8b 45 08             	mov    0x8(%ebp),%eax
80105806:	83 ec 08             	sub    $0x8,%esp
80105809:	6a 01                	push   $0x1
8010580b:	50                   	push   %eax
8010580c:	e8 8a ff ff ff       	call   8010579b <xchg>
80105811:	83 c4 10             	add    $0x10,%esp
80105814:	85 c0                	test   %eax,%eax
80105816:	75 eb                	jne    80105803 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105818:	8b 45 08             	mov    0x8(%ebp),%eax
8010581b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105822:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	83 c0 0c             	add    $0xc,%eax
8010582b:	83 ec 08             	sub    $0x8,%esp
8010582e:	50                   	push   %eax
8010582f:	8d 45 08             	lea    0x8(%ebp),%eax
80105832:	50                   	push   %eax
80105833:	e8 58 00 00 00       	call   80105890 <getcallerpcs>
80105838:	83 c4 10             	add    $0x10,%esp
}
8010583b:	90                   	nop
8010583c:	c9                   	leave  
8010583d:	c3                   	ret    

8010583e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010583e:	55                   	push   %ebp
8010583f:	89 e5                	mov    %esp,%ebp
80105841:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105844:	83 ec 0c             	sub    $0xc,%esp
80105847:	ff 75 08             	pushl  0x8(%ebp)
8010584a:	e8 bb 00 00 00       	call   8010590a <holding>
8010584f:	83 c4 10             	add    $0x10,%esp
80105852:	85 c0                	test   %eax,%eax
80105854:	75 0d                	jne    80105863 <release+0x25>
    panic("release");
80105856:	83 ec 0c             	sub    $0xc,%esp
80105859:	68 02 94 10 80       	push   $0x80109402
8010585e:	e8 03 ad ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105863:	8b 45 08             	mov    0x8(%ebp),%eax
80105866:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010586d:	8b 45 08             	mov    0x8(%ebp),%eax
80105870:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105877:	8b 45 08             	mov    0x8(%ebp),%eax
8010587a:	83 ec 08             	sub    $0x8,%esp
8010587d:	6a 00                	push   $0x0
8010587f:	50                   	push   %eax
80105880:	e8 16 ff ff ff       	call   8010579b <xchg>
80105885:	83 c4 10             	add    $0x10,%esp

  popcli();
80105888:	e8 ec 00 00 00       	call   80105979 <popcli>
}
8010588d:	90                   	nop
8010588e:	c9                   	leave  
8010588f:	c3                   	ret    

80105890 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105890:	55                   	push   %ebp
80105891:	89 e5                	mov    %esp,%ebp
80105893:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105896:	8b 45 08             	mov    0x8(%ebp),%eax
80105899:	83 e8 08             	sub    $0x8,%eax
8010589c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010589f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801058a6:	eb 38                	jmp    801058e0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801058a8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801058ac:	74 53                	je     80105901 <getcallerpcs+0x71>
801058ae:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801058b5:	76 4a                	jbe    80105901 <getcallerpcs+0x71>
801058b7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801058bb:	74 44                	je     80105901 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801058bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ca:	01 c2                	add    %eax,%edx
801058cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058cf:	8b 40 04             	mov    0x4(%eax),%eax
801058d2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801058d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d7:	8b 00                	mov    (%eax),%eax
801058d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801058dc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058e0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058e4:	7e c2                	jle    801058a8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058e6:	eb 19                	jmp    80105901 <getcallerpcs+0x71>
    pcs[i] = 0;
801058e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f5:	01 d0                	add    %edx,%eax
801058f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105901:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105905:	7e e1                	jle    801058e8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105907:	90                   	nop
80105908:	c9                   	leave  
80105909:	c3                   	ret    

8010590a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010590a:	55                   	push   %ebp
8010590b:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010590d:	8b 45 08             	mov    0x8(%ebp),%eax
80105910:	8b 00                	mov    (%eax),%eax
80105912:	85 c0                	test   %eax,%eax
80105914:	74 17                	je     8010592d <holding+0x23>
80105916:	8b 45 08             	mov    0x8(%ebp),%eax
80105919:	8b 50 08             	mov    0x8(%eax),%edx
8010591c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105922:	39 c2                	cmp    %eax,%edx
80105924:	75 07                	jne    8010592d <holding+0x23>
80105926:	b8 01 00 00 00       	mov    $0x1,%eax
8010592b:	eb 05                	jmp    80105932 <holding+0x28>
8010592d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105932:	5d                   	pop    %ebp
80105933:	c3                   	ret    

80105934 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105934:	55                   	push   %ebp
80105935:	89 e5                	mov    %esp,%ebp
80105937:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010593a:	e8 3e fe ff ff       	call   8010577d <readeflags>
8010593f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105942:	e8 46 fe ff ff       	call   8010578d <cli>
  if(cpu->ncli++ == 0)
80105947:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010594e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105954:	8d 48 01             	lea    0x1(%eax),%ecx
80105957:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010595d:	85 c0                	test   %eax,%eax
8010595f:	75 15                	jne    80105976 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105961:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105967:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010596a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105970:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105976:	90                   	nop
80105977:	c9                   	leave  
80105978:	c3                   	ret    

80105979 <popcli>:

void
popcli(void)
{
80105979:	55                   	push   %ebp
8010597a:	89 e5                	mov    %esp,%ebp
8010597c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010597f:	e8 f9 fd ff ff       	call   8010577d <readeflags>
80105984:	25 00 02 00 00       	and    $0x200,%eax
80105989:	85 c0                	test   %eax,%eax
8010598b:	74 0d                	je     8010599a <popcli+0x21>
    panic("popcli - interruptible");
8010598d:	83 ec 0c             	sub    $0xc,%esp
80105990:	68 0a 94 10 80       	push   $0x8010940a
80105995:	e8 cc ab ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010599a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059a0:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801059a6:	83 ea 01             	sub    $0x1,%edx
801059a9:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801059af:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059b5:	85 c0                	test   %eax,%eax
801059b7:	79 0d                	jns    801059c6 <popcli+0x4d>
    panic("popcli");
801059b9:	83 ec 0c             	sub    $0xc,%esp
801059bc:	68 21 94 10 80       	push   $0x80109421
801059c1:	e8 a0 ab ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801059c6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059cc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059d2:	85 c0                	test   %eax,%eax
801059d4:	75 15                	jne    801059eb <popcli+0x72>
801059d6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059dc:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801059e2:	85 c0                	test   %eax,%eax
801059e4:	74 05                	je     801059eb <popcli+0x72>
    sti();
801059e6:	e8 a9 fd ff ff       	call   80105794 <sti>
}
801059eb:	90                   	nop
801059ec:	c9                   	leave  
801059ed:	c3                   	ret    

801059ee <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801059ee:	55                   	push   %ebp
801059ef:	89 e5                	mov    %esp,%ebp
801059f1:	57                   	push   %edi
801059f2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801059f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059f6:	8b 55 10             	mov    0x10(%ebp),%edx
801059f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801059fc:	89 cb                	mov    %ecx,%ebx
801059fe:	89 df                	mov    %ebx,%edi
80105a00:	89 d1                	mov    %edx,%ecx
80105a02:	fc                   	cld    
80105a03:	f3 aa                	rep stos %al,%es:(%edi)
80105a05:	89 ca                	mov    %ecx,%edx
80105a07:	89 fb                	mov    %edi,%ebx
80105a09:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a0c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a0f:	90                   	nop
80105a10:	5b                   	pop    %ebx
80105a11:	5f                   	pop    %edi
80105a12:	5d                   	pop    %ebp
80105a13:	c3                   	ret    

80105a14 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105a14:	55                   	push   %ebp
80105a15:	89 e5                	mov    %esp,%ebp
80105a17:	57                   	push   %edi
80105a18:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105a1c:	8b 55 10             	mov    0x10(%ebp),%edx
80105a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a22:	89 cb                	mov    %ecx,%ebx
80105a24:	89 df                	mov    %ebx,%edi
80105a26:	89 d1                	mov    %edx,%ecx
80105a28:	fc                   	cld    
80105a29:	f3 ab                	rep stos %eax,%es:(%edi)
80105a2b:	89 ca                	mov    %ecx,%edx
80105a2d:	89 fb                	mov    %edi,%ebx
80105a2f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a32:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a35:	90                   	nop
80105a36:	5b                   	pop    %ebx
80105a37:	5f                   	pop    %edi
80105a38:	5d                   	pop    %ebp
80105a39:	c3                   	ret    

80105a3a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105a3a:	55                   	push   %ebp
80105a3b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105a40:	83 e0 03             	and    $0x3,%eax
80105a43:	85 c0                	test   %eax,%eax
80105a45:	75 43                	jne    80105a8a <memset+0x50>
80105a47:	8b 45 10             	mov    0x10(%ebp),%eax
80105a4a:	83 e0 03             	and    $0x3,%eax
80105a4d:	85 c0                	test   %eax,%eax
80105a4f:	75 39                	jne    80105a8a <memset+0x50>
    c &= 0xFF;
80105a51:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a58:	8b 45 10             	mov    0x10(%ebp),%eax
80105a5b:	c1 e8 02             	shr    $0x2,%eax
80105a5e:	89 c1                	mov    %eax,%ecx
80105a60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a63:	c1 e0 18             	shl    $0x18,%eax
80105a66:	89 c2                	mov    %eax,%edx
80105a68:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a6b:	c1 e0 10             	shl    $0x10,%eax
80105a6e:	09 c2                	or     %eax,%edx
80105a70:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a73:	c1 e0 08             	shl    $0x8,%eax
80105a76:	09 d0                	or     %edx,%eax
80105a78:	0b 45 0c             	or     0xc(%ebp),%eax
80105a7b:	51                   	push   %ecx
80105a7c:	50                   	push   %eax
80105a7d:	ff 75 08             	pushl  0x8(%ebp)
80105a80:	e8 8f ff ff ff       	call   80105a14 <stosl>
80105a85:	83 c4 0c             	add    $0xc,%esp
80105a88:	eb 12                	jmp    80105a9c <memset+0x62>
  } else
    stosb(dst, c, n);
80105a8a:	8b 45 10             	mov    0x10(%ebp),%eax
80105a8d:	50                   	push   %eax
80105a8e:	ff 75 0c             	pushl  0xc(%ebp)
80105a91:	ff 75 08             	pushl  0x8(%ebp)
80105a94:	e8 55 ff ff ff       	call   801059ee <stosb>
80105a99:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105a9c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a9f:	c9                   	leave  
80105aa0:	c3                   	ret    

80105aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105aa1:	55                   	push   %ebp
80105aa2:	89 e5                	mov    %esp,%ebp
80105aa4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80105aaa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105aad:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105ab3:	eb 30                	jmp    80105ae5 <memcmp+0x44>
    if(*s1 != *s2)
80105ab5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ab8:	0f b6 10             	movzbl (%eax),%edx
80105abb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105abe:	0f b6 00             	movzbl (%eax),%eax
80105ac1:	38 c2                	cmp    %al,%dl
80105ac3:	74 18                	je     80105add <memcmp+0x3c>
      return *s1 - *s2;
80105ac5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ac8:	0f b6 00             	movzbl (%eax),%eax
80105acb:	0f b6 d0             	movzbl %al,%edx
80105ace:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ad1:	0f b6 00             	movzbl (%eax),%eax
80105ad4:	0f b6 c0             	movzbl %al,%eax
80105ad7:	29 c2                	sub    %eax,%edx
80105ad9:	89 d0                	mov    %edx,%eax
80105adb:	eb 1a                	jmp    80105af7 <memcmp+0x56>
    s1++, s2++;
80105add:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ae1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105ae5:	8b 45 10             	mov    0x10(%ebp),%eax
80105ae8:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aeb:	89 55 10             	mov    %edx,0x10(%ebp)
80105aee:	85 c0                	test   %eax,%eax
80105af0:	75 c3                	jne    80105ab5 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105af7:	c9                   	leave  
80105af8:	c3                   	ret    

80105af9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105af9:	55                   	push   %ebp
80105afa:	89 e5                	mov    %esp,%ebp
80105afc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105aff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b02:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105b05:	8b 45 08             	mov    0x8(%ebp),%eax
80105b08:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105b0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b0e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b11:	73 54                	jae    80105b67 <memmove+0x6e>
80105b13:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b16:	8b 45 10             	mov    0x10(%ebp),%eax
80105b19:	01 d0                	add    %edx,%eax
80105b1b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b1e:	76 47                	jbe    80105b67 <memmove+0x6e>
    s += n;
80105b20:	8b 45 10             	mov    0x10(%ebp),%eax
80105b23:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105b26:	8b 45 10             	mov    0x10(%ebp),%eax
80105b29:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105b2c:	eb 13                	jmp    80105b41 <memmove+0x48>
      *--d = *--s;
80105b2e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105b32:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105b36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b39:	0f b6 10             	movzbl (%eax),%edx
80105b3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b3f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105b41:	8b 45 10             	mov    0x10(%ebp),%eax
80105b44:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b47:	89 55 10             	mov    %edx,0x10(%ebp)
80105b4a:	85 c0                	test   %eax,%eax
80105b4c:	75 e0                	jne    80105b2e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b4e:	eb 24                	jmp    80105b74 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b53:	8d 50 01             	lea    0x1(%eax),%edx
80105b56:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b59:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b5c:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b5f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105b62:	0f b6 12             	movzbl (%edx),%edx
80105b65:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b67:	8b 45 10             	mov    0x10(%ebp),%eax
80105b6a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b6d:	89 55 10             	mov    %edx,0x10(%ebp)
80105b70:	85 c0                	test   %eax,%eax
80105b72:	75 dc                	jne    80105b50 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105b74:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105b77:	c9                   	leave  
80105b78:	c3                   	ret    

80105b79 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105b79:	55                   	push   %ebp
80105b7a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105b7c:	ff 75 10             	pushl  0x10(%ebp)
80105b7f:	ff 75 0c             	pushl  0xc(%ebp)
80105b82:	ff 75 08             	pushl  0x8(%ebp)
80105b85:	e8 6f ff ff ff       	call   80105af9 <memmove>
80105b8a:	83 c4 0c             	add    $0xc,%esp
}
80105b8d:	c9                   	leave  
80105b8e:	c3                   	ret    

80105b8f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105b8f:	55                   	push   %ebp
80105b90:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105b92:	eb 0c                	jmp    80105ba0 <strncmp+0x11>
    n--, p++, q++;
80105b94:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105b98:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105b9c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105ba0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ba4:	74 1a                	je     80105bc0 <strncmp+0x31>
80105ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba9:	0f b6 00             	movzbl (%eax),%eax
80105bac:	84 c0                	test   %al,%al
80105bae:	74 10                	je     80105bc0 <strncmp+0x31>
80105bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb3:	0f b6 10             	movzbl (%eax),%edx
80105bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bb9:	0f b6 00             	movzbl (%eax),%eax
80105bbc:	38 c2                	cmp    %al,%dl
80105bbe:	74 d4                	je     80105b94 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105bc0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bc4:	75 07                	jne    80105bcd <strncmp+0x3e>
    return 0;
80105bc6:	b8 00 00 00 00       	mov    $0x0,%eax
80105bcb:	eb 16                	jmp    80105be3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd0:	0f b6 00             	movzbl (%eax),%eax
80105bd3:	0f b6 d0             	movzbl %al,%edx
80105bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd9:	0f b6 00             	movzbl (%eax),%eax
80105bdc:	0f b6 c0             	movzbl %al,%eax
80105bdf:	29 c2                	sub    %eax,%edx
80105be1:	89 d0                	mov    %edx,%eax
}
80105be3:	5d                   	pop    %ebp
80105be4:	c3                   	ret    

80105be5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105be5:	55                   	push   %ebp
80105be6:	89 e5                	mov    %esp,%ebp
80105be8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105beb:	8b 45 08             	mov    0x8(%ebp),%eax
80105bee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105bf1:	90                   	nop
80105bf2:	8b 45 10             	mov    0x10(%ebp),%eax
80105bf5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bf8:	89 55 10             	mov    %edx,0x10(%ebp)
80105bfb:	85 c0                	test   %eax,%eax
80105bfd:	7e 2c                	jle    80105c2b <strncpy+0x46>
80105bff:	8b 45 08             	mov    0x8(%ebp),%eax
80105c02:	8d 50 01             	lea    0x1(%eax),%edx
80105c05:	89 55 08             	mov    %edx,0x8(%ebp)
80105c08:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c0b:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c0e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c11:	0f b6 12             	movzbl (%edx),%edx
80105c14:	88 10                	mov    %dl,(%eax)
80105c16:	0f b6 00             	movzbl (%eax),%eax
80105c19:	84 c0                	test   %al,%al
80105c1b:	75 d5                	jne    80105bf2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105c1d:	eb 0c                	jmp    80105c2b <strncpy+0x46>
    *s++ = 0;
80105c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c22:	8d 50 01             	lea    0x1(%eax),%edx
80105c25:	89 55 08             	mov    %edx,0x8(%ebp)
80105c28:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105c2b:	8b 45 10             	mov    0x10(%ebp),%eax
80105c2e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c31:	89 55 10             	mov    %edx,0x10(%ebp)
80105c34:	85 c0                	test   %eax,%eax
80105c36:	7f e7                	jg     80105c1f <strncpy+0x3a>
    *s++ = 0;
  return os;
80105c38:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c3b:	c9                   	leave  
80105c3c:	c3                   	ret    

80105c3d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105c3d:	55                   	push   %ebp
80105c3e:	89 e5                	mov    %esp,%ebp
80105c40:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105c43:	8b 45 08             	mov    0x8(%ebp),%eax
80105c46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105c49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c4d:	7f 05                	jg     80105c54 <safestrcpy+0x17>
    return os;
80105c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c52:	eb 31                	jmp    80105c85 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105c58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c5c:	7e 1e                	jle    80105c7c <safestrcpy+0x3f>
80105c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c61:	8d 50 01             	lea    0x1(%eax),%edx
80105c64:	89 55 08             	mov    %edx,0x8(%ebp)
80105c67:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c6a:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c6d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c70:	0f b6 12             	movzbl (%edx),%edx
80105c73:	88 10                	mov    %dl,(%eax)
80105c75:	0f b6 00             	movzbl (%eax),%eax
80105c78:	84 c0                	test   %al,%al
80105c7a:	75 d8                	jne    80105c54 <safestrcpy+0x17>
    ;
  *s = 0;
80105c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c7f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105c82:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c85:	c9                   	leave  
80105c86:	c3                   	ret    

80105c87 <strlen>:

int
strlen(const char *s)
{
80105c87:	55                   	push   %ebp
80105c88:	89 e5                	mov    %esp,%ebp
80105c8a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105c8d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c94:	eb 04                	jmp    80105c9a <strlen+0x13>
80105c96:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105c9a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca0:	01 d0                	add    %edx,%eax
80105ca2:	0f b6 00             	movzbl (%eax),%eax
80105ca5:	84 c0                	test   %al,%al
80105ca7:	75 ed                	jne    80105c96 <strlen+0xf>
    ;
  return n;
80105ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cac:	c9                   	leave  
80105cad:	c3                   	ret    

80105cae <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105cae:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105cb2:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105cb6:	55                   	push   %ebp
  pushl %ebx
80105cb7:	53                   	push   %ebx
  pushl %esi
80105cb8:	56                   	push   %esi
  pushl %edi
80105cb9:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105cba:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105cbc:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105cbe:	5f                   	pop    %edi
  popl %esi
80105cbf:	5e                   	pop    %esi
  popl %ebx
80105cc0:	5b                   	pop    %ebx
  popl %ebp
80105cc1:	5d                   	pop    %ebp
  ret
80105cc2:	c3                   	ret    

80105cc3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105cc3:	55                   	push   %ebp
80105cc4:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105cc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ccc:	8b 00                	mov    (%eax),%eax
80105cce:	3b 45 08             	cmp    0x8(%ebp),%eax
80105cd1:	76 12                	jbe    80105ce5 <fetchint+0x22>
80105cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd6:	8d 50 04             	lea    0x4(%eax),%edx
80105cd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cdf:	8b 00                	mov    (%eax),%eax
80105ce1:	39 c2                	cmp    %eax,%edx
80105ce3:	76 07                	jbe    80105cec <fetchint+0x29>
    return -1;
80105ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cea:	eb 0f                	jmp    80105cfb <fetchint+0x38>
  *ip = *(int*)(addr);
80105cec:	8b 45 08             	mov    0x8(%ebp),%eax
80105cef:	8b 10                	mov    (%eax),%edx
80105cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf4:	89 10                	mov    %edx,(%eax)
  return 0;
80105cf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cfb:	5d                   	pop    %ebp
80105cfc:	c3                   	ret    

80105cfd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105cfd:	55                   	push   %ebp
80105cfe:	89 e5                	mov    %esp,%ebp
80105d00:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105d03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d09:	8b 00                	mov    (%eax),%eax
80105d0b:	3b 45 08             	cmp    0x8(%ebp),%eax
80105d0e:	77 07                	ja     80105d17 <fetchstr+0x1a>
    return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	eb 46                	jmp    80105d5d <fetchstr+0x60>
  *pp = (char*)addr;
80105d17:	8b 55 08             	mov    0x8(%ebp),%edx
80105d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d1d:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105d1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d25:	8b 00                	mov    (%eax),%eax
80105d27:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2d:	8b 00                	mov    (%eax),%eax
80105d2f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105d32:	eb 1c                	jmp    80105d50 <fetchstr+0x53>
    if(*s == 0)
80105d34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d37:	0f b6 00             	movzbl (%eax),%eax
80105d3a:	84 c0                	test   %al,%al
80105d3c:	75 0e                	jne    80105d4c <fetchstr+0x4f>
      return s - *pp;
80105d3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d44:	8b 00                	mov    (%eax),%eax
80105d46:	29 c2                	sub    %eax,%edx
80105d48:	89 d0                	mov    %edx,%eax
80105d4a:	eb 11                	jmp    80105d5d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105d4c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d53:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d56:	72 dc                	jb     80105d34 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d5d:	c9                   	leave  
80105d5e:	c3                   	ret    

80105d5f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105d5f:	55                   	push   %ebp
80105d60:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105d62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d68:	8b 40 18             	mov    0x18(%eax),%eax
80105d6b:	8b 40 44             	mov    0x44(%eax),%eax
80105d6e:	8b 55 08             	mov    0x8(%ebp),%edx
80105d71:	c1 e2 02             	shl    $0x2,%edx
80105d74:	01 d0                	add    %edx,%eax
80105d76:	83 c0 04             	add    $0x4,%eax
80105d79:	ff 75 0c             	pushl  0xc(%ebp)
80105d7c:	50                   	push   %eax
80105d7d:	e8 41 ff ff ff       	call   80105cc3 <fetchint>
80105d82:	83 c4 08             	add    $0x8,%esp
}
80105d85:	c9                   	leave  
80105d86:	c3                   	ret    

80105d87 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d87:	55                   	push   %ebp
80105d88:	89 e5                	mov    %esp,%ebp
80105d8a:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80105d8d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105d90:	50                   	push   %eax
80105d91:	ff 75 08             	pushl  0x8(%ebp)
80105d94:	e8 c6 ff ff ff       	call   80105d5f <argint>
80105d99:	83 c4 08             	add    $0x8,%esp
80105d9c:	85 c0                	test   %eax,%eax
80105d9e:	79 07                	jns    80105da7 <argptr+0x20>
    return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da5:	eb 3b                	jmp    80105de2 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dad:	8b 00                	mov    (%eax),%eax
80105daf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105db2:	39 d0                	cmp    %edx,%eax
80105db4:	76 16                	jbe    80105dcc <argptr+0x45>
80105db6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db9:	89 c2                	mov    %eax,%edx
80105dbb:	8b 45 10             	mov    0x10(%ebp),%eax
80105dbe:	01 c2                	add    %eax,%edx
80105dc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dc6:	8b 00                	mov    (%eax),%eax
80105dc8:	39 c2                	cmp    %eax,%edx
80105dca:	76 07                	jbe    80105dd3 <argptr+0x4c>
    return -1;
80105dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd1:	eb 0f                	jmp    80105de2 <argptr+0x5b>
  *pp = (char*)i;
80105dd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dd6:	89 c2                	mov    %eax,%edx
80105dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ddb:	89 10                	mov    %edx,(%eax)
  return 0;
80105ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105de2:	c9                   	leave  
80105de3:	c3                   	ret    

80105de4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105de4:	55                   	push   %ebp
80105de5:	89 e5                	mov    %esp,%ebp
80105de7:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105dea:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105ded:	50                   	push   %eax
80105dee:	ff 75 08             	pushl  0x8(%ebp)
80105df1:	e8 69 ff ff ff       	call   80105d5f <argint>
80105df6:	83 c4 08             	add    $0x8,%esp
80105df9:	85 c0                	test   %eax,%eax
80105dfb:	79 07                	jns    80105e04 <argstr+0x20>
    return -1;
80105dfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e02:	eb 0f                	jmp    80105e13 <argstr+0x2f>
  return fetchstr(addr, pp);
80105e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e07:	ff 75 0c             	pushl  0xc(%ebp)
80105e0a:	50                   	push   %eax
80105e0b:	e8 ed fe ff ff       	call   80105cfd <fetchstr>
80105e10:	83 c4 08             	add    $0x8,%esp
}
80105e13:	c9                   	leave  
80105e14:	c3                   	ret    

80105e15 <syscall>:
[SYS_semup]   sys_semup
};

void
syscall(void)
{
80105e15:	55                   	push   %ebp
80105e16:	89 e5                	mov    %esp,%ebp
80105e18:	53                   	push   %ebx
80105e19:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105e1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e22:	8b 40 18             	mov    0x18(%eax),%eax
80105e25:	8b 40 1c             	mov    0x1c(%eax),%eax
80105e28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105e2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e2f:	7e 30                	jle    80105e61 <syscall+0x4c>
80105e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e34:	83 f8 1b             	cmp    $0x1b,%eax
80105e37:	77 28                	ja     80105e61 <syscall+0x4c>
80105e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e43:	85 c0                	test   %eax,%eax
80105e45:	74 1a                	je     80105e61 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105e47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e4d:	8b 58 18             	mov    0x18(%eax),%ebx
80105e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e53:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e5a:	ff d0                	call   *%eax
80105e5c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105e5f:	eb 34                	jmp    80105e95 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105e61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e67:	8d 50 6c             	lea    0x6c(%eax),%edx
80105e6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105e70:	8b 40 10             	mov    0x10(%eax),%eax
80105e73:	ff 75 f4             	pushl  -0xc(%ebp)
80105e76:	52                   	push   %edx
80105e77:	50                   	push   %eax
80105e78:	68 28 94 10 80       	push   $0x80109428
80105e7d:	e8 44 a5 ff ff       	call   801003c6 <cprintf>
80105e82:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105e85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e8b:	8b 40 18             	mov    0x18(%eax),%eax
80105e8e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105e95:	90                   	nop
80105e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e99:	c9                   	leave  
80105e9a:	c3                   	ret    

80105e9b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105e9b:	55                   	push   %ebp
80105e9c:	89 e5                	mov    %esp,%ebp
80105e9e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ea1:	83 ec 08             	sub    $0x8,%esp
80105ea4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ea7:	50                   	push   %eax
80105ea8:	ff 75 08             	pushl  0x8(%ebp)
80105eab:	e8 af fe ff ff       	call   80105d5f <argint>
80105eb0:	83 c4 10             	add    $0x10,%esp
80105eb3:	85 c0                	test   %eax,%eax
80105eb5:	79 07                	jns    80105ebe <argfd+0x23>
    return -1;
80105eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebc:	eb 50                	jmp    80105f0e <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	78 21                	js     80105ee6 <argfd+0x4b>
80105ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec8:	83 f8 0f             	cmp    $0xf,%eax
80105ecb:	7f 19                	jg     80105ee6 <argfd+0x4b>
80105ecd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ed3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ed6:	83 c2 08             	add    $0x8,%edx
80105ed9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105edd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee4:	75 07                	jne    80105eed <argfd+0x52>
    return -1;
80105ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eeb:	eb 21                	jmp    80105f0e <argfd+0x73>
  if(pfd)
80105eed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ef1:	74 08                	je     80105efb <argfd+0x60>
    *pfd = fd;
80105ef3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ef9:	89 10                	mov    %edx,(%eax)
  if(pf)
80105efb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105eff:	74 08                	je     80105f09 <argfd+0x6e>
    *pf = f;
80105f01:	8b 45 10             	mov    0x10(%ebp),%eax
80105f04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f07:	89 10                	mov    %edx,(%eax)
  return 0;
80105f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f0e:	c9                   	leave  
80105f0f:	c3                   	ret    

80105f10 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105f10:	55                   	push   %ebp
80105f11:	89 e5                	mov    %esp,%ebp
80105f13:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f16:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105f1d:	eb 30                	jmp    80105f4f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105f1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f25:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f28:	83 c2 08             	add    $0x8,%edx
80105f2b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f2f:	85 c0                	test   %eax,%eax
80105f31:	75 18                	jne    80105f4b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105f33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f39:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f3c:	8d 4a 08             	lea    0x8(%edx),%ecx
80105f3f:	8b 55 08             	mov    0x8(%ebp),%edx
80105f42:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f49:	eb 0f                	jmp    80105f5a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f4b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f4f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105f53:	7e ca                	jle    80105f1f <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f5a:	c9                   	leave  
80105f5b:	c3                   	ret    

80105f5c <sys_dup>:

int
sys_dup(void)
{
80105f5c:	55                   	push   %ebp
80105f5d:	89 e5                	mov    %esp,%ebp
80105f5f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105f62:	83 ec 04             	sub    $0x4,%esp
80105f65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f68:	50                   	push   %eax
80105f69:	6a 00                	push   $0x0
80105f6b:	6a 00                	push   $0x0
80105f6d:	e8 29 ff ff ff       	call   80105e9b <argfd>
80105f72:	83 c4 10             	add    $0x10,%esp
80105f75:	85 c0                	test   %eax,%eax
80105f77:	79 07                	jns    80105f80 <sys_dup+0x24>
    return -1;
80105f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f7e:	eb 31                	jmp    80105fb1 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f83:	83 ec 0c             	sub    $0xc,%esp
80105f86:	50                   	push   %eax
80105f87:	e8 84 ff ff ff       	call   80105f10 <fdalloc>
80105f8c:	83 c4 10             	add    $0x10,%esp
80105f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f96:	79 07                	jns    80105f9f <sys_dup+0x43>
    return -1;
80105f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9d:	eb 12                	jmp    80105fb1 <sys_dup+0x55>
  filedup(f);
80105f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa2:	83 ec 0c             	sub    $0xc,%esp
80105fa5:	50                   	push   %eax
80105fa6:	e8 42 b0 ff ff       	call   80100fed <filedup>
80105fab:	83 c4 10             	add    $0x10,%esp
  return fd;
80105fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fb1:	c9                   	leave  
80105fb2:	c3                   	ret    

80105fb3 <sys_read>:

int
sys_read(void)
{
80105fb3:	55                   	push   %ebp
80105fb4:	89 e5                	mov    %esp,%ebp
80105fb6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105fb9:	83 ec 04             	sub    $0x4,%esp
80105fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fbf:	50                   	push   %eax
80105fc0:	6a 00                	push   $0x0
80105fc2:	6a 00                	push   $0x0
80105fc4:	e8 d2 fe ff ff       	call   80105e9b <argfd>
80105fc9:	83 c4 10             	add    $0x10,%esp
80105fcc:	85 c0                	test   %eax,%eax
80105fce:	78 2e                	js     80105ffe <sys_read+0x4b>
80105fd0:	83 ec 08             	sub    $0x8,%esp
80105fd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fd6:	50                   	push   %eax
80105fd7:	6a 02                	push   $0x2
80105fd9:	e8 81 fd ff ff       	call   80105d5f <argint>
80105fde:	83 c4 10             	add    $0x10,%esp
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	78 19                	js     80105ffe <sys_read+0x4b>
80105fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe8:	83 ec 04             	sub    $0x4,%esp
80105feb:	50                   	push   %eax
80105fec:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fef:	50                   	push   %eax
80105ff0:	6a 01                	push   $0x1
80105ff2:	e8 90 fd ff ff       	call   80105d87 <argptr>
80105ff7:	83 c4 10             	add    $0x10,%esp
80105ffa:	85 c0                	test   %eax,%eax
80105ffc:	79 07                	jns    80106005 <sys_read+0x52>
    return -1;
80105ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106003:	eb 17                	jmp    8010601c <sys_read+0x69>
  return fileread(f, p, n);
80106005:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106008:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010600b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600e:	83 ec 04             	sub    $0x4,%esp
80106011:	51                   	push   %ecx
80106012:	52                   	push   %edx
80106013:	50                   	push   %eax
80106014:	e8 64 b1 ff ff       	call   8010117d <fileread>
80106019:	83 c4 10             	add    $0x10,%esp
}
8010601c:	c9                   	leave  
8010601d:	c3                   	ret    

8010601e <sys_write>:

int
sys_write(void)
{
8010601e:	55                   	push   %ebp
8010601f:	89 e5                	mov    %esp,%ebp
80106021:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106024:	83 ec 04             	sub    $0x4,%esp
80106027:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010602a:	50                   	push   %eax
8010602b:	6a 00                	push   $0x0
8010602d:	6a 00                	push   $0x0
8010602f:	e8 67 fe ff ff       	call   80105e9b <argfd>
80106034:	83 c4 10             	add    $0x10,%esp
80106037:	85 c0                	test   %eax,%eax
80106039:	78 2e                	js     80106069 <sys_write+0x4b>
8010603b:	83 ec 08             	sub    $0x8,%esp
8010603e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106041:	50                   	push   %eax
80106042:	6a 02                	push   $0x2
80106044:	e8 16 fd ff ff       	call   80105d5f <argint>
80106049:	83 c4 10             	add    $0x10,%esp
8010604c:	85 c0                	test   %eax,%eax
8010604e:	78 19                	js     80106069 <sys_write+0x4b>
80106050:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106053:	83 ec 04             	sub    $0x4,%esp
80106056:	50                   	push   %eax
80106057:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010605a:	50                   	push   %eax
8010605b:	6a 01                	push   $0x1
8010605d:	e8 25 fd ff ff       	call   80105d87 <argptr>
80106062:	83 c4 10             	add    $0x10,%esp
80106065:	85 c0                	test   %eax,%eax
80106067:	79 07                	jns    80106070 <sys_write+0x52>
    return -1;
80106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606e:	eb 17                	jmp    80106087 <sys_write+0x69>
  return filewrite(f, p, n);
80106070:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106073:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106079:	83 ec 04             	sub    $0x4,%esp
8010607c:	51                   	push   %ecx
8010607d:	52                   	push   %edx
8010607e:	50                   	push   %eax
8010607f:	e8 b1 b1 ff ff       	call   80101235 <filewrite>
80106084:	83 c4 10             	add    $0x10,%esp
}
80106087:	c9                   	leave  
80106088:	c3                   	ret    

80106089 <sys_close>:

int
sys_close(void)
{
80106089:	55                   	push   %ebp
8010608a:	89 e5                	mov    %esp,%ebp
8010608c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010608f:	83 ec 04             	sub    $0x4,%esp
80106092:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106095:	50                   	push   %eax
80106096:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106099:	50                   	push   %eax
8010609a:	6a 00                	push   $0x0
8010609c:	e8 fa fd ff ff       	call   80105e9b <argfd>
801060a1:	83 c4 10             	add    $0x10,%esp
801060a4:	85 c0                	test   %eax,%eax
801060a6:	79 07                	jns    801060af <sys_close+0x26>
    return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ad:	eb 28                	jmp    801060d7 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801060af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060b8:	83 c2 08             	add    $0x8,%edx
801060bb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801060c2:	00 
  fileclose(f);
801060c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	50                   	push   %eax
801060ca:	e8 6f af ff ff       	call   8010103e <fileclose>
801060cf:	83 c4 10             	add    $0x10,%esp
  return 0;
801060d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d7:	c9                   	leave  
801060d8:	c3                   	ret    

801060d9 <sys_fstat>:

int
sys_fstat(void)
{
801060d9:	55                   	push   %ebp
801060da:	89 e5                	mov    %esp,%ebp
801060dc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801060df:	83 ec 04             	sub    $0x4,%esp
801060e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060e5:	50                   	push   %eax
801060e6:	6a 00                	push   $0x0
801060e8:	6a 00                	push   $0x0
801060ea:	e8 ac fd ff ff       	call   80105e9b <argfd>
801060ef:	83 c4 10             	add    $0x10,%esp
801060f2:	85 c0                	test   %eax,%eax
801060f4:	78 17                	js     8010610d <sys_fstat+0x34>
801060f6:	83 ec 04             	sub    $0x4,%esp
801060f9:	6a 14                	push   $0x14
801060fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060fe:	50                   	push   %eax
801060ff:	6a 01                	push   $0x1
80106101:	e8 81 fc ff ff       	call   80105d87 <argptr>
80106106:	83 c4 10             	add    $0x10,%esp
80106109:	85 c0                	test   %eax,%eax
8010610b:	79 07                	jns    80106114 <sys_fstat+0x3b>
    return -1;
8010610d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106112:	eb 13                	jmp    80106127 <sys_fstat+0x4e>
  return filestat(f, st);
80106114:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611a:	83 ec 08             	sub    $0x8,%esp
8010611d:	52                   	push   %edx
8010611e:	50                   	push   %eax
8010611f:	e8 02 b0 ff ff       	call   80101126 <filestat>
80106124:	83 c4 10             	add    $0x10,%esp
}
80106127:	c9                   	leave  
80106128:	c3                   	ret    

80106129 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106129:	55                   	push   %ebp
8010612a:	89 e5                	mov    %esp,%ebp
8010612c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010612f:	83 ec 08             	sub    $0x8,%esp
80106132:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106135:	50                   	push   %eax
80106136:	6a 00                	push   $0x0
80106138:	e8 a7 fc ff ff       	call   80105de4 <argstr>
8010613d:	83 c4 10             	add    $0x10,%esp
80106140:	85 c0                	test   %eax,%eax
80106142:	78 15                	js     80106159 <sys_link+0x30>
80106144:	83 ec 08             	sub    $0x8,%esp
80106147:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010614a:	50                   	push   %eax
8010614b:	6a 01                	push   $0x1
8010614d:	e8 92 fc ff ff       	call   80105de4 <argstr>
80106152:	83 c4 10             	add    $0x10,%esp
80106155:	85 c0                	test   %eax,%eax
80106157:	79 0a                	jns    80106163 <sys_link+0x3a>
    return -1;
80106159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615e:	e9 68 01 00 00       	jmp    801062cb <sys_link+0x1a2>

  begin_op();
80106163:	e8 54 d3 ff ff       	call   801034bc <begin_op>
  if((ip = namei(old)) == 0){
80106168:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010616b:	83 ec 0c             	sub    $0xc,%esp
8010616e:	50                   	push   %eax
8010616f:	e8 57 c3 ff ff       	call   801024cb <namei>
80106174:	83 c4 10             	add    $0x10,%esp
80106177:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010617a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010617e:	75 0f                	jne    8010618f <sys_link+0x66>
    end_op();
80106180:	e8 c3 d3 ff ff       	call   80103548 <end_op>
    return -1;
80106185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618a:	e9 3c 01 00 00       	jmp    801062cb <sys_link+0x1a2>
  }

  ilock(ip);
8010618f:	83 ec 0c             	sub    $0xc,%esp
80106192:	ff 75 f4             	pushl  -0xc(%ebp)
80106195:	e8 79 b7 ff ff       	call   80101913 <ilock>
8010619a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010619d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061a4:	66 83 f8 01          	cmp    $0x1,%ax
801061a8:	75 1d                	jne    801061c7 <sys_link+0x9e>
    iunlockput(ip);
801061aa:	83 ec 0c             	sub    $0xc,%esp
801061ad:	ff 75 f4             	pushl  -0xc(%ebp)
801061b0:	e8 18 ba ff ff       	call   80101bcd <iunlockput>
801061b5:	83 c4 10             	add    $0x10,%esp
    end_op();
801061b8:	e8 8b d3 ff ff       	call   80103548 <end_op>
    return -1;
801061bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c2:	e9 04 01 00 00       	jmp    801062cb <sys_link+0x1a2>
  }

  ip->nlink++;
801061c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ca:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801061ce:	83 c0 01             	add    $0x1,%eax
801061d1:	89 c2                	mov    %eax,%edx
801061d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d6:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801061da:	83 ec 0c             	sub    $0xc,%esp
801061dd:	ff 75 f4             	pushl  -0xc(%ebp)
801061e0:	e8 5a b5 ff ff       	call   8010173f <iupdate>
801061e5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801061e8:	83 ec 0c             	sub    $0xc,%esp
801061eb:	ff 75 f4             	pushl  -0xc(%ebp)
801061ee:	e8 78 b8 ff ff       	call   80101a6b <iunlock>
801061f3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801061f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801061f9:	83 ec 08             	sub    $0x8,%esp
801061fc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801061ff:	52                   	push   %edx
80106200:	50                   	push   %eax
80106201:	e8 e1 c2 ff ff       	call   801024e7 <nameiparent>
80106206:	83 c4 10             	add    $0x10,%esp
80106209:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010620c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106210:	74 71                	je     80106283 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106212:	83 ec 0c             	sub    $0xc,%esp
80106215:	ff 75 f0             	pushl  -0x10(%ebp)
80106218:	e8 f6 b6 ff ff       	call   80101913 <ilock>
8010621d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106220:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106223:	8b 10                	mov    (%eax),%edx
80106225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106228:	8b 00                	mov    (%eax),%eax
8010622a:	39 c2                	cmp    %eax,%edx
8010622c:	75 1d                	jne    8010624b <sys_link+0x122>
8010622e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106231:	8b 40 04             	mov    0x4(%eax),%eax
80106234:	83 ec 04             	sub    $0x4,%esp
80106237:	50                   	push   %eax
80106238:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010623b:	50                   	push   %eax
8010623c:	ff 75 f0             	pushl  -0x10(%ebp)
8010623f:	e8 eb bf ff ff       	call   8010222f <dirlink>
80106244:	83 c4 10             	add    $0x10,%esp
80106247:	85 c0                	test   %eax,%eax
80106249:	79 10                	jns    8010625b <sys_link+0x132>
    iunlockput(dp);
8010624b:	83 ec 0c             	sub    $0xc,%esp
8010624e:	ff 75 f0             	pushl  -0x10(%ebp)
80106251:	e8 77 b9 ff ff       	call   80101bcd <iunlockput>
80106256:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106259:	eb 29                	jmp    80106284 <sys_link+0x15b>
  }
  iunlockput(dp);
8010625b:	83 ec 0c             	sub    $0xc,%esp
8010625e:	ff 75 f0             	pushl  -0x10(%ebp)
80106261:	e8 67 b9 ff ff       	call   80101bcd <iunlockput>
80106266:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106269:	83 ec 0c             	sub    $0xc,%esp
8010626c:	ff 75 f4             	pushl  -0xc(%ebp)
8010626f:	e8 69 b8 ff ff       	call   80101add <iput>
80106274:	83 c4 10             	add    $0x10,%esp

  end_op();
80106277:	e8 cc d2 ff ff       	call   80103548 <end_op>

  return 0;
8010627c:	b8 00 00 00 00       	mov    $0x0,%eax
80106281:	eb 48                	jmp    801062cb <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106283:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106284:	83 ec 0c             	sub    $0xc,%esp
80106287:	ff 75 f4             	pushl  -0xc(%ebp)
8010628a:	e8 84 b6 ff ff       	call   80101913 <ilock>
8010628f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106295:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106299:	83 e8 01             	sub    $0x1,%eax
8010629c:	89 c2                	mov    %eax,%edx
8010629e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801062a5:	83 ec 0c             	sub    $0xc,%esp
801062a8:	ff 75 f4             	pushl  -0xc(%ebp)
801062ab:	e8 8f b4 ff ff       	call   8010173f <iupdate>
801062b0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801062b3:	83 ec 0c             	sub    $0xc,%esp
801062b6:	ff 75 f4             	pushl  -0xc(%ebp)
801062b9:	e8 0f b9 ff ff       	call   80101bcd <iunlockput>
801062be:	83 c4 10             	add    $0x10,%esp
  end_op();
801062c1:	e8 82 d2 ff ff       	call   80103548 <end_op>
  return -1;
801062c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062cb:	c9                   	leave  
801062cc:	c3                   	ret    

801062cd <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801062cd:	55                   	push   %ebp
801062ce:	89 e5                	mov    %esp,%ebp
801062d0:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062d3:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801062da:	eb 40                	jmp    8010631c <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801062dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062df:	6a 10                	push   $0x10
801062e1:	50                   	push   %eax
801062e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062e5:	50                   	push   %eax
801062e6:	ff 75 08             	pushl  0x8(%ebp)
801062e9:	e8 8d bb ff ff       	call   80101e7b <readi>
801062ee:	83 c4 10             	add    $0x10,%esp
801062f1:	83 f8 10             	cmp    $0x10,%eax
801062f4:	74 0d                	je     80106303 <isdirempty+0x36>
      panic("isdirempty: readi");
801062f6:	83 ec 0c             	sub    $0xc,%esp
801062f9:	68 44 94 10 80       	push   $0x80109444
801062fe:	e8 63 a2 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106303:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106307:	66 85 c0             	test   %ax,%ax
8010630a:	74 07                	je     80106313 <isdirempty+0x46>
      return 0;
8010630c:	b8 00 00 00 00       	mov    $0x0,%eax
80106311:	eb 1b                	jmp    8010632e <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106316:	83 c0 10             	add    $0x10,%eax
80106319:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010631c:	8b 45 08             	mov    0x8(%ebp),%eax
8010631f:	8b 50 18             	mov    0x18(%eax),%edx
80106322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106325:	39 c2                	cmp    %eax,%edx
80106327:	77 b3                	ja     801062dc <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106329:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010632e:	c9                   	leave  
8010632f:	c3                   	ret    

80106330 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106330:	55                   	push   %ebp
80106331:	89 e5                	mov    %esp,%ebp
80106333:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106336:	83 ec 08             	sub    $0x8,%esp
80106339:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010633c:	50                   	push   %eax
8010633d:	6a 00                	push   $0x0
8010633f:	e8 a0 fa ff ff       	call   80105de4 <argstr>
80106344:	83 c4 10             	add    $0x10,%esp
80106347:	85 c0                	test   %eax,%eax
80106349:	79 0a                	jns    80106355 <sys_unlink+0x25>
    return -1;
8010634b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106350:	e9 bc 01 00 00       	jmp    80106511 <sys_unlink+0x1e1>

  begin_op();
80106355:	e8 62 d1 ff ff       	call   801034bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010635a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010635d:	83 ec 08             	sub    $0x8,%esp
80106360:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106363:	52                   	push   %edx
80106364:	50                   	push   %eax
80106365:	e8 7d c1 ff ff       	call   801024e7 <nameiparent>
8010636a:	83 c4 10             	add    $0x10,%esp
8010636d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106370:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106374:	75 0f                	jne    80106385 <sys_unlink+0x55>
    end_op();
80106376:	e8 cd d1 ff ff       	call   80103548 <end_op>
    return -1;
8010637b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106380:	e9 8c 01 00 00       	jmp    80106511 <sys_unlink+0x1e1>
  }

  ilock(dp);
80106385:	83 ec 0c             	sub    $0xc,%esp
80106388:	ff 75 f4             	pushl  -0xc(%ebp)
8010638b:	e8 83 b5 ff ff       	call   80101913 <ilock>
80106390:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106393:	83 ec 08             	sub    $0x8,%esp
80106396:	68 56 94 10 80       	push   $0x80109456
8010639b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010639e:	50                   	push   %eax
8010639f:	e8 b6 bd ff ff       	call   8010215a <namecmp>
801063a4:	83 c4 10             	add    $0x10,%esp
801063a7:	85 c0                	test   %eax,%eax
801063a9:	0f 84 4a 01 00 00    	je     801064f9 <sys_unlink+0x1c9>
801063af:	83 ec 08             	sub    $0x8,%esp
801063b2:	68 58 94 10 80       	push   $0x80109458
801063b7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063ba:	50                   	push   %eax
801063bb:	e8 9a bd ff ff       	call   8010215a <namecmp>
801063c0:	83 c4 10             	add    $0x10,%esp
801063c3:	85 c0                	test   %eax,%eax
801063c5:	0f 84 2e 01 00 00    	je     801064f9 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801063cb:	83 ec 04             	sub    $0x4,%esp
801063ce:	8d 45 c8             	lea    -0x38(%ebp),%eax
801063d1:	50                   	push   %eax
801063d2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063d5:	50                   	push   %eax
801063d6:	ff 75 f4             	pushl  -0xc(%ebp)
801063d9:	e8 97 bd ff ff       	call   80102175 <dirlookup>
801063de:	83 c4 10             	add    $0x10,%esp
801063e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e8:	0f 84 0a 01 00 00    	je     801064f8 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801063ee:	83 ec 0c             	sub    $0xc,%esp
801063f1:	ff 75 f0             	pushl  -0x10(%ebp)
801063f4:	e8 1a b5 ff ff       	call   80101913 <ilock>
801063f9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801063fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ff:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106403:	66 85 c0             	test   %ax,%ax
80106406:	7f 0d                	jg     80106415 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106408:	83 ec 0c             	sub    $0xc,%esp
8010640b:	68 5b 94 10 80       	push   $0x8010945b
80106410:	e8 51 a1 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106418:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010641c:	66 83 f8 01          	cmp    $0x1,%ax
80106420:	75 25                	jne    80106447 <sys_unlink+0x117>
80106422:	83 ec 0c             	sub    $0xc,%esp
80106425:	ff 75 f0             	pushl  -0x10(%ebp)
80106428:	e8 a0 fe ff ff       	call   801062cd <isdirempty>
8010642d:	83 c4 10             	add    $0x10,%esp
80106430:	85 c0                	test   %eax,%eax
80106432:	75 13                	jne    80106447 <sys_unlink+0x117>
    iunlockput(ip);
80106434:	83 ec 0c             	sub    $0xc,%esp
80106437:	ff 75 f0             	pushl  -0x10(%ebp)
8010643a:	e8 8e b7 ff ff       	call   80101bcd <iunlockput>
8010643f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106442:	e9 b2 00 00 00       	jmp    801064f9 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106447:	83 ec 04             	sub    $0x4,%esp
8010644a:	6a 10                	push   $0x10
8010644c:	6a 00                	push   $0x0
8010644e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106451:	50                   	push   %eax
80106452:	e8 e3 f5 ff ff       	call   80105a3a <memset>
80106457:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010645a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010645d:	6a 10                	push   $0x10
8010645f:	50                   	push   %eax
80106460:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106463:	50                   	push   %eax
80106464:	ff 75 f4             	pushl  -0xc(%ebp)
80106467:	e8 66 bb ff ff       	call   80101fd2 <writei>
8010646c:	83 c4 10             	add    $0x10,%esp
8010646f:	83 f8 10             	cmp    $0x10,%eax
80106472:	74 0d                	je     80106481 <sys_unlink+0x151>
    panic("unlink: writei");
80106474:	83 ec 0c             	sub    $0xc,%esp
80106477:	68 6d 94 10 80       	push   $0x8010946d
8010647c:	e8 e5 a0 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106484:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106488:	66 83 f8 01          	cmp    $0x1,%ax
8010648c:	75 21                	jne    801064af <sys_unlink+0x17f>
    dp->nlink--;
8010648e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106491:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106495:	83 e8 01             	sub    $0x1,%eax
80106498:	89 c2                	mov    %eax,%edx
8010649a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801064a1:	83 ec 0c             	sub    $0xc,%esp
801064a4:	ff 75 f4             	pushl  -0xc(%ebp)
801064a7:	e8 93 b2 ff ff       	call   8010173f <iupdate>
801064ac:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801064af:	83 ec 0c             	sub    $0xc,%esp
801064b2:	ff 75 f4             	pushl  -0xc(%ebp)
801064b5:	e8 13 b7 ff ff       	call   80101bcd <iunlockput>
801064ba:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801064bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064c4:	83 e8 01             	sub    $0x1,%eax
801064c7:	89 c2                	mov    %eax,%edx
801064c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801064d0:	83 ec 0c             	sub    $0xc,%esp
801064d3:	ff 75 f0             	pushl  -0x10(%ebp)
801064d6:	e8 64 b2 ff ff       	call   8010173f <iupdate>
801064db:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801064de:	83 ec 0c             	sub    $0xc,%esp
801064e1:	ff 75 f0             	pushl  -0x10(%ebp)
801064e4:	e8 e4 b6 ff ff       	call   80101bcd <iunlockput>
801064e9:	83 c4 10             	add    $0x10,%esp

  end_op();
801064ec:	e8 57 d0 ff ff       	call   80103548 <end_op>

  return 0;
801064f1:	b8 00 00 00 00       	mov    $0x0,%eax
801064f6:	eb 19                	jmp    80106511 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801064f8:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801064f9:	83 ec 0c             	sub    $0xc,%esp
801064fc:	ff 75 f4             	pushl  -0xc(%ebp)
801064ff:	e8 c9 b6 ff ff       	call   80101bcd <iunlockput>
80106504:	83 c4 10             	add    $0x10,%esp
  end_op();
80106507:	e8 3c d0 ff ff       	call   80103548 <end_op>
  return -1;
8010650c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106511:	c9                   	leave  
80106512:	c3                   	ret    

80106513 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106513:	55                   	push   %ebp
80106514:	89 e5                	mov    %esp,%ebp
80106516:	83 ec 38             	sub    $0x38,%esp
80106519:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010651c:	8b 55 10             	mov    0x10(%ebp),%edx
8010651f:	8b 45 14             	mov    0x14(%ebp),%eax
80106522:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106526:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010652a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010652e:	83 ec 08             	sub    $0x8,%esp
80106531:	8d 45 de             	lea    -0x22(%ebp),%eax
80106534:	50                   	push   %eax
80106535:	ff 75 08             	pushl  0x8(%ebp)
80106538:	e8 aa bf ff ff       	call   801024e7 <nameiparent>
8010653d:	83 c4 10             	add    $0x10,%esp
80106540:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106543:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106547:	75 0a                	jne    80106553 <create+0x40>
    return 0;
80106549:	b8 00 00 00 00       	mov    $0x0,%eax
8010654e:	e9 90 01 00 00       	jmp    801066e3 <create+0x1d0>
  ilock(dp);
80106553:	83 ec 0c             	sub    $0xc,%esp
80106556:	ff 75 f4             	pushl  -0xc(%ebp)
80106559:	e8 b5 b3 ff ff       	call   80101913 <ilock>
8010655e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106561:	83 ec 04             	sub    $0x4,%esp
80106564:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106567:	50                   	push   %eax
80106568:	8d 45 de             	lea    -0x22(%ebp),%eax
8010656b:	50                   	push   %eax
8010656c:	ff 75 f4             	pushl  -0xc(%ebp)
8010656f:	e8 01 bc ff ff       	call   80102175 <dirlookup>
80106574:	83 c4 10             	add    $0x10,%esp
80106577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010657a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657e:	74 50                	je     801065d0 <create+0xbd>
    iunlockput(dp);
80106580:	83 ec 0c             	sub    $0xc,%esp
80106583:	ff 75 f4             	pushl  -0xc(%ebp)
80106586:	e8 42 b6 ff ff       	call   80101bcd <iunlockput>
8010658b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010658e:	83 ec 0c             	sub    $0xc,%esp
80106591:	ff 75 f0             	pushl  -0x10(%ebp)
80106594:	e8 7a b3 ff ff       	call   80101913 <ilock>
80106599:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010659c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801065a1:	75 15                	jne    801065b8 <create+0xa5>
801065a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065aa:	66 83 f8 02          	cmp    $0x2,%ax
801065ae:	75 08                	jne    801065b8 <create+0xa5>
      return ip;
801065b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b3:	e9 2b 01 00 00       	jmp    801066e3 <create+0x1d0>
    iunlockput(ip);
801065b8:	83 ec 0c             	sub    $0xc,%esp
801065bb:	ff 75 f0             	pushl  -0x10(%ebp)
801065be:	e8 0a b6 ff ff       	call   80101bcd <iunlockput>
801065c3:	83 c4 10             	add    $0x10,%esp
    return 0;
801065c6:	b8 00 00 00 00       	mov    $0x0,%eax
801065cb:	e9 13 01 00 00       	jmp    801066e3 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801065d0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801065d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d7:	8b 00                	mov    (%eax),%eax
801065d9:	83 ec 08             	sub    $0x8,%esp
801065dc:	52                   	push   %edx
801065dd:	50                   	push   %eax
801065de:	e8 7b b0 ff ff       	call   8010165e <ialloc>
801065e3:	83 c4 10             	add    $0x10,%esp
801065e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ed:	75 0d                	jne    801065fc <create+0xe9>
    panic("create: ialloc");
801065ef:	83 ec 0c             	sub    $0xc,%esp
801065f2:	68 7c 94 10 80       	push   $0x8010947c
801065f7:	e8 6a 9f ff ff       	call   80100566 <panic>

  ilock(ip);
801065fc:	83 ec 0c             	sub    $0xc,%esp
801065ff:	ff 75 f0             	pushl  -0x10(%ebp)
80106602:	e8 0c b3 ff ff       	call   80101913 <ilock>
80106607:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010660a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010660d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106611:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106618:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010661c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106623:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106629:	83 ec 0c             	sub    $0xc,%esp
8010662c:	ff 75 f0             	pushl  -0x10(%ebp)
8010662f:	e8 0b b1 ff ff       	call   8010173f <iupdate>
80106634:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106637:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010663c:	75 6a                	jne    801066a8 <create+0x195>
    dp->nlink++;  // for ".."
8010663e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106641:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106645:	83 c0 01             	add    $0x1,%eax
80106648:	89 c2                	mov    %eax,%edx
8010664a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106651:	83 ec 0c             	sub    $0xc,%esp
80106654:	ff 75 f4             	pushl  -0xc(%ebp)
80106657:	e8 e3 b0 ff ff       	call   8010173f <iupdate>
8010665c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010665f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106662:	8b 40 04             	mov    0x4(%eax),%eax
80106665:	83 ec 04             	sub    $0x4,%esp
80106668:	50                   	push   %eax
80106669:	68 56 94 10 80       	push   $0x80109456
8010666e:	ff 75 f0             	pushl  -0x10(%ebp)
80106671:	e8 b9 bb ff ff       	call   8010222f <dirlink>
80106676:	83 c4 10             	add    $0x10,%esp
80106679:	85 c0                	test   %eax,%eax
8010667b:	78 1e                	js     8010669b <create+0x188>
8010667d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106680:	8b 40 04             	mov    0x4(%eax),%eax
80106683:	83 ec 04             	sub    $0x4,%esp
80106686:	50                   	push   %eax
80106687:	68 58 94 10 80       	push   $0x80109458
8010668c:	ff 75 f0             	pushl  -0x10(%ebp)
8010668f:	e8 9b bb ff ff       	call   8010222f <dirlink>
80106694:	83 c4 10             	add    $0x10,%esp
80106697:	85 c0                	test   %eax,%eax
80106699:	79 0d                	jns    801066a8 <create+0x195>
      panic("create dots");
8010669b:	83 ec 0c             	sub    $0xc,%esp
8010669e:	68 8b 94 10 80       	push   $0x8010948b
801066a3:	e8 be 9e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801066a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ab:	8b 40 04             	mov    0x4(%eax),%eax
801066ae:	83 ec 04             	sub    $0x4,%esp
801066b1:	50                   	push   %eax
801066b2:	8d 45 de             	lea    -0x22(%ebp),%eax
801066b5:	50                   	push   %eax
801066b6:	ff 75 f4             	pushl  -0xc(%ebp)
801066b9:	e8 71 bb ff ff       	call   8010222f <dirlink>
801066be:	83 c4 10             	add    $0x10,%esp
801066c1:	85 c0                	test   %eax,%eax
801066c3:	79 0d                	jns    801066d2 <create+0x1bf>
    panic("create: dirlink");
801066c5:	83 ec 0c             	sub    $0xc,%esp
801066c8:	68 97 94 10 80       	push   $0x80109497
801066cd:	e8 94 9e ff ff       	call   80100566 <panic>

  iunlockput(dp);
801066d2:	83 ec 0c             	sub    $0xc,%esp
801066d5:	ff 75 f4             	pushl  -0xc(%ebp)
801066d8:	e8 f0 b4 ff ff       	call   80101bcd <iunlockput>
801066dd:	83 c4 10             	add    $0x10,%esp

  return ip;
801066e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801066e3:	c9                   	leave  
801066e4:	c3                   	ret    

801066e5 <sys_open>:

int
sys_open(void)
{
801066e5:	55                   	push   %ebp
801066e6:	89 e5                	mov    %esp,%ebp
801066e8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801066eb:	83 ec 08             	sub    $0x8,%esp
801066ee:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066f1:	50                   	push   %eax
801066f2:	6a 00                	push   $0x0
801066f4:	e8 eb f6 ff ff       	call   80105de4 <argstr>
801066f9:	83 c4 10             	add    $0x10,%esp
801066fc:	85 c0                	test   %eax,%eax
801066fe:	78 15                	js     80106715 <sys_open+0x30>
80106700:	83 ec 08             	sub    $0x8,%esp
80106703:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106706:	50                   	push   %eax
80106707:	6a 01                	push   $0x1
80106709:	e8 51 f6 ff ff       	call   80105d5f <argint>
8010670e:	83 c4 10             	add    $0x10,%esp
80106711:	85 c0                	test   %eax,%eax
80106713:	79 0a                	jns    8010671f <sys_open+0x3a>
    return -1;
80106715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671a:	e9 61 01 00 00       	jmp    80106880 <sys_open+0x19b>

  begin_op();
8010671f:	e8 98 cd ff ff       	call   801034bc <begin_op>

  if(omode & O_CREATE){
80106724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106727:	25 00 02 00 00       	and    $0x200,%eax
8010672c:	85 c0                	test   %eax,%eax
8010672e:	74 2a                	je     8010675a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106730:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106733:	6a 00                	push   $0x0
80106735:	6a 00                	push   $0x0
80106737:	6a 02                	push   $0x2
80106739:	50                   	push   %eax
8010673a:	e8 d4 fd ff ff       	call   80106513 <create>
8010673f:	83 c4 10             	add    $0x10,%esp
80106742:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106745:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106749:	75 75                	jne    801067c0 <sys_open+0xdb>
      end_op();
8010674b:	e8 f8 cd ff ff       	call   80103548 <end_op>
      return -1;
80106750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106755:	e9 26 01 00 00       	jmp    80106880 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010675a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010675d:	83 ec 0c             	sub    $0xc,%esp
80106760:	50                   	push   %eax
80106761:	e8 65 bd ff ff       	call   801024cb <namei>
80106766:	83 c4 10             	add    $0x10,%esp
80106769:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010676c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106770:	75 0f                	jne    80106781 <sys_open+0x9c>
      end_op();
80106772:	e8 d1 cd ff ff       	call   80103548 <end_op>
      return -1;
80106777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677c:	e9 ff 00 00 00       	jmp    80106880 <sys_open+0x19b>
    }
    ilock(ip);
80106781:	83 ec 0c             	sub    $0xc,%esp
80106784:	ff 75 f4             	pushl  -0xc(%ebp)
80106787:	e8 87 b1 ff ff       	call   80101913 <ilock>
8010678c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010678f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106792:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106796:	66 83 f8 01          	cmp    $0x1,%ax
8010679a:	75 24                	jne    801067c0 <sys_open+0xdb>
8010679c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010679f:	85 c0                	test   %eax,%eax
801067a1:	74 1d                	je     801067c0 <sys_open+0xdb>
      iunlockput(ip);
801067a3:	83 ec 0c             	sub    $0xc,%esp
801067a6:	ff 75 f4             	pushl  -0xc(%ebp)
801067a9:	e8 1f b4 ff ff       	call   80101bcd <iunlockput>
801067ae:	83 c4 10             	add    $0x10,%esp
      end_op();
801067b1:	e8 92 cd ff ff       	call   80103548 <end_op>
      return -1;
801067b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bb:	e9 c0 00 00 00       	jmp    80106880 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801067c0:	e8 bb a7 ff ff       	call   80100f80 <filealloc>
801067c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067cc:	74 17                	je     801067e5 <sys_open+0x100>
801067ce:	83 ec 0c             	sub    $0xc,%esp
801067d1:	ff 75 f0             	pushl  -0x10(%ebp)
801067d4:	e8 37 f7 ff ff       	call   80105f10 <fdalloc>
801067d9:	83 c4 10             	add    $0x10,%esp
801067dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801067df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801067e3:	79 2e                	jns    80106813 <sys_open+0x12e>
    if(f)
801067e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067e9:	74 0e                	je     801067f9 <sys_open+0x114>
      fileclose(f);
801067eb:	83 ec 0c             	sub    $0xc,%esp
801067ee:	ff 75 f0             	pushl  -0x10(%ebp)
801067f1:	e8 48 a8 ff ff       	call   8010103e <fileclose>
801067f6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801067f9:	83 ec 0c             	sub    $0xc,%esp
801067fc:	ff 75 f4             	pushl  -0xc(%ebp)
801067ff:	e8 c9 b3 ff ff       	call   80101bcd <iunlockput>
80106804:	83 c4 10             	add    $0x10,%esp
    end_op();
80106807:	e8 3c cd ff ff       	call   80103548 <end_op>
    return -1;
8010680c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106811:	eb 6d                	jmp    80106880 <sys_open+0x19b>
  }
  iunlock(ip);
80106813:	83 ec 0c             	sub    $0xc,%esp
80106816:	ff 75 f4             	pushl  -0xc(%ebp)
80106819:	e8 4d b2 ff ff       	call   80101a6b <iunlock>
8010681e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106821:	e8 22 cd ff ff       	call   80103548 <end_op>

  f->type = FD_INODE;
80106826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106829:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010682f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106832:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106835:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010683b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106842:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106845:	83 e0 01             	and    $0x1,%eax
80106848:	85 c0                	test   %eax,%eax
8010684a:	0f 94 c0             	sete   %al
8010684d:	89 c2                	mov    %eax,%edx
8010684f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106852:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106858:	83 e0 01             	and    $0x1,%eax
8010685b:	85 c0                	test   %eax,%eax
8010685d:	75 0a                	jne    80106869 <sys_open+0x184>
8010685f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106862:	83 e0 02             	and    $0x2,%eax
80106865:	85 c0                	test   %eax,%eax
80106867:	74 07                	je     80106870 <sys_open+0x18b>
80106869:	b8 01 00 00 00       	mov    $0x1,%eax
8010686e:	eb 05                	jmp    80106875 <sys_open+0x190>
80106870:	b8 00 00 00 00       	mov    $0x0,%eax
80106875:	89 c2                	mov    %eax,%edx
80106877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010687d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106880:	c9                   	leave  
80106881:	c3                   	ret    

80106882 <sys_mkdir>:

int
sys_mkdir(void)
{
80106882:	55                   	push   %ebp
80106883:	89 e5                	mov    %esp,%ebp
80106885:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106888:	e8 2f cc ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010688d:	83 ec 08             	sub    $0x8,%esp
80106890:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106893:	50                   	push   %eax
80106894:	6a 00                	push   $0x0
80106896:	e8 49 f5 ff ff       	call   80105de4 <argstr>
8010689b:	83 c4 10             	add    $0x10,%esp
8010689e:	85 c0                	test   %eax,%eax
801068a0:	78 1b                	js     801068bd <sys_mkdir+0x3b>
801068a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068a5:	6a 00                	push   $0x0
801068a7:	6a 00                	push   $0x0
801068a9:	6a 01                	push   $0x1
801068ab:	50                   	push   %eax
801068ac:	e8 62 fc ff ff       	call   80106513 <create>
801068b1:	83 c4 10             	add    $0x10,%esp
801068b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068bb:	75 0c                	jne    801068c9 <sys_mkdir+0x47>
    end_op();
801068bd:	e8 86 cc ff ff       	call   80103548 <end_op>
    return -1;
801068c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c7:	eb 18                	jmp    801068e1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801068c9:	83 ec 0c             	sub    $0xc,%esp
801068cc:	ff 75 f4             	pushl  -0xc(%ebp)
801068cf:	e8 f9 b2 ff ff       	call   80101bcd <iunlockput>
801068d4:	83 c4 10             	add    $0x10,%esp
  end_op();
801068d7:	e8 6c cc ff ff       	call   80103548 <end_op>
  return 0;
801068dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068e1:	c9                   	leave  
801068e2:	c3                   	ret    

801068e3 <sys_mknod>:

int
sys_mknod(void)
{
801068e3:	55                   	push   %ebp
801068e4:	89 e5                	mov    %esp,%ebp
801068e6:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801068e9:	e8 ce cb ff ff       	call   801034bc <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801068ee:	83 ec 08             	sub    $0x8,%esp
801068f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068f4:	50                   	push   %eax
801068f5:	6a 00                	push   $0x0
801068f7:	e8 e8 f4 ff ff       	call   80105de4 <argstr>
801068fc:	83 c4 10             	add    $0x10,%esp
801068ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106902:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106906:	78 4f                	js     80106957 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106908:	83 ec 08             	sub    $0x8,%esp
8010690b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010690e:	50                   	push   %eax
8010690f:	6a 01                	push   $0x1
80106911:	e8 49 f4 ff ff       	call   80105d5f <argint>
80106916:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106919:	85 c0                	test   %eax,%eax
8010691b:	78 3a                	js     80106957 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010691d:	83 ec 08             	sub    $0x8,%esp
80106920:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106923:	50                   	push   %eax
80106924:	6a 02                	push   $0x2
80106926:	e8 34 f4 ff ff       	call   80105d5f <argint>
8010692b:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010692e:	85 c0                	test   %eax,%eax
80106930:	78 25                	js     80106957 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106932:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106935:	0f bf c8             	movswl %ax,%ecx
80106938:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010693b:	0f bf d0             	movswl %ax,%edx
8010693e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106941:	51                   	push   %ecx
80106942:	52                   	push   %edx
80106943:	6a 03                	push   $0x3
80106945:	50                   	push   %eax
80106946:	e8 c8 fb ff ff       	call   80106513 <create>
8010694b:	83 c4 10             	add    $0x10,%esp
8010694e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106951:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106955:	75 0c                	jne    80106963 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106957:	e8 ec cb ff ff       	call   80103548 <end_op>
    return -1;
8010695c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106961:	eb 18                	jmp    8010697b <sys_mknod+0x98>
  }
  iunlockput(ip);
80106963:	83 ec 0c             	sub    $0xc,%esp
80106966:	ff 75 f0             	pushl  -0x10(%ebp)
80106969:	e8 5f b2 ff ff       	call   80101bcd <iunlockput>
8010696e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106971:	e8 d2 cb ff ff       	call   80103548 <end_op>
  return 0;
80106976:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010697b:	c9                   	leave  
8010697c:	c3                   	ret    

8010697d <sys_chdir>:

int
sys_chdir(void)
{
8010697d:	55                   	push   %ebp
8010697e:	89 e5                	mov    %esp,%ebp
80106980:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106983:	e8 34 cb ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106988:	83 ec 08             	sub    $0x8,%esp
8010698b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010698e:	50                   	push   %eax
8010698f:	6a 00                	push   $0x0
80106991:	e8 4e f4 ff ff       	call   80105de4 <argstr>
80106996:	83 c4 10             	add    $0x10,%esp
80106999:	85 c0                	test   %eax,%eax
8010699b:	78 18                	js     801069b5 <sys_chdir+0x38>
8010699d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a0:	83 ec 0c             	sub    $0xc,%esp
801069a3:	50                   	push   %eax
801069a4:	e8 22 bb ff ff       	call   801024cb <namei>
801069a9:	83 c4 10             	add    $0x10,%esp
801069ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069b3:	75 0c                	jne    801069c1 <sys_chdir+0x44>
    end_op();
801069b5:	e8 8e cb ff ff       	call   80103548 <end_op>
    return -1;
801069ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bf:	eb 6e                	jmp    80106a2f <sys_chdir+0xb2>
  }
  ilock(ip);
801069c1:	83 ec 0c             	sub    $0xc,%esp
801069c4:	ff 75 f4             	pushl  -0xc(%ebp)
801069c7:	e8 47 af ff ff       	call   80101913 <ilock>
801069cc:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801069cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069d6:	66 83 f8 01          	cmp    $0x1,%ax
801069da:	74 1a                	je     801069f6 <sys_chdir+0x79>
    iunlockput(ip);
801069dc:	83 ec 0c             	sub    $0xc,%esp
801069df:	ff 75 f4             	pushl  -0xc(%ebp)
801069e2:	e8 e6 b1 ff ff       	call   80101bcd <iunlockput>
801069e7:	83 c4 10             	add    $0x10,%esp
    end_op();
801069ea:	e8 59 cb ff ff       	call   80103548 <end_op>
    return -1;
801069ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f4:	eb 39                	jmp    80106a2f <sys_chdir+0xb2>
  }
  iunlock(ip);
801069f6:	83 ec 0c             	sub    $0xc,%esp
801069f9:	ff 75 f4             	pushl  -0xc(%ebp)
801069fc:	e8 6a b0 ff ff       	call   80101a6b <iunlock>
80106a01:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106a04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a0a:	8b 40 68             	mov    0x68(%eax),%eax
80106a0d:	83 ec 0c             	sub    $0xc,%esp
80106a10:	50                   	push   %eax
80106a11:	e8 c7 b0 ff ff       	call   80101add <iput>
80106a16:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a19:	e8 2a cb ff ff       	call   80103548 <end_op>
  proc->cwd = ip;
80106a1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a27:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106a2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a2f:	c9                   	leave  
80106a30:	c3                   	ret    

80106a31 <sys_exec>:

int
sys_exec(void)
{
80106a31:	55                   	push   %ebp
80106a32:	89 e5                	mov    %esp,%ebp
80106a34:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106a3a:	83 ec 08             	sub    $0x8,%esp
80106a3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a40:	50                   	push   %eax
80106a41:	6a 00                	push   $0x0
80106a43:	e8 9c f3 ff ff       	call   80105de4 <argstr>
80106a48:	83 c4 10             	add    $0x10,%esp
80106a4b:	85 c0                	test   %eax,%eax
80106a4d:	78 18                	js     80106a67 <sys_exec+0x36>
80106a4f:	83 ec 08             	sub    $0x8,%esp
80106a52:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a58:	50                   	push   %eax
80106a59:	6a 01                	push   $0x1
80106a5b:	e8 ff f2 ff ff       	call   80105d5f <argint>
80106a60:	83 c4 10             	add    $0x10,%esp
80106a63:	85 c0                	test   %eax,%eax
80106a65:	79 0a                	jns    80106a71 <sys_exec+0x40>
    return -1;
80106a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6c:	e9 c6 00 00 00       	jmp    80106b37 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106a71:	83 ec 04             	sub    $0x4,%esp
80106a74:	68 80 00 00 00       	push   $0x80
80106a79:	6a 00                	push   $0x0
80106a7b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a81:	50                   	push   %eax
80106a82:	e8 b3 ef ff ff       	call   80105a3a <memset>
80106a87:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106a8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a94:	83 f8 1f             	cmp    $0x1f,%eax
80106a97:	76 0a                	jbe    80106aa3 <sys_exec+0x72>
      return -1;
80106a99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a9e:	e9 94 00 00 00       	jmp    80106b37 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa6:	c1 e0 02             	shl    $0x2,%eax
80106aa9:	89 c2                	mov    %eax,%edx
80106aab:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106ab1:	01 c2                	add    %eax,%edx
80106ab3:	83 ec 08             	sub    $0x8,%esp
80106ab6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106abc:	50                   	push   %eax
80106abd:	52                   	push   %edx
80106abe:	e8 00 f2 ff ff       	call   80105cc3 <fetchint>
80106ac3:	83 c4 10             	add    $0x10,%esp
80106ac6:	85 c0                	test   %eax,%eax
80106ac8:	79 07                	jns    80106ad1 <sys_exec+0xa0>
      return -1;
80106aca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106acf:	eb 66                	jmp    80106b37 <sys_exec+0x106>
    if(uarg == 0){
80106ad1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ad7:	85 c0                	test   %eax,%eax
80106ad9:	75 27                	jne    80106b02 <sys_exec+0xd1>
      argv[i] = 0;
80106adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ade:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106ae5:	00 00 00 00 
      break;
80106ae9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aed:	83 ec 08             	sub    $0x8,%esp
80106af0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106af6:	52                   	push   %edx
80106af7:	50                   	push   %eax
80106af8:	e8 59 a0 ff ff       	call   80100b56 <exec>
80106afd:	83 c4 10             	add    $0x10,%esp
80106b00:	eb 35                	jmp    80106b37 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b02:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b0b:	c1 e2 02             	shl    $0x2,%edx
80106b0e:	01 c2                	add    %eax,%edx
80106b10:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b16:	83 ec 08             	sub    $0x8,%esp
80106b19:	52                   	push   %edx
80106b1a:	50                   	push   %eax
80106b1b:	e8 dd f1 ff ff       	call   80105cfd <fetchstr>
80106b20:	83 c4 10             	add    $0x10,%esp
80106b23:	85 c0                	test   %eax,%eax
80106b25:	79 07                	jns    80106b2e <sys_exec+0xfd>
      return -1;
80106b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2c:	eb 09                	jmp    80106b37 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106b2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106b32:	e9 5a ff ff ff       	jmp    80106a91 <sys_exec+0x60>
  return exec(path, argv);
}
80106b37:	c9                   	leave  
80106b38:	c3                   	ret    

80106b39 <sys_pipe>:

int
sys_pipe(void)
{
80106b39:	55                   	push   %ebp
80106b3a:	89 e5                	mov    %esp,%ebp
80106b3c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106b3f:	83 ec 04             	sub    $0x4,%esp
80106b42:	6a 08                	push   $0x8
80106b44:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b47:	50                   	push   %eax
80106b48:	6a 00                	push   $0x0
80106b4a:	e8 38 f2 ff ff       	call   80105d87 <argptr>
80106b4f:	83 c4 10             	add    $0x10,%esp
80106b52:	85 c0                	test   %eax,%eax
80106b54:	79 0a                	jns    80106b60 <sys_pipe+0x27>
    return -1;
80106b56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b5b:	e9 af 00 00 00       	jmp    80106c0f <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106b60:	83 ec 08             	sub    $0x8,%esp
80106b63:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b66:	50                   	push   %eax
80106b67:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b6a:	50                   	push   %eax
80106b6b:	e8 4a d4 ff ff       	call   80103fba <pipealloc>
80106b70:	83 c4 10             	add    $0x10,%esp
80106b73:	85 c0                	test   %eax,%eax
80106b75:	79 0a                	jns    80106b81 <sys_pipe+0x48>
    return -1;
80106b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b7c:	e9 8e 00 00 00       	jmp    80106c0f <sys_pipe+0xd6>
  fd0 = -1;
80106b81:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106b88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b8b:	83 ec 0c             	sub    $0xc,%esp
80106b8e:	50                   	push   %eax
80106b8f:	e8 7c f3 ff ff       	call   80105f10 <fdalloc>
80106b94:	83 c4 10             	add    $0x10,%esp
80106b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b9e:	78 18                	js     80106bb8 <sys_pipe+0x7f>
80106ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ba3:	83 ec 0c             	sub    $0xc,%esp
80106ba6:	50                   	push   %eax
80106ba7:	e8 64 f3 ff ff       	call   80105f10 <fdalloc>
80106bac:	83 c4 10             	add    $0x10,%esp
80106baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106bb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bb6:	79 3f                	jns    80106bf7 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106bb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bbc:	78 14                	js     80106bd2 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106bbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bc7:	83 c2 08             	add    $0x8,%edx
80106bca:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106bd1:	00 
    fileclose(rf);
80106bd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bd5:	83 ec 0c             	sub    $0xc,%esp
80106bd8:	50                   	push   %eax
80106bd9:	e8 60 a4 ff ff       	call   8010103e <fileclose>
80106bde:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106be1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106be4:	83 ec 0c             	sub    $0xc,%esp
80106be7:	50                   	push   %eax
80106be8:	e8 51 a4 ff ff       	call   8010103e <fileclose>
80106bed:	83 c4 10             	add    $0x10,%esp
    return -1;
80106bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf5:	eb 18                	jmp    80106c0f <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bfd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106bff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c02:	8d 50 04             	lea    0x4(%eax),%edx
80106c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c08:	89 02                	mov    %eax,(%edx)
  return 0;
80106c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c0f:	c9                   	leave  
80106c10:	c3                   	ret    

80106c11 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106c11:	55                   	push   %ebp
80106c12:	89 e5                	mov    %esp,%ebp
80106c14:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106c17:	e8 3c dd ff ff       	call   80104958 <fork>
}
80106c1c:	c9                   	leave  
80106c1d:	c3                   	ret    

80106c1e <sys_exit>:

int
sys_exit(void)
{
80106c1e:	55                   	push   %ebp
80106c1f:	89 e5                	mov    %esp,%ebp
80106c21:	83 ec 08             	sub    $0x8,%esp
  exit();
80106c24:	e8 2b df ff ff       	call   80104b54 <exit>
  return 0;  // not reached
80106c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c2e:	c9                   	leave  
80106c2f:	c3                   	ret    

80106c30 <sys_wait>:

int
sys_wait(void)
{
80106c30:	55                   	push   %ebp
80106c31:	89 e5                	mov    %esp,%ebp
80106c33:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106c36:	e8 ab e0 ff ff       	call   80104ce6 <wait>
}
80106c3b:	c9                   	leave  
80106c3c:	c3                   	ret    

80106c3d <sys_kill>:

int
sys_kill(void)
{
80106c3d:	55                   	push   %ebp
80106c3e:	89 e5                	mov    %esp,%ebp
80106c40:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106c43:	83 ec 08             	sub    $0x8,%esp
80106c46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c49:	50                   	push   %eax
80106c4a:	6a 00                	push   $0x0
80106c4c:	e8 0e f1 ff ff       	call   80105d5f <argint>
80106c51:	83 c4 10             	add    $0x10,%esp
80106c54:	85 c0                	test   %eax,%eax
80106c56:	79 07                	jns    80106c5f <sys_kill+0x22>
    return -1;
80106c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5d:	eb 0f                	jmp    80106c6e <sys_kill+0x31>
  return kill(pid);
80106c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c62:	83 ec 0c             	sub    $0xc,%esp
80106c65:	50                   	push   %eax
80106c66:	e8 f3 e4 ff ff       	call   8010515e <kill>
80106c6b:	83 c4 10             	add    $0x10,%esp
}
80106c6e:	c9                   	leave  
80106c6f:	c3                   	ret    

80106c70 <sys_getpid>:

int
sys_getpid(void)
{
80106c70:	55                   	push   %ebp
80106c71:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106c73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c79:	8b 40 10             	mov    0x10(%eax),%eax
}
80106c7c:	5d                   	pop    %ebp
80106c7d:	c3                   	ret    

80106c7e <sys_sbrk>:

int
sys_sbrk(void)
{
80106c7e:	55                   	push   %ebp
80106c7f:	89 e5                	mov    %esp,%ebp
80106c81:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106c84:	83 ec 08             	sub    $0x8,%esp
80106c87:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c8a:	50                   	push   %eax
80106c8b:	6a 00                	push   $0x0
80106c8d:	e8 cd f0 ff ff       	call   80105d5f <argint>
80106c92:	83 c4 10             	add    $0x10,%esp
80106c95:	85 c0                	test   %eax,%eax
80106c97:	79 07                	jns    80106ca0 <sys_sbrk+0x22>
    return -1;
80106c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9e:	eb 28                	jmp    80106cc8 <sys_sbrk+0x4a>
  addr = proc->sz;
80106ca0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca6:	8b 00                	mov    (%eax),%eax
80106ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cae:	83 ec 0c             	sub    $0xc,%esp
80106cb1:	50                   	push   %eax
80106cb2:	e8 fe db ff ff       	call   801048b5 <growproc>
80106cb7:	83 c4 10             	add    $0x10,%esp
80106cba:	85 c0                	test   %eax,%eax
80106cbc:	79 07                	jns    80106cc5 <sys_sbrk+0x47>
    return -1;
80106cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc3:	eb 03                	jmp    80106cc8 <sys_sbrk+0x4a>
  return addr;
80106cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106cc8:	c9                   	leave  
80106cc9:	c3                   	ret    

80106cca <sys_sleep>:

int
sys_sleep(void)
{
80106cca:	55                   	push   %ebp
80106ccb:	89 e5                	mov    %esp,%ebp
80106ccd:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106cd0:	83 ec 08             	sub    $0x8,%esp
80106cd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cd6:	50                   	push   %eax
80106cd7:	6a 00                	push   $0x0
80106cd9:	e8 81 f0 ff ff       	call   80105d5f <argint>
80106cde:	83 c4 10             	add    $0x10,%esp
80106ce1:	85 c0                	test   %eax,%eax
80106ce3:	79 07                	jns    80106cec <sys_sleep+0x22>
    return -1;
80106ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cea:	eb 77                	jmp    80106d63 <sys_sleep+0x99>
  acquire(&tickslock);
80106cec:	83 ec 0c             	sub    $0xc,%esp
80106cef:	68 20 65 11 80       	push   $0x80116520
80106cf4:	e8 de ea ff ff       	call   801057d7 <acquire>
80106cf9:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106cfc:	a1 60 6d 11 80       	mov    0x80116d60,%eax
80106d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106d04:	eb 39                	jmp    80106d3f <sys_sleep+0x75>
    if(proc->killed){
80106d06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0c:	8b 40 24             	mov    0x24(%eax),%eax
80106d0f:	85 c0                	test   %eax,%eax
80106d11:	74 17                	je     80106d2a <sys_sleep+0x60>
      release(&tickslock);
80106d13:	83 ec 0c             	sub    $0xc,%esp
80106d16:	68 20 65 11 80       	push   $0x80116520
80106d1b:	e8 1e eb ff ff       	call   8010583e <release>
80106d20:	83 c4 10             	add    $0x10,%esp
      return -1;
80106d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d28:	eb 39                	jmp    80106d63 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106d2a:	83 ec 08             	sub    $0x8,%esp
80106d2d:	68 20 65 11 80       	push   $0x80116520
80106d32:	68 60 6d 11 80       	push   $0x80116d60
80106d37:	e8 df e2 ff ff       	call   8010501b <sleep>
80106d3c:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106d3f:	a1 60 6d 11 80       	mov    0x80116d60,%eax
80106d44:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106d47:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d4a:	39 d0                	cmp    %edx,%eax
80106d4c:	72 b8                	jb     80106d06 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106d4e:	83 ec 0c             	sub    $0xc,%esp
80106d51:	68 20 65 11 80       	push   $0x80116520
80106d56:	e8 e3 ea ff ff       	call   8010583e <release>
80106d5b:	83 c4 10             	add    $0x10,%esp
  return 0;
80106d5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d63:	c9                   	leave  
80106d64:	c3                   	ret    

80106d65 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106d65:	55                   	push   %ebp
80106d66:	89 e5                	mov    %esp,%ebp
80106d68:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106d6b:	83 ec 0c             	sub    $0xc,%esp
80106d6e:	68 20 65 11 80       	push   $0x80116520
80106d73:	e8 5f ea ff ff       	call   801057d7 <acquire>
80106d78:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106d7b:	a1 60 6d 11 80       	mov    0x80116d60,%eax
80106d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106d83:	83 ec 0c             	sub    $0xc,%esp
80106d86:	68 20 65 11 80       	push   $0x80116520
80106d8b:	e8 ae ea ff ff       	call   8010583e <release>
80106d90:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d96:	c9                   	leave  
80106d97:	c3                   	ret    

80106d98 <sys_procstat>:

// List the existing processes in the system and their status.
int
sys_procstat(void)
{
80106d98:	55                   	push   %ebp
80106d99:	89 e5                	mov    %esp,%ebp
80106d9b:	83 ec 08             	sub    $0x8,%esp
  cprintf("sys_procstat\n");
80106d9e:	83 ec 0c             	sub    $0xc,%esp
80106da1:	68 a7 94 10 80       	push   $0x801094a7
80106da6:	e8 1b 96 ff ff       	call   801003c6 <cprintf>
80106dab:	83 c4 10             	add    $0x10,%esp
  procdump();  // call function defined in proc.c
80106dae:	e8 36 e4 ff ff       	call   801051e9 <procdump>
  return 0;
80106db3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106db8:	c9                   	leave  
80106db9:	c3                   	ret    

80106dba <sys_setpriority>:

// Set the priority to a process.
int
sys_setpriority(void)
{
80106dba:	55                   	push   %ebp
80106dbb:	89 e5                	mov    %esp,%ebp
80106dbd:	83 ec 18             	sub    $0x18,%esp
  int level;
  //cprintf("sys_setpriority\n");
  if(argint(0, &level)<0)
80106dc0:	83 ec 08             	sub    $0x8,%esp
80106dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dc6:	50                   	push   %eax
80106dc7:	6a 00                	push   $0x0
80106dc9:	e8 91 ef ff ff       	call   80105d5f <argint>
80106dce:	83 c4 10             	add    $0x10,%esp
80106dd1:	85 c0                	test   %eax,%eax
80106dd3:	79 07                	jns    80106ddc <sys_setpriority+0x22>
    return -1;
80106dd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dda:	eb 12                	jmp    80106dee <sys_setpriority+0x34>
  proc->priority=level;
80106ddc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106de2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106de5:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  return 0;
80106de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106dee:	c9                   	leave  
80106def:	c3                   	ret    

80106df0 <sys_semget>:


int
sys_semget(void)
{
80106df0:	55                   	push   %ebp
80106df1:	89 e5                	mov    %esp,%ebp
80106df3:	83 ec 18             	sub    $0x18,%esp
  int id, value;
  if(argint(0, &id)<0)
80106df6:	83 ec 08             	sub    $0x8,%esp
80106df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dfc:	50                   	push   %eax
80106dfd:	6a 00                	push   $0x0
80106dff:	e8 5b ef ff ff       	call   80105d5f <argint>
80106e04:	83 c4 10             	add    $0x10,%esp
80106e07:	85 c0                	test   %eax,%eax
80106e09:	79 07                	jns    80106e12 <sys_semget+0x22>
    return -1;
80106e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e10:	eb 2f                	jmp    80106e41 <sys_semget+0x51>
  if(argint(1, &value)<0)
80106e12:	83 ec 08             	sub    $0x8,%esp
80106e15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e18:	50                   	push   %eax
80106e19:	6a 01                	push   $0x1
80106e1b:	e8 3f ef ff ff       	call   80105d5f <argint>
80106e20:	83 c4 10             	add    $0x10,%esp
80106e23:	85 c0                	test   %eax,%eax
80106e25:	79 07                	jns    80106e2e <sys_semget+0x3e>
    return -1;
80106e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e2c:	eb 13                	jmp    80106e41 <sys_semget+0x51>
  return semget(id,value);
80106e2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e34:	83 ec 08             	sub    $0x8,%esp
80106e37:	52                   	push   %edx
80106e38:	50                   	push   %eax
80106e39:	e8 b4 e5 ff ff       	call   801053f2 <semget>
80106e3e:	83 c4 10             	add    $0x10,%esp
}
80106e41:	c9                   	leave  
80106e42:	c3                   	ret    

80106e43 <sys_semfree>:


int
sys_semfree(void)
{
80106e43:	55                   	push   %ebp
80106e44:	89 e5                	mov    %esp,%ebp
80106e46:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80106e49:	83 ec 08             	sub    $0x8,%esp
80106e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e4f:	50                   	push   %eax
80106e50:	6a 00                	push   $0x0
80106e52:	e8 08 ef ff ff       	call   80105d5f <argint>
80106e57:	83 c4 10             	add    $0x10,%esp
80106e5a:	85 c0                	test   %eax,%eax
80106e5c:	79 07                	jns    80106e65 <sys_semfree+0x22>
    return -1;
80106e5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e63:	eb 0f                	jmp    80106e74 <sys_semfree+0x31>
  return semfree(id);
80106e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e68:	83 ec 0c             	sub    $0xc,%esp
80106e6b:	50                   	push   %eax
80106e6c:	e8 b3 e6 ff ff       	call   80105524 <semfree>
80106e71:	83 c4 10             	add    $0x10,%esp
}
80106e74:	c9                   	leave  
80106e75:	c3                   	ret    

80106e76 <sys_semdown>:


int
sys_semdown(void)
{
80106e76:	55                   	push   %ebp
80106e77:	89 e5                	mov    %esp,%ebp
80106e79:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80106e7c:	83 ec 08             	sub    $0x8,%esp
80106e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e82:	50                   	push   %eax
80106e83:	6a 00                	push   $0x0
80106e85:	e8 d5 ee ff ff       	call   80105d5f <argint>
80106e8a:	83 c4 10             	add    $0x10,%esp
80106e8d:	85 c0                	test   %eax,%eax
80106e8f:	79 07                	jns    80106e98 <sys_semdown+0x22>
    return -1;
80106e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e96:	eb 0f                	jmp    80106ea7 <sys_semdown+0x31>
  return semdown(id);
80106e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9b:	83 ec 0c             	sub    $0xc,%esp
80106e9e:	50                   	push   %eax
80106e9f:	e8 1b e7 ff ff       	call   801055bf <semdown>
80106ea4:	83 c4 10             	add    $0x10,%esp
}
80106ea7:	c9                   	leave  
80106ea8:	c3                   	ret    

80106ea9 <sys_semup>:


int
sys_semup(void)
{
80106ea9:	55                   	push   %ebp
80106eaa:	89 e5                	mov    %esp,%ebp
80106eac:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80106eaf:	83 ec 08             	sub    $0x8,%esp
80106eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106eb5:	50                   	push   %eax
80106eb6:	6a 00                	push   $0x0
80106eb8:	e8 a2 ee ff ff       	call   80105d5f <argint>
80106ebd:	83 c4 10             	add    $0x10,%esp
80106ec0:	85 c0                	test   %eax,%eax
80106ec2:	79 07                	jns    80106ecb <sys_semup+0x22>
    return -1;
80106ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ec9:	eb 0f                	jmp    80106eda <sys_semup+0x31>
  return semup(id);
80106ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ece:	83 ec 0c             	sub    $0xc,%esp
80106ed1:	50                   	push   %eax
80106ed2:	e8 7b e7 ff ff       	call   80105652 <semup>
80106ed7:	83 c4 10             	add    $0x10,%esp
}
80106eda:	c9                   	leave  
80106edb:	c3                   	ret    

80106edc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106edc:	55                   	push   %ebp
80106edd:	89 e5                	mov    %esp,%ebp
80106edf:	83 ec 08             	sub    $0x8,%esp
80106ee2:	8b 55 08             	mov    0x8(%ebp),%edx
80106ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ee8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106eec:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106eef:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ef3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ef7:	ee                   	out    %al,(%dx)
}
80106ef8:	90                   	nop
80106ef9:	c9                   	leave  
80106efa:	c3                   	ret    

80106efb <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106efb:	55                   	push   %ebp
80106efc:	89 e5                	mov    %esp,%ebp
80106efe:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106f01:	6a 34                	push   $0x34
80106f03:	6a 43                	push   $0x43
80106f05:	e8 d2 ff ff ff       	call   80106edc <outb>
80106f0a:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106f0d:	68 9c 00 00 00       	push   $0x9c
80106f12:	6a 40                	push   $0x40
80106f14:	e8 c3 ff ff ff       	call   80106edc <outb>
80106f19:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106f1c:	6a 2e                	push   $0x2e
80106f1e:	6a 40                	push   $0x40
80106f20:	e8 b7 ff ff ff       	call   80106edc <outb>
80106f25:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106f28:	83 ec 0c             	sub    $0xc,%esp
80106f2b:	6a 00                	push   $0x0
80106f2d:	e8 72 cf ff ff       	call   80103ea4 <picenable>
80106f32:	83 c4 10             	add    $0x10,%esp
}
80106f35:	90                   	nop
80106f36:	c9                   	leave  
80106f37:	c3                   	ret    

80106f38 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106f38:	1e                   	push   %ds
  pushl %es
80106f39:	06                   	push   %es
  pushl %fs
80106f3a:	0f a0                	push   %fs
  pushl %gs
80106f3c:	0f a8                	push   %gs
  pushal
80106f3e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106f3f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106f43:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106f45:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106f47:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106f4b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106f4d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106f4f:	54                   	push   %esp
  call trap
80106f50:	e8 d7 01 00 00       	call   8010712c <trap>
  addl $4, %esp
80106f55:	83 c4 04             	add    $0x4,%esp

80106f58 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106f58:	61                   	popa   
  popl %gs
80106f59:	0f a9                	pop    %gs
  popl %fs
80106f5b:	0f a1                	pop    %fs
  popl %es
80106f5d:	07                   	pop    %es
  popl %ds
80106f5e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106f5f:	83 c4 08             	add    $0x8,%esp
  iret
80106f62:	cf                   	iret   

80106f63 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106f63:	55                   	push   %ebp
80106f64:	89 e5                	mov    %esp,%ebp
80106f66:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f6c:	83 e8 01             	sub    $0x1,%eax
80106f6f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f73:	8b 45 08             	mov    0x8(%ebp),%eax
80106f76:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7d:	c1 e8 10             	shr    $0x10,%eax
80106f80:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106f84:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f87:	0f 01 18             	lidtl  (%eax)
}
80106f8a:	90                   	nop
80106f8b:	c9                   	leave  
80106f8c:	c3                   	ret    

80106f8d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106f8d:	55                   	push   %ebp
80106f8e:	89 e5                	mov    %esp,%ebp
80106f90:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106f93:	0f 20 d0             	mov    %cr2,%eax
80106f96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106f99:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f9c:	c9                   	leave  
80106f9d:	c3                   	ret    

80106f9e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106f9e:	55                   	push   %ebp
80106f9f:	89 e5                	mov    %esp,%ebp
80106fa1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106fa4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106fab:	e9 c3 00 00 00       	jmp    80107073 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb3:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106fba:	89 c2                	mov    %eax,%edx
80106fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fbf:	66 89 14 c5 60 65 11 	mov    %dx,-0x7fee9aa0(,%eax,8)
80106fc6:	80 
80106fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fca:	66 c7 04 c5 62 65 11 	movw   $0x8,-0x7fee9a9e(,%eax,8)
80106fd1:	80 08 00 
80106fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd7:	0f b6 14 c5 64 65 11 	movzbl -0x7fee9a9c(,%eax,8),%edx
80106fde:	80 
80106fdf:	83 e2 e0             	and    $0xffffffe0,%edx
80106fe2:	88 14 c5 64 65 11 80 	mov    %dl,-0x7fee9a9c(,%eax,8)
80106fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fec:	0f b6 14 c5 64 65 11 	movzbl -0x7fee9a9c(,%eax,8),%edx
80106ff3:	80 
80106ff4:	83 e2 1f             	and    $0x1f,%edx
80106ff7:	88 14 c5 64 65 11 80 	mov    %dl,-0x7fee9a9c(,%eax,8)
80106ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107001:	0f b6 14 c5 65 65 11 	movzbl -0x7fee9a9b(,%eax,8),%edx
80107008:	80 
80107009:	83 e2 f0             	and    $0xfffffff0,%edx
8010700c:	83 ca 0e             	or     $0xe,%edx
8010700f:	88 14 c5 65 65 11 80 	mov    %dl,-0x7fee9a9b(,%eax,8)
80107016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107019:	0f b6 14 c5 65 65 11 	movzbl -0x7fee9a9b(,%eax,8),%edx
80107020:	80 
80107021:	83 e2 ef             	and    $0xffffffef,%edx
80107024:	88 14 c5 65 65 11 80 	mov    %dl,-0x7fee9a9b(,%eax,8)
8010702b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702e:	0f b6 14 c5 65 65 11 	movzbl -0x7fee9a9b(,%eax,8),%edx
80107035:	80 
80107036:	83 e2 9f             	and    $0xffffff9f,%edx
80107039:	88 14 c5 65 65 11 80 	mov    %dl,-0x7fee9a9b(,%eax,8)
80107040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107043:	0f b6 14 c5 65 65 11 	movzbl -0x7fee9a9b(,%eax,8),%edx
8010704a:	80 
8010704b:	83 ca 80             	or     $0xffffff80,%edx
8010704e:	88 14 c5 65 65 11 80 	mov    %dl,-0x7fee9a9b(,%eax,8)
80107055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107058:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
8010705f:	c1 e8 10             	shr    $0x10,%eax
80107062:	89 c2                	mov    %eax,%edx
80107064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107067:	66 89 14 c5 66 65 11 	mov    %dx,-0x7fee9a9a(,%eax,8)
8010706e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010706f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107073:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010707a:	0f 8e 30 ff ff ff    	jle    80106fb0 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107080:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80107085:	66 a3 60 67 11 80    	mov    %ax,0x80116760
8010708b:	66 c7 05 62 67 11 80 	movw   $0x8,0x80116762
80107092:	08 00 
80107094:	0f b6 05 64 67 11 80 	movzbl 0x80116764,%eax
8010709b:	83 e0 e0             	and    $0xffffffe0,%eax
8010709e:	a2 64 67 11 80       	mov    %al,0x80116764
801070a3:	0f b6 05 64 67 11 80 	movzbl 0x80116764,%eax
801070aa:	83 e0 1f             	and    $0x1f,%eax
801070ad:	a2 64 67 11 80       	mov    %al,0x80116764
801070b2:	0f b6 05 65 67 11 80 	movzbl 0x80116765,%eax
801070b9:	83 c8 0f             	or     $0xf,%eax
801070bc:	a2 65 67 11 80       	mov    %al,0x80116765
801070c1:	0f b6 05 65 67 11 80 	movzbl 0x80116765,%eax
801070c8:	83 e0 ef             	and    $0xffffffef,%eax
801070cb:	a2 65 67 11 80       	mov    %al,0x80116765
801070d0:	0f b6 05 65 67 11 80 	movzbl 0x80116765,%eax
801070d7:	83 c8 60             	or     $0x60,%eax
801070da:	a2 65 67 11 80       	mov    %al,0x80116765
801070df:	0f b6 05 65 67 11 80 	movzbl 0x80116765,%eax
801070e6:	83 c8 80             	or     $0xffffff80,%eax
801070e9:	a2 65 67 11 80       	mov    %al,0x80116765
801070ee:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
801070f3:	c1 e8 10             	shr    $0x10,%eax
801070f6:	66 a3 66 67 11 80    	mov    %ax,0x80116766

  initlock(&tickslock, "time");
801070fc:	83 ec 08             	sub    $0x8,%esp
801070ff:	68 b8 94 10 80       	push   $0x801094b8
80107104:	68 20 65 11 80       	push   $0x80116520
80107109:	e8 a7 e6 ff ff       	call   801057b5 <initlock>
8010710e:	83 c4 10             	add    $0x10,%esp
}
80107111:	90                   	nop
80107112:	c9                   	leave  
80107113:	c3                   	ret    

80107114 <idtinit>:

void
idtinit(void)
{
80107114:	55                   	push   %ebp
80107115:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107117:	68 00 08 00 00       	push   $0x800
8010711c:	68 60 65 11 80       	push   $0x80116560
80107121:	e8 3d fe ff ff       	call   80106f63 <lidt>
80107126:	83 c4 08             	add    $0x8,%esp
}
80107129:	90                   	nop
8010712a:	c9                   	leave  
8010712b:	c3                   	ret    

8010712c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010712c:	55                   	push   %ebp
8010712d:	89 e5                	mov    %esp,%ebp
8010712f:	57                   	push   %edi
80107130:	56                   	push   %esi
80107131:	53                   	push   %ebx
80107132:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80107135:	8b 45 08             	mov    0x8(%ebp),%eax
80107138:	8b 40 30             	mov    0x30(%eax),%eax
8010713b:	83 f8 40             	cmp    $0x40,%eax
8010713e:	75 3e                	jne    8010717e <trap+0x52>
    if(proc->killed)
80107140:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107146:	8b 40 24             	mov    0x24(%eax),%eax
80107149:	85 c0                	test   %eax,%eax
8010714b:	74 05                	je     80107152 <trap+0x26>
      exit();
8010714d:	e8 02 da ff ff       	call   80104b54 <exit>
    proc->tf = tf;
80107152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107158:	8b 55 08             	mov    0x8(%ebp),%edx
8010715b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010715e:	e8 b2 ec ff ff       	call   80105e15 <syscall>
    if(proc->killed)
80107163:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107169:	8b 40 24             	mov    0x24(%eax),%eax
8010716c:	85 c0                	test   %eax,%eax
8010716e:	0f 84 15 03 00 00    	je     80107489 <trap+0x35d>
      exit();
80107174:	e8 db d9 ff ff       	call   80104b54 <exit>
    return;
80107179:	e9 0b 03 00 00       	jmp    80107489 <trap+0x35d>
  }

  switch(tf->trapno){
8010717e:	8b 45 08             	mov    0x8(%ebp),%eax
80107181:	8b 40 30             	mov    0x30(%eax),%eax
80107184:	83 e8 20             	sub    $0x20,%eax
80107187:	83 f8 1f             	cmp    $0x1f,%eax
8010718a:	0f 87 c0 00 00 00    	ja     80107250 <trap+0x124>
80107190:	8b 04 85 b0 95 10 80 	mov    -0x7fef6a50(,%eax,4),%eax
80107197:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107199:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010719f:	0f b6 00             	movzbl (%eax),%eax
801071a2:	84 c0                	test   %al,%al
801071a4:	75 3d                	jne    801071e3 <trap+0xb7>
      acquire(&tickslock);
801071a6:	83 ec 0c             	sub    $0xc,%esp
801071a9:	68 20 65 11 80       	push   $0x80116520
801071ae:	e8 24 e6 ff ff       	call   801057d7 <acquire>
801071b3:	83 c4 10             	add    $0x10,%esp
      ticks++;
801071b6:	a1 60 6d 11 80       	mov    0x80116d60,%eax
801071bb:	83 c0 01             	add    $0x1,%eax
801071be:	a3 60 6d 11 80       	mov    %eax,0x80116d60
      wakeup(&ticks);
801071c3:	83 ec 0c             	sub    $0xc,%esp
801071c6:	68 60 6d 11 80       	push   $0x80116d60
801071cb:	e8 57 df ff ff       	call   80105127 <wakeup>
801071d0:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801071d3:	83 ec 0c             	sub    $0xc,%esp
801071d6:	68 20 65 11 80       	push   $0x80116520
801071db:	e8 5e e6 ff ff       	call   8010583e <release>
801071e0:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801071e3:	e8 a4 bd ff ff       	call   80102f8c <lapiceoi>
    break;
801071e8:	e9 c0 01 00 00       	jmp    801073ad <trap+0x281>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801071ed:	e8 ad b5 ff ff       	call   8010279f <ideintr>
    lapiceoi();
801071f2:	e8 95 bd ff ff       	call   80102f8c <lapiceoi>
    break;
801071f7:	e9 b1 01 00 00       	jmp    801073ad <trap+0x281>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801071fc:	e8 8d bb ff ff       	call   80102d8e <kbdintr>
    lapiceoi();
80107201:	e8 86 bd ff ff       	call   80102f8c <lapiceoi>
    break;
80107206:	e9 a2 01 00 00       	jmp    801073ad <trap+0x281>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010720b:	e8 5a 04 00 00       	call   8010766a <uartintr>
    lapiceoi();
80107210:	e8 77 bd ff ff       	call   80102f8c <lapiceoi>
    break;
80107215:	e9 93 01 00 00       	jmp    801073ad <trap+0x281>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010721a:	8b 45 08             	mov    0x8(%ebp),%eax
8010721d:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107220:	8b 45 08             	mov    0x8(%ebp),%eax
80107223:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107227:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010722a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107230:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107233:	0f b6 c0             	movzbl %al,%eax
80107236:	51                   	push   %ecx
80107237:	52                   	push   %edx
80107238:	50                   	push   %eax
80107239:	68 c0 94 10 80       	push   $0x801094c0
8010723e:	e8 83 91 ff ff       	call   801003c6 <cprintf>
80107243:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107246:	e8 41 bd ff ff       	call   80102f8c <lapiceoi>
    break;
8010724b:	e9 5d 01 00 00       	jmp    801073ad <trap+0x281>

  //PAGEBREAK: 13
  default:

    if(proc && tf->trapno == T_PGFLT){
80107250:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107256:	85 c0                	test   %eax,%eax
80107258:	0f 84 93 00 00 00    	je     801072f1 <trap+0x1c5>
8010725e:	8b 45 08             	mov    0x8(%ebp),%eax
80107261:	8b 40 30             	mov    0x30(%eax),%eax
80107264:	83 f8 0e             	cmp    $0xe,%eax
80107267:	0f 85 84 00 00 00    	jne    801072f1 <trap+0x1c5>
      uint cr2=rcr2();
8010726d:	e8 1b fd ff ff       	call   80106f8d <rcr2>
80107272:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint basepgaddr;


      //  Verify if you wanted to access a correct address but not assigned.
      //  if appropriate, assign one more page to the stack.
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
80107275:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010727b:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80107281:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80107284:	77 6b                	ja     801072f1 <trap+0x1c5>
80107286:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010728c:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80107292:	05 00 80 00 00       	add    $0x8000,%eax
80107297:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010729a:	76 55                	jbe    801072f1 <trap+0x1c5>
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
8010729c:	83 ec 08             	sub    $0x8,%esp
8010729f:	ff 75 e4             	pushl  -0x1c(%ebp)
801072a2:	68 e4 94 10 80       	push   $0x801094e4
801072a7:	e8 1a 91 ff ff       	call   801003c6 <cprintf>
801072ac:	83 c4 10             	add    $0x10,%esp
        basepgaddr=PGROUNDDOWN(cr2);
801072af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
801072ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801072bd:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
801072c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072c9:	8b 40 04             	mov    0x4(%eax),%eax
801072cc:	83 ec 04             	sub    $0x4,%esp
801072cf:	52                   	push   %edx
801072d0:	ff 75 e0             	pushl  -0x20(%ebp)
801072d3:	50                   	push   %eax
801072d4:	e8 e5 17 00 00       	call   80108abe <allocuvm>
801072d9:	83 c4 10             	add    $0x10,%esp
801072dc:	85 c0                	test   %eax,%eax
801072de:	0f 85 c8 00 00 00    	jne    801073ac <trap+0x280>
          panic("trap alloc stack");
801072e4:	83 ec 0c             	sub    $0xc,%esp
801072e7:	68 20 95 10 80       	push   $0x80109520
801072ec:	e8 75 92 ff ff       	call   80100566 <panic>
        break;
      }
    }

    if(proc == 0 || (tf->cs&3) == 0){
801072f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072f7:	85 c0                	test   %eax,%eax
801072f9:	74 11                	je     8010730c <trap+0x1e0>
801072fb:	8b 45 08             	mov    0x8(%ebp),%eax
801072fe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107302:	0f b7 c0             	movzwl %ax,%eax
80107305:	83 e0 03             	and    $0x3,%eax
80107308:	85 c0                	test   %eax,%eax
8010730a:	75 40                	jne    8010734c <trap+0x220>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010730c:	e8 7c fc ff ff       	call   80106f8d <rcr2>
80107311:	89 c3                	mov    %eax,%ebx
80107313:	8b 45 08             	mov    0x8(%ebp),%eax
80107316:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107319:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010731f:	0f b6 00             	movzbl (%eax),%eax
      }
    }

    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107322:	0f b6 d0             	movzbl %al,%edx
80107325:	8b 45 08             	mov    0x8(%ebp),%eax
80107328:	8b 40 30             	mov    0x30(%eax),%eax
8010732b:	83 ec 0c             	sub    $0xc,%esp
8010732e:	53                   	push   %ebx
8010732f:	51                   	push   %ecx
80107330:	52                   	push   %edx
80107331:	50                   	push   %eax
80107332:	68 34 95 10 80       	push   $0x80109534
80107337:	e8 8a 90 ff ff       	call   801003c6 <cprintf>
8010733c:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010733f:	83 ec 0c             	sub    $0xc,%esp
80107342:	68 66 95 10 80       	push   $0x80109566
80107347:	e8 1a 92 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010734c:	e8 3c fc ff ff       	call   80106f8d <rcr2>
80107351:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107354:	8b 45 08             	mov    0x8(%ebp),%eax
80107357:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010735a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107360:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107363:	0f b6 d8             	movzbl %al,%ebx
80107366:	8b 45 08             	mov    0x8(%ebp),%eax
80107369:	8b 48 34             	mov    0x34(%eax),%ecx
8010736c:	8b 45 08             	mov    0x8(%ebp),%eax
8010736f:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107372:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107378:	8d 78 6c             	lea    0x6c(%eax),%edi
8010737b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107381:	8b 40 10             	mov    0x10(%eax),%eax
80107384:	ff 75 d4             	pushl  -0x2c(%ebp)
80107387:	56                   	push   %esi
80107388:	53                   	push   %ebx
80107389:	51                   	push   %ecx
8010738a:	52                   	push   %edx
8010738b:	57                   	push   %edi
8010738c:	50                   	push   %eax
8010738d:	68 6c 95 10 80       	push   $0x8010956c
80107392:	e8 2f 90 ff ff       	call   801003c6 <cprintf>
80107397:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
8010739a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801073a7:	eb 04                	jmp    801073ad <trap+0x281>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801073a9:	90                   	nop
801073aa:	eb 01                	jmp    801073ad <trap+0x281>
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
        basepgaddr=PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        break;
801073ac:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801073ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073b3:	85 c0                	test   %eax,%eax
801073b5:	74 24                	je     801073db <trap+0x2af>
801073b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073bd:	8b 40 24             	mov    0x24(%eax),%eax
801073c0:	85 c0                	test   %eax,%eax
801073c2:	74 17                	je     801073db <trap+0x2af>
801073c4:	8b 45 08             	mov    0x8(%ebp),%eax
801073c7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801073cb:	0f b7 c0             	movzwl %ax,%eax
801073ce:	83 e0 03             	and    $0x3,%eax
801073d1:	83 f8 03             	cmp    $0x3,%eax
801073d4:	75 05                	jne    801073db <trap+0x2af>
    exit();
801073d6:	e8 79 d7 ff ff       	call   80104b54 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
801073db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073e1:	85 c0                	test   %eax,%eax
801073e3:	74 41                	je     80107426 <trap+0x2fa>
801073e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073eb:	8b 40 0c             	mov    0xc(%eax),%eax
801073ee:	83 f8 04             	cmp    $0x4,%eax
801073f1:	75 33                	jne    80107426 <trap+0x2fa>
801073f3:	8b 45 08             	mov    0x8(%ebp),%eax
801073f6:	8b 40 30             	mov    0x30(%eax),%eax
801073f9:	83 f8 20             	cmp    $0x20,%eax
801073fc:	75 28                	jne    80107426 <trap+0x2fa>
    if(proc->ticks++ == QUANTUM-1){  // Check if the amount of ticks of the current process reached the Quantum
801073fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107404:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
80107408:	8d 4a 01             	lea    0x1(%edx),%ecx
8010740b:	66 89 48 7c          	mov    %cx,0x7c(%eax)
8010740f:	66 83 fa 04          	cmp    $0x4,%dx
80107413:	75 11                	jne    80107426 <trap+0x2fa>
      //cprintf("El proceso con id %d tiene %d ticks\n",proc->pid, proc->ticks);
      proc->ticks=0;  // Restarts the amount of process ticks
80107415:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010741b:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
80107421:	e8 63 db ff ff       	call   80104f89 <yield>
    }

  }
  // check if the number of ticks was reached to increase the ages.
  if((tf->trapno == T_IRQ0+IRQ_TIMER) && (ticks % TICKSFORAGE == 0))
80107426:	8b 45 08             	mov    0x8(%ebp),%eax
80107429:	8b 40 30             	mov    0x30(%eax),%eax
8010742c:	83 f8 20             	cmp    $0x20,%eax
8010742f:	75 28                	jne    80107459 <trap+0x32d>
80107431:	8b 0d 60 6d 11 80    	mov    0x80116d60,%ecx
80107437:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010743c:	89 c8                	mov    %ecx,%eax
8010743e:	f7 e2                	mul    %edx
80107440:	c1 ea 03             	shr    $0x3,%edx
80107443:	89 d0                	mov    %edx,%eax
80107445:	c1 e0 02             	shl    $0x2,%eax
80107448:	01 d0                	add    %edx,%eax
8010744a:	01 c0                	add    %eax,%eax
8010744c:	29 c1                	sub    %eax,%ecx
8010744e:	89 ca                	mov    %ecx,%edx
80107450:	85 d2                	test   %edx,%edx
80107452:	75 05                	jne    80107459 <trap+0x32d>
    calculateaging();
80107454:	e8 1b d1 ff ff       	call   80104574 <calculateaging>


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010745f:	85 c0                	test   %eax,%eax
80107461:	74 27                	je     8010748a <trap+0x35e>
80107463:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107469:	8b 40 24             	mov    0x24(%eax),%eax
8010746c:	85 c0                	test   %eax,%eax
8010746e:	74 1a                	je     8010748a <trap+0x35e>
80107470:	8b 45 08             	mov    0x8(%ebp),%eax
80107473:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107477:	0f b7 c0             	movzwl %ax,%eax
8010747a:	83 e0 03             	and    $0x3,%eax
8010747d:	83 f8 03             	cmp    $0x3,%eax
80107480:	75 08                	jne    8010748a <trap+0x35e>
    exit();
80107482:	e8 cd d6 ff ff       	call   80104b54 <exit>
80107487:	eb 01                	jmp    8010748a <trap+0x35e>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107489:	90                   	nop


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010748a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010748d:	5b                   	pop    %ebx
8010748e:	5e                   	pop    %esi
8010748f:	5f                   	pop    %edi
80107490:	5d                   	pop    %ebp
80107491:	c3                   	ret    

80107492 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107492:	55                   	push   %ebp
80107493:	89 e5                	mov    %esp,%ebp
80107495:	83 ec 14             	sub    $0x14,%esp
80107498:	8b 45 08             	mov    0x8(%ebp),%eax
8010749b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010749f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801074a3:	89 c2                	mov    %eax,%edx
801074a5:	ec                   	in     (%dx),%al
801074a6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801074a9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801074ad:	c9                   	leave  
801074ae:	c3                   	ret    

801074af <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801074af:	55                   	push   %ebp
801074b0:	89 e5                	mov    %esp,%ebp
801074b2:	83 ec 08             	sub    $0x8,%esp
801074b5:	8b 55 08             	mov    0x8(%ebp),%edx
801074b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801074bb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801074bf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801074c2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801074c6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801074ca:	ee                   	out    %al,(%dx)
}
801074cb:	90                   	nop
801074cc:	c9                   	leave  
801074cd:	c3                   	ret    

801074ce <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801074ce:	55                   	push   %ebp
801074cf:	89 e5                	mov    %esp,%ebp
801074d1:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801074d4:	6a 00                	push   $0x0
801074d6:	68 fa 03 00 00       	push   $0x3fa
801074db:	e8 cf ff ff ff       	call   801074af <outb>
801074e0:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801074e3:	68 80 00 00 00       	push   $0x80
801074e8:	68 fb 03 00 00       	push   $0x3fb
801074ed:	e8 bd ff ff ff       	call   801074af <outb>
801074f2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801074f5:	6a 0c                	push   $0xc
801074f7:	68 f8 03 00 00       	push   $0x3f8
801074fc:	e8 ae ff ff ff       	call   801074af <outb>
80107501:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107504:	6a 00                	push   $0x0
80107506:	68 f9 03 00 00       	push   $0x3f9
8010750b:	e8 9f ff ff ff       	call   801074af <outb>
80107510:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107513:	6a 03                	push   $0x3
80107515:	68 fb 03 00 00       	push   $0x3fb
8010751a:	e8 90 ff ff ff       	call   801074af <outb>
8010751f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107522:	6a 00                	push   $0x0
80107524:	68 fc 03 00 00       	push   $0x3fc
80107529:	e8 81 ff ff ff       	call   801074af <outb>
8010752e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107531:	6a 01                	push   $0x1
80107533:	68 f9 03 00 00       	push   $0x3f9
80107538:	e8 72 ff ff ff       	call   801074af <outb>
8010753d:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107540:	68 fd 03 00 00       	push   $0x3fd
80107545:	e8 48 ff ff ff       	call   80107492 <inb>
8010754a:	83 c4 04             	add    $0x4,%esp
8010754d:	3c ff                	cmp    $0xff,%al
8010754f:	74 6e                	je     801075bf <uartinit+0xf1>
    return;
  uart = 1;
80107551:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107558:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010755b:	68 fa 03 00 00       	push   $0x3fa
80107560:	e8 2d ff ff ff       	call   80107492 <inb>
80107565:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107568:	68 f8 03 00 00       	push   $0x3f8
8010756d:	e8 20 ff ff ff       	call   80107492 <inb>
80107572:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107575:	83 ec 0c             	sub    $0xc,%esp
80107578:	6a 04                	push   $0x4
8010757a:	e8 25 c9 ff ff       	call   80103ea4 <picenable>
8010757f:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107582:	83 ec 08             	sub    $0x8,%esp
80107585:	6a 00                	push   $0x0
80107587:	6a 04                	push   $0x4
80107589:	e8 b3 b4 ff ff       	call   80102a41 <ioapicenable>
8010758e:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107591:	c7 45 f4 30 96 10 80 	movl   $0x80109630,-0xc(%ebp)
80107598:	eb 19                	jmp    801075b3 <uartinit+0xe5>
    uartputc(*p);
8010759a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759d:	0f b6 00             	movzbl (%eax),%eax
801075a0:	0f be c0             	movsbl %al,%eax
801075a3:	83 ec 0c             	sub    $0xc,%esp
801075a6:	50                   	push   %eax
801075a7:	e8 16 00 00 00       	call   801075c2 <uartputc>
801075ac:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801075af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b6:	0f b6 00             	movzbl (%eax),%eax
801075b9:	84 c0                	test   %al,%al
801075bb:	75 dd                	jne    8010759a <uartinit+0xcc>
801075bd:	eb 01                	jmp    801075c0 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801075bf:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801075c0:	c9                   	leave  
801075c1:	c3                   	ret    

801075c2 <uartputc>:

void
uartputc(int c)
{
801075c2:	55                   	push   %ebp
801075c3:	89 e5                	mov    %esp,%ebp
801075c5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801075c8:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801075cd:	85 c0                	test   %eax,%eax
801075cf:	74 53                	je     80107624 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801075d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801075d8:	eb 11                	jmp    801075eb <uartputc+0x29>
    microdelay(10);
801075da:	83 ec 0c             	sub    $0xc,%esp
801075dd:	6a 0a                	push   $0xa
801075df:	e8 c3 b9 ff ff       	call   80102fa7 <microdelay>
801075e4:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801075e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075eb:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801075ef:	7f 1a                	jg     8010760b <uartputc+0x49>
801075f1:	83 ec 0c             	sub    $0xc,%esp
801075f4:	68 fd 03 00 00       	push   $0x3fd
801075f9:	e8 94 fe ff ff       	call   80107492 <inb>
801075fe:	83 c4 10             	add    $0x10,%esp
80107601:	0f b6 c0             	movzbl %al,%eax
80107604:	83 e0 20             	and    $0x20,%eax
80107607:	85 c0                	test   %eax,%eax
80107609:	74 cf                	je     801075da <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010760b:	8b 45 08             	mov    0x8(%ebp),%eax
8010760e:	0f b6 c0             	movzbl %al,%eax
80107611:	83 ec 08             	sub    $0x8,%esp
80107614:	50                   	push   %eax
80107615:	68 f8 03 00 00       	push   $0x3f8
8010761a:	e8 90 fe ff ff       	call   801074af <outb>
8010761f:	83 c4 10             	add    $0x10,%esp
80107622:	eb 01                	jmp    80107625 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107624:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107625:	c9                   	leave  
80107626:	c3                   	ret    

80107627 <uartgetc>:

static int
uartgetc(void)
{
80107627:	55                   	push   %ebp
80107628:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010762a:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010762f:	85 c0                	test   %eax,%eax
80107631:	75 07                	jne    8010763a <uartgetc+0x13>
    return -1;
80107633:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107638:	eb 2e                	jmp    80107668 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010763a:	68 fd 03 00 00       	push   $0x3fd
8010763f:	e8 4e fe ff ff       	call   80107492 <inb>
80107644:	83 c4 04             	add    $0x4,%esp
80107647:	0f b6 c0             	movzbl %al,%eax
8010764a:	83 e0 01             	and    $0x1,%eax
8010764d:	85 c0                	test   %eax,%eax
8010764f:	75 07                	jne    80107658 <uartgetc+0x31>
    return -1;
80107651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107656:	eb 10                	jmp    80107668 <uartgetc+0x41>
  return inb(COM1+0);
80107658:	68 f8 03 00 00       	push   $0x3f8
8010765d:	e8 30 fe ff ff       	call   80107492 <inb>
80107662:	83 c4 04             	add    $0x4,%esp
80107665:	0f b6 c0             	movzbl %al,%eax
}
80107668:	c9                   	leave  
80107669:	c3                   	ret    

8010766a <uartintr>:

void
uartintr(void)
{
8010766a:	55                   	push   %ebp
8010766b:	89 e5                	mov    %esp,%ebp
8010766d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107670:	83 ec 0c             	sub    $0xc,%esp
80107673:	68 27 76 10 80       	push   $0x80107627
80107678:	e8 60 91 ff ff       	call   801007dd <consoleintr>
8010767d:	83 c4 10             	add    $0x10,%esp
}
80107680:	90                   	nop
80107681:	c9                   	leave  
80107682:	c3                   	ret    

80107683 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $0
80107685:	6a 00                	push   $0x0
  jmp alltraps
80107687:	e9 ac f8 ff ff       	jmp    80106f38 <alltraps>

8010768c <vector1>:
.globl vector1
vector1:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $1
8010768e:	6a 01                	push   $0x1
  jmp alltraps
80107690:	e9 a3 f8 ff ff       	jmp    80106f38 <alltraps>

80107695 <vector2>:
.globl vector2
vector2:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $2
80107697:	6a 02                	push   $0x2
  jmp alltraps
80107699:	e9 9a f8 ff ff       	jmp    80106f38 <alltraps>

8010769e <vector3>:
.globl vector3
vector3:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $3
801076a0:	6a 03                	push   $0x3
  jmp alltraps
801076a2:	e9 91 f8 ff ff       	jmp    80106f38 <alltraps>

801076a7 <vector4>:
.globl vector4
vector4:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $4
801076a9:	6a 04                	push   $0x4
  jmp alltraps
801076ab:	e9 88 f8 ff ff       	jmp    80106f38 <alltraps>

801076b0 <vector5>:
.globl vector5
vector5:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $5
801076b2:	6a 05                	push   $0x5
  jmp alltraps
801076b4:	e9 7f f8 ff ff       	jmp    80106f38 <alltraps>

801076b9 <vector6>:
.globl vector6
vector6:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $6
801076bb:	6a 06                	push   $0x6
  jmp alltraps
801076bd:	e9 76 f8 ff ff       	jmp    80106f38 <alltraps>

801076c2 <vector7>:
.globl vector7
vector7:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $7
801076c4:	6a 07                	push   $0x7
  jmp alltraps
801076c6:	e9 6d f8 ff ff       	jmp    80106f38 <alltraps>

801076cb <vector8>:
.globl vector8
vector8:
  pushl $8
801076cb:	6a 08                	push   $0x8
  jmp alltraps
801076cd:	e9 66 f8 ff ff       	jmp    80106f38 <alltraps>

801076d2 <vector9>:
.globl vector9
vector9:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $9
801076d4:	6a 09                	push   $0x9
  jmp alltraps
801076d6:	e9 5d f8 ff ff       	jmp    80106f38 <alltraps>

801076db <vector10>:
.globl vector10
vector10:
  pushl $10
801076db:	6a 0a                	push   $0xa
  jmp alltraps
801076dd:	e9 56 f8 ff ff       	jmp    80106f38 <alltraps>

801076e2 <vector11>:
.globl vector11
vector11:
  pushl $11
801076e2:	6a 0b                	push   $0xb
  jmp alltraps
801076e4:	e9 4f f8 ff ff       	jmp    80106f38 <alltraps>

801076e9 <vector12>:
.globl vector12
vector12:
  pushl $12
801076e9:	6a 0c                	push   $0xc
  jmp alltraps
801076eb:	e9 48 f8 ff ff       	jmp    80106f38 <alltraps>

801076f0 <vector13>:
.globl vector13
vector13:
  pushl $13
801076f0:	6a 0d                	push   $0xd
  jmp alltraps
801076f2:	e9 41 f8 ff ff       	jmp    80106f38 <alltraps>

801076f7 <vector14>:
.globl vector14
vector14:
  pushl $14
801076f7:	6a 0e                	push   $0xe
  jmp alltraps
801076f9:	e9 3a f8 ff ff       	jmp    80106f38 <alltraps>

801076fe <vector15>:
.globl vector15
vector15:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $15
80107700:	6a 0f                	push   $0xf
  jmp alltraps
80107702:	e9 31 f8 ff ff       	jmp    80106f38 <alltraps>

80107707 <vector16>:
.globl vector16
vector16:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $16
80107709:	6a 10                	push   $0x10
  jmp alltraps
8010770b:	e9 28 f8 ff ff       	jmp    80106f38 <alltraps>

80107710 <vector17>:
.globl vector17
vector17:
  pushl $17
80107710:	6a 11                	push   $0x11
  jmp alltraps
80107712:	e9 21 f8 ff ff       	jmp    80106f38 <alltraps>

80107717 <vector18>:
.globl vector18
vector18:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $18
80107719:	6a 12                	push   $0x12
  jmp alltraps
8010771b:	e9 18 f8 ff ff       	jmp    80106f38 <alltraps>

80107720 <vector19>:
.globl vector19
vector19:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $19
80107722:	6a 13                	push   $0x13
  jmp alltraps
80107724:	e9 0f f8 ff ff       	jmp    80106f38 <alltraps>

80107729 <vector20>:
.globl vector20
vector20:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $20
8010772b:	6a 14                	push   $0x14
  jmp alltraps
8010772d:	e9 06 f8 ff ff       	jmp    80106f38 <alltraps>

80107732 <vector21>:
.globl vector21
vector21:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $21
80107734:	6a 15                	push   $0x15
  jmp alltraps
80107736:	e9 fd f7 ff ff       	jmp    80106f38 <alltraps>

8010773b <vector22>:
.globl vector22
vector22:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $22
8010773d:	6a 16                	push   $0x16
  jmp alltraps
8010773f:	e9 f4 f7 ff ff       	jmp    80106f38 <alltraps>

80107744 <vector23>:
.globl vector23
vector23:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $23
80107746:	6a 17                	push   $0x17
  jmp alltraps
80107748:	e9 eb f7 ff ff       	jmp    80106f38 <alltraps>

8010774d <vector24>:
.globl vector24
vector24:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $24
8010774f:	6a 18                	push   $0x18
  jmp alltraps
80107751:	e9 e2 f7 ff ff       	jmp    80106f38 <alltraps>

80107756 <vector25>:
.globl vector25
vector25:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $25
80107758:	6a 19                	push   $0x19
  jmp alltraps
8010775a:	e9 d9 f7 ff ff       	jmp    80106f38 <alltraps>

8010775f <vector26>:
.globl vector26
vector26:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $26
80107761:	6a 1a                	push   $0x1a
  jmp alltraps
80107763:	e9 d0 f7 ff ff       	jmp    80106f38 <alltraps>

80107768 <vector27>:
.globl vector27
vector27:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $27
8010776a:	6a 1b                	push   $0x1b
  jmp alltraps
8010776c:	e9 c7 f7 ff ff       	jmp    80106f38 <alltraps>

80107771 <vector28>:
.globl vector28
vector28:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $28
80107773:	6a 1c                	push   $0x1c
  jmp alltraps
80107775:	e9 be f7 ff ff       	jmp    80106f38 <alltraps>

8010777a <vector29>:
.globl vector29
vector29:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $29
8010777c:	6a 1d                	push   $0x1d
  jmp alltraps
8010777e:	e9 b5 f7 ff ff       	jmp    80106f38 <alltraps>

80107783 <vector30>:
.globl vector30
vector30:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $30
80107785:	6a 1e                	push   $0x1e
  jmp alltraps
80107787:	e9 ac f7 ff ff       	jmp    80106f38 <alltraps>

8010778c <vector31>:
.globl vector31
vector31:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $31
8010778e:	6a 1f                	push   $0x1f
  jmp alltraps
80107790:	e9 a3 f7 ff ff       	jmp    80106f38 <alltraps>

80107795 <vector32>:
.globl vector32
vector32:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $32
80107797:	6a 20                	push   $0x20
  jmp alltraps
80107799:	e9 9a f7 ff ff       	jmp    80106f38 <alltraps>

8010779e <vector33>:
.globl vector33
vector33:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $33
801077a0:	6a 21                	push   $0x21
  jmp alltraps
801077a2:	e9 91 f7 ff ff       	jmp    80106f38 <alltraps>

801077a7 <vector34>:
.globl vector34
vector34:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $34
801077a9:	6a 22                	push   $0x22
  jmp alltraps
801077ab:	e9 88 f7 ff ff       	jmp    80106f38 <alltraps>

801077b0 <vector35>:
.globl vector35
vector35:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $35
801077b2:	6a 23                	push   $0x23
  jmp alltraps
801077b4:	e9 7f f7 ff ff       	jmp    80106f38 <alltraps>

801077b9 <vector36>:
.globl vector36
vector36:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $36
801077bb:	6a 24                	push   $0x24
  jmp alltraps
801077bd:	e9 76 f7 ff ff       	jmp    80106f38 <alltraps>

801077c2 <vector37>:
.globl vector37
vector37:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $37
801077c4:	6a 25                	push   $0x25
  jmp alltraps
801077c6:	e9 6d f7 ff ff       	jmp    80106f38 <alltraps>

801077cb <vector38>:
.globl vector38
vector38:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $38
801077cd:	6a 26                	push   $0x26
  jmp alltraps
801077cf:	e9 64 f7 ff ff       	jmp    80106f38 <alltraps>

801077d4 <vector39>:
.globl vector39
vector39:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $39
801077d6:	6a 27                	push   $0x27
  jmp alltraps
801077d8:	e9 5b f7 ff ff       	jmp    80106f38 <alltraps>

801077dd <vector40>:
.globl vector40
vector40:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $40
801077df:	6a 28                	push   $0x28
  jmp alltraps
801077e1:	e9 52 f7 ff ff       	jmp    80106f38 <alltraps>

801077e6 <vector41>:
.globl vector41
vector41:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $41
801077e8:	6a 29                	push   $0x29
  jmp alltraps
801077ea:	e9 49 f7 ff ff       	jmp    80106f38 <alltraps>

801077ef <vector42>:
.globl vector42
vector42:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $42
801077f1:	6a 2a                	push   $0x2a
  jmp alltraps
801077f3:	e9 40 f7 ff ff       	jmp    80106f38 <alltraps>

801077f8 <vector43>:
.globl vector43
vector43:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $43
801077fa:	6a 2b                	push   $0x2b
  jmp alltraps
801077fc:	e9 37 f7 ff ff       	jmp    80106f38 <alltraps>

80107801 <vector44>:
.globl vector44
vector44:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $44
80107803:	6a 2c                	push   $0x2c
  jmp alltraps
80107805:	e9 2e f7 ff ff       	jmp    80106f38 <alltraps>

8010780a <vector45>:
.globl vector45
vector45:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $45
8010780c:	6a 2d                	push   $0x2d
  jmp alltraps
8010780e:	e9 25 f7 ff ff       	jmp    80106f38 <alltraps>

80107813 <vector46>:
.globl vector46
vector46:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $46
80107815:	6a 2e                	push   $0x2e
  jmp alltraps
80107817:	e9 1c f7 ff ff       	jmp    80106f38 <alltraps>

8010781c <vector47>:
.globl vector47
vector47:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $47
8010781e:	6a 2f                	push   $0x2f
  jmp alltraps
80107820:	e9 13 f7 ff ff       	jmp    80106f38 <alltraps>

80107825 <vector48>:
.globl vector48
vector48:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $48
80107827:	6a 30                	push   $0x30
  jmp alltraps
80107829:	e9 0a f7 ff ff       	jmp    80106f38 <alltraps>

8010782e <vector49>:
.globl vector49
vector49:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $49
80107830:	6a 31                	push   $0x31
  jmp alltraps
80107832:	e9 01 f7 ff ff       	jmp    80106f38 <alltraps>

80107837 <vector50>:
.globl vector50
vector50:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $50
80107839:	6a 32                	push   $0x32
  jmp alltraps
8010783b:	e9 f8 f6 ff ff       	jmp    80106f38 <alltraps>

80107840 <vector51>:
.globl vector51
vector51:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $51
80107842:	6a 33                	push   $0x33
  jmp alltraps
80107844:	e9 ef f6 ff ff       	jmp    80106f38 <alltraps>

80107849 <vector52>:
.globl vector52
vector52:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $52
8010784b:	6a 34                	push   $0x34
  jmp alltraps
8010784d:	e9 e6 f6 ff ff       	jmp    80106f38 <alltraps>

80107852 <vector53>:
.globl vector53
vector53:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $53
80107854:	6a 35                	push   $0x35
  jmp alltraps
80107856:	e9 dd f6 ff ff       	jmp    80106f38 <alltraps>

8010785b <vector54>:
.globl vector54
vector54:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $54
8010785d:	6a 36                	push   $0x36
  jmp alltraps
8010785f:	e9 d4 f6 ff ff       	jmp    80106f38 <alltraps>

80107864 <vector55>:
.globl vector55
vector55:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $55
80107866:	6a 37                	push   $0x37
  jmp alltraps
80107868:	e9 cb f6 ff ff       	jmp    80106f38 <alltraps>

8010786d <vector56>:
.globl vector56
vector56:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $56
8010786f:	6a 38                	push   $0x38
  jmp alltraps
80107871:	e9 c2 f6 ff ff       	jmp    80106f38 <alltraps>

80107876 <vector57>:
.globl vector57
vector57:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $57
80107878:	6a 39                	push   $0x39
  jmp alltraps
8010787a:	e9 b9 f6 ff ff       	jmp    80106f38 <alltraps>

8010787f <vector58>:
.globl vector58
vector58:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $58
80107881:	6a 3a                	push   $0x3a
  jmp alltraps
80107883:	e9 b0 f6 ff ff       	jmp    80106f38 <alltraps>

80107888 <vector59>:
.globl vector59
vector59:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $59
8010788a:	6a 3b                	push   $0x3b
  jmp alltraps
8010788c:	e9 a7 f6 ff ff       	jmp    80106f38 <alltraps>

80107891 <vector60>:
.globl vector60
vector60:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $60
80107893:	6a 3c                	push   $0x3c
  jmp alltraps
80107895:	e9 9e f6 ff ff       	jmp    80106f38 <alltraps>

8010789a <vector61>:
.globl vector61
vector61:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $61
8010789c:	6a 3d                	push   $0x3d
  jmp alltraps
8010789e:	e9 95 f6 ff ff       	jmp    80106f38 <alltraps>

801078a3 <vector62>:
.globl vector62
vector62:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $62
801078a5:	6a 3e                	push   $0x3e
  jmp alltraps
801078a7:	e9 8c f6 ff ff       	jmp    80106f38 <alltraps>

801078ac <vector63>:
.globl vector63
vector63:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $63
801078ae:	6a 3f                	push   $0x3f
  jmp alltraps
801078b0:	e9 83 f6 ff ff       	jmp    80106f38 <alltraps>

801078b5 <vector64>:
.globl vector64
vector64:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $64
801078b7:	6a 40                	push   $0x40
  jmp alltraps
801078b9:	e9 7a f6 ff ff       	jmp    80106f38 <alltraps>

801078be <vector65>:
.globl vector65
vector65:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $65
801078c0:	6a 41                	push   $0x41
  jmp alltraps
801078c2:	e9 71 f6 ff ff       	jmp    80106f38 <alltraps>

801078c7 <vector66>:
.globl vector66
vector66:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $66
801078c9:	6a 42                	push   $0x42
  jmp alltraps
801078cb:	e9 68 f6 ff ff       	jmp    80106f38 <alltraps>

801078d0 <vector67>:
.globl vector67
vector67:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $67
801078d2:	6a 43                	push   $0x43
  jmp alltraps
801078d4:	e9 5f f6 ff ff       	jmp    80106f38 <alltraps>

801078d9 <vector68>:
.globl vector68
vector68:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $68
801078db:	6a 44                	push   $0x44
  jmp alltraps
801078dd:	e9 56 f6 ff ff       	jmp    80106f38 <alltraps>

801078e2 <vector69>:
.globl vector69
vector69:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $69
801078e4:	6a 45                	push   $0x45
  jmp alltraps
801078e6:	e9 4d f6 ff ff       	jmp    80106f38 <alltraps>

801078eb <vector70>:
.globl vector70
vector70:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $70
801078ed:	6a 46                	push   $0x46
  jmp alltraps
801078ef:	e9 44 f6 ff ff       	jmp    80106f38 <alltraps>

801078f4 <vector71>:
.globl vector71
vector71:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $71
801078f6:	6a 47                	push   $0x47
  jmp alltraps
801078f8:	e9 3b f6 ff ff       	jmp    80106f38 <alltraps>

801078fd <vector72>:
.globl vector72
vector72:
  pushl $0
801078fd:	6a 00                	push   $0x0
  pushl $72
801078ff:	6a 48                	push   $0x48
  jmp alltraps
80107901:	e9 32 f6 ff ff       	jmp    80106f38 <alltraps>

80107906 <vector73>:
.globl vector73
vector73:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $73
80107908:	6a 49                	push   $0x49
  jmp alltraps
8010790a:	e9 29 f6 ff ff       	jmp    80106f38 <alltraps>

8010790f <vector74>:
.globl vector74
vector74:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $74
80107911:	6a 4a                	push   $0x4a
  jmp alltraps
80107913:	e9 20 f6 ff ff       	jmp    80106f38 <alltraps>

80107918 <vector75>:
.globl vector75
vector75:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $75
8010791a:	6a 4b                	push   $0x4b
  jmp alltraps
8010791c:	e9 17 f6 ff ff       	jmp    80106f38 <alltraps>

80107921 <vector76>:
.globl vector76
vector76:
  pushl $0
80107921:	6a 00                	push   $0x0
  pushl $76
80107923:	6a 4c                	push   $0x4c
  jmp alltraps
80107925:	e9 0e f6 ff ff       	jmp    80106f38 <alltraps>

8010792a <vector77>:
.globl vector77
vector77:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $77
8010792c:	6a 4d                	push   $0x4d
  jmp alltraps
8010792e:	e9 05 f6 ff ff       	jmp    80106f38 <alltraps>

80107933 <vector78>:
.globl vector78
vector78:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $78
80107935:	6a 4e                	push   $0x4e
  jmp alltraps
80107937:	e9 fc f5 ff ff       	jmp    80106f38 <alltraps>

8010793c <vector79>:
.globl vector79
vector79:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $79
8010793e:	6a 4f                	push   $0x4f
  jmp alltraps
80107940:	e9 f3 f5 ff ff       	jmp    80106f38 <alltraps>

80107945 <vector80>:
.globl vector80
vector80:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $80
80107947:	6a 50                	push   $0x50
  jmp alltraps
80107949:	e9 ea f5 ff ff       	jmp    80106f38 <alltraps>

8010794e <vector81>:
.globl vector81
vector81:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $81
80107950:	6a 51                	push   $0x51
  jmp alltraps
80107952:	e9 e1 f5 ff ff       	jmp    80106f38 <alltraps>

80107957 <vector82>:
.globl vector82
vector82:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $82
80107959:	6a 52                	push   $0x52
  jmp alltraps
8010795b:	e9 d8 f5 ff ff       	jmp    80106f38 <alltraps>

80107960 <vector83>:
.globl vector83
vector83:
  pushl $0
80107960:	6a 00                	push   $0x0
  pushl $83
80107962:	6a 53                	push   $0x53
  jmp alltraps
80107964:	e9 cf f5 ff ff       	jmp    80106f38 <alltraps>

80107969 <vector84>:
.globl vector84
vector84:
  pushl $0
80107969:	6a 00                	push   $0x0
  pushl $84
8010796b:	6a 54                	push   $0x54
  jmp alltraps
8010796d:	e9 c6 f5 ff ff       	jmp    80106f38 <alltraps>

80107972 <vector85>:
.globl vector85
vector85:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $85
80107974:	6a 55                	push   $0x55
  jmp alltraps
80107976:	e9 bd f5 ff ff       	jmp    80106f38 <alltraps>

8010797b <vector86>:
.globl vector86
vector86:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $86
8010797d:	6a 56                	push   $0x56
  jmp alltraps
8010797f:	e9 b4 f5 ff ff       	jmp    80106f38 <alltraps>

80107984 <vector87>:
.globl vector87
vector87:
  pushl $0
80107984:	6a 00                	push   $0x0
  pushl $87
80107986:	6a 57                	push   $0x57
  jmp alltraps
80107988:	e9 ab f5 ff ff       	jmp    80106f38 <alltraps>

8010798d <vector88>:
.globl vector88
vector88:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $88
8010798f:	6a 58                	push   $0x58
  jmp alltraps
80107991:	e9 a2 f5 ff ff       	jmp    80106f38 <alltraps>

80107996 <vector89>:
.globl vector89
vector89:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $89
80107998:	6a 59                	push   $0x59
  jmp alltraps
8010799a:	e9 99 f5 ff ff       	jmp    80106f38 <alltraps>

8010799f <vector90>:
.globl vector90
vector90:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $90
801079a1:	6a 5a                	push   $0x5a
  jmp alltraps
801079a3:	e9 90 f5 ff ff       	jmp    80106f38 <alltraps>

801079a8 <vector91>:
.globl vector91
vector91:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $91
801079aa:	6a 5b                	push   $0x5b
  jmp alltraps
801079ac:	e9 87 f5 ff ff       	jmp    80106f38 <alltraps>

801079b1 <vector92>:
.globl vector92
vector92:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $92
801079b3:	6a 5c                	push   $0x5c
  jmp alltraps
801079b5:	e9 7e f5 ff ff       	jmp    80106f38 <alltraps>

801079ba <vector93>:
.globl vector93
vector93:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $93
801079bc:	6a 5d                	push   $0x5d
  jmp alltraps
801079be:	e9 75 f5 ff ff       	jmp    80106f38 <alltraps>

801079c3 <vector94>:
.globl vector94
vector94:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $94
801079c5:	6a 5e                	push   $0x5e
  jmp alltraps
801079c7:	e9 6c f5 ff ff       	jmp    80106f38 <alltraps>

801079cc <vector95>:
.globl vector95
vector95:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $95
801079ce:	6a 5f                	push   $0x5f
  jmp alltraps
801079d0:	e9 63 f5 ff ff       	jmp    80106f38 <alltraps>

801079d5 <vector96>:
.globl vector96
vector96:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $96
801079d7:	6a 60                	push   $0x60
  jmp alltraps
801079d9:	e9 5a f5 ff ff       	jmp    80106f38 <alltraps>

801079de <vector97>:
.globl vector97
vector97:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $97
801079e0:	6a 61                	push   $0x61
  jmp alltraps
801079e2:	e9 51 f5 ff ff       	jmp    80106f38 <alltraps>

801079e7 <vector98>:
.globl vector98
vector98:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $98
801079e9:	6a 62                	push   $0x62
  jmp alltraps
801079eb:	e9 48 f5 ff ff       	jmp    80106f38 <alltraps>

801079f0 <vector99>:
.globl vector99
vector99:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $99
801079f2:	6a 63                	push   $0x63
  jmp alltraps
801079f4:	e9 3f f5 ff ff       	jmp    80106f38 <alltraps>

801079f9 <vector100>:
.globl vector100
vector100:
  pushl $0
801079f9:	6a 00                	push   $0x0
  pushl $100
801079fb:	6a 64                	push   $0x64
  jmp alltraps
801079fd:	e9 36 f5 ff ff       	jmp    80106f38 <alltraps>

80107a02 <vector101>:
.globl vector101
vector101:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $101
80107a04:	6a 65                	push   $0x65
  jmp alltraps
80107a06:	e9 2d f5 ff ff       	jmp    80106f38 <alltraps>

80107a0b <vector102>:
.globl vector102
vector102:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $102
80107a0d:	6a 66                	push   $0x66
  jmp alltraps
80107a0f:	e9 24 f5 ff ff       	jmp    80106f38 <alltraps>

80107a14 <vector103>:
.globl vector103
vector103:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $103
80107a16:	6a 67                	push   $0x67
  jmp alltraps
80107a18:	e9 1b f5 ff ff       	jmp    80106f38 <alltraps>

80107a1d <vector104>:
.globl vector104
vector104:
  pushl $0
80107a1d:	6a 00                	push   $0x0
  pushl $104
80107a1f:	6a 68                	push   $0x68
  jmp alltraps
80107a21:	e9 12 f5 ff ff       	jmp    80106f38 <alltraps>

80107a26 <vector105>:
.globl vector105
vector105:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $105
80107a28:	6a 69                	push   $0x69
  jmp alltraps
80107a2a:	e9 09 f5 ff ff       	jmp    80106f38 <alltraps>

80107a2f <vector106>:
.globl vector106
vector106:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $106
80107a31:	6a 6a                	push   $0x6a
  jmp alltraps
80107a33:	e9 00 f5 ff ff       	jmp    80106f38 <alltraps>

80107a38 <vector107>:
.globl vector107
vector107:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $107
80107a3a:	6a 6b                	push   $0x6b
  jmp alltraps
80107a3c:	e9 f7 f4 ff ff       	jmp    80106f38 <alltraps>

80107a41 <vector108>:
.globl vector108
vector108:
  pushl $0
80107a41:	6a 00                	push   $0x0
  pushl $108
80107a43:	6a 6c                	push   $0x6c
  jmp alltraps
80107a45:	e9 ee f4 ff ff       	jmp    80106f38 <alltraps>

80107a4a <vector109>:
.globl vector109
vector109:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $109
80107a4c:	6a 6d                	push   $0x6d
  jmp alltraps
80107a4e:	e9 e5 f4 ff ff       	jmp    80106f38 <alltraps>

80107a53 <vector110>:
.globl vector110
vector110:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $110
80107a55:	6a 6e                	push   $0x6e
  jmp alltraps
80107a57:	e9 dc f4 ff ff       	jmp    80106f38 <alltraps>

80107a5c <vector111>:
.globl vector111
vector111:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $111
80107a5e:	6a 6f                	push   $0x6f
  jmp alltraps
80107a60:	e9 d3 f4 ff ff       	jmp    80106f38 <alltraps>

80107a65 <vector112>:
.globl vector112
vector112:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $112
80107a67:	6a 70                	push   $0x70
  jmp alltraps
80107a69:	e9 ca f4 ff ff       	jmp    80106f38 <alltraps>

80107a6e <vector113>:
.globl vector113
vector113:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $113
80107a70:	6a 71                	push   $0x71
  jmp alltraps
80107a72:	e9 c1 f4 ff ff       	jmp    80106f38 <alltraps>

80107a77 <vector114>:
.globl vector114
vector114:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $114
80107a79:	6a 72                	push   $0x72
  jmp alltraps
80107a7b:	e9 b8 f4 ff ff       	jmp    80106f38 <alltraps>

80107a80 <vector115>:
.globl vector115
vector115:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $115
80107a82:	6a 73                	push   $0x73
  jmp alltraps
80107a84:	e9 af f4 ff ff       	jmp    80106f38 <alltraps>

80107a89 <vector116>:
.globl vector116
vector116:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $116
80107a8b:	6a 74                	push   $0x74
  jmp alltraps
80107a8d:	e9 a6 f4 ff ff       	jmp    80106f38 <alltraps>

80107a92 <vector117>:
.globl vector117
vector117:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $117
80107a94:	6a 75                	push   $0x75
  jmp alltraps
80107a96:	e9 9d f4 ff ff       	jmp    80106f38 <alltraps>

80107a9b <vector118>:
.globl vector118
vector118:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $118
80107a9d:	6a 76                	push   $0x76
  jmp alltraps
80107a9f:	e9 94 f4 ff ff       	jmp    80106f38 <alltraps>

80107aa4 <vector119>:
.globl vector119
vector119:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $119
80107aa6:	6a 77                	push   $0x77
  jmp alltraps
80107aa8:	e9 8b f4 ff ff       	jmp    80106f38 <alltraps>

80107aad <vector120>:
.globl vector120
vector120:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $120
80107aaf:	6a 78                	push   $0x78
  jmp alltraps
80107ab1:	e9 82 f4 ff ff       	jmp    80106f38 <alltraps>

80107ab6 <vector121>:
.globl vector121
vector121:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $121
80107ab8:	6a 79                	push   $0x79
  jmp alltraps
80107aba:	e9 79 f4 ff ff       	jmp    80106f38 <alltraps>

80107abf <vector122>:
.globl vector122
vector122:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $122
80107ac1:	6a 7a                	push   $0x7a
  jmp alltraps
80107ac3:	e9 70 f4 ff ff       	jmp    80106f38 <alltraps>

80107ac8 <vector123>:
.globl vector123
vector123:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $123
80107aca:	6a 7b                	push   $0x7b
  jmp alltraps
80107acc:	e9 67 f4 ff ff       	jmp    80106f38 <alltraps>

80107ad1 <vector124>:
.globl vector124
vector124:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $124
80107ad3:	6a 7c                	push   $0x7c
  jmp alltraps
80107ad5:	e9 5e f4 ff ff       	jmp    80106f38 <alltraps>

80107ada <vector125>:
.globl vector125
vector125:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $125
80107adc:	6a 7d                	push   $0x7d
  jmp alltraps
80107ade:	e9 55 f4 ff ff       	jmp    80106f38 <alltraps>

80107ae3 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $126
80107ae5:	6a 7e                	push   $0x7e
  jmp alltraps
80107ae7:	e9 4c f4 ff ff       	jmp    80106f38 <alltraps>

80107aec <vector127>:
.globl vector127
vector127:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $127
80107aee:	6a 7f                	push   $0x7f
  jmp alltraps
80107af0:	e9 43 f4 ff ff       	jmp    80106f38 <alltraps>

80107af5 <vector128>:
.globl vector128
vector128:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $128
80107af7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107afc:	e9 37 f4 ff ff       	jmp    80106f38 <alltraps>

80107b01 <vector129>:
.globl vector129
vector129:
  pushl $0
80107b01:	6a 00                	push   $0x0
  pushl $129
80107b03:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107b08:	e9 2b f4 ff ff       	jmp    80106f38 <alltraps>

80107b0d <vector130>:
.globl vector130
vector130:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $130
80107b0f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107b14:	e9 1f f4 ff ff       	jmp    80106f38 <alltraps>

80107b19 <vector131>:
.globl vector131
vector131:
  pushl $0
80107b19:	6a 00                	push   $0x0
  pushl $131
80107b1b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107b20:	e9 13 f4 ff ff       	jmp    80106f38 <alltraps>

80107b25 <vector132>:
.globl vector132
vector132:
  pushl $0
80107b25:	6a 00                	push   $0x0
  pushl $132
80107b27:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107b2c:	e9 07 f4 ff ff       	jmp    80106f38 <alltraps>

80107b31 <vector133>:
.globl vector133
vector133:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $133
80107b33:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107b38:	e9 fb f3 ff ff       	jmp    80106f38 <alltraps>

80107b3d <vector134>:
.globl vector134
vector134:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $134
80107b3f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107b44:	e9 ef f3 ff ff       	jmp    80106f38 <alltraps>

80107b49 <vector135>:
.globl vector135
vector135:
  pushl $0
80107b49:	6a 00                	push   $0x0
  pushl $135
80107b4b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107b50:	e9 e3 f3 ff ff       	jmp    80106f38 <alltraps>

80107b55 <vector136>:
.globl vector136
vector136:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $136
80107b57:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107b5c:	e9 d7 f3 ff ff       	jmp    80106f38 <alltraps>

80107b61 <vector137>:
.globl vector137
vector137:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $137
80107b63:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107b68:	e9 cb f3 ff ff       	jmp    80106f38 <alltraps>

80107b6d <vector138>:
.globl vector138
vector138:
  pushl $0
80107b6d:	6a 00                	push   $0x0
  pushl $138
80107b6f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107b74:	e9 bf f3 ff ff       	jmp    80106f38 <alltraps>

80107b79 <vector139>:
.globl vector139
vector139:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $139
80107b7b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107b80:	e9 b3 f3 ff ff       	jmp    80106f38 <alltraps>

80107b85 <vector140>:
.globl vector140
vector140:
  pushl $0
80107b85:	6a 00                	push   $0x0
  pushl $140
80107b87:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107b8c:	e9 a7 f3 ff ff       	jmp    80106f38 <alltraps>

80107b91 <vector141>:
.globl vector141
vector141:
  pushl $0
80107b91:	6a 00                	push   $0x0
  pushl $141
80107b93:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107b98:	e9 9b f3 ff ff       	jmp    80106f38 <alltraps>

80107b9d <vector142>:
.globl vector142
vector142:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $142
80107b9f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ba4:	e9 8f f3 ff ff       	jmp    80106f38 <alltraps>

80107ba9 <vector143>:
.globl vector143
vector143:
  pushl $0
80107ba9:	6a 00                	push   $0x0
  pushl $143
80107bab:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107bb0:	e9 83 f3 ff ff       	jmp    80106f38 <alltraps>

80107bb5 <vector144>:
.globl vector144
vector144:
  pushl $0
80107bb5:	6a 00                	push   $0x0
  pushl $144
80107bb7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107bbc:	e9 77 f3 ff ff       	jmp    80106f38 <alltraps>

80107bc1 <vector145>:
.globl vector145
vector145:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $145
80107bc3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107bc8:	e9 6b f3 ff ff       	jmp    80106f38 <alltraps>

80107bcd <vector146>:
.globl vector146
vector146:
  pushl $0
80107bcd:	6a 00                	push   $0x0
  pushl $146
80107bcf:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107bd4:	e9 5f f3 ff ff       	jmp    80106f38 <alltraps>

80107bd9 <vector147>:
.globl vector147
vector147:
  pushl $0
80107bd9:	6a 00                	push   $0x0
  pushl $147
80107bdb:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107be0:	e9 53 f3 ff ff       	jmp    80106f38 <alltraps>

80107be5 <vector148>:
.globl vector148
vector148:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $148
80107be7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107bec:	e9 47 f3 ff ff       	jmp    80106f38 <alltraps>

80107bf1 <vector149>:
.globl vector149
vector149:
  pushl $0
80107bf1:	6a 00                	push   $0x0
  pushl $149
80107bf3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107bf8:	e9 3b f3 ff ff       	jmp    80106f38 <alltraps>

80107bfd <vector150>:
.globl vector150
vector150:
  pushl $0
80107bfd:	6a 00                	push   $0x0
  pushl $150
80107bff:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107c04:	e9 2f f3 ff ff       	jmp    80106f38 <alltraps>

80107c09 <vector151>:
.globl vector151
vector151:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $151
80107c0b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107c10:	e9 23 f3 ff ff       	jmp    80106f38 <alltraps>

80107c15 <vector152>:
.globl vector152
vector152:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $152
80107c17:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107c1c:	e9 17 f3 ff ff       	jmp    80106f38 <alltraps>

80107c21 <vector153>:
.globl vector153
vector153:
  pushl $0
80107c21:	6a 00                	push   $0x0
  pushl $153
80107c23:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107c28:	e9 0b f3 ff ff       	jmp    80106f38 <alltraps>

80107c2d <vector154>:
.globl vector154
vector154:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $154
80107c2f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107c34:	e9 ff f2 ff ff       	jmp    80106f38 <alltraps>

80107c39 <vector155>:
.globl vector155
vector155:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $155
80107c3b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107c40:	e9 f3 f2 ff ff       	jmp    80106f38 <alltraps>

80107c45 <vector156>:
.globl vector156
vector156:
  pushl $0
80107c45:	6a 00                	push   $0x0
  pushl $156
80107c47:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107c4c:	e9 e7 f2 ff ff       	jmp    80106f38 <alltraps>

80107c51 <vector157>:
.globl vector157
vector157:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $157
80107c53:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107c58:	e9 db f2 ff ff       	jmp    80106f38 <alltraps>

80107c5d <vector158>:
.globl vector158
vector158:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $158
80107c5f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107c64:	e9 cf f2 ff ff       	jmp    80106f38 <alltraps>

80107c69 <vector159>:
.globl vector159
vector159:
  pushl $0
80107c69:	6a 00                	push   $0x0
  pushl $159
80107c6b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107c70:	e9 c3 f2 ff ff       	jmp    80106f38 <alltraps>

80107c75 <vector160>:
.globl vector160
vector160:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $160
80107c77:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107c7c:	e9 b7 f2 ff ff       	jmp    80106f38 <alltraps>

80107c81 <vector161>:
.globl vector161
vector161:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $161
80107c83:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107c88:	e9 ab f2 ff ff       	jmp    80106f38 <alltraps>

80107c8d <vector162>:
.globl vector162
vector162:
  pushl $0
80107c8d:	6a 00                	push   $0x0
  pushl $162
80107c8f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107c94:	e9 9f f2 ff ff       	jmp    80106f38 <alltraps>

80107c99 <vector163>:
.globl vector163
vector163:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $163
80107c9b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107ca0:	e9 93 f2 ff ff       	jmp    80106f38 <alltraps>

80107ca5 <vector164>:
.globl vector164
vector164:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $164
80107ca7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107cac:	e9 87 f2 ff ff       	jmp    80106f38 <alltraps>

80107cb1 <vector165>:
.globl vector165
vector165:
  pushl $0
80107cb1:	6a 00                	push   $0x0
  pushl $165
80107cb3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107cb8:	e9 7b f2 ff ff       	jmp    80106f38 <alltraps>

80107cbd <vector166>:
.globl vector166
vector166:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $166
80107cbf:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107cc4:	e9 6f f2 ff ff       	jmp    80106f38 <alltraps>

80107cc9 <vector167>:
.globl vector167
vector167:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $167
80107ccb:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107cd0:	e9 63 f2 ff ff       	jmp    80106f38 <alltraps>

80107cd5 <vector168>:
.globl vector168
vector168:
  pushl $0
80107cd5:	6a 00                	push   $0x0
  pushl $168
80107cd7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107cdc:	e9 57 f2 ff ff       	jmp    80106f38 <alltraps>

80107ce1 <vector169>:
.globl vector169
vector169:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $169
80107ce3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107ce8:	e9 4b f2 ff ff       	jmp    80106f38 <alltraps>

80107ced <vector170>:
.globl vector170
vector170:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $170
80107cef:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107cf4:	e9 3f f2 ff ff       	jmp    80106f38 <alltraps>

80107cf9 <vector171>:
.globl vector171
vector171:
  pushl $0
80107cf9:	6a 00                	push   $0x0
  pushl $171
80107cfb:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107d00:	e9 33 f2 ff ff       	jmp    80106f38 <alltraps>

80107d05 <vector172>:
.globl vector172
vector172:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $172
80107d07:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107d0c:	e9 27 f2 ff ff       	jmp    80106f38 <alltraps>

80107d11 <vector173>:
.globl vector173
vector173:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $173
80107d13:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107d18:	e9 1b f2 ff ff       	jmp    80106f38 <alltraps>

80107d1d <vector174>:
.globl vector174
vector174:
  pushl $0
80107d1d:	6a 00                	push   $0x0
  pushl $174
80107d1f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107d24:	e9 0f f2 ff ff       	jmp    80106f38 <alltraps>

80107d29 <vector175>:
.globl vector175
vector175:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $175
80107d2b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107d30:	e9 03 f2 ff ff       	jmp    80106f38 <alltraps>

80107d35 <vector176>:
.globl vector176
vector176:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $176
80107d37:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107d3c:	e9 f7 f1 ff ff       	jmp    80106f38 <alltraps>

80107d41 <vector177>:
.globl vector177
vector177:
  pushl $0
80107d41:	6a 00                	push   $0x0
  pushl $177
80107d43:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107d48:	e9 eb f1 ff ff       	jmp    80106f38 <alltraps>

80107d4d <vector178>:
.globl vector178
vector178:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $178
80107d4f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107d54:	e9 df f1 ff ff       	jmp    80106f38 <alltraps>

80107d59 <vector179>:
.globl vector179
vector179:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $179
80107d5b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107d60:	e9 d3 f1 ff ff       	jmp    80106f38 <alltraps>

80107d65 <vector180>:
.globl vector180
vector180:
  pushl $0
80107d65:	6a 00                	push   $0x0
  pushl $180
80107d67:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107d6c:	e9 c7 f1 ff ff       	jmp    80106f38 <alltraps>

80107d71 <vector181>:
.globl vector181
vector181:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $181
80107d73:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107d78:	e9 bb f1 ff ff       	jmp    80106f38 <alltraps>

80107d7d <vector182>:
.globl vector182
vector182:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $182
80107d7f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107d84:	e9 af f1 ff ff       	jmp    80106f38 <alltraps>

80107d89 <vector183>:
.globl vector183
vector183:
  pushl $0
80107d89:	6a 00                	push   $0x0
  pushl $183
80107d8b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107d90:	e9 a3 f1 ff ff       	jmp    80106f38 <alltraps>

80107d95 <vector184>:
.globl vector184
vector184:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $184
80107d97:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107d9c:	e9 97 f1 ff ff       	jmp    80106f38 <alltraps>

80107da1 <vector185>:
.globl vector185
vector185:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $185
80107da3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107da8:	e9 8b f1 ff ff       	jmp    80106f38 <alltraps>

80107dad <vector186>:
.globl vector186
vector186:
  pushl $0
80107dad:	6a 00                	push   $0x0
  pushl $186
80107daf:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107db4:	e9 7f f1 ff ff       	jmp    80106f38 <alltraps>

80107db9 <vector187>:
.globl vector187
vector187:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $187
80107dbb:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107dc0:	e9 73 f1 ff ff       	jmp    80106f38 <alltraps>

80107dc5 <vector188>:
.globl vector188
vector188:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $188
80107dc7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107dcc:	e9 67 f1 ff ff       	jmp    80106f38 <alltraps>

80107dd1 <vector189>:
.globl vector189
vector189:
  pushl $0
80107dd1:	6a 00                	push   $0x0
  pushl $189
80107dd3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107dd8:	e9 5b f1 ff ff       	jmp    80106f38 <alltraps>

80107ddd <vector190>:
.globl vector190
vector190:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $190
80107ddf:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107de4:	e9 4f f1 ff ff       	jmp    80106f38 <alltraps>

80107de9 <vector191>:
.globl vector191
vector191:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $191
80107deb:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107df0:	e9 43 f1 ff ff       	jmp    80106f38 <alltraps>

80107df5 <vector192>:
.globl vector192
vector192:
  pushl $0
80107df5:	6a 00                	push   $0x0
  pushl $192
80107df7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107dfc:	e9 37 f1 ff ff       	jmp    80106f38 <alltraps>

80107e01 <vector193>:
.globl vector193
vector193:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $193
80107e03:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107e08:	e9 2b f1 ff ff       	jmp    80106f38 <alltraps>

80107e0d <vector194>:
.globl vector194
vector194:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $194
80107e0f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107e14:	e9 1f f1 ff ff       	jmp    80106f38 <alltraps>

80107e19 <vector195>:
.globl vector195
vector195:
  pushl $0
80107e19:	6a 00                	push   $0x0
  pushl $195
80107e1b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107e20:	e9 13 f1 ff ff       	jmp    80106f38 <alltraps>

80107e25 <vector196>:
.globl vector196
vector196:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $196
80107e27:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107e2c:	e9 07 f1 ff ff       	jmp    80106f38 <alltraps>

80107e31 <vector197>:
.globl vector197
vector197:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $197
80107e33:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107e38:	e9 fb f0 ff ff       	jmp    80106f38 <alltraps>

80107e3d <vector198>:
.globl vector198
vector198:
  pushl $0
80107e3d:	6a 00                	push   $0x0
  pushl $198
80107e3f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107e44:	e9 ef f0 ff ff       	jmp    80106f38 <alltraps>

80107e49 <vector199>:
.globl vector199
vector199:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $199
80107e4b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107e50:	e9 e3 f0 ff ff       	jmp    80106f38 <alltraps>

80107e55 <vector200>:
.globl vector200
vector200:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $200
80107e57:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107e5c:	e9 d7 f0 ff ff       	jmp    80106f38 <alltraps>

80107e61 <vector201>:
.globl vector201
vector201:
  pushl $0
80107e61:	6a 00                	push   $0x0
  pushl $201
80107e63:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107e68:	e9 cb f0 ff ff       	jmp    80106f38 <alltraps>

80107e6d <vector202>:
.globl vector202
vector202:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $202
80107e6f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107e74:	e9 bf f0 ff ff       	jmp    80106f38 <alltraps>

80107e79 <vector203>:
.globl vector203
vector203:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $203
80107e7b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107e80:	e9 b3 f0 ff ff       	jmp    80106f38 <alltraps>

80107e85 <vector204>:
.globl vector204
vector204:
  pushl $0
80107e85:	6a 00                	push   $0x0
  pushl $204
80107e87:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107e8c:	e9 a7 f0 ff ff       	jmp    80106f38 <alltraps>

80107e91 <vector205>:
.globl vector205
vector205:
  pushl $0
80107e91:	6a 00                	push   $0x0
  pushl $205
80107e93:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107e98:	e9 9b f0 ff ff       	jmp    80106f38 <alltraps>

80107e9d <vector206>:
.globl vector206
vector206:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $206
80107e9f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107ea4:	e9 8f f0 ff ff       	jmp    80106f38 <alltraps>

80107ea9 <vector207>:
.globl vector207
vector207:
  pushl $0
80107ea9:	6a 00                	push   $0x0
  pushl $207
80107eab:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107eb0:	e9 83 f0 ff ff       	jmp    80106f38 <alltraps>

80107eb5 <vector208>:
.globl vector208
vector208:
  pushl $0
80107eb5:	6a 00                	push   $0x0
  pushl $208
80107eb7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107ebc:	e9 77 f0 ff ff       	jmp    80106f38 <alltraps>

80107ec1 <vector209>:
.globl vector209
vector209:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $209
80107ec3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107ec8:	e9 6b f0 ff ff       	jmp    80106f38 <alltraps>

80107ecd <vector210>:
.globl vector210
vector210:
  pushl $0
80107ecd:	6a 00                	push   $0x0
  pushl $210
80107ecf:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107ed4:	e9 5f f0 ff ff       	jmp    80106f38 <alltraps>

80107ed9 <vector211>:
.globl vector211
vector211:
  pushl $0
80107ed9:	6a 00                	push   $0x0
  pushl $211
80107edb:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107ee0:	e9 53 f0 ff ff       	jmp    80106f38 <alltraps>

80107ee5 <vector212>:
.globl vector212
vector212:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $212
80107ee7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107eec:	e9 47 f0 ff ff       	jmp    80106f38 <alltraps>

80107ef1 <vector213>:
.globl vector213
vector213:
  pushl $0
80107ef1:	6a 00                	push   $0x0
  pushl $213
80107ef3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107ef8:	e9 3b f0 ff ff       	jmp    80106f38 <alltraps>

80107efd <vector214>:
.globl vector214
vector214:
  pushl $0
80107efd:	6a 00                	push   $0x0
  pushl $214
80107eff:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107f04:	e9 2f f0 ff ff       	jmp    80106f38 <alltraps>

80107f09 <vector215>:
.globl vector215
vector215:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $215
80107f0b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107f10:	e9 23 f0 ff ff       	jmp    80106f38 <alltraps>

80107f15 <vector216>:
.globl vector216
vector216:
  pushl $0
80107f15:	6a 00                	push   $0x0
  pushl $216
80107f17:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107f1c:	e9 17 f0 ff ff       	jmp    80106f38 <alltraps>

80107f21 <vector217>:
.globl vector217
vector217:
  pushl $0
80107f21:	6a 00                	push   $0x0
  pushl $217
80107f23:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107f28:	e9 0b f0 ff ff       	jmp    80106f38 <alltraps>

80107f2d <vector218>:
.globl vector218
vector218:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $218
80107f2f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107f34:	e9 ff ef ff ff       	jmp    80106f38 <alltraps>

80107f39 <vector219>:
.globl vector219
vector219:
  pushl $0
80107f39:	6a 00                	push   $0x0
  pushl $219
80107f3b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107f40:	e9 f3 ef ff ff       	jmp    80106f38 <alltraps>

80107f45 <vector220>:
.globl vector220
vector220:
  pushl $0
80107f45:	6a 00                	push   $0x0
  pushl $220
80107f47:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107f4c:	e9 e7 ef ff ff       	jmp    80106f38 <alltraps>

80107f51 <vector221>:
.globl vector221
vector221:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $221
80107f53:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107f58:	e9 db ef ff ff       	jmp    80106f38 <alltraps>

80107f5d <vector222>:
.globl vector222
vector222:
  pushl $0
80107f5d:	6a 00                	push   $0x0
  pushl $222
80107f5f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107f64:	e9 cf ef ff ff       	jmp    80106f38 <alltraps>

80107f69 <vector223>:
.globl vector223
vector223:
  pushl $0
80107f69:	6a 00                	push   $0x0
  pushl $223
80107f6b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107f70:	e9 c3 ef ff ff       	jmp    80106f38 <alltraps>

80107f75 <vector224>:
.globl vector224
vector224:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $224
80107f77:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107f7c:	e9 b7 ef ff ff       	jmp    80106f38 <alltraps>

80107f81 <vector225>:
.globl vector225
vector225:
  pushl $0
80107f81:	6a 00                	push   $0x0
  pushl $225
80107f83:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107f88:	e9 ab ef ff ff       	jmp    80106f38 <alltraps>

80107f8d <vector226>:
.globl vector226
vector226:
  pushl $0
80107f8d:	6a 00                	push   $0x0
  pushl $226
80107f8f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107f94:	e9 9f ef ff ff       	jmp    80106f38 <alltraps>

80107f99 <vector227>:
.globl vector227
vector227:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $227
80107f9b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107fa0:	e9 93 ef ff ff       	jmp    80106f38 <alltraps>

80107fa5 <vector228>:
.globl vector228
vector228:
  pushl $0
80107fa5:	6a 00                	push   $0x0
  pushl $228
80107fa7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107fac:	e9 87 ef ff ff       	jmp    80106f38 <alltraps>

80107fb1 <vector229>:
.globl vector229
vector229:
  pushl $0
80107fb1:	6a 00                	push   $0x0
  pushl $229
80107fb3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107fb8:	e9 7b ef ff ff       	jmp    80106f38 <alltraps>

80107fbd <vector230>:
.globl vector230
vector230:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $230
80107fbf:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107fc4:	e9 6f ef ff ff       	jmp    80106f38 <alltraps>

80107fc9 <vector231>:
.globl vector231
vector231:
  pushl $0
80107fc9:	6a 00                	push   $0x0
  pushl $231
80107fcb:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107fd0:	e9 63 ef ff ff       	jmp    80106f38 <alltraps>

80107fd5 <vector232>:
.globl vector232
vector232:
  pushl $0
80107fd5:	6a 00                	push   $0x0
  pushl $232
80107fd7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107fdc:	e9 57 ef ff ff       	jmp    80106f38 <alltraps>

80107fe1 <vector233>:
.globl vector233
vector233:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $233
80107fe3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107fe8:	e9 4b ef ff ff       	jmp    80106f38 <alltraps>

80107fed <vector234>:
.globl vector234
vector234:
  pushl $0
80107fed:	6a 00                	push   $0x0
  pushl $234
80107fef:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ff4:	e9 3f ef ff ff       	jmp    80106f38 <alltraps>

80107ff9 <vector235>:
.globl vector235
vector235:
  pushl $0
80107ff9:	6a 00                	push   $0x0
  pushl $235
80107ffb:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108000:	e9 33 ef ff ff       	jmp    80106f38 <alltraps>

80108005 <vector236>:
.globl vector236
vector236:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $236
80108007:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010800c:	e9 27 ef ff ff       	jmp    80106f38 <alltraps>

80108011 <vector237>:
.globl vector237
vector237:
  pushl $0
80108011:	6a 00                	push   $0x0
  pushl $237
80108013:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108018:	e9 1b ef ff ff       	jmp    80106f38 <alltraps>

8010801d <vector238>:
.globl vector238
vector238:
  pushl $0
8010801d:	6a 00                	push   $0x0
  pushl $238
8010801f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108024:	e9 0f ef ff ff       	jmp    80106f38 <alltraps>

80108029 <vector239>:
.globl vector239
vector239:
  pushl $0
80108029:	6a 00                	push   $0x0
  pushl $239
8010802b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108030:	e9 03 ef ff ff       	jmp    80106f38 <alltraps>

80108035 <vector240>:
.globl vector240
vector240:
  pushl $0
80108035:	6a 00                	push   $0x0
  pushl $240
80108037:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010803c:	e9 f7 ee ff ff       	jmp    80106f38 <alltraps>

80108041 <vector241>:
.globl vector241
vector241:
  pushl $0
80108041:	6a 00                	push   $0x0
  pushl $241
80108043:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108048:	e9 eb ee ff ff       	jmp    80106f38 <alltraps>

8010804d <vector242>:
.globl vector242
vector242:
  pushl $0
8010804d:	6a 00                	push   $0x0
  pushl $242
8010804f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108054:	e9 df ee ff ff       	jmp    80106f38 <alltraps>

80108059 <vector243>:
.globl vector243
vector243:
  pushl $0
80108059:	6a 00                	push   $0x0
  pushl $243
8010805b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108060:	e9 d3 ee ff ff       	jmp    80106f38 <alltraps>

80108065 <vector244>:
.globl vector244
vector244:
  pushl $0
80108065:	6a 00                	push   $0x0
  pushl $244
80108067:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010806c:	e9 c7 ee ff ff       	jmp    80106f38 <alltraps>

80108071 <vector245>:
.globl vector245
vector245:
  pushl $0
80108071:	6a 00                	push   $0x0
  pushl $245
80108073:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108078:	e9 bb ee ff ff       	jmp    80106f38 <alltraps>

8010807d <vector246>:
.globl vector246
vector246:
  pushl $0
8010807d:	6a 00                	push   $0x0
  pushl $246
8010807f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108084:	e9 af ee ff ff       	jmp    80106f38 <alltraps>

80108089 <vector247>:
.globl vector247
vector247:
  pushl $0
80108089:	6a 00                	push   $0x0
  pushl $247
8010808b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108090:	e9 a3 ee ff ff       	jmp    80106f38 <alltraps>

80108095 <vector248>:
.globl vector248
vector248:
  pushl $0
80108095:	6a 00                	push   $0x0
  pushl $248
80108097:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010809c:	e9 97 ee ff ff       	jmp    80106f38 <alltraps>

801080a1 <vector249>:
.globl vector249
vector249:
  pushl $0
801080a1:	6a 00                	push   $0x0
  pushl $249
801080a3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801080a8:	e9 8b ee ff ff       	jmp    80106f38 <alltraps>

801080ad <vector250>:
.globl vector250
vector250:
  pushl $0
801080ad:	6a 00                	push   $0x0
  pushl $250
801080af:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801080b4:	e9 7f ee ff ff       	jmp    80106f38 <alltraps>

801080b9 <vector251>:
.globl vector251
vector251:
  pushl $0
801080b9:	6a 00                	push   $0x0
  pushl $251
801080bb:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801080c0:	e9 73 ee ff ff       	jmp    80106f38 <alltraps>

801080c5 <vector252>:
.globl vector252
vector252:
  pushl $0
801080c5:	6a 00                	push   $0x0
  pushl $252
801080c7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801080cc:	e9 67 ee ff ff       	jmp    80106f38 <alltraps>

801080d1 <vector253>:
.globl vector253
vector253:
  pushl $0
801080d1:	6a 00                	push   $0x0
  pushl $253
801080d3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801080d8:	e9 5b ee ff ff       	jmp    80106f38 <alltraps>

801080dd <vector254>:
.globl vector254
vector254:
  pushl $0
801080dd:	6a 00                	push   $0x0
  pushl $254
801080df:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801080e4:	e9 4f ee ff ff       	jmp    80106f38 <alltraps>

801080e9 <vector255>:
.globl vector255
vector255:
  pushl $0
801080e9:	6a 00                	push   $0x0
  pushl $255
801080eb:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801080f0:	e9 43 ee ff ff       	jmp    80106f38 <alltraps>

801080f5 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801080f5:	55                   	push   %ebp
801080f6:	89 e5                	mov    %esp,%ebp
801080f8:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801080fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801080fe:	83 e8 01             	sub    $0x1,%eax
80108101:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108105:	8b 45 08             	mov    0x8(%ebp),%eax
80108108:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010810c:	8b 45 08             	mov    0x8(%ebp),%eax
8010810f:	c1 e8 10             	shr    $0x10,%eax
80108112:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108116:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108119:	0f 01 10             	lgdtl  (%eax)
}
8010811c:	90                   	nop
8010811d:	c9                   	leave  
8010811e:	c3                   	ret    

8010811f <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010811f:	55                   	push   %ebp
80108120:	89 e5                	mov    %esp,%ebp
80108122:	83 ec 04             	sub    $0x4,%esp
80108125:	8b 45 08             	mov    0x8(%ebp),%eax
80108128:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010812c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108130:	0f 00 d8             	ltr    %ax
}
80108133:	90                   	nop
80108134:	c9                   	leave  
80108135:	c3                   	ret    

80108136 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108136:	55                   	push   %ebp
80108137:	89 e5                	mov    %esp,%ebp
80108139:	83 ec 04             	sub    $0x4,%esp
8010813c:	8b 45 08             	mov    0x8(%ebp),%eax
8010813f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108143:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108147:	8e e8                	mov    %eax,%gs
}
80108149:	90                   	nop
8010814a:	c9                   	leave  
8010814b:	c3                   	ret    

8010814c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010814c:	55                   	push   %ebp
8010814d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010814f:	8b 45 08             	mov    0x8(%ebp),%eax
80108152:	0f 22 d8             	mov    %eax,%cr3
}
80108155:	90                   	nop
80108156:	5d                   	pop    %ebp
80108157:	c3                   	ret    

80108158 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108158:	55                   	push   %ebp
80108159:	89 e5                	mov    %esp,%ebp
8010815b:	8b 45 08             	mov    0x8(%ebp),%eax
8010815e:	05 00 00 00 80       	add    $0x80000000,%eax
80108163:	5d                   	pop    %ebp
80108164:	c3                   	ret    

80108165 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108165:	55                   	push   %ebp
80108166:	89 e5                	mov    %esp,%ebp
80108168:	8b 45 08             	mov    0x8(%ebp),%eax
8010816b:	05 00 00 00 80       	add    $0x80000000,%eax
80108170:	5d                   	pop    %ebp
80108171:	c3                   	ret    

80108172 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108172:	55                   	push   %ebp
80108173:	89 e5                	mov    %esp,%ebp
80108175:	53                   	push   %ebx
80108176:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108179:	e8 b5 ad ff ff       	call   80102f33 <cpunum>
8010817e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108184:	05 80 33 11 80       	add    $0x80113380,%eax
80108189:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010818c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108198:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010819e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a1:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801081a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081ac:	83 e2 f0             	and    $0xfffffff0,%edx
801081af:	83 ca 0a             	or     $0xa,%edx
801081b2:	88 50 7d             	mov    %dl,0x7d(%eax)
801081b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081bc:	83 ca 10             	or     $0x10,%edx
801081bf:	88 50 7d             	mov    %dl,0x7d(%eax)
801081c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081c9:	83 e2 9f             	and    $0xffffff9f,%edx
801081cc:	88 50 7d             	mov    %dl,0x7d(%eax)
801081cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081d6:	83 ca 80             	or     $0xffffff80,%edx
801081d9:	88 50 7d             	mov    %dl,0x7d(%eax)
801081dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081df:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081e3:	83 ca 0f             	or     $0xf,%edx
801081e6:	88 50 7e             	mov    %dl,0x7e(%eax)
801081e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081f0:	83 e2 ef             	and    $0xffffffef,%edx
801081f3:	88 50 7e             	mov    %dl,0x7e(%eax)
801081f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081fd:	83 e2 df             	and    $0xffffffdf,%edx
80108200:	88 50 7e             	mov    %dl,0x7e(%eax)
80108203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108206:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010820a:	83 ca 40             	or     $0x40,%edx
8010820d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108213:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108217:	83 ca 80             	or     $0xffffff80,%edx
8010821a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010821d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108220:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108227:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010822e:	ff ff 
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010823a:	00 00 
8010823c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823f:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108249:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108250:	83 e2 f0             	and    $0xfffffff0,%edx
80108253:	83 ca 02             	or     $0x2,%edx
80108256:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010825c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108266:	83 ca 10             	or     $0x10,%edx
80108269:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010826f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108272:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108279:	83 e2 9f             	and    $0xffffff9f,%edx
8010827c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108285:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010828c:	83 ca 80             	or     $0xffffff80,%edx
8010828f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108298:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010829f:	83 ca 0f             	or     $0xf,%edx
801082a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ab:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082b2:	83 e2 ef             	and    $0xffffffef,%edx
801082b5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082be:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082c5:	83 e2 df             	and    $0xffffffdf,%edx
801082c8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082d8:	83 ca 40             	or     $0x40,%edx
801082db:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082eb:	83 ca 80             	or     $0xffffff80,%edx
801082ee:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801082fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108301:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108308:	ff ff 
8010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108314:	00 00 
80108316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108319:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108323:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010832a:	83 e2 f0             	and    $0xfffffff0,%edx
8010832d:	83 ca 0a             	or     $0xa,%edx
80108330:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108339:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108340:	83 ca 10             	or     $0x10,%edx
80108343:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108353:	83 ca 60             	or     $0x60,%edx
80108356:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010835c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108366:	83 ca 80             	or     $0xffffff80,%edx
80108369:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010836f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108372:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108379:	83 ca 0f             	or     $0xf,%edx
8010837c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108385:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010838c:	83 e2 ef             	and    $0xffffffef,%edx
8010838f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108398:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010839f:	83 e2 df             	and    $0xffffffdf,%edx
801083a2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ab:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083b2:	83 ca 40             	or     $0x40,%edx
801083b5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083be:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801083c5:	83 ca 80             	or     $0xffffff80,%edx
801083c8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801083ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801083d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083db:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801083e2:	ff ff 
801083e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e7:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801083ee:	00 00 
801083f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f3:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801083fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108404:	83 e2 f0             	and    $0xfffffff0,%edx
80108407:	83 ca 02             	or     $0x2,%edx
8010840a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108413:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010841a:	83 ca 10             	or     $0x10,%edx
8010841d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108426:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010842d:	83 ca 60             	or     $0x60,%edx
80108430:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108439:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108440:	83 ca 80             	or     $0xffffff80,%edx
80108443:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108453:	83 ca 0f             	or     $0xf,%edx
80108456:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010845c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108466:	83 e2 ef             	and    $0xffffffef,%edx
80108469:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010846f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108472:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108479:	83 e2 df             	and    $0xffffffdf,%edx
8010847c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108485:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010848c:	83 ca 40             	or     $0x40,%edx
8010848f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108498:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010849f:	83 ca 80             	or     $0xffffff80,%edx
801084a2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801084a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ab:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801084b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b5:	05 b4 00 00 00       	add    $0xb4,%eax
801084ba:	89 c3                	mov    %eax,%ebx
801084bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bf:	05 b4 00 00 00       	add    $0xb4,%eax
801084c4:	c1 e8 10             	shr    $0x10,%eax
801084c7:	89 c2                	mov    %eax,%edx
801084c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cc:	05 b4 00 00 00       	add    $0xb4,%eax
801084d1:	c1 e8 18             	shr    $0x18,%eax
801084d4:	89 c1                	mov    %eax,%ecx
801084d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d9:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801084e0:	00 00 
801084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e5:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801084ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ef:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801084f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801084ff:	83 e2 f0             	and    $0xfffffff0,%edx
80108502:	83 ca 02             	or     $0x2,%edx
80108505:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010850b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108515:	83 ca 10             	or     $0x10,%edx
80108518:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010851e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108521:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108528:	83 e2 9f             	and    $0xffffff9f,%edx
8010852b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108534:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010853b:	83 ca 80             	or     $0xffffff80,%edx
8010853e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108547:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010854e:	83 e2 f0             	and    $0xfffffff0,%edx
80108551:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108561:	83 e2 ef             	and    $0xffffffef,%edx
80108564:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010856a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108574:	83 e2 df             	and    $0xffffffdf,%edx
80108577:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010857d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108580:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108587:	83 ca 40             	or     $0x40,%edx
8010858a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108593:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010859a:	83 ca 80             	or     $0xffffff80,%edx
8010859d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a6:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801085ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085af:	83 c0 70             	add    $0x70,%eax
801085b2:	83 ec 08             	sub    $0x8,%esp
801085b5:	6a 38                	push   $0x38
801085b7:	50                   	push   %eax
801085b8:	e8 38 fb ff ff       	call   801080f5 <lgdt>
801085bd:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801085c0:	83 ec 0c             	sub    $0xc,%esp
801085c3:	6a 18                	push   $0x18
801085c5:	e8 6c fb ff ff       	call   80108136 <loadgs>
801085ca:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
801085cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d0:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801085d6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801085dd:	00 00 00 00 
}
801085e1:	90                   	nop
801085e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085e5:	c9                   	leave  
801085e6:	c3                   	ret    

801085e7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801085e7:	55                   	push   %ebp
801085e8:	89 e5                	mov    %esp,%ebp
801085ea:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801085ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801085f0:	c1 e8 16             	shr    $0x16,%eax
801085f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085fa:	8b 45 08             	mov    0x8(%ebp),%eax
801085fd:	01 d0                	add    %edx,%eax
801085ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108605:	8b 00                	mov    (%eax),%eax
80108607:	83 e0 01             	and    $0x1,%eax
8010860a:	85 c0                	test   %eax,%eax
8010860c:	74 18                	je     80108626 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010860e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108611:	8b 00                	mov    (%eax),%eax
80108613:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108618:	50                   	push   %eax
80108619:	e8 47 fb ff ff       	call   80108165 <p2v>
8010861e:	83 c4 04             	add    $0x4,%esp
80108621:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108624:	eb 48                	jmp    8010866e <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108626:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010862a:	74 0e                	je     8010863a <walkpgdir+0x53>
8010862c:	e8 9c a5 ff ff       	call   80102bcd <kalloc>
80108631:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108638:	75 07                	jne    80108641 <walkpgdir+0x5a>
      return 0;
8010863a:	b8 00 00 00 00       	mov    $0x0,%eax
8010863f:	eb 44                	jmp    80108685 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108641:	83 ec 04             	sub    $0x4,%esp
80108644:	68 00 10 00 00       	push   $0x1000
80108649:	6a 00                	push   $0x0
8010864b:	ff 75 f4             	pushl  -0xc(%ebp)
8010864e:	e8 e7 d3 ff ff       	call   80105a3a <memset>
80108653:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108656:	83 ec 0c             	sub    $0xc,%esp
80108659:	ff 75 f4             	pushl  -0xc(%ebp)
8010865c:	e8 f7 fa ff ff       	call   80108158 <v2p>
80108661:	83 c4 10             	add    $0x10,%esp
80108664:	83 c8 07             	or     $0x7,%eax
80108667:	89 c2                	mov    %eax,%edx
80108669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010866c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010866e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108671:	c1 e8 0c             	shr    $0xc,%eax
80108674:	25 ff 03 00 00       	and    $0x3ff,%eax
80108679:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108683:	01 d0                	add    %edx,%eax
}
80108685:	c9                   	leave  
80108686:	c3                   	ret    

80108687 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108687:	55                   	push   %ebp
80108688:	89 e5                	mov    %esp,%ebp
8010868a:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010868d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108690:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108695:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108698:	8b 55 0c             	mov    0xc(%ebp),%edx
8010869b:	8b 45 10             	mov    0x10(%ebp),%eax
8010869e:	01 d0                	add    %edx,%eax
801086a0:	83 e8 01             	sub    $0x1,%eax
801086a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801086ab:	83 ec 04             	sub    $0x4,%esp
801086ae:	6a 01                	push   $0x1
801086b0:	ff 75 f4             	pushl  -0xc(%ebp)
801086b3:	ff 75 08             	pushl  0x8(%ebp)
801086b6:	e8 2c ff ff ff       	call   801085e7 <walkpgdir>
801086bb:	83 c4 10             	add    $0x10,%esp
801086be:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086c5:	75 07                	jne    801086ce <mappages+0x47>
      return -1;
801086c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086cc:	eb 47                	jmp    80108715 <mappages+0x8e>
    if(*pte & PTE_P)
801086ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d1:	8b 00                	mov    (%eax),%eax
801086d3:	83 e0 01             	and    $0x1,%eax
801086d6:	85 c0                	test   %eax,%eax
801086d8:	74 0d                	je     801086e7 <mappages+0x60>
      panic("remap");
801086da:	83 ec 0c             	sub    $0xc,%esp
801086dd:	68 38 96 10 80       	push   $0x80109638
801086e2:	e8 7f 7e ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801086e7:	8b 45 18             	mov    0x18(%ebp),%eax
801086ea:	0b 45 14             	or     0x14(%ebp),%eax
801086ed:	83 c8 01             	or     $0x1,%eax
801086f0:	89 c2                	mov    %eax,%edx
801086f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f5:	89 10                	mov    %edx,(%eax)
    if(a == last)
801086f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801086fd:	74 10                	je     8010870f <mappages+0x88>
      break;
    a += PGSIZE;
801086ff:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108706:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010870d:	eb 9c                	jmp    801086ab <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010870f:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108710:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108715:	c9                   	leave  
80108716:	c3                   	ret    

80108717 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108717:	55                   	push   %ebp
80108718:	89 e5                	mov    %esp,%ebp
8010871a:	53                   	push   %ebx
8010871b:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010871e:	e8 aa a4 ff ff       	call   80102bcd <kalloc>
80108723:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108726:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010872a:	75 0a                	jne    80108736 <setupkvm+0x1f>
    return 0;
8010872c:	b8 00 00 00 00       	mov    $0x0,%eax
80108731:	e9 8e 00 00 00       	jmp    801087c4 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108736:	83 ec 04             	sub    $0x4,%esp
80108739:	68 00 10 00 00       	push   $0x1000
8010873e:	6a 00                	push   $0x0
80108740:	ff 75 f0             	pushl  -0x10(%ebp)
80108743:	e8 f2 d2 ff ff       	call   80105a3a <memset>
80108748:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010874b:	83 ec 0c             	sub    $0xc,%esp
8010874e:	68 00 00 00 0e       	push   $0xe000000
80108753:	e8 0d fa ff ff       	call   80108165 <p2v>
80108758:	83 c4 10             	add    $0x10,%esp
8010875b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108760:	76 0d                	jbe    8010876f <setupkvm+0x58>
    panic("PHYSTOP too high");
80108762:	83 ec 0c             	sub    $0xc,%esp
80108765:	68 3e 96 10 80       	push   $0x8010963e
8010876a:	e8 f7 7d ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010876f:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108776:	eb 40                	jmp    801087b8 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010877e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108781:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108787:	8b 58 08             	mov    0x8(%eax),%ebx
8010878a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878d:	8b 40 04             	mov    0x4(%eax),%eax
80108790:	29 c3                	sub    %eax,%ebx
80108792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108795:	8b 00                	mov    (%eax),%eax
80108797:	83 ec 0c             	sub    $0xc,%esp
8010879a:	51                   	push   %ecx
8010879b:	52                   	push   %edx
8010879c:	53                   	push   %ebx
8010879d:	50                   	push   %eax
8010879e:	ff 75 f0             	pushl  -0x10(%ebp)
801087a1:	e8 e1 fe ff ff       	call   80108687 <mappages>
801087a6:	83 c4 20             	add    $0x20,%esp
801087a9:	85 c0                	test   %eax,%eax
801087ab:	79 07                	jns    801087b4 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801087ad:	b8 00 00 00 00       	mov    $0x0,%eax
801087b2:	eb 10                	jmp    801087c4 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801087b4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801087b8:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801087bf:	72 b7                	jb     80108778 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801087c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801087c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087c7:	c9                   	leave  
801087c8:	c3                   	ret    

801087c9 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801087c9:	55                   	push   %ebp
801087ca:	89 e5                	mov    %esp,%ebp
801087cc:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801087cf:	e8 43 ff ff ff       	call   80108717 <setupkvm>
801087d4:	a3 b8 6d 11 80       	mov    %eax,0x80116db8
  switchkvm();
801087d9:	e8 03 00 00 00       	call   801087e1 <switchkvm>
}
801087de:	90                   	nop
801087df:	c9                   	leave  
801087e0:	c3                   	ret    

801087e1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801087e1:	55                   	push   %ebp
801087e2:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801087e4:	a1 b8 6d 11 80       	mov    0x80116db8,%eax
801087e9:	50                   	push   %eax
801087ea:	e8 69 f9 ff ff       	call   80108158 <v2p>
801087ef:	83 c4 04             	add    $0x4,%esp
801087f2:	50                   	push   %eax
801087f3:	e8 54 f9 ff ff       	call   8010814c <lcr3>
801087f8:	83 c4 04             	add    $0x4,%esp
}
801087fb:	90                   	nop
801087fc:	c9                   	leave  
801087fd:	c3                   	ret    

801087fe <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801087fe:	55                   	push   %ebp
801087ff:	89 e5                	mov    %esp,%ebp
80108801:	56                   	push   %esi
80108802:	53                   	push   %ebx
  pushcli();
80108803:	e8 2c d1 ff ff       	call   80105934 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108808:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010880e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108815:	83 c2 08             	add    $0x8,%edx
80108818:	89 d6                	mov    %edx,%esi
8010881a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108821:	83 c2 08             	add    $0x8,%edx
80108824:	c1 ea 10             	shr    $0x10,%edx
80108827:	89 d3                	mov    %edx,%ebx
80108829:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108830:	83 c2 08             	add    $0x8,%edx
80108833:	c1 ea 18             	shr    $0x18,%edx
80108836:	89 d1                	mov    %edx,%ecx
80108838:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010883f:	67 00 
80108841:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108848:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
8010884e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108855:	83 e2 f0             	and    $0xfffffff0,%edx
80108858:	83 ca 09             	or     $0x9,%edx
8010885b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108861:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108868:	83 ca 10             	or     $0x10,%edx
8010886b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108871:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108878:	83 e2 9f             	and    $0xffffff9f,%edx
8010887b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108881:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108888:	83 ca 80             	or     $0xffffff80,%edx
8010888b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108891:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108898:	83 e2 f0             	and    $0xfffffff0,%edx
8010889b:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088a1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088a8:	83 e2 ef             	and    $0xffffffef,%edx
801088ab:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088b1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088b8:	83 e2 df             	and    $0xffffffdf,%edx
801088bb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088c1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088c8:	83 ca 40             	or     $0x40,%edx
801088cb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088d1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801088d8:	83 e2 7f             	and    $0x7f,%edx
801088db:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801088e1:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801088e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801088ed:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801088f4:	83 e2 ef             	and    $0xffffffef,%edx
801088f7:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801088fd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108903:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108909:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010890f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108916:	8b 52 08             	mov    0x8(%edx),%edx
80108919:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010891f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108922:	83 ec 0c             	sub    $0xc,%esp
80108925:	6a 30                	push   $0x30
80108927:	e8 f3 f7 ff ff       	call   8010811f <ltr>
8010892c:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
8010892f:	8b 45 08             	mov    0x8(%ebp),%eax
80108932:	8b 40 04             	mov    0x4(%eax),%eax
80108935:	85 c0                	test   %eax,%eax
80108937:	75 0d                	jne    80108946 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108939:	83 ec 0c             	sub    $0xc,%esp
8010893c:	68 4f 96 10 80       	push   $0x8010964f
80108941:	e8 20 7c ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108946:	8b 45 08             	mov    0x8(%ebp),%eax
80108949:	8b 40 04             	mov    0x4(%eax),%eax
8010894c:	83 ec 0c             	sub    $0xc,%esp
8010894f:	50                   	push   %eax
80108950:	e8 03 f8 ff ff       	call   80108158 <v2p>
80108955:	83 c4 10             	add    $0x10,%esp
80108958:	83 ec 0c             	sub    $0xc,%esp
8010895b:	50                   	push   %eax
8010895c:	e8 eb f7 ff ff       	call   8010814c <lcr3>
80108961:	83 c4 10             	add    $0x10,%esp
  popcli();
80108964:	e8 10 d0 ff ff       	call   80105979 <popcli>
}
80108969:	90                   	nop
8010896a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010896d:	5b                   	pop    %ebx
8010896e:	5e                   	pop    %esi
8010896f:	5d                   	pop    %ebp
80108970:	c3                   	ret    

80108971 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108971:	55                   	push   %ebp
80108972:	89 e5                	mov    %esp,%ebp
80108974:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108977:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010897e:	76 0d                	jbe    8010898d <inituvm+0x1c>
    panic("inituvm: more than a page");
80108980:	83 ec 0c             	sub    $0xc,%esp
80108983:	68 63 96 10 80       	push   $0x80109663
80108988:	e8 d9 7b ff ff       	call   80100566 <panic>
  mem = kalloc();
8010898d:	e8 3b a2 ff ff       	call   80102bcd <kalloc>
80108992:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108995:	83 ec 04             	sub    $0x4,%esp
80108998:	68 00 10 00 00       	push   $0x1000
8010899d:	6a 00                	push   $0x0
8010899f:	ff 75 f4             	pushl  -0xc(%ebp)
801089a2:	e8 93 d0 ff ff       	call   80105a3a <memset>
801089a7:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801089aa:	83 ec 0c             	sub    $0xc,%esp
801089ad:	ff 75 f4             	pushl  -0xc(%ebp)
801089b0:	e8 a3 f7 ff ff       	call   80108158 <v2p>
801089b5:	83 c4 10             	add    $0x10,%esp
801089b8:	83 ec 0c             	sub    $0xc,%esp
801089bb:	6a 06                	push   $0x6
801089bd:	50                   	push   %eax
801089be:	68 00 10 00 00       	push   $0x1000
801089c3:	6a 00                	push   $0x0
801089c5:	ff 75 08             	pushl  0x8(%ebp)
801089c8:	e8 ba fc ff ff       	call   80108687 <mappages>
801089cd:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801089d0:	83 ec 04             	sub    $0x4,%esp
801089d3:	ff 75 10             	pushl  0x10(%ebp)
801089d6:	ff 75 0c             	pushl  0xc(%ebp)
801089d9:	ff 75 f4             	pushl  -0xc(%ebp)
801089dc:	e8 18 d1 ff ff       	call   80105af9 <memmove>
801089e1:	83 c4 10             	add    $0x10,%esp
}
801089e4:	90                   	nop
801089e5:	c9                   	leave  
801089e6:	c3                   	ret    

801089e7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801089e7:	55                   	push   %ebp
801089e8:	89 e5                	mov    %esp,%ebp
801089ea:	53                   	push   %ebx
801089eb:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801089ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801089f1:	25 ff 0f 00 00       	and    $0xfff,%eax
801089f6:	85 c0                	test   %eax,%eax
801089f8:	74 0d                	je     80108a07 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801089fa:	83 ec 0c             	sub    $0xc,%esp
801089fd:	68 80 96 10 80       	push   $0x80109680
80108a02:	e8 5f 7b ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108a07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a0e:	e9 95 00 00 00       	jmp    80108aa8 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108a13:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a19:	01 d0                	add    %edx,%eax
80108a1b:	83 ec 04             	sub    $0x4,%esp
80108a1e:	6a 00                	push   $0x0
80108a20:	50                   	push   %eax
80108a21:	ff 75 08             	pushl  0x8(%ebp)
80108a24:	e8 be fb ff ff       	call   801085e7 <walkpgdir>
80108a29:	83 c4 10             	add    $0x10,%esp
80108a2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a2f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a33:	75 0d                	jne    80108a42 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108a35:	83 ec 0c             	sub    $0xc,%esp
80108a38:	68 a3 96 10 80       	push   $0x801096a3
80108a3d:	e8 24 7b ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a45:	8b 00                	mov    (%eax),%eax
80108a47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108a4f:	8b 45 18             	mov    0x18(%ebp),%eax
80108a52:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108a55:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108a5a:	77 0b                	ja     80108a67 <loaduvm+0x80>
      n = sz - i;
80108a5c:	8b 45 18             	mov    0x18(%ebp),%eax
80108a5f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a65:	eb 07                	jmp    80108a6e <loaduvm+0x87>
    else
      n = PGSIZE;
80108a67:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108a6e:	8b 55 14             	mov    0x14(%ebp),%edx
80108a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a74:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108a77:	83 ec 0c             	sub    $0xc,%esp
80108a7a:	ff 75 e8             	pushl  -0x18(%ebp)
80108a7d:	e8 e3 f6 ff ff       	call   80108165 <p2v>
80108a82:	83 c4 10             	add    $0x10,%esp
80108a85:	ff 75 f0             	pushl  -0x10(%ebp)
80108a88:	53                   	push   %ebx
80108a89:	50                   	push   %eax
80108a8a:	ff 75 10             	pushl  0x10(%ebp)
80108a8d:	e8 e9 93 ff ff       	call   80101e7b <readi>
80108a92:	83 c4 10             	add    $0x10,%esp
80108a95:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a98:	74 07                	je     80108aa1 <loaduvm+0xba>
      return -1;
80108a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a9f:	eb 18                	jmp    80108ab9 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108aa1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aab:	3b 45 18             	cmp    0x18(%ebp),%eax
80108aae:	0f 82 5f ff ff ff    	jb     80108a13 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108ab4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108ab9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108abc:	c9                   	leave  
80108abd:	c3                   	ret    

80108abe <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108abe:	55                   	push   %ebp
80108abf:	89 e5                	mov    %esp,%ebp
80108ac1:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108ac4:	8b 45 10             	mov    0x10(%ebp),%eax
80108ac7:	85 c0                	test   %eax,%eax
80108ac9:	79 0a                	jns    80108ad5 <allocuvm+0x17>
    return 0;
80108acb:	b8 00 00 00 00       	mov    $0x0,%eax
80108ad0:	e9 b0 00 00 00       	jmp    80108b85 <allocuvm+0xc7>
  if(newsz < oldsz)
80108ad5:	8b 45 10             	mov    0x10(%ebp),%eax
80108ad8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108adb:	73 08                	jae    80108ae5 <allocuvm+0x27>
    return oldsz;
80108add:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ae0:	e9 a0 00 00 00       	jmp    80108b85 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ae8:	05 ff 0f 00 00       	add    $0xfff,%eax
80108aed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108af5:	eb 7f                	jmp    80108b76 <allocuvm+0xb8>
    mem = kalloc();
80108af7:	e8 d1 a0 ff ff       	call   80102bcd <kalloc>
80108afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108aff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b03:	75 2b                	jne    80108b30 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108b05:	83 ec 0c             	sub    $0xc,%esp
80108b08:	68 c1 96 10 80       	push   $0x801096c1
80108b0d:	e8 b4 78 ff ff       	call   801003c6 <cprintf>
80108b12:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108b15:	83 ec 04             	sub    $0x4,%esp
80108b18:	ff 75 0c             	pushl  0xc(%ebp)
80108b1b:	ff 75 10             	pushl  0x10(%ebp)
80108b1e:	ff 75 08             	pushl  0x8(%ebp)
80108b21:	e8 61 00 00 00       	call   80108b87 <deallocuvm>
80108b26:	83 c4 10             	add    $0x10,%esp
      return 0;
80108b29:	b8 00 00 00 00       	mov    $0x0,%eax
80108b2e:	eb 55                	jmp    80108b85 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108b30:	83 ec 04             	sub    $0x4,%esp
80108b33:	68 00 10 00 00       	push   $0x1000
80108b38:	6a 00                	push   $0x0
80108b3a:	ff 75 f0             	pushl  -0x10(%ebp)
80108b3d:	e8 f8 ce ff ff       	call   80105a3a <memset>
80108b42:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108b45:	83 ec 0c             	sub    $0xc,%esp
80108b48:	ff 75 f0             	pushl  -0x10(%ebp)
80108b4b:	e8 08 f6 ff ff       	call   80108158 <v2p>
80108b50:	83 c4 10             	add    $0x10,%esp
80108b53:	89 c2                	mov    %eax,%edx
80108b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b58:	83 ec 0c             	sub    $0xc,%esp
80108b5b:	6a 06                	push   $0x6
80108b5d:	52                   	push   %edx
80108b5e:	68 00 10 00 00       	push   $0x1000
80108b63:	50                   	push   %eax
80108b64:	ff 75 08             	pushl  0x8(%ebp)
80108b67:	e8 1b fb ff ff       	call   80108687 <mappages>
80108b6c:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108b6f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b79:	3b 45 10             	cmp    0x10(%ebp),%eax
80108b7c:	0f 82 75 ff ff ff    	jb     80108af7 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108b82:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108b85:	c9                   	leave  
80108b86:	c3                   	ret    

80108b87 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108b87:	55                   	push   %ebp
80108b88:	89 e5                	mov    %esp,%ebp
80108b8a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108b8d:	8b 45 10             	mov    0x10(%ebp),%eax
80108b90:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b93:	72 08                	jb     80108b9d <deallocuvm+0x16>
    return oldsz;
80108b95:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b98:	e9 a5 00 00 00       	jmp    80108c42 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108b9d:	8b 45 10             	mov    0x10(%ebp),%eax
80108ba0:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ba5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108baa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108bad:	e9 81 00 00 00       	jmp    80108c33 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb5:	83 ec 04             	sub    $0x4,%esp
80108bb8:	6a 00                	push   $0x0
80108bba:	50                   	push   %eax
80108bbb:	ff 75 08             	pushl  0x8(%ebp)
80108bbe:	e8 24 fa ff ff       	call   801085e7 <walkpgdir>
80108bc3:	83 c4 10             	add    $0x10,%esp
80108bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108bc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108bcd:	75 09                	jne    80108bd8 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108bcf:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108bd6:	eb 54                	jmp    80108c2c <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bdb:	8b 00                	mov    (%eax),%eax
80108bdd:	83 e0 01             	and    $0x1,%eax
80108be0:	85 c0                	test   %eax,%eax
80108be2:	74 48                	je     80108c2c <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be7:	8b 00                	mov    (%eax),%eax
80108be9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bee:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108bf1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bf5:	75 0d                	jne    80108c04 <deallocuvm+0x7d>
        panic("kfree");
80108bf7:	83 ec 0c             	sub    $0xc,%esp
80108bfa:	68 d9 96 10 80       	push   $0x801096d9
80108bff:	e8 62 79 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108c04:	83 ec 0c             	sub    $0xc,%esp
80108c07:	ff 75 ec             	pushl  -0x14(%ebp)
80108c0a:	e8 56 f5 ff ff       	call   80108165 <p2v>
80108c0f:	83 c4 10             	add    $0x10,%esp
80108c12:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108c15:	83 ec 0c             	sub    $0xc,%esp
80108c18:	ff 75 e8             	pushl  -0x18(%ebp)
80108c1b:	e8 10 9f ff ff       	call   80102b30 <kfree>
80108c20:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108c2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c39:	0f 82 73 ff ff ff    	jb     80108bb2 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108c3f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c42:	c9                   	leave  
80108c43:	c3                   	ret    

80108c44 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108c44:	55                   	push   %ebp
80108c45:	89 e5                	mov    %esp,%ebp
80108c47:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108c4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108c4e:	75 0d                	jne    80108c5d <freevm+0x19>
    panic("freevm: no pgdir");
80108c50:	83 ec 0c             	sub    $0xc,%esp
80108c53:	68 df 96 10 80       	push   $0x801096df
80108c58:	e8 09 79 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108c5d:	83 ec 04             	sub    $0x4,%esp
80108c60:	6a 00                	push   $0x0
80108c62:	68 00 00 00 80       	push   $0x80000000
80108c67:	ff 75 08             	pushl  0x8(%ebp)
80108c6a:	e8 18 ff ff ff       	call   80108b87 <deallocuvm>
80108c6f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108c72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c79:	eb 4f                	jmp    80108cca <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c85:	8b 45 08             	mov    0x8(%ebp),%eax
80108c88:	01 d0                	add    %edx,%eax
80108c8a:	8b 00                	mov    (%eax),%eax
80108c8c:	83 e0 01             	and    $0x1,%eax
80108c8f:	85 c0                	test   %eax,%eax
80108c91:	74 33                	je     80108cc6 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca0:	01 d0                	add    %edx,%eax
80108ca2:	8b 00                	mov    (%eax),%eax
80108ca4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ca9:	83 ec 0c             	sub    $0xc,%esp
80108cac:	50                   	push   %eax
80108cad:	e8 b3 f4 ff ff       	call   80108165 <p2v>
80108cb2:	83 c4 10             	add    $0x10,%esp
80108cb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108cb8:	83 ec 0c             	sub    $0xc,%esp
80108cbb:	ff 75 f0             	pushl  -0x10(%ebp)
80108cbe:	e8 6d 9e ff ff       	call   80102b30 <kfree>
80108cc3:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108cc6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108cca:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108cd1:	76 a8                	jbe    80108c7b <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108cd3:	83 ec 0c             	sub    $0xc,%esp
80108cd6:	ff 75 08             	pushl  0x8(%ebp)
80108cd9:	e8 52 9e ff ff       	call   80102b30 <kfree>
80108cde:	83 c4 10             	add    $0x10,%esp
}
80108ce1:	90                   	nop
80108ce2:	c9                   	leave  
80108ce3:	c3                   	ret    

80108ce4 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108ce4:	55                   	push   %ebp
80108ce5:	89 e5                	mov    %esp,%ebp
80108ce7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108cea:	83 ec 04             	sub    $0x4,%esp
80108ced:	6a 00                	push   $0x0
80108cef:	ff 75 0c             	pushl  0xc(%ebp)
80108cf2:	ff 75 08             	pushl  0x8(%ebp)
80108cf5:	e8 ed f8 ff ff       	call   801085e7 <walkpgdir>
80108cfa:	83 c4 10             	add    $0x10,%esp
80108cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108d00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108d04:	75 0d                	jne    80108d13 <clearpteu+0x2f>
    panic("clearpteu");
80108d06:	83 ec 0c             	sub    $0xc,%esp
80108d09:	68 f0 96 10 80       	push   $0x801096f0
80108d0e:	e8 53 78 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80108d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d16:	8b 00                	mov    (%eax),%eax
80108d18:	83 e0 fb             	and    $0xfffffffb,%eax
80108d1b:	89 c2                	mov    %eax,%edx
80108d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d20:	89 10                	mov    %edx,(%eax)
}
80108d22:	90                   	nop
80108d23:	c9                   	leave  
80108d24:	c3                   	ret    

80108d25 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108d25:	55                   	push   %ebp
80108d26:	89 e5                	mov    %esp,%ebp
80108d28:	53                   	push   %ebx
80108d29:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108d2c:	e8 e6 f9 ff ff       	call   80108717 <setupkvm>
80108d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d38:	75 0a                	jne    80108d44 <copyuvm+0x1f>
    return 0;
80108d3a:	b8 00 00 00 00       	mov    $0x0,%eax
80108d3f:	e9 ee 00 00 00       	jmp    80108e32 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108d44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d4b:	e9 ba 00 00 00       	jmp    80108e0a <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d53:	83 ec 04             	sub    $0x4,%esp
80108d56:	6a 00                	push   $0x0
80108d58:	50                   	push   %eax
80108d59:	ff 75 08             	pushl  0x8(%ebp)
80108d5c:	e8 86 f8 ff ff       	call   801085e7 <walkpgdir>
80108d61:	83 c4 10             	add    $0x10,%esp
80108d64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d6b:	75 0d                	jne    80108d7a <copyuvm+0x55>
    //  continue;
      panic("copyuvm: pte should exist");
80108d6d:	83 ec 0c             	sub    $0xc,%esp
80108d70:	68 fa 96 10 80       	push   $0x801096fa
80108d75:	e8 ec 77 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108d7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d7d:	8b 00                	mov    (%eax),%eax
80108d7f:	83 e0 01             	and    $0x1,%eax
80108d82:	85 c0                	test   %eax,%eax
80108d84:	74 7c                	je     80108e02 <copyuvm+0xdd>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80108d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d89:	8b 00                	mov    (%eax),%eax
80108d8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108d93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d96:	8b 00                	mov    (%eax),%eax
80108d98:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108da0:	e8 28 9e ff ff       	call   80102bcd <kalloc>
80108da5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108da8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108dac:	74 6d                	je     80108e1b <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108dae:	83 ec 0c             	sub    $0xc,%esp
80108db1:	ff 75 e8             	pushl  -0x18(%ebp)
80108db4:	e8 ac f3 ff ff       	call   80108165 <p2v>
80108db9:	83 c4 10             	add    $0x10,%esp
80108dbc:	83 ec 04             	sub    $0x4,%esp
80108dbf:	68 00 10 00 00       	push   $0x1000
80108dc4:	50                   	push   %eax
80108dc5:	ff 75 e0             	pushl  -0x20(%ebp)
80108dc8:	e8 2c cd ff ff       	call   80105af9 <memmove>
80108dcd:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108dd0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108dd3:	83 ec 0c             	sub    $0xc,%esp
80108dd6:	ff 75 e0             	pushl  -0x20(%ebp)
80108dd9:	e8 7a f3 ff ff       	call   80108158 <v2p>
80108dde:	83 c4 10             	add    $0x10,%esp
80108de1:	89 c2                	mov    %eax,%edx
80108de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de6:	83 ec 0c             	sub    $0xc,%esp
80108de9:	53                   	push   %ebx
80108dea:	52                   	push   %edx
80108deb:	68 00 10 00 00       	push   $0x1000
80108df0:	50                   	push   %eax
80108df1:	ff 75 f0             	pushl  -0x10(%ebp)
80108df4:	e8 8e f8 ff ff       	call   80108687 <mappages>
80108df9:	83 c4 20             	add    $0x20,%esp
80108dfc:	85 c0                	test   %eax,%eax
80108dfe:	78 1e                	js     80108e1e <copyuvm+0xf9>
80108e00:	eb 01                	jmp    80108e03 <copyuvm+0xde>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
    //  continue;
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      continue;
80108e02:	90                   	nop
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108e03:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e10:	0f 82 3a ff ff ff    	jb     80108d50 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e19:	eb 17                	jmp    80108e32 <copyuvm+0x10d>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108e1b:	90                   	nop
80108e1c:	eb 01                	jmp    80108e1f <copyuvm+0xfa>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108e1e:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108e1f:	83 ec 0c             	sub    $0xc,%esp
80108e22:	ff 75 f0             	pushl  -0x10(%ebp)
80108e25:	e8 1a fe ff ff       	call   80108c44 <freevm>
80108e2a:	83 c4 10             	add    $0x10,%esp
  return 0;
80108e2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e35:	c9                   	leave  
80108e36:	c3                   	ret    

80108e37 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108e37:	55                   	push   %ebp
80108e38:	89 e5                	mov    %esp,%ebp
80108e3a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108e3d:	83 ec 04             	sub    $0x4,%esp
80108e40:	6a 00                	push   $0x0
80108e42:	ff 75 0c             	pushl  0xc(%ebp)
80108e45:	ff 75 08             	pushl  0x8(%ebp)
80108e48:	e8 9a f7 ff ff       	call   801085e7 <walkpgdir>
80108e4d:	83 c4 10             	add    $0x10,%esp
80108e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e56:	8b 00                	mov    (%eax),%eax
80108e58:	83 e0 01             	and    $0x1,%eax
80108e5b:	85 c0                	test   %eax,%eax
80108e5d:	75 07                	jne    80108e66 <uva2ka+0x2f>
    return 0;
80108e5f:	b8 00 00 00 00       	mov    $0x0,%eax
80108e64:	eb 29                	jmp    80108e8f <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e69:	8b 00                	mov    (%eax),%eax
80108e6b:	83 e0 04             	and    $0x4,%eax
80108e6e:	85 c0                	test   %eax,%eax
80108e70:	75 07                	jne    80108e79 <uva2ka+0x42>
    return 0;
80108e72:	b8 00 00 00 00       	mov    $0x0,%eax
80108e77:	eb 16                	jmp    80108e8f <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e7c:	8b 00                	mov    (%eax),%eax
80108e7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e83:	83 ec 0c             	sub    $0xc,%esp
80108e86:	50                   	push   %eax
80108e87:	e8 d9 f2 ff ff       	call   80108165 <p2v>
80108e8c:	83 c4 10             	add    $0x10,%esp
}
80108e8f:	c9                   	leave  
80108e90:	c3                   	ret    

80108e91 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108e91:	55                   	push   %ebp
80108e92:	89 e5                	mov    %esp,%ebp
80108e94:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108e97:	8b 45 10             	mov    0x10(%ebp),%eax
80108e9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108e9d:	eb 7f                	jmp    80108f1e <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ea2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ea7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ead:	83 ec 08             	sub    $0x8,%esp
80108eb0:	50                   	push   %eax
80108eb1:	ff 75 08             	pushl  0x8(%ebp)
80108eb4:	e8 7e ff ff ff       	call   80108e37 <uva2ka>
80108eb9:	83 c4 10             	add    $0x10,%esp
80108ebc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108ebf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ec3:	75 07                	jne    80108ecc <copyout+0x3b>
      return -1;
80108ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eca:	eb 61                	jmp    80108f2d <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ecf:	2b 45 0c             	sub    0xc(%ebp),%eax
80108ed2:	05 00 10 00 00       	add    $0x1000,%eax
80108ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108edd:	3b 45 14             	cmp    0x14(%ebp),%eax
80108ee0:	76 06                	jbe    80108ee8 <copyout+0x57>
      n = len;
80108ee2:	8b 45 14             	mov    0x14(%ebp),%eax
80108ee5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eeb:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108eee:	89 c2                	mov    %eax,%edx
80108ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ef3:	01 d0                	add    %edx,%eax
80108ef5:	83 ec 04             	sub    $0x4,%esp
80108ef8:	ff 75 f0             	pushl  -0x10(%ebp)
80108efb:	ff 75 f4             	pushl  -0xc(%ebp)
80108efe:	50                   	push   %eax
80108eff:	e8 f5 cb ff ff       	call   80105af9 <memmove>
80108f04:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f0a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f10:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f16:	05 00 10 00 00       	add    $0x1000,%eax
80108f1b:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108f1e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108f22:	0f 85 77 ff ff ff    	jne    80108e9f <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f2d:	c9                   	leave  
80108f2e:	c3                   	ret    
