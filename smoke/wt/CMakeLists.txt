IF(NOT Boost_FOUND)
    FIND_PACKAGE( Boost REQUIRED COMPONENTS date_time regex program_options signals )
ENDIF(NOT Boost_FOUND)

IF(NOT Wt_FOUND)
    FIND_PACKAGE(Wt REQUIRED)
ENDIF(NOT Wt_FOUND)

include_directories( ${Wt_INCLUDE_DIR} 
                     ${Wt_INCLUDE_DIR}/Wt 
                     ${Wt_INCLUDE_DIR}/Wt/Chart
                     ${Boost_INCLUDE_DIR}
                     ${Boost_INCLUDE_DIR}/boost
                     ${Boost_INCLUDE_DIR}/boost/signals
                     ${CMAKE_SOURCE_DIR}/smoke )


IF(NOT PERL_FOUND)
    FIND_PACKAGE(PERL REQUIRED)
ENDIF(NOT PERL_FOUND)

########### next target ###############

add_custom_command( OUTPUT 
                    ${CMAKE_CURRENT_BINARY_DIR}/smokedata.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_1.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_2.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_3.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_4.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_5.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_6.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_7.cpp 
                    ${CMAKE_CURRENT_BINARY_DIR}/x_8.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_9.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_10.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_11.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_12.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_13.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_14.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_15.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_16.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_17.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_18.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_19.cpp
                    ${CMAKE_CURRENT_BINARY_DIR}/x_20.cpp

                    COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_CURRENT_BINARY_DIR}/generate.pl
                    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/generate.pl
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )

# macro_add_file_dependencies(${CMAKE_CURRENT_BINARY_DIR}/smokedata.cpp ${CMAKE_CURRENT_BINARY_DIR}/x_1.cpp)

include_directories(${CMAKE_SOURCE_DIR}/smoke ${CMAKE_SOURCE_DIR}/smoke/qt )

set(    smokewt_LIB_SRCS 
        ${CMAKE_CURRENT_BINARY_DIR}/smokedata.cpp  
        ${CMAKE_CURRENT_BINARY_DIR}/x_1.cpp 
        ${CMAKE_CURRENT_BINARY_DIR}/x_2.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_3.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_4.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_5.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_6.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_7.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_8.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_9.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_10.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_11.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_12.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_13.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_14.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_15.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_16.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_17.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_18.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_19.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_20.cpp )

set (CMAKE_CXX_FLAGS -fexceptions)
set (CMAKE_CXX_FLAGS -fvisibility=hidden)

IF(CMAKE_CXX_FLAGS MATCHES "-fvisibility")
    ADD_DEFINITIONS(-DGCC_VISIBILITY)
ENDIF(CMAKE_CXX_FLAGS MATCHES "-fvisibility")

add_library(smokewt SHARED ${smokewt_LIB_SRCS})

target_link_libraries(  smokewt 
                        ${Boost_LIBRARIES} 
                        ${Wt_LIBRARY}
                        ${Wt_HTTP_LIBRARY} )

set_target_properties(smokewt PROPERTIES VERSION 1.0.0 SOVERSION 1)

install(TARGETS smokewt DESTINATION ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX})

configure_file(generate.pl.cmake ${CMAKE_CURRENT_BINARY_DIR}/generate.pl @ONLY)

# kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
