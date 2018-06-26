
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
   b:	68 eb 08 00 00       	push   $0x8eb
  10:	e8 a9 03 00 00       	call   3be <open>
  15:	83 c4 10             	add    $0x10,%esp
  18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  mmap(fd,&buff);
  1b:	83 ec 08             	sub    $0x8,%esp
  1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  21:	50                   	push   %eax
  22:	ff 75 f0             	pushl  -0x10(%ebp)
  25:	e8 24 04 00 00       	call   44e <mmap>
  2a:	83 c4 10             	add    $0x10,%esp
  for(i=0;i<600;i++){
  2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  34:	eb 25                	jmp    5b <mmaptest+0x5b>
    printf(1,"%c",buff[i] );
  36:	8b 55 ec             	mov    -0x14(%ebp),%edx
  39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3c:	01 d0                	add    %edx,%eax
  3e:	0f b6 00             	movzbl (%eax),%eax
  41:	0f be c0             	movsbl %al,%eax
  44:	83 ec 04             	sub    $0x4,%esp
  47:	50                   	push   %eax
  48:	68 f2 08 00 00       	push   $0x8f2
  4d:	6a 01                	push   $0x1
  4f:	e8 e1 04 00 00       	call   535 <printf>
  54:	83 c4 10             	add    $0x10,%esp
  int fd;
  int i;
  char* buff;
  fd=open("README",O_RDWR);
  mmap(fd,&buff);
  for(i=0;i<600;i++){
  57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5b:	81 7d f4 57 02 00 00 	cmpl   $0x257,-0xc(%ebp)
  62:	7e d2                	jle    36 <mmaptest+0x36>
    printf(1,"%c",buff[i] );
  }
  printf(1,"IMPRIMIO SIN MODIFICAR!!!!\n");
  64:	83 ec 08             	sub    $0x8,%esp
  67:	68 f5 08 00 00       	push   $0x8f5
  6c:	6a 01                	push   $0x1
  6e:	e8 c2 04 00 00       	call   535 <printf>
  73:	83 c4 10             	add    $0x10,%esp
  for(i=0;i<500;i++){
  76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  7d:	eb 0f                	jmp    8e <mmaptest+0x8e>
    buff[i]='X';
  7f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	01 d0                	add    %edx,%eax
  87:	c6 00 58             	movb   $0x58,(%eax)
  mmap(fd,&buff);
  for(i=0;i<600;i++){
    printf(1,"%c",buff[i] );
  }
  printf(1,"IMPRIMIO SIN MODIFICAR!!!!\n");
  for(i=0;i<500;i++){
  8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8e:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
  95:	7e e8                	jle    7f <mmaptest+0x7f>
    buff[i]='X';
  }

  for(i=0;i<510;i++){
  97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  9e:	eb 25                	jmp    c5 <mmaptest+0xc5>
    printf(1,"%c",buff[i] );
  a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a6:	01 d0                	add    %edx,%eax
  a8:	0f b6 00             	movzbl (%eax),%eax
  ab:	0f be c0             	movsbl %al,%eax
  ae:	83 ec 04             	sub    $0x4,%esp
  b1:	50                   	push   %eax
  b2:	68 f2 08 00 00       	push   $0x8f2
  b7:	6a 01                	push   $0x1
  b9:	e8 77 04 00 00       	call   535 <printf>
  be:	83 c4 10             	add    $0x10,%esp
  printf(1,"IMPRIMIO SIN MODIFICAR!!!!\n");
  for(i=0;i<500;i++){
    buff[i]='X';
  }

  for(i=0;i<510;i++){
  c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  c5:	81 7d f4 fd 01 00 00 	cmpl   $0x1fd,-0xc(%ebp)
  cc:	7e d2                	jle    a0 <mmaptest+0xa0>
    printf(1,"%c",buff[i] );
  }
  printf(1,"IMPRIMIO modificado!!!!!!!\n");
  ce:	83 ec 08             	sub    $0x8,%esp
  d1:	68 11 09 00 00       	push   $0x911
  d6:	6a 01                	push   $0x1
  d8:	e8 58 04 00 00       	call   535 <printf>
  dd:	83 c4 10             	add    $0x10,%esp
  munmap(buff);
  e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e3:	83 ec 0c             	sub    $0xc,%esp
  e6:	50                   	push   %eax
  e7:	e8 6a 03 00 00       	call   456 <munmap>
  ec:	83 c4 10             	add    $0x10,%esp
  printf(1, "mmaptest ok\n");
  ef:	83 ec 08             	sub    $0x8,%esp
  f2:	68 2d 09 00 00       	push   $0x92d
  f7:	6a 01                	push   $0x1
  f9:	e8 37 04 00 00       	call   535 <printf>
  fe:	83 c4 10             	add    $0x10,%esp
}
 101:	90                   	nop
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <main>:

int
main(void)
{
 104:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 108:	83 e4 f0             	and    $0xfffffff0,%esp
 10b:	ff 71 fc             	pushl  -0x4(%ecx)
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
 111:	51                   	push   %ecx
 112:	83 ec 04             	sub    $0x4,%esp
  mmaptest();
 115:	e8 e6 fe ff ff       	call   0 <mmaptest>
  exit();
 11a:	e8 57 02 00 00       	call   376 <exit>

0000011f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11f:	55                   	push   %ebp
 120:	89 e5                	mov    %esp,%ebp
 122:	57                   	push   %edi
 123:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 124:	8b 4d 08             	mov    0x8(%ebp),%ecx
 127:	8b 55 10             	mov    0x10(%ebp),%edx
 12a:	8b 45 0c             	mov    0xc(%ebp),%eax
 12d:	89 cb                	mov    %ecx,%ebx
 12f:	89 df                	mov    %ebx,%edi
 131:	89 d1                	mov    %edx,%ecx
 133:	fc                   	cld    
 134:	f3 aa                	rep stos %al,%es:(%edi)
 136:	89 ca                	mov    %ecx,%edx
 138:	89 fb                	mov    %edi,%ebx
 13a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 140:	90                   	nop
 141:	5b                   	pop    %ebx
 142:	5f                   	pop    %edi
 143:	5d                   	pop    %ebp
 144:	c3                   	ret    

00000145 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 151:	90                   	nop
 152:	8b 45 08             	mov    0x8(%ebp),%eax
 155:	8d 50 01             	lea    0x1(%eax),%edx
 158:	89 55 08             	mov    %edx,0x8(%ebp)
 15b:	8b 55 0c             	mov    0xc(%ebp),%edx
 15e:	8d 4a 01             	lea    0x1(%edx),%ecx
 161:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 164:	0f b6 12             	movzbl (%edx),%edx
 167:	88 10                	mov    %dl,(%eax)
 169:	0f b6 00             	movzbl (%eax),%eax
 16c:	84 c0                	test   %al,%al
 16e:	75 e2                	jne    152 <strcpy+0xd>
    ;
  return os;
 170:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 173:	c9                   	leave  
 174:	c3                   	ret    

00000175 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 178:	eb 08                	jmp    182 <strcmp+0xd>
    p++, q++;
 17a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 182:	8b 45 08             	mov    0x8(%ebp),%eax
 185:	0f b6 00             	movzbl (%eax),%eax
 188:	84 c0                	test   %al,%al
 18a:	74 10                	je     19c <strcmp+0x27>
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	0f b6 10             	movzbl (%eax),%edx
 192:	8b 45 0c             	mov    0xc(%ebp),%eax
 195:	0f b6 00             	movzbl (%eax),%eax
 198:	38 c2                	cmp    %al,%dl
 19a:	74 de                	je     17a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	0f b6 00             	movzbl (%eax),%eax
 1a2:	0f b6 d0             	movzbl %al,%edx
 1a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a8:	0f b6 00             	movzbl (%eax),%eax
 1ab:	0f b6 c0             	movzbl %al,%eax
 1ae:	29 c2                	sub    %eax,%edx
 1b0:	89 d0                	mov    %edx,%eax
}
 1b2:	5d                   	pop    %ebp
 1b3:	c3                   	ret    

000001b4 <strlen>:

uint
strlen(char *s)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c1:	eb 04                	jmp    1c7 <strlen+0x13>
 1c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	01 d0                	add    %edx,%eax
 1cf:	0f b6 00             	movzbl (%eax),%eax
 1d2:	84 c0                	test   %al,%al
 1d4:	75 ed                	jne    1c3 <strlen+0xf>
    ;
  return n;
 1d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d9:	c9                   	leave  
 1da:	c3                   	ret    

000001db <memset>:

void*
memset(void *dst, int c, uint n)
{
 1db:	55                   	push   %ebp
 1dc:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1de:	8b 45 10             	mov    0x10(%ebp),%eax
 1e1:	50                   	push   %eax
 1e2:	ff 75 0c             	pushl  0xc(%ebp)
 1e5:	ff 75 08             	pushl  0x8(%ebp)
 1e8:	e8 32 ff ff ff       	call   11f <stosb>
 1ed:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f3:	c9                   	leave  
 1f4:	c3                   	ret    

000001f5 <strchr>:

char*
strchr(const char *s, char c)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
 1f8:	83 ec 04             	sub    $0x4,%esp
 1fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fe:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 201:	eb 14                	jmp    217 <strchr+0x22>
    if(*s == c)
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	0f b6 00             	movzbl (%eax),%eax
 209:	3a 45 fc             	cmp    -0x4(%ebp),%al
 20c:	75 05                	jne    213 <strchr+0x1e>
      return (char*)s;
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	eb 13                	jmp    226 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 213:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	0f b6 00             	movzbl (%eax),%eax
 21d:	84 c0                	test   %al,%al
 21f:	75 e2                	jne    203 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 221:	b8 00 00 00 00       	mov    $0x0,%eax
}
 226:	c9                   	leave  
 227:	c3                   	ret    

00000228 <gets>:

char*
gets(char *buf, int max)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 235:	eb 42                	jmp    279 <gets+0x51>
    cc = read(0, &c, 1);
 237:	83 ec 04             	sub    $0x4,%esp
 23a:	6a 01                	push   $0x1
 23c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23f:	50                   	push   %eax
 240:	6a 00                	push   $0x0
 242:	e8 47 01 00 00       	call   38e <read>
 247:	83 c4 10             	add    $0x10,%esp
 24a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 251:	7e 33                	jle    286 <gets+0x5e>
      break;
    buf[i++] = c;
 253:	8b 45 f4             	mov    -0xc(%ebp),%eax
 256:	8d 50 01             	lea    0x1(%eax),%edx
 259:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25c:	89 c2                	mov    %eax,%edx
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	01 c2                	add    %eax,%edx
 263:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 267:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 269:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26d:	3c 0a                	cmp    $0xa,%al
 26f:	74 16                	je     287 <gets+0x5f>
 271:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 275:	3c 0d                	cmp    $0xd,%al
 277:	74 0e                	je     287 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 279:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27c:	83 c0 01             	add    $0x1,%eax
 27f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 282:	7c b3                	jl     237 <gets+0xf>
 284:	eb 01                	jmp    287 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 286:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <stat>:

int
stat(char *n, struct stat *st)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	6a 00                	push   $0x0
 2a2:	ff 75 08             	pushl  0x8(%ebp)
 2a5:	e8 14 01 00 00       	call   3be <open>
 2aa:	83 c4 10             	add    $0x10,%esp
 2ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b4:	79 07                	jns    2bd <stat+0x26>
    return -1;
 2b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bb:	eb 25                	jmp    2e2 <stat+0x4b>
  r = fstat(fd, st);
 2bd:	83 ec 08             	sub    $0x8,%esp
 2c0:	ff 75 0c             	pushl  0xc(%ebp)
 2c3:	ff 75 f4             	pushl  -0xc(%ebp)
 2c6:	e8 0b 01 00 00       	call   3d6 <fstat>
 2cb:	83 c4 10             	add    $0x10,%esp
 2ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d1:	83 ec 0c             	sub    $0xc,%esp
 2d4:	ff 75 f4             	pushl  -0xc(%ebp)
 2d7:	e8 ca 00 00 00       	call   3a6 <close>
 2dc:	83 c4 10             	add    $0x10,%esp
  return r;
 2df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e2:	c9                   	leave  
 2e3:	c3                   	ret    

000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f1:	eb 25                	jmp    318 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f6:	89 d0                	mov    %edx,%eax
 2f8:	c1 e0 02             	shl    $0x2,%eax
 2fb:	01 d0                	add    %edx,%eax
 2fd:	01 c0                	add    %eax,%eax
 2ff:	89 c1                	mov    %eax,%ecx
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	8d 50 01             	lea    0x1(%eax),%edx
 307:	89 55 08             	mov    %edx,0x8(%ebp)
 30a:	0f b6 00             	movzbl (%eax),%eax
 30d:	0f be c0             	movsbl %al,%eax
 310:	01 c8                	add    %ecx,%eax
 312:	83 e8 30             	sub    $0x30,%eax
 315:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	0f b6 00             	movzbl (%eax),%eax
 31e:	3c 2f                	cmp    $0x2f,%al
 320:	7e 0a                	jle    32c <atoi+0x48>
 322:	8b 45 08             	mov    0x8(%ebp),%eax
 325:	0f b6 00             	movzbl (%eax),%eax
 328:	3c 39                	cmp    $0x39,%al
 32a:	7e c7                	jle    2f3 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32f:	c9                   	leave  
 330:	c3                   	ret    

00000331 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33d:	8b 45 0c             	mov    0xc(%ebp),%eax
 340:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 343:	eb 17                	jmp    35c <memmove+0x2b>
    *dst++ = *src++;
 345:	8b 45 fc             	mov    -0x4(%ebp),%eax
 348:	8d 50 01             	lea    0x1(%eax),%edx
 34b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 351:	8d 4a 01             	lea    0x1(%edx),%ecx
 354:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 357:	0f b6 12             	movzbl (%edx),%edx
 35a:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35c:	8b 45 10             	mov    0x10(%ebp),%eax
 35f:	8d 50 ff             	lea    -0x1(%eax),%edx
 362:	89 55 10             	mov    %edx,0x10(%ebp)
 365:	85 c0                	test   %eax,%eax
 367:	7f dc                	jg     345 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 369:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36c:	c9                   	leave  
 36d:	c3                   	ret    

0000036e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36e:	b8 01 00 00 00       	mov    $0x1,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <exit>:
SYSCALL(exit)
 376:	b8 02 00 00 00       	mov    $0x2,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <wait>:
SYSCALL(wait)
 37e:	b8 03 00 00 00       	mov    $0x3,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <pipe>:
SYSCALL(pipe)
 386:	b8 04 00 00 00       	mov    $0x4,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <read>:
SYSCALL(read)
 38e:	b8 05 00 00 00       	mov    $0x5,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <seek>:
SYSCALL(seek)
 396:	b8 1c 00 00 00       	mov    $0x1c,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <write>:
SYSCALL(write)
 39e:	b8 10 00 00 00       	mov    $0x10,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <close>:
SYSCALL(close)
 3a6:	b8 15 00 00 00       	mov    $0x15,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <kill>:
SYSCALL(kill)
 3ae:	b8 06 00 00 00       	mov    $0x6,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <exec>:
SYSCALL(exec)
 3b6:	b8 07 00 00 00       	mov    $0x7,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <open>:
SYSCALL(open)
 3be:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <mknod>:
SYSCALL(mknod)
 3c6:	b8 11 00 00 00       	mov    $0x11,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <unlink>:
SYSCALL(unlink)
 3ce:	b8 12 00 00 00       	mov    $0x12,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <fstat>:
SYSCALL(fstat)
 3d6:	b8 08 00 00 00       	mov    $0x8,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <link>:
SYSCALL(link)
 3de:	b8 13 00 00 00       	mov    $0x13,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <mkdir>:
SYSCALL(mkdir)
 3e6:	b8 14 00 00 00       	mov    $0x14,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <chdir>:
SYSCALL(chdir)
 3ee:	b8 09 00 00 00       	mov    $0x9,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <dup>:
SYSCALL(dup)
 3f6:	b8 0a 00 00 00       	mov    $0xa,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret    

000003fe <getpid>:
SYSCALL(getpid)
 3fe:	b8 0b 00 00 00       	mov    $0xb,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret    

00000406 <sbrk>:
SYSCALL(sbrk)
 406:	b8 0c 00 00 00       	mov    $0xc,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret    

0000040e <sleep>:
SYSCALL(sleep)
 40e:	b8 0d 00 00 00       	mov    $0xd,%eax
 413:	cd 40                	int    $0x40
 415:	c3                   	ret    

00000416 <uptime>:
SYSCALL(uptime)
 416:	b8 0e 00 00 00       	mov    $0xe,%eax
 41b:	cd 40                	int    $0x40
 41d:	c3                   	ret    

0000041e <procstat>:
SYSCALL(procstat)
 41e:	b8 16 00 00 00       	mov    $0x16,%eax
 423:	cd 40                	int    $0x40
 425:	c3                   	ret    

00000426 <setpriority>:
SYSCALL(setpriority)
 426:	b8 17 00 00 00       	mov    $0x17,%eax
 42b:	cd 40                	int    $0x40
 42d:	c3                   	ret    

0000042e <semget>:
SYSCALL(semget)
 42e:	b8 18 00 00 00       	mov    $0x18,%eax
 433:	cd 40                	int    $0x40
 435:	c3                   	ret    

00000436 <semfree>:
SYSCALL(semfree)
 436:	b8 19 00 00 00       	mov    $0x19,%eax
 43b:	cd 40                	int    $0x40
 43d:	c3                   	ret    

0000043e <semdown>:
SYSCALL(semdown)
 43e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 443:	cd 40                	int    $0x40
 445:	c3                   	ret    

00000446 <semup>:
SYSCALL(semup)
 446:	b8 1b 00 00 00       	mov    $0x1b,%eax
 44b:	cd 40                	int    $0x40
 44d:	c3                   	ret    

0000044e <mmap>:
SYSCALL(mmap)
 44e:	b8 1d 00 00 00       	mov    $0x1d,%eax
 453:	cd 40                	int    $0x40
 455:	c3                   	ret    

00000456 <munmap>:
SYSCALL(munmap)
 456:	b8 1e 00 00 00       	mov    $0x1e,%eax
 45b:	cd 40                	int    $0x40
 45d:	c3                   	ret    

0000045e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 45e:	55                   	push   %ebp
 45f:	89 e5                	mov    %esp,%ebp
 461:	83 ec 18             	sub    $0x18,%esp
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 46a:	83 ec 04             	sub    $0x4,%esp
 46d:	6a 01                	push   $0x1
 46f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 472:	50                   	push   %eax
 473:	ff 75 08             	pushl  0x8(%ebp)
 476:	e8 23 ff ff ff       	call   39e <write>
 47b:	83 c4 10             	add    $0x10,%esp
}
 47e:	90                   	nop
 47f:	c9                   	leave  
 480:	c3                   	ret    

00000481 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 481:	55                   	push   %ebp
 482:	89 e5                	mov    %esp,%ebp
 484:	53                   	push   %ebx
 485:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 488:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 493:	74 17                	je     4ac <printint+0x2b>
 495:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 499:	79 11                	jns    4ac <printint+0x2b>
    neg = 1;
 49b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	f7 d8                	neg    %eax
 4a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4aa:	eb 06                	jmp    4b2 <printint+0x31>
  } else {
    x = xx;
 4ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 4af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4bc:	8d 41 01             	lea    0x1(%ecx),%eax
 4bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c8:	ba 00 00 00 00       	mov    $0x0,%edx
 4cd:	f7 f3                	div    %ebx
 4cf:	89 d0                	mov    %edx,%eax
 4d1:	0f b6 80 ac 0b 00 00 	movzbl 0xbac(%eax),%eax
 4d8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e2:	ba 00 00 00 00       	mov    $0x0,%edx
 4e7:	f7 f3                	div    %ebx
 4e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f0:	75 c7                	jne    4b9 <printint+0x38>
  if(neg)
 4f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f6:	74 2d                	je     525 <printint+0xa4>
    buf[i++] = '-';
 4f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fb:	8d 50 01             	lea    0x1(%eax),%edx
 4fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
 501:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 506:	eb 1d                	jmp    525 <printint+0xa4>
    putc(fd, buf[i]);
 508:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50e:	01 d0                	add    %edx,%eax
 510:	0f b6 00             	movzbl (%eax),%eax
 513:	0f be c0             	movsbl %al,%eax
 516:	83 ec 08             	sub    $0x8,%esp
 519:	50                   	push   %eax
 51a:	ff 75 08             	pushl  0x8(%ebp)
 51d:	e8 3c ff ff ff       	call   45e <putc>
 522:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 525:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 529:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52d:	79 d9                	jns    508 <printint+0x87>
    putc(fd, buf[i]);
}
 52f:	90                   	nop
 530:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 533:	c9                   	leave  
 534:	c3                   	ret    

