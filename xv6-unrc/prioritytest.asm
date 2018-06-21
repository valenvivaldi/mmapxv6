
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
   9:	68 40 08 00 00       	push   $0x840
   e:	6a 01                	push   $0x1
  10:	e8 75 04 00 00       	call   48a <printf>
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

000003b3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b3:	55                   	push   %ebp
 3b4:	89 e5                	mov    %esp,%ebp
 3b6:	83 ec 18             	sub    $0x18,%esp
 3b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bc:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3bf:	83 ec 04             	sub    $0x4,%esp
 3c2:	6a 01                	push   $0x1
 3c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c7:	50                   	push   %eax
 3c8:	ff 75 08             	pushl  0x8(%ebp)
 3cb:	e8 2b ff ff ff       	call   2fb <write>
 3d0:	83 c4 10             	add    $0x10,%esp
}
 3d3:	90                   	nop
 3d4:	c9                   	leave  
 3d5:	c3                   	ret    

000003d6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d6:	55                   	push   %ebp
 3d7:	89 e5                	mov    %esp,%ebp
 3d9:	53                   	push   %ebx
 3da:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e8:	74 17                	je     401 <printint+0x2b>
 3ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ee:	79 11                	jns    401 <printint+0x2b>
    neg = 1;
 3f0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fa:	f7 d8                	neg    %eax
 3fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ff:	eb 06                	jmp    407 <printint+0x31>
  } else {
    x = xx;
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 407:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 40e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 411:	8d 41 01             	lea    0x1(%ecx),%eax
 414:	89 45 f4             	mov    %eax,-0xc(%ebp)
 417:	8b 5d 10             	mov    0x10(%ebp),%ebx
 41a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41d:	ba 00 00 00 00       	mov    $0x0,%edx
 422:	f7 f3                	div    %ebx
 424:	89 d0                	mov    %edx,%eax
 426:	0f b6 80 c0 0a 00 00 	movzbl 0xac0(%eax),%eax
 42d:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 431:	8b 5d 10             	mov    0x10(%ebp),%ebx
 434:	8b 45 ec             	mov    -0x14(%ebp),%eax
 437:	ba 00 00 00 00       	mov    $0x0,%edx
 43c:	f7 f3                	div    %ebx
 43e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 441:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 445:	75 c7                	jne    40e <printint+0x38>
  if(neg)
 447:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44b:	74 2d                	je     47a <printint+0xa4>
    buf[i++] = '-';
 44d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 450:	8d 50 01             	lea    0x1(%eax),%edx
 453:	89 55 f4             	mov    %edx,-0xc(%ebp)
 456:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 45b:	eb 1d                	jmp    47a <printint+0xa4>
    putc(fd, buf[i]);
 45d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 460:	8b 45 f4             	mov    -0xc(%ebp),%eax
 463:	01 d0                	add    %edx,%eax
 465:	0f b6 00             	movzbl (%eax),%eax
 468:	0f be c0             	movsbl %al,%eax
 46b:	83 ec 08             	sub    $0x8,%esp
 46e:	50                   	push   %eax
 46f:	ff 75 08             	pushl  0x8(%ebp)
 472:	e8 3c ff ff ff       	call   3b3 <putc>
 477:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 47a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 47e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 482:	79 d9                	jns    45d <printint+0x87>
    putc(fd, buf[i]);
}
 484:	90                   	nop
 485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 488:	c9                   	leave  
 489:	c3                   	ret    

