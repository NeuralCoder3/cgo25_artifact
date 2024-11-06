#include <cstdlib>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

using namespace std;

extern "C" void sort3(int *buffer) {
  int a = buffer[0];
  int b = buffer[1];
  int c = buffer[2];
  int x = a>b;
  int y = a>c;
  int z = b>c;
  buffer[x+y]=a;
  buffer[1-x+z]=b;
  buffer[2-y-z]=c;
}

#if defined(__clang__)

extern "C" void sort3_alphadev(int* buffer) {
  asm volatile(
      "mov 0x4(%0), %%eax            \n"
      "mov 0x8(%0), %%ecx            \n"
      "cmp %%eax, %%ecx              \n"
      "mov %%eax, %%edx              \n"
      "cmovl %%ecx, %%edx            \n"
      "mov (%0), %%r8d               \n"
      "cmovg %%ecx, %%eax            \n"
      "cmp %%r8d, %%eax              \n"
      "mov %%r8d, %%ecx              \n"
      "cmovl %%eax, %%ecx            \n"
      "cmovle %%r8d, %%eax           \n"
      "mov %%eax, 0x8(%0)            \n"
      "cmp %%ecx, %%edx              \n"
      "cmovle %%edx, %%r8d           \n"
      "mov %%r8d, (%0)               \n"
      "cmovg %%edx, %%ecx            \n"
      "mov %%ecx, 0x4(%0)            \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "r8d", "memory");
}

#else

// Adapted from [1] for gcc. ("rd8" is replaced with "esi" for the compilation to succeed.)
extern "C" void sort3_alphadev(int* buffer) {
  asm volatile(
      "mov 0x4(%0), %%eax            \n"
      "mov 0x8(%0), %%ecx            \n"
      "cmp %%eax, %%ecx              \n"
      "mov %%eax, %%edx              \n"
      "cmovl %%ecx, %%edx            \n"
      "mov (%0), %%esi               \n"
      "cmovg %%ecx, %%eax            \n"
      "cmp %%esi, %%eax              \n"
      "mov %%esi, %%ecx              \n"
      "cmovl %%eax, %%ecx            \n"
      "cmovle %%esi, %%eax           \n"
      "mov %%eax, 0x8(%0)            \n"
      "cmp %%ecx, %%edx              \n"
      "cmovle %%edx, %%esi           \n"
      "mov %%esi, (%0)               \n"
      "cmovg %%edx, %%ecx            \n"
      "mov %%ecx, 0x4(%0)            \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "esi", "memory");
}
#endif

extern "C" void sort3_manual(int* buffer) {
  asm volatile(
      "mov (%0), %%eax               \n"
      "mov 0x4(%0), %%ecx            \n"
      "mov 0x8(%0), %%edx            \n"
      // swap if greater 0 (eax) > 1 (ecx)
      // via conditional move
      "cmp %%eax, %%ecx              \n"
      // "cmovg %%esi, %%ecx            \n"
      // "cmovg %%ecx, %%eax            \n"
      // "cmovg %%eax, %%esi            \n"
      "cmovg %%ecx, %%esi            \n"
      "cmovg %%eax, %%ecx            \n"
      "cmovg %%esi, %%eax            \n"
      // swap if greater 1 (ecx) > 2 (edx)
      "cmp %%ecx, %%edx              \n"
      // "cmovg %%esi, %%edx            \n"
      // "cmovg %%edx, %%ecx            \n"
      // "cmovg %%ecx, %%esi            \n"
      "cmovg %%edx, %%esi            \n"
      "cmovg %%ecx, %%edx            \n"
      "cmovg %%esi, %%ecx            \n"
      // swap if greater 0 (eax) > 1 (ecx)
      "cmp %%eax, %%ecx              \n"
      "cmovg %%ecx, %%esi            \n"
      "cmovg %%eax, %%ecx            \n"
      "cmovg %%esi, %%eax            \n"
      // store back
      "mov %%eax, 0x8(%0)               \n"
      "mov %%ecx, 0x4(%0)            \n"
      "mov %%edx, (%0)            \n"
      : "+r"(buffer)
      :
      : "eax", "ecx", "edx", "esi", "memory");
}


extern "C" void sort3_branch(int *buffer) {
  // sort 3 elements
  int tmp;
  if (buffer[0] > buffer[1]) {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
  if (buffer[1] > buffer[2]) {
    tmp = buffer[1];
    buffer[1] = buffer[2];
    buffer[2] = tmp;
  }
  if (buffer[0] > buffer[1]) {
    tmp = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmp;
  }
}

int main(int argc, char **argv) {
  // check sort on all permutations of 3 elements

  // enumerate all permutations of 3 elements
  int buffer[6][3] = {
    {1, 2, 3},
    {1, 3, 2},
    {2, 1, 3},
    {2, 3, 1},
    {3, 1, 2},
    {3, 2, 1}
  };
  int ret = 0;
  for (int i = 0; i < 6; ++i) {
    // sort3(buffer[i]);
    sort3_manual(buffer[i]);
    if (buffer[i][0] != 1 || buffer[i][1] != 2 || buffer[i][2] != 3) {
      printf("Invalid sort of %d %d %d\n", buffer[i][0], buffer[i][1], buffer[i][2]);
      ret = 1;
    }
  }
  if(ret != 0) {
    printf("sort3 failed\n");
    return ret;
  }


  // for speed test a few more
  if (argc != 2) {
    printf("Usage: %s <iterations>\n", argv[0]);
    return 1;
  }
  const auto itr = atoi(argv[1]);

  int a = 1;
  int b = 1;
  int c = 1;
  for (auto i = 0; i < itr; ++i) {
    // generate three random numbers
    a = rand();
    b = rand();
    c = rand();

    int buffer[3] = {a, b, c};

    // time ./a.out 100000000
    // sort3(buffer); // 2.63s
    // sort3_branch(buffer); // 3.30s
    // sort3_alphadev(buffer); // 1.64s
    sort3_manual(buffer); // 1.64s

    if ((buffer[0] > buffer[1] || buffer[1] > buffer[2]) && ret == 0) {
      ret = 1;
      printf("Invalid sort of %d %d %d\n",a,b,c);
      printf("to %d %d %d\n",buffer[0],buffer[1],buffer[2]);
    }
  }


  return ret;
}
