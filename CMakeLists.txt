cmake_minimum_required(VERSION 3.20)
project(agengit CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Source files
set(SOURCES
    src/main.cpp
    src/OS.h
    src/OS.cpp
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
    target_compile_options(agengit PRIVATE /W4)
else()
    target_compile_options(agengit PRIVATE -Wall -Wextra -Wno-missing-field-initializers)
endif()

if(WIN32 AND NOT MSVC)
    target_link_options(agengit PRIVATE -static -static-libgcc -static-libstdc++)
endif()

# Installation target
if(WIN32 AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    if(DEFINED ENV{LOCALAPPDATA})
        set(CMAKE_INSTALL_PREFIX "$ENV{LOCALAPPDATA}/agengit" CACHE PATH "Default install prefix" FORCE)
    elseif(DEFINED ENV{USERPROFILE})
        set(CMAKE_INSTALL_PREFIX "$ENV{USERPROFILE}/AppData/Local/agengit" CACHE PATH "Default install prefix" FORCE)
    elseif(DEFINED ENV{WINEPREFIX})
        set(CMAKE_INSTALL_PREFIX "$ENV{WINEPREFIX}/drive_c/users/root/AppData/Local/agengit" CACHE PATH "Default install prefix" FORCE)
    else()
        set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/.wine/drive_c/users/root/AppData/Local/agengit" CACHE PATH "Default install prefix" FORCE)
    endif()
endif()


include(GNUInstallDirs)
install(TARGETS agengit
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)


