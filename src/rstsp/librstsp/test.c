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
#  define PRIu32 "u"
#endif

#ifndef PRIi64
#  if __WORDSIZE == 64
#    define PRIi64 "li"
#  else
#    define PRIi64 "lli"
#  endif
#endif

int64_t dst(uint32_t i, uint32_t j) {
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
   *   - a pointer to tour cost (int64);
   *   - a pointer to tour array (zero-based, closed cycle, word32)
   *   all packed in a pointer array.
   */
  Pointer *result;

  /**
   * We also want to avoid having to manually manage memory, therefore only
   * basic searches -- not their combinators -- are exposed through the library.
   *
   * This computes optimal pyramidal tour, writing a dot trace if so desired.
   */
  char *dotfilename = NULL;
  int64_t *cost;
  uint32_t *tour;
  result = (Pointer *)rstsp_pyr_search(prob_size, *dst, dotfilename);
  if(result) {
    cost = (int64_t *)result[0];
    tour = (uint32_t *)result[1];
    printf("  > Pyramidal tour: ");
    print_tour(tour, prob_size);
    printf("  > Tour cost: %" PRIi64 "\n", *cost);
    free(tour);
    free(cost);
    free(result);
  }

  /**
   * Optimal strongly balanced tour;  max_width : node size limit.
   */
  uint32_t max_width = 3;
  result = (Pointer *)rstsp_sb_search(prob_size, *dst, max_width, dotfilename);
  if(result) {
    cost = (int64_t *)result[0];
    tour = (uint32_t *)result[1];
    printf("  > SB tour: ");
    print_tour(tour, prob_size);
    printf("  > Tour cost: %" PRIi64 "\n", *cost);
    free(tour);
    free(cost);
    free(result);
  }

  /**
   * Iterative pyramidal search which considers up to n rotations in each
   * iteration.
   */
  uint32_t max_iters = 10;
  uint32_t stale_iters = 3;
  uint32_t max_rots = prob_size-1;
  result = (Pointer *)rstsp_iter_pyr_search(prob_size, *dst, max_iters, stale_iters, max_rots);
  if(result) {
    cost = (int64_t *)result[0];
    tour = (uint32_t *)result[1];
    printf("  > Pyramidal/iter/rot tour: ");
    print_tour(tour, prob_size);
    printf("  > Tour cost: %" PRIi64 "\n", *cost);
    free(tour);
    free(cost);
    free(result);
  }

  /**
   * Iterative strongly balanced search, flower size 1.5*n (ceil'ed).
   */
  max_rots = 2*prob_size;
  result = (Pointer *)rstsp_iter_sb_search(prob_size, *dst, max_width, max_iters, stale_iters, max_rots);
  if(result) {
    cost = (int64_t *)result[0];
    tour = (uint32_t *)result[1];
    printf("  > SB/iter/rot tour: ");
    print_tour(tour, prob_size);
    printf("  > Tour cost: %" PRIi64 "\n", *cost);
    free(tour);
    free(cost);
    free(result);
  }

  /**
   *  A variation of the above where number of considered rotations grows at
   *  stale iterations (which we call adaptive).
   */
  uint32_t min_rots = 0;
  result = (Pointer *)rstsp_ad_sb_search(prob_size, *dst, max_width, max_iters, stale_iters, min_rots, max_rots);
  if(result) {
    cost = (int64_t *)result[0];
    tour = (uint32_t *)result[1];
    printf("  > SB/adaptive tour: ");
    print_tour(tour, prob_size);
    printf("  > Tour cost: %" PRIi64 "\n", *cost);
    free(tour);
    free(cost);
    free(result);
  }

  /**
   *  A variant combining, in alternating, or flipflop, manner, adaptive s.b. &
   *  iterative pyramidal searches.
   */
  uint32_t max_flips = 0;
  result = (Pointer *)rstsp_ff_search(prob_size, *dst, max_width, max_iters, stale_iters, min_rots, max_rots, max_flips);
  if(result) {
    cost = (int64_t *)result[0];
    tour = (uint32_t *)result[1];
    printf("  > SB/flipflop tour: ");
    print_tour(tour, prob_size);
    printf("  > Tour cost: %" PRIi64 "\n", *cost);
    free(tour);
    free(cost);
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
