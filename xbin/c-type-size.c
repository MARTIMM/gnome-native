/*
 compile: gcc -o c-type-size c-type-size.c

 See also:
   https://www.tutorialspoint.com/c_standard_library/limits_h.htm
   https://www.tutorialspoint.com/cprogramming/c_data_types.htm
   https://en.wikibooks.org/wiki/C_Programming/limits.h
   https://www.gnu.org/software/libc/manual/html_node/Range-of-Type.html
*/

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <float.h>

int main(int argc, char** argv) {

  printf("CHAR_BIT : %d\n", CHAR_BIT);
  printf("CHAR_MAX : %d\n", CHAR_MAX);
  printf("CHAR_MIN : %d\n", CHAR_MIN);

  printf("INT_MAX  : %d\n", INT_MAX);
  printf("INT_MIN  : %d\n", INT_MIN);
  printf("UINT_MAX : %u\n", (unsigned int) UINT_MAX);

  printf("LONG_MAX : %ld\n", (long) LONG_MAX);
  printf("LONG_MIN : %ld\n", (long) LONG_MIN);
  printf("ULONG_MAX: %lu\n", (unsigned long) ULONG_MAX);

  printf("SCHAR_MAX: %d\n", SCHAR_MAX);
  printf("SCHAR_MIN: %d\n", SCHAR_MIN);
  printf("SHRT_MAX : %d\n", SHRT_MAX);
  printf("SHRT_MIN : %d\n", SHRT_MIN);
  printf("UCHAR_MAX: %d\n", UCHAR_MAX);
  printf("USHRT_MAX: %d\n", (unsigned short) USHRT_MAX);

  return 0;
}
