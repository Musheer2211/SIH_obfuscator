cmake_minimum_required(VERSION 3.13)

# Ensure both C and C++ are enabled (LLVM helper expects C too)
project(SimpleObfPass LANGUAGES C CXX)

# Prefer Position Independent Code for plugins
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Allow using the installed LLVM via -DCMAKE_PREFIX_PATH or /c/LLVM
find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "LLVM_DIR = ${LLVM_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(HandleLLVMOptions)
include(AddLLVM)              # for llvm_map_components_to_libnames

# C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Try compile target type: static library to avoid weird link checks on MinGW
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Plugin target
add_library(SimpleObfPass MODULE obfuscator.cpp)

# Keep plugin small, and match common LLVM plugin flags
target_compile_options(SimpleObfPass PRIVATE -fno-rtti)

# Include LLVM headers
target_include_directories(SimpleObfPass PRIVATE ${LLVM_INCLUDE_DIRS})

# ----------------- sanitize and apply LLVM_DEFINITIONS safely ----------------
# Some definitions from LLVM_DEFINITIONS are like -DLLVM_VERSION_STRING=12.0.0
# which need quoting for GCC/MinGW. We transform them into -DNAME="value".
set(SANITIZED_LLVM_DEFINITIONS "")
foreach(def ${LLVM_DEFINITIONS})
  if(def MATCHES "^-D([^=]+)=(.*)$")
    string(REGEX REPLACE "^-D([^=]+)=(.*)$" "\\1" _varname ${def})
    string(REGEX REPLACE "^-D([^=]+)=(.*)$" "\\2" _varval ${def})
    if(_varval MATCHES "^[0-9]+$")
      list(APPEND SANITIZED_LLVM_DEFINITIONS "-D${_varname}=${_varval}")
    else()
      string(REGEX REPLACE "\"" "\\\\\"" _varval_escaped "${_varval}")
      list(APPEND SANITIZED_LLVM_DEFINITIONS "-D${_varname}=\"${_varval_escaped}\"")
    endif()
  else()
    list(APPEND SANITIZED_LLVM_DEFINITIONS "${def}")
  endif()
endforeach()

target_compile_definitions(SimpleObfPass PRIVATE ${SANITIZED_LLVM_DEFINITIONS})
# ---------------------------------------------------------------------------

# Link only the LLVM components you need (include Passes for PassBuilder)
set(LLVM_COMPONENTS
  Core
  Support
  IRReader
  Passes
  TransformUtils
  # add other components if your pass needs them
)

llvm_map_components_to_libnames(LLVM_LIBS ${LLVM_COMPONENTS})
target_link_libraries(SimpleObfPass PRIVATE ${LLVM_LIBS})

# Optional: installation into the LLVM lib folder if you used an install prefix
install(TARGETS SimpleObfPass
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib)
