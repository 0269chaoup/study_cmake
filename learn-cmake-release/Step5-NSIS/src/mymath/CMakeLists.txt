include(GenerateExportHeader)

add_library(mymath
    mymath.cpp
    mymath.h
)

generate_export_header(mymath
    EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/mymath_export.h
    EXPORT_MACRO_NAME MYMATH_API
)

target_include_directories(mymath
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(mymath PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

install(TARGETS mymath
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT Runtime
)

install(FILES
    mymath.h
    ${CMAKE_CURRENT_BINARY_DIR}/mymath_export.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT Development
)
