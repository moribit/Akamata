	.file	"simd-codegen"
	.text
	.p2align	2
	.type	.Lsimd_codegen.mask_vector,@function
.Lsimd_codegen.mask_vector:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x1
	mov	x1, x2
	mov	x2, x8
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.maskCopy__func_0
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
	.p2align	2
	.type	.Lsimd_candidates.maskCopy__func_0,@function
.Lsimd_candidates.maskCopy__func_0:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cmp	x1, #16
	b.lo	.LBB1_4
	adrp	x9, .LCPI1_0
	mov	x8, xzr
	ldr	q0, [x9, :lo12:.LCPI1_0]
	mov	x9, x1
.LBB1_2:
	ldr	q1, [x2, x8]
	sub	x9, x9, #16
	cmp	x9, #15
	eor	v1.16b, v1.16b, v0.16b
	str	q1, [x0, x8]
	add	x8, x8, #16
	b.hi	.LBB1_2
	cmp	x8, x1
	b.lo	.LBB1_5
	b	.LBB1_7
.LBB1_4:
	mov	x8, xzr
	cmp	xzr, x1
	b.hs	.LBB1_7
.LBB1_5:
	adrp	x9, .L__anon_203
	add	x9, x9, :lo12:.L__anon_203
.LBB1_6:
	and	x10, x8, #0x3
	ldrb	w11, [x2, x8]
	ldrb	w10, [x9, x10]
	eor	w10, w10, w11
	strb	w10, [x0, x8]
	add	x8, x8, #1
	cmp	x1, x8
	b.ne	.LBB1_6
.LBB1_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end1:
	.size	.Lsimd_candidates.maskCopy__func_0, .Lfunc_end1-.Lsimd_candidates.maskCopy__func_0
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_codegen.mask_word,@function
.Lsimd_codegen.mask_word:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x1
	mov	x1, x2
	mov	x2, x8
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.maskCopy__func_1
.Lfunc_end2:
	.size	.Lsimd_codegen.mask_word, .Lfunc_end2-.Lsimd_codegen.mask_word
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_candidates.maskCopy__func_1,@function
.Lsimd_candidates.maskCopy__func_1:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cmp	x1, #8
	b.lo	.LBB3_4
	mov	x9, #-35747867511423104
	mov	x8, xzr
	mov	x10, x1
	movk	x9, #25361
	movk	x9, #25361, lsl #32
.LBB3_2:
	ldr	x11, [x2, x8]
	sub	x10, x10, #8
	cmp	x10, #7
	eor	x11, x11, x9
	str	x11, [x0, x8]
	add	x8, x8, #8
	b.hi	.LBB3_2
	cmp	x8, x1
	b.lo	.LBB3_5
	b	.LBB3_7
.LBB3_4:
	mov	x8, xzr
	cmp	xzr, x1
	b.hs	.LBB3_7
.LBB3_5:
	adrp	x9, .L__anon_203
	add	x9, x9, :lo12:.L__anon_203
.LBB3_6:
	and	x10, x8, #0x3
	ldrb	w11, [x2, x8]
	ldrb	w10, [x9, x10]
	eor	w10, w10, w11
	strb	w10, [x0, x8]
	add	x8, x8, #1
	cmp	x1, x8
	b.ne	.LBB3_6
.LBB3_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end3:
	.size	.Lsimd_candidates.maskCopy__func_1, .Lfunc_end3-.Lsimd_candidates.maskCopy__func_1
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_codegen.mask_byte,@function
.Lsimd_codegen.mask_byte:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x1
	mov	x1, x2
	mov	x2, x8
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.maskCopy__func_2
.Lfunc_end4:
	.size	.Lsimd_codegen.mask_byte, .Lfunc_end4-.Lsimd_codegen.mask_byte
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_candidates.maskCopy__func_2,@function
.Lsimd_candidates.maskCopy__func_2:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, .LBB5_3
	mov	x8, xzr
	adrp	x9, .L__anon_203
	add	x9, x9, :lo12:.L__anon_203
