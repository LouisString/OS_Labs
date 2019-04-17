
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 36 02 00 00       	call   f0100280 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 1e 40 01 00    	add    $0x1401e,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 b8 de fe ff    	lea    -0x12148(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 0f 0c 00 00       	call   f0100c72 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 d4 de fe ff    	lea    -0x1212c(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 e9 0b 00 00       	call   f0100c72 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 53 09 00 00       	call   f01009f4 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	57                   	push   %edi
f01000aa:	56                   	push   %esi
f01000ab:	53                   	push   %ebx
f01000ac:	81 ec 20 01 00 00    	sub    $0x120,%esp
f01000b2:	e8 c9 01 00 00       	call   f0100280 <__x86.get_pc_thunk.bx>
f01000b7:	81 c3 b1 3f 01 00    	add    $0x13fb1,%ebx
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000bd:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f01000c1:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
f01000c5:	c7 85 e6 fe ff ff 00 	movl   $0x0,-0x11a(%ebp)
f01000cc:	00 00 00 
f01000cf:	c7 45 e2 00 00 00 00 	movl   $0x0,-0x1e(%ebp)
f01000d6:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01000dc:	b9 3f 00 00 00       	mov    $0x3f,%ecx
f01000e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01000e6:	f3 ab                	rep stos %eax,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000e8:	c7 c2 80 40 11 f0    	mov    $0xf0114080,%edx
f01000ee:	c7 c0 c0 46 11 f0    	mov    $0xf01146c0,%eax
f01000f4:	29 d0                	sub    %edx,%eax
f01000f6:	50                   	push   %eax
f01000f7:	6a 00                	push   $0x0
f01000f9:	52                   	push   %edx
f01000fa:	e8 e1 19 00 00       	call   f0101ae0 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000ff:	e8 a4 05 00 00       	call   f01006a8 <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f0100104:	8d 45 e6             	lea    -0x1a(%ebp),%eax
f0100107:	50                   	push   %eax
f0100108:	8d 7d e7             	lea    -0x19(%ebp),%edi
f010010b:	57                   	push   %edi
f010010c:	68 ac 1a 00 00       	push   $0x1aac
f0100111:	8d 83 68 df fe ff    	lea    -0x12098(%ebx),%eax
f0100117:	50                   	push   %eax
f0100118:	e8 55 0b 00 00       	call   f0100c72 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f010011d:	83 c4 18             	add    $0x18,%esp
f0100120:	6a 16                	push   $0x16
f0100122:	8d 83 88 df fe ff    	lea    -0x12078(%ebx),%eax
f0100128:	50                   	push   %eax
f0100129:	e8 44 0b 00 00       	call   f0100c72 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010012e:	83 c4 0c             	add    $0xc,%esp
f0100131:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f0100135:	50                   	push   %eax
f0100136:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010013a:	50                   	push   %eax
f010013b:	8d 83 ef de fe ff    	lea    -0x12111(%ebx),%eax
f0100141:	50                   	push   %eax
f0100142:	e8 2b 0b 00 00       	call   f0100c72 <cprintf>
	cprintf("%n", NULL);
f0100147:	83 c4 08             	add    $0x8,%esp
f010014a:	6a 00                	push   $0x0
f010014c:	8d 83 72 e2 fe ff    	lea    -0x11d8e(%ebx),%eax
f0100152:	50                   	push   %eax
f0100153:	e8 1a 0b 00 00       	call   f0100c72 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100158:	83 c4 0c             	add    $0xc,%esp
f010015b:	68 ff 00 00 00       	push   $0xff
f0100160:	6a 0d                	push   $0xd
f0100162:	8d b5 e6 fe ff ff    	lea    -0x11a(%ebp),%esi
f0100168:	56                   	push   %esi
f0100169:	e8 72 19 00 00       	call   f0101ae0 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f010016e:	83 c4 0c             	add    $0xc,%esp
f0100171:	57                   	push   %edi
f0100172:	56                   	push   %esi
f0100173:	8d 83 06 df fe ff    	lea    -0x120fa(%ebx),%eax
f0100179:	50                   	push   %eax
f010017a:	e8 f3 0a 00 00       	call   f0100c72 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010017f:	83 c4 08             	add    $0x8,%esp
f0100182:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100186:	50                   	push   %eax
f0100187:	8d 83 0b df fe ff    	lea    -0x120f5(%ebx),%eax
f010018d:	50                   	push   %eax
f010018e:	e8 df 0a 00 00       	call   f0100c72 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f0100193:	83 c4 0c             	add    $0xc,%esp
f0100196:	68 00 fc ff ff       	push   $0xfffffc00
f010019b:	68 00 04 00 00       	push   $0x400
f01001a0:	8d 83 17 df fe ff    	lea    -0x120e9(%ebx),%eax
f01001a6:	50                   	push   %eax
f01001a7:	e8 c6 0a 00 00       	call   f0100c72 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01001ac:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01001b3:	e8 88 fe ff ff       	call   f0100040 <test_backtrace>
f01001b8:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01001bb:	83 ec 0c             	sub    $0xc,%esp
f01001be:	6a 00                	push   $0x0
f01001c0:	e8 e9 08 00 00       	call   f0100aae <monitor>
f01001c5:	83 c4 10             	add    $0x10,%esp
f01001c8:	eb f1                	jmp    f01001bb <i386_init+0x115>

f01001ca <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01001ca:	55                   	push   %ebp
f01001cb:	89 e5                	mov    %esp,%ebp
f01001cd:	57                   	push   %edi
f01001ce:	56                   	push   %esi
f01001cf:	53                   	push   %ebx
f01001d0:	83 ec 0c             	sub    $0xc,%esp
f01001d3:	e8 a8 00 00 00       	call   f0100280 <__x86.get_pc_thunk.bx>
f01001d8:	81 c3 90 3e 01 00    	add    $0x13e90,%ebx
f01001de:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01001e1:	c7 c0 c4 46 11 f0    	mov    $0xf01146c4,%eax
f01001e7:	83 38 00             	cmpl   $0x0,(%eax)
f01001ea:	74 0f                	je     f01001fb <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01001ec:	83 ec 0c             	sub    $0xc,%esp
f01001ef:	6a 00                	push   $0x0
f01001f1:	e8 b8 08 00 00       	call   f0100aae <monitor>
f01001f6:	83 c4 10             	add    $0x10,%esp
f01001f9:	eb f1                	jmp    f01001ec <_panic+0x22>
	panicstr = fmt;
f01001fb:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01001fd:	fa                   	cli    
f01001fe:	fc                   	cld    
	va_start(ap, fmt);
f01001ff:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100202:	83 ec 04             	sub    $0x4,%esp
f0100205:	ff 75 0c             	pushl  0xc(%ebp)
f0100208:	ff 75 08             	pushl  0x8(%ebp)
f010020b:	8d 83 33 df fe ff    	lea    -0x120cd(%ebx),%eax
f0100211:	50                   	push   %eax
f0100212:	e8 5b 0a 00 00       	call   f0100c72 <cprintf>
	vcprintf(fmt, ap);
f0100217:	83 c4 08             	add    $0x8,%esp
f010021a:	56                   	push   %esi
f010021b:	57                   	push   %edi
f010021c:	e8 1a 0a 00 00       	call   f0100c3b <vcprintf>
	cprintf("\n");
f0100221:	8d 83 c1 df fe ff    	lea    -0x1203f(%ebx),%eax
f0100227:	89 04 24             	mov    %eax,(%esp)
f010022a:	e8 43 0a 00 00       	call   f0100c72 <cprintf>
f010022f:	83 c4 10             	add    $0x10,%esp
f0100232:	eb b8                	jmp    f01001ec <_panic+0x22>

f0100234 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100234:	55                   	push   %ebp
f0100235:	89 e5                	mov    %esp,%ebp
f0100237:	56                   	push   %esi
f0100238:	53                   	push   %ebx
f0100239:	e8 42 00 00 00       	call   f0100280 <__x86.get_pc_thunk.bx>
f010023e:	81 c3 2a 3e 01 00    	add    $0x13e2a,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100244:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100247:	83 ec 04             	sub    $0x4,%esp
f010024a:	ff 75 0c             	pushl  0xc(%ebp)
f010024d:	ff 75 08             	pushl  0x8(%ebp)
f0100250:	8d 83 4b df fe ff    	lea    -0x120b5(%ebx),%eax
f0100256:	50                   	push   %eax
f0100257:	e8 16 0a 00 00       	call   f0100c72 <cprintf>
	vcprintf(fmt, ap);
f010025c:	83 c4 08             	add    $0x8,%esp
f010025f:	56                   	push   %esi
f0100260:	ff 75 10             	pushl  0x10(%ebp)
f0100263:	e8 d3 09 00 00       	call   f0100c3b <vcprintf>
	cprintf("\n");
f0100268:	8d 83 c1 df fe ff    	lea    -0x1203f(%ebx),%eax
f010026e:	89 04 24             	mov    %eax,(%esp)
f0100271:	e8 fc 09 00 00       	call   f0100c72 <cprintf>
	va_end(ap);
}
f0100276:	83 c4 10             	add    $0x10,%esp
f0100279:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010027c:	5b                   	pop    %ebx
f010027d:	5e                   	pop    %esi
f010027e:	5d                   	pop    %ebp
f010027f:	c3                   	ret    

f0100280 <__x86.get_pc_thunk.bx>:
f0100280:	8b 1c 24             	mov    (%esp),%ebx
f0100283:	c3                   	ret    

f0100284 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100284:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100289:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010028a:	a8 01                	test   $0x1,%al
f010028c:	74 0a                	je     f0100298 <serial_proc_data+0x14>
f010028e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100293:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100294:	0f b6 c0             	movzbl %al,%eax
f0100297:	c3                   	ret    
		return -1;
f0100298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010029d:	c3                   	ret    

f010029e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	56                   	push   %esi
f01002a2:	53                   	push   %ebx
f01002a3:	e8 d8 ff ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f01002a8:	81 c3 c0 3d 01 00    	add    $0x13dc0,%ebx
f01002ae:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01002b0:	ff d6                	call   *%esi
f01002b2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002b5:	74 2a                	je     f01002e1 <cons_intr+0x43>
		if (c == 0)
f01002b7:	85 c0                	test   %eax,%eax
f01002b9:	74 f5                	je     f01002b0 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01002bb:	8b 8b 3c 02 00 00    	mov    0x23c(%ebx),%ecx
f01002c1:	8d 51 01             	lea    0x1(%ecx),%edx
f01002c4:	88 84 0b 38 00 00 00 	mov    %al,0x38(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01002cb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01002d6:	0f 44 d0             	cmove  %eax,%edx
f01002d9:	89 93 3c 02 00 00    	mov    %edx,0x23c(%ebx)
f01002df:	eb cf                	jmp    f01002b0 <cons_intr+0x12>
	}
}
f01002e1:	5b                   	pop    %ebx
f01002e2:	5e                   	pop    %esi
f01002e3:	5d                   	pop    %ebp
f01002e4:	c3                   	ret    

