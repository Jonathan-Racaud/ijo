#ifndef IJO_VM_H
#define IJO_VM_H

#include "chunk.h"

/**
 * @brief The ijo Virtual Machine.
 */
typedef struct {
    /// @brief The chunk of code to execute.
    Chunk *chunk;
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

#endif // IJO_VM_H