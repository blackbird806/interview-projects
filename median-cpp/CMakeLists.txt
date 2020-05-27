cmake_minimum_required(VERSION 3.10)
project(median)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

if(MSVC)
	set(CMAKE_CXX_FLAGS "/W3 /EHsc /WX /Od")
else()
	set(CMAKE_CXX_FLAGS "-Wall -Wextra -Werror -g -O0")
endif()

add_executable(ut test-main.cpp tests.cpp median.cpp)

if(MSVC)
	set(CMAKE_CXX_FLAGS "/W3 /WX /EHsc /O2 /Ob2")
else()
	set(CMAKE_CXX_FLAGS "-Wall -Wextra -Werror -g -O2")
endif()

add_executable(app median.cpp app.cpp)
