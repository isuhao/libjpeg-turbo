#*********************************************************************************************************
# libjpeg-turbo Makefile
# target -> libjpeg.a  
#           libjpeg.so
#*********************************************************************************************************

#*********************************************************************************************************
# include config.mk
#*********************************************************************************************************
CONFIG_MK_EXIST = $(shell if [ -f ../config.mk ]; then echo exist; else echo notexist; fi;)
ifeq ($(CONFIG_MK_EXIST), exist)
include ../config.mk
else
CONFIG_MK_EXIST = $(shell if [ -f config.mk ]; then echo exist; else echo notexist; fi;)
ifeq ($(CONFIG_MK_EXIST), exist)
include config.mk
else
CONFIG_MK_EXIST =
endif
endif

#*********************************************************************************************************
# check configure
#*********************************************************************************************************
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))

$(call check_defined, CONFIG_MK_EXIST, Please configure this project in RealCoder or \
create a config.mk file!)
$(call check_defined, SYLIXOS_BASE_PATH, SylixOS base project path)
$(call check_defined, TOOLCHAIN_PREFIX, the prefix name of toolchain)
$(call check_defined, DEBUG_LEVEL, debug level(debug or release))

#*********************************************************************************************************
# configure area you can set the following config to you own system
# FPUFLAGS (-mfloat-abi=softfp -mfpu=vfpv3 ...)
# CPUFLAGS (-mcpu=arm920t ...)
# NOTICE: libsylixos, BSP and other kernel modules projects CAN NOT use vfp!
#*********************************************************************************************************
FPUFLAGS = 
CPUFLAGS = -mcpu=arm920t $(FPUFLAGS)

#*********************************************************************************************************
# toolchain select
#*********************************************************************************************************
CC  = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
AS  = $(TOOLCHAIN_PREFIX)gcc
AR  = $(TOOLCHAIN_PREFIX)ar
LD  = $(TOOLCHAIN_PREFIX)g++

#*********************************************************************************************************
# do not change the following code
# buildin internal application source
#*********************************************************************************************************
#*********************************************************************************************************
# src(s) file
#*********************************************************************************************************
SRCS = \
libjpeg-turbo/cdjpeg.c \
libjpeg-turbo/jaricom.c \
libjpeg-turbo/jcapimin.c \
libjpeg-turbo/jcapistd.c \
libjpeg-turbo/jcarith.c \
libjpeg-turbo/jccoefct.c \
libjpeg-turbo/jccolor.c \
libjpeg-turbo/jcdctmgr.c \
libjpeg-turbo/jchuff.c \
libjpeg-turbo/jcinit.c \
libjpeg-turbo/jcmainct.c \
libjpeg-turbo/jcmarker.c \
libjpeg-turbo/jcmaster.c \
libjpeg-turbo/jcomapi.c \
libjpeg-turbo/jcparam.c \
libjpeg-turbo/jcphuff.c \
libjpeg-turbo/jcprepct.c \
libjpeg-turbo/jcsample.c \
libjpeg-turbo/jctrans.c \
libjpeg-turbo/jdapimin.c \
libjpeg-turbo/jdapistd.c \
libjpeg-turbo/jdarith.c \
libjpeg-turbo/jdatadst.c \
libjpeg-turbo/jdatasrc.c \
libjpeg-turbo/jdcoefct.c \
libjpeg-turbo/jdcolor.c \
libjpeg-turbo/jddctmgr.c \
libjpeg-turbo/jdhuff.c \
libjpeg-turbo/jdinput.c \
libjpeg-turbo/jdmainct.c \
libjpeg-turbo/jdmarker.c \
libjpeg-turbo/jdmaster.c \
libjpeg-turbo/jdmerge.c \
libjpeg-turbo/jdphuff.c \
libjpeg-turbo/jdpostct.c \
libjpeg-turbo/jdsample.c \
libjpeg-turbo/jdtrans.c \
libjpeg-turbo/jerror.c \
libjpeg-turbo/jfdctflt.c \
libjpeg-turbo/jfdctfst.c \
libjpeg-turbo/jfdctint.c \
libjpeg-turbo/jidctflt.c \
libjpeg-turbo/jidctfst.c \
libjpeg-turbo/jidctint.c \
libjpeg-turbo/jidctred.c \
libjpeg-turbo/jmemmgr.c \
libjpeg-turbo/jmemnobs.c \
libjpeg-turbo/jquant1.c \
libjpeg-turbo/jquant2.c \
libjpeg-turbo/jutils.c \
libjpeg-turbo/rdswitch.c \
libjpeg-turbo/tjutil.c \
libjpeg-turbo/transupp.c \
libjpeg-turbo/md5/md5.c \
libjpeg-turbo/md5/md5hl.c \
libjpeg-turbo/simd/jsimd_arm.c \
libjpeg-turbo/simd/jsimd_arm_neon.c


#*********************************************************************************************************
# build path
#*********************************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OUTDIR = Debug
else
OUTDIR = Release
endif

OUTPATH = ./$(OUTDIR)
OBJPATH = $(OUTPATH)/obj
DEPPATH = $(OUTPATH)/dep

