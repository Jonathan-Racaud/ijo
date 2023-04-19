#include "gc/naiveGC.h"
#include "ijoMemory.h"
#include "value.h"

// Forward declaration

void ObjectDelete(ijoObj *obj);

// NaiveGC implementation

NaiveGCNode *NaiveGCNodeCreate(Value *value) {
    NaiveGCNode *node = (NaiveGCNode*)malloc(sizeof(NaiveGCNode));
    if (value != NULL) {
        node->obj = AS_OBJ(*value);
    } else {
        node->obj = NULL;
    }

    node->next = NULL;

    return node;
}

void NaiveGCInsert(NaiveGCNode **head, Value *value) {
    NaiveGCNode *newNode = NaiveGCNodeCreate(value);
    newNode->next = *head;
    *head = newNode;
}

void NaiveGCClear(NaiveGCNode *head) {
    NaiveGCNode *current;

    while (head != NULL) {
        current = head;
        
        if (head->obj != NULL) {
            ObjectDelete(head->obj);
            head->obj = NULL;
        }

        head = head->next;

        free(current);
    }
}