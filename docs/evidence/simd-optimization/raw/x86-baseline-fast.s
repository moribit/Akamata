	.intel_syntax noprefix
	.file	"simd-codegen"
	.text
	.p2align	4
	.type	.Lsimd_codegen.mask_vector,@function
.Lsimd_codegen.mask_vector:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	rax, rsi
	mov	rsi, rdx
	mov	rdx, rax
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.maskCopy__func_0
.Lfunc_end0:
	.size	.Lsimd_codegen.mask_vector, .Lfunc_end0-.Lsimd_codegen.mask_vector
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI1_0:
	.byte	17
	.byte	99
	.byte	128
	.byte	255
	.byte	17
	.byte	99
	.byte	128
	.byte	255
	.byte	17
	.byte	99
	.byte	128
	.byte	255
	.byte	17
	.byte	99
	.byte	128
	.byte	255
	.text
	.p2align	4
	.type	.Lsimd_candidates.maskCopy__func_0,@function
.Lsimd_candidates.maskCopy__func_0:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	cmp	rsi, 16
	jb	.LBB1_1
	lea	rax, [rsi - 16]
	mov	r8, rax
	shr	r8, 4
	add	r8, 1
	mov	ecx, r8d
	and	ecx, 3
	cmp	rax, 48
	jae	.LBB1_13
	xor	eax, eax
	jmp	.LBB1_5
.LBB1_1:
	xor	eax, eax
	jmp	.LBB1_7
.LBB1_13:
	and	r8, -4
	neg	r8
	xor	eax, eax
	movaps	xmm0, xmmword ptr [rip + .LCPI1_0]
	.p2align	4
.LBB1_14:
	movups	xmm1, xmmword ptr [rdx + rax]
	xorps	xmm1, xmm0
	movups	xmmword ptr [rdi + rax], xmm1
	movups	xmm1, xmmword ptr [rdx + rax + 16]
	xorps	xmm1, xmm0
	movups	xmmword ptr [rdi + rax + 16], xmm1
	movups	xmm1, xmmword ptr [rdx + rax + 32]
	xorps	xmm1, xmm0
	movups	xmmword ptr [rdi + rax + 32], xmm1
	movups	xmm1, xmmword ptr [rdx + rax + 48]
	xorps	xmm1, xmm0
	movups	xmmword ptr [rdi + rax + 48], xmm1
	add	rax, 64
	add	r8, 4
	jne	.LBB1_14
	test	rcx, rcx
	je	.LBB1_7
.LBB1_5:
	movaps	xmm0, xmmword ptr [rip + .LCPI1_0]
	.p2align	4
.LBB1_6:
	movups	xmm1, xmmword ptr [rdx + rax]
	xorps	xmm1, xmm0
	movups	xmmword ptr [rdi + rax], xmm1
	add	rax, 16
	add	rcx, -1
	jne	.LBB1_6
.LBB1_7:
	cmp	rsi, rax
	jbe	.LBB1_12
	mov	r8d, esi
	sub	r8d, eax
	lea	rcx, [rax + 1]
	test	r8b, 1
	je	.LBB1_10
	mov	r8d, eax
	and	r8d, 3
	movzx	r8d, byte ptr [r8 + .L__anon_203]
	xor	r8b, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], r8b
	mov	rax, rcx
.LBB1_10:
	cmp	rsi, rcx
	je	.LBB1_12
	.p2align	4
.LBB1_11:
	mov	ecx, eax
	and	ecx, 3
	movzx	ecx, byte ptr [rcx + .L__anon_203]
	xor	cl, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], cl
	lea	ecx, [rax + 1]
	and	ecx, 3
	movzx	ecx, byte ptr [rcx + .L__anon_203]
	xor	cl, byte ptr [rdx + rax + 1]
	mov	byte ptr [rdi + rax + 1], cl
	add	rax, 2
	cmp	rsi, rax
	jne	.LBB1_11
