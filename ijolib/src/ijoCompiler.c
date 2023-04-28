#include "ijoCompiler.h"
#include "ijoScanner.h"
#include "ijoLog.h"
#include "ijoObj.h"
#include "gc/ijoNaiveGC.h"
#include "ijoMemory.h"

extern NaiveGCNode *gc;

#ifdef DEBUG_PRINT_CODE
#include "ijoDebug.h"
#endif

// Private functions forward declarations

void parserAdvance(Parser *parser);
void expression(Parser *parser, Chunk *chunk, Table *interned);
void declaration(Parser *parser, Chunk *chunk, Table *interned);
void grouping(Parser *parser, Chunk *chunk, Table *interned);
void unary(Parser *parser, Chunk *chunk, Table *interned);
void binary(Parser *parser, Chunk *chunk, Table *interned);
void consume(Parser *parser, TokenType type, const char * message);

void statement(Parser *parser, Chunk *chunk, Table *interned);
void printStatement(Parser *parser, Chunk *chunk, Table *interned);

void parsePrecedence(Parser *parser, Chunk *chunk, Table *strings, Precedence precedence);
ParseRule* getRule(TokenType type);

bool match(Parser *parser, TokenType type);

void errorAt(Parser *parser, Token *token, const char *message);
void errorAtCurrent(Parser *parser, const char *message);

void emitInstruction(Parser *parser, Chunk *chunk, uint32_t instruction);
void emitInstructions(Parser *parser, Chunk *chunk, uint32_t instruction1, uint32_t instruction2);
void emitReturn(Parser *parser, Chunk *chunk);
void endCompiler(Parser *parser, Chunk *chunk);

// Public functions implementations

bool Compile(const char *source, Chunk *chunk, Table *interned, CompileMode mode) {
    Scanner *scanner = ScannerNew();
    ScannerInit(scanner, source);

    Parser parser;
    ParserInit(&parser, scanner);

    parserAdvance(&parser);

    while (!match(&parser, TOKEN_EOF)) {
        declaration(&parser, chunk, interned);
    }

    consume(&parser, TOKEN_EOF, "Expected end of expression");

    ScannerDelete(scanner);

    endCompiler(&parser, chunk);
    return !parser.hadError;
}

void parserAdvance(Parser *parser) {
    parser->previous = parser->current;

    for (;;) {
        parser->current = ScannerScan(parser->scanner);
        if (parser->current.type != TOKEN_ERROR) break;

        errorAtCurrent(parser, "");
    }
}

void expression(Parser *parser, Chunk *chunk, Table *interned) {
    parsePrecedence(parser, chunk, interned, PREC_ASSIGNMENT);
}

void constDeclaration(Parser *parser, Chunk *chunk, Table *interned) {
    ijoString *varName = CStringCopy(parser->previous.identifierStart,
                                     parser->previous.identifierLength);

    if (TableFindString(interned, varName->chars, varName->length, varName->hash)) {
        errorAtCurrent(parser, "Constant already declared.");
        return;
    }
    
    Chunk tempChunk;
    ChunkNew(&tempChunk);

    expression(parser, &tempChunk, interned);
    Value value = tempChunk.constants.values[0];
    
    consume(parser, TOKEN_EOL, "Only 1 expression accepted per line.");

    TableInsertInternal(interned, varName, value);
    return;
}

void declaration(Parser *parser, Chunk *chunk, Table *interned) {
    if (match(parser, TOKEN_CONST)) {
        constDeclaration(parser, chunk, interned);
    } else if (match(parser, TOKEN_EOL)) {
        // Do Nothing
    } else {
        statement(parser, chunk, interned);
    }

    if (parser->panicMode) synchronize(parser);
}

void statement(Parser *parser, Chunk *chunk, Table *interned) {
    if (match(parser, TOKEN_PRINT)) {
        return printStatement(parser, chunk, interned);
    }

    expression(parser, chunk, interned);
}

void printStatement(Parser *parser, Chunk *chunk, Table *interned) {
    expression(parser, chunk, interned);
    emitInstruction(parser, chunk, OP_PRINT);
}

void grouping(Parser *parser, Chunk *chunk, Table *interned) {
    expression(parser, chunk, interned);
    consume(parser, TOKEN_RIGHT_PAREN, "Expect ')' after expression");
}

void unary(Parser *parser, Chunk *chunk, Table *interned) {
  TokenType operatorType = parser->previous.type;

  // Compile the operand.
  parsePrecedence(parser, chunk, interned, PREC_UNARY);

  // Emit the operator instruction.
  switch (operatorType) {
    case TOKEN_BANG: emitInstruction(parser, chunk, OP_NOT); break;
    case TOKEN_MINUS: emitInstruction(parser, chunk, OP_NEG); break;
    default: return; // Unreachable.
  }
}