00000535 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 535:	55                   	push   %ebp
 536:	89 e5                	mov    %esp,%ebp
 538:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 542:	8d 45 0c             	lea    0xc(%ebp),%eax
 545:	83 c0 04             	add    $0x4,%eax
 548:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 552:	e9 59 01 00 00       	jmp    6b0 <printf+0x17b>
    c = fmt[i] & 0xff;
 557:	8b 55 0c             	mov    0xc(%ebp),%edx
 55a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 55d:	01 d0                	add    %edx,%eax
 55f:	0f b6 00             	movzbl (%eax),%eax
 562:	0f be c0             	movsbl %al,%eax
 565:	25 ff 00 00 00       	and    $0xff,%eax
 56a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 56d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 571:	75 2c                	jne    59f <printf+0x6a>
      if(c == '%'){
 573:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 577:	75 0c                	jne    585 <printf+0x50>
        state = '%';
 579:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 580:	e9 27 01 00 00       	jmp    6ac <printf+0x177>
      } else {
        putc(fd, c);
 585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 588:	0f be c0             	movsbl %al,%eax
 58b:	83 ec 08             	sub    $0x8,%esp
 58e:	50                   	push   %eax
 58f:	ff 75 08             	pushl  0x8(%ebp)
 592:	e8 c7 fe ff ff       	call   45e <putc>
 597:	83 c4 10             	add    $0x10,%esp
 59a:	e9 0d 01 00 00       	jmp    6ac <printf+0x177>
      }
    } else if(state == '%'){
 59f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a3:	0f 85 03 01 00 00    	jne    6ac <printf+0x177>
      if(c == 'd'){
 5a9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5ad:	75 1e                	jne    5cd <printf+0x98>
        printint(fd, *ap, 10, 1);
 5af:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b2:	8b 00                	mov    (%eax),%eax
 5b4:	6a 01                	push   $0x1
 5b6:	6a 0a                	push   $0xa
 5b8:	50                   	push   %eax
 5b9:	ff 75 08             	pushl  0x8(%ebp)
 5bc:	e8 c0 fe ff ff       	call   481 <printint>
 5c1:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c8:	e9 d8 00 00 00       	jmp    6a5 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5cd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d1:	74 06                	je     5d9 <printf+0xa4>
 5d3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d7:	75 1e                	jne    5f7 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dc:	8b 00                	mov    (%eax),%eax
 5de:	6a 00                	push   $0x0
 5e0:	6a 10                	push   $0x10
 5e2:	50                   	push   %eax
 5e3:	ff 75 08             	pushl  0x8(%ebp)
 5e6:	e8 96 fe ff ff       	call   481 <printint>
 5eb:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f2:	e9 ae 00 00 00       	jmp    6a5 <printf+0x170>
      } else if(c == 's'){
 5f7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5fb:	75 43                	jne    640 <printf+0x10b>
        s = (char*)*ap;
 5fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 605:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 609:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 60d:	75 25                	jne    634 <printf+0xff>
          s = "(null)";
 60f:	c7 45 f4 3a 09 00 00 	movl   $0x93a,-0xc(%ebp)
        while(*s != 0){
 616:	eb 1c                	jmp    634 <printf+0xff>
          putc(fd, *s);
 618:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61b:	0f b6 00             	movzbl (%eax),%eax
 61e:	0f be c0             	movsbl %al,%eax
 621:	83 ec 08             	sub    $0x8,%esp
 624:	50                   	push   %eax
 625:	ff 75 08             	pushl  0x8(%ebp)
 628:	e8 31 fe ff ff       	call   45e <putc>
 62d:	83 c4 10             	add    $0x10,%esp
          s++;
 630:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 634:	8b 45 f4             	mov    -0xc(%ebp),%eax
 637:	0f b6 00             	movzbl (%eax),%eax
 63a:	84 c0                	test   %al,%al
 63c:	75 da                	jne    618 <printf+0xe3>
 63e:	eb 65                	jmp    6a5 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 640:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 644:	75 1d                	jne    663 <printf+0x12e>
        putc(fd, *ap);
 646:	8b 45 e8             	mov    -0x18(%ebp),%eax
 649:	8b 00                	mov    (%eax),%eax
 64b:	0f be c0             	movsbl %al,%eax
 64e:	83 ec 08             	sub    $0x8,%esp
 651:	50                   	push   %eax
 652:	ff 75 08             	pushl  0x8(%ebp)
 655:	e8 04 fe ff ff       	call   45e <putc>
 65a:	83 c4 10             	add    $0x10,%esp
        ap++;
 65d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 661:	eb 42                	jmp    6a5 <printf+0x170>
      } else if(c == '%'){
 663:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 667:	75 17                	jne    680 <printf+0x14b>
        putc(fd, c);
 669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66c:	0f be c0             	movsbl %al,%eax
 66f:	83 ec 08             	sub    $0x8,%esp
 672:	50                   	push   %eax
 673:	ff 75 08             	pushl  0x8(%ebp)
 676:	e8 e3 fd ff ff       	call   45e <putc>
 67b:	83 c4 10             	add    $0x10,%esp
 67e:	eb 25                	jmp    6a5 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 680:	83 ec 08             	sub    $0x8,%esp
 683:	6a 25                	push   $0x25
 685:	ff 75 08             	pushl  0x8(%ebp)
 688:	e8 d1 fd ff ff       	call   45e <putc>
 68d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 690:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 693:	0f be c0             	movsbl %al,%eax
 696:	83 ec 08             	sub    $0x8,%esp
 699:	50                   	push   %eax
 69a:	ff 75 08             	pushl  0x8(%ebp)
 69d:	e8 bc fd ff ff       	call   45e <putc>
 6a2:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6a5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6ac:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6b0:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b6:	01 d0                	add    %edx,%eax
 6b8:	0f b6 00             	movzbl (%eax),%eax
 6bb:	84 c0                	test   %al,%al
 6bd:	0f 85 94 fe ff ff    	jne    557 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6c3:	90                   	nop
 6c4:	c9                   	leave  
 6c5:	c3                   	ret    

000006c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c6:	55                   	push   %ebp
 6c7:	89 e5                	mov    %esp,%ebp
 6c9:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6cc:	8b 45 08             	mov    0x8(%ebp),%eax
 6cf:	83 e8 08             	sub    $0x8,%eax
 6d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d5:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 6da:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6dd:	eb 24                	jmp    703 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e7:	77 12                	ja     6fb <free+0x35>
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ef:	77 24                	ja     715 <free+0x4f>
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f9:	77 1a                	ja     715 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fe:	8b 00                	mov    (%eax),%eax
 700:	89 45 fc             	mov    %eax,-0x4(%ebp)
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 709:	76 d4                	jbe    6df <free+0x19>
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	8b 00                	mov    (%eax),%eax
 710:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 713:	76 ca                	jbe    6df <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 715:	8b 45 f8             	mov    -0x8(%ebp),%eax
 718:	8b 40 04             	mov    0x4(%eax),%eax
 71b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	01 c2                	add    %eax,%edx
 727:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72a:	8b 00                	mov    (%eax),%eax
 72c:	39 c2                	cmp    %eax,%edx
 72e:	75 24                	jne    754 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 730:	8b 45 f8             	mov    -0x8(%ebp),%eax
 733:	8b 50 04             	mov    0x4(%eax),%edx
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 00                	mov    (%eax),%eax
 73b:	8b 40 04             	mov    0x4(%eax),%eax
 73e:	01 c2                	add    %eax,%edx
 740:	8b 45 f8             	mov    -0x8(%ebp),%eax
 743:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	8b 00                	mov    (%eax),%eax
 74b:	8b 10                	mov    (%eax),%edx
 74d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 750:	89 10                	mov    %edx,(%eax)
 752:	eb 0a                	jmp    75e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 754:	8b 45 fc             	mov    -0x4(%ebp),%eax
 757:	8b 10                	mov    (%eax),%edx
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 75e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 761:	8b 40 04             	mov    0x4(%eax),%eax
 764:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	01 d0                	add    %edx,%eax
 770:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 773:	75 20                	jne    795 <free+0xcf>
    p->s.size += bp->s.size;
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 50 04             	mov    0x4(%eax),%edx
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	8b 40 04             	mov    0x4(%eax),%eax
 781:	01 c2                	add    %eax,%edx
 783:	8b 45 fc             	mov    -0x4(%ebp),%eax
 786:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 789:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78c:	8b 10                	mov    (%eax),%edx
 78e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 791:	89 10                	mov    %edx,(%eax)
 793:	eb 08                	jmp    79d <free+0xd7>
  } else
    p->s.ptr = bp;
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 55 f8             	mov    -0x8(%ebp),%edx
 79b:	89 10                	mov    %edx,(%eax)
  freep = p;
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	a3 c8 0b 00 00       	mov    %eax,0xbc8
}
 7a5:	90                   	nop
 7a6:	c9                   	leave  
 7a7:	c3                   	ret    

000007a8 <morecore>:

static Header*
morecore(uint nu)
{
 7a8:	55                   	push   %ebp
 7a9:	89 e5                	mov    %esp,%ebp
 7ab:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7ae:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7b5:	77 07                	ja     7be <morecore+0x16>
    nu = 4096;
 7b7:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7be:	8b 45 08             	mov    0x8(%ebp),%eax
 7c1:	c1 e0 03             	shl    $0x3,%eax
 7c4:	83 ec 0c             	sub    $0xc,%esp
 7c7:	50                   	push   %eax
 7c8:	e8 39 fc ff ff       	call   406 <sbrk>
 7cd:	83 c4 10             	add    $0x10,%esp
 7d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7d3:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7d7:	75 07                	jne    7e0 <morecore+0x38>
    return 0;
 7d9:	b8 00 00 00 00       	mov    $0x0,%eax
 7de:	eb 26                	jmp    806 <morecore+0x5e>
  hp = (Header*)p;
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	8b 55 08             	mov    0x8(%ebp),%edx
 7ec:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f2:	83 c0 08             	add    $0x8,%eax
 7f5:	83 ec 0c             	sub    $0xc,%esp
 7f8:	50                   	push   %eax
 7f9:	e8 c8 fe ff ff       	call   6c6 <free>
 7fe:	83 c4 10             	add    $0x10,%esp
  return freep;
 801:	a1 c8 0b 00 00       	mov    0xbc8,%eax
}
 806:	c9                   	leave  
 807:	c3                   	ret    

00000808 <malloc>:

void*
malloc(uint nbytes)
{
 808:	55                   	push   %ebp
 809:	89 e5                	mov    %esp,%ebp
 80b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80e:	8b 45 08             	mov    0x8(%ebp),%eax
 811:	83 c0 07             	add    $0x7,%eax
 814:	c1 e8 03             	shr    $0x3,%eax
 817:	83 c0 01             	add    $0x1,%eax
 81a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 81d:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 822:	89 45 f0             	mov    %eax,-0x10(%ebp)
 825:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 829:	75 23                	jne    84e <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 82b:	c7 45 f0 c0 0b 00 00 	movl   $0xbc0,-0x10(%ebp)
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	a3 c8 0b 00 00       	mov    %eax,0xbc8
 83a:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 83f:	a3 c0 0b 00 00       	mov    %eax,0xbc0
    base.s.size = 0;
 844:	c7 05 c4 0b 00 00 00 	movl   $0x0,0xbc4
 84b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 851:	8b 00                	mov    (%eax),%eax
 853:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	8b 40 04             	mov    0x4(%eax),%eax
 85c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85f:	72 4d                	jb     8ae <malloc+0xa6>
      if(p->s.size == nunits)
 861:	8b 45 f4             	mov    -0xc(%ebp),%eax
 864:	8b 40 04             	mov    0x4(%eax),%eax
 867:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86a:	75 0c                	jne    878 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 10                	mov    (%eax),%edx
 871:	8b 45 f0             	mov    -0x10(%ebp),%eax
 874:	89 10                	mov    %edx,(%eax)
 876:	eb 26                	jmp    89e <malloc+0x96>
      else {
        p->s.size -= nunits;
 878:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87b:	8b 40 04             	mov    0x4(%eax),%eax
 87e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 881:	89 c2                	mov    %eax,%edx
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	8b 40 04             	mov    0x4(%eax),%eax
 88f:	c1 e0 03             	shl    $0x3,%eax
 892:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 895:	8b 45 f4             	mov    -0xc(%ebp),%eax
 898:	8b 55 ec             	mov    -0x14(%ebp),%edx
 89b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 89e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a1:	a3 c8 0b 00 00       	mov    %eax,0xbc8
      return (void*)(p + 1);
 8a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a9:	83 c0 08             	add    $0x8,%eax
 8ac:	eb 3b                	jmp    8e9 <malloc+0xe1>
    }
    if(p == freep)
 8ae:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 8b3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8b6:	75 1e                	jne    8d6 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8b8:	83 ec 0c             	sub    $0xc,%esp
 8bb:	ff 75 ec             	pushl  -0x14(%ebp)
 8be:	e8 e5 fe ff ff       	call   7a8 <morecore>
 8c3:	83 c4 10             	add    $0x10,%esp
 8c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8cd:	75 07                	jne    8d6 <malloc+0xce>
        return 0;
 8cf:	b8 00 00 00 00       	mov    $0x0,%eax
 8d4:	eb 13                	jmp    8e9 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8df:	8b 00                	mov    (%eax),%eax
 8e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8e4:	e9 6d ff ff ff       	jmp    856 <malloc+0x4e>
}
 8e9:	c9                   	leave  
 8ea:	c3                   	ret    
