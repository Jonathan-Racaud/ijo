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

bool ijoStringEqual(ijoString *a, ijoString *b) {
    return (a->length == b->length) && (memcmp(a->chars, b->chars, a->length) == 0);
}

ijoString *CStringCopy(const char* chars, int size) {
    char *heapChars = ALLOCATE(char, size + 1);
    memcpy(heapChars, chars, size);
    heapChars[size] = '\0';

    return ijoStringNew(heapChars, size);
}