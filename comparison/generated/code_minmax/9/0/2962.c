"movd (%0), %%xmm0	\n"
"movd 4(%0), %%xmm1	\n"
"movd 8(%0), %%xmm2	\n"
"pmaxud %%xmm2, %%xmm3	\n"
"pminud %%xmm1, %%xmm3	\n"
"pmaxud %%xmm1, %%xmm2	\n"
"movdqa %%xmm0, %%xmm1	\n"
"pmaxud %%xmm3, %%xmm1	\n"
"pminud %%xmm0, %%xmm3	\n"
"pminud %%xmm2, %%xmm1	\n"
"pmaxud %%xmm0, %%xmm2	\n"
"movdqa %%xmm3, %%xmm0	\n"
"movd %%xmm0, (%0)	\n"
"movd %%xmm1, 4(%0)	\n"
"movd %%xmm2, 8(%0)	\n"
