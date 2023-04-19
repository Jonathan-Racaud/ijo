#ifndef IJO_NAIVE_GC_H
#define IJO_NAIVE_GC_H

// Forward declaration
typedef struct ijoObj ijoObj;

/// @brief A linked-list that holds the reference to all allocated ijoObj.
typedef struct NaiveGCNode {
    ijoObj *obj;
    struct NaiveGCNode *next;
} NaiveGCNode;

/**
 * @brief Initializes the NaiveGC.
 * @param gc The GC to initialize.
 */
void NaiveGCInit(NaiveGCNode *gc);

/**
 * @brief Appends an @p obj to the list of allocated ijoObj
 * @param obj The object to store.
 */
void NaiveGCAppend(NaiveGCNode *gc, ijoObj *obj);

/**
 * @brief Clears the content of the GC and all of its stored obj.
 * @param gc The gc to clear.
 */
void NaiveGCClear(NaiveGCNode *gc);

#endif // IJO_NAIVE_GC_H