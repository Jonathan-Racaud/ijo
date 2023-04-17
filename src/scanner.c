#include "scanner.h"
#include "ijoMemory.h"
#include "log.h"

// Private function forward declaration

Token makeToken(Scanner *scanner, TokenType);
Token errorToken(Scanner *scanner, const char *message);

bool isAtEnd(Scanner *scanner);

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
    scanner->start = scanner->current;

    if (isAtEnd(scanner)) return makeToken(scanner, TOKEN_EOF);

    return errorToken(scanner, "Unexpected character");
}

Token makeToken(Scanner *scanner, TokenType type) {
    Token token = {
        type,
        scanner->start,
        (int)(scanner->current - scanner->start),
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
        scanner->line
    };

    return error;
}

bool isAtEnd(Scanner *scanner) {
    return *scanner->current == '\0';
}