cmake_minimum_required(VERSION 4.0)
project(agengit CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Source files
set(SOURCES
    src/main.cpp
    src/permission.h
    src/rules.h
    src/rules.cpp
)

# Set configuration-specific output directory for all platforms
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})

add_executable(agengit ${SOURCES})

# Target-specific compile options for clean and safe code
if(MSVC)
    target_compile_options(agengit PRIVATE /W4 /WX)
else()
    target_compile_options(agengit PRIVATE -Wall -Wextra -Werror)
endif()
