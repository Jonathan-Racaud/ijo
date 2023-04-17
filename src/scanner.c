#include "scanner.h"
#include "ijoMemory.h"

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