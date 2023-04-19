#include "ijoObj.h"
#include "ijoMemory.h"
#include "ijoVM.h"
#include "value.h"
#include "log.h"

#define ALLOCATE_OBJ(type, objectType) \
    (type*)ObjectNew(sizeof(type), objectType)

ijoObj *ObjectNew(int size, ObjType type) {
    ijoObj *object = (ijoObj*)Reallocate(NULL, 0, size);
    object->type = type;
    return object;
}

void ObjectDelete(ijoObj *obj) {
    switch (obj->type)
    {
    case OBJ_STRING: ijoStringDelete(obj); break;
    default: break;
    }
}

bool isObjType(Value value, ObjType type) {
    return IS_OBJ(value) && (AS_OBJ(value)->type == type);
}

void ObjectPrint(Value obj) {
    switch (obj.type)
    {
    case OBJ_STRING: ConsoleWrite("%s", AS_CSTRING(obj)); break;
    default: LogError("Unknown type");
        break;
    }
}

// Public ijoString functions implementations

ijoString *ijoStringNew(char *chars, int size) {
    ijoString *string = ALLOCATE_OBJ(ijoString, OBJ_STRING);
    ijoStringInit(string, chars, size);
}

void ijoStringInit(ijoString *string, char *chars, int size) {
    string->chars = chars;
    string->length = size;
}

void ijoStringDelete(ijoString *string) {
    free(string->chars);
    Delete(string);
}

Value ijoStringEqual(Value a, Value b) {
    ijoString *aString = AS_STRING(a);
    ijoString *bString = AS_STRING(b);
    return BOOL_VAL((aString->length == bString->length) && 
                    (memcmp(aString->chars, bString->chars, aString->length) == 0));
}

Value ijoStringConcat(Value a, Value b) {
    ijoString *aString = AS_STRING(a);
    ijoString *bString = AS_STRING(b);
    
    int length = aString->length + bString->length + 1;

    ijoString *result = ijoStringNew(NULL, length);
    memcpy(result->chars, aString->chars, aString->length);
    memcpy(result->chars + aString->length, bString->chars, bString->length);
    result->chars[length] = '\0';

    return OBJ_VAL(result);
}

ijoString *CStringCopy(const char* chars, int size) {
    char *heapChars = ALLOCATE(char, size + 1);
    memcpy(heapChars, chars, size);
    heapChars[size] = '\0';

    return ijoStringNew(heapChars, size);
}