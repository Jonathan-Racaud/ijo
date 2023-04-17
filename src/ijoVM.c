#include "ijoVM.h"
#include "ijoMemory.h"
#include "common.h"
#include "log.h"

#if DEBUG
#include "debug.h"
#endif

ijoVM *ijoVMNew() {
    ijoVM* vm = (ijoVM*)malloc(sizeof(ijoVM));

    if (!vm) {
        LogCritical("Unable to allocate memory for the vm");
    }
}

void ijoVMDelete(ijoVM *vm) {
    Delete(vm);
}

InterpretResult ijoVMInterpret(ijoVM *vm, Chunk *chunk) {
    vm->chunk = chunk;
    vm->ip = vm->chunk->code;

    return ijoVMRun(vm);
}

InterpretResult ijoVMRun(ijoVM *vm) {
#define READ_BYTE() (*vm->ip++)
#define READ_CONST() (vm->chunk->constants.values[READ_BYTE()])

    for(;;) {
        #if DEBUG_TRACE_EXECUTION
        ConsoleWrite("          ");
        for (Value *slot = vm->stack; slot < vm->stackTop; slot++) {
            ConsoleWrite("[ ");
            ValuePrint(*slot);
            ConsoleWrite("]");
        }
        ConsoleWriteLine("");
        // DisassembleInstruction(vm->chunk, (uint32_t)(vm->ip - vm->chunk->code));
        #endif

        uint32_t instruction;

        switch (instruction = READ_BYTE())
        {
        case OP_CONSTANT: {
            Value constant = READ_CONST();
            ijoVMStackPush(vm, constant);
        }
        case OP_ADD: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            ijoVMStackPush(vm, ValueAdd(a, b));
            break;
        }
        case OP_SUB: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            ijoVMStackPush(vm, ValueSub(a, b));
            break;
        }
        case OP_MUL: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            ijoVMStackPush(vm, ValueMul(a, b));
            break;
        }
        case OP_DIV: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            ijoVMStackPush(vm, ValueDiv(a, b));
            break;
        }
        case OP_MOD: {
            Value b = ijoVMStackPop(vm);
            Value a = ijoVMStackPop(vm);
            ijoVMStackPush(vm, ValueMod(a, b));
            break;
        }
        case OP_NEG: {
            Value val = ijoVMStackPop(vm);
            ijoVMStackPush(vm, ValueNegate(val));
            break;
        }
        case OP_PRINT: {
            Value val = ijoVMStackPop(vm);
            ValuePrint(val);
            ConsoleWriteLine("");
        }
        case OP_RETURN: {
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
        return 0;
    }

    vm->stackTop--;
    return *vm->stackTop;
}