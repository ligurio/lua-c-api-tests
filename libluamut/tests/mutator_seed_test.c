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
LLVMFuzzerCustomMutator(uint8_t *Data, size_t Size,
	                    size_t MaxSize, unsigned int Seed);

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
	size_t res = LLVMFuzzerCustomMutator(data, size, max_size, seed);
	assert(res != 0);
}

int
main(void)
{
	test_seed();
}
