
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
  char* buff;
  fd=open("text.txt",O_RDWR);
   6:	83 ec 08             	sub    $0x8,%esp
   9:	6a 02                	push   $0x2
   b:	68 23 08 00 00       	push   $0x823
  10:	e8 e9 02 00 00       	call   2fe <open>
  15:	83 c4 10             	add    $0x10,%esp
  18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  mmap(fd,O_RDWR,&buff);
  1b:	83 ec 04             	sub    $0x4,%esp
  1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  21:	50                   	push   %eax
  22:	6a 02                	push   $0x2
  24:	ff 75 f4             	pushl  -0xc(%ebp)
  27:	e8 62 03 00 00       	call   38e <mmap>
  2c:	83 c4 10             	add    $0x10,%esp

  printf(1, "mmaptest ok\n");
  2f:	83 ec 08             	sub    $0x8,%esp
  32:	68 2c 08 00 00       	push   $0x82c
  37:	6a 01                	push   $0x1
  39:	e8 2f 04 00 00       	call   46d <printf>
  3e:	83 c4 10             	add    $0x10,%esp
}
  41:	90                   	nop
  42:	c9                   	leave  
  43:	c3                   	ret    

00000044 <main>:

int
main(void)
{
  44:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  48:	83 e4 f0             	and    $0xfffffff0,%esp
  4b:	ff 71 fc             	pushl  -0x4(%ecx)
  4e:	55                   	push   %ebp
  4f:	89 e5                	mov    %esp,%ebp
  51:	51                   	push   %ecx
  52:	83 ec 04             	sub    $0x4,%esp
  mmaptest();
  55:	e8 a6 ff ff ff       	call   0 <mmaptest>
  exit();
  5a:	e8 57 02 00 00       	call   2b6 <exit>

0000005f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  5f:	55                   	push   %ebp
  60:	89 e5                	mov    %esp,%ebp
  62:	57                   	push   %edi
  63:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  67:	8b 55 10             	mov    0x10(%ebp),%edx
  6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  6d:	89 cb                	mov    %ecx,%ebx
  6f:	89 df                	mov    %ebx,%edi
  71:	89 d1                	mov    %edx,%ecx
  73:	fc                   	cld    
  74:	f3 aa                	rep stos %al,%es:(%edi)
  76:	89 ca                	mov    %ecx,%edx
  78:	89 fb                	mov    %edi,%ebx
  7a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  7d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  80:	90                   	nop
  81:	5b                   	pop    %ebx
  82:	5f                   	pop    %edi
  83:	5d                   	pop    %ebp
  84:	c3                   	ret    

00000085 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  85:	55                   	push   %ebp
  86:	89 e5                	mov    %esp,%ebp
  88:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  8b:	8b 45 08             	mov    0x8(%ebp),%eax
  8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  91:	90                   	nop
  92:	8b 45 08             	mov    0x8(%ebp),%eax
  95:	8d 50 01             	lea    0x1(%eax),%edx
  98:	89 55 08             	mov    %edx,0x8(%ebp)
  9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  9e:	8d 4a 01             	lea    0x1(%edx),%ecx
  a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  a4:	0f b6 12             	movzbl (%edx),%edx
  a7:	88 10                	mov    %dl,(%eax)
  a9:	0f b6 00             	movzbl (%eax),%eax
  ac:	84 c0                	test   %al,%al
  ae:	75 e2                	jne    92 <strcpy+0xd>
    ;
  return os;
  b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b3:	c9                   	leave  
  b4:	c3                   	ret    

000000b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  b8:	eb 08                	jmp    c2 <strcmp+0xd>
    p++, q++;
  ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	0f b6 00             	movzbl (%eax),%eax
  c8:	84 c0                	test   %al,%al
  ca:	74 10                	je     dc <strcmp+0x27>
  cc:	8b 45 08             	mov    0x8(%ebp),%eax
  cf:	0f b6 10             	movzbl (%eax),%edx
  d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  d5:	0f b6 00             	movzbl (%eax),%eax
  d8:	38 c2                	cmp    %al,%dl
  da:	74 de                	je     ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  dc:	8b 45 08             	mov    0x8(%ebp),%eax
  df:	0f b6 00             	movzbl (%eax),%eax
  e2:	0f b6 d0             	movzbl %al,%edx
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	0f b6 00             	movzbl (%eax),%eax
  eb:	0f b6 c0             	movzbl %al,%eax
  ee:	29 c2                	sub    %eax,%edx
  f0:	89 d0                	mov    %edx,%eax
}
  f2:	5d                   	pop    %ebp
  f3:	c3                   	ret    

