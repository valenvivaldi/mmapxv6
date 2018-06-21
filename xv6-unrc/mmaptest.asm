
_mmaptest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <mmaptest>:



void
mmaptest(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int i;
  char* buff;
  fd=open("README",O_RDWR);
   6:	83 ec 08             	sub    $0x8,%esp
   9:	6a 02                	push   $0x2
   b:	68 5a 08 00 00       	push   $0x85a
  10:	e8 20 03 00 00       	call   335 <open>
  15:	83 c4 10             	add    $0x10,%esp
  18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  mmap(fd,O_RDWR,&buff);
  1b:	83 ec 04             	sub    $0x4,%esp
  1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  21:	50                   	push   %eax
  22:	6a 02                	push   $0x2
  24:	ff 75 f0             	pushl  -0x10(%ebp)
  27:	e8 99 03 00 00       	call   3c5 <mmap>
  2c:	83 c4 10             	add    $0x10,%esp
  for(i=0;i<10000;i++){
  2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  36:	eb 25                	jmp    5d <mmaptest+0x5d>
    printf(1,"%c",buff[i] );
  38:	8b 55 ec             	mov    -0x14(%ebp),%edx
  3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3e:	01 d0                	add    %edx,%eax
  40:	0f b6 00             	movzbl (%eax),%eax
  43:	0f be c0             	movsbl %al,%eax
  46:	83 ec 04             	sub    $0x4,%esp
  49:	50                   	push   %eax
  4a:	68 61 08 00 00       	push   $0x861
  4f:	6a 01                	push   $0x1
  51:	e8 4e 04 00 00       	call   4a4 <printf>
  56:	83 c4 10             	add    $0x10,%esp
  int fd;
  int i;
  char* buff;
  fd=open("README",O_RDWR);
  mmap(fd,O_RDWR,&buff);
  for(i=0;i<10000;i++){
  59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5d:	81 7d f4 0f 27 00 00 	cmpl   $0x270f,-0xc(%ebp)
  64:	7e d2                	jle    38 <mmaptest+0x38>
    printf(1,"%c",buff[i] );
  }
  printf(1, "mmaptest ok\n");
  66:	83 ec 08             	sub    $0x8,%esp
  69:	68 64 08 00 00       	push   $0x864
  6e:	6a 01                	push   $0x1
  70:	e8 2f 04 00 00       	call   4a4 <printf>
  75:	83 c4 10             	add    $0x10,%esp
}
  78:	90                   	nop
  79:	c9                   	leave  
  7a:	c3                   	ret    

0000007b <main>:

int
main(void)
{
  7b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  7f:	83 e4 f0             	and    $0xfffffff0,%esp
  82:	ff 71 fc             	pushl  -0x4(%ecx)
  85:	55                   	push   %ebp
  86:	89 e5                	mov    %esp,%ebp
  88:	51                   	push   %ecx
  89:	83 ec 04             	sub    $0x4,%esp
  mmaptest();
  8c:	e8 6f ff ff ff       	call   0 <mmaptest>
  exit();
  91:	e8 57 02 00 00       	call   2ed <exit>

00000096 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  96:	55                   	push   %ebp
  97:	89 e5                	mov    %esp,%ebp
  99:	57                   	push   %edi
  9a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  9e:	8b 55 10             	mov    0x10(%ebp),%edx
  a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  a4:	89 cb                	mov    %ecx,%ebx
  a6:	89 df                	mov    %ebx,%edi
  a8:	89 d1                	mov    %edx,%ecx
  aa:	fc                   	cld    
  ab:	f3 aa                	rep stos %al,%es:(%edi)
  ad:	89 ca                	mov    %ecx,%edx
  af:	89 fb                	mov    %edi,%ebx
  b1:	89 5d 08             	mov    %ebx,0x8(%ebp)
  b4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b7:	90                   	nop
  b8:	5b                   	pop    %ebx
  b9:	5f                   	pop    %edi
  ba:	5d                   	pop    %ebp
  bb:	c3                   	ret    

000000bc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  bf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c8:	90                   	nop
  c9:	8b 45 08             	mov    0x8(%ebp),%eax
  cc:	8d 50 01             	lea    0x1(%eax),%edx
  cf:	89 55 08             	mov    %edx,0x8(%ebp)
  d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  d8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  db:	0f b6 12             	movzbl (%edx),%edx
  de:	88 10                	mov    %dl,(%eax)
  e0:	0f b6 00             	movzbl (%eax),%eax
  e3:	84 c0                	test   %al,%al
  e5:	75 e2                	jne    c9 <strcpy+0xd>
    ;
  return os;
  e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ea:	c9                   	leave  
  eb:	c3                   	ret    

000000ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ef:	eb 08                	jmp    f9 <strcmp+0xd>
    p++, q++;
  f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f9:	8b 45 08             	mov    0x8(%ebp),%eax
  fc:	0f b6 00             	movzbl (%eax),%eax
  ff:	84 c0                	test   %al,%al
 101:	74 10                	je     113 <strcmp+0x27>
 103:	8b 45 08             	mov    0x8(%ebp),%eax
 106:	0f b6 10             	movzbl (%eax),%edx
 109:	8b 45 0c             	mov    0xc(%ebp),%eax
 10c:	0f b6 00             	movzbl (%eax),%eax
 10f:	38 c2                	cmp    %al,%dl
 111:	74 de                	je     f1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	0f b6 00             	movzbl (%eax),%eax
 119:	0f b6 d0             	movzbl %al,%edx
 11c:	8b 45 0c             	mov    0xc(%ebp),%eax
 11f:	0f b6 00             	movzbl (%eax),%eax
 122:	0f b6 c0             	movzbl %al,%eax
 125:	29 c2                	sub    %eax,%edx
 127:	89 d0                	mov    %edx,%eax
}
 129:	5d                   	pop    %ebp
 12a:	c3                   	ret    

0000012b <strlen>:

uint
strlen(char *s)
{
 12b:	55                   	push   %ebp
 12c:	89 e5                	mov    %esp,%ebp
 12e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 131:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 138:	eb 04                	jmp    13e <strlen+0x13>
 13a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 13e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	01 d0                	add    %edx,%eax
 146:	0f b6 00             	movzbl (%eax),%eax
 149:	84 c0                	test   %al,%al
 14b:	75 ed                	jne    13a <strlen+0xf>
    ;
  return n;
 14d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 150:	c9                   	leave  
 151:	c3                   	ret    

00000152 <memset>:

void*
memset(void *dst, int c, uint n)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 155:	8b 45 10             	mov    0x10(%ebp),%eax
 158:	50                   	push   %eax
 159:	ff 75 0c             	pushl  0xc(%ebp)
 15c:	ff 75 08             	pushl  0x8(%ebp)
 15f:	e8 32 ff ff ff       	call   96 <stosb>
 164:	83 c4 0c             	add    $0xc,%esp
  return dst;
 167:	8b 45 08             	mov    0x8(%ebp),%eax
}
 16a:	c9                   	leave  
 16b:	c3                   	ret    

0000016c <strchr>:

char*
strchr(const char *s, char c)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	83 ec 04             	sub    $0x4,%esp
 172:	8b 45 0c             	mov    0xc(%ebp),%eax
 175:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 178:	eb 14                	jmp    18e <strchr+0x22>
    if(*s == c)
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	3a 45 fc             	cmp    -0x4(%ebp),%al
 183:	75 05                	jne    18a <strchr+0x1e>
      return (char*)s;
 185:	8b 45 08             	mov    0x8(%ebp),%eax
 188:	eb 13                	jmp    19d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 18a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	0f b6 00             	movzbl (%eax),%eax
 194:	84 c0                	test   %al,%al
 196:	75 e2                	jne    17a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 198:	b8 00 00 00 00       	mov    $0x0,%eax
}
 19d:	c9                   	leave  
 19e:	c3                   	ret    

