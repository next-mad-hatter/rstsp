# RSTSP

## Quick Source Guide

### Contents -- utilities:

    * `./*.sh`       : housekeeping scripts
    * `./polyml`     : scripts for using MLton's smlnj-lib under Poly/ML
    * `./win32/`     : is used by mlton crosscompiler
    * `./build/`     : built binaries

### Source structure

    * `./common/`     : frequently used bits
    * `./tspgraph/`   : tsp search tree descriptions
    * `./tspsearch/`  : tsp search tree traversal
    * `./main/`       : rstsp utility's common functionality
    * `./librstsp`    : shared library interface
    * `./rstsp/`      : toplevel includes
    * `./experimental/`   : concurrency code, not necessarily functional
    * `./sample-session-*.sml` : sample code as it could be used in a SML REPL

### Making smlnj-lib available under Poly/ML

### Crosscompiler setup

    * `./win32/`   : is used by mlton crosscompiler and should include

        - `libgmp.a`      : empty archive
        - `libdmp-10.dll` : mingw libgmp dl
        - `include/gmp.h` : mingw libgmp header
        - `pkg/           : mingw libgmp source (see `./build_mingw.sh`)