.LBB1_12:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end1:
	.size	.Lsimd_candidates.maskCopy__func_0, .Lfunc_end1-.Lsimd_candidates.maskCopy__func_0
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_codegen.mask_word,@function
.Lsimd_codegen.mask_word:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	rax, rsi
	mov	rsi, rdx
	mov	rdx, rax
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.maskCopy__func_1
.Lfunc_end2:
	.size	.Lsimd_codegen.mask_word, .Lfunc_end2-.Lsimd_codegen.mask_word
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_candidates.maskCopy__func_1,@function
.Lsimd_candidates.maskCopy__func_1:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	cmp	rsi, 8
	jb	.LBB3_1
	movabs	rcx, -35919868066766063
	lea	rax, [rsi - 8]
	mov	r9, rax
	shr	r9, 3
	add	r9, 1
	mov	r8d, r9d
	and	r8d, 3
	cmp	rax, 24
	jae	.LBB3_12
	xor	eax, eax
	jmp	.LBB3_5
.LBB3_1:
	xor	eax, eax
	jmp	.LBB3_6
.LBB3_12:
	and	r9, -4
	neg	r9
	xor	eax, eax
	.p2align	4
.LBB3_13:
	mov	r10, qword ptr [rdx + rax]
	xor	r10, rcx
	mov	qword ptr [rdi + rax], r10
	mov	r10, qword ptr [rdx + rax + 8]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 8], r10
	mov	r10, qword ptr [rdx + rax + 16]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 16], r10
	mov	r10, qword ptr [rdx + rax + 24]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 24], r10
	add	rax, 32
	add	r9, 4
	jne	.LBB3_13
	test	r8, r8
	je	.LBB3_6
	.p2align	4
.LBB3_5:
	mov	r9, qword ptr [rdx + rax]
	xor	r9, rcx
	mov	qword ptr [rdi + rax], r9
	add	rax, 8
	add	r8, -1
	jne	.LBB3_5
.LBB3_6:
	cmp	rsi, rax
	jbe	.LBB3_11
	mov	r8d, esi
	sub	r8d, eax
	lea	rcx, [rax + 1]
	test	r8b, 1
	je	.LBB3_9
	mov	r8d, eax
	and	r8d, 3
	movzx	r8d, byte ptr [r8 + .L__anon_203]
	xor	r8b, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], r8b
	mov	rax, rcx
.LBB3_9:
	cmp	rsi, rcx
	je	.LBB3_11
	.p2align	4
.LBB3_10:
	mov	ecx, eax
	and	ecx, 3
	movzx	ecx, byte ptr [rcx + .L__anon_203]
	xor	cl, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], cl
	lea	ecx, [rax + 1]
	and	ecx, 3
	movzx	ecx, byte ptr [rcx + .L__anon_203]
	xor	cl, byte ptr [rdx + rax + 1]
	mov	byte ptr [rdi + rax + 1], cl
	add	rax, 2
	cmp	rsi, rax
	jne	.LBB3_10
.LBB3_11:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end3:
	.size	.Lsimd_candidates.maskCopy__func_1, .Lfunc_end3-.Lsimd_candidates.maskCopy__func_1
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_codegen.mask_byte,@function
.Lsimd_codegen.mask_byte:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	rax, rsi
	mov	rsi, rdx
	mov	rdx, rax
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.maskCopy__func_2
.Lfunc_end4:
	.size	.Lsimd_codegen.mask_byte, .Lfunc_end4-.Lsimd_codegen.mask_byte
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_candidates.maskCopy__func_2,@function
.Lsimd_candidates.maskCopy__func_2:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	test	rsi, rsi
	je	.LBB5_12
	cmp	rsi, 1
	jne	.LBB5_3
	xor	esi, esi
	jmp	.LBB5_11
