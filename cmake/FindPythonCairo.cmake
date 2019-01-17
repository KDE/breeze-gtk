if(CMAKE_VERSION VERSION_LESS 3.12.0)
    find_package(PythonInterp 3 REQUIRED)
    # PythonInterp sets PYTHON_EXECUTABLE
else()
    find_package(Python3 COMPONENTS Interpreter REQUIRED)
    set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
endif()

# Check for python cairo
execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import cairo"
                RESULT_VARIABLE PYTHON_CAIRO_RESULT)
if (PYTHON_CAIRO_RESULT EQUAL 0)
    set(PYTHONCAIRO_FOUND 1)
endif()