0000019f <gets>:

char*
gets(char *buf, int max)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ac:	eb 42                	jmp    1f0 <gets+0x51>
    cc = read(0, &c, 1);
 1ae:	83 ec 04             	sub    $0x4,%esp
 1b1:	6a 01                	push   $0x1
 1b3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b6:	50                   	push   %eax
 1b7:	6a 00                	push   $0x0
 1b9:	e8 47 01 00 00       	call   305 <read>
 1be:	83 c4 10             	add    $0x10,%esp
 1c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c8:	7e 33                	jle    1fd <gets+0x5e>
      break;
    buf[i++] = c;
 1ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cd:	8d 50 01             	lea    0x1(%eax),%edx
 1d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1d3:	89 c2                	mov    %eax,%edx
 1d5:	8b 45 08             	mov    0x8(%ebp),%eax
 1d8:	01 c2                	add    %eax,%edx
 1da:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1de:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e4:	3c 0a                	cmp    $0xa,%al
 1e6:	74 16                	je     1fe <gets+0x5f>
 1e8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ec:	3c 0d                	cmp    $0xd,%al
 1ee:	74 0e                	je     1fe <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f3:	83 c0 01             	add    $0x1,%eax
 1f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f9:	7c b3                	jl     1ae <gets+0xf>
 1fb:	eb 01                	jmp    1fe <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1fd:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	01 d0                	add    %edx,%eax
 206:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 209:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20c:	c9                   	leave  
 20d:	c3                   	ret    

