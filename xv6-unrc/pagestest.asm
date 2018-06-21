
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
  71:	68 72 08 00 00       	push   $0x872
  76:	6a 01                	push   $0x1
  78:	e8 3f 04 00 00       	call   4bc <printf>
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

000003e5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e5:	55                   	push   %ebp
 3e6:	89 e5                	mov    %esp,%ebp
 3e8:	83 ec 18             	sub    $0x18,%esp
 3eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ee:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3f1:	83 ec 04             	sub    $0x4,%esp
 3f4:	6a 01                	push   $0x1
 3f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3f9:	50                   	push   %eax
 3fa:	ff 75 08             	pushl  0x8(%ebp)
 3fd:	e8 2b ff ff ff       	call   32d <write>
 402:	83 c4 10             	add    $0x10,%esp
}
 405:	90                   	nop
 406:	c9                   	leave  
 407:	c3                   	ret    

00000408 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
 40b:	53                   	push   %ebx
 40c:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 40f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 416:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 41a:	74 17                	je     433 <printint+0x2b>
 41c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 420:	79 11                	jns    433 <printint+0x2b>
    neg = 1;
 422:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 429:	8b 45 0c             	mov    0xc(%ebp),%eax
 42c:	f7 d8                	neg    %eax
 42e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 431:	eb 06                	jmp    439 <printint+0x31>
  } else {
    x = xx;
 433:	8b 45 0c             	mov    0xc(%ebp),%eax
 436:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 439:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 440:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 443:	8d 41 01             	lea    0x1(%ecx),%eax
 446:	89 45 f4             	mov    %eax,-0xc(%ebp)
 449:	8b 5d 10             	mov    0x10(%ebp),%ebx
 44c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 44f:	ba 00 00 00 00       	mov    $0x0,%edx
 454:	f7 f3                	div    %ebx
 456:	89 d0                	mov    %edx,%eax
 458:	0f b6 80 f8 0a 00 00 	movzbl 0xaf8(%eax),%eax
 45f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 463:	8b 5d 10             	mov    0x10(%ebp),%ebx
 466:	8b 45 ec             	mov    -0x14(%ebp),%eax
 469:	ba 00 00 00 00       	mov    $0x0,%edx
 46e:	f7 f3                	div    %ebx
 470:	89 45 ec             	mov    %eax,-0x14(%ebp)
 473:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 477:	75 c7                	jne    440 <printint+0x38>
  if(neg)
 479:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47d:	74 2d                	je     4ac <printint+0xa4>
    buf[i++] = '-';
 47f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 482:	8d 50 01             	lea    0x1(%eax),%edx
 485:	89 55 f4             	mov    %edx,-0xc(%ebp)
 488:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 48d:	eb 1d                	jmp    4ac <printint+0xa4>
    putc(fd, buf[i]);
 48f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 492:	8b 45 f4             	mov    -0xc(%ebp),%eax
 495:	01 d0                	add    %edx,%eax
 497:	0f b6 00             	movzbl (%eax),%eax
 49a:	0f be c0             	movsbl %al,%eax
 49d:	83 ec 08             	sub    $0x8,%esp
 4a0:	50                   	push   %eax
 4a1:	ff 75 08             	pushl  0x8(%ebp)
 4a4:	e8 3c ff ff ff       	call   3e5 <putc>
 4a9:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4ac:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4b4:	79 d9                	jns    48f <printint+0x87>
    putc(fd, buf[i]);
}
 4b6:	90                   	nop
 4b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4ba:	c9                   	leave  
 4bb:	c3                   	ret    

