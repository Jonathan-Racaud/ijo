#ifndef IJO_SCANNER_H
#define IJO_SCANNER_H

/// @brief Represents a Scanner.
typedef struct {
    /// @brief Marks the beginning of the current lexem.
    const char *start;

    /// @brief Marks the current character being looked at.
    const char *current;

    /// @brief The current line of code the current lexem is on. 
    int line;
} Scanner;

/**
 * @brief Instantiate a new Scanner.
 * @return The newly instantiated Scanner.
 */
Scanner *ScannerNew();

/**
 * @brief Deletes a Scanner.
 * @param scanner The scanner instance to delete.
 */
void ScannerDelete(Scanner *scanner);

/**
 * @brief Init the scanner that will scan the @p source code.
 * @param source The source code to scan.
 */
void ScannerInit(Scanner *scanner, const char *source);

#endif // IJO_SCANNER_H