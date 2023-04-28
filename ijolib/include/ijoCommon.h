#ifndef IJO_COMMON_H
#define IJO_COMMON_H

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <string.h>

#define HAS_ENUM(val, test) ((val & test) != 0)

#define LOG_LEVEL_ALL      1
#define LOG_LEVEL_INFO     0
#define LOG_LEVEL_DEBUG    0
#define LOG_LEVEL_WARNING  0
#define LOG_LEVEL_ERROR    1
#define LOG_LEVEL_CRITICAL 1

#define DEBUG_PRINT_CODE      0
#define DEBUG_TRACE_EXECUTION 0

#endif // IJO_COMMON_H