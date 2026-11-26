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

	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
.LCPI1_0:
	.byte	17
	.byte	99
	.byte	128
	.byte	255
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI1_1:
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
	inc	r8
	mov	ecx, r8d
	and	ecx, 7
	cmp	rax, 112
	jae	.LBB1_14
	xor	eax, eax
	jmp	.LBB1_5
.LBB1_1:
	xor	eax, eax
	jmp	.LBB1_7
.LBB1_14:
	and	r8, -8
	neg	r8
	xor	eax, eax
	vbroadcastss	xmm0, dword ptr [rip + .LCPI1_0]
	.p2align	4
.LBB1_15:
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax]
	vmovups	xmmword ptr [rdi + rax], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 16]
	vmovups	xmmword ptr [rdi + rax + 16], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 32]
	vmovups	xmmword ptr [rdi + rax + 32], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 48]
	vmovups	xmmword ptr [rdi + rax + 48], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 64]
	vmovups	xmmword ptr [rdi + rax + 64], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 80]
	vmovups	xmmword ptr [rdi + rax + 80], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 96]
	vmovups	xmmword ptr [rdi + rax + 96], xmm1
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax + 112]
	vmovups	xmmword ptr [rdi + rax + 112], xmm1
	sub	rax, -128
	add	r8, 8
	jne	.LBB1_15
	test	rcx, rcx
	je	.LBB1_7
.LBB1_5:
	vbroadcastss	xmm0, dword ptr [rip + .LCPI1_0]
	.p2align	4
.LBB1_6:
	vxorps	xmm1, xmm0, xmmword ptr [rdx + rax]
	vmovups	xmmword ptr [rdi + rax], xmm1
	add	rax, 16
	dec	rcx
	jne	.LBB1_6
.LBB1_7:
	mov	rcx, rax
	sub	rcx, rsi
	jae	.LBB1_13
	mov	r8d, esi
	sub	r8d, eax
	and	r8d, 3
	je	.LBB1_10
	.p2align	4
.LBB1_9:
	mov	r9d, eax
	and	r9d, 3
	movzx	r9d, byte ptr [r9 + .L__anon_203]
	xor	r9b, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], r9b
	inc	rax
	dec	r8
	jne	.LBB1_9
.LBB1_10:
	cmp	rcx, -4
	ja	.LBB1_13
	mov	r9d, eax
	and	r9d, 3
	lea	r8d, [rax + 1]
	and	r8d, 3
	lea	r10d, [rax - 1]
	and	r10d, 3
	movzx	ecx, byte ptr [r9 + .L__anon_203]
	xor	r9, 2
	movzx	r8d, byte ptr [r8 + .L__anon_203]
	movzx	r9d, byte ptr [r9 + .L__anon_203]
	movzx	r10d, byte ptr [r10 + .L__anon_203]
	.p2align	4
.LBB1_12:
	movzx	r11d, byte ptr [rdx + rax]
	xor	r11b, cl
	mov	byte ptr [rdi + rax], r11b
	movzx	r11d, byte ptr [rdx + rax + 1]
	xor	r11b, r8b
	mov	byte ptr [rdi + rax + 1], r11b
	movzx	r11d, byte ptr [rdx + rax + 2]
	xor	r11b, r9b
	mov	byte ptr [rdi + rax + 2], r11b
	movzx	r11d, byte ptr [rdx + rax + 3]
	xor	r11b, r10b
	mov	byte ptr [rdi + rax + 3], r11b
	add	rax, 4
	cmp	rsi, rax
	jne	.LBB1_12
.LBB1_13:
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
	inc	r9
	mov	r8d, r9d
	and	r8d, 7
	cmp	rax, 56
	jae	.LBB3_13
	xor	eax, eax
	jmp	.LBB3_5
.LBB3_1:
	xor	eax, eax
	jmp	.LBB3_6
.LBB3_13:
	and	r9, -8
	neg	r9
	xor	eax, eax
	.p2align	4
