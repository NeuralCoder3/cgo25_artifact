"mov (%0), %%r10d	\n"
"mov 0x4(%0), %%r9d	\n"
"mov 0x8(%0), %%r8d	\n"
"mov 0xc(%0), %%eax	\n"
"mov 0x10(%0), %%ecx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%r8d, %%edx	\n"
"cmovg %%eax, %%r8d	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%ecx, %%r9d	\n"
"cmovg %%ecx, %%edx	\n"
"cmovg %%r9d, %%ecx	\n"
"cmovg %%edx, %%r9d	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%ecx, %%edx	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%r8d, %%r9d	\n"
"cmovg %%r9d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%eax, %%edx	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%r9d, %%r10d	\n"
"cmovg %%r10d, %%edx	\n"
"cmovg %%r9d, %%r10d	\n"
"cmovg %%edx, %%r9d	\n"
"cmp %%r8d, %%r9d	\n"
"cmovg %%r8d, %%r9d	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%edx, %%eax	\n"
"cmovl %%eax, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%ecx, %%eax	\n"
"cmovg %%edx, %%ecx	\n"
"mov %%r10d, (%0)	\n"
"mov %%r9d, 0x4(%0)	\n"
"mov %%r8d, 0x8(%0)	\n"
"mov %%eax, 0xc(%0)	\n"
"mov %%ecx, 0x10(%0)	\n"
