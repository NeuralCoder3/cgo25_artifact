"mov (%0), %%r9d	\n"
"mov 0x4(%0), %%r8d	\n"
"mov 0x8(%0), %%eax	\n"
"mov 0xc(%0), %%ecx	\n"
"cmp %%ecx, %%eax	\n"
"mov %%eax, %%edx	\n"
"cmovg %%ecx, %%eax	\n"
"cmovg %%edx, %%ecx	\n"
"mov %%r9d, %%edx	\n"
"cmp %%edx, %%r8d	\n"
"cmovl %%r8d, %%edx	\n"
"cmovl %%r9d, %%r8d	\n"
"mov %%edx, %%r9d	\n"
"cmp %%edx, %%eax	\n"
"cmovl %%eax, %%r9d	\n"
"cmovl %%edx, %%eax	\n"
"mov %%ecx, %%edx	\n"
"cmp %%ecx, %%r8d	\n"
"cmovl %%r8d, %%edx	\n"
"cmovg %%r8d, %%ecx	\n"
"cmp %%edx, %%eax	\n"
"mov %%edx, %%r8d	\n"
"cmovl %%eax, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"mov %%r9d, (%0)	\n"
"mov %%r8d, 0x4(%0)	\n"
"mov %%eax, 0x8(%0)	\n"
"mov %%ecx, 0xc(%0)	\n"
