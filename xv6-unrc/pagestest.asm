
_pagestest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <pagestest>:



void
pagestest(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
   7:	89 e0                	mov    %esp,%eax
   9:	89 c3                	mov    %eax,%ebx
  int i;
  int array[n];
   b:	8b 45 08             	mov    0x8(%ebp),%eax
   e:	8d 50 ff             	lea    -0x1(%eax),%edx
  11:	89 55 f0             	mov    %edx,-0x10(%ebp)
  14:	c1 e0 02             	shl    $0x2,%eax
  17:	8d 50 03             	lea    0x3(%eax),%edx
  1a:	b8 10 00 00 00       	mov    $0x10,%eax
  1f:	83 e8 01             	sub    $0x1,%eax
  22:	01 d0                	add    %edx,%eax
  24:	b9 10 00 00 00       	mov    $0x10,%ecx
  29:	ba 00 00 00 00       	mov    $0x0,%edx
  2e:	f7 f1                	div    %ecx
  30:	6b c0 10             	imul   $0x10,%eax,%eax
  33:	29 c4                	sub    %eax,%esp
  35:	89 e0                	mov    %esp,%eax
  37:	83 c0 03             	add    $0x3,%eax
  3a:	c1 e8 02             	shr    $0x2,%eax
  3d:	c1 e0 02             	shl    $0x2,%eax
  40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(i=0;i<n;i++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 10                	jmp    5c <pagestest+0x5c>
    array[i]=i;
  4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  52:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  55:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
void
pagestest(int n)
{
  int i;
  int array[n];
  for(i=0;i<n;i++){
  58:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5f:	3b 45 08             	cmp    0x8(%ebp),%eax
  62:	7c e8                	jl     4c <pagestest+0x4c>
    array[i]=i;
  }
  //pagestest(n-1);
  printf(1, "pages test OK %i\n",array[n]);
  64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  67:	8b 55 08             	mov    0x8(%ebp),%edx
  6a:	8b 04 90             	mov    (%eax,%edx,4),%eax
  6d:	83 ec 04             	sub    $0x4,%esp
  70:	50                   	push   %eax
  71:	68 7a 08 00 00       	push   $0x87a
  76:	6a 01                	push   $0x1
  78:	e8 47 04 00 00       	call   4c4 <printf>
  7d:	83 c4 10             	add    $0x10,%esp
  80:	89 dc                	mov    %ebx,%esp
}
  82:	90                   	nop
  83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  86:	c9                   	leave  
  87:	c3                   	ret    

00000088 <main>:

int
main(void)
{
  88:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  8c:	83 e4 f0             	and    $0xfffffff0,%esp
  8f:	ff 71 fc             	pushl  -0x4(%ecx)
  92:	55                   	push   %ebp
  93:	89 e5                	mov    %esp,%ebp
  95:	51                   	push   %ecx
  96:	83 ec 04             	sub    $0x4,%esp
  pagestest(N);
  99:	83 ec 0c             	sub    $0xc,%esp
  9c:	68 00 04 00 00       	push   $0x400
  a1:	e8 5a ff ff ff       	call   0 <pagestest>
  a6:	83 c4 10             	add    $0x10,%esp
  exit();
  a9:	e8 57 02 00 00       	call   305 <exit>

000000ae <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  ae:	55                   	push   %ebp
  af:	89 e5                	mov    %esp,%ebp
  b1:	57                   	push   %edi
  b2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b6:	8b 55 10             	mov    0x10(%ebp),%edx
  b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  bc:	89 cb                	mov    %ecx,%ebx
  be:	89 df                	mov    %ebx,%edi
  c0:	89 d1                	mov    %edx,%ecx
  c2:	fc                   	cld    
  c3:	f3 aa                	rep stos %al,%es:(%edi)
  c5:	89 ca                	mov    %ecx,%edx
  c7:	89 fb                	mov    %edi,%ebx
  c9:	89 5d 08             	mov    %ebx,0x8(%ebp)
  cc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  cf:	90                   	nop
  d0:	5b                   	pop    %ebx
  d1:	5f                   	pop    %edi
  d2:	5d                   	pop    %ebp
  d3:	c3                   	ret    

000000d4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  d4:	55                   	push   %ebp
  d5:	89 e5                	mov    %esp,%ebp
  d7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  e0:	90                   	nop
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	8d 50 01             	lea    0x1(%eax),%edx
  e7:	89 55 08             	mov    %edx,0x8(%ebp)
  ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  f0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  f3:	0f b6 12             	movzbl (%edx),%edx
  f6:	88 10                	mov    %dl,(%eax)
  f8:	0f b6 00             	movzbl (%eax),%eax
  fb:	84 c0                	test   %al,%al
  fd:	75 e2                	jne    e1 <strcpy+0xd>
    ;
  return os;
  ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 107:	eb 08                	jmp    111 <strcmp+0xd>
    p++, q++;
 109:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 10d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	84 c0                	test   %al,%al
 119:	74 10                	je     12b <strcmp+0x27>
 11b:	8b 45 08             	mov    0x8(%ebp),%eax
 11e:	0f b6 10             	movzbl (%eax),%edx
 121:	8b 45 0c             	mov    0xc(%ebp),%eax
 124:	0f b6 00             	movzbl (%eax),%eax
 127:	38 c2                	cmp    %al,%dl
 129:	74 de                	je     109 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 12b:	8b 45 08             	mov    0x8(%ebp),%eax
 12e:	0f b6 00             	movzbl (%eax),%eax
 131:	0f b6 d0             	movzbl %al,%edx
 134:	8b 45 0c             	mov    0xc(%ebp),%eax
 137:	0f b6 00             	movzbl (%eax),%eax
 13a:	0f b6 c0             	movzbl %al,%eax
 13d:	29 c2                	sub    %eax,%edx
 13f:	89 d0                	mov    %edx,%eax
}
 141:	5d                   	pop    %ebp
 142:	c3                   	ret    

00000143 <strlen>:

uint
strlen(char *s)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 149:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 150:	eb 04                	jmp    156 <strlen+0x13>
 152:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 156:	8b 55 fc             	mov    -0x4(%ebp),%edx
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	01 d0                	add    %edx,%eax
 15e:	0f b6 00             	movzbl (%eax),%eax
 161:	84 c0                	test   %al,%al
 163:	75 ed                	jne    152 <strlen+0xf>
    ;
  return n;
 165:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 168:	c9                   	leave  
 169:	c3                   	ret    

0000016a <memset>:

void*
memset(void *dst, int c, uint n)
{
 16a:	55                   	push   %ebp
 16b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 16d:	8b 45 10             	mov    0x10(%ebp),%eax
 170:	50                   	push   %eax
 171:	ff 75 0c             	pushl  0xc(%ebp)
 174:	ff 75 08             	pushl  0x8(%ebp)
 177:	e8 32 ff ff ff       	call   ae <stosb>
 17c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 182:	c9                   	leave  
 183:	c3                   	ret    

00000184 <strchr>:

char*
strchr(const char *s, char c)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 04             	sub    $0x4,%esp
 18a:	8b 45 0c             	mov    0xc(%ebp),%eax
 18d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 190:	eb 14                	jmp    1a6 <strchr+0x22>
    if(*s == c)
 192:	8b 45 08             	mov    0x8(%ebp),%eax
 195:	0f b6 00             	movzbl (%eax),%eax
 198:	3a 45 fc             	cmp    -0x4(%ebp),%al
 19b:	75 05                	jne    1a2 <strchr+0x1e>
      return (char*)s;
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	eb 13                	jmp    1b5 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1a2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a6:	8b 45 08             	mov    0x8(%ebp),%eax
 1a9:	0f b6 00             	movzbl (%eax),%eax
 1ac:	84 c0                	test   %al,%al
 1ae:	75 e2                	jne    192 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1b5:	c9                   	leave  
 1b6:	c3                   	ret    

000001b7 <gets>:

char*
gets(char *buf, int max)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1c4:	eb 42                	jmp    208 <gets+0x51>
    cc = read(0, &c, 1);
 1c6:	83 ec 04             	sub    $0x4,%esp
 1c9:	6a 01                	push   $0x1
 1cb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ce:	50                   	push   %eax
 1cf:	6a 00                	push   $0x0
 1d1:	e8 47 01 00 00       	call   31d <read>
 1d6:	83 c4 10             	add    $0x10,%esp
 1d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1e0:	7e 33                	jle    215 <gets+0x5e>
      break;
    buf[i++] = c;
 1e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e5:	8d 50 01             	lea    0x1(%eax),%edx
 1e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1eb:	89 c2                	mov    %eax,%edx
 1ed:	8b 45 08             	mov    0x8(%ebp),%eax
 1f0:	01 c2                	add    %eax,%edx
 1f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1f8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1fc:	3c 0a                	cmp    $0xa,%al
 1fe:	74 16                	je     216 <gets+0x5f>
 200:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 204:	3c 0d                	cmp    $0xd,%al
 206:	74 0e                	je     216 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20b:	83 c0 01             	add    $0x1,%eax
 20e:	3b 45 0c             	cmp    0xc(%ebp),%eax
 211:	7c b3                	jl     1c6 <gets+0xf>
 213:	eb 01                	jmp    216 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 215:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 216:	8b 55 f4             	mov    -0xc(%ebp),%edx
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	01 d0                	add    %edx,%eax
 21e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 221:	8b 45 08             	mov    0x8(%ebp),%eax
}
 224:	c9                   	leave  
 225:	c3                   	ret    

00000226 <stat>:

int
stat(char *n, struct stat *st)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22c:	83 ec 08             	sub    $0x8,%esp
 22f:	6a 00                	push   $0x0
 231:	ff 75 08             	pushl  0x8(%ebp)
 234:	e8 14 01 00 00       	call   34d <open>
 239:	83 c4 10             	add    $0x10,%esp
 23c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 23f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 243:	79 07                	jns    24c <stat+0x26>
    return -1;
 245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 24a:	eb 25                	jmp    271 <stat+0x4b>
  r = fstat(fd, st);
 24c:	83 ec 08             	sub    $0x8,%esp
 24f:	ff 75 0c             	pushl  0xc(%ebp)
 252:	ff 75 f4             	pushl  -0xc(%ebp)
 255:	e8 0b 01 00 00       	call   365 <fstat>
 25a:	83 c4 10             	add    $0x10,%esp
 25d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 260:	83 ec 0c             	sub    $0xc,%esp
 263:	ff 75 f4             	pushl  -0xc(%ebp)
 266:	e8 ca 00 00 00       	call   335 <close>
 26b:	83 c4 10             	add    $0x10,%esp
  return r;
 26e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 271:	c9                   	leave  
 272:	c3                   	ret    

00000273 <atoi>:

int
atoi(const char *s)
{
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 279:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 280:	eb 25                	jmp    2a7 <atoi+0x34>
    n = n*10 + *s++ - '0';
 282:	8b 55 fc             	mov    -0x4(%ebp),%edx
 285:	89 d0                	mov    %edx,%eax
 287:	c1 e0 02             	shl    $0x2,%eax
 28a:	01 d0                	add    %edx,%eax
 28c:	01 c0                	add    %eax,%eax
 28e:	89 c1                	mov    %eax,%ecx
 290:	8b 45 08             	mov    0x8(%ebp),%eax
 293:	8d 50 01             	lea    0x1(%eax),%edx
 296:	89 55 08             	mov    %edx,0x8(%ebp)
 299:	0f b6 00             	movzbl (%eax),%eax
 29c:	0f be c0             	movsbl %al,%eax
 29f:	01 c8                	add    %ecx,%eax
 2a1:	83 e8 30             	sub    $0x30,%eax
 2a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	0f b6 00             	movzbl (%eax),%eax
 2ad:	3c 2f                	cmp    $0x2f,%al
 2af:	7e 0a                	jle    2bb <atoi+0x48>
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	3c 39                	cmp    $0x39,%al
 2b9:	7e c7                	jle    282 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2be:	c9                   	leave  
 2bf:	c3                   	ret    

000002c0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2d2:	eb 17                	jmp    2eb <memmove+0x2b>
    *dst++ = *src++;
 2d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2d7:	8d 50 01             	lea    0x1(%eax),%edx
 2da:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2e0:	8d 4a 01             	lea    0x1(%edx),%ecx
 2e3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2e6:	0f b6 12             	movzbl (%edx),%edx
 2e9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2eb:	8b 45 10             	mov    0x10(%ebp),%eax
 2ee:	8d 50 ff             	lea    -0x1(%eax),%edx
 2f1:	89 55 10             	mov    %edx,0x10(%ebp)
 2f4:	85 c0                	test   %eax,%eax
 2f6:	7f dc                	jg     2d4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2fd:	b8 01 00 00 00       	mov    $0x1,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <exit>:
SYSCALL(exit)
 305:	b8 02 00 00 00       	mov    $0x2,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <wait>:
SYSCALL(wait)
 30d:	b8 03 00 00 00       	mov    $0x3,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <pipe>:
SYSCALL(pipe)
 315:	b8 04 00 00 00       	mov    $0x4,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <read>:
SYSCALL(read)
 31d:	b8 05 00 00 00       	mov    $0x5,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <seek>:
SYSCALL(seek)
 325:	b8 1c 00 00 00       	mov    $0x1c,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <write>:
SYSCALL(write)
 32d:	b8 10 00 00 00       	mov    $0x10,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <close>:
SYSCALL(close)
 335:	b8 15 00 00 00       	mov    $0x15,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <kill>:
SYSCALL(kill)
 33d:	b8 06 00 00 00       	mov    $0x6,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <exec>:
SYSCALL(exec)
 345:	b8 07 00 00 00       	mov    $0x7,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <open>:
SYSCALL(open)
 34d:	b8 0f 00 00 00       	mov    $0xf,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <mknod>:
SYSCALL(mknod)
 355:	b8 11 00 00 00       	mov    $0x11,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <unlink>:
SYSCALL(unlink)
 35d:	b8 12 00 00 00       	mov    $0x12,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <fstat>:
SYSCALL(fstat)
 365:	b8 08 00 00 00       	mov    $0x8,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <link>:
SYSCALL(link)
 36d:	b8 13 00 00 00       	mov    $0x13,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <mkdir>:
SYSCALL(mkdir)
 375:	b8 14 00 00 00       	mov    $0x14,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <chdir>:
SYSCALL(chdir)
 37d:	b8 09 00 00 00       	mov    $0x9,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <dup>:
SYSCALL(dup)
 385:	b8 0a 00 00 00       	mov    $0xa,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <getpid>:
SYSCALL(getpid)
 38d:	b8 0b 00 00 00       	mov    $0xb,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <sbrk>:
SYSCALL(sbrk)
 395:	b8 0c 00 00 00       	mov    $0xc,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <sleep>:
SYSCALL(sleep)
 39d:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <uptime>:
SYSCALL(uptime)
 3a5:	b8 0e 00 00 00       	mov    $0xe,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <procstat>:
SYSCALL(procstat)
 3ad:	b8 16 00 00 00       	mov    $0x16,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <setpriority>:
SYSCALL(setpriority)
 3b5:	b8 17 00 00 00       	mov    $0x17,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <semget>:
SYSCALL(semget)
 3bd:	b8 18 00 00 00       	mov    $0x18,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <semfree>:
SYSCALL(semfree)
 3c5:	b8 19 00 00 00       	mov    $0x19,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <semdown>:
SYSCALL(semdown)
 3cd:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <semup>:
SYSCALL(semup)
 3d5:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <mmap>:
SYSCALL(mmap)
 3dd:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <munmap>:
SYSCALL(munmap)
 3e5:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3ed:	55                   	push   %ebp
 3ee:	89 e5                	mov    %esp,%ebp
 3f0:	83 ec 18             	sub    $0x18,%esp
 3f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3f9:	83 ec 04             	sub    $0x4,%esp
 3fc:	6a 01                	push   $0x1
 3fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
 401:	50                   	push   %eax
 402:	ff 75 08             	pushl  0x8(%ebp)
 405:	e8 23 ff ff ff       	call   32d <write>
 40a:	83 c4 10             	add    $0x10,%esp
}
 40d:	90                   	nop
 40e:	c9                   	leave  
 40f:	c3                   	ret    

00000410 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	53                   	push   %ebx
 414:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 417:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 41e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 422:	74 17                	je     43b <printint+0x2b>
 424:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 428:	79 11                	jns    43b <printint+0x2b>
    neg = 1;
 42a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 431:	8b 45 0c             	mov    0xc(%ebp),%eax
 434:	f7 d8                	neg    %eax
 436:	89 45 ec             	mov    %eax,-0x14(%ebp)
 439:	eb 06                	jmp    441 <printint+0x31>
  } else {
    x = xx;
 43b:	8b 45 0c             	mov    0xc(%ebp),%eax
 43e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 441:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 448:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 44b:	8d 41 01             	lea    0x1(%ecx),%eax
 44e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 451:	8b 5d 10             	mov    0x10(%ebp),%ebx
 454:	8b 45 ec             	mov    -0x14(%ebp),%eax
 457:	ba 00 00 00 00       	mov    $0x0,%edx
 45c:	f7 f3                	div    %ebx
 45e:	89 d0                	mov    %edx,%eax
 460:	0f b6 80 00 0b 00 00 	movzbl 0xb00(%eax),%eax
 467:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 46b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 46e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 471:	ba 00 00 00 00       	mov    $0x0,%edx
 476:	f7 f3                	div    %ebx
 478:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47f:	75 c7                	jne    448 <printint+0x38>
  if(neg)
 481:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 485:	74 2d                	je     4b4 <printint+0xa4>
    buf[i++] = '-';
 487:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48a:	8d 50 01             	lea    0x1(%eax),%edx
 48d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 490:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 495:	eb 1d                	jmp    4b4 <printint+0xa4>
    putc(fd, buf[i]);
 497:	8d 55 dc             	lea    -0x24(%ebp),%edx
 49a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49d:	01 d0                	add    %edx,%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	0f be c0             	movsbl %al,%eax
 4a5:	83 ec 08             	sub    $0x8,%esp
 4a8:	50                   	push   %eax
 4a9:	ff 75 08             	pushl  0x8(%ebp)
 4ac:	e8 3c ff ff ff       	call   3ed <putc>
 4b1:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4b4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4bc:	79 d9                	jns    497 <printint+0x87>
    putc(fd, buf[i]);
}
 4be:	90                   	nop
 4bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4c2:	c9                   	leave  
 4c3:	c3                   	ret    

000004c4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4c4:	55                   	push   %ebp
 4c5:	89 e5                	mov    %esp,%ebp
 4c7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d1:	8d 45 0c             	lea    0xc(%ebp),%eax
 4d4:	83 c0 04             	add    $0x4,%eax
 4d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e1:	e9 59 01 00 00       	jmp    63f <printf+0x17b>
    c = fmt[i] & 0xff;
 4e6:	8b 55 0c             	mov    0xc(%ebp),%edx
 4e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ec:	01 d0                	add    %edx,%eax
 4ee:	0f b6 00             	movzbl (%eax),%eax
 4f1:	0f be c0             	movsbl %al,%eax
 4f4:	25 ff 00 00 00       	and    $0xff,%eax
 4f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 500:	75 2c                	jne    52e <printf+0x6a>
      if(c == '%'){
 502:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 506:	75 0c                	jne    514 <printf+0x50>
        state = '%';
 508:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 50f:	e9 27 01 00 00       	jmp    63b <printf+0x177>
      } else {
        putc(fd, c);
 514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 517:	0f be c0             	movsbl %al,%eax
 51a:	83 ec 08             	sub    $0x8,%esp
 51d:	50                   	push   %eax
 51e:	ff 75 08             	pushl  0x8(%ebp)
 521:	e8 c7 fe ff ff       	call   3ed <putc>
 526:	83 c4 10             	add    $0x10,%esp
 529:	e9 0d 01 00 00       	jmp    63b <printf+0x177>
      }
    } else if(state == '%'){
 52e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 532:	0f 85 03 01 00 00    	jne    63b <printf+0x177>
      if(c == 'd'){
 538:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 53c:	75 1e                	jne    55c <printf+0x98>
        printint(fd, *ap, 10, 1);
 53e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 541:	8b 00                	mov    (%eax),%eax
 543:	6a 01                	push   $0x1
 545:	6a 0a                	push   $0xa
 547:	50                   	push   %eax
 548:	ff 75 08             	pushl  0x8(%ebp)
 54b:	e8 c0 fe ff ff       	call   410 <printint>
 550:	83 c4 10             	add    $0x10,%esp
        ap++;
 553:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 557:	e9 d8 00 00 00       	jmp    634 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 55c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 560:	74 06                	je     568 <printf+0xa4>
 562:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 566:	75 1e                	jne    586 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 568:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56b:	8b 00                	mov    (%eax),%eax
 56d:	6a 00                	push   $0x0
 56f:	6a 10                	push   $0x10
 571:	50                   	push   %eax
 572:	ff 75 08             	pushl  0x8(%ebp)
 575:	e8 96 fe ff ff       	call   410 <printint>
 57a:	83 c4 10             	add    $0x10,%esp
        ap++;
 57d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 581:	e9 ae 00 00 00       	jmp    634 <printf+0x170>
      } else if(c == 's'){
 586:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 58a:	75 43                	jne    5cf <printf+0x10b>
        s = (char*)*ap;
 58c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58f:	8b 00                	mov    (%eax),%eax
 591:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 594:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 598:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59c:	75 25                	jne    5c3 <printf+0xff>
          s = "(null)";
 59e:	c7 45 f4 8c 08 00 00 	movl   $0x88c,-0xc(%ebp)
        while(*s != 0){
 5a5:	eb 1c                	jmp    5c3 <printf+0xff>
          putc(fd, *s);
 5a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	0f be c0             	movsbl %al,%eax
 5b0:	83 ec 08             	sub    $0x8,%esp
 5b3:	50                   	push   %eax
 5b4:	ff 75 08             	pushl  0x8(%ebp)
 5b7:	e8 31 fe ff ff       	call   3ed <putc>
 5bc:	83 c4 10             	add    $0x10,%esp
          s++;
 5bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c6:	0f b6 00             	movzbl (%eax),%eax
 5c9:	84 c0                	test   %al,%al
 5cb:	75 da                	jne    5a7 <printf+0xe3>
 5cd:	eb 65                	jmp    634 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5cf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d3:	75 1d                	jne    5f2 <printf+0x12e>
        putc(fd, *ap);
 5d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	0f be c0             	movsbl %al,%eax
 5dd:	83 ec 08             	sub    $0x8,%esp
 5e0:	50                   	push   %eax
 5e1:	ff 75 08             	pushl  0x8(%ebp)
 5e4:	e8 04 fe ff ff       	call   3ed <putc>
 5e9:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ec:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f0:	eb 42                	jmp    634 <printf+0x170>
      } else if(c == '%'){
 5f2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f6:	75 17                	jne    60f <printf+0x14b>
        putc(fd, c);
 5f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fb:	0f be c0             	movsbl %al,%eax
 5fe:	83 ec 08             	sub    $0x8,%esp
 601:	50                   	push   %eax
 602:	ff 75 08             	pushl  0x8(%ebp)
 605:	e8 e3 fd ff ff       	call   3ed <putc>
 60a:	83 c4 10             	add    $0x10,%esp
 60d:	eb 25                	jmp    634 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 60f:	83 ec 08             	sub    $0x8,%esp
 612:	6a 25                	push   $0x25
 614:	ff 75 08             	pushl  0x8(%ebp)
 617:	e8 d1 fd ff ff       	call   3ed <putc>
 61c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 61f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 622:	0f be c0             	movsbl %al,%eax
 625:	83 ec 08             	sub    $0x8,%esp
 628:	50                   	push   %eax
 629:	ff 75 08             	pushl  0x8(%ebp)
 62c:	e8 bc fd ff ff       	call   3ed <putc>
 631:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 634:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 63b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 63f:	8b 55 0c             	mov    0xc(%ebp),%edx
 642:	8b 45 f0             	mov    -0x10(%ebp),%eax
 645:	01 d0                	add    %edx,%eax
 647:	0f b6 00             	movzbl (%eax),%eax
 64a:	84 c0                	test   %al,%al
 64c:	0f 85 94 fe ff ff    	jne    4e6 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 652:	90                   	nop
 653:	c9                   	leave  
 654:	c3                   	ret    

00000655 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 655:	55                   	push   %ebp
 656:	89 e5                	mov    %esp,%ebp
 658:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65b:	8b 45 08             	mov    0x8(%ebp),%eax
 65e:	83 e8 08             	sub    $0x8,%eax
 661:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 664:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 669:	89 45 fc             	mov    %eax,-0x4(%ebp)
 66c:	eb 24                	jmp    692 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 00                	mov    (%eax),%eax
 673:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 676:	77 12                	ja     68a <free+0x35>
 678:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67e:	77 24                	ja     6a4 <free+0x4f>
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	8b 00                	mov    (%eax),%eax
 685:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 688:	77 1a                	ja     6a4 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 692:	8b 45 f8             	mov    -0x8(%ebp),%eax
 695:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 698:	76 d4                	jbe    66e <free+0x19>
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	8b 00                	mov    (%eax),%eax
 69f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a2:	76 ca                	jbe    66e <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a7:	8b 40 04             	mov    0x4(%eax),%eax
 6aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b4:	01 c2                	add    %eax,%edx
 6b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b9:	8b 00                	mov    (%eax),%eax
 6bb:	39 c2                	cmp    %eax,%edx
 6bd:	75 24                	jne    6e3 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c2:	8b 50 04             	mov    0x4(%eax),%edx
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	8b 40 04             	mov    0x4(%eax),%eax
 6cd:	01 c2                	add    %eax,%edx
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	8b 10                	mov    (%eax),%edx
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	89 10                	mov    %edx,(%eax)
 6e1:	eb 0a                	jmp    6ed <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 10                	mov    (%eax),%edx
 6e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6eb:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 40 04             	mov    0x4(%eax),%eax
 6f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fd:	01 d0                	add    %edx,%eax
 6ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 702:	75 20                	jne    724 <free+0xcf>
    p->s.size += bp->s.size;
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 50 04             	mov    0x4(%eax),%edx
 70a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70d:	8b 40 04             	mov    0x4(%eax),%eax
 710:	01 c2                	add    %eax,%edx
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 718:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71b:	8b 10                	mov    (%eax),%edx
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	89 10                	mov    %edx,(%eax)
 722:	eb 08                	jmp    72c <free+0xd7>
  } else
    p->s.ptr = bp;
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 55 f8             	mov    -0x8(%ebp),%edx
 72a:	89 10                	mov    %edx,(%eax)
  freep = p;
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	a3 1c 0b 00 00       	mov    %eax,0xb1c
}
 734:	90                   	nop
 735:	c9                   	leave  
 736:	c3                   	ret    

00000737 <morecore>:

static Header*
morecore(uint nu)
{
 737:	55                   	push   %ebp
 738:	89 e5                	mov    %esp,%ebp
 73a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 73d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 744:	77 07                	ja     74d <morecore+0x16>
    nu = 4096;
 746:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 74d:	8b 45 08             	mov    0x8(%ebp),%eax
 750:	c1 e0 03             	shl    $0x3,%eax
 753:	83 ec 0c             	sub    $0xc,%esp
 756:	50                   	push   %eax
 757:	e8 39 fc ff ff       	call   395 <sbrk>
 75c:	83 c4 10             	add    $0x10,%esp
 75f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 762:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 766:	75 07                	jne    76f <morecore+0x38>
    return 0;
 768:	b8 00 00 00 00       	mov    $0x0,%eax
 76d:	eb 26                	jmp    795 <morecore+0x5e>
  hp = (Header*)p;
 76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 772:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	8b 55 08             	mov    0x8(%ebp),%edx
 77b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 77e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 781:	83 c0 08             	add    $0x8,%eax
 784:	83 ec 0c             	sub    $0xc,%esp
 787:	50                   	push   %eax
 788:	e8 c8 fe ff ff       	call   655 <free>
 78d:	83 c4 10             	add    $0x10,%esp
  return freep;
 790:	a1 1c 0b 00 00       	mov    0xb1c,%eax
}
 795:	c9                   	leave  
 796:	c3                   	ret    

00000797 <malloc>:

void*
malloc(uint nbytes)
{
 797:	55                   	push   %ebp
 798:	89 e5                	mov    %esp,%ebp
 79a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79d:	8b 45 08             	mov    0x8(%ebp),%eax
 7a0:	83 c0 07             	add    $0x7,%eax
 7a3:	c1 e8 03             	shr    $0x3,%eax
 7a6:	83 c0 01             	add    $0x1,%eax
 7a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ac:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 7b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b8:	75 23                	jne    7dd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7ba:	c7 45 f0 14 0b 00 00 	movl   $0xb14,-0x10(%ebp)
 7c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c4:	a3 1c 0b 00 00       	mov    %eax,0xb1c
 7c9:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 7ce:	a3 14 0b 00 00       	mov    %eax,0xb14
    base.s.size = 0;
 7d3:	c7 05 18 0b 00 00 00 	movl   $0x0,0xb18
 7da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ee:	72 4d                	jb     83d <malloc+0xa6>
      if(p->s.size == nunits)
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7f9:	75 0c                	jne    807 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	8b 10                	mov    (%eax),%edx
 800:	8b 45 f0             	mov    -0x10(%ebp),%eax
 803:	89 10                	mov    %edx,(%eax)
 805:	eb 26                	jmp    82d <malloc+0x96>
      else {
        p->s.size -= nunits;
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 810:	89 c2                	mov    %eax,%edx
 812:	8b 45 f4             	mov    -0xc(%ebp),%eax
 815:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	8b 40 04             	mov    0x4(%eax),%eax
 81e:	c1 e0 03             	shl    $0x3,%eax
 821:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 824:	8b 45 f4             	mov    -0xc(%ebp),%eax
 827:	8b 55 ec             	mov    -0x14(%ebp),%edx
 82a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 82d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 830:	a3 1c 0b 00 00       	mov    %eax,0xb1c
      return (void*)(p + 1);
 835:	8b 45 f4             	mov    -0xc(%ebp),%eax
 838:	83 c0 08             	add    $0x8,%eax
 83b:	eb 3b                	jmp    878 <malloc+0xe1>
    }
    if(p == freep)
 83d:	a1 1c 0b 00 00       	mov    0xb1c,%eax
 842:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 845:	75 1e                	jne    865 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 847:	83 ec 0c             	sub    $0xc,%esp
 84a:	ff 75 ec             	pushl  -0x14(%ebp)
 84d:	e8 e5 fe ff ff       	call   737 <morecore>
 852:	83 c4 10             	add    $0x10,%esp
 855:	89 45 f4             	mov    %eax,-0xc(%ebp)
 858:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 85c:	75 07                	jne    865 <malloc+0xce>
        return 0;
 85e:	b8 00 00 00 00       	mov    $0x0,%eax
 863:	eb 13                	jmp    878 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 873:	e9 6d ff ff ff       	jmp    7e5 <malloc+0x4e>
}
 878:	c9                   	leave  
 879:	c3                   	ret    