000000f4 <strlen>:

uint
strlen(char *s)
{
  f4:	55                   	push   %ebp
  f5:	89 e5                	mov    %esp,%ebp
  f7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 101:	eb 04                	jmp    107 <strlen+0x13>
 103:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 107:	8b 55 fc             	mov    -0x4(%ebp),%edx
 10a:	8b 45 08             	mov    0x8(%ebp),%eax
 10d:	01 d0                	add    %edx,%eax
 10f:	0f b6 00             	movzbl (%eax),%eax
 112:	84 c0                	test   %al,%al
 114:	75 ed                	jne    103 <strlen+0xf>
    ;
  return n;
 116:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 119:	c9                   	leave  
 11a:	c3                   	ret    

0000011b <memset>:

void*
memset(void *dst, int c, uint n)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 11e:	8b 45 10             	mov    0x10(%ebp),%eax
 121:	50                   	push   %eax
 122:	ff 75 0c             	pushl  0xc(%ebp)
 125:	ff 75 08             	pushl  0x8(%ebp)
 128:	e8 32 ff ff ff       	call   5f <stosb>
 12d:	83 c4 0c             	add    $0xc,%esp
  return dst;
 130:	8b 45 08             	mov    0x8(%ebp),%eax
}
 133:	c9                   	leave  
 134:	c3                   	ret    

00000135 <strchr>:

char*
strchr(const char *s, char c)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 04             	sub    $0x4,%esp
 13b:	8b 45 0c             	mov    0xc(%ebp),%eax
 13e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 141:	eb 14                	jmp    157 <strchr+0x22>
    if(*s == c)
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	0f b6 00             	movzbl (%eax),%eax
 149:	3a 45 fc             	cmp    -0x4(%ebp),%al
 14c:	75 05                	jne    153 <strchr+0x1e>
      return (char*)s;
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	eb 13                	jmp    166 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 153:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 157:	8b 45 08             	mov    0x8(%ebp),%eax
 15a:	0f b6 00             	movzbl (%eax),%eax
 15d:	84 c0                	test   %al,%al
 15f:	75 e2                	jne    143 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 161:	b8 00 00 00 00       	mov    $0x0,%eax
}
 166:	c9                   	leave  
 167:	c3                   	ret    

00000168 <gets>:

