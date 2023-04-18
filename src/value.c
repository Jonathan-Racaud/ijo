#include "value.h"
#include "ijoMemory.h"
#include "log.h"
#include "ijoObj.h"

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
    switch (value.type)
    {
    case VAL_NUMBER: ConsoleWrite("%g", AS_NUMBER(value)); break;
    case VAL_BOOL:   ConsoleWrite("%s", AS_BOOL(value) ? "@true" : "@false"); break;
    case VAL_RESULT: ConsoleWrite("%g", AS_SUCCESS(value) ? "@success" : "@error"); break;
    case VAL_OBJ: ObjectPrint(value); break;
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

Value ValueEqual(Value a, Value b) {
    if (IS_NUMBER(a) && IS_NUMBER(b)) {
        return BOOL_VAL(AS_NUMBER(a) == AS_NUMBER(b));
    }

    if (IS_BOOL(a) && IS_BOOL(b)) {
        return BOOL_VAL(AS_BOOL(a) == AS_BOOL(b));
    }

    if (IS_STRING(a) && IS_STRING(b)) {
        return BOOL_VAL(ijoStringEqual(AS_STRING(a), AS_STRING(b)));
    }

    return ERROR_VAL();
}

Value ValueNotEqual(Value a, Value b) {
    Value result = ValueEqual(a, b);
    
    if (IS_BOOL(result)) {
        return BOOL_VAL(!AS_BOOL(result));
    }

    return result;
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
    [OPERATOR_PLUS]                = {ValueError, ValueNumberAdd, ValueError},
    [OPERATOR_MINUS]               = {ValueNumberNegate, ValueNumberSub, ValueError},
    [OPERATOR_STAR]                = {ValueError, ValueNumberMul, ValueError},
    [OPERATOR_SLASH]               = {ValueError, ValueNumberDiv, ValueError},
    [OPERATOR_PERCENT]             = {ValueError, ValueNumberMod, ValueError},
    [OPERATOR_BANG]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]         = {ValueError, ValueEqual, ValueError},
    [OPERATOR_BANG_EQUAL]          = {ValueError, ValueNotEqual, ValueError},
    [OPERATOR_CHEVRON_LEFT]        = {ValueError, ValueNumberLessThan, ValueError},
    [OPERATOR_CHEVRON_RIGHT]       = {ValueError, ValueNumberGreaterThan, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT]  = {ValueError, ValueNumberLessEqual, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueNumberGreaterEqual, ValueError},
};

/**
 * @brief Default operators for Boolean values.
 * @note ValueOperator | Prefix | Infix | Postfix
 */
ValueOperator boolOperators [] = {
    [OPERATOR_PLUS]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_MINUS]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_STAR]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_SLASH]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_PERCENT]             = {ValueError, ValueError2, ValueError},
    [OPERATOR_BANG]                = {ValueBoolNot, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]         = {ValueError, ValueEqual, ValueError},
    [OPERATOR_CHEVRON_LEFT]        = {ValueError, ValueNotEqual, ValueError},
    [OPERATOR_CHEVRON_RIGHT]       = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT]  = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueError2, ValueError},
};

/**
 * @brief Default operators for Result values.
 * @note ValueOperator | Prefix | Infix | Postfix
 */
ValueOperator resultOperators [] = {
    [OPERATOR_PLUS]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_MINUS]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_STAR]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_SLASH]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_PERCENT]             = {ValueError, ValueError2, ValueError},
    [OPERATOR_BANG]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]         = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_LEFT]        = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_RIGHT]       = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT]  = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueError2, ValueError},
};

/**
 * @brief Default operators for Obj values.
 * @note ValueOperator | Prefix | Infix | Postfix
 */
ValueOperator objOperators [] = {
    [OPERATOR_PLUS]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_MINUS]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_STAR]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_SLASH]               = {ValueError, ValueError2, ValueError},
    [OPERATOR_PERCENT]             = {ValueError, ValueError2, ValueError},
    [OPERATOR_BANG]                = {ValueError, ValueError2, ValueError},
    [OPERATOR_EQUAL_EQUAL]         = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_LEFT]        = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_RIGHT]       = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_LEFT]  = {ValueError, ValueError2, ValueError},
    [OPERATOR_CHEVRON_EQUAL_RIGHT] = {ValueError, ValueError2, ValueError},
};