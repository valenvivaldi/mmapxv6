
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
8010002d:	b8 59 38 10 80       	mov    $0x80103859,%eax
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
8010003d:	68 c4 92 10 80       	push   $0x801092c4
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 00 59 00 00       	call   8010594c <initlock>
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
801000c1:	e8 a8 58 00 00       	call   8010596e <acquire>
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
8010010c:	e8 c4 58 00 00       	call   801059d5 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 86 50 00 00       	call   801051b2 <sleep>
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
80100188:	e8 48 58 00 00       	call   801059d5 <release>
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
801001aa:	68 cb 92 10 80       	push   $0x801092cb
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
801001e2:	e8 e8 26 00 00       	call   801028cf <iderw>
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
80100204:	68 dc 92 10 80       	push   $0x801092dc
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
80100223:	e8 a7 26 00 00       	call   801028cf <iderw>
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
80100243:	68 e3 92 10 80       	push   $0x801092e3
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 14 57 00 00       	call   8010596e <acquire>
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
801002b9:	e8 00 50 00 00       	call   801052be <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 07 57 00 00       	call   801059d5 <release>
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
801003e2:	e8 87 55 00 00       	call   8010596e <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 ea 92 10 80       	push   $0x801092ea
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
801004cd:	c7 45 ec f3 92 10 80 	movl   $0x801092f3,-0x14(%ebp)
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
8010055b:	e8 75 54 00 00       	call   801059d5 <release>
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
8010058b:	68 fa 92 10 80       	push   $0x801092fa
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
801005aa:	68 09 93 10 80       	push   $0x80109309
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 60 54 00 00       	call   80105a27 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 0b 93 10 80       	push   $0x8010930b
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
801006db:	e8 b0 55 00 00       	call   80105c90 <memmove>
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
80100705:	e8 c7 54 00 00       	call   80105bd1 <memset>
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
8010079a:	e8 b6 71 00 00       	call   80107955 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 a9 71 00 00       	call   80107955 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 9c 71 00 00       	call   80107955 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 8c 71 00 00       	call   80107955 <uartputc>
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
801007eb:	e8 7e 51 00 00       	call   8010596e <acquire>
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
8010081e:	e8 5d 4b 00 00       	call   80105380 <procdump>
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
80100931:	e8 88 49 00 00       	call   801052be <wakeup>
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
80100954:	e8 7c 50 00 00       	call   801059d5 <release>
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
8010096b:	e8 56 11 00 00       	call   80101ac6 <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 a0 17 11 80       	push   $0x801117a0
80100981:	e8 e8 4f 00 00       	call   8010596e <acquire>
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
801009a3:	e8 2d 50 00 00       	call   801059d5 <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 b8 0f 00 00       	call   8010196e <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 a0 17 11 80       	push   $0x801117a0
801009cb:	68 54 18 11 80       	push   $0x80111854
801009d0:	e8 dd 47 00 00       	call   801051b2 <sleep>
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
80100a4e:	e8 82 4f 00 00       	call   801059d5 <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 0d 0f 00 00       	call   8010196e <ilock>
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
80100a7c:	e8 45 10 00 00       	call   80101ac6 <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a8c:	e8 dd 4e 00 00       	call   8010596e <acquire>
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
80100ace:	e8 02 4f 00 00       	call   801059d5 <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 8d 0e 00 00       	call   8010196e <ilock>
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
80100af2:	68 0f 93 10 80       	push   $0x8010930f
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 4b 4e 00 00       	call   8010594c <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 17 93 10 80       	push   $0x80109317
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 36 4e 00 00       	call   8010594c <initlock>
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
80100b3c:	e8 fa 34 00 00       	call   8010403b <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 4c 1f 00 00       	call   80102a9c <ioapicenable>
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
80100b5f:	e8 b3 29 00 00       	call   80103517 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 b7 19 00 00       	call   80102526 <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 23 2a 00 00       	call   801035a3 <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 d6 03 00 00       	jmp    80100f60 <exec+0x40a>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 d9 0d 00 00       	call   8010196e <ilock>
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
80100bad:	e8 24 13 00 00       	call   80101ed6 <readi>
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
80100bcf:	e8 d6 7e 00 00       	call   80108aaa <setupkvm>
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
80100c0d:	e8 c4 12 00 00       	call   80101ed6 <readi>
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
80100c55:	e8 f7 81 00 00       	call   80108e51 <allocuvm>
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
80100c88:	e8 ed 80 00 00       	call   80108d7a <loaduvm>
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
80100cc1:	e8 62 0f 00 00       	call   80101c28 <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 d5 28 00 00       	call   801035a3 <end_op>
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
80100d16:	e8 36 81 00 00       	call   80108e51 <allocuvm>
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
80100d5c:	e8 bd 50 00 00       	call   80105e1e <strlen>
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
80100d89:	e8 90 50 00 00       	call   80105e1e <strlen>
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
80100daf:	e8 70 84 00 00       	call   80109224 <copyout>
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
80100e4b:	e8 d4 83 00 00       	call   80109224 <copyout>
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
80100e9c:	e8 33 4f 00 00       	call   80105dd4 <safestrcpy>
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
80100ef2:	e8 9a 7c 00 00       	call   80108b91 <switchuvm>
80100ef7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100efa:	83 ec 0c             	sub    $0xc,%esp
80100efd:	ff 75 d0             	pushl  -0x30(%ebp)
80100f00:	e8 d2 80 00 00       	call   80108fd7 <freevm>
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
80100f3a:	e8 98 80 00 00       	call   80108fd7 <freevm>
80100f3f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f46:	74 13                	je     80100f5b <exec+0x405>
    iunlockput(ip);
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	ff 75 d8             	pushl  -0x28(%ebp)
80100f4e:	e8 d5 0c 00 00       	call   80101c28 <iunlockput>
80100f53:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f56:	e8 48 26 00 00       	call   801035a3 <end_op>
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
80100f6b:	68 1d 93 10 80       	push   $0x8010931d
80100f70:	68 60 18 11 80       	push   $0x80111860
80100f75:	e8 d2 49 00 00       	call   8010594c <initlock>
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
80100f8e:	e8 db 49 00 00       	call   8010596e <acquire>
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
80100fbb:	e8 15 4a 00 00       	call   801059d5 <release>
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
80100fde:	e8 f2 49 00 00       	call   801059d5 <release>
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
80100ffb:	e8 6e 49 00 00       	call   8010596e <acquire>
80101000:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	8b 40 04             	mov    0x4(%eax),%eax
80101009:	85 c0                	test   %eax,%eax
8010100b:	7f 0d                	jg     8010101a <filedup+0x2d>
    panic("filedup");
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 24 93 10 80       	push   $0x80109324
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
80101031:	e8 9f 49 00 00       	call   801059d5 <release>
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
8010104c:	e8 1d 49 00 00       	call   8010596e <acquire>
80101051:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	7f 0d                	jg     8010106b <fileclose+0x2d>
    panic("fileclose");
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 2c 93 10 80       	push   $0x8010932c
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
8010108c:	e8 44 49 00 00       	call   801059d5 <release>
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
801010da:	e8 f6 48 00 00       	call   801059d5 <release>
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
801010f9:	e8 a6 31 00 00       	call   801042a4 <pipeclose>
801010fe:	83 c4 10             	add    $0x10,%esp
80101101:	eb 21                	jmp    80101124 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101103:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101106:	83 f8 02             	cmp    $0x2,%eax
80101109:	75 19                	jne    80101124 <fileclose+0xe6>
    begin_op();
8010110b:	e8 07 24 00 00       	call   80103517 <begin_op>
    iput(ff.ip);
80101110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	50                   	push   %eax
80101117:	e8 1c 0a 00 00       	call   80101b38 <iput>
8010111c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010111f:	e8 7f 24 00 00       	call   801035a3 <end_op>
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
80101140:	e8 29 08 00 00       	call   8010196e <ilock>
80101145:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 40 10             	mov    0x10(%eax),%eax
8010114e:	83 ec 08             	sub    $0x8,%esp
80101151:	ff 75 0c             	pushl  0xc(%ebp)
80101154:	50                   	push   %eax
80101155:	e8 36 0d 00 00       	call   80101e90 <stati>
8010115a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	8b 40 10             	mov    0x10(%eax),%eax
80101163:	83 ec 0c             	sub    $0xc,%esp
80101166:	50                   	push   %eax
80101167:	e8 5a 09 00 00       	call   80101ac6 <iunlock>
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
801011b2:	e8 95 32 00 00       	call   8010444c <piperead>
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
801011d0:	e8 99 07 00 00       	call   8010196e <ilock>
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
801011ed:	e8 e4 0c 00 00       	call   80101ed6 <readi>
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
80101219:	e8 a8 08 00 00       	call   80101ac6 <iunlock>
8010121e:	83 c4 10             	add    $0x10,%esp
    return r;
80101221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101224:	eb 0d                	jmp    80101233 <fileread+0xb6>
  }
  panic("fileread");
80101226:	83 ec 0c             	sub    $0xc,%esp
80101229:	68 36 93 10 80       	push   $0x80109336
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
8010126b:	e8 de 30 00 00       	call   8010434e <pipewrite>
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
801012b0:	e8 62 22 00 00       	call   80103517 <begin_op>
      ilock(f->ip);
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 40 10             	mov    0x10(%eax),%eax
801012bb:	83 ec 0c             	sub    $0xc,%esp
801012be:	50                   	push   %eax
801012bf:	e8 aa 06 00 00       	call   8010196e <ilock>
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
801012e2:	e8 46 0d 00 00       	call   8010202d <writei>
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
8010130e:	e8 b3 07 00 00       	call   80101ac6 <iunlock>
80101313:	83 c4 10             	add    $0x10,%esp
      end_op();
80101316:	e8 88 22 00 00       	call   801035a3 <end_op>

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
8010132c:	68 3f 93 10 80       	push   $0x8010933f
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
80101362:	68 4f 93 10 80       	push   $0x8010934f
80101367:	e8 fa f1 ff ff       	call   80100566 <panic>
}
8010136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010136f:	c9                   	leave  
80101370:	c3                   	ret    

80101371 <fileseek>:


int
fileseek(struct file *f, uint newoffset)
{
80101371:	55                   	push   %ebp
80101372:	89 e5                	mov    %esp,%ebp
  if(f->readable == 0){
80101374:	8b 45 08             	mov    0x8(%ebp),%eax
80101377:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010137b:	84 c0                	test   %al,%al
8010137d:	75 07                	jne    80101386 <fileseek+0x15>
    return -1;
8010137f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101384:	eb 44                	jmp    801013ca <fileseek+0x59>
  }
  if(f->writable == 0)
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010138d:	84 c0                	test   %al,%al
8010138f:	75 07                	jne    80101398 <fileseek+0x27>
    return -1;
80101391:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101396:	eb 32                	jmp    801013ca <fileseek+0x59>
  if(newoffset<0)
    return -1;
  if(newoffset > f->ip->size){
80101398:	8b 45 08             	mov    0x8(%ebp),%eax
8010139b:	8b 40 10             	mov    0x10(%eax),%eax
8010139e:	8b 40 18             	mov    0x18(%eax),%eax
801013a1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801013a4:	73 16                	jae    801013bc <fileseek+0x4b>
      f->off = f->ip->size;
801013a6:	8b 45 08             	mov    0x8(%ebp),%eax
801013a9:	8b 40 10             	mov    0x10(%eax),%eax
801013ac:	8b 50 18             	mov    0x18(%eax),%edx
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	89 50 14             	mov    %edx,0x14(%eax)
      return 0;
801013b5:	b8 00 00 00 00       	mov    $0x0,%eax
801013ba:	eb 0e                	jmp    801013ca <fileseek+0x59>
  }

  f->off = newoffset;
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801013c2:	89 50 14             	mov    %edx,0x14(%eax)
  return 0;
801013c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801013ca:	5d                   	pop    %ebp
801013cb:	c3                   	ret    

801013cc <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013cc:	55                   	push   %ebp
801013cd:	89 e5                	mov    %esp,%ebp
801013cf:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d2:	8b 45 08             	mov    0x8(%ebp),%eax
801013d5:	83 ec 08             	sub    $0x8,%esp
801013d8:	6a 01                	push   $0x1
801013da:	50                   	push   %eax
801013db:	e8 d6 ed ff ff       	call   801001b6 <bread>
801013e0:	83 c4 10             	add    $0x10,%esp
801013e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e9:	83 c0 18             	add    $0x18,%eax
801013ec:	83 ec 04             	sub    $0x4,%esp
801013ef:	6a 10                	push   $0x10
801013f1:	50                   	push   %eax
801013f2:	ff 75 0c             	pushl  0xc(%ebp)
801013f5:	e8 96 48 00 00       	call   80105c90 <memmove>
801013fa:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013fd:	83 ec 0c             	sub    $0xc,%esp
80101400:	ff 75 f4             	pushl  -0xc(%ebp)
80101403:	e8 26 ee ff ff       	call   8010022e <brelse>
80101408:	83 c4 10             	add    $0x10,%esp
}
8010140b:	90                   	nop
8010140c:	c9                   	leave  
8010140d:	c3                   	ret    

8010140e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010140e:	55                   	push   %ebp
8010140f:	89 e5                	mov    %esp,%ebp
80101411:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101414:	8b 55 0c             	mov    0xc(%ebp),%edx
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	83 ec 08             	sub    $0x8,%esp
8010141d:	52                   	push   %edx
8010141e:	50                   	push   %eax
8010141f:	e8 92 ed ff ff       	call   801001b6 <bread>
80101424:	83 c4 10             	add    $0x10,%esp
80101427:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142d:	83 c0 18             	add    $0x18,%eax
80101430:	83 ec 04             	sub    $0x4,%esp
80101433:	68 00 02 00 00       	push   $0x200
80101438:	6a 00                	push   $0x0
8010143a:	50                   	push   %eax
8010143b:	e8 91 47 00 00       	call   80105bd1 <memset>
80101440:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101443:	83 ec 0c             	sub    $0xc,%esp
80101446:	ff 75 f4             	pushl  -0xc(%ebp)
80101449:	e8 01 23 00 00       	call   8010374f <log_write>
8010144e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101451:	83 ec 0c             	sub    $0xc,%esp
80101454:	ff 75 f4             	pushl  -0xc(%ebp)
80101457:	e8 d2 ed ff ff       	call   8010022e <brelse>
8010145c:	83 c4 10             	add    $0x10,%esp
}
8010145f:	90                   	nop
80101460:	c9                   	leave  
80101461:	c3                   	ret    

80101462 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101462:	55                   	push   %ebp
80101463:	89 e5                	mov    %esp,%ebp
80101465:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101468:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010146f:	8b 45 08             	mov    0x8(%ebp),%eax
80101472:	83 ec 08             	sub    $0x8,%esp
80101475:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101478:	52                   	push   %edx
80101479:	50                   	push   %eax
8010147a:	e8 4d ff ff ff       	call   801013cc <readsb>
8010147f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101482:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101489:	e9 15 01 00 00       	jmp    801015a3 <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101491:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101497:	85 c0                	test   %eax,%eax
80101499:	0f 48 c2             	cmovs  %edx,%eax
8010149c:	c1 f8 0c             	sar    $0xc,%eax
8010149f:	89 c2                	mov    %eax,%edx
801014a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014a4:	c1 e8 03             	shr    $0x3,%eax
801014a7:	01 d0                	add    %edx,%eax
801014a9:	83 c0 03             	add    $0x3,%eax
801014ac:	83 ec 08             	sub    $0x8,%esp
801014af:	50                   	push   %eax
801014b0:	ff 75 08             	pushl  0x8(%ebp)
801014b3:	e8 fe ec ff ff       	call   801001b6 <bread>
801014b8:	83 c4 10             	add    $0x10,%esp
801014bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014c5:	e9 a6 00 00 00       	jmp    80101570 <balloc+0x10e>
      m = 1 << (bi % 8);
801014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cd:	99                   	cltd   
801014ce:	c1 ea 1d             	shr    $0x1d,%edx
801014d1:	01 d0                	add    %edx,%eax
801014d3:	83 e0 07             	and    $0x7,%eax
801014d6:	29 d0                	sub    %edx,%eax
801014d8:	ba 01 00 00 00       	mov    $0x1,%edx
801014dd:	89 c1                	mov    %eax,%ecx
801014df:	d3 e2                	shl    %cl,%edx
801014e1:	89 d0                	mov    %edx,%eax
801014e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e9:	8d 50 07             	lea    0x7(%eax),%edx
801014ec:	85 c0                	test   %eax,%eax
801014ee:	0f 48 c2             	cmovs  %edx,%eax
801014f1:	c1 f8 03             	sar    $0x3,%eax
801014f4:	89 c2                	mov    %eax,%edx
801014f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014f9:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014fe:	0f b6 c0             	movzbl %al,%eax
80101501:	23 45 e8             	and    -0x18(%ebp),%eax
80101504:	85 c0                	test   %eax,%eax
80101506:	75 64                	jne    8010156c <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
80101508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150b:	8d 50 07             	lea    0x7(%eax),%edx
8010150e:	85 c0                	test   %eax,%eax
80101510:	0f 48 c2             	cmovs  %edx,%eax
80101513:	c1 f8 03             	sar    $0x3,%eax
80101516:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101519:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010151e:	89 d1                	mov    %edx,%ecx
80101520:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101523:	09 ca                	or     %ecx,%edx
80101525:	89 d1                	mov    %edx,%ecx
80101527:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010152a:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010152e:	83 ec 0c             	sub    $0xc,%esp
80101531:	ff 75 ec             	pushl  -0x14(%ebp)
80101534:	e8 16 22 00 00       	call   8010374f <log_write>
80101539:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010153c:	83 ec 0c             	sub    $0xc,%esp
8010153f:	ff 75 ec             	pushl  -0x14(%ebp)
80101542:	e8 e7 ec ff ff       	call   8010022e <brelse>
80101547:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010154a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101550:	01 c2                	add    %eax,%edx
80101552:	8b 45 08             	mov    0x8(%ebp),%eax
80101555:	83 ec 08             	sub    $0x8,%esp
80101558:	52                   	push   %edx
80101559:	50                   	push   %eax
8010155a:	e8 af fe ff ff       	call   8010140e <bzero>
8010155f:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101562:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101568:	01 d0                	add    %edx,%eax
8010156a:	eb 52                	jmp    801015be <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010156c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101570:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101577:	7f 15                	jg     8010158e <balloc+0x12c>
80101579:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157f:	01 d0                	add    %edx,%eax
80101581:	89 c2                	mov    %eax,%edx
80101583:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101586:	39 c2                	cmp    %eax,%edx
80101588:	0f 82 3c ff ff ff    	jb     801014ca <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010158e:	83 ec 0c             	sub    $0xc,%esp
80101591:	ff 75 ec             	pushl  -0x14(%ebp)
80101594:	e8 95 ec ff ff       	call   8010022e <brelse>
80101599:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010159c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
801015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a9:	39 c2                	cmp    %eax,%edx
801015ab:	0f 87 dd fe ff ff    	ja     8010148e <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015b1:	83 ec 0c             	sub    $0xc,%esp
801015b4:	68 59 93 10 80       	push   $0x80109359
801015b9:	e8 a8 ef ff ff       	call   80100566 <panic>
}
801015be:	c9                   	leave  
801015bf:	c3                   	ret    

801015c0 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801015c6:	83 ec 08             	sub    $0x8,%esp
801015c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
801015cc:	50                   	push   %eax
801015cd:	ff 75 08             	pushl  0x8(%ebp)
801015d0:	e8 f7 fd ff ff       	call   801013cc <readsb>
801015d5:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801015d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801015db:	c1 e8 0c             	shr    $0xc,%eax
801015de:	89 c2                	mov    %eax,%edx
801015e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015e3:	c1 e8 03             	shr    $0x3,%eax
801015e6:	01 d0                	add    %edx,%eax
801015e8:	8d 50 03             	lea    0x3(%eax),%edx
801015eb:	8b 45 08             	mov    0x8(%ebp),%eax
801015ee:	83 ec 08             	sub    $0x8,%esp
801015f1:	52                   	push   %edx
801015f2:	50                   	push   %eax
801015f3:	e8 be eb ff ff       	call   801001b6 <bread>
801015f8:	83 c4 10             	add    $0x10,%esp
801015fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101601:	25 ff 0f 00 00       	and    $0xfff,%eax
80101606:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160c:	99                   	cltd   
8010160d:	c1 ea 1d             	shr    $0x1d,%edx
80101610:	01 d0                	add    %edx,%eax
80101612:	83 e0 07             	and    $0x7,%eax
80101615:	29 d0                	sub    %edx,%eax
80101617:	ba 01 00 00 00       	mov    $0x1,%edx
8010161c:	89 c1                	mov    %eax,%ecx
8010161e:	d3 e2                	shl    %cl,%edx
80101620:	89 d0                	mov    %edx,%eax
80101622:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101625:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101628:	8d 50 07             	lea    0x7(%eax),%edx
8010162b:	85 c0                	test   %eax,%eax
8010162d:	0f 48 c2             	cmovs  %edx,%eax
80101630:	c1 f8 03             	sar    $0x3,%eax
80101633:	89 c2                	mov    %eax,%edx
80101635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101638:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010163d:	0f b6 c0             	movzbl %al,%eax
80101640:	23 45 ec             	and    -0x14(%ebp),%eax
80101643:	85 c0                	test   %eax,%eax
80101645:	75 0d                	jne    80101654 <bfree+0x94>
    panic("freeing free block");
80101647:	83 ec 0c             	sub    $0xc,%esp
8010164a:	68 6f 93 10 80       	push   $0x8010936f
8010164f:	e8 12 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101657:	8d 50 07             	lea    0x7(%eax),%edx
8010165a:	85 c0                	test   %eax,%eax
8010165c:	0f 48 c2             	cmovs  %edx,%eax
8010165f:	c1 f8 03             	sar    $0x3,%eax
80101662:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101665:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010166a:	89 d1                	mov    %edx,%ecx
8010166c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010166f:	f7 d2                	not    %edx
80101671:	21 ca                	and    %ecx,%edx
80101673:	89 d1                	mov    %edx,%ecx
80101675:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101678:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010167c:	83 ec 0c             	sub    $0xc,%esp
8010167f:	ff 75 f4             	pushl  -0xc(%ebp)
80101682:	e8 c8 20 00 00       	call   8010374f <log_write>
80101687:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010168a:	83 ec 0c             	sub    $0xc,%esp
8010168d:	ff 75 f4             	pushl  -0xc(%ebp)
80101690:	e8 99 eb ff ff       	call   8010022e <brelse>
80101695:	83 c4 10             	add    $0x10,%esp
}
80101698:	90                   	nop
80101699:	c9                   	leave  
8010169a:	c3                   	ret    

8010169b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010169b:	55                   	push   %ebp
8010169c:	89 e5                	mov    %esp,%ebp
8010169e:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
801016a1:	83 ec 08             	sub    $0x8,%esp
801016a4:	68 82 93 10 80       	push   $0x80109382
801016a9:	68 60 22 11 80       	push   $0x80112260
801016ae:	e8 99 42 00 00       	call   8010594c <initlock>
801016b3:	83 c4 10             	add    $0x10,%esp
}
801016b6:	90                   	nop
801016b7:	c9                   	leave  
801016b8:	c3                   	ret    

801016b9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016b9:	55                   	push   %ebp
801016ba:	89 e5                	mov    %esp,%ebp
801016bc:	83 ec 38             	sub    $0x38,%esp
801016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c2:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801016c6:	8b 45 08             	mov    0x8(%ebp),%eax
801016c9:	83 ec 08             	sub    $0x8,%esp
801016cc:	8d 55 dc             	lea    -0x24(%ebp),%edx
801016cf:	52                   	push   %edx
801016d0:	50                   	push   %eax
801016d1:	e8 f6 fc ff ff       	call   801013cc <readsb>
801016d6:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
801016d9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016e0:	e9 98 00 00 00       	jmp    8010177d <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
801016e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e8:	c1 e8 03             	shr    $0x3,%eax
801016eb:	83 c0 02             	add    $0x2,%eax
801016ee:	83 ec 08             	sub    $0x8,%esp
801016f1:	50                   	push   %eax
801016f2:	ff 75 08             	pushl  0x8(%ebp)
801016f5:	e8 bc ea ff ff       	call   801001b6 <bread>
801016fa:	83 c4 10             	add    $0x10,%esp
801016fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101703:	8d 50 18             	lea    0x18(%eax),%edx
80101706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101709:	83 e0 07             	and    $0x7,%eax
8010170c:	c1 e0 06             	shl    $0x6,%eax
8010170f:	01 d0                	add    %edx,%eax
80101711:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101714:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101717:	0f b7 00             	movzwl (%eax),%eax
8010171a:	66 85 c0             	test   %ax,%ax
8010171d:	75 4c                	jne    8010176b <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
8010171f:	83 ec 04             	sub    $0x4,%esp
80101722:	6a 40                	push   $0x40
80101724:	6a 00                	push   $0x0
80101726:	ff 75 ec             	pushl  -0x14(%ebp)
80101729:	e8 a3 44 00 00       	call   80105bd1 <memset>
8010172e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101731:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101734:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101738:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010173b:	83 ec 0c             	sub    $0xc,%esp
8010173e:	ff 75 f0             	pushl  -0x10(%ebp)
80101741:	e8 09 20 00 00       	call   8010374f <log_write>
80101746:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101749:	83 ec 0c             	sub    $0xc,%esp
8010174c:	ff 75 f0             	pushl  -0x10(%ebp)
8010174f:	e8 da ea ff ff       	call   8010022e <brelse>
80101754:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175a:	83 ec 08             	sub    $0x8,%esp
8010175d:	50                   	push   %eax
8010175e:	ff 75 08             	pushl  0x8(%ebp)
80101761:	e8 ef 00 00 00       	call   80101855 <iget>
80101766:	83 c4 10             	add    $0x10,%esp
80101769:	eb 2d                	jmp    80101798 <ialloc+0xdf>
    }
    brelse(bp);
8010176b:	83 ec 0c             	sub    $0xc,%esp
8010176e:	ff 75 f0             	pushl  -0x10(%ebp)
80101771:	e8 b8 ea ff ff       	call   8010022e <brelse>
80101776:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101779:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010177d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101783:	39 c2                	cmp    %eax,%edx
80101785:	0f 87 5a ff ff ff    	ja     801016e5 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010178b:	83 ec 0c             	sub    $0xc,%esp
8010178e:	68 89 93 10 80       	push   $0x80109389
80101793:	e8 ce ed ff ff       	call   80100566 <panic>
}
80101798:	c9                   	leave  
80101799:	c3                   	ret    

8010179a <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010179a:	55                   	push   %ebp
8010179b:	89 e5                	mov    %esp,%ebp
8010179d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801017a0:	8b 45 08             	mov    0x8(%ebp),%eax
801017a3:	8b 40 04             	mov    0x4(%eax),%eax
801017a6:	c1 e8 03             	shr    $0x3,%eax
801017a9:	8d 50 02             	lea    0x2(%eax),%edx
801017ac:	8b 45 08             	mov    0x8(%ebp),%eax
801017af:	8b 00                	mov    (%eax),%eax
801017b1:	83 ec 08             	sub    $0x8,%esp
801017b4:	52                   	push   %edx
801017b5:	50                   	push   %eax
801017b6:	e8 fb e9 ff ff       	call   801001b6 <bread>
801017bb:	83 c4 10             	add    $0x10,%esp
801017be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c4:	8d 50 18             	lea    0x18(%eax),%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 40 04             	mov    0x4(%eax),%eax
801017cd:	83 e0 07             	and    $0x7,%eax
801017d0:	c1 e0 06             	shl    $0x6,%eax
801017d3:	01 d0                	add    %edx,%eax
801017d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017d8:	8b 45 08             	mov    0x8(%ebp),%eax
801017db:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e2:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e5:	8b 45 08             	mov    0x8(%ebp),%eax
801017e8:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ef:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017f3:	8b 45 08             	mov    0x8(%ebp),%eax
801017f6:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101801:	8b 45 08             	mov    0x8(%ebp),%eax
80101804:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010180f:	8b 45 08             	mov    0x8(%ebp),%eax
80101812:	8b 50 18             	mov    0x18(%eax),%edx
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8d 50 1c             	lea    0x1c(%eax),%edx
80101821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101824:	83 c0 0c             	add    $0xc,%eax
80101827:	83 ec 04             	sub    $0x4,%esp
8010182a:	6a 34                	push   $0x34
8010182c:	52                   	push   %edx
8010182d:	50                   	push   %eax
8010182e:	e8 5d 44 00 00       	call   80105c90 <memmove>
80101833:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101836:	83 ec 0c             	sub    $0xc,%esp
80101839:	ff 75 f4             	pushl  -0xc(%ebp)
8010183c:	e8 0e 1f 00 00       	call   8010374f <log_write>
80101841:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101844:	83 ec 0c             	sub    $0xc,%esp
80101847:	ff 75 f4             	pushl  -0xc(%ebp)
8010184a:	e8 df e9 ff ff       	call   8010022e <brelse>
8010184f:	83 c4 10             	add    $0x10,%esp
}
80101852:	90                   	nop
80101853:	c9                   	leave  
80101854:	c3                   	ret    

80101855 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101855:	55                   	push   %ebp
80101856:	89 e5                	mov    %esp,%ebp
80101858:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010185b:	83 ec 0c             	sub    $0xc,%esp
8010185e:	68 60 22 11 80       	push   $0x80112260
80101863:	e8 06 41 00 00       	call   8010596e <acquire>
80101868:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010186b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101872:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101879:	eb 5d                	jmp    801018d8 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187e:	8b 40 08             	mov    0x8(%eax),%eax
80101881:	85 c0                	test   %eax,%eax
80101883:	7e 39                	jle    801018be <iget+0x69>
80101885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101888:	8b 00                	mov    (%eax),%eax
8010188a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010188d:	75 2f                	jne    801018be <iget+0x69>
8010188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101892:	8b 40 04             	mov    0x4(%eax),%eax
80101895:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101898:	75 24                	jne    801018be <iget+0x69>
      ip->ref++;
8010189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189d:	8b 40 08             	mov    0x8(%eax),%eax
801018a0:	8d 50 01             	lea    0x1(%eax),%edx
801018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a6:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a9:	83 ec 0c             	sub    $0xc,%esp
801018ac:	68 60 22 11 80       	push   $0x80112260
801018b1:	e8 1f 41 00 00       	call   801059d5 <release>
801018b6:	83 c4 10             	add    $0x10,%esp
      return ip;
801018b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bc:	eb 74                	jmp    80101932 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c2:	75 10                	jne    801018d4 <iget+0x7f>
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8b 40 08             	mov    0x8(%eax),%eax
801018ca:	85 c0                	test   %eax,%eax
801018cc:	75 06                	jne    801018d4 <iget+0x7f>
      empty = ip;
801018ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d4:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d8:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801018df:	72 9a                	jb     8010187b <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e5:	75 0d                	jne    801018f4 <iget+0x9f>
    panic("iget: no inodes");
801018e7:	83 ec 0c             	sub    $0xc,%esp
801018ea:	68 9b 93 10 80       	push   $0x8010939b
801018ef:	e8 72 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fd:	8b 55 08             	mov    0x8(%ebp),%edx
80101900:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101905:	8b 55 0c             	mov    0xc(%ebp),%edx
80101908:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010191f:	83 ec 0c             	sub    $0xc,%esp
80101922:	68 60 22 11 80       	push   $0x80112260
80101927:	e8 a9 40 00 00       	call   801059d5 <release>
8010192c:	83 c4 10             	add    $0x10,%esp

  return ip;
8010192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101932:	c9                   	leave  
80101933:	c3                   	ret    

80101934 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101934:	55                   	push   %ebp
80101935:	89 e5                	mov    %esp,%ebp
80101937:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 60 22 11 80       	push   $0x80112260
80101942:	e8 27 40 00 00       	call   8010596e <acquire>
80101947:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
8010194a:	8b 45 08             	mov    0x8(%ebp),%eax
8010194d:	8b 40 08             	mov    0x8(%eax),%eax
80101950:	8d 50 01             	lea    0x1(%eax),%edx
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101959:	83 ec 0c             	sub    $0xc,%esp
8010195c:	68 60 22 11 80       	push   $0x80112260
80101961:	e8 6f 40 00 00       	call   801059d5 <release>
80101966:	83 c4 10             	add    $0x10,%esp
  return ip;
80101969:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010196c:	c9                   	leave  
8010196d:	c3                   	ret    

8010196e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010196e:	55                   	push   %ebp
8010196f:	89 e5                	mov    %esp,%ebp
80101971:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101974:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101978:	74 0a                	je     80101984 <ilock+0x16>
8010197a:	8b 45 08             	mov    0x8(%ebp),%eax
8010197d:	8b 40 08             	mov    0x8(%eax),%eax
80101980:	85 c0                	test   %eax,%eax
80101982:	7f 0d                	jg     80101991 <ilock+0x23>
    panic("ilock");
80101984:	83 ec 0c             	sub    $0xc,%esp
80101987:	68 ab 93 10 80       	push   $0x801093ab
8010198c:	e8 d5 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101991:	83 ec 0c             	sub    $0xc,%esp
80101994:	68 60 22 11 80       	push   $0x80112260
80101999:	e8 d0 3f 00 00       	call   8010596e <acquire>
8010199e:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019a1:	eb 13                	jmp    801019b6 <ilock+0x48>
    sleep(ip, &icache.lock);
801019a3:	83 ec 08             	sub    $0x8,%esp
801019a6:	68 60 22 11 80       	push   $0x80112260
801019ab:	ff 75 08             	pushl  0x8(%ebp)
801019ae:	e8 ff 37 00 00       	call   801051b2 <sleep>
801019b3:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b6:	8b 45 08             	mov    0x8(%ebp),%eax
801019b9:	8b 40 0c             	mov    0xc(%eax),%eax
801019bc:	83 e0 01             	and    $0x1,%eax
801019bf:	85 c0                	test   %eax,%eax
801019c1:	75 e0                	jne    801019a3 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019c3:	8b 45 08             	mov    0x8(%ebp),%eax
801019c6:	8b 40 0c             	mov    0xc(%eax),%eax
801019c9:	83 c8 01             	or     $0x1,%eax
801019cc:	89 c2                	mov    %eax,%edx
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d4:	83 ec 0c             	sub    $0xc,%esp
801019d7:	68 60 22 11 80       	push   $0x80112260
801019dc:	e8 f4 3f 00 00       	call   801059d5 <release>
801019e1:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ea:	83 e0 02             	and    $0x2,%eax
801019ed:	85 c0                	test   %eax,%eax
801019ef:	0f 85 ce 00 00 00    	jne    80101ac3 <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	8b 40 04             	mov    0x4(%eax),%eax
801019fb:	c1 e8 03             	shr    $0x3,%eax
801019fe:	8d 50 02             	lea    0x2(%eax),%edx
80101a01:	8b 45 08             	mov    0x8(%ebp),%eax
80101a04:	8b 00                	mov    (%eax),%eax
80101a06:	83 ec 08             	sub    $0x8,%esp
80101a09:	52                   	push   %edx
80101a0a:	50                   	push   %eax
80101a0b:	e8 a6 e7 ff ff       	call   801001b6 <bread>
80101a10:	83 c4 10             	add    $0x10,%esp
80101a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a19:	8d 50 18             	lea    0x18(%eax),%edx
80101a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1f:	8b 40 04             	mov    0x4(%eax),%eax
80101a22:	83 e0 07             	and    $0x7,%eax
80101a25:	c1 e0 06             	shl    $0x6,%eax
80101a28:	01 d0                	add    %edx,%eax
80101a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a30:	0f b7 10             	movzwl (%eax),%edx
80101a33:	8b 45 08             	mov    0x8(%ebp),%eax
80101a36:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a59:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a67:	8b 50 08             	mov    0x8(%eax),%edx
80101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6d:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a73:	8d 50 0c             	lea    0xc(%eax),%edx
80101a76:	8b 45 08             	mov    0x8(%ebp),%eax
80101a79:	83 c0 1c             	add    $0x1c,%eax
80101a7c:	83 ec 04             	sub    $0x4,%esp
80101a7f:	6a 34                	push   $0x34
80101a81:	52                   	push   %edx
80101a82:	50                   	push   %eax
80101a83:	e8 08 42 00 00       	call   80105c90 <memmove>
80101a88:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a8b:	83 ec 0c             	sub    $0xc,%esp
80101a8e:	ff 75 f4             	pushl  -0xc(%ebp)
80101a91:	e8 98 e7 ff ff       	call   8010022e <brelse>
80101a96:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a99:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a9f:	83 c8 02             	or     $0x2,%eax
80101aa2:	89 c2                	mov    %eax,%edx
80101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa7:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab1:	66 85 c0             	test   %ax,%ax
80101ab4:	75 0d                	jne    80101ac3 <ilock+0x155>
      panic("ilock: no type");
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	68 b1 93 10 80       	push   $0x801093b1
80101abe:	e8 a3 ea ff ff       	call   80100566 <panic>
  }
}
80101ac3:	90                   	nop
80101ac4:	c9                   	leave  
80101ac5:	c3                   	ret    

80101ac6 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac6:	55                   	push   %ebp
80101ac7:	89 e5                	mov    %esp,%ebp
80101ac9:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101acc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad0:	74 17                	je     80101ae9 <iunlock+0x23>
80101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad5:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad8:	83 e0 01             	and    $0x1,%eax
80101adb:	85 c0                	test   %eax,%eax
80101add:	74 0a                	je     80101ae9 <iunlock+0x23>
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	8b 40 08             	mov    0x8(%eax),%eax
80101ae5:	85 c0                	test   %eax,%eax
80101ae7:	7f 0d                	jg     80101af6 <iunlock+0x30>
    panic("iunlock");
80101ae9:	83 ec 0c             	sub    $0xc,%esp
80101aec:	68 c0 93 10 80       	push   $0x801093c0
80101af1:	e8 70 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af6:	83 ec 0c             	sub    $0xc,%esp
80101af9:	68 60 22 11 80       	push   $0x80112260
80101afe:	e8 6b 3e 00 00       	call   8010596e <acquire>
80101b03:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b06:	8b 45 08             	mov    0x8(%ebp),%eax
80101b09:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0c:	83 e0 fe             	and    $0xfffffffe,%eax
80101b0f:	89 c2                	mov    %eax,%edx
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	ff 75 08             	pushl  0x8(%ebp)
80101b1d:	e8 9c 37 00 00       	call   801052be <wakeup>
80101b22:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 60 22 11 80       	push   $0x80112260
80101b2d:	e8 a3 3e 00 00       	call   801059d5 <release>
80101b32:	83 c4 10             	add    $0x10,%esp
}
80101b35:	90                   	nop
80101b36:	c9                   	leave  
80101b37:	c3                   	ret    

80101b38 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b38:	55                   	push   %ebp
80101b39:	89 e5                	mov    %esp,%ebp
80101b3b:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b3e:	83 ec 0c             	sub    $0xc,%esp
80101b41:	68 60 22 11 80       	push   $0x80112260
80101b46:	e8 23 3e 00 00       	call   8010596e <acquire>
80101b4b:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	83 f8 01             	cmp    $0x1,%eax
80101b57:	0f 85 a9 00 00 00    	jne    80101c06 <iput+0xce>
80101b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b60:	8b 40 0c             	mov    0xc(%eax),%eax
80101b63:	83 e0 02             	and    $0x2,%eax
80101b66:	85 c0                	test   %eax,%eax
80101b68:	0f 84 98 00 00 00    	je     80101c06 <iput+0xce>
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b75:	66 85 c0             	test   %ax,%ax
80101b78:	0f 85 88 00 00 00    	jne    80101c06 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 40 0c             	mov    0xc(%eax),%eax
80101b84:	83 e0 01             	and    $0x1,%eax
80101b87:	85 c0                	test   %eax,%eax
80101b89:	74 0d                	je     80101b98 <iput+0x60>
      panic("iput busy");
80101b8b:	83 ec 0c             	sub    $0xc,%esp
80101b8e:	68 c8 93 10 80       	push   $0x801093c8
80101b93:	e8 ce e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b98:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b9e:	83 c8 01             	or     $0x1,%eax
80101ba1:	89 c2                	mov    %eax,%edx
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	68 60 22 11 80       	push   $0x80112260
80101bb1:	e8 1f 3e 00 00       	call   801059d5 <release>
80101bb6:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bb9:	83 ec 0c             	sub    $0xc,%esp
80101bbc:	ff 75 08             	pushl  0x8(%ebp)
80101bbf:	e8 a8 01 00 00       	call   80101d6c <itrunc>
80101bc4:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bca:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bd0:	83 ec 0c             	sub    $0xc,%esp
80101bd3:	ff 75 08             	pushl  0x8(%ebp)
80101bd6:	e8 bf fb ff ff       	call   8010179a <iupdate>
80101bdb:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	68 60 22 11 80       	push   $0x80112260
80101be6:	e8 83 3d 00 00       	call   8010596e <acquire>
80101beb:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bf8:	83 ec 0c             	sub    $0xc,%esp
80101bfb:	ff 75 08             	pushl  0x8(%ebp)
80101bfe:	e8 bb 36 00 00       	call   801052be <wakeup>
80101c03:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c06:	8b 45 08             	mov    0x8(%ebp),%eax
80101c09:	8b 40 08             	mov    0x8(%eax),%eax
80101c0c:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c12:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c15:	83 ec 0c             	sub    $0xc,%esp
80101c18:	68 60 22 11 80       	push   $0x80112260
80101c1d:	e8 b3 3d 00 00       	call   801059d5 <release>
80101c22:	83 c4 10             	add    $0x10,%esp
}
80101c25:	90                   	nop
80101c26:	c9                   	leave  
80101c27:	c3                   	ret    

80101c28 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c28:	55                   	push   %ebp
80101c29:	89 e5                	mov    %esp,%ebp
80101c2b:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c2e:	83 ec 0c             	sub    $0xc,%esp
80101c31:	ff 75 08             	pushl  0x8(%ebp)
80101c34:	e8 8d fe ff ff       	call   80101ac6 <iunlock>
80101c39:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3c:	83 ec 0c             	sub    $0xc,%esp
80101c3f:	ff 75 08             	pushl  0x8(%ebp)
80101c42:	e8 f1 fe ff ff       	call   80101b38 <iput>
80101c47:	83 c4 10             	add    $0x10,%esp
}
80101c4a:	90                   	nop
80101c4b:	c9                   	leave  
80101c4c:	c3                   	ret    

80101c4d <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c4d:	55                   	push   %ebp
80101c4e:	89 e5                	mov    %esp,%ebp
80101c50:	53                   	push   %ebx
80101c51:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c54:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c58:	77 42                	ja     80101c9c <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c60:	83 c2 04             	add    $0x4,%edx
80101c63:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c6e:	75 24                	jne    80101c94 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 00                	mov    (%eax),%eax
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	50                   	push   %eax
80101c79:	e8 e4 f7 ff ff       	call   80101462 <balloc>
80101c7e:	83 c4 10             	add    $0x10,%esp
80101c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8a:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c90:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c97:	e9 cb 00 00 00       	jmp    80101d67 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c9c:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca0:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca4:	0f 87 b0 00 00 00    	ja     80101d5a <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb7:	75 1d                	jne    80101cd6 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 00                	mov    (%eax),%eax
80101cbe:	83 ec 0c             	sub    $0xc,%esp
80101cc1:	50                   	push   %eax
80101cc2:	e8 9b f7 ff ff       	call   80101462 <balloc>
80101cc7:	83 c4 10             	add    $0x10,%esp
80101cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd3:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 cf e4 ff ff       	call   801001b6 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 18             	add    $0x18,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 37                	jne    80101d47 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	8b 00                	mov    (%eax),%eax
80101d25:	83 ec 0c             	sub    $0xc,%esp
80101d28:	50                   	push   %eax
80101d29:	e8 34 f7 ff ff       	call   80101462 <balloc>
80101d2e:	83 c4 10             	add    $0x10,%esp
80101d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d37:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d39:	83 ec 0c             	sub    $0xc,%esp
80101d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80101d3f:	e8 0b 1a 00 00       	call   8010374f <log_write>
80101d44:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d47:	83 ec 0c             	sub    $0xc,%esp
80101d4a:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4d:	e8 dc e4 ff ff       	call   8010022e <brelse>
80101d52:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d58:	eb 0d                	jmp    80101d67 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d5a:	83 ec 0c             	sub    $0xc,%esp
80101d5d:	68 d2 93 10 80       	push   $0x801093d2
80101d62:	e8 ff e7 ff ff       	call   80100566 <panic>
}
80101d67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d6a:	c9                   	leave  
80101d6b:	c3                   	ret    

80101d6c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6c:	55                   	push   %ebp
80101d6d:	89 e5                	mov    %esp,%ebp
80101d6f:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d79:	eb 45                	jmp    80101dc0 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d81:	83 c2 04             	add    $0x4,%edx
80101d84:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d88:	85 c0                	test   %eax,%eax
80101d8a:	74 30                	je     80101dbc <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d92:	83 c2 04             	add    $0x4,%edx
80101d95:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d99:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9c:	8b 12                	mov    (%edx),%edx
80101d9e:	83 ec 08             	sub    $0x8,%esp
80101da1:	50                   	push   %eax
80101da2:	52                   	push   %edx
80101da3:	e8 18 f8 ff ff       	call   801015c0 <bfree>
80101da8:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dab:	8b 45 08             	mov    0x8(%ebp),%eax
80101dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db1:	83 c2 04             	add    $0x4,%edx
80101db4:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbb:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc0:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc4:	7e b5                	jle    80101d7b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dcc:	85 c0                	test   %eax,%eax
80101dce:	0f 84 a1 00 00 00    	je     80101e75 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 50 4c             	mov    0x4c(%eax),%edx
80101dda:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddd:	8b 00                	mov    (%eax),%eax
80101ddf:	83 ec 08             	sub    $0x8,%esp
80101de2:	52                   	push   %edx
80101de3:	50                   	push   %eax
80101de4:	e8 cd e3 ff ff       	call   801001b6 <bread>
80101de9:	83 c4 10             	add    $0x10,%esp
80101dec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101def:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df2:	83 c0 18             	add    $0x18,%eax
80101df5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dff:	eb 3c                	jmp    80101e3d <itrunc+0xd1>
      if(a[j])
80101e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e0e:	01 d0                	add    %edx,%eax
80101e10:	8b 00                	mov    (%eax),%eax
80101e12:	85 c0                	test   %eax,%eax
80101e14:	74 23                	je     80101e39 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e23:	01 d0                	add    %edx,%eax
80101e25:	8b 00                	mov    (%eax),%eax
80101e27:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2a:	8b 12                	mov    (%edx),%edx
80101e2c:	83 ec 08             	sub    $0x8,%esp
80101e2f:	50                   	push   %eax
80101e30:	52                   	push   %edx
80101e31:	e8 8a f7 ff ff       	call   801015c0 <bfree>
80101e36:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e39:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e40:	83 f8 7f             	cmp    $0x7f,%eax
80101e43:	76 bc                	jbe    80101e01 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e45:	83 ec 0c             	sub    $0xc,%esp
80101e48:	ff 75 ec             	pushl  -0x14(%ebp)
80101e4b:	e8 de e3 ff ff       	call   8010022e <brelse>
80101e50:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e53:	8b 45 08             	mov    0x8(%ebp),%eax
80101e56:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e59:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5c:	8b 12                	mov    (%edx),%edx
80101e5e:	83 ec 08             	sub    $0x8,%esp
80101e61:	50                   	push   %eax
80101e62:	52                   	push   %edx
80101e63:	e8 58 f7 ff ff       	call   801015c0 <bfree>
80101e68:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	pushl  0x8(%ebp)
80101e85:	e8 10 f9 ff ff       	call   8010179a <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 18             	mov    0x18(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0c 01 00 00       	jmp    8010202b <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	pushl  0xc(%ebp)
80101f38:	ff 75 08             	pushl  0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e6 00 00 00       	jmp    8010202b <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 18             	mov    0x18(%eax),%eax
80101f4b:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f4e:	72 0d                	jb     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5b:	73 0a                	jae    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c4 00 00 00       	jmp    8010202b <readi+0x155>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 18             	mov    0x18(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 18             	mov    0x18(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 8b 00 00 00       	jmp    8010201c <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	pushl  0x8(%ebp)
80101f9e:	e8 aa fc ff ff       	call   80101c4d <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	89 c2                	mov    %eax,%edx
80101fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fab:	8b 00                	mov    (%eax),%eax
80101fad:	83 ec 08             	sub    $0x8,%esp
80101fb0:	52                   	push   %edx
80101fb1:	50                   	push   %eax
80101fb2:	e8 ff e1 ff ff       	call   801001b6 <bread>
80101fb7:	83 c4 10             	add    $0x10,%esp
80101fba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbd:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc0:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc5:	ba 00 02 00 00       	mov    $0x200,%edx
80101fca:	29 c2                	sub    %eax,%edx
80101fcc:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcf:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd2:	39 c2                	cmp    %eax,%edx
80101fd4:	0f 46 c2             	cmovbe %edx,%eax
80101fd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdd:	8d 50 18             	lea    0x18(%eax),%edx
80101fe0:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe3:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe8:	01 d0                	add    %edx,%eax
80101fea:	83 ec 04             	sub    $0x4,%esp
80101fed:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff0:	50                   	push   %eax
80101ff1:	ff 75 0c             	pushl  0xc(%ebp)
80101ff4:	e8 97 3c 00 00       	call   80105c90 <memmove>
80101ff9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffc:	83 ec 0c             	sub    $0xc,%esp
80101fff:	ff 75 f0             	pushl  -0x10(%ebp)
80102002:	e8 27 e2 ff ff       	call   8010022e <brelse>
80102007:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 10             	add    %eax,0x10(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 0c             	add    %eax,0xc(%ebp)
8010201c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102022:	0f 82 69 ff ff ff    	jb     80101f91 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102028:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202b:	c9                   	leave  
8010202c:	c3                   	ret    

8010202d <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202d:	55                   	push   %ebp
8010202e:	89 e5                	mov    %esp,%ebp
80102030:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010203a:	66 83 f8 03          	cmp    $0x3,%ax
8010203e:	75 5c                	jne    8010209c <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102040:	8b 45 08             	mov    0x8(%ebp),%eax
80102043:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102047:	66 85 c0             	test   %ax,%ax
8010204a:	78 20                	js     8010206c <writei+0x3f>
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102053:	66 83 f8 09          	cmp    $0x9,%ax
80102057:	7f 13                	jg     8010206c <writei+0x3f>
80102059:	8b 45 08             	mov    0x8(%ebp),%eax
8010205c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102060:	98                   	cwtl   
80102061:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102068:	85 c0                	test   %eax,%eax
8010206a:	75 0a                	jne    80102076 <writei+0x49>
      return -1;
8010206c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102071:	e9 3d 01 00 00       	jmp    801021b3 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102076:	8b 45 08             	mov    0x8(%ebp),%eax
80102079:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207d:	98                   	cwtl   
8010207e:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102085:	8b 55 14             	mov    0x14(%ebp),%edx
80102088:	83 ec 04             	sub    $0x4,%esp
8010208b:	52                   	push   %edx
8010208c:	ff 75 0c             	pushl  0xc(%ebp)
8010208f:	ff 75 08             	pushl  0x8(%ebp)
80102092:	ff d0                	call   *%eax
80102094:	83 c4 10             	add    $0x10,%esp
80102097:	e9 17 01 00 00       	jmp    801021b3 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010209c:	8b 45 08             	mov    0x8(%ebp),%eax
8010209f:	8b 40 18             	mov    0x18(%eax),%eax
801020a2:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a5:	72 0d                	jb     801020b4 <writei+0x87>
801020a7:	8b 55 10             	mov    0x10(%ebp),%edx
801020aa:	8b 45 14             	mov    0x14(%ebp),%eax
801020ad:	01 d0                	add    %edx,%eax
801020af:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b2:	73 0a                	jae    801020be <writei+0x91>
    return -1;
801020b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b9:	e9 f5 00 00 00       	jmp    801021b3 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020be:	8b 55 10             	mov    0x10(%ebp),%edx
801020c1:	8b 45 14             	mov    0x14(%ebp),%eax
801020c4:	01 d0                	add    %edx,%eax
801020c6:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020cb:	76 0a                	jbe    801020d7 <writei+0xaa>
    return -1;
801020cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d2:	e9 dc 00 00 00       	jmp    801021b3 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020de:	e9 99 00 00 00       	jmp    8010217c <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e3:	8b 45 10             	mov    0x10(%ebp),%eax
801020e6:	c1 e8 09             	shr    $0x9,%eax
801020e9:	83 ec 08             	sub    $0x8,%esp
801020ec:	50                   	push   %eax
801020ed:	ff 75 08             	pushl  0x8(%ebp)
801020f0:	e8 58 fb ff ff       	call   80101c4d <bmap>
801020f5:	83 c4 10             	add    $0x10,%esp
801020f8:	89 c2                	mov    %eax,%edx
801020fa:	8b 45 08             	mov    0x8(%ebp),%eax
801020fd:	8b 00                	mov    (%eax),%eax
801020ff:	83 ec 08             	sub    $0x8,%esp
80102102:	52                   	push   %edx
80102103:	50                   	push   %eax
80102104:	e8 ad e0 ff ff       	call   801001b6 <bread>
80102109:	83 c4 10             	add    $0x10,%esp
8010210c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210f:	8b 45 10             	mov    0x10(%ebp),%eax
80102112:	25 ff 01 00 00       	and    $0x1ff,%eax
80102117:	ba 00 02 00 00       	mov    $0x200,%edx
8010211c:	29 c2                	sub    %eax,%edx
8010211e:	8b 45 14             	mov    0x14(%ebp),%eax
80102121:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102124:	39 c2                	cmp    %eax,%edx
80102126:	0f 46 c2             	cmovbe %edx,%eax
80102129:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010212c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212f:	8d 50 18             	lea    0x18(%eax),%edx
80102132:	8b 45 10             	mov    0x10(%ebp),%eax
80102135:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213a:	01 d0                	add    %edx,%eax
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	ff 75 ec             	pushl  -0x14(%ebp)
80102142:	ff 75 0c             	pushl  0xc(%ebp)
80102145:	50                   	push   %eax
80102146:	e8 45 3b 00 00       	call   80105c90 <memmove>
8010214b:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214e:	83 ec 0c             	sub    $0xc,%esp
80102151:	ff 75 f0             	pushl  -0x10(%ebp)
80102154:	e8 f6 15 00 00       	call   8010374f <log_write>
80102159:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010215c:	83 ec 0c             	sub    $0xc,%esp
8010215f:	ff 75 f0             	pushl  -0x10(%ebp)
80102162:	e8 c7 e0 ff ff       	call   8010022e <brelse>
80102167:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102170:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102173:	01 45 10             	add    %eax,0x10(%ebp)
80102176:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102179:	01 45 0c             	add    %eax,0xc(%ebp)
8010217c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102182:	0f 82 5b ff ff ff    	jb     801020e3 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102188:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218c:	74 22                	je     801021b0 <writei+0x183>
8010218e:	8b 45 08             	mov    0x8(%ebp),%eax
80102191:	8b 40 18             	mov    0x18(%eax),%eax
80102194:	3b 45 10             	cmp    0x10(%ebp),%eax
80102197:	73 17                	jae    801021b0 <writei+0x183>
    ip->size = off;
80102199:	8b 45 08             	mov    0x8(%ebp),%eax
8010219c:	8b 55 10             	mov    0x10(%ebp),%edx
8010219f:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021a2:	83 ec 0c             	sub    $0xc,%esp
801021a5:	ff 75 08             	pushl  0x8(%ebp)
801021a8:	e8 ed f5 ff ff       	call   8010179a <iupdate>
801021ad:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b3:	c9                   	leave  
801021b4:	c3                   	ret    

801021b5 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b5:	55                   	push   %ebp
801021b6:	89 e5                	mov    %esp,%ebp
801021b8:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bb:	83 ec 04             	sub    $0x4,%esp
801021be:	6a 0e                	push   $0xe
801021c0:	ff 75 0c             	pushl  0xc(%ebp)
801021c3:	ff 75 08             	pushl  0x8(%ebp)
801021c6:	e8 5b 3b 00 00       	call   80105d26 <strncmp>
801021cb:	83 c4 10             	add    $0x10,%esp
}
801021ce:	c9                   	leave  
801021cf:	c3                   	ret    

801021d0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d0:	55                   	push   %ebp
801021d1:	89 e5                	mov    %esp,%ebp
801021d3:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021dd:	66 83 f8 01          	cmp    $0x1,%ax
801021e1:	74 0d                	je     801021f0 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e3:	83 ec 0c             	sub    $0xc,%esp
801021e6:	68 e5 93 10 80       	push   $0x801093e5
801021eb:	e8 76 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f7:	eb 7b                	jmp    80102274 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f9:	6a 10                	push   $0x10
801021fb:	ff 75 f4             	pushl  -0xc(%ebp)
801021fe:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102201:	50                   	push   %eax
80102202:	ff 75 08             	pushl  0x8(%ebp)
80102205:	e8 cc fc ff ff       	call   80101ed6 <readi>
8010220a:	83 c4 10             	add    $0x10,%esp
8010220d:	83 f8 10             	cmp    $0x10,%eax
80102210:	74 0d                	je     8010221f <dirlookup+0x4f>
      panic("dirlink read");
80102212:	83 ec 0c             	sub    $0xc,%esp
80102215:	68 f7 93 10 80       	push   $0x801093f7
8010221a:	e8 47 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010221f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102223:	66 85 c0             	test   %ax,%ax
80102226:	74 47                	je     8010226f <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102228:	83 ec 08             	sub    $0x8,%esp
8010222b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222e:	83 c0 02             	add    $0x2,%eax
80102231:	50                   	push   %eax
80102232:	ff 75 0c             	pushl  0xc(%ebp)
80102235:	e8 7b ff ff ff       	call   801021b5 <namecmp>
8010223a:	83 c4 10             	add    $0x10,%esp
8010223d:	85 c0                	test   %eax,%eax
8010223f:	75 2f                	jne    80102270 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102241:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102245:	74 08                	je     8010224f <dirlookup+0x7f>
        *poff = off;
80102247:	8b 45 10             	mov    0x10(%ebp),%eax
8010224a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102253:	0f b7 c0             	movzwl %ax,%eax
80102256:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102259:	8b 45 08             	mov    0x8(%ebp),%eax
8010225c:	8b 00                	mov    (%eax),%eax
8010225e:	83 ec 08             	sub    $0x8,%esp
80102261:	ff 75 f0             	pushl  -0x10(%ebp)
80102264:	50                   	push   %eax
80102265:	e8 eb f5 ff ff       	call   80101855 <iget>
8010226a:	83 c4 10             	add    $0x10,%esp
8010226d:	eb 19                	jmp    80102288 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010226f:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102270:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102274:	8b 45 08             	mov    0x8(%ebp),%eax
80102277:	8b 40 18             	mov    0x18(%eax),%eax
8010227a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010227d:	0f 87 76 ff ff ff    	ja     801021f9 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102283:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102288:	c9                   	leave  
80102289:	c3                   	ret    

8010228a <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102290:	83 ec 04             	sub    $0x4,%esp
80102293:	6a 00                	push   $0x0
80102295:	ff 75 0c             	pushl  0xc(%ebp)
80102298:	ff 75 08             	pushl  0x8(%ebp)
8010229b:	e8 30 ff ff ff       	call   801021d0 <dirlookup>
801022a0:	83 c4 10             	add    $0x10,%esp
801022a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022aa:	74 18                	je     801022c4 <dirlink+0x3a>
    iput(ip);
801022ac:	83 ec 0c             	sub    $0xc,%esp
801022af:	ff 75 f0             	pushl  -0x10(%ebp)
801022b2:	e8 81 f8 ff ff       	call   80101b38 <iput>
801022b7:	83 c4 10             	add    $0x10,%esp
    return -1;
801022ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bf:	e9 9c 00 00 00       	jmp    80102360 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cb:	eb 39                	jmp    80102306 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d0:	6a 10                	push   $0x10
801022d2:	50                   	push   %eax
801022d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d6:	50                   	push   %eax
801022d7:	ff 75 08             	pushl  0x8(%ebp)
801022da:	e8 f7 fb ff ff       	call   80101ed6 <readi>
801022df:	83 c4 10             	add    $0x10,%esp
801022e2:	83 f8 10             	cmp    $0x10,%eax
801022e5:	74 0d                	je     801022f4 <dirlink+0x6a>
      panic("dirlink read");
801022e7:	83 ec 0c             	sub    $0xc,%esp
801022ea:	68 f7 93 10 80       	push   $0x801093f7
801022ef:	e8 72 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022f4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f8:	66 85 c0             	test   %ax,%ax
801022fb:	74 18                	je     80102315 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102300:	83 c0 10             	add    $0x10,%eax
80102303:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102306:	8b 45 08             	mov    0x8(%ebp),%eax
80102309:	8b 50 18             	mov    0x18(%eax),%edx
8010230c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230f:	39 c2                	cmp    %eax,%edx
80102311:	77 ba                	ja     801022cd <dirlink+0x43>
80102313:	eb 01                	jmp    80102316 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102315:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102316:	83 ec 04             	sub    $0x4,%esp
80102319:	6a 0e                	push   $0xe
8010231b:	ff 75 0c             	pushl  0xc(%ebp)
8010231e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102321:	83 c0 02             	add    $0x2,%eax
80102324:	50                   	push   %eax
80102325:	e8 52 3a 00 00       	call   80105d7c <strncpy>
8010232a:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232d:	8b 45 10             	mov    0x10(%ebp),%eax
80102330:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102337:	6a 10                	push   $0x10
80102339:	50                   	push   %eax
8010233a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233d:	50                   	push   %eax
8010233e:	ff 75 08             	pushl  0x8(%ebp)
80102341:	e8 e7 fc ff ff       	call   8010202d <writei>
80102346:	83 c4 10             	add    $0x10,%esp
80102349:	83 f8 10             	cmp    $0x10,%eax
8010234c:	74 0d                	je     8010235b <dirlink+0xd1>
    panic("dirlink");
8010234e:	83 ec 0c             	sub    $0xc,%esp
80102351:	68 04 94 10 80       	push   $0x80109404
80102356:	e8 0b e2 ff ff       	call   80100566 <panic>

  return 0;
8010235b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102360:	c9                   	leave  
80102361:	c3                   	ret    

80102362 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102362:	55                   	push   %ebp
80102363:	89 e5                	mov    %esp,%ebp
80102365:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102368:	eb 04                	jmp    8010236e <skipelem+0xc>
    path++;
8010236a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010236e:	8b 45 08             	mov    0x8(%ebp),%eax
80102371:	0f b6 00             	movzbl (%eax),%eax
80102374:	3c 2f                	cmp    $0x2f,%al
80102376:	74 f2                	je     8010236a <skipelem+0x8>
    path++;
  if(*path == 0)
80102378:	8b 45 08             	mov    0x8(%ebp),%eax
8010237b:	0f b6 00             	movzbl (%eax),%eax
8010237e:	84 c0                	test   %al,%al
80102380:	75 07                	jne    80102389 <skipelem+0x27>
    return 0;
80102382:	b8 00 00 00 00       	mov    $0x0,%eax
80102387:	eb 7b                	jmp    80102404 <skipelem+0xa2>
  s = path;
80102389:	8b 45 08             	mov    0x8(%ebp),%eax
8010238c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238f:	eb 04                	jmp    80102395 <skipelem+0x33>
    path++;
80102391:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102395:	8b 45 08             	mov    0x8(%ebp),%eax
80102398:	0f b6 00             	movzbl (%eax),%eax
8010239b:	3c 2f                	cmp    $0x2f,%al
8010239d:	74 0a                	je     801023a9 <skipelem+0x47>
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	0f b6 00             	movzbl (%eax),%eax
801023a5:	84 c0                	test   %al,%al
801023a7:	75 e8                	jne    80102391 <skipelem+0x2f>
    path++;
  len = path - s;
801023a9:	8b 55 08             	mov    0x8(%ebp),%edx
801023ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023af:	29 c2                	sub    %eax,%edx
801023b1:	89 d0                	mov    %edx,%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	pushl  -0xc(%ebp)
801023c4:	ff 75 0c             	pushl  0xc(%ebp)
801023c7:	e8 c4 38 00 00       	call   80105c90 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	pushl  -0xc(%ebp)
801023db:	ff 75 0c             	pushl  0xc(%ebp)
801023de:	e8 ad 38 00 00       	call   80105c90 <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x95>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x91>
    path++;
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 33 f4 ff ff       	call   80101855 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 bb 00 00 00       	jmp    801024e8 <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010242d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102433:	8b 40 68             	mov    0x68(%eax),%eax
80102436:	83 ec 0c             	sub    $0xc,%esp
80102439:	50                   	push   %eax
8010243a:	e8 f5 f4 ff ff       	call   80101934 <idup>
8010243f:	83 c4 10             	add    $0x10,%esp
80102442:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102445:	e9 9e 00 00 00       	jmp    801024e8 <namex+0xe2>
    ilock(ip);
8010244a:	83 ec 0c             	sub    $0xc,%esp
8010244d:	ff 75 f4             	pushl  -0xc(%ebp)
80102450:	e8 19 f5 ff ff       	call   8010196e <ilock>
80102455:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010245f:	66 83 f8 01          	cmp    $0x1,%ax
80102463:	74 18                	je     8010247d <namex+0x77>
      iunlockput(ip);
80102465:	83 ec 0c             	sub    $0xc,%esp
80102468:	ff 75 f4             	pushl  -0xc(%ebp)
8010246b:	e8 b8 f7 ff ff       	call   80101c28 <iunlockput>
80102470:	83 c4 10             	add    $0x10,%esp
      return 0;
80102473:	b8 00 00 00 00       	mov    $0x0,%eax
80102478:	e9 a7 00 00 00       	jmp    80102524 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010247d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102481:	74 20                	je     801024a3 <namex+0x9d>
80102483:	8b 45 08             	mov    0x8(%ebp),%eax
80102486:	0f b6 00             	movzbl (%eax),%eax
80102489:	84 c0                	test   %al,%al
8010248b:	75 16                	jne    801024a3 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010248d:	83 ec 0c             	sub    $0xc,%esp
80102490:	ff 75 f4             	pushl  -0xc(%ebp)
80102493:	e8 2e f6 ff ff       	call   80101ac6 <iunlock>
80102498:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249e:	e9 81 00 00 00       	jmp    80102524 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a3:	83 ec 04             	sub    $0x4,%esp
801024a6:	6a 00                	push   $0x0
801024a8:	ff 75 10             	pushl  0x10(%ebp)
801024ab:	ff 75 f4             	pushl  -0xc(%ebp)
801024ae:	e8 1d fd ff ff       	call   801021d0 <dirlookup>
801024b3:	83 c4 10             	add    $0x10,%esp
801024b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bd:	75 15                	jne    801024d4 <namex+0xce>
      iunlockput(ip);
801024bf:	83 ec 0c             	sub    $0xc,%esp
801024c2:	ff 75 f4             	pushl  -0xc(%ebp)
801024c5:	e8 5e f7 ff ff       	call   80101c28 <iunlockput>
801024ca:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cd:	b8 00 00 00 00       	mov    $0x0,%eax
801024d2:	eb 50                	jmp    80102524 <namex+0x11e>
    }
    iunlockput(ip);
801024d4:	83 ec 0c             	sub    $0xc,%esp
801024d7:	ff 75 f4             	pushl  -0xc(%ebp)
801024da:	e8 49 f7 ff ff       	call   80101c28 <iunlockput>
801024df:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024e8:	83 ec 08             	sub    $0x8,%esp
801024eb:	ff 75 10             	pushl  0x10(%ebp)
801024ee:	ff 75 08             	pushl  0x8(%ebp)
801024f1:	e8 6c fe ff ff       	call   80102362 <skipelem>
801024f6:	83 c4 10             	add    $0x10,%esp
801024f9:	89 45 08             	mov    %eax,0x8(%ebp)
801024fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102500:	0f 85 44 ff ff ff    	jne    8010244a <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102506:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250a:	74 15                	je     80102521 <namex+0x11b>
    iput(ip);
8010250c:	83 ec 0c             	sub    $0xc,%esp
8010250f:	ff 75 f4             	pushl  -0xc(%ebp)
80102512:	e8 21 f6 ff ff       	call   80101b38 <iput>
80102517:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251a:	b8 00 00 00 00       	mov    $0x0,%eax
8010251f:	eb 03                	jmp    80102524 <namex+0x11e>
  }
  return ip;
80102521:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102524:	c9                   	leave  
80102525:	c3                   	ret    

80102526 <namei>:

struct inode*
namei(char *path)
{
80102526:	55                   	push   %ebp
80102527:	89 e5                	mov    %esp,%ebp
80102529:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252c:	83 ec 04             	sub    $0x4,%esp
8010252f:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102532:	50                   	push   %eax
80102533:	6a 00                	push   $0x0
80102535:	ff 75 08             	pushl  0x8(%ebp)
80102538:	e8 c9 fe ff ff       	call   80102406 <namex>
8010253d:	83 c4 10             	add    $0x10,%esp
}
80102540:	c9                   	leave  
80102541:	c3                   	ret    

80102542 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102542:	55                   	push   %ebp
80102543:	89 e5                	mov    %esp,%ebp
80102545:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102548:	83 ec 04             	sub    $0x4,%esp
8010254b:	ff 75 0c             	pushl  0xc(%ebp)
8010254e:	6a 01                	push   $0x1
80102550:	ff 75 08             	pushl  0x8(%ebp)
80102553:	e8 ae fe ff ff       	call   80102406 <namex>
80102558:	83 c4 10             	add    $0x10,%esp
}
8010255b:	c9                   	leave  
8010255c:	c3                   	ret    

8010255d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010255d:	55                   	push   %ebp
8010255e:	89 e5                	mov    %esp,%ebp
80102560:	83 ec 14             	sub    $0x14,%esp
80102563:	8b 45 08             	mov    0x8(%ebp),%eax
80102566:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010256e:	89 c2                	mov    %eax,%edx
80102570:	ec                   	in     (%dx),%al
80102571:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102574:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102578:	c9                   	leave  
80102579:	c3                   	ret    

8010257a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010257a:	55                   	push   %ebp
8010257b:	89 e5                	mov    %esp,%ebp
8010257d:	57                   	push   %edi
8010257e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010257f:	8b 55 08             	mov    0x8(%ebp),%edx
80102582:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102585:	8b 45 10             	mov    0x10(%ebp),%eax
80102588:	89 cb                	mov    %ecx,%ebx
8010258a:	89 df                	mov    %ebx,%edi
8010258c:	89 c1                	mov    %eax,%ecx
8010258e:	fc                   	cld    
8010258f:	f3 6d                	rep insl (%dx),%es:(%edi)
80102591:	89 c8                	mov    %ecx,%eax
80102593:	89 fb                	mov    %edi,%ebx
80102595:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102598:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010259b:	90                   	nop
8010259c:	5b                   	pop    %ebx
8010259d:	5f                   	pop    %edi
8010259e:	5d                   	pop    %ebp
8010259f:	c3                   	ret    

801025a0 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a0:	55                   	push   %ebp
801025a1:	89 e5                	mov    %esp,%ebp
801025a3:	83 ec 08             	sub    $0x8,%esp
801025a6:	8b 55 08             	mov    0x8(%ebp),%edx
801025a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ac:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025bb:	ee                   	out    %al,(%dx)
}
801025bc:	90                   	nop
801025bd:	c9                   	leave  
801025be:	c3                   	ret    

801025bf <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025bf:	55                   	push   %ebp
801025c0:	89 e5                	mov    %esp,%ebp
801025c2:	56                   	push   %esi
801025c3:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c4:	8b 55 08             	mov    0x8(%ebp),%edx
801025c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025ca:	8b 45 10             	mov    0x10(%ebp),%eax
801025cd:	89 cb                	mov    %ecx,%ebx
801025cf:	89 de                	mov    %ebx,%esi
801025d1:	89 c1                	mov    %eax,%ecx
801025d3:	fc                   	cld    
801025d4:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d6:	89 c8                	mov    %ecx,%eax
801025d8:	89 f3                	mov    %esi,%ebx
801025da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025dd:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e0:	90                   	nop
801025e1:	5b                   	pop    %ebx
801025e2:	5e                   	pop    %esi
801025e3:	5d                   	pop    %ebp
801025e4:	c3                   	ret    

801025e5 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e5:	55                   	push   %ebp
801025e6:	89 e5                	mov    %esp,%ebp
801025e8:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025eb:	90                   	nop
801025ec:	68 f7 01 00 00       	push   $0x1f7
801025f1:	e8 67 ff ff ff       	call   8010255d <inb>
801025f6:	83 c4 04             	add    $0x4,%esp
801025f9:	0f b6 c0             	movzbl %al,%eax
801025fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102602:	25 c0 00 00 00       	and    $0xc0,%eax
80102607:	83 f8 40             	cmp    $0x40,%eax
8010260a:	75 e0                	jne    801025ec <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102610:	74 11                	je     80102623 <idewait+0x3e>
80102612:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102615:	83 e0 21             	and    $0x21,%eax
80102618:	85 c0                	test   %eax,%eax
8010261a:	74 07                	je     80102623 <idewait+0x3e>
    return -1;
8010261c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102621:	eb 05                	jmp    80102628 <idewait+0x43>
  return 0;
80102623:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102628:	c9                   	leave  
80102629:	c3                   	ret    

8010262a <ideinit>:

void
ideinit(void)
{
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
8010262d:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102630:	83 ec 08             	sub    $0x8,%esp
80102633:	68 0c 94 10 80       	push   $0x8010940c
80102638:	68 20 c6 10 80       	push   $0x8010c620
8010263d:	e8 0a 33 00 00       	call   8010594c <initlock>
80102642:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102645:	83 ec 0c             	sub    $0xc,%esp
80102648:	6a 0e                	push   $0xe
8010264a:	e8 ec 19 00 00       	call   8010403b <picenable>
8010264f:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102652:	a1 60 39 11 80       	mov    0x80113960,%eax
80102657:	83 e8 01             	sub    $0x1,%eax
8010265a:	83 ec 08             	sub    $0x8,%esp
8010265d:	50                   	push   %eax
8010265e:	6a 0e                	push   $0xe
80102660:	e8 37 04 00 00       	call   80102a9c <ioapicenable>
80102665:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102668:	83 ec 0c             	sub    $0xc,%esp
8010266b:	6a 00                	push   $0x0
8010266d:	e8 73 ff ff ff       	call   801025e5 <idewait>
80102672:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102675:	83 ec 08             	sub    $0x8,%esp
80102678:	68 f0 00 00 00       	push   $0xf0
8010267d:	68 f6 01 00 00       	push   $0x1f6
80102682:	e8 19 ff ff ff       	call   801025a0 <outb>
80102687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010268a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102691:	eb 24                	jmp    801026b7 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102693:	83 ec 0c             	sub    $0xc,%esp
80102696:	68 f7 01 00 00       	push   $0x1f7
8010269b:	e8 bd fe ff ff       	call   8010255d <inb>
801026a0:	83 c4 10             	add    $0x10,%esp
801026a3:	84 c0                	test   %al,%al
801026a5:	74 0c                	je     801026b3 <ideinit+0x89>
      havedisk1 = 1;
801026a7:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
801026ae:	00 00 00 
      break;
801026b1:	eb 0d                	jmp    801026c0 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b7:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026be:	7e d3                	jle    80102693 <ideinit+0x69>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026c0:	83 ec 08             	sub    $0x8,%esp
801026c3:	68 e0 00 00 00       	push   $0xe0
801026c8:	68 f6 01 00 00       	push   $0x1f6
801026cd:	e8 ce fe ff ff       	call   801025a0 <outb>
801026d2:	83 c4 10             	add    $0x10,%esp
}
801026d5:	90                   	nop
801026d6:	c9                   	leave  
801026d7:	c3                   	ret    

801026d8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026d8:	55                   	push   %ebp
801026d9:	89 e5                	mov    %esp,%ebp
801026db:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
801026de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e2:	75 0d                	jne    801026f1 <idestart+0x19>
    panic("idestart");
801026e4:	83 ec 0c             	sub    $0xc,%esp
801026e7:	68 10 94 10 80       	push   $0x80109410
801026ec:	e8 75 de ff ff       	call   80100566 <panic>

  idewait(0);
801026f1:	83 ec 0c             	sub    $0xc,%esp
801026f4:	6a 00                	push   $0x0
801026f6:	e8 ea fe ff ff       	call   801025e5 <idewait>
801026fb:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801026fe:	83 ec 08             	sub    $0x8,%esp
80102701:	6a 00                	push   $0x0
80102703:	68 f6 03 00 00       	push   $0x3f6
80102708:	e8 93 fe ff ff       	call   801025a0 <outb>
8010270d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
80102710:	83 ec 08             	sub    $0x8,%esp
80102713:	6a 01                	push   $0x1
80102715:	68 f2 01 00 00       	push   $0x1f2
8010271a:	e8 81 fe ff ff       	call   801025a0 <outb>
8010271f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
80102722:	8b 45 08             	mov    0x8(%ebp),%eax
80102725:	8b 40 08             	mov    0x8(%eax),%eax
80102728:	0f b6 c0             	movzbl %al,%eax
8010272b:	83 ec 08             	sub    $0x8,%esp
8010272e:	50                   	push   %eax
8010272f:	68 f3 01 00 00       	push   $0x1f3
80102734:	e8 67 fe ff ff       	call   801025a0 <outb>
80102739:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010273c:	8b 45 08             	mov    0x8(%ebp),%eax
8010273f:	8b 40 08             	mov    0x8(%eax),%eax
80102742:	c1 e8 08             	shr    $0x8,%eax
80102745:	0f b6 c0             	movzbl %al,%eax
80102748:	83 ec 08             	sub    $0x8,%esp
8010274b:	50                   	push   %eax
8010274c:	68 f4 01 00 00       	push   $0x1f4
80102751:	e8 4a fe ff ff       	call   801025a0 <outb>
80102756:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102759:	8b 45 08             	mov    0x8(%ebp),%eax
8010275c:	8b 40 08             	mov    0x8(%eax),%eax
8010275f:	c1 e8 10             	shr    $0x10,%eax
80102762:	0f b6 c0             	movzbl %al,%eax
80102765:	83 ec 08             	sub    $0x8,%esp
80102768:	50                   	push   %eax
80102769:	68 f5 01 00 00       	push   $0x1f5
8010276e:	e8 2d fe ff ff       	call   801025a0 <outb>
80102773:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102776:	8b 45 08             	mov    0x8(%ebp),%eax
80102779:	8b 40 04             	mov    0x4(%eax),%eax
8010277c:	83 e0 01             	and    $0x1,%eax
8010277f:	c1 e0 04             	shl    $0x4,%eax
80102782:	89 c2                	mov    %eax,%edx
80102784:	8b 45 08             	mov    0x8(%ebp),%eax
80102787:	8b 40 08             	mov    0x8(%eax),%eax
8010278a:	c1 e8 18             	shr    $0x18,%eax
8010278d:	83 e0 0f             	and    $0xf,%eax
80102790:	09 d0                	or     %edx,%eax
80102792:	83 c8 e0             	or     $0xffffffe0,%eax
80102795:	0f b6 c0             	movzbl %al,%eax
80102798:	83 ec 08             	sub    $0x8,%esp
8010279b:	50                   	push   %eax
8010279c:	68 f6 01 00 00       	push   $0x1f6
801027a1:	e8 fa fd ff ff       	call   801025a0 <outb>
801027a6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027a9:	8b 45 08             	mov    0x8(%ebp),%eax
801027ac:	8b 00                	mov    (%eax),%eax
801027ae:	83 e0 04             	and    $0x4,%eax
801027b1:	85 c0                	test   %eax,%eax
801027b3:	74 30                	je     801027e5 <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
801027b5:	83 ec 08             	sub    $0x8,%esp
801027b8:	6a 30                	push   $0x30
801027ba:	68 f7 01 00 00       	push   $0x1f7
801027bf:	e8 dc fd ff ff       	call   801025a0 <outb>
801027c4:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
801027c7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ca:	83 c0 18             	add    $0x18,%eax
801027cd:	83 ec 04             	sub    $0x4,%esp
801027d0:	68 80 00 00 00       	push   $0x80
801027d5:	50                   	push   %eax
801027d6:	68 f0 01 00 00       	push   $0x1f0
801027db:	e8 df fd ff ff       	call   801025bf <outsl>
801027e0:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801027e3:	eb 12                	jmp    801027f7 <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801027e5:	83 ec 08             	sub    $0x8,%esp
801027e8:	6a 20                	push   $0x20
801027ea:	68 f7 01 00 00       	push   $0x1f7
801027ef:	e8 ac fd ff ff       	call   801025a0 <outb>
801027f4:	83 c4 10             	add    $0x10,%esp
  }
}
801027f7:	90                   	nop
801027f8:	c9                   	leave  
801027f9:	c3                   	ret    

801027fa <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027fa:	55                   	push   %ebp
801027fb:	89 e5                	mov    %esp,%ebp
801027fd:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102800:	83 ec 0c             	sub    $0xc,%esp
80102803:	68 20 c6 10 80       	push   $0x8010c620
80102808:	e8 61 31 00 00       	call   8010596e <acquire>
8010280d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102810:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102815:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102818:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010281c:	75 15                	jne    80102833 <ideintr+0x39>
    release(&idelock);
8010281e:	83 ec 0c             	sub    $0xc,%esp
80102821:	68 20 c6 10 80       	push   $0x8010c620
80102826:	e8 aa 31 00 00       	call   801059d5 <release>
8010282b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010282e:	e9 9a 00 00 00       	jmp    801028cd <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102836:	8b 40 14             	mov    0x14(%eax),%eax
80102839:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010283e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102841:	8b 00                	mov    (%eax),%eax
80102843:	83 e0 04             	and    $0x4,%eax
80102846:	85 c0                	test   %eax,%eax
80102848:	75 2d                	jne    80102877 <ideintr+0x7d>
8010284a:	83 ec 0c             	sub    $0xc,%esp
8010284d:	6a 01                	push   $0x1
8010284f:	e8 91 fd ff ff       	call   801025e5 <idewait>
80102854:	83 c4 10             	add    $0x10,%esp
80102857:	85 c0                	test   %eax,%eax
80102859:	78 1c                	js     80102877 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
8010285b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285e:	83 c0 18             	add    $0x18,%eax
80102861:	83 ec 04             	sub    $0x4,%esp
80102864:	68 80 00 00 00       	push   $0x80
80102869:	50                   	push   %eax
8010286a:	68 f0 01 00 00       	push   $0x1f0
8010286f:	e8 06 fd ff ff       	call   8010257a <insl>
80102874:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287a:	8b 00                	mov    (%eax),%eax
8010287c:	83 c8 02             	or     $0x2,%eax
8010287f:	89 c2                	mov    %eax,%edx
80102881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102884:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102889:	8b 00                	mov    (%eax),%eax
8010288b:	83 e0 fb             	and    $0xfffffffb,%eax
8010288e:	89 c2                	mov    %eax,%edx
80102890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102893:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102895:	83 ec 0c             	sub    $0xc,%esp
80102898:	ff 75 f4             	pushl  -0xc(%ebp)
8010289b:	e8 1e 2a 00 00       	call   801052be <wakeup>
801028a0:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028a3:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028a8:	85 c0                	test   %eax,%eax
801028aa:	74 11                	je     801028bd <ideintr+0xc3>
    idestart(idequeue);
801028ac:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028b1:	83 ec 0c             	sub    $0xc,%esp
801028b4:	50                   	push   %eax
801028b5:	e8 1e fe ff ff       	call   801026d8 <idestart>
801028ba:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028bd:	83 ec 0c             	sub    $0xc,%esp
801028c0:	68 20 c6 10 80       	push   $0x8010c620
801028c5:	e8 0b 31 00 00       	call   801059d5 <release>
801028ca:	83 c4 10             	add    $0x10,%esp
}
801028cd:	c9                   	leave  
801028ce:	c3                   	ret    

801028cf <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028cf:	55                   	push   %ebp
801028d0:	89 e5                	mov    %esp,%ebp
801028d2:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801028d5:	8b 45 08             	mov    0x8(%ebp),%eax
801028d8:	8b 00                	mov    (%eax),%eax
801028da:	83 e0 01             	and    $0x1,%eax
801028dd:	85 c0                	test   %eax,%eax
801028df:	75 0d                	jne    801028ee <iderw+0x1f>
    panic("iderw: buf not busy");
801028e1:	83 ec 0c             	sub    $0xc,%esp
801028e4:	68 19 94 10 80       	push   $0x80109419
801028e9:	e8 78 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028ee:	8b 45 08             	mov    0x8(%ebp),%eax
801028f1:	8b 00                	mov    (%eax),%eax
801028f3:	83 e0 06             	and    $0x6,%eax
801028f6:	83 f8 02             	cmp    $0x2,%eax
801028f9:	75 0d                	jne    80102908 <iderw+0x39>
    panic("iderw: nothing to do");
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 2d 94 10 80       	push   $0x8010942d
80102903:	e8 5e dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102908:	8b 45 08             	mov    0x8(%ebp),%eax
8010290b:	8b 40 04             	mov    0x4(%eax),%eax
8010290e:	85 c0                	test   %eax,%eax
80102910:	74 16                	je     80102928 <iderw+0x59>
80102912:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80102917:	85 c0                	test   %eax,%eax
80102919:	75 0d                	jne    80102928 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010291b:	83 ec 0c             	sub    $0xc,%esp
8010291e:	68 42 94 10 80       	push   $0x80109442
80102923:	e8 3e dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102928:	83 ec 0c             	sub    $0xc,%esp
8010292b:	68 20 c6 10 80       	push   $0x8010c620
80102930:	e8 39 30 00 00       	call   8010596e <acquire>
80102935:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102938:	8b 45 08             	mov    0x8(%ebp),%eax
8010293b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102942:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102949:	eb 0b                	jmp    80102956 <iderw+0x87>
8010294b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294e:	8b 00                	mov    (%eax),%eax
80102950:	83 c0 14             	add    $0x14,%eax
80102953:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102959:	8b 00                	mov    (%eax),%eax
8010295b:	85 c0                	test   %eax,%eax
8010295d:	75 ec                	jne    8010294b <iderw+0x7c>
    ;
  *pp = b;
8010295f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102962:	8b 55 08             	mov    0x8(%ebp),%edx
80102965:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102967:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010296c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010296f:	75 23                	jne    80102994 <iderw+0xc5>
    idestart(b);
80102971:	83 ec 0c             	sub    $0xc,%esp
80102974:	ff 75 08             	pushl  0x8(%ebp)
80102977:	e8 5c fd ff ff       	call   801026d8 <idestart>
8010297c:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010297f:	eb 13                	jmp    80102994 <iderw+0xc5>
    sleep(b, &idelock);
80102981:	83 ec 08             	sub    $0x8,%esp
80102984:	68 20 c6 10 80       	push   $0x8010c620
80102989:	ff 75 08             	pushl  0x8(%ebp)
8010298c:	e8 21 28 00 00       	call   801051b2 <sleep>
80102991:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102994:	8b 45 08             	mov    0x8(%ebp),%eax
80102997:	8b 00                	mov    (%eax),%eax
80102999:	83 e0 06             	and    $0x6,%eax
8010299c:	83 f8 02             	cmp    $0x2,%eax
8010299f:	75 e0                	jne    80102981 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029a1:	83 ec 0c             	sub    $0xc,%esp
801029a4:	68 20 c6 10 80       	push   $0x8010c620
801029a9:	e8 27 30 00 00       	call   801059d5 <release>
801029ae:	83 c4 10             	add    $0x10,%esp
}
801029b1:	90                   	nop
801029b2:	c9                   	leave  
801029b3:	c3                   	ret    

801029b4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029b7:	a1 34 32 11 80       	mov    0x80113234,%eax
801029bc:	8b 55 08             	mov    0x8(%ebp),%edx
801029bf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029c1:	a1 34 32 11 80       	mov    0x80113234,%eax
801029c6:	8b 40 10             	mov    0x10(%eax),%eax
}
801029c9:	5d                   	pop    %ebp
801029ca:	c3                   	ret    

801029cb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029cb:	55                   	push   %ebp
801029cc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029ce:	a1 34 32 11 80       	mov    0x80113234,%eax
801029d3:	8b 55 08             	mov    0x8(%ebp),%edx
801029d6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029d8:	a1 34 32 11 80       	mov    0x80113234,%eax
801029dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801029e0:	89 50 10             	mov    %edx,0x10(%eax)
}
801029e3:	90                   	nop
801029e4:	5d                   	pop    %ebp
801029e5:	c3                   	ret    

801029e6 <ioapicinit>:

void
ioapicinit(void)
{
801029e6:	55                   	push   %ebp
801029e7:	89 e5                	mov    %esp,%ebp
801029e9:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
801029ec:	a1 64 33 11 80       	mov    0x80113364,%eax
801029f1:	85 c0                	test   %eax,%eax
801029f3:	0f 84 a0 00 00 00    	je     80102a99 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801029f9:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102a00:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a03:	6a 01                	push   $0x1
80102a05:	e8 aa ff ff ff       	call   801029b4 <ioapicread>
80102a0a:	83 c4 04             	add    $0x4,%esp
80102a0d:	c1 e8 10             	shr    $0x10,%eax
80102a10:	25 ff 00 00 00       	and    $0xff,%eax
80102a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a18:	6a 00                	push   $0x0
80102a1a:	e8 95 ff ff ff       	call   801029b4 <ioapicread>
80102a1f:	83 c4 04             	add    $0x4,%esp
80102a22:	c1 e8 18             	shr    $0x18,%eax
80102a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a28:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102a2f:	0f b6 c0             	movzbl %al,%eax
80102a32:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a35:	74 10                	je     80102a47 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a37:	83 ec 0c             	sub    $0xc,%esp
80102a3a:	68 60 94 10 80       	push   $0x80109460
80102a3f:	e8 82 d9 ff ff       	call   801003c6 <cprintf>
80102a44:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a4e:	eb 3f                	jmp    80102a8f <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a53:	83 c0 20             	add    $0x20,%eax
80102a56:	0d 00 00 01 00       	or     $0x10000,%eax
80102a5b:	89 c2                	mov    %eax,%edx
80102a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a60:	83 c0 08             	add    $0x8,%eax
80102a63:	01 c0                	add    %eax,%eax
80102a65:	83 ec 08             	sub    $0x8,%esp
80102a68:	52                   	push   %edx
80102a69:	50                   	push   %eax
80102a6a:	e8 5c ff ff ff       	call   801029cb <ioapicwrite>
80102a6f:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a75:	83 c0 08             	add    $0x8,%eax
80102a78:	01 c0                	add    %eax,%eax
80102a7a:	83 c0 01             	add    $0x1,%eax
80102a7d:	83 ec 08             	sub    $0x8,%esp
80102a80:	6a 00                	push   $0x0
80102a82:	50                   	push   %eax
80102a83:	e8 43 ff ff ff       	call   801029cb <ioapicwrite>
80102a88:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a8b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a92:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a95:	7e b9                	jle    80102a50 <ioapicinit+0x6a>
80102a97:	eb 01                	jmp    80102a9a <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a99:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a9a:	c9                   	leave  
80102a9b:	c3                   	ret    

80102a9c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a9c:	55                   	push   %ebp
80102a9d:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a9f:	a1 64 33 11 80       	mov    0x80113364,%eax
80102aa4:	85 c0                	test   %eax,%eax
80102aa6:	74 39                	je     80102ae1 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80102aab:	83 c0 20             	add    $0x20,%eax
80102aae:	89 c2                	mov    %eax,%edx
80102ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab3:	83 c0 08             	add    $0x8,%eax
80102ab6:	01 c0                	add    %eax,%eax
80102ab8:	52                   	push   %edx
80102ab9:	50                   	push   %eax
80102aba:	e8 0c ff ff ff       	call   801029cb <ioapicwrite>
80102abf:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ac5:	c1 e0 18             	shl    $0x18,%eax
80102ac8:	89 c2                	mov    %eax,%edx
80102aca:	8b 45 08             	mov    0x8(%ebp),%eax
80102acd:	83 c0 08             	add    $0x8,%eax
80102ad0:	01 c0                	add    %eax,%eax
80102ad2:	83 c0 01             	add    $0x1,%eax
80102ad5:	52                   	push   %edx
80102ad6:	50                   	push   %eax
80102ad7:	e8 ef fe ff ff       	call   801029cb <ioapicwrite>
80102adc:	83 c4 08             	add    $0x8,%esp
80102adf:	eb 01                	jmp    80102ae2 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102ae1:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102ae2:	c9                   	leave  
80102ae3:	c3                   	ret    

80102ae4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102ae4:	55                   	push   %ebp
80102ae5:	89 e5                	mov    %esp,%ebp
80102ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aea:	05 00 00 00 80       	add    $0x80000000,%eax
80102aef:	5d                   	pop    %ebp
80102af0:	c3                   	ret    

80102af1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102af1:	55                   	push   %ebp
80102af2:	89 e5                	mov    %esp,%ebp
80102af4:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102af7:	83 ec 08             	sub    $0x8,%esp
80102afa:	68 92 94 10 80       	push   $0x80109492
80102aff:	68 40 32 11 80       	push   $0x80113240
80102b04:	e8 43 2e 00 00       	call   8010594c <initlock>
80102b09:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b0c:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102b13:	00 00 00 
  freerange(vstart, vend);
80102b16:	83 ec 08             	sub    $0x8,%esp
80102b19:	ff 75 0c             	pushl  0xc(%ebp)
80102b1c:	ff 75 08             	pushl  0x8(%ebp)
80102b1f:	e8 2a 00 00 00       	call   80102b4e <freerange>
80102b24:	83 c4 10             	add    $0x10,%esp
}
80102b27:	90                   	nop
80102b28:	c9                   	leave  
80102b29:	c3                   	ret    

80102b2a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b2a:	55                   	push   %ebp
80102b2b:	89 e5                	mov    %esp,%ebp
80102b2d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b30:	83 ec 08             	sub    $0x8,%esp
80102b33:	ff 75 0c             	pushl  0xc(%ebp)
80102b36:	ff 75 08             	pushl  0x8(%ebp)
80102b39:	e8 10 00 00 00       	call   80102b4e <freerange>
80102b3e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b41:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102b48:	00 00 00 
}
80102b4b:	90                   	nop
80102b4c:	c9                   	leave  
80102b4d:	c3                   	ret    

80102b4e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b4e:	55                   	push   %ebp
80102b4f:	89 e5                	mov    %esp,%ebp
80102b51:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b54:	8b 45 08             	mov    0x8(%ebp),%eax
80102b57:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b64:	eb 15                	jmp    80102b7b <freerange+0x2d>
    kfree(p);
80102b66:	83 ec 0c             	sub    $0xc,%esp
80102b69:	ff 75 f4             	pushl  -0xc(%ebp)
80102b6c:	e8 1a 00 00 00       	call   80102b8b <kfree>
80102b71:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7e:	05 00 10 00 00       	add    $0x1000,%eax
80102b83:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b86:	76 de                	jbe    80102b66 <freerange+0x18>
    kfree(p);
}
80102b88:	90                   	nop
80102b89:	c9                   	leave  
80102b8a:	c3                   	ret    

80102b8b <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b8b:	55                   	push   %ebp
80102b8c:	89 e5                	mov    %esp,%ebp
80102b8e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b91:	8b 45 08             	mov    0x8(%ebp),%eax
80102b94:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b99:	85 c0                	test   %eax,%eax
80102b9b:	75 1b                	jne    80102bb8 <kfree+0x2d>
80102b9d:	81 7d 08 bc 81 11 80 	cmpl   $0x801181bc,0x8(%ebp)
80102ba4:	72 12                	jb     80102bb8 <kfree+0x2d>
80102ba6:	ff 75 08             	pushl  0x8(%ebp)
80102ba9:	e8 36 ff ff ff       	call   80102ae4 <v2p>
80102bae:	83 c4 04             	add    $0x4,%esp
80102bb1:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bb6:	76 0d                	jbe    80102bc5 <kfree+0x3a>
    panic("kfree");
80102bb8:	83 ec 0c             	sub    $0xc,%esp
80102bbb:	68 97 94 10 80       	push   $0x80109497
80102bc0:	e8 a1 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bc5:	83 ec 04             	sub    $0x4,%esp
80102bc8:	68 00 10 00 00       	push   $0x1000
80102bcd:	6a 01                	push   $0x1
80102bcf:	ff 75 08             	pushl  0x8(%ebp)
80102bd2:	e8 fa 2f 00 00       	call   80105bd1 <memset>
80102bd7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102bda:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bdf:	85 c0                	test   %eax,%eax
80102be1:	74 10                	je     80102bf3 <kfree+0x68>
    acquire(&kmem.lock);
80102be3:	83 ec 0c             	sub    $0xc,%esp
80102be6:	68 40 32 11 80       	push   $0x80113240
80102beb:	e8 7e 2d 00 00       	call   8010596e <acquire>
80102bf0:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102bf9:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c02:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c07:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c0c:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c11:	85 c0                	test   %eax,%eax
80102c13:	74 10                	je     80102c25 <kfree+0x9a>
    release(&kmem.lock);
80102c15:	83 ec 0c             	sub    $0xc,%esp
80102c18:	68 40 32 11 80       	push   $0x80113240
80102c1d:	e8 b3 2d 00 00       	call   801059d5 <release>
80102c22:	83 c4 10             	add    $0x10,%esp
}
80102c25:	90                   	nop
80102c26:	c9                   	leave  
80102c27:	c3                   	ret    

80102c28 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c28:	55                   	push   %ebp
80102c29:	89 e5                	mov    %esp,%ebp
80102c2b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c2e:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c33:	85 c0                	test   %eax,%eax
80102c35:	74 10                	je     80102c47 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c37:	83 ec 0c             	sub    $0xc,%esp
80102c3a:	68 40 32 11 80       	push   $0x80113240
80102c3f:	e8 2a 2d 00 00       	call   8010596e <acquire>
80102c44:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c47:	a1 78 32 11 80       	mov    0x80113278,%eax
80102c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c53:	74 0a                	je     80102c5f <kalloc+0x37>
    kmem.freelist = r->next;
80102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c58:	8b 00                	mov    (%eax),%eax
80102c5a:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c5f:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c64:	85 c0                	test   %eax,%eax
80102c66:	74 10                	je     80102c78 <kalloc+0x50>
    release(&kmem.lock);
80102c68:	83 ec 0c             	sub    $0xc,%esp
80102c6b:	68 40 32 11 80       	push   $0x80113240
80102c70:	e8 60 2d 00 00       	call   801059d5 <release>
80102c75:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c7b:	c9                   	leave  
80102c7c:	c3                   	ret    

80102c7d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c7d:	55                   	push   %ebp
80102c7e:	89 e5                	mov    %esp,%ebp
80102c80:	83 ec 14             	sub    $0x14,%esp
80102c83:	8b 45 08             	mov    0x8(%ebp),%eax
80102c86:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c8a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c8e:	89 c2                	mov    %eax,%edx
80102c90:	ec                   	in     (%dx),%al
80102c91:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c94:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c98:	c9                   	leave  
80102c99:	c3                   	ret    

80102c9a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c9a:	55                   	push   %ebp
80102c9b:	89 e5                	mov    %esp,%ebp
80102c9d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ca0:	6a 64                	push   $0x64
80102ca2:	e8 d6 ff ff ff       	call   80102c7d <inb>
80102ca7:	83 c4 04             	add    $0x4,%esp
80102caa:	0f b6 c0             	movzbl %al,%eax
80102cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb3:	83 e0 01             	and    $0x1,%eax
80102cb6:	85 c0                	test   %eax,%eax
80102cb8:	75 0a                	jne    80102cc4 <kbdgetc+0x2a>
    return -1;
80102cba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cbf:	e9 23 01 00 00       	jmp    80102de7 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102cc4:	6a 60                	push   $0x60
80102cc6:	e8 b2 ff ff ff       	call   80102c7d <inb>
80102ccb:	83 c4 04             	add    $0x4,%esp
80102cce:	0f b6 c0             	movzbl %al,%eax
80102cd1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cd4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102cdb:	75 17                	jne    80102cf4 <kbdgetc+0x5a>
    shift |= E0ESC;
80102cdd:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ce2:	83 c8 40             	or     $0x40,%eax
80102ce5:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102cea:	b8 00 00 00 00       	mov    $0x0,%eax
80102cef:	e9 f3 00 00 00       	jmp    80102de7 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102cf4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf7:	25 80 00 00 00       	and    $0x80,%eax
80102cfc:	85 c0                	test   %eax,%eax
80102cfe:	74 45                	je     80102d45 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d00:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d05:	83 e0 40             	and    $0x40,%eax
80102d08:	85 c0                	test   %eax,%eax
80102d0a:	75 08                	jne    80102d14 <kbdgetc+0x7a>
80102d0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0f:	83 e0 7f             	and    $0x7f,%eax
80102d12:	eb 03                	jmp    80102d17 <kbdgetc+0x7d>
80102d14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d17:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d1d:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d22:	0f b6 00             	movzbl (%eax),%eax
80102d25:	83 c8 40             	or     $0x40,%eax
80102d28:	0f b6 c0             	movzbl %al,%eax
80102d2b:	f7 d0                	not    %eax
80102d2d:	89 c2                	mov    %eax,%edx
80102d2f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d34:	21 d0                	and    %edx,%eax
80102d36:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102d3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102d40:	e9 a2 00 00 00       	jmp    80102de7 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d45:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d4a:	83 e0 40             	and    $0x40,%eax
80102d4d:	85 c0                	test   %eax,%eax
80102d4f:	74 14                	je     80102d65 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d51:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d58:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d5d:	83 e0 bf             	and    $0xffffffbf,%eax
80102d60:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102d65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d68:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d6d:	0f b6 00             	movzbl (%eax),%eax
80102d70:	0f b6 d0             	movzbl %al,%edx
80102d73:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d78:	09 d0                	or     %edx,%eax
80102d7a:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102d7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d82:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102d87:	0f b6 00             	movzbl (%eax),%eax
80102d8a:	0f b6 d0             	movzbl %al,%edx
80102d8d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d92:	31 d0                	xor    %edx,%eax
80102d94:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d99:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d9e:	83 e0 03             	and    $0x3,%eax
80102da1:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102da8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dab:	01 d0                	add    %edx,%eax
80102dad:	0f b6 00             	movzbl (%eax),%eax
80102db0:	0f b6 c0             	movzbl %al,%eax
80102db3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102db6:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dbb:	83 e0 08             	and    $0x8,%eax
80102dbe:	85 c0                	test   %eax,%eax
80102dc0:	74 22                	je     80102de4 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102dc2:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102dc6:	76 0c                	jbe    80102dd4 <kbdgetc+0x13a>
80102dc8:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102dcc:	77 06                	ja     80102dd4 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102dce:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102dd2:	eb 10                	jmp    80102de4 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102dd4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102dd8:	76 0a                	jbe    80102de4 <kbdgetc+0x14a>
80102dda:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102dde:	77 04                	ja     80102de4 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102de0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102de4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102de7:	c9                   	leave  
80102de8:	c3                   	ret    

80102de9 <kbdintr>:

void
kbdintr(void)
{
80102de9:	55                   	push   %ebp
80102dea:	89 e5                	mov    %esp,%ebp
80102dec:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102def:	83 ec 0c             	sub    $0xc,%esp
80102df2:	68 9a 2c 10 80       	push   $0x80102c9a
80102df7:	e8 e1 d9 ff ff       	call   801007dd <consoleintr>
80102dfc:	83 c4 10             	add    $0x10,%esp
}
80102dff:	90                   	nop
80102e00:	c9                   	leave  
80102e01:	c3                   	ret    

80102e02 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e02:	55                   	push   %ebp
80102e03:	89 e5                	mov    %esp,%ebp
80102e05:	83 ec 14             	sub    $0x14,%esp
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e0f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e13:	89 c2                	mov    %eax,%edx
80102e15:	ec                   	in     (%dx),%al
80102e16:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e19:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e1d:	c9                   	leave  
80102e1e:	c3                   	ret    

80102e1f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 08             	sub    $0x8,%esp
80102e25:	8b 55 08             	mov    0x8(%ebp),%edx
80102e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e2b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e2f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e32:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e36:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e3a:	ee                   	out    %al,(%dx)
}
80102e3b:	90                   	nop
80102e3c:	c9                   	leave  
80102e3d:	c3                   	ret    

80102e3e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e3e:	55                   	push   %ebp
80102e3f:	89 e5                	mov    %esp,%ebp
80102e41:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e44:	9c                   	pushf  
80102e45:	58                   	pop    %eax
80102e46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e49:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e4c:	c9                   	leave  
80102e4d:	c3                   	ret    

80102e4e <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e4e:	55                   	push   %ebp
80102e4f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e51:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e56:	8b 55 08             	mov    0x8(%ebp),%edx
80102e59:	c1 e2 02             	shl    $0x2,%edx
80102e5c:	01 c2                	add    %eax,%edx
80102e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e61:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e63:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e68:	83 c0 20             	add    $0x20,%eax
80102e6b:	8b 00                	mov    (%eax),%eax
}
80102e6d:	90                   	nop
80102e6e:	5d                   	pop    %ebp
80102e6f:	c3                   	ret    

80102e70 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e73:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e78:	85 c0                	test   %eax,%eax
80102e7a:	0f 84 0b 01 00 00    	je     80102f8b <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e80:	68 3f 01 00 00       	push   $0x13f
80102e85:	6a 3c                	push   $0x3c
80102e87:	e8 c2 ff ff ff       	call   80102e4e <lapicw>
80102e8c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e8f:	6a 0b                	push   $0xb
80102e91:	68 f8 00 00 00       	push   $0xf8
80102e96:	e8 b3 ff ff ff       	call   80102e4e <lapicw>
80102e9b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e9e:	68 20 00 02 00       	push   $0x20020
80102ea3:	68 c8 00 00 00       	push   $0xc8
80102ea8:	e8 a1 ff ff ff       	call   80102e4e <lapicw>
80102ead:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102eb0:	68 80 96 98 00       	push   $0x989680
80102eb5:	68 e0 00 00 00       	push   $0xe0
80102eba:	e8 8f ff ff ff       	call   80102e4e <lapicw>
80102ebf:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ec2:	68 00 00 01 00       	push   $0x10000
80102ec7:	68 d4 00 00 00       	push   $0xd4
80102ecc:	e8 7d ff ff ff       	call   80102e4e <lapicw>
80102ed1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102ed4:	68 00 00 01 00       	push   $0x10000
80102ed9:	68 d8 00 00 00       	push   $0xd8
80102ede:	e8 6b ff ff ff       	call   80102e4e <lapicw>
80102ee3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ee6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102eeb:	83 c0 30             	add    $0x30,%eax
80102eee:	8b 00                	mov    (%eax),%eax
80102ef0:	c1 e8 10             	shr    $0x10,%eax
80102ef3:	0f b6 c0             	movzbl %al,%eax
80102ef6:	83 f8 03             	cmp    $0x3,%eax
80102ef9:	76 12                	jbe    80102f0d <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102efb:	68 00 00 01 00       	push   $0x10000
80102f00:	68 d0 00 00 00       	push   $0xd0
80102f05:	e8 44 ff ff ff       	call   80102e4e <lapicw>
80102f0a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f0d:	6a 33                	push   $0x33
80102f0f:	68 dc 00 00 00       	push   $0xdc
80102f14:	e8 35 ff ff ff       	call   80102e4e <lapicw>
80102f19:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f1c:	6a 00                	push   $0x0
80102f1e:	68 a0 00 00 00       	push   $0xa0
80102f23:	e8 26 ff ff ff       	call   80102e4e <lapicw>
80102f28:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f2b:	6a 00                	push   $0x0
80102f2d:	68 a0 00 00 00       	push   $0xa0
80102f32:	e8 17 ff ff ff       	call   80102e4e <lapicw>
80102f37:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f3a:	6a 00                	push   $0x0
80102f3c:	6a 2c                	push   $0x2c
80102f3e:	e8 0b ff ff ff       	call   80102e4e <lapicw>
80102f43:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f46:	6a 00                	push   $0x0
80102f48:	68 c4 00 00 00       	push   $0xc4
80102f4d:	e8 fc fe ff ff       	call   80102e4e <lapicw>
80102f52:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f55:	68 00 85 08 00       	push   $0x88500
80102f5a:	68 c0 00 00 00       	push   $0xc0
80102f5f:	e8 ea fe ff ff       	call   80102e4e <lapicw>
80102f64:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f67:	90                   	nop
80102f68:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f6d:	05 00 03 00 00       	add    $0x300,%eax
80102f72:	8b 00                	mov    (%eax),%eax
80102f74:	25 00 10 00 00       	and    $0x1000,%eax
80102f79:	85 c0                	test   %eax,%eax
80102f7b:	75 eb                	jne    80102f68 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f7d:	6a 00                	push   $0x0
80102f7f:	6a 20                	push   $0x20
80102f81:	e8 c8 fe ff ff       	call   80102e4e <lapicw>
80102f86:	83 c4 08             	add    $0x8,%esp
80102f89:	eb 01                	jmp    80102f8c <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f8b:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f8c:	c9                   	leave  
80102f8d:	c3                   	ret    

80102f8e <cpunum>:

int
cpunum(void)
{
80102f8e:	55                   	push   %ebp
80102f8f:	89 e5                	mov    %esp,%ebp
80102f91:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f94:	e8 a5 fe ff ff       	call   80102e3e <readeflags>
80102f99:	25 00 02 00 00       	and    $0x200,%eax
80102f9e:	85 c0                	test   %eax,%eax
80102fa0:	74 26                	je     80102fc8 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fa2:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102fa7:	8d 50 01             	lea    0x1(%eax),%edx
80102faa:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102fb0:	85 c0                	test   %eax,%eax
80102fb2:	75 14                	jne    80102fc8 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102fb4:	8b 45 04             	mov    0x4(%ebp),%eax
80102fb7:	83 ec 08             	sub    $0x8,%esp
80102fba:	50                   	push   %eax
80102fbb:	68 a0 94 10 80       	push   $0x801094a0
80102fc0:	e8 01 d4 ff ff       	call   801003c6 <cprintf>
80102fc5:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102fc8:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fcd:	85 c0                	test   %eax,%eax
80102fcf:	74 0f                	je     80102fe0 <cpunum+0x52>
    return lapic[ID]>>24;
80102fd1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fd6:	83 c0 20             	add    $0x20,%eax
80102fd9:	8b 00                	mov    (%eax),%eax
80102fdb:	c1 e8 18             	shr    $0x18,%eax
80102fde:	eb 05                	jmp    80102fe5 <cpunum+0x57>
  return 0;
80102fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102fe5:	c9                   	leave  
80102fe6:	c3                   	ret    

80102fe7 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102fe7:	55                   	push   %ebp
80102fe8:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102fea:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fef:	85 c0                	test   %eax,%eax
80102ff1:	74 0c                	je     80102fff <lapiceoi+0x18>
    lapicw(EOI, 0);
80102ff3:	6a 00                	push   $0x0
80102ff5:	6a 2c                	push   $0x2c
80102ff7:	e8 52 fe ff ff       	call   80102e4e <lapicw>
80102ffc:	83 c4 08             	add    $0x8,%esp
}
80102fff:	90                   	nop
80103000:	c9                   	leave  
80103001:	c3                   	ret    

80103002 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103002:	55                   	push   %ebp
80103003:	89 e5                	mov    %esp,%ebp
}
80103005:	90                   	nop
80103006:	5d                   	pop    %ebp
80103007:	c3                   	ret    

80103008 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103008:	55                   	push   %ebp
80103009:	89 e5                	mov    %esp,%ebp
8010300b:	83 ec 14             	sub    $0x14,%esp
8010300e:	8b 45 08             	mov    0x8(%ebp),%eax
80103011:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103014:	6a 0f                	push   $0xf
80103016:	6a 70                	push   $0x70
80103018:	e8 02 fe ff ff       	call   80102e1f <outb>
8010301d:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103020:	6a 0a                	push   $0xa
80103022:	6a 71                	push   $0x71
80103024:	e8 f6 fd ff ff       	call   80102e1f <outb>
80103029:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010302c:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103033:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103036:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010303b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010303e:	83 c0 02             	add    $0x2,%eax
80103041:	8b 55 0c             	mov    0xc(%ebp),%edx
80103044:	c1 ea 04             	shr    $0x4,%edx
80103047:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010304a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010304e:	c1 e0 18             	shl    $0x18,%eax
80103051:	50                   	push   %eax
80103052:	68 c4 00 00 00       	push   $0xc4
80103057:	e8 f2 fd ff ff       	call   80102e4e <lapicw>
8010305c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010305f:	68 00 c5 00 00       	push   $0xc500
80103064:	68 c0 00 00 00       	push   $0xc0
80103069:	e8 e0 fd ff ff       	call   80102e4e <lapicw>
8010306e:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103071:	68 c8 00 00 00       	push   $0xc8
80103076:	e8 87 ff ff ff       	call   80103002 <microdelay>
8010307b:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010307e:	68 00 85 00 00       	push   $0x8500
80103083:	68 c0 00 00 00       	push   $0xc0
80103088:	e8 c1 fd ff ff       	call   80102e4e <lapicw>
8010308d:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103090:	6a 64                	push   $0x64
80103092:	e8 6b ff ff ff       	call   80103002 <microdelay>
80103097:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010309a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030a1:	eb 3d                	jmp    801030e0 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030a3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030a7:	c1 e0 18             	shl    $0x18,%eax
801030aa:	50                   	push   %eax
801030ab:	68 c4 00 00 00       	push   $0xc4
801030b0:	e8 99 fd ff ff       	call   80102e4e <lapicw>
801030b5:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801030bb:	c1 e8 0c             	shr    $0xc,%eax
801030be:	80 cc 06             	or     $0x6,%ah
801030c1:	50                   	push   %eax
801030c2:	68 c0 00 00 00       	push   $0xc0
801030c7:	e8 82 fd ff ff       	call   80102e4e <lapicw>
801030cc:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030cf:	68 c8 00 00 00       	push   $0xc8
801030d4:	e8 29 ff ff ff       	call   80103002 <microdelay>
801030d9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030e0:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030e4:	7e bd                	jle    801030a3 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030e6:	90                   	nop
801030e7:	c9                   	leave  
801030e8:	c3                   	ret    

801030e9 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030e9:	55                   	push   %ebp
801030ea:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801030ec:	8b 45 08             	mov    0x8(%ebp),%eax
801030ef:	0f b6 c0             	movzbl %al,%eax
801030f2:	50                   	push   %eax
801030f3:	6a 70                	push   $0x70
801030f5:	e8 25 fd ff ff       	call   80102e1f <outb>
801030fa:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030fd:	68 c8 00 00 00       	push   $0xc8
80103102:	e8 fb fe ff ff       	call   80103002 <microdelay>
80103107:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010310a:	6a 71                	push   $0x71
8010310c:	e8 f1 fc ff ff       	call   80102e02 <inb>
80103111:	83 c4 04             	add    $0x4,%esp
80103114:	0f b6 c0             	movzbl %al,%eax
}
80103117:	c9                   	leave  
80103118:	c3                   	ret    

80103119 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103119:	55                   	push   %ebp
8010311a:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010311c:	6a 00                	push   $0x0
8010311e:	e8 c6 ff ff ff       	call   801030e9 <cmos_read>
80103123:	83 c4 04             	add    $0x4,%esp
80103126:	89 c2                	mov    %eax,%edx
80103128:	8b 45 08             	mov    0x8(%ebp),%eax
8010312b:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010312d:	6a 02                	push   $0x2
8010312f:	e8 b5 ff ff ff       	call   801030e9 <cmos_read>
80103134:	83 c4 04             	add    $0x4,%esp
80103137:	89 c2                	mov    %eax,%edx
80103139:	8b 45 08             	mov    0x8(%ebp),%eax
8010313c:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010313f:	6a 04                	push   $0x4
80103141:	e8 a3 ff ff ff       	call   801030e9 <cmos_read>
80103146:	83 c4 04             	add    $0x4,%esp
80103149:	89 c2                	mov    %eax,%edx
8010314b:	8b 45 08             	mov    0x8(%ebp),%eax
8010314e:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103151:	6a 07                	push   $0x7
80103153:	e8 91 ff ff ff       	call   801030e9 <cmos_read>
80103158:	83 c4 04             	add    $0x4,%esp
8010315b:	89 c2                	mov    %eax,%edx
8010315d:	8b 45 08             	mov    0x8(%ebp),%eax
80103160:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103163:	6a 08                	push   $0x8
80103165:	e8 7f ff ff ff       	call   801030e9 <cmos_read>
8010316a:	83 c4 04             	add    $0x4,%esp
8010316d:	89 c2                	mov    %eax,%edx
8010316f:	8b 45 08             	mov    0x8(%ebp),%eax
80103172:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103175:	6a 09                	push   $0x9
80103177:	e8 6d ff ff ff       	call   801030e9 <cmos_read>
8010317c:	83 c4 04             	add    $0x4,%esp
8010317f:	89 c2                	mov    %eax,%edx
80103181:	8b 45 08             	mov    0x8(%ebp),%eax
80103184:	89 50 14             	mov    %edx,0x14(%eax)
}
80103187:	90                   	nop
80103188:	c9                   	leave  
80103189:	c3                   	ret    

8010318a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010318a:	55                   	push   %ebp
8010318b:	89 e5                	mov    %esp,%ebp
8010318d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103190:	6a 0b                	push   $0xb
80103192:	e8 52 ff ff ff       	call   801030e9 <cmos_read>
80103197:	83 c4 04             	add    $0x4,%esp
8010319a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010319d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a0:	83 e0 04             	and    $0x4,%eax
801031a3:	85 c0                	test   %eax,%eax
801031a5:	0f 94 c0             	sete   %al
801031a8:	0f b6 c0             	movzbl %al,%eax
801031ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031ae:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031b1:	50                   	push   %eax
801031b2:	e8 62 ff ff ff       	call   80103119 <fill_rtcdate>
801031b7:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031ba:	6a 0a                	push   $0xa
801031bc:	e8 28 ff ff ff       	call   801030e9 <cmos_read>
801031c1:	83 c4 04             	add    $0x4,%esp
801031c4:	25 80 00 00 00       	and    $0x80,%eax
801031c9:	85 c0                	test   %eax,%eax
801031cb:	75 27                	jne    801031f4 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031cd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031d0:	50                   	push   %eax
801031d1:	e8 43 ff ff ff       	call   80103119 <fill_rtcdate>
801031d6:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031d9:	83 ec 04             	sub    $0x4,%esp
801031dc:	6a 18                	push   $0x18
801031de:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e1:	50                   	push   %eax
801031e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031e5:	50                   	push   %eax
801031e6:	e8 4d 2a 00 00       	call   80105c38 <memcmp>
801031eb:	83 c4 10             	add    $0x10,%esp
801031ee:	85 c0                	test   %eax,%eax
801031f0:	74 05                	je     801031f7 <cmostime+0x6d>
801031f2:	eb ba                	jmp    801031ae <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801031f4:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031f5:	eb b7                	jmp    801031ae <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801031f7:	90                   	nop
  }

  // convert
  if (bcd) {
801031f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031fc:	0f 84 b4 00 00 00    	je     801032b6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103202:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103205:	c1 e8 04             	shr    $0x4,%eax
80103208:	89 c2                	mov    %eax,%edx
8010320a:	89 d0                	mov    %edx,%eax
8010320c:	c1 e0 02             	shl    $0x2,%eax
8010320f:	01 d0                	add    %edx,%eax
80103211:	01 c0                	add    %eax,%eax
80103213:	89 c2                	mov    %eax,%edx
80103215:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103218:	83 e0 0f             	and    $0xf,%eax
8010321b:	01 d0                	add    %edx,%eax
8010321d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103220:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103223:	c1 e8 04             	shr    $0x4,%eax
80103226:	89 c2                	mov    %eax,%edx
80103228:	89 d0                	mov    %edx,%eax
8010322a:	c1 e0 02             	shl    $0x2,%eax
8010322d:	01 d0                	add    %edx,%eax
8010322f:	01 c0                	add    %eax,%eax
80103231:	89 c2                	mov    %eax,%edx
80103233:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103236:	83 e0 0f             	and    $0xf,%eax
80103239:	01 d0                	add    %edx,%eax
8010323b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010323e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103241:	c1 e8 04             	shr    $0x4,%eax
80103244:	89 c2                	mov    %eax,%edx
80103246:	89 d0                	mov    %edx,%eax
80103248:	c1 e0 02             	shl    $0x2,%eax
8010324b:	01 d0                	add    %edx,%eax
8010324d:	01 c0                	add    %eax,%eax
8010324f:	89 c2                	mov    %eax,%edx
80103251:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103254:	83 e0 0f             	and    $0xf,%eax
80103257:	01 d0                	add    %edx,%eax
80103259:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010325c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010325f:	c1 e8 04             	shr    $0x4,%eax
80103262:	89 c2                	mov    %eax,%edx
80103264:	89 d0                	mov    %edx,%eax
80103266:	c1 e0 02             	shl    $0x2,%eax
80103269:	01 d0                	add    %edx,%eax
8010326b:	01 c0                	add    %eax,%eax
8010326d:	89 c2                	mov    %eax,%edx
8010326f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103272:	83 e0 0f             	and    $0xf,%eax
80103275:	01 d0                	add    %edx,%eax
80103277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010327a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010327d:	c1 e8 04             	shr    $0x4,%eax
80103280:	89 c2                	mov    %eax,%edx
80103282:	89 d0                	mov    %edx,%eax
80103284:	c1 e0 02             	shl    $0x2,%eax
80103287:	01 d0                	add    %edx,%eax
80103289:	01 c0                	add    %eax,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103290:	83 e0 0f             	and    $0xf,%eax
80103293:	01 d0                	add    %edx,%eax
80103295:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103298:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010329b:	c1 e8 04             	shr    $0x4,%eax
8010329e:	89 c2                	mov    %eax,%edx
801032a0:	89 d0                	mov    %edx,%eax
801032a2:	c1 e0 02             	shl    $0x2,%eax
801032a5:	01 d0                	add    %edx,%eax
801032a7:	01 c0                	add    %eax,%eax
801032a9:	89 c2                	mov    %eax,%edx
801032ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ae:	83 e0 0f             	and    $0xf,%eax
801032b1:	01 d0                	add    %edx,%eax
801032b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032b6:	8b 45 08             	mov    0x8(%ebp),%eax
801032b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032bc:	89 10                	mov    %edx,(%eax)
801032be:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032c1:	89 50 04             	mov    %edx,0x4(%eax)
801032c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032c7:	89 50 08             	mov    %edx,0x8(%eax)
801032ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032cd:	89 50 0c             	mov    %edx,0xc(%eax)
801032d0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032d3:	89 50 10             	mov    %edx,0x10(%eax)
801032d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032d9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032dc:	8b 45 08             	mov    0x8(%ebp),%eax
801032df:	8b 40 14             	mov    0x14(%eax),%eax
801032e2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032e8:	8b 45 08             	mov    0x8(%ebp),%eax
801032eb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ee:	90                   	nop
801032ef:	c9                   	leave  
801032f0:	c3                   	ret    

801032f1 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
801032f1:	55                   	push   %ebp
801032f2:	89 e5                	mov    %esp,%ebp
801032f4:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032f7:	83 ec 08             	sub    $0x8,%esp
801032fa:	68 cc 94 10 80       	push   $0x801094cc
801032ff:	68 80 32 11 80       	push   $0x80113280
80103304:	e8 43 26 00 00       	call   8010594c <initlock>
80103309:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
8010330c:	83 ec 08             	sub    $0x8,%esp
8010330f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103312:	50                   	push   %eax
80103313:	6a 01                	push   $0x1
80103315:	e8 b2 e0 ff ff       	call   801013cc <readsb>
8010331a:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
8010331d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103323:	29 c2                	sub    %eax,%edx
80103325:	89 d0                	mov    %edx,%eax
80103327:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
8010332c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332f:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
80103334:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
8010333b:	00 00 00 
  recover_from_log();
8010333e:	e8 b2 01 00 00       	call   801034f5 <recover_from_log>
}
80103343:	90                   	nop
80103344:	c9                   	leave  
80103345:	c3                   	ret    

80103346 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103346:	55                   	push   %ebp
80103347:	89 e5                	mov    %esp,%ebp
80103349:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010334c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103353:	e9 95 00 00 00       	jmp    801033ed <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103358:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010335e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103361:	01 d0                	add    %edx,%eax
80103363:	83 c0 01             	add    $0x1,%eax
80103366:	89 c2                	mov    %eax,%edx
80103368:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010336d:	83 ec 08             	sub    $0x8,%esp
80103370:	52                   	push   %edx
80103371:	50                   	push   %eax
80103372:	e8 3f ce ff ff       	call   801001b6 <bread>
80103377:	83 c4 10             	add    $0x10,%esp
8010337a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010337d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103380:	83 c0 10             	add    $0x10,%eax
80103383:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010338a:	89 c2                	mov    %eax,%edx
8010338c:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103391:	83 ec 08             	sub    $0x8,%esp
80103394:	52                   	push   %edx
80103395:	50                   	push   %eax
80103396:	e8 1b ce ff ff       	call   801001b6 <bread>
8010339b:	83 c4 10             	add    $0x10,%esp
8010339e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a4:	8d 50 18             	lea    0x18(%eax),%edx
801033a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033aa:	83 c0 18             	add    $0x18,%eax
801033ad:	83 ec 04             	sub    $0x4,%esp
801033b0:	68 00 02 00 00       	push   $0x200
801033b5:	52                   	push   %edx
801033b6:	50                   	push   %eax
801033b7:	e8 d4 28 00 00       	call   80105c90 <memmove>
801033bc:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033bf:	83 ec 0c             	sub    $0xc,%esp
801033c2:	ff 75 ec             	pushl  -0x14(%ebp)
801033c5:	e8 25 ce ff ff       	call   801001ef <bwrite>
801033ca:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801033cd:	83 ec 0c             	sub    $0xc,%esp
801033d0:	ff 75 f0             	pushl  -0x10(%ebp)
801033d3:	e8 56 ce ff ff       	call   8010022e <brelse>
801033d8:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033db:	83 ec 0c             	sub    $0xc,%esp
801033de:	ff 75 ec             	pushl  -0x14(%ebp)
801033e1:	e8 48 ce ff ff       	call   8010022e <brelse>
801033e6:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ed:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033f5:	0f 8f 5d ff ff ff    	jg     80103358 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033fb:	90                   	nop
801033fc:	c9                   	leave  
801033fd:	c3                   	ret    

801033fe <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033fe:	55                   	push   %ebp
801033ff:	89 e5                	mov    %esp,%ebp
80103401:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103404:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103409:	89 c2                	mov    %eax,%edx
8010340b:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103410:	83 ec 08             	sub    $0x8,%esp
80103413:	52                   	push   %edx
80103414:	50                   	push   %eax
80103415:	e8 9c cd ff ff       	call   801001b6 <bread>
8010341a:	83 c4 10             	add    $0x10,%esp
8010341d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103420:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103423:	83 c0 18             	add    $0x18,%eax
80103426:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103429:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342c:	8b 00                	mov    (%eax),%eax
8010342e:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103433:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010343a:	eb 1b                	jmp    80103457 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
8010343c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010343f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103442:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103449:	83 c2 10             	add    $0x10,%edx
8010344c:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103453:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103457:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010345c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010345f:	7f db                	jg     8010343c <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103461:	83 ec 0c             	sub    $0xc,%esp
80103464:	ff 75 f0             	pushl  -0x10(%ebp)
80103467:	e8 c2 cd ff ff       	call   8010022e <brelse>
8010346c:	83 c4 10             	add    $0x10,%esp
}
8010346f:	90                   	nop
80103470:	c9                   	leave  
80103471:	c3                   	ret    

80103472 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103472:	55                   	push   %ebp
80103473:	89 e5                	mov    %esp,%ebp
80103475:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103478:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010347d:	89 c2                	mov    %eax,%edx
8010347f:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103484:	83 ec 08             	sub    $0x8,%esp
80103487:	52                   	push   %edx
80103488:	50                   	push   %eax
80103489:	e8 28 cd ff ff       	call   801001b6 <bread>
8010348e:	83 c4 10             	add    $0x10,%esp
80103491:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103497:	83 c0 18             	add    $0x18,%eax
8010349a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010349d:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
801034a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a6:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034af:	eb 1b                	jmp    801034cc <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
801034b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b4:	83 c0 10             	add    $0x10,%eax
801034b7:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
801034be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c4:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034cc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034d4:	7f db                	jg     801034b1 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801034d6:	83 ec 0c             	sub    $0xc,%esp
801034d9:	ff 75 f0             	pushl  -0x10(%ebp)
801034dc:	e8 0e cd ff ff       	call   801001ef <bwrite>
801034e1:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034e4:	83 ec 0c             	sub    $0xc,%esp
801034e7:	ff 75 f0             	pushl  -0x10(%ebp)
801034ea:	e8 3f cd ff ff       	call   8010022e <brelse>
801034ef:	83 c4 10             	add    $0x10,%esp
}
801034f2:	90                   	nop
801034f3:	c9                   	leave  
801034f4:	c3                   	ret    

801034f5 <recover_from_log>:

static void
recover_from_log(void)
{
801034f5:	55                   	push   %ebp
801034f6:	89 e5                	mov    %esp,%ebp
801034f8:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034fb:	e8 fe fe ff ff       	call   801033fe <read_head>
  install_trans(); // if committed, copy from log to disk
80103500:	e8 41 fe ff ff       	call   80103346 <install_trans>
  log.lh.n = 0;
80103505:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010350c:	00 00 00 
  write_head(); // clear the log
8010350f:	e8 5e ff ff ff       	call   80103472 <write_head>
}
80103514:	90                   	nop
80103515:	c9                   	leave  
80103516:	c3                   	ret    

80103517 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103517:	55                   	push   %ebp
80103518:	89 e5                	mov    %esp,%ebp
8010351a:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010351d:	83 ec 0c             	sub    $0xc,%esp
80103520:	68 80 32 11 80       	push   $0x80113280
80103525:	e8 44 24 00 00       	call   8010596e <acquire>
8010352a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010352d:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103532:	85 c0                	test   %eax,%eax
80103534:	74 17                	je     8010354d <begin_op+0x36>
      sleep(&log, &log.lock);
80103536:	83 ec 08             	sub    $0x8,%esp
80103539:	68 80 32 11 80       	push   $0x80113280
8010353e:	68 80 32 11 80       	push   $0x80113280
80103543:	e8 6a 1c 00 00       	call   801051b2 <sleep>
80103548:	83 c4 10             	add    $0x10,%esp
8010354b:	eb e0                	jmp    8010352d <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010354d:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103553:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103558:	8d 50 01             	lea    0x1(%eax),%edx
8010355b:	89 d0                	mov    %edx,%eax
8010355d:	c1 e0 02             	shl    $0x2,%eax
80103560:	01 d0                	add    %edx,%eax
80103562:	01 c0                	add    %eax,%eax
80103564:	01 c8                	add    %ecx,%eax
80103566:	83 f8 1e             	cmp    $0x1e,%eax
80103569:	7e 17                	jle    80103582 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010356b:	83 ec 08             	sub    $0x8,%esp
8010356e:	68 80 32 11 80       	push   $0x80113280
80103573:	68 80 32 11 80       	push   $0x80113280
80103578:	e8 35 1c 00 00       	call   801051b2 <sleep>
8010357d:	83 c4 10             	add    $0x10,%esp
80103580:	eb ab                	jmp    8010352d <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103582:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103587:	83 c0 01             	add    $0x1,%eax
8010358a:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010358f:	83 ec 0c             	sub    $0xc,%esp
80103592:	68 80 32 11 80       	push   $0x80113280
80103597:	e8 39 24 00 00       	call   801059d5 <release>
8010359c:	83 c4 10             	add    $0x10,%esp
      break;
8010359f:	90                   	nop
    }
  }
}
801035a0:	90                   	nop
801035a1:	c9                   	leave  
801035a2:	c3                   	ret    

801035a3 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035a3:	55                   	push   %ebp
801035a4:	89 e5                	mov    %esp,%ebp
801035a6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b0:	83 ec 0c             	sub    $0xc,%esp
801035b3:	68 80 32 11 80       	push   $0x80113280
801035b8:	e8 b1 23 00 00       	call   8010596e <acquire>
801035bd:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c0:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801035c5:	83 e8 01             	sub    $0x1,%eax
801035c8:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801035cd:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801035d2:	85 c0                	test   %eax,%eax
801035d4:	74 0d                	je     801035e3 <end_op+0x40>
    panic("log.committing");
801035d6:	83 ec 0c             	sub    $0xc,%esp
801035d9:	68 d0 94 10 80       	push   $0x801094d0
801035de:	e8 83 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801035e3:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801035e8:	85 c0                	test   %eax,%eax
801035ea:	75 13                	jne    801035ff <end_op+0x5c>
    do_commit = 1;
801035ec:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035f3:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801035fa:	00 00 00 
801035fd:	eb 10                	jmp    8010360f <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801035ff:	83 ec 0c             	sub    $0xc,%esp
80103602:	68 80 32 11 80       	push   $0x80113280
80103607:	e8 b2 1c 00 00       	call   801052be <wakeup>
8010360c:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010360f:	83 ec 0c             	sub    $0xc,%esp
80103612:	68 80 32 11 80       	push   $0x80113280
80103617:	e8 b9 23 00 00       	call   801059d5 <release>
8010361c:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010361f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103623:	74 3f                	je     80103664 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103625:	e8 f5 00 00 00       	call   8010371f <commit>
    acquire(&log.lock);
8010362a:	83 ec 0c             	sub    $0xc,%esp
8010362d:	68 80 32 11 80       	push   $0x80113280
80103632:	e8 37 23 00 00       	call   8010596e <acquire>
80103637:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010363a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103641:	00 00 00 
    wakeup(&log);
80103644:	83 ec 0c             	sub    $0xc,%esp
80103647:	68 80 32 11 80       	push   $0x80113280
8010364c:	e8 6d 1c 00 00       	call   801052be <wakeup>
80103651:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103654:	83 ec 0c             	sub    $0xc,%esp
80103657:	68 80 32 11 80       	push   $0x80113280
8010365c:	e8 74 23 00 00       	call   801059d5 <release>
80103661:	83 c4 10             	add    $0x10,%esp
  }
}
80103664:	90                   	nop
80103665:	c9                   	leave  
80103666:	c3                   	ret    

80103667 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103667:	55                   	push   %ebp
80103668:	89 e5                	mov    %esp,%ebp
8010366a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010366d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103674:	e9 95 00 00 00       	jmp    8010370e <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103679:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010367f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103682:	01 d0                	add    %edx,%eax
80103684:	83 c0 01             	add    $0x1,%eax
80103687:	89 c2                	mov    %eax,%edx
80103689:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010368e:	83 ec 08             	sub    $0x8,%esp
80103691:	52                   	push   %edx
80103692:	50                   	push   %eax
80103693:	e8 1e cb ff ff       	call   801001b6 <bread>
80103698:	83 c4 10             	add    $0x10,%esp
8010369b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a1:	83 c0 10             	add    $0x10,%eax
801036a4:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801036ab:	89 c2                	mov    %eax,%edx
801036ad:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801036b2:	83 ec 08             	sub    $0x8,%esp
801036b5:	52                   	push   %edx
801036b6:	50                   	push   %eax
801036b7:	e8 fa ca ff ff       	call   801001b6 <bread>
801036bc:	83 c4 10             	add    $0x10,%esp
801036bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036c5:	8d 50 18             	lea    0x18(%eax),%edx
801036c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036cb:	83 c0 18             	add    $0x18,%eax
801036ce:	83 ec 04             	sub    $0x4,%esp
801036d1:	68 00 02 00 00       	push   $0x200
801036d6:	52                   	push   %edx
801036d7:	50                   	push   %eax
801036d8:	e8 b3 25 00 00       	call   80105c90 <memmove>
801036dd:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e0:	83 ec 0c             	sub    $0xc,%esp
801036e3:	ff 75 f0             	pushl  -0x10(%ebp)
801036e6:	e8 04 cb ff ff       	call   801001ef <bwrite>
801036eb:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801036ee:	83 ec 0c             	sub    $0xc,%esp
801036f1:	ff 75 ec             	pushl  -0x14(%ebp)
801036f4:	e8 35 cb ff ff       	call   8010022e <brelse>
801036f9:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801036fc:	83 ec 0c             	sub    $0xc,%esp
801036ff:	ff 75 f0             	pushl  -0x10(%ebp)
80103702:	e8 27 cb ff ff       	call   8010022e <brelse>
80103707:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010370a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010370e:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103713:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103716:	0f 8f 5d ff ff ff    	jg     80103679 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010371c:	90                   	nop
8010371d:	c9                   	leave  
8010371e:	c3                   	ret    

8010371f <commit>:

static void
commit()
{
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103725:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010372a:	85 c0                	test   %eax,%eax
8010372c:	7e 1e                	jle    8010374c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010372e:	e8 34 ff ff ff       	call   80103667 <write_log>
    write_head();    // Write header to disk -- the real commit
80103733:	e8 3a fd ff ff       	call   80103472 <write_head>
    install_trans(); // Now install writes to home locations
80103738:	e8 09 fc ff ff       	call   80103346 <install_trans>
    log.lh.n = 0; 
8010373d:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103744:	00 00 00 
    write_head();    // Erase the transaction from the log
80103747:	e8 26 fd ff ff       	call   80103472 <write_head>
  }
}
8010374c:	90                   	nop
8010374d:	c9                   	leave  
8010374e:	c3                   	ret    

8010374f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010374f:	55                   	push   %ebp
80103750:	89 e5                	mov    %esp,%ebp
80103752:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103755:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010375a:	83 f8 1d             	cmp    $0x1d,%eax
8010375d:	7f 12                	jg     80103771 <log_write+0x22>
8010375f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103764:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
8010376a:	83 ea 01             	sub    $0x1,%edx
8010376d:	39 d0                	cmp    %edx,%eax
8010376f:	7c 0d                	jl     8010377e <log_write+0x2f>
    panic("too big a transaction");
80103771:	83 ec 0c             	sub    $0xc,%esp
80103774:	68 df 94 10 80       	push   $0x801094df
80103779:	e8 e8 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010377e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103783:	85 c0                	test   %eax,%eax
80103785:	7f 0d                	jg     80103794 <log_write+0x45>
    panic("log_write outside of trans");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 f5 94 10 80       	push   $0x801094f5
8010378f:	e8 d2 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	68 80 32 11 80       	push   $0x80113280
8010379c:	e8 cd 21 00 00       	call   8010596e <acquire>
801037a1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037ab:	eb 1d                	jmp    801037ca <log_write+0x7b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801037ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b0:	83 c0 10             	add    $0x10,%eax
801037b3:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801037ba:	89 c2                	mov    %eax,%edx
801037bc:	8b 45 08             	mov    0x8(%ebp),%eax
801037bf:	8b 40 08             	mov    0x8(%eax),%eax
801037c2:	39 c2                	cmp    %eax,%edx
801037c4:	74 10                	je     801037d6 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037ca:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037d2:	7f d9                	jg     801037ad <log_write+0x5e>
801037d4:	eb 01                	jmp    801037d7 <log_write+0x88>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
801037d6:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801037d7:	8b 45 08             	mov    0x8(%ebp),%eax
801037da:	8b 40 08             	mov    0x8(%eax),%eax
801037dd:	89 c2                	mov    %eax,%edx
801037df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e2:	83 c0 10             	add    $0x10,%eax
801037e5:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801037ec:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037f4:	75 0d                	jne    80103803 <log_write+0xb4>
    log.lh.n++;
801037f6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037fb:	83 c0 01             	add    $0x1,%eax
801037fe:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
80103803:	8b 45 08             	mov    0x8(%ebp),%eax
80103806:	8b 00                	mov    (%eax),%eax
80103808:	83 c8 04             	or     $0x4,%eax
8010380b:	89 c2                	mov    %eax,%edx
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103812:	83 ec 0c             	sub    $0xc,%esp
80103815:	68 80 32 11 80       	push   $0x80113280
8010381a:	e8 b6 21 00 00       	call   801059d5 <release>
8010381f:	83 c4 10             	add    $0x10,%esp
}
80103822:	90                   	nop
80103823:	c9                   	leave  
80103824:	c3                   	ret    

80103825 <v2p>:
80103825:	55                   	push   %ebp
80103826:	89 e5                	mov    %esp,%ebp
80103828:	8b 45 08             	mov    0x8(%ebp),%eax
8010382b:	05 00 00 00 80       	add    $0x80000000,%eax
80103830:	5d                   	pop    %ebp
80103831:	c3                   	ret    

80103832 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103832:	55                   	push   %ebp
80103833:	89 e5                	mov    %esp,%ebp
80103835:	8b 45 08             	mov    0x8(%ebp),%eax
80103838:	05 00 00 00 80       	add    $0x80000000,%eax
8010383d:	5d                   	pop    %ebp
8010383e:	c3                   	ret    

8010383f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010383f:	55                   	push   %ebp
80103840:	89 e5                	mov    %esp,%ebp
80103842:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103845:	8b 55 08             	mov    0x8(%ebp),%edx
80103848:	8b 45 0c             	mov    0xc(%ebp),%eax
8010384b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010384e:	f0 87 02             	lock xchg %eax,(%edx)
80103851:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103854:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103857:	c9                   	leave  
80103858:	c3                   	ret    

80103859 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103859:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010385d:	83 e4 f0             	and    $0xfffffff0,%esp
80103860:	ff 71 fc             	pushl  -0x4(%ecx)
80103863:	55                   	push   %ebp
80103864:	89 e5                	mov    %esp,%ebp
80103866:	51                   	push   %ecx
80103867:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010386a:	83 ec 08             	sub    $0x8,%esp
8010386d:	68 00 00 40 80       	push   $0x80400000
80103872:	68 bc 81 11 80       	push   $0x801181bc
80103877:	e8 75 f2 ff ff       	call   80102af1 <kinit1>
8010387c:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010387f:	e8 d8 52 00 00       	call   80108b5c <kvmalloc>
  mpinit();        // collect info about this machine
80103884:	e8 89 05 00 00       	call   80103e12 <mpinit>
  lapicinit();
80103889:	e8 e2 f5 ff ff       	call   80102e70 <lapicinit>
  seginit();       // set up segments
8010388e:	e8 72 4c 00 00       	call   80108505 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103893:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103899:	0f b6 00             	movzbl (%eax),%eax
8010389c:	0f b6 c0             	movzbl %al,%eax
8010389f:	83 ec 08             	sub    $0x8,%esp
801038a2:	50                   	push   %eax
801038a3:	68 10 95 10 80       	push   $0x80109510
801038a8:	e8 19 cb ff ff       	call   801003c6 <cprintf>
801038ad:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038b0:	e8 b3 07 00 00       	call   80104068 <picinit>
  ioapicinit();    // another interrupt controller
801038b5:	e8 2c f1 ff ff       	call   801029e6 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038ba:	e8 2a d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801038bf:	e8 9d 3f 00 00       	call   80107861 <uartinit>
  pinit();         // process table
801038c4:	e8 28 0f 00 00       	call   801047f1 <pinit>
  tvinit();        // trap vectors
801038c9:	e8 1e 39 00 00       	call   801071ec <tvinit>
  binit();         // buffer cache
801038ce:	e8 61 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038d3:	e8 8a d6 ff ff       	call   80100f62 <fileinit>
  seminit();       // semaphore table
801038d8:	e8 bf 1b 00 00       	call   8010549c <seminit>
  iinit();         // inode cache
801038dd:	e8 b9 dd ff ff       	call   8010169b <iinit>
  ideinit();       // disk
801038e2:	e8 43 ed ff ff       	call   8010262a <ideinit>
  if(!ismp)
801038e7:	a1 64 33 11 80       	mov    0x80113364,%eax
801038ec:	85 c0                	test   %eax,%eax
801038ee:	75 05                	jne    801038f5 <main+0x9c>
    timerinit();   // uniprocessor timer
801038f0:	e8 54 38 00 00       	call   80107149 <timerinit>
  startothers();   // start other processors
801038f5:	e8 7f 00 00 00       	call   80103979 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038fa:	83 ec 08             	sub    $0x8,%esp
801038fd:	68 00 00 00 8e       	push   $0x8e000000
80103902:	68 00 00 40 80       	push   $0x80400000
80103907:	e8 1e f2 ff ff       	call   80102b2a <kinit2>
8010390c:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010390f:	e8 19 10 00 00       	call   8010492d <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103914:	e8 1a 00 00 00       	call   80103933 <mpmain>

80103919 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103919:	55                   	push   %ebp
8010391a:	89 e5                	mov    %esp,%ebp
8010391c:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010391f:	e8 50 52 00 00       	call   80108b74 <switchkvm>
  seginit();
80103924:	e8 dc 4b 00 00       	call   80108505 <seginit>
  lapicinit();
80103929:	e8 42 f5 ff ff       	call   80102e70 <lapicinit>
  mpmain();
8010392e:	e8 00 00 00 00       	call   80103933 <mpmain>

80103933 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103933:	55                   	push   %ebp
80103934:	89 e5                	mov    %esp,%ebp
80103936:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103939:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010393f:	0f b6 00             	movzbl (%eax),%eax
80103942:	0f b6 c0             	movzbl %al,%eax
80103945:	83 ec 08             	sub    $0x8,%esp
80103948:	50                   	push   %eax
80103949:	68 27 95 10 80       	push   $0x80109527
8010394e:	e8 73 ca ff ff       	call   801003c6 <cprintf>
80103953:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103956:	e8 07 3a 00 00       	call   80107362 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010395b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103961:	05 a8 00 00 00       	add    $0xa8,%eax
80103966:	83 ec 08             	sub    $0x8,%esp
80103969:	6a 01                	push   $0x1
8010396b:	50                   	push   %eax
8010396c:	e8 ce fe ff ff       	call   8010383f <xchg>
80103971:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103974:	e8 2b 16 00 00       	call   80104fa4 <scheduler>

80103979 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103979:	55                   	push   %ebp
8010397a:	89 e5                	mov    %esp,%ebp
8010397c:	53                   	push   %ebx
8010397d:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103980:	68 00 70 00 00       	push   $0x7000
80103985:	e8 a8 fe ff ff       	call   80103832 <p2v>
8010398a:	83 c4 04             	add    $0x4,%esp
8010398d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103990:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103995:	83 ec 04             	sub    $0x4,%esp
80103998:	50                   	push   %eax
80103999:	68 2c c5 10 80       	push   $0x8010c52c
8010399e:	ff 75 f0             	pushl  -0x10(%ebp)
801039a1:	e8 ea 22 00 00       	call   80105c90 <memmove>
801039a6:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039a9:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
801039b0:	e9 90 00 00 00       	jmp    80103a45 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039b5:	e8 d4 f5 ff ff       	call   80102f8e <cpunum>
801039ba:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039c0:	05 80 33 11 80       	add    $0x80113380,%eax
801039c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039c8:	74 73                	je     80103a3d <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039ca:	e8 59 f2 ff ff       	call   80102c28 <kalloc>
801039cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d5:	83 e8 04             	sub    $0x4,%eax
801039d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039db:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039e1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e6:	83 e8 08             	sub    $0x8,%eax
801039e9:	c7 00 19 39 10 80    	movl   $0x80103919,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801039ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f2:	8d 58 f4             	lea    -0xc(%eax),%ebx
801039f5:	83 ec 0c             	sub    $0xc,%esp
801039f8:	68 00 b0 10 80       	push   $0x8010b000
801039fd:	e8 23 fe ff ff       	call   80103825 <v2p>
80103a02:	83 c4 10             	add    $0x10,%esp
80103a05:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a07:	83 ec 0c             	sub    $0xc,%esp
80103a0a:	ff 75 f0             	pushl  -0x10(%ebp)
80103a0d:	e8 13 fe ff ff       	call   80103825 <v2p>
80103a12:	83 c4 10             	add    $0x10,%esp
80103a15:	89 c2                	mov    %eax,%edx
80103a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1a:	0f b6 00             	movzbl (%eax),%eax
80103a1d:	0f b6 c0             	movzbl %al,%eax
80103a20:	83 ec 08             	sub    $0x8,%esp
80103a23:	52                   	push   %edx
80103a24:	50                   	push   %eax
80103a25:	e8 de f5 ff ff       	call   80103008 <lapicstartap>
80103a2a:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a2d:	90                   	nop
80103a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a31:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a37:	85 c0                	test   %eax,%eax
80103a39:	74 f3                	je     80103a2e <startothers+0xb5>
80103a3b:	eb 01                	jmp    80103a3e <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a3d:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a3e:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a45:	a1 60 39 11 80       	mov    0x80113960,%eax
80103a4a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a50:	05 80 33 11 80       	add    $0x80113380,%eax
80103a55:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a58:	0f 87 57 ff ff ff    	ja     801039b5 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a5e:	90                   	nop
80103a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a62:	c9                   	leave  
80103a63:	c3                   	ret    

80103a64 <mmap>:
#include "mmu.h"
#include "proc.h"

int
mmap(int fd, int mode, char ** addr )
{
80103a64:	55                   	push   %ebp
80103a65:	89 e5                	mov    %esp,%ebp
80103a67:	83 ec 10             	sub    $0x10,%esp
  int indexommap;
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd>=0&&fd<NOFILE&&proc->ofile[fd]!=0){
80103a6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103a6e:	78 36                	js     80103aa6 <mmap+0x42>
80103a70:	83 7d 08 0f          	cmpl   $0xf,0x8(%ebp)
80103a74:	7f 30                	jg     80103aa6 <mmap+0x42>
80103a76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7f:	83 c2 08             	add    $0x8,%edx
80103a82:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103a86:	85 c0                	test   %eax,%eax
80103a88:	74 1c                	je     80103aa6 <mmap+0x42>
    fileformap=proc->ofile[fd];
80103a8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a90:	8b 55 08             	mov    0x8(%ebp),%edx
80103a93:	83 c2 08             	add    $0x8,%edx
80103a96:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103a9a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
80103a9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103aa4:	eb 25                	jmp    80103acb <mmap+0x67>
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd>=0&&fd<NOFILE&&proc->ofile[fd]!=0){
    fileformap=proc->ofile[fd];
  }else{
    return -1;
80103aa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103aab:	e9 e4 00 00 00       	jmp    80103b94 <mmap+0x130>
  }
  //buscar espacio libre en ommap
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
    if(proc->ommap[indexommap].pfile==0){
80103ab0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ab6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ab9:	83 c2 0a             	add    $0xa,%edx
80103abc:	c1 e2 04             	shl    $0x4,%edx
80103abf:	01 d0                	add    %edx,%eax
80103ac1:	8b 00                	mov    (%eax),%eax
80103ac3:	85 c0                	test   %eax,%eax
80103ac5:	74 0c                	je     80103ad3 <mmap+0x6f>
    fileformap=proc->ofile[fd];
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
80103ac7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103acb:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80103acf:	7e df                	jle    80103ab0 <mmap+0x4c>
80103ad1:	eb 01                	jmp    80103ad4 <mmap+0x70>
    if(proc->ommap[indexommap].pfile==0){
      break;
80103ad3:	90                   	nop
    }
  }

  //guardar estructura
  if(indexommap<MAXMAPPEDFILES){
80103ad4:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80103ad8:	0f 8f b1 00 00 00    	jg     80103b8f <mmap+0x12b>

    proc->ommap[indexommap].pfile=fileformap;
80103ade:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ae4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ae7:	83 c2 0a             	add    $0xa,%edx
80103aea:	c1 e2 04             	shl    $0x4,%edx
80103aed:	01 c2                	add    %eax,%edx
80103aef:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103af2:	89 02                	mov    %eax,(%edx)
    proc->ommap[indexommap].mode = mode;
80103af4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103afa:	8b 55 0c             	mov    0xc(%ebp),%edx
80103afd:	89 d1                	mov    %edx,%ecx
80103aff:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b02:	83 c2 0a             	add    $0xa,%edx
80103b05:	c1 e2 04             	shl    $0x4,%edx
80103b08:	01 d0                	add    %edx,%eax
80103b0a:	83 c0 0c             	add    $0xc,%eax
80103b0d:	66 89 08             	mov    %cx,(%eax)
    proc->ommap[indexommap].sz = fileformap->ip->size;
80103b10:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103b1a:	8b 40 10             	mov    0x10(%eax),%eax
80103b1d:	8b 40 18             	mov    0x18(%eax),%eax
80103b20:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80103b23:	83 c1 0a             	add    $0xa,%ecx
80103b26:	c1 e1 04             	shl    $0x4,%ecx
80103b29:	01 ca                	add    %ecx,%edx
80103b2b:	83 c2 08             	add    $0x8,%edx
80103b2e:	89 02                	mov    %eax,(%edx)

    proc->ommap[indexommap].va=proc->sz;
80103b30:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b3d:	8b 00                	mov    (%eax),%eax
80103b3f:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80103b42:	83 c1 0a             	add    $0xa,%ecx
80103b45:	c1 e1 04             	shl    $0x4,%ecx
80103b48:	01 ca                	add    %ecx,%edx
80103b4a:	83 c2 04             	add    $0x4,%edx
80103b4d:	89 02                	mov    %eax,(%edx)
    proc->sz =proc->sz+fileformap->ip->size;
80103b4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b55:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b5c:	8b 0a                	mov    (%edx),%ecx
80103b5e:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103b61:	8b 52 10             	mov    0x10(%edx),%edx
80103b64:	8b 52 18             	mov    0x18(%edx),%edx
80103b67:	01 ca                	add    %ecx,%edx
80103b69:	89 10                	mov    %edx,(%eax)

    //*adrr = dir de memoria virtual donde empieza el archivo
    *addr =(void *) proc->ommap[indexommap].va;
80103b6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b71:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b74:	83 c2 0a             	add    $0xa,%edx
80103b77:	c1 e2 04             	shl    $0x4,%edx
80103b7a:	01 d0                	add    %edx,%eax
80103b7c:	83 c0 04             	add    $0x4,%eax
80103b7f:	8b 00                	mov    (%eax),%eax
80103b81:	89 c2                	mov    %eax,%edx
80103b83:	8b 45 10             	mov    0x10(%ebp),%eax
80103b86:	89 10                	mov    %edx,(%eax)

    return 0;
80103b88:	b8 00 00 00 00       	mov    $0x0,%eax
80103b8d:	eb 05                	jmp    80103b94 <mmap+0x130>

  }else{
    return -2;
80103b8f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  }




}
80103b94:	c9                   	leave  
80103b95:	c3                   	ret    

80103b96 <munmap>:

int
munmap(char * addr)
{
80103b96:	55                   	push   %ebp
80103b97:	89 e5                	mov    %esp,%ebp
 //buscar  ommap que archivo mapeado usa esa direccion de mem
 //verificar paginas dirty,y guardar cada pagina dirty en el archivo
return 0;
80103b99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b9e:	5d                   	pop    %ebp
80103b9f:	c3                   	ret    

80103ba0 <p2v>:
80103ba0:	55                   	push   %ebp
80103ba1:	89 e5                	mov    %esp,%ebp
80103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba6:	05 00 00 00 80       	add    $0x80000000,%eax
80103bab:	5d                   	pop    %ebp
80103bac:	c3                   	ret    

80103bad <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 14             	sub    $0x14,%esp
80103bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103bba:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103bbe:	89 c2                	mov    %eax,%edx
80103bc0:	ec                   	in     (%dx),%al
80103bc1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103bc4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103bc8:	c9                   	leave  
80103bc9:	c3                   	ret    

80103bca <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103bca:	55                   	push   %ebp
80103bcb:	89 e5                	mov    %esp,%ebp
80103bcd:	83 ec 08             	sub    $0x8,%esp
80103bd0:	8b 55 08             	mov    0x8(%ebp),%edx
80103bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bd6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103bda:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103bdd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103be1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103be5:	ee                   	out    %al,(%dx)
}
80103be6:	90                   	nop
80103be7:	c9                   	leave  
80103be8:	c3                   	ret    

80103be9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103be9:	55                   	push   %ebp
80103bea:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103bec:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103bf1:	89 c2                	mov    %eax,%edx
80103bf3:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103bf8:	29 c2                	sub    %eax,%edx
80103bfa:	89 d0                	mov    %edx,%eax
80103bfc:	c1 f8 02             	sar    $0x2,%eax
80103bff:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103c05:	5d                   	pop    %ebp
80103c06:	c3                   	ret    

80103c07 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103c07:	55                   	push   %ebp
80103c08:	89 e5                	mov    %esp,%ebp
80103c0a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c14:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c1b:	eb 15                	jmp    80103c32 <sum+0x2b>
    sum += addr[i];
80103c1d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c20:	8b 45 08             	mov    0x8(%ebp),%eax
80103c23:	01 d0                	add    %edx,%eax
80103c25:	0f b6 00             	movzbl (%eax),%eax
80103c28:	0f b6 c0             	movzbl %al,%eax
80103c2b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103c2e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c35:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c38:	7c e3                	jl     80103c1d <sum+0x16>
    sum += addr[i];
  return sum;
80103c3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c3d:	c9                   	leave  
80103c3e:	c3                   	ret    

80103c3f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c3f:	55                   	push   %ebp
80103c40:	89 e5                	mov    %esp,%ebp
80103c42:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103c45:	ff 75 08             	pushl  0x8(%ebp)
80103c48:	e8 53 ff ff ff       	call   80103ba0 <p2v>
80103c4d:	83 c4 04             	add    $0x4,%esp
80103c50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c53:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c59:	01 d0                	add    %edx,%eax
80103c5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c64:	eb 36                	jmp    80103c9c <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c66:	83 ec 04             	sub    $0x4,%esp
80103c69:	6a 04                	push   $0x4
80103c6b:	68 38 95 10 80       	push   $0x80109538
80103c70:	ff 75 f4             	pushl  -0xc(%ebp)
80103c73:	e8 c0 1f 00 00       	call   80105c38 <memcmp>
80103c78:	83 c4 10             	add    $0x10,%esp
80103c7b:	85 c0                	test   %eax,%eax
80103c7d:	75 19                	jne    80103c98 <mpsearch1+0x59>
80103c7f:	83 ec 08             	sub    $0x8,%esp
80103c82:	6a 10                	push   $0x10
80103c84:	ff 75 f4             	pushl  -0xc(%ebp)
80103c87:	e8 7b ff ff ff       	call   80103c07 <sum>
80103c8c:	83 c4 10             	add    $0x10,%esp
80103c8f:	84 c0                	test   %al,%al
80103c91:	75 05                	jne    80103c98 <mpsearch1+0x59>
      return (struct mp*)p;
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	eb 11                	jmp    80103ca9 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c98:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ca2:	72 c2                	jb     80103c66 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ca9:	c9                   	leave  
80103caa:	c3                   	ret    

80103cab <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cab:	55                   	push   %ebp
80103cac:	89 e5                	mov    %esp,%ebp
80103cae:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cb1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbb:	83 c0 0f             	add    $0xf,%eax
80103cbe:	0f b6 00             	movzbl (%eax),%eax
80103cc1:	0f b6 c0             	movzbl %al,%eax
80103cc4:	c1 e0 08             	shl    $0x8,%eax
80103cc7:	89 c2                	mov    %eax,%edx
80103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccc:	83 c0 0e             	add    $0xe,%eax
80103ccf:	0f b6 00             	movzbl (%eax),%eax
80103cd2:	0f b6 c0             	movzbl %al,%eax
80103cd5:	09 d0                	or     %edx,%eax
80103cd7:	c1 e0 04             	shl    $0x4,%eax
80103cda:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103cdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ce1:	74 21                	je     80103d04 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ce3:	83 ec 08             	sub    $0x8,%esp
80103ce6:	68 00 04 00 00       	push   $0x400
80103ceb:	ff 75 f0             	pushl  -0x10(%ebp)
80103cee:	e8 4c ff ff ff       	call   80103c3f <mpsearch1>
80103cf3:	83 c4 10             	add    $0x10,%esp
80103cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cf9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cfd:	74 51                	je     80103d50 <mpsearch+0xa5>
      return mp;
80103cff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d02:	eb 61                	jmp    80103d65 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d07:	83 c0 14             	add    $0x14,%eax
80103d0a:	0f b6 00             	movzbl (%eax),%eax
80103d0d:	0f b6 c0             	movzbl %al,%eax
80103d10:	c1 e0 08             	shl    $0x8,%eax
80103d13:	89 c2                	mov    %eax,%edx
80103d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d18:	83 c0 13             	add    $0x13,%eax
80103d1b:	0f b6 00             	movzbl (%eax),%eax
80103d1e:	0f b6 c0             	movzbl %al,%eax
80103d21:	09 d0                	or     %edx,%eax
80103d23:	c1 e0 0a             	shl    $0xa,%eax
80103d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2c:	2d 00 04 00 00       	sub    $0x400,%eax
80103d31:	83 ec 08             	sub    $0x8,%esp
80103d34:	68 00 04 00 00       	push   $0x400
80103d39:	50                   	push   %eax
80103d3a:	e8 00 ff ff ff       	call   80103c3f <mpsearch1>
80103d3f:	83 c4 10             	add    $0x10,%esp
80103d42:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d45:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d49:	74 05                	je     80103d50 <mpsearch+0xa5>
      return mp;
80103d4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d4e:	eb 15                	jmp    80103d65 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d50:	83 ec 08             	sub    $0x8,%esp
80103d53:	68 00 00 01 00       	push   $0x10000
80103d58:	68 00 00 0f 00       	push   $0xf0000
80103d5d:	e8 dd fe ff ff       	call   80103c3f <mpsearch1>
80103d62:	83 c4 10             	add    $0x10,%esp
}
80103d65:	c9                   	leave  
80103d66:	c3                   	ret    

80103d67 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d67:	55                   	push   %ebp
80103d68:	89 e5                	mov    %esp,%ebp
80103d6a:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d6d:	e8 39 ff ff ff       	call   80103cab <mpsearch>
80103d72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d79:	74 0a                	je     80103d85 <mpconfig+0x1e>
80103d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7e:	8b 40 04             	mov    0x4(%eax),%eax
80103d81:	85 c0                	test   %eax,%eax
80103d83:	75 0a                	jne    80103d8f <mpconfig+0x28>
    return 0;
80103d85:	b8 00 00 00 00       	mov    $0x0,%eax
80103d8a:	e9 81 00 00 00       	jmp    80103e10 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d92:	8b 40 04             	mov    0x4(%eax),%eax
80103d95:	83 ec 0c             	sub    $0xc,%esp
80103d98:	50                   	push   %eax
80103d99:	e8 02 fe ff ff       	call   80103ba0 <p2v>
80103d9e:	83 c4 10             	add    $0x10,%esp
80103da1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103da4:	83 ec 04             	sub    $0x4,%esp
80103da7:	6a 04                	push   $0x4
80103da9:	68 3d 95 10 80       	push   $0x8010953d
80103dae:	ff 75 f0             	pushl  -0x10(%ebp)
80103db1:	e8 82 1e 00 00       	call   80105c38 <memcmp>
80103db6:	83 c4 10             	add    $0x10,%esp
80103db9:	85 c0                	test   %eax,%eax
80103dbb:	74 07                	je     80103dc4 <mpconfig+0x5d>
    return 0;
80103dbd:	b8 00 00 00 00       	mov    $0x0,%eax
80103dc2:	eb 4c                	jmp    80103e10 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dcb:	3c 01                	cmp    $0x1,%al
80103dcd:	74 12                	je     80103de1 <mpconfig+0x7a>
80103dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd2:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dd6:	3c 04                	cmp    $0x4,%al
80103dd8:	74 07                	je     80103de1 <mpconfig+0x7a>
    return 0;
80103dda:	b8 00 00 00 00       	mov    $0x0,%eax
80103ddf:	eb 2f                	jmp    80103e10 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103de8:	0f b7 c0             	movzwl %ax,%eax
80103deb:	83 ec 08             	sub    $0x8,%esp
80103dee:	50                   	push   %eax
80103def:	ff 75 f0             	pushl  -0x10(%ebp)
80103df2:	e8 10 fe ff ff       	call   80103c07 <sum>
80103df7:	83 c4 10             	add    $0x10,%esp
80103dfa:	84 c0                	test   %al,%al
80103dfc:	74 07                	je     80103e05 <mpconfig+0x9e>
    return 0;
80103dfe:	b8 00 00 00 00       	mov    $0x0,%eax
80103e03:	eb 0b                	jmp    80103e10 <mpconfig+0xa9>
  *pmp = mp;
80103e05:	8b 45 08             	mov    0x8(%ebp),%eax
80103e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e0b:	89 10                	mov    %edx,(%eax)
  return conf;
80103e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e10:	c9                   	leave  
80103e11:	c3                   	ret    

80103e12 <mpinit>:

void
mpinit(void)
{
80103e12:	55                   	push   %ebp
80103e13:	89 e5                	mov    %esp,%ebp
80103e15:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103e18:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103e1f:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103e28:	50                   	push   %eax
80103e29:	e8 39 ff ff ff       	call   80103d67 <mpconfig>
80103e2e:	83 c4 10             	add    $0x10,%esp
80103e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e38:	0f 84 96 01 00 00    	je     80103fd4 <mpinit+0x1c2>
    return;
  ismp = 1;
80103e3e:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103e45:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4b:	8b 40 24             	mov    0x24(%eax),%eax
80103e4e:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e56:	83 c0 2c             	add    $0x2c,%eax
80103e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e5f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e63:	0f b7 d0             	movzwl %ax,%edx
80103e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e69:	01 d0                	add    %edx,%eax
80103e6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e6e:	e9 f2 00 00 00       	jmp    80103f65 <mpinit+0x153>
    switch(*p){
80103e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e76:	0f b6 00             	movzbl (%eax),%eax
80103e79:	0f b6 c0             	movzbl %al,%eax
80103e7c:	83 f8 04             	cmp    $0x4,%eax
80103e7f:	0f 87 bc 00 00 00    	ja     80103f41 <mpinit+0x12f>
80103e85:	8b 04 85 80 95 10 80 	mov    -0x7fef6a80(,%eax,4),%eax
80103e8c:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e91:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e97:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e9b:	0f b6 d0             	movzbl %al,%edx
80103e9e:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ea3:	39 c2                	cmp    %eax,%edx
80103ea5:	74 2b                	je     80103ed2 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103ea7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103eaa:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103eae:	0f b6 d0             	movzbl %al,%edx
80103eb1:	a1 60 39 11 80       	mov    0x80113960,%eax
80103eb6:	83 ec 04             	sub    $0x4,%esp
80103eb9:	52                   	push   %edx
80103eba:	50                   	push   %eax
80103ebb:	68 42 95 10 80       	push   $0x80109542
80103ec0:	e8 01 c5 ff ff       	call   801003c6 <cprintf>
80103ec5:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103ec8:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103ecf:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ed5:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103ed9:	0f b6 c0             	movzbl %al,%eax
80103edc:	83 e0 02             	and    $0x2,%eax
80103edf:	85 c0                	test   %eax,%eax
80103ee1:	74 15                	je     80103ef8 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103ee3:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ee8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103eee:	05 80 33 11 80       	add    $0x80113380,%eax
80103ef3:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103ef8:	a1 60 39 11 80       	mov    0x80113960,%eax
80103efd:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103f03:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103f09:	05 80 33 11 80       	add    $0x80113380,%eax
80103f0e:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103f10:	a1 60 39 11 80       	mov    0x80113960,%eax
80103f15:	83 c0 01             	add    $0x1,%eax
80103f18:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103f1d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f21:	eb 42                	jmp    80103f65 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f2c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f30:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103f35:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f39:	eb 2a                	jmp    80103f65 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f3b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f3f:	eb 24                	jmp    80103f65 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f44:	0f b6 00             	movzbl (%eax),%eax
80103f47:	0f b6 c0             	movzbl %al,%eax
80103f4a:	83 ec 08             	sub    $0x8,%esp
80103f4d:	50                   	push   %eax
80103f4e:	68 60 95 10 80       	push   $0x80109560
80103f53:	e8 6e c4 ff ff       	call   801003c6 <cprintf>
80103f58:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103f5b:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103f62:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f68:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f6b:	0f 82 02 ff ff ff    	jb     80103e73 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103f71:	a1 64 33 11 80       	mov    0x80113364,%eax
80103f76:	85 c0                	test   %eax,%eax
80103f78:	75 1d                	jne    80103f97 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f7a:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f81:	00 00 00 
    lapic = 0;
80103f84:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f8b:	00 00 00 
    ioapicid = 0;
80103f8e:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f95:	eb 3e                	jmp    80103fd5 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f9e:	84 c0                	test   %al,%al
80103fa0:	74 33                	je     80103fd5 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fa2:	83 ec 08             	sub    $0x8,%esp
80103fa5:	6a 70                	push   $0x70
80103fa7:	6a 22                	push   $0x22
80103fa9:	e8 1c fc ff ff       	call   80103bca <outb>
80103fae:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fb1:	83 ec 0c             	sub    $0xc,%esp
80103fb4:	6a 23                	push   $0x23
80103fb6:	e8 f2 fb ff ff       	call   80103bad <inb>
80103fbb:	83 c4 10             	add    $0x10,%esp
80103fbe:	83 c8 01             	or     $0x1,%eax
80103fc1:	0f b6 c0             	movzbl %al,%eax
80103fc4:	83 ec 08             	sub    $0x8,%esp
80103fc7:	50                   	push   %eax
80103fc8:	6a 23                	push   $0x23
80103fca:	e8 fb fb ff ff       	call   80103bca <outb>
80103fcf:	83 c4 10             	add    $0x10,%esp
80103fd2:	eb 01                	jmp    80103fd5 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103fd4:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103fd5:	c9                   	leave  
80103fd6:	c3                   	ret    

80103fd7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103fd7:	55                   	push   %ebp
80103fd8:	89 e5                	mov    %esp,%ebp
80103fda:	83 ec 08             	sub    $0x8,%esp
80103fdd:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103fe7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103fea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ff2:	ee                   	out    %al,(%dx)
}
80103ff3:	90                   	nop
80103ff4:	c9                   	leave  
80103ff5:	c3                   	ret    

80103ff6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ff6:	55                   	push   %ebp
80103ff7:	89 e5                	mov    %esp,%ebp
80103ff9:	83 ec 04             	sub    $0x4,%esp
80103ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104003:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104007:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
8010400d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104011:	0f b6 c0             	movzbl %al,%eax
80104014:	50                   	push   %eax
80104015:	6a 21                	push   $0x21
80104017:	e8 bb ff ff ff       	call   80103fd7 <outb>
8010401c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010401f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104023:	66 c1 e8 08          	shr    $0x8,%ax
80104027:	0f b6 c0             	movzbl %al,%eax
8010402a:	50                   	push   %eax
8010402b:	68 a1 00 00 00       	push   $0xa1
80104030:	e8 a2 ff ff ff       	call   80103fd7 <outb>
80104035:	83 c4 08             	add    $0x8,%esp
}
80104038:	90                   	nop
80104039:	c9                   	leave  
8010403a:	c3                   	ret    

8010403b <picenable>:

void
picenable(int irq)
{
8010403b:	55                   	push   %ebp
8010403c:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	ba 01 00 00 00       	mov    $0x1,%edx
80104046:	89 c1                	mov    %eax,%ecx
80104048:	d3 e2                	shl    %cl,%edx
8010404a:	89 d0                	mov    %edx,%eax
8010404c:	f7 d0                	not    %eax
8010404e:	89 c2                	mov    %eax,%edx
80104050:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104057:	21 d0                	and    %edx,%eax
80104059:	0f b7 c0             	movzwl %ax,%eax
8010405c:	50                   	push   %eax
8010405d:	e8 94 ff ff ff       	call   80103ff6 <picsetmask>
80104062:	83 c4 04             	add    $0x4,%esp
}
80104065:	90                   	nop
80104066:	c9                   	leave  
80104067:	c3                   	ret    

80104068 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104068:	55                   	push   %ebp
80104069:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010406b:	68 ff 00 00 00       	push   $0xff
80104070:	6a 21                	push   $0x21
80104072:	e8 60 ff ff ff       	call   80103fd7 <outb>
80104077:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010407a:	68 ff 00 00 00       	push   $0xff
8010407f:	68 a1 00 00 00       	push   $0xa1
80104084:	e8 4e ff ff ff       	call   80103fd7 <outb>
80104089:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010408c:	6a 11                	push   $0x11
8010408e:	6a 20                	push   $0x20
80104090:	e8 42 ff ff ff       	call   80103fd7 <outb>
80104095:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104098:	6a 20                	push   $0x20
8010409a:	6a 21                	push   $0x21
8010409c:	e8 36 ff ff ff       	call   80103fd7 <outb>
801040a1:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801040a4:	6a 04                	push   $0x4
801040a6:	6a 21                	push   $0x21
801040a8:	e8 2a ff ff ff       	call   80103fd7 <outb>
801040ad:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801040b0:	6a 03                	push   $0x3
801040b2:	6a 21                	push   $0x21
801040b4:	e8 1e ff ff ff       	call   80103fd7 <outb>
801040b9:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801040bc:	6a 11                	push   $0x11
801040be:	68 a0 00 00 00       	push   $0xa0
801040c3:	e8 0f ff ff ff       	call   80103fd7 <outb>
801040c8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801040cb:	6a 28                	push   $0x28
801040cd:	68 a1 00 00 00       	push   $0xa1
801040d2:	e8 00 ff ff ff       	call   80103fd7 <outb>
801040d7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801040da:	6a 02                	push   $0x2
801040dc:	68 a1 00 00 00       	push   $0xa1
801040e1:	e8 f1 fe ff ff       	call   80103fd7 <outb>
801040e6:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801040e9:	6a 03                	push   $0x3
801040eb:	68 a1 00 00 00       	push   $0xa1
801040f0:	e8 e2 fe ff ff       	call   80103fd7 <outb>
801040f5:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801040f8:	6a 68                	push   $0x68
801040fa:	6a 20                	push   $0x20
801040fc:	e8 d6 fe ff ff       	call   80103fd7 <outb>
80104101:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104104:	6a 0a                	push   $0xa
80104106:	6a 20                	push   $0x20
80104108:	e8 ca fe ff ff       	call   80103fd7 <outb>
8010410d:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104110:	6a 68                	push   $0x68
80104112:	68 a0 00 00 00       	push   $0xa0
80104117:	e8 bb fe ff ff       	call   80103fd7 <outb>
8010411c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010411f:	6a 0a                	push   $0xa
80104121:	68 a0 00 00 00       	push   $0xa0
80104126:	e8 ac fe ff ff       	call   80103fd7 <outb>
8010412b:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010412e:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104135:	66 83 f8 ff          	cmp    $0xffff,%ax
80104139:	74 13                	je     8010414e <picinit+0xe6>
    picsetmask(irqmask);
8010413b:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104142:	0f b7 c0             	movzwl %ax,%eax
80104145:	50                   	push   %eax
80104146:	e8 ab fe ff ff       	call   80103ff6 <picsetmask>
8010414b:	83 c4 04             	add    $0x4,%esp
}
8010414e:	90                   	nop
8010414f:	c9                   	leave  
80104150:	c3                   	ret    

80104151 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104151:	55                   	push   %ebp
80104152:	89 e5                	mov    %esp,%ebp
80104154:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104157:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010415e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104161:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104167:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416a:	8b 10                	mov    (%eax),%edx
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104171:	e8 0a ce ff ff       	call   80100f80 <filealloc>
80104176:	89 c2                	mov    %eax,%edx
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	89 10                	mov    %edx,(%eax)
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	8b 00                	mov    (%eax),%eax
80104182:	85 c0                	test   %eax,%eax
80104184:	0f 84 cb 00 00 00    	je     80104255 <pipealloc+0x104>
8010418a:	e8 f1 cd ff ff       	call   80100f80 <filealloc>
8010418f:	89 c2                	mov    %eax,%edx
80104191:	8b 45 0c             	mov    0xc(%ebp),%eax
80104194:	89 10                	mov    %edx,(%eax)
80104196:	8b 45 0c             	mov    0xc(%ebp),%eax
80104199:	8b 00                	mov    (%eax),%eax
8010419b:	85 c0                	test   %eax,%eax
8010419d:	0f 84 b2 00 00 00    	je     80104255 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801041a3:	e8 80 ea ff ff       	call   80102c28 <kalloc>
801041a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041af:	0f 84 9f 00 00 00    	je     80104254 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801041b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801041bf:	00 00 00 
  p->writeopen = 1;
801041c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801041cc:	00 00 00 
  p->nwrite = 0;
801041cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801041d9:	00 00 00 
  p->nread = 0;
801041dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041df:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801041e6:	00 00 00 
  initlock(&p->lock, "pipe");
801041e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ec:	83 ec 08             	sub    $0x8,%esp
801041ef:	68 94 95 10 80       	push   $0x80109594
801041f4:	50                   	push   %eax
801041f5:	e8 52 17 00 00       	call   8010594c <initlock>
801041fa:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801041fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104200:	8b 00                	mov    (%eax),%eax
80104202:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104208:	8b 45 08             	mov    0x8(%ebp),%eax
8010420b:	8b 00                	mov    (%eax),%eax
8010420d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104211:	8b 45 08             	mov    0x8(%ebp),%eax
80104214:	8b 00                	mov    (%eax),%eax
80104216:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010421a:	8b 45 08             	mov    0x8(%ebp),%eax
8010421d:	8b 00                	mov    (%eax),%eax
8010421f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104222:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104225:	8b 45 0c             	mov    0xc(%ebp),%eax
80104228:	8b 00                	mov    (%eax),%eax
8010422a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104230:	8b 45 0c             	mov    0xc(%ebp),%eax
80104233:	8b 00                	mov    (%eax),%eax
80104235:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104239:	8b 45 0c             	mov    0xc(%ebp),%eax
8010423c:	8b 00                	mov    (%eax),%eax
8010423e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104242:	8b 45 0c             	mov    0xc(%ebp),%eax
80104245:	8b 00                	mov    (%eax),%eax
80104247:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010424d:	b8 00 00 00 00       	mov    $0x0,%eax
80104252:	eb 4e                	jmp    801042a2 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104254:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104259:	74 0e                	je     80104269 <pipealloc+0x118>
    kfree((char*)p);
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	ff 75 f4             	pushl  -0xc(%ebp)
80104261:	e8 25 e9 ff ff       	call   80102b8b <kfree>
80104266:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104269:	8b 45 08             	mov    0x8(%ebp),%eax
8010426c:	8b 00                	mov    (%eax),%eax
8010426e:	85 c0                	test   %eax,%eax
80104270:	74 11                	je     80104283 <pipealloc+0x132>
    fileclose(*f0);
80104272:	8b 45 08             	mov    0x8(%ebp),%eax
80104275:	8b 00                	mov    (%eax),%eax
80104277:	83 ec 0c             	sub    $0xc,%esp
8010427a:	50                   	push   %eax
8010427b:	e8 be cd ff ff       	call   8010103e <fileclose>
80104280:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104283:	8b 45 0c             	mov    0xc(%ebp),%eax
80104286:	8b 00                	mov    (%eax),%eax
80104288:	85 c0                	test   %eax,%eax
8010428a:	74 11                	je     8010429d <pipealloc+0x14c>
    fileclose(*f1);
8010428c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428f:	8b 00                	mov    (%eax),%eax
80104291:	83 ec 0c             	sub    $0xc,%esp
80104294:	50                   	push   %eax
80104295:	e8 a4 cd ff ff       	call   8010103e <fileclose>
8010429a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010429d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801042a2:	c9                   	leave  
801042a3:	c3                   	ret    

801042a4 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801042a4:	55                   	push   %ebp
801042a5:	89 e5                	mov    %esp,%ebp
801042a7:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801042aa:	8b 45 08             	mov    0x8(%ebp),%eax
801042ad:	83 ec 0c             	sub    $0xc,%esp
801042b0:	50                   	push   %eax
801042b1:	e8 b8 16 00 00       	call   8010596e <acquire>
801042b6:	83 c4 10             	add    $0x10,%esp
  if(writable){
801042b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042bd:	74 23                	je     801042e2 <pipeclose+0x3e>
    p->writeopen = 0;
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801042c9:	00 00 00 
    wakeup(&p->nread);
801042cc:	8b 45 08             	mov    0x8(%ebp),%eax
801042cf:	05 34 02 00 00       	add    $0x234,%eax
801042d4:	83 ec 0c             	sub    $0xc,%esp
801042d7:	50                   	push   %eax
801042d8:	e8 e1 0f 00 00       	call   801052be <wakeup>
801042dd:	83 c4 10             	add    $0x10,%esp
801042e0:	eb 21                	jmp    80104303 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801042e2:	8b 45 08             	mov    0x8(%ebp),%eax
801042e5:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801042ec:	00 00 00 
    wakeup(&p->nwrite);
801042ef:	8b 45 08             	mov    0x8(%ebp),%eax
801042f2:	05 38 02 00 00       	add    $0x238,%eax
801042f7:	83 ec 0c             	sub    $0xc,%esp
801042fa:	50                   	push   %eax
801042fb:	e8 be 0f 00 00       	call   801052be <wakeup>
80104300:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010430c:	85 c0                	test   %eax,%eax
8010430e:	75 2c                	jne    8010433c <pipeclose+0x98>
80104310:	8b 45 08             	mov    0x8(%ebp),%eax
80104313:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104319:	85 c0                	test   %eax,%eax
8010431b:	75 1f                	jne    8010433c <pipeclose+0x98>
    release(&p->lock);
8010431d:	8b 45 08             	mov    0x8(%ebp),%eax
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	50                   	push   %eax
80104324:	e8 ac 16 00 00       	call   801059d5 <release>
80104329:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010432c:	83 ec 0c             	sub    $0xc,%esp
8010432f:	ff 75 08             	pushl  0x8(%ebp)
80104332:	e8 54 e8 ff ff       	call   80102b8b <kfree>
80104337:	83 c4 10             	add    $0x10,%esp
8010433a:	eb 0f                	jmp    8010434b <pipeclose+0xa7>
  } else
    release(&p->lock);
8010433c:	8b 45 08             	mov    0x8(%ebp),%eax
8010433f:	83 ec 0c             	sub    $0xc,%esp
80104342:	50                   	push   %eax
80104343:	e8 8d 16 00 00       	call   801059d5 <release>
80104348:	83 c4 10             	add    $0x10,%esp
}
8010434b:	90                   	nop
8010434c:	c9                   	leave  
8010434d:	c3                   	ret    

8010434e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010434e:	55                   	push   %ebp
8010434f:	89 e5                	mov    %esp,%ebp
80104351:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104354:	8b 45 08             	mov    0x8(%ebp),%eax
80104357:	83 ec 0c             	sub    $0xc,%esp
8010435a:	50                   	push   %eax
8010435b:	e8 0e 16 00 00       	call   8010596e <acquire>
80104360:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104363:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010436a:	e9 ad 00 00 00       	jmp    8010441c <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010436f:	8b 45 08             	mov    0x8(%ebp),%eax
80104372:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104378:	85 c0                	test   %eax,%eax
8010437a:	74 0d                	je     80104389 <pipewrite+0x3b>
8010437c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104382:	8b 40 24             	mov    0x24(%eax),%eax
80104385:	85 c0                	test   %eax,%eax
80104387:	74 19                	je     801043a2 <pipewrite+0x54>
        release(&p->lock);
80104389:	8b 45 08             	mov    0x8(%ebp),%eax
8010438c:	83 ec 0c             	sub    $0xc,%esp
8010438f:	50                   	push   %eax
80104390:	e8 40 16 00 00       	call   801059d5 <release>
80104395:	83 c4 10             	add    $0x10,%esp
        return -1;
80104398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010439d:	e9 a8 00 00 00       	jmp    8010444a <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801043a2:	8b 45 08             	mov    0x8(%ebp),%eax
801043a5:	05 34 02 00 00       	add    $0x234,%eax
801043aa:	83 ec 0c             	sub    $0xc,%esp
801043ad:	50                   	push   %eax
801043ae:	e8 0b 0f 00 00       	call   801052be <wakeup>
801043b3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801043b6:	8b 45 08             	mov    0x8(%ebp),%eax
801043b9:	8b 55 08             	mov    0x8(%ebp),%edx
801043bc:	81 c2 38 02 00 00    	add    $0x238,%edx
801043c2:	83 ec 08             	sub    $0x8,%esp
801043c5:	50                   	push   %eax
801043c6:	52                   	push   %edx
801043c7:	e8 e6 0d 00 00       	call   801051b2 <sleep>
801043cc:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801043cf:	8b 45 08             	mov    0x8(%ebp),%eax
801043d2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801043d8:	8b 45 08             	mov    0x8(%ebp),%eax
801043db:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043e1:	05 00 02 00 00       	add    $0x200,%eax
801043e6:	39 c2                	cmp    %eax,%edx
801043e8:	74 85                	je     8010436f <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801043ea:	8b 45 08             	mov    0x8(%ebp),%eax
801043ed:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043f3:	8d 48 01             	lea    0x1(%eax),%ecx
801043f6:	8b 55 08             	mov    0x8(%ebp),%edx
801043f9:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801043ff:	25 ff 01 00 00       	and    $0x1ff,%eax
80104404:	89 c1                	mov    %eax,%ecx
80104406:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104409:	8b 45 0c             	mov    0xc(%ebp),%eax
8010440c:	01 d0                	add    %edx,%eax
8010440e:	0f b6 10             	movzbl (%eax),%edx
80104411:	8b 45 08             	mov    0x8(%ebp),%eax
80104414:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104418:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010441c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104422:	7c ab                	jl     801043cf <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104424:	8b 45 08             	mov    0x8(%ebp),%eax
80104427:	05 34 02 00 00       	add    $0x234,%eax
8010442c:	83 ec 0c             	sub    $0xc,%esp
8010442f:	50                   	push   %eax
80104430:	e8 89 0e 00 00       	call   801052be <wakeup>
80104435:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104438:	8b 45 08             	mov    0x8(%ebp),%eax
8010443b:	83 ec 0c             	sub    $0xc,%esp
8010443e:	50                   	push   %eax
8010443f:	e8 91 15 00 00       	call   801059d5 <release>
80104444:	83 c4 10             	add    $0x10,%esp
  return n;
80104447:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010444a:	c9                   	leave  
8010444b:	c3                   	ret    

8010444c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010444c:	55                   	push   %ebp
8010444d:	89 e5                	mov    %esp,%ebp
8010444f:	53                   	push   %ebx
80104450:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104453:	8b 45 08             	mov    0x8(%ebp),%eax
80104456:	83 ec 0c             	sub    $0xc,%esp
80104459:	50                   	push   %eax
8010445a:	e8 0f 15 00 00       	call   8010596e <acquire>
8010445f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104462:	eb 3f                	jmp    801044a3 <piperead+0x57>
    if(proc->killed){
80104464:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010446a:	8b 40 24             	mov    0x24(%eax),%eax
8010446d:	85 c0                	test   %eax,%eax
8010446f:	74 19                	je     8010448a <piperead+0x3e>
      release(&p->lock);
80104471:	8b 45 08             	mov    0x8(%ebp),%eax
80104474:	83 ec 0c             	sub    $0xc,%esp
80104477:	50                   	push   %eax
80104478:	e8 58 15 00 00       	call   801059d5 <release>
8010447d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104485:	e9 bf 00 00 00       	jmp    80104549 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010448a:	8b 45 08             	mov    0x8(%ebp),%eax
8010448d:	8b 55 08             	mov    0x8(%ebp),%edx
80104490:	81 c2 34 02 00 00    	add    $0x234,%edx
80104496:	83 ec 08             	sub    $0x8,%esp
80104499:	50                   	push   %eax
8010449a:	52                   	push   %edx
8010449b:	e8 12 0d 00 00       	call   801051b2 <sleep>
801044a0:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801044a3:	8b 45 08             	mov    0x8(%ebp),%eax
801044a6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801044ac:	8b 45 08             	mov    0x8(%ebp),%eax
801044af:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801044b5:	39 c2                	cmp    %eax,%edx
801044b7:	75 0d                	jne    801044c6 <piperead+0x7a>
801044b9:	8b 45 08             	mov    0x8(%ebp),%eax
801044bc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801044c2:	85 c0                	test   %eax,%eax
801044c4:	75 9e                	jne    80104464 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044cd:	eb 49                	jmp    80104518 <piperead+0xcc>
    if(p->nread == p->nwrite)
801044cf:	8b 45 08             	mov    0x8(%ebp),%eax
801044d2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801044d8:	8b 45 08             	mov    0x8(%ebp),%eax
801044db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801044e1:	39 c2                	cmp    %eax,%edx
801044e3:	74 3d                	je     80104522 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801044e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801044eb:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801044ee:	8b 45 08             	mov    0x8(%ebp),%eax
801044f1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801044f7:	8d 48 01             	lea    0x1(%eax),%ecx
801044fa:	8b 55 08             	mov    0x8(%ebp),%edx
801044fd:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104503:	25 ff 01 00 00       	and    $0x1ff,%eax
80104508:	89 c2                	mov    %eax,%edx
8010450a:	8b 45 08             	mov    0x8(%ebp),%eax
8010450d:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104512:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104514:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010451e:	7c af                	jl     801044cf <piperead+0x83>
80104520:	eb 01                	jmp    80104523 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104522:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104523:	8b 45 08             	mov    0x8(%ebp),%eax
80104526:	05 38 02 00 00       	add    $0x238,%eax
8010452b:	83 ec 0c             	sub    $0xc,%esp
8010452e:	50                   	push   %eax
8010452f:	e8 8a 0d 00 00       	call   801052be <wakeup>
80104534:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104537:	8b 45 08             	mov    0x8(%ebp),%eax
8010453a:	83 ec 0c             	sub    $0xc,%esp
8010453d:	50                   	push   %eax
8010453e:	e8 92 14 00 00       	call   801059d5 <release>
80104543:	83 c4 10             	add    $0x10,%esp
  return i;
80104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010454c:	c9                   	leave  
8010454d:	c3                   	ret    

8010454e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010454e:	55                   	push   %ebp
8010454f:	89 e5                	mov    %esp,%ebp
80104551:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104554:	9c                   	pushf  
80104555:	58                   	pop    %eax
80104556:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104559:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010455c:	c9                   	leave  
8010455d:	c3                   	ret    

8010455e <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010455e:	55                   	push   %ebp
8010455f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104561:	fb                   	sti    
}
80104562:	90                   	nop
80104563:	5d                   	pop    %ebp
80104564:	c3                   	ret    

80104565 <make_runnable>:
} ptable;

//enqueue the process in the corresponding priority
static void
make_runnable(struct proc* p)
{
80104565:	55                   	push   %ebp
80104566:	89 e5                	mov    %esp,%ebp
  if(ptable.mlf[p->priority].last==0){
80104568:	8b 45 08             	mov    0x8(%ebp),%eax
8010456b:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010456f:	0f b7 c0             	movzwl %ax,%eax
80104572:	05 86 07 00 00       	add    $0x786,%eax
80104577:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
8010457e:	85 c0                	test   %eax,%eax
80104580:	75 1c                	jne    8010459e <make_runnable+0x39>
    ptable.mlf[p->priority].first = p;
80104582:	8b 45 08             	mov    0x8(%ebp),%eax
80104585:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104589:	0f b7 c0             	movzwl %ax,%eax
8010458c:	8d 90 86 07 00 00    	lea    0x786(%eax),%edx
80104592:	8b 45 08             	mov    0x8(%ebp),%eax
80104595:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
8010459c:	eb 1f                	jmp    801045bd <make_runnable+0x58>
  } else{
    ptable.mlf[p->priority].last->next = p;
8010459e:	8b 45 08             	mov    0x8(%ebp),%eax
801045a1:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801045a5:	0f b7 c0             	movzwl %ax,%eax
801045a8:	05 86 07 00 00       	add    $0x786,%eax
801045ad:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
801045b4:	8b 55 08             	mov    0x8(%ebp),%edx
801045b7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
  ptable.mlf[p->priority].last=p;
801045bd:	8b 45 08             	mov    0x8(%ebp),%eax
801045c0:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801045c4:	0f b7 c0             	movzwl %ax,%eax
801045c7:	8d 90 86 07 00 00    	lea    0x786(%eax),%edx
801045cd:	8b 45 08             	mov    0x8(%ebp),%eax
801045d0:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
  p->next=0;
801045d7:	8b 45 08             	mov    0x8(%ebp),%eax
801045da:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801045e1:	00 00 00 
  p->age=0;
801045e4:	8b 45 08             	mov    0x8(%ebp),%eax
801045e7:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
801045ee:	00 00 
  p->state=RUNNABLE;
801045f0:	8b 45 08             	mov    0x8(%ebp),%eax
801045f3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045fa:	90                   	nop
801045fb:	5d                   	pop    %ebp
801045fc:	c3                   	ret    

801045fd <unqueue>:

//dequeue first element of the level "level"
static struct proc*
unqueue(int level)
{
801045fd:	55                   	push   %ebp
801045fe:	89 e5                	mov    %esp,%ebp
80104600:	83 ec 18             	sub    $0x18,%esp
  struct proc* p=ptable.mlf[level].first;
80104603:	8b 45 08             	mov    0x8(%ebp),%eax
80104606:	05 86 07 00 00       	add    $0x786,%eax
8010460b:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104612:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!ptable.mlf[level].first)
80104615:	8b 45 08             	mov    0x8(%ebp),%eax
80104618:	05 86 07 00 00       	add    $0x786,%eax
8010461d:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104624:	85 c0                	test   %eax,%eax
80104626:	75 0d                	jne    80104635 <unqueue+0x38>
    panic("empty level");
80104628:	83 ec 0c             	sub    $0xc,%esp
8010462b:	68 9c 95 10 80       	push   $0x8010959c
80104630:	e8 31 bf ff ff       	call   80100566 <panic>
  if(ptable.mlf[level].first==ptable.mlf[level].last){
80104635:	8b 45 08             	mov    0x8(%ebp),%eax
80104638:	05 86 07 00 00       	add    $0x786,%eax
8010463d:	8b 14 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%edx
80104644:	8b 45 08             	mov    0x8(%ebp),%eax
80104647:	05 86 07 00 00       	add    $0x786,%eax
8010464c:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
80104653:	39 c2                	cmp    %eax,%edx
80104655:	75 34                	jne    8010468b <unqueue+0x8e>
    ptable.mlf[level].last = ptable.mlf[level].first = 0;
80104657:	8b 45 08             	mov    0x8(%ebp),%eax
8010465a:	05 86 07 00 00       	add    $0x786,%eax
8010465f:	c7 04 c5 84 39 11 80 	movl   $0x0,-0x7feec67c(,%eax,8)
80104666:	00 00 00 00 
8010466a:	8b 45 08             	mov    0x8(%ebp),%eax
8010466d:	05 86 07 00 00       	add    $0x786,%eax
80104672:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104679:	8b 55 08             	mov    0x8(%ebp),%edx
8010467c:	81 c2 86 07 00 00    	add    $0x786,%edx
80104682:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
80104689:	eb 19                	jmp    801046a4 <unqueue+0xa7>
  }else{
    ptable.mlf[level].first=p->next;
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104694:	8b 55 08             	mov    0x8(%ebp),%edx
80104697:	81 c2 86 07 00 00    	add    $0x786,%edx
8010469d:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
  }
  if(p->state!=RUNNABLE)
801046a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a7:	8b 40 0c             	mov    0xc(%eax),%eax
801046aa:	83 f8 03             	cmp    $0x3,%eax
801046ad:	74 0d                	je     801046bc <unqueue+0xbf>
    panic("unqueue not RUNNABLE process");
801046af:	83 ec 0c             	sub    $0xc,%esp
801046b2:	68 a8 95 10 80       	push   $0x801095a8
801046b7:	e8 aa be ff ff       	call   80100566 <panic>
  return p;
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046bf:	c9                   	leave  
801046c0:	c3                   	ret    

801046c1 <levelupdate>:

//unqueue the process, it increases the priority if it corresponds, and queues it in the new level.
static void
levelupdate(struct proc* p)
{
801046c1:	55                   	push   %ebp
801046c2:	89 e5                	mov    %esp,%ebp
801046c4:	83 ec 08             	sub    $0x8,%esp
  unqueue(p->priority);
801046c7:	8b 45 08             	mov    0x8(%ebp),%eax
801046ca:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046ce:	0f b7 c0             	movzwl %ax,%eax
801046d1:	83 ec 0c             	sub    $0xc,%esp
801046d4:	50                   	push   %eax
801046d5:	e8 23 ff ff ff       	call   801045fd <unqueue>
801046da:	83 c4 10             	add    $0x10,%esp
  if(p->priority>MLFMAXPRIORITY)
801046dd:	8b 45 08             	mov    0x8(%ebp),%eax
801046e0:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046e4:	66 85 c0             	test   %ax,%ax
801046e7:	74 11                	je     801046fa <levelupdate+0x39>
    p->priority--;
801046e9:	8b 45 08             	mov    0x8(%ebp),%eax
801046ec:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046f0:	8d 50 ff             	lea    -0x1(%eax),%edx
801046f3:	8b 45 08             	mov    0x8(%ebp),%eax
801046f6:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(p);
801046fa:	83 ec 0c             	sub    $0xc,%esp
801046fd:	ff 75 08             	pushl  0x8(%ebp)
80104700:	e8 60 fe ff ff       	call   80104565 <make_runnable>
80104705:	83 c4 10             	add    $0x10,%esp
}
80104708:	90                   	nop
80104709:	c9                   	leave  
8010470a:	c3                   	ret    

8010470b <calculateaging>:

//go through MLF, looking for processes that reach AGEFORAGINGS and raise the priority.
//call procdump to show them.
void
calculateaging(void)
{
8010470b:	55                   	push   %ebp
8010470c:	89 e5                	mov    %esp,%ebp
8010470e:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  int l;
  acquire(&ptable.lock);
80104711:	83 ec 0c             	sub    $0xc,%esp
80104714:	68 80 39 11 80       	push   $0x80113980
80104719:	e8 50 12 00 00       	call   8010596e <acquire>
8010471e:	83 c4 10             	add    $0x10,%esp
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104728:	e9 a7 00 00 00       	jmp    801047d4 <calculateaging+0xc9>
    p=ptable.mlf[l].first;
8010472d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104730:	05 86 07 00 00       	add    $0x786,%eax
80104735:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
8010473c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p){
8010473f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104743:	0f 84 87 00 00 00    	je     801047d0 <calculateaging+0xc5>
      p->age++;  // increase the age to the process
80104749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010474c:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104753:	8d 50 01             	lea    0x1(%eax),%edx
80104756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104759:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      //procdump();
      if(p->age == AGEFORAGINGS){
80104760:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104763:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
8010476a:	66 83 f8 05          	cmp    $0x5,%ax
8010476e:	75 60                	jne    801047d0 <calculateaging+0xc5>
        if(ptable.mlf[p->priority].first!=p)
80104770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104773:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104777:	0f b7 c0             	movzwl %ax,%eax
8010477a:	05 86 07 00 00       	add    $0x786,%eax
8010477f:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104786:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104789:	74 0d                	je     80104798 <calculateaging+0x8d>
          panic("it does not eliminate the first element of the level.");
8010478b:	83 ec 0c             	sub    $0xc,%esp
8010478e:	68 c8 95 10 80       	push   $0x801095c8
80104793:	e8 ce bd ff ff       	call   80100566 <panic>
        procdump();
80104798:	e8 e3 0b 00 00       	call   80105380 <procdump>
        cprintf("/**************************************************************/\n");
8010479d:	83 ec 0c             	sub    $0xc,%esp
801047a0:	68 00 96 10 80       	push   $0x80109600
801047a5:	e8 1c bc ff ff       	call   801003c6 <cprintf>
801047aa:	83 c4 10             	add    $0x10,%esp
        levelupdate(p);  // call to levelupdate
801047ad:	83 ec 0c             	sub    $0xc,%esp
801047b0:	ff 75 f0             	pushl  -0x10(%ebp)
801047b3:	e8 09 ff ff ff       	call   801046c1 <levelupdate>
801047b8:	83 c4 10             	add    $0x10,%esp
        procdump();
801047bb:	e8 c0 0b 00 00       	call   80105380 <procdump>
        cprintf("/--------------------------------------------------------------/\n");
801047c0:	83 ec 0c             	sub    $0xc,%esp
801047c3:	68 44 96 10 80       	push   $0x80109644
801047c8:	e8 f9 bb ff ff       	call   801003c6 <cprintf>
801047cd:	83 c4 10             	add    $0x10,%esp
calculateaging(void)
{
  struct proc* p;
  int l;
  acquire(&ptable.lock);
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
801047d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047d4:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801047d8:	0f 8e 4f ff ff ff    	jle    8010472d <calculateaging+0x22>
        procdump();
        cprintf("/--------------------------------------------------------------/\n");
      }
    }
  }
  release(&ptable.lock);
801047de:	83 ec 0c             	sub    $0xc,%esp
801047e1:	68 80 39 11 80       	push   $0x80113980
801047e6:	e8 ea 11 00 00       	call   801059d5 <release>
801047eb:	83 c4 10             	add    $0x10,%esp
}
801047ee:	90                   	nop
801047ef:	c9                   	leave  
801047f0:	c3                   	ret    

801047f1 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801047f1:	55                   	push   %ebp
801047f2:	89 e5                	mov    %esp,%ebp
801047f4:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801047f7:	83 ec 08             	sub    $0x8,%esp
801047fa:	68 86 96 10 80       	push   $0x80109686
801047ff:	68 80 39 11 80       	push   $0x80113980
80104804:	e8 43 11 00 00       	call   8010594c <initlock>
80104809:	83 c4 10             	add    $0x10,%esp
}
8010480c:	90                   	nop
8010480d:	c9                   	leave  
8010480e:	c3                   	ret    

8010480f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010480f:	55                   	push   %ebp
80104810:	89 e5                	mov    %esp,%ebp
80104812:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104815:	83 ec 0c             	sub    $0xc,%esp
80104818:	68 80 39 11 80       	push   $0x80113980
8010481d:	e8 4c 11 00 00       	call   8010596e <acquire>
80104822:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104825:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010482c:	eb 11                	jmp    8010483f <allocproc+0x30>
    if(p->state == UNUSED)
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	8b 40 0c             	mov    0xc(%eax),%eax
80104834:	85 c0                	test   %eax,%eax
80104836:	74 2a                	je     80104862 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104838:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
8010483f:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80104846:	72 e6                	jb     8010482e <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104848:	83 ec 0c             	sub    $0xc,%esp
8010484b:	68 80 39 11 80       	push   $0x80113980
80104850:	e8 80 11 00 00       	call   801059d5 <release>
80104855:	83 c4 10             	add    $0x10,%esp
  return 0;
80104858:	b8 00 00 00 00       	mov    $0x0,%eax
8010485d:	e9 c9 00 00 00       	jmp    8010492b <allocproc+0x11c>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104862:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104866:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010486d:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104872:	8d 50 01             	lea    0x1(%eax),%edx
80104875:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
8010487b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010487e:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104881:	83 ec 0c             	sub    $0xc,%esp
80104884:	68 80 39 11 80       	push   $0x80113980
80104889:	e8 47 11 00 00       	call   801059d5 <release>
8010488e:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104891:	e8 92 e3 ff ff       	call   80102c28 <kalloc>
80104896:	89 c2                	mov    %eax,%edx
80104898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489b:	89 50 08             	mov    %edx,0x8(%eax)
8010489e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a1:	8b 40 08             	mov    0x8(%eax),%eax
801048a4:	85 c0                	test   %eax,%eax
801048a6:	75 11                	jne    801048b9 <allocproc+0xaa>
    p->state = UNUSED;
801048a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ab:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801048b2:	b8 00 00 00 00       	mov    $0x0,%eax
801048b7:	eb 72                	jmp    8010492b <allocproc+0x11c>
  }
  sp = p->kstack + KSTACKSIZE;
801048b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bc:	8b 40 08             	mov    0x8(%eax),%eax
801048bf:	05 00 10 00 00       	add    $0x1000,%eax
801048c4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801048c7:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801048cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048d1:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801048d4:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801048d8:	ba a6 71 10 80       	mov    $0x801071a6,%edx
801048dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e0:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801048e2:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048ec:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801048ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801048f5:	83 ec 04             	sub    $0x4,%esp
801048f8:	6a 14                	push   $0x14
801048fa:	6a 00                	push   $0x0
801048fc:	50                   	push   %eax
801048fd:	e8 cf 12 00 00       	call   80105bd1 <memset>
80104902:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	8b 40 1c             	mov    0x1c(%eax),%eax
8010490b:	ba 81 51 10 80       	mov    $0x80105181,%edx
80104910:	89 50 10             	mov    %edx,0x10(%eax)

  p->priority=0;  // initializes the priority.
80104913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104916:	66 c7 40 7e 00 00    	movw   $0x0,0x7e(%eax)
  p->age=0;  // initialize age.
8010491c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491f:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
80104926:	00 00 
  return p;
80104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010492b:	c9                   	leave  
8010492c:	c3                   	ret    

8010492d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010492d:	55                   	push   %ebp
8010492e:	89 e5                	mov    %esp,%ebp
80104930:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104933:	e8 d7 fe ff ff       	call   8010480f <allocproc>
80104938:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010493b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493e:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
80104943:	e8 62 41 00 00       	call   80108aaa <setupkvm>
80104948:	89 c2                	mov    %eax,%edx
8010494a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494d:	89 50 04             	mov    %edx,0x4(%eax)
80104950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104953:	8b 40 04             	mov    0x4(%eax),%eax
80104956:	85 c0                	test   %eax,%eax
80104958:	75 0d                	jne    80104967 <userinit+0x3a>
    panic("userinit: out of memory?");
8010495a:	83 ec 0c             	sub    $0xc,%esp
8010495d:	68 8d 96 10 80       	push   $0x8010968d
80104962:	e8 ff bb ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104967:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010496c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496f:	8b 40 04             	mov    0x4(%eax),%eax
80104972:	83 ec 04             	sub    $0x4,%esp
80104975:	52                   	push   %edx
80104976:	68 00 c5 10 80       	push   $0x8010c500
8010497b:	50                   	push   %eax
8010497c:	e8 83 43 00 00       	call   80108d04 <inituvm>
80104981:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104987:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010498d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104990:	8b 40 18             	mov    0x18(%eax),%eax
80104993:	83 ec 04             	sub    $0x4,%esp
80104996:	6a 4c                	push   $0x4c
80104998:	6a 00                	push   $0x0
8010499a:	50                   	push   %eax
8010499b:	e8 31 12 00 00       	call   80105bd1 <memset>
801049a0:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801049a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a6:	8b 40 18             	mov    0x18(%eax),%eax
801049a9:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801049af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b2:	8b 40 18             	mov    0x18(%eax),%eax
801049b5:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	8b 40 18             	mov    0x18(%eax),%eax
801049c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049c4:	8b 52 18             	mov    0x18(%edx),%edx
801049c7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801049cb:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801049cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d2:	8b 40 18             	mov    0x18(%eax),%eax
801049d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d8:	8b 52 18             	mov    0x18(%edx),%edx
801049db:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801049df:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801049e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e6:	8b 40 18             	mov    0x18(%eax),%eax
801049e9:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801049f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f3:	8b 40 18             	mov    0x18(%eax),%eax
801049f6:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801049fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a00:	8b 40 18             	mov    0x18(%eax),%eax
80104a03:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0d:	83 c0 6c             	add    $0x6c,%eax
80104a10:	83 ec 04             	sub    $0x4,%esp
80104a13:	6a 10                	push   $0x10
80104a15:	68 a6 96 10 80       	push   $0x801096a6
80104a1a:	50                   	push   %eax
80104a1b:	e8 b4 13 00 00       	call   80105dd4 <safestrcpy>
80104a20:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104a23:	83 ec 0c             	sub    $0xc,%esp
80104a26:	68 af 96 10 80       	push   $0x801096af
80104a2b:	e8 f6 da ff ff       	call   80102526 <namei>
80104a30:	83 c4 10             	add    $0x10,%esp
80104a33:	89 c2                	mov    %eax,%edx
80104a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a38:	89 50 68             	mov    %edx,0x68(%eax)


  make_runnable(p);
80104a3b:	83 ec 0c             	sub    $0xc,%esp
80104a3e:	ff 75 f4             	pushl  -0xc(%ebp)
80104a41:	e8 1f fb ff ff       	call   80104565 <make_runnable>
80104a46:	83 c4 10             	add    $0x10,%esp
}
80104a49:	90                   	nop
80104a4a:	c9                   	leave  
80104a4b:	c3                   	ret    

80104a4c <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104a4c:	55                   	push   %ebp
80104a4d:	89 e5                	mov    %esp,%ebp
80104a4f:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104a52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a58:	8b 00                	mov    (%eax),%eax
80104a5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104a5d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a61:	7e 31                	jle    80104a94 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a63:	8b 55 08             	mov    0x8(%ebp),%edx
80104a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a69:	01 c2                	add    %eax,%edx
80104a6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a71:	8b 40 04             	mov    0x4(%eax),%eax
80104a74:	83 ec 04             	sub    $0x4,%esp
80104a77:	52                   	push   %edx
80104a78:	ff 75 f4             	pushl  -0xc(%ebp)
80104a7b:	50                   	push   %eax
80104a7c:	e8 d0 43 00 00       	call   80108e51 <allocuvm>
80104a81:	83 c4 10             	add    $0x10,%esp
80104a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a8b:	75 3e                	jne    80104acb <growproc+0x7f>
      return -1;
80104a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a92:	eb 59                	jmp    80104aed <growproc+0xa1>
  } else if(n < 0){
80104a94:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a98:	79 31                	jns    80104acb <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a9a:	8b 55 08             	mov    0x8(%ebp),%edx
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	01 c2                	add    %eax,%edx
80104aa2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa8:	8b 40 04             	mov    0x4(%eax),%eax
80104aab:	83 ec 04             	sub    $0x4,%esp
80104aae:	52                   	push   %edx
80104aaf:	ff 75 f4             	pushl  -0xc(%ebp)
80104ab2:	50                   	push   %eax
80104ab3:	e8 62 44 00 00       	call   80108f1a <deallocuvm>
80104ab8:	83 c4 10             	add    $0x10,%esp
80104abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104abe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ac2:	75 07                	jne    80104acb <growproc+0x7f>
      return -1;
80104ac4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ac9:	eb 22                	jmp    80104aed <growproc+0xa1>
  }
  proc->sz = sz;
80104acb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ad1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ad4:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104ad6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104adc:	83 ec 0c             	sub    $0xc,%esp
80104adf:	50                   	push   %eax
80104ae0:	e8 ac 40 00 00       	call   80108b91 <switchuvm>
80104ae5:	83 c4 10             	add    $0x10,%esp
  return 0;
80104ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104aed:	c9                   	leave  
80104aee:	c3                   	ret    

80104aef <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104aef:	55                   	push   %ebp
80104af0:	89 e5                	mov    %esp,%ebp
80104af2:	57                   	push   %edi
80104af3:	56                   	push   %esi
80104af4:	53                   	push   %ebx
80104af5:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104af8:	e8 12 fd ff ff       	call   8010480f <allocproc>
80104afd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104b00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104b04:	75 0a                	jne    80104b10 <fork+0x21>
    return -1;
80104b06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b0b:	e9 d3 01 00 00       	jmp    80104ce3 <fork+0x1f4>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104b10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b16:	8b 10                	mov    (%eax),%edx
80104b18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1e:	8b 40 04             	mov    0x4(%eax),%eax
80104b21:	83 ec 08             	sub    $0x8,%esp
80104b24:	52                   	push   %edx
80104b25:	50                   	push   %eax
80104b26:	e8 8d 45 00 00       	call   801090b8 <copyuvm>
80104b2b:	83 c4 10             	add    $0x10,%esp
80104b2e:	89 c2                	mov    %eax,%edx
80104b30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b33:	89 50 04             	mov    %edx,0x4(%eax)
80104b36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b39:	8b 40 04             	mov    0x4(%eax),%eax
80104b3c:	85 c0                	test   %eax,%eax
80104b3e:	75 30                	jne    80104b70 <fork+0x81>
    kfree(np->kstack);
80104b40:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b43:	8b 40 08             	mov    0x8(%eax),%eax
80104b46:	83 ec 0c             	sub    $0xc,%esp
80104b49:	50                   	push   %eax
80104b4a:	e8 3c e0 ff ff       	call   80102b8b <kfree>
80104b4f:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104b52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104b5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b5f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6b:	e9 73 01 00 00       	jmp    80104ce3 <fork+0x1f4>
  }
  np->sz = proc->sz;
80104b70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b76:	8b 10                	mov    (%eax),%edx
80104b78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b7b:	89 10                	mov    %edx,(%eax)
  np->sstack = proc->sstack;
80104b7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b83:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80104b89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b8c:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)

  np->parent = proc;
80104b92:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b9c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104b9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ba2:	8b 50 18             	mov    0x18(%eax),%edx
80104ba5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bab:	8b 40 18             	mov    0x18(%eax),%eax
80104bae:	89 c3                	mov    %eax,%ebx
80104bb0:	b8 13 00 00 00       	mov    $0x13,%eax
80104bb5:	89 d7                	mov    %edx,%edi
80104bb7:	89 de                	mov    %ebx,%esi
80104bb9:	89 c1                	mov    %eax,%ecx
80104bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc0:	8b 40 18             	mov    0x18(%eax),%eax
80104bc3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104bca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104bd1:	eb 43                	jmp    80104c16 <fork+0x127>
    if(proc->ofile[i])
80104bd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bdc:	83 c2 08             	add    $0x8,%edx
80104bdf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104be3:	85 c0                	test   %eax,%eax
80104be5:	74 2b                	je     80104c12 <fork+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
80104be7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bf0:	83 c2 08             	add    $0x8,%edx
80104bf3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bf7:	83 ec 0c             	sub    $0xc,%esp
80104bfa:	50                   	push   %eax
80104bfb:	e8 ed c3 ff ff       	call   80100fed <filedup>
80104c00:	83 c4 10             	add    $0x10,%esp
80104c03:	89 c1                	mov    %eax,%ecx
80104c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c08:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c0b:	83 c2 08             	add    $0x8,%edx
80104c0e:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104c12:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104c16:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104c1a:	7e b7                	jle    80104bd3 <fork+0xe4>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++)
80104c1c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104c23:	eb 43                	jmp    80104c68 <fork+0x179>
    if(proc->osemaphore[i])
80104c25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c2e:	83 c2 20             	add    $0x20,%edx
80104c31:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c35:	85 c0                	test   %eax,%eax
80104c37:	74 2b                	je     80104c64 <fork+0x175>
      np->osemaphore[i] = semdup(proc->osemaphore[i]);
80104c39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c42:	83 c2 20             	add    $0x20,%edx
80104c45:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c49:	83 ec 0c             	sub    $0xc,%esp
80104c4c:	50                   	push   %eax
80104c4d:	e8 71 0c 00 00       	call   801058c3 <semdup>
80104c52:	83 c4 10             	add    $0x10,%esp
80104c55:	89 c1                	mov    %eax,%ecx
80104c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c5d:	83 c2 20             	add    $0x20,%edx
80104c60:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++)
80104c64:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104c68:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
80104c6c:	7e b7                	jle    80104c25 <fork+0x136>
    if(proc->osemaphore[i])
      np->osemaphore[i] = semdup(proc->osemaphore[i]);

  np->cwd = idup(proc->cwd);
80104c6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c74:	8b 40 68             	mov    0x68(%eax),%eax
80104c77:	83 ec 0c             	sub    $0xc,%esp
80104c7a:	50                   	push   %eax
80104c7b:	e8 b4 cc ff ff       	call   80101934 <idup>
80104c80:	83 c4 10             	add    $0x10,%esp
80104c83:	89 c2                	mov    %eax,%edx
80104c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c88:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104c8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c91:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c97:	83 c0 6c             	add    $0x6c,%eax
80104c9a:	83 ec 04             	sub    $0x4,%esp
80104c9d:	6a 10                	push   $0x10
80104c9f:	52                   	push   %edx
80104ca0:	50                   	push   %eax
80104ca1:	e8 2e 11 00 00       	call   80105dd4 <safestrcpy>
80104ca6:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cac:	8b 40 10             	mov    0x10(%eax),%eax
80104caf:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104cb2:	83 ec 0c             	sub    $0xc,%esp
80104cb5:	68 80 39 11 80       	push   $0x80113980
80104cba:	e8 af 0c 00 00       	call   8010596e <acquire>
80104cbf:	83 c4 10             	add    $0x10,%esp
  make_runnable(np);
80104cc2:	83 ec 0c             	sub    $0xc,%esp
80104cc5:	ff 75 e0             	pushl  -0x20(%ebp)
80104cc8:	e8 98 f8 ff ff       	call   80104565 <make_runnable>
80104ccd:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104cd0:	83 ec 0c             	sub    $0xc,%esp
80104cd3:	68 80 39 11 80       	push   $0x80113980
80104cd8:	e8 f8 0c 00 00       	call   801059d5 <release>
80104cdd:	83 c4 10             	add    $0x10,%esp

  return pid;
80104ce0:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ce6:	5b                   	pop    %ebx
80104ce7:	5e                   	pop    %esi
80104ce8:	5f                   	pop    %edi
80104ce9:	5d                   	pop    %ebp
80104cea:	c3                   	ret    

80104ceb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104ceb:	55                   	push   %ebp
80104cec:	89 e5                	mov    %esp,%ebp
80104cee:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd,idsem;

  if(proc == initproc)
80104cf1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cf8:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104cfd:	39 c2                	cmp    %eax,%edx
80104cff:	75 0d                	jne    80104d0e <exit+0x23>
    panic("init exiting");
80104d01:	83 ec 0c             	sub    $0xc,%esp
80104d04:	68 b1 96 10 80       	push   $0x801096b1
80104d09:	e8 58 b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d0e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104d15:	eb 48                	jmp    80104d5f <exit+0x74>
    if(proc->ofile[fd]){
80104d17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d20:	83 c2 08             	add    $0x8,%edx
80104d23:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d27:	85 c0                	test   %eax,%eax
80104d29:	74 30                	je     80104d5b <exit+0x70>
      fileclose(proc->ofile[fd]);
80104d2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d34:	83 c2 08             	add    $0x8,%edx
80104d37:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d3b:	83 ec 0c             	sub    $0xc,%esp
80104d3e:	50                   	push   %eax
80104d3f:	e8 fa c2 ff ff       	call   8010103e <fileclose>
80104d44:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104d47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d4d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d50:	83 c2 08             	add    $0x8,%edx
80104d53:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104d5a:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d5b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d5f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104d63:	7e b2                	jle    80104d17 <exit+0x2c>
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104d65:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104d6c:	eb 48                	jmp    80104db6 <exit+0xcb>
    if(proc->osemaphore[idsem]){
80104d6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d74:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d77:	83 c2 20             	add    $0x20,%edx
80104d7a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d7e:	85 c0                	test   %eax,%eax
80104d80:	74 30                	je     80104db2 <exit+0xc7>
      semclose(proc->osemaphore[idsem]);
80104d82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d88:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d8b:	83 c2 20             	add    $0x20,%edx
80104d8e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d92:	83 ec 0c             	sub    $0xc,%esp
80104d95:	50                   	push   %eax
80104d96:	e8 d9 0a 00 00       	call   80105874 <semclose>
80104d9b:	83 c4 10             	add    $0x10,%esp
      proc->osemaphore[idsem] = 0;
80104d9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104da7:	83 c2 20             	add    $0x20,%edx
80104daa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104db1:	00 
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104db2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104db6:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80104dba:	7e b2                	jle    80104d6e <exit+0x83>
      semclose(proc->osemaphore[idsem]);
      proc->osemaphore[idsem] = 0;
    }
  }

  begin_op();
80104dbc:	e8 56 e7 ff ff       	call   80103517 <begin_op>
  iput(proc->cwd);
80104dc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc7:	8b 40 68             	mov    0x68(%eax),%eax
80104dca:	83 ec 0c             	sub    $0xc,%esp
80104dcd:	50                   	push   %eax
80104dce:	e8 65 cd ff ff       	call   80101b38 <iput>
80104dd3:	83 c4 10             	add    $0x10,%esp
  end_op();
80104dd6:	e8 c8 e7 ff ff       	call   801035a3 <end_op>
  proc->cwd = 0;
80104ddb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104de8:	83 ec 0c             	sub    $0xc,%esp
80104deb:	68 80 39 11 80       	push   $0x80113980
80104df0:	e8 79 0b 00 00       	call   8010596e <acquire>
80104df5:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104df8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dfe:	8b 40 14             	mov    0x14(%eax),%eax
80104e01:	83 ec 0c             	sub    $0xc,%esp
80104e04:	50                   	push   %eax
80104e05:	e8 54 04 00 00       	call   8010525e <wakeup1>
80104e0a:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e0d:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104e14:	eb 3f                	jmp    80104e55 <exit+0x16a>
    if(p->parent == proc){
80104e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e19:	8b 50 14             	mov    0x14(%eax),%edx
80104e1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e22:	39 c2                	cmp    %eax,%edx
80104e24:	75 28                	jne    80104e4e <exit+0x163>
      p->parent = initproc;
80104e26:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e35:	8b 40 0c             	mov    0xc(%eax),%eax
80104e38:	83 f8 05             	cmp    $0x5,%eax
80104e3b:	75 11                	jne    80104e4e <exit+0x163>
        wakeup1(initproc);
80104e3d:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104e42:	83 ec 0c             	sub    $0xc,%esp
80104e45:	50                   	push   %eax
80104e46:	e8 13 04 00 00       	call   8010525e <wakeup1>
80104e4b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e4e:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
80104e55:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80104e5c:	72 b8                	jb     80104e16 <exit+0x12b>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104e5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e64:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104e6b:	e8 f4 01 00 00       	call   80105064 <sched>
  panic("zombie exit");
80104e70:	83 ec 0c             	sub    $0xc,%esp
80104e73:	68 be 96 10 80       	push   $0x801096be
80104e78:	e8 e9 b6 ff ff       	call   80100566 <panic>

80104e7d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104e7d:	55                   	push   %ebp
80104e7e:	89 e5                	mov    %esp,%ebp
80104e80:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104e83:	83 ec 0c             	sub    $0xc,%esp
80104e86:	68 80 39 11 80       	push   $0x80113980
80104e8b:	e8 de 0a 00 00       	call   8010596e <acquire>
80104e90:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104e93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e9a:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104ea1:	e9 a9 00 00 00       	jmp    80104f4f <wait+0xd2>
      if(p->parent != proc)
80104ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea9:	8b 50 14             	mov    0x14(%eax),%edx
80104eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eb2:	39 c2                	cmp    %eax,%edx
80104eb4:	0f 85 8d 00 00 00    	jne    80104f47 <wait+0xca>
        continue;
      havekids = 1;
80104eba:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec7:	83 f8 05             	cmp    $0x5,%eax
80104eca:	75 7c                	jne    80104f48 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecf:	8b 40 10             	mov    0x10(%eax),%eax
80104ed2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed8:	8b 40 08             	mov    0x8(%eax),%eax
80104edb:	83 ec 0c             	sub    $0xc,%esp
80104ede:	50                   	push   %eax
80104edf:	e8 a7 dc ff ff       	call   80102b8b <kfree>
80104ee4:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef4:	8b 40 04             	mov    0x4(%eax),%eax
80104ef7:	83 ec 0c             	sub    $0xc,%esp
80104efa:	50                   	push   %eax
80104efb:	e8 d7 40 00 00       	call   80108fd7 <freevm>
80104f00:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f06:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f10:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f24:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104f32:	83 ec 0c             	sub    $0xc,%esp
80104f35:	68 80 39 11 80       	push   $0x80113980
80104f3a:	e8 96 0a 00 00       	call   801059d5 <release>
80104f3f:	83 c4 10             	add    $0x10,%esp
        return pid;
80104f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f45:	eb 5b                	jmp    80104fa2 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104f47:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f48:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
80104f4f:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80104f56:	0f 82 4a ff ff ff    	jb     80104ea6 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104f5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f60:	74 0d                	je     80104f6f <wait+0xf2>
80104f62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f68:	8b 40 24             	mov    0x24(%eax),%eax
80104f6b:	85 c0                	test   %eax,%eax
80104f6d:	74 17                	je     80104f86 <wait+0x109>
      release(&ptable.lock);
80104f6f:	83 ec 0c             	sub    $0xc,%esp
80104f72:	68 80 39 11 80       	push   $0x80113980
80104f77:	e8 59 0a 00 00       	call   801059d5 <release>
80104f7c:	83 c4 10             	add    $0x10,%esp
      return -1;
80104f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f84:	eb 1c                	jmp    80104fa2 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104f86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f8c:	83 ec 08             	sub    $0x8,%esp
80104f8f:	68 80 39 11 80       	push   $0x80113980
80104f94:	50                   	push   %eax
80104f95:	e8 18 02 00 00       	call   801051b2 <sleep>
80104f9a:	83 c4 10             	add    $0x10,%esp
  }
80104f9d:	e9 f1 fe ff ff       	jmp    80104e93 <wait+0x16>
}
80104fa2:	c9                   	leave  
80104fa3:	c3                   	ret    

80104fa4 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int l;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104faa:	e8 af f5 ff ff       	call   8010455e <sti>

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
80104faf:	83 ec 0c             	sub    $0xc,%esp
80104fb2:	68 80 39 11 80       	push   $0x80113980
80104fb7:	e8 b2 09 00 00       	call   8010596e <acquire>
80104fbc:	83 c4 10             	add    $0x10,%esp
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104fbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fc6:	eb 7d                	jmp    80105045 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
80104fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcb:	05 86 07 00 00       	add    $0x786,%eax
80104fd0:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104fd7:	85 c0                	test   %eax,%eax
80104fd9:	75 06                	jne    80104fe1 <scheduler+0x3d>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104fdb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fdf:	eb 64                	jmp    80105045 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
        continue;
      p=unqueue(l);
80104fe1:	83 ec 0c             	sub    $0xc,%esp
80104fe4:	ff 75 f4             	pushl  -0xc(%ebp)
80104fe7:	e8 11 f6 ff ff       	call   801045fd <unqueue>
80104fec:	83 c4 10             	add    $0x10,%esp
80104fef:	89 45 f0             	mov    %eax,-0x10(%ebp)


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff5:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4


      switchuvm(p);
80104ffb:	83 ec 0c             	sub    $0xc,%esp
80104ffe:	ff 75 f0             	pushl  -0x10(%ebp)
80105001:	e8 8b 3b 00 00       	call   80108b91 <switchuvm>
80105006:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80105009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105013:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105019:	8b 40 1c             	mov    0x1c(%eax),%eax
8010501c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105023:	83 c2 04             	add    $0x4,%edx
80105026:	83 ec 08             	sub    $0x8,%esp
80105029:	50                   	push   %eax
8010502a:	52                   	push   %edx
8010502b:	e8 15 0e 00 00       	call   80105e45 <swtch>
80105030:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105033:	e8 3c 3b 00 00       	call   80108b74 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105038:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010503f:	00 00 00 00 
      break;
80105043:	eb 0a                	jmp    8010504f <scheduler+0xab>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80105045:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80105049:	0f 8e 79 ff ff ff    	jle    80104fc8 <scheduler+0x24>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      break;
    }
    release(&ptable.lock);
8010504f:	83 ec 0c             	sub    $0xc,%esp
80105052:	68 80 39 11 80       	push   $0x80113980
80105057:	e8 79 09 00 00       	call   801059d5 <release>
8010505c:	83 c4 10             	add    $0x10,%esp
  }
8010505f:	e9 46 ff ff ff       	jmp    80104faa <scheduler+0x6>

80105064 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105064:	55                   	push   %ebp
80105065:	89 e5                	mov    %esp,%ebp
80105067:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010506a:	83 ec 0c             	sub    $0xc,%esp
8010506d:	68 80 39 11 80       	push   $0x80113980
80105072:	e8 2a 0a 00 00       	call   80105aa1 <holding>
80105077:	83 c4 10             	add    $0x10,%esp
8010507a:	85 c0                	test   %eax,%eax
8010507c:	75 0d                	jne    8010508b <sched+0x27>
    panic("sched ptable.lock");
8010507e:	83 ec 0c             	sub    $0xc,%esp
80105081:	68 ca 96 10 80       	push   $0x801096ca
80105086:	e8 db b4 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010508b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105091:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105097:	83 f8 01             	cmp    $0x1,%eax
8010509a:	74 0d                	je     801050a9 <sched+0x45>
    panic("sched locks");
8010509c:	83 ec 0c             	sub    $0xc,%esp
8010509f:	68 dc 96 10 80       	push   $0x801096dc
801050a4:	e8 bd b4 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801050a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050af:	8b 40 0c             	mov    0xc(%eax),%eax
801050b2:	83 f8 04             	cmp    $0x4,%eax
801050b5:	75 0d                	jne    801050c4 <sched+0x60>
    panic("sched running");
801050b7:	83 ec 0c             	sub    $0xc,%esp
801050ba:	68 e8 96 10 80       	push   $0x801096e8
801050bf:	e8 a2 b4 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801050c4:	e8 85 f4 ff ff       	call   8010454e <readeflags>
801050c9:	25 00 02 00 00       	and    $0x200,%eax
801050ce:	85 c0                	test   %eax,%eax
801050d0:	74 0d                	je     801050df <sched+0x7b>
    panic("sched interruptible");
801050d2:	83 ec 0c             	sub    $0xc,%esp
801050d5:	68 f6 96 10 80       	push   $0x801096f6
801050da:	e8 87 b4 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801050df:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050e5:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801050eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801050ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050f4:	8b 40 04             	mov    0x4(%eax),%eax
801050f7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050fe:	83 c2 1c             	add    $0x1c,%edx
80105101:	83 ec 08             	sub    $0x8,%esp
80105104:	50                   	push   %eax
80105105:	52                   	push   %edx
80105106:	e8 3a 0d 00 00       	call   80105e45 <swtch>
8010510b:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010510e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105114:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105117:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010511d:	90                   	nop
8010511e:	c9                   	leave  
8010511f:	c3                   	ret    

80105120 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105120:	55                   	push   %ebp
80105121:	89 e5                	mov    %esp,%ebp
80105123:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105126:	83 ec 0c             	sub    $0xc,%esp
80105129:	68 80 39 11 80       	push   $0x80113980
8010512e:	e8 3b 08 00 00       	call   8010596e <acquire>
80105133:	83 c4 10             	add    $0x10,%esp
  if(proc->priority<MLFLEVELS-1)
80105136:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513c:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105140:	66 83 f8 02          	cmp    $0x2,%ax
80105144:	77 11                	ja     80105157 <yield+0x37>
    proc->priority++;
80105146:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010514c:	0f b7 50 7e          	movzwl 0x7e(%eax),%edx
80105150:	83 c2 01             	add    $0x1,%edx
80105153:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(proc);
80105157:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515d:	83 ec 0c             	sub    $0xc,%esp
80105160:	50                   	push   %eax
80105161:	e8 ff f3 ff ff       	call   80104565 <make_runnable>
80105166:	83 c4 10             	add    $0x10,%esp
  sched();
80105169:	e8 f6 fe ff ff       	call   80105064 <sched>
  release(&ptable.lock);
8010516e:	83 ec 0c             	sub    $0xc,%esp
80105171:	68 80 39 11 80       	push   $0x80113980
80105176:	e8 5a 08 00 00       	call   801059d5 <release>
8010517b:	83 c4 10             	add    $0x10,%esp
}
8010517e:	90                   	nop
8010517f:	c9                   	leave  
80105180:	c3                   	ret    

80105181 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105181:	55                   	push   %ebp
80105182:	89 e5                	mov    %esp,%ebp
80105184:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105187:	83 ec 0c             	sub    $0xc,%esp
8010518a:	68 80 39 11 80       	push   $0x80113980
8010518f:	e8 41 08 00 00       	call   801059d5 <release>
80105194:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105197:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010519c:	85 c0                	test   %eax,%eax
8010519e:	74 0f                	je     801051af <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801051a0:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
801051a7:	00 00 00 
    initlog();
801051aa:	e8 42 e1 ff ff       	call   801032f1 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801051af:	90                   	nop
801051b0:	c9                   	leave  
801051b1:	c3                   	ret    

801051b2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801051b2:	55                   	push   %ebp
801051b3:	89 e5                	mov    %esp,%ebp
801051b5:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801051b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051be:	85 c0                	test   %eax,%eax
801051c0:	75 0d                	jne    801051cf <sleep+0x1d>
    panic("sleep");
801051c2:	83 ec 0c             	sub    $0xc,%esp
801051c5:	68 0a 97 10 80       	push   $0x8010970a
801051ca:	e8 97 b3 ff ff       	call   80100566 <panic>

  if(lk == 0)
801051cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801051d3:	75 0d                	jne    801051e2 <sleep+0x30>
    panic("sleep without lk");
801051d5:	83 ec 0c             	sub    $0xc,%esp
801051d8:	68 10 97 10 80       	push   $0x80109710
801051dd:	e8 84 b3 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801051e2:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801051e9:	74 1e                	je     80105209 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801051eb:	83 ec 0c             	sub    $0xc,%esp
801051ee:	68 80 39 11 80       	push   $0x80113980
801051f3:	e8 76 07 00 00       	call   8010596e <acquire>
801051f8:	83 c4 10             	add    $0x10,%esp
    release(lk);
801051fb:	83 ec 0c             	sub    $0xc,%esp
801051fe:	ff 75 0c             	pushl  0xc(%ebp)
80105201:	e8 cf 07 00 00       	call   801059d5 <release>
80105206:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105209:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010520f:	8b 55 08             	mov    0x8(%ebp),%edx
80105212:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105215:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010521b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105222:	e8 3d fe ff ff       	call   80105064 <sched>

  // Tidy up.
  proc->chan = 0;
80105227:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010522d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105234:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
8010523b:	74 1e                	je     8010525b <sleep+0xa9>
    release(&ptable.lock);
8010523d:	83 ec 0c             	sub    $0xc,%esp
80105240:	68 80 39 11 80       	push   $0x80113980
80105245:	e8 8b 07 00 00       	call   801059d5 <release>
8010524a:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010524d:	83 ec 0c             	sub    $0xc,%esp
80105250:	ff 75 0c             	pushl  0xc(%ebp)
80105253:	e8 16 07 00 00       	call   8010596e <acquire>
80105258:	83 c4 10             	add    $0x10,%esp
  }
}
8010525b:	90                   	nop
8010525c:	c9                   	leave  
8010525d:	c3                   	ret    

8010525e <wakeup1>:
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
// If applicable, the priority of the process increases.
static void
wakeup1(void *chan)
{
8010525e:	55                   	push   %ebp
8010525f:	89 e5                	mov    %esp,%ebp
80105261:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105264:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
8010526b:	eb 45                	jmp    801052b2 <wakeup1+0x54>
    if(p->state == SLEEPING && p->chan == chan){
8010526d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105270:	8b 40 0c             	mov    0xc(%eax),%eax
80105273:	83 f8 02             	cmp    $0x2,%eax
80105276:	75 33                	jne    801052ab <wakeup1+0x4d>
80105278:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010527b:	8b 40 20             	mov    0x20(%eax),%eax
8010527e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105281:	75 28                	jne    801052ab <wakeup1+0x4d>
      if (p->priority>0)
80105283:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105286:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010528a:	66 85 c0             	test   %ax,%ax
8010528d:	74 11                	je     801052a0 <wakeup1+0x42>
        p->priority--;
8010528f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105292:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105296:	8d 50 ff             	lea    -0x1(%eax),%edx
80105299:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010529c:	66 89 50 7e          	mov    %dx,0x7e(%eax)
      make_runnable(p);
801052a0:	ff 75 fc             	pushl  -0x4(%ebp)
801052a3:	e8 bd f2 ff ff       	call   80104565 <make_runnable>
801052a8:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801052ab:	81 45 fc f0 00 00 00 	addl   $0xf0,-0x4(%ebp)
801052b2:	81 7d fc b4 75 11 80 	cmpl   $0x801175b4,-0x4(%ebp)
801052b9:	72 b2                	jb     8010526d <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan){
      if (p->priority>0)
        p->priority--;
      make_runnable(p);
    }
}
801052bb:	90                   	nop
801052bc:	c9                   	leave  
801052bd:	c3                   	ret    

801052be <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801052be:	55                   	push   %ebp
801052bf:	89 e5                	mov    %esp,%ebp
801052c1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801052c4:	83 ec 0c             	sub    $0xc,%esp
801052c7:	68 80 39 11 80       	push   $0x80113980
801052cc:	e8 9d 06 00 00       	call   8010596e <acquire>
801052d1:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801052d4:	83 ec 0c             	sub    $0xc,%esp
801052d7:	ff 75 08             	pushl  0x8(%ebp)
801052da:	e8 7f ff ff ff       	call   8010525e <wakeup1>
801052df:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801052e2:	83 ec 0c             	sub    $0xc,%esp
801052e5:	68 80 39 11 80       	push   $0x80113980
801052ea:	e8 e6 06 00 00       	call   801059d5 <release>
801052ef:	83 c4 10             	add    $0x10,%esp
}
801052f2:	90                   	nop
801052f3:	c9                   	leave  
801052f4:	c3                   	ret    

801052f5 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801052f5:	55                   	push   %ebp
801052f6:	89 e5                	mov    %esp,%ebp
801052f8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801052fb:	83 ec 0c             	sub    $0xc,%esp
801052fe:	68 80 39 11 80       	push   $0x80113980
80105303:	e8 66 06 00 00       	call   8010596e <acquire>
80105308:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010530b:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105312:	eb 4c                	jmp    80105360 <kill+0x6b>
    if(p->pid == pid){
80105314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105317:	8b 40 10             	mov    0x10(%eax),%eax
8010531a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010531d:	75 3a                	jne    80105359 <kill+0x64>
      p->killed = 1;
8010531f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105322:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532c:	8b 40 0c             	mov    0xc(%eax),%eax
8010532f:	83 f8 02             	cmp    $0x2,%eax
80105332:	75 0e                	jne    80105342 <kill+0x4d>
        make_runnable(p);
80105334:	83 ec 0c             	sub    $0xc,%esp
80105337:	ff 75 f4             	pushl  -0xc(%ebp)
8010533a:	e8 26 f2 ff ff       	call   80104565 <make_runnable>
8010533f:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
80105342:	83 ec 0c             	sub    $0xc,%esp
80105345:	68 80 39 11 80       	push   $0x80113980
8010534a:	e8 86 06 00 00       	call   801059d5 <release>
8010534f:	83 c4 10             	add    $0x10,%esp
      return 0;
80105352:	b8 00 00 00 00       	mov    $0x0,%eax
80105357:	eb 25                	jmp    8010537e <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105359:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
80105360:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80105367:	72 ab                	jb     80105314 <kill+0x1f>
        make_runnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105369:	83 ec 0c             	sub    $0xc,%esp
8010536c:	68 80 39 11 80       	push   $0x80113980
80105371:	e8 5f 06 00 00       	call   801059d5 <release>
80105376:	83 c4 10             	add    $0x10,%esp
  return -1;
80105379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010537e:	c9                   	leave  
8010537f:	c3                   	ret    

80105380 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105380:	55                   	push   %ebp
80105381:	89 e5                	mov    %esp,%ebp
80105383:	53                   	push   %ebx
80105384:	83 ec 44             	sub    $0x44,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105387:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
8010538e:	e9 f6 00 00 00       	jmp    80105489 <procdump+0x109>
    if(p->state == UNUSED)
80105393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105396:	8b 40 0c             	mov    0xc(%eax),%eax
80105399:	85 c0                	test   %eax,%eax
8010539b:	0f 84 e0 00 00 00    	je     80105481 <procdump+0x101>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801053a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a4:	8b 40 0c             	mov    0xc(%eax),%eax
801053a7:	83 f8 05             	cmp    $0x5,%eax
801053aa:	77 23                	ja     801053cf <procdump+0x4f>
801053ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053af:	8b 40 0c             	mov    0xc(%eax),%eax
801053b2:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801053b9:	85 c0                	test   %eax,%eax
801053bb:	74 12                	je     801053cf <procdump+0x4f>
      state = states[p->state];
801053bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c0:	8b 40 0c             	mov    0xc(%eax),%eax
801053c3:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801053ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
801053cd:	eb 07                	jmp    801053d6 <procdump+0x56>
    else
      state = "???";
801053cf:	c7 45 ec 21 97 10 80 	movl   $0x80109721,-0x14(%ebp)
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
801053d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d9:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801053e0:	0f b7 c8             	movzwl %ax,%ecx
801053e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e6:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801053ea:	0f b7 d0             	movzwl %ax,%edx
801053ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f0:	8d 58 6c             	lea    0x6c(%eax),%ebx
801053f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f6:	8b 40 10             	mov    0x10(%eax),%eax
801053f9:	83 ec 08             	sub    $0x8,%esp
801053fc:	51                   	push   %ecx
801053fd:	52                   	push   %edx
801053fe:	53                   	push   %ebx
801053ff:	ff 75 ec             	pushl  -0x14(%ebp)
80105402:	50                   	push   %eax
80105403:	68 25 97 10 80       	push   $0x80109725
80105408:	e8 b9 af ff ff       	call   801003c6 <cprintf>
8010540d:	83 c4 20             	add    $0x20,%esp
    if(p->state == SLEEPING){
80105410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105413:	8b 40 0c             	mov    0xc(%eax),%eax
80105416:	83 f8 02             	cmp    $0x2,%eax
80105419:	75 54                	jne    8010546f <procdump+0xef>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010541b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105421:	8b 40 0c             	mov    0xc(%eax),%eax
80105424:	83 c0 08             	add    $0x8,%eax
80105427:	89 c2                	mov    %eax,%edx
80105429:	83 ec 08             	sub    $0x8,%esp
8010542c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010542f:	50                   	push   %eax
80105430:	52                   	push   %edx
80105431:	e8 f1 05 00 00       	call   80105a27 <getcallerpcs>
80105436:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105439:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105440:	eb 1c                	jmp    8010545e <procdump+0xde>
        cprintf(" %p", pc[i]);
80105442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105445:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105449:	83 ec 08             	sub    $0x8,%esp
8010544c:	50                   	push   %eax
8010544d:	68 41 97 10 80       	push   $0x80109741
80105452:	e8 6f af ff ff       	call   801003c6 <cprintf>
80105457:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010545a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010545e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105462:	7f 0b                	jg     8010546f <procdump+0xef>
80105464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105467:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010546b:	85 c0                	test   %eax,%eax
8010546d:	75 d3                	jne    80105442 <procdump+0xc2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010546f:	83 ec 0c             	sub    $0xc,%esp
80105472:	68 45 97 10 80       	push   $0x80109745
80105477:	e8 4a af ff ff       	call   801003c6 <cprintf>
8010547c:	83 c4 10             	add    $0x10,%esp
8010547f:	eb 01                	jmp    80105482 <procdump+0x102>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105481:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105482:	81 45 f0 f0 00 00 00 	addl   $0xf0,-0x10(%ebp)
80105489:	81 7d f0 b4 75 11 80 	cmpl   $0x801175b4,-0x10(%ebp)
80105490:	0f 82 fd fe ff ff    	jb     80105393 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105496:	90                   	nop
80105497:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010549a:	c9                   	leave  
8010549b:	c3                   	ret    

8010549c <seminit>:
} stable;

// Initializes the LOCK of the semaphore table.
void
seminit(void)
{
8010549c:	55                   	push   %ebp
8010549d:	89 e5                	mov    %esp,%ebp
8010549f:	83 ec 08             	sub    $0x8,%esp
  initlock(&stable.lock, "stable");
801054a2:	83 ec 08             	sub    $0x8,%esp
801054a5:	68 71 97 10 80       	push   $0x80109771
801054aa:	68 e0 75 11 80       	push   $0x801175e0
801054af:	e8 98 04 00 00       	call   8010594c <initlock>
801054b4:	83 c4 10             	add    $0x10,%esp
}
801054b7:	90                   	nop
801054b8:	c9                   	leave  
801054b9:	c3                   	ret    

801054ba <allocinprocess>:

// Assigns a place in the open semaphore array of the process and returns the position.
static int
allocinprocess()
{
801054ba:	55                   	push   %ebp
801054bb:	89 e5                	mov    %esp,%ebp
801054bd:	83 ec 10             	sub    $0x10,%esp
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
801054c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054c7:	eb 22                	jmp    801054eb <allocinprocess+0x31>
    s=proc->osemaphore[i];
801054c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054d2:	83 c2 20             	add    $0x20,%edx
801054d5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(!s)
801054dc:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801054e0:	75 05                	jne    801054e7 <allocinprocess+0x2d>
      return i;
801054e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e5:	eb 0f                	jmp    801054f6 <allocinprocess+0x3c>
allocinprocess()
{
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
801054e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054eb:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801054ef:	7e d8                	jle    801054c9 <allocinprocess+0xf>
    s=proc->osemaphore[i];
    if(!s)
      return i;
  }
  return -1;
801054f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054f6:	c9                   	leave  
801054f7:	c3                   	ret    

801054f8 <searchinprocess>:

// Find the id passed as an argument between the ids of the open semaphores of the process and return its position.
static int
searchinprocess(int id)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
801054fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105505:	eb 2c                	jmp    80105533 <searchinprocess+0x3b>
    s=proc->osemaphore[i];
80105507:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010550d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105510:	83 c2 20             	add    $0x20,%edx
80105513:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105517:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s && s->id==id){
8010551a:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
8010551e:	74 0f                	je     8010552f <searchinprocess+0x37>
80105520:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105523:	8b 00                	mov    (%eax),%eax
80105525:	3b 45 08             	cmp    0x8(%ebp),%eax
80105528:	75 05                	jne    8010552f <searchinprocess+0x37>
        return i;
8010552a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010552d:	eb 0f                	jmp    8010553e <searchinprocess+0x46>
searchinprocess(int id)
{
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
8010552f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105533:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80105537:	7e ce                	jle    80105507 <searchinprocess+0xf>
    s=proc->osemaphore[i];
    if(s && s->id==id){
        return i;
    }
  }
  return -1;
80105539:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010553e:	c9                   	leave  
8010553f:	c3                   	ret    

80105540 <allocinsystem>:

// Assign a place in the semaphore table of the system and return a pointer to it.
// if the table is full, return null (0)
static struct semaphore*
allocinsystem()
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
80105546:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010554d:	eb 2d                	jmp    8010557c <allocinsystem+0x3c>
    s=&stable.sem[i];
8010554f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105552:	89 d0                	mov    %edx,%eax
80105554:	01 c0                	add    %eax,%eax
80105556:	01 d0                	add    %edx,%eax
80105558:	c1 e0 02             	shl    $0x2,%eax
8010555b:	83 c0 30             	add    $0x30,%eax
8010555e:	05 e0 75 11 80       	add    $0x801175e0,%eax
80105563:	83 c0 04             	add    $0x4,%eax
80105566:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s->references==0)
80105569:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010556c:	8b 40 04             	mov    0x4(%eax),%eax
8010556f:	85 c0                	test   %eax,%eax
80105571:	75 05                	jne    80105578 <allocinsystem+0x38>
      return s;
80105573:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105576:	eb 0f                	jmp    80105587 <allocinsystem+0x47>
static struct semaphore*
allocinsystem()
{
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
80105578:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010557c:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80105580:	7e cd                	jle    8010554f <allocinsystem+0xf>
    s=&stable.sem[i];
    if(s->references==0)
      return s;
  }
  return 0;
80105582:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105587:	c9                   	leave  
80105588:	c3                   	ret    

80105589 <semget>:
// if there is no place in the system's semaphore table, return -3.
// if semid> 0 and the semaphore is not in use, return -1.
// if semid <-1 or semid> MAXSEM, return -4.
int
semget(int semid, int initvalue)
{
80105589:	55                   	push   %ebp
8010558a:	89 e5                	mov    %esp,%ebp
8010558c:	83 ec 18             	sub    $0x18,%esp
  int position=0,retvalue;
8010558f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  struct semaphore* s;

  if(semid<-1 || semid>=MAXSEM)
80105596:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
8010559a:	7c 06                	jl     801055a2 <semget+0x19>
8010559c:	83 7d 08 3f          	cmpl   $0x3f,0x8(%ebp)
801055a0:	7e 0a                	jle    801055ac <semget+0x23>
    return -4;
801055a2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
801055a7:	e9 0d 01 00 00       	jmp    801056b9 <semget+0x130>
  acquire(&stable.lock);
801055ac:	83 ec 0c             	sub    $0xc,%esp
801055af:	68 e0 75 11 80       	push   $0x801175e0
801055b4:	e8 b5 03 00 00       	call   8010596e <acquire>
801055b9:	83 c4 10             	add    $0x10,%esp
  position=allocinprocess();
801055bc:	e8 f9 fe ff ff       	call   801054ba <allocinprocess>
801055c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(position==-1){
801055c4:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
801055c8:	75 0c                	jne    801055d6 <semget+0x4d>
    retvalue=-2;
801055ca:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retget;
801055d1:	e9 d0 00 00 00       	jmp    801056a6 <semget+0x11d>
  }
  if(semid==-1){
801055d6:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
801055da:	75 47                	jne    80105623 <semget+0x9a>
    s=allocinsystem();
801055dc:	e8 5f ff ff ff       	call   80105540 <allocinsystem>
801055e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!s){
801055e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055e8:	75 0c                	jne    801055f6 <semget+0x6d>
      retvalue=-3;
801055ea:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
      goto retget;
801055f1:	e9 b0 00 00 00       	jmp    801056a6 <semget+0x11d>
    }
    s->id=s-stable.sem;
801055f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f9:	ba 14 76 11 80       	mov    $0x80117614,%edx
801055fe:	29 d0                	sub    %edx,%eax
80105600:	c1 f8 02             	sar    $0x2,%eax
80105603:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
80105609:	89 c2                	mov    %eax,%edx
8010560b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560e:	89 10                	mov    %edx,(%eax)
    s->value=initvalue;
80105610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105613:	8b 55 0c             	mov    0xc(%ebp),%edx
80105616:	89 50 08             	mov    %edx,0x8(%eax)
    retvalue=s->id;
80105619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561c:	8b 00                	mov    (%eax),%eax
8010561e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    goto found;
80105621:	eb 61                	jmp    80105684 <semget+0xfb>
  }
  if(semid>=0){
80105623:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105627:	78 5b                	js     80105684 <semget+0xfb>
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
80105629:	c7 45 f0 14 76 11 80 	movl   $0x80117614,-0x10(%ebp)
80105630:	eb 3f                	jmp    80105671 <semget+0xe8>
      if(s->id==semid && ((s->references)>0)){
80105632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105635:	8b 00                	mov    (%eax),%eax
80105637:	3b 45 08             	cmp    0x8(%ebp),%eax
8010563a:	75 14                	jne    80105650 <semget+0xc7>
8010563c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563f:	8b 40 04             	mov    0x4(%eax),%eax
80105642:	85 c0                	test   %eax,%eax
80105644:	7e 0a                	jle    80105650 <semget+0xc7>
        retvalue=s->id;
80105646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105649:	8b 00                	mov    (%eax),%eax
8010564b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto found;
8010564e:	eb 34                	jmp    80105684 <semget+0xfb>
      }
      if(s->id==semid && ((s->references)==0)){
80105650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105653:	8b 00                	mov    (%eax),%eax
80105655:	3b 45 08             	cmp    0x8(%ebp),%eax
80105658:	75 13                	jne    8010566d <semget+0xe4>
8010565a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565d:	8b 40 04             	mov    0x4(%eax),%eax
80105660:	85 c0                	test   %eax,%eax
80105662:	75 09                	jne    8010566d <semget+0xe4>
        retvalue=-1;
80105664:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
        goto retget;
8010566b:	eb 39                	jmp    801056a6 <semget+0x11d>
    s->value=initvalue;
    retvalue=s->id;
    goto found;
  }
  if(semid>=0){
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
8010566d:	83 45 f0 0c          	addl   $0xc,-0x10(%ebp)
80105671:	b8 14 79 11 80       	mov    $0x80117914,%eax
80105676:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80105679:	72 b7                	jb     80105632 <semget+0xa9>
      if(s->id==semid && ((s->references)==0)){
        retvalue=-1;
        goto retget;
      }
    }
    retvalue=-5;
8010567b:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    goto retget;
80105682:	eb 22                	jmp    801056a6 <semget+0x11d>
  }
found:
  s->references++;
80105684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105687:	8b 40 04             	mov    0x4(%eax),%eax
8010568a:	8d 50 01             	lea    0x1(%eax),%edx
8010568d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105690:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[position]=s;
80105693:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105699:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010569c:	8d 4a 20             	lea    0x20(%edx),%ecx
8010569f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056a2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
retget:
  release(&stable.lock);
801056a6:	83 ec 0c             	sub    $0xc,%esp
801056a9:	68 e0 75 11 80       	push   $0x801175e0
801056ae:	e8 22 03 00 00       	call   801059d5 <release>
801056b3:	83 c4 10             	add    $0x10,%esp
  return retvalue;
801056b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056b9:	c9                   	leave  
801056ba:	c3                   	ret    

801056bb <semfree>:

// It releases the semaphore of the process if it is not in use, but only decreases the references in 1.
// if the semaphore is not in the process, return -1.
int
semfree(int semid)
{
801056bb:	55                   	push   %ebp
801056bc:	89 e5                	mov    %esp,%ebp
801056be:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int retvalue,pos;

  acquire(&stable.lock);
801056c1:	83 ec 0c             	sub    $0xc,%esp
801056c4:	68 e0 75 11 80       	push   $0x801175e0
801056c9:	e8 a0 02 00 00       	call   8010596e <acquire>
801056ce:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
801056d1:	83 ec 0c             	sub    $0xc,%esp
801056d4:	ff 75 08             	pushl  0x8(%ebp)
801056d7:	e8 1c fe ff ff       	call   801054f8 <searchinprocess>
801056dc:	83 c4 10             	add    $0x10,%esp
801056df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
801056e2:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801056e6:	75 09                	jne    801056f1 <semfree+0x36>
    retvalue=-1;
801056e8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retfree;
801056ef:	eb 50                	jmp    80105741 <semfree+0x86>
  }
  s=proc->osemaphore[pos];
801056f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056fa:	83 c2 20             	add    $0x20,%edx
801056fd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(s->references < 1){
80105704:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105707:	8b 40 04             	mov    0x4(%eax),%eax
8010570a:	85 c0                	test   %eax,%eax
8010570c:	7f 09                	jg     80105717 <semfree+0x5c>
    retvalue=-2;
8010570e:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retfree;
80105715:	eb 2a                	jmp    80105741 <semfree+0x86>
  }
  s->references--;
80105717:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010571a:	8b 40 04             	mov    0x4(%eax),%eax
8010571d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105720:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105723:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[pos]=0;
80105726:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010572c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010572f:	83 c2 20             	add    $0x20,%edx
80105732:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105739:	00 
  retvalue=0;
8010573a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retfree:
  release(&stable.lock);
80105741:	83 ec 0c             	sub    $0xc,%esp
80105744:	68 e0 75 11 80       	push   $0x801175e0
80105749:	e8 87 02 00 00       	call   801059d5 <release>
8010574e:	83 c4 10             	add    $0x10,%esp
  return retvalue;
80105751:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105754:	c9                   	leave  
80105755:	c3                   	ret    

80105756 <semdown>:

// Decreases the value of the semaphore if it is greater than 0 but sleeps the process.
// if the semaphore is not in the process, return -1.
int
semdown(int semid)
{
80105756:	55                   	push   %ebp
80105757:	89 e5                	mov    %esp,%ebp
80105759:	83 ec 18             	sub    $0x18,%esp
  int value,pos;
  struct semaphore* s;

  acquire(&stable.lock);
8010575c:	83 ec 0c             	sub    $0xc,%esp
8010575f:	68 e0 75 11 80       	push   $0x801175e0
80105764:	e8 05 02 00 00       	call   8010596e <acquire>
80105769:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
8010576c:	83 ec 0c             	sub    $0xc,%esp
8010576f:	ff 75 08             	pushl  0x8(%ebp)
80105772:	e8 81 fd ff ff       	call   801054f8 <searchinprocess>
80105777:	83 c4 10             	add    $0x10,%esp
8010577a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
8010577d:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105781:	75 09                	jne    8010578c <semdown+0x36>
    value=-1;
80105783:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retdown;
8010578a:	eb 48                	jmp    801057d4 <semdown+0x7e>
  }
  s=proc->osemaphore[pos];
8010578c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105792:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105795:	83 c2 20             	add    $0x20,%edx
80105798:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010579c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  while(s->value<=0){
8010579f:	eb 13                	jmp    801057b4 <semdown+0x5e>
    sleep(s,&stable.lock);
801057a1:	83 ec 08             	sub    $0x8,%esp
801057a4:	68 e0 75 11 80       	push   $0x801175e0
801057a9:	ff 75 ec             	pushl  -0x14(%ebp)
801057ac:	e8 01 fa ff ff       	call   801051b2 <sleep>
801057b1:	83 c4 10             	add    $0x10,%esp
  if(pos==-1){
    value=-1;
    goto retdown;
  }
  s=proc->osemaphore[pos];
  while(s->value<=0){
801057b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801057b7:	8b 40 08             	mov    0x8(%eax),%eax
801057ba:	85 c0                	test   %eax,%eax
801057bc:	7e e3                	jle    801057a1 <semdown+0x4b>
    sleep(s,&stable.lock);
  }
  s->value--;
801057be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801057c1:	8b 40 08             	mov    0x8(%eax),%eax
801057c4:	8d 50 ff             	lea    -0x1(%eax),%edx
801057c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801057ca:	89 50 08             	mov    %edx,0x8(%eax)
  value=0;
801057cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retdown:
  release(&stable.lock);
801057d4:	83 ec 0c             	sub    $0xc,%esp
801057d7:	68 e0 75 11 80       	push   $0x801175e0
801057dc:	e8 f4 01 00 00       	call   801059d5 <release>
801057e1:	83 c4 10             	add    $0x10,%esp
  return value;
801057e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057e7:	c9                   	leave  
801057e8:	c3                   	ret    

801057e9 <semup>:

// It increases the value of the semaphore and wake up processes waiting for it.
// if the semaphore is not in the process, return -1.
int
semup(int semid)
{
801057e9:	55                   	push   %ebp
801057ea:	89 e5                	mov    %esp,%ebp
801057ec:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int pos;

  acquire(&stable.lock);
801057ef:	83 ec 0c             	sub    $0xc,%esp
801057f2:	68 e0 75 11 80       	push   $0x801175e0
801057f7:	e8 72 01 00 00       	call   8010596e <acquire>
801057fc:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
801057ff:	83 ec 0c             	sub    $0xc,%esp
80105802:	ff 75 08             	pushl  0x8(%ebp)
80105805:	e8 ee fc ff ff       	call   801054f8 <searchinprocess>
8010580a:	83 c4 10             	add    $0x10,%esp
8010580d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pos==-1){
80105810:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105814:	75 17                	jne    8010582d <semup+0x44>
    release(&stable.lock);
80105816:	83 ec 0c             	sub    $0xc,%esp
80105819:	68 e0 75 11 80       	push   $0x801175e0
8010581e:	e8 b2 01 00 00       	call   801059d5 <release>
80105823:	83 c4 10             	add    $0x10,%esp
    return -1;
80105826:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582b:	eb 45                	jmp    80105872 <semup+0x89>
  }
  s=proc->osemaphore[pos];
8010582d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105833:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105836:	83 c2 20             	add    $0x20,%edx
80105839:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010583d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->value++;
80105840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105843:	8b 40 08             	mov    0x8(%eax),%eax
80105846:	8d 50 01             	lea    0x1(%eax),%edx
80105849:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&stable.lock);
8010584f:	83 ec 0c             	sub    $0xc,%esp
80105852:	68 e0 75 11 80       	push   $0x801175e0
80105857:	e8 79 01 00 00       	call   801059d5 <release>
8010585c:	83 c4 10             	add    $0x10,%esp
  wakeup(s);
8010585f:	83 ec 0c             	sub    $0xc,%esp
80105862:	ff 75 f0             	pushl  -0x10(%ebp)
80105865:	e8 54 fa ff ff       	call   801052be <wakeup>
8010586a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010586d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105872:	c9                   	leave  
80105873:	c3                   	ret    

80105874 <semclose>:

// Decrease the semaphore references.
void
semclose(struct semaphore* s)
{
80105874:	55                   	push   %ebp
80105875:	89 e5                	mov    %esp,%ebp
80105877:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
8010587a:	83 ec 0c             	sub    $0xc,%esp
8010587d:	68 e0 75 11 80       	push   $0x801175e0
80105882:	e8 e7 00 00 00       	call   8010596e <acquire>
80105887:	83 c4 10             	add    $0x10,%esp

  if(s->references < 1)
8010588a:	8b 45 08             	mov    0x8(%ebp),%eax
8010588d:	8b 40 04             	mov    0x4(%eax),%eax
80105890:	85 c0                	test   %eax,%eax
80105892:	7f 0d                	jg     801058a1 <semclose+0x2d>
    panic("semclose");
80105894:	83 ec 0c             	sub    $0xc,%esp
80105897:	68 78 97 10 80       	push   $0x80109778
8010589c:	e8 c5 ac ff ff       	call   80100566 <panic>
  s->references--;
801058a1:	8b 45 08             	mov    0x8(%ebp),%eax
801058a4:	8b 40 04             	mov    0x4(%eax),%eax
801058a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801058aa:	8b 45 08             	mov    0x8(%ebp),%eax
801058ad:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
801058b0:	83 ec 0c             	sub    $0xc,%esp
801058b3:	68 e0 75 11 80       	push   $0x801175e0
801058b8:	e8 18 01 00 00       	call   801059d5 <release>
801058bd:	83 c4 10             	add    $0x10,%esp
  return;
801058c0:	90                   	nop

}
801058c1:	c9                   	leave  
801058c2:	c3                   	ret    

801058c3 <semdup>:

// Increase the semaphore references.
struct semaphore*
semdup(struct semaphore* s)
{
801058c3:	55                   	push   %ebp
801058c4:	89 e5                	mov    %esp,%ebp
801058c6:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
801058c9:	83 ec 0c             	sub    $0xc,%esp
801058cc:	68 e0 75 11 80       	push   $0x801175e0
801058d1:	e8 98 00 00 00       	call   8010596e <acquire>
801058d6:	83 c4 10             	add    $0x10,%esp
  if(s->references<0)
801058d9:	8b 45 08             	mov    0x8(%ebp),%eax
801058dc:	8b 40 04             	mov    0x4(%eax),%eax
801058df:	85 c0                	test   %eax,%eax
801058e1:	79 0d                	jns    801058f0 <semdup+0x2d>
    panic("semdup error");
801058e3:	83 ec 0c             	sub    $0xc,%esp
801058e6:	68 81 97 10 80       	push   $0x80109781
801058eb:	e8 76 ac ff ff       	call   80100566 <panic>
  s->references++;
801058f0:	8b 45 08             	mov    0x8(%ebp),%eax
801058f3:	8b 40 04             	mov    0x4(%eax),%eax
801058f6:	8d 50 01             	lea    0x1(%eax),%edx
801058f9:	8b 45 08             	mov    0x8(%ebp),%eax
801058fc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
801058ff:	83 ec 0c             	sub    $0xc,%esp
80105902:	68 e0 75 11 80       	push   $0x801175e0
80105907:	e8 c9 00 00 00       	call   801059d5 <release>
8010590c:	83 c4 10             	add    $0x10,%esp
  return s;
8010590f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105912:	c9                   	leave  
80105913:	c3                   	ret    

80105914 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105914:	55                   	push   %ebp
80105915:	89 e5                	mov    %esp,%ebp
80105917:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010591a:	9c                   	pushf  
8010591b:	58                   	pop    %eax
8010591c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010591f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105922:	c9                   	leave  
80105923:	c3                   	ret    

80105924 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105924:	55                   	push   %ebp
80105925:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105927:	fa                   	cli    
}
80105928:	90                   	nop
80105929:	5d                   	pop    %ebp
8010592a:	c3                   	ret    

8010592b <sti>:

static inline void
sti(void)
{
8010592b:	55                   	push   %ebp
8010592c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010592e:	fb                   	sti    
}
8010592f:	90                   	nop
80105930:	5d                   	pop    %ebp
80105931:	c3                   	ret    

80105932 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105932:	55                   	push   %ebp
80105933:	89 e5                	mov    %esp,%ebp
80105935:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105938:	8b 55 08             	mov    0x8(%ebp),%edx
8010593b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010593e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105941:	f0 87 02             	lock xchg %eax,(%edx)
80105944:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105947:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010594a:	c9                   	leave  
8010594b:	c3                   	ret    

8010594c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010594c:	55                   	push   %ebp
8010594d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010594f:	8b 45 08             	mov    0x8(%ebp),%eax
80105952:	8b 55 0c             	mov    0xc(%ebp),%edx
80105955:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105958:	8b 45 08             	mov    0x8(%ebp),%eax
8010595b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105961:	8b 45 08             	mov    0x8(%ebp),%eax
80105964:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010596b:	90                   	nop
8010596c:	5d                   	pop    %ebp
8010596d:	c3                   	ret    

8010596e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010596e:	55                   	push   %ebp
8010596f:	89 e5                	mov    %esp,%ebp
80105971:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105974:	e8 52 01 00 00       	call   80105acb <pushcli>
  if(holding(lk))
80105979:	8b 45 08             	mov    0x8(%ebp),%eax
8010597c:	83 ec 0c             	sub    $0xc,%esp
8010597f:	50                   	push   %eax
80105980:	e8 1c 01 00 00       	call   80105aa1 <holding>
80105985:	83 c4 10             	add    $0x10,%esp
80105988:	85 c0                	test   %eax,%eax
8010598a:	74 0d                	je     80105999 <acquire+0x2b>
    panic("acquire");
8010598c:	83 ec 0c             	sub    $0xc,%esp
8010598f:	68 8e 97 10 80       	push   $0x8010978e
80105994:	e8 cd ab ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while(xchg(&lk->locked, 1) != 0)
80105999:	90                   	nop
8010599a:	8b 45 08             	mov    0x8(%ebp),%eax
8010599d:	83 ec 08             	sub    $0x8,%esp
801059a0:	6a 01                	push   $0x1
801059a2:	50                   	push   %eax
801059a3:	e8 8a ff ff ff       	call   80105932 <xchg>
801059a8:	83 c4 10             	add    $0x10,%esp
801059ab:	85 c0                	test   %eax,%eax
801059ad:	75 eb                	jne    8010599a <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801059af:	8b 45 08             	mov    0x8(%ebp),%eax
801059b2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801059b9:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801059bc:	8b 45 08             	mov    0x8(%ebp),%eax
801059bf:	83 c0 0c             	add    $0xc,%eax
801059c2:	83 ec 08             	sub    $0x8,%esp
801059c5:	50                   	push   %eax
801059c6:	8d 45 08             	lea    0x8(%ebp),%eax
801059c9:	50                   	push   %eax
801059ca:	e8 58 00 00 00       	call   80105a27 <getcallerpcs>
801059cf:	83 c4 10             	add    $0x10,%esp
}
801059d2:	90                   	nop
801059d3:	c9                   	leave  
801059d4:	c3                   	ret    

801059d5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801059d5:	55                   	push   %ebp
801059d6:	89 e5                	mov    %esp,%ebp
801059d8:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801059db:	83 ec 0c             	sub    $0xc,%esp
801059de:	ff 75 08             	pushl  0x8(%ebp)
801059e1:	e8 bb 00 00 00       	call   80105aa1 <holding>
801059e6:	83 c4 10             	add    $0x10,%esp
801059e9:	85 c0                	test   %eax,%eax
801059eb:	75 0d                	jne    801059fa <release+0x25>
    panic("release");
801059ed:	83 ec 0c             	sub    $0xc,%esp
801059f0:	68 96 97 10 80       	push   $0x80109796
801059f5:	e8 6c ab ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801059fa:	8b 45 08             	mov    0x8(%ebp),%eax
801059fd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105a04:	8b 45 08             	mov    0x8(%ebp),%eax
80105a07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a11:	83 ec 08             	sub    $0x8,%esp
80105a14:	6a 00                	push   $0x0
80105a16:	50                   	push   %eax
80105a17:	e8 16 ff ff ff       	call   80105932 <xchg>
80105a1c:	83 c4 10             	add    $0x10,%esp

  popcli();
80105a1f:	e8 ec 00 00 00       	call   80105b10 <popcli>
}
80105a24:	90                   	nop
80105a25:	c9                   	leave  
80105a26:	c3                   	ret    

80105a27 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105a27:	55                   	push   %ebp
80105a28:	89 e5                	mov    %esp,%ebp
80105a2a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80105a30:	83 e8 08             	sub    $0x8,%eax
80105a33:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105a36:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105a3d:	eb 38                	jmp    80105a77 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105a3f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105a43:	74 53                	je     80105a98 <getcallerpcs+0x71>
80105a45:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105a4c:	76 4a                	jbe    80105a98 <getcallerpcs+0x71>
80105a4e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105a52:	74 44                	je     80105a98 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105a54:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a57:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a61:	01 c2                	add    %eax,%edx
80105a63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a66:	8b 40 04             	mov    0x4(%eax),%eax
80105a69:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105a6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a6e:	8b 00                	mov    (%eax),%eax
80105a70:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105a73:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105a77:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a7b:	7e c2                	jle    80105a3f <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a7d:	eb 19                	jmp    80105a98 <getcallerpcs+0x71>
    pcs[i] = 0;
80105a7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a8c:	01 d0                	add    %edx,%eax
80105a8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a94:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105a98:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a9c:	7e e1                	jle    80105a7f <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105a9e:	90                   	nop
80105a9f:	c9                   	leave  
80105aa0:	c3                   	ret    

80105aa1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105aa1:	55                   	push   %ebp
80105aa2:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80105aa7:	8b 00                	mov    (%eax),%eax
80105aa9:	85 c0                	test   %eax,%eax
80105aab:	74 17                	je     80105ac4 <holding+0x23>
80105aad:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab0:	8b 50 08             	mov    0x8(%eax),%edx
80105ab3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ab9:	39 c2                	cmp    %eax,%edx
80105abb:	75 07                	jne    80105ac4 <holding+0x23>
80105abd:	b8 01 00 00 00       	mov    $0x1,%eax
80105ac2:	eb 05                	jmp    80105ac9 <holding+0x28>
80105ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ac9:	5d                   	pop    %ebp
80105aca:	c3                   	ret    

80105acb <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105acb:	55                   	push   %ebp
80105acc:	89 e5                	mov    %esp,%ebp
80105ace:	83 ec 10             	sub    $0x10,%esp
  int eflags;

  eflags = readeflags();
80105ad1:	e8 3e fe ff ff       	call   80105914 <readeflags>
80105ad6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105ad9:	e8 46 fe ff ff       	call   80105924 <cli>
  if(cpu->ncli++ == 0)
80105ade:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105ae5:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105aeb:	8d 48 01             	lea    0x1(%eax),%ecx
80105aee:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105af4:	85 c0                	test   %eax,%eax
80105af6:	75 15                	jne    80105b0d <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105af8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105afe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b01:	81 e2 00 02 00 00    	and    $0x200,%edx
80105b07:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105b0d:	90                   	nop
80105b0e:	c9                   	leave  
80105b0f:	c3                   	ret    

80105b10 <popcli>:

void
popcli(void)
{
80105b10:	55                   	push   %ebp
80105b11:	89 e5                	mov    %esp,%ebp
80105b13:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105b16:	e8 f9 fd ff ff       	call   80105914 <readeflags>
80105b1b:	25 00 02 00 00       	and    $0x200,%eax
80105b20:	85 c0                	test   %eax,%eax
80105b22:	74 0d                	je     80105b31 <popcli+0x21>
    panic("popcli - interruptible");
80105b24:	83 ec 0c             	sub    $0xc,%esp
80105b27:	68 9e 97 10 80       	push   $0x8010979e
80105b2c:	e8 35 aa ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105b31:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b37:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105b3d:	83 ea 01             	sub    $0x1,%edx
80105b40:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105b46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	79 0d                	jns    80105b5d <popcli+0x4d>
    panic("popcli");
80105b50:	83 ec 0c             	sub    $0xc,%esp
80105b53:	68 b5 97 10 80       	push   $0x801097b5
80105b58:	e8 09 aa ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105b5d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b63:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105b69:	85 c0                	test   %eax,%eax
80105b6b:	75 15                	jne    80105b82 <popcli+0x72>
80105b6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b73:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105b79:	85 c0                	test   %eax,%eax
80105b7b:	74 05                	je     80105b82 <popcli+0x72>
    sti();
80105b7d:	e8 a9 fd ff ff       	call   8010592b <sti>
}
80105b82:	90                   	nop
80105b83:	c9                   	leave  
80105b84:	c3                   	ret    

80105b85 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105b85:	55                   	push   %ebp
80105b86:	89 e5                	mov    %esp,%ebp
80105b88:	57                   	push   %edi
80105b89:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b8d:	8b 55 10             	mov    0x10(%ebp),%edx
80105b90:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b93:	89 cb                	mov    %ecx,%ebx
80105b95:	89 df                	mov    %ebx,%edi
80105b97:	89 d1                	mov    %edx,%ecx
80105b99:	fc                   	cld    
80105b9a:	f3 aa                	rep stos %al,%es:(%edi)
80105b9c:	89 ca                	mov    %ecx,%edx
80105b9e:	89 fb                	mov    %edi,%ebx
80105ba0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105ba3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105ba6:	90                   	nop
80105ba7:	5b                   	pop    %ebx
80105ba8:	5f                   	pop    %edi
80105ba9:	5d                   	pop    %ebp
80105baa:	c3                   	ret    

80105bab <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105bab:	55                   	push   %ebp
80105bac:	89 e5                	mov    %esp,%ebp
80105bae:	57                   	push   %edi
80105baf:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105bb3:	8b 55 10             	mov    0x10(%ebp),%edx
80105bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bb9:	89 cb                	mov    %ecx,%ebx
80105bbb:	89 df                	mov    %ebx,%edi
80105bbd:	89 d1                	mov    %edx,%ecx
80105bbf:	fc                   	cld    
80105bc0:	f3 ab                	rep stos %eax,%es:(%edi)
80105bc2:	89 ca                	mov    %ecx,%edx
80105bc4:	89 fb                	mov    %edi,%ebx
80105bc6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105bc9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105bcc:	90                   	nop
80105bcd:	5b                   	pop    %ebx
80105bce:	5f                   	pop    %edi
80105bcf:	5d                   	pop    %ebp
80105bd0:	c3                   	ret    

80105bd1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105bd1:	55                   	push   %ebp
80105bd2:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd7:	83 e0 03             	and    $0x3,%eax
80105bda:	85 c0                	test   %eax,%eax
80105bdc:	75 43                	jne    80105c21 <memset+0x50>
80105bde:	8b 45 10             	mov    0x10(%ebp),%eax
80105be1:	83 e0 03             	and    $0x3,%eax
80105be4:	85 c0                	test   %eax,%eax
80105be6:	75 39                	jne    80105c21 <memset+0x50>
    c &= 0xFF;
80105be8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105bef:	8b 45 10             	mov    0x10(%ebp),%eax
80105bf2:	c1 e8 02             	shr    $0x2,%eax
80105bf5:	89 c1                	mov    %eax,%ecx
80105bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bfa:	c1 e0 18             	shl    $0x18,%eax
80105bfd:	89 c2                	mov    %eax,%edx
80105bff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c02:	c1 e0 10             	shl    $0x10,%eax
80105c05:	09 c2                	or     %eax,%edx
80105c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c0a:	c1 e0 08             	shl    $0x8,%eax
80105c0d:	09 d0                	or     %edx,%eax
80105c0f:	0b 45 0c             	or     0xc(%ebp),%eax
80105c12:	51                   	push   %ecx
80105c13:	50                   	push   %eax
80105c14:	ff 75 08             	pushl  0x8(%ebp)
80105c17:	e8 8f ff ff ff       	call   80105bab <stosl>
80105c1c:	83 c4 0c             	add    $0xc,%esp
80105c1f:	eb 12                	jmp    80105c33 <memset+0x62>
  } else
    stosb(dst, c, n);
80105c21:	8b 45 10             	mov    0x10(%ebp),%eax
80105c24:	50                   	push   %eax
80105c25:	ff 75 0c             	pushl  0xc(%ebp)
80105c28:	ff 75 08             	pushl  0x8(%ebp)
80105c2b:	e8 55 ff ff ff       	call   80105b85 <stosb>
80105c30:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105c33:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105c36:	c9                   	leave  
80105c37:	c3                   	ret    

80105c38 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105c38:	55                   	push   %ebp
80105c39:	89 e5                	mov    %esp,%ebp
80105c3b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c41:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105c44:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c47:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105c4a:	eb 30                	jmp    80105c7c <memcmp+0x44>
    if(*s1 != *s2)
80105c4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c4f:	0f b6 10             	movzbl (%eax),%edx
80105c52:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c55:	0f b6 00             	movzbl (%eax),%eax
80105c58:	38 c2                	cmp    %al,%dl
80105c5a:	74 18                	je     80105c74 <memcmp+0x3c>
      return *s1 - *s2;
80105c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c5f:	0f b6 00             	movzbl (%eax),%eax
80105c62:	0f b6 d0             	movzbl %al,%edx
80105c65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c68:	0f b6 00             	movzbl (%eax),%eax
80105c6b:	0f b6 c0             	movzbl %al,%eax
80105c6e:	29 c2                	sub    %eax,%edx
80105c70:	89 d0                	mov    %edx,%eax
80105c72:	eb 1a                	jmp    80105c8e <memcmp+0x56>
    s1++, s2++;
80105c74:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105c78:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105c7c:	8b 45 10             	mov    0x10(%ebp),%eax
80105c7f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c82:	89 55 10             	mov    %edx,0x10(%ebp)
80105c85:	85 c0                	test   %eax,%eax
80105c87:	75 c3                	jne    80105c4c <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105c89:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c8e:	c9                   	leave  
80105c8f:	c3                   	ret    

80105c90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105c90:	55                   	push   %ebp
80105c91:	89 e5                	mov    %esp,%ebp
80105c93:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105c96:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c99:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c9f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ca2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ca5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ca8:	73 54                	jae    80105cfe <memmove+0x6e>
80105caa:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105cad:	8b 45 10             	mov    0x10(%ebp),%eax
80105cb0:	01 d0                	add    %edx,%eax
80105cb2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105cb5:	76 47                	jbe    80105cfe <memmove+0x6e>
    s += n;
80105cb7:	8b 45 10             	mov    0x10(%ebp),%eax
80105cba:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105cbd:	8b 45 10             	mov    0x10(%ebp),%eax
80105cc0:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105cc3:	eb 13                	jmp    80105cd8 <memmove+0x48>
      *--d = *--s;
80105cc5:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105cc9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cd0:	0f b6 10             	movzbl (%eax),%edx
80105cd3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cd6:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105cd8:	8b 45 10             	mov    0x10(%ebp),%eax
80105cdb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cde:	89 55 10             	mov    %edx,0x10(%ebp)
80105ce1:	85 c0                	test   %eax,%eax
80105ce3:	75 e0                	jne    80105cc5 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105ce5:	eb 24                	jmp    80105d0b <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105ce7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cea:	8d 50 01             	lea    0x1(%eax),%edx
80105ced:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105cf0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105cf3:	8d 4a 01             	lea    0x1(%edx),%ecx
80105cf6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105cf9:	0f b6 12             	movzbl (%edx),%edx
80105cfc:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105cfe:	8b 45 10             	mov    0x10(%ebp),%eax
80105d01:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d04:	89 55 10             	mov    %edx,0x10(%ebp)
80105d07:	85 c0                	test   %eax,%eax
80105d09:	75 dc                	jne    80105ce7 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105d0b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105d0e:	c9                   	leave  
80105d0f:	c3                   	ret    

80105d10 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105d10:	55                   	push   %ebp
80105d11:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105d13:	ff 75 10             	pushl  0x10(%ebp)
80105d16:	ff 75 0c             	pushl  0xc(%ebp)
80105d19:	ff 75 08             	pushl  0x8(%ebp)
80105d1c:	e8 6f ff ff ff       	call   80105c90 <memmove>
80105d21:	83 c4 0c             	add    $0xc,%esp
}
80105d24:	c9                   	leave  
80105d25:	c3                   	ret    

80105d26 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105d26:	55                   	push   %ebp
80105d27:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105d29:	eb 0c                	jmp    80105d37 <strncmp+0x11>
    n--, p++, q++;
80105d2b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105d2f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105d33:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105d37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d3b:	74 1a                	je     80105d57 <strncmp+0x31>
80105d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105d40:	0f b6 00             	movzbl (%eax),%eax
80105d43:	84 c0                	test   %al,%al
80105d45:	74 10                	je     80105d57 <strncmp+0x31>
80105d47:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4a:	0f b6 10             	movzbl (%eax),%edx
80105d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d50:	0f b6 00             	movzbl (%eax),%eax
80105d53:	38 c2                	cmp    %al,%dl
80105d55:	74 d4                	je     80105d2b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105d57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d5b:	75 07                	jne    80105d64 <strncmp+0x3e>
    return 0;
80105d5d:	b8 00 00 00 00       	mov    $0x0,%eax
80105d62:	eb 16                	jmp    80105d7a <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105d64:	8b 45 08             	mov    0x8(%ebp),%eax
80105d67:	0f b6 00             	movzbl (%eax),%eax
80105d6a:	0f b6 d0             	movzbl %al,%edx
80105d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d70:	0f b6 00             	movzbl (%eax),%eax
80105d73:	0f b6 c0             	movzbl %al,%eax
80105d76:	29 c2                	sub    %eax,%edx
80105d78:	89 d0                	mov    %edx,%eax
}
80105d7a:	5d                   	pop    %ebp
80105d7b:	c3                   	ret    

80105d7c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105d7c:	55                   	push   %ebp
80105d7d:	89 e5                	mov    %esp,%ebp
80105d7f:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105d82:	8b 45 08             	mov    0x8(%ebp),%eax
80105d85:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105d88:	90                   	nop
80105d89:	8b 45 10             	mov    0x10(%ebp),%eax
80105d8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d8f:	89 55 10             	mov    %edx,0x10(%ebp)
80105d92:	85 c0                	test   %eax,%eax
80105d94:	7e 2c                	jle    80105dc2 <strncpy+0x46>
80105d96:	8b 45 08             	mov    0x8(%ebp),%eax
80105d99:	8d 50 01             	lea    0x1(%eax),%edx
80105d9c:	89 55 08             	mov    %edx,0x8(%ebp)
80105d9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105da2:	8d 4a 01             	lea    0x1(%edx),%ecx
80105da5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105da8:	0f b6 12             	movzbl (%edx),%edx
80105dab:	88 10                	mov    %dl,(%eax)
80105dad:	0f b6 00             	movzbl (%eax),%eax
80105db0:	84 c0                	test   %al,%al
80105db2:	75 d5                	jne    80105d89 <strncpy+0xd>
    ;
  while(n-- > 0)
80105db4:	eb 0c                	jmp    80105dc2 <strncpy+0x46>
    *s++ = 0;
80105db6:	8b 45 08             	mov    0x8(%ebp),%eax
80105db9:	8d 50 01             	lea    0x1(%eax),%edx
80105dbc:	89 55 08             	mov    %edx,0x8(%ebp)
80105dbf:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105dc2:	8b 45 10             	mov    0x10(%ebp),%eax
80105dc5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dc8:	89 55 10             	mov    %edx,0x10(%ebp)
80105dcb:	85 c0                	test   %eax,%eax
80105dcd:	7f e7                	jg     80105db6 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105dcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dd2:	c9                   	leave  
80105dd3:	c3                   	ret    

80105dd4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105dd4:	55                   	push   %ebp
80105dd5:	89 e5                	mov    %esp,%ebp
80105dd7:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105dda:	8b 45 08             	mov    0x8(%ebp),%eax
80105ddd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105de0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105de4:	7f 05                	jg     80105deb <safestrcpy+0x17>
    return os;
80105de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105de9:	eb 31                	jmp    80105e1c <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105deb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105def:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105df3:	7e 1e                	jle    80105e13 <safestrcpy+0x3f>
80105df5:	8b 45 08             	mov    0x8(%ebp),%eax
80105df8:	8d 50 01             	lea    0x1(%eax),%edx
80105dfb:	89 55 08             	mov    %edx,0x8(%ebp)
80105dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
80105e01:	8d 4a 01             	lea    0x1(%edx),%ecx
80105e04:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105e07:	0f b6 12             	movzbl (%edx),%edx
80105e0a:	88 10                	mov    %dl,(%eax)
80105e0c:	0f b6 00             	movzbl (%eax),%eax
80105e0f:	84 c0                	test   %al,%al
80105e11:	75 d8                	jne    80105deb <safestrcpy+0x17>
    ;
  *s = 0;
80105e13:	8b 45 08             	mov    0x8(%ebp),%eax
80105e16:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105e19:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e1c:	c9                   	leave  
80105e1d:	c3                   	ret    

80105e1e <strlen>:

int
strlen(const char *s)
{
80105e1e:	55                   	push   %ebp
80105e1f:	89 e5                	mov    %esp,%ebp
80105e21:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105e24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105e2b:	eb 04                	jmp    80105e31 <strlen+0x13>
80105e2d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e31:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e34:	8b 45 08             	mov    0x8(%ebp),%eax
80105e37:	01 d0                	add    %edx,%eax
80105e39:	0f b6 00             	movzbl (%eax),%eax
80105e3c:	84 c0                	test   %al,%al
80105e3e:	75 ed                	jne    80105e2d <strlen+0xf>
    ;
  return n;
80105e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e43:	c9                   	leave  
80105e44:	c3                   	ret    

80105e45 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105e45:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105e49:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105e4d:	55                   	push   %ebp
  pushl %ebx
80105e4e:	53                   	push   %ebx
  pushl %esi
80105e4f:	56                   	push   %esi
  pushl %edi
80105e50:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105e51:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105e53:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105e55:	5f                   	pop    %edi
  popl %esi
80105e56:	5e                   	pop    %esi
  popl %ebx
80105e57:	5b                   	pop    %ebx
  popl %ebp
80105e58:	5d                   	pop    %ebp
  ret
80105e59:	c3                   	ret    

80105e5a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105e5a:	55                   	push   %ebp
80105e5b:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105e5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e63:	8b 00                	mov    (%eax),%eax
80105e65:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e68:	76 12                	jbe    80105e7c <fetchint+0x22>
80105e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6d:	8d 50 04             	lea    0x4(%eax),%edx
80105e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e76:	8b 00                	mov    (%eax),%eax
80105e78:	39 c2                	cmp    %eax,%edx
80105e7a:	76 07                	jbe    80105e83 <fetchint+0x29>
    return -1;
80105e7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e81:	eb 0f                	jmp    80105e92 <fetchint+0x38>
  *ip = *(int*)(addr);
80105e83:	8b 45 08             	mov    0x8(%ebp),%eax
80105e86:	8b 10                	mov    (%eax),%edx
80105e88:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e8b:	89 10                	mov    %edx,(%eax)
  return 0;
80105e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e92:	5d                   	pop    %ebp
80105e93:	c3                   	ret    

80105e94 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105e94:	55                   	push   %ebp
80105e95:	89 e5                	mov    %esp,%ebp
80105e97:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105e9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ea0:	8b 00                	mov    (%eax),%eax
80105ea2:	3b 45 08             	cmp    0x8(%ebp),%eax
80105ea5:	77 07                	ja     80105eae <fetchstr+0x1a>
    return -1;
80105ea7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eac:	eb 46                	jmp    80105ef4 <fetchstr+0x60>
  *pp = (char*)addr;
80105eae:	8b 55 08             	mov    0x8(%ebp),%edx
80105eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb4:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105eb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ebc:	8b 00                	mov    (%eax),%eax
80105ebe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ec4:	8b 00                	mov    (%eax),%eax
80105ec6:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105ec9:	eb 1c                	jmp    80105ee7 <fetchstr+0x53>
    if(*s == 0)
80105ecb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ece:	0f b6 00             	movzbl (%eax),%eax
80105ed1:	84 c0                	test   %al,%al
80105ed3:	75 0e                	jne    80105ee3 <fetchstr+0x4f>
      return s - *pp;
80105ed5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105edb:	8b 00                	mov    (%eax),%eax
80105edd:	29 c2                	sub    %eax,%edx
80105edf:	89 d0                	mov    %edx,%eax
80105ee1:	eb 11                	jmp    80105ef4 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105ee3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ee7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105eed:	72 dc                	jb     80105ecb <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ef4:	c9                   	leave  
80105ef5:	c3                   	ret    

80105ef6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105ef6:	55                   	push   %ebp
80105ef7:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105eff:	8b 40 18             	mov    0x18(%eax),%eax
80105f02:	8b 40 44             	mov    0x44(%eax),%eax
80105f05:	8b 55 08             	mov    0x8(%ebp),%edx
80105f08:	c1 e2 02             	shl    $0x2,%edx
80105f0b:	01 d0                	add    %edx,%eax
80105f0d:	83 c0 04             	add    $0x4,%eax
80105f10:	ff 75 0c             	pushl  0xc(%ebp)
80105f13:	50                   	push   %eax
80105f14:	e8 41 ff ff ff       	call   80105e5a <fetchint>
80105f19:	83 c4 08             	add    $0x8,%esp
}
80105f1c:	c9                   	leave  
80105f1d:	c3                   	ret    

80105f1e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105f1e:	55                   	push   %ebp
80105f1f:	89 e5                	mov    %esp,%ebp
80105f21:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80105f24:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105f27:	50                   	push   %eax
80105f28:	ff 75 08             	pushl  0x8(%ebp)
80105f2b:	e8 c6 ff ff ff       	call   80105ef6 <argint>
80105f30:	83 c4 08             	add    $0x8,%esp
80105f33:	85 c0                	test   %eax,%eax
80105f35:	79 07                	jns    80105f3e <argptr+0x20>
    return -1;
80105f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3c:	eb 3b                	jmp    80105f79 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105f3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f44:	8b 00                	mov    (%eax),%eax
80105f46:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f49:	39 d0                	cmp    %edx,%eax
80105f4b:	76 16                	jbe    80105f63 <argptr+0x45>
80105f4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f50:	89 c2                	mov    %eax,%edx
80105f52:	8b 45 10             	mov    0x10(%ebp),%eax
80105f55:	01 c2                	add    %eax,%edx
80105f57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f5d:	8b 00                	mov    (%eax),%eax
80105f5f:	39 c2                	cmp    %eax,%edx
80105f61:	76 07                	jbe    80105f6a <argptr+0x4c>
    return -1;
80105f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f68:	eb 0f                	jmp    80105f79 <argptr+0x5b>
  *pp = (char*)i;
80105f6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f6d:	89 c2                	mov    %eax,%edx
80105f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f72:	89 10                	mov    %edx,(%eax)
  return 0;
80105f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f79:	c9                   	leave  
80105f7a:	c3                   	ret    

80105f7b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105f7b:	55                   	push   %ebp
80105f7c:	89 e5                	mov    %esp,%ebp
80105f7e:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105f81:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105f84:	50                   	push   %eax
80105f85:	ff 75 08             	pushl  0x8(%ebp)
80105f88:	e8 69 ff ff ff       	call   80105ef6 <argint>
80105f8d:	83 c4 08             	add    $0x8,%esp
80105f90:	85 c0                	test   %eax,%eax
80105f92:	79 07                	jns    80105f9b <argstr+0x20>
    return -1;
80105f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f99:	eb 0f                	jmp    80105faa <argstr+0x2f>
  return fetchstr(addr, pp);
80105f9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f9e:	ff 75 0c             	pushl  0xc(%ebp)
80105fa1:	50                   	push   %eax
80105fa2:	e8 ed fe ff ff       	call   80105e94 <fetchstr>
80105fa7:	83 c4 08             	add    $0x8,%esp
}
80105faa:	c9                   	leave  
80105fab:	c3                   	ret    

80105fac <syscall>:
[SYS_mmap]   sys_mmap
};

void
syscall(void)
{
80105fac:	55                   	push   %ebp
80105fad:	89 e5                	mov    %esp,%ebp
80105faf:	53                   	push   %ebx
80105fb0:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105fb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fb9:	8b 40 18             	mov    0x18(%eax),%eax
80105fbc:	8b 40 1c             	mov    0x1c(%eax),%eax
80105fbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105fc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc6:	7e 30                	jle    80105ff8 <syscall+0x4c>
80105fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcb:	83 f8 1d             	cmp    $0x1d,%eax
80105fce:	77 28                	ja     80105ff8 <syscall+0x4c>
80105fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd3:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105fda:	85 c0                	test   %eax,%eax
80105fdc:	74 1a                	je     80105ff8 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105fde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fe4:	8b 58 18             	mov    0x18(%eax),%ebx
80105fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fea:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105ff1:	ff d0                	call   *%eax
80105ff3:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105ff6:	eb 34                	jmp    8010602c <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105ff8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ffe:	8d 50 6c             	lea    0x6c(%eax),%edx
80106001:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106007:	8b 40 10             	mov    0x10(%eax),%eax
8010600a:	ff 75 f4             	pushl  -0xc(%ebp)
8010600d:	52                   	push   %edx
8010600e:	50                   	push   %eax
8010600f:	68 bc 97 10 80       	push   $0x801097bc
80106014:	e8 ad a3 ff ff       	call   801003c6 <cprintf>
80106019:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010601c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106022:	8b 40 18             	mov    0x18(%eax),%eax
80106025:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010602c:	90                   	nop
8010602d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106030:	c9                   	leave  
80106031:	c3                   	ret    

80106032 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106032:	55                   	push   %ebp
80106033:	89 e5                	mov    %esp,%ebp
80106035:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106038:	83 ec 08             	sub    $0x8,%esp
8010603b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010603e:	50                   	push   %eax
8010603f:	ff 75 08             	pushl  0x8(%ebp)
80106042:	e8 af fe ff ff       	call   80105ef6 <argint>
80106047:	83 c4 10             	add    $0x10,%esp
8010604a:	85 c0                	test   %eax,%eax
8010604c:	79 07                	jns    80106055 <argfd+0x23>
    return -1;
8010604e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106053:	eb 50                	jmp    801060a5 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106058:	85 c0                	test   %eax,%eax
8010605a:	78 21                	js     8010607d <argfd+0x4b>
8010605c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605f:	83 f8 0f             	cmp    $0xf,%eax
80106062:	7f 19                	jg     8010607d <argfd+0x4b>
80106064:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010606a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010606d:	83 c2 08             	add    $0x8,%edx
80106070:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106074:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106077:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010607b:	75 07                	jne    80106084 <argfd+0x52>
    return -1;
8010607d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106082:	eb 21                	jmp    801060a5 <argfd+0x73>
  if(pfd)
80106084:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106088:	74 08                	je     80106092 <argfd+0x60>
    *pfd = fd;
8010608a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010608d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106090:	89 10                	mov    %edx,(%eax)
  if(pf)
80106092:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106096:	74 08                	je     801060a0 <argfd+0x6e>
    *pf = f;
80106098:	8b 45 10             	mov    0x10(%ebp),%eax
8010609b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010609e:	89 10                	mov    %edx,(%eax)
  return 0;
801060a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a5:	c9                   	leave  
801060a6:	c3                   	ret    

801060a7 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801060a7:	55                   	push   %ebp
801060a8:	89 e5                	mov    %esp,%ebp
801060aa:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801060ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801060b4:	eb 30                	jmp    801060e6 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801060b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060bf:	83 c2 08             	add    $0x8,%edx
801060c2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801060c6:	85 c0                	test   %eax,%eax
801060c8:	75 18                	jne    801060e2 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801060ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060d3:	8d 4a 08             	lea    0x8(%edx),%ecx
801060d6:	8b 55 08             	mov    0x8(%ebp),%edx
801060d9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801060dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060e0:	eb 0f                	jmp    801060f1 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801060e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060e6:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801060ea:	7e ca                	jle    801060b6 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801060ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060f1:	c9                   	leave  
801060f2:	c3                   	ret    

801060f3 <sys_dup>:

int
sys_dup(void)
{
801060f3:	55                   	push   %ebp
801060f4:	89 e5                	mov    %esp,%ebp
801060f6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801060f9:	83 ec 04             	sub    $0x4,%esp
801060fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060ff:	50                   	push   %eax
80106100:	6a 00                	push   $0x0
80106102:	6a 00                	push   $0x0
80106104:	e8 29 ff ff ff       	call   80106032 <argfd>
80106109:	83 c4 10             	add    $0x10,%esp
8010610c:	85 c0                	test   %eax,%eax
8010610e:	79 07                	jns    80106117 <sys_dup+0x24>
    return -1;
80106110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106115:	eb 31                	jmp    80106148 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611a:	83 ec 0c             	sub    $0xc,%esp
8010611d:	50                   	push   %eax
8010611e:	e8 84 ff ff ff       	call   801060a7 <fdalloc>
80106123:	83 c4 10             	add    $0x10,%esp
80106126:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106129:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612d:	79 07                	jns    80106136 <sys_dup+0x43>
    return -1;
8010612f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106134:	eb 12                	jmp    80106148 <sys_dup+0x55>
  filedup(f);
80106136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106139:	83 ec 0c             	sub    $0xc,%esp
8010613c:	50                   	push   %eax
8010613d:	e8 ab ae ff ff       	call   80100fed <filedup>
80106142:	83 c4 10             	add    $0x10,%esp
  return fd;
80106145:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106148:	c9                   	leave  
80106149:	c3                   	ret    

8010614a <sys_read>:

int
sys_read(void)
{
8010614a:	55                   	push   %ebp
8010614b:	89 e5                	mov    %esp,%ebp
8010614d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106150:	83 ec 04             	sub    $0x4,%esp
80106153:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106156:	50                   	push   %eax
80106157:	6a 00                	push   $0x0
80106159:	6a 00                	push   $0x0
8010615b:	e8 d2 fe ff ff       	call   80106032 <argfd>
80106160:	83 c4 10             	add    $0x10,%esp
80106163:	85 c0                	test   %eax,%eax
80106165:	78 2e                	js     80106195 <sys_read+0x4b>
80106167:	83 ec 08             	sub    $0x8,%esp
8010616a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010616d:	50                   	push   %eax
8010616e:	6a 02                	push   $0x2
80106170:	e8 81 fd ff ff       	call   80105ef6 <argint>
80106175:	83 c4 10             	add    $0x10,%esp
80106178:	85 c0                	test   %eax,%eax
8010617a:	78 19                	js     80106195 <sys_read+0x4b>
8010617c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617f:	83 ec 04             	sub    $0x4,%esp
80106182:	50                   	push   %eax
80106183:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106186:	50                   	push   %eax
80106187:	6a 01                	push   $0x1
80106189:	e8 90 fd ff ff       	call   80105f1e <argptr>
8010618e:	83 c4 10             	add    $0x10,%esp
80106191:	85 c0                	test   %eax,%eax
80106193:	79 07                	jns    8010619c <sys_read+0x52>
    return -1;
80106195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619a:	eb 17                	jmp    801061b3 <sys_read+0x69>
  return fileread(f, p, n);
8010619c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010619f:	8b 55 ec             	mov    -0x14(%ebp),%edx
801061a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a5:	83 ec 04             	sub    $0x4,%esp
801061a8:	51                   	push   %ecx
801061a9:	52                   	push   %edx
801061aa:	50                   	push   %eax
801061ab:	e8 cd af ff ff       	call   8010117d <fileread>
801061b0:	83 c4 10             	add    $0x10,%esp
}
801061b3:	c9                   	leave  
801061b4:	c3                   	ret    

801061b5 <sys_write>:

int
sys_write(void)
{
801061b5:	55                   	push   %ebp
801061b6:	89 e5                	mov    %esp,%ebp
801061b8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801061bb:	83 ec 04             	sub    $0x4,%esp
801061be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061c1:	50                   	push   %eax
801061c2:	6a 00                	push   $0x0
801061c4:	6a 00                	push   $0x0
801061c6:	e8 67 fe ff ff       	call   80106032 <argfd>
801061cb:	83 c4 10             	add    $0x10,%esp
801061ce:	85 c0                	test   %eax,%eax
801061d0:	78 2e                	js     80106200 <sys_write+0x4b>
801061d2:	83 ec 08             	sub    $0x8,%esp
801061d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061d8:	50                   	push   %eax
801061d9:	6a 02                	push   $0x2
801061db:	e8 16 fd ff ff       	call   80105ef6 <argint>
801061e0:	83 c4 10             	add    $0x10,%esp
801061e3:	85 c0                	test   %eax,%eax
801061e5:	78 19                	js     80106200 <sys_write+0x4b>
801061e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ea:	83 ec 04             	sub    $0x4,%esp
801061ed:	50                   	push   %eax
801061ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061f1:	50                   	push   %eax
801061f2:	6a 01                	push   $0x1
801061f4:	e8 25 fd ff ff       	call   80105f1e <argptr>
801061f9:	83 c4 10             	add    $0x10,%esp
801061fc:	85 c0                	test   %eax,%eax
801061fe:	79 07                	jns    80106207 <sys_write+0x52>
    return -1;
80106200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106205:	eb 17                	jmp    8010621e <sys_write+0x69>
  return filewrite(f, p, n);
80106207:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010620a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010620d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106210:	83 ec 04             	sub    $0x4,%esp
80106213:	51                   	push   %ecx
80106214:	52                   	push   %edx
80106215:	50                   	push   %eax
80106216:	e8 1a b0 ff ff       	call   80101235 <filewrite>
8010621b:	83 c4 10             	add    $0x10,%esp
}
8010621e:	c9                   	leave  
8010621f:	c3                   	ret    

80106220 <sys_close>:

int
sys_close(void)
{
80106220:	55                   	push   %ebp
80106221:	89 e5                	mov    %esp,%ebp
80106223:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106226:	83 ec 04             	sub    $0x4,%esp
80106229:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010622c:	50                   	push   %eax
8010622d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106230:	50                   	push   %eax
80106231:	6a 00                	push   $0x0
80106233:	e8 fa fd ff ff       	call   80106032 <argfd>
80106238:	83 c4 10             	add    $0x10,%esp
8010623b:	85 c0                	test   %eax,%eax
8010623d:	79 07                	jns    80106246 <sys_close+0x26>
    return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	eb 28                	jmp    8010626e <sys_close+0x4e>
  proc->ofile[fd] = 0;
80106246:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010624c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010624f:	83 c2 08             	add    $0x8,%edx
80106252:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106259:	00 
  fileclose(f);
8010625a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625d:	83 ec 0c             	sub    $0xc,%esp
80106260:	50                   	push   %eax
80106261:	e8 d8 ad ff ff       	call   8010103e <fileclose>
80106266:	83 c4 10             	add    $0x10,%esp
  return 0;
80106269:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010626e:	c9                   	leave  
8010626f:	c3                   	ret    

80106270 <sys_fstat>:

int
sys_fstat(void)
{
80106270:	55                   	push   %ebp
80106271:	89 e5                	mov    %esp,%ebp
80106273:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106276:	83 ec 04             	sub    $0x4,%esp
80106279:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010627c:	50                   	push   %eax
8010627d:	6a 00                	push   $0x0
8010627f:	6a 00                	push   $0x0
80106281:	e8 ac fd ff ff       	call   80106032 <argfd>
80106286:	83 c4 10             	add    $0x10,%esp
80106289:	85 c0                	test   %eax,%eax
8010628b:	78 17                	js     801062a4 <sys_fstat+0x34>
8010628d:	83 ec 04             	sub    $0x4,%esp
80106290:	6a 14                	push   $0x14
80106292:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106295:	50                   	push   %eax
80106296:	6a 01                	push   $0x1
80106298:	e8 81 fc ff ff       	call   80105f1e <argptr>
8010629d:	83 c4 10             	add    $0x10,%esp
801062a0:	85 c0                	test   %eax,%eax
801062a2:	79 07                	jns    801062ab <sys_fstat+0x3b>
    return -1;
801062a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a9:	eb 13                	jmp    801062be <sys_fstat+0x4e>
  return filestat(f, st);
801062ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b1:	83 ec 08             	sub    $0x8,%esp
801062b4:	52                   	push   %edx
801062b5:	50                   	push   %eax
801062b6:	e8 6b ae ff ff       	call   80101126 <filestat>
801062bb:	83 c4 10             	add    $0x10,%esp
}
801062be:	c9                   	leave  
801062bf:	c3                   	ret    

801062c0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801062c0:	55                   	push   %ebp
801062c1:	89 e5                	mov    %esp,%ebp
801062c3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801062c6:	83 ec 08             	sub    $0x8,%esp
801062c9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801062cc:	50                   	push   %eax
801062cd:	6a 00                	push   $0x0
801062cf:	e8 a7 fc ff ff       	call   80105f7b <argstr>
801062d4:	83 c4 10             	add    $0x10,%esp
801062d7:	85 c0                	test   %eax,%eax
801062d9:	78 15                	js     801062f0 <sys_link+0x30>
801062db:	83 ec 08             	sub    $0x8,%esp
801062de:	8d 45 dc             	lea    -0x24(%ebp),%eax
801062e1:	50                   	push   %eax
801062e2:	6a 01                	push   $0x1
801062e4:	e8 92 fc ff ff       	call   80105f7b <argstr>
801062e9:	83 c4 10             	add    $0x10,%esp
801062ec:	85 c0                	test   %eax,%eax
801062ee:	79 0a                	jns    801062fa <sys_link+0x3a>
    return -1;
801062f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f5:	e9 68 01 00 00       	jmp    80106462 <sys_link+0x1a2>

  begin_op();
801062fa:	e8 18 d2 ff ff       	call   80103517 <begin_op>
  if((ip = namei(old)) == 0){
801062ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106302:	83 ec 0c             	sub    $0xc,%esp
80106305:	50                   	push   %eax
80106306:	e8 1b c2 ff ff       	call   80102526 <namei>
8010630b:	83 c4 10             	add    $0x10,%esp
8010630e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106311:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106315:	75 0f                	jne    80106326 <sys_link+0x66>
    end_op();
80106317:	e8 87 d2 ff ff       	call   801035a3 <end_op>
    return -1;
8010631c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106321:	e9 3c 01 00 00       	jmp    80106462 <sys_link+0x1a2>
  }

  ilock(ip);
80106326:	83 ec 0c             	sub    $0xc,%esp
80106329:	ff 75 f4             	pushl  -0xc(%ebp)
8010632c:	e8 3d b6 ff ff       	call   8010196e <ilock>
80106331:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80106334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106337:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010633b:	66 83 f8 01          	cmp    $0x1,%ax
8010633f:	75 1d                	jne    8010635e <sys_link+0x9e>
    iunlockput(ip);
80106341:	83 ec 0c             	sub    $0xc,%esp
80106344:	ff 75 f4             	pushl  -0xc(%ebp)
80106347:	e8 dc b8 ff ff       	call   80101c28 <iunlockput>
8010634c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010634f:	e8 4f d2 ff ff       	call   801035a3 <end_op>
    return -1;
80106354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106359:	e9 04 01 00 00       	jmp    80106462 <sys_link+0x1a2>
  }

  ip->nlink++;
8010635e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106361:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106365:	83 c0 01             	add    $0x1,%eax
80106368:	89 c2                	mov    %eax,%edx
8010636a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106371:	83 ec 0c             	sub    $0xc,%esp
80106374:	ff 75 f4             	pushl  -0xc(%ebp)
80106377:	e8 1e b4 ff ff       	call   8010179a <iupdate>
8010637c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010637f:	83 ec 0c             	sub    $0xc,%esp
80106382:	ff 75 f4             	pushl  -0xc(%ebp)
80106385:	e8 3c b7 ff ff       	call   80101ac6 <iunlock>
8010638a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010638d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106390:	83 ec 08             	sub    $0x8,%esp
80106393:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106396:	52                   	push   %edx
80106397:	50                   	push   %eax
80106398:	e8 a5 c1 ff ff       	call   80102542 <nameiparent>
8010639d:	83 c4 10             	add    $0x10,%esp
801063a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063a7:	74 71                	je     8010641a <sys_link+0x15a>
    goto bad;
  ilock(dp);
801063a9:	83 ec 0c             	sub    $0xc,%esp
801063ac:	ff 75 f0             	pushl  -0x10(%ebp)
801063af:	e8 ba b5 ff ff       	call   8010196e <ilock>
801063b4:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801063b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ba:	8b 10                	mov    (%eax),%edx
801063bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bf:	8b 00                	mov    (%eax),%eax
801063c1:	39 c2                	cmp    %eax,%edx
801063c3:	75 1d                	jne    801063e2 <sys_link+0x122>
801063c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c8:	8b 40 04             	mov    0x4(%eax),%eax
801063cb:	83 ec 04             	sub    $0x4,%esp
801063ce:	50                   	push   %eax
801063cf:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801063d2:	50                   	push   %eax
801063d3:	ff 75 f0             	pushl  -0x10(%ebp)
801063d6:	e8 af be ff ff       	call   8010228a <dirlink>
801063db:	83 c4 10             	add    $0x10,%esp
801063de:	85 c0                	test   %eax,%eax
801063e0:	79 10                	jns    801063f2 <sys_link+0x132>
    iunlockput(dp);
801063e2:	83 ec 0c             	sub    $0xc,%esp
801063e5:	ff 75 f0             	pushl  -0x10(%ebp)
801063e8:	e8 3b b8 ff ff       	call   80101c28 <iunlockput>
801063ed:	83 c4 10             	add    $0x10,%esp
    goto bad;
801063f0:	eb 29                	jmp    8010641b <sys_link+0x15b>
  }
  iunlockput(dp);
801063f2:	83 ec 0c             	sub    $0xc,%esp
801063f5:	ff 75 f0             	pushl  -0x10(%ebp)
801063f8:	e8 2b b8 ff ff       	call   80101c28 <iunlockput>
801063fd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106400:	83 ec 0c             	sub    $0xc,%esp
80106403:	ff 75 f4             	pushl  -0xc(%ebp)
80106406:	e8 2d b7 ff ff       	call   80101b38 <iput>
8010640b:	83 c4 10             	add    $0x10,%esp

  end_op();
8010640e:	e8 90 d1 ff ff       	call   801035a3 <end_op>

  return 0;
80106413:	b8 00 00 00 00       	mov    $0x0,%eax
80106418:	eb 48                	jmp    80106462 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010641a:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
8010641b:	83 ec 0c             	sub    $0xc,%esp
8010641e:	ff 75 f4             	pushl  -0xc(%ebp)
80106421:	e8 48 b5 ff ff       	call   8010196e <ilock>
80106426:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106430:	83 e8 01             	sub    $0x1,%eax
80106433:	89 c2                	mov    %eax,%edx
80106435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106438:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010643c:	83 ec 0c             	sub    $0xc,%esp
8010643f:	ff 75 f4             	pushl  -0xc(%ebp)
80106442:	e8 53 b3 ff ff       	call   8010179a <iupdate>
80106447:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010644a:	83 ec 0c             	sub    $0xc,%esp
8010644d:	ff 75 f4             	pushl  -0xc(%ebp)
80106450:	e8 d3 b7 ff ff       	call   80101c28 <iunlockput>
80106455:	83 c4 10             	add    $0x10,%esp
  end_op();
80106458:	e8 46 d1 ff ff       	call   801035a3 <end_op>
  return -1;
8010645d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106462:	c9                   	leave  
80106463:	c3                   	ret    

80106464 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106464:	55                   	push   %ebp
80106465:	89 e5                	mov    %esp,%ebp
80106467:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010646a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106471:	eb 40                	jmp    801064b3 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106476:	6a 10                	push   $0x10
80106478:	50                   	push   %eax
80106479:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010647c:	50                   	push   %eax
8010647d:	ff 75 08             	pushl  0x8(%ebp)
80106480:	e8 51 ba ff ff       	call   80101ed6 <readi>
80106485:	83 c4 10             	add    $0x10,%esp
80106488:	83 f8 10             	cmp    $0x10,%eax
8010648b:	74 0d                	je     8010649a <isdirempty+0x36>
      panic("isdirempty: readi");
8010648d:	83 ec 0c             	sub    $0xc,%esp
80106490:	68 d8 97 10 80       	push   $0x801097d8
80106495:	e8 cc a0 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010649a:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010649e:	66 85 c0             	test   %ax,%ax
801064a1:	74 07                	je     801064aa <isdirempty+0x46>
      return 0;
801064a3:	b8 00 00 00 00       	mov    $0x0,%eax
801064a8:	eb 1b                	jmp    801064c5 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801064aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ad:	83 c0 10             	add    $0x10,%eax
801064b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b3:	8b 45 08             	mov    0x8(%ebp),%eax
801064b6:	8b 50 18             	mov    0x18(%eax),%edx
801064b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bc:	39 c2                	cmp    %eax,%edx
801064be:	77 b3                	ja     80106473 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801064c0:	b8 01 00 00 00       	mov    $0x1,%eax
}
801064c5:	c9                   	leave  
801064c6:	c3                   	ret    

801064c7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801064c7:	55                   	push   %ebp
801064c8:	89 e5                	mov    %esp,%ebp
801064ca:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801064cd:	83 ec 08             	sub    $0x8,%esp
801064d0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801064d3:	50                   	push   %eax
801064d4:	6a 00                	push   $0x0
801064d6:	e8 a0 fa ff ff       	call   80105f7b <argstr>
801064db:	83 c4 10             	add    $0x10,%esp
801064de:	85 c0                	test   %eax,%eax
801064e0:	79 0a                	jns    801064ec <sys_unlink+0x25>
    return -1;
801064e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e7:	e9 bc 01 00 00       	jmp    801066a8 <sys_unlink+0x1e1>

  begin_op();
801064ec:	e8 26 d0 ff ff       	call   80103517 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801064f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801064f4:	83 ec 08             	sub    $0x8,%esp
801064f7:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801064fa:	52                   	push   %edx
801064fb:	50                   	push   %eax
801064fc:	e8 41 c0 ff ff       	call   80102542 <nameiparent>
80106501:	83 c4 10             	add    $0x10,%esp
80106504:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106507:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010650b:	75 0f                	jne    8010651c <sys_unlink+0x55>
    end_op();
8010650d:	e8 91 d0 ff ff       	call   801035a3 <end_op>
    return -1;
80106512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106517:	e9 8c 01 00 00       	jmp    801066a8 <sys_unlink+0x1e1>
  }

  ilock(dp);
8010651c:	83 ec 0c             	sub    $0xc,%esp
8010651f:	ff 75 f4             	pushl  -0xc(%ebp)
80106522:	e8 47 b4 ff ff       	call   8010196e <ilock>
80106527:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010652a:	83 ec 08             	sub    $0x8,%esp
8010652d:	68 ea 97 10 80       	push   $0x801097ea
80106532:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106535:	50                   	push   %eax
80106536:	e8 7a bc ff ff       	call   801021b5 <namecmp>
8010653b:	83 c4 10             	add    $0x10,%esp
8010653e:	85 c0                	test   %eax,%eax
80106540:	0f 84 4a 01 00 00    	je     80106690 <sys_unlink+0x1c9>
80106546:	83 ec 08             	sub    $0x8,%esp
80106549:	68 ec 97 10 80       	push   $0x801097ec
8010654e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106551:	50                   	push   %eax
80106552:	e8 5e bc ff ff       	call   801021b5 <namecmp>
80106557:	83 c4 10             	add    $0x10,%esp
8010655a:	85 c0                	test   %eax,%eax
8010655c:	0f 84 2e 01 00 00    	je     80106690 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106562:	83 ec 04             	sub    $0x4,%esp
80106565:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106568:	50                   	push   %eax
80106569:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010656c:	50                   	push   %eax
8010656d:	ff 75 f4             	pushl  -0xc(%ebp)
80106570:	e8 5b bc ff ff       	call   801021d0 <dirlookup>
80106575:	83 c4 10             	add    $0x10,%esp
80106578:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010657b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657f:	0f 84 0a 01 00 00    	je     8010668f <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106585:	83 ec 0c             	sub    $0xc,%esp
80106588:	ff 75 f0             	pushl  -0x10(%ebp)
8010658b:	e8 de b3 ff ff       	call   8010196e <ilock>
80106590:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106596:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010659a:	66 85 c0             	test   %ax,%ax
8010659d:	7f 0d                	jg     801065ac <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010659f:	83 ec 0c             	sub    $0xc,%esp
801065a2:	68 ef 97 10 80       	push   $0x801097ef
801065a7:	e8 ba 9f ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801065ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065af:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065b3:	66 83 f8 01          	cmp    $0x1,%ax
801065b7:	75 25                	jne    801065de <sys_unlink+0x117>
801065b9:	83 ec 0c             	sub    $0xc,%esp
801065bc:	ff 75 f0             	pushl  -0x10(%ebp)
801065bf:	e8 a0 fe ff ff       	call   80106464 <isdirempty>
801065c4:	83 c4 10             	add    $0x10,%esp
801065c7:	85 c0                	test   %eax,%eax
801065c9:	75 13                	jne    801065de <sys_unlink+0x117>
    iunlockput(ip);
801065cb:	83 ec 0c             	sub    $0xc,%esp
801065ce:	ff 75 f0             	pushl  -0x10(%ebp)
801065d1:	e8 52 b6 ff ff       	call   80101c28 <iunlockput>
801065d6:	83 c4 10             	add    $0x10,%esp
    goto bad;
801065d9:	e9 b2 00 00 00       	jmp    80106690 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801065de:	83 ec 04             	sub    $0x4,%esp
801065e1:	6a 10                	push   $0x10
801065e3:	6a 00                	push   $0x0
801065e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065e8:	50                   	push   %eax
801065e9:	e8 e3 f5 ff ff       	call   80105bd1 <memset>
801065ee:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801065f4:	6a 10                	push   $0x10
801065f6:	50                   	push   %eax
801065f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065fa:	50                   	push   %eax
801065fb:	ff 75 f4             	pushl  -0xc(%ebp)
801065fe:	e8 2a ba ff ff       	call   8010202d <writei>
80106603:	83 c4 10             	add    $0x10,%esp
80106606:	83 f8 10             	cmp    $0x10,%eax
80106609:	74 0d                	je     80106618 <sys_unlink+0x151>
    panic("unlink: writei");
8010660b:	83 ec 0c             	sub    $0xc,%esp
8010660e:	68 01 98 10 80       	push   $0x80109801
80106613:	e8 4e 9f ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010661f:	66 83 f8 01          	cmp    $0x1,%ax
80106623:	75 21                	jne    80106646 <sys_unlink+0x17f>
    dp->nlink--;
80106625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106628:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010662c:	83 e8 01             	sub    $0x1,%eax
8010662f:	89 c2                	mov    %eax,%edx
80106631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106634:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106638:	83 ec 0c             	sub    $0xc,%esp
8010663b:	ff 75 f4             	pushl  -0xc(%ebp)
8010663e:	e8 57 b1 ff ff       	call   8010179a <iupdate>
80106643:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106646:	83 ec 0c             	sub    $0xc,%esp
80106649:	ff 75 f4             	pushl  -0xc(%ebp)
8010664c:	e8 d7 b5 ff ff       	call   80101c28 <iunlockput>
80106651:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106657:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010665b:	83 e8 01             	sub    $0x1,%eax
8010665e:	89 c2                	mov    %eax,%edx
80106660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106663:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106667:	83 ec 0c             	sub    $0xc,%esp
8010666a:	ff 75 f0             	pushl  -0x10(%ebp)
8010666d:	e8 28 b1 ff ff       	call   8010179a <iupdate>
80106672:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106675:	83 ec 0c             	sub    $0xc,%esp
80106678:	ff 75 f0             	pushl  -0x10(%ebp)
8010667b:	e8 a8 b5 ff ff       	call   80101c28 <iunlockput>
80106680:	83 c4 10             	add    $0x10,%esp

  end_op();
80106683:	e8 1b cf ff ff       	call   801035a3 <end_op>

  return 0;
80106688:	b8 00 00 00 00       	mov    $0x0,%eax
8010668d:	eb 19                	jmp    801066a8 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010668f:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106690:	83 ec 0c             	sub    $0xc,%esp
80106693:	ff 75 f4             	pushl  -0xc(%ebp)
80106696:	e8 8d b5 ff ff       	call   80101c28 <iunlockput>
8010669b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010669e:	e8 00 cf ff ff       	call   801035a3 <end_op>
  return -1;
801066a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066a8:	c9                   	leave  
801066a9:	c3                   	ret    

801066aa <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801066aa:	55                   	push   %ebp
801066ab:	89 e5                	mov    %esp,%ebp
801066ad:	83 ec 38             	sub    $0x38,%esp
801066b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801066b3:	8b 55 10             	mov    0x10(%ebp),%edx
801066b6:	8b 45 14             	mov    0x14(%ebp),%eax
801066b9:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801066bd:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801066c1:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801066c5:	83 ec 08             	sub    $0x8,%esp
801066c8:	8d 45 de             	lea    -0x22(%ebp),%eax
801066cb:	50                   	push   %eax
801066cc:	ff 75 08             	pushl  0x8(%ebp)
801066cf:	e8 6e be ff ff       	call   80102542 <nameiparent>
801066d4:	83 c4 10             	add    $0x10,%esp
801066d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066de:	75 0a                	jne    801066ea <create+0x40>
    return 0;
801066e0:	b8 00 00 00 00       	mov    $0x0,%eax
801066e5:	e9 90 01 00 00       	jmp    8010687a <create+0x1d0>
  ilock(dp);
801066ea:	83 ec 0c             	sub    $0xc,%esp
801066ed:	ff 75 f4             	pushl  -0xc(%ebp)
801066f0:	e8 79 b2 ff ff       	call   8010196e <ilock>
801066f5:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801066f8:	83 ec 04             	sub    $0x4,%esp
801066fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066fe:	50                   	push   %eax
801066ff:	8d 45 de             	lea    -0x22(%ebp),%eax
80106702:	50                   	push   %eax
80106703:	ff 75 f4             	pushl  -0xc(%ebp)
80106706:	e8 c5 ba ff ff       	call   801021d0 <dirlookup>
8010670b:	83 c4 10             	add    $0x10,%esp
8010670e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106711:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106715:	74 50                	je     80106767 <create+0xbd>
    iunlockput(dp);
80106717:	83 ec 0c             	sub    $0xc,%esp
8010671a:	ff 75 f4             	pushl  -0xc(%ebp)
8010671d:	e8 06 b5 ff ff       	call   80101c28 <iunlockput>
80106722:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106725:	83 ec 0c             	sub    $0xc,%esp
80106728:	ff 75 f0             	pushl  -0x10(%ebp)
8010672b:	e8 3e b2 ff ff       	call   8010196e <ilock>
80106730:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106733:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106738:	75 15                	jne    8010674f <create+0xa5>
8010673a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106741:	66 83 f8 02          	cmp    $0x2,%ax
80106745:	75 08                	jne    8010674f <create+0xa5>
      return ip;
80106747:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674a:	e9 2b 01 00 00       	jmp    8010687a <create+0x1d0>
    iunlockput(ip);
8010674f:	83 ec 0c             	sub    $0xc,%esp
80106752:	ff 75 f0             	pushl  -0x10(%ebp)
80106755:	e8 ce b4 ff ff       	call   80101c28 <iunlockput>
8010675a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010675d:	b8 00 00 00 00       	mov    $0x0,%eax
80106762:	e9 13 01 00 00       	jmp    8010687a <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106767:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010676b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676e:	8b 00                	mov    (%eax),%eax
80106770:	83 ec 08             	sub    $0x8,%esp
80106773:	52                   	push   %edx
80106774:	50                   	push   %eax
80106775:	e8 3f af ff ff       	call   801016b9 <ialloc>
8010677a:	83 c4 10             	add    $0x10,%esp
8010677d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106780:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106784:	75 0d                	jne    80106793 <create+0xe9>
    panic("create: ialloc");
80106786:	83 ec 0c             	sub    $0xc,%esp
80106789:	68 10 98 10 80       	push   $0x80109810
8010678e:	e8 d3 9d ff ff       	call   80100566 <panic>

  ilock(ip);
80106793:	83 ec 0c             	sub    $0xc,%esp
80106796:	ff 75 f0             	pushl  -0x10(%ebp)
80106799:	e8 d0 b1 ff ff       	call   8010196e <ilock>
8010679e:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801067a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a4:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801067a8:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801067ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067af:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801067b3:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801067b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ba:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801067c0:	83 ec 0c             	sub    $0xc,%esp
801067c3:	ff 75 f0             	pushl  -0x10(%ebp)
801067c6:	e8 cf af ff ff       	call   8010179a <iupdate>
801067cb:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801067ce:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801067d3:	75 6a                	jne    8010683f <create+0x195>
    dp->nlink++;  // for ".."
801067d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067dc:	83 c0 01             	add    $0x1,%eax
801067df:	89 c2                	mov    %eax,%edx
801067e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801067e8:	83 ec 0c             	sub    $0xc,%esp
801067eb:	ff 75 f4             	pushl  -0xc(%ebp)
801067ee:	e8 a7 af ff ff       	call   8010179a <iupdate>
801067f3:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801067f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f9:	8b 40 04             	mov    0x4(%eax),%eax
801067fc:	83 ec 04             	sub    $0x4,%esp
801067ff:	50                   	push   %eax
80106800:	68 ea 97 10 80       	push   $0x801097ea
80106805:	ff 75 f0             	pushl  -0x10(%ebp)
80106808:	e8 7d ba ff ff       	call   8010228a <dirlink>
8010680d:	83 c4 10             	add    $0x10,%esp
80106810:	85 c0                	test   %eax,%eax
80106812:	78 1e                	js     80106832 <create+0x188>
80106814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106817:	8b 40 04             	mov    0x4(%eax),%eax
8010681a:	83 ec 04             	sub    $0x4,%esp
8010681d:	50                   	push   %eax
8010681e:	68 ec 97 10 80       	push   $0x801097ec
80106823:	ff 75 f0             	pushl  -0x10(%ebp)
80106826:	e8 5f ba ff ff       	call   8010228a <dirlink>
8010682b:	83 c4 10             	add    $0x10,%esp
8010682e:	85 c0                	test   %eax,%eax
80106830:	79 0d                	jns    8010683f <create+0x195>
      panic("create dots");
80106832:	83 ec 0c             	sub    $0xc,%esp
80106835:	68 1f 98 10 80       	push   $0x8010981f
8010683a:	e8 27 9d ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010683f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106842:	8b 40 04             	mov    0x4(%eax),%eax
80106845:	83 ec 04             	sub    $0x4,%esp
80106848:	50                   	push   %eax
80106849:	8d 45 de             	lea    -0x22(%ebp),%eax
8010684c:	50                   	push   %eax
8010684d:	ff 75 f4             	pushl  -0xc(%ebp)
80106850:	e8 35 ba ff ff       	call   8010228a <dirlink>
80106855:	83 c4 10             	add    $0x10,%esp
80106858:	85 c0                	test   %eax,%eax
8010685a:	79 0d                	jns    80106869 <create+0x1bf>
    panic("create: dirlink");
8010685c:	83 ec 0c             	sub    $0xc,%esp
8010685f:	68 2b 98 10 80       	push   $0x8010982b
80106864:	e8 fd 9c ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106869:	83 ec 0c             	sub    $0xc,%esp
8010686c:	ff 75 f4             	pushl  -0xc(%ebp)
8010686f:	e8 b4 b3 ff ff       	call   80101c28 <iunlockput>
80106874:	83 c4 10             	add    $0x10,%esp

  return ip;
80106877:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010687a:	c9                   	leave  
8010687b:	c3                   	ret    

8010687c <sys_open>:

int
sys_open(void)
{
8010687c:	55                   	push   %ebp
8010687d:	89 e5                	mov    %esp,%ebp
8010687f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106882:	83 ec 08             	sub    $0x8,%esp
80106885:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106888:	50                   	push   %eax
80106889:	6a 00                	push   $0x0
8010688b:	e8 eb f6 ff ff       	call   80105f7b <argstr>
80106890:	83 c4 10             	add    $0x10,%esp
80106893:	85 c0                	test   %eax,%eax
80106895:	78 15                	js     801068ac <sys_open+0x30>
80106897:	83 ec 08             	sub    $0x8,%esp
8010689a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010689d:	50                   	push   %eax
8010689e:	6a 01                	push   $0x1
801068a0:	e8 51 f6 ff ff       	call   80105ef6 <argint>
801068a5:	83 c4 10             	add    $0x10,%esp
801068a8:	85 c0                	test   %eax,%eax
801068aa:	79 0a                	jns    801068b6 <sys_open+0x3a>
    return -1;
801068ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b1:	e9 61 01 00 00       	jmp    80106a17 <sys_open+0x19b>

  begin_op();
801068b6:	e8 5c cc ff ff       	call   80103517 <begin_op>

  if(omode & O_CREATE){
801068bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068be:	25 00 02 00 00       	and    $0x200,%eax
801068c3:	85 c0                	test   %eax,%eax
801068c5:	74 2a                	je     801068f1 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801068c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068ca:	6a 00                	push   $0x0
801068cc:	6a 00                	push   $0x0
801068ce:	6a 02                	push   $0x2
801068d0:	50                   	push   %eax
801068d1:	e8 d4 fd ff ff       	call   801066aa <create>
801068d6:	83 c4 10             	add    $0x10,%esp
801068d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801068dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068e0:	75 75                	jne    80106957 <sys_open+0xdb>
      end_op();
801068e2:	e8 bc cc ff ff       	call   801035a3 <end_op>
      return -1;
801068e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ec:	e9 26 01 00 00       	jmp    80106a17 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801068f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068f4:	83 ec 0c             	sub    $0xc,%esp
801068f7:	50                   	push   %eax
801068f8:	e8 29 bc ff ff       	call   80102526 <namei>
801068fd:	83 c4 10             	add    $0x10,%esp
80106900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106907:	75 0f                	jne    80106918 <sys_open+0x9c>
      end_op();
80106909:	e8 95 cc ff ff       	call   801035a3 <end_op>
      return -1;
8010690e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106913:	e9 ff 00 00 00       	jmp    80106a17 <sys_open+0x19b>
    }
    ilock(ip);
80106918:	83 ec 0c             	sub    $0xc,%esp
8010691b:	ff 75 f4             	pushl  -0xc(%ebp)
8010691e:	e8 4b b0 ff ff       	call   8010196e <ilock>
80106923:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106929:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010692d:	66 83 f8 01          	cmp    $0x1,%ax
80106931:	75 24                	jne    80106957 <sys_open+0xdb>
80106933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106936:	85 c0                	test   %eax,%eax
80106938:	74 1d                	je     80106957 <sys_open+0xdb>
      iunlockput(ip);
8010693a:	83 ec 0c             	sub    $0xc,%esp
8010693d:	ff 75 f4             	pushl  -0xc(%ebp)
80106940:	e8 e3 b2 ff ff       	call   80101c28 <iunlockput>
80106945:	83 c4 10             	add    $0x10,%esp
      end_op();
80106948:	e8 56 cc ff ff       	call   801035a3 <end_op>
      return -1;
8010694d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106952:	e9 c0 00 00 00       	jmp    80106a17 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106957:	e8 24 a6 ff ff       	call   80100f80 <filealloc>
8010695c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010695f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106963:	74 17                	je     8010697c <sys_open+0x100>
80106965:	83 ec 0c             	sub    $0xc,%esp
80106968:	ff 75 f0             	pushl  -0x10(%ebp)
8010696b:	e8 37 f7 ff ff       	call   801060a7 <fdalloc>
80106970:	83 c4 10             	add    $0x10,%esp
80106973:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106976:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010697a:	79 2e                	jns    801069aa <sys_open+0x12e>
    if(f)
8010697c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106980:	74 0e                	je     80106990 <sys_open+0x114>
      fileclose(f);
80106982:	83 ec 0c             	sub    $0xc,%esp
80106985:	ff 75 f0             	pushl  -0x10(%ebp)
80106988:	e8 b1 a6 ff ff       	call   8010103e <fileclose>
8010698d:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106990:	83 ec 0c             	sub    $0xc,%esp
80106993:	ff 75 f4             	pushl  -0xc(%ebp)
80106996:	e8 8d b2 ff ff       	call   80101c28 <iunlockput>
8010699b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010699e:	e8 00 cc ff ff       	call   801035a3 <end_op>
    return -1;
801069a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a8:	eb 6d                	jmp    80106a17 <sys_open+0x19b>
  }
  iunlock(ip);
801069aa:	83 ec 0c             	sub    $0xc,%esp
801069ad:	ff 75 f4             	pushl  -0xc(%ebp)
801069b0:	e8 11 b1 ff ff       	call   80101ac6 <iunlock>
801069b5:	83 c4 10             	add    $0x10,%esp
  end_op();
801069b8:	e8 e6 cb ff ff       	call   801035a3 <end_op>

  f->type = FD_INODE;
801069bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801069c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069cc:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801069cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801069d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069dc:	83 e0 01             	and    $0x1,%eax
801069df:	85 c0                	test   %eax,%eax
801069e1:	0f 94 c0             	sete   %al
801069e4:	89 c2                	mov    %eax,%edx
801069e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801069ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069ef:	83 e0 01             	and    $0x1,%eax
801069f2:	85 c0                	test   %eax,%eax
801069f4:	75 0a                	jne    80106a00 <sys_open+0x184>
801069f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069f9:	83 e0 02             	and    $0x2,%eax
801069fc:	85 c0                	test   %eax,%eax
801069fe:	74 07                	je     80106a07 <sys_open+0x18b>
80106a00:	b8 01 00 00 00       	mov    $0x1,%eax
80106a05:	eb 05                	jmp    80106a0c <sys_open+0x190>
80106a07:	b8 00 00 00 00       	mov    $0x0,%eax
80106a0c:	89 c2                	mov    %eax,%edx
80106a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a11:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106a14:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106a17:	c9                   	leave  
80106a18:	c3                   	ret    

80106a19 <sys_mkdir>:

int
sys_mkdir(void)
{
80106a19:	55                   	push   %ebp
80106a1a:	89 e5                	mov    %esp,%ebp
80106a1c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106a1f:	e8 f3 ca ff ff       	call   80103517 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106a24:	83 ec 08             	sub    $0x8,%esp
80106a27:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a2a:	50                   	push   %eax
80106a2b:	6a 00                	push   $0x0
80106a2d:	e8 49 f5 ff ff       	call   80105f7b <argstr>
80106a32:	83 c4 10             	add    $0x10,%esp
80106a35:	85 c0                	test   %eax,%eax
80106a37:	78 1b                	js     80106a54 <sys_mkdir+0x3b>
80106a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a3c:	6a 00                	push   $0x0
80106a3e:	6a 00                	push   $0x0
80106a40:	6a 01                	push   $0x1
80106a42:	50                   	push   %eax
80106a43:	e8 62 fc ff ff       	call   801066aa <create>
80106a48:	83 c4 10             	add    $0x10,%esp
80106a4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a52:	75 0c                	jne    80106a60 <sys_mkdir+0x47>
    end_op();
80106a54:	e8 4a cb ff ff       	call   801035a3 <end_op>
    return -1;
80106a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a5e:	eb 18                	jmp    80106a78 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106a60:	83 ec 0c             	sub    $0xc,%esp
80106a63:	ff 75 f4             	pushl  -0xc(%ebp)
80106a66:	e8 bd b1 ff ff       	call   80101c28 <iunlockput>
80106a6b:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a6e:	e8 30 cb ff ff       	call   801035a3 <end_op>
  return 0;
80106a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a78:	c9                   	leave  
80106a79:	c3                   	ret    

80106a7a <sys_mknod>:

int
sys_mknod(void)
{
80106a7a:	55                   	push   %ebp
80106a7b:	89 e5                	mov    %esp,%ebp
80106a7d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;

  begin_op();
80106a80:	e8 92 ca ff ff       	call   80103517 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106a85:	83 ec 08             	sub    $0x8,%esp
80106a88:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a8b:	50                   	push   %eax
80106a8c:	6a 00                	push   $0x0
80106a8e:	e8 e8 f4 ff ff       	call   80105f7b <argstr>
80106a93:	83 c4 10             	add    $0x10,%esp
80106a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a9d:	78 4f                	js     80106aee <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106a9f:	83 ec 08             	sub    $0x8,%esp
80106aa2:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106aa5:	50                   	push   %eax
80106aa6:	6a 01                	push   $0x1
80106aa8:	e8 49 f4 ff ff       	call   80105ef6 <argint>
80106aad:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106ab0:	85 c0                	test   %eax,%eax
80106ab2:	78 3a                	js     80106aee <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106ab4:	83 ec 08             	sub    $0x8,%esp
80106ab7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106aba:	50                   	push   %eax
80106abb:	6a 02                	push   $0x2
80106abd:	e8 34 f4 ff ff       	call   80105ef6 <argint>
80106ac2:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106ac5:	85 c0                	test   %eax,%eax
80106ac7:	78 25                	js     80106aee <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106acc:	0f bf c8             	movswl %ax,%ecx
80106acf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ad2:	0f bf d0             	movswl %ax,%edx
80106ad5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106ad8:	51                   	push   %ecx
80106ad9:	52                   	push   %edx
80106ada:	6a 03                	push   $0x3
80106adc:	50                   	push   %eax
80106add:	e8 c8 fb ff ff       	call   801066aa <create>
80106ae2:	83 c4 10             	add    $0x10,%esp
80106ae5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ae8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aec:	75 0c                	jne    80106afa <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106aee:	e8 b0 ca ff ff       	call   801035a3 <end_op>
    return -1;
80106af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af8:	eb 18                	jmp    80106b12 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106afa:	83 ec 0c             	sub    $0xc,%esp
80106afd:	ff 75 f0             	pushl  -0x10(%ebp)
80106b00:	e8 23 b1 ff ff       	call   80101c28 <iunlockput>
80106b05:	83 c4 10             	add    $0x10,%esp
  end_op();
80106b08:	e8 96 ca ff ff       	call   801035a3 <end_op>
  return 0;
80106b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b12:	c9                   	leave  
80106b13:	c3                   	ret    

80106b14 <sys_chdir>:

int
sys_chdir(void)
{
80106b14:	55                   	push   %ebp
80106b15:	89 e5                	mov    %esp,%ebp
80106b17:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106b1a:	e8 f8 c9 ff ff       	call   80103517 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106b1f:	83 ec 08             	sub    $0x8,%esp
80106b22:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b25:	50                   	push   %eax
80106b26:	6a 00                	push   $0x0
80106b28:	e8 4e f4 ff ff       	call   80105f7b <argstr>
80106b2d:	83 c4 10             	add    $0x10,%esp
80106b30:	85 c0                	test   %eax,%eax
80106b32:	78 18                	js     80106b4c <sys_chdir+0x38>
80106b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b37:	83 ec 0c             	sub    $0xc,%esp
80106b3a:	50                   	push   %eax
80106b3b:	e8 e6 b9 ff ff       	call   80102526 <namei>
80106b40:	83 c4 10             	add    $0x10,%esp
80106b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b4a:	75 0c                	jne    80106b58 <sys_chdir+0x44>
    end_op();
80106b4c:	e8 52 ca ff ff       	call   801035a3 <end_op>
    return -1;
80106b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b56:	eb 6e                	jmp    80106bc6 <sys_chdir+0xb2>
  }
  ilock(ip);
80106b58:	83 ec 0c             	sub    $0xc,%esp
80106b5b:	ff 75 f4             	pushl  -0xc(%ebp)
80106b5e:	e8 0b ae ff ff       	call   8010196e <ilock>
80106b63:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b69:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b6d:	66 83 f8 01          	cmp    $0x1,%ax
80106b71:	74 1a                	je     80106b8d <sys_chdir+0x79>
    iunlockput(ip);
80106b73:	83 ec 0c             	sub    $0xc,%esp
80106b76:	ff 75 f4             	pushl  -0xc(%ebp)
80106b79:	e8 aa b0 ff ff       	call   80101c28 <iunlockput>
80106b7e:	83 c4 10             	add    $0x10,%esp
    end_op();
80106b81:	e8 1d ca ff ff       	call   801035a3 <end_op>
    return -1;
80106b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8b:	eb 39                	jmp    80106bc6 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106b8d:	83 ec 0c             	sub    $0xc,%esp
80106b90:	ff 75 f4             	pushl  -0xc(%ebp)
80106b93:	e8 2e af ff ff       	call   80101ac6 <iunlock>
80106b98:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106b9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba1:	8b 40 68             	mov    0x68(%eax),%eax
80106ba4:	83 ec 0c             	sub    $0xc,%esp
80106ba7:	50                   	push   %eax
80106ba8:	e8 8b af ff ff       	call   80101b38 <iput>
80106bad:	83 c4 10             	add    $0x10,%esp
  end_op();
80106bb0:	e8 ee c9 ff ff       	call   801035a3 <end_op>
  proc->cwd = ip;
80106bb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bbe:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106bc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bc6:	c9                   	leave  
80106bc7:	c3                   	ret    

80106bc8 <sys_exec>:

int
sys_exec(void)
{
80106bc8:	55                   	push   %ebp
80106bc9:	89 e5                	mov    %esp,%ebp
80106bcb:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106bd1:	83 ec 08             	sub    $0x8,%esp
80106bd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bd7:	50                   	push   %eax
80106bd8:	6a 00                	push   $0x0
80106bda:	e8 9c f3 ff ff       	call   80105f7b <argstr>
80106bdf:	83 c4 10             	add    $0x10,%esp
80106be2:	85 c0                	test   %eax,%eax
80106be4:	78 18                	js     80106bfe <sys_exec+0x36>
80106be6:	83 ec 08             	sub    $0x8,%esp
80106be9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106bef:	50                   	push   %eax
80106bf0:	6a 01                	push   $0x1
80106bf2:	e8 ff f2 ff ff       	call   80105ef6 <argint>
80106bf7:	83 c4 10             	add    $0x10,%esp
80106bfa:	85 c0                	test   %eax,%eax
80106bfc:	79 0a                	jns    80106c08 <sys_exec+0x40>
    return -1;
80106bfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c03:	e9 c6 00 00 00       	jmp    80106cce <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106c08:	83 ec 04             	sub    $0x4,%esp
80106c0b:	68 80 00 00 00       	push   $0x80
80106c10:	6a 00                	push   $0x0
80106c12:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106c18:	50                   	push   %eax
80106c19:	e8 b3 ef ff ff       	call   80105bd1 <memset>
80106c1e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106c21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2b:	83 f8 1f             	cmp    $0x1f,%eax
80106c2e:	76 0a                	jbe    80106c3a <sys_exec+0x72>
      return -1;
80106c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c35:	e9 94 00 00 00       	jmp    80106cce <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3d:	c1 e0 02             	shl    $0x2,%eax
80106c40:	89 c2                	mov    %eax,%edx
80106c42:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106c48:	01 c2                	add    %eax,%edx
80106c4a:	83 ec 08             	sub    $0x8,%esp
80106c4d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106c53:	50                   	push   %eax
80106c54:	52                   	push   %edx
80106c55:	e8 00 f2 ff ff       	call   80105e5a <fetchint>
80106c5a:	83 c4 10             	add    $0x10,%esp
80106c5d:	85 c0                	test   %eax,%eax
80106c5f:	79 07                	jns    80106c68 <sys_exec+0xa0>
      return -1;
80106c61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c66:	eb 66                	jmp    80106cce <sys_exec+0x106>
    if(uarg == 0){
80106c68:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c6e:	85 c0                	test   %eax,%eax
80106c70:	75 27                	jne    80106c99 <sys_exec+0xd1>
      argv[i] = 0;
80106c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c75:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106c7c:	00 00 00 00 
      break;
80106c80:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c84:	83 ec 08             	sub    $0x8,%esp
80106c87:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106c8d:	52                   	push   %edx
80106c8e:	50                   	push   %eax
80106c8f:	e8 c2 9e ff ff       	call   80100b56 <exec>
80106c94:	83 c4 10             	add    $0x10,%esp
80106c97:	eb 35                	jmp    80106cce <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106c99:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ca2:	c1 e2 02             	shl    $0x2,%edx
80106ca5:	01 c2                	add    %eax,%edx
80106ca7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106cad:	83 ec 08             	sub    $0x8,%esp
80106cb0:	52                   	push   %edx
80106cb1:	50                   	push   %eax
80106cb2:	e8 dd f1 ff ff       	call   80105e94 <fetchstr>
80106cb7:	83 c4 10             	add    $0x10,%esp
80106cba:	85 c0                	test   %eax,%eax
80106cbc:	79 07                	jns    80106cc5 <sys_exec+0xfd>
      return -1;
80106cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc3:	eb 09                	jmp    80106cce <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106cc5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106cc9:	e9 5a ff ff ff       	jmp    80106c28 <sys_exec+0x60>
  return exec(path, argv);
}
80106cce:	c9                   	leave  
80106ccf:	c3                   	ret    

80106cd0 <sys_pipe>:

int
sys_pipe(void)
{
80106cd0:	55                   	push   %ebp
80106cd1:	89 e5                	mov    %esp,%ebp
80106cd3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106cd6:	83 ec 04             	sub    $0x4,%esp
80106cd9:	6a 08                	push   $0x8
80106cdb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106cde:	50                   	push   %eax
80106cdf:	6a 00                	push   $0x0
80106ce1:	e8 38 f2 ff ff       	call   80105f1e <argptr>
80106ce6:	83 c4 10             	add    $0x10,%esp
80106ce9:	85 c0                	test   %eax,%eax
80106ceb:	79 0a                	jns    80106cf7 <sys_pipe+0x27>
    return -1;
80106ced:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cf2:	e9 af 00 00 00       	jmp    80106da6 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106cf7:	83 ec 08             	sub    $0x8,%esp
80106cfa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106cfd:	50                   	push   %eax
80106cfe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d01:	50                   	push   %eax
80106d02:	e8 4a d4 ff ff       	call   80104151 <pipealloc>
80106d07:	83 c4 10             	add    $0x10,%esp
80106d0a:	85 c0                	test   %eax,%eax
80106d0c:	79 0a                	jns    80106d18 <sys_pipe+0x48>
    return -1;
80106d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d13:	e9 8e 00 00 00       	jmp    80106da6 <sys_pipe+0xd6>
  fd0 = -1;
80106d18:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d22:	83 ec 0c             	sub    $0xc,%esp
80106d25:	50                   	push   %eax
80106d26:	e8 7c f3 ff ff       	call   801060a7 <fdalloc>
80106d2b:	83 c4 10             	add    $0x10,%esp
80106d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d35:	78 18                	js     80106d4f <sys_pipe+0x7f>
80106d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d3a:	83 ec 0c             	sub    $0xc,%esp
80106d3d:	50                   	push   %eax
80106d3e:	e8 64 f3 ff ff       	call   801060a7 <fdalloc>
80106d43:	83 c4 10             	add    $0x10,%esp
80106d46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d4d:	79 3f                	jns    80106d8e <sys_pipe+0xbe>
    if(fd0 >= 0)
80106d4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d53:	78 14                	js     80106d69 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106d55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d5e:	83 c2 08             	add    $0x8,%edx
80106d61:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106d68:	00 
    fileclose(rf);
80106d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d6c:	83 ec 0c             	sub    $0xc,%esp
80106d6f:	50                   	push   %eax
80106d70:	e8 c9 a2 ff ff       	call   8010103e <fileclose>
80106d75:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d7b:	83 ec 0c             	sub    $0xc,%esp
80106d7e:	50                   	push   %eax
80106d7f:	e8 ba a2 ff ff       	call   8010103e <fileclose>
80106d84:	83 c4 10             	add    $0x10,%esp
    return -1;
80106d87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d8c:	eb 18                	jmp    80106da6 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106d8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d94:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d99:	8d 50 04             	lea    0x4(%eax),%edx
80106d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9f:	89 02                	mov    %eax,(%edx)
  return 0;
80106da1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106da6:	c9                   	leave  
80106da7:	c3                   	ret    

80106da8 <sys_seek>:


int
sys_seek(void)
{
80106da8:	55                   	push   %ebp
80106da9:	89 e5                	mov    %esp,%ebp
80106dab:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;

  if(argfd(0, 0, &f) < 0 || argint(1, &n) < 0 )
80106dae:	83 ec 04             	sub    $0x4,%esp
80106db1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106db4:	50                   	push   %eax
80106db5:	6a 00                	push   $0x0
80106db7:	6a 00                	push   $0x0
80106db9:	e8 74 f2 ff ff       	call   80106032 <argfd>
80106dbe:	83 c4 10             	add    $0x10,%esp
80106dc1:	85 c0                	test   %eax,%eax
80106dc3:	78 15                	js     80106dda <sys_seek+0x32>
80106dc5:	83 ec 08             	sub    $0x8,%esp
80106dc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dcb:	50                   	push   %eax
80106dcc:	6a 01                	push   $0x1
80106dce:	e8 23 f1 ff ff       	call   80105ef6 <argint>
80106dd3:	83 c4 10             	add    $0x10,%esp
80106dd6:	85 c0                	test   %eax,%eax
80106dd8:	79 07                	jns    80106de1 <sys_seek+0x39>
    return -1;
80106dda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ddf:	eb 15                	jmp    80106df6 <sys_seek+0x4e>
  return fileseek(f, n);
80106de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106de4:	89 c2                	mov    %eax,%edx
80106de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106de9:	83 ec 08             	sub    $0x8,%esp
80106dec:	52                   	push   %edx
80106ded:	50                   	push   %eax
80106dee:	e8 7e a5 ff ff       	call   80101371 <fileseek>
80106df3:	83 c4 10             	add    $0x10,%esp
}
80106df6:	c9                   	leave  
80106df7:	c3                   	ret    

80106df8 <sys_fork>:
#include "mmap.h"
#include "proc.h"

int
sys_fork(void)
{
80106df8:	55                   	push   %ebp
80106df9:	89 e5                	mov    %esp,%ebp
80106dfb:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106dfe:	e8 ec dc ff ff       	call   80104aef <fork>
}
80106e03:	c9                   	leave  
80106e04:	c3                   	ret    

80106e05 <sys_exit>:

int
sys_exit(void)
{
80106e05:	55                   	push   %ebp
80106e06:	89 e5                	mov    %esp,%ebp
80106e08:	83 ec 08             	sub    $0x8,%esp
  exit();
80106e0b:	e8 db de ff ff       	call   80104ceb <exit>
  return 0;  // not reached
80106e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e15:	c9                   	leave  
80106e16:	c3                   	ret    

80106e17 <sys_wait>:

int
sys_wait(void)
{
80106e17:	55                   	push   %ebp
80106e18:	89 e5                	mov    %esp,%ebp
80106e1a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106e1d:	e8 5b e0 ff ff       	call   80104e7d <wait>
}
80106e22:	c9                   	leave  
80106e23:	c3                   	ret    

80106e24 <sys_kill>:

int
sys_kill(void)
{
80106e24:	55                   	push   %ebp
80106e25:	89 e5                	mov    %esp,%ebp
80106e27:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106e2a:	83 ec 08             	sub    $0x8,%esp
80106e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e30:	50                   	push   %eax
80106e31:	6a 00                	push   $0x0
80106e33:	e8 be f0 ff ff       	call   80105ef6 <argint>
80106e38:	83 c4 10             	add    $0x10,%esp
80106e3b:	85 c0                	test   %eax,%eax
80106e3d:	79 07                	jns    80106e46 <sys_kill+0x22>
    return -1;
80106e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e44:	eb 0f                	jmp    80106e55 <sys_kill+0x31>
  return kill(pid);
80106e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e49:	83 ec 0c             	sub    $0xc,%esp
80106e4c:	50                   	push   %eax
80106e4d:	e8 a3 e4 ff ff       	call   801052f5 <kill>
80106e52:	83 c4 10             	add    $0x10,%esp
}
80106e55:	c9                   	leave  
80106e56:	c3                   	ret    

80106e57 <sys_getpid>:

int
sys_getpid(void)
{
80106e57:	55                   	push   %ebp
80106e58:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106e5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e60:	8b 40 10             	mov    0x10(%eax),%eax
}
80106e63:	5d                   	pop    %ebp
80106e64:	c3                   	ret    

80106e65 <sys_sbrk>:

int
sys_sbrk(void)
{
80106e65:	55                   	push   %ebp
80106e66:	89 e5                	mov    %esp,%ebp
80106e68:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106e6b:	83 ec 08             	sub    $0x8,%esp
80106e6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e71:	50                   	push   %eax
80106e72:	6a 00                	push   $0x0
80106e74:	e8 7d f0 ff ff       	call   80105ef6 <argint>
80106e79:	83 c4 10             	add    $0x10,%esp
80106e7c:	85 c0                	test   %eax,%eax
80106e7e:	79 07                	jns    80106e87 <sys_sbrk+0x22>
    return -1;
80106e80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e85:	eb 28                	jmp    80106eaf <sys_sbrk+0x4a>
  addr = proc->sz;
80106e87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e8d:	8b 00                	mov    (%eax),%eax
80106e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e95:	83 ec 0c             	sub    $0xc,%esp
80106e98:	50                   	push   %eax
80106e99:	e8 ae db ff ff       	call   80104a4c <growproc>
80106e9e:	83 c4 10             	add    $0x10,%esp
80106ea1:	85 c0                	test   %eax,%eax
80106ea3:	79 07                	jns    80106eac <sys_sbrk+0x47>
    return -1;
80106ea5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eaa:	eb 03                	jmp    80106eaf <sys_sbrk+0x4a>
  return addr;
80106eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106eaf:	c9                   	leave  
80106eb0:	c3                   	ret    

80106eb1 <sys_sleep>:

int
sys_sleep(void)
{
80106eb1:	55                   	push   %ebp
80106eb2:	89 e5                	mov    %esp,%ebp
80106eb4:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106eb7:	83 ec 08             	sub    $0x8,%esp
80106eba:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ebd:	50                   	push   %eax
80106ebe:	6a 00                	push   $0x0
80106ec0:	e8 31 f0 ff ff       	call   80105ef6 <argint>
80106ec5:	83 c4 10             	add    $0x10,%esp
80106ec8:	85 c0                	test   %eax,%eax
80106eca:	79 07                	jns    80106ed3 <sys_sleep+0x22>
    return -1;
80106ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed1:	eb 77                	jmp    80106f4a <sys_sleep+0x99>
  acquire(&tickslock);
80106ed3:	83 ec 0c             	sub    $0xc,%esp
80106ed6:	68 20 79 11 80       	push   $0x80117920
80106edb:	e8 8e ea ff ff       	call   8010596e <acquire>
80106ee0:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106ee3:	a1 60 81 11 80       	mov    0x80118160,%eax
80106ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106eeb:	eb 39                	jmp    80106f26 <sys_sleep+0x75>
    if(proc->killed){
80106eed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef3:	8b 40 24             	mov    0x24(%eax),%eax
80106ef6:	85 c0                	test   %eax,%eax
80106ef8:	74 17                	je     80106f11 <sys_sleep+0x60>
      release(&tickslock);
80106efa:	83 ec 0c             	sub    $0xc,%esp
80106efd:	68 20 79 11 80       	push   $0x80117920
80106f02:	e8 ce ea ff ff       	call   801059d5 <release>
80106f07:	83 c4 10             	add    $0x10,%esp
      return -1;
80106f0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f0f:	eb 39                	jmp    80106f4a <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106f11:	83 ec 08             	sub    $0x8,%esp
80106f14:	68 20 79 11 80       	push   $0x80117920
80106f19:	68 60 81 11 80       	push   $0x80118160
80106f1e:	e8 8f e2 ff ff       	call   801051b2 <sleep>
80106f23:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106f26:	a1 60 81 11 80       	mov    0x80118160,%eax
80106f2b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106f2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f31:	39 d0                	cmp    %edx,%eax
80106f33:	72 b8                	jb     80106eed <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106f35:	83 ec 0c             	sub    $0xc,%esp
80106f38:	68 20 79 11 80       	push   $0x80117920
80106f3d:	e8 93 ea ff ff       	call   801059d5 <release>
80106f42:	83 c4 10             	add    $0x10,%esp
  return 0;
80106f45:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f4a:	c9                   	leave  
80106f4b:	c3                   	ret    

80106f4c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106f4c:	55                   	push   %ebp
80106f4d:	89 e5                	mov    %esp,%ebp
80106f4f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106f52:	83 ec 0c             	sub    $0xc,%esp
80106f55:	68 20 79 11 80       	push   $0x80117920
80106f5a:	e8 0f ea ff ff       	call   8010596e <acquire>
80106f5f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106f62:	a1 60 81 11 80       	mov    0x80118160,%eax
80106f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106f6a:	83 ec 0c             	sub    $0xc,%esp
80106f6d:	68 20 79 11 80       	push   $0x80117920
80106f72:	e8 5e ea ff ff       	call   801059d5 <release>
80106f77:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106f7d:	c9                   	leave  
80106f7e:	c3                   	ret    

80106f7f <sys_procstat>:

// List the existing processes in the system and their status.
int
sys_procstat(void)
{
80106f7f:	55                   	push   %ebp
80106f80:	89 e5                	mov    %esp,%ebp
80106f82:	83 ec 08             	sub    $0x8,%esp
  cprintf("sys_procstat\n");
80106f85:	83 ec 0c             	sub    $0xc,%esp
80106f88:	68 3b 98 10 80       	push   $0x8010983b
80106f8d:	e8 34 94 ff ff       	call   801003c6 <cprintf>
80106f92:	83 c4 10             	add    $0x10,%esp
  procdump();  // call function defined in proc.c
80106f95:	e8 e6 e3 ff ff       	call   80105380 <procdump>
  return 0;
80106f9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f9f:	c9                   	leave  
80106fa0:	c3                   	ret    

80106fa1 <sys_setpriority>:

// Set the priority to a process.
int
sys_setpriority(void)
{
80106fa1:	55                   	push   %ebp
80106fa2:	89 e5                	mov    %esp,%ebp
80106fa4:	83 ec 18             	sub    $0x18,%esp
  int level;
  //cprintf("sys_setpriority\n");
  if(argint(0, &level)<0)
80106fa7:	83 ec 08             	sub    $0x8,%esp
80106faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fad:	50                   	push   %eax
80106fae:	6a 00                	push   $0x0
80106fb0:	e8 41 ef ff ff       	call   80105ef6 <argint>
80106fb5:	83 c4 10             	add    $0x10,%esp
80106fb8:	85 c0                	test   %eax,%eax
80106fba:	79 07                	jns    80106fc3 <sys_setpriority+0x22>
    return -1;
80106fbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fc1:	eb 12                	jmp    80106fd5 <sys_setpriority+0x34>
  proc->priority=level;
80106fc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fcc:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  return 0;
80106fd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fd5:	c9                   	leave  
80106fd6:	c3                   	ret    

80106fd7 <sys_semget>:


int
sys_semget(void)
{
80106fd7:	55                   	push   %ebp
80106fd8:	89 e5                	mov    %esp,%ebp
80106fda:	83 ec 18             	sub    $0x18,%esp
  int id, value;
  if(argint(0, &id)<0)
80106fdd:	83 ec 08             	sub    $0x8,%esp
80106fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fe3:	50                   	push   %eax
80106fe4:	6a 00                	push   $0x0
80106fe6:	e8 0b ef ff ff       	call   80105ef6 <argint>
80106feb:	83 c4 10             	add    $0x10,%esp
80106fee:	85 c0                	test   %eax,%eax
80106ff0:	79 07                	jns    80106ff9 <sys_semget+0x22>
    return -1;
80106ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff7:	eb 2f                	jmp    80107028 <sys_semget+0x51>
  if(argint(1, &value)<0)
80106ff9:	83 ec 08             	sub    $0x8,%esp
80106ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fff:	50                   	push   %eax
80107000:	6a 01                	push   $0x1
80107002:	e8 ef ee ff ff       	call   80105ef6 <argint>
80107007:	83 c4 10             	add    $0x10,%esp
8010700a:	85 c0                	test   %eax,%eax
8010700c:	79 07                	jns    80107015 <sys_semget+0x3e>
    return -1;
8010700e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107013:	eb 13                	jmp    80107028 <sys_semget+0x51>
  return semget(id,value);
80107015:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701b:	83 ec 08             	sub    $0x8,%esp
8010701e:	52                   	push   %edx
8010701f:	50                   	push   %eax
80107020:	e8 64 e5 ff ff       	call   80105589 <semget>
80107025:	83 c4 10             	add    $0x10,%esp
}
80107028:	c9                   	leave  
80107029:	c3                   	ret    

8010702a <sys_semfree>:


int
sys_semfree(void)
{
8010702a:	55                   	push   %ebp
8010702b:	89 e5                	mov    %esp,%ebp
8010702d:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107030:	83 ec 08             	sub    $0x8,%esp
80107033:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107036:	50                   	push   %eax
80107037:	6a 00                	push   $0x0
80107039:	e8 b8 ee ff ff       	call   80105ef6 <argint>
8010703e:	83 c4 10             	add    $0x10,%esp
80107041:	85 c0                	test   %eax,%eax
80107043:	79 07                	jns    8010704c <sys_semfree+0x22>
    return -1;
80107045:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010704a:	eb 0f                	jmp    8010705b <sys_semfree+0x31>
  return semfree(id);
8010704c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704f:	83 ec 0c             	sub    $0xc,%esp
80107052:	50                   	push   %eax
80107053:	e8 63 e6 ff ff       	call   801056bb <semfree>
80107058:	83 c4 10             	add    $0x10,%esp
}
8010705b:	c9                   	leave  
8010705c:	c3                   	ret    

8010705d <sys_semdown>:


int
sys_semdown(void)
{
8010705d:	55                   	push   %ebp
8010705e:	89 e5                	mov    %esp,%ebp
80107060:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107063:	83 ec 08             	sub    $0x8,%esp
80107066:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107069:	50                   	push   %eax
8010706a:	6a 00                	push   $0x0
8010706c:	e8 85 ee ff ff       	call   80105ef6 <argint>
80107071:	83 c4 10             	add    $0x10,%esp
80107074:	85 c0                	test   %eax,%eax
80107076:	79 07                	jns    8010707f <sys_semdown+0x22>
    return -1;
80107078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010707d:	eb 0f                	jmp    8010708e <sys_semdown+0x31>
  return semdown(id);
8010707f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107082:	83 ec 0c             	sub    $0xc,%esp
80107085:	50                   	push   %eax
80107086:	e8 cb e6 ff ff       	call   80105756 <semdown>
8010708b:	83 c4 10             	add    $0x10,%esp
}
8010708e:	c9                   	leave  
8010708f:	c3                   	ret    

80107090 <sys_semup>:


int
sys_semup(void)
{
80107090:	55                   	push   %ebp
80107091:	89 e5                	mov    %esp,%ebp
80107093:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107096:	83 ec 08             	sub    $0x8,%esp
80107099:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010709c:	50                   	push   %eax
8010709d:	6a 00                	push   $0x0
8010709f:	e8 52 ee ff ff       	call   80105ef6 <argint>
801070a4:	83 c4 10             	add    $0x10,%esp
801070a7:	85 c0                	test   %eax,%eax
801070a9:	79 07                	jns    801070b2 <sys_semup+0x22>
    return -1;
801070ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b0:	eb 0f                	jmp    801070c1 <sys_semup+0x31>
  return semup(id);
801070b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b5:	83 ec 0c             	sub    $0xc,%esp
801070b8:	50                   	push   %eax
801070b9:	e8 2b e7 ff ff       	call   801057e9 <semup>
801070be:	83 c4 10             	add    $0x10,%esp
}
801070c1:	c9                   	leave  
801070c2:	c3                   	ret    

801070c3 <sys_mmap>:

int
sys_mmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
801070c3:	55                   	push   %ebp
801070c4:	89 e5                	mov    %esp,%ebp
801070c6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int mode;
  int addr;

  if(argint(0, &fd)<0 || argint(1, &mode)<0 ||argint(2,&addr)<0){ //PREGUNTAR
801070c9:	83 ec 08             	sub    $0x8,%esp
801070cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070cf:	50                   	push   %eax
801070d0:	6a 00                	push   $0x0
801070d2:	e8 1f ee ff ff       	call   80105ef6 <argint>
801070d7:	83 c4 10             	add    $0x10,%esp
801070da:	85 c0                	test   %eax,%eax
801070dc:	78 2a                	js     80107108 <sys_mmap+0x45>
801070de:	83 ec 08             	sub    $0x8,%esp
801070e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070e4:	50                   	push   %eax
801070e5:	6a 01                	push   $0x1
801070e7:	e8 0a ee ff ff       	call   80105ef6 <argint>
801070ec:	83 c4 10             	add    $0x10,%esp
801070ef:	85 c0                	test   %eax,%eax
801070f1:	78 15                	js     80107108 <sys_mmap+0x45>
801070f3:	83 ec 08             	sub    $0x8,%esp
801070f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070f9:	50                   	push   %eax
801070fa:	6a 02                	push   $0x2
801070fc:	e8 f5 ed ff ff       	call   80105ef6 <argint>
80107101:	83 c4 10             	add    $0x10,%esp
80107104:	85 c0                	test   %eax,%eax
80107106:	79 07                	jns    8010710f <sys_mmap+0x4c>
    return -1;
80107108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010710d:	eb 19                	jmp    80107128 <sys_mmap+0x65>
  }
  //cprintf("%x",addr);
  return mmap(fd,mode,(char**)addr);
8010710f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107112:	89 c1                	mov    %eax,%ecx
80107114:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711a:	83 ec 04             	sub    $0x4,%esp
8010711d:	51                   	push   %ecx
8010711e:	52                   	push   %edx
8010711f:	50                   	push   %eax
80107120:	e8 3f c9 ff ff       	call   80103a64 <mmap>
80107125:	83 c4 10             	add    $0x10,%esp
}
80107128:	c9                   	leave  
80107129:	c3                   	ret    

8010712a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010712a:	55                   	push   %ebp
8010712b:	89 e5                	mov    %esp,%ebp
8010712d:	83 ec 08             	sub    $0x8,%esp
80107130:	8b 55 08             	mov    0x8(%ebp),%edx
80107133:	8b 45 0c             	mov    0xc(%ebp),%eax
80107136:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010713a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010713d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107141:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107145:	ee                   	out    %al,(%dx)
}
80107146:	90                   	nop
80107147:	c9                   	leave  
80107148:	c3                   	ret    

80107149 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107149:	55                   	push   %ebp
8010714a:	89 e5                	mov    %esp,%ebp
8010714c:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010714f:	6a 34                	push   $0x34
80107151:	6a 43                	push   $0x43
80107153:	e8 d2 ff ff ff       	call   8010712a <outb>
80107158:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010715b:	68 9c 00 00 00       	push   $0x9c
80107160:	6a 40                	push   $0x40
80107162:	e8 c3 ff ff ff       	call   8010712a <outb>
80107167:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010716a:	6a 2e                	push   $0x2e
8010716c:	6a 40                	push   $0x40
8010716e:	e8 b7 ff ff ff       	call   8010712a <outb>
80107173:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107176:	83 ec 0c             	sub    $0xc,%esp
80107179:	6a 00                	push   $0x0
8010717b:	e8 bb ce ff ff       	call   8010403b <picenable>
80107180:	83 c4 10             	add    $0x10,%esp
}
80107183:	90                   	nop
80107184:	c9                   	leave  
80107185:	c3                   	ret    

80107186 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107186:	1e                   	push   %ds
  pushl %es
80107187:	06                   	push   %es
  pushl %fs
80107188:	0f a0                	push   %fs
  pushl %gs
8010718a:	0f a8                	push   %gs
  pushal
8010718c:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010718d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107191:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107193:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107195:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107199:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010719b:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010719d:	54                   	push   %esp
  call trap
8010719e:	e8 43 02 00 00       	call   801073e6 <trap>
  addl $4, %esp
801071a3:	83 c4 04             	add    $0x4,%esp

801071a6 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801071a6:	61                   	popa   
  popl %gs
801071a7:	0f a9                	pop    %gs
  popl %fs
801071a9:	0f a1                	pop    %fs
  popl %es
801071ab:	07                   	pop    %es
  popl %ds
801071ac:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801071ad:	83 c4 08             	add    $0x8,%esp
  iret
801071b0:	cf                   	iret   

801071b1 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071b1:	55                   	push   %ebp
801071b2:	89 e5                	mov    %esp,%ebp
801071b4:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801071ba:	83 e8 01             	sub    $0x1,%eax
801071bd:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071c1:	8b 45 08             	mov    0x8(%ebp),%eax
801071c4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071c8:	8b 45 08             	mov    0x8(%ebp),%eax
801071cb:	c1 e8 10             	shr    $0x10,%eax
801071ce:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801071d2:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071d5:	0f 01 18             	lidtl  (%eax)
}
801071d8:	90                   	nop
801071d9:	c9                   	leave  
801071da:	c3                   	ret    

801071db <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801071db:	55                   	push   %ebp
801071dc:	89 e5                	mov    %esp,%ebp
801071de:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801071e1:	0f 20 d0             	mov    %cr2,%eax
801071e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801071e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801071ea:	c9                   	leave  
801071eb:	c3                   	ret    

801071ec <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801071ec:	55                   	push   %ebp
801071ed:	89 e5                	mov    %esp,%ebp
801071ef:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801071f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801071f9:	e9 c3 00 00 00       	jmp    801072c1 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801071fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107201:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
80107208:	89 c2                	mov    %eax,%edx
8010720a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720d:	66 89 14 c5 60 79 11 	mov    %dx,-0x7fee86a0(,%eax,8)
80107214:	80 
80107215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107218:	66 c7 04 c5 62 79 11 	movw   $0x8,-0x7fee869e(,%eax,8)
8010721f:	80 08 00 
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	0f b6 14 c5 64 79 11 	movzbl -0x7fee869c(,%eax,8),%edx
8010722c:	80 
8010722d:	83 e2 e0             	and    $0xffffffe0,%edx
80107230:	88 14 c5 64 79 11 80 	mov    %dl,-0x7fee869c(,%eax,8)
80107237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723a:	0f b6 14 c5 64 79 11 	movzbl -0x7fee869c(,%eax,8),%edx
80107241:	80 
80107242:	83 e2 1f             	and    $0x1f,%edx
80107245:	88 14 c5 64 79 11 80 	mov    %dl,-0x7fee869c(,%eax,8)
8010724c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724f:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
80107256:	80 
80107257:	83 e2 f0             	and    $0xfffffff0,%edx
8010725a:	83 ca 0e             	or     $0xe,%edx
8010725d:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
80107264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107267:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
8010726e:	80 
8010726f:	83 e2 ef             	and    $0xffffffef,%edx
80107272:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
80107279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727c:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
80107283:	80 
80107284:	83 e2 9f             	and    $0xffffff9f,%edx
80107287:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
8010728e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107291:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
80107298:	80 
80107299:	83 ca 80             	or     $0xffffff80,%edx
8010729c:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
801072a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a6:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
801072ad:	c1 e8 10             	shr    $0x10,%eax
801072b0:	89 c2                	mov    %eax,%edx
801072b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b5:	66 89 14 c5 66 79 11 	mov    %dx,-0x7fee869a(,%eax,8)
801072bc:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801072bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801072c1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801072c8:	0f 8e 30 ff ff ff    	jle    801071fe <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801072ce:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
801072d3:	66 a3 60 7b 11 80    	mov    %ax,0x80117b60
801072d9:	66 c7 05 62 7b 11 80 	movw   $0x8,0x80117b62
801072e0:	08 00 
801072e2:	0f b6 05 64 7b 11 80 	movzbl 0x80117b64,%eax
801072e9:	83 e0 e0             	and    $0xffffffe0,%eax
801072ec:	a2 64 7b 11 80       	mov    %al,0x80117b64
801072f1:	0f b6 05 64 7b 11 80 	movzbl 0x80117b64,%eax
801072f8:	83 e0 1f             	and    $0x1f,%eax
801072fb:	a2 64 7b 11 80       	mov    %al,0x80117b64
80107300:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107307:	83 c8 0f             	or     $0xf,%eax
8010730a:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010730f:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107316:	83 e0 ef             	and    $0xffffffef,%eax
80107319:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010731e:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107325:	83 c8 60             	or     $0x60,%eax
80107328:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010732d:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107334:	83 c8 80             	or     $0xffffff80,%eax
80107337:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010733c:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
80107341:	c1 e8 10             	shr    $0x10,%eax
80107344:	66 a3 66 7b 11 80    	mov    %ax,0x80117b66

  initlock(&tickslock, "time");
8010734a:	83 ec 08             	sub    $0x8,%esp
8010734d:	68 4c 98 10 80       	push   $0x8010984c
80107352:	68 20 79 11 80       	push   $0x80117920
80107357:	e8 f0 e5 ff ff       	call   8010594c <initlock>
8010735c:	83 c4 10             	add    $0x10,%esp
}
8010735f:	90                   	nop
80107360:	c9                   	leave  
80107361:	c3                   	ret    

80107362 <idtinit>:

void
idtinit(void)
{
80107362:	55                   	push   %ebp
80107363:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107365:	68 00 08 00 00       	push   $0x800
8010736a:	68 60 79 11 80       	push   $0x80117960
8010736f:	e8 3d fe ff ff       	call   801071b1 <lidt>
80107374:	83 c4 08             	add    $0x8,%esp
}
80107377:	90                   	nop
80107378:	c9                   	leave  
80107379:	c3                   	ret    

8010737a <mmapin>:

int
mmapin(uint cr2)
{
8010737a:	55                   	push   %ebp
8010737b:	89 e5                	mov    %esp,%ebp
8010737d:	83 ec 10             	sub    $0x10,%esp
  int index;

  for(index=0;index<MAXMAPPEDFILES;index++){
80107380:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107387:	eb 50                	jmp    801073d9 <mmapin+0x5f>
    int va;
    int sz;
    va = proc->ommap[index].va;
80107389:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010738f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107392:	83 c2 0a             	add    $0xa,%edx
80107395:	c1 e2 04             	shl    $0x4,%edx
80107398:	01 d0                	add    %edx,%eax
8010739a:	83 c0 04             	add    $0x4,%eax
8010739d:	8b 00                	mov    (%eax),%eax
8010739f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    sz = proc->ommap[index].sz;
801073a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801073ab:	83 c2 0a             	add    $0xa,%edx
801073ae:	c1 e2 04             	shl    $0x4,%edx
801073b1:	01 d0                	add    %edx,%eax
801073b3:	83 c0 08             	add    $0x8,%eax
801073b6:	8b 00                	mov    (%eax),%eax
801073b8:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(cr2>=va && cr2<va+sz)
801073bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801073be:	39 45 08             	cmp    %eax,0x8(%ebp)
801073c1:	72 12                	jb     801073d5 <mmapin+0x5b>
801073c3:	8b 55 f8             	mov    -0x8(%ebp),%edx
801073c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c9:	01 d0                	add    %edx,%eax
801073cb:	3b 45 08             	cmp    0x8(%ebp),%eax
801073ce:	76 05                	jbe    801073d5 <mmapin+0x5b>
      return index;
801073d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073d3:	eb 0f                	jmp    801073e4 <mmapin+0x6a>
int
mmapin(uint cr2)
{
  int index;

  for(index=0;index<MAXMAPPEDFILES;index++){
801073d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801073d9:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801073dd:	7e aa                	jle    80107389 <mmapin+0xf>
    sz = proc->ommap[index].sz;

    if(cr2>=va && cr2<va+sz)
      return index;
  }
  return -1;
801073df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073e4:	c9                   	leave  
801073e5:	c3                   	ret    

801073e6 <trap>:


//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801073e6:	55                   	push   %ebp
801073e7:	89 e5                	mov    %esp,%ebp
801073e9:	57                   	push   %edi
801073ea:	56                   	push   %esi
801073eb:	53                   	push   %ebx
801073ec:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801073ef:	8b 45 08             	mov    0x8(%ebp),%eax
801073f2:	8b 40 30             	mov    0x30(%eax),%eax
801073f5:	83 f8 40             	cmp    $0x40,%eax
801073f8:	75 3e                	jne    80107438 <trap+0x52>
    if(proc->killed)
801073fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107400:	8b 40 24             	mov    0x24(%eax),%eax
80107403:	85 c0                	test   %eax,%eax
80107405:	74 05                	je     8010740c <trap+0x26>
      exit();
80107407:	e8 df d8 ff ff       	call   80104ceb <exit>
    proc->tf = tf;
8010740c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107412:	8b 55 08             	mov    0x8(%ebp),%edx
80107415:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107418:	e8 8f eb ff ff       	call   80105fac <syscall>
    if(proc->killed)
8010741d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107423:	8b 40 24             	mov    0x24(%eax),%eax
80107426:	85 c0                	test   %eax,%eax
80107428:	0f 84 ee 03 00 00    	je     8010781c <trap+0x436>
      exit();
8010742e:	e8 b8 d8 ff ff       	call   80104ceb <exit>
    return;
80107433:	e9 e4 03 00 00       	jmp    8010781c <trap+0x436>
  }

  switch(tf->trapno){
80107438:	8b 45 08             	mov    0x8(%ebp),%eax
8010743b:	8b 40 30             	mov    0x30(%eax),%eax
8010743e:	83 e8 20             	sub    $0x20,%eax
80107441:	83 f8 1f             	cmp    $0x1f,%eax
80107444:	0f 87 c0 00 00 00    	ja     8010750a <trap+0x124>
8010744a:	8b 04 85 78 99 10 80 	mov    -0x7fef6688(,%eax,4),%eax
80107451:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107453:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107459:	0f b6 00             	movzbl (%eax),%eax
8010745c:	84 c0                	test   %al,%al
8010745e:	75 3d                	jne    8010749d <trap+0xb7>
      acquire(&tickslock);
80107460:	83 ec 0c             	sub    $0xc,%esp
80107463:	68 20 79 11 80       	push   $0x80117920
80107468:	e8 01 e5 ff ff       	call   8010596e <acquire>
8010746d:	83 c4 10             	add    $0x10,%esp
      ticks++;
80107470:	a1 60 81 11 80       	mov    0x80118160,%eax
80107475:	83 c0 01             	add    $0x1,%eax
80107478:	a3 60 81 11 80       	mov    %eax,0x80118160
      wakeup(&ticks);
8010747d:	83 ec 0c             	sub    $0xc,%esp
80107480:	68 60 81 11 80       	push   $0x80118160
80107485:	e8 34 de ff ff       	call   801052be <wakeup>
8010748a:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010748d:	83 ec 0c             	sub    $0xc,%esp
80107490:	68 20 79 11 80       	push   $0x80117920
80107495:	e8 3b e5 ff ff       	call   801059d5 <release>
8010749a:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010749d:	e8 45 bb ff ff       	call   80102fe7 <lapiceoi>
    break;
801074a2:	e9 99 02 00 00       	jmp    80107740 <trap+0x35a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801074a7:	e8 4e b3 ff ff       	call   801027fa <ideintr>
    lapiceoi();
801074ac:	e8 36 bb ff ff       	call   80102fe7 <lapiceoi>
    break;
801074b1:	e9 8a 02 00 00       	jmp    80107740 <trap+0x35a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801074b6:	e8 2e b9 ff ff       	call   80102de9 <kbdintr>
    lapiceoi();
801074bb:	e8 27 bb ff ff       	call   80102fe7 <lapiceoi>
    break;
801074c0:	e9 7b 02 00 00       	jmp    80107740 <trap+0x35a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801074c5:	e8 33 05 00 00       	call   801079fd <uartintr>
    lapiceoi();
801074ca:	e8 18 bb ff ff       	call   80102fe7 <lapiceoi>
    break;
801074cf:	e9 6c 02 00 00       	jmp    80107740 <trap+0x35a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074d4:	8b 45 08             	mov    0x8(%ebp),%eax
801074d7:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801074da:	8b 45 08             	mov    0x8(%ebp),%eax
801074dd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074e1:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801074e4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801074ea:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801074ed:	0f b6 c0             	movzbl %al,%eax
801074f0:	51                   	push   %ecx
801074f1:	52                   	push   %edx
801074f2:	50                   	push   %eax
801074f3:	68 54 98 10 80       	push   $0x80109854
801074f8:	e8 c9 8e ff ff       	call   801003c6 <cprintf>
801074fd:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107500:	e8 e2 ba ff ff       	call   80102fe7 <lapiceoi>
    break;
80107505:	e9 36 02 00 00       	jmp    80107740 <trap+0x35a>

  //PAGEBREAK: 13
  default:

    if(proc && tf->trapno == T_PGFLT){
8010750a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107510:	85 c0                	test   %eax,%eax
80107512:	0f 84 6c 01 00 00    	je     80107684 <trap+0x29e>
80107518:	8b 45 08             	mov    0x8(%ebp),%eax
8010751b:	8b 40 30             	mov    0x30(%eax),%eax
8010751e:	83 f8 0e             	cmp    $0xe,%eax
80107521:	0f 85 5d 01 00 00    	jne    80107684 <trap+0x29e>
      uint cr2=rcr2();
80107527:	e8 af fc ff ff       	call   801071db <rcr2>
8010752c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int mmapid;


      //  Verify if you wanted to access a correct address but not assigned.
      //  if appropriate, assign one more page to the stack.
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
8010752f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107535:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
8010753b:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010753e:	77 6b                	ja     801075ab <trap+0x1c5>
80107540:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107546:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
8010754c:	05 00 80 00 00       	add    $0x8000,%eax
80107551:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80107554:	76 55                	jbe    801075ab <trap+0x1c5>
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
80107556:	83 ec 08             	sub    $0x8,%esp
80107559:	ff 75 e4             	pushl  -0x1c(%ebp)
8010755c:	68 78 98 10 80       	push   $0x80109878
80107561:	e8 60 8e ff ff       	call   801003c6 <cprintf>
80107566:	83 c4 10             	add    $0x10,%esp
        basepgaddr=PGROUNDDOWN(cr2);
80107569:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010756c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107571:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
80107574:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107577:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
8010757d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107583:	8b 40 04             	mov    0x4(%eax),%eax
80107586:	83 ec 04             	sub    $0x4,%esp
80107589:	52                   	push   %edx
8010758a:	ff 75 e0             	pushl  -0x20(%ebp)
8010758d:	50                   	push   %eax
8010758e:	e8 be 18 00 00       	call   80108e51 <allocuvm>
80107593:	83 c4 10             	add    $0x10,%esp
80107596:	85 c0                	test   %eax,%eax
80107598:	0f 85 a1 01 00 00    	jne    8010773f <trap+0x359>
          panic("trap alloc stack");
8010759e:	83 ec 0c             	sub    $0xc,%esp
801075a1:	68 b4 98 10 80       	push   $0x801098b4
801075a6:	e8 bb 8f ff ff       	call   80100566 <panic>
        break;
      }

      if ( (mmapid = mmapin(cr2)) >= 0 ) {
801075ab:	83 ec 0c             	sub    $0xc,%esp
801075ae:	ff 75 e4             	pushl  -0x1c(%ebp)
801075b1:	e8 c4 fd ff ff       	call   8010737a <mmapin>
801075b6:	83 c4 10             	add    $0x10,%esp
801075b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
801075bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801075c0:	0f 88 be 00 00 00    	js     80107684 <trap+0x29e>
        int offset;
        cprintf("SE QUIERE LEER UNA PAGINA DEL ARCHIVO NO ALOCADA!\n");
801075c6:	83 ec 0c             	sub    $0xc,%esp
801075c9:	68 c8 98 10 80       	push   $0x801098c8
801075ce:	e8 f3 8d ff ff       	call   801003c6 <cprintf>
801075d3:	83 c4 10             	add    $0x10,%esp
        // in ashared memory region
        basepgaddr = PGROUNDDOWN(cr2);
801075d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075de:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
801075e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801075e4:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
801075ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f0:	8b 40 04             	mov    0x4(%eax),%eax
801075f3:	83 ec 04             	sub    $0x4,%esp
801075f6:	52                   	push   %edx
801075f7:	ff 75 e0             	pushl  -0x20(%ebp)
801075fa:	50                   	push   %eax
801075fb:	e8 51 18 00 00       	call   80108e51 <allocuvm>
80107600:	83 c4 10             	add    $0x10,%esp
80107603:	85 c0                	test   %eax,%eax
80107605:	75 0d                	jne    80107614 <trap+0x22e>
          panic("trap alloc stack");
80107607:	83 ec 0c             	sub    $0xc,%esp
8010760a:	68 b4 98 10 80       	push   $0x801098b4
8010760f:	e8 52 8f ff ff       	call   80100566 <panic>
        offset = basepgaddr - proc->ommap[mmapid].va;
80107614:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010761a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010761d:	83 c2 0a             	add    $0xa,%edx
80107620:	c1 e2 04             	shl    $0x4,%edx
80107623:	01 d0                	add    %edx,%eax
80107625:	83 c0 04             	add    $0x4,%eax
80107628:	8b 00                	mov    (%eax),%eax
8010762a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010762d:	29 c2                	sub    %eax,%edx
8010762f:	89 d0                	mov    %edx,%eax
80107631:	89 45 d8             	mov    %eax,-0x28(%ebp)
        fileseek(proc->ommap[mmapid].pfile, offset);
80107634:	8b 55 d8             	mov    -0x28(%ebp),%edx
80107637:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010763d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80107640:	83 c1 0a             	add    $0xa,%ecx
80107643:	c1 e1 04             	shl    $0x4,%ecx
80107646:	01 c8                	add    %ecx,%eax
80107648:	8b 00                	mov    (%eax),%eax
8010764a:	83 ec 08             	sub    $0x8,%esp
8010764d:	52                   	push   %edx
8010764e:	50                   	push   %eax
8010764f:	e8 1d 9d ff ff       	call   80101371 <fileseek>
80107654:	83 c4 10             	add    $0x10,%esp
        fileread(proc->ommap[mmapid].pfile, (char *)basepgaddr, PGSIZE);
80107657:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010765a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107660:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80107663:	83 c1 0a             	add    $0xa,%ecx
80107666:	c1 e1 04             	shl    $0x4,%ecx
80107669:	01 c8                	add    %ecx,%eax
8010766b:	8b 00                	mov    (%eax),%eax
8010766d:	83 ec 04             	sub    $0x4,%esp
80107670:	68 00 10 00 00       	push   $0x1000
80107675:	52                   	push   %edx
80107676:	50                   	push   %eax
80107677:	e8 01 9b ff ff       	call   8010117d <fileread>
8010767c:	83 c4 10             	add    $0x10,%esp
        break;
8010767f:	e9 bc 00 00 00       	jmp    80107740 <trap+0x35a>
      }

    }

    if(proc == 0 || (tf->cs&3) == 0){
80107684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010768a:	85 c0                	test   %eax,%eax
8010768c:	74 11                	je     8010769f <trap+0x2b9>
8010768e:	8b 45 08             	mov    0x8(%ebp),%eax
80107691:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107695:	0f b7 c0             	movzwl %ax,%eax
80107698:	83 e0 03             	and    $0x3,%eax
8010769b:	85 c0                	test   %eax,%eax
8010769d:	75 40                	jne    801076df <trap+0x2f9>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010769f:	e8 37 fb ff ff       	call   801071db <rcr2>
801076a4:	89 c3                	mov    %eax,%ebx
801076a6:	8b 45 08             	mov    0x8(%ebp),%eax
801076a9:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801076ac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076b2:	0f b6 00             	movzbl (%eax),%eax

    }

    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801076b5:	0f b6 d0             	movzbl %al,%edx
801076b8:	8b 45 08             	mov    0x8(%ebp),%eax
801076bb:	8b 40 30             	mov    0x30(%eax),%eax
801076be:	83 ec 0c             	sub    $0xc,%esp
801076c1:	53                   	push   %ebx
801076c2:	51                   	push   %ecx
801076c3:	52                   	push   %edx
801076c4:	50                   	push   %eax
801076c5:	68 fc 98 10 80       	push   $0x801098fc
801076ca:	e8 f7 8c ff ff       	call   801003c6 <cprintf>
801076cf:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801076d2:	83 ec 0c             	sub    $0xc,%esp
801076d5:	68 2e 99 10 80       	push   $0x8010992e
801076da:	e8 87 8e ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076df:	e8 f7 fa ff ff       	call   801071db <rcr2>
801076e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801076e7:	8b 45 08             	mov    0x8(%ebp),%eax
801076ea:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
801076ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076f3:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076f6:	0f b6 d8             	movzbl %al,%ebx
801076f9:	8b 45 08             	mov    0x8(%ebp),%eax
801076fc:	8b 48 34             	mov    0x34(%eax),%ecx
801076ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107702:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107705:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010770b:	8d 78 6c             	lea    0x6c(%eax),%edi
8010770e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107714:	8b 40 10             	mov    0x10(%eax),%eax
80107717:	ff 75 d4             	pushl  -0x2c(%ebp)
8010771a:	56                   	push   %esi
8010771b:	53                   	push   %ebx
8010771c:	51                   	push   %ecx
8010771d:	52                   	push   %edx
8010771e:	57                   	push   %edi
8010771f:	50                   	push   %eax
80107720:	68 34 99 10 80       	push   $0x80109934
80107725:	e8 9c 8c ff ff       	call   801003c6 <cprintf>
8010772a:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
8010772d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107733:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010773a:	eb 04                	jmp    80107740 <trap+0x35a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010773c:	90                   	nop
8010773d:	eb 01                	jmp    80107740 <trap+0x35a>
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
        basepgaddr=PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        break;
8010773f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107746:	85 c0                	test   %eax,%eax
80107748:	74 24                	je     8010776e <trap+0x388>
8010774a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107750:	8b 40 24             	mov    0x24(%eax),%eax
80107753:	85 c0                	test   %eax,%eax
80107755:	74 17                	je     8010776e <trap+0x388>
80107757:	8b 45 08             	mov    0x8(%ebp),%eax
8010775a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010775e:	0f b7 c0             	movzwl %ax,%eax
80107761:	83 e0 03             	and    $0x3,%eax
80107764:	83 f8 03             	cmp    $0x3,%eax
80107767:	75 05                	jne    8010776e <trap+0x388>
    exit();
80107769:	e8 7d d5 ff ff       	call   80104ceb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
8010776e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107774:	85 c0                	test   %eax,%eax
80107776:	74 41                	je     801077b9 <trap+0x3d3>
80107778:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010777e:	8b 40 0c             	mov    0xc(%eax),%eax
80107781:	83 f8 04             	cmp    $0x4,%eax
80107784:	75 33                	jne    801077b9 <trap+0x3d3>
80107786:	8b 45 08             	mov    0x8(%ebp),%eax
80107789:	8b 40 30             	mov    0x30(%eax),%eax
8010778c:	83 f8 20             	cmp    $0x20,%eax
8010778f:	75 28                	jne    801077b9 <trap+0x3d3>
    if(proc->ticks++ == QUANTUM-1){  // Check if the amount of ticks of the current process reached the Quantum
80107791:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107797:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
8010779b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010779e:	66 89 48 7c          	mov    %cx,0x7c(%eax)
801077a2:	66 83 fa 04          	cmp    $0x4,%dx
801077a6:	75 11                	jne    801077b9 <trap+0x3d3>
      //cprintf("El proceso con id %d tiene %d ticks\n",proc->pid, proc->ticks);
      proc->ticks=0;  // Restarts the amount of process ticks
801077a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077ae:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
801077b4:	e8 67 d9 ff ff       	call   80105120 <yield>
    }

  }
  // check if the number of ticks was reached to increase the ages.
  if((tf->trapno == T_IRQ0+IRQ_TIMER) && (ticks % TICKSFORAGE == 0))
801077b9:	8b 45 08             	mov    0x8(%ebp),%eax
801077bc:	8b 40 30             	mov    0x30(%eax),%eax
801077bf:	83 f8 20             	cmp    $0x20,%eax
801077c2:	75 28                	jne    801077ec <trap+0x406>
801077c4:	8b 0d 60 81 11 80    	mov    0x80118160,%ecx
801077ca:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801077cf:	89 c8                	mov    %ecx,%eax
801077d1:	f7 e2                	mul    %edx
801077d3:	c1 ea 03             	shr    $0x3,%edx
801077d6:	89 d0                	mov    %edx,%eax
801077d8:	c1 e0 02             	shl    $0x2,%eax
801077db:	01 d0                	add    %edx,%eax
801077dd:	01 c0                	add    %eax,%eax
801077df:	29 c1                	sub    %eax,%ecx
801077e1:	89 ca                	mov    %ecx,%edx
801077e3:	85 d2                	test   %edx,%edx
801077e5:	75 05                	jne    801077ec <trap+0x406>
    calculateaging();
801077e7:	e8 1f cf ff ff       	call   8010470b <calculateaging>


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801077ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077f2:	85 c0                	test   %eax,%eax
801077f4:	74 27                	je     8010781d <trap+0x437>
801077f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077fc:	8b 40 24             	mov    0x24(%eax),%eax
801077ff:	85 c0                	test   %eax,%eax
80107801:	74 1a                	je     8010781d <trap+0x437>
80107803:	8b 45 08             	mov    0x8(%ebp),%eax
80107806:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010780a:	0f b7 c0             	movzwl %ax,%eax
8010780d:	83 e0 03             	and    $0x3,%eax
80107810:	83 f8 03             	cmp    $0x3,%eax
80107813:	75 08                	jne    8010781d <trap+0x437>
    exit();
80107815:	e8 d1 d4 ff ff       	call   80104ceb <exit>
8010781a:	eb 01                	jmp    8010781d <trap+0x437>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010781c:	90                   	nop


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010781d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107820:	5b                   	pop    %ebx
80107821:	5e                   	pop    %esi
80107822:	5f                   	pop    %edi
80107823:	5d                   	pop    %ebp
80107824:	c3                   	ret    

80107825 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107825:	55                   	push   %ebp
80107826:	89 e5                	mov    %esp,%ebp
80107828:	83 ec 14             	sub    $0x14,%esp
8010782b:	8b 45 08             	mov    0x8(%ebp),%eax
8010782e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107832:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107836:	89 c2                	mov    %eax,%edx
80107838:	ec                   	in     (%dx),%al
80107839:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010783c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107840:	c9                   	leave  
80107841:	c3                   	ret    

80107842 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107842:	55                   	push   %ebp
80107843:	89 e5                	mov    %esp,%ebp
80107845:	83 ec 08             	sub    $0x8,%esp
80107848:	8b 55 08             	mov    0x8(%ebp),%edx
8010784b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010784e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107852:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107855:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107859:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010785d:	ee                   	out    %al,(%dx)
}
8010785e:	90                   	nop
8010785f:	c9                   	leave  
80107860:	c3                   	ret    

80107861 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107861:	55                   	push   %ebp
80107862:	89 e5                	mov    %esp,%ebp
80107864:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107867:	6a 00                	push   $0x0
80107869:	68 fa 03 00 00       	push   $0x3fa
8010786e:	e8 cf ff ff ff       	call   80107842 <outb>
80107873:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107876:	68 80 00 00 00       	push   $0x80
8010787b:	68 fb 03 00 00       	push   $0x3fb
80107880:	e8 bd ff ff ff       	call   80107842 <outb>
80107885:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107888:	6a 0c                	push   $0xc
8010788a:	68 f8 03 00 00       	push   $0x3f8
8010788f:	e8 ae ff ff ff       	call   80107842 <outb>
80107894:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107897:	6a 00                	push   $0x0
80107899:	68 f9 03 00 00       	push   $0x3f9
8010789e:	e8 9f ff ff ff       	call   80107842 <outb>
801078a3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801078a6:	6a 03                	push   $0x3
801078a8:	68 fb 03 00 00       	push   $0x3fb
801078ad:	e8 90 ff ff ff       	call   80107842 <outb>
801078b2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801078b5:	6a 00                	push   $0x0
801078b7:	68 fc 03 00 00       	push   $0x3fc
801078bc:	e8 81 ff ff ff       	call   80107842 <outb>
801078c1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801078c4:	6a 01                	push   $0x1
801078c6:	68 f9 03 00 00       	push   $0x3f9
801078cb:	e8 72 ff ff ff       	call   80107842 <outb>
801078d0:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801078d3:	68 fd 03 00 00       	push   $0x3fd
801078d8:	e8 48 ff ff ff       	call   80107825 <inb>
801078dd:	83 c4 04             	add    $0x4,%esp
801078e0:	3c ff                	cmp    $0xff,%al
801078e2:	74 6e                	je     80107952 <uartinit+0xf1>
    return;
  uart = 1;
801078e4:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
801078eb:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801078ee:	68 fa 03 00 00       	push   $0x3fa
801078f3:	e8 2d ff ff ff       	call   80107825 <inb>
801078f8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801078fb:	68 f8 03 00 00       	push   $0x3f8
80107900:	e8 20 ff ff ff       	call   80107825 <inb>
80107905:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107908:	83 ec 0c             	sub    $0xc,%esp
8010790b:	6a 04                	push   $0x4
8010790d:	e8 29 c7 ff ff       	call   8010403b <picenable>
80107912:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107915:	83 ec 08             	sub    $0x8,%esp
80107918:	6a 00                	push   $0x0
8010791a:	6a 04                	push   $0x4
8010791c:	e8 7b b1 ff ff       	call   80102a9c <ioapicenable>
80107921:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107924:	c7 45 f4 f8 99 10 80 	movl   $0x801099f8,-0xc(%ebp)
8010792b:	eb 19                	jmp    80107946 <uartinit+0xe5>
    uartputc(*p);
8010792d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107930:	0f b6 00             	movzbl (%eax),%eax
80107933:	0f be c0             	movsbl %al,%eax
80107936:	83 ec 0c             	sub    $0xc,%esp
80107939:	50                   	push   %eax
8010793a:	e8 16 00 00 00       	call   80107955 <uartputc>
8010793f:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107942:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107949:	0f b6 00             	movzbl (%eax),%eax
8010794c:	84 c0                	test   %al,%al
8010794e:	75 dd                	jne    8010792d <uartinit+0xcc>
80107950:	eb 01                	jmp    80107953 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107952:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107953:	c9                   	leave  
80107954:	c3                   	ret    

80107955 <uartputc>:

void
uartputc(int c)
{
80107955:	55                   	push   %ebp
80107956:	89 e5                	mov    %esp,%ebp
80107958:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010795b:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107960:	85 c0                	test   %eax,%eax
80107962:	74 53                	je     801079b7 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010796b:	eb 11                	jmp    8010797e <uartputc+0x29>
    microdelay(10);
8010796d:	83 ec 0c             	sub    $0xc,%esp
80107970:	6a 0a                	push   $0xa
80107972:	e8 8b b6 ff ff       	call   80103002 <microdelay>
80107977:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010797a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010797e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107982:	7f 1a                	jg     8010799e <uartputc+0x49>
80107984:	83 ec 0c             	sub    $0xc,%esp
80107987:	68 fd 03 00 00       	push   $0x3fd
8010798c:	e8 94 fe ff ff       	call   80107825 <inb>
80107991:	83 c4 10             	add    $0x10,%esp
80107994:	0f b6 c0             	movzbl %al,%eax
80107997:	83 e0 20             	and    $0x20,%eax
8010799a:	85 c0                	test   %eax,%eax
8010799c:	74 cf                	je     8010796d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010799e:	8b 45 08             	mov    0x8(%ebp),%eax
801079a1:	0f b6 c0             	movzbl %al,%eax
801079a4:	83 ec 08             	sub    $0x8,%esp
801079a7:	50                   	push   %eax
801079a8:	68 f8 03 00 00       	push   $0x3f8
801079ad:	e8 90 fe ff ff       	call   80107842 <outb>
801079b2:	83 c4 10             	add    $0x10,%esp
801079b5:	eb 01                	jmp    801079b8 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801079b7:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801079b8:	c9                   	leave  
801079b9:	c3                   	ret    

801079ba <uartgetc>:

static int
uartgetc(void)
{
801079ba:	55                   	push   %ebp
801079bb:	89 e5                	mov    %esp,%ebp
  if(!uart)
801079bd:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801079c2:	85 c0                	test   %eax,%eax
801079c4:	75 07                	jne    801079cd <uartgetc+0x13>
    return -1;
801079c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079cb:	eb 2e                	jmp    801079fb <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801079cd:	68 fd 03 00 00       	push   $0x3fd
801079d2:	e8 4e fe ff ff       	call   80107825 <inb>
801079d7:	83 c4 04             	add    $0x4,%esp
801079da:	0f b6 c0             	movzbl %al,%eax
801079dd:	83 e0 01             	and    $0x1,%eax
801079e0:	85 c0                	test   %eax,%eax
801079e2:	75 07                	jne    801079eb <uartgetc+0x31>
    return -1;
801079e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079e9:	eb 10                	jmp    801079fb <uartgetc+0x41>
  return inb(COM1+0);
801079eb:	68 f8 03 00 00       	push   $0x3f8
801079f0:	e8 30 fe ff ff       	call   80107825 <inb>
801079f5:	83 c4 04             	add    $0x4,%esp
801079f8:	0f b6 c0             	movzbl %al,%eax
}
801079fb:	c9                   	leave  
801079fc:	c3                   	ret    

801079fd <uartintr>:

void
uartintr(void)
{
801079fd:	55                   	push   %ebp
801079fe:	89 e5                	mov    %esp,%ebp
80107a00:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107a03:	83 ec 0c             	sub    $0xc,%esp
80107a06:	68 ba 79 10 80       	push   $0x801079ba
80107a0b:	e8 cd 8d ff ff       	call   801007dd <consoleintr>
80107a10:	83 c4 10             	add    $0x10,%esp
}
80107a13:	90                   	nop
80107a14:	c9                   	leave  
80107a15:	c3                   	ret    

80107a16 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $0
80107a18:	6a 00                	push   $0x0
  jmp alltraps
80107a1a:	e9 67 f7 ff ff       	jmp    80107186 <alltraps>

80107a1f <vector1>:
.globl vector1
vector1:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $1
80107a21:	6a 01                	push   $0x1
  jmp alltraps
80107a23:	e9 5e f7 ff ff       	jmp    80107186 <alltraps>

80107a28 <vector2>:
.globl vector2
vector2:
  pushl $0
80107a28:	6a 00                	push   $0x0
  pushl $2
80107a2a:	6a 02                	push   $0x2
  jmp alltraps
80107a2c:	e9 55 f7 ff ff       	jmp    80107186 <alltraps>

80107a31 <vector3>:
.globl vector3
vector3:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $3
80107a33:	6a 03                	push   $0x3
  jmp alltraps
80107a35:	e9 4c f7 ff ff       	jmp    80107186 <alltraps>

80107a3a <vector4>:
.globl vector4
vector4:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $4
80107a3c:	6a 04                	push   $0x4
  jmp alltraps
80107a3e:	e9 43 f7 ff ff       	jmp    80107186 <alltraps>

80107a43 <vector5>:
.globl vector5
vector5:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $5
80107a45:	6a 05                	push   $0x5
  jmp alltraps
80107a47:	e9 3a f7 ff ff       	jmp    80107186 <alltraps>

80107a4c <vector6>:
.globl vector6
vector6:
  pushl $0
80107a4c:	6a 00                	push   $0x0
  pushl $6
80107a4e:	6a 06                	push   $0x6
  jmp alltraps
80107a50:	e9 31 f7 ff ff       	jmp    80107186 <alltraps>

80107a55 <vector7>:
.globl vector7
vector7:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $7
80107a57:	6a 07                	push   $0x7
  jmp alltraps
80107a59:	e9 28 f7 ff ff       	jmp    80107186 <alltraps>

80107a5e <vector8>:
.globl vector8
vector8:
  pushl $8
80107a5e:	6a 08                	push   $0x8
  jmp alltraps
80107a60:	e9 21 f7 ff ff       	jmp    80107186 <alltraps>

80107a65 <vector9>:
.globl vector9
vector9:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $9
80107a67:	6a 09                	push   $0x9
  jmp alltraps
80107a69:	e9 18 f7 ff ff       	jmp    80107186 <alltraps>

80107a6e <vector10>:
.globl vector10
vector10:
  pushl $10
80107a6e:	6a 0a                	push   $0xa
  jmp alltraps
80107a70:	e9 11 f7 ff ff       	jmp    80107186 <alltraps>

80107a75 <vector11>:
.globl vector11
vector11:
  pushl $11
80107a75:	6a 0b                	push   $0xb
  jmp alltraps
80107a77:	e9 0a f7 ff ff       	jmp    80107186 <alltraps>

80107a7c <vector12>:
.globl vector12
vector12:
  pushl $12
80107a7c:	6a 0c                	push   $0xc
  jmp alltraps
80107a7e:	e9 03 f7 ff ff       	jmp    80107186 <alltraps>

80107a83 <vector13>:
.globl vector13
vector13:
  pushl $13
80107a83:	6a 0d                	push   $0xd
  jmp alltraps
80107a85:	e9 fc f6 ff ff       	jmp    80107186 <alltraps>

80107a8a <vector14>:
.globl vector14
vector14:
  pushl $14
80107a8a:	6a 0e                	push   $0xe
  jmp alltraps
80107a8c:	e9 f5 f6 ff ff       	jmp    80107186 <alltraps>

80107a91 <vector15>:
.globl vector15
vector15:
  pushl $0
80107a91:	6a 00                	push   $0x0
  pushl $15
80107a93:	6a 0f                	push   $0xf
  jmp alltraps
80107a95:	e9 ec f6 ff ff       	jmp    80107186 <alltraps>

80107a9a <vector16>:
.globl vector16
vector16:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $16
80107a9c:	6a 10                	push   $0x10
  jmp alltraps
80107a9e:	e9 e3 f6 ff ff       	jmp    80107186 <alltraps>

80107aa3 <vector17>:
.globl vector17
vector17:
  pushl $17
80107aa3:	6a 11                	push   $0x11
  jmp alltraps
80107aa5:	e9 dc f6 ff ff       	jmp    80107186 <alltraps>

80107aaa <vector18>:
.globl vector18
vector18:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $18
80107aac:	6a 12                	push   $0x12
  jmp alltraps
80107aae:	e9 d3 f6 ff ff       	jmp    80107186 <alltraps>

80107ab3 <vector19>:
.globl vector19
vector19:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $19
80107ab5:	6a 13                	push   $0x13
  jmp alltraps
80107ab7:	e9 ca f6 ff ff       	jmp    80107186 <alltraps>

80107abc <vector20>:
.globl vector20
vector20:
  pushl $0
80107abc:	6a 00                	push   $0x0
  pushl $20
80107abe:	6a 14                	push   $0x14
  jmp alltraps
80107ac0:	e9 c1 f6 ff ff       	jmp    80107186 <alltraps>

80107ac5 <vector21>:
.globl vector21
vector21:
  pushl $0
80107ac5:	6a 00                	push   $0x0
  pushl $21
80107ac7:	6a 15                	push   $0x15
  jmp alltraps
80107ac9:	e9 b8 f6 ff ff       	jmp    80107186 <alltraps>

80107ace <vector22>:
.globl vector22
vector22:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $22
80107ad0:	6a 16                	push   $0x16
  jmp alltraps
80107ad2:	e9 af f6 ff ff       	jmp    80107186 <alltraps>

80107ad7 <vector23>:
.globl vector23
vector23:
  pushl $0
80107ad7:	6a 00                	push   $0x0
  pushl $23
80107ad9:	6a 17                	push   $0x17
  jmp alltraps
80107adb:	e9 a6 f6 ff ff       	jmp    80107186 <alltraps>

80107ae0 <vector24>:
.globl vector24
vector24:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $24
80107ae2:	6a 18                	push   $0x18
  jmp alltraps
80107ae4:	e9 9d f6 ff ff       	jmp    80107186 <alltraps>

80107ae9 <vector25>:
.globl vector25
vector25:
  pushl $0
80107ae9:	6a 00                	push   $0x0
  pushl $25
80107aeb:	6a 19                	push   $0x19
  jmp alltraps
80107aed:	e9 94 f6 ff ff       	jmp    80107186 <alltraps>

80107af2 <vector26>:
.globl vector26
vector26:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $26
80107af4:	6a 1a                	push   $0x1a
  jmp alltraps
80107af6:	e9 8b f6 ff ff       	jmp    80107186 <alltraps>

80107afb <vector27>:
.globl vector27
vector27:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $27
80107afd:	6a 1b                	push   $0x1b
  jmp alltraps
80107aff:	e9 82 f6 ff ff       	jmp    80107186 <alltraps>

80107b04 <vector28>:
.globl vector28
vector28:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $28
80107b06:	6a 1c                	push   $0x1c
  jmp alltraps
80107b08:	e9 79 f6 ff ff       	jmp    80107186 <alltraps>

80107b0d <vector29>:
.globl vector29
vector29:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $29
80107b0f:	6a 1d                	push   $0x1d
  jmp alltraps
80107b11:	e9 70 f6 ff ff       	jmp    80107186 <alltraps>

80107b16 <vector30>:
.globl vector30
vector30:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $30
80107b18:	6a 1e                	push   $0x1e
  jmp alltraps
80107b1a:	e9 67 f6 ff ff       	jmp    80107186 <alltraps>

80107b1f <vector31>:
.globl vector31
vector31:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $31
80107b21:	6a 1f                	push   $0x1f
  jmp alltraps
80107b23:	e9 5e f6 ff ff       	jmp    80107186 <alltraps>

80107b28 <vector32>:
.globl vector32
vector32:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $32
80107b2a:	6a 20                	push   $0x20
  jmp alltraps
80107b2c:	e9 55 f6 ff ff       	jmp    80107186 <alltraps>

80107b31 <vector33>:
.globl vector33
vector33:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $33
80107b33:	6a 21                	push   $0x21
  jmp alltraps
80107b35:	e9 4c f6 ff ff       	jmp    80107186 <alltraps>

80107b3a <vector34>:
.globl vector34
vector34:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $34
80107b3c:	6a 22                	push   $0x22
  jmp alltraps
80107b3e:	e9 43 f6 ff ff       	jmp    80107186 <alltraps>

80107b43 <vector35>:
.globl vector35
vector35:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $35
80107b45:	6a 23                	push   $0x23
  jmp alltraps
80107b47:	e9 3a f6 ff ff       	jmp    80107186 <alltraps>

80107b4c <vector36>:
.globl vector36
vector36:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $36
80107b4e:	6a 24                	push   $0x24
  jmp alltraps
80107b50:	e9 31 f6 ff ff       	jmp    80107186 <alltraps>

80107b55 <vector37>:
.globl vector37
vector37:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $37
80107b57:	6a 25                	push   $0x25
  jmp alltraps
80107b59:	e9 28 f6 ff ff       	jmp    80107186 <alltraps>

80107b5e <vector38>:
.globl vector38
vector38:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $38
80107b60:	6a 26                	push   $0x26
  jmp alltraps
80107b62:	e9 1f f6 ff ff       	jmp    80107186 <alltraps>

80107b67 <vector39>:
.globl vector39
vector39:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $39
80107b69:	6a 27                	push   $0x27
  jmp alltraps
80107b6b:	e9 16 f6 ff ff       	jmp    80107186 <alltraps>

80107b70 <vector40>:
.globl vector40
vector40:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $40
80107b72:	6a 28                	push   $0x28
  jmp alltraps
80107b74:	e9 0d f6 ff ff       	jmp    80107186 <alltraps>

80107b79 <vector41>:
.globl vector41
vector41:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $41
80107b7b:	6a 29                	push   $0x29
  jmp alltraps
80107b7d:	e9 04 f6 ff ff       	jmp    80107186 <alltraps>

80107b82 <vector42>:
.globl vector42
vector42:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $42
80107b84:	6a 2a                	push   $0x2a
  jmp alltraps
80107b86:	e9 fb f5 ff ff       	jmp    80107186 <alltraps>

80107b8b <vector43>:
.globl vector43
vector43:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $43
80107b8d:	6a 2b                	push   $0x2b
  jmp alltraps
80107b8f:	e9 f2 f5 ff ff       	jmp    80107186 <alltraps>

80107b94 <vector44>:
.globl vector44
vector44:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $44
80107b96:	6a 2c                	push   $0x2c
  jmp alltraps
80107b98:	e9 e9 f5 ff ff       	jmp    80107186 <alltraps>

80107b9d <vector45>:
.globl vector45
vector45:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $45
80107b9f:	6a 2d                	push   $0x2d
  jmp alltraps
80107ba1:	e9 e0 f5 ff ff       	jmp    80107186 <alltraps>

80107ba6 <vector46>:
.globl vector46
vector46:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $46
80107ba8:	6a 2e                	push   $0x2e
  jmp alltraps
80107baa:	e9 d7 f5 ff ff       	jmp    80107186 <alltraps>

80107baf <vector47>:
.globl vector47
vector47:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $47
80107bb1:	6a 2f                	push   $0x2f
  jmp alltraps
80107bb3:	e9 ce f5 ff ff       	jmp    80107186 <alltraps>

80107bb8 <vector48>:
.globl vector48
vector48:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $48
80107bba:	6a 30                	push   $0x30
  jmp alltraps
80107bbc:	e9 c5 f5 ff ff       	jmp    80107186 <alltraps>

80107bc1 <vector49>:
.globl vector49
vector49:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $49
80107bc3:	6a 31                	push   $0x31
  jmp alltraps
80107bc5:	e9 bc f5 ff ff       	jmp    80107186 <alltraps>

80107bca <vector50>:
.globl vector50
vector50:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $50
80107bcc:	6a 32                	push   $0x32
  jmp alltraps
80107bce:	e9 b3 f5 ff ff       	jmp    80107186 <alltraps>

80107bd3 <vector51>:
.globl vector51
vector51:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $51
80107bd5:	6a 33                	push   $0x33
  jmp alltraps
80107bd7:	e9 aa f5 ff ff       	jmp    80107186 <alltraps>

80107bdc <vector52>:
.globl vector52
vector52:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $52
80107bde:	6a 34                	push   $0x34
  jmp alltraps
80107be0:	e9 a1 f5 ff ff       	jmp    80107186 <alltraps>

80107be5 <vector53>:
.globl vector53
vector53:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $53
80107be7:	6a 35                	push   $0x35
  jmp alltraps
80107be9:	e9 98 f5 ff ff       	jmp    80107186 <alltraps>

80107bee <vector54>:
.globl vector54
vector54:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $54
80107bf0:	6a 36                	push   $0x36
  jmp alltraps
80107bf2:	e9 8f f5 ff ff       	jmp    80107186 <alltraps>

80107bf7 <vector55>:
.globl vector55
vector55:
  pushl $0
80107bf7:	6a 00                	push   $0x0
  pushl $55
80107bf9:	6a 37                	push   $0x37
  jmp alltraps
80107bfb:	e9 86 f5 ff ff       	jmp    80107186 <alltraps>

80107c00 <vector56>:
.globl vector56
vector56:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $56
80107c02:	6a 38                	push   $0x38
  jmp alltraps
80107c04:	e9 7d f5 ff ff       	jmp    80107186 <alltraps>

80107c09 <vector57>:
.globl vector57
vector57:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $57
80107c0b:	6a 39                	push   $0x39
  jmp alltraps
80107c0d:	e9 74 f5 ff ff       	jmp    80107186 <alltraps>

80107c12 <vector58>:
.globl vector58
vector58:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $58
80107c14:	6a 3a                	push   $0x3a
  jmp alltraps
80107c16:	e9 6b f5 ff ff       	jmp    80107186 <alltraps>

80107c1b <vector59>:
.globl vector59
vector59:
  pushl $0
80107c1b:	6a 00                	push   $0x0
  pushl $59
80107c1d:	6a 3b                	push   $0x3b
  jmp alltraps
80107c1f:	e9 62 f5 ff ff       	jmp    80107186 <alltraps>

80107c24 <vector60>:
.globl vector60
vector60:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $60
80107c26:	6a 3c                	push   $0x3c
  jmp alltraps
80107c28:	e9 59 f5 ff ff       	jmp    80107186 <alltraps>

80107c2d <vector61>:
.globl vector61
vector61:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $61
80107c2f:	6a 3d                	push   $0x3d
  jmp alltraps
80107c31:	e9 50 f5 ff ff       	jmp    80107186 <alltraps>

80107c36 <vector62>:
.globl vector62
vector62:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $62
80107c38:	6a 3e                	push   $0x3e
  jmp alltraps
80107c3a:	e9 47 f5 ff ff       	jmp    80107186 <alltraps>

80107c3f <vector63>:
.globl vector63
vector63:
  pushl $0
80107c3f:	6a 00                	push   $0x0
  pushl $63
80107c41:	6a 3f                	push   $0x3f
  jmp alltraps
80107c43:	e9 3e f5 ff ff       	jmp    80107186 <alltraps>

80107c48 <vector64>:
.globl vector64
vector64:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $64
80107c4a:	6a 40                	push   $0x40
  jmp alltraps
80107c4c:	e9 35 f5 ff ff       	jmp    80107186 <alltraps>

80107c51 <vector65>:
.globl vector65
vector65:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $65
80107c53:	6a 41                	push   $0x41
  jmp alltraps
80107c55:	e9 2c f5 ff ff       	jmp    80107186 <alltraps>

80107c5a <vector66>:
.globl vector66
vector66:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $66
80107c5c:	6a 42                	push   $0x42
  jmp alltraps
80107c5e:	e9 23 f5 ff ff       	jmp    80107186 <alltraps>

80107c63 <vector67>:
.globl vector67
vector67:
  pushl $0
80107c63:	6a 00                	push   $0x0
  pushl $67
80107c65:	6a 43                	push   $0x43
  jmp alltraps
80107c67:	e9 1a f5 ff ff       	jmp    80107186 <alltraps>

80107c6c <vector68>:
.globl vector68
vector68:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $68
80107c6e:	6a 44                	push   $0x44
  jmp alltraps
80107c70:	e9 11 f5 ff ff       	jmp    80107186 <alltraps>

80107c75 <vector69>:
.globl vector69
vector69:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $69
80107c77:	6a 45                	push   $0x45
  jmp alltraps
80107c79:	e9 08 f5 ff ff       	jmp    80107186 <alltraps>

80107c7e <vector70>:
.globl vector70
vector70:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $70
80107c80:	6a 46                	push   $0x46
  jmp alltraps
80107c82:	e9 ff f4 ff ff       	jmp    80107186 <alltraps>

80107c87 <vector71>:
.globl vector71
vector71:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $71
80107c89:	6a 47                	push   $0x47
  jmp alltraps
80107c8b:	e9 f6 f4 ff ff       	jmp    80107186 <alltraps>

80107c90 <vector72>:
.globl vector72
vector72:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $72
80107c92:	6a 48                	push   $0x48
  jmp alltraps
80107c94:	e9 ed f4 ff ff       	jmp    80107186 <alltraps>

80107c99 <vector73>:
.globl vector73
vector73:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $73
80107c9b:	6a 49                	push   $0x49
  jmp alltraps
80107c9d:	e9 e4 f4 ff ff       	jmp    80107186 <alltraps>

80107ca2 <vector74>:
.globl vector74
vector74:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $74
80107ca4:	6a 4a                	push   $0x4a
  jmp alltraps
80107ca6:	e9 db f4 ff ff       	jmp    80107186 <alltraps>

80107cab <vector75>:
.globl vector75
vector75:
  pushl $0
80107cab:	6a 00                	push   $0x0
  pushl $75
80107cad:	6a 4b                	push   $0x4b
  jmp alltraps
80107caf:	e9 d2 f4 ff ff       	jmp    80107186 <alltraps>

80107cb4 <vector76>:
.globl vector76
vector76:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $76
80107cb6:	6a 4c                	push   $0x4c
  jmp alltraps
80107cb8:	e9 c9 f4 ff ff       	jmp    80107186 <alltraps>

80107cbd <vector77>:
.globl vector77
vector77:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $77
80107cbf:	6a 4d                	push   $0x4d
  jmp alltraps
80107cc1:	e9 c0 f4 ff ff       	jmp    80107186 <alltraps>

80107cc6 <vector78>:
.globl vector78
vector78:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $78
80107cc8:	6a 4e                	push   $0x4e
  jmp alltraps
80107cca:	e9 b7 f4 ff ff       	jmp    80107186 <alltraps>

80107ccf <vector79>:
.globl vector79
vector79:
  pushl $0
80107ccf:	6a 00                	push   $0x0
  pushl $79
80107cd1:	6a 4f                	push   $0x4f
  jmp alltraps
80107cd3:	e9 ae f4 ff ff       	jmp    80107186 <alltraps>

80107cd8 <vector80>:
.globl vector80
vector80:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $80
80107cda:	6a 50                	push   $0x50
  jmp alltraps
80107cdc:	e9 a5 f4 ff ff       	jmp    80107186 <alltraps>

80107ce1 <vector81>:
.globl vector81
vector81:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $81
80107ce3:	6a 51                	push   $0x51
  jmp alltraps
80107ce5:	e9 9c f4 ff ff       	jmp    80107186 <alltraps>

80107cea <vector82>:
.globl vector82
vector82:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $82
80107cec:	6a 52                	push   $0x52
  jmp alltraps
80107cee:	e9 93 f4 ff ff       	jmp    80107186 <alltraps>

80107cf3 <vector83>:
.globl vector83
vector83:
  pushl $0
80107cf3:	6a 00                	push   $0x0
  pushl $83
80107cf5:	6a 53                	push   $0x53
  jmp alltraps
80107cf7:	e9 8a f4 ff ff       	jmp    80107186 <alltraps>

80107cfc <vector84>:
.globl vector84
vector84:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $84
80107cfe:	6a 54                	push   $0x54
  jmp alltraps
80107d00:	e9 81 f4 ff ff       	jmp    80107186 <alltraps>

80107d05 <vector85>:
.globl vector85
vector85:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $85
80107d07:	6a 55                	push   $0x55
  jmp alltraps
80107d09:	e9 78 f4 ff ff       	jmp    80107186 <alltraps>

80107d0e <vector86>:
.globl vector86
vector86:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $86
80107d10:	6a 56                	push   $0x56
  jmp alltraps
80107d12:	e9 6f f4 ff ff       	jmp    80107186 <alltraps>

80107d17 <vector87>:
.globl vector87
vector87:
  pushl $0
80107d17:	6a 00                	push   $0x0
  pushl $87
80107d19:	6a 57                	push   $0x57
  jmp alltraps
80107d1b:	e9 66 f4 ff ff       	jmp    80107186 <alltraps>

80107d20 <vector88>:
.globl vector88
vector88:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $88
80107d22:	6a 58                	push   $0x58
  jmp alltraps
80107d24:	e9 5d f4 ff ff       	jmp    80107186 <alltraps>

80107d29 <vector89>:
.globl vector89
vector89:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $89
80107d2b:	6a 59                	push   $0x59
  jmp alltraps
80107d2d:	e9 54 f4 ff ff       	jmp    80107186 <alltraps>

80107d32 <vector90>:
.globl vector90
vector90:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $90
80107d34:	6a 5a                	push   $0x5a
  jmp alltraps
80107d36:	e9 4b f4 ff ff       	jmp    80107186 <alltraps>

80107d3b <vector91>:
.globl vector91
vector91:
  pushl $0
80107d3b:	6a 00                	push   $0x0
  pushl $91
80107d3d:	6a 5b                	push   $0x5b
  jmp alltraps
80107d3f:	e9 42 f4 ff ff       	jmp    80107186 <alltraps>

80107d44 <vector92>:
.globl vector92
vector92:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $92
80107d46:	6a 5c                	push   $0x5c
  jmp alltraps
80107d48:	e9 39 f4 ff ff       	jmp    80107186 <alltraps>

80107d4d <vector93>:
.globl vector93
vector93:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $93
80107d4f:	6a 5d                	push   $0x5d
  jmp alltraps
80107d51:	e9 30 f4 ff ff       	jmp    80107186 <alltraps>

80107d56 <vector94>:
.globl vector94
vector94:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $94
80107d58:	6a 5e                	push   $0x5e
  jmp alltraps
80107d5a:	e9 27 f4 ff ff       	jmp    80107186 <alltraps>

80107d5f <vector95>:
.globl vector95
vector95:
  pushl $0
80107d5f:	6a 00                	push   $0x0
  pushl $95
80107d61:	6a 5f                	push   $0x5f
  jmp alltraps
80107d63:	e9 1e f4 ff ff       	jmp    80107186 <alltraps>

80107d68 <vector96>:
.globl vector96
vector96:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $96
80107d6a:	6a 60                	push   $0x60
  jmp alltraps
80107d6c:	e9 15 f4 ff ff       	jmp    80107186 <alltraps>

80107d71 <vector97>:
.globl vector97
vector97:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $97
80107d73:	6a 61                	push   $0x61
  jmp alltraps
80107d75:	e9 0c f4 ff ff       	jmp    80107186 <alltraps>

80107d7a <vector98>:
.globl vector98
vector98:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $98
80107d7c:	6a 62                	push   $0x62
  jmp alltraps
80107d7e:	e9 03 f4 ff ff       	jmp    80107186 <alltraps>

80107d83 <vector99>:
.globl vector99
vector99:
  pushl $0
80107d83:	6a 00                	push   $0x0
  pushl $99
80107d85:	6a 63                	push   $0x63
  jmp alltraps
80107d87:	e9 fa f3 ff ff       	jmp    80107186 <alltraps>

80107d8c <vector100>:
.globl vector100
vector100:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $100
80107d8e:	6a 64                	push   $0x64
  jmp alltraps
80107d90:	e9 f1 f3 ff ff       	jmp    80107186 <alltraps>

80107d95 <vector101>:
.globl vector101
vector101:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $101
80107d97:	6a 65                	push   $0x65
  jmp alltraps
80107d99:	e9 e8 f3 ff ff       	jmp    80107186 <alltraps>

80107d9e <vector102>:
.globl vector102
vector102:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $102
80107da0:	6a 66                	push   $0x66
  jmp alltraps
80107da2:	e9 df f3 ff ff       	jmp    80107186 <alltraps>

80107da7 <vector103>:
.globl vector103
vector103:
  pushl $0
80107da7:	6a 00                	push   $0x0
  pushl $103
80107da9:	6a 67                	push   $0x67
  jmp alltraps
80107dab:	e9 d6 f3 ff ff       	jmp    80107186 <alltraps>

80107db0 <vector104>:
.globl vector104
vector104:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $104
80107db2:	6a 68                	push   $0x68
  jmp alltraps
80107db4:	e9 cd f3 ff ff       	jmp    80107186 <alltraps>

80107db9 <vector105>:
.globl vector105
vector105:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $105
80107dbb:	6a 69                	push   $0x69
  jmp alltraps
80107dbd:	e9 c4 f3 ff ff       	jmp    80107186 <alltraps>

80107dc2 <vector106>:
.globl vector106
vector106:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $106
80107dc4:	6a 6a                	push   $0x6a
  jmp alltraps
80107dc6:	e9 bb f3 ff ff       	jmp    80107186 <alltraps>

80107dcb <vector107>:
.globl vector107
vector107:
  pushl $0
80107dcb:	6a 00                	push   $0x0
  pushl $107
80107dcd:	6a 6b                	push   $0x6b
  jmp alltraps
80107dcf:	e9 b2 f3 ff ff       	jmp    80107186 <alltraps>

80107dd4 <vector108>:
.globl vector108
vector108:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $108
80107dd6:	6a 6c                	push   $0x6c
  jmp alltraps
80107dd8:	e9 a9 f3 ff ff       	jmp    80107186 <alltraps>

80107ddd <vector109>:
.globl vector109
vector109:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $109
80107ddf:	6a 6d                	push   $0x6d
  jmp alltraps
80107de1:	e9 a0 f3 ff ff       	jmp    80107186 <alltraps>

80107de6 <vector110>:
.globl vector110
vector110:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $110
80107de8:	6a 6e                	push   $0x6e
  jmp alltraps
80107dea:	e9 97 f3 ff ff       	jmp    80107186 <alltraps>

80107def <vector111>:
.globl vector111
vector111:
  pushl $0
80107def:	6a 00                	push   $0x0
  pushl $111
80107df1:	6a 6f                	push   $0x6f
  jmp alltraps
80107df3:	e9 8e f3 ff ff       	jmp    80107186 <alltraps>

80107df8 <vector112>:
.globl vector112
vector112:
  pushl $0
80107df8:	6a 00                	push   $0x0
  pushl $112
80107dfa:	6a 70                	push   $0x70
  jmp alltraps
80107dfc:	e9 85 f3 ff ff       	jmp    80107186 <alltraps>

80107e01 <vector113>:
.globl vector113
vector113:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $113
80107e03:	6a 71                	push   $0x71
  jmp alltraps
80107e05:	e9 7c f3 ff ff       	jmp    80107186 <alltraps>

80107e0a <vector114>:
.globl vector114
vector114:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $114
80107e0c:	6a 72                	push   $0x72
  jmp alltraps
80107e0e:	e9 73 f3 ff ff       	jmp    80107186 <alltraps>

80107e13 <vector115>:
.globl vector115
vector115:
  pushl $0
80107e13:	6a 00                	push   $0x0
  pushl $115
80107e15:	6a 73                	push   $0x73
  jmp alltraps
80107e17:	e9 6a f3 ff ff       	jmp    80107186 <alltraps>

80107e1c <vector116>:
.globl vector116
vector116:
  pushl $0
80107e1c:	6a 00                	push   $0x0
  pushl $116
80107e1e:	6a 74                	push   $0x74
  jmp alltraps
80107e20:	e9 61 f3 ff ff       	jmp    80107186 <alltraps>

80107e25 <vector117>:
.globl vector117
vector117:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $117
80107e27:	6a 75                	push   $0x75
  jmp alltraps
80107e29:	e9 58 f3 ff ff       	jmp    80107186 <alltraps>

80107e2e <vector118>:
.globl vector118
vector118:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $118
80107e30:	6a 76                	push   $0x76
  jmp alltraps
80107e32:	e9 4f f3 ff ff       	jmp    80107186 <alltraps>

80107e37 <vector119>:
.globl vector119
vector119:
  pushl $0
80107e37:	6a 00                	push   $0x0
  pushl $119
80107e39:	6a 77                	push   $0x77
  jmp alltraps
80107e3b:	e9 46 f3 ff ff       	jmp    80107186 <alltraps>

80107e40 <vector120>:
.globl vector120
vector120:
  pushl $0
80107e40:	6a 00                	push   $0x0
  pushl $120
80107e42:	6a 78                	push   $0x78
  jmp alltraps
80107e44:	e9 3d f3 ff ff       	jmp    80107186 <alltraps>

80107e49 <vector121>:
.globl vector121
vector121:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $121
80107e4b:	6a 79                	push   $0x79
  jmp alltraps
80107e4d:	e9 34 f3 ff ff       	jmp    80107186 <alltraps>

80107e52 <vector122>:
.globl vector122
vector122:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $122
80107e54:	6a 7a                	push   $0x7a
  jmp alltraps
80107e56:	e9 2b f3 ff ff       	jmp    80107186 <alltraps>

80107e5b <vector123>:
.globl vector123
vector123:
  pushl $0
80107e5b:	6a 00                	push   $0x0
  pushl $123
80107e5d:	6a 7b                	push   $0x7b
  jmp alltraps
80107e5f:	e9 22 f3 ff ff       	jmp    80107186 <alltraps>

80107e64 <vector124>:
.globl vector124
vector124:
  pushl $0
80107e64:	6a 00                	push   $0x0
  pushl $124
80107e66:	6a 7c                	push   $0x7c
  jmp alltraps
80107e68:	e9 19 f3 ff ff       	jmp    80107186 <alltraps>

80107e6d <vector125>:
.globl vector125
vector125:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $125
80107e6f:	6a 7d                	push   $0x7d
  jmp alltraps
80107e71:	e9 10 f3 ff ff       	jmp    80107186 <alltraps>

80107e76 <vector126>:
.globl vector126
vector126:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $126
80107e78:	6a 7e                	push   $0x7e
  jmp alltraps
80107e7a:	e9 07 f3 ff ff       	jmp    80107186 <alltraps>

80107e7f <vector127>:
.globl vector127
vector127:
  pushl $0
80107e7f:	6a 00                	push   $0x0
  pushl $127
80107e81:	6a 7f                	push   $0x7f
  jmp alltraps
80107e83:	e9 fe f2 ff ff       	jmp    80107186 <alltraps>

80107e88 <vector128>:
.globl vector128
vector128:
  pushl $0
80107e88:	6a 00                	push   $0x0
  pushl $128
80107e8a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107e8f:	e9 f2 f2 ff ff       	jmp    80107186 <alltraps>

80107e94 <vector129>:
.globl vector129
vector129:
  pushl $0
80107e94:	6a 00                	push   $0x0
  pushl $129
80107e96:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107e9b:	e9 e6 f2 ff ff       	jmp    80107186 <alltraps>

80107ea0 <vector130>:
.globl vector130
vector130:
  pushl $0
80107ea0:	6a 00                	push   $0x0
  pushl $130
80107ea2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107ea7:	e9 da f2 ff ff       	jmp    80107186 <alltraps>

80107eac <vector131>:
.globl vector131
vector131:
  pushl $0
80107eac:	6a 00                	push   $0x0
  pushl $131
80107eae:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107eb3:	e9 ce f2 ff ff       	jmp    80107186 <alltraps>

80107eb8 <vector132>:
.globl vector132
vector132:
  pushl $0
80107eb8:	6a 00                	push   $0x0
  pushl $132
80107eba:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107ebf:	e9 c2 f2 ff ff       	jmp    80107186 <alltraps>

80107ec4 <vector133>:
.globl vector133
vector133:
  pushl $0
80107ec4:	6a 00                	push   $0x0
  pushl $133
80107ec6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107ecb:	e9 b6 f2 ff ff       	jmp    80107186 <alltraps>

80107ed0 <vector134>:
.globl vector134
vector134:
  pushl $0
80107ed0:	6a 00                	push   $0x0
  pushl $134
80107ed2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107ed7:	e9 aa f2 ff ff       	jmp    80107186 <alltraps>

80107edc <vector135>:
.globl vector135
vector135:
  pushl $0
80107edc:	6a 00                	push   $0x0
  pushl $135
80107ede:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107ee3:	e9 9e f2 ff ff       	jmp    80107186 <alltraps>

80107ee8 <vector136>:
.globl vector136
vector136:
  pushl $0
80107ee8:	6a 00                	push   $0x0
  pushl $136
80107eea:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107eef:	e9 92 f2 ff ff       	jmp    80107186 <alltraps>

80107ef4 <vector137>:
.globl vector137
vector137:
  pushl $0
80107ef4:	6a 00                	push   $0x0
  pushl $137
80107ef6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107efb:	e9 86 f2 ff ff       	jmp    80107186 <alltraps>

80107f00 <vector138>:
.globl vector138
vector138:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $138
80107f02:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107f07:	e9 7a f2 ff ff       	jmp    80107186 <alltraps>

80107f0c <vector139>:
.globl vector139
vector139:
  pushl $0
80107f0c:	6a 00                	push   $0x0
  pushl $139
80107f0e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107f13:	e9 6e f2 ff ff       	jmp    80107186 <alltraps>

80107f18 <vector140>:
.globl vector140
vector140:
  pushl $0
80107f18:	6a 00                	push   $0x0
  pushl $140
80107f1a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107f1f:	e9 62 f2 ff ff       	jmp    80107186 <alltraps>

80107f24 <vector141>:
.globl vector141
vector141:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $141
80107f26:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107f2b:	e9 56 f2 ff ff       	jmp    80107186 <alltraps>

80107f30 <vector142>:
.globl vector142
vector142:
  pushl $0
80107f30:	6a 00                	push   $0x0
  pushl $142
80107f32:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107f37:	e9 4a f2 ff ff       	jmp    80107186 <alltraps>

80107f3c <vector143>:
.globl vector143
vector143:
  pushl $0
80107f3c:	6a 00                	push   $0x0
  pushl $143
80107f3e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107f43:	e9 3e f2 ff ff       	jmp    80107186 <alltraps>

80107f48 <vector144>:
.globl vector144
vector144:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $144
80107f4a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107f4f:	e9 32 f2 ff ff       	jmp    80107186 <alltraps>

80107f54 <vector145>:
.globl vector145
vector145:
  pushl $0
80107f54:	6a 00                	push   $0x0
  pushl $145
80107f56:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107f5b:	e9 26 f2 ff ff       	jmp    80107186 <alltraps>

80107f60 <vector146>:
.globl vector146
vector146:
  pushl $0
80107f60:	6a 00                	push   $0x0
  pushl $146
80107f62:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107f67:	e9 1a f2 ff ff       	jmp    80107186 <alltraps>

80107f6c <vector147>:
.globl vector147
vector147:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $147
80107f6e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107f73:	e9 0e f2 ff ff       	jmp    80107186 <alltraps>

80107f78 <vector148>:
.globl vector148
vector148:
  pushl $0
80107f78:	6a 00                	push   $0x0
  pushl $148
80107f7a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107f7f:	e9 02 f2 ff ff       	jmp    80107186 <alltraps>

80107f84 <vector149>:
.globl vector149
vector149:
  pushl $0
80107f84:	6a 00                	push   $0x0
  pushl $149
80107f86:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107f8b:	e9 f6 f1 ff ff       	jmp    80107186 <alltraps>

80107f90 <vector150>:
.globl vector150
vector150:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $150
80107f92:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107f97:	e9 ea f1 ff ff       	jmp    80107186 <alltraps>

80107f9c <vector151>:
.globl vector151
vector151:
  pushl $0
80107f9c:	6a 00                	push   $0x0
  pushl $151
80107f9e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107fa3:	e9 de f1 ff ff       	jmp    80107186 <alltraps>

80107fa8 <vector152>:
.globl vector152
vector152:
  pushl $0
80107fa8:	6a 00                	push   $0x0
  pushl $152
80107faa:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107faf:	e9 d2 f1 ff ff       	jmp    80107186 <alltraps>

80107fb4 <vector153>:
.globl vector153
vector153:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $153
80107fb6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107fbb:	e9 c6 f1 ff ff       	jmp    80107186 <alltraps>

80107fc0 <vector154>:
.globl vector154
vector154:
  pushl $0
80107fc0:	6a 00                	push   $0x0
  pushl $154
80107fc2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107fc7:	e9 ba f1 ff ff       	jmp    80107186 <alltraps>

80107fcc <vector155>:
.globl vector155
vector155:
  pushl $0
80107fcc:	6a 00                	push   $0x0
  pushl $155
80107fce:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107fd3:	e9 ae f1 ff ff       	jmp    80107186 <alltraps>

80107fd8 <vector156>:
.globl vector156
vector156:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $156
80107fda:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107fdf:	e9 a2 f1 ff ff       	jmp    80107186 <alltraps>

80107fe4 <vector157>:
.globl vector157
vector157:
  pushl $0
80107fe4:	6a 00                	push   $0x0
  pushl $157
80107fe6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107feb:	e9 96 f1 ff ff       	jmp    80107186 <alltraps>

80107ff0 <vector158>:
.globl vector158
vector158:
  pushl $0
80107ff0:	6a 00                	push   $0x0
  pushl $158
80107ff2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107ff7:	e9 8a f1 ff ff       	jmp    80107186 <alltraps>

80107ffc <vector159>:
.globl vector159
vector159:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $159
80107ffe:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108003:	e9 7e f1 ff ff       	jmp    80107186 <alltraps>

80108008 <vector160>:
.globl vector160
vector160:
  pushl $0
80108008:	6a 00                	push   $0x0
  pushl $160
8010800a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010800f:	e9 72 f1 ff ff       	jmp    80107186 <alltraps>

80108014 <vector161>:
.globl vector161
vector161:
  pushl $0
80108014:	6a 00                	push   $0x0
  pushl $161
80108016:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010801b:	e9 66 f1 ff ff       	jmp    80107186 <alltraps>

80108020 <vector162>:
.globl vector162
vector162:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $162
80108022:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108027:	e9 5a f1 ff ff       	jmp    80107186 <alltraps>

8010802c <vector163>:
.globl vector163
vector163:
  pushl $0
8010802c:	6a 00                	push   $0x0
  pushl $163
8010802e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108033:	e9 4e f1 ff ff       	jmp    80107186 <alltraps>

80108038 <vector164>:
.globl vector164
vector164:
  pushl $0
80108038:	6a 00                	push   $0x0
  pushl $164
8010803a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010803f:	e9 42 f1 ff ff       	jmp    80107186 <alltraps>

80108044 <vector165>:
.globl vector165
vector165:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $165
80108046:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010804b:	e9 36 f1 ff ff       	jmp    80107186 <alltraps>

80108050 <vector166>:
.globl vector166
vector166:
  pushl $0
80108050:	6a 00                	push   $0x0
  pushl $166
80108052:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108057:	e9 2a f1 ff ff       	jmp    80107186 <alltraps>

8010805c <vector167>:
.globl vector167
vector167:
  pushl $0
8010805c:	6a 00                	push   $0x0
  pushl $167
8010805e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108063:	e9 1e f1 ff ff       	jmp    80107186 <alltraps>

80108068 <vector168>:
.globl vector168
vector168:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $168
8010806a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010806f:	e9 12 f1 ff ff       	jmp    80107186 <alltraps>

80108074 <vector169>:
.globl vector169
vector169:
  pushl $0
80108074:	6a 00                	push   $0x0
  pushl $169
80108076:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010807b:	e9 06 f1 ff ff       	jmp    80107186 <alltraps>

80108080 <vector170>:
.globl vector170
vector170:
  pushl $0
80108080:	6a 00                	push   $0x0
  pushl $170
80108082:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108087:	e9 fa f0 ff ff       	jmp    80107186 <alltraps>

8010808c <vector171>:
.globl vector171
vector171:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $171
8010808e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108093:	e9 ee f0 ff ff       	jmp    80107186 <alltraps>

80108098 <vector172>:
.globl vector172
vector172:
  pushl $0
80108098:	6a 00                	push   $0x0
  pushl $172
8010809a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010809f:	e9 e2 f0 ff ff       	jmp    80107186 <alltraps>

801080a4 <vector173>:
.globl vector173
vector173:
  pushl $0
801080a4:	6a 00                	push   $0x0
  pushl $173
801080a6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801080ab:	e9 d6 f0 ff ff       	jmp    80107186 <alltraps>

801080b0 <vector174>:
.globl vector174
vector174:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $174
801080b2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801080b7:	e9 ca f0 ff ff       	jmp    80107186 <alltraps>

801080bc <vector175>:
.globl vector175
vector175:
  pushl $0
801080bc:	6a 00                	push   $0x0
  pushl $175
801080be:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801080c3:	e9 be f0 ff ff       	jmp    80107186 <alltraps>

801080c8 <vector176>:
.globl vector176
vector176:
  pushl $0
801080c8:	6a 00                	push   $0x0
  pushl $176
801080ca:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801080cf:	e9 b2 f0 ff ff       	jmp    80107186 <alltraps>

801080d4 <vector177>:
.globl vector177
vector177:
  pushl $0
801080d4:	6a 00                	push   $0x0
  pushl $177
801080d6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801080db:	e9 a6 f0 ff ff       	jmp    80107186 <alltraps>

801080e0 <vector178>:
.globl vector178
vector178:
  pushl $0
801080e0:	6a 00                	push   $0x0
  pushl $178
801080e2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801080e7:	e9 9a f0 ff ff       	jmp    80107186 <alltraps>

801080ec <vector179>:
.globl vector179
vector179:
  pushl $0
801080ec:	6a 00                	push   $0x0
  pushl $179
801080ee:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801080f3:	e9 8e f0 ff ff       	jmp    80107186 <alltraps>

801080f8 <vector180>:
.globl vector180
vector180:
  pushl $0
801080f8:	6a 00                	push   $0x0
  pushl $180
801080fa:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801080ff:	e9 82 f0 ff ff       	jmp    80107186 <alltraps>

80108104 <vector181>:
.globl vector181
vector181:
  pushl $0
80108104:	6a 00                	push   $0x0
  pushl $181
80108106:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010810b:	e9 76 f0 ff ff       	jmp    80107186 <alltraps>

80108110 <vector182>:
.globl vector182
vector182:
  pushl $0
80108110:	6a 00                	push   $0x0
  pushl $182
80108112:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108117:	e9 6a f0 ff ff       	jmp    80107186 <alltraps>

8010811c <vector183>:
.globl vector183
vector183:
  pushl $0
8010811c:	6a 00                	push   $0x0
  pushl $183
8010811e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108123:	e9 5e f0 ff ff       	jmp    80107186 <alltraps>

80108128 <vector184>:
.globl vector184
vector184:
  pushl $0
80108128:	6a 00                	push   $0x0
  pushl $184
8010812a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010812f:	e9 52 f0 ff ff       	jmp    80107186 <alltraps>

80108134 <vector185>:
.globl vector185
vector185:
  pushl $0
80108134:	6a 00                	push   $0x0
  pushl $185
80108136:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010813b:	e9 46 f0 ff ff       	jmp    80107186 <alltraps>

80108140 <vector186>:
.globl vector186
vector186:
  pushl $0
80108140:	6a 00                	push   $0x0
  pushl $186
80108142:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108147:	e9 3a f0 ff ff       	jmp    80107186 <alltraps>

8010814c <vector187>:
.globl vector187
vector187:
  pushl $0
8010814c:	6a 00                	push   $0x0
  pushl $187
8010814e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108153:	e9 2e f0 ff ff       	jmp    80107186 <alltraps>

80108158 <vector188>:
.globl vector188
vector188:
  pushl $0
80108158:	6a 00                	push   $0x0
  pushl $188
8010815a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010815f:	e9 22 f0 ff ff       	jmp    80107186 <alltraps>

80108164 <vector189>:
.globl vector189
vector189:
  pushl $0
80108164:	6a 00                	push   $0x0
  pushl $189
80108166:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010816b:	e9 16 f0 ff ff       	jmp    80107186 <alltraps>

80108170 <vector190>:
.globl vector190
vector190:
  pushl $0
80108170:	6a 00                	push   $0x0
  pushl $190
80108172:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108177:	e9 0a f0 ff ff       	jmp    80107186 <alltraps>

8010817c <vector191>:
.globl vector191
vector191:
  pushl $0
8010817c:	6a 00                	push   $0x0
  pushl $191
8010817e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108183:	e9 fe ef ff ff       	jmp    80107186 <alltraps>

80108188 <vector192>:
.globl vector192
vector192:
  pushl $0
80108188:	6a 00                	push   $0x0
  pushl $192
8010818a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010818f:	e9 f2 ef ff ff       	jmp    80107186 <alltraps>

80108194 <vector193>:
.globl vector193
vector193:
  pushl $0
80108194:	6a 00                	push   $0x0
  pushl $193
80108196:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010819b:	e9 e6 ef ff ff       	jmp    80107186 <alltraps>

801081a0 <vector194>:
.globl vector194
vector194:
  pushl $0
801081a0:	6a 00                	push   $0x0
  pushl $194
801081a2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801081a7:	e9 da ef ff ff       	jmp    80107186 <alltraps>

801081ac <vector195>:
.globl vector195
vector195:
  pushl $0
801081ac:	6a 00                	push   $0x0
  pushl $195
801081ae:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801081b3:	e9 ce ef ff ff       	jmp    80107186 <alltraps>

801081b8 <vector196>:
.globl vector196
vector196:
  pushl $0
801081b8:	6a 00                	push   $0x0
  pushl $196
801081ba:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801081bf:	e9 c2 ef ff ff       	jmp    80107186 <alltraps>

801081c4 <vector197>:
.globl vector197
vector197:
  pushl $0
801081c4:	6a 00                	push   $0x0
  pushl $197
801081c6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801081cb:	e9 b6 ef ff ff       	jmp    80107186 <alltraps>

801081d0 <vector198>:
.globl vector198
vector198:
  pushl $0
801081d0:	6a 00                	push   $0x0
  pushl $198
801081d2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801081d7:	e9 aa ef ff ff       	jmp    80107186 <alltraps>

801081dc <vector199>:
.globl vector199
vector199:
  pushl $0
801081dc:	6a 00                	push   $0x0
  pushl $199
801081de:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801081e3:	e9 9e ef ff ff       	jmp    80107186 <alltraps>

801081e8 <vector200>:
.globl vector200
vector200:
  pushl $0
801081e8:	6a 00                	push   $0x0
  pushl $200
801081ea:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801081ef:	e9 92 ef ff ff       	jmp    80107186 <alltraps>

801081f4 <vector201>:
.globl vector201
vector201:
  pushl $0
801081f4:	6a 00                	push   $0x0
  pushl $201
801081f6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801081fb:	e9 86 ef ff ff       	jmp    80107186 <alltraps>

80108200 <vector202>:
.globl vector202
vector202:
  pushl $0
80108200:	6a 00                	push   $0x0
  pushl $202
80108202:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108207:	e9 7a ef ff ff       	jmp    80107186 <alltraps>

8010820c <vector203>:
.globl vector203
vector203:
  pushl $0
8010820c:	6a 00                	push   $0x0
  pushl $203
8010820e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108213:	e9 6e ef ff ff       	jmp    80107186 <alltraps>

80108218 <vector204>:
.globl vector204
vector204:
  pushl $0
80108218:	6a 00                	push   $0x0
  pushl $204
8010821a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010821f:	e9 62 ef ff ff       	jmp    80107186 <alltraps>

80108224 <vector205>:
.globl vector205
vector205:
  pushl $0
80108224:	6a 00                	push   $0x0
  pushl $205
80108226:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010822b:	e9 56 ef ff ff       	jmp    80107186 <alltraps>

80108230 <vector206>:
.globl vector206
vector206:
  pushl $0
80108230:	6a 00                	push   $0x0
  pushl $206
80108232:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108237:	e9 4a ef ff ff       	jmp    80107186 <alltraps>

8010823c <vector207>:
.globl vector207
vector207:
  pushl $0
8010823c:	6a 00                	push   $0x0
  pushl $207
8010823e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108243:	e9 3e ef ff ff       	jmp    80107186 <alltraps>

80108248 <vector208>:
.globl vector208
vector208:
  pushl $0
80108248:	6a 00                	push   $0x0
  pushl $208
8010824a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010824f:	e9 32 ef ff ff       	jmp    80107186 <alltraps>

80108254 <vector209>:
.globl vector209
vector209:
  pushl $0
80108254:	6a 00                	push   $0x0
  pushl $209
80108256:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010825b:	e9 26 ef ff ff       	jmp    80107186 <alltraps>

80108260 <vector210>:
.globl vector210
vector210:
  pushl $0
80108260:	6a 00                	push   $0x0
  pushl $210
80108262:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108267:	e9 1a ef ff ff       	jmp    80107186 <alltraps>

8010826c <vector211>:
.globl vector211
vector211:
  pushl $0
8010826c:	6a 00                	push   $0x0
  pushl $211
8010826e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108273:	e9 0e ef ff ff       	jmp    80107186 <alltraps>

80108278 <vector212>:
.globl vector212
vector212:
  pushl $0
80108278:	6a 00                	push   $0x0
  pushl $212
8010827a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010827f:	e9 02 ef ff ff       	jmp    80107186 <alltraps>

80108284 <vector213>:
.globl vector213
vector213:
  pushl $0
80108284:	6a 00                	push   $0x0
  pushl $213
80108286:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010828b:	e9 f6 ee ff ff       	jmp    80107186 <alltraps>

80108290 <vector214>:
.globl vector214
vector214:
  pushl $0
80108290:	6a 00                	push   $0x0
  pushl $214
80108292:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108297:	e9 ea ee ff ff       	jmp    80107186 <alltraps>

8010829c <vector215>:
.globl vector215
vector215:
  pushl $0
8010829c:	6a 00                	push   $0x0
  pushl $215
8010829e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801082a3:	e9 de ee ff ff       	jmp    80107186 <alltraps>

801082a8 <vector216>:
.globl vector216
vector216:
  pushl $0
801082a8:	6a 00                	push   $0x0
  pushl $216
801082aa:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801082af:	e9 d2 ee ff ff       	jmp    80107186 <alltraps>

801082b4 <vector217>:
.globl vector217
vector217:
  pushl $0
801082b4:	6a 00                	push   $0x0
  pushl $217
801082b6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801082bb:	e9 c6 ee ff ff       	jmp    80107186 <alltraps>

801082c0 <vector218>:
.globl vector218
vector218:
  pushl $0
801082c0:	6a 00                	push   $0x0
  pushl $218
801082c2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801082c7:	e9 ba ee ff ff       	jmp    80107186 <alltraps>

801082cc <vector219>:
.globl vector219
vector219:
  pushl $0
801082cc:	6a 00                	push   $0x0
  pushl $219
801082ce:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801082d3:	e9 ae ee ff ff       	jmp    80107186 <alltraps>

801082d8 <vector220>:
.globl vector220
vector220:
  pushl $0
801082d8:	6a 00                	push   $0x0
  pushl $220
801082da:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801082df:	e9 a2 ee ff ff       	jmp    80107186 <alltraps>

801082e4 <vector221>:
.globl vector221
vector221:
  pushl $0
801082e4:	6a 00                	push   $0x0
  pushl $221
801082e6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801082eb:	e9 96 ee ff ff       	jmp    80107186 <alltraps>

801082f0 <vector222>:
.globl vector222
vector222:
  pushl $0
801082f0:	6a 00                	push   $0x0
  pushl $222
801082f2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801082f7:	e9 8a ee ff ff       	jmp    80107186 <alltraps>

801082fc <vector223>:
.globl vector223
vector223:
  pushl $0
801082fc:	6a 00                	push   $0x0
  pushl $223
801082fe:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108303:	e9 7e ee ff ff       	jmp    80107186 <alltraps>

80108308 <vector224>:
.globl vector224
vector224:
  pushl $0
80108308:	6a 00                	push   $0x0
  pushl $224
8010830a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010830f:	e9 72 ee ff ff       	jmp    80107186 <alltraps>

80108314 <vector225>:
.globl vector225
vector225:
  pushl $0
80108314:	6a 00                	push   $0x0
  pushl $225
80108316:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010831b:	e9 66 ee ff ff       	jmp    80107186 <alltraps>

80108320 <vector226>:
.globl vector226
vector226:
  pushl $0
80108320:	6a 00                	push   $0x0
  pushl $226
80108322:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108327:	e9 5a ee ff ff       	jmp    80107186 <alltraps>

8010832c <vector227>:
.globl vector227
vector227:
  pushl $0
8010832c:	6a 00                	push   $0x0
  pushl $227
8010832e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108333:	e9 4e ee ff ff       	jmp    80107186 <alltraps>

80108338 <vector228>:
.globl vector228
vector228:
  pushl $0
80108338:	6a 00                	push   $0x0
  pushl $228
8010833a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010833f:	e9 42 ee ff ff       	jmp    80107186 <alltraps>

80108344 <vector229>:
.globl vector229
vector229:
  pushl $0
80108344:	6a 00                	push   $0x0
  pushl $229
80108346:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010834b:	e9 36 ee ff ff       	jmp    80107186 <alltraps>

80108350 <vector230>:
.globl vector230
vector230:
  pushl $0
80108350:	6a 00                	push   $0x0
  pushl $230
80108352:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108357:	e9 2a ee ff ff       	jmp    80107186 <alltraps>

8010835c <vector231>:
.globl vector231
vector231:
  pushl $0
8010835c:	6a 00                	push   $0x0
  pushl $231
8010835e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108363:	e9 1e ee ff ff       	jmp    80107186 <alltraps>

80108368 <vector232>:
.globl vector232
vector232:
  pushl $0
80108368:	6a 00                	push   $0x0
  pushl $232
8010836a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010836f:	e9 12 ee ff ff       	jmp    80107186 <alltraps>

80108374 <vector233>:
.globl vector233
vector233:
  pushl $0
80108374:	6a 00                	push   $0x0
  pushl $233
80108376:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010837b:	e9 06 ee ff ff       	jmp    80107186 <alltraps>

80108380 <vector234>:
.globl vector234
vector234:
  pushl $0
80108380:	6a 00                	push   $0x0
  pushl $234
80108382:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108387:	e9 fa ed ff ff       	jmp    80107186 <alltraps>

8010838c <vector235>:
.globl vector235
vector235:
  pushl $0
8010838c:	6a 00                	push   $0x0
  pushl $235
8010838e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108393:	e9 ee ed ff ff       	jmp    80107186 <alltraps>

80108398 <vector236>:
.globl vector236
vector236:
  pushl $0
80108398:	6a 00                	push   $0x0
  pushl $236
8010839a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010839f:	e9 e2 ed ff ff       	jmp    80107186 <alltraps>

801083a4 <vector237>:
.globl vector237
vector237:
  pushl $0
801083a4:	6a 00                	push   $0x0
  pushl $237
801083a6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801083ab:	e9 d6 ed ff ff       	jmp    80107186 <alltraps>

801083b0 <vector238>:
.globl vector238
vector238:
  pushl $0
801083b0:	6a 00                	push   $0x0
  pushl $238
801083b2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801083b7:	e9 ca ed ff ff       	jmp    80107186 <alltraps>

801083bc <vector239>:
.globl vector239
vector239:
  pushl $0
801083bc:	6a 00                	push   $0x0
  pushl $239
801083be:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801083c3:	e9 be ed ff ff       	jmp    80107186 <alltraps>

801083c8 <vector240>:
.globl vector240
vector240:
  pushl $0
801083c8:	6a 00                	push   $0x0
  pushl $240
801083ca:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801083cf:	e9 b2 ed ff ff       	jmp    80107186 <alltraps>

801083d4 <vector241>:
.globl vector241
vector241:
  pushl $0
801083d4:	6a 00                	push   $0x0
  pushl $241
801083d6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801083db:	e9 a6 ed ff ff       	jmp    80107186 <alltraps>

801083e0 <vector242>:
.globl vector242
vector242:
  pushl $0
801083e0:	6a 00                	push   $0x0
  pushl $242
801083e2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801083e7:	e9 9a ed ff ff       	jmp    80107186 <alltraps>

801083ec <vector243>:
.globl vector243
vector243:
  pushl $0
801083ec:	6a 00                	push   $0x0
  pushl $243
801083ee:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801083f3:	e9 8e ed ff ff       	jmp    80107186 <alltraps>

801083f8 <vector244>:
.globl vector244
vector244:
  pushl $0
801083f8:	6a 00                	push   $0x0
  pushl $244
801083fa:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801083ff:	e9 82 ed ff ff       	jmp    80107186 <alltraps>

80108404 <vector245>:
.globl vector245
vector245:
  pushl $0
80108404:	6a 00                	push   $0x0
  pushl $245
80108406:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010840b:	e9 76 ed ff ff       	jmp    80107186 <alltraps>

80108410 <vector246>:
.globl vector246
vector246:
  pushl $0
80108410:	6a 00                	push   $0x0
  pushl $246
80108412:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108417:	e9 6a ed ff ff       	jmp    80107186 <alltraps>

8010841c <vector247>:
.globl vector247
vector247:
  pushl $0
8010841c:	6a 00                	push   $0x0
  pushl $247
8010841e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108423:	e9 5e ed ff ff       	jmp    80107186 <alltraps>

80108428 <vector248>:
.globl vector248
vector248:
  pushl $0
80108428:	6a 00                	push   $0x0
  pushl $248
8010842a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010842f:	e9 52 ed ff ff       	jmp    80107186 <alltraps>

80108434 <vector249>:
.globl vector249
vector249:
  pushl $0
80108434:	6a 00                	push   $0x0
  pushl $249
80108436:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010843b:	e9 46 ed ff ff       	jmp    80107186 <alltraps>

80108440 <vector250>:
.globl vector250
vector250:
  pushl $0
80108440:	6a 00                	push   $0x0
  pushl $250
80108442:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108447:	e9 3a ed ff ff       	jmp    80107186 <alltraps>

8010844c <vector251>:
.globl vector251
vector251:
  pushl $0
8010844c:	6a 00                	push   $0x0
  pushl $251
8010844e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108453:	e9 2e ed ff ff       	jmp    80107186 <alltraps>

80108458 <vector252>:
.globl vector252
vector252:
  pushl $0
80108458:	6a 00                	push   $0x0
  pushl $252
8010845a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010845f:	e9 22 ed ff ff       	jmp    80107186 <alltraps>

80108464 <vector253>:
.globl vector253
vector253:
  pushl $0
80108464:	6a 00                	push   $0x0
  pushl $253
80108466:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010846b:	e9 16 ed ff ff       	jmp    80107186 <alltraps>

80108470 <vector254>:
.globl vector254
vector254:
  pushl $0
80108470:	6a 00                	push   $0x0
  pushl $254
80108472:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108477:	e9 0a ed ff ff       	jmp    80107186 <alltraps>

8010847c <vector255>:
.globl vector255
vector255:
  pushl $0
8010847c:	6a 00                	push   $0x0
  pushl $255
8010847e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108483:	e9 fe ec ff ff       	jmp    80107186 <alltraps>

80108488 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108488:	55                   	push   %ebp
80108489:	89 e5                	mov    %esp,%ebp
8010848b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010848e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108491:	83 e8 01             	sub    $0x1,%eax
80108494:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108498:	8b 45 08             	mov    0x8(%ebp),%eax
8010849b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010849f:	8b 45 08             	mov    0x8(%ebp),%eax
801084a2:	c1 e8 10             	shr    $0x10,%eax
801084a5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801084a9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801084ac:	0f 01 10             	lgdtl  (%eax)
}
801084af:	90                   	nop
801084b0:	c9                   	leave  
801084b1:	c3                   	ret    

801084b2 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801084b2:	55                   	push   %ebp
801084b3:	89 e5                	mov    %esp,%ebp
801084b5:	83 ec 04             	sub    $0x4,%esp
801084b8:	8b 45 08             	mov    0x8(%ebp),%eax
801084bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801084bf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801084c3:	0f 00 d8             	ltr    %ax
}
801084c6:	90                   	nop
801084c7:	c9                   	leave  
801084c8:	c3                   	ret    

801084c9 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801084c9:	55                   	push   %ebp
801084ca:	89 e5                	mov    %esp,%ebp
801084cc:	83 ec 04             	sub    $0x4,%esp
801084cf:	8b 45 08             	mov    0x8(%ebp),%eax
801084d2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801084d6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801084da:	8e e8                	mov    %eax,%gs
}
801084dc:	90                   	nop
801084dd:	c9                   	leave  
801084de:	c3                   	ret    

801084df <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801084df:	55                   	push   %ebp
801084e0:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801084e2:	8b 45 08             	mov    0x8(%ebp),%eax
801084e5:	0f 22 d8             	mov    %eax,%cr3
}
801084e8:	90                   	nop
801084e9:	5d                   	pop    %ebp
801084ea:	c3                   	ret    

801084eb <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801084eb:	55                   	push   %ebp
801084ec:	89 e5                	mov    %esp,%ebp
801084ee:	8b 45 08             	mov    0x8(%ebp),%eax
801084f1:	05 00 00 00 80       	add    $0x80000000,%eax
801084f6:	5d                   	pop    %ebp
801084f7:	c3                   	ret    

801084f8 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801084f8:	55                   	push   %ebp
801084f9:	89 e5                	mov    %esp,%ebp
801084fb:	8b 45 08             	mov    0x8(%ebp),%eax
801084fe:	05 00 00 00 80       	add    $0x80000000,%eax
80108503:	5d                   	pop    %ebp
80108504:	c3                   	ret    

80108505 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108505:	55                   	push   %ebp
80108506:	89 e5                	mov    %esp,%ebp
80108508:	53                   	push   %ebx
80108509:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010850c:	e8 7d aa ff ff       	call   80102f8e <cpunum>
80108511:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108517:	05 80 33 11 80       	add    $0x80113380,%eax
8010851c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010851f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108522:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108534:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010853f:	83 e2 f0             	and    $0xfffffff0,%edx
80108542:	83 ca 0a             	or     $0xa,%edx
80108545:	88 50 7d             	mov    %dl,0x7d(%eax)
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010854f:	83 ca 10             	or     $0x10,%edx
80108552:	88 50 7d             	mov    %dl,0x7d(%eax)
80108555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108558:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010855c:	83 e2 9f             	and    $0xffffff9f,%edx
8010855f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108565:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108569:	83 ca 80             	or     $0xffffff80,%edx
8010856c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010856f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108572:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108576:	83 ca 0f             	or     $0xf,%edx
80108579:	88 50 7e             	mov    %dl,0x7e(%eax)
8010857c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108583:	83 e2 ef             	and    $0xffffffef,%edx
80108586:	88 50 7e             	mov    %dl,0x7e(%eax)
80108589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108590:	83 e2 df             	and    $0xffffffdf,%edx
80108593:	88 50 7e             	mov    %dl,0x7e(%eax)
80108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108599:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010859d:	83 ca 40             	or     $0x40,%edx
801085a0:	88 50 7e             	mov    %dl,0x7e(%eax)
801085a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085aa:	83 ca 80             	or     $0xffffff80,%edx
801085ad:	88 50 7e             	mov    %dl,0x7e(%eax)
801085b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801085b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ba:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801085c1:	ff ff 
801085c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801085cd:	00 00 
801085cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801085d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085dc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085e3:	83 e2 f0             	and    $0xfffffff0,%edx
801085e6:	83 ca 02             	or     $0x2,%edx
801085e9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801085f9:	83 ca 10             	or     $0x10,%edx
801085fc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108605:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010860c:	83 e2 9f             	and    $0xffffff9f,%edx
8010860f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108618:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010861f:	83 ca 80             	or     $0xffffff80,%edx
80108622:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108632:	83 ca 0f             	or     $0xf,%edx
80108635:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010863b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108645:	83 e2 ef             	and    $0xffffffef,%edx
80108648:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010864e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108651:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108658:	83 e2 df             	and    $0xffffffdf,%edx
8010865b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108664:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010866b:	83 ca 40             	or     $0x40,%edx
8010866e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010867e:	83 ca 80             	or     $0xffffff80,%edx
80108681:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108694:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010869b:	ff ff 
8010869d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801086a7:	00 00 
801086a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ac:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801086b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086bd:	83 e2 f0             	and    $0xfffffff0,%edx
801086c0:	83 ca 0a             	or     $0xa,%edx
801086c3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086d3:	83 ca 10             	or     $0x10,%edx
801086d6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086df:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086e6:	83 ca 60             	or     $0x60,%edx
801086e9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801086f9:	83 ca 80             	or     $0xffffff80,%edx
801086fc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010870c:	83 ca 0f             	or     $0xf,%edx
8010870f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010871f:	83 e2 ef             	and    $0xffffffef,%edx
80108722:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108732:	83 e2 df             	and    $0xffffffdf,%edx
80108735:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108745:	83 ca 40             	or     $0x40,%edx
80108748:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108758:	83 ca 80             	or     $0xffffff80,%edx
8010875b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108764:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010876b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108775:	ff ff 
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108781:	00 00 
80108783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108786:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010878d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108790:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108797:	83 e2 f0             	and    $0xfffffff0,%edx
8010879a:	83 ca 02             	or     $0x2,%edx
8010879d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801087ad:	83 ca 10             	or     $0x10,%edx
801087b0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801087c0:	83 ca 60             	or     $0x60,%edx
801087c3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801087d3:	83 ca 80             	or     $0xffffff80,%edx
801087d6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801087dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087df:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087e6:	83 ca 0f             	or     $0xf,%edx
801087e9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801087ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801087f9:	83 e2 ef             	and    $0xffffffef,%edx
801087fc:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108805:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010880c:	83 e2 df             	and    $0xffffffdf,%edx
8010880f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108818:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010881f:	83 ca 40             	or     $0x40,%edx
80108822:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108832:	83 ca 80             	or     $0xffffff80,%edx
80108835:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010883b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108848:	05 b4 00 00 00       	add    $0xb4,%eax
8010884d:	89 c3                	mov    %eax,%ebx
8010884f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108852:	05 b4 00 00 00       	add    $0xb4,%eax
80108857:	c1 e8 10             	shr    $0x10,%eax
8010885a:	89 c2                	mov    %eax,%edx
8010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885f:	05 b4 00 00 00       	add    $0xb4,%eax
80108864:	c1 e8 18             	shr    $0x18,%eax
80108867:	89 c1                	mov    %eax,%ecx
80108869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108873:	00 00 
80108875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108878:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010887f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108882:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108892:	83 e2 f0             	and    $0xfffffff0,%edx
80108895:	83 ca 02             	or     $0x2,%edx
80108898:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010889e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088a8:	83 ca 10             	or     $0x10,%edx
801088ab:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088bb:	83 e2 9f             	and    $0xffffff9f,%edx
801088be:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088ce:	83 ca 80             	or     $0xffffff80,%edx
801088d1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801088d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088da:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088e1:	83 e2 f0             	and    $0xfffffff0,%edx
801088e4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ed:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801088f4:	83 e2 ef             	and    $0xffffffef,%edx
801088f7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801088fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108900:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108907:	83 e2 df             	and    $0xffffffdf,%edx
8010890a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108913:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010891a:	83 ca 40             	or     $0x40,%edx
8010891d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108926:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010892d:	83 ca 80             	or     $0xffffff80,%edx
80108930:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108939:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010893f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108942:	83 c0 70             	add    $0x70,%eax
80108945:	83 ec 08             	sub    $0x8,%esp
80108948:	6a 38                	push   $0x38
8010894a:	50                   	push   %eax
8010894b:	e8 38 fb ff ff       	call   80108488 <lgdt>
80108950:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108953:	83 ec 0c             	sub    $0xc,%esp
80108956:	6a 18                	push   $0x18
80108958:	e8 6c fb ff ff       	call   801084c9 <loadgs>
8010895d:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
80108960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108963:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108969:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108970:	00 00 00 00 
}
80108974:	90                   	nop
80108975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108978:	c9                   	leave  
80108979:	c3                   	ret    

8010897a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010897a:	55                   	push   %ebp
8010897b:	89 e5                	mov    %esp,%ebp
8010897d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108980:	8b 45 0c             	mov    0xc(%ebp),%eax
80108983:	c1 e8 16             	shr    $0x16,%eax
80108986:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010898d:	8b 45 08             	mov    0x8(%ebp),%eax
80108990:	01 d0                	add    %edx,%eax
80108992:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108995:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108998:	8b 00                	mov    (%eax),%eax
8010899a:	83 e0 01             	and    $0x1,%eax
8010899d:	85 c0                	test   %eax,%eax
8010899f:	74 18                	je     801089b9 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801089a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a4:	8b 00                	mov    (%eax),%eax
801089a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089ab:	50                   	push   %eax
801089ac:	e8 47 fb ff ff       	call   801084f8 <p2v>
801089b1:	83 c4 04             	add    $0x4,%esp
801089b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089b7:	eb 48                	jmp    80108a01 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801089b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801089bd:	74 0e                	je     801089cd <walkpgdir+0x53>
801089bf:	e8 64 a2 ff ff       	call   80102c28 <kalloc>
801089c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089cb:	75 07                	jne    801089d4 <walkpgdir+0x5a>
      return 0;
801089cd:	b8 00 00 00 00       	mov    $0x0,%eax
801089d2:	eb 44                	jmp    80108a18 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801089d4:	83 ec 04             	sub    $0x4,%esp
801089d7:	68 00 10 00 00       	push   $0x1000
801089dc:	6a 00                	push   $0x0
801089de:	ff 75 f4             	pushl  -0xc(%ebp)
801089e1:	e8 eb d1 ff ff       	call   80105bd1 <memset>
801089e6:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801089e9:	83 ec 0c             	sub    $0xc,%esp
801089ec:	ff 75 f4             	pushl  -0xc(%ebp)
801089ef:	e8 f7 fa ff ff       	call   801084eb <v2p>
801089f4:	83 c4 10             	add    $0x10,%esp
801089f7:	83 c8 07             	or     $0x7,%eax
801089fa:	89 c2                	mov    %eax,%edx
801089fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ff:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108a01:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a04:	c1 e8 0c             	shr    $0xc,%eax
80108a07:	25 ff 03 00 00       	and    $0x3ff,%eax
80108a0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a16:	01 d0                	add    %edx,%eax
}
80108a18:	c9                   	leave  
80108a19:	c3                   	ret    

80108a1a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108a1a:	55                   	push   %ebp
80108a1b:	89 e5                	mov    %esp,%ebp
80108a1d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108a20:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a2e:	8b 45 10             	mov    0x10(%ebp),%eax
80108a31:	01 d0                	add    %edx,%eax
80108a33:	83 e8 01             	sub    $0x1,%eax
80108a36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108a3e:	83 ec 04             	sub    $0x4,%esp
80108a41:	6a 01                	push   $0x1
80108a43:	ff 75 f4             	pushl  -0xc(%ebp)
80108a46:	ff 75 08             	pushl  0x8(%ebp)
80108a49:	e8 2c ff ff ff       	call   8010897a <walkpgdir>
80108a4e:	83 c4 10             	add    $0x10,%esp
80108a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a54:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a58:	75 07                	jne    80108a61 <mappages+0x47>
      return -1;
80108a5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a5f:	eb 47                	jmp    80108aa8 <mappages+0x8e>
    if(*pte & PTE_P)
80108a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a64:	8b 00                	mov    (%eax),%eax
80108a66:	83 e0 01             	and    $0x1,%eax
80108a69:	85 c0                	test   %eax,%eax
80108a6b:	74 0d                	je     80108a7a <mappages+0x60>
      panic("remap");
80108a6d:	83 ec 0c             	sub    $0xc,%esp
80108a70:	68 00 9a 10 80       	push   $0x80109a00
80108a75:	e8 ec 7a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108a7a:	8b 45 18             	mov    0x18(%ebp),%eax
80108a7d:	0b 45 14             	or     0x14(%ebp),%eax
80108a80:	83 c8 01             	or     $0x1,%eax
80108a83:	89 c2                	mov    %eax,%edx
80108a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a88:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a90:	74 10                	je     80108aa2 <mappages+0x88>
      break;
    a += PGSIZE;
80108a92:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108a99:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108aa0:	eb 9c                	jmp    80108a3e <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108aa2:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108aa8:	c9                   	leave  
80108aa9:	c3                   	ret    

80108aaa <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108aaa:	55                   	push   %ebp
80108aab:	89 e5                	mov    %esp,%ebp
80108aad:	53                   	push   %ebx
80108aae:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108ab1:	e8 72 a1 ff ff       	call   80102c28 <kalloc>
80108ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ab9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108abd:	75 0a                	jne    80108ac9 <setupkvm+0x1f>
    return 0;
80108abf:	b8 00 00 00 00       	mov    $0x0,%eax
80108ac4:	e9 8e 00 00 00       	jmp    80108b57 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108ac9:	83 ec 04             	sub    $0x4,%esp
80108acc:	68 00 10 00 00       	push   $0x1000
80108ad1:	6a 00                	push   $0x0
80108ad3:	ff 75 f0             	pushl  -0x10(%ebp)
80108ad6:	e8 f6 d0 ff ff       	call   80105bd1 <memset>
80108adb:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108ade:	83 ec 0c             	sub    $0xc,%esp
80108ae1:	68 00 00 00 0e       	push   $0xe000000
80108ae6:	e8 0d fa ff ff       	call   801084f8 <p2v>
80108aeb:	83 c4 10             	add    $0x10,%esp
80108aee:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108af3:	76 0d                	jbe    80108b02 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108af5:	83 ec 0c             	sub    $0xc,%esp
80108af8:	68 06 9a 10 80       	push   $0x80109a06
80108afd:	e8 64 7a ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b02:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108b09:	eb 40                	jmp    80108b4b <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b14:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1a:	8b 58 08             	mov    0x8(%eax),%ebx
80108b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b20:	8b 40 04             	mov    0x4(%eax),%eax
80108b23:	29 c3                	sub    %eax,%ebx
80108b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b28:	8b 00                	mov    (%eax),%eax
80108b2a:	83 ec 0c             	sub    $0xc,%esp
80108b2d:	51                   	push   %ecx
80108b2e:	52                   	push   %edx
80108b2f:	53                   	push   %ebx
80108b30:	50                   	push   %eax
80108b31:	ff 75 f0             	pushl  -0x10(%ebp)
80108b34:	e8 e1 fe ff ff       	call   80108a1a <mappages>
80108b39:	83 c4 20             	add    $0x20,%esp
80108b3c:	85 c0                	test   %eax,%eax
80108b3e:	79 07                	jns    80108b47 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108b40:	b8 00 00 00 00       	mov    $0x0,%eax
80108b45:	eb 10                	jmp    80108b57 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b47:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108b4b:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108b52:	72 b7                	jb     80108b0b <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108b57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b5a:	c9                   	leave  
80108b5b:	c3                   	ret    

80108b5c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108b5c:	55                   	push   %ebp
80108b5d:	89 e5                	mov    %esp,%ebp
80108b5f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108b62:	e8 43 ff ff ff       	call   80108aaa <setupkvm>
80108b67:	a3 b8 81 11 80       	mov    %eax,0x801181b8
  switchkvm();
80108b6c:	e8 03 00 00 00       	call   80108b74 <switchkvm>
}
80108b71:	90                   	nop
80108b72:	c9                   	leave  
80108b73:	c3                   	ret    

80108b74 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108b74:	55                   	push   %ebp
80108b75:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108b77:	a1 b8 81 11 80       	mov    0x801181b8,%eax
80108b7c:	50                   	push   %eax
80108b7d:	e8 69 f9 ff ff       	call   801084eb <v2p>
80108b82:	83 c4 04             	add    $0x4,%esp
80108b85:	50                   	push   %eax
80108b86:	e8 54 f9 ff ff       	call   801084df <lcr3>
80108b8b:	83 c4 04             	add    $0x4,%esp
}
80108b8e:	90                   	nop
80108b8f:	c9                   	leave  
80108b90:	c3                   	ret    

80108b91 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108b91:	55                   	push   %ebp
80108b92:	89 e5                	mov    %esp,%ebp
80108b94:	56                   	push   %esi
80108b95:	53                   	push   %ebx
  pushcli();
80108b96:	e8 30 cf ff ff       	call   80105acb <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108b9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ba1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ba8:	83 c2 08             	add    $0x8,%edx
80108bab:	89 d6                	mov    %edx,%esi
80108bad:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108bb4:	83 c2 08             	add    $0x8,%edx
80108bb7:	c1 ea 10             	shr    $0x10,%edx
80108bba:	89 d3                	mov    %edx,%ebx
80108bbc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108bc3:	83 c2 08             	add    $0x8,%edx
80108bc6:	c1 ea 18             	shr    $0x18,%edx
80108bc9:	89 d1                	mov    %edx,%ecx
80108bcb:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108bd2:	67 00 
80108bd4:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108bdb:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108be1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108be8:	83 e2 f0             	and    $0xfffffff0,%edx
80108beb:	83 ca 09             	or     $0x9,%edx
80108bee:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108bf4:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108bfb:	83 ca 10             	or     $0x10,%edx
80108bfe:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c04:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c0b:	83 e2 9f             	and    $0xffffff9f,%edx
80108c0e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c14:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c1b:	83 ca 80             	or     $0xffffff80,%edx
80108c1e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c24:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c2b:	83 e2 f0             	and    $0xfffffff0,%edx
80108c2e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c34:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c3b:	83 e2 ef             	and    $0xffffffef,%edx
80108c3e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c44:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c4b:	83 e2 df             	and    $0xffffffdf,%edx
80108c4e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c54:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c5b:	83 ca 40             	or     $0x40,%edx
80108c5e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c64:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c6b:	83 e2 7f             	and    $0x7f,%edx
80108c6e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c74:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108c7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c80:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c87:	83 e2 ef             	and    $0xffffffef,%edx
80108c8a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108c90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c96:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108c9c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ca2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108ca9:	8b 52 08             	mov    0x8(%edx),%edx
80108cac:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108cb2:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108cb5:	83 ec 0c             	sub    $0xc,%esp
80108cb8:	6a 30                	push   $0x30
80108cba:	e8 f3 f7 ff ff       	call   801084b2 <ltr>
80108cbf:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc5:	8b 40 04             	mov    0x4(%eax),%eax
80108cc8:	85 c0                	test   %eax,%eax
80108cca:	75 0d                	jne    80108cd9 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108ccc:	83 ec 0c             	sub    $0xc,%esp
80108ccf:	68 17 9a 10 80       	push   $0x80109a17
80108cd4:	e8 8d 78 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80108cdc:	8b 40 04             	mov    0x4(%eax),%eax
80108cdf:	83 ec 0c             	sub    $0xc,%esp
80108ce2:	50                   	push   %eax
80108ce3:	e8 03 f8 ff ff       	call   801084eb <v2p>
80108ce8:	83 c4 10             	add    $0x10,%esp
80108ceb:	83 ec 0c             	sub    $0xc,%esp
80108cee:	50                   	push   %eax
80108cef:	e8 eb f7 ff ff       	call   801084df <lcr3>
80108cf4:	83 c4 10             	add    $0x10,%esp
  popcli();
80108cf7:	e8 14 ce ff ff       	call   80105b10 <popcli>
}
80108cfc:	90                   	nop
80108cfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108d00:	5b                   	pop    %ebx
80108d01:	5e                   	pop    %esi
80108d02:	5d                   	pop    %ebp
80108d03:	c3                   	ret    

80108d04 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d04:	55                   	push   %ebp
80108d05:	89 e5                	mov    %esp,%ebp
80108d07:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108d0a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108d11:	76 0d                	jbe    80108d20 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108d13:	83 ec 0c             	sub    $0xc,%esp
80108d16:	68 2b 9a 10 80       	push   $0x80109a2b
80108d1b:	e8 46 78 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108d20:	e8 03 9f ff ff       	call   80102c28 <kalloc>
80108d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108d28:	83 ec 04             	sub    $0x4,%esp
80108d2b:	68 00 10 00 00       	push   $0x1000
80108d30:	6a 00                	push   $0x0
80108d32:	ff 75 f4             	pushl  -0xc(%ebp)
80108d35:	e8 97 ce ff ff       	call   80105bd1 <memset>
80108d3a:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108d3d:	83 ec 0c             	sub    $0xc,%esp
80108d40:	ff 75 f4             	pushl  -0xc(%ebp)
80108d43:	e8 a3 f7 ff ff       	call   801084eb <v2p>
80108d48:	83 c4 10             	add    $0x10,%esp
80108d4b:	83 ec 0c             	sub    $0xc,%esp
80108d4e:	6a 06                	push   $0x6
80108d50:	50                   	push   %eax
80108d51:	68 00 10 00 00       	push   $0x1000
80108d56:	6a 00                	push   $0x0
80108d58:	ff 75 08             	pushl  0x8(%ebp)
80108d5b:	e8 ba fc ff ff       	call   80108a1a <mappages>
80108d60:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108d63:	83 ec 04             	sub    $0x4,%esp
80108d66:	ff 75 10             	pushl  0x10(%ebp)
80108d69:	ff 75 0c             	pushl  0xc(%ebp)
80108d6c:	ff 75 f4             	pushl  -0xc(%ebp)
80108d6f:	e8 1c cf ff ff       	call   80105c90 <memmove>
80108d74:	83 c4 10             	add    $0x10,%esp
}
80108d77:	90                   	nop
80108d78:	c9                   	leave  
80108d79:	c3                   	ret    

80108d7a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108d7a:	55                   	push   %ebp
80108d7b:	89 e5                	mov    %esp,%ebp
80108d7d:	53                   	push   %ebx
80108d7e:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d84:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d89:	85 c0                	test   %eax,%eax
80108d8b:	74 0d                	je     80108d9a <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108d8d:	83 ec 0c             	sub    $0xc,%esp
80108d90:	68 48 9a 10 80       	push   $0x80109a48
80108d95:	e8 cc 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108d9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108da1:	e9 95 00 00 00       	jmp    80108e3b <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108da6:	8b 55 0c             	mov    0xc(%ebp),%edx
80108da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dac:	01 d0                	add    %edx,%eax
80108dae:	83 ec 04             	sub    $0x4,%esp
80108db1:	6a 00                	push   $0x0
80108db3:	50                   	push   %eax
80108db4:	ff 75 08             	pushl  0x8(%ebp)
80108db7:	e8 be fb ff ff       	call   8010897a <walkpgdir>
80108dbc:	83 c4 10             	add    $0x10,%esp
80108dbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108dc2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108dc6:	75 0d                	jne    80108dd5 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108dc8:	83 ec 0c             	sub    $0xc,%esp
80108dcb:	68 6b 9a 10 80       	push   $0x80109a6b
80108dd0:	e8 91 77 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108dd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd8:	8b 00                	mov    (%eax),%eax
80108dda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ddf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108de2:	8b 45 18             	mov    0x18(%ebp),%eax
80108de5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108de8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108ded:	77 0b                	ja     80108dfa <loaduvm+0x80>
      n = sz - i;
80108def:	8b 45 18             	mov    0x18(%ebp),%eax
80108df2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108df5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108df8:	eb 07                	jmp    80108e01 <loaduvm+0x87>
    else
      n = PGSIZE;
80108dfa:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108e01:	8b 55 14             	mov    0x14(%ebp),%edx
80108e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e07:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108e0a:	83 ec 0c             	sub    $0xc,%esp
80108e0d:	ff 75 e8             	pushl  -0x18(%ebp)
80108e10:	e8 e3 f6 ff ff       	call   801084f8 <p2v>
80108e15:	83 c4 10             	add    $0x10,%esp
80108e18:	ff 75 f0             	pushl  -0x10(%ebp)
80108e1b:	53                   	push   %ebx
80108e1c:	50                   	push   %eax
80108e1d:	ff 75 10             	pushl  0x10(%ebp)
80108e20:	e8 b1 90 ff ff       	call   80101ed6 <readi>
80108e25:	83 c4 10             	add    $0x10,%esp
80108e28:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108e2b:	74 07                	je     80108e34 <loaduvm+0xba>
      return -1;
80108e2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e32:	eb 18                	jmp    80108e4c <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108e34:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108e41:	0f 82 5f ff ff ff    	jb     80108da6 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108e47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e4f:	c9                   	leave  
80108e50:	c3                   	ret    

80108e51 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108e51:	55                   	push   %ebp
80108e52:	89 e5                	mov    %esp,%ebp
80108e54:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108e57:	8b 45 10             	mov    0x10(%ebp),%eax
80108e5a:	85 c0                	test   %eax,%eax
80108e5c:	79 0a                	jns    80108e68 <allocuvm+0x17>
    return 0;
80108e5e:	b8 00 00 00 00       	mov    $0x0,%eax
80108e63:	e9 b0 00 00 00       	jmp    80108f18 <allocuvm+0xc7>
  if(newsz < oldsz)
80108e68:	8b 45 10             	mov    0x10(%ebp),%eax
80108e6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e6e:	73 08                	jae    80108e78 <allocuvm+0x27>
    return oldsz;
80108e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e73:	e9 a0 00 00 00       	jmp    80108f18 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e7b:	05 ff 0f 00 00       	add    $0xfff,%eax
80108e80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108e88:	eb 7f                	jmp    80108f09 <allocuvm+0xb8>
    mem = kalloc();
80108e8a:	e8 99 9d ff ff       	call   80102c28 <kalloc>
80108e8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108e92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e96:	75 2b                	jne    80108ec3 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108e98:	83 ec 0c             	sub    $0xc,%esp
80108e9b:	68 89 9a 10 80       	push   $0x80109a89
80108ea0:	e8 21 75 ff ff       	call   801003c6 <cprintf>
80108ea5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108ea8:	83 ec 04             	sub    $0x4,%esp
80108eab:	ff 75 0c             	pushl  0xc(%ebp)
80108eae:	ff 75 10             	pushl  0x10(%ebp)
80108eb1:	ff 75 08             	pushl  0x8(%ebp)
80108eb4:	e8 61 00 00 00       	call   80108f1a <deallocuvm>
80108eb9:	83 c4 10             	add    $0x10,%esp
      return 0;
80108ebc:	b8 00 00 00 00       	mov    $0x0,%eax
80108ec1:	eb 55                	jmp    80108f18 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108ec3:	83 ec 04             	sub    $0x4,%esp
80108ec6:	68 00 10 00 00       	push   $0x1000
80108ecb:	6a 00                	push   $0x0
80108ecd:	ff 75 f0             	pushl  -0x10(%ebp)
80108ed0:	e8 fc cc ff ff       	call   80105bd1 <memset>
80108ed5:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ed8:	83 ec 0c             	sub    $0xc,%esp
80108edb:	ff 75 f0             	pushl  -0x10(%ebp)
80108ede:	e8 08 f6 ff ff       	call   801084eb <v2p>
80108ee3:	83 c4 10             	add    $0x10,%esp
80108ee6:	89 c2                	mov    %eax,%edx
80108ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eeb:	83 ec 0c             	sub    $0xc,%esp
80108eee:	6a 06                	push   $0x6
80108ef0:	52                   	push   %edx
80108ef1:	68 00 10 00 00       	push   $0x1000
80108ef6:	50                   	push   %eax
80108ef7:	ff 75 08             	pushl  0x8(%ebp)
80108efa:	e8 1b fb ff ff       	call   80108a1a <mappages>
80108eff:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108f02:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0c:	3b 45 10             	cmp    0x10(%ebp),%eax
80108f0f:	0f 82 75 ff ff ff    	jb     80108e8a <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108f15:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108f18:	c9                   	leave  
80108f19:	c3                   	ret    

80108f1a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f1a:	55                   	push   %ebp
80108f1b:	89 e5                	mov    %esp,%ebp
80108f1d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108f20:	8b 45 10             	mov    0x10(%ebp),%eax
80108f23:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f26:	72 08                	jb     80108f30 <deallocuvm+0x16>
    return oldsz;
80108f28:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f2b:	e9 a5 00 00 00       	jmp    80108fd5 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108f30:	8b 45 10             	mov    0x10(%ebp),%eax
80108f33:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108f40:	e9 81 00 00 00       	jmp    80108fc6 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f48:	83 ec 04             	sub    $0x4,%esp
80108f4b:	6a 00                	push   $0x0
80108f4d:	50                   	push   %eax
80108f4e:	ff 75 08             	pushl  0x8(%ebp)
80108f51:	e8 24 fa ff ff       	call   8010897a <walkpgdir>
80108f56:	83 c4 10             	add    $0x10,%esp
80108f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108f5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f60:	75 09                	jne    80108f6b <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108f62:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108f69:	eb 54                	jmp    80108fbf <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f6e:	8b 00                	mov    (%eax),%eax
80108f70:	83 e0 01             	and    $0x1,%eax
80108f73:	85 c0                	test   %eax,%eax
80108f75:	74 48                	je     80108fbf <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f7a:	8b 00                	mov    (%eax),%eax
80108f7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f81:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108f84:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f88:	75 0d                	jne    80108f97 <deallocuvm+0x7d>
        panic("kfree");
80108f8a:	83 ec 0c             	sub    $0xc,%esp
80108f8d:	68 a1 9a 10 80       	push   $0x80109aa1
80108f92:	e8 cf 75 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108f97:	83 ec 0c             	sub    $0xc,%esp
80108f9a:	ff 75 ec             	pushl  -0x14(%ebp)
80108f9d:	e8 56 f5 ff ff       	call   801084f8 <p2v>
80108fa2:	83 c4 10             	add    $0x10,%esp
80108fa5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108fa8:	83 ec 0c             	sub    $0xc,%esp
80108fab:	ff 75 e8             	pushl  -0x18(%ebp)
80108fae:	e8 d8 9b ff ff       	call   80102b8b <kfree>
80108fb3:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108fbf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fcc:	0f 82 73 ff ff ff    	jb     80108f45 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108fd2:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fd5:	c9                   	leave  
80108fd6:	c3                   	ret    

80108fd7 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108fd7:	55                   	push   %ebp
80108fd8:	89 e5                	mov    %esp,%ebp
80108fda:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108fdd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108fe1:	75 0d                	jne    80108ff0 <freevm+0x19>
    panic("freevm: no pgdir");
80108fe3:	83 ec 0c             	sub    $0xc,%esp
80108fe6:	68 a7 9a 10 80       	push   $0x80109aa7
80108feb:	e8 76 75 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108ff0:	83 ec 04             	sub    $0x4,%esp
80108ff3:	6a 00                	push   $0x0
80108ff5:	68 00 00 00 80       	push   $0x80000000
80108ffa:	ff 75 08             	pushl  0x8(%ebp)
80108ffd:	e8 18 ff ff ff       	call   80108f1a <deallocuvm>
80109002:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109005:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010900c:	eb 4f                	jmp    8010905d <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010900e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109011:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109018:	8b 45 08             	mov    0x8(%ebp),%eax
8010901b:	01 d0                	add    %edx,%eax
8010901d:	8b 00                	mov    (%eax),%eax
8010901f:	83 e0 01             	and    $0x1,%eax
80109022:	85 c0                	test   %eax,%eax
80109024:	74 33                	je     80109059 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109029:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109030:	8b 45 08             	mov    0x8(%ebp),%eax
80109033:	01 d0                	add    %edx,%eax
80109035:	8b 00                	mov    (%eax),%eax
80109037:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010903c:	83 ec 0c             	sub    $0xc,%esp
8010903f:	50                   	push   %eax
80109040:	e8 b3 f4 ff ff       	call   801084f8 <p2v>
80109045:	83 c4 10             	add    $0x10,%esp
80109048:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010904b:	83 ec 0c             	sub    $0xc,%esp
8010904e:	ff 75 f0             	pushl  -0x10(%ebp)
80109051:	e8 35 9b ff ff       	call   80102b8b <kfree>
80109056:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109059:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010905d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109064:	76 a8                	jbe    8010900e <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109066:	83 ec 0c             	sub    $0xc,%esp
80109069:	ff 75 08             	pushl  0x8(%ebp)
8010906c:	e8 1a 9b ff ff       	call   80102b8b <kfree>
80109071:	83 c4 10             	add    $0x10,%esp
}
80109074:	90                   	nop
80109075:	c9                   	leave  
80109076:	c3                   	ret    

80109077 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109077:	55                   	push   %ebp
80109078:	89 e5                	mov    %esp,%ebp
8010907a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010907d:	83 ec 04             	sub    $0x4,%esp
80109080:	6a 00                	push   $0x0
80109082:	ff 75 0c             	pushl  0xc(%ebp)
80109085:	ff 75 08             	pushl  0x8(%ebp)
80109088:	e8 ed f8 ff ff       	call   8010897a <walkpgdir>
8010908d:	83 c4 10             	add    $0x10,%esp
80109090:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109093:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109097:	75 0d                	jne    801090a6 <clearpteu+0x2f>
    panic("clearpteu");
80109099:	83 ec 0c             	sub    $0xc,%esp
8010909c:	68 b8 9a 10 80       	push   $0x80109ab8
801090a1:	e8 c0 74 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801090a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a9:	8b 00                	mov    (%eax),%eax
801090ab:	83 e0 fb             	and    $0xfffffffb,%eax
801090ae:	89 c2                	mov    %eax,%edx
801090b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b3:	89 10                	mov    %edx,(%eax)
}
801090b5:	90                   	nop
801090b6:	c9                   	leave  
801090b7:	c3                   	ret    

801090b8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801090b8:	55                   	push   %ebp
801090b9:	89 e5                	mov    %esp,%ebp
801090bb:	53                   	push   %ebx
801090bc:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801090bf:	e8 e6 f9 ff ff       	call   80108aaa <setupkvm>
801090c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801090c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801090cb:	75 0a                	jne    801090d7 <copyuvm+0x1f>
    return 0;
801090cd:	b8 00 00 00 00       	mov    $0x0,%eax
801090d2:	e9 ee 00 00 00       	jmp    801091c5 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
801090d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090de:	e9 ba 00 00 00       	jmp    8010919d <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801090e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e6:	83 ec 04             	sub    $0x4,%esp
801090e9:	6a 00                	push   $0x0
801090eb:	50                   	push   %eax
801090ec:	ff 75 08             	pushl  0x8(%ebp)
801090ef:	e8 86 f8 ff ff       	call   8010897a <walkpgdir>
801090f4:	83 c4 10             	add    $0x10,%esp
801090f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801090fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801090fe:	75 0d                	jne    8010910d <copyuvm+0x55>
    //  continue;
      panic("copyuvm: pte should exist");
80109100:	83 ec 0c             	sub    $0xc,%esp
80109103:	68 c2 9a 10 80       	push   $0x80109ac2
80109108:	e8 59 74 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010910d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109110:	8b 00                	mov    (%eax),%eax
80109112:	83 e0 01             	and    $0x1,%eax
80109115:	85 c0                	test   %eax,%eax
80109117:	74 7c                	je     80109195 <copyuvm+0xdd>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80109119:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010911c:	8b 00                	mov    (%eax),%eax
8010911e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109123:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109126:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109129:	8b 00                	mov    (%eax),%eax
8010912b:	25 ff 0f 00 00       	and    $0xfff,%eax
80109130:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109133:	e8 f0 9a ff ff       	call   80102c28 <kalloc>
80109138:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010913b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010913f:	74 6d                	je     801091ae <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109141:	83 ec 0c             	sub    $0xc,%esp
80109144:	ff 75 e8             	pushl  -0x18(%ebp)
80109147:	e8 ac f3 ff ff       	call   801084f8 <p2v>
8010914c:	83 c4 10             	add    $0x10,%esp
8010914f:	83 ec 04             	sub    $0x4,%esp
80109152:	68 00 10 00 00       	push   $0x1000
80109157:	50                   	push   %eax
80109158:	ff 75 e0             	pushl  -0x20(%ebp)
8010915b:	e8 30 cb ff ff       	call   80105c90 <memmove>
80109160:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109163:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109166:	83 ec 0c             	sub    $0xc,%esp
80109169:	ff 75 e0             	pushl  -0x20(%ebp)
8010916c:	e8 7a f3 ff ff       	call   801084eb <v2p>
80109171:	83 c4 10             	add    $0x10,%esp
80109174:	89 c2                	mov    %eax,%edx
80109176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109179:	83 ec 0c             	sub    $0xc,%esp
8010917c:	53                   	push   %ebx
8010917d:	52                   	push   %edx
8010917e:	68 00 10 00 00       	push   $0x1000
80109183:	50                   	push   %eax
80109184:	ff 75 f0             	pushl  -0x10(%ebp)
80109187:	e8 8e f8 ff ff       	call   80108a1a <mappages>
8010918c:	83 c4 20             	add    $0x20,%esp
8010918f:	85 c0                	test   %eax,%eax
80109191:	78 1e                	js     801091b1 <copyuvm+0xf9>
80109193:	eb 01                	jmp    80109196 <copyuvm+0xde>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
    //  continue;
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      continue;
80109195:	90                   	nop
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109196:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010919d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091a3:	0f 82 3a ff ff ff    	jb     801090e3 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801091a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ac:	eb 17                	jmp    801091c5 <copyuvm+0x10d>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801091ae:	90                   	nop
801091af:	eb 01                	jmp    801091b2 <copyuvm+0xfa>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801091b1:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801091b2:	83 ec 0c             	sub    $0xc,%esp
801091b5:	ff 75 f0             	pushl  -0x10(%ebp)
801091b8:	e8 1a fe ff ff       	call   80108fd7 <freevm>
801091bd:	83 c4 10             	add    $0x10,%esp
  return 0;
801091c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801091c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801091c8:	c9                   	leave  
801091c9:	c3                   	ret    

801091ca <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801091ca:	55                   	push   %ebp
801091cb:	89 e5                	mov    %esp,%ebp
801091cd:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801091d0:	83 ec 04             	sub    $0x4,%esp
801091d3:	6a 00                	push   $0x0
801091d5:	ff 75 0c             	pushl  0xc(%ebp)
801091d8:	ff 75 08             	pushl  0x8(%ebp)
801091db:	e8 9a f7 ff ff       	call   8010897a <walkpgdir>
801091e0:	83 c4 10             	add    $0x10,%esp
801091e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801091e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e9:	8b 00                	mov    (%eax),%eax
801091eb:	83 e0 01             	and    $0x1,%eax
801091ee:	85 c0                	test   %eax,%eax
801091f0:	75 07                	jne    801091f9 <uva2ka+0x2f>
    return 0;
801091f2:	b8 00 00 00 00       	mov    $0x0,%eax
801091f7:	eb 29                	jmp    80109222 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801091f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fc:	8b 00                	mov    (%eax),%eax
801091fe:	83 e0 04             	and    $0x4,%eax
80109201:	85 c0                	test   %eax,%eax
80109203:	75 07                	jne    8010920c <uva2ka+0x42>
    return 0;
80109205:	b8 00 00 00 00       	mov    $0x0,%eax
8010920a:	eb 16                	jmp    80109222 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010920c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920f:	8b 00                	mov    (%eax),%eax
80109211:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109216:	83 ec 0c             	sub    $0xc,%esp
80109219:	50                   	push   %eax
8010921a:	e8 d9 f2 ff ff       	call   801084f8 <p2v>
8010921f:	83 c4 10             	add    $0x10,%esp
}
80109222:	c9                   	leave  
80109223:	c3                   	ret    

80109224 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109224:	55                   	push   %ebp
80109225:	89 e5                	mov    %esp,%ebp
80109227:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010922a:	8b 45 10             	mov    0x10(%ebp),%eax
8010922d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109230:	eb 7f                	jmp    801092b1 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109232:	8b 45 0c             	mov    0xc(%ebp),%eax
80109235:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010923a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010923d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109240:	83 ec 08             	sub    $0x8,%esp
80109243:	50                   	push   %eax
80109244:	ff 75 08             	pushl  0x8(%ebp)
80109247:	e8 7e ff ff ff       	call   801091ca <uva2ka>
8010924c:	83 c4 10             	add    $0x10,%esp
8010924f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109252:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109256:	75 07                	jne    8010925f <copyout+0x3b>
      return -1;
80109258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010925d:	eb 61                	jmp    801092c0 <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010925f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109262:	2b 45 0c             	sub    0xc(%ebp),%eax
80109265:	05 00 10 00 00       	add    $0x1000,%eax
8010926a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010926d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109270:	3b 45 14             	cmp    0x14(%ebp),%eax
80109273:	76 06                	jbe    8010927b <copyout+0x57>
      n = len;
80109275:	8b 45 14             	mov    0x14(%ebp),%eax
80109278:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010927b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010927e:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109281:	89 c2                	mov    %eax,%edx
80109283:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109286:	01 d0                	add    %edx,%eax
80109288:	83 ec 04             	sub    $0x4,%esp
8010928b:	ff 75 f0             	pushl  -0x10(%ebp)
8010928e:	ff 75 f4             	pushl  -0xc(%ebp)
80109291:	50                   	push   %eax
80109292:	e8 f9 c9 ff ff       	call   80105c90 <memmove>
80109297:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010929a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801092a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a3:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801092a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092a9:	05 00 10 00 00       	add    $0x1000,%eax
801092ae:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801092b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801092b5:	0f 85 77 ff ff ff    	jne    80109232 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801092bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092c0:	c9                   	leave  
801092c1:	c3                   	ret    
