#ifndef IJO_TABLE_H
#define IJO_TABLE_H

#include "common.h"
#include "value.h"

/**
 * @brief An entry for the ijo HashTable
 */
typedef struct {
    /// @brief The Entry's key.
    ijoString *key;

    /// @brief The Entry's value.
    Value value;
} Entry;

/**
 * @brief HashTable for ijo variables.
 */
typedef struct {
    /// @brief The number of stored entry.
    int count;

    /// @brief The total capacity for the table.
    int capacity;

    /// @brief The entries in this Table.
    Entry *entries;
} Table;

/**
 * @brief Initializes a new HashTable.
 * @param table The table to initialize.
 */
void TableInit(Table *table);

/**
 * @brief Frees the resources of the @p table.
 * @param table The table to free.
 */
void TableDelete(Table *table);

#endif // IJO_TABLE_H