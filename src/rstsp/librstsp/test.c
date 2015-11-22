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
  int i;
  for(i=0; i<size+1; i++) {
    printf("%" PRIu32, tour[i]+1);
    if(i<size) printf(" ");
  }
  printf("\n");
}

int main(int argc, const char **argv) {

  /**
   * Yes, this is important.
   */
  rstsp_open(argc, argv);

  uint32_t prob_size = 10;

  /**
   * We do not want want to deal with structure alignment for different
   * platforms, hence a call to search function shall yield:
   *   - a pointer to tour length;
   *   - a pointer to tour array (zero-based, closed cycle)
   *   all packed in a pointer array.
   */
  uint32_t **result;

  /**
   * We also want to avoid having to manually manage memory, therefore only
   * basic searches -- not their combinators -- are exposed through the library.
   *
   * What follows is simple pyramidal search.
   */
  char *dotfilename = NULL;
  result = (uint32_t **)rstsp_pyr_search(prob_size, *dst, dotfilename);
  if(result) {
    printf("  > Pyramidal tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  /**
   * Simple balanced search;  max_width : node size limit.
   */
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

  /**
   * Iterative pyramidal search which considers up to `rotations` cyclic permutations in
   * each iteration and reorders for next.
   */
  uint32_t max_iters = 10;
  uint32_t stale_iters = 3;
  uint32_t rotations = prob_size-1;
  result = (uint32_t **)rstsp_iter_pyr_search(prob_size, *dst, max_iters, stale_iters, rotations);
  if(result) {
    printf("  > Pyramidal/iter/rot tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  /**
   * Iterative balanced search which, additionally to reordering, considers up to `rotations`
   * "balanced shift"-permutations in each iteration.
   */
  result = (uint32_t **)rstsp_iter_sb_search(prob_size, *dst, max_width, max_iters, stale_iters, rotations+1);
  if(result) {
    printf("  > SB/iter/rot tour: ");
    print_tour(result[1], prob_size);
    printf("  > Tour length: %" PRIu32 "\n", *result[0]);
    free(result[1]);
    free(result[0]);
    free(result);
  }

  /**
   * Since SML offers garbage collection, the library should be clean from leaks in
   * userspace.  Please note that valgrind has issues with mlton's memory management
   * and reports lots of invalid memory accesses.  These messages should be harmless --
   * we might one day also supply a valgrind whitelist.
   */
  rstsp_close();
  return 0;
}
