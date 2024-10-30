cmake_minimum_required(VERSION 3.1)

project(sort3bench
  VERSION 1.0
  DESCRIPTION ""
  LANGUAGES CXX
)

set(CMAKE_COMPILE_WARNING_AS_ERROR ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS "s;S")

add_compile_options(-fno-pie)
add_link_options(-no-pie)

#---------------------------------------------------------------------------
# Google benchmark
#---------------------------------------------------------------------------

include(FetchContent)

FetchContent_Declare(
  benchmark
  GIT_REPOSITORY https://github.com/google/benchmark.git
  GIT_TAG        v1.8.2
  SOURCE_DIR     ${CMAKE_BINARY_DIR}/tp/benchmark
)

set(BENCHMARK_ENABLE_TESTING off)
FetchContent_MakeAvailable(benchmark)
target_compile_definitions(benchmark PUBLIC -DBENCHMARK_STATIC_DEFINE)

#---------------------------------------------------------------------------
# Sort3
#---------------------------------------------------------------------------

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

add_executable(bench
  bench/benchmark.cpp
)

add_executable(bench4
  bench/benchmark4.cpp
)

add_executable(bench5
  bench/benchmark5.cpp
)

add_executable(bench_embed
  bench/benchmark_embed.cpp
)

add_executable(bench_embed4
  bench/benchmark_embed4.cpp
)

target_link_libraries(bench benchmark benchmark_main)
target_link_libraries(bench_embed benchmark benchmark_main)
target_link_libraries(bench4 benchmark benchmark_main)
target_link_libraries(bench_embed4 benchmark benchmark_main)
target_link_libraries(bench5 benchmark benchmark_main)

# cargo build --release if libsort_rust.a is not present
include(ExternalProject)
ExternalProject_Add(
  rust_sort
  PREFIX ${CMAKE_SOURCE_DIR}/rust_sort
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/rust_sort
  BINARY_DIR ${CMAKE_SOURCE_DIR}/rust_sort
  BUILD_ALWAYS 1
  BUILD_BYPRODUCTS ${CMAKE_SOURCE_DIR}/rust_sort/target/release/libsort_rust.a
  CONFIGURE_COMMAND ""
  BUILD_COMMAND cargo build --release
  INSTALL_COMMAND ""
)
add_dependencies(bench rust_sort)
add_dependencies(bench_embed rust_sort)
add_dependencies(bench4 rust_sort)
add_dependencies(bench_embed4 rust_sort)
add_dependencies(bench5 rust_sort)

# add libsort_rust.a (${CMAKE_SOURCE_DIR}/../rust_sort/target/release/libsort_rust.a)
# additionally compile .a file into the executable

target_link_libraries(bench ${CMAKE_SOURCE_DIR}/rust_sort/target/release/libsort_rust.a)
target_link_libraries(bench_embed ${CMAKE_SOURCE_DIR}/rust_sort/target/release/libsort_rust.a)
target_link_libraries(bench4 ${CMAKE_SOURCE_DIR}/rust_sort/target/release/libsort_rust.a)
target_link_libraries(bench_embed4 ${CMAKE_SOURCE_DIR}/rust_sort/target/release/libsort_rust.a)
target_link_libraries(bench5 ${CMAKE_SOURCE_DIR}/rust_sort/target/release/libsort_rust.a)


# generate assembly code (.s) for the benchmarks
# new target for assembly code of bench


#---------------------------------------------------------------------------
# Custom targets for generating assembly files
#---------------------------------------------------------------------------

include_directories(${CMAKE_BINARY_DIR}/tp/benchmark/include)
add_definitions(-DBENCHMARK_STATIC_DEFINE)

function(add_assembly_target target_name source_file)
  add_custom_target(${target_name}
    COMMAND ${CMAKE_CXX_COMPILER}
      ${CMAKE_CXX_FLAGS}
      -O2
      -S ${source_file}
      -o ${PROJECT_BINARY_DIR}/${target_name}.s
      -I${CMAKE_BINARY_DIR}/tp/benchmark/include
      -DBENCHMARK_STATIC_DEFINE
    COMMENT "Generating assembly for ${source_file}"
  )
endfunction()


add_assembly_target(bench_s ${CMAKE_SOURCE_DIR}/bench/benchmark.cpp)
add_assembly_target(bench4_s ${CMAKE_SOURCE_DIR}/bench/benchmark4.cpp)
add_assembly_target(bench5_s ${CMAKE_SOURCE_DIR}/bench/benchmark5.cpp)
add_assembly_target(bench_embed_s ${CMAKE_SOURCE_DIR}/bench/benchmark_embed.cpp)
add_assembly_target(bench_embed4_s ${CMAKE_SOURCE_DIR}/bench/benchmark_embed4.cpp)