#include "ijoTable.h"

#include <stdlib.h>
#include <string.h>

#include "ijoMemory.h"
#include "ijoObj.h"
#include "ijoValue.h"

#define TABLE_MAX_LOAD 0.75

void TableInit(Table *table) {
    table->capacity = 0;
    table->count = 0;
    table->entries = NULL;
}

void TableDelete(Table *table) {
    FREE_ARRAY(Entry, table->entries, table->capacity);
    TableInit(table);
}

void TableAdjustCapacity(Table *table, int capacity) {
    Entry *entries = ALLOCATE(Entry, capacity);

    table->count = 0;
    for (int i = 0; i < capacity; i++) {
        entries[i].key = NULL;
        entries[i].value = IJO_INTERNAL(IJO_INTERNAL_EMPTY_ENTRY);
    }

    for (int i = 0; i < table->capacity; i++) {
        Entry *entry = &table->entries[i];
        
        if (entry->key == NULL) continue;

        Entry *dest = TableFindEntry(entries, capacity, entry->key);
        dest->key = entry->key;
        dest->value = entry->value;
        table->count++;
    }

    FREE_ARRAY(Entry, table->entries, table->capacity);

    table->entries = entries;
    table->capacity = capacity;
}

bool TableInsert(Table *table, ijoString *key, Value value) {
    if (table->count + 1 > table->capacity * TABLE_MAX_LOAD) {
        int capacity = GROW_CAPACITY(table->capacity);
        TableAdjustCapacity(table, capacity);
    }

    Entry *entry = TableFindEntry(table->entries, table->capacity, key);

    bool isNewKey = IS_INTERNAL(entry->value, IJO_INTERNAL_EMPTY_ENTRY);

    if (isNewKey) {
        table->count++;
    }

    entry->key = key;
    entry->value = value;

    return isNewKey;
}

Entry *TableFindInternalEntry(Entry *entries, int capacity, ijoString *key) {
    uint32_t index = key->hash % capacity;
    Entry *tombstone = NULL;

    for (;;) {
        Entry *entry = &entries[index];

        if (entry->key == NULL) {
            if (IS_INTERNAL(entry->value, IJO_INTERNAL_EMPTY_ENTRY)) {
                return entry;
            }

            if (IS_INTERNAL(entry->value, IJO_INTERNAL_TOMBSTONE)) {
                return (tombstone != NULL) ? tombstone : entry;
            } else {
                if (tombstone == NULL) tombstone = entry;
            }
        } else if (entry->key->length == key->length &&
                   entry->key->hash == key->hash &&
                   memcmp(entry->key->chars, key->chars, key->length) == 0) {
            return entry;
        }

        index = (index + 1) % capacity;
    }
}

bool TableInsertInternal(Table *table, ijoString *key, Value value) {
    if (table->count + 1 > table->capacity * TABLE_MAX_LOAD) {
        int capacity = GROW_CAPACITY(table->capacity);
        TableAdjustCapacity(table, capacity);
    }

    Entry *entry = TableFindInternalEntry(table->entries, table->capacity, key);

    bool isNewKey = IS_INTERNAL(entry->value, IJO_INTERNAL_EMPTY_ENTRY);

    if (isNewKey) {
        table->count++;
    }

    entry->key = key;
    entry->value = value;

    return isNewKey;
}

Entry *TableFindEntry(Entry *entries, int capacity, ijoString *key) {
    uint32_t index = key->hash % capacity;
    Entry *tombstone = NULL;

    for (;;) {
        Entry *entry = &entries[index];

        if (entry->key == NULL) {
            if (IS_INTERNAL(entry->value, IJO_INTERNAL_EMPTY_ENTRY)) {
                return entry;
            }

            if (IS_INTERNAL(entry->value, IJO_INTERNAL_TOMBSTONE)) {
                return (tombstone != NULL) ? tombstone : entry;
            } else {
                if (tombstone == NULL) tombstone = entry;
            }
        } else if (entry->key == key) {
            return entry;
        }

        index = (index + 1) % capacity;
    }
}

ijoString* TableFindString(Table *table, const char *chars, int length, uint32_t hash) {
    if (table->count == 0) {
        return NULL;
    }

    uint32_t index = hash % table->capacity;

    for (;;) {
        Entry* entry = &table->entries[index];
    
        if (entry->key == NULL) {
            // Stop if we find an empty non-tombstone entry.
            if (!IS_INTERNAL(entry->value, IJO_INTERNAL_TOMBSTONE)) {
                return NULL; 
            }
        } else if (entry->key->length == length &&
                   entry->key->hash == hash &&
                   memcmp(entry->key->chars, chars, length) == 0) {
            // We found it.
            return entry->key;
        }
        
        index = (index + 1) % table->capacity;
    }
}

void TableAddAll(Table *from, Table *to) {
    for (int i = 0; i < from->capacity; i++) {
        Entry *entry = &from->entries[i];

        if (entry->key == NULL) continue;

        TableInsert(to, entry->key, entry->value);
    }
}

bool TableGet(Table *table, ijoString *key, Value *outValue) {
    *outValue = ERROR_VAL();

    if (table->count == 0) return false;

    Entry *entry = TableFindEntry(table->entries, table->capacity, key);
    
    if (entry->key == NULL) return false;

    *outValue = entry->value;

    return true;
}

bool TableRemove(Table *table, ijoString *key) {
    if (table->count == 0) {
        return false;
    }

    Entry *entry = TableFindEntry(table->entries, table->capacity, key);

    if (entry->key == NULL) {
        return false;
    }

    // Place a tombstone in the entry.
    entry->key = NULL;
    entry->value = IJO_INTERNAL(IJO_INTERNAL_TOMBSTONE);
    return true;
}