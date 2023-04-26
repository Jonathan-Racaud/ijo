#include "ijoScanner.h"
#include "ijoMemory.h"
#include "ijoLog.h"

// Private function forward declaration
#ifndef IJO_SCANNER_PRIV_C
#define IJO_SCANNER_PRIV_C
Token makeToken(Scanner *scanner, TokenType);
Token errorToken(Scanner *scanner, const char *message);
Token scanString(Scanner *scanner);
Token scanNumber(Scanner *scanner);
Token scanIdentifier(Scanner *scanner);
Token constOrKeyword(Scanner *scanner);
Token boolOrAssert(Scanner *scanner);
TokenType identifierType();

bool isAlpha(char c);
bool isDigit(char c);
bool isWhitespace(char c);
bool isAtEnd(Scanner *scanner);
bool match(Scanner* scanner, char expected);
char scannerAdvance(Scanner *scanner);
char peek(Scanner *scanner);
char peekNext(Scanner *scanner);
void skipWhitespace(Scanner *scanner);
#endif // IJO_SCANNER_PRIV_C

// Public functions implementations

Scanner *ScannerNew() {
    Scanner *scanner = (Scanner*)malloc(sizeof(Scanner));

    return scanner;
}

void ScannerDelete(Scanner *scanner) {
    Delete(scanner);
}

void ScannerInit(Scanner *scanner, const char *source) {
    scanner->start = source;
    scanner->current = source;
    scanner->line = 1;
}

Token ScannerScan(Scanner *scanner) {
    skipWhitespace(scanner);

    scanner->start = scanner->current;

    if (isAtEnd(scanner)) return makeToken(scanner, TOKEN_EOF);

    char c = scannerAdvance(scanner);

    if (isDigit(c)) return scanNumber(scanner);
    if (isAlpha(c) || (c == '@')) return scanIdentifier(scanner);

    switch (c) {
        case '(': return makeToken(scanner, TOKEN_LEFT_PAREN);
        case ')': return makeToken(scanner, TOKEN_RIGHT_PAREN);
        case '{': return makeToken(scanner, TOKEN_LEFT_BRACE);
        case '}': return makeToken(scanner, TOKEN_RIGHT_BRACE);
        case ';': return makeToken(scanner, TOKEN_SEMICOLON);
        case ',': return makeToken(scanner, TOKEN_COMMA);
        case '.': return makeToken(scanner, TOKEN_DOT);
        case '-': return makeToken(scanner, TOKEN_MINUS);
        case '+': return makeToken(scanner, TOKEN_PLUS);
        case '/': return makeToken(scanner, TOKEN_SLASH);
        case '*': return makeToken(scanner, TOKEN_STAR);

        case '!':
            return makeToken(scanner,
                match(scanner, '=') ? TOKEN_BANG_EQUAL : TOKEN_BANG);
        case '=':
            return makeToken(scanner,
                match(scanner, '=') ? TOKEN_EQUAL_EQUAL : TOKEN_EQUAL);
        case '<':
            return makeToken(scanner,
                match(scanner, '=') ? TOKEN_LESS_EQUAL : TOKEN_LESS);
        case '>':
            return makeToken(scanner,
                match(scanner, '=') ? TOKEN_GREATER_EQUAL : TOKEN_GREATER);

        case '"': return scanString(scanner);

        /**
         * In ijo a 'Keyword' is the combination of '#' + identifier + one of the 
         * symbols used in the switch inside of the varOrKeyword function.
        */
        case '#': return constOrKeyword(scanner);
        case '\n': return makeToken(scanner, TOKEN_EOL);
    }

    return errorToken(scanner, "Unexpected character");
}

// Private functions implementations

Token makeToken(Scanner *scanner, TokenType type) {
    Token token = {
        type,
        scanner->start,
        (int)(scanner->current - scanner->start),
        NULL,
        0,
        scanner->line
    };

    return token;
}

Token makeComplexeToken(
  Scanner *scanner,
  TokenType type,
  const char *identifierStart,
  int identifierLength) {
    Token token = {
      type,
      scanner->start,
      (int)(scanner->current - scanner->start),
      identifierStart,
      identifierLength,
      scanner->line
    };

    return token;
}

Token errorToken(Scanner *scanner, const char *message) {
    LogError("%s at line %s", message, scanner->line);

    Token error = {
        TOKEN_ERROR,
        message,
        (int)strlen(message),
        NULL,
        0,
        scanner->line
    };

    return error;
}

Token scanString(Scanner *scanner) {
  while (peek(scanner) != '"' && !isAtEnd(scanner)) {
    if (peek(scanner) == '\n') scanner->line++;
    scannerAdvance(scanner);
  }

  if (isAtEnd(scanner)) return errorToken(scanner, "Unterminated string.");

  // The closing quote.
  scannerAdvance(scanner);
  return makeToken(scanner, TOKEN_STRING);
}

Token scanNumber(Scanner *scanner) {
  while (isDigit(peek(scanner))) scannerAdvance(scanner);

  // Look for a fractional part.
  if (peek(scanner) == '.' && isDigit(peekNext(scanner))) {
    // Consume the ".".
    scannerAdvance(scanner);

    while (isDigit(peek(scanner))) scannerAdvance(scanner);
  }

  return makeToken(scanner, TOKEN_NUMBER);
}

