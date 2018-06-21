
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
8010002d:	b8 35 38 10 80       	mov    $0x80103835,%eax
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
8010003d:	68 70 91 10 80       	push   $0x80109170
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 dc 58 00 00       	call   80105928 <initlock>
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
801000c1:	e8 84 58 00 00       	call   8010594a <acquire>
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
8010010c:	e8 a0 58 00 00       	call   801059b1 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 62 50 00 00       	call   8010518e <sleep>
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
80100188:	e8 24 58 00 00       	call   801059b1 <release>
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
801001aa:	68 77 91 10 80       	push   $0x80109177
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
801001e2:	e8 c4 26 00 00       	call   801028ab <iderw>
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
80100204:	68 88 91 10 80       	push   $0x80109188
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
80100223:	e8 83 26 00 00       	call   801028ab <iderw>
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
80100243:	68 8f 91 10 80       	push   $0x8010918f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 f0 56 00 00       	call   8010594a <acquire>
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
801002b9:	e8 dc 4f 00 00       	call   8010529a <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 e3 56 00 00       	call   801059b1 <release>
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
801003e2:	e8 63 55 00 00       	call   8010594a <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 96 91 10 80       	push   $0x80109196
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
801004cd:	c7 45 ec 9f 91 10 80 	movl   $0x8010919f,-0x14(%ebp)
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
8010055b:	e8 51 54 00 00       	call   801059b1 <release>
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
8010058b:	68 a6 91 10 80       	push   $0x801091a6
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
801005aa:	68 b5 91 10 80       	push   $0x801091b5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 3c 54 00 00       	call   80105a03 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 b7 91 10 80       	push   $0x801091b7
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
801006db:	e8 8c 55 00 00       	call   80105c6c <memmove>
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
80100705:	e8 a3 54 00 00       	call   80105bad <memset>
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
8010079a:	e8 61 70 00 00       	call   80107800 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 54 70 00 00       	call   80107800 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 47 70 00 00       	call   80107800 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 37 70 00 00       	call   80107800 <uartputc>
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
801007eb:	e8 5a 51 00 00       	call   8010594a <acquire>
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
8010081e:	e8 39 4b 00 00       	call   8010535c <procdump>
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
80100931:	e8 64 49 00 00       	call   8010529a <wakeup>
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
80100954:	e8 58 50 00 00       	call   801059b1 <release>
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
8010096b:	e8 32 11 00 00       	call   80101aa2 <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 a0 17 11 80       	push   $0x801117a0
80100981:	e8 c4 4f 00 00       	call   8010594a <acquire>
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
801009a3:	e8 09 50 00 00       	call   801059b1 <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 94 0f 00 00       	call   8010194a <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 a0 17 11 80       	push   $0x801117a0
801009cb:	68 54 18 11 80       	push   $0x80111854
801009d0:	e8 b9 47 00 00       	call   8010518e <sleep>
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
80100a4e:	e8 5e 4f 00 00       	call   801059b1 <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 e9 0e 00 00       	call   8010194a <ilock>
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
80100a7c:	e8 21 10 00 00       	call   80101aa2 <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a8c:	e8 b9 4e 00 00       	call   8010594a <acquire>
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
80100ace:	e8 de 4e 00 00       	call   801059b1 <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 69 0e 00 00       	call   8010194a <ilock>
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
80100af2:	68 bb 91 10 80       	push   $0x801091bb
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 27 4e 00 00       	call   80105928 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 c3 91 10 80       	push   $0x801091c3
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 12 4e 00 00       	call   80105928 <initlock>
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
80100b3c:	e8 d6 34 00 00       	call   80104017 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 28 1f 00 00       	call   80102a78 <ioapicenable>
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
80100b5f:	e8 8f 29 00 00       	call   801034f3 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 93 19 00 00       	call   80102502 <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 ff 29 00 00       	call   8010357f <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 d6 03 00 00       	jmp    80100f60 <exec+0x40a>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 b5 0d 00 00       	call   8010194a <ilock>
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
80100bad:	e8 00 13 00 00       	call   80101eb2 <readi>
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
80100bcf:	e8 81 7d 00 00       	call   80108955 <setupkvm>
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
80100c0d:	e8 a0 12 00 00       	call   80101eb2 <readi>
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
80100c55:	e8 a2 80 00 00       	call   80108cfc <allocuvm>
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
80100c88:	e8 98 7f 00 00       	call   80108c25 <loaduvm>
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
80100cc1:	e8 3e 0f 00 00       	call   80101c04 <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 b1 28 00 00       	call   8010357f <end_op>
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
80100d16:	e8 e1 7f 00 00       	call   80108cfc <allocuvm>
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
80100d5c:	e8 99 50 00 00       	call   80105dfa <strlen>
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
80100d89:	e8 6c 50 00 00       	call   80105dfa <strlen>
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
80100daf:	e8 1b 83 00 00       	call   801090cf <copyout>
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
80100e4b:	e8 7f 82 00 00       	call   801090cf <copyout>
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
80100e9c:	e8 0f 4f 00 00       	call   80105db0 <safestrcpy>
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
80100ef2:	e8 45 7b 00 00       	call   80108a3c <switchuvm>
80100ef7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100efa:	83 ec 0c             	sub    $0xc,%esp
80100efd:	ff 75 d0             	pushl  -0x30(%ebp)
80100f00:	e8 7d 7f 00 00       	call   80108e82 <freevm>
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
80100f3a:	e8 43 7f 00 00       	call   80108e82 <freevm>
80100f3f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f46:	74 13                	je     80100f5b <exec+0x405>
    iunlockput(ip);
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	ff 75 d8             	pushl  -0x28(%ebp)
80100f4e:	e8 b1 0c 00 00       	call   80101c04 <iunlockput>
80100f53:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f56:	e8 24 26 00 00       	call   8010357f <end_op>
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
80100f6b:	68 c9 91 10 80       	push   $0x801091c9
80100f70:	68 60 18 11 80       	push   $0x80111860
80100f75:	e8 ae 49 00 00       	call   80105928 <initlock>
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
80100f8e:	e8 b7 49 00 00       	call   8010594a <acquire>
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
80100fbb:	e8 f1 49 00 00       	call   801059b1 <release>
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
80100fde:	e8 ce 49 00 00       	call   801059b1 <release>
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
80100ffb:	e8 4a 49 00 00       	call   8010594a <acquire>
80101000:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	8b 40 04             	mov    0x4(%eax),%eax
80101009:	85 c0                	test   %eax,%eax
8010100b:	7f 0d                	jg     8010101a <filedup+0x2d>
    panic("filedup");
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 d0 91 10 80       	push   $0x801091d0
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
80101031:	e8 7b 49 00 00       	call   801059b1 <release>
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
8010104c:	e8 f9 48 00 00       	call   8010594a <acquire>
80101051:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	7f 0d                	jg     8010106b <fileclose+0x2d>
    panic("fileclose");
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 d8 91 10 80       	push   $0x801091d8
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
8010108c:	e8 20 49 00 00       	call   801059b1 <release>
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
801010da:	e8 d2 48 00 00       	call   801059b1 <release>
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
801010f9:	e8 82 31 00 00       	call   80104280 <pipeclose>
801010fe:	83 c4 10             	add    $0x10,%esp
80101101:	eb 21                	jmp    80101124 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101103:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101106:	83 f8 02             	cmp    $0x2,%eax
80101109:	75 19                	jne    80101124 <fileclose+0xe6>
    begin_op();
8010110b:	e8 e3 23 00 00       	call   801034f3 <begin_op>
    iput(ff.ip);
80101110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	50                   	push   %eax
80101117:	e8 f8 09 00 00       	call   80101b14 <iput>
8010111c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010111f:	e8 5b 24 00 00       	call   8010357f <end_op>
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
80101140:	e8 05 08 00 00       	call   8010194a <ilock>
80101145:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 40 10             	mov    0x10(%eax),%eax
8010114e:	83 ec 08             	sub    $0x8,%esp
80101151:	ff 75 0c             	pushl  0xc(%ebp)
80101154:	50                   	push   %eax
80101155:	e8 12 0d 00 00       	call   80101e6c <stati>
8010115a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	8b 40 10             	mov    0x10(%eax),%eax
80101163:	83 ec 0c             	sub    $0xc,%esp
80101166:	50                   	push   %eax
80101167:	e8 36 09 00 00       	call   80101aa2 <iunlock>
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
801011b2:	e8 71 32 00 00       	call   80104428 <piperead>
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
801011d0:	e8 75 07 00 00       	call   8010194a <ilock>
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
801011ed:	e8 c0 0c 00 00       	call   80101eb2 <readi>
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
80101219:	e8 84 08 00 00       	call   80101aa2 <iunlock>
8010121e:	83 c4 10             	add    $0x10,%esp
    return r;
80101221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101224:	eb 0d                	jmp    80101233 <fileread+0xb6>
  }
  panic("fileread");
80101226:	83 ec 0c             	sub    $0xc,%esp
80101229:	68 e2 91 10 80       	push   $0x801091e2
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
8010126b:	e8 ba 30 00 00       	call   8010432a <pipewrite>
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
801012b0:	e8 3e 22 00 00       	call   801034f3 <begin_op>
      ilock(f->ip);
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 40 10             	mov    0x10(%eax),%eax
801012bb:	83 ec 0c             	sub    $0xc,%esp
801012be:	50                   	push   %eax
801012bf:	e8 86 06 00 00       	call   8010194a <ilock>
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
801012e2:	e8 22 0d 00 00       	call   80102009 <writei>
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
8010130e:	e8 8f 07 00 00       	call   80101aa2 <iunlock>
80101313:	83 c4 10             	add    $0x10,%esp
      end_op();
80101316:	e8 64 22 00 00       	call   8010357f <end_op>

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
8010132c:	68 eb 91 10 80       	push   $0x801091eb
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
80101362:	68 fb 91 10 80       	push   $0x801091fb
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
80101384:	eb 20                	jmp    801013a6 <fileseek+0x35>
  }
  if(f->writable == 0)
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010138d:	84 c0                	test   %al,%al
8010138f:	75 07                	jne    80101398 <fileseek+0x27>
    return -1;
80101391:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101396:	eb 0e                	jmp    801013a6 <fileseek+0x35>
  f->off = newoffset;
80101398:	8b 45 08             	mov    0x8(%ebp),%eax
8010139b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010139e:	89 50 14             	mov    %edx,0x14(%eax)
  return 0;
801013a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801013a6:	5d                   	pop    %ebp
801013a7:	c3                   	ret    

801013a8 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013a8:	55                   	push   %ebp
801013a9:	89 e5                	mov    %esp,%ebp
801013ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	83 ec 08             	sub    $0x8,%esp
801013b4:	6a 01                	push   $0x1
801013b6:	50                   	push   %eax
801013b7:	e8 fa ed ff ff       	call   801001b6 <bread>
801013bc:	83 c4 10             	add    $0x10,%esp
801013bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c5:	83 c0 18             	add    $0x18,%eax
801013c8:	83 ec 04             	sub    $0x4,%esp
801013cb:	6a 10                	push   $0x10
801013cd:	50                   	push   %eax
801013ce:	ff 75 0c             	pushl  0xc(%ebp)
801013d1:	e8 96 48 00 00       	call   80105c6c <memmove>
801013d6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013d9:	83 ec 0c             	sub    $0xc,%esp
801013dc:	ff 75 f4             	pushl  -0xc(%ebp)
801013df:	e8 4a ee ff ff       	call   8010022e <brelse>
801013e4:	83 c4 10             	add    $0x10,%esp
}
801013e7:	90                   	nop
801013e8:	c9                   	leave  
801013e9:	c3                   	ret    

801013ea <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ea:	55                   	push   %ebp
801013eb:	89 e5                	mov    %esp,%ebp
801013ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801013f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013f3:	8b 45 08             	mov    0x8(%ebp),%eax
801013f6:	83 ec 08             	sub    $0x8,%esp
801013f9:	52                   	push   %edx
801013fa:	50                   	push   %eax
801013fb:	e8 b6 ed ff ff       	call   801001b6 <bread>
80101400:	83 c4 10             	add    $0x10,%esp
80101403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	83 c0 18             	add    $0x18,%eax
8010140c:	83 ec 04             	sub    $0x4,%esp
8010140f:	68 00 02 00 00       	push   $0x200
80101414:	6a 00                	push   $0x0
80101416:	50                   	push   %eax
80101417:	e8 91 47 00 00       	call   80105bad <memset>
8010141c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010141f:	83 ec 0c             	sub    $0xc,%esp
80101422:	ff 75 f4             	pushl  -0xc(%ebp)
80101425:	e8 01 23 00 00       	call   8010372b <log_write>
8010142a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010142d:	83 ec 0c             	sub    $0xc,%esp
80101430:	ff 75 f4             	pushl  -0xc(%ebp)
80101433:	e8 f6 ed ff ff       	call   8010022e <brelse>
80101438:	83 c4 10             	add    $0x10,%esp
}
8010143b:	90                   	nop
8010143c:	c9                   	leave  
8010143d:	c3                   	ret    

8010143e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010143e:	55                   	push   %ebp
8010143f:	89 e5                	mov    %esp,%ebp
80101441:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101444:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010144b:	8b 45 08             	mov    0x8(%ebp),%eax
8010144e:	83 ec 08             	sub    $0x8,%esp
80101451:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101454:	52                   	push   %edx
80101455:	50                   	push   %eax
80101456:	e8 4d ff ff ff       	call   801013a8 <readsb>
8010145b:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010145e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101465:	e9 15 01 00 00       	jmp    8010157f <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010146d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101473:	85 c0                	test   %eax,%eax
80101475:	0f 48 c2             	cmovs  %edx,%eax
80101478:	c1 f8 0c             	sar    $0xc,%eax
8010147b:	89 c2                	mov    %eax,%edx
8010147d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101480:	c1 e8 03             	shr    $0x3,%eax
80101483:	01 d0                	add    %edx,%eax
80101485:	83 c0 03             	add    $0x3,%eax
80101488:	83 ec 08             	sub    $0x8,%esp
8010148b:	50                   	push   %eax
8010148c:	ff 75 08             	pushl  0x8(%ebp)
8010148f:	e8 22 ed ff ff       	call   801001b6 <bread>
80101494:	83 c4 10             	add    $0x10,%esp
80101497:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010149a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014a1:	e9 a6 00 00 00       	jmp    8010154c <balloc+0x10e>
      m = 1 << (bi % 8);
801014a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a9:	99                   	cltd   
801014aa:	c1 ea 1d             	shr    $0x1d,%edx
801014ad:	01 d0                	add    %edx,%eax
801014af:	83 e0 07             	and    $0x7,%eax
801014b2:	29 d0                	sub    %edx,%eax
801014b4:	ba 01 00 00 00       	mov    $0x1,%edx
801014b9:	89 c1                	mov    %eax,%ecx
801014bb:	d3 e2                	shl    %cl,%edx
801014bd:	89 d0                	mov    %edx,%eax
801014bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c5:	8d 50 07             	lea    0x7(%eax),%edx
801014c8:	85 c0                	test   %eax,%eax
801014ca:	0f 48 c2             	cmovs  %edx,%eax
801014cd:	c1 f8 03             	sar    $0x3,%eax
801014d0:	89 c2                	mov    %eax,%edx
801014d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014d5:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014da:	0f b6 c0             	movzbl %al,%eax
801014dd:	23 45 e8             	and    -0x18(%ebp),%eax
801014e0:	85 c0                	test   %eax,%eax
801014e2:	75 64                	jne    80101548 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
801014e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e7:	8d 50 07             	lea    0x7(%eax),%edx
801014ea:	85 c0                	test   %eax,%eax
801014ec:	0f 48 c2             	cmovs  %edx,%eax
801014ef:	c1 f8 03             	sar    $0x3,%eax
801014f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f5:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014fa:	89 d1                	mov    %edx,%ecx
801014fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ff:	09 ca                	or     %ecx,%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010150a:	83 ec 0c             	sub    $0xc,%esp
8010150d:	ff 75 ec             	pushl  -0x14(%ebp)
80101510:	e8 16 22 00 00       	call   8010372b <log_write>
80101515:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 ec             	pushl  -0x14(%ebp)
8010151e:	e8 0b ed ff ff       	call   8010022e <brelse>
80101523:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101526:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152c:	01 c2                	add    %eax,%edx
8010152e:	8b 45 08             	mov    0x8(%ebp),%eax
80101531:	83 ec 08             	sub    $0x8,%esp
80101534:	52                   	push   %edx
80101535:	50                   	push   %eax
80101536:	e8 af fe ff ff       	call   801013ea <bzero>
8010153b:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010153e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101544:	01 d0                	add    %edx,%eax
80101546:	eb 52                	jmp    8010159a <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101548:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010154c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101553:	7f 15                	jg     8010156a <balloc+0x12c>
80101555:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101558:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155b:	01 d0                	add    %edx,%eax
8010155d:	89 c2                	mov    %eax,%edx
8010155f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101562:	39 c2                	cmp    %eax,%edx
80101564:	0f 82 3c ff ff ff    	jb     801014a6 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010156a:	83 ec 0c             	sub    $0xc,%esp
8010156d:	ff 75 ec             	pushl  -0x14(%ebp)
80101570:	e8 b9 ec ff ff       	call   8010022e <brelse>
80101575:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101578:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010157f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101585:	39 c2                	cmp    %eax,%edx
80101587:	0f 87 dd fe ff ff    	ja     8010146a <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010158d:	83 ec 0c             	sub    $0xc,%esp
80101590:	68 05 92 10 80       	push   $0x80109205
80101595:	e8 cc ef ff ff       	call   80100566 <panic>
}
8010159a:	c9                   	leave  
8010159b:	c3                   	ret    

8010159c <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010159c:	55                   	push   %ebp
8010159d:	89 e5                	mov    %esp,%ebp
8010159f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801015a2:	83 ec 08             	sub    $0x8,%esp
801015a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801015a8:	50                   	push   %eax
801015a9:	ff 75 08             	pushl  0x8(%ebp)
801015ac:	e8 f7 fd ff ff       	call   801013a8 <readsb>
801015b1:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801015b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015b7:	c1 e8 0c             	shr    $0xc,%eax
801015ba:	89 c2                	mov    %eax,%edx
801015bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	01 d0                	add    %edx,%eax
801015c4:	8d 50 03             	lea    0x3(%eax),%edx
801015c7:	8b 45 08             	mov    0x8(%ebp),%eax
801015ca:	83 ec 08             	sub    $0x8,%esp
801015cd:	52                   	push   %edx
801015ce:	50                   	push   %eax
801015cf:	e8 e2 eb ff ff       	call   801001b6 <bread>
801015d4:	83 c4 10             	add    $0x10,%esp
801015d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015da:	8b 45 0c             	mov    0xc(%ebp),%eax
801015dd:	25 ff 0f 00 00       	and    $0xfff,%eax
801015e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e8:	99                   	cltd   
801015e9:	c1 ea 1d             	shr    $0x1d,%edx
801015ec:	01 d0                	add    %edx,%eax
801015ee:	83 e0 07             	and    $0x7,%eax
801015f1:	29 d0                	sub    %edx,%eax
801015f3:	ba 01 00 00 00       	mov    $0x1,%edx
801015f8:	89 c1                	mov    %eax,%ecx
801015fa:	d3 e2                	shl    %cl,%edx
801015fc:	89 d0                	mov    %edx,%eax
801015fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101604:	8d 50 07             	lea    0x7(%eax),%edx
80101607:	85 c0                	test   %eax,%eax
80101609:	0f 48 c2             	cmovs  %edx,%eax
8010160c:	c1 f8 03             	sar    $0x3,%eax
8010160f:	89 c2                	mov    %eax,%edx
80101611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101614:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101619:	0f b6 c0             	movzbl %al,%eax
8010161c:	23 45 ec             	and    -0x14(%ebp),%eax
8010161f:	85 c0                	test   %eax,%eax
80101621:	75 0d                	jne    80101630 <bfree+0x94>
    panic("freeing free block");
80101623:	83 ec 0c             	sub    $0xc,%esp
80101626:	68 1b 92 10 80       	push   $0x8010921b
8010162b:	e8 36 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
80101630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101633:	8d 50 07             	lea    0x7(%eax),%edx
80101636:	85 c0                	test   %eax,%eax
80101638:	0f 48 c2             	cmovs  %edx,%eax
8010163b:	c1 f8 03             	sar    $0x3,%eax
8010163e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101641:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101646:	89 d1                	mov    %edx,%ecx
80101648:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164b:	f7 d2                	not    %edx
8010164d:	21 ca                	and    %ecx,%edx
8010164f:	89 d1                	mov    %edx,%ecx
80101651:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101654:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101658:	83 ec 0c             	sub    $0xc,%esp
8010165b:	ff 75 f4             	pushl  -0xc(%ebp)
8010165e:	e8 c8 20 00 00       	call   8010372b <log_write>
80101663:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101666:	83 ec 0c             	sub    $0xc,%esp
80101669:	ff 75 f4             	pushl  -0xc(%ebp)
8010166c:	e8 bd eb ff ff       	call   8010022e <brelse>
80101671:	83 c4 10             	add    $0x10,%esp
}
80101674:	90                   	nop
80101675:	c9                   	leave  
80101676:	c3                   	ret    

80101677 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101677:	55                   	push   %ebp
80101678:	89 e5                	mov    %esp,%ebp
8010167a:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010167d:	83 ec 08             	sub    $0x8,%esp
80101680:	68 2e 92 10 80       	push   $0x8010922e
80101685:	68 60 22 11 80       	push   $0x80112260
8010168a:	e8 99 42 00 00       	call   80105928 <initlock>
8010168f:	83 c4 10             	add    $0x10,%esp
}
80101692:	90                   	nop
80101693:	c9                   	leave  
80101694:	c3                   	ret    

80101695 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101695:	55                   	push   %ebp
80101696:	89 e5                	mov    %esp,%ebp
80101698:	83 ec 38             	sub    $0x38,%esp
8010169b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010169e:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801016a2:	8b 45 08             	mov    0x8(%ebp),%eax
801016a5:	83 ec 08             	sub    $0x8,%esp
801016a8:	8d 55 dc             	lea    -0x24(%ebp),%edx
801016ab:	52                   	push   %edx
801016ac:	50                   	push   %eax
801016ad:	e8 f6 fc ff ff       	call   801013a8 <readsb>
801016b2:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
801016b5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016bc:	e9 98 00 00 00       	jmp    80101759 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
801016c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c4:	c1 e8 03             	shr    $0x3,%eax
801016c7:	83 c0 02             	add    $0x2,%eax
801016ca:	83 ec 08             	sub    $0x8,%esp
801016cd:	50                   	push   %eax
801016ce:	ff 75 08             	pushl  0x8(%ebp)
801016d1:	e8 e0 ea ff ff       	call   801001b6 <bread>
801016d6:	83 c4 10             	add    $0x10,%esp
801016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016df:	8d 50 18             	lea    0x18(%eax),%edx
801016e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e5:	83 e0 07             	and    $0x7,%eax
801016e8:	c1 e0 06             	shl    $0x6,%eax
801016eb:	01 d0                	add    %edx,%eax
801016ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016f3:	0f b7 00             	movzwl (%eax),%eax
801016f6:	66 85 c0             	test   %ax,%ax
801016f9:	75 4c                	jne    80101747 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016fb:	83 ec 04             	sub    $0x4,%esp
801016fe:	6a 40                	push   $0x40
80101700:	6a 00                	push   $0x0
80101702:	ff 75 ec             	pushl  -0x14(%ebp)
80101705:	e8 a3 44 00 00       	call   80105bad <memset>
8010170a:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010170d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101710:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101714:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101717:	83 ec 0c             	sub    $0xc,%esp
8010171a:	ff 75 f0             	pushl  -0x10(%ebp)
8010171d:	e8 09 20 00 00       	call   8010372b <log_write>
80101722:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101725:	83 ec 0c             	sub    $0xc,%esp
80101728:	ff 75 f0             	pushl  -0x10(%ebp)
8010172b:	e8 fe ea ff ff       	call   8010022e <brelse>
80101730:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101736:	83 ec 08             	sub    $0x8,%esp
80101739:	50                   	push   %eax
8010173a:	ff 75 08             	pushl  0x8(%ebp)
8010173d:	e8 ef 00 00 00       	call   80101831 <iget>
80101742:	83 c4 10             	add    $0x10,%esp
80101745:	eb 2d                	jmp    80101774 <ialloc+0xdf>
    }
    brelse(bp);
80101747:	83 ec 0c             	sub    $0xc,%esp
8010174a:	ff 75 f0             	pushl  -0x10(%ebp)
8010174d:	e8 dc ea ff ff       	call   8010022e <brelse>
80101752:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101755:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101759:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010175c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175f:	39 c2                	cmp    %eax,%edx
80101761:	0f 87 5a ff ff ff    	ja     801016c1 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101767:	83 ec 0c             	sub    $0xc,%esp
8010176a:	68 35 92 10 80       	push   $0x80109235
8010176f:	e8 f2 ed ff ff       	call   80100566 <panic>
}
80101774:	c9                   	leave  
80101775:	c3                   	ret    

80101776 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101776:	55                   	push   %ebp
80101777:	89 e5                	mov    %esp,%ebp
80101779:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010177c:	8b 45 08             	mov    0x8(%ebp),%eax
8010177f:	8b 40 04             	mov    0x4(%eax),%eax
80101782:	c1 e8 03             	shr    $0x3,%eax
80101785:	8d 50 02             	lea    0x2(%eax),%edx
80101788:	8b 45 08             	mov    0x8(%ebp),%eax
8010178b:	8b 00                	mov    (%eax),%eax
8010178d:	83 ec 08             	sub    $0x8,%esp
80101790:	52                   	push   %edx
80101791:	50                   	push   %eax
80101792:	e8 1f ea ff ff       	call   801001b6 <bread>
80101797:	83 c4 10             	add    $0x10,%esp
8010179a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a0:	8d 50 18             	lea    0x18(%eax),%edx
801017a3:	8b 45 08             	mov    0x8(%ebp),%eax
801017a6:	8b 40 04             	mov    0x4(%eax),%eax
801017a9:	83 e0 07             	and    $0x7,%eax
801017ac:	c1 e0 06             	shl    $0x6,%eax
801017af:	01 d0                	add    %edx,%eax
801017b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017b4:	8b 45 08             	mov    0x8(%ebp),%eax
801017b7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017be:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017cb:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017cf:	8b 45 08             	mov    0x8(%ebp),%eax
801017d2:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d9:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017dd:	8b 45 08             	mov    0x8(%ebp),%eax
801017e0:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e7:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017eb:	8b 45 08             	mov    0x8(%ebp),%eax
801017ee:	8b 50 18             	mov    0x18(%eax),%edx
801017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f4:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	8d 50 1c             	lea    0x1c(%eax),%edx
801017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101800:	83 c0 0c             	add    $0xc,%eax
80101803:	83 ec 04             	sub    $0x4,%esp
80101806:	6a 34                	push   $0x34
80101808:	52                   	push   %edx
80101809:	50                   	push   %eax
8010180a:	e8 5d 44 00 00       	call   80105c6c <memmove>
8010180f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101812:	83 ec 0c             	sub    $0xc,%esp
80101815:	ff 75 f4             	pushl  -0xc(%ebp)
80101818:	e8 0e 1f 00 00       	call   8010372b <log_write>
8010181d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101820:	83 ec 0c             	sub    $0xc,%esp
80101823:	ff 75 f4             	pushl  -0xc(%ebp)
80101826:	e8 03 ea ff ff       	call   8010022e <brelse>
8010182b:	83 c4 10             	add    $0x10,%esp
}
8010182e:	90                   	nop
8010182f:	c9                   	leave  
80101830:	c3                   	ret    

80101831 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101831:	55                   	push   %ebp
80101832:	89 e5                	mov    %esp,%ebp
80101834:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101837:	83 ec 0c             	sub    $0xc,%esp
8010183a:	68 60 22 11 80       	push   $0x80112260
8010183f:	e8 06 41 00 00       	call   8010594a <acquire>
80101844:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101847:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010184e:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101855:	eb 5d                	jmp    801018b4 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185a:	8b 40 08             	mov    0x8(%eax),%eax
8010185d:	85 c0                	test   %eax,%eax
8010185f:	7e 39                	jle    8010189a <iget+0x69>
80101861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101864:	8b 00                	mov    (%eax),%eax
80101866:	3b 45 08             	cmp    0x8(%ebp),%eax
80101869:	75 2f                	jne    8010189a <iget+0x69>
8010186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186e:	8b 40 04             	mov    0x4(%eax),%eax
80101871:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101874:	75 24                	jne    8010189a <iget+0x69>
      ip->ref++;
80101876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101879:	8b 40 08             	mov    0x8(%eax),%eax
8010187c:	8d 50 01             	lea    0x1(%eax),%edx
8010187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101882:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101885:	83 ec 0c             	sub    $0xc,%esp
80101888:	68 60 22 11 80       	push   $0x80112260
8010188d:	e8 1f 41 00 00       	call   801059b1 <release>
80101892:	83 c4 10             	add    $0x10,%esp
      return ip;
80101895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101898:	eb 74                	jmp    8010190e <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010189a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010189e:	75 10                	jne    801018b0 <iget+0x7f>
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	8b 40 08             	mov    0x8(%eax),%eax
801018a6:	85 c0                	test   %eax,%eax
801018a8:	75 06                	jne    801018b0 <iget+0x7f>
      empty = ip;
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018b0:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018b4:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801018bb:	72 9a                	jb     80101857 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c1:	75 0d                	jne    801018d0 <iget+0x9f>
    panic("iget: no inodes");
801018c3:	83 ec 0c             	sub    $0xc,%esp
801018c6:	68 47 92 10 80       	push   $0x80109247
801018cb:	e8 96 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d9:	8b 55 08             	mov    0x8(%ebp),%edx
801018dc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e1:	8b 55 0c             	mov    0xc(%ebp),%edx
801018e4:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018fb:	83 ec 0c             	sub    $0xc,%esp
801018fe:	68 60 22 11 80       	push   $0x80112260
80101903:	e8 a9 40 00 00       	call   801059b1 <release>
80101908:	83 c4 10             	add    $0x10,%esp

  return ip;
8010190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010190e:	c9                   	leave  
8010190f:	c3                   	ret    

80101910 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101910:	55                   	push   %ebp
80101911:	89 e5                	mov    %esp,%ebp
80101913:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101916:	83 ec 0c             	sub    $0xc,%esp
80101919:	68 60 22 11 80       	push   $0x80112260
8010191e:	e8 27 40 00 00       	call   8010594a <acquire>
80101923:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101926:	8b 45 08             	mov    0x8(%ebp),%eax
80101929:	8b 40 08             	mov    0x8(%eax),%eax
8010192c:	8d 50 01             	lea    0x1(%eax),%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101935:	83 ec 0c             	sub    $0xc,%esp
80101938:	68 60 22 11 80       	push   $0x80112260
8010193d:	e8 6f 40 00 00       	call   801059b1 <release>
80101942:	83 c4 10             	add    $0x10,%esp
  return ip;
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101948:	c9                   	leave  
80101949:	c3                   	ret    

8010194a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010194a:	55                   	push   %ebp
8010194b:	89 e5                	mov    %esp,%ebp
8010194d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101950:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101954:	74 0a                	je     80101960 <ilock+0x16>
80101956:	8b 45 08             	mov    0x8(%ebp),%eax
80101959:	8b 40 08             	mov    0x8(%eax),%eax
8010195c:	85 c0                	test   %eax,%eax
8010195e:	7f 0d                	jg     8010196d <ilock+0x23>
    panic("ilock");
80101960:	83 ec 0c             	sub    $0xc,%esp
80101963:	68 57 92 10 80       	push   $0x80109257
80101968:	e8 f9 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010196d:	83 ec 0c             	sub    $0xc,%esp
80101970:	68 60 22 11 80       	push   $0x80112260
80101975:	e8 d0 3f 00 00       	call   8010594a <acquire>
8010197a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010197d:	eb 13                	jmp    80101992 <ilock+0x48>
    sleep(ip, &icache.lock);
8010197f:	83 ec 08             	sub    $0x8,%esp
80101982:	68 60 22 11 80       	push   $0x80112260
80101987:	ff 75 08             	pushl  0x8(%ebp)
8010198a:	e8 ff 37 00 00       	call   8010518e <sleep>
8010198f:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101992:	8b 45 08             	mov    0x8(%ebp),%eax
80101995:	8b 40 0c             	mov    0xc(%eax),%eax
80101998:	83 e0 01             	and    $0x1,%eax
8010199b:	85 c0                	test   %eax,%eax
8010199d:	75 e0                	jne    8010197f <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
8010199f:	8b 45 08             	mov    0x8(%ebp),%eax
801019a2:	8b 40 0c             	mov    0xc(%eax),%eax
801019a5:	83 c8 01             	or     $0x1,%eax
801019a8:	89 c2                	mov    %eax,%edx
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	68 60 22 11 80       	push   $0x80112260
801019b8:	e8 f4 3f 00 00       	call   801059b1 <release>
801019bd:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	8b 40 0c             	mov    0xc(%eax),%eax
801019c6:	83 e0 02             	and    $0x2,%eax
801019c9:	85 c0                	test   %eax,%eax
801019cb:	0f 85 ce 00 00 00    	jne    80101a9f <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801019d1:	8b 45 08             	mov    0x8(%ebp),%eax
801019d4:	8b 40 04             	mov    0x4(%eax),%eax
801019d7:	c1 e8 03             	shr    $0x3,%eax
801019da:	8d 50 02             	lea    0x2(%eax),%edx
801019dd:	8b 45 08             	mov    0x8(%ebp),%eax
801019e0:	8b 00                	mov    (%eax),%eax
801019e2:	83 ec 08             	sub    $0x8,%esp
801019e5:	52                   	push   %edx
801019e6:	50                   	push   %eax
801019e7:	e8 ca e7 ff ff       	call   801001b6 <bread>
801019ec:	83 c4 10             	add    $0x10,%esp
801019ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f5:	8d 50 18             	lea    0x18(%eax),%edx
801019f8:	8b 45 08             	mov    0x8(%ebp),%eax
801019fb:	8b 40 04             	mov    0x4(%eax),%eax
801019fe:	83 e0 07             	and    $0x7,%eax
80101a01:	c1 e0 06             	shl    $0x6,%eax
80101a04:	01 d0                	add    %edx,%eax
80101a06:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a0c:	0f b7 10             	movzwl (%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a19:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a20:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a27:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a35:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a43:	8b 50 08             	mov    0x8(%eax),%edx
80101a46:	8b 45 08             	mov    0x8(%ebp),%eax
80101a49:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4f:	8d 50 0c             	lea    0xc(%eax),%edx
80101a52:	8b 45 08             	mov    0x8(%ebp),%eax
80101a55:	83 c0 1c             	add    $0x1c,%eax
80101a58:	83 ec 04             	sub    $0x4,%esp
80101a5b:	6a 34                	push   $0x34
80101a5d:	52                   	push   %edx
80101a5e:	50                   	push   %eax
80101a5f:	e8 08 42 00 00       	call   80105c6c <memmove>
80101a64:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	ff 75 f4             	pushl  -0xc(%ebp)
80101a6d:	e8 bc e7 ff ff       	call   8010022e <brelse>
80101a72:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	8b 40 0c             	mov    0xc(%eax),%eax
80101a7b:	83 c8 02             	or     $0x2,%eax
80101a7e:	89 c2                	mov    %eax,%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a86:	8b 45 08             	mov    0x8(%ebp),%eax
80101a89:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a8d:	66 85 c0             	test   %ax,%ax
80101a90:	75 0d                	jne    80101a9f <ilock+0x155>
      panic("ilock: no type");
80101a92:	83 ec 0c             	sub    $0xc,%esp
80101a95:	68 5d 92 10 80       	push   $0x8010925d
80101a9a:	e8 c7 ea ff ff       	call   80100566 <panic>
  }
}
80101a9f:	90                   	nop
80101aa0:	c9                   	leave  
80101aa1:	c3                   	ret    

80101aa2 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101aa2:	55                   	push   %ebp
80101aa3:	89 e5                	mov    %esp,%ebp
80101aa5:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101aa8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aac:	74 17                	je     80101ac5 <iunlock+0x23>
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab4:	83 e0 01             	and    $0x1,%eax
80101ab7:	85 c0                	test   %eax,%eax
80101ab9:	74 0a                	je     80101ac5 <iunlock+0x23>
80101abb:	8b 45 08             	mov    0x8(%ebp),%eax
80101abe:	8b 40 08             	mov    0x8(%eax),%eax
80101ac1:	85 c0                	test   %eax,%eax
80101ac3:	7f 0d                	jg     80101ad2 <iunlock+0x30>
    panic("iunlock");
80101ac5:	83 ec 0c             	sub    $0xc,%esp
80101ac8:	68 6c 92 10 80       	push   $0x8010926c
80101acd:	e8 94 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101ad2:	83 ec 0c             	sub    $0xc,%esp
80101ad5:	68 60 22 11 80       	push   $0x80112260
80101ada:	e8 6b 3e 00 00       	call   8010594a <acquire>
80101adf:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	8b 40 0c             	mov    0xc(%eax),%eax
80101ae8:	83 e0 fe             	and    $0xfffffffe,%eax
80101aeb:	89 c2                	mov    %eax,%edx
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101af3:	83 ec 0c             	sub    $0xc,%esp
80101af6:	ff 75 08             	pushl  0x8(%ebp)
80101af9:	e8 9c 37 00 00       	call   8010529a <wakeup>
80101afe:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b01:	83 ec 0c             	sub    $0xc,%esp
80101b04:	68 60 22 11 80       	push   $0x80112260
80101b09:	e8 a3 3e 00 00       	call   801059b1 <release>
80101b0e:	83 c4 10             	add    $0x10,%esp
}
80101b11:	90                   	nop
80101b12:	c9                   	leave  
80101b13:	c3                   	ret    

80101b14 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b14:	55                   	push   %ebp
80101b15:	89 e5                	mov    %esp,%ebp
80101b17:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	68 60 22 11 80       	push   $0x80112260
80101b22:	e8 23 3e 00 00       	call   8010594a <acquire>
80101b27:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2d:	8b 40 08             	mov    0x8(%eax),%eax
80101b30:	83 f8 01             	cmp    $0x1,%eax
80101b33:	0f 85 a9 00 00 00    	jne    80101be2 <iput+0xce>
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	8b 40 0c             	mov    0xc(%eax),%eax
80101b3f:	83 e0 02             	and    $0x2,%eax
80101b42:	85 c0                	test   %eax,%eax
80101b44:	0f 84 98 00 00 00    	je     80101be2 <iput+0xce>
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b51:	66 85 c0             	test   %ax,%ax
80101b54:	0f 85 88 00 00 00    	jne    80101be2 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	8b 40 0c             	mov    0xc(%eax),%eax
80101b60:	83 e0 01             	and    $0x1,%eax
80101b63:	85 c0                	test   %eax,%eax
80101b65:	74 0d                	je     80101b74 <iput+0x60>
      panic("iput busy");
80101b67:	83 ec 0c             	sub    $0xc,%esp
80101b6a:	68 74 92 10 80       	push   $0x80109274
80101b6f:	e8 f2 e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b74:	8b 45 08             	mov    0x8(%ebp),%eax
80101b77:	8b 40 0c             	mov    0xc(%eax),%eax
80101b7a:	83 c8 01             	or     $0x1,%eax
80101b7d:	89 c2                	mov    %eax,%edx
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b85:	83 ec 0c             	sub    $0xc,%esp
80101b88:	68 60 22 11 80       	push   $0x80112260
80101b8d:	e8 1f 3e 00 00       	call   801059b1 <release>
80101b92:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b95:	83 ec 0c             	sub    $0xc,%esp
80101b98:	ff 75 08             	pushl  0x8(%ebp)
80101b9b:	e8 a8 01 00 00       	call   80101d48 <itrunc>
80101ba0:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bac:	83 ec 0c             	sub    $0xc,%esp
80101baf:	ff 75 08             	pushl  0x8(%ebp)
80101bb2:	e8 bf fb ff ff       	call   80101776 <iupdate>
80101bb7:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bba:	83 ec 0c             	sub    $0xc,%esp
80101bbd:	68 60 22 11 80       	push   $0x80112260
80101bc2:	e8 83 3d 00 00       	call   8010594a <acquire>
80101bc7:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bd4:	83 ec 0c             	sub    $0xc,%esp
80101bd7:	ff 75 08             	pushl  0x8(%ebp)
80101bda:	e8 bb 36 00 00       	call   8010529a <wakeup>
80101bdf:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101be2:	8b 45 08             	mov    0x8(%ebp),%eax
80101be5:	8b 40 08             	mov    0x8(%eax),%eax
80101be8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101beb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bee:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 22 11 80       	push   $0x80112260
80101bf9:	e8 b3 3d 00 00       	call   801059b1 <release>
80101bfe:	83 c4 10             	add    $0x10,%esp
}
80101c01:	90                   	nop
80101c02:	c9                   	leave  
80101c03:	c3                   	ret    

80101c04 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c04:	55                   	push   %ebp
80101c05:	89 e5                	mov    %esp,%ebp
80101c07:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c0a:	83 ec 0c             	sub    $0xc,%esp
80101c0d:	ff 75 08             	pushl  0x8(%ebp)
80101c10:	e8 8d fe ff ff       	call   80101aa2 <iunlock>
80101c15:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c18:	83 ec 0c             	sub    $0xc,%esp
80101c1b:	ff 75 08             	pushl  0x8(%ebp)
80101c1e:	e8 f1 fe ff ff       	call   80101b14 <iput>
80101c23:	83 c4 10             	add    $0x10,%esp
}
80101c26:	90                   	nop
80101c27:	c9                   	leave  
80101c28:	c3                   	ret    

80101c29 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c29:	55                   	push   %ebp
80101c2a:	89 e5                	mov    %esp,%ebp
80101c2c:	53                   	push   %ebx
80101c2d:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c30:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c34:	77 42                	ja     80101c78 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c36:	8b 45 08             	mov    0x8(%ebp),%eax
80101c39:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c3c:	83 c2 04             	add    $0x4,%edx
80101c3f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c4a:	75 24                	jne    80101c70 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 00                	mov    (%eax),%eax
80101c51:	83 ec 0c             	sub    $0xc,%esp
80101c54:	50                   	push   %eax
80101c55:	e8 e4 f7 ff ff       	call   8010143e <balloc>
80101c5a:	83 c4 10             	add    $0x10,%esp
80101c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c60:	8b 45 08             	mov    0x8(%ebp),%eax
80101c63:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c66:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c73:	e9 cb 00 00 00       	jmp    80101d43 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c78:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c7c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c80:	0f 87 b0 00 00 00    	ja     80101d36 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c93:	75 1d                	jne    80101cb2 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c95:	8b 45 08             	mov    0x8(%ebp),%eax
80101c98:	8b 00                	mov    (%eax),%eax
80101c9a:	83 ec 0c             	sub    $0xc,%esp
80101c9d:	50                   	push   %eax
80101c9e:	e8 9b f7 ff ff       	call   8010143e <balloc>
80101ca3:	83 c4 10             	add    $0x10,%esp
80101ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101caf:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	8b 00                	mov    (%eax),%eax
80101cb7:	83 ec 08             	sub    $0x8,%esp
80101cba:	ff 75 f4             	pushl  -0xc(%ebp)
80101cbd:	50                   	push   %eax
80101cbe:	e8 f3 e4 ff ff       	call   801001b6 <bread>
80101cc3:	83 c4 10             	add    $0x10,%esp
80101cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ccc:	83 c0 18             	add    $0x18,%eax
80101ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cd5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cdf:	01 d0                	add    %edx,%eax
80101ce1:	8b 00                	mov    (%eax),%eax
80101ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cea:	75 37                	jne    80101d23 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101cec:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cff:	8b 00                	mov    (%eax),%eax
80101d01:	83 ec 0c             	sub    $0xc,%esp
80101d04:	50                   	push   %eax
80101d05:	e8 34 f7 ff ff       	call   8010143e <balloc>
80101d0a:	83 c4 10             	add    $0x10,%esp
80101d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d13:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	ff 75 f0             	pushl  -0x10(%ebp)
80101d1b:	e8 0b 1a 00 00       	call   8010372b <log_write>
80101d20:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d23:	83 ec 0c             	sub    $0xc,%esp
80101d26:	ff 75 f0             	pushl  -0x10(%ebp)
80101d29:	e8 00 e5 ff ff       	call   8010022e <brelse>
80101d2e:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d34:	eb 0d                	jmp    80101d43 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d36:	83 ec 0c             	sub    $0xc,%esp
80101d39:	68 7e 92 10 80       	push   $0x8010927e
80101d3e:	e8 23 e8 ff ff       	call   80100566 <panic>
}
80101d43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d46:	c9                   	leave  
80101d47:	c3                   	ret    

80101d48 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d48:	55                   	push   %ebp
80101d49:	89 e5                	mov    %esp,%ebp
80101d4b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d55:	eb 45                	jmp    80101d9c <itrunc+0x54>
    if(ip->addrs[i]){
80101d57:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d5d:	83 c2 04             	add    $0x4,%edx
80101d60:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d64:	85 c0                	test   %eax,%eax
80101d66:	74 30                	je     80101d98 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	83 c2 04             	add    $0x4,%edx
80101d71:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d75:	8b 55 08             	mov    0x8(%ebp),%edx
80101d78:	8b 12                	mov    (%edx),%edx
80101d7a:	83 ec 08             	sub    $0x8,%esp
80101d7d:	50                   	push   %eax
80101d7e:	52                   	push   %edx
80101d7f:	e8 18 f8 ff ff       	call   8010159c <bfree>
80101d84:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8d:	83 c2 04             	add    $0x4,%edx
80101d90:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d97:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d9c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101da0:	7e b5                	jle    80101d57 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101da8:	85 c0                	test   %eax,%eax
80101daa:	0f 84 a1 00 00 00    	je     80101e51 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	8b 00                	mov    (%eax),%eax
80101dbb:	83 ec 08             	sub    $0x8,%esp
80101dbe:	52                   	push   %edx
80101dbf:	50                   	push   %eax
80101dc0:	e8 f1 e3 ff ff       	call   801001b6 <bread>
80101dc5:	83 c4 10             	add    $0x10,%esp
80101dc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dce:	83 c0 18             	add    $0x18,%eax
80101dd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dd4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ddb:	eb 3c                	jmp    80101e19 <itrunc+0xd1>
      if(a[j])
80101ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101de7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dea:	01 d0                	add    %edx,%eax
80101dec:	8b 00                	mov    (%eax),%eax
80101dee:	85 c0                	test   %eax,%eax
80101df0:	74 23                	je     80101e15 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dff:	01 d0                	add    %edx,%eax
80101e01:	8b 00                	mov    (%eax),%eax
80101e03:	8b 55 08             	mov    0x8(%ebp),%edx
80101e06:	8b 12                	mov    (%edx),%edx
80101e08:	83 ec 08             	sub    $0x8,%esp
80101e0b:	50                   	push   %eax
80101e0c:	52                   	push   %edx
80101e0d:	e8 8a f7 ff ff       	call   8010159c <bfree>
80101e12:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e15:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1c:	83 f8 7f             	cmp    $0x7f,%eax
80101e1f:	76 bc                	jbe    80101ddd <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e21:	83 ec 0c             	sub    $0xc,%esp
80101e24:	ff 75 ec             	pushl  -0x14(%ebp)
80101e27:	e8 02 e4 ff ff       	call   8010022e <brelse>
80101e2c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e32:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e35:	8b 55 08             	mov    0x8(%ebp),%edx
80101e38:	8b 12                	mov    (%edx),%edx
80101e3a:	83 ec 08             	sub    $0x8,%esp
80101e3d:	50                   	push   %eax
80101e3e:	52                   	push   %edx
80101e3f:	e8 58 f7 ff ff       	call   8010159c <bfree>
80101e44:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e47:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e5b:	83 ec 0c             	sub    $0xc,%esp
80101e5e:	ff 75 08             	pushl  0x8(%ebp)
80101e61:	e8 10 f9 ff ff       	call   80101776 <iupdate>
80101e66:	83 c4 10             	add    $0x10,%esp
}
80101e69:	90                   	nop
80101e6a:	c9                   	leave  
80101e6b:	c3                   	ret    

80101e6c <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e6c:	55                   	push   %ebp
80101e6d:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 00                	mov    (%eax),%eax
80101e74:	89 c2                	mov    %eax,%edx
80101e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e79:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7f:	8b 50 04             	mov    0x4(%eax),%edx
80101e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e85:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e92:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9f:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea6:	8b 50 18             	mov    0x18(%eax),%edx
80101ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eac:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eaf:	90                   	nop
80101eb0:	5d                   	pop    %ebp
80101eb1:	c3                   	ret    

80101eb2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101eb2:	55                   	push   %ebp
80101eb3:	89 e5                	mov    %esp,%ebp
80101eb5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ebf:	66 83 f8 03          	cmp    $0x3,%ax
80101ec3:	75 5c                	jne    80101f21 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ecc:	66 85 c0             	test   %ax,%ax
80101ecf:	78 20                	js     80101ef1 <readi+0x3f>
80101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed8:	66 83 f8 09          	cmp    $0x9,%ax
80101edc:	7f 13                	jg     80101ef1 <readi+0x3f>
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee5:	98                   	cwtl   
80101ee6:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101eed:	85 c0                	test   %eax,%eax
80101eef:	75 0a                	jne    80101efb <readi+0x49>
      return -1;
80101ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ef6:	e9 0c 01 00 00       	jmp    80102007 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f02:	98                   	cwtl   
80101f03:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101f0a:	8b 55 14             	mov    0x14(%ebp),%edx
80101f0d:	83 ec 04             	sub    $0x4,%esp
80101f10:	52                   	push   %edx
80101f11:	ff 75 0c             	pushl  0xc(%ebp)
80101f14:	ff 75 08             	pushl  0x8(%ebp)
80101f17:	ff d0                	call   *%eax
80101f19:	83 c4 10             	add    $0x10,%esp
80101f1c:	e9 e6 00 00 00       	jmp    80102007 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	8b 40 18             	mov    0x18(%eax),%eax
80101f27:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f2a:	72 0d                	jb     80101f39 <readi+0x87>
80101f2c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f2f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f32:	01 d0                	add    %edx,%eax
80101f34:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f37:	73 0a                	jae    80101f43 <readi+0x91>
    return -1;
80101f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f3e:	e9 c4 00 00 00       	jmp    80102007 <readi+0x155>
  if(off + n > ip->size)
80101f43:	8b 55 10             	mov    0x10(%ebp),%edx
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
80101f49:	01 c2                	add    %eax,%edx
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 40 18             	mov    0x18(%eax),%eax
80101f51:	39 c2                	cmp    %eax,%edx
80101f53:	76 0c                	jbe    80101f61 <readi+0xaf>
    n = ip->size - off;
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	8b 40 18             	mov    0x18(%eax),%eax
80101f5b:	2b 45 10             	sub    0x10(%ebp),%eax
80101f5e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f68:	e9 8b 00 00 00       	jmp    80101ff8 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f6d:	8b 45 10             	mov    0x10(%ebp),%eax
80101f70:	c1 e8 09             	shr    $0x9,%eax
80101f73:	83 ec 08             	sub    $0x8,%esp
80101f76:	50                   	push   %eax
80101f77:	ff 75 08             	pushl  0x8(%ebp)
80101f7a:	e8 aa fc ff ff       	call   80101c29 <bmap>
80101f7f:	83 c4 10             	add    $0x10,%esp
80101f82:	89 c2                	mov    %eax,%edx
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	8b 00                	mov    (%eax),%eax
80101f89:	83 ec 08             	sub    $0x8,%esp
80101f8c:	52                   	push   %edx
80101f8d:	50                   	push   %eax
80101f8e:	e8 23 e2 ff ff       	call   801001b6 <bread>
80101f93:	83 c4 10             	add    $0x10,%esp
80101f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fa1:	ba 00 02 00 00       	mov    $0x200,%edx
80101fa6:	29 c2                	sub    %eax,%edx
80101fa8:	8b 45 14             	mov    0x14(%ebp),%eax
80101fab:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fae:	39 c2                	cmp    %eax,%edx
80101fb0:	0f 46 c2             	cmovbe %edx,%eax
80101fb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb9:	8d 50 18             	lea    0x18(%eax),%edx
80101fbc:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc4:	01 d0                	add    %edx,%eax
80101fc6:	83 ec 04             	sub    $0x4,%esp
80101fc9:	ff 75 ec             	pushl  -0x14(%ebp)
80101fcc:	50                   	push   %eax
80101fcd:	ff 75 0c             	pushl  0xc(%ebp)
80101fd0:	e8 97 3c 00 00       	call   80105c6c <memmove>
80101fd5:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fd8:	83 ec 0c             	sub    $0xc,%esp
80101fdb:	ff 75 f0             	pushl  -0x10(%ebp)
80101fde:	e8 4b e2 ff ff       	call   8010022e <brelse>
80101fe3:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fe6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe9:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fef:	01 45 10             	add    %eax,0x10(%ebp)
80101ff2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff5:	01 45 0c             	add    %eax,0xc(%ebp)
80101ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ffb:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ffe:	0f 82 69 ff ff ff    	jb     80101f6d <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102004:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102007:	c9                   	leave  
80102008:	c3                   	ret    

80102009 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102009:	55                   	push   %ebp
8010200a:	89 e5                	mov    %esp,%ebp
8010200c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102016:	66 83 f8 03          	cmp    $0x3,%ax
8010201a:	75 5c                	jne    80102078 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010201c:	8b 45 08             	mov    0x8(%ebp),%eax
8010201f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102023:	66 85 c0             	test   %ax,%ax
80102026:	78 20                	js     80102048 <writei+0x3f>
80102028:	8b 45 08             	mov    0x8(%ebp),%eax
8010202b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010202f:	66 83 f8 09          	cmp    $0x9,%ax
80102033:	7f 13                	jg     80102048 <writei+0x3f>
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010203c:	98                   	cwtl   
8010203d:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102044:	85 c0                	test   %eax,%eax
80102046:	75 0a                	jne    80102052 <writei+0x49>
      return -1;
80102048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010204d:	e9 3d 01 00 00       	jmp    8010218f <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102059:	98                   	cwtl   
8010205a:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102061:	8b 55 14             	mov    0x14(%ebp),%edx
80102064:	83 ec 04             	sub    $0x4,%esp
80102067:	52                   	push   %edx
80102068:	ff 75 0c             	pushl  0xc(%ebp)
8010206b:	ff 75 08             	pushl  0x8(%ebp)
8010206e:	ff d0                	call   *%eax
80102070:	83 c4 10             	add    $0x10,%esp
80102073:	e9 17 01 00 00       	jmp    8010218f <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	8b 40 18             	mov    0x18(%eax),%eax
8010207e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102081:	72 0d                	jb     80102090 <writei+0x87>
80102083:	8b 55 10             	mov    0x10(%ebp),%edx
80102086:	8b 45 14             	mov    0x14(%ebp),%eax
80102089:	01 d0                	add    %edx,%eax
8010208b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010208e:	73 0a                	jae    8010209a <writei+0x91>
    return -1;
80102090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102095:	e9 f5 00 00 00       	jmp    8010218f <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010209a:	8b 55 10             	mov    0x10(%ebp),%edx
8010209d:	8b 45 14             	mov    0x14(%ebp),%eax
801020a0:	01 d0                	add    %edx,%eax
801020a2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020a7:	76 0a                	jbe    801020b3 <writei+0xaa>
    return -1;
801020a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ae:	e9 dc 00 00 00       	jmp    8010218f <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020ba:	e9 99 00 00 00       	jmp    80102158 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020bf:	8b 45 10             	mov    0x10(%ebp),%eax
801020c2:	c1 e8 09             	shr    $0x9,%eax
801020c5:	83 ec 08             	sub    $0x8,%esp
801020c8:	50                   	push   %eax
801020c9:	ff 75 08             	pushl  0x8(%ebp)
801020cc:	e8 58 fb ff ff       	call   80101c29 <bmap>
801020d1:	83 c4 10             	add    $0x10,%esp
801020d4:	89 c2                	mov    %eax,%edx
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	8b 00                	mov    (%eax),%eax
801020db:	83 ec 08             	sub    $0x8,%esp
801020de:	52                   	push   %edx
801020df:	50                   	push   %eax
801020e0:	e8 d1 e0 ff ff       	call   801001b6 <bread>
801020e5:	83 c4 10             	add    $0x10,%esp
801020e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020eb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ee:	25 ff 01 00 00       	and    $0x1ff,%eax
801020f3:	ba 00 02 00 00       	mov    $0x200,%edx
801020f8:	29 c2                	sub    %eax,%edx
801020fa:	8b 45 14             	mov    0x14(%ebp),%eax
801020fd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102100:	39 c2                	cmp    %eax,%edx
80102102:	0f 46 c2             	cmovbe %edx,%eax
80102105:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010210b:	8d 50 18             	lea    0x18(%eax),%edx
8010210e:	8b 45 10             	mov    0x10(%ebp),%eax
80102111:	25 ff 01 00 00       	and    $0x1ff,%eax
80102116:	01 d0                	add    %edx,%eax
80102118:	83 ec 04             	sub    $0x4,%esp
8010211b:	ff 75 ec             	pushl  -0x14(%ebp)
8010211e:	ff 75 0c             	pushl  0xc(%ebp)
80102121:	50                   	push   %eax
80102122:	e8 45 3b 00 00       	call   80105c6c <memmove>
80102127:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010212a:	83 ec 0c             	sub    $0xc,%esp
8010212d:	ff 75 f0             	pushl  -0x10(%ebp)
80102130:	e8 f6 15 00 00       	call   8010372b <log_write>
80102135:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102138:	83 ec 0c             	sub    $0xc,%esp
8010213b:	ff 75 f0             	pushl  -0x10(%ebp)
8010213e:	e8 eb e0 ff ff       	call   8010022e <brelse>
80102143:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102146:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102149:	01 45 f4             	add    %eax,-0xc(%ebp)
8010214c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010214f:	01 45 10             	add    %eax,0x10(%ebp)
80102152:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102155:	01 45 0c             	add    %eax,0xc(%ebp)
80102158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010215b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010215e:	0f 82 5b ff ff ff    	jb     801020bf <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102164:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102168:	74 22                	je     8010218c <writei+0x183>
8010216a:	8b 45 08             	mov    0x8(%ebp),%eax
8010216d:	8b 40 18             	mov    0x18(%eax),%eax
80102170:	3b 45 10             	cmp    0x10(%ebp),%eax
80102173:	73 17                	jae    8010218c <writei+0x183>
    ip->size = off;
80102175:	8b 45 08             	mov    0x8(%ebp),%eax
80102178:	8b 55 10             	mov    0x10(%ebp),%edx
8010217b:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010217e:	83 ec 0c             	sub    $0xc,%esp
80102181:	ff 75 08             	pushl  0x8(%ebp)
80102184:	e8 ed f5 ff ff       	call   80101776 <iupdate>
80102189:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010218c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010218f:	c9                   	leave  
80102190:	c3                   	ret    

80102191 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102191:	55                   	push   %ebp
80102192:	89 e5                	mov    %esp,%ebp
80102194:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102197:	83 ec 04             	sub    $0x4,%esp
8010219a:	6a 0e                	push   $0xe
8010219c:	ff 75 0c             	pushl  0xc(%ebp)
8010219f:	ff 75 08             	pushl  0x8(%ebp)
801021a2:	e8 5b 3b 00 00       	call   80105d02 <strncmp>
801021a7:	83 c4 10             	add    $0x10,%esp
}
801021aa:	c9                   	leave  
801021ab:	c3                   	ret    

801021ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021ac:	55                   	push   %ebp
801021ad:	89 e5                	mov    %esp,%ebp
801021af:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021b2:	8b 45 08             	mov    0x8(%ebp),%eax
801021b5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021b9:	66 83 f8 01          	cmp    $0x1,%ax
801021bd:	74 0d                	je     801021cc <dirlookup+0x20>
    panic("dirlookup not DIR");
801021bf:	83 ec 0c             	sub    $0xc,%esp
801021c2:	68 91 92 10 80       	push   $0x80109291
801021c7:	e8 9a e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021d3:	eb 7b                	jmp    80102250 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021d5:	6a 10                	push   $0x10
801021d7:	ff 75 f4             	pushl  -0xc(%ebp)
801021da:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021dd:	50                   	push   %eax
801021de:	ff 75 08             	pushl  0x8(%ebp)
801021e1:	e8 cc fc ff ff       	call   80101eb2 <readi>
801021e6:	83 c4 10             	add    $0x10,%esp
801021e9:	83 f8 10             	cmp    $0x10,%eax
801021ec:	74 0d                	je     801021fb <dirlookup+0x4f>
      panic("dirlink read");
801021ee:	83 ec 0c             	sub    $0xc,%esp
801021f1:	68 a3 92 10 80       	push   $0x801092a3
801021f6:	e8 6b e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021fb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021ff:	66 85 c0             	test   %ax,%ax
80102202:	74 47                	je     8010224b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102204:	83 ec 08             	sub    $0x8,%esp
80102207:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010220a:	83 c0 02             	add    $0x2,%eax
8010220d:	50                   	push   %eax
8010220e:	ff 75 0c             	pushl  0xc(%ebp)
80102211:	e8 7b ff ff ff       	call   80102191 <namecmp>
80102216:	83 c4 10             	add    $0x10,%esp
80102219:	85 c0                	test   %eax,%eax
8010221b:	75 2f                	jne    8010224c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010221d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102221:	74 08                	je     8010222b <dirlookup+0x7f>
        *poff = off;
80102223:	8b 45 10             	mov    0x10(%ebp),%eax
80102226:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102229:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010222b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010222f:	0f b7 c0             	movzwl %ax,%eax
80102232:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102235:	8b 45 08             	mov    0x8(%ebp),%eax
80102238:	8b 00                	mov    (%eax),%eax
8010223a:	83 ec 08             	sub    $0x8,%esp
8010223d:	ff 75 f0             	pushl  -0x10(%ebp)
80102240:	50                   	push   %eax
80102241:	e8 eb f5 ff ff       	call   80101831 <iget>
80102246:	83 c4 10             	add    $0x10,%esp
80102249:	eb 19                	jmp    80102264 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010224b:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010224c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	8b 40 18             	mov    0x18(%eax),%eax
80102256:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102259:	0f 87 76 ff ff ff    	ja     801021d5 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010225f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102264:	c9                   	leave  
80102265:	c3                   	ret    

80102266 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102266:	55                   	push   %ebp
80102267:	89 e5                	mov    %esp,%ebp
80102269:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010226c:	83 ec 04             	sub    $0x4,%esp
8010226f:	6a 00                	push   $0x0
80102271:	ff 75 0c             	pushl  0xc(%ebp)
80102274:	ff 75 08             	pushl  0x8(%ebp)
80102277:	e8 30 ff ff ff       	call   801021ac <dirlookup>
8010227c:	83 c4 10             	add    $0x10,%esp
8010227f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102282:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102286:	74 18                	je     801022a0 <dirlink+0x3a>
    iput(ip);
80102288:	83 ec 0c             	sub    $0xc,%esp
8010228b:	ff 75 f0             	pushl  -0x10(%ebp)
8010228e:	e8 81 f8 ff ff       	call   80101b14 <iput>
80102293:	83 c4 10             	add    $0x10,%esp
    return -1;
80102296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010229b:	e9 9c 00 00 00       	jmp    8010233c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a7:	eb 39                	jmp    801022e2 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ac:	6a 10                	push   $0x10
801022ae:	50                   	push   %eax
801022af:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022b2:	50                   	push   %eax
801022b3:	ff 75 08             	pushl  0x8(%ebp)
801022b6:	e8 f7 fb ff ff       	call   80101eb2 <readi>
801022bb:	83 c4 10             	add    $0x10,%esp
801022be:	83 f8 10             	cmp    $0x10,%eax
801022c1:	74 0d                	je     801022d0 <dirlink+0x6a>
      panic("dirlink read");
801022c3:	83 ec 0c             	sub    $0xc,%esp
801022c6:	68 a3 92 10 80       	push   $0x801092a3
801022cb:	e8 96 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022d0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022d4:	66 85 c0             	test   %ax,%ax
801022d7:	74 18                	je     801022f1 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022dc:	83 c0 10             	add    $0x10,%eax
801022df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022e2:	8b 45 08             	mov    0x8(%ebp),%eax
801022e5:	8b 50 18             	mov    0x18(%eax),%edx
801022e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022eb:	39 c2                	cmp    %eax,%edx
801022ed:	77 ba                	ja     801022a9 <dirlink+0x43>
801022ef:	eb 01                	jmp    801022f2 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022f1:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022f2:	83 ec 04             	sub    $0x4,%esp
801022f5:	6a 0e                	push   $0xe
801022f7:	ff 75 0c             	pushl  0xc(%ebp)
801022fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022fd:	83 c0 02             	add    $0x2,%eax
80102300:	50                   	push   %eax
80102301:	e8 52 3a 00 00       	call   80105d58 <strncpy>
80102306:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102309:	8b 45 10             	mov    0x10(%ebp),%eax
8010230c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102313:	6a 10                	push   $0x10
80102315:	50                   	push   %eax
80102316:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102319:	50                   	push   %eax
8010231a:	ff 75 08             	pushl  0x8(%ebp)
8010231d:	e8 e7 fc ff ff       	call   80102009 <writei>
80102322:	83 c4 10             	add    $0x10,%esp
80102325:	83 f8 10             	cmp    $0x10,%eax
80102328:	74 0d                	je     80102337 <dirlink+0xd1>
    panic("dirlink");
8010232a:	83 ec 0c             	sub    $0xc,%esp
8010232d:	68 b0 92 10 80       	push   $0x801092b0
80102332:	e8 2f e2 ff ff       	call   80100566 <panic>

  return 0;
80102337:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010233c:	c9                   	leave  
8010233d:	c3                   	ret    

8010233e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010233e:	55                   	push   %ebp
8010233f:	89 e5                	mov    %esp,%ebp
80102341:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102344:	eb 04                	jmp    8010234a <skipelem+0xc>
    path++;
80102346:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010234a:	8b 45 08             	mov    0x8(%ebp),%eax
8010234d:	0f b6 00             	movzbl (%eax),%eax
80102350:	3c 2f                	cmp    $0x2f,%al
80102352:	74 f2                	je     80102346 <skipelem+0x8>
    path++;
  if(*path == 0)
80102354:	8b 45 08             	mov    0x8(%ebp),%eax
80102357:	0f b6 00             	movzbl (%eax),%eax
8010235a:	84 c0                	test   %al,%al
8010235c:	75 07                	jne    80102365 <skipelem+0x27>
    return 0;
8010235e:	b8 00 00 00 00       	mov    $0x0,%eax
80102363:	eb 7b                	jmp    801023e0 <skipelem+0xa2>
  s = path;
80102365:	8b 45 08             	mov    0x8(%ebp),%eax
80102368:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010236b:	eb 04                	jmp    80102371 <skipelem+0x33>
    path++;
8010236d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102371:	8b 45 08             	mov    0x8(%ebp),%eax
80102374:	0f b6 00             	movzbl (%eax),%eax
80102377:	3c 2f                	cmp    $0x2f,%al
80102379:	74 0a                	je     80102385 <skipelem+0x47>
8010237b:	8b 45 08             	mov    0x8(%ebp),%eax
8010237e:	0f b6 00             	movzbl (%eax),%eax
80102381:	84 c0                	test   %al,%al
80102383:	75 e8                	jne    8010236d <skipelem+0x2f>
    path++;
  len = path - s;
80102385:	8b 55 08             	mov    0x8(%ebp),%edx
80102388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238b:	29 c2                	sub    %eax,%edx
8010238d:	89 d0                	mov    %edx,%eax
8010238f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102392:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102396:	7e 15                	jle    801023ad <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102398:	83 ec 04             	sub    $0x4,%esp
8010239b:	6a 0e                	push   $0xe
8010239d:	ff 75 f4             	pushl  -0xc(%ebp)
801023a0:	ff 75 0c             	pushl  0xc(%ebp)
801023a3:	e8 c4 38 00 00       	call   80105c6c <memmove>
801023a8:	83 c4 10             	add    $0x10,%esp
801023ab:	eb 26                	jmp    801023d3 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b0:	83 ec 04             	sub    $0x4,%esp
801023b3:	50                   	push   %eax
801023b4:	ff 75 f4             	pushl  -0xc(%ebp)
801023b7:	ff 75 0c             	pushl  0xc(%ebp)
801023ba:	e8 ad 38 00 00       	call   80105c6c <memmove>
801023bf:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c8:	01 d0                	add    %edx,%eax
801023ca:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023cd:	eb 04                	jmp    801023d3 <skipelem+0x95>
    path++;
801023cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023d3:	8b 45 08             	mov    0x8(%ebp),%eax
801023d6:	0f b6 00             	movzbl (%eax),%eax
801023d9:	3c 2f                	cmp    $0x2f,%al
801023db:	74 f2                	je     801023cf <skipelem+0x91>
    path++;
  return path;
801023dd:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023e0:	c9                   	leave  
801023e1:	c3                   	ret    

801023e2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023e2:	55                   	push   %ebp
801023e3:	89 e5                	mov    %esp,%ebp
801023e5:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023e8:	8b 45 08             	mov    0x8(%ebp),%eax
801023eb:	0f b6 00             	movzbl (%eax),%eax
801023ee:	3c 2f                	cmp    $0x2f,%al
801023f0:	75 17                	jne    80102409 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023f2:	83 ec 08             	sub    $0x8,%esp
801023f5:	6a 01                	push   $0x1
801023f7:	6a 01                	push   $0x1
801023f9:	e8 33 f4 ff ff       	call   80101831 <iget>
801023fe:	83 c4 10             	add    $0x10,%esp
80102401:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102404:	e9 bb 00 00 00       	jmp    801024c4 <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102409:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010240f:	8b 40 68             	mov    0x68(%eax),%eax
80102412:	83 ec 0c             	sub    $0xc,%esp
80102415:	50                   	push   %eax
80102416:	e8 f5 f4 ff ff       	call   80101910 <idup>
8010241b:	83 c4 10             	add    $0x10,%esp
8010241e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102421:	e9 9e 00 00 00       	jmp    801024c4 <namex+0xe2>
    ilock(ip);
80102426:	83 ec 0c             	sub    $0xc,%esp
80102429:	ff 75 f4             	pushl  -0xc(%ebp)
8010242c:	e8 19 f5 ff ff       	call   8010194a <ilock>
80102431:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102437:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010243b:	66 83 f8 01          	cmp    $0x1,%ax
8010243f:	74 18                	je     80102459 <namex+0x77>
      iunlockput(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	pushl  -0xc(%ebp)
80102447:	e8 b8 f7 ff ff       	call   80101c04 <iunlockput>
8010244c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010244f:	b8 00 00 00 00       	mov    $0x0,%eax
80102454:	e9 a7 00 00 00       	jmp    80102500 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102459:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010245d:	74 20                	je     8010247f <namex+0x9d>
8010245f:	8b 45 08             	mov    0x8(%ebp),%eax
80102462:	0f b6 00             	movzbl (%eax),%eax
80102465:	84 c0                	test   %al,%al
80102467:	75 16                	jne    8010247f <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102469:	83 ec 0c             	sub    $0xc,%esp
8010246c:	ff 75 f4             	pushl  -0xc(%ebp)
8010246f:	e8 2e f6 ff ff       	call   80101aa2 <iunlock>
80102474:	83 c4 10             	add    $0x10,%esp
      return ip;
80102477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247a:	e9 81 00 00 00       	jmp    80102500 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010247f:	83 ec 04             	sub    $0x4,%esp
80102482:	6a 00                	push   $0x0
80102484:	ff 75 10             	pushl  0x10(%ebp)
80102487:	ff 75 f4             	pushl  -0xc(%ebp)
8010248a:	e8 1d fd ff ff       	call   801021ac <dirlookup>
8010248f:	83 c4 10             	add    $0x10,%esp
80102492:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102495:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102499:	75 15                	jne    801024b0 <namex+0xce>
      iunlockput(ip);
8010249b:	83 ec 0c             	sub    $0xc,%esp
8010249e:	ff 75 f4             	pushl  -0xc(%ebp)
801024a1:	e8 5e f7 ff ff       	call   80101c04 <iunlockput>
801024a6:	83 c4 10             	add    $0x10,%esp
      return 0;
801024a9:	b8 00 00 00 00       	mov    $0x0,%eax
801024ae:	eb 50                	jmp    80102500 <namex+0x11e>
    }
    iunlockput(ip);
801024b0:	83 ec 0c             	sub    $0xc,%esp
801024b3:	ff 75 f4             	pushl  -0xc(%ebp)
801024b6:	e8 49 f7 ff ff       	call   80101c04 <iunlockput>
801024bb:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024c4:	83 ec 08             	sub    $0x8,%esp
801024c7:	ff 75 10             	pushl  0x10(%ebp)
801024ca:	ff 75 08             	pushl  0x8(%ebp)
801024cd:	e8 6c fe ff ff       	call   8010233e <skipelem>
801024d2:	83 c4 10             	add    $0x10,%esp
801024d5:	89 45 08             	mov    %eax,0x8(%ebp)
801024d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024dc:	0f 85 44 ff ff ff    	jne    80102426 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024e6:	74 15                	je     801024fd <namex+0x11b>
    iput(ip);
801024e8:	83 ec 0c             	sub    $0xc,%esp
801024eb:	ff 75 f4             	pushl  -0xc(%ebp)
801024ee:	e8 21 f6 ff ff       	call   80101b14 <iput>
801024f3:	83 c4 10             	add    $0x10,%esp
    return 0;
801024f6:	b8 00 00 00 00       	mov    $0x0,%eax
801024fb:	eb 03                	jmp    80102500 <namex+0x11e>
  }
  return ip;
801024fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102500:	c9                   	leave  
80102501:	c3                   	ret    

80102502 <namei>:

struct inode*
namei(char *path)
{
80102502:	55                   	push   %ebp
80102503:	89 e5                	mov    %esp,%ebp
80102505:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102508:	83 ec 04             	sub    $0x4,%esp
8010250b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010250e:	50                   	push   %eax
8010250f:	6a 00                	push   $0x0
80102511:	ff 75 08             	pushl  0x8(%ebp)
80102514:	e8 c9 fe ff ff       	call   801023e2 <namex>
80102519:	83 c4 10             	add    $0x10,%esp
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    

8010251e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102524:	83 ec 04             	sub    $0x4,%esp
80102527:	ff 75 0c             	pushl  0xc(%ebp)
8010252a:	6a 01                	push   $0x1
8010252c:	ff 75 08             	pushl  0x8(%ebp)
8010252f:	e8 ae fe ff ff       	call   801023e2 <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 14             	sub    $0x14,%esp
8010253f:	8b 45 08             	mov    0x8(%ebp),%eax
80102542:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102546:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010254a:	89 c2                	mov    %eax,%edx
8010254c:	ec                   	in     (%dx),%al
8010254d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102550:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102554:	c9                   	leave  
80102555:	c3                   	ret    

80102556 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102556:	55                   	push   %ebp
80102557:	89 e5                	mov    %esp,%ebp
80102559:	57                   	push   %edi
8010255a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010255b:	8b 55 08             	mov    0x8(%ebp),%edx
8010255e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102561:	8b 45 10             	mov    0x10(%ebp),%eax
80102564:	89 cb                	mov    %ecx,%ebx
80102566:	89 df                	mov    %ebx,%edi
80102568:	89 c1                	mov    %eax,%ecx
8010256a:	fc                   	cld    
8010256b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010256d:	89 c8                	mov    %ecx,%eax
8010256f:	89 fb                	mov    %edi,%ebx
80102571:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102574:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102577:	90                   	nop
80102578:	5b                   	pop    %ebx
80102579:	5f                   	pop    %edi
8010257a:	5d                   	pop    %ebp
8010257b:	c3                   	ret    

8010257c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	83 ec 08             	sub    $0x8,%esp
80102582:	8b 55 08             	mov    0x8(%ebp),%edx
80102585:	8b 45 0c             	mov    0xc(%ebp),%eax
80102588:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010258c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010258f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102593:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102597:	ee                   	out    %al,(%dx)
}
80102598:	90                   	nop
80102599:	c9                   	leave  
8010259a:	c3                   	ret    

8010259b <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010259b:	55                   	push   %ebp
8010259c:	89 e5                	mov    %esp,%ebp
8010259e:	56                   	push   %esi
8010259f:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025a0:	8b 55 08             	mov    0x8(%ebp),%edx
801025a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025a6:	8b 45 10             	mov    0x10(%ebp),%eax
801025a9:	89 cb                	mov    %ecx,%ebx
801025ab:	89 de                	mov    %ebx,%esi
801025ad:	89 c1                	mov    %eax,%ecx
801025af:	fc                   	cld    
801025b0:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025b2:	89 c8                	mov    %ecx,%eax
801025b4:	89 f3                	mov    %esi,%ebx
801025b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025b9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025bc:	90                   	nop
801025bd:	5b                   	pop    %ebx
801025be:	5e                   	pop    %esi
801025bf:	5d                   	pop    %ebp
801025c0:	c3                   	ret    

801025c1 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
801025c4:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025c7:	90                   	nop
801025c8:	68 f7 01 00 00       	push   $0x1f7
801025cd:	e8 67 ff ff ff       	call   80102539 <inb>
801025d2:	83 c4 04             	add    $0x4,%esp
801025d5:	0f b6 c0             	movzbl %al,%eax
801025d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025de:	25 c0 00 00 00       	and    $0xc0,%eax
801025e3:	83 f8 40             	cmp    $0x40,%eax
801025e6:	75 e0                	jne    801025c8 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ec:	74 11                	je     801025ff <idewait+0x3e>
801025ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025f1:	83 e0 21             	and    $0x21,%eax
801025f4:	85 c0                	test   %eax,%eax
801025f6:	74 07                	je     801025ff <idewait+0x3e>
    return -1;
801025f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025fd:	eb 05                	jmp    80102604 <idewait+0x43>
  return 0;
801025ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102604:	c9                   	leave  
80102605:	c3                   	ret    

80102606 <ideinit>:

void
ideinit(void)
{
80102606:	55                   	push   %ebp
80102607:	89 e5                	mov    %esp,%ebp
80102609:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010260c:	83 ec 08             	sub    $0x8,%esp
8010260f:	68 b8 92 10 80       	push   $0x801092b8
80102614:	68 20 c6 10 80       	push   $0x8010c620
80102619:	e8 0a 33 00 00       	call   80105928 <initlock>
8010261e:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102621:	83 ec 0c             	sub    $0xc,%esp
80102624:	6a 0e                	push   $0xe
80102626:	e8 ec 19 00 00       	call   80104017 <picenable>
8010262b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010262e:	a1 60 39 11 80       	mov    0x80113960,%eax
80102633:	83 e8 01             	sub    $0x1,%eax
80102636:	83 ec 08             	sub    $0x8,%esp
80102639:	50                   	push   %eax
8010263a:	6a 0e                	push   $0xe
8010263c:	e8 37 04 00 00       	call   80102a78 <ioapicenable>
80102641:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102644:	83 ec 0c             	sub    $0xc,%esp
80102647:	6a 00                	push   $0x0
80102649:	e8 73 ff ff ff       	call   801025c1 <idewait>
8010264e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102651:	83 ec 08             	sub    $0x8,%esp
80102654:	68 f0 00 00 00       	push   $0xf0
80102659:	68 f6 01 00 00       	push   $0x1f6
8010265e:	e8 19 ff ff ff       	call   8010257c <outb>
80102663:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102666:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010266d:	eb 24                	jmp    80102693 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010266f:	83 ec 0c             	sub    $0xc,%esp
80102672:	68 f7 01 00 00       	push   $0x1f7
80102677:	e8 bd fe ff ff       	call   80102539 <inb>
8010267c:	83 c4 10             	add    $0x10,%esp
8010267f:	84 c0                	test   %al,%al
80102681:	74 0c                	je     8010268f <ideinit+0x89>
      havedisk1 = 1;
80102683:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
8010268a:	00 00 00 
      break;
8010268d:	eb 0d                	jmp    8010269c <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010268f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102693:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010269a:	7e d3                	jle    8010266f <ideinit+0x69>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010269c:	83 ec 08             	sub    $0x8,%esp
8010269f:	68 e0 00 00 00       	push   $0xe0
801026a4:	68 f6 01 00 00       	push   $0x1f6
801026a9:	e8 ce fe ff ff       	call   8010257c <outb>
801026ae:	83 c4 10             	add    $0x10,%esp
}
801026b1:	90                   	nop
801026b2:	c9                   	leave  
801026b3:	c3                   	ret    

801026b4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026b4:	55                   	push   %ebp
801026b5:	89 e5                	mov    %esp,%ebp
801026b7:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
801026ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026be:	75 0d                	jne    801026cd <idestart+0x19>
    panic("idestart");
801026c0:	83 ec 0c             	sub    $0xc,%esp
801026c3:	68 bc 92 10 80       	push   $0x801092bc
801026c8:	e8 99 de ff ff       	call   80100566 <panic>

  idewait(0);
801026cd:	83 ec 0c             	sub    $0xc,%esp
801026d0:	6a 00                	push   $0x0
801026d2:	e8 ea fe ff ff       	call   801025c1 <idewait>
801026d7:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801026da:	83 ec 08             	sub    $0x8,%esp
801026dd:	6a 00                	push   $0x0
801026df:	68 f6 03 00 00       	push   $0x3f6
801026e4:	e8 93 fe ff ff       	call   8010257c <outb>
801026e9:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801026ec:	83 ec 08             	sub    $0x8,%esp
801026ef:	6a 01                	push   $0x1
801026f1:	68 f2 01 00 00       	push   $0x1f2
801026f6:	e8 81 fe ff ff       	call   8010257c <outb>
801026fb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102701:	8b 40 08             	mov    0x8(%eax),%eax
80102704:	0f b6 c0             	movzbl %al,%eax
80102707:	83 ec 08             	sub    $0x8,%esp
8010270a:	50                   	push   %eax
8010270b:	68 f3 01 00 00       	push   $0x1f3
80102710:	e8 67 fe ff ff       	call   8010257c <outb>
80102715:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102718:	8b 45 08             	mov    0x8(%ebp),%eax
8010271b:	8b 40 08             	mov    0x8(%eax),%eax
8010271e:	c1 e8 08             	shr    $0x8,%eax
80102721:	0f b6 c0             	movzbl %al,%eax
80102724:	83 ec 08             	sub    $0x8,%esp
80102727:	50                   	push   %eax
80102728:	68 f4 01 00 00       	push   $0x1f4
8010272d:	e8 4a fe ff ff       	call   8010257c <outb>
80102732:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102735:	8b 45 08             	mov    0x8(%ebp),%eax
80102738:	8b 40 08             	mov    0x8(%eax),%eax
8010273b:	c1 e8 10             	shr    $0x10,%eax
8010273e:	0f b6 c0             	movzbl %al,%eax
80102741:	83 ec 08             	sub    $0x8,%esp
80102744:	50                   	push   %eax
80102745:	68 f5 01 00 00       	push   $0x1f5
8010274a:	e8 2d fe ff ff       	call   8010257c <outb>
8010274f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102752:	8b 45 08             	mov    0x8(%ebp),%eax
80102755:	8b 40 04             	mov    0x4(%eax),%eax
80102758:	83 e0 01             	and    $0x1,%eax
8010275b:	c1 e0 04             	shl    $0x4,%eax
8010275e:	89 c2                	mov    %eax,%edx
80102760:	8b 45 08             	mov    0x8(%ebp),%eax
80102763:	8b 40 08             	mov    0x8(%eax),%eax
80102766:	c1 e8 18             	shr    $0x18,%eax
80102769:	83 e0 0f             	and    $0xf,%eax
8010276c:	09 d0                	or     %edx,%eax
8010276e:	83 c8 e0             	or     $0xffffffe0,%eax
80102771:	0f b6 c0             	movzbl %al,%eax
80102774:	83 ec 08             	sub    $0x8,%esp
80102777:	50                   	push   %eax
80102778:	68 f6 01 00 00       	push   $0x1f6
8010277d:	e8 fa fd ff ff       	call   8010257c <outb>
80102782:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102785:	8b 45 08             	mov    0x8(%ebp),%eax
80102788:	8b 00                	mov    (%eax),%eax
8010278a:	83 e0 04             	and    $0x4,%eax
8010278d:	85 c0                	test   %eax,%eax
8010278f:	74 30                	je     801027c1 <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
80102791:	83 ec 08             	sub    $0x8,%esp
80102794:	6a 30                	push   $0x30
80102796:	68 f7 01 00 00       	push   $0x1f7
8010279b:	e8 dc fd ff ff       	call   8010257c <outb>
801027a0:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
801027a3:	8b 45 08             	mov    0x8(%ebp),%eax
801027a6:	83 c0 18             	add    $0x18,%eax
801027a9:	83 ec 04             	sub    $0x4,%esp
801027ac:	68 80 00 00 00       	push   $0x80
801027b1:	50                   	push   %eax
801027b2:	68 f0 01 00 00       	push   $0x1f0
801027b7:	e8 df fd ff ff       	call   8010259b <outsl>
801027bc:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801027bf:	eb 12                	jmp    801027d3 <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801027c1:	83 ec 08             	sub    $0x8,%esp
801027c4:	6a 20                	push   $0x20
801027c6:	68 f7 01 00 00       	push   $0x1f7
801027cb:	e8 ac fd ff ff       	call   8010257c <outb>
801027d0:	83 c4 10             	add    $0x10,%esp
  }
}
801027d3:	90                   	nop
801027d4:	c9                   	leave  
801027d5:	c3                   	ret    

801027d6 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027d6:	55                   	push   %ebp
801027d7:	89 e5                	mov    %esp,%ebp
801027d9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027dc:	83 ec 0c             	sub    $0xc,%esp
801027df:	68 20 c6 10 80       	push   $0x8010c620
801027e4:	e8 61 31 00 00       	call   8010594a <acquire>
801027e9:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801027ec:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027f8:	75 15                	jne    8010280f <ideintr+0x39>
    release(&idelock);
801027fa:	83 ec 0c             	sub    $0xc,%esp
801027fd:	68 20 c6 10 80       	push   $0x8010c620
80102802:	e8 aa 31 00 00       	call   801059b1 <release>
80102807:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010280a:	e9 9a 00 00 00       	jmp    801028a9 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010280f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102812:	8b 40 14             	mov    0x14(%eax),%eax
80102815:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010281a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281d:	8b 00                	mov    (%eax),%eax
8010281f:	83 e0 04             	and    $0x4,%eax
80102822:	85 c0                	test   %eax,%eax
80102824:	75 2d                	jne    80102853 <ideintr+0x7d>
80102826:	83 ec 0c             	sub    $0xc,%esp
80102829:	6a 01                	push   $0x1
8010282b:	e8 91 fd ff ff       	call   801025c1 <idewait>
80102830:	83 c4 10             	add    $0x10,%esp
80102833:	85 c0                	test   %eax,%eax
80102835:	78 1c                	js     80102853 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
80102837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283a:	83 c0 18             	add    $0x18,%eax
8010283d:	83 ec 04             	sub    $0x4,%esp
80102840:	68 80 00 00 00       	push   $0x80
80102845:	50                   	push   %eax
80102846:	68 f0 01 00 00       	push   $0x1f0
8010284b:	e8 06 fd ff ff       	call   80102556 <insl>
80102850:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102856:	8b 00                	mov    (%eax),%eax
80102858:	83 c8 02             	or     $0x2,%eax
8010285b:	89 c2                	mov    %eax,%edx
8010285d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102860:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102865:	8b 00                	mov    (%eax),%eax
80102867:	83 e0 fb             	and    $0xfffffffb,%eax
8010286a:	89 c2                	mov    %eax,%edx
8010286c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102871:	83 ec 0c             	sub    $0xc,%esp
80102874:	ff 75 f4             	pushl  -0xc(%ebp)
80102877:	e8 1e 2a 00 00       	call   8010529a <wakeup>
8010287c:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010287f:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102884:	85 c0                	test   %eax,%eax
80102886:	74 11                	je     80102899 <ideintr+0xc3>
    idestart(idequeue);
80102888:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010288d:	83 ec 0c             	sub    $0xc,%esp
80102890:	50                   	push   %eax
80102891:	e8 1e fe ff ff       	call   801026b4 <idestart>
80102896:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102899:	83 ec 0c             	sub    $0xc,%esp
8010289c:	68 20 c6 10 80       	push   $0x8010c620
801028a1:	e8 0b 31 00 00       	call   801059b1 <release>
801028a6:	83 c4 10             	add    $0x10,%esp
}
801028a9:	c9                   	leave  
801028aa:	c3                   	ret    

801028ab <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028ab:	55                   	push   %ebp
801028ac:	89 e5                	mov    %esp,%ebp
801028ae:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801028b1:	8b 45 08             	mov    0x8(%ebp),%eax
801028b4:	8b 00                	mov    (%eax),%eax
801028b6:	83 e0 01             	and    $0x1,%eax
801028b9:	85 c0                	test   %eax,%eax
801028bb:	75 0d                	jne    801028ca <iderw+0x1f>
    panic("iderw: buf not busy");
801028bd:	83 ec 0c             	sub    $0xc,%esp
801028c0:	68 c5 92 10 80       	push   $0x801092c5
801028c5:	e8 9c dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028ca:	8b 45 08             	mov    0x8(%ebp),%eax
801028cd:	8b 00                	mov    (%eax),%eax
801028cf:	83 e0 06             	and    $0x6,%eax
801028d2:	83 f8 02             	cmp    $0x2,%eax
801028d5:	75 0d                	jne    801028e4 <iderw+0x39>
    panic("iderw: nothing to do");
801028d7:	83 ec 0c             	sub    $0xc,%esp
801028da:	68 d9 92 10 80       	push   $0x801092d9
801028df:	e8 82 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801028e4:	8b 45 08             	mov    0x8(%ebp),%eax
801028e7:	8b 40 04             	mov    0x4(%eax),%eax
801028ea:	85 c0                	test   %eax,%eax
801028ec:	74 16                	je     80102904 <iderw+0x59>
801028ee:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801028f3:	85 c0                	test   %eax,%eax
801028f5:	75 0d                	jne    80102904 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028f7:	83 ec 0c             	sub    $0xc,%esp
801028fa:	68 ee 92 10 80       	push   $0x801092ee
801028ff:	e8 62 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102904:	83 ec 0c             	sub    $0xc,%esp
80102907:	68 20 c6 10 80       	push   $0x8010c620
8010290c:	e8 39 30 00 00       	call   8010594a <acquire>
80102911:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010291e:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102925:	eb 0b                	jmp    80102932 <iderw+0x87>
80102927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010292a:	8b 00                	mov    (%eax),%eax
8010292c:	83 c0 14             	add    $0x14,%eax
8010292f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102935:	8b 00                	mov    (%eax),%eax
80102937:	85 c0                	test   %eax,%eax
80102939:	75 ec                	jne    80102927 <iderw+0x7c>
    ;
  *pp = b;
8010293b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293e:	8b 55 08             	mov    0x8(%ebp),%edx
80102941:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102943:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102948:	3b 45 08             	cmp    0x8(%ebp),%eax
8010294b:	75 23                	jne    80102970 <iderw+0xc5>
    idestart(b);
8010294d:	83 ec 0c             	sub    $0xc,%esp
80102950:	ff 75 08             	pushl  0x8(%ebp)
80102953:	e8 5c fd ff ff       	call   801026b4 <idestart>
80102958:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010295b:	eb 13                	jmp    80102970 <iderw+0xc5>
    sleep(b, &idelock);
8010295d:	83 ec 08             	sub    $0x8,%esp
80102960:	68 20 c6 10 80       	push   $0x8010c620
80102965:	ff 75 08             	pushl  0x8(%ebp)
80102968:	e8 21 28 00 00       	call   8010518e <sleep>
8010296d:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102970:	8b 45 08             	mov    0x8(%ebp),%eax
80102973:	8b 00                	mov    (%eax),%eax
80102975:	83 e0 06             	and    $0x6,%eax
80102978:	83 f8 02             	cmp    $0x2,%eax
8010297b:	75 e0                	jne    8010295d <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
8010297d:	83 ec 0c             	sub    $0xc,%esp
80102980:	68 20 c6 10 80       	push   $0x8010c620
80102985:	e8 27 30 00 00       	call   801059b1 <release>
8010298a:	83 c4 10             	add    $0x10,%esp
}
8010298d:	90                   	nop
8010298e:	c9                   	leave  
8010298f:	c3                   	ret    

80102990 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102990:	55                   	push   %ebp
80102991:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102993:	a1 34 32 11 80       	mov    0x80113234,%eax
80102998:	8b 55 08             	mov    0x8(%ebp),%edx
8010299b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010299d:	a1 34 32 11 80       	mov    0x80113234,%eax
801029a2:	8b 40 10             	mov    0x10(%eax),%eax
}
801029a5:	5d                   	pop    %ebp
801029a6:	c3                   	ret    

801029a7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029a7:	55                   	push   %ebp
801029a8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029aa:	a1 34 32 11 80       	mov    0x80113234,%eax
801029af:	8b 55 08             	mov    0x8(%ebp),%edx
801029b2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029b4:	a1 34 32 11 80       	mov    0x80113234,%eax
801029b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801029bc:	89 50 10             	mov    %edx,0x10(%eax)
}
801029bf:	90                   	nop
801029c0:	5d                   	pop    %ebp
801029c1:	c3                   	ret    

801029c2 <ioapicinit>:

void
ioapicinit(void)
{
801029c2:	55                   	push   %ebp
801029c3:	89 e5                	mov    %esp,%ebp
801029c5:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
801029c8:	a1 64 33 11 80       	mov    0x80113364,%eax
801029cd:	85 c0                	test   %eax,%eax
801029cf:	0f 84 a0 00 00 00    	je     80102a75 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801029d5:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
801029dc:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029df:	6a 01                	push   $0x1
801029e1:	e8 aa ff ff ff       	call   80102990 <ioapicread>
801029e6:	83 c4 04             	add    $0x4,%esp
801029e9:	c1 e8 10             	shr    $0x10,%eax
801029ec:	25 ff 00 00 00       	and    $0xff,%eax
801029f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029f4:	6a 00                	push   $0x0
801029f6:	e8 95 ff ff ff       	call   80102990 <ioapicread>
801029fb:	83 c4 04             	add    $0x4,%esp
801029fe:	c1 e8 18             	shr    $0x18,%eax
80102a01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a04:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102a0b:	0f b6 c0             	movzbl %al,%eax
80102a0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a11:	74 10                	je     80102a23 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a13:	83 ec 0c             	sub    $0xc,%esp
80102a16:	68 0c 93 10 80       	push   $0x8010930c
80102a1b:	e8 a6 d9 ff ff       	call   801003c6 <cprintf>
80102a20:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a2a:	eb 3f                	jmp    80102a6b <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2f:	83 c0 20             	add    $0x20,%eax
80102a32:	0d 00 00 01 00       	or     $0x10000,%eax
80102a37:	89 c2                	mov    %eax,%edx
80102a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3c:	83 c0 08             	add    $0x8,%eax
80102a3f:	01 c0                	add    %eax,%eax
80102a41:	83 ec 08             	sub    $0x8,%esp
80102a44:	52                   	push   %edx
80102a45:	50                   	push   %eax
80102a46:	e8 5c ff ff ff       	call   801029a7 <ioapicwrite>
80102a4b:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a51:	83 c0 08             	add    $0x8,%eax
80102a54:	01 c0                	add    %eax,%eax
80102a56:	83 c0 01             	add    $0x1,%eax
80102a59:	83 ec 08             	sub    $0x8,%esp
80102a5c:	6a 00                	push   $0x0
80102a5e:	50                   	push   %eax
80102a5f:	e8 43 ff ff ff       	call   801029a7 <ioapicwrite>
80102a64:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a71:	7e b9                	jle    80102a2c <ioapicinit+0x6a>
80102a73:	eb 01                	jmp    80102a76 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a75:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a76:	c9                   	leave  
80102a77:	c3                   	ret    

80102a78 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a7b:	a1 64 33 11 80       	mov    0x80113364,%eax
80102a80:	85 c0                	test   %eax,%eax
80102a82:	74 39                	je     80102abd <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a84:	8b 45 08             	mov    0x8(%ebp),%eax
80102a87:	83 c0 20             	add    $0x20,%eax
80102a8a:	89 c2                	mov    %eax,%edx
80102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8f:	83 c0 08             	add    $0x8,%eax
80102a92:	01 c0                	add    %eax,%eax
80102a94:	52                   	push   %edx
80102a95:	50                   	push   %eax
80102a96:	e8 0c ff ff ff       	call   801029a7 <ioapicwrite>
80102a9b:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aa1:	c1 e0 18             	shl    $0x18,%eax
80102aa4:	89 c2                	mov    %eax,%edx
80102aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa9:	83 c0 08             	add    $0x8,%eax
80102aac:	01 c0                	add    %eax,%eax
80102aae:	83 c0 01             	add    $0x1,%eax
80102ab1:	52                   	push   %edx
80102ab2:	50                   	push   %eax
80102ab3:	e8 ef fe ff ff       	call   801029a7 <ioapicwrite>
80102ab8:	83 c4 08             	add    $0x8,%esp
80102abb:	eb 01                	jmp    80102abe <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102abd:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102abe:	c9                   	leave  
80102abf:	c3                   	ret    

80102ac0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102ac0:	55                   	push   %ebp
80102ac1:	89 e5                	mov    %esp,%ebp
80102ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac6:	05 00 00 00 80       	add    $0x80000000,%eax
80102acb:	5d                   	pop    %ebp
80102acc:	c3                   	ret    

80102acd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102acd:	55                   	push   %ebp
80102ace:	89 e5                	mov    %esp,%ebp
80102ad0:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102ad3:	83 ec 08             	sub    $0x8,%esp
80102ad6:	68 3e 93 10 80       	push   $0x8010933e
80102adb:	68 40 32 11 80       	push   $0x80113240
80102ae0:	e8 43 2e 00 00       	call   80105928 <initlock>
80102ae5:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ae8:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102aef:	00 00 00 
  freerange(vstart, vend);
80102af2:	83 ec 08             	sub    $0x8,%esp
80102af5:	ff 75 0c             	pushl  0xc(%ebp)
80102af8:	ff 75 08             	pushl  0x8(%ebp)
80102afb:	e8 2a 00 00 00       	call   80102b2a <freerange>
80102b00:	83 c4 10             	add    $0x10,%esp
}
80102b03:	90                   	nop
80102b04:	c9                   	leave  
80102b05:	c3                   	ret    

80102b06 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b06:	55                   	push   %ebp
80102b07:	89 e5                	mov    %esp,%ebp
80102b09:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b0c:	83 ec 08             	sub    $0x8,%esp
80102b0f:	ff 75 0c             	pushl  0xc(%ebp)
80102b12:	ff 75 08             	pushl  0x8(%ebp)
80102b15:	e8 10 00 00 00       	call   80102b2a <freerange>
80102b1a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b1d:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102b24:	00 00 00 
}
80102b27:	90                   	nop
80102b28:	c9                   	leave  
80102b29:	c3                   	ret    

80102b2a <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b2a:	55                   	push   %ebp
80102b2b:	89 e5                	mov    %esp,%ebp
80102b2d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b30:	8b 45 08             	mov    0x8(%ebp),%eax
80102b33:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b40:	eb 15                	jmp    80102b57 <freerange+0x2d>
    kfree(p);
80102b42:	83 ec 0c             	sub    $0xc,%esp
80102b45:	ff 75 f4             	pushl  -0xc(%ebp)
80102b48:	e8 1a 00 00 00       	call   80102b67 <kfree>
80102b4d:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b5a:	05 00 10 00 00       	add    $0x1000,%eax
80102b5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b62:	76 de                	jbe    80102b42 <freerange+0x18>
    kfree(p);
}
80102b64:	90                   	nop
80102b65:	c9                   	leave  
80102b66:	c3                   	ret    

80102b67 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b67:	55                   	push   %ebp
80102b68:	89 e5                	mov    %esp,%ebp
80102b6a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b70:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b75:	85 c0                	test   %eax,%eax
80102b77:	75 1b                	jne    80102b94 <kfree+0x2d>
80102b79:	81 7d 08 bc 81 11 80 	cmpl   $0x801181bc,0x8(%ebp)
80102b80:	72 12                	jb     80102b94 <kfree+0x2d>
80102b82:	ff 75 08             	pushl  0x8(%ebp)
80102b85:	e8 36 ff ff ff       	call   80102ac0 <v2p>
80102b8a:	83 c4 04             	add    $0x4,%esp
80102b8d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b92:	76 0d                	jbe    80102ba1 <kfree+0x3a>
    panic("kfree");
80102b94:	83 ec 0c             	sub    $0xc,%esp
80102b97:	68 43 93 10 80       	push   $0x80109343
80102b9c:	e8 c5 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ba1:	83 ec 04             	sub    $0x4,%esp
80102ba4:	68 00 10 00 00       	push   $0x1000
80102ba9:	6a 01                	push   $0x1
80102bab:	ff 75 08             	pushl  0x8(%ebp)
80102bae:	e8 fa 2f 00 00       	call   80105bad <memset>
80102bb3:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102bb6:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bbb:	85 c0                	test   %eax,%eax
80102bbd:	74 10                	je     80102bcf <kfree+0x68>
    acquire(&kmem.lock);
80102bbf:	83 ec 0c             	sub    $0xc,%esp
80102bc2:	68 40 32 11 80       	push   $0x80113240
80102bc7:	e8 7e 2d 00 00       	call   8010594a <acquire>
80102bcc:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102bd5:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bde:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be3:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102be8:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bed:	85 c0                	test   %eax,%eax
80102bef:	74 10                	je     80102c01 <kfree+0x9a>
    release(&kmem.lock);
80102bf1:	83 ec 0c             	sub    $0xc,%esp
80102bf4:	68 40 32 11 80       	push   $0x80113240
80102bf9:	e8 b3 2d 00 00       	call   801059b1 <release>
80102bfe:	83 c4 10             	add    $0x10,%esp
}
80102c01:	90                   	nop
80102c02:	c9                   	leave  
80102c03:	c3                   	ret    

80102c04 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c04:	55                   	push   %ebp
80102c05:	89 e5                	mov    %esp,%ebp
80102c07:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c0a:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c0f:	85 c0                	test   %eax,%eax
80102c11:	74 10                	je     80102c23 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c13:	83 ec 0c             	sub    $0xc,%esp
80102c16:	68 40 32 11 80       	push   $0x80113240
80102c1b:	e8 2a 2d 00 00       	call   8010594a <acquire>
80102c20:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c23:	a1 78 32 11 80       	mov    0x80113278,%eax
80102c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c2f:	74 0a                	je     80102c3b <kalloc+0x37>
    kmem.freelist = r->next;
80102c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c34:	8b 00                	mov    (%eax),%eax
80102c36:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c3b:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c40:	85 c0                	test   %eax,%eax
80102c42:	74 10                	je     80102c54 <kalloc+0x50>
    release(&kmem.lock);
80102c44:	83 ec 0c             	sub    $0xc,%esp
80102c47:	68 40 32 11 80       	push   $0x80113240
80102c4c:	e8 60 2d 00 00       	call   801059b1 <release>
80102c51:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c57:	c9                   	leave  
80102c58:	c3                   	ret    

80102c59 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c59:	55                   	push   %ebp
80102c5a:	89 e5                	mov    %esp,%ebp
80102c5c:	83 ec 14             	sub    $0x14,%esp
80102c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c62:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c66:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c6a:	89 c2                	mov    %eax,%edx
80102c6c:	ec                   	in     (%dx),%al
80102c6d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c70:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c74:	c9                   	leave  
80102c75:	c3                   	ret    

80102c76 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c76:	55                   	push   %ebp
80102c77:	89 e5                	mov    %esp,%ebp
80102c79:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c7c:	6a 64                	push   $0x64
80102c7e:	e8 d6 ff ff ff       	call   80102c59 <inb>
80102c83:	83 c4 04             	add    $0x4,%esp
80102c86:	0f b6 c0             	movzbl %al,%eax
80102c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8f:	83 e0 01             	and    $0x1,%eax
80102c92:	85 c0                	test   %eax,%eax
80102c94:	75 0a                	jne    80102ca0 <kbdgetc+0x2a>
    return -1;
80102c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c9b:	e9 23 01 00 00       	jmp    80102dc3 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ca0:	6a 60                	push   $0x60
80102ca2:	e8 b2 ff ff ff       	call   80102c59 <inb>
80102ca7:	83 c4 04             	add    $0x4,%esp
80102caa:	0f b6 c0             	movzbl %al,%eax
80102cad:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cb0:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102cb7:	75 17                	jne    80102cd0 <kbdgetc+0x5a>
    shift |= E0ESC;
80102cb9:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cbe:	83 c8 40             	or     $0x40,%eax
80102cc1:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102cc6:	b8 00 00 00 00       	mov    $0x0,%eax
80102ccb:	e9 f3 00 00 00       	jmp    80102dc3 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102cd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd3:	25 80 00 00 00       	and    $0x80,%eax
80102cd8:	85 c0                	test   %eax,%eax
80102cda:	74 45                	je     80102d21 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102cdc:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ce1:	83 e0 40             	and    $0x40,%eax
80102ce4:	85 c0                	test   %eax,%eax
80102ce6:	75 08                	jne    80102cf0 <kbdgetc+0x7a>
80102ce8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ceb:	83 e0 7f             	and    $0x7f,%eax
80102cee:	eb 03                	jmp    80102cf3 <kbdgetc+0x7d>
80102cf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf9:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102cfe:	0f b6 00             	movzbl (%eax),%eax
80102d01:	83 c8 40             	or     $0x40,%eax
80102d04:	0f b6 c0             	movzbl %al,%eax
80102d07:	f7 d0                	not    %eax
80102d09:	89 c2                	mov    %eax,%edx
80102d0b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d10:	21 d0                	and    %edx,%eax
80102d12:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102d17:	b8 00 00 00 00       	mov    $0x0,%eax
80102d1c:	e9 a2 00 00 00       	jmp    80102dc3 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d21:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d26:	83 e0 40             	and    $0x40,%eax
80102d29:	85 c0                	test   %eax,%eax
80102d2b:	74 14                	je     80102d41 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d2d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d34:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d39:	83 e0 bf             	and    $0xffffffbf,%eax
80102d3c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102d41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d44:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d49:	0f b6 00             	movzbl (%eax),%eax
80102d4c:	0f b6 d0             	movzbl %al,%edx
80102d4f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d54:	09 d0                	or     %edx,%eax
80102d56:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102d5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5e:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102d63:	0f b6 00             	movzbl (%eax),%eax
80102d66:	0f b6 d0             	movzbl %al,%edx
80102d69:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d6e:	31 d0                	xor    %edx,%eax
80102d70:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d75:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d7a:	83 e0 03             	and    $0x3,%eax
80102d7d:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102d84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d87:	01 d0                	add    %edx,%eax
80102d89:	0f b6 00             	movzbl (%eax),%eax
80102d8c:	0f b6 c0             	movzbl %al,%eax
80102d8f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d92:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d97:	83 e0 08             	and    $0x8,%eax
80102d9a:	85 c0                	test   %eax,%eax
80102d9c:	74 22                	je     80102dc0 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d9e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102da2:	76 0c                	jbe    80102db0 <kbdgetc+0x13a>
80102da4:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102da8:	77 06                	ja     80102db0 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102daa:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102dae:	eb 10                	jmp    80102dc0 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102db0:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102db4:	76 0a                	jbe    80102dc0 <kbdgetc+0x14a>
80102db6:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102dba:	77 04                	ja     80102dc0 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102dbc:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102dc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102dc3:	c9                   	leave  
80102dc4:	c3                   	ret    

80102dc5 <kbdintr>:

void
kbdintr(void)
{
80102dc5:	55                   	push   %ebp
80102dc6:	89 e5                	mov    %esp,%ebp
80102dc8:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102dcb:	83 ec 0c             	sub    $0xc,%esp
80102dce:	68 76 2c 10 80       	push   $0x80102c76
80102dd3:	e8 05 da ff ff       	call   801007dd <consoleintr>
80102dd8:	83 c4 10             	add    $0x10,%esp
}
80102ddb:	90                   	nop
80102ddc:	c9                   	leave  
80102ddd:	c3                   	ret    

80102dde <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102dde:	55                   	push   %ebp
80102ddf:	89 e5                	mov    %esp,%ebp
80102de1:	83 ec 14             	sub    $0x14,%esp
80102de4:	8b 45 08             	mov    0x8(%ebp),%eax
80102de7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102deb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102def:	89 c2                	mov    %eax,%edx
80102df1:	ec                   	in     (%dx),%al
80102df2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102df5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102df9:	c9                   	leave  
80102dfa:	c3                   	ret    

80102dfb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102dfb:	55                   	push   %ebp
80102dfc:	89 e5                	mov    %esp,%ebp
80102dfe:	83 ec 08             	sub    $0x8,%esp
80102e01:	8b 55 08             	mov    0x8(%ebp),%edx
80102e04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e07:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e0b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e0e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e12:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e16:	ee                   	out    %al,(%dx)
}
80102e17:	90                   	nop
80102e18:	c9                   	leave  
80102e19:	c3                   	ret    

80102e1a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e1a:	55                   	push   %ebp
80102e1b:	89 e5                	mov    %esp,%ebp
80102e1d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e20:	9c                   	pushf  
80102e21:	58                   	pop    %eax
80102e22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e25:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e28:	c9                   	leave  
80102e29:	c3                   	ret    

80102e2a <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e2a:	55                   	push   %ebp
80102e2b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e2d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e32:	8b 55 08             	mov    0x8(%ebp),%edx
80102e35:	c1 e2 02             	shl    $0x2,%edx
80102e38:	01 c2                	add    %eax,%edx
80102e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e3d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e3f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e44:	83 c0 20             	add    $0x20,%eax
80102e47:	8b 00                	mov    (%eax),%eax
}
80102e49:	90                   	nop
80102e4a:	5d                   	pop    %ebp
80102e4b:	c3                   	ret    

80102e4c <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e4c:	55                   	push   %ebp
80102e4d:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e4f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e54:	85 c0                	test   %eax,%eax
80102e56:	0f 84 0b 01 00 00    	je     80102f67 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e5c:	68 3f 01 00 00       	push   $0x13f
80102e61:	6a 3c                	push   $0x3c
80102e63:	e8 c2 ff ff ff       	call   80102e2a <lapicw>
80102e68:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e6b:	6a 0b                	push   $0xb
80102e6d:	68 f8 00 00 00       	push   $0xf8
80102e72:	e8 b3 ff ff ff       	call   80102e2a <lapicw>
80102e77:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e7a:	68 20 00 02 00       	push   $0x20020
80102e7f:	68 c8 00 00 00       	push   $0xc8
80102e84:	e8 a1 ff ff ff       	call   80102e2a <lapicw>
80102e89:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e8c:	68 80 96 98 00       	push   $0x989680
80102e91:	68 e0 00 00 00       	push   $0xe0
80102e96:	e8 8f ff ff ff       	call   80102e2a <lapicw>
80102e9b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e9e:	68 00 00 01 00       	push   $0x10000
80102ea3:	68 d4 00 00 00       	push   $0xd4
80102ea8:	e8 7d ff ff ff       	call   80102e2a <lapicw>
80102ead:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102eb0:	68 00 00 01 00       	push   $0x10000
80102eb5:	68 d8 00 00 00       	push   $0xd8
80102eba:	e8 6b ff ff ff       	call   80102e2a <lapicw>
80102ebf:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ec2:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ec7:	83 c0 30             	add    $0x30,%eax
80102eca:	8b 00                	mov    (%eax),%eax
80102ecc:	c1 e8 10             	shr    $0x10,%eax
80102ecf:	0f b6 c0             	movzbl %al,%eax
80102ed2:	83 f8 03             	cmp    $0x3,%eax
80102ed5:	76 12                	jbe    80102ee9 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102ed7:	68 00 00 01 00       	push   $0x10000
80102edc:	68 d0 00 00 00       	push   $0xd0
80102ee1:	e8 44 ff ff ff       	call   80102e2a <lapicw>
80102ee6:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ee9:	6a 33                	push   $0x33
80102eeb:	68 dc 00 00 00       	push   $0xdc
80102ef0:	e8 35 ff ff ff       	call   80102e2a <lapicw>
80102ef5:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ef8:	6a 00                	push   $0x0
80102efa:	68 a0 00 00 00       	push   $0xa0
80102eff:	e8 26 ff ff ff       	call   80102e2a <lapicw>
80102f04:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f07:	6a 00                	push   $0x0
80102f09:	68 a0 00 00 00       	push   $0xa0
80102f0e:	e8 17 ff ff ff       	call   80102e2a <lapicw>
80102f13:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f16:	6a 00                	push   $0x0
80102f18:	6a 2c                	push   $0x2c
80102f1a:	e8 0b ff ff ff       	call   80102e2a <lapicw>
80102f1f:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f22:	6a 00                	push   $0x0
80102f24:	68 c4 00 00 00       	push   $0xc4
80102f29:	e8 fc fe ff ff       	call   80102e2a <lapicw>
80102f2e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f31:	68 00 85 08 00       	push   $0x88500
80102f36:	68 c0 00 00 00       	push   $0xc0
80102f3b:	e8 ea fe ff ff       	call   80102e2a <lapicw>
80102f40:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f43:	90                   	nop
80102f44:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f49:	05 00 03 00 00       	add    $0x300,%eax
80102f4e:	8b 00                	mov    (%eax),%eax
80102f50:	25 00 10 00 00       	and    $0x1000,%eax
80102f55:	85 c0                	test   %eax,%eax
80102f57:	75 eb                	jne    80102f44 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f59:	6a 00                	push   $0x0
80102f5b:	6a 20                	push   $0x20
80102f5d:	e8 c8 fe ff ff       	call   80102e2a <lapicw>
80102f62:	83 c4 08             	add    $0x8,%esp
80102f65:	eb 01                	jmp    80102f68 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f67:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f68:	c9                   	leave  
80102f69:	c3                   	ret    

80102f6a <cpunum>:

int
cpunum(void)
{
80102f6a:	55                   	push   %ebp
80102f6b:	89 e5                	mov    %esp,%ebp
80102f6d:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f70:	e8 a5 fe ff ff       	call   80102e1a <readeflags>
80102f75:	25 00 02 00 00       	and    $0x200,%eax
80102f7a:	85 c0                	test   %eax,%eax
80102f7c:	74 26                	je     80102fa4 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f7e:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102f83:	8d 50 01             	lea    0x1(%eax),%edx
80102f86:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102f8c:	85 c0                	test   %eax,%eax
80102f8e:	75 14                	jne    80102fa4 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f90:	8b 45 04             	mov    0x4(%ebp),%eax
80102f93:	83 ec 08             	sub    $0x8,%esp
80102f96:	50                   	push   %eax
80102f97:	68 4c 93 10 80       	push   $0x8010934c
80102f9c:	e8 25 d4 ff ff       	call   801003c6 <cprintf>
80102fa1:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102fa4:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fa9:	85 c0                	test   %eax,%eax
80102fab:	74 0f                	je     80102fbc <cpunum+0x52>
    return lapic[ID]>>24;
80102fad:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fb2:	83 c0 20             	add    $0x20,%eax
80102fb5:	8b 00                	mov    (%eax),%eax
80102fb7:	c1 e8 18             	shr    $0x18,%eax
80102fba:	eb 05                	jmp    80102fc1 <cpunum+0x57>
  return 0;
80102fbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102fc1:	c9                   	leave  
80102fc2:	c3                   	ret    

80102fc3 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102fc3:	55                   	push   %ebp
80102fc4:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102fc6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fcb:	85 c0                	test   %eax,%eax
80102fcd:	74 0c                	je     80102fdb <lapiceoi+0x18>
    lapicw(EOI, 0);
80102fcf:	6a 00                	push   $0x0
80102fd1:	6a 2c                	push   $0x2c
80102fd3:	e8 52 fe ff ff       	call   80102e2a <lapicw>
80102fd8:	83 c4 08             	add    $0x8,%esp
}
80102fdb:	90                   	nop
80102fdc:	c9                   	leave  
80102fdd:	c3                   	ret    

80102fde <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp
}
80102fe1:	90                   	nop
80102fe2:	5d                   	pop    %ebp
80102fe3:	c3                   	ret    

80102fe4 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fe4:	55                   	push   %ebp
80102fe5:	89 e5                	mov    %esp,%ebp
80102fe7:	83 ec 14             	sub    $0x14,%esp
80102fea:	8b 45 08             	mov    0x8(%ebp),%eax
80102fed:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102ff0:	6a 0f                	push   $0xf
80102ff2:	6a 70                	push   $0x70
80102ff4:	e8 02 fe ff ff       	call   80102dfb <outb>
80102ff9:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102ffc:	6a 0a                	push   $0xa
80102ffe:	6a 71                	push   $0x71
80103000:	e8 f6 fd ff ff       	call   80102dfb <outb>
80103005:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103008:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010300f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103012:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103017:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010301a:	83 c0 02             	add    $0x2,%eax
8010301d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103020:	c1 ea 04             	shr    $0x4,%edx
80103023:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103026:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010302a:	c1 e0 18             	shl    $0x18,%eax
8010302d:	50                   	push   %eax
8010302e:	68 c4 00 00 00       	push   $0xc4
80103033:	e8 f2 fd ff ff       	call   80102e2a <lapicw>
80103038:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010303b:	68 00 c5 00 00       	push   $0xc500
80103040:	68 c0 00 00 00       	push   $0xc0
80103045:	e8 e0 fd ff ff       	call   80102e2a <lapicw>
8010304a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010304d:	68 c8 00 00 00       	push   $0xc8
80103052:	e8 87 ff ff ff       	call   80102fde <microdelay>
80103057:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010305a:	68 00 85 00 00       	push   $0x8500
8010305f:	68 c0 00 00 00       	push   $0xc0
80103064:	e8 c1 fd ff ff       	call   80102e2a <lapicw>
80103069:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010306c:	6a 64                	push   $0x64
8010306e:	e8 6b ff ff ff       	call   80102fde <microdelay>
80103073:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103076:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010307d:	eb 3d                	jmp    801030bc <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010307f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103083:	c1 e0 18             	shl    $0x18,%eax
80103086:	50                   	push   %eax
80103087:	68 c4 00 00 00       	push   $0xc4
8010308c:	e8 99 fd ff ff       	call   80102e2a <lapicw>
80103091:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103094:	8b 45 0c             	mov    0xc(%ebp),%eax
80103097:	c1 e8 0c             	shr    $0xc,%eax
8010309a:	80 cc 06             	or     $0x6,%ah
8010309d:	50                   	push   %eax
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 82 fd ff ff       	call   80102e2a <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ab:	68 c8 00 00 00       	push   $0xc8
801030b0:	e8 29 ff ff ff       	call   80102fde <microdelay>
801030b5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030bc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030c0:	7e bd                	jle    8010307f <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030c2:	90                   	nop
801030c3:	c9                   	leave  
801030c4:	c3                   	ret    

801030c5 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030c5:	55                   	push   %ebp
801030c6:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801030c8:	8b 45 08             	mov    0x8(%ebp),%eax
801030cb:	0f b6 c0             	movzbl %al,%eax
801030ce:	50                   	push   %eax
801030cf:	6a 70                	push   $0x70
801030d1:	e8 25 fd ff ff       	call   80102dfb <outb>
801030d6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030d9:	68 c8 00 00 00       	push   $0xc8
801030de:	e8 fb fe ff ff       	call   80102fde <microdelay>
801030e3:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801030e6:	6a 71                	push   $0x71
801030e8:	e8 f1 fc ff ff       	call   80102dde <inb>
801030ed:	83 c4 04             	add    $0x4,%esp
801030f0:	0f b6 c0             	movzbl %al,%eax
}
801030f3:	c9                   	leave  
801030f4:	c3                   	ret    

801030f5 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801030f8:	6a 00                	push   $0x0
801030fa:	e8 c6 ff ff ff       	call   801030c5 <cmos_read>
801030ff:	83 c4 04             	add    $0x4,%esp
80103102:	89 c2                	mov    %eax,%edx
80103104:	8b 45 08             	mov    0x8(%ebp),%eax
80103107:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103109:	6a 02                	push   $0x2
8010310b:	e8 b5 ff ff ff       	call   801030c5 <cmos_read>
80103110:	83 c4 04             	add    $0x4,%esp
80103113:	89 c2                	mov    %eax,%edx
80103115:	8b 45 08             	mov    0x8(%ebp),%eax
80103118:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010311b:	6a 04                	push   $0x4
8010311d:	e8 a3 ff ff ff       	call   801030c5 <cmos_read>
80103122:	83 c4 04             	add    $0x4,%esp
80103125:	89 c2                	mov    %eax,%edx
80103127:	8b 45 08             	mov    0x8(%ebp),%eax
8010312a:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010312d:	6a 07                	push   $0x7
8010312f:	e8 91 ff ff ff       	call   801030c5 <cmos_read>
80103134:	83 c4 04             	add    $0x4,%esp
80103137:	89 c2                	mov    %eax,%edx
80103139:	8b 45 08             	mov    0x8(%ebp),%eax
8010313c:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
8010313f:	6a 08                	push   $0x8
80103141:	e8 7f ff ff ff       	call   801030c5 <cmos_read>
80103146:	83 c4 04             	add    $0x4,%esp
80103149:	89 c2                	mov    %eax,%edx
8010314b:	8b 45 08             	mov    0x8(%ebp),%eax
8010314e:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103151:	6a 09                	push   $0x9
80103153:	e8 6d ff ff ff       	call   801030c5 <cmos_read>
80103158:	83 c4 04             	add    $0x4,%esp
8010315b:	89 c2                	mov    %eax,%edx
8010315d:	8b 45 08             	mov    0x8(%ebp),%eax
80103160:	89 50 14             	mov    %edx,0x14(%eax)
}
80103163:	90                   	nop
80103164:	c9                   	leave  
80103165:	c3                   	ret    

80103166 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103166:	55                   	push   %ebp
80103167:	89 e5                	mov    %esp,%ebp
80103169:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010316c:	6a 0b                	push   $0xb
8010316e:	e8 52 ff ff ff       	call   801030c5 <cmos_read>
80103173:	83 c4 04             	add    $0x4,%esp
80103176:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010317c:	83 e0 04             	and    $0x4,%eax
8010317f:	85 c0                	test   %eax,%eax
80103181:	0f 94 c0             	sete   %al
80103184:	0f b6 c0             	movzbl %al,%eax
80103187:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010318a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010318d:	50                   	push   %eax
8010318e:	e8 62 ff ff ff       	call   801030f5 <fill_rtcdate>
80103193:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103196:	6a 0a                	push   $0xa
80103198:	e8 28 ff ff ff       	call   801030c5 <cmos_read>
8010319d:	83 c4 04             	add    $0x4,%esp
801031a0:	25 80 00 00 00       	and    $0x80,%eax
801031a5:	85 c0                	test   %eax,%eax
801031a7:	75 27                	jne    801031d0 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031a9:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031ac:	50                   	push   %eax
801031ad:	e8 43 ff ff ff       	call   801030f5 <fill_rtcdate>
801031b2:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031b5:	83 ec 04             	sub    $0x4,%esp
801031b8:	6a 18                	push   $0x18
801031ba:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031bd:	50                   	push   %eax
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 4d 2a 00 00       	call   80105c14 <memcmp>
801031c7:	83 c4 10             	add    $0x10,%esp
801031ca:	85 c0                	test   %eax,%eax
801031cc:	74 05                	je     801031d3 <cmostime+0x6d>
801031ce:	eb ba                	jmp    8010318a <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801031d0:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031d1:	eb b7                	jmp    8010318a <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801031d3:	90                   	nop
  }

  // convert
  if (bcd) {
801031d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031d8:	0f 84 b4 00 00 00    	je     80103292 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031de:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031e1:	c1 e8 04             	shr    $0x4,%eax
801031e4:	89 c2                	mov    %eax,%edx
801031e6:	89 d0                	mov    %edx,%eax
801031e8:	c1 e0 02             	shl    $0x2,%eax
801031eb:	01 d0                	add    %edx,%eax
801031ed:	01 c0                	add    %eax,%eax
801031ef:	89 c2                	mov    %eax,%edx
801031f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031f4:	83 e0 0f             	and    $0xf,%eax
801031f7:	01 d0                	add    %edx,%eax
801031f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031ff:	c1 e8 04             	shr    $0x4,%eax
80103202:	89 c2                	mov    %eax,%edx
80103204:	89 d0                	mov    %edx,%eax
80103206:	c1 e0 02             	shl    $0x2,%eax
80103209:	01 d0                	add    %edx,%eax
8010320b:	01 c0                	add    %eax,%eax
8010320d:	89 c2                	mov    %eax,%edx
8010320f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103212:	83 e0 0f             	and    $0xf,%eax
80103215:	01 d0                	add    %edx,%eax
80103217:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010321a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010321d:	c1 e8 04             	shr    $0x4,%eax
80103220:	89 c2                	mov    %eax,%edx
80103222:	89 d0                	mov    %edx,%eax
80103224:	c1 e0 02             	shl    $0x2,%eax
80103227:	01 d0                	add    %edx,%eax
80103229:	01 c0                	add    %eax,%eax
8010322b:	89 c2                	mov    %eax,%edx
8010322d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103230:	83 e0 0f             	and    $0xf,%eax
80103233:	01 d0                	add    %edx,%eax
80103235:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010323b:	c1 e8 04             	shr    $0x4,%eax
8010323e:	89 c2                	mov    %eax,%edx
80103240:	89 d0                	mov    %edx,%eax
80103242:	c1 e0 02             	shl    $0x2,%eax
80103245:	01 d0                	add    %edx,%eax
80103247:	01 c0                	add    %eax,%eax
80103249:	89 c2                	mov    %eax,%edx
8010324b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010324e:	83 e0 0f             	and    $0xf,%eax
80103251:	01 d0                	add    %edx,%eax
80103253:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103256:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103259:	c1 e8 04             	shr    $0x4,%eax
8010325c:	89 c2                	mov    %eax,%edx
8010325e:	89 d0                	mov    %edx,%eax
80103260:	c1 e0 02             	shl    $0x2,%eax
80103263:	01 d0                	add    %edx,%eax
80103265:	01 c0                	add    %eax,%eax
80103267:	89 c2                	mov    %eax,%edx
80103269:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010326c:	83 e0 0f             	and    $0xf,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103274:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103277:	c1 e8 04             	shr    $0x4,%eax
8010327a:	89 c2                	mov    %eax,%edx
8010327c:	89 d0                	mov    %edx,%eax
8010327e:	c1 e0 02             	shl    $0x2,%eax
80103281:	01 d0                	add    %edx,%eax
80103283:	01 c0                	add    %eax,%eax
80103285:	89 c2                	mov    %eax,%edx
80103287:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010328a:	83 e0 0f             	and    $0xf,%eax
8010328d:	01 d0                	add    %edx,%eax
8010328f:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103292:	8b 45 08             	mov    0x8(%ebp),%eax
80103295:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103298:	89 10                	mov    %edx,(%eax)
8010329a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010329d:	89 50 04             	mov    %edx,0x4(%eax)
801032a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032a3:	89 50 08             	mov    %edx,0x8(%eax)
801032a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032a9:	89 50 0c             	mov    %edx,0xc(%eax)
801032ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032af:	89 50 10             	mov    %edx,0x10(%eax)
801032b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032b5:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032b8:	8b 45 08             	mov    0x8(%ebp),%eax
801032bb:	8b 40 14             	mov    0x14(%eax),%eax
801032be:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032c4:	8b 45 08             	mov    0x8(%ebp),%eax
801032c7:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ca:	90                   	nop
801032cb:	c9                   	leave  
801032cc:	c3                   	ret    

801032cd <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
801032cd:	55                   	push   %ebp
801032ce:	89 e5                	mov    %esp,%ebp
801032d0:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032d3:	83 ec 08             	sub    $0x8,%esp
801032d6:	68 78 93 10 80       	push   $0x80109378
801032db:	68 80 32 11 80       	push   $0x80113280
801032e0:	e8 43 26 00 00       	call   80105928 <initlock>
801032e5:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
801032e8:	83 ec 08             	sub    $0x8,%esp
801032eb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032ee:	50                   	push   %eax
801032ef:	6a 01                	push   $0x1
801032f1:	e8 b2 e0 ff ff       	call   801013a8 <readsb>
801032f6:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
801032f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ff:	29 c2                	sub    %eax,%edx
80103301:	89 d0                	mov    %edx,%eax
80103303:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
80103308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330b:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
80103310:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
80103317:	00 00 00 
  recover_from_log();
8010331a:	e8 b2 01 00 00       	call   801034d1 <recover_from_log>
}
8010331f:	90                   	nop
80103320:	c9                   	leave  
80103321:	c3                   	ret    

80103322 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103322:	55                   	push   %ebp
80103323:	89 e5                	mov    %esp,%ebp
80103325:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103328:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010332f:	e9 95 00 00 00       	jmp    801033c9 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103334:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010333a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333d:	01 d0                	add    %edx,%eax
8010333f:	83 c0 01             	add    $0x1,%eax
80103342:	89 c2                	mov    %eax,%edx
80103344:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103349:	83 ec 08             	sub    $0x8,%esp
8010334c:	52                   	push   %edx
8010334d:	50                   	push   %eax
8010334e:	e8 63 ce ff ff       	call   801001b6 <bread>
80103353:	83 c4 10             	add    $0x10,%esp
80103356:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010335c:	83 c0 10             	add    $0x10,%eax
8010335f:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103366:	89 c2                	mov    %eax,%edx
80103368:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010336d:	83 ec 08             	sub    $0x8,%esp
80103370:	52                   	push   %edx
80103371:	50                   	push   %eax
80103372:	e8 3f ce ff ff       	call   801001b6 <bread>
80103377:	83 c4 10             	add    $0x10,%esp
8010337a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010337d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103380:	8d 50 18             	lea    0x18(%eax),%edx
80103383:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103386:	83 c0 18             	add    $0x18,%eax
80103389:	83 ec 04             	sub    $0x4,%esp
8010338c:	68 00 02 00 00       	push   $0x200
80103391:	52                   	push   %edx
80103392:	50                   	push   %eax
80103393:	e8 d4 28 00 00       	call   80105c6c <memmove>
80103398:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010339b:	83 ec 0c             	sub    $0xc,%esp
8010339e:	ff 75 ec             	pushl  -0x14(%ebp)
801033a1:	e8 49 ce ff ff       	call   801001ef <bwrite>
801033a6:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801033a9:	83 ec 0c             	sub    $0xc,%esp
801033ac:	ff 75 f0             	pushl  -0x10(%ebp)
801033af:	e8 7a ce ff ff       	call   8010022e <brelse>
801033b4:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033b7:	83 ec 0c             	sub    $0xc,%esp
801033ba:	ff 75 ec             	pushl  -0x14(%ebp)
801033bd:	e8 6c ce ff ff       	call   8010022e <brelse>
801033c2:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033c9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033ce:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033d1:	0f 8f 5d ff ff ff    	jg     80103334 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033d7:	90                   	nop
801033d8:	c9                   	leave  
801033d9:	c3                   	ret    

801033da <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033da:	55                   	push   %ebp
801033db:	89 e5                	mov    %esp,%ebp
801033dd:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033e0:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801033e5:	89 c2                	mov    %eax,%edx
801033e7:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033ec:	83 ec 08             	sub    $0x8,%esp
801033ef:	52                   	push   %edx
801033f0:	50                   	push   %eax
801033f1:	e8 c0 cd ff ff       	call   801001b6 <bread>
801033f6:	83 c4 10             	add    $0x10,%esp
801033f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ff:	83 c0 18             	add    $0x18,%eax
80103402:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103405:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103408:	8b 00                	mov    (%eax),%eax
8010340a:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
8010340f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103416:	eb 1b                	jmp    80103433 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
80103418:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010341e:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103422:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103425:	83 c2 10             	add    $0x10,%edx
80103428:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010342f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103433:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103438:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010343b:	7f db                	jg     80103418 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010343d:	83 ec 0c             	sub    $0xc,%esp
80103440:	ff 75 f0             	pushl  -0x10(%ebp)
80103443:	e8 e6 cd ff ff       	call   8010022e <brelse>
80103448:	83 c4 10             	add    $0x10,%esp
}
8010344b:	90                   	nop
8010344c:	c9                   	leave  
8010344d:	c3                   	ret    

8010344e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010344e:	55                   	push   %ebp
8010344f:	89 e5                	mov    %esp,%ebp
80103451:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103454:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103459:	89 c2                	mov    %eax,%edx
8010345b:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103460:	83 ec 08             	sub    $0x8,%esp
80103463:	52                   	push   %edx
80103464:	50                   	push   %eax
80103465:	e8 4c cd ff ff       	call   801001b6 <bread>
8010346a:	83 c4 10             	add    $0x10,%esp
8010346d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103473:	83 c0 18             	add    $0x18,%eax
80103476:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103479:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
8010347f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103482:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103484:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010348b:	eb 1b                	jmp    801034a8 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
8010348d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103490:	83 c0 10             	add    $0x10,%eax
80103493:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
8010349a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010349d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a0:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034a8:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034b0:	7f db                	jg     8010348d <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801034b2:	83 ec 0c             	sub    $0xc,%esp
801034b5:	ff 75 f0             	pushl  -0x10(%ebp)
801034b8:	e8 32 cd ff ff       	call   801001ef <bwrite>
801034bd:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034c0:	83 ec 0c             	sub    $0xc,%esp
801034c3:	ff 75 f0             	pushl  -0x10(%ebp)
801034c6:	e8 63 cd ff ff       	call   8010022e <brelse>
801034cb:	83 c4 10             	add    $0x10,%esp
}
801034ce:	90                   	nop
801034cf:	c9                   	leave  
801034d0:	c3                   	ret    

801034d1 <recover_from_log>:

static void
recover_from_log(void)
{
801034d1:	55                   	push   %ebp
801034d2:	89 e5                	mov    %esp,%ebp
801034d4:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034d7:	e8 fe fe ff ff       	call   801033da <read_head>
  install_trans(); // if committed, copy from log to disk
801034dc:	e8 41 fe ff ff       	call   80103322 <install_trans>
  log.lh.n = 0;
801034e1:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801034e8:	00 00 00 
  write_head(); // clear the log
801034eb:	e8 5e ff ff ff       	call   8010344e <write_head>
}
801034f0:	90                   	nop
801034f1:	c9                   	leave  
801034f2:	c3                   	ret    

801034f3 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034f3:	55                   	push   %ebp
801034f4:	89 e5                	mov    %esp,%ebp
801034f6:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801034f9:	83 ec 0c             	sub    $0xc,%esp
801034fc:	68 80 32 11 80       	push   $0x80113280
80103501:	e8 44 24 00 00       	call   8010594a <acquire>
80103506:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103509:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010350e:	85 c0                	test   %eax,%eax
80103510:	74 17                	je     80103529 <begin_op+0x36>
      sleep(&log, &log.lock);
80103512:	83 ec 08             	sub    $0x8,%esp
80103515:	68 80 32 11 80       	push   $0x80113280
8010351a:	68 80 32 11 80       	push   $0x80113280
8010351f:	e8 6a 1c 00 00       	call   8010518e <sleep>
80103524:	83 c4 10             	add    $0x10,%esp
80103527:	eb e0                	jmp    80103509 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103529:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
8010352f:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103534:	8d 50 01             	lea    0x1(%eax),%edx
80103537:	89 d0                	mov    %edx,%eax
80103539:	c1 e0 02             	shl    $0x2,%eax
8010353c:	01 d0                	add    %edx,%eax
8010353e:	01 c0                	add    %eax,%eax
80103540:	01 c8                	add    %ecx,%eax
80103542:	83 f8 1e             	cmp    $0x1e,%eax
80103545:	7e 17                	jle    8010355e <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103547:	83 ec 08             	sub    $0x8,%esp
8010354a:	68 80 32 11 80       	push   $0x80113280
8010354f:	68 80 32 11 80       	push   $0x80113280
80103554:	e8 35 1c 00 00       	call   8010518e <sleep>
80103559:	83 c4 10             	add    $0x10,%esp
8010355c:	eb ab                	jmp    80103509 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010355e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103563:	83 c0 01             	add    $0x1,%eax
80103566:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010356b:	83 ec 0c             	sub    $0xc,%esp
8010356e:	68 80 32 11 80       	push   $0x80113280
80103573:	e8 39 24 00 00       	call   801059b1 <release>
80103578:	83 c4 10             	add    $0x10,%esp
      break;
8010357b:	90                   	nop
    }
  }
}
8010357c:	90                   	nop
8010357d:	c9                   	leave  
8010357e:	c3                   	ret    

8010357f <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010357f:	55                   	push   %ebp
80103580:	89 e5                	mov    %esp,%ebp
80103582:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103585:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010358c:	83 ec 0c             	sub    $0xc,%esp
8010358f:	68 80 32 11 80       	push   $0x80113280
80103594:	e8 b1 23 00 00       	call   8010594a <acquire>
80103599:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010359c:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801035a1:	83 e8 01             	sub    $0x1,%eax
801035a4:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801035a9:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801035ae:	85 c0                	test   %eax,%eax
801035b0:	74 0d                	je     801035bf <end_op+0x40>
    panic("log.committing");
801035b2:	83 ec 0c             	sub    $0xc,%esp
801035b5:	68 7c 93 10 80       	push   $0x8010937c
801035ba:	e8 a7 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801035bf:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801035c4:	85 c0                	test   %eax,%eax
801035c6:	75 13                	jne    801035db <end_op+0x5c>
    do_commit = 1;
801035c8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035cf:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801035d6:	00 00 00 
801035d9:	eb 10                	jmp    801035eb <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801035db:	83 ec 0c             	sub    $0xc,%esp
801035de:	68 80 32 11 80       	push   $0x80113280
801035e3:	e8 b2 1c 00 00       	call   8010529a <wakeup>
801035e8:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801035eb:	83 ec 0c             	sub    $0xc,%esp
801035ee:	68 80 32 11 80       	push   $0x80113280
801035f3:	e8 b9 23 00 00       	call   801059b1 <release>
801035f8:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801035fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035ff:	74 3f                	je     80103640 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103601:	e8 f5 00 00 00       	call   801036fb <commit>
    acquire(&log.lock);
80103606:	83 ec 0c             	sub    $0xc,%esp
80103609:	68 80 32 11 80       	push   $0x80113280
8010360e:	e8 37 23 00 00       	call   8010594a <acquire>
80103613:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103616:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
8010361d:	00 00 00 
    wakeup(&log);
80103620:	83 ec 0c             	sub    $0xc,%esp
80103623:	68 80 32 11 80       	push   $0x80113280
80103628:	e8 6d 1c 00 00       	call   8010529a <wakeup>
8010362d:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103630:	83 ec 0c             	sub    $0xc,%esp
80103633:	68 80 32 11 80       	push   $0x80113280
80103638:	e8 74 23 00 00       	call   801059b1 <release>
8010363d:	83 c4 10             	add    $0x10,%esp
  }
}
80103640:	90                   	nop
80103641:	c9                   	leave  
80103642:	c3                   	ret    

80103643 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103643:	55                   	push   %ebp
80103644:	89 e5                	mov    %esp,%ebp
80103646:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103649:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103650:	e9 95 00 00 00       	jmp    801036ea <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103655:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010365e:	01 d0                	add    %edx,%eax
80103660:	83 c0 01             	add    $0x1,%eax
80103663:	89 c2                	mov    %eax,%edx
80103665:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010366a:	83 ec 08             	sub    $0x8,%esp
8010366d:	52                   	push   %edx
8010366e:	50                   	push   %eax
8010366f:	e8 42 cb ff ff       	call   801001b6 <bread>
80103674:	83 c4 10             	add    $0x10,%esp
80103677:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010367a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010367d:	83 c0 10             	add    $0x10,%eax
80103680:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103687:	89 c2                	mov    %eax,%edx
80103689:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010368e:	83 ec 08             	sub    $0x8,%esp
80103691:	52                   	push   %edx
80103692:	50                   	push   %eax
80103693:	e8 1e cb ff ff       	call   801001b6 <bread>
80103698:	83 c4 10             	add    $0x10,%esp
8010369b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010369e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036a1:	8d 50 18             	lea    0x18(%eax),%edx
801036a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a7:	83 c0 18             	add    $0x18,%eax
801036aa:	83 ec 04             	sub    $0x4,%esp
801036ad:	68 00 02 00 00       	push   $0x200
801036b2:	52                   	push   %edx
801036b3:	50                   	push   %eax
801036b4:	e8 b3 25 00 00       	call   80105c6c <memmove>
801036b9:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036bc:	83 ec 0c             	sub    $0xc,%esp
801036bf:	ff 75 f0             	pushl  -0x10(%ebp)
801036c2:	e8 28 cb ff ff       	call   801001ef <bwrite>
801036c7:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801036ca:	83 ec 0c             	sub    $0xc,%esp
801036cd:	ff 75 ec             	pushl  -0x14(%ebp)
801036d0:	e8 59 cb ff ff       	call   8010022e <brelse>
801036d5:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801036d8:	83 ec 0c             	sub    $0xc,%esp
801036db:	ff 75 f0             	pushl  -0x10(%ebp)
801036de:	e8 4b cb ff ff       	call   8010022e <brelse>
801036e3:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036ea:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036f2:	0f 8f 5d ff ff ff    	jg     80103655 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801036f8:	90                   	nop
801036f9:	c9                   	leave  
801036fa:	c3                   	ret    

801036fb <commit>:

static void
commit()
{
801036fb:	55                   	push   %ebp
801036fc:	89 e5                	mov    %esp,%ebp
801036fe:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103701:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103706:	85 c0                	test   %eax,%eax
80103708:	7e 1e                	jle    80103728 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010370a:	e8 34 ff ff ff       	call   80103643 <write_log>
    write_head();    // Write header to disk -- the real commit
8010370f:	e8 3a fd ff ff       	call   8010344e <write_head>
    install_trans(); // Now install writes to home locations
80103714:	e8 09 fc ff ff       	call   80103322 <install_trans>
    log.lh.n = 0; 
80103719:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103720:	00 00 00 
    write_head();    // Erase the transaction from the log
80103723:	e8 26 fd ff ff       	call   8010344e <write_head>
  }
}
80103728:	90                   	nop
80103729:	c9                   	leave  
8010372a:	c3                   	ret    

8010372b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010372b:	55                   	push   %ebp
8010372c:	89 e5                	mov    %esp,%ebp
8010372e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103731:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103736:	83 f8 1d             	cmp    $0x1d,%eax
80103739:	7f 12                	jg     8010374d <log_write+0x22>
8010373b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103740:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103746:	83 ea 01             	sub    $0x1,%edx
80103749:	39 d0                	cmp    %edx,%eax
8010374b:	7c 0d                	jl     8010375a <log_write+0x2f>
    panic("too big a transaction");
8010374d:	83 ec 0c             	sub    $0xc,%esp
80103750:	68 8b 93 10 80       	push   $0x8010938b
80103755:	e8 0c ce ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010375a:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010375f:	85 c0                	test   %eax,%eax
80103761:	7f 0d                	jg     80103770 <log_write+0x45>
    panic("log_write outside of trans");
80103763:	83 ec 0c             	sub    $0xc,%esp
80103766:	68 a1 93 10 80       	push   $0x801093a1
8010376b:	e8 f6 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103770:	83 ec 0c             	sub    $0xc,%esp
80103773:	68 80 32 11 80       	push   $0x80113280
80103778:	e8 cd 21 00 00       	call   8010594a <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	eb 1d                	jmp    801037a6 <log_write+0x7b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010378c:	83 c0 10             	add    $0x10,%eax
8010378f:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103796:	89 c2                	mov    %eax,%edx
80103798:	8b 45 08             	mov    0x8(%ebp),%eax
8010379b:	8b 40 08             	mov    0x8(%eax),%eax
8010379e:	39 c2                	cmp    %eax,%edx
801037a0:	74 10                	je     801037b2 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037a6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037ab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ae:	7f d9                	jg     80103789 <log_write+0x5e>
801037b0:	eb 01                	jmp    801037b3 <log_write+0x88>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
801037b2:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801037b3:	8b 45 08             	mov    0x8(%ebp),%eax
801037b6:	8b 40 08             	mov    0x8(%eax),%eax
801037b9:	89 c2                	mov    %eax,%edx
801037bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037be:	83 c0 10             	add    $0x10,%eax
801037c1:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801037c8:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037d0:	75 0d                	jne    801037df <log_write+0xb4>
    log.lh.n++;
801037d2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037d7:	83 c0 01             	add    $0x1,%eax
801037da:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801037df:	8b 45 08             	mov    0x8(%ebp),%eax
801037e2:	8b 00                	mov    (%eax),%eax
801037e4:	83 c8 04             	or     $0x4,%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 08             	mov    0x8(%ebp),%eax
801037ec:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037ee:	83 ec 0c             	sub    $0xc,%esp
801037f1:	68 80 32 11 80       	push   $0x80113280
801037f6:	e8 b6 21 00 00       	call   801059b1 <release>
801037fb:	83 c4 10             	add    $0x10,%esp
}
801037fe:	90                   	nop
801037ff:	c9                   	leave  
80103800:	c3                   	ret    

80103801 <v2p>:
80103801:	55                   	push   %ebp
80103802:	89 e5                	mov    %esp,%ebp
80103804:	8b 45 08             	mov    0x8(%ebp),%eax
80103807:	05 00 00 00 80       	add    $0x80000000,%eax
8010380c:	5d                   	pop    %ebp
8010380d:	c3                   	ret    

8010380e <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010380e:	55                   	push   %ebp
8010380f:	89 e5                	mov    %esp,%ebp
80103811:	8b 45 08             	mov    0x8(%ebp),%eax
80103814:	05 00 00 00 80       	add    $0x80000000,%eax
80103819:	5d                   	pop    %ebp
8010381a:	c3                   	ret    

8010381b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010381b:	55                   	push   %ebp
8010381c:	89 e5                	mov    %esp,%ebp
8010381e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103821:	8b 55 08             	mov    0x8(%ebp),%edx
80103824:	8b 45 0c             	mov    0xc(%ebp),%eax
80103827:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010382a:	f0 87 02             	lock xchg %eax,(%edx)
8010382d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103830:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103833:	c9                   	leave  
80103834:	c3                   	ret    

80103835 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103835:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103839:	83 e4 f0             	and    $0xfffffff0,%esp
8010383c:	ff 71 fc             	pushl  -0x4(%ecx)
8010383f:	55                   	push   %ebp
80103840:	89 e5                	mov    %esp,%ebp
80103842:	51                   	push   %ecx
80103843:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103846:	83 ec 08             	sub    $0x8,%esp
80103849:	68 00 00 40 80       	push   $0x80400000
8010384e:	68 bc 81 11 80       	push   $0x801181bc
80103853:	e8 75 f2 ff ff       	call   80102acd <kinit1>
80103858:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010385b:	e8 a7 51 00 00       	call   80108a07 <kvmalloc>
  mpinit();        // collect info about this machine
80103860:	e8 89 05 00 00       	call   80103dee <mpinit>
  lapicinit();
80103865:	e8 e2 f5 ff ff       	call   80102e4c <lapicinit>
  seginit();       // set up segments
8010386a:	e8 41 4b 00 00       	call   801083b0 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010386f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103875:	0f b6 00             	movzbl (%eax),%eax
80103878:	0f b6 c0             	movzbl %al,%eax
8010387b:	83 ec 08             	sub    $0x8,%esp
8010387e:	50                   	push   %eax
8010387f:	68 bc 93 10 80       	push   $0x801093bc
80103884:	e8 3d cb ff ff       	call   801003c6 <cprintf>
80103889:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010388c:	e8 b3 07 00 00       	call   80104044 <picinit>
  ioapicinit();    // another interrupt controller
80103891:	e8 2c f1 ff ff       	call   801029c2 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103896:	e8 4e d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
8010389b:	e8 6c 3e 00 00       	call   8010770c <uartinit>
  pinit();         // process table
801038a0:	e8 28 0f 00 00       	call   801047cd <pinit>
  tvinit();        // trap vectors
801038a5:	e8 32 39 00 00       	call   801071dc <tvinit>
  binit();         // buffer cache
801038aa:	e8 85 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038af:	e8 ae d6 ff ff       	call   80100f62 <fileinit>
  seminit();       // semaphore table
801038b4:	e8 bf 1b 00 00       	call   80105478 <seminit>
  iinit();         // inode cache
801038b9:	e8 b9 dd ff ff       	call   80101677 <iinit>
  ideinit();       // disk
801038be:	e8 43 ed ff ff       	call   80102606 <ideinit>
  if(!ismp)
801038c3:	a1 64 33 11 80       	mov    0x80113364,%eax
801038c8:	85 c0                	test   %eax,%eax
801038ca:	75 05                	jne    801038d1 <main+0x9c>
    timerinit();   // uniprocessor timer
801038cc:	e8 68 38 00 00       	call   80107139 <timerinit>
  startothers();   // start other processors
801038d1:	e8 7f 00 00 00       	call   80103955 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038d6:	83 ec 08             	sub    $0x8,%esp
801038d9:	68 00 00 00 8e       	push   $0x8e000000
801038de:	68 00 00 40 80       	push   $0x80400000
801038e3:	e8 1e f2 ff ff       	call   80102b06 <kinit2>
801038e8:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038eb:	e8 19 10 00 00       	call   80104909 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801038f0:	e8 1a 00 00 00       	call   8010390f <mpmain>

801038f5 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038f5:	55                   	push   %ebp
801038f6:	89 e5                	mov    %esp,%ebp
801038f8:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038fb:	e8 1f 51 00 00       	call   80108a1f <switchkvm>
  seginit();
80103900:	e8 ab 4a 00 00       	call   801083b0 <seginit>
  lapicinit();
80103905:	e8 42 f5 ff ff       	call   80102e4c <lapicinit>
  mpmain();
8010390a:	e8 00 00 00 00       	call   8010390f <mpmain>

8010390f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010390f:	55                   	push   %ebp
80103910:	89 e5                	mov    %esp,%ebp
80103912:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103915:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010391b:	0f b6 00             	movzbl (%eax),%eax
8010391e:	0f b6 c0             	movzbl %al,%eax
80103921:	83 ec 08             	sub    $0x8,%esp
80103924:	50                   	push   %eax
80103925:	68 d3 93 10 80       	push   $0x801093d3
8010392a:	e8 97 ca ff ff       	call   801003c6 <cprintf>
8010392f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103932:	e8 1b 3a 00 00       	call   80107352 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103937:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010393d:	05 a8 00 00 00       	add    $0xa8,%eax
80103942:	83 ec 08             	sub    $0x8,%esp
80103945:	6a 01                	push   $0x1
80103947:	50                   	push   %eax
80103948:	e8 ce fe ff ff       	call   8010381b <xchg>
8010394d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103950:	e8 2b 16 00 00       	call   80104f80 <scheduler>

80103955 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103955:	55                   	push   %ebp
80103956:	89 e5                	mov    %esp,%ebp
80103958:	53                   	push   %ebx
80103959:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010395c:	68 00 70 00 00       	push   $0x7000
80103961:	e8 a8 fe ff ff       	call   8010380e <p2v>
80103966:	83 c4 04             	add    $0x4,%esp
80103969:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010396c:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103971:	83 ec 04             	sub    $0x4,%esp
80103974:	50                   	push   %eax
80103975:	68 2c c5 10 80       	push   $0x8010c52c
8010397a:	ff 75 f0             	pushl  -0x10(%ebp)
8010397d:	e8 ea 22 00 00       	call   80105c6c <memmove>
80103982:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103985:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
8010398c:	e9 90 00 00 00       	jmp    80103a21 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103991:	e8 d4 f5 ff ff       	call   80102f6a <cpunum>
80103996:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010399c:	05 80 33 11 80       	add    $0x80113380,%eax
801039a1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039a4:	74 73                	je     80103a19 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039a6:	e8 59 f2 ff ff       	call   80102c04 <kalloc>
801039ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b1:	83 e8 04             	sub    $0x4,%eax
801039b4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039b7:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039bd:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c2:	83 e8 08             	sub    $0x8,%eax
801039c5:	c7 00 f5 38 10 80    	movl   $0x801038f5,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801039cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ce:	8d 58 f4             	lea    -0xc(%eax),%ebx
801039d1:	83 ec 0c             	sub    $0xc,%esp
801039d4:	68 00 b0 10 80       	push   $0x8010b000
801039d9:	e8 23 fe ff ff       	call   80103801 <v2p>
801039de:	83 c4 10             	add    $0x10,%esp
801039e1:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801039e3:	83 ec 0c             	sub    $0xc,%esp
801039e6:	ff 75 f0             	pushl  -0x10(%ebp)
801039e9:	e8 13 fe ff ff       	call   80103801 <v2p>
801039ee:	83 c4 10             	add    $0x10,%esp
801039f1:	89 c2                	mov    %eax,%edx
801039f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f6:	0f b6 00             	movzbl (%eax),%eax
801039f9:	0f b6 c0             	movzbl %al,%eax
801039fc:	83 ec 08             	sub    $0x8,%esp
801039ff:	52                   	push   %edx
80103a00:	50                   	push   %eax
80103a01:	e8 de f5 ff ff       	call   80102fe4 <lapicstartap>
80103a06:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a09:	90                   	nop
80103a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a0d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a13:	85 c0                	test   %eax,%eax
80103a15:	74 f3                	je     80103a0a <startothers+0xb5>
80103a17:	eb 01                	jmp    80103a1a <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a19:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a1a:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a21:	a1 60 39 11 80       	mov    0x80113960,%eax
80103a26:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a2c:	05 80 33 11 80       	add    $0x80113380,%eax
80103a31:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a34:	0f 87 57 ff ff ff    	ja     80103991 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a3a:	90                   	nop
80103a3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a3e:	c9                   	leave  
80103a3f:	c3                   	ret    

80103a40 <mmap>:
#include "mmu.h"
#include "proc.h"

int
mmap(int fd, int mode, char ** addr )
{
80103a40:	55                   	push   %ebp
80103a41:	89 e5                	mov    %esp,%ebp
80103a43:	83 ec 10             	sub    $0x10,%esp
  int indexommap;
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd>=0&&fd<NOFILE&&proc->ofile[fd]!=0){
80103a46:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103a4a:	78 36                	js     80103a82 <mmap+0x42>
80103a4c:	83 7d 08 0f          	cmpl   $0xf,0x8(%ebp)
80103a50:	7f 30                	jg     80103a82 <mmap+0x42>
80103a52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a58:	8b 55 08             	mov    0x8(%ebp),%edx
80103a5b:	83 c2 08             	add    $0x8,%edx
80103a5e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103a62:	85 c0                	test   %eax,%eax
80103a64:	74 1c                	je     80103a82 <mmap+0x42>
    fileformap=proc->ofile[fd];
80103a66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a6c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a6f:	83 c2 08             	add    $0x8,%edx
80103a72:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103a76:	89 45 f8             	mov    %eax,-0x8(%ebp)
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
80103a79:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a80:	eb 25                	jmp    80103aa7 <mmap+0x67>
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd>=0&&fd<NOFILE&&proc->ofile[fd]!=0){
    fileformap=proc->ofile[fd];
  }else{
    return -1;
80103a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a87:	e9 e4 00 00 00       	jmp    80103b70 <mmap+0x130>
  }
  //buscar espacio libre en ommap
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
    if(proc->ommap[indexommap].pfile==0){
80103a8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a95:	83 c2 0a             	add    $0xa,%edx
80103a98:	c1 e2 04             	shl    $0x4,%edx
80103a9b:	01 d0                	add    %edx,%eax
80103a9d:	8b 00                	mov    (%eax),%eax
80103a9f:	85 c0                	test   %eax,%eax
80103aa1:	74 0c                	je     80103aaf <mmap+0x6f>
    fileformap=proc->ofile[fd];
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap=0;indexommap<MAXMAPPEDFILES;indexommap++){
80103aa3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103aa7:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80103aab:	7e df                	jle    80103a8c <mmap+0x4c>
80103aad:	eb 01                	jmp    80103ab0 <mmap+0x70>
    if(proc->ommap[indexommap].pfile==0){
      break;
80103aaf:	90                   	nop
    }
  }

  //guardar estructura
  if(indexommap<MAXMAPPEDFILES){
80103ab0:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80103ab4:	0f 8f b1 00 00 00    	jg     80103b6b <mmap+0x12b>

    proc->ommap[indexommap].pfile=fileformap;
80103aba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ac0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ac3:	83 c2 0a             	add    $0xa,%edx
80103ac6:	c1 e2 04             	shl    $0x4,%edx
80103ac9:	01 c2                	add    %eax,%edx
80103acb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103ace:	89 02                	mov    %eax,(%edx)
    proc->ommap[indexommap].mode = mode;
80103ad0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ad9:	89 d1                	mov    %edx,%ecx
80103adb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ade:	83 c2 0a             	add    $0xa,%edx
80103ae1:	c1 e2 04             	shl    $0x4,%edx
80103ae4:	01 d0                	add    %edx,%eax
80103ae6:	83 c0 0c             	add    $0xc,%eax
80103ae9:	66 89 08             	mov    %cx,(%eax)
    proc->ommap[indexommap].sz = fileformap->ip->size;
80103aec:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103af3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103af6:	8b 40 10             	mov    0x10(%eax),%eax
80103af9:	8b 40 18             	mov    0x18(%eax),%eax
80103afc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80103aff:	83 c1 0a             	add    $0xa,%ecx
80103b02:	c1 e1 04             	shl    $0x4,%ecx
80103b05:	01 ca                	add    %ecx,%edx
80103b07:	83 c2 08             	add    $0x8,%edx
80103b0a:	89 02                	mov    %eax,(%edx)

    proc->ommap[indexommap].va=proc->sz;
80103b0c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b19:	8b 00                	mov    (%eax),%eax
80103b1b:	8b 4d fc             	mov    -0x4(%ebp),%ecx
80103b1e:	83 c1 0a             	add    $0xa,%ecx
80103b21:	c1 e1 04             	shl    $0x4,%ecx
80103b24:	01 ca                	add    %ecx,%edx
80103b26:	83 c2 04             	add    $0x4,%edx
80103b29:	89 02                	mov    %eax,(%edx)
    proc->sz =proc->sz+fileformap->ip->size;
80103b2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b31:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b38:	8b 0a                	mov    (%edx),%ecx
80103b3a:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103b3d:	8b 52 10             	mov    0x10(%edx),%edx
80103b40:	8b 52 18             	mov    0x18(%edx),%edx
80103b43:	01 ca                	add    %ecx,%edx
80103b45:	89 10                	mov    %edx,(%eax)

    //*adrr = dir de memoria virtual donde empieza el archivo
    *addr =(void *) proc->ommap[indexommap].va;
80103b47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b50:	83 c2 0a             	add    $0xa,%edx
80103b53:	c1 e2 04             	shl    $0x4,%edx
80103b56:	01 d0                	add    %edx,%eax
80103b58:	83 c0 04             	add    $0x4,%eax
80103b5b:	8b 00                	mov    (%eax),%eax
80103b5d:	89 c2                	mov    %eax,%edx
80103b5f:	8b 45 10             	mov    0x10(%ebp),%eax
80103b62:	89 10                	mov    %edx,(%eax)

    return 0;
80103b64:	b8 00 00 00 00       	mov    $0x0,%eax
80103b69:	eb 05                	jmp    80103b70 <mmap+0x130>

  }else{
    return -2;
80103b6b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  }




}
80103b70:	c9                   	leave  
80103b71:	c3                   	ret    

80103b72 <munmap>:

int
munmap(char * addr)
{
80103b72:	55                   	push   %ebp
80103b73:	89 e5                	mov    %esp,%ebp
 //buscar  ommap que archivo mapeado usa esa direccion de mem
 //verificar paginas dirty,y guardar cada pagina dirty en el archivo
return 0;
80103b75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b7a:	5d                   	pop    %ebp
80103b7b:	c3                   	ret    

80103b7c <p2v>:
80103b7c:	55                   	push   %ebp
80103b7d:	89 e5                	mov    %esp,%ebp
80103b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b82:	05 00 00 00 80       	add    $0x80000000,%eax
80103b87:	5d                   	pop    %ebp
80103b88:	c3                   	ret    

80103b89 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103b89:	55                   	push   %ebp
80103b8a:	89 e5                	mov    %esp,%ebp
80103b8c:	83 ec 14             	sub    $0x14,%esp
80103b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b92:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b96:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b9a:	89 c2                	mov    %eax,%edx
80103b9c:	ec                   	in     (%dx),%al
80103b9d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ba0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ba4:	c9                   	leave  
80103ba5:	c3                   	ret    

80103ba6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ba6:	55                   	push   %ebp
80103ba7:	89 e5                	mov    %esp,%ebp
80103ba9:	83 ec 08             	sub    $0x8,%esp
80103bac:	8b 55 08             	mov    0x8(%ebp),%edx
80103baf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bb2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103bb6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103bb9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103bbd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103bc1:	ee                   	out    %al,(%dx)
}
80103bc2:	90                   	nop
80103bc3:	c9                   	leave  
80103bc4:	c3                   	ret    

80103bc5 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103bc5:	55                   	push   %ebp
80103bc6:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103bc8:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103bcd:	89 c2                	mov    %eax,%edx
80103bcf:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103bd4:	29 c2                	sub    %eax,%edx
80103bd6:	89 d0                	mov    %edx,%eax
80103bd8:	c1 f8 02             	sar    $0x2,%eax
80103bdb:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103be1:	5d                   	pop    %ebp
80103be2:	c3                   	ret    

80103be3 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103be3:	55                   	push   %ebp
80103be4:	89 e5                	mov    %esp,%ebp
80103be6:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103be9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103bf0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103bf7:	eb 15                	jmp    80103c0e <sum+0x2b>
    sum += addr[i];
80103bf9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bff:	01 d0                	add    %edx,%eax
80103c01:	0f b6 00             	movzbl (%eax),%eax
80103c04:	0f b6 c0             	movzbl %al,%eax
80103c07:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103c0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c11:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c14:	7c e3                	jl     80103bf9 <sum+0x16>
    sum += addr[i];
  return sum;
80103c16:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c19:	c9                   	leave  
80103c1a:	c3                   	ret    

80103c1b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c1b:	55                   	push   %ebp
80103c1c:	89 e5                	mov    %esp,%ebp
80103c1e:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103c21:	ff 75 08             	pushl  0x8(%ebp)
80103c24:	e8 53 ff ff ff       	call   80103b7c <p2v>
80103c29:	83 c4 04             	add    $0x4,%esp
80103c2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c35:	01 d0                	add    %edx,%eax
80103c37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c40:	eb 36                	jmp    80103c78 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c42:	83 ec 04             	sub    $0x4,%esp
80103c45:	6a 04                	push   $0x4
80103c47:	68 e4 93 10 80       	push   $0x801093e4
80103c4c:	ff 75 f4             	pushl  -0xc(%ebp)
80103c4f:	e8 c0 1f 00 00       	call   80105c14 <memcmp>
80103c54:	83 c4 10             	add    $0x10,%esp
80103c57:	85 c0                	test   %eax,%eax
80103c59:	75 19                	jne    80103c74 <mpsearch1+0x59>
80103c5b:	83 ec 08             	sub    $0x8,%esp
80103c5e:	6a 10                	push   $0x10
80103c60:	ff 75 f4             	pushl  -0xc(%ebp)
80103c63:	e8 7b ff ff ff       	call   80103be3 <sum>
80103c68:	83 c4 10             	add    $0x10,%esp
80103c6b:	84 c0                	test   %al,%al
80103c6d:	75 05                	jne    80103c74 <mpsearch1+0x59>
      return (struct mp*)p;
80103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c72:	eb 11                	jmp    80103c85 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c74:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c7e:	72 c2                	jb     80103c42 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c85:	c9                   	leave  
80103c86:	c3                   	ret    

80103c87 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c87:	55                   	push   %ebp
80103c88:	89 e5                	mov    %esp,%ebp
80103c8a:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c8d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c97:	83 c0 0f             	add    $0xf,%eax
80103c9a:	0f b6 00             	movzbl (%eax),%eax
80103c9d:	0f b6 c0             	movzbl %al,%eax
80103ca0:	c1 e0 08             	shl    $0x8,%eax
80103ca3:	89 c2                	mov    %eax,%edx
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	83 c0 0e             	add    $0xe,%eax
80103cab:	0f b6 00             	movzbl (%eax),%eax
80103cae:	0f b6 c0             	movzbl %al,%eax
80103cb1:	09 d0                	or     %edx,%eax
80103cb3:	c1 e0 04             	shl    $0x4,%eax
80103cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103cb9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cbd:	74 21                	je     80103ce0 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103cbf:	83 ec 08             	sub    $0x8,%esp
80103cc2:	68 00 04 00 00       	push   $0x400
80103cc7:	ff 75 f0             	pushl  -0x10(%ebp)
80103cca:	e8 4c ff ff ff       	call   80103c1b <mpsearch1>
80103ccf:	83 c4 10             	add    $0x10,%esp
80103cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cd5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cd9:	74 51                	je     80103d2c <mpsearch+0xa5>
      return mp;
80103cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cde:	eb 61                	jmp    80103d41 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce3:	83 c0 14             	add    $0x14,%eax
80103ce6:	0f b6 00             	movzbl (%eax),%eax
80103ce9:	0f b6 c0             	movzbl %al,%eax
80103cec:	c1 e0 08             	shl    $0x8,%eax
80103cef:	89 c2                	mov    %eax,%edx
80103cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf4:	83 c0 13             	add    $0x13,%eax
80103cf7:	0f b6 00             	movzbl (%eax),%eax
80103cfa:	0f b6 c0             	movzbl %al,%eax
80103cfd:	09 d0                	or     %edx,%eax
80103cff:	c1 e0 0a             	shl    $0xa,%eax
80103d02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d08:	2d 00 04 00 00       	sub    $0x400,%eax
80103d0d:	83 ec 08             	sub    $0x8,%esp
80103d10:	68 00 04 00 00       	push   $0x400
80103d15:	50                   	push   %eax
80103d16:	e8 00 ff ff ff       	call   80103c1b <mpsearch1>
80103d1b:	83 c4 10             	add    $0x10,%esp
80103d1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d25:	74 05                	je     80103d2c <mpsearch+0xa5>
      return mp;
80103d27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d2a:	eb 15                	jmp    80103d41 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d2c:	83 ec 08             	sub    $0x8,%esp
80103d2f:	68 00 00 01 00       	push   $0x10000
80103d34:	68 00 00 0f 00       	push   $0xf0000
80103d39:	e8 dd fe ff ff       	call   80103c1b <mpsearch1>
80103d3e:	83 c4 10             	add    $0x10,%esp
}
80103d41:	c9                   	leave  
80103d42:	c3                   	ret    

80103d43 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d43:	55                   	push   %ebp
80103d44:	89 e5                	mov    %esp,%ebp
80103d46:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d49:	e8 39 ff ff ff       	call   80103c87 <mpsearch>
80103d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d55:	74 0a                	je     80103d61 <mpconfig+0x1e>
80103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5a:	8b 40 04             	mov    0x4(%eax),%eax
80103d5d:	85 c0                	test   %eax,%eax
80103d5f:	75 0a                	jne    80103d6b <mpconfig+0x28>
    return 0;
80103d61:	b8 00 00 00 00       	mov    $0x0,%eax
80103d66:	e9 81 00 00 00       	jmp    80103dec <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6e:	8b 40 04             	mov    0x4(%eax),%eax
80103d71:	83 ec 0c             	sub    $0xc,%esp
80103d74:	50                   	push   %eax
80103d75:	e8 02 fe ff ff       	call   80103b7c <p2v>
80103d7a:	83 c4 10             	add    $0x10,%esp
80103d7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d80:	83 ec 04             	sub    $0x4,%esp
80103d83:	6a 04                	push   $0x4
80103d85:	68 e9 93 10 80       	push   $0x801093e9
80103d8a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d8d:	e8 82 1e 00 00       	call   80105c14 <memcmp>
80103d92:	83 c4 10             	add    $0x10,%esp
80103d95:	85 c0                	test   %eax,%eax
80103d97:	74 07                	je     80103da0 <mpconfig+0x5d>
    return 0;
80103d99:	b8 00 00 00 00       	mov    $0x0,%eax
80103d9e:	eb 4c                	jmp    80103dec <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103da3:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103da7:	3c 01                	cmp    $0x1,%al
80103da9:	74 12                	je     80103dbd <mpconfig+0x7a>
80103dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dae:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103db2:	3c 04                	cmp    $0x4,%al
80103db4:	74 07                	je     80103dbd <mpconfig+0x7a>
    return 0;
80103db6:	b8 00 00 00 00       	mov    $0x0,%eax
80103dbb:	eb 2f                	jmp    80103dec <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103dc4:	0f b7 c0             	movzwl %ax,%eax
80103dc7:	83 ec 08             	sub    $0x8,%esp
80103dca:	50                   	push   %eax
80103dcb:	ff 75 f0             	pushl  -0x10(%ebp)
80103dce:	e8 10 fe ff ff       	call   80103be3 <sum>
80103dd3:	83 c4 10             	add    $0x10,%esp
80103dd6:	84 c0                	test   %al,%al
80103dd8:	74 07                	je     80103de1 <mpconfig+0x9e>
    return 0;
80103dda:	b8 00 00 00 00       	mov    $0x0,%eax
80103ddf:	eb 0b                	jmp    80103dec <mpconfig+0xa9>
  *pmp = mp;
80103de1:	8b 45 08             	mov    0x8(%ebp),%eax
80103de4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103de7:	89 10                	mov    %edx,(%eax)
  return conf;
80103de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103dec:	c9                   	leave  
80103ded:	c3                   	ret    

80103dee <mpinit>:

void
mpinit(void)
{
80103dee:	55                   	push   %ebp
80103def:	89 e5                	mov    %esp,%ebp
80103df1:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103df4:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103dfb:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103dfe:	83 ec 0c             	sub    $0xc,%esp
80103e01:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103e04:	50                   	push   %eax
80103e05:	e8 39 ff ff ff       	call   80103d43 <mpconfig>
80103e0a:	83 c4 10             	add    $0x10,%esp
80103e0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e14:	0f 84 96 01 00 00    	je     80103fb0 <mpinit+0x1c2>
    return;
  ismp = 1;
80103e1a:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103e21:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e27:	8b 40 24             	mov    0x24(%eax),%eax
80103e2a:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e32:	83 c0 2c             	add    $0x2c,%eax
80103e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e3b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e3f:	0f b7 d0             	movzwl %ax,%edx
80103e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e45:	01 d0                	add    %edx,%eax
80103e47:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e4a:	e9 f2 00 00 00       	jmp    80103f41 <mpinit+0x153>
    switch(*p){
80103e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e52:	0f b6 00             	movzbl (%eax),%eax
80103e55:	0f b6 c0             	movzbl %al,%eax
80103e58:	83 f8 04             	cmp    $0x4,%eax
80103e5b:	0f 87 bc 00 00 00    	ja     80103f1d <mpinit+0x12f>
80103e61:	8b 04 85 2c 94 10 80 	mov    -0x7fef6bd4(,%eax,4),%eax
80103e68:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e73:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e77:	0f b6 d0             	movzbl %al,%edx
80103e7a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e7f:	39 c2                	cmp    %eax,%edx
80103e81:	74 2b                	je     80103eae <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e86:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e8a:	0f b6 d0             	movzbl %al,%edx
80103e8d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e92:	83 ec 04             	sub    $0x4,%esp
80103e95:	52                   	push   %edx
80103e96:	50                   	push   %eax
80103e97:	68 ee 93 10 80       	push   $0x801093ee
80103e9c:	e8 25 c5 ff ff       	call   801003c6 <cprintf>
80103ea1:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103ea4:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103eab:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103eae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103eb1:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103eb5:	0f b6 c0             	movzbl %al,%eax
80103eb8:	83 e0 02             	and    $0x2,%eax
80103ebb:	85 c0                	test   %eax,%eax
80103ebd:	74 15                	je     80103ed4 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103ebf:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ec4:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103eca:	05 80 33 11 80       	add    $0x80113380,%eax
80103ecf:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103ed4:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ed9:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103edf:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ee5:	05 80 33 11 80       	add    $0x80113380,%eax
80103eea:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103eec:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ef1:	83 c0 01             	add    $0x1,%eax
80103ef4:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103ef9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103efd:	eb 42                	jmp    80103f41 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f08:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f0c:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103f11:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f15:	eb 2a                	jmp    80103f41 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f17:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f1b:	eb 24                	jmp    80103f41 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f20:	0f b6 00             	movzbl (%eax),%eax
80103f23:	0f b6 c0             	movzbl %al,%eax
80103f26:	83 ec 08             	sub    $0x8,%esp
80103f29:	50                   	push   %eax
80103f2a:	68 0c 94 10 80       	push   $0x8010940c
80103f2f:	e8 92 c4 ff ff       	call   801003c6 <cprintf>
80103f34:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103f37:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103f3e:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f44:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f47:	0f 82 02 ff ff ff    	jb     80103e4f <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103f4d:	a1 64 33 11 80       	mov    0x80113364,%eax
80103f52:	85 c0                	test   %eax,%eax
80103f54:	75 1d                	jne    80103f73 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f56:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f5d:	00 00 00 
    lapic = 0;
80103f60:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f67:	00 00 00 
    ioapicid = 0;
80103f6a:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f71:	eb 3e                	jmp    80103fb1 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f76:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f7a:	84 c0                	test   %al,%al
80103f7c:	74 33                	je     80103fb1 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f7e:	83 ec 08             	sub    $0x8,%esp
80103f81:	6a 70                	push   $0x70
80103f83:	6a 22                	push   $0x22
80103f85:	e8 1c fc ff ff       	call   80103ba6 <outb>
80103f8a:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f8d:	83 ec 0c             	sub    $0xc,%esp
80103f90:	6a 23                	push   $0x23
80103f92:	e8 f2 fb ff ff       	call   80103b89 <inb>
80103f97:	83 c4 10             	add    $0x10,%esp
80103f9a:	83 c8 01             	or     $0x1,%eax
80103f9d:	0f b6 c0             	movzbl %al,%eax
80103fa0:	83 ec 08             	sub    $0x8,%esp
80103fa3:	50                   	push   %eax
80103fa4:	6a 23                	push   $0x23
80103fa6:	e8 fb fb ff ff       	call   80103ba6 <outb>
80103fab:	83 c4 10             	add    $0x10,%esp
80103fae:	eb 01                	jmp    80103fb1 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103fb0:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103fb1:	c9                   	leave  
80103fb2:	c3                   	ret    

80103fb3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103fb3:	55                   	push   %ebp
80103fb4:	89 e5                	mov    %esp,%ebp
80103fb6:	83 ec 08             	sub    $0x8,%esp
80103fb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fbf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103fc3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103fc6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103fce:	ee                   	out    %al,(%dx)
}
80103fcf:	90                   	nop
80103fd0:	c9                   	leave  
80103fd1:	c3                   	ret    

80103fd2 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103fd2:	55                   	push   %ebp
80103fd3:	89 e5                	mov    %esp,%ebp
80103fd5:	83 ec 04             	sub    $0x4,%esp
80103fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103fdf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fe3:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103fe9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fed:	0f b6 c0             	movzbl %al,%eax
80103ff0:	50                   	push   %eax
80103ff1:	6a 21                	push   $0x21
80103ff3:	e8 bb ff ff ff       	call   80103fb3 <outb>
80103ff8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103ffb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fff:	66 c1 e8 08          	shr    $0x8,%ax
80104003:	0f b6 c0             	movzbl %al,%eax
80104006:	50                   	push   %eax
80104007:	68 a1 00 00 00       	push   $0xa1
8010400c:	e8 a2 ff ff ff       	call   80103fb3 <outb>
80104011:	83 c4 08             	add    $0x8,%esp
}
80104014:	90                   	nop
80104015:	c9                   	leave  
80104016:	c3                   	ret    

80104017 <picenable>:

void
picenable(int irq)
{
80104017:	55                   	push   %ebp
80104018:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
8010401a:	8b 45 08             	mov    0x8(%ebp),%eax
8010401d:	ba 01 00 00 00       	mov    $0x1,%edx
80104022:	89 c1                	mov    %eax,%ecx
80104024:	d3 e2                	shl    %cl,%edx
80104026:	89 d0                	mov    %edx,%eax
80104028:	f7 d0                	not    %eax
8010402a:	89 c2                	mov    %eax,%edx
8010402c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104033:	21 d0                	and    %edx,%eax
80104035:	0f b7 c0             	movzwl %ax,%eax
80104038:	50                   	push   %eax
80104039:	e8 94 ff ff ff       	call   80103fd2 <picsetmask>
8010403e:	83 c4 04             	add    $0x4,%esp
}
80104041:	90                   	nop
80104042:	c9                   	leave  
80104043:	c3                   	ret    

80104044 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104044:	55                   	push   %ebp
80104045:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104047:	68 ff 00 00 00       	push   $0xff
8010404c:	6a 21                	push   $0x21
8010404e:	e8 60 ff ff ff       	call   80103fb3 <outb>
80104053:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104056:	68 ff 00 00 00       	push   $0xff
8010405b:	68 a1 00 00 00       	push   $0xa1
80104060:	e8 4e ff ff ff       	call   80103fb3 <outb>
80104065:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104068:	6a 11                	push   $0x11
8010406a:	6a 20                	push   $0x20
8010406c:	e8 42 ff ff ff       	call   80103fb3 <outb>
80104071:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104074:	6a 20                	push   $0x20
80104076:	6a 21                	push   $0x21
80104078:	e8 36 ff ff ff       	call   80103fb3 <outb>
8010407d:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104080:	6a 04                	push   $0x4
80104082:	6a 21                	push   $0x21
80104084:	e8 2a ff ff ff       	call   80103fb3 <outb>
80104089:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010408c:	6a 03                	push   $0x3
8010408e:	6a 21                	push   $0x21
80104090:	e8 1e ff ff ff       	call   80103fb3 <outb>
80104095:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104098:	6a 11                	push   $0x11
8010409a:	68 a0 00 00 00       	push   $0xa0
8010409f:	e8 0f ff ff ff       	call   80103fb3 <outb>
801040a4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801040a7:	6a 28                	push   $0x28
801040a9:	68 a1 00 00 00       	push   $0xa1
801040ae:	e8 00 ff ff ff       	call   80103fb3 <outb>
801040b3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801040b6:	6a 02                	push   $0x2
801040b8:	68 a1 00 00 00       	push   $0xa1
801040bd:	e8 f1 fe ff ff       	call   80103fb3 <outb>
801040c2:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801040c5:	6a 03                	push   $0x3
801040c7:	68 a1 00 00 00       	push   $0xa1
801040cc:	e8 e2 fe ff ff       	call   80103fb3 <outb>
801040d1:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801040d4:	6a 68                	push   $0x68
801040d6:	6a 20                	push   $0x20
801040d8:	e8 d6 fe ff ff       	call   80103fb3 <outb>
801040dd:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801040e0:	6a 0a                	push   $0xa
801040e2:	6a 20                	push   $0x20
801040e4:	e8 ca fe ff ff       	call   80103fb3 <outb>
801040e9:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801040ec:	6a 68                	push   $0x68
801040ee:	68 a0 00 00 00       	push   $0xa0
801040f3:	e8 bb fe ff ff       	call   80103fb3 <outb>
801040f8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801040fb:	6a 0a                	push   $0xa
801040fd:	68 a0 00 00 00       	push   $0xa0
80104102:	e8 ac fe ff ff       	call   80103fb3 <outb>
80104107:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010410a:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104111:	66 83 f8 ff          	cmp    $0xffff,%ax
80104115:	74 13                	je     8010412a <picinit+0xe6>
    picsetmask(irqmask);
80104117:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010411e:	0f b7 c0             	movzwl %ax,%eax
80104121:	50                   	push   %eax
80104122:	e8 ab fe ff ff       	call   80103fd2 <picsetmask>
80104127:	83 c4 04             	add    $0x4,%esp
}
8010412a:	90                   	nop
8010412b:	c9                   	leave  
8010412c:	c3                   	ret    

8010412d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010412d:	55                   	push   %ebp
8010412e:	89 e5                	mov    %esp,%ebp
80104130:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104133:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010413a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010413d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104143:	8b 45 0c             	mov    0xc(%ebp),%eax
80104146:	8b 10                	mov    (%eax),%edx
80104148:	8b 45 08             	mov    0x8(%ebp),%eax
8010414b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010414d:	e8 2e ce ff ff       	call   80100f80 <filealloc>
80104152:	89 c2                	mov    %eax,%edx
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	89 10                	mov    %edx,(%eax)
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	8b 00                	mov    (%eax),%eax
8010415e:	85 c0                	test   %eax,%eax
80104160:	0f 84 cb 00 00 00    	je     80104231 <pipealloc+0x104>
80104166:	e8 15 ce ff ff       	call   80100f80 <filealloc>
8010416b:	89 c2                	mov    %eax,%edx
8010416d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104170:	89 10                	mov    %edx,(%eax)
80104172:	8b 45 0c             	mov    0xc(%ebp),%eax
80104175:	8b 00                	mov    (%eax),%eax
80104177:	85 c0                	test   %eax,%eax
80104179:	0f 84 b2 00 00 00    	je     80104231 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010417f:	e8 80 ea ff ff       	call   80102c04 <kalloc>
80104184:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010418b:	0f 84 9f 00 00 00    	je     80104230 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104194:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010419b:	00 00 00 
  p->writeopen = 1;
8010419e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801041a8:	00 00 00 
  p->nwrite = 0;
801041ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ae:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801041b5:	00 00 00 
  p->nread = 0;
801041b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801041c2:	00 00 00 
  initlock(&p->lock, "pipe");
801041c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c8:	83 ec 08             	sub    $0x8,%esp
801041cb:	68 40 94 10 80       	push   $0x80109440
801041d0:	50                   	push   %eax
801041d1:	e8 52 17 00 00       	call   80105928 <initlock>
801041d6:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801041d9:	8b 45 08             	mov    0x8(%ebp),%eax
801041dc:	8b 00                	mov    (%eax),%eax
801041de:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041e4:	8b 45 08             	mov    0x8(%ebp),%eax
801041e7:	8b 00                	mov    (%eax),%eax
801041e9:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041ed:	8b 45 08             	mov    0x8(%ebp),%eax
801041f0:	8b 00                	mov    (%eax),%eax
801041f2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 00                	mov    (%eax),%eax
801041fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fe:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104201:	8b 45 0c             	mov    0xc(%ebp),%eax
80104204:	8b 00                	mov    (%eax),%eax
80104206:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010420c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010420f:	8b 00                	mov    (%eax),%eax
80104211:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104215:	8b 45 0c             	mov    0xc(%ebp),%eax
80104218:	8b 00                	mov    (%eax),%eax
8010421a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010421e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104221:	8b 00                	mov    (%eax),%eax
80104223:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104226:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104229:	b8 00 00 00 00       	mov    $0x0,%eax
8010422e:	eb 4e                	jmp    8010427e <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104230:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104231:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104235:	74 0e                	je     80104245 <pipealloc+0x118>
    kfree((char*)p);
80104237:	83 ec 0c             	sub    $0xc,%esp
8010423a:	ff 75 f4             	pushl  -0xc(%ebp)
8010423d:	e8 25 e9 ff ff       	call   80102b67 <kfree>
80104242:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104245:	8b 45 08             	mov    0x8(%ebp),%eax
80104248:	8b 00                	mov    (%eax),%eax
8010424a:	85 c0                	test   %eax,%eax
8010424c:	74 11                	je     8010425f <pipealloc+0x132>
    fileclose(*f0);
8010424e:	8b 45 08             	mov    0x8(%ebp),%eax
80104251:	8b 00                	mov    (%eax),%eax
80104253:	83 ec 0c             	sub    $0xc,%esp
80104256:	50                   	push   %eax
80104257:	e8 e2 cd ff ff       	call   8010103e <fileclose>
8010425c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010425f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104262:	8b 00                	mov    (%eax),%eax
80104264:	85 c0                	test   %eax,%eax
80104266:	74 11                	je     80104279 <pipealloc+0x14c>
    fileclose(*f1);
80104268:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426b:	8b 00                	mov    (%eax),%eax
8010426d:	83 ec 0c             	sub    $0xc,%esp
80104270:	50                   	push   %eax
80104271:	e8 c8 cd ff ff       	call   8010103e <fileclose>
80104276:	83 c4 10             	add    $0x10,%esp
  return -1;
80104279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010427e:	c9                   	leave  
8010427f:	c3                   	ret    

80104280 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104280:	55                   	push   %ebp
80104281:	89 e5                	mov    %esp,%ebp
80104283:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104286:	8b 45 08             	mov    0x8(%ebp),%eax
80104289:	83 ec 0c             	sub    $0xc,%esp
8010428c:	50                   	push   %eax
8010428d:	e8 b8 16 00 00       	call   8010594a <acquire>
80104292:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104295:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104299:	74 23                	je     801042be <pipeclose+0x3e>
    p->writeopen = 0;
8010429b:	8b 45 08             	mov    0x8(%ebp),%eax
8010429e:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801042a5:	00 00 00 
    wakeup(&p->nread);
801042a8:	8b 45 08             	mov    0x8(%ebp),%eax
801042ab:	05 34 02 00 00       	add    $0x234,%eax
801042b0:	83 ec 0c             	sub    $0xc,%esp
801042b3:	50                   	push   %eax
801042b4:	e8 e1 0f 00 00       	call   8010529a <wakeup>
801042b9:	83 c4 10             	add    $0x10,%esp
801042bc:	eb 21                	jmp    801042df <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801042be:	8b 45 08             	mov    0x8(%ebp),%eax
801042c1:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801042c8:	00 00 00 
    wakeup(&p->nwrite);
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	05 38 02 00 00       	add    $0x238,%eax
801042d3:	83 ec 0c             	sub    $0xc,%esp
801042d6:	50                   	push   %eax
801042d7:	e8 be 0f 00 00       	call   8010529a <wakeup>
801042dc:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801042df:	8b 45 08             	mov    0x8(%ebp),%eax
801042e2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042e8:	85 c0                	test   %eax,%eax
801042ea:	75 2c                	jne    80104318 <pipeclose+0x98>
801042ec:	8b 45 08             	mov    0x8(%ebp),%eax
801042ef:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042f5:	85 c0                	test   %eax,%eax
801042f7:	75 1f                	jne    80104318 <pipeclose+0x98>
    release(&p->lock);
801042f9:	8b 45 08             	mov    0x8(%ebp),%eax
801042fc:	83 ec 0c             	sub    $0xc,%esp
801042ff:	50                   	push   %eax
80104300:	e8 ac 16 00 00       	call   801059b1 <release>
80104305:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104308:	83 ec 0c             	sub    $0xc,%esp
8010430b:	ff 75 08             	pushl  0x8(%ebp)
8010430e:	e8 54 e8 ff ff       	call   80102b67 <kfree>
80104313:	83 c4 10             	add    $0x10,%esp
80104316:	eb 0f                	jmp    80104327 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104318:	8b 45 08             	mov    0x8(%ebp),%eax
8010431b:	83 ec 0c             	sub    $0xc,%esp
8010431e:	50                   	push   %eax
8010431f:	e8 8d 16 00 00       	call   801059b1 <release>
80104324:	83 c4 10             	add    $0x10,%esp
}
80104327:	90                   	nop
80104328:	c9                   	leave  
80104329:	c3                   	ret    

8010432a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010432a:	55                   	push   %ebp
8010432b:	89 e5                	mov    %esp,%ebp
8010432d:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104330:	8b 45 08             	mov    0x8(%ebp),%eax
80104333:	83 ec 0c             	sub    $0xc,%esp
80104336:	50                   	push   %eax
80104337:	e8 0e 16 00 00       	call   8010594a <acquire>
8010433c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010433f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104346:	e9 ad 00 00 00       	jmp    801043f8 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010434b:	8b 45 08             	mov    0x8(%ebp),%eax
8010434e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104354:	85 c0                	test   %eax,%eax
80104356:	74 0d                	je     80104365 <pipewrite+0x3b>
80104358:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435e:	8b 40 24             	mov    0x24(%eax),%eax
80104361:	85 c0                	test   %eax,%eax
80104363:	74 19                	je     8010437e <pipewrite+0x54>
        release(&p->lock);
80104365:	8b 45 08             	mov    0x8(%ebp),%eax
80104368:	83 ec 0c             	sub    $0xc,%esp
8010436b:	50                   	push   %eax
8010436c:	e8 40 16 00 00       	call   801059b1 <release>
80104371:	83 c4 10             	add    $0x10,%esp
        return -1;
80104374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104379:	e9 a8 00 00 00       	jmp    80104426 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010437e:	8b 45 08             	mov    0x8(%ebp),%eax
80104381:	05 34 02 00 00       	add    $0x234,%eax
80104386:	83 ec 0c             	sub    $0xc,%esp
80104389:	50                   	push   %eax
8010438a:	e8 0b 0f 00 00       	call   8010529a <wakeup>
8010438f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104392:	8b 45 08             	mov    0x8(%ebp),%eax
80104395:	8b 55 08             	mov    0x8(%ebp),%edx
80104398:	81 c2 38 02 00 00    	add    $0x238,%edx
8010439e:	83 ec 08             	sub    $0x8,%esp
801043a1:	50                   	push   %eax
801043a2:	52                   	push   %edx
801043a3:	e8 e6 0d 00 00       	call   8010518e <sleep>
801043a8:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801043b4:	8b 45 08             	mov    0x8(%ebp),%eax
801043b7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043bd:	05 00 02 00 00       	add    $0x200,%eax
801043c2:	39 c2                	cmp    %eax,%edx
801043c4:	74 85                	je     8010434b <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043cf:	8d 48 01             	lea    0x1(%eax),%ecx
801043d2:	8b 55 08             	mov    0x8(%ebp),%edx
801043d5:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801043db:	25 ff 01 00 00       	and    $0x1ff,%eax
801043e0:	89 c1                	mov    %eax,%ecx
801043e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e8:	01 d0                	add    %edx,%eax
801043ea:	0f b6 10             	movzbl (%eax),%edx
801043ed:	8b 45 08             	mov    0x8(%ebp),%eax
801043f0:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fb:	3b 45 10             	cmp    0x10(%ebp),%eax
801043fe:	7c ab                	jl     801043ab <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104400:	8b 45 08             	mov    0x8(%ebp),%eax
80104403:	05 34 02 00 00       	add    $0x234,%eax
80104408:	83 ec 0c             	sub    $0xc,%esp
8010440b:	50                   	push   %eax
8010440c:	e8 89 0e 00 00       	call   8010529a <wakeup>
80104411:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104414:	8b 45 08             	mov    0x8(%ebp),%eax
80104417:	83 ec 0c             	sub    $0xc,%esp
8010441a:	50                   	push   %eax
8010441b:	e8 91 15 00 00       	call   801059b1 <release>
80104420:	83 c4 10             	add    $0x10,%esp
  return n;
80104423:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104426:	c9                   	leave  
80104427:	c3                   	ret    

80104428 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104428:	55                   	push   %ebp
80104429:	89 e5                	mov    %esp,%ebp
8010442b:	53                   	push   %ebx
8010442c:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010442f:	8b 45 08             	mov    0x8(%ebp),%eax
80104432:	83 ec 0c             	sub    $0xc,%esp
80104435:	50                   	push   %eax
80104436:	e8 0f 15 00 00       	call   8010594a <acquire>
8010443b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010443e:	eb 3f                	jmp    8010447f <piperead+0x57>
    if(proc->killed){
80104440:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104446:	8b 40 24             	mov    0x24(%eax),%eax
80104449:	85 c0                	test   %eax,%eax
8010444b:	74 19                	je     80104466 <piperead+0x3e>
      release(&p->lock);
8010444d:	8b 45 08             	mov    0x8(%ebp),%eax
80104450:	83 ec 0c             	sub    $0xc,%esp
80104453:	50                   	push   %eax
80104454:	e8 58 15 00 00       	call   801059b1 <release>
80104459:	83 c4 10             	add    $0x10,%esp
      return -1;
8010445c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104461:	e9 bf 00 00 00       	jmp    80104525 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104466:	8b 45 08             	mov    0x8(%ebp),%eax
80104469:	8b 55 08             	mov    0x8(%ebp),%edx
8010446c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104472:	83 ec 08             	sub    $0x8,%esp
80104475:	50                   	push   %eax
80104476:	52                   	push   %edx
80104477:	e8 12 0d 00 00       	call   8010518e <sleep>
8010447c:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010447f:	8b 45 08             	mov    0x8(%ebp),%eax
80104482:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104488:	8b 45 08             	mov    0x8(%ebp),%eax
8010448b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104491:	39 c2                	cmp    %eax,%edx
80104493:	75 0d                	jne    801044a2 <piperead+0x7a>
80104495:	8b 45 08             	mov    0x8(%ebp),%eax
80104498:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010449e:	85 c0                	test   %eax,%eax
801044a0:	75 9e                	jne    80104440 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044a9:	eb 49                	jmp    801044f4 <piperead+0xcc>
    if(p->nread == p->nwrite)
801044ab:	8b 45 08             	mov    0x8(%ebp),%eax
801044ae:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801044b4:	8b 45 08             	mov    0x8(%ebp),%eax
801044b7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801044bd:	39 c2                	cmp    %eax,%edx
801044bf:	74 3d                	je     801044fe <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801044c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801044c7:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801044ca:	8b 45 08             	mov    0x8(%ebp),%eax
801044cd:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801044d3:	8d 48 01             	lea    0x1(%eax),%ecx
801044d6:	8b 55 08             	mov    0x8(%ebp),%edx
801044d9:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801044df:	25 ff 01 00 00       	and    $0x1ff,%eax
801044e4:	89 c2                	mov    %eax,%edx
801044e6:	8b 45 08             	mov    0x8(%ebp),%eax
801044e9:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801044ee:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	3b 45 10             	cmp    0x10(%ebp),%eax
801044fa:	7c af                	jl     801044ab <piperead+0x83>
801044fc:	eb 01                	jmp    801044ff <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801044fe:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104502:	05 38 02 00 00       	add    $0x238,%eax
80104507:	83 ec 0c             	sub    $0xc,%esp
8010450a:	50                   	push   %eax
8010450b:	e8 8a 0d 00 00       	call   8010529a <wakeup>
80104510:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104513:	8b 45 08             	mov    0x8(%ebp),%eax
80104516:	83 ec 0c             	sub    $0xc,%esp
80104519:	50                   	push   %eax
8010451a:	e8 92 14 00 00       	call   801059b1 <release>
8010451f:	83 c4 10             	add    $0x10,%esp
  return i;
80104522:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104528:	c9                   	leave  
80104529:	c3                   	ret    

8010452a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010452a:	55                   	push   %ebp
8010452b:	89 e5                	mov    %esp,%ebp
8010452d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104530:	9c                   	pushf  
80104531:	58                   	pop    %eax
80104532:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104535:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104538:	c9                   	leave  
80104539:	c3                   	ret    

8010453a <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010453a:	55                   	push   %ebp
8010453b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010453d:	fb                   	sti    
}
8010453e:	90                   	nop
8010453f:	5d                   	pop    %ebp
80104540:	c3                   	ret    

80104541 <make_runnable>:
} ptable;

//enqueue the process in the corresponding priority
static void
make_runnable(struct proc* p)
{
80104541:	55                   	push   %ebp
80104542:	89 e5                	mov    %esp,%ebp
  if(ptable.mlf[p->priority].last==0){
80104544:	8b 45 08             	mov    0x8(%ebp),%eax
80104547:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010454b:	0f b7 c0             	movzwl %ax,%eax
8010454e:	05 86 07 00 00       	add    $0x786,%eax
80104553:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
8010455a:	85 c0                	test   %eax,%eax
8010455c:	75 1c                	jne    8010457a <make_runnable+0x39>
    ptable.mlf[p->priority].first = p;
8010455e:	8b 45 08             	mov    0x8(%ebp),%eax
80104561:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104565:	0f b7 c0             	movzwl %ax,%eax
80104568:	8d 90 86 07 00 00    	lea    0x786(%eax),%edx
8010456e:	8b 45 08             	mov    0x8(%ebp),%eax
80104571:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
80104578:	eb 1f                	jmp    80104599 <make_runnable+0x58>
  } else{
    ptable.mlf[p->priority].last->next = p;
8010457a:	8b 45 08             	mov    0x8(%ebp),%eax
8010457d:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104581:	0f b7 c0             	movzwl %ax,%eax
80104584:	05 86 07 00 00       	add    $0x786,%eax
80104589:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
80104590:	8b 55 08             	mov    0x8(%ebp),%edx
80104593:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
  ptable.mlf[p->priority].last=p;
80104599:	8b 45 08             	mov    0x8(%ebp),%eax
8010459c:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801045a0:	0f b7 c0             	movzwl %ax,%eax
801045a3:	8d 90 86 07 00 00    	lea    0x786(%eax),%edx
801045a9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ac:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
  p->next=0;
801045b3:	8b 45 08             	mov    0x8(%ebp),%eax
801045b6:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801045bd:	00 00 00 
  p->age=0;
801045c0:	8b 45 08             	mov    0x8(%ebp),%eax
801045c3:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
801045ca:	00 00 
  p->state=RUNNABLE;
801045cc:	8b 45 08             	mov    0x8(%ebp),%eax
801045cf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045d6:	90                   	nop
801045d7:	5d                   	pop    %ebp
801045d8:	c3                   	ret    

801045d9 <unqueue>:

//dequeue first element of the level "level"
static struct proc*
unqueue(int level)
{
801045d9:	55                   	push   %ebp
801045da:	89 e5                	mov    %esp,%ebp
801045dc:	83 ec 18             	sub    $0x18,%esp
  struct proc* p=ptable.mlf[level].first;
801045df:	8b 45 08             	mov    0x8(%ebp),%eax
801045e2:	05 86 07 00 00       	add    $0x786,%eax
801045e7:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801045ee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!ptable.mlf[level].first)
801045f1:	8b 45 08             	mov    0x8(%ebp),%eax
801045f4:	05 86 07 00 00       	add    $0x786,%eax
801045f9:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104600:	85 c0                	test   %eax,%eax
80104602:	75 0d                	jne    80104611 <unqueue+0x38>
    panic("empty level");
80104604:	83 ec 0c             	sub    $0xc,%esp
80104607:	68 48 94 10 80       	push   $0x80109448
8010460c:	e8 55 bf ff ff       	call   80100566 <panic>
  if(ptable.mlf[level].first==ptable.mlf[level].last){
80104611:	8b 45 08             	mov    0x8(%ebp),%eax
80104614:	05 86 07 00 00       	add    $0x786,%eax
80104619:	8b 14 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%edx
80104620:	8b 45 08             	mov    0x8(%ebp),%eax
80104623:	05 86 07 00 00       	add    $0x786,%eax
80104628:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
8010462f:	39 c2                	cmp    %eax,%edx
80104631:	75 34                	jne    80104667 <unqueue+0x8e>
    ptable.mlf[level].last = ptable.mlf[level].first = 0;
80104633:	8b 45 08             	mov    0x8(%ebp),%eax
80104636:	05 86 07 00 00       	add    $0x786,%eax
8010463b:	c7 04 c5 84 39 11 80 	movl   $0x0,-0x7feec67c(,%eax,8)
80104642:	00 00 00 00 
80104646:	8b 45 08             	mov    0x8(%ebp),%eax
80104649:	05 86 07 00 00       	add    $0x786,%eax
8010464e:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104655:	8b 55 08             	mov    0x8(%ebp),%edx
80104658:	81 c2 86 07 00 00    	add    $0x786,%edx
8010465e:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
80104665:	eb 19                	jmp    80104680 <unqueue+0xa7>
  }else{
    ptable.mlf[level].first=p->next;
80104667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104670:	8b 55 08             	mov    0x8(%ebp),%edx
80104673:	81 c2 86 07 00 00    	add    $0x786,%edx
80104679:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
  }
  if(p->state!=RUNNABLE)
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 40 0c             	mov    0xc(%eax),%eax
80104686:	83 f8 03             	cmp    $0x3,%eax
80104689:	74 0d                	je     80104698 <unqueue+0xbf>
    panic("unqueue not RUNNABLE process");
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	68 54 94 10 80       	push   $0x80109454
80104693:	e8 ce be ff ff       	call   80100566 <panic>
  return p;
80104698:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010469b:	c9                   	leave  
8010469c:	c3                   	ret    

8010469d <levelupdate>:

//unqueue the process, it increases the priority if it corresponds, and queues it in the new level.
static void
levelupdate(struct proc* p)
{
8010469d:	55                   	push   %ebp
8010469e:	89 e5                	mov    %esp,%ebp
801046a0:	83 ec 08             	sub    $0x8,%esp
  unqueue(p->priority);
801046a3:	8b 45 08             	mov    0x8(%ebp),%eax
801046a6:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046aa:	0f b7 c0             	movzwl %ax,%eax
801046ad:	83 ec 0c             	sub    $0xc,%esp
801046b0:	50                   	push   %eax
801046b1:	e8 23 ff ff ff       	call   801045d9 <unqueue>
801046b6:	83 c4 10             	add    $0x10,%esp
  if(p->priority>MLFMAXPRIORITY)
801046b9:	8b 45 08             	mov    0x8(%ebp),%eax
801046bc:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046c0:	66 85 c0             	test   %ax,%ax
801046c3:	74 11                	je     801046d6 <levelupdate+0x39>
    p->priority--;
801046c5:	8b 45 08             	mov    0x8(%ebp),%eax
801046c8:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801046cf:	8b 45 08             	mov    0x8(%ebp),%eax
801046d2:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(p);
801046d6:	83 ec 0c             	sub    $0xc,%esp
801046d9:	ff 75 08             	pushl  0x8(%ebp)
801046dc:	e8 60 fe ff ff       	call   80104541 <make_runnable>
801046e1:	83 c4 10             	add    $0x10,%esp
}
801046e4:	90                   	nop
801046e5:	c9                   	leave  
801046e6:	c3                   	ret    

801046e7 <calculateaging>:

//go through MLF, looking for processes that reach AGEFORAGINGS and raise the priority.
//call procdump to show them.
void
calculateaging(void)
{
801046e7:	55                   	push   %ebp
801046e8:	89 e5                	mov    %esp,%ebp
801046ea:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  int l;
  acquire(&ptable.lock);
801046ed:	83 ec 0c             	sub    $0xc,%esp
801046f0:	68 80 39 11 80       	push   $0x80113980
801046f5:	e8 50 12 00 00       	call   8010594a <acquire>
801046fa:	83 c4 10             	add    $0x10,%esp
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
801046fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104704:	e9 a7 00 00 00       	jmp    801047b0 <calculateaging+0xc9>
    p=ptable.mlf[l].first;
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	05 86 07 00 00       	add    $0x786,%eax
80104711:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104718:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p){
8010471b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010471f:	0f 84 87 00 00 00    	je     801047ac <calculateaging+0xc5>
      p->age++;  // increase the age to the process
80104725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104728:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
8010472f:	8d 50 01             	lea    0x1(%eax),%edx
80104732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104735:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      //procdump();
      if(p->age == AGEFORAGINGS){
8010473c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010473f:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104746:	66 83 f8 05          	cmp    $0x5,%ax
8010474a:	75 60                	jne    801047ac <calculateaging+0xc5>
        if(ptable.mlf[p->priority].first!=p)
8010474c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010474f:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104753:	0f b7 c0             	movzwl %ax,%eax
80104756:	05 86 07 00 00       	add    $0x786,%eax
8010475b:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104762:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104765:	74 0d                	je     80104774 <calculateaging+0x8d>
          panic("it does not eliminate the first element of the level.");
80104767:	83 ec 0c             	sub    $0xc,%esp
8010476a:	68 74 94 10 80       	push   $0x80109474
8010476f:	e8 f2 bd ff ff       	call   80100566 <panic>
        procdump();
80104774:	e8 e3 0b 00 00       	call   8010535c <procdump>
        cprintf("/**************************************************************/\n");
80104779:	83 ec 0c             	sub    $0xc,%esp
8010477c:	68 ac 94 10 80       	push   $0x801094ac
80104781:	e8 40 bc ff ff       	call   801003c6 <cprintf>
80104786:	83 c4 10             	add    $0x10,%esp
        levelupdate(p);  // call to levelupdate
80104789:	83 ec 0c             	sub    $0xc,%esp
8010478c:	ff 75 f0             	pushl  -0x10(%ebp)
8010478f:	e8 09 ff ff ff       	call   8010469d <levelupdate>
80104794:	83 c4 10             	add    $0x10,%esp
        procdump();
80104797:	e8 c0 0b 00 00       	call   8010535c <procdump>
        cprintf("/--------------------------------------------------------------/\n");
8010479c:	83 ec 0c             	sub    $0xc,%esp
8010479f:	68 f0 94 10 80       	push   $0x801094f0
801047a4:	e8 1d bc ff ff       	call   801003c6 <cprintf>
801047a9:	83 c4 10             	add    $0x10,%esp
calculateaging(void)
{
  struct proc* p;
  int l;
  acquire(&ptable.lock);
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
801047ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047b0:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801047b4:	0f 8e 4f ff ff ff    	jle    80104709 <calculateaging+0x22>
        procdump();
        cprintf("/--------------------------------------------------------------/\n");
      }
    }
  }
  release(&ptable.lock);
801047ba:	83 ec 0c             	sub    $0xc,%esp
801047bd:	68 80 39 11 80       	push   $0x80113980
801047c2:	e8 ea 11 00 00       	call   801059b1 <release>
801047c7:	83 c4 10             	add    $0x10,%esp
}
801047ca:	90                   	nop
801047cb:	c9                   	leave  
801047cc:	c3                   	ret    

801047cd <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801047cd:	55                   	push   %ebp
801047ce:	89 e5                	mov    %esp,%ebp
801047d0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801047d3:	83 ec 08             	sub    $0x8,%esp
801047d6:	68 32 95 10 80       	push   $0x80109532
801047db:	68 80 39 11 80       	push   $0x80113980
801047e0:	e8 43 11 00 00       	call   80105928 <initlock>
801047e5:	83 c4 10             	add    $0x10,%esp
}
801047e8:	90                   	nop
801047e9:	c9                   	leave  
801047ea:	c3                   	ret    

801047eb <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801047eb:	55                   	push   %ebp
801047ec:	89 e5                	mov    %esp,%ebp
801047ee:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	68 80 39 11 80       	push   $0x80113980
801047f9:	e8 4c 11 00 00       	call   8010594a <acquire>
801047fe:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104801:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104808:	eb 11                	jmp    8010481b <allocproc+0x30>
    if(p->state == UNUSED)
8010480a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480d:	8b 40 0c             	mov    0xc(%eax),%eax
80104810:	85 c0                	test   %eax,%eax
80104812:	74 2a                	je     8010483e <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104814:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
8010481b:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80104822:	72 e6                	jb     8010480a <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104824:	83 ec 0c             	sub    $0xc,%esp
80104827:	68 80 39 11 80       	push   $0x80113980
8010482c:	e8 80 11 00 00       	call   801059b1 <release>
80104831:	83 c4 10             	add    $0x10,%esp
  return 0;
80104834:	b8 00 00 00 00       	mov    $0x0,%eax
80104839:	e9 c9 00 00 00       	jmp    80104907 <allocproc+0x11c>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010483e:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010483f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104842:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104849:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010484e:	8d 50 01             	lea    0x1(%eax),%edx
80104851:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104857:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010485a:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010485d:	83 ec 0c             	sub    $0xc,%esp
80104860:	68 80 39 11 80       	push   $0x80113980
80104865:	e8 47 11 00 00       	call   801059b1 <release>
8010486a:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010486d:	e8 92 e3 ff ff       	call   80102c04 <kalloc>
80104872:	89 c2                	mov    %eax,%edx
80104874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104877:	89 50 08             	mov    %edx,0x8(%eax)
8010487a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487d:	8b 40 08             	mov    0x8(%eax),%eax
80104880:	85 c0                	test   %eax,%eax
80104882:	75 11                	jne    80104895 <allocproc+0xaa>
    p->state = UNUSED;
80104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104887:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010488e:	b8 00 00 00 00       	mov    $0x0,%eax
80104893:	eb 72                	jmp    80104907 <allocproc+0x11c>
  }
  sp = p->kstack + KSTACKSIZE;
80104895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104898:	8b 40 08             	mov    0x8(%eax),%eax
8010489b:	05 00 10 00 00       	add    $0x1000,%eax
801048a0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801048a3:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801048a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048ad:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801048b0:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801048b4:	ba 96 71 10 80       	mov    $0x80107196,%edx
801048b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048bc:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801048be:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801048c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048c8:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801048cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ce:	8b 40 1c             	mov    0x1c(%eax),%eax
801048d1:	83 ec 04             	sub    $0x4,%esp
801048d4:	6a 14                	push   $0x14
801048d6:	6a 00                	push   $0x0
801048d8:	50                   	push   %eax
801048d9:	e8 cf 12 00 00       	call   80105bad <memset>
801048de:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801048e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e4:	8b 40 1c             	mov    0x1c(%eax),%eax
801048e7:	ba 5d 51 10 80       	mov    $0x8010515d,%edx
801048ec:	89 50 10             	mov    %edx,0x10(%eax)

  p->priority=0;  // initializes the priority.
801048ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f2:	66 c7 40 7e 00 00    	movw   $0x0,0x7e(%eax)
  p->age=0;  // initialize age.
801048f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fb:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
80104902:	00 00 
  return p;
80104904:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104907:	c9                   	leave  
80104908:	c3                   	ret    

80104909 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104909:	55                   	push   %ebp
8010490a:	89 e5                	mov    %esp,%ebp
8010490c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010490f:	e8 d7 fe ff ff       	call   801047eb <allocproc>
80104914:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491a:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
8010491f:	e8 31 40 00 00       	call   80108955 <setupkvm>
80104924:	89 c2                	mov    %eax,%edx
80104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104929:	89 50 04             	mov    %edx,0x4(%eax)
8010492c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492f:	8b 40 04             	mov    0x4(%eax),%eax
80104932:	85 c0                	test   %eax,%eax
80104934:	75 0d                	jne    80104943 <userinit+0x3a>
    panic("userinit: out of memory?");
80104936:	83 ec 0c             	sub    $0xc,%esp
80104939:	68 39 95 10 80       	push   $0x80109539
8010493e:	e8 23 bc ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104943:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494b:	8b 40 04             	mov    0x4(%eax),%eax
8010494e:	83 ec 04             	sub    $0x4,%esp
80104951:	52                   	push   %edx
80104952:	68 00 c5 10 80       	push   $0x8010c500
80104957:	50                   	push   %eax
80104958:	e8 52 42 00 00       	call   80108baf <inituvm>
8010495d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104963:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	8b 40 18             	mov    0x18(%eax),%eax
8010496f:	83 ec 04             	sub    $0x4,%esp
80104972:	6a 4c                	push   $0x4c
80104974:	6a 00                	push   $0x0
80104976:	50                   	push   %eax
80104977:	e8 31 12 00 00       	call   80105bad <memset>
8010497c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104982:	8b 40 18             	mov    0x18(%eax),%eax
80104985:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010498b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498e:	8b 40 18             	mov    0x18(%eax),%eax
80104991:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499a:	8b 40 18             	mov    0x18(%eax),%eax
8010499d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049a0:	8b 52 18             	mov    0x18(%edx),%edx
801049a3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801049a7:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801049ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ae:	8b 40 18             	mov    0x18(%eax),%eax
801049b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049b4:	8b 52 18             	mov    0x18(%edx),%edx
801049b7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801049bb:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801049bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c2:	8b 40 18             	mov    0x18(%eax),%eax
801049c5:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801049cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cf:	8b 40 18             	mov    0x18(%eax),%eax
801049d2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	8b 40 18             	mov    0x18(%eax),%eax
801049df:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801049e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e9:	83 c0 6c             	add    $0x6c,%eax
801049ec:	83 ec 04             	sub    $0x4,%esp
801049ef:	6a 10                	push   $0x10
801049f1:	68 52 95 10 80       	push   $0x80109552
801049f6:	50                   	push   %eax
801049f7:	e8 b4 13 00 00       	call   80105db0 <safestrcpy>
801049fc:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801049ff:	83 ec 0c             	sub    $0xc,%esp
80104a02:	68 5b 95 10 80       	push   $0x8010955b
80104a07:	e8 f6 da ff ff       	call   80102502 <namei>
80104a0c:	83 c4 10             	add    $0x10,%esp
80104a0f:	89 c2                	mov    %eax,%edx
80104a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a14:	89 50 68             	mov    %edx,0x68(%eax)


  make_runnable(p);
80104a17:	83 ec 0c             	sub    $0xc,%esp
80104a1a:	ff 75 f4             	pushl  -0xc(%ebp)
80104a1d:	e8 1f fb ff ff       	call   80104541 <make_runnable>
80104a22:	83 c4 10             	add    $0x10,%esp
}
80104a25:	90                   	nop
80104a26:	c9                   	leave  
80104a27:	c3                   	ret    

80104a28 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104a28:	55                   	push   %ebp
80104a29:	89 e5                	mov    %esp,%ebp
80104a2b:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104a2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a34:	8b 00                	mov    (%eax),%eax
80104a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104a39:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a3d:	7e 31                	jle    80104a70 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a3f:	8b 55 08             	mov    0x8(%ebp),%edx
80104a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a45:	01 c2                	add    %eax,%edx
80104a47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4d:	8b 40 04             	mov    0x4(%eax),%eax
80104a50:	83 ec 04             	sub    $0x4,%esp
80104a53:	52                   	push   %edx
80104a54:	ff 75 f4             	pushl  -0xc(%ebp)
80104a57:	50                   	push   %eax
80104a58:	e8 9f 42 00 00       	call   80108cfc <allocuvm>
80104a5d:	83 c4 10             	add    $0x10,%esp
80104a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a67:	75 3e                	jne    80104aa7 <growproc+0x7f>
      return -1;
80104a69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a6e:	eb 59                	jmp    80104ac9 <growproc+0xa1>
  } else if(n < 0){
80104a70:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a74:	79 31                	jns    80104aa7 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a76:	8b 55 08             	mov    0x8(%ebp),%edx
80104a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7c:	01 c2                	add    %eax,%edx
80104a7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a84:	8b 40 04             	mov    0x4(%eax),%eax
80104a87:	83 ec 04             	sub    $0x4,%esp
80104a8a:	52                   	push   %edx
80104a8b:	ff 75 f4             	pushl  -0xc(%ebp)
80104a8e:	50                   	push   %eax
80104a8f:	e8 31 43 00 00       	call   80108dc5 <deallocuvm>
80104a94:	83 c4 10             	add    $0x10,%esp
80104a97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a9e:	75 07                	jne    80104aa7 <growproc+0x7f>
      return -1;
80104aa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa5:	eb 22                	jmp    80104ac9 <growproc+0xa1>
  }
  proc->sz = sz;
80104aa7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ab0:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104ab2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab8:	83 ec 0c             	sub    $0xc,%esp
80104abb:	50                   	push   %eax
80104abc:	e8 7b 3f 00 00       	call   80108a3c <switchuvm>
80104ac1:	83 c4 10             	add    $0x10,%esp
  return 0;
80104ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ac9:	c9                   	leave  
80104aca:	c3                   	ret    

80104acb <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104acb:	55                   	push   %ebp
80104acc:	89 e5                	mov    %esp,%ebp
80104ace:	57                   	push   %edi
80104acf:	56                   	push   %esi
80104ad0:	53                   	push   %ebx
80104ad1:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104ad4:	e8 12 fd ff ff       	call   801047eb <allocproc>
80104ad9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104adc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104ae0:	75 0a                	jne    80104aec <fork+0x21>
    return -1;
80104ae2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae7:	e9 d3 01 00 00       	jmp    80104cbf <fork+0x1f4>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104aec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af2:	8b 10                	mov    (%eax),%edx
80104af4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afa:	8b 40 04             	mov    0x4(%eax),%eax
80104afd:	83 ec 08             	sub    $0x8,%esp
80104b00:	52                   	push   %edx
80104b01:	50                   	push   %eax
80104b02:	e8 5c 44 00 00       	call   80108f63 <copyuvm>
80104b07:	83 c4 10             	add    $0x10,%esp
80104b0a:	89 c2                	mov    %eax,%edx
80104b0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b0f:	89 50 04             	mov    %edx,0x4(%eax)
80104b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b15:	8b 40 04             	mov    0x4(%eax),%eax
80104b18:	85 c0                	test   %eax,%eax
80104b1a:	75 30                	jne    80104b4c <fork+0x81>
    kfree(np->kstack);
80104b1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b1f:	8b 40 08             	mov    0x8(%eax),%eax
80104b22:	83 ec 0c             	sub    $0xc,%esp
80104b25:	50                   	push   %eax
80104b26:	e8 3c e0 ff ff       	call   80102b67 <kfree>
80104b2b:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104b2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104b38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b3b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104b42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b47:	e9 73 01 00 00       	jmp    80104cbf <fork+0x1f4>
  }
  np->sz = proc->sz;
80104b4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b52:	8b 10                	mov    (%eax),%edx
80104b54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b57:	89 10                	mov    %edx,(%eax)
  np->sstack = proc->sstack;
80104b59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5f:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80104b65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b68:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)

  np->parent = proc;
80104b6e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b78:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104b7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b7e:	8b 50 18             	mov    0x18(%eax),%edx
80104b81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b87:	8b 40 18             	mov    0x18(%eax),%eax
80104b8a:	89 c3                	mov    %eax,%ebx
80104b8c:	b8 13 00 00 00       	mov    $0x13,%eax
80104b91:	89 d7                	mov    %edx,%edi
80104b93:	89 de                	mov    %ebx,%esi
80104b95:	89 c1                	mov    %eax,%ecx
80104b97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104b99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b9c:	8b 40 18             	mov    0x18(%eax),%eax
80104b9f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104ba6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104bad:	eb 43                	jmp    80104bf2 <fork+0x127>
    if(proc->ofile[i])
80104baf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bb8:	83 c2 08             	add    $0x8,%edx
80104bbb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bbf:	85 c0                	test   %eax,%eax
80104bc1:	74 2b                	je     80104bee <fork+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
80104bc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bcc:	83 c2 08             	add    $0x8,%edx
80104bcf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bd3:	83 ec 0c             	sub    $0xc,%esp
80104bd6:	50                   	push   %eax
80104bd7:	e8 11 c4 ff ff       	call   80100fed <filedup>
80104bdc:	83 c4 10             	add    $0x10,%esp
80104bdf:	89 c1                	mov    %eax,%ecx
80104be1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104be4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104be7:	83 c2 08             	add    $0x8,%edx
80104bea:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104bee:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104bf2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104bf6:	7e b7                	jle    80104baf <fork+0xe4>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++)
80104bf8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104bff:	eb 43                	jmp    80104c44 <fork+0x179>
    if(proc->osemaphore[i])
80104c01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c0a:	83 c2 20             	add    $0x20,%edx
80104c0d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c11:	85 c0                	test   %eax,%eax
80104c13:	74 2b                	je     80104c40 <fork+0x175>
      np->osemaphore[i] = semdup(proc->osemaphore[i]);
80104c15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c1e:	83 c2 20             	add    $0x20,%edx
80104c21:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c25:	83 ec 0c             	sub    $0xc,%esp
80104c28:	50                   	push   %eax
80104c29:	e8 71 0c 00 00       	call   8010589f <semdup>
80104c2e:	83 c4 10             	add    $0x10,%esp
80104c31:	89 c1                	mov    %eax,%ecx
80104c33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c39:	83 c2 20             	add    $0x20,%edx
80104c3c:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++)
80104c40:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104c44:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
80104c48:	7e b7                	jle    80104c01 <fork+0x136>
    if(proc->osemaphore[i])
      np->osemaphore[i] = semdup(proc->osemaphore[i]);

  np->cwd = idup(proc->cwd);
80104c4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c50:	8b 40 68             	mov    0x68(%eax),%eax
80104c53:	83 ec 0c             	sub    $0xc,%esp
80104c56:	50                   	push   %eax
80104c57:	e8 b4 cc ff ff       	call   80101910 <idup>
80104c5c:	83 c4 10             	add    $0x10,%esp
80104c5f:	89 c2                	mov    %eax,%edx
80104c61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c64:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104c67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c6d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c73:	83 c0 6c             	add    $0x6c,%eax
80104c76:	83 ec 04             	sub    $0x4,%esp
80104c79:	6a 10                	push   $0x10
80104c7b:	52                   	push   %edx
80104c7c:	50                   	push   %eax
80104c7d:	e8 2e 11 00 00       	call   80105db0 <safestrcpy>
80104c82:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c88:	8b 40 10             	mov    0x10(%eax),%eax
80104c8b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104c8e:	83 ec 0c             	sub    $0xc,%esp
80104c91:	68 80 39 11 80       	push   $0x80113980
80104c96:	e8 af 0c 00 00       	call   8010594a <acquire>
80104c9b:	83 c4 10             	add    $0x10,%esp
  make_runnable(np);
80104c9e:	83 ec 0c             	sub    $0xc,%esp
80104ca1:	ff 75 e0             	pushl  -0x20(%ebp)
80104ca4:	e8 98 f8 ff ff       	call   80104541 <make_runnable>
80104ca9:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104cac:	83 ec 0c             	sub    $0xc,%esp
80104caf:	68 80 39 11 80       	push   $0x80113980
80104cb4:	e8 f8 0c 00 00       	call   801059b1 <release>
80104cb9:	83 c4 10             	add    $0x10,%esp

  return pid;
80104cbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cc2:	5b                   	pop    %ebx
80104cc3:	5e                   	pop    %esi
80104cc4:	5f                   	pop    %edi
80104cc5:	5d                   	pop    %ebp
80104cc6:	c3                   	ret    

80104cc7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104cc7:	55                   	push   %ebp
80104cc8:	89 e5                	mov    %esp,%ebp
80104cca:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd,idsem;

  if(proc == initproc)
80104ccd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cd4:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104cd9:	39 c2                	cmp    %eax,%edx
80104cdb:	75 0d                	jne    80104cea <exit+0x23>
    panic("init exiting");
80104cdd:	83 ec 0c             	sub    $0xc,%esp
80104ce0:	68 5d 95 10 80       	push   $0x8010955d
80104ce5:	e8 7c b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104cea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cf1:	eb 48                	jmp    80104d3b <exit+0x74>
    if(proc->ofile[fd]){
80104cf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cfc:	83 c2 08             	add    $0x8,%edx
80104cff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d03:	85 c0                	test   %eax,%eax
80104d05:	74 30                	je     80104d37 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d10:	83 c2 08             	add    $0x8,%edx
80104d13:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d17:	83 ec 0c             	sub    $0xc,%esp
80104d1a:	50                   	push   %eax
80104d1b:	e8 1e c3 ff ff       	call   8010103e <fileclose>
80104d20:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104d23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d2c:	83 c2 08             	add    $0x8,%edx
80104d2f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104d36:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d37:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d3b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104d3f:	7e b2                	jle    80104cf3 <exit+0x2c>
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104d41:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104d48:	eb 48                	jmp    80104d92 <exit+0xcb>
    if(proc->osemaphore[idsem]){
80104d4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d50:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d53:	83 c2 20             	add    $0x20,%edx
80104d56:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d5a:	85 c0                	test   %eax,%eax
80104d5c:	74 30                	je     80104d8e <exit+0xc7>
      semclose(proc->osemaphore[idsem]);
80104d5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d64:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d67:	83 c2 20             	add    $0x20,%edx
80104d6a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d6e:	83 ec 0c             	sub    $0xc,%esp
80104d71:	50                   	push   %eax
80104d72:	e8 d9 0a 00 00       	call   80105850 <semclose>
80104d77:	83 c4 10             	add    $0x10,%esp
      proc->osemaphore[idsem] = 0;
80104d7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d80:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d83:	83 c2 20             	add    $0x20,%edx
80104d86:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104d8d:	00 
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104d8e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104d92:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80104d96:	7e b2                	jle    80104d4a <exit+0x83>
      semclose(proc->osemaphore[idsem]);
      proc->osemaphore[idsem] = 0;
    }
  }

  begin_op();
80104d98:	e8 56 e7 ff ff       	call   801034f3 <begin_op>
  iput(proc->cwd);
80104d9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da3:	8b 40 68             	mov    0x68(%eax),%eax
80104da6:	83 ec 0c             	sub    $0xc,%esp
80104da9:	50                   	push   %eax
80104daa:	e8 65 cd ff ff       	call   80101b14 <iput>
80104daf:	83 c4 10             	add    $0x10,%esp
  end_op();
80104db2:	e8 c8 e7 ff ff       	call   8010357f <end_op>
  proc->cwd = 0;
80104db7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dbd:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104dc4:	83 ec 0c             	sub    $0xc,%esp
80104dc7:	68 80 39 11 80       	push   $0x80113980
80104dcc:	e8 79 0b 00 00       	call   8010594a <acquire>
80104dd1:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104dd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dda:	8b 40 14             	mov    0x14(%eax),%eax
80104ddd:	83 ec 0c             	sub    $0xc,%esp
80104de0:	50                   	push   %eax
80104de1:	e8 54 04 00 00       	call   8010523a <wakeup1>
80104de6:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104de9:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104df0:	eb 3f                	jmp    80104e31 <exit+0x16a>
    if(p->parent == proc){
80104df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df5:	8b 50 14             	mov    0x14(%eax),%edx
80104df8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dfe:	39 c2                	cmp    %eax,%edx
80104e00:	75 28                	jne    80104e2a <exit+0x163>
      p->parent = initproc;
80104e02:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e11:	8b 40 0c             	mov    0xc(%eax),%eax
80104e14:	83 f8 05             	cmp    $0x5,%eax
80104e17:	75 11                	jne    80104e2a <exit+0x163>
        wakeup1(initproc);
80104e19:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104e1e:	83 ec 0c             	sub    $0xc,%esp
80104e21:	50                   	push   %eax
80104e22:	e8 13 04 00 00       	call   8010523a <wakeup1>
80104e27:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e2a:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
80104e31:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80104e38:	72 b8                	jb     80104df2 <exit+0x12b>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104e3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e40:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104e47:	e8 f4 01 00 00       	call   80105040 <sched>
  panic("zombie exit");
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	68 6a 95 10 80       	push   $0x8010956a
80104e54:	e8 0d b7 ff ff       	call   80100566 <panic>

80104e59 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104e59:	55                   	push   %ebp
80104e5a:	89 e5                	mov    %esp,%ebp
80104e5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104e5f:	83 ec 0c             	sub    $0xc,%esp
80104e62:	68 80 39 11 80       	push   $0x80113980
80104e67:	e8 de 0a 00 00       	call   8010594a <acquire>
80104e6c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104e6f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e76:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104e7d:	e9 a9 00 00 00       	jmp    80104f2b <wait+0xd2>
      if(p->parent != proc)
80104e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e85:	8b 50 14             	mov    0x14(%eax),%edx
80104e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e8e:	39 c2                	cmp    %eax,%edx
80104e90:	0f 85 8d 00 00 00    	jne    80104f23 <wait+0xca>
        continue;
      havekids = 1;
80104e96:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea3:	83 f8 05             	cmp    $0x5,%eax
80104ea6:	75 7c                	jne    80104f24 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eab:	8b 40 10             	mov    0x10(%eax),%eax
80104eae:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb4:	8b 40 08             	mov    0x8(%eax),%eax
80104eb7:	83 ec 0c             	sub    $0xc,%esp
80104eba:	50                   	push   %eax
80104ebb:	e8 a7 dc ff ff       	call   80102b67 <kfree>
80104ec0:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed0:	8b 40 04             	mov    0x4(%eax),%eax
80104ed3:	83 ec 0c             	sub    $0xc,%esp
80104ed6:	50                   	push   %eax
80104ed7:	e8 a6 3f 00 00       	call   80108e82 <freevm>
80104edc:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eec:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f00:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f07:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104f0e:	83 ec 0c             	sub    $0xc,%esp
80104f11:	68 80 39 11 80       	push   $0x80113980
80104f16:	e8 96 0a 00 00       	call   801059b1 <release>
80104f1b:	83 c4 10             	add    $0x10,%esp
        return pid;
80104f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f21:	eb 5b                	jmp    80104f7e <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104f23:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f24:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
80104f2b:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80104f32:	0f 82 4a ff ff ff    	jb     80104e82 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104f38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f3c:	74 0d                	je     80104f4b <wait+0xf2>
80104f3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f44:	8b 40 24             	mov    0x24(%eax),%eax
80104f47:	85 c0                	test   %eax,%eax
80104f49:	74 17                	je     80104f62 <wait+0x109>
      release(&ptable.lock);
80104f4b:	83 ec 0c             	sub    $0xc,%esp
80104f4e:	68 80 39 11 80       	push   $0x80113980
80104f53:	e8 59 0a 00 00       	call   801059b1 <release>
80104f58:	83 c4 10             	add    $0x10,%esp
      return -1;
80104f5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f60:	eb 1c                	jmp    80104f7e <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104f62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f68:	83 ec 08             	sub    $0x8,%esp
80104f6b:	68 80 39 11 80       	push   $0x80113980
80104f70:	50                   	push   %eax
80104f71:	e8 18 02 00 00       	call   8010518e <sleep>
80104f76:	83 c4 10             	add    $0x10,%esp
  }
80104f79:	e9 f1 fe ff ff       	jmp    80104e6f <wait+0x16>
}
80104f7e:	c9                   	leave  
80104f7f:	c3                   	ret    

80104f80 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104f80:	55                   	push   %ebp
80104f81:	89 e5                	mov    %esp,%ebp
80104f83:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int l;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104f86:	e8 af f5 ff ff       	call   8010453a <sti>

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
80104f8b:	83 ec 0c             	sub    $0xc,%esp
80104f8e:	68 80 39 11 80       	push   $0x80113980
80104f93:	e8 b2 09 00 00       	call   8010594a <acquire>
80104f98:	83 c4 10             	add    $0x10,%esp
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104f9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fa2:	eb 7d                	jmp    80105021 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
80104fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa7:	05 86 07 00 00       	add    $0x786,%eax
80104fac:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104fb3:	85 c0                	test   %eax,%eax
80104fb5:	75 06                	jne    80104fbd <scheduler+0x3d>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80104fb7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fbb:	eb 64                	jmp    80105021 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
        continue;
      p=unqueue(l);
80104fbd:	83 ec 0c             	sub    $0xc,%esp
80104fc0:	ff 75 f4             	pushl  -0xc(%ebp)
80104fc3:	e8 11 f6 ff ff       	call   801045d9 <unqueue>
80104fc8:	83 c4 10             	add    $0x10,%esp
80104fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4


      switchuvm(p);
80104fd7:	83 ec 0c             	sub    $0xc,%esp
80104fda:	ff 75 f0             	pushl  -0x10(%ebp)
80104fdd:	e8 5a 3a 00 00       	call   80108a3c <switchuvm>
80104fe2:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe8:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104fef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff5:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ff8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104fff:	83 c2 04             	add    $0x4,%edx
80105002:	83 ec 08             	sub    $0x8,%esp
80105005:	50                   	push   %eax
80105006:	52                   	push   %edx
80105007:	e8 15 0e 00 00       	call   80105e21 <swtch>
8010500c:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010500f:	e8 0b 3a 00 00       	call   80108a1f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105014:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010501b:	00 00 00 00 
      break;
8010501f:	eb 0a                	jmp    8010502b <scheduler+0xab>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80105021:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80105025:	0f 8e 79 ff ff ff    	jle    80104fa4 <scheduler+0x24>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      break;
    }
    release(&ptable.lock);
8010502b:	83 ec 0c             	sub    $0xc,%esp
8010502e:	68 80 39 11 80       	push   $0x80113980
80105033:	e8 79 09 00 00       	call   801059b1 <release>
80105038:	83 c4 10             	add    $0x10,%esp
  }
8010503b:	e9 46 ff ff ff       	jmp    80104f86 <scheduler+0x6>

80105040 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105040:	55                   	push   %ebp
80105041:	89 e5                	mov    %esp,%ebp
80105043:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105046:	83 ec 0c             	sub    $0xc,%esp
80105049:	68 80 39 11 80       	push   $0x80113980
8010504e:	e8 2a 0a 00 00       	call   80105a7d <holding>
80105053:	83 c4 10             	add    $0x10,%esp
80105056:	85 c0                	test   %eax,%eax
80105058:	75 0d                	jne    80105067 <sched+0x27>
    panic("sched ptable.lock");
8010505a:	83 ec 0c             	sub    $0xc,%esp
8010505d:	68 76 95 10 80       	push   $0x80109576
80105062:	e8 ff b4 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105067:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010506d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105073:	83 f8 01             	cmp    $0x1,%eax
80105076:	74 0d                	je     80105085 <sched+0x45>
    panic("sched locks");
80105078:	83 ec 0c             	sub    $0xc,%esp
8010507b:	68 88 95 10 80       	push   $0x80109588
80105080:	e8 e1 b4 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105085:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508b:	8b 40 0c             	mov    0xc(%eax),%eax
8010508e:	83 f8 04             	cmp    $0x4,%eax
80105091:	75 0d                	jne    801050a0 <sched+0x60>
    panic("sched running");
80105093:	83 ec 0c             	sub    $0xc,%esp
80105096:	68 94 95 10 80       	push   $0x80109594
8010509b:	e8 c6 b4 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801050a0:	e8 85 f4 ff ff       	call   8010452a <readeflags>
801050a5:	25 00 02 00 00       	and    $0x200,%eax
801050aa:	85 c0                	test   %eax,%eax
801050ac:	74 0d                	je     801050bb <sched+0x7b>
    panic("sched interruptible");
801050ae:	83 ec 0c             	sub    $0xc,%esp
801050b1:	68 a2 95 10 80       	push   $0x801095a2
801050b6:	e8 ab b4 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801050bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050c1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801050c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801050ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050d0:	8b 40 04             	mov    0x4(%eax),%eax
801050d3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050da:	83 c2 1c             	add    $0x1c,%edx
801050dd:	83 ec 08             	sub    $0x8,%esp
801050e0:	50                   	push   %eax
801050e1:	52                   	push   %edx
801050e2:	e8 3a 0d 00 00       	call   80105e21 <swtch>
801050e7:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801050ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050f3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801050f9:	90                   	nop
801050fa:	c9                   	leave  
801050fb:	c3                   	ret    

801050fc <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105102:	83 ec 0c             	sub    $0xc,%esp
80105105:	68 80 39 11 80       	push   $0x80113980
8010510a:	e8 3b 08 00 00       	call   8010594a <acquire>
8010510f:	83 c4 10             	add    $0x10,%esp
  if(proc->priority<MLFLEVELS-1)
80105112:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105118:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010511c:	66 83 f8 02          	cmp    $0x2,%ax
80105120:	77 11                	ja     80105133 <yield+0x37>
    proc->priority++;
80105122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105128:	0f b7 50 7e          	movzwl 0x7e(%eax),%edx
8010512c:	83 c2 01             	add    $0x1,%edx
8010512f:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(proc);
80105133:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105139:	83 ec 0c             	sub    $0xc,%esp
8010513c:	50                   	push   %eax
8010513d:	e8 ff f3 ff ff       	call   80104541 <make_runnable>
80105142:	83 c4 10             	add    $0x10,%esp
  sched();
80105145:	e8 f6 fe ff ff       	call   80105040 <sched>
  release(&ptable.lock);
8010514a:	83 ec 0c             	sub    $0xc,%esp
8010514d:	68 80 39 11 80       	push   $0x80113980
80105152:	e8 5a 08 00 00       	call   801059b1 <release>
80105157:	83 c4 10             	add    $0x10,%esp
}
8010515a:	90                   	nop
8010515b:	c9                   	leave  
8010515c:	c3                   	ret    

8010515d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010515d:	55                   	push   %ebp
8010515e:	89 e5                	mov    %esp,%ebp
80105160:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105163:	83 ec 0c             	sub    $0xc,%esp
80105166:	68 80 39 11 80       	push   $0x80113980
8010516b:	e8 41 08 00 00       	call   801059b1 <release>
80105170:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105173:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105178:	85 c0                	test   %eax,%eax
8010517a:	74 0f                	je     8010518b <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010517c:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105183:	00 00 00 
    initlog();
80105186:	e8 42 e1 ff ff       	call   801032cd <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010518b:	90                   	nop
8010518c:	c9                   	leave  
8010518d:	c3                   	ret    

8010518e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010518e:	55                   	push   %ebp
8010518f:	89 e5                	mov    %esp,%ebp
80105191:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105194:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010519a:	85 c0                	test   %eax,%eax
8010519c:	75 0d                	jne    801051ab <sleep+0x1d>
    panic("sleep");
8010519e:	83 ec 0c             	sub    $0xc,%esp
801051a1:	68 b6 95 10 80       	push   $0x801095b6
801051a6:	e8 bb b3 ff ff       	call   80100566 <panic>

  if(lk == 0)
801051ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801051af:	75 0d                	jne    801051be <sleep+0x30>
    panic("sleep without lk");
801051b1:	83 ec 0c             	sub    $0xc,%esp
801051b4:	68 bc 95 10 80       	push   $0x801095bc
801051b9:	e8 a8 b3 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801051be:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801051c5:	74 1e                	je     801051e5 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801051c7:	83 ec 0c             	sub    $0xc,%esp
801051ca:	68 80 39 11 80       	push   $0x80113980
801051cf:	e8 76 07 00 00       	call   8010594a <acquire>
801051d4:	83 c4 10             	add    $0x10,%esp
    release(lk);
801051d7:	83 ec 0c             	sub    $0xc,%esp
801051da:	ff 75 0c             	pushl  0xc(%ebp)
801051dd:	e8 cf 07 00 00       	call   801059b1 <release>
801051e2:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801051e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051eb:	8b 55 08             	mov    0x8(%ebp),%edx
801051ee:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801051f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051f7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801051fe:	e8 3d fe ff ff       	call   80105040 <sched>

  // Tidy up.
  proc->chan = 0;
80105203:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105209:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105210:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105217:	74 1e                	je     80105237 <sleep+0xa9>
    release(&ptable.lock);
80105219:	83 ec 0c             	sub    $0xc,%esp
8010521c:	68 80 39 11 80       	push   $0x80113980
80105221:	e8 8b 07 00 00       	call   801059b1 <release>
80105226:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105229:	83 ec 0c             	sub    $0xc,%esp
8010522c:	ff 75 0c             	pushl  0xc(%ebp)
8010522f:	e8 16 07 00 00       	call   8010594a <acquire>
80105234:	83 c4 10             	add    $0x10,%esp
  }
}
80105237:	90                   	nop
80105238:	c9                   	leave  
80105239:	c3                   	ret    

8010523a <wakeup1>:
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
// If applicable, the priority of the process increases.
static void
wakeup1(void *chan)
{
8010523a:	55                   	push   %ebp
8010523b:	89 e5                	mov    %esp,%ebp
8010523d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105240:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80105247:	eb 45                	jmp    8010528e <wakeup1+0x54>
    if(p->state == SLEEPING && p->chan == chan){
80105249:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010524c:	8b 40 0c             	mov    0xc(%eax),%eax
8010524f:	83 f8 02             	cmp    $0x2,%eax
80105252:	75 33                	jne    80105287 <wakeup1+0x4d>
80105254:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105257:	8b 40 20             	mov    0x20(%eax),%eax
8010525a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010525d:	75 28                	jne    80105287 <wakeup1+0x4d>
      if (p->priority>0)
8010525f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105262:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105266:	66 85 c0             	test   %ax,%ax
80105269:	74 11                	je     8010527c <wakeup1+0x42>
        p->priority--;
8010526b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010526e:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105272:	8d 50 ff             	lea    -0x1(%eax),%edx
80105275:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105278:	66 89 50 7e          	mov    %dx,0x7e(%eax)
      make_runnable(p);
8010527c:	ff 75 fc             	pushl  -0x4(%ebp)
8010527f:	e8 bd f2 ff ff       	call   80104541 <make_runnable>
80105284:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105287:	81 45 fc f0 00 00 00 	addl   $0xf0,-0x4(%ebp)
8010528e:	81 7d fc b4 75 11 80 	cmpl   $0x801175b4,-0x4(%ebp)
80105295:	72 b2                	jb     80105249 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan){
      if (p->priority>0)
        p->priority--;
      make_runnable(p);
    }
}
80105297:	90                   	nop
80105298:	c9                   	leave  
80105299:	c3                   	ret    

8010529a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010529a:	55                   	push   %ebp
8010529b:	89 e5                	mov    %esp,%ebp
8010529d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801052a0:	83 ec 0c             	sub    $0xc,%esp
801052a3:	68 80 39 11 80       	push   $0x80113980
801052a8:	e8 9d 06 00 00       	call   8010594a <acquire>
801052ad:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801052b0:	83 ec 0c             	sub    $0xc,%esp
801052b3:	ff 75 08             	pushl  0x8(%ebp)
801052b6:	e8 7f ff ff ff       	call   8010523a <wakeup1>
801052bb:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801052be:	83 ec 0c             	sub    $0xc,%esp
801052c1:	68 80 39 11 80       	push   $0x80113980
801052c6:	e8 e6 06 00 00       	call   801059b1 <release>
801052cb:	83 c4 10             	add    $0x10,%esp
}
801052ce:	90                   	nop
801052cf:	c9                   	leave  
801052d0:	c3                   	ret    

801052d1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801052d1:	55                   	push   %ebp
801052d2:	89 e5                	mov    %esp,%ebp
801052d4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801052d7:	83 ec 0c             	sub    $0xc,%esp
801052da:	68 80 39 11 80       	push   $0x80113980
801052df:	e8 66 06 00 00       	call   8010594a <acquire>
801052e4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052e7:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801052ee:	eb 4c                	jmp    8010533c <kill+0x6b>
    if(p->pid == pid){
801052f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f3:	8b 40 10             	mov    0x10(%eax),%eax
801052f6:	3b 45 08             	cmp    0x8(%ebp),%eax
801052f9:	75 3a                	jne    80105335 <kill+0x64>
      p->killed = 1;
801052fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fe:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105308:	8b 40 0c             	mov    0xc(%eax),%eax
8010530b:	83 f8 02             	cmp    $0x2,%eax
8010530e:	75 0e                	jne    8010531e <kill+0x4d>
        make_runnable(p);
80105310:	83 ec 0c             	sub    $0xc,%esp
80105313:	ff 75 f4             	pushl  -0xc(%ebp)
80105316:	e8 26 f2 ff ff       	call   80104541 <make_runnable>
8010531b:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
8010531e:	83 ec 0c             	sub    $0xc,%esp
80105321:	68 80 39 11 80       	push   $0x80113980
80105326:	e8 86 06 00 00       	call   801059b1 <release>
8010532b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010532e:	b8 00 00 00 00       	mov    $0x0,%eax
80105333:	eb 25                	jmp    8010535a <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105335:	81 45 f4 f0 00 00 00 	addl   $0xf0,-0xc(%ebp)
8010533c:	81 7d f4 b4 75 11 80 	cmpl   $0x801175b4,-0xc(%ebp)
80105343:	72 ab                	jb     801052f0 <kill+0x1f>
        make_runnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105345:	83 ec 0c             	sub    $0xc,%esp
80105348:	68 80 39 11 80       	push   $0x80113980
8010534d:	e8 5f 06 00 00       	call   801059b1 <release>
80105352:	83 c4 10             	add    $0x10,%esp
  return -1;
80105355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010535a:	c9                   	leave  
8010535b:	c3                   	ret    

8010535c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010535c:	55                   	push   %ebp
8010535d:	89 e5                	mov    %esp,%ebp
8010535f:	53                   	push   %ebx
80105360:	83 ec 44             	sub    $0x44,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105363:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
8010536a:	e9 f6 00 00 00       	jmp    80105465 <procdump+0x109>
    if(p->state == UNUSED)
8010536f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105372:	8b 40 0c             	mov    0xc(%eax),%eax
80105375:	85 c0                	test   %eax,%eax
80105377:	0f 84 e0 00 00 00    	je     8010545d <procdump+0x101>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010537d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105380:	8b 40 0c             	mov    0xc(%eax),%eax
80105383:	83 f8 05             	cmp    $0x5,%eax
80105386:	77 23                	ja     801053ab <procdump+0x4f>
80105388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010538b:	8b 40 0c             	mov    0xc(%eax),%eax
8010538e:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105395:	85 c0                	test   %eax,%eax
80105397:	74 12                	je     801053ab <procdump+0x4f>
      state = states[p->state];
80105399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010539c:	8b 40 0c             	mov    0xc(%eax),%eax
8010539f:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801053a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801053a9:	eb 07                	jmp    801053b2 <procdump+0x56>
    else
      state = "???";
801053ab:	c7 45 ec cd 95 10 80 	movl   $0x801095cd,-0x14(%ebp)
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
801053b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b5:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801053bc:	0f b7 c8             	movzwl %ax,%ecx
801053bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c2:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801053c6:	0f b7 d0             	movzwl %ax,%edx
801053c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053cc:	8d 58 6c             	lea    0x6c(%eax),%ebx
801053cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d2:	8b 40 10             	mov    0x10(%eax),%eax
801053d5:	83 ec 08             	sub    $0x8,%esp
801053d8:	51                   	push   %ecx
801053d9:	52                   	push   %edx
801053da:	53                   	push   %ebx
801053db:	ff 75 ec             	pushl  -0x14(%ebp)
801053de:	50                   	push   %eax
801053df:	68 d1 95 10 80       	push   $0x801095d1
801053e4:	e8 dd af ff ff       	call   801003c6 <cprintf>
801053e9:	83 c4 20             	add    $0x20,%esp
    if(p->state == SLEEPING){
801053ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ef:	8b 40 0c             	mov    0xc(%eax),%eax
801053f2:	83 f8 02             	cmp    $0x2,%eax
801053f5:	75 54                	jne    8010544b <procdump+0xef>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801053f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fa:	8b 40 1c             	mov    0x1c(%eax),%eax
801053fd:	8b 40 0c             	mov    0xc(%eax),%eax
80105400:	83 c0 08             	add    $0x8,%eax
80105403:	89 c2                	mov    %eax,%edx
80105405:	83 ec 08             	sub    $0x8,%esp
80105408:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010540b:	50                   	push   %eax
8010540c:	52                   	push   %edx
8010540d:	e8 f1 05 00 00       	call   80105a03 <getcallerpcs>
80105412:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105415:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010541c:	eb 1c                	jmp    8010543a <procdump+0xde>
        cprintf(" %p", pc[i]);
8010541e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105421:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105425:	83 ec 08             	sub    $0x8,%esp
80105428:	50                   	push   %eax
80105429:	68 ed 95 10 80       	push   $0x801095ed
8010542e:	e8 93 af ff ff       	call   801003c6 <cprintf>
80105433:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105436:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010543a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010543e:	7f 0b                	jg     8010544b <procdump+0xef>
80105440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105443:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105447:	85 c0                	test   %eax,%eax
80105449:	75 d3                	jne    8010541e <procdump+0xc2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010544b:	83 ec 0c             	sub    $0xc,%esp
8010544e:	68 f1 95 10 80       	push   $0x801095f1
80105453:	e8 6e af ff ff       	call   801003c6 <cprintf>
80105458:	83 c4 10             	add    $0x10,%esp
8010545b:	eb 01                	jmp    8010545e <procdump+0x102>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010545d:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010545e:	81 45 f0 f0 00 00 00 	addl   $0xf0,-0x10(%ebp)
80105465:	81 7d f0 b4 75 11 80 	cmpl   $0x801175b4,-0x10(%ebp)
8010546c:	0f 82 fd fe ff ff    	jb     8010536f <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105472:	90                   	nop
80105473:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <seminit>:
} stable;

// Initializes the LOCK of the semaphore table.
void
seminit(void)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
8010547b:	83 ec 08             	sub    $0x8,%esp
  initlock(&stable.lock, "stable");
8010547e:	83 ec 08             	sub    $0x8,%esp
80105481:	68 1d 96 10 80       	push   $0x8010961d
80105486:	68 e0 75 11 80       	push   $0x801175e0
8010548b:	e8 98 04 00 00       	call   80105928 <initlock>
80105490:	83 c4 10             	add    $0x10,%esp
}
80105493:	90                   	nop
80105494:	c9                   	leave  
80105495:	c3                   	ret    

80105496 <allocinprocess>:

// Assigns a place in the open semaphore array of the process and returns the position.
static int
allocinprocess()
{
80105496:	55                   	push   %ebp
80105497:	89 e5                	mov    %esp,%ebp
80105499:	83 ec 10             	sub    $0x10,%esp
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
8010549c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054a3:	eb 22                	jmp    801054c7 <allocinprocess+0x31>
    s=proc->osemaphore[i];
801054a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ab:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054ae:	83 c2 20             	add    $0x20,%edx
801054b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(!s)
801054b8:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801054bc:	75 05                	jne    801054c3 <allocinprocess+0x2d>
      return i;
801054be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054c1:	eb 0f                	jmp    801054d2 <allocinprocess+0x3c>
allocinprocess()
{
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
801054c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054c7:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801054cb:	7e d8                	jle    801054a5 <allocinprocess+0xf>
    s=proc->osemaphore[i];
    if(!s)
      return i;
  }
  return -1;
801054cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054d2:	c9                   	leave  
801054d3:	c3                   	ret    

801054d4 <searchinprocess>:

// Find the id passed as an argument between the ids of the open semaphores of the process and return its position.
static int
searchinprocess(int id)
{
801054d4:	55                   	push   %ebp
801054d5:	89 e5                	mov    %esp,%ebp
801054d7:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
801054da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054e1:	eb 2c                	jmp    8010550f <searchinprocess+0x3b>
    s=proc->osemaphore[i];
801054e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054ec:	83 c2 20             	add    $0x20,%edx
801054ef:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054f3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s && s->id==id){
801054f6:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801054fa:	74 0f                	je     8010550b <searchinprocess+0x37>
801054fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054ff:	8b 00                	mov    (%eax),%eax
80105501:	3b 45 08             	cmp    0x8(%ebp),%eax
80105504:	75 05                	jne    8010550b <searchinprocess+0x37>
        return i;
80105506:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105509:	eb 0f                	jmp    8010551a <searchinprocess+0x46>
searchinprocess(int id)
{
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
8010550b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010550f:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80105513:	7e ce                	jle    801054e3 <searchinprocess+0xf>
    s=proc->osemaphore[i];
    if(s && s->id==id){
        return i;
    }
  }
  return -1;
80105515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010551a:	c9                   	leave  
8010551b:	c3                   	ret    

8010551c <allocinsystem>:

// Assign a place in the semaphore table of the system and return a pointer to it.
// if the table is full, return null (0)
static struct semaphore*
allocinsystem()
{
8010551c:	55                   	push   %ebp
8010551d:	89 e5                	mov    %esp,%ebp
8010551f:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
80105522:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105529:	eb 2d                	jmp    80105558 <allocinsystem+0x3c>
    s=&stable.sem[i];
8010552b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010552e:	89 d0                	mov    %edx,%eax
80105530:	01 c0                	add    %eax,%eax
80105532:	01 d0                	add    %edx,%eax
80105534:	c1 e0 02             	shl    $0x2,%eax
80105537:	83 c0 30             	add    $0x30,%eax
8010553a:	05 e0 75 11 80       	add    $0x801175e0,%eax
8010553f:	83 c0 04             	add    $0x4,%eax
80105542:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s->references==0)
80105545:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105548:	8b 40 04             	mov    0x4(%eax),%eax
8010554b:	85 c0                	test   %eax,%eax
8010554d:	75 05                	jne    80105554 <allocinsystem+0x38>
      return s;
8010554f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105552:	eb 0f                	jmp    80105563 <allocinsystem+0x47>
static struct semaphore*
allocinsystem()
{
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
80105554:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105558:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
8010555c:	7e cd                	jle    8010552b <allocinsystem+0xf>
    s=&stable.sem[i];
    if(s->references==0)
      return s;
  }
  return 0;
8010555e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105563:	c9                   	leave  
80105564:	c3                   	ret    

80105565 <semget>:
// if there is no place in the system's semaphore table, return -3.
// if semid> 0 and the semaphore is not in use, return -1.
// if semid <-1 or semid> MAXSEM, return -4.
int
semget(int semid, int initvalue)
{
80105565:	55                   	push   %ebp
80105566:	89 e5                	mov    %esp,%ebp
80105568:	83 ec 18             	sub    $0x18,%esp
  int position=0,retvalue;
8010556b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  struct semaphore* s;

  if(semid<-1 || semid>=MAXSEM)
80105572:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
80105576:	7c 06                	jl     8010557e <semget+0x19>
80105578:	83 7d 08 3f          	cmpl   $0x3f,0x8(%ebp)
8010557c:	7e 0a                	jle    80105588 <semget+0x23>
    return -4;
8010557e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
80105583:	e9 0d 01 00 00       	jmp    80105695 <semget+0x130>
  acquire(&stable.lock);
80105588:	83 ec 0c             	sub    $0xc,%esp
8010558b:	68 e0 75 11 80       	push   $0x801175e0
80105590:	e8 b5 03 00 00       	call   8010594a <acquire>
80105595:	83 c4 10             	add    $0x10,%esp
  position=allocinprocess();
80105598:	e8 f9 fe ff ff       	call   80105496 <allocinprocess>
8010559d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(position==-1){
801055a0:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
801055a4:	75 0c                	jne    801055b2 <semget+0x4d>
    retvalue=-2;
801055a6:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retget;
801055ad:	e9 d0 00 00 00       	jmp    80105682 <semget+0x11d>
  }
  if(semid==-1){
801055b2:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
801055b6:	75 47                	jne    801055ff <semget+0x9a>
    s=allocinsystem();
801055b8:	e8 5f ff ff ff       	call   8010551c <allocinsystem>
801055bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!s){
801055c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055c4:	75 0c                	jne    801055d2 <semget+0x6d>
      retvalue=-3;
801055c6:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
      goto retget;
801055cd:	e9 b0 00 00 00       	jmp    80105682 <semget+0x11d>
    }
    s->id=s-stable.sem;
801055d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d5:	ba 14 76 11 80       	mov    $0x80117614,%edx
801055da:	29 d0                	sub    %edx,%eax
801055dc:	c1 f8 02             	sar    $0x2,%eax
801055df:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
801055e5:	89 c2                	mov    %eax,%edx
801055e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ea:	89 10                	mov    %edx,(%eax)
    s->value=initvalue;
801055ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801055f2:	89 50 08             	mov    %edx,0x8(%eax)
    retvalue=s->id;
801055f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f8:	8b 00                	mov    (%eax),%eax
801055fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    goto found;
801055fd:	eb 61                	jmp    80105660 <semget+0xfb>
  }
  if(semid>=0){
801055ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105603:	78 5b                	js     80105660 <semget+0xfb>
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
80105605:	c7 45 f0 14 76 11 80 	movl   $0x80117614,-0x10(%ebp)
8010560c:	eb 3f                	jmp    8010564d <semget+0xe8>
      if(s->id==semid && ((s->references)>0)){
8010560e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105611:	8b 00                	mov    (%eax),%eax
80105613:	3b 45 08             	cmp    0x8(%ebp),%eax
80105616:	75 14                	jne    8010562c <semget+0xc7>
80105618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561b:	8b 40 04             	mov    0x4(%eax),%eax
8010561e:	85 c0                	test   %eax,%eax
80105620:	7e 0a                	jle    8010562c <semget+0xc7>
        retvalue=s->id;
80105622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105625:	8b 00                	mov    (%eax),%eax
80105627:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto found;
8010562a:	eb 34                	jmp    80105660 <semget+0xfb>
      }
      if(s->id==semid && ((s->references)==0)){
8010562c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562f:	8b 00                	mov    (%eax),%eax
80105631:	3b 45 08             	cmp    0x8(%ebp),%eax
80105634:	75 13                	jne    80105649 <semget+0xe4>
80105636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105639:	8b 40 04             	mov    0x4(%eax),%eax
8010563c:	85 c0                	test   %eax,%eax
8010563e:	75 09                	jne    80105649 <semget+0xe4>
        retvalue=-1;
80105640:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
        goto retget;
80105647:	eb 39                	jmp    80105682 <semget+0x11d>
    s->value=initvalue;
    retvalue=s->id;
    goto found;
  }
  if(semid>=0){
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
80105649:	83 45 f0 0c          	addl   $0xc,-0x10(%ebp)
8010564d:	b8 14 79 11 80       	mov    $0x80117914,%eax
80105652:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80105655:	72 b7                	jb     8010560e <semget+0xa9>
      if(s->id==semid && ((s->references)==0)){
        retvalue=-1;
        goto retget;
      }
    }
    retvalue=-5;
80105657:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    goto retget;
8010565e:	eb 22                	jmp    80105682 <semget+0x11d>
  }
found:
  s->references++;
80105660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105663:	8b 40 04             	mov    0x4(%eax),%eax
80105666:	8d 50 01             	lea    0x1(%eax),%edx
80105669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010566c:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[position]=s;
8010566f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105675:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105678:	8d 4a 20             	lea    0x20(%edx),%ecx
8010567b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010567e:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
retget:
  release(&stable.lock);
80105682:	83 ec 0c             	sub    $0xc,%esp
80105685:	68 e0 75 11 80       	push   $0x801175e0
8010568a:	e8 22 03 00 00       	call   801059b1 <release>
8010568f:	83 c4 10             	add    $0x10,%esp
  return retvalue;
80105692:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105695:	c9                   	leave  
80105696:	c3                   	ret    

80105697 <semfree>:

// It releases the semaphore of the process if it is not in use, but only decreases the references in 1.
// if the semaphore is not in the process, return -1.
int
semfree(int semid)
{
80105697:	55                   	push   %ebp
80105698:	89 e5                	mov    %esp,%ebp
8010569a:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int retvalue,pos;

  acquire(&stable.lock);
8010569d:	83 ec 0c             	sub    $0xc,%esp
801056a0:	68 e0 75 11 80       	push   $0x801175e0
801056a5:	e8 a0 02 00 00       	call   8010594a <acquire>
801056aa:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
801056ad:	83 ec 0c             	sub    $0xc,%esp
801056b0:	ff 75 08             	pushl  0x8(%ebp)
801056b3:	e8 1c fe ff ff       	call   801054d4 <searchinprocess>
801056b8:	83 c4 10             	add    $0x10,%esp
801056bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
801056be:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801056c2:	75 09                	jne    801056cd <semfree+0x36>
    retvalue=-1;
801056c4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retfree;
801056cb:	eb 50                	jmp    8010571d <semfree+0x86>
  }
  s=proc->osemaphore[pos];
801056cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056d6:	83 c2 20             	add    $0x20,%edx
801056d9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(s->references < 1){
801056e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056e3:	8b 40 04             	mov    0x4(%eax),%eax
801056e6:	85 c0                	test   %eax,%eax
801056e8:	7f 09                	jg     801056f3 <semfree+0x5c>
    retvalue=-2;
801056ea:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retfree;
801056f1:	eb 2a                	jmp    8010571d <semfree+0x86>
  }
  s->references--;
801056f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056f6:	8b 40 04             	mov    0x4(%eax),%eax
801056f9:	8d 50 ff             	lea    -0x1(%eax),%edx
801056fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056ff:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[pos]=0;
80105702:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105708:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010570b:	83 c2 20             	add    $0x20,%edx
8010570e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105715:	00 
  retvalue=0;
80105716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retfree:
  release(&stable.lock);
8010571d:	83 ec 0c             	sub    $0xc,%esp
80105720:	68 e0 75 11 80       	push   $0x801175e0
80105725:	e8 87 02 00 00       	call   801059b1 <release>
8010572a:	83 c4 10             	add    $0x10,%esp
  return retvalue;
8010572d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105730:	c9                   	leave  
80105731:	c3                   	ret    

80105732 <semdown>:

// Decreases the value of the semaphore if it is greater than 0 but sleeps the process.
// if the semaphore is not in the process, return -1.
int
semdown(int semid)
{
80105732:	55                   	push   %ebp
80105733:	89 e5                	mov    %esp,%ebp
80105735:	83 ec 18             	sub    $0x18,%esp
  int value,pos;
  struct semaphore* s;

  acquire(&stable.lock);
80105738:	83 ec 0c             	sub    $0xc,%esp
8010573b:	68 e0 75 11 80       	push   $0x801175e0
80105740:	e8 05 02 00 00       	call   8010594a <acquire>
80105745:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	ff 75 08             	pushl  0x8(%ebp)
8010574e:	e8 81 fd ff ff       	call   801054d4 <searchinprocess>
80105753:	83 c4 10             	add    $0x10,%esp
80105756:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
80105759:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010575d:	75 09                	jne    80105768 <semdown+0x36>
    value=-1;
8010575f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retdown;
80105766:	eb 48                	jmp    801057b0 <semdown+0x7e>
  }
  s=proc->osemaphore[pos];
80105768:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010576e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105771:	83 c2 20             	add    $0x20,%edx
80105774:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105778:	89 45 ec             	mov    %eax,-0x14(%ebp)
  while(s->value<=0){
8010577b:	eb 13                	jmp    80105790 <semdown+0x5e>
    sleep(s,&stable.lock);
8010577d:	83 ec 08             	sub    $0x8,%esp
80105780:	68 e0 75 11 80       	push   $0x801175e0
80105785:	ff 75 ec             	pushl  -0x14(%ebp)
80105788:	e8 01 fa ff ff       	call   8010518e <sleep>
8010578d:	83 c4 10             	add    $0x10,%esp
  if(pos==-1){
    value=-1;
    goto retdown;
  }
  s=proc->osemaphore[pos];
  while(s->value<=0){
80105790:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105793:	8b 40 08             	mov    0x8(%eax),%eax
80105796:	85 c0                	test   %eax,%eax
80105798:	7e e3                	jle    8010577d <semdown+0x4b>
    sleep(s,&stable.lock);
  }
  s->value--;
8010579a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010579d:	8b 40 08             	mov    0x8(%eax),%eax
801057a0:	8d 50 ff             	lea    -0x1(%eax),%edx
801057a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801057a6:	89 50 08             	mov    %edx,0x8(%eax)
  value=0;
801057a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retdown:
  release(&stable.lock);
801057b0:	83 ec 0c             	sub    $0xc,%esp
801057b3:	68 e0 75 11 80       	push   $0x801175e0
801057b8:	e8 f4 01 00 00       	call   801059b1 <release>
801057bd:	83 c4 10             	add    $0x10,%esp
  return value;
801057c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057c3:	c9                   	leave  
801057c4:	c3                   	ret    

801057c5 <semup>:

// It increases the value of the semaphore and wake up processes waiting for it.
// if the semaphore is not in the process, return -1.
int
semup(int semid)
{
801057c5:	55                   	push   %ebp
801057c6:	89 e5                	mov    %esp,%ebp
801057c8:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int pos;

  acquire(&stable.lock);
801057cb:	83 ec 0c             	sub    $0xc,%esp
801057ce:	68 e0 75 11 80       	push   $0x801175e0
801057d3:	e8 72 01 00 00       	call   8010594a <acquire>
801057d8:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
801057db:	83 ec 0c             	sub    $0xc,%esp
801057de:	ff 75 08             	pushl  0x8(%ebp)
801057e1:	e8 ee fc ff ff       	call   801054d4 <searchinprocess>
801057e6:	83 c4 10             	add    $0x10,%esp
801057e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pos==-1){
801057ec:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
801057f0:	75 17                	jne    80105809 <semup+0x44>
    release(&stable.lock);
801057f2:	83 ec 0c             	sub    $0xc,%esp
801057f5:	68 e0 75 11 80       	push   $0x801175e0
801057fa:	e8 b2 01 00 00       	call   801059b1 <release>
801057ff:	83 c4 10             	add    $0x10,%esp
    return -1;
80105802:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105807:	eb 45                	jmp    8010584e <semup+0x89>
  }
  s=proc->osemaphore[pos];
80105809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105812:	83 c2 20             	add    $0x20,%edx
80105815:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105819:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->value++;
8010581c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581f:	8b 40 08             	mov    0x8(%eax),%eax
80105822:	8d 50 01             	lea    0x1(%eax),%edx
80105825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105828:	89 50 08             	mov    %edx,0x8(%eax)
  release(&stable.lock);
8010582b:	83 ec 0c             	sub    $0xc,%esp
8010582e:	68 e0 75 11 80       	push   $0x801175e0
80105833:	e8 79 01 00 00       	call   801059b1 <release>
80105838:	83 c4 10             	add    $0x10,%esp
  wakeup(s);
8010583b:	83 ec 0c             	sub    $0xc,%esp
8010583e:	ff 75 f0             	pushl  -0x10(%ebp)
80105841:	e8 54 fa ff ff       	call   8010529a <wakeup>
80105846:	83 c4 10             	add    $0x10,%esp
  return 0;
80105849:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010584e:	c9                   	leave  
8010584f:	c3                   	ret    

80105850 <semclose>:

// Decrease the semaphore references.
void
semclose(struct semaphore* s)
{
80105850:	55                   	push   %ebp
80105851:	89 e5                	mov    %esp,%ebp
80105853:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
80105856:	83 ec 0c             	sub    $0xc,%esp
80105859:	68 e0 75 11 80       	push   $0x801175e0
8010585e:	e8 e7 00 00 00       	call   8010594a <acquire>
80105863:	83 c4 10             	add    $0x10,%esp

  if(s->references < 1)
80105866:	8b 45 08             	mov    0x8(%ebp),%eax
80105869:	8b 40 04             	mov    0x4(%eax),%eax
8010586c:	85 c0                	test   %eax,%eax
8010586e:	7f 0d                	jg     8010587d <semclose+0x2d>
    panic("semclose");
80105870:	83 ec 0c             	sub    $0xc,%esp
80105873:	68 24 96 10 80       	push   $0x80109624
80105878:	e8 e9 ac ff ff       	call   80100566 <panic>
  s->references--;
8010587d:	8b 45 08             	mov    0x8(%ebp),%eax
80105880:	8b 40 04             	mov    0x4(%eax),%eax
80105883:	8d 50 ff             	lea    -0x1(%eax),%edx
80105886:	8b 45 08             	mov    0x8(%ebp),%eax
80105889:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
8010588c:	83 ec 0c             	sub    $0xc,%esp
8010588f:	68 e0 75 11 80       	push   $0x801175e0
80105894:	e8 18 01 00 00       	call   801059b1 <release>
80105899:	83 c4 10             	add    $0x10,%esp
  return;
8010589c:	90                   	nop

}
8010589d:	c9                   	leave  
8010589e:	c3                   	ret    

8010589f <semdup>:

// Increase the semaphore references.
struct semaphore*
semdup(struct semaphore* s)
{
8010589f:	55                   	push   %ebp
801058a0:	89 e5                	mov    %esp,%ebp
801058a2:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
801058a5:	83 ec 0c             	sub    $0xc,%esp
801058a8:	68 e0 75 11 80       	push   $0x801175e0
801058ad:	e8 98 00 00 00       	call   8010594a <acquire>
801058b2:	83 c4 10             	add    $0x10,%esp
  if(s->references<0)
801058b5:	8b 45 08             	mov    0x8(%ebp),%eax
801058b8:	8b 40 04             	mov    0x4(%eax),%eax
801058bb:	85 c0                	test   %eax,%eax
801058bd:	79 0d                	jns    801058cc <semdup+0x2d>
    panic("semdup error");
801058bf:	83 ec 0c             	sub    $0xc,%esp
801058c2:	68 2d 96 10 80       	push   $0x8010962d
801058c7:	e8 9a ac ff ff       	call   80100566 <panic>
  s->references++;
801058cc:	8b 45 08             	mov    0x8(%ebp),%eax
801058cf:	8b 40 04             	mov    0x4(%eax),%eax
801058d2:	8d 50 01             	lea    0x1(%eax),%edx
801058d5:	8b 45 08             	mov    0x8(%ebp),%eax
801058d8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	68 e0 75 11 80       	push   $0x801175e0
801058e3:	e8 c9 00 00 00       	call   801059b1 <release>
801058e8:	83 c4 10             	add    $0x10,%esp
  return s;
801058eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801058ee:	c9                   	leave  
801058ef:	c3                   	ret    

801058f0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801058f0:	55                   	push   %ebp
801058f1:	89 e5                	mov    %esp,%ebp
801058f3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801058f6:	9c                   	pushf  
801058f7:	58                   	pop    %eax
801058f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801058fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058fe:	c9                   	leave  
801058ff:	c3                   	ret    

80105900 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105903:	fa                   	cli    
}
80105904:	90                   	nop
80105905:	5d                   	pop    %ebp
80105906:	c3                   	ret    

80105907 <sti>:

static inline void
sti(void)
{
80105907:	55                   	push   %ebp
80105908:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010590a:	fb                   	sti    
}
8010590b:	90                   	nop
8010590c:	5d                   	pop    %ebp
8010590d:	c3                   	ret    

8010590e <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010590e:	55                   	push   %ebp
8010590f:	89 e5                	mov    %esp,%ebp
80105911:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105914:	8b 55 08             	mov    0x8(%ebp),%edx
80105917:	8b 45 0c             	mov    0xc(%ebp),%eax
8010591a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010591d:	f0 87 02             	lock xchg %eax,(%edx)
80105920:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105923:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105926:	c9                   	leave  
80105927:	c3                   	ret    

80105928 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105928:	55                   	push   %ebp
80105929:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010592b:	8b 45 08             	mov    0x8(%ebp),%eax
8010592e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105931:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105934:	8b 45 08             	mov    0x8(%ebp),%eax
80105937:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010593d:	8b 45 08             	mov    0x8(%ebp),%eax
80105940:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105947:	90                   	nop
80105948:	5d                   	pop    %ebp
80105949:	c3                   	ret    

8010594a <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010594a:	55                   	push   %ebp
8010594b:	89 e5                	mov    %esp,%ebp
8010594d:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105950:	e8 52 01 00 00       	call   80105aa7 <pushcli>
  if(holding(lk))
80105955:	8b 45 08             	mov    0x8(%ebp),%eax
80105958:	83 ec 0c             	sub    $0xc,%esp
8010595b:	50                   	push   %eax
8010595c:	e8 1c 01 00 00       	call   80105a7d <holding>
80105961:	83 c4 10             	add    $0x10,%esp
80105964:	85 c0                	test   %eax,%eax
80105966:	74 0d                	je     80105975 <acquire+0x2b>
    panic("acquire");
80105968:	83 ec 0c             	sub    $0xc,%esp
8010596b:	68 3a 96 10 80       	push   $0x8010963a
80105970:	e8 f1 ab ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while(xchg(&lk->locked, 1) != 0)
80105975:	90                   	nop
80105976:	8b 45 08             	mov    0x8(%ebp),%eax
80105979:	83 ec 08             	sub    $0x8,%esp
8010597c:	6a 01                	push   $0x1
8010597e:	50                   	push   %eax
8010597f:	e8 8a ff ff ff       	call   8010590e <xchg>
80105984:	83 c4 10             	add    $0x10,%esp
80105987:	85 c0                	test   %eax,%eax
80105989:	75 eb                	jne    80105976 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010598b:	8b 45 08             	mov    0x8(%ebp),%eax
8010598e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105995:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105998:	8b 45 08             	mov    0x8(%ebp),%eax
8010599b:	83 c0 0c             	add    $0xc,%eax
8010599e:	83 ec 08             	sub    $0x8,%esp
801059a1:	50                   	push   %eax
801059a2:	8d 45 08             	lea    0x8(%ebp),%eax
801059a5:	50                   	push   %eax
801059a6:	e8 58 00 00 00       	call   80105a03 <getcallerpcs>
801059ab:	83 c4 10             	add    $0x10,%esp
}
801059ae:	90                   	nop
801059af:	c9                   	leave  
801059b0:	c3                   	ret    

801059b1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801059b1:	55                   	push   %ebp
801059b2:	89 e5                	mov    %esp,%ebp
801059b4:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801059b7:	83 ec 0c             	sub    $0xc,%esp
801059ba:	ff 75 08             	pushl  0x8(%ebp)
801059bd:	e8 bb 00 00 00       	call   80105a7d <holding>
801059c2:	83 c4 10             	add    $0x10,%esp
801059c5:	85 c0                	test   %eax,%eax
801059c7:	75 0d                	jne    801059d6 <release+0x25>
    panic("release");
801059c9:	83 ec 0c             	sub    $0xc,%esp
801059cc:	68 42 96 10 80       	push   $0x80109642
801059d1:	e8 90 ab ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801059d6:	8b 45 08             	mov    0x8(%ebp),%eax
801059d9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801059e0:	8b 45 08             	mov    0x8(%ebp),%eax
801059e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801059ea:	8b 45 08             	mov    0x8(%ebp),%eax
801059ed:	83 ec 08             	sub    $0x8,%esp
801059f0:	6a 00                	push   $0x0
801059f2:	50                   	push   %eax
801059f3:	e8 16 ff ff ff       	call   8010590e <xchg>
801059f8:	83 c4 10             	add    $0x10,%esp

  popcli();
801059fb:	e8 ec 00 00 00       	call   80105aec <popcli>
}
80105a00:	90                   	nop
80105a01:	c9                   	leave  
80105a02:	c3                   	ret    

80105a03 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105a03:	55                   	push   %ebp
80105a04:	89 e5                	mov    %esp,%ebp
80105a06:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105a09:	8b 45 08             	mov    0x8(%ebp),%eax
80105a0c:	83 e8 08             	sub    $0x8,%eax
80105a0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105a12:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105a19:	eb 38                	jmp    80105a53 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105a1b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105a1f:	74 53                	je     80105a74 <getcallerpcs+0x71>
80105a21:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105a28:	76 4a                	jbe    80105a74 <getcallerpcs+0x71>
80105a2a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105a2e:	74 44                	je     80105a74 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105a30:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a3d:	01 c2                	add    %eax,%edx
80105a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a42:	8b 40 04             	mov    0x4(%eax),%eax
80105a45:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a4a:	8b 00                	mov    (%eax),%eax
80105a4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105a4f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105a53:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a57:	7e c2                	jle    80105a1b <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a59:	eb 19                	jmp    80105a74 <getcallerpcs+0x71>
    pcs[i] = 0;
80105a5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a65:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a68:	01 d0                	add    %edx,%eax
80105a6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a70:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105a74:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a78:	7e e1                	jle    80105a5b <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105a7a:	90                   	nop
80105a7b:	c9                   	leave  
80105a7c:	c3                   	ret    

80105a7d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105a7d:	55                   	push   %ebp
80105a7e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105a80:	8b 45 08             	mov    0x8(%ebp),%eax
80105a83:	8b 00                	mov    (%eax),%eax
80105a85:	85 c0                	test   %eax,%eax
80105a87:	74 17                	je     80105aa0 <holding+0x23>
80105a89:	8b 45 08             	mov    0x8(%ebp),%eax
80105a8c:	8b 50 08             	mov    0x8(%eax),%edx
80105a8f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105a95:	39 c2                	cmp    %eax,%edx
80105a97:	75 07                	jne    80105aa0 <holding+0x23>
80105a99:	b8 01 00 00 00       	mov    $0x1,%eax
80105a9e:	eb 05                	jmp    80105aa5 <holding+0x28>
80105aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aa5:	5d                   	pop    %ebp
80105aa6:	c3                   	ret    

80105aa7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105aa7:	55                   	push   %ebp
80105aa8:	89 e5                	mov    %esp,%ebp
80105aaa:	83 ec 10             	sub    $0x10,%esp
  int eflags;

  eflags = readeflags();
80105aad:	e8 3e fe ff ff       	call   801058f0 <readeflags>
80105ab2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105ab5:	e8 46 fe ff ff       	call   80105900 <cli>
  if(cpu->ncli++ == 0)
80105aba:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105ac1:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105ac7:	8d 48 01             	lea    0x1(%eax),%ecx
80105aca:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105ad0:	85 c0                	test   %eax,%eax
80105ad2:	75 15                	jne    80105ae9 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105ad4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ada:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105add:	81 e2 00 02 00 00    	and    $0x200,%edx
80105ae3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105ae9:	90                   	nop
80105aea:	c9                   	leave  
80105aeb:	c3                   	ret    

80105aec <popcli>:

void
popcli(void)
{
80105aec:	55                   	push   %ebp
80105aed:	89 e5                	mov    %esp,%ebp
80105aef:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105af2:	e8 f9 fd ff ff       	call   801058f0 <readeflags>
80105af7:	25 00 02 00 00       	and    $0x200,%eax
80105afc:	85 c0                	test   %eax,%eax
80105afe:	74 0d                	je     80105b0d <popcli+0x21>
    panic("popcli - interruptible");
80105b00:	83 ec 0c             	sub    $0xc,%esp
80105b03:	68 4a 96 10 80       	push   $0x8010964a
80105b08:	e8 59 aa ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105b0d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b13:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105b19:	83 ea 01             	sub    $0x1,%edx
80105b1c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105b22:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105b28:	85 c0                	test   %eax,%eax
80105b2a:	79 0d                	jns    80105b39 <popcli+0x4d>
    panic("popcli");
80105b2c:	83 ec 0c             	sub    $0xc,%esp
80105b2f:	68 61 96 10 80       	push   $0x80109661
80105b34:	e8 2d aa ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105b39:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b3f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105b45:	85 c0                	test   %eax,%eax
80105b47:	75 15                	jne    80105b5e <popcli+0x72>
80105b49:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105b4f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105b55:	85 c0                	test   %eax,%eax
80105b57:	74 05                	je     80105b5e <popcli+0x72>
    sti();
80105b59:	e8 a9 fd ff ff       	call   80105907 <sti>
}
80105b5e:	90                   	nop
80105b5f:	c9                   	leave  
80105b60:	c3                   	ret    

80105b61 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105b61:	55                   	push   %ebp
80105b62:	89 e5                	mov    %esp,%ebp
80105b64:	57                   	push   %edi
80105b65:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105b66:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b69:	8b 55 10             	mov    0x10(%ebp),%edx
80105b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b6f:	89 cb                	mov    %ecx,%ebx
80105b71:	89 df                	mov    %ebx,%edi
80105b73:	89 d1                	mov    %edx,%ecx
80105b75:	fc                   	cld    
80105b76:	f3 aa                	rep stos %al,%es:(%edi)
80105b78:	89 ca                	mov    %ecx,%edx
80105b7a:	89 fb                	mov    %edi,%ebx
80105b7c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105b7f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105b82:	90                   	nop
80105b83:	5b                   	pop    %ebx
80105b84:	5f                   	pop    %edi
80105b85:	5d                   	pop    %ebp
80105b86:	c3                   	ret    

80105b87 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105b87:	55                   	push   %ebp
80105b88:	89 e5                	mov    %esp,%ebp
80105b8a:	57                   	push   %edi
80105b8b:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b8f:	8b 55 10             	mov    0x10(%ebp),%edx
80105b92:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b95:	89 cb                	mov    %ecx,%ebx
80105b97:	89 df                	mov    %ebx,%edi
80105b99:	89 d1                	mov    %edx,%ecx
80105b9b:	fc                   	cld    
80105b9c:	f3 ab                	rep stos %eax,%es:(%edi)
80105b9e:	89 ca                	mov    %ecx,%edx
80105ba0:	89 fb                	mov    %edi,%ebx
80105ba2:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105ba5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105ba8:	90                   	nop
80105ba9:	5b                   	pop    %ebx
80105baa:	5f                   	pop    %edi
80105bab:	5d                   	pop    %ebp
80105bac:	c3                   	ret    

80105bad <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105bad:	55                   	push   %ebp
80105bae:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb3:	83 e0 03             	and    $0x3,%eax
80105bb6:	85 c0                	test   %eax,%eax
80105bb8:	75 43                	jne    80105bfd <memset+0x50>
80105bba:	8b 45 10             	mov    0x10(%ebp),%eax
80105bbd:	83 e0 03             	and    $0x3,%eax
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	75 39                	jne    80105bfd <memset+0x50>
    c &= 0xFF;
80105bc4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105bcb:	8b 45 10             	mov    0x10(%ebp),%eax
80105bce:	c1 e8 02             	shr    $0x2,%eax
80105bd1:	89 c1                	mov    %eax,%ecx
80105bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd6:	c1 e0 18             	shl    $0x18,%eax
80105bd9:	89 c2                	mov    %eax,%edx
80105bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bde:	c1 e0 10             	shl    $0x10,%eax
80105be1:	09 c2                	or     %eax,%edx
80105be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105be6:	c1 e0 08             	shl    $0x8,%eax
80105be9:	09 d0                	or     %edx,%eax
80105beb:	0b 45 0c             	or     0xc(%ebp),%eax
80105bee:	51                   	push   %ecx
80105bef:	50                   	push   %eax
80105bf0:	ff 75 08             	pushl  0x8(%ebp)
80105bf3:	e8 8f ff ff ff       	call   80105b87 <stosl>
80105bf8:	83 c4 0c             	add    $0xc,%esp
80105bfb:	eb 12                	jmp    80105c0f <memset+0x62>
  } else
    stosb(dst, c, n);
80105bfd:	8b 45 10             	mov    0x10(%ebp),%eax
80105c00:	50                   	push   %eax
80105c01:	ff 75 0c             	pushl  0xc(%ebp)
80105c04:	ff 75 08             	pushl  0x8(%ebp)
80105c07:	e8 55 ff ff ff       	call   80105b61 <stosb>
80105c0c:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105c0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105c12:	c9                   	leave  
80105c13:	c3                   	ret    

80105c14 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105c14:	55                   	push   %ebp
80105c15:	89 e5                	mov    %esp,%ebp
80105c17:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105c20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c23:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105c26:	eb 30                	jmp    80105c58 <memcmp+0x44>
    if(*s1 != *s2)
80105c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c2b:	0f b6 10             	movzbl (%eax),%edx
80105c2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c31:	0f b6 00             	movzbl (%eax),%eax
80105c34:	38 c2                	cmp    %al,%dl
80105c36:	74 18                	je     80105c50 <memcmp+0x3c>
      return *s1 - *s2;
80105c38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c3b:	0f b6 00             	movzbl (%eax),%eax
80105c3e:	0f b6 d0             	movzbl %al,%edx
80105c41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c44:	0f b6 00             	movzbl (%eax),%eax
80105c47:	0f b6 c0             	movzbl %al,%eax
80105c4a:	29 c2                	sub    %eax,%edx
80105c4c:	89 d0                	mov    %edx,%eax
80105c4e:	eb 1a                	jmp    80105c6a <memcmp+0x56>
    s1++, s2++;
80105c50:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105c54:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105c58:	8b 45 10             	mov    0x10(%ebp),%eax
80105c5b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c5e:	89 55 10             	mov    %edx,0x10(%ebp)
80105c61:	85 c0                	test   %eax,%eax
80105c63:	75 c3                	jne    80105c28 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105c65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c6a:	c9                   	leave  
80105c6b:	c3                   	ret    

80105c6c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105c6c:	55                   	push   %ebp
80105c6d:	89 e5                	mov    %esp,%ebp
80105c6f:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105c72:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c75:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105c78:	8b 45 08             	mov    0x8(%ebp),%eax
80105c7b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105c7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c81:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c84:	73 54                	jae    80105cda <memmove+0x6e>
80105c86:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c89:	8b 45 10             	mov    0x10(%ebp),%eax
80105c8c:	01 d0                	add    %edx,%eax
80105c8e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c91:	76 47                	jbe    80105cda <memmove+0x6e>
    s += n;
80105c93:	8b 45 10             	mov    0x10(%ebp),%eax
80105c96:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105c99:	8b 45 10             	mov    0x10(%ebp),%eax
80105c9c:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105c9f:	eb 13                	jmp    80105cb4 <memmove+0x48>
      *--d = *--s;
80105ca1:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105ca5:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cac:	0f b6 10             	movzbl (%eax),%edx
80105caf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cb2:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105cb4:	8b 45 10             	mov    0x10(%ebp),%eax
80105cb7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cba:	89 55 10             	mov    %edx,0x10(%ebp)
80105cbd:	85 c0                	test   %eax,%eax
80105cbf:	75 e0                	jne    80105ca1 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105cc1:	eb 24                	jmp    80105ce7 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105cc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cc6:	8d 50 01             	lea    0x1(%eax),%edx
80105cc9:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105ccc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ccf:	8d 4a 01             	lea    0x1(%edx),%ecx
80105cd2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105cd5:	0f b6 12             	movzbl (%edx),%edx
80105cd8:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105cda:	8b 45 10             	mov    0x10(%ebp),%eax
80105cdd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ce0:	89 55 10             	mov    %edx,0x10(%ebp)
80105ce3:	85 c0                	test   %eax,%eax
80105ce5:	75 dc                	jne    80105cc3 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105ce7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105cea:	c9                   	leave  
80105ceb:	c3                   	ret    

80105cec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105cec:	55                   	push   %ebp
80105ced:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105cef:	ff 75 10             	pushl  0x10(%ebp)
80105cf2:	ff 75 0c             	pushl  0xc(%ebp)
80105cf5:	ff 75 08             	pushl  0x8(%ebp)
80105cf8:	e8 6f ff ff ff       	call   80105c6c <memmove>
80105cfd:	83 c4 0c             	add    $0xc,%esp
}
80105d00:	c9                   	leave  
80105d01:	c3                   	ret    

80105d02 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105d02:	55                   	push   %ebp
80105d03:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105d05:	eb 0c                	jmp    80105d13 <strncmp+0x11>
    n--, p++, q++;
80105d07:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105d0b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105d0f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105d13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d17:	74 1a                	je     80105d33 <strncmp+0x31>
80105d19:	8b 45 08             	mov    0x8(%ebp),%eax
80105d1c:	0f b6 00             	movzbl (%eax),%eax
80105d1f:	84 c0                	test   %al,%al
80105d21:	74 10                	je     80105d33 <strncmp+0x31>
80105d23:	8b 45 08             	mov    0x8(%ebp),%eax
80105d26:	0f b6 10             	movzbl (%eax),%edx
80105d29:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2c:	0f b6 00             	movzbl (%eax),%eax
80105d2f:	38 c2                	cmp    %al,%dl
80105d31:	74 d4                	je     80105d07 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105d33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d37:	75 07                	jne    80105d40 <strncmp+0x3e>
    return 0;
80105d39:	b8 00 00 00 00       	mov    $0x0,%eax
80105d3e:	eb 16                	jmp    80105d56 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105d40:	8b 45 08             	mov    0x8(%ebp),%eax
80105d43:	0f b6 00             	movzbl (%eax),%eax
80105d46:	0f b6 d0             	movzbl %al,%edx
80105d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d4c:	0f b6 00             	movzbl (%eax),%eax
80105d4f:	0f b6 c0             	movzbl %al,%eax
80105d52:	29 c2                	sub    %eax,%edx
80105d54:	89 d0                	mov    %edx,%eax
}
80105d56:	5d                   	pop    %ebp
80105d57:	c3                   	ret    

80105d58 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105d58:	55                   	push   %ebp
80105d59:	89 e5                	mov    %esp,%ebp
80105d5b:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d61:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105d64:	90                   	nop
80105d65:	8b 45 10             	mov    0x10(%ebp),%eax
80105d68:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d6b:	89 55 10             	mov    %edx,0x10(%ebp)
80105d6e:	85 c0                	test   %eax,%eax
80105d70:	7e 2c                	jle    80105d9e <strncpy+0x46>
80105d72:	8b 45 08             	mov    0x8(%ebp),%eax
80105d75:	8d 50 01             	lea    0x1(%eax),%edx
80105d78:	89 55 08             	mov    %edx,0x8(%ebp)
80105d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d7e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105d81:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105d84:	0f b6 12             	movzbl (%edx),%edx
80105d87:	88 10                	mov    %dl,(%eax)
80105d89:	0f b6 00             	movzbl (%eax),%eax
80105d8c:	84 c0                	test   %al,%al
80105d8e:	75 d5                	jne    80105d65 <strncpy+0xd>
    ;
  while(n-- > 0)
80105d90:	eb 0c                	jmp    80105d9e <strncpy+0x46>
    *s++ = 0;
80105d92:	8b 45 08             	mov    0x8(%ebp),%eax
80105d95:	8d 50 01             	lea    0x1(%eax),%edx
80105d98:	89 55 08             	mov    %edx,0x8(%ebp)
80105d9b:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105d9e:	8b 45 10             	mov    0x10(%ebp),%eax
80105da1:	8d 50 ff             	lea    -0x1(%eax),%edx
80105da4:	89 55 10             	mov    %edx,0x10(%ebp)
80105da7:	85 c0                	test   %eax,%eax
80105da9:	7f e7                	jg     80105d92 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dae:	c9                   	leave  
80105daf:	c3                   	ret    

80105db0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105db0:	55                   	push   %ebp
80105db1:	89 e5                	mov    %esp,%ebp
80105db3:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105db6:	8b 45 08             	mov    0x8(%ebp),%eax
80105db9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105dbc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dc0:	7f 05                	jg     80105dc7 <safestrcpy+0x17>
    return os;
80105dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dc5:	eb 31                	jmp    80105df8 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105dc7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105dcb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dcf:	7e 1e                	jle    80105def <safestrcpy+0x3f>
80105dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd4:	8d 50 01             	lea    0x1(%eax),%edx
80105dd7:	89 55 08             	mov    %edx,0x8(%ebp)
80105dda:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ddd:	8d 4a 01             	lea    0x1(%edx),%ecx
80105de0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105de3:	0f b6 12             	movzbl (%edx),%edx
80105de6:	88 10                	mov    %dl,(%eax)
80105de8:	0f b6 00             	movzbl (%eax),%eax
80105deb:	84 c0                	test   %al,%al
80105ded:	75 d8                	jne    80105dc7 <safestrcpy+0x17>
    ;
  *s = 0;
80105def:	8b 45 08             	mov    0x8(%ebp),%eax
80105df2:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105df5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105df8:	c9                   	leave  
80105df9:	c3                   	ret    

80105dfa <strlen>:

int
strlen(const char *s)
{
80105dfa:	55                   	push   %ebp
80105dfb:	89 e5                	mov    %esp,%ebp
80105dfd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105e00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105e07:	eb 04                	jmp    80105e0d <strlen+0x13>
80105e09:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e0d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e10:	8b 45 08             	mov    0x8(%ebp),%eax
80105e13:	01 d0                	add    %edx,%eax
80105e15:	0f b6 00             	movzbl (%eax),%eax
80105e18:	84 c0                	test   %al,%al
80105e1a:	75 ed                	jne    80105e09 <strlen+0xf>
    ;
  return n;
80105e1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e1f:	c9                   	leave  
80105e20:	c3                   	ret    

80105e21 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105e21:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105e25:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105e29:	55                   	push   %ebp
  pushl %ebx
80105e2a:	53                   	push   %ebx
  pushl %esi
80105e2b:	56                   	push   %esi
  pushl %edi
80105e2c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105e2d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105e2f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105e31:	5f                   	pop    %edi
  popl %esi
80105e32:	5e                   	pop    %esi
  popl %ebx
80105e33:	5b                   	pop    %ebx
  popl %ebp
80105e34:	5d                   	pop    %ebp
  ret
80105e35:	c3                   	ret    

80105e36 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105e36:	55                   	push   %ebp
80105e37:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105e39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e3f:	8b 00                	mov    (%eax),%eax
80105e41:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e44:	76 12                	jbe    80105e58 <fetchint+0x22>
80105e46:	8b 45 08             	mov    0x8(%ebp),%eax
80105e49:	8d 50 04             	lea    0x4(%eax),%edx
80105e4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e52:	8b 00                	mov    (%eax),%eax
80105e54:	39 c2                	cmp    %eax,%edx
80105e56:	76 07                	jbe    80105e5f <fetchint+0x29>
    return -1;
80105e58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5d:	eb 0f                	jmp    80105e6e <fetchint+0x38>
  *ip = *(int*)(addr);
80105e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80105e62:	8b 10                	mov    (%eax),%edx
80105e64:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e67:	89 10                	mov    %edx,(%eax)
  return 0;
80105e69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e6e:	5d                   	pop    %ebp
80105e6f:	c3                   	ret    

80105e70 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105e70:	55                   	push   %ebp
80105e71:	89 e5                	mov    %esp,%ebp
80105e73:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e7c:	8b 00                	mov    (%eax),%eax
80105e7e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e81:	77 07                	ja     80105e8a <fetchstr+0x1a>
    return -1;
80105e83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e88:	eb 46                	jmp    80105ed0 <fetchstr+0x60>
  *pp = (char*)addr;
80105e8a:	8b 55 08             	mov    0x8(%ebp),%edx
80105e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e90:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105e92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e98:	8b 00                	mov    (%eax),%eax
80105e9a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea0:	8b 00                	mov    (%eax),%eax
80105ea2:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105ea5:	eb 1c                	jmp    80105ec3 <fetchstr+0x53>
    if(*s == 0)
80105ea7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105eaa:	0f b6 00             	movzbl (%eax),%eax
80105ead:	84 c0                	test   %al,%al
80105eaf:	75 0e                	jne    80105ebf <fetchstr+0x4f>
      return s - *pp;
80105eb1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb7:	8b 00                	mov    (%eax),%eax
80105eb9:	29 c2                	sub    %eax,%edx
80105ebb:	89 d0                	mov    %edx,%eax
80105ebd:	eb 11                	jmp    80105ed0 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105ebf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ec3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ec6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ec9:	72 dc                	jb     80105ea7 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ed0:	c9                   	leave  
80105ed1:	c3                   	ret    

80105ed2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105ed2:	55                   	push   %ebp
80105ed3:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105ed5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105edb:	8b 40 18             	mov    0x18(%eax),%eax
80105ede:	8b 40 44             	mov    0x44(%eax),%eax
80105ee1:	8b 55 08             	mov    0x8(%ebp),%edx
80105ee4:	c1 e2 02             	shl    $0x2,%edx
80105ee7:	01 d0                	add    %edx,%eax
80105ee9:	83 c0 04             	add    $0x4,%eax
80105eec:	ff 75 0c             	pushl  0xc(%ebp)
80105eef:	50                   	push   %eax
80105ef0:	e8 41 ff ff ff       	call   80105e36 <fetchint>
80105ef5:	83 c4 08             	add    $0x8,%esp
}
80105ef8:	c9                   	leave  
80105ef9:	c3                   	ret    

80105efa <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105efa:	55                   	push   %ebp
80105efb:	89 e5                	mov    %esp,%ebp
80105efd:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80105f00:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105f03:	50                   	push   %eax
80105f04:	ff 75 08             	pushl  0x8(%ebp)
80105f07:	e8 c6 ff ff ff       	call   80105ed2 <argint>
80105f0c:	83 c4 08             	add    $0x8,%esp
80105f0f:	85 c0                	test   %eax,%eax
80105f11:	79 07                	jns    80105f1a <argptr+0x20>
    return -1;
80105f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f18:	eb 3b                	jmp    80105f55 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105f1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f20:	8b 00                	mov    (%eax),%eax
80105f22:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f25:	39 d0                	cmp    %edx,%eax
80105f27:	76 16                	jbe    80105f3f <argptr+0x45>
80105f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f2c:	89 c2                	mov    %eax,%edx
80105f2e:	8b 45 10             	mov    0x10(%ebp),%eax
80105f31:	01 c2                	add    %eax,%edx
80105f33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f39:	8b 00                	mov    (%eax),%eax
80105f3b:	39 c2                	cmp    %eax,%edx
80105f3d:	76 07                	jbe    80105f46 <argptr+0x4c>
    return -1;
80105f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f44:	eb 0f                	jmp    80105f55 <argptr+0x5b>
  *pp = (char*)i;
80105f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f49:	89 c2                	mov    %eax,%edx
80105f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f4e:	89 10                	mov    %edx,(%eax)
  return 0;
80105f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f55:	c9                   	leave  
80105f56:	c3                   	ret    

80105f57 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105f57:	55                   	push   %ebp
80105f58:	89 e5                	mov    %esp,%ebp
80105f5a:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105f5d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105f60:	50                   	push   %eax
80105f61:	ff 75 08             	pushl  0x8(%ebp)
80105f64:	e8 69 ff ff ff       	call   80105ed2 <argint>
80105f69:	83 c4 08             	add    $0x8,%esp
80105f6c:	85 c0                	test   %eax,%eax
80105f6e:	79 07                	jns    80105f77 <argstr+0x20>
    return -1;
80105f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f75:	eb 0f                	jmp    80105f86 <argstr+0x2f>
  return fetchstr(addr, pp);
80105f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f7a:	ff 75 0c             	pushl  0xc(%ebp)
80105f7d:	50                   	push   %eax
80105f7e:	e8 ed fe ff ff       	call   80105e70 <fetchstr>
80105f83:	83 c4 08             	add    $0x8,%esp
}
80105f86:	c9                   	leave  
80105f87:	c3                   	ret    

80105f88 <syscall>:
[SYS_mmap]   sys_mmap
};

void
syscall(void)
{
80105f88:	55                   	push   %ebp
80105f89:	89 e5                	mov    %esp,%ebp
80105f8b:	53                   	push   %ebx
80105f8c:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105f8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f95:	8b 40 18             	mov    0x18(%eax),%eax
80105f98:	8b 40 1c             	mov    0x1c(%eax),%eax
80105f9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105f9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fa2:	7e 30                	jle    80105fd4 <syscall+0x4c>
80105fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa7:	83 f8 1d             	cmp    $0x1d,%eax
80105faa:	77 28                	ja     80105fd4 <syscall+0x4c>
80105fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105faf:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105fb6:	85 c0                	test   %eax,%eax
80105fb8:	74 1a                	je     80105fd4 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105fba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fc0:	8b 58 18             	mov    0x18(%eax),%ebx
80105fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc6:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105fcd:	ff d0                	call   *%eax
80105fcf:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105fd2:	eb 34                	jmp    80106008 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105fd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fda:	8d 50 6c             	lea    0x6c(%eax),%edx
80105fdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105fe3:	8b 40 10             	mov    0x10(%eax),%eax
80105fe6:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe9:	52                   	push   %edx
80105fea:	50                   	push   %eax
80105feb:	68 68 96 10 80       	push   $0x80109668
80105ff0:	e8 d1 a3 ff ff       	call   801003c6 <cprintf>
80105ff5:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105ff8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ffe:	8b 40 18             	mov    0x18(%eax),%eax
80106001:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106008:	90                   	nop
80106009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010600c:	c9                   	leave  
8010600d:	c3                   	ret    

8010600e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010600e:	55                   	push   %ebp
8010600f:	89 e5                	mov    %esp,%ebp
80106011:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106014:	83 ec 08             	sub    $0x8,%esp
80106017:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010601a:	50                   	push   %eax
8010601b:	ff 75 08             	pushl  0x8(%ebp)
8010601e:	e8 af fe ff ff       	call   80105ed2 <argint>
80106023:	83 c4 10             	add    $0x10,%esp
80106026:	85 c0                	test   %eax,%eax
80106028:	79 07                	jns    80106031 <argfd+0x23>
    return -1;
8010602a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602f:	eb 50                	jmp    80106081 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106034:	85 c0                	test   %eax,%eax
80106036:	78 21                	js     80106059 <argfd+0x4b>
80106038:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603b:	83 f8 0f             	cmp    $0xf,%eax
8010603e:	7f 19                	jg     80106059 <argfd+0x4b>
80106040:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106046:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106049:	83 c2 08             	add    $0x8,%edx
8010604c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106050:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106053:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106057:	75 07                	jne    80106060 <argfd+0x52>
    return -1;
80106059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605e:	eb 21                	jmp    80106081 <argfd+0x73>
  if(pfd)
80106060:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106064:	74 08                	je     8010606e <argfd+0x60>
    *pfd = fd;
80106066:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010606c:	89 10                	mov    %edx,(%eax)
  if(pf)
8010606e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106072:	74 08                	je     8010607c <argfd+0x6e>
    *pf = f;
80106074:	8b 45 10             	mov    0x10(%ebp),%eax
80106077:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010607a:	89 10                	mov    %edx,(%eax)
  return 0;
8010607c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106081:	c9                   	leave  
80106082:	c3                   	ret    

80106083 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106083:	55                   	push   %ebp
80106084:	89 e5                	mov    %esp,%ebp
80106086:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106089:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106090:	eb 30                	jmp    801060c2 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106092:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106098:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010609b:	83 c2 08             	add    $0x8,%edx
8010609e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801060a2:	85 c0                	test   %eax,%eax
801060a4:	75 18                	jne    801060be <fdalloc+0x3b>
      proc->ofile[fd] = f;
801060a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060af:	8d 4a 08             	lea    0x8(%edx),%ecx
801060b2:	8b 55 08             	mov    0x8(%ebp),%edx
801060b5:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801060b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060bc:	eb 0f                	jmp    801060cd <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801060be:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060c2:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801060c6:	7e ca                	jle    80106092 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801060c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060cd:	c9                   	leave  
801060ce:	c3                   	ret    

801060cf <sys_dup>:

int
sys_dup(void)
{
801060cf:	55                   	push   %ebp
801060d0:	89 e5                	mov    %esp,%ebp
801060d2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801060d5:	83 ec 04             	sub    $0x4,%esp
801060d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060db:	50                   	push   %eax
801060dc:	6a 00                	push   $0x0
801060de:	6a 00                	push   $0x0
801060e0:	e8 29 ff ff ff       	call   8010600e <argfd>
801060e5:	83 c4 10             	add    $0x10,%esp
801060e8:	85 c0                	test   %eax,%eax
801060ea:	79 07                	jns    801060f3 <sys_dup+0x24>
    return -1;
801060ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f1:	eb 31                	jmp    80106124 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801060f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f6:	83 ec 0c             	sub    $0xc,%esp
801060f9:	50                   	push   %eax
801060fa:	e8 84 ff ff ff       	call   80106083 <fdalloc>
801060ff:	83 c4 10             	add    $0x10,%esp
80106102:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106105:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106109:	79 07                	jns    80106112 <sys_dup+0x43>
    return -1;
8010610b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106110:	eb 12                	jmp    80106124 <sys_dup+0x55>
  filedup(f);
80106112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106115:	83 ec 0c             	sub    $0xc,%esp
80106118:	50                   	push   %eax
80106119:	e8 cf ae ff ff       	call   80100fed <filedup>
8010611e:	83 c4 10             	add    $0x10,%esp
  return fd;
80106121:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106124:	c9                   	leave  
80106125:	c3                   	ret    

80106126 <sys_read>:

int
sys_read(void)
{
80106126:	55                   	push   %ebp
80106127:	89 e5                	mov    %esp,%ebp
80106129:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010612c:	83 ec 04             	sub    $0x4,%esp
8010612f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106132:	50                   	push   %eax
80106133:	6a 00                	push   $0x0
80106135:	6a 00                	push   $0x0
80106137:	e8 d2 fe ff ff       	call   8010600e <argfd>
8010613c:	83 c4 10             	add    $0x10,%esp
8010613f:	85 c0                	test   %eax,%eax
80106141:	78 2e                	js     80106171 <sys_read+0x4b>
80106143:	83 ec 08             	sub    $0x8,%esp
80106146:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106149:	50                   	push   %eax
8010614a:	6a 02                	push   $0x2
8010614c:	e8 81 fd ff ff       	call   80105ed2 <argint>
80106151:	83 c4 10             	add    $0x10,%esp
80106154:	85 c0                	test   %eax,%eax
80106156:	78 19                	js     80106171 <sys_read+0x4b>
80106158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615b:	83 ec 04             	sub    $0x4,%esp
8010615e:	50                   	push   %eax
8010615f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106162:	50                   	push   %eax
80106163:	6a 01                	push   $0x1
80106165:	e8 90 fd ff ff       	call   80105efa <argptr>
8010616a:	83 c4 10             	add    $0x10,%esp
8010616d:	85 c0                	test   %eax,%eax
8010616f:	79 07                	jns    80106178 <sys_read+0x52>
    return -1;
80106171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106176:	eb 17                	jmp    8010618f <sys_read+0x69>
  return fileread(f, p, n);
80106178:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010617b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010617e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106181:	83 ec 04             	sub    $0x4,%esp
80106184:	51                   	push   %ecx
80106185:	52                   	push   %edx
80106186:	50                   	push   %eax
80106187:	e8 f1 af ff ff       	call   8010117d <fileread>
8010618c:	83 c4 10             	add    $0x10,%esp
}
8010618f:	c9                   	leave  
80106190:	c3                   	ret    

80106191 <sys_write>:

int
sys_write(void)
{
80106191:	55                   	push   %ebp
80106192:	89 e5                	mov    %esp,%ebp
80106194:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106197:	83 ec 04             	sub    $0x4,%esp
8010619a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010619d:	50                   	push   %eax
8010619e:	6a 00                	push   $0x0
801061a0:	6a 00                	push   $0x0
801061a2:	e8 67 fe ff ff       	call   8010600e <argfd>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	85 c0                	test   %eax,%eax
801061ac:	78 2e                	js     801061dc <sys_write+0x4b>
801061ae:	83 ec 08             	sub    $0x8,%esp
801061b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061b4:	50                   	push   %eax
801061b5:	6a 02                	push   $0x2
801061b7:	e8 16 fd ff ff       	call   80105ed2 <argint>
801061bc:	83 c4 10             	add    $0x10,%esp
801061bf:	85 c0                	test   %eax,%eax
801061c1:	78 19                	js     801061dc <sys_write+0x4b>
801061c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c6:	83 ec 04             	sub    $0x4,%esp
801061c9:	50                   	push   %eax
801061ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061cd:	50                   	push   %eax
801061ce:	6a 01                	push   $0x1
801061d0:	e8 25 fd ff ff       	call   80105efa <argptr>
801061d5:	83 c4 10             	add    $0x10,%esp
801061d8:	85 c0                	test   %eax,%eax
801061da:	79 07                	jns    801061e3 <sys_write+0x52>
    return -1;
801061dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e1:	eb 17                	jmp    801061fa <sys_write+0x69>
  return filewrite(f, p, n);
801061e3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801061e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801061e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ec:	83 ec 04             	sub    $0x4,%esp
801061ef:	51                   	push   %ecx
801061f0:	52                   	push   %edx
801061f1:	50                   	push   %eax
801061f2:	e8 3e b0 ff ff       	call   80101235 <filewrite>
801061f7:	83 c4 10             	add    $0x10,%esp
}
801061fa:	c9                   	leave  
801061fb:	c3                   	ret    

801061fc <sys_close>:

int
sys_close(void)
{
801061fc:	55                   	push   %ebp
801061fd:	89 e5                	mov    %esp,%ebp
801061ff:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106202:	83 ec 04             	sub    $0x4,%esp
80106205:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106208:	50                   	push   %eax
80106209:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010620c:	50                   	push   %eax
8010620d:	6a 00                	push   $0x0
8010620f:	e8 fa fd ff ff       	call   8010600e <argfd>
80106214:	83 c4 10             	add    $0x10,%esp
80106217:	85 c0                	test   %eax,%eax
80106219:	79 07                	jns    80106222 <sys_close+0x26>
    return -1;
8010621b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106220:	eb 28                	jmp    8010624a <sys_close+0x4e>
  proc->ofile[fd] = 0;
80106222:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106228:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010622b:	83 c2 08             	add    $0x8,%edx
8010622e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106235:	00 
  fileclose(f);
80106236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106239:	83 ec 0c             	sub    $0xc,%esp
8010623c:	50                   	push   %eax
8010623d:	e8 fc ad ff ff       	call   8010103e <fileclose>
80106242:	83 c4 10             	add    $0x10,%esp
  return 0;
80106245:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010624a:	c9                   	leave  
8010624b:	c3                   	ret    

8010624c <sys_fstat>:

int
sys_fstat(void)
{
8010624c:	55                   	push   %ebp
8010624d:	89 e5                	mov    %esp,%ebp
8010624f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106252:	83 ec 04             	sub    $0x4,%esp
80106255:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106258:	50                   	push   %eax
80106259:	6a 00                	push   $0x0
8010625b:	6a 00                	push   $0x0
8010625d:	e8 ac fd ff ff       	call   8010600e <argfd>
80106262:	83 c4 10             	add    $0x10,%esp
80106265:	85 c0                	test   %eax,%eax
80106267:	78 17                	js     80106280 <sys_fstat+0x34>
80106269:	83 ec 04             	sub    $0x4,%esp
8010626c:	6a 14                	push   $0x14
8010626e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106271:	50                   	push   %eax
80106272:	6a 01                	push   $0x1
80106274:	e8 81 fc ff ff       	call   80105efa <argptr>
80106279:	83 c4 10             	add    $0x10,%esp
8010627c:	85 c0                	test   %eax,%eax
8010627e:	79 07                	jns    80106287 <sys_fstat+0x3b>
    return -1;
80106280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106285:	eb 13                	jmp    8010629a <sys_fstat+0x4e>
  return filestat(f, st);
80106287:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010628a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010628d:	83 ec 08             	sub    $0x8,%esp
80106290:	52                   	push   %edx
80106291:	50                   	push   %eax
80106292:	e8 8f ae ff ff       	call   80101126 <filestat>
80106297:	83 c4 10             	add    $0x10,%esp
}
8010629a:	c9                   	leave  
8010629b:	c3                   	ret    

8010629c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010629c:	55                   	push   %ebp
8010629d:	89 e5                	mov    %esp,%ebp
8010629f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801062a2:	83 ec 08             	sub    $0x8,%esp
801062a5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801062a8:	50                   	push   %eax
801062a9:	6a 00                	push   $0x0
801062ab:	e8 a7 fc ff ff       	call   80105f57 <argstr>
801062b0:	83 c4 10             	add    $0x10,%esp
801062b3:	85 c0                	test   %eax,%eax
801062b5:	78 15                	js     801062cc <sys_link+0x30>
801062b7:	83 ec 08             	sub    $0x8,%esp
801062ba:	8d 45 dc             	lea    -0x24(%ebp),%eax
801062bd:	50                   	push   %eax
801062be:	6a 01                	push   $0x1
801062c0:	e8 92 fc ff ff       	call   80105f57 <argstr>
801062c5:	83 c4 10             	add    $0x10,%esp
801062c8:	85 c0                	test   %eax,%eax
801062ca:	79 0a                	jns    801062d6 <sys_link+0x3a>
    return -1;
801062cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d1:	e9 68 01 00 00       	jmp    8010643e <sys_link+0x1a2>

  begin_op();
801062d6:	e8 18 d2 ff ff       	call   801034f3 <begin_op>
  if((ip = namei(old)) == 0){
801062db:	8b 45 d8             	mov    -0x28(%ebp),%eax
801062de:	83 ec 0c             	sub    $0xc,%esp
801062e1:	50                   	push   %eax
801062e2:	e8 1b c2 ff ff       	call   80102502 <namei>
801062e7:	83 c4 10             	add    $0x10,%esp
801062ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f1:	75 0f                	jne    80106302 <sys_link+0x66>
    end_op();
801062f3:	e8 87 d2 ff ff       	call   8010357f <end_op>
    return -1;
801062f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fd:	e9 3c 01 00 00       	jmp    8010643e <sys_link+0x1a2>
  }

  ilock(ip);
80106302:	83 ec 0c             	sub    $0xc,%esp
80106305:	ff 75 f4             	pushl  -0xc(%ebp)
80106308:	e8 3d b6 ff ff       	call   8010194a <ilock>
8010630d:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80106310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106313:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106317:	66 83 f8 01          	cmp    $0x1,%ax
8010631b:	75 1d                	jne    8010633a <sys_link+0x9e>
    iunlockput(ip);
8010631d:	83 ec 0c             	sub    $0xc,%esp
80106320:	ff 75 f4             	pushl  -0xc(%ebp)
80106323:	e8 dc b8 ff ff       	call   80101c04 <iunlockput>
80106328:	83 c4 10             	add    $0x10,%esp
    end_op();
8010632b:	e8 4f d2 ff ff       	call   8010357f <end_op>
    return -1;
80106330:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106335:	e9 04 01 00 00       	jmp    8010643e <sys_link+0x1a2>
  }

  ip->nlink++;
8010633a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106341:	83 c0 01             	add    $0x1,%eax
80106344:	89 c2                	mov    %eax,%edx
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010634d:	83 ec 0c             	sub    $0xc,%esp
80106350:	ff 75 f4             	pushl  -0xc(%ebp)
80106353:	e8 1e b4 ff ff       	call   80101776 <iupdate>
80106358:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010635b:	83 ec 0c             	sub    $0xc,%esp
8010635e:	ff 75 f4             	pushl  -0xc(%ebp)
80106361:	e8 3c b7 ff ff       	call   80101aa2 <iunlock>
80106366:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106369:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010636c:	83 ec 08             	sub    $0x8,%esp
8010636f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106372:	52                   	push   %edx
80106373:	50                   	push   %eax
80106374:	e8 a5 c1 ff ff       	call   8010251e <nameiparent>
80106379:	83 c4 10             	add    $0x10,%esp
8010637c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010637f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106383:	74 71                	je     801063f6 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80106385:	83 ec 0c             	sub    $0xc,%esp
80106388:	ff 75 f0             	pushl  -0x10(%ebp)
8010638b:	e8 ba b5 ff ff       	call   8010194a <ilock>
80106390:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106396:	8b 10                	mov    (%eax),%edx
80106398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639b:	8b 00                	mov    (%eax),%eax
8010639d:	39 c2                	cmp    %eax,%edx
8010639f:	75 1d                	jne    801063be <sys_link+0x122>
801063a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a4:	8b 40 04             	mov    0x4(%eax),%eax
801063a7:	83 ec 04             	sub    $0x4,%esp
801063aa:	50                   	push   %eax
801063ab:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801063ae:	50                   	push   %eax
801063af:	ff 75 f0             	pushl  -0x10(%ebp)
801063b2:	e8 af be ff ff       	call   80102266 <dirlink>
801063b7:	83 c4 10             	add    $0x10,%esp
801063ba:	85 c0                	test   %eax,%eax
801063bc:	79 10                	jns    801063ce <sys_link+0x132>
    iunlockput(dp);
801063be:	83 ec 0c             	sub    $0xc,%esp
801063c1:	ff 75 f0             	pushl  -0x10(%ebp)
801063c4:	e8 3b b8 ff ff       	call   80101c04 <iunlockput>
801063c9:	83 c4 10             	add    $0x10,%esp
    goto bad;
801063cc:	eb 29                	jmp    801063f7 <sys_link+0x15b>
  }
  iunlockput(dp);
801063ce:	83 ec 0c             	sub    $0xc,%esp
801063d1:	ff 75 f0             	pushl  -0x10(%ebp)
801063d4:	e8 2b b8 ff ff       	call   80101c04 <iunlockput>
801063d9:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801063dc:	83 ec 0c             	sub    $0xc,%esp
801063df:	ff 75 f4             	pushl  -0xc(%ebp)
801063e2:	e8 2d b7 ff ff       	call   80101b14 <iput>
801063e7:	83 c4 10             	add    $0x10,%esp

  end_op();
801063ea:	e8 90 d1 ff ff       	call   8010357f <end_op>

  return 0;
801063ef:	b8 00 00 00 00       	mov    $0x0,%eax
801063f4:	eb 48                	jmp    8010643e <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801063f6:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	ff 75 f4             	pushl  -0xc(%ebp)
801063fd:	e8 48 b5 ff ff       	call   8010194a <ilock>
80106402:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106408:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010640c:	83 e8 01             	sub    $0x1,%eax
8010640f:	89 c2                	mov    %eax,%edx
80106411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106414:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106418:	83 ec 0c             	sub    $0xc,%esp
8010641b:	ff 75 f4             	pushl  -0xc(%ebp)
8010641e:	e8 53 b3 ff ff       	call   80101776 <iupdate>
80106423:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106426:	83 ec 0c             	sub    $0xc,%esp
80106429:	ff 75 f4             	pushl  -0xc(%ebp)
8010642c:	e8 d3 b7 ff ff       	call   80101c04 <iunlockput>
80106431:	83 c4 10             	add    $0x10,%esp
  end_op();
80106434:	e8 46 d1 ff ff       	call   8010357f <end_op>
  return -1;
80106439:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010643e:	c9                   	leave  
8010643f:	c3                   	ret    

80106440 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106440:	55                   	push   %ebp
80106441:	89 e5                	mov    %esp,%ebp
80106443:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106446:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010644d:	eb 40                	jmp    8010648f <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010644f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106452:	6a 10                	push   $0x10
80106454:	50                   	push   %eax
80106455:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106458:	50                   	push   %eax
80106459:	ff 75 08             	pushl  0x8(%ebp)
8010645c:	e8 51 ba ff ff       	call   80101eb2 <readi>
80106461:	83 c4 10             	add    $0x10,%esp
80106464:	83 f8 10             	cmp    $0x10,%eax
80106467:	74 0d                	je     80106476 <isdirempty+0x36>
      panic("isdirempty: readi");
80106469:	83 ec 0c             	sub    $0xc,%esp
8010646c:	68 84 96 10 80       	push   $0x80109684
80106471:	e8 f0 a0 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106476:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010647a:	66 85 c0             	test   %ax,%ax
8010647d:	74 07                	je     80106486 <isdirempty+0x46>
      return 0;
8010647f:	b8 00 00 00 00       	mov    $0x0,%eax
80106484:	eb 1b                	jmp    801064a1 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106489:	83 c0 10             	add    $0x10,%eax
8010648c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010648f:	8b 45 08             	mov    0x8(%ebp),%eax
80106492:	8b 50 18             	mov    0x18(%eax),%edx
80106495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106498:	39 c2                	cmp    %eax,%edx
8010649a:	77 b3                	ja     8010644f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010649c:	b8 01 00 00 00       	mov    $0x1,%eax
}
801064a1:	c9                   	leave  
801064a2:	c3                   	ret    

801064a3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801064a3:	55                   	push   %ebp
801064a4:	89 e5                	mov    %esp,%ebp
801064a6:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801064a9:	83 ec 08             	sub    $0x8,%esp
801064ac:	8d 45 cc             	lea    -0x34(%ebp),%eax
801064af:	50                   	push   %eax
801064b0:	6a 00                	push   $0x0
801064b2:	e8 a0 fa ff ff       	call   80105f57 <argstr>
801064b7:	83 c4 10             	add    $0x10,%esp
801064ba:	85 c0                	test   %eax,%eax
801064bc:	79 0a                	jns    801064c8 <sys_unlink+0x25>
    return -1;
801064be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c3:	e9 bc 01 00 00       	jmp    80106684 <sys_unlink+0x1e1>

  begin_op();
801064c8:	e8 26 d0 ff ff       	call   801034f3 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801064cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
801064d0:	83 ec 08             	sub    $0x8,%esp
801064d3:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801064d6:	52                   	push   %edx
801064d7:	50                   	push   %eax
801064d8:	e8 41 c0 ff ff       	call   8010251e <nameiparent>
801064dd:	83 c4 10             	add    $0x10,%esp
801064e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e7:	75 0f                	jne    801064f8 <sys_unlink+0x55>
    end_op();
801064e9:	e8 91 d0 ff ff       	call   8010357f <end_op>
    return -1;
801064ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f3:	e9 8c 01 00 00       	jmp    80106684 <sys_unlink+0x1e1>
  }

  ilock(dp);
801064f8:	83 ec 0c             	sub    $0xc,%esp
801064fb:	ff 75 f4             	pushl  -0xc(%ebp)
801064fe:	e8 47 b4 ff ff       	call   8010194a <ilock>
80106503:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106506:	83 ec 08             	sub    $0x8,%esp
80106509:	68 96 96 10 80       	push   $0x80109696
8010650e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106511:	50                   	push   %eax
80106512:	e8 7a bc ff ff       	call   80102191 <namecmp>
80106517:	83 c4 10             	add    $0x10,%esp
8010651a:	85 c0                	test   %eax,%eax
8010651c:	0f 84 4a 01 00 00    	je     8010666c <sys_unlink+0x1c9>
80106522:	83 ec 08             	sub    $0x8,%esp
80106525:	68 98 96 10 80       	push   $0x80109698
8010652a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010652d:	50                   	push   %eax
8010652e:	e8 5e bc ff ff       	call   80102191 <namecmp>
80106533:	83 c4 10             	add    $0x10,%esp
80106536:	85 c0                	test   %eax,%eax
80106538:	0f 84 2e 01 00 00    	je     8010666c <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010653e:	83 ec 04             	sub    $0x4,%esp
80106541:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106544:	50                   	push   %eax
80106545:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106548:	50                   	push   %eax
80106549:	ff 75 f4             	pushl  -0xc(%ebp)
8010654c:	e8 5b bc ff ff       	call   801021ac <dirlookup>
80106551:	83 c4 10             	add    $0x10,%esp
80106554:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106557:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010655b:	0f 84 0a 01 00 00    	je     8010666b <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106561:	83 ec 0c             	sub    $0xc,%esp
80106564:	ff 75 f0             	pushl  -0x10(%ebp)
80106567:	e8 de b3 ff ff       	call   8010194a <ilock>
8010656c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010656f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106572:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106576:	66 85 c0             	test   %ax,%ax
80106579:	7f 0d                	jg     80106588 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010657b:	83 ec 0c             	sub    $0xc,%esp
8010657e:	68 9b 96 10 80       	push   $0x8010969b
80106583:	e8 de 9f ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010658f:	66 83 f8 01          	cmp    $0x1,%ax
80106593:	75 25                	jne    801065ba <sys_unlink+0x117>
80106595:	83 ec 0c             	sub    $0xc,%esp
80106598:	ff 75 f0             	pushl  -0x10(%ebp)
8010659b:	e8 a0 fe ff ff       	call   80106440 <isdirempty>
801065a0:	83 c4 10             	add    $0x10,%esp
801065a3:	85 c0                	test   %eax,%eax
801065a5:	75 13                	jne    801065ba <sys_unlink+0x117>
    iunlockput(ip);
801065a7:	83 ec 0c             	sub    $0xc,%esp
801065aa:	ff 75 f0             	pushl  -0x10(%ebp)
801065ad:	e8 52 b6 ff ff       	call   80101c04 <iunlockput>
801065b2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801065b5:	e9 b2 00 00 00       	jmp    8010666c <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801065ba:	83 ec 04             	sub    $0x4,%esp
801065bd:	6a 10                	push   $0x10
801065bf:	6a 00                	push   $0x0
801065c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065c4:	50                   	push   %eax
801065c5:	e8 e3 f5 ff ff       	call   80105bad <memset>
801065ca:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065cd:	8b 45 c8             	mov    -0x38(%ebp),%eax
801065d0:	6a 10                	push   $0x10
801065d2:	50                   	push   %eax
801065d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065d6:	50                   	push   %eax
801065d7:	ff 75 f4             	pushl  -0xc(%ebp)
801065da:	e8 2a ba ff ff       	call   80102009 <writei>
801065df:	83 c4 10             	add    $0x10,%esp
801065e2:	83 f8 10             	cmp    $0x10,%eax
801065e5:	74 0d                	je     801065f4 <sys_unlink+0x151>
    panic("unlink: writei");
801065e7:	83 ec 0c             	sub    $0xc,%esp
801065ea:	68 ad 96 10 80       	push   $0x801096ad
801065ef:	e8 72 9f ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801065f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065fb:	66 83 f8 01          	cmp    $0x1,%ax
801065ff:	75 21                	jne    80106622 <sys_unlink+0x17f>
    dp->nlink--;
80106601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106604:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106608:	83 e8 01             	sub    $0x1,%eax
8010660b:	89 c2                	mov    %eax,%edx
8010660d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106610:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106614:	83 ec 0c             	sub    $0xc,%esp
80106617:	ff 75 f4             	pushl  -0xc(%ebp)
8010661a:	e8 57 b1 ff ff       	call   80101776 <iupdate>
8010661f:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106622:	83 ec 0c             	sub    $0xc,%esp
80106625:	ff 75 f4             	pushl  -0xc(%ebp)
80106628:	e8 d7 b5 ff ff       	call   80101c04 <iunlockput>
8010662d:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106633:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106637:	83 e8 01             	sub    $0x1,%eax
8010663a:	89 c2                	mov    %eax,%edx
8010663c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106643:	83 ec 0c             	sub    $0xc,%esp
80106646:	ff 75 f0             	pushl  -0x10(%ebp)
80106649:	e8 28 b1 ff ff       	call   80101776 <iupdate>
8010664e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106651:	83 ec 0c             	sub    $0xc,%esp
80106654:	ff 75 f0             	pushl  -0x10(%ebp)
80106657:	e8 a8 b5 ff ff       	call   80101c04 <iunlockput>
8010665c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010665f:	e8 1b cf ff ff       	call   8010357f <end_op>

  return 0;
80106664:	b8 00 00 00 00       	mov    $0x0,%eax
80106669:	eb 19                	jmp    80106684 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010666b:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010666c:	83 ec 0c             	sub    $0xc,%esp
8010666f:	ff 75 f4             	pushl  -0xc(%ebp)
80106672:	e8 8d b5 ff ff       	call   80101c04 <iunlockput>
80106677:	83 c4 10             	add    $0x10,%esp
  end_op();
8010667a:	e8 00 cf ff ff       	call   8010357f <end_op>
  return -1;
8010667f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106684:	c9                   	leave  
80106685:	c3                   	ret    

80106686 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106686:	55                   	push   %ebp
80106687:	89 e5                	mov    %esp,%ebp
80106689:	83 ec 38             	sub    $0x38,%esp
8010668c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010668f:	8b 55 10             	mov    0x10(%ebp),%edx
80106692:	8b 45 14             	mov    0x14(%ebp),%eax
80106695:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106699:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010669d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801066a1:	83 ec 08             	sub    $0x8,%esp
801066a4:	8d 45 de             	lea    -0x22(%ebp),%eax
801066a7:	50                   	push   %eax
801066a8:	ff 75 08             	pushl  0x8(%ebp)
801066ab:	e8 6e be ff ff       	call   8010251e <nameiparent>
801066b0:	83 c4 10             	add    $0x10,%esp
801066b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ba:	75 0a                	jne    801066c6 <create+0x40>
    return 0;
801066bc:	b8 00 00 00 00       	mov    $0x0,%eax
801066c1:	e9 90 01 00 00       	jmp    80106856 <create+0x1d0>
  ilock(dp);
801066c6:	83 ec 0c             	sub    $0xc,%esp
801066c9:	ff 75 f4             	pushl  -0xc(%ebp)
801066cc:	e8 79 b2 ff ff       	call   8010194a <ilock>
801066d1:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801066d4:	83 ec 04             	sub    $0x4,%esp
801066d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066da:	50                   	push   %eax
801066db:	8d 45 de             	lea    -0x22(%ebp),%eax
801066de:	50                   	push   %eax
801066df:	ff 75 f4             	pushl  -0xc(%ebp)
801066e2:	e8 c5 ba ff ff       	call   801021ac <dirlookup>
801066e7:	83 c4 10             	add    $0x10,%esp
801066ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066f1:	74 50                	je     80106743 <create+0xbd>
    iunlockput(dp);
801066f3:	83 ec 0c             	sub    $0xc,%esp
801066f6:	ff 75 f4             	pushl  -0xc(%ebp)
801066f9:	e8 06 b5 ff ff       	call   80101c04 <iunlockput>
801066fe:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106701:	83 ec 0c             	sub    $0xc,%esp
80106704:	ff 75 f0             	pushl  -0x10(%ebp)
80106707:	e8 3e b2 ff ff       	call   8010194a <ilock>
8010670c:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010670f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106714:	75 15                	jne    8010672b <create+0xa5>
80106716:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106719:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010671d:	66 83 f8 02          	cmp    $0x2,%ax
80106721:	75 08                	jne    8010672b <create+0xa5>
      return ip;
80106723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106726:	e9 2b 01 00 00       	jmp    80106856 <create+0x1d0>
    iunlockput(ip);
8010672b:	83 ec 0c             	sub    $0xc,%esp
8010672e:	ff 75 f0             	pushl  -0x10(%ebp)
80106731:	e8 ce b4 ff ff       	call   80101c04 <iunlockput>
80106736:	83 c4 10             	add    $0x10,%esp
    return 0;
80106739:	b8 00 00 00 00       	mov    $0x0,%eax
8010673e:	e9 13 01 00 00       	jmp    80106856 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106743:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674a:	8b 00                	mov    (%eax),%eax
8010674c:	83 ec 08             	sub    $0x8,%esp
8010674f:	52                   	push   %edx
80106750:	50                   	push   %eax
80106751:	e8 3f af ff ff       	call   80101695 <ialloc>
80106756:	83 c4 10             	add    $0x10,%esp
80106759:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010675c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106760:	75 0d                	jne    8010676f <create+0xe9>
    panic("create: ialloc");
80106762:	83 ec 0c             	sub    $0xc,%esp
80106765:	68 bc 96 10 80       	push   $0x801096bc
8010676a:	e8 f7 9d ff ff       	call   80100566 <panic>

  ilock(ip);
8010676f:	83 ec 0c             	sub    $0xc,%esp
80106772:	ff 75 f0             	pushl  -0x10(%ebp)
80106775:	e8 d0 b1 ff ff       	call   8010194a <ilock>
8010677a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010677d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106780:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106784:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106788:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010678b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010678f:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106796:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010679c:	83 ec 0c             	sub    $0xc,%esp
8010679f:	ff 75 f0             	pushl  -0x10(%ebp)
801067a2:	e8 cf af ff ff       	call   80101776 <iupdate>
801067a7:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801067aa:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801067af:	75 6a                	jne    8010681b <create+0x195>
    dp->nlink++;  // for ".."
801067b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801067b8:	83 c0 01             	add    $0x1,%eax
801067bb:	89 c2                	mov    %eax,%edx
801067bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c0:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801067c4:	83 ec 0c             	sub    $0xc,%esp
801067c7:	ff 75 f4             	pushl  -0xc(%ebp)
801067ca:	e8 a7 af ff ff       	call   80101776 <iupdate>
801067cf:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801067d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d5:	8b 40 04             	mov    0x4(%eax),%eax
801067d8:	83 ec 04             	sub    $0x4,%esp
801067db:	50                   	push   %eax
801067dc:	68 96 96 10 80       	push   $0x80109696
801067e1:	ff 75 f0             	pushl  -0x10(%ebp)
801067e4:	e8 7d ba ff ff       	call   80102266 <dirlink>
801067e9:	83 c4 10             	add    $0x10,%esp
801067ec:	85 c0                	test   %eax,%eax
801067ee:	78 1e                	js     8010680e <create+0x188>
801067f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f3:	8b 40 04             	mov    0x4(%eax),%eax
801067f6:	83 ec 04             	sub    $0x4,%esp
801067f9:	50                   	push   %eax
801067fa:	68 98 96 10 80       	push   $0x80109698
801067ff:	ff 75 f0             	pushl  -0x10(%ebp)
80106802:	e8 5f ba ff ff       	call   80102266 <dirlink>
80106807:	83 c4 10             	add    $0x10,%esp
8010680a:	85 c0                	test   %eax,%eax
8010680c:	79 0d                	jns    8010681b <create+0x195>
      panic("create dots");
8010680e:	83 ec 0c             	sub    $0xc,%esp
80106811:	68 cb 96 10 80       	push   $0x801096cb
80106816:	e8 4b 9d ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010681b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010681e:	8b 40 04             	mov    0x4(%eax),%eax
80106821:	83 ec 04             	sub    $0x4,%esp
80106824:	50                   	push   %eax
80106825:	8d 45 de             	lea    -0x22(%ebp),%eax
80106828:	50                   	push   %eax
80106829:	ff 75 f4             	pushl  -0xc(%ebp)
8010682c:	e8 35 ba ff ff       	call   80102266 <dirlink>
80106831:	83 c4 10             	add    $0x10,%esp
80106834:	85 c0                	test   %eax,%eax
80106836:	79 0d                	jns    80106845 <create+0x1bf>
    panic("create: dirlink");
80106838:	83 ec 0c             	sub    $0xc,%esp
8010683b:	68 d7 96 10 80       	push   $0x801096d7
80106840:	e8 21 9d ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106845:	83 ec 0c             	sub    $0xc,%esp
80106848:	ff 75 f4             	pushl  -0xc(%ebp)
8010684b:	e8 b4 b3 ff ff       	call   80101c04 <iunlockput>
80106850:	83 c4 10             	add    $0x10,%esp

  return ip;
80106853:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106856:	c9                   	leave  
80106857:	c3                   	ret    

80106858 <sys_open>:

int
sys_open(void)
{
80106858:	55                   	push   %ebp
80106859:	89 e5                	mov    %esp,%ebp
8010685b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010685e:	83 ec 08             	sub    $0x8,%esp
80106861:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106864:	50                   	push   %eax
80106865:	6a 00                	push   $0x0
80106867:	e8 eb f6 ff ff       	call   80105f57 <argstr>
8010686c:	83 c4 10             	add    $0x10,%esp
8010686f:	85 c0                	test   %eax,%eax
80106871:	78 15                	js     80106888 <sys_open+0x30>
80106873:	83 ec 08             	sub    $0x8,%esp
80106876:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106879:	50                   	push   %eax
8010687a:	6a 01                	push   $0x1
8010687c:	e8 51 f6 ff ff       	call   80105ed2 <argint>
80106881:	83 c4 10             	add    $0x10,%esp
80106884:	85 c0                	test   %eax,%eax
80106886:	79 0a                	jns    80106892 <sys_open+0x3a>
    return -1;
80106888:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010688d:	e9 61 01 00 00       	jmp    801069f3 <sys_open+0x19b>

  begin_op();
80106892:	e8 5c cc ff ff       	call   801034f3 <begin_op>

  if(omode & O_CREATE){
80106897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010689a:	25 00 02 00 00       	and    $0x200,%eax
8010689f:	85 c0                	test   %eax,%eax
801068a1:	74 2a                	je     801068cd <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801068a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068a6:	6a 00                	push   $0x0
801068a8:	6a 00                	push   $0x0
801068aa:	6a 02                	push   $0x2
801068ac:	50                   	push   %eax
801068ad:	e8 d4 fd ff ff       	call   80106686 <create>
801068b2:	83 c4 10             	add    $0x10,%esp
801068b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801068b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068bc:	75 75                	jne    80106933 <sys_open+0xdb>
      end_op();
801068be:	e8 bc cc ff ff       	call   8010357f <end_op>
      return -1;
801068c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c8:	e9 26 01 00 00       	jmp    801069f3 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801068cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068d0:	83 ec 0c             	sub    $0xc,%esp
801068d3:	50                   	push   %eax
801068d4:	e8 29 bc ff ff       	call   80102502 <namei>
801068d9:	83 c4 10             	add    $0x10,%esp
801068dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068e3:	75 0f                	jne    801068f4 <sys_open+0x9c>
      end_op();
801068e5:	e8 95 cc ff ff       	call   8010357f <end_op>
      return -1;
801068ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ef:	e9 ff 00 00 00       	jmp    801069f3 <sys_open+0x19b>
    }
    ilock(ip);
801068f4:	83 ec 0c             	sub    $0xc,%esp
801068f7:	ff 75 f4             	pushl  -0xc(%ebp)
801068fa:	e8 4b b0 ff ff       	call   8010194a <ilock>
801068ff:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106905:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106909:	66 83 f8 01          	cmp    $0x1,%ax
8010690d:	75 24                	jne    80106933 <sys_open+0xdb>
8010690f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106912:	85 c0                	test   %eax,%eax
80106914:	74 1d                	je     80106933 <sys_open+0xdb>
      iunlockput(ip);
80106916:	83 ec 0c             	sub    $0xc,%esp
80106919:	ff 75 f4             	pushl  -0xc(%ebp)
8010691c:	e8 e3 b2 ff ff       	call   80101c04 <iunlockput>
80106921:	83 c4 10             	add    $0x10,%esp
      end_op();
80106924:	e8 56 cc ff ff       	call   8010357f <end_op>
      return -1;
80106929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010692e:	e9 c0 00 00 00       	jmp    801069f3 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106933:	e8 48 a6 ff ff       	call   80100f80 <filealloc>
80106938:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010693b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010693f:	74 17                	je     80106958 <sys_open+0x100>
80106941:	83 ec 0c             	sub    $0xc,%esp
80106944:	ff 75 f0             	pushl  -0x10(%ebp)
80106947:	e8 37 f7 ff ff       	call   80106083 <fdalloc>
8010694c:	83 c4 10             	add    $0x10,%esp
8010694f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106952:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106956:	79 2e                	jns    80106986 <sys_open+0x12e>
    if(f)
80106958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010695c:	74 0e                	je     8010696c <sys_open+0x114>
      fileclose(f);
8010695e:	83 ec 0c             	sub    $0xc,%esp
80106961:	ff 75 f0             	pushl  -0x10(%ebp)
80106964:	e8 d5 a6 ff ff       	call   8010103e <fileclose>
80106969:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010696c:	83 ec 0c             	sub    $0xc,%esp
8010696f:	ff 75 f4             	pushl  -0xc(%ebp)
80106972:	e8 8d b2 ff ff       	call   80101c04 <iunlockput>
80106977:	83 c4 10             	add    $0x10,%esp
    end_op();
8010697a:	e8 00 cc ff ff       	call   8010357f <end_op>
    return -1;
8010697f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106984:	eb 6d                	jmp    801069f3 <sys_open+0x19b>
  }
  iunlock(ip);
80106986:	83 ec 0c             	sub    $0xc,%esp
80106989:	ff 75 f4             	pushl  -0xc(%ebp)
8010698c:	e8 11 b1 ff ff       	call   80101aa2 <iunlock>
80106991:	83 c4 10             	add    $0x10,%esp
  end_op();
80106994:	e8 e6 cb ff ff       	call   8010357f <end_op>

  f->type = FD_INODE;
80106999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010699c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801069a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069a8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801069ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ae:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801069b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069b8:	83 e0 01             	and    $0x1,%eax
801069bb:	85 c0                	test   %eax,%eax
801069bd:	0f 94 c0             	sete   %al
801069c0:	89 c2                	mov    %eax,%edx
801069c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801069c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069cb:	83 e0 01             	and    $0x1,%eax
801069ce:	85 c0                	test   %eax,%eax
801069d0:	75 0a                	jne    801069dc <sys_open+0x184>
801069d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069d5:	83 e0 02             	and    $0x2,%eax
801069d8:	85 c0                	test   %eax,%eax
801069da:	74 07                	je     801069e3 <sys_open+0x18b>
801069dc:	b8 01 00 00 00       	mov    $0x1,%eax
801069e1:	eb 05                	jmp    801069e8 <sys_open+0x190>
801069e3:	b8 00 00 00 00       	mov    $0x0,%eax
801069e8:	89 c2                	mov    %eax,%edx
801069ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ed:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801069f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801069f3:	c9                   	leave  
801069f4:	c3                   	ret    

801069f5 <sys_mkdir>:

int
sys_mkdir(void)
{
801069f5:	55                   	push   %ebp
801069f6:	89 e5                	mov    %esp,%ebp
801069f8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801069fb:	e8 f3 ca ff ff       	call   801034f3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106a00:	83 ec 08             	sub    $0x8,%esp
80106a03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a06:	50                   	push   %eax
80106a07:	6a 00                	push   $0x0
80106a09:	e8 49 f5 ff ff       	call   80105f57 <argstr>
80106a0e:	83 c4 10             	add    $0x10,%esp
80106a11:	85 c0                	test   %eax,%eax
80106a13:	78 1b                	js     80106a30 <sys_mkdir+0x3b>
80106a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a18:	6a 00                	push   $0x0
80106a1a:	6a 00                	push   $0x0
80106a1c:	6a 01                	push   $0x1
80106a1e:	50                   	push   %eax
80106a1f:	e8 62 fc ff ff       	call   80106686 <create>
80106a24:	83 c4 10             	add    $0x10,%esp
80106a27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a2e:	75 0c                	jne    80106a3c <sys_mkdir+0x47>
    end_op();
80106a30:	e8 4a cb ff ff       	call   8010357f <end_op>
    return -1;
80106a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a3a:	eb 18                	jmp    80106a54 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106a3c:	83 ec 0c             	sub    $0xc,%esp
80106a3f:	ff 75 f4             	pushl  -0xc(%ebp)
80106a42:	e8 bd b1 ff ff       	call   80101c04 <iunlockput>
80106a47:	83 c4 10             	add    $0x10,%esp
  end_op();
80106a4a:	e8 30 cb ff ff       	call   8010357f <end_op>
  return 0;
80106a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a54:	c9                   	leave  
80106a55:	c3                   	ret    

80106a56 <sys_mknod>:

int
sys_mknod(void)
{
80106a56:	55                   	push   %ebp
80106a57:	89 e5                	mov    %esp,%ebp
80106a59:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;

  begin_op();
80106a5c:	e8 92 ca ff ff       	call   801034f3 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106a61:	83 ec 08             	sub    $0x8,%esp
80106a64:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a67:	50                   	push   %eax
80106a68:	6a 00                	push   $0x0
80106a6a:	e8 e8 f4 ff ff       	call   80105f57 <argstr>
80106a6f:	83 c4 10             	add    $0x10,%esp
80106a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a79:	78 4f                	js     80106aca <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106a7b:	83 ec 08             	sub    $0x8,%esp
80106a7e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a81:	50                   	push   %eax
80106a82:	6a 01                	push   $0x1
80106a84:	e8 49 f4 ff ff       	call   80105ed2 <argint>
80106a89:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106a8c:	85 c0                	test   %eax,%eax
80106a8e:	78 3a                	js     80106aca <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106a90:	83 ec 08             	sub    $0x8,%esp
80106a93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a96:	50                   	push   %eax
80106a97:	6a 02                	push   $0x2
80106a99:	e8 34 f4 ff ff       	call   80105ed2 <argint>
80106a9e:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106aa1:	85 c0                	test   %eax,%eax
80106aa3:	78 25                	js     80106aca <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106aa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aa8:	0f bf c8             	movswl %ax,%ecx
80106aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106aae:	0f bf d0             	movswl %ax,%edx
80106ab1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106ab4:	51                   	push   %ecx
80106ab5:	52                   	push   %edx
80106ab6:	6a 03                	push   $0x3
80106ab8:	50                   	push   %eax
80106ab9:	e8 c8 fb ff ff       	call   80106686 <create>
80106abe:	83 c4 10             	add    $0x10,%esp
80106ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ac8:	75 0c                	jne    80106ad6 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106aca:	e8 b0 ca ff ff       	call   8010357f <end_op>
    return -1;
80106acf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad4:	eb 18                	jmp    80106aee <sys_mknod+0x98>
  }
  iunlockput(ip);
80106ad6:	83 ec 0c             	sub    $0xc,%esp
80106ad9:	ff 75 f0             	pushl  -0x10(%ebp)
80106adc:	e8 23 b1 ff ff       	call   80101c04 <iunlockput>
80106ae1:	83 c4 10             	add    $0x10,%esp
  end_op();
80106ae4:	e8 96 ca ff ff       	call   8010357f <end_op>
  return 0;
80106ae9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106aee:	c9                   	leave  
80106aef:	c3                   	ret    

80106af0 <sys_chdir>:

int
sys_chdir(void)
{
80106af0:	55                   	push   %ebp
80106af1:	89 e5                	mov    %esp,%ebp
80106af3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106af6:	e8 f8 c9 ff ff       	call   801034f3 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106afb:	83 ec 08             	sub    $0x8,%esp
80106afe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b01:	50                   	push   %eax
80106b02:	6a 00                	push   $0x0
80106b04:	e8 4e f4 ff ff       	call   80105f57 <argstr>
80106b09:	83 c4 10             	add    $0x10,%esp
80106b0c:	85 c0                	test   %eax,%eax
80106b0e:	78 18                	js     80106b28 <sys_chdir+0x38>
80106b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b13:	83 ec 0c             	sub    $0xc,%esp
80106b16:	50                   	push   %eax
80106b17:	e8 e6 b9 ff ff       	call   80102502 <namei>
80106b1c:	83 c4 10             	add    $0x10,%esp
80106b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b26:	75 0c                	jne    80106b34 <sys_chdir+0x44>
    end_op();
80106b28:	e8 52 ca ff ff       	call   8010357f <end_op>
    return -1;
80106b2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b32:	eb 6e                	jmp    80106ba2 <sys_chdir+0xb2>
  }
  ilock(ip);
80106b34:	83 ec 0c             	sub    $0xc,%esp
80106b37:	ff 75 f4             	pushl  -0xc(%ebp)
80106b3a:	e8 0b ae ff ff       	call   8010194a <ilock>
80106b3f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b45:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b49:	66 83 f8 01          	cmp    $0x1,%ax
80106b4d:	74 1a                	je     80106b69 <sys_chdir+0x79>
    iunlockput(ip);
80106b4f:	83 ec 0c             	sub    $0xc,%esp
80106b52:	ff 75 f4             	pushl  -0xc(%ebp)
80106b55:	e8 aa b0 ff ff       	call   80101c04 <iunlockput>
80106b5a:	83 c4 10             	add    $0x10,%esp
    end_op();
80106b5d:	e8 1d ca ff ff       	call   8010357f <end_op>
    return -1;
80106b62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b67:	eb 39                	jmp    80106ba2 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106b69:	83 ec 0c             	sub    $0xc,%esp
80106b6c:	ff 75 f4             	pushl  -0xc(%ebp)
80106b6f:	e8 2e af ff ff       	call   80101aa2 <iunlock>
80106b74:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106b77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b7d:	8b 40 68             	mov    0x68(%eax),%eax
80106b80:	83 ec 0c             	sub    $0xc,%esp
80106b83:	50                   	push   %eax
80106b84:	e8 8b af ff ff       	call   80101b14 <iput>
80106b89:	83 c4 10             	add    $0x10,%esp
  end_op();
80106b8c:	e8 ee c9 ff ff       	call   8010357f <end_op>
  proc->cwd = ip;
80106b91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b9a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ba2:	c9                   	leave  
80106ba3:	c3                   	ret    

80106ba4 <sys_exec>:

int
sys_exec(void)
{
80106ba4:	55                   	push   %ebp
80106ba5:	89 e5                	mov    %esp,%ebp
80106ba7:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106bad:	83 ec 08             	sub    $0x8,%esp
80106bb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bb3:	50                   	push   %eax
80106bb4:	6a 00                	push   $0x0
80106bb6:	e8 9c f3 ff ff       	call   80105f57 <argstr>
80106bbb:	83 c4 10             	add    $0x10,%esp
80106bbe:	85 c0                	test   %eax,%eax
80106bc0:	78 18                	js     80106bda <sys_exec+0x36>
80106bc2:	83 ec 08             	sub    $0x8,%esp
80106bc5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106bcb:	50                   	push   %eax
80106bcc:	6a 01                	push   $0x1
80106bce:	e8 ff f2 ff ff       	call   80105ed2 <argint>
80106bd3:	83 c4 10             	add    $0x10,%esp
80106bd6:	85 c0                	test   %eax,%eax
80106bd8:	79 0a                	jns    80106be4 <sys_exec+0x40>
    return -1;
80106bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bdf:	e9 c6 00 00 00       	jmp    80106caa <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106be4:	83 ec 04             	sub    $0x4,%esp
80106be7:	68 80 00 00 00       	push   $0x80
80106bec:	6a 00                	push   $0x0
80106bee:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106bf4:	50                   	push   %eax
80106bf5:	e8 b3 ef ff ff       	call   80105bad <memset>
80106bfa:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106bfd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c07:	83 f8 1f             	cmp    $0x1f,%eax
80106c0a:	76 0a                	jbe    80106c16 <sys_exec+0x72>
      return -1;
80106c0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c11:	e9 94 00 00 00       	jmp    80106caa <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c19:	c1 e0 02             	shl    $0x2,%eax
80106c1c:	89 c2                	mov    %eax,%edx
80106c1e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106c24:	01 c2                	add    %eax,%edx
80106c26:	83 ec 08             	sub    $0x8,%esp
80106c29:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106c2f:	50                   	push   %eax
80106c30:	52                   	push   %edx
80106c31:	e8 00 f2 ff ff       	call   80105e36 <fetchint>
80106c36:	83 c4 10             	add    $0x10,%esp
80106c39:	85 c0                	test   %eax,%eax
80106c3b:	79 07                	jns    80106c44 <sys_exec+0xa0>
      return -1;
80106c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c42:	eb 66                	jmp    80106caa <sys_exec+0x106>
    if(uarg == 0){
80106c44:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c4a:	85 c0                	test   %eax,%eax
80106c4c:	75 27                	jne    80106c75 <sys_exec+0xd1>
      argv[i] = 0;
80106c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c51:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106c58:	00 00 00 00 
      break;
80106c5c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c60:	83 ec 08             	sub    $0x8,%esp
80106c63:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106c69:	52                   	push   %edx
80106c6a:	50                   	push   %eax
80106c6b:	e8 e6 9e ff ff       	call   80100b56 <exec>
80106c70:	83 c4 10             	add    $0x10,%esp
80106c73:	eb 35                	jmp    80106caa <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106c75:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106c7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c7e:	c1 e2 02             	shl    $0x2,%edx
80106c81:	01 c2                	add    %eax,%edx
80106c83:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c89:	83 ec 08             	sub    $0x8,%esp
80106c8c:	52                   	push   %edx
80106c8d:	50                   	push   %eax
80106c8e:	e8 dd f1 ff ff       	call   80105e70 <fetchstr>
80106c93:	83 c4 10             	add    $0x10,%esp
80106c96:	85 c0                	test   %eax,%eax
80106c98:	79 07                	jns    80106ca1 <sys_exec+0xfd>
      return -1;
80106c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9f:	eb 09                	jmp    80106caa <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106ca1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106ca5:	e9 5a ff ff ff       	jmp    80106c04 <sys_exec+0x60>
  return exec(path, argv);
}
80106caa:	c9                   	leave  
80106cab:	c3                   	ret    

80106cac <sys_pipe>:

int
sys_pipe(void)
{
80106cac:	55                   	push   %ebp
80106cad:	89 e5                	mov    %esp,%ebp
80106caf:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106cb2:	83 ec 04             	sub    $0x4,%esp
80106cb5:	6a 08                	push   $0x8
80106cb7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106cba:	50                   	push   %eax
80106cbb:	6a 00                	push   $0x0
80106cbd:	e8 38 f2 ff ff       	call   80105efa <argptr>
80106cc2:	83 c4 10             	add    $0x10,%esp
80106cc5:	85 c0                	test   %eax,%eax
80106cc7:	79 0a                	jns    80106cd3 <sys_pipe+0x27>
    return -1;
80106cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cce:	e9 af 00 00 00       	jmp    80106d82 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106cd3:	83 ec 08             	sub    $0x8,%esp
80106cd6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106cd9:	50                   	push   %eax
80106cda:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106cdd:	50                   	push   %eax
80106cde:	e8 4a d4 ff ff       	call   8010412d <pipealloc>
80106ce3:	83 c4 10             	add    $0x10,%esp
80106ce6:	85 c0                	test   %eax,%eax
80106ce8:	79 0a                	jns    80106cf4 <sys_pipe+0x48>
    return -1;
80106cea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cef:	e9 8e 00 00 00       	jmp    80106d82 <sys_pipe+0xd6>
  fd0 = -1;
80106cf4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106cfe:	83 ec 0c             	sub    $0xc,%esp
80106d01:	50                   	push   %eax
80106d02:	e8 7c f3 ff ff       	call   80106083 <fdalloc>
80106d07:	83 c4 10             	add    $0x10,%esp
80106d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d11:	78 18                	js     80106d2b <sys_pipe+0x7f>
80106d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d16:	83 ec 0c             	sub    $0xc,%esp
80106d19:	50                   	push   %eax
80106d1a:	e8 64 f3 ff ff       	call   80106083 <fdalloc>
80106d1f:	83 c4 10             	add    $0x10,%esp
80106d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d29:	79 3f                	jns    80106d6a <sys_pipe+0xbe>
    if(fd0 >= 0)
80106d2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d2f:	78 14                	js     80106d45 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106d31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d3a:	83 c2 08             	add    $0x8,%edx
80106d3d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106d44:	00 
    fileclose(rf);
80106d45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d48:	83 ec 0c             	sub    $0xc,%esp
80106d4b:	50                   	push   %eax
80106d4c:	e8 ed a2 ff ff       	call   8010103e <fileclose>
80106d51:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d57:	83 ec 0c             	sub    $0xc,%esp
80106d5a:	50                   	push   %eax
80106d5b:	e8 de a2 ff ff       	call   8010103e <fileclose>
80106d60:	83 c4 10             	add    $0x10,%esp
    return -1;
80106d63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d68:	eb 18                	jmp    80106d82 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106d6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d70:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106d72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d75:	8d 50 04             	lea    0x4(%eax),%edx
80106d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d7b:	89 02                	mov    %eax,(%edx)
  return 0;
80106d7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d82:	c9                   	leave  
80106d83:	c3                   	ret    

80106d84 <sys_seek>:


int
sys_seek(void)
{
80106d84:	55                   	push   %ebp
80106d85:	89 e5                	mov    %esp,%ebp
80106d87:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;

  if(argfd(0, 0, &f) < 0 || argint(1, &n) < 0 )
80106d8a:	83 ec 04             	sub    $0x4,%esp
80106d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d90:	50                   	push   %eax
80106d91:	6a 00                	push   $0x0
80106d93:	6a 00                	push   $0x0
80106d95:	e8 74 f2 ff ff       	call   8010600e <argfd>
80106d9a:	83 c4 10             	add    $0x10,%esp
80106d9d:	85 c0                	test   %eax,%eax
80106d9f:	78 15                	js     80106db6 <sys_seek+0x32>
80106da1:	83 ec 08             	sub    $0x8,%esp
80106da4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106da7:	50                   	push   %eax
80106da8:	6a 01                	push   $0x1
80106daa:	e8 23 f1 ff ff       	call   80105ed2 <argint>
80106daf:	83 c4 10             	add    $0x10,%esp
80106db2:	85 c0                	test   %eax,%eax
80106db4:	79 07                	jns    80106dbd <sys_seek+0x39>
    return -1;
80106db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dbb:	eb 15                	jmp    80106dd2 <sys_seek+0x4e>
  return fileseek(f, n);
80106dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc0:	89 c2                	mov    %eax,%edx
80106dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc5:	83 ec 08             	sub    $0x8,%esp
80106dc8:	52                   	push   %edx
80106dc9:	50                   	push   %eax
80106dca:	e8 a2 a5 ff ff       	call   80101371 <fileseek>
80106dcf:	83 c4 10             	add    $0x10,%esp
}
80106dd2:	c9                   	leave  
80106dd3:	c3                   	ret    

80106dd4 <sys_fork>:
#include "mmap.h"
#include "proc.h"

int
sys_fork(void)
{
80106dd4:	55                   	push   %ebp
80106dd5:	89 e5                	mov    %esp,%ebp
80106dd7:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106dda:	e8 ec dc ff ff       	call   80104acb <fork>
}
80106ddf:	c9                   	leave  
80106de0:	c3                   	ret    

80106de1 <sys_exit>:

int
sys_exit(void)
{
80106de1:	55                   	push   %ebp
80106de2:	89 e5                	mov    %esp,%ebp
80106de4:	83 ec 08             	sub    $0x8,%esp
  exit();
80106de7:	e8 db de ff ff       	call   80104cc7 <exit>
  return 0;  // not reached
80106dec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106df1:	c9                   	leave  
80106df2:	c3                   	ret    

80106df3 <sys_wait>:

int
sys_wait(void)
{
80106df3:	55                   	push   %ebp
80106df4:	89 e5                	mov    %esp,%ebp
80106df6:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106df9:	e8 5b e0 ff ff       	call   80104e59 <wait>
}
80106dfe:	c9                   	leave  
80106dff:	c3                   	ret    

80106e00 <sys_kill>:

int
sys_kill(void)
{
80106e00:	55                   	push   %ebp
80106e01:	89 e5                	mov    %esp,%ebp
80106e03:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106e06:	83 ec 08             	sub    $0x8,%esp
80106e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e0c:	50                   	push   %eax
80106e0d:	6a 00                	push   $0x0
80106e0f:	e8 be f0 ff ff       	call   80105ed2 <argint>
80106e14:	83 c4 10             	add    $0x10,%esp
80106e17:	85 c0                	test   %eax,%eax
80106e19:	79 07                	jns    80106e22 <sys_kill+0x22>
    return -1;
80106e1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e20:	eb 0f                	jmp    80106e31 <sys_kill+0x31>
  return kill(pid);
80106e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e25:	83 ec 0c             	sub    $0xc,%esp
80106e28:	50                   	push   %eax
80106e29:	e8 a3 e4 ff ff       	call   801052d1 <kill>
80106e2e:	83 c4 10             	add    $0x10,%esp
}
80106e31:	c9                   	leave  
80106e32:	c3                   	ret    

80106e33 <sys_getpid>:

int
sys_getpid(void)
{
80106e33:	55                   	push   %ebp
80106e34:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106e36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e3c:	8b 40 10             	mov    0x10(%eax),%eax
}
80106e3f:	5d                   	pop    %ebp
80106e40:	c3                   	ret    

80106e41 <sys_sbrk>:

int
sys_sbrk(void)
{
80106e41:	55                   	push   %ebp
80106e42:	89 e5                	mov    %esp,%ebp
80106e44:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106e47:	83 ec 08             	sub    $0x8,%esp
80106e4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e4d:	50                   	push   %eax
80106e4e:	6a 00                	push   $0x0
80106e50:	e8 7d f0 ff ff       	call   80105ed2 <argint>
80106e55:	83 c4 10             	add    $0x10,%esp
80106e58:	85 c0                	test   %eax,%eax
80106e5a:	79 07                	jns    80106e63 <sys_sbrk+0x22>
    return -1;
80106e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e61:	eb 28                	jmp    80106e8b <sys_sbrk+0x4a>
  addr = proc->sz;
80106e63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e69:	8b 00                	mov    (%eax),%eax
80106e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e71:	83 ec 0c             	sub    $0xc,%esp
80106e74:	50                   	push   %eax
80106e75:	e8 ae db ff ff       	call   80104a28 <growproc>
80106e7a:	83 c4 10             	add    $0x10,%esp
80106e7d:	85 c0                	test   %eax,%eax
80106e7f:	79 07                	jns    80106e88 <sys_sbrk+0x47>
    return -1;
80106e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e86:	eb 03                	jmp    80106e8b <sys_sbrk+0x4a>
  return addr;
80106e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106e8b:	c9                   	leave  
80106e8c:	c3                   	ret    

80106e8d <sys_sleep>:

int
sys_sleep(void)
{
80106e8d:	55                   	push   %ebp
80106e8e:	89 e5                	mov    %esp,%ebp
80106e90:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106e93:	83 ec 08             	sub    $0x8,%esp
80106e96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e99:	50                   	push   %eax
80106e9a:	6a 00                	push   $0x0
80106e9c:	e8 31 f0 ff ff       	call   80105ed2 <argint>
80106ea1:	83 c4 10             	add    $0x10,%esp
80106ea4:	85 c0                	test   %eax,%eax
80106ea6:	79 07                	jns    80106eaf <sys_sleep+0x22>
    return -1;
80106ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ead:	eb 77                	jmp    80106f26 <sys_sleep+0x99>
  acquire(&tickslock);
80106eaf:	83 ec 0c             	sub    $0xc,%esp
80106eb2:	68 20 79 11 80       	push   $0x80117920
80106eb7:	e8 8e ea ff ff       	call   8010594a <acquire>
80106ebc:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106ebf:	a1 60 81 11 80       	mov    0x80118160,%eax
80106ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106ec7:	eb 39                	jmp    80106f02 <sys_sleep+0x75>
    if(proc->killed){
80106ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ecf:	8b 40 24             	mov    0x24(%eax),%eax
80106ed2:	85 c0                	test   %eax,%eax
80106ed4:	74 17                	je     80106eed <sys_sleep+0x60>
      release(&tickslock);
80106ed6:	83 ec 0c             	sub    $0xc,%esp
80106ed9:	68 20 79 11 80       	push   $0x80117920
80106ede:	e8 ce ea ff ff       	call   801059b1 <release>
80106ee3:	83 c4 10             	add    $0x10,%esp
      return -1;
80106ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eeb:	eb 39                	jmp    80106f26 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106eed:	83 ec 08             	sub    $0x8,%esp
80106ef0:	68 20 79 11 80       	push   $0x80117920
80106ef5:	68 60 81 11 80       	push   $0x80118160
80106efa:	e8 8f e2 ff ff       	call   8010518e <sleep>
80106eff:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106f02:	a1 60 81 11 80       	mov    0x80118160,%eax
80106f07:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106f0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f0d:	39 d0                	cmp    %edx,%eax
80106f0f:	72 b8                	jb     80106ec9 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106f11:	83 ec 0c             	sub    $0xc,%esp
80106f14:	68 20 79 11 80       	push   $0x80117920
80106f19:	e8 93 ea ff ff       	call   801059b1 <release>
80106f1e:	83 c4 10             	add    $0x10,%esp
  return 0;
80106f21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f26:	c9                   	leave  
80106f27:	c3                   	ret    

80106f28 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106f28:	55                   	push   %ebp
80106f29:	89 e5                	mov    %esp,%ebp
80106f2b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106f2e:	83 ec 0c             	sub    $0xc,%esp
80106f31:	68 20 79 11 80       	push   $0x80117920
80106f36:	e8 0f ea ff ff       	call   8010594a <acquire>
80106f3b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106f3e:	a1 60 81 11 80       	mov    0x80118160,%eax
80106f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106f46:	83 ec 0c             	sub    $0xc,%esp
80106f49:	68 20 79 11 80       	push   $0x80117920
80106f4e:	e8 5e ea ff ff       	call   801059b1 <release>
80106f53:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106f59:	c9                   	leave  
80106f5a:	c3                   	ret    

80106f5b <sys_procstat>:

// List the existing processes in the system and their status.
int
sys_procstat(void)
{
80106f5b:	55                   	push   %ebp
80106f5c:	89 e5                	mov    %esp,%ebp
80106f5e:	83 ec 08             	sub    $0x8,%esp
  cprintf("sys_procstat\n");
80106f61:	83 ec 0c             	sub    $0xc,%esp
80106f64:	68 e7 96 10 80       	push   $0x801096e7
80106f69:	e8 58 94 ff ff       	call   801003c6 <cprintf>
80106f6e:	83 c4 10             	add    $0x10,%esp
  procdump();  // call function defined in proc.c
80106f71:	e8 e6 e3 ff ff       	call   8010535c <procdump>
  return 0;
80106f76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f7b:	c9                   	leave  
80106f7c:	c3                   	ret    

80106f7d <sys_setpriority>:

// Set the priority to a process.
int
sys_setpriority(void)
{
80106f7d:	55                   	push   %ebp
80106f7e:	89 e5                	mov    %esp,%ebp
80106f80:	83 ec 18             	sub    $0x18,%esp
  int level;
  //cprintf("sys_setpriority\n");
  if(argint(0, &level)<0)
80106f83:	83 ec 08             	sub    $0x8,%esp
80106f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f89:	50                   	push   %eax
80106f8a:	6a 00                	push   $0x0
80106f8c:	e8 41 ef ff ff       	call   80105ed2 <argint>
80106f91:	83 c4 10             	add    $0x10,%esp
80106f94:	85 c0                	test   %eax,%eax
80106f96:	79 07                	jns    80106f9f <sys_setpriority+0x22>
    return -1;
80106f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f9d:	eb 12                	jmp    80106fb1 <sys_setpriority+0x34>
  proc->priority=level;
80106f9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fa8:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  return 0;
80106fac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fb1:	c9                   	leave  
80106fb2:	c3                   	ret    

80106fb3 <sys_semget>:


int
sys_semget(void)
{
80106fb3:	55                   	push   %ebp
80106fb4:	89 e5                	mov    %esp,%ebp
80106fb6:	83 ec 18             	sub    $0x18,%esp
  int id, value;
  if(argint(0, &id)<0)
80106fb9:	83 ec 08             	sub    $0x8,%esp
80106fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fbf:	50                   	push   %eax
80106fc0:	6a 00                	push   $0x0
80106fc2:	e8 0b ef ff ff       	call   80105ed2 <argint>
80106fc7:	83 c4 10             	add    $0x10,%esp
80106fca:	85 c0                	test   %eax,%eax
80106fcc:	79 07                	jns    80106fd5 <sys_semget+0x22>
    return -1;
80106fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fd3:	eb 2f                	jmp    80107004 <sys_semget+0x51>
  if(argint(1, &value)<0)
80106fd5:	83 ec 08             	sub    $0x8,%esp
80106fd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fdb:	50                   	push   %eax
80106fdc:	6a 01                	push   $0x1
80106fde:	e8 ef ee ff ff       	call   80105ed2 <argint>
80106fe3:	83 c4 10             	add    $0x10,%esp
80106fe6:	85 c0                	test   %eax,%eax
80106fe8:	79 07                	jns    80106ff1 <sys_semget+0x3e>
    return -1;
80106fea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fef:	eb 13                	jmp    80107004 <sys_semget+0x51>
  return semget(id,value);
80106ff1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff7:	83 ec 08             	sub    $0x8,%esp
80106ffa:	52                   	push   %edx
80106ffb:	50                   	push   %eax
80106ffc:	e8 64 e5 ff ff       	call   80105565 <semget>
80107001:	83 c4 10             	add    $0x10,%esp
}
80107004:	c9                   	leave  
80107005:	c3                   	ret    

80107006 <sys_semfree>:


int
sys_semfree(void)
{
80107006:	55                   	push   %ebp
80107007:	89 e5                	mov    %esp,%ebp
80107009:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
8010700c:	83 ec 08             	sub    $0x8,%esp
8010700f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107012:	50                   	push   %eax
80107013:	6a 00                	push   $0x0
80107015:	e8 b8 ee ff ff       	call   80105ed2 <argint>
8010701a:	83 c4 10             	add    $0x10,%esp
8010701d:	85 c0                	test   %eax,%eax
8010701f:	79 07                	jns    80107028 <sys_semfree+0x22>
    return -1;
80107021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107026:	eb 0f                	jmp    80107037 <sys_semfree+0x31>
  return semfree(id);
80107028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702b:	83 ec 0c             	sub    $0xc,%esp
8010702e:	50                   	push   %eax
8010702f:	e8 63 e6 ff ff       	call   80105697 <semfree>
80107034:	83 c4 10             	add    $0x10,%esp
}
80107037:	c9                   	leave  
80107038:	c3                   	ret    

80107039 <sys_semdown>:


int
sys_semdown(void)
{
80107039:	55                   	push   %ebp
8010703a:	89 e5                	mov    %esp,%ebp
8010703c:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
8010703f:	83 ec 08             	sub    $0x8,%esp
80107042:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107045:	50                   	push   %eax
80107046:	6a 00                	push   $0x0
80107048:	e8 85 ee ff ff       	call   80105ed2 <argint>
8010704d:	83 c4 10             	add    $0x10,%esp
80107050:	85 c0                	test   %eax,%eax
80107052:	79 07                	jns    8010705b <sys_semdown+0x22>
    return -1;
80107054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107059:	eb 0f                	jmp    8010706a <sys_semdown+0x31>
  return semdown(id);
8010705b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705e:	83 ec 0c             	sub    $0xc,%esp
80107061:	50                   	push   %eax
80107062:	e8 cb e6 ff ff       	call   80105732 <semdown>
80107067:	83 c4 10             	add    $0x10,%esp
}
8010706a:	c9                   	leave  
8010706b:	c3                   	ret    

8010706c <sys_semup>:


int
sys_semup(void)
{
8010706c:	55                   	push   %ebp
8010706d:	89 e5                	mov    %esp,%ebp
8010706f:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107072:	83 ec 08             	sub    $0x8,%esp
80107075:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107078:	50                   	push   %eax
80107079:	6a 00                	push   $0x0
8010707b:	e8 52 ee ff ff       	call   80105ed2 <argint>
80107080:	83 c4 10             	add    $0x10,%esp
80107083:	85 c0                	test   %eax,%eax
80107085:	79 07                	jns    8010708e <sys_semup+0x22>
    return -1;
80107087:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010708c:	eb 0f                	jmp    8010709d <sys_semup+0x31>
  return semup(id);
8010708e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107091:	83 ec 0c             	sub    $0xc,%esp
80107094:	50                   	push   %eax
80107095:	e8 2b e7 ff ff       	call   801057c5 <semup>
8010709a:	83 c4 10             	add    $0x10,%esp
}
8010709d:	c9                   	leave  
8010709e:	c3                   	ret    

8010709f <sys_mmap>:

int
sys_mmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
8010709f:	55                   	push   %ebp
801070a0:	89 e5                	mov    %esp,%ebp
801070a2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int mode;
  int addr;
  if(argint(0, &fd)<0 || argint(1, &mode)<0 ||argint(2,&addr)<0){ //PREGUNTAR
801070a5:	83 ec 08             	sub    $0x8,%esp
801070a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070ab:	50                   	push   %eax
801070ac:	6a 00                	push   $0x0
801070ae:	e8 1f ee ff ff       	call   80105ed2 <argint>
801070b3:	83 c4 10             	add    $0x10,%esp
801070b6:	85 c0                	test   %eax,%eax
801070b8:	78 2a                	js     801070e4 <sys_mmap+0x45>
801070ba:	83 ec 08             	sub    $0x8,%esp
801070bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070c0:	50                   	push   %eax
801070c1:	6a 01                	push   $0x1
801070c3:	e8 0a ee ff ff       	call   80105ed2 <argint>
801070c8:	83 c4 10             	add    $0x10,%esp
801070cb:	85 c0                	test   %eax,%eax
801070cd:	78 15                	js     801070e4 <sys_mmap+0x45>
801070cf:	83 ec 08             	sub    $0x8,%esp
801070d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801070d5:	50                   	push   %eax
801070d6:	6a 02                	push   $0x2
801070d8:	e8 f5 ed ff ff       	call   80105ed2 <argint>
801070dd:	83 c4 10             	add    $0x10,%esp
801070e0:	85 c0                	test   %eax,%eax
801070e2:	79 07                	jns    801070eb <sys_mmap+0x4c>
    return -1;
801070e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070e9:	eb 2d                	jmp    80107118 <sys_mmap+0x79>
  }
  cprintf("%x",addr);
801070eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070ee:	83 ec 08             	sub    $0x8,%esp
801070f1:	50                   	push   %eax
801070f2:	68 f5 96 10 80       	push   $0x801096f5
801070f7:	e8 ca 92 ff ff       	call   801003c6 <cprintf>
801070fc:	83 c4 10             	add    $0x10,%esp
  return mmap(fd,mode,(char**)addr);
801070ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107102:	89 c1                	mov    %eax,%ecx
80107104:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710a:	83 ec 04             	sub    $0x4,%esp
8010710d:	51                   	push   %ecx
8010710e:	52                   	push   %edx
8010710f:	50                   	push   %eax
80107110:	e8 2b c9 ff ff       	call   80103a40 <mmap>
80107115:	83 c4 10             	add    $0x10,%esp
}
80107118:	c9                   	leave  
80107119:	c3                   	ret    

8010711a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010711a:	55                   	push   %ebp
8010711b:	89 e5                	mov    %esp,%ebp
8010711d:	83 ec 08             	sub    $0x8,%esp
80107120:	8b 55 08             	mov    0x8(%ebp),%edx
80107123:	8b 45 0c             	mov    0xc(%ebp),%eax
80107126:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010712a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010712d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107131:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107135:	ee                   	out    %al,(%dx)
}
80107136:	90                   	nop
80107137:	c9                   	leave  
80107138:	c3                   	ret    

80107139 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107139:	55                   	push   %ebp
8010713a:	89 e5                	mov    %esp,%ebp
8010713c:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010713f:	6a 34                	push   $0x34
80107141:	6a 43                	push   $0x43
80107143:	e8 d2 ff ff ff       	call   8010711a <outb>
80107148:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010714b:	68 9c 00 00 00       	push   $0x9c
80107150:	6a 40                	push   $0x40
80107152:	e8 c3 ff ff ff       	call   8010711a <outb>
80107157:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010715a:	6a 2e                	push   $0x2e
8010715c:	6a 40                	push   $0x40
8010715e:	e8 b7 ff ff ff       	call   8010711a <outb>
80107163:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107166:	83 ec 0c             	sub    $0xc,%esp
80107169:	6a 00                	push   $0x0
8010716b:	e8 a7 ce ff ff       	call   80104017 <picenable>
80107170:	83 c4 10             	add    $0x10,%esp
}
80107173:	90                   	nop
80107174:	c9                   	leave  
80107175:	c3                   	ret    

80107176 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107176:	1e                   	push   %ds
  pushl %es
80107177:	06                   	push   %es
  pushl %fs
80107178:	0f a0                	push   %fs
  pushl %gs
8010717a:	0f a8                	push   %gs
  pushal
8010717c:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010717d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107181:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107183:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107185:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107189:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010718b:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010718d:	54                   	push   %esp
  call trap
8010718e:	e8 d7 01 00 00       	call   8010736a <trap>
  addl $4, %esp
80107193:	83 c4 04             	add    $0x4,%esp

80107196 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107196:	61                   	popa   
  popl %gs
80107197:	0f a9                	pop    %gs
  popl %fs
80107199:	0f a1                	pop    %fs
  popl %es
8010719b:	07                   	pop    %es
  popl %ds
8010719c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010719d:	83 c4 08             	add    $0x8,%esp
  iret
801071a0:	cf                   	iret   

801071a1 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071a1:	55                   	push   %ebp
801071a2:	89 e5                	mov    %esp,%ebp
801071a4:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801071aa:	83 e8 01             	sub    $0x1,%eax
801071ad:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071b1:	8b 45 08             	mov    0x8(%ebp),%eax
801071b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071b8:	8b 45 08             	mov    0x8(%ebp),%eax
801071bb:	c1 e8 10             	shr    $0x10,%eax
801071be:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801071c2:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071c5:	0f 01 18             	lidtl  (%eax)
}
801071c8:	90                   	nop
801071c9:	c9                   	leave  
801071ca:	c3                   	ret    

801071cb <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801071cb:	55                   	push   %ebp
801071cc:	89 e5                	mov    %esp,%ebp
801071ce:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801071d1:	0f 20 d0             	mov    %cr2,%eax
801071d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801071d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801071da:	c9                   	leave  
801071db:	c3                   	ret    

801071dc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801071dc:	55                   	push   %ebp
801071dd:	89 e5                	mov    %esp,%ebp
801071df:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801071e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801071e9:	e9 c3 00 00 00       	jmp    801072b1 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801071ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f1:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
801071f8:	89 c2                	mov    %eax,%edx
801071fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fd:	66 89 14 c5 60 79 11 	mov    %dx,-0x7fee86a0(,%eax,8)
80107204:	80 
80107205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107208:	66 c7 04 c5 62 79 11 	movw   $0x8,-0x7fee869e(,%eax,8)
8010720f:	80 08 00 
80107212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107215:	0f b6 14 c5 64 79 11 	movzbl -0x7fee869c(,%eax,8),%edx
8010721c:	80 
8010721d:	83 e2 e0             	and    $0xffffffe0,%edx
80107220:	88 14 c5 64 79 11 80 	mov    %dl,-0x7fee869c(,%eax,8)
80107227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722a:	0f b6 14 c5 64 79 11 	movzbl -0x7fee869c(,%eax,8),%edx
80107231:	80 
80107232:	83 e2 1f             	and    $0x1f,%edx
80107235:	88 14 c5 64 79 11 80 	mov    %dl,-0x7fee869c(,%eax,8)
8010723c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723f:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
80107246:	80 
80107247:	83 e2 f0             	and    $0xfffffff0,%edx
8010724a:	83 ca 0e             	or     $0xe,%edx
8010724d:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
80107254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107257:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
8010725e:	80 
8010725f:	83 e2 ef             	and    $0xffffffef,%edx
80107262:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
80107269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726c:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
80107273:	80 
80107274:	83 e2 9f             	and    $0xffffff9f,%edx
80107277:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
8010727e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107281:	0f b6 14 c5 65 79 11 	movzbl -0x7fee869b(,%eax,8),%edx
80107288:	80 
80107289:	83 ca 80             	or     $0xffffff80,%edx
8010728c:	88 14 c5 65 79 11 80 	mov    %dl,-0x7fee869b(,%eax,8)
80107293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107296:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
8010729d:	c1 e8 10             	shr    $0x10,%eax
801072a0:	89 c2                	mov    %eax,%edx
801072a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a5:	66 89 14 c5 66 79 11 	mov    %dx,-0x7fee869a(,%eax,8)
801072ac:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801072ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801072b1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801072b8:	0f 8e 30 ff ff ff    	jle    801071ee <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801072be:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
801072c3:	66 a3 60 7b 11 80    	mov    %ax,0x80117b60
801072c9:	66 c7 05 62 7b 11 80 	movw   $0x8,0x80117b62
801072d0:	08 00 
801072d2:	0f b6 05 64 7b 11 80 	movzbl 0x80117b64,%eax
801072d9:	83 e0 e0             	and    $0xffffffe0,%eax
801072dc:	a2 64 7b 11 80       	mov    %al,0x80117b64
801072e1:	0f b6 05 64 7b 11 80 	movzbl 0x80117b64,%eax
801072e8:	83 e0 1f             	and    $0x1f,%eax
801072eb:	a2 64 7b 11 80       	mov    %al,0x80117b64
801072f0:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
801072f7:	83 c8 0f             	or     $0xf,%eax
801072fa:	a2 65 7b 11 80       	mov    %al,0x80117b65
801072ff:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107306:	83 e0 ef             	and    $0xffffffef,%eax
80107309:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010730e:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107315:	83 c8 60             	or     $0x60,%eax
80107318:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010731d:	0f b6 05 65 7b 11 80 	movzbl 0x80117b65,%eax
80107324:	83 c8 80             	or     $0xffffff80,%eax
80107327:	a2 65 7b 11 80       	mov    %al,0x80117b65
8010732c:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
80107331:	c1 e8 10             	shr    $0x10,%eax
80107334:	66 a3 66 7b 11 80    	mov    %ax,0x80117b66

  initlock(&tickslock, "time");
8010733a:	83 ec 08             	sub    $0x8,%esp
8010733d:	68 f8 96 10 80       	push   $0x801096f8
80107342:	68 20 79 11 80       	push   $0x80117920
80107347:	e8 dc e5 ff ff       	call   80105928 <initlock>
8010734c:	83 c4 10             	add    $0x10,%esp
}
8010734f:	90                   	nop
80107350:	c9                   	leave  
80107351:	c3                   	ret    

80107352 <idtinit>:

void
idtinit(void)
{
80107352:	55                   	push   %ebp
80107353:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107355:	68 00 08 00 00       	push   $0x800
8010735a:	68 60 79 11 80       	push   $0x80117960
8010735f:	e8 3d fe ff ff       	call   801071a1 <lidt>
80107364:	83 c4 08             	add    $0x8,%esp
}
80107367:	90                   	nop
80107368:	c9                   	leave  
80107369:	c3                   	ret    

8010736a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010736a:	55                   	push   %ebp
8010736b:	89 e5                	mov    %esp,%ebp
8010736d:	57                   	push   %edi
8010736e:	56                   	push   %esi
8010736f:	53                   	push   %ebx
80107370:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80107373:	8b 45 08             	mov    0x8(%ebp),%eax
80107376:	8b 40 30             	mov    0x30(%eax),%eax
80107379:	83 f8 40             	cmp    $0x40,%eax
8010737c:	75 3e                	jne    801073bc <trap+0x52>
    if(proc->killed)
8010737e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107384:	8b 40 24             	mov    0x24(%eax),%eax
80107387:	85 c0                	test   %eax,%eax
80107389:	74 05                	je     80107390 <trap+0x26>
      exit();
8010738b:	e8 37 d9 ff ff       	call   80104cc7 <exit>
    proc->tf = tf;
80107390:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107396:	8b 55 08             	mov    0x8(%ebp),%edx
80107399:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010739c:	e8 e7 eb ff ff       	call   80105f88 <syscall>
    if(proc->killed)
801073a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a7:	8b 40 24             	mov    0x24(%eax),%eax
801073aa:	85 c0                	test   %eax,%eax
801073ac:	0f 84 15 03 00 00    	je     801076c7 <trap+0x35d>
      exit();
801073b2:	e8 10 d9 ff ff       	call   80104cc7 <exit>
    return;
801073b7:	e9 0b 03 00 00       	jmp    801076c7 <trap+0x35d>
  }

  switch(tf->trapno){
801073bc:	8b 45 08             	mov    0x8(%ebp),%eax
801073bf:	8b 40 30             	mov    0x30(%eax),%eax
801073c2:	83 e8 20             	sub    $0x20,%eax
801073c5:	83 f8 1f             	cmp    $0x1f,%eax
801073c8:	0f 87 c0 00 00 00    	ja     8010748e <trap+0x124>
801073ce:	8b 04 85 f0 97 10 80 	mov    -0x7fef6810(,%eax,4),%eax
801073d5:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801073d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801073dd:	0f b6 00             	movzbl (%eax),%eax
801073e0:	84 c0                	test   %al,%al
801073e2:	75 3d                	jne    80107421 <trap+0xb7>
      acquire(&tickslock);
801073e4:	83 ec 0c             	sub    $0xc,%esp
801073e7:	68 20 79 11 80       	push   $0x80117920
801073ec:	e8 59 e5 ff ff       	call   8010594a <acquire>
801073f1:	83 c4 10             	add    $0x10,%esp
      ticks++;
801073f4:	a1 60 81 11 80       	mov    0x80118160,%eax
801073f9:	83 c0 01             	add    $0x1,%eax
801073fc:	a3 60 81 11 80       	mov    %eax,0x80118160
      wakeup(&ticks);
80107401:	83 ec 0c             	sub    $0xc,%esp
80107404:	68 60 81 11 80       	push   $0x80118160
80107409:	e8 8c de ff ff       	call   8010529a <wakeup>
8010740e:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107411:	83 ec 0c             	sub    $0xc,%esp
80107414:	68 20 79 11 80       	push   $0x80117920
80107419:	e8 93 e5 ff ff       	call   801059b1 <release>
8010741e:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107421:	e8 9d bb ff ff       	call   80102fc3 <lapiceoi>
    break;
80107426:	e9 c0 01 00 00       	jmp    801075eb <trap+0x281>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010742b:	e8 a6 b3 ff ff       	call   801027d6 <ideintr>
    lapiceoi();
80107430:	e8 8e bb ff ff       	call   80102fc3 <lapiceoi>
    break;
80107435:	e9 b1 01 00 00       	jmp    801075eb <trap+0x281>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010743a:	e8 86 b9 ff ff       	call   80102dc5 <kbdintr>
    lapiceoi();
8010743f:	e8 7f bb ff ff       	call   80102fc3 <lapiceoi>
    break;
80107444:	e9 a2 01 00 00       	jmp    801075eb <trap+0x281>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107449:	e8 5a 04 00 00       	call   801078a8 <uartintr>
    lapiceoi();
8010744e:	e8 70 bb ff ff       	call   80102fc3 <lapiceoi>
    break;
80107453:	e9 93 01 00 00       	jmp    801075eb <trap+0x281>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107458:	8b 45 08             	mov    0x8(%ebp),%eax
8010745b:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010745e:	8b 45 08             	mov    0x8(%ebp),%eax
80107461:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107465:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107468:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010746e:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107471:	0f b6 c0             	movzbl %al,%eax
80107474:	51                   	push   %ecx
80107475:	52                   	push   %edx
80107476:	50                   	push   %eax
80107477:	68 00 97 10 80       	push   $0x80109700
8010747c:	e8 45 8f ff ff       	call   801003c6 <cprintf>
80107481:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107484:	e8 3a bb ff ff       	call   80102fc3 <lapiceoi>
    break;
80107489:	e9 5d 01 00 00       	jmp    801075eb <trap+0x281>

  //PAGEBREAK: 13
  default:

    if(proc && tf->trapno == T_PGFLT){
8010748e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107494:	85 c0                	test   %eax,%eax
80107496:	0f 84 93 00 00 00    	je     8010752f <trap+0x1c5>
8010749c:	8b 45 08             	mov    0x8(%ebp),%eax
8010749f:	8b 40 30             	mov    0x30(%eax),%eax
801074a2:	83 f8 0e             	cmp    $0xe,%eax
801074a5:	0f 85 84 00 00 00    	jne    8010752f <trap+0x1c5>
      uint cr2=rcr2();
801074ab:	e8 1b fd ff ff       	call   801071cb <rcr2>
801074b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint basepgaddr;


      //  Verify if you wanted to access a correct address but not assigned.
      //  if appropriate, assign one more page to the stack.
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
801074b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074b9:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
801074bf:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801074c2:	77 6b                	ja     8010752f <trap+0x1c5>
801074c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074ca:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
801074d0:	05 00 80 00 00       	add    $0x8000,%eax
801074d5:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801074d8:	76 55                	jbe    8010752f <trap+0x1c5>
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
801074da:	83 ec 08             	sub    $0x8,%esp
801074dd:	ff 75 e4             	pushl  -0x1c(%ebp)
801074e0:	68 24 97 10 80       	push   $0x80109724
801074e5:	e8 dc 8e ff ff       	call   801003c6 <cprintf>
801074ea:	83 c4 10             	add    $0x10,%esp
        basepgaddr=PGROUNDDOWN(cr2);
801074ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801074f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
801074f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801074fb:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
80107501:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107507:	8b 40 04             	mov    0x4(%eax),%eax
8010750a:	83 ec 04             	sub    $0x4,%esp
8010750d:	52                   	push   %edx
8010750e:	ff 75 e0             	pushl  -0x20(%ebp)
80107511:	50                   	push   %eax
80107512:	e8 e5 17 00 00       	call   80108cfc <allocuvm>
80107517:	83 c4 10             	add    $0x10,%esp
8010751a:	85 c0                	test   %eax,%eax
8010751c:	0f 85 c8 00 00 00    	jne    801075ea <trap+0x280>
          panic("trap alloc stack");
80107522:	83 ec 0c             	sub    $0xc,%esp
80107525:	68 60 97 10 80       	push   $0x80109760
8010752a:	e8 37 90 ff ff       	call   80100566 <panic>
        break;
      }
    }

    if(proc == 0 || (tf->cs&3) == 0){
8010752f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107535:	85 c0                	test   %eax,%eax
80107537:	74 11                	je     8010754a <trap+0x1e0>
80107539:	8b 45 08             	mov    0x8(%ebp),%eax
8010753c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107540:	0f b7 c0             	movzwl %ax,%eax
80107543:	83 e0 03             	and    $0x3,%eax
80107546:	85 c0                	test   %eax,%eax
80107548:	75 40                	jne    8010758a <trap+0x220>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010754a:	e8 7c fc ff ff       	call   801071cb <rcr2>
8010754f:	89 c3                	mov    %eax,%ebx
80107551:	8b 45 08             	mov    0x8(%ebp),%eax
80107554:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107557:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010755d:	0f b6 00             	movzbl (%eax),%eax
      }
    }

    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107560:	0f b6 d0             	movzbl %al,%edx
80107563:	8b 45 08             	mov    0x8(%ebp),%eax
80107566:	8b 40 30             	mov    0x30(%eax),%eax
80107569:	83 ec 0c             	sub    $0xc,%esp
8010756c:	53                   	push   %ebx
8010756d:	51                   	push   %ecx
8010756e:	52                   	push   %edx
8010756f:	50                   	push   %eax
80107570:	68 74 97 10 80       	push   $0x80109774
80107575:	e8 4c 8e ff ff       	call   801003c6 <cprintf>
8010757a:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010757d:	83 ec 0c             	sub    $0xc,%esp
80107580:	68 a6 97 10 80       	push   $0x801097a6
80107585:	e8 dc 8f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010758a:	e8 3c fc ff ff       	call   801071cb <rcr2>
8010758f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107592:	8b 45 08             	mov    0x8(%ebp),%eax
80107595:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107598:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010759e:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075a1:	0f b6 d8             	movzbl %al,%ebx
801075a4:	8b 45 08             	mov    0x8(%ebp),%eax
801075a7:	8b 48 34             	mov    0x34(%eax),%ecx
801075aa:	8b 45 08             	mov    0x8(%ebp),%eax
801075ad:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
801075b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075b6:	8d 78 6c             	lea    0x6c(%eax),%edi
801075b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075bf:	8b 40 10             	mov    0x10(%eax),%eax
801075c2:	ff 75 d4             	pushl  -0x2c(%ebp)
801075c5:	56                   	push   %esi
801075c6:	53                   	push   %ebx
801075c7:	51                   	push   %ecx
801075c8:	52                   	push   %edx
801075c9:	57                   	push   %edi
801075ca:	50                   	push   %eax
801075cb:	68 ac 97 10 80       	push   $0x801097ac
801075d0:	e8 f1 8d ff ff       	call   801003c6 <cprintf>
801075d5:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
801075d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075de:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801075e5:	eb 04                	jmp    801075eb <trap+0x281>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801075e7:	90                   	nop
801075e8:	eb 01                	jmp    801075eb <trap+0x281>
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
        basepgaddr=PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        break;
801075ea:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801075eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075f1:	85 c0                	test   %eax,%eax
801075f3:	74 24                	je     80107619 <trap+0x2af>
801075f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075fb:	8b 40 24             	mov    0x24(%eax),%eax
801075fe:	85 c0                	test   %eax,%eax
80107600:	74 17                	je     80107619 <trap+0x2af>
80107602:	8b 45 08             	mov    0x8(%ebp),%eax
80107605:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107609:	0f b7 c0             	movzwl %ax,%eax
8010760c:	83 e0 03             	and    $0x3,%eax
8010760f:	83 f8 03             	cmp    $0x3,%eax
80107612:	75 05                	jne    80107619 <trap+0x2af>
    exit();
80107614:	e8 ae d6 ff ff       	call   80104cc7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
80107619:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010761f:	85 c0                	test   %eax,%eax
80107621:	74 41                	je     80107664 <trap+0x2fa>
80107623:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107629:	8b 40 0c             	mov    0xc(%eax),%eax
8010762c:	83 f8 04             	cmp    $0x4,%eax
8010762f:	75 33                	jne    80107664 <trap+0x2fa>
80107631:	8b 45 08             	mov    0x8(%ebp),%eax
80107634:	8b 40 30             	mov    0x30(%eax),%eax
80107637:	83 f8 20             	cmp    $0x20,%eax
8010763a:	75 28                	jne    80107664 <trap+0x2fa>
    if(proc->ticks++ == QUANTUM-1){  // Check if the amount of ticks of the current process reached the Quantum
8010763c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107642:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
80107646:	8d 4a 01             	lea    0x1(%edx),%ecx
80107649:	66 89 48 7c          	mov    %cx,0x7c(%eax)
8010764d:	66 83 fa 04          	cmp    $0x4,%dx
80107651:	75 11                	jne    80107664 <trap+0x2fa>
      //cprintf("El proceso con id %d tiene %d ticks\n",proc->pid, proc->ticks);
      proc->ticks=0;  // Restarts the amount of process ticks
80107653:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107659:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
8010765f:	e8 98 da ff ff       	call   801050fc <yield>
    }

  }
  // check if the number of ticks was reached to increase the ages.
  if((tf->trapno == T_IRQ0+IRQ_TIMER) && (ticks % TICKSFORAGE == 0))
80107664:	8b 45 08             	mov    0x8(%ebp),%eax
80107667:	8b 40 30             	mov    0x30(%eax),%eax
8010766a:	83 f8 20             	cmp    $0x20,%eax
8010766d:	75 28                	jne    80107697 <trap+0x32d>
8010766f:	8b 0d 60 81 11 80    	mov    0x80118160,%ecx
80107675:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010767a:	89 c8                	mov    %ecx,%eax
8010767c:	f7 e2                	mul    %edx
8010767e:	c1 ea 03             	shr    $0x3,%edx
80107681:	89 d0                	mov    %edx,%eax
80107683:	c1 e0 02             	shl    $0x2,%eax
80107686:	01 d0                	add    %edx,%eax
80107688:	01 c0                	add    %eax,%eax
8010768a:	29 c1                	sub    %eax,%ecx
8010768c:	89 ca                	mov    %ecx,%edx
8010768e:	85 d2                	test   %edx,%edx
80107690:	75 05                	jne    80107697 <trap+0x32d>
    calculateaging();
80107692:	e8 50 d0 ff ff       	call   801046e7 <calculateaging>


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107697:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010769d:	85 c0                	test   %eax,%eax
8010769f:	74 27                	je     801076c8 <trap+0x35e>
801076a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076a7:	8b 40 24             	mov    0x24(%eax),%eax
801076aa:	85 c0                	test   %eax,%eax
801076ac:	74 1a                	je     801076c8 <trap+0x35e>
801076ae:	8b 45 08             	mov    0x8(%ebp),%eax
801076b1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801076b5:	0f b7 c0             	movzwl %ax,%eax
801076b8:	83 e0 03             	and    $0x3,%eax
801076bb:	83 f8 03             	cmp    $0x3,%eax
801076be:	75 08                	jne    801076c8 <trap+0x35e>
    exit();
801076c0:	e8 02 d6 ff ff       	call   80104cc7 <exit>
801076c5:	eb 01                	jmp    801076c8 <trap+0x35e>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801076c7:	90                   	nop


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801076c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076cb:	5b                   	pop    %ebx
801076cc:	5e                   	pop    %esi
801076cd:	5f                   	pop    %edi
801076ce:	5d                   	pop    %ebp
801076cf:	c3                   	ret    

801076d0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801076d0:	55                   	push   %ebp
801076d1:	89 e5                	mov    %esp,%ebp
801076d3:	83 ec 14             	sub    $0x14,%esp
801076d6:	8b 45 08             	mov    0x8(%ebp),%eax
801076d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801076dd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801076e1:	89 c2                	mov    %eax,%edx
801076e3:	ec                   	in     (%dx),%al
801076e4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801076e7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801076eb:	c9                   	leave  
801076ec:	c3                   	ret    

801076ed <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801076ed:	55                   	push   %ebp
801076ee:	89 e5                	mov    %esp,%ebp
801076f0:	83 ec 08             	sub    $0x8,%esp
801076f3:	8b 55 08             	mov    0x8(%ebp),%edx
801076f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801076f9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801076fd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107700:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107704:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107708:	ee                   	out    %al,(%dx)
}
80107709:	90                   	nop
8010770a:	c9                   	leave  
8010770b:	c3                   	ret    

8010770c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010770c:	55                   	push   %ebp
8010770d:	89 e5                	mov    %esp,%ebp
8010770f:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107712:	6a 00                	push   $0x0
80107714:	68 fa 03 00 00       	push   $0x3fa
80107719:	e8 cf ff ff ff       	call   801076ed <outb>
8010771e:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107721:	68 80 00 00 00       	push   $0x80
80107726:	68 fb 03 00 00       	push   $0x3fb
8010772b:	e8 bd ff ff ff       	call   801076ed <outb>
80107730:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107733:	6a 0c                	push   $0xc
80107735:	68 f8 03 00 00       	push   $0x3f8
8010773a:	e8 ae ff ff ff       	call   801076ed <outb>
8010773f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107742:	6a 00                	push   $0x0
80107744:	68 f9 03 00 00       	push   $0x3f9
80107749:	e8 9f ff ff ff       	call   801076ed <outb>
8010774e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107751:	6a 03                	push   $0x3
80107753:	68 fb 03 00 00       	push   $0x3fb
80107758:	e8 90 ff ff ff       	call   801076ed <outb>
8010775d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107760:	6a 00                	push   $0x0
80107762:	68 fc 03 00 00       	push   $0x3fc
80107767:	e8 81 ff ff ff       	call   801076ed <outb>
8010776c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010776f:	6a 01                	push   $0x1
80107771:	68 f9 03 00 00       	push   $0x3f9
80107776:	e8 72 ff ff ff       	call   801076ed <outb>
8010777b:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010777e:	68 fd 03 00 00       	push   $0x3fd
80107783:	e8 48 ff ff ff       	call   801076d0 <inb>
80107788:	83 c4 04             	add    $0x4,%esp
8010778b:	3c ff                	cmp    $0xff,%al
8010778d:	74 6e                	je     801077fd <uartinit+0xf1>
    return;
  uart = 1;
8010778f:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107796:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107799:	68 fa 03 00 00       	push   $0x3fa
8010779e:	e8 2d ff ff ff       	call   801076d0 <inb>
801077a3:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801077a6:	68 f8 03 00 00       	push   $0x3f8
801077ab:	e8 20 ff ff ff       	call   801076d0 <inb>
801077b0:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801077b3:	83 ec 0c             	sub    $0xc,%esp
801077b6:	6a 04                	push   $0x4
801077b8:	e8 5a c8 ff ff       	call   80104017 <picenable>
801077bd:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801077c0:	83 ec 08             	sub    $0x8,%esp
801077c3:	6a 00                	push   $0x0
801077c5:	6a 04                	push   $0x4
801077c7:	e8 ac b2 ff ff       	call   80102a78 <ioapicenable>
801077cc:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077cf:	c7 45 f4 70 98 10 80 	movl   $0x80109870,-0xc(%ebp)
801077d6:	eb 19                	jmp    801077f1 <uartinit+0xe5>
    uartputc(*p);
801077d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077db:	0f b6 00             	movzbl (%eax),%eax
801077de:	0f be c0             	movsbl %al,%eax
801077e1:	83 ec 0c             	sub    $0xc,%esp
801077e4:	50                   	push   %eax
801077e5:	e8 16 00 00 00       	call   80107800 <uartputc>
801077ea:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801077f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f4:	0f b6 00             	movzbl (%eax),%eax
801077f7:	84 c0                	test   %al,%al
801077f9:	75 dd                	jne    801077d8 <uartinit+0xcc>
801077fb:	eb 01                	jmp    801077fe <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801077fd:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801077fe:	c9                   	leave  
801077ff:	c3                   	ret    

80107800 <uartputc>:

void
uartputc(int c)
{
80107800:	55                   	push   %ebp
80107801:	89 e5                	mov    %esp,%ebp
80107803:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107806:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010780b:	85 c0                	test   %eax,%eax
8010780d:	74 53                	je     80107862 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010780f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107816:	eb 11                	jmp    80107829 <uartputc+0x29>
    microdelay(10);
80107818:	83 ec 0c             	sub    $0xc,%esp
8010781b:	6a 0a                	push   $0xa
8010781d:	e8 bc b7 ff ff       	call   80102fde <microdelay>
80107822:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107825:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107829:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010782d:	7f 1a                	jg     80107849 <uartputc+0x49>
8010782f:	83 ec 0c             	sub    $0xc,%esp
80107832:	68 fd 03 00 00       	push   $0x3fd
80107837:	e8 94 fe ff ff       	call   801076d0 <inb>
8010783c:	83 c4 10             	add    $0x10,%esp
8010783f:	0f b6 c0             	movzbl %al,%eax
80107842:	83 e0 20             	and    $0x20,%eax
80107845:	85 c0                	test   %eax,%eax
80107847:	74 cf                	je     80107818 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107849:	8b 45 08             	mov    0x8(%ebp),%eax
8010784c:	0f b6 c0             	movzbl %al,%eax
8010784f:	83 ec 08             	sub    $0x8,%esp
80107852:	50                   	push   %eax
80107853:	68 f8 03 00 00       	push   $0x3f8
80107858:	e8 90 fe ff ff       	call   801076ed <outb>
8010785d:	83 c4 10             	add    $0x10,%esp
80107860:	eb 01                	jmp    80107863 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107862:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107863:	c9                   	leave  
80107864:	c3                   	ret    

80107865 <uartgetc>:

static int
uartgetc(void)
{
80107865:	55                   	push   %ebp
80107866:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107868:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010786d:	85 c0                	test   %eax,%eax
8010786f:	75 07                	jne    80107878 <uartgetc+0x13>
    return -1;
80107871:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107876:	eb 2e                	jmp    801078a6 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107878:	68 fd 03 00 00       	push   $0x3fd
8010787d:	e8 4e fe ff ff       	call   801076d0 <inb>
80107882:	83 c4 04             	add    $0x4,%esp
80107885:	0f b6 c0             	movzbl %al,%eax
80107888:	83 e0 01             	and    $0x1,%eax
8010788b:	85 c0                	test   %eax,%eax
8010788d:	75 07                	jne    80107896 <uartgetc+0x31>
    return -1;
8010788f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107894:	eb 10                	jmp    801078a6 <uartgetc+0x41>
  return inb(COM1+0);
80107896:	68 f8 03 00 00       	push   $0x3f8
8010789b:	e8 30 fe ff ff       	call   801076d0 <inb>
801078a0:	83 c4 04             	add    $0x4,%esp
801078a3:	0f b6 c0             	movzbl %al,%eax
}
801078a6:	c9                   	leave  
801078a7:	c3                   	ret    

801078a8 <uartintr>:

void
uartintr(void)
{
801078a8:	55                   	push   %ebp
801078a9:	89 e5                	mov    %esp,%ebp
801078ab:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801078ae:	83 ec 0c             	sub    $0xc,%esp
801078b1:	68 65 78 10 80       	push   $0x80107865
801078b6:	e8 22 8f ff ff       	call   801007dd <consoleintr>
801078bb:	83 c4 10             	add    $0x10,%esp
}
801078be:	90                   	nop
801078bf:	c9                   	leave  
801078c0:	c3                   	ret    

801078c1 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801078c1:	6a 00                	push   $0x0
  pushl $0
801078c3:	6a 00                	push   $0x0
  jmp alltraps
801078c5:	e9 ac f8 ff ff       	jmp    80107176 <alltraps>

801078ca <vector1>:
.globl vector1
vector1:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $1
801078cc:	6a 01                	push   $0x1
  jmp alltraps
801078ce:	e9 a3 f8 ff ff       	jmp    80107176 <alltraps>

801078d3 <vector2>:
.globl vector2
vector2:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $2
801078d5:	6a 02                	push   $0x2
  jmp alltraps
801078d7:	e9 9a f8 ff ff       	jmp    80107176 <alltraps>

801078dc <vector3>:
.globl vector3
vector3:
  pushl $0
801078dc:	6a 00                	push   $0x0
  pushl $3
801078de:	6a 03                	push   $0x3
  jmp alltraps
801078e0:	e9 91 f8 ff ff       	jmp    80107176 <alltraps>

801078e5 <vector4>:
.globl vector4
vector4:
  pushl $0
801078e5:	6a 00                	push   $0x0
  pushl $4
801078e7:	6a 04                	push   $0x4
  jmp alltraps
801078e9:	e9 88 f8 ff ff       	jmp    80107176 <alltraps>

801078ee <vector5>:
.globl vector5
vector5:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $5
801078f0:	6a 05                	push   $0x5
  jmp alltraps
801078f2:	e9 7f f8 ff ff       	jmp    80107176 <alltraps>

801078f7 <vector6>:
.globl vector6
vector6:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $6
801078f9:	6a 06                	push   $0x6
  jmp alltraps
801078fb:	e9 76 f8 ff ff       	jmp    80107176 <alltraps>

80107900 <vector7>:
.globl vector7
vector7:
  pushl $0
80107900:	6a 00                	push   $0x0
  pushl $7
80107902:	6a 07                	push   $0x7
  jmp alltraps
80107904:	e9 6d f8 ff ff       	jmp    80107176 <alltraps>

80107909 <vector8>:
.globl vector8
vector8:
  pushl $8
80107909:	6a 08                	push   $0x8
  jmp alltraps
8010790b:	e9 66 f8 ff ff       	jmp    80107176 <alltraps>

80107910 <vector9>:
.globl vector9
vector9:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $9
80107912:	6a 09                	push   $0x9
  jmp alltraps
80107914:	e9 5d f8 ff ff       	jmp    80107176 <alltraps>

80107919 <vector10>:
.globl vector10
vector10:
  pushl $10
80107919:	6a 0a                	push   $0xa
  jmp alltraps
8010791b:	e9 56 f8 ff ff       	jmp    80107176 <alltraps>

80107920 <vector11>:
.globl vector11
vector11:
  pushl $11
80107920:	6a 0b                	push   $0xb
  jmp alltraps
80107922:	e9 4f f8 ff ff       	jmp    80107176 <alltraps>

80107927 <vector12>:
.globl vector12
vector12:
  pushl $12
80107927:	6a 0c                	push   $0xc
  jmp alltraps
80107929:	e9 48 f8 ff ff       	jmp    80107176 <alltraps>

8010792e <vector13>:
.globl vector13
vector13:
  pushl $13
8010792e:	6a 0d                	push   $0xd
  jmp alltraps
80107930:	e9 41 f8 ff ff       	jmp    80107176 <alltraps>

80107935 <vector14>:
.globl vector14
vector14:
  pushl $14
80107935:	6a 0e                	push   $0xe
  jmp alltraps
80107937:	e9 3a f8 ff ff       	jmp    80107176 <alltraps>

8010793c <vector15>:
.globl vector15
vector15:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $15
8010793e:	6a 0f                	push   $0xf
  jmp alltraps
80107940:	e9 31 f8 ff ff       	jmp    80107176 <alltraps>

80107945 <vector16>:
.globl vector16
vector16:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $16
80107947:	6a 10                	push   $0x10
  jmp alltraps
80107949:	e9 28 f8 ff ff       	jmp    80107176 <alltraps>

8010794e <vector17>:
.globl vector17
vector17:
  pushl $17
8010794e:	6a 11                	push   $0x11
  jmp alltraps
80107950:	e9 21 f8 ff ff       	jmp    80107176 <alltraps>

80107955 <vector18>:
.globl vector18
vector18:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $18
80107957:	6a 12                	push   $0x12
  jmp alltraps
80107959:	e9 18 f8 ff ff       	jmp    80107176 <alltraps>

8010795e <vector19>:
.globl vector19
vector19:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $19
80107960:	6a 13                	push   $0x13
  jmp alltraps
80107962:	e9 0f f8 ff ff       	jmp    80107176 <alltraps>

80107967 <vector20>:
.globl vector20
vector20:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $20
80107969:	6a 14                	push   $0x14
  jmp alltraps
8010796b:	e9 06 f8 ff ff       	jmp    80107176 <alltraps>

80107970 <vector21>:
.globl vector21
vector21:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $21
80107972:	6a 15                	push   $0x15
  jmp alltraps
80107974:	e9 fd f7 ff ff       	jmp    80107176 <alltraps>

80107979 <vector22>:
.globl vector22
vector22:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $22
8010797b:	6a 16                	push   $0x16
  jmp alltraps
8010797d:	e9 f4 f7 ff ff       	jmp    80107176 <alltraps>

80107982 <vector23>:
.globl vector23
vector23:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $23
80107984:	6a 17                	push   $0x17
  jmp alltraps
80107986:	e9 eb f7 ff ff       	jmp    80107176 <alltraps>

8010798b <vector24>:
.globl vector24
vector24:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $24
8010798d:	6a 18                	push   $0x18
  jmp alltraps
8010798f:	e9 e2 f7 ff ff       	jmp    80107176 <alltraps>

80107994 <vector25>:
.globl vector25
vector25:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $25
80107996:	6a 19                	push   $0x19
  jmp alltraps
80107998:	e9 d9 f7 ff ff       	jmp    80107176 <alltraps>

8010799d <vector26>:
.globl vector26
vector26:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $26
8010799f:	6a 1a                	push   $0x1a
  jmp alltraps
801079a1:	e9 d0 f7 ff ff       	jmp    80107176 <alltraps>

801079a6 <vector27>:
.globl vector27
vector27:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $27
801079a8:	6a 1b                	push   $0x1b
  jmp alltraps
801079aa:	e9 c7 f7 ff ff       	jmp    80107176 <alltraps>

801079af <vector28>:
.globl vector28
vector28:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $28
801079b1:	6a 1c                	push   $0x1c
  jmp alltraps
801079b3:	e9 be f7 ff ff       	jmp    80107176 <alltraps>

801079b8 <vector29>:
.globl vector29
vector29:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $29
801079ba:	6a 1d                	push   $0x1d
  jmp alltraps
801079bc:	e9 b5 f7 ff ff       	jmp    80107176 <alltraps>

801079c1 <vector30>:
.globl vector30
vector30:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $30
801079c3:	6a 1e                	push   $0x1e
  jmp alltraps
801079c5:	e9 ac f7 ff ff       	jmp    80107176 <alltraps>

801079ca <vector31>:
.globl vector31
vector31:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $31
801079cc:	6a 1f                	push   $0x1f
  jmp alltraps
801079ce:	e9 a3 f7 ff ff       	jmp    80107176 <alltraps>

801079d3 <vector32>:
.globl vector32
vector32:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $32
801079d5:	6a 20                	push   $0x20
  jmp alltraps
801079d7:	e9 9a f7 ff ff       	jmp    80107176 <alltraps>

801079dc <vector33>:
.globl vector33
vector33:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $33
801079de:	6a 21                	push   $0x21
  jmp alltraps
801079e0:	e9 91 f7 ff ff       	jmp    80107176 <alltraps>

801079e5 <vector34>:
.globl vector34
vector34:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $34
801079e7:	6a 22                	push   $0x22
  jmp alltraps
801079e9:	e9 88 f7 ff ff       	jmp    80107176 <alltraps>

801079ee <vector35>:
.globl vector35
vector35:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $35
801079f0:	6a 23                	push   $0x23
  jmp alltraps
801079f2:	e9 7f f7 ff ff       	jmp    80107176 <alltraps>

801079f7 <vector36>:
.globl vector36
vector36:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $36
801079f9:	6a 24                	push   $0x24
  jmp alltraps
801079fb:	e9 76 f7 ff ff       	jmp    80107176 <alltraps>

80107a00 <vector37>:
.globl vector37
vector37:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $37
80107a02:	6a 25                	push   $0x25
  jmp alltraps
80107a04:	e9 6d f7 ff ff       	jmp    80107176 <alltraps>

80107a09 <vector38>:
.globl vector38
vector38:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $38
80107a0b:	6a 26                	push   $0x26
  jmp alltraps
80107a0d:	e9 64 f7 ff ff       	jmp    80107176 <alltraps>

80107a12 <vector39>:
.globl vector39
vector39:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $39
80107a14:	6a 27                	push   $0x27
  jmp alltraps
80107a16:	e9 5b f7 ff ff       	jmp    80107176 <alltraps>

80107a1b <vector40>:
.globl vector40
vector40:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $40
80107a1d:	6a 28                	push   $0x28
  jmp alltraps
80107a1f:	e9 52 f7 ff ff       	jmp    80107176 <alltraps>

80107a24 <vector41>:
.globl vector41
vector41:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $41
80107a26:	6a 29                	push   $0x29
  jmp alltraps
80107a28:	e9 49 f7 ff ff       	jmp    80107176 <alltraps>

80107a2d <vector42>:
.globl vector42
vector42:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $42
80107a2f:	6a 2a                	push   $0x2a
  jmp alltraps
80107a31:	e9 40 f7 ff ff       	jmp    80107176 <alltraps>

80107a36 <vector43>:
.globl vector43
vector43:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $43
80107a38:	6a 2b                	push   $0x2b
  jmp alltraps
80107a3a:	e9 37 f7 ff ff       	jmp    80107176 <alltraps>

80107a3f <vector44>:
.globl vector44
vector44:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $44
80107a41:	6a 2c                	push   $0x2c
  jmp alltraps
80107a43:	e9 2e f7 ff ff       	jmp    80107176 <alltraps>

80107a48 <vector45>:
.globl vector45
vector45:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $45
80107a4a:	6a 2d                	push   $0x2d
  jmp alltraps
80107a4c:	e9 25 f7 ff ff       	jmp    80107176 <alltraps>

80107a51 <vector46>:
.globl vector46
vector46:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $46
80107a53:	6a 2e                	push   $0x2e
  jmp alltraps
80107a55:	e9 1c f7 ff ff       	jmp    80107176 <alltraps>

80107a5a <vector47>:
.globl vector47
vector47:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $47
80107a5c:	6a 2f                	push   $0x2f
  jmp alltraps
80107a5e:	e9 13 f7 ff ff       	jmp    80107176 <alltraps>

80107a63 <vector48>:
.globl vector48
vector48:
  pushl $0
80107a63:	6a 00                	push   $0x0
  pushl $48
80107a65:	6a 30                	push   $0x30
  jmp alltraps
80107a67:	e9 0a f7 ff ff       	jmp    80107176 <alltraps>

80107a6c <vector49>:
.globl vector49
vector49:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $49
80107a6e:	6a 31                	push   $0x31
  jmp alltraps
80107a70:	e9 01 f7 ff ff       	jmp    80107176 <alltraps>

80107a75 <vector50>:
.globl vector50
vector50:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $50
80107a77:	6a 32                	push   $0x32
  jmp alltraps
80107a79:	e9 f8 f6 ff ff       	jmp    80107176 <alltraps>

80107a7e <vector51>:
.globl vector51
vector51:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $51
80107a80:	6a 33                	push   $0x33
  jmp alltraps
80107a82:	e9 ef f6 ff ff       	jmp    80107176 <alltraps>

80107a87 <vector52>:
.globl vector52
vector52:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $52
80107a89:	6a 34                	push   $0x34
  jmp alltraps
80107a8b:	e9 e6 f6 ff ff       	jmp    80107176 <alltraps>

80107a90 <vector53>:
.globl vector53
vector53:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $53
80107a92:	6a 35                	push   $0x35
  jmp alltraps
80107a94:	e9 dd f6 ff ff       	jmp    80107176 <alltraps>

80107a99 <vector54>:
.globl vector54
vector54:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $54
80107a9b:	6a 36                	push   $0x36
  jmp alltraps
80107a9d:	e9 d4 f6 ff ff       	jmp    80107176 <alltraps>

80107aa2 <vector55>:
.globl vector55
vector55:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $55
80107aa4:	6a 37                	push   $0x37
  jmp alltraps
80107aa6:	e9 cb f6 ff ff       	jmp    80107176 <alltraps>

80107aab <vector56>:
.globl vector56
vector56:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $56
80107aad:	6a 38                	push   $0x38
  jmp alltraps
80107aaf:	e9 c2 f6 ff ff       	jmp    80107176 <alltraps>

80107ab4 <vector57>:
.globl vector57
vector57:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $57
80107ab6:	6a 39                	push   $0x39
  jmp alltraps
80107ab8:	e9 b9 f6 ff ff       	jmp    80107176 <alltraps>

80107abd <vector58>:
.globl vector58
vector58:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $58
80107abf:	6a 3a                	push   $0x3a
  jmp alltraps
80107ac1:	e9 b0 f6 ff ff       	jmp    80107176 <alltraps>

80107ac6 <vector59>:
.globl vector59
vector59:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $59
80107ac8:	6a 3b                	push   $0x3b
  jmp alltraps
80107aca:	e9 a7 f6 ff ff       	jmp    80107176 <alltraps>

80107acf <vector60>:
.globl vector60
vector60:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $60
80107ad1:	6a 3c                	push   $0x3c
  jmp alltraps
80107ad3:	e9 9e f6 ff ff       	jmp    80107176 <alltraps>

80107ad8 <vector61>:
.globl vector61
vector61:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $61
80107ada:	6a 3d                	push   $0x3d
  jmp alltraps
80107adc:	e9 95 f6 ff ff       	jmp    80107176 <alltraps>

80107ae1 <vector62>:
.globl vector62
vector62:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $62
80107ae3:	6a 3e                	push   $0x3e
  jmp alltraps
80107ae5:	e9 8c f6 ff ff       	jmp    80107176 <alltraps>

80107aea <vector63>:
.globl vector63
vector63:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $63
80107aec:	6a 3f                	push   $0x3f
  jmp alltraps
80107aee:	e9 83 f6 ff ff       	jmp    80107176 <alltraps>

80107af3 <vector64>:
.globl vector64
vector64:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $64
80107af5:	6a 40                	push   $0x40
  jmp alltraps
80107af7:	e9 7a f6 ff ff       	jmp    80107176 <alltraps>

80107afc <vector65>:
.globl vector65
vector65:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $65
80107afe:	6a 41                	push   $0x41
  jmp alltraps
80107b00:	e9 71 f6 ff ff       	jmp    80107176 <alltraps>

80107b05 <vector66>:
.globl vector66
vector66:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $66
80107b07:	6a 42                	push   $0x42
  jmp alltraps
80107b09:	e9 68 f6 ff ff       	jmp    80107176 <alltraps>

80107b0e <vector67>:
.globl vector67
vector67:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $67
80107b10:	6a 43                	push   $0x43
  jmp alltraps
80107b12:	e9 5f f6 ff ff       	jmp    80107176 <alltraps>

80107b17 <vector68>:
.globl vector68
vector68:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $68
80107b19:	6a 44                	push   $0x44
  jmp alltraps
80107b1b:	e9 56 f6 ff ff       	jmp    80107176 <alltraps>

80107b20 <vector69>:
.globl vector69
vector69:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $69
80107b22:	6a 45                	push   $0x45
  jmp alltraps
80107b24:	e9 4d f6 ff ff       	jmp    80107176 <alltraps>

80107b29 <vector70>:
.globl vector70
vector70:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $70
80107b2b:	6a 46                	push   $0x46
  jmp alltraps
80107b2d:	e9 44 f6 ff ff       	jmp    80107176 <alltraps>

80107b32 <vector71>:
.globl vector71
vector71:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $71
80107b34:	6a 47                	push   $0x47
  jmp alltraps
80107b36:	e9 3b f6 ff ff       	jmp    80107176 <alltraps>

80107b3b <vector72>:
.globl vector72
vector72:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $72
80107b3d:	6a 48                	push   $0x48
  jmp alltraps
80107b3f:	e9 32 f6 ff ff       	jmp    80107176 <alltraps>

80107b44 <vector73>:
.globl vector73
vector73:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $73
80107b46:	6a 49                	push   $0x49
  jmp alltraps
80107b48:	e9 29 f6 ff ff       	jmp    80107176 <alltraps>

80107b4d <vector74>:
.globl vector74
vector74:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $74
80107b4f:	6a 4a                	push   $0x4a
  jmp alltraps
80107b51:	e9 20 f6 ff ff       	jmp    80107176 <alltraps>

80107b56 <vector75>:
.globl vector75
vector75:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $75
80107b58:	6a 4b                	push   $0x4b
  jmp alltraps
80107b5a:	e9 17 f6 ff ff       	jmp    80107176 <alltraps>

80107b5f <vector76>:
.globl vector76
vector76:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $76
80107b61:	6a 4c                	push   $0x4c
  jmp alltraps
80107b63:	e9 0e f6 ff ff       	jmp    80107176 <alltraps>

80107b68 <vector77>:
.globl vector77
vector77:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $77
80107b6a:	6a 4d                	push   $0x4d
  jmp alltraps
80107b6c:	e9 05 f6 ff ff       	jmp    80107176 <alltraps>

80107b71 <vector78>:
.globl vector78
vector78:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $78
80107b73:	6a 4e                	push   $0x4e
  jmp alltraps
80107b75:	e9 fc f5 ff ff       	jmp    80107176 <alltraps>

80107b7a <vector79>:
.globl vector79
vector79:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $79
80107b7c:	6a 4f                	push   $0x4f
  jmp alltraps
80107b7e:	e9 f3 f5 ff ff       	jmp    80107176 <alltraps>

80107b83 <vector80>:
.globl vector80
vector80:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $80
80107b85:	6a 50                	push   $0x50
  jmp alltraps
80107b87:	e9 ea f5 ff ff       	jmp    80107176 <alltraps>

80107b8c <vector81>:
.globl vector81
vector81:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $81
80107b8e:	6a 51                	push   $0x51
  jmp alltraps
80107b90:	e9 e1 f5 ff ff       	jmp    80107176 <alltraps>

80107b95 <vector82>:
.globl vector82
vector82:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $82
80107b97:	6a 52                	push   $0x52
  jmp alltraps
80107b99:	e9 d8 f5 ff ff       	jmp    80107176 <alltraps>

80107b9e <vector83>:
.globl vector83
vector83:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $83
80107ba0:	6a 53                	push   $0x53
  jmp alltraps
80107ba2:	e9 cf f5 ff ff       	jmp    80107176 <alltraps>

80107ba7 <vector84>:
.globl vector84
vector84:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $84
80107ba9:	6a 54                	push   $0x54
  jmp alltraps
80107bab:	e9 c6 f5 ff ff       	jmp    80107176 <alltraps>

80107bb0 <vector85>:
.globl vector85
vector85:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $85
80107bb2:	6a 55                	push   $0x55
  jmp alltraps
80107bb4:	e9 bd f5 ff ff       	jmp    80107176 <alltraps>

80107bb9 <vector86>:
.globl vector86
vector86:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $86
80107bbb:	6a 56                	push   $0x56
  jmp alltraps
80107bbd:	e9 b4 f5 ff ff       	jmp    80107176 <alltraps>

80107bc2 <vector87>:
.globl vector87
vector87:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $87
80107bc4:	6a 57                	push   $0x57
  jmp alltraps
80107bc6:	e9 ab f5 ff ff       	jmp    80107176 <alltraps>

80107bcb <vector88>:
.globl vector88
vector88:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $88
80107bcd:	6a 58                	push   $0x58
  jmp alltraps
80107bcf:	e9 a2 f5 ff ff       	jmp    80107176 <alltraps>

80107bd4 <vector89>:
.globl vector89
vector89:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $89
80107bd6:	6a 59                	push   $0x59
  jmp alltraps
80107bd8:	e9 99 f5 ff ff       	jmp    80107176 <alltraps>

80107bdd <vector90>:
.globl vector90
vector90:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $90
80107bdf:	6a 5a                	push   $0x5a
  jmp alltraps
80107be1:	e9 90 f5 ff ff       	jmp    80107176 <alltraps>

80107be6 <vector91>:
.globl vector91
vector91:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $91
80107be8:	6a 5b                	push   $0x5b
  jmp alltraps
80107bea:	e9 87 f5 ff ff       	jmp    80107176 <alltraps>

80107bef <vector92>:
.globl vector92
vector92:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $92
80107bf1:	6a 5c                	push   $0x5c
  jmp alltraps
80107bf3:	e9 7e f5 ff ff       	jmp    80107176 <alltraps>

80107bf8 <vector93>:
.globl vector93
vector93:
  pushl $0
80107bf8:	6a 00                	push   $0x0
  pushl $93
80107bfa:	6a 5d                	push   $0x5d
  jmp alltraps
80107bfc:	e9 75 f5 ff ff       	jmp    80107176 <alltraps>

80107c01 <vector94>:
.globl vector94
vector94:
  pushl $0
80107c01:	6a 00                	push   $0x0
  pushl $94
80107c03:	6a 5e                	push   $0x5e
  jmp alltraps
80107c05:	e9 6c f5 ff ff       	jmp    80107176 <alltraps>

80107c0a <vector95>:
.globl vector95
vector95:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $95
80107c0c:	6a 5f                	push   $0x5f
  jmp alltraps
80107c0e:	e9 63 f5 ff ff       	jmp    80107176 <alltraps>

80107c13 <vector96>:
.globl vector96
vector96:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $96
80107c15:	6a 60                	push   $0x60
  jmp alltraps
80107c17:	e9 5a f5 ff ff       	jmp    80107176 <alltraps>

80107c1c <vector97>:
.globl vector97
vector97:
  pushl $0
80107c1c:	6a 00                	push   $0x0
  pushl $97
80107c1e:	6a 61                	push   $0x61
  jmp alltraps
80107c20:	e9 51 f5 ff ff       	jmp    80107176 <alltraps>

80107c25 <vector98>:
.globl vector98
vector98:
  pushl $0
80107c25:	6a 00                	push   $0x0
  pushl $98
80107c27:	6a 62                	push   $0x62
  jmp alltraps
80107c29:	e9 48 f5 ff ff       	jmp    80107176 <alltraps>

80107c2e <vector99>:
.globl vector99
vector99:
  pushl $0
80107c2e:	6a 00                	push   $0x0
  pushl $99
80107c30:	6a 63                	push   $0x63
  jmp alltraps
80107c32:	e9 3f f5 ff ff       	jmp    80107176 <alltraps>

80107c37 <vector100>:
.globl vector100
vector100:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $100
80107c39:	6a 64                	push   $0x64
  jmp alltraps
80107c3b:	e9 36 f5 ff ff       	jmp    80107176 <alltraps>

80107c40 <vector101>:
.globl vector101
vector101:
  pushl $0
80107c40:	6a 00                	push   $0x0
  pushl $101
80107c42:	6a 65                	push   $0x65
  jmp alltraps
80107c44:	e9 2d f5 ff ff       	jmp    80107176 <alltraps>

80107c49 <vector102>:
.globl vector102
vector102:
  pushl $0
80107c49:	6a 00                	push   $0x0
  pushl $102
80107c4b:	6a 66                	push   $0x66
  jmp alltraps
80107c4d:	e9 24 f5 ff ff       	jmp    80107176 <alltraps>

80107c52 <vector103>:
.globl vector103
vector103:
  pushl $0
80107c52:	6a 00                	push   $0x0
  pushl $103
80107c54:	6a 67                	push   $0x67
  jmp alltraps
80107c56:	e9 1b f5 ff ff       	jmp    80107176 <alltraps>

80107c5b <vector104>:
.globl vector104
vector104:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $104
80107c5d:	6a 68                	push   $0x68
  jmp alltraps
80107c5f:	e9 12 f5 ff ff       	jmp    80107176 <alltraps>

80107c64 <vector105>:
.globl vector105
vector105:
  pushl $0
80107c64:	6a 00                	push   $0x0
  pushl $105
80107c66:	6a 69                	push   $0x69
  jmp alltraps
80107c68:	e9 09 f5 ff ff       	jmp    80107176 <alltraps>

80107c6d <vector106>:
.globl vector106
vector106:
  pushl $0
80107c6d:	6a 00                	push   $0x0
  pushl $106
80107c6f:	6a 6a                	push   $0x6a
  jmp alltraps
80107c71:	e9 00 f5 ff ff       	jmp    80107176 <alltraps>

80107c76 <vector107>:
.globl vector107
vector107:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $107
80107c78:	6a 6b                	push   $0x6b
  jmp alltraps
80107c7a:	e9 f7 f4 ff ff       	jmp    80107176 <alltraps>

80107c7f <vector108>:
.globl vector108
vector108:
  pushl $0
80107c7f:	6a 00                	push   $0x0
  pushl $108
80107c81:	6a 6c                	push   $0x6c
  jmp alltraps
80107c83:	e9 ee f4 ff ff       	jmp    80107176 <alltraps>

80107c88 <vector109>:
.globl vector109
vector109:
  pushl $0
80107c88:	6a 00                	push   $0x0
  pushl $109
80107c8a:	6a 6d                	push   $0x6d
  jmp alltraps
80107c8c:	e9 e5 f4 ff ff       	jmp    80107176 <alltraps>

80107c91 <vector110>:
.globl vector110
vector110:
  pushl $0
80107c91:	6a 00                	push   $0x0
  pushl $110
80107c93:	6a 6e                	push   $0x6e
  jmp alltraps
80107c95:	e9 dc f4 ff ff       	jmp    80107176 <alltraps>

80107c9a <vector111>:
.globl vector111
vector111:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $111
80107c9c:	6a 6f                	push   $0x6f
  jmp alltraps
80107c9e:	e9 d3 f4 ff ff       	jmp    80107176 <alltraps>

80107ca3 <vector112>:
.globl vector112
vector112:
  pushl $0
80107ca3:	6a 00                	push   $0x0
  pushl $112
80107ca5:	6a 70                	push   $0x70
  jmp alltraps
80107ca7:	e9 ca f4 ff ff       	jmp    80107176 <alltraps>

80107cac <vector113>:
.globl vector113
vector113:
  pushl $0
80107cac:	6a 00                	push   $0x0
  pushl $113
80107cae:	6a 71                	push   $0x71
  jmp alltraps
80107cb0:	e9 c1 f4 ff ff       	jmp    80107176 <alltraps>

80107cb5 <vector114>:
.globl vector114
vector114:
  pushl $0
80107cb5:	6a 00                	push   $0x0
  pushl $114
80107cb7:	6a 72                	push   $0x72
  jmp alltraps
80107cb9:	e9 b8 f4 ff ff       	jmp    80107176 <alltraps>

80107cbe <vector115>:
.globl vector115
vector115:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $115
80107cc0:	6a 73                	push   $0x73
  jmp alltraps
80107cc2:	e9 af f4 ff ff       	jmp    80107176 <alltraps>

80107cc7 <vector116>:
.globl vector116
vector116:
  pushl $0
80107cc7:	6a 00                	push   $0x0
  pushl $116
80107cc9:	6a 74                	push   $0x74
  jmp alltraps
80107ccb:	e9 a6 f4 ff ff       	jmp    80107176 <alltraps>

80107cd0 <vector117>:
.globl vector117
vector117:
  pushl $0
80107cd0:	6a 00                	push   $0x0
  pushl $117
80107cd2:	6a 75                	push   $0x75
  jmp alltraps
80107cd4:	e9 9d f4 ff ff       	jmp    80107176 <alltraps>

80107cd9 <vector118>:
.globl vector118
vector118:
  pushl $0
80107cd9:	6a 00                	push   $0x0
  pushl $118
80107cdb:	6a 76                	push   $0x76
  jmp alltraps
80107cdd:	e9 94 f4 ff ff       	jmp    80107176 <alltraps>

80107ce2 <vector119>:
.globl vector119
vector119:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $119
80107ce4:	6a 77                	push   $0x77
  jmp alltraps
80107ce6:	e9 8b f4 ff ff       	jmp    80107176 <alltraps>

80107ceb <vector120>:
.globl vector120
vector120:
  pushl $0
80107ceb:	6a 00                	push   $0x0
  pushl $120
80107ced:	6a 78                	push   $0x78
  jmp alltraps
80107cef:	e9 82 f4 ff ff       	jmp    80107176 <alltraps>

80107cf4 <vector121>:
.globl vector121
vector121:
  pushl $0
80107cf4:	6a 00                	push   $0x0
  pushl $121
80107cf6:	6a 79                	push   $0x79
  jmp alltraps
80107cf8:	e9 79 f4 ff ff       	jmp    80107176 <alltraps>

80107cfd <vector122>:
.globl vector122
vector122:
  pushl $0
80107cfd:	6a 00                	push   $0x0
  pushl $122
80107cff:	6a 7a                	push   $0x7a
  jmp alltraps
80107d01:	e9 70 f4 ff ff       	jmp    80107176 <alltraps>

80107d06 <vector123>:
.globl vector123
vector123:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $123
80107d08:	6a 7b                	push   $0x7b
  jmp alltraps
80107d0a:	e9 67 f4 ff ff       	jmp    80107176 <alltraps>

80107d0f <vector124>:
.globl vector124
vector124:
  pushl $0
80107d0f:	6a 00                	push   $0x0
  pushl $124
80107d11:	6a 7c                	push   $0x7c
  jmp alltraps
80107d13:	e9 5e f4 ff ff       	jmp    80107176 <alltraps>

80107d18 <vector125>:
.globl vector125
vector125:
  pushl $0
80107d18:	6a 00                	push   $0x0
  pushl $125
80107d1a:	6a 7d                	push   $0x7d
  jmp alltraps
80107d1c:	e9 55 f4 ff ff       	jmp    80107176 <alltraps>

80107d21 <vector126>:
.globl vector126
vector126:
  pushl $0
80107d21:	6a 00                	push   $0x0
  pushl $126
80107d23:	6a 7e                	push   $0x7e
  jmp alltraps
80107d25:	e9 4c f4 ff ff       	jmp    80107176 <alltraps>

80107d2a <vector127>:
.globl vector127
vector127:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $127
80107d2c:	6a 7f                	push   $0x7f
  jmp alltraps
80107d2e:	e9 43 f4 ff ff       	jmp    80107176 <alltraps>

80107d33 <vector128>:
.globl vector128
vector128:
  pushl $0
80107d33:	6a 00                	push   $0x0
  pushl $128
80107d35:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107d3a:	e9 37 f4 ff ff       	jmp    80107176 <alltraps>

80107d3f <vector129>:
.globl vector129
vector129:
  pushl $0
80107d3f:	6a 00                	push   $0x0
  pushl $129
80107d41:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107d46:	e9 2b f4 ff ff       	jmp    80107176 <alltraps>

80107d4b <vector130>:
.globl vector130
vector130:
  pushl $0
80107d4b:	6a 00                	push   $0x0
  pushl $130
80107d4d:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107d52:	e9 1f f4 ff ff       	jmp    80107176 <alltraps>

80107d57 <vector131>:
.globl vector131
vector131:
  pushl $0
80107d57:	6a 00                	push   $0x0
  pushl $131
80107d59:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107d5e:	e9 13 f4 ff ff       	jmp    80107176 <alltraps>

80107d63 <vector132>:
.globl vector132
vector132:
  pushl $0
80107d63:	6a 00                	push   $0x0
  pushl $132
80107d65:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107d6a:	e9 07 f4 ff ff       	jmp    80107176 <alltraps>

80107d6f <vector133>:
.globl vector133
vector133:
  pushl $0
80107d6f:	6a 00                	push   $0x0
  pushl $133
80107d71:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107d76:	e9 fb f3 ff ff       	jmp    80107176 <alltraps>

80107d7b <vector134>:
.globl vector134
vector134:
  pushl $0
80107d7b:	6a 00                	push   $0x0
  pushl $134
80107d7d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107d82:	e9 ef f3 ff ff       	jmp    80107176 <alltraps>

80107d87 <vector135>:
.globl vector135
vector135:
  pushl $0
80107d87:	6a 00                	push   $0x0
  pushl $135
80107d89:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107d8e:	e9 e3 f3 ff ff       	jmp    80107176 <alltraps>

80107d93 <vector136>:
.globl vector136
vector136:
  pushl $0
80107d93:	6a 00                	push   $0x0
  pushl $136
80107d95:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107d9a:	e9 d7 f3 ff ff       	jmp    80107176 <alltraps>

80107d9f <vector137>:
.globl vector137
vector137:
  pushl $0
80107d9f:	6a 00                	push   $0x0
  pushl $137
80107da1:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107da6:	e9 cb f3 ff ff       	jmp    80107176 <alltraps>

80107dab <vector138>:
.globl vector138
vector138:
  pushl $0
80107dab:	6a 00                	push   $0x0
  pushl $138
80107dad:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107db2:	e9 bf f3 ff ff       	jmp    80107176 <alltraps>

80107db7 <vector139>:
.globl vector139
vector139:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $139
80107db9:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107dbe:	e9 b3 f3 ff ff       	jmp    80107176 <alltraps>

80107dc3 <vector140>:
.globl vector140
vector140:
  pushl $0
80107dc3:	6a 00                	push   $0x0
  pushl $140
80107dc5:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107dca:	e9 a7 f3 ff ff       	jmp    80107176 <alltraps>

80107dcf <vector141>:
.globl vector141
vector141:
  pushl $0
80107dcf:	6a 00                	push   $0x0
  pushl $141
80107dd1:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107dd6:	e9 9b f3 ff ff       	jmp    80107176 <alltraps>

80107ddb <vector142>:
.globl vector142
vector142:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $142
80107ddd:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107de2:	e9 8f f3 ff ff       	jmp    80107176 <alltraps>

80107de7 <vector143>:
.globl vector143
vector143:
  pushl $0
80107de7:	6a 00                	push   $0x0
  pushl $143
80107de9:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107dee:	e9 83 f3 ff ff       	jmp    80107176 <alltraps>

80107df3 <vector144>:
.globl vector144
vector144:
  pushl $0
80107df3:	6a 00                	push   $0x0
  pushl $144
80107df5:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107dfa:	e9 77 f3 ff ff       	jmp    80107176 <alltraps>

80107dff <vector145>:
.globl vector145
vector145:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $145
80107e01:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107e06:	e9 6b f3 ff ff       	jmp    80107176 <alltraps>

80107e0b <vector146>:
.globl vector146
vector146:
  pushl $0
80107e0b:	6a 00                	push   $0x0
  pushl $146
80107e0d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107e12:	e9 5f f3 ff ff       	jmp    80107176 <alltraps>

80107e17 <vector147>:
.globl vector147
vector147:
  pushl $0
80107e17:	6a 00                	push   $0x0
  pushl $147
80107e19:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107e1e:	e9 53 f3 ff ff       	jmp    80107176 <alltraps>

80107e23 <vector148>:
.globl vector148
vector148:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $148
80107e25:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107e2a:	e9 47 f3 ff ff       	jmp    80107176 <alltraps>

80107e2f <vector149>:
.globl vector149
vector149:
  pushl $0
80107e2f:	6a 00                	push   $0x0
  pushl $149
80107e31:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107e36:	e9 3b f3 ff ff       	jmp    80107176 <alltraps>

80107e3b <vector150>:
.globl vector150
vector150:
  pushl $0
80107e3b:	6a 00                	push   $0x0
  pushl $150
80107e3d:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107e42:	e9 2f f3 ff ff       	jmp    80107176 <alltraps>

80107e47 <vector151>:
.globl vector151
vector151:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $151
80107e49:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107e4e:	e9 23 f3 ff ff       	jmp    80107176 <alltraps>

80107e53 <vector152>:
.globl vector152
vector152:
  pushl $0
80107e53:	6a 00                	push   $0x0
  pushl $152
80107e55:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107e5a:	e9 17 f3 ff ff       	jmp    80107176 <alltraps>

80107e5f <vector153>:
.globl vector153
vector153:
  pushl $0
80107e5f:	6a 00                	push   $0x0
  pushl $153
80107e61:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107e66:	e9 0b f3 ff ff       	jmp    80107176 <alltraps>

80107e6b <vector154>:
.globl vector154
vector154:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $154
80107e6d:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107e72:	e9 ff f2 ff ff       	jmp    80107176 <alltraps>

80107e77 <vector155>:
.globl vector155
vector155:
  pushl $0
80107e77:	6a 00                	push   $0x0
  pushl $155
80107e79:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107e7e:	e9 f3 f2 ff ff       	jmp    80107176 <alltraps>

80107e83 <vector156>:
.globl vector156
vector156:
  pushl $0
80107e83:	6a 00                	push   $0x0
  pushl $156
80107e85:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107e8a:	e9 e7 f2 ff ff       	jmp    80107176 <alltraps>

80107e8f <vector157>:
.globl vector157
vector157:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $157
80107e91:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107e96:	e9 db f2 ff ff       	jmp    80107176 <alltraps>

80107e9b <vector158>:
.globl vector158
vector158:
  pushl $0
80107e9b:	6a 00                	push   $0x0
  pushl $158
80107e9d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107ea2:	e9 cf f2 ff ff       	jmp    80107176 <alltraps>

80107ea7 <vector159>:
.globl vector159
vector159:
  pushl $0
80107ea7:	6a 00                	push   $0x0
  pushl $159
80107ea9:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107eae:	e9 c3 f2 ff ff       	jmp    80107176 <alltraps>

80107eb3 <vector160>:
.globl vector160
vector160:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $160
80107eb5:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107eba:	e9 b7 f2 ff ff       	jmp    80107176 <alltraps>

80107ebf <vector161>:
.globl vector161
vector161:
  pushl $0
80107ebf:	6a 00                	push   $0x0
  pushl $161
80107ec1:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107ec6:	e9 ab f2 ff ff       	jmp    80107176 <alltraps>

80107ecb <vector162>:
.globl vector162
vector162:
  pushl $0
80107ecb:	6a 00                	push   $0x0
  pushl $162
80107ecd:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107ed2:	e9 9f f2 ff ff       	jmp    80107176 <alltraps>

80107ed7 <vector163>:
.globl vector163
vector163:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $163
80107ed9:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107ede:	e9 93 f2 ff ff       	jmp    80107176 <alltraps>

80107ee3 <vector164>:
.globl vector164
vector164:
  pushl $0
80107ee3:	6a 00                	push   $0x0
  pushl $164
80107ee5:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107eea:	e9 87 f2 ff ff       	jmp    80107176 <alltraps>

80107eef <vector165>:
.globl vector165
vector165:
  pushl $0
80107eef:	6a 00                	push   $0x0
  pushl $165
80107ef1:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107ef6:	e9 7b f2 ff ff       	jmp    80107176 <alltraps>

80107efb <vector166>:
.globl vector166
vector166:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $166
80107efd:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107f02:	e9 6f f2 ff ff       	jmp    80107176 <alltraps>

80107f07 <vector167>:
.globl vector167
vector167:
  pushl $0
80107f07:	6a 00                	push   $0x0
  pushl $167
80107f09:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107f0e:	e9 63 f2 ff ff       	jmp    80107176 <alltraps>

80107f13 <vector168>:
.globl vector168
vector168:
  pushl $0
80107f13:	6a 00                	push   $0x0
  pushl $168
80107f15:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107f1a:	e9 57 f2 ff ff       	jmp    80107176 <alltraps>

80107f1f <vector169>:
.globl vector169
vector169:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $169
80107f21:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107f26:	e9 4b f2 ff ff       	jmp    80107176 <alltraps>

80107f2b <vector170>:
.globl vector170
vector170:
  pushl $0
80107f2b:	6a 00                	push   $0x0
  pushl $170
80107f2d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107f32:	e9 3f f2 ff ff       	jmp    80107176 <alltraps>

80107f37 <vector171>:
.globl vector171
vector171:
  pushl $0
80107f37:	6a 00                	push   $0x0
  pushl $171
80107f39:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107f3e:	e9 33 f2 ff ff       	jmp    80107176 <alltraps>

80107f43 <vector172>:
.globl vector172
vector172:
  pushl $0
80107f43:	6a 00                	push   $0x0
  pushl $172
80107f45:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107f4a:	e9 27 f2 ff ff       	jmp    80107176 <alltraps>

80107f4f <vector173>:
.globl vector173
vector173:
  pushl $0
80107f4f:	6a 00                	push   $0x0
  pushl $173
80107f51:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107f56:	e9 1b f2 ff ff       	jmp    80107176 <alltraps>

80107f5b <vector174>:
.globl vector174
vector174:
  pushl $0
80107f5b:	6a 00                	push   $0x0
  pushl $174
80107f5d:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107f62:	e9 0f f2 ff ff       	jmp    80107176 <alltraps>

80107f67 <vector175>:
.globl vector175
vector175:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $175
80107f69:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107f6e:	e9 03 f2 ff ff       	jmp    80107176 <alltraps>

80107f73 <vector176>:
.globl vector176
vector176:
  pushl $0
80107f73:	6a 00                	push   $0x0
  pushl $176
80107f75:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107f7a:	e9 f7 f1 ff ff       	jmp    80107176 <alltraps>

80107f7f <vector177>:
.globl vector177
vector177:
  pushl $0
80107f7f:	6a 00                	push   $0x0
  pushl $177
80107f81:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107f86:	e9 eb f1 ff ff       	jmp    80107176 <alltraps>

80107f8b <vector178>:
.globl vector178
vector178:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $178
80107f8d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107f92:	e9 df f1 ff ff       	jmp    80107176 <alltraps>

80107f97 <vector179>:
.globl vector179
vector179:
  pushl $0
80107f97:	6a 00                	push   $0x0
  pushl $179
80107f99:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107f9e:	e9 d3 f1 ff ff       	jmp    80107176 <alltraps>

80107fa3 <vector180>:
.globl vector180
vector180:
  pushl $0
80107fa3:	6a 00                	push   $0x0
  pushl $180
80107fa5:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107faa:	e9 c7 f1 ff ff       	jmp    80107176 <alltraps>

80107faf <vector181>:
.globl vector181
vector181:
  pushl $0
80107faf:	6a 00                	push   $0x0
  pushl $181
80107fb1:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107fb6:	e9 bb f1 ff ff       	jmp    80107176 <alltraps>

80107fbb <vector182>:
.globl vector182
vector182:
  pushl $0
80107fbb:	6a 00                	push   $0x0
  pushl $182
80107fbd:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107fc2:	e9 af f1 ff ff       	jmp    80107176 <alltraps>

80107fc7 <vector183>:
.globl vector183
vector183:
  pushl $0
80107fc7:	6a 00                	push   $0x0
  pushl $183
80107fc9:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107fce:	e9 a3 f1 ff ff       	jmp    80107176 <alltraps>

80107fd3 <vector184>:
.globl vector184
vector184:
  pushl $0
80107fd3:	6a 00                	push   $0x0
  pushl $184
80107fd5:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107fda:	e9 97 f1 ff ff       	jmp    80107176 <alltraps>

80107fdf <vector185>:
.globl vector185
vector185:
  pushl $0
80107fdf:	6a 00                	push   $0x0
  pushl $185
80107fe1:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107fe6:	e9 8b f1 ff ff       	jmp    80107176 <alltraps>

80107feb <vector186>:
.globl vector186
vector186:
  pushl $0
80107feb:	6a 00                	push   $0x0
  pushl $186
80107fed:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107ff2:	e9 7f f1 ff ff       	jmp    80107176 <alltraps>

80107ff7 <vector187>:
.globl vector187
vector187:
  pushl $0
80107ff7:	6a 00                	push   $0x0
  pushl $187
80107ff9:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107ffe:	e9 73 f1 ff ff       	jmp    80107176 <alltraps>

80108003 <vector188>:
.globl vector188
vector188:
  pushl $0
80108003:	6a 00                	push   $0x0
  pushl $188
80108005:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010800a:	e9 67 f1 ff ff       	jmp    80107176 <alltraps>

8010800f <vector189>:
.globl vector189
vector189:
  pushl $0
8010800f:	6a 00                	push   $0x0
  pushl $189
80108011:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108016:	e9 5b f1 ff ff       	jmp    80107176 <alltraps>

8010801b <vector190>:
.globl vector190
vector190:
  pushl $0
8010801b:	6a 00                	push   $0x0
  pushl $190
8010801d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108022:	e9 4f f1 ff ff       	jmp    80107176 <alltraps>

80108027 <vector191>:
.globl vector191
vector191:
  pushl $0
80108027:	6a 00                	push   $0x0
  pushl $191
80108029:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010802e:	e9 43 f1 ff ff       	jmp    80107176 <alltraps>

80108033 <vector192>:
.globl vector192
vector192:
  pushl $0
80108033:	6a 00                	push   $0x0
  pushl $192
80108035:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010803a:	e9 37 f1 ff ff       	jmp    80107176 <alltraps>

8010803f <vector193>:
.globl vector193
vector193:
  pushl $0
8010803f:	6a 00                	push   $0x0
  pushl $193
80108041:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108046:	e9 2b f1 ff ff       	jmp    80107176 <alltraps>

8010804b <vector194>:
.globl vector194
vector194:
  pushl $0
8010804b:	6a 00                	push   $0x0
  pushl $194
8010804d:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108052:	e9 1f f1 ff ff       	jmp    80107176 <alltraps>

80108057 <vector195>:
.globl vector195
vector195:
  pushl $0
80108057:	6a 00                	push   $0x0
  pushl $195
80108059:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010805e:	e9 13 f1 ff ff       	jmp    80107176 <alltraps>

80108063 <vector196>:
.globl vector196
vector196:
  pushl $0
80108063:	6a 00                	push   $0x0
  pushl $196
80108065:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010806a:	e9 07 f1 ff ff       	jmp    80107176 <alltraps>

8010806f <vector197>:
.globl vector197
vector197:
  pushl $0
8010806f:	6a 00                	push   $0x0
  pushl $197
80108071:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108076:	e9 fb f0 ff ff       	jmp    80107176 <alltraps>

8010807b <vector198>:
.globl vector198
vector198:
  pushl $0
8010807b:	6a 00                	push   $0x0
  pushl $198
8010807d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108082:	e9 ef f0 ff ff       	jmp    80107176 <alltraps>

80108087 <vector199>:
.globl vector199
vector199:
  pushl $0
80108087:	6a 00                	push   $0x0
  pushl $199
80108089:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010808e:	e9 e3 f0 ff ff       	jmp    80107176 <alltraps>

80108093 <vector200>:
.globl vector200
vector200:
  pushl $0
80108093:	6a 00                	push   $0x0
  pushl $200
80108095:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010809a:	e9 d7 f0 ff ff       	jmp    80107176 <alltraps>

8010809f <vector201>:
.globl vector201
vector201:
  pushl $0
8010809f:	6a 00                	push   $0x0
  pushl $201
801080a1:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801080a6:	e9 cb f0 ff ff       	jmp    80107176 <alltraps>

801080ab <vector202>:
.globl vector202
vector202:
  pushl $0
801080ab:	6a 00                	push   $0x0
  pushl $202
801080ad:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801080b2:	e9 bf f0 ff ff       	jmp    80107176 <alltraps>

801080b7 <vector203>:
.globl vector203
vector203:
  pushl $0
801080b7:	6a 00                	push   $0x0
  pushl $203
801080b9:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801080be:	e9 b3 f0 ff ff       	jmp    80107176 <alltraps>

801080c3 <vector204>:
.globl vector204
vector204:
  pushl $0
801080c3:	6a 00                	push   $0x0
  pushl $204
801080c5:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801080ca:	e9 a7 f0 ff ff       	jmp    80107176 <alltraps>

801080cf <vector205>:
.globl vector205
vector205:
  pushl $0
801080cf:	6a 00                	push   $0x0
  pushl $205
801080d1:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801080d6:	e9 9b f0 ff ff       	jmp    80107176 <alltraps>

801080db <vector206>:
.globl vector206
vector206:
  pushl $0
801080db:	6a 00                	push   $0x0
  pushl $206
801080dd:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801080e2:	e9 8f f0 ff ff       	jmp    80107176 <alltraps>

801080e7 <vector207>:
.globl vector207
vector207:
  pushl $0
801080e7:	6a 00                	push   $0x0
  pushl $207
801080e9:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801080ee:	e9 83 f0 ff ff       	jmp    80107176 <alltraps>

801080f3 <vector208>:
.globl vector208
vector208:
  pushl $0
801080f3:	6a 00                	push   $0x0
  pushl $208
801080f5:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801080fa:	e9 77 f0 ff ff       	jmp    80107176 <alltraps>

801080ff <vector209>:
.globl vector209
vector209:
  pushl $0
801080ff:	6a 00                	push   $0x0
  pushl $209
80108101:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108106:	e9 6b f0 ff ff       	jmp    80107176 <alltraps>

8010810b <vector210>:
.globl vector210
vector210:
  pushl $0
8010810b:	6a 00                	push   $0x0
  pushl $210
8010810d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108112:	e9 5f f0 ff ff       	jmp    80107176 <alltraps>

80108117 <vector211>:
.globl vector211
vector211:
  pushl $0
80108117:	6a 00                	push   $0x0
  pushl $211
80108119:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010811e:	e9 53 f0 ff ff       	jmp    80107176 <alltraps>

80108123 <vector212>:
.globl vector212
vector212:
  pushl $0
80108123:	6a 00                	push   $0x0
  pushl $212
80108125:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010812a:	e9 47 f0 ff ff       	jmp    80107176 <alltraps>

8010812f <vector213>:
.globl vector213
vector213:
  pushl $0
8010812f:	6a 00                	push   $0x0
  pushl $213
80108131:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108136:	e9 3b f0 ff ff       	jmp    80107176 <alltraps>

8010813b <vector214>:
.globl vector214
vector214:
  pushl $0
8010813b:	6a 00                	push   $0x0
  pushl $214
8010813d:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108142:	e9 2f f0 ff ff       	jmp    80107176 <alltraps>

80108147 <vector215>:
.globl vector215
vector215:
  pushl $0
80108147:	6a 00                	push   $0x0
  pushl $215
80108149:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010814e:	e9 23 f0 ff ff       	jmp    80107176 <alltraps>

80108153 <vector216>:
.globl vector216
vector216:
  pushl $0
80108153:	6a 00                	push   $0x0
  pushl $216
80108155:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010815a:	e9 17 f0 ff ff       	jmp    80107176 <alltraps>

8010815f <vector217>:
.globl vector217
vector217:
  pushl $0
8010815f:	6a 00                	push   $0x0
  pushl $217
80108161:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108166:	e9 0b f0 ff ff       	jmp    80107176 <alltraps>

8010816b <vector218>:
.globl vector218
vector218:
  pushl $0
8010816b:	6a 00                	push   $0x0
  pushl $218
8010816d:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108172:	e9 ff ef ff ff       	jmp    80107176 <alltraps>

80108177 <vector219>:
.globl vector219
vector219:
  pushl $0
80108177:	6a 00                	push   $0x0
  pushl $219
80108179:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010817e:	e9 f3 ef ff ff       	jmp    80107176 <alltraps>

80108183 <vector220>:
.globl vector220
vector220:
  pushl $0
80108183:	6a 00                	push   $0x0
  pushl $220
80108185:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010818a:	e9 e7 ef ff ff       	jmp    80107176 <alltraps>

8010818f <vector221>:
.globl vector221
vector221:
  pushl $0
8010818f:	6a 00                	push   $0x0
  pushl $221
80108191:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108196:	e9 db ef ff ff       	jmp    80107176 <alltraps>

8010819b <vector222>:
.globl vector222
vector222:
  pushl $0
8010819b:	6a 00                	push   $0x0
  pushl $222
8010819d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801081a2:	e9 cf ef ff ff       	jmp    80107176 <alltraps>

801081a7 <vector223>:
.globl vector223
vector223:
  pushl $0
801081a7:	6a 00                	push   $0x0
  pushl $223
801081a9:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801081ae:	e9 c3 ef ff ff       	jmp    80107176 <alltraps>

801081b3 <vector224>:
.globl vector224
vector224:
  pushl $0
801081b3:	6a 00                	push   $0x0
  pushl $224
801081b5:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801081ba:	e9 b7 ef ff ff       	jmp    80107176 <alltraps>

801081bf <vector225>:
.globl vector225
vector225:
  pushl $0
801081bf:	6a 00                	push   $0x0
  pushl $225
801081c1:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801081c6:	e9 ab ef ff ff       	jmp    80107176 <alltraps>

801081cb <vector226>:
.globl vector226
vector226:
  pushl $0
801081cb:	6a 00                	push   $0x0
  pushl $226
801081cd:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801081d2:	e9 9f ef ff ff       	jmp    80107176 <alltraps>

801081d7 <vector227>:
.globl vector227
vector227:
  pushl $0
801081d7:	6a 00                	push   $0x0
  pushl $227
801081d9:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801081de:	e9 93 ef ff ff       	jmp    80107176 <alltraps>

801081e3 <vector228>:
.globl vector228
vector228:
  pushl $0
801081e3:	6a 00                	push   $0x0
  pushl $228
801081e5:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801081ea:	e9 87 ef ff ff       	jmp    80107176 <alltraps>

801081ef <vector229>:
.globl vector229
vector229:
  pushl $0
801081ef:	6a 00                	push   $0x0
  pushl $229
801081f1:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801081f6:	e9 7b ef ff ff       	jmp    80107176 <alltraps>

801081fb <vector230>:
.globl vector230
vector230:
  pushl $0
801081fb:	6a 00                	push   $0x0
  pushl $230
801081fd:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108202:	e9 6f ef ff ff       	jmp    80107176 <alltraps>

80108207 <vector231>:
.globl vector231
vector231:
  pushl $0
80108207:	6a 00                	push   $0x0
  pushl $231
80108209:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010820e:	e9 63 ef ff ff       	jmp    80107176 <alltraps>

80108213 <vector232>:
.globl vector232
vector232:
  pushl $0
80108213:	6a 00                	push   $0x0
  pushl $232
80108215:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010821a:	e9 57 ef ff ff       	jmp    80107176 <alltraps>

8010821f <vector233>:
.globl vector233
vector233:
  pushl $0
8010821f:	6a 00                	push   $0x0
  pushl $233
80108221:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108226:	e9 4b ef ff ff       	jmp    80107176 <alltraps>

8010822b <vector234>:
.globl vector234
vector234:
  pushl $0
8010822b:	6a 00                	push   $0x0
  pushl $234
8010822d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108232:	e9 3f ef ff ff       	jmp    80107176 <alltraps>

80108237 <vector235>:
.globl vector235
vector235:
  pushl $0
80108237:	6a 00                	push   $0x0
  pushl $235
80108239:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010823e:	e9 33 ef ff ff       	jmp    80107176 <alltraps>

80108243 <vector236>:
.globl vector236
vector236:
  pushl $0
80108243:	6a 00                	push   $0x0
  pushl $236
80108245:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010824a:	e9 27 ef ff ff       	jmp    80107176 <alltraps>

8010824f <vector237>:
.globl vector237
vector237:
  pushl $0
8010824f:	6a 00                	push   $0x0
  pushl $237
80108251:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108256:	e9 1b ef ff ff       	jmp    80107176 <alltraps>

8010825b <vector238>:
.globl vector238
vector238:
  pushl $0
8010825b:	6a 00                	push   $0x0
  pushl $238
8010825d:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108262:	e9 0f ef ff ff       	jmp    80107176 <alltraps>

80108267 <vector239>:
.globl vector239
vector239:
  pushl $0
80108267:	6a 00                	push   $0x0
  pushl $239
80108269:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010826e:	e9 03 ef ff ff       	jmp    80107176 <alltraps>

80108273 <vector240>:
.globl vector240
vector240:
  pushl $0
80108273:	6a 00                	push   $0x0
  pushl $240
80108275:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010827a:	e9 f7 ee ff ff       	jmp    80107176 <alltraps>

8010827f <vector241>:
.globl vector241
vector241:
  pushl $0
8010827f:	6a 00                	push   $0x0
  pushl $241
80108281:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108286:	e9 eb ee ff ff       	jmp    80107176 <alltraps>

8010828b <vector242>:
.globl vector242
vector242:
  pushl $0
8010828b:	6a 00                	push   $0x0
  pushl $242
8010828d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108292:	e9 df ee ff ff       	jmp    80107176 <alltraps>

80108297 <vector243>:
.globl vector243
vector243:
  pushl $0
80108297:	6a 00                	push   $0x0
  pushl $243
80108299:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010829e:	e9 d3 ee ff ff       	jmp    80107176 <alltraps>

801082a3 <vector244>:
.globl vector244
vector244:
  pushl $0
801082a3:	6a 00                	push   $0x0
  pushl $244
801082a5:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801082aa:	e9 c7 ee ff ff       	jmp    80107176 <alltraps>

801082af <vector245>:
.globl vector245
vector245:
  pushl $0
801082af:	6a 00                	push   $0x0
  pushl $245
801082b1:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801082b6:	e9 bb ee ff ff       	jmp    80107176 <alltraps>

801082bb <vector246>:
.globl vector246
vector246:
  pushl $0
801082bb:	6a 00                	push   $0x0
  pushl $246
801082bd:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801082c2:	e9 af ee ff ff       	jmp    80107176 <alltraps>

801082c7 <vector247>:
.globl vector247
vector247:
  pushl $0
801082c7:	6a 00                	push   $0x0
  pushl $247
801082c9:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801082ce:	e9 a3 ee ff ff       	jmp    80107176 <alltraps>

801082d3 <vector248>:
.globl vector248
vector248:
  pushl $0
801082d3:	6a 00                	push   $0x0
  pushl $248
801082d5:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801082da:	e9 97 ee ff ff       	jmp    80107176 <alltraps>

801082df <vector249>:
.globl vector249
vector249:
  pushl $0
801082df:	6a 00                	push   $0x0
  pushl $249
801082e1:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801082e6:	e9 8b ee ff ff       	jmp    80107176 <alltraps>

801082eb <vector250>:
.globl vector250
vector250:
  pushl $0
801082eb:	6a 00                	push   $0x0
  pushl $250
801082ed:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801082f2:	e9 7f ee ff ff       	jmp    80107176 <alltraps>

801082f7 <vector251>:
.globl vector251
vector251:
  pushl $0
801082f7:	6a 00                	push   $0x0
  pushl $251
801082f9:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801082fe:	e9 73 ee ff ff       	jmp    80107176 <alltraps>

80108303 <vector252>:
.globl vector252
vector252:
  pushl $0
80108303:	6a 00                	push   $0x0
  pushl $252
80108305:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010830a:	e9 67 ee ff ff       	jmp    80107176 <alltraps>

8010830f <vector253>:
.globl vector253
vector253:
  pushl $0
8010830f:	6a 00                	push   $0x0
  pushl $253
80108311:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108316:	e9 5b ee ff ff       	jmp    80107176 <alltraps>

8010831b <vector254>:
.globl vector254
vector254:
  pushl $0
8010831b:	6a 00                	push   $0x0
  pushl $254
8010831d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108322:	e9 4f ee ff ff       	jmp    80107176 <alltraps>

80108327 <vector255>:
.globl vector255
vector255:
  pushl $0
80108327:	6a 00                	push   $0x0
  pushl $255
80108329:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010832e:	e9 43 ee ff ff       	jmp    80107176 <alltraps>

80108333 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108333:	55                   	push   %ebp
80108334:	89 e5                	mov    %esp,%ebp
80108336:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010833c:	83 e8 01             	sub    $0x1,%eax
8010833f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108343:	8b 45 08             	mov    0x8(%ebp),%eax
80108346:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010834a:	8b 45 08             	mov    0x8(%ebp),%eax
8010834d:	c1 e8 10             	shr    $0x10,%eax
80108350:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108354:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108357:	0f 01 10             	lgdtl  (%eax)
}
8010835a:	90                   	nop
8010835b:	c9                   	leave  
8010835c:	c3                   	ret    

8010835d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010835d:	55                   	push   %ebp
8010835e:	89 e5                	mov    %esp,%ebp
80108360:	83 ec 04             	sub    $0x4,%esp
80108363:	8b 45 08             	mov    0x8(%ebp),%eax
80108366:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010836a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010836e:	0f 00 d8             	ltr    %ax
}
80108371:	90                   	nop
80108372:	c9                   	leave  
80108373:	c3                   	ret    

80108374 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108374:	55                   	push   %ebp
80108375:	89 e5                	mov    %esp,%ebp
80108377:	83 ec 04             	sub    $0x4,%esp
8010837a:	8b 45 08             	mov    0x8(%ebp),%eax
8010837d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108381:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108385:	8e e8                	mov    %eax,%gs
}
80108387:	90                   	nop
80108388:	c9                   	leave  
80108389:	c3                   	ret    

8010838a <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010838a:	55                   	push   %ebp
8010838b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010838d:	8b 45 08             	mov    0x8(%ebp),%eax
80108390:	0f 22 d8             	mov    %eax,%cr3
}
80108393:	90                   	nop
80108394:	5d                   	pop    %ebp
80108395:	c3                   	ret    

80108396 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108396:	55                   	push   %ebp
80108397:	89 e5                	mov    %esp,%ebp
80108399:	8b 45 08             	mov    0x8(%ebp),%eax
8010839c:	05 00 00 00 80       	add    $0x80000000,%eax
801083a1:	5d                   	pop    %ebp
801083a2:	c3                   	ret    

801083a3 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801083a3:	55                   	push   %ebp
801083a4:	89 e5                	mov    %esp,%ebp
801083a6:	8b 45 08             	mov    0x8(%ebp),%eax
801083a9:	05 00 00 00 80       	add    $0x80000000,%eax
801083ae:	5d                   	pop    %ebp
801083af:	c3                   	ret    

801083b0 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801083b0:	55                   	push   %ebp
801083b1:	89 e5                	mov    %esp,%ebp
801083b3:	53                   	push   %ebx
801083b4:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801083b7:	e8 ae ab ff ff       	call   80102f6a <cpunum>
801083bc:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801083c2:	05 80 33 11 80       	add    $0x80113380,%eax
801083c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801083ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cd:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801083d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d6:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801083dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083df:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801083e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083ea:	83 e2 f0             	and    $0xfffffff0,%edx
801083ed:	83 ca 0a             	or     $0xa,%edx
801083f0:	88 50 7d             	mov    %dl,0x7d(%eax)
801083f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801083fa:	83 ca 10             	or     $0x10,%edx
801083fd:	88 50 7d             	mov    %dl,0x7d(%eax)
80108400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108403:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108407:	83 e2 9f             	and    $0xffffff9f,%edx
8010840a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108414:	83 ca 80             	or     $0xffffff80,%edx
80108417:	88 50 7d             	mov    %dl,0x7d(%eax)
8010841a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108421:	83 ca 0f             	or     $0xf,%edx
80108424:	88 50 7e             	mov    %dl,0x7e(%eax)
80108427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010842e:	83 e2 ef             	and    $0xffffffef,%edx
80108431:	88 50 7e             	mov    %dl,0x7e(%eax)
80108434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108437:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010843b:	83 e2 df             	and    $0xffffffdf,%edx
8010843e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108444:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108448:	83 ca 40             	or     $0x40,%edx
8010844b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108455:	83 ca 80             	or     $0xffffff80,%edx
80108458:	88 50 7e             	mov    %dl,0x7e(%eax)
8010845b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845e:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108465:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010846c:	ff ff 
8010846e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108471:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108478:	00 00 
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108487:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010848e:	83 e2 f0             	and    $0xfffffff0,%edx
80108491:	83 ca 02             	or     $0x2,%edx
80108494:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010849a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801084a4:	83 ca 10             	or     $0x10,%edx
801084a7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801084b7:	83 e2 9f             	and    $0xffffff9f,%edx
801084ba:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801084ca:	83 ca 80             	or     $0xffffff80,%edx
801084cd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084dd:	83 ca 0f             	or     $0xf,%edx
801084e0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801084f0:	83 e2 ef             	and    $0xffffffef,%edx
801084f3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108503:	83 e2 df             	and    $0xffffffdf,%edx
80108506:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010850c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108516:	83 ca 40             	or     $0x40,%edx
80108519:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010851f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108522:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108529:	83 ca 80             	or     $0xffffff80,%edx
8010852c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108535:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010853c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108546:	ff ff 
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108552:	00 00 
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010855e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108561:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108568:	83 e2 f0             	and    $0xfffffff0,%edx
8010856b:	83 ca 0a             	or     $0xa,%edx
8010856e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010857e:	83 ca 10             	or     $0x10,%edx
80108581:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108591:	83 ca 60             	or     $0x60,%edx
80108594:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010859a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801085a4:	83 ca 80             	or     $0xffffff80,%edx
801085a7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801085ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085b7:	83 ca 0f             	or     $0xf,%edx
801085ba:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085ca:	83 e2 ef             	and    $0xffffffef,%edx
801085cd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085dd:	83 e2 df             	and    $0xffffffdf,%edx
801085e0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801085f0:	83 ca 40             	or     $0x40,%edx
801085f3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108603:	83 ca 80             	or     $0xffffff80,%edx
80108606:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010860c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860f:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108619:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108620:	ff ff 
80108622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108625:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010862c:	00 00 
8010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108631:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108642:	83 e2 f0             	and    $0xfffffff0,%edx
80108645:	83 ca 02             	or     $0x2,%edx
80108648:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010864e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108651:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108658:	83 ca 10             	or     $0x10,%edx
8010865b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108664:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010866b:	83 ca 60             	or     $0x60,%edx
8010866e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010867e:	83 ca 80             	or     $0xffffff80,%edx
80108681:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108691:	83 ca 0f             	or     $0xf,%edx
80108694:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086a4:	83 e2 ef             	and    $0xffffffef,%edx
801086a7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086b7:	83 e2 df             	and    $0xffffffdf,%edx
801086ba:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086ca:	83 ca 40             	or     $0x40,%edx
801086cd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801086dd:	83 ca 80             	or     $0xffffff80,%edx
801086e0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801086e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e9:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801086f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f3:	05 b4 00 00 00       	add    $0xb4,%eax
801086f8:	89 c3                	mov    %eax,%ebx
801086fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fd:	05 b4 00 00 00       	add    $0xb4,%eax
80108702:	c1 e8 10             	shr    $0x10,%eax
80108705:	89 c2                	mov    %eax,%edx
80108707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870a:	05 b4 00 00 00       	add    $0xb4,%eax
8010870f:	c1 e8 18             	shr    $0x18,%eax
80108712:	89 c1                	mov    %eax,%ecx
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010871e:	00 00 
80108720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108723:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010872a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872d:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108736:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010873d:	83 e2 f0             	and    $0xfffffff0,%edx
80108740:	83 ca 02             	or     $0x2,%edx
80108743:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108753:	83 ca 10             	or     $0x10,%edx
80108756:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010875c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108766:	83 e2 9f             	and    $0xffffff9f,%edx
80108769:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010876f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108772:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108779:	83 ca 80             	or     $0xffffff80,%edx
8010877c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108785:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010878c:	83 e2 f0             	and    $0xfffffff0,%edx
8010878f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108798:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010879f:	83 e2 ef             	and    $0xffffffef,%edx
801087a2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087b2:	83 e2 df             	and    $0xffffffdf,%edx
801087b5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087be:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087c5:	83 ca 40             	or     $0x40,%edx
801087c8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801087d8:	83 ca 80             	or     $0xffffff80,%edx
801087db:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801087e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e4:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801087ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ed:	83 c0 70             	add    $0x70,%eax
801087f0:	83 ec 08             	sub    $0x8,%esp
801087f3:	6a 38                	push   $0x38
801087f5:	50                   	push   %eax
801087f6:	e8 38 fb ff ff       	call   80108333 <lgdt>
801087fb:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801087fe:	83 ec 0c             	sub    $0xc,%esp
80108801:	6a 18                	push   $0x18
80108803:	e8 6c fb ff ff       	call   80108374 <loadgs>
80108808:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
8010880b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880e:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108814:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010881b:	00 00 00 00 
}
8010881f:	90                   	nop
80108820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108823:	c9                   	leave  
80108824:	c3                   	ret    

80108825 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108825:	55                   	push   %ebp
80108826:	89 e5                	mov    %esp,%ebp
80108828:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010882b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010882e:	c1 e8 16             	shr    $0x16,%eax
80108831:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108838:	8b 45 08             	mov    0x8(%ebp),%eax
8010883b:	01 d0                	add    %edx,%eax
8010883d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108843:	8b 00                	mov    (%eax),%eax
80108845:	83 e0 01             	and    $0x1,%eax
80108848:	85 c0                	test   %eax,%eax
8010884a:	74 18                	je     80108864 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010884c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010884f:	8b 00                	mov    (%eax),%eax
80108851:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108856:	50                   	push   %eax
80108857:	e8 47 fb ff ff       	call   801083a3 <p2v>
8010885c:	83 c4 04             	add    $0x4,%esp
8010885f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108862:	eb 48                	jmp    801088ac <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108864:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108868:	74 0e                	je     80108878 <walkpgdir+0x53>
8010886a:	e8 95 a3 ff ff       	call   80102c04 <kalloc>
8010886f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108872:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108876:	75 07                	jne    8010887f <walkpgdir+0x5a>
      return 0;
80108878:	b8 00 00 00 00       	mov    $0x0,%eax
8010887d:	eb 44                	jmp    801088c3 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010887f:	83 ec 04             	sub    $0x4,%esp
80108882:	68 00 10 00 00       	push   $0x1000
80108887:	6a 00                	push   $0x0
80108889:	ff 75 f4             	pushl  -0xc(%ebp)
8010888c:	e8 1c d3 ff ff       	call   80105bad <memset>
80108891:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108894:	83 ec 0c             	sub    $0xc,%esp
80108897:	ff 75 f4             	pushl  -0xc(%ebp)
8010889a:	e8 f7 fa ff ff       	call   80108396 <v2p>
8010889f:	83 c4 10             	add    $0x10,%esp
801088a2:	83 c8 07             	or     $0x7,%eax
801088a5:	89 c2                	mov    %eax,%edx
801088a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088aa:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801088ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801088af:	c1 e8 0c             	shr    $0xc,%eax
801088b2:	25 ff 03 00 00       	and    $0x3ff,%eax
801088b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c1:	01 d0                	add    %edx,%eax
}
801088c3:	c9                   	leave  
801088c4:	c3                   	ret    

801088c5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801088c5:	55                   	push   %ebp
801088c6:	89 e5                	mov    %esp,%ebp
801088c8:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801088cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801088ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801088d6:	8b 55 0c             	mov    0xc(%ebp),%edx
801088d9:	8b 45 10             	mov    0x10(%ebp),%eax
801088dc:	01 d0                	add    %edx,%eax
801088de:	83 e8 01             	sub    $0x1,%eax
801088e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801088e9:	83 ec 04             	sub    $0x4,%esp
801088ec:	6a 01                	push   $0x1
801088ee:	ff 75 f4             	pushl  -0xc(%ebp)
801088f1:	ff 75 08             	pushl  0x8(%ebp)
801088f4:	e8 2c ff ff ff       	call   80108825 <walkpgdir>
801088f9:	83 c4 10             	add    $0x10,%esp
801088fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801088ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108903:	75 07                	jne    8010890c <mappages+0x47>
      return -1;
80108905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010890a:	eb 47                	jmp    80108953 <mappages+0x8e>
    if(*pte & PTE_P)
8010890c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010890f:	8b 00                	mov    (%eax),%eax
80108911:	83 e0 01             	and    $0x1,%eax
80108914:	85 c0                	test   %eax,%eax
80108916:	74 0d                	je     80108925 <mappages+0x60>
      panic("remap");
80108918:	83 ec 0c             	sub    $0xc,%esp
8010891b:	68 78 98 10 80       	push   $0x80109878
80108920:	e8 41 7c ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108925:	8b 45 18             	mov    0x18(%ebp),%eax
80108928:	0b 45 14             	or     0x14(%ebp),%eax
8010892b:	83 c8 01             	or     $0x1,%eax
8010892e:	89 c2                	mov    %eax,%edx
80108930:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108933:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108938:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010893b:	74 10                	je     8010894d <mappages+0x88>
      break;
    a += PGSIZE;
8010893d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108944:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010894b:	eb 9c                	jmp    801088e9 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010894d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010894e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108953:	c9                   	leave  
80108954:	c3                   	ret    

80108955 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108955:	55                   	push   %ebp
80108956:	89 e5                	mov    %esp,%ebp
80108958:	53                   	push   %ebx
80108959:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010895c:	e8 a3 a2 ff ff       	call   80102c04 <kalloc>
80108961:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108964:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108968:	75 0a                	jne    80108974 <setupkvm+0x1f>
    return 0;
8010896a:	b8 00 00 00 00       	mov    $0x0,%eax
8010896f:	e9 8e 00 00 00       	jmp    80108a02 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108974:	83 ec 04             	sub    $0x4,%esp
80108977:	68 00 10 00 00       	push   $0x1000
8010897c:	6a 00                	push   $0x0
8010897e:	ff 75 f0             	pushl  -0x10(%ebp)
80108981:	e8 27 d2 ff ff       	call   80105bad <memset>
80108986:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108989:	83 ec 0c             	sub    $0xc,%esp
8010898c:	68 00 00 00 0e       	push   $0xe000000
80108991:	e8 0d fa ff ff       	call   801083a3 <p2v>
80108996:	83 c4 10             	add    $0x10,%esp
80108999:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010899e:	76 0d                	jbe    801089ad <setupkvm+0x58>
    panic("PHYSTOP too high");
801089a0:	83 ec 0c             	sub    $0xc,%esp
801089a3:	68 7e 98 10 80       	push   $0x8010987e
801089a8:	e8 b9 7b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801089ad:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801089b4:	eb 40                	jmp    801089f6 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801089b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b9:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801089bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bf:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801089c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c5:	8b 58 08             	mov    0x8(%eax),%ebx
801089c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cb:	8b 40 04             	mov    0x4(%eax),%eax
801089ce:	29 c3                	sub    %eax,%ebx
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	8b 00                	mov    (%eax),%eax
801089d5:	83 ec 0c             	sub    $0xc,%esp
801089d8:	51                   	push   %ecx
801089d9:	52                   	push   %edx
801089da:	53                   	push   %ebx
801089db:	50                   	push   %eax
801089dc:	ff 75 f0             	pushl  -0x10(%ebp)
801089df:	e8 e1 fe ff ff       	call   801088c5 <mappages>
801089e4:	83 c4 20             	add    $0x20,%esp
801089e7:	85 c0                	test   %eax,%eax
801089e9:	79 07                	jns    801089f2 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801089eb:	b8 00 00 00 00       	mov    $0x0,%eax
801089f0:	eb 10                	jmp    80108a02 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801089f2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801089f6:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801089fd:	72 b7                	jb     801089b6 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801089ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108a02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a05:	c9                   	leave  
80108a06:	c3                   	ret    

80108a07 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108a07:	55                   	push   %ebp
80108a08:	89 e5                	mov    %esp,%ebp
80108a0a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108a0d:	e8 43 ff ff ff       	call   80108955 <setupkvm>
80108a12:	a3 b8 81 11 80       	mov    %eax,0x801181b8
  switchkvm();
80108a17:	e8 03 00 00 00       	call   80108a1f <switchkvm>
}
80108a1c:	90                   	nop
80108a1d:	c9                   	leave  
80108a1e:	c3                   	ret    

80108a1f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108a1f:	55                   	push   %ebp
80108a20:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108a22:	a1 b8 81 11 80       	mov    0x801181b8,%eax
80108a27:	50                   	push   %eax
80108a28:	e8 69 f9 ff ff       	call   80108396 <v2p>
80108a2d:	83 c4 04             	add    $0x4,%esp
80108a30:	50                   	push   %eax
80108a31:	e8 54 f9 ff ff       	call   8010838a <lcr3>
80108a36:	83 c4 04             	add    $0x4,%esp
}
80108a39:	90                   	nop
80108a3a:	c9                   	leave  
80108a3b:	c3                   	ret    

80108a3c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108a3c:	55                   	push   %ebp
80108a3d:	89 e5                	mov    %esp,%ebp
80108a3f:	56                   	push   %esi
80108a40:	53                   	push   %ebx
  pushcli();
80108a41:	e8 61 d0 ff ff       	call   80105aa7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108a46:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108a4c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a53:	83 c2 08             	add    $0x8,%edx
80108a56:	89 d6                	mov    %edx,%esi
80108a58:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a5f:	83 c2 08             	add    $0x8,%edx
80108a62:	c1 ea 10             	shr    $0x10,%edx
80108a65:	89 d3                	mov    %edx,%ebx
80108a67:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108a6e:	83 c2 08             	add    $0x8,%edx
80108a71:	c1 ea 18             	shr    $0x18,%edx
80108a74:	89 d1                	mov    %edx,%ecx
80108a76:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108a7d:	67 00 
80108a7f:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108a86:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108a8c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108a93:	83 e2 f0             	and    $0xfffffff0,%edx
80108a96:	83 ca 09             	or     $0x9,%edx
80108a99:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108a9f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108aa6:	83 ca 10             	or     $0x10,%edx
80108aa9:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108aaf:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ab6:	83 e2 9f             	and    $0xffffff9f,%edx
80108ab9:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108abf:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ac6:	83 ca 80             	or     $0xffffff80,%edx
80108ac9:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108acf:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ad6:	83 e2 f0             	and    $0xfffffff0,%edx
80108ad9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108adf:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ae6:	83 e2 ef             	and    $0xffffffef,%edx
80108ae9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108aef:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108af6:	83 e2 df             	and    $0xffffffdf,%edx
80108af9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108aff:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b06:	83 ca 40             	or     $0x40,%edx
80108b09:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b0f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108b16:	83 e2 7f             	and    $0x7f,%edx
80108b19:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108b1f:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108b25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b2b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108b32:	83 e2 ef             	and    $0xffffffef,%edx
80108b35:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108b3b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b41:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108b47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108b4d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108b54:	8b 52 08             	mov    0x8(%edx),%edx
80108b57:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108b5d:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108b60:	83 ec 0c             	sub    $0xc,%esp
80108b63:	6a 30                	push   $0x30
80108b65:	e8 f3 f7 ff ff       	call   8010835d <ltr>
80108b6a:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80108b70:	8b 40 04             	mov    0x4(%eax),%eax
80108b73:	85 c0                	test   %eax,%eax
80108b75:	75 0d                	jne    80108b84 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108b77:	83 ec 0c             	sub    $0xc,%esp
80108b7a:	68 8f 98 10 80       	push   $0x8010988f
80108b7f:	e8 e2 79 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108b84:	8b 45 08             	mov    0x8(%ebp),%eax
80108b87:	8b 40 04             	mov    0x4(%eax),%eax
80108b8a:	83 ec 0c             	sub    $0xc,%esp
80108b8d:	50                   	push   %eax
80108b8e:	e8 03 f8 ff ff       	call   80108396 <v2p>
80108b93:	83 c4 10             	add    $0x10,%esp
80108b96:	83 ec 0c             	sub    $0xc,%esp
80108b99:	50                   	push   %eax
80108b9a:	e8 eb f7 ff ff       	call   8010838a <lcr3>
80108b9f:	83 c4 10             	add    $0x10,%esp
  popcli();
80108ba2:	e8 45 cf ff ff       	call   80105aec <popcli>
}
80108ba7:	90                   	nop
80108ba8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108bab:	5b                   	pop    %ebx
80108bac:	5e                   	pop    %esi
80108bad:	5d                   	pop    %ebp
80108bae:	c3                   	ret    

80108baf <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108baf:	55                   	push   %ebp
80108bb0:	89 e5                	mov    %esp,%ebp
80108bb2:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108bb5:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108bbc:	76 0d                	jbe    80108bcb <inituvm+0x1c>
    panic("inituvm: more than a page");
80108bbe:	83 ec 0c             	sub    $0xc,%esp
80108bc1:	68 a3 98 10 80       	push   $0x801098a3
80108bc6:	e8 9b 79 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108bcb:	e8 34 a0 ff ff       	call   80102c04 <kalloc>
80108bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108bd3:	83 ec 04             	sub    $0x4,%esp
80108bd6:	68 00 10 00 00       	push   $0x1000
80108bdb:	6a 00                	push   $0x0
80108bdd:	ff 75 f4             	pushl  -0xc(%ebp)
80108be0:	e8 c8 cf ff ff       	call   80105bad <memset>
80108be5:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108be8:	83 ec 0c             	sub    $0xc,%esp
80108beb:	ff 75 f4             	pushl  -0xc(%ebp)
80108bee:	e8 a3 f7 ff ff       	call   80108396 <v2p>
80108bf3:	83 c4 10             	add    $0x10,%esp
80108bf6:	83 ec 0c             	sub    $0xc,%esp
80108bf9:	6a 06                	push   $0x6
80108bfb:	50                   	push   %eax
80108bfc:	68 00 10 00 00       	push   $0x1000
80108c01:	6a 00                	push   $0x0
80108c03:	ff 75 08             	pushl  0x8(%ebp)
80108c06:	e8 ba fc ff ff       	call   801088c5 <mappages>
80108c0b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108c0e:	83 ec 04             	sub    $0x4,%esp
80108c11:	ff 75 10             	pushl  0x10(%ebp)
80108c14:	ff 75 0c             	pushl  0xc(%ebp)
80108c17:	ff 75 f4             	pushl  -0xc(%ebp)
80108c1a:	e8 4d d0 ff ff       	call   80105c6c <memmove>
80108c1f:	83 c4 10             	add    $0x10,%esp
}
80108c22:	90                   	nop
80108c23:	c9                   	leave  
80108c24:	c3                   	ret    

80108c25 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108c25:	55                   	push   %ebp
80108c26:	89 e5                	mov    %esp,%ebp
80108c28:	53                   	push   %ebx
80108c29:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c2f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108c34:	85 c0                	test   %eax,%eax
80108c36:	74 0d                	je     80108c45 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108c38:	83 ec 0c             	sub    $0xc,%esp
80108c3b:	68 c0 98 10 80       	push   $0x801098c0
80108c40:	e8 21 79 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108c45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c4c:	e9 95 00 00 00       	jmp    80108ce6 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108c51:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c57:	01 d0                	add    %edx,%eax
80108c59:	83 ec 04             	sub    $0x4,%esp
80108c5c:	6a 00                	push   $0x0
80108c5e:	50                   	push   %eax
80108c5f:	ff 75 08             	pushl  0x8(%ebp)
80108c62:	e8 be fb ff ff       	call   80108825 <walkpgdir>
80108c67:	83 c4 10             	add    $0x10,%esp
80108c6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c6d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c71:	75 0d                	jne    80108c80 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108c73:	83 ec 0c             	sub    $0xc,%esp
80108c76:	68 e3 98 10 80       	push   $0x801098e3
80108c7b:	e8 e6 78 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c83:	8b 00                	mov    (%eax),%eax
80108c85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108c8d:	8b 45 18             	mov    0x18(%ebp),%eax
80108c90:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108c93:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108c98:	77 0b                	ja     80108ca5 <loaduvm+0x80>
      n = sz - i;
80108c9a:	8b 45 18             	mov    0x18(%ebp),%eax
80108c9d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ca3:	eb 07                	jmp    80108cac <loaduvm+0x87>
    else
      n = PGSIZE;
80108ca5:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108cac:	8b 55 14             	mov    0x14(%ebp),%edx
80108caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108cb5:	83 ec 0c             	sub    $0xc,%esp
80108cb8:	ff 75 e8             	pushl  -0x18(%ebp)
80108cbb:	e8 e3 f6 ff ff       	call   801083a3 <p2v>
80108cc0:	83 c4 10             	add    $0x10,%esp
80108cc3:	ff 75 f0             	pushl  -0x10(%ebp)
80108cc6:	53                   	push   %ebx
80108cc7:	50                   	push   %eax
80108cc8:	ff 75 10             	pushl  0x10(%ebp)
80108ccb:	e8 e2 91 ff ff       	call   80101eb2 <readi>
80108cd0:	83 c4 10             	add    $0x10,%esp
80108cd3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108cd6:	74 07                	je     80108cdf <loaduvm+0xba>
      return -1;
80108cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cdd:	eb 18                	jmp    80108cf7 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108cdf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce9:	3b 45 18             	cmp    0x18(%ebp),%eax
80108cec:	0f 82 5f ff ff ff    	jb     80108c51 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108cf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cfa:	c9                   	leave  
80108cfb:	c3                   	ret    

80108cfc <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108cfc:	55                   	push   %ebp
80108cfd:	89 e5                	mov    %esp,%ebp
80108cff:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108d02:	8b 45 10             	mov    0x10(%ebp),%eax
80108d05:	85 c0                	test   %eax,%eax
80108d07:	79 0a                	jns    80108d13 <allocuvm+0x17>
    return 0;
80108d09:	b8 00 00 00 00       	mov    $0x0,%eax
80108d0e:	e9 b0 00 00 00       	jmp    80108dc3 <allocuvm+0xc7>
  if(newsz < oldsz)
80108d13:	8b 45 10             	mov    0x10(%ebp),%eax
80108d16:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d19:	73 08                	jae    80108d23 <allocuvm+0x27>
    return oldsz;
80108d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d1e:	e9 a0 00 00 00       	jmp    80108dc3 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108d23:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d26:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108d33:	eb 7f                	jmp    80108db4 <allocuvm+0xb8>
    mem = kalloc();
80108d35:	e8 ca 9e ff ff       	call   80102c04 <kalloc>
80108d3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108d3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d41:	75 2b                	jne    80108d6e <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108d43:	83 ec 0c             	sub    $0xc,%esp
80108d46:	68 01 99 10 80       	push   $0x80109901
80108d4b:	e8 76 76 ff ff       	call   801003c6 <cprintf>
80108d50:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108d53:	83 ec 04             	sub    $0x4,%esp
80108d56:	ff 75 0c             	pushl  0xc(%ebp)
80108d59:	ff 75 10             	pushl  0x10(%ebp)
80108d5c:	ff 75 08             	pushl  0x8(%ebp)
80108d5f:	e8 61 00 00 00       	call   80108dc5 <deallocuvm>
80108d64:	83 c4 10             	add    $0x10,%esp
      return 0;
80108d67:	b8 00 00 00 00       	mov    $0x0,%eax
80108d6c:	eb 55                	jmp    80108dc3 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108d6e:	83 ec 04             	sub    $0x4,%esp
80108d71:	68 00 10 00 00       	push   $0x1000
80108d76:	6a 00                	push   $0x0
80108d78:	ff 75 f0             	pushl  -0x10(%ebp)
80108d7b:	e8 2d ce ff ff       	call   80105bad <memset>
80108d80:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108d83:	83 ec 0c             	sub    $0xc,%esp
80108d86:	ff 75 f0             	pushl  -0x10(%ebp)
80108d89:	e8 08 f6 ff ff       	call   80108396 <v2p>
80108d8e:	83 c4 10             	add    $0x10,%esp
80108d91:	89 c2                	mov    %eax,%edx
80108d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d96:	83 ec 0c             	sub    $0xc,%esp
80108d99:	6a 06                	push   $0x6
80108d9b:	52                   	push   %edx
80108d9c:	68 00 10 00 00       	push   $0x1000
80108da1:	50                   	push   %eax
80108da2:	ff 75 08             	pushl  0x8(%ebp)
80108da5:	e8 1b fb ff ff       	call   801088c5 <mappages>
80108daa:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108dad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db7:	3b 45 10             	cmp    0x10(%ebp),%eax
80108dba:	0f 82 75 ff ff ff    	jb     80108d35 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108dc0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108dc3:	c9                   	leave  
80108dc4:	c3                   	ret    

80108dc5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108dc5:	55                   	push   %ebp
80108dc6:	89 e5                	mov    %esp,%ebp
80108dc8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108dcb:	8b 45 10             	mov    0x10(%ebp),%eax
80108dce:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108dd1:	72 08                	jb     80108ddb <deallocuvm+0x16>
    return oldsz;
80108dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dd6:	e9 a5 00 00 00       	jmp    80108e80 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108ddb:	8b 45 10             	mov    0x10(%ebp),%eax
80108dde:	05 ff 0f 00 00       	add    $0xfff,%eax
80108de3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108deb:	e9 81 00 00 00       	jmp    80108e71 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df3:	83 ec 04             	sub    $0x4,%esp
80108df6:	6a 00                	push   $0x0
80108df8:	50                   	push   %eax
80108df9:	ff 75 08             	pushl  0x8(%ebp)
80108dfc:	e8 24 fa ff ff       	call   80108825 <walkpgdir>
80108e01:	83 c4 10             	add    $0x10,%esp
80108e04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108e07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e0b:	75 09                	jne    80108e16 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108e0d:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108e14:	eb 54                	jmp    80108e6a <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e19:	8b 00                	mov    (%eax),%eax
80108e1b:	83 e0 01             	and    $0x1,%eax
80108e1e:	85 c0                	test   %eax,%eax
80108e20:	74 48                	je     80108e6a <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e25:	8b 00                	mov    (%eax),%eax
80108e27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108e2f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e33:	75 0d                	jne    80108e42 <deallocuvm+0x7d>
        panic("kfree");
80108e35:	83 ec 0c             	sub    $0xc,%esp
80108e38:	68 19 99 10 80       	push   $0x80109919
80108e3d:	e8 24 77 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108e42:	83 ec 0c             	sub    $0xc,%esp
80108e45:	ff 75 ec             	pushl  -0x14(%ebp)
80108e48:	e8 56 f5 ff ff       	call   801083a3 <p2v>
80108e4d:	83 c4 10             	add    $0x10,%esp
80108e50:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108e53:	83 ec 0c             	sub    $0xc,%esp
80108e56:	ff 75 e8             	pushl  -0x18(%ebp)
80108e59:	e8 09 9d ff ff       	call   80102b67 <kfree>
80108e5e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108e6a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e74:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e77:	0f 82 73 ff ff ff    	jb     80108df0 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108e7d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e80:	c9                   	leave  
80108e81:	c3                   	ret    

80108e82 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108e82:	55                   	push   %ebp
80108e83:	89 e5                	mov    %esp,%ebp
80108e85:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108e88:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e8c:	75 0d                	jne    80108e9b <freevm+0x19>
    panic("freevm: no pgdir");
80108e8e:	83 ec 0c             	sub    $0xc,%esp
80108e91:	68 1f 99 10 80       	push   $0x8010991f
80108e96:	e8 cb 76 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108e9b:	83 ec 04             	sub    $0x4,%esp
80108e9e:	6a 00                	push   $0x0
80108ea0:	68 00 00 00 80       	push   $0x80000000
80108ea5:	ff 75 08             	pushl  0x8(%ebp)
80108ea8:	e8 18 ff ff ff       	call   80108dc5 <deallocuvm>
80108ead:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108eb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108eb7:	eb 4f                	jmp    80108f08 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec6:	01 d0                	add    %edx,%eax
80108ec8:	8b 00                	mov    (%eax),%eax
80108eca:	83 e0 01             	and    $0x1,%eax
80108ecd:	85 c0                	test   %eax,%eax
80108ecf:	74 33                	je     80108f04 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108edb:	8b 45 08             	mov    0x8(%ebp),%eax
80108ede:	01 d0                	add    %edx,%eax
80108ee0:	8b 00                	mov    (%eax),%eax
80108ee2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ee7:	83 ec 0c             	sub    $0xc,%esp
80108eea:	50                   	push   %eax
80108eeb:	e8 b3 f4 ff ff       	call   801083a3 <p2v>
80108ef0:	83 c4 10             	add    $0x10,%esp
80108ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108ef6:	83 ec 0c             	sub    $0xc,%esp
80108ef9:	ff 75 f0             	pushl  -0x10(%ebp)
80108efc:	e8 66 9c ff ff       	call   80102b67 <kfree>
80108f01:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108f04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f08:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108f0f:	76 a8                	jbe    80108eb9 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108f11:	83 ec 0c             	sub    $0xc,%esp
80108f14:	ff 75 08             	pushl  0x8(%ebp)
80108f17:	e8 4b 9c ff ff       	call   80102b67 <kfree>
80108f1c:	83 c4 10             	add    $0x10,%esp
}
80108f1f:	90                   	nop
80108f20:	c9                   	leave  
80108f21:	c3                   	ret    

80108f22 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108f22:	55                   	push   %ebp
80108f23:	89 e5                	mov    %esp,%ebp
80108f25:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108f28:	83 ec 04             	sub    $0x4,%esp
80108f2b:	6a 00                	push   $0x0
80108f2d:	ff 75 0c             	pushl  0xc(%ebp)
80108f30:	ff 75 08             	pushl  0x8(%ebp)
80108f33:	e8 ed f8 ff ff       	call   80108825 <walkpgdir>
80108f38:	83 c4 10             	add    $0x10,%esp
80108f3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108f3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f42:	75 0d                	jne    80108f51 <clearpteu+0x2f>
    panic("clearpteu");
80108f44:	83 ec 0c             	sub    $0xc,%esp
80108f47:	68 30 99 10 80       	push   $0x80109930
80108f4c:	e8 15 76 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80108f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f54:	8b 00                	mov    (%eax),%eax
80108f56:	83 e0 fb             	and    $0xfffffffb,%eax
80108f59:	89 c2                	mov    %eax,%edx
80108f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5e:	89 10                	mov    %edx,(%eax)
}
80108f60:	90                   	nop
80108f61:	c9                   	leave  
80108f62:	c3                   	ret    

80108f63 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108f63:	55                   	push   %ebp
80108f64:	89 e5                	mov    %esp,%ebp
80108f66:	53                   	push   %ebx
80108f67:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108f6a:	e8 e6 f9 ff ff       	call   80108955 <setupkvm>
80108f6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f76:	75 0a                	jne    80108f82 <copyuvm+0x1f>
    return 0;
80108f78:	b8 00 00 00 00       	mov    $0x0,%eax
80108f7d:	e9 ee 00 00 00       	jmp    80109070 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108f82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f89:	e9 ba 00 00 00       	jmp    80109048 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f91:	83 ec 04             	sub    $0x4,%esp
80108f94:	6a 00                	push   $0x0
80108f96:	50                   	push   %eax
80108f97:	ff 75 08             	pushl  0x8(%ebp)
80108f9a:	e8 86 f8 ff ff       	call   80108825 <walkpgdir>
80108f9f:	83 c4 10             	add    $0x10,%esp
80108fa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108fa5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108fa9:	75 0d                	jne    80108fb8 <copyuvm+0x55>
    //  continue;
      panic("copyuvm: pte should exist");
80108fab:	83 ec 0c             	sub    $0xc,%esp
80108fae:	68 3a 99 10 80       	push   $0x8010993a
80108fb3:	e8 ae 75 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fbb:	8b 00                	mov    (%eax),%eax
80108fbd:	83 e0 01             	and    $0x1,%eax
80108fc0:	85 c0                	test   %eax,%eax
80108fc2:	74 7c                	je     80109040 <copyuvm+0xdd>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80108fc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fc7:	8b 00                	mov    (%eax),%eax
80108fc9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fce:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108fd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fd4:	8b 00                	mov    (%eax),%eax
80108fd6:	25 ff 0f 00 00       	and    $0xfff,%eax
80108fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108fde:	e8 21 9c ff ff       	call   80102c04 <kalloc>
80108fe3:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108fe6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108fea:	74 6d                	je     80109059 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108fec:	83 ec 0c             	sub    $0xc,%esp
80108fef:	ff 75 e8             	pushl  -0x18(%ebp)
80108ff2:	e8 ac f3 ff ff       	call   801083a3 <p2v>
80108ff7:	83 c4 10             	add    $0x10,%esp
80108ffa:	83 ec 04             	sub    $0x4,%esp
80108ffd:	68 00 10 00 00       	push   $0x1000
80109002:	50                   	push   %eax
80109003:	ff 75 e0             	pushl  -0x20(%ebp)
80109006:	e8 61 cc ff ff       	call   80105c6c <memmove>
8010900b:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010900e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109011:	83 ec 0c             	sub    $0xc,%esp
80109014:	ff 75 e0             	pushl  -0x20(%ebp)
80109017:	e8 7a f3 ff ff       	call   80108396 <v2p>
8010901c:	83 c4 10             	add    $0x10,%esp
8010901f:	89 c2                	mov    %eax,%edx
80109021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109024:	83 ec 0c             	sub    $0xc,%esp
80109027:	53                   	push   %ebx
80109028:	52                   	push   %edx
80109029:	68 00 10 00 00       	push   $0x1000
8010902e:	50                   	push   %eax
8010902f:	ff 75 f0             	pushl  -0x10(%ebp)
80109032:	e8 8e f8 ff ff       	call   801088c5 <mappages>
80109037:	83 c4 20             	add    $0x20,%esp
8010903a:	85 c0                	test   %eax,%eax
8010903c:	78 1e                	js     8010905c <copyuvm+0xf9>
8010903e:	eb 01                	jmp    80109041 <copyuvm+0xde>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
    //  continue;
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      continue;
80109040:	90                   	nop
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109041:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010904b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010904e:	0f 82 3a ff ff ff    	jb     80108f8e <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109057:	eb 17                	jmp    80109070 <copyuvm+0x10d>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109059:	90                   	nop
8010905a:	eb 01                	jmp    8010905d <copyuvm+0xfa>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010905c:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010905d:	83 ec 0c             	sub    $0xc,%esp
80109060:	ff 75 f0             	pushl  -0x10(%ebp)
80109063:	e8 1a fe ff ff       	call   80108e82 <freevm>
80109068:	83 c4 10             	add    $0x10,%esp
  return 0;
8010906b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109073:	c9                   	leave  
80109074:	c3                   	ret    

80109075 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109075:	55                   	push   %ebp
80109076:	89 e5                	mov    %esp,%ebp
80109078:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010907b:	83 ec 04             	sub    $0x4,%esp
8010907e:	6a 00                	push   $0x0
80109080:	ff 75 0c             	pushl  0xc(%ebp)
80109083:	ff 75 08             	pushl  0x8(%ebp)
80109086:	e8 9a f7 ff ff       	call   80108825 <walkpgdir>
8010908b:	83 c4 10             	add    $0x10,%esp
8010908e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109094:	8b 00                	mov    (%eax),%eax
80109096:	83 e0 01             	and    $0x1,%eax
80109099:	85 c0                	test   %eax,%eax
8010909b:	75 07                	jne    801090a4 <uva2ka+0x2f>
    return 0;
8010909d:	b8 00 00 00 00       	mov    $0x0,%eax
801090a2:	eb 29                	jmp    801090cd <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801090a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a7:	8b 00                	mov    (%eax),%eax
801090a9:	83 e0 04             	and    $0x4,%eax
801090ac:	85 c0                	test   %eax,%eax
801090ae:	75 07                	jne    801090b7 <uva2ka+0x42>
    return 0;
801090b0:	b8 00 00 00 00       	mov    $0x0,%eax
801090b5:	eb 16                	jmp    801090cd <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801090b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ba:	8b 00                	mov    (%eax),%eax
801090bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090c1:	83 ec 0c             	sub    $0xc,%esp
801090c4:	50                   	push   %eax
801090c5:	e8 d9 f2 ff ff       	call   801083a3 <p2v>
801090ca:	83 c4 10             	add    $0x10,%esp
}
801090cd:	c9                   	leave  
801090ce:	c3                   	ret    

801090cf <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801090cf:	55                   	push   %ebp
801090d0:	89 e5                	mov    %esp,%ebp
801090d2:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801090d5:	8b 45 10             	mov    0x10(%ebp),%eax
801090d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801090db:	eb 7f                	jmp    8010915c <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801090dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801090e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801090e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090eb:	83 ec 08             	sub    $0x8,%esp
801090ee:	50                   	push   %eax
801090ef:	ff 75 08             	pushl  0x8(%ebp)
801090f2:	e8 7e ff ff ff       	call   80109075 <uva2ka>
801090f7:	83 c4 10             	add    $0x10,%esp
801090fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801090fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109101:	75 07                	jne    8010910a <copyout+0x3b>
      return -1;
80109103:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109108:	eb 61                	jmp    8010916b <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010910a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010910d:	2b 45 0c             	sub    0xc(%ebp),%eax
80109110:	05 00 10 00 00       	add    $0x1000,%eax
80109115:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109118:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010911e:	76 06                	jbe    80109126 <copyout+0x57>
      n = len;
80109120:	8b 45 14             	mov    0x14(%ebp),%eax
80109123:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109126:	8b 45 0c             	mov    0xc(%ebp),%eax
80109129:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010912c:	89 c2                	mov    %eax,%edx
8010912e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109131:	01 d0                	add    %edx,%eax
80109133:	83 ec 04             	sub    $0x4,%esp
80109136:	ff 75 f0             	pushl  -0x10(%ebp)
80109139:	ff 75 f4             	pushl  -0xc(%ebp)
8010913c:	50                   	push   %eax
8010913d:	e8 2a cb ff ff       	call   80105c6c <memmove>
80109142:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109148:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010914b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010914e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109151:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109154:	05 00 10 00 00       	add    $0x1000,%eax
80109159:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010915c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109160:	0f 85 77 ff ff ff    	jne    801090dd <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109166:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010916b:	c9                   	leave  
8010916c:	c3                   	ret    
