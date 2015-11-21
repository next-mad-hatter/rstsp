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

#ifndef PRIu32
#define PRIu32 "u"
#endif

uint32_t dst(uint32_t i, uint32_t j) {
  return i+j;
}

void print_tour(uint32_t *tour, uint32_t size) {
    for(int i=0; i<size+1; i++) {
      printf("%" PRIu32, tour[i]+1);
      if(i<size) printf(" ");
    }
    printf("\n");
}

int main(int argc, const char **argv) {

  rstsp_open(argc, argv);

  uint32_t prob_size = 10;

  char *dotfilename = NULL;
  uint32_t **result = (uint32_t **)rstsp_pyr_search(prob_size, *dst, dotfilename);
  if(result) {
    printf("  > Pyramidal tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  uint32_t max_width = 3;
  result = (uint32_t **)rstsp_sb_search(prob_size, *dst, max_width, dotfilename);
  if(result) {
    printf("  > SB tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  uint32_t max_iters = 10;
  uint32_t stale_iters = 3;
  uint32_t rotations = prob_size - 1;
  result = (uint32_t **)rstsp_ir_pyr_search(prob_size, *dst, max_iters, stale_iters, rotations);
  if(result) {
    printf("  > Pyramidal/iter/rot tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  result = (uint32_t **)rstsp_ir_sb_search(prob_size, *dst, max_width, max_iters, stale_iters, rotations);
  if(result) {
    printf("  > SB/iter/rot tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  rstsp_close();
  return 0;
}