000004bc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4bc:	55                   	push   %ebp
 4bd:	89 e5                	mov    %esp,%ebp
 4bf:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4c9:	8d 45 0c             	lea    0xc(%ebp),%eax
 4cc:	83 c0 04             	add    $0x4,%eax
 4cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4d9:	e9 59 01 00 00       	jmp    637 <printf+0x17b>
    c = fmt[i] & 0xff;
 4de:	8b 55 0c             	mov    0xc(%ebp),%edx
 4e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4e4:	01 d0                	add    %edx,%eax
 4e6:	0f b6 00             	movzbl (%eax),%eax
 4e9:	0f be c0             	movsbl %al,%eax
 4ec:	25 ff 00 00 00       	and    $0xff,%eax
 4f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f8:	75 2c                	jne    526 <printf+0x6a>
      if(c == '%'){
 4fa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4fe:	75 0c                	jne    50c <printf+0x50>
        state = '%';
 500:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 507:	e9 27 01 00 00       	jmp    633 <printf+0x177>
      } else {
        putc(fd, c);
 50c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 50f:	0f be c0             	movsbl %al,%eax
 512:	83 ec 08             	sub    $0x8,%esp
 515:	50                   	push   %eax
 516:	ff 75 08             	pushl  0x8(%ebp)
 519:	e8 c7 fe ff ff       	call   3e5 <putc>
 51e:	83 c4 10             	add    $0x10,%esp
 521:	e9 0d 01 00 00       	jmp    633 <printf+0x177>
      }
    } else if(state == '%'){
 526:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 52a:	0f 85 03 01 00 00    	jne    633 <printf+0x177>
      if(c == 'd'){
 530:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 534:	75 1e                	jne    554 <printf+0x98>
        printint(fd, *ap, 10, 1);
 536:	8b 45 e8             	mov    -0x18(%ebp),%eax
 539:	8b 00                	mov    (%eax),%eax
 53b:	6a 01                	push   $0x1
 53d:	6a 0a                	push   $0xa
 53f:	50                   	push   %eax
 540:	ff 75 08             	pushl  0x8(%ebp)
 543:	e8 c0 fe ff ff       	call   408 <printint>
 548:	83 c4 10             	add    $0x10,%esp
        ap++;
 54b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54f:	e9 d8 00 00 00       	jmp    62c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 554:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 558:	74 06                	je     560 <printf+0xa4>
 55a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 55e:	75 1e                	jne    57e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 560:	8b 45 e8             	mov    -0x18(%ebp),%eax
 563:	8b 00                	mov    (%eax),%eax
 565:	6a 00                	push   $0x0
 567:	6a 10                	push   $0x10
 569:	50                   	push   %eax
 56a:	ff 75 08             	pushl  0x8(%ebp)
 56d:	e8 96 fe ff ff       	call   408 <printint>
 572:	83 c4 10             	add    $0x10,%esp
        ap++;
 575:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 579:	e9 ae 00 00 00       	jmp    62c <printf+0x170>
      } else if(c == 's'){
 57e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 582:	75 43                	jne    5c7 <printf+0x10b>
        s = (char*)*ap;
 584:	8b 45 e8             	mov    -0x18(%ebp),%eax
 587:	8b 00                	mov    (%eax),%eax
 589:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 58c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 590:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 594:	75 25                	jne    5bb <printf+0xff>
          s = "(null)";
 596:	c7 45 f4 84 08 00 00 	movl   $0x884,-0xc(%ebp)
        while(*s != 0){
 59d:	eb 1c                	jmp    5bb <printf+0xff>
          putc(fd, *s);
 59f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a2:	0f b6 00             	movzbl (%eax),%eax
 5a5:	0f be c0             	movsbl %al,%eax
 5a8:	83 ec 08             	sub    $0x8,%esp
 5ab:	50                   	push   %eax
 5ac:	ff 75 08             	pushl  0x8(%ebp)
 5af:	e8 31 fe ff ff       	call   3e5 <putc>
 5b4:	83 c4 10             	add    $0x10,%esp
          s++;
 5b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	84 c0                	test   %al,%al
 5c3:	75 da                	jne    59f <printf+0xe3>
 5c5:	eb 65                	jmp    62c <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5cb:	75 1d                	jne    5ea <printf+0x12e>
        putc(fd, *ap);
 5cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d0:	8b 00                	mov    (%eax),%eax
 5d2:	0f be c0             	movsbl %al,%eax
 5d5:	83 ec 08             	sub    $0x8,%esp
 5d8:	50                   	push   %eax
 5d9:	ff 75 08             	pushl  0x8(%ebp)
 5dc:	e8 04 fe ff ff       	call   3e5 <putc>
 5e1:	83 c4 10             	add    $0x10,%esp
        ap++;
 5e4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e8:	eb 42                	jmp    62c <printf+0x170>
      } else if(c == '%'){
 5ea:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ee:	75 17                	jne    607 <printf+0x14b>
        putc(fd, c);
 5f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f3:	0f be c0             	movsbl %al,%eax
 5f6:	83 ec 08             	sub    $0x8,%esp
 5f9:	50                   	push   %eax
 5fa:	ff 75 08             	pushl  0x8(%ebp)
 5fd:	e8 e3 fd ff ff       	call   3e5 <putc>
 602:	83 c4 10             	add    $0x10,%esp
 605:	eb 25                	jmp    62c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 607:	83 ec 08             	sub    $0x8,%esp
 60a:	6a 25                	push   $0x25
 60c:	ff 75 08             	pushl  0x8(%ebp)
 60f:	e8 d1 fd ff ff       	call   3e5 <putc>
 614:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61a:	0f be c0             	movsbl %al,%eax
 61d:	83 ec 08             	sub    $0x8,%esp
 620:	50                   	push   %eax
 621:	ff 75 08             	pushl  0x8(%ebp)
 624:	e8 bc fd ff ff       	call   3e5 <putc>
 629:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 62c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 633:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 637:	8b 55 0c             	mov    0xc(%ebp),%edx
 63a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 63d:	01 d0                	add    %edx,%eax
 63f:	0f b6 00             	movzbl (%eax),%eax
 642:	84 c0                	test   %al,%al
 644:	0f 85 94 fe ff ff    	jne    4de <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 64a:	90                   	nop
 64b:	c9                   	leave  
 64c:	c3                   	ret    

0000064d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 64d:	55                   	push   %ebp
 64e:	89 e5                	mov    %esp,%ebp
 650:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 653:	8b 45 08             	mov    0x8(%ebp),%eax
 656:	83 e8 08             	sub    $0x8,%eax
 659:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65c:	a1 14 0b 00 00       	mov    0xb14,%eax
 661:	89 45 fc             	mov    %eax,-0x4(%ebp)
 664:	eb 24                	jmp    68a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 666:	8b 45 fc             	mov    -0x4(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66e:	77 12                	ja     682 <free+0x35>
 670:	8b 45 f8             	mov    -0x8(%ebp),%eax
 673:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 676:	77 24                	ja     69c <free+0x4f>
 678:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67b:	8b 00                	mov    (%eax),%eax
 67d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 680:	77 1a                	ja     69c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 682:	8b 45 fc             	mov    -0x4(%ebp),%eax
 685:	8b 00                	mov    (%eax),%eax
 687:	89 45 fc             	mov    %eax,-0x4(%ebp)
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 690:	76 d4                	jbe    666 <free+0x19>
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 69a:	76 ca                	jbe    666 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	8b 40 04             	mov    0x4(%eax),%eax
 6a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ac:	01 c2                	add    %eax,%edx
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	8b 00                	mov    (%eax),%eax
 6b3:	39 c2                	cmp    %eax,%edx
 6b5:	75 24                	jne    6db <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	8b 50 04             	mov    0x4(%eax),%edx
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	8b 40 04             	mov    0x4(%eax),%eax
 6c5:	01 c2                	add    %eax,%edx
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	8b 10                	mov    (%eax),%edx
 6d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d7:	89 10                	mov    %edx,(%eax)
 6d9:	eb 0a                	jmp    6e5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6de:	8b 10                	mov    (%eax),%edx
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 40 04             	mov    0x4(%eax),%eax
 6eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	01 d0                	add    %edx,%eax
 6f7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6fa:	75 20                	jne    71c <free+0xcf>
    p->s.size += bp->s.size;
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 50 04             	mov    0x4(%eax),%edx
 702:	8b 45 f8             	mov    -0x8(%ebp),%eax
 705:	8b 40 04             	mov    0x4(%eax),%eax
 708:	01 c2                	add    %eax,%edx
 70a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	8b 10                	mov    (%eax),%edx
 715:	8b 45 fc             	mov    -0x4(%ebp),%eax
 718:	89 10                	mov    %edx,(%eax)
 71a:	eb 08                	jmp    724 <free+0xd7>
  } else
    p->s.ptr = bp;
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 722:	89 10                	mov    %edx,(%eax)
  freep = p;
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	a3 14 0b 00 00       	mov    %eax,0xb14
}
 72c:	90                   	nop
 72d:	c9                   	leave  
 72e:	c3                   	ret    

0000072f <morecore>:

static Header*
morecore(uint nu)
{
 72f:	55                   	push   %ebp
 730:	89 e5                	mov    %esp,%ebp
 732:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 735:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 73c:	77 07                	ja     745 <morecore+0x16>
    nu = 4096;
 73e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	c1 e0 03             	shl    $0x3,%eax
 74b:	83 ec 0c             	sub    $0xc,%esp
 74e:	50                   	push   %eax
 74f:	e8 41 fc ff ff       	call   395 <sbrk>
 754:	83 c4 10             	add    $0x10,%esp
 757:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 75a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 75e:	75 07                	jne    767 <morecore+0x38>
    return 0;
 760:	b8 00 00 00 00       	mov    $0x0,%eax
 765:	eb 26                	jmp    78d <morecore+0x5e>
  hp = (Header*)p;
 767:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 76d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 770:	8b 55 08             	mov    0x8(%ebp),%edx
 773:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	83 c0 08             	add    $0x8,%eax
 77c:	83 ec 0c             	sub    $0xc,%esp
 77f:	50                   	push   %eax
 780:	e8 c8 fe ff ff       	call   64d <free>
 785:	83 c4 10             	add    $0x10,%esp
  return freep;
 788:	a1 14 0b 00 00       	mov    0xb14,%eax
}
 78d:	c9                   	leave  
 78e:	c3                   	ret    

0000078f <malloc>:

void*
malloc(uint nbytes)
{
 78f:	55                   	push   %ebp
 790:	89 e5                	mov    %esp,%ebp
 792:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 795:	8b 45 08             	mov    0x8(%ebp),%eax
 798:	83 c0 07             	add    $0x7,%eax
 79b:	c1 e8 03             	shr    $0x3,%eax
 79e:	83 c0 01             	add    $0x1,%eax
 7a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7a4:	a1 14 0b 00 00       	mov    0xb14,%eax
 7a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b0:	75 23                	jne    7d5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7b2:	c7 45 f0 0c 0b 00 00 	movl   $0xb0c,-0x10(%ebp)
 7b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bc:	a3 14 0b 00 00       	mov    %eax,0xb14
 7c1:	a1 14 0b 00 00       	mov    0xb14,%eax
 7c6:	a3 0c 0b 00 00       	mov    %eax,0xb0c
    base.s.size = 0;
 7cb:	c7 05 10 0b 00 00 00 	movl   $0x0,0xb10
 7d2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	8b 40 04             	mov    0x4(%eax),%eax
 7e3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e6:	72 4d                	jb     835 <malloc+0xa6>
      if(p->s.size == nunits)
 7e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7eb:	8b 40 04             	mov    0x4(%eax),%eax
 7ee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7f1:	75 0c                	jne    7ff <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f6:	8b 10                	mov    (%eax),%edx
 7f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fb:	89 10                	mov    %edx,(%eax)
 7fd:	eb 26                	jmp    825 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	8b 40 04             	mov    0x4(%eax),%eax
 805:	2b 45 ec             	sub    -0x14(%ebp),%eax
 808:	89 c2                	mov    %eax,%edx
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 810:	8b 45 f4             	mov    -0xc(%ebp),%eax
 813:	8b 40 04             	mov    0x4(%eax),%eax
 816:	c1 e0 03             	shl    $0x3,%eax
 819:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 81c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 822:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	a3 14 0b 00 00       	mov    %eax,0xb14
      return (void*)(p + 1);
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	83 c0 08             	add    $0x8,%eax
 833:	eb 3b                	jmp    870 <malloc+0xe1>
    }
    if(p == freep)
 835:	a1 14 0b 00 00       	mov    0xb14,%eax
 83a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 83d:	75 1e                	jne    85d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 83f:	83 ec 0c             	sub    $0xc,%esp
 842:	ff 75 ec             	pushl  -0x14(%ebp)
 845:	e8 e5 fe ff ff       	call   72f <morecore>
 84a:	83 c4 10             	add    $0x10,%esp
 84d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 850:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 854:	75 07                	jne    85d <malloc+0xce>
        return 0;
 856:	b8 00 00 00 00       	mov    $0x0,%eax
 85b:	eb 13                	jmp    870 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	89 45 f0             	mov    %eax,-0x10(%ebp)
 863:	8b 45 f4             	mov    -0xc(%ebp),%eax
 866:	8b 00                	mov    (%eax),%eax
 868:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 86b:	e9 6d ff ff ff       	jmp    7dd <malloc+0x4e>
}
 870:	c9                   	leave  
 871:	c3                   	ret    