.LBB3_14:
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
	mov	r10, qword ptr [rdx + rax + 32]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 32], r10
	mov	r10, qword ptr [rdx + rax + 40]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 40], r10
	mov	r10, qword ptr [rdx + rax + 48]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 48], r10
	mov	r10, qword ptr [rdx + rax + 56]
	xor	r10, rcx
	mov	qword ptr [rdi + rax + 56], r10
	add	rax, 64
	add	r9, 8
	jne	.LBB3_14
	test	r8, r8
	je	.LBB3_6
	.p2align	4
.LBB3_5:
	mov	r9, qword ptr [rdx + rax]
	xor	r9, rcx
	mov	qword ptr [rdi + rax], r9
	add	rax, 8
	dec	r8
	jne	.LBB3_5
.LBB3_6:
	mov	rcx, rax
	sub	rcx, rsi
	jae	.LBB3_12
	mov	r8d, esi
	sub	r8d, eax
	and	r8d, 3
	je	.LBB3_9
	.p2align	4
.LBB3_8:
	mov	r9d, eax
	and	r9d, 3
	movzx	r9d, byte ptr [r9 + .L__anon_203]
	xor	r9b, byte ptr [rdx + rax]
	mov	byte ptr [rdi + rax], r9b
	inc	rax
	dec	r8
	jne	.LBB3_8
.LBB3_9:
	cmp	rcx, -4
	ja	.LBB3_12
	mov	r9d, eax
	and	r9d, 3
	lea	r8d, [rax + 1]
	and	r8d, 3
	lea	r10d, [rax - 1]
	and	r10d, 3
	movzx	ecx, byte ptr [r9 + .L__anon_203]
	xor	r9, 2
	movzx	r8d, byte ptr [r8 + .L__anon_203]
	movzx	r9d, byte ptr [r9 + .L__anon_203]
	movzx	r10d, byte ptr [r10 + .L__anon_203]
	.p2align	4
.LBB3_11:
	movzx	r11d, byte ptr [rdx + rax]
	xor	r11b, cl
	mov	byte ptr [rdi + rax], r11b
	movzx	r11d, byte ptr [rdx + rax + 1]
	xor	r11b, r8b
	mov	byte ptr [rdi + rax + 1], r11b
	movzx	r11d, byte ptr [rdx + rax + 2]
	xor	r11b, r9b
	mov	byte ptr [rdi + rax + 2], r11b
	movzx	r11d, byte ptr [rdx + rax + 3]
	xor	r11b, r10b
	mov	byte ptr [rdi + rax + 3], r11b
	add	rax, 4
	cmp	rsi, rax
	jne	.LBB3_11
.LBB3_12:
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
	mov	eax, esi
	and	eax, 3
	cmp	rsi, 4
	jae	.LBB5_3
	xor	esi, esi
	jmp	.LBB5_11
.LBB5_3:
	lea	r8, [rsi - 4]
	shr	r8, 2
	je	.LBB5_4
	inc	r8
	mov	r9, r8
	and	r9, -2
	xor	ecx, ecx
	.p2align	4
.LBB5_6:
	movzx	r10d, byte ptr [rdx + rcx]
	xor	r10b, 17
	mov	byte ptr [rdi + rcx], r10b
	movzx	r10d, byte ptr [rdx + rcx + 1]
	xor	r10b, 99
	mov	byte ptr [rdi + rcx + 1], r10b
	movzx	r10d, byte ptr [rdx + rcx + 2]
	add	r10b, -128
	mov	byte ptr [rdi + rcx + 2], r10b
	movzx	r10d, byte ptr [rdx + rcx + 3]
	not	r10b
	mov	byte ptr [rdi + rcx + 3], r10b
	movzx	r10d, byte ptr [rdx + rcx + 4]
	xor	r10b, 17
	mov	byte ptr [rdi + rcx + 4], r10b
	movzx	r10d, byte ptr [rdx + rcx + 5]
	xor	r10b, 99
	mov	byte ptr [rdi + rcx + 5], r10b
	movzx	r10d, byte ptr [rdx + rcx + 6]
	add	r10b, -128
	mov	byte ptr [rdi + rcx + 6], r10b
	movzx	r10d, byte ptr [rdx + rcx + 7]
	not	r10b
	mov	byte ptr [rdi + rcx + 7], r10b
	add	rcx, 8
	add	r9, -2
	jne	.LBB5_6
	test	r8b, 1
	jne	.LBB5_8
	test	rax, rax
	jne	.LBB5_10
	jmp	.LBB5_12
