IF(NOT Boost_FOUND)
    FIND_PACKAGE( Boost REQUIRED COMPONENTS date_time regex program_options signals )
ENDIF(NOT Boost_FOUND)

IF(NOT Wt_FOUND)
    FIND_PACKAGE(Wt REQUIRED)
ENDIF(NOT Wt_FOUND)

include_directories(    ${CMAKE_SOURCE_DIR}/smoke
                        ${CMAKE_SOURCE_DIR}/ruby/wtruby/src
                        ${RUBY_INCLUDE_PATH}
                        ${Boost_INCLUDE_DIR}
                        ${Wt_INCLUDE_DIR} 
                        ${Wt_INCLUDE_DIR}/Wt
                        ${Wt_INCLUDE_DIR}/Wt/Ext )

set (CMAKE_CXX_FLAGS -fvisibility=hidden)

set(    wtext_LIB_SRCS 
        wtexthandlers.cpp 
        wtext.cpp )

set (CMAKE_CXX_FLAGS -fexceptions)

add_library(wtext MODULE ${wtext_LIB_SRCS})

target_link_libraries(  wtext 
                        ${RUBY_LIBRARY} 
                        ${Boost_LIBRARIES} 
                        ${Wt_LIBRARY} 
                        ${Wt_HTTP_LIBRARY} 
                        ${Wt_EXT_LIBRARY} 
                        wtrubyshared 
                        smokewt 
                        smokewtext )

set_target_properties(wtext PROPERTIES PREFIX "")

install(TARGETS wtext DESTINATION ${CUSTOM_RUBY_SITE_ARCH_DIR})
install(FILES wtext.rb DESTINATION ${CUSTOM_RUBY_SITE_LIB_DIR}/wt)

# kate: space-indent on; indent-width 4; replace-tabs on; mixed-indent off;
