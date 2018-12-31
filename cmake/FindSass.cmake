#.rst:
# FindSass
# -----------
#
# Try to find Sass compiler.
#
# If the Sass compiler executable is not in your PATH, you can provide
# an alternative name or full path location with the ``Sass_EXECUTABLE`` variable.
# In this case, do not forget to set ``Sass_COMPILER_TYPE`` variable also.
#
# This will define the following variables:
#
# ``Sass_FOUND``
#     True if sass is available.
#
# ``Sass_EXECUTABLE``
#     The Sass compiler executable.
#
# ``Sass_COMPILER_TYPE``
#     Sass compiler type: ``sass`` or ``sassc``.
#
# If ``Sass_FOUND`` is TRUE, it will also define the following imported
# target:
#
# ``Sass::Sass``
#     The Sass compiler executable.
#

#=============================================================================
# Copyright 2018 Alexander Kernozhitsky <sh200105@mail.ru>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

set_package_properties(Sass PROPERTIES
  DESCRIPTION "SASS compiler"
  URL "https://sass-lang.com/"
  PURPOSE "Required for building GTK themes")

find_program(Sass_EXECUTABLE NAMES sassc)

if(Sass_EXECUTABLE)
    if(NOT Sass_COMPILER_TYPE)
      set(Sass_COMPILER_TYPE sassc)
    endif()
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