f01002e5 <kbd_proc_data>:
{
f01002e5:	55                   	push   %ebp
f01002e6:	89 e5                	mov    %esp,%ebp
f01002e8:	56                   	push   %esi
f01002e9:	53                   	push   %ebx
f01002ea:	e8 91 ff ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f01002ef:	81 c3 79 3d 01 00    	add    $0x13d79,%ebx
f01002f5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002fa:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002fb:	a8 01                	test   $0x1,%al
f01002fd:	0f 84 fb 00 00 00    	je     f01003fe <kbd_proc_data+0x119>
	if (stat & KBS_TERR)
f0100303:	a8 20                	test   $0x20,%al
f0100305:	0f 85 fa 00 00 00    	jne    f0100405 <kbd_proc_data+0x120>
f010030b:	ba 60 00 00 00       	mov    $0x60,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100313:	3c e0                	cmp    $0xe0,%al
f0100315:	74 64                	je     f010037b <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100317:	84 c0                	test   %al,%al
f0100319:	78 75                	js     f0100390 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010031b:	8b 8b 18 00 00 00    	mov    0x18(%ebx),%ecx
f0100321:	f6 c1 40             	test   $0x40,%cl
f0100324:	74 0e                	je     f0100334 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100326:	83 c8 80             	or     $0xffffff80,%eax
f0100329:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010032e:	89 8b 18 00 00 00    	mov    %ecx,0x18(%ebx)
	shift |= shiftcode[data];
f0100334:	0f b6 d2             	movzbl %dl,%edx
f0100337:	0f b6 84 13 f8 e0 fe 	movzbl -0x11f08(%ebx,%edx,1),%eax
f010033e:	ff 
f010033f:	0b 83 18 00 00 00    	or     0x18(%ebx),%eax
	shift ^= togglecode[data];
f0100345:	0f b6 8c 13 f8 df fe 	movzbl -0x12008(%ebx,%edx,1),%ecx
f010034c:	ff 
f010034d:	31 c8                	xor    %ecx,%eax
f010034f:	89 83 18 00 00 00    	mov    %eax,0x18(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100355:	89 c1                	mov    %eax,%ecx
f0100357:	83 e1 03             	and    $0x3,%ecx
f010035a:	8b 8c 8b 98 ff ff ff 	mov    -0x68(%ebx,%ecx,4),%ecx
f0100361:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100365:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100368:	a8 08                	test   $0x8,%al
f010036a:	74 65                	je     f01003d1 <kbd_proc_data+0xec>
		if ('a' <= c && c <= 'z')
f010036c:	89 f2                	mov    %esi,%edx
f010036e:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100371:	83 f9 19             	cmp    $0x19,%ecx
f0100374:	77 4f                	ja     f01003c5 <kbd_proc_data+0xe0>
			c += 'A' - 'a';
f0100376:	83 ee 20             	sub    $0x20,%esi
f0100379:	eb 0c                	jmp    f0100387 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010037b:	83 8b 18 00 00 00 40 	orl    $0x40,0x18(%ebx)
		return 0;
f0100382:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100387:	89 f0                	mov    %esi,%eax
f0100389:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010038c:	5b                   	pop    %ebx
f010038d:	5e                   	pop    %esi
f010038e:	5d                   	pop    %ebp
f010038f:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100390:	8b 8b 18 00 00 00    	mov    0x18(%ebx),%ecx
f0100396:	89 ce                	mov    %ecx,%esi
f0100398:	83 e6 40             	and    $0x40,%esi
f010039b:	83 e0 7f             	and    $0x7f,%eax
f010039e:	85 f6                	test   %esi,%esi
f01003a0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003a3:	0f b6 d2             	movzbl %dl,%edx
f01003a6:	0f b6 84 13 f8 e0 fe 	movzbl -0x11f08(%ebx,%edx,1),%eax
f01003ad:	ff 
f01003ae:	83 c8 40             	or     $0x40,%eax
f01003b1:	0f b6 c0             	movzbl %al,%eax
f01003b4:	f7 d0                	not    %eax
f01003b6:	21 c8                	and    %ecx,%eax
f01003b8:	89 83 18 00 00 00    	mov    %eax,0x18(%ebx)
		return 0;
f01003be:	be 00 00 00 00       	mov    $0x0,%esi
f01003c3:	eb c2                	jmp    f0100387 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01003c5:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003c8:	8d 4e 20             	lea    0x20(%esi),%ecx
f01003cb:	83 fa 1a             	cmp    $0x1a,%edx
f01003ce:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003d1:	f7 d0                	not    %eax
f01003d3:	a8 06                	test   $0x6,%al
f01003d5:	75 b0                	jne    f0100387 <kbd_proc_data+0xa2>
f01003d7:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01003dd:	75 a8                	jne    f0100387 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01003df:	83 ec 0c             	sub    $0xc,%esp
f01003e2:	8d 83 b7 df fe ff    	lea    -0x12049(%ebx),%eax
f01003e8:	50                   	push   %eax
f01003e9:	e8 84 08 00 00       	call   f0100c72 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01003f3:	ba 92 00 00 00       	mov    $0x92,%edx
f01003f8:	ee                   	out    %al,(%dx)
f01003f9:	83 c4 10             	add    $0x10,%esp
f01003fc:	eb 89                	jmp    f0100387 <kbd_proc_data+0xa2>
		return -1;
f01003fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100403:	eb 82                	jmp    f0100387 <kbd_proc_data+0xa2>
		return -1;
f0100405:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010040a:	e9 78 ff ff ff       	jmp    f0100387 <kbd_proc_data+0xa2>

f010040f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010040f:	55                   	push   %ebp
f0100410:	89 e5                	mov    %esp,%ebp
f0100412:	57                   	push   %edi
f0100413:	56                   	push   %esi
f0100414:	53                   	push   %ebx
f0100415:	83 ec 1c             	sub    $0x1c,%esp
f0100418:	e8 63 fe ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f010041d:	81 c3 4b 3c 01 00    	add    $0x13c4b,%ebx
f0100423:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100425:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100434:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100435:	a8 20                	test   $0x20,%al
f0100437:	75 13                	jne    f010044c <cons_putc+0x3d>
f0100439:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010043f:	7f 0b                	jg     f010044c <cons_putc+0x3d>
f0100441:	89 ca                	mov    %ecx,%edx
f0100443:	ec                   	in     (%dx),%al
f0100444:	ec                   	in     (%dx),%al
f0100445:	ec                   	in     (%dx),%al
f0100446:	ec                   	in     (%dx),%al
	     i++)
f0100447:	83 c6 01             	add    $0x1,%esi
f010044a:	eb e3                	jmp    f010042f <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f010044c:	89 f8                	mov    %edi,%eax
f010044e:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100451:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100456:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100457:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010045c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100461:	ba 79 03 00 00       	mov    $0x379,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010046d:	7f 0f                	jg     f010047e <cons_putc+0x6f>
f010046f:	84 c0                	test   %al,%al
f0100471:	78 0b                	js     f010047e <cons_putc+0x6f>
f0100473:	89 ca                	mov    %ecx,%edx
f0100475:	ec                   	in     (%dx),%al
f0100476:	ec                   	in     (%dx),%al
f0100477:	ec                   	in     (%dx),%al
f0100478:	ec                   	in     (%dx),%al
f0100479:	83 c6 01             	add    $0x1,%esi
f010047c:	eb e3                	jmp    f0100461 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100483:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100487:	ee                   	out    %al,(%dx)
f0100488:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010048d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100492:	ee                   	out    %al,(%dx)
f0100493:	b8 08 00 00 00       	mov    $0x8,%eax
f0100498:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100499:	89 fa                	mov    %edi,%edx
f010049b:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004a1:	89 f8                	mov    %edi,%eax
f01004a3:	80 cc 07             	or     $0x7,%ah
f01004a6:	85 d2                	test   %edx,%edx
f01004a8:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01004ab:	89 f8                	mov    %edi,%eax
f01004ad:	0f b6 c0             	movzbl %al,%eax
f01004b0:	83 f8 09             	cmp    $0x9,%eax
f01004b3:	0f 84 b4 00 00 00    	je     f010056d <cons_putc+0x15e>
f01004b9:	7e 74                	jle    f010052f <cons_putc+0x120>
f01004bb:	83 f8 0a             	cmp    $0xa,%eax
f01004be:	0f 84 9c 00 00 00    	je     f0100560 <cons_putc+0x151>
f01004c4:	83 f8 0d             	cmp    $0xd,%eax
f01004c7:	0f 85 d7 00 00 00    	jne    f01005a4 <cons_putc+0x195>
		crt_pos -= (crt_pos % CRT_COLS);
f01004cd:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f01004d4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004da:	c1 e8 16             	shr    $0x16,%eax
f01004dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e0:	c1 e0 04             	shl    $0x4,%eax
f01004e3:	66 89 83 40 02 00 00 	mov    %ax,0x240(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004ea:	66 81 bb 40 02 00 00 	cmpw   $0x7cf,0x240(%ebx)
f01004f1:	cf 07 
f01004f3:	0f 87 ce 00 00 00    	ja     f01005c7 <cons_putc+0x1b8>
	outb(addr_6845, 14);
f01004f9:	8b 8b 48 02 00 00    	mov    0x248(%ebx),%ecx
f01004ff:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100504:	89 ca                	mov    %ecx,%edx
f0100506:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100507:	0f b7 9b 40 02 00 00 	movzwl 0x240(%ebx),%ebx
f010050e:	8d 71 01             	lea    0x1(%ecx),%esi
f0100511:	89 d8                	mov    %ebx,%eax
f0100513:	66 c1 e8 08          	shr    $0x8,%ax
f0100517:	89 f2                	mov    %esi,%edx
f0100519:	ee                   	out    %al,(%dx)
f010051a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010051f:	89 ca                	mov    %ecx,%edx
f0100521:	ee                   	out    %al,(%dx)
f0100522:	89 d8                	mov    %ebx,%eax
f0100524:	89 f2                	mov    %esi,%edx
f0100526:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100527:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010052a:	5b                   	pop    %ebx
f010052b:	5e                   	pop    %esi
f010052c:	5f                   	pop    %edi
f010052d:	5d                   	pop    %ebp
f010052e:	c3                   	ret    
f010052f:	83 f8 08             	cmp    $0x8,%eax
f0100532:	75 70                	jne    f01005a4 <cons_putc+0x195>
		if (crt_pos > 0) {
f0100534:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f010053b:	66 85 c0             	test   %ax,%ax
f010053e:	74 b9                	je     f01004f9 <cons_putc+0xea>
			crt_pos--;
f0100540:	83 e8 01             	sub    $0x1,%eax
f0100543:	66 89 83 40 02 00 00 	mov    %ax,0x240(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	89 fa                	mov    %edi,%edx
f010054f:	b2 00                	mov    $0x0,%dl
f0100551:	83 ca 20             	or     $0x20,%edx
f0100554:	8b 8b 44 02 00 00    	mov    0x244(%ebx),%ecx
f010055a:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010055e:	eb 8a                	jmp    f01004ea <cons_putc+0xdb>
		crt_pos += CRT_COLS;
f0100560:	66 83 83 40 02 00 00 	addw   $0x50,0x240(%ebx)
f0100567:	50 
f0100568:	e9 60 ff ff ff       	jmp    f01004cd <cons_putc+0xbe>
		cons_putc(' ');
f010056d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100572:	e8 98 fe ff ff       	call   f010040f <cons_putc>
		cons_putc(' ');
f0100577:	b8 20 00 00 00       	mov    $0x20,%eax
f010057c:	e8 8e fe ff ff       	call   f010040f <cons_putc>
		cons_putc(' ');
f0100581:	b8 20 00 00 00       	mov    $0x20,%eax
f0100586:	e8 84 fe ff ff       	call   f010040f <cons_putc>
		cons_putc(' ');
f010058b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100590:	e8 7a fe ff ff       	call   f010040f <cons_putc>
		cons_putc(' ');
f0100595:	b8 20 00 00 00       	mov    $0x20,%eax
f010059a:	e8 70 fe ff ff       	call   f010040f <cons_putc>
f010059f:	e9 46 ff ff ff       	jmp    f01004ea <cons_putc+0xdb>
		crt_buf[crt_pos++] = c;		/* write the character */
f01005a4:	0f b7 83 40 02 00 00 	movzwl 0x240(%ebx),%eax
f01005ab:	8d 50 01             	lea    0x1(%eax),%edx
f01005ae:	66 89 93 40 02 00 00 	mov    %dx,0x240(%ebx)
f01005b5:	0f b7 c0             	movzwl %ax,%eax
f01005b8:	8b 93 44 02 00 00    	mov    0x244(%ebx),%edx
f01005be:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005c2:	e9 23 ff ff ff       	jmp    f01004ea <cons_putc+0xdb>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005c7:	8b 83 44 02 00 00    	mov    0x244(%ebx),%eax
f01005cd:	83 ec 04             	sub    $0x4,%esp
f01005d0:	68 00 0f 00 00       	push   $0xf00
f01005d5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005db:	52                   	push   %edx
f01005dc:	50                   	push   %eax
f01005dd:	e8 46 15 00 00       	call   f0101b28 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005e2:	8b 93 44 02 00 00    	mov    0x244(%ebx),%edx
f01005e8:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005ee:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005f4:	83 c4 10             	add    $0x10,%esp
f01005f7:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005fc:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ff:	39 d0                	cmp    %edx,%eax
f0100601:	75 f4                	jne    f01005f7 <cons_putc+0x1e8>
		crt_pos -= CRT_COLS;
f0100603:	66 83 ab 40 02 00 00 	subw   $0x50,0x240(%ebx)
f010060a:	50 
f010060b:	e9 e9 fe ff ff       	jmp    f01004f9 <cons_putc+0xea>

f0100610 <serial_intr>:
{
f0100610:	e8 dc 01 00 00       	call   f01007f1 <__x86.get_pc_thunk.ax>
f0100615:	05 53 3a 01 00       	add    $0x13a53,%eax
	if (serial_exists)
f010061a:	80 b8 4c 02 00 00 00 	cmpb   $0x0,0x24c(%eax)
f0100621:	75 01                	jne    f0100624 <serial_intr+0x14>
f0100623:	c3                   	ret    
{
f0100624:	55                   	push   %ebp
f0100625:	89 e5                	mov    %esp,%ebp
f0100627:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010062a:	8d 80 1c c2 fe ff    	lea    -0x13de4(%eax),%eax
f0100630:	e8 69 fc ff ff       	call   f010029e <cons_intr>
}
f0100635:	c9                   	leave  
f0100636:	c3                   	ret    

f0100637 <kbd_intr>:
{
f0100637:	55                   	push   %ebp
f0100638:	89 e5                	mov    %esp,%ebp
f010063a:	83 ec 08             	sub    $0x8,%esp
f010063d:	e8 af 01 00 00       	call   f01007f1 <__x86.get_pc_thunk.ax>
f0100642:	05 26 3a 01 00       	add    $0x13a26,%eax
	cons_intr(kbd_proc_data);
f0100647:	8d 80 7d c2 fe ff    	lea    -0x13d83(%eax),%eax
f010064d:	e8 4c fc ff ff       	call   f010029e <cons_intr>
}
f0100652:	c9                   	leave  
f0100653:	c3                   	ret    

f0100654 <cons_getc>:
{
f0100654:	55                   	push   %ebp
f0100655:	89 e5                	mov    %esp,%ebp
f0100657:	53                   	push   %ebx
f0100658:	83 ec 04             	sub    $0x4,%esp
f010065b:	e8 20 fc ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100660:	81 c3 08 3a 01 00    	add    $0x13a08,%ebx
	serial_intr();
f0100666:	e8 a5 ff ff ff       	call   f0100610 <serial_intr>
	kbd_intr();
f010066b:	e8 c7 ff ff ff       	call   f0100637 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100670:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
	return 0;
f0100676:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010067b:	3b 8b 3c 02 00 00    	cmp    0x23c(%ebx),%ecx
f0100681:	74 1f                	je     f01006a2 <cons_getc+0x4e>
		c = cons.buf[cons.rpos++];
f0100683:	8d 51 01             	lea    0x1(%ecx),%edx
f0100686:	0f b6 84 0b 38 00 00 	movzbl 0x38(%ebx,%ecx,1),%eax
f010068d:	00 
		if (cons.rpos == CONSBUFSIZE)
f010068e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100694:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100699:	0f 44 d1             	cmove  %ecx,%edx
f010069c:	89 93 38 02 00 00    	mov    %edx,0x238(%ebx)
}
f01006a2:	83 c4 04             	add    $0x4,%esp
f01006a5:	5b                   	pop    %ebx
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    

f01006a8 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01006a8:	55                   	push   %ebp
f01006a9:	89 e5                	mov    %esp,%ebp
f01006ab:	57                   	push   %edi
f01006ac:	56                   	push   %esi
f01006ad:	53                   	push   %ebx
f01006ae:	83 ec 1c             	sub    $0x1c,%esp
f01006b1:	e8 ca fb ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f01006b6:	81 c3 b2 39 01 00    	add    $0x139b2,%ebx
	was = *cp;
f01006bc:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006c3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006ca:	5a a5 
	if (*cp != 0xA55A) {
f01006cc:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006d3:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006d7:	0f 84 bc 00 00 00    	je     f0100799 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01006dd:	c7 83 48 02 00 00 b4 	movl   $0x3b4,0x248(%ebx)
f01006e4:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006e7:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f01006ee:	8b bb 48 02 00 00    	mov    0x248(%ebx),%edi
f01006f4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006f9:	89 fa                	mov    %edi,%edx
f01006fb:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006fc:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ff:	89 ca                	mov    %ecx,%edx
f0100701:	ec                   	in     (%dx),%al
f0100702:	0f b6 f0             	movzbl %al,%esi
f0100705:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100708:	b8 0f 00 00 00       	mov    $0xf,%eax
f010070d:	89 fa                	mov    %edi,%edx
f010070f:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100710:	89 ca                	mov    %ecx,%edx
f0100712:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100716:	89 bb 44 02 00 00    	mov    %edi,0x244(%ebx)
	pos |= inb(addr_6845 + 1);
f010071c:	0f b6 c0             	movzbl %al,%eax
f010071f:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100721:	66 89 b3 40 02 00 00 	mov    %si,0x240(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100728:	b9 00 00 00 00       	mov    $0x0,%ecx
f010072d:	89 c8                	mov    %ecx,%eax
f010072f:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100734:	ee                   	out    %al,(%dx)
f0100735:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010073a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010073f:	89 fa                	mov    %edi,%edx
f0100741:	ee                   	out    %al,(%dx)
f0100742:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100747:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010074c:	ee                   	out    %al,(%dx)
f010074d:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100752:	89 c8                	mov    %ecx,%eax
f0100754:	89 f2                	mov    %esi,%edx
f0100756:	ee                   	out    %al,(%dx)
f0100757:	b8 03 00 00 00       	mov    $0x3,%eax
f010075c:	89 fa                	mov    %edi,%edx
f010075e:	ee                   	out    %al,(%dx)
f010075f:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100764:	89 c8                	mov    %ecx,%eax
f0100766:	ee                   	out    %al,(%dx)
f0100767:	b8 01 00 00 00       	mov    $0x1,%eax
f010076c:	89 f2                	mov    %esi,%edx
f010076e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100774:	ec                   	in     (%dx),%al
f0100775:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100777:	3c ff                	cmp    $0xff,%al
f0100779:	0f 95 83 4c 02 00 00 	setne  0x24c(%ebx)
f0100780:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100785:	ec                   	in     (%dx),%al
f0100786:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010078b:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010078c:	80 f9 ff             	cmp    $0xff,%cl
f010078f:	74 25                	je     f01007b6 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f0100791:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100794:	5b                   	pop    %ebx
f0100795:	5e                   	pop    %esi
f0100796:	5f                   	pop    %edi
f0100797:	5d                   	pop    %ebp
f0100798:	c3                   	ret    
		*cp = was;
f0100799:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007a0:	c7 83 48 02 00 00 d4 	movl   $0x3d4,0x248(%ebx)
f01007a7:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01007aa:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01007b1:	e9 38 ff ff ff       	jmp    f01006ee <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01007b6:	83 ec 0c             	sub    $0xc,%esp
f01007b9:	8d 83 c3 df fe ff    	lea    -0x1203d(%ebx),%eax
f01007bf:	50                   	push   %eax
f01007c0:	e8 ad 04 00 00       	call   f0100c72 <cprintf>
f01007c5:	83 c4 10             	add    $0x10,%esp
}
f01007c8:	eb c7                	jmp    f0100791 <cons_init+0xe9>

f01007ca <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007ca:	55                   	push   %ebp
f01007cb:	89 e5                	mov    %esp,%ebp
f01007cd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d3:	e8 37 fc ff ff       	call   f010040f <cons_putc>
}
f01007d8:	c9                   	leave  
f01007d9:	c3                   	ret    

f01007da <getchar>:

int
getchar(void)
{
f01007da:	55                   	push   %ebp
f01007db:	89 e5                	mov    %esp,%ebp
f01007dd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007e0:	e8 6f fe ff ff       	call   f0100654 <cons_getc>
f01007e5:	85 c0                	test   %eax,%eax
f01007e7:	74 f7                	je     f01007e0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007e9:	c9                   	leave  
f01007ea:	c3                   	ret    

f01007eb <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01007eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01007f0:	c3                   	ret    

f01007f1 <__x86.get_pc_thunk.ax>:
f01007f1:	8b 04 24             	mov    (%esp),%eax
f01007f4:	c3                   	ret    

f01007f5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
f01007f8:	56                   	push   %esi
f01007f9:	53                   	push   %ebx
f01007fa:	e8 81 fa ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f01007ff:	81 c3 69 38 01 00    	add    $0x13869,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100805:	83 ec 04             	sub    $0x4,%esp
f0100808:	8d 83 f8 e1 fe ff    	lea    -0x11e08(%ebx),%eax
f010080e:	50                   	push   %eax
f010080f:	8d 83 16 e2 fe ff    	lea    -0x11dea(%ebx),%eax
f0100815:	50                   	push   %eax
f0100816:	8d b3 1b e2 fe ff    	lea    -0x11de5(%ebx),%esi
f010081c:	56                   	push   %esi
f010081d:	e8 50 04 00 00       	call   f0100c72 <cprintf>
f0100822:	83 c4 0c             	add    $0xc,%esp
f0100825:	8d 83 e4 e2 fe ff    	lea    -0x11d1c(%ebx),%eax
f010082b:	50                   	push   %eax
f010082c:	8d 83 24 e2 fe ff    	lea    -0x11ddc(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	56                   	push   %esi
f0100834:	e8 39 04 00 00       	call   f0100c72 <cprintf>
f0100839:	83 c4 0c             	add    $0xc,%esp
f010083c:	8d 83 0c e3 fe ff    	lea    -0x11cf4(%ebx),%eax
f0100842:	50                   	push   %eax
f0100843:	8d 83 2d e2 fe ff    	lea    -0x11dd3(%ebx),%eax
f0100849:	50                   	push   %eax
f010084a:	56                   	push   %esi
f010084b:	e8 22 04 00 00       	call   f0100c72 <cprintf>
	return 0;
}
f0100850:	b8 00 00 00 00       	mov    $0x0,%eax
f0100855:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100858:	5b                   	pop    %ebx
f0100859:	5e                   	pop    %esi
f010085a:	5d                   	pop    %ebp
f010085b:	c3                   	ret    

f010085c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010085c:	55                   	push   %ebp
f010085d:	89 e5                	mov    %esp,%ebp
f010085f:	57                   	push   %edi
f0100860:	56                   	push   %esi
f0100861:	53                   	push   %ebx
f0100862:	83 ec 18             	sub    $0x18,%esp
f0100865:	e8 16 fa ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f010086a:	81 c3 fe 37 01 00    	add    $0x137fe,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100870:	8d 83 37 e2 fe ff    	lea    -0x11dc9(%ebx),%eax
f0100876:	50                   	push   %eax
f0100877:	e8 f6 03 00 00       	call   f0100c72 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010087c:	83 c4 08             	add    $0x8,%esp
f010087f:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100885:	8d 83 30 e3 fe ff    	lea    -0x11cd0(%ebx),%eax
f010088b:	50                   	push   %eax
f010088c:	e8 e1 03 00 00       	call   f0100c72 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100891:	83 c4 0c             	add    $0xc,%esp
f0100894:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010089a:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01008a0:	50                   	push   %eax
f01008a1:	57                   	push   %edi
f01008a2:	8d 83 58 e3 fe ff    	lea    -0x11ca8(%ebx),%eax
f01008a8:	50                   	push   %eax
f01008a9:	e8 c4 03 00 00       	call   f0100c72 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008ae:	83 c4 0c             	add    $0xc,%esp
f01008b1:	c7 c0 1f 1f 10 f0    	mov    $0xf0101f1f,%eax
f01008b7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01008bd:	52                   	push   %edx
f01008be:	50                   	push   %eax
f01008bf:	8d 83 7c e3 fe ff    	lea    -0x11c84(%ebx),%eax
f01008c5:	50                   	push   %eax
f01008c6:	e8 a7 03 00 00       	call   f0100c72 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008cb:	83 c4 0c             	add    $0xc,%esp
f01008ce:	c7 c0 80 40 11 f0    	mov    $0xf0114080,%eax
f01008d4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01008da:	52                   	push   %edx
f01008db:	50                   	push   %eax
f01008dc:	8d 83 a0 e3 fe ff    	lea    -0x11c60(%ebx),%eax
f01008e2:	50                   	push   %eax
f01008e3:	e8 8a 03 00 00       	call   f0100c72 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008e8:	83 c4 0c             	add    $0xc,%esp
f01008eb:	c7 c6 c0 46 11 f0    	mov    $0xf01146c0,%esi
f01008f1:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01008f7:	50                   	push   %eax
f01008f8:	56                   	push   %esi
f01008f9:	8d 83 c4 e3 fe ff    	lea    -0x11c3c(%ebx),%eax
f01008ff:	50                   	push   %eax
f0100900:	e8 6d 03 00 00       	call   f0100c72 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100905:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100908:	29 fe                	sub    %edi,%esi
f010090a:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100910:	c1 fe 0a             	sar    $0xa,%esi
f0100913:	56                   	push   %esi
f0100914:	8d 83 e8 e3 fe ff    	lea    -0x11c18(%ebx),%eax
f010091a:	50                   	push   %eax
f010091b:	e8 52 03 00 00       	call   f0100c72 <cprintf>
	return 0;
}
f0100920:	b8 00 00 00 00       	mov    $0x0,%eax
f0100925:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100928:	5b                   	pop    %ebx
f0100929:	5e                   	pop    %esi
f010092a:	5f                   	pop    %edi
f010092b:	5d                   	pop    %ebp
f010092c:	c3                   	ret    

f010092d <do_overflow>:
	return (val << 16)|(val >> 16);
}	

void
do_overflow(void)
{
f010092d:	55                   	push   %ebp
f010092e:	89 e5                	mov    %esp,%ebp
f0100930:	53                   	push   %ebx
f0100931:	83 ec 10             	sub    $0x10,%esp
f0100934:	e8 47 f9 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100939:	81 c3 2f 37 01 00    	add    $0x1372f,%ebx
    cprintf("Overflow success\n");
f010093f:	8d 83 50 e2 fe ff    	lea    -0x11db0(%ebx),%eax
f0100945:	50                   	push   %eax
f0100946:	e8 27 03 00 00       	call   f0100c72 <cprintf>
}
f010094b:	83 c4 10             	add    $0x10,%esp
f010094e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100951:	c9                   	leave  
f0100952:	c3                   	ret    

f0100953 <start_overflow>:

void
start_overflow(void)
{
f0100953:	55                   	push   %ebp
f0100954:	89 e5                	mov    %esp,%ebp
f0100956:	57                   	push   %edi
f0100957:	53                   	push   %ebx
f0100958:	81 ec 08 01 00 00    	sub    $0x108,%esp
f010095e:	e8 1d f9 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100963:	81 c3 05 37 01 00    	add    $0x13705,%ebx
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    	char str[256] = {};
f0100969:	8d bd f8 fe ff ff    	lea    -0x108(%ebp),%edi
f010096f:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100974:	b8 00 00 00 00       	mov    $0x0,%eax
f0100979:	f3 ab                	rep stos %eax,%es:(%edi)
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010097b:	8d 45 04             	lea    0x4(%ebp),%eax
    	int nstr = 0;
    	int pret_addr;
	pret_addr = read_pretaddr();
	// Your code here.
//	f010092d
	cprintf("000000000000000000000000000000000000000000000%n", str+268);
f010097e:	8d 45 04             	lea    0x4(%ebp),%eax
f0100981:	50                   	push   %eax
f0100982:	8d 83 14 e4 fe ff    	lea    -0x11bec(%ebx),%eax
f0100988:	50                   	push   %eax
f0100989:	e8 e4 02 00 00       	call   f0100c72 <cprintf>
	cprintf("000000000%n", str+269);
f010098e:	83 c4 08             	add    $0x8,%esp
f0100991:	8d 45 05             	lea    0x5(%ebp),%eax
f0100994:	50                   	push   %eax
f0100995:	8d 83 69 e2 fe ff    	lea    -0x11d97(%ebx),%eax
f010099b:	50                   	push   %eax
f010099c:	e8 d1 02 00 00       	call   f0100c72 <cprintf>
	cprintf("0000000000000000%n", str+270);
f01009a1:	83 c4 08             	add    $0x8,%esp
f01009a4:	8d 45 06             	lea    0x6(%ebp),%eax
f01009a7:	50                   	push   %eax
f01009a8:	8d bb 62 e2 fe ff    	lea    -0x11d9e(%ebx),%edi
f01009ae:	57                   	push   %edi
f01009af:	e8 be 02 00 00       	call   f0100c72 <cprintf>start_overflow
//	f0100a4f
	cprintf("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000%n", str + 272);
f01009b4:	83 c4 08             	add    $0x8,%esp
f01009b7:	8d 45 08             	lea    0x8(%ebp),%eax
f01009ba:	50                   	push   %eax
f01009bb:	8d 83 44 e4 fe ff    	lea    -0x11bbc(%ebx),%eax
f01009c1:	50                   	push   %eax
f01009c2:	e8 ab 02 00 00       	call   f0100c72 <cprintf>
	*(str + 272) = ~(*(str + 272));
f01009c7:	f6 55 08             	notb   0x8(%ebp)
	cprintf("0000000000%n", str + 273);
f01009ca:	83 c4 08             	add    $0x8,%esp
f01009cd:	8d 45 09             	lea    0x9(%ebp),%eax
f01009d0:	50                   	push   %eax
f01009d1:	8d 83 68 e2 fe ff    	lea    -0x11d98(%ebx),%eax
f01009d7:	50                   	push   %eax
f01009d8:	e8 95 02 00 00       	call   f0100c72 <cprintf>
	cprintf("0000000000000000%n", str + 274);
f01009dd:	83 c4 08             	add    $0x8,%esp
f01009e0:	8d 45 0a             	lea    0xa(%ebp),%eax
f01009e3:	50                   	push   %eax
f01009e4:	57                   	push   %edi
f01009e5:	e8 88 02 00 00       	call   f0100c72 <cprintf>
}
f01009ea:	83 c4 10             	add    $0x10,%esp
f01009ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009f0:	5b                   	pop    %ebx
f01009f1:	5f                   	pop    %edi
f01009f2:	5d                   	pop    %ebp
f01009f3:	c3                   	ret    

f01009f4 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009f4:	55                   	push   %ebp
f01009f5:	89 e5                	mov    %esp,%ebp
f01009f7:	57                   	push   %edi
f01009f8:	56                   	push   %esi
f01009f9:	53                   	push   %ebx
f01009fa:	83 ec 48             	sub    $0x48,%esp
f01009fd:	e8 7e f8 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100a02:	81 c3 66 36 01 00    	add    $0x13666,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f0100a08:	8d 83 75 e2 fe ff    	lea    -0x11d8b(%ebx),%eax
f0100a0e:	50                   	push   %eax
f0100a0f:	e8 5e 02 00 00       	call   f0100c72 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a14:	89 ee                	mov    %ebp,%esi
	int ebp, eip;
	ebp = read_ebp();
	struct Eipdebuginfo info;
	while (ebp != 0x0) {
f0100a16:	83 c4 10             	add    $0x10,%esp
		eip = *((int*)ebp + 1);
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n", 
f0100a19:	8d 83 c4 e4 fe ff    	lea    -0x11b3c(%ebx),%eax
f0100a1f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			eip, ebp, *((int*)ebp + 2), *((int*)ebp + 3),
			*((int*)ebp + 4), *((int*)ebp + 5), *((int*)ebp + 6));
		debuginfo_eip(eip, &info);
f0100a22:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a25:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (ebp != 0x0) {
f0100a28:	85 f6                	test   %esi,%esi
f0100a2a:	74 54                	je     f0100a80 <mon_backtrace+0x8c>
		eip = *((int*)ebp + 1);
f0100a2c:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n", 
f0100a2f:	ff 76 18             	pushl  0x18(%esi)
f0100a32:	ff 76 14             	pushl  0x14(%esi)
f0100a35:	ff 76 10             	pushl  0x10(%esi)
f0100a38:	ff 76 0c             	pushl  0xc(%esi)
f0100a3b:	ff 76 08             	pushl  0x8(%esi)
f0100a3e:	56                   	push   %esi
f0100a3f:	57                   	push   %edi
f0100a40:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100a43:	e8 2a 02 00 00       	call   f0100c72 <cprintf>
		debuginfo_eip(eip, &info);
f0100a48:	83 c4 18             	add    $0x18,%esp
f0100a4b:	ff 75 c0             	pushl  -0x40(%ebp)
f0100a4e:	57                   	push   %edi
f0100a4f:	e8 22 03 00 00       	call   f0100d76 <debuginfo_eip>
		*((char*)info.eip_fn_name + info.eip_fn_namelen) = '\0';
f0100a54:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a57:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a5a:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
		cprintf("\t%s:%d %s+%d\n", info.eip_file, info.eip_line, info.eip_fn_name, eip - info.eip_fn_addr);
f0100a5e:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100a61:	89 3c 24             	mov    %edi,(%esp)
f0100a64:	ff 75 d8             	pushl  -0x28(%ebp)
f0100a67:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100a6a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100a6d:	8d 83 87 e2 fe ff    	lea    -0x11d79(%ebx),%eax
f0100a73:	50                   	push   %eax
f0100a74:	e8 f9 01 00 00       	call   f0100c72 <cprintf>
		ebp = *((int*)ebp);
f0100a79:	8b 36                	mov    (%esi),%esi
f0100a7b:	83 c4 20             	add    $0x20,%esp
f0100a7e:	eb a8                	jmp    f0100a28 <mon_backtrace+0x34>
        start_overflow();
f0100a80:	e8 ce fe ff ff       	call   f0100953 <start_overflow>
	}
	overflow_me();
    	cprintf("Backtrace success\n");
f0100a85:	83 ec 0c             	sub    $0xc,%esp
f0100a88:	8d 83 95 e2 fe ff    	lea    -0x11d6b(%ebx),%eax
f0100a8e:	50                   	push   %eax
f0100a8f:	e8 de 01 00 00       	call   f0100c72 <cprintf>
	return 0;
}
f0100a94:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a9c:	5b                   	pop    %ebx
f0100a9d:	5e                   	pop    %esi
f0100a9e:	5f                   	pop    %edi
f0100a9f:	5d                   	pop    %ebp
f0100aa0:	c3                   	ret    

f0100aa1 <overflow_me>:
{
f0100aa1:	55                   	push   %ebp
f0100aa2:	89 e5                	mov    %esp,%ebp
f0100aa4:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100aa7:	e8 a7 fe ff ff       	call   f0100953 <start_overflow>
}
f0100aac:	c9                   	leave  
f0100aad:	c3                   	ret    

f0100aae <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100aae:	55                   	push   %ebp
f0100aaf:	89 e5                	mov    %esp,%ebp
f0100ab1:	57                   	push   %edi
f0100ab2:	56                   	push   %esi
f0100ab3:	53                   	push   %ebx
f0100ab4:	83 ec 68             	sub    $0x68,%esp
f0100ab7:	e8 c4 f7 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100abc:	81 c3 ac 35 01 00    	add    $0x135ac,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ac2:	8d 83 fc e4 fe ff    	lea    -0x11b04(%ebx),%eax
f0100ac8:	50                   	push   %eax
f0100ac9:	e8 a4 01 00 00       	call   f0100c72 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ace:	8d 83 20 e5 fe ff    	lea    -0x11ae0(%ebx),%eax
f0100ad4:	89 04 24             	mov    %eax,(%esp)
f0100ad7:	e8 96 01 00 00       	call   f0100c72 <cprintf>
f0100adc:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100adf:	8d 83 ac e2 fe ff    	lea    -0x11d54(%ebx),%eax
f0100ae5:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0100ae8:	e9 d1 00 00 00       	jmp    f0100bbe <monitor+0x110>
f0100aed:	83 ec 08             	sub    $0x8,%esp
f0100af0:	0f be c0             	movsbl %al,%eax
f0100af3:	50                   	push   %eax
f0100af4:	ff 75 a0             	pushl  -0x60(%ebp)
f0100af7:	e8 a7 0f 00 00       	call   f0101aa3 <strchr>
f0100afc:	83 c4 10             	add    $0x10,%esp
f0100aff:	85 c0                	test   %eax,%eax
f0100b01:	74 6d                	je     f0100b70 <monitor+0xc2>
			*buf++ = 0;
f0100b03:	c6 06 00             	movb   $0x0,(%esi)
f0100b06:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100b09:	8d 76 01             	lea    0x1(%esi),%esi
f0100b0c:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100b0f:	0f b6 06             	movzbl (%esi),%eax
f0100b12:	84 c0                	test   %al,%al
f0100b14:	75 d7                	jne    f0100aed <monitor+0x3f>
	argv[argc] = 0;
f0100b16:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100b1d:	00 
	if (argc == 0)
f0100b1e:	85 ff                	test   %edi,%edi
f0100b20:	0f 84 98 00 00 00    	je     f0100bbe <monitor+0x110>
f0100b26:	8d b3 b8 ff ff ff    	lea    -0x48(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b31:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100b34:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b36:	83 ec 08             	sub    $0x8,%esp
f0100b39:	ff 36                	pushl  (%esi)
f0100b3b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b3e:	e8 02 0f 00 00       	call   f0101a45 <strcmp>
f0100b43:	83 c4 10             	add    $0x10,%esp
f0100b46:	85 c0                	test   %eax,%eax
f0100b48:	0f 84 99 00 00 00    	je     f0100be7 <monitor+0x139>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b4e:	83 c7 01             	add    $0x1,%edi
f0100b51:	83 c6 0c             	add    $0xc,%esi
f0100b54:	83 ff 03             	cmp    $0x3,%edi
f0100b57:	75 dd                	jne    f0100b36 <monitor+0x88>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b59:	83 ec 08             	sub    $0x8,%esp
f0100b5c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b5f:	8d 83 ce e2 fe ff    	lea    -0x11d32(%ebx),%eax
f0100b65:	50                   	push   %eax
f0100b66:	e8 07 01 00 00       	call   f0100c72 <cprintf>
f0100b6b:	83 c4 10             	add    $0x10,%esp
f0100b6e:	eb 4e                	jmp    f0100bbe <monitor+0x110>
		if (*buf == 0)
f0100b70:	80 3e 00             	cmpb   $0x0,(%esi)
f0100b73:	74 a1                	je     f0100b16 <monitor+0x68>
		if (argc == MAXARGS-1) {
f0100b75:	83 ff 0f             	cmp    $0xf,%edi
f0100b78:	74 30                	je     f0100baa <monitor+0xfc>
		argv[argc++] = buf;
f0100b7a:	8d 47 01             	lea    0x1(%edi),%eax
f0100b7d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100b80:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b84:	0f b6 06             	movzbl (%esi),%eax
f0100b87:	84 c0                	test   %al,%al
f0100b89:	74 81                	je     f0100b0c <monitor+0x5e>
f0100b8b:	83 ec 08             	sub    $0x8,%esp
f0100b8e:	0f be c0             	movsbl %al,%eax
f0100b91:	50                   	push   %eax
f0100b92:	ff 75 a0             	pushl  -0x60(%ebp)
f0100b95:	e8 09 0f 00 00       	call   f0101aa3 <strchr>
f0100b9a:	83 c4 10             	add    $0x10,%esp
f0100b9d:	85 c0                	test   %eax,%eax
f0100b9f:	0f 85 67 ff ff ff    	jne    f0100b0c <monitor+0x5e>
			buf++;
f0100ba5:	83 c6 01             	add    $0x1,%esi
f0100ba8:	eb da                	jmp    f0100b84 <monitor+0xd6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100baa:	83 ec 08             	sub    $0x8,%esp
f0100bad:	6a 10                	push   $0x10
f0100baf:	8d 83 b1 e2 fe ff    	lea    -0x11d4f(%ebx),%eax
f0100bb5:	50                   	push   %eax
f0100bb6:	e8 b7 00 00 00       	call   f0100c72 <cprintf>
f0100bbb:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100bbe:	8d bb a8 e2 fe ff    	lea    -0x11d58(%ebx),%edi
f0100bc4:	83 ec 0c             	sub    $0xc,%esp
f0100bc7:	57                   	push   %edi
f0100bc8:	e8 97 0c 00 00       	call   f0101864 <readline>
		if (buf != NULL)
f0100bcd:	83 c4 10             	add    $0x10,%esp
f0100bd0:	85 c0                	test   %eax,%eax
f0100bd2:	74 f0                	je     f0100bc4 <monitor+0x116>
f0100bd4:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100bd6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100bdd:	bf 00 00 00 00       	mov    $0x0,%edi
f0100be2:	e9 28 ff ff ff       	jmp    f0100b0f <monitor+0x61>
f0100be7:	89 f8                	mov    %edi,%eax
f0100be9:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100bec:	83 ec 04             	sub    $0x4,%esp
f0100bef:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100bf2:	ff 75 08             	pushl  0x8(%ebp)
f0100bf5:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bf8:	52                   	push   %edx
f0100bf9:	57                   	push   %edi
f0100bfa:	ff 94 83 c0 ff ff ff 	call   *-0x40(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100c01:	83 c4 10             	add    $0x10,%esp
f0100c04:	85 c0                	test   %eax,%eax
f0100c06:	79 b6                	jns    f0100bbe <monitor+0x110>
				break;
	}
}
f0100c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c0b:	5b                   	pop    %ebx
f0100c0c:	5e                   	pop    %esi
f0100c0d:	5f                   	pop    %edi
f0100c0e:	5d                   	pop    %ebp
f0100c0f:	c3                   	ret    

f0100c10 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100c10:	55                   	push   %ebp
f0100c11:	89 e5                	mov    %esp,%ebp
f0100c13:	56                   	push   %esi
f0100c14:	53                   	push   %ebx
f0100c15:	e8 66 f6 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100c1a:	81 c3 4e 34 01 00    	add    $0x1344e,%ebx
f0100c20:	8b 75 0c             	mov    0xc(%ebp),%esi
	cputchar(ch);
f0100c23:	83 ec 0c             	sub    $0xc,%esp
f0100c26:	ff 75 08             	pushl  0x8(%ebp)
f0100c29:	e8 9c fb ff ff       	call   f01007ca <cputchar>
	(*cnt)++;
f0100c2e:	83 06 01             	addl   $0x1,(%esi)
}
f0100c31:	83 c4 10             	add    $0x10,%esp
f0100c34:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c37:	5b                   	pop    %ebx
f0100c38:	5e                   	pop    %esi
f0100c39:	5d                   	pop    %ebp
f0100c3a:	c3                   	ret    

f0100c3b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100c3b:	55                   	push   %ebp
f0100c3c:	89 e5                	mov    %esp,%ebp
f0100c3e:	53                   	push   %ebx
f0100c3f:	83 ec 14             	sub    $0x14,%esp
f0100c42:	e8 39 f6 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100c47:	81 c3 21 34 01 00    	add    $0x13421,%ebx
	int cnt = 0;
f0100c4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100c54:	ff 75 0c             	pushl  0xc(%ebp)
f0100c57:	ff 75 08             	pushl  0x8(%ebp)
f0100c5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c5d:	50                   	push   %eax
f0100c5e:	8d 83 a8 cb fe ff    	lea    -0x13458(%ebx),%eax
f0100c64:	50                   	push   %eax
f0100c65:	e8 d1 05 00 00       	call   f010123b <vprintfmt>
	return cnt;
}
f0100c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c70:	c9                   	leave  
f0100c71:	c3                   	ret    

f0100c72 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100c72:	55                   	push   %ebp
f0100c73:	89 e5                	mov    %esp,%ebp
f0100c75:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100c78:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c7b:	50                   	push   %eax
f0100c7c:	ff 75 08             	pushl  0x8(%ebp)
f0100c7f:	e8 b7 ff ff ff       	call   f0100c3b <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c84:	c9                   	leave  
f0100c85:	c3                   	ret    

f0100c86 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c86:	55                   	push   %ebp
f0100c87:	89 e5                	mov    %esp,%ebp
f0100c89:	57                   	push   %edi
f0100c8a:	56                   	push   %esi
f0100c8b:	53                   	push   %ebx
f0100c8c:	83 ec 14             	sub    $0x14,%esp
f0100c8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c95:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c98:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c9b:	8b 1a                	mov    (%edx),%ebx
f0100c9d:	8b 01                	mov    (%ecx),%eax
f0100c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ca2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100ca9:	eb 23                	jmp    f0100cce <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100cab:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100cae:	eb 1e                	jmp    f0100cce <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100cb0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cb3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100cb6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100cba:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100cbd:	73 41                	jae    f0100d00 <stab_binsearch+0x7a>
			*region_left = m;
f0100cbf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100cc2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100cc4:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100cc7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100cce:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100cd1:	7f 5a                	jg     f0100d2d <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100cd6:	01 d8                	add    %ebx,%eax
f0100cd8:	89 c7                	mov    %eax,%edi
f0100cda:	c1 ef 1f             	shr    $0x1f,%edi
f0100cdd:	01 c7                	add    %eax,%edi
f0100cdf:	d1 ff                	sar    %edi
f0100ce1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100ce4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ce7:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100ceb:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ced:	39 c3                	cmp    %eax,%ebx
f0100cef:	7f ba                	jg     f0100cab <stab_binsearch+0x25>
f0100cf1:	0f b6 0a             	movzbl (%edx),%ecx
f0100cf4:	83 ea 0c             	sub    $0xc,%edx
f0100cf7:	39 f1                	cmp    %esi,%ecx
f0100cf9:	74 b5                	je     f0100cb0 <stab_binsearch+0x2a>
			m--;
f0100cfb:	83 e8 01             	sub    $0x1,%eax
f0100cfe:	eb ed                	jmp    f0100ced <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0100d00:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100d03:	76 14                	jbe    f0100d19 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100d05:	83 e8 01             	sub    $0x1,%eax
f0100d08:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100d0b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d0e:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100d10:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100d17:	eb b5                	jmp    f0100cce <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100d19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d1c:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100d1e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100d22:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100d24:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100d2b:	eb a1                	jmp    f0100cce <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100d2d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100d31:	75 15                	jne    f0100d48 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d36:	8b 00                	mov    (%eax),%eax
f0100d38:	83 e8 01             	sub    $0x1,%eax
f0100d3b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100d3e:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100d40:	83 c4 14             	add    $0x14,%esp
f0100d43:	5b                   	pop    %ebx
f0100d44:	5e                   	pop    %esi
f0100d45:	5f                   	pop    %edi
f0100d46:	5d                   	pop    %ebp
f0100d47:	c3                   	ret    
		for (l = *region_right;
f0100d48:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d4b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d50:	8b 0f                	mov    (%edi),%ecx
f0100d52:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d55:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100d58:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100d5c:	eb 03                	jmp    f0100d61 <stab_binsearch+0xdb>
		     l--)
f0100d5e:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100d61:	39 c1                	cmp    %eax,%ecx
f0100d63:	7d 0a                	jge    f0100d6f <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100d65:	0f b6 1a             	movzbl (%edx),%ebx
f0100d68:	83 ea 0c             	sub    $0xc,%edx
f0100d6b:	39 f3                	cmp    %esi,%ebx
f0100d6d:	75 ef                	jne    f0100d5e <stab_binsearch+0xd8>
		*region_left = l;
f0100d6f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d72:	89 06                	mov    %eax,(%esi)
}
f0100d74:	eb ca                	jmp    f0100d40 <stab_binsearch+0xba>

f0100d76 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100d76:	55                   	push   %ebp
f0100d77:	89 e5                	mov    %esp,%ebp
f0100d79:	57                   	push   %edi
f0100d7a:	56                   	push   %esi
f0100d7b:	53                   	push   %ebx
f0100d7c:	83 ec 3c             	sub    $0x3c,%esp
f0100d7f:	e8 fc f4 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0100d84:	81 c3 e4 32 01 00    	add    $0x132e4,%ebx
f0100d8a:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0100d8d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100d90:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d93:	8d 83 45 e5 fe ff    	lea    -0x11abb(%ebx),%eax
f0100d99:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100d9b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100da2:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100da5:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100dac:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100daf:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100db6:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100dbc:	0f 86 57 01 00 00    	jbe    f0100f19 <debuginfo_eip+0x1a3>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100dc2:	c7 c0 79 6f 10 f0    	mov    $0xf0106f79,%eax
f0100dc8:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100dce:	0f 86 19 02 00 00    	jbe    f0100fed <debuginfo_eip+0x277>
f0100dd4:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100dd7:	c7 c0 21 8a 10 f0    	mov    $0xf0108a21,%eax
f0100ddd:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100de1:	0f 85 0d 02 00 00    	jne    f0100ff4 <debuginfo_eip+0x27e>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100de7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100dee:	c7 c0 44 28 10 f0    	mov    $0xf0102844,%eax
f0100df4:	c7 c2 78 6f 10 f0    	mov    $0xf0106f78,%edx
f0100dfa:	29 c2                	sub    %eax,%edx
f0100dfc:	c1 fa 02             	sar    $0x2,%edx
f0100dff:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100e05:	83 ea 01             	sub    $0x1,%edx
f0100e08:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100e0b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100e0e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100e11:	83 ec 08             	sub    $0x8,%esp
f0100e14:	57                   	push   %edi
f0100e15:	6a 64                	push   $0x64
f0100e17:	e8 6a fe ff ff       	call   f0100c86 <stab_binsearch>
	if (lfile == 0)
f0100e1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e1f:	83 c4 10             	add    $0x10,%esp
f0100e22:	85 c0                	test   %eax,%eax
f0100e24:	0f 84 d1 01 00 00    	je     f0100ffb <debuginfo_eip+0x285>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100e2a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100e2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e30:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100e33:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100e36:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e39:	83 ec 08             	sub    $0x8,%esp
f0100e3c:	57                   	push   %edi
f0100e3d:	6a 24                	push   $0x24
f0100e3f:	c7 c0 44 28 10 f0    	mov    $0xf0102844,%eax
f0100e45:	e8 3c fe ff ff       	call   f0100c86 <stab_binsearch>

	if (lfun <= rfun) {
f0100e4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e4d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e50:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100e53:	83 c4 10             	add    $0x10,%esp
f0100e56:	39 c8                	cmp    %ecx,%eax
f0100e58:	0f 8f d6 00 00 00    	jg     f0100f34 <debuginfo_eip+0x1be>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100e5e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e61:	c7 c1 44 28 10 f0    	mov    $0xf0102844,%ecx
f0100e67:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100e6a:	8b 11                	mov    (%ecx),%edx
f0100e6c:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100e6f:	c7 c2 21 8a 10 f0    	mov    $0xf0108a21,%edx
f0100e75:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0100e78:	81 ea 79 6f 10 f0    	sub    $0xf0106f79,%edx
f0100e7e:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0100e81:	39 d3                	cmp    %edx,%ebx
f0100e83:	73 0c                	jae    f0100e91 <debuginfo_eip+0x11b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e85:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100e88:	81 c3 79 6f 10 f0    	add    $0xf0106f79,%ebx
f0100e8e:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e91:	8b 51 08             	mov    0x8(%ecx),%edx
f0100e94:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100e97:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100e99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100e9c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100e9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ea2:	83 ec 08             	sub    $0x8,%esp
f0100ea5:	6a 3a                	push   $0x3a
f0100ea7:	ff 76 08             	pushl  0x8(%esi)
f0100eaa:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100ead:	e8 12 0c 00 00       	call   f0101ac4 <strfind>
f0100eb2:	2b 46 08             	sub    0x8(%esi),%eax
f0100eb5:	89 46 0c             	mov    %eax,0xc(%esi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100eb8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ebb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ebe:	83 c4 08             	add    $0x8,%esp
f0100ec1:	57                   	push   %edi
f0100ec2:	6a 44                	push   $0x44
f0100ec4:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100ec7:	c7 c0 44 28 10 f0    	mov    $0xf0102844,%eax
f0100ecd:	e8 b4 fd ff ff       	call   f0100c86 <stab_binsearch>
	if (lline > rline)
f0100ed2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100ed5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100ed8:	83 c4 10             	add    $0x10,%esp
f0100edb:	39 d9                	cmp    %ebx,%ecx
f0100edd:	0f 8f 1f 01 00 00    	jg     f0101002 <debuginfo_eip+0x28c>
		return -1;
	info->eip_line = (rline % 50);
f0100ee3:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
f0100ee8:	89 d8                	mov    %ebx,%eax
f0100eea:	f7 ea                	imul   %edx
f0100eec:	c1 fa 04             	sar    $0x4,%edx
f0100eef:	89 df                	mov    %ebx,%edi
f0100ef1:	c1 ff 1f             	sar    $0x1f,%edi
f0100ef4:	29 fa                	sub    %edi,%edx
f0100ef6:	6b d2 32             	imul   $0x32,%edx,%edx
f0100ef9:	29 d3                	sub    %edx,%ebx
f0100efb:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100efe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f01:	89 c8                	mov    %ecx,%eax
f0100f03:	8d 0c 49             	lea    (%ecx,%ecx,2),%ecx
f0100f06:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100f09:	c7 c2 44 28 10 f0    	mov    $0xf0102844,%edx
f0100f0f:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100f13:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100f17:	eb 39                	jmp    f0100f52 <debuginfo_eip+0x1dc>
  	        panic("User address");
f0100f19:	83 ec 04             	sub    $0x4,%esp
f0100f1c:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100f1f:	8d 83 4f e5 fe ff    	lea    -0x11ab1(%ebx),%eax
f0100f25:	50                   	push   %eax
f0100f26:	6a 7f                	push   $0x7f
f0100f28:	8d 83 5c e5 fe ff    	lea    -0x11aa4(%ebx),%eax
f0100f2e:	50                   	push   %eax
f0100f2f:	e8 96 f2 ff ff       	call   f01001ca <_panic>
		info->eip_fn_addr = addr;
f0100f34:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f40:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f43:	e9 5a ff ff ff       	jmp    f0100ea2 <debuginfo_eip+0x12c>
f0100f48:	83 e8 01             	sub    $0x1,%eax
f0100f4b:	83 ea 0c             	sub    $0xc,%edx
f0100f4e:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100f52:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100f55:	39 c7                	cmp    %eax,%edi
f0100f57:	7f 51                	jg     f0100faa <debuginfo_eip+0x234>
	       && stabs[lline].n_type != N_SOL
f0100f59:	0f b6 0a             	movzbl (%edx),%ecx
f0100f5c:	80 f9 84             	cmp    $0x84,%cl
f0100f5f:	74 19                	je     f0100f7a <debuginfo_eip+0x204>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100f61:	80 f9 64             	cmp    $0x64,%cl
f0100f64:	75 e2                	jne    f0100f48 <debuginfo_eip+0x1d2>
f0100f66:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100f6a:	74 dc                	je     f0100f48 <debuginfo_eip+0x1d2>
f0100f6c:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100f70:	74 11                	je     f0100f83 <debuginfo_eip+0x20d>
f0100f72:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100f75:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f78:	eb 09                	jmp    f0100f83 <debuginfo_eip+0x20d>
f0100f7a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100f7e:	74 03                	je     f0100f83 <debuginfo_eip+0x20d>
f0100f80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f83:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100f86:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100f89:	c7 c0 44 28 10 f0    	mov    $0xf0102844,%eax
f0100f8f:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100f92:	c7 c0 21 8a 10 f0    	mov    $0xf0108a21,%eax
f0100f98:	81 e8 79 6f 10 f0    	sub    $0xf0106f79,%eax
f0100f9e:	39 c2                	cmp    %eax,%edx
f0100fa0:	73 08                	jae    f0100faa <debuginfo_eip+0x234>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100fa2:	81 c2 79 6f 10 f0    	add    $0xf0106f79,%edx
f0100fa8:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100faa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fad:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100fb0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100fb5:	39 da                	cmp    %ebx,%edx
f0100fb7:	7d 55                	jge    f010100e <debuginfo_eip+0x298>
		for (lline = lfun + 1;
f0100fb9:	83 c2 01             	add    $0x1,%edx
f0100fbc:	89 d0                	mov    %edx,%eax
f0100fbe:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100fc1:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100fc4:	c7 c2 44 28 10 f0    	mov    $0xf0102844,%edx
f0100fca:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100fce:	eb 04                	jmp    f0100fd4 <debuginfo_eip+0x25e>
			info->eip_fn_narg++;
f0100fd0:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100fd4:	39 c3                	cmp    %eax,%ebx
f0100fd6:	7e 31                	jle    f0101009 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100fd8:	0f b6 0a             	movzbl (%edx),%ecx
f0100fdb:	83 c0 01             	add    $0x1,%eax
f0100fde:	83 c2 0c             	add    $0xc,%edx
f0100fe1:	80 f9 a0             	cmp    $0xa0,%cl
f0100fe4:	74 ea                	je     f0100fd0 <debuginfo_eip+0x25a>
	return 0;
f0100fe6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100feb:	eb 21                	jmp    f010100e <debuginfo_eip+0x298>
		return -1;
f0100fed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ff2:	eb 1a                	jmp    f010100e <debuginfo_eip+0x298>
f0100ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ff9:	eb 13                	jmp    f010100e <debuginfo_eip+0x298>
		return -1;
f0100ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101000:	eb 0c                	jmp    f010100e <debuginfo_eip+0x298>
		return -1;
f0101002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101007:	eb 05                	jmp    f010100e <debuginfo_eip+0x298>
	return 0;
f0101009:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010100e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101011:	5b                   	pop    %ebx
f0101012:	5e                   	pop    %esi
f0101013:	5f                   	pop    %edi
f0101014:	5d                   	pop    %ebp
f0101015:	c3                   	ret    

f0101016 <printsign>:
 * using specified putch function and associated pointer putdat.
 */

static int
printsign(void(*putch)(int, void*), void *putdat,
	unsigned long long num, unsigned base, int width, unsigned long long origin) {
f0101016:	55                   	push   %ebp
f0101017:	89 e5                	mov    %esp,%ebp
f0101019:	57                   	push   %edi
f010101a:	56                   	push   %esi
f010101b:	53                   	push   %ebx
f010101c:	83 ec 2c             	sub    $0x2c,%esp
f010101f:	e8 5c f2 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0101024:	81 c3 44 30 01 00    	add    $0x13044,%ebx
f010102a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010102d:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0101030:	8b 55 08             	mov    0x8(%ebp),%edx
f0101033:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101036:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101039:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010103c:	8b 45 10             	mov    0x10(%ebp),%eax
f010103f:	8b 75 18             	mov    0x18(%ebp),%esi
f0101042:	8b 7d 1c             	mov    0x1c(%ebp),%edi
f0101045:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0101048:	89 7d cc             	mov    %edi,-0x34(%ebp)
	if (num >= base) {
f010104b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010104e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101055:	39 c2                	cmp    %eax,%edx
f0101057:	89 ce                	mov    %ecx,%esi
f0101059:	1b 75 e4             	sbb    -0x1c(%ebp),%esi
f010105c:	73 4f                	jae    f01010ad <printsign+0x97>
		width = printsign(putch, putdat, num / base, base, width - 1, origin);
	}
	putch("0123456789abcdef"[num % base], putdat);
f010105e:	83 ec 08             	sub    $0x8,%esp
f0101061:	ff 75 d8             	pushl  -0x28(%ebp)
f0101064:	83 ec 04             	sub    $0x4,%esp
f0101067:	ff 75 e4             	pushl  -0x1c(%ebp)
f010106a:	ff 75 e0             	pushl  -0x20(%ebp)
f010106d:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101070:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101073:	57                   	push   %edi
f0101074:	56                   	push   %esi
f0101075:	e8 66 0d 00 00       	call   f0101de0 <__umoddi3>
f010107a:	83 c4 14             	add    $0x14,%esp
f010107d:	0f be 84 03 6a e5 fe 	movsbl -0x11a96(%ebx,%eax,1),%eax
f0101084:	ff 
f0101085:	50                   	push   %eax
f0101086:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101089:	ff d0                	call   *%eax
	if (num == origin) {
f010108b:	83 c4 10             	add    $0x10,%esp
f010108e:	89 fb                	mov    %edi,%ebx
f0101090:	89 f0                	mov    %esi,%eax
f0101092:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0101095:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101098:	31 f0                	xor    %esi,%eax
f010109a:	89 da                	mov    %ebx,%edx
f010109c:	31 fa                	xor    %edi,%edx
f010109e:	09 c2                	or     %eax,%edx
f01010a0:	74 4b                	je     f01010ed <printsign+0xd7>
		while (--width > 0) {
			putch(' ', putdat);//当显示需要左对齐时，给右边补上padc
		}
	}
	return width;
}
f01010a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010a8:	5b                   	pop    %ebx
f01010a9:	5e                   	pop    %esi
f01010aa:	5f                   	pop    %edi
f01010ab:	5d                   	pop    %ebp
f01010ac:	c3                   	ret    
		width = printsign(putch, putdat, num / base, base, width - 1, origin);
f01010ad:	8b 7d 14             	mov    0x14(%ebp),%edi
f01010b0:	8d 57 ff             	lea    -0x1(%edi),%edx
f01010b3:	83 ec 08             	sub    $0x8,%esp
f01010b6:	ff 75 cc             	pushl  -0x34(%ebp)
f01010b9:	ff 75 c8             	pushl  -0x38(%ebp)
f01010bc:	52                   	push   %edx
f01010bd:	50                   	push   %eax
f01010be:	83 ec 08             	sub    $0x8,%esp
f01010c1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01010c4:	ff 75 e0             	pushl  -0x20(%ebp)
f01010c7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01010ca:	ff 75 d0             	pushl  -0x30(%ebp)
f01010cd:	e8 fe 0b 00 00       	call   f0101cd0 <__udivdi3>
f01010d2:	83 c4 18             	add    $0x18,%esp
f01010d5:	52                   	push   %edx
f01010d6:	50                   	push   %eax
f01010d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010da:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010dd:	e8 34 ff ff ff       	call   f0101016 <printsign>
f01010e2:	89 45 14             	mov    %eax,0x14(%ebp)
f01010e5:	83 c4 20             	add    $0x20,%esp
f01010e8:	e9 71 ff ff ff       	jmp    f010105e <printsign+0x48>
f01010ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01010f0:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01010f3:	8b 7d d8             	mov    -0x28(%ebp),%edi
		while (--width > 0) {
f01010f6:	83 eb 01             	sub    $0x1,%ebx
f01010f9:	85 db                	test   %ebx,%ebx
f01010fb:	7e 0d                	jle    f010110a <printsign+0xf4>
			putch(' ', putdat);//当显示需要左对齐时，给右边补上padc
f01010fd:	83 ec 08             	sub    $0x8,%esp
f0101100:	57                   	push   %edi
f0101101:	6a 20                	push   $0x20
f0101103:	ff d6                	call   *%esi
f0101105:	83 c4 10             	add    $0x10,%esp
f0101108:	eb ec                	jmp    f01010f6 <printsign+0xe0>
f010110a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f010110e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101113:	0f 4f 45 14          	cmovg  0x14(%ebp),%eax
f0101117:	29 45 14             	sub    %eax,0x14(%ebp)
f010111a:	eb 86                	jmp    f01010a2 <printsign+0x8c>

f010111c <printnum>:

static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010111c:	55                   	push   %ebp
f010111d:	89 e5                	mov    %esp,%ebp
f010111f:	57                   	push   %edi
f0101120:	56                   	push   %esi
f0101121:	53                   	push   %ebx
f0101122:	83 ec 2c             	sub    $0x2c,%esp
f0101125:	e8 36 07 00 00       	call   f0101860 <__x86.get_pc_thunk.di>
f010112a:	81 c7 3e 2f 01 00    	add    $0x12f3e,%edi
f0101130:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101133:	89 c7                	mov    %eax,%edi
f0101135:	89 d6                	mov    %edx,%esi
f0101137:	8b 55 08             	mov    0x8(%ebp),%edx
f010113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010113d:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0101140:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101143:	8b 45 10             	mov    0x10(%ebp),%eax
f0101146:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:

	if (padc != '-') {
f0101149:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f010114d:	0f 84 91 00 00 00    	je     f01011e4 <printnum+0xc8>
		if (num >= base) {
f0101153:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101156:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010115d:	39 c2                	cmp    %eax,%edx
f010115f:	89 ca                	mov    %ecx,%edx
f0101161:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
f0101164:	73 15                	jae    f010117b <printnum+0x5f>
			printnum(putch, putdat, num / base, base, width - 1, padc);
		}
		else {
			// print any needed pad characters before first digit
			while (--width > 0) {
f0101166:	83 eb 01             	sub    $0x1,%ebx
f0101169:	85 db                	test   %ebx,%ebx
f010116b:	7e 41                	jle    f01011ae <printnum+0x92>
				putch(padc, putdat);//当显示需要右对齐时，应该先把左边补上padc
f010116d:	83 ec 08             	sub    $0x8,%esp
f0101170:	56                   	push   %esi
f0101171:	ff 75 18             	pushl  0x18(%ebp)
f0101174:	ff d7                	call   *%edi
f0101176:	83 c4 10             	add    $0x10,%esp
f0101179:	eb eb                	jmp    f0101166 <printnum+0x4a>
			printnum(putch, putdat, num / base, base, width - 1, padc);
f010117b:	83 ec 0c             	sub    $0xc,%esp
f010117e:	ff 75 18             	pushl  0x18(%ebp)
f0101181:	83 eb 01             	sub    $0x1,%ebx
f0101184:	53                   	push   %ebx
f0101185:	50                   	push   %eax
f0101186:	83 ec 08             	sub    $0x8,%esp
f0101189:	ff 75 e4             	pushl  -0x1c(%ebp)
f010118c:	ff 75 e0             	pushl  -0x20(%ebp)
f010118f:	ff 75 dc             	pushl  -0x24(%ebp)
f0101192:	ff 75 d8             	pushl  -0x28(%ebp)
f0101195:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101198:	e8 33 0b 00 00       	call   f0101cd0 <__udivdi3>
f010119d:	83 c4 18             	add    $0x18,%esp
f01011a0:	52                   	push   %edx
f01011a1:	50                   	push   %eax
f01011a2:	89 f2                	mov    %esi,%edx
f01011a4:	89 f8                	mov    %edi,%eax
f01011a6:	e8 71 ff ff ff       	call   f010111c <printnum>
f01011ab:	83 c4 20             	add    $0x20,%esp
			}
		}
		// then print this (the least significant) digit
		putch("0123456789abcdef"[num % base], putdat);
f01011ae:	83 ec 08             	sub    $0x8,%esp
f01011b1:	56                   	push   %esi
f01011b2:	83 ec 04             	sub    $0x4,%esp
f01011b5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01011b8:	ff 75 e0             	pushl  -0x20(%ebp)
f01011bb:	ff 75 dc             	pushl  -0x24(%ebp)
f01011be:	ff 75 d8             	pushl  -0x28(%ebp)
f01011c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01011c4:	89 f3                	mov    %esi,%ebx
f01011c6:	e8 15 0c 00 00       	call   f0101de0 <__umoddi3>
f01011cb:	83 c4 14             	add    $0x14,%esp
f01011ce:	0f be 84 06 6a e5 fe 	movsbl -0x11a96(%esi,%eax,1),%eax
f01011d5:	ff 
f01011d6:	50                   	push   %eax
f01011d7:	ff d7                	call   *%edi
f01011d9:	83 c4 10             	add    $0x10,%esp
	}
	else {
		printsign(putch, putdat, num, base, width, num);
	}
}
f01011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011df:	5b                   	pop    %ebx
f01011e0:	5e                   	pop    %esi
f01011e1:	5f                   	pop    %edi
f01011e2:	5d                   	pop    %ebp
f01011e3:	c3                   	ret    
		printsign(putch, putdat, num, base, width, num);
f01011e4:	83 ec 08             	sub    $0x8,%esp
f01011e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01011ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01011ed:	51                   	push   %ecx
f01011ee:	52                   	push   %edx
f01011ef:	53                   	push   %ebx
f01011f0:	50                   	push   %eax
f01011f1:	51                   	push   %ecx
f01011f2:	52                   	push   %edx
f01011f3:	89 f2                	mov    %esi,%edx
f01011f5:	89 f8                	mov    %edi,%eax
f01011f7:	e8 1a fe ff ff       	call   f0101016 <printsign>
f01011fc:	83 c4 20             	add    $0x20,%esp
}
f01011ff:	eb db                	jmp    f01011dc <printnum+0xc0>

f0101201 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101201:	55                   	push   %ebp
f0101202:	89 e5                	mov    %esp,%ebp
f0101204:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101207:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010120b:	8b 10                	mov    (%eax),%edx
f010120d:	3b 50 04             	cmp    0x4(%eax),%edx
f0101210:	73 0a                	jae    f010121c <sprintputch+0x1b>
		*b->buf++ = ch;
f0101212:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101215:	89 08                	mov    %ecx,(%eax)
f0101217:	8b 45 08             	mov    0x8(%ebp),%eax
f010121a:	88 02                	mov    %al,(%edx)
}
f010121c:	5d                   	pop    %ebp
f010121d:	c3                   	ret    

f010121e <printfmt>:
{
f010121e:	55                   	push   %ebp
f010121f:	89 e5                	mov    %esp,%ebp
f0101221:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0101224:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101227:	50                   	push   %eax
f0101228:	ff 75 10             	pushl  0x10(%ebp)
f010122b:	ff 75 0c             	pushl  0xc(%ebp)
f010122e:	ff 75 08             	pushl  0x8(%ebp)
f0101231:	e8 05 00 00 00       	call   f010123b <vprintfmt>
}
f0101236:	83 c4 10             	add    $0x10,%esp
f0101239:	c9                   	leave  
f010123a:	c3                   	ret    

f010123b <vprintfmt>:
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	57                   	push   %edi
f010123f:	56                   	push   %esi
f0101240:	53                   	push   %ebx
f0101241:	83 ec 3c             	sub    $0x3c,%esp
f0101244:	e8 37 f0 ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0101249:	81 c3 1f 2e 01 00    	add    $0x12e1f,%ebx
f010124f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101252:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101255:	e9 4b 04 00 00       	jmp    f01016a5 <.L38+0x55>
		sflag = 0;
f010125a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		padc = ' ';
f0101261:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0101265:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f010126c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0101273:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010127a:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101281:	8d 47 01             	lea    0x1(%edi),%eax
f0101284:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101287:	0f b6 17             	movzbl (%edi),%edx
f010128a:	8d 42 dd             	lea    -0x23(%edx),%eax
f010128d:	3c 55                	cmp    $0x55,%al
f010128f:	0f 87 29 05 00 00    	ja     f01017be <.L33>
f0101295:	0f b6 c0             	movzbl %al,%eax
f0101298:	89 d9                	mov    %ebx,%ecx
f010129a:	03 8c 83 74 e6 fe ff 	add    -0x1198c(%ebx,%eax,4),%ecx
f01012a1:	ff e1                	jmp    *%ecx

f01012a3 <.L84>:
f01012a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01012a6:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01012aa:	eb d5                	jmp    f0101281 <vprintfmt+0x46>

f01012ac <.L48>:
		switch (ch = *(unsigned char *) fmt++) {
f01012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			sflag = 1;
f01012af:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
f01012b6:	eb c9                	jmp    f0101281 <vprintfmt+0x46>

f01012b8 <.L45>:
		switch (ch = *(unsigned char *) fmt++) {
f01012b8:	0f b6 d2             	movzbl %dl,%edx
f01012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01012be:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c3:	89 75 0c             	mov    %esi,0xc(%ebp)
f01012c6:	eb 0c                	jmp    f01012d4 <.L46+0xc>

f01012c8 <.L46>:
		switch (ch = *(unsigned char *) fmt++) {
f01012c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01012cb:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
			goto reswitch;
f01012cf:	eb b0                	jmp    f0101281 <vprintfmt+0x46>
			for (precision = 0; ; ++fmt) {
f01012d1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01012d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01012d7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01012db:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01012de:	8d 72 d0             	lea    -0x30(%edx),%esi
f01012e1:	83 fe 09             	cmp    $0x9,%esi
f01012e4:	76 eb                	jbe    f01012d1 <.L46+0x9>
f01012e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012e9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012ec:	eb 14                	jmp    f0101302 <.L49+0x14>

f01012ee <.L49>:
			precision = va_arg(ap, int);
f01012ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f1:	8b 00                	mov    (%eax),%eax
f01012f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f9:	8d 40 04             	lea    0x4(%eax),%eax
f01012fc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01012ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101302:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101306:	0f 89 75 ff ff ff    	jns    f0101281 <vprintfmt+0x46>
				width = precision, precision = -1;
f010130c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010130f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101312:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0101319:	e9 63 ff ff ff       	jmp    f0101281 <vprintfmt+0x46>

f010131e <.L47>:
f010131e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101321:	85 c0                	test   %eax,%eax
f0101323:	ba 00 00 00 00       	mov    $0x0,%edx
f0101328:	0f 48 c2             	cmovs  %edx,%eax
f010132b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010132e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101331:	e9 4b ff ff ff       	jmp    f0101281 <vprintfmt+0x46>

f0101336 <.L51>:
f0101336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101339:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101340:	e9 3c ff ff ff       	jmp    f0101281 <vprintfmt+0x46>

f0101345 <.L41>:
			lflag++;
f0101345:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010134c:	e9 30 ff ff ff       	jmp    f0101281 <vprintfmt+0x46>

f0101351 <.L44>:
			putch(va_arg(ap, int), putdat);
f0101351:	8b 45 14             	mov    0x14(%ebp),%eax
f0101354:	8d 78 04             	lea    0x4(%eax),%edi
f0101357:	83 ec 08             	sub    $0x8,%esp
f010135a:	56                   	push   %esi
f010135b:	ff 30                	pushl  (%eax)
f010135d:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101360:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101363:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0101366:	e9 37 03 00 00       	jmp    f01016a2 <.L38+0x52>

f010136b <.L42>:
			err = va_arg(ap, int);
f010136b:	8b 45 14             	mov    0x14(%ebp),%eax
f010136e:	8d 78 04             	lea    0x4(%eax),%edi
f0101371:	8b 00                	mov    (%eax),%eax
f0101373:	99                   	cltd   
f0101374:	31 d0                	xor    %edx,%eax
f0101376:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101378:	83 f8 06             	cmp    $0x6,%eax
f010137b:	7f 27                	jg     f01013a4 <.L42+0x39>
f010137d:	8b 94 83 dc ff ff ff 	mov    -0x24(%ebx,%eax,4),%edx
f0101384:	85 d2                	test   %edx,%edx
f0101386:	74 1c                	je     f01013a4 <.L42+0x39>
				printfmt(putch, putdat, "%s", p);
f0101388:	52                   	push   %edx
f0101389:	8d 83 8b e5 fe ff    	lea    -0x11a75(%ebx),%eax
f010138f:	50                   	push   %eax
f0101390:	56                   	push   %esi
f0101391:	ff 75 08             	pushl  0x8(%ebp)
f0101394:	e8 85 fe ff ff       	call   f010121e <printfmt>
f0101399:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010139c:	89 7d 14             	mov    %edi,0x14(%ebp)
f010139f:	e9 fe 02 00 00       	jmp    f01016a2 <.L38+0x52>
				printfmt(putch, putdat, "error %d", err);
f01013a4:	50                   	push   %eax
f01013a5:	8d 83 82 e5 fe ff    	lea    -0x11a7e(%ebx),%eax
f01013ab:	50                   	push   %eax
f01013ac:	56                   	push   %esi
f01013ad:	ff 75 08             	pushl  0x8(%ebp)
f01013b0:	e8 69 fe ff ff       	call   f010121e <printfmt>
f01013b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01013b8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01013bb:	e9 e2 02 00 00       	jmp    f01016a2 <.L38+0x52>

f01013c0 <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f01013c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c3:	83 c0 04             	add    $0x4,%eax
f01013c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01013c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01013cc:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01013ce:	85 d2                	test   %edx,%edx
f01013d0:	8d 83 7b e5 fe ff    	lea    -0x11a85(%ebx),%eax
f01013d6:	0f 45 c2             	cmovne %edx,%eax
f01013d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01013dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01013e0:	7e 06                	jle    f01013e8 <.L37+0x28>
f01013e2:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01013e6:	75 0d                	jne    f01013f5 <.L37+0x35>
				for (width -= strnlen(p, precision); width > 0; width--)
f01013e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01013eb:	89 c7                	mov    %eax,%edi
f01013ed:	03 45 e0             	add    -0x20(%ebp),%eax
f01013f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01013f3:	eb 55                	jmp    f010144a <.L37+0x8a>
f01013f5:	83 ec 08             	sub    $0x8,%esp
f01013f8:	ff 75 d8             	pushl  -0x28(%ebp)
f01013fb:	50                   	push   %eax
f01013fc:	e8 78 05 00 00       	call   f0101979 <strnlen>
f0101401:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101404:	29 c1                	sub    %eax,%ecx
f0101406:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0101409:	83 c4 10             	add    $0x10,%esp
f010140c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f010140e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101412:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101415:	eb 10                	jmp    f0101427 <.L37+0x67>
					putch(padc, putdat);
f0101417:	83 ec 08             	sub    $0x8,%esp
f010141a:	56                   	push   %esi
f010141b:	ff 75 e0             	pushl  -0x20(%ebp)
f010141e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101421:	83 ef 01             	sub    $0x1,%edi
f0101424:	83 c4 10             	add    $0x10,%esp
f0101427:	85 ff                	test   %edi,%edi
f0101429:	7f ec                	jg     f0101417 <.L37+0x57>
f010142b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010142e:	85 c9                	test   %ecx,%ecx
f0101430:	b8 00 00 00 00       	mov    $0x0,%eax
f0101435:	0f 49 c1             	cmovns %ecx,%eax
f0101438:	29 c1                	sub    %eax,%ecx
f010143a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010143d:	eb a9                	jmp    f01013e8 <.L37+0x28>
					putch(ch, putdat);
f010143f:	83 ec 08             	sub    $0x8,%esp
f0101442:	56                   	push   %esi
f0101443:	52                   	push   %edx
f0101444:	ff 55 08             	call   *0x8(%ebp)
f0101447:	83 c4 10             	add    $0x10,%esp
f010144a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010144d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010144f:	83 c7 01             	add    $0x1,%edi
f0101452:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101456:	0f be d0             	movsbl %al,%edx
f0101459:	85 d2                	test   %edx,%edx
f010145b:	74 4d                	je     f01014aa <.L37+0xea>
f010145d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101461:	78 06                	js     f0101469 <.L37+0xa9>
f0101463:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101467:	78 1f                	js     f0101488 <.L37+0xc8>
				if (altflag && (ch < ' ' || ch > '~'))
f0101469:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010146d:	74 d0                	je     f010143f <.L37+0x7f>
f010146f:	0f be c0             	movsbl %al,%eax
f0101472:	83 e8 20             	sub    $0x20,%eax
f0101475:	83 f8 5e             	cmp    $0x5e,%eax
f0101478:	76 c5                	jbe    f010143f <.L37+0x7f>
					putch('?', putdat);
f010147a:	83 ec 08             	sub    $0x8,%esp
f010147d:	56                   	push   %esi
f010147e:	6a 3f                	push   $0x3f
f0101480:	ff 55 08             	call   *0x8(%ebp)
f0101483:	83 c4 10             	add    $0x10,%esp
f0101486:	eb c2                	jmp    f010144a <.L37+0x8a>
f0101488:	89 cf                	mov    %ecx,%edi
f010148a:	eb 0f                	jmp    f010149b <.L37+0xdb>
				putch(' ', putdat);
f010148c:	83 ec 08             	sub    $0x8,%esp
f010148f:	56                   	push   %esi
f0101490:	6a 20                	push   $0x20
f0101492:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0101495:	83 ef 01             	sub    $0x1,%edi
f0101498:	83 c4 10             	add    $0x10,%esp
f010149b:	85 ff                	test   %edi,%edi
f010149d:	7f ed                	jg     f010148c <.L37+0xcc>
			if ((p = va_arg(ap, char *)) == NULL)
f010149f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01014a2:	89 45 14             	mov    %eax,0x14(%ebp)
f01014a5:	e9 f8 01 00 00       	jmp    f01016a2 <.L38+0x52>
f01014aa:	89 cf                	mov    %ecx,%edi
f01014ac:	eb ed                	jmp    f010149b <.L37+0xdb>

f01014ae <.L43>:
	if (lflag >= 2)
f01014ae:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f01014b2:	7f 21                	jg     f01014d5 <.L43+0x27>
	else if (lflag)
f01014b4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01014b8:	74 69                	je     f0101523 <.L43+0x75>
		return va_arg(*ap, long);
f01014ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01014bd:	8b 00                	mov    (%eax),%eax
f01014bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014c2:	89 c1                	mov    %eax,%ecx
f01014c4:	c1 f9 1f             	sar    $0x1f,%ecx
f01014c7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01014ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01014cd:	8d 40 04             	lea    0x4(%eax),%eax
f01014d0:	89 45 14             	mov    %eax,0x14(%ebp)
f01014d3:	eb 17                	jmp    f01014ec <.L43+0x3e>
		return va_arg(*ap, long long);
f01014d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01014d8:	8b 50 04             	mov    0x4(%eax),%edx
f01014db:	8b 00                	mov    (%eax),%eax
f01014dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01014e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01014e6:	8d 40 08             	lea    0x8(%eax),%eax
f01014e9:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
f01014ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01014f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01014f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f01014f8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01014fc:	78 40                	js     f010153e <.L43+0x90>
			base = 10;
f01014fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			else if (sflag == 1){
f0101503:	83 7d c4 01          	cmpl   $0x1,-0x3c(%ebp)
f0101507:	0f 85 76 01 00 00    	jne    f0101683 <.L38+0x33>
				putch('+', putdat);
f010150d:	83 ec 08             	sub    $0x8,%esp
f0101510:	56                   	push   %esi
f0101511:	6a 2b                	push   $0x2b
f0101513:	ff 55 08             	call   *0x8(%ebp)
f0101516:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101519:	b8 0a 00 00 00       	mov    $0xa,%eax
f010151e:	e9 60 01 00 00       	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, int);
f0101523:	8b 45 14             	mov    0x14(%ebp),%eax
f0101526:	8b 00                	mov    (%eax),%eax
f0101528:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010152b:	89 c1                	mov    %eax,%ecx
f010152d:	c1 f9 1f             	sar    $0x1f,%ecx
f0101530:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101533:	8b 45 14             	mov    0x14(%ebp),%eax
f0101536:	8d 40 04             	lea    0x4(%eax),%eax
f0101539:	89 45 14             	mov    %eax,0x14(%ebp)
f010153c:	eb ae                	jmp    f01014ec <.L43+0x3e>
				putch('-', putdat);
f010153e:	83 ec 08             	sub    $0x8,%esp
f0101541:	56                   	push   %esi
f0101542:	6a 2d                	push   $0x2d
f0101544:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101547:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010154a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010154d:	f7 d8                	neg    %eax
f010154f:	83 d2 00             	adc    $0x0,%edx
f0101552:	f7 da                	neg    %edx
f0101554:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101557:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010155a:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010155d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101562:	e9 1c 01 00 00       	jmp    f0101683 <.L38+0x33>

f0101567 <.L36>:
	if (lflag >= 2)
f0101567:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f010156b:	7f 29                	jg     f0101596 <.L36+0x2f>
	else if (lflag)
f010156d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0101571:	74 44                	je     f01015b7 <.L36+0x50>
		return va_arg(*ap, unsigned long);
f0101573:	8b 45 14             	mov    0x14(%ebp),%eax
f0101576:	8b 00                	mov    (%eax),%eax
f0101578:	ba 00 00 00 00       	mov    $0x0,%edx
f010157d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101580:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101583:	8b 45 14             	mov    0x14(%ebp),%eax
f0101586:	8d 40 04             	lea    0x4(%eax),%eax
f0101589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010158c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101591:	e9 ed 00 00 00       	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, unsigned long long);
f0101596:	8b 45 14             	mov    0x14(%ebp),%eax
f0101599:	8b 50 04             	mov    0x4(%eax),%edx
f010159c:	8b 00                	mov    (%eax),%eax
f010159e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01015a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01015a7:	8d 40 08             	lea    0x8(%eax),%eax
f01015aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01015ad:	b8 0a 00 00 00       	mov    $0xa,%eax
f01015b2:	e9 cc 00 00 00       	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, unsigned int);
f01015b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01015ba:	8b 00                	mov    (%eax),%eax
f01015bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01015c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01015c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01015ca:	8d 40 04             	lea    0x4(%eax),%eax
f01015cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01015d0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01015d5:	e9 a9 00 00 00       	jmp    f0101683 <.L38+0x33>

f01015da <.L39>:
			putch('0', putdat);
f01015da:	83 ec 08             	sub    $0x8,%esp
f01015dd:	56                   	push   %esi
f01015de:	6a 30                	push   $0x30
f01015e0:	ff 55 08             	call   *0x8(%ebp)
	if (lflag >= 2)
f01015e3:	83 c4 10             	add    $0x10,%esp
f01015e6:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f01015ea:	7f 26                	jg     f0101612 <.L39+0x38>
	else if (lflag)
f01015ec:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01015f0:	74 3e                	je     f0101630 <.L39+0x56>
		return va_arg(*ap, unsigned long);
f01015f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01015f5:	8b 00                	mov    (%eax),%eax
f01015f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01015fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101602:	8b 45 14             	mov    0x14(%ebp),%eax
f0101605:	8d 40 04             	lea    0x4(%eax),%eax
f0101608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010160b:	b8 08 00 00 00       	mov    $0x8,%eax
f0101610:	eb 71                	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, unsigned long long);
f0101612:	8b 45 14             	mov    0x14(%ebp),%eax
f0101615:	8b 50 04             	mov    0x4(%eax),%edx
f0101618:	8b 00                	mov    (%eax),%eax
f010161a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010161d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101620:	8b 45 14             	mov    0x14(%ebp),%eax
f0101623:	8d 40 08             	lea    0x8(%eax),%eax
f0101626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101629:	b8 08 00 00 00       	mov    $0x8,%eax
f010162e:	eb 53                	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, unsigned int);
f0101630:	8b 45 14             	mov    0x14(%ebp),%eax
f0101633:	8b 00                	mov    (%eax),%eax
f0101635:	ba 00 00 00 00       	mov    $0x0,%edx
f010163a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010163d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101640:	8b 45 14             	mov    0x14(%ebp),%eax
f0101643:	8d 40 04             	lea    0x4(%eax),%eax
f0101646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101649:	b8 08 00 00 00       	mov    $0x8,%eax
f010164e:	eb 33                	jmp    f0101683 <.L38+0x33>

f0101650 <.L38>:
			putch('0', putdat);
f0101650:	83 ec 08             	sub    $0x8,%esp
f0101653:	56                   	push   %esi
f0101654:	6a 30                	push   $0x30
f0101656:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101659:	83 c4 08             	add    $0x8,%esp
f010165c:	56                   	push   %esi
f010165d:	6a 78                	push   $0x78
f010165f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101662:	8b 45 14             	mov    0x14(%ebp),%eax
f0101665:	8b 00                	mov    (%eax),%eax
f0101667:	ba 00 00 00 00       	mov    $0x0,%edx
f010166c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010166f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			goto number;
f0101672:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101675:	8b 45 14             	mov    0x14(%ebp),%eax
f0101678:	8d 40 04             	lea    0x4(%eax),%eax
f010167b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010167e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101683:	83 ec 0c             	sub    $0xc,%esp
f0101686:	0f be 55 cf          	movsbl -0x31(%ebp),%edx
f010168a:	52                   	push   %edx
f010168b:	ff 75 e0             	pushl  -0x20(%ebp)
f010168e:	50                   	push   %eax
f010168f:	ff 75 dc             	pushl  -0x24(%ebp)
f0101692:	ff 75 d8             	pushl  -0x28(%ebp)
f0101695:	89 f2                	mov    %esi,%edx
f0101697:	8b 45 08             	mov    0x8(%ebp),%eax
f010169a:	e8 7d fa ff ff       	call   f010111c <printnum>
			break;
f010169f:	83 c4 20             	add    $0x20,%esp
        		          if ((np = va_arg(ap, signed char *)) == NULL) {
f01016a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01016a5:	83 c7 01             	add    $0x1,%edi
f01016a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01016ac:	83 f8 25             	cmp    $0x25,%eax
f01016af:	0f 84 a5 fb ff ff    	je     f010125a <vprintfmt+0x1f>
			if (ch == '\0')
f01016b5:	85 c0                	test   %eax,%eax
f01016b7:	0f 84 22 01 00 00    	je     f01017df <.L33+0x21>
			putch(ch, putdat);
f01016bd:	83 ec 08             	sub    $0x8,%esp
f01016c0:	56                   	push   %esi
f01016c1:	50                   	push   %eax
f01016c2:	ff 55 08             	call   *0x8(%ebp)
f01016c5:	83 c4 10             	add    $0x10,%esp
f01016c8:	eb db                	jmp    f01016a5 <.L38+0x55>

f01016ca <.L34>:
	if (lflag >= 2)
f01016ca:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f01016ce:	7f 26                	jg     f01016f6 <.L34+0x2c>
	else if (lflag)
f01016d0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01016d4:	74 41                	je     f0101717 <.L34+0x4d>
		return va_arg(*ap, unsigned long);
f01016d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01016d9:	8b 00                	mov    (%eax),%eax
f01016db:	ba 00 00 00 00       	mov    $0x0,%edx
f01016e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01016e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01016e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01016e9:	8d 40 04             	lea    0x4(%eax),%eax
f01016ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01016ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01016f4:	eb 8d                	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, unsigned long long);
f01016f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01016f9:	8b 50 04             	mov    0x4(%eax),%edx
f01016fc:	8b 00                	mov    (%eax),%eax
f01016fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101701:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101704:	8b 45 14             	mov    0x14(%ebp),%eax
f0101707:	8d 40 08             	lea    0x8(%eax),%eax
f010170a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010170d:	b8 10 00 00 00       	mov    $0x10,%eax
f0101712:	e9 6c ff ff ff       	jmp    f0101683 <.L38+0x33>
		return va_arg(*ap, unsigned int);
f0101717:	8b 45 14             	mov    0x14(%ebp),%eax
f010171a:	8b 00                	mov    (%eax),%eax
f010171c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101721:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101724:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101727:	8b 45 14             	mov    0x14(%ebp),%eax
f010172a:	8d 40 04             	lea    0x4(%eax),%eax
f010172d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101730:	b8 10 00 00 00       	mov    $0x10,%eax
f0101735:	e9 49 ff ff ff       	jmp    f0101683 <.L38+0x33>

f010173a <.L40>:
        		          if ((np = va_arg(ap, signed char *)) == NULL) {
f010173a:	8b 45 14             	mov    0x14(%ebp),%eax
f010173d:	83 c0 04             	add    $0x4,%eax
f0101740:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101743:	8b 45 14             	mov    0x14(%ebp),%eax
f0101746:	8b 38                	mov    (%eax),%edi
f0101748:	85 ff                	test   %edi,%edi
f010174a:	74 14                	je     f0101760 <.L40+0x26>
			   	else if (*((signed char *)putdat) < 0){
f010174c:	0f b6 06             	movzbl (%esi),%eax
f010174f:	84 c0                	test   %al,%al
f0101751:	78 32                	js     f0101785 <.L40+0x4b>
                                	*np = *((signed char *)putdat);
f0101753:	88 07                	mov    %al,(%edi)
        		          if ((np = va_arg(ap, signed char *)) == NULL) {
f0101755:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101758:	89 45 14             	mov    %eax,0x14(%ebp)
f010175b:	e9 42 ff ff ff       	jmp    f01016a2 <.L38+0x52>
	                    	      printfmt(putch, putdat, "%s", null_error);
f0101760:	8d 83 f8 e5 fe ff    	lea    -0x11a08(%ebx),%eax
f0101766:	50                   	push   %eax
f0101767:	8d 83 8b e5 fe ff    	lea    -0x11a75(%ebx),%eax
f010176d:	50                   	push   %eax
f010176e:	56                   	push   %esi
f010176f:	ff 75 08             	pushl  0x8(%ebp)
f0101772:	e8 a7 fa ff ff       	call   f010121e <printfmt>
f0101777:	83 c4 10             	add    $0x10,%esp
        		          if ((np = va_arg(ap, signed char *)) == NULL) {
f010177a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010177d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101780:	e9 1d ff ff ff       	jmp    f01016a2 <.L38+0x52>
			    		printfmt(putch, putdat,"%s", overflow_error);
f0101785:	8d 83 30 e6 fe ff    	lea    -0x119d0(%ebx),%eax
f010178b:	50                   	push   %eax
f010178c:	8d 83 8b e5 fe ff    	lea    -0x11a75(%ebx),%eax
f0101792:	50                   	push   %eax
f0101793:	56                   	push   %esi
f0101794:	ff 75 08             	pushl  0x8(%ebp)
f0101797:	e8 82 fa ff ff       	call   f010121e <printfmt>
					*np = -1;
f010179c:	c6 07 ff             	movb   $0xff,(%edi)
f010179f:	83 c4 10             	add    $0x10,%esp
        		          if ((np = va_arg(ap, signed char *)) == NULL) {
f01017a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01017a5:	89 45 14             	mov    %eax,0x14(%ebp)
f01017a8:	e9 f5 fe ff ff       	jmp    f01016a2 <.L38+0x52>

f01017ad <.L50>:
			putch(ch, putdat);
f01017ad:	83 ec 08             	sub    $0x8,%esp
f01017b0:	56                   	push   %esi
f01017b1:	6a 25                	push   $0x25
f01017b3:	ff 55 08             	call   *0x8(%ebp)
			break;
f01017b6:	83 c4 10             	add    $0x10,%esp
f01017b9:	e9 e4 fe ff ff       	jmp    f01016a2 <.L38+0x52>

f01017be <.L33>:
			putch('%', putdat);
f01017be:	83 ec 08             	sub    $0x8,%esp
f01017c1:	56                   	push   %esi
f01017c2:	6a 25                	push   $0x25
f01017c4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01017c7:	83 c4 10             	add    $0x10,%esp
f01017ca:	89 f8                	mov    %edi,%eax
f01017cc:	eb 03                	jmp    f01017d1 <.L33+0x13>
f01017ce:	83 e8 01             	sub    $0x1,%eax
f01017d1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01017d5:	75 f7                	jne    f01017ce <.L33+0x10>
f01017d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01017da:	e9 c3 fe ff ff       	jmp    f01016a2 <.L38+0x52>
}
f01017df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017e2:	5b                   	pop    %ebx
f01017e3:	5e                   	pop    %esi
f01017e4:	5f                   	pop    %edi
f01017e5:	5d                   	pop    %ebp
f01017e6:	c3                   	ret    

f01017e7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01017e7:	55                   	push   %ebp
f01017e8:	89 e5                	mov    %esp,%ebp
f01017ea:	53                   	push   %ebx
f01017eb:	83 ec 14             	sub    $0x14,%esp
f01017ee:	e8 8d ea ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f01017f3:	81 c3 75 28 01 00    	add    $0x12875,%ebx
f01017f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01017fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01017ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101810:	85 c0                	test   %eax,%eax
f0101812:	74 2b                	je     f010183f <vsnprintf+0x58>
f0101814:	85 d2                	test   %edx,%edx
f0101816:	7e 27                	jle    f010183f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101818:	ff 75 14             	pushl  0x14(%ebp)
f010181b:	ff 75 10             	pushl  0x10(%ebp)
f010181e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101821:	50                   	push   %eax
f0101822:	8d 83 99 d1 fe ff    	lea    -0x12e67(%ebx),%eax
f0101828:	50                   	push   %eax
f0101829:	e8 0d fa ff ff       	call   f010123b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010182e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101831:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101834:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101837:	83 c4 10             	add    $0x10,%esp
}
f010183a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010183d:	c9                   	leave  
f010183e:	c3                   	ret    
		return -E_INVAL;
f010183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101844:	eb f4                	jmp    f010183a <vsnprintf+0x53>

f0101846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101846:	55                   	push   %ebp
f0101847:	89 e5                	mov    %esp,%ebp
f0101849:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010184c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010184f:	50                   	push   %eax
f0101850:	ff 75 10             	pushl  0x10(%ebp)
f0101853:	ff 75 0c             	pushl  0xc(%ebp)
f0101856:	ff 75 08             	pushl  0x8(%ebp)
f0101859:	e8 89 ff ff ff       	call   f01017e7 <vsnprintf>
	va_end(ap);

	return rc;
}
f010185e:	c9                   	leave  
f010185f:	c3                   	ret    

f0101860 <__x86.get_pc_thunk.di>:
f0101860:	8b 3c 24             	mov    (%esp),%edi
f0101863:	c3                   	ret    

f0101864 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101864:	55                   	push   %ebp
f0101865:	89 e5                	mov    %esp,%ebp
f0101867:	57                   	push   %edi
f0101868:	56                   	push   %esi
f0101869:	53                   	push   %ebx
f010186a:	83 ec 1c             	sub    $0x1c,%esp
f010186d:	e8 0e ea ff ff       	call   f0100280 <__x86.get_pc_thunk.bx>
f0101872:	81 c3 f6 27 01 00    	add    $0x127f6,%ebx
f0101878:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010187b:	85 c0                	test   %eax,%eax
f010187d:	74 13                	je     f0101892 <readline+0x2e>
		cprintf("%s", prompt);
f010187f:	83 ec 08             	sub    $0x8,%esp
f0101882:	50                   	push   %eax
f0101883:	8d 83 8b e5 fe ff    	lea    -0x11a75(%ebx),%eax
f0101889:	50                   	push   %eax
f010188a:	e8 e3 f3 ff ff       	call   f0100c72 <cprintf>
f010188f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101892:	83 ec 0c             	sub    $0xc,%esp
f0101895:	6a 00                	push   $0x0
f0101897:	e8 4f ef ff ff       	call   f01007eb <iscons>
f010189c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010189f:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01018a2:	bf 00 00 00 00       	mov    $0x0,%edi
f01018a7:	eb 52                	jmp    f01018fb <readline+0x97>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01018a9:	83 ec 08             	sub    $0x8,%esp
f01018ac:	50                   	push   %eax
f01018ad:	8d 83 cc e7 fe ff    	lea    -0x11834(%ebx),%eax
f01018b3:	50                   	push   %eax
f01018b4:	e8 b9 f3 ff ff       	call   f0100c72 <cprintf>
			return NULL;
f01018b9:	83 c4 10             	add    $0x10,%esp
f01018bc:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01018c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018c4:	5b                   	pop    %ebx
f01018c5:	5e                   	pop    %esi
f01018c6:	5f                   	pop    %edi
f01018c7:	5d                   	pop    %ebp
f01018c8:	c3                   	ret    
			if (echoing)
f01018c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01018cd:	75 05                	jne    f01018d4 <readline+0x70>
			i--;
f01018cf:	83 ef 01             	sub    $0x1,%edi
f01018d2:	eb 27                	jmp    f01018fb <readline+0x97>
				cputchar('\b');
f01018d4:	83 ec 0c             	sub    $0xc,%esp
f01018d7:	6a 08                	push   $0x8
f01018d9:	e8 ec ee ff ff       	call   f01007ca <cputchar>
f01018de:	83 c4 10             	add    $0x10,%esp
f01018e1:	eb ec                	jmp    f01018cf <readline+0x6b>
				cputchar(c);
f01018e3:	83 ec 0c             	sub    $0xc,%esp
f01018e6:	56                   	push   %esi
f01018e7:	e8 de ee ff ff       	call   f01007ca <cputchar>
f01018ec:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01018ef:	89 f0                	mov    %esi,%eax
f01018f1:	88 84 3b 58 02 00 00 	mov    %al,0x258(%ebx,%edi,1)
f01018f8:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01018fb:	e8 da ee ff ff       	call   f01007da <getchar>
f0101900:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101902:	85 c0                	test   %eax,%eax
f0101904:	78 a3                	js     f01018a9 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101906:	83 f8 08             	cmp    $0x8,%eax
f0101909:	0f 94 c2             	sete   %dl
f010190c:	83 f8 7f             	cmp    $0x7f,%eax
f010190f:	0f 94 c0             	sete   %al
f0101912:	08 c2                	or     %al,%dl
f0101914:	74 04                	je     f010191a <readline+0xb6>
f0101916:	85 ff                	test   %edi,%edi
f0101918:	7f af                	jg     f01018c9 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010191a:	83 fe 1f             	cmp    $0x1f,%esi
f010191d:	7e 10                	jle    f010192f <readline+0xcb>
f010191f:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101925:	7f 08                	jg     f010192f <readline+0xcb>
			if (echoing)
f0101927:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010192b:	74 c2                	je     f01018ef <readline+0x8b>
f010192d:	eb b4                	jmp    f01018e3 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010192f:	83 fe 0a             	cmp    $0xa,%esi
f0101932:	74 05                	je     f0101939 <readline+0xd5>
f0101934:	83 fe 0d             	cmp    $0xd,%esi
f0101937:	75 c2                	jne    f01018fb <readline+0x97>
			if (echoing)
f0101939:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010193d:	75 13                	jne    f0101952 <readline+0xee>
			buf[i] = 0;
f010193f:	c6 84 3b 58 02 00 00 	movb   $0x0,0x258(%ebx,%edi,1)
f0101946:	00 
			return buf;
f0101947:	8d 83 58 02 00 00    	lea    0x258(%ebx),%eax
f010194d:	e9 6f ff ff ff       	jmp    f01018c1 <readline+0x5d>
				cputchar('\n');
f0101952:	83 ec 0c             	sub    $0xc,%esp
f0101955:	6a 0a                	push   $0xa
f0101957:	e8 6e ee ff ff       	call   f01007ca <cputchar>
f010195c:	83 c4 10             	add    $0x10,%esp
f010195f:	eb de                	jmp    f010193f <readline+0xdb>

f0101961 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101961:	55                   	push   %ebp
f0101962:	89 e5                	mov    %esp,%ebp
f0101964:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101967:	b8 00 00 00 00       	mov    $0x0,%eax
f010196c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101970:	74 05                	je     f0101977 <strlen+0x16>
		n++;
f0101972:	83 c0 01             	add    $0x1,%eax
f0101975:	eb f5                	jmp    f010196c <strlen+0xb>
	return n;
}
f0101977:	5d                   	pop    %ebp
f0101978:	c3                   	ret    

f0101979 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101979:	55                   	push   %ebp
f010197a:	89 e5                	mov    %esp,%ebp
f010197c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010197f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101982:	ba 00 00 00 00       	mov    $0x0,%edx
f0101987:	39 c2                	cmp    %eax,%edx
f0101989:	74 0d                	je     f0101998 <strnlen+0x1f>
f010198b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010198f:	74 05                	je     f0101996 <strnlen+0x1d>
		n++;
f0101991:	83 c2 01             	add    $0x1,%edx
f0101994:	eb f1                	jmp    f0101987 <strnlen+0xe>
f0101996:	89 d0                	mov    %edx,%eax
	return n;
}
f0101998:	5d                   	pop    %ebp
f0101999:	c3                   	ret    

f010199a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010199a:	55                   	push   %ebp
f010199b:	89 e5                	mov    %esp,%ebp
f010199d:	53                   	push   %ebx
f010199e:	8b 45 08             	mov    0x8(%ebp),%eax
f01019a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01019a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01019a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01019ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01019b0:	83 c2 01             	add    $0x1,%edx
f01019b3:	84 c9                	test   %cl,%cl
f01019b5:	75 f2                	jne    f01019a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01019b7:	5b                   	pop    %ebx
f01019b8:	5d                   	pop    %ebp
f01019b9:	c3                   	ret    

f01019ba <strcat>:

char *
strcat(char *dst, const char *src)
{
f01019ba:	55                   	push   %ebp
f01019bb:	89 e5                	mov    %esp,%ebp
f01019bd:	53                   	push   %ebx
f01019be:	83 ec 10             	sub    $0x10,%esp
f01019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01019c4:	53                   	push   %ebx
f01019c5:	e8 97 ff ff ff       	call   f0101961 <strlen>
f01019ca:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01019cd:	ff 75 0c             	pushl  0xc(%ebp)
f01019d0:	01 d8                	add    %ebx,%eax
f01019d2:	50                   	push   %eax
f01019d3:	e8 c2 ff ff ff       	call   f010199a <strcpy>
	return dst;
}
f01019d8:	89 d8                	mov    %ebx,%eax
f01019da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01019dd:	c9                   	leave  
f01019de:	c3                   	ret    

f01019df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01019df:	55                   	push   %ebp
f01019e0:	89 e5                	mov    %esp,%ebp
f01019e2:	56                   	push   %esi
f01019e3:	53                   	push   %ebx
f01019e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01019e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01019ea:	89 c6                	mov    %eax,%esi
f01019ec:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01019ef:	89 c2                	mov    %eax,%edx
f01019f1:	39 f2                	cmp    %esi,%edx
f01019f3:	74 11                	je     f0101a06 <strncpy+0x27>
		*dst++ = *src;
f01019f5:	83 c2 01             	add    $0x1,%edx
f01019f8:	0f b6 19             	movzbl (%ecx),%ebx
f01019fb:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01019fe:	80 fb 01             	cmp    $0x1,%bl
f0101a01:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0101a04:	eb eb                	jmp    f01019f1 <strncpy+0x12>
	}
	return ret;
}
f0101a06:	5b                   	pop    %ebx
f0101a07:	5e                   	pop    %esi
f0101a08:	5d                   	pop    %ebp
f0101a09:	c3                   	ret    

