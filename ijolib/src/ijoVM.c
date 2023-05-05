#include "ijoVM.h"
#include "ijoCommon.h"
#include "ijoMemory.h"
#include "ijoLog.h"
#include "gc/ijoNaiveGC.h"
#include "ijoObj.h"
#include "ijoValue.h"

extern NaiveGCNode *gc;

#if DEBUG
#include "ijoDebug.h"
#endif

void ijoVMInit(ijoVM *vm) {
    if (!vm) return;

    ijoVMStackReset(vm);
    
    TableInit(&vm->interned);
}

void ijoVMDeinit(ijoVM *vm) {
    if (!vm) return;

    TableDelete(&vm->interned);
    ijoVMInit(vm);
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
    LogDebug(" == Stack evolution ==\n");
#endif

#if DEBUG_VM_CONSTANTS
    LogDebug(" == VM Constants and Interned Strings ==\n");

    for (uint32_t i = 0; i < vm->interned.capacity; i++) {
        Entry *entry = &vm->interned.entries[i];

        if (entry->key == NULL && entry->value.type == IJO_INTERNAL_EMPTY_ENTRY) continue;

        LogDebug("%s = ", entry->key->chars);
        ValuePrint(entry->value);
        ConsoleWriteLine("");
    }

    LogDebug(" == VM Constants and Interned Strings ==\n");
#endif

    OpCode lastOpCode;

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
            break;
        }
        case OP_PRINTLN: {
            Value val = ijoVMStackPop(vm);
            ValuePrint(val);
            ConsoleWriteLine("");
            break;
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
        case OP_POP: {
            ijoVMStackPop(vm);
            break;
        }
        case OP_GET_LOCAL: {
            uint32_t slot = READ_BYTE();
            ijoVMStackPush(vm, vm->stack[slot]);
            break;
        }
        case OP_SET_LOCAL: {
            uint32_t slot = READ_BYTE();
            Value value = ijoVMStackPeek(vm, 0);
            vm->stack[slot] = value;
            break;
        }
        case OP_RETURN: {
            if (mode == COMPILE_REPL && (lastOpCode != OP_PRINT))
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

        lastOpCode = instruction;
    }

#undef READ_CONST
#undef READ_BYTE
}

void ijoVMStackReset(ijoVM *vm) {
    if (!vm) return;

    vm->stackTop = vm->stack;
}

void ijoVMStackPush(ijoVM *vm, Value value) {
    if (!vm) return;

    if ((int)(vm->stackTop - vm->stack) >= STACK_MAX) {
        LogError("Stack full");
        return;
    }

    *vm->stackTop = value;
    vm->stackTop++;
}

Value ijoVMStackPop(ijoVM *vm) {
    if (!vm) return ERROR_VAL();

    if (vm->stackTop == vm->stack) {
        #if DEBUG_TRACE_EXECUTION
            LogError("Already at the start of the stack");
        #endif

        return ERROR_VAL();
    }

    vm->stackTop--;
    return *vm->stackTop;
}

Value ijoVMStackPeek(ijoVM *vm, int offset) {
     if (!vm) return ERROR_VAL();

     return vm->stackTop[-1 - offset];
}