#ifndef IJO_MEMORY_H
#define IJO_MEMORY_H

#include "common.h"

/**
 * @brief Grows the @p capacity by a factor of 2.
*/
#define GROW_CAPACITY(capacity) \
    ((capacity < 8) ? (8) : (capacity * 2))

/**
 * @brief Grows the array at @p pointer with the @p oldSize to its @p newSize and cast the result to @p type.
*/ 
#define GROW_ARRAY(type, pointer, oldSize, newSize) \
    ((type*)Reallocate(pointer, sizeof(type) * oldSize, sizeof(type) * newSize))

/**
 * @brief Frees the array pointed to by @p pointer and cast the result to @p type.
*/
#define FREE_ARRAY(type, pointer, oldSize) \
    ((type*)Reallocate(pointer, sizeof(type) * oldSize, 0));

/**
 * @brief Reallocate the memory pointed to by @p pointer.
 * @param pointer The pointer to memory to reallocate.
 * @param oldSize The current size of the memory from pointer.
 * @param newSize The new size for the memory.
 * @return The pointer to the reallocated memory.
 */
void *Reallocate(void *pointer, uint32_t oldSize, uint32_t newSize);

/**
 * @brief Free and nullify the @p ptr.
 * @param ptr The pointer to free and nullify.
 */
void Delete(void *ptr);

#endif // IJO_MEMORY_H