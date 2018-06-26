
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
   9:	68 47 08 00 00       	push   $0x847
   e:	6a 01                	push   $0x1
  10:	e8 7c 04 00 00       	call   491 <printf>
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

000003b2 <munmap>:
SYSCALL(munmap)
 3b2:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3ba:	55                   	push   %ebp
 3bb:	89 e5                	mov    %esp,%ebp
 3bd:	83 ec 18             	sub    $0x18,%esp
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c6:	83 ec 04             	sub    $0x4,%esp
 3c9:	6a 01                	push   $0x1
 3cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ce:	50                   	push   %eax
 3cf:	ff 75 08             	pushl  0x8(%ebp)
 3d2:	e8 23 ff ff ff       	call   2fa <write>
 3d7:	83 c4 10             	add    $0x10,%esp
}
 3da:	90                   	nop
 3db:	c9                   	leave  
 3dc:	c3                   	ret    

000003dd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3dd:	55                   	push   %ebp
 3de:	89 e5                	mov    %esp,%ebp
 3e0:	53                   	push   %ebx
 3e1:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3eb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ef:	74 17                	je     408 <printint+0x2b>
 3f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f5:	79 11                	jns    408 <printint+0x2b>
    neg = 1;
 3f7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 401:	f7 d8                	neg    %eax
 403:	89 45 ec             	mov    %eax,-0x14(%ebp)
 406:	eb 06                	jmp    40e <printint+0x31>
  } else {
    x = xx;
 408:	8b 45 0c             	mov    0xc(%ebp),%eax
 40b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 415:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 418:	8d 41 01             	lea    0x1(%ecx),%eax
 41b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 41e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 421:	8b 45 ec             	mov    -0x14(%ebp),%eax
 424:	ba 00 00 00 00       	mov    $0x0,%edx
 429:	f7 f3                	div    %ebx
 42b:	89 d0                	mov    %edx,%eax
 42d:	0f b6 80 c4 0a 00 00 	movzbl 0xac4(%eax),%eax
 434:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 438:	8b 5d 10             	mov    0x10(%ebp),%ebx
 43b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43e:	ba 00 00 00 00       	mov    $0x0,%edx
 443:	f7 f3                	div    %ebx
 445:	89 45 ec             	mov    %eax,-0x14(%ebp)
 448:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 44c:	75 c7                	jne    415 <printint+0x38>
  if(neg)
 44e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 452:	74 2d                	je     481 <printint+0xa4>
    buf[i++] = '-';
 454:	8b 45 f4             	mov    -0xc(%ebp),%eax
 457:	8d 50 01             	lea    0x1(%eax),%edx
 45a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 462:	eb 1d                	jmp    481 <printint+0xa4>
    putc(fd, buf[i]);
 464:	8d 55 dc             	lea    -0x24(%ebp),%edx
 467:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46a:	01 d0                	add    %edx,%eax
 46c:	0f b6 00             	movzbl (%eax),%eax
 46f:	0f be c0             	movsbl %al,%eax
 472:	83 ec 08             	sub    $0x8,%esp
 475:	50                   	push   %eax
 476:	ff 75 08             	pushl  0x8(%ebp)
 479:	e8 3c ff ff ff       	call   3ba <putc>
 47e:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 481:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 485:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 489:	79 d9                	jns    464 <printint+0x87>
    putc(fd, buf[i]);
}
 48b:	90                   	nop
 48c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 48f:	c9                   	leave  
 490:	c3                   	ret    

