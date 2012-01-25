# The make utility automatically determines which pieces of a large program
# need to be recompiled, and issues commands to recompile them. This file tells
# make how to compile and link the program. This makefile also tells make how
# to run miscellaneous commands when explicitly asked (for example, to run an
# emulator after building the correct filesystem image, or to remove certain
# files as a clean-up operation).
#
# http://www.gnu.org/software/make/manual/


################################################################################
# Emulator Options
################################################################################

# If the makefile can't find QEMU, specify its path here
#QEMU =

# Try to infer the correct QEMU if not specified
ifndef QEMU
QEMU = $(shell if which qemu > /dev/null; \
	then echo qemu; exit; \
	else \
	qemu=/u/c/s/cs537-1/ta/tools/qemu; \
	if test -x $$qemu; then echo $$qemu; exit; fi; fi; \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your " 1>&2; \
	echo "*** PATH or have you tried setting the QEMU variable in " 1>&2; \
	echo "*** Makefile?" 1>&2; \
	echo "***" 1>&2; exit 1)
endif

# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)

# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)

# number of CPUs to emulate in QEMU
ifndef CPUS
CPUS := 2
endif

QEMUOPTS = -hdb fs.img xv6.img -smp $(CPUS)

# delete target if error building it
.DELETE_ON_ERROR:

include common.mk
include kernel/makefile.mk
include user/makefile.mk
include tools/makefile.mk
DEPS := $(KERNEL_DEPS) $(USER_DEPS) $(TOOLS_DEPS)
CLEAN := $(KERNEL_CLEAN) $(USER_CLEAN) $(TOOLS_CLEAN) fs fs.img


################################################################################
# Main Targets
################################################################################

.PHONY: all clean distclean tags dvi html pdf ps \
	run qemu qemu-nox qemu-gdb qemu-nox-gdb bochs depend \
	kernel tools user

all: xv6.img fs.img

clean:
	rm -rf $(CLEAN)

distclean: clean
	rm -f TAGS .gdbinit .bochsrc

tags: TAGS
TAGS: $(OBJS) bootother.S init.o
	etags *.S *.c

run: qemu

qemu: fs.img xv6.img
	$(QEMU) -serial mon:stdio $(QEMUOPTS)

qemu-nox: fs.img xv6.img
	$(QEMU) -nographic $(QEMUOPTS)

qemu-gdb: fs.img xv6.img .gdbinit
	@echo "*** Now run 'gdb'." 1>&2
	$(QEMU) -serial mon:stdio $(QEMUOPTS) -S $(QEMUGDB)

qemu-nox-gdb: fs.img xv6.img .gdbinit
	@echo "*** Now run 'gdb'." 1>&2
	$(QEMU) -nographic $(QEMUOPTS) -S $(QEMUGDB)

bochs: fs.img xv6.img .bochsrc
	bochs -q

depend: $(DEPS)

################################################################################
# Build Recipies
################################################################################

-include $(DEPS)


%.asm: %.o
	$(OBJDUMP) -S $< > $@

%.sym: %.o
	$(OBJDUMP) -t $< | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $@

fs:
	mkdir -p fs

fs/%: user/bin/%
	cp $< $@

fs/README: README | fs
	cp $< $@

USER_BINS := $(notdir $(USER_PROGS))
fs.img: tools/mkfs fs/README $(addprefix fs/,$(USER_BINS))
	./tools/mkfs fs.img fs

.gdbinit: tools/dot-gdbinit
	sed "s/localhost:1234/localhost:$(GDBPORT)/" < $^ > $@

.bochsrc: tools/dot-bochsrc
	cp dot-bochsrc .bochsrc

