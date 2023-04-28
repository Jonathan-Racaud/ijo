#define TEST_NO_MAIN
#include "acutest.h"
#include "ijoVM.h"

static inline void test_ijoVMNew_GivenNULL_DoesntCrash(void) {
	ijoVMNew(NULL);
}

#define IJOVM_TESTS \
	{ "ijoVMNew_GivenNULL_DoesntCrash", test_ijoVMNew_GivenNULL_DoesntCrash }