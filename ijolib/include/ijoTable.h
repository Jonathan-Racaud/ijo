#ifndef IJO_TABLE_H
#define IJO_TABLE_H

#include "ijoCommon.h"
#include "ijoValue.h"

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

/**
 * @brief Inserts a @p value into the @p table with the specified @p key.
 * @param table The table to insert data into.
 * @param key The key associated with the value.
 * @param value The value associated with the key.
 * @return True when the key and value are inserted. False otherwise.
 */
bool TableInsert(Table *table, ijoString *key, Value value);

/**
 * @brief Gets a value from the @p table for the specified @p key.
 * @param table The table to search.
 * @param key The key to search.
 * @param outValue The pointer where the value will be stored.
 * @return True if an Entry is found. @p outValue will be set to the found value.
 * @return False if no Entry is found. @p outValue will be set to @error.
 */
bool TableGet(Table *table, ijoString *key, Value *outValue);

/**
 * @brief Removes an Entry with the specified @p key from the @p table.
 * @param table The table to remove the entry from.
 * @param key The key to search for.
 * @return True if removed, False otherwise.
 */
bool TableRemove(Table *table, ijoString *key);

/**
 * @brief Finds an Entry in the list of @p entries for the specified @p key.
 * @param entries The list of Entry to search.
 * @param capacity The @p entries' capacity.
 * @param key The key to search.
 * @return The corresponding Entry. NULL otherwise.
 */
Entry *TableFindEntry(Entry *entries, int capacity, ijoString *key);

/**
 * @brief Finds an interned string in the Table @p table.
 * @param table The table to search.
 * @param chars The string to look for.
 * @param length The string's length.
 * @param hash The string's hash.
 * @return The found String or NULL.
 */
ijoString* TableFindString(Table *table, const char *chars, int length, uint32_t hash);

/**
 * @brief Insert into the @p to Table all the entries of the @p from Table. 
 * @param from The original Table to copy.
 * @param to The destination of the copy.
 */
void TableAddAll(Table *from, Table *to);

#endif // IJO_TABLE_H