set_package_properties(Sass PROPERTIES
  DESCRIPTION "SASS compiler"
  URL "https://sass-lang.com/"
  PURPOSE "Required for building GTK themes")

find_program(Sass_EXECUTABLE NAMES sassc)

if(Sass_EXECUTABLE)
    set(Sass_COMPILER_TYPE sassc)
else()
    find_program(Sass_EXECUTABLE NAMES sass)
    set(Sass_COMPILER_TYPE sass)
endif()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Sass
    FOUND_VAR
        Sass_FOUND
    REQUIRED_VARS
        Sass_EXECUTABLE
)
mark_as_advanced(Sass_EXECUTABLE)

if (Sass_FOUND)
    if (NOT TARGET Sass::Sass)
        add_executable(Sass::Sass IMPORTED)
        set_target_properties(Sass::Sass PROPERTIES
            IMPORTED_LOCATION "${Sass_EXECUTABLE}"
        )
    endif()
endif()
