add_subdirectory( lib )

IF(NOT Boost_FOUND)
    FIND_PACKAGE( Boost REQUIRED COMPONENTS date_time regex program_options signals )
ENDIF(NOT Boost_FOUND)

IF(NOT Wt_FOUND)
    FIND_PACKAGE(Wt REQUIRED)
ENDIF(NOT Wt_FOUND)

include_directories(    ${CMAKE_SOURCE_DIR}/smoke 
                        ${RUBY_INCLUDE_PATH}
                        ${Boost_INCLUDE_DIR}
                        ${Wt_INCLUDE_DIR} 
                        ${Wt_INCLUDE_DIR}/Wt )

set ( CMAKE_CXX_FLAGS -fvisibility=hidden )

set(    wtrubyshared_LIB_SRCS 
        Wt.cpp 
        handlers.cpp 
        marshall_types.cpp )

set(    wt_LIB_SRCS 
        wtruby.cpp
        slot_invocation.cpp )

set ( CMAKE_CXX_FLAGS -fexceptions )

add_library(wtrubyshared SHARED ${wtrubyshared_LIB_SRCS})
add_library(wtrubyhttp MODULE ${wt_LIB_SRCS})
add_library(wtrubyfcgi MODULE ${wt_LIB_SRCS})

target_link_libraries(  wtrubyshared 
                        ${RUBY_LIBRARY} 
                        ${Boost_LIBRARIES} 
                        ${Wt_LIBRARY} 
#                        ${Wt_HTTP_LIBRARY} 
                        smokewt )

target_link_libraries(  wtrubyhttp 
                        ${RUBY_LIBRARY} 
                        ${Boost_LIBRARIES} 
                        ${Wt_LIBRARY} 
                        ${Wt_HTTP_LIBRARY} 
                        wtrubyshared 
                        smokewt )

target_link_libraries(  wtrubyfcgi
                        ${RUBY_LIBRARY} 
                        ${Boost_LIBRARIES} 
                        ${Wt_LIBRARY} 
                        wtfcgi 
                        wtrubyshared 
                        smokewt )

set_target_properties(wtrubyhttp PROPERTIES PREFIX "" OUTPUT_NAME wthttp)
set_target_properties(wtrubyfcgi PROPERTIES PREFIX "" OUTPUT_NAME wtfcgi)
set_target_properties(wtrubyshared PROPERTIES VERSION 1.0.0 SOVERSION 1)

install(TARGETS wtrubyshared LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX} )
install(TARGETS wtrubyhttp DESTINATION ${CUSTOM_RUBY_SITE_ARCH_DIR})
install(TARGETS wtrubyfcgi DESTINATION ${CUSTOM_RUBY_SITE_ARCH_DIR})

# kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;


