"mov (%0), %%r8d	\n"
"mov 0x4(%0), %%eax	\n"
"mov 0x8(%0), %%ecx	\n"
"mov %%eax, %%edx	\n"
"cmp %%ecx, %%eax	\n"
"cmovl %%ecx, %%edx	\n"
"cmovg %%ecx, %%eax	\n"
"mov %%r8d, %%ecx	\n"
"cmp %%ecx, %%eax	\n"
"cmovl %%eax, %%r8d	\n"
"cmovl %%ecx, %%eax	\n"
"cmp %%edx, %%ecx	\n"
"cmovl %%edx, %%ecx	\n"
"cmovg %%edx, %%eax	\n"
"mov %%r8d, (%0)	\n"
"mov %%eax, 0x4(%0)	\n"
"mov %%ecx, 0x8(%0)	\n"
