# Pyramidal & Relaxed Supnick TSP

## Quick Start Guide

### Building

   ```
           ./bin/build.sh
   ```
   requires a working `mlton` installation.

   Building the mingw binary requires a suitable (i.e. featuring gmp)
   cross-compiler environment.

   For details, see `./src/rstsp/build_*.sh` and `./src/rstsp/README.md`.

### Getting more test data

   ```
          ./bin/fetch-data.sh
   ```
   uses `wget`, `tar`, `gunzip` and `lynx` and takes about 60MB,
   plus about 20MB in `./tmp/` which can be cleaned afterwards.

### Running tests

   ```
          ./bin/test.sh
   ```
   requires `ruby` & powerbar gem.

   At first run, this will also generate random test data,
   which needs significant chunk of space -- about 200MB right now.

### Plotting test results

   ```
          ./bin/plot.sh
   ```
   requires `ruby` & `gnuplot`.

   Generated plots will be put to `./plot/out` folder.

### Packaging

   ```
          [env VERSION=my-great-build] ./bin/pkg.sh
   ```
   packages the crosscompiled version and puts it into `./tmp/`.