.LBB5_4:
	xor	ecx, ecx
.LBB5_8:
	movzx	r8d, byte ptr [rdx + rcx]
	xor	r8b, 17
	mov	byte ptr [rdi + rcx], r8b
	movzx	r8d, byte ptr [rdx + rcx + 1]
	xor	r8b, 99
	mov	byte ptr [rdi + rcx + 1], r8b
	movzx	r8d, byte ptr [rdx + rcx + 2]
	add	r8b, -128
	mov	byte ptr [rdi + rcx + 2], r8b
	movzx	r8d, byte ptr [rdx + rcx + 3]
	not	r8b
	mov	byte ptr [rdi + rcx + 3], r8b
	test	rax, rax
	je	.LBB5_12
.LBB5_10:
	and	rsi, -4
	.p2align	4
.LBB5_11:
	mov	ecx, esi
	and	ecx, 3
	movzx	ecx, byte ptr [rcx + .L__anon_203]
	xor	cl, byte ptr [rdx + rsi]
	mov	byte ptr [rdi + rsi], cl
	inc	rsi
	dec	rax
	jne	.LBB5_11
.LBB5_12:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end5:
	.size	.Lsimd_candidates.maskCopy__func_2, .Lfunc_end5-.Lsimd_candidates.maskCopy__func_2
	.cfi_endproc

	.section	.rodata.cst32,"aM",@progbits,32
	.p2align	5, 0x0
.LCPI6_0:
	.zero	32,13
.LCPI6_1:
	.zero	32,31
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
	.byte	16
	.byte	17
	.byte	18
	.byte	19
	.byte	20
	.byte	21
	.byte	22
	.byte	23
	.byte	24
	.byte	25
	.byte	26
	.byte	27
	.byte	28
	.byte	29
	.byte	30
	.byte	31
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI6_3:
	.zero	16,13
.LCPI6_4:
	.zero	16,15
.LCPI6_5:
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
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
.LCPI6_6:
	.zero	4,13
.LCPI6_7:
	.zero	4,31
.LCPI6_8:
	.zero	4,15
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
	cmp	rsi, 65
	jb	.LBB6_3
	xor	ecx, ecx
	vpbroadcastd	ymm0, dword ptr [rip + .LCPI6_6]
	.p2align	4
.LBB6_12:
	vmovdqu	ymm1, ymmword ptr [rdi + rcx]
	vpcmpeqb	ymm2, ymm1, ymm0
	vpmovmskb	edx, ymm2
	test	edx, edx
	jne	.LBB6_13
	vmovdqu	ymm1, ymmword ptr [rdi + rcx + 32]
	vpcmpeqb	ymm2, ymm1, ymm0
	vpmovmskb	edx, ymm2
	test	edx, edx
	jne	.LBB6_15
	lea	rdx, [rcx + 64]
	sub	rcx, -128
	cmp	rcx, rax
	mov	rcx, rdx
	jb	.LBB6_12
	lea	rcx, [rdx + 32]
	cmp	rcx, rax
	jae	.LBB6_5