.LBB5_3:
	lea	rcx, [rsi - 2]
	shr	rcx
	je	.LBB5_4
	add	rcx, 1
	mov	r8, rcx
	and	r8, -2
	xor	eax, eax
	.p2align	4
.LBB5_6:
	movzx	r9d, byte ptr [rdx + rax]
	xor	r9b, 17
	mov	byte ptr [rdi + rax], r9b
	movzx	r9d, byte ptr [rdx + rax + 1]
	xor	r9b, 99
	mov	byte ptr [rdi + rax + 1], r9b
	movzx	r9d, byte ptr [rdx + rax + 2]
	add	r9b, -128
	mov	byte ptr [rdi + rax + 2], r9b
	movzx	r9d, byte ptr [rdx + rax + 3]
	not	r9b
	mov	byte ptr [rdi + rax + 3], r9b
	add	rax, 4
	add	r8, -2
	jne	.LBB5_6
	test	cl, 1
	jne	.LBB5_8
	test	sil, 1
	jne	.LBB5_10
.LBB5_12:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB5_4:
	.cfi_def_cfa rbp, 16
	xor	eax, eax
.LBB5_8:
	mov	ecx, eax
	and	ecx, 2
	movzx	r8d, byte ptr [rcx + .L__anon_203]
	xor	r8b, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], r8b
	movzx	ecx, byte ptr [rcx + .L__anon_203+1]
	xor	cl, byte ptr [rdx + rax + 1]
	mov	byte ptr [rdi + rax + 1], cl
	test	sil, 1
	je	.LBB5_12
.LBB5_10:
	and	rsi, -2
.LBB5_11:
	mov	eax, esi
	and	eax, 2
	movzx	eax, byte ptr [rax + .L__anon_203]
	xor	al, byte ptr [rdx + rsi]
	mov	byte ptr [rdi + rsi], al
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end5:
	.size	.Lsimd_candidates.maskCopy__func_2, .Lfunc_end5-.Lsimd_candidates.maskCopy__func_2
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI6_0:
	.zero	16,13
.LCPI6_1:
	.zero	16,15
.LCPI6_2:
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.byte	8
	.byte	9
	.byte	10
	.byte	11
	.byte	12
	.byte	13
	.byte	14
	.byte	15
.LCPI6_3:
	.byte	13
	.byte	13
	.byte	13
	.byte	13
	.byte	13
	.byte	13
	.byte	13
	.byte	13
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
.LCPI6_4:
	.short	7
	.short	7
	.short	7
	.short	7
	.short	7
	.short	7
	.short	7
	.short	7
.LCPI6_5:
	.short	0
	.short	1
	.short	2
	.short	3
	.short	4
	.short	5
	.short	6
	.short	7
	.text
	.p2align	4
	.type	.Lsimd_codegen.std_search,@function
.Lsimd_codegen.std_search:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	test	rsi, rsi
	je	.LBB6_1
	mov	rax, rsi
	cmp	rsi, 33
	jb	.LBB6_3
	xor	ecx, ecx
	movdqa	xmm0, xmmword ptr [rip + .LCPI6_0]
	.p2align	4
.LBB6_12:
	movdqu	xmm1, xmmword ptr [rdi + rcx]
	movdqa	xmm2, xmm1
	pcmpeqb	xmm2, xmm0
	pmovmskb	edx, xmm2
	test	edx, edx
	jne	.LBB6_13
	movdqu	xmm1, xmmword ptr [rdi + rcx + 16]
	movdqa	xmm2, xmm1
	pcmpeqb	xmm2, xmm0
	pmovmskb	edx, xmm2
	test	edx, edx
	jne	.LBB6_15
	lea	rdx, [rcx + 32]
	add	rcx, 64
	cmp	rcx, rax
	mov	rcx, rdx
	jb	.LBB6_12
	lea	rcx, [rdx + 16]
	cmp	rcx, rax
	jae	.LBB6_5
