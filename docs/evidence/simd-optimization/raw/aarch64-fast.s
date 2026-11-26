	.build_version macos, 27, 0, 1
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_simd_codegen.mask_vector:
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
	b	l_simd_candidates.maskCopy__func_0
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI1_0:
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
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_simd_candidates.maskCopy__func_0:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cmp	x1, #16
	b.lo	LBB1_4
	mov	x8, #0
Lloh0:
	adrp	x9, lCPI1_0@PAGE
Lloh1:
	ldr	q0, [x9, lCPI1_0@PAGEOFF]
	mov	x9, x1
LBB1_2:
	ldr	q1, [x2, x8]
	eor.16b	v1, v1, v0
	str	q1, [x0, x8]
	add	x8, x8, #16
	sub	x9, x9, #16
	cmp	x9, #15
	b.hi	LBB1_2
	cmp	x8, x1
	b.lo	LBB1_5
	b	LBB1_7
LBB1_4:
	mov	x8, #0
	cmp	x8, x1
	b.hs	LBB1_7
LBB1_5:
Lloh2:
	adrp	x9, l___anon_203@PAGE
Lloh3:
	add	x9, x9, l___anon_203@PAGEOFF
LBB1_6:
	ldrb	w10, [x2, x8]
	and	x11, x8, #0x3
	ldrb	w11, [x9, x11]
	eor	w10, w11, w10
	strb	w10, [x0, x8]
	add	x8, x8, #1
	cmp	x1, x8
	b.ne	LBB1_6
LBB1_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpLdr	Lloh0, Lloh1
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc

	.p2align	2
l_simd_codegen.mask_word:
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
	b	l_simd_candidates.maskCopy__func_1
	.cfi_endproc

	.p2align	2
l_simd_candidates.maskCopy__func_1:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cmp	x1, #8
	b.lo	LBB3_4
	mov	x8, #0
	mov	x9, #-35747867511423104
	movk	x9, #25361
	movk	x9, #25361, lsl #32
	mov	x10, x1
LBB3_2:
	ldr	x11, [x2, x8]
	eor	x11, x11, x9
	str	x11, [x0, x8]
	add	x8, x8, #8
	sub	x10, x10, #8
	cmp	x10, #7
	b.hi	LBB3_2
	cmp	x8, x1
	b.lo	LBB3_5
	b	LBB3_7
LBB3_4:
	mov	x8, #0
	cmp	x8, x1
	b.hs	LBB3_7
LBB3_5:
Lloh4:
	adrp	x9, l___anon_203@PAGE
Lloh5:
	add	x9, x9, l___anon_203@PAGEOFF
LBB3_6:
	ldrb	w10, [x2, x8]
	and	x11, x8, #0x3
	ldrb	w11, [x9, x11]
	eor	w10, w11, w10
	strb	w10, [x0, x8]
	add	x8, x8, #1
	cmp	x1, x8
	b.ne	LBB3_6
LBB3_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpAdd	Lloh4, Lloh5
	.cfi_endproc

	.p2align	2
l_simd_codegen.mask_byte:
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
	b	l_simd_candidates.maskCopy__func_2
	.cfi_endproc

	.p2align	2
l_simd_candidates.maskCopy__func_2:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, LBB5_6
	mov	x8, #0
	sub	x9, x1, #1
	mov	x10, #-3689348814741910324
	movk	x10, #52429
	umulh	x10, x9, x10
	lsr	x10, x10, #2
	add	x10, x10, x10, lsl #2
	sub	x9, x9, x10
	add	x11, x9, #1
	cmp	x11, #5
	csinc	x9, xzr, x9, eq
Lloh6:
	adrp	x10, l___anon_203@PAGE
Lloh7:
	add	x10, x10, l___anon_203@PAGEOFF
	cmp	x1, #5
	b.lo	LBB5_5
	mov	x12, #0
	sub	x8, x1, x9
