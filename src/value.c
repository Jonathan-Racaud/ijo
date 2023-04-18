#include "value.h"
#include "ijoMemory.h"
#include "log.h"

void ValueArrayNew(ValueArray *array) {
    array->capacity = 0;
    array->count = 0;
    array->values = NULL;
}

void ValueArrayDelete(ValueArray *array) {
    FREE_ARRAY(Value, array->values, array->capacity);
    ValueArrayNew(array);
}

void ValueArrayAppend(ValueArray *array, Value value) {
    if (array->capacity < array->count + 1) {
        int oldCapacity = array->capacity;
        array->capacity = GROW_CAPACITY(oldCapacity);
        array->values = GROW_ARRAY(Value, array->values, oldCapacity, array->capacity);
    }

    array->values[array->count] = value;
    array->count += 1;
}

void ValuePrint(Value value) {
    if (IS_NUMBER(value)) {
        ConsoleWrite("%g", AS_NUMBER(value));
    }

    if (IS_BOOL(value)) {
        ConsoleWrite("%s", AS_BOOL(value) ? "@true" : "@false");
    }

    if (IS_RESULT(value)) {
        ConsoleWrite("%s", AS_SUCCESS(value) ? "@success" : "@error");
    }
}

Value ValueNumberAdd(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a) + AS_NUMBER(b));
}

Value ValueNumberSub(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a)- AS_NUMBER(b));
}

Value ValueNumberDiv(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a) / AS_NUMBER(b));
}

Value ValueNumberMul(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a) * AS_NUMBER(b));
}

Value ValueNumberMod(Value a, Value b) {
    return NUMBER_VAL((int)AS_NUMBER(a) % (int)AS_NUMBER(b));
}

Value ValueNumberEqual(Value a, Value b) {
    return BOOL_VAL(AS_NUMBER(a) == AS_NUMBER(b));
}

Value ValueNumberGreaterThan(Value a, Value b) {
    return BOOL_VAL(AS_NUMBER(a) > AS_NUMBER(b));
}

Value ValueNumberGreaterEqual(Value a, Value b) {
    return BOOL_VAL(AS_NUMBER(a) >= AS_NUMBER(b));
}

Value ValueNumberLessThan(Value a, Value b) {
    return BOOL_VAL(AS_NUMBER(a) < AS_NUMBER(b));
}

Value ValueNumberLessEqual(Value a, Value b) {
    return BOOL_VAL(AS_NUMBER(a) <= AS_NUMBER(b));
}

Value ValueNumberNegate(Value val) {
    return NUMBER_VAL(-AS_NUMBER(val));
}

Value ValueError(Value b) {
    return ERROR_VAL();
}

Value ValueError2(Value a, Value b) {
    return ERROR_VAL();
}

Value ValueBoolNot(Value a) {
    return BOOL_VAL(!AS_BOOL(a));
}

/**
 * @brief Default operators for Number values.
 * @note ValueOperator | Prefix | Infix | Postfix
 */
ValueOperator numberOperators [] = {
    [OPERATOR_PLUS]               = {ValueError, ValueNumberAdd, ValueError},
    [OPERATOR_MINUS]              = {ValueNumberNegate, ValueNumberSub, ValueError},
    [OPERATOR_STAR]               = {ValueError, ValueNumberMul, ValueError},
    [OPERATOR_SLASH]              = {ValueError, ValueNumberDiv, ValueError},
    [OPERATOR_PERCENT]            = {ValueError, ValueNumberMod, ValueError},
    [OPERATOR_BANG]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]        = {ValueError, ValueNumberEqual, ValueError},
    [OPERATOR_CHEVRON_LEFT]       = {ValueError, ValueNumberLessThan, ValueError},
    [OPERATOR_CHEVRON_RIGHT]      = {ValueError, ValueNumberGreaterThan, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT] = {ValueError, ValueNumberLessEqual, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueNumberGreaterEqual, ValueError},
};

ValueOperator boolOperators [] = {
    [OPERATOR_PLUS]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_MINUS]              = {ValueError, ValueError2, ValueError},
    [OPERATOR_STAR]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_SLASH]              = {ValueError, ValueError2, ValueError},
    [OPERATOR_PERCENT]            = {ValueError, ValueError2, ValueError},
    [OPERATOR_BANG]               = {ValueBoolNot, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]        = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_LEFT]       = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_RIGHT]      = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT] = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueError2, ValueError},
};

ValueOperator resultOperators [] = {
    [OPERATOR_PLUS]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_MINUS]              = {ValueError, ValueError2, ValueError},
    [OPERATOR_STAR]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_SLASH]              = {ValueError, ValueError2, ValueError},
    [OPERATOR_PERCENT]            = {ValueError, ValueError2, ValueError},
    [OPERATOR_BANG]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]        = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_LEFT]       = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_RIGHT]      = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT] = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueError2, ValueError},
};