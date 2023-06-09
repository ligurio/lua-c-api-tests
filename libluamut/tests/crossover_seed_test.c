#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#ifndef lengthof
#  define lengthof(array) (sizeof (array) / sizeof ((array)[0]))
#endif

#ifdef __cplusplus
extern "C" {
#endif

size_t
LLVMFuzzerCustomCrossOver(const uint8_t *Data1, size_t Size1,
	                      const uint8_t *Data2, size_t Size2,
	                      uint8_t *Out, size_t MaxOutSize,
	                      unsigned int Seed);

#ifdef __cplusplus
} /* extern "C" */
#endif

static void
test_seed(void)
{
	time_t t;
	srand((unsigned) time(&t));

    uint8_t data[] = { 'L', 'U', 'A' };
	size_t size = lengthof(data);
	size_t max_size = size;
	size_t seed = rand();
	size_t res = LLVMFuzzerCustomCrossOver(data, size, data, size,
	                                       NULL, max_size, seed);
	assert(res != 0);
}

int
main(void)
{
	test_seed();
}
