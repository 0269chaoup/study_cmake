cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Tutorial 
    VERSION 1.0
    DESCRIPTION "Tutorial step2"
    LANGUAGES CXX
    HOMEPAGE_URL "http://"
)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# TODO 7: Create a variable USE_MYMATH using option and set default to ON
set(USE_MYMATH False CACHE BOOL "Use tutorial provided math implementation")
# configure a header file to pass some of the CMake settings
# to the source code
configure_file(TutorialConfig.h.in TutorialConfig.h)

# TODO 8: Use list() and APPEND to create a list of optional libraries
# called  EXTRA_LIBS and a list of optional include directories called
# EXTRA_INCLUDES. Add the MathFunctions library and source directory to
# the appropriate lists.
#
# Only call add_subdirectory and only add MathFunctions specific values
# to EXTRA_LIBS and EXTRA_INCLUDES if USE_MYMATH is true.

# 将缓存变量USE_MYMATH的值设置为True，强制设置为True
set(USE_MYMATH True CACHE BOOL "Use tutorial provided math implementation" FORCE)
if(USE_MYMATH)
    add_subdirectory(MathFunctions)
    list(APPEND EXTRA_LIBS MathFunctions)
    list(APPEND EXTRA_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/MathFunctions)
endif()
# TODO 2: Use add_subdirectory() to add MathFunctions to this project
# add_subdirectory(MathFucions)
# add the executable
add_executable(Tutorial tutorial.cxx)

# TODO 9: Use EXTRA_LIBS instead of the MathFunctions specific values
# in target_link_libraries.

foreach(item ${EXTRA_LIBS})
    target_link_libraries(Tutorial PUBLIC ${item})
endforeach()
# TODO 3: Use target_link_libraries to link the library to our executable
target_link_libraries(Tutorial PRIVATE MathFunctions)
# TODO 4: Add MathFunctions to Tutorial's target_include_directories()
# Hint: ${PROJECT_SOURCE_DIR} is a path to the project source. AKA This folder!
target_include_directories(Tutorial PUBLIC
                            "${PROJECT_SOURCE_DIR}/MathFunctions"
                            )
# TODO 10: Use EXTRA_INCLUDES instead of the MathFunctions specific values
# in target_include_directories.
foreach(item ${EXTRA_INCLUDES})
    target_include_directories(Tutorial PUBLIC ${item})
    MESSAGE(STATUS "item= ${item}")
endforeach()

MESSAGE(STATUS "CMAKE_CURRENT_SOURCE_DIR = ${CMAKE_CURRENT_SOURCE_DIR}")
# add the binary tree to the search path for include files
# so that we will find TutorialConfig.h
target_include_directories(Tutorial PUBLIC
                           "${PROJECT_BINARY_DIR}"
                           )
