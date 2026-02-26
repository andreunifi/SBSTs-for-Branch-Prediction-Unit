#include "tests.h"


const signature_t const GOLDEN_SIGNATURES[NUMTESTS] = {
	0xCAFECAFE,	// TEST1 – placeholder (set from golden simulation)
	0xCAFECAFE,	// TEST2 – placeholder (set from golden simulation)
	0xCAFECAFE,	// TEST3 – placeholder (set from golden simulation)
};

int main(void)
{
	int i, fails;
	signature_t signatures[NUMTESTS];
	
	signatures[TEST1] = test1();
	signatures[TEST2] = test2();
	signatures[TEST3] = test3();

	for(i=0; i<NUMTESTS; i++) {
		fails += signatures[i] != GOLDEN_SIGNATURES[i];
	}

 	return fails;
}