.LBB6_17:
	vmovdqu	ymm0, ymmword ptr [rdi + rdx]
	vpcmpeqb	ymm0, ymm0, ymmword ptr [rip + .LCPI6_0]
	vpmovmskb	esi, ymm0
	test	esi, esi
	je	.LBB6_6
	vpbroadcastd	ymm1, dword ptr [rip + .LCPI6_7]
	vpblendvb	ymm0, ymm1, ymmword ptr [rip + .LCPI6_2], ymm0
	vextracti128	xmm2, ymm0, 1
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 238
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 85
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrld	xmm2, xmm0, 16
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrlw	xmm2, xmm0, 8
	vpand	xmm1, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm1
	vpextrb	eax, xmm0, 0
	add	rdx, rax
	mov	rax, rdx
	pop	rbp
	.cfi_def_cfa rsp, 8
	vzeroupper
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
	lea	rcx, [rdx + 32]
	cmp	rcx, rax
	jb	.LBB6_17
.LBB6_5:
	mov	rcx, rdx
.LBB6_6:
	lea	rdx, [rcx + 16]
	cmp	rdx, rax
	jae	.LBB6_7
	vmovdqu	xmm0, xmmword ptr [rdi + rcx]
	vpcmpeqb	xmm0, xmm0, xmmword ptr [rip + .LCPI6_3]
	vpmovmskb	esi, xmm0
	test	esi, esi
	je	.LBB6_8
	vpbroadcastd	xmm1, dword ptr [rip + .LCPI6_8]
	vpblendvb	xmm0, xmm1, xmmword ptr [rip + .LCPI6_5], xmm0
	vpshufd	xmm2, xmm0, 238
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 85
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrld	xmm2, xmm0, 16
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrlw	xmm2, xmm0, 8
	vpand	xmm1, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm1
	vpextrb	eax, xmm0, 0
	add	rcx, rax
	mov	rax, rcx
	pop	rbp
	.cfi_def_cfa rsp, 8
	vzeroupper
	ret
.LBB6_7:
	.cfi_def_cfa rbp, 16
	mov	rdx, rcx
	jmp	.LBB6_8
	.p2align	4
.LBB6_9:
	cmp	byte ptr [rdi + rdx], 13
	je	.LBB6_10
	inc	rdx
.LBB6_8:
	cmp	rax, rdx
	jne	.LBB6_9
	pop	rbp
	.cfi_def_cfa rsp, 8
	vzeroupper
	ret
.LBB6_13:
	.cfi_def_cfa rbp, 16
	vpcmpeqb	ymm0, ymm1, ymmword ptr [rip + .LCPI6_0]
	vpbroadcastd	ymm1, dword ptr [rip + .LCPI6_7]
	vpblendvb	ymm0, ymm1, ymmword ptr [rip + .LCPI6_2], ymm0
	vextracti128	xmm2, ymm0, 1
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 238
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 85
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrld	xmm2, xmm0, 16
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrlw	xmm2, xmm0, 8
	vpand	xmm1, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm1
	vpextrb	eax, xmm0, 0
	add	rax, rcx
	pop	rbp
	.cfi_def_cfa rsp, 8
	vzeroupper
	ret
.LBB6_15:
	.cfi_def_cfa rbp, 16
	vpcmpeqb	ymm0, ymm1, ymmword ptr [rip + .LCPI6_0]
	vpbroadcastd	ymm1, dword ptr [rip + .LCPI6_7]
	vpblendvb	ymm0, ymm1, ymmword ptr [rip + .LCPI6_2], ymm0
	vextracti128	xmm2, ymm0, 1
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 238
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpshufd	xmm2, xmm0, 85
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrld	xmm2, xmm0, 16
	vpand	xmm2, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm2
	vpsrlw	xmm2, xmm0, 8
	vpand	xmm1, xmm2, xmm1
	vpminub	xmm0, xmm0, xmm1
	vpextrb	eax, xmm0, 0
	lea	rax, [rax + rcx + 32]
	pop	rbp
	.cfi_def_cfa rsp, 8
	vzeroupper
	ret