0000020e <stat>:

int
stat(char *n, struct stat *st)
{
 20e:	55                   	push   %ebp
 20f:	89 e5                	mov    %esp,%ebp
 211:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 214:	83 ec 08             	sub    $0x8,%esp
 217:	6a 00                	push   $0x0
 219:	ff 75 08             	pushl  0x8(%ebp)
 21c:	e8 14 01 00 00       	call   335 <open>
 221:	83 c4 10             	add    $0x10,%esp
 224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 227:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 22b:	79 07                	jns    234 <stat+0x26>
    return -1;
 22d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 232:	eb 25                	jmp    259 <stat+0x4b>
  r = fstat(fd, st);
 234:	83 ec 08             	sub    $0x8,%esp
 237:	ff 75 0c             	pushl  0xc(%ebp)
 23a:	ff 75 f4             	pushl  -0xc(%ebp)
 23d:	e8 0b 01 00 00       	call   34d <fstat>
 242:	83 c4 10             	add    $0x10,%esp
 245:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 248:	83 ec 0c             	sub    $0xc,%esp
 24b:	ff 75 f4             	pushl  -0xc(%ebp)
 24e:	e8 ca 00 00 00       	call   31d <close>
 253:	83 c4 10             	add    $0x10,%esp
  return r;
 256:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <atoi>:

int
atoi(const char *s)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 261:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 268:	eb 25                	jmp    28f <atoi+0x34>
    n = n*10 + *s++ - '0';
 26a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 26d:	89 d0                	mov    %edx,%eax
 26f:	c1 e0 02             	shl    $0x2,%eax
 272:	01 d0                	add    %edx,%eax
 274:	01 c0                	add    %eax,%eax
 276:	89 c1                	mov    %eax,%ecx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	8d 50 01             	lea    0x1(%eax),%edx
 27e:	89 55 08             	mov    %edx,0x8(%ebp)
 281:	0f b6 00             	movzbl (%eax),%eax
 284:	0f be c0             	movsbl %al,%eax
 287:	01 c8                	add    %ecx,%eax
 289:	83 e8 30             	sub    $0x30,%eax
 28c:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	0f b6 00             	movzbl (%eax),%eax
 295:	3c 2f                	cmp    $0x2f,%al
 297:	7e 0a                	jle    2a3 <atoi+0x48>
 299:	8b 45 08             	mov    0x8(%ebp),%eax
 29c:	0f b6 00             	movzbl (%eax),%eax
 29f:	3c 39                	cmp    $0x39,%al
 2a1:	7e c7                	jle    26a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a6:	c9                   	leave  
 2a7:	c3                   	ret    

000002a8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ba:	eb 17                	jmp    2d3 <memmove+0x2b>
    *dst++ = *src++;
 2bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2bf:	8d 50 01             	lea    0x1(%eax),%edx
 2c2:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2c5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c8:	8d 4a 01             	lea    0x1(%edx),%ecx
 2cb:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2ce:	0f b6 12             	movzbl (%edx),%edx
 2d1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2d3:	8b 45 10             	mov    0x10(%ebp),%eax
 2d6:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d9:	89 55 10             	mov    %edx,0x10(%ebp)
 2dc:	85 c0                	test   %eax,%eax
 2de:	7f dc                	jg     2bc <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    

000002e5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e5:	b8 01 00 00 00       	mov    $0x1,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <exit>:
SYSCALL(exit)
 2ed:	b8 02 00 00 00       	mov    $0x2,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <wait>:
SYSCALL(wait)
 2f5:	b8 03 00 00 00       	mov    $0x3,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <pipe>:
SYSCALL(pipe)
 2fd:	b8 04 00 00 00       	mov    $0x4,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <read>:
SYSCALL(read)
 305:	b8 05 00 00 00       	mov    $0x5,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <seek>:
SYSCALL(seek)
 30d:	b8 1c 00 00 00       	mov    $0x1c,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <write>:
SYSCALL(write)
 315:	b8 10 00 00 00       	mov    $0x10,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <close>:
SYSCALL(close)
 31d:	b8 15 00 00 00       	mov    $0x15,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <kill>:
SYSCALL(kill)
 325:	b8 06 00 00 00       	mov    $0x6,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <exec>:
SYSCALL(exec)
 32d:	b8 07 00 00 00       	mov    $0x7,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <open>:
SYSCALL(open)
 335:	b8 0f 00 00 00       	mov    $0xf,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <mknod>:
SYSCALL(mknod)
 33d:	b8 11 00 00 00       	mov    $0x11,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <unlink>:
SYSCALL(unlink)
 345:	b8 12 00 00 00       	mov    $0x12,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <fstat>:
SYSCALL(fstat)
 34d:	b8 08 00 00 00       	mov    $0x8,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <link>:
SYSCALL(link)
 355:	b8 13 00 00 00       	mov    $0x13,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <mkdir>:
SYSCALL(mkdir)
 35d:	b8 14 00 00 00       	mov    $0x14,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <chdir>:
SYSCALL(chdir)
 365:	b8 09 00 00 00       	mov    $0x9,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <dup>:
SYSCALL(dup)
 36d:	b8 0a 00 00 00       	mov    $0xa,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <getpid>:
SYSCALL(getpid)
 375:	b8 0b 00 00 00       	mov    $0xb,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <sbrk>:
SYSCALL(sbrk)
 37d:	b8 0c 00 00 00       	mov    $0xc,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <sleep>:
SYSCALL(sleep)
 385:	b8 0d 00 00 00       	mov    $0xd,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <uptime>:
SYSCALL(uptime)
 38d:	b8 0e 00 00 00       	mov    $0xe,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <procstat>:
SYSCALL(procstat)
 395:	b8 16 00 00 00       	mov    $0x16,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <setpriority>:
SYSCALL(setpriority)
 39d:	b8 17 00 00 00       	mov    $0x17,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <semget>:
SYSCALL(semget)
 3a5:	b8 18 00 00 00       	mov    $0x18,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <semfree>:
SYSCALL(semfree)
 3ad:	b8 19 00 00 00       	mov    $0x19,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <semdown>:
SYSCALL(semdown)
 3b5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <semup>:
SYSCALL(semup)
 3bd:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <mmap>:
SYSCALL(mmap)
 3c5:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3cd:	55                   	push   %ebp
 3ce:	89 e5                	mov    %esp,%ebp
 3d0:	83 ec 18             	sub    $0x18,%esp
 3d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3d9:	83 ec 04             	sub    $0x4,%esp
 3dc:	6a 01                	push   $0x1
 3de:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3e1:	50                   	push   %eax
 3e2:	ff 75 08             	pushl  0x8(%ebp)
 3e5:	e8 2b ff ff ff       	call   315 <write>
 3ea:	83 c4 10             	add    $0x10,%esp
}
 3ed:	90                   	nop
 3ee:	c9                   	leave  
 3ef:	c3                   	ret    