f0101a0a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101a0a:	55                   	push   %ebp
f0101a0b:	89 e5                	mov    %esp,%ebp
f0101a0d:	56                   	push   %esi
f0101a0e:	53                   	push   %ebx
f0101a0f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a15:	8b 55 10             	mov    0x10(%ebp),%edx
f0101a18:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101a1a:	85 d2                	test   %edx,%edx
f0101a1c:	74 21                	je     f0101a3f <strlcpy+0x35>
f0101a1e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101a22:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0101a24:	39 c2                	cmp    %eax,%edx
f0101a26:	74 14                	je     f0101a3c <strlcpy+0x32>
f0101a28:	0f b6 19             	movzbl (%ecx),%ebx
f0101a2b:	84 db                	test   %bl,%bl
f0101a2d:	74 0b                	je     f0101a3a <strlcpy+0x30>
			*dst++ = *src++;
f0101a2f:	83 c1 01             	add    $0x1,%ecx
f0101a32:	83 c2 01             	add    $0x1,%edx
f0101a35:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101a38:	eb ea                	jmp    f0101a24 <strlcpy+0x1a>
f0101a3a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101a3c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101a3f:	29 f0                	sub    %esi,%eax
}
f0101a41:	5b                   	pop    %ebx
f0101a42:	5e                   	pop    %esi
f0101a43:	5d                   	pop    %ebp
f0101a44:	c3                   	ret    

