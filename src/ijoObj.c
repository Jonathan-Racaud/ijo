#include "ijoObj.h"
#include "value.h"

#include "ijoMemory.h"
#include "value.h"
#include "ijoVM.h"

#define ALLOCATE_OBJ(type, objectType) \
    (type*)ObjectNew(sizeof(type), objectType)

ijoObj *ObjectNew(int size, ObjType type) {
    ijoObj *object = (ijoObj*)Reallocate(NULL, 0, size);
    object->type = type;
    return object;
} 

bool isObjType(Value value, ObjType type) {
    return IS_OBJ(value) && (AS_OBJ(value)->type == type);
}

ijoString *ijoStringNew(char *chars, int size) {
    ijoString *string = ALLOCATE_OBJ(ijoString, OBJ_STRING);
    ijoStringInit(string, chars, size);
}

// Public ijoString functions implementations

void ijoStringInit(ijoString *string, char *chars, int size) {
    string->chars = chars;
    string->length = size;
}

void ijoStringDelete(ijoString *string) {
    free(string->chars);
    Delete(string);
}

ijoString *CStringCopy(const char* chars, int size) {
    char *heapChars = ALLOCATE(char, size + 1);
    memcpy(heapChars, chars, size);
    heapChars[size] = '\0';

    return ijoStringNew(heapChars, size);
}