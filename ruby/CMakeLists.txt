macro_optional_find_package(RUBY)

#####################################################################
# Wt::Ruby

OPTION(ENABLE_WTRUBY "build Wt::Ruby" ON)

SET(CUSTOM_RUBY_SITE_ARCH_DIR ${RUBY_SITE_ARCH_DIR} CACHE DIR "custom installation directory for ruby binary extension" )
SET(CUSTOM_RUBY_SITE_LIB_DIR ${RUBY_SITE_LIB_DIR} CACHE DIR "custom installation directory for ruby extension" )

set(WTRUBY_ENABLED "no")
if(RUBY_EXECUTABLE)
    if(ENABLE_WTRUBY)
        add_subdirectory( wtruby )
        add_subdirectory( wtext )
        set(WTRUBY_ENABLED "yes")
    endif(ENABLE_WTRUBY)
endif(RUBY_EXECUTABLE)
message(STATUS "Build Wt::Ruby... " ${WTRUBY_ENABLED})

