"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"mov %%r8d, %%edx	\n"
"cmp %%ecx, %%r8d	\n"
"cmovl %%ecx, %%edx	\n"
"cmovg %%ecx, %%r8d	\n"
"mov %%eax, %%ecx	\n"
"cmp %%eax, %%r8d	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%ecx, %%r8d	\n"
"cmp %%edx, %%eax	\n"
"cmovg %%edx, %%eax	\n"
"cmovl %%edx, %%ecx	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
