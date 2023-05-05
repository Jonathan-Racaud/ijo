#ifndef IJO_CHUNK_H
#define IJO_CHUNK_H

#include "ijoCommon.h"
#include "ijoValue.h"

#if defined(__cplusplus)
extern "C" {
#endif

/// @brief The different Operation Code the ijoVM understands.
typedef enum {
    OP_CONSTANT,

    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,

    OP_NEG,
    
    OP_EQ,
    OP_NEQ,
    OP_LT,
    OP_LE,
    OP_GT,
    OP_GE,

    OP_TRUE,
    OP_FALSE,
    OP_SUCCESS,
    OP_ERROR,

    OP_NOT,

    OP_PRINT,

    OP_MODULE,

    OP_GET_LOCAL,
    OP_SET_LOCAL,

    OP_POP,
    OP_RETURN,
} OpCode;

/// @brief Represents a chunk of data to be executed by the ijoVM.
typedef struct {
    /// @brief The current number of OpCode that this chunk represents.
    uint32_t count;

    /// @brief The capacity of this chunk of code.
    uint32_t capacity;
    
    /// @brief The list of OpCode to execute.
    uint32_t *code;

    /// @brief The constant pool for this chunk.
    ValueArray constants;

    /// @brief The lines number for runtime error.
    uint32_t *lines;
} Chunk;

/// @brief Initialize a @p chunk.
/// @param chunk: The chunk to initialize.
void ChunkNew(Chunk *chunk);

/// @brief Deletes a @p chunk and its allocated memory.
// Parameters:
//   - Chunk *chunk: The chunk to be deleted.
void ChunkDelete(Chunk *chunk);

/// @brief Write code to the @p chunk.
/// @param chunk: The chunk to be written.
/// @param code: The code instruction.
/// @param line: The line number inside the source file.
void ChunkWriteCode(Chunk *chunk, uint32_t code, uint32_t line);

/// @brief Adds a constant value to the @p chunk and returns its index.
/// @param chunk: The chunk to add the constant to.
/// @param value: The value to add to the chunk's constant pool.
//
/// @retval The index of the added constant.
uint32_t ChunkAddConstant(Chunk *chunk, Value value);

#if defined(__cplusplus)
}
#endif

#endif // IJO_CHUNK_H