.LBB6_17:
	movdqu	xmm0, xmmword ptr [rdi + rdx]
	pcmpeqb	xmm0, xmmword ptr [rip + .LCPI6_0]
	pmovmskb	esi, xmm0
	test	esi, esi
	je	.LBB6_6
	movdqa	xmm1, xmmword ptr [rip + .LCPI6_1]
	movdqa	xmm2, xmm0
	pand	xmm0, xmmword ptr [rip + .LCPI6_2]
	pandn	xmm2, xmm1
	por	xmm0, xmm2
	pshufd	xmm2, xmm0, 238
	pand	xmm2, xmm1
	pminub	xmm2, xmm0
	pshufd	xmm0, xmm2, 85
	pand	xmm0, xmm1
	pminub	xmm0, xmm2
	movdqa	xmm2, xmm0
	psrld	xmm2, 16
	pand	xmm2, xmm1
	pminub	xmm2, xmm0
	movdqa	xmm0, xmm2
	psrlw	xmm0, 8
	pand	xmm0, xmm1
	pminub	xmm0, xmm2
	movd	eax, xmm0
	movzx	eax, ax
	add	rdx, rax
	mov	rax, rdx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB6_1:
	.cfi_def_cfa rbp, 16
	xor	eax, eax
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB6_3:
	.cfi_def_cfa rbp, 16
	xor	edx, edx
	lea	rcx, [rdx + 16]
	cmp	rcx, rax
	jb	.LBB6_17
.LBB6_5:
	mov	rcx, rdx
.LBB6_6:
	lea	rdx, [rcx + 8]
	cmp	rdx, rax
	jae	.LBB6_7
	movq	xmm0, qword ptr [rdi + rcx]
	movdqa	xmm1, xmmword ptr [rip + .LCPI6_3]
	pcmpeqb	xmm1, xmm0
	pmovmskb	esi, xmm1
	test	sil, sil
	je	.LBB6_8
	punpcklbw	xmm0, xmm0
	pcmpeqb	xmm0, xmmword ptr [rip + .LCPI6_0]
	movdqa	xmm1, xmmword ptr [rip + .LCPI6_4]
	movdqa	xmm2, xmm0
	pand	xmm0, xmmword ptr [rip + .LCPI6_5]
	pandn	xmm2, xmm1
	por	xmm0, xmm2
	pshufd	xmm2, xmm0, 238
	pand	xmm2, xmm1
	pminsw	xmm2, xmm0
	pshufd	xmm0, xmm2, 85
	pand	xmm0, xmm1
	pminsw	xmm0, xmm2
	movdqa	xmm2, xmm0
	psrld	xmm2, 16
	pand	xmm2, xmm1
	pminsw	xmm2, xmm0
	pextrw	eax, xmm2, 0
	add	rcx, rax
	mov	rax, rcx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB6_7:
	.cfi_def_cfa rbp, 16
	mov	rdx, rcx
	jmp	.LBB6_8
	.p2align	4
.LBB6_9:
	cmp	byte ptr [rdi + rdx], 13
	je	.LBB6_10
	add	rdx, 1
