#ifndef IJO_COMPILER_H
#define IJO_COMPILER_H

#include "chunk.h"
#include "token.h"

/// @brief The Parser struct for the ijoVM.
typedef struct {
    /// @brief The current Token.
    Token current;

    /// @brief The previous Token.
    Token previous;

    /// @brief To know if there was an error while parsing.
    bool hadError;

    /// @brief Tracks if we are in panic mode.
    bool panicMode;
} Parser;

/// @brief Define the levels of precedences from lowest to highest.
typedef enum {
  PREC_NONE,
  PREC_ASSIGNMENT,  // =
  PREC_OR,          // or
  PREC_AND,         // and
  PREC_EQUALITY,    // == !=
  PREC_COMPARISON,  // < > <= >=
  PREC_TERM,        // + -
  PREC_FACTOR,      // * /
  PREC_UNARY,       // ! -
  PREC_CALL,        // . ()
  PREC_PRIMARY
} Precedence;

/**
 * @brief Initializes the specified @p parser.
 * @param parser The parser to initialize.
 */
void ParserInit(Parser *parser);

/**
 * @brief Compiles @p source code to a Chunk.
 * @param source The source code to compile.
 * @param chunk The compiled chunk from @p source.
 * @return True when the compilation was successful.
 */
bool Compile(const char *source, Chunk *chunk);

#endif // IJO_COMPILER_H