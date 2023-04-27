#include "ijoVM.h"
#include "ijoCommon.h"
#include "ijoMemory.h"
#include "ijoLog.h"
#include "gc/ijoNaiveGC.h"
#include "ijoObj.h"

extern NaiveGCNode *gc;

#if DEBUG
#include "ijoDebug.h"
#endif

void ijoVMNew(ijoVM *vm) {
    ijoVMStackReset(vm);
    
    TableInit(&vm->interned);
}

void ijoVMDelete(ijoVM *vm) {
    TableDelete(&vm->interned);
}

InterpretResult ijoVMInterpret(ijoVM *vm, Chunk *chunk, CompileMode mode) {
    vm->chunk = chunk;
    vm->ip = vm->chunk->code;

    return ijoVMRun(vm, mode);
}

InterpretResult ijoVMRun(ijoVM *vm, CompileMode mode) {
#define READ_BYTE() (*vm->ip++)
#define READ_CONST() (vm->chunk->constants.values[READ_BYTE()])

#if DEBUG_TRACE_EXECUTION
    LogDebug(" == Stack evolution ==");
#endif

    for(;;) {
        #if DEBUG_TRACE_EXECUTION
        ConsoleWrite("          ");
        for (Value *slot = vm->stack; slot < vm->stackTop; slot++) {
            ConsoleWrite("[ ");
            ValuePrint(*slot);
            ConsoleWrite(" ]");
        }
        ConsoleWriteLine("");
        DisassembleInstruction(vm->chunk, (uint32_t)(vm->ip - vm->chunk->code));
        #endif

        uint32_t instruction;

        switch (instruction = READ_BYTE())
        {
        case OP_CONSTANT: {
            Value constant = READ_CONST();
            ijoVMStackPush(vm, constant);
            break;
        }
        case OP_ADD: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_PLUS]).infix(a, b);

            if (result.type == VAL_OBJ) {
                if (IS_STRING(result)) {
                    TableInsert(&vm->interned, AS_STRING(result), IJO_INTERNAL(IJO_INTERNAL_STRING));
                }
                NaiveGCInsert(&gc, &result);
            }
            
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_SUB: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_MINUS]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_MUL: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_STAR]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_DIV: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_SLASH]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_MOD: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_PERCENT]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_NEG: {
            Value val = ijoVMStackPop(vm);
            Value result = (val.operators[OPERATOR_MINUS]).prefix(val);
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_PRINT: {
            Value val = ijoVMStackPop(vm);
            ValuePrint(val);
            ConsoleWriteLine("");
        }
        case OP_TRUE: {
            ijoVMStackPush(vm, BOOL_VAL(true));
            break;
        }
        case OP_FALSE: {
            ijoVMStackPush(vm, BOOL_VAL(false));
            break;
        }
        // !@true
        case OP_NOT: {
            Value val = ijoVMStackPop(vm);
            Value result = (val.operators[OPERATOR_BANG]).prefix(val);
            ijoVMStackPush(vm, result);
            break;
        }
        // ==
        case OP_EQ: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_EQUAL_EQUAL]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        // !=
        case OP_NEQ: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_BANG_EQUAL]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        // <
        case OP_LT: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_CHEVRON_LEFT]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        // <=
        case OP_LE: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_CHEVRON_EQUAL_LEFT]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        // >
        case OP_GT: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_CHEVRON_RIGHT]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        // >=
        case OP_GE: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            Value result = (a.operators[OPERATOR_CHEVRON_EQUAL_RIGHT]).infix(a, b);
            ijoVMStackPush(vm, result);
            break;
        }
        case OP_RETURN: {
            if (mode == COMPILE_REPL)
            {
                #if DEBUG_TRACE_EXECUTION
                    LogDebug(" == Stack evolution ==");
                #endif

                ValuePrint(ijoVMStackPop(vm));
                ConsoleWriteLine("");
            }
            return INTERPRET_OK;
        }
        
        default:
            return INTERPRET_RUNTIME_ERROR;
        }
    }

#undef READ_CONST
#undef READ_BYTE
}

void ijoVMStackReset(ijoVM *vm) {
    vm->stackTop = vm->stack;
}

void ijoVMStackPush(ijoVM *vm, Value value) {
    if ((int)(vm->stackTop - vm->stack) >= STACK_MAX) {
        LogError("Stack full");
        return;
    }

    *vm->stackTop = value;
    vm->stackTop++;
}

Value ijoVMStackPop(ijoVM *vm) {
    if (vm->stackTop == vm->stack) {
        LogError("Already at the start of the stack");
        return ERROR_VAL();
    }

    vm->stackTop--;
    return *vm->stackTop;
}