# RSTSP

## Quick Source Guide

### Contents -- utilities:

     * `./build_*.sh` : build scripts
     * `./pkg_*.sh`   : packaging scripts
     * `./clean.sh`   : clean script

     * `./polyml`     : scripts for using MLton's smlnj-lib under Poly/ML
     * `./win32/`     : is used by mlton crosscompiler
     * `./build/`     : built binaries

### Source structure

     * `./rstsp/`      : toplevel

     * `./common/`     : frequently used bits
     * `./tspgraph/`   : tsp search graphs
     * `./tspsearch/`  : tsp search graph traversal implementations
     * `./main/`       : rstsp utility's common functionality

     * `./threaded/`   : experimental code

### Making smlnj-lib available under Poly/ML

### Loading SML/NJ or Poly/ML repl

### Crosscompiler setup

     * `./win32/`   : is used by mlton crosscompiler and should include

                      `libgmp.a`      : empty archive
                      `libdmp-10.dll` : mingw libgmp dl
                      `include/gmp.h` : mingw libgmp header
                      `pkg/           : mingw libgmp source (see `./build_mingw.sh`)

