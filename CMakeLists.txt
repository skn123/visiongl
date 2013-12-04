# CMakeLists.txt to generate Makefile
# cmake version 2.8 required
cmake_minimum_required(VERSION 2.8)

# Defining project name 
project(visiongl)

# visiongl_src stores the name of the source files
set(visiongl_src src/vglImage.cpp src/vglSimpleBGModel.cpp src/vglLoadShader.cpp src/vglContext.cpp src/glsl2cpp_Stereo.cpp src/glsl2cpp_shaders.cpp src/glsl2cpp_DiffEq.cpp src/glsl2cpp_BG.cpp)
set(visiongl_headers src/vglTail.h src/vglSimpleBGModel.h src/vglLoadShader.h src/vglImage.h src/vglHead.h src/vglContext.h src/glsl2cpp_Stereo.h src/glsl2cpp_shaders.h src/glsl2cpp_DiffEq.h src/glsl2cpp_BG.h)
set(visiongl_src_cuda src/vglCudaImage.cu src/kernel2cu_shaders.cu src/kernel2cu_shaders.h src/vglCudaImage.h)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake-modules")

# Gererate Makefile for Windows
if(WIN32)

	# Looking for lib and include folders of glew, glut and opencv
	find_package (MyGLEW REQUIRED)
	find_package (MyFREEGLUT REQUIRED)
	find_package (MyOpenCV REQUIRED)

	# Adding folders containing libs
	link_directories(${OPENCV_LIBRARY})

	# Adding folders containing header files
	INCLUDE_DIRECTORIES( src/ ${OPENCV_INCLUDE_DIR} ${GLEW_INCLUDE_DIR} ${FREEGLUT_INCLUDE_DIR})
	
	# Add CUDA if applies
	if (${WITH_CUDA}) # Creating object file of the library within CUDA
		find_package(CUDA REQUIRED)
		add_definitions(-D__CUDA__)
		
		list(APPEND CUDA_NVCC_FLAGS ${custom_cuda_flags})
		list(APPEND CUDA_NVCC_FLAGS -Xcompiler)
		
		cuda_add_library(visiongl ${visiongl_src} ${visiongl_headers} ${visiongl_src_cuda})
		
	else() # Creating object file of the library without CUDA
		add_library(visiongl ${visiongl_src} ${visiongl_headers})
	endif()

	# Creating demo_fractal object files
	if (${WITH_CUDA})
		cuda_add_executable(demo_fractal src/demo/fractal.cpp)
	else()
		add_executable(demo_fractal src/demo/fractal.cpp)
	endif()
	
        SET_TARGET_PROPERTIES(demo_fractal PROPERTIES PREFIX "bin/")

	# Creating demo_cam object files
	if (${WITH_CUDA})
		cuda_add_executable(demo_cam src/demo/cam.cpp)
	else()
		add_executable(demo_cam src/demo/cam.cpp)
	endif()
        SET_TARGET_PROPERTIES(demo_cam PROPERTIES PREFIX "bin/")
 
	# Linking executables
	target_link_libraries(demo_cam visiongl ${FREEGLUT_LIBRARY} ${GLEW_LIBRARY} ${OPENCV_LIBRARIES})
	target_link_libraries(demo_fractal visiongl ${FREEGLUT_LIBRARY} ${GLEW_LIBRARY} ${OPENCV_LIBRARIES})
	

# Gererate Makefile for Linux
else()

	# Looking for lib and include folders of glew, glut, opencv and opengl
	find_package (MyGLEW REQUIRED)
	find_package (MyFREEGLUT REQUIRED)
	find_package (MyOpenCV REQUIRED)
	find_package (OpenGL REQUIRED)

	# Adding folders containing libs
	link_directories(${OPENCV_LIBRARY})

	# Adding folders containing header files
	INCLUDE_DIRECTORIES( src/ ${GLEW_INCLUDE_PATH} ${FREEGLUT_INCLUDE_DIR} ${OPENCV_INCLUDE_DIR} )

	if (${WITH_CUDA}) # Creating object file of the library within CUDA
		find_package(CUDA REQUIRED)
		add_definitions(-D__CUDA__)
		
		list(APPEND CUDA_NVCC_FLAGS ${custom_cuda_flags})
		list(APPEND CUDA_NVCC_FLAGS -Xcompiler)
		
		cuda_add_library(visiongl ${visiongl_src} ${visiongl_headers} ${visiongl_src_cuda})
		
	else() # Creating object file of the library without CUDA
		add_library(visiongl ${visiongl_src} ${visiongl_headers})
	endif()
        SET_TARGET_PROPERTIES(visiongl PROPERTIES PREFIX "lib/lib")

	# Creating demo_fractal object files
	add_executable(demo_fractal src/demo/fractal.cpp)
        SET_TARGET_PROPERTIES(demo_fractal PROPERTIES PREFIX "bin/")

	# Creating demo_cam object files
	add_executable(demo_cam src/demo/cam.cpp)
        SET_TARGET_PROPERTIES(demo_cam PROPERTIES PREFIX "bin/")
	
	# Linking executables
	target_link_libraries(demo_fractal visiongl ${OPENCV_LIBRARIES}  ${FREEGLUT_LIBRARY} ${GLEW_LIBRARY} ${OPENGL_glu_LIBRARY})
	target_link_libraries(demo_cam     visiongl ${OPENCV_LIBRARIES}  ${FREEGLUT_LIBRARY} ${GLEW_LIBRARY} ${OPENGL_glu_LIBRARY})

endif()