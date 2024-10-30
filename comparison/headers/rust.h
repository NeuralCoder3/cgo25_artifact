#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

extern "C" {

void sort3_rust_std(int32_t *buf);

void sort3_rust_swap_inline_annotated(int32_t *buf_raw);

void sort3_rust_swap_inline_raw(int32_t *buf);

void sort3_rust_branchless_min_annotated(int32_t *buf_raw);

void sort3_rust_branchless_annotated(int32_t *buf_raw);

} // extern "C"
