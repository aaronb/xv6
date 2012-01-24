# C compiler options
# http://gcc.gnu.org/onlinedocs/gcc-4.4.6/gcc/Invoking-GCC.html
CC = gcc
# enable extra warnings
CFLAGS += -Wall
# treat warnings as errors
CFLAGS += -Werror
# produce debugging information for use by gdb
CFLAGS += -ggdb

# uncomment to enable optimizations. improves performance, but may make 
# debugging more difficult
#CFLAGS += -O2

# C Preprocessor
CPP = cpp

# Assembler options
# http://sourceware.org/binutils/docs/as/Invoking.html
AS = gcc
ASFLAGS += -ggdb # produce debugging information for use by gdb

# Linker options
# http://sourceware.org/binutils/docs/ld/Options.html
LD = ld

OBJCOPY = objcopy

OBJDUMP = objdump
