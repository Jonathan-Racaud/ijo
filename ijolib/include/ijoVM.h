#ifndef IJO_VM_H
#define IJO_VM_H

#include "ijoCompiler.h"
#include "ijoValue.h"
#include "ijoTable.h"

#define STACK_MAX 256

/// @brief The result of interpreting a Chunk of code.
typedef enum {
    /// @brief Code interpretation was successful.
    INTERPRET_OK,

    /// @brief An error occured while compiling code.
    INTERPRET_COMPILE_ERROR,

    /// @brief An error occured while running code.
    INTERPRET_RUNTIME_ERROR
} InterpretResult;

/**
 * @brief The ijo Virtual Machine.
 */
typedef struct {
    /// @brief The chunk of code to execute.
    Chunk *chunk;

    /// @brief Current instruction pointer.
    uint32_t *ip;

    /// @brief The stack to operate upon.
    Value stack[STACK_MAX];

    /// @brief Pointer to the top of the stack.
    Value *stackTop;

    /// @brief Table of interned Strings and Constants.
    Table interned;
} ijoVM;

/**
 * @brief Instantiate a new ijoVM.
 * @return A pointer to the ijoVM.
 */
void ijoVMInit(ijoVM *vm);

/**
 * @brief Deletes an @p ijoVM.
 */
void ijoVMDeinit(ijoVM *vm);

/**
 * @brief Interprets a chunk of code.
 * @param vm The ijoVM that should interpret the code.
 * @param chunk The chunk of code to be interpreted.
 * @return The result of the code interpretation.
 */
InterpretResult ijoVMInterpret(ijoVM *vm, Chunk *chunk, CompileMode mode);

/**
 * @brief Runs the vm.
 * @param vm The vm to run.
 * @return The interpret result for this vm.
 */
InterpretResult ijoVMRun(ijoVM *vm, CompileMode mode);

/**
 * @brief Resets the stack for the specified @p vm.
 * @param vm The vm that needs its stack reset.
 */
void ijoVMStackReset(ijoVM *vm);

/**
 * @brief Push a value to the stack.
 * @param vm The vm that needs its stack pushed.
 * @param value The value to push..
 */
void ijoVMStackPush(ijoVM *vm, Value value);

/**
 * @brief Pop a value of the stack.
 * @param vm The vm that needs its stack popped.
 * @return The popped value.
 */
Value ijoVMStackPop(ijoVM *vm);

#endif // IJO_VM_H