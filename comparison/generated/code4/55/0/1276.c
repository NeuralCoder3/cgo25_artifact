"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"mov %%ecx, %%edx	\n"
"cmp %%edx, %%eax	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"cmp %%r8d, %%r9d	\n"
"mov %%r8d, %%edx	\n"
"cmovg %%r9d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"mov %%edx, %%r8d	\n"
"cmp %%edx, %%ecx	\n"
"cmovl %%ecx, %%r8d	\n"
"cmovl %%edx, %%ecx	\n"
"mov %%r9d, %%edx	\n"
"cmp %%eax, %%r9d	\n"
"cmovg %%eax, %%r9d	\n"
"cmovg %%edx, %%eax	\n"
"mov %%eax, %%edx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
