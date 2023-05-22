#include "ijoDebug.h"
#include "ijoLog.h"

void DisassembleChunk(Chunk *chunk, const char *name, FILE *stream)
{
    LogDebug("== %s - Start ==", name);

    for (uint32_t offset = 0; offset < chunk->count;)
    {
        offset = DisassembleInstruction(chunk, offset, stream);
    }
    LogDebug("== %s - End ==", name);
}

uint32_t DisassembleInstruction(Chunk *chunk, uint32_t offset, FILE *stream)
{
    OutputWrite(stream, "%04d ", offset);

    uint32_t instruction = chunk->code[offset];

    switch (instruction)
    {
    case OP_CONSTANT:
        return DisassembleConstantInstruction("OP_CONSTANT", chunk, offset, stream);
    case OP_ADD:
        return DisassembleSimpleInstruction("OP_ADD", chunk, offset, stream);
    case OP_SUB:
        return DisassembleSimpleInstruction("OP_SUB", chunk, offset, stream);
    case OP_MUL:
        return DisassembleSimpleInstruction("OP_MUL", chunk, offset, stream);
    case OP_DIV:
        return DisassembleSimpleInstruction("OP_DIV", chunk, offset, stream);
    case OP_MOD:
        return DisassembleSimpleInstruction("OP_MOD", chunk, offset, stream);
    case OP_NEG:
        return DisassembleSimpleInstruction("OP_NEG", chunk, offset, stream);
    case OP_EQ:
        return DisassembleSimpleInstruction("OP_EQ", chunk, offset, stream);
    case OP_NEQ:
        return DisassembleSimpleInstruction("OP_NEQ", chunk, offset, stream);
    case OP_LT:
        return DisassembleSimpleInstruction("OP_LT", chunk, offset, stream);
    case OP_LE:
        return DisassembleSimpleInstruction("OP_LE", chunk, offset, stream);
    case OP_GT:
        return DisassembleSimpleInstruction("OP_GT", chunk, offset, stream);
    case OP_GE:
        return DisassembleSimpleInstruction("OP_GE", chunk, offset, stream);
    case OP_PRINT:
        return DisassembleSimpleInstruction("OP_PRINT", chunk, offset, stream);
    case OP_PRINTLN:
        return DisassembleSimpleInstruction("OP_PRINTLN", chunk, offset, stream);
    case OP_RETURN:
        return DisassembleSimpleInstruction("OP_RETURN", chunk, offset, stream);
    case OP_TRUE:
        return DisassembleSimpleInstruction("OP_TRUE", chunk, offset, stream);
    case OP_FALSE:
        return DisassembleSimpleInstruction("OP_FALSE", chunk, offset, stream);
    case OP_MODULE:
        return DisassembleSimpleInstruction("OP_MODULE", chunk, offset, stream);
    case OP_NOT:
        return DisassembleSimpleInstruction("OP_NOT", chunk, offset, stream);
    case OP_POP:
        return DisassembleSimpleInstruction("OP_POP", chunk, offset, stream);
    case OP_GET_LOCAL:
        return DisassembleArgInstruction("OP_GET_LOCAL", chunk, offset, stream);
    case OP_SET_LOCAL:
        return DisassembleArgInstruction("OP_SET_LOCAL", chunk, offset, stream);
    case OP_JUMP:
        return DisassembleArgInstruction("OP_JUMP", chunk, offset, stream);
    case OP_JUMP_IF_FALSE:
        return DisassembleArgInstruction("OP_JUMP_IF_FALSE", chunk, offset, stream);
    case OP_JUMP_BACK:
        return DisassembleArgInstruction("OP_JUMP_BACK", chunk, offset, stream);
    default:
        return DisassembleUnknownInstruction(chunk, instruction, stream);
    }
}

uint32_t DisassembleUnknownInstruction(Chunk *chunk, uint32_t offset, FILE *stream)
{
    OutputWriteLine(stream, "Unknown instruction: %04d", offset);
    return offset + 1;
}

uint32_t DisassembleSimpleInstruction(const char *name, Chunk *chunk, uint32_t offset, FILE *stream)
{
    OutputWriteLine(stream, "%s", name);
    return offset + 1;
}

uint32_t DisassembleConstantInstruction(const char *name, Chunk *chunk, uint32_t offset, FILE *stream)
{
    uint32_t constant = chunk->code[offset + 1];

    OutputWrite(stream, "%-16s %4d '", name, constant);
    ValuePrint(stream, chunk->constants.values[constant]);
    OutputWriteLine(stream, "");

    return offset + 2;
}

uint32_t DisassembleArgInstruction(const char *name, Chunk *chunk, uint32_t offset, FILE *stream)
{
    uint32_t slot = chunk->code[offset + 1];
    OutputWriteLine(stream, "%-16s %4d", name, slot);
    return offset + 2;
}