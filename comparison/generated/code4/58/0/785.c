"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"cmp %%ecx, %%r9d	\n"
"mov %%r9d, %%edx	\n"
"cmovg %%ecx, %%r9d	\n"
"cmovg %%edx, %%ecx	\n"
"mov %%eax, %%edx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%r8d, %%edx	\n"
"cmovg %%eax, %%r8d	\n"
"mov %%edx, %%eax	\n"
"cmp %%edx, %%ecx	\n"
"cmovl %%ecx, %%eax	\n"
"cmovl %%edx, %%ecx	\n"
"mov %%r9d, %%edx	\n"
"cmp %%edx, %%r8d	\n"
"cmovl %%r8d, %%r9d	\n"
"cmovg %%r8d, %%edx	\n"
"cmovl %%edx, %%r8d	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%eax, %%r8d	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
