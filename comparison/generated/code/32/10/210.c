"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"mov %%eax, %%edx	\n"
"cmp %%edx, %%r8d	\n"
"cmovg %%r8d, %%eax	\n"
"cmovl %%r8d, %%edx	\n"
"mov %%edx, %%r8d	\n"
"cmp %%ecx, %%r8d	\n"
"cmovg %%ecx, %%r8d	\n"
"cmovl %%ecx, %%edx	\n"
"cmp %%edx, %%eax	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