Token scanIdentifier(Scanner *scanner) {
  while (isAlpha(peek(scanner)) || isDigit(peek(scanner))) scannerAdvance(scanner);
  return makeToken(scanner, identifierType(scanner));
}

Token constOrKeyword(Scanner *scanner) {
    char c;

    // We ignore whitespace that may be between '#' and the identifier.
    while (isWhitespace(peek(scanner))) {
      if (isAtEnd(scanner)) return errorToken(scanner, "Unexpected character");
      
      scannerAdvance(scanner);
    }

    // We parse the identifier
    const char *identifierStart = scanner->current;
    int identifierLength = 0;
    while (isAlpha(peek(scanner)) ||
           isDigit(peek(scanner))) {

        /**
         * The following syntax is accepted:
         * 
         * #Obj
         * {
         *      field: Type
         * }
         * 
         * #func
         * (param: Type) -> Type {}
         * 
         * #assert
         * @(param: Type) {}
         * 
         * #Enum
         * |
         *      Val1,
         *      Val2
         * |
         * 
         * #Array
         * [String]
         * 
         * #HashMap
         * <String, String>
         */
        if (isWhitespace(peek(scanner) || (peek(scanner) == '\n'))) break;

        if (isAtEnd(scanner)) return errorToken(scanner, "Unexpected character");
        
        c = scannerAdvance(scanner);
        identifierLength++;
    }

    // We ignore whitespace that may be between the identifier and the first char that define what
    // we are scanning.
    while (isWhitespace(peek(scanner))) {
      if (isAtEnd(scanner)) return errorToken(scanner, "Unexpected character");
      
      scannerAdvance(scanner);
    }

    // We consume the current char so we can select what to do.
    c = scannerAdvance(scanner);

    switch (c)
    {
    case '{': return makeComplexeToken(scanner, TOKEN_STRUCT, identifierStart, identifierLength);
    case '[': return makeComplexeToken(scanner, TOKEN_ARRAY, identifierStart, identifierLength);
    case '<': return makeComplexeToken(scanner, TOKEN_MAP, identifierStart, identifierLength);
    case '|': return makeComplexeToken(scanner, TOKEN_ENUM, identifierStart, identifierLength);
    case '%': return makeComplexeToken(scanner, TOKEN_MODULE, identifierStart, identifierLength);
    case '=': return makeComplexeToken(scanner, TOKEN_CONST, identifierStart, identifierLength);
    default:
        break;
    }
}

TokenType checkKeyword(
  Scanner* scanner,
  int start,
  int length,
  const char* rest,
  TokenType type
) {
  if (scanner->current - scanner->start == start + length &&
      memcmp(scanner->start + start, rest, length) == 0) {
    return type;
  }

  return TOKEN_IDENTIFIER;
}

bool isAtEnd(Scanner *scanner) {
    return *scanner->current == '\0';
}

char scannerAdvance(Scanner *scanner) {
  scanner->current++;
  return scanner->current[-1];
}

char peek(Scanner *scanner) {
    return *scanner->current;
}

char peekNext(Scanner *scanner) {
  if (isAtEnd(scanner)) return '\0';
  return scanner->current[1];
}

bool match(Scanner* scanner, char expected) {
  if (isAtEnd(scanner)) return false;
  if (*scanner->current != expected) return false;
  scanner->current++;
  return true;
}

void skipWhitespace(Scanner *scanner) {
    for (;;) {
    char c = peek(scanner);
    switch (c) {
        case ' ':
        case '\r':
        case '\t':
            scannerAdvance(scanner);
            break;
        case '/':
            if (peekNext(scanner) == '/') {
            // A comment goes until the end of the line.
            while (peek(scanner) != '\n' && !isAtEnd(scanner)) scannerAdvance(scanner);
            } else {
                return;
            }
            break;
        default:
            return;
    }
  }
}

bool isDigit(char c) {
  return c >= '0' && c <= '9';
}

bool isAlpha(char c) {
  return (c >= 'a' && c <= 'z') ||
         (c >= 'A' && c <= 'Z') ||
          c == '_';
}

bool isWhitespace(char c) {
    return (c == ' ' || c == '\r' || c == '\t');
}

TokenType identifierType(Scanner *scanner) {
  /**
   * The only exception to the KeySymbol rules has to do with the boolean values.
   * The reason is that I did not find a non cryptic, easy to read way to represent 
   * them using symbols for now.
   * 
   * They are reusing syntax for calling an assert function as they are closely related
   * to how this type of function is meant to be used in ijo.
  */    
  switch (scanner->start[0])
  {
  case '@':
    if (scanner->current - scanner->start > 1) {
      switch (scanner->start[1])
      {
      case 't': return checkKeyword(scanner, 2, 3, "rue", TOKEN_TRUE);
      case 'f': return checkKeyword(scanner, 2, 4, "alse", TOKEN_FALSE);
      }
    }
    break;  
  
  default: return TOKEN_IDENTIFIER;
  }
}