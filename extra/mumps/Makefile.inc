LSCOTCHDIR = /usr/lib
ISCOTCH   =

LSCOTCH   =

LPORDDIR = $(topdir)/PORD/lib/
IPORD    = -I$(topdir)/PORD/include/
LPORD    = -L$(LPORDDIR) -lpord$(PLAT)

LMETISDIR = /usr/lib
IMETIS    =

LMETIS    =

ORDERINGSF = -Dpord
ORDERINGSC  = $(ORDERINGSF)

LORDERINGS = $(LPORD)
IORDERINGSF =
IORDERINGSC = $(IPORD)

PLAT    =
LIBEXT_SHARED  = .so
SONAME = -soname
SHARED_OPT = -shared
FPIC_OPT = -fPIC
LIBEXT  = .a
OUTC    = -o
OUTF    = -o
RM = /bin/rm -f
CC = cc
FC = /usr/lib/llvm22/bin/flang-22
FL = /usr/lib/llvm22/bin/flang-22
AR = ar vr
RANLIB = ranlib
LAPACK = -lopenblas



INCSEQ = -I$(topdir)/libseq
LIBSEQ  = $(LAPACK) -L$(topdir)/libseq -lmpiseq$(PLAT)

LIBBLAS = -lopenblas
LIBOTHERS =

CDEFS   = -DAdd_

OPTF    = -O -fopenmp
OPTL    = -O -fopenmp
OPTC    = -O -fopenmp

INCS = $(INCSEQ) -I/usr/include
LIBS = $(LIBSEQ)
LIBSEQNEEDED = libseqneeded