f0101a45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101a45:	55                   	push   %ebp
f0101a46:	89 e5                	mov    %esp,%ebp
f0101a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101a4e:	0f b6 01             	movzbl (%ecx),%eax
f0101a51:	84 c0                	test   %al,%al
f0101a53:	74 0c                	je     f0101a61 <strcmp+0x1c>
f0101a55:	3a 02                	cmp    (%edx),%al
f0101a57:	75 08                	jne    f0101a61 <strcmp+0x1c>
		p++, q++;
f0101a59:	83 c1 01             	add    $0x1,%ecx
f0101a5c:	83 c2 01             	add    $0x1,%edx
f0101a5f:	eb ed                	jmp    f0101a4e <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101a61:	0f b6 c0             	movzbl %al,%eax
f0101a64:	0f b6 12             	movzbl (%edx),%edx
f0101a67:	29 d0                	sub    %edx,%eax
}
f0101a69:	5d                   	pop    %ebp
f0101a6a:	c3                   	ret    

f0101a6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101a6b:	55                   	push   %ebp
f0101a6c:	89 e5                	mov    %esp,%ebp
f0101a6e:	53                   	push   %ebx
f0101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a72:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a75:	89 c3                	mov    %eax,%ebx
f0101a77:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101a7a:	eb 06                	jmp    f0101a82 <strncmp+0x17>
		n--, p++, q++;
