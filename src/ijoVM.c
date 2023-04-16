#include "ijoVM.h"
#include "ijoMemory.h"
#include "common.h"
#include "log.h"

ijoVM *ijoVMNew() {
    ijoVM* vm = (ijoVM*)malloc(sizeof(ijoVM));

    if (!vm) {
        LogCritical("Unable to allocate memory for the vm");
    }
}

void ijoVMDelete(ijoVM *vm) {
    Delete(vm);
}