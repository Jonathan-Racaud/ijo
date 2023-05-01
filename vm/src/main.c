#include "ijoCommon.h"
#include "ijoChunk.h"
#include "ijoLog.h"
#include "ijoVM.h"
#include "ijoCompiler.h"
#include "gc/ijoNaiveGC.h"

InterpretResult Interpret(ijoVM *vm, char *source, CompileMode mode) {
  Chunk chunk;
  ChunkNew(&chunk);

  if (!Compile(source, &chunk, &vm->interned, mode)) {
    ChunkDelete(&chunk);
    return INTERPRET_COMPILE_ERROR;
  }

  vm->chunk = &chunk;
  vm->ip = vm->chunk->code;

  InterpretResult result = ijoVMRun(vm, mode);
  ChunkDelete(&chunk);

  return result;
}

void StartRepl(ijoVM *vm) {
  char line[1024];

  for(;;) {
    ConsoleWrite("> ");

    if (!fgets(line, sizeof(line), stdin)) {
      ConsoleWriteLine("");
      break;
    }

    if (0 == strcmp(line, "exit\n")) {
      break;
    }

    Interpret(vm, line, COMPILE_REPL);
  }

}

char *ReadFile(const char *path) {
  FILE *file = fopen(path, "rb");

  if (file == NULL) {
    LogError("Could not open file \"%s\".", path);
    return NULL;
  }

  fseek(file, 0L, SEEK_END);
  size_t fileSize = ftell(file);
  rewind(file);

  char *buffer = (char*)malloc(fileSize + 1);

  if (buffer == NULL) {
    LogError("Could not allocate memory for reading file \"%s\".", path);
    return NULL;
  }

  size_t bytesRead = fread(buffer, sizeof(char), fileSize, file);

  if (bytesRead < fileSize) {
    LogError("Could not read file \"%s\".", path);
    return NULL;
  }

  buffer[bytesRead] = '\0';

  fclose(file);

  return buffer;
}

void RunFile(ijoVM *vm, char *path) {
  char *source = ReadFile(path);

  if (source == NULL) {
    ijoVMDeinit(vm);
    exit(74);
  }

  InterpretResult result = Interpret(vm, source, COMPILE_FILE);
  free(source);

  if (result == INTERPRET_COMPILE_ERROR) exit(65);
  if (result == INTERPRET_RUNTIME_ERROR) exit(70);
}

int main(int argc, char **argv) {
  LogInfo("Creating a new ijoVM...\n");
  ijoVM vm;
  ijoVMInit(&vm);

  gc = NaiveGCNodeCreate(NULL);

  if (argc == 1) {
    StartRepl(&vm);
  } else if (argc == 2) {
    RunFile(&vm, argv[1]);
  } else {
    ConsoleWriteLine("Usage: ijoVM [path]");
    ijoVMDeinit(&vm);
    exit(64);
  }

  NaiveGCClear(gc);
  ijoVMDeinit(&vm);

  LogInfo("Stopping the ijoVM\n");

  return 0;
}
