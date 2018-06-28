
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
  fd=open("README",O_RDONLY);
   6:	83 ec 08             	sub    $0x8,%esp
   9:	6a 00                	push   $0x0
   b:	68 dc 08 00 00       	push   $0x8dc
  10:	e8 9a 03 00 00       	call   3af <open>
  15:	83 c4 10             	add    $0x10,%esp
  18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  mmap(fd,&buff);
  1b:	83 ec 08             	sub    $0x8,%esp
  1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  21:	50                   	push   %eax
  22:	ff 75 f0             	pushl  -0x10(%ebp)
  25:	e8 15 04 00 00       	call   43f <mmap>
  2a:	83 c4 10             	add    $0x10,%esp
  printf(1,"IMPRIMIO SIN MODIFICAR!!!!\n");
  2d:	83 ec 08             	sub    $0x8,%esp
  30:	68 e3 08 00 00       	push   $0x8e3
  35:	6a 01                	push   $0x1
  37:	e8 ea 04 00 00       	call   526 <printf>
  3c:	83 c4 10             	add    $0x10,%esp
  for(i=0;i<600;i++){
  3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  46:	eb 25                	jmp    6d <mmaptest+0x6d>
    printf(1,"%c",buff[i] );
  48:	8b 55 ec             	mov    -0x14(%ebp),%edx
  4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4e:	01 d0                	add    %edx,%eax
  50:	0f b6 00             	movzbl (%eax),%eax
  53:	0f be c0             	movsbl %al,%eax
  56:	83 ec 04             	sub    $0x4,%esp
  59:	50                   	push   %eax
  5a:	68 ff 08 00 00       	push   $0x8ff
  5f:	6a 01                	push   $0x1
  61:	e8 c0 04 00 00       	call   526 <printf>
  66:	83 c4 10             	add    $0x10,%esp
  int i;
  char* buff;
  fd=open("README",O_RDONLY);
  mmap(fd,&buff);
  printf(1,"IMPRIMIO SIN MODIFICAR!!!!\n");
  for(i=0;i<600;i++){
  69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  6d:	81 7d f4 57 02 00 00 	cmpl   $0x257,-0xc(%ebp)
  74:	7e d2                	jle    48 <mmaptest+0x48>
    printf(1,"%c",buff[i] );
  }
  for(i=0;i<500;i++){
  76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  7d:	eb 0f                	jmp    8e <mmaptest+0x8e>
    buff[i]='X';
  7f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	01 d0                	add    %edx,%eax
  87:	c6 00 58             	movb   $0x58,(%eax)
  mmap(fd,&buff);
  printf(1,"IMPRIMIO SIN MODIFICAR!!!!\n");
  for(i=0;i<600;i++){
    printf(1,"%c",buff[i] );
  }
  for(i=0;i<500;i++){
  8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8e:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
  95:	7e e8                	jle    7f <mmaptest+0x7f>
    buff[i]='X';
  }

  printf(1,"IMPRIMIO modificado!!!!!!!\n");
  97:	83 ec 08             	sub    $0x8,%esp
  9a:	68 02 09 00 00       	push   $0x902
  9f:	6a 01                	push   $0x1
  a1:	e8 80 04 00 00       	call   526 <printf>
  a6:	83 c4 10             	add    $0x10,%esp
  for(i=0;i<600;i++){
  a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  b0:	eb 25                	jmp    d7 <mmaptest+0xd7>
    printf(1,"%c",buff[i] );
  b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b8:	01 d0                	add    %edx,%eax
  ba:	0f b6 00             	movzbl (%eax),%eax
  bd:	0f be c0             	movsbl %al,%eax
  c0:	83 ec 04             	sub    $0x4,%esp
  c3:	50                   	push   %eax
  c4:	68 ff 08 00 00       	push   $0x8ff
  c9:	6a 01                	push   $0x1
  cb:	e8 56 04 00 00       	call   526 <printf>
  d0:	83 c4 10             	add    $0x10,%esp
  for(i=0;i<500;i++){
    buff[i]='X';
  }

  printf(1,"IMPRIMIO modificado!!!!!!!\n");
  for(i=0;i<600;i++){
  d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  d7:	81 7d f4 57 02 00 00 	cmpl   $0x257,-0xc(%ebp)
  de:	7e d2                	jle    b2 <mmaptest+0xb2>
    printf(1,"%c",buff[i] );
  }
  //munmap(buff);
  printf(1, "mmaptest ok\n");
  e0:	83 ec 08             	sub    $0x8,%esp
  e3:	68 1e 09 00 00       	push   $0x91e
  e8:	6a 01                	push   $0x1
  ea:	e8 37 04 00 00       	call   526 <printf>
  ef:	83 c4 10             	add    $0x10,%esp
}
  f2:	90                   	nop
  f3:	c9                   	leave  
  f4:	c3                   	ret    

000000f5 <main>:

int
main(void)
{
  f5:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  f9:	83 e4 f0             	and    $0xfffffff0,%esp
  fc:	ff 71 fc             	pushl  -0x4(%ecx)
  ff:	55                   	push   %ebp
 100:	89 e5                	mov    %esp,%ebp
 102:	51                   	push   %ecx
 103:	83 ec 04             	sub    $0x4,%esp
  mmaptest();
 106:	e8 f5 fe ff ff       	call   0 <mmaptest>
  exit();
 10b:	e8 57 02 00 00       	call   367 <exit>

00000110 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	57                   	push   %edi
 114:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 115:	8b 4d 08             	mov    0x8(%ebp),%ecx
 118:	8b 55 10             	mov    0x10(%ebp),%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	89 cb                	mov    %ecx,%ebx
 120:	89 df                	mov    %ebx,%edi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%edi)
 127:	89 ca                	mov    %ecx,%edx
 129:	89 fb                	mov    %edi,%ebx
 12b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 131:	90                   	nop
 132:	5b                   	pop    %ebx
 133:	5f                   	pop    %edi
 134:	5d                   	pop    %ebp
 135:	c3                   	ret    

00000136 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 136:	55                   	push   %ebp
 137:	89 e5                	mov    %esp,%ebp
 139:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 142:	90                   	nop
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	8d 50 01             	lea    0x1(%eax),%edx
 149:	89 55 08             	mov    %edx,0x8(%ebp)
 14c:	8b 55 0c             	mov    0xc(%ebp),%edx
 14f:	8d 4a 01             	lea    0x1(%edx),%ecx
 152:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 155:	0f b6 12             	movzbl (%edx),%edx
 158:	88 10                	mov    %dl,(%eax)
 15a:	0f b6 00             	movzbl (%eax),%eax
 15d:	84 c0                	test   %al,%al
 15f:	75 e2                	jne    143 <strcpy+0xd>
    ;
  return os;
 161:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 164:	c9                   	leave  
 165:	c3                   	ret    

00000166 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 166:	55                   	push   %ebp
 167:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 169:	eb 08                	jmp    173 <strcmp+0xd>
    p++, q++;
 16b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	0f b6 00             	movzbl (%eax),%eax
 179:	84 c0                	test   %al,%al
 17b:	74 10                	je     18d <strcmp+0x27>
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	0f b6 10             	movzbl (%eax),%edx
 183:	8b 45 0c             	mov    0xc(%ebp),%eax
 186:	0f b6 00             	movzbl (%eax),%eax
 189:	38 c2                	cmp    %al,%dl
 18b:	74 de                	je     16b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	0f b6 00             	movzbl (%eax),%eax
 193:	0f b6 d0             	movzbl %al,%edx
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	0f b6 00             	movzbl (%eax),%eax
 19c:	0f b6 c0             	movzbl %al,%eax
 19f:	29 c2                	sub    %eax,%edx
 1a1:	89 d0                	mov    %edx,%eax
}
 1a3:	5d                   	pop    %ebp
 1a4:	c3                   	ret    

000001a5 <strlen>:

uint
strlen(char *s)
{
 1a5:	55                   	push   %ebp
 1a6:	89 e5                	mov    %esp,%ebp
 1a8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b2:	eb 04                	jmp    1b8 <strlen+0x13>
 1b4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1bb:	8b 45 08             	mov    0x8(%ebp),%eax
 1be:	01 d0                	add    %edx,%eax
 1c0:	0f b6 00             	movzbl (%eax),%eax
 1c3:	84 c0                	test   %al,%al
 1c5:	75 ed                	jne    1b4 <strlen+0xf>
    ;
  return n;
 1c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ca:	c9                   	leave  
 1cb:	c3                   	ret    

000001cc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1cf:	8b 45 10             	mov    0x10(%ebp),%eax
 1d2:	50                   	push   %eax
 1d3:	ff 75 0c             	pushl  0xc(%ebp)
 1d6:	ff 75 08             	pushl  0x8(%ebp)
 1d9:	e8 32 ff ff ff       	call   110 <stosb>
 1de:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e4:	c9                   	leave  
 1e5:	c3                   	ret    

000001e6 <strchr>:

char*
strchr(const char *s, char c)
{
 1e6:	55                   	push   %ebp
 1e7:	89 e5                	mov    %esp,%ebp
 1e9:	83 ec 04             	sub    $0x4,%esp
 1ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ef:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f2:	eb 14                	jmp    208 <strchr+0x22>
    if(*s == c)
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	0f b6 00             	movzbl (%eax),%eax
 1fa:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1fd:	75 05                	jne    204 <strchr+0x1e>
      return (char*)s;
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	eb 13                	jmp    217 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 204:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	0f b6 00             	movzbl (%eax),%eax
 20e:	84 c0                	test   %al,%al
 210:	75 e2                	jne    1f4 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 212:	b8 00 00 00 00       	mov    $0x0,%eax
}
 217:	c9                   	leave  
 218:	c3                   	ret    

00000219 <gets>:

char*
gets(char *buf, int max)
{
 219:	55                   	push   %ebp
 21a:	89 e5                	mov    %esp,%ebp
 21c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 226:	eb 42                	jmp    26a <gets+0x51>
    cc = read(0, &c, 1);
 228:	83 ec 04             	sub    $0x4,%esp
 22b:	6a 01                	push   $0x1
 22d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 230:	50                   	push   %eax
 231:	6a 00                	push   $0x0
 233:	e8 47 01 00 00       	call   37f <read>
 238:	83 c4 10             	add    $0x10,%esp
 23b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 23e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 242:	7e 33                	jle    277 <gets+0x5e>
      break;
    buf[i++] = c;
 244:	8b 45 f4             	mov    -0xc(%ebp),%eax
 247:	8d 50 01             	lea    0x1(%eax),%edx
 24a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 24d:	89 c2                	mov    %eax,%edx
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	01 c2                	add    %eax,%edx
 254:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 258:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 25a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25e:	3c 0a                	cmp    $0xa,%al
 260:	74 16                	je     278 <gets+0x5f>
 262:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 266:	3c 0d                	cmp    $0xd,%al
 268:	74 0e                	je     278 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26d:	83 c0 01             	add    $0x1,%eax
 270:	3b 45 0c             	cmp    0xc(%ebp),%eax
 273:	7c b3                	jl     228 <gets+0xf>
 275:	eb 01                	jmp    278 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 277:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 278:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	01 d0                	add    %edx,%eax
 280:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 283:	8b 45 08             	mov    0x8(%ebp),%eax
}
 286:	c9                   	leave  
 287:	c3                   	ret    

00000288 <stat>:

int
stat(char *n, struct stat *st)
{
 288:	55                   	push   %ebp
 289:	89 e5                	mov    %esp,%ebp
 28b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28e:	83 ec 08             	sub    $0x8,%esp
 291:	6a 00                	push   $0x0
 293:	ff 75 08             	pushl  0x8(%ebp)
 296:	e8 14 01 00 00       	call   3af <open>
 29b:	83 c4 10             	add    $0x10,%esp
 29e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a5:	79 07                	jns    2ae <stat+0x26>
    return -1;
 2a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ac:	eb 25                	jmp    2d3 <stat+0x4b>
  r = fstat(fd, st);
 2ae:	83 ec 08             	sub    $0x8,%esp
 2b1:	ff 75 0c             	pushl  0xc(%ebp)
 2b4:	ff 75 f4             	pushl  -0xc(%ebp)
 2b7:	e8 0b 01 00 00       	call   3c7 <fstat>
 2bc:	83 c4 10             	add    $0x10,%esp
 2bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c2:	83 ec 0c             	sub    $0xc,%esp
 2c5:	ff 75 f4             	pushl  -0xc(%ebp)
 2c8:	e8 ca 00 00 00       	call   397 <close>
 2cd:	83 c4 10             	add    $0x10,%esp
  return r;
 2d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d3:	c9                   	leave  
 2d4:	c3                   	ret    

000002d5 <atoi>:

int
atoi(const char *s)
{
 2d5:	55                   	push   %ebp
 2d6:	89 e5                	mov    %esp,%ebp
 2d8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2db:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e2:	eb 25                	jmp    309 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e7:	89 d0                	mov    %edx,%eax
 2e9:	c1 e0 02             	shl    $0x2,%eax
 2ec:	01 d0                	add    %edx,%eax
 2ee:	01 c0                	add    %eax,%eax
 2f0:	89 c1                	mov    %eax,%ecx
 2f2:	8b 45 08             	mov    0x8(%ebp),%eax
 2f5:	8d 50 01             	lea    0x1(%eax),%edx
 2f8:	89 55 08             	mov    %edx,0x8(%ebp)
 2fb:	0f b6 00             	movzbl (%eax),%eax
 2fe:	0f be c0             	movsbl %al,%eax
 301:	01 c8                	add    %ecx,%eax
 303:	83 e8 30             	sub    $0x30,%eax
 306:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	3c 2f                	cmp    $0x2f,%al
 311:	7e 0a                	jle    31d <atoi+0x48>
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	0f b6 00             	movzbl (%eax),%eax
 319:	3c 39                	cmp    $0x39,%al
 31b:	7e c7                	jle    2e4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 31d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 320:	c9                   	leave  
 321:	c3                   	ret    

00000322 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 322:	55                   	push   %ebp
 323:	89 e5                	mov    %esp,%ebp
 325:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 334:	eb 17                	jmp    34d <memmove+0x2b>
    *dst++ = *src++;
 336:	8b 45 fc             	mov    -0x4(%ebp),%eax
 339:	8d 50 01             	lea    0x1(%eax),%edx
 33c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 33f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 342:	8d 4a 01             	lea    0x1(%edx),%ecx
 345:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 348:	0f b6 12             	movzbl (%edx),%edx
 34b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 34d:	8b 45 10             	mov    0x10(%ebp),%eax
 350:	8d 50 ff             	lea    -0x1(%eax),%edx
 353:	89 55 10             	mov    %edx,0x10(%ebp)
 356:	85 c0                	test   %eax,%eax
 358:	7f dc                	jg     336 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35d:	c9                   	leave  
 35e:	c3                   	ret    

0000035f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 35f:	b8 01 00 00 00       	mov    $0x1,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <exit>:
SYSCALL(exit)
 367:	b8 02 00 00 00       	mov    $0x2,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <wait>:
SYSCALL(wait)
 36f:	b8 03 00 00 00       	mov    $0x3,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <pipe>:
SYSCALL(pipe)
 377:	b8 04 00 00 00       	mov    $0x4,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <read>:
SYSCALL(read)
 37f:	b8 05 00 00 00       	mov    $0x5,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <seek>:
SYSCALL(seek)
 387:	b8 1c 00 00 00       	mov    $0x1c,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <write>:
SYSCALL(write)
 38f:	b8 10 00 00 00       	mov    $0x10,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <close>:
SYSCALL(close)
 397:	b8 15 00 00 00       	mov    $0x15,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <kill>:
SYSCALL(kill)
 39f:	b8 06 00 00 00       	mov    $0x6,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <exec>:
SYSCALL(exec)
 3a7:	b8 07 00 00 00       	mov    $0x7,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <open>:
SYSCALL(open)
 3af:	b8 0f 00 00 00       	mov    $0xf,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <mknod>:
SYSCALL(mknod)
 3b7:	b8 11 00 00 00       	mov    $0x11,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <unlink>:
SYSCALL(unlink)
 3bf:	b8 12 00 00 00       	mov    $0x12,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <fstat>:
SYSCALL(fstat)
 3c7:	b8 08 00 00 00       	mov    $0x8,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <link>:
SYSCALL(link)
 3cf:	b8 13 00 00 00       	mov    $0x13,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <mkdir>:
SYSCALL(mkdir)
 3d7:	b8 14 00 00 00       	mov    $0x14,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <chdir>:
SYSCALL(chdir)
 3df:	b8 09 00 00 00       	mov    $0x9,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <dup>:
SYSCALL(dup)
 3e7:	b8 0a 00 00 00       	mov    $0xa,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <getpid>:
SYSCALL(getpid)
 3ef:	b8 0b 00 00 00       	mov    $0xb,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <sbrk>:
SYSCALL(sbrk)
 3f7:	b8 0c 00 00 00       	mov    $0xc,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <sleep>:
SYSCALL(sleep)
 3ff:	b8 0d 00 00 00       	mov    $0xd,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <uptime>:
SYSCALL(uptime)
 407:	b8 0e 00 00 00       	mov    $0xe,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <procstat>:
SYSCALL(procstat)
 40f:	b8 16 00 00 00       	mov    $0x16,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <setpriority>:
SYSCALL(setpriority)
 417:	b8 17 00 00 00       	mov    $0x17,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <semget>:
SYSCALL(semget)
 41f:	b8 18 00 00 00       	mov    $0x18,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <semfree>:
SYSCALL(semfree)
 427:	b8 19 00 00 00       	mov    $0x19,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <semdown>:
SYSCALL(semdown)
 42f:	b8 1a 00 00 00       	mov    $0x1a,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <semup>:
SYSCALL(semup)
 437:	b8 1b 00 00 00       	mov    $0x1b,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <mmap>:
SYSCALL(mmap)
 43f:	b8 1d 00 00 00       	mov    $0x1d,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <munmap>:
SYSCALL(munmap)
 447:	b8 1e 00 00 00       	mov    $0x1e,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 44f:	55                   	push   %ebp
 450:	89 e5                	mov    %esp,%ebp
 452:	83 ec 18             	sub    $0x18,%esp
 455:	8b 45 0c             	mov    0xc(%ebp),%eax
 458:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 45b:	83 ec 04             	sub    $0x4,%esp
 45e:	6a 01                	push   $0x1
 460:	8d 45 f4             	lea    -0xc(%ebp),%eax
 463:	50                   	push   %eax
 464:	ff 75 08             	pushl  0x8(%ebp)
 467:	e8 23 ff ff ff       	call   38f <write>
 46c:	83 c4 10             	add    $0x10,%esp
}
 46f:	90                   	nop
 470:	c9                   	leave  
 471:	c3                   	ret    

00000472 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 472:	55                   	push   %ebp
 473:	89 e5                	mov    %esp,%ebp
 475:	53                   	push   %ebx
 476:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 479:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 480:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 484:	74 17                	je     49d <printint+0x2b>
 486:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 48a:	79 11                	jns    49d <printint+0x2b>
    neg = 1;
 48c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 493:	8b 45 0c             	mov    0xc(%ebp),%eax
 496:	f7 d8                	neg    %eax
 498:	89 45 ec             	mov    %eax,-0x14(%ebp)
 49b:	eb 06                	jmp    4a3 <printint+0x31>
  } else {
    x = xx;
 49d:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4aa:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4ad:	8d 41 01             	lea    0x1(%ecx),%eax
 4b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b9:	ba 00 00 00 00       	mov    $0x0,%edx
 4be:	f7 f3                	div    %ebx
 4c0:	89 d0                	mov    %edx,%eax
 4c2:	0f b6 80 9c 0b 00 00 	movzbl 0xb9c(%eax),%eax
 4c9:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d3:	ba 00 00 00 00       	mov    $0x0,%edx
 4d8:	f7 f3                	div    %ebx
 4da:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e1:	75 c7                	jne    4aa <printint+0x38>
  if(neg)
 4e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e7:	74 2d                	je     516 <printint+0xa4>
    buf[i++] = '-';
 4e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ec:	8d 50 01             	lea    0x1(%eax),%edx
 4ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f7:	eb 1d                	jmp    516 <printint+0xa4>
    putc(fd, buf[i]);
 4f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ff:	01 d0                	add    %edx,%eax
 501:	0f b6 00             	movzbl (%eax),%eax
 504:	0f be c0             	movsbl %al,%eax
 507:	83 ec 08             	sub    $0x8,%esp
 50a:	50                   	push   %eax
 50b:	ff 75 08             	pushl  0x8(%ebp)
 50e:	e8 3c ff ff ff       	call   44f <putc>
 513:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 516:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 51a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51e:	79 d9                	jns    4f9 <printint+0x87>
    putc(fd, buf[i]);
}
 520:	90                   	nop
 521:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 524:	c9                   	leave  
 525:	c3                   	ret    

00000526 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 526:	55                   	push   %ebp
 527:	89 e5                	mov    %esp,%ebp
 529:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 52c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 533:	8d 45 0c             	lea    0xc(%ebp),%eax
 536:	83 c0 04             	add    $0x4,%eax
 539:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 53c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 543:	e9 59 01 00 00       	jmp    6a1 <printf+0x17b>
    c = fmt[i] & 0xff;
 548:	8b 55 0c             	mov    0xc(%ebp),%edx
 54b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 54e:	01 d0                	add    %edx,%eax
 550:	0f b6 00             	movzbl (%eax),%eax
 553:	0f be c0             	movsbl %al,%eax
 556:	25 ff 00 00 00       	and    $0xff,%eax
 55b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 55e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 562:	75 2c                	jne    590 <printf+0x6a>
      if(c == '%'){
 564:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 568:	75 0c                	jne    576 <printf+0x50>
        state = '%';
 56a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 571:	e9 27 01 00 00       	jmp    69d <printf+0x177>
      } else {
        putc(fd, c);
 576:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 579:	0f be c0             	movsbl %al,%eax
 57c:	83 ec 08             	sub    $0x8,%esp
 57f:	50                   	push   %eax
 580:	ff 75 08             	pushl  0x8(%ebp)
 583:	e8 c7 fe ff ff       	call   44f <putc>
 588:	83 c4 10             	add    $0x10,%esp
 58b:	e9 0d 01 00 00       	jmp    69d <printf+0x177>
      }
    } else if(state == '%'){
 590:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 594:	0f 85 03 01 00 00    	jne    69d <printf+0x177>
      if(c == 'd'){
 59a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 59e:	75 1e                	jne    5be <printf+0x98>
        printint(fd, *ap, 10, 1);
 5a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a3:	8b 00                	mov    (%eax),%eax
 5a5:	6a 01                	push   $0x1
 5a7:	6a 0a                	push   $0xa
 5a9:	50                   	push   %eax
 5aa:	ff 75 08             	pushl  0x8(%ebp)
 5ad:	e8 c0 fe ff ff       	call   472 <printint>
 5b2:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b9:	e9 d8 00 00 00       	jmp    696 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5be:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5c2:	74 06                	je     5ca <printf+0xa4>
 5c4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5c8:	75 1e                	jne    5e8 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5cd:	8b 00                	mov    (%eax),%eax
 5cf:	6a 00                	push   $0x0
 5d1:	6a 10                	push   $0x10
 5d3:	50                   	push   %eax
 5d4:	ff 75 08             	pushl  0x8(%ebp)
 5d7:	e8 96 fe ff ff       	call   472 <printint>
 5dc:	83 c4 10             	add    $0x10,%esp
        ap++;
 5df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e3:	e9 ae 00 00 00       	jmp    696 <printf+0x170>
      } else if(c == 's'){
 5e8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5ec:	75 43                	jne    631 <printf+0x10b>
        s = (char*)*ap;
 5ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fe:	75 25                	jne    625 <printf+0xff>
          s = "(null)";
 600:	c7 45 f4 2b 09 00 00 	movl   $0x92b,-0xc(%ebp)
        while(*s != 0){
 607:	eb 1c                	jmp    625 <printf+0xff>
          putc(fd, *s);
 609:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60c:	0f b6 00             	movzbl (%eax),%eax
 60f:	0f be c0             	movsbl %al,%eax
 612:	83 ec 08             	sub    $0x8,%esp
 615:	50                   	push   %eax
 616:	ff 75 08             	pushl  0x8(%ebp)
 619:	e8 31 fe ff ff       	call   44f <putc>
 61e:	83 c4 10             	add    $0x10,%esp
          s++;
 621:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 625:	8b 45 f4             	mov    -0xc(%ebp),%eax
 628:	0f b6 00             	movzbl (%eax),%eax
 62b:	84 c0                	test   %al,%al
 62d:	75 da                	jne    609 <printf+0xe3>
 62f:	eb 65                	jmp    696 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 631:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 635:	75 1d                	jne    654 <printf+0x12e>
        putc(fd, *ap);
 637:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63a:	8b 00                	mov    (%eax),%eax
 63c:	0f be c0             	movsbl %al,%eax
 63f:	83 ec 08             	sub    $0x8,%esp
 642:	50                   	push   %eax
 643:	ff 75 08             	pushl  0x8(%ebp)
 646:	e8 04 fe ff ff       	call   44f <putc>
 64b:	83 c4 10             	add    $0x10,%esp
        ap++;
 64e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 652:	eb 42                	jmp    696 <printf+0x170>
      } else if(c == '%'){
 654:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 658:	75 17                	jne    671 <printf+0x14b>
        putc(fd, c);
 65a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65d:	0f be c0             	movsbl %al,%eax
 660:	83 ec 08             	sub    $0x8,%esp
 663:	50                   	push   %eax
 664:	ff 75 08             	pushl  0x8(%ebp)
 667:	e8 e3 fd ff ff       	call   44f <putc>
 66c:	83 c4 10             	add    $0x10,%esp
 66f:	eb 25                	jmp    696 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 671:	83 ec 08             	sub    $0x8,%esp
 674:	6a 25                	push   $0x25
 676:	ff 75 08             	pushl  0x8(%ebp)
 679:	e8 d1 fd ff ff       	call   44f <putc>
 67e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 684:	0f be c0             	movsbl %al,%eax
 687:	83 ec 08             	sub    $0x8,%esp
 68a:	50                   	push   %eax
 68b:	ff 75 08             	pushl  0x8(%ebp)
 68e:	e8 bc fd ff ff       	call   44f <putc>
 693:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 696:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 69d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6a1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a7:	01 d0                	add    %edx,%eax
 6a9:	0f b6 00             	movzbl (%eax),%eax
 6ac:	84 c0                	test   %al,%al
 6ae:	0f 85 94 fe ff ff    	jne    548 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b4:	90                   	nop
 6b5:	c9                   	leave  
 6b6:	c3                   	ret    

000006b7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b7:	55                   	push   %ebp
 6b8:	89 e5                	mov    %esp,%ebp
 6ba:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6bd:	8b 45 08             	mov    0x8(%ebp),%eax
 6c0:	83 e8 08             	sub    $0x8,%eax
 6c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c6:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 6cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ce:	eb 24                	jmp    6f4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d3:	8b 00                	mov    (%eax),%eax
 6d5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d8:	77 12                	ja     6ec <free+0x35>
 6da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e0:	77 24                	ja     706 <free+0x4f>
 6e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e5:	8b 00                	mov    (%eax),%eax
 6e7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ea:	77 1a                	ja     706 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fa:	76 d4                	jbe    6d0 <free+0x19>
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 00                	mov    (%eax),%eax
 701:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 704:	76 ca                	jbe    6d0 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 706:	8b 45 f8             	mov    -0x8(%ebp),%eax
 709:	8b 40 04             	mov    0x4(%eax),%eax
 70c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 713:	8b 45 f8             	mov    -0x8(%ebp),%eax
 716:	01 c2                	add    %eax,%edx
 718:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71b:	8b 00                	mov    (%eax),%eax
 71d:	39 c2                	cmp    %eax,%edx
 71f:	75 24                	jne    745 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 721:	8b 45 f8             	mov    -0x8(%ebp),%eax
 724:	8b 50 04             	mov    0x4(%eax),%edx
 727:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72a:	8b 00                	mov    (%eax),%eax
 72c:	8b 40 04             	mov    0x4(%eax),%eax
 72f:	01 c2                	add    %eax,%edx
 731:	8b 45 f8             	mov    -0x8(%ebp),%eax
 734:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 737:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73a:	8b 00                	mov    (%eax),%eax
 73c:	8b 10                	mov    (%eax),%edx
 73e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 741:	89 10                	mov    %edx,(%eax)
 743:	eb 0a                	jmp    74f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 745:	8b 45 fc             	mov    -0x4(%ebp),%eax
 748:	8b 10                	mov    (%eax),%edx
 74a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 40 04             	mov    0x4(%eax),%eax
 755:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	01 d0                	add    %edx,%eax
 761:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 764:	75 20                	jne    786 <free+0xcf>
    p->s.size += bp->s.size;
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	8b 50 04             	mov    0x4(%eax),%edx
 76c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76f:	8b 40 04             	mov    0x4(%eax),%eax
 772:	01 c2                	add    %eax,%edx
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 77a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77d:	8b 10                	mov    (%eax),%edx
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	89 10                	mov    %edx,(%eax)
 784:	eb 08                	jmp    78e <free+0xd7>
  } else
    p->s.ptr = bp;
 786:	8b 45 fc             	mov    -0x4(%ebp),%eax
 789:	8b 55 f8             	mov    -0x8(%ebp),%edx
 78c:	89 10                	mov    %edx,(%eax)
  freep = p;
 78e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 791:	a3 b8 0b 00 00       	mov    %eax,0xbb8
}
 796:	90                   	nop
 797:	c9                   	leave  
 798:	c3                   	ret    

00000799 <morecore>:

static Header*
morecore(uint nu)
{
 799:	55                   	push   %ebp
 79a:	89 e5                	mov    %esp,%ebp
 79c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 79f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a6:	77 07                	ja     7af <morecore+0x16>
    nu = 4096;
 7a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
 7b2:	c1 e0 03             	shl    $0x3,%eax
 7b5:	83 ec 0c             	sub    $0xc,%esp
 7b8:	50                   	push   %eax
 7b9:	e8 39 fc ff ff       	call   3f7 <sbrk>
 7be:	83 c4 10             	add    $0x10,%esp
 7c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7c4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c8:	75 07                	jne    7d1 <morecore+0x38>
    return 0;
 7ca:	b8 00 00 00 00       	mov    $0x0,%eax
 7cf:	eb 26                	jmp    7f7 <morecore+0x5e>
  hp = (Header*)p;
 7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7da:	8b 55 08             	mov    0x8(%ebp),%edx
 7dd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e3:	83 c0 08             	add    $0x8,%eax
 7e6:	83 ec 0c             	sub    $0xc,%esp
 7e9:	50                   	push   %eax
 7ea:	e8 c8 fe ff ff       	call   6b7 <free>
 7ef:	83 c4 10             	add    $0x10,%esp
  return freep;
 7f2:	a1 b8 0b 00 00       	mov    0xbb8,%eax
}
 7f7:	c9                   	leave  
 7f8:	c3                   	ret    

000007f9 <malloc>:

void*
malloc(uint nbytes)
{
 7f9:	55                   	push   %ebp
 7fa:	89 e5                	mov    %esp,%ebp
 7fc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ff:	8b 45 08             	mov    0x8(%ebp),%eax
 802:	83 c0 07             	add    $0x7,%eax
 805:	c1 e8 03             	shr    $0x3,%eax
 808:	83 c0 01             	add    $0x1,%eax
 80b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 80e:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 813:	89 45 f0             	mov    %eax,-0x10(%ebp)
 816:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 81a:	75 23                	jne    83f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 81c:	c7 45 f0 b0 0b 00 00 	movl   $0xbb0,-0x10(%ebp)
 823:	8b 45 f0             	mov    -0x10(%ebp),%eax
 826:	a3 b8 0b 00 00       	mov    %eax,0xbb8
 82b:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 830:	a3 b0 0b 00 00       	mov    %eax,0xbb0
    base.s.size = 0;
 835:	c7 05 b4 0b 00 00 00 	movl   $0x0,0xbb4
 83c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 842:	8b 00                	mov    (%eax),%eax
 844:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 850:	72 4d                	jb     89f <malloc+0xa6>
      if(p->s.size == nunits)
 852:	8b 45 f4             	mov    -0xc(%ebp),%eax
 855:	8b 40 04             	mov    0x4(%eax),%eax
 858:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85b:	75 0c                	jne    869 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	8b 10                	mov    (%eax),%edx
 862:	8b 45 f0             	mov    -0x10(%ebp),%eax
 865:	89 10                	mov    %edx,(%eax)
 867:	eb 26                	jmp    88f <malloc+0x96>
      else {
        p->s.size -= nunits;
 869:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86c:	8b 40 04             	mov    0x4(%eax),%eax
 86f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 872:	89 c2                	mov    %eax,%edx
 874:	8b 45 f4             	mov    -0xc(%ebp),%eax
 877:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8b 40 04             	mov    0x4(%eax),%eax
 880:	c1 e0 03             	shl    $0x3,%eax
 883:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 886:	8b 45 f4             	mov    -0xc(%ebp),%eax
 889:	8b 55 ec             	mov    -0x14(%ebp),%edx
 88c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 88f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 892:	a3 b8 0b 00 00       	mov    %eax,0xbb8
      return (void*)(p + 1);
 897:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89a:	83 c0 08             	add    $0x8,%eax
 89d:	eb 3b                	jmp    8da <malloc+0xe1>
    }
    if(p == freep)
 89f:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 8a4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a7:	75 1e                	jne    8c7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8a9:	83 ec 0c             	sub    $0xc,%esp
 8ac:	ff 75 ec             	pushl  -0x14(%ebp)
 8af:	e8 e5 fe ff ff       	call   799 <morecore>
 8b4:	83 c4 10             	add    $0x10,%esp
 8b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8be:	75 07                	jne    8c7 <malloc+0xce>
        return 0;
 8c0:	b8 00 00 00 00       	mov    $0x0,%eax
 8c5:	eb 13                	jmp    8da <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8d5:	e9 6d ff ff ff       	jmp    847 <malloc+0x4e>
}
 8da:	c9                   	leave  
 8db:	c3                   	ret    
