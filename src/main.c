#include "common.h"
#include "chunk.h"
#include "log.h"
#include "ijoVM.h"
#include "compiler.h"

#if DEBUG
#include "debug.h"
#define LOG_LEVEL LOG_LEVEL_DEBUG
#endif

InterpretResult Interpret(ijoVM *vm, char *source) {
  Chunk chunk = Compile(source);

  return INTERPRET_OK;
}

void StartRepl(ijoVM *vm) {
  char line[1024];

  for(;;) {
    ConsoleWrite("> ");

    if (!fgets(line, sizeof(line), stdin)) {
      ConsoleWriteLine("");
      break;
    }

    Interpret(vm, line);
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
    ijoVMDelete(vm);
    exit(74);
  }

  InterpretResult result = Interpret(vm, source);
  free(source);

  if (result == INTERPRET_COMPILE_ERROR) exit(65);
  if (result == INTERPRET_RUNTIME_ERROR) exit(70);
}

int main(int argc, char **argv) {
  LogInfo("Creating a new ijoVM...");
  ijoVM *vm = ijoVMNew();

  if (argc == 1) {
    StartRepl(vm);
  } else if (argc == 2) {
    RunFile(vm, argv[1]);
  } else {
    ConsoleWriteLine("Usage: ijoVM [path]");
    ijoVMDelete(vm);
    exit(64);
  }

  LogInfo("Stopping the ijoVM");
  ijoVMDelete(vm);

  return 0;
}
