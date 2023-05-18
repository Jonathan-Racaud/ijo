#ifndef PLAYGROUND_DISASSEMBLER_H
#define PLAYGROUND_DISASSEMBLER_H

#include "ijoChunk.h"
#include <string>

void DisassembleChunk(Chunk *chunk, std::ostringstream &ss);
uint32_t DisassembleInstruction(Chunk *chunk, uint32_t offset, std::ostringstream &ss);
uint32_t DisassembleUnknownInstruction(Chunk *chunk, uint32_t offset, std::ostringstream &ss);
uint32_t DisassembleSimpleInstruction(const char *name, Chunk *chunk, uint32_t offset, std::ostringstream &ss);
uint32_t DisassembleConstantInstruction(const char *name, Chunk *chunk, uint32_t offset, std::ostringstream &ss);
uint32_t DisassembleArgInstruction(const char *name, Chunk *chunk, uint32_t offset, std::ostringstream &ss);

#endif // PLAYGROUND_DISASSEMBLER_H