.LBB5_2:
	and	x10, x8, #0x3
	ldrb	w11, [x2, x8]
	ldrb	w10, [x9, x10]
	eor	w10, w10, w11
	strb	w10, [x0, x8]
	add	x8, x8, #1
	cmp	x1, x8
	b.ne	.LBB5_2
.LBB5_3:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end5:
	.size	.Lsimd_candidates.maskCopy__func_2, .Lfunc_end5-.Lsimd_candidates.maskCopy__func_2
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI6_0:
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
	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3, 0x0
.LCPI6_1:
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.text
	.p2align	2
	.type	.Lsimd_codegen.std_search,@function
.Lsimd_codegen.std_search:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x1, .LBB6_13
	cmp	x1, #33
	b.lo	.LBB6_8
	movi	v0.16b, #13
	mov	x9, xzr
.LBB6_3:
	ldr	q1, [x0, x9]
	cmeq	v2.16b, v1.16b, v0.16b
	umaxv	b2, v2.16b
	fmov	w8, s2
	tbnz	w8, #0, .LBB6_11
	add	x8, x0, x9
	ldr	q1, [x8, #16]
	cmeq	v2.16b, v1.16b, v0.16b
	umaxv	b2, v2.16b
	fmov	w8, s2
	tbnz	w8, #0, .LBB6_12
	add	x10, x9, #64
	add	x8, x9, #32
	cmp	x10, x1
	mov	x9, x8
	b.lo	.LBB6_3
	add	x9, x8, #16
	cmp	x9, x1
	b.lo	.LBB6_9
.LBB6_7:
	add	x9, x8, #8
	cmp	x9, x1
	b.hs	.LBB6_20
	b	.LBB6_15
.LBB6_8:
	mov	x8, xzr
	add	x9, x8, #16
	cmp	x9, x1
	b.hs	.LBB6_7
.LBB6_9:
	movi	v0.16b, #13
	ldr	q1, [x0, x8]
	cmeq	v0.16b, v1.16b, v0.16b
	umaxv	b1, v0.16b
	fmov	w10, s1
	tbz	w10, #0, .LBB6_14
	movi	v1.16b, #15
	adrp	x9, .LCPI6_0
	ldr	q2, [x9, :lo12:.LCPI6_0]
	bsl	v0.16b, v2.16b, v1.16b
	uminv	b0, v0.16b
	fmov	w9, s0
	and	x9, x9, #0xf
	add	x1, x8, x9
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB6_11:
	.cfi_restore_state
	.cfi_remember_state
	movi	v0.16b, #13
	movi	v2.16b, #15
	adrp	x8, .LCPI6_0
	cmeq	v0.16b, v1.16b, v0.16b
	ldr	q1, [x8, :lo12:.LCPI6_0]
	bsl	v0.16b, v1.16b, v2.16b
	uminv	b0, v0.16b
	fmov	w8, s0
	and	x8, x8, #0xf
	add	x1, x8, x9
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB6_12:
	.cfi_restore_state
	.cfi_remember_state
	movi	v0.16b, #13
	movi	v2.16b, #15
	adrp	x8, .LCPI6_0
	cmeq	v0.16b, v1.16b, v0.16b
	ldr	q1, [x8, :lo12:.LCPI6_0]
	bsl	v0.16b, v1.16b, v2.16b
	uminv	b0, v0.16b
	fmov	w8, s0
	and	x8, x8, #0xf
	add	x8, x8, x9
	add	x1, x8, #16
.LBB6_13:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB6_14:
	.cfi_restore_state
	.cfi_remember_state
	mov	x8, x9
	add	x9, x9, #8
	cmp	x9, x1
	b.hs	.LBB6_20
.LBB6_15:
	movi	v0.8b, #13
	ldr	d1, [x0, x8]
	cmeq	v0.8b, v1.8b, v0.8b
	umaxv	b1, v0.8b
	fmov	w10, s1
	tbz	w10, #0, .LBB6_17
	movi	v1.8b, #7
	adrp	x9, .LCPI6_1
	ldr	d2, [x9, :lo12:.LCPI6_1]
	bsl	v0.8b, v2.8b, v1.8b
	uminv	b0, v0.8b
	fmov	w9, s0
	and	x9, x9, #0x7
	add	x1, x8, x9
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB6_17:
	.cfi_restore_state
	mov	x8, x9
	b	.LBB6_20
.LBB6_18:
	ldrb	w9, [x0, x8]
	cmp	w9, #13
	b.eq	.LBB6_21
	add	x8, x8, #1
.LBB6_20:
	cmp	x1, x8
	b.ne	.LBB6_18
	b	.LBB6_13
.LBB6_21:
	mov	x1, x8
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end6:
	.size	.Lsimd_codegen.std_search, .Lfunc_end6-.Lsimd_codegen.std_search
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_codegen.field_vector,@function
.Lsimd_codegen.field_vector:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.find__func_8
.Lfunc_end7:
	.size	.Lsimd_codegen.field_vector, .Lfunc_end7-.Lsimd_codegen.field_vector
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI8_0:
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
	.p2align	2
	.type	.Lsimd_candidates.find__func_8,@function
.Lsimd_candidates.find__func_8:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cmp	x1, #16
	b.lo	.LBB8_9
	movi	v0.16b, #32
	movi	v1.16b, #9
	mov	x10, xzr
	movi	v2.16b, #127
	and	x8, x1, #0xfffffffffffffff0
	mov	x11, x0
	mov	x9, x1
.LBB8_2:
	ldr	q3, [x11], #16
	cmhi	v4.16b, v0.16b, v3.16b
	cmeq	v5.16b, v3.16b, v1.16b
	cmeq	v3.16b, v3.16b, v2.16b
	bic	v4.16b, v4.16b, v5.16b
	orr	v3.16b, v3.16b, v4.16b
	umaxv	b4, v3.16b
	fmov	w12, s4
	tbnz	w12, #0, .LBB8_10
	sub	x9, x9, #16
	sub	x10, x10, #16
	cmp	x9, #15
	b.hi	.LBB8_2
	cbz	x9, .LBB8_8
.LBB8_5:
	ldrb	w11, [x0, x8]
	cmp	w11, #32
	ccmp	w11, #9, #4, lo
	cset	w10, ne
	cmp	w11, #127
	b.eq	.LBB8_11
	tbnz	w10, #0, .LBB8_11
	subs	x9, x9, #1
	add	x8, x8, #1
	b.ne	.LBB8_5
.LBB8_8:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB8_9:
	.cfi_restore_state
	.cfi_remember_state
	mov	x8, xzr
	mov	x9, x1
	cbnz	x1, .LBB8_5
	b	.LBB8_8
.LBB8_10:
	movi	v0.16b, #15
	adrp	x8, .LCPI8_0
	ldr	q1, [x8, :lo12:.LCPI8_0]
	bit	v0.16b, v1.16b, v3.16b
	uminv	b0, v0.16b
	fmov	w8, s0
	and	x8, x8, #0xf
	sub	x1, x8, x10
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB8_11:
	.cfi_restore_state
	mov	x1, x8
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end8:
	.size	.Lsimd_candidates.find__func_8, .Lfunc_end8-.Lsimd_candidates.find__func_8
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_codegen.field_scalar,@function
.Lsimd_codegen.field_scalar:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.find__func_10
.Lfunc_end9:
	.size	.Lsimd_codegen.field_scalar, .Lfunc_end9-.Lsimd_codegen.field_scalar
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_candidates.find__func_10,@function
.Lsimd_candidates.find__func_10:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x1, .LBB10_6
	mov	x8, x0
	mov	x0, xzr
.LBB10_2:
	ldrb	w10, [x8, x0]
	cmp	w10, #32
	ccmp	w10, #9, #4, lo
	cset	w9, ne
	cmp	w10, #127
	b.eq	.LBB10_7
	tbnz	w9, #0, .LBB10_7
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	.LBB10_2
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB10_6:
	.cfi_restore_state
	mov	x0, xzr
.LBB10_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end10:
	.size	.Lsimd_candidates.find__func_10, .Lfunc_end10-.Lsimd_candidates.find__func_10
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_codegen.json_vector,@function
.Lsimd_codegen.json_vector:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.find__func_11
.Lfunc_end11:
	.size	.Lsimd_codegen.json_vector, .Lfunc_end11-.Lsimd_codegen.json_vector
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI12_0:
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
	.p2align	2
	.type	.Lsimd_candidates.find__func_11,@function
.Lsimd_candidates.find__func_11:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cmp	x1, #16
	b.lo	.LBB12_9
	movi	v0.16b, #32
	movi	v1.16b, #34
	mov	x10, xzr
	movi	v2.16b, #92
	and	x8, x1, #0xfffffffffffffff0
	mov	x11, x0
	mov	x9, x1
.LBB12_2:
	ldr	q3, [x11], #16
	cmeq	v4.16b, v3.16b, v1.16b
	cmeq	v5.16b, v3.16b, v2.16b
	cmhi	v3.16b, v0.16b, v3.16b
	orr	v4.16b, v4.16b, v5.16b
	orr	v3.16b, v4.16b, v3.16b
	umaxv	b4, v3.16b
	fmov	w12, s4
	tbnz	w12, #0, .LBB12_12
	sub	x9, x9, #16
	sub	x10, x10, #16
	cmp	x9, #15
	b.hi	.LBB12_2
	cbz	x9, .LBB12_10
.LBB12_5:
	ldrb	w10, [x0, x8]
	and	w10, w10, #0xff
	cmp	w10, #32
	b.lo	.LBB12_11
	cmp	w10, #34
	b.eq	.LBB12_11
	cmp	w10, #92
	b.eq	.LBB12_11
	subs	x9, x9, #1
	add	x8, x8, #1
	b.ne	.LBB12_5
	b	.LBB12_10
.LBB12_9:
	mov	x8, xzr
	mov	x9, x1
	cbnz	x1, .LBB12_5
.LBB12_10:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB12_11:
	.cfi_restore_state
	.cfi_remember_state
	mov	x1, x8
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB12_12:
	.cfi_restore_state
	movi	v0.16b, #15
	adrp	x8, .LCPI12_0
	ldr	q1, [x8, :lo12:.LCPI12_0]
	bit	v0.16b, v1.16b, v3.16b
	uminv	b0, v0.16b
	fmov	w8, s0
	and	x8, x8, #0xf
	sub	x1, x8, x10
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.Lfunc_end12:
	.size	.Lsimd_candidates.find__func_11, .Lfunc_end12-.Lsimd_candidates.find__func_11
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_codegen.json_scalar,@function
.Lsimd_codegen.json_scalar:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	.Lsimd_candidates.find__func_13
.Lfunc_end13:
	.size	.Lsimd_codegen.json_scalar, .Lfunc_end13-.Lsimd_codegen.json_scalar
	.cfi_endproc

	.p2align	2
	.type	.Lsimd_candidates.find__func_13,@function
.Lsimd_candidates.find__func_13:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x1, .LBB14_7
	mov	x8, x0
	mov	x0, xzr
.LBB14_2:
	ldrb	w9, [x8, x0]
	and	w9, w9, #0xff
	cmp	w9, #32
	b.lo	.LBB14_8
	cmp	w9, #34
	b.eq	.LBB14_8
	cmp	w9, #92
	b.eq	.LBB14_8
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	.LBB14_2
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB14_7:
	.cfi_restore_state
	mov	x0, xzr
.LBB14_8:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
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
