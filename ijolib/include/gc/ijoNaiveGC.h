#ifndef IJO_NAIVE_GC_H
#define IJO_NAIVE_GC_H

#include "ijoValue.h"

#if defined(__cplusplus)
extern "C" {
#endif

/// @brief A linked-list that holds the reference to all allocated ijoObj.
typedef struct NaiveGCNode {
    ijoObj *obj;
    struct NaiveGCNode *next;
} NaiveGCNode;

/**
 * @brief Initializes the NaiveGC.
 * @param gc The GC to initialize.
 */
NaiveGCNode *NaiveGCNodeCreate(Value *obj);

/**
 * @brief Appends an @p obj to the list of allocated ijoObj
 * @param obj The object to store.
 */
void NaiveGCInsert(NaiveGCNode **head, Value *obj);

/**
 * @brief Clears the content of the GC and all of its stored obj.
 * @param gc The gc to clear.
 */
void NaiveGCClear(NaiveGCNode *head);

extern NaiveGCNode *gc;

#if defined(__cplusplus)
}
#endif

#endif // IJO_NAIVE_GC_H