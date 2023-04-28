#include "ijoLog.h"

void Log(const char *prefix, const char *message, va_list args) {
    printf(prefix);
    vprintf(message, args);
}

void LogInfo(const char *message, ...) {
#if LOG_LEVEL_INFO || LOG_LEVEL_ALL
    va_list args;
    va_start(args, message);
    Log("[INFO]: ", message, args);
    va_end(args);
#endif
}

void LogDebug(const char *message, ...) {
#if LOG_LEVEL_DEBUG || LOG_LEVEL_ALL
    va_list args;
    va_start(args, message);
    Log("[DEBUG]: ", message, args);
    va_end(args);
#endif
}

void LogWarning(const char *message, ...) {
#if LOG_LEVEL_WARNING || LOG_LEVEL_ALL
    va_list args;
    va_start(args, message);
    Log("[WARNING]: ", message, args);
    va_end(args);
#endif
}

void LogError(const char *message, ...) {
#if LOG_LEVEL_ERROR || LOG_LEVEL_ALL
    va_list args;
    va_start(args, message);
    Log("[ERROR]: ", message, args);
    va_end(args);
#endif
}

void LogCritical(const char *message, ...) {
#if LOG_LEVEL_CRITICAL || LOG_LEVEL_ALL
    va_list args;
    va_start(args, message);
    Log("[CRITICAL]: ", message, args);
    va_end(args);
#endif
}

void ConsoleWrite(const char *message, ...) {
    va_list args;
    
    va_start(args, message);
    vprintf(message, args);
    va_end(args);
}

void ConsoleWriteLine(const char *message, ...) {
    va_list args;
    
    va_start(args, message);
    vprintf(message, args);
    va_end(args);
    printf("\n");
}