
_prioritytest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <prioritytest>:



void
prioritytest(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int i;
  int pid;
  printf(1, "prioritytest\n");
   6:	83 ec 08             	sub    $0x8,%esp
   9:	68 48 08 00 00       	push   $0x848
   e:	6a 01                	push   $0x1
  10:	e8 7d 04 00 00       	call   492 <printf>
  15:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  18:	e8 ae 02 00 00       	call   2cb <fork>
  1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i=0;i<4;i++){
  20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  27:	eb 0f                	jmp    38 <prioritytest+0x38>
      fork();
  29:	e8 9d 02 00 00       	call   2cb <fork>

      if(pid==0){
  2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  32:	74 0c                	je     40 <prioritytest+0x40>
{
  int i;
  int pid;
  printf(1, "prioritytest\n");
    pid = fork();
    for (i=0;i<4;i++){
  34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  38:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  3c:	7e eb                	jle    29 <prioritytest+0x29>
  3e:	eb 01                	jmp    41 <prioritytest+0x41>
      fork();

      if(pid==0){
        break;
  40:	90                   	nop
      }
    }

    if(pid != 0){
  41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  45:	74 0f                	je     56 <prioritytest+0x56>
      for(;;){
        setpriority(0);
  47:	83 ec 0c             	sub    $0xc,%esp
  4a:	6a 00                	push   $0x0
  4c:	e8 32 03 00 00       	call   383 <setpriority>
  51:	83 c4 10             	add    $0x10,%esp
      }
  54:	eb f1                	jmp    47 <prioritytest+0x47>
    }
    if(pid == 0){
  56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5a:	75 02                	jne    5e <prioritytest+0x5e>
        //setpriority(3);
        for(;;){
        }
  5c:	eb fe                	jmp    5c <prioritytest+0x5c>
      }
    }
  5e:	90                   	nop
  5f:	c9                   	leave  
  60:	c3                   	ret    

00000061 <main>:



int
main(void)
{
  61:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  65:	83 e4 f0             	and    $0xfffffff0,%esp
  68:	ff 71 fc             	pushl  -0x4(%ecx)
  6b:	55                   	push   %ebp
  6c:	89 e5                	mov    %esp,%ebp
  6e:	51                   	push   %ecx
  6f:	83 ec 04             	sub    $0x4,%esp
  prioritytest();
  72:	e8 89 ff ff ff       	call   0 <prioritytest>
  exit();
  77:	e8 57 02 00 00       	call   2d3 <exit>

0000007c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	57                   	push   %edi
  80:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  84:	8b 55 10             	mov    0x10(%ebp),%edx
  87:	8b 45 0c             	mov    0xc(%ebp),%eax
  8a:	89 cb                	mov    %ecx,%ebx
  8c:	89 df                	mov    %ebx,%edi
  8e:	89 d1                	mov    %edx,%ecx
  90:	fc                   	cld    
  91:	f3 aa                	rep stos %al,%es:(%edi)
  93:	89 ca                	mov    %ecx,%edx
  95:	89 fb                	mov    %edi,%ebx
  97:	89 5d 08             	mov    %ebx,0x8(%ebp)
  9a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9d:	90                   	nop
  9e:	5b                   	pop    %ebx
  9f:	5f                   	pop    %edi
  a0:	5d                   	pop    %ebp
  a1:	c3                   	ret    

000000a2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a2:	55                   	push   %ebp
  a3:	89 e5                	mov    %esp,%ebp
  a5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ae:	90                   	nop
  af:	8b 45 08             	mov    0x8(%ebp),%eax
  b2:	8d 50 01             	lea    0x1(%eax),%edx
  b5:	89 55 08             	mov    %edx,0x8(%ebp)
  b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  bb:	8d 4a 01             	lea    0x1(%edx),%ecx
  be:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  c1:	0f b6 12             	movzbl (%edx),%edx
  c4:	88 10                	mov    %dl,(%eax)
  c6:	0f b6 00             	movzbl (%eax),%eax
  c9:	84 c0                	test   %al,%al
  cb:	75 e2                	jne    af <strcpy+0xd>
    ;
  return os;
  cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d0:	c9                   	leave  
  d1:	c3                   	ret    

000000d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d2:	55                   	push   %ebp
  d3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d5:	eb 08                	jmp    df <strcmp+0xd>
    p++, q++;
  d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  db:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	0f b6 00             	movzbl (%eax),%eax
  e5:	84 c0                	test   %al,%al
  e7:	74 10                	je     f9 <strcmp+0x27>
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	0f b6 10             	movzbl (%eax),%edx
  ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  f2:	0f b6 00             	movzbl (%eax),%eax
  f5:	38 c2                	cmp    %al,%dl
  f7:	74 de                	je     d7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f9:	8b 45 08             	mov    0x8(%ebp),%eax
  fc:	0f b6 00             	movzbl (%eax),%eax
  ff:	0f b6 d0             	movzbl %al,%edx
 102:	8b 45 0c             	mov    0xc(%ebp),%eax
 105:	0f b6 00             	movzbl (%eax),%eax
 108:	0f b6 c0             	movzbl %al,%eax
 10b:	29 c2                	sub    %eax,%edx
 10d:	89 d0                	mov    %edx,%eax
}
 10f:	5d                   	pop    %ebp
 110:	c3                   	ret    

00000111 <strlen>:

uint
strlen(char *s)
{
 111:	55                   	push   %ebp
 112:	89 e5                	mov    %esp,%ebp
 114:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 117:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 11e:	eb 04                	jmp    124 <strlen+0x13>
 120:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 124:	8b 55 fc             	mov    -0x4(%ebp),%edx
 127:	8b 45 08             	mov    0x8(%ebp),%eax
 12a:	01 d0                	add    %edx,%eax
 12c:	0f b6 00             	movzbl (%eax),%eax
 12f:	84 c0                	test   %al,%al
 131:	75 ed                	jne    120 <strlen+0xf>
    ;
  return n;
 133:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 136:	c9                   	leave  
 137:	c3                   	ret    

00000138 <memset>:

void*
memset(void *dst, int c, uint n)
{
 138:	55                   	push   %ebp
 139:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 13b:	8b 45 10             	mov    0x10(%ebp),%eax
 13e:	50                   	push   %eax
 13f:	ff 75 0c             	pushl  0xc(%ebp)
 142:	ff 75 08             	pushl  0x8(%ebp)
 145:	e8 32 ff ff ff       	call   7c <stosb>
 14a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 14d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 150:	c9                   	leave  
 151:	c3                   	ret    

00000152 <strchr>:

char*
strchr(const char *s, char c)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
 155:	83 ec 04             	sub    $0x4,%esp
 158:	8b 45 0c             	mov    0xc(%ebp),%eax
 15b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15e:	eb 14                	jmp    174 <strchr+0x22>
    if(*s == c)
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	0f b6 00             	movzbl (%eax),%eax
 166:	3a 45 fc             	cmp    -0x4(%ebp),%al
 169:	75 05                	jne    170 <strchr+0x1e>
      return (char*)s;
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	eb 13                	jmp    183 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 170:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	0f b6 00             	movzbl (%eax),%eax
 17a:	84 c0                	test   %al,%al
 17c:	75 e2                	jne    160 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 17e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <gets>:

char*
gets(char *buf, int max)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 192:	eb 42                	jmp    1d6 <gets+0x51>
    cc = read(0, &c, 1);
 194:	83 ec 04             	sub    $0x4,%esp
 197:	6a 01                	push   $0x1
 199:	8d 45 ef             	lea    -0x11(%ebp),%eax
 19c:	50                   	push   %eax
 19d:	6a 00                	push   $0x0
 19f:	e8 47 01 00 00       	call   2eb <read>
 1a4:	83 c4 10             	add    $0x10,%esp
 1a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ae:	7e 33                	jle    1e3 <gets+0x5e>
      break;
    buf[i++] = c;
 1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b3:	8d 50 01             	lea    0x1(%eax),%edx
 1b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1b9:	89 c2                	mov    %eax,%edx
 1bb:	8b 45 08             	mov    0x8(%ebp),%eax
 1be:	01 c2                	add    %eax,%edx
 1c0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ca:	3c 0a                	cmp    $0xa,%al
 1cc:	74 16                	je     1e4 <gets+0x5f>
 1ce:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d2:	3c 0d                	cmp    $0xd,%al
 1d4:	74 0e                	je     1e4 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d9:	83 c0 01             	add    $0x1,%eax
 1dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1df:	7c b3                	jl     194 <gets+0xf>
 1e1:	eb 01                	jmp    1e4 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1e3:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	01 d0                	add    %edx,%eax
 1ec:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f2:	c9                   	leave  
 1f3:	c3                   	ret    

000001f4 <stat>:

int
stat(char *n, struct stat *st)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fa:	83 ec 08             	sub    $0x8,%esp
 1fd:	6a 00                	push   $0x0
 1ff:	ff 75 08             	pushl  0x8(%ebp)
 202:	e8 14 01 00 00       	call   31b <open>
 207:	83 c4 10             	add    $0x10,%esp
 20a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 211:	79 07                	jns    21a <stat+0x26>
    return -1;
 213:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 218:	eb 25                	jmp    23f <stat+0x4b>
  r = fstat(fd, st);
 21a:	83 ec 08             	sub    $0x8,%esp
 21d:	ff 75 0c             	pushl  0xc(%ebp)
 220:	ff 75 f4             	pushl  -0xc(%ebp)
 223:	e8 0b 01 00 00       	call   333 <fstat>
 228:	83 c4 10             	add    $0x10,%esp
 22b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22e:	83 ec 0c             	sub    $0xc,%esp
 231:	ff 75 f4             	pushl  -0xc(%ebp)
 234:	e8 ca 00 00 00       	call   303 <close>
 239:	83 c4 10             	add    $0x10,%esp
  return r;
 23c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <atoi>:

int
atoi(const char *s)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 247:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24e:	eb 25                	jmp    275 <atoi+0x34>
    n = n*10 + *s++ - '0';
 250:	8b 55 fc             	mov    -0x4(%ebp),%edx
 253:	89 d0                	mov    %edx,%eax
 255:	c1 e0 02             	shl    $0x2,%eax
 258:	01 d0                	add    %edx,%eax
 25a:	01 c0                	add    %eax,%eax
 25c:	89 c1                	mov    %eax,%ecx
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	8d 50 01             	lea    0x1(%eax),%edx
 264:	89 55 08             	mov    %edx,0x8(%ebp)
 267:	0f b6 00             	movzbl (%eax),%eax
 26a:	0f be c0             	movsbl %al,%eax
 26d:	01 c8                	add    %ecx,%eax
 26f:	83 e8 30             	sub    $0x30,%eax
 272:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	0f b6 00             	movzbl (%eax),%eax
 27b:	3c 2f                	cmp    $0x2f,%al
 27d:	7e 0a                	jle    289 <atoi+0x48>
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	0f b6 00             	movzbl (%eax),%eax
 285:	3c 39                	cmp    $0x39,%al
 287:	7e c7                	jle    250 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 289:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2a0:	eb 17                	jmp    2b9 <memmove+0x2b>
    *dst++ = *src++;
 2a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a5:	8d 50 01             	lea    0x1(%eax),%edx
 2a8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ae:	8d 4a 01             	lea    0x1(%edx),%ecx
 2b1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2b4:	0f b6 12             	movzbl (%edx),%edx
 2b7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b9:	8b 45 10             	mov    0x10(%ebp),%eax
 2bc:	8d 50 ff             	lea    -0x1(%eax),%edx
 2bf:	89 55 10             	mov    %edx,0x10(%ebp)
 2c2:	85 c0                	test   %eax,%eax
 2c4:	7f dc                	jg     2a2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c9:	c9                   	leave  
 2ca:	c3                   	ret    

000002cb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2cb:	b8 01 00 00 00       	mov    $0x1,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <exit>:
SYSCALL(exit)
 2d3:	b8 02 00 00 00       	mov    $0x2,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <wait>:
SYSCALL(wait)
 2db:	b8 03 00 00 00       	mov    $0x3,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <pipe>:
SYSCALL(pipe)
 2e3:	b8 04 00 00 00       	mov    $0x4,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <read>:
SYSCALL(read)
 2eb:	b8 05 00 00 00       	mov    $0x5,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <seek>:
SYSCALL(seek)
 2f3:	b8 1c 00 00 00       	mov    $0x1c,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <write>:
SYSCALL(write)
 2fb:	b8 10 00 00 00       	mov    $0x10,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <close>:
SYSCALL(close)
 303:	b8 15 00 00 00       	mov    $0x15,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <kill>:
SYSCALL(kill)
 30b:	b8 06 00 00 00       	mov    $0x6,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <exec>:
SYSCALL(exec)
 313:	b8 07 00 00 00       	mov    $0x7,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <open>:
SYSCALL(open)
 31b:	b8 0f 00 00 00       	mov    $0xf,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <mknod>:
SYSCALL(mknod)
 323:	b8 11 00 00 00       	mov    $0x11,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <unlink>:
SYSCALL(unlink)
 32b:	b8 12 00 00 00       	mov    $0x12,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <fstat>:
SYSCALL(fstat)
 333:	b8 08 00 00 00       	mov    $0x8,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <link>:
SYSCALL(link)
 33b:	b8 13 00 00 00       	mov    $0x13,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <mkdir>:
SYSCALL(mkdir)
 343:	b8 14 00 00 00       	mov    $0x14,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <chdir>:
SYSCALL(chdir)
 34b:	b8 09 00 00 00       	mov    $0x9,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <dup>:
SYSCALL(dup)
 353:	b8 0a 00 00 00       	mov    $0xa,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <getpid>:
SYSCALL(getpid)
 35b:	b8 0b 00 00 00       	mov    $0xb,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <sbrk>:
SYSCALL(sbrk)
 363:	b8 0c 00 00 00       	mov    $0xc,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <sleep>:
SYSCALL(sleep)
 36b:	b8 0d 00 00 00       	mov    $0xd,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <uptime>:
SYSCALL(uptime)
 373:	b8 0e 00 00 00       	mov    $0xe,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <procstat>:
SYSCALL(procstat)
 37b:	b8 16 00 00 00       	mov    $0x16,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <setpriority>:
SYSCALL(setpriority)
 383:	b8 17 00 00 00       	mov    $0x17,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <semget>:
SYSCALL(semget)
 38b:	b8 18 00 00 00       	mov    $0x18,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <semfree>:
SYSCALL(semfree)
 393:	b8 19 00 00 00       	mov    $0x19,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <semdown>:
SYSCALL(semdown)
 39b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <semup>:
SYSCALL(semup)
 3a3:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <mmap>:
SYSCALL(mmap)
 3ab:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <munmap>:
SYSCALL(munmap)
 3b3:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3bb:	55                   	push   %ebp
 3bc:	89 e5                	mov    %esp,%ebp
 3be:	83 ec 18             	sub    $0x18,%esp
 3c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c7:	83 ec 04             	sub    $0x4,%esp
 3ca:	6a 01                	push   $0x1
 3cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3cf:	50                   	push   %eax
 3d0:	ff 75 08             	pushl  0x8(%ebp)
 3d3:	e8 23 ff ff ff       	call   2fb <write>
 3d8:	83 c4 10             	add    $0x10,%esp
}
 3db:	90                   	nop
 3dc:	c9                   	leave  
 3dd:	c3                   	ret    

000003de <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3de:	55                   	push   %ebp
 3df:	89 e5                	mov    %esp,%ebp
 3e1:	53                   	push   %ebx
 3e2:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3ec:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3f0:	74 17                	je     409 <printint+0x2b>
 3f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f6:	79 11                	jns    409 <printint+0x2b>
    neg = 1;
 3f8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 402:	f7 d8                	neg    %eax
 404:	89 45 ec             	mov    %eax,-0x14(%ebp)
 407:	eb 06                	jmp    40f <printint+0x31>
  } else {
    x = xx;
 409:	8b 45 0c             	mov    0xc(%ebp),%eax
 40c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 416:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 419:	8d 41 01             	lea    0x1(%ecx),%eax
 41c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 41f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 422:	8b 45 ec             	mov    -0x14(%ebp),%eax
 425:	ba 00 00 00 00       	mov    $0x0,%edx
 42a:	f7 f3                	div    %ebx
 42c:	89 d0                	mov    %edx,%eax
 42e:	0f b6 80 c8 0a 00 00 	movzbl 0xac8(%eax),%eax
 435:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 439:	8b 5d 10             	mov    0x10(%ebp),%ebx
 43c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43f:	ba 00 00 00 00       	mov    $0x0,%edx
 444:	f7 f3                	div    %ebx
 446:	89 45 ec             	mov    %eax,-0x14(%ebp)
 449:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 44d:	75 c7                	jne    416 <printint+0x38>
  if(neg)
 44f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 453:	74 2d                	je     482 <printint+0xa4>
    buf[i++] = '-';
 455:	8b 45 f4             	mov    -0xc(%ebp),%eax
 458:	8d 50 01             	lea    0x1(%eax),%edx
 45b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 463:	eb 1d                	jmp    482 <printint+0xa4>
    putc(fd, buf[i]);
 465:	8d 55 dc             	lea    -0x24(%ebp),%edx
 468:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46b:	01 d0                	add    %edx,%eax
 46d:	0f b6 00             	movzbl (%eax),%eax
 470:	0f be c0             	movsbl %al,%eax
 473:	83 ec 08             	sub    $0x8,%esp
 476:	50                   	push   %eax
 477:	ff 75 08             	pushl  0x8(%ebp)
 47a:	e8 3c ff ff ff       	call   3bb <putc>
 47f:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 482:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 486:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 48a:	79 d9                	jns    465 <printint+0x87>
    putc(fd, buf[i]);
}
 48c:	90                   	nop
 48d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 490:	c9                   	leave  
 491:	c3                   	ret    

00000492 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 492:	55                   	push   %ebp
 493:	89 e5                	mov    %esp,%ebp
 495:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 498:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 49f:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a2:	83 c0 04             	add    $0x4,%eax
 4a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4af:	e9 59 01 00 00       	jmp    60d <printf+0x17b>
    c = fmt[i] & 0xff;
 4b4:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ba:	01 d0                	add    %edx,%eax
 4bc:	0f b6 00             	movzbl (%eax),%eax
 4bf:	0f be c0             	movsbl %al,%eax
 4c2:	25 ff 00 00 00       	and    $0xff,%eax
 4c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ce:	75 2c                	jne    4fc <printf+0x6a>
      if(c == '%'){
 4d0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d4:	75 0c                	jne    4e2 <printf+0x50>
        state = '%';
 4d6:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4dd:	e9 27 01 00 00       	jmp    609 <printf+0x177>
      } else {
        putc(fd, c);
 4e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e5:	0f be c0             	movsbl %al,%eax
 4e8:	83 ec 08             	sub    $0x8,%esp
 4eb:	50                   	push   %eax
 4ec:	ff 75 08             	pushl  0x8(%ebp)
 4ef:	e8 c7 fe ff ff       	call   3bb <putc>
 4f4:	83 c4 10             	add    $0x10,%esp
 4f7:	e9 0d 01 00 00       	jmp    609 <printf+0x177>
      }
    } else if(state == '%'){
 4fc:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 500:	0f 85 03 01 00 00    	jne    609 <printf+0x177>
      if(c == 'd'){
 506:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 50a:	75 1e                	jne    52a <printf+0x98>
        printint(fd, *ap, 10, 1);
 50c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50f:	8b 00                	mov    (%eax),%eax
 511:	6a 01                	push   $0x1
 513:	6a 0a                	push   $0xa
 515:	50                   	push   %eax
 516:	ff 75 08             	pushl  0x8(%ebp)
 519:	e8 c0 fe ff ff       	call   3de <printint>
 51e:	83 c4 10             	add    $0x10,%esp
        ap++;
 521:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 525:	e9 d8 00 00 00       	jmp    602 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 52a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52e:	74 06                	je     536 <printf+0xa4>
 530:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 534:	75 1e                	jne    554 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 536:	8b 45 e8             	mov    -0x18(%ebp),%eax
 539:	8b 00                	mov    (%eax),%eax
 53b:	6a 00                	push   $0x0
 53d:	6a 10                	push   $0x10
 53f:	50                   	push   %eax
 540:	ff 75 08             	pushl  0x8(%ebp)
 543:	e8 96 fe ff ff       	call   3de <printint>
 548:	83 c4 10             	add    $0x10,%esp
        ap++;
 54b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54f:	e9 ae 00 00 00       	jmp    602 <printf+0x170>
      } else if(c == 's'){
 554:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 558:	75 43                	jne    59d <printf+0x10b>
        s = (char*)*ap;
 55a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55d:	8b 00                	mov    (%eax),%eax
 55f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 562:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 566:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 56a:	75 25                	jne    591 <printf+0xff>
          s = "(null)";
 56c:	c7 45 f4 56 08 00 00 	movl   $0x856,-0xc(%ebp)
        while(*s != 0){
 573:	eb 1c                	jmp    591 <printf+0xff>
          putc(fd, *s);
 575:	8b 45 f4             	mov    -0xc(%ebp),%eax
 578:	0f b6 00             	movzbl (%eax),%eax
 57b:	0f be c0             	movsbl %al,%eax
 57e:	83 ec 08             	sub    $0x8,%esp
 581:	50                   	push   %eax
 582:	ff 75 08             	pushl  0x8(%ebp)
 585:	e8 31 fe ff ff       	call   3bb <putc>
 58a:	83 c4 10             	add    $0x10,%esp
          s++;
 58d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 591:	8b 45 f4             	mov    -0xc(%ebp),%eax
 594:	0f b6 00             	movzbl (%eax),%eax
 597:	84 c0                	test   %al,%al
 599:	75 da                	jne    575 <printf+0xe3>
 59b:	eb 65                	jmp    602 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 59d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5a1:	75 1d                	jne    5c0 <printf+0x12e>
        putc(fd, *ap);
 5a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a6:	8b 00                	mov    (%eax),%eax
 5a8:	0f be c0             	movsbl %al,%eax
 5ab:	83 ec 08             	sub    $0x8,%esp
 5ae:	50                   	push   %eax
 5af:	ff 75 08             	pushl  0x8(%ebp)
 5b2:	e8 04 fe ff ff       	call   3bb <putc>
 5b7:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5be:	eb 42                	jmp    602 <printf+0x170>
      } else if(c == '%'){
 5c0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c4:	75 17                	jne    5dd <printf+0x14b>
        putc(fd, c);
 5c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c9:	0f be c0             	movsbl %al,%eax
 5cc:	83 ec 08             	sub    $0x8,%esp
 5cf:	50                   	push   %eax
 5d0:	ff 75 08             	pushl  0x8(%ebp)
 5d3:	e8 e3 fd ff ff       	call   3bb <putc>
 5d8:	83 c4 10             	add    $0x10,%esp
 5db:	eb 25                	jmp    602 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5dd:	83 ec 08             	sub    $0x8,%esp
 5e0:	6a 25                	push   $0x25
 5e2:	ff 75 08             	pushl  0x8(%ebp)
 5e5:	e8 d1 fd ff ff       	call   3bb <putc>
 5ea:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f0:	0f be c0             	movsbl %al,%eax
 5f3:	83 ec 08             	sub    $0x8,%esp
 5f6:	50                   	push   %eax
 5f7:	ff 75 08             	pushl  0x8(%ebp)
 5fa:	e8 bc fd ff ff       	call   3bb <putc>
 5ff:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 602:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 609:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60d:	8b 55 0c             	mov    0xc(%ebp),%edx
 610:	8b 45 f0             	mov    -0x10(%ebp),%eax
 613:	01 d0                	add    %edx,%eax
 615:	0f b6 00             	movzbl (%eax),%eax
 618:	84 c0                	test   %al,%al
 61a:	0f 85 94 fe ff ff    	jne    4b4 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 620:	90                   	nop
 621:	c9                   	leave  
 622:	c3                   	ret    

00000623 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 623:	55                   	push   %ebp
 624:	89 e5                	mov    %esp,%ebp
 626:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 629:	8b 45 08             	mov    0x8(%ebp),%eax
 62c:	83 e8 08             	sub    $0x8,%eax
 62f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 632:	a1 e4 0a 00 00       	mov    0xae4,%eax
 637:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63a:	eb 24                	jmp    660 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	8b 00                	mov    (%eax),%eax
 641:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 644:	77 12                	ja     658 <free+0x35>
 646:	8b 45 f8             	mov    -0x8(%ebp),%eax
 649:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64c:	77 24                	ja     672 <free+0x4f>
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 656:	77 1a                	ja     672 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 658:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65b:	8b 00                	mov    (%eax),%eax
 65d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 660:	8b 45 f8             	mov    -0x8(%ebp),%eax
 663:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 666:	76 d4                	jbe    63c <free+0x19>
 668:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66b:	8b 00                	mov    (%eax),%eax
 66d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 670:	76 ca                	jbe    63c <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 672:	8b 45 f8             	mov    -0x8(%ebp),%eax
 675:	8b 40 04             	mov    0x4(%eax),%eax
 678:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 67f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 682:	01 c2                	add    %eax,%edx
 684:	8b 45 fc             	mov    -0x4(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	39 c2                	cmp    %eax,%edx
 68b:	75 24                	jne    6b1 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 68d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 690:	8b 50 04             	mov    0x4(%eax),%edx
 693:	8b 45 fc             	mov    -0x4(%ebp),%eax
 696:	8b 00                	mov    (%eax),%eax
 698:	8b 40 04             	mov    0x4(%eax),%eax
 69b:	01 c2                	add    %eax,%edx
 69d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a0:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	8b 00                	mov    (%eax),%eax
 6a8:	8b 10                	mov    (%eax),%edx
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	89 10                	mov    %edx,(%eax)
 6af:	eb 0a                	jmp    6bb <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	8b 10                	mov    (%eax),%edx
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	8b 40 04             	mov    0x4(%eax),%eax
 6c1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cb:	01 d0                	add    %edx,%eax
 6cd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d0:	75 20                	jne    6f2 <free+0xcf>
    p->s.size += bp->s.size;
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	8b 50 04             	mov    0x4(%eax),%edx
 6d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6db:	8b 40 04             	mov    0x4(%eax),%eax
 6de:	01 c2                	add    %eax,%edx
 6e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e9:	8b 10                	mov    (%eax),%edx
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	89 10                	mov    %edx,(%eax)
 6f0:	eb 08                	jmp    6fa <free+0xd7>
  } else
    p->s.ptr = bp;
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6f8:	89 10                	mov    %edx,(%eax)
  freep = p;
 6fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fd:	a3 e4 0a 00 00       	mov    %eax,0xae4
}
 702:	90                   	nop
 703:	c9                   	leave  
 704:	c3                   	ret    

00000705 <morecore>:

static Header*
morecore(uint nu)
{
 705:	55                   	push   %ebp
 706:	89 e5                	mov    %esp,%ebp
 708:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 70b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 712:	77 07                	ja     71b <morecore+0x16>
    nu = 4096;
 714:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	c1 e0 03             	shl    $0x3,%eax
 721:	83 ec 0c             	sub    $0xc,%esp
 724:	50                   	push   %eax
 725:	e8 39 fc ff ff       	call   363 <sbrk>
 72a:	83 c4 10             	add    $0x10,%esp
 72d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 730:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 734:	75 07                	jne    73d <morecore+0x38>
    return 0;
 736:	b8 00 00 00 00       	mov    $0x0,%eax
 73b:	eb 26                	jmp    763 <morecore+0x5e>
  hp = (Header*)p;
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 743:	8b 45 f0             	mov    -0x10(%ebp),%eax
 746:	8b 55 08             	mov    0x8(%ebp),%edx
 749:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74f:	83 c0 08             	add    $0x8,%eax
 752:	83 ec 0c             	sub    $0xc,%esp
 755:	50                   	push   %eax
 756:	e8 c8 fe ff ff       	call   623 <free>
 75b:	83 c4 10             	add    $0x10,%esp
  return freep;
 75e:	a1 e4 0a 00 00       	mov    0xae4,%eax
}
 763:	c9                   	leave  
 764:	c3                   	ret    

00000765 <malloc>:

void*
malloc(uint nbytes)
{
 765:	55                   	push   %ebp
 766:	89 e5                	mov    %esp,%ebp
 768:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76b:	8b 45 08             	mov    0x8(%ebp),%eax
 76e:	83 c0 07             	add    $0x7,%eax
 771:	c1 e8 03             	shr    $0x3,%eax
 774:	83 c0 01             	add    $0x1,%eax
 777:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 77a:	a1 e4 0a 00 00       	mov    0xae4,%eax
 77f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 782:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 786:	75 23                	jne    7ab <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 788:	c7 45 f0 dc 0a 00 00 	movl   $0xadc,-0x10(%ebp)
 78f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 792:	a3 e4 0a 00 00       	mov    %eax,0xae4
 797:	a1 e4 0a 00 00       	mov    0xae4,%eax
 79c:	a3 dc 0a 00 00       	mov    %eax,0xadc
    base.s.size = 0;
 7a1:	c7 05 e0 0a 00 00 00 	movl   $0x0,0xae0
 7a8:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ae:	8b 00                	mov    (%eax),%eax
 7b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	8b 40 04             	mov    0x4(%eax),%eax
 7b9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7bc:	72 4d                	jb     80b <malloc+0xa6>
      if(p->s.size == nunits)
 7be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c1:	8b 40 04             	mov    0x4(%eax),%eax
 7c4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c7:	75 0c                	jne    7d5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	8b 10                	mov    (%eax),%edx
 7ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d1:	89 10                	mov    %edx,(%eax)
 7d3:	eb 26                	jmp    7fb <malloc+0x96>
      else {
        p->s.size -= nunits;
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	8b 40 04             	mov    0x4(%eax),%eax
 7db:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7de:	89 c2                	mov    %eax,%edx
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e9:	8b 40 04             	mov    0x4(%eax),%eax
 7ec:	c1 e0 03             	shl    $0x3,%eax
 7ef:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fe:	a3 e4 0a 00 00       	mov    %eax,0xae4
      return (void*)(p + 1);
 803:	8b 45 f4             	mov    -0xc(%ebp),%eax
 806:	83 c0 08             	add    $0x8,%eax
 809:	eb 3b                	jmp    846 <malloc+0xe1>
    }
    if(p == freep)
 80b:	a1 e4 0a 00 00       	mov    0xae4,%eax
 810:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 813:	75 1e                	jne    833 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 815:	83 ec 0c             	sub    $0xc,%esp
 818:	ff 75 ec             	pushl  -0x14(%ebp)
 81b:	e8 e5 fe ff ff       	call   705 <morecore>
 820:	83 c4 10             	add    $0x10,%esp
 823:	89 45 f4             	mov    %eax,-0xc(%ebp)
 826:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82a:	75 07                	jne    833 <malloc+0xce>
        return 0;
 82c:	b8 00 00 00 00       	mov    $0x0,%eax
 831:	eb 13                	jmp    846 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 833:	8b 45 f4             	mov    -0xc(%ebp),%eax
 836:	89 45 f0             	mov    %eax,-0x10(%ebp)
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 841:	e9 6d ff ff ff       	jmp    7b3 <malloc+0x4e>
}
 846:	c9                   	leave  
 847:	c3                   	ret    
