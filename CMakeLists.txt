cmake_minimum_required(VERSION 3.13)
project(SimpleObfPass LANGUAGES CXX)

# Use the same LLVM version as opt/clang
find_package(LLVM CONFIG REQUIRED)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

# Set include paths
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

# Ensure we use C++17 (LLVM ≥ 14 requires at least this)
set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard")
set(CMAKE_CXX_STANDARD_REQUIRED YES)

# === Build the plugin ===
add_library(SimpleObfPass MODULE obfuscator_with_bogus_report.cpp)

# DO NOT link against LLVM libraries!
# target_link_libraries(SimpleObfPass LLVM::Core LLVM::IRReader ...)  <-- ❌ NO

# Make sure the plugin has no 'lib' prefix
set_target_properties(SimpleObfPass PROPERTIES
    PREFIX ""
    SUFFIX ".so"
)

# Ensure position-independent code (for shared plugin)
set_target_properties(SimpleObfPass PROPERTIES POSITION_INDEPENDENT_CODE ON)

# This ensures the same visibility rules as LLVM
if (MSVC)
    target_compile_definitions(SimpleObfPass PRIVATE -D_CRT_SECURE_NO_WARNINGS)
else()
    target_compile_options(SimpleObfPass PRIVATE -fno-rtti -fPIC)
endif()
