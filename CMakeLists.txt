project(kdebindings)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules )

include (MacroOptionalFindPackage)

FIND_PACKAGE(Perl REQUIRED)
FIND_PACKAGE (Wt REQUIRED)

include_directories (${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${WT_INCLUDES} )

FIND_PACKAGE (RUBY REQUIRED)
FIND_PACKAGE (OpenGL REQUIRED)

add_subdirectory(smoke)

if(RUBY_EXECUTABLE)
   add_subdirectory( ruby )
endif(RUBY_EXECUTABLE)