void binary(Parser *parser, Chunk *chunk, Table *interned) {
    TokenType operatorType = parser->previous.type;

    ParseRule *rule = getRule(operatorType);
    parsePrecedence(parser, chunk, interned, (Precedence)(rule->precedence + 1));

    switch (operatorType)
    {
    case TOKEN_PLUS:          emitInstruction(parser, chunk, OP_ADD); break;
    case TOKEN_MINUS:         emitInstruction(parser, chunk, OP_SUB); break;
    case TOKEN_SLASH:         emitInstruction(parser, chunk, OP_DIV); break;
    case TOKEN_STAR:          emitInstruction(parser, chunk, OP_MUL); break;
    case TOKEN_PERCENT:       emitInstruction(parser, chunk, OP_MOD); break;
    case TOKEN_BANG_EQUAL:    emitInstruction(parser, chunk, OP_NEQ); break;
    case TOKEN_EQUAL_EQUAL:   emitInstruction(parser, chunk, OP_EQ); break;
    case TOKEN_GREATER:       emitInstruction(parser, chunk, OP_GT); break;
    case TOKEN_GREATER_EQUAL: emitInstruction(parser, chunk, OP_GE); break;
    case TOKEN_LESS:          emitInstruction(parser, chunk, OP_LT); break;
    case TOKEN_LESS_EQUAL:    emitInstruction(parser, chunk, OP_LE); break;
    default: return;
    }
}

void consume(Parser *parser, TokenType type, const char * message) {
    if (parser->current.type == type) {
        parserAdvance(parser);
        return;
    }

    errorAtCurrent(parser, message);
}

uint32_t makeConstant(Chunk *chunk, Value value) {
    int constant = ChunkAddConstant(chunk, value);
    
    if (constant > UINT32_MAX) {
        LogError("Too many constants in one chunk.");
        return 0;
    }

    return constant;
}

void emitInstruction(Parser *parser, Chunk *chunk, uint32_t instruction) {
    ChunkWriteCode(chunk, instruction, parser->previous.line);
}

void emitInstructions(Parser *parser, Chunk *chunk, uint32_t instruction1, uint32_t instruction2) {
    ChunkWriteCode(chunk, instruction1, parser->previous.line);
    ChunkWriteCode(chunk, instruction2, parser->previous.line);
}

void emitConstant(Parser *parser, Chunk *chunk, Value value) {
    emitInstructions(parser, chunk, OP_CONSTANT, makeConstant(chunk, value));
}

void emitReturn(Parser* parser, Chunk *chunk) {
    ChunkWriteCode(chunk, OP_RETURN, parser->previous.line);
}

void endCompiler(Parser *parser, Chunk *chunk) {
    emitReturn(parser, chunk);

    #if DEBUG_PRINT_CODE
    if (!parser->hadError) {
        DisassembleChunk(chunk, "Code");
    }
    #endif
}

void number(Parser *parser, Chunk *chunk, Table *strings) {
    double value = strtod(parser->previous.start, NULL);
    emitConstant(parser, chunk, NUMBER_VAL(value));
}

void literal(Parser *parser, Chunk *chunk, Table *strings) {
  switch (parser->previous.type) {
    case TOKEN_FALSE: emitInstruction(parser, chunk, OP_FALSE); break;
    case TOKEN_TRUE: emitInstruction(parser, chunk, OP_TRUE); break;
    default: return; // Unreachable.
  }
}

void string(Parser *parser, Chunk *chunk, Table *strings) {
    // If ijo supported string escape sequences like \n,
    // we’d translate those here.
    // Since it doesn’t, we can take the characters as they are.

    // +1 to trim leading quotation mark.
    //                             -2 to trim trailing quotation mark.
    ijoString *copiedStr = CStringCopy(parser->previous.start + 1, parser->previous.length - 2);

    ijoString *interned = TableFindString(strings, 
                                          copiedStr->chars,
                                          copiedStr->length,
                                          copiedStr->hash);

    if (interned != NULL) {
        ijoStringDelete(copiedStr);
        emitConstant(parser, chunk, INTERNAL_STR(interned));
    } else {
        Value internedStr = INTERNAL_STR(copiedStr);

        NaiveGCInsert(&gc, &internedStr);
        emitConstant(parser, chunk, internedStr);
        TableInsert(strings, copiedStr, internedStr);
    }
}

void parsePrecedence(Parser *parser, Chunk *chunk, Table *interned, Precedence precedence) {
    parserAdvance(parser);

    ParseRule *rule = getRule(parser->previous.type);

    if (!HAS_ENUM(parser->current.type, rule->acceptedTokens)) {
        errorAt(parser, &parser->current, "Invalid token");
        return;
    }

    if (rule->prefix == NULL) {
        LogError("Expected expression");
        return;
    }

    rule->prefix(parser, chunk, interned);

    while (precedence <= getRule(parser->current.type)->precedence) {
        parserAdvance(parser);
        ParseFunc infixRule = getRule(parser->previous.type)->infix;
        infixRule(parser, chunk, interned);
    }
}

