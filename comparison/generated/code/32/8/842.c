"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"cmp %%ecx, %%eax	\n"
"mov %%ecx, %%edx	\n"
"cmovl %%eax, %%edx	\n"
"cmovl %%ecx, %%eax	\n"
"mov %%eax, %%ecx	\n"
"cmp %%ecx, %%r8d	\n"
"cmovg %%r8d, %%ecx	\n"
"cmovl %%r8d, %%eax	\n"
"cmp %%edx, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
