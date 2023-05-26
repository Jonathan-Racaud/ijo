#define TEST_NO_MAIN
#include "acutest.h"
#include "ijoVM.h"

static inline void test_ijoVMInit_GivenNULL_DoesntCrash(void) {
	ijoVMInit(NULL);
}

static inline void test_ijoVMInit_GivenVMPtr_InitializesCorrectly(void) {
	// Arrange
	ijoVM sut;
	
	// Act
	ijoVMInit(&sut);

	// Assert
	TEST_CHECK(sut.chunk == NULL);
	TEST_CHECK(sut.ip == NULL);
	TEST_CHECK(sut.stack != NULL);
	TEST_CHECK(sut.stackTop == sut.stack);
	TEST_CHECK(sut.interned.count == 0);
}

static inline void test_ijoVMDeinit_GivenNULL_DoesntCrash(void) {
	ijoVMDeinit(NULL);
}

static inline void test_ijoVMDeinit_GivenVMPtr_FreeResources(void) {
	// Arrange
	ijoVM sut;
	
	// Act
	ijoVMDeinit(&sut);

	// Assert
	TEST_CHECK(sut.chunk == NULL);
	TEST_CHECK(sut.ip == NULL);
	TEST_CHECK(sut.stack != NULL);
	TEST_CHECK(sut.stackTop == sut.stack);
	TEST_CHECK(sut.interned.count == 0);
}

static inline void test_ijoVMStackReset_GivenNULL_DoesntCrash(void) {
	// Arrange
	
	// Act
	ijoVMStackReset(NULL);

	// Assert
}

static inline void test_ijoVMStackReset_GivenVMPTR_ResetsStack(void) {
	// Arrange
	ijoVM sut;
	ijoVMInit(&sut);
	sut.stackTop = &sut.stack[STACK_MAX - 1];

	// Act
	ijoVMStackReset(&sut);

	// Assert
	TEST_CHECK(sut.stackTop == sut.stack);
}

static inline void test_ijoVMStackPush_GivenNULL_DoesntCrash(void) {
	// Arrange
	Value val;

	// Act
	ijoVMStackPush(NULL, val);

	// Assert
}

static inline void test_ijoVMStackPush_WhenHasRoom_PushValue(void) {
	// Arrange
	ijoVM sut;
	ijoVMInit(&sut);
	Value expectedValue = NUMBER_VAL(42);

	// Act
	ijoVMStackPush(&sut, expectedValue);
	Value poppedValue = ijoVMStackPop(&sut);

	// Assert
	bool valuesAreEqual = AS_BOOL(ValueEqual(expectedValue, poppedValue));
	TEST_CHECK(valuesAreEqual);
}

static inline void test_ijoVMStackPush_WhenFull_DoesntIncrementStackTop(void) {
	// Arrange
	ijoVM sut;
	ijoVMInit(&sut);
	Value expectedValue = NUMBER_VAL(42);

	sut.stackTop = &sut.stack[STACK_MAX];

	// Act
	ijoVMStackPush(&sut, expectedValue);

	// Assert
	TEST_CHECK(sut.stackTop == &sut.stack[STACK_MAX]);
}

static inline void test_ijoVMStackPop_GivenNULL_DoesntCrash(void) {
	// Arrange
	
	// Act
	ijoVMStackPop(NULL);

	// Assert
}

static inline void test_ijoVMStackPop_WhenHasValue_PopValue(void) {
	// Arrange
	ijoVM sut;
	ijoVMInit(&sut);
	Value expectedValue = NUMBER_VAL(42);
	ijoVMStackPush(&sut, expectedValue);

	// Act
	Value poppedValue = ijoVMStackPop(&sut);

	// Assert
	bool valuesAreEqual = AS_BOOL(ValueEqual(expectedValue, poppedValue));
	TEST_CHECK(valuesAreEqual);
}

static inline void test_ijoVMStackPop_WhenEmpty_ReturnsErrorValue(void) {
	// Arrange
	ijoVM sut;
	ijoVMInit(&sut);

	// Act
	Value poppedValue = ijoVMStackPop(&sut);

	// Assert
	TEST_CHECK(IS_RESULT(poppedValue));
	TEST_CHECK(AS_ERROR(poppedValue) == false);
}

#define IJOVM_TESTS { "ijoVMInit_GivenNULL_DoesntCrash", test_ijoVMInit_GivenNULL_DoesntCrash }, \
					{ "ijoVMInit_GivenVMPtr_InitializesCorrectly", test_ijoVMInit_GivenVMPtr_InitializesCorrectly }, \
					{ "ijoVMDeinit_GivenNULL_DoesntCrash", test_ijoVMDeinit_GivenNULL_DoesntCrash }, \
					{ "ijoVMDeinit_GivenVMPtr_FreeResources", test_ijoVMDeinit_GivenVMPtr_FreeResources }, \
					{ "ijoVMStackReset_GivenNULL_DoesntCrash", test_ijoVMStackReset_GivenNULL_DoesntCrash }, \
					{ "ijoVMStackReset_GivenVMPTR_ResetsStack", test_ijoVMStackReset_GivenVMPTR_ResetsStack }, \
					{ "ijoVMStackPush_GivenNULL_DoesntCrash", test_ijoVMStackPush_GivenNULL_DoesntCrash }, \
					{ "ijoVMStackPush_WhenHasRoom_PushValue", test_ijoVMStackPush_WhenHasRoom_PushValue }, \
					{ "ijoVMStackPush_WhenFull_DoesntIncrementStackTop", test_ijoVMStackPush_WhenFull_DoesntIncrementStackTop }, \
					{ "ijoVMStackPop_GivenNULL_DoesntCrash", test_ijoVMStackPop_GivenNULL_DoesntCrash }, \
					{ "ijoVMStackPop_WhenHasValue_PopValue", test_ijoVMStackPop_WhenHasValue_PopValue }, \
					{ "ijoVMStackPop_WhenEmpty_ReturnsErrorValue", test_ijoVMStackPop_WhenEmpty_ReturnsErrorValue }