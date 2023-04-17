#include "compiler.h"
#include "scanner.h"
#include "log.h"

// Private functions forward declarations

void advance(Parser *parser);
void expression(Parser *parser);
void consume(Parser *parser, TokenType type, const char * message);

Token scanToken(Parser *parser);

void errorAt(Parser *parser, Token *token, const char *message);
void errorAtCurrent(Parser *parser);

void emitIntruction(Parser *parser, Chunk *chunk, uint32_t instruction);
void emitInstructions(Parser *parser, Chunk *chunk, uint32_t instruction1, uint32_t instruction2);
void emitReturn(Chunk *chunk);
void endCompiler(Chunk *chunk);

// Public functions implementations

bool Compile(const char *source, Chunk *chunk) {
    Scanner *scanner = ScannerNew();
    ScannerInit(scanner, source);

    Parser parser;
    ParserInit(&parser);

    advance(&parser);
    expression(&parser);
    consume(&parser, TOKEN_EOF, "Expected end of expression");

    ScannerDelete(scanner);

    endCompiler(chunk);
    return !parser.hadError;
}

void advance(Parser *parser) {
    parser->previous = parser->current;

    for (;;) {
        parser->current = scanToken(parser);
        if (parser->current.type != TOKEN_ERROR) break;

        errorAtCurrent(parser);
    }
}

void expression(Parser *parser) {

}

void consume(Parser *parser, TokenType type, const char * message) {
    if (parser->current.type == type) {
        advance(parser);
        return;
    }

    errorAtCurrent(parser);
}


void emitIntruction(Parser *parser, Chunk *chunk, uint32_t instruction) {
    ChunkWriteCode(chunk, instruction, parser->previous.line);
}

void emitInstructions(Parser *parser, Chunk *chunk, uint32_t instruction1, uint32_t instruction2) {

}

void emitReturn(Chunk *chunk) {
    ChunkWriteCode(chunk, OP_RETURN);
}

void endCompiler(Chunk *chunk) {
    emitReturn(chunk);
}

void errorAt(Parser *parser, Token *token, const char *message) {
    if (parser->panicMode) return;

    parser->panicMode = true;
    
    LogError("line %d", token->line);

    if (token->type == TOKEN_EOF) {
        LogError(" at end");
    } else if (token->type == TOKEN_ERROR) {
        // Nothing.
    } else {
        LogError(" at '%.*s'", token->length, token->start);
    }

    LogError(": %s\n", message);
    
    parser->hadError = true;
}

void errorAtCurrent(Parser *parser) {
    errorAt(parser, &parser->previous, parser->current.start);
}

// Parser public functions implementations

void ParserInit(Parser *parser) {
    parser->panicMode = false;
    parser->hadError = false;
}