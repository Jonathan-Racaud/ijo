cmake_minimum_required(VERSION 3.26)
project(ijoVM)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  message("Building in DEBUG mode")
  add_definitions(
    -DDEBUG
  )
endif()

# Sources
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(SOURCES
  ${SOURCE_DIR}/main.c
  ${SOURCE_DIR}/ijoMemory.c
  ${SOURCE_DIR}/ijoChunk.c
  ${SOURCE_DIR}/ijoDebug.c
  ${SOURCE_DIR}/ijoValue.c
  ${SOURCE_DIR}/ijoLog.c
  ${SOURCE_DIR}/ijoVM.c
  ${SOURCE_DIR}/ijoCompiler.c
  ${SOURCE_DIR}/ijoScanner.c
  ${SOURCE_DIR}/ijoObj.c
  ${SOURCE_DIR}/gc/ijoNaiveGC.c
  ${SOURCE_DIR}/ijoTable.c
)

# Includes
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(INCLUDES
  ${INCLUDE_DIR}/ijoCommon.h
  ${INCLUDE_DIR}/ijoMemory.h
  ${INCLUDE_DIR}/ijoChunk.h
  ${INCLUDE_DIR}/ijoDebug.h
  ${INCLUDE_DIR}/ijoValue.h
  ${INCLUDE_DIR}/ijoLog.h
  ${INCLUDE_DIR}/ijoVM.h
  ${INCLUDE_DIR}/ijoCompiler.h
  ${INCLUDE_DIR}/ijoScanner.h
  ${INCLUDE_DIR}/ijoToken.h
  ${INCLUDE_DIR}/ijoObj.h
  ${INCLUDE_DIR}/gc/ijoNaiveGC.h
  ${INCLUDE_DIR}/ijoTable.h
)
include_directories(${INCLUDE_DIR})

add_executable(${PROJECT_NAME} ${SOURCES})

install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX})

