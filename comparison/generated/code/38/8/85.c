"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"cmp %%ecx, %%eax	\n"
"cmovg %%ecx, %%edx	\n"
"cmovl %%eax, %%edx	\n"
"cmovg %%eax, %%ecx	\n"
"cmp %%ecx, %%r8d	\n"
"cmovg %%ecx, %%eax	\n"
"cmovl %%r8d, %%eax	\n"
"cmovg %%r8d, %%ecx	\n"
"cmp %%edx, %%eax	\n"
"cmovl %%edx, %%eax	\n"
"cmovg %%edx, %%r8d	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
