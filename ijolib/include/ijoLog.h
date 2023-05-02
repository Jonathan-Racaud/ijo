#ifndef IJO_LOG_H
#define IJO_LOG_H

#include "ijoCommon.h"

#if defined(__cplusplus)
extern "C" {
#endif

/**
 * @brief Logs a @p message with @p prefix to the console.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param prefix The prefix to use for the log message.
 * @param message The message to log.
 * @param ... The va_args parameters.
 */
void Log(const char *prefix, const char *message, va_list args);

/**
 * @brief Logs an [INFO] @p message.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param message The message to log. 
 * @param ... The va_args parameters.
 */
void LogInfo(const char * message, ...);

/**
 * @brief Logs an [DEBUG] @p message.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param message The message to log. 
 * @param ... The va_args parameters.
 */
void LogDebug(const char * message, ...);

/**
 * @brief Logs an [WARNING] @p message.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param message The message to log. 
 * @param ... The va_args parameters.
 */
void LogWarning(const char * message, ...);

/**
 * @brief Logs an [ERROR] @p message.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param message The message to log. 
 * @param ... The va_args parameters.
 */
void LogError(const char * message, ...);

/**
 * @brief Logs an [CRITICAL] @p message.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param message The message to log. 
 * @param ... The va_args parameters.
 */
void LogCritical(const char * message, ...);

/**
 * @brief Writes a @p message to the console.
 * @param prefix The prefix to use for the log message.
 * @param message The message to log.
 * @param ... The va_args parameters.
 */
void ConsoleWrite(const char * message, ...);

/**
 * @brief Writes a @p message to the console.
 * 
 * Appends a new line at the end of the message.
 * 
 * @param prefix The prefix to use for the log message.
 * @param message The message to log.
 * @param ... The va_args parameters.
 */
void ConsoleWriteLine(const char * message, ...);

#if defined(__cplusplus)
}
#endif

#endif // IJO_LOG_H