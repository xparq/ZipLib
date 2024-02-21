#-----------------------------------------------------------------------------
# Build options/defaults...
#

TOOLCHAIN ?= $(if $(or $(shell echo $(windir)),$(shell echo $(WINDIR))),$(if $(or $(shell echo $(VCToolsVersion)),$(shell echo $(VCToolsVersion))),msvc,mingw),linux)
$(info TOOLCHAIN: $(TOOLCHAIN))

LIB_MODE ?= static

#-----------------------------------------------------------------------------
# Project anatomy...
#

# These must all be relative to the build root, and must not be empty!
# (Use . for the root of the build tree!)
SRC_SUBDIR  = src
LIB_SUBDIR  = lib
TEST_SUBDIR = test

TEST_EXE = $(TEST_SUBDIR)/test-$(TOOLCHAIN)

ZIPLIB_STATIC = $(LIB_SUBDIR)/$(libname_prefix)ZipLib-$(TOOLCHAIN).$(libext_static)
ZIPLIB_SHARED = $(LIB_SUBDIR)/$(libname_prefix)ZipLib-$(TOOLCHAIN).$(libext_shared)

ifeq ($(LIB_MODE), static)
ZIPLIB = $(ZIPLIB_STATIC)
else
ZIPLIB = $(ZIPLIB_SHARED)
endif

