#include "interface.h"
#include "alphadev.h"
#include "cassioneri.h"
#include "custom.h"
#include "mimicry.h"
#include "rust.h"
#include "../generated/code/generated.h"
#include "../generated/code_minmax/generated.h"

#include <array>

TestFunction predefined_functions[] = {

    {sort3_cassioneri_14, "cassioneri_14"},
    {sort3_cassioneri_15, "cassioneri_15"},
    {sort3_cassioneri_15_v2, "cassioneri_15_v2"},
    {sort3_cassioneri_faster, "cassioneri_faster"},

    {sort3_default, "default"},
    {sort3_default_size, "default_size"},
    {sort3_std, "std"},
    {sort3_branchless, "branchless"},
    {sort3_branchless_size, "branchless_size"},
    {sort3_swap, "swap"},
    {sort3_swap_inline, "swap_inline"},
    {sort3_sorting_network, "sorting_network"},
    {sort3_xmm, "sort3_xmm"},
    {sort3_xmm2_asm, "sort3_xmm2_asm"},
    {sort3_xmm2_c, "sort3_xmm2_c"},

    // { sort3_mimicry_mu, "sort3_mimicry_mu" },
    {sort3_mimicry_ms, "mimicry_ms"},
    {sort3_mimicry_mv, "mimicry_mv"},
    {sort3_mimicry_std, "mimicry_std"},

    // {sort3_rust_std, "rust_std"},
    {sort3_rust_swap_inline_annotated, "rust_swap_inline_annotated"},
    {sort3_rust_swap_inline_raw, "rust_swap_inline_raw"},
    {sort3_rust_branchless_min_annotated, "rust_branchless_min_annotated"},
    {sort3_rust_branchless_annotated, "rust_branchless_annotated"},

    {sort3_alphadev, "alphadev"},
    {sort3_alphadev_reorder, "alphadev_reorder"},
};

std::vector<TestFunction> MakeFunctions()
{
    std::vector<TestFunction> functions;
    for (auto &func : predefined_functions)
    {
        functions.push_back(func);
    }

    std::vector<TestFunction> generated;
    for (auto &func : gen_functions_minmax)
    {
        generated.push_back(func);
    }
    for (auto &func : gen_functions)
    {
        generated.push_back(func);
    }
    auto gen = std::default_random_engine(42);
    std::shuffle(generated.begin(), generated.end(), gen);
    for (auto &func : generated)
    {
        functions.push_back(func);
    }
    generated.clear();

    return functions;
}

std::vector<TestFunction> functions = MakeFunctions();
