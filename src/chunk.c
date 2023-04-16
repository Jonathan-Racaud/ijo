#include "chunk.h"
#include "ijoMemory.h"

void ChunkNew(Chunk *chunk) {
    chunk->count = 0;
    chunk->capacity = 0;
    chunk->code = NULL;
    chunk->lines = NULL;
    ValueArrayNew(&(*chunk).constants);
}

void ChunkDelete(Chunk *chunk) {
    FREE_ARRAY(uint32_t, chunk->code, chunk->capacity);
    FREE_ARRAY(uint32_t, chunk->lines, chunk->capacity);
    ValueArrayDelete(&chunk->constants);
}

void ChunkWriteCode(Chunk *chunk, uint32_t code, uint32_t line) {
    if (chunk->capacity < chunk->count + 1) {
        int oldCapacity = chunk->capacity;
        chunk->capacity = GROW_CAPACITY(oldCapacity);
        chunk->code = GROW_ARRAY(uint32_t, chunk->code, oldCapacity, chunk->capacity);
        chunk->lines = GROW_ARRAY(uint32_t, chunk->lines, oldCapacity, chunk->capacity);
    }

    chunk->code[chunk->count] = code;
    chunk->lines[chunk->count] = line;
    chunk->count += 1;
}

uint32_t ChunkAddConstant(Chunk *chunk, Value value) {
    ValueArrayAppend(&chunk->constants, value);
    return chunk->constants.count + 1;
}
