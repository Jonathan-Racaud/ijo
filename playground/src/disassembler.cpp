#include "disassembler.h"
#include <iomanip>
#include <sstream>
#include <string>
#include <string_view>

void DisassembleChunk(Chunk *chunk, std::ostringstream &ss)
{
  for (uint32_t offset = 0; offset < chunk->count;)
  {
    offset = DisassembleInstruction(chunk, offset, ss);
  }
}

uint32_t DisassembleInstruction(Chunk *chunk, uint32_t offset, std::ostringstream &ss)
{
  ss << std::setw(4) << std::setfill('0') << offset << " ";

  uint32_t instruction = chunk->code[offset];

  switch (instruction)
  {
  case OP_CONSTANT:
    return DisassembleConstantInstruction("OP_CONSTANT", chunk, offset, ss);
  case OP_ADD:
    return DisassembleSimpleInstruction("OP_ADD", chunk, offset, ss);
  case OP_SUB:
    return DisassembleSimpleInstruction("OP_SUB", chunk, offset, ss);
  case OP_MUL:
    return DisassembleSimpleInstruction("OP_MUL", chunk, offset, ss);
  case OP_DIV:
    return DisassembleSimpleInstruction("OP_DIV", chunk, offset, ss);
  case OP_MOD:
    return DisassembleSimpleInstruction("OP_MOD", chunk, offset, ss);
  case OP_NEG:
    return DisassembleSimpleInstruction("OP_NEG", chunk, offset, ss);
  case OP_EQ:
    return DisassembleSimpleInstruction("OP_EQ", chunk, offset, ss);
  case OP_NEQ:
    return DisassembleSimpleInstruction("OP_NEQ", chunk, offset, ss);
  case OP_LT:
    return DisassembleSimpleInstruction("OP_LT", chunk, offset, ss);
  case OP_LE:
    return DisassembleSimpleInstruction("OP_LE", chunk, offset, ss);
  case OP_GT:
    return DisassembleSimpleInstruction("OP_GT", chunk, offset, ss);
  case OP_GE:
    return DisassembleSimpleInstruction("OP_GE", chunk, offset, ss);
  case OP_PRINT:
    return DisassembleSimpleInstruction("OP_PRINT", chunk, offset, ss);
  case OP_PRINTLN:
    return DisassembleSimpleInstruction("OP_PRINTLN", chunk, offset, ss);
  case OP_RETURN:
    return DisassembleSimpleInstruction("OP_RETURN", chunk, offset, ss);
  case OP_TRUE:
    return DisassembleSimpleInstruction("OP_TRUE", chunk, offset, ss);
  case OP_FALSE:
    return DisassembleSimpleInstruction("OP_FALSE", chunk, offset, ss);
  case OP_MODULE:
    return DisassembleSimpleInstruction("OP_MODULE", chunk, offset, ss);
  case OP_NOT:
    return DisassembleSimpleInstruction("OP_NOT", chunk, offset, ss);
  case OP_POP:
    return DisassembleSimpleInstruction("OP_POP", chunk, offset, ss);
  case OP_GET_LOCAL:
    return DisassembleArgInstruction("OP_GET_LOCAL", chunk, offset, ss);
  case OP_SET_LOCAL:
    return DisassembleArgInstruction("OP_SET_LOCAL", chunk, offset, ss);
  case OP_JUMP:
    return DisassembleArgInstruction("OP_JUMP", chunk, offset, ss);
  case OP_JUMP_IF_FALSE:
    return DisassembleArgInstruction("OP_JUMP_IF_FALSE", chunk, offset, ss);
  default:
    return DisassembleUnknownInstruction(chunk, instruction, ss);
  }
}

uint32_t DisassembleUnknownInstruction(Chunk *chunk, uint32_t offset, std::ostringstream &ss)
{
  ss << "Unknown instruction: " << std::setw(4) << std::setfill('0') << offset << "\n";
  return offset + 1;
}

uint32_t DisassembleSimpleInstruction(const char *name, Chunk *chunk, uint32_t offset, std::ostringstream &ss)
{
  ss << name << "\n";
  return offset + 1;
}

uint32_t DisassembleConstantInstruction(const char *name, Chunk *chunk, uint32_t offset, std::ostringstream &ss)
{
  uint32_t constant = chunk->code[offset + 1];

  ss << std::left << std::setw(16) << std::string_view(name) << std::right << std::setw(4) << constant << "\n";
  // ValuePrint(chunk->constants.values[constant]);

  return offset + 2;
}

uint32_t DisassembleArgInstruction(const char *name, Chunk *chunk, uint32_t offset, std::ostringstream &ss)
{
  uint32_t slot = chunk->code[offset + 1];

  ss << std::left << std::setw(16) << std::string_view(name) << std::right << std::setw(4) << slot << "\n";
  return offset + 2;
}