00000491 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 491:	55                   	push   %ebp
 492:	89 e5                	mov    %esp,%ebp
 494:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 497:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 49e:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a1:	83 c0 04             	add    $0x4,%eax
 4a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ae:	e9 59 01 00 00       	jmp    60c <printf+0x17b>
    c = fmt[i] & 0xff;
 4b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b9:	01 d0                	add    %edx,%eax
 4bb:	0f b6 00             	movzbl (%eax),%eax
 4be:	0f be c0             	movsbl %al,%eax
 4c1:	25 ff 00 00 00       	and    $0xff,%eax
 4c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cd:	75 2c                	jne    4fb <printf+0x6a>
      if(c == '%'){
 4cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d3:	75 0c                	jne    4e1 <printf+0x50>
        state = '%';
 4d5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4dc:	e9 27 01 00 00       	jmp    608 <printf+0x177>
      } else {
        putc(fd, c);
 4e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	83 ec 08             	sub    $0x8,%esp
 4ea:	50                   	push   %eax
 4eb:	ff 75 08             	pushl  0x8(%ebp)
 4ee:	e8 c7 fe ff ff       	call   3ba <putc>
 4f3:	83 c4 10             	add    $0x10,%esp
 4f6:	e9 0d 01 00 00       	jmp    608 <printf+0x177>
      }
    } else if(state == '%'){
 4fb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ff:	0f 85 03 01 00 00    	jne    608 <printf+0x177>
      if(c == 'd'){
 505:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 509:	75 1e                	jne    529 <printf+0x98>
        printint(fd, *ap, 10, 1);
 50b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50e:	8b 00                	mov    (%eax),%eax
 510:	6a 01                	push   $0x1
 512:	6a 0a                	push   $0xa
 514:	50                   	push   %eax
 515:	ff 75 08             	pushl  0x8(%ebp)
 518:	e8 c0 fe ff ff       	call   3dd <printint>
 51d:	83 c4 10             	add    $0x10,%esp
        ap++;
 520:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 524:	e9 d8 00 00 00       	jmp    601 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 529:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52d:	74 06                	je     535 <printf+0xa4>
 52f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 533:	75 1e                	jne    553 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 535:	8b 45 e8             	mov    -0x18(%ebp),%eax
 538:	8b 00                	mov    (%eax),%eax
 53a:	6a 00                	push   $0x0
 53c:	6a 10                	push   $0x10
 53e:	50                   	push   %eax
 53f:	ff 75 08             	pushl  0x8(%ebp)
 542:	e8 96 fe ff ff       	call   3dd <printint>
 547:	83 c4 10             	add    $0x10,%esp
        ap++;
 54a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54e:	e9 ae 00 00 00       	jmp    601 <printf+0x170>
      } else if(c == 's'){
 553:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 557:	75 43                	jne    59c <printf+0x10b>
        s = (char*)*ap;
 559:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55c:	8b 00                	mov    (%eax),%eax
 55e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 561:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 565:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 569:	75 25                	jne    590 <printf+0xff>
          s = "(null)";
 56b:	c7 45 f4 57 08 00 00 	movl   $0x857,-0xc(%ebp)
        while(*s != 0){
 572:	eb 1c                	jmp    590 <printf+0xff>
          putc(fd, *s);
 574:	8b 45 f4             	mov    -0xc(%ebp),%eax
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	83 ec 08             	sub    $0x8,%esp
 580:	50                   	push   %eax
 581:	ff 75 08             	pushl  0x8(%ebp)
 584:	e8 31 fe ff ff       	call   3ba <putc>
 589:	83 c4 10             	add    $0x10,%esp
          s++;
 58c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 590:	8b 45 f4             	mov    -0xc(%ebp),%eax
 593:	0f b6 00             	movzbl (%eax),%eax
 596:	84 c0                	test   %al,%al
 598:	75 da                	jne    574 <printf+0xe3>
 59a:	eb 65                	jmp    601 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 59c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5a0:	75 1d                	jne    5bf <printf+0x12e>
        putc(fd, *ap);
 5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a5:	8b 00                	mov    (%eax),%eax
 5a7:	0f be c0             	movsbl %al,%eax
 5aa:	83 ec 08             	sub    $0x8,%esp
 5ad:	50                   	push   %eax
 5ae:	ff 75 08             	pushl  0x8(%ebp)
 5b1:	e8 04 fe ff ff       	call   3ba <putc>
 5b6:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bd:	eb 42                	jmp    601 <printf+0x170>
      } else if(c == '%'){
 5bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c3:	75 17                	jne    5dc <printf+0x14b>
        putc(fd, c);
 5c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c8:	0f be c0             	movsbl %al,%eax
 5cb:	83 ec 08             	sub    $0x8,%esp
 5ce:	50                   	push   %eax
 5cf:	ff 75 08             	pushl  0x8(%ebp)
 5d2:	e8 e3 fd ff ff       	call   3ba <putc>
 5d7:	83 c4 10             	add    $0x10,%esp
 5da:	eb 25                	jmp    601 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5dc:	83 ec 08             	sub    $0x8,%esp
 5df:	6a 25                	push   $0x25
 5e1:	ff 75 08             	pushl  0x8(%ebp)
 5e4:	e8 d1 fd ff ff       	call   3ba <putc>
 5e9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ef:	0f be c0             	movsbl %al,%eax
 5f2:	83 ec 08             	sub    $0x8,%esp
 5f5:	50                   	push   %eax
 5f6:	ff 75 08             	pushl  0x8(%ebp)
 5f9:	e8 bc fd ff ff       	call   3ba <putc>
 5fe:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 601:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 608:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60c:	8b 55 0c             	mov    0xc(%ebp),%edx
 60f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 612:	01 d0                	add    %edx,%eax
 614:	0f b6 00             	movzbl (%eax),%eax
 617:	84 c0                	test   %al,%al
 619:	0f 85 94 fe ff ff    	jne    4b3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 61f:	90                   	nop
 620:	c9                   	leave  
 621:	c3                   	ret    

00000622 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 622:	55                   	push   %ebp
 623:	89 e5                	mov    %esp,%ebp
 625:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 628:	8b 45 08             	mov    0x8(%ebp),%eax
 62b:	83 e8 08             	sub    $0x8,%eax
 62e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 631:	a1 e0 0a 00 00       	mov    0xae0,%eax
 636:	89 45 fc             	mov    %eax,-0x4(%ebp)
 639:	eb 24                	jmp    65f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 63b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63e:	8b 00                	mov    (%eax),%eax
 640:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 643:	77 12                	ja     657 <free+0x35>
 645:	8b 45 f8             	mov    -0x8(%ebp),%eax
 648:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64b:	77 24                	ja     671 <free+0x4f>
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 655:	77 1a                	ja     671 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 657:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65a:	8b 00                	mov    (%eax),%eax
 65c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 665:	76 d4                	jbe    63b <free+0x19>
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 00                	mov    (%eax),%eax
 66c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 66f:	76 ca                	jbe    63b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 671:	8b 45 f8             	mov    -0x8(%ebp),%eax
 674:	8b 40 04             	mov    0x4(%eax),%eax
 677:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	01 c2                	add    %eax,%edx
 683:	8b 45 fc             	mov    -0x4(%ebp),%eax
 686:	8b 00                	mov    (%eax),%eax
 688:	39 c2                	cmp    %eax,%edx
 68a:	75 24                	jne    6b0 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 68c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68f:	8b 50 04             	mov    0x4(%eax),%edx
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	8b 40 04             	mov    0x4(%eax),%eax
 69a:	01 c2                	add    %eax,%edx
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	8b 00                	mov    (%eax),%eax
 6a7:	8b 10                	mov    (%eax),%edx
 6a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ac:	89 10                	mov    %edx,(%eax)
 6ae:	eb 0a                	jmp    6ba <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	8b 10                	mov    (%eax),%edx
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bd:	8b 40 04             	mov    0x4(%eax),%eax
 6c0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ca:	01 d0                	add    %edx,%eax
 6cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6cf:	75 20                	jne    6f1 <free+0xcf>
    p->s.size += bp->s.size;
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	8b 50 04             	mov    0x4(%eax),%edx
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	8b 40 04             	mov    0x4(%eax),%eax
 6dd:	01 c2                	add    %eax,%edx
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e8:	8b 10                	mov    (%eax),%edx
 6ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ed:	89 10                	mov    %edx,(%eax)
 6ef:	eb 08                	jmp    6f9 <free+0xd7>
  } else
    p->s.ptr = bp;
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6f7:	89 10                	mov    %edx,(%eax)
  freep = p;
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	a3 e0 0a 00 00       	mov    %eax,0xae0
}
 701:	90                   	nop
 702:	c9                   	leave  
 703:	c3                   	ret    

00000704 <morecore>:

static Header*
morecore(uint nu)
{
 704:	55                   	push   %ebp
 705:	89 e5                	mov    %esp,%ebp
 707:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 70a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 711:	77 07                	ja     71a <morecore+0x16>
    nu = 4096;
 713:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 71a:	8b 45 08             	mov    0x8(%ebp),%eax
 71d:	c1 e0 03             	shl    $0x3,%eax
 720:	83 ec 0c             	sub    $0xc,%esp
 723:	50                   	push   %eax
 724:	e8 39 fc ff ff       	call   362 <sbrk>
 729:	83 c4 10             	add    $0x10,%esp
 72c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 72f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 733:	75 07                	jne    73c <morecore+0x38>
    return 0;
 735:	b8 00 00 00 00       	mov    $0x0,%eax
 73a:	eb 26                	jmp    762 <morecore+0x5e>
  hp = (Header*)p;
 73c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 742:	8b 45 f0             	mov    -0x10(%ebp),%eax
 745:	8b 55 08             	mov    0x8(%ebp),%edx
 748:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 74b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74e:	83 c0 08             	add    $0x8,%eax
 751:	83 ec 0c             	sub    $0xc,%esp
 754:	50                   	push   %eax
 755:	e8 c8 fe ff ff       	call   622 <free>
 75a:	83 c4 10             	add    $0x10,%esp
  return freep;
 75d:	a1 e0 0a 00 00       	mov    0xae0,%eax
}
 762:	c9                   	leave  
 763:	c3                   	ret    

00000764 <malloc>:

void*
malloc(uint nbytes)
{
 764:	55                   	push   %ebp
 765:	89 e5                	mov    %esp,%ebp
 767:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76a:	8b 45 08             	mov    0x8(%ebp),%eax
 76d:	83 c0 07             	add    $0x7,%eax
 770:	c1 e8 03             	shr    $0x3,%eax
 773:	83 c0 01             	add    $0x1,%eax
 776:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 779:	a1 e0 0a 00 00       	mov    0xae0,%eax
 77e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 781:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 785:	75 23                	jne    7aa <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 787:	c7 45 f0 d8 0a 00 00 	movl   $0xad8,-0x10(%ebp)
 78e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 791:	a3 e0 0a 00 00       	mov    %eax,0xae0
 796:	a1 e0 0a 00 00       	mov    0xae0,%eax
 79b:	a3 d8 0a 00 00       	mov    %eax,0xad8
    base.s.size = 0;
 7a0:	c7 05 dc 0a 00 00 00 	movl   $0x0,0xadc
 7a7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ad:	8b 00                	mov    (%eax),%eax
 7af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b5:	8b 40 04             	mov    0x4(%eax),%eax
 7b8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7bb:	72 4d                	jb     80a <malloc+0xa6>
      if(p->s.size == nunits)
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	8b 40 04             	mov    0x4(%eax),%eax
 7c3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c6:	75 0c                	jne    7d4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cb:	8b 10                	mov    (%eax),%edx
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	89 10                	mov    %edx,(%eax)
 7d2:	eb 26                	jmp    7fa <malloc+0x96>
      else {
        p->s.size -= nunits;
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	8b 40 04             	mov    0x4(%eax),%eax
 7da:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7dd:	89 c2                	mov    %eax,%edx
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	c1 e0 03             	shl    $0x3,%eax
 7ee:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fd:	a3 e0 0a 00 00       	mov    %eax,0xae0
      return (void*)(p + 1);
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	83 c0 08             	add    $0x8,%eax
 808:	eb 3b                	jmp    845 <malloc+0xe1>
    }
    if(p == freep)
 80a:	a1 e0 0a 00 00       	mov    0xae0,%eax
 80f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 812:	75 1e                	jne    832 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 814:	83 ec 0c             	sub    $0xc,%esp
 817:	ff 75 ec             	pushl  -0x14(%ebp)
 81a:	e8 e5 fe ff ff       	call   704 <morecore>
 81f:	83 c4 10             	add    $0x10,%esp
 822:	89 45 f4             	mov    %eax,-0xc(%ebp)
 825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 829:	75 07                	jne    832 <malloc+0xce>
        return 0;
 82b:	b8 00 00 00 00       	mov    $0x0,%eax
 830:	eb 13                	jmp    845 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	89 45 f0             	mov    %eax,-0x10(%ebp)
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 840:	e9 6d ff ff ff       	jmp    7b2 <malloc+0x4e>
}
 845:	c9                   	leave  
 846:	c3                   	ret    
