"mov (%0), %%r10d	\n"
"mov 0x4(%0), %%r9d	\n"
"mov 0x8(%0), %%r8d	\n"
"mov 0xc(%0), %%eax	\n"
"mov 0x10(%0), %%ecx	\n"
"mov %%r10d, %%edx	\n"
"cmp %%edx, %%r9d	\n"
"cmovl %%r9d, %%r10d	\n"
"cmovl %%edx, %%r9d	\n"
"mov %%r8d, %%edx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%eax, %%r8d	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r10d, %%edx	\n"
"cmp %%r8d, %%r10d	\n"
"cmovg %%r8d, %%r10d	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%eax, %%r9d	\n"
"cmovg %%r9d, %%edx	\n"
"cmovg %%eax, %%r9d	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%r8d, %%r9d	\n"
"cmovg %%r9d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%ecx, %%edx	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%r8d, %%r9d	\n"
"cmovg %%r9d, %%r8d	\n"
"cmovg %%edx, %%r9d	\n"
"cmp %%r9d, %%r10d	\n"
"cmovg %%r10d, %%r9d	\n"
"cmovg %%edx, %%r10d	\n"
"mov %%r10d, (%0)	\n"
"mov %%r9d, 0x4(%0)	\n"
"mov %%r8d, 0x8(%0)	\n"
"mov %%eax, 0xc(%0)	\n"
"mov %%ecx, 0x10(%0)	\n"
