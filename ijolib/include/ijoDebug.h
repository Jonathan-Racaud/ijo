#ifndef IJO_DEBUG_H
#define IJO_DEBUG_H

#include "ijoChunk.h"
#include "ijoCommon.h"

#if defined(__cplusplus)
extern "C"
{
#endif

  /**
   * @brief Disassemble the @p chunk with associated @p name to the specified @p stream.
   * @param chunk The chunk to disassemble.
   * @param name The name associated to `chunk`.
   * @param stream The stream to write into.
   */
  void DisassembleChunk(Chunk *chunk, const char *name, FILE *stream);

  /**
   * @brief Disassemble the instruction from the @p chunk at the specified @p offset to the specified @p stream.
   * @param stream The stream to write into.
   * @param chunk The chunk to disassemble.
   * @param offset The offset for the instruction to disassemble.
   * @param stream The stream to write into.
   * @return The offset to the next instruction.
   */
  uint32_t DisassembleInstruction(Chunk *chunk, uint32_t offset, FILE *stream);

  /**
   * @brief Disassemble an unknown instruction at the specified @p offset to the specified @p stream.
   * @param chunk The chunk for information.
   * @param offset The offset for the instruction to disassemble.
   * @param stream The stream to write into.
   * @return The offset to the next instruction.
   */
  uint32_t DisassembleUnknownInstruction(Chunk *chunk, uint32_t offset, FILE *stream);

  /**
   * @brief Disassemble a simple instruction at the specified @p offset with the associated @p name to the specified @p stream.
   * @param name The name of the instruction.
   * @param chunk The chunk for information.
   * @param offset The offset for the instruction to disassemble.
   * @param stream The stream to write into.
   * @return The offset to the next instruction.
   */
  uint32_t DisassembleSimpleInstruction(const char *name, Chunk *chunk, uint32_t offset, FILE *stream);

  /**
   * @brief Disassemble a constant instruction at the specified @p offset for the associated @p chunk to the specified @p stream.
   * @param name The name of the instruction.
   * @param chunk The chunk to use for printing the instruction's information.
   * @param offset The offset for the instruction to disassemble.
   * @param stream The stream to write into.
   * @return The offset to the next instruction.
   */
  uint32_t DisassembleConstantInstruction(const char *name, Chunk *chunk, uint32_t offset, FILE *stream);

  /**
   * @brief Disassemble an instruction that takes an argument at the specified @p offset for the associated @p chunk to the specified @p stream.
   * @param name The name of the instruction.
   * @param chunk The chunk to use for printing the instruction's information.
   * @param offset The offset for the instruction to disassemble.
   * @param stream The stream to write into.
   * @return The offset to the next instruction.
   */
  uint32_t DisassembleArgInstruction(const char *name, Chunk *chunk, uint32_t offset, FILE *stream);

#if defined(__cplusplus)
}
#endif

#endif // IJO_DEBUG_H