.LBB6_8:
	cmp	rax, rdx
	jne	.LBB6_9
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB6_13:
	.cfi_def_cfa rbp, 16
	pcmpeqb	xmm1, xmmword ptr [rip + .LCPI6_0]
	movdqa	xmm0, xmmword ptr [rip + .LCPI6_1]
	movdqa	xmm2, xmm1
	pandn	xmm2, xmm0
	pand	xmm1, xmmword ptr [rip + .LCPI6_2]
	por	xmm1, xmm2
	pshufd	xmm2, xmm1, 238
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	pshufd	xmm1, xmm2, 85
	pand	xmm1, xmm0
	pminub	xmm1, xmm2
	movdqa	xmm2, xmm1
	psrld	xmm2, 16
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	movdqa	xmm1, xmm2
	psrlw	xmm1, 8
	pand	xmm1, xmm0
	pminub	xmm1, xmm2
	movd	eax, xmm1
	movzx	eax, ax
	add	rax, rcx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB6_15:
	.cfi_def_cfa rbp, 16
	pcmpeqb	xmm1, xmmword ptr [rip + .LCPI6_0]
	movdqa	xmm0, xmmword ptr [rip + .LCPI6_1]
	movdqa	xmm2, xmm1
	pandn	xmm2, xmm0
	pand	xmm1, xmmword ptr [rip + .LCPI6_2]
	por	xmm1, xmm2
	pshufd	xmm2, xmm1, 238
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	pshufd	xmm1, xmm2, 85
	pand	xmm1, xmm0
	pminub	xmm1, xmm2
	movdqa	xmm2, xmm1
	psrld	xmm2, 16
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	movdqa	xmm1, xmm2
	psrlw	xmm1, 8
	pand	xmm1, xmm0
	pminub	xmm1, xmm2
	movd	eax, xmm1
	movzx	eax, ax
	add	rax, rcx
	add	rax, 16
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB6_10:
	.cfi_def_cfa rbp, 16
	mov	rax, rdx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end6:
	.size	.Lsimd_codegen.std_search, .Lfunc_end6-.Lsimd_codegen.std_search
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_codegen.field_vector,@function
.Lsimd_codegen.field_vector:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.find__func_8
.Lfunc_end7:
	.size	.Lsimd_codegen.field_vector, .Lfunc_end7-.Lsimd_codegen.field_vector
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI8_0:
	.zero	16,31
.LCPI8_1:
	.zero	16,9
.LCPI8_2:
	.zero	16,127
.LCPI8_3:
	.zero	16,15
.LCPI8_4:
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.byte	8
	.byte	9
	.byte	10
	.byte	11
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.text
	.p2align	4
	.type	.Lsimd_candidates.find__func_8,@function
.Lsimd_candidates.find__func_8:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	rax, rsi
	cmp	rsi, 16
	jb	.LBB8_5
	mov	rdx, rax
	and	rdx, -16
	xor	ecx, ecx
	movdqa	xmm0, xmmword ptr [rip + .LCPI8_0]
	movdqa	xmm1, xmmword ptr [rip + .LCPI8_1]
	movdqa	xmm2, xmmword ptr [rip + .LCPI8_2]
	mov	rsi, rdi
	.p2align	4
.LBB8_2:
	movdqu	xmm3, xmmword ptr [rsi]
	movdqa	xmm4, xmm3
	pminub	xmm4, xmm0
	pcmpeqb	xmm4, xmm3
	movdqa	xmm5, xmm3
	pcmpeqb	xmm5, xmm1
	pandn	xmm5, xmm4
	pcmpeqb	xmm3, xmm2
	por	xmm3, xmm5
	pmovmskb	r8d, xmm3
	test	r8d, r8d
	jne	.LBB8_10
	add	rsi, 16
	lea	r8, [rax + rcx]
	add	r8, -16
	add	rcx, -16
	cmp	r8, 15
	ja	.LBB8_2
	add	rcx, rax
	test	rcx, rcx
	jne	.LBB8_6
	jmp	.LBB8_9
.LBB8_5:
	xor	edx, edx
	mov	rcx, rax
	test	rcx, rcx
	je	.LBB8_9
	.p2align	4
.LBB8_6:
	movzx	r9d, byte ptr [rdi + rdx]
	cmp	r9b, 32
	setb	sil
	cmp	r9b, 9
	setne	r8b
	cmp	r9b, 127
	je	.LBB8_12
	and	sil, r8b
	jne	.LBB8_12
	add	rdx, 1
	add	rcx, -1
	jne	.LBB8_6
