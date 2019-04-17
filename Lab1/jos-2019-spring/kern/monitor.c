// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display backtrace of kernel stack", mon_backtrace},
	{ "time", "Display running time (in clocks cycles) of the command", mon_time }
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
    return pretaddr;
}

static uint32_t
swap_endian(uint32_t val) {
	val = ((val << 8)&0xFF00FF00) | ((val >> 8)&0x00FF00FF);
	return (val << 16)|(val >> 16);
}	

void
do_overflow(void)
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
	// You should use a techique similar to buffer overflow
	// to invoke the do_overflow function and
	// the procedure must return normally.

    // And you must use the "cprintf" function with %n specifier
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    	char str[256] = {};
    	int nstr = 0;
    	int pret_addr;
	pret_addr = read_pretaddr();
	// Your code here.
//	f0100a6e
	cprintf("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000%n\n", str+268);
	cprintf("0000000000%n\n", str+269);
	cprintf("0000000000000000%n\n", str+270);
//	f0100bc6
	cprintf("000000000000000000000000000000000000000000000000000000000%n", str + 272);
	*(str + 272) = ~(*(str + 272));
	cprintf("00000000000%n\n", str + 273);
	cprintf("0000000000000000%n\n", str + 274);
}

void
overflow_me(void)
{
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	cprintf("Stack backtrace:\n");
	int ebp, eip;
	ebp = read_ebp();
	struct Eipdebuginfo info;
	while (ebp != 0x0) {
		eip = *((int*)ebp + 1);
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n", 
			eip, ebp, *((int*)ebp + 2), *((int*)ebp + 3),
			*((int*)ebp + 4), *((int*)ebp + 5), *((int*)ebp + 6));
		debuginfo_eip(eip, &info);
		*((char*)info.eip_fn_name + info.eip_fn_namelen) = '\0';
		cprintf("\t%s:%d %s+%d\n", info.eip_file, info.eip_line, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = *((int*)ebp);
	}
	overflow_me();
    	cprintf("Backtrace success\n");
	return 0;
}


void access_counter(unsigned *hi, unsigned *lo)
{
	asm("rdtsc; movl %%edx, %0; movl %%eax, %1"
		: "=r" (*hi), "=r" (*lo)
		: /* No input */
		: "%edx", "%eax");
	return;
}

void start_counter(unsigned *cyc_hi, unsigned *cyc_lo)
{
	access_counter(cyc_hi, cyc_lo);
	return;
}

/* Return the number of cycles since the last call to start_counter. */
double get_counter(unsigned *cyc_hi, unsigned *cyc_lo)
{
	unsigned int    ncyc_hi, ncyc_lo;
	unsigned int    hi, lo, borrow;
	double  result;

	/* Get cycle counter */
	access_counter(&ncyc_hi, &ncyc_lo);

	/* Do double precision subtraction */
	lo = ncyc_lo - *cyc_lo;
	borrow = lo > ncyc_lo;
	hi = ncyc_hi - *cyc_hi - borrow;

	result = (double)hi * (1 << 30) * 4 + lo;
	return result;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

int
mon_time(int argc, char **argv, struct Trapframe *tf) {
        unsigned int cyc_lo;
        unsigned int cyc_hi;
        double cnt;

        start_counter(&cyc_hi, &cyc_lo);
        runcmd(argv[1], tf);
        cnt = get_counter(&cyc_hi, &cyc_lo);
        cprintf("%s cycles: %d\n", argv[1], (int)cnt);
	return 0;
}


void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
