
_semaphoretest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <printf>:
int semempty;
int semb;

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	ff 75 0c             	pushl  0xc(%ebp)
   c:	e8 fe 02 00 00       	call   30f <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 ce 04 00 00       	call   4f1 <write>
  23:	83 c4 10             	add    $0x10,%esp
}
  26:	90                   	nop
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <enqueue>:


void
enqueue()
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 08             	sub    $0x8,%esp
  semdown(semb);
  2f:	a1 5c 08 00 00       	mov    0x85c,%eax
  34:	83 ec 0c             	sub    $0xc,%esp
  37:	50                   	push   %eax
  38:	e8 54 05 00 00       	call   591 <semdown>
  3d:	83 c4 10             	add    $0x10,%esp
  write(fd, "+1", sizeof("+1"));
  40:	a1 58 08 00 00       	mov    0x858,%eax
  45:	83 ec 04             	sub    $0x4,%esp
  48:	6a 03                	push   $0x3
  4a:	68 a1 05 00 00       	push   $0x5a1
  4f:	50                   	push   %eax
  50:	e8 9c 04 00 00       	call   4f1 <write>
  55:	83 c4 10             	add    $0x10,%esp
  semup(semb);
  58:	a1 5c 08 00 00       	mov    0x85c,%eax
  5d:	83 ec 0c             	sub    $0xc,%esp
  60:	50                   	push   %eax
  61:	e8 33 05 00 00       	call   599 <semup>
  66:	83 c4 10             	add    $0x10,%esp
}
  69:	90                   	nop
  6a:	c9                   	leave  
  6b:	c3                   	ret    

0000006c <unqueue>:

int
unqueue()
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	83 ec 08             	sub    $0x8,%esp
  semdown(semb);
  72:	a1 5c 08 00 00       	mov    0x85c,%eax
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	50                   	push   %eax
  7b:	e8 11 05 00 00       	call   591 <semdown>
  80:	83 c4 10             	add    $0x10,%esp
  write(fd, "-1", sizeof("-1"));
  83:	a1 58 08 00 00       	mov    0x858,%eax
  88:	83 ec 04             	sub    $0x4,%esp
  8b:	6a 03                	push   $0x3
  8d:	68 a4 05 00 00       	push   $0x5a4
  92:	50                   	push   %eax
  93:	e8 59 04 00 00       	call   4f1 <write>
  98:	83 c4 10             	add    $0x10,%esp
  semup(semb);
  9b:	a1 5c 08 00 00       	mov    0x85c,%eax
  a0:	83 ec 0c             	sub    $0xc,%esp
  a3:	50                   	push   %eax
  a4:	e8 f0 04 00 00       	call   599 <semup>
  a9:	83 c4 10             	add    $0x10,%esp
  return 0;
  ac:	b8 00 00 00 00       	mov    $0x0,%eax

}
  b1:	c9                   	leave  
  b2:	c3                   	ret    

000000b3 <cons>:

void
cons()
{
  b3:	55                   	push   %ebp
  b4:	89 e5                	mov    %esp,%ebp
  b6:	83 ec 08             	sub    $0x8,%esp
  for(;;) {
    semdown(semempty);
  b9:	a1 60 08 00 00       	mov    0x860,%eax
  be:	83 ec 0c             	sub    $0xc,%esp
  c1:	50                   	push   %eax
  c2:	e8 ca 04 00 00       	call   591 <semdown>
  c7:	83 c4 10             	add    $0x10,%esp
    unqueue();
  ca:	e8 9d ff ff ff       	call   6c <unqueue>
    semup(semfull);
  cf:	a1 64 08 00 00       	mov    0x864,%eax
  d4:	83 ec 0c             	sub    $0xc,%esp
  d7:	50                   	push   %eax
  d8:	e8 bc 04 00 00       	call   599 <semup>
  dd:	83 c4 10             	add    $0x10,%esp
  }
  e0:	eb d7                	jmp    b9 <cons+0x6>

000000e2 <prod>:

}

