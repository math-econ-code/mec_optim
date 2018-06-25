
ifeq ($(CXX),)
	CXX=g++
endif

# core compiling options

CXX_STD = -std=c++11
OPT_FLAGS = -Wall -O3 -march=native -ffp-contract=fast -DNDEBUG -DARMA_NO_DEBUG

# source directories

SDIR = .
HEADER_DIR = $(SDIR)/include

# Armadillo files

ifeq ($(ARMA_INCLUDE_PATH),)
	ARMA_INCLUDE_PATH=$(HEADER_DIR)
endif

# general flags

CXXFLAGS = $(CXX_STD) $(OPT_FLAGS) -I$(ARMA_INCLUDE_PATH) -I$(HEADER_DIR)

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
	LIBS= -framework Accelerate

	APPLE_COMPILER := $(shell $(CXX) --version 2>&1 | grep -i -c -E 'apple llvm')
	ifeq ($(APPLE_COMPILER),0)
		OPT_FLAGS+= -fopenmp
	endif
else
	LIBS= -lblas
endif

# core files

SOURCES= ./bus_maintenance.cpp
OBJECTS= $(SOURCES:.cpp=.out)

all: $(OBJECTS)

$(SDIR)/%.out: $(SDIR)/%.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)

# cleanup and install
.PHONY: clean
clean:
	@rm -f ./*.out ./*.o
