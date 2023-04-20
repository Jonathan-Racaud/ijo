#include "table.h"

#include <stdlib.h>
#include <string.h>

#include "ijoMemory.h"
#include "ijoObj.h"
#include "value.h"

void TableInit(Table *table) {
    table->capacity = 0;
    table->count = 0;
    table->entries = NULL;
}

void TableDelete(Table *table) {
    FREE_ARRAY(Entry, table->entries, table->capacity);
    TableInit(table);
}