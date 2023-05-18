#include "ijoObj.h"
#include "ijoLog.h"
#include "ijoMemory.h"
#include "ijoTable.h"
#include "ijoVM.h"
#include "ijoValue.h"

#define ALLOCATE_OBJ(type, objectType) \
    (type *)ObjectNew(sizeof(type), objectType)

ijoObj *ObjectNew(int size, ObjType type)
{
    ijoObj *object = (ijoObj *)Reallocate(NULL, 0, size);
    object->type = type;
    return object;
}

void ObjectDelete(ijoObj *obj)
{
    switch (obj->type)
    {
    case OBJ_STRING:
        ijoStringDelete((ijoString *)obj);
        break;
    default:
        break;
    }
}

bool isObjType(Value value, ObjType type)
{
    return IS_OBJ(value) && (AS_OBJ(value)->type == type);
}

void ObjectPrint(FILE *stream, Value value)
{
    ijoObj *obj = AS_OBJ(value);

    switch (obj->type)
    {
    case OBJ_STRING:
        OutputWrite(stream, "%s", AS_CSTRING(value));
        break;
    default:
        LogError("Unknown type");
        break;
    }
}

// Private ijoString functions forward declaration

uint32_t hashString(const char *str, int length);

// Public ijoString functions implementations

ijoString *ijoStringNew(char *chars, int size, uint32_t hash)
{
    ijoString *string = ALLOCATE_OBJ(ijoString, OBJ_STRING);
    ijoStringInit(string, chars, size, hash);
}

void ijoStringInit(ijoString *string, char *chars, int size, uint32_t hash)
{
    string->chars = chars;
    string->length = size;
    string->hash = hash;
}

void ijoStringDelete(ijoString *string)
{
    free(string->chars);
    Delete(string);
}

Value ijoStringEqual(Value a, Value b)
{
    return BOOL_VAL(AS_OBJ(a) == AS_OBJ(b));
    // ijoString *aString = AS_STRING(a);
    // ijoString *bString = AS_STRING(b);
    // return BOOL_VAL((aString->length == bString->length) &&
    //                 (memcmp(aString->chars, bString->chars, aString->length) == 0));
}

Value ijoStringConcat(Value a, Value b)
{
    ijoString *aString = AS_STRING(a);
    ijoString *bString = AS_STRING(b);

    int length = aString->length + bString->length;

    char *content = NULL;
    content = ALLOCATE(char, length + 1);
    memcpy(content, aString->chars, aString->length);
    memcpy(content + aString->length, bString->chars, bString->length);
    content[length] = '\0';

    uint32_t hash = hashString(content, length);

    ijoString *result = ijoStringNew(content, length, hash);
    Value str = OBJ_VAL(result);
    str.operators = stringOperators;

    return str;
}

ijoString *CStringCopy(const char *chars, int size)
{
    uint32_t hash = hashString(chars, size);
    char *heapChars = ALLOCATE(char, size + 1);
    memcpy(heapChars, chars, size);
    heapChars[size] = '\0';

    return ijoStringNew(heapChars, size, hash);
}

/**
 * @brief Hash the string @p str of length @p length using the FNV-1a algorithm.
 * @param str The string to hash.
 * @param length The string's length.
 * @return The hash value for the string.
 */
uint32_t hashString(const char *str, int length)
{
    uint32_t hash = 2166136261u;
    for (int i = 0; i < length; i++)
    {
        hash ^= (uint8_t)str[i];
        hash *= 16777619;
    }
    return hash;
}