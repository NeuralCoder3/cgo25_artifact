"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"mov %%r8d, %%edx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%eax, %%r8d	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%ecx, %%r9d	\n"
"mov %%ecx, %%edx	\n"
"cmovg %%r9d, %%edx	\n"
"cmovg %%ecx, %%r9d	\n"
"mov %%edx, %%ecx	\n"
"cmp %%edx, %%eax	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%r8d, %%r9d	\n"
"mov %%r9d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r8d, %%edx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%eax, %%r8d	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
