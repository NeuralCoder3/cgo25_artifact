"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"cmp %%ecx, %%r8d	\n"
"mov %%ecx, %%edx	\n"
"cmovg %%r8d, %%ecx	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r9d, %%edx	\n"
"cmp %%eax, %%r9d	\n"
"cmovg %%eax, %%r9d	\n"
"cmovl %%eax, %%edx	\n"
"mov %%edx, %%eax	\n"
"cmp %%edx, %%ecx	\n"
"cmovl %%ecx, %%eax	\n"
"cmovl %%edx, %%ecx	\n"
"mov %%r9d, %%edx	\n"
"cmp %%r8d, %%r9d	\n"
"cmovl %%r8d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"cmp %%edx, %%eax	\n"
"cmovl %%eax, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
