# RSTSP

## Quick Source Guide

### What this directory contains:

     * `./build_*`  : build scripts
     * `./pkg_*`    : packaging scripts
     * `./clean.sh` : clean script

     * `./polyml`   : scripts for using MLton's smlnj-lib under Poly/ML

     * `./win32/`   : is used by mlton crosscompiler and should include

                      `libgmp.a`      : empty archive
                      `libdmp-10.dll` : mingw libgmp dl
                      `include/gmp.h` : mingw libgmp header
                      `pkg/           : mingw libgmp source (see `./build_mingw.sh`)

     * `./build/` : built binaries

     * source ...

### Making smlnj-lib available under Poly/ML

### Crosscompiler setup

