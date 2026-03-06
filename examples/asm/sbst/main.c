#include "tests.h"
#include <stdint.h>

volatile uint32_t sig;

const signature_t const GOLDEN_SIGNATURES[NUMTESTS] = {
	0xCAFECAFE // TEST1
	//0x123494a0,	// TEST2
};

signature_t ACTUAL_SIGNATURES[NUMTESTS] = {};




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

	uint32_t hpm_before = compute_signature();

	test1();

	uint32_t hpm_after = compute_signature();

	ACTUAL_SIGNATURES[i] = hpm_after - hpm_before; //store the difference in the first element

	register uint32_t dbg1 asm("t0") = ACTUAL_SIGNATURES[i]; //check it manually 

	i++;

	hpm_before = compute_signature();

	test2();

	hpm_after = compute_signature();

	ACTUAL_SIGNATURES[i] = hpm_after - hpm_before; //store the difference in the second element

	register uint32_t dbg2 asm("t0") = ACTUAL_SIGNATURES[i]; //check it manually 

	i++;


	hpm_before = compute_signature();

	test3();

	hpm_after = compute_signature();

	ACTUAL_SIGNATURES[i] = hpm_after - hpm_before; //store the difference in the second element

	register uint32_t dbg3 asm("t0") = ACTUAL_SIGNATURES[i]; //check it manually 

	i=7;


	hpm_before = compute_signature();

	test7();

	hpm_after = compute_signature();

	ACTUAL_SIGNATURES[i] = hpm_after - hpm_before; //store the difference in the second element

	register uint32_t dbg7 asm("t0") = ACTUAL_SIGNATURES[i]; //check it manually 

	i++;


	hpm_before = compute_signature();

	test8();

	hpm_after = compute_signature();

	ACTUAL_SIGNATURES[i] = hpm_after - hpm_before; //store the difference in the second element

	register uint32_t dbg8 asm("t0") = ACTUAL_SIGNATURES[i]; //check it manually 

	i++;





	for(i=0; i<NUMTESTS; i++) {
		if (ACTUAL_SIGNATURES[i] != GOLDEN_SIGNATURES[i]) {
			fails++; 
		}
	}		

 	return fails;
}