char*
gets(char *buf, int max)
{
 168:	55                   	push   %ebp
 169:	89 e5                	mov    %esp,%ebp
 16b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 175:	eb 42                	jmp    1b9 <gets+0x51>
    cc = read(0, &c, 1);
 177:	83 ec 04             	sub    $0x4,%esp
 17a:	6a 01                	push   $0x1
 17c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 17f:	50                   	push   %eax
 180:	6a 00                	push   $0x0
 182:	e8 47 01 00 00       	call   2ce <read>
 187:	83 c4 10             	add    $0x10,%esp
 18a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 18d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 191:	7e 33                	jle    1c6 <gets+0x5e>
      break;
    buf[i++] = c;
 193:	8b 45 f4             	mov    -0xc(%ebp),%eax
 196:	8d 50 01             	lea    0x1(%eax),%edx
 199:	89 55 f4             	mov    %edx,-0xc(%ebp)
 19c:	89 c2                	mov    %eax,%edx
 19e:	8b 45 08             	mov    0x8(%ebp),%eax
 1a1:	01 c2                	add    %eax,%edx
 1a3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ad:	3c 0a                	cmp    $0xa,%al
 1af:	74 16                	je     1c7 <gets+0x5f>
 1b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1b5:	3c 0d                	cmp    $0xd,%al
 1b7:	74 0e                	je     1c7 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bc:	83 c0 01             	add    $0x1,%eax
 1bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1c2:	7c b3                	jl     177 <gets+0xf>
 1c4:	eb 01                	jmp    1c7 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1c6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	01 d0                	add    %edx,%eax
 1cf:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d5:	c9                   	leave  
 1d6:	c3                   	ret    

000001d7 <stat>:

int
stat(char *n, struct stat *st)
{
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
 1da:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1dd:	83 ec 08             	sub    $0x8,%esp
 1e0:	6a 00                	push   $0x0
 1e2:	ff 75 08             	pushl  0x8(%ebp)
 1e5:	e8 14 01 00 00       	call   2fe <open>
 1ea:	83 c4 10             	add    $0x10,%esp
 1ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1f4:	79 07                	jns    1fd <stat+0x26>
    return -1;
 1f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1fb:	eb 25                	jmp    222 <stat+0x4b>
  r = fstat(fd, st);
 1fd:	83 ec 08             	sub    $0x8,%esp
 200:	ff 75 0c             	pushl  0xc(%ebp)
 203:	ff 75 f4             	pushl  -0xc(%ebp)
 206:	e8 0b 01 00 00       	call   316 <fstat>
 20b:	83 c4 10             	add    $0x10,%esp
 20e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 211:	83 ec 0c             	sub    $0xc,%esp
 214:	ff 75 f4             	pushl  -0xc(%ebp)
 217:	e8 ca 00 00 00       	call   2e6 <close>
 21c:	83 c4 10             	add    $0x10,%esp
  return r;
 21f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 222:	c9                   	leave  
 223:	c3                   	ret    

00000224 <atoi>:

int
atoi(const char *s)
{
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 22a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 231:	eb 25                	jmp    258 <atoi+0x34>
    n = n*10 + *s++ - '0';
 233:	8b 55 fc             	mov    -0x4(%ebp),%edx
 236:	89 d0                	mov    %edx,%eax
 238:	c1 e0 02             	shl    $0x2,%eax
 23b:	01 d0                	add    %edx,%eax
 23d:	01 c0                	add    %eax,%eax
 23f:	89 c1                	mov    %eax,%ecx
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	8d 50 01             	lea    0x1(%eax),%edx
 247:	89 55 08             	mov    %edx,0x8(%ebp)
 24a:	0f b6 00             	movzbl (%eax),%eax
 24d:	0f be c0             	movsbl %al,%eax
 250:	01 c8                	add    %ecx,%eax
 252:	83 e8 30             	sub    $0x30,%eax
 255:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	3c 2f                	cmp    $0x2f,%al
 260:	7e 0a                	jle    26c <atoi+0x48>
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	0f b6 00             	movzbl (%eax),%eax
 268:	3c 39                	cmp    $0x39,%al
 26a:	7e c7                	jle    233 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 26c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 26f:	c9                   	leave  
 270:	c3                   	ret    

00000271 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 27d:	8b 45 0c             	mov    0xc(%ebp),%eax
 280:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 283:	eb 17                	jmp    29c <memmove+0x2b>
    *dst++ = *src++;
 285:	8b 45 fc             	mov    -0x4(%ebp),%eax
 288:	8d 50 01             	lea    0x1(%eax),%edx
 28b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 28e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 291:	8d 4a 01             	lea    0x1(%edx),%ecx
 294:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 297:	0f b6 12             	movzbl (%edx),%edx
 29a:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 29c:	8b 45 10             	mov    0x10(%ebp),%eax
 29f:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a2:	89 55 10             	mov    %edx,0x10(%ebp)
 2a5:	85 c0                	test   %eax,%eax
 2a7:	7f dc                	jg     285 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ac:	c9                   	leave  
 2ad:	c3                   	ret    

000002ae <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2ae:	b8 01 00 00 00       	mov    $0x1,%eax
 2b3:	cd 40                	int    $0x40
 2b5:	c3                   	ret    

000002b6 <exit>:
SYSCALL(exit)
 2b6:	b8 02 00 00 00       	mov    $0x2,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <wait>:
SYSCALL(wait)
 2be:	b8 03 00 00 00       	mov    $0x3,%eax
 2c3:	cd 40                	int    $0x40
 2c5:	c3                   	ret    

000002c6 <pipe>:
SYSCALL(pipe)
 2c6:	b8 04 00 00 00       	mov    $0x4,%eax
 2cb:	cd 40                	int    $0x40
 2cd:	c3                   	ret    

000002ce <read>:
SYSCALL(read)
 2ce:	b8 05 00 00 00       	mov    $0x5,%eax
 2d3:	cd 40                	int    $0x40
 2d5:	c3                   	ret    

000002d6 <seek>:
SYSCALL(seek)
 2d6:	b8 1c 00 00 00       	mov    $0x1c,%eax
 2db:	cd 40                	int    $0x40
 2dd:	c3                   	ret    

000002de <write>:
SYSCALL(write)
 2de:	b8 10 00 00 00       	mov    $0x10,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <close>:
SYSCALL(close)
 2e6:	b8 15 00 00 00       	mov    $0x15,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <kill>:
SYSCALL(kill)
 2ee:	b8 06 00 00 00       	mov    $0x6,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <exec>:
SYSCALL(exec)
 2f6:	b8 07 00 00 00       	mov    $0x7,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <open>:
SYSCALL(open)
 2fe:	b8 0f 00 00 00       	mov    $0xf,%eax
 303:	cd 40                	int    $0x40
 305:	c3                   	ret    

00000306 <mknod>:
SYSCALL(mknod)
 306:	b8 11 00 00 00       	mov    $0x11,%eax
 30b:	cd 40                	int    $0x40
 30d:	c3                   	ret    

0000030e <unlink>:
SYSCALL(unlink)
 30e:	b8 12 00 00 00       	mov    $0x12,%eax
 313:	cd 40                	int    $0x40
 315:	c3                   	ret    

00000316 <fstat>:
SYSCALL(fstat)
 316:	b8 08 00 00 00       	mov    $0x8,%eax
 31b:	cd 40                	int    $0x40
 31d:	c3                   	ret    

0000031e <link>:
SYSCALL(link)
 31e:	b8 13 00 00 00       	mov    $0x13,%eax
 323:	cd 40                	int    $0x40
 325:	c3                   	ret    

00000326 <mkdir>:
SYSCALL(mkdir)
 326:	b8 14 00 00 00       	mov    $0x14,%eax
 32b:	cd 40                	int    $0x40
 32d:	c3                   	ret    

0000032e <chdir>:
SYSCALL(chdir)
 32e:	b8 09 00 00 00       	mov    $0x9,%eax
 333:	cd 40                	int    $0x40
 335:	c3                   	ret    

00000336 <dup>:
SYSCALL(dup)
 336:	b8 0a 00 00 00       	mov    $0xa,%eax
 33b:	cd 40                	int    $0x40
 33d:	c3                   	ret    

0000033e <getpid>:
SYSCALL(getpid)
 33e:	b8 0b 00 00 00       	mov    $0xb,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <sbrk>:
SYSCALL(sbrk)
 346:	b8 0c 00 00 00       	mov    $0xc,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <sleep>:
SYSCALL(sleep)
 34e:	b8 0d 00 00 00       	mov    $0xd,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <uptime>:
SYSCALL(uptime)
 356:	b8 0e 00 00 00       	mov    $0xe,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <procstat>:
SYSCALL(procstat)
 35e:	b8 16 00 00 00       	mov    $0x16,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <setpriority>:
SYSCALL(setpriority)
 366:	b8 17 00 00 00       	mov    $0x17,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <semget>:
SYSCALL(semget)
 36e:	b8 18 00 00 00       	mov    $0x18,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <semfree>:
SYSCALL(semfree)
 376:	b8 19 00 00 00       	mov    $0x19,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <semdown>:
SYSCALL(semdown)
 37e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <semup>:
SYSCALL(semup)
 386:	b8 1b 00 00 00       	mov    $0x1b,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <mmap>:
SYSCALL(mmap)
 38e:	b8 1d 00 00 00       	mov    $0x1d,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	83 ec 18             	sub    $0x18,%esp
 39c:	8b 45 0c             	mov    0xc(%ebp),%eax
 39f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a2:	83 ec 04             	sub    $0x4,%esp
 3a5:	6a 01                	push   $0x1
 3a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3aa:	50                   	push   %eax
 3ab:	ff 75 08             	pushl  0x8(%ebp)
 3ae:	e8 2b ff ff ff       	call   2de <write>
 3b3:	83 c4 10             	add    $0x10,%esp
}
 3b6:	90                   	nop
 3b7:	c9                   	leave  
 3b8:	c3                   	ret    

000003b9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b9:	55                   	push   %ebp
 3ba:	89 e5                	mov    %esp,%ebp
 3bc:	53                   	push   %ebx
 3bd:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3cb:	74 17                	je     3e4 <printint+0x2b>
 3cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d1:	79 11                	jns    3e4 <printint+0x2b>
    neg = 1;
 3d3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	f7 d8                	neg    %eax
 3df:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e2:	eb 06                	jmp    3ea <printint+0x31>
  } else {
    x = xx;
 3e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3f4:	8d 41 01             	lea    0x1(%ecx),%eax
 3f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 400:	ba 00 00 00 00       	mov    $0x0,%edx
 405:	f7 f3                	div    %ebx
 407:	89 d0                	mov    %edx,%eax
 409:	0f b6 80 a8 0a 00 00 	movzbl 0xaa8(%eax),%eax
 410:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 414:	8b 5d 10             	mov    0x10(%ebp),%ebx
 417:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41a:	ba 00 00 00 00       	mov    $0x0,%edx
 41f:	f7 f3                	div    %ebx
 421:	89 45 ec             	mov    %eax,-0x14(%ebp)
 424:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 428:	75 c7                	jne    3f1 <printint+0x38>
  if(neg)
 42a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 42e:	74 2d                	je     45d <printint+0xa4>
    buf[i++] = '-';
 430:	8b 45 f4             	mov    -0xc(%ebp),%eax
 433:	8d 50 01             	lea    0x1(%eax),%edx
 436:	89 55 f4             	mov    %edx,-0xc(%ebp)
 439:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 43e:	eb 1d                	jmp    45d <printint+0xa4>
    putc(fd, buf[i]);
 440:	8d 55 dc             	lea    -0x24(%ebp),%edx
 443:	8b 45 f4             	mov    -0xc(%ebp),%eax
 446:	01 d0                	add    %edx,%eax
 448:	0f b6 00             	movzbl (%eax),%eax
 44b:	0f be c0             	movsbl %al,%eax
 44e:	83 ec 08             	sub    $0x8,%esp
 451:	50                   	push   %eax
 452:	ff 75 08             	pushl  0x8(%ebp)
 455:	e8 3c ff ff ff       	call   396 <putc>
 45a:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 45d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 461:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 465:	79 d9                	jns    440 <printint+0x87>
    putc(fd, buf[i]);
}
 467:	90                   	nop
 468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 473:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 47a:	8d 45 0c             	lea    0xc(%ebp),%eax
 47d:	83 c0 04             	add    $0x4,%eax
 480:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 483:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 48a:	e9 59 01 00 00       	jmp    5e8 <printf+0x17b>
    c = fmt[i] & 0xff;
 48f:	8b 55 0c             	mov    0xc(%ebp),%edx
 492:	8b 45 f0             	mov    -0x10(%ebp),%eax
 495:	01 d0                	add    %edx,%eax
 497:	0f b6 00             	movzbl (%eax),%eax
 49a:	0f be c0             	movsbl %al,%eax
 49d:	25 ff 00 00 00       	and    $0xff,%eax
 4a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a9:	75 2c                	jne    4d7 <printf+0x6a>
      if(c == '%'){
 4ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4af:	75 0c                	jne    4bd <printf+0x50>
        state = '%';
 4b1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b8:	e9 27 01 00 00       	jmp    5e4 <printf+0x177>
      } else {
        putc(fd, c);
 4bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c0:	0f be c0             	movsbl %al,%eax
 4c3:	83 ec 08             	sub    $0x8,%esp
 4c6:	50                   	push   %eax
 4c7:	ff 75 08             	pushl  0x8(%ebp)
 4ca:	e8 c7 fe ff ff       	call   396 <putc>
 4cf:	83 c4 10             	add    $0x10,%esp
 4d2:	e9 0d 01 00 00       	jmp    5e4 <printf+0x177>
      }
    } else if(state == '%'){
 4d7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4db:	0f 85 03 01 00 00    	jne    5e4 <printf+0x177>
      if(c == 'd'){
 4e1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e5:	75 1e                	jne    505 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ea:	8b 00                	mov    (%eax),%eax
 4ec:	6a 01                	push   $0x1
 4ee:	6a 0a                	push   $0xa
 4f0:	50                   	push   %eax
 4f1:	ff 75 08             	pushl  0x8(%ebp)
 4f4:	e8 c0 fe ff ff       	call   3b9 <printint>
 4f9:	83 c4 10             	add    $0x10,%esp
        ap++;
 4fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 500:	e9 d8 00 00 00       	jmp    5dd <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 505:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 509:	74 06                	je     511 <printf+0xa4>
 50b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 50f:	75 1e                	jne    52f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 511:	8b 45 e8             	mov    -0x18(%ebp),%eax
 514:	8b 00                	mov    (%eax),%eax
 516:	6a 00                	push   $0x0
 518:	6a 10                	push   $0x10
 51a:	50                   	push   %eax
 51b:	ff 75 08             	pushl  0x8(%ebp)
 51e:	e8 96 fe ff ff       	call   3b9 <printint>
 523:	83 c4 10             	add    $0x10,%esp
        ap++;
 526:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52a:	e9 ae 00 00 00       	jmp    5dd <printf+0x170>
      } else if(c == 's'){
 52f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 533:	75 43                	jne    578 <printf+0x10b>
        s = (char*)*ap;
 535:	8b 45 e8             	mov    -0x18(%ebp),%eax
 538:	8b 00                	mov    (%eax),%eax
 53a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 541:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 545:	75 25                	jne    56c <printf+0xff>
          s = "(null)";
 547:	c7 45 f4 39 08 00 00 	movl   $0x839,-0xc(%ebp)
        while(*s != 0){
 54e:	eb 1c                	jmp    56c <printf+0xff>
          putc(fd, *s);
 550:	8b 45 f4             	mov    -0xc(%ebp),%eax
 553:	0f b6 00             	movzbl (%eax),%eax
 556:	0f be c0             	movsbl %al,%eax
 559:	83 ec 08             	sub    $0x8,%esp
 55c:	50                   	push   %eax
 55d:	ff 75 08             	pushl  0x8(%ebp)
 560:	e8 31 fe ff ff       	call   396 <putc>
 565:	83 c4 10             	add    $0x10,%esp
          s++;
 568:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	0f b6 00             	movzbl (%eax),%eax
 572:	84 c0                	test   %al,%al
 574:	75 da                	jne    550 <printf+0xe3>
 576:	eb 65                	jmp    5dd <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 578:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 57c:	75 1d                	jne    59b <printf+0x12e>
        putc(fd, *ap);
 57e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	0f be c0             	movsbl %al,%eax
 586:	83 ec 08             	sub    $0x8,%esp
 589:	50                   	push   %eax
 58a:	ff 75 08             	pushl  0x8(%ebp)
 58d:	e8 04 fe ff ff       	call   396 <putc>
 592:	83 c4 10             	add    $0x10,%esp
        ap++;
 595:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 599:	eb 42                	jmp    5dd <printf+0x170>
      } else if(c == '%'){
 59b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59f:	75 17                	jne    5b8 <printf+0x14b>
        putc(fd, c);
 5a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a4:	0f be c0             	movsbl %al,%eax
 5a7:	83 ec 08             	sub    $0x8,%esp
 5aa:	50                   	push   %eax
 5ab:	ff 75 08             	pushl  0x8(%ebp)
 5ae:	e8 e3 fd ff ff       	call   396 <putc>
 5b3:	83 c4 10             	add    $0x10,%esp
 5b6:	eb 25                	jmp    5dd <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b8:	83 ec 08             	sub    $0x8,%esp
 5bb:	6a 25                	push   $0x25
 5bd:	ff 75 08             	pushl  0x8(%ebp)
 5c0:	e8 d1 fd ff ff       	call   396 <putc>
 5c5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5cb:	0f be c0             	movsbl %al,%eax
 5ce:	83 ec 08             	sub    $0x8,%esp
 5d1:	50                   	push   %eax
 5d2:	ff 75 08             	pushl  0x8(%ebp)
 5d5:	e8 bc fd ff ff       	call   396 <putc>
 5da:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ee:	01 d0                	add    %edx,%eax
 5f0:	0f b6 00             	movzbl (%eax),%eax
 5f3:	84 c0                	test   %al,%al
 5f5:	0f 85 94 fe ff ff    	jne    48f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5fb:	90                   	nop
 5fc:	c9                   	leave  
 5fd:	c3                   	ret    

000005fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5fe:	55                   	push   %ebp
 5ff:	89 e5                	mov    %esp,%ebp
 601:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	83 e8 08             	sub    $0x8,%eax
 60a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60d:	a1 c4 0a 00 00       	mov    0xac4,%eax
 612:	89 45 fc             	mov    %eax,-0x4(%ebp)
 615:	eb 24                	jmp    63b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 617:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61a:	8b 00                	mov    (%eax),%eax
 61c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61f:	77 12                	ja     633 <free+0x35>
 621:	8b 45 f8             	mov    -0x8(%ebp),%eax
 624:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 627:	77 24                	ja     64d <free+0x4f>
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 631:	77 1a                	ja     64d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 633:	8b 45 fc             	mov    -0x4(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 641:	76 d4                	jbe    617 <free+0x19>
 643:	8b 45 fc             	mov    -0x4(%ebp),%eax
 646:	8b 00                	mov    (%eax),%eax
 648:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 64b:	76 ca                	jbe    617 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 64d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 650:	8b 40 04             	mov    0x4(%eax),%eax
 653:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65d:	01 c2                	add    %eax,%edx
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	39 c2                	cmp    %eax,%edx
 666:	75 24                	jne    68c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 668:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66b:	8b 50 04             	mov    0x4(%eax),%edx
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 00                	mov    (%eax),%eax
 673:	8b 40 04             	mov    0x4(%eax),%eax
 676:	01 c2                	add    %eax,%edx
 678:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	8b 00                	mov    (%eax),%eax
 683:	8b 10                	mov    (%eax),%edx
 685:	8b 45 f8             	mov    -0x8(%ebp),%eax
 688:	89 10                	mov    %edx,(%eax)
 68a:	eb 0a                	jmp    696 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 10                	mov    (%eax),%edx
 691:	8b 45 f8             	mov    -0x8(%ebp),%eax
 694:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 696:	8b 45 fc             	mov    -0x4(%ebp),%eax
 699:	8b 40 04             	mov    0x4(%eax),%eax
 69c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	01 d0                	add    %edx,%eax
 6a8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ab:	75 20                	jne    6cd <free+0xcf>
    p->s.size += bp->s.size;
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b0:	8b 50 04             	mov    0x4(%eax),%edx
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	8b 40 04             	mov    0x4(%eax),%eax
 6b9:	01 c2                	add    %eax,%edx
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c4:	8b 10                	mov    (%eax),%edx
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	89 10                	mov    %edx,(%eax)
 6cb:	eb 08                	jmp    6d5 <free+0xd7>
  } else
    p->s.ptr = bp;
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d3:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	a3 c4 0a 00 00       	mov    %eax,0xac4
}
 6dd:	90                   	nop
 6de:	c9                   	leave  
 6df:	c3                   	ret    

000006e0 <morecore>:

static Header*
morecore(uint nu)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ed:	77 07                	ja     6f6 <morecore+0x16>
    nu = 4096;
 6ef:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f6:	8b 45 08             	mov    0x8(%ebp),%eax
 6f9:	c1 e0 03             	shl    $0x3,%eax
 6fc:	83 ec 0c             	sub    $0xc,%esp
 6ff:	50                   	push   %eax
 700:	e8 41 fc ff ff       	call   346 <sbrk>
 705:	83 c4 10             	add    $0x10,%esp
 708:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 70b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 70f:	75 07                	jne    718 <morecore+0x38>
    return 0;
 711:	b8 00 00 00 00       	mov    $0x0,%eax
 716:	eb 26                	jmp    73e <morecore+0x5e>
  hp = (Header*)p;
 718:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 71e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 721:	8b 55 08             	mov    0x8(%ebp),%edx
 724:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 727:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72a:	83 c0 08             	add    $0x8,%eax
 72d:	83 ec 0c             	sub    $0xc,%esp
 730:	50                   	push   %eax
 731:	e8 c8 fe ff ff       	call   5fe <free>
 736:	83 c4 10             	add    $0x10,%esp
  return freep;
 739:	a1 c4 0a 00 00       	mov    0xac4,%eax
}
 73e:	c9                   	leave  
 73f:	c3                   	ret    

00000740 <malloc>:

void*
malloc(uint nbytes)
{
 740:	55                   	push   %ebp
 741:	89 e5                	mov    %esp,%ebp
 743:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 746:	8b 45 08             	mov    0x8(%ebp),%eax
 749:	83 c0 07             	add    $0x7,%eax
 74c:	c1 e8 03             	shr    $0x3,%eax
 74f:	83 c0 01             	add    $0x1,%eax
 752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 755:	a1 c4 0a 00 00       	mov    0xac4,%eax
 75a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 75d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 761:	75 23                	jne    786 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 763:	c7 45 f0 bc 0a 00 00 	movl   $0xabc,-0x10(%ebp)
 76a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76d:	a3 c4 0a 00 00       	mov    %eax,0xac4
 772:	a1 c4 0a 00 00       	mov    0xac4,%eax
 777:	a3 bc 0a 00 00       	mov    %eax,0xabc
    base.s.size = 0;
 77c:	c7 05 c0 0a 00 00 00 	movl   $0x0,0xac0
 783:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 786:	8b 45 f0             	mov    -0x10(%ebp),%eax
 789:	8b 00                	mov    (%eax),%eax
 78b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 78e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 791:	8b 40 04             	mov    0x4(%eax),%eax
 794:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 797:	72 4d                	jb     7e6 <malloc+0xa6>
      if(p->s.size == nunits)
 799:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79c:	8b 40 04             	mov    0x4(%eax),%eax
 79f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7a2:	75 0c                	jne    7b0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 10                	mov    (%eax),%edx
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	89 10                	mov    %edx,(%eax)
 7ae:	eb 26                	jmp    7d6 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b3:	8b 40 04             	mov    0x4(%eax),%eax
 7b6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7b9:	89 c2                	mov    %eax,%edx
 7bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7be:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	8b 40 04             	mov    0x4(%eax),%eax
 7c7:	c1 e0 03             	shl    $0x3,%eax
 7ca:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d9:	a3 c4 0a 00 00       	mov    %eax,0xac4
      return (void*)(p + 1);
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	83 c0 08             	add    $0x8,%eax
 7e4:	eb 3b                	jmp    821 <malloc+0xe1>
    }
    if(p == freep)
 7e6:	a1 c4 0a 00 00       	mov    0xac4,%eax
 7eb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7ee:	75 1e                	jne    80e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7f0:	83 ec 0c             	sub    $0xc,%esp
 7f3:	ff 75 ec             	pushl  -0x14(%ebp)
 7f6:	e8 e5 fe ff ff       	call   6e0 <morecore>
 7fb:	83 c4 10             	add    $0x10,%esp
 7fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
 801:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 805:	75 07                	jne    80e <malloc+0xce>
        return 0;
 807:	b8 00 00 00 00       	mov    $0x0,%eax
 80c:	eb 13                	jmp    821 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	89 45 f0             	mov    %eax,-0x10(%ebp)
 814:	8b 45 f4             	mov    -0xc(%ebp),%eax
 817:	8b 00                	mov    (%eax),%eax
 819:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 81c:	e9 6d ff ff ff       	jmp    78e <malloc+0x4e>
}
 821:	c9                   	leave  
 822:	c3                   	ret    
