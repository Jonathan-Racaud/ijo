#ifndef IJO_TOKEN_H
#define IJO_TOKEN_H

/// @brief Represents the type of token.
typedef enum {
  TOKEN_ERROR,
  TOKEN_EOF,

  // Single-character tokens.
  TOKEN_LEFT_PAREN,
  TOKEN_RIGHT_PAREN,
  TOKEN_LEFT_BRACE,
  TOKEN_RIGHT_BRACE,
  TOKEN_COMMA,
  TOKEN_DOT,
  TOKEN_MINUS,
  TOKEN_PLUS,
  TOKEN_SEMICOLON,
  TOKEN_SLASH,
  TOKEN_STAR,
  TOKEN_PERCENT,

  // One or two character tokens.
  TOKEN_BANG,
  TOKEN_BANG_EQUAL,
  TOKEN_EQUAL,
  TOKEN_EQUAL_EQUAL,
  TOKEN_GREATER,
  TOKEN_GREATER_EQUAL,
  TOKEN_LESS,
  TOKEN_LESS_EQUAL,

  // Literals.
  TOKEN_IDENTIFIER,
  TOKEN_STRING,
  TOKEN_NUMBER,

  // KeySymbols. They act like keywords, but use symbols instead.
  TOKEN_AND,
  TOKEN_STRUCT,
  TOKEN_ELSE,
  TOKEN_FALSE,
  TOKEN_FOR,
  TOKEN_FUNC,
  TOKEN_ASSERT,
  TOKEN_IF,
  TOKEN_NIL,
  TOKEN_OR,
  TOKEN_PRINT,
  TOKEN_RETURN,
  TOKEN_SUPER,
  TOKEN_THIS,
  TOKEN_TRUE,
  TOKEN_CONST,
  TOKEN_VAR,
  TOKEN_WHILE,
  TOKEN_MODULE,
  TOKEN_ARRAY,
  TOKEN_MAP,
  TOKEN_ENUM,
  
  // Acts like ';' in other languages. Kind of.
  TOKEN_EOL,

  // For when a parsing rule can accept any kind of token.
  // Except the TOKEN_ERROR and TOKEN_EOF.
  TOKEN_ALL = ~((1 << TOKEN_ERROR) | (1 << TOKEN_EOF))
} TokenType;

/// @brief Represents a token
typedef struct {
    /// @brief The type of token.
    TokenType type;

    /// @brief Start of the token in the source code.
    const char *start;

    /// @brief Length of the token.
    int length;

    /// @brief Start of the identifier. This is used only for const, struct, functions, assertions,
    /// arrays or map.
    const char *identifierStart;

    /// @brief The length of the identifier.
    int identifierLength;

    /// @brief Line where the token is located.
    int line;
} Token;

#endif // IJO_TOKEN_H