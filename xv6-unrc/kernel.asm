
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
8010003d:	68 80 96 10 80       	push   $0x80109680
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 e1 5b 00 00       	call   80105c2d <initlock>
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
801000c1:	e8 89 5b 00 00       	call   80105c4f <acquire>
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
8010010c:	e8 a5 5b 00 00       	call   80105cb6 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 67 53 00 00       	call   80105493 <sleep>
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
80100188:	e8 29 5b 00 00       	call   80105cb6 <release>
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
801001aa:	68 87 96 10 80       	push   $0x80109687
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
80100204:	68 98 96 10 80       	push   $0x80109698
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
80100243:	68 9f 96 10 80       	push   $0x8010969f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 f5 59 00 00       	call   80105c4f <acquire>
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
801002b9:	e8 e1 52 00 00       	call   8010559f <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 e8 59 00 00       	call   80105cb6 <release>
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
801003e2:	e8 68 58 00 00       	call   80105c4f <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 a6 96 10 80       	push   $0x801096a6
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
801004cd:	c7 45 ec af 96 10 80 	movl   $0x801096af,-0x14(%ebp)
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
8010055b:	e8 56 57 00 00       	call   80105cb6 <release>
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
8010058b:	68 b6 96 10 80       	push   $0x801096b6
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
801005aa:	68 c5 96 10 80       	push   $0x801096c5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 41 57 00 00       	call   80105d08 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 c7 96 10 80       	push   $0x801096c7
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
801006db:	e8 91 58 00 00       	call   80105f71 <memmove>
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
80100705:	e8 a8 57 00 00       	call   80105eb2 <memset>
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
8010079a:	e8 f9 74 00 00       	call   80107c98 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 ec 74 00 00       	call   80107c98 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 df 74 00 00       	call   80107c98 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 cf 74 00 00       	call   80107c98 <uartputc>
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
801007eb:	e8 5f 54 00 00       	call   80105c4f <acquire>
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
8010081e:	e8 3e 4e 00 00       	call   80105661 <procdump>
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
80100931:	e8 69 4c 00 00       	call   8010559f <wakeup>
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
80100954:	e8 5d 53 00 00       	call   80105cb6 <release>
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
80100981:	e8 c9 52 00 00       	call   80105c4f <acquire>
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
801009a3:	e8 0e 53 00 00       	call   80105cb6 <release>
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
801009d0:	e8 be 4a 00 00       	call   80105493 <sleep>
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
80100a4e:	e8 63 52 00 00       	call   80105cb6 <release>
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
80100a8c:	e8 be 51 00 00       	call   80105c4f <acquire>
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
80100ace:	e8 e3 51 00 00       	call   80105cb6 <release>
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
80100af2:	68 cb 96 10 80       	push   $0x801096cb
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 2c 51 00 00       	call   80105c2d <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 d3 96 10 80       	push   $0x801096d3
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 17 51 00 00       	call   80105c2d <initlock>
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
80100bcf:	e8 19 82 00 00       	call   80108ded <setupkvm>
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
80100c55:	e8 3a 85 00 00       	call   80109194 <allocuvm>
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
80100c88:	e8 30 84 00 00       	call   801090bd <loaduvm>
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
80100d16:	e8 79 84 00 00       	call   80109194 <allocuvm>
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
80100d5c:	e8 9e 53 00 00       	call   801060ff <strlen>
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
80100d89:	e8 71 53 00 00       	call   801060ff <strlen>
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
80100daf:	e8 b3 87 00 00       	call   80109567 <copyout>
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
80100e4b:	e8 17 87 00 00       	call   80109567 <copyout>
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
80100e9c:	e8 14 52 00 00       	call   801060b5 <safestrcpy>
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
80100ef2:	e8 dd 7f 00 00       	call   80108ed4 <switchuvm>
80100ef7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100efa:	83 ec 0c             	sub    $0xc,%esp
80100efd:	ff 75 d0             	pushl  -0x30(%ebp)
80100f00:	e8 15 84 00 00       	call   8010931a <freevm>
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
80100f3a:	e8 db 83 00 00       	call   8010931a <freevm>
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
80100f6b:	68 d9 96 10 80       	push   $0x801096d9
80100f70:	68 60 18 11 80       	push   $0x80111860
80100f75:	e8 b3 4c 00 00       	call   80105c2d <initlock>
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
80100f8e:	e8 bc 4c 00 00       	call   80105c4f <acquire>
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
80100fbb:	e8 f6 4c 00 00       	call   80105cb6 <release>
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
80100fde:	e8 d3 4c 00 00       	call   80105cb6 <release>
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
80100ffb:	e8 4f 4c 00 00       	call   80105c4f <acquire>
80101000:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	8b 40 04             	mov    0x4(%eax),%eax
80101009:	85 c0                	test   %eax,%eax
8010100b:	7f 0d                	jg     8010101a <filedup+0x2d>
    panic("filedup");
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 e0 96 10 80       	push   $0x801096e0
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
80101031:	e8 80 4c 00 00       	call   80105cb6 <release>
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
8010104c:	e8 fe 4b 00 00       	call   80105c4f <acquire>
80101051:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	85 c0                	test   %eax,%eax
8010105c:	7f 0d                	jg     8010106b <fileclose+0x2d>
    panic("fileclose");
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 e8 96 10 80       	push   $0x801096e8
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
8010108c:	e8 25 4c 00 00       	call   80105cb6 <release>
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
801010da:	e8 d7 4b 00 00       	call   80105cb6 <release>
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
80101229:	68 f2 96 10 80       	push   $0x801096f2
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
8010132c:	68 fb 96 10 80       	push   $0x801096fb
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
80101362:	68 0b 97 10 80       	push   $0x8010970b
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
801013f5:	e8 77 4b 00 00       	call   80105f71 <memmove>
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
8010143b:	e8 72 4a 00 00       	call   80105eb2 <memset>
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
801015b4:	68 15 97 10 80       	push   $0x80109715
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
8010164a:	68 2b 97 10 80       	push   $0x8010972b
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
801016a4:	68 3e 97 10 80       	push   $0x8010973e
801016a9:	68 60 22 11 80       	push   $0x80112260
801016ae:	e8 7a 45 00 00       	call   80105c2d <initlock>
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
80101729:	e8 84 47 00 00       	call   80105eb2 <memset>
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
8010178e:	68 45 97 10 80       	push   $0x80109745
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
8010182e:	e8 3e 47 00 00       	call   80105f71 <memmove>
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
80101863:	e8 e7 43 00 00       	call   80105c4f <acquire>
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
801018b1:	e8 00 44 00 00       	call   80105cb6 <release>
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
801018ea:	68 57 97 10 80       	push   $0x80109757
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
80101927:	e8 8a 43 00 00       	call   80105cb6 <release>
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
80101942:	e8 08 43 00 00       	call   80105c4f <acquire>
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
80101961:	e8 50 43 00 00       	call   80105cb6 <release>
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
80101987:	68 67 97 10 80       	push   $0x80109767
8010198c:	e8 d5 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101991:	83 ec 0c             	sub    $0xc,%esp
80101994:	68 60 22 11 80       	push   $0x80112260
80101999:	e8 b1 42 00 00       	call   80105c4f <acquire>
8010199e:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019a1:	eb 13                	jmp    801019b6 <ilock+0x48>
    sleep(ip, &icache.lock);
801019a3:	83 ec 08             	sub    $0x8,%esp
801019a6:	68 60 22 11 80       	push   $0x80112260
801019ab:	ff 75 08             	pushl  0x8(%ebp)
801019ae:	e8 e0 3a 00 00       	call   80105493 <sleep>
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
801019dc:	e8 d5 42 00 00       	call   80105cb6 <release>
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
80101a83:	e8 e9 44 00 00       	call   80105f71 <memmove>
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
80101ab9:	68 6d 97 10 80       	push   $0x8010976d
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
80101aec:	68 7c 97 10 80       	push   $0x8010977c
80101af1:	e8 70 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af6:	83 ec 0c             	sub    $0xc,%esp
80101af9:	68 60 22 11 80       	push   $0x80112260
80101afe:	e8 4c 41 00 00       	call   80105c4f <acquire>
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
80101b1d:	e8 7d 3a 00 00       	call   8010559f <wakeup>
80101b22:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 60 22 11 80       	push   $0x80112260
80101b2d:	e8 84 41 00 00       	call   80105cb6 <release>
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
80101b46:	e8 04 41 00 00       	call   80105c4f <acquire>
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
80101b8e:	68 84 97 10 80       	push   $0x80109784
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
80101bb1:	e8 00 41 00 00       	call   80105cb6 <release>
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
80101be6:	e8 64 40 00 00       	call   80105c4f <acquire>
80101beb:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bf8:	83 ec 0c             	sub    $0xc,%esp
80101bfb:	ff 75 08             	pushl  0x8(%ebp)
80101bfe:	e8 9c 39 00 00       	call   8010559f <wakeup>
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
80101c1d:	e8 94 40 00 00       	call   80105cb6 <release>
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
80101d5d:	68 8e 97 10 80       	push   $0x8010978e
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
80101ff4:	e8 78 3f 00 00       	call   80105f71 <memmove>
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
80102146:	e8 26 3e 00 00       	call   80105f71 <memmove>
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
801021c6:	e8 3c 3e 00 00       	call   80106007 <strncmp>
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
801021e6:	68 a1 97 10 80       	push   $0x801097a1
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
80102215:	68 b3 97 10 80       	push   $0x801097b3
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
801022ea:	68 b3 97 10 80       	push   $0x801097b3
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
80102325:	e8 33 3d 00 00       	call   8010605d <strncpy>
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
80102351:	68 c0 97 10 80       	push   $0x801097c0
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
801023c7:	e8 a5 3b 00 00       	call   80105f71 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	pushl  -0xc(%ebp)
801023db:	ff 75 0c             	pushl  0xc(%ebp)
801023de:	e8 8e 3b 00 00       	call   80105f71 <memmove>
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
80102633:	68 c8 97 10 80       	push   $0x801097c8
80102638:	68 20 c6 10 80       	push   $0x8010c620
8010263d:	e8 eb 35 00 00       	call   80105c2d <initlock>
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
801026e7:	68 cc 97 10 80       	push   $0x801097cc
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
80102808:	e8 42 34 00 00       	call   80105c4f <acquire>
8010280d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102810:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102815:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102818:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010281c:	75 15                	jne    80102833 <ideintr+0x39>
    release(&idelock);
8010281e:	83 ec 0c             	sub    $0xc,%esp
80102821:	68 20 c6 10 80       	push   $0x8010c620
80102826:	e8 8b 34 00 00       	call   80105cb6 <release>
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
8010289b:	e8 ff 2c 00 00       	call   8010559f <wakeup>
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
801028c5:	e8 ec 33 00 00       	call   80105cb6 <release>
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
801028e4:	68 d5 97 10 80       	push   $0x801097d5
801028e9:	e8 78 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028ee:	8b 45 08             	mov    0x8(%ebp),%eax
801028f1:	8b 00                	mov    (%eax),%eax
801028f3:	83 e0 06             	and    $0x6,%eax
801028f6:	83 f8 02             	cmp    $0x2,%eax
801028f9:	75 0d                	jne    80102908 <iderw+0x39>
    panic("iderw: nothing to do");
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 e9 97 10 80       	push   $0x801097e9
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
8010291e:	68 fe 97 10 80       	push   $0x801097fe
80102923:	e8 3e dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102928:	83 ec 0c             	sub    $0xc,%esp
8010292b:	68 20 c6 10 80       	push   $0x8010c620
80102930:	e8 1a 33 00 00       	call   80105c4f <acquire>
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
8010298c:	e8 02 2b 00 00       	call   80105493 <sleep>
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
801029a9:	e8 08 33 00 00       	call   80105cb6 <release>
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
80102a3a:	68 1c 98 10 80       	push   $0x8010981c
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
80102afa:	68 4e 98 10 80       	push   $0x8010984e
80102aff:	68 40 32 11 80       	push   $0x80113240
80102b04:	e8 24 31 00 00       	call   80105c2d <initlock>
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
80102bbb:	68 53 98 10 80       	push   $0x80109853
80102bc0:	e8 a1 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bc5:	83 ec 04             	sub    $0x4,%esp
80102bc8:	68 00 10 00 00       	push   $0x1000
80102bcd:	6a 01                	push   $0x1
80102bcf:	ff 75 08             	pushl  0x8(%ebp)
80102bd2:	e8 db 32 00 00       	call   80105eb2 <memset>
80102bd7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102bda:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bdf:	85 c0                	test   %eax,%eax
80102be1:	74 10                	je     80102bf3 <kfree+0x68>
    acquire(&kmem.lock);
80102be3:	83 ec 0c             	sub    $0xc,%esp
80102be6:	68 40 32 11 80       	push   $0x80113240
80102beb:	e8 5f 30 00 00       	call   80105c4f <acquire>
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
80102c1d:	e8 94 30 00 00       	call   80105cb6 <release>
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
80102c3f:	e8 0b 30 00 00       	call   80105c4f <acquire>
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
80102c70:	e8 41 30 00 00       	call   80105cb6 <release>
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
80102fbb:	68 5c 98 10 80       	push   $0x8010985c
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
801031e6:	e8 2e 2d 00 00       	call   80105f19 <memcmp>
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
801032fa:	68 88 98 10 80       	push   $0x80109888
801032ff:	68 80 32 11 80       	push   $0x80113280
80103304:	e8 24 29 00 00       	call   80105c2d <initlock>
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
801033b7:	e8 b5 2b 00 00       	call   80105f71 <memmove>
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
80103525:	e8 25 27 00 00       	call   80105c4f <acquire>
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
80103543:	e8 4b 1f 00 00       	call   80105493 <sleep>
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
80103578:	e8 16 1f 00 00       	call   80105493 <sleep>
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
80103597:	e8 1a 27 00 00       	call   80105cb6 <release>
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
801035b8:	e8 92 26 00 00       	call   80105c4f <acquire>
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
801035d9:	68 8c 98 10 80       	push   $0x8010988c
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
80103607:	e8 93 1f 00 00       	call   8010559f <wakeup>
8010360c:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010360f:	83 ec 0c             	sub    $0xc,%esp
80103612:	68 80 32 11 80       	push   $0x80113280
80103617:	e8 9a 26 00 00       	call   80105cb6 <release>
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
80103632:	e8 18 26 00 00       	call   80105c4f <acquire>
80103637:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010363a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103641:	00 00 00 
    wakeup(&log);
80103644:	83 ec 0c             	sub    $0xc,%esp
80103647:	68 80 32 11 80       	push   $0x80113280
8010364c:	e8 4e 1f 00 00       	call   8010559f <wakeup>
80103651:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103654:	83 ec 0c             	sub    $0xc,%esp
80103657:	68 80 32 11 80       	push   $0x80113280
8010365c:	e8 55 26 00 00       	call   80105cb6 <release>
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
801036d8:	e8 94 28 00 00       	call   80105f71 <memmove>
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
80103774:	68 9b 98 10 80       	push   $0x8010989b
80103779:	e8 e8 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010377e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103783:	85 c0                	test   %eax,%eax
80103785:	7f 0d                	jg     80103794 <log_write+0x45>
    panic("log_write outside of trans");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 b1 98 10 80       	push   $0x801098b1
8010378f:	e8 d2 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	68 80 32 11 80       	push   $0x80113280
8010379c:	e8 ae 24 00 00       	call   80105c4f <acquire>
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
8010381a:	e8 97 24 00 00       	call   80105cb6 <release>
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
8010387f:	e8 1b 56 00 00       	call   80108e9f <kvmalloc>
  mpinit();        // collect info about this machine
80103884:	e8 f6 06 00 00       	call   80103f7f <mpinit>
  lapicinit();
80103889:	e8 e2 f5 ff ff       	call   80102e70 <lapicinit>
  seginit();       // set up segments
8010388e:	e8 b5 4f 00 00       	call   80108848 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103893:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103899:	0f b6 00             	movzbl (%eax),%eax
8010389c:	0f b6 c0             	movzbl %al,%eax
8010389f:	83 ec 08             	sub    $0x8,%esp
801038a2:	50                   	push   %eax
801038a3:	68 cc 98 10 80       	push   $0x801098cc
801038a8:	e8 19 cb ff ff       	call   801003c6 <cprintf>
801038ad:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038b0:	e8 20 09 00 00       	call   801041d5 <picinit>
  ioapicinit();    // another interrupt controller
801038b5:	e8 2c f1 ff ff       	call   801029e6 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038ba:	e8 2a d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801038bf:	e8 e0 42 00 00       	call   80107ba4 <uartinit>
  pinit();         // process table
801038c4:	e8 95 10 00 00       	call   8010495e <pinit>
  tvinit();        // trap vectors
801038c9:	e8 19 3c 00 00       	call   801074e7 <tvinit>
  binit();         // buffer cache
801038ce:	e8 61 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038d3:	e8 8a d6 ff ff       	call   80100f62 <fileinit>
  seminit();       // semaphore table
801038d8:	e8 a0 1e 00 00       	call   8010577d <seminit>
  iinit();         // inode cache
801038dd:	e8 b9 dd ff ff       	call   8010169b <iinit>
  ideinit();       // disk
801038e2:	e8 43 ed ff ff       	call   8010262a <ideinit>
  if(!ismp)
801038e7:	a1 64 33 11 80       	mov    0x80113364,%eax
801038ec:	85 c0                	test   %eax,%eax
801038ee:	75 05                	jne    801038f5 <main+0x9c>
    timerinit();   // uniprocessor timer
801038f0:	e8 4f 3b 00 00       	call   80107444 <timerinit>
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
8010391f:	e8 93 55 00 00       	call   80108eb7 <switchkvm>
  seginit();
80103924:	e8 1f 4f 00 00       	call   80108848 <seginit>
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
80103949:	68 e3 98 10 80       	push   $0x801098e3
8010394e:	e8 73 ca ff ff       	call   801003c6 <cprintf>
80103953:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103956:	e8 02 3d 00 00       	call   8010765d <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010395b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103961:	05 a8 00 00 00       	add    $0xa8,%eax
80103966:	83 ec 08             	sub    $0x8,%esp
80103969:	6a 01                	push   $0x1
8010396b:	50                   	push   %eax
8010396c:	e8 ce fe ff ff       	call   8010383f <xchg>
80103971:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103974:	e8 0c 19 00 00       	call   80105285 <scheduler>

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
801039a1:	e8 cb 25 00 00       	call   80105f71 <memmove>
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
80103c51:	e8 ef 59 00 00       	call   80109645 <pgflags>
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
80103ce4:	e8 1c 59 00 00       	call   80109605 <unmappages>
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
80103dd8:	68 f4 98 10 80       	push   $0x801098f4
80103ddd:	ff 75 f4             	pushl  -0xc(%ebp)
80103de0:	e8 34 21 00 00       	call   80105f19 <memcmp>
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
80103f16:	68 f9 98 10 80       	push   $0x801098f9
80103f1b:	ff 75 f0             	pushl  -0x10(%ebp)
80103f1e:	e8 f6 1f 00 00       	call   80105f19 <memcmp>
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
80103ff2:	8b 04 85 3c 99 10 80 	mov    -0x7fef66c4(,%eax,4),%eax
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
80104028:	68 fe 98 10 80       	push   $0x801098fe
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
801040bb:	68 1c 99 10 80       	push   $0x8010991c
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
8010435c:	68 50 99 10 80       	push   $0x80109950
80104361:	50                   	push   %eax
80104362:	e8 c6 18 00 00       	call   80105c2d <initlock>
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
8010441e:	e8 2c 18 00 00       	call   80105c4f <acquire>
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
80104445:	e8 55 11 00 00       	call   8010559f <wakeup>
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
80104468:	e8 32 11 00 00       	call   8010559f <wakeup>
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
80104491:	e8 20 18 00 00       	call   80105cb6 <release>
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
801044b0:	e8 01 18 00 00       	call   80105cb6 <release>
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
801044c8:	e8 82 17 00 00       	call   80105c4f <acquire>
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
801044fd:	e8 b4 17 00 00       	call   80105cb6 <release>
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
8010451b:	e8 7f 10 00 00       	call   8010559f <wakeup>
80104520:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104523:	8b 45 08             	mov    0x8(%ebp),%eax
80104526:	8b 55 08             	mov    0x8(%ebp),%edx
80104529:	81 c2 38 02 00 00    	add    $0x238,%edx
8010452f:	83 ec 08             	sub    $0x8,%esp
80104532:	50                   	push   %eax
80104533:	52                   	push   %edx
80104534:	e8 5a 0f 00 00       	call   80105493 <sleep>
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
8010459d:	e8 fd 0f 00 00       	call   8010559f <wakeup>
801045a2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801045a5:	8b 45 08             	mov    0x8(%ebp),%eax
801045a8:	83 ec 0c             	sub    $0xc,%esp
801045ab:	50                   	push   %eax
801045ac:	e8 05 17 00 00       	call   80105cb6 <release>
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
801045c7:	e8 83 16 00 00       	call   80105c4f <acquire>
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
801045e5:	e8 cc 16 00 00       	call   80105cb6 <release>
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
80104608:	e8 86 0e 00 00       	call   80105493 <sleep>
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
8010469c:	e8 fe 0e 00 00       	call   8010559f <wakeup>
801046a1:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801046a4:	8b 45 08             	mov    0x8(%ebp),%eax
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	50                   	push   %eax
801046ab:	e8 06 16 00 00       	call   80105cb6 <release>
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
80104798:	68 58 99 10 80       	push   $0x80109958
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
8010481f:	68 64 99 10 80       	push   $0x80109964
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
80104886:	e8 c4 13 00 00       	call   80105c4f <acquire>
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
801048fb:	68 84 99 10 80       	push   $0x80109984
80104900:	e8 61 bc ff ff       	call   80100566 <panic>
        procdump();
80104905:	e8 57 0d 00 00       	call   80105661 <procdump>
        cprintf("/**************************************************************/\n");
8010490a:	83 ec 0c             	sub    $0xc,%esp
8010490d:	68 bc 99 10 80       	push   $0x801099bc
80104912:	e8 af ba ff ff       	call   801003c6 <cprintf>
80104917:	83 c4 10             	add    $0x10,%esp
        levelupdate(p);  // call to levelupdate
8010491a:	83 ec 0c             	sub    $0xc,%esp
8010491d:	ff 75 f0             	pushl  -0x10(%ebp)
80104920:	e8 09 ff ff ff       	call   8010482e <levelupdate>
80104925:	83 c4 10             	add    $0x10,%esp
        procdump();
80104928:	e8 34 0d 00 00       	call   80105661 <procdump>
        cprintf("/--------------------------------------------------------------/\n");
8010492d:	83 ec 0c             	sub    $0xc,%esp
80104930:	68 00 9a 10 80       	push   $0x80109a00
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
80104953:	e8 5e 13 00 00       	call   80105cb6 <release>
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
80104967:	68 42 9a 10 80       	push   $0x80109a42
8010496c:	68 80 39 11 80       	push   $0x80113980
80104971:	e8 b7 12 00 00       	call   80105c2d <initlock>
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
8010498a:	e8 c0 12 00 00       	call   80105c4f <acquire>
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
801049bd:	e8 f4 12 00 00       	call   80105cb6 <release>
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
801049f6:	e8 bb 12 00 00       	call   80105cb6 <release>
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
80104a45:	ba a1 74 10 80       	mov    $0x801074a1,%edx
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
80104a6a:	e8 43 14 00 00       	call   80105eb2 <memset>
80104a6f:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a75:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a78:	ba 62 54 10 80       	mov    $0x80105462,%edx
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
80104ab0:	e8 38 43 00 00       	call   80108ded <setupkvm>
80104ab5:	89 c2                	mov    %eax,%edx
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	89 50 04             	mov    %edx,0x4(%eax)
80104abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac0:	8b 40 04             	mov    0x4(%eax),%eax
80104ac3:	85 c0                	test   %eax,%eax
80104ac5:	75 0d                	jne    80104ad4 <userinit+0x3a>
    panic("userinit: out of memory?");
80104ac7:	83 ec 0c             	sub    $0xc,%esp
80104aca:	68 49 9a 10 80       	push   $0x80109a49
80104acf:	e8 92 ba ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104ad4:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adc:	8b 40 04             	mov    0x4(%eax),%eax
80104adf:	83 ec 04             	sub    $0x4,%esp
80104ae2:	52                   	push   %edx
80104ae3:	68 00 c5 10 80       	push   $0x8010c500
80104ae8:	50                   	push   %eax
80104ae9:	e8 59 45 00 00       	call   80109047 <inituvm>
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
80104b08:	e8 a5 13 00 00       	call   80105eb2 <memset>
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
80104b82:	68 62 9a 10 80       	push   $0x80109a62
80104b87:	50                   	push   %eax
80104b88:	e8 28 15 00 00       	call   801060b5 <safestrcpy>
80104b8d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104b90:	83 ec 0c             	sub    $0xc,%esp
80104b93:	68 6b 9a 10 80       	push   $0x80109a6b
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
80104be9:	e8 a6 45 00 00       	call   80109194 <allocuvm>
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
80104c20:	e8 38 46 00 00       	call   8010925d <deallocuvm>
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
80104c4d:	e8 82 42 00 00       	call   80108ed4 <switchuvm>
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
80104c93:	e8 63 47 00 00       	call   801093fb <copyuvm>
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
80104dba:	e8 e5 0d 00 00       	call   80105ba4 <semdup>
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
80104ee8:	e8 c8 11 00 00       	call   801060b5 <safestrcpy>
80104eed:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ef3:	8b 40 10             	mov    0x10(%eax),%eax
80104ef6:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104ef9:	83 ec 0c             	sub    $0xc,%esp
80104efc:	68 80 39 11 80       	push   $0x80113980
80104f01:	e8 49 0d 00 00       	call   80105c4f <acquire>
80104f06:	83 c4 10             	add    $0x10,%esp
  make_runnable(np);
80104f09:	83 ec 0c             	sub    $0xc,%esp
80104f0c:	ff 75 e0             	pushl  -0x20(%ebp)
80104f0f:	e8 be f7 ff ff       	call   801046d2 <make_runnable>
80104f14:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f17:	83 ec 0c             	sub    $0xc,%esp
80104f1a:	68 80 39 11 80       	push   $0x80113980
80104f1f:	e8 92 0d 00 00       	call   80105cb6 <release>
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
80104f4b:	68 6d 9a 10 80       	push   $0x80109a6d
80104f50:	e8 11 b6 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104f55:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f5c:	eb 48                	jmp    80104fa6 <exit+0x74>
    if(proc->ofile[fd]){
80104f5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f64:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f67:	83 c2 08             	add    $0x8,%edx
80104f6a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f6e:	85 c0                	test   %eax,%eax
80104f70:	74 30                	je     80104fa2 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104f72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f78:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f7b:	83 c2 08             	add    $0x8,%edx
80104f7e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f82:	83 ec 0c             	sub    $0xc,%esp
80104f85:	50                   	push   %eax
80104f86:	e8 b3 c0 ff ff       	call   8010103e <fileclose>
80104f8b:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104f8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f97:	83 c2 08             	add    $0x8,%edx
80104f9a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104fa1:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104fa2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104fa6:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104faa:	7e b2                	jle    80104f5e <exit+0x2c>
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104fac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104fb3:	eb 48                	jmp    80104ffd <exit+0xcb>
    if(proc->osemaphore[idsem]){
80104fb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fbb:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fbe:	83 c2 20             	add    $0x20,%edx
80104fc1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fc5:	85 c0                	test   %eax,%eax
80104fc7:	74 30                	je     80104ff9 <exit+0xc7>
      semclose(proc->osemaphore[idsem]);
80104fc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd2:	83 c2 20             	add    $0x20,%edx
80104fd5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fd9:	83 ec 0c             	sub    $0xc,%esp
80104fdc:	50                   	push   %eax
80104fdd:	e8 73 0b 00 00       	call   80105b55 <semclose>
80104fe2:	83 c4 10             	add    $0x10,%esp
      proc->osemaphore[idsem] = 0;
80104fe5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104feb:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fee:	83 c2 20             	add    $0x20,%edx
80104ff1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104ff8:	00 
      proc->ofile[fd] = 0;
    }
  }

  // Close all open semaphore.
  for(idsem = 0; idsem < MAXPROCSEM; idsem++){
80104ff9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104ffd:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80105001:	7e b2                	jle    80104fb5 <exit+0x83>
    if(proc->osemaphore[idsem]){
      semclose(proc->osemaphore[idsem]);
      proc->osemaphore[idsem] = 0;
    }
  }
  for(i = 0; i < MAXMAPPEDFILES; i++){
80105003:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
8010500a:	e9 84 00 00 00       	jmp    80105093 <exit+0x161>
    if(proc->ommap[i].pfile){
8010500f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105016:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105019:	89 d0                	mov    %edx,%eax
8010501b:	01 c0                	add    %eax,%eax
8010501d:	01 d0                	add    %edx,%eax
8010501f:	c1 e0 02             	shl    $0x2,%eax
80105022:	01 c8                	add    %ecx,%eax
80105024:	05 a0 00 00 00       	add    $0xa0,%eax
80105029:	8b 00                	mov    (%eax),%eax
8010502b:	85 c0                	test   %eax,%eax
8010502d:	74 60                	je     8010508f <exit+0x15d>
      proc->ommap[i].pfile = 0;
8010502f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105036:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105039:	89 d0                	mov    %edx,%eax
8010503b:	01 c0                	add    %eax,%eax
8010503d:	01 d0                	add    %edx,%eax
8010503f:	c1 e0 02             	shl    $0x2,%eax
80105042:	01 c8                	add    %ecx,%eax
80105044:	05 a0 00 00 00       	add    $0xa0,%eax
80105049:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->ommap[i].va = 0;
8010504f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105056:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105059:	89 d0                	mov    %edx,%eax
8010505b:	01 c0                	add    %eax,%eax
8010505d:	01 d0                	add    %edx,%eax
8010505f:	c1 e0 02             	shl    $0x2,%eax
80105062:	01 c8                	add    %ecx,%eax
80105064:	05 a4 00 00 00       	add    $0xa4,%eax
80105069:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->ommap[i].sz = 0;
8010506f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105076:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105079:	89 d0                	mov    %edx,%eax
8010507b:	01 c0                	add    %eax,%eax
8010507d:	01 d0                	add    %edx,%eax
8010507f:	c1 e0 02             	shl    $0x2,%eax
80105082:	01 c8                	add    %ecx,%eax
80105084:	05 a8 00 00 00       	add    $0xa8,%eax
80105089:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(proc->osemaphore[idsem]){
      semclose(proc->osemaphore[idsem]);
      proc->osemaphore[idsem] = 0;
    }
  }
  for(i = 0; i < MAXMAPPEDFILES; i++){
8010508f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80105093:	83 7d e8 04          	cmpl   $0x4,-0x18(%ebp)
80105097:	0f 8e 72 ff ff ff    	jle    8010500f <exit+0xdd>
      proc->ommap[i].va = 0;
      proc->ommap[i].sz = 0;
    }
  }

  begin_op();
8010509d:	e8 75 e4 ff ff       	call   80103517 <begin_op>
  iput(proc->cwd);
801050a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a8:	8b 40 68             	mov    0x68(%eax),%eax
801050ab:	83 ec 0c             	sub    $0xc,%esp
801050ae:	50                   	push   %eax
801050af:	e8 84 ca ff ff       	call   80101b38 <iput>
801050b4:	83 c4 10             	add    $0x10,%esp
  end_op();
801050b7:	e8 e7 e4 ff ff       	call   801035a3 <end_op>
  proc->cwd = 0;
801050bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801050c9:	83 ec 0c             	sub    $0xc,%esp
801050cc:	68 80 39 11 80       	push   $0x80113980
801050d1:	e8 79 0b 00 00       	call   80105c4f <acquire>
801050d6:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801050d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050df:	8b 40 14             	mov    0x14(%eax),%eax
801050e2:	83 ec 0c             	sub    $0xc,%esp
801050e5:	50                   	push   %eax
801050e6:	e8 54 04 00 00       	call   8010553f <wakeup1>
801050eb:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ee:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801050f5:	eb 3f                	jmp    80105136 <exit+0x204>
    if(p->parent == proc){
801050f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fa:	8b 50 14             	mov    0x14(%eax),%edx
801050fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105103:	39 c2                	cmp    %eax,%edx
80105105:	75 28                	jne    8010512f <exit+0x1fd>
      p->parent = initproc;
80105107:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
8010510d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105110:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105116:	8b 40 0c             	mov    0xc(%eax),%eax
80105119:	83 f8 05             	cmp    $0x5,%eax
8010511c:	75 11                	jne    8010512f <exit+0x1fd>
        wakeup1(initproc);
8010511e:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80105123:	83 ec 0c             	sub    $0xc,%esp
80105126:	50                   	push   %eax
80105127:	e8 13 04 00 00       	call   8010553f <wakeup1>
8010512c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010512f:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
80105136:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010513d:	72 b8                	jb     801050f7 <exit+0x1c5>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010513f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105145:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010514c:	e8 f4 01 00 00       	call   80105345 <sched>
  panic("zombie exit");
80105151:	83 ec 0c             	sub    $0xc,%esp
80105154:	68 7a 9a 10 80       	push   $0x80109a7a
80105159:	e8 08 b4 ff ff       	call   80100566 <panic>

8010515e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010515e:	55                   	push   %ebp
8010515f:	89 e5                	mov    %esp,%ebp
80105161:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105164:	83 ec 0c             	sub    $0xc,%esp
80105167:	68 80 39 11 80       	push   $0x80113980
8010516c:	e8 de 0a 00 00       	call   80105c4f <acquire>
80105171:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105174:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010517b:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105182:	e9 a9 00 00 00       	jmp    80105230 <wait+0xd2>
      if(p->parent != proc)
80105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518a:	8b 50 14             	mov    0x14(%eax),%edx
8010518d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105193:	39 c2                	cmp    %eax,%edx
80105195:	0f 85 8d 00 00 00    	jne    80105228 <wait+0xca>
        continue;
      havekids = 1;
8010519b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801051a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a5:	8b 40 0c             	mov    0xc(%eax),%eax
801051a8:	83 f8 05             	cmp    $0x5,%eax
801051ab:	75 7c                	jne    80105229 <wait+0xcb>
        // Found one.
        pid = p->pid;
801051ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b0:	8b 40 10             	mov    0x10(%eax),%eax
801051b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801051b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b9:	8b 40 08             	mov    0x8(%eax),%eax
801051bc:	83 ec 0c             	sub    $0xc,%esp
801051bf:	50                   	push   %eax
801051c0:	e8 c6 d9 ff ff       	call   80102b8b <kfree>
801051c5:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801051c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801051d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d5:	8b 40 04             	mov    0x4(%eax),%eax
801051d8:	83 ec 0c             	sub    $0xc,%esp
801051db:	50                   	push   %eax
801051dc:	e8 39 41 00 00       	call   8010931a <freevm>
801051e1:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801051e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801051ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105205:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105213:	83 ec 0c             	sub    $0xc,%esp
80105216:	68 80 39 11 80       	push   $0x80113980
8010521b:	e8 96 0a 00 00       	call   80105cb6 <release>
80105220:	83 c4 10             	add    $0x10,%esp
        return pid;
80105223:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105226:	eb 5b                	jmp    80105283 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105228:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105229:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
80105230:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80105237:	0f 82 4a ff ff ff    	jb     80105187 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010523d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105241:	74 0d                	je     80105250 <wait+0xf2>
80105243:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105249:	8b 40 24             	mov    0x24(%eax),%eax
8010524c:	85 c0                	test   %eax,%eax
8010524e:	74 17                	je     80105267 <wait+0x109>
      release(&ptable.lock);
80105250:	83 ec 0c             	sub    $0xc,%esp
80105253:	68 80 39 11 80       	push   $0x80113980
80105258:	e8 59 0a 00 00       	call   80105cb6 <release>
8010525d:	83 c4 10             	add    $0x10,%esp
      return -1;
80105260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105265:	eb 1c                	jmp    80105283 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105267:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010526d:	83 ec 08             	sub    $0x8,%esp
80105270:	68 80 39 11 80       	push   $0x80113980
80105275:	50                   	push   %eax
80105276:	e8 18 02 00 00       	call   80105493 <sleep>
8010527b:	83 c4 10             	add    $0x10,%esp
  }
8010527e:	e9 f1 fe ff ff       	jmp    80105174 <wait+0x16>
}
80105283:	c9                   	leave  
80105284:	c3                   	ret    

80105285 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int l;
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010528b:	e8 3b f4 ff ff       	call   801046cb <sti>

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
80105290:	83 ec 0c             	sub    $0xc,%esp
80105293:	68 80 39 11 80       	push   $0x80113980
80105298:	e8 b2 09 00 00       	call   80105c4f <acquire>
8010529d:	83 c4 10             	add    $0x10,%esp
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
801052a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052a7:	eb 7d                	jmp    80105326 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
801052a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ac:	05 e6 06 00 00       	add    $0x6e6,%eax
801052b1:	8b 04 c5 84 39 11 80 	mov    -0x7feec67c(,%eax,8),%eax
801052b8:	85 c0                	test   %eax,%eax
801052ba:	75 06                	jne    801052c2 <scheduler+0x3d>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
801052bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052c0:	eb 64                	jmp    80105326 <scheduler+0xa1>
      if (!ptable.mlf[l].first)
        continue;
      p=unqueue(l);
801052c2:	83 ec 0c             	sub    $0xc,%esp
801052c5:	ff 75 f4             	pushl  -0xc(%ebp)
801052c8:	e8 9d f4 ff ff       	call   8010476a <unqueue>
801052cd:	83 c4 10             	add    $0x10,%esp
801052d0:	89 45 f0             	mov    %eax,-0x10(%ebp)


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801052d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052d6:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4


      switchuvm(p);
801052dc:	83 ec 0c             	sub    $0xc,%esp
801052df:	ff 75 f0             	pushl  -0x10(%ebp)
801052e2:	e8 ed 3b 00 00       	call   80108ed4 <switchuvm>
801052e7:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801052ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ed:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801052f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052fa:	8b 40 1c             	mov    0x1c(%eax),%eax
801052fd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105304:	83 c2 04             	add    $0x4,%edx
80105307:	83 ec 08             	sub    $0x8,%esp
8010530a:	50                   	push   %eax
8010530b:	52                   	push   %edx
8010530c:	e8 15 0e 00 00       	call   80106126 <swtch>
80105311:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105314:	e8 9e 3b 00 00       	call   80108eb7 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105319:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105320:	00 00 00 00 
      break;
80105324:	eb 0a                	jmp    80105330 <scheduler+0xab>
    // Enable interrupts on this processor.
    sti();

    // Loop over MLF looking for process to execute according to priority levels.
    acquire(&ptable.lock);
    for(l=MLFMAXPRIORITY; l<MLFLEVELS; l++){
80105326:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
8010532a:	0f 8e 79 ff ff ff    	jle    801052a9 <scheduler+0x24>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      break;
    }
    release(&ptable.lock);
80105330:	83 ec 0c             	sub    $0xc,%esp
80105333:	68 80 39 11 80       	push   $0x80113980
80105338:	e8 79 09 00 00       	call   80105cb6 <release>
8010533d:	83 c4 10             	add    $0x10,%esp
  }
80105340:	e9 46 ff ff ff       	jmp    8010528b <scheduler+0x6>

80105345 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010534b:	83 ec 0c             	sub    $0xc,%esp
8010534e:	68 80 39 11 80       	push   $0x80113980
80105353:	e8 2a 0a 00 00       	call   80105d82 <holding>
80105358:	83 c4 10             	add    $0x10,%esp
8010535b:	85 c0                	test   %eax,%eax
8010535d:	75 0d                	jne    8010536c <sched+0x27>
    panic("sched ptable.lock");
8010535f:	83 ec 0c             	sub    $0xc,%esp
80105362:	68 86 9a 10 80       	push   $0x80109a86
80105367:	e8 fa b1 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010536c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105372:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105378:	83 f8 01             	cmp    $0x1,%eax
8010537b:	74 0d                	je     8010538a <sched+0x45>
    panic("sched locks");
8010537d:	83 ec 0c             	sub    $0xc,%esp
80105380:	68 98 9a 10 80       	push   $0x80109a98
80105385:	e8 dc b1 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010538a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105390:	8b 40 0c             	mov    0xc(%eax),%eax
80105393:	83 f8 04             	cmp    $0x4,%eax
80105396:	75 0d                	jne    801053a5 <sched+0x60>
    panic("sched running");
80105398:	83 ec 0c             	sub    $0xc,%esp
8010539b:	68 a4 9a 10 80       	push   $0x80109aa4
801053a0:	e8 c1 b1 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801053a5:	e8 11 f3 ff ff       	call   801046bb <readeflags>
801053aa:	25 00 02 00 00       	and    $0x200,%eax
801053af:	85 c0                	test   %eax,%eax
801053b1:	74 0d                	je     801053c0 <sched+0x7b>
    panic("sched interruptible");
801053b3:	83 ec 0c             	sub    $0xc,%esp
801053b6:	68 b2 9a 10 80       	push   $0x80109ab2
801053bb:	e8 a6 b1 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801053c0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053c6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801053cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053d5:	8b 40 04             	mov    0x4(%eax),%eax
801053d8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053df:	83 c2 1c             	add    $0x1c,%edx
801053e2:	83 ec 08             	sub    $0x8,%esp
801053e5:	50                   	push   %eax
801053e6:	52                   	push   %edx
801053e7:	e8 3a 0d 00 00       	call   80106126 <swtch>
801053ec:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801053ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053f8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801053fe:	90                   	nop
801053ff:	c9                   	leave  
80105400:	c3                   	ret    

80105401 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105401:	55                   	push   %ebp
80105402:	89 e5                	mov    %esp,%ebp
80105404:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105407:	83 ec 0c             	sub    $0xc,%esp
8010540a:	68 80 39 11 80       	push   $0x80113980
8010540f:	e8 3b 08 00 00       	call   80105c4f <acquire>
80105414:	83 c4 10             	add    $0x10,%esp
  if(proc->priority<MLFLEVELS-1)
80105417:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541d:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105421:	66 83 f8 02          	cmp    $0x2,%ax
80105425:	77 11                	ja     80105438 <yield+0x37>
    proc->priority++;
80105427:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542d:	0f b7 50 7e          	movzwl 0x7e(%eax),%edx
80105431:	83 c2 01             	add    $0x1,%edx
80105434:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  make_runnable(proc);
80105438:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543e:	83 ec 0c             	sub    $0xc,%esp
80105441:	50                   	push   %eax
80105442:	e8 8b f2 ff ff       	call   801046d2 <make_runnable>
80105447:	83 c4 10             	add    $0x10,%esp
  sched();
8010544a:	e8 f6 fe ff ff       	call   80105345 <sched>
  release(&ptable.lock);
8010544f:	83 ec 0c             	sub    $0xc,%esp
80105452:	68 80 39 11 80       	push   $0x80113980
80105457:	e8 5a 08 00 00       	call   80105cb6 <release>
8010545c:	83 c4 10             	add    $0x10,%esp
}
8010545f:	90                   	nop
80105460:	c9                   	leave  
80105461:	c3                   	ret    

80105462 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105462:	55                   	push   %ebp
80105463:	89 e5                	mov    %esp,%ebp
80105465:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105468:	83 ec 0c             	sub    $0xc,%esp
8010546b:	68 80 39 11 80       	push   $0x80113980
80105470:	e8 41 08 00 00       	call   80105cb6 <release>
80105475:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105478:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010547d:	85 c0                	test   %eax,%eax
8010547f:	74 0f                	je     80105490 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105481:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105488:	00 00 00 
    initlog();
8010548b:	e8 61 de ff ff       	call   801032f1 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80105490:	90                   	nop
80105491:	c9                   	leave  
80105492:	c3                   	ret    

80105493 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105493:	55                   	push   %ebp
80105494:	89 e5                	mov    %esp,%ebp
80105496:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105499:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549f:	85 c0                	test   %eax,%eax
801054a1:	75 0d                	jne    801054b0 <sleep+0x1d>
    panic("sleep");
801054a3:	83 ec 0c             	sub    $0xc,%esp
801054a6:	68 c6 9a 10 80       	push   $0x80109ac6
801054ab:	e8 b6 b0 ff ff       	call   80100566 <panic>

  if(lk == 0)
801054b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054b4:	75 0d                	jne    801054c3 <sleep+0x30>
    panic("sleep without lk");
801054b6:	83 ec 0c             	sub    $0xc,%esp
801054b9:	68 cc 9a 10 80       	push   $0x80109acc
801054be:	e8 a3 b0 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801054c3:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801054ca:	74 1e                	je     801054ea <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801054cc:	83 ec 0c             	sub    $0xc,%esp
801054cf:	68 80 39 11 80       	push   $0x80113980
801054d4:	e8 76 07 00 00       	call   80105c4f <acquire>
801054d9:	83 c4 10             	add    $0x10,%esp
    release(lk);
801054dc:	83 ec 0c             	sub    $0xc,%esp
801054df:	ff 75 0c             	pushl  0xc(%ebp)
801054e2:	e8 cf 07 00 00       	call   80105cb6 <release>
801054e7:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801054ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054f0:	8b 55 08             	mov    0x8(%ebp),%edx
801054f3:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801054f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054fc:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105503:	e8 3d fe ff ff       	call   80105345 <sched>

  // Tidy up.
  proc->chan = 0;
80105508:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010550e:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105515:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
8010551c:	74 1e                	je     8010553c <sleep+0xa9>
    release(&ptable.lock);
8010551e:	83 ec 0c             	sub    $0xc,%esp
80105521:	68 80 39 11 80       	push   $0x80113980
80105526:	e8 8b 07 00 00       	call   80105cb6 <release>
8010552b:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010552e:	83 ec 0c             	sub    $0xc,%esp
80105531:	ff 75 0c             	pushl  0xc(%ebp)
80105534:	e8 16 07 00 00       	call   80105c4f <acquire>
80105539:	83 c4 10             	add    $0x10,%esp
  }
}
8010553c:	90                   	nop
8010553d:	c9                   	leave  
8010553e:	c3                   	ret    

8010553f <wakeup1>:
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
// If applicable, the priority of the process increases.
static void
wakeup1(void *chan)
{
8010553f:	55                   	push   %ebp
80105540:	89 e5                	mov    %esp,%ebp
80105542:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105545:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
8010554c:	eb 45                	jmp    80105593 <wakeup1+0x54>
    if(p->state == SLEEPING && p->chan == chan){
8010554e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105551:	8b 40 0c             	mov    0xc(%eax),%eax
80105554:	83 f8 02             	cmp    $0x2,%eax
80105557:	75 33                	jne    8010558c <wakeup1+0x4d>
80105559:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010555c:	8b 40 20             	mov    0x20(%eax),%eax
8010555f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105562:	75 28                	jne    8010558c <wakeup1+0x4d>
      if (p->priority>0)
80105564:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105567:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
8010556b:	66 85 c0             	test   %ax,%ax
8010556e:	74 11                	je     80105581 <wakeup1+0x42>
        p->priority--;
80105570:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105573:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
80105577:	8d 50 ff             	lea    -0x1(%eax),%edx
8010557a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010557d:	66 89 50 7e          	mov    %dx,0x7e(%eax)
      make_runnable(p);
80105581:	ff 75 fc             	pushl  -0x4(%ebp)
80105584:	e8 49 f1 ff ff       	call   801046d2 <make_runnable>
80105589:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010558c:	81 45 fc dc 00 00 00 	addl   $0xdc,-0x4(%ebp)
80105593:	81 7d fc b4 70 11 80 	cmpl   $0x801170b4,-0x4(%ebp)
8010559a:	72 b2                	jb     8010554e <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan){
      if (p->priority>0)
        p->priority--;
      make_runnable(p);
    }
}
8010559c:	90                   	nop
8010559d:	c9                   	leave  
8010559e:	c3                   	ret    

8010559f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010559f:	55                   	push   %ebp
801055a0:	89 e5                	mov    %esp,%ebp
801055a2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801055a5:	83 ec 0c             	sub    $0xc,%esp
801055a8:	68 80 39 11 80       	push   $0x80113980
801055ad:	e8 9d 06 00 00       	call   80105c4f <acquire>
801055b2:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801055b5:	83 ec 0c             	sub    $0xc,%esp
801055b8:	ff 75 08             	pushl  0x8(%ebp)
801055bb:	e8 7f ff ff ff       	call   8010553f <wakeup1>
801055c0:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801055c3:	83 ec 0c             	sub    $0xc,%esp
801055c6:	68 80 39 11 80       	push   $0x80113980
801055cb:	e8 e6 06 00 00       	call   80105cb6 <release>
801055d0:	83 c4 10             	add    $0x10,%esp
}
801055d3:	90                   	nop
801055d4:	c9                   	leave  
801055d5:	c3                   	ret    

801055d6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801055d6:	55                   	push   %ebp
801055d7:	89 e5                	mov    %esp,%ebp
801055d9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801055dc:	83 ec 0c             	sub    $0xc,%esp
801055df:	68 80 39 11 80       	push   $0x80113980
801055e4:	e8 66 06 00 00       	call   80105c4f <acquire>
801055e9:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055ec:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801055f3:	eb 4c                	jmp    80105641 <kill+0x6b>
    if(p->pid == pid){
801055f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f8:	8b 40 10             	mov    0x10(%eax),%eax
801055fb:	3b 45 08             	cmp    0x8(%ebp),%eax
801055fe:	75 3a                	jne    8010563a <kill+0x64>
      p->killed = 1;
80105600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105603:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010560a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560d:	8b 40 0c             	mov    0xc(%eax),%eax
80105610:	83 f8 02             	cmp    $0x2,%eax
80105613:	75 0e                	jne    80105623 <kill+0x4d>
        make_runnable(p);
80105615:	83 ec 0c             	sub    $0xc,%esp
80105618:	ff 75 f4             	pushl  -0xc(%ebp)
8010561b:	e8 b2 f0 ff ff       	call   801046d2 <make_runnable>
80105620:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
80105623:	83 ec 0c             	sub    $0xc,%esp
80105626:	68 80 39 11 80       	push   $0x80113980
8010562b:	e8 86 06 00 00       	call   80105cb6 <release>
80105630:	83 c4 10             	add    $0x10,%esp
      return 0;
80105633:	b8 00 00 00 00       	mov    $0x0,%eax
80105638:	eb 25                	jmp    8010565f <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010563a:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
80105641:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80105648:	72 ab                	jb     801055f5 <kill+0x1f>
        make_runnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010564a:	83 ec 0c             	sub    $0xc,%esp
8010564d:	68 80 39 11 80       	push   $0x80113980
80105652:	e8 5f 06 00 00       	call   80105cb6 <release>
80105657:	83 c4 10             	add    $0x10,%esp
  return -1;
8010565a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010565f:	c9                   	leave  
80105660:	c3                   	ret    

80105661 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105661:	55                   	push   %ebp
80105662:	89 e5                	mov    %esp,%ebp
80105664:	53                   	push   %ebx
80105665:	83 ec 44             	sub    $0x44,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105668:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
8010566f:	e9 f6 00 00 00       	jmp    8010576a <procdump+0x109>
    if(p->state == UNUSED)
80105674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105677:	8b 40 0c             	mov    0xc(%eax),%eax
8010567a:	85 c0                	test   %eax,%eax
8010567c:	0f 84 e0 00 00 00    	je     80105762 <procdump+0x101>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105682:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105685:	8b 40 0c             	mov    0xc(%eax),%eax
80105688:	83 f8 05             	cmp    $0x5,%eax
8010568b:	77 23                	ja     801056b0 <procdump+0x4f>
8010568d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105690:	8b 40 0c             	mov    0xc(%eax),%eax
80105693:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010569a:	85 c0                	test   %eax,%eax
8010569c:	74 12                	je     801056b0 <procdump+0x4f>
      state = states[p->state];
8010569e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a1:	8b 40 0c             	mov    0xc(%eax),%eax
801056a4:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801056ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
801056ae:	eb 07                	jmp    801056b7 <procdump+0x56>
    else
      state = "???";
801056b0:	c7 45 ec dd 9a 10 80 	movl   $0x80109add,-0x14(%ebp)
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
801056b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ba:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801056c1:	0f b7 c8             	movzwl %ax,%ecx
801056c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c7:	0f b7 40 7e          	movzwl 0x7e(%eax),%eax
801056cb:	0f b7 d0             	movzwl %ax,%edx
801056ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d1:	8d 58 6c             	lea    0x6c(%eax),%ebx
801056d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d7:	8b 40 10             	mov    0x10(%eax),%eax
801056da:	83 ec 08             	sub    $0x8,%esp
801056dd:	51                   	push   %ecx
801056de:	52                   	push   %edx
801056df:	53                   	push   %ebx
801056e0:	ff 75 ec             	pushl  -0x14(%ebp)
801056e3:	50                   	push   %eax
801056e4:	68 e1 9a 10 80       	push   $0x80109ae1
801056e9:	e8 d8 ac ff ff       	call   801003c6 <cprintf>
801056ee:	83 c4 20             	add    $0x20,%esp
    if(p->state == SLEEPING){
801056f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f4:	8b 40 0c             	mov    0xc(%eax),%eax
801056f7:	83 f8 02             	cmp    $0x2,%eax
801056fa:	75 54                	jne    80105750 <procdump+0xef>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801056fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ff:	8b 40 1c             	mov    0x1c(%eax),%eax
80105702:	8b 40 0c             	mov    0xc(%eax),%eax
80105705:	83 c0 08             	add    $0x8,%eax
80105708:	89 c2                	mov    %eax,%edx
8010570a:	83 ec 08             	sub    $0x8,%esp
8010570d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105710:	50                   	push   %eax
80105711:	52                   	push   %edx
80105712:	e8 f1 05 00 00       	call   80105d08 <getcallerpcs>
80105717:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010571a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105721:	eb 1c                	jmp    8010573f <procdump+0xde>
        cprintf(" %p", pc[i]);
80105723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105726:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010572a:	83 ec 08             	sub    $0x8,%esp
8010572d:	50                   	push   %eax
8010572e:	68 fd 9a 10 80       	push   $0x80109afd
80105733:	e8 8e ac ff ff       	call   801003c6 <cprintf>
80105738:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s priority:%d age:%d", p->pid, state, p->name,p->priority,p->age);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010573b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010573f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105743:	7f 0b                	jg     80105750 <procdump+0xef>
80105745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105748:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010574c:	85 c0                	test   %eax,%eax
8010574e:	75 d3                	jne    80105723 <procdump+0xc2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	68 01 9b 10 80       	push   $0x80109b01
80105758:	e8 69 ac ff ff       	call   801003c6 <cprintf>
8010575d:	83 c4 10             	add    $0x10,%esp
80105760:	eb 01                	jmp    80105763 <procdump+0x102>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105762:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105763:	81 45 f0 dc 00 00 00 	addl   $0xdc,-0x10(%ebp)
8010576a:	81 7d f0 b4 70 11 80 	cmpl   $0x801170b4,-0x10(%ebp)
80105771:	0f 82 fd fe ff ff    	jb     80105674 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105777:	90                   	nop
80105778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010577b:	c9                   	leave  
8010577c:	c3                   	ret    

8010577d <seminit>:
} stable;

// Initializes the LOCK of the semaphore table.
void
seminit(void)
{
8010577d:	55                   	push   %ebp
8010577e:	89 e5                	mov    %esp,%ebp
80105780:	83 ec 08             	sub    $0x8,%esp
  initlock(&stable.lock, "stable");
80105783:	83 ec 08             	sub    $0x8,%esp
80105786:	68 2d 9b 10 80       	push   $0x80109b2d
8010578b:	68 e0 70 11 80       	push   $0x801170e0
80105790:	e8 98 04 00 00       	call   80105c2d <initlock>
80105795:	83 c4 10             	add    $0x10,%esp
}
80105798:	90                   	nop
80105799:	c9                   	leave  
8010579a:	c3                   	ret    

8010579b <allocinprocess>:

// Assigns a place in the open semaphore array of the process and returns the position.
static int
allocinprocess()
{
8010579b:	55                   	push   %ebp
8010579c:	89 e5                	mov    %esp,%ebp
8010579e:	83 ec 10             	sub    $0x10,%esp
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
801057a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a8:	eb 22                	jmp    801057cc <allocinprocess+0x31>
    s=proc->osemaphore[i];
801057aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b3:	83 c2 20             	add    $0x20,%edx
801057b6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(!s)
801057bd:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801057c1:	75 05                	jne    801057c8 <allocinprocess+0x2d>
      return i;
801057c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c6:	eb 0f                	jmp    801057d7 <allocinprocess+0x3c>
allocinprocess()
{
  int i;
  struct semaphore* s;

  for(i = 0; i < MAXPROCSEM; i++){
801057c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057cc:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
801057d0:	7e d8                	jle    801057aa <allocinprocess+0xf>
    s=proc->osemaphore[i];
    if(!s)
      return i;
  }
  return -1;
801057d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057d7:	c9                   	leave  
801057d8:	c3                   	ret    

801057d9 <searchinprocess>:

// Find the id passed as an argument between the ids of the open semaphores of the process and return its position.
static int
searchinprocess(int id)
{
801057d9:	55                   	push   %ebp
801057da:	89 e5                	mov    %esp,%ebp
801057dc:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
801057df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057e6:	eb 2c                	jmp    80105814 <searchinprocess+0x3b>
    s=proc->osemaphore[i];
801057e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057f1:	83 c2 20             	add    $0x20,%edx
801057f4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s && s->id==id){
801057fb:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801057ff:	74 0f                	je     80105810 <searchinprocess+0x37>
80105801:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105804:	8b 00                	mov    (%eax),%eax
80105806:	3b 45 08             	cmp    0x8(%ebp),%eax
80105809:	75 05                	jne    80105810 <searchinprocess+0x37>
        return i;
8010580b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010580e:	eb 0f                	jmp    8010581f <searchinprocess+0x46>
searchinprocess(int id)
{
  struct semaphore* s;
  int i;

  for(i = 0; i < MAXPROCSEM; i++){
80105810:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105814:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80105818:	7e ce                	jle    801057e8 <searchinprocess+0xf>
    s=proc->osemaphore[i];
    if(s && s->id==id){
        return i;
    }
  }
  return -1;
8010581a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010581f:	c9                   	leave  
80105820:	c3                   	ret    

80105821 <allocinsystem>:

// Assign a place in the semaphore table of the system and return a pointer to it.
// if the table is full, return null (0)
static struct semaphore*
allocinsystem()
{
80105821:	55                   	push   %ebp
80105822:	89 e5                	mov    %esp,%ebp
80105824:	83 ec 10             	sub    $0x10,%esp
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
80105827:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010582e:	eb 2d                	jmp    8010585d <allocinsystem+0x3c>
    s=&stable.sem[i];
80105830:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105833:	89 d0                	mov    %edx,%eax
80105835:	01 c0                	add    %eax,%eax
80105837:	01 d0                	add    %edx,%eax
80105839:	c1 e0 02             	shl    $0x2,%eax
8010583c:	83 c0 30             	add    $0x30,%eax
8010583f:	05 e0 70 11 80       	add    $0x801170e0,%eax
80105844:	83 c0 04             	add    $0x4,%eax
80105847:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if(s->references==0)
8010584a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010584d:	8b 40 04             	mov    0x4(%eax),%eax
80105850:	85 c0                	test   %eax,%eax
80105852:	75 05                	jne    80105859 <allocinsystem+0x38>
      return s;
80105854:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105857:	eb 0f                	jmp    80105868 <allocinsystem+0x47>
static struct semaphore*
allocinsystem()
{
  struct semaphore* s;
  int i;
  for(i=0; i < MAXSEM; i++){
80105859:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010585d:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80105861:	7e cd                	jle    80105830 <allocinsystem+0xf>
    s=&stable.sem[i];
    if(s->references==0)
      return s;
  }
  return 0;
80105863:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105868:	c9                   	leave  
80105869:	c3                   	ret    

8010586a <semget>:
// if there is no place in the system's semaphore table, return -3.
// if semid> 0 and the semaphore is not in use, return -1.
// if semid <-1 or semid> MAXSEM, return -4.
int
semget(int semid, int initvalue)
{
8010586a:	55                   	push   %ebp
8010586b:	89 e5                	mov    %esp,%ebp
8010586d:	83 ec 18             	sub    $0x18,%esp
  int position=0,retvalue;
80105870:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  struct semaphore* s;

  if(semid<-1 || semid>=MAXSEM)
80105877:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
8010587b:	7c 06                	jl     80105883 <semget+0x19>
8010587d:	83 7d 08 3f          	cmpl   $0x3f,0x8(%ebp)
80105881:	7e 0a                	jle    8010588d <semget+0x23>
    return -4;
80105883:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
80105888:	e9 0d 01 00 00       	jmp    8010599a <semget+0x130>
  acquire(&stable.lock);
8010588d:	83 ec 0c             	sub    $0xc,%esp
80105890:	68 e0 70 11 80       	push   $0x801170e0
80105895:	e8 b5 03 00 00       	call   80105c4f <acquire>
8010589a:	83 c4 10             	add    $0x10,%esp
  position=allocinprocess();
8010589d:	e8 f9 fe ff ff       	call   8010579b <allocinprocess>
801058a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(position==-1){
801058a5:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
801058a9:	75 0c                	jne    801058b7 <semget+0x4d>
    retvalue=-2;
801058ab:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retget;
801058b2:	e9 d0 00 00 00       	jmp    80105987 <semget+0x11d>
  }
  if(semid==-1){
801058b7:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
801058bb:	75 47                	jne    80105904 <semget+0x9a>
    s=allocinsystem();
801058bd:	e8 5f ff ff ff       	call   80105821 <allocinsystem>
801058c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!s){
801058c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058c9:	75 0c                	jne    801058d7 <semget+0x6d>
      retvalue=-3;
801058cb:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
      goto retget;
801058d2:	e9 b0 00 00 00       	jmp    80105987 <semget+0x11d>
    }
    s->id=s-stable.sem;
801058d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058da:	ba 14 71 11 80       	mov    $0x80117114,%edx
801058df:	29 d0                	sub    %edx,%eax
801058e1:	c1 f8 02             	sar    $0x2,%eax
801058e4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
801058ea:	89 c2                	mov    %eax,%edx
801058ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ef:	89 10                	mov    %edx,(%eax)
    s->value=initvalue;
801058f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801058f7:	89 50 08             	mov    %edx,0x8(%eax)
    retvalue=s->id;
801058fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fd:	8b 00                	mov    (%eax),%eax
801058ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    goto found;
80105902:	eb 61                	jmp    80105965 <semget+0xfb>
  }
  if(semid>=0){
80105904:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105908:	78 5b                	js     80105965 <semget+0xfb>
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
8010590a:	c7 45 f0 14 71 11 80 	movl   $0x80117114,-0x10(%ebp)
80105911:	eb 3f                	jmp    80105952 <semget+0xe8>
      if(s->id==semid && ((s->references)>0)){
80105913:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105916:	8b 00                	mov    (%eax),%eax
80105918:	3b 45 08             	cmp    0x8(%ebp),%eax
8010591b:	75 14                	jne    80105931 <semget+0xc7>
8010591d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105920:	8b 40 04             	mov    0x4(%eax),%eax
80105923:	85 c0                	test   %eax,%eax
80105925:	7e 0a                	jle    80105931 <semget+0xc7>
        retvalue=s->id;
80105927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592a:	8b 00                	mov    (%eax),%eax
8010592c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto found;
8010592f:	eb 34                	jmp    80105965 <semget+0xfb>
      }
      if(s->id==semid && ((s->references)==0)){
80105931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105934:	8b 00                	mov    (%eax),%eax
80105936:	3b 45 08             	cmp    0x8(%ebp),%eax
80105939:	75 13                	jne    8010594e <semget+0xe4>
8010593b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593e:	8b 40 04             	mov    0x4(%eax),%eax
80105941:	85 c0                	test   %eax,%eax
80105943:	75 09                	jne    8010594e <semget+0xe4>
        retvalue=-1;
80105945:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
        goto retget;
8010594c:	eb 39                	jmp    80105987 <semget+0x11d>
    s->value=initvalue;
    retvalue=s->id;
    goto found;
  }
  if(semid>=0){
    for(s = stable.sem; s < stable.sem + MAXSEM; s++){
8010594e:	83 45 f0 0c          	addl   $0xc,-0x10(%ebp)
80105952:	b8 14 74 11 80       	mov    $0x80117414,%eax
80105957:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010595a:	72 b7                	jb     80105913 <semget+0xa9>
      if(s->id==semid && ((s->references)==0)){
        retvalue=-1;
        goto retget;
      }
    }
    retvalue=-5;
8010595c:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    goto retget;
80105963:	eb 22                	jmp    80105987 <semget+0x11d>
  }
found:
  s->references++;
80105965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105968:	8b 40 04             	mov    0x4(%eax),%eax
8010596b:	8d 50 01             	lea    0x1(%eax),%edx
8010596e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105971:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[position]=s;
80105974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010597a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010597d:	8d 4a 20             	lea    0x20(%edx),%ecx
80105980:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105983:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
retget:
  release(&stable.lock);
80105987:	83 ec 0c             	sub    $0xc,%esp
8010598a:	68 e0 70 11 80       	push   $0x801170e0
8010598f:	e8 22 03 00 00       	call   80105cb6 <release>
80105994:	83 c4 10             	add    $0x10,%esp
  return retvalue;
80105997:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010599a:	c9                   	leave  
8010599b:	c3                   	ret    

8010599c <semfree>:

// It releases the semaphore of the process if it is not in use, but only decreases the references in 1.
// if the semaphore is not in the process, return -1.
int
semfree(int semid)
{
8010599c:	55                   	push   %ebp
8010599d:	89 e5                	mov    %esp,%ebp
8010599f:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int retvalue,pos;

  acquire(&stable.lock);
801059a2:	83 ec 0c             	sub    $0xc,%esp
801059a5:	68 e0 70 11 80       	push   $0x801170e0
801059aa:	e8 a0 02 00 00       	call   80105c4f <acquire>
801059af:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
801059b2:	83 ec 0c             	sub    $0xc,%esp
801059b5:	ff 75 08             	pushl  0x8(%ebp)
801059b8:	e8 1c fe ff ff       	call   801057d9 <searchinprocess>
801059bd:	83 c4 10             	add    $0x10,%esp
801059c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
801059c3:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801059c7:	75 09                	jne    801059d2 <semfree+0x36>
    retvalue=-1;
801059c9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retfree;
801059d0:	eb 50                	jmp    80105a22 <semfree+0x86>
  }
  s=proc->osemaphore[pos];
801059d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059db:	83 c2 20             	add    $0x20,%edx
801059de:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(s->references < 1){
801059e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059e8:	8b 40 04             	mov    0x4(%eax),%eax
801059eb:	85 c0                	test   %eax,%eax
801059ed:	7f 09                	jg     801059f8 <semfree+0x5c>
    retvalue=-2;
801059ef:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%ebp)
    goto retfree;
801059f6:	eb 2a                	jmp    80105a22 <semfree+0x86>
  }
  s->references--;
801059f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059fb:	8b 40 04             	mov    0x4(%eax),%eax
801059fe:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a04:	89 50 04             	mov    %edx,0x4(%eax)
  proc->osemaphore[pos]=0;
80105a07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a10:	83 c2 20             	add    $0x20,%edx
80105a13:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a1a:	00 
  retvalue=0;
80105a1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retfree:
  release(&stable.lock);
80105a22:	83 ec 0c             	sub    $0xc,%esp
80105a25:	68 e0 70 11 80       	push   $0x801170e0
80105a2a:	e8 87 02 00 00       	call   80105cb6 <release>
80105a2f:	83 c4 10             	add    $0x10,%esp
  return retvalue;
80105a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a35:	c9                   	leave  
80105a36:	c3                   	ret    

80105a37 <semdown>:

// Decreases the value of the semaphore if it is greater than 0 but sleeps the process.
// if the semaphore is not in the process, return -1.
int
semdown(int semid)
{
80105a37:	55                   	push   %ebp
80105a38:	89 e5                	mov    %esp,%ebp
80105a3a:	83 ec 18             	sub    $0x18,%esp
  int value,pos;
  struct semaphore* s;

  acquire(&stable.lock);
80105a3d:	83 ec 0c             	sub    $0xc,%esp
80105a40:	68 e0 70 11 80       	push   $0x801170e0
80105a45:	e8 05 02 00 00       	call   80105c4f <acquire>
80105a4a:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105a4d:	83 ec 0c             	sub    $0xc,%esp
80105a50:	ff 75 08             	pushl  0x8(%ebp)
80105a53:	e8 81 fd ff ff       	call   801057d9 <searchinprocess>
80105a58:	83 c4 10             	add    $0x10,%esp
80105a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pos==-1){
80105a5e:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105a62:	75 09                	jne    80105a6d <semdown+0x36>
    value=-1;
80105a64:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    goto retdown;
80105a6b:	eb 48                	jmp    80105ab5 <semdown+0x7e>
  }
  s=proc->osemaphore[pos];
80105a6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a73:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a76:	83 c2 20             	add    $0x20,%edx
80105a79:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  while(s->value<=0){
80105a80:	eb 13                	jmp    80105a95 <semdown+0x5e>
    sleep(s,&stable.lock);
80105a82:	83 ec 08             	sub    $0x8,%esp
80105a85:	68 e0 70 11 80       	push   $0x801170e0
80105a8a:	ff 75 ec             	pushl  -0x14(%ebp)
80105a8d:	e8 01 fa ff ff       	call   80105493 <sleep>
80105a92:	83 c4 10             	add    $0x10,%esp
  if(pos==-1){
    value=-1;
    goto retdown;
  }
  s=proc->osemaphore[pos];
  while(s->value<=0){
80105a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a98:	8b 40 08             	mov    0x8(%eax),%eax
80105a9b:	85 c0                	test   %eax,%eax
80105a9d:	7e e3                	jle    80105a82 <semdown+0x4b>
    sleep(s,&stable.lock);
  }
  s->value--;
80105a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105aa2:	8b 40 08             	mov    0x8(%eax),%eax
80105aa5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105aab:	89 50 08             	mov    %edx,0x8(%eax)
  value=0;
80105aae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
retdown:
  release(&stable.lock);
80105ab5:	83 ec 0c             	sub    $0xc,%esp
80105ab8:	68 e0 70 11 80       	push   $0x801170e0
80105abd:	e8 f4 01 00 00       	call   80105cb6 <release>
80105ac2:	83 c4 10             	add    $0x10,%esp
  return value;
80105ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ac8:	c9                   	leave  
80105ac9:	c3                   	ret    

80105aca <semup>:

// It increases the value of the semaphore and wake up processes waiting for it.
// if the semaphore is not in the process, return -1.
int
semup(int semid)
{
80105aca:	55                   	push   %ebp
80105acb:	89 e5                	mov    %esp,%ebp
80105acd:	83 ec 18             	sub    $0x18,%esp
  struct semaphore* s;
  int pos;

  acquire(&stable.lock);
80105ad0:	83 ec 0c             	sub    $0xc,%esp
80105ad3:	68 e0 70 11 80       	push   $0x801170e0
80105ad8:	e8 72 01 00 00       	call   80105c4f <acquire>
80105add:	83 c4 10             	add    $0x10,%esp
  pos=searchinprocess(semid);
80105ae0:	83 ec 0c             	sub    $0xc,%esp
80105ae3:	ff 75 08             	pushl  0x8(%ebp)
80105ae6:	e8 ee fc ff ff       	call   801057d9 <searchinprocess>
80105aeb:	83 c4 10             	add    $0x10,%esp
80105aee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pos==-1){
80105af1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105af5:	75 17                	jne    80105b0e <semup+0x44>
    release(&stable.lock);
80105af7:	83 ec 0c             	sub    $0xc,%esp
80105afa:	68 e0 70 11 80       	push   $0x801170e0
80105aff:	e8 b2 01 00 00       	call   80105cb6 <release>
80105b04:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0c:	eb 45                	jmp    80105b53 <semup+0x89>
  }
  s=proc->osemaphore[pos];
80105b0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b17:	83 c2 20             	add    $0x20,%edx
80105b1a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->value++;
80105b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b24:	8b 40 08             	mov    0x8(%eax),%eax
80105b27:	8d 50 01             	lea    0x1(%eax),%edx
80105b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&stable.lock);
80105b30:	83 ec 0c             	sub    $0xc,%esp
80105b33:	68 e0 70 11 80       	push   $0x801170e0
80105b38:	e8 79 01 00 00       	call   80105cb6 <release>
80105b3d:	83 c4 10             	add    $0x10,%esp
  wakeup(s);
80105b40:	83 ec 0c             	sub    $0xc,%esp
80105b43:	ff 75 f0             	pushl  -0x10(%ebp)
80105b46:	e8 54 fa ff ff       	call   8010559f <wakeup>
80105b4b:	83 c4 10             	add    $0x10,%esp
  return 0;
80105b4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b53:	c9                   	leave  
80105b54:	c3                   	ret    

80105b55 <semclose>:

// Decrease the semaphore references.
void
semclose(struct semaphore* s)
{
80105b55:	55                   	push   %ebp
80105b56:	89 e5                	mov    %esp,%ebp
80105b58:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
80105b5b:	83 ec 0c             	sub    $0xc,%esp
80105b5e:	68 e0 70 11 80       	push   $0x801170e0
80105b63:	e8 e7 00 00 00       	call   80105c4f <acquire>
80105b68:	83 c4 10             	add    $0x10,%esp

  if(s->references < 1)
80105b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6e:	8b 40 04             	mov    0x4(%eax),%eax
80105b71:	85 c0                	test   %eax,%eax
80105b73:	7f 0d                	jg     80105b82 <semclose+0x2d>
    panic("semclose");
80105b75:	83 ec 0c             	sub    $0xc,%esp
80105b78:	68 34 9b 10 80       	push   $0x80109b34
80105b7d:	e8 e4 a9 ff ff       	call   80100566 <panic>
  s->references--;
80105b82:	8b 45 08             	mov    0x8(%ebp),%eax
80105b85:	8b 40 04             	mov    0x4(%eax),%eax
80105b88:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
80105b91:	83 ec 0c             	sub    $0xc,%esp
80105b94:	68 e0 70 11 80       	push   $0x801170e0
80105b99:	e8 18 01 00 00       	call   80105cb6 <release>
80105b9e:	83 c4 10             	add    $0x10,%esp
  return;
80105ba1:	90                   	nop

}
80105ba2:	c9                   	leave  
80105ba3:	c3                   	ret    

80105ba4 <semdup>:

// Increase the semaphore references.
struct semaphore*
semdup(struct semaphore* s)
{
80105ba4:	55                   	push   %ebp
80105ba5:	89 e5                	mov    %esp,%ebp
80105ba7:	83 ec 08             	sub    $0x8,%esp
  acquire(&stable.lock);
80105baa:	83 ec 0c             	sub    $0xc,%esp
80105bad:	68 e0 70 11 80       	push   $0x801170e0
80105bb2:	e8 98 00 00 00       	call   80105c4f <acquire>
80105bb7:	83 c4 10             	add    $0x10,%esp
  if(s->references<0)
80105bba:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbd:	8b 40 04             	mov    0x4(%eax),%eax
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	79 0d                	jns    80105bd1 <semdup+0x2d>
    panic("semdup error");
80105bc4:	83 ec 0c             	sub    $0xc,%esp
80105bc7:	68 3d 9b 10 80       	push   $0x80109b3d
80105bcc:	e8 95 a9 ff ff       	call   80100566 <panic>
  s->references++;
80105bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd4:	8b 40 04             	mov    0x4(%eax),%eax
80105bd7:	8d 50 01             	lea    0x1(%eax),%edx
80105bda:	8b 45 08             	mov    0x8(%ebp),%eax
80105bdd:	89 50 04             	mov    %edx,0x4(%eax)
  release(&stable.lock);
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	68 e0 70 11 80       	push   $0x801170e0
80105be8:	e8 c9 00 00 00       	call   80105cb6 <release>
80105bed:	83 c4 10             	add    $0x10,%esp
  return s;
80105bf0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105bf3:	c9                   	leave  
80105bf4:	c3                   	ret    

80105bf5 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105bf5:	55                   	push   %ebp
80105bf6:	89 e5                	mov    %esp,%ebp
80105bf8:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105bfb:	9c                   	pushf  
80105bfc:	58                   	pop    %eax
80105bfd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c03:	c9                   	leave  
80105c04:	c3                   	ret    

80105c05 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105c05:	55                   	push   %ebp
80105c06:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105c08:	fa                   	cli    
}
80105c09:	90                   	nop
80105c0a:	5d                   	pop    %ebp
80105c0b:	c3                   	ret    

80105c0c <sti>:

static inline void
sti(void)
{
80105c0c:	55                   	push   %ebp
80105c0d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105c0f:	fb                   	sti    
}
80105c10:	90                   	nop
80105c11:	5d                   	pop    %ebp
80105c12:	c3                   	ret    

80105c13 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105c13:	55                   	push   %ebp
80105c14:	89 e5                	mov    %esp,%ebp
80105c16:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105c19:	8b 55 08             	mov    0x8(%ebp),%edx
80105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c22:	f0 87 02             	lock xchg %eax,(%edx)
80105c25:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c2b:	c9                   	leave  
80105c2c:	c3                   	ret    

80105c2d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105c2d:	55                   	push   %ebp
80105c2e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105c30:	8b 45 08             	mov    0x8(%ebp),%eax
80105c33:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c36:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105c39:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105c42:	8b 45 08             	mov    0x8(%ebp),%eax
80105c45:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105c4c:	90                   	nop
80105c4d:	5d                   	pop    %ebp
80105c4e:	c3                   	ret    

80105c4f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105c4f:	55                   	push   %ebp
80105c50:	89 e5                	mov    %esp,%ebp
80105c52:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105c55:	e8 52 01 00 00       	call   80105dac <pushcli>
  if(holding(lk))
80105c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5d:	83 ec 0c             	sub    $0xc,%esp
80105c60:	50                   	push   %eax
80105c61:	e8 1c 01 00 00       	call   80105d82 <holding>
80105c66:	83 c4 10             	add    $0x10,%esp
80105c69:	85 c0                	test   %eax,%eax
80105c6b:	74 0d                	je     80105c7a <acquire+0x2b>
    panic("acquire");
80105c6d:	83 ec 0c             	sub    $0xc,%esp
80105c70:	68 4a 9b 10 80       	push   $0x80109b4a
80105c75:	e8 ec a8 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while(xchg(&lk->locked, 1) != 0)
80105c7a:	90                   	nop
80105c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c7e:	83 ec 08             	sub    $0x8,%esp
80105c81:	6a 01                	push   $0x1
80105c83:	50                   	push   %eax
80105c84:	e8 8a ff ff ff       	call   80105c13 <xchg>
80105c89:	83 c4 10             	add    $0x10,%esp
80105c8c:	85 c0                	test   %eax,%eax
80105c8e:	75 eb                	jne    80105c7b <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105c90:	8b 45 08             	mov    0x8(%ebp),%eax
80105c93:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105c9a:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca0:	83 c0 0c             	add    $0xc,%eax
80105ca3:	83 ec 08             	sub    $0x8,%esp
80105ca6:	50                   	push   %eax
80105ca7:	8d 45 08             	lea    0x8(%ebp),%eax
80105caa:	50                   	push   %eax
80105cab:	e8 58 00 00 00       	call   80105d08 <getcallerpcs>
80105cb0:	83 c4 10             	add    $0x10,%esp
}
80105cb3:	90                   	nop
80105cb4:	c9                   	leave  
80105cb5:	c3                   	ret    

80105cb6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105cb6:	55                   	push   %ebp
80105cb7:	89 e5                	mov    %esp,%ebp
80105cb9:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105cbc:	83 ec 0c             	sub    $0xc,%esp
80105cbf:	ff 75 08             	pushl  0x8(%ebp)
80105cc2:	e8 bb 00 00 00       	call   80105d82 <holding>
80105cc7:	83 c4 10             	add    $0x10,%esp
80105cca:	85 c0                	test   %eax,%eax
80105ccc:	75 0d                	jne    80105cdb <release+0x25>
    panic("release");
80105cce:	83 ec 0c             	sub    $0xc,%esp
80105cd1:	68 52 9b 10 80       	push   $0x80109b52
80105cd6:	e8 8b a8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80105cde:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105cef:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf2:	83 ec 08             	sub    $0x8,%esp
80105cf5:	6a 00                	push   $0x0
80105cf7:	50                   	push   %eax
80105cf8:	e8 16 ff ff ff       	call   80105c13 <xchg>
80105cfd:	83 c4 10             	add    $0x10,%esp

  popcli();
80105d00:	e8 ec 00 00 00       	call   80105df1 <popcli>
}
80105d05:	90                   	nop
80105d06:	c9                   	leave  
80105d07:	c3                   	ret    

80105d08 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105d08:	55                   	push   %ebp
80105d09:	89 e5                	mov    %esp,%ebp
80105d0b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d11:	83 e8 08             	sub    $0x8,%eax
80105d14:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105d17:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105d1e:	eb 38                	jmp    80105d58 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105d20:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105d24:	74 53                	je     80105d79 <getcallerpcs+0x71>
80105d26:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105d2d:	76 4a                	jbe    80105d79 <getcallerpcs+0x71>
80105d2f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105d33:	74 44                	je     80105d79 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105d35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d42:	01 c2                	add    %eax,%edx
80105d44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d47:	8b 40 04             	mov    0x4(%eax),%eax
80105d4a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105d4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d4f:	8b 00                	mov    (%eax),%eax
80105d51:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105d54:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d58:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d5c:	7e c2                	jle    80105d20 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d5e:	eb 19                	jmp    80105d79 <getcallerpcs+0x71>
    pcs[i] = 0;
80105d60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d6d:	01 d0                	add    %edx,%eax
80105d6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105d75:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105d79:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105d7d:	7e e1                	jle    80105d60 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105d7f:	90                   	nop
80105d80:	c9                   	leave  
80105d81:	c3                   	ret    

80105d82 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105d82:	55                   	push   %ebp
80105d83:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105d85:	8b 45 08             	mov    0x8(%ebp),%eax
80105d88:	8b 00                	mov    (%eax),%eax
80105d8a:	85 c0                	test   %eax,%eax
80105d8c:	74 17                	je     80105da5 <holding+0x23>
80105d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d91:	8b 50 08             	mov    0x8(%eax),%edx
80105d94:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d9a:	39 c2                	cmp    %eax,%edx
80105d9c:	75 07                	jne    80105da5 <holding+0x23>
80105d9e:	b8 01 00 00 00       	mov    $0x1,%eax
80105da3:	eb 05                	jmp    80105daa <holding+0x28>
80105da5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105daa:	5d                   	pop    %ebp
80105dab:	c3                   	ret    

80105dac <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105dac:	55                   	push   %ebp
80105dad:	89 e5                	mov    %esp,%ebp
80105daf:	83 ec 10             	sub    $0x10,%esp
  int eflags;

  eflags = readeflags();
80105db2:	e8 3e fe ff ff       	call   80105bf5 <readeflags>
80105db7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105dba:	e8 46 fe ff ff       	call   80105c05 <cli>
  if(cpu->ncli++ == 0)
80105dbf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105dc6:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105dcc:	8d 48 01             	lea    0x1(%eax),%ecx
80105dcf:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105dd5:	85 c0                	test   %eax,%eax
80105dd7:	75 15                	jne    80105dee <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105dd9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ddf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105de2:	81 e2 00 02 00 00    	and    $0x200,%edx
80105de8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105dee:	90                   	nop
80105def:	c9                   	leave  
80105df0:	c3                   	ret    

80105df1 <popcli>:

void
popcli(void)
{
80105df1:	55                   	push   %ebp
80105df2:	89 e5                	mov    %esp,%ebp
80105df4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105df7:	e8 f9 fd ff ff       	call   80105bf5 <readeflags>
80105dfc:	25 00 02 00 00       	and    $0x200,%eax
80105e01:	85 c0                	test   %eax,%eax
80105e03:	74 0d                	je     80105e12 <popcli+0x21>
    panic("popcli - interruptible");
80105e05:	83 ec 0c             	sub    $0xc,%esp
80105e08:	68 5a 9b 10 80       	push   $0x80109b5a
80105e0d:	e8 54 a7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105e12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e18:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105e1e:	83 ea 01             	sub    $0x1,%edx
80105e21:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105e27:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105e2d:	85 c0                	test   %eax,%eax
80105e2f:	79 0d                	jns    80105e3e <popcli+0x4d>
    panic("popcli");
80105e31:	83 ec 0c             	sub    $0xc,%esp
80105e34:	68 71 9b 10 80       	push   $0x80109b71
80105e39:	e8 28 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105e3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e44:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105e4a:	85 c0                	test   %eax,%eax
80105e4c:	75 15                	jne    80105e63 <popcli+0x72>
80105e4e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e54:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105e5a:	85 c0                	test   %eax,%eax
80105e5c:	74 05                	je     80105e63 <popcli+0x72>
    sti();
80105e5e:	e8 a9 fd ff ff       	call   80105c0c <sti>
}
80105e63:	90                   	nop
80105e64:	c9                   	leave  
80105e65:	c3                   	ret    

80105e66 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105e66:	55                   	push   %ebp
80105e67:	89 e5                	mov    %esp,%ebp
80105e69:	57                   	push   %edi
80105e6a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e6e:	8b 55 10             	mov    0x10(%ebp),%edx
80105e71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e74:	89 cb                	mov    %ecx,%ebx
80105e76:	89 df                	mov    %ebx,%edi
80105e78:	89 d1                	mov    %edx,%ecx
80105e7a:	fc                   	cld    
80105e7b:	f3 aa                	rep stos %al,%es:(%edi)
80105e7d:	89 ca                	mov    %ecx,%edx
80105e7f:	89 fb                	mov    %edi,%ebx
80105e81:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105e84:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105e87:	90                   	nop
80105e88:	5b                   	pop    %ebx
80105e89:	5f                   	pop    %edi
80105e8a:	5d                   	pop    %ebp
80105e8b:	c3                   	ret    

80105e8c <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105e8c:	55                   	push   %ebp
80105e8d:	89 e5                	mov    %esp,%ebp
80105e8f:	57                   	push   %edi
80105e90:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105e91:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105e94:	8b 55 10             	mov    0x10(%ebp),%edx
80105e97:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e9a:	89 cb                	mov    %ecx,%ebx
80105e9c:	89 df                	mov    %ebx,%edi
80105e9e:	89 d1                	mov    %edx,%ecx
80105ea0:	fc                   	cld    
80105ea1:	f3 ab                	rep stos %eax,%es:(%edi)
80105ea3:	89 ca                	mov    %ecx,%edx
80105ea5:	89 fb                	mov    %edi,%ebx
80105ea7:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105eaa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105ead:	90                   	nop
80105eae:	5b                   	pop    %ebx
80105eaf:	5f                   	pop    %edi
80105eb0:	5d                   	pop    %ebp
80105eb1:	c3                   	ret    

80105eb2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105eb2:	55                   	push   %ebp
80105eb3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb8:	83 e0 03             	and    $0x3,%eax
80105ebb:	85 c0                	test   %eax,%eax
80105ebd:	75 43                	jne    80105f02 <memset+0x50>
80105ebf:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec2:	83 e0 03             	and    $0x3,%eax
80105ec5:	85 c0                	test   %eax,%eax
80105ec7:	75 39                	jne    80105f02 <memset+0x50>
    c &= 0xFF;
80105ec9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105ed0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed3:	c1 e8 02             	shr    $0x2,%eax
80105ed6:	89 c1                	mov    %eax,%ecx
80105ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105edb:	c1 e0 18             	shl    $0x18,%eax
80105ede:	89 c2                	mov    %eax,%edx
80105ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ee3:	c1 e0 10             	shl    $0x10,%eax
80105ee6:	09 c2                	or     %eax,%edx
80105ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eeb:	c1 e0 08             	shl    $0x8,%eax
80105eee:	09 d0                	or     %edx,%eax
80105ef0:	0b 45 0c             	or     0xc(%ebp),%eax
80105ef3:	51                   	push   %ecx
80105ef4:	50                   	push   %eax
80105ef5:	ff 75 08             	pushl  0x8(%ebp)
80105ef8:	e8 8f ff ff ff       	call   80105e8c <stosl>
80105efd:	83 c4 0c             	add    $0xc,%esp
80105f00:	eb 12                	jmp    80105f14 <memset+0x62>
  } else
    stosb(dst, c, n);
80105f02:	8b 45 10             	mov    0x10(%ebp),%eax
80105f05:	50                   	push   %eax
80105f06:	ff 75 0c             	pushl  0xc(%ebp)
80105f09:	ff 75 08             	pushl  0x8(%ebp)
80105f0c:	e8 55 ff ff ff       	call   80105e66 <stosb>
80105f11:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105f14:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f17:	c9                   	leave  
80105f18:	c3                   	ret    

80105f19 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105f19:	55                   	push   %ebp
80105f1a:	89 e5                	mov    %esp,%ebp
80105f1c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105f25:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f28:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105f2b:	eb 30                	jmp    80105f5d <memcmp+0x44>
    if(*s1 != *s2)
80105f2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f30:	0f b6 10             	movzbl (%eax),%edx
80105f33:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f36:	0f b6 00             	movzbl (%eax),%eax
80105f39:	38 c2                	cmp    %al,%dl
80105f3b:	74 18                	je     80105f55 <memcmp+0x3c>
      return *s1 - *s2;
80105f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f40:	0f b6 00             	movzbl (%eax),%eax
80105f43:	0f b6 d0             	movzbl %al,%edx
80105f46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f49:	0f b6 00             	movzbl (%eax),%eax
80105f4c:	0f b6 c0             	movzbl %al,%eax
80105f4f:	29 c2                	sub    %eax,%edx
80105f51:	89 d0                	mov    %edx,%eax
80105f53:	eb 1a                	jmp    80105f6f <memcmp+0x56>
    s1++, s2++;
80105f55:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f59:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105f5d:	8b 45 10             	mov    0x10(%ebp),%eax
80105f60:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f63:	89 55 10             	mov    %edx,0x10(%ebp)
80105f66:	85 c0                	test   %eax,%eax
80105f68:	75 c3                	jne    80105f2d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105f6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f6f:	c9                   	leave  
80105f70:	c3                   	ret    

80105f71 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105f71:	55                   	push   %ebp
80105f72:	89 e5                	mov    %esp,%ebp
80105f74:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105f77:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f80:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105f83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f86:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f89:	73 54                	jae    80105fdf <memmove+0x6e>
80105f8b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f8e:	8b 45 10             	mov    0x10(%ebp),%eax
80105f91:	01 d0                	add    %edx,%eax
80105f93:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105f96:	76 47                	jbe    80105fdf <memmove+0x6e>
    s += n;
80105f98:	8b 45 10             	mov    0x10(%ebp),%eax
80105f9b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105f9e:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105fa4:	eb 13                	jmp    80105fb9 <memmove+0x48>
      *--d = *--s;
80105fa6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105faa:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fb1:	0f b6 10             	movzbl (%eax),%edx
80105fb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105fb7:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105fb9:	8b 45 10             	mov    0x10(%ebp),%eax
80105fbc:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fbf:	89 55 10             	mov    %edx,0x10(%ebp)
80105fc2:	85 c0                	test   %eax,%eax
80105fc4:	75 e0                	jne    80105fa6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105fc6:	eb 24                	jmp    80105fec <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105fc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105fcb:	8d 50 01             	lea    0x1(%eax),%edx
80105fce:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105fd1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105fd4:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fd7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105fda:	0f b6 12             	movzbl (%edx),%edx
80105fdd:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105fdf:	8b 45 10             	mov    0x10(%ebp),%eax
80105fe2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fe5:	89 55 10             	mov    %edx,0x10(%ebp)
80105fe8:	85 c0                	test   %eax,%eax
80105fea:	75 dc                	jne    80105fc8 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105fec:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105fef:	c9                   	leave  
80105ff0:	c3                   	ret    

80105ff1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105ff1:	55                   	push   %ebp
80105ff2:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105ff4:	ff 75 10             	pushl  0x10(%ebp)
80105ff7:	ff 75 0c             	pushl  0xc(%ebp)
80105ffa:	ff 75 08             	pushl  0x8(%ebp)
80105ffd:	e8 6f ff ff ff       	call   80105f71 <memmove>
80106002:	83 c4 0c             	add    $0xc,%esp
}
80106005:	c9                   	leave  
80106006:	c3                   	ret    

80106007 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106007:	55                   	push   %ebp
80106008:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010600a:	eb 0c                	jmp    80106018 <strncmp+0x11>
    n--, p++, q++;
8010600c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106010:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106014:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106018:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010601c:	74 1a                	je     80106038 <strncmp+0x31>
8010601e:	8b 45 08             	mov    0x8(%ebp),%eax
80106021:	0f b6 00             	movzbl (%eax),%eax
80106024:	84 c0                	test   %al,%al
80106026:	74 10                	je     80106038 <strncmp+0x31>
80106028:	8b 45 08             	mov    0x8(%ebp),%eax
8010602b:	0f b6 10             	movzbl (%eax),%edx
8010602e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106031:	0f b6 00             	movzbl (%eax),%eax
80106034:	38 c2                	cmp    %al,%dl
80106036:	74 d4                	je     8010600c <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106038:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010603c:	75 07                	jne    80106045 <strncmp+0x3e>
    return 0;
8010603e:	b8 00 00 00 00       	mov    $0x0,%eax
80106043:	eb 16                	jmp    8010605b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106045:	8b 45 08             	mov    0x8(%ebp),%eax
80106048:	0f b6 00             	movzbl (%eax),%eax
8010604b:	0f b6 d0             	movzbl %al,%edx
8010604e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106051:	0f b6 00             	movzbl (%eax),%eax
80106054:	0f b6 c0             	movzbl %al,%eax
80106057:	29 c2                	sub    %eax,%edx
80106059:	89 d0                	mov    %edx,%eax
}
8010605b:	5d                   	pop    %ebp
8010605c:	c3                   	ret    

8010605d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010605d:	55                   	push   %ebp
8010605e:	89 e5                	mov    %esp,%ebp
80106060:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106063:	8b 45 08             	mov    0x8(%ebp),%eax
80106066:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106069:	90                   	nop
8010606a:	8b 45 10             	mov    0x10(%ebp),%eax
8010606d:	8d 50 ff             	lea    -0x1(%eax),%edx
80106070:	89 55 10             	mov    %edx,0x10(%ebp)
80106073:	85 c0                	test   %eax,%eax
80106075:	7e 2c                	jle    801060a3 <strncpy+0x46>
80106077:	8b 45 08             	mov    0x8(%ebp),%eax
8010607a:	8d 50 01             	lea    0x1(%eax),%edx
8010607d:	89 55 08             	mov    %edx,0x8(%ebp)
80106080:	8b 55 0c             	mov    0xc(%ebp),%edx
80106083:	8d 4a 01             	lea    0x1(%edx),%ecx
80106086:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106089:	0f b6 12             	movzbl (%edx),%edx
8010608c:	88 10                	mov    %dl,(%eax)
8010608e:	0f b6 00             	movzbl (%eax),%eax
80106091:	84 c0                	test   %al,%al
80106093:	75 d5                	jne    8010606a <strncpy+0xd>
    ;
  while(n-- > 0)
80106095:	eb 0c                	jmp    801060a3 <strncpy+0x46>
    *s++ = 0;
80106097:	8b 45 08             	mov    0x8(%ebp),%eax
8010609a:	8d 50 01             	lea    0x1(%eax),%edx
8010609d:	89 55 08             	mov    %edx,0x8(%ebp)
801060a0:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801060a3:	8b 45 10             	mov    0x10(%ebp),%eax
801060a6:	8d 50 ff             	lea    -0x1(%eax),%edx
801060a9:	89 55 10             	mov    %edx,0x10(%ebp)
801060ac:	85 c0                	test   %eax,%eax
801060ae:	7f e7                	jg     80106097 <strncpy+0x3a>
    *s++ = 0;
  return os;
801060b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060b3:	c9                   	leave  
801060b4:	c3                   	ret    

801060b5 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801060bb:	8b 45 08             	mov    0x8(%ebp),%eax
801060be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801060c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060c5:	7f 05                	jg     801060cc <safestrcpy+0x17>
    return os;
801060c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060ca:	eb 31                	jmp    801060fd <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801060cc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801060d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060d4:	7e 1e                	jle    801060f4 <safestrcpy+0x3f>
801060d6:	8b 45 08             	mov    0x8(%ebp),%eax
801060d9:	8d 50 01             	lea    0x1(%eax),%edx
801060dc:	89 55 08             	mov    %edx,0x8(%ebp)
801060df:	8b 55 0c             	mov    0xc(%ebp),%edx
801060e2:	8d 4a 01             	lea    0x1(%edx),%ecx
801060e5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801060e8:	0f b6 12             	movzbl (%edx),%edx
801060eb:	88 10                	mov    %dl,(%eax)
801060ed:	0f b6 00             	movzbl (%eax),%eax
801060f0:	84 c0                	test   %al,%al
801060f2:	75 d8                	jne    801060cc <safestrcpy+0x17>
    ;
  *s = 0;
801060f4:	8b 45 08             	mov    0x8(%ebp),%eax
801060f7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801060fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060fd:	c9                   	leave  
801060fe:	c3                   	ret    

801060ff <strlen>:

int
strlen(const char *s)
{
801060ff:	55                   	push   %ebp
80106100:	89 e5                	mov    %esp,%ebp
80106102:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106105:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010610c:	eb 04                	jmp    80106112 <strlen+0x13>
8010610e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106112:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106115:	8b 45 08             	mov    0x8(%ebp),%eax
80106118:	01 d0                	add    %edx,%eax
8010611a:	0f b6 00             	movzbl (%eax),%eax
8010611d:	84 c0                	test   %al,%al
8010611f:	75 ed                	jne    8010610e <strlen+0xf>
    ;
  return n;
80106121:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106124:	c9                   	leave  
80106125:	c3                   	ret    

80106126 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106126:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010612a:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010612e:	55                   	push   %ebp
  pushl %ebx
8010612f:	53                   	push   %ebx
  pushl %esi
80106130:	56                   	push   %esi
  pushl %edi
80106131:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106132:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106134:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106136:	5f                   	pop    %edi
  popl %esi
80106137:	5e                   	pop    %esi
  popl %ebx
80106138:	5b                   	pop    %ebx
  popl %ebp
80106139:	5d                   	pop    %ebp
  ret
8010613a:	c3                   	ret    

8010613b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010613b:	55                   	push   %ebp
8010613c:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010613e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106144:	8b 00                	mov    (%eax),%eax
80106146:	3b 45 08             	cmp    0x8(%ebp),%eax
80106149:	76 12                	jbe    8010615d <fetchint+0x22>
8010614b:	8b 45 08             	mov    0x8(%ebp),%eax
8010614e:	8d 50 04             	lea    0x4(%eax),%edx
80106151:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106157:	8b 00                	mov    (%eax),%eax
80106159:	39 c2                	cmp    %eax,%edx
8010615b:	76 07                	jbe    80106164 <fetchint+0x29>
    return -1;
8010615d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106162:	eb 0f                	jmp    80106173 <fetchint+0x38>
  *ip = *(int*)(addr);
80106164:	8b 45 08             	mov    0x8(%ebp),%eax
80106167:	8b 10                	mov    (%eax),%edx
80106169:	8b 45 0c             	mov    0xc(%ebp),%eax
8010616c:	89 10                	mov    %edx,(%eax)
  return 0;
8010616e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106173:	5d                   	pop    %ebp
80106174:	c3                   	ret    

80106175 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106175:	55                   	push   %ebp
80106176:	89 e5                	mov    %esp,%ebp
80106178:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010617b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106181:	8b 00                	mov    (%eax),%eax
80106183:	3b 45 08             	cmp    0x8(%ebp),%eax
80106186:	77 07                	ja     8010618f <fetchstr+0x1a>
    return -1;
80106188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618d:	eb 46                	jmp    801061d5 <fetchstr+0x60>
  *pp = (char*)addr;
8010618f:	8b 55 08             	mov    0x8(%ebp),%edx
80106192:	8b 45 0c             	mov    0xc(%ebp),%eax
80106195:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106197:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010619d:	8b 00                	mov    (%eax),%eax
8010619f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801061a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a5:	8b 00                	mov    (%eax),%eax
801061a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
801061aa:	eb 1c                	jmp    801061c8 <fetchstr+0x53>
    if(*s == 0)
801061ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061af:	0f b6 00             	movzbl (%eax),%eax
801061b2:	84 c0                	test   %al,%al
801061b4:	75 0e                	jne    801061c4 <fetchstr+0x4f>
      return s - *pp;
801061b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801061bc:	8b 00                	mov    (%eax),%eax
801061be:	29 c2                	sub    %eax,%edx
801061c0:	89 d0                	mov    %edx,%eax
801061c2:	eb 11                	jmp    801061d5 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801061c4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801061c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061cb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801061ce:	72 dc                	jb     801061ac <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801061d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061d5:	c9                   	leave  
801061d6:	c3                   	ret    

801061d7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801061d7:	55                   	push   %ebp
801061d8:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801061da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e0:	8b 40 18             	mov    0x18(%eax),%eax
801061e3:	8b 40 44             	mov    0x44(%eax),%eax
801061e6:	8b 55 08             	mov    0x8(%ebp),%edx
801061e9:	c1 e2 02             	shl    $0x2,%edx
801061ec:	01 d0                	add    %edx,%eax
801061ee:	83 c0 04             	add    $0x4,%eax
801061f1:	ff 75 0c             	pushl  0xc(%ebp)
801061f4:	50                   	push   %eax
801061f5:	e8 41 ff ff ff       	call   8010613b <fetchint>
801061fa:	83 c4 08             	add    $0x8,%esp
}
801061fd:	c9                   	leave  
801061fe:	c3                   	ret    

801061ff <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801061ff:	55                   	push   %ebp
80106200:	89 e5                	mov    %esp,%ebp
80106202:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80106205:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106208:	50                   	push   %eax
80106209:	ff 75 08             	pushl  0x8(%ebp)
8010620c:	e8 c6 ff ff ff       	call   801061d7 <argint>
80106211:	83 c4 08             	add    $0x8,%esp
80106214:	85 c0                	test   %eax,%eax
80106216:	79 07                	jns    8010621f <argptr+0x20>
    return -1;
80106218:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621d:	eb 3b                	jmp    8010625a <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010621f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106225:	8b 00                	mov    (%eax),%eax
80106227:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010622a:	39 d0                	cmp    %edx,%eax
8010622c:	76 16                	jbe    80106244 <argptr+0x45>
8010622e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106231:	89 c2                	mov    %eax,%edx
80106233:	8b 45 10             	mov    0x10(%ebp),%eax
80106236:	01 c2                	add    %eax,%edx
80106238:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010623e:	8b 00                	mov    (%eax),%eax
80106240:	39 c2                	cmp    %eax,%edx
80106242:	76 07                	jbe    8010624b <argptr+0x4c>
    return -1;
80106244:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106249:	eb 0f                	jmp    8010625a <argptr+0x5b>
  *pp = (char*)i;
8010624b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010624e:	89 c2                	mov    %eax,%edx
80106250:	8b 45 0c             	mov    0xc(%ebp),%eax
80106253:	89 10                	mov    %edx,(%eax)
  return 0;
80106255:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010625a:	c9                   	leave  
8010625b:	c3                   	ret    

8010625c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010625c:	55                   	push   %ebp
8010625d:	89 e5                	mov    %esp,%ebp
8010625f:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106262:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106265:	50                   	push   %eax
80106266:	ff 75 08             	pushl  0x8(%ebp)
80106269:	e8 69 ff ff ff       	call   801061d7 <argint>
8010626e:	83 c4 08             	add    $0x8,%esp
80106271:	85 c0                	test   %eax,%eax
80106273:	79 07                	jns    8010627c <argstr+0x20>
    return -1;
80106275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627a:	eb 0f                	jmp    8010628b <argstr+0x2f>
  return fetchstr(addr, pp);
8010627c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010627f:	ff 75 0c             	pushl  0xc(%ebp)
80106282:	50                   	push   %eax
80106283:	e8 ed fe ff ff       	call   80106175 <fetchstr>
80106288:	83 c4 08             	add    $0x8,%esp
}
8010628b:	c9                   	leave  
8010628c:	c3                   	ret    

8010628d <syscall>:
[SYS_munmap]   sys_munmap
};

void
syscall(void)
{
8010628d:	55                   	push   %ebp
8010628e:	89 e5                	mov    %esp,%ebp
80106290:	53                   	push   %ebx
80106291:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106294:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010629a:	8b 40 18             	mov    0x18(%eax),%eax
8010629d:	8b 40 1c             	mov    0x1c(%eax),%eax
801062a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801062a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062a7:	7e 30                	jle    801062d9 <syscall+0x4c>
801062a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ac:	83 f8 1e             	cmp    $0x1e,%eax
801062af:	77 28                	ja     801062d9 <syscall+0x4c>
801062b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b4:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801062bb:	85 c0                	test   %eax,%eax
801062bd:	74 1a                	je     801062d9 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801062bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062c5:	8b 58 18             	mov    0x18(%eax),%ebx
801062c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cb:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801062d2:	ff d0                	call   *%eax
801062d4:	89 43 1c             	mov    %eax,0x1c(%ebx)
801062d7:	eb 34                	jmp    8010630d <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801062d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062df:	8d 50 6c             	lea    0x6c(%eax),%edx
801062e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801062e8:	8b 40 10             	mov    0x10(%eax),%eax
801062eb:	ff 75 f4             	pushl  -0xc(%ebp)
801062ee:	52                   	push   %edx
801062ef:	50                   	push   %eax
801062f0:	68 78 9b 10 80       	push   $0x80109b78
801062f5:	e8 cc a0 ff ff       	call   801003c6 <cprintf>
801062fa:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801062fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106303:	8b 40 18             	mov    0x18(%eax),%eax
80106306:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010630d:	90                   	nop
8010630e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106311:	c9                   	leave  
80106312:	c3                   	ret    

80106313 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106313:	55                   	push   %ebp
80106314:	89 e5                	mov    %esp,%ebp
80106316:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106319:	83 ec 08             	sub    $0x8,%esp
8010631c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010631f:	50                   	push   %eax
80106320:	ff 75 08             	pushl  0x8(%ebp)
80106323:	e8 af fe ff ff       	call   801061d7 <argint>
80106328:	83 c4 10             	add    $0x10,%esp
8010632b:	85 c0                	test   %eax,%eax
8010632d:	79 07                	jns    80106336 <argfd+0x23>
    return -1;
8010632f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106334:	eb 50                	jmp    80106386 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80106336:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106339:	85 c0                	test   %eax,%eax
8010633b:	78 21                	js     8010635e <argfd+0x4b>
8010633d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106340:	83 f8 0f             	cmp    $0xf,%eax
80106343:	7f 19                	jg     8010635e <argfd+0x4b>
80106345:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010634b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010634e:	83 c2 08             	add    $0x8,%edx
80106351:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106355:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106358:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010635c:	75 07                	jne    80106365 <argfd+0x52>
    return -1;
8010635e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106363:	eb 21                	jmp    80106386 <argfd+0x73>
  if(pfd)
80106365:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106369:	74 08                	je     80106373 <argfd+0x60>
    *pfd = fd;
8010636b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010636e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106371:	89 10                	mov    %edx,(%eax)
  if(pf)
80106373:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106377:	74 08                	je     80106381 <argfd+0x6e>
    *pf = f;
80106379:	8b 45 10             	mov    0x10(%ebp),%eax
8010637c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010637f:	89 10                	mov    %edx,(%eax)
  return 0;
80106381:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106386:	c9                   	leave  
80106387:	c3                   	ret    

80106388 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106388:	55                   	push   %ebp
80106389:	89 e5                	mov    %esp,%ebp
8010638b:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010638e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106395:	eb 30                	jmp    801063c7 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80106397:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010639d:	8b 55 fc             	mov    -0x4(%ebp),%edx
801063a0:	83 c2 08             	add    $0x8,%edx
801063a3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801063a7:	85 c0                	test   %eax,%eax
801063a9:	75 18                	jne    801063c3 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801063ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801063b4:	8d 4a 08             	lea    0x8(%edx),%ecx
801063b7:	8b 55 08             	mov    0x8(%ebp),%edx
801063ba:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801063be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801063c1:	eb 0f                	jmp    801063d2 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801063c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801063c7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801063cb:	7e ca                	jle    80106397 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801063cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801063d2:	c9                   	leave  
801063d3:	c3                   	ret    

801063d4 <sys_dup>:

int
sys_dup(void)
{
801063d4:	55                   	push   %ebp
801063d5:	89 e5                	mov    %esp,%ebp
801063d7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801063da:	83 ec 04             	sub    $0x4,%esp
801063dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e0:	50                   	push   %eax
801063e1:	6a 00                	push   $0x0
801063e3:	6a 00                	push   $0x0
801063e5:	e8 29 ff ff ff       	call   80106313 <argfd>
801063ea:	83 c4 10             	add    $0x10,%esp
801063ed:	85 c0                	test   %eax,%eax
801063ef:	79 07                	jns    801063f8 <sys_dup+0x24>
    return -1;
801063f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f6:	eb 31                	jmp    80106429 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801063f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fb:	83 ec 0c             	sub    $0xc,%esp
801063fe:	50                   	push   %eax
801063ff:	e8 84 ff ff ff       	call   80106388 <fdalloc>
80106404:	83 c4 10             	add    $0x10,%esp
80106407:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010640a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010640e:	79 07                	jns    80106417 <sys_dup+0x43>
    return -1;
80106410:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106415:	eb 12                	jmp    80106429 <sys_dup+0x55>
  filedup(f);
80106417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641a:	83 ec 0c             	sub    $0xc,%esp
8010641d:	50                   	push   %eax
8010641e:	e8 ca ab ff ff       	call   80100fed <filedup>
80106423:	83 c4 10             	add    $0x10,%esp
  return fd;
80106426:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106429:	c9                   	leave  
8010642a:	c3                   	ret    

8010642b <sys_read>:

int
sys_read(void)
{
8010642b:	55                   	push   %ebp
8010642c:	89 e5                	mov    %esp,%ebp
8010642e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106431:	83 ec 04             	sub    $0x4,%esp
80106434:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106437:	50                   	push   %eax
80106438:	6a 00                	push   $0x0
8010643a:	6a 00                	push   $0x0
8010643c:	e8 d2 fe ff ff       	call   80106313 <argfd>
80106441:	83 c4 10             	add    $0x10,%esp
80106444:	85 c0                	test   %eax,%eax
80106446:	78 2e                	js     80106476 <sys_read+0x4b>
80106448:	83 ec 08             	sub    $0x8,%esp
8010644b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010644e:	50                   	push   %eax
8010644f:	6a 02                	push   $0x2
80106451:	e8 81 fd ff ff       	call   801061d7 <argint>
80106456:	83 c4 10             	add    $0x10,%esp
80106459:	85 c0                	test   %eax,%eax
8010645b:	78 19                	js     80106476 <sys_read+0x4b>
8010645d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106460:	83 ec 04             	sub    $0x4,%esp
80106463:	50                   	push   %eax
80106464:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106467:	50                   	push   %eax
80106468:	6a 01                	push   $0x1
8010646a:	e8 90 fd ff ff       	call   801061ff <argptr>
8010646f:	83 c4 10             	add    $0x10,%esp
80106472:	85 c0                	test   %eax,%eax
80106474:	79 07                	jns    8010647d <sys_read+0x52>
    return -1;
80106476:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647b:	eb 17                	jmp    80106494 <sys_read+0x69>
  return fileread(f, p, n);
8010647d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106480:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106486:	83 ec 04             	sub    $0x4,%esp
80106489:	51                   	push   %ecx
8010648a:	52                   	push   %edx
8010648b:	50                   	push   %eax
8010648c:	e8 ec ac ff ff       	call   8010117d <fileread>
80106491:	83 c4 10             	add    $0x10,%esp
}
80106494:	c9                   	leave  
80106495:	c3                   	ret    

80106496 <sys_write>:

int
sys_write(void)
{
80106496:	55                   	push   %ebp
80106497:	89 e5                	mov    %esp,%ebp
80106499:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010649c:	83 ec 04             	sub    $0x4,%esp
8010649f:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064a2:	50                   	push   %eax
801064a3:	6a 00                	push   $0x0
801064a5:	6a 00                	push   $0x0
801064a7:	e8 67 fe ff ff       	call   80106313 <argfd>
801064ac:	83 c4 10             	add    $0x10,%esp
801064af:	85 c0                	test   %eax,%eax
801064b1:	78 2e                	js     801064e1 <sys_write+0x4b>
801064b3:	83 ec 08             	sub    $0x8,%esp
801064b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b9:	50                   	push   %eax
801064ba:	6a 02                	push   $0x2
801064bc:	e8 16 fd ff ff       	call   801061d7 <argint>
801064c1:	83 c4 10             	add    $0x10,%esp
801064c4:	85 c0                	test   %eax,%eax
801064c6:	78 19                	js     801064e1 <sys_write+0x4b>
801064c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cb:	83 ec 04             	sub    $0x4,%esp
801064ce:	50                   	push   %eax
801064cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064d2:	50                   	push   %eax
801064d3:	6a 01                	push   $0x1
801064d5:	e8 25 fd ff ff       	call   801061ff <argptr>
801064da:	83 c4 10             	add    $0x10,%esp
801064dd:	85 c0                	test   %eax,%eax
801064df:	79 07                	jns    801064e8 <sys_write+0x52>
    return -1;
801064e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e6:	eb 17                	jmp    801064ff <sys_write+0x69>
  return filewrite(f, p, n);
801064e8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801064eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801064ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f1:	83 ec 04             	sub    $0x4,%esp
801064f4:	51                   	push   %ecx
801064f5:	52                   	push   %edx
801064f6:	50                   	push   %eax
801064f7:	e8 39 ad ff ff       	call   80101235 <filewrite>
801064fc:	83 c4 10             	add    $0x10,%esp
}
801064ff:	c9                   	leave  
80106500:	c3                   	ret    

80106501 <sys_close>:

int
sys_close(void)
{
80106501:	55                   	push   %ebp
80106502:	89 e5                	mov    %esp,%ebp
80106504:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106507:	83 ec 04             	sub    $0x4,%esp
8010650a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010650d:	50                   	push   %eax
8010650e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106511:	50                   	push   %eax
80106512:	6a 00                	push   $0x0
80106514:	e8 fa fd ff ff       	call   80106313 <argfd>
80106519:	83 c4 10             	add    $0x10,%esp
8010651c:	85 c0                	test   %eax,%eax
8010651e:	79 07                	jns    80106527 <sys_close+0x26>
    return -1;
80106520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106525:	eb 28                	jmp    8010654f <sys_close+0x4e>
  proc->ofile[fd] = 0;
80106527:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106530:	83 c2 08             	add    $0x8,%edx
80106533:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010653a:	00 
  fileclose(f);
8010653b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653e:	83 ec 0c             	sub    $0xc,%esp
80106541:	50                   	push   %eax
80106542:	e8 f7 aa ff ff       	call   8010103e <fileclose>
80106547:	83 c4 10             	add    $0x10,%esp
  return 0;
8010654a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010654f:	c9                   	leave  
80106550:	c3                   	ret    

80106551 <sys_fstat>:

int
sys_fstat(void)
{
80106551:	55                   	push   %ebp
80106552:	89 e5                	mov    %esp,%ebp
80106554:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106557:	83 ec 04             	sub    $0x4,%esp
8010655a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010655d:	50                   	push   %eax
8010655e:	6a 00                	push   $0x0
80106560:	6a 00                	push   $0x0
80106562:	e8 ac fd ff ff       	call   80106313 <argfd>
80106567:	83 c4 10             	add    $0x10,%esp
8010656a:	85 c0                	test   %eax,%eax
8010656c:	78 17                	js     80106585 <sys_fstat+0x34>
8010656e:	83 ec 04             	sub    $0x4,%esp
80106571:	6a 14                	push   $0x14
80106573:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106576:	50                   	push   %eax
80106577:	6a 01                	push   $0x1
80106579:	e8 81 fc ff ff       	call   801061ff <argptr>
8010657e:	83 c4 10             	add    $0x10,%esp
80106581:	85 c0                	test   %eax,%eax
80106583:	79 07                	jns    8010658c <sys_fstat+0x3b>
    return -1;
80106585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658a:	eb 13                	jmp    8010659f <sys_fstat+0x4e>
  return filestat(f, st);
8010658c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010658f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106592:	83 ec 08             	sub    $0x8,%esp
80106595:	52                   	push   %edx
80106596:	50                   	push   %eax
80106597:	e8 8a ab ff ff       	call   80101126 <filestat>
8010659c:	83 c4 10             	add    $0x10,%esp
}
8010659f:	c9                   	leave  
801065a0:	c3                   	ret    

801065a1 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801065a1:	55                   	push   %ebp
801065a2:	89 e5                	mov    %esp,%ebp
801065a4:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801065a7:	83 ec 08             	sub    $0x8,%esp
801065aa:	8d 45 d8             	lea    -0x28(%ebp),%eax
801065ad:	50                   	push   %eax
801065ae:	6a 00                	push   $0x0
801065b0:	e8 a7 fc ff ff       	call   8010625c <argstr>
801065b5:	83 c4 10             	add    $0x10,%esp
801065b8:	85 c0                	test   %eax,%eax
801065ba:	78 15                	js     801065d1 <sys_link+0x30>
801065bc:	83 ec 08             	sub    $0x8,%esp
801065bf:	8d 45 dc             	lea    -0x24(%ebp),%eax
801065c2:	50                   	push   %eax
801065c3:	6a 01                	push   $0x1
801065c5:	e8 92 fc ff ff       	call   8010625c <argstr>
801065ca:	83 c4 10             	add    $0x10,%esp
801065cd:	85 c0                	test   %eax,%eax
801065cf:	79 0a                	jns    801065db <sys_link+0x3a>
    return -1;
801065d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d6:	e9 68 01 00 00       	jmp    80106743 <sys_link+0x1a2>

  begin_op();
801065db:	e8 37 cf ff ff       	call   80103517 <begin_op>
  if((ip = namei(old)) == 0){
801065e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801065e3:	83 ec 0c             	sub    $0xc,%esp
801065e6:	50                   	push   %eax
801065e7:	e8 3a bf ff ff       	call   80102526 <namei>
801065ec:	83 c4 10             	add    $0x10,%esp
801065ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065f6:	75 0f                	jne    80106607 <sys_link+0x66>
    end_op();
801065f8:	e8 a6 cf ff ff       	call   801035a3 <end_op>
    return -1;
801065fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106602:	e9 3c 01 00 00       	jmp    80106743 <sys_link+0x1a2>
  }

  ilock(ip);
80106607:	83 ec 0c             	sub    $0xc,%esp
8010660a:	ff 75 f4             	pushl  -0xc(%ebp)
8010660d:	e8 5c b3 ff ff       	call   8010196e <ilock>
80106612:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80106615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106618:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010661c:	66 83 f8 01          	cmp    $0x1,%ax
80106620:	75 1d                	jne    8010663f <sys_link+0x9e>
    iunlockput(ip);
80106622:	83 ec 0c             	sub    $0xc,%esp
80106625:	ff 75 f4             	pushl  -0xc(%ebp)
80106628:	e8 fb b5 ff ff       	call   80101c28 <iunlockput>
8010662d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106630:	e8 6e cf ff ff       	call   801035a3 <end_op>
    return -1;
80106635:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663a:	e9 04 01 00 00       	jmp    80106743 <sys_link+0x1a2>
  }

  ip->nlink++;
8010663f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106642:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106646:	83 c0 01             	add    $0x1,%eax
80106649:	89 c2                	mov    %eax,%edx
8010664b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106652:	83 ec 0c             	sub    $0xc,%esp
80106655:	ff 75 f4             	pushl  -0xc(%ebp)
80106658:	e8 3d b1 ff ff       	call   8010179a <iupdate>
8010665d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106660:	83 ec 0c             	sub    $0xc,%esp
80106663:	ff 75 f4             	pushl  -0xc(%ebp)
80106666:	e8 5b b4 ff ff       	call   80101ac6 <iunlock>
8010666b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010666e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106671:	83 ec 08             	sub    $0x8,%esp
80106674:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106677:	52                   	push   %edx
80106678:	50                   	push   %eax
80106679:	e8 c4 be ff ff       	call   80102542 <nameiparent>
8010667e:	83 c4 10             	add    $0x10,%esp
80106681:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106684:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106688:	74 71                	je     801066fb <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010668a:	83 ec 0c             	sub    $0xc,%esp
8010668d:	ff 75 f0             	pushl  -0x10(%ebp)
80106690:	e8 d9 b2 ff ff       	call   8010196e <ilock>
80106695:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010669b:	8b 10                	mov    (%eax),%edx
8010669d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a0:	8b 00                	mov    (%eax),%eax
801066a2:	39 c2                	cmp    %eax,%edx
801066a4:	75 1d                	jne    801066c3 <sys_link+0x122>
801066a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a9:	8b 40 04             	mov    0x4(%eax),%eax
801066ac:	83 ec 04             	sub    $0x4,%esp
801066af:	50                   	push   %eax
801066b0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801066b3:	50                   	push   %eax
801066b4:	ff 75 f0             	pushl  -0x10(%ebp)
801066b7:	e8 ce bb ff ff       	call   8010228a <dirlink>
801066bc:	83 c4 10             	add    $0x10,%esp
801066bf:	85 c0                	test   %eax,%eax
801066c1:	79 10                	jns    801066d3 <sys_link+0x132>
    iunlockput(dp);
801066c3:	83 ec 0c             	sub    $0xc,%esp
801066c6:	ff 75 f0             	pushl  -0x10(%ebp)
801066c9:	e8 5a b5 ff ff       	call   80101c28 <iunlockput>
801066ce:	83 c4 10             	add    $0x10,%esp
    goto bad;
801066d1:	eb 29                	jmp    801066fc <sys_link+0x15b>
  }
  iunlockput(dp);
801066d3:	83 ec 0c             	sub    $0xc,%esp
801066d6:	ff 75 f0             	pushl  -0x10(%ebp)
801066d9:	e8 4a b5 ff ff       	call   80101c28 <iunlockput>
801066de:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801066e1:	83 ec 0c             	sub    $0xc,%esp
801066e4:	ff 75 f4             	pushl  -0xc(%ebp)
801066e7:	e8 4c b4 ff ff       	call   80101b38 <iput>
801066ec:	83 c4 10             	add    $0x10,%esp

  end_op();
801066ef:	e8 af ce ff ff       	call   801035a3 <end_op>

  return 0;
801066f4:	b8 00 00 00 00       	mov    $0x0,%eax
801066f9:	eb 48                	jmp    80106743 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801066fb:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801066fc:	83 ec 0c             	sub    $0xc,%esp
801066ff:	ff 75 f4             	pushl  -0xc(%ebp)
80106702:	e8 67 b2 ff ff       	call   8010196e <ilock>
80106707:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010670a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106711:	83 e8 01             	sub    $0x1,%eax
80106714:	89 c2                	mov    %eax,%edx
80106716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106719:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010671d:	83 ec 0c             	sub    $0xc,%esp
80106720:	ff 75 f4             	pushl  -0xc(%ebp)
80106723:	e8 72 b0 ff ff       	call   8010179a <iupdate>
80106728:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010672b:	83 ec 0c             	sub    $0xc,%esp
8010672e:	ff 75 f4             	pushl  -0xc(%ebp)
80106731:	e8 f2 b4 ff ff       	call   80101c28 <iunlockput>
80106736:	83 c4 10             	add    $0x10,%esp
  end_op();
80106739:	e8 65 ce ff ff       	call   801035a3 <end_op>
  return -1;
8010673e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106743:	c9                   	leave  
80106744:	c3                   	ret    

80106745 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106745:	55                   	push   %ebp
80106746:	89 e5                	mov    %esp,%ebp
80106748:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010674b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106752:	eb 40                	jmp    80106794 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106757:	6a 10                	push   $0x10
80106759:	50                   	push   %eax
8010675a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010675d:	50                   	push   %eax
8010675e:	ff 75 08             	pushl  0x8(%ebp)
80106761:	e8 70 b7 ff ff       	call   80101ed6 <readi>
80106766:	83 c4 10             	add    $0x10,%esp
80106769:	83 f8 10             	cmp    $0x10,%eax
8010676c:	74 0d                	je     8010677b <isdirempty+0x36>
      panic("isdirempty: readi");
8010676e:	83 ec 0c             	sub    $0xc,%esp
80106771:	68 94 9b 10 80       	push   $0x80109b94
80106776:	e8 eb 9d ff ff       	call   80100566 <panic>
    if(de.inum != 0)
8010677b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010677f:	66 85 c0             	test   %ax,%ax
80106782:	74 07                	je     8010678b <isdirempty+0x46>
      return 0;
80106784:	b8 00 00 00 00       	mov    $0x0,%eax
80106789:	eb 1b                	jmp    801067a6 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010678b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678e:	83 c0 10             	add    $0x10,%eax
80106791:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106794:	8b 45 08             	mov    0x8(%ebp),%eax
80106797:	8b 50 18             	mov    0x18(%eax),%edx
8010679a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679d:	39 c2                	cmp    %eax,%edx
8010679f:	77 b3                	ja     80106754 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801067a1:	b8 01 00 00 00       	mov    $0x1,%eax
}
801067a6:	c9                   	leave  
801067a7:	c3                   	ret    

801067a8 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801067a8:	55                   	push   %ebp
801067a9:	89 e5                	mov    %esp,%ebp
801067ab:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801067ae:	83 ec 08             	sub    $0x8,%esp
801067b1:	8d 45 cc             	lea    -0x34(%ebp),%eax
801067b4:	50                   	push   %eax
801067b5:	6a 00                	push   $0x0
801067b7:	e8 a0 fa ff ff       	call   8010625c <argstr>
801067bc:	83 c4 10             	add    $0x10,%esp
801067bf:	85 c0                	test   %eax,%eax
801067c1:	79 0a                	jns    801067cd <sys_unlink+0x25>
    return -1;
801067c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c8:	e9 bc 01 00 00       	jmp    80106989 <sys_unlink+0x1e1>

  begin_op();
801067cd:	e8 45 cd ff ff       	call   80103517 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801067d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801067d5:	83 ec 08             	sub    $0x8,%esp
801067d8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801067db:	52                   	push   %edx
801067dc:	50                   	push   %eax
801067dd:	e8 60 bd ff ff       	call   80102542 <nameiparent>
801067e2:	83 c4 10             	add    $0x10,%esp
801067e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ec:	75 0f                	jne    801067fd <sys_unlink+0x55>
    end_op();
801067ee:	e8 b0 cd ff ff       	call   801035a3 <end_op>
    return -1;
801067f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f8:	e9 8c 01 00 00       	jmp    80106989 <sys_unlink+0x1e1>
  }

  ilock(dp);
801067fd:	83 ec 0c             	sub    $0xc,%esp
80106800:	ff 75 f4             	pushl  -0xc(%ebp)
80106803:	e8 66 b1 ff ff       	call   8010196e <ilock>
80106808:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010680b:	83 ec 08             	sub    $0x8,%esp
8010680e:	68 a6 9b 10 80       	push   $0x80109ba6
80106813:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106816:	50                   	push   %eax
80106817:	e8 99 b9 ff ff       	call   801021b5 <namecmp>
8010681c:	83 c4 10             	add    $0x10,%esp
8010681f:	85 c0                	test   %eax,%eax
80106821:	0f 84 4a 01 00 00    	je     80106971 <sys_unlink+0x1c9>
80106827:	83 ec 08             	sub    $0x8,%esp
8010682a:	68 a8 9b 10 80       	push   $0x80109ba8
8010682f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106832:	50                   	push   %eax
80106833:	e8 7d b9 ff ff       	call   801021b5 <namecmp>
80106838:	83 c4 10             	add    $0x10,%esp
8010683b:	85 c0                	test   %eax,%eax
8010683d:	0f 84 2e 01 00 00    	je     80106971 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106843:	83 ec 04             	sub    $0x4,%esp
80106846:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106849:	50                   	push   %eax
8010684a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010684d:	50                   	push   %eax
8010684e:	ff 75 f4             	pushl  -0xc(%ebp)
80106851:	e8 7a b9 ff ff       	call   801021d0 <dirlookup>
80106856:	83 c4 10             	add    $0x10,%esp
80106859:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010685c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106860:	0f 84 0a 01 00 00    	je     80106970 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106866:	83 ec 0c             	sub    $0xc,%esp
80106869:	ff 75 f0             	pushl  -0x10(%ebp)
8010686c:	e8 fd b0 ff ff       	call   8010196e <ilock>
80106871:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106877:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010687b:	66 85 c0             	test   %ax,%ax
8010687e:	7f 0d                	jg     8010688d <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106880:	83 ec 0c             	sub    $0xc,%esp
80106883:	68 ab 9b 10 80       	push   $0x80109bab
80106888:	e8 d9 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010688d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106890:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106894:	66 83 f8 01          	cmp    $0x1,%ax
80106898:	75 25                	jne    801068bf <sys_unlink+0x117>
8010689a:	83 ec 0c             	sub    $0xc,%esp
8010689d:	ff 75 f0             	pushl  -0x10(%ebp)
801068a0:	e8 a0 fe ff ff       	call   80106745 <isdirempty>
801068a5:	83 c4 10             	add    $0x10,%esp
801068a8:	85 c0                	test   %eax,%eax
801068aa:	75 13                	jne    801068bf <sys_unlink+0x117>
    iunlockput(ip);
801068ac:	83 ec 0c             	sub    $0xc,%esp
801068af:	ff 75 f0             	pushl  -0x10(%ebp)
801068b2:	e8 71 b3 ff ff       	call   80101c28 <iunlockput>
801068b7:	83 c4 10             	add    $0x10,%esp
    goto bad;
801068ba:	e9 b2 00 00 00       	jmp    80106971 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801068bf:	83 ec 04             	sub    $0x4,%esp
801068c2:	6a 10                	push   $0x10
801068c4:	6a 00                	push   $0x0
801068c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068c9:	50                   	push   %eax
801068ca:	e8 e3 f5 ff ff       	call   80105eb2 <memset>
801068cf:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801068d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
801068d5:	6a 10                	push   $0x10
801068d7:	50                   	push   %eax
801068d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068db:	50                   	push   %eax
801068dc:	ff 75 f4             	pushl  -0xc(%ebp)
801068df:	e8 49 b7 ff ff       	call   8010202d <writei>
801068e4:	83 c4 10             	add    $0x10,%esp
801068e7:	83 f8 10             	cmp    $0x10,%eax
801068ea:	74 0d                	je     801068f9 <sys_unlink+0x151>
    panic("unlink: writei");
801068ec:	83 ec 0c             	sub    $0xc,%esp
801068ef:	68 bd 9b 10 80       	push   $0x80109bbd
801068f4:	e8 6d 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801068f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068fc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106900:	66 83 f8 01          	cmp    $0x1,%ax
80106904:	75 21                	jne    80106927 <sys_unlink+0x17f>
    dp->nlink--;
80106906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106909:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010690d:	83 e8 01             	sub    $0x1,%eax
80106910:	89 c2                	mov    %eax,%edx
80106912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106915:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106919:	83 ec 0c             	sub    $0xc,%esp
8010691c:	ff 75 f4             	pushl  -0xc(%ebp)
8010691f:	e8 76 ae ff ff       	call   8010179a <iupdate>
80106924:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106927:	83 ec 0c             	sub    $0xc,%esp
8010692a:	ff 75 f4             	pushl  -0xc(%ebp)
8010692d:	e8 f6 b2 ff ff       	call   80101c28 <iunlockput>
80106932:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106938:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010693c:	83 e8 01             	sub    $0x1,%eax
8010693f:	89 c2                	mov    %eax,%edx
80106941:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106944:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106948:	83 ec 0c             	sub    $0xc,%esp
8010694b:	ff 75 f0             	pushl  -0x10(%ebp)
8010694e:	e8 47 ae ff ff       	call   8010179a <iupdate>
80106953:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106956:	83 ec 0c             	sub    $0xc,%esp
80106959:	ff 75 f0             	pushl  -0x10(%ebp)
8010695c:	e8 c7 b2 ff ff       	call   80101c28 <iunlockput>
80106961:	83 c4 10             	add    $0x10,%esp

  end_op();
80106964:	e8 3a cc ff ff       	call   801035a3 <end_op>

  return 0;
80106969:	b8 00 00 00 00       	mov    $0x0,%eax
8010696e:	eb 19                	jmp    80106989 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106970:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106971:	83 ec 0c             	sub    $0xc,%esp
80106974:	ff 75 f4             	pushl  -0xc(%ebp)
80106977:	e8 ac b2 ff ff       	call   80101c28 <iunlockput>
8010697c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010697f:	e8 1f cc ff ff       	call   801035a3 <end_op>
  return -1;
80106984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106989:	c9                   	leave  
8010698a:	c3                   	ret    

8010698b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010698b:	55                   	push   %ebp
8010698c:	89 e5                	mov    %esp,%ebp
8010698e:	83 ec 38             	sub    $0x38,%esp
80106991:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106994:	8b 55 10             	mov    0x10(%ebp),%edx
80106997:	8b 45 14             	mov    0x14(%ebp),%eax
8010699a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010699e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801069a2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801069a6:	83 ec 08             	sub    $0x8,%esp
801069a9:	8d 45 de             	lea    -0x22(%ebp),%eax
801069ac:	50                   	push   %eax
801069ad:	ff 75 08             	pushl  0x8(%ebp)
801069b0:	e8 8d bb ff ff       	call   80102542 <nameiparent>
801069b5:	83 c4 10             	add    $0x10,%esp
801069b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069bf:	75 0a                	jne    801069cb <create+0x40>
    return 0;
801069c1:	b8 00 00 00 00       	mov    $0x0,%eax
801069c6:	e9 90 01 00 00       	jmp    80106b5b <create+0x1d0>
  ilock(dp);
801069cb:	83 ec 0c             	sub    $0xc,%esp
801069ce:	ff 75 f4             	pushl  -0xc(%ebp)
801069d1:	e8 98 af ff ff       	call   8010196e <ilock>
801069d6:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801069d9:	83 ec 04             	sub    $0x4,%esp
801069dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069df:	50                   	push   %eax
801069e0:	8d 45 de             	lea    -0x22(%ebp),%eax
801069e3:	50                   	push   %eax
801069e4:	ff 75 f4             	pushl  -0xc(%ebp)
801069e7:	e8 e4 b7 ff ff       	call   801021d0 <dirlookup>
801069ec:	83 c4 10             	add    $0x10,%esp
801069ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069f6:	74 50                	je     80106a48 <create+0xbd>
    iunlockput(dp);
801069f8:	83 ec 0c             	sub    $0xc,%esp
801069fb:	ff 75 f4             	pushl  -0xc(%ebp)
801069fe:	e8 25 b2 ff ff       	call   80101c28 <iunlockput>
80106a03:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106a06:	83 ec 0c             	sub    $0xc,%esp
80106a09:	ff 75 f0             	pushl  -0x10(%ebp)
80106a0c:	e8 5d af ff ff       	call   8010196e <ilock>
80106a11:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106a14:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a19:	75 15                	jne    80106a30 <create+0xa5>
80106a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a1e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a22:	66 83 f8 02          	cmp    $0x2,%ax
80106a26:	75 08                	jne    80106a30 <create+0xa5>
      return ip;
80106a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a2b:	e9 2b 01 00 00       	jmp    80106b5b <create+0x1d0>
    iunlockput(ip);
80106a30:	83 ec 0c             	sub    $0xc,%esp
80106a33:	ff 75 f0             	pushl  -0x10(%ebp)
80106a36:	e8 ed b1 ff ff       	call   80101c28 <iunlockput>
80106a3b:	83 c4 10             	add    $0x10,%esp
    return 0;
80106a3e:	b8 00 00 00 00       	mov    $0x0,%eax
80106a43:	e9 13 01 00 00       	jmp    80106b5b <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106a48:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4f:	8b 00                	mov    (%eax),%eax
80106a51:	83 ec 08             	sub    $0x8,%esp
80106a54:	52                   	push   %edx
80106a55:	50                   	push   %eax
80106a56:	e8 5e ac ff ff       	call   801016b9 <ialloc>
80106a5b:	83 c4 10             	add    $0x10,%esp
80106a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a65:	75 0d                	jne    80106a74 <create+0xe9>
    panic("create: ialloc");
80106a67:	83 ec 0c             	sub    $0xc,%esp
80106a6a:	68 cc 9b 10 80       	push   $0x80109bcc
80106a6f:	e8 f2 9a ff ff       	call   80100566 <panic>

  ilock(ip);
80106a74:	83 ec 0c             	sub    $0xc,%esp
80106a77:	ff 75 f0             	pushl  -0x10(%ebp)
80106a7a:	e8 ef ae ff ff       	call   8010196e <ilock>
80106a7f:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a85:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a89:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a90:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a94:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a9b:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106aa1:	83 ec 0c             	sub    $0xc,%esp
80106aa4:	ff 75 f0             	pushl  -0x10(%ebp)
80106aa7:	e8 ee ac ff ff       	call   8010179a <iupdate>
80106aac:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106aaf:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106ab4:	75 6a                	jne    80106b20 <create+0x195>
    dp->nlink++;  // for ".."
80106ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106abd:	83 c0 01             	add    $0x1,%eax
80106ac0:	89 c2                	mov    %eax,%edx
80106ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac5:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106ac9:	83 ec 0c             	sub    $0xc,%esp
80106acc:	ff 75 f4             	pushl  -0xc(%ebp)
80106acf:	e8 c6 ac ff ff       	call   8010179a <iupdate>
80106ad4:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ada:	8b 40 04             	mov    0x4(%eax),%eax
80106add:	83 ec 04             	sub    $0x4,%esp
80106ae0:	50                   	push   %eax
80106ae1:	68 a6 9b 10 80       	push   $0x80109ba6
80106ae6:	ff 75 f0             	pushl  -0x10(%ebp)
80106ae9:	e8 9c b7 ff ff       	call   8010228a <dirlink>
80106aee:	83 c4 10             	add    $0x10,%esp
80106af1:	85 c0                	test   %eax,%eax
80106af3:	78 1e                	js     80106b13 <create+0x188>
80106af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af8:	8b 40 04             	mov    0x4(%eax),%eax
80106afb:	83 ec 04             	sub    $0x4,%esp
80106afe:	50                   	push   %eax
80106aff:	68 a8 9b 10 80       	push   $0x80109ba8
80106b04:	ff 75 f0             	pushl  -0x10(%ebp)
80106b07:	e8 7e b7 ff ff       	call   8010228a <dirlink>
80106b0c:	83 c4 10             	add    $0x10,%esp
80106b0f:	85 c0                	test   %eax,%eax
80106b11:	79 0d                	jns    80106b20 <create+0x195>
      panic("create dots");
80106b13:	83 ec 0c             	sub    $0xc,%esp
80106b16:	68 db 9b 10 80       	push   $0x80109bdb
80106b1b:	e8 46 9a ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b23:	8b 40 04             	mov    0x4(%eax),%eax
80106b26:	83 ec 04             	sub    $0x4,%esp
80106b29:	50                   	push   %eax
80106b2a:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b2d:	50                   	push   %eax
80106b2e:	ff 75 f4             	pushl  -0xc(%ebp)
80106b31:	e8 54 b7 ff ff       	call   8010228a <dirlink>
80106b36:	83 c4 10             	add    $0x10,%esp
80106b39:	85 c0                	test   %eax,%eax
80106b3b:	79 0d                	jns    80106b4a <create+0x1bf>
    panic("create: dirlink");
80106b3d:	83 ec 0c             	sub    $0xc,%esp
80106b40:	68 e7 9b 10 80       	push   $0x80109be7
80106b45:	e8 1c 9a ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106b4a:	83 ec 0c             	sub    $0xc,%esp
80106b4d:	ff 75 f4             	pushl  -0xc(%ebp)
80106b50:	e8 d3 b0 ff ff       	call   80101c28 <iunlockput>
80106b55:	83 c4 10             	add    $0x10,%esp

  return ip;
80106b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b5b:	c9                   	leave  
80106b5c:	c3                   	ret    

80106b5d <sys_open>:

int
sys_open(void)
{
80106b5d:	55                   	push   %ebp
80106b5e:	89 e5                	mov    %esp,%ebp
80106b60:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b63:	83 ec 08             	sub    $0x8,%esp
80106b66:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b69:	50                   	push   %eax
80106b6a:	6a 00                	push   $0x0
80106b6c:	e8 eb f6 ff ff       	call   8010625c <argstr>
80106b71:	83 c4 10             	add    $0x10,%esp
80106b74:	85 c0                	test   %eax,%eax
80106b76:	78 15                	js     80106b8d <sys_open+0x30>
80106b78:	83 ec 08             	sub    $0x8,%esp
80106b7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b7e:	50                   	push   %eax
80106b7f:	6a 01                	push   $0x1
80106b81:	e8 51 f6 ff ff       	call   801061d7 <argint>
80106b86:	83 c4 10             	add    $0x10,%esp
80106b89:	85 c0                	test   %eax,%eax
80106b8b:	79 0a                	jns    80106b97 <sys_open+0x3a>
    return -1;
80106b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b92:	e9 61 01 00 00       	jmp    80106cf8 <sys_open+0x19b>

  begin_op();
80106b97:	e8 7b c9 ff ff       	call   80103517 <begin_op>

  if(omode & O_CREATE){
80106b9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b9f:	25 00 02 00 00       	and    $0x200,%eax
80106ba4:	85 c0                	test   %eax,%eax
80106ba6:	74 2a                	je     80106bd2 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106ba8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bab:	6a 00                	push   $0x0
80106bad:	6a 00                	push   $0x0
80106baf:	6a 02                	push   $0x2
80106bb1:	50                   	push   %eax
80106bb2:	e8 d4 fd ff ff       	call   8010698b <create>
80106bb7:	83 c4 10             	add    $0x10,%esp
80106bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106bbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bc1:	75 75                	jne    80106c38 <sys_open+0xdb>
      end_op();
80106bc3:	e8 db c9 ff ff       	call   801035a3 <end_op>
      return -1;
80106bc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bcd:	e9 26 01 00 00       	jmp    80106cf8 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106bd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bd5:	83 ec 0c             	sub    $0xc,%esp
80106bd8:	50                   	push   %eax
80106bd9:	e8 48 b9 ff ff       	call   80102526 <namei>
80106bde:	83 c4 10             	add    $0x10,%esp
80106be1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106be4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106be8:	75 0f                	jne    80106bf9 <sys_open+0x9c>
      end_op();
80106bea:	e8 b4 c9 ff ff       	call   801035a3 <end_op>
      return -1;
80106bef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf4:	e9 ff 00 00 00       	jmp    80106cf8 <sys_open+0x19b>
    }
    ilock(ip);
80106bf9:	83 ec 0c             	sub    $0xc,%esp
80106bfc:	ff 75 f4             	pushl  -0xc(%ebp)
80106bff:	e8 6a ad ff ff       	call   8010196e <ilock>
80106c04:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c0e:	66 83 f8 01          	cmp    $0x1,%ax
80106c12:	75 24                	jne    80106c38 <sys_open+0xdb>
80106c14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c17:	85 c0                	test   %eax,%eax
80106c19:	74 1d                	je     80106c38 <sys_open+0xdb>
      iunlockput(ip);
80106c1b:	83 ec 0c             	sub    $0xc,%esp
80106c1e:	ff 75 f4             	pushl  -0xc(%ebp)
80106c21:	e8 02 b0 ff ff       	call   80101c28 <iunlockput>
80106c26:	83 c4 10             	add    $0x10,%esp
      end_op();
80106c29:	e8 75 c9 ff ff       	call   801035a3 <end_op>
      return -1;
80106c2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c33:	e9 c0 00 00 00       	jmp    80106cf8 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106c38:	e8 43 a3 ff ff       	call   80100f80 <filealloc>
80106c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c44:	74 17                	je     80106c5d <sys_open+0x100>
80106c46:	83 ec 0c             	sub    $0xc,%esp
80106c49:	ff 75 f0             	pushl  -0x10(%ebp)
80106c4c:	e8 37 f7 ff ff       	call   80106388 <fdalloc>
80106c51:	83 c4 10             	add    $0x10,%esp
80106c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106c57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106c5b:	79 2e                	jns    80106c8b <sys_open+0x12e>
    if(f)
80106c5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c61:	74 0e                	je     80106c71 <sys_open+0x114>
      fileclose(f);
80106c63:	83 ec 0c             	sub    $0xc,%esp
80106c66:	ff 75 f0             	pushl  -0x10(%ebp)
80106c69:	e8 d0 a3 ff ff       	call   8010103e <fileclose>
80106c6e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106c71:	83 ec 0c             	sub    $0xc,%esp
80106c74:	ff 75 f4             	pushl  -0xc(%ebp)
80106c77:	e8 ac af ff ff       	call   80101c28 <iunlockput>
80106c7c:	83 c4 10             	add    $0x10,%esp
    end_op();
80106c7f:	e8 1f c9 ff ff       	call   801035a3 <end_op>
    return -1;
80106c84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c89:	eb 6d                	jmp    80106cf8 <sys_open+0x19b>
  }
  iunlock(ip);
80106c8b:	83 ec 0c             	sub    $0xc,%esp
80106c8e:	ff 75 f4             	pushl  -0xc(%ebp)
80106c91:	e8 30 ae ff ff       	call   80101ac6 <iunlock>
80106c96:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c99:	e8 05 c9 ff ff       	call   801035a3 <end_op>

  f->type = FD_INODE;
80106c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ca1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106caa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106cad:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cb3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106cba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106cbd:	83 e0 01             	and    $0x1,%eax
80106cc0:	85 c0                	test   %eax,%eax
80106cc2:	0f 94 c0             	sete   %al
80106cc5:	89 c2                	mov    %eax,%edx
80106cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cca:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106cd0:	83 e0 01             	and    $0x1,%eax
80106cd3:	85 c0                	test   %eax,%eax
80106cd5:	75 0a                	jne    80106ce1 <sys_open+0x184>
80106cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106cda:	83 e0 02             	and    $0x2,%eax
80106cdd:	85 c0                	test   %eax,%eax
80106cdf:	74 07                	je     80106ce8 <sys_open+0x18b>
80106ce1:	b8 01 00 00 00       	mov    $0x1,%eax
80106ce6:	eb 05                	jmp    80106ced <sys_open+0x190>
80106ce8:	b8 00 00 00 00       	mov    $0x0,%eax
80106ced:	89 c2                	mov    %eax,%edx
80106cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cf2:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106cf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106cf8:	c9                   	leave  
80106cf9:	c3                   	ret    

80106cfa <sys_mkdir>:

int
sys_mkdir(void)
{
80106cfa:	55                   	push   %ebp
80106cfb:	89 e5                	mov    %esp,%ebp
80106cfd:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106d00:	e8 12 c8 ff ff       	call   80103517 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106d05:	83 ec 08             	sub    $0x8,%esp
80106d08:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d0b:	50                   	push   %eax
80106d0c:	6a 00                	push   $0x0
80106d0e:	e8 49 f5 ff ff       	call   8010625c <argstr>
80106d13:	83 c4 10             	add    $0x10,%esp
80106d16:	85 c0                	test   %eax,%eax
80106d18:	78 1b                	js     80106d35 <sys_mkdir+0x3b>
80106d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d1d:	6a 00                	push   $0x0
80106d1f:	6a 00                	push   $0x0
80106d21:	6a 01                	push   $0x1
80106d23:	50                   	push   %eax
80106d24:	e8 62 fc ff ff       	call   8010698b <create>
80106d29:	83 c4 10             	add    $0x10,%esp
80106d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d33:	75 0c                	jne    80106d41 <sys_mkdir+0x47>
    end_op();
80106d35:	e8 69 c8 ff ff       	call   801035a3 <end_op>
    return -1;
80106d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d3f:	eb 18                	jmp    80106d59 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106d41:	83 ec 0c             	sub    $0xc,%esp
80106d44:	ff 75 f4             	pushl  -0xc(%ebp)
80106d47:	e8 dc ae ff ff       	call   80101c28 <iunlockput>
80106d4c:	83 c4 10             	add    $0x10,%esp
  end_op();
80106d4f:	e8 4f c8 ff ff       	call   801035a3 <end_op>
  return 0;
80106d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d59:	c9                   	leave  
80106d5a:	c3                   	ret    

80106d5b <sys_mknod>:

int
sys_mknod(void)
{
80106d5b:	55                   	push   %ebp
80106d5c:	89 e5                	mov    %esp,%ebp
80106d5e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;

  begin_op();
80106d61:	e8 b1 c7 ff ff       	call   80103517 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106d66:	83 ec 08             	sub    $0x8,%esp
80106d69:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106d6c:	50                   	push   %eax
80106d6d:	6a 00                	push   $0x0
80106d6f:	e8 e8 f4 ff ff       	call   8010625c <argstr>
80106d74:	83 c4 10             	add    $0x10,%esp
80106d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d7e:	78 4f                	js     80106dcf <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106d80:	83 ec 08             	sub    $0x8,%esp
80106d83:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d86:	50                   	push   %eax
80106d87:	6a 01                	push   $0x1
80106d89:	e8 49 f4 ff ff       	call   801061d7 <argint>
80106d8e:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106d91:	85 c0                	test   %eax,%eax
80106d93:	78 3a                	js     80106dcf <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106d95:	83 ec 08             	sub    $0x8,%esp
80106d98:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d9b:	50                   	push   %eax
80106d9c:	6a 02                	push   $0x2
80106d9e:	e8 34 f4 ff ff       	call   801061d7 <argint>
80106da3:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106da6:	85 c0                	test   %eax,%eax
80106da8:	78 25                	js     80106dcf <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dad:	0f bf c8             	movswl %ax,%ecx
80106db0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106db3:	0f bf d0             	movswl %ax,%edx
80106db6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;

  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106db9:	51                   	push   %ecx
80106dba:	52                   	push   %edx
80106dbb:	6a 03                	push   $0x3
80106dbd:	50                   	push   %eax
80106dbe:	e8 c8 fb ff ff       	call   8010698b <create>
80106dc3:	83 c4 10             	add    $0x10,%esp
80106dc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106dc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106dcd:	75 0c                	jne    80106ddb <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106dcf:	e8 cf c7 ff ff       	call   801035a3 <end_op>
    return -1;
80106dd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd9:	eb 18                	jmp    80106df3 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106ddb:	83 ec 0c             	sub    $0xc,%esp
80106dde:	ff 75 f0             	pushl  -0x10(%ebp)
80106de1:	e8 42 ae ff ff       	call   80101c28 <iunlockput>
80106de6:	83 c4 10             	add    $0x10,%esp
  end_op();
80106de9:	e8 b5 c7 ff ff       	call   801035a3 <end_op>
  return 0;
80106dee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106df3:	c9                   	leave  
80106df4:	c3                   	ret    

80106df5 <sys_chdir>:

int
sys_chdir(void)
{
80106df5:	55                   	push   %ebp
80106df6:	89 e5                	mov    %esp,%ebp
80106df8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106dfb:	e8 17 c7 ff ff       	call   80103517 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106e00:	83 ec 08             	sub    $0x8,%esp
80106e03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e06:	50                   	push   %eax
80106e07:	6a 00                	push   $0x0
80106e09:	e8 4e f4 ff ff       	call   8010625c <argstr>
80106e0e:	83 c4 10             	add    $0x10,%esp
80106e11:	85 c0                	test   %eax,%eax
80106e13:	78 18                	js     80106e2d <sys_chdir+0x38>
80106e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e18:	83 ec 0c             	sub    $0xc,%esp
80106e1b:	50                   	push   %eax
80106e1c:	e8 05 b7 ff ff       	call   80102526 <namei>
80106e21:	83 c4 10             	add    $0x10,%esp
80106e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e2b:	75 0c                	jne    80106e39 <sys_chdir+0x44>
    end_op();
80106e2d:	e8 71 c7 ff ff       	call   801035a3 <end_op>
    return -1;
80106e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e37:	eb 6e                	jmp    80106ea7 <sys_chdir+0xb2>
  }
  ilock(ip);
80106e39:	83 ec 0c             	sub    $0xc,%esp
80106e3c:	ff 75 f4             	pushl  -0xc(%ebp)
80106e3f:	e8 2a ab ff ff       	call   8010196e <ilock>
80106e44:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e4a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106e4e:	66 83 f8 01          	cmp    $0x1,%ax
80106e52:	74 1a                	je     80106e6e <sys_chdir+0x79>
    iunlockput(ip);
80106e54:	83 ec 0c             	sub    $0xc,%esp
80106e57:	ff 75 f4             	pushl  -0xc(%ebp)
80106e5a:	e8 c9 ad ff ff       	call   80101c28 <iunlockput>
80106e5f:	83 c4 10             	add    $0x10,%esp
    end_op();
80106e62:	e8 3c c7 ff ff       	call   801035a3 <end_op>
    return -1;
80106e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e6c:	eb 39                	jmp    80106ea7 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106e6e:	83 ec 0c             	sub    $0xc,%esp
80106e71:	ff 75 f4             	pushl  -0xc(%ebp)
80106e74:	e8 4d ac ff ff       	call   80101ac6 <iunlock>
80106e79:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106e7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e82:	8b 40 68             	mov    0x68(%eax),%eax
80106e85:	83 ec 0c             	sub    $0xc,%esp
80106e88:	50                   	push   %eax
80106e89:	e8 aa ac ff ff       	call   80101b38 <iput>
80106e8e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e91:	e8 0d c7 ff ff       	call   801035a3 <end_op>
  proc->cwd = ip;
80106e96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106e9f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106ea2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ea7:	c9                   	leave  
80106ea8:	c3                   	ret    

80106ea9 <sys_exec>:

int
sys_exec(void)
{
80106ea9:	55                   	push   %ebp
80106eaa:	89 e5                	mov    %esp,%ebp
80106eac:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106eb2:	83 ec 08             	sub    $0x8,%esp
80106eb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106eb8:	50                   	push   %eax
80106eb9:	6a 00                	push   $0x0
80106ebb:	e8 9c f3 ff ff       	call   8010625c <argstr>
80106ec0:	83 c4 10             	add    $0x10,%esp
80106ec3:	85 c0                	test   %eax,%eax
80106ec5:	78 18                	js     80106edf <sys_exec+0x36>
80106ec7:	83 ec 08             	sub    $0x8,%esp
80106eca:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106ed0:	50                   	push   %eax
80106ed1:	6a 01                	push   $0x1
80106ed3:	e8 ff f2 ff ff       	call   801061d7 <argint>
80106ed8:	83 c4 10             	add    $0x10,%esp
80106edb:	85 c0                	test   %eax,%eax
80106edd:	79 0a                	jns    80106ee9 <sys_exec+0x40>
    return -1;
80106edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ee4:	e9 c6 00 00 00       	jmp    80106faf <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106ee9:	83 ec 04             	sub    $0x4,%esp
80106eec:	68 80 00 00 00       	push   $0x80
80106ef1:	6a 00                	push   $0x0
80106ef3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ef9:	50                   	push   %eax
80106efa:	e8 b3 ef ff ff       	call   80105eb2 <memset>
80106eff:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106f02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0c:	83 f8 1f             	cmp    $0x1f,%eax
80106f0f:	76 0a                	jbe    80106f1b <sys_exec+0x72>
      return -1;
80106f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f16:	e9 94 00 00 00       	jmp    80106faf <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1e:	c1 e0 02             	shl    $0x2,%eax
80106f21:	89 c2                	mov    %eax,%edx
80106f23:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106f29:	01 c2                	add    %eax,%edx
80106f2b:	83 ec 08             	sub    $0x8,%esp
80106f2e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106f34:	50                   	push   %eax
80106f35:	52                   	push   %edx
80106f36:	e8 00 f2 ff ff       	call   8010613b <fetchint>
80106f3b:	83 c4 10             	add    $0x10,%esp
80106f3e:	85 c0                	test   %eax,%eax
80106f40:	79 07                	jns    80106f49 <sys_exec+0xa0>
      return -1;
80106f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f47:	eb 66                	jmp    80106faf <sys_exec+0x106>
    if(uarg == 0){
80106f49:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f4f:	85 c0                	test   %eax,%eax
80106f51:	75 27                	jne    80106f7a <sys_exec+0xd1>
      argv[i] = 0;
80106f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f56:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106f5d:	00 00 00 00 
      break;
80106f61:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f65:	83 ec 08             	sub    $0x8,%esp
80106f68:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f6e:	52                   	push   %edx
80106f6f:	50                   	push   %eax
80106f70:	e8 e1 9b ff ff       	call   80100b56 <exec>
80106f75:	83 c4 10             	add    $0x10,%esp
80106f78:	eb 35                	jmp    80106faf <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f7a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f83:	c1 e2 02             	shl    $0x2,%edx
80106f86:	01 c2                	add    %eax,%edx
80106f88:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f8e:	83 ec 08             	sub    $0x8,%esp
80106f91:	52                   	push   %edx
80106f92:	50                   	push   %eax
80106f93:	e8 dd f1 ff ff       	call   80106175 <fetchstr>
80106f98:	83 c4 10             	add    $0x10,%esp
80106f9b:	85 c0                	test   %eax,%eax
80106f9d:	79 07                	jns    80106fa6 <sys_exec+0xfd>
      return -1;
80106f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa4:	eb 09                	jmp    80106faf <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106fa6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106faa:	e9 5a ff ff ff       	jmp    80106f09 <sys_exec+0x60>
  return exec(path, argv);
}
80106faf:	c9                   	leave  
80106fb0:	c3                   	ret    

80106fb1 <sys_pipe>:

int
sys_pipe(void)
{
80106fb1:	55                   	push   %ebp
80106fb2:	89 e5                	mov    %esp,%ebp
80106fb4:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106fb7:	83 ec 04             	sub    $0x4,%esp
80106fba:	6a 08                	push   $0x8
80106fbc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106fbf:	50                   	push   %eax
80106fc0:	6a 00                	push   $0x0
80106fc2:	e8 38 f2 ff ff       	call   801061ff <argptr>
80106fc7:	83 c4 10             	add    $0x10,%esp
80106fca:	85 c0                	test   %eax,%eax
80106fcc:	79 0a                	jns    80106fd8 <sys_pipe+0x27>
    return -1;
80106fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fd3:	e9 af 00 00 00       	jmp    80107087 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106fd8:	83 ec 08             	sub    $0x8,%esp
80106fdb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106fde:	50                   	push   %eax
80106fdf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106fe2:	50                   	push   %eax
80106fe3:	e8 d6 d2 ff ff       	call   801042be <pipealloc>
80106fe8:	83 c4 10             	add    $0x10,%esp
80106feb:	85 c0                	test   %eax,%eax
80106fed:	79 0a                	jns    80106ff9 <sys_pipe+0x48>
    return -1;
80106fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff4:	e9 8e 00 00 00       	jmp    80107087 <sys_pipe+0xd6>
  fd0 = -1;
80106ff9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107000:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107003:	83 ec 0c             	sub    $0xc,%esp
80107006:	50                   	push   %eax
80107007:	e8 7c f3 ff ff       	call   80106388 <fdalloc>
8010700c:	83 c4 10             	add    $0x10,%esp
8010700f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107012:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107016:	78 18                	js     80107030 <sys_pipe+0x7f>
80107018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010701b:	83 ec 0c             	sub    $0xc,%esp
8010701e:	50                   	push   %eax
8010701f:	e8 64 f3 ff ff       	call   80106388 <fdalloc>
80107024:	83 c4 10             	add    $0x10,%esp
80107027:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010702a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010702e:	79 3f                	jns    8010706f <sys_pipe+0xbe>
    if(fd0 >= 0)
80107030:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107034:	78 14                	js     8010704a <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107036:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010703c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010703f:	83 c2 08             	add    $0x8,%edx
80107042:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107049:	00 
    fileclose(rf);
8010704a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010704d:	83 ec 0c             	sub    $0xc,%esp
80107050:	50                   	push   %eax
80107051:	e8 e8 9f ff ff       	call   8010103e <fileclose>
80107056:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010705c:	83 ec 0c             	sub    $0xc,%esp
8010705f:	50                   	push   %eax
80107060:	e8 d9 9f ff ff       	call   8010103e <fileclose>
80107065:	83 c4 10             	add    $0x10,%esp
    return -1;
80107068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010706d:	eb 18                	jmp    80107087 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
8010706f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107072:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107075:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107077:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010707a:	8d 50 04             	lea    0x4(%eax),%edx
8010707d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107080:	89 02                	mov    %eax,(%edx)
  return 0;
80107082:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107087:	c9                   	leave  
80107088:	c3                   	ret    

80107089 <sys_seek>:


int
sys_seek(void)
{
80107089:	55                   	push   %ebp
8010708a:	89 e5                	mov    %esp,%ebp
8010708c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;

  if(argfd(0, 0, &f) < 0 || argint(1, &n) < 0 )
8010708f:	83 ec 04             	sub    $0x4,%esp
80107092:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107095:	50                   	push   %eax
80107096:	6a 00                	push   $0x0
80107098:	6a 00                	push   $0x0
8010709a:	e8 74 f2 ff ff       	call   80106313 <argfd>
8010709f:	83 c4 10             	add    $0x10,%esp
801070a2:	85 c0                	test   %eax,%eax
801070a4:	78 15                	js     801070bb <sys_seek+0x32>
801070a6:	83 ec 08             	sub    $0x8,%esp
801070a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070ac:	50                   	push   %eax
801070ad:	6a 01                	push   $0x1
801070af:	e8 23 f1 ff ff       	call   801061d7 <argint>
801070b4:	83 c4 10             	add    $0x10,%esp
801070b7:	85 c0                	test   %eax,%eax
801070b9:	79 07                	jns    801070c2 <sys_seek+0x39>
    return -1;
801070bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070c0:	eb 15                	jmp    801070d7 <sys_seek+0x4e>
  return fileseek(f, n);
801070c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070c5:	89 c2                	mov    %eax,%edx
801070c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ca:	83 ec 08             	sub    $0x8,%esp
801070cd:	52                   	push   %edx
801070ce:	50                   	push   %eax
801070cf:	e8 9d a2 ff ff       	call   80101371 <fileseek>
801070d4:	83 c4 10             	add    $0x10,%esp
}
801070d7:	c9                   	leave  
801070d8:	c3                   	ret    

801070d9 <sys_fork>:
#include "mmap.h"
#include "proc.h"

int
sys_fork(void)
{
801070d9:	55                   	push   %ebp
801070da:	89 e5                	mov    %esp,%ebp
801070dc:	83 ec 08             	sub    $0x8,%esp
  return fork();
801070df:	e8 78 db ff ff       	call   80104c5c <fork>
}
801070e4:	c9                   	leave  
801070e5:	c3                   	ret    

801070e6 <sys_exit>:

int
sys_exit(void)
{
801070e6:	55                   	push   %ebp
801070e7:	89 e5                	mov    %esp,%ebp
801070e9:	83 ec 08             	sub    $0x8,%esp
  exit();
801070ec:	e8 41 de ff ff       	call   80104f32 <exit>
  return 0;  // not reached
801070f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070f6:	c9                   	leave  
801070f7:	c3                   	ret    

801070f8 <sys_wait>:

int
sys_wait(void)
{
801070f8:	55                   	push   %ebp
801070f9:	89 e5                	mov    %esp,%ebp
801070fb:	83 ec 08             	sub    $0x8,%esp
  return wait();
801070fe:	e8 5b e0 ff ff       	call   8010515e <wait>
}
80107103:	c9                   	leave  
80107104:	c3                   	ret    

80107105 <sys_kill>:

int
sys_kill(void)
{
80107105:	55                   	push   %ebp
80107106:	89 e5                	mov    %esp,%ebp
80107108:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010710b:	83 ec 08             	sub    $0x8,%esp
8010710e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107111:	50                   	push   %eax
80107112:	6a 00                	push   $0x0
80107114:	e8 be f0 ff ff       	call   801061d7 <argint>
80107119:	83 c4 10             	add    $0x10,%esp
8010711c:	85 c0                	test   %eax,%eax
8010711e:	79 07                	jns    80107127 <sys_kill+0x22>
    return -1;
80107120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107125:	eb 0f                	jmp    80107136 <sys_kill+0x31>
  return kill(pid);
80107127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712a:	83 ec 0c             	sub    $0xc,%esp
8010712d:	50                   	push   %eax
8010712e:	e8 a3 e4 ff ff       	call   801055d6 <kill>
80107133:	83 c4 10             	add    $0x10,%esp
}
80107136:	c9                   	leave  
80107137:	c3                   	ret    

80107138 <sys_getpid>:

int
sys_getpid(void)
{
80107138:	55                   	push   %ebp
80107139:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010713b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107141:	8b 40 10             	mov    0x10(%eax),%eax
}
80107144:	5d                   	pop    %ebp
80107145:	c3                   	ret    

80107146 <sys_sbrk>:

int
sys_sbrk(void)
{
80107146:	55                   	push   %ebp
80107147:	89 e5                	mov    %esp,%ebp
80107149:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010714c:	83 ec 08             	sub    $0x8,%esp
8010714f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107152:	50                   	push   %eax
80107153:	6a 00                	push   $0x0
80107155:	e8 7d f0 ff ff       	call   801061d7 <argint>
8010715a:	83 c4 10             	add    $0x10,%esp
8010715d:	85 c0                	test   %eax,%eax
8010715f:	79 07                	jns    80107168 <sys_sbrk+0x22>
    return -1;
80107161:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107166:	eb 28                	jmp    80107190 <sys_sbrk+0x4a>
  addr = proc->sz;
80107168:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010716e:	8b 00                	mov    (%eax),%eax
80107170:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107176:	83 ec 0c             	sub    $0xc,%esp
80107179:	50                   	push   %eax
8010717a:	e8 3a da ff ff       	call   80104bb9 <growproc>
8010717f:	83 c4 10             	add    $0x10,%esp
80107182:	85 c0                	test   %eax,%eax
80107184:	79 07                	jns    8010718d <sys_sbrk+0x47>
    return -1;
80107186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010718b:	eb 03                	jmp    80107190 <sys_sbrk+0x4a>
  return addr;
8010718d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107190:	c9                   	leave  
80107191:	c3                   	ret    

80107192 <sys_sleep>:

int
sys_sleep(void)
{
80107192:	55                   	push   %ebp
80107193:	89 e5                	mov    %esp,%ebp
80107195:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107198:	83 ec 08             	sub    $0x8,%esp
8010719b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010719e:	50                   	push   %eax
8010719f:	6a 00                	push   $0x0
801071a1:	e8 31 f0 ff ff       	call   801061d7 <argint>
801071a6:	83 c4 10             	add    $0x10,%esp
801071a9:	85 c0                	test   %eax,%eax
801071ab:	79 07                	jns    801071b4 <sys_sleep+0x22>
    return -1;
801071ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071b2:	eb 77                	jmp    8010722b <sys_sleep+0x99>
  acquire(&tickslock);
801071b4:	83 ec 0c             	sub    $0xc,%esp
801071b7:	68 20 74 11 80       	push   $0x80117420
801071bc:	e8 8e ea ff ff       	call   80105c4f <acquire>
801071c1:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801071c4:	a1 60 7c 11 80       	mov    0x80117c60,%eax
801071c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801071cc:	eb 39                	jmp    80107207 <sys_sleep+0x75>
    if(proc->killed){
801071ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071d4:	8b 40 24             	mov    0x24(%eax),%eax
801071d7:	85 c0                	test   %eax,%eax
801071d9:	74 17                	je     801071f2 <sys_sleep+0x60>
      release(&tickslock);
801071db:	83 ec 0c             	sub    $0xc,%esp
801071de:	68 20 74 11 80       	push   $0x80117420
801071e3:	e8 ce ea ff ff       	call   80105cb6 <release>
801071e8:	83 c4 10             	add    $0x10,%esp
      return -1;
801071eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071f0:	eb 39                	jmp    8010722b <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801071f2:	83 ec 08             	sub    $0x8,%esp
801071f5:	68 20 74 11 80       	push   $0x80117420
801071fa:	68 60 7c 11 80       	push   $0x80117c60
801071ff:	e8 8f e2 ff ff       	call   80105493 <sleep>
80107204:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107207:	a1 60 7c 11 80       	mov    0x80117c60,%eax
8010720c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010720f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107212:	39 d0                	cmp    %edx,%eax
80107214:	72 b8                	jb     801071ce <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107216:	83 ec 0c             	sub    $0xc,%esp
80107219:	68 20 74 11 80       	push   $0x80117420
8010721e:	e8 93 ea ff ff       	call   80105cb6 <release>
80107223:	83 c4 10             	add    $0x10,%esp
  return 0;
80107226:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010722b:	c9                   	leave  
8010722c:	c3                   	ret    

8010722d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010722d:	55                   	push   %ebp
8010722e:	89 e5                	mov    %esp,%ebp
80107230:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80107233:	83 ec 0c             	sub    $0xc,%esp
80107236:	68 20 74 11 80       	push   $0x80117420
8010723b:	e8 0f ea ff ff       	call   80105c4f <acquire>
80107240:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107243:	a1 60 7c 11 80       	mov    0x80117c60,%eax
80107248:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010724b:	83 ec 0c             	sub    $0xc,%esp
8010724e:	68 20 74 11 80       	push   $0x80117420
80107253:	e8 5e ea ff ff       	call   80105cb6 <release>
80107258:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010725e:	c9                   	leave  
8010725f:	c3                   	ret    

80107260 <sys_procstat>:

// List the existing processes in the system and their status.
int
sys_procstat(void)
{
80107260:	55                   	push   %ebp
80107261:	89 e5                	mov    %esp,%ebp
80107263:	83 ec 08             	sub    $0x8,%esp
  cprintf("sys_procstat\n");
80107266:	83 ec 0c             	sub    $0xc,%esp
80107269:	68 f7 9b 10 80       	push   $0x80109bf7
8010726e:	e8 53 91 ff ff       	call   801003c6 <cprintf>
80107273:	83 c4 10             	add    $0x10,%esp
  procdump();  // call function defined in proc.c
80107276:	e8 e6 e3 ff ff       	call   80105661 <procdump>
  return 0;
8010727b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107280:	c9                   	leave  
80107281:	c3                   	ret    

80107282 <sys_setpriority>:

// Set the priority to a process.
int
sys_setpriority(void)
{
80107282:	55                   	push   %ebp
80107283:	89 e5                	mov    %esp,%ebp
80107285:	83 ec 18             	sub    $0x18,%esp
  int level;
  //cprintf("sys_setpriority\n");
  if(argint(0, &level)<0)
80107288:	83 ec 08             	sub    $0x8,%esp
8010728b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010728e:	50                   	push   %eax
8010728f:	6a 00                	push   $0x0
80107291:	e8 41 ef ff ff       	call   801061d7 <argint>
80107296:	83 c4 10             	add    $0x10,%esp
80107299:	85 c0                	test   %eax,%eax
8010729b:	79 07                	jns    801072a4 <sys_setpriority+0x22>
    return -1;
8010729d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072a2:	eb 12                	jmp    801072b6 <sys_setpriority+0x34>
  proc->priority=level;
801072a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072ad:	66 89 50 7e          	mov    %dx,0x7e(%eax)
  return 0;
801072b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072b6:	c9                   	leave  
801072b7:	c3                   	ret    

801072b8 <sys_semget>:


int
sys_semget(void)
{
801072b8:	55                   	push   %ebp
801072b9:	89 e5                	mov    %esp,%ebp
801072bb:	83 ec 18             	sub    $0x18,%esp
  int id, value;
  if(argint(0, &id)<0)
801072be:	83 ec 08             	sub    $0x8,%esp
801072c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072c4:	50                   	push   %eax
801072c5:	6a 00                	push   $0x0
801072c7:	e8 0b ef ff ff       	call   801061d7 <argint>
801072cc:	83 c4 10             	add    $0x10,%esp
801072cf:	85 c0                	test   %eax,%eax
801072d1:	79 07                	jns    801072da <sys_semget+0x22>
    return -1;
801072d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072d8:	eb 2f                	jmp    80107309 <sys_semget+0x51>
  if(argint(1, &value)<0)
801072da:	83 ec 08             	sub    $0x8,%esp
801072dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072e0:	50                   	push   %eax
801072e1:	6a 01                	push   $0x1
801072e3:	e8 ef ee ff ff       	call   801061d7 <argint>
801072e8:	83 c4 10             	add    $0x10,%esp
801072eb:	85 c0                	test   %eax,%eax
801072ed:	79 07                	jns    801072f6 <sys_semget+0x3e>
    return -1;
801072ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072f4:	eb 13                	jmp    80107309 <sys_semget+0x51>
  return semget(id,value);
801072f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801072f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fc:	83 ec 08             	sub    $0x8,%esp
801072ff:	52                   	push   %edx
80107300:	50                   	push   %eax
80107301:	e8 64 e5 ff ff       	call   8010586a <semget>
80107306:	83 c4 10             	add    $0x10,%esp
}
80107309:	c9                   	leave  
8010730a:	c3                   	ret    

8010730b <sys_semfree>:


int
sys_semfree(void)
{
8010730b:	55                   	push   %ebp
8010730c:	89 e5                	mov    %esp,%ebp
8010730e:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107311:	83 ec 08             	sub    $0x8,%esp
80107314:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107317:	50                   	push   %eax
80107318:	6a 00                	push   $0x0
8010731a:	e8 b8 ee ff ff       	call   801061d7 <argint>
8010731f:	83 c4 10             	add    $0x10,%esp
80107322:	85 c0                	test   %eax,%eax
80107324:	79 07                	jns    8010732d <sys_semfree+0x22>
    return -1;
80107326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010732b:	eb 0f                	jmp    8010733c <sys_semfree+0x31>
  return semfree(id);
8010732d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107330:	83 ec 0c             	sub    $0xc,%esp
80107333:	50                   	push   %eax
80107334:	e8 63 e6 ff ff       	call   8010599c <semfree>
80107339:	83 c4 10             	add    $0x10,%esp
}
8010733c:	c9                   	leave  
8010733d:	c3                   	ret    

8010733e <sys_semdown>:


int
sys_semdown(void)
{
8010733e:	55                   	push   %ebp
8010733f:	89 e5                	mov    %esp,%ebp
80107341:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107344:	83 ec 08             	sub    $0x8,%esp
80107347:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010734a:	50                   	push   %eax
8010734b:	6a 00                	push   $0x0
8010734d:	e8 85 ee ff ff       	call   801061d7 <argint>
80107352:	83 c4 10             	add    $0x10,%esp
80107355:	85 c0                	test   %eax,%eax
80107357:	79 07                	jns    80107360 <sys_semdown+0x22>
    return -1;
80107359:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010735e:	eb 0f                	jmp    8010736f <sys_semdown+0x31>
  return semdown(id);
80107360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107363:	83 ec 0c             	sub    $0xc,%esp
80107366:	50                   	push   %eax
80107367:	e8 cb e6 ff ff       	call   80105a37 <semdown>
8010736c:	83 c4 10             	add    $0x10,%esp
}
8010736f:	c9                   	leave  
80107370:	c3                   	ret    

80107371 <sys_semup>:


int
sys_semup(void)
{
80107371:	55                   	push   %ebp
80107372:	89 e5                	mov    %esp,%ebp
80107374:	83 ec 18             	sub    $0x18,%esp
  int id;
  if(argint(0, &id)<0)
80107377:	83 ec 08             	sub    $0x8,%esp
8010737a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010737d:	50                   	push   %eax
8010737e:	6a 00                	push   $0x0
80107380:	e8 52 ee ff ff       	call   801061d7 <argint>
80107385:	83 c4 10             	add    $0x10,%esp
80107388:	85 c0                	test   %eax,%eax
8010738a:	79 07                	jns    80107393 <sys_semup+0x22>
    return -1;
8010738c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107391:	eb 0f                	jmp    801073a2 <sys_semup+0x31>
  return semup(id);
80107393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107396:	83 ec 0c             	sub    $0xc,%esp
80107399:	50                   	push   %eax
8010739a:	e8 2b e7 ff ff       	call   80105aca <semup>
8010739f:	83 c4 10             	add    $0x10,%esp
}
801073a2:	c9                   	leave  
801073a3:	c3                   	ret    

801073a4 <sys_mmap>:

int
sys_mmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
801073a4:	55                   	push   %ebp
801073a5:	89 e5                	mov    %esp,%ebp
801073a7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int addr;

  if(argint(0, &fd)<0 || argint(1,&addr)<0){ //PREGUNTAR
801073aa:	83 ec 08             	sub    $0x8,%esp
801073ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073b0:	50                   	push   %eax
801073b1:	6a 00                	push   $0x0
801073b3:	e8 1f ee ff ff       	call   801061d7 <argint>
801073b8:	83 c4 10             	add    $0x10,%esp
801073bb:	85 c0                	test   %eax,%eax
801073bd:	78 15                	js     801073d4 <sys_mmap+0x30>
801073bf:	83 ec 08             	sub    $0x8,%esp
801073c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073c5:	50                   	push   %eax
801073c6:	6a 01                	push   $0x1
801073c8:	e8 0a ee ff ff       	call   801061d7 <argint>
801073cd:	83 c4 10             	add    $0x10,%esp
801073d0:	85 c0                	test   %eax,%eax
801073d2:	79 07                	jns    801073db <sys_mmap+0x37>
    return -1;
801073d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d9:	eb 15                	jmp    801073f0 <sys_mmap+0x4c>
  }
  //cprintf("%x",addr);
  return mmap(fd,(char**)addr);
801073db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073de:	89 c2                	mov    %eax,%edx
801073e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e3:	83 ec 08             	sub    $0x8,%esp
801073e6:	52                   	push   %edx
801073e7:	50                   	push   %eax
801073e8:	e8 84 c6 ff ff       	call   80103a71 <mmap>
801073ed:	83 c4 10             	add    $0x10,%esp
}
801073f0:	c9                   	leave  
801073f1:	c3                   	ret    

801073f2 <sys_munmap>:

int
sys_munmap(void)
{                                                     //(2,&addr,sizeof(addr))<0
801073f2:	55                   	push   %ebp
801073f3:	89 e5                	mov    %esp,%ebp
801073f5:	83 ec 18             	sub    $0x18,%esp
  int addr;

  if(argint(0,&addr)<0){ //PREGUNTAR
801073f8:	83 ec 08             	sub    $0x8,%esp
801073fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073fe:	50                   	push   %eax
801073ff:	6a 00                	push   $0x0
80107401:	e8 d1 ed ff ff       	call   801061d7 <argint>
80107406:	83 c4 10             	add    $0x10,%esp
80107409:	85 c0                	test   %eax,%eax
8010740b:	79 07                	jns    80107414 <sys_munmap+0x22>
    return -1;
8010740d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107412:	eb 0f                	jmp    80107423 <sys_munmap+0x31>
  }

  return munmap((char*)addr);
80107414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107417:	83 ec 0c             	sub    $0xc,%esp
8010741a:	50                   	push   %eax
8010741b:	e8 9b c7 ff ff       	call   80103bbb <munmap>
80107420:	83 c4 10             	add    $0x10,%esp
}
80107423:	c9                   	leave  
80107424:	c3                   	ret    

80107425 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107425:	55                   	push   %ebp
80107426:	89 e5                	mov    %esp,%ebp
80107428:	83 ec 08             	sub    $0x8,%esp
8010742b:	8b 55 08             	mov    0x8(%ebp),%edx
8010742e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107431:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107435:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107438:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010743c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107440:	ee                   	out    %al,(%dx)
}
80107441:	90                   	nop
80107442:	c9                   	leave  
80107443:	c3                   	ret    

80107444 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107444:	55                   	push   %ebp
80107445:	89 e5                	mov    %esp,%ebp
80107447:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010744a:	6a 34                	push   $0x34
8010744c:	6a 43                	push   $0x43
8010744e:	e8 d2 ff ff ff       	call   80107425 <outb>
80107453:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107456:	68 9c 00 00 00       	push   $0x9c
8010745b:	6a 40                	push   $0x40
8010745d:	e8 c3 ff ff ff       	call   80107425 <outb>
80107462:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107465:	6a 2e                	push   $0x2e
80107467:	6a 40                	push   $0x40
80107469:	e8 b7 ff ff ff       	call   80107425 <outb>
8010746e:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107471:	83 ec 0c             	sub    $0xc,%esp
80107474:	6a 00                	push   $0x0
80107476:	e8 2d cd ff ff       	call   801041a8 <picenable>
8010747b:	83 c4 10             	add    $0x10,%esp
}
8010747e:	90                   	nop
8010747f:	c9                   	leave  
80107480:	c3                   	ret    

80107481 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107481:	1e                   	push   %ds
  pushl %es
80107482:	06                   	push   %es
  pushl %fs
80107483:	0f a0                	push   %fs
  pushl %gs
80107485:	0f a8                	push   %gs
  pushal
80107487:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107488:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010748c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010748e:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107490:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107494:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107496:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107498:	54                   	push   %esp
  call trap
80107499:	e8 73 02 00 00       	call   80107711 <trap>
  addl $4, %esp
8010749e:	83 c4 04             	add    $0x4,%esp

801074a1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801074a1:	61                   	popa   
  popl %gs
801074a2:	0f a9                	pop    %gs
  popl %fs
801074a4:	0f a1                	pop    %fs
  popl %es
801074a6:	07                   	pop    %es
  popl %ds
801074a7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801074a8:	83 c4 08             	add    $0x8,%esp
  iret
801074ab:	cf                   	iret   

801074ac <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801074ac:	55                   	push   %ebp
801074ad:	89 e5                	mov    %esp,%ebp
801074af:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801074b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801074b5:	83 e8 01             	sub    $0x1,%eax
801074b8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074bc:	8b 45 08             	mov    0x8(%ebp),%eax
801074bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074c3:	8b 45 08             	mov    0x8(%ebp),%eax
801074c6:	c1 e8 10             	shr    $0x10,%eax
801074c9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801074cd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074d0:	0f 01 18             	lidtl  (%eax)
}
801074d3:	90                   	nop
801074d4:	c9                   	leave  
801074d5:	c3                   	ret    

801074d6 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801074d6:	55                   	push   %ebp
801074d7:	89 e5                	mov    %esp,%ebp
801074d9:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801074dc:	0f 20 d0             	mov    %cr2,%eax
801074df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801074e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801074e5:	c9                   	leave  
801074e6:	c3                   	ret    

801074e7 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801074e7:	55                   	push   %ebp
801074e8:	89 e5                	mov    %esp,%ebp
801074ea:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801074ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074f4:	e9 c3 00 00 00       	jmp    801075bc <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801074f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fc:	8b 04 85 bc c0 10 80 	mov    -0x7fef3f44(,%eax,4),%eax
80107503:	89 c2                	mov    %eax,%edx
80107505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107508:	66 89 14 c5 60 74 11 	mov    %dx,-0x7fee8ba0(,%eax,8)
8010750f:	80 
80107510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107513:	66 c7 04 c5 62 74 11 	movw   $0x8,-0x7fee8b9e(,%eax,8)
8010751a:	80 08 00 
8010751d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107520:	0f b6 14 c5 64 74 11 	movzbl -0x7fee8b9c(,%eax,8),%edx
80107527:	80 
80107528:	83 e2 e0             	and    $0xffffffe0,%edx
8010752b:	88 14 c5 64 74 11 80 	mov    %dl,-0x7fee8b9c(,%eax,8)
80107532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107535:	0f b6 14 c5 64 74 11 	movzbl -0x7fee8b9c(,%eax,8),%edx
8010753c:	80 
8010753d:	83 e2 1f             	and    $0x1f,%edx
80107540:	88 14 c5 64 74 11 80 	mov    %dl,-0x7fee8b9c(,%eax,8)
80107547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754a:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
80107551:	80 
80107552:	83 e2 f0             	and    $0xfffffff0,%edx
80107555:	83 ca 0e             	or     $0xe,%edx
80107558:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
8010755f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107562:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
80107569:	80 
8010756a:	83 e2 ef             	and    $0xffffffef,%edx
8010756d:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
80107574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107577:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
8010757e:	80 
8010757f:	83 e2 9f             	and    $0xffffff9f,%edx
80107582:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
80107589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758c:	0f b6 14 c5 65 74 11 	movzbl -0x7fee8b9b(,%eax,8),%edx
80107593:	80 
80107594:	83 ca 80             	or     $0xffffff80,%edx
80107597:	88 14 c5 65 74 11 80 	mov    %dl,-0x7fee8b9b(,%eax,8)
8010759e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a1:	8b 04 85 bc c0 10 80 	mov    -0x7fef3f44(,%eax,4),%eax
801075a8:	c1 e8 10             	shr    $0x10,%eax
801075ab:	89 c2                	mov    %eax,%edx
801075ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b0:	66 89 14 c5 66 74 11 	mov    %dx,-0x7fee8b9a(,%eax,8)
801075b7:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801075b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075bc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801075c3:	0f 8e 30 ff ff ff    	jle    801074f9 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801075c9:	a1 bc c1 10 80       	mov    0x8010c1bc,%eax
801075ce:	66 a3 60 76 11 80    	mov    %ax,0x80117660
801075d4:	66 c7 05 62 76 11 80 	movw   $0x8,0x80117662
801075db:	08 00 
801075dd:	0f b6 05 64 76 11 80 	movzbl 0x80117664,%eax
801075e4:	83 e0 e0             	and    $0xffffffe0,%eax
801075e7:	a2 64 76 11 80       	mov    %al,0x80117664
801075ec:	0f b6 05 64 76 11 80 	movzbl 0x80117664,%eax
801075f3:	83 e0 1f             	and    $0x1f,%eax
801075f6:	a2 64 76 11 80       	mov    %al,0x80117664
801075fb:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
80107602:	83 c8 0f             	or     $0xf,%eax
80107605:	a2 65 76 11 80       	mov    %al,0x80117665
8010760a:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
80107611:	83 e0 ef             	and    $0xffffffef,%eax
80107614:	a2 65 76 11 80       	mov    %al,0x80117665
80107619:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
80107620:	83 c8 60             	or     $0x60,%eax
80107623:	a2 65 76 11 80       	mov    %al,0x80117665
80107628:	0f b6 05 65 76 11 80 	movzbl 0x80117665,%eax
8010762f:	83 c8 80             	or     $0xffffff80,%eax
80107632:	a2 65 76 11 80       	mov    %al,0x80117665
80107637:	a1 bc c1 10 80       	mov    0x8010c1bc,%eax
8010763c:	c1 e8 10             	shr    $0x10,%eax
8010763f:	66 a3 66 76 11 80    	mov    %ax,0x80117666

  initlock(&tickslock, "time");
80107645:	83 ec 08             	sub    $0x8,%esp
80107648:	68 08 9c 10 80       	push   $0x80109c08
8010764d:	68 20 74 11 80       	push   $0x80117420
80107652:	e8 d6 e5 ff ff       	call   80105c2d <initlock>
80107657:	83 c4 10             	add    $0x10,%esp
}
8010765a:	90                   	nop
8010765b:	c9                   	leave  
8010765c:	c3                   	ret    

8010765d <idtinit>:

void
idtinit(void)
{
8010765d:	55                   	push   %ebp
8010765e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107660:	68 00 08 00 00       	push   $0x800
80107665:	68 60 74 11 80       	push   $0x80117460
8010766a:	e8 3d fe ff ff       	call   801074ac <lidt>
8010766f:	83 c4 08             	add    $0x8,%esp
}
80107672:	90                   	nop
80107673:	c9                   	leave  
80107674:	c3                   	ret    

80107675 <mmapin>:

int
mmapin(uint cr2)
{
80107675:	55                   	push   %ebp
80107676:	89 e5                	mov    %esp,%ebp
80107678:	83 ec 10             	sub    $0x10,%esp
  int index;

  for(index = 0; index < MAXMAPPEDFILES; index++){
8010767b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107682:	eb 7c                	jmp    80107700 <mmapin+0x8b>
    int va;
    int sz;
    va = proc->ommap[index].va;
80107684:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010768b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010768e:	89 d0                	mov    %edx,%eax
80107690:	01 c0                	add    %eax,%eax
80107692:	01 d0                	add    %edx,%eax
80107694:	c1 e0 02             	shl    $0x2,%eax
80107697:	01 c8                	add    %ecx,%eax
80107699:	05 a4 00 00 00       	add    $0xa4,%eax
8010769e:	8b 00                	mov    (%eax),%eax
801076a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    sz = proc->ommap[index].sz;
801076a3:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801076aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801076ad:	89 d0                	mov    %edx,%eax
801076af:	01 c0                	add    %eax,%eax
801076b1:	01 d0                	add    %edx,%eax
801076b3:	c1 e0 02             	shl    $0x2,%eax
801076b6:	01 c8                	add    %ecx,%eax
801076b8:	05 a8 00 00 00       	add    $0xa8,%eax
801076bd:	8b 00                	mov    (%eax),%eax
801076bf:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(proc->ommap[index].pfile != 0 && cr2 >= va && cr2 < (va + sz))
801076c2:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801076c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801076cc:	89 d0                	mov    %edx,%eax
801076ce:	01 c0                	add    %eax,%eax
801076d0:	01 d0                	add    %edx,%eax
801076d2:	c1 e0 02             	shl    $0x2,%eax
801076d5:	01 c8                	add    %ecx,%eax
801076d7:	05 a0 00 00 00       	add    $0xa0,%eax
801076dc:	8b 00                	mov    (%eax),%eax
801076de:	85 c0                	test   %eax,%eax
801076e0:	74 1a                	je     801076fc <mmapin+0x87>
801076e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801076e5:	39 45 08             	cmp    %eax,0x8(%ebp)
801076e8:	72 12                	jb     801076fc <mmapin+0x87>
801076ea:	8b 55 f8             	mov    -0x8(%ebp),%edx
801076ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f0:	01 d0                	add    %edx,%eax
801076f2:	3b 45 08             	cmp    0x8(%ebp),%eax
801076f5:	76 05                	jbe    801076fc <mmapin+0x87>
      return index;
801076f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801076fa:	eb 13                	jmp    8010770f <mmapin+0x9a>
int
mmapin(uint cr2)
{
  int index;

  for(index = 0; index < MAXMAPPEDFILES; index++){
801076fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107700:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
80107704:	0f 8e 7a ff ff ff    	jle    80107684 <mmapin+0xf>
    sz = proc->ommap[index].sz;

    if(proc->ommap[index].pfile != 0 && cr2 >= va && cr2 < (va + sz))
      return index;
  }
  return -1;
8010770a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010770f:	c9                   	leave  
80107710:	c3                   	ret    

80107711 <trap>:


//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107711:	55                   	push   %ebp
80107712:	89 e5                	mov    %esp,%ebp
80107714:	57                   	push   %edi
80107715:	56                   	push   %esi
80107716:	53                   	push   %ebx
80107717:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010771a:	8b 45 08             	mov    0x8(%ebp),%eax
8010771d:	8b 40 30             	mov    0x30(%eax),%eax
80107720:	83 f8 40             	cmp    $0x40,%eax
80107723:	75 3e                	jne    80107763 <trap+0x52>
    if(proc->killed)
80107725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010772b:	8b 40 24             	mov    0x24(%eax),%eax
8010772e:	85 c0                	test   %eax,%eax
80107730:	74 05                	je     80107737 <trap+0x26>
      exit();
80107732:	e8 fb d7 ff ff       	call   80104f32 <exit>
    proc->tf = tf;
80107737:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010773d:	8b 55 08             	mov    0x8(%ebp),%edx
80107740:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107743:	e8 45 eb ff ff       	call   8010628d <syscall>
    if(proc->killed)
80107748:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010774e:	8b 40 24             	mov    0x24(%eax),%eax
80107751:	85 c0                	test   %eax,%eax
80107753:	0f 84 06 04 00 00    	je     80107b5f <trap+0x44e>
      exit();
80107759:	e8 d4 d7 ff ff       	call   80104f32 <exit>
    return;
8010775e:	e9 fc 03 00 00       	jmp    80107b5f <trap+0x44e>
  }

  switch(tf->trapno){
80107763:	8b 45 08             	mov    0x8(%ebp),%eax
80107766:	8b 40 30             	mov    0x30(%eax),%eax
80107769:	83 e8 20             	sub    $0x20,%eax
8010776c:	83 f8 1f             	cmp    $0x1f,%eax
8010776f:	0f 87 c0 00 00 00    	ja     80107835 <trap+0x124>
80107775:	8b 04 85 44 9d 10 80 	mov    -0x7fef62bc(,%eax,4),%eax
8010777c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010777e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107784:	0f b6 00             	movzbl (%eax),%eax
80107787:	84 c0                	test   %al,%al
80107789:	75 3d                	jne    801077c8 <trap+0xb7>
      acquire(&tickslock);
8010778b:	83 ec 0c             	sub    $0xc,%esp
8010778e:	68 20 74 11 80       	push   $0x80117420
80107793:	e8 b7 e4 ff ff       	call   80105c4f <acquire>
80107798:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010779b:	a1 60 7c 11 80       	mov    0x80117c60,%eax
801077a0:	83 c0 01             	add    $0x1,%eax
801077a3:	a3 60 7c 11 80       	mov    %eax,0x80117c60
      wakeup(&ticks);
801077a8:	83 ec 0c             	sub    $0xc,%esp
801077ab:	68 60 7c 11 80       	push   $0x80117c60
801077b0:	e8 ea dd ff ff       	call   8010559f <wakeup>
801077b5:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801077b8:	83 ec 0c             	sub    $0xc,%esp
801077bb:	68 20 74 11 80       	push   $0x80117420
801077c0:	e8 f1 e4 ff ff       	call   80105cb6 <release>
801077c5:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801077c8:	e8 1a b8 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077cd:	e9 b1 02 00 00       	jmp    80107a83 <trap+0x372>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801077d2:	e8 23 b0 ff ff       	call   801027fa <ideintr>
    lapiceoi();
801077d7:	e8 0b b8 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077dc:	e9 a2 02 00 00       	jmp    80107a83 <trap+0x372>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801077e1:	e8 03 b6 ff ff       	call   80102de9 <kbdintr>
    lapiceoi();
801077e6:	e8 fc b7 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077eb:	e9 93 02 00 00       	jmp    80107a83 <trap+0x372>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801077f0:	e8 4b 05 00 00       	call   80107d40 <uartintr>
    lapiceoi();
801077f5:	e8 ed b7 ff ff       	call   80102fe7 <lapiceoi>
    break;
801077fa:	e9 84 02 00 00       	jmp    80107a83 <trap+0x372>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107802:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107805:	8b 45 08             	mov    0x8(%ebp),%eax
80107808:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010780c:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010780f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107815:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107818:	0f b6 c0             	movzbl %al,%eax
8010781b:	51                   	push   %ecx
8010781c:	52                   	push   %edx
8010781d:	50                   	push   %eax
8010781e:	68 10 9c 10 80       	push   $0x80109c10
80107823:	e8 9e 8b ff ff       	call   801003c6 <cprintf>
80107828:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010782b:	e8 b7 b7 ff ff       	call   80102fe7 <lapiceoi>
    break;
80107830:	e9 4e 02 00 00       	jmp    80107a83 <trap+0x372>

  //PAGEBREAK: 13
  default:

    if(proc && tf->trapno == T_PGFLT){
80107835:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010783b:	85 c0                	test   %eax,%eax
8010783d:	0f 84 84 01 00 00    	je     801079c7 <trap+0x2b6>
80107843:	8b 45 08             	mov    0x8(%ebp),%eax
80107846:	8b 40 30             	mov    0x30(%eax),%eax
80107849:	83 f8 0e             	cmp    $0xe,%eax
8010784c:	0f 85 75 01 00 00    	jne    801079c7 <trap+0x2b6>
      uint cr2=rcr2();
80107852:	e8 7f fc ff ff       	call   801074d6 <rcr2>
80107857:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int mmapid;


      //  Verify if you wanted to access a correct address but not assigned.
      //  if appropriate, assign one more page to the stack.
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
8010785a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107860:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80107866:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80107869:	77 6b                	ja     801078d6 <trap+0x1c5>
8010786b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107871:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80107877:	05 00 80 00 00       	add    $0x8000,%eax
8010787c:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
8010787f:	76 55                	jbe    801078d6 <trap+0x1c5>
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
80107881:	83 ec 08             	sub    $0x8,%esp
80107884:	ff 75 e4             	pushl  -0x1c(%ebp)
80107887:	68 34 9c 10 80       	push   $0x80109c34
8010788c:	e8 35 8b ff ff       	call   801003c6 <cprintf>
80107891:	83 c4 10             	add    $0x10,%esp
        basepgaddr=PGROUNDDOWN(cr2);
80107894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107897:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010789c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
8010789f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801078a2:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
801078a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078ae:	8b 40 04             	mov    0x4(%eax),%eax
801078b1:	83 ec 04             	sub    $0x4,%esp
801078b4:	52                   	push   %edx
801078b5:	ff 75 e0             	pushl  -0x20(%ebp)
801078b8:	50                   	push   %eax
801078b9:	e8 d6 18 00 00       	call   80109194 <allocuvm>
801078be:	83 c4 10             	add    $0x10,%esp
801078c1:	85 c0                	test   %eax,%eax
801078c3:	0f 85 b9 01 00 00    	jne    80107a82 <trap+0x371>
          panic("trap alloc stack");
801078c9:	83 ec 0c             	sub    $0xc,%esp
801078cc:	68 70 9c 10 80       	push   $0x80109c70
801078d1:	e8 90 8c ff ff       	call   80100566 <panic>
        break;
      }

      if ( (mmapid = mmapin(cr2)) >= 0 ) {
801078d6:	83 ec 0c             	sub    $0xc,%esp
801078d9:	ff 75 e4             	pushl  -0x1c(%ebp)
801078dc:	e8 94 fd ff ff       	call   80107675 <mmapin>
801078e1:	83 c4 10             	add    $0x10,%esp
801078e4:	89 45 dc             	mov    %eax,-0x24(%ebp)
801078e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801078eb:	0f 88 d6 00 00 00    	js     801079c7 <trap+0x2b6>
        int offset;
        cprintf("\nSE QUIERE LEER UNA PAGINA DEL ARCHIVO NO ALOCADA!\n");
801078f1:	83 ec 0c             	sub    $0xc,%esp
801078f4:	68 84 9c 10 80       	push   $0x80109c84
801078f9:	e8 c8 8a ff ff       	call   801003c6 <cprintf>
801078fe:	83 c4 10             	add    $0x10,%esp
        // in ashared memory region
        basepgaddr = PGROUNDDOWN(cr2);
80107901:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107904:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107909:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
8010790c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010790f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
80107915:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010791b:	8b 40 04             	mov    0x4(%eax),%eax
8010791e:	83 ec 04             	sub    $0x4,%esp
80107921:	52                   	push   %edx
80107922:	ff 75 e0             	pushl  -0x20(%ebp)
80107925:	50                   	push   %eax
80107926:	e8 69 18 00 00       	call   80109194 <allocuvm>
8010792b:	83 c4 10             	add    $0x10,%esp
8010792e:	85 c0                	test   %eax,%eax
80107930:	75 0d                	jne    8010793f <trap+0x22e>
          panic("trap alloc mmap");
80107932:	83 ec 0c             	sub    $0xc,%esp
80107935:	68 b8 9c 10 80       	push   $0x80109cb8
8010793a:	e8 27 8c ff ff       	call   80100566 <panic>
        offset = basepgaddr - proc->ommap[mmapid].va;
8010793f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80107946:	8b 55 dc             	mov    -0x24(%ebp),%edx
80107949:	89 d0                	mov    %edx,%eax
8010794b:	01 c0                	add    %eax,%eax
8010794d:	01 d0                	add    %edx,%eax
8010794f:	c1 e0 02             	shl    $0x2,%eax
80107952:	01 c8                	add    %ecx,%eax
80107954:	05 a4 00 00 00       	add    $0xa4,%eax
80107959:	8b 00                	mov    (%eax),%eax
8010795b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010795e:	29 c2                	sub    %eax,%edx
80107960:	89 d0                	mov    %edx,%eax
80107962:	89 45 d8             	mov    %eax,-0x28(%ebp)
        fileseek(proc->ommap[mmapid].pfile, offset);
80107965:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80107968:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010796f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80107972:	89 d0                	mov    %edx,%eax
80107974:	01 c0                	add    %eax,%eax
80107976:	01 d0                	add    %edx,%eax
80107978:	c1 e0 02             	shl    $0x2,%eax
8010797b:	01 d8                	add    %ebx,%eax
8010797d:	05 a0 00 00 00       	add    $0xa0,%eax
80107982:	8b 00                	mov    (%eax),%eax
80107984:	83 ec 08             	sub    $0x8,%esp
80107987:	51                   	push   %ecx
80107988:	50                   	push   %eax
80107989:	e8 e3 99 ff ff       	call   80101371 <fileseek>
8010798e:	83 c4 10             	add    $0x10,%esp
        fileread(proc->ommap[mmapid].pfile, (char *)basepgaddr, PGSIZE);
80107991:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80107994:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010799b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010799e:	89 d0                	mov    %edx,%eax
801079a0:	01 c0                	add    %eax,%eax
801079a2:	01 d0                	add    %edx,%eax
801079a4:	c1 e0 02             	shl    $0x2,%eax
801079a7:	01 d8                	add    %ebx,%eax
801079a9:	05 a0 00 00 00       	add    $0xa0,%eax
801079ae:	8b 00                	mov    (%eax),%eax
801079b0:	83 ec 04             	sub    $0x4,%esp
801079b3:	68 00 10 00 00       	push   $0x1000
801079b8:	51                   	push   %ecx
801079b9:	50                   	push   %eax
801079ba:	e8 be 97 ff ff       	call   8010117d <fileread>
801079bf:	83 c4 10             	add    $0x10,%esp
        break;
801079c2:	e9 bc 00 00 00       	jmp    80107a83 <trap+0x372>
      }

    }

    if(proc == 0 || (tf->cs&3) == 0){
801079c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801079cd:	85 c0                	test   %eax,%eax
801079cf:	74 11                	je     801079e2 <trap+0x2d1>
801079d1:	8b 45 08             	mov    0x8(%ebp),%eax
801079d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801079d8:	0f b7 c0             	movzwl %ax,%eax
801079db:	83 e0 03             	and    $0x3,%eax
801079de:	85 c0                	test   %eax,%eax
801079e0:	75 40                	jne    80107a22 <trap+0x311>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801079e2:	e8 ef fa ff ff       	call   801074d6 <rcr2>
801079e7:	89 c3                	mov    %eax,%ebx
801079e9:	8b 45 08             	mov    0x8(%ebp),%eax
801079ec:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801079ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079f5:	0f b6 00             	movzbl (%eax),%eax

    }

    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801079f8:	0f b6 d0             	movzbl %al,%edx
801079fb:	8b 45 08             	mov    0x8(%ebp),%eax
801079fe:	8b 40 30             	mov    0x30(%eax),%eax
80107a01:	83 ec 0c             	sub    $0xc,%esp
80107a04:	53                   	push   %ebx
80107a05:	51                   	push   %ecx
80107a06:	52                   	push   %edx
80107a07:	50                   	push   %eax
80107a08:	68 c8 9c 10 80       	push   $0x80109cc8
80107a0d:	e8 b4 89 ff ff       	call   801003c6 <cprintf>
80107a12:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107a15:	83 ec 0c             	sub    $0xc,%esp
80107a18:	68 fa 9c 10 80       	push   $0x80109cfa
80107a1d:	e8 44 8b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107a22:	e8 af fa ff ff       	call   801074d6 <rcr2>
80107a27:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2d:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107a30:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a36:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107a39:	0f b6 d8             	movzbl %al,%ebx
80107a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a3f:	8b 48 34             	mov    0x34(%eax),%ecx
80107a42:	8b 45 08             	mov    0x8(%ebp),%eax
80107a45:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107a48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a4e:	8d 78 6c             	lea    0x6c(%eax),%edi
80107a51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107a57:	8b 40 10             	mov    0x10(%eax),%eax
80107a5a:	ff 75 d4             	pushl  -0x2c(%ebp)
80107a5d:	56                   	push   %esi
80107a5e:	53                   	push   %ebx
80107a5f:	51                   	push   %ecx
80107a60:	52                   	push   %edx
80107a61:	57                   	push   %edi
80107a62:	50                   	push   %eax
80107a63:	68 00 9d 10 80       	push   $0x80109d00
80107a68:	e8 59 89 ff ff       	call   801003c6 <cprintf>
80107a6d:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
80107a70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a76:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107a7d:	eb 04                	jmp    80107a83 <trap+0x372>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107a7f:	90                   	nop
80107a80:	eb 01                	jmp    80107a83 <trap+0x372>
      if(cr2 >= proc->sstack && cr2 < proc->sstack + MAXSTACKPAGES * PGSIZE){
        cprintf("exhausted the stack, it will increase...virtual address:%x\n",cr2);
        basepgaddr=PGROUNDDOWN(cr2);
        if(allocuvm(proc->pgdir, basepgaddr, basepgaddr + PGSIZE) == 0)
          panic("trap alloc stack");
        break;
80107a82:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107a83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a89:	85 c0                	test   %eax,%eax
80107a8b:	74 24                	je     80107ab1 <trap+0x3a0>
80107a8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a93:	8b 40 24             	mov    0x24(%eax),%eax
80107a96:	85 c0                	test   %eax,%eax
80107a98:	74 17                	je     80107ab1 <trap+0x3a0>
80107a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107aa1:	0f b7 c0             	movzwl %ax,%eax
80107aa4:	83 e0 03             	and    $0x3,%eax
80107aa7:	83 f8 03             	cmp    $0x3,%eax
80107aaa:	75 05                	jne    80107ab1 <trap+0x3a0>
    exit();
80107aac:	e8 81 d4 ff ff       	call   80104f32 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
80107ab1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ab7:	85 c0                	test   %eax,%eax
80107ab9:	74 41                	je     80107afc <trap+0x3eb>
80107abb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ac1:	8b 40 0c             	mov    0xc(%eax),%eax
80107ac4:	83 f8 04             	cmp    $0x4,%eax
80107ac7:	75 33                	jne    80107afc <trap+0x3eb>
80107ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80107acc:	8b 40 30             	mov    0x30(%eax),%eax
80107acf:	83 f8 20             	cmp    $0x20,%eax
80107ad2:	75 28                	jne    80107afc <trap+0x3eb>
    if(proc->ticks++ == QUANTUM-1){  // Check if the amount of ticks of the current process reached the Quantum
80107ad4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ada:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
80107ade:	8d 4a 01             	lea    0x1(%edx),%ecx
80107ae1:	66 89 48 7c          	mov    %cx,0x7c(%eax)
80107ae5:	66 83 fa 04          	cmp    $0x4,%dx
80107ae9:	75 11                	jne    80107afc <trap+0x3eb>
      //cprintf("El proceso con id %d tiene %d ticks\n",proc->pid, proc->ticks);
      proc->ticks=0;  // Restarts the amount of process ticks
80107aeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107af1:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
80107af7:	e8 05 d9 ff ff       	call   80105401 <yield>
    }

  }
  // check if the number of ticks was reached to increase the ages.
  if((tf->trapno == T_IRQ0+IRQ_TIMER) && (ticks % TICKSFORAGE == 0))
80107afc:	8b 45 08             	mov    0x8(%ebp),%eax
80107aff:	8b 40 30             	mov    0x30(%eax),%eax
80107b02:	83 f8 20             	cmp    $0x20,%eax
80107b05:	75 28                	jne    80107b2f <trap+0x41e>
80107b07:	8b 0d 60 7c 11 80    	mov    0x80117c60,%ecx
80107b0d:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107b12:	89 c8                	mov    %ecx,%eax
80107b14:	f7 e2                	mul    %edx
80107b16:	c1 ea 03             	shr    $0x3,%edx
80107b19:	89 d0                	mov    %edx,%eax
80107b1b:	c1 e0 02             	shl    $0x2,%eax
80107b1e:	01 d0                	add    %edx,%eax
80107b20:	01 c0                	add    %eax,%eax
80107b22:	29 c1                	sub    %eax,%ecx
80107b24:	89 ca                	mov    %ecx,%edx
80107b26:	85 d2                	test   %edx,%edx
80107b28:	75 05                	jne    80107b2f <trap+0x41e>
    calculateaging();
80107b2a:	e8 49 cd ff ff       	call   80104878 <calculateaging>


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107b2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107b35:	85 c0                	test   %eax,%eax
80107b37:	74 27                	je     80107b60 <trap+0x44f>
80107b39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107b3f:	8b 40 24             	mov    0x24(%eax),%eax
80107b42:	85 c0                	test   %eax,%eax
80107b44:	74 1a                	je     80107b60 <trap+0x44f>
80107b46:	8b 45 08             	mov    0x8(%ebp),%eax
80107b49:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107b4d:	0f b7 c0             	movzwl %ax,%eax
80107b50:	83 e0 03             	and    $0x3,%eax
80107b53:	83 f8 03             	cmp    $0x3,%eax
80107b56:	75 08                	jne    80107b60 <trap+0x44f>
    exit();
80107b58:	e8 d5 d3 ff ff       	call   80104f32 <exit>
80107b5d:	eb 01                	jmp    80107b60 <trap+0x44f>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107b5f:	90                   	nop


  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107b63:	5b                   	pop    %ebx
80107b64:	5e                   	pop    %esi
80107b65:	5f                   	pop    %edi
80107b66:	5d                   	pop    %ebp
80107b67:	c3                   	ret    

80107b68 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107b68:	55                   	push   %ebp
80107b69:	89 e5                	mov    %esp,%ebp
80107b6b:	83 ec 14             	sub    $0x14,%esp
80107b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107b71:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107b75:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107b79:	89 c2                	mov    %eax,%edx
80107b7b:	ec                   	in     (%dx),%al
80107b7c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107b7f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107b83:	c9                   	leave  
80107b84:	c3                   	ret    

80107b85 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107b85:	55                   	push   %ebp
80107b86:	89 e5                	mov    %esp,%ebp
80107b88:	83 ec 08             	sub    $0x8,%esp
80107b8b:	8b 55 08             	mov    0x8(%ebp),%edx
80107b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b91:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107b95:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107b98:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107b9c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107ba0:	ee                   	out    %al,(%dx)
}
80107ba1:	90                   	nop
80107ba2:	c9                   	leave  
80107ba3:	c3                   	ret    

80107ba4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107ba4:	55                   	push   %ebp
80107ba5:	89 e5                	mov    %esp,%ebp
80107ba7:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107baa:	6a 00                	push   $0x0
80107bac:	68 fa 03 00 00       	push   $0x3fa
80107bb1:	e8 cf ff ff ff       	call   80107b85 <outb>
80107bb6:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107bb9:	68 80 00 00 00       	push   $0x80
80107bbe:	68 fb 03 00 00       	push   $0x3fb
80107bc3:	e8 bd ff ff ff       	call   80107b85 <outb>
80107bc8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107bcb:	6a 0c                	push   $0xc
80107bcd:	68 f8 03 00 00       	push   $0x3f8
80107bd2:	e8 ae ff ff ff       	call   80107b85 <outb>
80107bd7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107bda:	6a 00                	push   $0x0
80107bdc:	68 f9 03 00 00       	push   $0x3f9
80107be1:	e8 9f ff ff ff       	call   80107b85 <outb>
80107be6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107be9:	6a 03                	push   $0x3
80107beb:	68 fb 03 00 00       	push   $0x3fb
80107bf0:	e8 90 ff ff ff       	call   80107b85 <outb>
80107bf5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107bf8:	6a 00                	push   $0x0
80107bfa:	68 fc 03 00 00       	push   $0x3fc
80107bff:	e8 81 ff ff ff       	call   80107b85 <outb>
80107c04:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107c07:	6a 01                	push   $0x1
80107c09:	68 f9 03 00 00       	push   $0x3f9
80107c0e:	e8 72 ff ff ff       	call   80107b85 <outb>
80107c13:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107c16:	68 fd 03 00 00       	push   $0x3fd
80107c1b:	e8 48 ff ff ff       	call   80107b68 <inb>
80107c20:	83 c4 04             	add    $0x4,%esp
80107c23:	3c ff                	cmp    $0xff,%al
80107c25:	74 6e                	je     80107c95 <uartinit+0xf1>
    return;
  uart = 1;
80107c27:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107c2e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107c31:	68 fa 03 00 00       	push   $0x3fa
80107c36:	e8 2d ff ff ff       	call   80107b68 <inb>
80107c3b:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107c3e:	68 f8 03 00 00       	push   $0x3f8
80107c43:	e8 20 ff ff ff       	call   80107b68 <inb>
80107c48:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107c4b:	83 ec 0c             	sub    $0xc,%esp
80107c4e:	6a 04                	push   $0x4
80107c50:	e8 53 c5 ff ff       	call   801041a8 <picenable>
80107c55:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107c58:	83 ec 08             	sub    $0x8,%esp
80107c5b:	6a 00                	push   $0x0
80107c5d:	6a 04                	push   $0x4
80107c5f:	e8 38 ae ff ff       	call   80102a9c <ioapicenable>
80107c64:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107c67:	c7 45 f4 c4 9d 10 80 	movl   $0x80109dc4,-0xc(%ebp)
80107c6e:	eb 19                	jmp    80107c89 <uartinit+0xe5>
    uartputc(*p);
80107c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c73:	0f b6 00             	movzbl (%eax),%eax
80107c76:	0f be c0             	movsbl %al,%eax
80107c79:	83 ec 0c             	sub    $0xc,%esp
80107c7c:	50                   	push   %eax
80107c7d:	e8 16 00 00 00       	call   80107c98 <uartputc>
80107c82:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107c85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8c:	0f b6 00             	movzbl (%eax),%eax
80107c8f:	84 c0                	test   %al,%al
80107c91:	75 dd                	jne    80107c70 <uartinit+0xcc>
80107c93:	eb 01                	jmp    80107c96 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107c95:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107c96:	c9                   	leave  
80107c97:	c3                   	ret    

80107c98 <uartputc>:

void
uartputc(int c)
{
80107c98:	55                   	push   %ebp
80107c99:	89 e5                	mov    %esp,%ebp
80107c9b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107c9e:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107ca3:	85 c0                	test   %eax,%eax
80107ca5:	74 53                	je     80107cfa <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cae:	eb 11                	jmp    80107cc1 <uartputc+0x29>
    microdelay(10);
80107cb0:	83 ec 0c             	sub    $0xc,%esp
80107cb3:	6a 0a                	push   $0xa
80107cb5:	e8 48 b3 ff ff       	call   80103002 <microdelay>
80107cba:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107cbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cc1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107cc5:	7f 1a                	jg     80107ce1 <uartputc+0x49>
80107cc7:	83 ec 0c             	sub    $0xc,%esp
80107cca:	68 fd 03 00 00       	push   $0x3fd
80107ccf:	e8 94 fe ff ff       	call   80107b68 <inb>
80107cd4:	83 c4 10             	add    $0x10,%esp
80107cd7:	0f b6 c0             	movzbl %al,%eax
80107cda:	83 e0 20             	and    $0x20,%eax
80107cdd:	85 c0                	test   %eax,%eax
80107cdf:	74 cf                	je     80107cb0 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ce4:	0f b6 c0             	movzbl %al,%eax
80107ce7:	83 ec 08             	sub    $0x8,%esp
80107cea:	50                   	push   %eax
80107ceb:	68 f8 03 00 00       	push   $0x3f8
80107cf0:	e8 90 fe ff ff       	call   80107b85 <outb>
80107cf5:	83 c4 10             	add    $0x10,%esp
80107cf8:	eb 01                	jmp    80107cfb <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107cfa:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107cfb:	c9                   	leave  
80107cfc:	c3                   	ret    

80107cfd <uartgetc>:

static int
uartgetc(void)
{
80107cfd:	55                   	push   %ebp
80107cfe:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107d00:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107d05:	85 c0                	test   %eax,%eax
80107d07:	75 07                	jne    80107d10 <uartgetc+0x13>
    return -1;
80107d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d0e:	eb 2e                	jmp    80107d3e <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107d10:	68 fd 03 00 00       	push   $0x3fd
80107d15:	e8 4e fe ff ff       	call   80107b68 <inb>
80107d1a:	83 c4 04             	add    $0x4,%esp
80107d1d:	0f b6 c0             	movzbl %al,%eax
80107d20:	83 e0 01             	and    $0x1,%eax
80107d23:	85 c0                	test   %eax,%eax
80107d25:	75 07                	jne    80107d2e <uartgetc+0x31>
    return -1;
80107d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d2c:	eb 10                	jmp    80107d3e <uartgetc+0x41>
  return inb(COM1+0);
80107d2e:	68 f8 03 00 00       	push   $0x3f8
80107d33:	e8 30 fe ff ff       	call   80107b68 <inb>
80107d38:	83 c4 04             	add    $0x4,%esp
80107d3b:	0f b6 c0             	movzbl %al,%eax
}
80107d3e:	c9                   	leave  
80107d3f:	c3                   	ret    

80107d40 <uartintr>:

void
uartintr(void)
{
80107d40:	55                   	push   %ebp
80107d41:	89 e5                	mov    %esp,%ebp
80107d43:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107d46:	83 ec 0c             	sub    $0xc,%esp
80107d49:	68 fd 7c 10 80       	push   $0x80107cfd
80107d4e:	e8 8a 8a ff ff       	call   801007dd <consoleintr>
80107d53:	83 c4 10             	add    $0x10,%esp
}
80107d56:	90                   	nop
80107d57:	c9                   	leave  
80107d58:	c3                   	ret    

80107d59 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $0
80107d5b:	6a 00                	push   $0x0
  jmp alltraps
80107d5d:	e9 1f f7 ff ff       	jmp    80107481 <alltraps>

80107d62 <vector1>:
.globl vector1
vector1:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $1
80107d64:	6a 01                	push   $0x1
  jmp alltraps
80107d66:	e9 16 f7 ff ff       	jmp    80107481 <alltraps>

80107d6b <vector2>:
.globl vector2
vector2:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $2
80107d6d:	6a 02                	push   $0x2
  jmp alltraps
80107d6f:	e9 0d f7 ff ff       	jmp    80107481 <alltraps>

80107d74 <vector3>:
.globl vector3
vector3:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $3
80107d76:	6a 03                	push   $0x3
  jmp alltraps
80107d78:	e9 04 f7 ff ff       	jmp    80107481 <alltraps>

80107d7d <vector4>:
.globl vector4
vector4:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $4
80107d7f:	6a 04                	push   $0x4
  jmp alltraps
80107d81:	e9 fb f6 ff ff       	jmp    80107481 <alltraps>

80107d86 <vector5>:
.globl vector5
vector5:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $5
80107d88:	6a 05                	push   $0x5
  jmp alltraps
80107d8a:	e9 f2 f6 ff ff       	jmp    80107481 <alltraps>

80107d8f <vector6>:
.globl vector6
vector6:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $6
80107d91:	6a 06                	push   $0x6
  jmp alltraps
80107d93:	e9 e9 f6 ff ff       	jmp    80107481 <alltraps>

80107d98 <vector7>:
.globl vector7
vector7:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $7
80107d9a:	6a 07                	push   $0x7
  jmp alltraps
80107d9c:	e9 e0 f6 ff ff       	jmp    80107481 <alltraps>

80107da1 <vector8>:
.globl vector8
vector8:
  pushl $8
80107da1:	6a 08                	push   $0x8
  jmp alltraps
80107da3:	e9 d9 f6 ff ff       	jmp    80107481 <alltraps>

80107da8 <vector9>:
.globl vector9
vector9:
  pushl $0
80107da8:	6a 00                	push   $0x0
  pushl $9
80107daa:	6a 09                	push   $0x9
  jmp alltraps
80107dac:	e9 d0 f6 ff ff       	jmp    80107481 <alltraps>

80107db1 <vector10>:
.globl vector10
vector10:
  pushl $10
80107db1:	6a 0a                	push   $0xa
  jmp alltraps
80107db3:	e9 c9 f6 ff ff       	jmp    80107481 <alltraps>

80107db8 <vector11>:
.globl vector11
vector11:
  pushl $11
80107db8:	6a 0b                	push   $0xb
  jmp alltraps
80107dba:	e9 c2 f6 ff ff       	jmp    80107481 <alltraps>

80107dbf <vector12>:
.globl vector12
vector12:
  pushl $12
80107dbf:	6a 0c                	push   $0xc
  jmp alltraps
80107dc1:	e9 bb f6 ff ff       	jmp    80107481 <alltraps>

80107dc6 <vector13>:
.globl vector13
vector13:
  pushl $13
80107dc6:	6a 0d                	push   $0xd
  jmp alltraps
80107dc8:	e9 b4 f6 ff ff       	jmp    80107481 <alltraps>

80107dcd <vector14>:
.globl vector14
vector14:
  pushl $14
80107dcd:	6a 0e                	push   $0xe
  jmp alltraps
80107dcf:	e9 ad f6 ff ff       	jmp    80107481 <alltraps>

80107dd4 <vector15>:
.globl vector15
vector15:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $15
80107dd6:	6a 0f                	push   $0xf
  jmp alltraps
80107dd8:	e9 a4 f6 ff ff       	jmp    80107481 <alltraps>

80107ddd <vector16>:
.globl vector16
vector16:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $16
80107ddf:	6a 10                	push   $0x10
  jmp alltraps
80107de1:	e9 9b f6 ff ff       	jmp    80107481 <alltraps>

80107de6 <vector17>:
.globl vector17
vector17:
  pushl $17
80107de6:	6a 11                	push   $0x11
  jmp alltraps
80107de8:	e9 94 f6 ff ff       	jmp    80107481 <alltraps>

80107ded <vector18>:
.globl vector18
vector18:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $18
80107def:	6a 12                	push   $0x12
  jmp alltraps
80107df1:	e9 8b f6 ff ff       	jmp    80107481 <alltraps>

80107df6 <vector19>:
.globl vector19
vector19:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $19
80107df8:	6a 13                	push   $0x13
  jmp alltraps
80107dfa:	e9 82 f6 ff ff       	jmp    80107481 <alltraps>

80107dff <vector20>:
.globl vector20
vector20:
  pushl $0
80107dff:	6a 00                	push   $0x0
  pushl $20
80107e01:	6a 14                	push   $0x14
  jmp alltraps
80107e03:	e9 79 f6 ff ff       	jmp    80107481 <alltraps>

80107e08 <vector21>:
.globl vector21
vector21:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $21
80107e0a:	6a 15                	push   $0x15
  jmp alltraps
80107e0c:	e9 70 f6 ff ff       	jmp    80107481 <alltraps>

80107e11 <vector22>:
.globl vector22
vector22:
  pushl $0
80107e11:	6a 00                	push   $0x0
  pushl $22
80107e13:	6a 16                	push   $0x16
  jmp alltraps
80107e15:	e9 67 f6 ff ff       	jmp    80107481 <alltraps>

80107e1a <vector23>:
.globl vector23
vector23:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $23
80107e1c:	6a 17                	push   $0x17
  jmp alltraps
80107e1e:	e9 5e f6 ff ff       	jmp    80107481 <alltraps>

80107e23 <vector24>:
.globl vector24
vector24:
  pushl $0
80107e23:	6a 00                	push   $0x0
  pushl $24
80107e25:	6a 18                	push   $0x18
  jmp alltraps
80107e27:	e9 55 f6 ff ff       	jmp    80107481 <alltraps>

80107e2c <vector25>:
.globl vector25
vector25:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $25
80107e2e:	6a 19                	push   $0x19
  jmp alltraps
80107e30:	e9 4c f6 ff ff       	jmp    80107481 <alltraps>

80107e35 <vector26>:
.globl vector26
vector26:
  pushl $0
80107e35:	6a 00                	push   $0x0
  pushl $26
80107e37:	6a 1a                	push   $0x1a
  jmp alltraps
80107e39:	e9 43 f6 ff ff       	jmp    80107481 <alltraps>

80107e3e <vector27>:
.globl vector27
vector27:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $27
80107e40:	6a 1b                	push   $0x1b
  jmp alltraps
80107e42:	e9 3a f6 ff ff       	jmp    80107481 <alltraps>

80107e47 <vector28>:
.globl vector28
vector28:
  pushl $0
80107e47:	6a 00                	push   $0x0
  pushl $28
80107e49:	6a 1c                	push   $0x1c
  jmp alltraps
80107e4b:	e9 31 f6 ff ff       	jmp    80107481 <alltraps>

80107e50 <vector29>:
.globl vector29
vector29:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $29
80107e52:	6a 1d                	push   $0x1d
  jmp alltraps
80107e54:	e9 28 f6 ff ff       	jmp    80107481 <alltraps>

80107e59 <vector30>:
.globl vector30
vector30:
  pushl $0
80107e59:	6a 00                	push   $0x0
  pushl $30
80107e5b:	6a 1e                	push   $0x1e
  jmp alltraps
80107e5d:	e9 1f f6 ff ff       	jmp    80107481 <alltraps>

80107e62 <vector31>:
.globl vector31
vector31:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $31
80107e64:	6a 1f                	push   $0x1f
  jmp alltraps
80107e66:	e9 16 f6 ff ff       	jmp    80107481 <alltraps>

80107e6b <vector32>:
.globl vector32
vector32:
  pushl $0
80107e6b:	6a 00                	push   $0x0
  pushl $32
80107e6d:	6a 20                	push   $0x20
  jmp alltraps
80107e6f:	e9 0d f6 ff ff       	jmp    80107481 <alltraps>

80107e74 <vector33>:
.globl vector33
vector33:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $33
80107e76:	6a 21                	push   $0x21
  jmp alltraps
80107e78:	e9 04 f6 ff ff       	jmp    80107481 <alltraps>

80107e7d <vector34>:
.globl vector34
vector34:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $34
80107e7f:	6a 22                	push   $0x22
  jmp alltraps
80107e81:	e9 fb f5 ff ff       	jmp    80107481 <alltraps>

80107e86 <vector35>:
.globl vector35
vector35:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $35
80107e88:	6a 23                	push   $0x23
  jmp alltraps
80107e8a:	e9 f2 f5 ff ff       	jmp    80107481 <alltraps>

80107e8f <vector36>:
.globl vector36
vector36:
  pushl $0
80107e8f:	6a 00                	push   $0x0
  pushl $36
80107e91:	6a 24                	push   $0x24
  jmp alltraps
80107e93:	e9 e9 f5 ff ff       	jmp    80107481 <alltraps>

80107e98 <vector37>:
.globl vector37
vector37:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $37
80107e9a:	6a 25                	push   $0x25
  jmp alltraps
80107e9c:	e9 e0 f5 ff ff       	jmp    80107481 <alltraps>

80107ea1 <vector38>:
.globl vector38
vector38:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $38
80107ea3:	6a 26                	push   $0x26
  jmp alltraps
80107ea5:	e9 d7 f5 ff ff       	jmp    80107481 <alltraps>

80107eaa <vector39>:
.globl vector39
vector39:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $39
80107eac:	6a 27                	push   $0x27
  jmp alltraps
80107eae:	e9 ce f5 ff ff       	jmp    80107481 <alltraps>

80107eb3 <vector40>:
.globl vector40
vector40:
  pushl $0
80107eb3:	6a 00                	push   $0x0
  pushl $40
80107eb5:	6a 28                	push   $0x28
  jmp alltraps
80107eb7:	e9 c5 f5 ff ff       	jmp    80107481 <alltraps>

80107ebc <vector41>:
.globl vector41
vector41:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $41
80107ebe:	6a 29                	push   $0x29
  jmp alltraps
80107ec0:	e9 bc f5 ff ff       	jmp    80107481 <alltraps>

80107ec5 <vector42>:
.globl vector42
vector42:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $42
80107ec7:	6a 2a                	push   $0x2a
  jmp alltraps
80107ec9:	e9 b3 f5 ff ff       	jmp    80107481 <alltraps>

80107ece <vector43>:
.globl vector43
vector43:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $43
80107ed0:	6a 2b                	push   $0x2b
  jmp alltraps
80107ed2:	e9 aa f5 ff ff       	jmp    80107481 <alltraps>

80107ed7 <vector44>:
.globl vector44
vector44:
  pushl $0
80107ed7:	6a 00                	push   $0x0
  pushl $44
80107ed9:	6a 2c                	push   $0x2c
  jmp alltraps
80107edb:	e9 a1 f5 ff ff       	jmp    80107481 <alltraps>

80107ee0 <vector45>:
.globl vector45
vector45:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $45
80107ee2:	6a 2d                	push   $0x2d
  jmp alltraps
80107ee4:	e9 98 f5 ff ff       	jmp    80107481 <alltraps>

80107ee9 <vector46>:
.globl vector46
vector46:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $46
80107eeb:	6a 2e                	push   $0x2e
  jmp alltraps
80107eed:	e9 8f f5 ff ff       	jmp    80107481 <alltraps>

80107ef2 <vector47>:
.globl vector47
vector47:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $47
80107ef4:	6a 2f                	push   $0x2f
  jmp alltraps
80107ef6:	e9 86 f5 ff ff       	jmp    80107481 <alltraps>

80107efb <vector48>:
.globl vector48
vector48:
  pushl $0
80107efb:	6a 00                	push   $0x0
  pushl $48
80107efd:	6a 30                	push   $0x30
  jmp alltraps
80107eff:	e9 7d f5 ff ff       	jmp    80107481 <alltraps>

80107f04 <vector49>:
.globl vector49
vector49:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $49
80107f06:	6a 31                	push   $0x31
  jmp alltraps
80107f08:	e9 74 f5 ff ff       	jmp    80107481 <alltraps>

80107f0d <vector50>:
.globl vector50
vector50:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $50
80107f0f:	6a 32                	push   $0x32
  jmp alltraps
80107f11:	e9 6b f5 ff ff       	jmp    80107481 <alltraps>

80107f16 <vector51>:
.globl vector51
vector51:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $51
80107f18:	6a 33                	push   $0x33
  jmp alltraps
80107f1a:	e9 62 f5 ff ff       	jmp    80107481 <alltraps>

80107f1f <vector52>:
.globl vector52
vector52:
  pushl $0
80107f1f:	6a 00                	push   $0x0
  pushl $52
80107f21:	6a 34                	push   $0x34
  jmp alltraps
80107f23:	e9 59 f5 ff ff       	jmp    80107481 <alltraps>

80107f28 <vector53>:
.globl vector53
vector53:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $53
80107f2a:	6a 35                	push   $0x35
  jmp alltraps
80107f2c:	e9 50 f5 ff ff       	jmp    80107481 <alltraps>

80107f31 <vector54>:
.globl vector54
vector54:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $54
80107f33:	6a 36                	push   $0x36
  jmp alltraps
80107f35:	e9 47 f5 ff ff       	jmp    80107481 <alltraps>

80107f3a <vector55>:
.globl vector55
vector55:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $55
80107f3c:	6a 37                	push   $0x37
  jmp alltraps
80107f3e:	e9 3e f5 ff ff       	jmp    80107481 <alltraps>

80107f43 <vector56>:
.globl vector56
vector56:
  pushl $0
80107f43:	6a 00                	push   $0x0
  pushl $56
80107f45:	6a 38                	push   $0x38
  jmp alltraps
80107f47:	e9 35 f5 ff ff       	jmp    80107481 <alltraps>

80107f4c <vector57>:
.globl vector57
vector57:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $57
80107f4e:	6a 39                	push   $0x39
  jmp alltraps
80107f50:	e9 2c f5 ff ff       	jmp    80107481 <alltraps>

80107f55 <vector58>:
.globl vector58
vector58:
  pushl $0
80107f55:	6a 00                	push   $0x0
  pushl $58
80107f57:	6a 3a                	push   $0x3a
  jmp alltraps
80107f59:	e9 23 f5 ff ff       	jmp    80107481 <alltraps>

80107f5e <vector59>:
.globl vector59
vector59:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $59
80107f60:	6a 3b                	push   $0x3b
  jmp alltraps
80107f62:	e9 1a f5 ff ff       	jmp    80107481 <alltraps>

80107f67 <vector60>:
.globl vector60
vector60:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $60
80107f69:	6a 3c                	push   $0x3c
  jmp alltraps
80107f6b:	e9 11 f5 ff ff       	jmp    80107481 <alltraps>

80107f70 <vector61>:
.globl vector61
vector61:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $61
80107f72:	6a 3d                	push   $0x3d
  jmp alltraps
80107f74:	e9 08 f5 ff ff       	jmp    80107481 <alltraps>

80107f79 <vector62>:
.globl vector62
vector62:
  pushl $0
80107f79:	6a 00                	push   $0x0
  pushl $62
80107f7b:	6a 3e                	push   $0x3e
  jmp alltraps
80107f7d:	e9 ff f4 ff ff       	jmp    80107481 <alltraps>

80107f82 <vector63>:
.globl vector63
vector63:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $63
80107f84:	6a 3f                	push   $0x3f
  jmp alltraps
80107f86:	e9 f6 f4 ff ff       	jmp    80107481 <alltraps>

80107f8b <vector64>:
.globl vector64
vector64:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $64
80107f8d:	6a 40                	push   $0x40
  jmp alltraps
80107f8f:	e9 ed f4 ff ff       	jmp    80107481 <alltraps>

80107f94 <vector65>:
.globl vector65
vector65:
  pushl $0
80107f94:	6a 00                	push   $0x0
  pushl $65
80107f96:	6a 41                	push   $0x41
  jmp alltraps
80107f98:	e9 e4 f4 ff ff       	jmp    80107481 <alltraps>

80107f9d <vector66>:
.globl vector66
vector66:
  pushl $0
80107f9d:	6a 00                	push   $0x0
  pushl $66
80107f9f:	6a 42                	push   $0x42
  jmp alltraps
80107fa1:	e9 db f4 ff ff       	jmp    80107481 <alltraps>

80107fa6 <vector67>:
.globl vector67
vector67:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $67
80107fa8:	6a 43                	push   $0x43
  jmp alltraps
80107faa:	e9 d2 f4 ff ff       	jmp    80107481 <alltraps>

80107faf <vector68>:
.globl vector68
vector68:
  pushl $0
80107faf:	6a 00                	push   $0x0
  pushl $68
80107fb1:	6a 44                	push   $0x44
  jmp alltraps
80107fb3:	e9 c9 f4 ff ff       	jmp    80107481 <alltraps>

80107fb8 <vector69>:
.globl vector69
vector69:
  pushl $0
80107fb8:	6a 00                	push   $0x0
  pushl $69
80107fba:	6a 45                	push   $0x45
  jmp alltraps
80107fbc:	e9 c0 f4 ff ff       	jmp    80107481 <alltraps>

80107fc1 <vector70>:
.globl vector70
vector70:
  pushl $0
80107fc1:	6a 00                	push   $0x0
  pushl $70
80107fc3:	6a 46                	push   $0x46
  jmp alltraps
80107fc5:	e9 b7 f4 ff ff       	jmp    80107481 <alltraps>

80107fca <vector71>:
.globl vector71
vector71:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $71
80107fcc:	6a 47                	push   $0x47
  jmp alltraps
80107fce:	e9 ae f4 ff ff       	jmp    80107481 <alltraps>

80107fd3 <vector72>:
.globl vector72
vector72:
  pushl $0
80107fd3:	6a 00                	push   $0x0
  pushl $72
80107fd5:	6a 48                	push   $0x48
  jmp alltraps
80107fd7:	e9 a5 f4 ff ff       	jmp    80107481 <alltraps>

80107fdc <vector73>:
.globl vector73
vector73:
  pushl $0
80107fdc:	6a 00                	push   $0x0
  pushl $73
80107fde:	6a 49                	push   $0x49
  jmp alltraps
80107fe0:	e9 9c f4 ff ff       	jmp    80107481 <alltraps>

80107fe5 <vector74>:
.globl vector74
vector74:
  pushl $0
80107fe5:	6a 00                	push   $0x0
  pushl $74
80107fe7:	6a 4a                	push   $0x4a
  jmp alltraps
80107fe9:	e9 93 f4 ff ff       	jmp    80107481 <alltraps>

80107fee <vector75>:
.globl vector75
vector75:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $75
80107ff0:	6a 4b                	push   $0x4b
  jmp alltraps
80107ff2:	e9 8a f4 ff ff       	jmp    80107481 <alltraps>

80107ff7 <vector76>:
.globl vector76
vector76:
  pushl $0
80107ff7:	6a 00                	push   $0x0
  pushl $76
80107ff9:	6a 4c                	push   $0x4c
  jmp alltraps
80107ffb:	e9 81 f4 ff ff       	jmp    80107481 <alltraps>

80108000 <vector77>:
.globl vector77
vector77:
  pushl $0
80108000:	6a 00                	push   $0x0
  pushl $77
80108002:	6a 4d                	push   $0x4d
  jmp alltraps
80108004:	e9 78 f4 ff ff       	jmp    80107481 <alltraps>

80108009 <vector78>:
.globl vector78
vector78:
  pushl $0
80108009:	6a 00                	push   $0x0
  pushl $78
8010800b:	6a 4e                	push   $0x4e
  jmp alltraps
8010800d:	e9 6f f4 ff ff       	jmp    80107481 <alltraps>

80108012 <vector79>:
.globl vector79
vector79:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $79
80108014:	6a 4f                	push   $0x4f
  jmp alltraps
80108016:	e9 66 f4 ff ff       	jmp    80107481 <alltraps>

8010801b <vector80>:
.globl vector80
vector80:
  pushl $0
8010801b:	6a 00                	push   $0x0
  pushl $80
8010801d:	6a 50                	push   $0x50
  jmp alltraps
8010801f:	e9 5d f4 ff ff       	jmp    80107481 <alltraps>

80108024 <vector81>:
.globl vector81
vector81:
  pushl $0
80108024:	6a 00                	push   $0x0
  pushl $81
80108026:	6a 51                	push   $0x51
  jmp alltraps
80108028:	e9 54 f4 ff ff       	jmp    80107481 <alltraps>

8010802d <vector82>:
.globl vector82
vector82:
  pushl $0
8010802d:	6a 00                	push   $0x0
  pushl $82
8010802f:	6a 52                	push   $0x52
  jmp alltraps
80108031:	e9 4b f4 ff ff       	jmp    80107481 <alltraps>

80108036 <vector83>:
.globl vector83
vector83:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $83
80108038:	6a 53                	push   $0x53
  jmp alltraps
8010803a:	e9 42 f4 ff ff       	jmp    80107481 <alltraps>

8010803f <vector84>:
.globl vector84
vector84:
  pushl $0
8010803f:	6a 00                	push   $0x0
  pushl $84
80108041:	6a 54                	push   $0x54
  jmp alltraps
80108043:	e9 39 f4 ff ff       	jmp    80107481 <alltraps>

80108048 <vector85>:
.globl vector85
vector85:
  pushl $0
80108048:	6a 00                	push   $0x0
  pushl $85
8010804a:	6a 55                	push   $0x55
  jmp alltraps
8010804c:	e9 30 f4 ff ff       	jmp    80107481 <alltraps>

80108051 <vector86>:
.globl vector86
vector86:
  pushl $0
80108051:	6a 00                	push   $0x0
  pushl $86
80108053:	6a 56                	push   $0x56
  jmp alltraps
80108055:	e9 27 f4 ff ff       	jmp    80107481 <alltraps>

8010805a <vector87>:
.globl vector87
vector87:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $87
8010805c:	6a 57                	push   $0x57
  jmp alltraps
8010805e:	e9 1e f4 ff ff       	jmp    80107481 <alltraps>

80108063 <vector88>:
.globl vector88
vector88:
  pushl $0
80108063:	6a 00                	push   $0x0
  pushl $88
80108065:	6a 58                	push   $0x58
  jmp alltraps
80108067:	e9 15 f4 ff ff       	jmp    80107481 <alltraps>

8010806c <vector89>:
.globl vector89
vector89:
  pushl $0
8010806c:	6a 00                	push   $0x0
  pushl $89
8010806e:	6a 59                	push   $0x59
  jmp alltraps
80108070:	e9 0c f4 ff ff       	jmp    80107481 <alltraps>

80108075 <vector90>:
.globl vector90
vector90:
  pushl $0
80108075:	6a 00                	push   $0x0
  pushl $90
80108077:	6a 5a                	push   $0x5a
  jmp alltraps
80108079:	e9 03 f4 ff ff       	jmp    80107481 <alltraps>

8010807e <vector91>:
.globl vector91
vector91:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $91
80108080:	6a 5b                	push   $0x5b
  jmp alltraps
80108082:	e9 fa f3 ff ff       	jmp    80107481 <alltraps>

80108087 <vector92>:
.globl vector92
vector92:
  pushl $0
80108087:	6a 00                	push   $0x0
  pushl $92
80108089:	6a 5c                	push   $0x5c
  jmp alltraps
8010808b:	e9 f1 f3 ff ff       	jmp    80107481 <alltraps>

80108090 <vector93>:
.globl vector93
vector93:
  pushl $0
80108090:	6a 00                	push   $0x0
  pushl $93
80108092:	6a 5d                	push   $0x5d
  jmp alltraps
80108094:	e9 e8 f3 ff ff       	jmp    80107481 <alltraps>

80108099 <vector94>:
.globl vector94
vector94:
  pushl $0
80108099:	6a 00                	push   $0x0
  pushl $94
8010809b:	6a 5e                	push   $0x5e
  jmp alltraps
8010809d:	e9 df f3 ff ff       	jmp    80107481 <alltraps>

801080a2 <vector95>:
.globl vector95
vector95:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $95
801080a4:	6a 5f                	push   $0x5f
  jmp alltraps
801080a6:	e9 d6 f3 ff ff       	jmp    80107481 <alltraps>

801080ab <vector96>:
.globl vector96
vector96:
  pushl $0
801080ab:	6a 00                	push   $0x0
  pushl $96
801080ad:	6a 60                	push   $0x60
  jmp alltraps
801080af:	e9 cd f3 ff ff       	jmp    80107481 <alltraps>

801080b4 <vector97>:
.globl vector97
vector97:
  pushl $0
801080b4:	6a 00                	push   $0x0
  pushl $97
801080b6:	6a 61                	push   $0x61
  jmp alltraps
801080b8:	e9 c4 f3 ff ff       	jmp    80107481 <alltraps>

801080bd <vector98>:
.globl vector98
vector98:
  pushl $0
801080bd:	6a 00                	push   $0x0
  pushl $98
801080bf:	6a 62                	push   $0x62
  jmp alltraps
801080c1:	e9 bb f3 ff ff       	jmp    80107481 <alltraps>

801080c6 <vector99>:
.globl vector99
vector99:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $99
801080c8:	6a 63                	push   $0x63
  jmp alltraps
801080ca:	e9 b2 f3 ff ff       	jmp    80107481 <alltraps>

801080cf <vector100>:
.globl vector100
vector100:
  pushl $0
801080cf:	6a 00                	push   $0x0
  pushl $100
801080d1:	6a 64                	push   $0x64
  jmp alltraps
801080d3:	e9 a9 f3 ff ff       	jmp    80107481 <alltraps>

801080d8 <vector101>:
.globl vector101
vector101:
  pushl $0
801080d8:	6a 00                	push   $0x0
  pushl $101
801080da:	6a 65                	push   $0x65
  jmp alltraps
801080dc:	e9 a0 f3 ff ff       	jmp    80107481 <alltraps>

801080e1 <vector102>:
.globl vector102
vector102:
  pushl $0
801080e1:	6a 00                	push   $0x0
  pushl $102
801080e3:	6a 66                	push   $0x66
  jmp alltraps
801080e5:	e9 97 f3 ff ff       	jmp    80107481 <alltraps>

801080ea <vector103>:
.globl vector103
vector103:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $103
801080ec:	6a 67                	push   $0x67
  jmp alltraps
801080ee:	e9 8e f3 ff ff       	jmp    80107481 <alltraps>

801080f3 <vector104>:
.globl vector104
vector104:
  pushl $0
801080f3:	6a 00                	push   $0x0
  pushl $104
801080f5:	6a 68                	push   $0x68
  jmp alltraps
801080f7:	e9 85 f3 ff ff       	jmp    80107481 <alltraps>

801080fc <vector105>:
.globl vector105
vector105:
  pushl $0
801080fc:	6a 00                	push   $0x0
  pushl $105
801080fe:	6a 69                	push   $0x69
  jmp alltraps
80108100:	e9 7c f3 ff ff       	jmp    80107481 <alltraps>

80108105 <vector106>:
.globl vector106
vector106:
  pushl $0
80108105:	6a 00                	push   $0x0
  pushl $106
80108107:	6a 6a                	push   $0x6a
  jmp alltraps
80108109:	e9 73 f3 ff ff       	jmp    80107481 <alltraps>

8010810e <vector107>:
.globl vector107
vector107:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $107
80108110:	6a 6b                	push   $0x6b
  jmp alltraps
80108112:	e9 6a f3 ff ff       	jmp    80107481 <alltraps>

80108117 <vector108>:
.globl vector108
vector108:
  pushl $0
80108117:	6a 00                	push   $0x0
  pushl $108
80108119:	6a 6c                	push   $0x6c
  jmp alltraps
8010811b:	e9 61 f3 ff ff       	jmp    80107481 <alltraps>

80108120 <vector109>:
.globl vector109
vector109:
  pushl $0
80108120:	6a 00                	push   $0x0
  pushl $109
80108122:	6a 6d                	push   $0x6d
  jmp alltraps
80108124:	e9 58 f3 ff ff       	jmp    80107481 <alltraps>

80108129 <vector110>:
.globl vector110
vector110:
  pushl $0
80108129:	6a 00                	push   $0x0
  pushl $110
8010812b:	6a 6e                	push   $0x6e
  jmp alltraps
8010812d:	e9 4f f3 ff ff       	jmp    80107481 <alltraps>

80108132 <vector111>:
.globl vector111
vector111:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $111
80108134:	6a 6f                	push   $0x6f
  jmp alltraps
80108136:	e9 46 f3 ff ff       	jmp    80107481 <alltraps>

8010813b <vector112>:
.globl vector112
vector112:
  pushl $0
8010813b:	6a 00                	push   $0x0
  pushl $112
8010813d:	6a 70                	push   $0x70
  jmp alltraps
8010813f:	e9 3d f3 ff ff       	jmp    80107481 <alltraps>

80108144 <vector113>:
.globl vector113
vector113:
  pushl $0
80108144:	6a 00                	push   $0x0
  pushl $113
80108146:	6a 71                	push   $0x71
  jmp alltraps
80108148:	e9 34 f3 ff ff       	jmp    80107481 <alltraps>

8010814d <vector114>:
.globl vector114
vector114:
  pushl $0
8010814d:	6a 00                	push   $0x0
  pushl $114
8010814f:	6a 72                	push   $0x72
  jmp alltraps
80108151:	e9 2b f3 ff ff       	jmp    80107481 <alltraps>

80108156 <vector115>:
.globl vector115
vector115:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $115
80108158:	6a 73                	push   $0x73
  jmp alltraps
8010815a:	e9 22 f3 ff ff       	jmp    80107481 <alltraps>

8010815f <vector116>:
.globl vector116
vector116:
  pushl $0
8010815f:	6a 00                	push   $0x0
  pushl $116
80108161:	6a 74                	push   $0x74
  jmp alltraps
80108163:	e9 19 f3 ff ff       	jmp    80107481 <alltraps>

80108168 <vector117>:
.globl vector117
vector117:
  pushl $0
80108168:	6a 00                	push   $0x0
  pushl $117
8010816a:	6a 75                	push   $0x75
  jmp alltraps
8010816c:	e9 10 f3 ff ff       	jmp    80107481 <alltraps>

80108171 <vector118>:
.globl vector118
vector118:
  pushl $0
80108171:	6a 00                	push   $0x0
  pushl $118
80108173:	6a 76                	push   $0x76
  jmp alltraps
80108175:	e9 07 f3 ff ff       	jmp    80107481 <alltraps>

8010817a <vector119>:
.globl vector119
vector119:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $119
8010817c:	6a 77                	push   $0x77
  jmp alltraps
8010817e:	e9 fe f2 ff ff       	jmp    80107481 <alltraps>

80108183 <vector120>:
.globl vector120
vector120:
  pushl $0
80108183:	6a 00                	push   $0x0
  pushl $120
80108185:	6a 78                	push   $0x78
  jmp alltraps
80108187:	e9 f5 f2 ff ff       	jmp    80107481 <alltraps>

8010818c <vector121>:
.globl vector121
vector121:
  pushl $0
8010818c:	6a 00                	push   $0x0
  pushl $121
8010818e:	6a 79                	push   $0x79
  jmp alltraps
80108190:	e9 ec f2 ff ff       	jmp    80107481 <alltraps>

80108195 <vector122>:
.globl vector122
vector122:
  pushl $0
80108195:	6a 00                	push   $0x0
  pushl $122
80108197:	6a 7a                	push   $0x7a
  jmp alltraps
80108199:	e9 e3 f2 ff ff       	jmp    80107481 <alltraps>

8010819e <vector123>:
.globl vector123
vector123:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $123
801081a0:	6a 7b                	push   $0x7b
  jmp alltraps
801081a2:	e9 da f2 ff ff       	jmp    80107481 <alltraps>

801081a7 <vector124>:
.globl vector124
vector124:
  pushl $0
801081a7:	6a 00                	push   $0x0
  pushl $124
801081a9:	6a 7c                	push   $0x7c
  jmp alltraps
801081ab:	e9 d1 f2 ff ff       	jmp    80107481 <alltraps>

801081b0 <vector125>:
.globl vector125
vector125:
  pushl $0
801081b0:	6a 00                	push   $0x0
  pushl $125
801081b2:	6a 7d                	push   $0x7d
  jmp alltraps
801081b4:	e9 c8 f2 ff ff       	jmp    80107481 <alltraps>

801081b9 <vector126>:
.globl vector126
vector126:
  pushl $0
801081b9:	6a 00                	push   $0x0
  pushl $126
801081bb:	6a 7e                	push   $0x7e
  jmp alltraps
801081bd:	e9 bf f2 ff ff       	jmp    80107481 <alltraps>

801081c2 <vector127>:
.globl vector127
vector127:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $127
801081c4:	6a 7f                	push   $0x7f
  jmp alltraps
801081c6:	e9 b6 f2 ff ff       	jmp    80107481 <alltraps>

801081cb <vector128>:
.globl vector128
vector128:
  pushl $0
801081cb:	6a 00                	push   $0x0
  pushl $128
801081cd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801081d2:	e9 aa f2 ff ff       	jmp    80107481 <alltraps>

801081d7 <vector129>:
.globl vector129
vector129:
  pushl $0
801081d7:	6a 00                	push   $0x0
  pushl $129
801081d9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801081de:	e9 9e f2 ff ff       	jmp    80107481 <alltraps>

801081e3 <vector130>:
.globl vector130
vector130:
  pushl $0
801081e3:	6a 00                	push   $0x0
  pushl $130
801081e5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801081ea:	e9 92 f2 ff ff       	jmp    80107481 <alltraps>

801081ef <vector131>:
.globl vector131
vector131:
  pushl $0
801081ef:	6a 00                	push   $0x0
  pushl $131
801081f1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801081f6:	e9 86 f2 ff ff       	jmp    80107481 <alltraps>

801081fb <vector132>:
.globl vector132
vector132:
  pushl $0
801081fb:	6a 00                	push   $0x0
  pushl $132
801081fd:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108202:	e9 7a f2 ff ff       	jmp    80107481 <alltraps>

80108207 <vector133>:
.globl vector133
vector133:
  pushl $0
80108207:	6a 00                	push   $0x0
  pushl $133
80108209:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010820e:	e9 6e f2 ff ff       	jmp    80107481 <alltraps>

80108213 <vector134>:
.globl vector134
vector134:
  pushl $0
80108213:	6a 00                	push   $0x0
  pushl $134
80108215:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010821a:	e9 62 f2 ff ff       	jmp    80107481 <alltraps>

8010821f <vector135>:
.globl vector135
vector135:
  pushl $0
8010821f:	6a 00                	push   $0x0
  pushl $135
80108221:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108226:	e9 56 f2 ff ff       	jmp    80107481 <alltraps>

8010822b <vector136>:
.globl vector136
vector136:
  pushl $0
8010822b:	6a 00                	push   $0x0
  pushl $136
8010822d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108232:	e9 4a f2 ff ff       	jmp    80107481 <alltraps>

80108237 <vector137>:
.globl vector137
vector137:
  pushl $0
80108237:	6a 00                	push   $0x0
  pushl $137
80108239:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010823e:	e9 3e f2 ff ff       	jmp    80107481 <alltraps>

80108243 <vector138>:
.globl vector138
vector138:
  pushl $0
80108243:	6a 00                	push   $0x0
  pushl $138
80108245:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010824a:	e9 32 f2 ff ff       	jmp    80107481 <alltraps>

8010824f <vector139>:
.globl vector139
vector139:
  pushl $0
8010824f:	6a 00                	push   $0x0
  pushl $139
80108251:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108256:	e9 26 f2 ff ff       	jmp    80107481 <alltraps>

8010825b <vector140>:
.globl vector140
vector140:
  pushl $0
8010825b:	6a 00                	push   $0x0
  pushl $140
8010825d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108262:	e9 1a f2 ff ff       	jmp    80107481 <alltraps>

80108267 <vector141>:
.globl vector141
vector141:
  pushl $0
80108267:	6a 00                	push   $0x0
  pushl $141
80108269:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010826e:	e9 0e f2 ff ff       	jmp    80107481 <alltraps>

80108273 <vector142>:
.globl vector142
vector142:
  pushl $0
80108273:	6a 00                	push   $0x0
  pushl $142
80108275:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010827a:	e9 02 f2 ff ff       	jmp    80107481 <alltraps>

8010827f <vector143>:
.globl vector143
vector143:
  pushl $0
8010827f:	6a 00                	push   $0x0
  pushl $143
80108281:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108286:	e9 f6 f1 ff ff       	jmp    80107481 <alltraps>

8010828b <vector144>:
.globl vector144
vector144:
  pushl $0
8010828b:	6a 00                	push   $0x0
  pushl $144
8010828d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108292:	e9 ea f1 ff ff       	jmp    80107481 <alltraps>

80108297 <vector145>:
.globl vector145
vector145:
  pushl $0
80108297:	6a 00                	push   $0x0
  pushl $145
80108299:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010829e:	e9 de f1 ff ff       	jmp    80107481 <alltraps>

801082a3 <vector146>:
.globl vector146
vector146:
  pushl $0
801082a3:	6a 00                	push   $0x0
  pushl $146
801082a5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801082aa:	e9 d2 f1 ff ff       	jmp    80107481 <alltraps>

801082af <vector147>:
.globl vector147
vector147:
  pushl $0
801082af:	6a 00                	push   $0x0
  pushl $147
801082b1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801082b6:	e9 c6 f1 ff ff       	jmp    80107481 <alltraps>

801082bb <vector148>:
.globl vector148
vector148:
  pushl $0
801082bb:	6a 00                	push   $0x0
  pushl $148
801082bd:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801082c2:	e9 ba f1 ff ff       	jmp    80107481 <alltraps>

801082c7 <vector149>:
.globl vector149
vector149:
  pushl $0
801082c7:	6a 00                	push   $0x0
  pushl $149
801082c9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801082ce:	e9 ae f1 ff ff       	jmp    80107481 <alltraps>

801082d3 <vector150>:
.globl vector150
vector150:
  pushl $0
801082d3:	6a 00                	push   $0x0
  pushl $150
801082d5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801082da:	e9 a2 f1 ff ff       	jmp    80107481 <alltraps>

801082df <vector151>:
.globl vector151
vector151:
  pushl $0
801082df:	6a 00                	push   $0x0
  pushl $151
801082e1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801082e6:	e9 96 f1 ff ff       	jmp    80107481 <alltraps>

801082eb <vector152>:
.globl vector152
vector152:
  pushl $0
801082eb:	6a 00                	push   $0x0
  pushl $152
801082ed:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801082f2:	e9 8a f1 ff ff       	jmp    80107481 <alltraps>

801082f7 <vector153>:
.globl vector153
vector153:
  pushl $0
801082f7:	6a 00                	push   $0x0
  pushl $153
801082f9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801082fe:	e9 7e f1 ff ff       	jmp    80107481 <alltraps>

80108303 <vector154>:
.globl vector154
vector154:
  pushl $0
80108303:	6a 00                	push   $0x0
  pushl $154
80108305:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010830a:	e9 72 f1 ff ff       	jmp    80107481 <alltraps>

8010830f <vector155>:
.globl vector155
vector155:
  pushl $0
8010830f:	6a 00                	push   $0x0
  pushl $155
80108311:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108316:	e9 66 f1 ff ff       	jmp    80107481 <alltraps>

8010831b <vector156>:
.globl vector156
vector156:
  pushl $0
8010831b:	6a 00                	push   $0x0
  pushl $156
8010831d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108322:	e9 5a f1 ff ff       	jmp    80107481 <alltraps>

80108327 <vector157>:
.globl vector157
vector157:
  pushl $0
80108327:	6a 00                	push   $0x0
  pushl $157
80108329:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010832e:	e9 4e f1 ff ff       	jmp    80107481 <alltraps>

80108333 <vector158>:
.globl vector158
vector158:
  pushl $0
80108333:	6a 00                	push   $0x0
  pushl $158
80108335:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010833a:	e9 42 f1 ff ff       	jmp    80107481 <alltraps>

8010833f <vector159>:
.globl vector159
vector159:
  pushl $0
8010833f:	6a 00                	push   $0x0
  pushl $159
80108341:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108346:	e9 36 f1 ff ff       	jmp    80107481 <alltraps>

8010834b <vector160>:
.globl vector160
vector160:
  pushl $0
8010834b:	6a 00                	push   $0x0
  pushl $160
8010834d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108352:	e9 2a f1 ff ff       	jmp    80107481 <alltraps>

80108357 <vector161>:
.globl vector161
vector161:
  pushl $0
80108357:	6a 00                	push   $0x0
  pushl $161
80108359:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010835e:	e9 1e f1 ff ff       	jmp    80107481 <alltraps>

80108363 <vector162>:
.globl vector162
vector162:
  pushl $0
80108363:	6a 00                	push   $0x0
  pushl $162
80108365:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010836a:	e9 12 f1 ff ff       	jmp    80107481 <alltraps>

8010836f <vector163>:
.globl vector163
vector163:
  pushl $0
8010836f:	6a 00                	push   $0x0
  pushl $163
80108371:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108376:	e9 06 f1 ff ff       	jmp    80107481 <alltraps>

8010837b <vector164>:
.globl vector164
vector164:
  pushl $0
8010837b:	6a 00                	push   $0x0
  pushl $164
8010837d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108382:	e9 fa f0 ff ff       	jmp    80107481 <alltraps>

80108387 <vector165>:
.globl vector165
vector165:
  pushl $0
80108387:	6a 00                	push   $0x0
  pushl $165
80108389:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010838e:	e9 ee f0 ff ff       	jmp    80107481 <alltraps>

80108393 <vector166>:
.globl vector166
vector166:
  pushl $0
80108393:	6a 00                	push   $0x0
  pushl $166
80108395:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010839a:	e9 e2 f0 ff ff       	jmp    80107481 <alltraps>

8010839f <vector167>:
.globl vector167
vector167:
  pushl $0
8010839f:	6a 00                	push   $0x0
  pushl $167
801083a1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801083a6:	e9 d6 f0 ff ff       	jmp    80107481 <alltraps>

801083ab <vector168>:
.globl vector168
vector168:
  pushl $0
801083ab:	6a 00                	push   $0x0
  pushl $168
801083ad:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801083b2:	e9 ca f0 ff ff       	jmp    80107481 <alltraps>

801083b7 <vector169>:
.globl vector169
vector169:
  pushl $0
801083b7:	6a 00                	push   $0x0
  pushl $169
801083b9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801083be:	e9 be f0 ff ff       	jmp    80107481 <alltraps>

801083c3 <vector170>:
.globl vector170
vector170:
  pushl $0
801083c3:	6a 00                	push   $0x0
  pushl $170
801083c5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801083ca:	e9 b2 f0 ff ff       	jmp    80107481 <alltraps>

801083cf <vector171>:
.globl vector171
vector171:
  pushl $0
801083cf:	6a 00                	push   $0x0
  pushl $171
801083d1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801083d6:	e9 a6 f0 ff ff       	jmp    80107481 <alltraps>

801083db <vector172>:
.globl vector172
vector172:
  pushl $0
801083db:	6a 00                	push   $0x0
  pushl $172
801083dd:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801083e2:	e9 9a f0 ff ff       	jmp    80107481 <alltraps>

801083e7 <vector173>:
.globl vector173
vector173:
  pushl $0
801083e7:	6a 00                	push   $0x0
  pushl $173
801083e9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801083ee:	e9 8e f0 ff ff       	jmp    80107481 <alltraps>

801083f3 <vector174>:
.globl vector174
vector174:
  pushl $0
801083f3:	6a 00                	push   $0x0
  pushl $174
801083f5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801083fa:	e9 82 f0 ff ff       	jmp    80107481 <alltraps>

801083ff <vector175>:
.globl vector175
vector175:
  pushl $0
801083ff:	6a 00                	push   $0x0
  pushl $175
80108401:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108406:	e9 76 f0 ff ff       	jmp    80107481 <alltraps>

8010840b <vector176>:
.globl vector176
vector176:
  pushl $0
8010840b:	6a 00                	push   $0x0
  pushl $176
8010840d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108412:	e9 6a f0 ff ff       	jmp    80107481 <alltraps>

80108417 <vector177>:
.globl vector177
vector177:
  pushl $0
80108417:	6a 00                	push   $0x0
  pushl $177
80108419:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010841e:	e9 5e f0 ff ff       	jmp    80107481 <alltraps>

80108423 <vector178>:
.globl vector178
vector178:
  pushl $0
80108423:	6a 00                	push   $0x0
  pushl $178
80108425:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010842a:	e9 52 f0 ff ff       	jmp    80107481 <alltraps>

8010842f <vector179>:
.globl vector179
vector179:
  pushl $0
8010842f:	6a 00                	push   $0x0
  pushl $179
80108431:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108436:	e9 46 f0 ff ff       	jmp    80107481 <alltraps>

8010843b <vector180>:
.globl vector180
vector180:
  pushl $0
8010843b:	6a 00                	push   $0x0
  pushl $180
8010843d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108442:	e9 3a f0 ff ff       	jmp    80107481 <alltraps>

80108447 <vector181>:
.globl vector181
vector181:
  pushl $0
80108447:	6a 00                	push   $0x0
  pushl $181
80108449:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010844e:	e9 2e f0 ff ff       	jmp    80107481 <alltraps>

80108453 <vector182>:
.globl vector182
vector182:
  pushl $0
80108453:	6a 00                	push   $0x0
  pushl $182
80108455:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010845a:	e9 22 f0 ff ff       	jmp    80107481 <alltraps>

8010845f <vector183>:
.globl vector183
vector183:
  pushl $0
8010845f:	6a 00                	push   $0x0
  pushl $183
80108461:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108466:	e9 16 f0 ff ff       	jmp    80107481 <alltraps>

8010846b <vector184>:
.globl vector184
vector184:
  pushl $0
8010846b:	6a 00                	push   $0x0
  pushl $184
8010846d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108472:	e9 0a f0 ff ff       	jmp    80107481 <alltraps>

80108477 <vector185>:
.globl vector185
vector185:
  pushl $0
80108477:	6a 00                	push   $0x0
  pushl $185
80108479:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010847e:	e9 fe ef ff ff       	jmp    80107481 <alltraps>

80108483 <vector186>:
.globl vector186
vector186:
  pushl $0
80108483:	6a 00                	push   $0x0
  pushl $186
80108485:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010848a:	e9 f2 ef ff ff       	jmp    80107481 <alltraps>

8010848f <vector187>:
.globl vector187
vector187:
  pushl $0
8010848f:	6a 00                	push   $0x0
  pushl $187
80108491:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108496:	e9 e6 ef ff ff       	jmp    80107481 <alltraps>

8010849b <vector188>:
.globl vector188
vector188:
  pushl $0
8010849b:	6a 00                	push   $0x0
  pushl $188
8010849d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801084a2:	e9 da ef ff ff       	jmp    80107481 <alltraps>

801084a7 <vector189>:
.globl vector189
vector189:
  pushl $0
801084a7:	6a 00                	push   $0x0
  pushl $189
801084a9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801084ae:	e9 ce ef ff ff       	jmp    80107481 <alltraps>

801084b3 <vector190>:
.globl vector190
vector190:
  pushl $0
801084b3:	6a 00                	push   $0x0
  pushl $190
801084b5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801084ba:	e9 c2 ef ff ff       	jmp    80107481 <alltraps>

801084bf <vector191>:
.globl vector191
vector191:
  pushl $0
801084bf:	6a 00                	push   $0x0
  pushl $191
801084c1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801084c6:	e9 b6 ef ff ff       	jmp    80107481 <alltraps>

801084cb <vector192>:
.globl vector192
vector192:
  pushl $0
801084cb:	6a 00                	push   $0x0
  pushl $192
801084cd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801084d2:	e9 aa ef ff ff       	jmp    80107481 <alltraps>

801084d7 <vector193>:
.globl vector193
vector193:
  pushl $0
801084d7:	6a 00                	push   $0x0
  pushl $193
801084d9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801084de:	e9 9e ef ff ff       	jmp    80107481 <alltraps>

801084e3 <vector194>:
.globl vector194
vector194:
  pushl $0
801084e3:	6a 00                	push   $0x0
  pushl $194
801084e5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801084ea:	e9 92 ef ff ff       	jmp    80107481 <alltraps>

801084ef <vector195>:
.globl vector195
vector195:
  pushl $0
801084ef:	6a 00                	push   $0x0
  pushl $195
801084f1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801084f6:	e9 86 ef ff ff       	jmp    80107481 <alltraps>

801084fb <vector196>:
.globl vector196
vector196:
  pushl $0
801084fb:	6a 00                	push   $0x0
  pushl $196
801084fd:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108502:	e9 7a ef ff ff       	jmp    80107481 <alltraps>

80108507 <vector197>:
.globl vector197
vector197:
  pushl $0
80108507:	6a 00                	push   $0x0
  pushl $197
80108509:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010850e:	e9 6e ef ff ff       	jmp    80107481 <alltraps>

80108513 <vector198>:
.globl vector198
vector198:
  pushl $0
80108513:	6a 00                	push   $0x0
  pushl $198
80108515:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010851a:	e9 62 ef ff ff       	jmp    80107481 <alltraps>

8010851f <vector199>:
.globl vector199
vector199:
  pushl $0
8010851f:	6a 00                	push   $0x0
  pushl $199
80108521:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108526:	e9 56 ef ff ff       	jmp    80107481 <alltraps>

8010852b <vector200>:
.globl vector200
vector200:
  pushl $0
8010852b:	6a 00                	push   $0x0
  pushl $200
8010852d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108532:	e9 4a ef ff ff       	jmp    80107481 <alltraps>

80108537 <vector201>:
.globl vector201
vector201:
  pushl $0
80108537:	6a 00                	push   $0x0
  pushl $201
80108539:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010853e:	e9 3e ef ff ff       	jmp    80107481 <alltraps>

80108543 <vector202>:
.globl vector202
vector202:
  pushl $0
80108543:	6a 00                	push   $0x0
  pushl $202
80108545:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010854a:	e9 32 ef ff ff       	jmp    80107481 <alltraps>

8010854f <vector203>:
.globl vector203
vector203:
  pushl $0
8010854f:	6a 00                	push   $0x0
  pushl $203
80108551:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108556:	e9 26 ef ff ff       	jmp    80107481 <alltraps>

8010855b <vector204>:
.globl vector204
vector204:
  pushl $0
8010855b:	6a 00                	push   $0x0
  pushl $204
8010855d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108562:	e9 1a ef ff ff       	jmp    80107481 <alltraps>

80108567 <vector205>:
.globl vector205
vector205:
  pushl $0
80108567:	6a 00                	push   $0x0
  pushl $205
80108569:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010856e:	e9 0e ef ff ff       	jmp    80107481 <alltraps>

80108573 <vector206>:
.globl vector206
vector206:
  pushl $0
80108573:	6a 00                	push   $0x0
  pushl $206
80108575:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010857a:	e9 02 ef ff ff       	jmp    80107481 <alltraps>

8010857f <vector207>:
.globl vector207
vector207:
  pushl $0
8010857f:	6a 00                	push   $0x0
  pushl $207
80108581:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108586:	e9 f6 ee ff ff       	jmp    80107481 <alltraps>

8010858b <vector208>:
.globl vector208
vector208:
  pushl $0
8010858b:	6a 00                	push   $0x0
  pushl $208
8010858d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108592:	e9 ea ee ff ff       	jmp    80107481 <alltraps>

80108597 <vector209>:
.globl vector209
vector209:
  pushl $0
80108597:	6a 00                	push   $0x0
  pushl $209
80108599:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010859e:	e9 de ee ff ff       	jmp    80107481 <alltraps>

801085a3 <vector210>:
.globl vector210
vector210:
  pushl $0
801085a3:	6a 00                	push   $0x0
  pushl $210
801085a5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801085aa:	e9 d2 ee ff ff       	jmp    80107481 <alltraps>

801085af <vector211>:
.globl vector211
vector211:
  pushl $0
801085af:	6a 00                	push   $0x0
  pushl $211
801085b1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801085b6:	e9 c6 ee ff ff       	jmp    80107481 <alltraps>

801085bb <vector212>:
.globl vector212
vector212:
  pushl $0
801085bb:	6a 00                	push   $0x0
  pushl $212
801085bd:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801085c2:	e9 ba ee ff ff       	jmp    80107481 <alltraps>

801085c7 <vector213>:
.globl vector213
vector213:
  pushl $0
801085c7:	6a 00                	push   $0x0
  pushl $213
801085c9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801085ce:	e9 ae ee ff ff       	jmp    80107481 <alltraps>

801085d3 <vector214>:
.globl vector214
vector214:
  pushl $0
801085d3:	6a 00                	push   $0x0
  pushl $214
801085d5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801085da:	e9 a2 ee ff ff       	jmp    80107481 <alltraps>

801085df <vector215>:
.globl vector215
vector215:
  pushl $0
801085df:	6a 00                	push   $0x0
  pushl $215
801085e1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801085e6:	e9 96 ee ff ff       	jmp    80107481 <alltraps>

801085eb <vector216>:
.globl vector216
vector216:
  pushl $0
801085eb:	6a 00                	push   $0x0
  pushl $216
801085ed:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801085f2:	e9 8a ee ff ff       	jmp    80107481 <alltraps>

801085f7 <vector217>:
.globl vector217
vector217:
  pushl $0
801085f7:	6a 00                	push   $0x0
  pushl $217
801085f9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801085fe:	e9 7e ee ff ff       	jmp    80107481 <alltraps>

80108603 <vector218>:
.globl vector218
vector218:
  pushl $0
80108603:	6a 00                	push   $0x0
  pushl $218
80108605:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010860a:	e9 72 ee ff ff       	jmp    80107481 <alltraps>

8010860f <vector219>:
.globl vector219
vector219:
  pushl $0
8010860f:	6a 00                	push   $0x0
  pushl $219
80108611:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108616:	e9 66 ee ff ff       	jmp    80107481 <alltraps>

8010861b <vector220>:
.globl vector220
vector220:
  pushl $0
8010861b:	6a 00                	push   $0x0
  pushl $220
8010861d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108622:	e9 5a ee ff ff       	jmp    80107481 <alltraps>

80108627 <vector221>:
.globl vector221
vector221:
  pushl $0
80108627:	6a 00                	push   $0x0
  pushl $221
80108629:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010862e:	e9 4e ee ff ff       	jmp    80107481 <alltraps>

80108633 <vector222>:
.globl vector222
vector222:
  pushl $0
80108633:	6a 00                	push   $0x0
  pushl $222
80108635:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010863a:	e9 42 ee ff ff       	jmp    80107481 <alltraps>

8010863f <vector223>:
.globl vector223
vector223:
  pushl $0
8010863f:	6a 00                	push   $0x0
  pushl $223
80108641:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108646:	e9 36 ee ff ff       	jmp    80107481 <alltraps>

8010864b <vector224>:
.globl vector224
vector224:
  pushl $0
8010864b:	6a 00                	push   $0x0
  pushl $224
8010864d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108652:	e9 2a ee ff ff       	jmp    80107481 <alltraps>

80108657 <vector225>:
.globl vector225
vector225:
  pushl $0
80108657:	6a 00                	push   $0x0
  pushl $225
80108659:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010865e:	e9 1e ee ff ff       	jmp    80107481 <alltraps>

80108663 <vector226>:
.globl vector226
vector226:
  pushl $0
80108663:	6a 00                	push   $0x0
  pushl $226
80108665:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010866a:	e9 12 ee ff ff       	jmp    80107481 <alltraps>

8010866f <vector227>:
.globl vector227
vector227:
  pushl $0
8010866f:	6a 00                	push   $0x0
  pushl $227
80108671:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108676:	e9 06 ee ff ff       	jmp    80107481 <alltraps>

8010867b <vector228>:
.globl vector228
vector228:
  pushl $0
8010867b:	6a 00                	push   $0x0
  pushl $228
8010867d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108682:	e9 fa ed ff ff       	jmp    80107481 <alltraps>

80108687 <vector229>:
.globl vector229
vector229:
  pushl $0
80108687:	6a 00                	push   $0x0
  pushl $229
80108689:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010868e:	e9 ee ed ff ff       	jmp    80107481 <alltraps>

80108693 <vector230>:
.globl vector230
vector230:
  pushl $0
80108693:	6a 00                	push   $0x0
  pushl $230
80108695:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010869a:	e9 e2 ed ff ff       	jmp    80107481 <alltraps>

8010869f <vector231>:
.globl vector231
vector231:
  pushl $0
8010869f:	6a 00                	push   $0x0
  pushl $231
801086a1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801086a6:	e9 d6 ed ff ff       	jmp    80107481 <alltraps>

801086ab <vector232>:
.globl vector232
vector232:
  pushl $0
801086ab:	6a 00                	push   $0x0
  pushl $232
801086ad:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801086b2:	e9 ca ed ff ff       	jmp    80107481 <alltraps>

801086b7 <vector233>:
.globl vector233
vector233:
  pushl $0
801086b7:	6a 00                	push   $0x0
  pushl $233
801086b9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801086be:	e9 be ed ff ff       	jmp    80107481 <alltraps>

801086c3 <vector234>:
.globl vector234
vector234:
  pushl $0
801086c3:	6a 00                	push   $0x0
  pushl $234
801086c5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801086ca:	e9 b2 ed ff ff       	jmp    80107481 <alltraps>

801086cf <vector235>:
.globl vector235
vector235:
  pushl $0
801086cf:	6a 00                	push   $0x0
  pushl $235
801086d1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801086d6:	e9 a6 ed ff ff       	jmp    80107481 <alltraps>

801086db <vector236>:
.globl vector236
vector236:
  pushl $0
801086db:	6a 00                	push   $0x0
  pushl $236
801086dd:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801086e2:	e9 9a ed ff ff       	jmp    80107481 <alltraps>

801086e7 <vector237>:
.globl vector237
vector237:
  pushl $0
801086e7:	6a 00                	push   $0x0
  pushl $237
801086e9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801086ee:	e9 8e ed ff ff       	jmp    80107481 <alltraps>

801086f3 <vector238>:
.globl vector238
vector238:
  pushl $0
801086f3:	6a 00                	push   $0x0
  pushl $238
801086f5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801086fa:	e9 82 ed ff ff       	jmp    80107481 <alltraps>

801086ff <vector239>:
.globl vector239
vector239:
  pushl $0
801086ff:	6a 00                	push   $0x0
  pushl $239
80108701:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108706:	e9 76 ed ff ff       	jmp    80107481 <alltraps>

8010870b <vector240>:
.globl vector240
vector240:
  pushl $0
8010870b:	6a 00                	push   $0x0
  pushl $240
8010870d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108712:	e9 6a ed ff ff       	jmp    80107481 <alltraps>

80108717 <vector241>:
.globl vector241
vector241:
  pushl $0
80108717:	6a 00                	push   $0x0
  pushl $241
80108719:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010871e:	e9 5e ed ff ff       	jmp    80107481 <alltraps>

80108723 <vector242>:
.globl vector242
vector242:
  pushl $0
80108723:	6a 00                	push   $0x0
  pushl $242
80108725:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010872a:	e9 52 ed ff ff       	jmp    80107481 <alltraps>

8010872f <vector243>:
.globl vector243
vector243:
  pushl $0
8010872f:	6a 00                	push   $0x0
  pushl $243
80108731:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108736:	e9 46 ed ff ff       	jmp    80107481 <alltraps>

8010873b <vector244>:
.globl vector244
vector244:
  pushl $0
8010873b:	6a 00                	push   $0x0
  pushl $244
8010873d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108742:	e9 3a ed ff ff       	jmp    80107481 <alltraps>

80108747 <vector245>:
.globl vector245
vector245:
  pushl $0
80108747:	6a 00                	push   $0x0
  pushl $245
80108749:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010874e:	e9 2e ed ff ff       	jmp    80107481 <alltraps>

80108753 <vector246>:
.globl vector246
vector246:
  pushl $0
80108753:	6a 00                	push   $0x0
  pushl $246
80108755:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010875a:	e9 22 ed ff ff       	jmp    80107481 <alltraps>

8010875f <vector247>:
.globl vector247
vector247:
  pushl $0
8010875f:	6a 00                	push   $0x0
  pushl $247
80108761:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108766:	e9 16 ed ff ff       	jmp    80107481 <alltraps>

8010876b <vector248>:
.globl vector248
vector248:
  pushl $0
8010876b:	6a 00                	push   $0x0
  pushl $248
8010876d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108772:	e9 0a ed ff ff       	jmp    80107481 <alltraps>

80108777 <vector249>:
.globl vector249
vector249:
  pushl $0
80108777:	6a 00                	push   $0x0
  pushl $249
80108779:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010877e:	e9 fe ec ff ff       	jmp    80107481 <alltraps>

80108783 <vector250>:
.globl vector250
vector250:
  pushl $0
80108783:	6a 00                	push   $0x0
  pushl $250
80108785:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010878a:	e9 f2 ec ff ff       	jmp    80107481 <alltraps>

8010878f <vector251>:
.globl vector251
vector251:
  pushl $0
8010878f:	6a 00                	push   $0x0
  pushl $251
80108791:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108796:	e9 e6 ec ff ff       	jmp    80107481 <alltraps>

8010879b <vector252>:
.globl vector252
vector252:
  pushl $0
8010879b:	6a 00                	push   $0x0
  pushl $252
8010879d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801087a2:	e9 da ec ff ff       	jmp    80107481 <alltraps>

801087a7 <vector253>:
.globl vector253
vector253:
  pushl $0
801087a7:	6a 00                	push   $0x0
  pushl $253
801087a9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801087ae:	e9 ce ec ff ff       	jmp    80107481 <alltraps>

801087b3 <vector254>:
.globl vector254
vector254:
  pushl $0
801087b3:	6a 00                	push   $0x0
  pushl $254
801087b5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801087ba:	e9 c2 ec ff ff       	jmp    80107481 <alltraps>

801087bf <vector255>:
.globl vector255
vector255:
  pushl $0
801087bf:	6a 00                	push   $0x0
  pushl $255
801087c1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801087c6:	e9 b6 ec ff ff       	jmp    80107481 <alltraps>

801087cb <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801087cb:	55                   	push   %ebp
801087cc:	89 e5                	mov    %esp,%ebp
801087ce:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801087d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d4:	83 e8 01             	sub    $0x1,%eax
801087d7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801087db:	8b 45 08             	mov    0x8(%ebp),%eax
801087de:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801087e2:	8b 45 08             	mov    0x8(%ebp),%eax
801087e5:	c1 e8 10             	shr    $0x10,%eax
801087e8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801087ec:	8d 45 fa             	lea    -0x6(%ebp),%eax
801087ef:	0f 01 10             	lgdtl  (%eax)
}
801087f2:	90                   	nop
801087f3:	c9                   	leave  
801087f4:	c3                   	ret    

801087f5 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801087f5:	55                   	push   %ebp
801087f6:	89 e5                	mov    %esp,%ebp
801087f8:	83 ec 04             	sub    $0x4,%esp
801087fb:	8b 45 08             	mov    0x8(%ebp),%eax
801087fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108802:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108806:	0f 00 d8             	ltr    %ax
}
80108809:	90                   	nop
8010880a:	c9                   	leave  
8010880b:	c3                   	ret    

8010880c <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010880c:	55                   	push   %ebp
8010880d:	89 e5                	mov    %esp,%ebp
8010880f:	83 ec 04             	sub    $0x4,%esp
80108812:	8b 45 08             	mov    0x8(%ebp),%eax
80108815:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108819:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010881d:	8e e8                	mov    %eax,%gs
}
8010881f:	90                   	nop
80108820:	c9                   	leave  
80108821:	c3                   	ret    

80108822 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108822:	55                   	push   %ebp
80108823:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108825:	8b 45 08             	mov    0x8(%ebp),%eax
80108828:	0f 22 d8             	mov    %eax,%cr3
}
8010882b:	90                   	nop
8010882c:	5d                   	pop    %ebp
8010882d:	c3                   	ret    

8010882e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010882e:	55                   	push   %ebp
8010882f:	89 e5                	mov    %esp,%ebp
80108831:	8b 45 08             	mov    0x8(%ebp),%eax
80108834:	05 00 00 00 80       	add    $0x80000000,%eax
80108839:	5d                   	pop    %ebp
8010883a:	c3                   	ret    

8010883b <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010883b:	55                   	push   %ebp
8010883c:	89 e5                	mov    %esp,%ebp
8010883e:	8b 45 08             	mov    0x8(%ebp),%eax
80108841:	05 00 00 00 80       	add    $0x80000000,%eax
80108846:	5d                   	pop    %ebp
80108847:	c3                   	ret    

80108848 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108848:	55                   	push   %ebp
80108849:	89 e5                	mov    %esp,%ebp
8010884b:	53                   	push   %ebx
8010884c:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010884f:	e8 3a a7 ff ff       	call   80102f8e <cpunum>
80108854:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010885a:	05 80 33 11 80       	add    $0x80113380,%eax
8010885f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108865:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108877:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010887b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108882:	83 e2 f0             	and    $0xfffffff0,%edx
80108885:	83 ca 0a             	or     $0xa,%edx
80108888:	88 50 7d             	mov    %dl,0x7d(%eax)
8010888b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108892:	83 ca 10             	or     $0x10,%edx
80108895:	88 50 7d             	mov    %dl,0x7d(%eax)
80108898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010889f:	83 e2 9f             	and    $0xffffff9f,%edx
801088a2:	88 50 7d             	mov    %dl,0x7d(%eax)
801088a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801088ac:	83 ca 80             	or     $0xffffff80,%edx
801088af:	88 50 7d             	mov    %dl,0x7d(%eax)
801088b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088b9:	83 ca 0f             	or     $0xf,%edx
801088bc:	88 50 7e             	mov    %dl,0x7e(%eax)
801088bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088c6:	83 e2 ef             	and    $0xffffffef,%edx
801088c9:	88 50 7e             	mov    %dl,0x7e(%eax)
801088cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088d3:	83 e2 df             	and    $0xffffffdf,%edx
801088d6:	88 50 7e             	mov    %dl,0x7e(%eax)
801088d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088e0:	83 ca 40             	or     $0x40,%edx
801088e3:	88 50 7e             	mov    %dl,0x7e(%eax)
801088e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801088ed:	83 ca 80             	or     $0xffffff80,%edx
801088f0:	88 50 7e             	mov    %dl,0x7e(%eax)
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801088fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fd:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108904:	ff ff 
80108906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108909:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108910:	00 00 
80108912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108915:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010891c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108926:	83 e2 f0             	and    $0xfffffff0,%edx
80108929:	83 ca 02             	or     $0x2,%edx
8010892c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108935:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010893c:	83 ca 10             	or     $0x10,%edx
8010893f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108948:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010894f:	83 e2 9f             	and    $0xffffff9f,%edx
80108952:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108962:	83 ca 80             	or     $0xffffff80,%edx
80108965:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010896b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108975:	83 ca 0f             	or     $0xf,%edx
80108978:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010897e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108981:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108988:	83 e2 ef             	and    $0xffffffef,%edx
8010898b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108994:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010899b:	83 e2 df             	and    $0xffffffdf,%edx
8010899e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801089a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801089ae:	83 ca 40             	or     $0x40,%edx
801089b1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801089b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ba:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801089c1:	83 ca 80             	or     $0xffffff80,%edx
801089c4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801089ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cd:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801089d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801089de:	ff ff 
801089e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801089ea:	00 00 
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801089f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108a00:	83 e2 f0             	and    $0xfffffff0,%edx
80108a03:	83 ca 0a             	or     $0xa,%edx
80108a06:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108a16:	83 ca 10             	or     $0x10,%edx
80108a19:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a22:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108a29:	83 ca 60             	or     $0x60,%edx
80108a2c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a35:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108a3c:	83 ca 80             	or     $0xffffff80,%edx
80108a3f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a48:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a4f:	83 ca 0f             	or     $0xf,%edx
80108a52:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a62:	83 e2 ef             	and    $0xffffffef,%edx
80108a65:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a75:	83 e2 df             	and    $0xffffffdf,%edx
80108a78:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a81:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a88:	83 ca 40             	or     $0x40,%edx
80108a8b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a94:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a9b:	83 ca 80             	or     $0xffffff80,%edx
80108a9e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab1:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108ab8:	ff ff 
80108aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108abd:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108ac4:	00 00 
80108ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac9:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108ada:	83 e2 f0             	and    $0xfffffff0,%edx
80108add:	83 ca 02             	or     $0x2,%edx
80108ae0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108af0:	83 ca 10             	or     $0x10,%edx
80108af3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108b03:	83 ca 60             	or     $0x60,%edx
80108b06:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108b16:	83 ca 80             	or     $0xffffff80,%edx
80108b19:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b22:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b29:	83 ca 0f             	or     $0xf,%edx
80108b2c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b35:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b3c:	83 e2 ef             	and    $0xffffffef,%edx
80108b3f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b48:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b4f:	83 e2 df             	and    $0xffffffdf,%edx
80108b52:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b62:	83 ca 40             	or     $0x40,%edx
80108b65:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108b75:	83 ca 80             	or     $0xffffff80,%edx
80108b78:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b81:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8b:	05 b4 00 00 00       	add    $0xb4,%eax
80108b90:	89 c3                	mov    %eax,%ebx
80108b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b95:	05 b4 00 00 00       	add    $0xb4,%eax
80108b9a:	c1 e8 10             	shr    $0x10,%eax
80108b9d:	89 c2                	mov    %eax,%edx
80108b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba2:	05 b4 00 00 00       	add    $0xb4,%eax
80108ba7:	c1 e8 18             	shr    $0x18,%eax
80108baa:	89 c1                	mov    %eax,%ecx
80108bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baf:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108bb6:	00 00 
80108bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bbb:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc5:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bce:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108bd5:	83 e2 f0             	and    $0xfffffff0,%edx
80108bd8:	83 ca 02             	or     $0x2,%edx
80108bdb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108beb:	83 ca 10             	or     $0x10,%edx
80108bee:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108bfe:	83 e2 9f             	and    $0xffffff9f,%edx
80108c01:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108c11:	83 ca 80             	or     $0xffffff80,%edx
80108c14:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c24:	83 e2 f0             	and    $0xfffffff0,%edx
80108c27:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c30:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c37:	83 e2 ef             	and    $0xffffffef,%edx
80108c3a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c43:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c4a:	83 e2 df             	and    $0xffffffdf,%edx
80108c4d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c56:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c5d:	83 ca 40             	or     $0x40,%edx
80108c60:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c69:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108c70:	83 ca 80             	or     $0xffffff80,%edx
80108c73:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7c:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c85:	83 c0 70             	add    $0x70,%eax
80108c88:	83 ec 08             	sub    $0x8,%esp
80108c8b:	6a 38                	push   $0x38
80108c8d:	50                   	push   %eax
80108c8e:	e8 38 fb ff ff       	call   801087cb <lgdt>
80108c93:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108c96:	83 ec 0c             	sub    $0xc,%esp
80108c99:	6a 18                	push   $0x18
80108c9b:	e8 6c fb ff ff       	call   8010880c <loadgs>
80108ca0:	83 c4 10             	add    $0x10,%esp

  // Initialize cpu-local storage.
  cpu = c;
80108ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca6:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108cac:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108cb3:	00 00 00 00 
}
80108cb7:	90                   	nop
80108cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cbb:	c9                   	leave  
80108cbc:	c3                   	ret    

80108cbd <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108cbd:	55                   	push   %ebp
80108cbe:	89 e5                	mov    %esp,%ebp
80108cc0:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc6:	c1 e8 16             	shr    $0x16,%eax
80108cc9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd3:	01 d0                	add    %edx,%eax
80108cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cdb:	8b 00                	mov    (%eax),%eax
80108cdd:	83 e0 01             	and    $0x1,%eax
80108ce0:	85 c0                	test   %eax,%eax
80108ce2:	74 18                	je     80108cfc <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ce7:	8b 00                	mov    (%eax),%eax
80108ce9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cee:	50                   	push   %eax
80108cef:	e8 47 fb ff ff       	call   8010883b <p2v>
80108cf4:	83 c4 04             	add    $0x4,%esp
80108cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108cfa:	eb 48                	jmp    80108d44 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108cfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108d00:	74 0e                	je     80108d10 <walkpgdir+0x53>
80108d02:	e8 21 9f ff ff       	call   80102c28 <kalloc>
80108d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108d0e:	75 07                	jne    80108d17 <walkpgdir+0x5a>
      return 0;
80108d10:	b8 00 00 00 00       	mov    $0x0,%eax
80108d15:	eb 44                	jmp    80108d5b <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108d17:	83 ec 04             	sub    $0x4,%esp
80108d1a:	68 00 10 00 00       	push   $0x1000
80108d1f:	6a 00                	push   $0x0
80108d21:	ff 75 f4             	pushl  -0xc(%ebp)
80108d24:	e8 89 d1 ff ff       	call   80105eb2 <memset>
80108d29:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108d2c:	83 ec 0c             	sub    $0xc,%esp
80108d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80108d32:	e8 f7 fa ff ff       	call   8010882e <v2p>
80108d37:	83 c4 10             	add    $0x10,%esp
80108d3a:	83 c8 07             	or     $0x7,%eax
80108d3d:	89 c2                	mov    %eax,%edx
80108d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d42:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d47:	c1 e8 0c             	shr    $0xc,%eax
80108d4a:	25 ff 03 00 00       	and    $0x3ff,%eax
80108d4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d59:	01 d0                	add    %edx,%eax
}
80108d5b:	c9                   	leave  
80108d5c:	c3                   	ret    

80108d5d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108d5d:	55                   	push   %ebp
80108d5e:	89 e5                	mov    %esp,%ebp
80108d60:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d71:	8b 45 10             	mov    0x10(%ebp),%eax
80108d74:	01 d0                	add    %edx,%eax
80108d76:	83 e8 01             	sub    $0x1,%eax
80108d79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108d81:	83 ec 04             	sub    $0x4,%esp
80108d84:	6a 01                	push   $0x1
80108d86:	ff 75 f4             	pushl  -0xc(%ebp)
80108d89:	ff 75 08             	pushl  0x8(%ebp)
80108d8c:	e8 2c ff ff ff       	call   80108cbd <walkpgdir>
80108d91:	83 c4 10             	add    $0x10,%esp
80108d94:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d9b:	75 07                	jne    80108da4 <mappages+0x47>
      return -1;
80108d9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108da2:	eb 47                	jmp    80108deb <mappages+0x8e>
    if(*pte & PTE_P)
80108da4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da7:	8b 00                	mov    (%eax),%eax
80108da9:	83 e0 01             	and    $0x1,%eax
80108dac:	85 c0                	test   %eax,%eax
80108dae:	74 0d                	je     80108dbd <mappages+0x60>
      panic("remap");
80108db0:	83 ec 0c             	sub    $0xc,%esp
80108db3:	68 cc 9d 10 80       	push   $0x80109dcc
80108db8:	e8 a9 77 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108dbd:	8b 45 18             	mov    0x18(%ebp),%eax
80108dc0:	0b 45 14             	or     0x14(%ebp),%eax
80108dc3:	83 c8 01             	or     $0x1,%eax
80108dc6:	89 c2                	mov    %eax,%edx
80108dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dcb:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108dd3:	74 10                	je     80108de5 <mappages+0x88>
      break;
    a += PGSIZE;
80108dd5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108ddc:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108de3:	eb 9c                	jmp    80108d81 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108de5:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108de6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108deb:	c9                   	leave  
80108dec:	c3                   	ret    

80108ded <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108ded:	55                   	push   %ebp
80108dee:	89 e5                	mov    %esp,%ebp
80108df0:	53                   	push   %ebx
80108df1:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108df4:	e8 2f 9e ff ff       	call   80102c28 <kalloc>
80108df9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108dfc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e00:	75 0a                	jne    80108e0c <setupkvm+0x1f>
    return 0;
80108e02:	b8 00 00 00 00       	mov    $0x0,%eax
80108e07:	e9 8e 00 00 00       	jmp    80108e9a <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108e0c:	83 ec 04             	sub    $0x4,%esp
80108e0f:	68 00 10 00 00       	push   $0x1000
80108e14:	6a 00                	push   $0x0
80108e16:	ff 75 f0             	pushl  -0x10(%ebp)
80108e19:	e8 94 d0 ff ff       	call   80105eb2 <memset>
80108e1e:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108e21:	83 ec 0c             	sub    $0xc,%esp
80108e24:	68 00 00 00 0e       	push   $0xe000000
80108e29:	e8 0d fa ff ff       	call   8010883b <p2v>
80108e2e:	83 c4 10             	add    $0x10,%esp
80108e31:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108e36:	76 0d                	jbe    80108e45 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108e38:	83 ec 0c             	sub    $0xc,%esp
80108e3b:	68 d2 9d 10 80       	push   $0x80109dd2
80108e40:	e8 21 77 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108e45:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108e4c:	eb 40                	jmp    80108e8e <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e51:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e57:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e5d:	8b 58 08             	mov    0x8(%eax),%ebx
80108e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e63:	8b 40 04             	mov    0x4(%eax),%eax
80108e66:	29 c3                	sub    %eax,%ebx
80108e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6b:	8b 00                	mov    (%eax),%eax
80108e6d:	83 ec 0c             	sub    $0xc,%esp
80108e70:	51                   	push   %ecx
80108e71:	52                   	push   %edx
80108e72:	53                   	push   %ebx
80108e73:	50                   	push   %eax
80108e74:	ff 75 f0             	pushl  -0x10(%ebp)
80108e77:	e8 e1 fe ff ff       	call   80108d5d <mappages>
80108e7c:	83 c4 20             	add    $0x20,%esp
80108e7f:	85 c0                	test   %eax,%eax
80108e81:	79 07                	jns    80108e8a <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108e83:	b8 00 00 00 00       	mov    $0x0,%eax
80108e88:	eb 10                	jmp    80108e9a <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108e8a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108e8e:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108e95:	72 b7                	jb     80108e4e <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108e9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e9d:	c9                   	leave  
80108e9e:	c3                   	ret    

80108e9f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108e9f:	55                   	push   %ebp
80108ea0:	89 e5                	mov    %esp,%ebp
80108ea2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108ea5:	e8 43 ff ff ff       	call   80108ded <setupkvm>
80108eaa:	a3 b8 7c 11 80       	mov    %eax,0x80117cb8
  switchkvm();
80108eaf:	e8 03 00 00 00       	call   80108eb7 <switchkvm>
}
80108eb4:	90                   	nop
80108eb5:	c9                   	leave  
80108eb6:	c3                   	ret    

80108eb7 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108eb7:	55                   	push   %ebp
80108eb8:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108eba:	a1 b8 7c 11 80       	mov    0x80117cb8,%eax
80108ebf:	50                   	push   %eax
80108ec0:	e8 69 f9 ff ff       	call   8010882e <v2p>
80108ec5:	83 c4 04             	add    $0x4,%esp
80108ec8:	50                   	push   %eax
80108ec9:	e8 54 f9 ff ff       	call   80108822 <lcr3>
80108ece:	83 c4 04             	add    $0x4,%esp
}
80108ed1:	90                   	nop
80108ed2:	c9                   	leave  
80108ed3:	c3                   	ret    

80108ed4 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108ed4:	55                   	push   %ebp
80108ed5:	89 e5                	mov    %esp,%ebp
80108ed7:	56                   	push   %esi
80108ed8:	53                   	push   %ebx
  pushcli();
80108ed9:	e8 ce ce ff ff       	call   80105dac <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108ede:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ee4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108eeb:	83 c2 08             	add    $0x8,%edx
80108eee:	89 d6                	mov    %edx,%esi
80108ef0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ef7:	83 c2 08             	add    $0x8,%edx
80108efa:	c1 ea 10             	shr    $0x10,%edx
80108efd:	89 d3                	mov    %edx,%ebx
80108eff:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108f06:	83 c2 08             	add    $0x8,%edx
80108f09:	c1 ea 18             	shr    $0x18,%edx
80108f0c:	89 d1                	mov    %edx,%ecx
80108f0e:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108f15:	67 00 
80108f17:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108f1e:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108f24:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f2b:	83 e2 f0             	and    $0xfffffff0,%edx
80108f2e:	83 ca 09             	or     $0x9,%edx
80108f31:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f37:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f3e:	83 ca 10             	or     $0x10,%edx
80108f41:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f47:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f4e:	83 e2 9f             	and    $0xffffff9f,%edx
80108f51:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f57:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f5e:	83 ca 80             	or     $0xffffff80,%edx
80108f61:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108f67:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f6e:	83 e2 f0             	and    $0xfffffff0,%edx
80108f71:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f77:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f7e:	83 e2 ef             	and    $0xffffffef,%edx
80108f81:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f87:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f8e:	83 e2 df             	and    $0xffffffdf,%edx
80108f91:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f97:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f9e:	83 ca 40             	or     $0x40,%edx
80108fa1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108fa7:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108fae:	83 e2 7f             	and    $0x7f,%edx
80108fb1:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108fb7:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108fbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108fc3:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108fca:	83 e2 ef             	and    $0xffffffef,%edx
80108fcd:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108fd3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108fd9:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108fdf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108fe5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108fec:	8b 52 08             	mov    0x8(%edx),%edx
80108fef:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108ff5:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108ff8:	83 ec 0c             	sub    $0xc,%esp
80108ffb:	6a 30                	push   $0x30
80108ffd:	e8 f3 f7 ff ff       	call   801087f5 <ltr>
80109002:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109005:	8b 45 08             	mov    0x8(%ebp),%eax
80109008:	8b 40 04             	mov    0x4(%eax),%eax
8010900b:	85 c0                	test   %eax,%eax
8010900d:	75 0d                	jne    8010901c <switchuvm+0x148>
    panic("switchuvm: no pgdir");
8010900f:	83 ec 0c             	sub    $0xc,%esp
80109012:	68 e3 9d 10 80       	push   $0x80109de3
80109017:	e8 4a 75 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010901c:	8b 45 08             	mov    0x8(%ebp),%eax
8010901f:	8b 40 04             	mov    0x4(%eax),%eax
80109022:	83 ec 0c             	sub    $0xc,%esp
80109025:	50                   	push   %eax
80109026:	e8 03 f8 ff ff       	call   8010882e <v2p>
8010902b:	83 c4 10             	add    $0x10,%esp
8010902e:	83 ec 0c             	sub    $0xc,%esp
80109031:	50                   	push   %eax
80109032:	e8 eb f7 ff ff       	call   80108822 <lcr3>
80109037:	83 c4 10             	add    $0x10,%esp
  popcli();
8010903a:	e8 b2 cd ff ff       	call   80105df1 <popcli>
}
8010903f:	90                   	nop
80109040:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109043:	5b                   	pop    %ebx
80109044:	5e                   	pop    %esi
80109045:	5d                   	pop    %ebp
80109046:	c3                   	ret    

80109047 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109047:	55                   	push   %ebp
80109048:	89 e5                	mov    %esp,%ebp
8010904a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010904d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109054:	76 0d                	jbe    80109063 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109056:	83 ec 0c             	sub    $0xc,%esp
80109059:	68 f7 9d 10 80       	push   $0x80109df7
8010905e:	e8 03 75 ff ff       	call   80100566 <panic>
  mem = kalloc();
80109063:	e8 c0 9b ff ff       	call   80102c28 <kalloc>
80109068:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010906b:	83 ec 04             	sub    $0x4,%esp
8010906e:	68 00 10 00 00       	push   $0x1000
80109073:	6a 00                	push   $0x0
80109075:	ff 75 f4             	pushl  -0xc(%ebp)
80109078:	e8 35 ce ff ff       	call   80105eb2 <memset>
8010907d:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109080:	83 ec 0c             	sub    $0xc,%esp
80109083:	ff 75 f4             	pushl  -0xc(%ebp)
80109086:	e8 a3 f7 ff ff       	call   8010882e <v2p>
8010908b:	83 c4 10             	add    $0x10,%esp
8010908e:	83 ec 0c             	sub    $0xc,%esp
80109091:	6a 06                	push   $0x6
80109093:	50                   	push   %eax
80109094:	68 00 10 00 00       	push   $0x1000
80109099:	6a 00                	push   $0x0
8010909b:	ff 75 08             	pushl  0x8(%ebp)
8010909e:	e8 ba fc ff ff       	call   80108d5d <mappages>
801090a3:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801090a6:	83 ec 04             	sub    $0x4,%esp
801090a9:	ff 75 10             	pushl  0x10(%ebp)
801090ac:	ff 75 0c             	pushl  0xc(%ebp)
801090af:	ff 75 f4             	pushl  -0xc(%ebp)
801090b2:	e8 ba ce ff ff       	call   80105f71 <memmove>
801090b7:	83 c4 10             	add    $0x10,%esp
}
801090ba:	90                   	nop
801090bb:	c9                   	leave  
801090bc:	c3                   	ret    

801090bd <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801090bd:	55                   	push   %ebp
801090be:	89 e5                	mov    %esp,%ebp
801090c0:	53                   	push   %ebx
801090c1:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801090c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801090c7:	25 ff 0f 00 00       	and    $0xfff,%eax
801090cc:	85 c0                	test   %eax,%eax
801090ce:	74 0d                	je     801090dd <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801090d0:	83 ec 0c             	sub    $0xc,%esp
801090d3:	68 14 9e 10 80       	push   $0x80109e14
801090d8:	e8 89 74 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801090dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090e4:	e9 95 00 00 00       	jmp    8010917e <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801090e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801090ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ef:	01 d0                	add    %edx,%eax
801090f1:	83 ec 04             	sub    $0x4,%esp
801090f4:	6a 00                	push   $0x0
801090f6:	50                   	push   %eax
801090f7:	ff 75 08             	pushl  0x8(%ebp)
801090fa:	e8 be fb ff ff       	call   80108cbd <walkpgdir>
801090ff:	83 c4 10             	add    $0x10,%esp
80109102:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109105:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109109:	75 0d                	jne    80109118 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010910b:	83 ec 0c             	sub    $0xc,%esp
8010910e:	68 37 9e 10 80       	push   $0x80109e37
80109113:	e8 4e 74 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109118:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010911b:	8b 00                	mov    (%eax),%eax
8010911d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109122:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109125:	8b 45 18             	mov    0x18(%ebp),%eax
80109128:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010912b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109130:	77 0b                	ja     8010913d <loaduvm+0x80>
      n = sz - i;
80109132:	8b 45 18             	mov    0x18(%ebp),%eax
80109135:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109138:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010913b:	eb 07                	jmp    80109144 <loaduvm+0x87>
    else
      n = PGSIZE;
8010913d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109144:	8b 55 14             	mov    0x14(%ebp),%edx
80109147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010914d:	83 ec 0c             	sub    $0xc,%esp
80109150:	ff 75 e8             	pushl  -0x18(%ebp)
80109153:	e8 e3 f6 ff ff       	call   8010883b <p2v>
80109158:	83 c4 10             	add    $0x10,%esp
8010915b:	ff 75 f0             	pushl  -0x10(%ebp)
8010915e:	53                   	push   %ebx
8010915f:	50                   	push   %eax
80109160:	ff 75 10             	pushl  0x10(%ebp)
80109163:	e8 6e 8d ff ff       	call   80101ed6 <readi>
80109168:	83 c4 10             	add    $0x10,%esp
8010916b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010916e:	74 07                	je     80109177 <loaduvm+0xba>
      return -1;
80109170:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109175:	eb 18                	jmp    8010918f <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109177:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010917e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109181:	3b 45 18             	cmp    0x18(%ebp),%eax
80109184:	0f 82 5f ff ff ff    	jb     801090e9 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010918a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010918f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109192:	c9                   	leave  
80109193:	c3                   	ret    

80109194 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109194:	55                   	push   %ebp
80109195:	89 e5                	mov    %esp,%ebp
80109197:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010919a:	8b 45 10             	mov    0x10(%ebp),%eax
8010919d:	85 c0                	test   %eax,%eax
8010919f:	79 0a                	jns    801091ab <allocuvm+0x17>
    return 0;
801091a1:	b8 00 00 00 00       	mov    $0x0,%eax
801091a6:	e9 b0 00 00 00       	jmp    8010925b <allocuvm+0xc7>
  if(newsz < oldsz)
801091ab:	8b 45 10             	mov    0x10(%ebp),%eax
801091ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091b1:	73 08                	jae    801091bb <allocuvm+0x27>
    return oldsz;
801091b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801091b6:	e9 a0 00 00 00       	jmp    8010925b <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
801091bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801091be:	05 ff 0f 00 00       	add    $0xfff,%eax
801091c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801091cb:	eb 7f                	jmp    8010924c <allocuvm+0xb8>
    mem = kalloc();
801091cd:	e8 56 9a ff ff       	call   80102c28 <kalloc>
801091d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801091d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801091d9:	75 2b                	jne    80109206 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801091db:	83 ec 0c             	sub    $0xc,%esp
801091de:	68 55 9e 10 80       	push   $0x80109e55
801091e3:	e8 de 71 ff ff       	call   801003c6 <cprintf>
801091e8:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801091eb:	83 ec 04             	sub    $0x4,%esp
801091ee:	ff 75 0c             	pushl  0xc(%ebp)
801091f1:	ff 75 10             	pushl  0x10(%ebp)
801091f4:	ff 75 08             	pushl  0x8(%ebp)
801091f7:	e8 61 00 00 00       	call   8010925d <deallocuvm>
801091fc:	83 c4 10             	add    $0x10,%esp
      return 0;
801091ff:	b8 00 00 00 00       	mov    $0x0,%eax
80109204:	eb 55                	jmp    8010925b <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109206:	83 ec 04             	sub    $0x4,%esp
80109209:	68 00 10 00 00       	push   $0x1000
8010920e:	6a 00                	push   $0x0
80109210:	ff 75 f0             	pushl  -0x10(%ebp)
80109213:	e8 9a cc ff ff       	call   80105eb2 <memset>
80109218:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010921b:	83 ec 0c             	sub    $0xc,%esp
8010921e:	ff 75 f0             	pushl  -0x10(%ebp)
80109221:	e8 08 f6 ff ff       	call   8010882e <v2p>
80109226:	83 c4 10             	add    $0x10,%esp
80109229:	89 c2                	mov    %eax,%edx
8010922b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010922e:	83 ec 0c             	sub    $0xc,%esp
80109231:	6a 06                	push   $0x6
80109233:	52                   	push   %edx
80109234:	68 00 10 00 00       	push   $0x1000
80109239:	50                   	push   %eax
8010923a:	ff 75 08             	pushl  0x8(%ebp)
8010923d:	e8 1b fb ff ff       	call   80108d5d <mappages>
80109242:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109245:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010924c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924f:	3b 45 10             	cmp    0x10(%ebp),%eax
80109252:	0f 82 75 ff ff ff    	jb     801091cd <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109258:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010925b:	c9                   	leave  
8010925c:	c3                   	ret    

8010925d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010925d:	55                   	push   %ebp
8010925e:	89 e5                	mov    %esp,%ebp
80109260:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109263:	8b 45 10             	mov    0x10(%ebp),%eax
80109266:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109269:	72 08                	jb     80109273 <deallocuvm+0x16>
    return oldsz;
8010926b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010926e:	e9 a5 00 00 00       	jmp    80109318 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109273:	8b 45 10             	mov    0x10(%ebp),%eax
80109276:	05 ff 0f 00 00       	add    $0xfff,%eax
8010927b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109280:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109283:	e9 81 00 00 00       	jmp    80109309 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928b:	83 ec 04             	sub    $0x4,%esp
8010928e:	6a 00                	push   $0x0
80109290:	50                   	push   %eax
80109291:	ff 75 08             	pushl  0x8(%ebp)
80109294:	e8 24 fa ff ff       	call   80108cbd <walkpgdir>
80109299:	83 c4 10             	add    $0x10,%esp
8010929c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010929f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801092a3:	75 09                	jne    801092ae <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801092a5:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801092ac:	eb 54                	jmp    80109302 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801092ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b1:	8b 00                	mov    (%eax),%eax
801092b3:	83 e0 01             	and    $0x1,%eax
801092b6:	85 c0                	test   %eax,%eax
801092b8:	74 48                	je     80109302 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801092ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092bd:	8b 00                	mov    (%eax),%eax
801092bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801092c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801092cb:	75 0d                	jne    801092da <deallocuvm+0x7d>
        panic("kfree");
801092cd:	83 ec 0c             	sub    $0xc,%esp
801092d0:	68 6d 9e 10 80       	push   $0x80109e6d
801092d5:	e8 8c 72 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801092da:	83 ec 0c             	sub    $0xc,%esp
801092dd:	ff 75 ec             	pushl  -0x14(%ebp)
801092e0:	e8 56 f5 ff ff       	call   8010883b <p2v>
801092e5:	83 c4 10             	add    $0x10,%esp
801092e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801092eb:	83 ec 0c             	sub    $0xc,%esp
801092ee:	ff 75 e8             	pushl  -0x18(%ebp)
801092f1:	e8 95 98 ff ff       	call   80102b8b <kfree>
801092f6:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801092f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109302:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010930f:	0f 82 73 ff ff ff    	jb     80109288 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109315:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109318:	c9                   	leave  
80109319:	c3                   	ret    

8010931a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010931a:	55                   	push   %ebp
8010931b:	89 e5                	mov    %esp,%ebp
8010931d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109320:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109324:	75 0d                	jne    80109333 <freevm+0x19>
    panic("freevm: no pgdir");
80109326:	83 ec 0c             	sub    $0xc,%esp
80109329:	68 73 9e 10 80       	push   $0x80109e73
8010932e:	e8 33 72 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109333:	83 ec 04             	sub    $0x4,%esp
80109336:	6a 00                	push   $0x0
80109338:	68 00 00 00 80       	push   $0x80000000
8010933d:	ff 75 08             	pushl  0x8(%ebp)
80109340:	e8 18 ff ff ff       	call   8010925d <deallocuvm>
80109345:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010934f:	eb 4f                	jmp    801093a0 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109354:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010935b:	8b 45 08             	mov    0x8(%ebp),%eax
8010935e:	01 d0                	add    %edx,%eax
80109360:	8b 00                	mov    (%eax),%eax
80109362:	83 e0 01             	and    $0x1,%eax
80109365:	85 c0                	test   %eax,%eax
80109367:	74 33                	je     8010939c <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109373:	8b 45 08             	mov    0x8(%ebp),%eax
80109376:	01 d0                	add    %edx,%eax
80109378:	8b 00                	mov    (%eax),%eax
8010937a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010937f:	83 ec 0c             	sub    $0xc,%esp
80109382:	50                   	push   %eax
80109383:	e8 b3 f4 ff ff       	call   8010883b <p2v>
80109388:	83 c4 10             	add    $0x10,%esp
8010938b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010938e:	83 ec 0c             	sub    $0xc,%esp
80109391:	ff 75 f0             	pushl  -0x10(%ebp)
80109394:	e8 f2 97 ff ff       	call   80102b8b <kfree>
80109399:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010939c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093a0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801093a7:	76 a8                	jbe    80109351 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801093a9:	83 ec 0c             	sub    $0xc,%esp
801093ac:	ff 75 08             	pushl  0x8(%ebp)
801093af:	e8 d7 97 ff ff       	call   80102b8b <kfree>
801093b4:	83 c4 10             	add    $0x10,%esp
}
801093b7:	90                   	nop
801093b8:	c9                   	leave  
801093b9:	c3                   	ret    

801093ba <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801093ba:	55                   	push   %ebp
801093bb:	89 e5                	mov    %esp,%ebp
801093bd:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801093c0:	83 ec 04             	sub    $0x4,%esp
801093c3:	6a 00                	push   $0x0
801093c5:	ff 75 0c             	pushl  0xc(%ebp)
801093c8:	ff 75 08             	pushl  0x8(%ebp)
801093cb:	e8 ed f8 ff ff       	call   80108cbd <walkpgdir>
801093d0:	83 c4 10             	add    $0x10,%esp
801093d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801093d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801093da:	75 0d                	jne    801093e9 <clearpteu+0x2f>
    panic("clearpteu");
801093dc:	83 ec 0c             	sub    $0xc,%esp
801093df:	68 84 9e 10 80       	push   $0x80109e84
801093e4:	e8 7d 71 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801093e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ec:	8b 00                	mov    (%eax),%eax
801093ee:	83 e0 fb             	and    $0xfffffffb,%eax
801093f1:	89 c2                	mov    %eax,%edx
801093f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f6:	89 10                	mov    %edx,(%eax)
}
801093f8:	90                   	nop
801093f9:	c9                   	leave  
801093fa:	c3                   	ret    

801093fb <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801093fb:	55                   	push   %ebp
801093fc:	89 e5                	mov    %esp,%ebp
801093fe:	53                   	push   %ebx
801093ff:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109402:	e8 e6 f9 ff ff       	call   80108ded <setupkvm>
80109407:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010940a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010940e:	75 0a                	jne    8010941a <copyuvm+0x1f>
    return 0;
80109410:	b8 00 00 00 00       	mov    $0x0,%eax
80109415:	e9 ee 00 00 00       	jmp    80109508 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
8010941a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109421:	e9 ba 00 00 00       	jmp    801094e0 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109429:	83 ec 04             	sub    $0x4,%esp
8010942c:	6a 00                	push   $0x0
8010942e:	50                   	push   %eax
8010942f:	ff 75 08             	pushl  0x8(%ebp)
80109432:	e8 86 f8 ff ff       	call   80108cbd <walkpgdir>
80109437:	83 c4 10             	add    $0x10,%esp
8010943a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010943d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109441:	75 0d                	jne    80109450 <copyuvm+0x55>
    //  continue;
      panic("copyuvm: pte should exist");
80109443:	83 ec 0c             	sub    $0xc,%esp
80109446:	68 8e 9e 10 80       	push   $0x80109e8e
8010944b:	e8 16 71 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109453:	8b 00                	mov    (%eax),%eax
80109455:	83 e0 01             	and    $0x1,%eax
80109458:	85 c0                	test   %eax,%eax
8010945a:	74 7c                	je     801094d8 <copyuvm+0xdd>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010945c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010945f:	8b 00                	mov    (%eax),%eax
80109461:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109466:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109469:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010946c:	8b 00                	mov    (%eax),%eax
8010946e:	25 ff 0f 00 00       	and    $0xfff,%eax
80109473:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109476:	e8 ad 97 ff ff       	call   80102c28 <kalloc>
8010947b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010947e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109482:	74 6d                	je     801094f1 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109484:	83 ec 0c             	sub    $0xc,%esp
80109487:	ff 75 e8             	pushl  -0x18(%ebp)
8010948a:	e8 ac f3 ff ff       	call   8010883b <p2v>
8010948f:	83 c4 10             	add    $0x10,%esp
80109492:	83 ec 04             	sub    $0x4,%esp
80109495:	68 00 10 00 00       	push   $0x1000
8010949a:	50                   	push   %eax
8010949b:	ff 75 e0             	pushl  -0x20(%ebp)
8010949e:	e8 ce ca ff ff       	call   80105f71 <memmove>
801094a3:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801094a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801094a9:	83 ec 0c             	sub    $0xc,%esp
801094ac:	ff 75 e0             	pushl  -0x20(%ebp)
801094af:	e8 7a f3 ff ff       	call   8010882e <v2p>
801094b4:	83 c4 10             	add    $0x10,%esp
801094b7:	89 c2                	mov    %eax,%edx
801094b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bc:	83 ec 0c             	sub    $0xc,%esp
801094bf:	53                   	push   %ebx
801094c0:	52                   	push   %edx
801094c1:	68 00 10 00 00       	push   $0x1000
801094c6:	50                   	push   %eax
801094c7:	ff 75 f0             	pushl  -0x10(%ebp)
801094ca:	e8 8e f8 ff ff       	call   80108d5d <mappages>
801094cf:	83 c4 20             	add    $0x20,%esp
801094d2:	85 c0                	test   %eax,%eax
801094d4:	78 1e                	js     801094f4 <copyuvm+0xf9>
801094d6:	eb 01                	jmp    801094d9 <copyuvm+0xde>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
    //  continue;
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      continue;
801094d8:	90                   	nop
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801094d9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801094e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801094e6:	0f 82 3a ff ff ff    	jb     80109426 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801094ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ef:	eb 17                	jmp    80109508 <copyuvm+0x10d>
      continue;
      //panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801094f1:	90                   	nop
801094f2:	eb 01                	jmp    801094f5 <copyuvm+0xfa>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801094f4:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801094f5:	83 ec 0c             	sub    $0xc,%esp
801094f8:	ff 75 f0             	pushl  -0x10(%ebp)
801094fb:	e8 1a fe ff ff       	call   8010931a <freevm>
80109500:	83 c4 10             	add    $0x10,%esp
  return 0;
80109503:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010950b:	c9                   	leave  
8010950c:	c3                   	ret    

8010950d <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010950d:	55                   	push   %ebp
8010950e:	89 e5                	mov    %esp,%ebp
80109510:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109513:	83 ec 04             	sub    $0x4,%esp
80109516:	6a 00                	push   $0x0
80109518:	ff 75 0c             	pushl  0xc(%ebp)
8010951b:	ff 75 08             	pushl  0x8(%ebp)
8010951e:	e8 9a f7 ff ff       	call   80108cbd <walkpgdir>
80109523:	83 c4 10             	add    $0x10,%esp
80109526:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010952c:	8b 00                	mov    (%eax),%eax
8010952e:	83 e0 01             	and    $0x1,%eax
80109531:	85 c0                	test   %eax,%eax
80109533:	75 07                	jne    8010953c <uva2ka+0x2f>
    return 0;
80109535:	b8 00 00 00 00       	mov    $0x0,%eax
8010953a:	eb 29                	jmp    80109565 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010953c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953f:	8b 00                	mov    (%eax),%eax
80109541:	83 e0 04             	and    $0x4,%eax
80109544:	85 c0                	test   %eax,%eax
80109546:	75 07                	jne    8010954f <uva2ka+0x42>
    return 0;
80109548:	b8 00 00 00 00       	mov    $0x0,%eax
8010954d:	eb 16                	jmp    80109565 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010954f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109552:	8b 00                	mov    (%eax),%eax
80109554:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109559:	83 ec 0c             	sub    $0xc,%esp
8010955c:	50                   	push   %eax
8010955d:	e8 d9 f2 ff ff       	call   8010883b <p2v>
80109562:	83 c4 10             	add    $0x10,%esp
}
80109565:	c9                   	leave  
80109566:	c3                   	ret    

80109567 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109567:	55                   	push   %ebp
80109568:	89 e5                	mov    %esp,%ebp
8010956a:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010956d:	8b 45 10             	mov    0x10(%ebp),%eax
80109570:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109573:	eb 7f                	jmp    801095f4 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109575:	8b 45 0c             	mov    0xc(%ebp),%eax
80109578:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010957d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109580:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109583:	83 ec 08             	sub    $0x8,%esp
80109586:	50                   	push   %eax
80109587:	ff 75 08             	pushl  0x8(%ebp)
8010958a:	e8 7e ff ff ff       	call   8010950d <uva2ka>
8010958f:	83 c4 10             	add    $0x10,%esp
80109592:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109595:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109599:	75 07                	jne    801095a2 <copyout+0x3b>
      return -1;
8010959b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095a0:	eb 61                	jmp    80109603 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801095a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095a5:	2b 45 0c             	sub    0xc(%ebp),%eax
801095a8:	05 00 10 00 00       	add    $0x1000,%eax
801095ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801095b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095b3:	3b 45 14             	cmp    0x14(%ebp),%eax
801095b6:	76 06                	jbe    801095be <copyout+0x57>
      n = len;
801095b8:	8b 45 14             	mov    0x14(%ebp),%eax
801095bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801095be:	8b 45 0c             	mov    0xc(%ebp),%eax
801095c1:	2b 45 ec             	sub    -0x14(%ebp),%eax
801095c4:	89 c2                	mov    %eax,%edx
801095c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095c9:	01 d0                	add    %edx,%eax
801095cb:	83 ec 04             	sub    $0x4,%esp
801095ce:	ff 75 f0             	pushl  -0x10(%ebp)
801095d1:	ff 75 f4             	pushl  -0xc(%ebp)
801095d4:	50                   	push   %eax
801095d5:	e8 97 c9 ff ff       	call   80105f71 <memmove>
801095da:	83 c4 10             	add    $0x10,%esp
    len -= n;
801095dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e0:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801095e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e6:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801095e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095ec:	05 00 10 00 00       	add    $0x1000,%eax
801095f1:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801095f4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801095f8:	0f 85 77 ff ff ff    	jne    80109575 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801095fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109603:	c9                   	leave  
80109604:	c3                   	ret    

80109605 <unmappages>:



int
unmappages(pde_t *pgdir, void *va, uint size)
{
80109605:	55                   	push   %ebp
80109606:	89 e5                	mov    %esp,%ebp
80109608:	83 ec 18             	sub    $0x18,%esp
  uint oldsz,newsz;

  oldsz= (uint) va+size;
8010960b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010960e:	8b 45 10             	mov    0x10(%ebp),%eax
80109611:	01 d0                	add    %edx,%eax
80109613:	89 45 f4             	mov    %eax,-0xc(%ebp)
  newsz=(uint) va;
80109616:	8b 45 0c             	mov    0xc(%ebp),%eax
80109619:	89 45 f0             	mov    %eax,-0x10(%ebp)

  newsz=deallocuvm(pgdir,oldsz,newsz);
8010961c:	83 ec 04             	sub    $0x4,%esp
8010961f:	ff 75 f0             	pushl  -0x10(%ebp)
80109622:	ff 75 f4             	pushl  -0xc(%ebp)
80109625:	ff 75 08             	pushl  0x8(%ebp)
80109628:	e8 30 fc ff ff       	call   8010925d <deallocuvm>
8010962d:	83 c4 10             	add    $0x10,%esp
80109630:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(!newsz)
80109633:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109637:	75 07                	jne    80109640 <unmappages+0x3b>
    return -1;
80109639:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010963e:	eb 03                	jmp    80109643 <unmappages+0x3e>

  return newsz;
80109640:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109643:	c9                   	leave  
80109644:	c3                   	ret    

80109645 <pgflags>:



pte_t*
pgflags(pde_t *pgdir, const void *va,uint flag)
{
80109645:	55                   	push   %ebp
80109646:	89 e5                	mov    %esp,%ebp
80109648:	83 ec 18             	sub    $0x18,%esp
  pte_t* pte;

  if((pte=walkpgdir(pgdir,(char*)va,0))!=0){
8010964b:	83 ec 04             	sub    $0x4,%esp
8010964e:	6a 00                	push   $0x0
80109650:	ff 75 0c             	pushl  0xc(%ebp)
80109653:	ff 75 08             	pushl  0x8(%ebp)
80109656:	e8 62 f6 ff ff       	call   80108cbd <walkpgdir>
8010965b:	83 c4 10             	add    $0x10,%esp
8010965e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109665:	74 11                	je     80109678 <pgflags+0x33>
    if(*pte & flag)
80109667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966a:	8b 00                	mov    (%eax),%eax
8010966c:	23 45 10             	and    0x10(%ebp),%eax
8010966f:	85 c0                	test   %eax,%eax
80109671:	74 05                	je     80109678 <pgflags+0x33>
      return pte;
80109673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109676:	eb 05                	jmp    8010967d <pgflags+0x38>
  }
  return 0;
80109678:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010967d:	c9                   	leave  
8010967e:	c3                   	ret    
