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
        ConsoleWrite("%s", AS_BOOL(value) ? "True" : "False");
    }

    if (IS_RESULT(value)) {
        ConsoleWrite("%s", AS_SUCCESS(value) ? ":O" : ":X");
    }
}

Value ValueAdd(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a) + AS_NUMBER(b));
}

Value ValueSub(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a)- AS_NUMBER(b));
}

Value ValueDiv(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a) / AS_NUMBER(b));
}

Value ValueMul(Value a, Value b) {
    return NUMBER_VAL(AS_NUMBER(a) * AS_NUMBER(b));
}

Value ValueMod(Value a, Value b) {
    return NUMBER_VAL((int)AS_NUMBER(a) % (int)AS_NUMBER(b));
}

bool ValueEqual(Value a, Value b) {
    return AS_NUMBER(a) == AS_NUMBER(b);
}

bool ValueGreaterThan(Value a, Value b) {
    return AS_NUMBER(a) > AS_NUMBER(b);
}

bool ValueGreaterEqual(Value a, Value b) {
    return AS_NUMBER(a) >= AS_NUMBER(b);
}

bool ValueLessThan(Value a, Value b) {
    return !ValueGreaterThan(a, b);
}

bool ValueLessEqual(Value a, Value b) {
    return !ValueGreaterEqual(a, b);
}

Value ValueNegate(Value val) {
    return NUMBER_VAL(-AS_NUMBER(val));
}