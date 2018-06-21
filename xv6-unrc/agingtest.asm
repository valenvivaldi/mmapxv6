
_agingtest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <agingtest>:



void
agingtest(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int pid;
  int i;

  printf(1, "agingtest test\n");
   6:	83 ec 08             	sub    $0x8,%esp
   9:	68 3f 08 00 00       	push   $0x83f
   e:	6a 01                	push   $0x1
  10:	e8 74 04 00 00       	call   489 <printf>
  15:	83 c4 10             	add    $0x10,%esp

  for(i=0;i<4;i++){
  18:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1f:	eb 12                	jmp    33 <agingtest+0x33>
    pid=fork();
  21:	e8 a4 02 00 00       	call   2ca <fork>
  26:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(pid==0)
  29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  2d:	74 0c                	je     3b <agingtest+0x3b>
  int pid;
  int i;

  printf(1, "agingtest test\n");

  for(i=0;i<4;i++){
  2f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  33:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  37:	7e e8                	jle    21 <agingtest+0x21>
  39:	eb 01                	jmp    3c <agingtest+0x3c>
    pid=fork();

    if(pid==0)
      break;
  3b:	90                   	nop
  }
  if (pid==0){
  3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  40:	75 0f                	jne    51 <agingtest+0x51>
    for(;;){
      setpriority(0);
  42:	83 ec 0c             	sub    $0xc,%esp
  45:	6a 00                	push   $0x0
  47:	e8 36 03 00 00       	call   382 <setpriority>
  4c:	83 c4 10             	add    $0x10,%esp
    }
  4f:	eb f1                	jmp    42 <agingtest+0x42>
  }else{
    setpriority(3);
  51:	83 ec 0c             	sub    $0xc,%esp
  54:	6a 03                	push   $0x3
  56:	e8 27 03 00 00       	call   382 <setpriority>
  5b:	83 c4 10             	add    $0x10,%esp
    for(;;){

    }
  5e:	eb fe                	jmp    5e <agingtest+0x5e>

00000060 <main>:
  printf(1, "aging test OK\n");
}

int
main(void)
{
  60:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  64:	83 e4 f0             	and    $0xfffffff0,%esp
  67:	ff 71 fc             	pushl  -0x4(%ecx)
  6a:	55                   	push   %ebp
  6b:	89 e5                	mov    %esp,%ebp
  6d:	51                   	push   %ecx
  6e:	83 ec 04             	sub    $0x4,%esp
  agingtest();
  71:	e8 8a ff ff ff       	call   0 <agingtest>
  exit();
  76:	e8 57 02 00 00       	call   2d2 <exit>

0000007b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7b:	55                   	push   %ebp
  7c:	89 e5                	mov    %esp,%ebp
  7e:	57                   	push   %edi
  7f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  83:	8b 55 10             	mov    0x10(%ebp),%edx
  86:	8b 45 0c             	mov    0xc(%ebp),%eax
  89:	89 cb                	mov    %ecx,%ebx
  8b:	89 df                	mov    %ebx,%edi
  8d:	89 d1                	mov    %edx,%ecx
  8f:	fc                   	cld    
  90:	f3 aa                	rep stos %al,%es:(%edi)
  92:	89 ca                	mov    %ecx,%edx
  94:	89 fb                	mov    %edi,%ebx
  96:	89 5d 08             	mov    %ebx,0x8(%ebp)
  99:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9c:	90                   	nop
  9d:	5b                   	pop    %ebx
  9e:	5f                   	pop    %edi
  9f:	5d                   	pop    %ebp
  a0:	c3                   	ret    

000000a1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a1:	55                   	push   %ebp
  a2:	89 e5                	mov    %esp,%ebp
  a4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ad:	90                   	nop
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	8d 50 01             	lea    0x1(%eax),%edx
  b4:	89 55 08             	mov    %edx,0x8(%ebp)
  b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  bd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  c0:	0f b6 12             	movzbl (%edx),%edx
  c3:	88 10                	mov    %dl,(%eax)
  c5:	0f b6 00             	movzbl (%eax),%eax
  c8:	84 c0                	test   %al,%al
  ca:	75 e2                	jne    ae <strcpy+0xd>
    ;
  return os;
  cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cf:	c9                   	leave  
  d0:	c3                   	ret    

000000d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d4:	eb 08                	jmp    de <strcmp+0xd>
    p++, q++;
  d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  da:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  de:	8b 45 08             	mov    0x8(%ebp),%eax
  e1:	0f b6 00             	movzbl (%eax),%eax
  e4:	84 c0                	test   %al,%al
  e6:	74 10                	je     f8 <strcmp+0x27>
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	0f b6 10             	movzbl (%eax),%edx
  ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  f1:	0f b6 00             	movzbl (%eax),%eax
  f4:	38 c2                	cmp    %al,%dl
  f6:	74 de                	je     d6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	0f b6 d0             	movzbl %al,%edx
 101:	8b 45 0c             	mov    0xc(%ebp),%eax
 104:	0f b6 00             	movzbl (%eax),%eax
 107:	0f b6 c0             	movzbl %al,%eax
 10a:	29 c2                	sub    %eax,%edx
 10c:	89 d0                	mov    %edx,%eax
}
 10e:	5d                   	pop    %ebp
 10f:	c3                   	ret    

00000110 <strlen>:

uint
strlen(char *s)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 116:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 11d:	eb 04                	jmp    123 <strlen+0x13>
 11f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 123:	8b 55 fc             	mov    -0x4(%ebp),%edx
 126:	8b 45 08             	mov    0x8(%ebp),%eax
 129:	01 d0                	add    %edx,%eax
 12b:	0f b6 00             	movzbl (%eax),%eax
 12e:	84 c0                	test   %al,%al
 130:	75 ed                	jne    11f <strlen+0xf>
    ;
  return n;
 132:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 135:	c9                   	leave  
 136:	c3                   	ret    

00000137 <memset>:

void*
memset(void *dst, int c, uint n)
{
 137:	55                   	push   %ebp
 138:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 13a:	8b 45 10             	mov    0x10(%ebp),%eax
 13d:	50                   	push   %eax
 13e:	ff 75 0c             	pushl  0xc(%ebp)
 141:	ff 75 08             	pushl  0x8(%ebp)
 144:	e8 32 ff ff ff       	call   7b <stosb>
 149:	83 c4 0c             	add    $0xc,%esp
  return dst;
 14c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14f:	c9                   	leave  
 150:	c3                   	ret    

00000151 <strchr>:

char*
strchr(const char *s, char c)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 04             	sub    $0x4,%esp
 157:	8b 45 0c             	mov    0xc(%ebp),%eax
 15a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15d:	eb 14                	jmp    173 <strchr+0x22>
    if(*s == c)
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
 162:	0f b6 00             	movzbl (%eax),%eax
 165:	3a 45 fc             	cmp    -0x4(%ebp),%al
 168:	75 05                	jne    16f <strchr+0x1e>
      return (char*)s;
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	eb 13                	jmp    182 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 16f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	0f b6 00             	movzbl (%eax),%eax
 179:	84 c0                	test   %al,%al
 17b:	75 e2                	jne    15f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 17d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 182:	c9                   	leave  
 183:	c3                   	ret    

00000184 <gets>:

char*
gets(char *buf, int max)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 191:	eb 42                	jmp    1d5 <gets+0x51>
    cc = read(0, &c, 1);
 193:	83 ec 04             	sub    $0x4,%esp
 196:	6a 01                	push   $0x1
 198:	8d 45 ef             	lea    -0x11(%ebp),%eax
 19b:	50                   	push   %eax
 19c:	6a 00                	push   $0x0
 19e:	e8 47 01 00 00       	call   2ea <read>
 1a3:	83 c4 10             	add    $0x10,%esp
 1a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ad:	7e 33                	jle    1e2 <gets+0x5e>
      break;
    buf[i++] = c;
 1af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b2:	8d 50 01             	lea    0x1(%eax),%edx
 1b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1b8:	89 c2                	mov    %eax,%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 c2                	add    %eax,%edx
 1bf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c3:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	3c 0a                	cmp    $0xa,%al
 1cb:	74 16                	je     1e3 <gets+0x5f>
 1cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d1:	3c 0d                	cmp    $0xd,%al
 1d3:	74 0e                	je     1e3 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	83 c0 01             	add    $0x1,%eax
 1db:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1de:	7c b3                	jl     193 <gets+0xf>
 1e0:	eb 01                	jmp    1e3 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1e2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	01 d0                	add    %edx,%eax
 1eb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f1:	c9                   	leave  
 1f2:	c3                   	ret    

000001f3 <stat>:

int
stat(char *n, struct stat *st)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f9:	83 ec 08             	sub    $0x8,%esp
 1fc:	6a 00                	push   $0x0
 1fe:	ff 75 08             	pushl  0x8(%ebp)
 201:	e8 14 01 00 00       	call   31a <open>
 206:	83 c4 10             	add    $0x10,%esp
 209:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 210:	79 07                	jns    219 <stat+0x26>
    return -1;
 212:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 217:	eb 25                	jmp    23e <stat+0x4b>
  r = fstat(fd, st);
 219:	83 ec 08             	sub    $0x8,%esp
 21c:	ff 75 0c             	pushl  0xc(%ebp)
 21f:	ff 75 f4             	pushl  -0xc(%ebp)
 222:	e8 0b 01 00 00       	call   332 <fstat>
 227:	83 c4 10             	add    $0x10,%esp
 22a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22d:	83 ec 0c             	sub    $0xc,%esp
 230:	ff 75 f4             	pushl  -0xc(%ebp)
 233:	e8 ca 00 00 00       	call   302 <close>
 238:	83 c4 10             	add    $0x10,%esp
  return r;
 23b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23e:	c9                   	leave  
 23f:	c3                   	ret    

00000240 <atoi>:

int
atoi(const char *s)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 246:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24d:	eb 25                	jmp    274 <atoi+0x34>
    n = n*10 + *s++ - '0';
 24f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 252:	89 d0                	mov    %edx,%eax
 254:	c1 e0 02             	shl    $0x2,%eax
 257:	01 d0                	add    %edx,%eax
 259:	01 c0                	add    %eax,%eax
 25b:	89 c1                	mov    %eax,%ecx
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	8d 50 01             	lea    0x1(%eax),%edx
 263:	89 55 08             	mov    %edx,0x8(%ebp)
 266:	0f b6 00             	movzbl (%eax),%eax
 269:	0f be c0             	movsbl %al,%eax
 26c:	01 c8                	add    %ecx,%eax
 26e:	83 e8 30             	sub    $0x30,%eax
 271:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	0f b6 00             	movzbl (%eax),%eax
 27a:	3c 2f                	cmp    $0x2f,%al
 27c:	7e 0a                	jle    288 <atoi+0x48>
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	0f b6 00             	movzbl (%eax),%eax
 284:	3c 39                	cmp    $0x39,%al
 286:	7e c7                	jle    24f <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 288:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28b:	c9                   	leave  
 28c:	c3                   	ret    

0000028d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 299:	8b 45 0c             	mov    0xc(%ebp),%eax
 29c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 29f:	eb 17                	jmp    2b8 <memmove+0x2b>
    *dst++ = *src++;
 2a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a4:	8d 50 01             	lea    0x1(%eax),%edx
 2a7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ad:	8d 4a 01             	lea    0x1(%edx),%ecx
 2b0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2b3:	0f b6 12             	movzbl (%edx),%edx
 2b6:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b8:	8b 45 10             	mov    0x10(%ebp),%eax
 2bb:	8d 50 ff             	lea    -0x1(%eax),%edx
 2be:	89 55 10             	mov    %edx,0x10(%ebp)
 2c1:	85 c0                	test   %eax,%eax
 2c3:	7f dc                	jg     2a1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2ca:	b8 01 00 00 00       	mov    $0x1,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <exit>:
SYSCALL(exit)
 2d2:	b8 02 00 00 00       	mov    $0x2,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <wait>:
SYSCALL(wait)
 2da:	b8 03 00 00 00       	mov    $0x3,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <pipe>:
SYSCALL(pipe)
 2e2:	b8 04 00 00 00       	mov    $0x4,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <read>:
SYSCALL(read)
 2ea:	b8 05 00 00 00       	mov    $0x5,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <seek>:
SYSCALL(seek)
 2f2:	b8 1c 00 00 00       	mov    $0x1c,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <write>:
SYSCALL(write)
 2fa:	b8 10 00 00 00       	mov    $0x10,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <close>:
SYSCALL(close)
 302:	b8 15 00 00 00       	mov    $0x15,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <kill>:
SYSCALL(kill)
 30a:	b8 06 00 00 00       	mov    $0x6,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <exec>:
SYSCALL(exec)
 312:	b8 07 00 00 00       	mov    $0x7,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <open>:
SYSCALL(open)
 31a:	b8 0f 00 00 00       	mov    $0xf,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <mknod>:
SYSCALL(mknod)
 322:	b8 11 00 00 00       	mov    $0x11,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <unlink>:
SYSCALL(unlink)
 32a:	b8 12 00 00 00       	mov    $0x12,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <fstat>:
SYSCALL(fstat)
 332:	b8 08 00 00 00       	mov    $0x8,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <link>:
SYSCALL(link)
 33a:	b8 13 00 00 00       	mov    $0x13,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <mkdir>:
SYSCALL(mkdir)
 342:	b8 14 00 00 00       	mov    $0x14,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <chdir>:
SYSCALL(chdir)
 34a:	b8 09 00 00 00       	mov    $0x9,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <dup>:
SYSCALL(dup)
 352:	b8 0a 00 00 00       	mov    $0xa,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <getpid>:
SYSCALL(getpid)
 35a:	b8 0b 00 00 00       	mov    $0xb,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <sbrk>:
SYSCALL(sbrk)
 362:	b8 0c 00 00 00       	mov    $0xc,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <sleep>:
SYSCALL(sleep)
 36a:	b8 0d 00 00 00       	mov    $0xd,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <uptime>:
SYSCALL(uptime)
 372:	b8 0e 00 00 00       	mov    $0xe,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <procstat>:
SYSCALL(procstat)
 37a:	b8 16 00 00 00       	mov    $0x16,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <setpriority>:
SYSCALL(setpriority)
 382:	b8 17 00 00 00       	mov    $0x17,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <semget>:
SYSCALL(semget)
 38a:	b8 18 00 00 00       	mov    $0x18,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <semfree>:
SYSCALL(semfree)
 392:	b8 19 00 00 00       	mov    $0x19,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <semdown>:
SYSCALL(semdown)
 39a:	b8 1a 00 00 00       	mov    $0x1a,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <semup>:
SYSCALL(semup)
 3a2:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <mmap>:
SYSCALL(mmap)
 3aa:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b2:	55                   	push   %ebp
 3b3:	89 e5                	mov    %esp,%ebp
 3b5:	83 ec 18             	sub    $0x18,%esp
 3b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bb:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3be:	83 ec 04             	sub    $0x4,%esp
 3c1:	6a 01                	push   $0x1
 3c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c6:	50                   	push   %eax
 3c7:	ff 75 08             	pushl  0x8(%ebp)
 3ca:	e8 2b ff ff ff       	call   2fa <write>
 3cf:	83 c4 10             	add    $0x10,%esp
}
 3d2:	90                   	nop
 3d3:	c9                   	leave  
 3d4:	c3                   	ret    

000003d5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d5:	55                   	push   %ebp
 3d6:	89 e5                	mov    %esp,%ebp
 3d8:	53                   	push   %ebx
 3d9:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e7:	74 17                	je     400 <printint+0x2b>
 3e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ed:	79 11                	jns    400 <printint+0x2b>
    neg = 1;
 3ef:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	f7 d8                	neg    %eax
 3fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fe:	eb 06                	jmp    406 <printint+0x31>
  } else {
    x = xx;
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 406:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 40d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 410:	8d 41 01             	lea    0x1(%ecx),%eax
 413:	89 45 f4             	mov    %eax,-0xc(%ebp)
 416:	8b 5d 10             	mov    0x10(%ebp),%ebx
 419:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41c:	ba 00 00 00 00       	mov    $0x0,%edx
 421:	f7 f3                	div    %ebx
 423:	89 d0                	mov    %edx,%eax
 425:	0f b6 80 bc 0a 00 00 	movzbl 0xabc(%eax),%eax
 42c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 430:	8b 5d 10             	mov    0x10(%ebp),%ebx
 433:	8b 45 ec             	mov    -0x14(%ebp),%eax
 436:	ba 00 00 00 00       	mov    $0x0,%edx
 43b:	f7 f3                	div    %ebx
 43d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 440:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 444:	75 c7                	jne    40d <printint+0x38>
  if(neg)
 446:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44a:	74 2d                	je     479 <printint+0xa4>
    buf[i++] = '-';
 44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44f:	8d 50 01             	lea    0x1(%eax),%edx
 452:	89 55 f4             	mov    %edx,-0xc(%ebp)
 455:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 45a:	eb 1d                	jmp    479 <printint+0xa4>
    putc(fd, buf[i]);
 45c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 45f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 462:	01 d0                	add    %edx,%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	0f be c0             	movsbl %al,%eax
 46a:	83 ec 08             	sub    $0x8,%esp
 46d:	50                   	push   %eax
 46e:	ff 75 08             	pushl  0x8(%ebp)
 471:	e8 3c ff ff ff       	call   3b2 <putc>
 476:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 479:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 47d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 481:	79 d9                	jns    45c <printint+0x87>
    putc(fd, buf[i]);
}
 483:	90                   	nop
 484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 487:	c9                   	leave  
 488:	c3                   	ret    

00000489 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 489:	55                   	push   %ebp
 48a:	89 e5                	mov    %esp,%ebp
 48c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 48f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 496:	8d 45 0c             	lea    0xc(%ebp),%eax
 499:	83 c0 04             	add    $0x4,%eax
 49c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 49f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a6:	e9 59 01 00 00       	jmp    604 <printf+0x17b>
    c = fmt[i] & 0xff;
 4ab:	8b 55 0c             	mov    0xc(%ebp),%edx
 4ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b1:	01 d0                	add    %edx,%eax
 4b3:	0f b6 00             	movzbl (%eax),%eax
 4b6:	0f be c0             	movsbl %al,%eax
 4b9:	25 ff 00 00 00       	and    $0xff,%eax
 4be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c5:	75 2c                	jne    4f3 <printf+0x6a>
      if(c == '%'){
 4c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4cb:	75 0c                	jne    4d9 <printf+0x50>
        state = '%';
 4cd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d4:	e9 27 01 00 00       	jmp    600 <printf+0x177>
      } else {
        putc(fd, c);
 4d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4dc:	0f be c0             	movsbl %al,%eax
 4df:	83 ec 08             	sub    $0x8,%esp
 4e2:	50                   	push   %eax
 4e3:	ff 75 08             	pushl  0x8(%ebp)
 4e6:	e8 c7 fe ff ff       	call   3b2 <putc>
 4eb:	83 c4 10             	add    $0x10,%esp
 4ee:	e9 0d 01 00 00       	jmp    600 <printf+0x177>
      }
    } else if(state == '%'){
 4f3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f7:	0f 85 03 01 00 00    	jne    600 <printf+0x177>
      if(c == 'd'){
 4fd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 501:	75 1e                	jne    521 <printf+0x98>
        printint(fd, *ap, 10, 1);
 503:	8b 45 e8             	mov    -0x18(%ebp),%eax
 506:	8b 00                	mov    (%eax),%eax
 508:	6a 01                	push   $0x1
 50a:	6a 0a                	push   $0xa
 50c:	50                   	push   %eax
 50d:	ff 75 08             	pushl  0x8(%ebp)
 510:	e8 c0 fe ff ff       	call   3d5 <printint>
 515:	83 c4 10             	add    $0x10,%esp
        ap++;
 518:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51c:	e9 d8 00 00 00       	jmp    5f9 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 521:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 525:	74 06                	je     52d <printf+0xa4>
 527:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 52b:	75 1e                	jne    54b <printf+0xc2>
        printint(fd, *ap, 16, 0);
 52d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 530:	8b 00                	mov    (%eax),%eax
 532:	6a 00                	push   $0x0
 534:	6a 10                	push   $0x10
 536:	50                   	push   %eax
 537:	ff 75 08             	pushl  0x8(%ebp)
 53a:	e8 96 fe ff ff       	call   3d5 <printint>
 53f:	83 c4 10             	add    $0x10,%esp
        ap++;
 542:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 546:	e9 ae 00 00 00       	jmp    5f9 <printf+0x170>
      } else if(c == 's'){
 54b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 54f:	75 43                	jne    594 <printf+0x10b>
        s = (char*)*ap;
 551:	8b 45 e8             	mov    -0x18(%ebp),%eax
 554:	8b 00                	mov    (%eax),%eax
 556:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 559:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 55d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 561:	75 25                	jne    588 <printf+0xff>
          s = "(null)";
 563:	c7 45 f4 4f 08 00 00 	movl   $0x84f,-0xc(%ebp)
        while(*s != 0){
 56a:	eb 1c                	jmp    588 <printf+0xff>
          putc(fd, *s);
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	0f b6 00             	movzbl (%eax),%eax
 572:	0f be c0             	movsbl %al,%eax
 575:	83 ec 08             	sub    $0x8,%esp
 578:	50                   	push   %eax
 579:	ff 75 08             	pushl  0x8(%ebp)
 57c:	e8 31 fe ff ff       	call   3b2 <putc>
 581:	83 c4 10             	add    $0x10,%esp
          s++;
 584:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 588:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58b:	0f b6 00             	movzbl (%eax),%eax
 58e:	84 c0                	test   %al,%al
 590:	75 da                	jne    56c <printf+0xe3>
 592:	eb 65                	jmp    5f9 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 594:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 598:	75 1d                	jne    5b7 <printf+0x12e>
        putc(fd, *ap);
 59a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59d:	8b 00                	mov    (%eax),%eax
 59f:	0f be c0             	movsbl %al,%eax
 5a2:	83 ec 08             	sub    $0x8,%esp
 5a5:	50                   	push   %eax
 5a6:	ff 75 08             	pushl  0x8(%ebp)
 5a9:	e8 04 fe ff ff       	call   3b2 <putc>
 5ae:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b5:	eb 42                	jmp    5f9 <printf+0x170>
      } else if(c == '%'){
 5b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5bb:	75 17                	jne    5d4 <printf+0x14b>
        putc(fd, c);
 5bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c0:	0f be c0             	movsbl %al,%eax
 5c3:	83 ec 08             	sub    $0x8,%esp
 5c6:	50                   	push   %eax
 5c7:	ff 75 08             	pushl  0x8(%ebp)
 5ca:	e8 e3 fd ff ff       	call   3b2 <putc>
 5cf:	83 c4 10             	add    $0x10,%esp
 5d2:	eb 25                	jmp    5f9 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d4:	83 ec 08             	sub    $0x8,%esp
 5d7:	6a 25                	push   $0x25
 5d9:	ff 75 08             	pushl  0x8(%ebp)
 5dc:	e8 d1 fd ff ff       	call   3b2 <putc>
 5e1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e7:	0f be c0             	movsbl %al,%eax
 5ea:	83 ec 08             	sub    $0x8,%esp
 5ed:	50                   	push   %eax
 5ee:	ff 75 08             	pushl  0x8(%ebp)
 5f1:	e8 bc fd ff ff       	call   3b2 <putc>
 5f6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5f9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 600:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 604:	8b 55 0c             	mov    0xc(%ebp),%edx
 607:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60a:	01 d0                	add    %edx,%eax
 60c:	0f b6 00             	movzbl (%eax),%eax
 60f:	84 c0                	test   %al,%al
 611:	0f 85 94 fe ff ff    	jne    4ab <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 617:	90                   	nop
 618:	c9                   	leave  
 619:	c3                   	ret    

0000061a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 61a:	55                   	push   %ebp
 61b:	89 e5                	mov    %esp,%ebp
 61d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 620:	8b 45 08             	mov    0x8(%ebp),%eax
 623:	83 e8 08             	sub    $0x8,%eax
 626:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 629:	a1 d8 0a 00 00       	mov    0xad8,%eax
 62e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 631:	eb 24                	jmp    657 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 633:	8b 45 fc             	mov    -0x4(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63b:	77 12                	ja     64f <free+0x35>
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 643:	77 24                	ja     669 <free+0x4f>
 645:	8b 45 fc             	mov    -0x4(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 64d:	77 1a                	ja     669 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	89 45 fc             	mov    %eax,-0x4(%ebp)
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65d:	76 d4                	jbe    633 <free+0x19>
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 667:	76 ca                	jbe    633 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 669:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66c:	8b 40 04             	mov    0x4(%eax),%eax
 66f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 676:	8b 45 f8             	mov    -0x8(%ebp),%eax
 679:	01 c2                	add    %eax,%edx
 67b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67e:	8b 00                	mov    (%eax),%eax
 680:	39 c2                	cmp    %eax,%edx
 682:	75 24                	jne    6a8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 684:	8b 45 f8             	mov    -0x8(%ebp),%eax
 687:	8b 50 04             	mov    0x4(%eax),%edx
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	8b 40 04             	mov    0x4(%eax),%eax
 692:	01 c2                	add    %eax,%edx
 694:	8b 45 f8             	mov    -0x8(%ebp),%eax
 697:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	8b 00                	mov    (%eax),%eax
 69f:	8b 10                	mov    (%eax),%edx
 6a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a4:	89 10                	mov    %edx,(%eax)
 6a6:	eb 0a                	jmp    6b2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	8b 10                	mov    (%eax),%edx
 6ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	8b 40 04             	mov    0x4(%eax),%eax
 6b8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	01 d0                	add    %edx,%eax
 6c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c7:	75 20                	jne    6e9 <free+0xcf>
    p->s.size += bp->s.size;
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 50 04             	mov    0x4(%eax),%edx
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	8b 40 04             	mov    0x4(%eax),%eax
 6d5:	01 c2                	add    %eax,%edx
 6d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6da:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e0:	8b 10                	mov    (%eax),%edx
 6e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e5:	89 10                	mov    %edx,(%eax)
 6e7:	eb 08                	jmp    6f1 <free+0xd7>
  } else
    p->s.ptr = bp;
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ef:	89 10                	mov    %edx,(%eax)
  freep = p;
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	a3 d8 0a 00 00       	mov    %eax,0xad8
}
 6f9:	90                   	nop
 6fa:	c9                   	leave  
 6fb:	c3                   	ret    

000006fc <morecore>:

static Header*
morecore(uint nu)
{
 6fc:	55                   	push   %ebp
 6fd:	89 e5                	mov    %esp,%ebp
 6ff:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 702:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 709:	77 07                	ja     712 <morecore+0x16>
    nu = 4096;
 70b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 712:	8b 45 08             	mov    0x8(%ebp),%eax
 715:	c1 e0 03             	shl    $0x3,%eax
 718:	83 ec 0c             	sub    $0xc,%esp
 71b:	50                   	push   %eax
 71c:	e8 41 fc ff ff       	call   362 <sbrk>
 721:	83 c4 10             	add    $0x10,%esp
 724:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 727:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 72b:	75 07                	jne    734 <morecore+0x38>
    return 0;
 72d:	b8 00 00 00 00       	mov    $0x0,%eax
 732:	eb 26                	jmp    75a <morecore+0x5e>
  hp = (Header*)p;
 734:	8b 45 f4             	mov    -0xc(%ebp),%eax
 737:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73d:	8b 55 08             	mov    0x8(%ebp),%edx
 740:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 743:	8b 45 f0             	mov    -0x10(%ebp),%eax
 746:	83 c0 08             	add    $0x8,%eax
 749:	83 ec 0c             	sub    $0xc,%esp
 74c:	50                   	push   %eax
 74d:	e8 c8 fe ff ff       	call   61a <free>
 752:	83 c4 10             	add    $0x10,%esp
  return freep;
 755:	a1 d8 0a 00 00       	mov    0xad8,%eax
}
 75a:	c9                   	leave  
 75b:	c3                   	ret    

0000075c <malloc>:

void*
malloc(uint nbytes)
{
 75c:	55                   	push   %ebp
 75d:	89 e5                	mov    %esp,%ebp
 75f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	83 c0 07             	add    $0x7,%eax
 768:	c1 e8 03             	shr    $0x3,%eax
 76b:	83 c0 01             	add    $0x1,%eax
 76e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 771:	a1 d8 0a 00 00       	mov    0xad8,%eax
 776:	89 45 f0             	mov    %eax,-0x10(%ebp)
 779:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 77d:	75 23                	jne    7a2 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 77f:	c7 45 f0 d0 0a 00 00 	movl   $0xad0,-0x10(%ebp)
 786:	8b 45 f0             	mov    -0x10(%ebp),%eax
 789:	a3 d8 0a 00 00       	mov    %eax,0xad8
 78e:	a1 d8 0a 00 00       	mov    0xad8,%eax
 793:	a3 d0 0a 00 00       	mov    %eax,0xad0
    base.s.size = 0;
 798:	c7 05 d4 0a 00 00 00 	movl   $0x0,0xad4
 79f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	8b 00                	mov    (%eax),%eax
 7a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ad:	8b 40 04             	mov    0x4(%eax),%eax
 7b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7b3:	72 4d                	jb     802 <malloc+0xa6>
      if(p->s.size == nunits)
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7be:	75 0c                	jne    7cc <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	8b 10                	mov    (%eax),%edx
 7c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c8:	89 10                	mov    %edx,(%eax)
 7ca:	eb 26                	jmp    7f2 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 40 04             	mov    0x4(%eax),%eax
 7d2:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7d5:	89 c2                	mov    %eax,%edx
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	8b 40 04             	mov    0x4(%eax),%eax
 7e3:	c1 e0 03             	shl    $0x3,%eax
 7e6:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ef:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f5:	a3 d8 0a 00 00       	mov    %eax,0xad8
      return (void*)(p + 1);
 7fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fd:	83 c0 08             	add    $0x8,%eax
 800:	eb 3b                	jmp    83d <malloc+0xe1>
    }
    if(p == freep)
 802:	a1 d8 0a 00 00       	mov    0xad8,%eax
 807:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 80a:	75 1e                	jne    82a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 80c:	83 ec 0c             	sub    $0xc,%esp
 80f:	ff 75 ec             	pushl  -0x14(%ebp)
 812:	e8 e5 fe ff ff       	call   6fc <morecore>
 817:	83 c4 10             	add    $0x10,%esp
 81a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 81d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 821:	75 07                	jne    82a <malloc+0xce>
        return 0;
 823:	b8 00 00 00 00       	mov    $0x0,%eax
 828:	eb 13                	jmp    83d <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 00                	mov    (%eax),%eax
 835:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 838:	e9 6d ff ff ff       	jmp    7aa <malloc+0x4e>
}
 83d:	c9                   	leave  
 83e:	c3                   	ret    