void
prod()
{
  e2:	55                   	push   %ebp
  e3:	89 e5                	mov    %esp,%ebp
  e5:	83 ec 18             	sub    $0x18,%esp
  int i;
    for(i=0;i<AMOUNTOFCYCLES;i++) {
  e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ef:	eb 2b                	jmp    11c <prod+0x3a>
      semdown(semfull);
  f1:	a1 64 08 00 00       	mov    0x864,%eax
  f6:	83 ec 0c             	sub    $0xc,%esp
  f9:	50                   	push   %eax
  fa:	e8 92 04 00 00       	call   591 <semdown>
  ff:	83 c4 10             	add    $0x10,%esp
      enqueue();
 102:	e8 22 ff ff ff       	call   29 <enqueue>
      semup(semempty);
 107:	a1 60 08 00 00       	mov    0x860,%eax
 10c:	83 ec 0c             	sub    $0xc,%esp
 10f:	50                   	push   %eax
 110:	e8 84 04 00 00       	call   599 <semup>
 115:	83 c4 10             	add    $0x10,%esp

void
prod()
{
  int i;
    for(i=0;i<AMOUNTOFCYCLES;i++) {
 118:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 11c:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 120:	7e cf                	jle    f1 <prod+0xf>
      semdown(semfull);
      enqueue();
      semup(semempty);
    }
}
 122:	90                   	nop
 123:	c9                   	leave  
 124:	c3                   	ret    

00000125 <semtest>:

void
semtest(void)
{
 125:	55                   	push   %ebp
 126:	89 e5                	mov    %esp,%ebp
 128:	83 ec 18             	sub    $0x18,%esp

  int i,j;
  int pid=1;
 12b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  fd=open("register", O_CREATE|O_RDWR);
 132:	83 ec 08             	sub    $0x8,%esp
 135:	68 02 02 00 00       	push   $0x202
 13a:	68 a7 05 00 00       	push   $0x5a7
 13f:	e8 cd 03 00 00       	call   511 <open>
 144:	83 c4 10             	add    $0x10,%esp
 147:	a3 58 08 00 00       	mov    %eax,0x858

  for(i=0;i<AMOUNTOFPRODUCERS;i++){
 14c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 153:	eb 26                	jmp    17b <semtest+0x56>

    pid=fork();
 155:	e8 6f 03 00 00       	call   4c9 <fork>
 15a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if(pid==0){
 15d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 161:	75 14                	jne    177 <semtest+0x52>
      printf(1,"PRODUCTOR\n" );
 163:	83 ec 08             	sub    $0x8,%esp
 166:	68 b0 05 00 00       	push   $0x5b0
 16b:	6a 01                	push   $0x1
 16d:	e8 8e fe ff ff       	call   0 <printf>
 172:	83 c4 10             	add    $0x10,%esp
      break;
 175:	eb 0a                	jmp    181 <semtest+0x5c>

  int i,j;
  int pid=1;
  fd=open("register", O_CREATE|O_RDWR);

  for(i=0;i<AMOUNTOFPRODUCERS;i++){
 177:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 17b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 17f:	7e d4                	jle    155 <semtest+0x30>
      printf(1,"PRODUCTOR\n" );
      break;
    }

  }
  if(pid==0){
 181:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 185:	75 05                	jne    18c <semtest+0x67>
    prod();
 187:	e8 56 ff ff ff       	call   e2 <prod>
  }

  for(i=0;i<AMOUNTOFCONSUMERS;i++){
 18c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 193:	eb 26                	jmp    1bb <semtest+0x96>
    pid=fork();
 195:	e8 2f 03 00 00       	call   4c9 <fork>
 19a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid==0){
 19d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1a1:	75 14                	jne    1b7 <semtest+0x92>
      printf(1,"CONSUMIDOR\n" );
 1a3:	83 ec 08             	sub    $0x8,%esp
 1a6:	68 bb 05 00 00       	push   $0x5bb
 1ab:	6a 01                	push   $0x1
 1ad:	e8 4e fe ff ff       	call   0 <printf>
 1b2:	83 c4 10             	add    $0x10,%esp
      break;
 1b5:	eb 0a                	jmp    1c1 <semtest+0x9c>
  }
  if(pid==0){
    prod();
  }

  for(i=0;i<AMOUNTOFCONSUMERS;i++){
 1b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1bf:	7e d4                	jle    195 <semtest+0x70>
      printf(1,"CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
 1c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1c5:	75 05                	jne    1cc <semtest+0xa7>
    cons();
 1c7:	e8 e7 fe ff ff       	call   b3 <cons>
  }
  if(pid!=0){
 1cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1d0:	74 18                	je     1ea <semtest+0xc5>
    for(j=0;j<AMOUNTOFPRODUCERS+AMOUNTOFPRODUCERS;j++){
 1d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1d9:	eb 09                	jmp    1e4 <semtest+0xbf>
      wait();
 1db:	e8 f9 02 00 00       	call   4d9 <wait>
  }
  if(pid==0){
    cons();
  }
  if(pid!=0){
    for(j=0;j<AMOUNTOFPRODUCERS+AMOUNTOFPRODUCERS;j++){
 1e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 1e4:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
 1e8:	7e f1                	jle    1db <semtest+0xb6>
      wait();
    }
  }
}
 1ea:	90                   	nop
 1eb:	c9                   	leave  
 1ec:	c3                   	ret    

000001ed <main>:

int
main(void)
{
 1ed:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1f1:	83 e4 f0             	and    $0xfffffff0,%esp
 1f4:	ff 71 fc             	pushl  -0x4(%ecx)
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	51                   	push   %ecx
 1fb:	83 ec 04             	sub    $0x4,%esp
  semempty=semget(-1,0);
 1fe:	83 ec 08             	sub    $0x8,%esp
 201:	6a 00                	push   $0x0
 203:	6a ff                	push   $0xffffffff
 205:	e8 77 03 00 00       	call   581 <semget>
 20a:	83 c4 10             	add    $0x10,%esp
 20d:	a3 60 08 00 00       	mov    %eax,0x860
  printf(1,"despues de semget semempty\n" );
 212:	83 ec 08             	sub    $0x8,%esp
 215:	68 c7 05 00 00       	push   $0x5c7
 21a:	6a 01                	push   $0x1
 21c:	e8 df fd ff ff       	call   0 <printf>
 221:	83 c4 10             	add    $0x10,%esp

  semfull=semget(-1,S);
 224:	83 ec 08             	sub    $0x8,%esp
 227:	6a 64                	push   $0x64
 229:	6a ff                	push   $0xffffffff
 22b:	e8 51 03 00 00       	call   581 <semget>
 230:	83 c4 10             	add    $0x10,%esp
 233:	a3 64 08 00 00       	mov    %eax,0x864
  printf(1,"despues de semget semfull\n" );
 238:	83 ec 08             	sub    $0x8,%esp
 23b:	68 e3 05 00 00       	push   $0x5e3
 240:	6a 01                	push   $0x1
 242:	e8 b9 fd ff ff       	call   0 <printf>
 247:	83 c4 10             	add    $0x10,%esp

  semb=semget(-1,1);
 24a:	83 ec 08             	sub    $0x8,%esp
 24d:	6a 01                	push   $0x1
 24f:	6a ff                	push   $0xffffffff
 251:	e8 2b 03 00 00       	call   581 <semget>
 256:	83 c4 10             	add    $0x10,%esp
 259:	a3 5c 08 00 00       	mov    %eax,0x85c
  printf(1,"despues de semget semb\n" );
 25e:	83 ec 08             	sub    $0x8,%esp
 261:	68 fe 05 00 00       	push   $0x5fe
 266:	6a 01                	push   $0x1
 268:	e8 93 fd ff ff       	call   0 <printf>
 26d:	83 c4 10             	add    $0x10,%esp

  semtest();
 270:	e8 b0 fe ff ff       	call   125 <semtest>
  exit();
 275:	e8 57 02 00 00       	call   4d1 <exit>

0000027a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 27a:	55                   	push   %ebp
 27b:	89 e5                	mov    %esp,%ebp
 27d:	57                   	push   %edi
 27e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 27f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 282:	8b 55 10             	mov    0x10(%ebp),%edx
 285:	8b 45 0c             	mov    0xc(%ebp),%eax
 288:	89 cb                	mov    %ecx,%ebx
 28a:	89 df                	mov    %ebx,%edi
 28c:	89 d1                	mov    %edx,%ecx
 28e:	fc                   	cld    
 28f:	f3 aa                	rep stos %al,%es:(%edi)
 291:	89 ca                	mov    %ecx,%edx
 293:	89 fb                	mov    %edi,%ebx
 295:	89 5d 08             	mov    %ebx,0x8(%ebp)
 298:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 29b:	90                   	nop
 29c:	5b                   	pop    %ebx
 29d:	5f                   	pop    %edi
 29e:	5d                   	pop    %ebp
 29f:	c3                   	ret    

000002a0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2ac:	90                   	nop
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	8d 50 01             	lea    0x1(%eax),%edx
 2b3:	89 55 08             	mov    %edx,0x8(%ebp)
 2b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 2b9:	8d 4a 01             	lea    0x1(%edx),%ecx
 2bc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2bf:	0f b6 12             	movzbl (%edx),%edx
 2c2:	88 10                	mov    %dl,(%eax)
 2c4:	0f b6 00             	movzbl (%eax),%eax
 2c7:	84 c0                	test   %al,%al
 2c9:	75 e2                	jne    2ad <strcpy+0xd>
    ;
  return os;
 2cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ce:	c9                   	leave  
 2cf:	c3                   	ret    

000002d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d0:	55                   	push   %ebp
 2d1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2d3:	eb 08                	jmp    2dd <strcmp+0xd>
    p++, q++;
 2d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2d9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	0f b6 00             	movzbl (%eax),%eax
 2e3:	84 c0                	test   %al,%al
 2e5:	74 10                	je     2f7 <strcmp+0x27>
 2e7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ea:	0f b6 10             	movzbl (%eax),%edx
 2ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f0:	0f b6 00             	movzbl (%eax),%eax
 2f3:	38 c2                	cmp    %al,%dl
 2f5:	74 de                	je     2d5 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	0f b6 00             	movzbl (%eax),%eax
 2fd:	0f b6 d0             	movzbl %al,%edx
 300:	8b 45 0c             	mov    0xc(%ebp),%eax
 303:	0f b6 00             	movzbl (%eax),%eax
 306:	0f b6 c0             	movzbl %al,%eax
 309:	29 c2                	sub    %eax,%edx
 30b:	89 d0                	mov    %edx,%eax
}
 30d:	5d                   	pop    %ebp
 30e:	c3                   	ret    

0000030f <strlen>:

uint
strlen(char *s)
{
 30f:	55                   	push   %ebp
 310:	89 e5                	mov    %esp,%ebp
 312:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 315:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 31c:	eb 04                	jmp    322 <strlen+0x13>
 31e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 322:	8b 55 fc             	mov    -0x4(%ebp),%edx
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	01 d0                	add    %edx,%eax
 32a:	0f b6 00             	movzbl (%eax),%eax
 32d:	84 c0                	test   %al,%al
 32f:	75 ed                	jne    31e <strlen+0xf>
    ;
  return n;
 331:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 334:	c9                   	leave  
 335:	c3                   	ret    

00000336 <memset>:

void*
memset(void *dst, int c, uint n)
{
 336:	55                   	push   %ebp
 337:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 339:	8b 45 10             	mov    0x10(%ebp),%eax
 33c:	50                   	push   %eax
 33d:	ff 75 0c             	pushl  0xc(%ebp)
 340:	ff 75 08             	pushl  0x8(%ebp)
 343:	e8 32 ff ff ff       	call   27a <stosb>
 348:	83 c4 0c             	add    $0xc,%esp
  return dst;
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34e:	c9                   	leave  
 34f:	c3                   	ret    

00000350 <strchr>:

char*
strchr(const char *s, char c)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	83 ec 04             	sub    $0x4,%esp
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 35c:	eb 14                	jmp    372 <strchr+0x22>
    if(*s == c)
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
 361:	0f b6 00             	movzbl (%eax),%eax
 364:	3a 45 fc             	cmp    -0x4(%ebp),%al
 367:	75 05                	jne    36e <strchr+0x1e>
      return (char*)s;
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	eb 13                	jmp    381 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 36e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	0f b6 00             	movzbl (%eax),%eax
 378:	84 c0                	test   %al,%al
 37a:	75 e2                	jne    35e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 37c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <gets>:

char*
gets(char *buf, int max)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 389:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 390:	eb 42                	jmp    3d4 <gets+0x51>
    cc = read(0, &c, 1);
 392:	83 ec 04             	sub    $0x4,%esp
 395:	6a 01                	push   $0x1
 397:	8d 45 ef             	lea    -0x11(%ebp),%eax
 39a:	50                   	push   %eax
 39b:	6a 00                	push   $0x0
 39d:	e8 47 01 00 00       	call   4e9 <read>
 3a2:	83 c4 10             	add    $0x10,%esp
 3a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ac:	7e 33                	jle    3e1 <gets+0x5e>
      break;
    buf[i++] = c;
 3ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b1:	8d 50 01             	lea    0x1(%eax),%edx
 3b4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3b7:	89 c2                	mov    %eax,%edx
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	01 c2                	add    %eax,%edx
 3be:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c8:	3c 0a                	cmp    $0xa,%al
 3ca:	74 16                	je     3e2 <gets+0x5f>
 3cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d0:	3c 0d                	cmp    $0xd,%al
 3d2:	74 0e                	je     3e2 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d7:	83 c0 01             	add    $0x1,%eax
 3da:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3dd:	7c b3                	jl     392 <gets+0xf>
 3df:	eb 01                	jmp    3e2 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3e1:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3e5:	8b 45 08             	mov    0x8(%ebp),%eax
 3e8:	01 d0                	add    %edx,%eax
 3ea:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f0:	c9                   	leave  
 3f1:	c3                   	ret    

000003f2 <stat>:

int
stat(char *n, struct stat *st)
{
 3f2:	55                   	push   %ebp
 3f3:	89 e5                	mov    %esp,%ebp
 3f5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3f8:	83 ec 08             	sub    $0x8,%esp
 3fb:	6a 00                	push   $0x0
 3fd:	ff 75 08             	pushl  0x8(%ebp)
 400:	e8 0c 01 00 00       	call   511 <open>
 405:	83 c4 10             	add    $0x10,%esp
 408:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 40b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 40f:	79 07                	jns    418 <stat+0x26>
    return -1;
 411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 416:	eb 25                	jmp    43d <stat+0x4b>
  r = fstat(fd, st);
 418:	83 ec 08             	sub    $0x8,%esp
 41b:	ff 75 0c             	pushl  0xc(%ebp)
 41e:	ff 75 f4             	pushl  -0xc(%ebp)
 421:	e8 03 01 00 00       	call   529 <fstat>
 426:	83 c4 10             	add    $0x10,%esp
 429:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 42c:	83 ec 0c             	sub    $0xc,%esp
 42f:	ff 75 f4             	pushl  -0xc(%ebp)
 432:	e8 c2 00 00 00       	call   4f9 <close>
 437:	83 c4 10             	add    $0x10,%esp
  return r;
 43a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 43d:	c9                   	leave  
 43e:	c3                   	ret    

0000043f <atoi>:

int
atoi(const char *s)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 445:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 44c:	eb 25                	jmp    473 <atoi+0x34>
    n = n*10 + *s++ - '0';
 44e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 451:	89 d0                	mov    %edx,%eax
 453:	c1 e0 02             	shl    $0x2,%eax
 456:	01 d0                	add    %edx,%eax
 458:	01 c0                	add    %eax,%eax
 45a:	89 c1                	mov    %eax,%ecx
 45c:	8b 45 08             	mov    0x8(%ebp),%eax
 45f:	8d 50 01             	lea    0x1(%eax),%edx
 462:	89 55 08             	mov    %edx,0x8(%ebp)
 465:	0f b6 00             	movzbl (%eax),%eax
 468:	0f be c0             	movsbl %al,%eax
 46b:	01 c8                	add    %ecx,%eax
 46d:	83 e8 30             	sub    $0x30,%eax
 470:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	0f b6 00             	movzbl (%eax),%eax
 479:	3c 2f                	cmp    $0x2f,%al
 47b:	7e 0a                	jle    487 <atoi+0x48>
 47d:	8b 45 08             	mov    0x8(%ebp),%eax
 480:	0f b6 00             	movzbl (%eax),%eax
 483:	3c 39                	cmp    $0x39,%al
 485:	7e c7                	jle    44e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 487:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 48a:	c9                   	leave  
 48b:	c3                   	ret    

0000048c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 48c:	55                   	push   %ebp
 48d:	89 e5                	mov    %esp,%ebp
 48f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 492:	8b 45 08             	mov    0x8(%ebp),%eax
 495:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 498:	8b 45 0c             	mov    0xc(%ebp),%eax
 49b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 49e:	eb 17                	jmp    4b7 <memmove+0x2b>
    *dst++ = *src++;
 4a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4a3:	8d 50 01             	lea    0x1(%eax),%edx
 4a6:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4a9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ac:	8d 4a 01             	lea    0x1(%edx),%ecx
 4af:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4b2:	0f b6 12             	movzbl (%edx),%edx
 4b5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4b7:	8b 45 10             	mov    0x10(%ebp),%eax
 4ba:	8d 50 ff             	lea    -0x1(%eax),%edx
 4bd:	89 55 10             	mov    %edx,0x10(%ebp)
 4c0:	85 c0                	test   %eax,%eax
 4c2:	7f dc                	jg     4a0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4c7:	c9                   	leave  
 4c8:	c3                   	ret    

000004c9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4c9:	b8 01 00 00 00       	mov    $0x1,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	ret    

000004d1 <exit>:
SYSCALL(exit)
 4d1:	b8 02 00 00 00       	mov    $0x2,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <wait>:
SYSCALL(wait)
 4d9:	b8 03 00 00 00       	mov    $0x3,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <pipe>:
SYSCALL(pipe)
 4e1:	b8 04 00 00 00       	mov    $0x4,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <read>:
SYSCALL(read)
 4e9:	b8 05 00 00 00       	mov    $0x5,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <write>:
SYSCALL(write)
 4f1:	b8 10 00 00 00       	mov    $0x10,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <close>:
SYSCALL(close)
 4f9:	b8 15 00 00 00       	mov    $0x15,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	ret    

00000501 <kill>:
SYSCALL(kill)
 501:	b8 06 00 00 00       	mov    $0x6,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	ret    

00000509 <exec>:
SYSCALL(exec)
 509:	b8 07 00 00 00       	mov    $0x7,%eax
 50e:	cd 40                	int    $0x40
 510:	c3                   	ret    

00000511 <open>:
SYSCALL(open)
 511:	b8 0f 00 00 00       	mov    $0xf,%eax
 516:	cd 40                	int    $0x40
 518:	c3                   	ret    

00000519 <mknod>:
SYSCALL(mknod)
 519:	b8 11 00 00 00       	mov    $0x11,%eax
 51e:	cd 40                	int    $0x40
 520:	c3                   	ret    

00000521 <unlink>:
SYSCALL(unlink)
 521:	b8 12 00 00 00       	mov    $0x12,%eax
 526:	cd 40                	int    $0x40
 528:	c3                   	ret    

00000529 <fstat>:
SYSCALL(fstat)
 529:	b8 08 00 00 00       	mov    $0x8,%eax
 52e:	cd 40                	int    $0x40
 530:	c3                   	ret    

00000531 <link>:
SYSCALL(link)
 531:	b8 13 00 00 00       	mov    $0x13,%eax
 536:	cd 40                	int    $0x40
 538:	c3                   	ret    

00000539 <mkdir>:
SYSCALL(mkdir)
 539:	b8 14 00 00 00       	mov    $0x14,%eax
 53e:	cd 40                	int    $0x40
 540:	c3                   	ret    

00000541 <chdir>:
SYSCALL(chdir)
 541:	b8 09 00 00 00       	mov    $0x9,%eax
 546:	cd 40                	int    $0x40
 548:	c3                   	ret    

00000549 <dup>:
SYSCALL(dup)
 549:	b8 0a 00 00 00       	mov    $0xa,%eax
 54e:	cd 40                	int    $0x40
 550:	c3                   	ret    

00000551 <getpid>:
SYSCALL(getpid)
 551:	b8 0b 00 00 00       	mov    $0xb,%eax
 556:	cd 40                	int    $0x40
 558:	c3                   	ret    

00000559 <sbrk>:
SYSCALL(sbrk)
 559:	b8 0c 00 00 00       	mov    $0xc,%eax
 55e:	cd 40                	int    $0x40
 560:	c3                   	ret    

00000561 <sleep>:
SYSCALL(sleep)
 561:	b8 0d 00 00 00       	mov    $0xd,%eax
 566:	cd 40                	int    $0x40
 568:	c3                   	ret    

00000569 <uptime>:
SYSCALL(uptime)
 569:	b8 0e 00 00 00       	mov    $0xe,%eax
 56e:	cd 40                	int    $0x40
 570:	c3                   	ret    

00000571 <procstat>:
SYSCALL(procstat)
 571:	b8 16 00 00 00       	mov    $0x16,%eax
 576:	cd 40                	int    $0x40
 578:	c3                   	ret    

00000579 <setpriority>:
SYSCALL(setpriority)
 579:	b8 17 00 00 00       	mov    $0x17,%eax
 57e:	cd 40                	int    $0x40
 580:	c3                   	ret    

00000581 <semget>:
SYSCALL(semget)
 581:	b8 18 00 00 00       	mov    $0x18,%eax
 586:	cd 40                	int    $0x40
 588:	c3                   	ret    

00000589 <semfree>:
SYSCALL(semfree)
 589:	b8 19 00 00 00       	mov    $0x19,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret    

00000591 <semdown>:
SYSCALL(semdown)
 591:	b8 1a 00 00 00       	mov    $0x1a,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <semup>:
SYSCALL(semup)
 599:	b8 1b 00 00 00       	mov    $0x1b,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    
