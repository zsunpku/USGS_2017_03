PROG = ex4
GPU_OUT = gpu
SERIAL_OUT = serial
include ../build_flags.inc
$(PROG): $(PROG).f90
	$(FC) $(FCFLAGS_GPU) -o $(PROG).$(GPU_OUT) $<
	$(FC) $(FCFLAGS_SERIAL) -o $(PROG).$(SERIAL_OUT) $<
all: $(PROG)
clean:
	@rm -rf *.gpu *.serial
