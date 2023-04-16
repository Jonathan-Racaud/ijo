#ifndef IJO_VALUE_H
#define IJO_VALUE_H

#include "common.h"

/**
 * @brief Represents the Value type used by the ijoVM.
 */
typedef double Value;

/**
 * @brief Represents a dynamic array of Value.
 */
typedef struct {
    /// @brief The array's capacity
    uint32_t capacity;

    /// @brief The current number of elements in the array.
    uint32_t count;

    /// @brief The values contained in the array.
    Value *values;
} ValueArray;

/**
 * @brief Initialized the \p array
 * @param array The array to initialize.
 */
void ValueArrayNew(ValueArray *array);

/**
 * @brief Deletes the `array`
 * @param array The array to deletes.
 */
void ValueArrayDelete(ValueArray *array);

/**
 * @brief Appends the @p value to the @p array
 * @param array The array to modify.
 * @param value The value to add to the array.
 */
void ValueArrayAppend(ValueArray *array, Value value);

/**
 * @brief Prints the @p value.
 * @param value 
 */
void ValuePrint(Value value);

#endif // IJO_VALUE_H