"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%r8d, %%edx	\n"
"cmovl %%eax, %%edx	\n"
"cmovl %%r8d, %%eax	\n"
"cmp %%ecx, %%eax	\n"
"mov %%eax, %%r8d	\n"
"cmovg %%ecx, %%r8d	\n"
"cmovl %%ecx, %%eax	\n"
"cmp %%edx, %%eax	\n"
"cmovg %%edx, %%eax	\n"
"cmovl %%edx, %%ecx	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"