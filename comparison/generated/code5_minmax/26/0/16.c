"movd (%0), %%xmm0	\n"
"movd 4(%0), %%xmm1	\n"
"movd 8(%0), %%xmm2	\n"
"movd 0xc(%0), %%xmm3	\n"
"movd 0x10(%0), %%xmm4	\n"
"movdqa %%xmm0, %%xmm5	\n"
"pminud %%xmm3, %%xmm0	\n"
"pmaxud %%xmm5, %%xmm3	\n"
"movdqa %%xmm0, %%xmm5	\n"
"pminud %%xmm1, %%xmm0	\n"
"pmaxud %%xmm5, %%xmm1	\n"
"movdqa %%xmm3, %%xmm5	\n"
"pminud %%xmm1, %%xmm3	\n"
"pmaxud %%xmm5, %%xmm1	\n"
"movdqa %%xmm0, %%xmm5	\n"
"pminud %%xmm2, %%xmm0	\n"
"pmaxud %%xmm5, %%xmm2	\n"
"pmaxud %%xmm2, %%xmm5	\n"
"pminud %%xmm1, %%xmm2	\n"
"pmaxud %%xmm5, %%xmm1	\n"
"pminud %%xmm3, %%xmm5	\n"
"pmaxud %%xmm2, %%xmm3	\n"
"movdqa %%xmm4, %%xmm2	\n"
"pmaxud %%xmm1, %%xmm4	\n"
"pminud %%xmm2, %%xmm1	\n"
"pminud %%xmm3, %%xmm2	\n"
"pmaxud %%xmm0, %%xmm1	\n"
"pminud %%xmm2, %%xmm0	\n"
"pmaxud %%xmm1, %%xmm3	\n"
"pminud %%xmm5, %%xmm1	\n"
"pmaxud %%xmm5, %%xmm2	\n"
"movd %%xmm0, (%0)	\n"
"movd %%xmm1, 4(%0)	\n"
"movd %%xmm2, 8(%0)	\n"
"movd %%xmm3, 0xc(%0)	\n"
"movd %%xmm4, 0x10(%0)	\n"