000003f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	53                   	push   %ebx
 3f4:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3fe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 402:	74 17                	je     41b <printint+0x2b>
 404:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 408:	79 11                	jns    41b <printint+0x2b>
    neg = 1;
 40a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 411:	8b 45 0c             	mov    0xc(%ebp),%eax
 414:	f7 d8                	neg    %eax
 416:	89 45 ec             	mov    %eax,-0x14(%ebp)
 419:	eb 06                	jmp    421 <printint+0x31>
  } else {
    x = xx;
 41b:	8b 45 0c             	mov    0xc(%ebp),%eax
 41e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 421:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 428:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 42b:	8d 41 01             	lea    0x1(%ecx),%eax
 42e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 431:	8b 5d 10             	mov    0x10(%ebp),%ebx
 434:	8b 45 ec             	mov    -0x14(%ebp),%eax
 437:	ba 00 00 00 00       	mov    $0x0,%edx
 43c:	f7 f3                	div    %ebx
 43e:	89 d0                	mov    %edx,%eax
 440:	0f b6 80 e0 0a 00 00 	movzbl 0xae0(%eax),%eax
 447:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 44b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 44e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 451:	ba 00 00 00 00       	mov    $0x0,%edx
 456:	f7 f3                	div    %ebx
 458:	89 45 ec             	mov    %eax,-0x14(%ebp)
 45b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 45f:	75 c7                	jne    428 <printint+0x38>
  if(neg)
 461:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 465:	74 2d                	je     494 <printint+0xa4>
    buf[i++] = '-';
 467:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46a:	8d 50 01             	lea    0x1(%eax),%edx
 46d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 470:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 475:	eb 1d                	jmp    494 <printint+0xa4>
    putc(fd, buf[i]);
 477:	8d 55 dc             	lea    -0x24(%ebp),%edx
 47a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47d:	01 d0                	add    %edx,%eax
 47f:	0f b6 00             	movzbl (%eax),%eax
 482:	0f be c0             	movsbl %al,%eax
 485:	83 ec 08             	sub    $0x8,%esp
 488:	50                   	push   %eax
 489:	ff 75 08             	pushl  0x8(%ebp)
 48c:	e8 3c ff ff ff       	call   3cd <putc>
 491:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 494:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 498:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 49c:	79 d9                	jns    477 <printint+0x87>
    putc(fd, buf[i]);
}
 49e:	90                   	nop
 49f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4a2:	c9                   	leave  
 4a3:	c3                   	ret    

