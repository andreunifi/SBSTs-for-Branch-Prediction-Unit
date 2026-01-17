#include "tests.h"
#include <stdint.h>

volatile uint32_t sig;

const signature_t const GOLDEN_SIGNATURES[NUMTESTS] = {
	0x123494a0,	// TEST1
};




__attribute__((noinline)) static void leaf(uint32_t x) {
  // piccola side-effect per evitare ottimizzazioni aggressive
  sig ^= x * 0x9e3779b9u;
}

// catena di profondità N: ogni livello fa call al prossimo e poi ritorna
__attribute__((noinline)) static void level(int d, uint32_t x) {
  sig ^= (uint32_t)d + x;
  leaf(sig);

  if (d > 0) {
    level(d - 1, x + 1);
  }

  // after return: altra side-effect
  leaf(sig ^ 0xA5A5A5A5u);
}

int main(void)
{
	//return 0;

	// sig = 0x12345678u;

	// // ripeti con profondità diverse per coprire più casi (anche > 16 se RAS=16)
	// level(4,  1);
	// level(8,  2);
	// level(20, 3);   // stress overflow/wrap/saturazione
  
	// // chiamate non annidate (push/pop singoli ripetuti)
	// for (int i = 0; i < 200; i++) {
	//   leaf((uint32_t)i);
	// }
  
	// // signature in RAM (per confronto nel testbench)
	// volatile uint32_t *out = (uint32_t*)0x80002000; // esempio: scegli area valida nella tua mappa
	// out[0] = sig;



	int i, fails=0;
	signature_t signatures[NUMTESTS];
	
	signatures[TEST1] = test1();

	for(i=0; i<NUMTESTS; i++) {
		fails += signatures[i] != GOLDEN_SIGNATURES[i];
	}

 	return fails;
}