f0101a7c:	83 c0 01             	add    $0x1,%eax
f0101a7f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101a82:	39 d8                	cmp    %ebx,%eax
f0101a84:	74 16                	je     f0101a9c <strncmp+0x31>
f0101a86:	0f b6 08             	movzbl (%eax),%ecx
f0101a89:	84 c9                	test   %cl,%cl
f0101a8b:	74 04                	je     f0101a91 <strncmp+0x26>
f0101a8d:	3a 0a                	cmp    (%edx),%cl
f0101a8f:	74 eb                	je     f0101a7c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101a91:	0f b6 00             	movzbl (%eax),%eax
f0101a94:	0f b6 12             	movzbl (%edx),%edx
f0101a97:	29 d0                	sub    %edx,%eax
}
f0101a99:	5b                   	pop    %ebx
f0101a9a:	5d                   	pop    %ebp
f0101a9b:	c3                   	ret    
		return 0;
f0101a9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101aa1:	eb f6                	jmp    f0101a99 <strncmp+0x2e>

f0101aa3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101aa3:	55                   	push   %ebp
f0101aa4:	89 e5                	mov    %esp,%ebp
f0101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aa9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101aad:	0f b6 10             	movzbl (%eax),%edx
f0101ab0:	84 d2                	test   %dl,%dl
f0101ab2:	74 09                	je     f0101abd <strchr+0x1a>
		if (*s == c)