0000048a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 48a:	55                   	push   %ebp
 48b:	89 e5                	mov    %esp,%ebp
 48d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 490:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 497:	8d 45 0c             	lea    0xc(%ebp),%eax
 49a:	83 c0 04             	add    $0x4,%eax
 49d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a7:	e9 59 01 00 00       	jmp    605 <printf+0x17b>
    c = fmt[i] & 0xff;
 4ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 4af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b2:	01 d0                	add    %edx,%eax
 4b4:	0f b6 00             	movzbl (%eax),%eax
 4b7:	0f be c0             	movsbl %al,%eax
 4ba:	25 ff 00 00 00       	and    $0xff,%eax
 4bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c6:	75 2c                	jne    4f4 <printf+0x6a>
      if(c == '%'){
 4c8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4cc:	75 0c                	jne    4da <printf+0x50>
        state = '%';
 4ce:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d5:	e9 27 01 00 00       	jmp    601 <printf+0x177>
      } else {
        putc(fd, c);
 4da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4dd:	0f be c0             	movsbl %al,%eax
 4e0:	83 ec 08             	sub    $0x8,%esp
 4e3:	50                   	push   %eax
 4e4:	ff 75 08             	pushl  0x8(%ebp)
 4e7:	e8 c7 fe ff ff       	call   3b3 <putc>
 4ec:	83 c4 10             	add    $0x10,%esp
 4ef:	e9 0d 01 00 00       	jmp    601 <printf+0x177>
      }
    } else if(state == '%'){
 4f4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f8:	0f 85 03 01 00 00    	jne    601 <printf+0x177>
      if(c == 'd'){
 4fe:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 502:	75 1e                	jne    522 <printf+0x98>
        printint(fd, *ap, 10, 1);
 504:	8b 45 e8             	mov    -0x18(%ebp),%eax
 507:	8b 00                	mov    (%eax),%eax
 509:	6a 01                	push   $0x1
 50b:	6a 0a                	push   $0xa
 50d:	50                   	push   %eax
 50e:	ff 75 08             	pushl  0x8(%ebp)
 511:	e8 c0 fe ff ff       	call   3d6 <printint>
 516:	83 c4 10             	add    $0x10,%esp
        ap++;
 519:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51d:	e9 d8 00 00 00       	jmp    5fa <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 522:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 526:	74 06                	je     52e <printf+0xa4>
 528:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 52c:	75 1e                	jne    54c <printf+0xc2>
        printint(fd, *ap, 16, 0);
 52e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 531:	8b 00                	mov    (%eax),%eax
 533:	6a 00                	push   $0x0
 535:	6a 10                	push   $0x10
 537:	50                   	push   %eax
 538:	ff 75 08             	pushl  0x8(%ebp)
 53b:	e8 96 fe ff ff       	call   3d6 <printint>
 540:	83 c4 10             	add    $0x10,%esp
        ap++;
 543:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 547:	e9 ae 00 00 00       	jmp    5fa <printf+0x170>
      } else if(c == 's'){
 54c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 550:	75 43                	jne    595 <printf+0x10b>
        s = (char*)*ap;
 552:	8b 45 e8             	mov    -0x18(%ebp),%eax
 555:	8b 00                	mov    (%eax),%eax
 557:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 55a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 55e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 562:	75 25                	jne    589 <printf+0xff>
          s = "(null)";
 564:	c7 45 f4 4e 08 00 00 	movl   $0x84e,-0xc(%ebp)
        while(*s != 0){
 56b:	eb 1c                	jmp    589 <printf+0xff>
          putc(fd, *s);
 56d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 570:	0f b6 00             	movzbl (%eax),%eax
 573:	0f be c0             	movsbl %al,%eax
 576:	83 ec 08             	sub    $0x8,%esp
 579:	50                   	push   %eax
 57a:	ff 75 08             	pushl  0x8(%ebp)
 57d:	e8 31 fe ff ff       	call   3b3 <putc>
 582:	83 c4 10             	add    $0x10,%esp
          s++;
 585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 589:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58c:	0f b6 00             	movzbl (%eax),%eax
 58f:	84 c0                	test   %al,%al
 591:	75 da                	jne    56d <printf+0xe3>
 593:	eb 65                	jmp    5fa <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 595:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 599:	75 1d                	jne    5b8 <printf+0x12e>
        putc(fd, *ap);
 59b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59e:	8b 00                	mov    (%eax),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	83 ec 08             	sub    $0x8,%esp
 5a6:	50                   	push   %eax
 5a7:	ff 75 08             	pushl  0x8(%ebp)
 5aa:	e8 04 fe ff ff       	call   3b3 <putc>
 5af:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b6:	eb 42                	jmp    5fa <printf+0x170>
      } else if(c == '%'){
 5b8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5bc:	75 17                	jne    5d5 <printf+0x14b>
        putc(fd, c);
 5be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	83 ec 08             	sub    $0x8,%esp
 5c7:	50                   	push   %eax
 5c8:	ff 75 08             	pushl  0x8(%ebp)
 5cb:	e8 e3 fd ff ff       	call   3b3 <putc>
 5d0:	83 c4 10             	add    $0x10,%esp
 5d3:	eb 25                	jmp    5fa <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d5:	83 ec 08             	sub    $0x8,%esp
 5d8:	6a 25                	push   $0x25
 5da:	ff 75 08             	pushl  0x8(%ebp)
 5dd:	e8 d1 fd ff ff       	call   3b3 <putc>
 5e2:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e8:	0f be c0             	movsbl %al,%eax
 5eb:	83 ec 08             	sub    $0x8,%esp
 5ee:	50                   	push   %eax
 5ef:	ff 75 08             	pushl  0x8(%ebp)
 5f2:	e8 bc fd ff ff       	call   3b3 <putc>
 5f7:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5fa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 601:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 605:	8b 55 0c             	mov    0xc(%ebp),%edx
 608:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60b:	01 d0                	add    %edx,%eax
 60d:	0f b6 00             	movzbl (%eax),%eax
 610:	84 c0                	test   %al,%al
 612:	0f 85 94 fe ff ff    	jne    4ac <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 618:	90                   	nop
 619:	c9                   	leave  
 61a:	c3                   	ret    

0000061b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 61b:	55                   	push   %ebp
 61c:	89 e5                	mov    %esp,%ebp
 61e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 621:	8b 45 08             	mov    0x8(%ebp),%eax
 624:	83 e8 08             	sub    $0x8,%eax
 627:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62a:	a1 dc 0a 00 00       	mov    0xadc,%eax
 62f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 632:	eb 24                	jmp    658 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 634:	8b 45 fc             	mov    -0x4(%ebp),%eax
 637:	8b 00                	mov    (%eax),%eax
 639:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63c:	77 12                	ja     650 <free+0x35>
 63e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 641:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 644:	77 24                	ja     66a <free+0x4f>
 646:	8b 45 fc             	mov    -0x4(%ebp),%eax
 649:	8b 00                	mov    (%eax),%eax
 64b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 64e:	77 1a                	ja     66a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 650:	8b 45 fc             	mov    -0x4(%ebp),%eax
 653:	8b 00                	mov    (%eax),%eax
 655:	89 45 fc             	mov    %eax,-0x4(%ebp)
 658:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65e:	76 d4                	jbe    634 <free+0x19>
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 668:	76 ca                	jbe    634 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 66a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66d:	8b 40 04             	mov    0x4(%eax),%eax
 670:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 677:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67a:	01 c2                	add    %eax,%edx
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67f:	8b 00                	mov    (%eax),%eax
 681:	39 c2                	cmp    %eax,%edx
 683:	75 24                	jne    6a9 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 685:	8b 45 f8             	mov    -0x8(%ebp),%eax
 688:	8b 50 04             	mov    0x4(%eax),%edx
 68b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68e:	8b 00                	mov    (%eax),%eax
 690:	8b 40 04             	mov    0x4(%eax),%eax
 693:	01 c2                	add    %eax,%edx
 695:	8b 45 f8             	mov    -0x8(%ebp),%eax
 698:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 69b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69e:	8b 00                	mov    (%eax),%eax
 6a0:	8b 10                	mov    (%eax),%edx
 6a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a5:	89 10                	mov    %edx,(%eax)
 6a7:	eb 0a                	jmp    6b3 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 10                	mov    (%eax),%edx
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b6:	8b 40 04             	mov    0x4(%eax),%eax
 6b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c3:	01 d0                	add    %edx,%eax
 6c5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c8:	75 20                	jne    6ea <free+0xcf>
    p->s.size += bp->s.size;
 6ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cd:	8b 50 04             	mov    0x4(%eax),%edx
 6d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d3:	8b 40 04             	mov    0x4(%eax),%eax
 6d6:	01 c2                	add    %eax,%edx
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e1:	8b 10                	mov    (%eax),%edx
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	89 10                	mov    %edx,(%eax)
 6e8:	eb 08                	jmp    6f2 <free+0xd7>
  } else
    p->s.ptr = bp;
 6ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ed:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6f0:	89 10                	mov    %edx,(%eax)
  freep = p;
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	a3 dc 0a 00 00       	mov    %eax,0xadc
}
 6fa:	90                   	nop
 6fb:	c9                   	leave  
 6fc:	c3                   	ret    

000006fd <morecore>:

static Header*
morecore(uint nu)
{
 6fd:	55                   	push   %ebp
 6fe:	89 e5                	mov    %esp,%ebp
 700:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 703:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 70a:	77 07                	ja     713 <morecore+0x16>
    nu = 4096;
 70c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 713:	8b 45 08             	mov    0x8(%ebp),%eax
 716:	c1 e0 03             	shl    $0x3,%eax
 719:	83 ec 0c             	sub    $0xc,%esp
 71c:	50                   	push   %eax
 71d:	e8 41 fc ff ff       	call   363 <sbrk>
 722:	83 c4 10             	add    $0x10,%esp
 725:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 728:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 72c:	75 07                	jne    735 <morecore+0x38>
    return 0;
 72e:	b8 00 00 00 00       	mov    $0x0,%eax
 733:	eb 26                	jmp    75b <morecore+0x5e>
  hp = (Header*)p;
 735:	8b 45 f4             	mov    -0xc(%ebp),%eax
 738:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73e:	8b 55 08             	mov    0x8(%ebp),%edx
 741:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 744:	8b 45 f0             	mov    -0x10(%ebp),%eax
 747:	83 c0 08             	add    $0x8,%eax
 74a:	83 ec 0c             	sub    $0xc,%esp
 74d:	50                   	push   %eax
 74e:	e8 c8 fe ff ff       	call   61b <free>
 753:	83 c4 10             	add    $0x10,%esp
  return freep;
 756:	a1 dc 0a 00 00       	mov    0xadc,%eax
}
 75b:	c9                   	leave  
 75c:	c3                   	ret    

0000075d <malloc>:

void*
malloc(uint nbytes)
{
 75d:	55                   	push   %ebp
 75e:	89 e5                	mov    %esp,%ebp
 760:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	83 c0 07             	add    $0x7,%eax
 769:	c1 e8 03             	shr    $0x3,%eax
 76c:	83 c0 01             	add    $0x1,%eax
 76f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 772:	a1 dc 0a 00 00       	mov    0xadc,%eax
 777:	89 45 f0             	mov    %eax,-0x10(%ebp)
 77a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 77e:	75 23                	jne    7a3 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 780:	c7 45 f0 d4 0a 00 00 	movl   $0xad4,-0x10(%ebp)
 787:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78a:	a3 dc 0a 00 00       	mov    %eax,0xadc
 78f:	a1 dc 0a 00 00       	mov    0xadc,%eax
 794:	a3 d4 0a 00 00       	mov    %eax,0xad4
    base.s.size = 0;
 799:	c7 05 d8 0a 00 00 00 	movl   $0x0,0xad8
 7a0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ae:	8b 40 04             	mov    0x4(%eax),%eax
 7b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7b4:	72 4d                	jb     803 <malloc+0xa6>
      if(p->s.size == nunits)
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	8b 40 04             	mov    0x4(%eax),%eax
 7bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7bf:	75 0c                	jne    7cd <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	8b 10                	mov    (%eax),%edx
 7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c9:	89 10                	mov    %edx,(%eax)
 7cb:	eb 26                	jmp    7f3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	8b 40 04             	mov    0x4(%eax),%eax
 7d3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7d6:	89 c2                	mov    %eax,%edx
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	8b 40 04             	mov    0x4(%eax),%eax
 7e4:	c1 e0 03             	shl    $0x3,%eax
 7e7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f6:	a3 dc 0a 00 00       	mov    %eax,0xadc
      return (void*)(p + 1);
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	83 c0 08             	add    $0x8,%eax
 801:	eb 3b                	jmp    83e <malloc+0xe1>
    }
    if(p == freep)
 803:	a1 dc 0a 00 00       	mov    0xadc,%eax
 808:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 80b:	75 1e                	jne    82b <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 80d:	83 ec 0c             	sub    $0xc,%esp
 810:	ff 75 ec             	pushl  -0x14(%ebp)
 813:	e8 e5 fe ff ff       	call   6fd <morecore>
 818:	83 c4 10             	add    $0x10,%esp
 81b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 81e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 822:	75 07                	jne    82b <malloc+0xce>
        return 0;
 824:	b8 00 00 00 00       	mov    $0x0,%eax
 829:	eb 13                	jmp    83e <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 831:	8b 45 f4             	mov    -0xc(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 839:	e9 6d ff ff ff       	jmp    7ab <malloc+0x4e>
}
 83e:	c9                   	leave  
 83f:	c3                   	ret    
