
## This is where a readme is going to be :).

For now, try:

### Building:

           ./bin/build.sh
   This requires a working mlton installation.
   Building the mingw binary requires a suitable
   (i.e. featuring gmp) cross-compiler environment.
   For details, see `./src/rstsp/build_*.sh` and `./src/rstsp/README.md`.

### Getting more test data:

          ./bin/fetch-data.sh
   This uses wget, tar, gunzip and lynx (for tsplib solutions file).
   Needs space.  `./tmp/` should probably be cleaned sometime after this.

### Running tests:

          ./bin/test.sh
   Requires ruby & powerbar gem.
   This will also generate random test data, which needs space.

### Plotting test results:

          ./bin/plot.sh
   This requires ruby & gnuplot.
   The plots will be put to ./plot/out folder.

### Packaging:

          [env VERSION=my-great-build] ./bin/pkg.sh
   Packages the crosscompiled version and puts it into `./tmp/`.