SRC = \
	$(wildcard $(SRC_SUBDIR)/lib/*.cpp)        \
	$(wildcard $(SRC_SUBDIR)/lib/detail/*.cpp)

# Sources of external dependencies
SRC_ZLIB  = $(wildcard extlibs/zlib/*.c)
SRC_BZIP2 = $(wildcard extlibs/bzip2/*.c)
SRC_LZMA.linux  = $(wildcard extlibs/lzma/unix/*.c)
SRC_LZMA.mingw  = $(wildcard extlibs/lzma/*.c)
SRC_LZMA.msvc   = $(wildcard extlibs/lzma/*.c)
SRC_LZMA = ${SRC_LZMA.$(TOOLCHAIN)}


#-----------------------------------------------------------------------------
# Tool config...
#

# Compilers...
CC.linux       = clang
CXX.linux      = clang++
CC.mingw       = gcc
CXX.mingw      = g++
CC.msvc        = cl
CXX.msvc       = cl
CC  = ${CC.$(TOOLCHAIN)}
CXX = ${CXX.$(TOOLCHAIN)}
#$(info - Using compiler for C: $(CC), C++: $(CXX))

C_AND_CXX_FLAGS = -I. -Iinclude
C_AND_CXX_FLAGS.linux = -o $@ -Wall -Wno-enum-conversion -O3 -fPIC
C_AND_CXX_FLAGS.mingw = -o $@ -Wall -Wno-enum-conversion -O3
C_AND_CXX_FLAGS.msvc  = -Fo$@ -nologo -W4 -O2
C_AND_CXX_FLAGS.msvc.static =
C_AND_CXX_FLAGS.msvc.shared =
C_AND_CXX_FLAGS.msvc += ${C_AND_CXX_FLAGS.msvc.$(LIB_MODE)}
C_AND_CXX_FLAGS += ${C_AND_CXX_FLAGS.$(TOOLCHAIN)}

CFLAGS.linux =
CFLAGS.mingw =
CFLAGS.msvc  =
CFLAGS += $(C_AND_CXX_FLAGS) ${CFLAGS.$(TOOLCHAIN)}

CXXFLAGS.linux  = -std=c++11
CXXFLAGS.mingw  = -std=c++11 -D_POSIX_C_SOURCE # localtime_r is only enabled if _POSIX_C_SOURCE is defined! :-o
CXXFLAGS.msvc   = -EHsc -D_POSIX_C_SOURCE # Doesn't even recognize c++11 any more, so nothing to do.
CXXFLAGS += $(C_AND_CXX_FLAGS) ${CXXFLAGS.$(TOOLCHAIN)}

# Compiler options to use only when compiling objects for the lib:
CLIBFLAGS.linux  =
CLIBFLAGS.mingw  =
CLIBFLAGS.msvc.static = -Zl # Omit default lib
CLIBFLAGS.msvc.shared = -LD # Create DLL <-!! Likely irrelevant here, as it's a flag for linking!
CLIBFLAGS.msvc   = ${CLIBFLAGS.msvc.$(LIB_MODE)}
CLIBFLAGS = ${CLIBFLAGS.$(TOOLCHAIN)}

# Compiler options to use only when compiling & linking the test/demo:
CEXEFLAGS.linux  =
CEXEFLAGS.mingw  =
CEXEFLAGS.msvc   = -MT
CEXEFLAGS = ${CEXEFLAGS.$(TOOLCHAIN)}

# Lib builder
# - shared:
LIBTOOL_SHARED.linux  = $(CXX)
LIBTOOL_SHARED.mingw  = $(CXX)
LIBTOOL_SHARED.msvc   = lib
LIBTOOL_SHARED = ${LIBTOOL_SHARED.$(TOOLCHAIN)}
# + flags:
LIBTOOL_SHARED_FLAGS.linux   = -shared -o $@
LIBTOOL_SHARED_FLAGS.mingw   = -shared -o $@
LIBTOOL_SHARED_FLAGS.msvc    = -nologo -out:$@
LIBTOOL_SHARED_FLAGS = ${LIBTOOL_SHARED_FLAGS.$(TOOLCHAIN)}
# - static:
LIBTOOL_STATIC.linux  = ar
LIBTOOL_STATIC.mingw  = ar
LIBTOOL_STATIC.msvc   = lib
LIBTOOL_STATIC = ${LIBTOOL_STATIC.$(TOOLCHAIN)}
# + flags
LIBTOOL_STATIC_FLAGS.linux   = crvf -o $@
LIBTOOL_STATIC_FLAGS.mingw   = crvf -o $@
LIBTOOL_STATIC_FLAGS.msvc    = -nologo -out:$@
LIBTOOL_STATIC_FLAGS = ${LIBTOOL_STATIC_FLAGS.$(TOOLCHAIN)}

# Linker
LINKER.linux  = $(CXX)
LINKER.mingw  = $(CXX)
LINKER.msvc   = link
LINKER = ${LINKER.$(TOOLCHAIN)}
# - flags
LDFLAGS.linux   = -pthread -o $@
LDFLAGS.mingw   = -pthread -o $@ 
LDFLAGS.msvc    = -nologo -Fe:$@
LDFLAGS = ${LDFLAGS.$(TOOLCHAIN)}


#-----------------------------------------------------------------------------
# Src -> obj mapping, platform-specific filename suffix/prefix adjustments...
#

objext.msvc = obj
objext.linux = o
objext.mingw = o
objext = ${objext.$(TOOLCHAIN)}

OBJS = \
		$(SRC:.cpp=.$(objext))	   \
		$(SRC_ZLIB:.c=.$(objext))  \
		$(SRC_LZMA:.c=.$(objext))  \
		$(SRC_BZIP2:.c=.$(objext))

libext_static.msvc = lib
libext_static.linux = a
libext_static.mingw = a
libext_static = ${libext_static.$(TOOLCHAIN)}
libext_shared.msvc = dll
libext_shared.linux = so
libext_shared.mingw = so
libext_shared = ${libext_shared.$(TOOLCHAIN)}

libname_prefix.msvc =
libname_prefix.linux = lib
libname_prefix.mingw = lib
libname_prefix = ${libname_prefix.$(TOOLCHAIN)}


#-----------------------------------------------------------------------------
# Rules
#

all: $(TEST_EXE)

$(TEST_EXE): $(ZIPLIB)
	$(CXX) $(CXXFLAGS) $(CEXEFLAGS) $(SRC_SUBDIR)/test/Main.cpp $(LDFLAGS) $(ZIPLIB)

$(ZIPLIB_STATIC): $(OBJS)
	$(LIBTOOL_STATIC) $(LIBTOOL_STATIC_FLAGS) $^

$(ZIPLIB_SHARED): $(OBJS)
ifeq ($(TOOLCHAIN), linux) # Symlinking is fucked up on Windows...
	$(LIBTOOL_SHARED) $(LIBTOOL_SHARED_FLAGS) $^
	# This clownfest is needed on Linux to get the test exe find its shared lib... :-/
	# -> https://unix.stackexchange.com/questions/479421/how-to-link-to-a-shared-library-with-a-relative-path
	# Alas, -f fails to remove an existing target link, even though it should ovewrite it! :-o
	#ln -s -f "`realpath $(LIB_SUBDIR)`" "$(TEST_SUBDIR)/$(LIB_SUBDIR)"
	test ! -L "$(TEST_SUBDIR)/$(LIB_SUBDIR)" || rm "$(TEST_SUBDIR)/$(LIB_SUBDIR)"
	ln -s "`realpath $(LIB_SUBDIR)`" "$(TEST_SUBDIR)/$(LIB_SUBDIR)"
else ifeq ($(TOOLCHAIN), mingw) # But at least this still works on Windows (w64devkit) fortunately! :-o
	$(LIBTOOL_SHARED) $(LIBTOOL_SHARED_FLAGS) $^
	cp -f $(ZIPLIB_SHARED) $(TEST_SUBDIR)/
else ifeq ($(TOOLCHAIN), msvc)
	#!! Not supported yet!
endif


%.$(objext): %.cpp
	$(CXX) $(CXXFLAGS) $(CLIBFLAGS) -c $<

%.$(objext): %.c
	$(CC) $(CFLAGS) $(CLIBFLAGS) -c $<

clean:
ifeq ($(TOOLCHAIN), msvc)
	echo "NOT DOING: busybox rm -rf `find $(SRC_SUBDIR) -name '*.$(objext)'` ziplib.tar.gz $(TEST_SUBDIR)/*.zip $(TEST_SUBDIR)/out* $(TEST_EXE) $(ZIPLIB)""
else
	echo rm -rf `find $(SRC_SUBDIR) -name '*.$(objext)'` ziplib.tar.gz $(TEST_SUBDIR)/*.zip $(TEST_SUBDIR)/out* $(TEST_EXE) $(ZIPLIB)
endif

tarball:
ifeq ($(TOOLCHAIN), msvc)
	busybox tar -zcvf ziplib.tar.gz *
else
	tar -zcvf ziplib.tar.gz *
endif