"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"mov %%r8d, %%edx	\n"
"cmp %%edx, %%eax	\n"
"cmovl %%eax, %%r8d	\n"
"cmovg %%eax, %%edx	\n"
"mov %%ecx, %%eax	\n"
"cmp %%ecx, %%r8d	\n"
"cmovg %%r8d, %%eax	\n"
"cmovg %%ecx, %%r8d	\n"
"cmp %%edx, %%ecx	\n"
"cmovl %%edx, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