f0101ab4:	38 ca                	cmp    %cl,%dl
f0101ab6:	74 0a                	je     f0101ac2 <strchr+0x1f>
	for (; *s; s++)
f0101ab8:	83 c0 01             	add    $0x1,%eax
f0101abb:	eb f0                	jmp    f0101aad <strchr+0xa>
			return (char *) s;
	return 0;
f0101abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101ac2:	5d                   	pop    %ebp
f0101ac3:	c3                   	ret    

f0101ac4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101ac4:	55                   	push   %ebp
f0101ac5:	89 e5                	mov    %esp,%ebp
f0101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101ace:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101ad1:	38 ca                	cmp    %cl,%dl
f0101ad3:	74 09                	je     f0101ade <strfind+0x1a>
f0101ad5:	84 d2                	test   %dl,%dl
f0101ad7:	74 05                	je     f0101ade <strfind+0x1a>
	for (; *s; s++)
f0101ad9:	83 c0 01             	add    $0x1,%eax
f0101adc:	eb f0                	jmp    f0101ace <strfind+0xa>
			break;
	return (char *) s;
}
f0101ade:	5d                   	pop    %ebp
f0101adf:	c3                   	ret    

f0101ae0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101ae0:	55                   	push   %ebp
f0101ae1:	89 e5                	mov    %esp,%ebp
f0101ae3:	57                   	push   %edi
f0101ae4:	56                   	push   %esi
f0101ae5:	53                   	push   %ebx
f0101ae6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101ae9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101aec:	85 c9                	test   %ecx,%ecx
f0101aee:	74 31                	je     f0101b21 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101af0:	89 f8                	mov    %edi,%eax
f0101af2:	09 c8                	or     %ecx,%eax
f0101af4:	a8 03                	test   $0x3,%al
f0101af6:	75 23                	jne    f0101b1b <memset+0x3b>
		c &= 0xFF;
