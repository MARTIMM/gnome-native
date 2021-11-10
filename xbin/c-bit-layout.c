/*
  From question asked at https://stackoverflow.com/questions/68535802/bit-fields-are-assigned-left-to-right-on-some-machines-and-right-to-left-on-oth
*/
#include <stdio.h>
#include <stdint.h>

union {
  uint32_t Everything;
  struct {
    uint32_t FirstMentionedBit : 1;
    uint32_t FewOTherBits      :30;
    uint32_t LastMentionedBit  : 1;
  } bitfield;
} Demonstration;

int main() {
  Demonstration.Everything                 = 0;
  Demonstration.bitfield.LastMentionedBit  = 1;

  printf("%x\n", Demonstration.Everything);

  Demonstration.Everything                 = 0;
  Demonstration.bitfield.FirstMentionedBit = 1;

  printf("%x\n", Demonstration.Everything);

  return 0;
}
