"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"mov %%eax, %%edx	\n"
"cmp %%ecx, %%eax	\n"
"cmovl %%ecx, %%eax	\n"
"cmovg %%ecx, %%edx	\n"
"cmp %%eax, %%r8d	\n"
"cmovl %%eax, %%ecx	\n"
"cmovl %%r8d, %%eax	\n"
"cmovg %%r8d, %%ecx	\n"
"cmp %%edx, %%r8d	\n"
"cmovg %%edx, %%r8d	\n"
"cmovl %%edx, %%eax	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