f0101af8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101afc:	89 d3                	mov    %edx,%ebx
f0101afe:	c1 e3 08             	shl    $0x8,%ebx
f0101b01:	89 d0                	mov    %edx,%eax
f0101b03:	c1 e0 18             	shl    $0x18,%eax
f0101b06:	89 d6                	mov    %edx,%esi
f0101b08:	c1 e6 10             	shl    $0x10,%esi
f0101b0b:	09 f0                	or     %esi,%eax
f0101b0d:	09 c2                	or     %eax,%edx
f0101b0f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101b11:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101b14:	89 d0                	mov    %edx,%eax
f0101b16:	fc                   	cld    
f0101b17:	f3 ab                	rep stos %eax,%es:(%edi)
f0101b19:	eb 06                	jmp    f0101b21 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b1e:	fc                   	cld    
f0101b1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101b21:	89 f8                	mov    %edi,%eax
f0101b23:	5b                   	pop    %ebx
f0101b24:	5e                   	pop    %esi
f0101b25:	5f                   	pop    %edi
f0101b26:	5d                   	pop    %ebp
f0101b27:	c3                   	ret    

f0101b28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101b28:	55                   	push   %ebp
f0101b29:	89 e5                	mov    %esp,%ebp
f0101b2b:	57                   	push   %edi
f0101b2c:	56                   	push   %esi
f0101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b30:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101b36:	39 c6                	cmp    %eax,%esi
f0101b38:	73 32                	jae    f0101b6c <memmove+0x44>
f0101b3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101b3d:	39 c2                	cmp    %eax,%edx
f0101b3f:	76 2b                	jbe    f0101b6c <memmove+0x44>
		s += n;
		d += n;
f0101b41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b44:	89 fe                	mov    %edi,%esi
f0101b46:	09 ce                	or     %ecx,%esi
f0101b48:	09 d6                	or     %edx,%esi
f0101b4a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101b50:	75 0e                	jne    f0101b60 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101b52:	83 ef 04             	sub    $0x4,%edi
f0101b55:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101b58:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101b5b:	fd                   	std    
f0101b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101b5e:	eb 09                	jmp    f0101b69 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101b60:	83 ef 01             	sub    $0x1,%edi
f0101b63:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101b66:	fd                   	std    
f0101b67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101b69:	fc                   	cld    
f0101b6a:	eb 1a                	jmp    f0101b86 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b6c:	89 c2                	mov    %eax,%edx
f0101b6e:	09 ca                	or     %ecx,%edx
f0101b70:	09 f2                	or     %esi,%edx
f0101b72:	f6 c2 03             	test   $0x3,%dl
f0101b75:	75 0a                	jne    f0101b81 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101b77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101b7a:	89 c7                	mov    %eax,%edi
f0101b7c:	fc                   	cld    
f0101b7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101b7f:	eb 05                	jmp    f0101b86 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0101b81:	89 c7                	mov    %eax,%edi
f0101b83:	fc                   	cld    
f0101b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101b86:	5e                   	pop    %esi
f0101b87:	5f                   	pop    %edi
f0101b88:	5d                   	pop    %ebp
f0101b89:	c3                   	ret    

f0101b8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101b8a:	55                   	push   %ebp
f0101b8b:	89 e5                	mov    %esp,%ebp
f0101b8d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101b90:	ff 75 10             	pushl  0x10(%ebp)
f0101b93:	ff 75 0c             	pushl  0xc(%ebp)
f0101b96:	ff 75 08             	pushl  0x8(%ebp)
f0101b99:	e8 8a ff ff ff       	call   f0101b28 <memmove>
}
f0101b9e:	c9                   	leave  
f0101b9f:	c3                   	ret    

f0101ba0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101ba0:	55                   	push   %ebp
f0101ba1:	89 e5                	mov    %esp,%ebp
f0101ba3:	56                   	push   %esi
f0101ba4:	53                   	push   %ebx
f0101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101bab:	89 c6                	mov    %eax,%esi
f0101bad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101bb0:	39 f0                	cmp    %esi,%eax
f0101bb2:	74 1c                	je     f0101bd0 <memcmp+0x30>
		if (*s1 != *s2)
f0101bb4:	0f b6 08             	movzbl (%eax),%ecx
f0101bb7:	0f b6 1a             	movzbl (%edx),%ebx
f0101bba:	38 d9                	cmp    %bl,%cl
f0101bbc:	75 08                	jne    f0101bc6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101bbe:	83 c0 01             	add    $0x1,%eax
f0101bc1:	83 c2 01             	add    $0x1,%edx
f0101bc4:	eb ea                	jmp    f0101bb0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101bc6:	0f b6 c1             	movzbl %cl,%eax
f0101bc9:	0f b6 db             	movzbl %bl,%ebx
f0101bcc:	29 d8                	sub    %ebx,%eax
f0101bce:	eb 05                	jmp    f0101bd5 <memcmp+0x35>
	}

	return 0;
f0101bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101bd5:	5b                   	pop    %ebx
f0101bd6:	5e                   	pop    %esi
f0101bd7:	5d                   	pop    %ebp
f0101bd8:	c3                   	ret    

f0101bd9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101bd9:	55                   	push   %ebp
f0101bda:	89 e5                	mov    %esp,%ebp
f0101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101be2:	89 c2                	mov    %eax,%edx
f0101be4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101be7:	39 d0                	cmp    %edx,%eax
f0101be9:	73 09                	jae    f0101bf4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101beb:	38 08                	cmp    %cl,(%eax)
f0101bed:	74 05                	je     f0101bf4 <memfind+0x1b>
	for (; s < ends; s++)
