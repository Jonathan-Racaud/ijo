#ifndef IJO_COMPILER_H
#define IJO_COMPILER_H

#include "chunk.h"
#include "token.h"
#include "scanner.h"

/// @brief Helps the compiler know what it is it's compiling.
typedef enum {
  COMPILE_FILE,
  COMPILE_REPL
} CompileMode;

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

    /// @brief The scanner associated with this Parser.
    Scanner *scanner;
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

/// @brief Function pointer to a parser function for a given TokenType.
typedef void (*ParseFunc)(Parser *, Chunk *);

/// @brief Rule to follow when parsing.
typedef struct {
    /// @brief Function pointer to the parser function of an prefix expression.
    ParseFunc prefix;

    /// @brief Function pointer to the parser function of an infix expression.
    ParseFunc infix;

    /// @brief The precedence of an infix expression that uses that token as an operator.
    Precedence precedence;

    /// @brief The tokens that can be accepted for the rules.
    TokenType acceptedTokens;
} ParseRule;

/**
 * @brief Initializes the specified @p parser.
 * @param parser The parser to initialize.
 * @param scanner The scanner associated with the @p parser.
 */
void ParserInit(Parser *parser, Scanner *scanner);

/**
 * @brief Compiles @p source code to a Chunk.
 * @param source The source code to compile.
 * @param chunk The compiled chunk from @p source.
 * @return True when the compilation was successful.
 */
bool Compile(const char *source, Chunk *chunk, CompileMode mode);

#endif // IJO_COMPILER_H