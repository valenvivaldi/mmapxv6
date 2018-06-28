
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
8010003d:	68 40 96 10 80       	push   $0x80109640
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 a2 5b 00 00       	call   80105bee <initlock>
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
801000c1:	e8 4a 5b 00 00       	call   80105c10 <acquire>
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
8010010c:	e8 66 5b 00 00       	call   80105c77 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 28 53 00 00       	call   80105454 <sleep>
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
80100188:	e8 ea 5a 00 00       	call   80105c77 <release>
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
801001aa:	68 47 96 10 80       	push   $0x80109647
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
80100204:	68 58 96 10 80       	push   $0x80109658
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
80100243:	68 5f 96 10 80       	push   $0x8010965f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 b6 59 00 00       	call   80105c10 <acquire>
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
801002b9:	e8 a2 52 00 00       	call   80105560 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 a9 59 00 00       	call   80105c77 <release>
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
801003e2:	e8 29 58 00 00       	call   80105c10 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 66 96 10 80       	push   $0x80109666
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
801004cd:	c7 45 ec 6f 96 10 80 	movl   $0x8010966f,-0x14(%ebp)
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
8010055b:	e8 17 57 00 00       	call   80105c77 <release>
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
8010058b:	68 76 96 10 80       	push   $0x80109676
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
801005aa:	68 85 96 10 80       	push   $0x80109685
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 02 57 00 00       	call   80105cc9 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 87 96 10 80       	push   $0x80109687
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
801006db:	e8 52 58 00 00       	call   80105f32 <memmove>
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
80100705:	e8 69 57 00 00       	call   80105e73 <memset>
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
8010079a:	e8 ba 74 00 00       	call   80107c59 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 ad 74 00 00       	call   80107c59 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 a0 74 00 00       	call   80107c59 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 90 74 00 00       	call   80107c59 <uartputc>
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
801007eb:	e8 20 54 00 00       	call   80105c10 <acquire>
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
8010081e:	e8 ff 4d 00 00       	call   80105622 <procdump>
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
80100931:	e8 2a 4c 00 00       	call   80105560 <wakeup>
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
80100954:	e8 1e 53 00 00       	call   80105c77 <release>
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
80100981:	e8 8a 52 00 00       	call   80105c10 <acquire>
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
801009a3:	e8 cf 52 00 00       	call   80105c77 <release>
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
801009d0:	e8 7f 4a 00 00       	call   80105454 <sleep>
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
80100a4e:	e8 24 52 00 00       	call   80105c77 <release>
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
80100a8c:	e8 7f 51 00 00       	call   80105c10 <acquire>
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
80100ace:	e8 a4 51 00 00       	call   80105c77 <release>
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
80100af2:	68 8b 96 10 80       	push   $0x8010968b
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 ed 50 00 00       	call   80105bee <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 93 96 10 80       	push   $0x80109693
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 d8 50 00 00       	call   80105bee <initlock>
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
80100b3c:	e8 67 36 00 00       	call   801041a8 <picenable>
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
80100bcf:	e8 da 81 00 00       	call   80108dae <setupkvm>
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
80100c55:	e8 fb 84 00 00       	call   80109155 <allocuvm>
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
80100c88:	e8 f1 83 00 00       	call   8010907e <loaduvm>
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
80100d16:	e8 3a 84 00 00       	call   80109155 <allocuvm>
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
80100d5c:	e8 5f 53 00 00       	call   801060c0 <strlen>
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
80100d89:	e8 32 53 00 00       	call   801060c0 <strlen>
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
80100daf:	e8 74 87 00 00       	call   80109528 <copyout>
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
80100e4b:	e8 d8 86 00 00       	call   80109528 <copyout>
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
80100e9c:	e8 d5 51 00 00       	call   80106076 <safestrcpy>
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
80100ef2:	e8 9e 7f 00 00       	call   80108e95 <switchuvm>
80100ef7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100efa:	83 ec 0c             	sub    $0xc,%esp
80100efd:	ff 75 d0             	pushl  -0x30(%ebp)
80100f00:	e8 d6 83 00 00       	call   801092db <freevm>
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
80100f3a:	e8 9c 83 00 00       	call   801092db <freevm>
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
80100f6b:	68 99 96 10 80       	push   $0x80109699
80100f70:	68 60 18 11 80       	push   $0x80111860
80100f75:	e8 74 4c 00 00       	call   80105bee <initlock>
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
80100f8e:	e8 7d 4c 00 00       	call   80105c10 <acquire>
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
80100fbb:	e8 b7 4c 00 00       	call   80105c77 <release>
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
80100fde:	e8 94 4c 00 00       	call   80105c77 <release>
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
80100ffb:	e8 10 4c 00 00       	call   80105c10 <acquire>
80101000:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	8b 40 04             	mov    0x4(%eax),%eax
80101009:	85 c0                	test   %eax,%eax
8010100b:	7f 0d                	jg     8010101a <filedup+0x2d>
    panic("filedup");
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 a0 96 10 80       	push   $0x801096a0
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
80101031:	e8 41 4c 00 00       	call   80105c77 <release>
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
8010104c:	e8 bf 4b 00 00       	call   80105c10 <acquire>
80101051:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	7f 0d                	jg     8010106b <fileclose+0x2d>
    panic("fileclose");
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 a8 96 10 80       	push   $0x801096a8
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
8010108c:	e8 e6 4b 00 00       	call   80105c77 <release>
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
801010da:	e8 98 4b 00 00       	call   80105c77 <release>
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
801010f9:	e8 13 33 00 00       	call   80104411 <pipeclose>
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
801011b2:	e8 02 34 00 00       	call   801045b9 <piperead>
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
80101229:	68 b2 96 10 80       	push   $0x801096b2
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
8010126b:	e8 4b 32 00 00       	call   801044bb <pipewrite>
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
8010132c:	68 bb 96 10 80       	push   $0x801096bb
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
80101362:	68 cb 96 10 80       	push   $0x801096cb
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
801013f5:	e8 38 4b 00 00       	call   80105f32 <memmove>
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
8010143b:	e8 33 4a 00 00       	call   80105e73 <memset>
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
801015b4:	68 d5 96 10 80       	push   $0x801096d5
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
8010164a:	68 eb 96 10 80       	push   $0x801096eb
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
801016a4:	68 fe 96 10 80       	push   $0x801096fe
801016a9:	68 60 22 11 80       	push   $0x80112260
801016ae:	e8 3b 45 00 00       	call   80105bee <initlock>
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
80101729:	e8 45 47 00 00       	call   80105e73 <memset>
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
8010178e:	68 05 97 10 80       	push   $0x80109705
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
8010182e:	e8 ff 46 00 00       	call   80105f32 <memmove>
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
80101863:	e8 a8 43 00 00       	call   80105c10 <acquire>
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
801018b1:	e8 c1 43 00 00       	call   80105c77 <release>
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
801018ea:	68 17 97 10 80       	push   $0x80109717
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
80101927:	e8 4b 43 00 00       	call   80105c77 <release>
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
80101942:	e8 c9 42 00 00       	call   80105c10 <acquire>
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
80101961:	e8 11 43 00 00       	call   80105c77 <release>
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
80101987:	68 27 97 10 80       	push   $0x80109727
8010198c:	e8 d5 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101991:	83 ec 0c             	sub    $0xc,%esp
80101994:	68 60 22 11 80       	push   $0x80112260
80101999:	e8 72 42 00 00       	call   80105c10 <acquire>
8010199e:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019a1:	eb 13                	jmp    801019b6 <ilock+0x48>
    sleep(ip, &icache.lock);
801019a3:	83 ec 08             	sub    $0x8,%esp
801019a6:	68 60 22 11 80       	push   $0x80112260
801019ab:	ff 75 08             	pushl  0x8(%ebp)
801019ae:	e8 a1 3a 00 00       	call   80105454 <sleep>
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
801019dc:	e8 96 42 00 00       	call   80105c77 <release>
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
80101a83:	e8 aa 44 00 00       	call   80105f32 <memmove>
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
80101ab9:	68 2d 97 10 80       	push   $0x8010972d
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
80101aec:	68 3c 97 10 80       	push   $0x8010973c
80101af1:	e8 70 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af6:	83 ec 0c             	sub    $0xc,%esp
80101af9:	68 60 22 11 80       	push   $0x80112260
80101afe:	e8 0d 41 00 00       	call   80105c10 <acquire>
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
80101b1d:	e8 3e 3a 00 00       	call   80105560 <wakeup>
80101b22:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 60 22 11 80       	push   $0x80112260
80101b2d:	e8 45 41 00 00       	call   80105c77 <release>
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
80101b46:	e8 c5 40 00 00       	call   80105c10 <acquire>
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
80101b8e:	68 44 97 10 80       	push   $0x80109744
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
80101bb1:	e8 c1 40 00 00       	call   80105c77 <release>
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
80101be6:	e8 25 40 00 00       	call   80105c10 <acquire>
80101beb:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bf8:	83 ec 0c             	sub    $0xc,%esp
80101bfb:	ff 75 08             	pushl  0x8(%ebp)
80101bfe:	e8 5d 39 00 00       	call   80105560 <wakeup>
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
80101c1d:	e8 55 40 00 00       	call   80105c77 <release>
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
80101d5d:	68 4e 97 10 80       	push   $0x8010974e
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
80101ff4:	e8 39 3f 00 00       	call   80105f32 <memmove>
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
80102146:	e8 e7 3d 00 00       	call   80105f32 <memmove>
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
801021c6:	e8 fd 3d 00 00       	call   80105fc8 <strncmp>
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
801021e6:	68 61 97 10 80       	push   $0x80109761
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
80102215:	68 73 97 10 80       	push   $0x80109773
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
801022ea:	68 73 97 10 80       	push   $0x80109773
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
80102325:	e8 f4 3c 00 00       	call   8010601e <strncpy>
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
80102351:	68 80 97 10 80       	push   $0x80109780
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
801023c7:	e8 66 3b 00 00       	call   80105f32 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	pushl  -0xc(%ebp)
801023db:	ff 75 0c             	pushl  0xc(%ebp)
801023de:	e8 4f 3b 00 00       	call   80105f32 <memmove>
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
80102633:	68 88 97 10 80       	push   $0x80109788
80102638:	68 20 c6 10 80       	push   $0x8010c620
8010263d:	e8 ac 35 00 00       	call   80105bee <initlock>
80102642:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102645:	83 ec 0c             	sub    $0xc,%esp
80102648:	6a 0e                	push   $0xe
8010264a:	e8 59 1b 00 00       	call   801041a8 <picenable>
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
801026e7:	68 8c 97 10 80       	push   $0x8010978c
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
80102808:	e8 03 34 00 00       	call   80105c10 <acquire>
8010280d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102810:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102815:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102818:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010281c:	75 15                	jne    80102833 <ideintr+0x39>
    release(&idelock);
8010281e:	83 ec 0c             	sub    $0xc,%esp
80102821:	68 20 c6 10 80       	push   $0x8010c620
80102826:	e8 4c 34 00 00       	call   80105c77 <release>
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
8010289b:	e8 c0 2c 00 00       	call   80105560 <wakeup>
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
801028c5:	e8 ad 33 00 00       	call   80105c77 <release>
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
801028e4:	68 95 97 10 80       	push   $0x80109795
801028e9:	e8 78 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028ee:	8b 45 08             	mov    0x8(%ebp),%eax
801028f1:	8b 00                	mov    (%eax),%eax
801028f3:	83 e0 06             	and    $0x6,%eax
801028f6:	83 f8 02             	cmp    $0x2,%eax
801028f9:	75 0d                	jne    80102908 <iderw+0x39>
    panic("iderw: nothing to do");
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 a9 97 10 80       	push   $0x801097a9
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
8010291e:	68 be 97 10 80       	push   $0x801097be
80102923:	e8 3e dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102928:	83 ec 0c             	sub    $0xc,%esp
8010292b:	68 20 c6 10 80       	push   $0x8010c620
80102930:	e8 db 32 00 00       	call   80105c10 <acquire>
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
8010298c:	e8 c3 2a 00 00       	call   80105454 <sleep>
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
801029a9:	e8 c9 32 00 00       	call   80105c77 <release>
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
80102a3a:	68 dc 97 10 80       	push   $0x801097dc
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
80102afa:	68 0e 98 10 80       	push   $0x8010980e
80102aff:	68 40 32 11 80       	push   $0x80113240
80102b04:	e8 e5 30 00 00       	call   80105bee <initlock>
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
80102b9d:	81 7d 08 bc 7c 11 80 	cmpl   $0x80117cbc,0x8(%ebp)
80102ba4:	72 12                	jb     80102bb8 <kfree+0x2d>
80102ba6:	ff 75 08             	pushl  0x8(%ebp)
80102ba9:	e8 36 ff ff ff       	call   80102ae4 <v2p>
80102bae:	83 c4 04             	add    $0x4,%esp
80102bb1:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bb6:	76 0d                	jbe    80102bc5 <kfree+0x3a>
    panic("kfree");
80102bb8:	83 ec 0c             	sub    $0xc,%esp
80102bbb:	68 13 98 10 80       	push   $0x80109813
80102bc0:	e8 a1 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bc5:	83 ec 04             	sub    $0x4,%esp
80102bc8:	68 00 10 00 00       	push   $0x1000
80102bcd:	6a 01                	push   $0x1
80102bcf:	ff 75 08             	pushl  0x8(%ebp)
80102bd2:	e8 9c 32 00 00       	call   80105e73 <memset>
80102bd7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102bda:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bdf:	85 c0                	test   %eax,%eax
80102be1:	74 10                	je     80102bf3 <kfree+0x68>
    acquire(&kmem.lock);
80102be3:	83 ec 0c             	sub    $0xc,%esp
80102be6:	68 40 32 11 80       	push   $0x80113240
80102beb:	e8 20 30 00 00       	call   80105c10 <acquire>
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
80102c1d:	e8 55 30 00 00       	call   80105c77 <release>
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
80102c3f:	e8 cc 2f 00 00       	call   80105c10 <acquire>
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
80102c70:	e8 02 30 00 00       	call   80105c77 <release>
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
80102fbb:	68 1c 98 10 80       	push   $0x8010981c
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
801031e6:	e8 ef 2c 00 00       	call   80105eda <memcmp>
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
801032fa:	68 48 98 10 80       	push   $0x80109848
801032ff:	68 80 32 11 80       	push   $0x80113280
80103304:	e8 e5 28 00 00       	call   80105bee <initlock>
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
801033b7:	e8 76 2b 00 00       	call   80105f32 <memmove>
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
80103525:	e8 e6 26 00 00       	call   80105c10 <acquire>
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
80103543:	e8 0c 1f 00 00       	call   80105454 <sleep>
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
80103578:	e8 d7 1e 00 00       	call   80105454 <sleep>
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
80103597:	e8 db 26 00 00       	call   80105c77 <release>
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
801035b8:	e8 53 26 00 00       	call   80105c10 <acquire>
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
801035d9:	68 4c 98 10 80       	push   $0x8010984c
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
80103607:	e8 54 1f 00 00       	call   80105560 <wakeup>
8010360c:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010360f:	83 ec 0c             	sub    $0xc,%esp
80103612:	68 80 32 11 80       	push   $0x80113280
80103617:	e8 5b 26 00 00       	call   80105c77 <release>
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
80103632:	e8 d9 25 00 00       	call   80105c10 <acquire>
80103637:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010363a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103641:	00 00 00 
    wakeup(&log);
80103644:	83 ec 0c             	sub    $0xc,%esp
80103647:	68 80 32 11 80       	push   $0x80113280
8010364c:	e8 0f 1f 00 00       	call   80105560 <wakeup>
80103651:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103654:	83 ec 0c             	sub    $0xc,%esp
80103657:	68 80 32 11 80       	push   $0x80113280
8010365c:	e8 16 26 00 00       	call   80105c77 <release>
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
801036d8:	e8 55 28 00 00       	call   80105f32 <memmove>
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
80103774:	68 5b 98 10 80       	push   $0x8010985b
80103779:	e8 e8 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010377e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103783:	85 c0                	test   %eax,%eax
80103785:	7f 0d                	jg     80103794 <log_write+0x45>
    panic("log_write outside of trans");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 71 98 10 80       	push   $0x80109871
8010378f:	e8 d2 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	68 80 32 11 80       	push   $0x80113280
8010379c:	e8 6f 24 00 00       	call   80105c10 <acquire>
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
8010381a:	e8 58 24 00 00       	call   80105c77 <release>
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
80103872:	68 bc 7c 11 80       	push   $0x80117cbc
80103877:	e8 75 f2 ff ff       	call   80102af1 <kinit1>
8010387c:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010387f:	e8 dc 55 00 00       	call   80108e60 <kvmalloc>
  mpinit();        // collect info about this machine
80103884:	e8 f6 06 00 00       	call   80103f7f <mpinit>
  lapicinit();
80103889:	e8 e2 f5 ff ff       	call   80102e70 <lapicinit>
  seginit();       // set up segments
8010388e:	e8 76 4f 00 00       	call   80108809 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103893:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103899:	0f b6 00             	movzbl (%eax),%eax
8010389c:	0f b6 c0             	movzbl %al,%eax
8010389f:	83 ec 08             	sub    $0x8,%esp
801038a2:	50                   	push   %eax
801038a3:	68 8c 98 10 80       	push   $0x8010988c
801038a8:	e8 19 cb ff ff       	call   801003c6 <cprintf>
801038ad:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038b0:	e8 20 09 00 00       	call   801041d5 <picinit>
  ioapicinit();    // another interrupt controller
801038b5:	e8 2c f1 ff ff       	call   801029e6 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038ba:	e8 2a d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801038bf:	e8 a1 42 00 00       	call   80107b65 <uartinit>
  pinit();         // process table
801038c4:	e8 95 10 00 00       	call   8010495e <pinit>
  tvinit();        // trap vectors
801038c9:	e8 da 3b 00 00       	call   801074a8 <tvinit>
  binit();         // buffer cache
801038ce:	e8 61 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038d3:	e8 8a d6 ff ff       	call   80100f62 <fileinit>
  seminit();       // semaphore table
801038d8:	e8 61 1e 00 00       	call   8010573e <seminit>
  iinit();         // inode cache
801038dd:	e8 b9 dd ff ff       	call   8010169b <iinit>
  ideinit();       // disk
801038e2:	e8 43 ed ff ff       	call   8010262a <ideinit>
  if(!ismp)
801038e7:	a1 64 33 11 80       	mov    0x80113364,%eax
801038ec:	85 c0                	test   %eax,%eax
801038ee:	75 05                	jne    801038f5 <main+0x9c>
    timerinit();   // uniprocessor timer
801038f0:	e8 10 3b 00 00       	call   80107405 <timerinit>
  startothers();   // start other processors
801038f5:	e8 7f 00 00 00       	call   80103979 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038fa:	83 ec 08             	sub    $0x8,%esp
801038fd:	68 00 00 00 8e       	push   $0x8e000000
80103902:	68 00 00 40 80       	push   $0x80400000
80103907:	e8 1e f2 ff ff       	call   80102b2a <kinit2>
8010390c:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010390f:	e8 86 11 00 00       	call   80104a9a <userinit>
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
8010391f:	e8 54 55 00 00       	call   80108e78 <switchkvm>
  seginit();
80103924:	e8 e0 4e 00 00       	call   80108809 <seginit>
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
80103949:	68 a3 98 10 80       	push   $0x801098a3
8010394e:	e8 73 ca ff ff       	call   801003c6 <cprintf>
80103953:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103956:	e8 c3 3c 00 00       	call   8010761e <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010395b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103961:	05 a8 00 00 00       	add    $0xa8,%eax
80103966:	83 ec 08             	sub    $0x8,%esp
80103969:	6a 01                	push   $0x1
8010396b:	50                   	push   %eax
8010396c:	e8 ce fe ff ff       	call   8010383f <xchg>
80103971:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103974:	e8 cd 18 00 00       	call   80105246 <scheduler>

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
801039a1:	e8 8c 25 00 00       	call   80105f32 <memmove>
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

80103a64 <p2v>:
80103a64:	55                   	push   %ebp
80103a65:	89 e5                	mov    %esp,%ebp
80103a67:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6a:	05 00 00 00 80       	add    $0x80000000,%eax
80103a6f:	5d                   	pop    %ebp
80103a70:	c3                   	ret    

80103a71 <mmap>:
#include "memlayout.h"
#include "proc.h"

int
mmap(int fd, char ** addr )
{
80103a71:	55                   	push   %ebp
80103a72:	89 e5                	mov    %esp,%ebp
80103a74:	53                   	push   %ebx
80103a75:	83 ec 10             	sub    $0x10,%esp
  int indexommap;
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd >= 0 && fd < NOFILE && proc->ofile[fd] != 0){
80103a78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103a7c:	78 36                	js     80103ab4 <mmap+0x43>
80103a7e:	83 7d 08 0f          	cmpl   $0xf,0x8(%ebp)
80103a82:	7f 30                	jg     80103ab4 <mmap+0x43>
80103a84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a8a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a8d:	83 c2 08             	add    $0x8,%edx
80103a90:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103a94:	85 c0                	test   %eax,%eax
80103a96:	74 1c                	je     80103ab4 <mmap+0x43>
    fileformap = proc->ofile[fd];
80103a98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103a9e:	8b 55 08             	mov    0x8(%ebp),%edx
80103aa1:	83 c2 08             	add    $0x8,%edx
80103aa4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
80103aab:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80103ab2:	eb 2e                	jmp    80103ae2 <mmap+0x71>
  struct file* fileformap;
//buscar en ofile del archivo el archivo a mapear
  if(fd >= 0 && fd < NOFILE && proc->ofile[fd] != 0){
    fileformap = proc->ofile[fd];
  }else{
    return -1;
80103ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ab9:	e9 f7 00 00 00       	jmp    80103bb5 <mmap+0x144>
  }
  //buscar espacio libre en ommap
  for (indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
    if(proc->ommap[indexommap].pfile == 0){
80103abe:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103ac5:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103ac8:	89 d0                	mov    %edx,%eax
80103aca:	01 c0                	add    %eax,%eax
80103acc:	01 d0                	add    %edx,%eax
80103ace:	c1 e0 02             	shl    $0x2,%eax
80103ad1:	01 c8                	add    %ecx,%eax
80103ad3:	05 a0 00 00 00       	add    $0xa0,%eax
80103ad8:	8b 00                	mov    (%eax),%eax
80103ada:	85 c0                	test   %eax,%eax
80103adc:	74 0c                	je     80103aea <mmap+0x79>
    fileformap = proc->ofile[fd];
  }else{
    return -1;
  }
  //buscar espacio libre en ommap
  for (indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
80103ade:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80103ae2:	83 7d f8 04          	cmpl   $0x4,-0x8(%ebp)
80103ae6:	7e d6                	jle    80103abe <mmap+0x4d>
80103ae8:	eb 01                	jmp    80103aeb <mmap+0x7a>
    if(proc->ommap[indexommap].pfile == 0){
      break;
80103aea:	90                   	nop
    }
  }

  //guardar estructura
  if(indexommap < MAXMAPPEDFILES){
80103aeb:	83 7d f8 04          	cmpl   $0x4,-0x8(%ebp)
80103aef:	0f 8f bb 00 00 00    	jg     80103bb0 <mmap+0x13f>

    proc->ommap[indexommap].pfile = fileformap;
80103af5:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103afc:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103aff:	89 d0                	mov    %edx,%eax
80103b01:	01 c0                	add    %eax,%eax
80103b03:	01 d0                	add    %edx,%eax
80103b05:	c1 e0 02             	shl    $0x2,%eax
80103b08:	01 c8                	add    %ecx,%eax
80103b0a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	89 02                	mov    %eax,(%edx)
    proc->ommap[indexommap].sz = fileformap->ip->size;
80103b15:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80103b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1f:	8b 40 10             	mov    0x10(%eax),%eax
80103b22:	8b 48 18             	mov    0x18(%eax),%ecx
80103b25:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103b28:	89 d0                	mov    %edx,%eax
80103b2a:	01 c0                	add    %eax,%eax
80103b2c:	01 d0                	add    %edx,%eax
80103b2e:	c1 e0 02             	shl    $0x2,%eax
80103b31:	01 d8                	add    %ebx,%eax
80103b33:	05 a8 00 00 00       	add    $0xa8,%eax
80103b38:	89 08                	mov    %ecx,(%eax)

    proc->ommap[indexommap].va = proc->sz;
80103b3a:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80103b41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b47:	8b 08                	mov    (%eax),%ecx
80103b49:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103b4c:	89 d0                	mov    %edx,%eax
80103b4e:	01 c0                	add    %eax,%eax
80103b50:	01 d0                	add    %edx,%eax
80103b52:	c1 e0 02             	shl    $0x2,%eax
80103b55:	01 d8                	add    %ebx,%eax
80103b57:	05 a4 00 00 00       	add    $0xa4,%eax
80103b5c:	89 08                	mov    %ecx,(%eax)
    proc->sz = PGROUNDUP(proc->sz + fileformap->ip->size);
80103b5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103b64:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80103b6b:	8b 0a                	mov    (%edx),%ecx
80103b6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b70:	8b 52 10             	mov    0x10(%edx),%edx
80103b73:	8b 52 18             	mov    0x18(%edx),%edx
80103b76:	01 ca                	add    %ecx,%edx
80103b78:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
80103b7e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80103b84:	89 10                	mov    %edx,(%eax)

    //*adrr = dir de memoria virtual donde empieza el archivo
    *addr = (void *) proc->ommap[indexommap].va;
80103b86:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103b8d:	8b 55 f8             	mov    -0x8(%ebp),%edx
80103b90:	89 d0                	mov    %edx,%eax
80103b92:	01 c0                	add    %eax,%eax
80103b94:	01 d0                	add    %edx,%eax
80103b96:	c1 e0 02             	shl    $0x2,%eax
80103b99:	01 c8                	add    %ecx,%eax
80103b9b:	05 a4 00 00 00       	add    $0xa4,%eax
80103ba0:	8b 00                	mov    (%eax),%eax
80103ba2:	89 c2                	mov    %eax,%edx
80103ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ba7:	89 10                	mov    %edx,(%eax)

    return 0;
80103ba9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bae:	eb 05                	jmp    80103bb5 <mmap+0x144>

  }else{
    return -2;
80103bb0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  }

}
80103bb5:	83 c4 10             	add    $0x10,%esp
80103bb8:	5b                   	pop    %ebx
80103bb9:	5d                   	pop    %ebp
80103bba:	c3                   	ret    

80103bbb <munmap>:

int
munmap(char * addr)
{
80103bbb:	55                   	push   %ebp
80103bbc:	89 e5                	mov    %esp,%ebp
80103bbe:	83 ec 28             	sub    $0x28,%esp
  uint indexommap, baseaddr, size;
  struct mmap* filemap;


 //buscar  ommap que archivo mapeado usa esa direccion de mem
 for(indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
80103bc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bc8:	eb 56                	jmp    80103c20 <munmap+0x65>
   //ver que la direccion virtual no sea 0 o puntero a file null
   filemap = &proc->ommap[indexommap];
80103bca:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80103bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bd4:	89 d0                	mov    %edx,%eax
80103bd6:	01 c0                	add    %eax,%eax
80103bd8:	01 d0                	add    %edx,%eax
80103bda:	c1 e0 02             	shl    $0x2,%eax
80103bdd:	05 a0 00 00 00       	add    $0xa0,%eax
80103be2:	01 c8                	add    %ecx,%eax
80103be4:	89 45 e8             	mov    %eax,-0x18(%ebp)
   if(filemap->va != 0 && filemap->pfile){
80103be7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bea:	8b 40 04             	mov    0x4(%eax),%eax
80103bed:	85 c0                	test   %eax,%eax
80103bef:	74 2b                	je     80103c1c <munmap+0x61>
80103bf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bf4:	8b 00                	mov    (%eax),%eax
80103bf6:	85 c0                	test   %eax,%eax
80103bf8:	74 22                	je     80103c1c <munmap+0x61>
     baseaddr = filemap->va;
80103bfa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bfd:	8b 40 04             	mov    0x4(%eax),%eax
80103c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
     size = filemap->va + filemap->sz;
80103c03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c06:	8b 50 04             	mov    0x4(%eax),%edx
80103c09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c0c:	8b 40 08             	mov    0x8(%eax),%eax
80103c0f:	01 d0                	add    %edx,%eax
80103c11:	89 45 ec             	mov    %eax,-0x14(%ebp)
     if((uint) addr == baseaddr)
80103c14:	8b 45 08             	mov    0x8(%ebp),%eax
80103c17:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103c1a:	74 0c                	je     80103c28 <munmap+0x6d>
  uint indexommap, baseaddr, size;
  struct mmap* filemap;


 //buscar  ommap que archivo mapeado usa esa direccion de mem
 for(indexommap = 0; indexommap < MAXMAPPEDFILES; indexommap++){
80103c1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c20:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80103c24:	76 a4                	jbe    80103bca <munmap+0xf>
80103c26:	eb 01                	jmp    80103c29 <munmap+0x6e>
   filemap = &proc->ommap[indexommap];
   if(filemap->va != 0 && filemap->pfile){
     baseaddr = filemap->va;
     size = filemap->va + filemap->sz;
     if((uint) addr == baseaddr)
       break;
80103c28:	90                   	nop
   }
 }
 if(indexommap < MAXMAPPEDFILES){
80103c29:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80103c2d:	0f 87 d3 00 00 00    	ja     80103d06 <munmap+0x14b>
   pte_t* pte;




   for(offset =(uint) addr; offset  < size; offset += PGSIZE){
80103c33:	8b 45 08             	mov    0x8(%ebp),%eax
80103c36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103c39:	e9 86 00 00 00       	jmp    80103cc4 <munmap+0x109>
    pte = pgflags(proc->pgdir,(char *) offset, PTE_D);
80103c3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103c41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103c47:	8b 40 04             	mov    0x4(%eax),%eax
80103c4a:	83 ec 04             	sub    $0x4,%esp
80103c4d:	6a 40                	push   $0x40
80103c4f:	52                   	push   %edx
80103c50:	50                   	push   %eax
80103c51:	e8 b0 59 00 00       	call   80109606 <pgflags>
80103c56:	83 c4 10             	add    $0x10,%esp
80103c59:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pte){
80103c5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103c60:	74 5b                	je     80103cbd <munmap+0x102>
      if((filemap->pfile)->writable){
80103c62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c65:	8b 00                	mov    (%eax),%eax
80103c67:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80103c6b:	84 c0                	test   %al,%al
80103c6d:	74 4e                	je     80103cbd <munmap+0x102>
        uint pa = PTE_ADDR(*pte);
80103c6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c72:	8b 00                	mov    (%eax),%eax
80103c74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103c79:	89 45 dc             	mov    %eax,-0x24(%ebp)
        fileseek(filemap->pfile, offset - (uint) addr);
80103c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103c82:	29 c2                	sub    %eax,%edx
80103c84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c87:	8b 00                	mov    (%eax),%eax
80103c89:	83 ec 08             	sub    $0x8,%esp
80103c8c:	52                   	push   %edx
80103c8d:	50                   	push   %eax
80103c8e:	e8 de d6 ff ff       	call   80101371 <fileseek>
80103c93:	83 c4 10             	add    $0x10,%esp
        filewrite(filemap->pfile, (char*)p2v(pa), PGSIZE);
80103c96:	83 ec 0c             	sub    $0xc,%esp
80103c99:	ff 75 dc             	pushl  -0x24(%ebp)
80103c9c:	e8 c3 fd ff ff       	call   80103a64 <p2v>
80103ca1:	83 c4 10             	add    $0x10,%esp
80103ca4:	89 c2                	mov    %eax,%edx
80103ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ca9:	8b 00                	mov    (%eax),%eax
80103cab:	83 ec 04             	sub    $0x4,%esp
80103cae:	68 00 10 00 00       	push   $0x1000
80103cb3:	52                   	push   %edx
80103cb4:	50                   	push   %eax
80103cb5:	e8 7b d5 ff ff       	call   80101235 <filewrite>
80103cba:	83 c4 10             	add    $0x10,%esp
   pte_t* pte;




   for(offset =(uint) addr; offset  < size; offset += PGSIZE){
80103cbd:	81 45 e4 00 10 00 00 	addl   $0x1000,-0x1c(%ebp)
80103cc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cc7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cca:	0f 82 6e ff ff ff    	jb     80103c3e <munmap+0x83>
        fileseek(filemap->pfile, offset - (uint) addr);
        filewrite(filemap->pfile, (char*)p2v(pa), PGSIZE);
      }
    }
   }
   unmappages(proc->pgdir, (char*)baseaddr, size);
80103cd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103cd9:	8b 40 04             	mov    0x4(%eax),%eax
80103cdc:	83 ec 04             	sub    $0x4,%esp
80103cdf:	ff 75 ec             	pushl  -0x14(%ebp)
80103ce2:	52                   	push   %edx
80103ce3:	50                   	push   %eax
80103ce4:	e8 dd 58 00 00       	call   801095c6 <unmappages>
80103ce9:	83 c4 10             	add    $0x10,%esp

   //marcar como no usadas
   filemap->pfile = 0;
80103cec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
   filemap->va = 0;
80103cf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cf8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

   return 0;
80103cff:	b8 00 00 00 00       	mov    $0x0,%eax
80103d04:	eb 05                	jmp    80103d0b <munmap+0x150>

 }else{
   return -1;
80103d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 }
}
80103d0b:	c9                   	leave  
80103d0c:	c3                   	ret    

80103d0d <p2v>:
80103d0d:	55                   	push   %ebp
80103d0e:	89 e5                	mov    %esp,%ebp
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	05 00 00 00 80       	add    $0x80000000,%eax
80103d18:	5d                   	pop    %ebp
80103d19:	c3                   	ret    

80103d1a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103d1a:	55                   	push   %ebp
80103d1b:	89 e5                	mov    %esp,%ebp
80103d1d:	83 ec 14             	sub    $0x14,%esp
80103d20:	8b 45 08             	mov    0x8(%ebp),%eax
80103d23:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d27:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103d2b:	89 c2                	mov    %eax,%edx
80103d2d:	ec                   	in     (%dx),%al
80103d2e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103d31:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103d35:	c9                   	leave  
80103d36:	c3                   	ret    

80103d37 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d37:	55                   	push   %ebp
80103d38:	89 e5                	mov    %esp,%ebp
80103d3a:	83 ec 08             	sub    $0x8,%esp
80103d3d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d40:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d43:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d47:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d4a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d4e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d52:	ee                   	out    %al,(%dx)
}
80103d53:	90                   	nop
80103d54:	c9                   	leave  
80103d55:	c3                   	ret    

80103d56 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103d56:	55                   	push   %ebp
80103d57:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103d59:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103d5e:	89 c2                	mov    %eax,%edx
80103d60:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103d65:	29 c2                	sub    %eax,%edx
80103d67:	89 d0                	mov    %edx,%eax
80103d69:	c1 f8 02             	sar    $0x2,%eax
80103d6c:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103d72:	5d                   	pop    %ebp
80103d73:	c3                   	ret    

80103d74 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103d74:	55                   	push   %ebp
80103d75:	89 e5                	mov    %esp,%ebp
80103d77:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103d7a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103d81:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103d88:	eb 15                	jmp    80103d9f <sum+0x2b>
    sum += addr[i];
80103d8a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d90:	01 d0                	add    %edx,%eax
80103d92:	0f b6 00             	movzbl (%eax),%eax
80103d95:	0f b6 c0             	movzbl %al,%eax
80103d98:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103d9b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103da2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103da5:	7c e3                	jl     80103d8a <sum+0x16>
    sum += addr[i];
  return sum;
80103da7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103daa:	c9                   	leave  
80103dab:	c3                   	ret    

80103dac <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103dac:	55                   	push   %ebp
80103dad:	89 e5                	mov    %esp,%ebp
80103daf:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103db2:	ff 75 08             	pushl  0x8(%ebp)
80103db5:	e8 53 ff ff ff       	call   80103d0d <p2v>
80103dba:	83 c4 04             	add    $0x4,%esp
80103dbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc6:	01 d0                	add    %edx,%eax
80103dc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dd1:	eb 36                	jmp    80103e09 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103dd3:	83 ec 04             	sub    $0x4,%esp
80103dd6:	6a 04                	push   $0x4
80103dd8:	68 b4 98 10 80       	push   $0x801098b4
80103ddd:	ff 75 f4             	pushl  -0xc(%ebp)
80103de0:	e8 f5 20 00 00       	call   80105eda <memcmp>
80103de5:	83 c4 10             	add    $0x10,%esp
80103de8:	85 c0                	test   %eax,%eax
80103dea:	75 19                	jne    80103e05 <mpsearch1+0x59>
80103dec:	83 ec 08             	sub    $0x8,%esp
80103def:	6a 10                	push   $0x10
80103df1:	ff 75 f4             	pushl  -0xc(%ebp)
80103df4:	e8 7b ff ff ff       	call   80103d74 <sum>
80103df9:	83 c4 10             	add    $0x10,%esp
80103dfc:	84 c0                	test   %al,%al
80103dfe:	75 05                	jne    80103e05 <mpsearch1+0x59>
      return (struct mp*)p;
80103e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e03:	eb 11                	jmp    80103e16 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e05:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e0f:	72 c2                	jb     80103dd3 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e16:	c9                   	leave  
80103e17:	c3                   	ret    

80103e18 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e18:	55                   	push   %ebp
80103e19:	89 e5                	mov    %esp,%ebp
80103e1b:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e1e:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e28:	83 c0 0f             	add    $0xf,%eax
80103e2b:	0f b6 00             	movzbl (%eax),%eax
80103e2e:	0f b6 c0             	movzbl %al,%eax
80103e31:	c1 e0 08             	shl    $0x8,%eax
80103e34:	89 c2                	mov    %eax,%edx
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	83 c0 0e             	add    $0xe,%eax
80103e3c:	0f b6 00             	movzbl (%eax),%eax
80103e3f:	0f b6 c0             	movzbl %al,%eax
80103e42:	09 d0                	or     %edx,%eax
80103e44:	c1 e0 04             	shl    $0x4,%eax
80103e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e4a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e4e:	74 21                	je     80103e71 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103e50:	83 ec 08             	sub    $0x8,%esp
80103e53:	68 00 04 00 00       	push   $0x400
80103e58:	ff 75 f0             	pushl  -0x10(%ebp)
80103e5b:	e8 4c ff ff ff       	call   80103dac <mpsearch1>
80103e60:	83 c4 10             	add    $0x10,%esp
80103e63:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e66:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e6a:	74 51                	je     80103ebd <mpsearch+0xa5>
      return mp;
80103e6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e6f:	eb 61                	jmp    80103ed2 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e74:	83 c0 14             	add    $0x14,%eax
80103e77:	0f b6 00             	movzbl (%eax),%eax
80103e7a:	0f b6 c0             	movzbl %al,%eax
80103e7d:	c1 e0 08             	shl    $0x8,%eax
80103e80:	89 c2                	mov    %eax,%edx
80103e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e85:	83 c0 13             	add    $0x13,%eax
80103e88:	0f b6 00             	movzbl (%eax),%eax
80103e8b:	0f b6 c0             	movzbl %al,%eax
80103e8e:	09 d0                	or     %edx,%eax
80103e90:	c1 e0 0a             	shl    $0xa,%eax
80103e93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e99:	2d 00 04 00 00       	sub    $0x400,%eax
80103e9e:	83 ec 08             	sub    $0x8,%esp
80103ea1:	68 00 04 00 00       	push   $0x400
80103ea6:	50                   	push   %eax
80103ea7:	e8 00 ff ff ff       	call   80103dac <mpsearch1>
80103eac:	83 c4 10             	add    $0x10,%esp
80103eaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103eb2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103eb6:	74 05                	je     80103ebd <mpsearch+0xa5>
      return mp;
80103eb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ebb:	eb 15                	jmp    80103ed2 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ebd:	83 ec 08             	sub    $0x8,%esp
80103ec0:	68 00 00 01 00       	push   $0x10000
80103ec5:	68 00 00 0f 00       	push   $0xf0000
80103eca:	e8 dd fe ff ff       	call   80103dac <mpsearch1>
80103ecf:	83 c4 10             	add    $0x10,%esp
}
80103ed2:	c9                   	leave  
80103ed3:	c3                   	ret    

80103ed4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ed4:	55                   	push   %ebp
80103ed5:	89 e5                	mov    %esp,%ebp
80103ed7:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103eda:	e8 39 ff ff ff       	call   80103e18 <mpsearch>
80103edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ee2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ee6:	74 0a                	je     80103ef2 <mpconfig+0x1e>
80103ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eeb:	8b 40 04             	mov    0x4(%eax),%eax
80103eee:	85 c0                	test   %eax,%eax
80103ef0:	75 0a                	jne    80103efc <mpconfig+0x28>
    return 0;
80103ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ef7:	e9 81 00 00 00       	jmp    80103f7d <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eff:	8b 40 04             	mov    0x4(%eax),%eax
80103f02:	83 ec 0c             	sub    $0xc,%esp
80103f05:	50                   	push   %eax
80103f06:	e8 02 fe ff ff       	call   80103d0d <p2v>
80103f0b:	83 c4 10             	add    $0x10,%esp
80103f0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f11:	83 ec 04             	sub    $0x4,%esp
80103f14:	6a 04                	push   $0x4
80103f16:	68 b9 98 10 80       	push   $0x801098b9
80103f1b:	ff 75 f0             	pushl  -0x10(%ebp)
80103f1e:	e8 b7 1f 00 00       	call   80105eda <memcmp>
80103f23:	83 c4 10             	add    $0x10,%esp
80103f26:	85 c0                	test   %eax,%eax
80103f28:	74 07                	je     80103f31 <mpconfig+0x5d>
    return 0;
80103f2a:	b8 00 00 00 00       	mov    $0x0,%eax
80103f2f:	eb 4c                	jmp    80103f7d <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f34:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f38:	3c 01                	cmp    $0x1,%al
80103f3a:	74 12                	je     80103f4e <mpconfig+0x7a>
80103f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f3f:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f43:	3c 04                	cmp    $0x4,%al
80103f45:	74 07                	je     80103f4e <mpconfig+0x7a>
    return 0;
80103f47:	b8 00 00 00 00       	mov    $0x0,%eax
80103f4c:	eb 2f                	jmp    80103f7d <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f51:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103f55:	0f b7 c0             	movzwl %ax,%eax
80103f58:	83 ec 08             	sub    $0x8,%esp
80103f5b:	50                   	push   %eax
80103f5c:	ff 75 f0             	pushl  -0x10(%ebp)
80103f5f:	e8 10 fe ff ff       	call   80103d74 <sum>
80103f64:	83 c4 10             	add    $0x10,%esp
80103f67:	84 c0                	test   %al,%al
80103f69:	74 07                	je     80103f72 <mpconfig+0x9e>
    return 0;
80103f6b:	b8 00 00 00 00       	mov    $0x0,%eax
80103f70:	eb 0b                	jmp    80103f7d <mpconfig+0xa9>
  *pmp = mp;
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f78:	89 10                	mov    %edx,(%eax)
  return conf;
80103f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f7d:	c9                   	leave  
80103f7e:	c3                   	ret    

80103f7f <mpinit>:

void
mpinit(void)
{
80103f7f:	55                   	push   %ebp
80103f80:	89 e5                	mov    %esp,%ebp
80103f82:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103f85:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103f8c:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103f8f:	83 ec 0c             	sub    $0xc,%esp
80103f92:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103f95:	50                   	push   %eax
80103f96:	e8 39 ff ff ff       	call   80103ed4 <mpconfig>
80103f9b:	83 c4 10             	add    $0x10,%esp
80103f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103fa1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fa5:	0f 84 96 01 00 00    	je     80104141 <mpinit+0x1c2>
    return;
  ismp = 1;
80103fab:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103fb2:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fb8:	8b 40 24             	mov    0x24(%eax),%eax
80103fbb:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fc3:	83 c0 2c             	add    $0x2c,%eax
80103fc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fcc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103fd0:	0f b7 d0             	movzwl %ax,%edx
80103fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fd6:	01 d0                	add    %edx,%eax
80103fd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103fdb:	e9 f2 00 00 00       	jmp    801040d2 <mpinit+0x153>
    switch(*p){
80103fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe3:	0f b6 00             	movzbl (%eax),%eax
80103fe6:	0f b6 c0             	movzbl %al,%eax
80103fe9:	83 f8 04             	cmp    $0x4,%eax
80103fec:	0f 87 bc 00 00 00    	ja     801040ae <mpinit+0x12f>
80103ff2:	8b 04 85 fc 98 10 80 	mov    -0x7fef6704(,%eax,4),%eax
80103ff9:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffe:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104001:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104004:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104008:	0f b6 d0             	movzbl %al,%edx
8010400b:	a1 60 39 11 80       	mov    0x80113960,%eax
80104010:	39 c2                	cmp    %eax,%edx
80104012:	74 2b                	je     8010403f <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104014:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104017:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010401b:	0f b6 d0             	movzbl %al,%edx
8010401e:	a1 60 39 11 80       	mov    0x80113960,%eax
80104023:	83 ec 04             	sub    $0x4,%esp
80104026:	52                   	push   %edx
80104027:	50                   	push   %eax
80104028:	68 be 98 10 80       	push   $0x801098be
8010402d:	e8 94 c3 ff ff       	call   801003c6 <cprintf>
80104032:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80104035:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
8010403c:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010403f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104042:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104046:	0f b6 c0             	movzbl %al,%eax
80104049:	83 e0 02             	and    $0x2,%eax
8010404c:	85 c0                	test   %eax,%eax
8010404e:	74 15                	je     80104065 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104050:	a1 60 39 11 80       	mov    0x80113960,%eax
80104055:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010405b:	05 80 33 11 80       	add    $0x80113380,%eax
80104060:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80104065:	a1 60 39 11 80       	mov    0x80113960,%eax
8010406a:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80104070:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104076:	05 80 33 11 80       	add    $0x80113380,%eax
8010407b:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010407d:	a1 60 39 11 80       	mov    0x80113960,%eax
80104082:	83 c0 01             	add    $0x1,%eax
80104085:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
8010408a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010408e:	eb 42                	jmp    801040d2 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104093:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104096:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104099:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010409d:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
801040a2:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040a6:	eb 2a                	jmp    801040d2 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801040a8:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040ac:	eb 24                	jmp    801040d2 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801040ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b1:	0f b6 00             	movzbl (%eax),%eax
801040b4:	0f b6 c0             	movzbl %al,%eax
801040b7:	83 ec 08             	sub    $0x8,%esp
801040ba:	50                   	push   %eax
801040bb:	68 dc 98 10 80       	push   $0x801098dc
801040c0:	e8 01 c3 ff ff       	call   801003c6 <cprintf>
801040c5:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
801040c8:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
801040cf:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801040d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801040d8:	0f 82 02 ff ff ff    	jb     80103fe0 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801040de:	a1 64 33 11 80       	mov    0x80113364,%eax
801040e3:	85 c0                	test   %eax,%eax
801040e5:	75 1d                	jne    80104104 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801040e7:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
801040ee:	00 00 00 
    lapic = 0;
801040f1:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
801040f8:	00 00 00 
    ioapicid = 0;
801040fb:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80104102:	eb 3e                	jmp    80104142 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80104104:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104107:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010410b:	84 c0                	test   %al,%al
8010410d:	74 33                	je     80104142 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010410f:	83 ec 08             	sub    $0x8,%esp
80104112:	6a 70                	push   $0x70
80104114:	6a 22                	push   $0x22
80104116:	e8 1c fc ff ff       	call   80103d37 <outb>
8010411b:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010411e:	83 ec 0c             	sub    $0xc,%esp
80104121:	6a 23                	push   $0x23
80104123:	e8 f2 fb ff ff       	call   80103d1a <inb>
80104128:	83 c4 10             	add    $0x10,%esp
8010412b:	83 c8 01             	or     $0x1,%eax
8010412e:	0f b6 c0             	movzbl %al,%eax
80104131:	83 ec 08             	sub    $0x8,%esp
80104134:	50                   	push   %eax
80104135:	6a 23                	push   $0x23
80104137:	e8 fb fb ff ff       	call   80103d37 <outb>
8010413c:	83 c4 10             	add    $0x10,%esp
8010413f:	eb 01                	jmp    80104142 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104141:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104142:	c9                   	leave  
80104143:	c3                   	ret    

80104144 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104144:	55                   	push   %ebp
80104145:	89 e5                	mov    %esp,%ebp
80104147:	83 ec 08             	sub    $0x8,%esp
8010414a:	8b 55 08             	mov    0x8(%ebp),%edx
8010414d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104150:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104154:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104157:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010415b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010415f:	ee                   	out    %al,(%dx)
}
80104160:	90                   	nop
80104161:	c9                   	leave  
80104162:	c3                   	ret    

80104163 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104163:	55                   	push   %ebp
80104164:	89 e5                	mov    %esp,%ebp
80104166:	83 ec 04             	sub    $0x4,%esp
80104169:	8b 45 08             	mov    0x8(%ebp),%eax
8010416c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104170:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104174:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
8010417a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010417e:	0f b6 c0             	movzbl %al,%eax
80104181:	50                   	push   %eax
80104182:	6a 21                	push   $0x21
80104184:	e8 bb ff ff ff       	call   80104144 <outb>
80104189:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
8010418c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104190:	66 c1 e8 08          	shr    $0x8,%ax
80104194:	0f b6 c0             	movzbl %al,%eax
80104197:	50                   	push   %eax
80104198:	68 a1 00 00 00       	push   $0xa1
8010419d:	e8 a2 ff ff ff       	call   80104144 <outb>
801041a2:	83 c4 08             	add    $0x8,%esp
}
801041a5:	90                   	nop
801041a6:	c9                   	leave  
801041a7:	c3                   	ret    

801041a8 <picenable>:

void
picenable(int irq)
{
801041a8:	55                   	push   %ebp
801041a9:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
801041ab:	8b 45 08             	mov    0x8(%ebp),%eax
801041ae:	ba 01 00 00 00       	mov    $0x1,%edx
801041b3:	89 c1                	mov    %eax,%ecx
801041b5:	d3 e2                	shl    %cl,%edx
801041b7:	89 d0                	mov    %edx,%eax
801041b9:	f7 d0                	not    %eax
801041bb:	89 c2                	mov    %eax,%edx
801041bd:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801041c4:	21 d0                	and    %edx,%eax
801041c6:	0f b7 c0             	movzwl %ax,%eax
801041c9:	50                   	push   %eax
801041ca:	e8 94 ff ff ff       	call   80104163 <picsetmask>
801041cf:	83 c4 04             	add    $0x4,%esp
}
801041d2:	90                   	nop
801041d3:	c9                   	leave  
801041d4:	c3                   	ret    

801041d5 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801041d5:	55                   	push   %ebp
801041d6:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801041d8:	68 ff 00 00 00       	push   $0xff
801041dd:	6a 21                	push   $0x21
801041df:	e8 60 ff ff ff       	call   80104144 <outb>
801041e4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801041e7:	68 ff 00 00 00       	push   $0xff
801041ec:	68 a1 00 00 00       	push   $0xa1
801041f1:	e8 4e ff ff ff       	call   80104144 <outb>
801041f6:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801041f9:	6a 11                	push   $0x11
801041fb:	6a 20                	push   $0x20
801041fd:	e8 42 ff ff ff       	call   80104144 <outb>
80104202:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104205:	6a 20                	push   $0x20
80104207:	6a 21                	push   $0x21
80104209:	e8 36 ff ff ff       	call   80104144 <outb>
8010420e:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104211:	6a 04                	push   $0x4
80104213:	6a 21                	push   $0x21
80104215:	e8 2a ff ff ff       	call   80104144 <outb>
8010421a:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010421d:	6a 03                	push   $0x3
8010421f:	6a 21                	push   $0x21
80104221:	e8 1e ff ff ff       	call   80104144 <outb>
80104226:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104229:	6a 11                	push   $0x11
8010422b:	68 a0 00 00 00       	push   $0xa0
80104230:	e8 0f ff ff ff       	call   80104144 <outb>
80104235:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104238:	6a 28                	push   $0x28
8010423a:	68 a1 00 00 00       	push   $0xa1
8010423f:	e8 00 ff ff ff       	call   80104144 <outb>
80104244:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104247:	6a 02                	push   $0x2
80104249:	68 a1 00 00 00       	push   $0xa1
8010424e:	e8 f1 fe ff ff       	call   80104144 <outb>
80104253:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104256:	6a 03                	push   $0x3
80104258:	68 a1 00 00 00       	push   $0xa1
8010425d:	e8 e2 fe ff ff       	call   80104144 <outb>
80104262:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104265:	6a 68                	push   $0x68
80104267:	6a 20                	push   $0x20
80104269:	e8 d6 fe ff ff       	call   80104144 <outb>
8010426e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104271:	6a 0a                	push   $0xa
80104273:	6a 20                	push   $0x20
80104275:	e8 ca fe ff ff       	call   80104144 <outb>
8010427a:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010427d:	6a 68                	push   $0x68
8010427f:	68 a0 00 00 00       	push   $0xa0
80104284:	e8 bb fe ff ff       	call   80104144 <outb>
80104289:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010428c:	6a 0a                	push   $0xa
8010428e:	68 a0 00 00 00       	push   $0xa0
80104293:	e8 ac fe ff ff       	call   80104144 <outb>
80104298:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010429b:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801042a2:	66 83 f8 ff          	cmp    $0xffff,%ax
801042a6:	74 13                	je     801042bb <picinit+0xe6>
    picsetmask(irqmask);
801042a8:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801042af:	0f b7 c0             	movzwl %ax,%eax
801042b2:	50                   	push   %eax
801042b3:	e8 ab fe ff ff       	call   80104163 <picsetmask>
801042b8:	83 c4 04             	add    $0x4,%esp
}
801042bb:	90                   	nop
801042bc:	c9                   	leave  
801042bd:	c3                   	ret    

801042be <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801042be:	55                   	push   %ebp
801042bf:	89 e5                	mov    %esp,%ebp
801042c1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801042c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801042cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801042d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d7:	8b 10                	mov    (%eax),%edx
801042d9:	8b 45 08             	mov    0x8(%ebp),%eax
801042dc:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801042de:	e8 9d cc ff ff       	call   80100f80 <filealloc>
801042e3:	89 c2                	mov    %eax,%edx
801042e5:	8b 45 08             	mov    0x8(%ebp),%eax
801042e8:	89 10                	mov    %edx,(%eax)
801042ea:	8b 45 08             	mov    0x8(%ebp),%eax
801042ed:	8b 00                	mov    (%eax),%eax
801042ef:	85 c0                	test   %eax,%eax
801042f1:	0f 84 cb 00 00 00    	je     801043c2 <pipealloc+0x104>
801042f7:	e8 84 cc ff ff       	call   80100f80 <filealloc>
801042fc:	89 c2                	mov    %eax,%edx
801042fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104301:	89 10                	mov    %edx,(%eax)
80104303:	8b 45 0c             	mov    0xc(%ebp),%eax
80104306:	8b 00                	mov    (%eax),%eax
80104308:	85 c0                	test   %eax,%eax
8010430a:	0f 84 b2 00 00 00    	je     801043c2 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104310:	e8 13 e9 ff ff       	call   80102c28 <kalloc>
80104315:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104318:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010431c:	0f 84 9f 00 00 00    	je     801043c1 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104325:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010432c:	00 00 00 
  p->writeopen = 1;
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104339:	00 00 00 
  p->nwrite = 0;
8010433c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104346:	00 00 00 
  p->nread = 0;
80104349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434c:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104353:	00 00 00 
  initlock(&p->lock, "pipe");
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104359:	83 ec 08             	sub    $0x8,%esp
8010435c:	68 10 99 10 80       	push   $0x80109910
80104361:	50                   	push   %eax
80104362:	e8 87 18 00 00       	call   80105bee <initlock>
80104367:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010436a:	8b 45 08             	mov    0x8(%ebp),%eax
8010436d:	8b 00                	mov    (%eax),%eax
8010436f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104375:	8b 45 08             	mov    0x8(%ebp),%eax
80104378:	8b 00                	mov    (%eax),%eax
8010437a:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010437e:	8b 45 08             	mov    0x8(%ebp),%eax
80104381:	8b 00                	mov    (%eax),%eax
80104383:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104387:	8b 45 08             	mov    0x8(%ebp),%eax
8010438a:	8b 00                	mov    (%eax),%eax
8010438c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438f:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104392:	8b 45 0c             	mov    0xc(%ebp),%eax
80104395:	8b 00                	mov    (%eax),%eax
80104397:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010439d:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a0:	8b 00                	mov    (%eax),%eax
801043a2:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801043a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a9:	8b 00                	mov    (%eax),%eax
801043ab:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801043af:	8b 45 0c             	mov    0xc(%ebp),%eax
801043b2:	8b 00                	mov    (%eax),%eax
801043b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b7:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801043ba:	b8 00 00 00 00       	mov    $0x0,%eax
801043bf:	eb 4e                	jmp    8010440f <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801043c1:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801043c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043c6:	74 0e                	je     801043d6 <pipealloc+0x118>
    kfree((char*)p);
801043c8:	83 ec 0c             	sub    $0xc,%esp
801043cb:	ff 75 f4             	pushl  -0xc(%ebp)
801043ce:	e8 b8 e7 ff ff       	call   80102b8b <kfree>
801043d3:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801043d6:	8b 45 08             	mov    0x8(%ebp),%eax
801043d9:	8b 00                	mov    (%eax),%eax
801043db:	85 c0                	test   %eax,%eax
801043dd:	74 11                	je     801043f0 <pipealloc+0x132>
    fileclose(*f0);
801043df:	8b 45 08             	mov    0x8(%ebp),%eax
801043e2:	8b 00                	mov    (%eax),%eax
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	50                   	push   %eax
801043e8:	e8 51 cc ff ff       	call   8010103e <fileclose>
801043ed:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801043f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801043f3:	8b 00                	mov    (%eax),%eax
801043f5:	85 c0                	test   %eax,%eax
801043f7:	74 11                	je     8010440a <pipealloc+0x14c>
    fileclose(*f1);
801043f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801043fc:	8b 00                	mov    (%eax),%eax
801043fe:	83 ec 0c             	sub    $0xc,%esp
80104401:	50                   	push   %eax
80104402:	e8 37 cc ff ff       	call   8010103e <fileclose>
80104407:	83 c4 10             	add    $0x10,%esp
  return -1;
8010440a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010440f:	c9                   	leave  
80104410:	c3                   	ret    

80104411 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104411:	55                   	push   %ebp
80104412:	89 e5                	mov    %esp,%ebp
80104414:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104417:	8b 45 08             	mov    0x8(%ebp),%eax
8010441a:	83 ec 0c             	sub    $0xc,%esp
8010441d:	50                   	push   %eax
8010441e:	e8 ed 17 00 00       	call   80105c10 <acquire>
80104423:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104426:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010442a:	74 23                	je     8010444f <pipeclose+0x3e>
    p->writeopen = 0;
8010442c:	8b 45 08             	mov    0x8(%ebp),%eax
8010442f:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104436:	00 00 00 
    wakeup(&p->nread);
80104439:	8b 45 08             	mov    0x8(%ebp),%eax
8010443c:	05 34 02 00 00       	add    $0x234,%eax
80104441:	83 ec 0c             	sub    $0xc,%esp
80104444:	50                   	push   %eax
80104445:	e8 16 11 00 00       	call   80105560 <wakeup>
8010444a:	83 c4 10             	add    $0x10,%esp
8010444d:	eb 21                	jmp    80104470 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010444f:	8b 45 08             	mov    0x8(%ebp),%eax
80104452:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104459:	00 00 00 
    wakeup(&p->nwrite);
8010445c:	8b 45 08             	mov    0x8(%ebp),%eax
8010445f:	05 38 02 00 00       	add    $0x238,%eax
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	50                   	push   %eax
80104468:	e8 f3 10 00 00       	call   80105560 <wakeup>
8010446d:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104470:	8b 45 08             	mov    0x8(%ebp),%eax
80104473:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104479:	85 c0                	test   %eax,%eax
8010447b:	75 2c                	jne    801044a9 <pipeclose+0x98>
8010447d:	8b 45 08             	mov    0x8(%ebp),%eax
80104480:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104486:	85 c0                	test   %eax,%eax
80104488:	75 1f                	jne    801044a9 <pipeclose+0x98>
    release(&p->lock);
8010448a:	8b 45 08             	mov    0x8(%ebp),%eax
8010448d:	83 ec 0c             	sub    $0xc,%esp
80104490:	50                   	push   %eax
80104491:	e8 e1 17 00 00       	call   80105c77 <release>
80104496:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104499:	83 ec 0c             	sub    $0xc,%esp
8010449c:	ff 75 08             	pushl  0x8(%ebp)
8010449f:	e8 e7 e6 ff ff       	call   80102b8b <kfree>
801044a4:	83 c4 10             	add    $0x10,%esp
801044a7:	eb 0f                	jmp    801044b8 <pipeclose+0xa7>
  } else
    release(&p->lock);
801044a9:	8b 45 08             	mov    0x8(%ebp),%eax
801044ac:	83 ec 0c             	sub    $0xc,%esp
801044af:	50                   	push   %eax
801044b0:	e8 c2 17 00 00       	call   80105c77 <release>
801044b5:	83 c4 10             	add    $0x10,%esp
}
801044b8:	90                   	nop
801044b9:	c9                   	leave  
801044ba:	c3                   	ret    

801044bb <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801044bb:	55                   	push   %ebp
801044bc:	89 e5                	mov    %esp,%ebp
801044be:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801044c1:	8b 45 08             	mov    0x8(%ebp),%eax
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	50                   	push   %eax
801044c8:	e8 43 17 00 00       	call   80105c10 <acquire>
801044cd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801044d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044d7:	e9 ad 00 00 00       	jmp    80104589 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801044dc:	8b 45 08             	mov    0x8(%ebp),%eax
801044df:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801044e5:	85 c0                	test   %eax,%eax
801044e7:	74 0d                	je     801044f6 <pipewrite+0x3b>
801044e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044ef:	8b 40 24             	mov    0x24(%eax),%eax
801044f2:	85 c0                	test   %eax,%eax
801044f4:	74 19                	je     8010450f <pipewrite+0x54>
        release(&p->lock);
801044f6:	8b 45 08             	mov    0x8(%ebp),%eax
801044f9:	83 ec 0c             	sub    $0xc,%esp
801044fc:	50                   	push   %eax
801044fd:	e8 75 17 00 00       	call   80105c77 <release>
80104502:	83 c4 10             	add    $0x10,%esp
        return -1;
80104505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010450a:	e9 a8 00 00 00       	jmp    801045b7 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010450f:	8b 45 08             	mov    0x8(%ebp),%eax
80104512:	05 34 02 00 00       	add    $0x234,%eax
80104517:	83 ec 0c             	sub    $0xc,%esp
8010451a:	50                   	push   %eax
8010451b:	e8 40 10 00 00       	call   80105560 <wakeup>
80104520:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104523:	8b 45 08             	mov    0x8(%ebp),%eax
80104526:	8b 55 08             	mov    0x8(%ebp),%edx
80104529:	81 c2 38 02 00 00    	add    $0x238,%edx
8010452f:	83 ec 08             	sub    $0x8,%esp
80104532:	50                   	push   %eax
80104533:	52                   	push   %edx
80104534:	e8 1b 0f 00 00       	call   80105454 <sleep>
80104539:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010453c:	8b 45 08             	mov    0x8(%ebp),%eax
8010453f:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104545:	8b 45 08             	mov    0x8(%ebp),%eax
80104548:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010454e:	05 00 02 00 00       	add    $0x200,%eax
80104553:	39 c2                	cmp    %eax,%edx
80104555:	74 85                	je     801044dc <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104557:	8b 45 08             	mov    0x8(%ebp),%eax
8010455a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104560:	8d 48 01             	lea    0x1(%eax),%ecx
80104563:	8b 55 08             	mov    0x8(%ebp),%edx
80104566:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010456c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104571:	89 c1                	mov    %eax,%ecx
80104573:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104576:	8b 45 0c             	mov    0xc(%ebp),%eax
80104579:	01 d0                	add    %edx,%eax
8010457b:	0f b6 10             	movzbl (%eax),%edx
8010457e:	8b 45 08             	mov    0x8(%ebp),%eax
80104581:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010458f:	7c ab                	jl     8010453c <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104591:	8b 45 08             	mov    0x8(%ebp),%eax
80104594:	05 34 02 00 00       	add    $0x234,%eax
80104599:	83 ec 0c             	sub    $0xc,%esp
8010459c:	50                   	push   %eax
8010459d:	e8 be 0f 00 00       	call   80105560 <wakeup>
801045a2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801045a5:	8b 45 08             	mov    0x8(%ebp),%eax
801045a8:	83 ec 0c             	sub    $0xc,%esp
801045ab:	50                   	push   %eax
801045ac:	e8 c6 16 00 00       	call   80105c77 <release>
801045b1:	83 c4 10             	add    $0x10,%esp
  return n;
801045b4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801045b7:	c9                   	leave  
801045b8:	c3                   	ret    

801045b9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801045b9:	55                   	push   %ebp
801045ba:	89 e5                	mov    %esp,%ebp
801045bc:	53                   	push   %ebx
801045bd:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801045c0:	8b 45 08             	mov    0x8(%ebp),%eax
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	50                   	push   %eax
801045c7:	e8 44 16 00 00       	call   80105c10 <acquire>
801045cc:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801045cf:	eb 3f                	jmp    80104610 <piperead+0x57>
    if(proc->killed){
801045d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d7:	8b 40 24             	mov    0x24(%eax),%eax
801045da:	85 c0                	test   %eax,%eax
801045dc:	74 19                	je     801045f7 <piperead+0x3e>
      release(&p->lock);
801045de:	8b 45 08             	mov    0x8(%ebp),%eax
801045e1:	83 ec 0c             	sub    $0xc,%esp
801045e4:	50                   	push   %eax
801045e5:	e8 8d 16 00 00       	call   80105c77 <release>
801045ea:	83 c4 10             	add    $0x10,%esp
      return -1;
801045ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f2:	e9 bf 00 00 00       	jmp    801046b6 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801045f7:	8b 45 08             	mov    0x8(%ebp),%eax
801045fa:	8b 55 08             	mov    0x8(%ebp),%edx
801045fd:	81 c2 34 02 00 00    	add    $0x234,%edx
80104603:	83 ec 08             	sub    $0x8,%esp
80104606:	50                   	push   %eax
80104607:	52                   	push   %edx
80104608:	e8 47 0e 00 00       	call   80105454 <sleep>
8010460d:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104610:	8b 45 08             	mov    0x8(%ebp),%eax
80104613:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104619:	8b 45 08             	mov    0x8(%ebp),%eax
8010461c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104622:	39 c2                	cmp    %eax,%edx
80104624:	75 0d                	jne    80104633 <piperead+0x7a>
80104626:	8b 45 08             	mov    0x8(%ebp),%eax
80104629:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010462f:	85 c0                	test   %eax,%eax
80104631:	75 9e                	jne    801045d1 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104633:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010463a:	eb 49                	jmp    80104685 <piperead+0xcc>
    if(p->nread == p->nwrite)
8010463c:	8b 45 08             	mov    0x8(%ebp),%eax
8010463f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104645:	8b 45 08             	mov    0x8(%ebp),%eax
80104648:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010464e:	39 c2                	cmp    %eax,%edx
80104650:	74 3d                	je     8010468f <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104655:	8b 45 0c             	mov    0xc(%ebp),%eax
80104658:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010465b:	8b 45 08             	mov    0x8(%ebp),%eax
8010465e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104664:	8d 48 01             	lea    0x1(%eax),%ecx
80104667:	8b 55 08             	mov    0x8(%ebp),%edx
8010466a:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104670:	25 ff 01 00 00       	and    $0x1ff,%eax
80104675:	89 c2                	mov    %eax,%edx
80104677:	8b 45 08             	mov    0x8(%ebp),%eax
8010467a:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010467f:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104681:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104688:	3b 45 10             	cmp    0x10(%ebp),%eax
8010468b:	7c af                	jl     8010463c <piperead+0x83>
8010468d:	eb 01                	jmp    80104690 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
8010468f:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104690:	8b 45 08             	mov    0x8(%ebp),%eax
80104693:	05 38 02 00 00       	add    $0x238,%eax
80104698:	83 ec 0c             	sub    $0xc,%esp
8010469b:	50                   	push   %eax
8010469c:	e8 bf 0e 00 00       	call   80105560 <wakeup>
801046a1:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801046a4:	8b 45 08             	mov    0x8(%ebp),%eax
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	50                   	push   %eax
801046ab:	e8 c7 15 00 00       	call   80105c77 <release>
801046b0:	83 c4 10             	add    $0x10,%esp
  return i;
801046b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046b9:	c9                   	leave  
801046ba:	c3                   	ret    

801046bb <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801046bb:	55                   	push   %ebp
801046bc:	89 e5                	mov    %esp,%ebp
801046be:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046c1:	9c                   	pushf  
801046c2:	58                   	pop    %eax
801046c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046c9:	c9                   	leave  
801046ca:	c3                   	ret    

801046cb <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801046cb:	55                   	push   %ebp
801046cc:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046ce:	fb                   	sti    
}
801046cf:	90                   	nop
801046d0:	5d                   	pop    %ebp
801046d1:	c3                   	ret    

801046d2 <make_runnable>:
} ptable;

//enqueue the process in the corresponding priority
static void
make_runnable(struct proc* p)
{
801046d2:	55                   	push   %ebp
801046d3:	89 e5                	mov    %esp,%ebp
  if(ptable.mlf[p->priority].last==0){
801046d5:	8b 45 08             	mov    0x8(%ebp),%eax
801046d8:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046dc:	0f b7 c0             	movzwl %ax,%eax
801046df:	05 e6 06 00 00       	add    $0x6e6,%eax
801046e4:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
801046eb:	85 c0                	test   %eax,%eax
801046ed:	75 1c                	jne    8010470b <make_runnable+0x39>
    ptable.mlf[p->priority].first = p;
801046ef:	8b 45 08             	mov    0x8(%ebp),%eax
801046f2:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801046f6:	0f b7 c0             	movzwl %ax,%eax
801046f9:	8d 90 e6 06 00 00    	lea    0x6e6(%eax),%edx
801046ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104702:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
80104709:	eb 1f                	jmp    8010472a <make_runnable+0x58>
  } else{
    ptable.mlf[p->priority].last->next = p;
8010470b:	8b 45 08             	mov    0x8(%ebp),%eax
8010470e:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104712:	0f b7 c0             	movzwl %ax,%eax
80104715:	05 e6 06 00 00       	add    $0x6e6,%eax
8010471a:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
80104721:	8b 55 08             	mov    0x8(%ebp),%edx
80104724:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
  ptable.mlf[p->priority].last=p;
8010472a:	8b 45 08             	mov    0x8(%ebp),%eax
8010472d:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104731:	0f b7 c0             	movzwl %ax,%eax
80104734:	8d 90 e6 06 00 00    	lea    0x6e6(%eax),%edx
8010473a:	8b 45 08             	mov    0x8(%ebp),%eax
8010473d:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
  p->next=0;
80104744:	8b 45 08             	mov    0x8(%ebp),%eax
80104747:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010474e:	00 00 00 
  p->age=0;
80104751:	8b 45 08             	mov    0x8(%ebp),%eax
80104754:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
8010475b:	00 00 
  p->state=RUNNABLE;
8010475d:	8b 45 08             	mov    0x8(%ebp),%eax
80104760:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104767:	90                   	nop
80104768:	5d                   	pop    %ebp
80104769:	c3                   	ret    

8010476a <unqueue>:

//dequeue first element of the level "level"
static struct proc*
unqueue(int level)
{
8010476a:	55                   	push   %ebp
8010476b:	89 e5                	mov    %esp,%ebp
8010476d:	83 ec 18             	sub    $0x18,%esp
  struct proc* p=ptable.mlf[level].first;
80104770:	8b 45 08             	mov    0x8(%ebp),%eax
80104773:	05 e6 06 00 00       	add    $0x6e6,%eax
80104778:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
8010477f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!ptable.mlf[level].first)
80104782:	8b 45 08             	mov    0x8(%ebp),%eax
80104785:	05 e6 06 00 00       	add    $0x6e6,%eax
8010478a:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80104791:	85 c0                	test   %eax,%eax
80104793:	75 0d                	jne    801047a2 <unqueue+0x38>
    panic("empty level");
80104795:	83 ec 0c             	sub    $0xc,%esp
80104798:	68 18 99 10 80       	push   $0x80109918
8010479d:	e8 c4 bd ff ff       	call   80100566 <panic>
  if(ptable.mlf[level].first==ptable.mlf[level].last){
801047a2:	8b 45 08             	mov    0x8(%ebp),%eax
801047a5:	05 e6 06 00 00       	add    $0x6e6,%eax
801047aa:	8b 14 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%edx
801047b1:	8b 45 08             	mov    0x8(%ebp),%eax
801047b4:	05 e6 06 00 00       	add    $0x6e6,%eax
801047b9:	8b 04 c5 88 39 11 80 	mov    -0x7feec678(,%eax,8),%eax
801047c0:	39 c2                	cmp    %eax,%edx
801047c2:	75 34                	jne    801047f8 <unqueue+0x8e>
    ptable.mlf[level].last = ptable.mlf[level].first = 0;
801047c4:	8b 45 08             	mov    0x8(%ebp),%eax
801047c7:	05 e6 06 00 00       	add    $0x6e6,%eax
801047cc:	c7 04 c5 84 39 11 80 	movl   $0x0,-0x7feec67c(,%eax,8)
801047d3:	00 00 00 00 
801047d7:	8b 45 08             	mov    0x8(%ebp),%eax
801047da:	05 e6 06 00 00       	add    $0x6e6,%eax
801047df:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801047e6:	8b 55 08             	mov    0x8(%ebp),%edx
801047e9:	81 c2 e6 06 00 00    	add    $0x6e6,%edx
801047ef:	89 04 d5 88 39 11 80 	mov    %eax,-0x7feec678(,%edx,8)
801047f6:	eb 19                	jmp    80104811 <unqueue+0xa7>
  }else{
    ptable.mlf[level].first=p->next;
801047f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104801:	8b 55 08             	mov    0x8(%ebp),%edx
80104804:	81 c2 e6 06 00 00    	add    $0x6e6,%edx
8010480a:	89 04 d5 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,8)
  }
  if(p->state!=RUNNABLE)
80104811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104814:	8b 40 0c             	mov    0xc(%eax),%eax
80104817:	83 f8 03             	cmp    $0x3,%eax
8010481a:	74 0d                	je     80104829 <unqueue+0xbf>
    panic("unqueue not RUNNABLE process");
8010481c:	83 ec 0c             	sub    $0xc,%esp
8010481f:	68 24 99 10 80       	push   $0x80109924
80104824:	e8 3d bd ff ff       	call   80100566 <panic>
  return p;
80104829:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010482c:	c9                   	leave  
8010482d:	c3                   	ret    

8010482e <levelupdate>:

//unqueue the process, it increases the priority if it corresponds, and queues it in the new level.
static void
levelupdate(struct proc* p)
{
8010482e:	55                   	push   %ebp
8010482f:	89 e5                	mov    %esp,%ebp
80104831:	83 ec 08             	sub    $0x8,%esp
  unqueue(p->priority);
80104834:	8b 45 08             	mov    0x8(%ebp),%eax
80104837:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010483b:	0f b7 c0             	movzwl %ax,%eax
8010483e:	83 ec 0c             	sub    $0xc,%esp
80104841:	50                   	push   %eax
80104842:	e8 23 ff ff ff       	call   8010476a <unqueue>
80104847:	83 c4 10             	add    $0x10,%esp
  if(p->priority>MLFMAXPRIORITY)
8010484a:	8b 45 08             	mov    0x8(%ebp),%eax
8010484d:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80104851:	66 85 c0             	test   %ax,%ax
80104854:	74 11                	je     80104867 <levelupdate+0x39>
    p->priority--;
80104856:	8b 45 08             	mov    0x8(%ebp),%eax
80104859:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010485d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104860:	8b 45 08             	mov    0x8(%ebp),%eax
80104863:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(p);
80104867:	83 ec 0c             	sub    $0xc,%esp
8010486a:	ff 75 08             	pushl  0x8(%ebp)
8010486d:	e8 60 fe ff ff       	call   801046d2 <make_runnable>
80104872:	83 c4 10             	add    $0x10,%esp
}
80104875:	90                   	nop
80104876:	c9                   	leave  
80104877:	c3                   	ret    

80104878 <calculateaging>:

//go through MLF, looking for processes that reach AGEFORAGINGS and raise the priority.
//call procdump to show them.
void
calculateaging(void)
{
80104878:	55                   	push   %ebp
80104879:	89 e5                	mov    %esp,%ebp
8010487b:	83 ec 18             	sub    $0x18,%esp
  struct proc* p;
  int l;
  acquire(&ptable.lock);
8010487e:	83 ec 0c             	sub    $0xc,%esp
80104881:	68 80 39 11 80       	push   $0x80113980
80104886:	e8 85 13 00 00       	call   80105c10 <acquire>
8010488b:	83 c4 10             	add    $0x10,%esp
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
8010488e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104895:	e9 a7 00 00 00       	jmp    80104941 <calculateaging+0xc9>
    p=ptable.mlf[l].first;
8010489a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489d:	05 e6 06 00 00       	add    $0x6e6,%eax
801048a2:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801048a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p){
801048ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801048b0:	0f 84 87 00 00 00    	je     8010493d <calculateaging+0xc5>
      p->age++;  // increase the age to the process
801048b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b9:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801048c0:	8d 50 01             	lea    0x1(%eax),%edx
801048c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c6:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      //procdump();
      if(p->age == AGEFORAGINGS){
801048cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d0:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801048d7:	66 83 f8 05          	cmp    $0x5,%ax
801048db:	75 60                	jne    8010493d <calculateaging+0xc5>
        if(ptable.mlf[p->priority].first!=p)
801048dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e0:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801048e4:	0f b7 c0             	movzwl %ax,%eax
801048e7:	05 e6 06 00 00       	add    $0x6e6,%eax
801048ec:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801048f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801048f6:	74 0d                	je     80104905 <calculateaging+0x8d>
          panic("it does not eliminate the first element of the level.");
801048f8:	83 ec 0c             	sub    $0xc,%esp
801048fb:	68 44 99 10 80       	push   $0x80109944
80104900:	e8 61 bc ff ff       	call   80100566 <panic>
        procdump();
80104905:	e8 18 0d 00 00       	call   80105622 <procdump>
        cprintf("/**************************************************************/\n");
8010490a:	83 ec 0c             	sub    $0xc,%esp
8010490d:	68 7c 99 10 80       	push   $0x8010997c
80104912:	e8 af ba ff ff       	call   801003c6 <cprintf>
80104917:	83 c4 10             	add    $0x10,%esp
        levelupdate(p);  // call to levelupdate
8010491a:	83 ec 0c             	sub    $0xc,%esp
8010491d:	ff 75 f0             	pushl  -0x10(%ebp)
80104920:	e8 09 ff ff ff       	call   8010482e <levelupdate>
80104925:	83 c4 10             	add    $0x10,%esp
        procdump();
80104928:	e8 f5 0c 00 00       	call   80105622 <procdump>
        cprintf("/--------------------------------------------------------------/\n");
8010492d:	83 ec 0c             	sub    $0xc,%esp
80104930:	68 c0 99 10 80       	push   $0x801099c0
80104935:	e8 8c ba ff ff       	call   801003c6 <cprintf>
8010493a:	83 c4 10             	add    $0x10,%esp
calculateaging(void)
{
  struct proc* p;
  int l;
  acquire(&ptable.lock);
  for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
8010493d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104941:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80104945:	0f 8e 4f ff ff ff    	jle    8010489a <calculateaging+0x22>
        procdump();
        cprintf("/--------------------------------------------------------------/\n");
      }
    }
  }
  release(&ptable.lock);
8010494b:	83 ec 0c             	sub    $0xc,%esp
8010494e:	68 80 39 11 80       	push   $0x80113980
80104953:	e8 1f 13 00 00       	call   80105c77 <release>
80104958:	83 c4 10             	add    $0x10,%esp
}
8010495b:	90                   	nop
8010495c:	c9                   	leave  
8010495d:	c3                   	ret    

8010495e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010495e:	55                   	push   %ebp
8010495f:	89 e5                	mov    %esp,%ebp
80104961:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104964:	83 ec 08             	sub    $0x8,%esp
80104967:	68 02 9a 10 80       	push   $0x80109a02
8010496c:	68 80 39 11 80       	push   $0x80113980
80104971:	e8 78 12 00 00       	call   80105bee <initlock>
80104976:	83 c4 10             	add    $0x10,%esp
}
80104979:	90                   	nop
8010497a:	c9                   	leave  
8010497b:	c3                   	ret    

8010497c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010497c:	55                   	push   %ebp
8010497d:	89 e5                	mov    %esp,%ebp
8010497f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104982:	83 ec 0c             	sub    $0xc,%esp
80104985:	68 80 39 11 80       	push   $0x80113980
8010498a:	e8 81 12 00 00       	call   80105c10 <acquire>
8010498f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104992:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104999:	eb 11                	jmp    801049ac <allocproc+0x30>
    if(p->state == UNUSED)
8010499b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499e:	8b 40 0c             	mov    0xc(%eax),%eax
801049a1:	85 c0                	test   %eax,%eax
801049a3:	74 2a                	je     801049cf <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801049a5:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
801049ac:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
801049b3:	72 e6                	jb     8010499b <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801049b5:	83 ec 0c             	sub    $0xc,%esp
801049b8:	68 80 39 11 80       	push   $0x80113980
801049bd:	e8 b5 12 00 00       	call   80105c77 <release>
801049c2:	83 c4 10             	add    $0x10,%esp
  return 0;
801049c5:	b8 00 00 00 00       	mov    $0x0,%eax
801049ca:	e9 c9 00 00 00       	jmp    80104a98 <allocproc+0x11c>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801049cf:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801049d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d3:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801049da:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801049df:	8d 50 01             	lea    0x1(%eax),%edx
801049e2:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801049e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049eb:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801049ee:	83 ec 0c             	sub    $0xc,%esp
801049f1:	68 80 39 11 80       	push   $0x80113980
801049f6:	e8 7c 12 00 00       	call   80105c77 <release>
801049fb:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801049fe:	e8 25 e2 ff ff       	call   80102c28 <kalloc>
80104a03:	89 c2                	mov    %eax,%edx
80104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a08:	89 50 08             	mov    %edx,0x8(%eax)
80104a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0e:	8b 40 08             	mov    0x8(%eax),%eax
80104a11:	85 c0                	test   %eax,%eax
80104a13:	75 11                	jne    80104a26 <allocproc+0xaa>
    p->state = UNUSED;
80104a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a18:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104a1f:	b8 00 00 00 00       	mov    $0x0,%eax
80104a24:	eb 72                	jmp    80104a98 <allocproc+0x11c>
  }
  sp = p->kstack + KSTACKSIZE;
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	8b 40 08             	mov    0x8(%eax),%eax
80104a2c:	05 00 10 00 00       	add    $0x1000,%eax
80104a31:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104a34:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a3e:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104a41:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104a45:	ba 62 74 10 80       	mov    $0x80107462,%edx
80104a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a4d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104a4f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a59:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a62:	83 ec 04             	sub    $0x4,%esp
80104a65:	6a 14                	push   $0x14
80104a67:	6a 00                	push   $0x0
80104a69:	50                   	push   %eax
80104a6a:	e8 04 14 00 00       	call   80105e73 <memset>
80104a6f:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a75:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a78:	ba 23 54 10 80       	mov    $0x80105423,%edx
80104a7d:	89 50 10             	mov    %edx,0x10(%eax)

  p->priority=0;  // initializes the priority.
80104a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a83:	66 c7 40 7e 00 00    	movw   $0x0,0x7e(%eax)
  p->age=0;  // initialize age.
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
80104a93:	00 00 
  return p;
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a98:	c9                   	leave  
80104a99:	c3                   	ret    

80104a9a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104a9a:	55                   	push   %ebp
80104a9b:	89 e5                	mov    %esp,%ebp
80104a9d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104aa0:	e8 d7 fe ff ff       	call   8010497c <allocproc>
80104aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aab:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
80104ab0:	e8 f9 42 00 00       	call   80108dae <setupkvm>
80104ab5:	89 c2                	mov    %eax,%edx
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	89 50 04             	mov    %edx,0x4(%eax)
80104abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac0:	8b 40 04             	mov    0x4(%eax),%eax
80104ac3:	85 c0                	test   %eax,%eax
80104ac5:	75 0d                	jne    80104ad4 <userinit+0x3a>
    panic("userinit: out of memory?");
80104ac7:	83 ec 0c             	sub    $0xc,%esp
80104aca:	68 09 9a 10 80       	push   $0x80109a09
80104acf:	e8 92 ba ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104ad4:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adc:	8b 40 04             	mov    0x4(%eax),%eax
80104adf:	83 ec 04             	sub    $0x4,%esp
80104ae2:	52                   	push   %edx
80104ae3:	68 00 c5 10 80       	push   $0x8010c500
80104ae8:	50                   	push   %eax
80104ae9:	e8 1a 45 00 00       	call   80109008 <inituvm>
80104aee:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afd:	8b 40 18             	mov    0x18(%eax),%eax
80104b00:	83 ec 04             	sub    $0x4,%esp
80104b03:	6a 4c                	push   $0x4c
80104b05:	6a 00                	push   $0x0
80104b07:	50                   	push   %eax
80104b08:	e8 66 13 00 00       	call   80105e73 <memset>
80104b0d:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b13:	8b 40 18             	mov    0x18(%eax),%eax
80104b16:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1f:	8b 40 18             	mov    0x18(%eax),%eax
80104b22:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2b:	8b 40 18             	mov    0x18(%eax),%eax
80104b2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b31:	8b 52 18             	mov    0x18(%edx),%edx
80104b34:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104b38:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3f:	8b 40 18             	mov    0x18(%eax),%eax
80104b42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b45:	8b 52 18             	mov    0x18(%edx),%edx
80104b48:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104b4c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b53:	8b 40 18             	mov    0x18(%eax),%eax
80104b56:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b60:	8b 40 18             	mov    0x18(%eax),%eax
80104b63:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6d:	8b 40 18             	mov    0x18(%eax),%eax
80104b70:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7a:	83 c0 6c             	add    $0x6c,%eax
80104b7d:	83 ec 04             	sub    $0x4,%esp
80104b80:	6a 10                	push   $0x10
80104b82:	68 22 9a 10 80       	push   $0x80109a22
80104b87:	50                   	push   %eax
80104b88:	e8 e9 14 00 00       	call   80106076 <safestrcpy>
80104b8d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104b90:	83 ec 0c             	sub    $0xc,%esp
80104b93:	68 2b 9a 10 80       	push   $0x80109a2b
80104b98:	e8 89 d9 ff ff       	call   80102526 <namei>
80104b9d:	83 c4 10             	add    $0x10,%esp
80104ba0:	89 c2                	mov    %eax,%edx
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	89 50 68             	mov    %edx,0x68(%eax)


  make_runnable(p);
80104ba8:	83 ec 0c             	sub    $0xc,%esp
80104bab:	ff 75 f4             	pushl  -0xc(%ebp)
80104bae:	e8 1f fb ff ff       	call   801046d2 <make_runnable>
80104bb3:	83 c4 10             	add    $0x10,%esp
}
80104bb6:	90                   	nop
80104bb7:	c9                   	leave  
80104bb8:	c3                   	ret    

80104bb9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104bb9:	55                   	push   %ebp
80104bba:	89 e5                	mov    %esp,%ebp
80104bbc:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104bbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc5:	8b 00                	mov    (%eax),%eax
80104bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104bca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104bce:	7e 31                	jle    80104c01 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104bd0:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd6:	01 c2                	add    %eax,%edx
80104bd8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bde:	8b 40 04             	mov    0x4(%eax),%eax
80104be1:	83 ec 04             	sub    $0x4,%esp
80104be4:	52                   	push   %edx
80104be5:	ff 75 f4             	pushl  -0xc(%ebp)
80104be8:	50                   	push   %eax
80104be9:	e8 67 45 00 00       	call   80109155 <allocuvm>
80104bee:	83 c4 10             	add    $0x10,%esp
80104bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bf8:	75 3e                	jne    80104c38 <growproc+0x7f>
      return -1;
80104bfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bff:	eb 59                	jmp    80104c5a <growproc+0xa1>
  } else if(n < 0){
80104c01:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104c05:	79 31                	jns    80104c38 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104c07:	8b 55 08             	mov    0x8(%ebp),%edx
80104c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0d:	01 c2                	add    %eax,%edx
80104c0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c15:	8b 40 04             	mov    0x4(%eax),%eax
80104c18:	83 ec 04             	sub    $0x4,%esp
80104c1b:	52                   	push   %edx
80104c1c:	ff 75 f4             	pushl  -0xc(%ebp)
80104c1f:	50                   	push   %eax
80104c20:	e8 f9 45 00 00       	call   8010921e <deallocuvm>
80104c25:	83 c4 10             	add    $0x10,%esp
80104c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c2f:	75 07                	jne    80104c38 <growproc+0x7f>
      return -1;
80104c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c36:	eb 22                	jmp    80104c5a <growproc+0xa1>
  }
  proc->sz = sz;
80104c38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c41:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104c43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c49:	83 ec 0c             	sub    $0xc,%esp
80104c4c:	50                   	push   %eax
80104c4d:	e8 43 42 00 00       	call   80108e95 <switchuvm>
80104c52:	83 c4 10             	add    $0x10,%esp
  return 0;
80104c55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c5a:	c9                   	leave  
80104c5b:	c3                   	ret    

80104c5c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104c5c:	55                   	push   %ebp
80104c5d:	89 e5                	mov    %esp,%ebp
80104c5f:	57                   	push   %edi
80104c60:	56                   	push   %esi
80104c61:	53                   	push   %ebx
80104c62:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104c65:	e8 12 fd ff ff       	call   8010497c <allocproc>
80104c6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104c6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104c71:	75 0a                	jne    80104c7d <fork+0x21>
    return -1;
80104c73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c78:	e9 ad 02 00 00       	jmp    80104f2a <fork+0x2ce>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104c7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c83:	8b 10                	mov    (%eax),%edx
80104c85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c8b:	8b 40 04             	mov    0x4(%eax),%eax
80104c8e:	83 ec 08             	sub    $0x8,%esp
80104c91:	52                   	push   %edx
80104c92:	50                   	push   %eax
80104c93:	e8 24 47 00 00       	call   801093bc <copyuvm>
80104c98:	83 c4 10             	add    $0x10,%esp
80104c9b:	89 c2                	mov    %eax,%edx
80104c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ca0:	89 50 04             	mov    %edx,0x4(%eax)
80104ca3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ca6:	8b 40 04             	mov    0x4(%eax),%eax
80104ca9:	85 c0                	test   %eax,%eax
80104cab:	75 30                	jne    80104cdd <fork+0x81>
    kfree(np->kstack);
80104cad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cb0:	8b 40 08             	mov    0x8(%eax),%eax
80104cb3:	83 ec 0c             	sub    $0xc,%esp
80104cb6:	50                   	push   %eax
80104cb7:	e8 cf de ff ff       	call   80102b8b <kfree>
80104cbc:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104cbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cc2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104cc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ccc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cd8:	e9 4d 02 00 00       	jmp    80104f2a <fork+0x2ce>
  }
  np->sz = proc->sz;
80104cdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce3:	8b 10                	mov    (%eax),%edx
80104ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ce8:	89 10                	mov    %edx,(%eax)
  np->sstack = proc->sstack;
80104cea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf0:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80104cf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cf9:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)

  np->parent = proc;
80104cff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d06:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d09:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d0f:	8b 50 18             	mov    0x18(%eax),%edx
80104d12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d18:	8b 40 18             	mov    0x18(%eax),%eax
80104d1b:	89 c3                	mov    %eax,%ebx
80104d1d:	b8 13 00 00 00       	mov    $0x13,%eax
80104d22:	89 d7                	mov    %edx,%edi
80104d24:	89 de                	mov    %ebx,%esi
80104d26:	89 c1                	mov    %eax,%ecx
80104d28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104d2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d2d:	8b 40 18             	mov    0x18(%eax),%eax
80104d30:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104d37:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104d3e:	eb 43                	jmp    80104d83 <fork+0x127>
    if(proc->ofile[i])
80104d40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d49:	83 c2 08             	add    $0x8,%edx
80104d4c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d50:	85 c0                	test   %eax,%eax
80104d52:	74 2b                	je     80104d7f <fork+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
80104d54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d5d:	83 c2 08             	add    $0x8,%edx
80104d60:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d64:	83 ec 0c             	sub    $0xc,%esp
80104d67:	50                   	push   %eax
80104d68:	e8 80 c2 ff ff       	call   80100fed <filedup>
80104d6d:	83 c4 10             	add    $0x10,%esp
80104d70:	89 c1                	mov    %eax,%ecx
80104d72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104d75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d78:	83 c2 08             	add    $0x8,%edx
80104d7b:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104d7f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104d83:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104d87:	7e b7                	jle    80104d40 <fork+0xe4>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++){
80104d89:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104d90:	eb 43                	jmp    80104dd5 <fork+0x179>
    if(proc->osemaphore[i])
80104d92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d9b:	83 c2 20             	add    $0x20,%edx
80104d9e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104da2:	85 c0                	test   %eax,%eax
80104da4:	74 2b                	je     80104dd1 <fork+0x175>
      np->osemaphore[i] = semdup(proc->osemaphore[i]);
80104da6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104daf:	83 c2 20             	add    $0x20,%edx
80104db2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104db6:	83 ec 0c             	sub    $0xc,%esp
80104db9:	50                   	push   %eax
80104dba:	e8 a6 0d 00 00       	call   80105b65 <semdup>
80104dbf:	83 c4 10             	add    $0x10,%esp
80104dc2:	89 c1                	mov    %eax,%ecx
80104dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dc7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104dca:	83 c2 20             	add    $0x20,%edx
80104dcd:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++){
80104dd1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104dd5:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
80104dd9:	7e b7                	jle    80104d92 <fork+0x136>
    if(proc->osemaphore[i])
      np->osemaphore[i] = semdup(proc->osemaphore[i]);
  }
  for(i = 0; i < MAXMAPPEDFILES; i++){
80104ddb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104de2:	e9 c4 00 00 00       	jmp    80104eab <fork+0x24f>
    if(proc->ommap[i].pfile){
80104de7:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104dee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104df1:	89 d0                	mov    %edx,%eax
80104df3:	01 c0                	add    %eax,%eax
80104df5:	01 d0                	add    %edx,%eax
80104df7:	c1 e0 02             	shl    $0x2,%eax
80104dfa:	01 c8                	add    %ecx,%eax
80104dfc:	05 a0 00 00 00       	add    $0xa0,%eax
80104e01:	8b 00                	mov    (%eax),%eax
80104e03:	85 c0                	test   %eax,%eax
80104e05:	0f 84 9c 00 00 00    	je     80104ea7 <fork+0x24b>
      np->ommap[i].pfile = proc->ommap[i].pfile;
80104e0b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104e12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e15:	89 d0                	mov    %edx,%eax
80104e17:	01 c0                	add    %eax,%eax
80104e19:	01 d0                	add    %edx,%eax
80104e1b:	c1 e0 02             	shl    $0x2,%eax
80104e1e:	01 c8                	add    %ecx,%eax
80104e20:	05 a0 00 00 00       	add    $0xa0,%eax
80104e25:	8b 08                	mov    (%eax),%ecx
80104e27:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80104e2a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e2d:	89 d0                	mov    %edx,%eax
80104e2f:	01 c0                	add    %eax,%eax
80104e31:	01 d0                	add    %edx,%eax
80104e33:	c1 e0 02             	shl    $0x2,%eax
80104e36:	01 d8                	add    %ebx,%eax
80104e38:	05 a0 00 00 00       	add    $0xa0,%eax
80104e3d:	89 08                	mov    %ecx,(%eax)
      np->ommap[i].va = proc->ommap[i].va;
80104e3f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104e46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e49:	89 d0                	mov    %edx,%eax
80104e4b:	01 c0                	add    %eax,%eax
80104e4d:	01 d0                	add    %edx,%eax
80104e4f:	c1 e0 02             	shl    $0x2,%eax
80104e52:	01 c8                	add    %ecx,%eax
80104e54:	05 a4 00 00 00       	add    $0xa4,%eax
80104e59:	8b 08                	mov    (%eax),%ecx
80104e5b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80104e5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e61:	89 d0                	mov    %edx,%eax
80104e63:	01 c0                	add    %eax,%eax
80104e65:	01 d0                	add    %edx,%eax
80104e67:	c1 e0 02             	shl    $0x2,%eax
80104e6a:	01 d8                	add    %ebx,%eax
80104e6c:	05 a4 00 00 00       	add    $0xa4,%eax
80104e71:	89 08                	mov    %ecx,(%eax)
      np->ommap[i].sz = proc->ommap[i].sz;
80104e73:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104e7a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e7d:	89 d0                	mov    %edx,%eax
80104e7f:	01 c0                	add    %eax,%eax
80104e81:	01 d0                	add    %edx,%eax
80104e83:	c1 e0 02             	shl    $0x2,%eax
80104e86:	01 c8                	add    %ecx,%eax
80104e88:	05 a8 00 00 00       	add    $0xa8,%eax
80104e8d:	8b 08                	mov    (%eax),%ecx
80104e8f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80104e92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e95:	89 d0                	mov    %edx,%eax
80104e97:	01 c0                	add    %eax,%eax
80104e99:	01 d0                	add    %edx,%eax
80104e9b:	c1 e0 02             	shl    $0x2,%eax
80104e9e:	01 d8                	add    %ebx,%eax
80104ea0:	05 a8 00 00 00       	add    $0xa8,%eax
80104ea5:	89 08                	mov    %ecx,(%eax)
  //duplicate semaphore a new process
  for(i = 0; i < MAXPROCSEM; i++){
    if(proc->osemaphore[i])
      np->osemaphore[i] = semdup(proc->osemaphore[i]);
  }
  for(i = 0; i < MAXMAPPEDFILES; i++){
80104ea7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104eab:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
80104eaf:	0f 8e 32 ff ff ff    	jle    80104de7 <fork+0x18b>
      np->ommap[i].sz = proc->ommap[i].sz;
    }
  }


  np->cwd = idup(proc->cwd);
80104eb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ebb:	8b 40 68             	mov    0x68(%eax),%eax
80104ebe:	83 ec 0c             	sub    $0xc,%esp
80104ec1:	50                   	push   %eax
80104ec2:	e8 6d ca ff ff       	call   80101934 <idup>
80104ec7:	83 c4 10             	add    $0x10,%esp
80104eca:	89 c2                	mov    %eax,%edx
80104ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ecf:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ed8:	8d 50 6c             	lea    0x6c(%eax),%edx
80104edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ede:	83 c0 6c             	add    $0x6c,%eax
80104ee1:	83 ec 04             	sub    $0x4,%esp
80104ee4:	6a 10                	push   $0x10
80104ee6:	52                   	push   %edx
80104ee7:	50                   	push   %eax
80104ee8:	e8 89 11 00 00       	call   80106076 <safestrcpy>
80104eed:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ef3:	8b 40 10             	mov    0x10(%eax),%eax
80104ef6:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104ef9:	83 ec 0c             	sub    $0xc,%esp
80104efc:	68 80 39 11 80       	push   $0x80113980
80104f01:	e8 0a 0d 00 00       	call   80105c10 <acquire>
80104f06:	83 c4 10             	add    $0x10,%esp
  make_runnable(np);
80104f09:	83 ec 0c             	sub    $0xc,%esp
80104f0c:	ff 75 e0             	pushl  -0x20(%ebp)
80104f0f:	e8 be f7 ff ff       	call   801046d2 <make_runnable>
80104f14:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f17:	83 ec 0c             	sub    $0xc,%esp
80104f1a:	68 80 39 11 80       	push   $0x80113980
80104f1f:	e8 53 0d 00 00       	call   80105c77 <release>
80104f24:	83 c4 10             	add    $0x10,%esp

  return pid;
80104f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f2d:	5b                   	pop    %ebx
80104f2e:	5e                   	pop    %esi
80104f2f:	5f                   	pop    %edi
80104f30:	5d                   	pop    %ebp
80104f31:	c3                   	ret    

80104f32 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104f32:	55                   	push   %ebp
80104f33:	89 e5                	mov    %esp,%ebp
80104f35:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd, idsem, i;

  if(proc == initproc)
80104f38:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f3f:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104f44:	39 c2                	cmp    %eax,%edx
80104f46:	75 0d                	jne    80104f55 <exit+0x23>
    panic("init exiting");
80104f48:	83 ec 0c             	sub    $0xc,%esp
80104f4b:	68 2d 9a 10 80       	push   $0x80109a2d
80104f50:	e8 11 b6 ff ff       	call   80100566 <panic>

  // Close all open mmaps and later closes all open files.
  for(i = 0; i < MAXMAPPEDFILES; i++){
80104f55:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80104f5c:	eb 4c                	jmp    80104faa <exit+0x78>
    if(proc->ommap[i].pfile){
80104f5e:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104f65:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104f68:	89 d0                	mov    %edx,%eax
80104f6a:	01 c0                	add    %eax,%eax
80104f6c:	01 d0                	add    %edx,%eax
80104f6e:	c1 e0 02             	shl    $0x2,%eax
80104f71:	01 c8                	add    %ecx,%eax
80104f73:	05 a0 00 00 00       	add    $0xa0,%eax
80104f78:	8b 00                	mov    (%eax),%eax
80104f7a:	85 c0                	test   %eax,%eax
80104f7c:	74 28                	je     80104fa6 <exit+0x74>
      munmap((char*) proc->ommap[i].va);
80104f7e:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80104f85:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104f88:	89 d0                	mov    %edx,%eax
80104f8a:	01 c0                	add    %eax,%eax
80104f8c:	01 d0                	add    %edx,%eax
80104f8e:	c1 e0 02             	shl    $0x2,%eax
80104f91:	01 c8                	add    %ecx,%eax
80104f93:	05 a4 00 00 00       	add    $0xa4,%eax
80104f98:	8b 00                	mov    (%eax),%eax
80104f9a:	83 ec 0c             	sub    $0xc,%esp
80104f9d:	50                   	push   %eax
80104f9e:	e8 18 ec ff ff       	call   80103bbb <munmap>
80104fa3:	83 c4 10             	add    $0x10,%esp

  if(proc == initproc)
    panic("init exiting");

  // Close all open mmaps and later closes all open files.
  for(i = 0; i < MAXMAPPEDFILES; i++){
80104fa6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104faa:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
80104fae:	7e ae                	jle    80104f5e <exit+0x2c>
    if(proc->ommap[i].pfile){
      munmap((char*) proc->ommap[i].va);
    }
  }
  for(fd = 0; fd < NOFILE; fd++){
80104fb0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104fb7:	eb 48                	jmp    80105001 <exit+0xcf>
    if(proc->ofile[fd]){
80104fb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fbf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fc2:	83 c2 08             	add    $0x8,%edx
80104fc5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fc9:	85 c0                	test   %eax,%eax
80104fcb:	74 30                	je     80104ffd <exit+0xcb>
      fileclose(proc->ofile[fd]);
80104fcd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fd6:	83 c2 08             	add    $0x8,%edx
80104fd9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fdd:	83 ec 0c             	sub    $0xc,%esp
80104fe0:	50                   	push   %eax
80104fe1:	e8 58 c0 ff ff       	call   8010103e <fileclose>
80104fe6:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104fe9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fef:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ff2:	83 c2 08             	add    $0x8,%edx
80104ff5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104ffc:	00 
  for(i = 0; i < MAXMAPPEDFILES; i++){
    if(proc->ommap[i].pfile){
      munmap((char*) proc->ommap[i].va);
    }
  }
  for(fd = 0; fd < NOFILE; fd++){
80104ffd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105001:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105005:	7e b2                	jle    80104fb9 <exit+0x87>
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80105007:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010500e:	eb 48                	jmp    80105058 <exit+0x126>
    if(proc->osemaphore[idsem]){
80105010:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105016:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105019:	83 c2 20             	add    $0x20,%edx
8010501c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105020:	85 c0                	test   %eax,%eax
80105022:	74 30                	je     80105054 <exit+0x122>
      semclose(proc->osemaphore[idsem]);
80105024:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010502a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010502d:	83 c2 20             	add    $0x20,%edx
80105030:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105034:	83 ec 0c             	sub    $0xc,%esp
80105037:	50                   	push   %eax
80105038:	e8 d9 0a 00 00       	call   80105b16 <semclose>
8010503d:	83 c4 10             	add    $0x10,%esp
      proc->osemaphore[idsem] = 0;
80105040:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105046:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105049:	83 c2 20             	add    $0x20,%edx
8010504c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105053:	00 
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80105054:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105058:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
8010505c:	7e b2                	jle    80105010 <exit+0xde>
      semclose(proc->osemaphore[idsem]);
      proc->osemaphore[idsem] = 0;
    }
  }

  begin_op();
8010505e:	e8 b4 e4 ff ff       	call   80103517 <begin_op>
  iput(proc->cwd);
80105063:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105069:	8b 40 68             	mov    0x68(%eax),%eax
8010506c:	83 ec 0c             	sub    $0xc,%esp
8010506f:	50                   	push   %eax
80105070:	e8 c3 ca ff ff       	call   80101b38 <iput>
80105075:	83 c4 10             	add    $0x10,%esp
  end_op();
80105078:	e8 26 e5 ff ff       	call   801035a3 <end_op>
  proc->cwd = 0;
8010507d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105083:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010508a:	83 ec 0c             	sub    $0xc,%esp
8010508d:	68 80 39 11 80       	push   $0x80113980
80105092:	e8 79 0b 00 00       	call   80105c10 <acquire>
80105097:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010509a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a0:	8b 40 14             	mov    0x14(%eax),%eax
801050a3:	83 ec 0c             	sub    $0xc,%esp
801050a6:	50                   	push   %eax
801050a7:	e8 54 04 00 00       	call   80105500 <wakeup1>
801050ac:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050af:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801050b6:	eb 3f                	jmp    801050f7 <exit+0x1c5>
    if(p->parent == proc){
801050b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bb:	8b 50 14             	mov    0x14(%eax),%edx
801050be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c4:	39 c2                	cmp    %eax,%edx
801050c6:	75 28                	jne    801050f0 <exit+0x1be>
      p->parent = initproc;
801050c8:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
801050ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d1:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	8b 40 0c             	mov    0xc(%eax),%eax
801050da:	83 f8 05             	cmp    $0x5,%eax
801050dd:	75 11                	jne    801050f0 <exit+0x1be>
        wakeup1(initproc);
801050df:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801050e4:	83 ec 0c             	sub    $0xc,%esp
801050e7:	50                   	push   %eax
801050e8:	e8 13 04 00 00       	call   80105500 <wakeup1>
801050ed:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050f0:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
801050f7:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
801050fe:	72 b8                	jb     801050b8 <exit+0x186>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80105100:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105106:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010510d:	e8 f4 01 00 00       	call   80105306 <sched>
  panic("zombie exit");
80105112:	83 ec 0c             	sub    $0xc,%esp
80105115:	68 3a 9a 10 80       	push   $0x80109a3a
8010511a:	e8 47 b4 ff ff       	call   80100566 <panic>

8010511f <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010511f:	55                   	push   %ebp
80105120:	89 e5                	mov    %esp,%ebp
80105122:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105125:	83 ec 0c             	sub    $0xc,%esp
80105128:	68 80 39 11 80       	push   $0x80113980
8010512d:	e8 de 0a 00 00       	call   80105c10 <acquire>
80105132:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105135:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010513c:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105143:	e9 a9 00 00 00       	jmp    801051f1 <wait+0xd2>
      if(p->parent != proc)
80105148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514b:	8b 50 14             	mov    0x14(%eax),%edx
8010514e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105154:	39 c2                	cmp    %eax,%edx
80105156:	0f 85 8d 00 00 00    	jne    801051e9 <wait+0xca>
        continue;
      havekids = 1;
8010515c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105166:	8b 40 0c             	mov    0xc(%eax),%eax
80105169:	83 f8 05             	cmp    $0x5,%eax
8010516c:	75 7c                	jne    801051ea <wait+0xcb>
        // Found one.
        pid = p->pid;
8010516e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105171:	8b 40 10             	mov    0x10(%eax),%eax
80105174:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517a:	8b 40 08             	mov    0x8(%eax),%eax
8010517d:	83 ec 0c             	sub    $0xc,%esp
80105180:	50                   	push   %eax
80105181:	e8 05 da ff ff       	call   80102b8b <kfree>
80105186:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80105189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80105193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105196:	8b 40 04             	mov    0x4(%eax),%eax
80105199:	83 ec 0c             	sub    $0xc,%esp
8010519c:	50                   	push   %eax
8010519d:	e8 39 41 00 00       	call   801092db <freevm>
801051a2:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801051a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801051b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801051c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801051ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801051d4:	83 ec 0c             	sub    $0xc,%esp
801051d7:	68 80 39 11 80       	push   $0x80113980
801051dc:	e8 96 0a 00 00       	call   80105c77 <release>
801051e1:	83 c4 10             	add    $0x10,%esp
        return pid;
801051e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051e7:	eb 5b                	jmp    80105244 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801051e9:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051ea:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
801051f1:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
801051f8:	0f 82 4a ff ff ff    	jb     80105148 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801051fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105202:	74 0d                	je     80105211 <wait+0xf2>
80105204:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010520a:	8b 40 24             	mov    0x24(%eax),%eax
8010520d:	85 c0                	test   %eax,%eax
8010520f:	74 17                	je     80105228 <wait+0x109>
      release(&ptable.lock);
80105211:	83 ec 0c             	sub    $0xc,%esp
80105214:	68 80 39 11 80       	push   $0x80113980
80105219:	e8 59 0a 00 00       	call   80105c77 <release>
8010521e:	83 c4 10             	add    $0x10,%esp
      return -1;
80105221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105226:	eb 1c                	jmp    80105244 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105228:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010522e:	83 ec 08             	sub    $0x8,%esp
80105231:	68 80 39 11 80       	push   $0x80113980
80105236:	50                   	push   %eax
80105237:	e8 18 02 00 00       	call   80105454 <sleep>
8010523c:	83 c4 10             	add    $0x10,%esp
  }
8010523f:	e9 f1 fe ff ff       	jmp    80105135 <wait+0x16>
}
80105244:	c9                   	leave  
80105245:	c3                   	ret    

80105246 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105246:	55                   	push   %ebp
80105247:	89 e5                	mov    %esp,%ebp
80105249:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int l;
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010524c:	e8 7a f4 ff ff       	call   801046cb <sti>

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
80105251:	83 ec 0c             	sub    $0xc,%esp
80105254:	68 80 39 11 80       	push   $0x80113980
80105259:	e8 b2 09 00 00       	call   80105c10 <acquire>
8010525e:	83 c4 10             	add    $0x10,%esp
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80105261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105268:	eb 7d                	jmp    801052e7 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
8010526a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526d:	05 e6 06 00 00       	add    $0x6e6,%eax
80105272:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
80105279:	85 c0                	test   %eax,%eax
8010527b:	75 06                	jne    80105283 <scheduler+0x3d>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
8010527d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105281:	eb 64                	jmp    801052e7 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
        continue;
      p=unqueue(l);
80105283:	83 ec 0c             	sub    $0xc,%esp
80105286:	ff 75 f4             	pushl  -0xc(%ebp)
80105289:	e8 dc f4 ff ff       	call   8010476a <unqueue>
8010528e:	83 c4 10             	add    $0x10,%esp
80105291:	89 45 f0             	mov    %eax,-0x10(%ebp)


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105294:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105297:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4


      switchuvm(p);
8010529d:	83 ec 0c             	sub    $0xc,%esp
801052a0:	ff 75 f0             	pushl  -0x10(%ebp)
801052a3:	e8 ed 3b 00 00       	call   80108e95 <switchuvm>
801052a8:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801052ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ae:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801052b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052bb:	8b 40 1c             	mov    0x1c(%eax),%eax
801052be:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801052c5:	83 c2 04             	add    $0x4,%edx
801052c8:	83 ec 08             	sub    $0x8,%esp
801052cb:	50                   	push   %eax
801052cc:	52                   	push   %edx
801052cd:	e8 15 0e 00 00       	call   801060e7 <swtch>
801052d2:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801052d5:	e8 9e 3b 00 00       	call   80108e78 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801052da:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801052e1:	00 00 00 00 
      break;
801052e5:	eb 0a                	jmp    801052f1 <scheduler+0xab>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
801052e7:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801052eb:	0f 8e 79 ff ff ff    	jle    8010526a <scheduler+0x24>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      break;
    }
    release(&ptable.lock);
801052f1:	83 ec 0c             	sub    $0xc,%esp
801052f4:	68 80 39 11 80       	push   $0x80113980
801052f9:	e8 79 09 00 00       	call   80105c77 <release>
801052fe:	83 c4 10             	add    $0x10,%esp
  }
80105301:	e9 46 ff ff ff       	jmp    8010524c <scheduler+0x6>

80105306 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105306:	55                   	push   %ebp
80105307:	89 e5                	mov    %esp,%ebp
80105309:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010530c:	83 ec 0c             	sub    $0xc,%esp
8010530f:	68 80 39 11 80       	push   $0x80113980
80105314:	e8 2a 0a 00 00       	call   80105d43 <holding>
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	85 c0                	test   %eax,%eax
8010531e:	75 0d                	jne    8010532d <sched+0x27>
    panic("sched ptable.lock");
80105320:	83 ec 0c             	sub    $0xc,%esp
80105323:	68 46 9a 10 80       	push   $0x80109a46
80105328:	e8 39 b2 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010532d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105333:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105339:	83 f8 01             	cmp    $0x1,%eax
8010533c:	74 0d                	je     8010534b <sched+0x45>
    panic("sched locks");
8010533e:	83 ec 0c             	sub    $0xc,%esp
80105341:	68 58 9a 10 80       	push   $0x80109a58
80105346:	e8 1b b2 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010534b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105351:	8b 40 0c             	mov    0xc(%eax),%eax
80105354:	83 f8 04             	cmp    $0x4,%eax
80105357:	75 0d                	jne    80105366 <sched+0x60>
    panic("sched running");
80105359:	83 ec 0c             	sub    $0xc,%esp
8010535c:	68 64 9a 10 80       	push   $0x80109a64
80105361:	e8 00 b2 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105366:	e8 50 f3 ff ff       	call   801046bb <readeflags>
8010536b:	25 00 02 00 00       	and    $0x200,%eax
80105370:	85 c0                	test   %eax,%eax
80105372:	74 0d                	je     80105381 <sched+0x7b>
    panic("sched interruptible");
80105374:	83 ec 0c             	sub    $0xc,%esp
80105377:	68 72 9a 10 80       	push   $0x80109a72
8010537c:	e8 e5 b1 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105381:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105387:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010538d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105390:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105396:	8b 40 04             	mov    0x4(%eax),%eax
80105399:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053a0:	83 c2 1c             	add    $0x1c,%edx
801053a3:	83 ec 08             	sub    $0x8,%esp
801053a6:	50                   	push   %eax
801053a7:	52                   	push   %edx
801053a8:	e8 3a 0d 00 00       	call   801060e7 <swtch>
801053ad:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801053b0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053b9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801053bf:	90                   	nop
801053c0:	c9                   	leave  
801053c1:	c3                   	ret    

801053c2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801053c2:	55                   	push   %ebp
801053c3:	89 e5                	mov    %esp,%ebp
801053c5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801053c8:	83 ec 0c             	sub    $0xc,%esp
801053cb:	68 80 39 11 80       	push   $0x80113980
801053d0:	e8 3b 08 00 00       	call   80105c10 <acquire>
801053d5:	83 c4 10             	add    $0x10,%esp
  if(proc->priority<MLFLEVELS-1)
801053d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053de:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801053e2:	66 83 f8 02          	cmp    $0x2,%ax
801053e6:	77 11                	ja     801053f9 <yield+0x37>
    proc->priority++;
801053e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ee:	0f b7 50 7e          	movzwl 0x7e(%eax),%edx
801053f2:	83 c2 01             	add    $0x1,%edx
801053f5:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(proc);
801053f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ff:	83 ec 0c             	sub    $0xc,%esp
80105402:	50                   	push   %eax
80105403:	e8 ca f2 ff ff       	call   801046d2 <make_runnable>
80105408:	83 c4 10             	add    $0x10,%esp
  sched();
8010540b:	e8 f6 fe ff ff       	call   80105306 <sched>
  release(&ptable.lock);
80105410:	83 ec 0c             	sub    $0xc,%esp
80105413:	68 80 39 11 80       	push   $0x80113980
80105418:	e8 5a 08 00 00       	call   80105c77 <release>
8010541d:	83 c4 10             	add    $0x10,%esp
}
80105420:	90                   	nop
80105421:	c9                   	leave  
80105422:	c3                   	ret    

80105423 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105423:	55                   	push   %ebp
80105424:	89 e5                	mov    %esp,%ebp
80105426:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	68 80 39 11 80       	push   $0x80113980
80105431:	e8 41 08 00 00       	call   80105c77 <release>
80105436:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105439:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010543e:	85 c0                	test   %eax,%eax
80105440:	74 0f                	je     80105451 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105442:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105449:	00 00 00 
    initlog();
8010544c:	e8 a0 de ff ff       	call   801032f1 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80105451:	90                   	nop
80105452:	c9                   	leave  
80105453:	c3                   	ret    

80105454 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105454:	55                   	push   %ebp
80105455:	89 e5                	mov    %esp,%ebp
80105457:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010545a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105460:	85 c0                	test   %eax,%eax
80105462:	75 0d                	jne    80105471 <sleep+0x1d>
    panic("sleep");
80105464:	83 ec 0c             	sub    $0xc,%esp
80105467:	68 86 9a 10 80       	push   $0x80109a86
8010546c:	e8 f5 b0 ff ff       	call   80100566 <panic>

  if(lk == 0)
80105471:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105475:	75 0d                	jne    80105484 <sleep+0x30>
    panic("sleep without lk");
80105477:	83 ec 0c             	sub    $0xc,%esp
8010547a:	68 8c 9a 10 80       	push   $0x80109a8c
8010547f:	e8 e2 b0 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105484:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
8010548b:	74 1e                	je     801054ab <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010548d:	83 ec 0c             	sub    $0xc,%esp
80105490:	68 80 39 11 80       	push   $0x80113980
80105495:	e8 76 07 00 00       	call   80105c10 <acquire>
8010549a:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010549d:	83 ec 0c             	sub    $0xc,%esp
801054a0:	ff 75 0c             	pushl  0xc(%ebp)
801054a3:	e8 cf 07 00 00       	call   80105c77 <release>
801054a8:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801054ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b1:	8b 55 08             	mov    0x8(%ebp),%edx
801054b4:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801054b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054bd:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801054c4:	e8 3d fe ff ff       	call   80105306 <sched>

  // Tidy up.
  proc->chan = 0;
801054c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054cf:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801054d6:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801054dd:	74 1e                	je     801054fd <sleep+0xa9>
    release(&ptable.lock);
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	68 80 39 11 80       	push   $0x80113980
801054e7:	e8 8b 07 00 00       	call   80105c77 <release>
801054ec:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801054ef:	83 ec 0c             	sub    $0xc,%esp
801054f2:	ff 75 0c             	pushl  0xc(%ebp)
801054f5:	e8 16 07 00 00       	call   80105c10 <acquire>
801054fa:	83 c4 10             	add    $0x10,%esp
  }
}
801054fd:	90                   	nop
801054fe:	c9                   	leave  
801054ff:	c3                   	ret    

80105500 <wakeup1>:
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
// If applicable, the priority of the process increases.
static void
wakeup1(void *chan)
{
80105500:	55                   	push   %ebp
80105501:	89 e5                	mov    %esp,%ebp
80105503:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105506:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
8010550d:	eb 45                	jmp    80105554 <wakeup1+0x54>
    if(p->state == SLEEPING && p->chan == chan){
8010550f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105512:	8b 40 0c             	mov    0xc(%eax),%eax
80105515:	83 f8 02             	cmp    $0x2,%eax
80105518:	75 33                	jne    8010554d <wakeup1+0x4d>
8010551a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010551d:	8b 40 20             	mov    0x20(%eax),%eax
80105520:	3b 45 08             	cmp    0x8(%ebp),%eax
80105523:	75 28                	jne    8010554d <wakeup1+0x4d>
      if (p->priority>0)
80105525:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105528:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010552c:	66 85 c0             	test   %ax,%ax
8010552f:	74 11                	je     80105542 <wakeup1+0x42>
        p->priority--;
80105531:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105534:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105538:	8d 50 ff             	lea    -0x1(%eax),%edx
8010553b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010553e:	66 89 50 7e          	mov    %dx,0x7e(%eax)
      make_runnable(p);
80105542:	ff 75 fc             	pushl  -0x4(%ebp)
80105545:	e8 88 f1 ff ff       	call   801046d2 <make_runnable>
8010554a:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010554d:	81 45 fc dc 00 00 00 	addl   $0xdc,-0x4(%ebp)
80105554:	81 7d fc b4 70 11 80 	cmpl   $0x801170b4,-0x4(%ebp)
8010555b:	72 b2                	jb     8010550f <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan){
      if (p->priority>0)
        p->priority--;
      make_runnable(p);
    }
}
8010555d:	90                   	nop
8010555e:	c9                   	leave  
8010555f:	c3                   	ret    

80105560 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105560:	55                   	push   %ebp
80105561:	89 e5                	mov    %esp,%ebp
80105563:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105566:	83 ec 0c             	sub    $0xc,%esp
80105569:	68 80 39 11 80       	push   $0x80113980
8010556e:	e8 9d 06 00 00       	call   80105c10 <acquire>
80105573:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105576:	83 ec 0c             	sub    $0xc,%esp
80105579:	ff 75 08             	pushl  0x8(%ebp)
8010557c:	e8 7f ff ff ff       	call   80105500 <wakeup1>
80105581:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105584:	83 ec 0c             	sub    $0xc,%esp
80105587:	68 80 39 11 80       	push   $0x80113980
8010558c:	e8 e6 06 00 00       	call   80105c77 <release>
80105591:	83 c4 10             	add    $0x10,%esp
}
80105594:	90                   	nop
80105595:	c9                   	leave  
80105596:	c3                   	ret    

80105597 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105597:	55                   	push   %ebp
80105598:	89 e5                	mov    %esp,%ebp
8010559a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010559d:	83 ec 0c             	sub    $0xc,%esp
801055a0:	68 80 39 11 80       	push   $0x80113980
801055a5:	e8 66 06 00 00       	call   80105c10 <acquire>
801055aa:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055ad:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801055b4:	eb 4c                	jmp    80105602 <kill+0x6b>
    if(p->pid == pid){
801055b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b9:	8b 40 10             	mov    0x10(%eax),%eax
801055bc:	3b 45 08             	cmp    0x8(%ebp),%eax
801055bf:	75 3a                	jne    801055fb <kill+0x64>
      p->killed = 1;
801055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801055cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ce:	8b 40 0c             	mov    0xc(%eax),%eax
801055d1:	83 f8 02             	cmp    $0x2,%eax
801055d4:	75 0e                	jne    801055e4 <kill+0x4d>
        make_runnable(p);
801055d6:	83 ec 0c             	sub    $0xc,%esp
801055d9:	ff 75 f4             	pushl  -0xc(%ebp)
801055dc:	e8 f1 f0 ff ff       	call   801046d2 <make_runnable>
801055e1:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
801055e4:	83 ec 0c             	sub    $0xc,%esp
801055e7:	68 80 39 11 80       	push   $0x80113980
801055ec:	e8 86 06 00 00       	call   80105c77 <release>
801055f1:	83 c4 10             	add    $0x10,%esp
      return 0;
801055f4:	b8 00 00 00 00       	mov    $0x0,%eax
801055f9:	eb 25                	jmp    80105620 <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055fb:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
80105602:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80105609:	72 ab                	jb     801055b6 <kill+0x1f>
        make_runnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010560b:	83 ec 0c             	sub    $0xc,%esp
8010560e:	68 80 39 11 80       	push   $0x80113980
80105613:	e8 5f 06 00 00       	call   80105c77 <release>
80105618:	83 c4 10             	add    $0x10,%esp
  return -1;
8010561b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105620:	c9                   	leave  
80105621:	c3                   	ret    

80105622 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105622:	55                   	push   %ebp
80105623:	89 e5                	mov    %esp,%ebp
80105625:	53                   	push   %ebx
80105626:	83 ec 44             	sub    $0x44,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105629:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105630:	e9 f6 00 00 00       	jmp    8010572b <procdump+0x109>
    if(p->state == UNUSED)
80105635:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105638:	8b 40 0c             	mov    0xc(%eax),%eax
8010563b:	85 c0                	test   %eax,%eax
8010563d:	0f 84 e0 00 00 00    	je     80105723 <procdump+0x101>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105643:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105646:	8b 40 0c             	mov    0xc(%eax),%eax
80105649:	83 f8 05             	cmp    $0x5,%eax
8010564c:	77 23                	ja     80105671 <procdump+0x4f>
8010564e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105651:	8b 40 0c             	mov    0xc(%eax),%eax
80105654:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010565b:	85 c0                	test   %eax,%eax
8010565d:	74 12                	je     80105671 <procdump+0x4f>
      state = states[p->state];
8010565f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105662:	8b 40 0c             	mov    0xc(%eax),%eax
80105665:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010566c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010566f:	eb 07                	jmp    80105678 <procdump+0x56>
    else
      state = "???";
80105671:	c7 45 ec 9d 9a 10 80 	movl   $0x80109a9d,-0x14(%ebp)
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
80105678:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010567b:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80105682:	0f b7 c8             	movzwl %ax,%ecx
80105685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105688:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010568c:	0f b7 d0             	movzwl %ax,%edx
8010568f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105692:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105695:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105698:	8b 40 10             	mov    0x10(%eax),%eax
8010569b:	83 ec 08             	sub    $0x8,%esp
8010569e:	51                   	push   %ecx
8010569f:	52                   	push   %edx
801056a0:	53                   	push   %ebx
801056a1:	ff 75 ec             	pushl  -0x14(%ebp)
801056a4:	50                   	push   %eax
801056a5:	68 a1 9a 10 80       	push   $0x80109aa1
801056aa:	e8 17 ad ff ff       	call   801003c6 <cprintf>
801056af:	83 c4 20             	add    $0x20,%esp
    if(p->state == SLEEPING){
801056b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b5:	8b 40 0c             	mov    0xc(%eax),%eax
801056b8:	83 f8 02             	cmp    $0x2,%eax
801056bb:	75 54                	jne    80105711 <procdump+0xef>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801056bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c0:	8b 40 1c             	mov    0x1c(%eax),%eax
801056c3:	8b 40 0c             	mov    0xc(%eax),%eax
801056c6:	83 c0 08             	add    $0x8,%eax
801056c9:	89 c2                	mov    %eax,%edx
801056cb:	83 ec 08             	sub    $0x8,%esp
801056ce:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801056d1:	50                   	push   %eax
801056d2:	52                   	push   %edx
801056d3:	e8 f1 05 00 00       	call   80105cc9 <getcallerpcs>
801056d8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801056db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801056e2:	eb 1c                	jmp    80105700 <procdump+0xde>
        cprintf(" %p", pc[i]);
801056e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801056eb:	83 ec 08             	sub    $0x8,%esp
801056ee:	50                   	push   %eax
801056ef:	68 bd 9a 10 80       	push   $0x80109abd
801056f4:	e8 cd ac ff ff       	call   801003c6 <cprintf>
801056f9:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801056fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105700:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105704:	7f 0b                	jg     80105711 <procdump+0xef>
80105706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105709:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010570d:	85 c0                	test   %eax,%eax
8010570f:	75 d3                	jne    801056e4 <procdump+0xc2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105711:	83 ec 0c             	sub    $0xc,%esp
80105714:	68 c1 9a 10 80       	push   $0x80109ac1
80105719:	e8 a8 ac ff ff       	call   801003c6 <cprintf>
8010571e:	83 c4 10             	add    $0x10,%esp
80105721:	eb 01                	jmp    80105724 <procdump+0x102>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105723:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105724:	81 45 f0 dc 00 00 00 	addl   $0xdc,-0x10(%ebp)
8010572b:	81 7d f0 b4 70 11 80 	cmpl   $0x801170b4,-0x10(%ebp)
80105732:	0f 82 fd fe ff ff    	jb     80105635 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105738:	90                   	nop
80105739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010573c:	c9                   	leave  
8010573d:	c3                   	ret    

8010573e <seminit>:
} stable;

// Initializes the LOCK of the semaphore table.
void
seminit(void)
{
8010573e:	55                   	push   %ebp
8010573f:	89 e5                	mov    %esp,%ebp
80105741:	83 ec 08             	sub    $0x8,%esp
  initlock(&stable.lock, "stable");
80105744:	83 ec 08             	sub    $0x8,%esp
80105747:	68 ed 9a 10 80       	push   $0x80109aed
8010574c:	68 e0 70 11 80       	push   $0x801170e0
80105751:	e8 98 04 00 00       	call   80105bee <initlock>
80105756:	83 c4 10             	add    $0x10,%esp
}
80105759:	90                   	nop
8010575a:	c9                   	leave  
8010575b:	c3                   	ret    

8010575c <allocinprocess>:

// Assigns a place in the open semaphore array of the process and returns the position.
static int
allocinprocess()
{
8010575c:	55                   	push   %ebp
8010575d:	89 e5                	mov    %esp,%ebp
8010575f:	83 ec 10             	sub    $0x10,%esp
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
80105762:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105769:	eb 22                	jmp    8010578d <allocinprocess+0x31>
    s=proc->osemaphore[i];
8010576b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105771:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105774:	83 c2 20             	add    $0x20,%edx
80105777:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010577b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(!s)
8010577e:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
80105782:	75 05                	jne    80105789 <allocinprocess+0x2d>
      return i;
80105784:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105787:	eb 0f                	jmp    80105798 <allocinprocess+0x3c>
allocinprocess()
{
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
80105789:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010578d:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80105791:	7e d8                	jle    8010576b <allocinprocess+0xf>
    s=proc->osemaphore[i];
    if(!s)
      return i;
  }
  return -1;
80105793:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105798:	c9                   	leave  
80105799:	c3                   	ret    

8010579a <searchinprocess>:

// Find the id passed as an argument between the ids of the open semaphores of the process and return its position.
static int
searchinprocess(int id)
{
8010579a:	55                   	push   %ebp
8010579b:	89 e5                	mov    %esp,%ebp
8010579d:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
801057a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a7:	eb 2c                	jmp    801057d5 <searchinprocess+0x3b>
    s=proc->osemaphore[i];
801057a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057af:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b2:	83 c2 20             	add    $0x20,%edx
801057b5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s && s->id==id){
801057bc:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801057c0:	74 0f                	je     801057d1 <searchinprocess+0x37>
801057c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057c5:	8b 00                	mov    (%eax),%eax
801057c7:	3b 45 08             	cmp    0x8(%ebp),%eax
801057ca:	75 05                	jne    801057d1 <searchinprocess+0x37>
        return i;
801057cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057cf:	eb 0f                	jmp    801057e0 <searchinprocess+0x46>
searchinprocess(int id)
{
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
801057d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057d5:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801057d9:	7e ce                	jle    801057a9 <searchinprocess+0xf>
    s=proc->osemaphore[i];
    if(s && s->id==id){
        return i;
    }
  }
  return -1;
801057db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057e0:	c9                   	leave  
801057e1:	c3                   	ret    

801057e2 <allocinsystem>:

// Assign a place in the semaphore table of the system and return a pointer to it.
// if the table is full, return null (0)
static struct semaphore*
allocinsystem()
{
801057e2:	55                   	push   %ebp
801057e3:	89 e5                	mov    %esp,%ebp
801057e5:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
801057e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057ef:	eb 2d                	jmp    8010581e <allocinsystem+0x3c>
    s=&stable.sem[i];
801057f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057f4:	89 d0                	mov    %edx,%eax
801057f6:	01 c0                	add    %eax,%eax
801057f8:	01 d0                	add    %edx,%eax
801057fa:	c1 e0 02             	shl    $0x2,%eax
801057fd:	83 c0 30             	add    $0x30,%eax
80105800:	05 e0 70 11 80       	add    $0x801170e0,%eax
80105805:	83 c0 04             	add    $0x4,%eax
80105808:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s->references==0)
8010580b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010580e:	8b 40 04             	mov    0x4(%eax),%eax
80105811:	85 c0                	test   %eax,%eax
80105813:	75 05                	jne    8010581a <allocinsystem+0x38>
      return s;
80105815:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105818:	eb 0f                	jmp    80105829 <allocinsystem+0x47>
static struct semaphore*
allocinsystem()
{
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
8010581a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010581e:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80105822:	7e cd                	jle    801057f1 <allocinsystem+0xf>
    s=&stable.sem[i];
    if(s->references==0)
      return s;
  }
  return 0;
80105824:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105829:	c9                   	leave  
8010582a:	c3                   	ret    

8010582b <semget>:
// if there is no place in the system's semaphore table, return -3.
// if semid> 0 and the semaphore is not in use, return -1.
// if semid <-1 or semid> MAXSEM, return -4.
int
semget(int semid, int initvalue)
{
8010582b:	55                   	push   %ebp
8010582c:	89 e5                	mov    %esp,%ebp
8010582e:	83 ec 18             	sub    $0x18,%esp
  int position=0,retvalue;
80105831:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  struct semaphore* s;

  if(semid<-1 || semid>=MAXSEM)
80105838:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
8010583c:	7c 06                	jl     80105844 <semget+0x19>
8010583e:	83 7d 08 3f          	cmpl   $0x3f,0x8(%ebp)
80105842:	7e 0a                	jle    8010584e <semget+0x23>
    return -4;
80105844:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
80105849:	e9 0d 01 00 00       	jmp    8010595b <semget+0x130>
  acquire(&stable.lock);
8010584e:	83 ec 0c             	sub    $0xc,%esp
80105851:	68 e0 70 11 80       	push   $0x801170e0
80105856:	e8 b5 03 00 00       	call   80105c10 <acquire>
8010585b:	83 c4 10             	add    $0x10,%esp
  position=allocinprocess();
8010585e:	e8 f9 fe ff ff       	call   8010575c <allocinprocess>
80105863:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(position==-1){
80105866:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
8010586a:	75 0c                	jne    80105878 <semget+0x4d>
    retvalue=-2;
8010586c:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retget;
80105873:	e9 d0 00 00 00       	jmp    80105948 <semget+0x11d>
  }
  if(semid==-1){
80105878:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
8010587c:	75 47                	jne    801058c5 <semget+0x9a>
    s=allocinsystem();
8010587e:	e8 5f ff ff ff       	call   801057e2 <allocinsystem>
80105883:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!s){
80105886:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010588a:	75 0c                	jne    80105898 <semget+0x6d>
      retvalue=-3;
8010588c:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
      goto retget;
80105893:	e9 b0 00 00 00       	jmp    80105948 <semget+0x11d>
    }
    s->id=s-stable.sem;
80105898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589b:	ba 14 71 11 80       	mov    $0x80117114,%edx
801058a0:	29 d0                	sub    %edx,%eax
801058a2:	c1 f8 02             	sar    $0x2,%eax
801058a5:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
801058ab:	89 c2                	mov    %eax,%edx
801058ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b0:	89 10                	mov    %edx,(%eax)
    s->value=initvalue;
801058b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801058b8:	89 50 08             	mov    %edx,0x8(%eax)
    retvalue=s->id;
801058bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058be:	8b 00                	mov    (%eax),%eax
801058c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    goto found;
801058c3:	eb 61                	jmp    80105926 <semget+0xfb>
  }
  if(semid>=0){
801058c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801058c9:	78 5b                	js     80105926 <semget+0xfb>
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
801058cb:	c7 45 f0 14 71 11 80 	movl   $0x80117114,-0x10(%ebp)
801058d2:	eb 3f                	jmp    80105913 <semget+0xe8>
      if(s->id==semid && ((s->references)>0)){
801058d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d7:	8b 00                	mov    (%eax),%eax
801058d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801058dc:	75 14                	jne    801058f2 <semget+0xc7>
801058de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e1:	8b 40 04             	mov    0x4(%eax),%eax
801058e4:	85 c0                	test   %eax,%eax
801058e6:	7e 0a                	jle    801058f2 <semget+0xc7>
        retvalue=s->id;
801058e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058eb:	8b 00                	mov    (%eax),%eax
801058ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto found;
801058f0:	eb 34                	jmp    80105926 <semget+0xfb>
      }
      if(s->id==semid && ((s->references)==0)){
801058f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f5:	8b 00                	mov    (%eax),%eax
801058f7:	3b 45 08             	cmp    0x8(%ebp),%eax
801058fa:	75 13                	jne    8010590f <semget+0xe4>
801058fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ff:	8b 40 04             	mov    0x4(%eax),%eax
80105902:	85 c0                	test   %eax,%eax
80105904:	75 09                	jne    8010590f <semget+0xe4>
        retvalue=-1;
80105906:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
        goto retget;
8010590d:	eb 39                	jmp    80105948 <semget+0x11d>
    s->value=initvalue;
    retvalue=s->id;
    goto found;
  }
  if(semid>=0){
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
8010590f:	83 45 f0 0c          	addl   $0xc,-0x10(%ebp)
80105913:	b8 14 74 11 80       	mov    $0x80117414,%eax
80105918:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010591b:	72 b7                	jb     801058d4 <semget+0xa9>
      if(s->id==semid && ((s->references)==0)){
        retvalue=-1;
        goto retget;
      }
    }
    retvalue=-5;
8010591d:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    goto retget;
80105924:	eb 22                	jmp    80105948 <semget+0x11d>
  }
found:
  s->references++;
80105926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105929:	8b 40 04             	mov    0x4(%eax),%eax
8010592c:	8d 50 01             	lea    0x1(%eax),%edx
8010592f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105932:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[position]=s;
80105935:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010593e:	8d 4a 20             	lea    0x20(%edx),%ecx
80105941:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105944:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
retget:
  release(&stable.lock);
80105948:	83 ec 0c             	sub    $0xc,%esp
8010594b:	68 e0 70 11 80       	push   $0x801170e0
80105950:	e8 22 03 00 00       	call   80105c77 <release>
80105955:	83 c4 10             	add    $0x10,%esp
  return retvalue;
80105958:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010595b:	c9                   	leave  
8010595c:	c3                   	ret    

8010595d <semfree>:

// It releases the semaphore of the process if it is not in use, but only decreases the references in 1.
// if the semaphore is not in the process, return -1.
int
semfree(int semid)
{
8010595d:	55                   	push   %ebp
8010595e:	89 e5                	mov    %esp,%ebp
80105960:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int retvalue,pos;

  acquire(&stable.lock);
80105963:	83 ec 0c             	sub    $0xc,%esp
80105966:	68 e0 70 11 80       	push   $0x801170e0
8010596b:	e8 a0 02 00 00       	call   80105c10 <acquire>
80105970:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105973:	83 ec 0c             	sub    $0xc,%esp
80105976:	ff 75 08             	pushl  0x8(%ebp)
80105979:	e8 1c fe ff ff       	call   8010579a <searchinprocess>
8010597e:	83 c4 10             	add    $0x10,%esp
80105981:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
80105984:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105988:	75 09                	jne    80105993 <semfree+0x36>
    retvalue=-1;
8010598a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retfree;
80105991:	eb 50                	jmp    801059e3 <semfree+0x86>
  }
  s=proc->osemaphore[pos];
80105993:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105999:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010599c:	83 c2 20             	add    $0x20,%edx
8010599f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(s->references < 1){
801059a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059a9:	8b 40 04             	mov    0x4(%eax),%eax
801059ac:	85 c0                	test   %eax,%eax
801059ae:	7f 09                	jg     801059b9 <semfree+0x5c>
    retvalue=-2;
801059b0:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retfree;
801059b7:	eb 2a                	jmp    801059e3 <semfree+0x86>
  }
  s->references--;
801059b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059bc:	8b 40 04             	mov    0x4(%eax),%eax
801059bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801059c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059c5:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[pos]=0;
801059c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059d1:	83 c2 20             	add    $0x20,%edx
801059d4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801059db:	00 
  retvalue=0;
801059dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retfree:
  release(&stable.lock);
801059e3:	83 ec 0c             	sub    $0xc,%esp
801059e6:	68 e0 70 11 80       	push   $0x801170e0
801059eb:	e8 87 02 00 00       	call   80105c77 <release>
801059f0:	83 c4 10             	add    $0x10,%esp
  return retvalue;
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059f6:	c9                   	leave  
801059f7:	c3                   	ret    

801059f8 <semdown>:

// Decreases the value of the semaphore if it is greater than 0 but sleeps the process.
// if the semaphore is not in the process, return -1.
int
semdown(int semid)
{
801059f8:	55                   	push   %ebp
801059f9:	89 e5                	mov    %esp,%ebp
801059fb:	83 ec 18             	sub    $0x18,%esp
  int value,pos;
  struct semaphore* s;

  acquire(&stable.lock);
801059fe:	83 ec 0c             	sub    $0xc,%esp
80105a01:	68 e0 70 11 80       	push   $0x801170e0
80105a06:	e8 05 02 00 00       	call   80105c10 <acquire>
80105a0b:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105a0e:	83 ec 0c             	sub    $0xc,%esp
80105a11:	ff 75 08             	pushl  0x8(%ebp)
80105a14:	e8 81 fd ff ff       	call   8010579a <searchinprocess>
80105a19:	83 c4 10             	add    $0x10,%esp
80105a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
80105a1f:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105a23:	75 09                	jne    80105a2e <semdown+0x36>
    value=-1;
80105a25:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retdown;
80105a2c:	eb 48                	jmp    80105a76 <semdown+0x7e>
  }
  s=proc->osemaphore[pos];
80105a2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a37:	83 c2 20             	add    $0x20,%edx
80105a3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  while(s->value<=0){
80105a41:	eb 13                	jmp    80105a56 <semdown+0x5e>
    sleep(s,&stable.lock);
80105a43:	83 ec 08             	sub    $0x8,%esp
80105a46:	68 e0 70 11 80       	push   $0x801170e0
80105a4b:	ff 75 ec             	pushl  -0x14(%ebp)
80105a4e:	e8 01 fa ff ff       	call   80105454 <sleep>
80105a53:	83 c4 10             	add    $0x10,%esp
  if(pos==-1){
    value=-1;
    goto retdown;
  }
  s=proc->osemaphore[pos];
  while(s->value<=0){
80105a56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a59:	8b 40 08             	mov    0x8(%eax),%eax
80105a5c:	85 c0                	test   %eax,%eax
80105a5e:	7e e3                	jle    80105a43 <semdown+0x4b>
    sleep(s,&stable.lock);
  }
  s->value--;
80105a60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a63:	8b 40 08             	mov    0x8(%eax),%eax
80105a66:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a6c:	89 50 08             	mov    %edx,0x8(%eax)
  value=0;
80105a6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retdown:
  release(&stable.lock);
80105a76:	83 ec 0c             	sub    $0xc,%esp
80105a79:	68 e0 70 11 80       	push   $0x801170e0
80105a7e:	e8 f4 01 00 00       	call   80105c77 <release>
80105a83:	83 c4 10             	add    $0x10,%esp
  return value;
80105a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a89:	c9                   	leave  
80105a8a:	c3                   	ret    

80105a8b <semup>:

// It increases the value of the semaphore and wake up processes waiting for it.
// if the semaphore is not in the process, return -1.
int
semup(int semid)
{
80105a8b:	55                   	push   %ebp
80105a8c:	89 e5                	mov    %esp,%ebp
80105a8e:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int pos;

  acquire(&stable.lock);
80105a91:	83 ec 0c             	sub    $0xc,%esp
80105a94:	68 e0 70 11 80       	push   $0x801170e0
80105a99:	e8 72 01 00 00       	call   80105c10 <acquire>
80105a9e:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105aa1:	83 ec 0c             	sub    $0xc,%esp
80105aa4:	ff 75 08             	pushl  0x8(%ebp)
80105aa7:	e8 ee fc ff ff       	call   8010579a <searchinprocess>
80105aac:	83 c4 10             	add    $0x10,%esp
80105aaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pos==-1){
80105ab2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105ab6:	75 17                	jne    80105acf <semup+0x44>
    release(&stable.lock);
80105ab8:	83 ec 0c             	sub    $0xc,%esp
80105abb:	68 e0 70 11 80       	push   $0x801170e0
80105ac0:	e8 b2 01 00 00       	call   80105c77 <release>
80105ac5:	83 c4 10             	add    $0x10,%esp
    return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acd:	eb 45                	jmp    80105b14 <semup+0x89>
  }
  s=proc->osemaphore[pos];
80105acf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad8:	83 c2 20             	add    $0x20,%edx
80105adb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->value++;
80105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae5:	8b 40 08             	mov    0x8(%eax),%eax
80105ae8:	8d 50 01             	lea    0x1(%eax),%edx
80105aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aee:	89 50 08             	mov    %edx,0x8(%eax)
  release(&stable.lock);
80105af1:	83 ec 0c             	sub    $0xc,%esp
80105af4:	68 e0 70 11 80       	push   $0x801170e0
80105af9:	e8 79 01 00 00       	call   80105c77 <release>
80105afe:	83 c4 10             	add    $0x10,%esp
  wakeup(s);
80105b01:	83 ec 0c             	sub    $0xc,%esp
80105b04:	ff 75 f0             	pushl  -0x10(%ebp)
80105b07:	e8 54 fa ff ff       	call   80105560 <wakeup>
80105b0c:	83 c4 10             	add    $0x10,%esp
  return 0;
80105b0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b14:	c9                   	leave  
80105b15:	c3                   	ret    

80105b16 <semclose>:

// Decrease the semaphore references.
void
semclose(struct semaphore* s)
{
80105b16:	55                   	push   %ebp
80105b17:	89 e5                	mov    %esp,%ebp
80105b19:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
80105b1c:	83 ec 0c             	sub    $0xc,%esp
80105b1f:	68 e0 70 11 80       	push   $0x801170e0
80105b24:	e8 e7 00 00 00       	call   80105c10 <acquire>
80105b29:	83 c4 10             	add    $0x10,%esp

  if(s->references < 1)
80105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2f:	8b 40 04             	mov    0x4(%eax),%eax
80105b32:	85 c0                	test   %eax,%eax
80105b34:	7f 0d                	jg     80105b43 <semclose+0x2d>
    panic("semclose");
80105b36:	83 ec 0c             	sub    $0xc,%esp
80105b39:	68 f4 9a 10 80       	push   $0x80109af4
80105b3e:	e8 23 aa ff ff       	call   80100566 <panic>
  s->references--;
80105b43:	8b 45 08             	mov    0x8(%ebp),%eax
80105b46:	8b 40 04             	mov    0x4(%eax),%eax
80105b49:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b4f:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
80105b52:	83 ec 0c             	sub    $0xc,%esp
80105b55:	68 e0 70 11 80       	push   $0x801170e0
80105b5a:	e8 18 01 00 00       	call   80105c77 <release>
80105b5f:	83 c4 10             	add    $0x10,%esp
  return;
80105b62:	90                   	nop

}
80105b63:	c9                   	leave  
80105b64:	c3                   	ret    

80105b65 <semdup>:

// Increase the semaphore references.
struct semaphore*
semdup(struct semaphore* s)
{
80105b65:	55                   	push   %ebp
80105b66:	89 e5                	mov    %esp,%ebp
80105b68:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
80105b6b:	83 ec 0c             	sub    $0xc,%esp
80105b6e:	68 e0 70 11 80       	push   $0x801170e0
80105b73:	e8 98 00 00 00       	call   80105c10 <acquire>
80105b78:	83 c4 10             	add    $0x10,%esp
  if(s->references<0)
80105b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7e:	8b 40 04             	mov    0x4(%eax),%eax
80105b81:	85 c0                	test   %eax,%eax
80105b83:	79 0d                	jns    80105b92 <semdup+0x2d>
    panic("semdup error");
80105b85:	83 ec 0c             	sub    $0xc,%esp
80105b88:	68 fd 9a 10 80       	push   $0x80109afd
80105b8d:	e8 d4 a9 ff ff       	call   80100566 <panic>
  s->references++;
80105b92:	8b 45 08             	mov    0x8(%ebp),%eax
80105b95:	8b 40 04             	mov    0x4(%eax),%eax
80105b98:	8d 50 01             	lea    0x1(%eax),%edx
80105b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
80105ba1:	83 ec 0c             	sub    $0xc,%esp
80105ba4:	68 e0 70 11 80       	push   $0x801170e0
80105ba9:	e8 c9 00 00 00       	call   80105c77 <release>
80105bae:	83 c4 10             	add    $0x10,%esp
  return s;
80105bb1:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105bb4:	c9                   	leave  
80105bb5:	c3                   	ret    

80105bb6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105bb6:	55                   	push   %ebp
80105bb7:	89 e5                	mov    %esp,%ebp
80105bb9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105bbc:	9c                   	pushf  
80105bbd:	58                   	pop    %eax
80105bbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105bc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bc4:	c9                   	leave  
80105bc5:	c3                   	ret    

80105bc6 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105bc6:	55                   	push   %ebp
80105bc7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105bc9:	fa                   	cli    
}
80105bca:	90                   	nop
80105bcb:	5d                   	pop    %ebp
80105bcc:	c3                   	ret    

80105bcd <sti>:

static inline void
sti(void)
{
80105bcd:	55                   	push   %ebp
80105bce:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105bd0:	fb                   	sti    
}
80105bd1:	90                   	nop
80105bd2:	5d                   	pop    %ebp
80105bd3:	c3                   	ret    

80105bd4 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105bd4:	55                   	push   %ebp
80105bd5:	89 e5                	mov    %esp,%ebp
80105bd7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105bda:	8b 55 08             	mov    0x8(%ebp),%edx
80105bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105be3:	f0 87 02             	lock xchg %eax,(%edx)
80105be6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105be9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bec:	c9                   	leave  
80105bed:	c3                   	ret    

80105bee <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105bee:	55                   	push   %ebp
80105bef:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bf7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80105bfd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105c03:	8b 45 08             	mov    0x8(%ebp),%eax
80105c06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105c0d:	90                   	nop
80105c0e:	5d                   	pop    %ebp
80105c0f:	c3                   	ret    

80105c10 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105c10:	55                   	push   %ebp
80105c11:	89 e5                	mov    %esp,%ebp
80105c13:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105c16:	e8 52 01 00 00       	call   80105d6d <pushcli>
  if(holding(lk))
80105c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1e:	83 ec 0c             	sub    $0xc,%esp
80105c21:	50                   	push   %eax
80105c22:	e8 1c 01 00 00       	call   80105d43 <holding>
80105c27:	83 c4 10             	add    $0x10,%esp
80105c2a:	85 c0                	test   %eax,%eax
80105c2c:	74 0d                	je     80105c3b <acquire+0x2b>
    panic("acquire");
80105c2e:	83 ec 0c             	sub    $0xc,%esp
80105c31:	68 0a 9b 10 80       	push   $0x80109b0a
80105c36:	e8 2b a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while(xchg(&lk->locked, 1) != 0)
80105c3b:	90                   	nop
80105c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3f:	83 ec 08             	sub    $0x8,%esp
80105c42:	6a 01                	push   $0x1
80105c44:	50                   	push   %eax
80105c45:	e8 8a ff ff ff       	call   80105bd4 <xchg>
80105c4a:	83 c4 10             	add    $0x10,%esp
80105c4d:	85 c0                	test   %eax,%eax
80105c4f:	75 eb                	jne    80105c3c <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105c51:	8b 45 08             	mov    0x8(%ebp),%eax
80105c54:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105c5b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c61:	83 c0 0c             	add    $0xc,%eax
80105c64:	83 ec 08             	sub    $0x8,%esp
80105c67:	50                   	push   %eax
80105c68:	8d 45 08             	lea    0x8(%ebp),%eax
80105c6b:	50                   	push   %eax
80105c6c:	e8 58 00 00 00       	call   80105cc9 <getcallerpcs>
80105c71:	83 c4 10             	add    $0x10,%esp
}
80105c74:	90                   	nop
80105c75:	c9                   	leave  
80105c76:	c3                   	ret    

80105c77 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105c77:	55                   	push   %ebp
80105c78:	89 e5                	mov    %esp,%ebp
80105c7a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105c7d:	83 ec 0c             	sub    $0xc,%esp
80105c80:	ff 75 08             	pushl  0x8(%ebp)
80105c83:	e8 bb 00 00 00       	call   80105d43 <holding>
80105c88:	83 c4 10             	add    $0x10,%esp
80105c8b:	85 c0                	test   %eax,%eax
80105c8d:	75 0d                	jne    80105c9c <release+0x25>
    panic("release");
80105c8f:	83 ec 0c             	sub    $0xc,%esp
80105c92:	68 12 9b 10 80       	push   $0x80109b12
80105c97:	e8 ca a8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c9f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb3:	83 ec 08             	sub    $0x8,%esp
80105cb6:	6a 00                	push   $0x0
80105cb8:	50                   	push   %eax
80105cb9:	e8 16 ff ff ff       	call   80105bd4 <xchg>
80105cbe:	83 c4 10             	add    $0x10,%esp

  popcli();
80105cc1:	e8 ec 00 00 00       	call   80105db2 <popcli>
}
80105cc6:	90                   	nop
80105cc7:	c9                   	leave  
80105cc8:	c3                   	ret    

80105cc9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105cc9:	55                   	push   %ebp
80105cca:	89 e5                	mov    %esp,%ebp
80105ccc:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd2:	83 e8 08             	sub    $0x8,%eax
80105cd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105cd8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105cdf:	eb 38                	jmp    80105d19 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105ce1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105ce5:	74 53                	je     80105d3a <getcallerpcs+0x71>
80105ce7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105cee:	76 4a                	jbe    80105d3a <getcallerpcs+0x71>
80105cf0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105cf4:	74 44                	je     80105d3a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105cf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105d00:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d03:	01 c2                	add    %eax,%edx
80105d05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d08:	8b 40 04             	mov    0x4(%eax),%eax
80105d0b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d10:	8b 00                	mov    (%eax),%eax
80105d12:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105d15:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d19:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d1d:	7e c2                	jle    80105ce1 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d1f:	eb 19                	jmp    80105d3a <getcallerpcs+0x71>
    pcs[i] = 0;
80105d21:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2e:	01 d0                	add    %edx,%eax
80105d30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d36:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d3a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d3e:	7e e1                	jle    80105d21 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105d40:	90                   	nop
80105d41:	c9                   	leave  
80105d42:	c3                   	ret    

80105d43 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105d43:	55                   	push   %ebp
80105d44:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105d46:	8b 45 08             	mov    0x8(%ebp),%eax
80105d49:	8b 00                	mov    (%eax),%eax
80105d4b:	85 c0                	test   %eax,%eax
80105d4d:	74 17                	je     80105d66 <holding+0x23>
80105d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d52:	8b 50 08             	mov    0x8(%eax),%edx
80105d55:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d5b:	39 c2                	cmp    %eax,%edx
80105d5d:	75 07                	jne    80105d66 <holding+0x23>
80105d5f:	b8 01 00 00 00       	mov    $0x1,%eax
80105d64:	eb 05                	jmp    80105d6b <holding+0x28>
80105d66:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d6b:	5d                   	pop    %ebp
80105d6c:	c3                   	ret    

80105d6d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105d6d:	55                   	push   %ebp
80105d6e:	89 e5                	mov    %esp,%ebp
80105d70:	83 ec 10             	sub    $0x10,%esp
  int eflags;

  eflags = readeflags();
80105d73:	e8 3e fe ff ff       	call   80105bb6 <readeflags>
80105d78:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105d7b:	e8 46 fe ff ff       	call   80105bc6 <cli>
  if(cpu->ncli++ == 0)
80105d80:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d87:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d8d:	8d 48 01             	lea    0x1(%eax),%ecx
80105d90:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d96:	85 c0                	test   %eax,%eax
80105d98:	75 15                	jne    80105daf <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d9a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105da0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105da3:	81 e2 00 02 00 00    	and    $0x200,%edx
80105da9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105daf:	90                   	nop
80105db0:	c9                   	leave  
80105db1:	c3                   	ret    

80105db2 <popcli>:

void
popcli(void)
{
80105db2:	55                   	push   %ebp
80105db3:	89 e5                	mov    %esp,%ebp
80105db5:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105db8:	e8 f9 fd ff ff       	call   80105bb6 <readeflags>
80105dbd:	25 00 02 00 00       	and    $0x200,%eax
80105dc2:	85 c0                	test   %eax,%eax
80105dc4:	74 0d                	je     80105dd3 <popcli+0x21>
    panic("popcli - interruptible");
80105dc6:	83 ec 0c             	sub    $0xc,%esp
80105dc9:	68 1a 9b 10 80       	push   $0x80109b1a
80105dce:	e8 93 a7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105dd3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105dd9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105ddf:	83 ea 01             	sub    $0x1,%edx
80105de2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105de8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105dee:	85 c0                	test   %eax,%eax
80105df0:	79 0d                	jns    80105dff <popcli+0x4d>
    panic("popcli");
80105df2:	83 ec 0c             	sub    $0xc,%esp
80105df5:	68 31 9b 10 80       	push   $0x80109b31
80105dfa:	e8 67 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105dff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e05:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105e0b:	85 c0                	test   %eax,%eax
80105e0d:	75 15                	jne    80105e24 <popcli+0x72>
80105e0f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e15:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105e1b:	85 c0                	test   %eax,%eax
80105e1d:	74 05                	je     80105e24 <popcli+0x72>
    sti();
80105e1f:	e8 a9 fd ff ff       	call   80105bcd <sti>
}
80105e24:	90                   	nop
80105e25:	c9                   	leave  
80105e26:	c3                   	ret    

80105e27 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105e27:	55                   	push   %ebp
80105e28:	89 e5                	mov    %esp,%ebp
80105e2a:	57                   	push   %edi
80105e2b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e2f:	8b 55 10             	mov    0x10(%ebp),%edx
80105e32:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e35:	89 cb                	mov    %ecx,%ebx
80105e37:	89 df                	mov    %ebx,%edi
80105e39:	89 d1                	mov    %edx,%ecx
80105e3b:	fc                   	cld    
80105e3c:	f3 aa                	rep stos %al,%es:(%edi)
80105e3e:	89 ca                	mov    %ecx,%edx
80105e40:	89 fb                	mov    %edi,%ebx
80105e42:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e45:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e48:	90                   	nop
80105e49:	5b                   	pop    %ebx
80105e4a:	5f                   	pop    %edi
80105e4b:	5d                   	pop    %ebp
80105e4c:	c3                   	ret    

80105e4d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105e4d:	55                   	push   %ebp
80105e4e:	89 e5                	mov    %esp,%ebp
80105e50:	57                   	push   %edi
80105e51:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e55:	8b 55 10             	mov    0x10(%ebp),%edx
80105e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e5b:	89 cb                	mov    %ecx,%ebx
80105e5d:	89 df                	mov    %ebx,%edi
80105e5f:	89 d1                	mov    %edx,%ecx
80105e61:	fc                   	cld    
80105e62:	f3 ab                	rep stos %eax,%es:(%edi)
80105e64:	89 ca                	mov    %ecx,%edx
80105e66:	89 fb                	mov    %edi,%ebx
80105e68:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e6b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e6e:	90                   	nop
80105e6f:	5b                   	pop    %ebx
80105e70:	5f                   	pop    %edi
80105e71:	5d                   	pop    %ebp
80105e72:	c3                   	ret    

80105e73 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105e73:	55                   	push   %ebp
80105e74:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105e76:	8b 45 08             	mov    0x8(%ebp),%eax
80105e79:	83 e0 03             	and    $0x3,%eax
80105e7c:	85 c0                	test   %eax,%eax
80105e7e:	75 43                	jne    80105ec3 <memset+0x50>
80105e80:	8b 45 10             	mov    0x10(%ebp),%eax
80105e83:	83 e0 03             	and    $0x3,%eax
80105e86:	85 c0                	test   %eax,%eax
80105e88:	75 39                	jne    80105ec3 <memset+0x50>
    c &= 0xFF;
80105e8a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e91:	8b 45 10             	mov    0x10(%ebp),%eax
80105e94:	c1 e8 02             	shr    $0x2,%eax
80105e97:	89 c1                	mov    %eax,%ecx
80105e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e9c:	c1 e0 18             	shl    $0x18,%eax
80105e9f:	89 c2                	mov    %eax,%edx
80105ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea4:	c1 e0 10             	shl    $0x10,%eax
80105ea7:	09 c2                	or     %eax,%edx
80105ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eac:	c1 e0 08             	shl    $0x8,%eax
80105eaf:	09 d0                	or     %edx,%eax
80105eb1:	0b 45 0c             	or     0xc(%ebp),%eax
80105eb4:	51                   	push   %ecx
80105eb5:	50                   	push   %eax
80105eb6:	ff 75 08             	pushl  0x8(%ebp)
80105eb9:	e8 8f ff ff ff       	call   80105e4d <stosl>
80105ebe:	83 c4 0c             	add    $0xc,%esp
80105ec1:	eb 12                	jmp    80105ed5 <memset+0x62>
  } else
    stosb(dst, c, n);
80105ec3:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec6:	50                   	push   %eax
80105ec7:	ff 75 0c             	pushl  0xc(%ebp)
80105eca:	ff 75 08             	pushl  0x8(%ebp)
80105ecd:	e8 55 ff ff ff       	call   80105e27 <stosb>
80105ed2:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105ed5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ed8:	c9                   	leave  
80105ed9:	c3                   	ret    

80105eda <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105eda:	55                   	push   %ebp
80105edb:	89 e5                	mov    %esp,%ebp
80105edd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ee9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105eec:	eb 30                	jmp    80105f1e <memcmp+0x44>
    if(*s1 != *s2)
80105eee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ef1:	0f b6 10             	movzbl (%eax),%edx
80105ef4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ef7:	0f b6 00             	movzbl (%eax),%eax
80105efa:	38 c2                	cmp    %al,%dl
80105efc:	74 18                	je     80105f16 <memcmp+0x3c>
      return *s1 - *s2;
80105efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f01:	0f b6 00             	movzbl (%eax),%eax
80105f04:	0f b6 d0             	movzbl %al,%edx
80105f07:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f0a:	0f b6 00             	movzbl (%eax),%eax
80105f0d:	0f b6 c0             	movzbl %al,%eax
80105f10:	29 c2                	sub    %eax,%edx
80105f12:	89 d0                	mov    %edx,%eax
80105f14:	eb 1a                	jmp    80105f30 <memcmp+0x56>
    s1++, s2++;
80105f16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f1a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105f1e:	8b 45 10             	mov    0x10(%ebp),%eax
80105f21:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f24:	89 55 10             	mov    %edx,0x10(%ebp)
80105f27:	85 c0                	test   %eax,%eax
80105f29:	75 c3                	jne    80105eee <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105f2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f30:	c9                   	leave  
80105f31:	c3                   	ret    

80105f32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105f32:	55                   	push   %ebp
80105f33:	89 e5                	mov    %esp,%ebp
80105f35:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105f38:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f41:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105f44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f47:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f4a:	73 54                	jae    80105fa0 <memmove+0x6e>
80105f4c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f4f:	8b 45 10             	mov    0x10(%ebp),%eax
80105f52:	01 d0                	add    %edx,%eax
80105f54:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f57:	76 47                	jbe    80105fa0 <memmove+0x6e>
    s += n;
80105f59:	8b 45 10             	mov    0x10(%ebp),%eax
80105f5c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105f5f:	8b 45 10             	mov    0x10(%ebp),%eax
80105f62:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105f65:	eb 13                	jmp    80105f7a <memmove+0x48>
      *--d = *--s;
80105f67:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105f6b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105f6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f72:	0f b6 10             	movzbl (%eax),%edx
80105f75:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f78:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105f7a:	8b 45 10             	mov    0x10(%ebp),%eax
80105f7d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f80:	89 55 10             	mov    %edx,0x10(%ebp)
80105f83:	85 c0                	test   %eax,%eax
80105f85:	75 e0                	jne    80105f67 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f87:	eb 24                	jmp    80105fad <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f89:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f8c:	8d 50 01             	lea    0x1(%eax),%edx
80105f8f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f95:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f98:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f9b:	0f b6 12             	movzbl (%edx),%edx
80105f9e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105fa0:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fa6:	89 55 10             	mov    %edx,0x10(%ebp)
80105fa9:	85 c0                	test   %eax,%eax
80105fab:	75 dc                	jne    80105f89 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105fad:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105fb0:	c9                   	leave  
80105fb1:	c3                   	ret    

80105fb2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105fb2:	55                   	push   %ebp
80105fb3:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105fb5:	ff 75 10             	pushl  0x10(%ebp)
80105fb8:	ff 75 0c             	pushl  0xc(%ebp)
80105fbb:	ff 75 08             	pushl  0x8(%ebp)
80105fbe:	e8 6f ff ff ff       	call   80105f32 <memmove>
80105fc3:	83 c4 0c             	add    $0xc,%esp
}
80105fc6:	c9                   	leave  
80105fc7:	c3                   	ret    

80105fc8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105fc8:	55                   	push   %ebp
80105fc9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105fcb:	eb 0c                	jmp    80105fd9 <strncmp+0x11>
    n--, p++, q++;
80105fcd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105fd1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105fd5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105fd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105fdd:	74 1a                	je     80105ff9 <strncmp+0x31>
80105fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe2:	0f b6 00             	movzbl (%eax),%eax
80105fe5:	84 c0                	test   %al,%al
80105fe7:	74 10                	je     80105ff9 <strncmp+0x31>
80105fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80105fec:	0f b6 10             	movzbl (%eax),%edx
80105fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ff2:	0f b6 00             	movzbl (%eax),%eax
80105ff5:	38 c2                	cmp    %al,%dl
80105ff7:	74 d4                	je     80105fcd <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105ff9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ffd:	75 07                	jne    80106006 <strncmp+0x3e>
    return 0;
80105fff:	b8 00 00 00 00       	mov    $0x0,%eax
80106004:	eb 16                	jmp    8010601c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106006:	8b 45 08             	mov    0x8(%ebp),%eax
80106009:	0f b6 00             	movzbl (%eax),%eax
8010600c:	0f b6 d0             	movzbl %al,%edx
8010600f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106012:	0f b6 00             	movzbl (%eax),%eax
80106015:	0f b6 c0             	movzbl %al,%eax
80106018:	29 c2                	sub    %eax,%edx
8010601a:	89 d0                	mov    %edx,%eax
}
8010601c:	5d                   	pop    %ebp
8010601d:	c3                   	ret    

8010601e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010601e:	55                   	push   %ebp
8010601f:	89 e5                	mov    %esp,%ebp
80106021:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106024:	8b 45 08             	mov    0x8(%ebp),%eax
80106027:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010602a:	90                   	nop
8010602b:	8b 45 10             	mov    0x10(%ebp),%eax
8010602e:	8d 50 ff             	lea    -0x1(%eax),%edx
80106031:	89 55 10             	mov    %edx,0x10(%ebp)
80106034:	85 c0                	test   %eax,%eax
80106036:	7e 2c                	jle    80106064 <strncpy+0x46>
80106038:	8b 45 08             	mov    0x8(%ebp),%eax
8010603b:	8d 50 01             	lea    0x1(%eax),%edx
8010603e:	89 55 08             	mov    %edx,0x8(%ebp)
80106041:	8b 55 0c             	mov    0xc(%ebp),%edx
80106044:	8d 4a 01             	lea    0x1(%edx),%ecx
80106047:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010604a:	0f b6 12             	movzbl (%edx),%edx
8010604d:	88 10                	mov    %dl,(%eax)
8010604f:	0f b6 00             	movzbl (%eax),%eax
80106052:	84 c0                	test   %al,%al
80106054:	75 d5                	jne    8010602b <strncpy+0xd>
    ;
  while(n-- > 0)
80106056:	eb 0c                	jmp    80106064 <strncpy+0x46>
    *s++ = 0;
80106058:	8b 45 08             	mov    0x8(%ebp),%eax
8010605b:	8d 50 01             	lea    0x1(%eax),%edx
8010605e:	89 55 08             	mov    %edx,0x8(%ebp)
80106061:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106064:	8b 45 10             	mov    0x10(%ebp),%eax
80106067:	8d 50 ff             	lea    -0x1(%eax),%edx
8010606a:	89 55 10             	mov    %edx,0x10(%ebp)
8010606d:	85 c0                	test   %eax,%eax
8010606f:	7f e7                	jg     80106058 <strncpy+0x3a>
    *s++ = 0;
  return os;
80106071:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106074:	c9                   	leave  
80106075:	c3                   	ret    

80106076 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106076:	55                   	push   %ebp
80106077:	89 e5                	mov    %esp,%ebp
80106079:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010607c:	8b 45 08             	mov    0x8(%ebp),%eax
8010607f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106082:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106086:	7f 05                	jg     8010608d <safestrcpy+0x17>
    return os;
80106088:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010608b:	eb 31                	jmp    801060be <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010608d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106091:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106095:	7e 1e                	jle    801060b5 <safestrcpy+0x3f>
80106097:	8b 45 08             	mov    0x8(%ebp),%eax
8010609a:	8d 50 01             	lea    0x1(%eax),%edx
8010609d:	89 55 08             	mov    %edx,0x8(%ebp)
801060a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801060a3:	8d 4a 01             	lea    0x1(%edx),%ecx
801060a6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801060a9:	0f b6 12             	movzbl (%edx),%edx
801060ac:	88 10                	mov    %dl,(%eax)
801060ae:	0f b6 00             	movzbl (%eax),%eax
801060b1:	84 c0                	test   %al,%al
801060b3:	75 d8                	jne    8010608d <safestrcpy+0x17>
    ;
  *s = 0;
801060b5:	8b 45 08             	mov    0x8(%ebp),%eax
801060b8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801060bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060be:	c9                   	leave  
801060bf:	c3                   	ret    

801060c0 <strlen>:

int
strlen(const char *s)
{
801060c0:	55                   	push   %ebp
801060c1:	89 e5                	mov    %esp,%ebp
801060c3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801060c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801060cd:	eb 04                	jmp    801060d3 <strlen+0x13>
801060cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060d6:	8b 45 08             	mov    0x8(%ebp),%eax
801060d9:	01 d0                	add    %edx,%eax
801060db:	0f b6 00             	movzbl (%eax),%eax
801060de:	84 c0                	test   %al,%al
801060e0:	75 ed                	jne    801060cf <strlen+0xf>
    ;
  return n;
801060e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060e5:	c9                   	leave  
801060e6:	c3                   	ret    

801060e7 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801060e7:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801060eb:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801060ef:	55                   	push   %ebp
  pushl %ebx
801060f0:	53                   	push   %ebx
  pushl %esi
801060f1:	56                   	push   %esi
  pushl %edi
801060f2:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801060f3:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801060f5:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801060f7:	5f                   	pop    %edi
  popl %esi
801060f8:	5e                   	pop    %esi
  popl %ebx
801060f9:	5b                   	pop    %ebx
  popl %ebp
801060fa:	5d                   	pop    %ebp
  ret
801060fb:	c3                   	ret    

801060fc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801060fc:	55                   	push   %ebp
801060fd:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801060ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106105:	8b 00                	mov    (%eax),%eax
80106107:	3b 45 08             	cmp    0x8(%ebp),%eax
8010610a:	76 12                	jbe    8010611e <fetchint+0x22>
8010610c:	8b 45 08             	mov    0x8(%ebp),%eax
8010610f:	8d 50 04             	lea    0x4(%eax),%edx
80106112:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106118:	8b 00                	mov    (%eax),%eax
8010611a:	39 c2                	cmp    %eax,%edx
8010611c:	76 07                	jbe    80106125 <fetchint+0x29>
    return -1;
8010611e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106123:	eb 0f                	jmp    80106134 <fetchint+0x38>
  *ip = *(int*)(addr);
80106125:	8b 45 08             	mov    0x8(%ebp),%eax
80106128:	8b 10                	mov    (%eax),%edx
8010612a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010612d:	89 10                	mov    %edx,(%eax)
  return 0;
8010612f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106134:	5d                   	pop    %ebp
80106135:	c3                   	ret    

80106136 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106136:	55                   	push   %ebp
80106137:	89 e5                	mov    %esp,%ebp
80106139:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010613c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106142:	8b 00                	mov    (%eax),%eax
80106144:	3b 45 08             	cmp    0x8(%ebp),%eax
80106147:	77 07                	ja     80106150 <fetchstr+0x1a>
    return -1;
80106149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614e:	eb 46                	jmp    80106196 <fetchstr+0x60>
  *pp = (char*)addr;
80106150:	8b 55 08             	mov    0x8(%ebp),%edx
80106153:	8b 45 0c             	mov    0xc(%ebp),%eax
80106156:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106158:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615e:	8b 00                	mov    (%eax),%eax
80106160:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106163:	8b 45 0c             	mov    0xc(%ebp),%eax
80106166:	8b 00                	mov    (%eax),%eax
80106168:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010616b:	eb 1c                	jmp    80106189 <fetchstr+0x53>
    if(*s == 0)
8010616d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106170:	0f b6 00             	movzbl (%eax),%eax
80106173:	84 c0                	test   %al,%al
80106175:	75 0e                	jne    80106185 <fetchstr+0x4f>
      return s - *pp;
80106177:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010617a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010617d:	8b 00                	mov    (%eax),%eax
8010617f:	29 c2                	sub    %eax,%edx
80106181:	89 d0                	mov    %edx,%eax
80106183:	eb 11                	jmp    80106196 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106185:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106189:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010618c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010618f:	72 dc                	jb     8010616d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106196:	c9                   	leave  
80106197:	c3                   	ret    

80106198 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106198:	55                   	push   %ebp
80106199:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010619b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061a1:	8b 40 18             	mov    0x18(%eax),%eax
801061a4:	8b 40 44             	mov    0x44(%eax),%eax
801061a7:	8b 55 08             	mov    0x8(%ebp),%edx
801061aa:	c1 e2 02             	shl    $0x2,%edx
801061ad:	01 d0                	add    %edx,%eax
801061af:	83 c0 04             	add    $0x4,%eax
801061b2:	ff 75 0c             	pushl  0xc(%ebp)
801061b5:	50                   	push   %eax
801061b6:	e8 41 ff ff ff       	call   801060fc <fetchint>
801061bb:	83 c4 08             	add    $0x8,%esp
}
801061be:	c9                   	leave  
801061bf:	c3                   	ret    

801061c0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801061c0:	55                   	push   %ebp
801061c1:	89 e5                	mov    %esp,%ebp
801061c3:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
801061c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061c9:	50                   	push   %eax
801061ca:	ff 75 08             	pushl  0x8(%ebp)
801061cd:	e8 c6 ff ff ff       	call   80106198 <argint>
801061d2:	83 c4 08             	add    $0x8,%esp
801061d5:	85 c0                	test   %eax,%eax
801061d7:	79 07                	jns    801061e0 <argptr+0x20>
    return -1;
801061d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061de:	eb 3b                	jmp    8010621b <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801061e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e6:	8b 00                	mov    (%eax),%eax
801061e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061eb:	39 d0                	cmp    %edx,%eax
801061ed:	76 16                	jbe    80106205 <argptr+0x45>
801061ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061f2:	89 c2                	mov    %eax,%edx
801061f4:	8b 45 10             	mov    0x10(%ebp),%eax
801061f7:	01 c2                	add    %eax,%edx
801061f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ff:	8b 00                	mov    (%eax),%eax
80106201:	39 c2                	cmp    %eax,%edx
80106203:	76 07                	jbe    8010620c <argptr+0x4c>
    return -1;
80106205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620a:	eb 0f                	jmp    8010621b <argptr+0x5b>
  *pp = (char*)i;
8010620c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010620f:	89 c2                	mov    %eax,%edx
80106211:	8b 45 0c             	mov    0xc(%ebp),%eax
80106214:	89 10                	mov    %edx,(%eax)
  return 0;
80106216:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010621b:	c9                   	leave  
8010621c:	c3                   	ret    

8010621d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010621d:	55                   	push   %ebp
8010621e:	89 e5                	mov    %esp,%ebp
80106220:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106223:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106226:	50                   	push   %eax
80106227:	ff 75 08             	pushl  0x8(%ebp)
8010622a:	e8 69 ff ff ff       	call   80106198 <argint>
8010622f:	83 c4 08             	add    $0x8,%esp
80106232:	85 c0                	test   %eax,%eax
80106234:	79 07                	jns    8010623d <argstr+0x20>
    return -1;
80106236:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623b:	eb 0f                	jmp    8010624c <argstr+0x2f>
  return fetchstr(addr, pp);
8010623d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106240:	ff 75 0c             	pushl  0xc(%ebp)
80106243:	50                   	push   %eax
80106244:	e8 ed fe ff ff       	call   80106136 <fetchstr>
80106249:	83 c4 08             	add    $0x8,%esp
}
8010624c:	c9                   	leave  
8010624d:	c3                   	ret    

8010624e <syscall>:
[SYS_munmap]   sys_munmap
};

void
syscall(void)
{
8010624e:	55                   	push   %ebp
8010624f:	89 e5                	mov    %esp,%ebp
80106251:	53                   	push   %ebx
80106252:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106255:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010625b:	8b 40 18             	mov    0x18(%eax),%eax
8010625e:	8b 40 1c             	mov    0x1c(%eax),%eax
80106261:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106264:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106268:	7e 30                	jle    8010629a <syscall+0x4c>
8010626a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626d:	83 f8 1e             	cmp    $0x1e,%eax
80106270:	77 28                	ja     8010629a <syscall+0x4c>
80106272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106275:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010627c:	85 c0                	test   %eax,%eax
8010627e:	74 1a                	je     8010629a <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106280:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106286:	8b 58 18             	mov    0x18(%eax),%ebx
80106289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010628c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106293:	ff d0                	call   *%eax
80106295:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106298:	eb 34                	jmp    801062ce <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010629a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a0:	8d 50 6c             	lea    0x6c(%eax),%edx
801062a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801062a9:	8b 40 10             	mov    0x10(%eax),%eax
801062ac:	ff 75 f4             	pushl  -0xc(%ebp)
801062af:	52                   	push   %edx
801062b0:	50                   	push   %eax
801062b1:	68 38 9b 10 80       	push   $0x80109b38
801062b6:	e8 0b a1 ff ff       	call   801003c6 <cprintf>
801062bb:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801062be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062c4:	8b 40 18             	mov    0x18(%eax),%eax
801062c7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801062ce:	90                   	nop
801062cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801062d2:	c9                   	leave  
801062d3:	c3                   	ret    

801062d4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801062d4:	55                   	push   %ebp
801062d5:	89 e5                	mov    %esp,%ebp
801062d7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801062da:	83 ec 08             	sub    $0x8,%esp
801062dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062e0:	50                   	push   %eax
801062e1:	ff 75 08             	pushl  0x8(%ebp)
801062e4:	e8 af fe ff ff       	call   80106198 <argint>
801062e9:	83 c4 10             	add    $0x10,%esp
801062ec:	85 c0                	test   %eax,%eax
801062ee:	79 07                	jns    801062f7 <argfd+0x23>
    return -1;
801062f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f5:	eb 50                	jmp    80106347 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801062f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fa:	85 c0                	test   %eax,%eax
801062fc:	78 21                	js     8010631f <argfd+0x4b>
801062fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106301:	83 f8 0f             	cmp    $0xf,%eax
80106304:	7f 19                	jg     8010631f <argfd+0x4b>
80106306:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010630c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010630f:	83 c2 08             	add    $0x8,%edx
80106312:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106316:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106319:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631d:	75 07                	jne    80106326 <argfd+0x52>
    return -1;
8010631f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106324:	eb 21                	jmp    80106347 <argfd+0x73>
  if(pfd)
80106326:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010632a:	74 08                	je     80106334 <argfd+0x60>
    *pfd = fd;
8010632c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010632f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106332:	89 10                	mov    %edx,(%eax)
  if(pf)
80106334:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106338:	74 08                	je     80106342 <argfd+0x6e>
    *pf = f;
8010633a:	8b 45 10             	mov    0x10(%ebp),%eax
8010633d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106340:	89 10                	mov    %edx,(%eax)
  return 0;
80106342:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106347:	c9                   	leave  
80106348:	c3                   	ret    

80106349 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106349:	55                   	push   %ebp
8010634a:	89 e5                	mov    %esp,%ebp
8010634c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010634f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106356:	eb 30                	jmp    80106388 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106358:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010635e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106361:	83 c2 08             	add    $0x8,%edx
80106364:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106368:	85 c0                	test   %eax,%eax
8010636a:	75 18                	jne    80106384 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010636c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106372:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106375:	8d 4a 08             	lea    0x8(%edx),%ecx
80106378:	8b 55 08             	mov    0x8(%ebp),%edx
8010637b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010637f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106382:	eb 0f                	jmp    80106393 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106384:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106388:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010638c:	7e ca                	jle    80106358 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010638e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106393:	c9                   	leave  
80106394:	c3                   	ret    

80106395 <sys_dup>:

int
sys_dup(void)
{
80106395:	55                   	push   %ebp
80106396:	89 e5                	mov    %esp,%ebp
80106398:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010639b:	83 ec 04             	sub    $0x4,%esp
8010639e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063a1:	50                   	push   %eax
801063a2:	6a 00                	push   $0x0
801063a4:	6a 00                	push   $0x0
801063a6:	e8 29 ff ff ff       	call   801062d4 <argfd>
801063ab:	83 c4 10             	add    $0x10,%esp
801063ae:	85 c0                	test   %eax,%eax
801063b0:	79 07                	jns    801063b9 <sys_dup+0x24>
    return -1;
801063b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b7:	eb 31                	jmp    801063ea <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801063b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063bc:	83 ec 0c             	sub    $0xc,%esp
801063bf:	50                   	push   %eax
801063c0:	e8 84 ff ff ff       	call   80106349 <fdalloc>
801063c5:	83 c4 10             	add    $0x10,%esp
801063c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063cf:	79 07                	jns    801063d8 <sys_dup+0x43>
    return -1;
801063d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d6:	eb 12                	jmp    801063ea <sys_dup+0x55>
  filedup(f);
801063d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063db:	83 ec 0c             	sub    $0xc,%esp
801063de:	50                   	push   %eax
801063df:	e8 09 ac ff ff       	call   80100fed <filedup>
801063e4:	83 c4 10             	add    $0x10,%esp
  return fd;
801063e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063ea:	c9                   	leave  
801063eb:	c3                   	ret    

801063ec <sys_read>:

int
sys_read(void)
{
801063ec:	55                   	push   %ebp
801063ed:	89 e5                	mov    %esp,%ebp
801063ef:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063f2:	83 ec 04             	sub    $0x4,%esp
801063f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063f8:	50                   	push   %eax
801063f9:	6a 00                	push   $0x0
801063fb:	6a 00                	push   $0x0
801063fd:	e8 d2 fe ff ff       	call   801062d4 <argfd>
80106402:	83 c4 10             	add    $0x10,%esp
80106405:	85 c0                	test   %eax,%eax
80106407:	78 2e                	js     80106437 <sys_read+0x4b>
80106409:	83 ec 08             	sub    $0x8,%esp
8010640c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010640f:	50                   	push   %eax
80106410:	6a 02                	push   $0x2
80106412:	e8 81 fd ff ff       	call   80106198 <argint>
80106417:	83 c4 10             	add    $0x10,%esp
8010641a:	85 c0                	test   %eax,%eax
8010641c:	78 19                	js     80106437 <sys_read+0x4b>
8010641e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106421:	83 ec 04             	sub    $0x4,%esp
80106424:	50                   	push   %eax
80106425:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106428:	50                   	push   %eax
80106429:	6a 01                	push   $0x1
8010642b:	e8 90 fd ff ff       	call   801061c0 <argptr>
80106430:	83 c4 10             	add    $0x10,%esp
80106433:	85 c0                	test   %eax,%eax
80106435:	79 07                	jns    8010643e <sys_read+0x52>
    return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	eb 17                	jmp    80106455 <sys_read+0x69>
  return fileread(f, p, n);
8010643e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106441:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106447:	83 ec 04             	sub    $0x4,%esp
8010644a:	51                   	push   %ecx
8010644b:	52                   	push   %edx
8010644c:	50                   	push   %eax
8010644d:	e8 2b ad ff ff       	call   8010117d <fileread>
80106452:	83 c4 10             	add    $0x10,%esp
}
80106455:	c9                   	leave  
80106456:	c3                   	ret    

80106457 <sys_write>:

int
sys_write(void)
{
80106457:	55                   	push   %ebp
80106458:	89 e5                	mov    %esp,%ebp
8010645a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010645d:	83 ec 04             	sub    $0x4,%esp
80106460:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106463:	50                   	push   %eax
80106464:	6a 00                	push   $0x0
80106466:	6a 00                	push   $0x0
80106468:	e8 67 fe ff ff       	call   801062d4 <argfd>
8010646d:	83 c4 10             	add    $0x10,%esp
80106470:	85 c0                	test   %eax,%eax
80106472:	78 2e                	js     801064a2 <sys_write+0x4b>
80106474:	83 ec 08             	sub    $0x8,%esp
80106477:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010647a:	50                   	push   %eax
8010647b:	6a 02                	push   $0x2
8010647d:	e8 16 fd ff ff       	call   80106198 <argint>
80106482:	83 c4 10             	add    $0x10,%esp
80106485:	85 c0                	test   %eax,%eax
80106487:	78 19                	js     801064a2 <sys_write+0x4b>
80106489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648c:	83 ec 04             	sub    $0x4,%esp
8010648f:	50                   	push   %eax
80106490:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106493:	50                   	push   %eax
80106494:	6a 01                	push   $0x1
80106496:	e8 25 fd ff ff       	call   801061c0 <argptr>
8010649b:	83 c4 10             	add    $0x10,%esp
8010649e:	85 c0                	test   %eax,%eax
801064a0:	79 07                	jns    801064a9 <sys_write+0x52>
    return -1;
801064a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a7:	eb 17                	jmp    801064c0 <sys_write+0x69>
  return filewrite(f, p, n);
801064a9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801064ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
801064af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b2:	83 ec 04             	sub    $0x4,%esp
801064b5:	51                   	push   %ecx
801064b6:	52                   	push   %edx
801064b7:	50                   	push   %eax
801064b8:	e8 78 ad ff ff       	call   80101235 <filewrite>
801064bd:	83 c4 10             	add    $0x10,%esp
}
801064c0:	c9                   	leave  
801064c1:	c3                   	ret    

801064c2 <sys_close>:

int
sys_close(void)
{
801064c2:	55                   	push   %ebp
801064c3:	89 e5                	mov    %esp,%ebp
801064c5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801064c8:	83 ec 04             	sub    $0x4,%esp
801064cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ce:	50                   	push   %eax
801064cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064d2:	50                   	push   %eax
801064d3:	6a 00                	push   $0x0
801064d5:	e8 fa fd ff ff       	call   801062d4 <argfd>
801064da:	83 c4 10             	add    $0x10,%esp
801064dd:	85 c0                	test   %eax,%eax
801064df:	79 07                	jns    801064e8 <sys_close+0x26>
    return -1;
801064e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e6:	eb 28                	jmp    80106510 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801064e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064f1:	83 c2 08             	add    $0x8,%edx
801064f4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064fb:	00 
  fileclose(f);
801064fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ff:	83 ec 0c             	sub    $0xc,%esp
80106502:	50                   	push   %eax
80106503:	e8 36 ab ff ff       	call   8010103e <fileclose>
80106508:	83 c4 10             	add    $0x10,%esp
  return 0;
8010650b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106510:	c9                   	leave  
80106511:	c3                   	ret    

80106512 <sys_fstat>:

int
sys_fstat(void)
{
80106512:	55                   	push   %ebp
80106513:	89 e5                	mov    %esp,%ebp
80106515:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106518:	83 ec 04             	sub    $0x4,%esp
8010651b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010651e:	50                   	push   %eax
8010651f:	6a 00                	push   $0x0
80106521:	6a 00                	push   $0x0
80106523:	e8 ac fd ff ff       	call   801062d4 <argfd>
80106528:	83 c4 10             	add    $0x10,%esp
8010652b:	85 c0                	test   %eax,%eax
8010652d:	78 17                	js     80106546 <sys_fstat+0x34>
8010652f:	83 ec 04             	sub    $0x4,%esp
80106532:	6a 14                	push   $0x14
80106534:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106537:	50                   	push   %eax
80106538:	6a 01                	push   $0x1
8010653a:	e8 81 fc ff ff       	call   801061c0 <argptr>
8010653f:	83 c4 10             	add    $0x10,%esp
80106542:	85 c0                	test   %eax,%eax
80106544:	79 07                	jns    8010654d <sys_fstat+0x3b>
    return -1;
80106546:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654b:	eb 13                	jmp    80106560 <sys_fstat+0x4e>
  return filestat(f, st);
8010654d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106553:	83 ec 08             	sub    $0x8,%esp
80106556:	52                   	push   %edx
80106557:	50                   	push   %eax
80106558:	e8 c9 ab ff ff       	call   80101126 <filestat>
8010655d:	83 c4 10             	add    $0x10,%esp
}
80106560:	c9                   	leave  
80106561:	c3                   	ret    

80106562 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106562:	55                   	push   %ebp
80106563:	89 e5                	mov    %esp,%ebp
80106565:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106568:	83 ec 08             	sub    $0x8,%esp
8010656b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010656e:	50                   	push   %eax
8010656f:	6a 00                	push   $0x0
80106571:	e8 a7 fc ff ff       	call   8010621d <argstr>
80106576:	83 c4 10             	add    $0x10,%esp
80106579:	85 c0                	test   %eax,%eax
8010657b:	78 15                	js     80106592 <sys_link+0x30>
8010657d:	83 ec 08             	sub    $0x8,%esp
80106580:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106583:	50                   	push   %eax
80106584:	6a 01                	push   $0x1
80106586:	e8 92 fc ff ff       	call   8010621d <argstr>
8010658b:	83 c4 10             	add    $0x10,%esp
8010658e:	85 c0                	test   %eax,%eax
80106590:	79 0a                	jns    8010659c <sys_link+0x3a>
    return -1;
80106592:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106597:	e9 68 01 00 00       	jmp    80106704 <sys_link+0x1a2>

  begin_op();
8010659c:	e8 76 cf ff ff       	call   80103517 <begin_op>
  if((ip = namei(old)) == 0){
801065a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801065a4:	83 ec 0c             	sub    $0xc,%esp
801065a7:	50                   	push   %eax
801065a8:	e8 79 bf ff ff       	call   80102526 <namei>
801065ad:	83 c4 10             	add    $0x10,%esp
801065b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065b7:	75 0f                	jne    801065c8 <sys_link+0x66>
    end_op();
801065b9:	e8 e5 cf ff ff       	call   801035a3 <end_op>
    return -1;
801065be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c3:	e9 3c 01 00 00       	jmp    80106704 <sys_link+0x1a2>
  }

  ilock(ip);
801065c8:	83 ec 0c             	sub    $0xc,%esp
801065cb:	ff 75 f4             	pushl  -0xc(%ebp)
801065ce:	e8 9b b3 ff ff       	call   8010196e <ilock>
801065d3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801065d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065dd:	66 83 f8 01          	cmp    $0x1,%ax
801065e1:	75 1d                	jne    80106600 <sys_link+0x9e>
    iunlockput(ip);
801065e3:	83 ec 0c             	sub    $0xc,%esp
801065e6:	ff 75 f4             	pushl  -0xc(%ebp)
801065e9:	e8 3a b6 ff ff       	call   80101c28 <iunlockput>
801065ee:	83 c4 10             	add    $0x10,%esp
    end_op();
801065f1:	e8 ad cf ff ff       	call   801035a3 <end_op>
    return -1;
801065f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fb:	e9 04 01 00 00       	jmp    80106704 <sys_link+0x1a2>
  }

  ip->nlink++;
80106600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106603:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106607:	83 c0 01             	add    $0x1,%eax
8010660a:	89 c2                	mov    %eax,%edx
8010660c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106613:	83 ec 0c             	sub    $0xc,%esp
80106616:	ff 75 f4             	pushl  -0xc(%ebp)
80106619:	e8 7c b1 ff ff       	call   8010179a <iupdate>
8010661e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106621:	83 ec 0c             	sub    $0xc,%esp
80106624:	ff 75 f4             	pushl  -0xc(%ebp)
80106627:	e8 9a b4 ff ff       	call   80101ac6 <iunlock>
8010662c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010662f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106632:	83 ec 08             	sub    $0x8,%esp
80106635:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106638:	52                   	push   %edx
80106639:	50                   	push   %eax
8010663a:	e8 03 bf ff ff       	call   80102542 <nameiparent>
8010663f:	83 c4 10             	add    $0x10,%esp
80106642:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106645:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106649:	74 71                	je     801066bc <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010664b:	83 ec 0c             	sub    $0xc,%esp
8010664e:	ff 75 f0             	pushl  -0x10(%ebp)
80106651:	e8 18 b3 ff ff       	call   8010196e <ilock>
80106656:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010665c:	8b 10                	mov    (%eax),%edx
8010665e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106661:	8b 00                	mov    (%eax),%eax
80106663:	39 c2                	cmp    %eax,%edx
80106665:	75 1d                	jne    80106684 <sys_link+0x122>
80106667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666a:	8b 40 04             	mov    0x4(%eax),%eax
8010666d:	83 ec 04             	sub    $0x4,%esp
80106670:	50                   	push   %eax
80106671:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106674:	50                   	push   %eax
80106675:	ff 75 f0             	pushl  -0x10(%ebp)
80106678:	e8 0d bc ff ff       	call   8010228a <dirlink>
8010667d:	83 c4 10             	add    $0x10,%esp
80106680:	85 c0                	test   %eax,%eax
80106682:	79 10                	jns    80106694 <sys_link+0x132>
    iunlockput(dp);
80106684:	83 ec 0c             	sub    $0xc,%esp
80106687:	ff 75 f0             	pushl  -0x10(%ebp)
8010668a:	e8 99 b5 ff ff       	call   80101c28 <iunlockput>
8010668f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106692:	eb 29                	jmp    801066bd <sys_link+0x15b>
  }
  iunlockput(dp);
80106694:	83 ec 0c             	sub    $0xc,%esp
80106697:	ff 75 f0             	pushl  -0x10(%ebp)
8010669a:	e8 89 b5 ff ff       	call   80101c28 <iunlockput>
8010669f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801066a2:	83 ec 0c             	sub    $0xc,%esp
801066a5:	ff 75 f4             	pushl  -0xc(%ebp)
801066a8:	e8 8b b4 ff ff       	call   80101b38 <iput>
801066ad:	83 c4 10             	add    $0x10,%esp

  end_op();
801066b0:	e8 ee ce ff ff       	call   801035a3 <end_op>

  return 0;
801066b5:	b8 00 00 00 00       	mov    $0x0,%eax
801066ba:	eb 48                	jmp    80106704 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801066bc:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801066bd:	83 ec 0c             	sub    $0xc,%esp
801066c0:	ff 75 f4             	pushl  -0xc(%ebp)
801066c3:	e8 a6 b2 ff ff       	call   8010196e <ilock>
801066c8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801066cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ce:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066d2:	83 e8 01             	sub    $0x1,%eax
801066d5:	89 c2                	mov    %eax,%edx
801066d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066da:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801066de:	83 ec 0c             	sub    $0xc,%esp
801066e1:	ff 75 f4             	pushl  -0xc(%ebp)
801066e4:	e8 b1 b0 ff ff       	call   8010179a <iupdate>
801066e9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801066ec:	83 ec 0c             	sub    $0xc,%esp
801066ef:	ff 75 f4             	pushl  -0xc(%ebp)
801066f2:	e8 31 b5 ff ff       	call   80101c28 <iunlockput>
801066f7:	83 c4 10             	add    $0x10,%esp
  end_op();
801066fa:	e8 a4 ce ff ff       	call   801035a3 <end_op>
  return -1;
801066ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106704:	c9                   	leave  
80106705:	c3                   	ret    

80106706 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106706:	55                   	push   %ebp
80106707:	89 e5                	mov    %esp,%ebp
80106709:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010670c:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106713:	eb 40                	jmp    80106755 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106718:	6a 10                	push   $0x10
8010671a:	50                   	push   %eax
8010671b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010671e:	50                   	push   %eax
8010671f:	ff 75 08             	pushl  0x8(%ebp)
80106722:	e8 af b7 ff ff       	call   80101ed6 <readi>
80106727:	83 c4 10             	add    $0x10,%esp
8010672a:	83 f8 10             	cmp    $0x10,%eax
8010672d:	74 0d                	je     8010673c <isdirempty+0x36>
      panic("isdirempty: readi");
8010672f:	83 ec 0c             	sub    $0xc,%esp
80106732:	68 54 9b 10 80       	push   $0x80109b54
80106737:	e8 2a 9e ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010673c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106740:	66 85 c0             	test   %ax,%ax
80106743:	74 07                	je     8010674c <isdirempty+0x46>
      return 0;
80106745:	b8 00 00 00 00       	mov    $0x0,%eax
8010674a:	eb 1b                	jmp    80106767 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010674c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674f:	83 c0 10             	add    $0x10,%eax
80106752:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106755:	8b 45 08             	mov    0x8(%ebp),%eax
80106758:	8b 50 18             	mov    0x18(%eax),%edx
8010675b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675e:	39 c2                	cmp    %eax,%edx
80106760:	77 b3                	ja     80106715 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106762:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106767:	c9                   	leave  
80106768:	c3                   	ret    

80106769 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106769:	55                   	push   %ebp
8010676a:	89 e5                	mov    %esp,%ebp
8010676c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010676f:	83 ec 08             	sub    $0x8,%esp
80106772:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106775:	50                   	push   %eax
80106776:	6a 00                	push   $0x0
80106778:	e8 a0 fa ff ff       	call   8010621d <argstr>
8010677d:	83 c4 10             	add    $0x10,%esp
80106780:	85 c0                	test   %eax,%eax
80106782:	79 0a                	jns    8010678e <sys_unlink+0x25>
    return -1;
80106784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106789:	e9 bc 01 00 00       	jmp    8010694a <sys_unlink+0x1e1>

  begin_op();
8010678e:	e8 84 cd ff ff       	call   80103517 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106793:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106796:	83 ec 08             	sub    $0x8,%esp
80106799:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010679c:	52                   	push   %edx
8010679d:	50                   	push   %eax
8010679e:	e8 9f bd ff ff       	call   80102542 <nameiparent>
801067a3:	83 c4 10             	add    $0x10,%esp
801067a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ad:	75 0f                	jne    801067be <sys_unlink+0x55>
    end_op();
801067af:	e8 ef cd ff ff       	call   801035a3 <end_op>
    return -1;
801067b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b9:	e9 8c 01 00 00       	jmp    8010694a <sys_unlink+0x1e1>
  }

  ilock(dp);
801067be:	83 ec 0c             	sub    $0xc,%esp
801067c1:	ff 75 f4             	pushl  -0xc(%ebp)
801067c4:	e8 a5 b1 ff ff       	call   8010196e <ilock>
801067c9:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067cc:	83 ec 08             	sub    $0x8,%esp
801067cf:	68 66 9b 10 80       	push   $0x80109b66
801067d4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067d7:	50                   	push   %eax
801067d8:	e8 d8 b9 ff ff       	call   801021b5 <namecmp>
801067dd:	83 c4 10             	add    $0x10,%esp
801067e0:	85 c0                	test   %eax,%eax
801067e2:	0f 84 4a 01 00 00    	je     80106932 <sys_unlink+0x1c9>
801067e8:	83 ec 08             	sub    $0x8,%esp
801067eb:	68 68 9b 10 80       	push   $0x80109b68
801067f0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067f3:	50                   	push   %eax
801067f4:	e8 bc b9 ff ff       	call   801021b5 <namecmp>
801067f9:	83 c4 10             	add    $0x10,%esp
801067fc:	85 c0                	test   %eax,%eax
801067fe:	0f 84 2e 01 00 00    	je     80106932 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106804:	83 ec 04             	sub    $0x4,%esp
80106807:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010680a:	50                   	push   %eax
8010680b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010680e:	50                   	push   %eax
8010680f:	ff 75 f4             	pushl  -0xc(%ebp)
80106812:	e8 b9 b9 ff ff       	call   801021d0 <dirlookup>
80106817:	83 c4 10             	add    $0x10,%esp
8010681a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010681d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106821:	0f 84 0a 01 00 00    	je     80106931 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106827:	83 ec 0c             	sub    $0xc,%esp
8010682a:	ff 75 f0             	pushl  -0x10(%ebp)
8010682d:	e8 3c b1 ff ff       	call   8010196e <ilock>
80106832:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106838:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010683c:	66 85 c0             	test   %ax,%ax
8010683f:	7f 0d                	jg     8010684e <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106841:	83 ec 0c             	sub    $0xc,%esp
80106844:	68 6b 9b 10 80       	push   $0x80109b6b
80106849:	e8 18 9d ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010684e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106851:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106855:	66 83 f8 01          	cmp    $0x1,%ax
80106859:	75 25                	jne    80106880 <sys_unlink+0x117>
8010685b:	83 ec 0c             	sub    $0xc,%esp
8010685e:	ff 75 f0             	pushl  -0x10(%ebp)
80106861:	e8 a0 fe ff ff       	call   80106706 <isdirempty>
80106866:	83 c4 10             	add    $0x10,%esp
80106869:	85 c0                	test   %eax,%eax
8010686b:	75 13                	jne    80106880 <sys_unlink+0x117>
    iunlockput(ip);
8010686d:	83 ec 0c             	sub    $0xc,%esp
80106870:	ff 75 f0             	pushl  -0x10(%ebp)
80106873:	e8 b0 b3 ff ff       	call   80101c28 <iunlockput>
80106878:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010687b:	e9 b2 00 00 00       	jmp    80106932 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106880:	83 ec 04             	sub    $0x4,%esp
80106883:	6a 10                	push   $0x10
80106885:	6a 00                	push   $0x0
80106887:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010688a:	50                   	push   %eax
8010688b:	e8 e3 f5 ff ff       	call   80105e73 <memset>
80106890:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106893:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106896:	6a 10                	push   $0x10
80106898:	50                   	push   %eax
80106899:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010689c:	50                   	push   %eax
8010689d:	ff 75 f4             	pushl  -0xc(%ebp)
801068a0:	e8 88 b7 ff ff       	call   8010202d <writei>
801068a5:	83 c4 10             	add    $0x10,%esp
801068a8:	83 f8 10             	cmp    $0x10,%eax
801068ab:	74 0d                	je     801068ba <sys_unlink+0x151>
    panic("unlink: writei");
801068ad:	83 ec 0c             	sub    $0xc,%esp
801068b0:	68 7d 9b 10 80       	push   $0x80109b7d
801068b5:	e8 ac 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801068ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068bd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068c1:	66 83 f8 01          	cmp    $0x1,%ax
801068c5:	75 21                	jne    801068e8 <sys_unlink+0x17f>
    dp->nlink--;
801068c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ca:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068ce:	83 e8 01             	sub    $0x1,%eax
801068d1:	89 c2                	mov    %eax,%edx
801068d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801068da:	83 ec 0c             	sub    $0xc,%esp
801068dd:	ff 75 f4             	pushl  -0xc(%ebp)
801068e0:	e8 b5 ae ff ff       	call   8010179a <iupdate>
801068e5:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801068e8:	83 ec 0c             	sub    $0xc,%esp
801068eb:	ff 75 f4             	pushl  -0xc(%ebp)
801068ee:	e8 35 b3 ff ff       	call   80101c28 <iunlockput>
801068f3:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801068f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068fd:	83 e8 01             	sub    $0x1,%eax
80106900:	89 c2                	mov    %eax,%edx
80106902:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106905:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106909:	83 ec 0c             	sub    $0xc,%esp
8010690c:	ff 75 f0             	pushl  -0x10(%ebp)
8010690f:	e8 86 ae ff ff       	call   8010179a <iupdate>
80106914:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106917:	83 ec 0c             	sub    $0xc,%esp
8010691a:	ff 75 f0             	pushl  -0x10(%ebp)
8010691d:	e8 06 b3 ff ff       	call   80101c28 <iunlockput>
80106922:	83 c4 10             	add    $0x10,%esp

  end_op();
80106925:	e8 79 cc ff ff       	call   801035a3 <end_op>

  return 0;
8010692a:	b8 00 00 00 00       	mov    $0x0,%eax
8010692f:	eb 19                	jmp    8010694a <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106931:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106932:	83 ec 0c             	sub    $0xc,%esp
80106935:	ff 75 f4             	pushl  -0xc(%ebp)
80106938:	e8 eb b2 ff ff       	call   80101c28 <iunlockput>
8010693d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106940:	e8 5e cc ff ff       	call   801035a3 <end_op>
  return -1;
80106945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010694a:	c9                   	leave  
8010694b:	c3                   	ret    

8010694c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010694c:	55                   	push   %ebp
8010694d:	89 e5                	mov    %esp,%ebp
8010694f:	83 ec 38             	sub    $0x38,%esp
80106952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106955:	8b 55 10             	mov    0x10(%ebp),%edx
80106958:	8b 45 14             	mov    0x14(%ebp),%eax
8010695b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010695f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106963:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106967:	83 ec 08             	sub    $0x8,%esp
8010696a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010696d:	50                   	push   %eax
8010696e:	ff 75 08             	pushl  0x8(%ebp)
80106971:	e8 cc bb ff ff       	call   80102542 <nameiparent>
80106976:	83 c4 10             	add    $0x10,%esp
80106979:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010697c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106980:	75 0a                	jne    8010698c <create+0x40>
    return 0;
80106982:	b8 00 00 00 00       	mov    $0x0,%eax
80106987:	e9 90 01 00 00       	jmp    80106b1c <create+0x1d0>
  ilock(dp);
8010698c:	83 ec 0c             	sub    $0xc,%esp
8010698f:	ff 75 f4             	pushl  -0xc(%ebp)
80106992:	e8 d7 af ff ff       	call   8010196e <ilock>
80106997:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010699a:	83 ec 04             	sub    $0x4,%esp
8010699d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069a0:	50                   	push   %eax
801069a1:	8d 45 de             	lea    -0x22(%ebp),%eax
801069a4:	50                   	push   %eax
801069a5:	ff 75 f4             	pushl  -0xc(%ebp)
801069a8:	e8 23 b8 ff ff       	call   801021d0 <dirlookup>
801069ad:	83 c4 10             	add    $0x10,%esp
801069b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069b7:	74 50                	je     80106a09 <create+0xbd>
    iunlockput(dp);
801069b9:	83 ec 0c             	sub    $0xc,%esp
801069bc:	ff 75 f4             	pushl  -0xc(%ebp)
801069bf:	e8 64 b2 ff ff       	call   80101c28 <iunlockput>
801069c4:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801069c7:	83 ec 0c             	sub    $0xc,%esp
801069ca:	ff 75 f0             	pushl  -0x10(%ebp)
801069cd:	e8 9c af ff ff       	call   8010196e <ilock>
801069d2:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801069d5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801069da:	75 15                	jne    801069f1 <create+0xa5>
801069dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069df:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801069e3:	66 83 f8 02          	cmp    $0x2,%ax
801069e7:	75 08                	jne    801069f1 <create+0xa5>
      return ip;
801069e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ec:	e9 2b 01 00 00       	jmp    80106b1c <create+0x1d0>
    iunlockput(ip);
801069f1:	83 ec 0c             	sub    $0xc,%esp
801069f4:	ff 75 f0             	pushl  -0x10(%ebp)
801069f7:	e8 2c b2 ff ff       	call   80101c28 <iunlockput>
801069fc:	83 c4 10             	add    $0x10,%esp
    return 0;
801069ff:	b8 00 00 00 00       	mov    $0x0,%eax
80106a04:	e9 13 01 00 00       	jmp    80106b1c <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106a09:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a10:	8b 00                	mov    (%eax),%eax
80106a12:	83 ec 08             	sub    $0x8,%esp
80106a15:	52                   	push   %edx
80106a16:	50                   	push   %eax
80106a17:	e8 9d ac ff ff       	call   801016b9 <ialloc>
80106a1c:	83 c4 10             	add    $0x10,%esp
80106a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a26:	75 0d                	jne    80106a35 <create+0xe9>
    panic("create: ialloc");
80106a28:	83 ec 0c             	sub    $0xc,%esp
80106a2b:	68 8c 9b 10 80       	push   $0x80109b8c
80106a30:	e8 31 9b ff ff       	call   80100566 <panic>

  ilock(ip);
80106a35:	83 ec 0c             	sub    $0xc,%esp
80106a38:	ff 75 f0             	pushl  -0x10(%ebp)
80106a3b:	e8 2e af ff ff       	call   8010196e <ilock>
80106a40:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a46:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a4a:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a51:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a55:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a5c:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106a62:	83 ec 0c             	sub    $0xc,%esp
80106a65:	ff 75 f0             	pushl  -0x10(%ebp)
80106a68:	e8 2d ad ff ff       	call   8010179a <iupdate>
80106a6d:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106a70:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106a75:	75 6a                	jne    80106ae1 <create+0x195>
    dp->nlink++;  // for ".."
80106a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106a7e:	83 c0 01             	add    $0x1,%eax
80106a81:	89 c2                	mov    %eax,%edx
80106a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a86:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106a8a:	83 ec 0c             	sub    $0xc,%esp
80106a8d:	ff 75 f4             	pushl  -0xc(%ebp)
80106a90:	e8 05 ad ff ff       	call   8010179a <iupdate>
80106a95:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a9b:	8b 40 04             	mov    0x4(%eax),%eax
80106a9e:	83 ec 04             	sub    $0x4,%esp
80106aa1:	50                   	push   %eax
80106aa2:	68 66 9b 10 80       	push   $0x80109b66
80106aa7:	ff 75 f0             	pushl  -0x10(%ebp)
80106aaa:	e8 db b7 ff ff       	call   8010228a <dirlink>
80106aaf:	83 c4 10             	add    $0x10,%esp
80106ab2:	85 c0                	test   %eax,%eax
80106ab4:	78 1e                	js     80106ad4 <create+0x188>
80106ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab9:	8b 40 04             	mov    0x4(%eax),%eax
80106abc:	83 ec 04             	sub    $0x4,%esp
80106abf:	50                   	push   %eax
80106ac0:	68 68 9b 10 80       	push   $0x80109b68
80106ac5:	ff 75 f0             	pushl  -0x10(%ebp)
80106ac8:	e8 bd b7 ff ff       	call   8010228a <dirlink>
80106acd:	83 c4 10             	add    $0x10,%esp
80106ad0:	85 c0                	test   %eax,%eax
80106ad2:	79 0d                	jns    80106ae1 <create+0x195>
      panic("create dots");
80106ad4:	83 ec 0c             	sub    $0xc,%esp
80106ad7:	68 9b 9b 10 80       	push   $0x80109b9b
80106adc:	e8 85 9a ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ae4:	8b 40 04             	mov    0x4(%eax),%eax
80106ae7:	83 ec 04             	sub    $0x4,%esp
80106aea:	50                   	push   %eax
80106aeb:	8d 45 de             	lea    -0x22(%ebp),%eax
80106aee:	50                   	push   %eax
80106aef:	ff 75 f4             	pushl  -0xc(%ebp)
80106af2:	e8 93 b7 ff ff       	call   8010228a <dirlink>
80106af7:	83 c4 10             	add    $0x10,%esp
80106afa:	85 c0                	test   %eax,%eax
80106afc:	79 0d                	jns    80106b0b <create+0x1bf>
    panic("create: dirlink");
80106afe:	83 ec 0c             	sub    $0xc,%esp
80106b01:	68 a7 9b 10 80       	push   $0x80109ba7
80106b06:	e8 5b 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106b0b:	83 ec 0c             	sub    $0xc,%esp
80106b0e:	ff 75 f4             	pushl  -0xc(%ebp)
80106b11:	e8 12 b1 ff ff       	call   80101c28 <iunlockput>
80106b16:	83 c4 10             	add    $0x10,%esp

  return ip;
80106b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b1c:	c9                   	leave  
80106b1d:	c3                   	ret    

80106b1e <sys_open>:

int
sys_open(void)
{
80106b1e:	55                   	push   %ebp
80106b1f:	89 e5                	mov    %esp,%ebp
80106b21:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b24:	83 ec 08             	sub    $0x8,%esp
80106b27:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b2a:	50                   	push   %eax
80106b2b:	6a 00                	push   $0x0
80106b2d:	e8 eb f6 ff ff       	call   8010621d <argstr>
80106b32:	83 c4 10             	add    $0x10,%esp
80106b35:	85 c0                	test   %eax,%eax
80106b37:	78 15                	js     80106b4e <sys_open+0x30>
80106b39:	83 ec 08             	sub    $0x8,%esp
80106b3c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b3f:	50                   	push   %eax
80106b40:	6a 01                	push   $0x1
80106b42:	e8 51 f6 ff ff       	call   80106198 <argint>
80106b47:	83 c4 10             	add    $0x10,%esp
80106b4a:	85 c0                	test   %eax,%eax
80106b4c:	79 0a                	jns    80106b58 <sys_open+0x3a>
    return -1;
80106b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b53:	e9 61 01 00 00       	jmp    80106cb9 <sys_open+0x19b>

  begin_op();
80106b58:	e8 ba c9 ff ff       	call   80103517 <begin_op>

  if(omode & O_CREATE){
80106b5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b60:	25 00 02 00 00       	and    $0x200,%eax
80106b65:	85 c0                	test   %eax,%eax
80106b67:	74 2a                	je     80106b93 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106b69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b6c:	6a 00                	push   $0x0
80106b6e:	6a 00                	push   $0x0
80106b70:	6a 02                	push   $0x2
80106b72:	50                   	push   %eax
80106b73:	e8 d4 fd ff ff       	call   8010694c <create>
80106b78:	83 c4 10             	add    $0x10,%esp
80106b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106b7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b82:	75 75                	jne    80106bf9 <sys_open+0xdb>
      end_op();
80106b84:	e8 1a ca ff ff       	call   801035a3 <end_op>
      return -1;
80106b89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8e:	e9 26 01 00 00       	jmp    80106cb9 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106b93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b96:	83 ec 0c             	sub    $0xc,%esp
80106b99:	50                   	push   %eax
80106b9a:	e8 87 b9 ff ff       	call   80102526 <namei>
80106b9f:	83 c4 10             	add    $0x10,%esp
80106ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ba5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ba9:	75 0f                	jne    80106bba <sys_open+0x9c>
      end_op();
80106bab:	e8 f3 c9 ff ff       	call   801035a3 <end_op>
      return -1;
80106bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bb5:	e9 ff 00 00 00       	jmp    80106cb9 <sys_open+0x19b>
    }
    ilock(ip);
80106bba:	83 ec 0c             	sub    $0xc,%esp
80106bbd:	ff 75 f4             	pushl  -0xc(%ebp)
80106bc0:	e8 a9 ad ff ff       	call   8010196e <ilock>
80106bc5:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bcb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106bcf:	66 83 f8 01          	cmp    $0x1,%ax
80106bd3:	75 24                	jne    80106bf9 <sys_open+0xdb>
80106bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bd8:	85 c0                	test   %eax,%eax
80106bda:	74 1d                	je     80106bf9 <sys_open+0xdb>
      iunlockput(ip);
80106bdc:	83 ec 0c             	sub    $0xc,%esp
80106bdf:	ff 75 f4             	pushl  -0xc(%ebp)
80106be2:	e8 41 b0 ff ff       	call   80101c28 <iunlockput>
80106be7:	83 c4 10             	add    $0x10,%esp
      end_op();
80106bea:	e8 b4 c9 ff ff       	call   801035a3 <end_op>
      return -1;
80106bef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf4:	e9 c0 00 00 00       	jmp    80106cb9 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106bf9:	e8 82 a3 ff ff       	call   80100f80 <filealloc>
80106bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c05:	74 17                	je     80106c1e <sys_open+0x100>
80106c07:	83 ec 0c             	sub    $0xc,%esp
80106c0a:	ff 75 f0             	pushl  -0x10(%ebp)
80106c0d:	e8 37 f7 ff ff       	call   80106349 <fdalloc>
80106c12:	83 c4 10             	add    $0x10,%esp
80106c15:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106c18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106c1c:	79 2e                	jns    80106c4c <sys_open+0x12e>
    if(f)
80106c1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c22:	74 0e                	je     80106c32 <sys_open+0x114>
      fileclose(f);
80106c24:	83 ec 0c             	sub    $0xc,%esp
80106c27:	ff 75 f0             	pushl  -0x10(%ebp)
80106c2a:	e8 0f a4 ff ff       	call   8010103e <fileclose>
80106c2f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106c32:	83 ec 0c             	sub    $0xc,%esp
80106c35:	ff 75 f4             	pushl  -0xc(%ebp)
80106c38:	e8 eb af ff ff       	call   80101c28 <iunlockput>
80106c3d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106c40:	e8 5e c9 ff ff       	call   801035a3 <end_op>
    return -1;
80106c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c4a:	eb 6d                	jmp    80106cb9 <sys_open+0x19b>
  }
  iunlock(ip);
80106c4c:	83 ec 0c             	sub    $0xc,%esp
80106c4f:	ff 75 f4             	pushl  -0xc(%ebp)
80106c52:	e8 6f ae ff ff       	call   80101ac6 <iunlock>
80106c57:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c5a:	e8 44 c9 ff ff       	call   801035a3 <end_op>

  f->type = FD_INODE;
80106c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c62:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c6e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c74:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c7e:	83 e0 01             	and    $0x1,%eax
80106c81:	85 c0                	test   %eax,%eax
80106c83:	0f 94 c0             	sete   %al
80106c86:	89 c2                	mov    %eax,%edx
80106c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c8b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106c8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c91:	83 e0 01             	and    $0x1,%eax
80106c94:	85 c0                	test   %eax,%eax
80106c96:	75 0a                	jne    80106ca2 <sys_open+0x184>
80106c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c9b:	83 e0 02             	and    $0x2,%eax
80106c9e:	85 c0                	test   %eax,%eax
80106ca0:	74 07                	je     80106ca9 <sys_open+0x18b>
80106ca2:	b8 01 00 00 00       	mov    $0x1,%eax
80106ca7:	eb 05                	jmp    80106cae <sys_open+0x190>
80106ca9:	b8 00 00 00 00       	mov    $0x0,%eax
80106cae:	89 c2                	mov    %eax,%edx
80106cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cb3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106cb9:	c9                   	leave  
80106cba:	c3                   	ret    

80106cbb <sys_mkdir>:

int
sys_mkdir(void)
{
80106cbb:	55                   	push   %ebp
80106cbc:	89 e5                	mov    %esp,%ebp
80106cbe:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106cc1:	e8 51 c8 ff ff       	call   80103517 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106cc6:	83 ec 08             	sub    $0x8,%esp
80106cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ccc:	50                   	push   %eax
80106ccd:	6a 00                	push   $0x0
80106ccf:	e8 49 f5 ff ff       	call   8010621d <argstr>
80106cd4:	83 c4 10             	add    $0x10,%esp
80106cd7:	85 c0                	test   %eax,%eax
80106cd9:	78 1b                	js     80106cf6 <sys_mkdir+0x3b>
80106cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cde:	6a 00                	push   $0x0
80106ce0:	6a 00                	push   $0x0
80106ce2:	6a 01                	push   $0x1
80106ce4:	50                   	push   %eax
80106ce5:	e8 62 fc ff ff       	call   8010694c <create>
80106cea:	83 c4 10             	add    $0x10,%esp
80106ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106cf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106cf4:	75 0c                	jne    80106d02 <sys_mkdir+0x47>
    end_op();
80106cf6:	e8 a8 c8 ff ff       	call   801035a3 <end_op>
    return -1;
80106cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d00:	eb 18                	jmp    80106d1a <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106d02:	83 ec 0c             	sub    $0xc,%esp
80106d05:	ff 75 f4             	pushl  -0xc(%ebp)
80106d08:	e8 1b af ff ff       	call   80101c28 <iunlockput>
80106d0d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d10:	e8 8e c8 ff ff       	call   801035a3 <end_op>
  return 0;
80106d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d1a:	c9                   	leave  
80106d1b:	c3                   	ret    

80106d1c <sys_mknod>:

int
sys_mknod(void)
{
80106d1c:	55                   	push   %ebp
80106d1d:	89 e5                	mov    %esp,%ebp
80106d1f:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;

  begin_op();
80106d22:	e8 f0 c7 ff ff       	call   80103517 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106d27:	83 ec 08             	sub    $0x8,%esp
80106d2a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106d2d:	50                   	push   %eax
80106d2e:	6a 00                	push   $0x0
80106d30:	e8 e8 f4 ff ff       	call   8010621d <argstr>
80106d35:	83 c4 10             	add    $0x10,%esp
80106d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d3f:	78 4f                	js     80106d90 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106d41:	83 ec 08             	sub    $0x8,%esp
80106d44:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d47:	50                   	push   %eax
80106d48:	6a 01                	push   $0x1
80106d4a:	e8 49 f4 ff ff       	call   80106198 <argint>
80106d4f:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106d52:	85 c0                	test   %eax,%eax
80106d54:	78 3a                	js     80106d90 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d56:	83 ec 08             	sub    $0x8,%esp
80106d59:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d5c:	50                   	push   %eax
80106d5d:	6a 02                	push   $0x2
80106d5f:	e8 34 f4 ff ff       	call   80106198 <argint>
80106d64:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106d67:	85 c0                	test   %eax,%eax
80106d69:	78 25                	js     80106d90 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d6e:	0f bf c8             	movswl %ax,%ecx
80106d71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d74:	0f bf d0             	movswl %ax,%edx
80106d77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d7a:	51                   	push   %ecx
80106d7b:	52                   	push   %edx
80106d7c:	6a 03                	push   $0x3
80106d7e:	50                   	push   %eax
80106d7f:	e8 c8 fb ff ff       	call   8010694c <create>
80106d84:	83 c4 10             	add    $0x10,%esp
80106d87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d8e:	75 0c                	jne    80106d9c <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106d90:	e8 0e c8 ff ff       	call   801035a3 <end_op>
    return -1;
80106d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d9a:	eb 18                	jmp    80106db4 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106d9c:	83 ec 0c             	sub    $0xc,%esp
80106d9f:	ff 75 f0             	pushl  -0x10(%ebp)
80106da2:	e8 81 ae ff ff       	call   80101c28 <iunlockput>
80106da7:	83 c4 10             	add    $0x10,%esp
  end_op();
80106daa:	e8 f4 c7 ff ff       	call   801035a3 <end_op>
  return 0;
80106daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106db4:	c9                   	leave  
80106db5:	c3                   	ret    

80106db6 <sys_chdir>:

int
sys_chdir(void)
{
80106db6:	55                   	push   %ebp
80106db7:	89 e5                	mov    %esp,%ebp
80106db9:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106dbc:	e8 56 c7 ff ff       	call   80103517 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106dc1:	83 ec 08             	sub    $0x8,%esp
80106dc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dc7:	50                   	push   %eax
80106dc8:	6a 00                	push   $0x0
80106dca:	e8 4e f4 ff ff       	call   8010621d <argstr>
80106dcf:	83 c4 10             	add    $0x10,%esp
80106dd2:	85 c0                	test   %eax,%eax
80106dd4:	78 18                	js     80106dee <sys_chdir+0x38>
80106dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dd9:	83 ec 0c             	sub    $0xc,%esp
80106ddc:	50                   	push   %eax
80106ddd:	e8 44 b7 ff ff       	call   80102526 <namei>
80106de2:	83 c4 10             	add    $0x10,%esp
80106de5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106de8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106dec:	75 0c                	jne    80106dfa <sys_chdir+0x44>
    end_op();
80106dee:	e8 b0 c7 ff ff       	call   801035a3 <end_op>
    return -1;
80106df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106df8:	eb 6e                	jmp    80106e68 <sys_chdir+0xb2>
  }
  ilock(ip);
80106dfa:	83 ec 0c             	sub    $0xc,%esp
80106dfd:	ff 75 f4             	pushl  -0xc(%ebp)
80106e00:	e8 69 ab ff ff       	call   8010196e <ilock>
80106e05:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e0b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106e0f:	66 83 f8 01          	cmp    $0x1,%ax
80106e13:	74 1a                	je     80106e2f <sys_chdir+0x79>
    iunlockput(ip);
80106e15:	83 ec 0c             	sub    $0xc,%esp
80106e18:	ff 75 f4             	pushl  -0xc(%ebp)
80106e1b:	e8 08 ae ff ff       	call   80101c28 <iunlockput>
80106e20:	83 c4 10             	add    $0x10,%esp
    end_op();
80106e23:	e8 7b c7 ff ff       	call   801035a3 <end_op>
    return -1;
80106e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e2d:	eb 39                	jmp    80106e68 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106e2f:	83 ec 0c             	sub    $0xc,%esp
80106e32:	ff 75 f4             	pushl  -0xc(%ebp)
80106e35:	e8 8c ac ff ff       	call   80101ac6 <iunlock>
80106e3a:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106e3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e43:	8b 40 68             	mov    0x68(%eax),%eax
80106e46:	83 ec 0c             	sub    $0xc,%esp
80106e49:	50                   	push   %eax
80106e4a:	e8 e9 ac ff ff       	call   80101b38 <iput>
80106e4f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e52:	e8 4c c7 ff ff       	call   801035a3 <end_op>
  proc->cwd = ip;
80106e57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e60:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106e63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e68:	c9                   	leave  
80106e69:	c3                   	ret    

80106e6a <sys_exec>:

int
sys_exec(void)
{
80106e6a:	55                   	push   %ebp
80106e6b:	89 e5                	mov    %esp,%ebp
80106e6d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106e73:	83 ec 08             	sub    $0x8,%esp
80106e76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e79:	50                   	push   %eax
80106e7a:	6a 00                	push   $0x0
80106e7c:	e8 9c f3 ff ff       	call   8010621d <argstr>
80106e81:	83 c4 10             	add    $0x10,%esp
80106e84:	85 c0                	test   %eax,%eax
80106e86:	78 18                	js     80106ea0 <sys_exec+0x36>
80106e88:	83 ec 08             	sub    $0x8,%esp
80106e8b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e91:	50                   	push   %eax
80106e92:	6a 01                	push   $0x1
80106e94:	e8 ff f2 ff ff       	call   80106198 <argint>
80106e99:	83 c4 10             	add    $0x10,%esp
80106e9c:	85 c0                	test   %eax,%eax
80106e9e:	79 0a                	jns    80106eaa <sys_exec+0x40>
    return -1;
80106ea0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea5:	e9 c6 00 00 00       	jmp    80106f70 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106eaa:	83 ec 04             	sub    $0x4,%esp
80106ead:	68 80 00 00 00       	push   $0x80
80106eb2:	6a 00                	push   $0x0
80106eb4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eba:	50                   	push   %eax
80106ebb:	e8 b3 ef ff ff       	call   80105e73 <memset>
80106ec0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106ec3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ecd:	83 f8 1f             	cmp    $0x1f,%eax
80106ed0:	76 0a                	jbe    80106edc <sys_exec+0x72>
      return -1;
80106ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed7:	e9 94 00 00 00       	jmp    80106f70 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edf:	c1 e0 02             	shl    $0x2,%eax
80106ee2:	89 c2                	mov    %eax,%edx
80106ee4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106eea:	01 c2                	add    %eax,%edx
80106eec:	83 ec 08             	sub    $0x8,%esp
80106eef:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106ef5:	50                   	push   %eax
80106ef6:	52                   	push   %edx
80106ef7:	e8 00 f2 ff ff       	call   801060fc <fetchint>
80106efc:	83 c4 10             	add    $0x10,%esp
80106eff:	85 c0                	test   %eax,%eax
80106f01:	79 07                	jns    80106f0a <sys_exec+0xa0>
      return -1;
80106f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f08:	eb 66                	jmp    80106f70 <sys_exec+0x106>
    if(uarg == 0){
80106f0a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f10:	85 c0                	test   %eax,%eax
80106f12:	75 27                	jne    80106f3b <sys_exec+0xd1>
      argv[i] = 0;
80106f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f17:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106f1e:	00 00 00 00 
      break;
80106f22:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f26:	83 ec 08             	sub    $0x8,%esp
80106f29:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f2f:	52                   	push   %edx
80106f30:	50                   	push   %eax
80106f31:	e8 20 9c ff ff       	call   80100b56 <exec>
80106f36:	83 c4 10             	add    $0x10,%esp
80106f39:	eb 35                	jmp    80106f70 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f3b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f44:	c1 e2 02             	shl    $0x2,%edx
80106f47:	01 c2                	add    %eax,%edx
80106f49:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f4f:	83 ec 08             	sub    $0x8,%esp
80106f52:	52                   	push   %edx
80106f53:	50                   	push   %eax
80106f54:	e8 dd f1 ff ff       	call   80106136 <fetchstr>
80106f59:	83 c4 10             	add    $0x10,%esp
80106f5c:	85 c0                	test   %eax,%eax
80106f5e:	79 07                	jns    80106f67 <sys_exec+0xfd>
      return -1;
80106f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f65:	eb 09                	jmp    80106f70 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f6b:	e9 5a ff ff ff       	jmp    80106eca <sys_exec+0x60>
  return exec(path, argv);
}
80106f70:	c9                   	leave  
80106f71:	c3                   	ret    

80106f72 <sys_pipe>:

int
sys_pipe(void)
{
80106f72:	55                   	push   %ebp
80106f73:	89 e5                	mov    %esp,%ebp
80106f75:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106f78:	83 ec 04             	sub    $0x4,%esp
80106f7b:	6a 08                	push   $0x8
80106f7d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106f80:	50                   	push   %eax
80106f81:	6a 00                	push   $0x0
80106f83:	e8 38 f2 ff ff       	call   801061c0 <argptr>
80106f88:	83 c4 10             	add    $0x10,%esp
80106f8b:	85 c0                	test   %eax,%eax
80106f8d:	79 0a                	jns    80106f99 <sys_pipe+0x27>
    return -1;
80106f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f94:	e9 af 00 00 00       	jmp    80107048 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106f99:	83 ec 08             	sub    $0x8,%esp
80106f9c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106f9f:	50                   	push   %eax
80106fa0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106fa3:	50                   	push   %eax
80106fa4:	e8 15 d3 ff ff       	call   801042be <pipealloc>
80106fa9:	83 c4 10             	add    $0x10,%esp
80106fac:	85 c0                	test   %eax,%eax
80106fae:	79 0a                	jns    80106fba <sys_pipe+0x48>
    return -1;
80106fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fb5:	e9 8e 00 00 00       	jmp    80107048 <sys_pipe+0xd6>
  fd0 = -1;
80106fba:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106fc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fc4:	83 ec 0c             	sub    $0xc,%esp
80106fc7:	50                   	push   %eax
80106fc8:	e8 7c f3 ff ff       	call   80106349 <fdalloc>
80106fcd:	83 c4 10             	add    $0x10,%esp
80106fd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fd7:	78 18                	js     80106ff1 <sys_pipe+0x7f>
80106fd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fdc:	83 ec 0c             	sub    $0xc,%esp
80106fdf:	50                   	push   %eax
80106fe0:	e8 64 f3 ff ff       	call   80106349 <fdalloc>
80106fe5:	83 c4 10             	add    $0x10,%esp
80106fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106feb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106fef:	79 3f                	jns    80107030 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106ff1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ff5:	78 14                	js     8010700b <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106ff7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ffd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107000:	83 c2 08             	add    $0x8,%edx
80107003:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010700a:	00 
    fileclose(rf);
8010700b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010700e:	83 ec 0c             	sub    $0xc,%esp
80107011:	50                   	push   %eax
80107012:	e8 27 a0 ff ff       	call   8010103e <fileclose>
80107017:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010701a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010701d:	83 ec 0c             	sub    $0xc,%esp
80107020:	50                   	push   %eax
80107021:	e8 18 a0 ff ff       	call   8010103e <fileclose>
80107026:	83 c4 10             	add    $0x10,%esp
    return -1;
80107029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010702e:	eb 18                	jmp    80107048 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107030:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107033:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107036:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107038:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010703b:	8d 50 04             	lea    0x4(%eax),%edx
8010703e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107041:	89 02                	mov    %eax,(%edx)
  return 0;
80107043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107048:	c9                   	leave  
80107049:	c3                   	ret    

8010704a <sys_seek>:


int
sys_seek(void)
{
8010704a:	55                   	push   %ebp
8010704b:	89 e5                	mov    %esp,%ebp
8010704d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;

  if(argfd(0, 0, &f) < 0 || argint(1, &n) < 0 )
80107050:	83 ec 04             	sub    $0x4,%esp
80107053:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107056:	50                   	push   %eax
80107057:	6a 00                	push   $0x0
80107059:	6a 00                	push   $0x0
8010705b:	e8 74 f2 ff ff       	call   801062d4 <argfd>
80107060:	83 c4 10             	add    $0x10,%esp
80107063:	85 c0                	test   %eax,%eax
80107065:	78 15                	js     8010707c <sys_seek+0x32>
80107067:	83 ec 08             	sub    $0x8,%esp
8010706a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010706d:	50                   	push   %eax
8010706e:	6a 01                	push   $0x1
80107070:	e8 23 f1 ff ff       	call   80106198 <argint>
80107075:	83 c4 10             	add    $0x10,%esp
80107078:	85 c0                	test   %eax,%eax
8010707a:	79 07                	jns    80107083 <sys_seek+0x39>
    return -1;
8010707c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107081:	eb 15                	jmp    80107098 <sys_seek+0x4e>
  return fileseek(f, n);
80107083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107086:	89 c2                	mov    %eax,%edx
80107088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708b:	83 ec 08             	sub    $0x8,%esp
8010708e:	52                   	push   %edx
8010708f:	50                   	push   %eax
80107090:	e8 dc a2 ff ff       	call   80101371 <fileseek>
80107095:	83 c4 10             	add    $0x10,%esp
}
80107098:	c9                   	leave  
80107099:	c3                   	ret    

8010709a <sys_fork>:
#include "mmap.h"
#include "proc.h"

int
sys_fork(void)
{
8010709a:	55                   	push   %ebp
8010709b:	89 e5                	mov    %esp,%ebp
8010709d:	83 ec 08             	sub    $0x8,%esp
  return fork();
801070a0:	e8 b7 db ff ff       	call   80104c5c <fork>
}
801070a5:	c9                   	leave  
801070a6:	c3                   	ret    

801070a7 <sys_exit>:

int
sys_exit(void)
{
801070a7:	55                   	push   %ebp
801070a8:	89 e5                	mov    %esp,%ebp
801070aa:	83 ec 08             	sub    $0x8,%esp
  exit();
801070ad:	e8 80 de ff ff       	call   80104f32 <exit>
  return 0;  // not reached
801070b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070b7:	c9                   	leave  
801070b8:	c3                   	ret    

801070b9 <sys_wait>:

int
sys_wait(void)
{
801070b9:	55                   	push   %ebp
801070ba:	89 e5                	mov    %esp,%ebp
801070bc:	83 ec 08             	sub    $0x8,%esp
  return wait();
801070bf:	e8 5b e0 ff ff       	call   8010511f <wait>
}
801070c4:	c9                   	leave  
801070c5:	c3                   	ret    

801070c6 <sys_kill>:

int
sys_kill(void)
{
801070c6:	55                   	push   %ebp
801070c7:	89 e5                	mov    %esp,%ebp
801070c9:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801070cc:	83 ec 08             	sub    $0x8,%esp
801070cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070d2:	50                   	push   %eax
801070d3:	6a 00                	push   $0x0
801070d5:	e8 be f0 ff ff       	call   80106198 <argint>
801070da:	83 c4 10             	add    $0x10,%esp
801070dd:	85 c0                	test   %eax,%eax
801070df:	79 07                	jns    801070e8 <sys_kill+0x22>
    return -1;
801070e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070e6:	eb 0f                	jmp    801070f7 <sys_kill+0x31>
  return kill(pid);
801070e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070eb:	83 ec 0c             	sub    $0xc,%esp
801070ee:	50                   	push   %eax
801070ef:	e8 a3 e4 ff ff       	call   80105597 <kill>
801070f4:	83 c4 10             	add    $0x10,%esp
}
801070f7:	c9                   	leave  
801070f8:	c3                   	ret    

801070f9 <sys_getpid>:

int
sys_getpid(void)
{
801070f9:	55                   	push   %ebp
801070fa:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801070fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107102:	8b 40 10             	mov    0x10(%eax),%eax
}
80107105:	5d                   	pop    %ebp
80107106:	c3                   	ret    

80107107 <sys_sbrk>:

int
sys_sbrk(void)
{
80107107:	55                   	push   %ebp
80107108:	89 e5                	mov    %esp,%ebp
8010710a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010710d:	83 ec 08             	sub    $0x8,%esp
80107110:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107113:	50                   	push   %eax
80107114:	6a 00                	push   $0x0
80107116:	e8 7d f0 ff ff       	call   80106198 <argint>
8010711b:	83 c4 10             	add    $0x10,%esp
8010711e:	85 c0                	test   %eax,%eax
80107120:	79 07                	jns    80107129 <sys_sbrk+0x22>
    return -1;
80107122:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107127:	eb 28                	jmp    80107151 <sys_sbrk+0x4a>
  addr = proc->sz;
80107129:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010712f:	8b 00                	mov    (%eax),%eax
80107131:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107137:	83 ec 0c             	sub    $0xc,%esp
8010713a:	50                   	push   %eax
8010713b:	e8 79 da ff ff       	call   80104bb9 <growproc>
80107140:	83 c4 10             	add    $0x10,%esp
80107143:	85 c0                	test   %eax,%eax
80107145:	79 07                	jns    8010714e <sys_sbrk+0x47>
    return -1;
80107147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010714c:	eb 03                	jmp    80107151 <sys_sbrk+0x4a>
  return addr;
8010714e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107151:	c9                   	leave  
80107152:	c3                   	ret    

80107153 <sys_sleep>:

int
sys_sleep(void)
{
80107153:	55                   	push   %ebp
80107154:	89 e5                	mov    %esp,%ebp
80107156:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107159:	83 ec 08             	sub    $0x8,%esp
8010715c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010715f:	50                   	push   %eax
80107160:	6a 00                	push   $0x0
80107162:	e8 31 f0 ff ff       	call   80106198 <argint>
80107167:	83 c4 10             	add    $0x10,%esp
8010716a:	85 c0                	test   %eax,%eax
8010716c:	79 07                	jns    80107175 <sys_sleep+0x22>
    return -1;
8010716e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107173:	eb 77                	jmp    801071ec <sys_sleep+0x99>
  acquire(&tickslock);
80107175:	83 ec 0c             	sub    $0xc,%esp
80107178:	68 20 74 11 80       	push   $0x80117420
8010717d:	e8 8e ea ff ff       	call   80105c10 <acquire>
80107182:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80107185:	a1 60 7c 11 80       	mov    0x80117c60,%eax
8010718a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010718d:	eb 39                	jmp    801071c8 <sys_sleep+0x75>
    if(proc->killed){
8010718f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107195:	8b 40 24             	mov    0x24(%eax),%eax
80107198:	85 c0                	test   %eax,%eax
8010719a:	74 17                	je     801071b3 <sys_sleep+0x60>
      release(&tickslock);
8010719c:	83 ec 0c             	sub    $0xc,%esp
8010719f:	68 20 74 11 80       	push   $0x80117420
801071a4:	e8 ce ea ff ff       	call   80105c77 <release>
801071a9:	83 c4 10             	add    $0x10,%esp
      return -1;
801071ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071b1:	eb 39                	jmp    801071ec <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801071b3:	83 ec 08             	sub    $0x8,%esp
801071b6:	68 20 74 11 80       	push   $0x80117420
801071bb:	68 60 7c 11 80       	push   $0x80117c60
801071c0:	e8 8f e2 ff ff       	call   80105454 <sleep>
801071c5:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801071c8:	a1 60 7c 11 80       	mov    0x80117c60,%eax
801071cd:	2b 45 f4             	sub    -0xc(%ebp),%eax
801071d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071d3:	39 d0                	cmp    %edx,%eax
801071d5:	72 b8                	jb     8010718f <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801071d7:	83 ec 0c             	sub    $0xc,%esp
801071da:	68 20 74 11 80       	push   $0x80117420
801071df:	e8 93 ea ff ff       	call   80105c77 <release>
801071e4:	83 c4 10             	add    $0x10,%esp
  return 0;
801071e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071ec:	c9                   	leave  
801071ed:	c3                   	ret    

801071ee <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801071ee:	55                   	push   %ebp
801071ef:	89 e5                	mov    %esp,%ebp
801071f1:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801071f4:	83 ec 0c             	sub    $0xc,%esp
801071f7:	68 20 74 11 80       	push   $0x80117420
801071fc:	e8 0f ea ff ff       	call   80105c10 <acquire>
80107201:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107204:	a1 60 7c 11 80       	mov    0x80117c60,%eax
80107209:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010720c:	83 ec 0c             	sub    $0xc,%esp
8010720f:	68 20 74 11 80       	push   $0x80117420
80107214:	e8 5e ea ff ff       	call   80105c77 <release>
80107219:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010721c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010721f:	c9                   	leave  
80107220:	c3                   	ret    

80107221 <sys_procstat>:

// List the existing processes in the system and their status.
int
sys_procstat(void)
{
80107221:	55                   	push   %ebp
80107222:	89 e5                	mov    %esp,%ebp
80107224:	83 ec 08             	sub    $0x8,%esp
  cprintf("sys_procstat\n");
80107227:	83 ec 0c             	sub    $0xc,%esp
8010722a:	68 b7 9b 10 80       	push   $0x80109bb7
8010722f:	e8 92 91 ff ff       	call   801003c6 <cprintf>
80107234:	83 c4 10             	add    $0x10,%esp
  procdump();  // call function defined in proc.c
80107237:	e8 e6 e3 ff ff       	call   80105622 <procdump>
  return 0;
8010723c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107241:	c9                   	leave  
80107242:	c3                   	ret    

80107243 <sys_setpriority>:

// Set the priority to a process.
int
sys_setpriority(void)
{
80107243:	55                   	push   %ebp
80107244:	89 e5                	mov    %esp,%ebp
80107246:	83 ec 18             	sub    $0x18,%esp
  int level;
  //cprintf("sys_setpriority\n");
  if(argint(0, &level)<0)
80107249:	83 ec 08             	sub    $0x8,%esp
8010724c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010724f:	50                   	push   %eax
80107250:	6a 00                	push   $0x0
80107252:	e8 41 ef ff ff       	call   80106198 <argint>
80107257:	83 c4 10             	add    $0x10,%esp
8010725a:	85 c0                	test   %eax,%eax
8010725c:	79 07                	jns    80107265 <sys_setpriority+0x22>
    return -1;
8010725e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107263:	eb 12                	jmp    80107277 <sys_setpriority+0x34>
  proc->priority=level;
80107265:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010726b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010726e:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  return 0;
80107272:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107277:	c9                   	leave  
80107278:	c3                   	ret    

80107279 <sys_semget>:


int
sys_semget(void)
{
80107279:	55                   	push   %ebp
8010727a:	89 e5                	mov    %esp,%ebp
8010727c:	83 ec 18             	sub    $0x18,%esp
  int id, value;
  if(argint(0, &id)<0)
8010727f:	83 ec 08             	sub    $0x8,%esp
80107282:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107285:	50                   	push   %eax
80107286:	6a 00                	push   $0x0
80107288:	e8 0b ef ff ff       	call   80106198 <argint>
8010728d:	83 c4 10             	add    $0x10,%esp
80107290:	85 c0                	test   %eax,%eax
80107292:	79 07                	jns    8010729b <sys_semget+0x22>
    return -1;
80107294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107299:	eb 2f                	jmp    801072ca <sys_semget+0x51>
  if(argint(1, &value)<0)
8010729b:	83 ec 08             	sub    $0x8,%esp
8010729e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072a1:	50                   	push   %eax
801072a2:	6a 01                	push   $0x1
801072a4:	e8 ef ee ff ff       	call   80106198 <argint>
801072a9:	83 c4 10             	add    $0x10,%esp
801072ac:	85 c0                	test   %eax,%eax
801072ae:	79 07                	jns    801072b7 <sys_semget+0x3e>
    return -1;
801072b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072b5:	eb 13                	jmp    801072ca <sys_semget+0x51>
  return semget(id,value);
801072b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bd:	83 ec 08             	sub    $0x8,%esp
801072c0:	52                   	push   %edx
801072c1:	50                   	push   %eax
801072c2:	e8 64 e5 ff ff       	call   8010582b <semget>
801072c7:	83 c4 10             	add    $0x10,%esp
}
801072ca:	c9                   	leave  
801072cb:	c3                   	ret    

801072cc <sys_semfree>:


int
sys_semfree(void)
{
801072cc:	55                   	push   %ebp
801072cd:	89 e5                	mov    %esp,%ebp
801072cf:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
801072d2:	83 ec 08             	sub    $0x8,%esp
801072d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072d8:	50                   	push   %eax
801072d9:	6a 00                	push   $0x0
801072db:	e8 b8 ee ff ff       	call   80106198 <argint>
801072e0:	83 c4 10             	add    $0x10,%esp
801072e3:	85 c0                	test   %eax,%eax
801072e5:	79 07                	jns    801072ee <sys_semfree+0x22>
    return -1;
801072e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072ec:	eb 0f                	jmp    801072fd <sys_semfree+0x31>
  return semfree(id);
801072ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f1:	83 ec 0c             	sub    $0xc,%esp
801072f4:	50                   	push   %eax
801072f5:	e8 63 e6 ff ff       	call   8010595d <semfree>
801072fa:	83 c4 10             	add    $0x10,%esp
}
801072fd:	c9                   	leave  
801072fe:	c3                   	ret    

801072ff <sys_semdown>:


int
sys_semdown(void)
{
801072ff:	55                   	push   %ebp
80107300:	89 e5                	mov    %esp,%ebp
80107302:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107305:	83 ec 08             	sub    $0x8,%esp
80107308:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010730b:	50                   	push   %eax
8010730c:	6a 00                	push   $0x0
8010730e:	e8 85 ee ff ff       	call   80106198 <argint>
80107313:	83 c4 10             	add    $0x10,%esp
80107316:	85 c0                	test   %eax,%eax
80107318:	79 07                	jns    80107321 <sys_semdown+0x22>
    return -1;
8010731a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010731f:	eb 0f                	jmp    80107330 <sys_semdown+0x31>
  return semdown(id);
80107321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107324:	83 ec 0c             	sub    $0xc,%esp
80107327:	50                   	push   %eax
80107328:	e8 cb e6 ff ff       	call   801059f8 <semdown>
8010732d:	83 c4 10             	add    $0x10,%esp
}
80107330:	c9                   	leave  
80107331:	c3                   	ret    

80107332 <sys_semup>:


int
sys_semup(void)
{
80107332:	55                   	push   %ebp
80107333:	89 e5                	mov    %esp,%ebp
80107335:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107338:	83 ec 08             	sub    $0x8,%esp
8010733b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010733e:	50                   	push   %eax
8010733f:	6a 00                	push   $0x0
80107341:	e8 52 ee ff ff       	call   80106198 <argint>
80107346:	83 c4 10             	add    $0x10,%esp
80107349:	85 c0                	test   %eax,%eax
8010734b:	79 07                	jns    80107354 <sys_semup+0x22>
    return -1;
8010734d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107352:	eb 0f                	jmp    80107363 <sys_semup+0x31>
  return semup(id);
80107354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107357:	83 ec 0c             	sub    $0xc,%esp
8010735a:	50                   	push   %eax
8010735b:	e8 2b e7 ff ff       	call   80105a8b <semup>
80107360:	83 c4 10             	add    $0x10,%esp
}
80107363:	c9                   	leave  
80107364:	c3                   	ret    

80107365 <sys_mmap>:

int
sys_mmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
80107365:	55                   	push   %ebp
80107366:	89 e5                	mov    %esp,%ebp
80107368:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int addr;

  if(argint(0, &fd)<0 || argint(1,&addr)<0){ //PREGUNTAR
8010736b:	83 ec 08             	sub    $0x8,%esp
8010736e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107371:	50                   	push   %eax
80107372:	6a 00                	push   $0x0
80107374:	e8 1f ee ff ff       	call   80106198 <argint>
80107379:	83 c4 10             	add    $0x10,%esp
8010737c:	85 c0                	test   %eax,%eax
8010737e:	78 15                	js     80107395 <sys_mmap+0x30>
80107380:	83 ec 08             	sub    $0x8,%esp
80107383:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107386:	50                   	push   %eax
80107387:	6a 01                	push   $0x1
80107389:	e8 0a ee ff ff       	call   80106198 <argint>
8010738e:	83 c4 10             	add    $0x10,%esp
80107391:	85 c0                	test   %eax,%eax
80107393:	79 07                	jns    8010739c <sys_mmap+0x37>
    return -1;
80107395:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010739a:	eb 15                	jmp    801073b1 <sys_mmap+0x4c>
  }
  //cprintf("%x",addr);
  return mmap(fd,(char**)addr);
8010739c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010739f:	89 c2                	mov    %eax,%edx
801073a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a4:	83 ec 08             	sub    $0x8,%esp
801073a7:	52                   	push   %edx
801073a8:	50                   	push   %eax
801073a9:	e8 c3 c6 ff ff       	call   80103a71 <mmap>
801073ae:	83 c4 10             	add    $0x10,%esp
}
801073b1:	c9                   	leave  
801073b2:	c3                   	ret    

801073b3 <sys_munmap>:

int
sys_munmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
801073b3:	55                   	push   %ebp
801073b4:	89 e5                	mov    %esp,%ebp
801073b6:	83 ec 18             	sub    $0x18,%esp
  int addr;

  if(argint(0,&addr)<0){ //PREGUNTAR
801073b9:	83 ec 08             	sub    $0x8,%esp
801073bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073bf:	50                   	push   %eax
801073c0:	6a 00                	push   $0x0
801073c2:	e8 d1 ed ff ff       	call   80106198 <argint>
801073c7:	83 c4 10             	add    $0x10,%esp
801073ca:	85 c0                	test   %eax,%eax
801073cc:	79 07                	jns    801073d5 <sys_munmap+0x22>
    return -1;
801073ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d3:	eb 0f                	jmp    801073e4 <sys_munmap+0x31>
  }

  return munmap((char*)addr);
801073d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d8:	83 ec 0c             	sub    $0xc,%esp
801073db:	50                   	push   %eax
801073dc:	e8 da c7 ff ff       	call   80103bbb <munmap>
801073e1:	83 c4 10             	add    $0x10,%esp
}
801073e4:	c9                   	leave  
801073e5:	c3                   	ret    

801073e6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801073e6:	55                   	push   %ebp
801073e7:	89 e5                	mov    %esp,%ebp
801073e9:	83 ec 08             	sub    $0x8,%esp
801073ec:	8b 55 08             	mov    0x8(%ebp),%edx
801073ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801073f2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801073f6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801073f9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801073fd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107401:	ee                   	out    %al,(%dx)
}
80107402:	90                   	nop
80107403:	c9                   	leave  
80107404:	c3                   	ret    

80107405 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107405:	55                   	push   %ebp
80107406:	89 e5                	mov    %esp,%ebp
80107408:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010740b:	6a 34                	push   $0x34
8010740d:	6a 43                	push   $0x43
8010740f:	e8 d2 ff ff ff       	call   801073e6 <outb>
80107414:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107417:	68 9c 00 00 00       	push   $0x9c
8010741c:	6a 40                	push   $0x40
8010741e:	e8 c3 ff ff ff       	call   801073e6 <outb>
80107423:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107426:	6a 2e                	push   $0x2e
80107428:	6a 40                	push   $0x40
8010742a:	e8 b7 ff ff ff       	call   801073e6 <outb>
8010742f:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107432:	83 ec 0c             	sub    $0xc,%esp
80107435:	6a 00                	push   $0x0
80107437:	e8 6c cd ff ff       	call   801041a8 <picenable>
8010743c:	83 c4 10             	add    $0x10,%esp
}
8010743f:	90                   	nop
80107440:	c9                   	leave  
80107441:	c3                   	ret    

80107442 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107442:	1e                   	push   %ds
  pushl %es
80107443:	06                   	push   %es
  pushl %fs
80107444:	0f a0                	push   %fs
  pushl %gs
80107446:	0f a8                	push   %gs
  pushal
80107448:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107449:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010744d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010744f:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107451:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107455:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107457:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107459:	54                   	push   %esp
  call trap
8010745a:	e8 73 02 00 00       	call   801076d2 <trap>
  addl $4, %esp
8010745f:	83 c4 04             	add    $0x4,%esp

80107462 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107462:	61                   	popa   
  popl %gs
80107463:	0f a9                	pop    %gs
  popl %fs
80107465:	0f a1                	pop    %fs
  popl %es
80107467:	07                   	pop    %es
  popl %ds
80107468:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107469:	83 c4 08             	add    $0x8,%esp
  iret
8010746c:	cf                   	iret   

8010746d <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010746d:	55                   	push   %ebp
8010746e:	89 e5                	mov    %esp,%ebp
80107470:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107473:	8b 45 0c             	mov    0xc(%ebp),%eax
80107476:	83 e8 01             	sub    $0x1,%eax
80107479:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010747d:	8b 45 08             	mov    0x8(%ebp),%eax
80107480:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107484:	8b 45 08             	mov    0x8(%ebp),%eax
80107487:	c1 e8 10             	shr    $0x10,%eax
8010748a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010748e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107491:	0f 01 18             	lidtl  (%eax)
}
80107494:	90                   	nop
80107495:	c9                   	leave  
80107496:	c3                   	ret    

80107497 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107497:	55                   	push   %ebp
80107498:	89 e5                	mov    %esp,%ebp
8010749a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010749d:	0f 20 d0             	mov    %cr2,%eax
801074a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801074a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801074a6:	c9                   	leave  
801074a7:	c3                   	ret    

801074a8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801074a8:	55                   	push   %ebp
801074a9:	89 e5                	mov    %esp,%ebp
801074ab:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801074ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074b5:	e9 c3 00 00 00       	jmp    8010757d <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801074ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bd:	8b 04 85 bc c0 10 80 	mov    -0x7fef3f44(,%eax,4),%eax
801074c4:	89 c2                	mov    %eax,%edx
801074c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c9:	66 89 14 c5 60 74 11 	mov    %dx,-0x7fee8ba0(,%eax,8)
801074d0:	80 
801074d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d4:	66 c7 04 c5 62 74 11 	movw   $0x8,-0x7fee8b9e(,%eax,8)
801074db:	80 08 00 
801074de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e1:	0f b6 14 c5 64 74 11 	movzbl -0x7fee8b9c(,%eax,8),%edx
801074e8:	80 
801074e9:	83 e2 e0             	and    $0xffffffe0,%edx
801074ec:	88 14 c5 64 74 11 80 	mov    %dl,-0x7fee8b9c(,%eax,8)
801074f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f6:	0f b6 14 c5 64 74 11 	movzbl -0x7fee8b9c(,%eax,8),%edx
801074fd:	80 
801074fe:	83 e2 1f             	and    $0x1f,%edx
80107501:	88 14 c5 64 74 11 80 	mov    %dl,-0x7fee8b9c(,%eax,8)
80107508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750b:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
80107512:	80 
80107513:	83 e2 f0             	and    $0xfffffff0,%edx
80107516:	83 ca 0e             	or     $0xe,%edx
80107519:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
80107520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107523:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
8010752a:	80 
8010752b:	83 e2 ef             	and    $0xffffffef,%edx
8010752e:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
80107535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107538:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
8010753f:	80 
80107540:	83 e2 9f             	and    $0xffffff9f,%edx
80107543:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
8010754a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754d:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
80107554:	80 
80107555:	83 ca 80             	or     $0xffffff80,%edx
80107558:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
8010755f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107562:	8b 04 85 bc c0 10 80 	mov    -0x7fef3f44(,%eax,4),%eax
80107569:	c1 e8 10             	shr    $0x10,%eax
8010756c:	89 c2                	mov    %eax,%edx
8010756e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107571:	66 89 14 c5 66 74 11 	mov    %dx,-0x7fee8b9a(,%eax,8)
80107578:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107579:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010757d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107584:	0f 8e 30 ff ff ff    	jle    801074ba <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010758a:	a1 bc c1 10 80       	mov    0x8010c1bc,%eax
8010758f:	66 a3 60 76 11 80    	mov    %ax,0x80117660
80107595:	66 c7 05 62 76 11 80 	movw   $0x8,0x80117662
8010759c:	08 00 
8010759e:	0f b6 05 64 76 11 80 	movzbl 0x80117664,%eax
801075a5:	83 e0 e0             	and    $0xffffffe0,%eax
801075a8:	a2 64 76 11 80       	mov    %al,0x80117664
801075ad:	0f b6 05 64 76 11 80 	movzbl 0x80117664,%eax
801075b4:	83 e0 1f             	and    $0x1f,%eax
801075b7:	a2 64 76 11 80       	mov    %al,0x80117664
801075bc:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
801075c3:	83 c8 0f             	or     $0xf,%eax
801075c6:	a2 65 76 11 80       	mov    %al,0x80117665
801075cb:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
801075d2:	83 e0 ef             	and    $0xffffffef,%eax
801075d5:	a2 65 76 11 80       	mov    %al,0x80117665
801075da:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
801075e1:	83 c8 60             	or     $0x60,%eax
801075e4:	a2 65 76 11 80       	mov    %al,0x80117665
801075e9:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
801075f0:	83 c8 80             	or     $0xffffff80,%eax
801075f3:	a2 65 76 11 80       	mov    %al,0x80117665
801075f8:	a1 bc c1 10 80       	mov    0x8010c1bc,%eax
801075fd:	c1 e8 10             	shr    $0x10,%eax
80107600:	66 a3 66 76 11 80    	mov    %ax,0x80117666

  initlock(&tickslock, "time");
80107606:	83 ec 08             	sub    $0x8,%esp
80107609:	68 c8 9b 10 80       	push   $0x80109bc8
8010760e:	68 20 74 11 80       	push   $0x80117420
80107613:	e8 d6 e5 ff ff       	call   80105bee <initlock>
80107618:	83 c4 10             	add    $0x10,%esp
}
8010761b:	90                   	nop
8010761c:	c9                   	leave  
8010761d:	c3                   	ret    

8010761e <idtinit>:

void
idtinit(void)
{
8010761e:	55                   	push   %ebp
8010761f:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107621:	68 00 08 00 00       	push   $0x800
80107626:	68 60 74 11 80       	push   $0x80117460
8010762b:	e8 3d fe ff ff       	call   8010746d <lidt>
80107630:	83 c4 08             	add    $0x8,%esp
}
80107633:	90                   	nop
80107634:	c9                   	leave  
80107635:	c3                   	ret    

80107636 <mmapin>:

int
mmapin(uint cr2)
{
80107636:	55                   	push   %ebp
80107637:	89 e5                	mov    %esp,%ebp
80107639:	83 ec 10             	sub    $0x10,%esp
  int index;

  for(index = 0; index < MAXMAPPEDFILES; index++){
8010763c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107643:	eb 7c                	jmp    801076c1 <mmapin+0x8b>
    int va;
    int sz;
    va = proc->ommap[index].va;
80107645:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010764c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010764f:	89 d0                	mov    %edx,%eax
80107651:	01 c0                	add    %eax,%eax
80107653:	01 d0                	add    %edx,%eax
80107655:	c1 e0 02             	shl    $0x2,%eax
80107658:	01 c8                	add    %ecx,%eax
8010765a:	05 a4 00 00 00       	add    $0xa4,%eax
8010765f:	8b 00                	mov    (%eax),%eax
80107661:	89 45 f8             	mov    %eax,-0x8(%ebp)
    sz = proc->ommap[index].sz;
80107664:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010766b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010766e:	89 d0                	mov    %edx,%eax
80107670:	01 c0                	add    %eax,%eax
80107672:	01 d0                	add    %edx,%eax
80107674:	c1 e0 02             	shl    $0x2,%eax
80107677:	01 c8                	add    %ecx,%eax
80107679:	05 a8 00 00 00       	add    $0xa8,%eax
8010767e:	8b 00                	mov    (%eax),%eax
80107680:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(proc->ommap[index].pfile != 0 && cr2 >= va && cr2 < (va + sz))
80107683:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010768a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010768d:	89 d0                	mov    %edx,%eax
8010768f:	01 c0                	add    %eax,%eax
80107691:	01 d0                	add    %edx,%eax
80107693:	c1 e0 02             	shl    $0x2,%eax
80107696:	01 c8                	add    %ecx,%eax
80107698:	05 a0 00 00 00       	add    $0xa0,%eax
8010769d:	8b 00                	mov    (%eax),%eax
8010769f:	85 c0                	test   %eax,%eax
801076a1:	74 1a                	je     801076bd <mmapin+0x87>
801076a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801076a6:	39 45 08             	cmp    %eax,0x8(%ebp)
801076a9:	72 12                	jb     801076bd <mmapin+0x87>
801076ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
801076ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b1:	01 d0                	add    %edx,%eax
801076b3:	3b 45 08             	cmp    0x8(%ebp),%eax
801076b6:	76 05                	jbe    801076bd <mmapin+0x87>
      return index;
801076b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076bb:	eb 13                	jmp    801076d0 <mmapin+0x9a>
int
mmapin(uint cr2)
{
  int index;

  for(index = 0; index < MAXMAPPEDFILES; index++){
801076bd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801076c1:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801076c5:	0f 8e 7a ff ff ff    	jle    80107645 <mmapin+0xf>
    sz = proc->ommap[index].sz;

    if(proc->ommap[index].pfile != 0 && cr2 >= va && cr2 < (va + sz))
      return index;
  }
  return -1;
801076cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801076d0:	c9                   	leave  
801076d1:	c3                   	ret    

801076d2 <trap>:


//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801076d2:	55                   	push   %ebp
801076d3:	89 e5                	mov    %esp,%ebp
801076d5:	57                   	push   %edi
801076d6:	56                   	push   %esi
801076d7:	53                   	push   %ebx
801076d8:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801076db:	8b 45 08             	mov    0x8(%ebp),%eax
801076de:	8b 40 30             	mov    0x30(%eax),%eax
801076e1:	83 f8 40             	cmp    $0x40,%eax
801076e4:	75 3e                	jne    80107724 <trap+0x52>
    if(proc->killed)
801076e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076ec:	8b 40 24             	mov    0x24(%eax),%eax
801076ef:	85 c0                	test   %eax,%eax
801076f1:	74 05                	je     801076f8 <trap+0x26>
      exit();
801076f3:	e8 3a d8 ff ff       	call   80104f32 <exit>
    proc->tf = tf;
801076f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076fe:	8b 55 08             	mov    0x8(%ebp),%edx
80107701:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107704:	e8 45 eb ff ff       	call   8010624e <syscall>
    if(proc->killed)
80107709:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010770f:	8b 40 24             	mov    0x24(%eax),%eax
80107712:	85 c0                	test   %eax,%eax
80107714:	0f 84 06 04 00 00    	je     80107b20 <trap+0x44e>
      exit();
8010771a:	e8 13 d8 ff ff       	call   80104f32 <exit>
    return;
8010771f:	e9 fc 03 00 00       	jmp    80107b20 <trap+0x44e>
  }

  switch(tf->trapno){
80107724:	8b 45 08             	mov    0x8(%ebp),%eax
80107727:	8b 40 30             	mov    0x30(%eax),%eax
8010772a:	83 e8 20             	sub    $0x20,%eax
8010772d:	83 f8 1f             	cmp    $0x1f,%eax
80107730:	0f 87 c0 00 00 00    	ja     801077f6 <trap+0x124>
80107736:	8b 04 85 04 9d 10 80 	mov    -0x7fef62fc(,%eax,4),%eax
8010773d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010773f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107745:	0f b6 00             	movzbl (%eax),%eax
80107748:	84 c0                	test   %al,%al
8010774a:	75 3d                	jne    80107789 <trap+0xb7>
      acquire(&tickslock);
8010774c:	83 ec 0c             	sub    $0xc,%esp
8010774f:	68 20 74 11 80       	push   $0x80117420
80107754:	e8 b7 e4 ff ff       	call   80105c10 <acquire>
80107759:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010775c:	a1 60 7c 11 80       	mov    0x80117c60,%eax
80107761:	83 c0 01             	add    $0x1,%eax
80107764:	a3 60 7c 11 80       	mov    %eax,0x80117c60
      wakeup(&ticks);
80107769:	83 ec 0c             	sub    $0xc,%esp
8010776c:	68 60 7c 11 80       	push   $0x80117c60
80107771:	e8 ea dd ff ff       	call   80105560 <wakeup>
80107776:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107779:	83 ec 0c             	sub    $0xc,%esp
8010777c:	68 20 74 11 80       	push   $0x80117420
80107781:	e8 f1 e4 ff ff       	call   80105c77 <release>
80107786:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107789:	e8 59 b8 ff ff       	call   80102fe7 <lapiceoi>
    break;
8010778e:	e9 b1 02 00 00       	jmp    80107a44 <trap+0x372>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107793:	e8 62 b0 ff ff       	call   801027fa <ideintr>
    lapiceoi();
80107798:	e8 4a b8 ff ff       	call   80102fe7 <lapiceoi>
    break;
8010779d:	e9 a2 02 00 00       	jmp    80107a44 <trap+0x372>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801077a2:	e8 42 b6 ff ff       	call   80102de9 <kbdintr>
    lapiceoi();
801077a7:	e8 3b b8 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077ac:	e9 93 02 00 00       	jmp    80107a44 <trap+0x372>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801077b1:	e8 4b 05 00 00       	call   80107d01 <uartintr>
    lapiceoi();
801077b6:	e8 2c b8 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077bb:	e9 84 02 00 00       	jmp    80107a44 <trap+0x372>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077c0:	8b 45 08             	mov    0x8(%ebp),%eax
801077c3:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801077c6:	8b 45 08             	mov    0x8(%ebp),%eax
801077c9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077cd:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801077d0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077d6:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077d9:	0f b6 c0             	movzbl %al,%eax
801077dc:	51                   	push   %ecx
801077dd:	52                   	push   %edx
801077de:	50                   	push   %eax
801077df:	68 d0 9b 10 80       	push   $0x80109bd0
801077e4:	e8 dd 8b ff ff       	call   801003c6 <cprintf>
801077e9:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801077ec:	e8 f6 b7 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077f1:	e9 4e 02 00 00       	jmp    80107a44 <trap+0x372>

  //PAGEBREAK: 13
  default:

    if(proc && tf->trapno == T_PGFLT){
801077f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077fc:	85 c0                	test   %eax,%eax
801077fe:	0f 84 84 01 00 00    	je     80107988 <trap+0x2b6>
80107804:	8b 45 08             	mov    0x8(%ebp),%eax
80107807:	8b 40 30             	mov    0x30(%eax),%eax
8010780a:	83 f8 0e             	cmp    $0xe,%eax
8010780d:	0f 85 75 01 00 00    	jne    80107988 <trap+0x2b6>
      uint cr2=rcr2();
80107813:	e8 7f fc ff ff       	call   80107497 <rcr2>
80107818:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int mmapid;


      //  Verify if you wanted to access a correct address but not assigned.
      //  if appropriate, assign one more page to the stack.
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
8010781b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107821:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80107827:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010782a:	77 6b                	ja     80107897 <trap+0x1c5>
8010782c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107832:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80107838:	05 00 80 00 00       	add    $0x8000,%eax
8010783d:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80107840:	76 55                	jbe    80107897 <trap+0x1c5>
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
80107842:	83 ec 08             	sub    $0x8,%esp
80107845:	ff 75 e4             	pushl  -0x1c(%ebp)
80107848:	68 f4 9b 10 80       	push   $0x80109bf4
8010784d:	e8 74 8b ff ff       	call   801003c6 <cprintf>
80107852:	83 c4 10             	add    $0x10,%esp
        basepgaddr=PGROUNDDOWN(cr2);
80107855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107858:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010785d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
80107860:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107863:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
80107869:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010786f:	8b 40 04             	mov    0x4(%eax),%eax
80107872:	83 ec 04             	sub    $0x4,%esp
80107875:	52                   	push   %edx
80107876:	ff 75 e0             	pushl  -0x20(%ebp)
80107879:	50                   	push   %eax
8010787a:	e8 d6 18 00 00       	call   80109155 <allocuvm>
8010787f:	83 c4 10             	add    $0x10,%esp
80107882:	85 c0                	test   %eax,%eax
80107884:	0f 85 b9 01 00 00    	jne    80107a43 <trap+0x371>
          panic("trap alloc stack");
8010788a:	83 ec 0c             	sub    $0xc,%esp
8010788d:	68 30 9c 10 80       	push   $0x80109c30
80107892:	e8 cf 8c ff ff       	call   80100566 <panic>
        break;
      }

      if ( (mmapid = mmapin(cr2)) >= 0 ) {
80107897:	83 ec 0c             	sub    $0xc,%esp
8010789a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010789d:	e8 94 fd ff ff       	call   80107636 <mmapin>
801078a2:	83 c4 10             	add    $0x10,%esp
801078a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
801078a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801078ac:	0f 88 d6 00 00 00    	js     80107988 <trap+0x2b6>
        int offset;
        cprintf("\nSE QUIERE LEER UNA PAGINA DEL ARCHIVO NO ALOCADA!\n");
801078b2:	83 ec 0c             	sub    $0xc,%esp
801078b5:	68 44 9c 10 80       	push   $0x80109c44
801078ba:	e8 07 8b ff ff       	call   801003c6 <cprintf>
801078bf:	83 c4 10             	add    $0x10,%esp
        // in ashared memory region
        basepgaddr = PGROUNDDOWN(cr2);
801078c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801078c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
801078cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801078d0:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
801078d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078dc:	8b 40 04             	mov    0x4(%eax),%eax
801078df:	83 ec 04             	sub    $0x4,%esp
801078e2:	52                   	push   %edx
801078e3:	ff 75 e0             	pushl  -0x20(%ebp)
801078e6:	50                   	push   %eax
801078e7:	e8 69 18 00 00       	call   80109155 <allocuvm>
801078ec:	83 c4 10             	add    $0x10,%esp
801078ef:	85 c0                	test   %eax,%eax
801078f1:	75 0d                	jne    80107900 <trap+0x22e>
          panic("trap alloc mmap");
801078f3:	83 ec 0c             	sub    $0xc,%esp
801078f6:	68 78 9c 10 80       	push   $0x80109c78
801078fb:	e8 66 8c ff ff       	call   80100566 <panic>
        offset = basepgaddr - proc->ommap[mmapid].va;
80107900:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80107907:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010790a:	89 d0                	mov    %edx,%eax
8010790c:	01 c0                	add    %eax,%eax
8010790e:	01 d0                	add    %edx,%eax
80107910:	c1 e0 02             	shl    $0x2,%eax
80107913:	01 c8                	add    %ecx,%eax
80107915:	05 a4 00 00 00       	add    $0xa4,%eax
8010791a:	8b 00                	mov    (%eax),%eax
8010791c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010791f:	29 c2                	sub    %eax,%edx
80107921:	89 d0                	mov    %edx,%eax
80107923:	89 45 d8             	mov    %eax,-0x28(%ebp)
        fileseek(proc->ommap[mmapid].pfile, offset);
80107926:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80107929:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80107930:	8b 55 dc             	mov    -0x24(%ebp),%edx
80107933:	89 d0                	mov    %edx,%eax
80107935:	01 c0                	add    %eax,%eax
80107937:	01 d0                	add    %edx,%eax
80107939:	c1 e0 02             	shl    $0x2,%eax
8010793c:	01 d8                	add    %ebx,%eax
8010793e:	05 a0 00 00 00       	add    $0xa0,%eax
80107943:	8b 00                	mov    (%eax),%eax
80107945:	83 ec 08             	sub    $0x8,%esp
80107948:	51                   	push   %ecx
80107949:	50                   	push   %eax
8010794a:	e8 22 9a ff ff       	call   80101371 <fileseek>
8010794f:	83 c4 10             	add    $0x10,%esp
        fileread(proc->ommap[mmapid].pfile, (char *)basepgaddr, PGSIZE);
80107952:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80107955:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010795c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010795f:	89 d0                	mov    %edx,%eax
80107961:	01 c0                	add    %eax,%eax
80107963:	01 d0                	add    %edx,%eax
80107965:	c1 e0 02             	shl    $0x2,%eax
80107968:	01 d8                	add    %ebx,%eax
8010796a:	05 a0 00 00 00       	add    $0xa0,%eax
8010796f:	8b 00                	mov    (%eax),%eax
80107971:	83 ec 04             	sub    $0x4,%esp
80107974:	68 00 10 00 00       	push   $0x1000
80107979:	51                   	push   %ecx
8010797a:	50                   	push   %eax
8010797b:	e8 fd 97 ff ff       	call   8010117d <fileread>
80107980:	83 c4 10             	add    $0x10,%esp
        break;
80107983:	e9 bc 00 00 00       	jmp    80107a44 <trap+0x372>
      }

    }

    if(proc == 0 || (tf->cs&3) == 0){
80107988:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010798e:	85 c0                	test   %eax,%eax
80107990:	74 11                	je     801079a3 <trap+0x2d1>
80107992:	8b 45 08             	mov    0x8(%ebp),%eax
80107995:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107999:	0f b7 c0             	movzwl %ax,%eax
8010799c:	83 e0 03             	and    $0x3,%eax
8010799f:	85 c0                	test   %eax,%eax
801079a1:	75 40                	jne    801079e3 <trap+0x311>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801079a3:	e8 ef fa ff ff       	call   80107497 <rcr2>
801079a8:	89 c3                	mov    %eax,%ebx
801079aa:	8b 45 08             	mov    0x8(%ebp),%eax
801079ad:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801079b0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079b6:	0f b6 00             	movzbl (%eax),%eax

    }

    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801079b9:	0f b6 d0             	movzbl %al,%edx
801079bc:	8b 45 08             	mov    0x8(%ebp),%eax
801079bf:	8b 40 30             	mov    0x30(%eax),%eax
801079c2:	83 ec 0c             	sub    $0xc,%esp
801079c5:	53                   	push   %ebx
801079c6:	51                   	push   %ecx
801079c7:	52                   	push   %edx
801079c8:	50                   	push   %eax
801079c9:	68 88 9c 10 80       	push   $0x80109c88
801079ce:	e8 f3 89 ff ff       	call   801003c6 <cprintf>
801079d3:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801079d6:	83 ec 0c             	sub    $0xc,%esp
801079d9:	68 ba 9c 10 80       	push   $0x80109cba
801079de:	e8 83 8b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801079e3:	e8 af fa ff ff       	call   80107497 <rcr2>
801079e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801079eb:	8b 45 08             	mov    0x8(%ebp),%eax
801079ee:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
801079f1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079f7:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801079fa:	0f b6 d8             	movzbl %al,%ebx
801079fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107a00:	8b 48 34             	mov    0x34(%eax),%ecx
80107a03:	8b 45 08             	mov    0x8(%ebp),%eax
80107a06:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107a09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a0f:	8d 78 6c             	lea    0x6c(%eax),%edi
80107a12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107a18:	8b 40 10             	mov    0x10(%eax),%eax
80107a1b:	ff 75 d4             	pushl  -0x2c(%ebp)
80107a1e:	56                   	push   %esi
80107a1f:	53                   	push   %ebx
80107a20:	51                   	push   %ecx
80107a21:	52                   	push   %edx
80107a22:	57                   	push   %edi
80107a23:	50                   	push   %eax
80107a24:	68 c0 9c 10 80       	push   $0x80109cc0
80107a29:	e8 98 89 ff ff       	call   801003c6 <cprintf>
80107a2e:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
80107a31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a37:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107a3e:	eb 04                	jmp    80107a44 <trap+0x372>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107a40:	90                   	nop
80107a41:	eb 01                	jmp    80107a44 <trap+0x372>
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
        basepgaddr=PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        break;
80107a43:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a4a:	85 c0                	test   %eax,%eax
80107a4c:	74 24                	je     80107a72 <trap+0x3a0>
80107a4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a54:	8b 40 24             	mov    0x24(%eax),%eax
80107a57:	85 c0                	test   %eax,%eax
80107a59:	74 17                	je     80107a72 <trap+0x3a0>
80107a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a5e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107a62:	0f b7 c0             	movzwl %ax,%eax
80107a65:	83 e0 03             	and    $0x3,%eax
80107a68:	83 f8 03             	cmp    $0x3,%eax
80107a6b:	75 05                	jne    80107a72 <trap+0x3a0>
    exit();
80107a6d:	e8 c0 d4 ff ff       	call   80104f32 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
80107a72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a78:	85 c0                	test   %eax,%eax
80107a7a:	74 41                	je     80107abd <trap+0x3eb>
80107a7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a82:	8b 40 0c             	mov    0xc(%eax),%eax
80107a85:	83 f8 04             	cmp    $0x4,%eax
80107a88:	75 33                	jne    80107abd <trap+0x3eb>
80107a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a8d:	8b 40 30             	mov    0x30(%eax),%eax
80107a90:	83 f8 20             	cmp    $0x20,%eax
80107a93:	75 28                	jne    80107abd <trap+0x3eb>
    if(proc->ticks++ == QUANTUM-1){  // Check if the amount of ticks of the current process reached the Quantum
80107a95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a9b:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
80107a9f:	8d 4a 01             	lea    0x1(%edx),%ecx
80107aa2:	66 89 48 7c          	mov    %cx,0x7c(%eax)
80107aa6:	66 83 fa 04          	cmp    $0x4,%dx
80107aaa:	75 11                	jne    80107abd <trap+0x3eb>
      //cprintf("El proceso con id %d tiene %d ticks\n",proc->pid, proc->ticks);
      proc->ticks=0;  // Restarts the amount of process ticks
80107aac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ab2:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
80107ab8:	e8 05 d9 ff ff       	call   801053c2 <yield>
    }

  }
  // check if the number of ticks was reached to increase the ages.
  if((tf->trapno == T_IRQ0+IRQ_TIMER) && (ticks % TICKSFORAGE == 0))
80107abd:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac0:	8b 40 30             	mov    0x30(%eax),%eax
80107ac3:	83 f8 20             	cmp    $0x20,%eax
80107ac6:	75 28                	jne    80107af0 <trap+0x41e>
80107ac8:	8b 0d 60 7c 11 80    	mov    0x80117c60,%ecx
80107ace:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107ad3:	89 c8                	mov    %ecx,%eax
80107ad5:	f7 e2                	mul    %edx
80107ad7:	c1 ea 03             	shr    $0x3,%edx
80107ada:	89 d0                	mov    %edx,%eax
80107adc:	c1 e0 02             	shl    $0x2,%eax
80107adf:	01 d0                	add    %edx,%eax
80107ae1:	01 c0                	add    %eax,%eax
80107ae3:	29 c1                	sub    %eax,%ecx
80107ae5:	89 ca                	mov    %ecx,%edx
80107ae7:	85 d2                	test   %edx,%edx
80107ae9:	75 05                	jne    80107af0 <trap+0x41e>
    calculateaging();
80107aeb:	e8 88 cd ff ff       	call   80104878 <calculateaging>


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107af0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107af6:	85 c0                	test   %eax,%eax
80107af8:	74 27                	je     80107b21 <trap+0x44f>
80107afa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107b00:	8b 40 24             	mov    0x24(%eax),%eax
80107b03:	85 c0                	test   %eax,%eax
80107b05:	74 1a                	je     80107b21 <trap+0x44f>
80107b07:	8b 45 08             	mov    0x8(%ebp),%eax
80107b0a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107b0e:	0f b7 c0             	movzwl %ax,%eax
80107b11:	83 e0 03             	and    $0x3,%eax
80107b14:	83 f8 03             	cmp    $0x3,%eax
80107b17:	75 08                	jne    80107b21 <trap+0x44f>
    exit();
80107b19:	e8 14 d4 ff ff       	call   80104f32 <exit>
80107b1e:	eb 01                	jmp    80107b21 <trap+0x44f>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107b20:	90                   	nop


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107b24:	5b                   	pop    %ebx
80107b25:	5e                   	pop    %esi
80107b26:	5f                   	pop    %edi
80107b27:	5d                   	pop    %ebp
80107b28:	c3                   	ret    

80107b29 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107b29:	55                   	push   %ebp
80107b2a:	89 e5                	mov    %esp,%ebp
80107b2c:	83 ec 14             	sub    $0x14,%esp
80107b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b32:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107b36:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107b3a:	89 c2                	mov    %eax,%edx
80107b3c:	ec                   	in     (%dx),%al
80107b3d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107b40:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107b44:	c9                   	leave  
80107b45:	c3                   	ret    

80107b46 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107b46:	55                   	push   %ebp
80107b47:	89 e5                	mov    %esp,%ebp
80107b49:	83 ec 08             	sub    $0x8,%esp
80107b4c:	8b 55 08             	mov    0x8(%ebp),%edx
80107b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b52:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107b56:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107b59:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107b5d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107b61:	ee                   	out    %al,(%dx)
}
80107b62:	90                   	nop
80107b63:	c9                   	leave  
80107b64:	c3                   	ret    

80107b65 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107b65:	55                   	push   %ebp
80107b66:	89 e5                	mov    %esp,%ebp
80107b68:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107b6b:	6a 00                	push   $0x0
80107b6d:	68 fa 03 00 00       	push   $0x3fa
80107b72:	e8 cf ff ff ff       	call   80107b46 <outb>
80107b77:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107b7a:	68 80 00 00 00       	push   $0x80
80107b7f:	68 fb 03 00 00       	push   $0x3fb
80107b84:	e8 bd ff ff ff       	call   80107b46 <outb>
80107b89:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107b8c:	6a 0c                	push   $0xc
80107b8e:	68 f8 03 00 00       	push   $0x3f8
80107b93:	e8 ae ff ff ff       	call   80107b46 <outb>
80107b98:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107b9b:	6a 00                	push   $0x0
80107b9d:	68 f9 03 00 00       	push   $0x3f9
80107ba2:	e8 9f ff ff ff       	call   80107b46 <outb>
80107ba7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107baa:	6a 03                	push   $0x3
80107bac:	68 fb 03 00 00       	push   $0x3fb
80107bb1:	e8 90 ff ff ff       	call   80107b46 <outb>
80107bb6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107bb9:	6a 00                	push   $0x0
80107bbb:	68 fc 03 00 00       	push   $0x3fc
80107bc0:	e8 81 ff ff ff       	call   80107b46 <outb>
80107bc5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107bc8:	6a 01                	push   $0x1
80107bca:	68 f9 03 00 00       	push   $0x3f9
80107bcf:	e8 72 ff ff ff       	call   80107b46 <outb>
80107bd4:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107bd7:	68 fd 03 00 00       	push   $0x3fd
80107bdc:	e8 48 ff ff ff       	call   80107b29 <inb>
80107be1:	83 c4 04             	add    $0x4,%esp
80107be4:	3c ff                	cmp    $0xff,%al
80107be6:	74 6e                	je     80107c56 <uartinit+0xf1>
    return;
  uart = 1;
80107be8:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107bef:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107bf2:	68 fa 03 00 00       	push   $0x3fa
80107bf7:	e8 2d ff ff ff       	call   80107b29 <inb>
80107bfc:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107bff:	68 f8 03 00 00       	push   $0x3f8
80107c04:	e8 20 ff ff ff       	call   80107b29 <inb>
80107c09:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107c0c:	83 ec 0c             	sub    $0xc,%esp
80107c0f:	6a 04                	push   $0x4
80107c11:	e8 92 c5 ff ff       	call   801041a8 <picenable>
80107c16:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107c19:	83 ec 08             	sub    $0x8,%esp
80107c1c:	6a 00                	push   $0x0
80107c1e:	6a 04                	push   $0x4
80107c20:	e8 77 ae ff ff       	call   80102a9c <ioapicenable>
80107c25:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107c28:	c7 45 f4 84 9d 10 80 	movl   $0x80109d84,-0xc(%ebp)
80107c2f:	eb 19                	jmp    80107c4a <uartinit+0xe5>
    uartputc(*p);
80107c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c34:	0f b6 00             	movzbl (%eax),%eax
80107c37:	0f be c0             	movsbl %al,%eax
80107c3a:	83 ec 0c             	sub    $0xc,%esp
80107c3d:	50                   	push   %eax
80107c3e:	e8 16 00 00 00       	call   80107c59 <uartputc>
80107c43:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107c46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4d:	0f b6 00             	movzbl (%eax),%eax
80107c50:	84 c0                	test   %al,%al
80107c52:	75 dd                	jne    80107c31 <uartinit+0xcc>
80107c54:	eb 01                	jmp    80107c57 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107c56:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107c57:	c9                   	leave  
80107c58:	c3                   	ret    

80107c59 <uartputc>:

void
uartputc(int c)
{
80107c59:	55                   	push   %ebp
80107c5a:	89 e5                	mov    %esp,%ebp
80107c5c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107c5f:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107c64:	85 c0                	test   %eax,%eax
80107c66:	74 53                	je     80107cbb <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c6f:	eb 11                	jmp    80107c82 <uartputc+0x29>
    microdelay(10);
80107c71:	83 ec 0c             	sub    $0xc,%esp
80107c74:	6a 0a                	push   $0xa
80107c76:	e8 87 b3 ff ff       	call   80103002 <microdelay>
80107c7b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107c7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107c82:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107c86:	7f 1a                	jg     80107ca2 <uartputc+0x49>
80107c88:	83 ec 0c             	sub    $0xc,%esp
80107c8b:	68 fd 03 00 00       	push   $0x3fd
80107c90:	e8 94 fe ff ff       	call   80107b29 <inb>
80107c95:	83 c4 10             	add    $0x10,%esp
80107c98:	0f b6 c0             	movzbl %al,%eax
80107c9b:	83 e0 20             	and    $0x20,%eax
80107c9e:	85 c0                	test   %eax,%eax
80107ca0:	74 cf                	je     80107c71 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca5:	0f b6 c0             	movzbl %al,%eax
80107ca8:	83 ec 08             	sub    $0x8,%esp
80107cab:	50                   	push   %eax
80107cac:	68 f8 03 00 00       	push   $0x3f8
80107cb1:	e8 90 fe ff ff       	call   80107b46 <outb>
80107cb6:	83 c4 10             	add    $0x10,%esp
80107cb9:	eb 01                	jmp    80107cbc <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107cbb:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107cbc:	c9                   	leave  
80107cbd:	c3                   	ret    

80107cbe <uartgetc>:

static int
uartgetc(void)
{
80107cbe:	55                   	push   %ebp
80107cbf:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107cc1:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107cc6:	85 c0                	test   %eax,%eax
80107cc8:	75 07                	jne    80107cd1 <uartgetc+0x13>
    return -1;
80107cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ccf:	eb 2e                	jmp    80107cff <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107cd1:	68 fd 03 00 00       	push   $0x3fd
80107cd6:	e8 4e fe ff ff       	call   80107b29 <inb>
80107cdb:	83 c4 04             	add    $0x4,%esp
80107cde:	0f b6 c0             	movzbl %al,%eax
80107ce1:	83 e0 01             	and    $0x1,%eax
80107ce4:	85 c0                	test   %eax,%eax
80107ce6:	75 07                	jne    80107cef <uartgetc+0x31>
    return -1;
80107ce8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ced:	eb 10                	jmp    80107cff <uartgetc+0x41>
  return inb(COM1+0);
80107cef:	68 f8 03 00 00       	push   $0x3f8
80107cf4:	e8 30 fe ff ff       	call   80107b29 <inb>
80107cf9:	83 c4 04             	add    $0x4,%esp
80107cfc:	0f b6 c0             	movzbl %al,%eax
}
80107cff:	c9                   	leave  
80107d00:	c3                   	ret    

80107d01 <uartintr>:

void
uartintr(void)
{
80107d01:	55                   	push   %ebp
80107d02:	89 e5                	mov    %esp,%ebp
80107d04:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107d07:	83 ec 0c             	sub    $0xc,%esp
80107d0a:	68 be 7c 10 80       	push   $0x80107cbe
80107d0f:	e8 c9 8a ff ff       	call   801007dd <consoleintr>
80107d14:	83 c4 10             	add    $0x10,%esp
}
80107d17:	90                   	nop
80107d18:	c9                   	leave  
80107d19:	c3                   	ret    

80107d1a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $0
80107d1c:	6a 00                	push   $0x0
  jmp alltraps
80107d1e:	e9 1f f7 ff ff       	jmp    80107442 <alltraps>

80107d23 <vector1>:
.globl vector1
vector1:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $1
80107d25:	6a 01                	push   $0x1
  jmp alltraps
80107d27:	e9 16 f7 ff ff       	jmp    80107442 <alltraps>

80107d2c <vector2>:
.globl vector2
vector2:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $2
80107d2e:	6a 02                	push   $0x2
  jmp alltraps
80107d30:	e9 0d f7 ff ff       	jmp    80107442 <alltraps>

80107d35 <vector3>:
.globl vector3
vector3:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $3
80107d37:	6a 03                	push   $0x3
  jmp alltraps
80107d39:	e9 04 f7 ff ff       	jmp    80107442 <alltraps>

80107d3e <vector4>:
.globl vector4
vector4:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $4
80107d40:	6a 04                	push   $0x4
  jmp alltraps
80107d42:	e9 fb f6 ff ff       	jmp    80107442 <alltraps>

80107d47 <vector5>:
.globl vector5
vector5:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $5
80107d49:	6a 05                	push   $0x5
  jmp alltraps
80107d4b:	e9 f2 f6 ff ff       	jmp    80107442 <alltraps>

80107d50 <vector6>:
.globl vector6
vector6:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $6
80107d52:	6a 06                	push   $0x6
  jmp alltraps
80107d54:	e9 e9 f6 ff ff       	jmp    80107442 <alltraps>

80107d59 <vector7>:
.globl vector7
vector7:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $7
80107d5b:	6a 07                	push   $0x7
  jmp alltraps
80107d5d:	e9 e0 f6 ff ff       	jmp    80107442 <alltraps>

80107d62 <vector8>:
.globl vector8
vector8:
  pushl $8
80107d62:	6a 08                	push   $0x8
  jmp alltraps
80107d64:	e9 d9 f6 ff ff       	jmp    80107442 <alltraps>

80107d69 <vector9>:
.globl vector9
vector9:
  pushl $0
80107d69:	6a 00                	push   $0x0
  pushl $9
80107d6b:	6a 09                	push   $0x9
  jmp alltraps
80107d6d:	e9 d0 f6 ff ff       	jmp    80107442 <alltraps>

80107d72 <vector10>:
.globl vector10
vector10:
  pushl $10
80107d72:	6a 0a                	push   $0xa
  jmp alltraps
80107d74:	e9 c9 f6 ff ff       	jmp    80107442 <alltraps>

80107d79 <vector11>:
.globl vector11
vector11:
  pushl $11
80107d79:	6a 0b                	push   $0xb
  jmp alltraps
80107d7b:	e9 c2 f6 ff ff       	jmp    80107442 <alltraps>

80107d80 <vector12>:
.globl vector12
vector12:
  pushl $12
80107d80:	6a 0c                	push   $0xc
  jmp alltraps
80107d82:	e9 bb f6 ff ff       	jmp    80107442 <alltraps>

80107d87 <vector13>:
.globl vector13
vector13:
  pushl $13
80107d87:	6a 0d                	push   $0xd
  jmp alltraps
80107d89:	e9 b4 f6 ff ff       	jmp    80107442 <alltraps>

80107d8e <vector14>:
.globl vector14
vector14:
  pushl $14
80107d8e:	6a 0e                	push   $0xe
  jmp alltraps
80107d90:	e9 ad f6 ff ff       	jmp    80107442 <alltraps>

80107d95 <vector15>:
.globl vector15
vector15:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $15
80107d97:	6a 0f                	push   $0xf
  jmp alltraps
80107d99:	e9 a4 f6 ff ff       	jmp    80107442 <alltraps>

80107d9e <vector16>:
.globl vector16
vector16:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $16
80107da0:	6a 10                	push   $0x10
  jmp alltraps
80107da2:	e9 9b f6 ff ff       	jmp    80107442 <alltraps>

80107da7 <vector17>:
.globl vector17
vector17:
  pushl $17
80107da7:	6a 11                	push   $0x11
  jmp alltraps
80107da9:	e9 94 f6 ff ff       	jmp    80107442 <alltraps>

80107dae <vector18>:
.globl vector18
vector18:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $18
80107db0:	6a 12                	push   $0x12
  jmp alltraps
80107db2:	e9 8b f6 ff ff       	jmp    80107442 <alltraps>

80107db7 <vector19>:
.globl vector19
vector19:
  pushl $0
80107db7:	6a 00                	push   $0x0
  pushl $19
80107db9:	6a 13                	push   $0x13
  jmp alltraps
80107dbb:	e9 82 f6 ff ff       	jmp    80107442 <alltraps>

80107dc0 <vector20>:
.globl vector20
vector20:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $20
80107dc2:	6a 14                	push   $0x14
  jmp alltraps
80107dc4:	e9 79 f6 ff ff       	jmp    80107442 <alltraps>

80107dc9 <vector21>:
.globl vector21
vector21:
  pushl $0
80107dc9:	6a 00                	push   $0x0
  pushl $21
80107dcb:	6a 15                	push   $0x15
  jmp alltraps
80107dcd:	e9 70 f6 ff ff       	jmp    80107442 <alltraps>

80107dd2 <vector22>:
.globl vector22
vector22:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $22
80107dd4:	6a 16                	push   $0x16
  jmp alltraps
80107dd6:	e9 67 f6 ff ff       	jmp    80107442 <alltraps>

80107ddb <vector23>:
.globl vector23
vector23:
  pushl $0
80107ddb:	6a 00                	push   $0x0
  pushl $23
80107ddd:	6a 17                	push   $0x17
  jmp alltraps
80107ddf:	e9 5e f6 ff ff       	jmp    80107442 <alltraps>

80107de4 <vector24>:
.globl vector24
vector24:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $24
80107de6:	6a 18                	push   $0x18
  jmp alltraps
80107de8:	e9 55 f6 ff ff       	jmp    80107442 <alltraps>

80107ded <vector25>:
.globl vector25
vector25:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $25
80107def:	6a 19                	push   $0x19
  jmp alltraps
80107df1:	e9 4c f6 ff ff       	jmp    80107442 <alltraps>

80107df6 <vector26>:
.globl vector26
vector26:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $26
80107df8:	6a 1a                	push   $0x1a
  jmp alltraps
80107dfa:	e9 43 f6 ff ff       	jmp    80107442 <alltraps>

80107dff <vector27>:
.globl vector27
vector27:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $27
80107e01:	6a 1b                	push   $0x1b
  jmp alltraps
80107e03:	e9 3a f6 ff ff       	jmp    80107442 <alltraps>

80107e08 <vector28>:
.globl vector28
vector28:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $28
80107e0a:	6a 1c                	push   $0x1c
  jmp alltraps
80107e0c:	e9 31 f6 ff ff       	jmp    80107442 <alltraps>

80107e11 <vector29>:
.globl vector29
vector29:
  pushl $0
80107e11:	6a 00                	push   $0x0
  pushl $29
80107e13:	6a 1d                	push   $0x1d
  jmp alltraps
80107e15:	e9 28 f6 ff ff       	jmp    80107442 <alltraps>

80107e1a <vector30>:
.globl vector30
vector30:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $30
80107e1c:	6a 1e                	push   $0x1e
  jmp alltraps
80107e1e:	e9 1f f6 ff ff       	jmp    80107442 <alltraps>

80107e23 <vector31>:
.globl vector31
vector31:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $31
80107e25:	6a 1f                	push   $0x1f
  jmp alltraps
80107e27:	e9 16 f6 ff ff       	jmp    80107442 <alltraps>

80107e2c <vector32>:
.globl vector32
vector32:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $32
80107e2e:	6a 20                	push   $0x20
  jmp alltraps
80107e30:	e9 0d f6 ff ff       	jmp    80107442 <alltraps>

80107e35 <vector33>:
.globl vector33
vector33:
  pushl $0
80107e35:	6a 00                	push   $0x0
  pushl $33
80107e37:	6a 21                	push   $0x21
  jmp alltraps
80107e39:	e9 04 f6 ff ff       	jmp    80107442 <alltraps>

80107e3e <vector34>:
.globl vector34
vector34:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $34
80107e40:	6a 22                	push   $0x22
  jmp alltraps
80107e42:	e9 fb f5 ff ff       	jmp    80107442 <alltraps>

80107e47 <vector35>:
.globl vector35
vector35:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $35
80107e49:	6a 23                	push   $0x23
  jmp alltraps
80107e4b:	e9 f2 f5 ff ff       	jmp    80107442 <alltraps>

80107e50 <vector36>:
.globl vector36
vector36:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $36
80107e52:	6a 24                	push   $0x24
  jmp alltraps
80107e54:	e9 e9 f5 ff ff       	jmp    80107442 <alltraps>

80107e59 <vector37>:
.globl vector37
vector37:
  pushl $0
80107e59:	6a 00                	push   $0x0
  pushl $37
80107e5b:	6a 25                	push   $0x25
  jmp alltraps
80107e5d:	e9 e0 f5 ff ff       	jmp    80107442 <alltraps>

80107e62 <vector38>:
.globl vector38
vector38:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $38
80107e64:	6a 26                	push   $0x26
  jmp alltraps
80107e66:	e9 d7 f5 ff ff       	jmp    80107442 <alltraps>

80107e6b <vector39>:
.globl vector39
vector39:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $39
80107e6d:	6a 27                	push   $0x27
  jmp alltraps
80107e6f:	e9 ce f5 ff ff       	jmp    80107442 <alltraps>

80107e74 <vector40>:
.globl vector40
vector40:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $40
80107e76:	6a 28                	push   $0x28
  jmp alltraps
80107e78:	e9 c5 f5 ff ff       	jmp    80107442 <alltraps>

80107e7d <vector41>:
.globl vector41
vector41:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $41
80107e7f:	6a 29                	push   $0x29
  jmp alltraps
80107e81:	e9 bc f5 ff ff       	jmp    80107442 <alltraps>

80107e86 <vector42>:
.globl vector42
vector42:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $42
80107e88:	6a 2a                	push   $0x2a
  jmp alltraps
80107e8a:	e9 b3 f5 ff ff       	jmp    80107442 <alltraps>

80107e8f <vector43>:
.globl vector43
vector43:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $43
80107e91:	6a 2b                	push   $0x2b
  jmp alltraps
80107e93:	e9 aa f5 ff ff       	jmp    80107442 <alltraps>

80107e98 <vector44>:
.globl vector44
vector44:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $44
80107e9a:	6a 2c                	push   $0x2c
  jmp alltraps
80107e9c:	e9 a1 f5 ff ff       	jmp    80107442 <alltraps>

80107ea1 <vector45>:
.globl vector45
vector45:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $45
80107ea3:	6a 2d                	push   $0x2d
  jmp alltraps
80107ea5:	e9 98 f5 ff ff       	jmp    80107442 <alltraps>

80107eaa <vector46>:
.globl vector46
vector46:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $46
80107eac:	6a 2e                	push   $0x2e
  jmp alltraps
80107eae:	e9 8f f5 ff ff       	jmp    80107442 <alltraps>

80107eb3 <vector47>:
.globl vector47
vector47:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $47
80107eb5:	6a 2f                	push   $0x2f
  jmp alltraps
80107eb7:	e9 86 f5 ff ff       	jmp    80107442 <alltraps>

80107ebc <vector48>:
.globl vector48
vector48:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $48
80107ebe:	6a 30                	push   $0x30
  jmp alltraps
80107ec0:	e9 7d f5 ff ff       	jmp    80107442 <alltraps>

80107ec5 <vector49>:
.globl vector49
vector49:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $49
80107ec7:	6a 31                	push   $0x31
  jmp alltraps
80107ec9:	e9 74 f5 ff ff       	jmp    80107442 <alltraps>

80107ece <vector50>:
.globl vector50
vector50:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $50
80107ed0:	6a 32                	push   $0x32
  jmp alltraps
80107ed2:	e9 6b f5 ff ff       	jmp    80107442 <alltraps>

80107ed7 <vector51>:
.globl vector51
vector51:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $51
80107ed9:	6a 33                	push   $0x33
  jmp alltraps
80107edb:	e9 62 f5 ff ff       	jmp    80107442 <alltraps>

80107ee0 <vector52>:
.globl vector52
vector52:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $52
80107ee2:	6a 34                	push   $0x34
  jmp alltraps
80107ee4:	e9 59 f5 ff ff       	jmp    80107442 <alltraps>

80107ee9 <vector53>:
.globl vector53
vector53:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $53
80107eeb:	6a 35                	push   $0x35
  jmp alltraps
80107eed:	e9 50 f5 ff ff       	jmp    80107442 <alltraps>

80107ef2 <vector54>:
.globl vector54
vector54:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $54
80107ef4:	6a 36                	push   $0x36
  jmp alltraps
80107ef6:	e9 47 f5 ff ff       	jmp    80107442 <alltraps>

80107efb <vector55>:
.globl vector55
vector55:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $55
80107efd:	6a 37                	push   $0x37
  jmp alltraps
80107eff:	e9 3e f5 ff ff       	jmp    80107442 <alltraps>

80107f04 <vector56>:
.globl vector56
vector56:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $56
80107f06:	6a 38                	push   $0x38
  jmp alltraps
80107f08:	e9 35 f5 ff ff       	jmp    80107442 <alltraps>

80107f0d <vector57>:
.globl vector57
vector57:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $57
80107f0f:	6a 39                	push   $0x39
  jmp alltraps
80107f11:	e9 2c f5 ff ff       	jmp    80107442 <alltraps>

80107f16 <vector58>:
.globl vector58
vector58:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $58
80107f18:	6a 3a                	push   $0x3a
  jmp alltraps
80107f1a:	e9 23 f5 ff ff       	jmp    80107442 <alltraps>

80107f1f <vector59>:
.globl vector59
vector59:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $59
80107f21:	6a 3b                	push   $0x3b
  jmp alltraps
80107f23:	e9 1a f5 ff ff       	jmp    80107442 <alltraps>

80107f28 <vector60>:
.globl vector60
vector60:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $60
80107f2a:	6a 3c                	push   $0x3c
  jmp alltraps
80107f2c:	e9 11 f5 ff ff       	jmp    80107442 <alltraps>

80107f31 <vector61>:
.globl vector61
vector61:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $61
80107f33:	6a 3d                	push   $0x3d
  jmp alltraps
80107f35:	e9 08 f5 ff ff       	jmp    80107442 <alltraps>

80107f3a <vector62>:
.globl vector62
vector62:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $62
80107f3c:	6a 3e                	push   $0x3e
  jmp alltraps
80107f3e:	e9 ff f4 ff ff       	jmp    80107442 <alltraps>

80107f43 <vector63>:
.globl vector63
vector63:
  pushl $0
80107f43:	6a 00                	push   $0x0
  pushl $63
80107f45:	6a 3f                	push   $0x3f
  jmp alltraps
80107f47:	e9 f6 f4 ff ff       	jmp    80107442 <alltraps>

80107f4c <vector64>:
.globl vector64
vector64:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $64
80107f4e:	6a 40                	push   $0x40
  jmp alltraps
80107f50:	e9 ed f4 ff ff       	jmp    80107442 <alltraps>

80107f55 <vector65>:
.globl vector65
vector65:
  pushl $0
80107f55:	6a 00                	push   $0x0
  pushl $65
80107f57:	6a 41                	push   $0x41
  jmp alltraps
80107f59:	e9 e4 f4 ff ff       	jmp    80107442 <alltraps>

80107f5e <vector66>:
.globl vector66
vector66:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $66
80107f60:	6a 42                	push   $0x42
  jmp alltraps
80107f62:	e9 db f4 ff ff       	jmp    80107442 <alltraps>

80107f67 <vector67>:
.globl vector67
vector67:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $67
80107f69:	6a 43                	push   $0x43
  jmp alltraps
80107f6b:	e9 d2 f4 ff ff       	jmp    80107442 <alltraps>

80107f70 <vector68>:
.globl vector68
vector68:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $68
80107f72:	6a 44                	push   $0x44
  jmp alltraps
80107f74:	e9 c9 f4 ff ff       	jmp    80107442 <alltraps>

80107f79 <vector69>:
.globl vector69
vector69:
  pushl $0
80107f79:	6a 00                	push   $0x0
  pushl $69
80107f7b:	6a 45                	push   $0x45
  jmp alltraps
80107f7d:	e9 c0 f4 ff ff       	jmp    80107442 <alltraps>

80107f82 <vector70>:
.globl vector70
vector70:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $70
80107f84:	6a 46                	push   $0x46
  jmp alltraps
80107f86:	e9 b7 f4 ff ff       	jmp    80107442 <alltraps>

80107f8b <vector71>:
.globl vector71
vector71:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $71
80107f8d:	6a 47                	push   $0x47
  jmp alltraps
80107f8f:	e9 ae f4 ff ff       	jmp    80107442 <alltraps>

80107f94 <vector72>:
.globl vector72
vector72:
  pushl $0
80107f94:	6a 00                	push   $0x0
  pushl $72
80107f96:	6a 48                	push   $0x48
  jmp alltraps
80107f98:	e9 a5 f4 ff ff       	jmp    80107442 <alltraps>

80107f9d <vector73>:
.globl vector73
vector73:
  pushl $0
80107f9d:	6a 00                	push   $0x0
  pushl $73
80107f9f:	6a 49                	push   $0x49
  jmp alltraps
80107fa1:	e9 9c f4 ff ff       	jmp    80107442 <alltraps>

80107fa6 <vector74>:
.globl vector74
vector74:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $74
80107fa8:	6a 4a                	push   $0x4a
  jmp alltraps
80107faa:	e9 93 f4 ff ff       	jmp    80107442 <alltraps>

80107faf <vector75>:
.globl vector75
vector75:
  pushl $0
80107faf:	6a 00                	push   $0x0
  pushl $75
80107fb1:	6a 4b                	push   $0x4b
  jmp alltraps
80107fb3:	e9 8a f4 ff ff       	jmp    80107442 <alltraps>

80107fb8 <vector76>:
.globl vector76
vector76:
  pushl $0
80107fb8:	6a 00                	push   $0x0
  pushl $76
80107fba:	6a 4c                	push   $0x4c
  jmp alltraps
80107fbc:	e9 81 f4 ff ff       	jmp    80107442 <alltraps>

80107fc1 <vector77>:
.globl vector77
vector77:
  pushl $0
80107fc1:	6a 00                	push   $0x0
  pushl $77
80107fc3:	6a 4d                	push   $0x4d
  jmp alltraps
80107fc5:	e9 78 f4 ff ff       	jmp    80107442 <alltraps>

80107fca <vector78>:
.globl vector78
vector78:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $78
80107fcc:	6a 4e                	push   $0x4e
  jmp alltraps
80107fce:	e9 6f f4 ff ff       	jmp    80107442 <alltraps>

80107fd3 <vector79>:
.globl vector79
vector79:
  pushl $0
80107fd3:	6a 00                	push   $0x0
  pushl $79
80107fd5:	6a 4f                	push   $0x4f
  jmp alltraps
80107fd7:	e9 66 f4 ff ff       	jmp    80107442 <alltraps>

80107fdc <vector80>:
.globl vector80
vector80:
  pushl $0
80107fdc:	6a 00                	push   $0x0
  pushl $80
80107fde:	6a 50                	push   $0x50
  jmp alltraps
80107fe0:	e9 5d f4 ff ff       	jmp    80107442 <alltraps>

80107fe5 <vector81>:
.globl vector81
vector81:
  pushl $0
80107fe5:	6a 00                	push   $0x0
  pushl $81
80107fe7:	6a 51                	push   $0x51
  jmp alltraps
80107fe9:	e9 54 f4 ff ff       	jmp    80107442 <alltraps>

80107fee <vector82>:
.globl vector82
vector82:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $82
80107ff0:	6a 52                	push   $0x52
  jmp alltraps
80107ff2:	e9 4b f4 ff ff       	jmp    80107442 <alltraps>

80107ff7 <vector83>:
.globl vector83
vector83:
  pushl $0
80107ff7:	6a 00                	push   $0x0
  pushl $83
80107ff9:	6a 53                	push   $0x53
  jmp alltraps
80107ffb:	e9 42 f4 ff ff       	jmp    80107442 <alltraps>

80108000 <vector84>:
.globl vector84
vector84:
  pushl $0
80108000:	6a 00                	push   $0x0
  pushl $84
80108002:	6a 54                	push   $0x54
  jmp alltraps
80108004:	e9 39 f4 ff ff       	jmp    80107442 <alltraps>

80108009 <vector85>:
.globl vector85
vector85:
  pushl $0
80108009:	6a 00                	push   $0x0
  pushl $85
8010800b:	6a 55                	push   $0x55
  jmp alltraps
8010800d:	e9 30 f4 ff ff       	jmp    80107442 <alltraps>

80108012 <vector86>:
.globl vector86
vector86:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $86
80108014:	6a 56                	push   $0x56
  jmp alltraps
80108016:	e9 27 f4 ff ff       	jmp    80107442 <alltraps>

8010801b <vector87>:
.globl vector87
vector87:
  pushl $0
8010801b:	6a 00                	push   $0x0
  pushl $87
8010801d:	6a 57                	push   $0x57
  jmp alltraps
8010801f:	e9 1e f4 ff ff       	jmp    80107442 <alltraps>

80108024 <vector88>:
.globl vector88
vector88:
  pushl $0
80108024:	6a 00                	push   $0x0
  pushl $88
80108026:	6a 58                	push   $0x58
  jmp alltraps
80108028:	e9 15 f4 ff ff       	jmp    80107442 <alltraps>

8010802d <vector89>:
.globl vector89
vector89:
  pushl $0
8010802d:	6a 00                	push   $0x0
  pushl $89
8010802f:	6a 59                	push   $0x59
  jmp alltraps
80108031:	e9 0c f4 ff ff       	jmp    80107442 <alltraps>

80108036 <vector90>:
.globl vector90
vector90:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $90
80108038:	6a 5a                	push   $0x5a
  jmp alltraps
8010803a:	e9 03 f4 ff ff       	jmp    80107442 <alltraps>

8010803f <vector91>:
.globl vector91
vector91:
  pushl $0
8010803f:	6a 00                	push   $0x0
  pushl $91
80108041:	6a 5b                	push   $0x5b
  jmp alltraps
80108043:	e9 fa f3 ff ff       	jmp    80107442 <alltraps>

80108048 <vector92>:
.globl vector92
vector92:
  pushl $0
80108048:	6a 00                	push   $0x0
  pushl $92
8010804a:	6a 5c                	push   $0x5c
  jmp alltraps
8010804c:	e9 f1 f3 ff ff       	jmp    80107442 <alltraps>

80108051 <vector93>:
.globl vector93
vector93:
  pushl $0
80108051:	6a 00                	push   $0x0
  pushl $93
80108053:	6a 5d                	push   $0x5d
  jmp alltraps
80108055:	e9 e8 f3 ff ff       	jmp    80107442 <alltraps>

8010805a <vector94>:
.globl vector94
vector94:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $94
8010805c:	6a 5e                	push   $0x5e
  jmp alltraps
8010805e:	e9 df f3 ff ff       	jmp    80107442 <alltraps>

80108063 <vector95>:
.globl vector95
vector95:
  pushl $0
80108063:	6a 00                	push   $0x0
  pushl $95
80108065:	6a 5f                	push   $0x5f
  jmp alltraps
80108067:	e9 d6 f3 ff ff       	jmp    80107442 <alltraps>

8010806c <vector96>:
.globl vector96
vector96:
  pushl $0
8010806c:	6a 00                	push   $0x0
  pushl $96
8010806e:	6a 60                	push   $0x60
  jmp alltraps
80108070:	e9 cd f3 ff ff       	jmp    80107442 <alltraps>

80108075 <vector97>:
.globl vector97
vector97:
  pushl $0
80108075:	6a 00                	push   $0x0
  pushl $97
80108077:	6a 61                	push   $0x61
  jmp alltraps
80108079:	e9 c4 f3 ff ff       	jmp    80107442 <alltraps>

8010807e <vector98>:
.globl vector98
vector98:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $98
80108080:	6a 62                	push   $0x62
  jmp alltraps
80108082:	e9 bb f3 ff ff       	jmp    80107442 <alltraps>

80108087 <vector99>:
.globl vector99
vector99:
  pushl $0
80108087:	6a 00                	push   $0x0
  pushl $99
80108089:	6a 63                	push   $0x63
  jmp alltraps
8010808b:	e9 b2 f3 ff ff       	jmp    80107442 <alltraps>

80108090 <vector100>:
.globl vector100
vector100:
  pushl $0
80108090:	6a 00                	push   $0x0
  pushl $100
80108092:	6a 64                	push   $0x64
  jmp alltraps
80108094:	e9 a9 f3 ff ff       	jmp    80107442 <alltraps>

80108099 <vector101>:
.globl vector101
vector101:
  pushl $0
80108099:	6a 00                	push   $0x0
  pushl $101
8010809b:	6a 65                	push   $0x65
  jmp alltraps
8010809d:	e9 a0 f3 ff ff       	jmp    80107442 <alltraps>

801080a2 <vector102>:
.globl vector102
vector102:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $102
801080a4:	6a 66                	push   $0x66
  jmp alltraps
801080a6:	e9 97 f3 ff ff       	jmp    80107442 <alltraps>

801080ab <vector103>:
.globl vector103
vector103:
  pushl $0
801080ab:	6a 00                	push   $0x0
  pushl $103
801080ad:	6a 67                	push   $0x67
  jmp alltraps
801080af:	e9 8e f3 ff ff       	jmp    80107442 <alltraps>

801080b4 <vector104>:
.globl vector104
vector104:
  pushl $0
801080b4:	6a 00                	push   $0x0
  pushl $104
801080b6:	6a 68                	push   $0x68
  jmp alltraps
801080b8:	e9 85 f3 ff ff       	jmp    80107442 <alltraps>

801080bd <vector105>:
.globl vector105
vector105:
  pushl $0
801080bd:	6a 00                	push   $0x0
  pushl $105
801080bf:	6a 69                	push   $0x69
  jmp alltraps
801080c1:	e9 7c f3 ff ff       	jmp    80107442 <alltraps>

801080c6 <vector106>:
.globl vector106
vector106:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $106
801080c8:	6a 6a                	push   $0x6a
  jmp alltraps
801080ca:	e9 73 f3 ff ff       	jmp    80107442 <alltraps>

801080cf <vector107>:
.globl vector107
vector107:
  pushl $0
801080cf:	6a 00                	push   $0x0
  pushl $107
801080d1:	6a 6b                	push   $0x6b
  jmp alltraps
801080d3:	e9 6a f3 ff ff       	jmp    80107442 <alltraps>

801080d8 <vector108>:
.globl vector108
vector108:
  pushl $0
801080d8:	6a 00                	push   $0x0
  pushl $108
801080da:	6a 6c                	push   $0x6c
  jmp alltraps
801080dc:	e9 61 f3 ff ff       	jmp    80107442 <alltraps>

801080e1 <vector109>:
.globl vector109
vector109:
  pushl $0
801080e1:	6a 00                	push   $0x0
  pushl $109
801080e3:	6a 6d                	push   $0x6d
  jmp alltraps
801080e5:	e9 58 f3 ff ff       	jmp    80107442 <alltraps>

801080ea <vector110>:
.globl vector110
vector110:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $110
801080ec:	6a 6e                	push   $0x6e
  jmp alltraps
801080ee:	e9 4f f3 ff ff       	jmp    80107442 <alltraps>

801080f3 <vector111>:
.globl vector111
vector111:
  pushl $0
801080f3:	6a 00                	push   $0x0
  pushl $111
801080f5:	6a 6f                	push   $0x6f
  jmp alltraps
801080f7:	e9 46 f3 ff ff       	jmp    80107442 <alltraps>

801080fc <vector112>:
.globl vector112
vector112:
  pushl $0
801080fc:	6a 00                	push   $0x0
  pushl $112
801080fe:	6a 70                	push   $0x70
  jmp alltraps
80108100:	e9 3d f3 ff ff       	jmp    80107442 <alltraps>

80108105 <vector113>:
.globl vector113
vector113:
  pushl $0
80108105:	6a 00                	push   $0x0
  pushl $113
80108107:	6a 71                	push   $0x71
  jmp alltraps
80108109:	e9 34 f3 ff ff       	jmp    80107442 <alltraps>

8010810e <vector114>:
.globl vector114
vector114:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $114
80108110:	6a 72                	push   $0x72
  jmp alltraps
80108112:	e9 2b f3 ff ff       	jmp    80107442 <alltraps>

80108117 <vector115>:
.globl vector115
vector115:
  pushl $0
80108117:	6a 00                	push   $0x0
  pushl $115
80108119:	6a 73                	push   $0x73
  jmp alltraps
8010811b:	e9 22 f3 ff ff       	jmp    80107442 <alltraps>

80108120 <vector116>:
.globl vector116
vector116:
  pushl $0
80108120:	6a 00                	push   $0x0
  pushl $116
80108122:	6a 74                	push   $0x74
  jmp alltraps
80108124:	e9 19 f3 ff ff       	jmp    80107442 <alltraps>

80108129 <vector117>:
.globl vector117
vector117:
  pushl $0
80108129:	6a 00                	push   $0x0
  pushl $117
8010812b:	6a 75                	push   $0x75
  jmp alltraps
8010812d:	e9 10 f3 ff ff       	jmp    80107442 <alltraps>

80108132 <vector118>:
.globl vector118
vector118:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $118
80108134:	6a 76                	push   $0x76
  jmp alltraps
80108136:	e9 07 f3 ff ff       	jmp    80107442 <alltraps>

8010813b <vector119>:
.globl vector119
vector119:
  pushl $0
8010813b:	6a 00                	push   $0x0
  pushl $119
8010813d:	6a 77                	push   $0x77
  jmp alltraps
8010813f:	e9 fe f2 ff ff       	jmp    80107442 <alltraps>

80108144 <vector120>:
.globl vector120
vector120:
  pushl $0
80108144:	6a 00                	push   $0x0
  pushl $120
80108146:	6a 78                	push   $0x78
  jmp alltraps
80108148:	e9 f5 f2 ff ff       	jmp    80107442 <alltraps>

8010814d <vector121>:
.globl vector121
vector121:
  pushl $0
8010814d:	6a 00                	push   $0x0
  pushl $121
8010814f:	6a 79                	push   $0x79
  jmp alltraps
80108151:	e9 ec f2 ff ff       	jmp    80107442 <alltraps>

80108156 <vector122>:
.globl vector122
vector122:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $122
80108158:	6a 7a                	push   $0x7a
  jmp alltraps
8010815a:	e9 e3 f2 ff ff       	jmp    80107442 <alltraps>

8010815f <vector123>:
.globl vector123
vector123:
  pushl $0
8010815f:	6a 00                	push   $0x0
  pushl $123
80108161:	6a 7b                	push   $0x7b
  jmp alltraps
80108163:	e9 da f2 ff ff       	jmp    80107442 <alltraps>

80108168 <vector124>:
.globl vector124
vector124:
  pushl $0
80108168:	6a 00                	push   $0x0
  pushl $124
8010816a:	6a 7c                	push   $0x7c
  jmp alltraps
8010816c:	e9 d1 f2 ff ff       	jmp    80107442 <alltraps>

80108171 <vector125>:
.globl vector125
vector125:
  pushl $0
80108171:	6a 00                	push   $0x0
  pushl $125
80108173:	6a 7d                	push   $0x7d
  jmp alltraps
80108175:	e9 c8 f2 ff ff       	jmp    80107442 <alltraps>

8010817a <vector126>:
.globl vector126
vector126:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $126
8010817c:	6a 7e                	push   $0x7e
  jmp alltraps
8010817e:	e9 bf f2 ff ff       	jmp    80107442 <alltraps>

80108183 <vector127>:
.globl vector127
vector127:
  pushl $0
80108183:	6a 00                	push   $0x0
  pushl $127
80108185:	6a 7f                	push   $0x7f
  jmp alltraps
80108187:	e9 b6 f2 ff ff       	jmp    80107442 <alltraps>

8010818c <vector128>:
.globl vector128
vector128:
  pushl $0
8010818c:	6a 00                	push   $0x0
  pushl $128
8010818e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108193:	e9 aa f2 ff ff       	jmp    80107442 <alltraps>

80108198 <vector129>:
.globl vector129
vector129:
  pushl $0
80108198:	6a 00                	push   $0x0
  pushl $129
8010819a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010819f:	e9 9e f2 ff ff       	jmp    80107442 <alltraps>

801081a4 <vector130>:
.globl vector130
vector130:
  pushl $0
801081a4:	6a 00                	push   $0x0
  pushl $130
801081a6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801081ab:	e9 92 f2 ff ff       	jmp    80107442 <alltraps>

801081b0 <vector131>:
.globl vector131
vector131:
  pushl $0
801081b0:	6a 00                	push   $0x0
  pushl $131
801081b2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801081b7:	e9 86 f2 ff ff       	jmp    80107442 <alltraps>

801081bc <vector132>:
.globl vector132
vector132:
  pushl $0
801081bc:	6a 00                	push   $0x0
  pushl $132
801081be:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801081c3:	e9 7a f2 ff ff       	jmp    80107442 <alltraps>

801081c8 <vector133>:
.globl vector133
vector133:
  pushl $0
801081c8:	6a 00                	push   $0x0
  pushl $133
801081ca:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801081cf:	e9 6e f2 ff ff       	jmp    80107442 <alltraps>

801081d4 <vector134>:
.globl vector134
vector134:
  pushl $0
801081d4:	6a 00                	push   $0x0
  pushl $134
801081d6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801081db:	e9 62 f2 ff ff       	jmp    80107442 <alltraps>

801081e0 <vector135>:
.globl vector135
vector135:
  pushl $0
801081e0:	6a 00                	push   $0x0
  pushl $135
801081e2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801081e7:	e9 56 f2 ff ff       	jmp    80107442 <alltraps>

801081ec <vector136>:
.globl vector136
vector136:
  pushl $0
801081ec:	6a 00                	push   $0x0
  pushl $136
801081ee:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801081f3:	e9 4a f2 ff ff       	jmp    80107442 <alltraps>

801081f8 <vector137>:
.globl vector137
vector137:
  pushl $0
801081f8:	6a 00                	push   $0x0
  pushl $137
801081fa:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801081ff:	e9 3e f2 ff ff       	jmp    80107442 <alltraps>

80108204 <vector138>:
.globl vector138
vector138:
  pushl $0
80108204:	6a 00                	push   $0x0
  pushl $138
80108206:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010820b:	e9 32 f2 ff ff       	jmp    80107442 <alltraps>

80108210 <vector139>:
.globl vector139
vector139:
  pushl $0
80108210:	6a 00                	push   $0x0
  pushl $139
80108212:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108217:	e9 26 f2 ff ff       	jmp    80107442 <alltraps>

8010821c <vector140>:
.globl vector140
vector140:
  pushl $0
8010821c:	6a 00                	push   $0x0
  pushl $140
8010821e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108223:	e9 1a f2 ff ff       	jmp    80107442 <alltraps>

80108228 <vector141>:
.globl vector141
vector141:
  pushl $0
80108228:	6a 00                	push   $0x0
  pushl $141
8010822a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010822f:	e9 0e f2 ff ff       	jmp    80107442 <alltraps>

80108234 <vector142>:
.globl vector142
vector142:
  pushl $0
80108234:	6a 00                	push   $0x0
  pushl $142
80108236:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010823b:	e9 02 f2 ff ff       	jmp    80107442 <alltraps>

80108240 <vector143>:
.globl vector143
vector143:
  pushl $0
80108240:	6a 00                	push   $0x0
  pushl $143
80108242:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108247:	e9 f6 f1 ff ff       	jmp    80107442 <alltraps>

8010824c <vector144>:
.globl vector144
vector144:
  pushl $0
8010824c:	6a 00                	push   $0x0
  pushl $144
8010824e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108253:	e9 ea f1 ff ff       	jmp    80107442 <alltraps>

80108258 <vector145>:
.globl vector145
vector145:
  pushl $0
80108258:	6a 00                	push   $0x0
  pushl $145
8010825a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010825f:	e9 de f1 ff ff       	jmp    80107442 <alltraps>

80108264 <vector146>:
.globl vector146
vector146:
  pushl $0
80108264:	6a 00                	push   $0x0
  pushl $146
80108266:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010826b:	e9 d2 f1 ff ff       	jmp    80107442 <alltraps>

80108270 <vector147>:
.globl vector147
vector147:
  pushl $0
80108270:	6a 00                	push   $0x0
  pushl $147
80108272:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108277:	e9 c6 f1 ff ff       	jmp    80107442 <alltraps>

8010827c <vector148>:
.globl vector148
vector148:
  pushl $0
8010827c:	6a 00                	push   $0x0
  pushl $148
8010827e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108283:	e9 ba f1 ff ff       	jmp    80107442 <alltraps>

80108288 <vector149>:
.globl vector149
vector149:
  pushl $0
80108288:	6a 00                	push   $0x0
  pushl $149
8010828a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010828f:	e9 ae f1 ff ff       	jmp    80107442 <alltraps>

80108294 <vector150>:
.globl vector150
vector150:
  pushl $0
80108294:	6a 00                	push   $0x0
  pushl $150
80108296:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010829b:	e9 a2 f1 ff ff       	jmp    80107442 <alltraps>

801082a0 <vector151>:
.globl vector151
vector151:
  pushl $0
801082a0:	6a 00                	push   $0x0
  pushl $151
801082a2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801082a7:	e9 96 f1 ff ff       	jmp    80107442 <alltraps>

801082ac <vector152>:
.globl vector152
vector152:
  pushl $0
801082ac:	6a 00                	push   $0x0
  pushl $152
801082ae:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801082b3:	e9 8a f1 ff ff       	jmp    80107442 <alltraps>

801082b8 <vector153>:
.globl vector153
vector153:
  pushl $0
801082b8:	6a 00                	push   $0x0
  pushl $153
801082ba:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801082bf:	e9 7e f1 ff ff       	jmp    80107442 <alltraps>

801082c4 <vector154>:
.globl vector154
vector154:
  pushl $0
801082c4:	6a 00                	push   $0x0
  pushl $154
801082c6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801082cb:	e9 72 f1 ff ff       	jmp    80107442 <alltraps>

801082d0 <vector155>:
.globl vector155
vector155:
  pushl $0
801082d0:	6a 00                	push   $0x0
  pushl $155
801082d2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801082d7:	e9 66 f1 ff ff       	jmp    80107442 <alltraps>

801082dc <vector156>:
.globl vector156
vector156:
  pushl $0
801082dc:	6a 00                	push   $0x0
  pushl $156
801082de:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801082e3:	e9 5a f1 ff ff       	jmp    80107442 <alltraps>

801082e8 <vector157>:
.globl vector157
vector157:
  pushl $0
801082e8:	6a 00                	push   $0x0
  pushl $157
801082ea:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801082ef:	e9 4e f1 ff ff       	jmp    80107442 <alltraps>

801082f4 <vector158>:
.globl vector158
vector158:
  pushl $0
801082f4:	6a 00                	push   $0x0
  pushl $158
801082f6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801082fb:	e9 42 f1 ff ff       	jmp    80107442 <alltraps>

80108300 <vector159>:
.globl vector159
vector159:
  pushl $0
80108300:	6a 00                	push   $0x0
  pushl $159
80108302:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108307:	e9 36 f1 ff ff       	jmp    80107442 <alltraps>

8010830c <vector160>:
.globl vector160
vector160:
  pushl $0
8010830c:	6a 00                	push   $0x0
  pushl $160
8010830e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108313:	e9 2a f1 ff ff       	jmp    80107442 <alltraps>

80108318 <vector161>:
.globl vector161
vector161:
  pushl $0
80108318:	6a 00                	push   $0x0
  pushl $161
8010831a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010831f:	e9 1e f1 ff ff       	jmp    80107442 <alltraps>

80108324 <vector162>:
.globl vector162
vector162:
  pushl $0
80108324:	6a 00                	push   $0x0
  pushl $162
80108326:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010832b:	e9 12 f1 ff ff       	jmp    80107442 <alltraps>

80108330 <vector163>:
.globl vector163
vector163:
  pushl $0
80108330:	6a 00                	push   $0x0
  pushl $163
80108332:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108337:	e9 06 f1 ff ff       	jmp    80107442 <alltraps>

8010833c <vector164>:
.globl vector164
vector164:
  pushl $0
8010833c:	6a 00                	push   $0x0
  pushl $164
8010833e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108343:	e9 fa f0 ff ff       	jmp    80107442 <alltraps>

80108348 <vector165>:
.globl vector165
vector165:
  pushl $0
80108348:	6a 00                	push   $0x0
  pushl $165
8010834a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010834f:	e9 ee f0 ff ff       	jmp    80107442 <alltraps>

80108354 <vector166>:
.globl vector166
vector166:
  pushl $0
80108354:	6a 00                	push   $0x0
  pushl $166
80108356:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010835b:	e9 e2 f0 ff ff       	jmp    80107442 <alltraps>

80108360 <vector167>:
.globl vector167
vector167:
  pushl $0
80108360:	6a 00                	push   $0x0
  pushl $167
80108362:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108367:	e9 d6 f0 ff ff       	jmp    80107442 <alltraps>

8010836c <vector168>:
.globl vector168
vector168:
  pushl $0
8010836c:	6a 00                	push   $0x0
  pushl $168
8010836e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108373:	e9 ca f0 ff ff       	jmp    80107442 <alltraps>

80108378 <vector169>:
.globl vector169
vector169:
  pushl $0
80108378:	6a 00                	push   $0x0
  pushl $169
8010837a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010837f:	e9 be f0 ff ff       	jmp    80107442 <alltraps>

80108384 <vector170>:
.globl vector170
vector170:
  pushl $0
80108384:	6a 00                	push   $0x0
  pushl $170
80108386:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010838b:	e9 b2 f0 ff ff       	jmp    80107442 <alltraps>

80108390 <vector171>:
.globl vector171
vector171:
  pushl $0
80108390:	6a 00                	push   $0x0
  pushl $171
80108392:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108397:	e9 a6 f0 ff ff       	jmp    80107442 <alltraps>

8010839c <vector172>:
.globl vector172
vector172:
  pushl $0
8010839c:	6a 00                	push   $0x0
  pushl $172
8010839e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801083a3:	e9 9a f0 ff ff       	jmp    80107442 <alltraps>

801083a8 <vector173>:
.globl vector173
vector173:
  pushl $0
801083a8:	6a 00                	push   $0x0
  pushl $173
801083aa:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801083af:	e9 8e f0 ff ff       	jmp    80107442 <alltraps>

801083b4 <vector174>:
.globl vector174
vector174:
  pushl $0
801083b4:	6a 00                	push   $0x0
  pushl $174
801083b6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801083bb:	e9 82 f0 ff ff       	jmp    80107442 <alltraps>

801083c0 <vector175>:
.globl vector175
vector175:
  pushl $0
801083c0:	6a 00                	push   $0x0
  pushl $175
801083c2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801083c7:	e9 76 f0 ff ff       	jmp    80107442 <alltraps>

801083cc <vector176>:
.globl vector176
vector176:
  pushl $0
801083cc:	6a 00                	push   $0x0
  pushl $176
801083ce:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801083d3:	e9 6a f0 ff ff       	jmp    80107442 <alltraps>

801083d8 <vector177>:
.globl vector177
vector177:
  pushl $0
801083d8:	6a 00                	push   $0x0
  pushl $177
801083da:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801083df:	e9 5e f0 ff ff       	jmp    80107442 <alltraps>

801083e4 <vector178>:
.globl vector178
vector178:
  pushl $0
801083e4:	6a 00                	push   $0x0
  pushl $178
801083e6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801083eb:	e9 52 f0 ff ff       	jmp    80107442 <alltraps>

801083f0 <vector179>:
.globl vector179
vector179:
  pushl $0
801083f0:	6a 00                	push   $0x0
  pushl $179
801083f2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801083f7:	e9 46 f0 ff ff       	jmp    80107442 <alltraps>

801083fc <vector180>:
.globl vector180
vector180:
  pushl $0
801083fc:	6a 00                	push   $0x0
  pushl $180
801083fe:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108403:	e9 3a f0 ff ff       	jmp    80107442 <alltraps>

80108408 <vector181>:
.globl vector181
vector181:
  pushl $0
80108408:	6a 00                	push   $0x0
  pushl $181
8010840a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010840f:	e9 2e f0 ff ff       	jmp    80107442 <alltraps>

80108414 <vector182>:
.globl vector182
vector182:
  pushl $0
80108414:	6a 00                	push   $0x0
  pushl $182
80108416:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010841b:	e9 22 f0 ff ff       	jmp    80107442 <alltraps>

80108420 <vector183>:
.globl vector183
vector183:
  pushl $0
80108420:	6a 00                	push   $0x0
  pushl $183
80108422:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108427:	e9 16 f0 ff ff       	jmp    80107442 <alltraps>

8010842c <vector184>:
.globl vector184
vector184:
  pushl $0
8010842c:	6a 00                	push   $0x0
  pushl $184
8010842e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108433:	e9 0a f0 ff ff       	jmp    80107442 <alltraps>

80108438 <vector185>:
.globl vector185
vector185:
  pushl $0
80108438:	6a 00                	push   $0x0
  pushl $185
8010843a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010843f:	e9 fe ef ff ff       	jmp    80107442 <alltraps>

80108444 <vector186>:
.globl vector186
vector186:
  pushl $0
80108444:	6a 00                	push   $0x0
  pushl $186
80108446:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010844b:	e9 f2 ef ff ff       	jmp    80107442 <alltraps>

80108450 <vector187>:
.globl vector187
vector187:
  pushl $0
80108450:	6a 00                	push   $0x0
  pushl $187
80108452:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108457:	e9 e6 ef ff ff       	jmp    80107442 <alltraps>

8010845c <vector188>:
.globl vector188
vector188:
  pushl $0
8010845c:	6a 00                	push   $0x0
  pushl $188
8010845e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108463:	e9 da ef ff ff       	jmp    80107442 <alltraps>

80108468 <vector189>:
.globl vector189
vector189:
  pushl $0
80108468:	6a 00                	push   $0x0
  pushl $189
8010846a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010846f:	e9 ce ef ff ff       	jmp    80107442 <alltraps>

80108474 <vector190>:
.globl vector190
vector190:
  pushl $0
80108474:	6a 00                	push   $0x0
  pushl $190
80108476:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010847b:	e9 c2 ef ff ff       	jmp    80107442 <alltraps>

80108480 <vector191>:
.globl vector191
vector191:
  pushl $0
80108480:	6a 00                	push   $0x0
  pushl $191
80108482:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108487:	e9 b6 ef ff ff       	jmp    80107442 <alltraps>

8010848c <vector192>:
.globl vector192
vector192:
  pushl $0
8010848c:	6a 00                	push   $0x0
  pushl $192
8010848e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108493:	e9 aa ef ff ff       	jmp    80107442 <alltraps>

80108498 <vector193>:
.globl vector193
vector193:
  pushl $0
80108498:	6a 00                	push   $0x0
  pushl $193
8010849a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010849f:	e9 9e ef ff ff       	jmp    80107442 <alltraps>

801084a4 <vector194>:
.globl vector194
vector194:
  pushl $0
801084a4:	6a 00                	push   $0x0
  pushl $194
801084a6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801084ab:	e9 92 ef ff ff       	jmp    80107442 <alltraps>

801084b0 <vector195>:
.globl vector195
vector195:
  pushl $0
801084b0:	6a 00                	push   $0x0
  pushl $195
801084b2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801084b7:	e9 86 ef ff ff       	jmp    80107442 <alltraps>

801084bc <vector196>:
.globl vector196
vector196:
  pushl $0
801084bc:	6a 00                	push   $0x0
  pushl $196
801084be:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801084c3:	e9 7a ef ff ff       	jmp    80107442 <alltraps>

801084c8 <vector197>:
.globl vector197
vector197:
  pushl $0
801084c8:	6a 00                	push   $0x0
  pushl $197
801084ca:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801084cf:	e9 6e ef ff ff       	jmp    80107442 <alltraps>

801084d4 <vector198>:
.globl vector198
vector198:
  pushl $0
801084d4:	6a 00                	push   $0x0
  pushl $198
801084d6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801084db:	e9 62 ef ff ff       	jmp    80107442 <alltraps>

801084e0 <vector199>:
.globl vector199
vector199:
  pushl $0
801084e0:	6a 00                	push   $0x0
  pushl $199
801084e2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801084e7:	e9 56 ef ff ff       	jmp    80107442 <alltraps>

801084ec <vector200>:
.globl vector200
vector200:
  pushl $0
801084ec:	6a 00                	push   $0x0
  pushl $200
801084ee:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801084f3:	e9 4a ef ff ff       	jmp    80107442 <alltraps>

801084f8 <vector201>:
.globl vector201
vector201:
  pushl $0
801084f8:	6a 00                	push   $0x0
  pushl $201
801084fa:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801084ff:	e9 3e ef ff ff       	jmp    80107442 <alltraps>

80108504 <vector202>:
.globl vector202
vector202:
  pushl $0
80108504:	6a 00                	push   $0x0
  pushl $202
80108506:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010850b:	e9 32 ef ff ff       	jmp    80107442 <alltraps>

80108510 <vector203>:
.globl vector203
vector203:
  pushl $0
80108510:	6a 00                	push   $0x0
  pushl $203
80108512:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108517:	e9 26 ef ff ff       	jmp    80107442 <alltraps>

8010851c <vector204>:
.globl vector204
vector204:
  pushl $0
8010851c:	6a 00                	push   $0x0
  pushl $204
8010851e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108523:	e9 1a ef ff ff       	jmp    80107442 <alltraps>

80108528 <vector205>:
.globl vector205
vector205:
  pushl $0
80108528:	6a 00                	push   $0x0
  pushl $205
8010852a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010852f:	e9 0e ef ff ff       	jmp    80107442 <alltraps>

80108534 <vector206>:
.globl vector206
vector206:
  pushl $0
80108534:	6a 00                	push   $0x0
  pushl $206
80108536:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010853b:	e9 02 ef ff ff       	jmp    80107442 <alltraps>

80108540 <vector207>:
.globl vector207
vector207:
  pushl $0
80108540:	6a 00                	push   $0x0
  pushl $207
80108542:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108547:	e9 f6 ee ff ff       	jmp    80107442 <alltraps>

8010854c <vector208>:
.globl vector208
vector208:
  pushl $0
8010854c:	6a 00                	push   $0x0
  pushl $208
8010854e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108553:	e9 ea ee ff ff       	jmp    80107442 <alltraps>

80108558 <vector209>:
.globl vector209
vector209:
  pushl $0
80108558:	6a 00                	push   $0x0
  pushl $209
8010855a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010855f:	e9 de ee ff ff       	jmp    80107442 <alltraps>

80108564 <vector210>:
.globl vector210
vector210:
  pushl $0
80108564:	6a 00                	push   $0x0
  pushl $210
80108566:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010856b:	e9 d2 ee ff ff       	jmp    80107442 <alltraps>

80108570 <vector211>:
.globl vector211
vector211:
  pushl $0
80108570:	6a 00                	push   $0x0
  pushl $211
80108572:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108577:	e9 c6 ee ff ff       	jmp    80107442 <alltraps>

8010857c <vector212>:
.globl vector212
vector212:
  pushl $0
8010857c:	6a 00                	push   $0x0
  pushl $212
8010857e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108583:	e9 ba ee ff ff       	jmp    80107442 <alltraps>

80108588 <vector213>:
.globl vector213
vector213:
  pushl $0
80108588:	6a 00                	push   $0x0
  pushl $213
8010858a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010858f:	e9 ae ee ff ff       	jmp    80107442 <alltraps>

80108594 <vector214>:
.globl vector214
vector214:
  pushl $0
80108594:	6a 00                	push   $0x0
  pushl $214
80108596:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010859b:	e9 a2 ee ff ff       	jmp    80107442 <alltraps>

801085a0 <vector215>:
.globl vector215
vector215:
  pushl $0
801085a0:	6a 00                	push   $0x0
  pushl $215
801085a2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801085a7:	e9 96 ee ff ff       	jmp    80107442 <alltraps>

801085ac <vector216>:
.globl vector216
vector216:
  pushl $0
801085ac:	6a 00                	push   $0x0
  pushl $216
801085ae:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801085b3:	e9 8a ee ff ff       	jmp    80107442 <alltraps>

801085b8 <vector217>:
.globl vector217
vector217:
  pushl $0
801085b8:	6a 00                	push   $0x0
  pushl $217
801085ba:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801085bf:	e9 7e ee ff ff       	jmp    80107442 <alltraps>

801085c4 <vector218>:
.globl vector218
vector218:
  pushl $0
801085c4:	6a 00                	push   $0x0
  pushl $218
801085c6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801085cb:	e9 72 ee ff ff       	jmp    80107442 <alltraps>

801085d0 <vector219>:
.globl vector219
vector219:
  pushl $0
801085d0:	6a 00                	push   $0x0
  pushl $219
801085d2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801085d7:	e9 66 ee ff ff       	jmp    80107442 <alltraps>

801085dc <vector220>:
.globl vector220
vector220:
  pushl $0
801085dc:	6a 00                	push   $0x0
  pushl $220
801085de:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801085e3:	e9 5a ee ff ff       	jmp    80107442 <alltraps>

801085e8 <vector221>:
.globl vector221
vector221:
  pushl $0
801085e8:	6a 00                	push   $0x0
  pushl $221
801085ea:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801085ef:	e9 4e ee ff ff       	jmp    80107442 <alltraps>

801085f4 <vector222>:
.globl vector222
vector222:
  pushl $0
801085f4:	6a 00                	push   $0x0
  pushl $222
801085f6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801085fb:	e9 42 ee ff ff       	jmp    80107442 <alltraps>

80108600 <vector223>:
.globl vector223
vector223:
  pushl $0
80108600:	6a 00                	push   $0x0
  pushl $223
80108602:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108607:	e9 36 ee ff ff       	jmp    80107442 <alltraps>

8010860c <vector224>:
.globl vector224
vector224:
  pushl $0
8010860c:	6a 00                	push   $0x0
  pushl $224
8010860e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108613:	e9 2a ee ff ff       	jmp    80107442 <alltraps>

80108618 <vector225>:
.globl vector225
vector225:
  pushl $0
80108618:	6a 00                	push   $0x0
  pushl $225
8010861a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010861f:	e9 1e ee ff ff       	jmp    80107442 <alltraps>

80108624 <vector226>:
.globl vector226
vector226:
  pushl $0
80108624:	6a 00                	push   $0x0
  pushl $226
80108626:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010862b:	e9 12 ee ff ff       	jmp    80107442 <alltraps>

80108630 <vector227>:
.globl vector227
vector227:
  pushl $0
80108630:	6a 00                	push   $0x0
  pushl $227
80108632:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108637:	e9 06 ee ff ff       	jmp    80107442 <alltraps>

8010863c <vector228>:
.globl vector228
vector228:
  pushl $0
8010863c:	6a 00                	push   $0x0
  pushl $228
8010863e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108643:	e9 fa ed ff ff       	jmp    80107442 <alltraps>

80108648 <vector229>:
.globl vector229
vector229:
  pushl $0
80108648:	6a 00                	push   $0x0
  pushl $229
8010864a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010864f:	e9 ee ed ff ff       	jmp    80107442 <alltraps>

80108654 <vector230>:
.globl vector230
vector230:
  pushl $0
80108654:	6a 00                	push   $0x0
  pushl $230
80108656:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010865b:	e9 e2 ed ff ff       	jmp    80107442 <alltraps>

80108660 <vector231>:
.globl vector231
vector231:
  pushl $0
80108660:	6a 00                	push   $0x0
  pushl $231
80108662:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108667:	e9 d6 ed ff ff       	jmp    80107442 <alltraps>

8010866c <vector232>:
.globl vector232
vector232:
  pushl $0
8010866c:	6a 00                	push   $0x0
  pushl $232
8010866e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108673:	e9 ca ed ff ff       	jmp    80107442 <alltraps>

80108678 <vector233>:
.globl vector233
vector233:
  pushl $0
80108678:	6a 00                	push   $0x0
  pushl $233
8010867a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010867f:	e9 be ed ff ff       	jmp    80107442 <alltraps>

80108684 <vector234>:
.globl vector234
vector234:
  pushl $0
80108684:	6a 00                	push   $0x0
  pushl $234
80108686:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010868b:	e9 b2 ed ff ff       	jmp    80107442 <alltraps>

80108690 <vector235>:
.globl vector235
vector235:
  pushl $0
80108690:	6a 00                	push   $0x0
  pushl $235
80108692:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108697:	e9 a6 ed ff ff       	jmp    80107442 <alltraps>

8010869c <vector236>:
.globl vector236
vector236:
  pushl $0
8010869c:	6a 00                	push   $0x0
  pushl $236
8010869e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801086a3:	e9 9a ed ff ff       	jmp    80107442 <alltraps>

801086a8 <vector237>:
.globl vector237
vector237:
  pushl $0
801086a8:	6a 00                	push   $0x0
  pushl $237
801086aa:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801086af:	e9 8e ed ff ff       	jmp    80107442 <alltraps>

801086b4 <vector238>:
.globl vector238
vector238:
  pushl $0
801086b4:	6a 00                	push   $0x0
  pushl $238
801086b6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801086bb:	e9 82 ed ff ff       	jmp    80107442 <alltraps>

801086c0 <vector239>:
.globl vector239
vector239:
  pushl $0
801086c0:	6a 00                	push   $0x0
  pushl $239
801086c2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801086c7:	e9 76 ed ff ff       	jmp    80107442 <alltraps>

801086cc <vector240>:
.globl vector240
vector240:
  pushl $0
801086cc:	6a 00                	push   $0x0
  pushl $240
801086ce:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801086d3:	e9 6a ed ff ff       	jmp    80107442 <alltraps>

801086d8 <vector241>:
.globl vector241
vector241:
  pushl $0
801086d8:	6a 00                	push   $0x0
  pushl $241
801086da:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801086df:	e9 5e ed ff ff       	jmp    80107442 <alltraps>

801086e4 <vector242>:
.globl vector242
vector242:
  pushl $0
801086e4:	6a 00                	push   $0x0
  pushl $242
801086e6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801086eb:	e9 52 ed ff ff       	jmp    80107442 <alltraps>

801086f0 <vector243>:
.globl vector243
vector243:
  pushl $0
801086f0:	6a 00                	push   $0x0
  pushl $243
801086f2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801086f7:	e9 46 ed ff ff       	jmp    80107442 <alltraps>

801086fc <vector244>:
.globl vector244
vector244:
  pushl $0
801086fc:	6a 00                	push   $0x0
  pushl $244
801086fe:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108703:	e9 3a ed ff ff       	jmp    80107442 <alltraps>

80108708 <vector245>:
.globl vector245
vector245:
  pushl $0
80108708:	6a 00                	push   $0x0
  pushl $245
8010870a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010870f:	e9 2e ed ff ff       	jmp    80107442 <alltraps>

80108714 <vector246>:
.globl vector246
vector246:
  pushl $0
80108714:	6a 00                	push   $0x0
  pushl $246
80108716:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010871b:	e9 22 ed ff ff       	jmp    80107442 <alltraps>

80108720 <vector247>:
.globl vector247
vector247:
  pushl $0
80108720:	6a 00                	push   $0x0
  pushl $247
80108722:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108727:	e9 16 ed ff ff       	jmp    80107442 <alltraps>

8010872c <vector248>:
.globl vector248
vector248:
  pushl $0
8010872c:	6a 00                	push   $0x0
  pushl $248
8010872e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108733:	e9 0a ed ff ff       	jmp    80107442 <alltraps>

80108738 <vector249>:
.globl vector249
vector249:
  pushl $0
80108738:	6a 00                	push   $0x0
  pushl $249
8010873a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010873f:	e9 fe ec ff ff       	jmp    80107442 <alltraps>

80108744 <vector250>:
.globl vector250
vector250:
  pushl $0
80108744:	6a 00                	push   $0x0
  pushl $250
80108746:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010874b:	e9 f2 ec ff ff       	jmp    80107442 <alltraps>

80108750 <vector251>:
.globl vector251
vector251:
  pushl $0
80108750:	6a 00                	push   $0x0
  pushl $251
80108752:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108757:	e9 e6 ec ff ff       	jmp    80107442 <alltraps>

8010875c <vector252>:
.globl vector252
vector252:
  pushl $0
8010875c:	6a 00                	push   $0x0
  pushl $252
8010875e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108763:	e9 da ec ff ff       	jmp    80107442 <alltraps>

80108768 <vector253>:
.globl vector253
vector253:
  pushl $0
80108768:	6a 00                	push   $0x0
  pushl $253
8010876a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010876f:	e9 ce ec ff ff       	jmp    80107442 <alltraps>

80108774 <vector254>:
.globl vector254
vector254:
  pushl $0
80108774:	6a 00                	push   $0x0
  pushl $254
80108776:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010877b:	e9 c2 ec ff ff       	jmp    80107442 <alltraps>

80108780 <vector255>:
.globl vector255
vector255:
  pushl $0
80108780:	6a 00                	push   $0x0
  pushl $255
80108782:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108787:	e9 b6 ec ff ff       	jmp    80107442 <alltraps>

8010878c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010878c:	55                   	push   %ebp
8010878d:	89 e5                	mov    %esp,%ebp
8010878f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108792:	8b 45 0c             	mov    0xc(%ebp),%eax
80108795:	83 e8 01             	sub    $0x1,%eax
80108798:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010879c:	8b 45 08             	mov    0x8(%ebp),%eax
8010879f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801087a3:	8b 45 08             	mov    0x8(%ebp),%eax
801087a6:	c1 e8 10             	shr    $0x10,%eax
801087a9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801087ad:	8d 45 fa             	lea    -0x6(%ebp),%eax
801087b0:	0f 01 10             	lgdtl  (%eax)
}
801087b3:	90                   	nop
801087b4:	c9                   	leave  
801087b5:	c3                   	ret    

801087b6 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801087b6:	55                   	push   %ebp
801087b7:	89 e5                	mov    %esp,%ebp
801087b9:	83 ec 04             	sub    $0x4,%esp
801087bc:	8b 45 08             	mov    0x8(%ebp),%eax
801087bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801087c3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801087c7:	0f 00 d8             	ltr    %ax
}
801087ca:	90                   	nop
801087cb:	c9                   	leave  
801087cc:	c3                   	ret    

801087cd <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801087cd:	55                   	push   %ebp
801087ce:	89 e5                	mov    %esp,%ebp
801087d0:	83 ec 04             	sub    $0x4,%esp
801087d3:	8b 45 08             	mov    0x8(%ebp),%eax
801087d6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801087da:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801087de:	8e e8                	mov    %eax,%gs
}
801087e0:	90                   	nop
801087e1:	c9                   	leave  
801087e2:	c3                   	ret    

801087e3 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801087e3:	55                   	push   %ebp
801087e4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801087e6:	8b 45 08             	mov    0x8(%ebp),%eax
801087e9:	0f 22 d8             	mov    %eax,%cr3
}
801087ec:	90                   	nop
801087ed:	5d                   	pop    %ebp
801087ee:	c3                   	ret    

801087ef <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801087ef:	55                   	push   %ebp
801087f0:	89 e5                	mov    %esp,%ebp
801087f2:	8b 45 08             	mov    0x8(%ebp),%eax
801087f5:	05 00 00 00 80       	add    $0x80000000,%eax
801087fa:	5d                   	pop    %ebp
801087fb:	c3                   	ret    

801087fc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801087fc:	55                   	push   %ebp
801087fd:	89 e5                	mov    %esp,%ebp
801087ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108802:	05 00 00 00 80       	add    $0x80000000,%eax
80108807:	5d                   	pop    %ebp
80108808:	c3                   	ret    

80108809 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108809:	55                   	push   %ebp
8010880a:	89 e5                	mov    %esp,%ebp
8010880c:	53                   	push   %ebx
8010880d:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108810:	e8 79 a7 ff ff       	call   80102f8e <cpunum>
80108815:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010881b:	05 80 33 11 80       	add    $0x80113380,%eax
80108820:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108826:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108838:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010883c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108843:	83 e2 f0             	and    $0xfffffff0,%edx
80108846:	83 ca 0a             	or     $0xa,%edx
80108849:	88 50 7d             	mov    %dl,0x7d(%eax)
8010884c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108853:	83 ca 10             	or     $0x10,%edx
80108856:	88 50 7d             	mov    %dl,0x7d(%eax)
80108859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108860:	83 e2 9f             	and    $0xffffff9f,%edx
80108863:	88 50 7d             	mov    %dl,0x7d(%eax)
80108866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108869:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010886d:	83 ca 80             	or     $0xffffff80,%edx
80108870:	88 50 7d             	mov    %dl,0x7d(%eax)
80108873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108876:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010887a:	83 ca 0f             	or     $0xf,%edx
8010887d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108883:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108887:	83 e2 ef             	and    $0xffffffef,%edx
8010888a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010888d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108890:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108894:	83 e2 df             	and    $0xffffffdf,%edx
80108897:	88 50 7e             	mov    %dl,0x7e(%eax)
8010889a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088a1:	83 ca 40             	or     $0x40,%edx
801088a4:	88 50 7e             	mov    %dl,0x7e(%eax)
801088a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088aa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088ae:	83 ca 80             	or     $0xffffff80,%edx
801088b1:	88 50 7e             	mov    %dl,0x7e(%eax)
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801088bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088be:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801088c5:	ff ff 
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801088d1:	00 00 
801088d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801088dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801088e7:	83 e2 f0             	and    $0xfffffff0,%edx
801088ea:	83 ca 02             	or     $0x2,%edx
801088ed:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801088fd:	83 ca 10             	or     $0x10,%edx
80108900:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108909:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108910:	83 e2 9f             	and    $0xffffff9f,%edx
80108913:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108923:	83 ca 80             	or     $0xffffff80,%edx
80108926:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010892c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108936:	83 ca 0f             	or     $0xf,%edx
80108939:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010893f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108942:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108949:	83 e2 ef             	and    $0xffffffef,%edx
8010894c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108955:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010895c:	83 e2 df             	and    $0xffffffdf,%edx
8010895f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108968:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010896f:	83 ca 40             	or     $0x40,%edx
80108972:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108982:	83 ca 80             	or     $0xffffff80,%edx
80108985:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010898b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108998:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010899f:	ff ff 
801089a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801089ab:	00 00 
801089ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801089b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ba:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801089c1:	83 e2 f0             	and    $0xfffffff0,%edx
801089c4:	83 ca 0a             	or     $0xa,%edx
801089c7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801089cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801089d7:	83 ca 10             	or     $0x10,%edx
801089da:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801089e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801089ea:	83 ca 60             	or     $0x60,%edx
801089ed:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801089f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801089fd:	83 ca 80             	or     $0xffffff80,%edx
80108a00:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a09:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a10:	83 ca 0f             	or     $0xf,%edx
80108a13:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a23:	83 e2 ef             	and    $0xffffffef,%edx
80108a26:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a36:	83 e2 df             	and    $0xffffffdf,%edx
80108a39:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a42:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a49:	83 ca 40             	or     $0x40,%edx
80108a4c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a55:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a5c:	83 ca 80             	or     $0xffffff80,%edx
80108a5f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a68:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a72:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108a79:	ff ff 
80108a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108a85:	00 00 
80108a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a94:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108a9b:	83 e2 f0             	and    $0xfffffff0,%edx
80108a9e:	83 ca 02             	or     $0x2,%edx
80108aa1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aaa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108ab1:	83 ca 10             	or     $0x10,%edx
80108ab4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108abd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108ac4:	83 ca 60             	or     $0x60,%edx
80108ac7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108ad7:	83 ca 80             	or     $0xffffff80,%edx
80108ada:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108aea:	83 ca 0f             	or     $0xf,%edx
80108aed:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108afd:	83 e2 ef             	and    $0xffffffef,%edx
80108b00:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b09:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b10:	83 e2 df             	and    $0xffffffdf,%edx
80108b13:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b23:	83 ca 40             	or     $0x40,%edx
80108b26:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b36:	83 ca 80             	or     $0xffffff80,%edx
80108b39:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b42:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4c:	05 b4 00 00 00       	add    $0xb4,%eax
80108b51:	89 c3                	mov    %eax,%ebx
80108b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b56:	05 b4 00 00 00       	add    $0xb4,%eax
80108b5b:	c1 e8 10             	shr    $0x10,%eax
80108b5e:	89 c2                	mov    %eax,%edx
80108b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b63:	05 b4 00 00 00       	add    $0xb4,%eax
80108b68:	c1 e8 18             	shr    $0x18,%eax
80108b6b:	89 c1                	mov    %eax,%ecx
80108b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b70:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108b77:	00 00 
80108b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b86:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108b96:	83 e2 f0             	and    $0xfffffff0,%edx
80108b99:	83 ca 02             	or     $0x2,%edx
80108b9c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108bac:	83 ca 10             	or     $0x10,%edx
80108baf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108bbf:	83 e2 9f             	and    $0xffffff9f,%edx
80108bc2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bcb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108bd2:	83 ca 80             	or     $0xffffff80,%edx
80108bd5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bde:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108be5:	83 e2 f0             	and    $0xfffffff0,%edx
80108be8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108bf8:	83 e2 ef             	and    $0xffffffef,%edx
80108bfb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c04:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c0b:	83 e2 df             	and    $0xffffffdf,%edx
80108c0e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c17:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c1e:	83 ca 40             	or     $0x40,%edx
80108c21:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c31:	83 ca 80             	or     $0xffffff80,%edx
80108c34:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3d:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c46:	83 c0 70             	add    $0x70,%eax
80108c49:	83 ec 08             	sub    $0x8,%esp
80108c4c:	6a 38                	push   $0x38
80108c4e:	50                   	push   %eax
80108c4f:	e8 38 fb ff ff       	call   8010878c <lgdt>
80108c54:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108c57:	83 ec 0c             	sub    $0xc,%esp
80108c5a:	6a 18                	push   $0x18
80108c5c:	e8 6c fb ff ff       	call   801087cd <loadgs>
80108c61:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
80108c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c67:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108c6d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108c74:	00 00 00 00 
}
80108c78:	90                   	nop
80108c79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c7c:	c9                   	leave  
80108c7d:	c3                   	ret    

80108c7e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108c7e:	55                   	push   %ebp
80108c7f:	89 e5                	mov    %esp,%ebp
80108c81:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108c84:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c87:	c1 e8 16             	shr    $0x16,%eax
80108c8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c91:	8b 45 08             	mov    0x8(%ebp),%eax
80108c94:	01 d0                	add    %edx,%eax
80108c96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c9c:	8b 00                	mov    (%eax),%eax
80108c9e:	83 e0 01             	and    $0x1,%eax
80108ca1:	85 c0                	test   %eax,%eax
80108ca3:	74 18                	je     80108cbd <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ca8:	8b 00                	mov    (%eax),%eax
80108caa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108caf:	50                   	push   %eax
80108cb0:	e8 47 fb ff ff       	call   801087fc <p2v>
80108cb5:	83 c4 04             	add    $0x4,%esp
80108cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108cbb:	eb 48                	jmp    80108d05 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108cbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108cc1:	74 0e                	je     80108cd1 <walkpgdir+0x53>
80108cc3:	e8 60 9f ff ff       	call   80102c28 <kalloc>
80108cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108ccb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108ccf:	75 07                	jne    80108cd8 <walkpgdir+0x5a>
      return 0;
80108cd1:	b8 00 00 00 00       	mov    $0x0,%eax
80108cd6:	eb 44                	jmp    80108d1c <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108cd8:	83 ec 04             	sub    $0x4,%esp
80108cdb:	68 00 10 00 00       	push   $0x1000
80108ce0:	6a 00                	push   $0x0
80108ce2:	ff 75 f4             	pushl  -0xc(%ebp)
80108ce5:	e8 89 d1 ff ff       	call   80105e73 <memset>
80108cea:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108ced:	83 ec 0c             	sub    $0xc,%esp
80108cf0:	ff 75 f4             	pushl  -0xc(%ebp)
80108cf3:	e8 f7 fa ff ff       	call   801087ef <v2p>
80108cf8:	83 c4 10             	add    $0x10,%esp
80108cfb:	83 c8 07             	or     $0x7,%eax
80108cfe:	89 c2                	mov    %eax,%edx
80108d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d03:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108d05:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d08:	c1 e8 0c             	shr    $0xc,%eax
80108d0b:	25 ff 03 00 00       	and    $0x3ff,%eax
80108d10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1a:	01 d0                	add    %edx,%eax
}
80108d1c:	c9                   	leave  
80108d1d:	c3                   	ret    

80108d1e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108d1e:	55                   	push   %ebp
80108d1f:	89 e5                	mov    %esp,%ebp
80108d21:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d32:	8b 45 10             	mov    0x10(%ebp),%eax
80108d35:	01 d0                	add    %edx,%eax
80108d37:	83 e8 01             	sub    $0x1,%eax
80108d3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108d42:	83 ec 04             	sub    $0x4,%esp
80108d45:	6a 01                	push   $0x1
80108d47:	ff 75 f4             	pushl  -0xc(%ebp)
80108d4a:	ff 75 08             	pushl  0x8(%ebp)
80108d4d:	e8 2c ff ff ff       	call   80108c7e <walkpgdir>
80108d52:	83 c4 10             	add    $0x10,%esp
80108d55:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d5c:	75 07                	jne    80108d65 <mappages+0x47>
      return -1;
80108d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d63:	eb 47                	jmp    80108dac <mappages+0x8e>
    if(*pte & PTE_P)
80108d65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d68:	8b 00                	mov    (%eax),%eax
80108d6a:	83 e0 01             	and    $0x1,%eax
80108d6d:	85 c0                	test   %eax,%eax
80108d6f:	74 0d                	je     80108d7e <mappages+0x60>
      panic("remap");
80108d71:	83 ec 0c             	sub    $0xc,%esp
80108d74:	68 8c 9d 10 80       	push   $0x80109d8c
80108d79:	e8 e8 77 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108d7e:	8b 45 18             	mov    0x18(%ebp),%eax
80108d81:	0b 45 14             	or     0x14(%ebp),%eax
80108d84:	83 c8 01             	or     $0x1,%eax
80108d87:	89 c2                	mov    %eax,%edx
80108d89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d8c:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d91:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108d94:	74 10                	je     80108da6 <mappages+0x88>
      break;
    a += PGSIZE;
80108d96:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108d9d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108da4:	eb 9c                	jmp    80108d42 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108da6:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108dac:	c9                   	leave  
80108dad:	c3                   	ret    

80108dae <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108dae:	55                   	push   %ebp
80108daf:	89 e5                	mov    %esp,%ebp
80108db1:	53                   	push   %ebx
80108db2:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108db5:	e8 6e 9e ff ff       	call   80102c28 <kalloc>
80108dba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108dbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108dc1:	75 0a                	jne    80108dcd <setupkvm+0x1f>
    return 0;
80108dc3:	b8 00 00 00 00       	mov    $0x0,%eax
80108dc8:	e9 8e 00 00 00       	jmp    80108e5b <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108dcd:	83 ec 04             	sub    $0x4,%esp
80108dd0:	68 00 10 00 00       	push   $0x1000
80108dd5:	6a 00                	push   $0x0
80108dd7:	ff 75 f0             	pushl  -0x10(%ebp)
80108dda:	e8 94 d0 ff ff       	call   80105e73 <memset>
80108ddf:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108de2:	83 ec 0c             	sub    $0xc,%esp
80108de5:	68 00 00 00 0e       	push   $0xe000000
80108dea:	e8 0d fa ff ff       	call   801087fc <p2v>
80108def:	83 c4 10             	add    $0x10,%esp
80108df2:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108df7:	76 0d                	jbe    80108e06 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108df9:	83 ec 0c             	sub    $0xc,%esp
80108dfc:	68 92 9d 10 80       	push   $0x80109d92
80108e01:	e8 60 77 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108e06:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108e0d:	eb 40                	jmp    80108e4f <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e12:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e18:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1e:	8b 58 08             	mov    0x8(%eax),%ebx
80108e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e24:	8b 40 04             	mov    0x4(%eax),%eax
80108e27:	29 c3                	sub    %eax,%ebx
80108e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2c:	8b 00                	mov    (%eax),%eax
80108e2e:	83 ec 0c             	sub    $0xc,%esp
80108e31:	51                   	push   %ecx
80108e32:	52                   	push   %edx
80108e33:	53                   	push   %ebx
80108e34:	50                   	push   %eax
80108e35:	ff 75 f0             	pushl  -0x10(%ebp)
80108e38:	e8 e1 fe ff ff       	call   80108d1e <mappages>
80108e3d:	83 c4 20             	add    $0x20,%esp
80108e40:	85 c0                	test   %eax,%eax
80108e42:	79 07                	jns    80108e4b <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108e44:	b8 00 00 00 00       	mov    $0x0,%eax
80108e49:	eb 10                	jmp    80108e5b <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108e4b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108e4f:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108e56:	72 b7                	jb     80108e0f <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108e5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e5e:	c9                   	leave  
80108e5f:	c3                   	ret    

80108e60 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108e60:	55                   	push   %ebp
80108e61:	89 e5                	mov    %esp,%ebp
80108e63:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108e66:	e8 43 ff ff ff       	call   80108dae <setupkvm>
80108e6b:	a3 b8 7c 11 80       	mov    %eax,0x80117cb8
  switchkvm();
80108e70:	e8 03 00 00 00       	call   80108e78 <switchkvm>
}
80108e75:	90                   	nop
80108e76:	c9                   	leave  
80108e77:	c3                   	ret    

80108e78 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108e78:	55                   	push   %ebp
80108e79:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108e7b:	a1 b8 7c 11 80       	mov    0x80117cb8,%eax
80108e80:	50                   	push   %eax
80108e81:	e8 69 f9 ff ff       	call   801087ef <v2p>
80108e86:	83 c4 04             	add    $0x4,%esp
80108e89:	50                   	push   %eax
80108e8a:	e8 54 f9 ff ff       	call   801087e3 <lcr3>
80108e8f:	83 c4 04             	add    $0x4,%esp
}
80108e92:	90                   	nop
80108e93:	c9                   	leave  
80108e94:	c3                   	ret    

80108e95 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108e95:	55                   	push   %ebp
80108e96:	89 e5                	mov    %esp,%ebp
80108e98:	56                   	push   %esi
80108e99:	53                   	push   %ebx
  pushcli();
80108e9a:	e8 ce ce ff ff       	call   80105d6d <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108e9f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ea5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108eac:	83 c2 08             	add    $0x8,%edx
80108eaf:	89 d6                	mov    %edx,%esi
80108eb1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108eb8:	83 c2 08             	add    $0x8,%edx
80108ebb:	c1 ea 10             	shr    $0x10,%edx
80108ebe:	89 d3                	mov    %edx,%ebx
80108ec0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ec7:	83 c2 08             	add    $0x8,%edx
80108eca:	c1 ea 18             	shr    $0x18,%edx
80108ecd:	89 d1                	mov    %edx,%ecx
80108ecf:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108ed6:	67 00 
80108ed8:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108edf:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108ee5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108eec:	83 e2 f0             	and    $0xfffffff0,%edx
80108eef:	83 ca 09             	or     $0x9,%edx
80108ef2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ef8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108eff:	83 ca 10             	or     $0x10,%edx
80108f02:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f08:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f0f:	83 e2 9f             	and    $0xffffff9f,%edx
80108f12:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f18:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f1f:	83 ca 80             	or     $0xffffff80,%edx
80108f22:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f28:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f2f:	83 e2 f0             	and    $0xfffffff0,%edx
80108f32:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f38:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f3f:	83 e2 ef             	and    $0xffffffef,%edx
80108f42:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f48:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f4f:	83 e2 df             	and    $0xffffffdf,%edx
80108f52:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f58:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f5f:	83 ca 40             	or     $0x40,%edx
80108f62:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f68:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f6f:	83 e2 7f             	and    $0x7f,%edx
80108f72:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f78:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108f7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108f84:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f8b:	83 e2 ef             	and    $0xffffffef,%edx
80108f8e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108f94:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108f9a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108fa0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108fa6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108fad:	8b 52 08             	mov    0x8(%edx),%edx
80108fb0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108fb6:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108fb9:	83 ec 0c             	sub    $0xc,%esp
80108fbc:	6a 30                	push   $0x30
80108fbe:	e8 f3 f7 ff ff       	call   801087b6 <ltr>
80108fc3:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80108fc9:	8b 40 04             	mov    0x4(%eax),%eax
80108fcc:	85 c0                	test   %eax,%eax
80108fce:	75 0d                	jne    80108fdd <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108fd0:	83 ec 0c             	sub    $0xc,%esp
80108fd3:	68 a3 9d 10 80       	push   $0x80109da3
80108fd8:	e8 89 75 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80108fe0:	8b 40 04             	mov    0x4(%eax),%eax
80108fe3:	83 ec 0c             	sub    $0xc,%esp
80108fe6:	50                   	push   %eax
80108fe7:	e8 03 f8 ff ff       	call   801087ef <v2p>
80108fec:	83 c4 10             	add    $0x10,%esp
80108fef:	83 ec 0c             	sub    $0xc,%esp
80108ff2:	50                   	push   %eax
80108ff3:	e8 eb f7 ff ff       	call   801087e3 <lcr3>
80108ff8:	83 c4 10             	add    $0x10,%esp
  popcli();
80108ffb:	e8 b2 cd ff ff       	call   80105db2 <popcli>
}
80109000:	90                   	nop
80109001:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109004:	5b                   	pop    %ebx
80109005:	5e                   	pop    %esi
80109006:	5d                   	pop    %ebp
80109007:	c3                   	ret    

80109008 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109008:	55                   	push   %ebp
80109009:	89 e5                	mov    %esp,%ebp
8010900b:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010900e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109015:	76 0d                	jbe    80109024 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109017:	83 ec 0c             	sub    $0xc,%esp
8010901a:	68 b7 9d 10 80       	push   $0x80109db7
8010901f:	e8 42 75 ff ff       	call   80100566 <panic>
  mem = kalloc();
80109024:	e8 ff 9b ff ff       	call   80102c28 <kalloc>
80109029:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010902c:	83 ec 04             	sub    $0x4,%esp
8010902f:	68 00 10 00 00       	push   $0x1000
80109034:	6a 00                	push   $0x0
80109036:	ff 75 f4             	pushl  -0xc(%ebp)
80109039:	e8 35 ce ff ff       	call   80105e73 <memset>
8010903e:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109041:	83 ec 0c             	sub    $0xc,%esp
80109044:	ff 75 f4             	pushl  -0xc(%ebp)
80109047:	e8 a3 f7 ff ff       	call   801087ef <v2p>
8010904c:	83 c4 10             	add    $0x10,%esp
8010904f:	83 ec 0c             	sub    $0xc,%esp
80109052:	6a 06                	push   $0x6
80109054:	50                   	push   %eax
80109055:	68 00 10 00 00       	push   $0x1000
8010905a:	6a 00                	push   $0x0
8010905c:	ff 75 08             	pushl  0x8(%ebp)
8010905f:	e8 ba fc ff ff       	call   80108d1e <mappages>
80109064:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80109067:	83 ec 04             	sub    $0x4,%esp
8010906a:	ff 75 10             	pushl  0x10(%ebp)
8010906d:	ff 75 0c             	pushl  0xc(%ebp)
80109070:	ff 75 f4             	pushl  -0xc(%ebp)
80109073:	e8 ba ce ff ff       	call   80105f32 <memmove>
80109078:	83 c4 10             	add    $0x10,%esp
}
8010907b:	90                   	nop
8010907c:	c9                   	leave  
8010907d:	c3                   	ret    

8010907e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010907e:	55                   	push   %ebp
8010907f:	89 e5                	mov    %esp,%ebp
80109081:	53                   	push   %ebx
80109082:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80109085:	8b 45 0c             	mov    0xc(%ebp),%eax
80109088:	25 ff 0f 00 00       	and    $0xfff,%eax
8010908d:	85 c0                	test   %eax,%eax
8010908f:	74 0d                	je     8010909e <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80109091:	83 ec 0c             	sub    $0xc,%esp
80109094:	68 d4 9d 10 80       	push   $0x80109dd4
80109099:	e8 c8 74 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010909e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090a5:	e9 95 00 00 00       	jmp    8010913f <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801090aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801090ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b0:	01 d0                	add    %edx,%eax
801090b2:	83 ec 04             	sub    $0x4,%esp
801090b5:	6a 00                	push   $0x0
801090b7:	50                   	push   %eax
801090b8:	ff 75 08             	pushl  0x8(%ebp)
801090bb:	e8 be fb ff ff       	call   80108c7e <walkpgdir>
801090c0:	83 c4 10             	add    $0x10,%esp
801090c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801090c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801090ca:	75 0d                	jne    801090d9 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801090cc:	83 ec 0c             	sub    $0xc,%esp
801090cf:	68 f7 9d 10 80       	push   $0x80109df7
801090d4:	e8 8d 74 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801090d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090dc:	8b 00                	mov    (%eax),%eax
801090de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801090e6:	8b 45 18             	mov    0x18(%ebp),%eax
801090e9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801090ec:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801090f1:	77 0b                	ja     801090fe <loaduvm+0x80>
      n = sz - i;
801090f3:	8b 45 18             	mov    0x18(%ebp),%eax
801090f6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801090f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801090fc:	eb 07                	jmp    80109105 <loaduvm+0x87>
    else
      n = PGSIZE;
801090fe:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109105:	8b 55 14             	mov    0x14(%ebp),%edx
80109108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010910b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010910e:	83 ec 0c             	sub    $0xc,%esp
80109111:	ff 75 e8             	pushl  -0x18(%ebp)
80109114:	e8 e3 f6 ff ff       	call   801087fc <p2v>
80109119:	83 c4 10             	add    $0x10,%esp
8010911c:	ff 75 f0             	pushl  -0x10(%ebp)
8010911f:	53                   	push   %ebx
80109120:	50                   	push   %eax
80109121:	ff 75 10             	pushl  0x10(%ebp)
80109124:	e8 ad 8d ff ff       	call   80101ed6 <readi>
80109129:	83 c4 10             	add    $0x10,%esp
8010912c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010912f:	74 07                	je     80109138 <loaduvm+0xba>
      return -1;
80109131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109136:	eb 18                	jmp    80109150 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109138:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010913f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109142:	3b 45 18             	cmp    0x18(%ebp),%eax
80109145:	0f 82 5f ff ff ff    	jb     801090aa <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010914b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109150:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109153:	c9                   	leave  
80109154:	c3                   	ret    

80109155 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109155:	55                   	push   %ebp
80109156:	89 e5                	mov    %esp,%ebp
80109158:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010915b:	8b 45 10             	mov    0x10(%ebp),%eax
8010915e:	85 c0                	test   %eax,%eax
80109160:	79 0a                	jns    8010916c <allocuvm+0x17>
    return 0;
80109162:	b8 00 00 00 00       	mov    $0x0,%eax
80109167:	e9 b0 00 00 00       	jmp    8010921c <allocuvm+0xc7>
  if(newsz < oldsz)
8010916c:	8b 45 10             	mov    0x10(%ebp),%eax
8010916f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109172:	73 08                	jae    8010917c <allocuvm+0x27>
    return oldsz;
80109174:	8b 45 0c             	mov    0xc(%ebp),%eax
80109177:	e9 a0 00 00 00       	jmp    8010921c <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
8010917c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010917f:	05 ff 0f 00 00       	add    $0xfff,%eax
80109184:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109189:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010918c:	eb 7f                	jmp    8010920d <allocuvm+0xb8>
    mem = kalloc();
8010918e:	e8 95 9a ff ff       	call   80102c28 <kalloc>
80109193:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109196:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010919a:	75 2b                	jne    801091c7 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
8010919c:	83 ec 0c             	sub    $0xc,%esp
8010919f:	68 15 9e 10 80       	push   $0x80109e15
801091a4:	e8 1d 72 ff ff       	call   801003c6 <cprintf>
801091a9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801091ac:	83 ec 04             	sub    $0x4,%esp
801091af:	ff 75 0c             	pushl  0xc(%ebp)
801091b2:	ff 75 10             	pushl  0x10(%ebp)
801091b5:	ff 75 08             	pushl  0x8(%ebp)
801091b8:	e8 61 00 00 00       	call   8010921e <deallocuvm>
801091bd:	83 c4 10             	add    $0x10,%esp
      return 0;
801091c0:	b8 00 00 00 00       	mov    $0x0,%eax
801091c5:	eb 55                	jmp    8010921c <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801091c7:	83 ec 04             	sub    $0x4,%esp
801091ca:	68 00 10 00 00       	push   $0x1000
801091cf:	6a 00                	push   $0x0
801091d1:	ff 75 f0             	pushl  -0x10(%ebp)
801091d4:	e8 9a cc ff ff       	call   80105e73 <memset>
801091d9:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801091dc:	83 ec 0c             	sub    $0xc,%esp
801091df:	ff 75 f0             	pushl  -0x10(%ebp)
801091e2:	e8 08 f6 ff ff       	call   801087ef <v2p>
801091e7:	83 c4 10             	add    $0x10,%esp
801091ea:	89 c2                	mov    %eax,%edx
801091ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ef:	83 ec 0c             	sub    $0xc,%esp
801091f2:	6a 06                	push   $0x6
801091f4:	52                   	push   %edx
801091f5:	68 00 10 00 00       	push   $0x1000
801091fa:	50                   	push   %eax
801091fb:	ff 75 08             	pushl  0x8(%ebp)
801091fe:	e8 1b fb ff ff       	call   80108d1e <mappages>
80109203:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109206:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010920d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109210:	3b 45 10             	cmp    0x10(%ebp),%eax
80109213:	0f 82 75 ff ff ff    	jb     8010918e <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109219:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010921c:	c9                   	leave  
8010921d:	c3                   	ret    

8010921e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010921e:	55                   	push   %ebp
8010921f:	89 e5                	mov    %esp,%ebp
80109221:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109224:	8b 45 10             	mov    0x10(%ebp),%eax
80109227:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010922a:	72 08                	jb     80109234 <deallocuvm+0x16>
    return oldsz;
8010922c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010922f:	e9 a5 00 00 00       	jmp    801092d9 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109234:	8b 45 10             	mov    0x10(%ebp),%eax
80109237:	05 ff 0f 00 00       	add    $0xfff,%eax
8010923c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109241:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109244:	e9 81 00 00 00       	jmp    801092ca <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924c:	83 ec 04             	sub    $0x4,%esp
8010924f:	6a 00                	push   $0x0
80109251:	50                   	push   %eax
80109252:	ff 75 08             	pushl  0x8(%ebp)
80109255:	e8 24 fa ff ff       	call   80108c7e <walkpgdir>
8010925a:	83 c4 10             	add    $0x10,%esp
8010925d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109260:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109264:	75 09                	jne    8010926f <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109266:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010926d:	eb 54                	jmp    801092c3 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010926f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109272:	8b 00                	mov    (%eax),%eax
80109274:	83 e0 01             	and    $0x1,%eax
80109277:	85 c0                	test   %eax,%eax
80109279:	74 48                	je     801092c3 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010927b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927e:	8b 00                	mov    (%eax),%eax
80109280:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109285:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109288:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010928c:	75 0d                	jne    8010929b <deallocuvm+0x7d>
        panic("kfree");
8010928e:	83 ec 0c             	sub    $0xc,%esp
80109291:	68 2d 9e 10 80       	push   $0x80109e2d
80109296:	e8 cb 72 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010929b:	83 ec 0c             	sub    $0xc,%esp
8010929e:	ff 75 ec             	pushl  -0x14(%ebp)
801092a1:	e8 56 f5 ff ff       	call   801087fc <p2v>
801092a6:	83 c4 10             	add    $0x10,%esp
801092a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801092ac:	83 ec 0c             	sub    $0xc,%esp
801092af:	ff 75 e8             	pushl  -0x18(%ebp)
801092b2:	e8 d4 98 ff ff       	call   80102b8b <kfree>
801092b7:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801092ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801092c3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801092ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092d0:	0f 82 73 ff ff ff    	jb     80109249 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801092d6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801092d9:	c9                   	leave  
801092da:	c3                   	ret    

801092db <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801092db:	55                   	push   %ebp
801092dc:	89 e5                	mov    %esp,%ebp
801092de:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801092e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801092e5:	75 0d                	jne    801092f4 <freevm+0x19>
    panic("freevm: no pgdir");
801092e7:	83 ec 0c             	sub    $0xc,%esp
801092ea:	68 33 9e 10 80       	push   $0x80109e33
801092ef:	e8 72 72 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801092f4:	83 ec 04             	sub    $0x4,%esp
801092f7:	6a 00                	push   $0x0
801092f9:	68 00 00 00 80       	push   $0x80000000
801092fe:	ff 75 08             	pushl  0x8(%ebp)
80109301:	e8 18 ff ff ff       	call   8010921e <deallocuvm>
80109306:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109310:	eb 4f                	jmp    80109361 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109315:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010931c:	8b 45 08             	mov    0x8(%ebp),%eax
8010931f:	01 d0                	add    %edx,%eax
80109321:	8b 00                	mov    (%eax),%eax
80109323:	83 e0 01             	and    $0x1,%eax
80109326:	85 c0                	test   %eax,%eax
80109328:	74 33                	je     8010935d <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010932a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109334:	8b 45 08             	mov    0x8(%ebp),%eax
80109337:	01 d0                	add    %edx,%eax
80109339:	8b 00                	mov    (%eax),%eax
8010933b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109340:	83 ec 0c             	sub    $0xc,%esp
80109343:	50                   	push   %eax
80109344:	e8 b3 f4 ff ff       	call   801087fc <p2v>
80109349:	83 c4 10             	add    $0x10,%esp
8010934c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010934f:	83 ec 0c             	sub    $0xc,%esp
80109352:	ff 75 f0             	pushl  -0x10(%ebp)
80109355:	e8 31 98 ff ff       	call   80102b8b <kfree>
8010935a:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010935d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109361:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109368:	76 a8                	jbe    80109312 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010936a:	83 ec 0c             	sub    $0xc,%esp
8010936d:	ff 75 08             	pushl  0x8(%ebp)
80109370:	e8 16 98 ff ff       	call   80102b8b <kfree>
80109375:	83 c4 10             	add    $0x10,%esp
}
80109378:	90                   	nop
80109379:	c9                   	leave  
8010937a:	c3                   	ret    

8010937b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010937b:	55                   	push   %ebp
8010937c:	89 e5                	mov    %esp,%ebp
8010937e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109381:	83 ec 04             	sub    $0x4,%esp
80109384:	6a 00                	push   $0x0
80109386:	ff 75 0c             	pushl  0xc(%ebp)
80109389:	ff 75 08             	pushl  0x8(%ebp)
8010938c:	e8 ed f8 ff ff       	call   80108c7e <walkpgdir>
80109391:	83 c4 10             	add    $0x10,%esp
80109394:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109397:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010939b:	75 0d                	jne    801093aa <clearpteu+0x2f>
    panic("clearpteu");
8010939d:	83 ec 0c             	sub    $0xc,%esp
801093a0:	68 44 9e 10 80       	push   $0x80109e44
801093a5:	e8 bc 71 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801093aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ad:	8b 00                	mov    (%eax),%eax
801093af:	83 e0 fb             	and    $0xfffffffb,%eax
801093b2:	89 c2                	mov    %eax,%edx
801093b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b7:	89 10                	mov    %edx,(%eax)
}
801093b9:	90                   	nop
801093ba:	c9                   	leave  
801093bb:	c3                   	ret    

801093bc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801093bc:	55                   	push   %ebp
801093bd:	89 e5                	mov    %esp,%ebp
801093bf:	53                   	push   %ebx
801093c0:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801093c3:	e8 e6 f9 ff ff       	call   80108dae <setupkvm>
801093c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801093cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801093cf:	75 0a                	jne    801093db <copyuvm+0x1f>
    return 0;
801093d1:	b8 00 00 00 00       	mov    $0x0,%eax
801093d6:	e9 ee 00 00 00       	jmp    801094c9 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
801093db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093e2:	e9 ba 00 00 00       	jmp    801094a1 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801093e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ea:	83 ec 04             	sub    $0x4,%esp
801093ed:	6a 00                	push   $0x0
801093ef:	50                   	push   %eax
801093f0:	ff 75 08             	pushl  0x8(%ebp)
801093f3:	e8 86 f8 ff ff       	call   80108c7e <walkpgdir>
801093f8:	83 c4 10             	add    $0x10,%esp
801093fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801093fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109402:	75 0d                	jne    80109411 <copyuvm+0x55>
    //  continue;
      panic("copyuvm: pte should exist");
80109404:	83 ec 0c             	sub    $0xc,%esp
80109407:	68 4e 9e 10 80       	push   $0x80109e4e
8010940c:	e8 55 71 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109411:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109414:	8b 00                	mov    (%eax),%eax
80109416:	83 e0 01             	and    $0x1,%eax
80109419:	85 c0                	test   %eax,%eax
8010941b:	74 7c                	je     80109499 <copyuvm+0xdd>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010941d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109420:	8b 00                	mov    (%eax),%eax
80109422:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109427:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010942a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010942d:	8b 00                	mov    (%eax),%eax
8010942f:	25 ff 0f 00 00       	and    $0xfff,%eax
80109434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109437:	e8 ec 97 ff ff       	call   80102c28 <kalloc>
8010943c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010943f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109443:	74 6d                	je     801094b2 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109445:	83 ec 0c             	sub    $0xc,%esp
80109448:	ff 75 e8             	pushl  -0x18(%ebp)
8010944b:	e8 ac f3 ff ff       	call   801087fc <p2v>
80109450:	83 c4 10             	add    $0x10,%esp
80109453:	83 ec 04             	sub    $0x4,%esp
80109456:	68 00 10 00 00       	push   $0x1000
8010945b:	50                   	push   %eax
8010945c:	ff 75 e0             	pushl  -0x20(%ebp)
8010945f:	e8 ce ca ff ff       	call   80105f32 <memmove>
80109464:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109467:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010946a:	83 ec 0c             	sub    $0xc,%esp
8010946d:	ff 75 e0             	pushl  -0x20(%ebp)
80109470:	e8 7a f3 ff ff       	call   801087ef <v2p>
80109475:	83 c4 10             	add    $0x10,%esp
80109478:	89 c2                	mov    %eax,%edx
8010947a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010947d:	83 ec 0c             	sub    $0xc,%esp
80109480:	53                   	push   %ebx
80109481:	52                   	push   %edx
80109482:	68 00 10 00 00       	push   $0x1000
80109487:	50                   	push   %eax
80109488:	ff 75 f0             	pushl  -0x10(%ebp)
8010948b:	e8 8e f8 ff ff       	call   80108d1e <mappages>
80109490:	83 c4 20             	add    $0x20,%esp
80109493:	85 c0                	test   %eax,%eax
80109495:	78 1e                	js     801094b5 <copyuvm+0xf9>
80109497:	eb 01                	jmp    8010949a <copyuvm+0xde>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
    //  continue;
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      continue;
80109499:	90                   	nop
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010949a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801094a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801094a7:	0f 82 3a ff ff ff    	jb     801093e7 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801094ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b0:	eb 17                	jmp    801094c9 <copyuvm+0x10d>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801094b2:	90                   	nop
801094b3:	eb 01                	jmp    801094b6 <copyuvm+0xfa>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801094b5:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801094b6:	83 ec 0c             	sub    $0xc,%esp
801094b9:	ff 75 f0             	pushl  -0x10(%ebp)
801094bc:	e8 1a fe ff ff       	call   801092db <freevm>
801094c1:	83 c4 10             	add    $0x10,%esp
  return 0;
801094c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801094c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801094cc:	c9                   	leave  
801094cd:	c3                   	ret    

801094ce <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801094ce:	55                   	push   %ebp
801094cf:	89 e5                	mov    %esp,%ebp
801094d1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801094d4:	83 ec 04             	sub    $0x4,%esp
801094d7:	6a 00                	push   $0x0
801094d9:	ff 75 0c             	pushl  0xc(%ebp)
801094dc:	ff 75 08             	pushl  0x8(%ebp)
801094df:	e8 9a f7 ff ff       	call   80108c7e <walkpgdir>
801094e4:	83 c4 10             	add    $0x10,%esp
801094e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801094ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ed:	8b 00                	mov    (%eax),%eax
801094ef:	83 e0 01             	and    $0x1,%eax
801094f2:	85 c0                	test   %eax,%eax
801094f4:	75 07                	jne    801094fd <uva2ka+0x2f>
    return 0;
801094f6:	b8 00 00 00 00       	mov    $0x0,%eax
801094fb:	eb 29                	jmp    80109526 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801094fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109500:	8b 00                	mov    (%eax),%eax
80109502:	83 e0 04             	and    $0x4,%eax
80109505:	85 c0                	test   %eax,%eax
80109507:	75 07                	jne    80109510 <uva2ka+0x42>
    return 0;
80109509:	b8 00 00 00 00       	mov    $0x0,%eax
8010950e:	eb 16                	jmp    80109526 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109513:	8b 00                	mov    (%eax),%eax
80109515:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010951a:	83 ec 0c             	sub    $0xc,%esp
8010951d:	50                   	push   %eax
8010951e:	e8 d9 f2 ff ff       	call   801087fc <p2v>
80109523:	83 c4 10             	add    $0x10,%esp
}
80109526:	c9                   	leave  
80109527:	c3                   	ret    

80109528 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109528:	55                   	push   %ebp
80109529:	89 e5                	mov    %esp,%ebp
8010952b:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010952e:	8b 45 10             	mov    0x10(%ebp),%eax
80109531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109534:	eb 7f                	jmp    801095b5 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109536:	8b 45 0c             	mov    0xc(%ebp),%eax
80109539:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010953e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109541:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109544:	83 ec 08             	sub    $0x8,%esp
80109547:	50                   	push   %eax
80109548:	ff 75 08             	pushl  0x8(%ebp)
8010954b:	e8 7e ff ff ff       	call   801094ce <uva2ka>
80109550:	83 c4 10             	add    $0x10,%esp
80109553:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109556:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010955a:	75 07                	jne    80109563 <copyout+0x3b>
      return -1;
8010955c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109561:	eb 61                	jmp    801095c4 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109563:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109566:	2b 45 0c             	sub    0xc(%ebp),%eax
80109569:	05 00 10 00 00       	add    $0x1000,%eax
8010956e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109574:	3b 45 14             	cmp    0x14(%ebp),%eax
80109577:	76 06                	jbe    8010957f <copyout+0x57>
      n = len;
80109579:	8b 45 14             	mov    0x14(%ebp),%eax
8010957c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010957f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109582:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109585:	89 c2                	mov    %eax,%edx
80109587:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010958a:	01 d0                	add    %edx,%eax
8010958c:	83 ec 04             	sub    $0x4,%esp
8010958f:	ff 75 f0             	pushl  -0x10(%ebp)
80109592:	ff 75 f4             	pushl  -0xc(%ebp)
80109595:	50                   	push   %eax
80109596:	e8 97 c9 ff ff       	call   80105f32 <memmove>
8010959b:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010959e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095a1:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801095a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095a7:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801095aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095ad:	05 00 10 00 00       	add    $0x1000,%eax
801095b2:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801095b5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801095b9:	0f 85 77 ff ff ff    	jne    80109536 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801095bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801095c4:	c9                   	leave  
801095c5:	c3                   	ret    

801095c6 <unmappages>:



int
unmappages(pde_t *pgdir, void *va, uint size)
{
801095c6:	55                   	push   %ebp
801095c7:	89 e5                	mov    %esp,%ebp
801095c9:	83 ec 18             	sub    $0x18,%esp
  uint oldsz,newsz;

  oldsz= (uint) va+size;
801095cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801095cf:	8b 45 10             	mov    0x10(%ebp),%eax
801095d2:	01 d0                	add    %edx,%eax
801095d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  newsz=(uint) va;
801095d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801095da:	89 45 f0             	mov    %eax,-0x10(%ebp)

  newsz=deallocuvm(pgdir,oldsz,newsz);
801095dd:	83 ec 04             	sub    $0x4,%esp
801095e0:	ff 75 f0             	pushl  -0x10(%ebp)
801095e3:	ff 75 f4             	pushl  -0xc(%ebp)
801095e6:	ff 75 08             	pushl  0x8(%ebp)
801095e9:	e8 30 fc ff ff       	call   8010921e <deallocuvm>
801095ee:	83 c4 10             	add    $0x10,%esp
801095f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(!newsz)
801095f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801095f8:	75 07                	jne    80109601 <unmappages+0x3b>
    return -1;
801095fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095ff:	eb 03                	jmp    80109604 <unmappages+0x3e>

  return newsz;
80109601:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109604:	c9                   	leave  
80109605:	c3                   	ret    

80109606 <pgflags>:



pte_t*
pgflags(pde_t *pgdir, const void *va,uint flag)
{
80109606:	55                   	push   %ebp
80109607:	89 e5                	mov    %esp,%ebp
80109609:	83 ec 18             	sub    $0x18,%esp
  pte_t* pte;

  if((pte=walkpgdir(pgdir,(char*)va,0))!=0){
8010960c:	83 ec 04             	sub    $0x4,%esp
8010960f:	6a 00                	push   $0x0
80109611:	ff 75 0c             	pushl  0xc(%ebp)
80109614:	ff 75 08             	pushl  0x8(%ebp)
80109617:	e8 62 f6 ff ff       	call   80108c7e <walkpgdir>
8010961c:	83 c4 10             	add    $0x10,%esp
8010961f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109622:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109626:	74 11                	je     80109639 <pgflags+0x33>
    if(*pte & flag)
80109628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962b:	8b 00                	mov    (%eax),%eax
8010962d:	23 45 10             	and    0x10(%ebp),%eax
80109630:	85 c0                	test   %eax,%eax
80109632:	74 05                	je     80109639 <pgflags+0x33>
      return pte;
80109634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109637:	eb 05                	jmp    8010963e <pgflags+0x38>
  }
  return 0;
80109639:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010963e:	c9                   	leave  
8010963f:	c3                   	ret    
