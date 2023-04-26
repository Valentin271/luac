# ======================================================
#
# Example Makefile to include Lua into C application
#
# ===========================

##########################################################################################
#                                       VARIABLES                                        #
##########################################################################################

.PHONY: all clean configure

PROJECT_VERSION  = 0.1.0
PROJECT_NAME     = luac

# LINUX,WIN,MAC
TARGET_OS       ?=

# DEBUG,RELEASE
BUILD_MODE      ?= DEBUG

SOURCE_PATH     ?= src
SOURCE_FILES    ?= \
	main.c

# Define all object files from source files
OBJS = $(patsubst %.c, $(SOURCE_PATH)/%.o, $(SOURCE_FILES))

CC              ?= gcc
CFLAGS           = -std=c99 -Wall
INCLUDE_PATHS    =
LDFLAGS          =
LDLIBS           =

MAKE            ?= make

LUA_SUPPORT     ?= true
LUA_VERSION     ?= 5.4.4
LUA_DIR         ?= lua-$(LUA_VERSION)


##########################################################################################
#                                      CONDITIONALS                                      #
##########################################################################################

# Determine OS if not already set
ifndef TARGET_OS
	ifeq ($(OS),Windows_NT)
		TARGET_OS = WIN
	else
		UNAMEOS = $(shell uname)
		ifeq ($(UNAMEOS),Darwin)
			TARGET_OS = MAC
		else
			TARGET_OS = LINUX
		endif
	endif
endif

# Configure build for release or debug
ifeq ($(BUILD_MODE),RELEASE)
	CFLAGS += -s -O2
else
	CFLAGS += -g -DDEBUG
endif

ifeq ($(LUA_SUPPORT), true)
	SOURCE_FILES   +=
	CFLAGS         += -DLUA_SUPPORT
	INCLUDE_PATHS  += -I$(LUA_DIR)/install/include
	LDFLAGS        += -L$(LUA_DIR)/install/lib
	LDLIBS         += -llua -lm
endif


##########################################################################################
#                                      BUILD STEPS                                       #
##########################################################################################

all: build

build: $(OBJS)
	$(CC) -o $(PROJECT_NAME) $(OBJS) $(CFLAGS) $(LDFLAGS) $(INCLUDE_PATHS) $(LDLIBS)

# NOTE: This pattern will compile every module defined on $(OBJS)
%.o: %.c
	$(CC) -c $< -o $@ $(CFLAGS) -D$(TARGET_OS) $(INCLUDE_PATHS) $(LDFLAGS) $(LDLIBS)


configure: _lua

_lua:
ifeq ($(LUA_SUPPORT), true)
	curl http://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz -o - | tar -xzf -
	$(MAKE) -C $(LUA_DIR)
	$(MAKE) -C $(LUA_DIR) local
endif


clean:
ifeq ($(TARGET_OS),WIN)
	del $(OBJS) $(PROJECT_NAME).exe /s
else
	rm $(PROJECT_NAME) $(OBJS)
endif
	@echo "Cleaning done"

dist-clean: clean
	rm -r $(LUA_DIR)
