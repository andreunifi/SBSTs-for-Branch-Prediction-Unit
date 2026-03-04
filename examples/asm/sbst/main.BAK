#include "tests.h"
#include <stdint.h>

volatile uint32_t sig;

const signature_t const GOLDEN_SIGNATURES[NUMTESTS] = {
	0xCAFECAFE, // TEST1
	0x123494a0,	// TEST2
};




uint32_t compute_signature(void) {
    uint32_t t5, t6, s2, s3, s4;

    asm volatile (
        "csrr %0, 0xB04 \n\t"  // HPM0
        "csrr %1, 0xB05 \n\t"  // HPM1
        "csrr %2, 0xB06 \n\t"  // HPM2
        "csrr %3, 0xB07 \n\t"  // HPM3
        "csrr %4, 0xB08 \n\t"  // HPM4
        : "=r"(t5), "=r"(t6), "=r"(s2), "=r"(s3), "=r"(s4)
    );

    // Combine them into a single signature
    uint32_t sig = t5 + t6 + s2 + s3 + s4;

    return sig;  // a0 will automatically hold the return value



}

int main(void)
{




	int i, fails=0;
	signature_t signatures[NUMTESTS];
	
	// signatures[0] = test1();   // store return value in the first element


	for(i=0; i<NUMTESTS; i++) {
		if (i == 0) {
			signatures[TEST1] = test1();
		} else if (i == 1) {
		} else {
			uint32_t hpm_before = compute_signature();
			//This checks HPM values
			signatures[TEST2] = test2();
			uint32_t test_sig = test3();
			signatures[TEST4] = test4();
			//RUn test1() to check for misprediction
			uint32_t hpm_after = compute_signature();
			//
			signatures[i] = hpm_after - hpm_before;

			register uint32_t dbg asm("t0") = signatures[i]; //check it manually 
			
		}

		fails += signatures[i] != GOLDEN_SIGNATURES[i];
	}

 	return fails;
}