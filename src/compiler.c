#include "compiler.h"
#include "scanner.h"

Chunk Compile(const char *source) {
    Chunk chunk;

    Scanner *scanner = ScannerNew();
    ScannerInit(scanner, source);
    ScannerDelete(scanner);

    return chunk;
}