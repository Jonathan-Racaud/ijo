#include "gc/naiveGC.h"
#include "ijoMemory.h"

// Forward declaration

void ObjectDelete(ijoObj *obj);

// NaiveGC implementation

void NaiveGCInit(NaiveGCNode *gc) {
    gc->obj = NULL;
    gc->next = NULL;
}

NaiveGCNode *NaiveGCNodeCreate(ijoObj *obj) {
    NaiveGCNode *node = (NaiveGCNode*)malloc(sizeof(NaiveGCNode));
    node->obj = obj;
    node->next = NULL;

    return node;
}

void NaiveGCInsert(NaiveGCNode **head, ijoObj *obj) {
    NaiveGCNode *newNode = NaiveGCNodeCreate(obj);
    newNode->next = *head;
    *head = newNode;
}

void NaiveGCClear(NaiveGCNode *head) {
    NaiveGCNode *current = head;

    while (current != NULL) {
        ObjectDelete(current->obj);
        current->obj = NULL;
        current = current->next;
    }
}