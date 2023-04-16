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
        DisassembleInstruction(vm->chunk, (uint32_t)(vm->ip - vm->chunk->code));
        #endif

        uint32_t instruction;

        switch (instruction = READ_BYTE())
        {
        case OP_CONSTANT: {
            Value constant = READ_CONST();
        }
        case OP_RETURN: {
            return INTERPRET_OK;
        }
        
        default:
            return INTERPRET_RUNTIME_ERROR:
        }
    }

#undef READ_CONST
#undef READ_BYTE
}