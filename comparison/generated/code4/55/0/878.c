"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"cmp %%r8d, %%r9d	\n"
"mov %%r9d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%eax, %%edx	\n"
"cmp %%edx, %%ecx	\n"
"cmovg %%ecx, %%edx	\n"
"cmovl %%ecx, %%eax	\n"
"mov %%edx, %%ecx	\n"
"cmp %%ecx, %%r8d	\n"
"cmovg %%r8d, %%ecx	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r9d, %%edx	\n"
"cmp %%eax, %%r9d	\n"
"cmovl %%eax, %%edx	\n"
"cmovg %%eax, %%r9d	\n"
"cmp %%edx, %%r8d	\n"
"mov %%edx, %%eax	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
