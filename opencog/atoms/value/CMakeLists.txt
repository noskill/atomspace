INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})

ADD_LIBRARY (value
	Value.cc
	FloatValue.cc
	LinkValue.cc
	RandomStream.cc
	StreamValue.cc
	StringValue.cc
	ValueFactory.cc
	PtrValue.cc
	TorchValue.cc
)
add_library(torch SHARED IMPORTED)
add_library(c10 SHARED IMPORTED)
add_library(caffe SHARED IMPORTED)
set_property(TARGET torch PROPERTY IMPORTED_LOCATION  /home/noskill/projects/libtorch/lib/libtorch.so)
set_property(TARGET c10 PROPERTY IMPORTED_LOCATION  /home/noskill/projects/libtorch/lib/libc10.so)
set_property(TARGET caffe PROPERTY IMPORTED_LOCATION  /home/noskill/projects/libtorch/lib/libcaffe2.so)

# Without this, parallel make will race and crap up the generated files.
ADD_DEPENDENCIES(value opencog_atom_types torch c10)

TARGET_LINK_LIBRARIES(value
	atom_types
	torch
	c10
        caffe	
	${COGUTIL_LIBRARY}
)
include_directories("/home/noskill/projects/libtorch/include/torch/csrc/api/include/"
                    "/home/noskill/projects/libtorch/include/"
	            "/usr/include/python3.6m/")

INSTALL (TARGETS value EXPORT AtomSpaceTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

INSTALL (FILES
	FloatValue.h
	LinkValue.h
	Value.h
	RandomStream.h
	StreamValue.h
	StringValue.h
	ValueFactory.h
	PtrValue.h
	TorchValue.h
	DESTINATION "include/opencog/atoms/value"
)