000004a4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4a4:	55                   	push   %ebp
 4a5:	89 e5                	mov    %esp,%ebp
 4a7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4aa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4b1:	8d 45 0c             	lea    0xc(%ebp),%eax
 4b4:	83 c0 04             	add    $0x4,%eax
 4b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4c1:	e9 59 01 00 00       	jmp    61f <printf+0x17b>
    c = fmt[i] & 0xff;
 4c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 4c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4cc:	01 d0                	add    %edx,%eax
 4ce:	0f b6 00             	movzbl (%eax),%eax
 4d1:	0f be c0             	movsbl %al,%eax
 4d4:	25 ff 00 00 00       	and    $0xff,%eax
 4d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e0:	75 2c                	jne    50e <printf+0x6a>
      if(c == '%'){
 4e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4e6:	75 0c                	jne    4f4 <printf+0x50>
        state = '%';
 4e8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ef:	e9 27 01 00 00       	jmp    61b <printf+0x177>
      } else {
        putc(fd, c);
 4f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f7:	0f be c0             	movsbl %al,%eax
 4fa:	83 ec 08             	sub    $0x8,%esp
 4fd:	50                   	push   %eax
 4fe:	ff 75 08             	pushl  0x8(%ebp)
 501:	e8 c7 fe ff ff       	call   3cd <putc>
 506:	83 c4 10             	add    $0x10,%esp
 509:	e9 0d 01 00 00       	jmp    61b <printf+0x177>
      }
    } else if(state == '%'){
 50e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 512:	0f 85 03 01 00 00    	jne    61b <printf+0x177>
      if(c == 'd'){
 518:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 51c:	75 1e                	jne    53c <printf+0x98>
        printint(fd, *ap, 10, 1);
 51e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 521:	8b 00                	mov    (%eax),%eax
 523:	6a 01                	push   $0x1
 525:	6a 0a                	push   $0xa
 527:	50                   	push   %eax
 528:	ff 75 08             	pushl  0x8(%ebp)
 52b:	e8 c0 fe ff ff       	call   3f0 <printint>
 530:	83 c4 10             	add    $0x10,%esp
        ap++;
 533:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 537:	e9 d8 00 00 00       	jmp    614 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 53c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 540:	74 06                	je     548 <printf+0xa4>
 542:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 546:	75 1e                	jne    566 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 548:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54b:	8b 00                	mov    (%eax),%eax
 54d:	6a 00                	push   $0x0
 54f:	6a 10                	push   $0x10
 551:	50                   	push   %eax
 552:	ff 75 08             	pushl  0x8(%ebp)
 555:	e8 96 fe ff ff       	call   3f0 <printint>
 55a:	83 c4 10             	add    $0x10,%esp
        ap++;
 55d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 561:	e9 ae 00 00 00       	jmp    614 <printf+0x170>
      } else if(c == 's'){
 566:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 56a:	75 43                	jne    5af <printf+0x10b>
        s = (char*)*ap;
 56c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56f:	8b 00                	mov    (%eax),%eax
 571:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 574:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 578:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 57c:	75 25                	jne    5a3 <printf+0xff>
          s = "(null)";
 57e:	c7 45 f4 71 08 00 00 	movl   $0x871,-0xc(%ebp)
        while(*s != 0){
 585:	eb 1c                	jmp    5a3 <printf+0xff>
          putc(fd, *s);
 587:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58a:	0f b6 00             	movzbl (%eax),%eax
 58d:	0f be c0             	movsbl %al,%eax
 590:	83 ec 08             	sub    $0x8,%esp
 593:	50                   	push   %eax
 594:	ff 75 08             	pushl  0x8(%ebp)
 597:	e8 31 fe ff ff       	call   3cd <putc>
 59c:	83 c4 10             	add    $0x10,%esp
          s++;
 59f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a6:	0f b6 00             	movzbl (%eax),%eax
 5a9:	84 c0                	test   %al,%al
 5ab:	75 da                	jne    587 <printf+0xe3>
 5ad:	eb 65                	jmp    614 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5af:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5b3:	75 1d                	jne    5d2 <printf+0x12e>
        putc(fd, *ap);
 5b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b8:	8b 00                	mov    (%eax),%eax
 5ba:	0f be c0             	movsbl %al,%eax
 5bd:	83 ec 08             	sub    $0x8,%esp
 5c0:	50                   	push   %eax
 5c1:	ff 75 08             	pushl  0x8(%ebp)
 5c4:	e8 04 fe ff ff       	call   3cd <putc>
 5c9:	83 c4 10             	add    $0x10,%esp
        ap++;
 5cc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d0:	eb 42                	jmp    614 <printf+0x170>
      } else if(c == '%'){
 5d2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d6:	75 17                	jne    5ef <printf+0x14b>
        putc(fd, c);
 5d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5db:	0f be c0             	movsbl %al,%eax
 5de:	83 ec 08             	sub    $0x8,%esp
 5e1:	50                   	push   %eax
 5e2:	ff 75 08             	pushl  0x8(%ebp)
 5e5:	e8 e3 fd ff ff       	call   3cd <putc>
 5ea:	83 c4 10             	add    $0x10,%esp
 5ed:	eb 25                	jmp    614 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ef:	83 ec 08             	sub    $0x8,%esp
 5f2:	6a 25                	push   $0x25
 5f4:	ff 75 08             	pushl  0x8(%ebp)
 5f7:	e8 d1 fd ff ff       	call   3cd <putc>
 5fc:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	83 ec 08             	sub    $0x8,%esp
 608:	50                   	push   %eax
 609:	ff 75 08             	pushl  0x8(%ebp)
 60c:	e8 bc fd ff ff       	call   3cd <putc>
 611:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 614:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 61b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 61f:	8b 55 0c             	mov    0xc(%ebp),%edx
 622:	8b 45 f0             	mov    -0x10(%ebp),%eax
 625:	01 d0                	add    %edx,%eax
 627:	0f b6 00             	movzbl (%eax),%eax
 62a:	84 c0                	test   %al,%al
 62c:	0f 85 94 fe ff ff    	jne    4c6 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 632:	90                   	nop
 633:	c9                   	leave  
 634:	c3                   	ret    

00000635 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 635:	55                   	push   %ebp
 636:	89 e5                	mov    %esp,%ebp
 638:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	83 e8 08             	sub    $0x8,%eax
 641:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 644:	a1 fc 0a 00 00       	mov    0xafc,%eax
 649:	89 45 fc             	mov    %eax,-0x4(%ebp)
 64c:	eb 24                	jmp    672 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 656:	77 12                	ja     66a <free+0x35>
 658:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65e:	77 24                	ja     684 <free+0x4f>
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 668:	77 1a                	ja     684 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66d:	8b 00                	mov    (%eax),%eax
 66f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 672:	8b 45 f8             	mov    -0x8(%ebp),%eax
 675:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 678:	76 d4                	jbe    64e <free+0x19>
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 682:	76 ca                	jbe    64e <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 684:	8b 45 f8             	mov    -0x8(%ebp),%eax
 687:	8b 40 04             	mov    0x4(%eax),%eax
 68a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 691:	8b 45 f8             	mov    -0x8(%ebp),%eax
 694:	01 c2                	add    %eax,%edx
 696:	8b 45 fc             	mov    -0x4(%ebp),%eax
 699:	8b 00                	mov    (%eax),%eax
 69b:	39 c2                	cmp    %eax,%edx
 69d:	75 24                	jne    6c3 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 69f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a2:	8b 50 04             	mov    0x4(%eax),%edx
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	8b 00                	mov    (%eax),%eax
 6aa:	8b 40 04             	mov    0x4(%eax),%eax
 6ad:	01 c2                	add    %eax,%edx
 6af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b2:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	8b 10                	mov    (%eax),%edx
 6bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bf:	89 10                	mov    %edx,(%eax)
 6c1:	eb 0a                	jmp    6cd <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	8b 10                	mov    (%eax),%edx
 6c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cb:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 40 04             	mov    0x4(%eax),%eax
 6d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dd:	01 d0                	add    %edx,%eax
 6df:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e2:	75 20                	jne    704 <free+0xcf>
    p->s.size += bp->s.size;
 6e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e7:	8b 50 04             	mov    0x4(%eax),%edx
 6ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ed:	8b 40 04             	mov    0x4(%eax),%eax
 6f0:	01 c2                	add    %eax,%edx
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fb:	8b 10                	mov    (%eax),%edx
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	89 10                	mov    %edx,(%eax)
 702:	eb 08                	jmp    70c <free+0xd7>
  } else
    p->s.ptr = bp;
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 55 f8             	mov    -0x8(%ebp),%edx
 70a:	89 10                	mov    %edx,(%eax)
  freep = p;
 70c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70f:	a3 fc 0a 00 00       	mov    %eax,0xafc
}
 714:	90                   	nop
 715:	c9                   	leave  
 716:	c3                   	ret    

00000717 <morecore>:

static Header*
morecore(uint nu)
{
 717:	55                   	push   %ebp
 718:	89 e5                	mov    %esp,%ebp
 71a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 71d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 724:	77 07                	ja     72d <morecore+0x16>
    nu = 4096;
 726:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	c1 e0 03             	shl    $0x3,%eax
 733:	83 ec 0c             	sub    $0xc,%esp
 736:	50                   	push   %eax
 737:	e8 41 fc ff ff       	call   37d <sbrk>
 73c:	83 c4 10             	add    $0x10,%esp
 73f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 742:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 746:	75 07                	jne    74f <morecore+0x38>
    return 0;
 748:	b8 00 00 00 00       	mov    $0x0,%eax
 74d:	eb 26                	jmp    775 <morecore+0x5e>
  hp = (Header*)p;
 74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 755:	8b 45 f0             	mov    -0x10(%ebp),%eax
 758:	8b 55 08             	mov    0x8(%ebp),%edx
 75b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 75e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 761:	83 c0 08             	add    $0x8,%eax
 764:	83 ec 0c             	sub    $0xc,%esp
 767:	50                   	push   %eax
 768:	e8 c8 fe ff ff       	call   635 <free>
 76d:	83 c4 10             	add    $0x10,%esp
  return freep;
 770:	a1 fc 0a 00 00       	mov    0xafc,%eax
}
 775:	c9                   	leave  
 776:	c3                   	ret    

00000777 <malloc>:

void*
malloc(uint nbytes)
{
 777:	55                   	push   %ebp
 778:	89 e5                	mov    %esp,%ebp
 77a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77d:	8b 45 08             	mov    0x8(%ebp),%eax
 780:	83 c0 07             	add    $0x7,%eax
 783:	c1 e8 03             	shr    $0x3,%eax
 786:	83 c0 01             	add    $0x1,%eax
 789:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 78c:	a1 fc 0a 00 00       	mov    0xafc,%eax
 791:	89 45 f0             	mov    %eax,-0x10(%ebp)
 794:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 798:	75 23                	jne    7bd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 79a:	c7 45 f0 f4 0a 00 00 	movl   $0xaf4,-0x10(%ebp)
 7a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a4:	a3 fc 0a 00 00       	mov    %eax,0xafc
 7a9:	a1 fc 0a 00 00       	mov    0xafc,%eax
 7ae:	a3 f4 0a 00 00       	mov    %eax,0xaf4
    base.s.size = 0;
 7b3:	c7 05 f8 0a 00 00 00 	movl   $0x0,0xaf8
 7ba:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c8:	8b 40 04             	mov    0x4(%eax),%eax
 7cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ce:	72 4d                	jb     81d <malloc+0xa6>
      if(p->s.size == nunits)
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	8b 40 04             	mov    0x4(%eax),%eax
 7d6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7d9:	75 0c                	jne    7e7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7de:	8b 10                	mov    (%eax),%edx
 7e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e3:	89 10                	mov    %edx,(%eax)
 7e5:	eb 26                	jmp    80d <malloc+0x96>
      else {
        p->s.size -= nunits;
 7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ea:	8b 40 04             	mov    0x4(%eax),%eax
 7ed:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7f0:	89 c2                	mov    %eax,%edx
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	8b 40 04             	mov    0x4(%eax),%eax
 7fe:	c1 e0 03             	shl    $0x3,%eax
 801:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	8b 55 ec             	mov    -0x14(%ebp),%edx
 80a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 80d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 810:	a3 fc 0a 00 00       	mov    %eax,0xafc
      return (void*)(p + 1);
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	83 c0 08             	add    $0x8,%eax
 81b:	eb 3b                	jmp    858 <malloc+0xe1>
    }
    if(p == freep)
 81d:	a1 fc 0a 00 00       	mov    0xafc,%eax
 822:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 825:	75 1e                	jne    845 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 827:	83 ec 0c             	sub    $0xc,%esp
 82a:	ff 75 ec             	pushl  -0x14(%ebp)
 82d:	e8 e5 fe ff ff       	call   717 <morecore>
 832:	83 c4 10             	add    $0x10,%esp
 835:	89 45 f4             	mov    %eax,-0xc(%ebp)
 838:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83c:	75 07                	jne    845 <malloc+0xce>
        return 0;
 83e:	b8 00 00 00 00       	mov    $0x0,%eax
 843:	eb 13                	jmp    858 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 845:	8b 45 f4             	mov    -0xc(%ebp),%eax
 848:	89 45 f0             	mov    %eax,-0x10(%ebp)
 84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84e:	8b 00                	mov    (%eax),%eax
 850:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 853:	e9 6d ff ff ff       	jmp    7c5 <malloc+0x4e>
}
 858:	c9                   	leave  
 859:	c3                   	ret    
