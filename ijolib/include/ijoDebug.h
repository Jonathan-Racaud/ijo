#ifndef IJO_DEBUG_H
#define IJO_DEBUG_H

#include "ijoCommon.h"
#include "ijoChunk.h"

#if defined(__cplusplus)
extern "C" {
#endif

/**
 * @brief Disassemble the @p chunk with associated @p name.
 * @param chunk The chunk to disassemble.
 * @param name The name associated to `chunk`.
 */
void DisassembleChunk(Chunk *chunk, const char *name);

/**
 * @brief Disassemble the instruction from the @p chunk at the specified @p offset.
 * @param chunk The chunk to disassemble.
 * @param offset The offset for the instruction to disassemble.
 * @return The offset to the next instruction.
 */
uint32_t DisassembleInstruction(Chunk *chunk, uint32_t offset);

/**
 * @brief Disassemble an unknown instruction at the specified @p offset.
 * @param chunk The chunk for information.
 * @param offset The offset for the instruction to disassemble.
 * @return The offset to the next instruction.
*/
uint32_t DisassembleUnknownInstruction(Chunk *chunk, uint32_t offset);

/**
 * @brief Disassemble a simple instruction at the specified @p offset with the associated @p name.
 * @param name The name of the instruction.
 * @param chunk The chunk for information.
 * @param offset The offset for the instruction to disassemble.
 * @return The offset to the next instruction.
 */
uint32_t DisassembleSimpleInstruction(const char *name, Chunk *chunk, uint32_t offset);

/**
 * @brief Disassemble a constant instruction at the specified @p offset for the associated @p chunk.
 * @param name The name of the instruction.
 * @param chunk The chunk to use for printing the instruction's information.
 * @param offset The offset for the instruction to disassemble.
 * @return The offset to the next instruction.
 */
uint32_t DisassembleConstantInstruction(const char *name, Chunk *chunk, uint32_t offset);

#if defined(__cplusplus)
}
#endif

#endif // IJO_DEBUG_H