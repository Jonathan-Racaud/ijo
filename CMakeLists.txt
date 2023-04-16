cmake_minimum_required(VERSION 3.26)
project(ijoVM)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  message("Building in DEBUG mode")
  add_definitions(
    -DDEBUG
    -DDEBUG_TRACE_EXECUTION
  )
endif()

# Sources
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(SOURCES
  ${SOURCE_DIR}/main.c
  ${SOURCE_DIR}/ijoMemory.c
  ${SOURCE_DIR}/chunk.c
  ${SOURCE_DIR}/debug.c
  ${SOURCE_DIR}/value.c
  ${SOURCE_DIR}/log.c
  ${SOURCE_DIR}/ijoVM.c
)

# Includes
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(INCLUDES
  ${INCLUDE_DIR}/common.h
  ${INCLUDE_DIR}/ijoMemory.h
  ${INCLUDE_DIR}/chunk.h
  ${INCLUDE_DIR}/debug.h
  ${INCLUDE_DIR}/value.h
  ${INCLUDE_DIR}/log.h
  ${INCLUDE_DIR}/ijoVM.h
)
include_directories(${INCLUDE_DIR})

add_executable(${PROJECT_NAME} ${SOURCES})

install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX})

