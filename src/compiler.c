#include "compiler.h"
#include "scanner.h"
#include "log.h"

Chunk Compile(const char *source) {
    Chunk chunk;

    Scanner *scanner = ScannerNew();
    ScannerInit(scanner, source);
    ScannerDelete(scanner);

    int line = 1;
    for (;;) {
        Token token = ScannerScan(scanner);

        if (token.line != line) {
            ConsoleWrite("%4d ", token.line);
            line = token.line;
        } else {
            ConsoleWrite("   | ");
        }

        ConsoleWriteLine("%2d '%.*s'", token.type, token.length, token.start);

        if (token.type == TOKEN_EOF) {
            break;
        }
    }

    return chunk;
}