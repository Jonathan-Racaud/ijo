#include "debug.h"
#include "log.h"

void DisassembleChunk(Chunk *chunk, const char *name) {
    LogDebug("== %s - Start ==", name);

    for (uint32_t offset = 0; offset < chunk->count;) {
        offset = DisassembleInstruction(chunk, offset);
    }
    LogDebug("== %s - End ==", name);
}

uint32_t DisassembleInstruction(Chunk *chunk, uint32_t offset) {
    ConsoleWrite("%04d ", offset);

    uint32_t instruction = chunk->code[offset];

    switch (instruction)
    {
    case OP_CONSTANT:
        return DisassembleConstantInstruction("OP_CONSTANT", chunk, offset);
    case OP_ADD:
        return DisassembleSimpleInstruction("OP_ADD", chunk, offset);
    case OP_SUB:
        return DisassembleSimpleInstruction("OP_SUB", chunk, offset);
    case OP_MUL:
        return DisassembleSimpleInstruction("OP_MUL", chunk, offset);
    case OP_DIV:
        return DisassembleSimpleInstruction("OP_DIV", chunk, offset);
    case OP_MOD:
        return DisassembleSimpleInstruction("OP_MOD", chunk, offset);
    case OP_NEG:
        return DisassembleSimpleInstruction("OP_NEG", chunk, offset);
    case OP_EQ:
        return DisassembleSimpleInstruction("OP_EQ", chunk, offset);
    case OP_LT:
        return DisassembleSimpleInstruction("OP_LT", chunk, offset);
    case OP_LE:
        return DisassembleSimpleInstruction("OP_LE", chunk, offset);
    case OP_GT:
        return DisassembleSimpleInstruction("OP_GT", chunk, offset);
    case OP_GE:
        return DisassembleSimpleInstruction("OP_GE", chunk, offset);
    case OP_PRINT:
        return DisassembleSimpleInstruction("OP_PRINT", chunk, offset);
    case OP_RETURN:
        return DisassembleSimpleInstruction("OP_RETURN", chunk, offset);
    case OP_MODULE:
        return DisassembleSimpleInstruction("OP_MODULE", chunk, offset);

    default:
        return DisassembleUnknownInstruction(chunk, instruction);
    }
}

uint32_t DisassembleUnknownInstruction(Chunk *chunk, uint32_t offset) {
    ConsoleWriteLine("Unknown instruction: %04d", offset);
    return offset + 1;
}

uint32_t DisassembleSimpleInstruction(const char *name, Chunk *chunk, uint32_t offset) {
    ConsoleWriteLine("%s", name);
    return offset + 1;
}

uint32_t DisassembleConstantInstruction(const char *name, Chunk *chunk, uint32_t offset) {
    uint32_t constant = chunk->code[offset + 1];
    
    ConsoleWrite("%-16s %4d '", name, constant);
    ValuePrint(chunk->constants.values[constant]);
    ConsoleWriteLine("");

    return offset + 2;
}