#ifndef IJO_OBJ_H
#define IJO_OBJ_H

#include "common.h"
#include "value.h"

/// @brief The types of object ijo understands.
typedef enum {
    OBJ_STRING,
} ObjType;

/// @brief Represents a heap allocated type.
/// @note Can be a String, Function, Instance...
struct ijoObj {
    /// @brief The object type.
    ObjType type;
};

/// @brief Represents a String.
struct ijoString {
    /// @brief Object header.
    ijoObj obj;

    /// @brief Length of the String
    int length;

    /// @brief Content of the String
    char *chars;
};

// ijoObj related functionalities

bool isObjType(Value value, ObjType type);

#define OBJ_TYPE(value)     (AS_OBJ(value)->type)

/**
 * @brief Instantiate a new ijoObject of size @p size and of type @p type.
 * @param size The size for the object.
 * @param type The type of the object.
 * @return 
 */
ijoObj *ObjectNew(int size, ObjType type);

/**
 * @brief Deletes an ijoObj.
 * @param obj The object to delete.
 */
void ObjectDelete(ijoObj *obj);

/**
 * @brief Prints an object to the console.
 * @param obj The object to print.
*/
void ObjectPrint(Value obj);

// ijoString related functionalities

#define IS_STRING(value)       isObjType(value, OBJ_STRING)
#define AS_STRING(value)       ((ijoString*)AS_OBJ(value))
#define AS_CSTRING(value)      (((ijoString*)AS_OBJ(value))->chars)

/**
 * @brief Allocate a new ijoString with content @p chars with length @p size.
 * @param chars The string content.
 * @param size The string's length.
 * @return 
 */
ijoString *ijoStringNew(char *chars, int size);

/**
 * @brief Initializes an ijoString with @p chars and @p size.
 * @param string The string to initialize.
 * @param chars The string's content.
 * @param size The string's length.
 */
void ijoStringInit(ijoString *string, char* chars, int size);

/**
 * @brief Deletes an ijoString, freeing its payload.
 * @param string The string to delete.
 */
void ijoStringDelete(ijoString *string);

/**
 * @brief Compares two strings.
 * @param a The first string to compare.
 * @param b The second string to compare.
 * @return True when the strings are the same.
 */
Value ijoStringEqual(Value a, Value b);

/**
 * @brief Concatenates two string together.
 * @param a The first string to concat.
 * @param b The second string to concat. Will be put at the end of @p a.
 * @return The concatenated string.
 */
Value ijoStringConcat(Value a, Value b);

/**
 * @brief Prints an ijoString to the console.
 * @param string The string to print.
*/
void ijoStringPrint(ijoString *string);

/**
 * @brief Copy the string @p chars of length @p size and returns an ijoString.
 * @param chars The string to copy.
 * @param size The string's length.
 * @return The copy of @p chars as an ijoString.
 */
ijoString* CStringCopy(const char* chars, int size);

#endif // IJO_OBJ_H