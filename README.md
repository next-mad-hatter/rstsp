
#                       Pyramidal & Relaxed Supnick TSP

##                           Quick Start Guide

### Building


   ```
           ./bin/build.sh
   ```
   requires a working `mlton` installation.  Built executables and libraries
   will be put into `./src/rstsp/build/`.

   Building mingw binaries requires a suitable (i.e. featuring gmp)
   cross-compiler environment.

   If you don't have `exuberant-ctags` installed, simply ignore the ctags error
   message.

   For more details, see `./src/rstsp/build_*.sh` and `./src/rstsp/README.md`.

### Getting some test data

   To get sample tsp instances from tsplib, vlsi and dimacs datasets, run

   ```
          ./bin/fetch-data.sh
   ```
   -- which uses `wget`, `tar`, `gunzip` and `lynx` and takes about 60MB,
   plus about 20MB in `./tmp/` which can be cleaned afterwards.

   `./bin/data_stats.sh` will list present tsp instances sorted by
   probelm size (uses `ruby`).

### Running tests

   Try running, say,
   ```
   ./src/rstsp/build/rstsp.mlton ./test/data/tsplib/gr17.tsp
   ```
   for a sample run and `./src/rstsp/build/rstsp.mlton --help`
   to see command options.

   To execute an extensive test set, run

   ```
          ./bin/test.sh
   ```
   , which requires `ruby` ≥ 1.9.3 & `powerbar` gem.

   During its first run, this script will also generate random test data,
   which needs significant chunk of space -- about 200MB right now.

   Also takes some time (about 30 minutes on our machine right now) and memory
   (sometimes well over 3GB in our tests).

### Plotting test results


   ```
          ./bin/plot.sh
   ```
   will plot results of previous test run (requires `ruby` & `gnuplot`).
   Generated plots will be put to `./plot/out` folder.

### Packaging


   ```
          [env VERSION=my-great-build] ./bin/pkg.sh
   ```
   packages the crosscompiled version and puts it into `./tmp/`.

### Calling rstsp from your code

   Apart through the rstsp executable, you can call these tour search functions
   from C as well as from a SML environment.

   The C library interface is very straighforward -- see `./src/rstsp/librstsp/test.c`
   for example code, `./src/rstsp/build_lib.sh` and `./src/rstsp/README.md`
   for build details.

   For an example of using rstsp from SML repl,
   see `./src/rstsp/sample-session-*.sml` -- you will also have to include
   the library code first, which is done by running the repl in `./src/rstsp/` and

   - under SML/NJ  : `use "./rstsp/rstsp-smlnj.sml";`

   - under Poly/ML : `use "./rstsp/rstsp-polyml.sml";`
     (you'll have to export smlnj-lib from mlton for Poly/ML
     to use via `./src/rstsp/polyml/*.sh` scripts first).