f0101bef:	83 c0 01             	add    $0x1,%eax
f0101bf2:	eb f3                	jmp    f0101be7 <memfind+0xe>
			break;
	return (void *) s;
}
f0101bf4:	5d                   	pop    %ebp
f0101bf5:	c3                   	ret    

f0101bf6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101bf6:	55                   	push   %ebp
f0101bf7:	89 e5                	mov    %esp,%ebp
f0101bf9:	57                   	push   %edi
f0101bfa:	56                   	push   %esi
f0101bfb:	53                   	push   %ebx
f0101bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101c02:	eb 03                	jmp    f0101c07 <strtol+0x11>
		s++;
f0101c04:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101c07:	0f b6 01             	movzbl (%ecx),%eax
f0101c0a:	3c 20                	cmp    $0x20,%al
f0101c0c:	74 f6                	je     f0101c04 <strtol+0xe>
f0101c0e:	3c 09                	cmp    $0x9,%al
f0101c10:	74 f2                	je     f0101c04 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101c12:	3c 2b                	cmp    $0x2b,%al
f0101c14:	74 2a                	je     f0101c40 <strtol+0x4a>
	int neg = 0;
f0101c16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101c1b:	3c 2d                	cmp    $0x2d,%al
f0101c1d:	74 2b                	je     f0101c4a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101c1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101c25:	75 0f                	jne    f0101c36 <strtol+0x40>
f0101c27:	80 39 30             	cmpb   $0x30,(%ecx)
f0101c2a:	74 28                	je     f0101c54 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101c2c:	85 db                	test   %ebx,%ebx
f0101c2e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101c33:	0f 44 d8             	cmove  %eax,%ebx
f0101c36:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c3b:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101c3e:	eb 50                	jmp    f0101c90 <strtol+0x9a>
		s++;
f0101c40:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101c43:	bf 00 00 00 00       	mov    $0x0,%edi
f0101c48:	eb d5                	jmp    f0101c1f <strtol+0x29>
		s++, neg = 1;
f0101c4a:	83 c1 01             	add    $0x1,%ecx
f0101c4d:	bf 01 00 00 00       	mov    $0x1,%edi
f0101c52:	eb cb                	jmp    f0101c1f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101c54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101c58:	74 0e                	je     f0101c68 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101c5a:	85 db                	test   %ebx,%ebx
f0101c5c:	75 d8                	jne    f0101c36 <strtol+0x40>
		s++, base = 8;
f0101c5e:	83 c1 01             	add    $0x1,%ecx
f0101c61:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101c66:	eb ce                	jmp    f0101c36 <strtol+0x40>
		s += 2, base = 16;
f0101c68:	83 c1 02             	add    $0x2,%ecx
f0101c6b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101c70:	eb c4                	jmp    f0101c36 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101c72:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101c75:	89 f3                	mov    %esi,%ebx
f0101c77:	80 fb 19             	cmp    $0x19,%bl
f0101c7a:	77 29                	ja     f0101ca5 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101c7c:	0f be d2             	movsbl %dl,%edx
f0101c7f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101c82:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101c85:	7d 30                	jge    f0101cb7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101c87:	83 c1 01             	add    $0x1,%ecx
f0101c8a:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101c8e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101c90:	0f b6 11             	movzbl (%ecx),%edx
f0101c93:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101c96:	89 f3                	mov    %esi,%ebx
f0101c98:	80 fb 09             	cmp    $0x9,%bl
f0101c9b:	77 d5                	ja     f0101c72 <strtol+0x7c>
			dig = *s - '0';
f0101c9d:	0f be d2             	movsbl %dl,%edx
f0101ca0:	83 ea 30             	sub    $0x30,%edx
f0101ca3:	eb dd                	jmp    f0101c82 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0101ca5:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101ca8:	89 f3                	mov    %esi,%ebx
f0101caa:	80 fb 19             	cmp    $0x19,%bl
f0101cad:	77 08                	ja     f0101cb7 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0101caf:	0f be d2             	movsbl %dl,%edx
f0101cb2:	83 ea 37             	sub    $0x37,%edx
f0101cb5:	eb cb                	jmp    f0101c82 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101cb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101cbb:	74 05                	je     f0101cc2 <strtol+0xcc>
		*endptr = (char *) s;
f0101cbd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101cc0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101cc2:	89 c2                	mov    %eax,%edx
f0101cc4:	f7 da                	neg    %edx
f0101cc6:	85 ff                	test   %edi,%edi
f0101cc8:	0f 45 c2             	cmovne %edx,%eax
}
f0101ccb:	5b                   	pop    %ebx
f0101ccc:	5e                   	pop    %esi
f0101ccd:	5f                   	pop    %edi
f0101cce:	5d                   	pop    %ebp
f0101ccf:	c3                   	ret    

f0101cd0 <__udivdi3>:
f0101cd0:	55                   	push   %ebp
f0101cd1:	57                   	push   %edi
f0101cd2:	56                   	push   %esi
f0101cd3:	53                   	push   %ebx
f0101cd4:	83 ec 1c             	sub    $0x1c,%esp
f0101cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101cdb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101ce3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101ce7:	85 d2                	test   %edx,%edx
f0101ce9:	75 4d                	jne    f0101d38 <__udivdi3+0x68>
f0101ceb:	39 f3                	cmp    %esi,%ebx
f0101ced:	76 19                	jbe    f0101d08 <__udivdi3+0x38>
f0101cef:	31 ff                	xor    %edi,%edi
f0101cf1:	89 e8                	mov    %ebp,%eax
f0101cf3:	89 f2                	mov    %esi,%edx
f0101cf5:	f7 f3                	div    %ebx
f0101cf7:	89 fa                	mov    %edi,%edx
f0101cf9:	83 c4 1c             	add    $0x1c,%esp
f0101cfc:	5b                   	pop    %ebx
f0101cfd:	5e                   	pop    %esi
f0101cfe:	5f                   	pop    %edi
f0101cff:	5d                   	pop    %ebp
f0101d00:	c3                   	ret    
f0101d01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d08:	89 d9                	mov    %ebx,%ecx
f0101d0a:	85 db                	test   %ebx,%ebx
f0101d0c:	75 0b                	jne    f0101d19 <__udivdi3+0x49>
f0101d0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d13:	31 d2                	xor    %edx,%edx
f0101d15:	f7 f3                	div    %ebx
f0101d17:	89 c1                	mov    %eax,%ecx
f0101d19:	31 d2                	xor    %edx,%edx
f0101d1b:	89 f0                	mov    %esi,%eax
f0101d1d:	f7 f1                	div    %ecx
f0101d1f:	89 c6                	mov    %eax,%esi
f0101d21:	89 e8                	mov    %ebp,%eax
f0101d23:	89 f7                	mov    %esi,%edi
f0101d25:	f7 f1                	div    %ecx
f0101d27:	89 fa                	mov    %edi,%edx
f0101d29:	83 c4 1c             	add    $0x1c,%esp
f0101d2c:	5b                   	pop    %ebx
f0101d2d:	5e                   	pop    %esi
f0101d2e:	5f                   	pop    %edi
f0101d2f:	5d                   	pop    %ebp
f0101d30:	c3                   	ret    
f0101d31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d38:	39 f2                	cmp    %esi,%edx
f0101d3a:	77 1c                	ja     f0101d58 <__udivdi3+0x88>
f0101d3c:	0f bd fa             	bsr    %edx,%edi
f0101d3f:	83 f7 1f             	xor    $0x1f,%edi
f0101d42:	75 2c                	jne    f0101d70 <__udivdi3+0xa0>
f0101d44:	39 f2                	cmp    %esi,%edx
f0101d46:	72 06                	jb     f0101d4e <__udivdi3+0x7e>
f0101d48:	31 c0                	xor    %eax,%eax
f0101d4a:	39 eb                	cmp    %ebp,%ebx
f0101d4c:	77 a9                	ja     f0101cf7 <__udivdi3+0x27>
f0101d4e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d53:	eb a2                	jmp    f0101cf7 <__udivdi3+0x27>
f0101d55:	8d 76 00             	lea    0x0(%esi),%esi
f0101d58:	31 ff                	xor    %edi,%edi
f0101d5a:	31 c0                	xor    %eax,%eax
f0101d5c:	89 fa                	mov    %edi,%edx
f0101d5e:	83 c4 1c             	add    $0x1c,%esp
f0101d61:	5b                   	pop    %ebx
f0101d62:	5e                   	pop    %esi
f0101d63:	5f                   	pop    %edi
f0101d64:	5d                   	pop    %ebp
f0101d65:	c3                   	ret    
f0101d66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d6d:	8d 76 00             	lea    0x0(%esi),%esi
f0101d70:	89 f9                	mov    %edi,%ecx
f0101d72:	b8 20 00 00 00       	mov    $0x20,%eax
f0101d77:	29 f8                	sub    %edi,%eax
f0101d79:	d3 e2                	shl    %cl,%edx
f0101d7b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101d7f:	89 c1                	mov    %eax,%ecx
f0101d81:	89 da                	mov    %ebx,%edx
f0101d83:	d3 ea                	shr    %cl,%edx
f0101d85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101d89:	09 d1                	or     %edx,%ecx
f0101d8b:	89 f2                	mov    %esi,%edx
f0101d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101d91:	89 f9                	mov    %edi,%ecx
f0101d93:	d3 e3                	shl    %cl,%ebx
f0101d95:	89 c1                	mov    %eax,%ecx
f0101d97:	d3 ea                	shr    %cl,%edx
f0101d99:	89 f9                	mov    %edi,%ecx
f0101d9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101d9f:	89 eb                	mov    %ebp,%ebx
f0101da1:	d3 e6                	shl    %cl,%esi
f0101da3:	89 c1                	mov    %eax,%ecx
f0101da5:	d3 eb                	shr    %cl,%ebx
f0101da7:	09 de                	or     %ebx,%esi
f0101da9:	89 f0                	mov    %esi,%eax
f0101dab:	f7 74 24 08          	divl   0x8(%esp)
f0101daf:	89 d6                	mov    %edx,%esi
f0101db1:	89 c3                	mov    %eax,%ebx
f0101db3:	f7 64 24 0c          	mull   0xc(%esp)
f0101db7:	39 d6                	cmp    %edx,%esi
f0101db9:	72 15                	jb     f0101dd0 <__udivdi3+0x100>
f0101dbb:	89 f9                	mov    %edi,%ecx
f0101dbd:	d3 e5                	shl    %cl,%ebp
f0101dbf:	39 c5                	cmp    %eax,%ebp
f0101dc1:	73 04                	jae    f0101dc7 <__udivdi3+0xf7>
f0101dc3:	39 d6                	cmp    %edx,%esi
f0101dc5:	74 09                	je     f0101dd0 <__udivdi3+0x100>
f0101dc7:	89 d8                	mov    %ebx,%eax
f0101dc9:	31 ff                	xor    %edi,%edi
f0101dcb:	e9 27 ff ff ff       	jmp    f0101cf7 <__udivdi3+0x27>
f0101dd0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101dd3:	31 ff                	xor    %edi,%edi
f0101dd5:	e9 1d ff ff ff       	jmp    f0101cf7 <__udivdi3+0x27>
f0101dda:	66 90                	xchg   %ax,%ax
f0101ddc:	66 90                	xchg   %ax,%ax
f0101dde:	66 90                	xchg   %ax,%ax

f0101de0 <__umoddi3>:
f0101de0:	55                   	push   %ebp
f0101de1:	57                   	push   %edi
f0101de2:	56                   	push   %esi
f0101de3:	53                   	push   %ebx
f0101de4:	83 ec 1c             	sub    $0x1c,%esp
f0101de7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101deb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101def:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101df7:	89 da                	mov    %ebx,%edx
f0101df9:	85 c0                	test   %eax,%eax
f0101dfb:	75 43                	jne    f0101e40 <__umoddi3+0x60>
f0101dfd:	39 df                	cmp    %ebx,%edi
f0101dff:	76 17                	jbe    f0101e18 <__umoddi3+0x38>
f0101e01:	89 f0                	mov    %esi,%eax
f0101e03:	f7 f7                	div    %edi
f0101e05:	89 d0                	mov    %edx,%eax
f0101e07:	31 d2                	xor    %edx,%edx
f0101e09:	83 c4 1c             	add    $0x1c,%esp
f0101e0c:	5b                   	pop    %ebx
f0101e0d:	5e                   	pop    %esi
f0101e0e:	5f                   	pop    %edi
f0101e0f:	5d                   	pop    %ebp
f0101e10:	c3                   	ret    
f0101e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101e18:	89 fd                	mov    %edi,%ebp
f0101e1a:	85 ff                	test   %edi,%edi
f0101e1c:	75 0b                	jne    f0101e29 <__umoddi3+0x49>
f0101e1e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e23:	31 d2                	xor    %edx,%edx
f0101e25:	f7 f7                	div    %edi
f0101e27:	89 c5                	mov    %eax,%ebp
f0101e29:	89 d8                	mov    %ebx,%eax
f0101e2b:	31 d2                	xor    %edx,%edx
f0101e2d:	f7 f5                	div    %ebp
f0101e2f:	89 f0                	mov    %esi,%eax
f0101e31:	f7 f5                	div    %ebp
f0101e33:	89 d0                	mov    %edx,%eax
f0101e35:	eb d0                	jmp    f0101e07 <__umoddi3+0x27>
f0101e37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101e3e:	66 90                	xchg   %ax,%ax
f0101e40:	89 f1                	mov    %esi,%ecx
f0101e42:	39 d8                	cmp    %ebx,%eax
f0101e44:	76 0a                	jbe    f0101e50 <__umoddi3+0x70>
f0101e46:	89 f0                	mov    %esi,%eax
f0101e48:	83 c4 1c             	add    $0x1c,%esp
f0101e4b:	5b                   	pop    %ebx
f0101e4c:	5e                   	pop    %esi
f0101e4d:	5f                   	pop    %edi
f0101e4e:	5d                   	pop    %ebp
f0101e4f:	c3                   	ret    
f0101e50:	0f bd e8             	bsr    %eax,%ebp
f0101e53:	83 f5 1f             	xor    $0x1f,%ebp
f0101e56:	75 20                	jne    f0101e78 <__umoddi3+0x98>
f0101e58:	39 d8                	cmp    %ebx,%eax
f0101e5a:	0f 82 b0 00 00 00    	jb     f0101f10 <__umoddi3+0x130>
f0101e60:	39 f7                	cmp    %esi,%edi
f0101e62:	0f 86 a8 00 00 00    	jbe    f0101f10 <__umoddi3+0x130>
f0101e68:	89 c8                	mov    %ecx,%eax
f0101e6a:	83 c4 1c             	add    $0x1c,%esp
f0101e6d:	5b                   	pop    %ebx
f0101e6e:	5e                   	pop    %esi
f0101e6f:	5f                   	pop    %edi
f0101e70:	5d                   	pop    %ebp
f0101e71:	c3                   	ret    
f0101e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101e78:	89 e9                	mov    %ebp,%ecx
f0101e7a:	ba 20 00 00 00       	mov    $0x20,%edx
f0101e7f:	29 ea                	sub    %ebp,%edx
f0101e81:	d3 e0                	shl    %cl,%eax
f0101e83:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e87:	89 d1                	mov    %edx,%ecx
f0101e89:	89 f8                	mov    %edi,%eax
f0101e8b:	d3 e8                	shr    %cl,%eax
f0101e8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101e91:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101e95:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101e99:	09 c1                	or     %eax,%ecx
f0101e9b:	89 d8                	mov    %ebx,%eax
f0101e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ea1:	89 e9                	mov    %ebp,%ecx
f0101ea3:	d3 e7                	shl    %cl,%edi
f0101ea5:	89 d1                	mov    %edx,%ecx
f0101ea7:	d3 e8                	shr    %cl,%eax
f0101ea9:	89 e9                	mov    %ebp,%ecx
f0101eab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101eaf:	d3 e3                	shl    %cl,%ebx
f0101eb1:	89 c7                	mov    %eax,%edi
f0101eb3:	89 d1                	mov    %edx,%ecx
f0101eb5:	89 f0                	mov    %esi,%eax
f0101eb7:	d3 e8                	shr    %cl,%eax
f0101eb9:	89 e9                	mov    %ebp,%ecx
f0101ebb:	89 fa                	mov    %edi,%edx
f0101ebd:	d3 e6                	shl    %cl,%esi
f0101ebf:	09 d8                	or     %ebx,%eax
f0101ec1:	f7 74 24 08          	divl   0x8(%esp)
f0101ec5:	89 d1                	mov    %edx,%ecx
f0101ec7:	89 f3                	mov    %esi,%ebx
f0101ec9:	f7 64 24 0c          	mull   0xc(%esp)
f0101ecd:	89 c6                	mov    %eax,%esi
f0101ecf:	89 d7                	mov    %edx,%edi
f0101ed1:	39 d1                	cmp    %edx,%ecx
f0101ed3:	72 06                	jb     f0101edb <__umoddi3+0xfb>
f0101ed5:	75 10                	jne    f0101ee7 <__umoddi3+0x107>
f0101ed7:	39 c3                	cmp    %eax,%ebx
f0101ed9:	73 0c                	jae    f0101ee7 <__umoddi3+0x107>
f0101edb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101edf:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101ee3:	89 d7                	mov    %edx,%edi
f0101ee5:	89 c6                	mov    %eax,%esi
f0101ee7:	89 ca                	mov    %ecx,%edx
f0101ee9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101eee:	29 f3                	sub    %esi,%ebx
f0101ef0:	19 fa                	sbb    %edi,%edx
f0101ef2:	89 d0                	mov    %edx,%eax
f0101ef4:	d3 e0                	shl    %cl,%eax
f0101ef6:	89 e9                	mov    %ebp,%ecx
f0101ef8:	d3 eb                	shr    %cl,%ebx
f0101efa:	d3 ea                	shr    %cl,%edx
f0101efc:	09 d8                	or     %ebx,%eax
f0101efe:	83 c4 1c             	add    $0x1c,%esp
f0101f01:	5b                   	pop    %ebx
f0101f02:	5e                   	pop    %esi
f0101f03:	5f                   	pop    %edi
f0101f04:	5d                   	pop    %ebp
f0101f05:	c3                   	ret    
f0101f06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101f0d:	8d 76 00             	lea    0x0(%esi),%esi
f0101f10:	89 da                	mov    %ebx,%edx
f0101f12:	29 fe                	sub    %edi,%esi
f0101f14:	19 c2                	sbb    %eax,%edx
f0101f16:	89 f1                	mov    %esi,%ecx
f0101f18:	89 c8                	mov    %ecx,%eax
f0101f1a:	e9 4b ff ff ff       	jmp    f0101e6a <__umoddi3+0x8a>