#*********************************************************************************************************
#  target
#*********************************************************************************************************
LIB = $(OUTPATH)/libjpeg.a
DLL = $(OUTPATH)/libjpeg.so

#*********************************************************************************************************
# objects
#*********************************************************************************************************
OBJS = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(SRCS))))
DEPS = $(addprefix $(DEPPATH)/, $(addsuffix .d, $(basename $(SRCS))))

#*********************************************************************************************************
# include path
#*********************************************************************************************************
INCDIR  = -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS"
INCDIR += -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS/include"
INCDIR += -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS/include/inet"

#*********************************************************************************************************
# compiler preprocess
#*********************************************************************************************************
DSYMBOL  = -DSYLIXOS
DSYMBOL += -DSYLIXOS_LIB 
DSYMBOL += -DSIZEOF_SIZE_T=4 -DXMD_H

#*********************************************************************************************************
# depend dynamic library
#*********************************************************************************************************
DEPEND_DLL = 

#*********************************************************************************************************
# depend dynamic library search path
#*********************************************************************************************************
DEPEND_DLL_PATH = 

#*********************************************************************************************************
# compiler optimize
#*********************************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OPTIMIZE = -O0 -g3 -gdwarf-2
else
OPTIMIZE = -O2 -g1 -gdwarf-2											# Do NOT use -O3 and -Os
endif										    						# -Os is not align for function
																		# loop and jump.
#*********************************************************************************************************
# depends and compiler parameter (cplusplus in kernel MUST NOT use exceptions and rtti)
#*********************************************************************************************************
DEPENDFLAG  = -MM
CXX_EXCEPT  = -fno-exceptions -fno-rtti
COMMONFLAGS = $(CPUFLAGS) $(OPTIMIZE) -Wall -fmessage-length=0 -fsigned-char -fno-short-enums
ASFLAGS     = -x assembler-with-cpp $(DSYMBOL) $(INCDIR) $(COMMONFLAGS) -c
CFLAGS      = $(DSYMBOL) $(INCDIR) $(COMMONFLAGS) -fPIC -c
CXXFLAGS    = $(DSYMBOL) $(INCDIR) $(CXX_EXCEPT) $(COMMONFLAGS) -fPIC -c
ARFLAGS     = -r

#*********************************************************************************************************
# define some useful variable
#*********************************************************************************************************
DEPEND          = $(CC)  $(DEPENDFLAG) $(CFLAGS)
DEPEND.d        = $(subst -g ,,$(DEPEND))
COMPILE.S       = $(AS)  $(ASFLAGS)
COMPILE_VFP.S   = $(AS)  $(ASFLAGS)
COMPILE.c       = $(CC)  $(CFLAGS)
COMPILE.cxx     = $(CXX) $(CXXFLAGS)

#*********************************************************************************************************
# target
#*********************************************************************************************************
all: $(LIB) $(DLL)
		@echo create "$(LIB) $(DLL)" success.

#*********************************************************************************************************
# include depends
#*********************************************************************************************************
ifneq ($(MAKECMDGOALS), clean)
ifneq ($(MAKECMDGOALS), clean_project)
sinclude $(DEPS)
endif
endif

#*********************************************************************************************************
# create depends files
#*********************************************************************************************************
$(DEPPATH)/%.d: %.c
		@echo creating $@
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		@rm -f $@; \
		echo -n '$@ $(addprefix $(OBJPATH)/, $(dir $<))' > $@; \
		$(DEPEND.d) $< >> $@ || rm -f $@; exit;

$(DEPPATH)/%.d: %.cpp
		@echo creating $@
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		@rm -f $@; \
		echo -n '$@ $(addprefix $(OBJPATH)/, $(dir $<))' > $@; \
		$(DEPEND.d) $< >> $@ || rm -f $@; exit;

#*********************************************************************************************************
# compile source files
#*********************************************************************************************************
$(OBJPATH)/%.o: %.S
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.S) $< -o $@

$(OBJPATH)/%.o: %.c
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.c) $< -o $@

$(OBJPATH)/%.o: %.cpp
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.cxx) $< -o $@

#*********************************************************************************************************
# link libjpeg.a object files
#*********************************************************************************************************
$(LIB): $(OBJS)
		$(AR) $(ARFLAGS) $(LIB) $(OBJS)

#*********************************************************************************************************
# link libjpeg.so object files
#*********************************************************************************************************
$(DLL): $(OBJS)
		$(LD) $(CPUFLAGS) -nostdlib -fPIC -shared -o $(DLL) $(OBJS) \
		$(DEPEND_DLL_PATH) $(DEPEND_DLL) -lm -lgcc

#*********************************************************************************************************
# clean
#*********************************************************************************************************
.PHONY: clean
.PHONY: clean_project

#*********************************************************************************************************
# clean objects
#*********************************************************************************************************
clean:
		-rm -rf $(LIB)
		-rm -rf $(DLL)
		-rm -rf $(OBJPATH)
		-rm -rf $(DEPPATH)

#*********************************************************************************************************
# clean project
#*********************************************************************************************************
clean_project:
		-rm -rf $(OUTPATH)

#*********************************************************************************************************
# END
#*********************************************************************************************************
