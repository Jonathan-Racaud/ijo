#ifndef IJO_OBJ_H
#define IJO_OBJ_H

#include "value.h"

typedef enum ObjType {
    OBJ_STRING,
} ObjType;

/// @brief Represents a heap allocated type.
/// @note Can be a String, Function, Instance...
typedef struct {
    /// @brief The object type.
    ObjType type;
} ijoObj;

/// @brief Represents a String.
typedef struct {
    /// @brief Object header.
    ijoObj obj;

    /// @brief Length of the String
    int length;

    /// @brief Content of the String
    char *chars;
} ijoString;

bool isObjType(Value value, ObjType type);

#define IS_STRING(value)       isObjType(value, OBJ_STRING)

#define AS_STRING(value)       ((ObjString*)AS_OBJ(value))
#define AS_CSTRING(value)      (((ObjString*)AS_OBJ(value))->chars)

#endif // IJO_OBJ_H