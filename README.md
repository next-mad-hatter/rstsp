
## This is where a readme is going to be :).

For now, try:

1. Building:

           ./bin/build.sh
   This requires a working mlton installation.
   Building the mingw binary requires a suitable
   (i.e. featuring gmp) cross-compiler environment.
   For details, see `./src/rstsp/build_*.sh`.

2. Running tests:

          ./bin/test.sh
   Requires ruby & powerbar gem.

3. Plotting test results:

          ./bin/plot.sh
   This requires ruby & gnuplot.
   The plots will be put to ./plot/out folder.

4. Packaging:

          [env VERSION=my-great-build] ./bin/pkg.sh
   Packages the crosscompiled version and puts it into `./tmp/`.

