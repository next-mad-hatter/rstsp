/*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 */

#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include "rstsp.h"

int main(int argc, const char **argv) {

  rstsp_open(argc, argv);

  uint32_t size = 5;
  uint32_t max_width = 0;
  uint32_t dst(uint32_t i, uint32_t j) { return i+j; }

  uint32_t **sol = rstsp_sbsearch(max_width, size, *dst);

  if(sol) {
    printf("  > Tour length: %" PRIu32 "\n", *sol[0]);
    printf("  > Tour: ");
    for(int i=0; i<size; i++) {
      printf("%" PRIu32, sol[1][i]+1);
      if(i+1<size) printf(" ");
    }
    printf("\n");
    free(sol[1]);
    free(sol[0]);
    free(sol);
  }

  rstsp_close();
  return 0;
}
