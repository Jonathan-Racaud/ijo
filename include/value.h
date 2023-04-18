#ifndef IJO_VALUE_H
#define IJO_VALUE_H

#include "common.h"

/**
 * @brief Types managed by the ijoVM.
 */
typedef enum {
    VAL_RESULT,
    VAL_BOOL,
    VAL_NUMBER
} ValueType;

/**
 * @brief Tells what kind of operator are allowed on the type.
 * @note Refers to the syntax used in the source code: '%' is not 
 * OPERATOR_MODULO but OPERATOR_PERCENT because a Value could have
 * an operator defined for this token without being a modulo operation.
 */
typedef enum {
    OPERATOR_PLUS,
    OPERATOR_MINUS,
    OPERATOR_STAR,
    OPERATOR_SLASH,
    OPERATOR_PERCENT,
} OperatorType;

struct ValueOperator;

/**
 * @brief Represents the Value type used by the ijoVM.
 * @note
 * There's 4 bytes of padding between the tag and the value.
 */
typedef struct {
    /// @brief The tag type for the value.
    /// @note 4 bytes
    ValueType type;

    struct ValueOperator *operators;

    /// @brief The data stored for the value.
    /// @note 8 bytes
    union {
        bool boolean;
        double number;
    } as;
} Value;

typedef Value (*OperatorInfixFunc)(Value a, Value b);
typedef Value (*OperatorPrefixFunc)(Value b);
typedef Value (*OperatorPostfixFunc)(Value b);
typedef uint8_t Operator ;

typedef struct ValueOperator {
    OperatorPrefixFunc prefix;
    OperatorInfixFunc infix;
    OperatorPostfixFunc postfix;
} ValueOperator;

extern ValueOperator numberOperators[];
extern ValueOperator boolOperators[];
extern ValueOperator resultOperators[];

#define BOOL_VAL(value)     ((Value){VAL_BOOL,   boolOperators,   {.boolean = value}})
#define NUMBER_VAL(value)   ((Value){VAL_NUMBER, numberOperators, {.number = value}})
#define SUCCESS_VAL()       ((Value){VAL_RESULT, resultOperators, {.boolean = 0}})
#define ERROR_VAL()         ((Value){VAL_RESULT, resultOperators, {.boolean = 1}})

#define AS_BOOL(value)      ((value).as.boolean)
#define AS_NUMBER(value)    ((value).as.number)
#define AS_SUCCESS(value)   ((value).as.boolean)
#define AS_ERROR(value)     ((value).as.boolean)

#define IS_RESULT(value)    ((value).type == VAL_RESULT)
#define IS_BOOL(value)      ((value).type == VAL_BOOL)
#define IS_NUMBER(value)    ((value).type == VAL_NUMBER)

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
Value ValueNumberAdd(Value a, Value b);

/**
 * @brief Subtract two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The subtraction of the two values.
 */
Value ValueNumberSub(Value a, Value b);

/**
 * @brief Multiply two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The multiplication of the two values.
 */
Value ValueNumberMul(Value a, Value b);

/**
 * @brief Divides two value together.
 * @param a The first value.
 * @param b The second value.
 * @return The division of the two values.
 */
Value ValueNumberDiv(Value a, Value b);

/**
 * @brief Modulo between two values.
 * @param a The first value.
 * @param b The second value.
 * @return The module of the two values.
 */
Value ValueNumberMod(Value a, Value b);

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

Value ValueError(Value a);
Value ValueError2(Value a, Value b);

#endif // IJO_VALUE_H