#This file was initially taken from https://raw.githubusercontent.com/microsoft/vcpkg/master/ports/7zip/CMakeLists.txt

#This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

#This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

#You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


# Created from 7-zip v19.00 - 7zip/CPP/7zip/Bundles/Format7zF

cmake_minimum_required(VERSION 3.11)
cmake_policy(VERSION 3.11)

#project(7zip LANGUAGES C CXX ASM_NASM)
project(7zip LANGUAGES C CXX ASM)

set(ARCH_SPEC_ASM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Asm/x86")

#file(GLOB_RECURSE SRC_ASM "${ARCH_SPEC_ASM_DIR}/*.asm")
set(SRC_ASM
    ${ARCH_SPEC_ASM_DIR}/AesOpt.asm
    ${ARCH_SPEC_ASM_DIR}/7zCrcOpt.asm
    #${ARCH_SPEC_ASM_DIR}/XzCrc64Opt.asm
)

if(WIN32)
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set_source_files_properties(${SRC_ASM} PROPERTIES COMPILE_FLAGS "-Dx64")
	else()
		set_source_files_properties(${SRC_ASM} PROPERTIES COMPILE_FLAGS "-safeseh")
	endif()
endif()

file(GLOB_RECURSE SRC_COMPRESS "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Compress/*.cpp")

file(GLOB_RECURSE SRC_CRYPTO "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Crypto/*.cpp")

file(GLOB_RECURSE SRC_C "${CMAKE_CURRENT_SOURCE_DIR}/C/*.c")

set_source_files_properties(
    ${SRC_COMPRESS}
    ${SRC_CRYPTO}
    ${SRC_C}
        PROPERTIES
            COMPILE_FLAGS $<$<CONFIG:RELEASE>:"/O2">
)


file(GLOB_RECURSE SRC_OTHER
	"${CMAKE_CURRENT_SOURCE_DIR}/CPP/Common/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/CPP/Common/*.cpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/CPP/Windows/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/CPP/Windows/*.cpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Common/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Common/*.cpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Archive/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Archive/*.cpp"
)

add_library(7zip
    ${SRC_ASM}
    ${SRC_OTHER}
    ${SRC_COMPRESS}
    ${SRC_CRYPTO}
    ${SRC_C}
    CPP/7zip/Archive/Archive2.def
)

target_include_directories(7zip PRIVATE ${ARCH_SPEC_ASM_DIR} C/brotli C/fast-lzma2 C/hashes C/lizard C/lz4 C/lz5 C/Util C/zstd C/zstdmt)


target_compile_definitions(7zip
    PUBLIC
        -DEXTERNAL_CODECS
        -D_7ZIP_LARGE_PAGES
        -D_7ZIP_ASM
        -DUNICODE
        -D_UNICODE
)

IF("${CMAKE_SYSTEM}" MATCHES "Linux")
target_compile_definitions(7zip
    PUBLIC
        -D_FILE_OFFSET_BITS=64
        -D_LARGEFILE_SOURCE
        -DNDEBUG
        -D_REENTRANT
        -DENV_UNIX
        -DENV_HAVE_GCCVISIBILITYPATCH
)
endif()

target_compile_options(7zip
    PRIVATE
        $<$<CONFIG:RELEASE>:/guard:cf>
)

target_include_directories(7zip
    INTERFACE
        $<INSTALL_INTERFACE:include>/7zip/CPP
)

set(PUBLIC_HEADERS
    C/7zTypes.h
    CPP/7zip/Archive/IArchive.h
    CPP/7zip/ICoder.h
    CPP/7zip/IDecl.h
    CPP/7zip/IPassword.h
    CPP/7zip/IProgress.h
    CPP/7zip/IStream.h
    CPP/7zip/PropID.h
    CPP/Common/Defs.h
    CPP/Common/MyTypes.h
    CPP/Common/MyUnknown.h
    CPP/Common/MyWindows.h
)

install(
    TARGETS 7zip
    EXPORT 7zip
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Headers makes relative includes so directory structure must be kept
foreach(HEADER ${PUBLIC_HEADERS})
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(
        FILES ${HEADER}
        CONFIGURATIONS Release
        DESTINATION include/7zip/${HEADER_DIR}
    )
endforeach()

install(
    EXPORT 7zip
    DESTINATION share/7zip
    FILE 7zipConfig.cmake
    NAMESPACE 7zip::
    CONFIGURATIONS Release
)

