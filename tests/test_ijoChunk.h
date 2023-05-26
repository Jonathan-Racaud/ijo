#define TEST_NO_MAIN
#include "acutest.h"
#include "ijoChunk.h"

static inline void test_ChunkNew_GivenNULL_DoesntCrash(void) {
    ChunkNew(NULL);
}

#define CHUNK_TESTS \
    { "ChunkNew_GivenNULL_DoesntCrash", test_ChunkNew_GivenNULL_DoesntCrash }