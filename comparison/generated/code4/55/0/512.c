"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"mov %%r9d, %%edx	\n"
"cmp %%eax, %%r9d	\n"
"cmovg %%eax, %%r9d	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r8d, %%edx	\n"
"cmp %%edx, %%ecx	\n"
"cmovl %%ecx, %%r8d	\n"
"cmovl %%edx, %%ecx	\n"
"mov %%eax, %%edx	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%ecx, %%eax	\n"
"cmovg %%edx, %%ecx	\n"
"mov %%r8d, %%edx	\n"
"cmp %%r8d, %%r9d	\n"
"cmovg %%r9d, %%edx	\n"
"cmovg %%r8d, %%r9d	\n"
"cmp %%edx, %%eax	\n"
"mov %%edx, %%r8d	\n"
"cmovl %%eax, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
