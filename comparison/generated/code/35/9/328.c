"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"cmp %%ecx, %%eax	\n"
"cmovl %%eax, %%edx	\n"
"cmovg %%ecx, %%edx	\n"
"cmovl %%ecx, %%eax	\n"
"cmp %%edx, %%r8d	\n"
"mov %%r8d, %%ecx	\n"
"cmovg %%edx, %%r8d	\n"
"cmovg %%ecx, %%edx	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%eax, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
