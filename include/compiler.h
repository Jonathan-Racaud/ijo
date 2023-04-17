#ifndef IJO_COMPILER_H
#define IJO_COMPILER_H

#include "chunk.h"

/**
 * @brief Compiles @p source code to a Chunk.
 * @param source The source code to compile.
 * @return The Chunk to execute.
 */
Chunk Compile(const char *source);

#endif // IJO_COMPILER_H