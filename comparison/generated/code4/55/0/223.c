"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"cmp %%ecx, %%eax	\n"
"mov %%ecx, %%edx	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r9d, %%edx	\n"
"cmp %%r8d, %%r9d	\n"
"cmovg %%r8d, %%r9d	\n"
"cmovg %%edx, %%r8d	\n"
"cmp %%ecx, %%r8d	\n"
"mov %%ecx, %%edx	\n"
"cmovg %%r8d, %%ecx	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%eax, %%edx	\n"
"cmp %%edx, %%r9d	\n"
"cmovg %%r9d, %%eax	\n"
"cmovg %%edx, %%r9d	\n"
"cmp %%eax, %%r8d	\n"
"mov %%eax, %%edx	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
