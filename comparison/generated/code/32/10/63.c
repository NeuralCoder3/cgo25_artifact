"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"mov %%r8d, %%edx	\n"
"cmp %%edx, %%eax	\n"
"cmovg %%eax, %%edx	\n"
"cmovg %%r8d, %%eax	\n"
"mov %%ecx, %%r8d	\n"
"cmp %%edx, %%r8d	\n"
"cmovl %%edx, %%ecx	\n"
"cmovl %%r8d, %%edx	\n"
"cmp %%edx, %%eax	\n"
"cmovl %%eax, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"