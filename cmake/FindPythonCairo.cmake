find_package(Python3 COMPONENTS Interpreter REQUIRED)

# Check for python cairo
execute_process(COMMAND ${Python3_EXECUTABLE} -c "import cairo"
                RESULT_VARIABLE PYTHON_CAIRO_RESULT)
if (PYTHON_CAIRO_RESULT EQUAL 0)
    set(PYTHONCAIRO_FOUND 1)
endif()
