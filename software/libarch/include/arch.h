#ifndef __SOFT_RISCV_ARCH_H
#define __SOFT_RISCV_ARCH_H

// Standard success definition
#define EXIT_SUCCESS (0)

/// Int types:
typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef unsigned short uint16_t;
typedef signed short int16_t;
typedef unsigned int uint32_t;
typedef signed int int32_t;
typedef unsigned long long uint64_t;
typedef signed long long int64_t;
typedef uint32_t size_t;

// Error type (negative indicating error)
typedef int err_t;

// Success
#define ERR_SUCCESS     (0)
// Argument error
#define ERR_EARGS       (-1)

// The end address of program memory
extern void* _end;

extern void* __program_start;

// The start address of heap memory
extern void* __heap_start;


/* The start of IO memory*/
#define MEM_IO_START    ((void*)0x00)
/* The end of IO memory*/
#define MEM_IO_END      (__program_start)
/* The start of program memory*/
#define MEM_PROG_START  (__program_start)
/* The end of program memory*/
#define MEM_PROG_END    (_end)
/* The start of heap memory*/
#define MEM_HEAP_START  (__heap_start)
/* The start of stack memory (grows down)*/
#define MEM_STACK_START ((void*)0xFFFFC)
/* The start of VGA buffer 1 memory*/
#define MEM_VGA_1_START ((void*)0x100000)
/* The start of VGA buffer 2 memory*/
#define MEM_VGA_2_START ((void*)0x200000)



#endif