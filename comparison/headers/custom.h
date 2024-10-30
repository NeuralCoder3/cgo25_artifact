#include <stdlib.h>
#include <algorithm>

extern "C" void sort3_default(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_default":::"memory");
  int tmp;
  if (buffer[0] > buffer[1])
  {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  if (buffer[1] > buffer[2])
  {
    tmp = buffer[1];
    buffer[1] = buffer[2];
    buffer[2] = tmp;
  }
  if (buffer[0] > buffer[1])
  {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_default_size(int buffer[3])
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_default_size":::"memory");
  int tmp;
  if (buffer[0] > buffer[1])
  {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  if (buffer[1] > buffer[2])
  {
    tmp = buffer[1];
    buffer[1] = buffer[2];
    buffer[2] = tmp;
  }
  if (buffer[0] > buffer[1])
  {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_std(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_std":::"memory");
  std::sort(buffer, buffer + 3);
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_branchless(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_branchless":::"memory");
  int a = buffer[0];
  int b = buffer[1];
  int c = buffer[2];
  int x = a > b;
  int y = a > c;
  int z = b > c;
  buffer[x + y] = a;
  buffer[1 - x + z] = b;
  buffer[2 - y - z] = c;
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_branchless_size(int buffer[3])
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_branchless_size":::"memory");
  int a = buffer[0];
  int b = buffer[1];
  int c = buffer[2];
  int x = a > b;
  int y = a > c;
  int z = b > c;
  buffer[x + y] = a;
  buffer[1 - x + z] = b;
  buffer[2 - y - z] = c;
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_swap(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_swap":::"memory");
  int a = buffer[0];
  int b = buffer[1];
  int c = buffer[2];

  if (c < b)
  {
    std::swap(c, b);
  }
  if (c < a)
  {
    std::swap(c, a);
  }
  if (b < a)
  {
    std::swap(b, a);
  }
  buffer[0] = a;
  buffer[1] = b;
  buffer[2] = c;
  __asm volatile("# LLVM-MCA-END":::"memory");
  return;
}

extern "C" void sort3_swap_inline(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_swap_inline":::"memory");
  if (buffer[0] > buffer[1])
  {
    std::swap(buffer[0], buffer[1]);
  }
  if (buffer[1] > buffer[2])
  {
    std::swap(buffer[1], buffer[2]);
  }
  if (buffer[0] > buffer[1])
  {
    std::swap(buffer[0], buffer[1]);
  }
  __asm volatile("# LLVM-MCA-END":::"memory");
}

// n = 4
extern "C" void sort4_default(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_default":::"memory");
  int tmp;
  // ab
  if (buffer[0] > buffer[1])
  {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  // cd
  if (buffer[2] > buffer[3])
  {
    tmp = buffer[2];
    buffer[2] = buffer[3];
    buffer[3] = tmp;
  }
  // ac
  if (buffer[0] > buffer[2])
  {
    tmp = buffer[0];
    buffer[0] = buffer[2];
    buffer[2] = tmp;
  }
  // bd
  if (buffer[1] > buffer[3])
  {
    tmp = buffer[1];
    buffer[1] = buffer[3];
    buffer[3] = tmp;
  }
  // bc
  if (buffer[1] > buffer[2])
  {
    tmp = buffer[1];
    buffer[1] = buffer[2];
    buffer[2] = tmp;
  }
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort4_default_size(int buffer[4])
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_default_size":::"memory");
  int tmp;
  // ab
  if (buffer[0] > buffer[1])
  {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  // cd
  if (buffer[2] > buffer[3])
  {
    tmp = buffer[2];
    buffer[2] = buffer[3];
    buffer[3] = tmp;
  }
  // ac
  if (buffer[0] > buffer[2])
  {
    tmp = buffer[0];
    buffer[0] = buffer[2];
    buffer[2] = tmp;
  }
  // bd
  if (buffer[1] > buffer[3])
  {
    tmp = buffer[1];
    buffer[1] = buffer[3];
    buffer[3] = tmp;
  }
  // bc
  if (buffer[1] > buffer[2])
  {
    tmp = buffer[1];
    buffer[1] = buffer[2];
    buffer[2] = tmp;
  }
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort4_std(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_std":::"memory");
  std::sort(buffer, buffer + 4);
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort4_branchless(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_branchless":::"memory");
  int a = buffer[0];
  int b = buffer[1];
  int c = buffer[2];
  int d = buffer[3];
  int x = a > b;
  int y = a > c;
  int z = a > d;
  int w = b > c;
  int v = b > d;
  int u = c > d;
  buffer[x + y + z] = a;
  buffer[1 - x + w + v] = b;
  buffer[2 - y - w + u] = c;
  buffer[3 - z - v - u] = d;
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort4_swap(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_swap":::"memory");
  int a = buffer[0];
  int b = buffer[1];
  int c = buffer[2];
  int d = buffer[3];

  // ab
  if (b < a)
    std::swap(b, a);
  // cd
  if (d < c)
    std::swap(d, c);
  // ac
  if (c < a)
    std::swap(c, a);
  // bd
  if (d < b)
    std::swap(d, b);
  // bc
  if (c < b)
    std::swap(c, b);

  buffer[0] = a;
  buffer[1] = b;
  buffer[2] = c;
  buffer[3] = d;
  __asm volatile("# LLVM-MCA-END":::"memory");
  return;
}

extern "C" void sort3_sorting_network(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_sorting_network":::"memory");
  asm volatile(
      "mov (%0), %%r8d	\n"
      "mov 0x4(%0), %%eax	\n"
      "mov 0x8(%0), %%ecx	\n"
      // // mov 4 1
      // // cmp 1 3
      // // cmovg 1 3
      // // cmovl 4 3
      // // mov 3 2
      // // cmp 1 2
      // // cmovg 2 1
      // // cmovg 1 3
      // // cmp 3 4
      // // cmovg 2 4
      // // cmovl 3 4
      // "mov %%r8d, %%edx	\n"
      // "cmp %%ecx, %%r8d	\n"
      // "cmovg %%ecx, %%r8d	\n"
      // "cmovl %%ecx, %%edx	\n"
      // "mov %%eax, %%ecx	\n"
      // "cmp %%eax, %%r8d	\n"
      // "cmovg %%r8d, %%eax	\n"
      // "cmovg %%ecx, %%r8d	\n"
      // "cmp %%edx, %%ecx	\n"
      // "cmovg %%edx, %%eax	\n"
      // "cmovl %%edx, %%ecx	\n"


      // swapifgreater(1, 2)
      // swapifgreater(2, 3)
      // swapifgreater(1, 2)

      // cmp 1 2
      // cmovg 4 2
      // cmovg 2 1
      // cmovg 1 4

      // cmp 2 3
      // cmovg 4 3
      // cmovg 3 2
      // cmovg 2 4

      // cmp 1 2
      // cmovg 4 2
      // cmovg 2 1
      // cmovg 1 4

      // 1 = r8d
      // 2 = eax
      // 3 = ecx
      // 4 = edx

      // cmp 1 2
      "cmp %%r8d, %%eax	\n"
      // cmovg 4 2
      "cmovg %%eax, %%edx	\n"
      // cmovg 2 1
      "cmovg %%r8d, %%eax	\n"
      // cmovg 1 4
      "cmovg %%edx, %%r8d	\n"

      // cmp 2 3
      "cmp %%eax, %%ecx	\n"
      // cmovg 4 3  
      "cmovg %%ecx, %%edx	\n"
      // cmovg 3 2
      "cmovg %%eax, %%ecx	\n"
      // cmovg 2 4
      "cmovg %%edx, %%eax	\n"

      // cmp 1 2
      "cmp %%r8d, %%eax	\n"
      // cmovg 4 2
      "cmovg %%eax, %%edx	\n"
      // cmovg 2 1
      "cmovg %%r8d, %%eax	\n"
      // cmovg 1 4
      "cmovg %%edx, %%r8d	\n"

    //   "mov %%r8d, (%0)	\n"
    //   "mov %%eax, 0x4(%0)	\n"
    //   "mov %%ecx, 0x8(%0)	\n"
      "mov %%r8d, 0x8(%0)	\n"
      "mov %%eax, 0x4(%0)	\n"
      "mov %%ecx, 0x0(%0)	\n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "r8d", "memory");
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_xmm(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort3_xmm":::"memory");
  asm volatile(
      "movd (%0), %%xmm0  \n"  // Load the first integer into xmm0
      "movd 4(%0), %%xmm1  \n" // Load the second integer into xmm1
      "movd 8(%0), %%xmm2  \n" // Load the third integer into xmm2

      // Compare xmm0 and xmm1, store min in xmm0 and max in xmm1
      "movaps %%xmm0, %%xmm3  \n"
      "pminsd %%xmm1, %%xmm0  \n"
      "pmaxsd %%xmm3, %%xmm1  \n"

      // Compare xmm1 and xmm2, store min in xmm1 and max in xmm2
      "movaps %%xmm1, %%xmm3  \n"
      "pminsd %%xmm2, %%xmm1  \n"
      "pmaxsd %%xmm3, %%xmm2  \n"

      // Compare xmm0 and xmm1 again to ensure the first two are in order
      "movaps %%xmm0, %%xmm3  \n"
      "pminsd %%xmm1, %%xmm0  \n"
      "pmaxsd %%xmm3, %%xmm1  \n"

      // Store the sorted values back to memory
      "movd %%xmm0, (%0)  \n"
      "movd %%xmm1, 4(%0)  \n"
      "movd %%xmm2, 8(%0)  \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "r8d",
        "xmm0", "xmm1", "xmm2", "xmm3",
        "memory");
  __asm volatile("# LLVM-MCA-END":::"memory");
}


extern "C" void sort3_xmm2_asm(int *buffer)
{
  // https://godbolt.org/z/6jarjofvP
  __asm volatile("# LLVM-MCA-BEGIN sort3_xmm2_asm":::"memory");
  asm volatile(
      "movd (%0), %%xmm0  \n"  // Load the first integer into xmm0
      "movd 4(%0), %%xmm1  \n" // Load the second integer into xmm1
      "movd 8(%0), %%xmm2  \n" // Load the third integer into xmm2

        "movdqa  %%xmm0, %%xmm3\n"
        "pminud  %%xmm1, %%xmm3\n"
        "pmaxud  %%xmm1, %%xmm0\n"
        "movdqa  %%xmm2, %%xmm1\n"
        "pminud  %%xmm3, %%xmm1\n"
        "pmaxud  %%xmm2, %%xmm3\n"
        "movdqa  %%xmm0, %%xmm2\n"
        "pminud  %%xmm3, %%xmm2\n"
        "pmaxud  %%xmm0, %%xmm3\n"

      // Store the sorted values back to memory
      "movd %%xmm1, (%0)  \n"
      "movd %%xmm2, 4(%0)  \n"
      "movd %%xmm3, 8(%0)  \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "r8d",
        "xmm0", "xmm1", "xmm2", "xmm3",
        "memory");
  __asm volatile("# LLVM-MCA-END":::"memory");
}

extern "C" void sort3_xmm2_c(int *data) {
  __asm volatile("# LLVM-MCA-BEGIN sort3_xmm2_c":::"memory");
    typedef uint32_t T __attribute__((ext_vector_type(2)));
    T tmp1, tmp2, tmp3;
    tmp1[0] = data[0];
    tmp2[0] = data[1];
    tmp3[0] = data[2];
    auto tmp4 = __builtin_elementwise_min(tmp1, tmp2);
    auto tmp5 = __builtin_elementwise_max(tmp1, tmp2);
    auto tmp6 = __builtin_elementwise_min(tmp3, tmp4);
    auto tmp7 = __builtin_elementwise_max(tmp3, tmp4);
    auto tmp8 = __builtin_elementwise_min(tmp5, tmp7);
    auto tmp9 = __builtin_elementwise_max(tmp5, tmp7);
    data[0] = tmp9[0];
    data[1] = tmp8[0];
    data[2] = tmp6[0];
  __asm volatile("# LLVM-MCA-END":::"memory");
}

#define SWAP(a, b, s) \
  "movdqa  " #a ", " #s "\n" \
  "pminud  " #b ", " #a "\n" \
  "pmaxud  " #s ", " #b "\n"

extern "C" void sort4_xmm_asm(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_xmm_asm":::"memory");
  asm volatile(
      // Load the four integers into xmm registers
      "movd (%0), %%xmm0  \n"  // Load the first integer into xmm0
      "movd 4(%0), %%xmm1  \n" // Load the second integer into xmm1
      "movd 8(%0), %%xmm2  \n" // Load the third integer into xmm2
      "movd 12(%0), %%xmm3  \n"// Load the fourth integer into xmm3

      SWAP(%%xmm0, %%xmm1, %%xmm4)
      SWAP(%%xmm2, %%xmm3, %%xmm4)
      SWAP(%%xmm0, %%xmm2, %%xmm4)
      SWAP(%%xmm1, %%xmm3, %%xmm4)
      SWAP(%%xmm1, %%xmm2, %%xmm4)

      // Store the sorted values back to memory
      "movd %%xmm0, (%0)  \n"
      "movd %%xmm1, 4(%0)  \n"
      "movd %%xmm2, 8(%0)  \n"
      "movd %%xmm3, 12(%0) \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "r8d",
        "xmm0", "xmm1", "xmm2", "xmm3", "xmm4",
        "memory");
  __asm volatile("# LLVM-MCA-END":::"memory");
}


extern "C" void sort5_xmm_asm(int *buffer)
{
  __asm volatile("# LLVM-MCA-BEGIN sort4_xmm_asm":::"memory");
  asm volatile(
      // Load the four integers into xmm registers
      "movd (%0), %%xmm0  \n"  // Load the first integer into xmm0
      "movd 4(%0), %%xmm1  \n" // Load the second integer into xmm1
      "movd 8(%0), %%xmm2  \n" // Load the third integer into xmm2
      "movd 12(%0), %%xmm3  \n"// Load the fourth integer into xmm3
      "movd 16(%0), %%xmm4  \n"// Load the fifth integer into xmm4

      SWAP(%%xmm1, %%xmm2, %%xmm5)
      SWAP(%%xmm3, %%xmm4, %%xmm5)
      SWAP(%%xmm1, %%xmm3, %%xmm5)
      SWAP(%%xmm0, %%xmm2, %%xmm5)

      SWAP(%%xmm0, %%xmm3, %%xmm5)
      SWAP(%%xmm2, %%xmm4, %%xmm5)
      SWAP(%%xmm0, %%xmm1, %%xmm5)
      SWAP(%%xmm2, %%xmm3, %%xmm5)

      SWAP(%%xmm1, %%xmm2, %%xmm5)

      // Store the sorted values back to memory
      "movd %%xmm0, (%0)  \n"
      "movd %%xmm1, 4(%0)  \n"
      "movd %%xmm2, 8(%0)  \n"
      "movd %%xmm3, 12(%0) \n"
      "movd %%xmm4, 16(%0) \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "r8d",
        "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5",
        "memory");
  __asm volatile("# LLVM-MCA-END":::"memory");
}