.LBB8_9:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB8_10:
	.cfi_def_cfa rbp, 16
	movdqa	xmm0, xmmword ptr [rip + .LCPI8_3]
	movdqa	xmm1, xmm3
	pandn	xmm1, xmm0
	pand	xmm3, xmmword ptr [rip + .LCPI8_4]
	por	xmm3, xmm1
	pshufd	xmm1, xmm3, 238
	pand	xmm1, xmm0
	pminub	xmm1, xmm3
	pshufd	xmm2, xmm1, 85
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	movdqa	xmm1, xmm2
	psrld	xmm1, 16
	pand	xmm1, xmm0
	pminub	xmm1, xmm2
	movdqa	xmm2, xmm1
	psrlw	xmm2, 8
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	movd	eax, xmm2
	movzx	eax, ax
	sub	rax, rcx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB8_12:
	.cfi_def_cfa rbp, 16
	mov	rax, rdx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end8:
	.size	.Lsimd_candidates.find__func_8, .Lfunc_end8-.Lsimd_candidates.find__func_8
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_codegen.field_scalar,@function
.Lsimd_codegen.field_scalar:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.find__func_10
.Lfunc_end9:
	.size	.Lsimd_codegen.field_scalar, .Lfunc_end9-.Lsimd_codegen.field_scalar
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_candidates.find__func_10,@function
.Lsimd_candidates.find__func_10:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	xor	eax, eax
	test	rsi, rsi
	je	.LBB10_5
	.p2align	4
.LBB10_1:
	movzx	r8d, byte ptr [rdi + rax]
	cmp	r8b, 32
	setb	cl
	cmp	r8b, 9
	setne	dl
	cmp	r8b, 127
	je	.LBB10_5
	and	cl, dl
	jne	.LBB10_5
	add	rax, 1
	cmp	rsi, rax
	jne	.LBB10_1
	mov	rax, rsi
.LBB10_5:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end10:
	.size	.Lsimd_candidates.find__func_10, .Lfunc_end10-.Lsimd_candidates.find__func_10
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_codegen.json_vector,@function
.Lsimd_codegen.json_vector:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.find__func_11
.Lfunc_end11:
	.size	.Lsimd_codegen.json_vector, .Lfunc_end11-.Lsimd_codegen.json_vector
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI12_0:
	.zero	16,31
.LCPI12_1:
	.zero	16,34
.LCPI12_2:
	.zero	16,92
.LCPI12_3:
	.zero	16,15
.LCPI12_4:
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.byte	8
	.byte	9
	.byte	10
	.byte	11
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.text
	.p2align	4
	.type	.Lsimd_candidates.find__func_11,@function
.Lsimd_candidates.find__func_11:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	rax, rsi
	cmp	rsi, 16
	jb	.LBB12_5
	mov	rdx, rax
	and	rdx, -16
	xor	ecx, ecx
	movdqa	xmm0, xmmword ptr [rip + .LCPI12_0]
	movdqa	xmm1, xmmword ptr [rip + .LCPI12_1]
	movdqa	xmm2, xmmword ptr [rip + .LCPI12_2]
	mov	rsi, rdi
	.p2align	4
.LBB12_2:
	movdqu	xmm3, xmmword ptr [rsi]
	movdqa	xmm4, xmm3
	pminub	xmm4, xmm0
	pcmpeqb	xmm4, xmm3
	movdqa	xmm5, xmm3
	pcmpeqb	xmm5, xmm1
	pcmpeqb	xmm3, xmm2
	por	xmm3, xmm5
	por	xmm3, xmm4
	pmovmskb	r8d, xmm3
	test	r8d, r8d
	jne	.LBB12_11
	add	rsi, 16
	lea	r8, [rax + rcx]
	add	r8, -16
	add	rcx, -16
	cmp	r8, 15
	ja	.LBB12_2
	add	rcx, rax
	test	rcx, rcx
	jne	.LBB12_6
	jmp	.LBB12_10
.LBB12_5:
	xor	edx, edx
	mov	rcx, rax
	test	rcx, rcx
	je	.LBB12_10
	.p2align	4
