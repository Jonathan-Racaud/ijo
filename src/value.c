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
    ConsoleWrite("%g", value);
}

Value ValueAdd(Value a, Value b) {
    return a + b;
}

Value ValueSub(Value a, Value b) {
    return a - b;
}

Value ValueDiv(Value a, Value b) {
    return a / b;
}

Value ValueMul(Value a, Value b) {
    return a * b;
}

Value ValueMod(Value a, Value b) {
    return (int)a % (int)b;
}