"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"cmp %%r8d, %%r9d	\n"
"mov %%r8d, %%edx	\n"
"cmovg %%r9d, %%r8d	\n"
"cmovg %%edx, %%r9d	\n"
"mov %%ecx, %%edx	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%eax, %%ecx	\n"
"cmovl %%eax, %%edx	\n"
"mov %%edx, %%eax	\n"
"cmp %%edx, %%r9d	\n"
"cmovg %%r9d, %%eax	\n"
"cmovg %%edx, %%r9d	\n"
"cmp %%ecx, %%r8d	\n"
"cmovg %%ecx, %%edx	\n"
"cmovl %%r8d, %%edx	\n"
"cmovg %%r8d, %%ecx	\n"
"mov %%edx, %%r8d	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%eax, %%r8d	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