.LBB6_10:
	.cfi_def_cfa rbp, 16
	mov	rax, rdx
	pop	rbp
	.cfi_def_cfa rsp, 8
	vzeroupper
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
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
.LCPI8_5:
	.zero	4,31
.LCPI8_6:
	.zero	4,9
.LCPI8_7:
	.zero	4,127
.LCPI8_8:
	.zero	4,15
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
	vpbroadcastd	xmm0, dword ptr [rip + .LCPI8_5]
	vpbroadcastd	xmm1, dword ptr [rip + .LCPI8_6]
	vpbroadcastd	xmm2, dword ptr [rip + .LCPI8_7]
	mov	rsi, rdi
	.p2align	4
.LBB8_2:
	vmovdqu	xmm3, xmmword ptr [rsi]
	vpminub	xmm4, xmm3, xmm0
	vpcmpeqb	xmm4, xmm3, xmm4
	vpcmpeqb	xmm5, xmm3, xmm1
	vpandn	xmm4, xmm5, xmm4
	vpcmpeqb	xmm3, xmm3, xmm2
	vpor	xmm3, xmm3, xmm4
	vpmovmskb	r8d, xmm3
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
	inc	rdx
	dec	rcx
	jne	.LBB8_6
.LBB8_9:
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB8_10:
	.cfi_def_cfa rbp, 16
	vpbroadcastd	xmm0, dword ptr [rip + .LCPI8_8]
	vpblendvb	xmm1, xmm0, xmmword ptr [rip + .LCPI8_4], xmm3
	vpshufd	xmm2, xmm1, 238
	vpminub	xmm1, xmm1, xmm2
	vpshufd	xmm2, xmm1, 85
	vpand	xmm2, xmm2, xmm0
	vpminub	xmm1, xmm1, xmm2
	vpsrld	xmm2, xmm1, 16
	vpand	xmm2, xmm2, xmm0
	vpminub	xmm1, xmm1, xmm2
	vpsrlw	xmm2, xmm1, 8
	vpand	xmm0, xmm2, xmm0
	vpminub	xmm0, xmm1, xmm0
	vpextrb	eax, xmm0, 0
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
	inc	rax
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
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
.LCPI12_5:
	.zero	4,31
.LCPI12_6:
	.zero	4,34
.LCPI12_7:
	.zero	4,92
.LCPI12_8:
	.zero	4,15
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
	vpbroadcastd	xmm0, dword ptr [rip + .LCPI12_5]
	vpbroadcastd	xmm1, dword ptr [rip + .LCPI12_6]
	vpbroadcastd	xmm2, dword ptr [rip + .LCPI12_7]
	mov	rsi, rdi
	.p2align	4
.LBB12_2:
	vmovdqu	xmm3, xmmword ptr [rsi]
	vpminub	xmm4, xmm3, xmm0
	vpcmpeqb	xmm4, xmm3, xmm4
	vpcmpeqb	xmm5, xmm3, xmm1
	vpcmpeqb	xmm3, xmm3, xmm2
	vpor	xmm3, xmm5, xmm3
	vpor	xmm3, xmm3, xmm4
	vpmovmskb	r8d, xmm3
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
	inc	rdx
	dec	rcx
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
	vpbroadcastd	xmm0, dword ptr [rip + .LCPI12_8]
	vpblendvb	xmm1, xmm0, xmmword ptr [rip + .LCPI12_4], xmm3
	vpshufd	xmm2, xmm1, 238
	vpminub	xmm1, xmm1, xmm2
	vpshufd	xmm2, xmm1, 85
	vpand	xmm2, xmm2, xmm0
	vpminub	xmm1, xmm1, xmm2
	vpsrld	xmm2, xmm1, 16
	vpand	xmm2, xmm2, xmm0
	vpminub	xmm1, xmm1, xmm2
	vpsrlw	xmm2, xmm1, 8
	vpand	xmm0, xmm2, xmm0
	vpminub	xmm0, xmm1, xmm0
	vpextrb	eax, xmm0, 0
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
	inc	rax
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
