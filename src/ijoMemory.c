#include "ijoMemory.h"

void *Reallocate(void *pointer, uint32_t oldSize, uint32_t newSize) {
    if (newSize == 0) {
        Delete(pointer);
        return NULL;
    }

    bool hadEmptyPtr = pointer == NULL;

    void *result = realloc(pointer, newSize);

    if (hadEmptyPtr) {
        memset(result, 0, newSize);
    }

    if (result == NULL) {
        exit(1);
    }

    return result; 
}

void Delete(void *ptr) {
    if (!ptr) {
        return;
    }

    free(ptr);
    ptr = NULL;
}