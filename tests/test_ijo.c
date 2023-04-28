// This file is only here to have the implementation of main from acutest being compiled.
// And to provide the `NaiveGCNode *gc` variable needed by ijolib.
// Every other test files MUST declare the macro TEST_NO_MAIN for compilation to work.

#include "acutest.h"
#include "test_ijoChunk.h"
#include "test_ijoVM.h"

#include "gc/ijoNaiveGC.h"
NaiveGCNode *gc;

TEST_LIST = {
	IJOVM_TESTS,
	CHUNK_TESTS,
	{ NULL, NULL }
};