LBB5_3:
	add	x13, x0, x12
	add	x14, x2, x12
	ldrb	w15, [x14]
	and	x16, x12, #0x3
	ldrb	w17, [x10, x16]
	eor	w15, w17, w15
	add	w1, w12, #1
	strb	w15, [x13]
	ldrb	w15, [x14, #1]
	and	x1, x1, #0x3
	ldrb	w1, [x10, x1]
	eor	w15, w1, w15
	strb	w15, [x13, #1]
	ldrb	w15, [x14, #2]
	eor	x16, x16, #0x2
	ldrb	w16, [x10, x16]
	eor	w15, w16, w15
	strb	w15, [x13, #2]
	sub	w15, w12, #1
	ldrb	w16, [x14, #3]
	and	x15, x15, #0x3
	ldrb	w15, [x10, x15]
	eor	w15, w15, w16
	strb	w15, [x13, #3]
	ldrb	w14, [x14, #4]
	eor	w14, w14, w17
	strb	w14, [x13, #4]
	add	x12, x12, #5
	cmp	x8, x12
	b.ne	LBB5_3
	cmp	x11, #5
	b.eq	LBB5_6
LBB5_5:
	ldrb	w11, [x2, x8]
	and	x12, x8, #0x3
	ldrb	w12, [x10, x12]
	eor	w11, w12, w11
	strb	w11, [x0, x8]
	add	x8, x8, #1
	subs	x9, x9, #1
	b.ne	LBB5_5
LBB5_6:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpAdd	Lloh6, Lloh7
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI6_0:
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
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0
lCPI6_1:
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_simd_codegen.std_search:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, LBB6_22
	cmp	x1, #33
	b.lo	LBB6_8
	mov	x9, #0
	movi.16b	v0, #13
LBB6_3:
	ldr	q1, [x0, x9]
	cmeq.16b	v2, v1, v0
	umaxv.16b	b2, v2
	fmov	w8, s2
	tbnz	w8, #0, LBB6_11
	add	x8, x0, x9
	ldr	q1, [x8, #16]
	cmeq.16b	v2, v1, v0
	umaxv.16b	b2, v2
	fmov	w8, s2
	tbnz	w8, #0, LBB6_12
	add	x8, x9, #32
	add	x10, x9, #64
	mov	x9, x8
	cmp	x10, x1
	b.lo	LBB6_3
	add	x9, x8, #16
	cmp	x9, x1
	b.lo	LBB6_9
LBB6_7:
	add	x9, x8, #8
	cmp	x9, x1
	b.hs	LBB6_20
	b	LBB6_14
LBB6_8:
	mov	x8, #0
	add	x9, x8, #16
	cmp	x9, x1
	b.hs	LBB6_7
LBB6_9:
	ldr	q0, [x0, x8]
	movi.16b	v1, #13
	cmeq.16b	v0, v0, v1
	umaxv.16b	b1, v0
	fmov	w10, s1
	tbz	w10, #0, LBB6_13
Lloh8:
	adrp	x9, lCPI6_0@PAGE
Lloh9:
	ldr	q1, [x9, lCPI6_0@PAGEOFF]
	movi.16b	v2, #15
	bsl.16b	v0, v1, v2
	uminv.16b	b0, v0
	fmov	w9, s0
	and	x9, x9, #0xf
	b	LBB6_16
LBB6_11:
	movi.16b	v0, #13
	cmeq.16b	v0, v1, v0
Lloh10:
	adrp	x8, lCPI6_0@PAGE
Lloh11:
	ldr	q1, [x8, lCPI6_0@PAGEOFF]
	movi.16b	v2, #15
	bsl.16b	v0, v1, v2
	uminv.16b	b0, v0
	fmov	w8, s0
	and	x8, x8, #0xf
	b	LBB6_16
LBB6_12:
	movi.16b	v0, #13
	cmeq.16b	v0, v1, v0
Lloh12:
	adrp	x8, lCPI6_0@PAGE
Lloh13:
	ldr	q1, [x8, lCPI6_0@PAGEOFF]
	movi.16b	v2, #15
	bsl.16b	v0, v1, v2
	uminv.16b	b0, v0
	fmov	w8, s0
	and	x8, x8, #0xf
	add	x8, x8, x9
	add	x1, x8, #16
	b	LBB6_22
LBB6_13:
	mov	x8, x9
	add	x9, x9, #8
	cmp	x9, x1
	b.hs	LBB6_20
LBB6_14:
	ldr	d0, [x0, x8]
	movi.8b	v1, #13
	cmeq.8b	v0, v0, v1
	umaxv.8b	b1, v0
	fmov	w10, s1
	tbz	w10, #0, LBB6_17
Lloh14:
	adrp	x9, lCPI6_1@PAGE
Lloh15:
	ldr	d1, [x9, lCPI6_1@PAGEOFF]
	movi.8b	v2, #7
	bsl.8b	v0, v1, v2
	uminv.8b	b0, v0
	fmov	w9, s0
	and	x9, x9, #0x7
LBB6_16:
	add	x1, x8, x9
	b	LBB6_22
LBB6_17:
	mov	x8, x9
	b	LBB6_20
LBB6_18:
	ldrb	w9, [x0, x8]
	cmp	w9, #13
	b.eq	LBB6_21
	add	x8, x8, #1
LBB6_20:
	cmp	x1, x8
	b.ne	LBB6_18
	b	LBB6_22
LBB6_21:
	mov	x1, x8
LBB6_22:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpLdr	Lloh8, Lloh9
	.loh AdrpLdr	Lloh10, Lloh11
	.loh AdrpLdr	Lloh12, Lloh13
	.loh AdrpLdr	Lloh14, Lloh15
	.cfi_endproc

	.p2align	2
l_simd_codegen.field_vector:
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
	b	l_simd_candidates.find__func_8
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI8_0:
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
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_simd_candidates.find__func_8:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cmp	x1, #16
	b.lo	LBB8_5
	mov	x10, #0
	and	x8, x1, #0xfffffffffffffff0
	movi.16b	v0, #32
	movi.16b	v1, #9
	movi.16b	v2, #127
	mov	x11, x0
	mov	x9, x1
LBB8_2:
	ldr	q3, [x11], #16
	cmhi.16b	v4, v0, v3
	cmeq.16b	v5, v3, v1
	bic.16b	v4, v4, v5
	cmeq.16b	v3, v3, v2
	orr.16b	v3, v3, v4
	umaxv.16b	b4, v3
	fmov	w12, s4
	tbnz	w12, #0, LBB8_9
	sub	x9, x9, #16
	sub	x10, x10, #16
	cmp	x9, #15
	b.hi	LBB8_2
	cbnz	x9, LBB8_6
	b	LBB8_11
LBB8_5:
	mov	x8, #0
	mov	x9, x1
	cbz	x1, LBB8_11
LBB8_6:
	ldrb	w11, [x0, x8]
	cmp	w11, #32
	ccmp	w11, #9, #4, lo
	cset	w10, ne
	cmp	w11, #127
	b.eq	LBB8_10
	tbnz	w10, #0, LBB8_10
	add	x8, x8, #1
	subs	x9, x9, #1
	b.ne	LBB8_6
	b	LBB8_11
LBB8_9:
Lloh16:
	adrp	x8, lCPI8_0@PAGE
Lloh17:
	ldr	q0, [x8, lCPI8_0@PAGEOFF]
	movi.16b	v1, #15
	bif.16b	v0, v1, v3
	uminv.16b	b0, v0
	fmov	w8, s0
	and	x8, x8, #0xf
	sub	x1, x8, x10
	b	LBB8_11
LBB8_10:
	mov	x1, x8
LBB8_11:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpLdr	Lloh16, Lloh17
	.cfi_endproc

	.p2align	2
l_simd_codegen.field_scalar:
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
	b	l_simd_candidates.find__func_10
	.cfi_endproc

	.p2align	2
l_simd_candidates.find__func_10:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, LBB10_6
	mov	x8, x0
	mov	x0, #0
LBB10_2:
	ldrb	w10, [x8, x0]
	cmp	w10, #32
	ccmp	w10, #9, #4, lo
	cset	w9, ne
	cmp	w10, #127
	b.eq	LBB10_7
	tbnz	w9, #0, LBB10_7
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	LBB10_2
	mov	x0, x1
	b	LBB10_7
LBB10_6:
	mov	x0, #0
LBB10_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.cfi_endproc

	.p2align	2
l_simd_codegen.json_vector:
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
	b	l_simd_candidates.find__func_11
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI12_0:
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
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_simd_candidates.find__func_11:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cmp	x1, #16
	b.lo	LBB12_5
	mov	x10, #0
	and	x8, x1, #0xfffffffffffffff0
	movi.16b	v0, #32
	movi.16b	v1, #34
	movi.16b	v2, #92
	mov	x11, x0
	mov	x9, x1
LBB12_2:
	ldr	q3, [x11], #16
	cmhi.16b	v4, v0, v3
	cmeq.16b	v5, v3, v1
	cmeq.16b	v3, v3, v2
	orr.16b	v3, v5, v3
	orr.16b	v3, v3, v4
	umaxv.16b	b4, v3
	fmov	w12, s4
	tbnz	w12, #0, LBB12_11
	sub	x9, x9, #16
	sub	x10, x10, #16
	cmp	x9, #15
	b.hi	LBB12_2
	cbnz	x9, LBB12_6
	b	LBB12_12
LBB12_5:
	mov	x8, #0
	mov	x9, x1
	cbz	x1, LBB12_12
LBB12_6:
	ldrb	w10, [x0, x8]
	and	w10, w10, #0xff
	cmp	w10, #32
	b.lo	LBB12_10
	cmp	w10, #34
	b.eq	LBB12_10
	cmp	w10, #92
	b.eq	LBB12_10
	add	x8, x8, #1
	subs	x9, x9, #1
	b.ne	LBB12_6
	b	LBB12_12
LBB12_10:
	mov	x1, x8
	b	LBB12_12
LBB12_11:
Lloh18:
	adrp	x8, lCPI12_0@PAGE
Lloh19:
	ldr	q0, [x8, lCPI12_0@PAGEOFF]
	movi.16b	v1, #15
	bif.16b	v0, v1, v3
	uminv.16b	b0, v0
	fmov	w8, s0
	and	x8, x8, #0xf
	sub	x1, x8, x10
LBB12_12:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpLdr	Lloh18, Lloh19
	.cfi_endproc

	.p2align	2
l_simd_codegen.json_scalar:
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
	b	l_simd_candidates.find__func_13
	.cfi_endproc

	.p2align	2
l_simd_candidates.find__func_13:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, LBB14_7
	mov	x8, x0
	mov	x0, #0
LBB14_2:
	ldrb	w9, [x8, x0]
	and	w9, w9, #0xff
	cmp	w9, #32
	b.lo	LBB14_8
	cmp	w9, #34
	b.eq	LBB14_8
	cmp	w9, #92
	b.eq	LBB14_8
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	LBB14_2
	mov	x0, x1
	b	LBB14_8
LBB14_7:
	mov	x0, #0
LBB14_8:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.cfi_endproc

	.section	__TEXT,__literal4,4byte_literals
l___anon_203:
	.ascii	"\021c\200\377"

	.globl	_mask_vector
_mask_vector = l_simd_codegen.mask_vector
	.globl	_mask_word
_mask_word = l_simd_codegen.mask_word
	.globl	_mask_byte
_mask_byte = l_simd_codegen.mask_byte
	.globl	_std_search
_std_search = l_simd_codegen.std_search
	.globl	_field_vector
_field_vector = l_simd_codegen.field_vector
	.globl	_field_scalar
_field_scalar = l_simd_codegen.field_scalar
	.globl	_json_vector
_json_vector = l_simd_codegen.json_vector
	.globl	_json_scalar
_json_scalar = l_simd_codegen.json_scalar
.subsections_via_symbols
