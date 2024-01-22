cmake_minimum_required(VERSION 3.5)
project(ORBWrapper)

MESSAGE("Build type: " ${CMAKE_BUILD_TYPE})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -Wall   -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall   -O3")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")

# Check C++11 or C++0x support
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)
# CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
if(COMPILER_SUPPORTS_CXX14)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
   add_definitions(-DCOMPILEDWITHC14)
   message(STATUS "Using flag -std=c++14.")
elseif(COMPILER_SUPPORTS_CXX11)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
   add_definitions(-DCOMPILEDWITHC11)
   message(STATUS "Using flag -std=c++11.")
else()
   message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. Please use a different C++ compiler.")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

find_package(OpenCV REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)
find_package(Sophus REQUIRED)
find_package(Pangolin REQUIRED)
find_package(ORB_SLAM3 REQUIRED)

include_directories(
  include
  ${ORB_SLAM3_ROOT_DIR}/include
  ${ORB_SLAM3_ROOT_DIR}/include/CameraModels
  ${ORB_SLAM3_ROOT_DIR}/Thirdparty/Sophus
  ${ORB_SLAM3_ROOT_DIR}
  ${EIGEN_INCLUDE_DIR}
  ${Pangolin_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIR}
)

link_directories(
  include
)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries( ${PROJECT_NAME} ${Eigen3_LIBS})
target_link_libraries( ${PROJECT_NAME} ${OpenCV_LIBRARIES})
target_link_libraries( ${PROJECT_NAME} ${Pangolin_LIBRARIES})
target_link_libraries( ${PROJECT_NAME} ${Sophus_LIBS})
target_link_libraries( ${PROJECT_NAME} ${ORB_SLAM3_LIBRARY} -lboost_serialization -lcrypto)