.LBB12_6:
	movzx	esi, byte ptr [rdi + rdx]
	cmp	sil, 32
	jb	.LBB12_12
	cmp	sil, 34
	je	.LBB12_12
	movzx	esi, sil
	cmp	esi, 92
	je	.LBB12_12
	add	rdx, 1
	add	rcx, -1
	jne	.LBB12_6
.LBB12_10:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB12_12:
	.cfi_def_cfa rbp, 16
	mov	rax, rdx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB12_11:
	.cfi_def_cfa rbp, 16
	movdqa	xmm0, xmmword ptr [rip + .LCPI12_3]
	movdqa	xmm1, xmm3
	pandn	xmm1, xmm0
	pand	xmm3, xmmword ptr [rip + .LCPI12_4]
	por	xmm3, xmm1
	pshufd	xmm1, xmm3, 238
	pand	xmm1, xmm0
	pminub	xmm1, xmm3
	pshufd	xmm2, xmm1, 85
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	movdqa	xmm1, xmm2
	psrld	xmm1, 16
	pand	xmm1, xmm0
	pminub	xmm1, xmm2
	movdqa	xmm2, xmm1
	psrlw	xmm2, 8
	pand	xmm2, xmm0
	pminub	xmm2, xmm1
	movd	eax, xmm2
	movzx	eax, ax
	sub	rax, rcx
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end12:
	.size	.Lsimd_candidates.find__func_11, .Lfunc_end12-.Lsimd_candidates.find__func_11
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_codegen.json_scalar,@function
.Lsimd_codegen.json_scalar:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	pop	rbp
	.cfi_def_cfa rsp, 8
	jmp	.Lsimd_candidates.find__func_13
.Lfunc_end13:
	.size	.Lsimd_codegen.json_scalar, .Lfunc_end13-.Lsimd_codegen.json_scalar
	.cfi_endproc

	.p2align	4
	.type	.Lsimd_candidates.find__func_13,@function
.Lsimd_candidates.find__func_13:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	xor	eax, eax
	test	rsi, rsi
	je	.LBB14_6
	.p2align	4
.LBB14_1:
	movzx	ecx, byte ptr [rdi + rax]
	cmp	cl, 32
	jb	.LBB14_6
	cmp	cl, 34
	je	.LBB14_6
	movzx	ecx, cl
	cmp	ecx, 92
	je	.LBB14_6
	add	rax, 1
	cmp	rsi, rax
	jne	.LBB14_1
	mov	rax, rsi
.LBB14_6:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end14:
	.size	.Lsimd_candidates.find__func_13, .Lfunc_end14-.Lsimd_candidates.find__func_13
	.cfi_endproc

	.type	.L__anon_203,@object
	.section	.rodata.cst4,"aM",@progbits,4
.L__anon_203:
	.ascii	"\021c\200\377"
	.size	.L__anon_203, 4

	.globl	mask_vector
	.type	mask_vector,@function
mask_vector = .Lsimd_codegen.mask_vector
	.globl	mask_word
	.type	mask_word,@function
mask_word = .Lsimd_codegen.mask_word
	.globl	mask_byte
	.type	mask_byte,@function
mask_byte = .Lsimd_codegen.mask_byte
	.globl	std_search
	.type	std_search,@function
std_search = .Lsimd_codegen.std_search
	.globl	field_vector
	.type	field_vector,@function
field_vector = .Lsimd_codegen.field_vector
	.globl	field_scalar
	.type	field_scalar,@function
field_scalar = .Lsimd_codegen.field_scalar
	.globl	json_vector
	.type	json_vector,@function
json_vector = .Lsimd_codegen.json_vector
	.globl	json_scalar
	.type	json_scalar,@function
json_scalar = .Lsimd_codegen.json_scalar
	.section	".note.GNU-stack","",@progbits