bool check(Parser *parser, TokenType type) {
    return parser->current.type == type;
}

bool match(Parser *parser, TokenType type) {
    if (!check(parser, type)) {
        return false;
    }

    parserAdvance(parser);

    return true;
}

void errorAt(Parser *parser, Token *token, const char *message) {
    if (parser->panicMode) return;

    parser->panicMode = true;
    
    LogError("line %d", token->line);

    if (token->type == TOKEN_EOF) {
        ConsoleWrite(" at end");
    } else if (token->type == TOKEN_ERROR) {
        // Nothing.
    } else {
        ConsoleWrite(" at '%.*s'", token->length, token->start);
    }

    ConsoleWrite(" %s\n", message);
    
    parser->hadError = true;
}

void errorAtCurrent(Parser *parser, const char *message) {
    LogError("%s\n", message);
    errorAt(parser, &parser->previous, parser->current.start);
}

void synchronize(Parser *parser) {
    parser->panicMode = false;

    while ((parser->current.type != TOKEN_EOF) || parser->current.type != TOKEN_EOL) {
        if (parser->previous.type == TOKEN_EOL) return; 

        switch (parser->current.type) {
        case TOKEN_STRUCT:
        case TOKEN_FUNC:
        case TOKEN_CONST:
        case TOKEN_FOR:
        case TOKEN_IF:
        case TOKEN_WHILE:
        case TOKEN_PRINT:
        case TOKEN_RETURN:
            return;

        default:
            ; // Do nothing.
        }

        parserAdvance(parser);
    }
}

// Parser public functions implementations

void ParserInit(Parser *parser, Scanner *scanner) {
    parser->panicMode = false;
    parser->hadError = false;
    parser->scanner = scanner;
}

/**
 * @brief Rules for parsing based on the TokenType.
 * 
 * @note
 * TokenType | Prefix ParseFunc | Infix ParseFunc | Precedence
 */
ParseRule rules[] = {
    // Single-character tokens.
    [TOKEN_COMMA]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_DOT]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_LEFT_BRACE]    = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL}, 
    [TOKEN_LEFT_PAREN]    = {grouping, NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_MINUS]         = {unary,    binary, PREC_TERM,       TOKEN_NUMBER},
    [TOKEN_PLUS]          = {NULL,     binary, PREC_TERM,       TOKEN_NUMBER | TOKEN_STRING},
    [TOKEN_RIGHT_BRACE]   = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_RIGHT_PAREN]   = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_SEMICOLON]     = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_SLASH]         = {NULL,     binary, PREC_FACTOR,     TOKEN_NUMBER},
    [TOKEN_STAR]          = {NULL,     binary, PREC_FACTOR,     TOKEN_NUMBER},
    [TOKEN_PERCENT]       = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    
    // One or two character tokens.
    [TOKEN_BANG]          = {unary,    NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_BANG_EQUAL]    = {NULL,     binary, PREC_EQUALITY,   TOKEN_ALL},
    [TOKEN_EQUAL]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_EQUAL_EQUAL]   = {NULL,     binary, PREC_EQUALITY,   TOKEN_ALL},
    [TOKEN_GREATER]       = {NULL,     binary, PREC_COMPARISON, TOKEN_ALL},
    [TOKEN_GREATER_EQUAL] = {NULL,     binary, PREC_COMPARISON, TOKEN_ALL},
    [TOKEN_LESS]          = {NULL,     binary, PREC_COMPARISON, TOKEN_ALL},
    [TOKEN_LESS_EQUAL]    = {NULL,     binary, PREC_COMPARISON, TOKEN_ALL},

    // Literals.
    [TOKEN_IDENTIFIER]    = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_NUMBER]        = {number,   NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_STRING]        = {string,   NULL,   PREC_NONE,       TOKEN_ALL},

    // KeySymbols. They act like keywords, but use symbols instead.
    [TOKEN_AND]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_ARRAY]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_ASSERT]        = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_STRUCT]        = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_ELSE]          = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_ENUM]          = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_FALSE]         = {literal,  NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_FOR]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_FUNC]          = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_IF]            = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_MAP]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_MODULE]        = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_NIL]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_OR]            = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_PRINT]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_RETURN]        = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_STRUCT]        = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_SUPER]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_THIS]          = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_TRUE]          = {literal,  NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_VAR]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_WHILE]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    
    [TOKEN_ERROR]         = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
    [TOKEN_EOF]           = {NULL,     NULL,   PREC_NONE,       TOKEN_ALL},
};

ParseRule* getRule(TokenType type) {
    return &rules[type];
}