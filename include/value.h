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

/**
 * @brief Adds two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The sum of the two values.
 */
Value ValueAdd(Value a, Value b);

/**
 * @brief Subtract two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The subtraction of the two values.
 */
Value ValueSub(Value a, Value b);

/**
 * @brief Multiply two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The multiplication of the two values.
 */
Value ValueMul(Value a, Value b);

/**
 * @brief Divides two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The division of the two values.
 */
Value ValueDiv(Value a, Value b);

/**
 * @brief Modulo between two values.
 * @param a The first value.
 * @param b The second value.
 * @return The module of the two values.
 */
Value ValueMod(Value a, Value b);

/**
 * @brief Compare two values together.
 * @param a The first value.
 * @param b The second value.
 * @return True when @p a == @p b>
 */
bool ValueEqual(Value a, Value b);

/**
 * @brief Compare two values together.
 * @param a The first value.
 * @param b The second value.
 * @return True when @p a > @p b
 */
bool ValueGreaterThan(Value a, Value b);

/**
 * @brief Compare two values together.
 * @param a The first value.
 * @param b The second value.
 * @return True when @p a >= @p b.
 */
bool ValueGreaterEqual(Value a, Value b);

/**
 * @brief Compare two values together.
 * @param a The first value.
 * @param b The second value.
 * @return True when @p a < @p b.
 */
bool ValueLessThan(Value a, Value b);

/**
 * @brief Compare two values together.
 * @param a The first value.
 * @param b The second value.
 * @return True when @p a <= @p b.
 */
bool ValueLessEqual(Value a, Value b);

/**
 * @brief Negate a value.
 * @param val 
 * @return The negated value.
 */
Value ValueNegate(Value val);

#endif // IJO_VALUE_H