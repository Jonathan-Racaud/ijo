#ifndef IJO_VM_H
#define IJO_VM_H

#include "chunk.h"

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
} ijoVM;

/**
 * @brief Instantiate a new ijoVM.
 * @return A pointer to the ijoVM.
 */
ijoVM *ijoVMNew();

/**
 * @brief Deletes an @p ijoVM.
 */
void ijoVMDelete(ijoVM *vm);

/**
 * @brief Interprets a chunk of code.
 * @param vm The ijoVM that should interpret the code.
 * @param chunk The chunk of code to be interpreted.
 * @return The result of the code interpretation.
 */
InterpretResult ijoVMInterpret(ijoVM *vm, Chunk *chunk);

/**
 * @brief Runs the vm.
 * @param vm The vm to run.
 * @return The interpret result for this vm.
 */
InterpretResult ijoVMRun(ijoVM *vm);

#endif // IJO_VM_H