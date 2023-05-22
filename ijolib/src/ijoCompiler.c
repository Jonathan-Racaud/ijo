#include "ijoCompiler.h"
#include "gc/ijoNaiveGC.h"
#include "ijoLog.h"
#include "ijoMemory.h"
#include "ijoObj.h"
#include "ijoScanner.h"

extern NaiveGCNode *gc;

#ifdef DEBUG_PRINT_CODE
#include "ijoDebug.h"
#endif

// Private functions forward declarations

void parserAdvance(Parser *parser);
void expression(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void declaration(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void grouping(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void unary(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void binary(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void noop(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void identifier(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void returnExpr(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void consume(Parser *parser, TokType type, const char *message);

void statement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void printStatement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void block(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void ifStatement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned);
void and (Parser * parser, Compiler *compiler, Chunk *chunk, Table *interned);
void or (Parser * parser, Compiler *compiler, Chunk *chunk, Table *interned);

void parsePrecedence(Parser *parser, Compiler *compiler, Chunk *chunk, Table *strings, Precedence precedence);
ParseRule *getRule(TokType type);

bool match(Parser *parser, TokType type);
bool check(Parser *parser, TokType type);

void errorAt(Parser *parser, Token *token, const char *message);
void errorAtCurrent(Parser *parser, const char *message);

void emitInstruction(Parser *parser, Chunk *chunk, uint32_t instruction);
void emitInstructions(Parser *parser, Chunk *chunk, uint32_t instruction1, uint32_t instruction2);
void emitConstant(Parser *parser, Chunk *chunk, Value value);
void emitReturn(Parser *parser, Chunk *chunk);
uint32_t emitJump(Parser *parser, Chunk *chunk, uint32_t instruction);
void emitLoopStart(Parser *parser, Chunk *chunk, uint32_t instruction);
void endCompiler(Parser *parser, Chunk *chunk);
void synchronize(Parser *parser);
uint32_t makeConstant(Chunk *chunk, Value value);

uint32_t parseVariable(Parser *parser, Compiler *compiler, Chunk *chunk, bool isConst, const char *message);
void markInitialized(Compiler *compiler);

void beginScope(Compiler *compiler);
void endScope(Parser *parser, Compiler *compiler, Chunk *chunk);

// Public functions implementations

bool Compile(const char *source, Chunk *chunk, Table *interned, CompileMode mode)
{
    Compiler compiler;
    CompilerInit(&compiler);

    Scanner *scanner = ScannerNew();
    ScannerInit(scanner, source);

    Parser parser;
    ParserInit(&parser, scanner);

    parserAdvance(&parser);

    while (!match(&parser, TOKEN_EOF))
    {
        declaration(&parser, &compiler, chunk, interned);
    }

    consume(&parser, TOKEN_EOF, "Expected end of expression");

    ScannerDelete(scanner);

    endCompiler(&parser, chunk);
    return !parser.hadError;
}

void parserAdvance(Parser *parser)
{
    parser->previous = parser->current;

    for (;;)
    {
        parser->current = ScannerScan(parser->scanner);
        if (parser->current.type != TOKEN_ERROR)
            break;

        errorAtCurrent(parser, "");
    }
}

void expression(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    parsePrecedence(parser, compiler, chunk, interned, PREC_ASSIGNMENT);
}

void constDeclaration(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    if (compiler->scopeDepth == 0)
    {
        ijoString *varName = CStringCopy(parser->previous.identifierStart,
                                         parser->previous.identifierLength);

        if (TableFindString(interned, varName->chars, varName->length, varName->hash))
        {
            ijoStringDelete(varName);
            errorAtCurrent(parser, "Constant already declared.");
            return;
        }

        Chunk tempChunk;
        ChunkNew(&tempChunk);

        expression(parser, compiler, &tempChunk, interned);
        Value value = tempChunk.constants.values[0];

        consume(parser, TOKEN_EOL, "Only 1 expression accepted per line.");

        TableInsertInternal(interned, varName, value);

        if (IS_OBJ(value))
        {
            NaiveGCInsert(&gc, &value);
        }

        NaiveGCInsert(&gc, &INTERNAL_STR(varName));
    }
    else
    {
        uint32_t index = parseVariable(parser, compiler, chunk, true, "Expected variable name");

        if (match(parser, TOKEN_EQUAL))
        {
            expression(parser, compiler, chunk, interned);
        }
        else
        {
            errorAtCurrent(parser, "Variable declaration must have a value.");
        }
    }
    return;
}

uint32_t identifierConstant(Token *name, Chunk *chunk)
{
    return makeConstant(chunk, OBJ_VAL(CStringCopy(name->start, name->length)));
}

void addLocal(Compiler *compiler, Token name, bool isConst)
{
    if (compiler->localCount == UINT8_COUNT)
    {
        LogError("Too many local variables in function.");
        return;
    }

    Local *local = &compiler->locals[compiler->localCount++];
    local->name = name;
    local->depth = -1;
    local->constant = isConst;
}

bool identifierEqual(Token *a, Token *b)
{
    if (a->length != b->length)
        return false;

    return memcmp(a->start, b->start, a->length) == 0;
}

void declareVariable(Parser *parser, Compiler *compiler, bool isConst)
{
    if (compiler->scopeDepth == 0)
        return;

    Token *name = &parser->previous;

    for (int i = compiler->localCount - 1; i >= 0; i--)
    {
        Local *local = &compiler->locals[i];

        if ((local->depth != -1) && (local->depth < compiler->scopeDepth))
        {
            break;
        }

        if (identifierEqual(name, &local->name))
        {
            errorAtCurrent(parser, "A variable with this name already exist in this scope.");
        }
    }

    addLocal(compiler, *name, isConst);
}

uint32_t parseVariable(Parser *parser, Compiler *compiler, Chunk *chunk, bool isConst, const char *message)
{
    consume(parser, TOKEN_IDENTIFIER, message);

    declareVariable(parser, compiler, isConst);
    if (compiler->scopeDepth > 0)
        return 0;

    return identifierConstant(&parser->previous, chunk);
}

void defineVariable(Compiler *compiler)
{
    if (compiler->scopeDepth > 0)
    {
        markInitialized(compiler);
        return;
    }
}

void varDeclaration(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    if (compiler->scopeDepth == 0)
    {
        errorAtCurrent(parser, "Variable declaration are not allowed at the global scope");
        return;
    }

    parseVariable(parser, compiler, chunk, false, "Expected variable name");

    if (match(parser, TOKEN_EQUAL))
    {
        expression(parser, compiler, chunk, interned);
    }
    else
    {
        errorAtCurrent(parser, "Variable declaration must have a value.");
    }

    if (!parser->parsingLoop)
    {
        consume(parser, TOKEN_EOL, "Only one expression per line");
    }

    defineVariable(compiler);
}

void declaration(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    if (match(parser, TOKEN_CONST))
    {
        constDeclaration(parser, compiler, chunk, interned);
    }
    else if (match(parser, TOKEN_VAR))
    {
        varDeclaration(parser, compiler, chunk, interned);
    }
    else if (match(parser, TOKEN_RETURN))
    {
        returnExpr(parser, compiler, chunk, interned);
    }
    else if (match(parser, TOKEN_EOL))
    {
        // Do Nothing
    }
    else
    {
        statement(parser, compiler, chunk, interned);
    }

    if (parser->panicMode)
        synchronize(parser);
}

void expressionStatement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    expression(parser, compiler, chunk, interned);
    if (!parser->parsingLoop)
    {
        consume(parser, TOKEN_EOL, "Only one expression per line accepted.");
    }
    emitInstruction(parser, chunk, OP_POP);
}

void returnExpr(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    emitInstruction(parser, chunk, OP_RETURN);
}

void patchJump(Chunk *chunk, uint32_t offset, uint32_t adjustment)
{
    chunk->code[offset + 1] = chunk->count - offset - adjustment;
}

// TODO: Better understand why the need of different adjustment for the jump instructions
// in ifStatement, or, and. I do not really like those magic number, so they should be explained
// when understood.
void ifStatement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    expression(parser, compiler, chunk, interned);
    consume(parser, TOKEN_RIGHT_PAREN, "Expected ')' after condition.");

    uint32_t thenJump = emitJump(parser, chunk, OP_JUMP_IF_FALSE);
    emitInstruction(parser, chunk, OP_POP);
    statement(parser, compiler, chunk, interned);

    patchJump(chunk, thenJump, 1);

    if (match(parser, TOKEN_ELSE))
    {
        uint32_t elseJump = emitJump(parser, chunk, OP_JUMP);
        emitInstruction(parser, chunk, OP_POP);
        statement(parser, compiler, chunk, interned);
        patchJump(chunk, elseJump, 2);
    }
}

void and (Parser * parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    uint32_t endJump = emitJump(parser, chunk, OP_JUMP_IF_FALSE);

    emitInstruction(parser, chunk, OP_POP);
    parsePrecedence(parser, compiler, chunk, interned, PREC_AND);

    patchJump(chunk, endJump, 1);
}

void or (Parser * parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    uint32_t elseJump = emitJump(parser, chunk, OP_JUMP_IF_FALSE);
    uint32_t endJump = emitJump(parser, chunk, OP_JUMP);

    patchJump(chunk, elseJump, 1);
    emitInstruction(parser, chunk, OP_POP);

    parsePrecedence(parser, compiler, chunk, interned, PREC_OR);
    patchJump(chunk, endJump, 0);
}

void cleanTempLoopChunks(Chunk *first, Chunk *second, Chunk *third, Chunk *body)
{
    ChunkDelete(first);
    ChunkDelete(second);
    ChunkDelete(third);
    ChunkDelete(body);
}

void chunkAppendInto(Chunk *dest, Chunk *src)
{
    uint32_t destConstNum = dest->constants.count;

    for (uint32_t i = 0; i < src->count; i++)
    {

        ChunkWriteCode(dest, src->code[i], src->lines[i]);
        if (src->code[i] == OP_CONSTANT)
        {
            i++; // We now want to write the OP_CONSTANT ARG
            ChunkWriteCode(dest, src->code[i] + ((destConstNum > 0) ? (destConstNum) : (0)), src->lines[i]);
        }
        else if (src->code[i] == OP_GET_LOCAL)
        {
            i++;
            // We now want to write the arg, but it needs this case because GET_LOCAL can have 0 as arg
            // which could be seen as OP_CONSTANT
            ChunkWriteCode(dest, src->code[i], src->lines[i]);
        }
        else if (src->code[i] == OP_SET_LOCAL)
        {
            i++;
            // We now want to write the arg, but it needs this case because SET_LOCAL can have 0 as arg
            // which could be seen as OP_CONSTANT
            ChunkWriteCode(dest, src->code[i], src->lines[i]);
        }
    }

    for (uint32_t i = 0; i < src->constants.count; i++)
    {
        ChunkAddConstant(dest, src->constants.values[i]);
    }
}

/**
 * A loop statement can have these forms:
 *
 * ~(initializer; condition; increment) {}
 * ~(condition;increment) {}
 * ~(condition) {}
 * ~() {} --> This is an infinite loop
 */
void loopStatement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    if (match(parser, TOKEN_SEMICOLON))
    {
        errorAtCurrent(parser, "Loop must be specified as one of:\n  ~(initializer; condition; increment) {...}\n  ~(condition;increment){...}\n  ~(condition){...}\n  ~(){...}");
        return;
    }

    beginScope(compiler);
    parser->parsingLoop = true;
    int parsedStatement = 0;

    Chunk firstStatement;
    ChunkNew(&firstStatement);

    Chunk secondStatement;
    ChunkNew(&secondStatement);

    Chunk thirdStatement;
    ChunkNew(&thirdStatement);

    Chunk bodyStatement;
    ChunkNew(&bodyStatement);

    if (match(parser, TOKEN_VAR))
    {
        varDeclaration(parser, compiler, &firstStatement, interned);
        parsedStatement++;
    }
    else
    {
        expression(parser, compiler, &firstStatement, interned);
        parsedStatement++;
    }

    if (match(parser, TOKEN_SEMICOLON))
    {
        if (match(parser, TOKEN_VAR))
        {
            errorAtCurrent(parser, "Tried to declare a variable when a boolean condition is expected.");
            cleanTempLoopChunks(&firstStatement, &secondStatement, &thirdStatement, &bodyStatement);
            endScope(parser, compiler, chunk);
            parser->parsingLoop = false;
            return;
        }

        expression(parser, compiler, &secondStatement, interned);
        parsedStatement++;
    }

    if (match(parser, TOKEN_SEMICOLON))
    {
        if (match(parser, TOKEN_VAR))
        {
            errorAtCurrent(parser, "Tried to declare a variable when a boolean condition is expected.");
            cleanTempLoopChunks(&firstStatement, &secondStatement, &thirdStatement, &bodyStatement);
            endScope(parser, compiler, chunk);
            parser->parsingLoop = false;
            return;
        }

        expressionStatement(parser, compiler, &thirdStatement, interned);
        parsedStatement++;
    }

    consume(parser, TOKEN_RIGHT_PAREN, "Expect ')' after loop clauses.");

    if (!check(parser, TOKEN_LEFT_BRACE))
    {
        errorAtCurrent(parser, "Loop body must be between '{}'");
        cleanTempLoopChunks(&firstStatement, &secondStatement, &thirdStatement, &bodyStatement);
        endScope(parser, compiler, chunk);
        parser->parsingLoop = false;
        return;
    }

    statement(parser, compiler, &bodyStatement, interned);

    uint32_t loopStart = chunk->count;

    switch (parsedStatement)
    {
    case 1: // ~(condition) {}
    {
        loopStart = chunk->count;
        chunkAppendInto(chunk, &firstStatement);
        uint32_t jump = emitJump(parser, chunk, OP_JUMP_IF_FALSE);
        emitInstruction(parser, chunk, OP_POP);

        chunkAppendInto(chunk, &bodyStatement);
        patchJump(chunk, jump, 0);
        break;
    }
    case 2: // ~(condition; increment) {}
    {
        loopStart = chunk->count;
        chunkAppendInto(chunk, &firstStatement);
        uint32_t jump = emitJump(parser, chunk, OP_JUMP_IF_FALSE);
        emitInstruction(parser, chunk, OP_POP);

        chunkAppendInto(chunk, &bodyStatement);
        chunkAppendInto(chunk, &secondStatement);

        patchJump(chunk, jump, 0);
        break;
    }
    case 3: // ~(init; condition; increment) {}
    {
        chunkAppendInto(chunk, &firstStatement);

        loopStart = chunk->count;
        chunkAppendInto(chunk, &secondStatement);
        uint32_t jump = emitJump(parser, chunk, OP_JUMP_IF_FALSE);
        emitInstruction(parser, chunk, OP_POP);

        chunkAppendInto(chunk, &bodyStatement);
        chunkAppendInto(chunk, &thirdStatement);

        patchJump(chunk, jump, 0);
        break;
    }
    case 0: // Infinite loop
    {
        chunkAppendInto(chunk, &bodyStatement);
        break;
    }
    default:
        errorAtCurrent(parser, "Invalid loop statement.");
        cleanTempLoopChunks(&firstStatement, &secondStatement, &thirdStatement, &bodyStatement);
        endScope(parser, compiler, chunk);
        parser->parsingLoop = false;
        return;
    }

    loopStart -= (parsedStatement >= 2) ? (2) : (0);
    emitLoopStart(parser, chunk, loopStart);
    endScope(parser, compiler, chunk);

    cleanTempLoopChunks(&firstStatement, &secondStatement, &thirdStatement, &bodyStatement);
    parser->parsingLoop = false;
}

void statement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    if (match(parser, TOKEN_EOL))
        return;

    if (match(parser, TOKEN_PRINT) || match(parser, TOKEN_PRINTLN))
    {
        printStatement(parser, compiler, chunk, interned);
        return;
    }
    else if (match(parser, TOKEN_IF))
    {
        ifStatement(parser, compiler, chunk, interned);
        return;
    }
    else if (match(parser, TOKEN_LOOP))
    {
        loopStatement(parser, compiler, chunk, interned);
        return;
    }
    else if (match(parser, TOKEN_LEFT_BRACE))
    {
        beginScope(compiler);
        block(parser, compiler, chunk, interned);
        endScope(parser, compiler, chunk);
        return;
    }

    expressionStatement(parser, compiler, chunk, interned);
}

void printStatement(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    OpCode op = (parser->previous.type == TOKEN_PRINT) ? OP_PRINT : OP_PRINTLN;

    if (!match(parser, TOKEN_EOL))
    {
        expression(parser, compiler, chunk, interned);
    }
    else
    {
        emitConstant(parser, chunk, NOOP_VAL());
    }

    emitInstruction(parser, chunk, op);
}

void block(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    while (!check(parser, TOKEN_RIGHT_BRACE) && !check(parser, TOKEN_EOF))
    {
        declaration(parser, compiler, chunk, interned);
    }

    consume(parser, TOKEN_RIGHT_BRACE, "Expected '}' after block.");
}

void grouping(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    expression(parser, compiler, chunk, interned);
    consume(parser, TOKEN_RIGHT_PAREN, "Expect ')' after expression");
}

void unary(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    TokType operatorType = parser->previous.type;

    // Compile the operand.
    parsePrecedence(parser, compiler, chunk, interned, PREC_UNARY);

    // Emit the operator instruction.
    switch (operatorType)
    {
    case TOKEN_BANG:
        emitInstruction(parser, chunk, OP_NOT);
        break;
    case TOKEN_MINUS:
        emitInstruction(parser, chunk, OP_NEG);
        break;
    default:
        return; // Unreachable.
    }
}

void binary(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    TokType operatorType = parser->previous.type;

    ParseRule *rule = getRule(operatorType);
    parsePrecedence(parser, compiler, chunk, interned, (Precedence)(rule->precedence + 1));

    switch (operatorType)
    {
    case TOKEN_PLUS:
        emitInstruction(parser, chunk, OP_ADD);
        break;
    case TOKEN_MINUS:
        emitInstruction(parser, chunk, OP_SUB);
        break;
    case TOKEN_SLASH:
        emitInstruction(parser, chunk, OP_DIV);
        break;
    case TOKEN_STAR:
        emitInstruction(parser, chunk, OP_MUL);
        break;
    case TOKEN_PERCENT:
        emitInstruction(parser, chunk, OP_MOD);
        break;
    case TOKEN_BANG_EQUAL:
        emitInstruction(parser, chunk, OP_NEQ);
        break;
    case TOKEN_EQUAL_EQUAL:
        emitInstruction(parser, chunk, OP_EQ);
        break;
    case TOKEN_GREATER:
        emitInstruction(parser, chunk, OP_GT);
        break;
    case TOKEN_GREATER_EQUAL:
        emitInstruction(parser, chunk, OP_GE);
        break;
    case TOKEN_LESS:
        emitInstruction(parser, chunk, OP_LT);
        break;
    case TOKEN_LESS_EQUAL:
        emitInstruction(parser, chunk, OP_LE);
        break;
    default:
        return;
    }
}

void markInitialized(Compiler *compiler)
{
    compiler->locals[compiler->localCount - 1].depth = compiler->scopeDepth;
}

uint32_t resolveLocal(Parser *parser, Compiler *compiler, Token *name)
{
    for (int i = compiler->localCount - 1; i >= 0; i--)
    {
        Local *local = &compiler->locals[i];

        if (identifierEqual(name, &local->name))
        {
            if (local->depth == -1)
            {
                errorAtCurrent(parser, "Can't read local variable in its own initialization.");
            }
            return i;
        }
    }

    return -1;
}

void namedVariable(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    int arg = resolveLocal(parser, compiler, &parser->previous);
    bool canAssign = parser->precedence <= PREC_ASSIGNMENT;

    // We found a local variable.
    if (arg != -1)
    {
        if (canAssign && match(parser, TOKEN_EQUAL))
        {
            if (compiler->locals[arg].constant)
            {
                errorAtCurrent(parser, "Tried to modify value of constant.");
                return;
            }

            expression(parser, compiler, chunk, interned);
            emitInstructions(parser, chunk, OP_SET_LOCAL, arg);
        }
        else
        {
            emitInstructions(parser, chunk, OP_GET_LOCAL, arg);
        }
    }
    else
    {
        if (canAssign && match(parser, TOKEN_EQUAL))
        {
            errorAtCurrent(parser, "Tried to modify value of constant.");
            return;
        }
        else
        {
            ijoString *key = CStringCopy(parser->previous.start, parser->previous.length);
            Entry *entry = TableFindInternalEntry(interned->entries, interned->capacity, key);

            if (entry)
            {
                emitConstant(parser, chunk, entry->value);
            }

            ijoStringDelete(key);
        }
    }
}

void identifier(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned)
{
    namedVariable(parser, compiler, chunk, interned);
}

void consume(Parser *parser, TokType type, const char *message)
{
    if (parser->current.type == type)
    {
        parserAdvance(parser);
        return;
    }

    errorAtCurrent(parser, message);
}

uint32_t makeConstant(Chunk *chunk, Value value)
{
    int constant = ChunkAddConstant(chunk, value);

    if (constant > UINT32_MAX)
    {
        LogError("Too many constants in one chunk.");
        return 0;
    }

    return constant;
}

void emitInstruction(Parser *parser, Chunk *chunk, uint32_t instruction)
{
    ChunkWriteCode(chunk, instruction, parser->previous.line);
}

void emitInstructions(Parser *parser, Chunk *chunk, uint32_t instruction1, uint32_t instruction2)
{
    ChunkWriteCode(chunk, instruction1, parser->previous.line);
    ChunkWriteCode(chunk, instruction2, parser->previous.line);
}

void emitConstant(Parser *parser, Chunk *chunk, Value value)
{
    emitInstructions(parser, chunk, OP_CONSTANT, makeConstant(chunk, value));
}

void emitReturn(Parser *parser, Chunk *chunk)
{
    ChunkWriteCode(chunk, OP_RETURN, parser->previous.line);
}

uint32_t emitJump(Parser *parser, Chunk *chunk, uint32_t instruction)
{
    uint32_t current = chunk->count;
    emitInstructions(parser, chunk, instruction, 0);

    return current;
}

void emitLoopStart(Parser *parser, Chunk *chunk, uint32_t position)
{
    uint32_t offset = chunk->count - position;
    emitInstructions(parser, chunk, OP_JUMP_BACK, offset);
}

void endCompiler(Parser *parser, Chunk *chunk)
{
    emitReturn(parser, chunk);
}

void number(Parser *parser, Compiler *compiler, Chunk *chunk, Table *strings)
{
    double value = strtod(parser->previous.start, NULL);
    emitConstant(parser, chunk, NUMBER_VAL(value));
}

void literal(Parser *parser, Compiler *compiler, Chunk *chunk, Table *strings)
{
    switch (parser->previous.type)
    {
    case TOKEN_FALSE:
        emitInstruction(parser, chunk, OP_FALSE);
        break;
    case TOKEN_TRUE:
        emitInstruction(parser, chunk, OP_TRUE);
        break;
    default:
        return; // Unreachable.
    }
}

void string(Parser *parser, Compiler *compiler, Chunk *chunk, Table *strings)
{
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

    if (interned != NULL)
    {
        ijoStringDelete(copiedStr);
        emitConstant(parser, chunk, INTERNAL_STR(interned));
    }
    else
    {
        Value internedStr = INTERNAL_STR(copiedStr);

        NaiveGCInsert(&gc, &internedStr);
        emitConstant(parser, chunk, internedStr);
        TableInsert(strings, copiedStr, internedStr);
    }
}

void parsePrecedence(Parser *parser, Compiler *compiler, Chunk *chunk, Table *interned, Precedence precedence)
{
    parserAdvance(parser);

    ParseRule *rule = getRule(parser->previous.type);

    if (!HAS_ENUM(parser->current.type, rule->acceptedTokens))
    {
        errorAt(parser, &parser->current, "Invalid token");
        return;
    }

    if (rule->prefix == NULL)
    {
        LogError("Expected expression");
        return;
    }

    parser->precedence = rule->precedence;
    rule->prefix(parser, compiler, chunk, interned);

    while (precedence <= getRule(parser->current.type)->precedence)
    {
        parserAdvance(parser);
        ParseFunc infixRule = getRule(parser->previous.type)->infix;

        infixRule(parser, compiler, chunk, interned);
    }
}

bool check(Parser *parser, TokType type)
{
    return parser->current.type == type;
}

bool match(Parser *parser, TokType type)
{
    if (!check(parser, type))
    {
        return false;
    }

    parserAdvance(parser);

    return true;
}

void errorAt(Parser *parser, Token *token, const char *message)
{
    if (parser->panicMode)
        return;

    parser->panicMode = true;

    LogError("line %d", token->line);

    if (token->type == TOKEN_EOF)
    {
        ConsoleWrite(" at end");
    }
    else if (token->type == TOKEN_ERROR)
    {
        // Nothing.
    }
    else
    {
        ConsoleWrite(" at '%.*s'", token->length, token->start);
    }

    ConsoleWrite(" %s\n", message);

    parser->hadError = true;
}

void errorAtCurrent(Parser *parser, const char *message)
{
    LogError("%s\n", message);
    errorAt(parser, &parser->previous, parser->current.start);
}

void synchronize(Parser *parser)
{
    parser->panicMode = false;

    while ((parser->current.type != TOKEN_EOF) || parser->current.type != TOKEN_EOL)
    {
        if (parser->previous.type == TOKEN_EOL)
            return;

        switch (parser->current.type)
        {
        case TOKEN_STRUCT:
        case TOKEN_FUNC:
        case TOKEN_CONST:
        case TOKEN_IF:
        case TOKEN_LOOP:
        case TOKEN_PRINT:
        case TOKEN_RETURN:
            return;

        default:; // Do nothing.
        }

        parserAdvance(parser);
    }
}

// Parser public functions implementations

void ParserInit(Parser *parser, Scanner *scanner)
{
    parser->panicMode = false;
    parser->hadError = false;
    parser->parsingLoop = false;
    parser->scanner = scanner;
}

void noop(Parser *parser, Compiler *compiler, Chunk *chunk, Table *strings) {}

/**
 * @brief Rules for parsing based on the TokType.
 *
 * @note
 * TokType | Prefix ParseFunc | Infix ParseFunc | Precedence
 */
ParseRule rules[] = {
    // Single-character tokens.
    [TOKEN_COMMA] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_DOT] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_LEFT_BRACE] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_LEFT_PAREN] = {grouping, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_MINUS] = {unary, binary, PREC_TERM, TOKEN_NUMBER},
    [TOKEN_PLUS] = {NULL, binary, PREC_TERM, TOKEN_NUMBER | TOKEN_STRING},
    [TOKEN_RIGHT_BRACE] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_RIGHT_PAREN] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_SEMICOLON] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_SLASH] = {NULL, binary, PREC_FACTOR, TOKEN_NUMBER},
    [TOKEN_STAR] = {NULL, binary, PREC_FACTOR, TOKEN_NUMBER},
    [TOKEN_PERCENT] = {NULL, NULL, PREC_NONE, TOKEN_ALL},

    // One or two character tokens.
    [TOKEN_BANG] = {unary, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_BANG_EQUAL] = {NULL, binary, PREC_EQUALITY, TOKEN_ALL},
    [TOKEN_EQUAL] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_EQUAL_EQUAL] = {NULL, binary, PREC_EQUALITY, TOKEN_ALL},
    [TOKEN_GREATER] = {NULL, binary, PREC_COMPARISON, TOKEN_ALL},
    [TOKEN_GREATER_EQUAL] = {NULL, binary, PREC_COMPARISON, TOKEN_ALL},
    [TOKEN_LESS] = {NULL, binary, PREC_COMPARISON, TOKEN_ALL},
    [TOKEN_LESS_EQUAL] = {NULL, binary, PREC_COMPARISON, TOKEN_ALL},

    // Literals.
    [TOKEN_IDENTIFIER] = {identifier, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_NUMBER] = {number, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_STRING] = {string, NULL, PREC_NONE, TOKEN_ALL},

    // KeySymbols. They act like keywords, but use symbols instead.
    [TOKEN_AND] = {NULL, and, PREC_AND, TOKEN_ALL},
    [TOKEN_ARRAY] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_ASSERT] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_STRUCT] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_ELSE] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_ENUM] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_FALSE] = {literal, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_FUNC] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_IF] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_MAP] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_MODULE] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_NIL] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_OR] = {NULL, or, PREC_OR, TOKEN_ALL},
    [TOKEN_PRINT] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_RETURN] = {returnExpr, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_STRUCT] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_SUPER] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_THIS] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_TRUE] = {literal, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_VAR] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_LOOP] = {NULL, NULL, PREC_NONE, TOKEN_ALL},

    [TOKEN_ERROR] = {NULL, NULL, PREC_NONE, TOKEN_ALL},
    [TOKEN_EOL] = {noop, noop, PREC_NONE, TOKEN_ALL},
    [TOKEN_EOF] = {noop, noop, PREC_NONE, TOKEN_ALL},
};

ParseRule *getRule(TokType type)
{
    return &rules[type];
}

void CompilerInit(Compiler *compiler)
{
    if (!compiler)
        return;

    compiler->localCount = 0;
    compiler->scopeDepth = 0;
}

void beginScope(Compiler *compiler)
{
    if (!compiler)
        return;

    compiler->scopeDepth++;
}

void endScope(Parser *parser, Compiler *compiler, Chunk *chunk)
{
    if (!compiler)
        return;
    compiler->scopeDepth--;

    while ((compiler->localCount > 0) &&
           (compiler->locals[compiler->localCount - 1].depth > compiler->scopeDepth))
    {
        // An optimization would be to have an OP_POPN which takes the number of pop operation to do
        emitInstruction(parser, chunk, OP_POP);
        compiler->localCount--;
    }
}