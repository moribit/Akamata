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
	mov	x3, x2
	mov	x2, x1
	mov	x1, x3
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
	.cfi_remember_state
	cmp	x1, x3
	b.ne	LBB1_16
	mov	x9, #0
Lloh0:
	adrp	x8, lCPI1_0@PAGE
Lloh1:
	ldr	q0, [x8, lCPI1_0@PAGEOFF]
	mov	x8, x1
LBB1_2:
	cmp	x8, #15
	b.ls	LBB1_7
	add	x8, x9, #16
	cmp	x8, x1
	b.hi	LBB1_15
	ldr	q1, [x2, x9]
	eor.16b	v1, v1, v0
	str	q1, [x0, x9]
	cmn	x9, #16
	b.eq	LBB1_6
	mov	x9, x8
	subs	x8, x1, x8
	b.hs	LBB1_2
LBB1_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB1_7:
	cmp	x1, x9
	b.ls	LBB1_14
	mvn	x8, x9
	add	x8, x8, x1
	mov	x10, #-3689348814741910324
	movk	x10, #52429
	umulh	x10, x8, x10
	lsr	x10, x10, #2
	add	x10, x10, x10, lsl #2
	sub	x10, x8, x10
	add	x10, x10, #1
	cmp	x10, #5
	b.eq	LBB1_11
Lloh2:
	adrp	x11, l___anon_203@PAGE
Lloh3:
	add	x11, x11, l___anon_203@PAGEOFF
LBB1_10:
	and	x12, x9, #0x3
	ldrb	w13, [x2, x9]
	ldrb	w12, [x11, x12]
	eor	w12, w12, w13
	strb	w12, [x0, x9]
	add	x9, x9, #1
	subs	x10, x10, #1
	b.ne	LBB1_10
LBB1_11:
	cmp	x8, #4
	b.lo	LBB1_14
	add	x8, x0, #4
Lloh4:
	adrp	x10, l___anon_203@PAGE
Lloh5:
	add	x10, x10, l___anon_203@PAGEOFF
LBB1_13:
	add	w11, w9, #2
	add	x12, x8, x9
	and	x11, x11, #0x3
	eor	x13, x11, #0x2
	add	x14, x2, x9
	ldrb	w15, [x14]
	ldrb	w13, [x10, x13]
	eor	w15, w13, w15
	sturb	w15, [x12, #-4]
	sub	w15, w9, #1
	add	x9, x9, #5
	and	x16, x9, #0x3
	ldrb	w17, [x14, #1]
	ldrb	w16, [x10, x16]
	eor	w16, w16, w17
	sturb	w16, [x12, #-3]
	ldrb	w16, [x14, #2]
	ldrb	w11, [x10, x11]
	eor	w11, w11, w16
	sturb	w11, [x12, #-2]
	and	x11, x15, #0x3
	ldrb	w15, [x14, #3]
	ldrb	w11, [x10, x11]
	eor	w11, w11, w15
	sturb	w11, [x12, #-1]
	ldrb	w11, [x14, #4]
	eor	w11, w11, w13
	strb	w11, [x12]
	cmp	x1, x9
	b.ne	LBB1_13
LBB1_14:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB1_15:
	.cfi_restore_state
	mov	x0, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB1_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdr	Lloh0, Lloh1
	.loh AdrpAdd	Lloh2, Lloh3
	.loh AdrpAdd	Lloh4, Lloh5
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).integerOverflow":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh6:
	adrp	x0, l___anon_691@PAGE
Lloh7:
	add	x0, x0, l___anon_691@PAGEOFF
	mov	w1, #16
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh6, Lloh7
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh8:
	adrp	x0, l___anon_697@PAGE
Lloh9:
	add	x0, x0, l___anon_697@PAGEOFF
	mov	w1, #24
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh8, Lloh9
	.cfi_endproc

	.p2align	2
l_debug.defaultPanic:
	.cfi_startproc
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x24, x23, [sp, #112]
	stp	x22, x21, [sp, #128]
	stp	x20, x19, [sp, #144]
	stp	x29, x30, [sp, #160]
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x19, x1
	mov	x20, x0
Lloh10:
	adrp	x21, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh11:
	ldr	x21, [x21, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x23, [x21]
	mov	x0, x21
	blr	x23
	ldr	x8, [x0]
	cbz	x8, LBB4_2
	mov	w9, #7
	str	x9, [x8, #24]
	mov	w9, #1
	strb	w9, [x8, #552]
LBB4_2:
	mov	w8, #-1431655766
	str	w8, [sp, #32]
	add	x0, sp, #32
	bl	_sigemptyset
	cmn	w0, #1
	b.ne	LBB4_6
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB4_66
	cmp	w8, #16, lsl #12
	b.hs	LBB4_66
	cbnz	w8, LBB4_68
LBB4_6:
	ldr	w8, [sp, #32]
	str	xzr, [sp, #32]
	stp	w8, wzr, [sp, #40]
	add	x1, sp, #32
	mov	w0, #11
	mov	x2, #0
	bl	_sigaction
	cmn	w0, #1
	b.ne	LBB4_10
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB4_66
	cmp	w8, #16, lsl #12
	b.hs	LBB4_66
	cbnz	w8, LBB4_67
LBB4_10:
	add	x1, sp, #32
	mov	w0, #4
	mov	x2, #0
	bl	_sigaction
	cmn	w0, #1
	b.ne	LBB4_14
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB4_66
	cmp	w8, #16, lsl #12
	b.hs	LBB4_66
	cbnz	w8, LBB4_67
LBB4_14:
	add	x1, sp, #32
	mov	w0, #10
	mov	x2, #0
	bl	_sigaction
	cmn	w0, #1
	b.ne	LBB4_18
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB4_66
	cmp	w8, #16, lsl #12
	b.hs	LBB4_66
	cbnz	w8, LBB4_67
LBB4_18:
	add	x1, sp, #32
	mov	w0, #8
	mov	x2, #0
	bl	_sigaction
	cmn	w0, #1
	b.ne	LBB4_22
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB4_66
	cmp	w8, #16, lsl #12
	b.hs	LBB4_66
	cbnz	w8, LBB4_67
LBB4_22:
Lloh12:
	adrp	x8, l_debug.panic_stage@TLVPPAGE
Lloh13:
	ldr	x8, [x8, l_debug.panic_stage@TLVPPAGEOFF]
	ldr	x9, [x8]
	mov	x0, x8
	blr	x9
	ldr	x10, [x0]
	cbnz	x10, LBB4_69
	mov	x0, x8
	blr	x9
	mov	w8, #1
	str	x8, [x0]
Lloh14:
	adrp	x22, l_debug.panicking@PAGE
Lloh15:
	add	x22, x22, l_debug.panicking@PAGEOFF
	ldaddalb	w8, w9, [x22]
	mov	x0, x21
	blr	x23
	ldr	x9, [x0]
	cbnz	x9, LBB4_25
	mov	w24, #0
	b	LBB4_26
LBB4_25:
	ldrb	w24, [x9, #552]
	strb	w8, [x9, #552]
LBB4_26:
	add	x0, sp, #32
	bl	l_Io.lockStderr
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB4_86
	ldr	x9, [sp, #32]
	ldrb	w8, [sp, #40]
	mov	x0, x21
	blr	x23
	ldr	x10, [x0]
	cbz	x10, LBB4_29
	and	w11, w24, #0x1
	strb	w11, [x10, #552]
LBB4_29:
	add	x21, x9, #24
	str	x21, [sp]
	strb	w8, [sp, #8]
	mov	x8, #-6148914691236517206
	str	x8, [sp, #32]
	add	x1, sp, #32
	mov	x0, #0
	bl	_pthread_threadid_np
	cbnz	w0, LBB4_68
	ldr	x23, [sp, #32]
Lloh16:
	adrp	x1, l___anon_4830@PAGE
Lloh17:
	add	x1, x1, l___anon_4830@PAGEOFF
	mov	x0, x21
	mov	w2, #7
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB4_46
	mov	w8, #-86
	strb	w8, [sp, #96]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #32]
	mov	w8, #65
	cmp	x23, #100
	b.lo	LBB4_36
	mov	x9, #62915
	movk	x9, #23592, lsl #16
	movk	x9, #49807, lsl #32
	movk	x9, #10485, lsl #48
	mov	x10, #-100
	add	x11, sp, #32
Lloh18:
	adrp	x12, l___anon_4180@PAGE
Lloh19:
	add	x12, x12, l___anon_4180@PAGEOFF
LBB4_33:
	subs	x8, x8, #2
	b.lo	LBB4_85
	lsr	x13, x23, #2
	umulh	x13, x13, x9
	lsr	x13, x13, #2
	madd	x14, x13, x10, x23
	ldrh	w14, [x12, x14, lsl #1]
	strh	w14, [x11, x8]
	lsr	x14, x23, #4
	mov	x23, x13
	cmp	x14, #624
	b.hi	LBB4_33
	mov	x23, x13
LBB4_36:
	cmp	x23, #10
	b.hs	LBB4_39
	subs	x8, x8, #1
	b.lo	LBB4_85
	orr	w9, w23, #0x30
	add	x10, sp, #32
	strb	w9, [x10, x8]
	b	LBB4_41
LBB4_39:
	subs	x8, x8, #2
	b.lo	LBB4_85
Lloh20:
	adrp	x9, l___anon_4180@PAGE
Lloh21:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w9, [x9, x23, lsl #1]
	add	x10, sp, #32
	strh	w9, [x10, x8]
LBB4_41:
	mov	w9, #65
	sub	x2, x9, x8
	add	x9, sp, #32
	add	x1, x9, x8
	mov	x0, x21
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB4_46
Lloh22:
	adrp	x1, l___anon_4850@PAGE
Lloh23:
	add	x1, x1, l___anon_4850@PAGEOFF
	mov	x0, x21
	mov	w2, #8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB4_46
	mov	x0, x21
	mov	x1, x20
	mov	x2, x19
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB4_46
Lloh24:
	adrp	x1, l___anon_4678@PAGE
Lloh25:
	add	x1, x1, l___anon_4678@PAGEOFF
	mov	x0, x21
	mov	w2, #1
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB4_46
	mov	x0, sp
	bl	l_debug.writeCurrentStackTrace
LBB4_46:
	adrp	x20, l_Io.Threaded.global_single_threaded_instance@PAGE+824
	ldrh	w8, [x20, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+824]
	cbnz	w8, LBB4_48
Lloh26:
	adrp	x19, l_Io.Threaded.global_single_threaded_instance@PAGE+784
Lloh27:
	add	x19, x19, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+784
	ldr	x8, [x19]
	ldr	x8, [x8, #16]
	mov	x0, x19
	blr	x8
	ldrh	w8, [x19, #40]
LBB4_48:
	cbz	w8, LBB4_52
	cmp	w8, #2
	b.ne	LBB4_51
	bl	l_Io.Threaded.recancelInner
LBB4_51:
	strh	wzr, [x20, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+824]
LBB4_52:
Lloh28:
	adrp	x8, l_Io.Threaded.global_single_threaded_instance@PAGE+728
Lloh29:
	add	x8, x8, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+728
	mov	w9, #1
	stp	xzr, xzr, [x8, #72]
	str	x9, [x8, #64]
	ldr	x8, [x8]
	subs	x8, x8, #1
	b.lo	LBB4_85
	adrp	x9, l_Io.Threaded.global_single_threaded_instance@PAGE+728
	str	x8, [x9, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+728]
	cbnz	x8, LBB4_59
Lloh30:
	adrp	x8, l_Io.Threaded.global_single_threaded_instance@PAGE+736
Lloh31:
	add	x8, x8, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+736
	mov	x9, #-1
	str	x9, [x8], #96
	swpl	wzr, w8, [x8]
	cbz	w8, LBB4_68
	cmp	w8, #1
	b.eq	LBB4_59
	cmp	w8, #2
	b.eq	LBB4_58
LBB4_57:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB4_58:
Lloh32:
	adrp	x0, l_Io.Threaded.global_single_threaded_instance@PAGE+832
Lloh33:
	add	x0, x0, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+832
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB4_59:
	mov	w8, #-1
	ldaddalb	w8, w8, [x22]
	cmp	w8, #1
	b.ne	LBB4_61
LBB4_60:
	bl	l_process.abort
LBB4_61:
	str	wzr, [sp, #32]
LBB4_62:
	add	x1, sp, #32
	mov	w0, #1
	movk	w0, #256, lsl #16
	mov	x2, #0
	mov	x3, #0
	mov	x4, #0
	bl	___ulock_wait2
	tbz	w0, #31, LBB4_62
	negs	w8, w0
	b.vs	LBB4_85
	tbnz	w8, #31, LBB4_66
	cmp	w8, #16, lsl #12
	b.lo	LBB4_62
LBB4_66:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB4_67:
	cmp	w8, #22
LBB4_68:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB4_69:
	cmp	x10, #1
	b.ne	LBB4_60
	mov	x0, x8
	blr	x9
	mov	w8, #2
	str	x8, [x0]
	mov	x0, x21
	blr	x23
	ldr	x8, [x0]
	cbnz	x8, LBB4_72
	mov	w20, #0
	b	LBB4_73
LBB4_72:
	ldrb	w20, [x8, #552]
	mov	w9, #1
	strb	w9, [x8, #552]
LBB4_73:
	add	x0, sp, #32
	bl	l_Io.lockStderr
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB4_86
	ldr	x19, [sp, #32]
	mov	x0, x21
	blr	x23
	ldr	x8, [x0]
	cbz	x8, LBB4_76
	and	w9, w20, #0x1
	strb	w9, [x8, #552]
LBB4_76:
	mov	x20, #0
Lloh34:
	adrp	x21, l___anon_3670@PAGE
Lloh35:
	add	x21, x21, l___anon_3670@PAGEOFF
	mov	w22, #32
Lloh36:
	adrp	x23, l___anon_3670@PAGE+32
Lloh37:
	add	x23, x23, l___anon_3670@PAGEOFF+32
LBB4_77:
	ldr	x9, [x19, #48]
	sub	x24, x22, x20
	adds	x10, x9, x24
	b.hs	LBB4_85
	add	x8, x21, x20
	ldr	x11, [x19, #40]
	cmp	x10, x11
	b.hi	LBB4_83
	ldr	x10, [x19, #32]
	add	x0, x10, x9
	add	x9, x0, x24
	cmp	x0, x23
	ccmp	x8, x9, #2, lo
	b.lo	LBB4_88
	add	x1, x21, x20
	sub	x2, x22, x20
	bl	_memcpy
	ldr	x8, [x19, #48]
	adds	x8, x8, x24
	b.hs	LBB4_85
	str	x8, [x19, #48]
	adds	x20, x20, x24
	b.hs	LBB4_85
LBB4_82:
	cmp	x20, #32
	b.lo	LBB4_77
	b	LBB4_60
LBB4_83:
	ldur	x9, [x19, #24]
	ldr	x9, [x9]
	stp	x8, x24, [sp, #16]
	add	x8, sp, #32
	add	x0, x19, #24
	add	x1, sp, #16
	mov	w2, #1
	mov	w3, #1
	blr	x9
	ldrh	w8, [sp, #40]
	cbnz	w8, LBB4_60
	ldr	x24, [sp, #32]
	adds	x20, x20, x24
	b.lo	LBB4_82
LBB4_85:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB4_86:
	cmp	w8, #2
	b.ne	LBB4_57
	mov	w0, #2
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB4_88:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpLdr	Lloh10, Lloh11
	.loh AdrpLdr	Lloh12, Lloh13
	.loh AdrpAdd	Lloh14, Lloh15
	.loh AdrpAdd	Lloh16, Lloh17
	.loh AdrpAdd	Lloh18, Lloh19
	.loh AdrpAdd	Lloh20, Lloh21
	.loh AdrpAdd	Lloh22, Lloh23
	.loh AdrpAdd	Lloh24, Lloh25
	.loh AdrpAdd	Lloh26, Lloh27
	.loh AdrpAdd	Lloh28, Lloh29
	.loh AdrpAdd	Lloh30, Lloh31
	.loh AdrpAdd	Lloh32, Lloh33
	.loh AdrpAdd	Lloh36, Lloh37
	.loh AdrpAdd	Lloh34, Lloh35
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).outOfBounds":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	l_debug.panicExtra__func_26
	.cfi_endproc

	.p2align	2
l_process.abort:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_abort
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI7_0:
	.quad	4096
	.quad	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_debug.panicExtra__func_26:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	sub	sp, sp, #1, lsl #12
	sub	sp, sp, #128
	mov	x19, x1
	mov	x20, x0
	sub	x21, x29, #160
	add	x22, sp, #1
	add	x0, sp, #1
	mov	w1, #170
	mov	w2, #4111
	bl	_memset
Lloh38:
	adrp	x8, l___anon_4078@PAGE
Lloh39:
	add	x8, x8, l___anon_4078@PAGEOFF
	stp	x8, x22, [x21]
Lloh40:
	adrp	x8, lCPI7_0@PAGE
Lloh41:
	ldr	q0, [x8, lCPI7_0@PAGEOFF]
	str	q0, [x21, #16]
Lloh42:
	adrp	x1, l___anon_3841@PAGE
Lloh43:
	add	x1, x1, l___anon_3841@PAGEOFF
	sub	x0, x29, #160
	mov	w2, #27
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB7_27
	mov	w8, #-86
	strb	w8, [x21, #96]
	movi.16b	v0, #170
	stp	q0, q0, [x21, #64]
	stp	q0, q0, [x21, #32]
	mov	w8, #65
	cmp	x20, #100
	b.lo	LBB7_6
	mov	x9, #62915
	movk	x9, #23592, lsl #16
	movk	x9, #49807, lsl #32
	movk	x9, #10485, lsl #48
	mov	x10, #-100
	sub	x11, x29, #128
Lloh44:
	adrp	x12, l___anon_4180@PAGE
Lloh45:
	add	x12, x12, l___anon_4180@PAGEOFF
LBB7_3:
	subs	x8, x8, #2
	b.lo	LBB7_22
	lsr	x13, x20, #2
	umulh	x13, x13, x9
	lsr	x13, x13, #2
	madd	x14, x13, x10, x20
	ldrh	w14, [x12, x14, lsl #1]
	strh	w14, [x11, x8]
	lsr	x14, x20, #4
	mov	x20, x13
	cmp	x14, #624
	b.hi	LBB7_3
	mov	x20, x13
LBB7_6:
	cmp	x20, #10
	b.hs	LBB7_9
	subs	x8, x8, #1
	b.lo	LBB7_22
	orr	w9, w20, #0x30
	sub	x10, x29, #128
	strb	w9, [x10, x8]
	b	LBB7_11
LBB7_9:
	subs	x8, x8, #2
	b.lo	LBB7_22
Lloh46:
	adrp	x9, l___anon_4180@PAGE
Lloh47:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w9, [x9, x20, lsl #1]
	sub	x10, x29, #128
	strh	w9, [x10, x8]
LBB7_11:
	mov	w9, #65
	sub	x2, x9, x8
	sub	x9, x29, #128
	sub	x0, x29, #160
	add	x1, x9, x8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB7_27
Lloh48:
	adrp	x1, l___anon_4024@PAGE
Lloh49:
	add	x1, x1, l___anon_4024@PAGEOFF
	sub	x0, x29, #160
	mov	w2, #6
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB7_27
	mov	w8, #-86
	strb	w8, [x21, #96]
	movi.16b	v0, #170
	stp	q0, q0, [x21, #64]
	stp	q0, q0, [x21, #32]
	mov	w8, #65
	cmp	x19, #100
	b.lo	LBB7_18
	mov	x9, #62915
	movk	x9, #23592, lsl #16
	movk	x9, #49807, lsl #32
	movk	x9, #10485, lsl #48
	mov	x10, #-100
	sub	x11, x29, #128
Lloh50:
	adrp	x12, l___anon_4180@PAGE
Lloh51:
	add	x12, x12, l___anon_4180@PAGEOFF
LBB7_15:
	subs	x8, x8, #2
	b.lo	LBB7_22
	lsr	x13, x19, #2
	umulh	x13, x13, x9
	lsr	x13, x13, #2
	madd	x14, x13, x10, x19
	ldrh	w14, [x12, x14, lsl #1]
	strh	w14, [x11, x8]
	lsr	x14, x19, #4
	mov	x19, x13
	cmp	x14, #624
	b.hi	LBB7_15
	mov	x19, x13
LBB7_18:
	cmp	x19, #10
	b.hs	LBB7_21
	subs	x8, x8, #1
	b.lo	LBB7_22
	orr	w9, w19, #0x30
	sub	x10, x29, #128
	strb	w9, [x10, x8]
	b	LBB7_24
LBB7_21:
	subs	x8, x8, #2
	b.hs	LBB7_23
LBB7_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB7_23:
Lloh52:
	adrp	x9, l___anon_4180@PAGE
Lloh53:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w9, [x9, x19, lsl #1]
	sub	x10, x29, #128
	strh	w9, [x10, x8]
LBB7_24:
	mov	w9, #65
	sub	x2, x9, x8
	sub	x9, x29, #128
	sub	x0, x29, #160
	add	x1, x9, x8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB7_27
	ldp	x8, x1, [x21, #16]
	cmp	x1, x8
	b.ls	LBB7_31
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB7_27:
	add	x8, x22, #1, lsl #12
Lloh54:
	adrp	x10, l___anon_3697@PAGE+15
Lloh55:
	add	x10, x10, l___anon_3697@PAGEOFF+15
Lloh56:
	adrp	x9, l___anon_3697@PAGE
Lloh57:
	add	x9, x9, l___anon_3697@PAGEOFF
	cmp	x8, x10
	b.hs	LBB7_30
	mov	w10, #4111
	add	x10, x22, x10
	cmp	x10, x9
	b.ls	LBB7_30
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB7_30:
	ldr	x10, [x9]
	str	x10, [x8]
	ldur	x9, [x9, #7]
	stur	x9, [x8, #7]
	add	x0, sp, #1
	mov	w1, #4111
	bl	l_debug.defaultPanic
LBB7_31:
	ldr	x0, [x21, #8]
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh42, Lloh43
	.loh AdrpLdr	Lloh40, Lloh41
	.loh AdrpAdd	Lloh38, Lloh39
	.loh AdrpAdd	Lloh44, Lloh45
	.loh AdrpAdd	Lloh46, Lloh47
	.loh AdrpAdd	Lloh48, Lloh49
	.loh AdrpAdd	Lloh50, Lloh51
	.loh AdrpAdd	Lloh52, Lloh53
	.loh AdrpAdd	Lloh56, Lloh57
	.loh AdrpAdd	Lloh54, Lloh55
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh58:
	adrp	x0, l___anon_3731@PAGE
Lloh59:
	add	x0, x0, l___anon_3731@PAGEOFF
	mov	w1, #23
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh58, Lloh59
	.cfi_endproc

	.p2align	2
l_Io.Writer.defaultRebase:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x26, x25, [sp, #32]
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x20, x2
	mov	x21, x1
	mov	x19, x0
Lloh60:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh61:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh62:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	ldp	x8, x23, [x0, #16]
Lloh63:
	adrp	x22, l___anon_4116@PAGE
Lloh64:
	add	x22, x22, l___anon_4116@PAGEOFF
LBB9_1:
	subs	x8, x8, x23
	b.lo	LBB9_19
	cmp	x8, x20
	b.hs	LBB9_14
	subs	x8, x23, x21
	csel	x25, xzr, x8, lo
	subs	x24, x23, x25
	b.lo	LBB9_19
	str	x25, [x19, #24]
	ldr	x8, [x19]
	ldr	x9, [x8]
	add	x8, sp, #8
	mov	x0, x19
	mov	x1, x22
	mov	w2, #1
	mov	w3, #1
	blr	x9
	ldrh	w0, [sp, #16]
	cbnz	w0, LBB9_16
	ldr	x8, [sp, #8]
	cbnz	x8, LBB9_13
	adds	x9, x25, x24
	b.hs	LBB9_19
	ldr	x8, [x19, #24]
	cmp	x8, x9
	b.hi	LBB9_13
	ldr	x1, [x19, #16]
	add	x0, x8, x24
	cmp	x0, x1
	b.hi	LBB9_21
	cmp	x23, x1
	b.hi	LBB9_20
	ldr	x9, [x19, #8]
	add	x0, x9, x8
	add	x1, x9, x25
	mov	x2, x24
	bl	_memmove
	ldr	x8, [x19, #24]
	adds	x23, x8, x24
	b.hs	LBB9_19
	str	x23, [x19, #24]
	ldr	x8, [x19, #16]
	subs	x9, x8, x21
	b.lo	LBB9_19
	cmp	x9, x20
	b.hs	LBB9_1
LBB9_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB9_14:
	mov	w0, #0
	ldr	x8, [sp, #24]
Lloh65:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh66:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh67:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB9_18
LBB9_15:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	ldp	x26, x25, [sp, #32]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB9_16:
	.cfi_restore_state
	ldr	x8, [x19, #24]
	adds	x8, x8, x24
	b.hs	LBB9_19
	str	x8, [x19, #24]
	ldr	x8, [sp, #24]
Lloh68:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh69:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh70:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB9_15
LBB9_18:
	bl	___stack_chk_fail
LBB9_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB9_20:
	mov	x0, x23
LBB9_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpAdd	Lloh63, Lloh64
	.loh AdrpLdrGotLdr	Lloh60, Lloh61, Lloh62
	.loh AdrpLdrGotLdr	Lloh65, Lloh66, Lloh67
	.loh AdrpLdrGotLdr	Lloh68, Lloh69, Lloh70
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).copyLenMismatch":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh71:
	adrp	x0, l___anon_4145@PAGE
Lloh72:
	add	x0, x0, l___anon_4145@PAGEOFF
	mov	w1, #55
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh71, Lloh72
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh73:
	adrp	x0, l___anon_4169@PAGE
Lloh74:
	add	x0, x0, l___anon_4169@PAGEOFF
	mov	w1, #23
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh73, Lloh74
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh75:
	adrp	x0, l___anon_4193@PAGE
Lloh76:
	add	x0, x0, l___anon_4193@PAGEOFF
	mov	w1, #40
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh75, Lloh76
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	l_debug.panicExtra__func_30
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI14_0:
	.quad	4096
	.quad	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_debug.panicExtra__func_30:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	sub	sp, sp, #1, lsl #12
	sub	sp, sp, #128
	mov	x19, x1
	mov	x20, x0
	sub	x21, x29, #160
	add	x22, sp, #1
	add	x0, sp, #1
	mov	w1, #170
	mov	w2, #4111
	bl	_memset
Lloh77:
	adrp	x8, l___anon_4078@PAGE
Lloh78:
	add	x8, x8, l___anon_4078@PAGEOFF
	stp	x8, x22, [x21]
Lloh79:
	adrp	x8, lCPI14_0@PAGE
Lloh80:
	ldr	q0, [x8, lCPI14_0@PAGEOFF]
	str	q0, [x21, #16]
Lloh81:
	adrp	x1, l___anon_4232@PAGE
Lloh82:
	add	x1, x1, l___anon_4232@PAGEOFF
	sub	x0, x29, #160
	mov	w2, #12
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB14_27
	mov	w8, #-86
	strb	w8, [x21, #96]
	movi.16b	v0, #170
	stp	q0, q0, [x21, #64]
	stp	q0, q0, [x21, #32]
	mov	w8, #65
	cmp	x20, #100
	b.lo	LBB14_6
	mov	x9, #62915
	movk	x9, #23592, lsl #16
	movk	x9, #49807, lsl #32
	movk	x9, #10485, lsl #48
	mov	x10, #-100
	sub	x11, x29, #128
Lloh83:
	adrp	x12, l___anon_4180@PAGE
Lloh84:
	add	x12, x12, l___anon_4180@PAGEOFF
LBB14_3:
	subs	x8, x8, #2
	b.lo	LBB14_22
	lsr	x13, x20, #2
	umulh	x13, x13, x9
	lsr	x13, x13, #2
	madd	x14, x13, x10, x20
	ldrh	w14, [x12, x14, lsl #1]
	strh	w14, [x11, x8]
	lsr	x14, x20, #4
	mov	x20, x13
	cmp	x14, #624
	b.hi	LBB14_3
	mov	x20, x13
LBB14_6:
	cmp	x20, #10
	b.hs	LBB14_9
	subs	x8, x8, #1
	b.lo	LBB14_22
	orr	w9, w20, #0x30
	sub	x10, x29, #128
	strb	w9, [x10, x8]
	b	LBB14_11
LBB14_9:
	subs	x8, x8, #2
	b.lo	LBB14_22
Lloh85:
	adrp	x9, l___anon_4180@PAGE
Lloh86:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w9, [x9, x20, lsl #1]
	sub	x10, x29, #128
	strh	w9, [x10, x8]
LBB14_11:
	mov	w9, #65
	sub	x2, x9, x8
	sub	x9, x29, #128
	sub	x0, x29, #160
	add	x1, x9, x8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB14_27
Lloh87:
	adrp	x1, l___anon_4273@PAGE
Lloh88:
	add	x1, x1, l___anon_4273@PAGEOFF
	sub	x0, x29, #160
	mov	w2, #26
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB14_27
	mov	w8, #-86
	strb	w8, [x21, #96]
	movi.16b	v0, #170
	stp	q0, q0, [x21, #64]
	stp	q0, q0, [x21, #32]
	mov	w8, #65
	cmp	x19, #100
	b.lo	LBB14_18
	mov	x9, #62915
	movk	x9, #23592, lsl #16
	movk	x9, #49807, lsl #32
	movk	x9, #10485, lsl #48
	mov	x10, #-100
	sub	x11, x29, #128
Lloh89:
	adrp	x12, l___anon_4180@PAGE
Lloh90:
	add	x12, x12, l___anon_4180@PAGEOFF
LBB14_15:
	subs	x8, x8, #2
	b.lo	LBB14_22
	lsr	x13, x19, #2
	umulh	x13, x13, x9
	lsr	x13, x13, #2
	madd	x14, x13, x10, x19
	ldrh	w14, [x12, x14, lsl #1]
	strh	w14, [x11, x8]
	lsr	x14, x19, #4
	mov	x19, x13
	cmp	x14, #624
	b.hi	LBB14_15
	mov	x19, x13
LBB14_18:
	cmp	x19, #10
	b.hs	LBB14_21
	subs	x8, x8, #1
	b.lo	LBB14_22
	orr	w9, w19, #0x30
	sub	x10, x29, #128
	strb	w9, [x10, x8]
	b	LBB14_24
LBB14_21:
	subs	x8, x8, #2
	b.hs	LBB14_23
LBB14_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB14_23:
Lloh91:
	adrp	x9, l___anon_4180@PAGE
Lloh92:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w9, [x9, x19, lsl #1]
	sub	x10, x29, #128
	strh	w9, [x10, x8]
LBB14_24:
	mov	w9, #65
	sub	x2, x9, x8
	sub	x9, x29, #128
	sub	x0, x29, #160
	add	x1, x9, x8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB14_27
	ldp	x8, x1, [x21, #16]
	cmp	x1, x8
	b.ls	LBB14_31
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB14_27:
	add	x8, x22, #1, lsl #12
Lloh93:
	adrp	x10, l___anon_3697@PAGE+15
Lloh94:
	add	x10, x10, l___anon_3697@PAGEOFF+15
Lloh95:
	adrp	x9, l___anon_3697@PAGE
Lloh96:
	add	x9, x9, l___anon_3697@PAGEOFF
	cmp	x8, x10
	b.hs	LBB14_30
	mov	w10, #4111
	add	x10, x22, x10
	cmp	x10, x9
	b.ls	LBB14_30
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB14_30:
	ldr	x10, [x9]
	str	x10, [x8]
	ldur	x9, [x9, #7]
	stur	x9, [x8, #7]
	add	x0, sp, #1
	mov	w1, #4111
	bl	l_debug.defaultPanic
LBB14_31:
	ldr	x0, [x21, #8]
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh81, Lloh82
	.loh AdrpLdr	Lloh79, Lloh80
	.loh AdrpAdd	Lloh77, Lloh78
	.loh AdrpAdd	Lloh83, Lloh84
	.loh AdrpAdd	Lloh85, Lloh86
	.loh AdrpAdd	Lloh87, Lloh88
	.loh AdrpAdd	Lloh89, Lloh90
	.loh AdrpAdd	Lloh91, Lloh92
	.loh AdrpAdd	Lloh95, Lloh96
	.loh AdrpAdd	Lloh93, Lloh94
	.cfi_endproc

	.p2align	2
l_Io.Writer.defaultFlush:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x19, x0
Lloh97:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh98:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh99:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	ldr	x8, [x0]
	ldr	x21, [x8]
Lloh100:
	adrp	x20, l___anon_4116@PAGE
Lloh101:
	add	x20, x20, l___anon_4116@PAGEOFF
LBB15_1:
	ldr	x8, [x19, #24]
	cbz	x8, LBB15_3
	add	x8, sp, #8
	mov	x0, x19
	mov	x1, x20
	mov	w2, #1
	mov	w3, #1
	blr	x21
	ldrh	w0, [sp, #16]
	cbz	w0, LBB15_1
	b	LBB15_4
LBB15_3:
	mov	w0, #0
LBB15_4:
	ldr	x8, [sp, #24]
Lloh102:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh103:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh104:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB15_6
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB15_6:
	.cfi_restore_state
	bl	___stack_chk_fail
	.loh AdrpAdd	Lloh100, Lloh101
	.loh AdrpLdrGotLdr	Lloh97, Lloh98, Lloh99
	.loh AdrpLdrGotLdr	Lloh102, Lloh103, Lloh104
	.cfi_endproc

	.p2align	2
l_Io.Writer.unimplementedSendFile:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh105:
	adrp	x9, l___anon_9773@PAGE
Lloh106:
	add	x9, x9, l___anon_9773@PAGEOFF
Lloh107:
	ldr	q0, [x9]
	str	q0, [x8]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpAddLdr	Lloh105, Lloh106, Lloh107
	.cfi_endproc

	.p2align	2
l_Io.Writer.failingRebase:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #102
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.cfi_endproc

	.p2align	2
l_Io.Writer.noopFlush:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #0
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.cfi_endproc

	.p2align	2
l_Io.Writer.fixedDrain:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
	cbz	x2, LBB19_15
	mov	x21, x3
	mov	x23, x1
	mov	x20, x0
	ldr	x0, [x0, #24]
	subs	x24, x2, #1
	b.eq	LBB19_8
	add	x25, x23, #8
	mov	x26, x24
LBB19_3:
	ldr	x1, [x20, #16]
	subs	x27, x1, x0
	b.lo	LBB19_28
	ldp	x1, x28, [x25, #-8]
	ldr	x8, [x20, #8]
	cmp	x28, x27
	csel	x22, x28, x27, lo
	add	x0, x8, x0
	add	x8, x0, x22
	add	x9, x1, x22
	cmp	x0, x9
	ccmp	x1, x8, #2, lo
	b.lo	LBB19_27
	mov	x2, x22
	bl	_memcpy
	ldr	x8, [x20, #24]
	adds	x0, x8, x22
	b.hs	LBB19_26
	str	x0, [x20, #24]
	cmp	x28, x27
	b.hi	LBB19_14
	add	x25, x25, #16
	subs	x26, x26, #1
	b.ne	LBB19_3
LBB19_8:
	ldr	x1, [x20, #16]
	subs	x22, x1, x0
	b.lo	LBB19_28
	add	x8, x23, x24, lsl #4
	ldr	x26, [x8, #8]
	cbz	x26, LBB19_15
	ldr	x23, [x8]
	ldr	x8, [x20, #8]
	add	x24, x8, x0
	cmp	x26, #1
	b.ne	LBB19_17
	cmp	x21, x22
	b.lo	LBB19_25
	ldrb	w1, [x23]
	mov	x0, x24
	mov	x2, x22
	bl	_memset
	ldr	x8, [x20, #24]
	adds	x8, x8, x22
	b.hs	LBB19_26
	str	x8, [x20, #24]
LBB19_14:
Lloh108:
	adrp	x8, l___anon_12268@PAGE
Lloh109:
	add	x8, x8, l___anon_12268@PAGEOFF
Lloh110:
	ldr	q0, [x8]
	str	q0, [x19]
	.cfi_def_cfa wsp, 96
	b	LBB19_16
LBB19_15:
	.cfi_restore_state
	.cfi_remember_state
	stp	xzr, xzr, [x19]
	.cfi_def_cfa wsp, 96
LBB19_16:
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB19_17:
	.cfi_restore_state
	cbz	x21, LBB19_25
	mov	x27, #0
LBB19_19:
	umulh	x8, x27, x26
	cmp	xzr, x8
	b.ne	LBB19_26
	mul	x0, x27, x26
	cmp	x22, x0
	b.lo	LBB19_29
	sub	x28, x22, x0
	cmp	x26, x28
	csel	x25, x26, x28, lo
	add	x0, x24, x0
	add	x8, x0, x25
	add	x9, x23, x25
	cmp	x0, x9
	ccmp	x23, x8, #2, lo
	b.lo	LBB19_27
	mov	x1, x23
	mov	x2, x25
	bl	_memcpy
	ldr	x8, [x20, #24]
	adds	x8, x8, x25
	b.hs	LBB19_26
	str	x8, [x20, #24]
	cmp	x26, x28
	b.hi	LBB19_14
	add	x27, x27, #1
	cmp	x21, x27
	b.ne	LBB19_19
LBB19_25:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB19_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB19_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB19_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB19_29:
	mov	x1, x22
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.loh AdrpAddLdr	Lloh108, Lloh109, Lloh110
	.cfi_endproc

	.p2align	2
l_Io.Writer.writeAll:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
Lloh111:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh112:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh113:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #40]
	cbz	x2, LBB20_12
	mov	x19, x2
	mov	x20, x1
	mov	x21, x0
	mov	x22, #0
	add	x23, x1, x2
LBB20_2:
	ldr	x9, [x21, #24]
	sub	x24, x19, x22
	adds	x10, x9, x24
	b.hs	LBB20_11
	add	x8, x20, x22
	ldr	x1, [x21, #16]
	cmp	x10, x1
	b.hi	LBB20_9
	add	x0, x9, x24
	cmp	x0, x1
	b.hi	LBB20_15
	ldr	x10, [x21, #8]
	add	x0, x10, x9
	add	x9, x0, x24
	cmp	x0, x23
	ccmp	x8, x9, #2, lo
	b.lo	LBB20_16
	add	x1, x20, x22
	sub	x2, x19, x22
	bl	_memcpy
	ldr	x8, [x21, #24]
	adds	x8, x8, x24
	b.hs	LBB20_11
	str	x8, [x21, #24]
	adds	x22, x22, x24
	b.hs	LBB20_11
LBB20_8:
	cmp	x22, x19
	b.lo	LBB20_2
	b	LBB20_12
LBB20_9:
	ldr	x9, [x21]
	ldr	x9, [x9]
	stp	x8, x24, [sp, #8]
	add	x8, sp, #24
	add	x1, sp, #8
	mov	x0, x21
	mov	w2, #1
	mov	w3, #1
	blr	x9
	ldrh	w0, [sp, #32]
	cbnz	w0, LBB20_13
	ldr	x24, [sp, #24]
	adds	x22, x22, x24
	b.lo	LBB20_8
LBB20_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB20_12:
	mov	w0, #0
LBB20_13:
	ldr	x8, [sp, #40]
Lloh114:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh115:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh116:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB20_17
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB20_15:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB20_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB20_17:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh111, Lloh112, Lloh113
	.loh AdrpLdrGotLdr	Lloh114, Lloh115, Lloh116
	.cfi_endproc

	.p2align	2
l_debug.writeCurrentStackTrace:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
Lloh117:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh118:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh119:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-24]
	ldr	x19, [x0]
	ldr	w8, [x0, #8]
	ands	w8, w8, #0x3
	b.eq	LBB21_5
	cmp	w8, #1
	b.ne	LBB21_10
Lloh120:
	adrp	x1, l___anon_4560@PAGE
Lloh121:
	add	x1, x1, l___anon_4560@PAGEOFF
	mov	x0, x19
	mov	w2, #4
	bl	l_Io.Writer.writeAll
Lloh122:
	adrp	x1, l___anon_4495@PAGE
Lloh123:
	add	x1, x1, l___anon_4495@PAGEOFF
	mov	x0, x19
	mov	w2, #52
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB21_8
	ldur	x8, [x29, #-24]
Lloh124:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh125:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh126:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB21_9
Lloh127:
	adrp	x1, l___anon_4562@PAGE
Lloh128:
	add	x1, x1, l___anon_4562@PAGEOFF
	mov	x0, x19
	mov	w2, #4
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	b	l_Io.Writer.writeAll
LBB21_5:
	.cfi_restore_state
	.cfi_remember_state
Lloh129:
	adrp	x1, l___anon_4495@PAGE
Lloh130:
	add	x1, x1, l___anon_4495@PAGEOFF
	mov	x0, x19
	mov	w2, #52
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB21_8
	ldur	x8, [x29, #-24]
Lloh131:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh132:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh133:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB21_9
LBB21_7:
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB21_8:
	.cfi_restore_state
Lloh134:
	adrp	x8, l_debug.getDebugInfoAllocator.S.arena@PAGE
Lloh135:
	add	x8, x8, l_debug.getDebugInfoAllocator.S.arena@PAGEOFF
Lloh136:
	adrp	x9, l___anon_4630@PAGE
Lloh137:
	add	x9, x9, l___anon_4630@PAGEOFF
	stp	x8, x9, [sp, #8]
	stp	xzr, xzr, [sp, #24]
	add	x0, sp, #8
	bl	l_heap.ArenaAllocator.deinit
	ldur	x8, [x29, #-24]
Lloh138:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh139:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh140:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB21_7
LBB21_9:
	bl	___stack_chk_fail
LBB21_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh117, Lloh118, Lloh119
	.loh AdrpAdd	Lloh122, Lloh123
	.loh AdrpAdd	Lloh120, Lloh121
	.loh AdrpLdrGotLdr	Lloh124, Lloh125, Lloh126
	.loh AdrpAdd	Lloh127, Lloh128
	.loh AdrpAdd	Lloh129, Lloh130
	.loh AdrpLdrGotLdr	Lloh131, Lloh132, Lloh133
	.loh AdrpLdrGotLdr	Lloh138, Lloh139, Lloh140
	.loh AdrpAdd	Lloh136, Lloh137
	.loh AdrpAdd	Lloh134, Lloh135
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).invalidEnumValue":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh141:
	adrp	x0, l___anon_4359@PAGE
Lloh142:
	add	x0, x0, l___anon_4359@PAGEOFF
	mov	w1, #18
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh141, Lloh142
	.cfi_endproc

	.p2align	2
l_heap.ArenaAllocator.deinit:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x19, x30
	ldp	x20, x21, [x0]
	ldp	x1, x22, [x0, #16]
	xpaci	x19
	cbz	x1, LBB23_2
LBB23_1:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x21, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB23_1
LBB23_2:
	cbz	x22, LBB23_5
	mov	x1, x22
LBB23_4:
	ldr	x22, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x21, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x22
	cbnz	x22, LBB23_4
LBB23_5:
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
	.cfi_endproc

	.p2align	2
l_heap.ArenaAllocator.free:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	tst	x0, #0x7
	b.ne	LBB24_9
	cbz	x2, LBB24_8
	ldapur	x8, [x0, #16]
	cbz	x8, LBB24_10
	add	x11, x8, #24
	ldr	x9, [x8, #8]!
	add	x10, x11, x9
	add	x12, x1, x2
	cmp	x10, x12
	b.ne	LBB24_7
	subs	x10, x9, x2
	b.lo	LBB24_11
	add	x11, x11, x10
	cmp	x11, x1
	b.ne	LBB24_8
	casl	x9, x10, [x8]
LBB24_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB24_8:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB24_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB24_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB24_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).unwrapNull":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh143:
	adrp	x0, l___anon_4704@PAGE
Lloh144:
	add	x0, x0, l___anon_4704@PAGEOFF
	mov	w1, #25
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh143, Lloh144
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh145:
	adrp	x0, l___anon_4710@PAGE
Lloh146:
	add	x0, x0, l___anon_4710@PAGEOFF
	mov	w1, #19
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh145, Lloh146
	.cfi_endproc

	.p2align	2
l_heap.ArenaAllocator.remap:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x19, x1
	bl	l_heap.ArenaAllocator.resize
	tst	w0, #0x1
	csel	x0, x19, xzr, ne
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
	.cfi_endproc

	.p2align	2
l_heap.ArenaAllocator.resize:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	tst	x0, #0x7
	b.ne	LBB28_18
	cbz	x2, LBB28_17
	cbz	x4, LBB28_17
	ldapur	x9, [x0, #16]
	cbz	x9, LBB28_19
	add	x11, x9, #24
	ldr	x10, [x9, #8]
	add	x8, x11, x10
	add	x12, x1, x2
	cmp	x8, x12
	b.eq	LBB28_6
	cmp	x4, x2
	cset	w0, ls
	b	LBB28_16
LBB28_6:
	subs	x12, x4, x2
	b.ls	LBB28_10
	ldr	x13, [x9], #8
	and	x8, x13, #0xfffffffffffffffe
	cmp	x13, #23
	b.ls	LBB28_21
	sub	x8, x8, #24
	subs	x8, x8, x10
	csel	x8, xzr, x8, lo
	cmp	x8, x12
	b.hs	LBB28_13
	mov	w0, #0
	b	LBB28_16
LBB28_10:
	sub	x8, x2, x4
	subs	x8, x10, x8
	b.lo	LBB28_20
	add	x11, x11, x8
	add	x12, x1, x4
	cmp	x11, x12
	b.ne	LBB28_17
	add	x9, x9, #8
	casl	x10, x8, [x9]
	mov	w0, #1
	b	LBB28_16
LBB28_13:
	adds	x8, x10, x12
	b.hs	LBB28_20
	add	x11, x11, x8
	add	x12, x1, x4
	cmp	x11, x12
	b.ne	LBB28_17
	mov	x11, x10
	casa	x11, x8, [x9]
	cmp	x11, x10
	cset	w0, eq
LBB28_16:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB28_17:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB28_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB28_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB28_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB28_21:
	mov	w0, #24
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.cfi_endproc

	.p2align	2
l_heap.ArenaAllocator.alloc:
	.cfi_startproc
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x28, x27, [sp, #80]
	stp	x26, x25, [sp, #96]
	stp	x24, x23, [sp, #112]
	stp	x22, x21, [sp, #128]
	stp	x20, x19, [sp, #144]
	stp	x29, x30, [sp, #160]
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	tst	x0, #0x7
	b.ne	LBB29_116
	mov	x21, x1
	cbz	x1, LBB29_109
	mov	x13, x0
	ldapur	x23, [x0, #16]
	mov	w14, #1
	lsl	x8, x14, x2
	adds	x9, x21, x8
	cset	w10, hs
	subs	x15, x9, #1
	cset	w9, lo
	stp	w9, w10, [sp, #72]
	mov	x9, #-1
	lsl	x22, x9, x2
	mvn	x16, x22
	add	x8, x8, #24
	adds	x8, x8, x21
	stp	x8, xzr, [sp, #8]
	cset	w8, hs
	str	w8, [sp, #4]
	xpaci	x30
	stp	x30, x0, [sp, #56]
	str	x15, [sp, #48]
LBB29_3:
	cbz	x23, LBB29_23
	ldr	x8, [x23]
	and	x1, x8, #0xfffffffffffffffe
	ldr	w9, [sp, #76]
	tbnz	w9, #0, LBB29_111
	ldr	w9, [sp, #72]
	cbnz	w9, LBB29_111
	add	x19, x23, #24
	cmp	x8, #24
	b.lo	LBB29_113
LBB29_7:
	add	x8, x23, #8
	ldadda	x15, x9, [x8]
	add	x8, x9, x19
	adds	x8, x8, x16
	b.hs	LBB29_112
	adds	x9, x9, x15
	b.hs	LBB29_112
	and	x8, x8, x22
	sub	x8, x8, x19
	adds	x10, x8, x21
	b.hs	LBB29_112
	cmp	x9, x10
	b.lo	LBB29_109
	cmp	x9, x10
	b.eq	LBB29_13
	add	x11, x23, #8
	cas	x9, x10, [x11]
LBB29_13:
	sub	x24, x1, #24
	cmp	x10, x24
	b.ls	LBB29_80
	ldseta	x14, x25, [x23]
	tbnz	w25, #0, LBB29_24
	cmp	x25, #23
	b.ls	LBB29_110
	ldr	x27, [x23, #8]
	add	x8, x27, x19
	adds	x8, x8, x16
	b.hs	LBB29_112
	and	x8, x8, x22
	sub	x20, x8, x19
	adds	x8, x20, #24
	b.hs	LBB29_112
	adds	x8, x8, x21
	b.hs	LBB29_112
	adds	x8, x8, #1
	b.hs	LBB29_112
	and	x26, x8, #0xfffffffffffffffe
	cmp	x26, x25
	b.hi	LBB29_25
	ldr	x8, [x23]
	and	x8, x8, #0xfffffffffffffffe
	cmp	x8, x25
	b.ne	LBB29_109
	stlr	x25, [x23]
	ldr	x8, [x23]
	and	x1, x8, #0xfffffffffffffffe
	cmp	x8, #23
	b.hi	LBB29_7
	b	LBB29_113
LBB29_23:
	mov	x24, #0
LBB29_24:
	add	x8, x13, #24
	swpa	xzr, x26, [x8]
	cbnz	x26, LBB29_31
	b	LBB29_61
LBB29_25:
	ldp	x0, x8, [x13]
	ldr	x8, [x8, #8]
	mov	x1, x23
	mov	x2, x25
	mov	w3, #3
	mov	x4, x26
	mov	x5, x30
	blr	x8
	mov	x8, x25
	tbz	w0, #0, LBB29_29
	adds	x8, x20, x21
	b.hs	LBB29_112
	add	x9, x23, #8
	mov	x10, x27
	casa	x10, x8, [x9]
	cmp	x10, x27
	b.eq	LBB29_101
	mov	x8, x26
LBB29_29:
	ldr	x9, [x23]
	and	x9, x9, #0xfffffffffffffffe
	cmp	x9, x25
	b.ne	LBB29_109
	stlr	x8, [x23]
	ldp	x30, x13, [sp, #56]
	mov	w14, #1
	ldr	x15, [sp, #48]
	mvn	x16, x22
	add	x8, x13, #24
	swpa	xzr, x26, [x8]
	cbz	x26, LBB29_61
LBB29_31:
	mov	x9, #0
	mov	x25, #0
	mov	x19, #0
	mov	x8, #-1
	mov	x10, x26
LBB29_32:
	ldr	x1, [x10]
	tbnz	w1, #0, LBB29_109
	cmp	x1, #23
	b.ls	LBB29_113
	mov	x20, x10
	add	x10, x10, #24
	adds	x11, x10, x16
	b.hs	LBB29_112
	and	x11, x11, x22
	sub	x10, x11, x10
	adds	x10, x10, x21
	b.hs	LBB29_112
	sub	x11, x1, #24
	subs	x10, x10, x11
	csel	x10, xzr, x10, lo
	cmp	x10, x8
	csel	x19, x9, x19, lo
	csel	x25, x20, x25, lo
	csel	x8, x10, x8, lo
	ldr	x10, [x20, #16]
	mov	x9, x20
	cbnz	x10, LBB29_32
	cbz	x25, LBB29_114
	mov	x28, x25
	ldr	x0, [x28], #24
	and	x2, x0, #0xfffffffffffffffe
	cmp	x0, #23
	b.ls	LBB29_115
	adds	x8, x28, x16
	b.hs	LBB29_112
	and	x8, x8, x22
	sub	x17, x8, x28
	adds	x27, x17, x21
	b.hs	LBB29_112
	sub	x8, x2, #24
	cmp	x27, x8
	b.ls	LBB29_48
	adds	x8, x17, #24
	b.hs	LBB29_112
	adds	x8, x8, x21
	b.hs	LBB29_112
	str	x17, [sp, #40]
	adds	x9, x8, #1
	b.hs	LBB29_112
	and	x8, x9, #0xfffffffffffffffe
	stp	x8, x9, [sp, #24]
	ldp	x0, x8, [x13]
	ldr	x8, [x8, #8]
	and	x4, x9, #0xfffffffffffffffe
	mov	x1, x25
	mov	w3, #3
	mov	x5, x30
	blr	x8
	tbz	w0, #0, LBB29_56
	ldr	x8, [sp, #32]
	cmp	x8, #23
	b.ls	LBB29_109
	ldr	x0, [sp, #24]
	str	x0, [x25]
	ldp	x30, x13, [sp, #56]
	mov	w14, #1
	ldp	x17, x15, [sp, #40]
	mvn	x16, x22
LBB29_48:
	ldr	x9, [x25, #16]
	stp	x27, x23, [x25, #8]
	cmp	x25, x23
	b.eq	LBB29_109
	add	x10, x13, #16
	mov	x8, x23
	casal	x8, x25, [x10]
	cmp	x8, x23
	b.eq	LBB29_86
	str	x9, [x25, #16]
	ldr	x9, [x20, #16]
	cmp	x9, x26
	b.eq	LBB29_109
	ldr	x10, [x26, #16]
	cmp	x10, x26
	b.eq	LBB29_109
	cmp	x20, x9
	b.eq	LBB29_109
	add	x10, x13, #24
	mov	x11, x9
	casl	x11, x26, [x10]
	mov	x23, x8
	cmp	x11, x9
	b.eq	LBB29_3
LBB29_54:
	str	x11, [x20, #16]
	mov	x9, x11
	casl	x9, x26, [x10]
	cmp	x9, x11
	mov	x11, x9
	b.ne	LBB29_54
	mov	x23, x8
	b	LBB29_3
LBB29_56:
	ldr	x8, [x20, #16]
	cmp	x8, x26
	b.eq	LBB29_109
	ldr	x9, [x26, #16]
	cmp	x9, x26
	ldp	x30, x13, [sp, #56]
	mov	w14, #1
	ldr	x15, [sp, #48]
	b.eq	LBB29_109
	cmp	x20, x8
	mvn	x16, x22
	b.eq	LBB29_109
	add	x9, x13, #24
	mov	x10, x8
	casl	x10, x26, [x9]
	cmp	x10, x8
	b.eq	LBB29_61
LBB29_60:
	str	x10, [x20, #16]
	mov	x8, x10
	casl	x8, x26, [x9]
	cmp	x8, x10
	mov	x10, x8
	b.ne	LBB29_60
LBB29_61:
	ldr	x8, [sp, #16]
	cbz	x8, LBB29_63
	ldr	x24, [x8]
	and	x1, x24, #0xfffffffffffffffe
	cmp	x24, #23
	b.hi	LBB29_72
	b	LBB29_113
LBB29_63:
	ldr	w8, [sp, #4]
	cbnz	w8, LBB29_112
	ldr	x8, [sp, #8]
	adds	x8, x24, x8
	b.hs	LBB29_112
	adds	x8, x8, #16
	b.hs	LBB29_112
	adds	x8, x8, x8, lsr #1
	b.hs	LBB29_112
	adds	x8, x8, #1
	b.hs	LBB29_112
	cmp	x8, #23
	b.ls	LBB29_109
	and	x24, x8, #0xfffffffffffffffe
	ldp	x0, x8, [x13]
	ldr	x8, [x8]
	mov	x1, x24
	mov	w2, #3
	mov	x3, x30
	blr	x8
	cbz	x0, LBB29_85
	tst	x0, #0x7
	b.ne	LBB29_116
	mov	x8, #-6148914691236517206
	stp	x24, x8, [x0]
	str	x0, [sp, #16]
	str	x8, [x0, #16]
	ldp	x30, x13, [sp, #56]
	mov	w14, #1
	ldr	x15, [sp, #48]
	mvn	x16, x22
	and	x1, x24, #0xfffffffffffffffe
	cmp	x24, #23
	b.ls	LBB29_113
LBB29_72:
	ldr	x8, [sp, #16]
	add	x8, x8, #24
	adds	x9, x8, x16
	b.hs	LBB29_112
	and	x9, x9, x22
	sub	x9, x9, x8
	adds	x10, x9, #24
	b.hs	LBB29_112
	adds	x10, x10, x21
	b.hs	LBB29_112
	cmp	x1, x10
	b.lo	LBB29_109
	adds	x10, x9, x21
	b.hs	LBB29_112
	ldr	x12, [sp, #16]
	stp	x10, x23, [x12, #8]
	cmp	x12, x23
	b.eq	LBB29_109
	add	x11, x13, #16
	mov	x10, x23
	casal	x10, x12, [x11]
	cmp	x10, x23
	b.eq	LBB29_107
	mov	x23, x10
	b	LBB29_3
LBB29_80:
	add	x0, x8, x21
	cmp	x0, x24
	b.hi	LBB29_117
	add	x0, x19, x8
	ldr	x11, [sp, #16]
	cbz	x11, LBB29_85
	mov	x8, #0
	str	xzr, [x11, #16]
	add	x9, x13, #24
	casl	x8, x11, [x9]
	cmp	x8, #0
	b.eq	LBB29_85
	mov	x9, x8
LBB29_84:
	str	x8, [x11, #16]
	add	x10, x13, #24
	casl	x9, x11, [x10]
	cmp	x9, x8
	mov	x8, x9
	b.ne	LBB29_84
LBB29_85:
	.cfi_def_cfa wsp, 176
	ldp	x29, x30, [sp, #160]
	ldp	x20, x19, [sp, #144]
	ldp	x22, x21, [sp, #128]
	ldp	x24, x23, [sp, #112]
	ldp	x26, x25, [sp, #96]
	ldp	x28, x27, [sp, #80]
	add	sp, sp, #176
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB29_86:
	.cfi_restore_state
	cbz	x19, LBB29_88
	str	x9, [x19, #16]
LBB29_88:
	cmp	x25, x26
	csel	x8, x9, x26, eq
	cmp	x25, x20
	csel	x9, x19, x20, eq
	cbz	x8, LBB29_96
	cbz	x9, LBB29_114
	ldr	x10, [x9, #16]
	cmp	x8, x10
	b.eq	LBB29_109
	ldr	x11, [x8, #16]
	cmp	x8, x11
	b.eq	LBB29_109
	cmp	x9, x10
	b.eq	LBB29_109
	add	x12, x13, #24
	mov	x11, x10
	casl	x11, x8, [x12]
	cmp	x11, x10
	b.eq	LBB29_96
	mov	x10, x11
LBB29_95:
	str	x11, [x9, #16]
	add	x12, x13, #24
	casl	x10, x8, [x12]
	cmp	x10, x11
	mov	x11, x10
	b.ne	LBB29_95
LBB29_96:
	and	x8, x0, #0xfffffffffffffffe
	sub	x1, x8, #24
	add	x0, x17, x21
	cmp	x0, x1
	b.hi	LBB29_118
	add	x0, x28, x17
	ldr	x11, [sp, #16]
	cbz	x11, LBB29_85
	mov	x8, #0
	str	xzr, [x11, #16]
	add	x9, x13, #24
	casl	x8, x11, [x9]
	cmp	x8, #0
	b.eq	LBB29_85
	mov	x9, x8
LBB29_100:
	str	x8, [x11, #16]
	add	x10, x13, #24
	casl	x9, x11, [x10]
	cmp	x9, x8
	mov	x8, x9
	b.ne	LBB29_100
	b	LBB29_85
LBB29_101:
	sub	x1, x26, #24
	add	x0, x20, x21
	cmp	x0, x1
	b.hi	LBB29_118
	ldr	x8, [x23]
	and	x8, x8, #0xfffffffffffffffe
	cmp	x8, x25
	ldr	x11, [sp, #64]
	ldr	x12, [sp, #16]
	b.ne	LBB29_109
	add	x0, x19, x20
	stlr	x26, [x23]
	cbz	x12, LBB29_85
	mov	x8, #0
	str	xzr, [x12, #16]
	add	x9, x11, #24
	casl	x8, x12, [x9]
	cmp	x8, #0
	b.eq	LBB29_85
	mov	x9, x8
LBB29_106:
	str	x8, [x12, #16]
	add	x10, x11, #24
	casl	x9, x12, [x10]
	cmp	x9, x8
	mov	x8, x9
	b.ne	LBB29_106
	b	LBB29_85
LBB29_107:
	sub	x1, x1, #24
	add	x0, x9, x21
	cmp	x0, x1
	b.hi	LBB29_118
	add	x0, x8, x9
	b	LBB29_85
LBB29_109:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB29_110:
	mov	w0, #24
	mov	x1, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB29_111:
	cmp	x8, #24
	b.lo	LBB29_113
LBB29_112:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB29_113:
	mov	w0, #24
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB29_114:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB29_115:
	mov	w0, #24
	mov	x1, x2
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB29_116:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB29_117:
	mov	x1, x24
LBB29_118:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).unwrapError":
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh147:
	adrp	x8, l___zig_error_name_table@PAGE
Lloh148:
	add	x8, x8, l___zig_error_name_table@PAGEOFF
	add	x8, x8, w0, uxth #4
	ldp	x9, x8, [x8]
	stp	x9, x8, [sp]
	mov	x0, sp
	bl	l_debug.panicExtra__func_43
	.loh AdrpAdd	Lloh147, Lloh148
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI31_0:
	.quad	4096
	.quad	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_debug.panicExtra__func_43:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	sub	sp, sp, #1, lsl #12
	sub	sp, sp, #48
	mov	x20, x0
	sub	x21, x29, #80
	add	x22, sp, #1
	add	x0, sp, #1
	mov	w1, #170
	mov	w2, #4111
	bl	_memset
Lloh149:
	adrp	x8, l___anon_4078@PAGE
Lloh150:
	add	x8, x8, l___anon_4078@PAGEOFF
	stp	x8, x22, [x21]
Lloh151:
	adrp	x8, lCPI31_0@PAGE
Lloh152:
	ldr	q0, [x8, lCPI31_0@PAGEOFF]
	str	q0, [x21, #16]
	ldp	x19, x20, [x20]
Lloh153:
	adrp	x1, l___anon_5134@PAGE
Lloh154:
	add	x1, x1, l___anon_5134@PAGEOFF
	sub	x0, x29, #80
	mov	w2, #25
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB31_4
	sub	x0, x29, #80
	mov	x1, x19
	mov	x2, x20
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB31_4
	ldp	x8, x1, [x21, #16]
	cmp	x1, x8
	b.ls	LBB31_8
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB31_4:
	add	x8, x22, #1, lsl #12
Lloh155:
	adrp	x10, l___anon_3697@PAGE+15
Lloh156:
	add	x10, x10, l___anon_3697@PAGEOFF+15
Lloh157:
	adrp	x9, l___anon_3697@PAGE
Lloh158:
	add	x9, x9, l___anon_3697@PAGEOFF
	cmp	x8, x10
	b.hs	LBB31_7
	mov	w10, #4111
	add	x10, x22, x10
	cmp	x10, x9
	b.ls	LBB31_7
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB31_7:
	ldr	x10, [x9]
	str	x10, [x8]
	ldur	x9, [x9, #7]
	stur	x9, [x8, #7]
	add	x0, sp, #1
	mov	w1, #4111
	bl	l_debug.defaultPanic
LBB31_8:
	ldr	x0, [x21, #8]
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh153, Lloh154
	.loh AdrpLdr	Lloh151, Lloh152
	.loh AdrpAdd	Lloh149, Lloh150
	.loh AdrpAdd	Lloh157, Lloh158
	.loh AdrpAdd	Lloh155, Lloh156
	.cfi_endproc

	.p2align	2
l_Io.lockStderr:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x0
Lloh159:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh160:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh161:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #56]
Lloh162:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh163:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x8, [x0]
	cbz	x8, LBB32_4
	ldr	x22, [x8, #8]
	adrp	x23, l_Io.Threaded.global_single_threaded_instance@PAGE+736
	ldr	x8, [x23, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+736]
	cmp	x8, x22
	b.ne	LBB32_6
LBB32_2:
Lloh164:
	adrp	x8, l_Io.Threaded.global_single_threaded_instance@PAGE+728
Lloh165:
	ldr	x8, [x8, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+728]
	adds	x8, x8, #1
	b.lo	LBB32_9
LBB32_3:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB32_4:
	mov	x8, #-6148914691236517206
	str	x8, [sp, #16]
	add	x1, sp, #16
	mov	x0, #0
	bl	_pthread_threadid_np
	cbnz	w0, LBB32_43
	ldr	x22, [sp, #16]
	adrp	x23, l_Io.Threaded.global_single_threaded_instance@PAGE+736
	ldr	x8, [x23, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+736]
	cmp	x8, x22
	b.eq	LBB32_2
LBB32_6:
	mov	w8, #0
Lloh166:
	adrp	x20, l_Io.Threaded.global_single_threaded_instance@PAGE+832
Lloh167:
	add	x20, x20, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+832
	mov	w9, #1
	casa	w8, w9, [x20]
	cmp	w8, #0
	b.ne	LBB32_35
LBB32_7:
Lloh168:
	adrp	x8, l_Io.Threaded.global_single_threaded_instance@PAGE+728
Lloh169:
	ldr	x8, [x8, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+728]
	cbnz	x8, LBB32_43
	str	x22, [x23, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+736]
	mov	w8, #1
LBB32_9:
Lloh170:
	adrp	x1, l_Io.Threaded.global_single_threaded_instance@PAGE
Lloh171:
	add	x1, x1, l_Io.Threaded.global_single_threaded_instance@PAGEOFF
	str	x8, [x1, #728]
Lloh172:
	adrp	x2, l___anon_9159@PAGE
Lloh173:
	add	x2, x2, l___anon_9159@PAGEOFF
	add	x0, sp, #32
	bl	l_Io.Threaded.initLockedStderr
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB32_26
	ldp	x20, x21, [sp, #32]
	adrp	x22, l_Progress.global_progress@PAGE+17893
	ldrb	w8, [x22, l_Progress.global_progress@PAGEOFF+17893]
	tbz	w8, #0, LBB32_24
	mov	x23, #0
Lloh174:
	adrp	x24, l___anon_6249@PAGE
Lloh175:
	add	x24, x24, l___anon_6249@PAGEOFF
	mov	w25, #12
Lloh176:
	adrp	x26, l___anon_6249@PAGE+12
Lloh177:
	add	x26, x26, l___anon_6249@PAGEOFF+12
LBB32_12:
	ldr	x9, [x20, #48]
	sub	x27, x25, x23
	adds	x10, x9, x27
	b.hs	LBB32_3
	add	x8, x24, x23
	ldr	x1, [x20, #40]
	cmp	x10, x1
	b.hi	LBB32_20
	add	x0, x9, x27
	cmp	x0, x1
	b.hi	LBB32_39
	ldr	x10, [x20, #32]
	add	x0, x10, x9
	cmp	x0, x26
	b.hs	LBB32_17
	add	x9, x0, x27
	cmp	x8, x9
	b.lo	LBB32_40
LBB32_17:
	add	x1, x24, x23
	sub	x2, x25, x23
	bl	_memcpy
	ldr	x8, [x20, #48]
	adds	x8, x8, x27
	b.hs	LBB32_3
	str	x8, [x20, #48]
	adds	x23, x23, x27
	b.hs	LBB32_3
LBB32_19:
	cmp	x23, #12
	b.lo	LBB32_12
	b	LBB32_23
LBB32_20:
	ldur	x9, [x20, #24]
	ldr	x9, [x9]
	stp	x8, x27, [sp, #16]
	add	x8, sp, #32
	add	x0, x20, #24
	add	x1, sp, #16
	mov	w2, #1
	mov	w3, #1
	blr	x9
	ldrh	w8, [sp, #40]
	cmp	w8, #102
	b.eq	LBB32_28
	cbnz	w8, LBB32_34
	ldr	x27, [sp, #32]
	adds	x23, x23, x27
	b.lo	LBB32_19
	b	LBB32_3
LBB32_23:
	strb	wzr, [x22, l_Progress.global_progress@PAGEOFF+17893]
LBB32_24:
	mov	x0, x20
	ldr	x8, [x0, #24]!
	ldr	x8, [x8, #16]
	blr	x8
	ands	w8, w0, #0xffff
	b.ne	LBB32_31
LBB32_25:
	mov	w0, #0
	mov	w8, #1
	stp	x8, xzr, [x20, #32]
	stp	x20, x21, [x19]
LBB32_26:
	strh	w0, [x19, #16]
	ldr	x8, [sp, #56]
Lloh178:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh179:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh180:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB32_42
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB32_28:
	.cfi_restore_state
	ldrh	w0, [x20, #64]
	cmp	w0, #2
	b.eq	LBB32_26
	cbnz	w0, LBB32_24
LBB32_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB32_31:
	cmp	w8, #102
	b.ne	LBB32_34
	ldrh	w0, [x20, #64]
	cmp	w0, #2
	b.eq	LBB32_26
	cbnz	w0, LBB32_25
	b	LBB32_30
LBB32_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB32_35:
	cmp	w8, #2
	b.eq	LBB32_41
LBB32_36:
	mov	w24, #2
Lloh181:
	adrp	x21, l___anon_2803@PAGE
Lloh182:
	add	x21, x21, l___anon_2803@PAGEOFF
LBB32_37:
	swpa	w24, w8, [x20]
	cbz	w8, LBB32_7
	mov	x0, x20
	mov	w1, #2
	mov	w2, #0
	mov	x3, x21
	bl	l_Io.Threaded.Thread.futexWaitInner
	tst	w0, #0xffff
	b.eq	LBB32_37
	b	LBB32_26
LBB32_39:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB32_40:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB32_41:
Lloh183:
	adrp	x0, l_Io.Threaded.global_single_threaded_instance@PAGE+832
Lloh184:
	add	x0, x0, l_Io.Threaded.global_single_threaded_instance@PAGEOFF+832
Lloh185:
	adrp	x3, l___anon_2803@PAGE
Lloh186:
	add	x3, x3, l___anon_2803@PAGEOFF
	mov	w1, #2
	mov	w2, #0
	bl	l_Io.Threaded.Thread.futexWaitInner
	tst	w0, #0xffff
	b.eq	LBB32_36
	b	LBB32_26
LBB32_42:
	bl	___stack_chk_fail
LBB32_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdr	Lloh162, Lloh163
	.loh AdrpLdrGotLdr	Lloh159, Lloh160, Lloh161
	.loh AdrpLdr	Lloh164, Lloh165
	.loh AdrpAdd	Lloh166, Lloh167
	.loh AdrpLdr	Lloh168, Lloh169
	.loh AdrpAdd	Lloh172, Lloh173
	.loh AdrpAdd	Lloh170, Lloh171
	.loh AdrpAdd	Lloh176, Lloh177
	.loh AdrpAdd	Lloh174, Lloh175
	.loh AdrpLdrGotLdr	Lloh178, Lloh179, Lloh180
	.loh AdrpAdd	Lloh181, Lloh182
	.loh AdrpAdd	Lloh185, Lloh186
	.loh AdrpAdd	Lloh183, Lloh184
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI33_0:
	.quad	8
	.quad	0
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0
lCPI33_1:
	.long	1
	.long	6
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.netLookup:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #608
Lloh187:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh188:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh189:
	ldr	x9, [x9]
	str	x9, [sp]
	stur	x9, [x29, #-88]
	cbz	x0, LBB33_100
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB33_98
	mov	x8, x1
	ldr	x1, [x1]
	ldr	x22, [x8, #8]
	ldr	x21, [x3]
	ldrh	w8, [x3, #8]
	ldrb	w24, [x3, #10]
	ldrb	w23, [x3, #11]
Lloh190:
	adrp	x9, l___anon_3542@PAGE
Lloh191:
	add	x9, x9, l___anon_3542@PAGEOFF
	stp	x20, x9, [sp, #8]
	cmp	x22, #255
	b.hs	LBB33_82
	mov	x19, x2
	movi.16b	v0, #170
	add	x9, sp, #80
	stur	q0, [x9, #255]
	stp	q0, q0, [sp, #304]
	stp	q0, q0, [sp, #272]
	stp	q0, q0, [sp, #240]
	stp	q0, q0, [sp, #208]
	stp	q0, q0, [sp, #176]
	stp	q0, q0, [sp, #144]
	stp	q0, q0, [sp, #112]
	add	x26, sp, #96
	add	x9, x1, x22
	cmp	x26, x9
	str	q0, [sp, #96]
	b.hs	LBB33_5
	add	x9, x26, x22
	cmp	x1, x9
	b.lo	LBB33_99
LBB33_5:
	and	x25, x8, #0xffff
	add	x0, sp, #96
	mov	x2, x22
	bl	_memcpy
	strb	wzr, [x26, x22]
	mov	x8, #-6148914691236517206
	str	x8, [sp, #360]
Lloh192:
	adrp	x8, l___anon_4078@PAGE
Lloh193:
	add	x8, x8, l___anon_4078@PAGEOFF
	add	x9, sp, #360
	stp	x8, x9, [sp, #64]
Lloh194:
	adrp	x8, lCPI33_0@PAGE
Lloh195:
	ldr	q0, [x8, lCPI33_0@PAGEOFF]
	str	q0, [sp, #80]
	mov	w8, #-86
	sturb	w8, [x29, #-96]
	movi.16b	v0, #170
	stp	q0, q0, [x29, #-128]
	stp	q0, q0, [x29, #-160]
	mov	w8, #65
	cmp	w25, #100
	b.lo	LBB33_10
	mov	x9, #62915
	movk	x9, #23592, lsl #16
	movk	x9, #49807, lsl #32
	movk	x9, #10485, lsl #48
	mov	x10, #-100
	sub	x11, x29, #160
Lloh196:
	adrp	x12, l___anon_4180@PAGE
Lloh197:
	add	x12, x12, l___anon_4180@PAGEOFF
LBB33_7:
	subs	x8, x8, #2
	b.lo	LBB33_97
	lsr	x13, x25, #2
	umulh	x13, x13, x9
	lsr	x13, x13, #2
	madd	x14, x13, x10, x25
	ldrh	w14, [x12, x14, lsl #1]
	strh	w14, [x11, x8]
	lsr	x14, x25, #4
	mov	x25, x13
	cmp	x14, #624
	b.hi	LBB33_7
	mov	x25, x13
LBB33_10:
	cmp	x25, #10
	b.hs	LBB33_13
	subs	x8, x8, #1
	b.lo	LBB33_97
	orr	w9, w25, #0x30
	sub	x10, x29, #160
	strb	w9, [x10, x8]
	b	LBB33_15
LBB33_13:
	subs	x8, x8, #2
	b.lo	LBB33_97
Lloh198:
	adrp	x9, l___anon_4180@PAGE
Lloh199:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w9, [x9, x25, lsl #1]
	sub	x10, x29, #160
	strh	w9, [x10, x8]
LBB33_15:
	mov	w9, #65
	sub	x2, x9, x8
	sub	x9, x29, #160
	add	x0, sp, #64
	add	x1, x9, x8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB33_17
Lloh200:
	adrp	x1, l___anon_5936@PAGE
Lloh201:
	add	x1, x1, l___anon_5936@PAGEOFF
	add	x0, sp, #64
	mov	w2, #1
	bl	l_Io.Writer.writeAll
LBB33_17:
	ands	w8, w0, #0xffff
	b.ne	LBB33_87
	ldp	x1, x8, [sp, #80]
	cmp	x8, x1
	b.hi	LBB33_101
	subs	x9, x8, #1
	b.lo	LBB33_97
	cmp	x9, x8
	b.hs	LBB33_102
	ldr	x22, [sp, #72]
	ldrb	w0, [x22, x9]
	cbnz	w0, LBB33_103
	tst	w24, #0x1
	mov	w8, #2
	mov	w9, #30
	csel	w8, w9, w8, ne
	tst	w23, #0x1
	csel	w8, w8, wzr, ne
	cmp	x21, #0
	mov	w9, #4098
	mov	w10, #4096
	csel	w9, w10, w9, eq
	str	w9, [sp, #368]
	str	w8, [sp, #372]
Lloh202:
	adrp	x8, lCPI33_1@PAGE
Lloh203:
	ldr	d0, [x8, lCPI33_1@PAGEOFF]
	str	d0, [sp, #376]
	str	wzr, [sp, #384]
	stp	xzr, xzr, [sp, #400]
	str	xzr, [sp, #392]
	str	xzr, [sp, #24]
	add	x0, sp, #416
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #424]
	cbnz	w0, LBB33_85
	ldr	x23, [sp, #416]
LBB33_24:
	add	x0, sp, #96
	add	x2, sp, #368
	add	x3, sp, #24
	mov	x1, x22
	bl	_getaddrinfo
	cmp	w0, #11
	b.ne	LBB33_29
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB33_96
	cmp	w8, #16, lsl #12
	b.hs	LBB33_96
	cmp	w8, #4
	b.ne	LBB33_44
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB33_24
	b	LBB33_61
LBB33_29:
	cbnz	w0, LBB33_42
	str	x23, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	ldr	x23, [sp, #24]
	cbz	x23, LBB33_60
	mov	x22, #0
	sub	x24, x29, #240
	mov	x25, #8323072
	movk	x25, #256, lsl #32
	b	LBB33_33
LBB33_32:
	ldr	x23, [x23, #40]
	cbz	x23, LBB33_45
LBB33_33:
	ldr	x9, [x23, #32]
	cbz	x9, LBB33_32
	tst	x9, #0x3
	b.ne	LBB33_98
	ldrb	w8, [x9, #1]
	cmp	w8, #30
	b.eq	LBB33_38
	cmp	w8, #2
	b.ne	LBB33_39
	mov	w8, #0
	ldrh	w10, [x9, #2]
	ldr	w9, [x9, #4]
	rev	w10, w10
	lsr	w10, w10, #16
	and	x11, x27, #0xffff000000000000
	orr	x10, x11, x10
	orr	x27, x10, x9, lsl #16
	b	LBB33_40
LBB33_38:
	ldrh	w8, [x9, #2]
	rev16	w26, w8
	ldr	w8, [x9, #4]
	ldr	w10, [x9, #24]
	orr	x27, x8, x10, lsl #32
	ldur	q0, [x9, #8]
	stur	q0, [x29, #-256]
	mov	w8, #1
	b	LBB33_40
LBB33_39:
	mov	w8, #0
	bfxil	x27, x25, #0, #48
LBB33_40:
	stur	x27, [x29, #-240]
	sturh	w26, [x29, #-232]
	ldur	q0, [x29, #-256]
	stur	q0, [x24, #10]
	sturb	w8, [x29, #-212]
	sturb	wzr, [x29, #-208]
	add	x1, sp, #8
	sub	x2, x29, #240
	mov	x0, x19
	bl	"l_Io.Queue(Io.net.HostName.LookupResult).putOne"
	tst	w0, #0xffff
	b.ne	LBB33_83
	ldr	x8, [x23, #24]
	cmp	x22, #0
	ccmp	x8, #0, #4, eq
	csel	x22, x8, x22, ne
	b	LBB33_32
LBB33_42:
	str	x23, [sp, #56]
	mov	x21, x0
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w21, #1
	cmp	w8, #8
	b.hs	LBB33_53
Lloh204:
	adrp	x9, l_switch.table.Io.Threaded.netLookup@PAGE
Lloh205:
	add	x9, x9, l_switch.table.Io.Threaded.netLookup@PAGEOFF
	ldrh	w0, [x9, w8, uxtw #1]
	b	LBB33_61
LBB33_44:
	str	x23, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB33_61
LBB33_45:
	cbz	x22, LBB33_58
	ldrb	w8, [x22]
	cbz	w8, LBB33_54
	mov	x23, #0
	add	x8, x22, #1
LBB33_48:
	cmn	x23, #1
	b.eq	LBB33_97
	ldrb	w9, [x8, x23]
	add	x23, x23, #1
	cbnz	w9, LBB33_48
	cbz	x21, LBB33_58
	sub	x8, x23, #1
	cmp	x8, #254
	b.hs	LBB33_105
	add	x8, x22, x23
	cmp	x21, x8
	b.lo	LBB33_56
	b	LBB33_57
LBB33_53:
	mov	w0, #12
	b	LBB33_61
LBB33_54:
	cbz	x21, LBB33_58
	mov	x23, #0
	add	x8, x22, x23
	cmp	x21, x8
	b.hs	LBB33_57
LBB33_56:
	add	x8, x21, x23
	cmp	x22, x8
	b.lo	LBB33_99
LBB33_57:
	mov	x0, x21
	mov	x1, x22
	mov	x2, x23
	bl	_memcpy
	stp	x21, x23, [x29, #-200]
	mov	w8, #1
	sturb	w8, [x29, #-168]
	add	x1, sp, #8
	sub	x2, x29, #200
	mov	x0, x19
	bl	"l_Io.Queue(Io.net.HostName.LookupResult).putOne"
	tst	w0, #0xffff
	b.ne	LBB33_83
LBB33_58:
	ldr	x0, [sp, #24]
	cbz	x0, LBB33_61
	bl	_freeaddrinfo
LBB33_60:
	mov	w0, #0
LBB33_61:
	mov	w8, #0
	add	x9, x19, #64
	mov	w21, #1
	casa	w8, w21, [x9]
	cmp	w8, #0
	b.ne	LBB33_89
LBB33_62:
	strb	w21, [x19, #68]
	ldr	x20, [x19, #48]
	cbz	x20, LBB33_70
	mov	w21, #1
LBB33_64:
	ldr	w9, [x20, #16]
	and	w8, w9, #0xffff
	cmp	w8, w9, lsr #16
	b.hi	LBB33_66
LBB33_65:
	ldr	x20, [x20, #8]
	cbnz	x20, LBB33_64
	b	LBB33_70
LBB33_66:
	mov	x8, x9
LBB33_67:
	add	w10, w9, #16, lsl #12
	add	x11, x20, #16
	casl	w8, w10, [x11]
	cmp	w8, w9
	b.eq	LBB33_69
	and	w9, w8, #0xffff
	cmp	w9, w8, lsr #16
	mov	x9, x8
	b.ls	LBB33_65
	b	LBB33_67
LBB33_69:
	add	x8, x20, #20
	ldaddl	w21, w8, [x8]
	mov	x22, x0
	add	x0, x20, #20
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	mov	x0, x22
	b	LBB33_65
LBB33_70:
	ldr	x20, [x19, #32]
	cbz	x20, LBB33_78
	mov	w21, #1
LBB33_72:
	ldr	w9, [x20, #16]
	and	w8, w9, #0xffff
	cmp	w8, w9, lsr #16
	b.hi	LBB33_74
LBB33_73:
	ldr	x20, [x20, #8]
	cbnz	x20, LBB33_72
	b	LBB33_78
LBB33_74:
	mov	x8, x9
LBB33_75:
	add	w10, w9, #16, lsl #12
	add	x11, x20, #16
	casl	w8, w10, [x11]
	cmp	w8, w9
	b.eq	LBB33_77
	and	w9, w8, #0xffff
	cmp	w9, w8, lsr #16
	mov	x9, x8
	b.ls	LBB33_73
	b	LBB33_75
LBB33_77:
	add	x8, x20, #20
	ldaddl	w21, w8, [x8]
	mov	x22, x0
	add	x0, x20, #20
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	mov	x0, x22
	b	LBB33_73
LBB33_78:
	add	x8, x19, #64
	swpl	wzr, w8, [x8]
	cbz	w8, LBB33_82
	cmp	w8, #1
	b.eq	LBB33_93
	cmp	w8, #2
	b.eq	LBB33_92
LBB33_81:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB33_82:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB33_83:
	ldr	x8, [sp, #24]
	cbz	x8, LBB33_85
	mov	x21, x0
	mov	x0, x8
	bl	_freeaddrinfo
	mov	x0, x21
LBB33_85:
	and	w8, w0, #0xffff
	cmp	w8, #103
	b.ne	LBB33_61
	mov	w0, #103
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB33_87:
	cmp	w8, #102
	b.ne	LBB33_81
	mov	w0, #16
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB33_89:
	cmp	w8, #2
	b.eq	LBB33_95
	add	x8, x19, #64
	mov	w22, #2
	swpa	w22, w8, [x8]
	cbz	w8, LBB33_62
LBB33_91:
	add	x24, x19, #64
	add	x1, x19, #64
	mov	x23, x0
	mov	x0, x20
	mov	w2, #2
	bl	l_Io.Threaded.futexWaitUncancelable
	mov	x0, x23
	swpa	w22, w8, [x24]
	cbnz	w8, LBB33_91
	b	LBB33_62
LBB33_92:
	mov	x20, x0
	add	x0, x19, #64
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	mov	x0, x20
LBB33_93:
	ldur	x8, [x29, #-88]
Lloh206:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh207:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh208:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB33_104
	add	sp, sp, #608
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB33_95:
	.cfi_restore_state
	add	x1, x19, #64
	mov	x22, x0
	mov	x0, x20
	mov	w2, #2
	bl	l_Io.Threaded.futexWaitUncancelable
	mov	x0, x22
	add	x8, x19, #64
	mov	w22, #2
	swpa	w22, w8, [x8]
	cbnz	w8, LBB33_91
	b	LBB33_62
LBB33_96:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB33_97:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB33_98:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB33_99:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB33_100:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB33_101:
	mov	x0, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB33_102:
	add	x0, x9, #1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB33_103:
	bl	"l_debug.FullPanic((function 'defaultPanic')).sentinelMismatch__func_47"
LBB33_104:
	bl	___stack_chk_fail
LBB33_105:
	mov	x0, x23
	mov	w1, #254
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh187, Lloh188, Lloh189
	.loh AdrpAdd	Lloh190, Lloh191
	.loh AdrpLdr	Lloh194, Lloh195
	.loh AdrpAdd	Lloh192, Lloh193
	.loh AdrpAdd	Lloh196, Lloh197
	.loh AdrpAdd	Lloh198, Lloh199
	.loh AdrpAdd	Lloh200, Lloh201
	.loh AdrpLdr	Lloh202, Lloh203
	.loh AdrpAdd	Lloh204, Lloh205
	.loh AdrpLdrGotLdr	Lloh206, Lloh207, Lloh208
	.cfi_endproc

	.p2align	2
"l_Io.Queue(Io.net.HostName.LookupResult).putOne":
	.cfi_startproc
	sub	sp, sp, #320
	.cfi_def_cfa_offset 320
	stp	x28, x27, [sp, #224]
	stp	x26, x25, [sp, #240]
	stp	x24, x23, [sp, #256]
	stp	x22, x21, [sp, #272]
	stp	x20, x19, [sp, #288]
	stp	x29, x30, [sp, #304]
	add	x29, sp, #304
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x20, x1
	mov	x21, x0
	mov	w8, #0
Lloh209:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh210:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh211:
	ldr	x9, [x9]
	str	x9, [sp, #24]
	stur	x9, [x29, #-104]
	ldp	q0, q1, [x2]
	stp	q0, q1, [sp, #96]
	ldr	x9, [x2, #32]
	str	x9, [sp, #128]
	add	x19, x0, #64
	ldp	x22, x23, [x1]
	mov	w9, #1
	casa	w8, w9, [x19]
	cmp	w8, #0
	b.ne	LBB34_108
LBB34_1:
	ldrb	w8, [x21, #68]
	tbz	w8, #0, LBB34_3
LBB34_2:
	mov	w22, #0
	mov	w0, #103
	b	LBB34_41
LBB34_3:
	mov	x25, #0
	ldp	x9, x8, [x20]
	stp	x8, x9, [sp, #8]
	mov	w24, #40
	add	x27, sp, #96
	mov	w28, #1
LBB34_4:
	ldr	x26, [x21, #48]
	cbz	x26, LBB34_19
	ldr	x9, [x26]
	cbz	x9, LBB34_8
	ldr	x8, [x26, #8]
	str	x8, [x9, #8]
	ldr	x9, [x26]
	cbz	x8, LBB34_9
LBB34_7:
	str	x9, [x8]
	ldur	x8, [x26, #-16]
	sub	x9, x24, x25
	cmp	x8, x9
	csel	x23, x8, x9, lo
	cbnz	x23, LBB34_10
	b	LBB34_116
LBB34_8:
	ldr	x8, [x26, #8]
	str	x8, [x21, #48]
	ldr	x9, [x26]
	cbnz	x8, LBB34_7
LBB34_9:
	str	x9, [x21, #56]
	ldur	x8, [x26, #-16]
	sub	x9, x24, x25
	cmp	x8, x9
	csel	x23, x8, x9, lo
	cbz	x23, LBB34_116
LBB34_10:
	sub	x22, x26, #24
	ldr	x0, [x22]
	add	x8, x27, x25
	add	x9, x8, x23
	add	x10, x0, x23
	cmp	x0, x9
	ccmp	x8, x10, #2, lo
	b.lo	LBB34_124
	add	x1, x27, x25
	mov	x2, x23
	bl	_memcpy
	ldr	x1, [x22, #8]
	subs	x8, x1, x23
	b.lo	LBB34_125
	add	x25, x23, x25
	ldr	x9, [x22]
	add	x9, x9, x23
	stp	x9, x8, [x22]
	ldr	x8, [x22, #16]
	subs	x8, x8, x23
	csel	x8, xzr, x8, lo
	str	x8, [x22, #16]
	b.hi	LBB34_31
	ldp	x0, x8, [x20]
	ldr	w10, [x22, #40]
	and	w9, w10, #0xffff
	cmp	w9, w10, lsr #16
	b.hi	LBB34_15
LBB34_14:
	cmp	x25, #40
	b.ne	LBB34_4
	b	LBB34_30
LBB34_15:
	mov	x9, x10
LBB34_16:
	add	w11, w10, #16, lsl #12
	add	x12, x22, #40
	casl	w9, w11, [x12]
	cmp	w9, w10
	b.eq	LBB34_18
	and	w10, w9, #0xffff
	cmp	w10, w9, lsr #16
	mov	x10, x9
	b.ls	LBB34_14
	b	LBB34_16
LBB34_18:
	add	x1, x22, #44
	ldaddl	w28, w9, [x1]
	ldr	x8, [x8, #112]
	mov	w2, #1
	blr	x8
	b	LBB34_14
LBB34_19:
	ldr	x9, [x21, #24]
	mov	w24, #40
	add	x26, sp, #96
LBB34_20:
	ldr	x8, [x21, #16]
	adds	x0, x8, x9
	b.hs	LBB34_129
	ldr	x1, [x21, #8]
	subs	x9, x0, x1
	b.hs	LBB34_24
	subs	x10, x1, x0
	b.lo	LBB34_126
	ldr	x8, [x21]
	add	x0, x8, x0
	cmp	x10, #0
	ccmp	x0, #0, #4, ne
	b.ne	LBB34_27
	b	LBB34_35
LBB34_24:
	subs	x10, x8, x9
	b.lo	LBB34_132
	cmp	x8, x1
	b.hi	LBB34_131
	ldr	x8, [x21]
	add	x0, x8, x9
	cmp	x10, #0
	ccmp	x0, #0, #4, ne
	b.eq	LBB34_35
LBB34_27:
	sub	x8, x24, x25
	cmp	x10, x8
	csel	x23, x10, x8, lo
	add	x8, x26, x25
	add	x9, x8, x23
	add	x10, x0, x23
	cmp	x0, x9
	ccmp	x8, x10, #2, lo
	b.lo	LBB34_124
	add	x1, x26, x25
	mov	x2, x23
	bl	_memcpy
	ldr	x8, [x21, #24]
	adds	x9, x8, x23
	b.hs	LBB34_129
	add	x25, x23, x25
	str	x9, [x21, #24]
	cmp	x25, #40
	b.ne	LBB34_20
LBB34_30:
	mov	w0, #0
	mov	w22, #1
	b	LBB34_41
LBB34_31:
	cmp	x25, #40
	b.ne	LBB34_116
	ldr	x8, [x21, #48]
	cbz	x8, LBB34_38
	str	x8, [x26, #8]
	ldr	x9, [x8]
	cbz	x9, LBB34_39
	str	x9, [x26]
	str	x26, [x9, #8]
	b	LBB34_40
LBB34_35:
	add	x8, sp, #96
	add	x8, x8, x25
	mov	w9, #40
	sub	x9, x9, x25
	stp	x8, x9, [sp, #32]
	add	x8, sp, #32
	add	x8, x8, #24
	stp	x9, xzr, [sp, #48]
	stp	xzr, xzr, [sp, #64]
	ldr	x9, [x21, #40]
	cbz	x9, LBB34_45
	str	x9, [sp, #56]
	ldr	x10, [x9, #8]
	cbz	x10, LBB34_48
	str	x10, [sp, #64]
	str	x8, [x10]
	str	x8, [x9, #8]
	b	LBB34_52
LBB34_38:
	mov	w0, #0
	stp	x26, x26, [x21, #48]
	mov	w22, #1
	mov	w24, #40
	stp	xzr, xzr, [x26]
	b	LBB34_41
LBB34_39:
	str	xzr, [x26]
	str	x26, [x21, #48]
LBB34_40:
	mov	w0, #0
	str	x26, [x8]
	mov	w22, #1
	mov	w24, #40
LBB34_41:
	ldp	x8, x9, [x20]
	swpl	wzr, w10, [x19]
	cbz	w10, LBB34_116
	cmp	w10, #1
	b.eq	LBB34_110
	cmp	w10, #2
	b.eq	LBB34_109
LBB34_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB34_45:
	ldr	x9, [x21, #32]
	cbz	x9, LBB34_49
	str	x9, [sp, #64]
	ldr	x10, [x9]
	cbz	x10, LBB34_50
	str	x10, [sp, #56]
	str	x8, [x10, #8]
	b	LBB34_51
LBB34_48:
	str	x8, [x21, #40]
	str	x8, [x9, #8]
	b	LBB34_52
LBB34_49:
	stp	x8, x8, [x21, #32]
	stp	xzr, xzr, [x8]
	b	LBB34_52
LBB34_50:
	str	x8, [x21, #32]
LBB34_51:
	str	x8, [x9]
LBB34_52:
	add	x28, sp, #32
	movi.2d	v0, #0000000000000000
	mov	w25, #1
	mov	w26, #65535
LBB34_53:
	ldr	x8, [sp, #48]
	cbz	x8, LBB34_93
	ldrb	w9, [x21, #68]
	tbnz	w9, #0, LBB34_93
	ldp	x23, x27, [x20]
	str	q0, [sp, #144]
	add	x8, sp, #144
	stp	q0, q0, [x8, #16]
	ldapur	w2, [sp, #76]
	add	x8, x28, #40
	ldadd	w25, w8, [x8]
	bics	wzr, w26, w8
	b.eq	LBB34_116
	ldp	x0, x8, [x20]
	swpl	wzr, w9, [x19]
	cbz	w9, LBB34_116
	cmp	w9, #1
	b.eq	LBB34_60
	cmp	w9, #2
	b.ne	LBB34_44
	ldr	x8, [x8, #112]
	add	x1, x21, #64
	mov	x22, x2
	mov	w2, #1
	blr	x8
	mov	x2, x22
LBB34_60:
	ldr	x8, [x27, #96]
	add	x1, x28, #44
	add	x3, sp, #144
	mov	x0, x23
	blr	x8
	ldapur	w24, [sp, #76]
	tst	w0, #0xffff
	b.ne	LBB34_72
LBB34_61:
	ldr	w8, [sp, #72]
	cmp	w8, #16, lsl #12
	movi.2d	v0, #0000000000000000
	b.lo	LBB34_65
LBB34_62:
	and	w9, w8, #0xffff
	sub	w9, w9, #1
	tst	w9, #0xffff0000
	b.ne	LBB34_129
	mov	x10, x8
	bfxil	w10, w9, #0, #16
	sub	w10, w10, #16, lsl #12
	add	x11, x28, #40
	mov	x9, x8
	casa	w9, w10, [x11]
	cmp	w9, w8
	b.eq	LBB34_82
	mov	x8, x9
	cmp	w9, #16, lsl #12
	b.hs	LBB34_62
LBB34_65:
	ldrb	w8, [sp, #176]
	and	w8, w8, #0x3
	cmp	w8, #1
	b.gt	LBB34_67
	cbz	w8, LBB34_71
	b	LBB34_116
LBB34_67:
	cmp	w8, #2
	b.ne	LBB34_44
	ldp	x26, x22, [sp, #144]
	ldp	x0, x8, [x20]
	ldr	x9, [x8, #704]
	ldrb	w25, [sp, #160]
	add	x8, sp, #80
	mov	x1, x25
	blr	x9
	cmp	w25, #8
	b.hs	LBB34_116
	ldp	x9, x8, [sp, #80]
	sxtw	x8, w8
	sxtw	x10, w22
	cmp	x9, x26
	sbc	x8, x8, x10
	sxtw	x9, w8
	eor	x9, x9, x8
	cbnz	x9, LBB34_129
	add	x9, sp, #32
	mov	w25, #1
	mov	w26, #65535
	tbz	w8, #31, LBB34_137
LBB34_71:
	ldr	x8, [x27, #96]
	add	x1, x28, #44
	add	x3, sp, #144
	mov	x0, x23
	mov	x2, x24
	blr	x8
	ldapur	w24, [sp, #76]
	tst	w0, #0xffff
	b.eq	LBB34_61
LBB34_72:
	movi.2d	v0, #0000000000000000
	ldp	x23, x24, [x20]
	ldr	w8, [sp, #72]
	and	w9, w8, #0xffff
	sub	w10, w9, #1
	tst	w10, #0xffff0000
	b.ne	LBB34_129
LBB34_73:
	lsr	w9, w8, #16
	and	w11, w10, #0xffff
	cmp	w9, w11
	csel	w11, w9, w11, lo
	bfi	w10, w11, #16, #16
	add	x12, x28, #40
	mov	x11, x8
	cas	w11, w10, [x12]
	cmp	w11, w8
	b.eq	LBB34_76
	and	w9, w11, #0xffff
	sub	w10, w9, #1
	tst	w10, #0xffff0000
	b.ne	LBB34_129
	mov	x8, x11
	b	LBB34_73
LBB34_76:
	cbz	w9, LBB34_79
	cmp	w9, w8, uxth
	b.hs	LBB34_79
	add	x8, x28, #44
	ldaddl	w25, w8, [x8]
	ldr	x8, [x24, #112]
	add	x1, x28, #44
	mov	x22, x0
	mov	x0, x23
	mov	w2, #1
	blr	x8
	movi.2d	v0, #0000000000000000
	mov	x0, x22
	ldp	x23, x24, [x20]
LBB34_79:
	mov	w8, #0
	casa	w8, w25, [x19]
	cmp	w8, #0
	b.ne	LBB34_85
LBB34_80:
	ands	w8, w0, #0xffff
	b.eq	LBB34_84
	cmp	w8, #2
	b.ne	LBB34_123
	b	LBB34_84
LBB34_82:
	mov	w8, #0
	ldp	x23, x22, [x20]
	casa	w8, w25, [x19]
	cmp	w8, #0
	b.ne	LBB34_89
LBB34_83:
	mov	w0, #0
LBB34_84:
	ands	w8, w0, #0xffff
	b.eq	LBB34_53
	b	LBB34_117
LBB34_85:
	mov	x22, x0
	cmp	w8, #2
	b.ne	LBB34_87
	ldr	x8, [x24, #104]
	add	x1, x21, #64
	mov	x0, x23
	mov	w2, #2
	blr	x8
LBB34_87:
	mov	w8, #2
	swpa	w8, w8, [x19]
	mov	x0, x22
	movi.2d	v0, #0000000000000000
	mov	w25, #1
	mov	w26, #65535
	cbz	w8, LBB34_80
LBB34_88:
	ldr	x8, [x24, #104]
	add	x1, x21, #64
	mov	x0, x23
	mov	w2, #2
	blr	x8
	movi.2d	v0, #0000000000000000
	mov	x0, x22
	mov	w8, #2
	swpa	w8, w8, [x19]
	cbnz	w8, LBB34_88
	b	LBB34_80
LBB34_89:
	cmp	w8, #2
	b.ne	LBB34_91
	ldr	x8, [x22, #104]
	add	x1, x21, #64
	mov	x0, x23
	mov	w2, #2
	blr	x8
LBB34_91:
	mov	w24, #2
	swpa	w24, w8, [x19]
	movi.2d	v0, #0000000000000000
	mov	w25, #1
	mov	w26, #65535
	cbz	w8, LBB34_83
LBB34_92:
	ldr	x8, [x22, #104]
	add	x1, x21, #64
	mov	x0, x23
	mov	w2, #2
	blr	x8
	movi.2d	v0, #0000000000000000
	swpa	w24, w8, [x19]
	cbnz	w8, LBB34_92
	b	LBB34_83
LBB34_93:
	ldr	x9, [sp, #40]
	cmp	x9, #40
	b.ne	LBB34_99
	ldrb	w9, [x21, #68]
	tbz	w9, #0, LBB34_116
	cbz	x8, LBB34_2
	ldr	x8, [sp, #56]
	cbz	x8, LBB34_106
	ldr	x9, [sp, #64]
	str	x9, [x8, #8]
	ldr	x8, [sp, #56]
	cbz	x9, LBB34_107
LBB34_98:
	mov	w22, #0
	str	x8, [x9]
	mov	w0, #103
	b	LBB34_41
LBB34_99:
	mov	w10, #40
	subs	x24, x10, x9
	b.lo	LBB34_129
	cbz	x8, LBB34_30
LBB34_101:
	ldr	x8, [sp, #56]
	cbz	x8, LBB34_104
	ldr	x9, [sp, #64]
	str	x9, [x8, #8]
	ldr	x8, [sp, #56]
	cbz	x9, LBB34_105
LBB34_103:
	mov	w0, #0
	str	x8, [x9]
	mov	w22, #1
	b	LBB34_41
LBB34_104:
	ldr	x9, [sp, #64]
	str	x9, [x21, #32]
	cbnz	x9, LBB34_103
LBB34_105:
	mov	w0, #0
	str	x8, [x21, #40]
	mov	w22, #1
	b	LBB34_41
LBB34_106:
	ldr	x9, [sp, #64]
	str	x9, [x21, #32]
	cbnz	x9, LBB34_98
LBB34_107:
	mov	w22, #0
	str	x8, [x21, #40]
	mov	w0, #103
	b	LBB34_41
LBB34_108:
	cmp	w8, #2
	b.ne	LBB34_140
	b	LBB34_139
LBB34_109:
	ldr	x9, [x9, #112]
	mov	x20, x0
	mov	x0, x8
	mov	x1, x19
	mov	w2, #1
	blr	x9
	mov	x0, x20
LBB34_110:
	cbz	w22, LBB34_114
	mov	x8, #-3689348814741910324
	movk	x8, #52429
	mul	x8, x24, x8
	ror	x8, x8, #3
	mov	x9, #7378697629483820646
	movk	x9, #1638, lsl #48
	cmp	x8, x9
	b.hi	LBB34_136
	sub	x8, x24, #40
	cmp	x8, #40
	b.hs	LBB34_116
	mov	w0, #0
LBB34_114:
	ldur	x8, [x29, #-104]
Lloh212:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh213:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh214:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB34_135
	.cfi_def_cfa wsp, 320
	ldp	x29, x30, [sp, #304]
	ldp	x20, x19, [sp, #288]
	ldp	x22, x21, [sp, #272]
	ldp	x24, x23, [sp, #256]
	ldp	x26, x25, [sp, #240]
	ldp	x28, x27, [sp, #224]
	add	sp, sp, #320
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB34_116:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB34_117:
	cmp	w8, #2
	b.ne	LBB34_44
	ldr	x8, [sp, #40]
	cmp	x8, #40
	b.ne	LBB34_127
	ldr	x8, [sp, #48]
	cbz	x8, LBB34_130
	ldr	x8, [sp, #56]
	cbz	x8, LBB34_133
	ldr	x9, [sp, #64]
	str	x9, [x8, #8]
	ldr	x8, [sp, #56]
	cbz	x9, LBB34_134
LBB34_122:
	mov	w22, #0
	str	x8, [x9]
	mov	w0, #2
	b	LBB34_41
LBB34_123:
	cmp	w8, #35
	b.ne	LBB34_44
	b	LBB34_138
LBB34_124:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB34_125:
	mov	x0, x23
LBB34_126:
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB34_127:
	ldp	x8, x0, [sp, #8]
	ldr	x8, [x8, #72]
	blr	x8
	ldr	x8, [sp, #40]
	mov	w9, #40
	subs	x24, x9, x8
	b.lo	LBB34_129
	ldr	x8, [sp, #48]
	cbnz	x8, LBB34_101
	b	LBB34_30
LBB34_129:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB34_130:
	mov	w22, #0
	mov	w0, #2
	b	LBB34_41
LBB34_131:
	mov	x0, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB34_132:
	mov	x0, x9
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB34_133:
	ldr	x9, [sp, #64]
	str	x9, [x21, #32]
	cbnz	x9, LBB34_122
LBB34_134:
	mov	w22, #0
	str	x8, [x21, #40]
	mov	w0, #2
	b	LBB34_41
LBB34_135:
	bl	___stack_chk_fail
LBB34_136:
	bl	"l_debug.FullPanic((function 'defaultPanic')).exactDivisionRemainder"
LBB34_137:
	add	x0, x9, #40
	mov	x1, x20
	bl	l_Io.Condition.deregister
	ldp	x1, x2, [x20]
	mov	x0, x19
	bl	l_Io.Mutex.lockUncancelable
LBB34_138:
	mov	w0, #35
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB34_139:
	ldr	x8, [x23, #96]
Lloh215:
	adrp	x3, l___anon_5690@PAGE
Lloh216:
	add	x3, x3, l___anon_5690@PAGEOFF
	add	x1, x21, #64
	mov	x0, x22
	mov	w2, #2
	blr	x8
	tst	w0, #0xffff
	b.ne	LBB34_114
LBB34_140:
	mov	w8, #2
	swpa	w8, w8, [x19]
	cbnz	w8, LBB34_139
	b	LBB34_1
	.loh AdrpLdrGotLdr	Lloh209, Lloh210, Lloh211
	.loh AdrpLdrGotLdr	Lloh212, Lloh213, Lloh214
	.loh AdrpAdd	Lloh215, Lloh216
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).exactDivisionRemainder":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh217:
	adrp	x0, l___anon_5575@PAGE
Lloh218:
	add	x0, x0, l___anon_5575@PAGEOFF
	mov	w1, #33
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh217, Lloh218
	.cfi_endproc

	.p2align	2
l_Io.Condition.deregister:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x8, x0
	ldp	x0, x9, [x1]
	ldr	w10, [x8]
	and	w11, w10, #0xffff
	sub	w13, w11, #1
	tst	w13, #0xffff0000
	b.ne	LBB36_8
LBB36_1:
	lsr	w11, w10, #16
	and	w12, w13, #0xffff
	cmp	w11, w12
	csel	w12, w11, w12, lo
	bfi	w13, w12, #16, #16
	mov	x12, x10
	cas	w12, w13, [x8]
	cmp	w12, w10
	b.eq	LBB36_4
	and	w11, w12, #0xffff
	sub	w13, w11, #1
	tst	w13, #0xffff0000
	b.ne	LBB36_8
	mov	x10, x12
	b	LBB36_1
LBB36_4:
	cbz	w11, LBB36_7
	cmp	w11, w10, uxth
	b.hs	LBB36_7
	add	x1, x8, #4
	mov	w8, #1
	ldaddl	w8, w8, [x1]
	ldr	x3, [x9, #112]
	mov	w2, #1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	br	x3
LBB36_7:
	.cfi_restore_state
	.cfi_remember_state
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB36_8:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Syscall.checkCancel:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	ldr	x8, [x0]
	cbz	x8, LBB37_3
	add	x8, x8, #24
	mov	w9, #2
	ldset	x9, x8, [x8]
	and	w8, w8, #0x7
	cmp	w8, #3
	b.gt	LBB37_4
	cmp	w8, #2
	b.le	LBB37_8
LBB37_3:
	mov	w0, #0
	b	LBB37_7
LBB37_4:
	cmp	w8, #5
	b.gt	LBB37_10
	b.ne	LBB37_11
	mov	w0, #2
LBB37_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB37_8:
	.cfi_restore_state
	cbz	w8, LBB37_11
	cmp	w8, #1
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB37_10:
	cmp	w8, #6
LBB37_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Syscall.finish:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	ldr	x8, [x0]
	cbz	x8, LBB38_7
	add	x8, x8, #24
	mov	w9, #3
	ldeor	x9, x8, [x8]
	and	w8, w8, #0x7
	cmp	w8, #3
	b.gt	LBB38_5
	cmp	w8, #2
	b.gt	LBB38_7
	cbz	w8, LBB38_9
	cmp	w8, #1
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB38_5:
	cmp	w8, #5
	b.gt	LBB38_8
	b.ne	LBB38_9
LBB38_7:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB38_8:
	.cfi_restore_state
	cmp	w8, #6
LBB38_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Syscall.start:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x8, x0
Lloh219:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh220:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x9, [x0]
	blr	x9
	ldr	x9, [x0]
	cbz	x9, LBB39_5
	ldrb	w10, [x9, #552]
	tbnz	w10, #0, LBB39_5
	add	x10, x9, #24
	mov	w11, #3
	ldset	x11, x10, [x10]
	and	w10, w10, #0x7
	cmp	w10, #4
	b.le	LBB39_7
	cmp	w10, #6
	b.eq	LBB39_9
	cmp	w10, #7
	b.ne	LBB39_12
LBB39_5:
	strh	wzr, [x8, #8]
	str	xzr, [x8]
LBB39_6:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB39_7:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w10, #0
	b.gt	LBB39_10
	strh	wzr, [x8, #8]
	str	x9, [x8]
	b	LBB39_6
LBB39_9:
Lloh221:
	adrp	x9, l___anon_5930@PAGE
Lloh222:
	add	x9, x9, l___anon_5930@PAGEOFF
Lloh223:
	ldr	q0, [x9]
	str	q0, [x8]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB39_10:
	.cfi_restore_state
	cmp	w10, #2
	b.gt	LBB39_13
	cmp	w10, #1
LBB39_12:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB39_13:
	cmp	w10, #3
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdr	Lloh219, Lloh220
	.loh AdrpAddLdr	Lloh221, Lloh222, Lloh223
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).sentinelMismatch__func_47":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	l_debug.panicExtra__func_68
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI41_0:
	.quad	4096
	.quad	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_debug.panicExtra__func_68:
	.cfi_startproc
	stp	x22, x21, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	sub	sp, sp, #1, lsl #12
	sub	sp, sp, #128
	mov	x19, x0
	sub	x20, x29, #144
	add	x21, sp, #1
	add	x0, sp, #1
	mov	w1, #170
	mov	w2, #4111
	bl	_memset
Lloh224:
	adrp	x8, l___anon_4078@PAGE
Lloh225:
	add	x8, x8, l___anon_4078@PAGEOFF
	stp	x8, x21, [x20]
Lloh226:
	adrp	x8, lCPI41_0@PAGE
Lloh227:
	ldr	q0, [x8, lCPI41_0@PAGEOFF]
	str	q0, [x20, #16]
Lloh228:
	adrp	x1, l___anon_6031@PAGE
Lloh229:
	add	x1, x1, l___anon_6031@PAGEOFF
	sub	x0, x29, #144
	mov	w2, #28
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB41_12
	sub	x8, x29, #112
	movi.16b	v0, #170
	stp	q0, q0, [x20, #64]
	stp	q0, q0, [x20, #32]
	mov	w9, #48
	strb	w9, [x20, #96]
	sub	x0, x29, #144
	add	x1, x8, #64
	mov	w2, #1
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB41_12
Lloh230:
	adrp	x1, l___anon_6066@PAGE
Lloh231:
	add	x1, x1, l___anon_6066@PAGEOFF
	sub	x0, x29, #144
	mov	w2, #8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB41_12
	mov	w8, #-86
	strb	w8, [x20, #96]
	movi.16b	v0, #170
	stp	q0, q0, [x20, #64]
	stp	q0, q0, [x20, #32]
	and	w8, w19, #0xff
	cmp	w8, #99
	b.ls	LBB41_5
	mov	w9, #41
	mul	w8, w8, w9
	lsr	w9, w8, #12
	mov	w8, #-100
	madd	w8, w9, w8, w19
Lloh232:
	adrp	x10, l___anon_4180@PAGE
Lloh233:
	add	x10, x10, l___anon_4180@PAGEOFF
	and	x8, x8, #0xff
	ldrh	w8, [x10, x8, lsl #1]
	sturh	w8, [x20, #95]
	mov	w8, #62
	mov	x19, x9
	b	LBB41_7
LBB41_5:
	cmp	w8, #10
	b.hs	LBB41_8
	mov	w8, #64
LBB41_7:
	orr	w9, w19, #0x30
	sub	x10, x29, #112
	strb	w9, [x10, x8]
	b	LBB41_9
LBB41_8:
	and	x8, x19, #0xff
Lloh234:
	adrp	x9, l___anon_4180@PAGE
Lloh235:
	add	x9, x9, l___anon_4180@PAGEOFF
	ldrh	w8, [x9, x8, lsl #1]
	sturh	w8, [x20, #95]
	mov	w8, #63
LBB41_9:
	mov	w9, #65
	sub	x2, x9, x8
	sub	x9, x29, #112
	sub	x0, x29, #144
	add	x1, x9, x8
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB41_12
	ldp	x8, x1, [x20, #16]
	cmp	x1, x8
	b.ls	LBB41_16
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB41_12:
	add	x8, x21, #1, lsl #12
Lloh236:
	adrp	x10, l___anon_3697@PAGE+15
Lloh237:
	add	x10, x10, l___anon_3697@PAGEOFF+15
Lloh238:
	adrp	x9, l___anon_3697@PAGE
Lloh239:
	add	x9, x9, l___anon_3697@PAGEOFF
	cmp	x8, x10
	b.hs	LBB41_15
	mov	w10, #4111
	add	x10, x21, x10
	cmp	x10, x9
	b.ls	LBB41_15
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB41_15:
	ldr	x10, [x9]
	str	x10, [x8]
	ldur	x9, [x9, #7]
	stur	x9, [x8, #7]
	add	x0, sp, #1
	mov	w1, #4111
	bl	l_debug.defaultPanic
LBB41_16:
	ldr	x0, [x20, #8]
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh228, Lloh229
	.loh AdrpLdr	Lloh226, Lloh227
	.loh AdrpAdd	Lloh224, Lloh225
	.loh AdrpAdd	Lloh230, Lloh231
	.loh AdrpAdd	Lloh232, Lloh233
	.loh AdrpAdd	Lloh234, Lloh235
	.loh AdrpAdd	Lloh238, Lloh239
	.loh AdrpAdd	Lloh236, Lloh237
	.cfi_endproc

	.p2align	2
l_Io.Mutex.lockUncancelable:
	.cfi_startproc
	stp	x22, x21, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	w8, #0
	mov	w9, #1
	casa	w8, w9, [x0]
	cmp	w8, #0
	b.ne	LBB42_2
LBB42_1:
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x22, x21, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB42_2:
	.cfi_restore_state
	cmp	w8, #2
	mov	x20, x2
	mov	x21, x1
	mov	x19, x0
	b.ne	LBB42_4
	ldr	x8, [x2, #104]
	mov	x0, x1
	mov	x1, x19
	mov	w2, #2
	blr	x8
	mov	x0, x19
	mov	x1, x21
	mov	x2, x20
LBB42_4:
	mov	w22, #2
	swpa	w22, w8, [x0]
	cbz	w8, LBB42_1
LBB42_5:
	ldr	x8, [x2, #104]
	mov	x0, x1
	mov	x1, x19
	mov	w2, #2
	blr	x8
	mov	x1, x21
	mov	x2, x20
	swpa	w22, w8, [x19]
	cbnz	w8, LBB42_5
	b	LBB42_1
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).castToNull":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh240:
	adrp	x0, l___anon_6122@PAGE
Lloh241:
	add	x0, x0, l___anon_6122@PAGEOFF
	mov	w1, #30
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh240, Lloh241
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netInterfaceName:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB44_5
	tst	x0, #0x7
	b.ne	LBB44_6
	mov	x19, x8
	bl	l_Io.Threaded.Thread.checkCancel
	ands	w8, w0, #0xffff
	b.ne	LBB44_4
Lloh242:
	adrp	x0, l___anon_6259@PAGE
Lloh243:
	add	x0, x0, l___anon_6259@PAGEOFF
	mov	w1, #40
	bl	l_debug.defaultPanic
LBB44_4:
	strh	w8, [x19]
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB44_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB44_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpAdd	Lloh242, Lloh243
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netInterfaceNameResolve:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB45_8
	tst	x0, #0x7
	b.ne	LBB45_9
	mov	x20, x1
	mov	x19, x8
	bl	l_Io.Threaded.Thread.checkCancel
	ands	w8, w0, #0xffff
	b.ne	LBB45_7
	mov	x0, x20
	bl	_if_nametoindex
	cbz	w0, LBB45_5
	strh	wzr, [x19, #4]
	str	w0, [x19]
	b	LBB45_6
LBB45_5:
	mov	x8, #395136991232
	str	x8, [x19]
LBB45_6:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB45_7:
	.cfi_restore_state
	strh	w8, [x19, #4]
	b	LBB45_6
LBB45_8:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB45_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Thread.checkCancel:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
Lloh244:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh245:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x9, [x0]
	cbz	x9, LBB46_2
	ldrb	w8, [x9, #552]
	tbz	w8, #0, LBB46_4
LBB46_2:
	mov	w0, #0
LBB46_3:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB46_4:
	.cfi_restore_state
	mov	w0, #0
	ldr	x10, [x9, #24]
	and	w8, w10, #0x7
	cmp	w8, #4
	b.le	LBB46_7
	cmp	w8, #6
	b.eq	LBB46_11
	cmp	w8, #7
	b.eq	LBB46_3
	b	LBB46_10
LBB46_7:
	cmp	w8, #0
	b.le	LBB46_3
	cmp	w8, #2
	b.gt	LBB46_12
	cmp	w8, #1
LBB46_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB46_11:
	orr	x8, x10, #0x7
	str	x8, [x9, #24]
	mov	w0, #2
	b	LBB46_3
LBB46_12:
	cmp	w8, #3
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdr	Lloh244, Lloh245
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netWriteFile:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB47_3
	tst	x0, #0x7
	b.ne	LBB47_4
Lloh246:
	adrp	x9, l___anon_9773@PAGE
Lloh247:
	add	x9, x9, l___anon_9773@PAGEOFF
Lloh248:
	ldr	q0, [x9]
	str	q0, [x8]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB47_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB47_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpAddLdr	Lloh246, Lloh247, Lloh248
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netClose:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB48_10
	tst	x0, #0x7
	b.ne	LBB48_11
	mov	x19, x2
	cbz	x2, LBB48_9
	mov	x20, x1
	b	LBB48_5
LBB48_4:
	subs	x19, x19, #1
	b.eq	LBB48_9
LBB48_5:
	ldr	w0, [x20], #36
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB48_4
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB48_8
	cmp	w8, #16, lsl #12
	b.lo	LBB48_4
LBB48_8:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB48_9:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB48_10:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB48_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.posixGetSockName:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x2
	mov	x20, x1
	mov	x21, x0
Lloh249:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh250:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh251:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #56]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB49_9
	ldr	x22, [sp, #40]
LBB49_2:
	mov	x0, x21
	mov	x1, x20
	mov	x2, x19
	bl	_getsockname
	cmn	w0, #1
	b.ne	LBB49_8
	bl	___error
	ldr	w23, [x0]
	tbnz	w23, #31, LBB49_13
	cmp	w23, #16, lsl #12
	b.hs	LBB49_13
	cmp	w23, #4
	b.ne	LBB49_7
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB49_2
	b	LBB49_9
LBB49_7:
	cbnz	w23, LBB49_11
LBB49_8:
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB49_9:
	ldr	x8, [sp, #56]
Lloh252:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh253:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh254:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB49_12
LBB49_10:
	.cfi_def_cfa wsp, 128
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB49_11:
	.cfi_restore_state
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	mov	w9, #4
	cmp	w23, #55
	csel	w0, w9, w8, eq
	ldr	x8, [sp, #56]
Lloh255:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh256:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh257:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB49_10
LBB49_12:
	bl	___stack_chk_fail
LBB49_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.loh AdrpLdrGotLdr	Lloh249, Lloh250, Lloh251
	.loh AdrpLdrGotLdr	Lloh252, Lloh253, Lloh254
	.loh AdrpLdrGotLdr	Lloh255, Lloh256, Lloh257
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netSocketCreatePair:
	.cfi_startproc
	sub	sp, sp, #240
	.cfi_def_cfa_offset 240
	stp	x24, x23, [sp, #176]
	stp	x22, x21, [sp, #192]
	stp	x20, x19, [sp, #208]
	stp	x29, x30, [sp, #224]
	add	x29, sp, #224
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh258:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh259:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh260:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB50_43
	tst	x0, #0x7
	b.ne	LBB50_44
	ldrb	w8, [x1, #9]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB50_45
	ldr	x9, [x1]
	ldrb	w22, [x1, #8]
	and	x8, x8, #0x7
Lloh261:
	adrp	x10, l_switch.table.Io.Threaded.openSocketPosix@PAGE
Lloh262:
	add	x10, x10, l_switch.table.Io.Threaded.openSocketPosix@PAGEOFF
	ldr	w20, [x10, x8, lsl #2]
	tst	x9, #0x100000000
	csel	w21, wzr, w9, eq
	mov	x8, #-6148914691236517206
	str	x8, [sp, #40]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #56]
	cbnz	w8, LBB50_28
	sub	x23, x29, #80
	ldr	x24, [sp, #48]
	tst	w22, #0x1
	mov	w8, #2
	mov	w9, #30
	csel	w22, w9, w8, ne
LBB50_5:
	add	x3, sp, #40
	mov	x0, x22
	mov	x1, x20
	mov	x2, x21
	bl	_socketpair
	cmn	w0, #1
	b.ne	LBB50_13
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB50_42
	cmp	w8, #16, lsl #12
	b.hs	LBB50_42
	cmp	w8, #4
	b.ne	LBB50_10
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB50_5
	b	LBB50_28
LBB50_10:
	cmp	w8, #55
	b.hi	LBB50_27
	mov	w8, w8
Lloh263:
	adrp	x9, LJTI50_0@PAGE
Lloh264:
	add	x9, x9, LJTI50_0@PAGEOFF
	adr	x10, LBB50_12
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB50_12:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #4
	b	LBB50_28
LBB50_13:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	ldr	w0, [sp, #40]
	bl	l_Io.Threaded.setCloexec
	tst	w0, #0xffff
	b.ne	LBB50_41
	ldr	w0, [sp, #44]
	bl	l_Io.Threaded.setCloexec
	tst	w0, #0xffff
	b.ne	LBB50_41
	mov	x8, #-6148914691236517206
	str	x8, [sp, #112]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #80]
	str	q0, [sp, #64]
	movi.2s	v0, #28
	stur	d0, [x29, #-104]
	ldr	w0, [sp, #40]
	add	x20, sp, #64
	sub	x21, x29, #104
	add	x1, sp, #64
	sub	x2, x29, #104
	bl	l_Io.Threaded.posixGetSockName
	tst	w0, #0xffff
	b.ne	LBB50_41
	ldr	w0, [sp, #44]
	add	x1, x20, #28
	orr	x2, x21, #0x4
	bl	l_Io.Threaded.posixGetSockName
	tst	w0, #0xffff
	b.ne	LBB50_41
	mov	x8, #8323072
	movk	x8, #256, lsl #32
	strh	wzr, [x19, #72]
	ldr	w9, [sp, #40]
	str	w9, [x19]
	ldrb	w9, [sp, #65]
	cmp	w9, #30
	b.eq	LBB50_31
	cmp	w9, #2
	b.ne	LBB50_32
	mov	w9, #0
	ldrh	w10, [sp, #66]
	ldr	w11, [sp, #68]
	rev	w10, w10
	lsr	w10, w10, #16
	orr	x11, x10, x11, lsl #16
	b	LBB50_33
LBB50_20:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #23
	b	LBB50_28
LBB50_21:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #24
	b	LBB50_28
LBB50_22:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #32
	b	LBB50_28
LBB50_23:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #84
	b	LBB50_28
LBB50_24:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #83
	b	LBB50_28
LBB50_25:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #10
	b	LBB50_28
LBB50_26:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #85
	b	LBB50_28
LBB50_27:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
LBB50_28:
	strh	w8, [x19, #72]
LBB50_29:
	ldur	x8, [x29, #-56]
Lloh265:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh266:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh267:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB50_46
	.cfi_def_cfa wsp, 240
	ldp	x29, x30, [sp, #224]
	ldp	x20, x19, [sp, #208]
	ldp	x22, x21, [sp, #192]
	ldp	x24, x23, [sp, #176]
	add	sp, sp, #240
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB50_31:
	.cfi_restore_state
	ldrh	w9, [sp, #66]
	rev16	w10, w9
	ldr	w9, [sp, #68]
	ldr	w11, [sp, #88]
	orr	x11, x9, x11, lsl #32
	ldur	q0, [sp, #72]
	stur	q0, [x29, #-96]
	mov	w9, #1
	b	LBB50_34
LBB50_32:
	mov	w9, #0
	mov	x11, #8323072
	movk	x11, #256, lsl #32
LBB50_33:
LBB50_34:
	stur	x11, [x19, #4]
	strh	w10, [x19, #12]
	ldur	q0, [x29, #-96]
	stur	q0, [x19, #14]
	strb	w9, [x19, #32]
	ldr	w9, [sp, #44]
	str	w9, [x19, #36]
	ldrb	w9, [sp, #93]
	cmp	w9, #30
	b.eq	LBB50_37
	cmp	w9, #2
	b.ne	LBB50_38
	mov	w9, #0
	ldrh	w8, [sp, #94]
	ldr	w10, [sp, #96]
	rev	w8, w8
	lsr	w8, w8, #16
	orr	x8, x8, x10, lsl #16
	b	LBB50_39
LBB50_37:
	ldrh	w8, [sp, #94]
	rev16	w10, w8
	ldr	w8, [sp, #96]
	ldr	w9, [sp, #116]
	orr	x8, x8, x9, lsl #32
	ldur	q0, [sp, #100]
	str	q0, [x23]
	mov	w9, #1
	b	LBB50_40
LBB50_38:
	mov	w9, #0
LBB50_39:
LBB50_40:
	str	x8, [x19, #40]
	strh	w10, [x19, #48]
	ldr	q0, [x23]
	stur	q0, [x19, #50]
	strb	w9, [x19, #68]
	b	LBB50_29
LBB50_41:
	ldr	w8, [sp, #40]
	mov	x20, x0
	mov	x0, x8
	bl	l_Io.Threaded.closeFd
	ldr	w0, [sp, #44]
	bl	l_Io.Threaded.closeFd
	strh	w20, [x19, #72]
	b	LBB50_29
LBB50_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB50_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB50_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB50_45:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB50_46:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh258, Lloh259, Lloh260
	.loh AdrpAdd	Lloh261, Lloh262
	.loh AdrpAdd	Lloh263, Lloh264
	.loh AdrpLdrGotLdr	Lloh265, Lloh266, Lloh267
	.cfi_endproc
	.section	__TEXT,__const
LJTI50_0:
	.byte	(LBB50_13-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_12-LBB50_12)>>2
	.byte	(LBB50_25-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_24-LBB50_12)>>2
	.byte	(LBB50_21-LBB50_12)>>2
	.byte	(LBB50_20-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_26-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_23-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_22-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_27-LBB50_12)>>2
	.byte	(LBB50_12-LBB50_12)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.closeFd:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB51_3
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB51_4
	cmp	w8, #16, lsl #12
	b.hs	LBB51_4
LBB51_3:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB51_4:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.setCloexec:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x19, x0
Lloh268:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh269:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh270:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB52_9
	ldr	x20, [sp, #40]
	mov	w21, #1
LBB52_2:
	str	x21, [sp]
	mov	x0, x19
	mov	w1, #2
	bl	_fcntl
	cmn	w0, #1
	b.ne	LBB52_8
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB52_13
	cmp	w8, #16, lsl #12
	b.hs	LBB52_13
	cmp	w8, #4
	b.ne	LBB52_7
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB52_2
	b	LBB52_9
LBB52_7:
	cbnz	w8, LBB52_11
LBB52_8:
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB52_9:
	ldur	x8, [x29, #-40]
Lloh271:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh272:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh273:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB52_12
LBB52_10:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB52_11:
	.cfi_restore_state
	str	x20, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	ldur	x8, [x29, #-40]
Lloh274:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh275:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh276:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB52_10
LBB52_12:
	bl	___stack_chk_fail
LBB52_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.loh AdrpLdrGotLdr	Lloh268, Lloh269, Lloh270
	.loh AdrpLdrGotLdr	Lloh271, Lloh272, Lloh273
	.loh AdrpLdrGotLdr	Lloh274, Lloh275, Lloh276
	.cfi_endproc

	.p2align	2
l_Io.Threaded.randomSecure:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB53_5
	tst	x0, #0x7
	b.ne	LBB53_6
	cbz	x2, LBB53_4
	mov	x0, x1
	mov	x1, x2
	bl	_arc4random_buf
LBB53_4:
	mov	w0, #0
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB53_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB53_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.random:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	.cfi_remember_state
	sub	sp, sp, #576
Lloh277:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh278:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh279:
	ldr	x9, [x9]
	str	x9, [sp, #8]
	stur	x9, [x29, #-56]
	cbz	x0, LBB54_9
	mov	x8, x0
	tst	x0, #0x7
	b.ne	LBB54_10
Lloh280:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh281:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x9, [x0]
	blr	x9
	ldr	x0, [x0]
	cbz	x0, LBB54_6
	ldr	x9, [x0, #32]!
	cmn	x9, #1
	b.eq	LBB54_8
LBB54_4:
	bl	l_Random.ChaCha.fill
	ldur	x8, [x29, #-56]
Lloh282:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh283:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh284:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB54_11
	add	sp, sp, #576
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x28, x27, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB54_6:
	.cfi_restore_state
	.cfi_remember_state
	ldur	x9, [x29, #-56]
Lloh285:
	adrp	x10, ___stack_chk_guard@GOTPAGE
Lloh286:
	ldr	x10, [x10, ___stack_chk_guard@GOTPAGEOFF]
Lloh287:
	ldr	x10, [x10]
	cmp	x10, x9
	b.ne	LBB54_11
	mov	x0, x8
	add	sp, sp, #576
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x28, x27, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w27
	.cfi_restore w28
	b	l_Io.Threaded.randomMainThread
LBB54_8:
	.cfi_restore_state
	add	x22, sp, #48
	movi.16b	v0, #170
	stp	q0, q0, [sp, #16]
	mov	x20, x1
	add	x1, sp, #16
	mov	x19, x0
	mov	x0, x8
	mov	x21, x2
	mov	w2, #32
	bl	l_Io.Threaded.randomMainThread
	add	x8, sp, #48
	add	x9, x8, #8
	movi.16b	v0, #170
	stp	q0, q0, [x9, #480]
	stp	q0, q0, [x9, #448]
	stp	q0, q0, [x9, #416]
	stp	q0, q0, [x9, #384]
	stp	q0, q0, [x9, #352]
	stp	q0, q0, [x9, #320]
	stp	q0, q0, [x9, #288]
	stp	q0, q0, [x9, #256]
	stur	q0, [x22, #248]
	stur	q0, [x22, #232]
	stur	q0, [x22, #216]
	stur	q0, [x22, #200]
	stur	q0, [x22, #184]
	stur	q0, [x22, #168]
	stur	q0, [x22, #152]
	stur	q0, [x22, #136]
	stur	q0, [x22, #120]
	stur	q0, [x22, #104]
	stur	q0, [x22, #88]
	stur	q0, [sp, #120]
	stur	q0, [sp, #104]
	stur	q0, [sp, #88]
	stur	q0, [sp, #72]
	stur	q0, [sp, #56]
	str	xzr, [sp, #48]
	ldp	q0, q1, [sp, #16]
	add	x0, x8, #8
	bl	"l_crypto.chacha20.ChaChaIETF(8).stream"
	add	x1, sp, #48
	mov	x0, x19
	mov	w2, #520
	bl	_memcpy
	mov	x0, x19
	mov	x1, x20
	mov	x2, x21
	b	LBB54_4
LBB54_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB54_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB54_11:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh277, Lloh278, Lloh279
	.loh AdrpLdr	Lloh280, Lloh281
	.loh AdrpLdrGotLdr	Lloh282, Lloh283, Lloh284
	.loh AdrpLdrGotLdr	Lloh285, Lloh286, Lloh287
	.cfi_endproc

	.p2align	2
l_Io.Threaded.sleep:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
Lloh288:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh289:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh290:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-24]
	cbz	x0, LBB55_21
	tst	x0, #0x7
	b.ne	LBB55_22
	ldp	x19, x20, [x1]
	ldrb	w8, [x1, #32]
	and	w8, w8, #0x3
	cmp	w8, #1
	b.gt	LBB55_5
	cbnz	w8, LBB55_7
	mov	x8, #9223372036854775807
	mov	x9, #9223372036854775807
	b	LBB55_10
LBB55_5:
	cmp	w8, #2
	b.ne	LBB55_24
	ldrb	w1, [x1, #16]
	add	x8, sp, #32
	bl	l_Io.Threaded.now
	ldrsw	x8, [sp, #40]
	ldr	x9, [sp, #32]
	sxtw	x10, w20
	subs	x19, x19, x9
	sbc	x20, x10, x8
	sxtw	x8, w20
	eor	x8, x8, x20
	cbnz	x8, LBB55_25
LBB55_7:
	sxtw	x1, w20
	mov	x0, x19
	mov	w2, #51712
	movk	w2, #15258, lsl #16
	mov	x3, #0
	bl	___divti3
	mov	x8, #-51712
	movk	x8, #50277, lsl #16
	umulh	x9, x0, x8
	sub	x9, x9, x0
	madd	x10, x1, x8, x9
	mul	x8, x0, x8
	adds	x9, x8, x19
	adc	x8, x10, x20
	sxtw	x10, w8
	asr	x11, x10, #63
	adds	x8, x0, x10, asr #31
	adc	x11, x11, x1
	sxtw	x11, w11
	mov	x12, #9223372036854775807
	cmp	x12, x8
	mov	x12, #-1
	sbcs	xzr, x12, x11
	b.ge	LBB55_20
	mov	x12, #-9223372036854775808
	cmp	x8, x12
	sbcs	xzr, x11, xzr
	b.ge	LBB55_20
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	and	x10, x11, x10, lsr #31
	add	x9, x10, x9
LBB55_10:
	stp	x8, x9, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #40]
	cbnz	w0, LBB55_18
	ldr	x19, [sp, #32]
LBB55_12:
	add	x0, sp, #32
	add	x1, sp, #32
	bl	_nanosleep
	cmn	w0, #1
	b.ne	LBB55_17
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB55_20
	cmp	w8, #16, lsl #12
	b.hs	LBB55_20
	cmp	w8, #4
	b.ne	LBB55_17
	str	x19, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB55_12
	b	LBB55_18
LBB55_17:
	str	x19, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB55_18:
	ldur	x8, [x29, #-24]
Lloh291:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh292:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh293:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB55_23
	.cfi_def_cfa wsp, 128
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB55_20:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB55_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB55_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB55_23:
	bl	___stack_chk_fail
LBB55_24:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB55_25:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.loh AdrpLdrGotLdr	Lloh288, Lloh289, Lloh290
	.loh AdrpLdrGotLdr	Lloh291, Lloh292, Lloh293
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI56_0:
	.long	3
	.long	0
	.long	0
	.long	0
lCPI56_1:
	.long	2
	.long	0
	.long	0
	.long	0
lCPI56_2:
	.long	1
	.long	0
	.long	0
	.long	0
lCPI56_3:
	.long	1634760805
	.long	857760878
	.long	2036477234
	.long	1797285236
lCPI56_4:
	.long	4
	.long	0
	.long	0
	.long	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Random.ChaCha.fill:
	.cfi_startproc
	sub	sp, sp, #192
	.cfi_def_cfa_offset 192
	stp	d11, d10, [sp, #96]
	stp	d9, d8, [sp, #112]
	stp	x24, x23, [sp, #128]
	stp	x22, x21, [sp, #144]
	stp	x20, x19, [sp, #160]
	stp	x29, x30, [sp, #176]
	add	x29, sp, #176
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset b8, -72
	.cfi_offset b9, -80
	.cfi_offset b10, -88
	.cfi_offset b11, -96
	.cfi_remember_state
Lloh294:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh295:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh296:
	ldr	x8, [x8]
	str	x8, [sp, #80]
	str	x8, [sp, #88]
	mov	x21, x0
	ldr	x9, [x21], #40
	mov	w8, #480
	subs	x8, x8, x9
	b.lo	LBB56_28
	mov	x19, x2
	mov	x20, x0
	cbz	x8, LBB56_6
	cmp	x8, x19
	csel	x22, x8, x19, lo
	add	x8, x22, x9
	cmp	x8, #481
	b.hs	LBB56_30
	mov	x0, x1
	add	x1, x21, x9
	add	x8, x1, x22
	add	x24, x0, x22
	cmp	x0, x8
	ccmp	x1, x24, #2, lo
	b.lo	LBB56_27
	mov	x2, x22
	bl	_memcpy
	ldr	x8, [x20]
	add	x23, x8, x22
	cmp	x23, #481
	b.hs	LBB56_31
	add	x0, x21, x8
	mov	x1, x22
	bl	_bzero
	sub	x19, x19, x22
	str	x23, [x20]
	mov	x0, x24
	cbnz	x19, LBB56_7
	b	LBB56_25
LBB56_6:
	mov	x0, x1
	cbz	x19, LBB56_25
LBB56_7:
	mov	x13, #0
	mov	x23, x20
	ldr	q0, [x23, #8]!
	ldr	q1, [x23, #16]
	adrp	x8, lCPI56_0@PAGE
	ldr	q2, [x8, lCPI56_0@PAGEOFF]
	adrp	x9, lCPI56_1@PAGE
	ldr	q3, [x9, lCPI56_1@PAGEOFF]
	adrp	x10, lCPI56_2@PAGE
	ldr	q4, [x10, lCPI56_2@PAGEOFF]
	movi.2d	v5, #0000000000000000
	mov	w14, #256
Lloh297:
	adrp	x11, lCPI56_4@PAGE
Lloh298:
	ldr	q10, [x11, lCPI56_4@PAGEOFF]
Lloh299:
	adrp	x11, lCPI56_3@PAGE
	ldr	q6, [x11, lCPI56_3@PAGEOFF]
LBB56_8:
	mov	x12, x14
	mov	x14, #-4
	mov.16b	v19, v6
	mov.16b	v7, v6
	mov.16b	v17, v6
	mov.16b	v22, v6
	mov.16b	v28, v0
	mov.16b	v26, v0
	mov.16b	v23, v0
	mov.16b	v21, v0
	mov.16b	v29, v5
	mov.16b	v25, v4
	mov.16b	v20, v3
	mov.16b	v16, v2
	mov.16b	v30, v1
	mov.16b	v27, v1
	mov.16b	v24, v1
	mov.16b	v18, v1
LBB56_9:
	add.4s	v22, v21, v22
	add.4s	v17, v23, v17
	add.4s	v7, v26, v7
	add.4s	v19, v28, v19
	eor.16b	v29, v29, v19
	eor.16b	v25, v25, v7
	eor.16b	v20, v20, v17
	eor.16b	v16, v16, v22
	rev32.8h	v16, v16
	rev32.8h	v20, v20
	rev32.8h	v25, v25
	rev32.8h	v29, v29
	add.4s	v30, v29, v30
	add.4s	v27, v25, v27
	add.4s	v24, v20, v24
	add.4s	v18, v16, v18
	eor.16b	v21, v18, v21
	eor.16b	v23, v24, v23
	eor.16b	v26, v27, v26
	eor.16b	v28, v30, v28
	shl.4s	v31, v28, #12
	usra.4s	v31, v28, #20
	shl.4s	v28, v26, #12
	usra.4s	v28, v26, #20
	shl.4s	v26, v23, #12
	usra.4s	v26, v23, #20
	shl.4s	v23, v21, #12
	usra.4s	v23, v21, #20
	add.4s	v21, v23, v22
	add.4s	v17, v26, v17
	add.4s	v7, v28, v7
	add.4s	v19, v31, v19
	eor.16b	v22, v19, v29
	eor.16b	v25, v7, v25
	eor.16b	v20, v17, v20
	eor.16b	v16, v21, v16
	ext.16b	v19, v19, v19, #12
	ext.16b	v7, v7, v7, #12
	ext.16b	v17, v17, v17, #12
	ext.16b	v21, v21, v21, #12
	shl.4s	v29, v16, #8
	usra.4s	v29, v16, #24
	shl.4s	v16, v20, #8
	usra.4s	v16, v20, #24
	shl.4s	v20, v25, #8
	usra.4s	v20, v25, #24
	shl.4s	v25, v22, #8
	usra.4s	v25, v22, #24
	add.4s	v22, v25, v30
	add.4s	v27, v20, v27
	add.4s	v24, v16, v24
	add.4s	v18, v29, v18
	ext.16b	v29, v29, v29, #8
	ext.16b	v16, v16, v16, #8
	ext.16b	v20, v20, v20, #8
	ext.16b	v25, v25, v25, #8
	eor.16b	v23, v18, v23
	eor.16b	v26, v24, v26
	eor.16b	v28, v27, v28
	eor.16b	v30, v22, v31
	ext.16b	v18, v18, v18, #4
	ext.16b	v24, v24, v24, #4
	ext.16b	v27, v27, v27, #4
	ext.16b	v22, v22, v22, #4
	shl.4s	v31, v30, #7
	usra.4s	v31, v30, #25
	shl.4s	v30, v28, #7
	usra.4s	v30, v28, #25
	shl.4s	v28, v26, #7
	usra.4s	v28, v26, #25
	shl.4s	v26, v23, #7
	usra.4s	v26, v23, #25
	add.4s	v21, v26, v21
	add.4s	v17, v28, v17
	add.4s	v7, v30, v7
	add.4s	v19, v31, v19
	eor.16b	v23, v19, v25
	eor.16b	v20, v7, v20
	eor.16b	v16, v17, v16
	eor.16b	v25, v21, v29
	rev32.8h	v25, v25
	rev32.8h	v16, v16
	rev32.8h	v20, v20
	rev32.8h	v23, v23
	add.4s	v29, v23, v22
	add.4s	v27, v20, v27
	add.4s	v24, v16, v24
	add.4s	v18, v25, v18
	eor.16b	v22, v18, v26
	eor.16b	v26, v24, v28
	eor.16b	v28, v27, v30
	eor.16b	v30, v29, v31
	shl.4s	v31, v30, #12
	usra.4s	v31, v30, #20
	shl.4s	v30, v28, #12
	usra.4s	v30, v28, #20
	shl.4s	v28, v26, #12
	usra.4s	v28, v26, #20
	shl.4s	v26, v22, #12
	usra.4s	v26, v22, #20
	add.4s	v21, v26, v21
	add.4s	v17, v28, v17
	add.4s	v7, v30, v7
	add.4s	v19, v31, v19
	eor.16b	v23, v19, v23
	eor.16b	v20, v7, v20
	eor.16b	v16, v17, v16
	eor.16b	v25, v21, v25
	ext.16b	v19, v19, v19, #4
	ext.16b	v7, v7, v7, #4
	ext.16b	v17, v17, v17, #4
	ext.16b	v22, v21, v21, #4
	shl.4s	v21, v25, #8
	usra.4s	v21, v25, #24
	shl.4s	v8, v16, #8
	usra.4s	v8, v16, #24
	shl.4s	v16, v20, #8
	usra.4s	v16, v20, #24
	shl.4s	v20, v23, #8
	usra.4s	v20, v23, #24
	add.4s	v23, v20, v29
	add.4s	v27, v16, v27
	add.4s	v24, v8, v24
	add.4s	v18, v21, v18
	ext.16b	v29, v20, v20, #8
	ext.16b	v25, v16, v16, #8
	ext.16b	v20, v8, v8, #8
	ext.16b	v16, v21, v21, #8
	eor.16b	v8, v18, v26
	eor.16b	v21, v24, v28
	eor.16b	v9, v27, v30
	eor.16b	v26, v23, v31
	ext.16b	v30, v23, v23, #12
	ext.16b	v27, v27, v27, #12
	ext.16b	v24, v24, v24, #12
	ext.16b	v18, v18, v18, #12
	shl.4s	v28, v26, #7
	usra.4s	v28, v26, #25
	shl.4s	v26, v9, #7
	usra.4s	v26, v9, #25
	shl.4s	v23, v21, #7
	usra.4s	v23, v21, #25
	shl.4s	v21, v8, #7
	usra.4s	v21, v8, #25
	add	x14, x14, #2
	cmp	x14, #4
	b.lt	LBB56_9
	add.4s	v19, v19, v6
	add	x13, x23, x13
	add.4s	v28, v28, v0
	stp	q19, q28, [x13]
	add.4s	v19, v22, v6
	add.4s	v17, v17, v6
	add.4s	v22, v30, v1
	add.4s	v28, v29, v5
	stp	q22, q28, [x13, #32]
	add.4s	v7, v7, v6
	add.4s	v22, v26, v0
	stp	q7, q22, [x13, #64]
	add.4s	v7, v27, v1
	add.4s	v22, v25, v4
	stp	q7, q22, [x13, #96]
	add.4s	v7, v23, v0
	stp	q17, q7, [x13, #128]
	add.4s	v7, v24, v1
	add.4s	v17, v20, v3
	stp	q7, q17, [x13, #160]
	add.4s	v7, v21, v0
	add.4s	v17, v18, v1
	add.4s	v16, v16, v2
	stp	q19, q7, [x13, #192]
	add.4s	v4, v4, v10
	add.4s	v5, v5, v10
	add.4s	v3, v3, v10
	add.4s	v2, v2, v10
	add	x14, x12, #256
	stp	q17, q16, [x13, #224]
	mov	x13, x12
	cmp	x12, #257
	b.lo	LBB56_8
	str	xzr, [x20]
	cmp	x19, #480
	b.lo	LBB56_22
	add	x24, x20, #520
	ldr	q0, [x8, lCPI56_0@PAGEOFF]
	str	q0, [sp, #48]
	ldr	q0, [x9, lCPI56_1@PAGEOFF]
	str	q0, [sp, #32]
	ldr	q0, [x10, lCPI56_2@PAGEOFF]
	str	q0, [sp, #16]
	ldr	q9, [x11, lCPI56_3@PAGEOFF]
	str	q10, [sp, #64]
	str	q9, [sp]
LBB56_13:
	add	x22, x0, #480
	cmp	x0, x24
	b.hs	LBB56_15
	cmp	x21, x22
	b.lo	LBB56_27
LBB56_15:
	mov	x1, x21
	mov	w2, #480
	bl	_memcpy
	mov	x9, #0
	ldur	q0, [x20, #8]
	ldur	q1, [x20, #24]
	movi.2d	v2, #0000000000000000
	mov	w10, #256
	ldp	q3, q4, [sp, #16]
	ldp	q5, q10, [sp, #48]
	ldr	q9, [sp]
LBB56_16:
	mov	x8, x10
	mov	x10, #-4
	mov.16b	v18, v9
	mov.16b	v6, v9
	mov.16b	v16, v9
	mov.16b	v21, v9
	mov.16b	v27, v0
	mov.16b	v25, v0
	mov.16b	v22, v0
	mov.16b	v20, v0
	mov.16b	v28, v2
	mov.16b	v24, v3
	mov.16b	v19, v4
	mov.16b	v7, v5
	mov.16b	v29, v1
	mov.16b	v26, v1
	mov.16b	v23, v1
	mov.16b	v17, v1
LBB56_17:
	add.4s	v21, v20, v21
	add.4s	v16, v22, v16
	add.4s	v6, v25, v6
	add.4s	v18, v27, v18
	eor.16b	v28, v28, v18
	eor.16b	v24, v24, v6
	eor.16b	v19, v19, v16
	eor.16b	v7, v7, v21
	rev32.8h	v7, v7
	rev32.8h	v19, v19
	rev32.8h	v24, v24
	rev32.8h	v28, v28
	add.4s	v29, v28, v29
	add.4s	v26, v24, v26
	add.4s	v23, v19, v23
	add.4s	v17, v7, v17
	eor.16b	v20, v17, v20
	eor.16b	v22, v23, v22
	eor.16b	v25, v26, v25
	eor.16b	v27, v29, v27
	shl.4s	v30, v27, #12
	usra.4s	v30, v27, #20
	shl.4s	v27, v25, #12
	usra.4s	v27, v25, #20
	shl.4s	v25, v22, #12
	usra.4s	v25, v22, #20
	shl.4s	v22, v20, #12
	usra.4s	v22, v20, #20
	add.4s	v20, v22, v21
	add.4s	v16, v25, v16
	add.4s	v6, v27, v6
	add.4s	v18, v30, v18
	eor.16b	v21, v18, v28
	eor.16b	v24, v6, v24
	eor.16b	v19, v16, v19
	eor.16b	v7, v20, v7
	ext.16b	v18, v18, v18, #12
	ext.16b	v6, v6, v6, #12
	ext.16b	v16, v16, v16, #12
	ext.16b	v20, v20, v20, #12
	shl.4s	v28, v7, #8
	usra.4s	v28, v7, #24
	shl.4s	v7, v19, #8
	usra.4s	v7, v19, #24
	shl.4s	v19, v24, #8
	usra.4s	v19, v24, #24
	shl.4s	v24, v21, #8
	usra.4s	v24, v21, #24
	add.4s	v21, v24, v29
	add.4s	v26, v19, v26
	add.4s	v23, v7, v23
	add.4s	v17, v28, v17
	ext.16b	v28, v28, v28, #8
	ext.16b	v7, v7, v7, #8
	ext.16b	v19, v19, v19, #8
	ext.16b	v24, v24, v24, #8
	eor.16b	v22, v17, v22
	eor.16b	v25, v23, v25
	eor.16b	v27, v26, v27
	eor.16b	v29, v21, v30
	ext.16b	v17, v17, v17, #4
	ext.16b	v23, v23, v23, #4
	ext.16b	v26, v26, v26, #4
	ext.16b	v21, v21, v21, #4
	shl.4s	v30, v29, #7
	usra.4s	v30, v29, #25
	shl.4s	v29, v27, #7
	usra.4s	v29, v27, #25
	shl.4s	v27, v25, #7
	usra.4s	v27, v25, #25
	shl.4s	v25, v22, #7
	usra.4s	v25, v22, #25
	add.4s	v20, v25, v20
	add.4s	v16, v27, v16
	add.4s	v6, v29, v6
	add.4s	v18, v30, v18
	eor.16b	v22, v18, v24
	eor.16b	v19, v6, v19
	eor.16b	v7, v16, v7
	eor.16b	v24, v20, v28
	rev32.8h	v24, v24
	rev32.8h	v7, v7
	rev32.8h	v19, v19
	rev32.8h	v22, v22
	add.4s	v28, v22, v21
	add.4s	v26, v19, v26
	add.4s	v23, v7, v23
	add.4s	v17, v24, v17
	eor.16b	v21, v17, v25
	eor.16b	v25, v23, v27
	eor.16b	v27, v26, v29
	eor.16b	v29, v28, v30
	shl.4s	v30, v29, #12
	usra.4s	v30, v29, #20
	shl.4s	v29, v27, #12
	usra.4s	v29, v27, #20
	shl.4s	v27, v25, #12
	usra.4s	v27, v25, #20
	shl.4s	v25, v21, #12
	usra.4s	v25, v21, #20
	add.4s	v20, v25, v20
	add.4s	v16, v27, v16
	add.4s	v6, v29, v6
	add.4s	v18, v30, v18
	eor.16b	v22, v18, v22
	eor.16b	v19, v6, v19
	eor.16b	v7, v16, v7
	eor.16b	v24, v20, v24
	ext.16b	v18, v18, v18, #4
	ext.16b	v6, v6, v6, #4
	ext.16b	v16, v16, v16, #4
	ext.16b	v21, v20, v20, #4
	shl.4s	v20, v24, #8
	usra.4s	v20, v24, #24
	shl.4s	v31, v7, #8
	usra.4s	v31, v7, #24
	shl.4s	v7, v19, #8
	usra.4s	v7, v19, #24
	shl.4s	v19, v22, #8
	usra.4s	v19, v22, #24
	add.4s	v22, v19, v28
	add.4s	v26, v7, v26
	add.4s	v23, v31, v23
	add.4s	v17, v20, v17
	ext.16b	v28, v19, v19, #8
	ext.16b	v24, v7, v7, #8
	ext.16b	v19, v31, v31, #8
	ext.16b	v7, v20, v20, #8
	eor.16b	v31, v17, v25
	eor.16b	v20, v23, v27
	eor.16b	v8, v26, v29
	eor.16b	v25, v22, v30
	ext.16b	v29, v22, v22, #12
	ext.16b	v26, v26, v26, #12
	ext.16b	v23, v23, v23, #12
	ext.16b	v17, v17, v17, #12
	shl.4s	v27, v25, #7
	usra.4s	v27, v25, #25
	shl.4s	v25, v8, #7
	usra.4s	v25, v8, #25
	shl.4s	v22, v20, #7
	usra.4s	v22, v20, #25
	shl.4s	v20, v31, #7
	usra.4s	v20, v31, #25
	add	x10, x10, #2
	cmp	x10, #4
	b.lt	LBB56_17
	add.4s	v18, v18, v9
	add	x9, x23, x9
	add.4s	v27, v27, v0
	stp	q18, q27, [x9]
	add.4s	v18, v21, v9
	add.4s	v16, v16, v9
	add.4s	v21, v29, v1
	add.4s	v27, v28, v2
	stp	q21, q27, [x9, #32]
	add.4s	v6, v6, v9
	add.4s	v21, v25, v0
	stp	q6, q21, [x9, #64]
	add.4s	v6, v26, v1
	add.4s	v21, v24, v3
	stp	q6, q21, [x9, #96]
	add.4s	v6, v22, v0
	stp	q16, q6, [x9, #128]
	add.4s	v6, v23, v1
	add.4s	v16, v19, v4
	stp	q6, q16, [x9, #160]
	add.4s	v6, v20, v0
	add.4s	v16, v17, v1
	add.4s	v7, v7, v5
	stp	q18, q6, [x9, #192]
	add.4s	v3, v3, v10
	add.4s	v2, v2, v10
	add.4s	v4, v4, v10
	add.4s	v5, v5, v10
	add	x10, x8, #256
	stp	q16, q7, [x9, #224]
	mov	x9, x8
	cmp	x8, #257
	b.lo	LBB56_16
	sub	x19, x19, #480
	str	xzr, [x20]
	mov	x0, x22
	cmp	x19, #479
	b.hi	LBB56_13
	cbz	x19, LBB56_25
	add	x8, x21, x19
	cmp	x22, x8
	b.lo	LBB56_23
	b	LBB56_24
LBB56_22:
	mov	x22, x0
	add	x8, x21, x19
	cmp	x0, x8
	b.hs	LBB56_24
LBB56_23:
	add	x8, x22, x19
	cmp	x21, x8
	b.lo	LBB56_27
LBB56_24:
	mov	x0, x22
	mov	x1, x21
	mov	x2, x19
	bl	_memcpy
	mov	x0, x21
	mov	x1, x19
	bl	_bzero
	str	x19, [x20]
LBB56_25:
	ldr	x8, [sp, #88]
Lloh300:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh301:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh302:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB56_29
	.cfi_def_cfa wsp, 192
	ldp	x29, x30, [sp, #176]
	ldp	x20, x19, [sp, #160]
	ldp	x22, x21, [sp, #144]
	ldp	x24, x23, [sp, #128]
	ldp	d9, d8, [sp, #112]
	ldp	d11, d10, [sp, #96]
	add	sp, sp, #192
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore b8
	.cfi_restore b9
	.cfi_restore b10
	.cfi_restore b11
	ret
LBB56_27:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB56_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB56_29:
	bl	___stack_chk_fail
LBB56_30:
	mov	x0, x8
	mov	w1, #480
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB56_31:
	mov	x0, x23
	mov	w1, #480
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh294, Lloh295, Lloh296
	.loh AdrpAdrp	Lloh297, Lloh299
	.loh AdrpLdr	Lloh297, Lloh298
	.loh AdrpLdrGotLdr	Lloh300, Lloh301, Lloh302
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI57_0:
	.long	3
	.long	0
	.long	0
	.long	0
lCPI57_1:
	.long	2
	.long	0
	.long	0
	.long	0
lCPI57_2:
	.long	1
	.long	0
	.long	0
	.long	0
lCPI57_3:
	.long	1634760805
	.long	857760878
	.long	2036477234
	.long	1797285236
lCPI57_4:
	.long	4
	.long	0
	.long	0
	.long	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
"l_crypto.chacha20.ChaChaIETF(8).stream":
	.cfi_startproc
	stp	d11, d10, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	d9, d8, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset b8, -24
	.cfi_offset b9, -32
	.cfi_offset b10, -40
	.cfi_offset b11, -48
	mov	x9, #0
Lloh303:
	adrp	x8, lCPI57_0@PAGE
Lloh304:
	ldr	q2, [x8, lCPI57_0@PAGEOFF]
Lloh305:
	adrp	x8, lCPI57_1@PAGE
Lloh306:
	ldr	q3, [x8, lCPI57_1@PAGEOFF]
Lloh307:
	adrp	x8, lCPI57_2@PAGE
Lloh308:
	ldr	q4, [x8, lCPI57_2@PAGEOFF]
	movi.2d	v5, #0000000000000000
Lloh309:
	adrp	x8, lCPI57_3@PAGE
Lloh310:
	ldr	q6, [x8, lCPI57_3@PAGEOFF]
Lloh311:
	adrp	x8, lCPI57_4@PAGE
Lloh312:
	ldr	q7, [x8, lCPI57_4@PAGEOFF]
	mov	w10, #256
LBB57_1:
	mov	x8, x10
	mov	x10, #-4
	mov.16b	v20, v6
	mov.16b	v16, v6
	mov.16b	v18, v6
	mov.16b	v23, v6
	mov.16b	v29, v0
	mov.16b	v27, v0
	mov.16b	v24, v0
	mov.16b	v22, v0
	mov.16b	v30, v5
	mov.16b	v26, v4
	mov.16b	v21, v3
	mov.16b	v17, v2
	mov.16b	v31, v1
	mov.16b	v28, v1
	mov.16b	v25, v1
	mov.16b	v19, v1
LBB57_2:
	add.4s	v23, v22, v23
	add.4s	v18, v24, v18
	add.4s	v16, v27, v16
	add.4s	v20, v29, v20
	eor.16b	v30, v30, v20
	eor.16b	v26, v26, v16
	eor.16b	v21, v21, v18
	eor.16b	v17, v17, v23
	rev32.8h	v17, v17
	rev32.8h	v21, v21
	rev32.8h	v26, v26
	rev32.8h	v30, v30
	add.4s	v31, v30, v31
	add.4s	v28, v26, v28
	add.4s	v25, v21, v25
	add.4s	v19, v17, v19
	eor.16b	v22, v19, v22
	eor.16b	v24, v25, v24
	eor.16b	v27, v28, v27
	eor.16b	v29, v31, v29
	shl.4s	v8, v29, #12
	usra.4s	v8, v29, #20
	shl.4s	v29, v27, #12
	usra.4s	v29, v27, #20
	shl.4s	v27, v24, #12
	usra.4s	v27, v24, #20
	shl.4s	v24, v22, #12
	usra.4s	v24, v22, #20
	add.4s	v22, v24, v23
	add.4s	v18, v27, v18
	add.4s	v16, v29, v16
	add.4s	v20, v8, v20
	eor.16b	v23, v20, v30
	eor.16b	v26, v16, v26
	eor.16b	v21, v18, v21
	eor.16b	v17, v22, v17
	ext.16b	v20, v20, v20, #12
	ext.16b	v16, v16, v16, #12
	ext.16b	v18, v18, v18, #12
	ext.16b	v22, v22, v22, #12
	shl.4s	v30, v17, #8
	usra.4s	v30, v17, #24
	shl.4s	v17, v21, #8
	usra.4s	v17, v21, #24
	shl.4s	v21, v26, #8
	usra.4s	v21, v26, #24
	shl.4s	v26, v23, #8
	usra.4s	v26, v23, #24
	add.4s	v23, v26, v31
	add.4s	v28, v21, v28
	add.4s	v25, v17, v25
	add.4s	v19, v30, v19
	ext.16b	v30, v30, v30, #8
	ext.16b	v17, v17, v17, #8
	ext.16b	v21, v21, v21, #8
	ext.16b	v26, v26, v26, #8
	eor.16b	v24, v19, v24
	eor.16b	v27, v25, v27
	eor.16b	v29, v28, v29
	eor.16b	v31, v23, v8
	ext.16b	v19, v19, v19, #4
	ext.16b	v25, v25, v25, #4
	ext.16b	v28, v28, v28, #4
	ext.16b	v23, v23, v23, #4
	shl.4s	v8, v31, #7
	usra.4s	v8, v31, #25
	shl.4s	v31, v29, #7
	usra.4s	v31, v29, #25
	shl.4s	v29, v27, #7
	usra.4s	v29, v27, #25
	shl.4s	v27, v24, #7
	usra.4s	v27, v24, #25
	add.4s	v22, v27, v22
	add.4s	v18, v29, v18
	add.4s	v16, v31, v16
	add.4s	v20, v8, v20
	eor.16b	v24, v20, v26
	eor.16b	v21, v16, v21
	eor.16b	v17, v18, v17
	eor.16b	v26, v22, v30
	rev32.8h	v26, v26
	rev32.8h	v17, v17
	rev32.8h	v21, v21
	rev32.8h	v24, v24
	add.4s	v30, v24, v23
	add.4s	v28, v21, v28
	add.4s	v25, v17, v25
	add.4s	v19, v26, v19
	eor.16b	v23, v19, v27
	eor.16b	v27, v25, v29
	eor.16b	v29, v28, v31
	eor.16b	v31, v30, v8
	shl.4s	v8, v31, #12
	usra.4s	v8, v31, #20
	shl.4s	v31, v29, #12
	usra.4s	v31, v29, #20
	shl.4s	v29, v27, #12
	usra.4s	v29, v27, #20
	shl.4s	v27, v23, #12
	usra.4s	v27, v23, #20
	add.4s	v22, v27, v22
	add.4s	v18, v29, v18
	add.4s	v16, v31, v16
	add.4s	v20, v8, v20
	eor.16b	v24, v20, v24
	eor.16b	v21, v16, v21
	eor.16b	v17, v18, v17
	eor.16b	v26, v22, v26
	ext.16b	v20, v20, v20, #4
	ext.16b	v16, v16, v16, #4
	ext.16b	v18, v18, v18, #4
	ext.16b	v23, v22, v22, #4
	shl.4s	v22, v26, #8
	usra.4s	v22, v26, #24
	shl.4s	v9, v17, #8
	usra.4s	v9, v17, #24
	shl.4s	v17, v21, #8
	usra.4s	v17, v21, #24
	shl.4s	v21, v24, #8
	usra.4s	v21, v24, #24
	add.4s	v24, v21, v30
	add.4s	v28, v17, v28
	add.4s	v25, v9, v25
	add.4s	v19, v22, v19
	ext.16b	v30, v21, v21, #8
	ext.16b	v26, v17, v17, #8
	ext.16b	v21, v9, v9, #8
	ext.16b	v17, v22, v22, #8
	eor.16b	v9, v19, v27
	eor.16b	v22, v25, v29
	eor.16b	v10, v28, v31
	eor.16b	v27, v24, v8
	ext.16b	v31, v24, v24, #12
	ext.16b	v28, v28, v28, #12
	ext.16b	v25, v25, v25, #12
	ext.16b	v19, v19, v19, #12
	shl.4s	v29, v27, #7
	usra.4s	v29, v27, #25
	shl.4s	v27, v10, #7
	usra.4s	v27, v10, #25
	shl.4s	v24, v22, #7
	usra.4s	v24, v22, #25
	shl.4s	v22, v9, #7
	usra.4s	v22, v9, #25
	add	x10, x10, #2
	cmp	x10, #4
	b.lt	LBB57_2
	add.4s	v20, v20, v6
	add	x9, x0, x9
	add.4s	v29, v29, v0
	stp	q20, q29, [x9]
	add.4s	v20, v23, v6
	add.4s	v18, v18, v6
	add.4s	v23, v31, v1
	add.4s	v29, v30, v5
	stp	q23, q29, [x9, #32]
	add.4s	v16, v16, v6
	add.4s	v23, v27, v0
	stp	q16, q23, [x9, #64]
	add.4s	v16, v28, v1
	add.4s	v23, v26, v4
	stp	q16, q23, [x9, #96]
	add.4s	v16, v24, v0
	stp	q18, q16, [x9, #128]
	add.4s	v16, v25, v1
	add.4s	v18, v21, v3
	stp	q16, q18, [x9, #160]
	add.4s	v16, v22, v0
	add.4s	v18, v19, v1
	add.4s	v17, v17, v2
	stp	q20, q16, [x9, #192]
	add.4s	v4, v4, v7
	add.4s	v5, v5, v7
	add.4s	v3, v3, v7
	add.4s	v2, v2, v7
	add	x10, x8, #256
	stp	q18, q17, [x9, #224]
	mov	x9, x8
	cmp	x8, #257
	b.lo	LBB57_1
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	d9, d8, [sp, #16]
	ldp	d11, d10, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore b8
	.cfi_restore b9
	.cfi_restore b10
	.cfi_restore b11
	ret
	.loh AdrpLdr	Lloh311, Lloh312
	.loh AdrpAdrp	Lloh309, Lloh311
	.loh AdrpLdr	Lloh309, Lloh310
	.loh AdrpAdrp	Lloh307, Lloh309
	.loh AdrpLdr	Lloh307, Lloh308
	.loh AdrpAdrp	Lloh305, Lloh307
	.loh AdrpLdr	Lloh305, Lloh306
	.loh AdrpAdrp	Lloh303, Lloh305
	.loh AdrpLdr	Lloh303, Lloh304
	.cfi_endproc

	.p2align	2
l_Io.Threaded.randomMainThread:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #576
	mov	w8, #0
Lloh313:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh314:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh315:
	ldr	x9, [x9]
	str	x9, [sp, #8]
	stur	x9, [x29, #-88]
	add	x19, x0, #836
	mov	w9, #1
	casa	w8, w9, [x19]
	cmp	w8, #0
	b.ne	LBB58_6
LBB58_1:
	ldr	x8, [x0, #8]!
	cmn	x8, #1
	b.eq	LBB58_10
	bl	l_Random.ChaCha.fill
	swpl	wzr, w8, [x19]
	cbz	w8, LBB58_19
LBB58_3:
	cmp	w8, #1
	b.eq	LBB58_13
	cmp	w8, #2
	b.eq	LBB58_12
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB58_6:
	cmp	w8, #2
	mov	x21, x0
	b.eq	LBB58_20
	mov	w22, #2
	swpa	w22, w8, [x19]
	cbz	w8, LBB58_1
LBB58_8:
Lloh316:
	adrp	x20, l___anon_2803@PAGE
Lloh317:
	add	x20, x20, l___anon_2803@PAGEOFF
LBB58_9:
	add	x0, x21, #836
	mov	x23, x1
	mov	w1, #2
	mov	x24, x2
	mov	x2, x20
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x0, x21
	mov	x1, x23
	mov	x2, x24
	swpa	w22, w8, [x19]
	cbnz	w8, LBB58_9
	b	LBB58_1
LBB58_10:
	mov	x23, x0
	mov	x21, x1
	mov	x22, x2
	movi.16b	v0, #170
	stp	q0, q0, [sp, #16]
	mov	x0, x19
	bl	l_Io.Threaded.mutexUnlock
Lloh318:
	adrp	x20, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh319:
	ldr	x20, [x20, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x25, [x20]
	mov	x0, x20
	blr	x25
	ldr	x8, [x0]
	cbz	x8, LBB58_15
	ldrb	w26, [x8, #552]
	mov	w9, #1
	strb	w9, [x8, #552]
	b	LBB58_16
LBB58_12:
	mov	x0, x19
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB58_13:
	ldur	x8, [x29, #-88]
Lloh320:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh321:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh322:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB58_21
	add	sp, sp, #576
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB58_15:
	.cfi_restore_state
	mov	w26, #0
LBB58_16:
	add	x24, sp, #48
	add	x0, sp, #16
	mov	w1, #32
	bl	_arc4random_buf
	mov	x0, x20
	blr	x25
	ldr	x8, [x0]
	cbz	x8, LBB58_18
	and	w9, w26, #0x1
	strb	w9, [x8, #552]
LBB58_18:
	mov	x0, x19
	bl	l_Io.Threaded.mutexLockUncancelable
	add	x8, sp, #48
	add	x9, x8, #8
	movi.16b	v0, #170
	stp	q0, q0, [x9, #480]
	stp	q0, q0, [x9, #448]
	stp	q0, q0, [x9, #416]
	stp	q0, q0, [x9, #384]
	stp	q0, q0, [x9, #352]
	stp	q0, q0, [x9, #320]
	stp	q0, q0, [x9, #288]
	stp	q0, q0, [x9, #256]
	stur	q0, [x24, #248]
	stur	q0, [x24, #232]
	stur	q0, [x24, #216]
	stur	q0, [x24, #200]
	stur	q0, [x24, #184]
	stur	q0, [x24, #168]
	stur	q0, [x24, #152]
	stur	q0, [x24, #136]
	stur	q0, [x24, #120]
	stur	q0, [x24, #104]
	stur	q0, [x24, #88]
	stur	q0, [sp, #120]
	stur	q0, [sp, #104]
	stur	q0, [sp, #88]
	stur	q0, [sp, #72]
	stur	q0, [sp, #56]
	str	xzr, [sp, #48]
	ldp	q0, q1, [sp, #16]
	add	x0, x8, #8
	bl	"l_crypto.chacha20.ChaChaIETF(8).stream"
	add	x1, sp, #48
	mov	x0, x23
	mov	w2, #520
	bl	_memcpy
	mov	x0, x23
	mov	x2, x22
	mov	x1, x21
	bl	l_Random.ChaCha.fill
	swpl	wzr, w8, [x19]
	cbnz	w8, LBB58_3
LBB58_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB58_20:
Lloh323:
	adrp	x8, l___anon_2803@PAGE
Lloh324:
	add	x8, x8, l___anon_2803@PAGEOFF
	add	x0, x21, #836
	mov	x20, x1
	mov	w1, #2
	mov	x22, x2
	mov	x2, x8
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x0, x21
	mov	x1, x20
	mov	x2, x22
	mov	w22, #2
	swpa	w22, w8, [x19]
	cbnz	w8, LBB58_8
	b	LBB58_1
LBB58_21:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh313, Lloh314, Lloh315
	.loh AdrpAdd	Lloh316, Lloh317
	.loh AdrpLdr	Lloh318, Lloh319
	.loh AdrpLdrGotLdr	Lloh320, Lloh321, Lloh322
	.loh AdrpAdd	Lloh323, Lloh324
	.cfi_endproc

	.p2align	2
l_Io.Threaded.clockResolution:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh325:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh326:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh327:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	cbz	x0, LBB59_14
	tst	x0, #0x7
	b.ne	LBB59_15
	eor	w8, w1, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB59_16
Lloh328:
	adrp	x9, l_switch.table.Io.Threaded.futexWait@PAGE
Lloh329:
	add	x9, x9, l_switch.table.Io.Threaded.futexWait@PAGEOFF
	and	x8, x8, #0x7
	ldr	w0, [x9, x8, lsl #2]
	mov	x8, #-6148914691236517206
	stp	x8, x8, [sp, #8]
	add	x1, sp, #8
	bl	_clock_getres
	cmn	w0, #1
	b.eq	LBB59_5
LBB59_4:
	mov	w8, #0
	ldp	x9, x10, [sp, #8]
	asr	x11, x10, #63
	mov	w12, #51712
	movk	w12, #15258, lsl #16
	smulh	x13, x9, x12
	mul	x9, x9, x12
	adds	x9, x9, x10
	adc	x10, x13, x11
	sxtw	x10, w10
	b	LBB59_12
LBB59_5:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB59_18
	cmp	w8, #16, lsl #12
	b.hs	LBB59_18
	cmp	w8, #22
	b.eq	LBB59_10
	cbz	w8, LBB59_4
	mov	w8, #12
	b	LBB59_11
LBB59_10:
	mov	w8, #79
LBB59_11:
LBB59_12:
	stp	x9, x10, [x19]
	strh	w8, [x19, #16]
	stur	xzr, [x19, #18]
	str	xzr, [x19, #24]
	ldr	x8, [sp, #24]
Lloh330:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh331:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh332:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB59_17
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB59_14:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB59_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB59_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB59_17:
	bl	___stack_chk_fail
LBB59_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.loh AdrpLdrGotLdr	Lloh325, Lloh326, Lloh327
	.loh AdrpAdd	Lloh328, Lloh329
	.loh AdrpLdrGotLdr	Lloh330, Lloh331, Lloh332
	.cfi_endproc

	.p2align	2
l_Io.Threaded.mutexUnlock:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	swpl	wzr, w8, [x0]
	cbz	w8, LBB60_5
	cmp	w8, #1
	b.eq	LBB60_4
	cmp	w8, #2
	b.eq	LBB60_6
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB60_4:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB60_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB60_6:
	mov	w1, #1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.Thread.futexWake
	.cfi_endproc

	.p2align	2
l_Io.Threaded.mutexLockUncancelable:
	.cfi_startproc
	stp	x22, x21, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	w8, #0
	mov	w9, #1
	casa	w8, w9, [x0]
	cmp	w8, #0
	b.ne	LBB61_2
LBB61_1:
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x22, x21, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB61_2:
	.cfi_restore_state
	cmp	w8, #2
	mov	x19, x0
	b.eq	LBB61_6
	mov	w21, #2
	swpa	w21, w8, [x0]
	cbz	w8, LBB61_1
LBB61_4:
Lloh333:
	adrp	x20, l___anon_2803@PAGE
Lloh334:
	add	x20, x20, l___anon_2803@PAGEOFF
LBB61_5:
	mov	x0, x19
	mov	w1, #2
	mov	x2, x20
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	swpa	w21, w8, [x19]
	cbnz	w8, LBB61_5
	b	LBB61_1
LBB61_6:
Lloh335:
	adrp	x2, l___anon_2803@PAGE
Lloh336:
	add	x2, x2, l___anon_2803@PAGEOFF
	mov	x0, x19
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	w21, #2
	swpa	w21, w8, [x19]
	cbnz	w8, LBB61_4
	b	LBB61_1
	.loh AdrpAdd	Lloh333, Lloh334
	.loh AdrpAdd	Lloh335, Lloh336
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Thread.futexWake:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	w1, LBB62_14
	mov	x19, x0
	mov	w8, #1
	movk	w8, #256, lsl #16
	orr	w9, w8, #0x100
	cmp	w1, #1
	csel	w20, w8, w9, eq
	b	LBB62_3
LBB62_2:
	cmp	w8, #89
	b.ne	LBB62_12
LBB62_3:
	mov	x0, x20
	mov	x1, x19
	mov	x2, #0
	bl	___ulock_wake
	tbz	w0, #31, LBB62_10
	negs	w8, w0
	b.vs	LBB62_15
	tbnz	w8, #31, LBB62_11
	cmp	w8, #16, lsl #12
	b.hs	LBB62_11
	cmp	w8, #13
	b.gt	LBB62_2
	cmp	w8, #4
	b.eq	LBB62_3
	cmp	w8, #2
	b.ne	LBB62_14
LBB62_10:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB62_11:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB62_12:
	cmp	w8, #37
	b.eq	LBB62_14
	cmp	w8, #14
LBB62_14:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB62_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Thread.futexWaitUncancelable:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x3, x2
	mov	w2, #1
	bl	l_Io.Threaded.Thread.futexWaitInner
	tst	w0, #0xffff
	b.ne	LBB63_2
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB63_2:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.now:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh337:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh338:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh339:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	cbz	x0, LBB64_11
	tst	x0, #0x7
	b.ne	LBB64_12
	eor	w8, w1, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB64_13
Lloh340:
	adrp	x9, l_switch.table.Io.Threaded.futexWait@PAGE
Lloh341:
	add	x9, x9, l_switch.table.Io.Threaded.futexWait@PAGEOFF
	and	x8, x8, #0x7
	ldr	w0, [x9, x8, lsl #2]
	mov	x8, #-6148914691236517206
	stp	x8, x8, [sp, #8]
	add	x1, sp, #8
	bl	_clock_gettime
	cmn	w0, #1
	b.eq	LBB64_5
LBB64_4:
	ldp	x8, x9, [sp, #8]
	asr	x10, x9, #63
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	smulh	x12, x8, x11
	mul	x8, x8, x11
	adds	x8, x8, x9
	adc	x9, x12, x10
	sxtw	x9, w9
	b	LBB64_9
LBB64_5:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB64_15
	cmp	w8, #16, lsl #12
	b.hs	LBB64_15
	cbz	w8, LBB64_4
	mov	x8, #0
	mov	x9, #0
LBB64_9:
	stp	x8, x9, [x19]
	ldr	x8, [sp, #24]
Lloh342:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh343:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh344:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB64_14
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB64_11:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB64_12:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB64_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB64_14:
	bl	___stack_chk_fail
LBB64_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.loh AdrpLdrGotLdr	Lloh337, Lloh338, Lloh339
	.loh AdrpAdd	Lloh340, Lloh341
	.loh AdrpLdrGotLdr	Lloh342, Lloh343, Lloh344
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Thread.futexWaitInner:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x20, x3
	mov	x21, x1
	mov	x19, x0
Lloh345:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh346:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh347:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #40]
	tbz	w2, #0, LBB65_3
	mov	x22, #0
	mov	w2, w21
	ldrb	w8, [x20, #8]
	tbz	w8, #0, LBB65_5
LBB65_2:
	ldr	x8, [x20]
	cmp	x8, #1
	csinc	x3, x8, xzr, hi
	b	LBB65_6
LBB65_3:
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #32]
	cbnz	w0, LBB65_8
	ldr	x22, [sp, #24]
	mov	w2, w21
	ldrb	w8, [x20, #8]
	tbnz	w8, #0, LBB65_2
LBB65_5:
	mov	x3, #0
LBB65_6:
	mov	w0, #1
	movk	w0, #256, lsl #16
	mov	x1, x19
	mov	x4, #0
	bl	___ulock_wait2
	mov	x19, x0
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	tbnz	w19, #31, LBB65_10
	mov	w0, #0
LBB65_8:
	ldr	x8, [sp, #40]
Lloh348:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh349:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh350:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB65_14
LBB65_9:
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB65_10:
	.cfi_restore_state
	negs	w8, w19
	b.vs	LBB65_16
	tbnz	w8, #31, LBB65_15
	cmp	w8, #16, lsl #12
	b.hs	LBB65_15
	mov	w0, #0
	ldr	x8, [sp, #40]
Lloh351:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh352:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh353:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB65_9
LBB65_14:
	bl	___stack_chk_fail
LBB65_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB65_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.loh AdrpLdrGotLdr	Lloh345, Lloh346, Lloh347
	.loh AdrpLdrGotLdr	Lloh348, Lloh349, Lloh350
	.loh AdrpLdrGotLdr	Lloh351, Lloh352, Lloh353
	.cfi_endproc

	.p2align	2
l_Io.Threaded.inheritParentFile:
	.cfi_startproc
	stp	x22, x21, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	cbz	x0, LBB66_5
	tst	x0, #0x7
	b.ne	LBB66_6
	mov	x20, x2
	mov	x21, x1
	mov	x19, x8
	mov	x0, x1
	bl	l_Io.Threaded.setCloexec
	tst	w0, #0xffff
	b.ne	LBB66_4
	str	w21, [x19]
	ldrb	w8, [x20]
	strb	w8, [x19, #4]
LBB66_4:
	strh	w0, [x19, #8]
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x22, x21, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB66_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB66_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.inheritParentDir:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB67_5
	tst	x0, #0x7
	b.ne	LBB67_6
	mov	x20, x1
	mov	x19, x8
	mov	x0, x1
	bl	l_Io.Threaded.setCloexec
	tst	w0, #0xffff
	b.ne	LBB67_4
	str	w20, [x19]
LBB67_4:
	strh	w0, [x19, #4]
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB67_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB67_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.progressParentFile:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB68_3
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB68_4
	mov	x19, x8
	mov	x0, x20
	bl	l_Io.Threaded.scanEnviron
	ldr	x8, [x20, #680]
	str	x8, [x19]
	ldr	w8, [x20, #688]
	str	w8, [x19, #8]
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB68_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB68_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.childKill:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
Lloh354:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh355:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh356:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB69_17
	tst	x0, #0x7
	b.ne	LBB69_18
	mov	x19, x1
	ldrb	w8, [x1, #156]
	tbz	w8, #0, LBB69_19
	ldr	w20, [x19, #152]
LBB69_4:
	mov	x0, x20
	mov	w1, #15
	bl	_kill
	cmn	w0, #1
	b.ne	LBB69_9
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB69_16
	cmp	w8, #16, lsl #12
	b.hs	LBB69_16
	cmp	w8, #4
	b.eq	LBB69_4
	cbnz	w8, LBB69_14
LBB69_9:
	mov	w8, #-1431655766
	str	w8, [sp, #20]
LBB69_10:
	add	x1, sp, #20
	mov	x0, x20
	mov	w2, #0
	mov	x3, #0
	bl	_wait4
	cmn	w0, #1
	b.ne	LBB69_14
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB69_16
	cmp	w8, #16, lsl #12
	b.hs	LBB69_16
	cmp	w8, #4
	b.eq	LBB69_10
LBB69_14:
	mov	x0, x19
	bl	l_Io.Threaded.childCleanupPosix
	ldr	x8, [sp, #24]
Lloh357:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh358:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh359:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB69_20
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB69_16:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB69_17:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB69_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB69_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB69_20:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh354, Lloh355, Lloh356
	.loh AdrpLdrGotLdr	Lloh357, Lloh358, Lloh359
	.cfi_endproc

	.p2align	2
l_Io.Threaded.scanEnviron:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	w8, #0
	add	x19, x0, #836
	mov	w9, #1
	casa	w8, w9, [x19]
	cmp	w8, #0
	b.ne	LBB70_9
LBB70_1:
	ldrb	w8, [x0, #859]
	tbz	w8, #0, LBB70_6
	add	x8, x0, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB70_7
LBB70_3:
	cmp	w8, #1
	b.eq	LBB70_8
	cmp	w8, #2
	b.eq	LBB70_13
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB70_6:
	mov	x20, x0
	add	x0, x0, #584
	bl	l_Io.Threaded.Environ.scan
	mov	w8, #1
	strb	w8, [x20, #859]
	add	x8, x20, #836
	swpl	wzr, w8, [x8]
	cbnz	w8, LBB70_3
LBB70_7:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB70_8:
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB70_9:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w8, #2
	mov	x21, x0
	b.eq	LBB70_14
	add	x8, x0, #836
	mov	w22, #2
	swpa	w22, w8, [x8]
	cbz	w8, LBB70_1
LBB70_11:
Lloh360:
	adrp	x20, l___anon_2803@PAGE
Lloh361:
	add	x20, x20, l___anon_2803@PAGEOFF
LBB70_12:
	add	x23, x0, #836
	add	x0, x21, #836
	mov	w1, #2
	mov	x2, x20
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x0, x21
	swpa	w22, w8, [x23]
	cbnz	w8, LBB70_12
	b	LBB70_1
LBB70_13:
	mov	x0, x19
	mov	w1, #1
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	b	l_Io.Threaded.Thread.futexWake
LBB70_14:
	.cfi_restore_state
Lloh362:
	adrp	x2, l___anon_2803@PAGE
Lloh363:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x21, #836
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x0, x21
	add	x8, x21, #836
	mov	w22, #2
	swpa	w22, w8, [x8]
	cbnz	w8, LBB70_11
	b	LBB70_1
	.loh AdrpAdd	Lloh360, Lloh361
	.loh AdrpAdd	Lloh362, Lloh363
	.cfi_endproc

	.p2align	2
l_Io.Threaded.childCleanupPosix:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x0
	ldrb	w8, [x0, #168]
	tbz	w8, #0, LBB71_5
	mov	x20, x19
	ldr	w0, [x20, #160]!
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB71_4
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB71_16
	cmp	w8, #16, lsl #12
	b.hs	LBB71_16
LBB71_4:
	str	wzr, [x20, #8]
	str	xzr, [x20]
LBB71_5:
	ldrb	w8, [x19, #180]
	tbz	w8, #0, LBB71_10
	mov	x20, x19
	ldr	w0, [x20, #172]!
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB71_9
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB71_16
	cmp	w8, #16, lsl #12
	b.hs	LBB71_16
LBB71_9:
	str	wzr, [x20, #8]
	str	xzr, [x20]
LBB71_10:
	ldrb	w8, [x19, #192]
	tbz	w8, #0, LBB71_15
	mov	x20, x19
	ldr	w0, [x20, #184]!
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB71_14
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB71_16
	cmp	w8, #16, lsl #12
	b.hs	LBB71_16
LBB71_14:
	str	wzr, [x20, #8]
	str	xzr, [x20]
LBB71_15:
	str	xzr, [x19, #152]
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB71_16:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Environ.scan:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x28, x27, [sp, #16]
	stp	x26, x25, [sp, #32]
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	ldr	x26, [x0, #8]
	cbz	x26, LBB72_64
	mov	x19, x0
	mov	x27, #0
	ldr	x8, [x0]
	str	x8, [sp, #8]
	b	LBB72_4
LBB72_2:
	mov	w8, #1
	strb	w8, [x19, #110]
LBB72_3:
	add	x27, x27, #1
	cmp	x27, x26
	b.eq	LBB72_64
LBB72_4:
	ldr	x8, [sp, #8]
	ldr	x21, [x8, x27, lsl #3]
	cbz	x21, LBB72_66
	mov	x23, #0
LBB72_6:
	ldrb	w8, [x21, x23]
	cbz	w8, LBB72_12
	cmp	w8, #61
	b.eq	LBB72_9
	adds	x23, x23, #1
	b.lo	LBB72_6
	b	LBB72_65
LBB72_9:
	add	x8, x21, #1
	mov	x28, x23
LBB72_10:
	cmn	x28, #1
	b.eq	LBB72_65
	ldrb	w9, [x8, x28]
	add	x28, x28, #1
	cbnz	w9, LBB72_10
	b	LBB72_13
LBB72_12:
	mov	x28, x23
LBB72_13:
	adds	x25, x23, #1
	b.hs	LBB72_65
	cmp	x28, x25
	b.lo	LBB72_67
	cmp	x23, #0
	csinc	x24, x21, xzr, ne
	mov	x0, x24
	mov	x1, x23
Lloh364:
	adrp	x2, l___anon_7041@PAGE
Lloh365:
	add	x2, x2, l___anon_7041@PAGEOFF
	mov	w3, #8
	bl	l_mem.eqlBytes
	tbnz	w0, #0, LBB72_2
	mov	x0, x24
	mov	x1, x23
Lloh366:
	adrp	x2, l___anon_7049@PAGE
Lloh367:
	add	x2, x2, l___anon_7049@PAGEOFF
	mov	w3, #14
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_18
	mov	w8, #1
	strb	w8, [x19, #111]
	b	LBB72_3
LBB72_18:
	add	x20, x21, x25
	sub	x22, x28, x25
	mov	x0, x24
	mov	x1, x23
Lloh368:
	adrp	x2, l___anon_7054@PAGE
Lloh369:
	add	x2, x2, l___anon_7054@PAGEOFF
	mov	w3, #12
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_21
	strh	wzr, [x19, #104]
	cmp	x28, x25
	b.ne	LBB72_31
LBB72_20:
	mov	w8, #78
	stur	w8, [x19, #104]
	stur	xzr, [x19, #96]
	b	LBB72_3
LBB72_21:
	mov	x0, x24
	mov	x1, x23
Lloh370:
	adrp	x2, l___anon_7072@PAGE
Lloh371:
	add	x2, x2, l___anon_7072@PAGEOFF
	mov	w3, #4
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_23
	stp	x20, x22, [x19, #16]
LBB72_23:
	mov	x0, x24
	mov	x1, x23
Lloh372:
	adrp	x2, l___anon_7081@PAGE
Lloh373:
	add	x2, x2, l___anon_7081@PAGEOFF
	mov	w3, #21
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_25
	stp	x20, x22, [x19, #32]
LBB72_25:
	mov	x0, x24
	mov	x1, x23
Lloh374:
	adrp	x2, l___anon_7084@PAGE
Lloh375:
	add	x2, x2, l___anon_7084@PAGEOFF
	mov	w3, #14
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_27
	stp	x20, x22, [x19, #48]
LBB72_27:
	mov	x0, x24
	mov	x1, x23
Lloh376:
	adrp	x2, l___anon_7087@PAGE
Lloh377:
	add	x2, x2, l___anon_7087@PAGEOFF
	mov	w3, #4
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_29
	stp	x20, x22, [x19, #64]
LBB72_29:
	mov	x0, x24
	mov	x1, x23
Lloh378:
	adrp	x2, l___anon_7090@PAGE
Lloh379:
	add	x2, x2, l___anon_7090@PAGEOFF
	mov	w3, #4
	bl	l_mem.eqlBytes
	tbz	w0, #0, LBB72_3
	stp	x20, x22, [x19, #80]
	b	LBB72_3
LBB72_31:
	ldrb	w9, [x20]
	cmp	w9, #95
	b.eq	LBB72_20
	add	x10, x21, x23
	add	x8, x10, #2
	cmp	w9, #45
	b.eq	LBB72_38
	cmp	w9, #43
	b.ne	LBB72_45
	cmp	x22, #1
	b.eq	LBB72_20
	ldrb	w9, [x20, #1]
	cmp	w9, #95
	b.eq	LBB72_20
	add	x9, x21, x28
	ldurb	w9, [x9, #-1]
	cmp	w9, #95
	b.eq	LBB72_20
	mov	w9, #0
	sub	x10, x28, x23
	sub	x10, x10, #2
	b	LBB72_58
LBB72_38:
	cmp	x22, #1
	b.eq	LBB72_20
	ldrb	w9, [x20, #1]
	cmp	w9, #95
	b.eq	LBB72_20
	add	x9, x21, x28
	ldurb	w9, [x9, #-1]
	cmp	w9, #95
	b.eq	LBB72_20
	sub	x9, x28, x23
	sub	x9, x9, #2
	b	LBB72_43
LBB72_42:
	add	x8, x8, #1
	subs	x9, x9, #1
	b.eq	LBB72_63
LBB72_43:
	ldrb	w10, [x8]
	cmp	w10, #48
	b.eq	LBB72_42
	cmp	w10, #95
	b.eq	LBB72_42
	b	LBB72_20
LBB72_45:
	add	x8, x21, x28
	ldurb	w8, [x8, #-1]
	cmp	w8, #95
	b.eq	LBB72_20
	mov	w9, #0
	add	x8, x10, #1
	sub	x10, x23, x28
	add	x10, x10, #1
	b	LBB72_50
LBB72_47:
	add	w9, w9, w11, uxtb
	lsr	w11, w9, #31
	tbnz	w11, #0, LBB72_20
	and	w9, w9, #0x7fffffff
LBB72_49:
	adds	x10, x10, #1
	b.hs	LBB72_63
LBB72_50:
	ldrb	w11, [x8], #1
	cmp	w11, #95
	b.eq	LBB72_49
	sub	w11, w11, #48
	cmp	w11, #9
	b.hi	LBB72_20
	cbz	w9, LBB72_47
	and	w9, w9, #0x7fffffff
	mov	w12, #10
	umull	x9, w9, w12
	lsr	w12, w9, #31
	tst	x9, #0xffffffff00000000
	csinc	w12, w12, wzr, eq
	tbnz	w12, #0, LBB72_20
	and	w9, w9, #0x7fffffff
	b	LBB72_47
LBB72_55:
	add	w9, w9, w11, uxtb
	lsr	w11, w9, #31
	tbnz	w11, #0, LBB72_20
	and	w9, w9, #0x7fffffff
LBB72_57:
	subs	x10, x10, #1
	b.eq	LBB72_63
LBB72_58:
	ldrb	w11, [x8], #1
	cmp	w11, #95
	b.eq	LBB72_57
	sub	w11, w11, #48
	cmp	w11, #9
	b.hi	LBB72_20
	cbz	w9, LBB72_55
	and	w9, w9, #0x7fffffff
	mov	w12, #10
	umull	x9, w9, w12
	lsr	w12, w9, #31
	tst	x9, #0xffffffff00000000
	csinc	w12, w12, wzr, eq
	tbnz	w12, #0, LBB72_20
	and	w9, w9, #0x7fffffff
	b	LBB72_55
LBB72_63:
	and	w8, w9, #0x7fffffff
	str	w8, [x19, #96]
	mov	w8, #1
	strb	w8, [x19, #100]
	b	LBB72_3
LBB72_64:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	ldp	x26, x25, [sp, #32]
	ldp	x28, x27, [sp, #16]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB72_65:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB72_66:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB72_67:
	mov	x0, x25
	mov	x1, x28
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.loh AdrpAdd	Lloh364, Lloh365
	.loh AdrpAdd	Lloh366, Lloh367
	.loh AdrpAdd	Lloh368, Lloh369
	.loh AdrpAdd	Lloh370, Lloh371
	.loh AdrpAdd	Lloh372, Lloh373
	.loh AdrpAdd	Lloh374, Lloh375
	.loh AdrpAdd	Lloh376, Lloh377
	.loh AdrpAdd	Lloh378, Lloh379
	.cfi_endproc

	.p2align	2
l_mem.eqlBytes:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cmp	x1, x3
	b.ne	LBB73_7
	cmp	x0, x2
	b.eq	LBB73_5
	subs	x8, x1, #16
	b.hi	LBB73_6
	cmp	x1, #3
	b.hi	LBB73_9
	lsr	x8, x1, #1
	sub	x9, x1, #1
	ldrb	w10, [x0, x9]
	ldrb	w11, [x2]
	ldrb	w12, [x0]
	ldrb	w9, [x2, x9]
	ldrb	w13, [x0, x8]
	ldrb	w8, [x2, x8]
	cmp	w12, w11
	ccmp	w10, w9, #0, eq
	ccmp	w13, w8, #0, eq
	cset	w8, eq
	b	LBB73_8
LBB73_5:
	mov	w8, #1
	b	LBB73_8
LBB73_6:
	ldr	q0, [x0]
	ldr	q1, [x2]
	cmeq.16b	v0, v0, v1
	mvn.16b	v0, v0
	umaxv.16b	b0, v0
	fmov	w9, s0
	tbz	w9, #0, LBB73_13
LBB73_7:
	mov	w8, #0
LBB73_8:
	and	w0, w8, #0x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB73_9:
	.cfi_restore_state
	sub	x10, x1, #4
	lsr	x8, x1, #1
	and	x11, x8, #0xc
	subs	x9, x10, x11
	b.lo	LBB73_15
	add	x8, x11, #4
	cmp	x8, x1
	b.hi	LBB73_14
	add	x8, x9, #4
	cmp	x8, x1
	b.hi	LBB73_14
	ldr	w8, [x2, x11]
	ldr	w11, [x0, x11]
	ldr	w12, [x2, x10]
	ldr	w10, [x0, x10]
	ldr	w13, [x2]
	ldr	w14, [x0, x9]
	ldr	w9, [x2, x9]
	ldr	w15, [x0]
	cmp	w12, w10
	ccmp	w13, w15, #0, eq
	ccmp	w8, w11, #0, eq
	ccmp	w9, w14, #0, eq
	cset	w8, eq
	b	LBB73_8
LBB73_13:
	ldr	q0, [x0, x8]
	ldr	q1, [x2, x8]
	cmeq.16b	v0, v0, v1
	mvn.16b	v0, v0
	umaxv.16b	b0, v0
	fmov	w8, s0
	eor	w8, w8, #0x1
	b	LBB73_8
LBB73_14:
	mov	x0, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB73_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.childWait:
	.cfi_startproc
	sub	sp, sp, #288
	.cfi_def_cfa_offset 288
	stp	x26, x25, [sp, #208]
	stp	x24, x23, [sp, #224]
	stp	x22, x21, [sp, #240]
	stp	x20, x19, [sp, #256]
	stp	x29, x30, [sp, #272]
	add	x29, sp, #272
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x19, x8
Lloh380:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh381:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh382:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB74_27
	tst	x0, #0x7
	b.ne	LBB74_28
	mov	x20, x1
	ldrb	w8, [x1, #156]
	tbz	w8, #0, LBB74_29
	ldr	w21, [x20, #152]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #144]
	stp	q0, q0, [sp, #112]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #48]
	str	q0, [sp, #32]
	ldrb	w23, [x20, #196]
	tst	w23, #0x1
	add	x8, sp, #32
	csel	x22, x8, xzr, ne
	mov	w8, #-1431655766
	str	w8, [sp, #12]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w25, [x29, #-80]
	cbnz	w25, LBB74_10
	ldur	x24, [x29, #-88]
LBB74_5:
	add	x1, sp, #12
	mov	x0, x21
	mov	w2, #0
	mov	x3, x22
	bl	_wait4
	cmn	w0, #1
	b.ne	LBB74_13
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB74_26
	cmp	w8, #16, lsl #12
	b.hs	LBB74_26
	cmp	w8, #4
	b.ne	LBB74_11
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w25, w0, #0xffff
	b.eq	LBB74_5
LBB74_10:
	mov	x0, x20
	bl	l_Io.Threaded.childCleanupPosix
	b	LBB74_20
LBB74_11:
	cmp	w8, #10
	b.eq	LBB74_19
	cbnz	w8, LBB74_19
LBB74_13:
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	tbz	w23, #0, LBB74_15
	ldp	q0, q1, [sp, #128]
	stp	q0, q1, [x20, #96]
	ldr	q0, [sp, #160]
	str	q0, [x20, #128]
	ldp	q0, q1, [sp, #64]
	stp	q0, q1, [x20, #32]
	ldp	q1, q0, [sp, #96]
	stp	q1, q0, [x20, #64]
	ldp	q1, q0, [sp, #32]
	stp	q1, q0, [x20]
	mov	w8, #1
	strb	w8, [x20, #144]
LBB74_15:
	ldr	w8, [sp, #12]
	and	w21, w8, #0x7f
	cmp	w21, #127
	b.eq	LBB74_21
	cbnz	w21, LBB74_22
	cmp	w8, #16, lsl #12
	b.hs	LBB74_26
	mov	w22, #0
	mov	x23, #0
	lsr	w21, w8, #8
	b	LBB74_23
LBB74_19:
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	l_Io.Threaded.childCleanupPosix
	mov	w25, #12
LBB74_20:
	b	LBB74_24
LBB74_21:
	mov	x9, #12884901888
	mov	w10, #4864
	lsr	w11, w8, #8
	and	w12, w11, #0xffff00
	mov	x13, #8589934592
	cmp	w11, #19
	csel	w21, w8, w11, eq
	csel	w22, w10, w12, eq
	csel	x23, x9, x13, eq
	b	LBB74_23
LBB74_22:
	mov	w22, #0
	mov	x23, #4294967296
LBB74_23:
	mov	x0, x20
	bl	l_Io.Threaded.childCleanupPosix
	mov	w25, #0
	and	w8, w21, #0xff
	orr	w8, w22, w8
	orr	x8, x23, x8
LBB74_24:
	str	x8, [x19]
	strh	w25, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh383:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh384:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh385:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB74_30
	.cfi_def_cfa wsp, 288
	ldp	x29, x30, [sp, #272]
	ldp	x20, x19, [sp, #256]
	ldp	x22, x21, [sp, #240]
	ldp	x24, x23, [sp, #224]
	ldp	x26, x25, [sp, #208]
	add	sp, sp, #288
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB74_26:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB74_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB74_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB74_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB74_30:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh380, Lloh381, Lloh382
	.loh AdrpLdrGotLdr	Lloh383, Lloh384, Lloh385
	.cfi_endproc

	.p2align	2
l_Io.Threaded.processSpawnDarwin:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #656
	mov	x26, x8
Lloh386:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh387:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh388:
	ldr	x8, [x8]
	str	x8, [sp, #232]
	stur	x8, [x29, #-104]
	add	x20, sp, #432
	ldp	q0, q1, [x1]
	stp	q0, q1, [x20, #112]
	ldp	x27, x23, [x1, #32]
	ldr	q0, [x1, #48]
	str	q0, [x20, #80]
	ldr	x8, [x1, #64]
	stur	x8, [x29, #-208]
	cbz	x0, LBB75_42
	mov	x21, x0
	tst	x0, #0x7
	b.ne	LBB75_41
	mov	x19, x30
	ldp	x9, x10, [x1, #72]
	str	x9, [sp, #224]
	ldp	x9, x8, [x1, #88]
	stp	x9, x10, [sp, #192]
	str	x8, [sp, #176]
	ldr	x8, [x1, #104]
	str	x8, [sp, #160]
	ldr	w24, [x1, #112]
	ldrb	w9, [x1, #120]
	ldr	w8, [x1, #124]
	str	w8, [sp, #188]
	ldrb	w8, [x1, #132]
	str	w8, [sp, #172]
	ldr	w10, [x1, #136]
	ldrb	w8, [x1, #144]
	stp	w8, w10, [sp, #152]
	ldur	x8, [x1, #164]
	str	x8, [sp, #144]
	ldrb	w8, [x1, #172]
	str	w8, [sp, #212]
	ldrb	w8, [x1, #173]
	stp	w8, w9, [sp, #216]
	ldrb	w22, [x1, #174]
	ldrb	w8, [x1, #175]
	str	w8, [sp, #140]
	mov	x0, x21
	bl	l_Io.Threaded.scanEnviron
	ldr	x10, [x21, #600]
	ldr	x9, [x21, #608]
	add	x8, x21, #744
	ldr	q0, [x8]
	stp	xzr, xzr, [sp, #448]
	ldr	q1, [x20, #16]
	stp	q0, q1, [sp, #240]
	adds	x25, x23, #1
	b.hs	LBB75_38
	xpaci	x19
	lsr	x8, x25, #61
	cbz	x8, LBB75_5
	mov	w23, #64
	add	x8, sp, #272
	b	LBB75_21
LBB75_5:
	stp	x10, x9, [sp, #104]
	str	x26, [sp, #128]
	lsl	x26, x25, #3
	add	x0, sp, #240
	mov	x1, x26
	mov	w2, #3
	bl	l_heap.ArenaAllocator.alloc
	cbz	x0, LBB75_18
	mov	x20, x0
	mov	w1, #170
	mov	x2, x26
	bl	_memset
	tst	x20, #0x7
	b.ne	LBB75_41
	stp	w22, w24, [sp, #96]
	cmp	x23, x25
	b.hs	LBB75_44
	str	x20, [sp, #120]
	str	xzr, [x20, x23, lsl #3]
	cbz	x23, LBB75_15
	add	x24, x27, #8
	ldr	x22, [sp, #120]
LBB75_10:
	ldr	x25, [x24]
	adds	x26, x25, #1
	b.hs	LBB75_38
	ldur	x28, [x24, #-8]
	add	x0, sp, #240
	mov	x1, x26
	mov	w2, #0
	bl	l_heap.ArenaAllocator.alloc
	cbz	x0, LBB75_19
	mov	x27, x0
	mov	w1, #170
	mov	x2, x26
	bl	_memset
	add	x20, x27, x25
	add	x8, x28, x25
	cmp	x27, x8
	ccmp	x28, x20, #2, lo
	b.lo	LBB75_40
	mov	x0, x27
	mov	x1, x28
	mov	x2, x25
	bl	_memcpy
	cmp	x25, x26
	b.hs	LBB75_39
	add	x24, x24, #16
	strb	wzr, [x20]
	str	x27, [x22], #8
	subs	x23, x23, #1
	b.ne	LBB75_10
LBB75_15:
	ldr	x1, [sp, #224]
	cbz	x1, LBB75_29
Lloh389:
	adrp	x3, l___anon_4630@PAGE
Lloh390:
	add	x3, x3, l___anon_4630@PAGEOFF
	sub	x22, x29, #152
	sub	x0, x29, #152
	add	x2, sp, #240
	bl	l_process.Environ.Map.createPosixBlock
	ldurh	w23, [x29, #-136]
	ldr	x26, [sp, #128]
	ldr	w11, [sp, #100]
	cbz	w23, LBB75_30
	add	x8, sp, #336
	b	LBB75_21
LBB75_18:
	mov	w23, #64
	add	x8, sp, #272
	b	LBB75_20
LBB75_19:
	mov	w23, #64
	add	x8, sp, #304
LBB75_20:
	ldr	x26, [sp, #128]
LBB75_21:
	ldp	q0, q1, [sp, #240]
	stp	q0, q1, [x8]
	ldp	x21, x22, [x8]
	ldp	x1, x24, [x8, #16]
	cbz	x1, LBB75_23
LBB75_22:
	ldr	x20, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x21
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x20
	cbnz	x20, LBB75_22
LBB75_23:
	cbz	x24, LBB75_26
	mov	x1, x24
LBB75_25:
	ldr	x20, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x21
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x20
	cbnz	x20, LBB75_25
LBB75_26:
	strh	w23, [x26, #200]
LBB75_27:
	ldur	x8, [x29, #-104]
Lloh391:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh392:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh393:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB75_43
	add	sp, sp, #656
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB75_29:
	.cfi_restore_state
	ldr	x1, [x21, #584]
	ldr	x2, [x21, #592]
Lloh394:
	adrp	x4, l___anon_4630@PAGE
Lloh395:
	add	x4, x4, l___anon_4630@PAGEOFF
	sub	x22, x29, #128
	sub	x0, x29, #128
	add	x3, sp, #240
	bl	l_process.Environ.createPosixBlock
	ldurh	w23, [x29, #-112]
	ldr	x26, [sp, #128]
	ldr	w11, [sp, #100]
	cbnz	w23, LBB75_37
LBB75_30:
	ldr	x6, [x22]
	ldr	x12, [sp, #144]
	lsr	x8, x12, #32
Lloh396:
	adrp	x9, l___anon_7325@PAGE
Lloh397:
	add	x9, x9, l___anon_7325@PAGEOFF
	ldp	x10, x13, [sp, #104]
	cmp	x10, #0
	csel	x9, x9, x10, eq
	mov	w10, #28
	csel	x10, x10, x13, eq
	stp	x9, x10, [sp, #72]
	ldr	w9, [sp, #140]
	and	w9, w9, #0x1
	strb	w9, [sp, #69]
	strb	w8, [sp, #68]
	str	w12, [sp, #64]
	ldr	x9, [sp, #160]
	ldr	x8, [sp, #176]
	stp	x8, x9, [sp, #48]
	ldp	x9, x8, [sp, #192]
	stp	x8, x9, [sp, #32]
	ldp	w9, w8, [sp, #152]
	strb	w9, [sp, #24]
	str	w8, [sp, #20]
	ldr	w8, [sp, #172]
	strb	w8, [sp, #16]
	ldr	w8, [sp, #188]
	str	w8, [sp, #12]
	add	x0, sp, #464
	sub	x3, x29, #192
	sub	x5, x29, #224
	ldr	w8, [sp, #212]
	and	w7, w8, #0x1
	ldp	w8, w9, [sp, #216]
	strb	w9, [sp, #8]
	str	w11, [sp, #4]
	strb	w8, [sp]
	mov	x1, x21
	mov	w2, #0
	ldr	x4, [sp, #120]
	bl	l_Io.Threaded.spawnDarwin
	ldrh	w23, [sp, #508]
	cbnz	w23, LBB75_36
	ldr	w8, [sp, #464]
	str	w8, [x26, #152]
	mov	w8, #1
	strb	w8, [x26, #156]
	ldr	x8, [sp, #472]
	str	x8, [x26, #160]
	ldr	w8, [sp, #480]
	ldr	w9, [sp, #492]
	str	w8, [x26, #168]
	strh	wzr, [x26, #200]
	add	x8, sp, #432
	ldur	x8, [x8, #52]
	stur	x8, [x26, #172]
	str	w9, [x26, #180]
	ldr	x8, [sp, #496]
	str	x8, [x26, #184]
	ldr	w8, [sp, #504]
	str	w8, [x26, #192]
	ldr	w8, [sp, #96]
	and	w8, w8, #0x1
	strb	w8, [x26, #196]
	str	xzr, [x26, #144]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x26, #112]
	stp	q0, q0, [x26, #80]
	stp	q0, q0, [x26, #48]
	stp	q0, q0, [x26, #16]
	str	q0, [x26]
	ldp	x20, x21, [sp, #240]
	ldp	x1, x22, [sp, #256]
	cbz	x1, LBB75_33
LBB75_32:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x21, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB75_32
LBB75_33:
	cbz	x22, LBB75_27
	mov	x1, x22
LBB75_35:
	ldr	x22, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x21, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x22
	cbnz	x22, LBB75_35
	b	LBB75_27
LBB75_36:
	add	x8, sp, #400
	b	LBB75_21
LBB75_37:
	add	x8, sp, #368
	b	LBB75_21
LBB75_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB75_39:
	mov	x0, x25
	mov	x1, x26
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB75_40:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB75_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB75_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB75_43:
	bl	___stack_chk_fail
LBB75_44:
	mov	x0, x23
	mov	x1, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh386, Lloh387, Lloh388
	.loh AdrpAdd	Lloh389, Lloh390
	.loh AdrpLdrGotLdr	Lloh391, Lloh392, Lloh393
	.loh AdrpAdd	Lloh394, Lloh395
	.loh AdrpAdd	Lloh396, Lloh397
	.cfi_endproc

	.p2align	2
l_Io.Threaded.spawnDarwin:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #3520
	mov	x28, x7
	mov	x21, x6
	mov	x26, x5
	mov	x22, x4
	mov	x24, x3
	mov	x25, x2
	mov	x20, x1
	mov	x19, x0
Lloh398:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh399:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh400:
	ldr	x8, [x8]
	str	x8, [sp, #168]
	stur	x8, [x29, #-96]
	mov	x8, #-6148914691236517206
	str	x8, [sp, #176]
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_init
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #12
	b.eq	LBB76_172
	cbnz	w0, LBB76_161
	mov	x8, #-6148914691236517206
	str	x8, [sp, #184]
	add	x0, sp, #184
	bl	_posix_spawnattr_init
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #12
	b.eq	LBB76_170
	cbnz	w0, LBB76_159
	str	x19, [sp, #120]
	ldrb	w8, [x29, #24]
	str	w8, [sp, #140]
	and	w27, w8, #0x7
Lloh401:
	adrp	x10, l___anon_6334@PAGE
Lloh402:
	add	x10, x10, l___anon_6334@PAGEOFF
	add	x8, x10, #4
	str	x8, [sp, #128]
	cmp	w27, #3
	b.ne	LBB76_11
	mov	x19, x10
	add	x0, sp, #224
	mov	w1, #16777216
	bl	l_Io.Threaded.pipe2
	ldrh	w23, [sp, #232]
	cbnz	w23, LBB76_189
	ldp	w9, w8, [sp, #224]
	str	w9, [sp, #36]
	stp	w8, w9, [sp, #144]
	str	w8, [sp, #28]
	add	x8, sp, #148
	str	x8, [sp, #96]
	add	x8, sp, #144
	str	x8, [sp, #104]
	mov	x10, x19
	b	LBB76_12
LBB76_11:
	add	x8, x10, #4
	stp	x10, x8, [sp, #96]
LBB76_12:
	ldrb	w8, [x29, #32]
	and	w9, w8, #0x7
	str	w8, [sp, #136]
	and	w8, w8, #0x7
	str	w8, [sp, #116]
	cmp	w9, #3
	b.ne	LBB76_16
	mov	x19, x10
	add	x0, sp, #236
	mov	w1, #16777216
	bl	l_Io.Threaded.pipe2
	ldrh	w23, [sp, #244]
	cbnz	w23, LBB76_187
	ldp	w8, w9, [sp, #236]
	str	w8, [sp, #24]
	stp	w9, w8, [sp, #152]
	str	w9, [sp, #44]
	add	x8, sp, #156
	str	x8, [sp, #88]
	add	x8, sp, #152
	str	x8, [sp, #128]
	mov	x10, x19
	ldrb	w11, [x29, #40]
	and	w9, w11, #0x7
	cmp	w9, #3
	b.eq	LBB76_17
LBB76_15:
	add	x23, x10, #4
	b	LBB76_19
LBB76_16:
	str	x10, [sp, #88]
	ldrb	w11, [x29, #40]
	and	w9, w11, #0x7
	cmp	w9, #3
	b.ne	LBB76_15
LBB76_17:
	mov	x19, x11
	add	x0, sp, #248
	mov	w1, #16777216
	bl	l_Io.Threaded.pipe2
	ldrh	w23, [sp, #256]
	cbnz	w23, LBB76_185
	ldp	w8, w9, [sp, #248]
	str	w8, [sp, #20]
	stp	w9, w8, [sp, #160]
	str	w9, [sp, #32]
	add	x10, sp, #164
	add	x23, sp, #160
	mov	x11, x19
	and	w9, w19, #0x7
LBB76_19:
	cmp	w27, #2
	b.eq	LBB76_25
	ldr	w8, [sp, #136]
	and	w8, w8, #0x7
	cmp	w8, #2
	b.eq	LBB76_25
	cmp	w9, #2
	b.eq	LBB76_25
LBB76_22:
	stp	x10, x23, [sp, #64]
	str	w11, [sp, #60]
	and	w8, w11, #0x7
	str	w8, [sp, #112]
	ldrb	w9, [x29, #16]
	mov	w8, #255
	str	w9, [sp, #56]
	bics	wzr, w8, w9
	b.eq	LBB76_32
	ldr	w19, [sp, #140]
	and	w23, w19, #0x7
	add	x0, sp, #260
	mov	w1, #4
	movk	w1, #256, lsl #16
	bl	l_Io.Threaded.pipe2
	ldrh	w27, [sp, #268]
	cbnz	w27, LBB76_197
	ldr	w8, [sp, #260]
	str	w8, [sp, #80]
	ldr	w23, [sp, #264]
	and	w27, w19, #0x7
	b	LBB76_33
LBB76_25:
	ldr	w8, [sp, #140]
	and	w8, w8, #0x7
	str	w8, [sp, #48]
	mov	w8, #0
	add	x27, x20, #836
	mov	w9, #1
	casa	w8, w9, [x27]
	cmp	w8, #0
	b.ne	LBB76_194
LBB76_26:
	ldr	w9, [x20, #848]
	swpl	wzr, w8, [x27]
	str	w9, [sp, #40]
	cmn	w9, #1
	b.eq	LBB76_81
	cbz	w8, LBB76_335
	cmp	w8, #1
	b.eq	LBB76_31
	cmp	w8, #2
	b.ne	LBB76_84
	mov	x27, x11
	add	x0, x20, #836
	mov	w1, #1
	mov	x19, x10
	bl	l_Io.Threaded.Thread.futexWake
	mov	x11, x27
	mov	x10, x19
LBB76_31:
	ldr	w8, [sp, #140]
	and	w27, w8, #0x7
	b	LBB76_22
LBB76_32:
	mov	w8, #-1
	str	w8, [sp, #80]
	mov	w23, #-1
LBB76_33:
	add	x0, sp, #272
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	ldrb	w8, [x26, #16]
	and	w8, w8, #0x3
	cmp	w8, #1
	b.gt	LBB76_64
	cbnz	w8, LBB76_76
LBB76_35:
	str	w23, [sp, #52]
	ldr	w8, [sp, #140]
	and	w23, w8, #0x7
	ldr	x26, [x29, #56]
	cbz	x26, LBB76_41
	ldr	x27, [x29, #48]
LBB76_37:
	ldr	w1, [x27], #4
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_addinherit_np
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cbnz	w0, LBB76_57
	subs	x26, x26, #1
	b.ne	LBB76_37
LBB76_41:
	ldr	x26, [x29, #72]
	cbz	x26, LBB76_47
	ldr	x27, [x29, #64]
LBB76_43:
	ldr	w1, [x27], #8
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_addinherit_np
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cbnz	w0, LBB76_57
	subs	x26, x26, #1
	b.ne	LBB76_43
LBB76_47:
	ldr	w23, [sp, #52]
	cmn	w23, #1
	ldr	w26, [sp, #140]
	and	w27, w26, #0x7
	b.eq	LBB76_52
	add	x0, sp, #176
	mov	x1, x23
	bl	_posix_spawn_file_actions_addinherit_np
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #11
	b.gt	LBB76_148
	cbnz	w0, LBB76_80
LBB76_52:
	and	w26, w26, #0x7
	cmp	w26, #1
	b.le	LBB76_105
	cmp	w26, #2
	b.eq	LBB76_108
	cmp	w26, #3
	b.eq	LBB76_109
	cmp	w26, #4
	b.ne	LBB76_84
	add	x0, sp, #176
	mov	w1, #0
	bl	_posix_spawn_file_actions_addclose
	tbz	w0, #31, LBB76_112
	b	LBB76_505
LBB76_57:
	ldr	x21, [sp, #72]
	cmp	w0, #9
	b.eq	LBB76_90
	cmp	w0, #12
	ldr	x19, [sp, #120]
	b.eq	LBB76_91
	cmp	w0, #22
	ldr	w1, [sp, #52]
	ldr	w0, [sp, #80]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_61
LBB76_60:
	ldr	x8, [sp, #64]
	ldr	w0, [x8]
	ldr	w1, [x21]
	bl	l_Io.Threaded.destroyPipe
LBB76_61:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_85
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w23, #3
	b.eq	LBB76_86
LBB76_63:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_158
	b	LBB76_505
LBB76_64:
	cmp	w8, #2
	b.ne	LBB76_84
	ldp	x1, x2, [x26]
	add	x0, sp, #1296
	add	x3, sp, #272
	bl	l_Io.Threaded.pathToPosix
	ldrh	w26, [sp, #1312]
	cbnz	w26, LBB76_220
	ldr	x1, [sp, #1296]
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_addchdir_np
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #11
	b.le	LBB76_87
	cmp	w0, #12
	b.eq	LBB76_162
	cmp	w0, #22
	ldr	w8, [sp, #80]
	b.eq	LBB76_89
	cmp	w0, #63
	b.ne	LBB76_89
	mov	x0, x8
	mov	x1, x23
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_98
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_99
LBB76_74:
	cmp	w27, #3
	b.ne	LBB76_100
LBB76_75:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	ldr	x19, [sp, #120]
	tbz	w0, #31, LBB76_101
	b	LBB76_505
LBB76_76:
	ldr	w1, [x26]
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_addfchdir_np
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #11
	b.gt	LBB76_148
	cbz	w0, LBB76_35
LBB76_80:
	cmp	w0, #9
	b	LBB76_150
LBB76_81:
	cbz	w8, LBB76_335
	cmp	w8, #1
	b.eq	LBB76_232
	cmp	w8, #2
	b.eq	LBB76_231
LBB76_84:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB76_85:
	cmp	w23, #3
	b.ne	LBB76_63
LBB76_86:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_158
	b	LBB76_505
LBB76_87:
	cbz	w0, LBB76_35
	cmp	w0, #9
	ldr	w8, [sp, #80]
LBB76_89:
	mov	x0, x8
	b	LBB76_151
LBB76_90:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	ldr	x19, [sp, #120]
	b.eq	LBB76_60
	b	LBB76_61
LBB76_91:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_95
	ldr	x8, [sp, #64]
	ldr	w0, [x8]
	ldr	w1, [x21]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_96
LBB76_93:
	cmp	w23, #3
	b.ne	LBB76_97
LBB76_94:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_169
	b	LBB76_505
LBB76_95:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_93
LBB76_96:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w23, #3
	b.eq	LBB76_94
LBB76_97:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_169
	b	LBB76_505
LBB76_98:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_74
LBB76_99:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w27, #3
	b.eq	LBB76_75
LBB76_100:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	ldr	x19, [sp, #120]
	tbnz	w0, #31, LBB76_505
LBB76_101:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh403:
	adrp	x8, l___anon_7603@PAGE
Lloh404:
	add	x8, x8, l___anon_7603@PAGEOFF
	b	LBB76_173
LBB76_105:
	cbz	w26, LBB76_111
	cmp	w26, #1
	b.ne	LBB76_84
	ldr	w1, [x29, #20]
	add	x0, sp, #176
	b	LBB76_110
LBB76_108:
	add	x0, sp, #176
	ldr	w1, [sp, #40]
	b	LBB76_110
LBB76_109:
	add	x0, sp, #176
	ldr	w1, [sp, #36]
LBB76_110:
	mov	w2, #0
	bl	_posix_spawn_file_actions_adddup2
	tbz	w0, #31, LBB76_112
	b	LBB76_505
LBB76_111:
	add	x0, sp, #176
	mov	w1, #0
	bl	_posix_spawn_file_actions_addinherit_np
	tbnz	w0, #31, LBB76_505
LBB76_112:
	cmp	w0, #16, lsl #12
	ldr	w1, [sp, #44]
	b.hs	LBB76_505
	cmp	w0, #11
	b.gt	LBB76_148
	cbnz	w0, LBB76_80
	ldr	w8, [sp, #136]
	and	w8, w8, #0x7
	cmp	w8, #1
	str	w8, [sp, #140]
	b.le	LBB76_120
	cmp	w8, #2
	b.eq	LBB76_124
	cmp	w8, #3
	b.eq	LBB76_123
	cmp	w8, #4
	b.ne	LBB76_84
	add	x0, sp, #176
	mov	w1, #1
	bl	_posix_spawn_file_actions_addclose
	b	LBB76_127
LBB76_120:
	cbz	w8, LBB76_126
	cmp	w8, #1
	b.ne	LBB76_84
	ldr	w1, [x29, #28]
LBB76_123:
	add	x0, sp, #176
	b	LBB76_125
LBB76_124:
	add	x0, sp, #176
	ldr	w1, [sp, #40]
LBB76_125:
	mov	w2, #1
	bl	_posix_spawn_file_actions_adddup2
	b	LBB76_127
LBB76_126:
	add	x0, sp, #176
	mov	w1, #1
	bl	_posix_spawn_file_actions_addinherit_np
LBB76_127:
	tbnz	w0, #31, LBB76_505
	lsr	w8, w0, #16
	cbnz	w8, LBB76_505
	cmp	w0, #11
	b.gt	LBB76_148
	cbnz	w0, LBB76_80
	ldr	w8, [sp, #60]
	and	w8, w8, #0x7
	cmp	w8, #1
	b.le	LBB76_136
	cmp	w8, #2
	b.eq	LBB76_139
	mov	x19, x8
	cmp	w8, #3
	b.eq	LBB76_140
	cmp	w19, #4
	b.ne	LBB76_84
	add	x0, sp, #176
	mov	w1, #2
	bl	_posix_spawn_file_actions_addclose
	b	LBB76_143
LBB76_136:
	mov	x19, x8
	cbz	w8, LBB76_142
	cmp	w19, #1
	b.ne	LBB76_84
	ldr	w1, [x29, #36]
	add	x0, sp, #176
	b	LBB76_141
LBB76_139:
	mov	x19, x8
	add	x0, sp, #176
	ldr	w1, [sp, #40]
	b	LBB76_141
LBB76_140:
	add	x0, sp, #176
	ldr	w1, [sp, #32]
LBB76_141:
	mov	w2, #2
	bl	_posix_spawn_file_actions_adddup2
	b	LBB76_143
LBB76_142:
	add	x0, sp, #176
	mov	w1, #2
	bl	_posix_spawn_file_actions_addinherit_np
LBB76_143:
	tbnz	w0, #31, LBB76_505
	lsr	w8, w0, #16
	cbnz	w8, LBB76_505
	cmp	w0, #11
	b.gt	LBB76_148
	cbz	w0, LBB76_176
	cmp	w0, #9
	ldr	w23, [sp, #52]
	b	LBB76_150
LBB76_148:
	cmp	w0, #12
	b.eq	LBB76_162
	cmp	w0, #22
LBB76_150:
	ldr	w0, [sp, #80]
LBB76_151:
	mov	x1, x23
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_155
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_156
LBB76_153:
	cmp	w27, #3
	b.ne	LBB76_157
LBB76_154:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	ldr	x19, [sp, #120]
	tbz	w0, #31, LBB76_158
	b	LBB76_505
LBB76_155:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_153
LBB76_156:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w27, #3
	b.eq	LBB76_154
LBB76_157:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	ldr	x19, [sp, #120]
	tbnz	w0, #31, LBB76_505
LBB76_158:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
LBB76_159:
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
LBB76_161:
	mov	w8, #12
	strh	w8, [x19, #44]
	b	LBB76_174
LBB76_162:
	ldr	w0, [sp, #80]
	mov	x1, x23
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_166
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_167
LBB76_164:
	cmp	w27, #3
	b.ne	LBB76_168
LBB76_165:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	ldr	x19, [sp, #120]
	tbz	w0, #31, LBB76_169
	b	LBB76_505
LBB76_166:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_164
LBB76_167:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w27, #3
	b.eq	LBB76_165
LBB76_168:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	ldr	x19, [sp, #120]
	tbnz	w0, #31, LBB76_505
LBB76_169:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
LBB76_170:
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
LBB76_172:
Lloh405:
	adrp	x8, l___anon_7447@PAGE
Lloh406:
	add	x8, x8, l___anon_7447@PAGEOFF
LBB76_173:
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldr	q0, [x8, #32]
	str	q0, [x19, #32]
LBB76_174:
	ldur	x8, [x29, #-96]
Lloh407:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh408:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh409:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB76_336
	add	sp, sp, #3520
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB76_176:
	.cfi_restore_state
	str	w27, [sp, #48]
	ldrb	w23, [x29, #84]
	tbz	w23, #0, LBB76_208
	ldr	w1, [x29, #80]
	add	x0, sp, #184
	bl	_posix_spawnattr_setpgroup
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cbz	w0, LBB76_208
	cmp	w0, #22
	b.ne	LBB76_363
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_275
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_276
LBB76_183:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_277
LBB76_184:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_278
	b	LBB76_505
LBB76_185:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_187
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
LBB76_187:
	cmp	w27, #3
	b.ne	LBB76_189
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
LBB76_189:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_190:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	ldr	x8, [sp, #120]
	strh	w23, [x8, #44]
	b	LBB76_174
LBB76_194:
	mov	x19, x11
	and	w9, w11, #0x7
	str	w9, [sp, #112]
	stp	x10, x23, [sp, #64]
	cmp	w8, #2
	b.eq	LBB76_283
LBB76_195:
	mov	w8, #2
	swpa	w8, w8, [x27]
	ldp	x10, x23, [sp, #64]
	mov	x11, x19
	cbz	w8, LBB76_26
	add	x0, x20, #836
	mov	w1, #2
	mov	w2, #0
Lloh410:
	adrp	x3, l___anon_2803@PAGE
Lloh411:
	add	x3, x3, l___anon_2803@PAGEOFF
	bl	l_Io.Threaded.Thread.futexWaitInner
	mov	x23, x0
	tst	w0, #0xffff
	b.eq	LBB76_195
	b	LBB76_268
LBB76_197:
	ldr	x19, [sp, #72]
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_201
	ldr	x8, [sp, #64]
	ldr	w0, [x8]
	ldr	w1, [x19]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_202
LBB76_199:
	cmp	w23, #3
	b.ne	LBB76_203
LBB76_200:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_204
	b	LBB76_505
LBB76_201:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_199
LBB76_202:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w23, #3
	b.eq	LBB76_200
LBB76_203:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_204:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	ldr	x8, [sp, #120]
	strh	w27, [x8, #44]
	b	LBB76_174
LBB76_208:
	ldrb	w8, [x29, #85]
	tst	w25, #0x1
	mov	w9, #64
	csel	w9, w9, wzr, ne
	tst	w8, #0x1
	mov	w8, #128
	csel	w8, w8, wzr, ne
	orr	w1, w8, w9
	bfi	w1, w23, #1, #1
	add	x0, sp, #184
	bl	_posix_spawnattr_setflags
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #22
	b.eq	LBB76_363
	cbnz	w0, LBB76_363
	mov	w8, #-1431655766
	str	w8, [sp, #196]
	ldr	x0, [x22]
	cbz	x0, LBB76_512
	bl	l_mem.span__func_123
	mov	x27, x0
	mov	x25, x1
	add	x0, sp, #1320
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	ldrb	w8, [x24, #24]
	and	w9, w8, #0x7
	cmp	w9, #5
	b.hs	LBB76_84
	ldr	x23, [x24]
Lloh412:
	adrp	x9, l___jmptab_2945@PAGE
Lloh413:
	add	x9, x9, l___jmptab_2945@PAGEOFF
	ldr	x8, [x9, x8, lsl #3]
	br	x8
Ltmp0:
LBB76_215:
	add	x0, sp, #2344
	mov	x1, x27
	mov	x2, x25
	mov	w3, #47
	bl	l_mem.findScalar__func_124
	ldrb	w8, [sp, #2352]
	tbnz	w8, #0, LBB76_359
Ltmp1:
LBB76_216:
	cbz	x25, LBB76_218
	ldrb	w8, [x27]
	cmp	w8, #47
	b.eq	LBB76_359
LBB76_218:
	ldp	x24, x23, [x29, #88]
	add	x0, sp, #2360
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	stp	x24, x23, [x29, #-216]
	stur	xzr, [x29, #-200]
	mov	w8, #58
	sturb	w8, [x29, #-192]
	sub	x0, x29, #216
	bl	"l_mem.TokenIterator(u8,.scalar).next"
	cbz	x0, LBB76_339
	mov	x8, x0
	mov	x24, x1
	mov	w9, #39
	str	w9, [sp, #136]
	b	LBB76_311
LBB76_220:
	ldr	x19, [sp, #72]
	ldr	w0, [sp, #80]
	mov	x1, x23
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_224
	ldr	x8, [sp, #64]
	ldr	w0, [x8]
	ldr	w1, [x19]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_225
LBB76_222:
	cmp	w27, #3
	b.ne	LBB76_226
LBB76_223:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_227
	b	LBB76_505
LBB76_224:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_222
LBB76_225:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w27, #3
	b.eq	LBB76_223
LBB76_226:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_227:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	ldr	x8, [sp, #120]
	strh	w26, [x8, #44]
	b	LBB76_174
LBB76_231:
	str	w11, [sp, #60]
	add	x0, x20, #836
	mov	w1, #1
	mov	x19, x10
	bl	l_Io.Threaded.Thread.futexWake
	ldr	w11, [sp, #60]
	mov	x10, x19
LBB76_232:
	stp	x10, x23, [sp, #64]
	mov	x19, x11
	and	w8, w11, #0x7
	str	w8, [sp, #112]
	sub	x0, x29, #112
	bl	l_Io.Threaded.Syscall.start
	ldurh	w23, [x29, #-104]
	cbnz	w23, LBB76_268
	ldur	x8, [x29, #-112]
	str	x8, [sp, #80]
LBB76_234:
	str	xzr, [sp]
Lloh414:
	adrp	x0, l___anon_7555@PAGE
Lloh415:
	add	x0, x0, l___anon_7555@PAGEOFF
	mov	w1, #2
	bl	_open
	mov	x23, x0
	cmn	w0, #1
	b.ne	LBB76_248
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB76_505
	cmp	w8, #16, lsl #12
	b.hs	LBB76_505
	cmp	w8, #4
	b.ne	LBB76_239
	ldr	x8, [sp, #80]
	str	x8, [sp, #208]
	add	x0, sp, #208
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w23, w0, #0xffff
	b.eq	LBB76_234
	b	LBB76_268
LBB76_239:
	cmp	w8, #12
	b.gt	LBB76_244
	cmp	w8, #1
	b.gt	LBB76_257
	cbz	w8, LBB76_248
	cmp	w8, #1
	b.ne	LBB76_266
	mov	w23, #18
	b	LBB76_267
LBB76_244:
	cmp	w8, #22
	b.gt	LBB76_260
	cmp	w8, #13
	b.eq	LBB76_263
	cmp	w8, #19
	b.ne	LBB76_266
	mov	w23, #21
	b	LBB76_267
LBB76_248:
	ldr	x8, [sp, #80]
	str	x8, [sp, #200]
	add	x0, sp, #200
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #0
	mov	w9, #1
	casa	w8, w9, [x27]
	cmp	w8, #0
	b.ne	LBB76_337
LBB76_249:
	ldr	w8, [x20, #848]
	cmn	w8, #1
	b.eq	LBB76_272
	mov	x0, x23
	bl	_close$NOCANCEL
	cmn	w0, #1
	ldr	w8, [sp, #140]
	and	w27, w8, #0x7
	b.ne	LBB76_253
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB76_505
	cmp	w8, #16, lsl #12
	b.hs	LBB76_505
LBB76_253:
	ldr	w9, [x20, #848]
	add	x8, x20, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB76_335
	cmp	w8, #1
	b.eq	LBB76_273
	cmp	w8, #2
	b.ne	LBB76_84
	str	w9, [sp, #40]
	add	x0, x20, #836
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB76_274
LBB76_257:
	cmp	w8, #2
	b.eq	LBB76_264
	cmp	w8, #12
	b.ne	LBB76_266
	mov	w23, #4
	b	LBB76_267
LBB76_260:
	cmp	w8, #23
	b.eq	LBB76_265
	cmp	w8, #24
	b.ne	LBB76_266
	mov	w23, #23
	b	LBB76_267
LBB76_263:
	mov	w23, #10
	b	LBB76_267
LBB76_264:
	mov	w23, #39
	b	LBB76_267
LBB76_265:
	mov	w23, #24
	b	LBB76_267
LBB76_266:
	mov	w23, #12
LBB76_267:
	ldr	x8, [sp, #80]
	str	x8, [sp, #216]
	add	x0, sp, #216
	bl	l_Io.Threaded.Syscall.finish
LBB76_268:
	ldr	w8, [sp, #112]
	cmp	w8, #3
	ldr	x8, [sp, #64]
	b.ne	LBB76_285
LBB76_269:
	ldr	w0, [x8]
	ldr	x8, [sp, #72]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	ldr	w20, [sp, #48]
	ldr	x19, [sp, #120]
	b.eq	LBB76_286
LBB76_270:
	cmp	w20, #3
	b.ne	LBB76_287
LBB76_271:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_288
	b	LBB76_505
LBB76_272:
	str	w23, [sp, #40]
	str	w23, [x20, #848]
	add	x0, x20, #836
	bl	l_Io.Threaded.mutexUnlock
	ldr	w8, [sp, #140]
	and	w27, w8, #0x7
	b	LBB76_274
LBB76_273:
	str	w9, [sp, #40]
LBB76_274:
	ldp	x10, x23, [sp, #64]
	mov	x11, x19
	b	LBB76_22
LBB76_275:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_183
LBB76_276:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_184
LBB76_277:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_278:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh416:
	adrp	x8, l___anon_7632@PAGE
Lloh417:
	add	x8, x8, l___anon_7632@PAGEOFF
LBB76_282:
	ldp	q0, q1, [x8]
	ldr	x9, [sp, #120]
	stp	q0, q1, [x9]
	ldr	q0, [x8, #32]
	str	q0, [x9, #32]
	b	LBB76_174
LBB76_283:
Lloh418:
	adrp	x3, l___anon_2803@PAGE
Lloh419:
	add	x3, x3, l___anon_2803@PAGEOFF
	add	x0, x20, #836
	mov	w1, #2
	mov	w2, #0
	bl	l_Io.Threaded.Thread.futexWaitInner
	tst	w0, #0xffff
	b.eq	LBB76_195
	mov	x23, x0
	ldr	w8, [sp, #112]
	cmp	w8, #3
	ldr	x8, [sp, #64]
	b.eq	LBB76_269
LBB76_285:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	ldr	w20, [sp, #48]
	ldr	x19, [sp, #120]
	b.ne	LBB76_270
LBB76_286:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	cmp	w20, #3
	b.eq	LBB76_271
LBB76_287:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_288:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	strh	w23, [x19, #44]
	b	LBB76_174
Ltmp2:
LBB76_292:
	ldr	x25, [x24, #8]
	ldr	w1, [x24, #16]
	cmn	w1, #2
	b.eq	LBB76_295
	cbz	x25, LBB76_351
	ldrb	w8, [x23]
	cmp	w8, #47
	b.ne	LBB76_351
LBB76_295:
	sub	x0, x29, #136
	add	x3, sp, #1320
	mov	x1, x23
	mov	x2, x25
	bl	l_Io.Threaded.pathToPosix
	ldurh	w23, [x29, #-120]
	cbnz	w23, LBB76_476
	ldur	x27, [x29, #-136]
	b	LBB76_359
Ltmp3:
LBB76_297:
	cmn	w23, #2
	b.eq	LBB76_359
	cbz	x25, LBB76_300
	ldrb	w8, [x27]
	cmp	w8, #47
	b.eq	LBB76_359
LBB76_300:
	sub	x0, x29, #184
	add	x2, sp, #1320
	mov	x1, x23
	mov	w3, #1024
	bl	l_Io.Threaded.realPathPosix
	ldurh	w23, [x29, #-176]
	cbnz	w23, LBB76_475
	ldur	x0, [x29, #-184]
	cmp	x0, #1024
	b.hs	LBB76_510
	add	x8, sp, #1320
	mov	w9, #47
	strb	w9, [x8, x0]
	add	x9, x0, #1
	add	x24, x9, x25
	cmp	x24, #1025
	b.hs	LBB76_508
	add	x0, x8, x9
	add	x8, x27, x25
	cmp	x0, x8
	b.hs	LBB76_305
	add	x8, x0, x25
	cmp	x27, x8
	b.lo	LBB76_507
LBB76_305:
	mov	x1, x27
	b	LBB76_357
Ltmp4:
LBB76_306:
	sub	x0, x29, #168
	add	x2, sp, #1320
	mov	x1, x23
	mov	w3, #1024
	bl	l_Io.Threaded.realPathPosix
	ldurh	w23, [x29, #-160]
	cbnz	w23, LBB76_475
	ldur	x0, [x29, #-168]
	cmp	x0, #1024
	b.hs	LBB76_510
	add	x8, sp, #1320
	add	x27, sp, #1320
	strb	wzr, [x8, x0]
	b	LBB76_359
LBB76_309:
	mov	w8, #10
LBB76_310:
	str	w8, [sp, #136]
	sub	x0, x29, #216
	bl	"l_mem.TokenIterator(u8,.scalar).next"
	mov	x8, x0
	mov	x24, x1
	cbz	x0, LBB76_340
LBB76_311:
	adds	x9, x24, x25
	b.hs	LBB76_506
	adds	x23, x9, #1
	b.hs	LBB76_506
	adds	x9, x23, #1
	b.hs	LBB76_506
	cmp	x9, #1025
	b.hs	LBB76_385
	cmp	x24, #1025
	b.hs	LBB76_508
	add	x9, x8, x24
	add	x10, sp, #2360
	cmp	x10, x9
	b.hs	LBB76_318
	add	x9, sp, #2360
	add	x9, x9, x24
	cmp	x8, x9
	b.lo	LBB76_507
LBB76_318:
	add	x0, sp, #2360
	mov	x1, x8
	mov	x2, x24
	bl	_memcpy
	cmp	x24, #1024
	b.eq	LBB76_509
	add	x8, sp, #2360
	mov	w9, #47
	strb	w9, [x8, x24]
	add	x8, x24, #1
	add	x0, x8, x25
	cmp	x0, #1025
	b.hs	LBB76_510
	add	x9, sp, #2360
	add	x0, x9, x8
	add	x8, x27, x25
	cmp	x0, x8
	b.hs	LBB76_322
	add	x8, x0, x25
	cmp	x27, x8
	b.lo	LBB76_507
LBB76_322:
	mov	x1, x27
	mov	x2, x25
	bl	_memcpy
	cmp	x23, #1024
	b.hs	LBB76_511
	add	x8, sp, #2360
	strb	wzr, [x8, x23]
	tbnz	w28, #0, LBB76_325
	add	x8, sp, #2360
	str	x8, [x22]
LBB76_325:
	add	x0, sp, #196
	add	x1, sp, #2360
	add	x2, sp, #176
	add	x3, sp, #184
	mov	x4, x22
	mov	x5, x21
	bl	_posix_spawn
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	cmp	w0, #20
	b.hi	LBB76_361
	mov	w8, #1
	lsl	w8, w8, w0
	mov	w9, #8196
	movk	w9, #16, lsl #16
	tst	w8, w9
	b.eq	LBB76_361
	ldr	w8, [sp, #136]
	cmp	w8, #10
	b.eq	LBB76_310
	cmp	w0, #20
	b.eq	LBB76_334
	cmp	w0, #13
	b.eq	LBB76_309
	cmp	w0, #2
	b.ne	LBB76_335
	mov	w8, #39
	b	LBB76_310
LBB76_334:
	mov	w8, #40
	b	LBB76_310
LBB76_335:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB76_336:
	bl	___stack_chk_fail
LBB76_337:
	cmp	w8, #2
	b.ne	LBB76_515
Lloh420:
	adrp	x2, l___anon_2803@PAGE
Lloh421:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x20, #836
	mov	w1, #2
	b	LBB76_514
LBB76_339:
	mov	w8, #39
	str	w8, [sp, #136]
LBB76_340:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_344
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_345
LBB76_342:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_346
LBB76_343:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_347
	b	LBB76_505
LBB76_344:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_342
LBB76_345:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_343
LBB76_346:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_347:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	ldr	x8, [sp, #120]
	ldr	w9, [sp, #136]
	strh	w9, [x8, #44]
	b	LBB76_174
LBB76_351:
	sub	x0, x29, #152
	add	x2, sp, #1320
	mov	w3, #1024
	bl	l_Io.Threaded.realPathPosix
	ldurh	w24, [x29, #-144]
	cbnz	w24, LBB76_482
	ldur	x0, [x29, #-152]
	cmp	x0, #1024
	b.hs	LBB76_510
	add	x8, sp, #1320
	mov	w9, #47
	strb	w9, [x8, x0]
	add	x9, x0, #1
	add	x24, x9, x25
	cmp	x24, #1025
	b.hs	LBB76_508
	add	x0, x8, x9
	add	x8, x23, x25
	cmp	x0, x8
	b.hs	LBB76_356
	add	x8, x0, x25
	cmp	x8, x23
	b.hi	LBB76_507
LBB76_356:
	mov	x1, x23
LBB76_357:
	mov	x2, x25
	bl	_memcpy
	cmp	x24, #1024
	b.eq	LBB76_509
	add	x8, sp, #1320
	add	x27, sp, #1320
	strb	wzr, [x8, x24]
LBB76_359:
	add	x0, sp, #196
	add	x2, sp, #176
	add	x3, sp, #184
	mov	x1, x27
	mov	x4, x22
	mov	x5, x21
	bl	_posix_spawn
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
LBB76_361:
	cmp	w0, #86
	b.hi	LBB76_363
	mov	w8, w0
Lloh422:
	adrp	x9, LJTI76_0@PAGE
Lloh423:
	add	x9, x9, LJTI76_0@PAGEOFF
	adr	x10, LBB76_363
	ldrh	w11, [x9, x8, lsl #1]
	add	x10, x10, x11, lsl #2
	br	x10
LBB76_363:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_367
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_368
LBB76_365:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_369
LBB76_366:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_370
	b	LBB76_505
LBB76_367:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_365
LBB76_368:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_366
LBB76_369:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_370:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	mov	w8, #12
	ldr	x9, [sp, #120]
	strh	w8, [x9, #44]
	b	LBB76_174
LBB76_374:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_378
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_379
LBB76_376:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_380
LBB76_377:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_381
	b	LBB76_505
LBB76_378:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_376
LBB76_379:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_377
LBB76_380:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_381:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh424:
	adrp	x8, l___anon_7447@PAGE
Lloh425:
	add	x8, x8, l___anon_7447@PAGEOFF
	b	LBB76_282
LBB76_385:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_389
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_390
LBB76_387:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_391
LBB76_388:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_392
	b	LBB76_505
LBB76_389:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_387
LBB76_390:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_388
LBB76_391:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_392:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh426:
	adrp	x8, l___anon_7603@PAGE
Lloh427:
	add	x8, x8, l___anon_7603@PAGEOFF
	b	LBB76_282
LBB76_396:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_400
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_401
LBB76_398:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_402
LBB76_399:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_403
	b	LBB76_505
LBB76_400:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_398
LBB76_401:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_399
LBB76_402:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_403:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh428:
	adrp	x8, l___anon_7751@PAGE
Lloh429:
	add	x8, x8, l___anon_7751@PAGEOFF
	b	LBB76_282
LBB76_407:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_411
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_412
LBB76_409:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_413
LBB76_410:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_414
	b	LBB76_505
LBB76_411:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_409
LBB76_412:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_410
LBB76_413:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_414:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh430:
	adrp	x8, l___anon_7747@PAGE
Lloh431:
	add	x8, x8, l___anon_7747@PAGEOFF
	b	LBB76_282
LBB76_418:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_422
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_423
LBB76_420:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_424
LBB76_421:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_425
	b	LBB76_505
LBB76_422:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_420
LBB76_423:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_421
LBB76_424:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_425:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh432:
	adrp	x8, l___anon_7753@PAGE
Lloh433:
	add	x8, x8, l___anon_7753@PAGEOFF
	b	LBB76_282
LBB76_429:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_433
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_434
LBB76_431:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_435
LBB76_432:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_436
	b	LBB76_505
LBB76_433:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_431
LBB76_434:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_432
LBB76_435:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_436:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh434:
	adrp	x8, l___anon_7757@PAGE
Lloh435:
	add	x8, x8, l___anon_7757@PAGEOFF
	b	LBB76_282
LBB76_440:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_444
	ldr	w0, [sp, #36]
	bl	l_Io.Threaded.closeFd
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_445
LBB76_442:
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_446
LBB76_443:
	ldr	w0, [sp, #32]
	bl	l_Io.Threaded.closeFd
	ldr	w8, [sp, #52]
	cmn	w8, #1
	b.ne	LBB76_447
	b	LBB76_448
LBB76_444:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_442
LBB76_445:
	ldr	w0, [sp, #44]
	bl	l_Io.Threaded.closeFd
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.eq	LBB76_443
LBB76_446:
	ldr	w8, [sp, #52]
	cmn	w8, #1
	b.eq	LBB76_448
LBB76_447:
	ldr	w0, [sp, #52]
	bl	l_Io.Threaded.closeFd
LBB76_448:
	ldr	w8, [sp, #80]
	mov	w8, w8
	orr	x2, x8, #0x100000000
	ldr	w0, [sp, #56]
	mov	x1, x20
	bl	l_Progress.Node.setIpcFile
	ldr	x10, [sp, #120]
	strh	wzr, [x10, #44]
	ldr	w8, [sp, #196]
	mov	w9, #-1
	stp	w8, w9, [x10]
	cmp	w26, #3
	b.ne	LBB76_461
	mov	w8, #1
	ldr	x9, [sp, #120]
	strb	w8, [x9, #16]
	ldr	w8, [sp, #28]
	str	w8, [x9, #8]
	strb	wzr, [x9, #12]
	b	LBB76_463
LBB76_450:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_454
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_455
LBB76_452:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_456
LBB76_453:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_457
	b	LBB76_505
LBB76_454:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_452
LBB76_455:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_453
LBB76_456:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_457:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh436:
	adrp	x8, l___anon_7743@PAGE
Lloh437:
	add	x8, x8, l___anon_7743@PAGEOFF
	b	LBB76_282
LBB76_461:
	cmp	w26, #4
	b.hi	LBB76_84
	ldr	x8, [sp, #120]
	stur	wzr, [x8, #16]
	stur	xzr, [x8, #8]
LBB76_463:
	ldr	w8, [sp, #140]
	cmp	w8, #3
	b.ne	LBB76_465
	mov	w8, #1
	ldr	x9, [sp, #120]
	strb	w8, [x9, #28]
	ldr	w8, [sp, #24]
	str	w8, [x9, #20]
	strb	wzr, [x9, #24]
	b	LBB76_467
LBB76_465:
	ldr	w8, [sp, #140]
	cmp	w8, #4
	b.hi	LBB76_84
	ldr	x8, [sp, #120]
	stur	wzr, [x8, #28]
	stur	xzr, [x8, #20]
LBB76_467:
	cmp	w19, #3
	b.ne	LBB76_469
	mov	w8, #1
	ldr	x9, [sp, #120]
	strb	w8, [x9, #40]
	ldr	w8, [sp, #20]
	str	w8, [x9, #32]
	strb	wzr, [x9, #36]
	b	LBB76_471
LBB76_469:
	cmp	w19, #4
	b.hi	LBB76_84
	ldr	x8, [sp, #120]
	stur	wzr, [x8, #40]
	stur	xzr, [x8, #32]
LBB76_471:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.lo	LBB76_174
	b	LBB76_505
LBB76_475:
	cmp	w23, #3
	b.eq	LBB76_483
LBB76_476:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_479
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_480
LBB76_478:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_189
	b	LBB76_481
LBB76_479:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_478
LBB76_480:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_189
LBB76_481:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_190
	b	LBB76_505
LBB76_482:
	cmp	w24, #3
	b.ne	LBB76_494
LBB76_483:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_487
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_488
LBB76_485:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_489
LBB76_486:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_490
	b	LBB76_505
LBB76_487:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_485
LBB76_488:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_486
LBB76_489:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_490:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
Lloh438:
	adrp	x8, l___anon_7732@PAGE
Lloh439:
	add	x8, x8, l___anon_7732@PAGEOFF
	b	LBB76_282
LBB76_494:
	ldr	w0, [sp, #80]
	ldr	w1, [sp, #52]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #112]
	cmp	w8, #3
	b.ne	LBB76_498
	ldp	x9, x8, [sp, #64]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.eq	LBB76_499
LBB76_496:
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.ne	LBB76_500
LBB76_497:
	ldp	x9, x8, [sp, #96]
	ldr	w0, [x9]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbz	w0, #31, LBB76_501
	b	LBB76_505
LBB76_498:
	ldr	w8, [sp, #116]
	cmp	w8, #3
	b.ne	LBB76_496
LBB76_499:
	ldr	x8, [sp, #88]
	ldr	w0, [x8]
	ldr	x8, [sp, #128]
	ldr	w1, [x8]
	bl	l_Io.Threaded.destroyPipe
	ldr	w8, [sp, #48]
	cmp	w8, #3
	b.eq	LBB76_497
LBB76_500:
	add	x0, sp, #184
	bl	_posix_spawnattr_destroy
	tbnz	w0, #31, LBB76_505
LBB76_501:
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	add	x0, sp, #176
	bl	_posix_spawn_file_actions_destroy
	tbnz	w0, #31, LBB76_505
	cmp	w0, #16, lsl #12
	b.hs	LBB76_505
	ldr	x8, [sp, #120]
	strh	w24, [x8, #44]
	b	LBB76_174
LBB76_505:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB76_506:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB76_507:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB76_508:
	mov	x0, x24
	mov	w1, #1024
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB76_509:
	mov	w0, #1024
LBB76_510:
	mov	w1, #1024
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB76_511:
	mov	x0, x23
	mov	w1, #1024
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB76_512:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB76_513:
	add	x0, x20, #836
	mov	w1, #2
Lloh440:
	adrp	x2, l___anon_2803@PAGE
Lloh441:
	add	x2, x2, l___anon_2803@PAGEOFF
LBB76_514:
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
LBB76_515:
	mov	w8, #2
	swpa	w8, w8, [x27]
	cbnz	w8, LBB76_513
	b	LBB76_249
	.loh AdrpLdrGotLdr	Lloh398, Lloh399, Lloh400
	.loh AdrpAdd	Lloh401, Lloh402
	.loh AdrpAdd	Lloh403, Lloh404
	.loh AdrpAdd	Lloh405, Lloh406
	.loh AdrpLdrGotLdr	Lloh407, Lloh408, Lloh409
	.loh AdrpAdd	Lloh410, Lloh411
	.loh AdrpAdd	Lloh412, Lloh413
	.loh AdrpAdd	Lloh414, Lloh415
	.loh AdrpAdd	Lloh416, Lloh417
	.loh AdrpAdd	Lloh418, Lloh419
	.loh AdrpAdd	Lloh420, Lloh421
	.loh AdrpAdd	Lloh422, Lloh423
	.loh AdrpAdd	Lloh424, Lloh425
	.loh AdrpAdd	Lloh426, Lloh427
	.loh AdrpAdd	Lloh428, Lloh429
	.loh AdrpAdd	Lloh430, Lloh431
	.loh AdrpAdd	Lloh432, Lloh433
	.loh AdrpAdd	Lloh434, Lloh435
	.loh AdrpAdd	Lloh436, Lloh437
	.loh AdrpAdd	Lloh438, Lloh439
	.loh AdrpAdd	Lloh440, Lloh441
	.cfi_endproc
	.section	__TEXT,__const
	.p2align	1, 0x0
LJTI76_0:
	.short	(LBB76_440-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_483-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_407-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_374-LBB76_363)>>2
	.short	(LBB76_396-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_374-LBB76_363)>>2
	.short	(LBB76_450-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_418-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_429-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_374-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_407-LBB76_363)>>2
	.short	(LBB76_385-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_363-LBB76_363)>>2
	.short	(LBB76_396-LBB76_363)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Progress.Node.setIpcFile:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	w8, #255
Lloh442:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh443:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh444:
	ldr	x9, [x9]
	str	x9, [sp, #8]
	str	x9, [sp, #24]
	bics	wzr, w8, w0
	b.eq	LBB77_10
	mov	x19, x0
Lloh445:
	adrp	x20, l_Progress.global_progress@PAGE
Lloh446:
	add	x20, x20, l_Progress.global_progress@PAGEOFF
	ldr	x0, [x20]
	cmp	x0, x1
	b.ne	LBB77_13
	ldr	x8, [x20, #8]
	mov	x9, #-128
	mov	w10, #18149
	add	x11, x20, x10
	mov	w12, #1
	mov	w13, #16348
	b	LBB77_4
LBB77_3:
	adds	x9, x9, #1
	b.hs	LBB77_8
LBB77_4:
	ldaddb	w12, w10, [x11]
	and	w10, w10, #0x7f
	add	x14, x20, w10, uxtw #2
	ldr	w15, [x14, #16348]
	tst	w15, #0x3
	b.ne	LBB77_3
	and	w14, w15, #0xffffff80
	add	w16, w14, #130
	add	x17, x20, x10, lsl #2
	add	x17, x17, x13
	mov	x1, x15
	casa	w1, w16, [x17]
	cmp	w1, w15
	b.ne	LBB77_3
	add	x8, x20, x10, lsl #3
	mov	w9, #16860
	str	x2, [x8, x9]
	and	x0, x19, #0xff
	and	w8, w19, #0xff
	cmp	w8, #127
	b.hs	LBB77_14
	add	w8, w14, #128
	add	x9, x20, x0, lsl #7
	orr	w8, w8, w10
	str	w8, [x9, #72]
	mov	w8, #-1
	stlur	w8, [x9, #76]
	b	LBB77_10
LBB77_8:
	ldr	x8, [x8, #376]
	str	x2, [sp, #16]
	add	x1, sp, #16
	mov	w2, #1
	blr	x8
	and	x0, x19, #0xff
	and	w8, w19, #0xff
	cmp	w8, #127
	b.hs	LBB77_14
	add	x8, x20, x0, lsl #7
	str	wzr, [x8, #72]
	str	wzr, [x8, #76]
LBB77_10:
	ldr	x8, [sp, #24]
Lloh447:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh448:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh449:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB77_12
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB77_12:
	.cfi_restore_state
	bl	___stack_chk_fail
LBB77_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB77_14:
	mov	w1, #127
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh442, Lloh443, Lloh444
	.loh AdrpAdd	Lloh445, Lloh446
	.loh AdrpLdrGotLdr	Lloh447, Lloh448, Lloh449
	.cfi_endproc

	.p2align	2
l_Io.Threaded.realPathPosix:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	sub	sp, sp, #1120
	mov	x20, x3
	mov	x19, x0
Lloh450:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh451:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh452:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-72]
	cmn	w1, #2
	b.ne	LBB78_3
	add	x0, sp, #40
	mov	x1, x2
	mov	x2, x20
	bl	l_Io.Threaded.processCurrentPathPosix
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB78_31
	ldr	x8, [sp, #40]
	str	x8, [x19]
	b	LBB78_18
LBB78_3:
	mov	x21, x1
	mov	x22, x2
	add	x23, sp, #56
	add	x0, sp, #56
	mov	w1, #1024
	bl	_bzero
	sub	x0, x29, #104
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-96]
	cbnz	w8, LBB78_10
	ldur	x24, [x29, #-104]
LBB78_5:
	str	x23, [sp]
	mov	x0, x21
	mov	w1, #50
	bl	_fcntl
	cmn	w0, #1
	b.ne	LBB78_12
	bl	___error
	ldr	w25, [x0]
	tbnz	w25, #31, LBB78_34
	cmp	w25, #16, lsl #12
	b.hs	LBB78_34
	cmp	w25, #4
	b.ne	LBB78_11
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB78_5
LBB78_10:
	strh	w8, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh453:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh454:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh455:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB78_19
	b	LBB78_29
LBB78_11:
	cbnz	w25, LBB78_20
LBB78_12:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w21, #1024
	sub	x0, x29, #88
	add	x1, sp, #56
	mov	w2, #1024
	mov	w3, #0
	bl	l_mem.findScalar__func_124
	ldurb	w8, [x29, #-80]
	ldur	x9, [x29, #-88]
	tst	w8, #0x1
	csel	x21, x9, x21, ne
	cmp	x21, x20
	b.ls	LBB78_15
LBB78_13:
Lloh456:
	adrp	x8, l___anon_10273@PAGE
Lloh457:
	add	x8, x8, l___anon_10273@PAGEOFF
LBB78_14:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-72]
Lloh458:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh459:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh460:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB78_19
	b	LBB78_29
LBB78_15:
	cmp	x21, #1025
	b.hs	LBB78_35
	add	x8, sp, #56
	add	x9, x22, x21
	cmp	x8, x9
	cset	w9, hs
	add	x8, x8, x21
	cmp	x22, x8
	ccmp	w9, #0, #0, lo
	b.eq	LBB78_36
	mov	x0, x22
	add	x1, sp, #56
	mov	x2, x21
	bl	_memcpy
	str	x21, [x19]
LBB78_18:
	strh	wzr, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh461:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh462:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh463:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB78_29
LBB78_19:
	add	sp, sp, #1120
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB78_20:
	.cfi_restore_state
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w25, #12
	b.gt	LBB78_25
	cmp	w25, #2
	b.eq	LBB78_33
	cmp	w25, #9
	b.eq	LBB78_33
	cmp	w25, #12
	b.ne	LBB78_28
Lloh464:
	adrp	x8, l___anon_10325@PAGE
Lloh465:
	add	x8, x8, l___anon_10325@PAGEOFF
	b	LBB78_14
LBB78_25:
	cmp	w25, #13
	b.eq	LBB78_30
	cmp	w25, #28
	b.eq	LBB78_13
	cmp	w25, #34
	b.eq	LBB78_13
LBB78_28:
	mov	w8, #12
	strh	w8, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh466:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh467:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh468:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB78_19
LBB78_29:
	bl	___stack_chk_fail
LBB78_30:
Lloh469:
	adrp	x8, l___anon_10280@PAGE
Lloh470:
	add	x8, x8, l___anon_10280@PAGEOFF
	b	LBB78_14
LBB78_31:
	cmp	w8, #66
	b.eq	LBB78_33
	cmp	w8, #67
	b.eq	LBB78_13
	b	LBB78_10
LBB78_33:
Lloh471:
	adrp	x8, l___anon_10282@PAGE
Lloh472:
	add	x8, x8, l___anon_10282@PAGEOFF
	b	LBB78_14
LBB78_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB78_35:
	mov	x0, x21
	mov	w1, #1024
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB78_36:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpLdrGotLdr	Lloh450, Lloh451, Lloh452
	.loh AdrpLdrGotLdr	Lloh453, Lloh454, Lloh455
	.loh AdrpAdd	Lloh456, Lloh457
	.loh AdrpLdrGotLdr	Lloh458, Lloh459, Lloh460
	.loh AdrpLdrGotLdr	Lloh461, Lloh462, Lloh463
	.loh AdrpAdd	Lloh464, Lloh465
	.loh AdrpLdrGotLdr	Lloh466, Lloh467, Lloh468
	.loh AdrpAdd	Lloh469, Lloh470
	.loh AdrpAdd	Lloh471, Lloh472
	.cfi_endproc

	.p2align	2
l_Io.Threaded.processCurrentPathPosix:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x20, x2
	mov	x21, x1
	mov	x19, x0
Lloh473:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh474:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh475:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	mov	x0, x1
	mov	x1, x2
	bl	_getcwd
	cbz	x0, LBB79_5
LBB79_1:
	add	x0, sp, #8
	mov	x1, x21
	mov	x2, x20
	mov	w3, #0
	bl	l_mem.findScalar__func_124
	ldrb	w8, [sp, #16]
	tbz	w8, #0, LBB79_23
	ldr	x8, [sp, #8]
	str	x8, [x19]
	strh	wzr, [x19, #8]
	ldr	x8, [sp, #24]
Lloh476:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh477:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh478:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB79_21
LBB79_3:
	.cfi_def_cfa wsp, 80
LBB79_4:
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB79_5:
	.cfi_restore_state
	.cfi_remember_state
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB79_22
	cmp	w8, #16, lsl #12
	b.hs	LBB79_22
	cmp	w8, #21
	b.gt	LBB79_11
	cbz	w8, LBB79_1
	cmp	w8, #2
	b.eq	LBB79_17
	cmp	w8, #14
	b	LBB79_16
LBB79_11:
	cmp	w8, #22
	b.eq	LBB79_16
	cmp	w8, #34
	b.eq	LBB79_19
	cmp	w8, #63
	b.ne	LBB79_16
Lloh479:
	adrp	x8, l___anon_7839@PAGE
Lloh480:
	add	x8, x8, l___anon_7839@PAGEOFF
Lloh481:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh482:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh483:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh484:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB79_21
	.cfi_def_cfa wsp, 80
	b	LBB79_4
LBB79_16:
	.cfi_restore_state
	.cfi_remember_state
	mov	w8, #12
	strh	w8, [x19, #8]
	ldr	x8, [sp, #24]
Lloh485:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh486:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh487:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB79_3
	b	LBB79_21
LBB79_17:
Lloh488:
	adrp	x8, l___anon_7836@PAGE
Lloh489:
	add	x8, x8, l___anon_7836@PAGEOFF
Lloh490:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh491:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh492:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh493:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB79_21
	.cfi_def_cfa wsp, 80
	b	LBB79_4
LBB79_19:
	.cfi_restore_state
	.cfi_remember_state
Lloh494:
	adrp	x8, l___anon_10273@PAGE
Lloh495:
	add	x8, x8, l___anon_10273@PAGEOFF
Lloh496:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh497:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh498:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh499:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB79_21
	.cfi_def_cfa wsp, 80
	b	LBB79_4
LBB79_21:
	.cfi_restore_state
	bl	___stack_chk_fail
LBB79_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB79_23:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
	.loh AdrpLdrGotLdr	Lloh473, Lloh474, Lloh475
	.loh AdrpLdrGotLdr	Lloh476, Lloh477, Lloh478
	.loh AdrpLdrGotLdr	Lloh482, Lloh483, Lloh484
	.loh AdrpAddLdr	Lloh479, Lloh480, Lloh481
	.loh AdrpLdrGotLdr	Lloh485, Lloh486, Lloh487
	.loh AdrpLdrGotLdr	Lloh491, Lloh492, Lloh493
	.loh AdrpAddLdr	Lloh488, Lloh489, Lloh490
	.loh AdrpLdrGotLdr	Lloh497, Lloh498, Lloh499
	.loh AdrpAddLdr	Lloh494, Lloh495, Lloh496
	.cfi_endproc

	.p2align	2
"l_mem.TokenIterator(u8,.scalar).next":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	ldp	x1, x8, [x0, #8]
	cmp	x8, x1
	b.hs	LBB80_4
	ldr	x9, [x0]
	ldrb	w10, [x0, #24]
LBB80_2:
	ldrb	w11, [x9, x8]
	cmp	w11, w10
	b.ne	LBB80_4
	add	x8, x8, #1
	str	x8, [x0, #16]
	cmp	x1, x8
	b.ne	LBB80_2
	b	LBB80_5
LBB80_4:
	cmp	x8, x1
	b.ne	LBB80_8
LBB80_5:
	mov	x10, #0
	mov	x9, #0
	cbz	x10, LBB80_16
LBB80_6:
	adds	x8, x1, x9
	b.hs	LBB80_18
	str	x8, [x0, #16]
	b	LBB80_17
LBB80_8:
	ldr	x10, [x0]
	mov	x9, x8
	b.hs	LBB80_14
	ldrb	w11, [x0, #24]
	mov	x9, x8
LBB80_10:
	ldrb	w12, [x10, x9]
	cmp	w12, w11
	b.eq	LBB80_13
	add	x9, x9, #1
	cmp	x1, x9
	b.ne	LBB80_10
	mov	x9, x1
LBB80_13:
	cmp	x9, x8
	b.lo	LBB80_20
LBB80_14:
	cmp	x9, x1
	b.hi	LBB80_19
	add	x10, x10, x8
	sub	x9, x9, x8
	mov	x1, x8
	cbnz	x10, LBB80_6
LBB80_16:
	mov	x9, #0
LBB80_17:
	mov	x0, x10
	mov	x1, x9
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB80_18:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB80_19:
	mov	x0, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB80_20:
	mov	x0, x8
	mov	x1, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI81_0:
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
lCPI81_1:
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
l_mem.findScalar__func_124:
	.cfi_startproc
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
Lloh500:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh501:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh502:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-8]
	cbz	x2, LBB81_27
	cmp	x2, #32
	b.ls	LBB81_12
	mov	x8, #0
	dup.16b	v0, w3
LBB81_3:
	add	x9, x8, #16
	cmp	x9, x2
	b.hi	LBB81_32
	ldr	q1, [x1, x8]
	cmeq.16b	v1, v1, v0
	umaxv.16b	b2, v1
	fmov	w9, s2
	tbnz	w9, #0, LBB81_17
	add	x9, x8, #32
	cmp	x9, x2
	b.hi	LBB81_32
	add	x9, x1, x8
	ldr	q1, [x9, #16]
	cmeq.16b	v1, v1, v0
	umaxv.16b	b2, v1
	fmov	w9, s2
	tbnz	w9, #0, LBB81_18
	adds	x9, x8, #64
	b.hs	LBB81_33
	add	x8, x8, #32
	cmp	x9, x2
	b.lo	LBB81_3
	add	x9, x8, #16
	cmp	x9, x2
	b.hs	LBB81_13
LBB81_10:
	dup.16b	v0, w3
	ldr	q1, [x1, x8]
	cmeq.16b	v0, v1, v0
	umaxv.16b	b1, v0
	fmov	w10, s1
	tbz	w10, #0, LBB81_20
Lloh503:
	adrp	x9, lCPI81_0@PAGE
Lloh504:
	ldr	q1, [x9, lCPI81_0@PAGEOFF]
	movi.16b	v2, #15
	bsl.16b	v0, v1, v2
	uminv.16b	b0, v0
	fmov	w9, s0
	and	x9, x9, #0xf
	b	LBB81_16
LBB81_12:
	mov	x8, #0
	add	x9, x8, #16
	cmp	x9, x2
	b.lo	LBB81_10
LBB81_13:
	add	x9, x8, #8
	cmp	x9, x2
	b.hs	LBB81_21
LBB81_14:
	dup.8b	v0, w3
	ldr	d1, [x1, x8]
	cmeq.8b	v0, v1, v0
	umaxv.8b	b1, v0
	fmov	w10, s1
	tbz	w10, #0, LBB81_30
Lloh505:
	adrp	x9, lCPI81_1@PAGE
Lloh506:
	ldr	d1, [x9, lCPI81_1@PAGEOFF]
	movi.8b	v2, #7
	bsl.8b	v0, v1, v2
	uminv.8b	b0, v0
	fmov	w9, s0
	and	x9, x9, #0x7
LBB81_16:
	add	x9, x8, x9
	b	LBB81_19
LBB81_17:
Lloh507:
	adrp	x9, lCPI81_0@PAGE
Lloh508:
	ldr	q0, [x9, lCPI81_0@PAGEOFF]
	movi.16b	v2, #15
	bif.16b	v0, v2, v1
	uminv.16b	b0, v0
	fmov	w9, s0
	and	x9, x9, #0xf
	add	x9, x9, x8
	b	LBB81_19
LBB81_18:
Lloh509:
	adrp	x9, lCPI81_0@PAGE
Lloh510:
	ldr	q0, [x9, lCPI81_0@PAGEOFF]
	movi.16b	v2, #15
	bif.16b	v0, v2, v1
	uminv.16b	b0, v0
	fmov	w9, s0
	and	x9, x9, #0xf
	add	x8, x9, x8
	add	x9, x8, #16
LBB81_19:
	mov	w8, #1
	b	LBB81_28
LBB81_20:
	mov	x8, x9
	add	x9, x9, #8
	cmp	x9, x2
	b.lo	LBB81_14
LBB81_21:
	subs	x10, x2, x8
	b.lo	LBB81_31
LBB81_22:
	b.eq	LBB81_27
	mov	x11, #0
	add	x12, x1, x8
LBB81_24:
	adds	x9, x8, x11
	b.hs	LBB81_33
	ldrb	w13, [x12, x11]
	cmp	w13, w3, uxtb
	b.eq	LBB81_19
	add	x11, x11, #1
	cmp	x10, x11
	b.ne	LBB81_24
LBB81_27:
	mov	x9, #0
	mov	w8, #0
	stur	wzr, [sp, #19]
	str	wzr, [sp, #16]
LBB81_28:
	str	x9, [x0]
	strb	w8, [x0, #8]
	ldr	w8, [sp, #16]
	stur	w8, [x0, #9]
	ldur	w8, [sp, #19]
	str	w8, [x0, #12]
	ldur	x8, [x29, #-8]
Lloh511:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh512:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh513:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB81_34
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	add	sp, sp, #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB81_30:
	.cfi_restore_state
	mov	x8, x9
	subs	x10, x2, x9
	b.hs	LBB81_22
LBB81_31:
	mov	x0, x8
	mov	x1, x2
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB81_32:
	mov	x0, x9
	mov	x1, x2
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB81_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB81_34:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh500, Lloh501, Lloh502
	.loh AdrpLdr	Lloh503, Lloh504
	.loh AdrpLdr	Lloh505, Lloh506
	.loh AdrpLdr	Lloh507, Lloh508
	.loh AdrpLdr	Lloh509, Lloh510
	.loh AdrpLdrGotLdr	Lloh511, Lloh512, Lloh513
	.cfi_endproc

	.p2align	2
l_mem.span__func_123:
	.cfi_startproc
	ldrb	w8, [x0]
	cbz	w8, LBB82_5
	mov	x9, #0
	add	x8, x0, #1
LBB82_2:
	cmn	x9, #1
	b.eq	LBB82_6
	add	x1, x9, #1
	ldrb	w10, [x8, x9]
	mov	x9, x1
	cbnz	w10, LBB82_2
	ret
LBB82_5:
	mov	x1, #0
	ret
LBB82_6:
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.pathToPosix:
	.cfi_startproc
	stp	x22, x21, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x8, #0
	mov	x9, x2
LBB83_1:
	cmp	x9, #16
	b.lo	LBB83_7
	add	x9, x8, #16
	cmp	x9, x2
	b.hi	LBB83_20
	ldr	q0, [x1, x8]
	cmeq.16b	v0, v0, #0
	umaxv.16b	b0, v0
	fmov	w10, s0
	tbnz	w10, #0, LBB83_14
	cmn	x8, #16
	b.eq	LBB83_6
	mov	x8, x9
	subs	x9, x2, x9
	b.hs	LBB83_1
LBB83_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB83_7:
	subs	x9, x2, x8
	b.lo	LBB83_21
	b.eq	LBB83_12
	add	x8, x1, x8
LBB83_10:
	ldrb	w10, [x8], #1
	cbz	w10, LBB83_14
	subs	x9, x9, #1
	b.ne	LBB83_10
LBB83_12:
	cmp	x2, #1024
	b.lo	LBB83_17
Lloh514:
	adrp	x8, l___anon_7965@PAGE
Lloh515:
	add	x8, x8, l___anon_7965@PAGEOFF
Lloh516:
	ldr	q0, [x8]
	str	q0, [x0]
	mov	w8, #43
	b	LBB83_15
LBB83_14:
Lloh517:
	adrp	x8, l___anon_7963@PAGE
Lloh518:
	add	x8, x8, l___anon_7963@PAGEOFF
Lloh519:
	ldr	q0, [x8]
	str	q0, [x0]
	mov	w8, #44
LBB83_15:
	str	x8, [x0, #16]
	.cfi_def_cfa wsp, 48
LBB83_16:
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x22, x21, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB83_17:
	.cfi_restore_state
	.cfi_remember_state
	mov	x20, x0
	add	x8, x1, x2
	cmp	x3, x8
	b.hs	LBB83_19
	add	x8, x3, x2
	cmp	x1, x8
	b.lo	LBB83_22
LBB83_19:
	mov	x0, x3
	mov	x19, x2
	mov	x21, x3
	bl	_memcpy
	strb	wzr, [x21, x19]
	stp	x21, x19, [x20]
	strh	wzr, [x20, #16]
	.cfi_def_cfa wsp, 48
	b	LBB83_16
LBB83_20:
	.cfi_restore_state
	mov	x0, x9
	mov	x1, x2
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB83_21:
	mov	x0, x8
	mov	x1, x2
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB83_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpAddLdr	Lloh514, Lloh515, Lloh516
	.loh AdrpAddLdr	Lloh517, Lloh518, Lloh519
	.cfi_endproc

	.p2align	2
l_Io.Threaded.destroyPipe:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x1
	mov	x20, x0
	cmn	w0, #1
	b.eq	LBB84_4
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB84_4
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB84_9
	cmp	w8, #16, lsl #12
	b.hs	LBB84_9
LBB84_4:
	cmp	w20, w19
	b.eq	LBB84_8
	mov	x0, x19
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB84_8
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB84_9
	cmp	w8, #16, lsl #12
	b.hs	LBB84_9
LBB84_8:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB84_9:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.pipe2:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x20, x1
	mov	x19, x0
Lloh520:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh521:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh522:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	mov	x8, #-6148914691236517206
	str	x8, [sp, #16]
	add	x0, sp, #16
	bl	_pipe
	cmn	w0, #1
	b.eq	LBB85_7
LBB85_1:
	ldp	w0, w21, [sp, #16]
	mov	w8, #1
	str	x8, [sp]
	mov	w1, #2
	bl	_fcntl
	cmn	w0, #1
	b.eq	LBB85_13
LBB85_2:
	mov	w8, #1
	str	x8, [sp]
	mov	x0, x21
	mov	w1, #2
	bl	_fcntl
	cmn	w0, #1
	b.eq	LBB85_16
LBB85_3:
	ands	w21, w20, #0x7
	b.eq	LBB85_6
	ldp	w0, w20, [sp, #16]
	str	x21, [sp]
	mov	w1, #4
	bl	_fcntl
	cmn	w0, #1
	b.eq	LBB85_19
LBB85_5:
	str	x21, [sp]
	mov	x0, x20
	mov	w1, #4
	bl	_fcntl
	cmn	w0, #1
	b.eq	LBB85_34
LBB85_6:
	ldr	x8, [sp, #16]
	str	x8, [x19]
	strh	wzr, [x19, #8]
	ldr	x8, [sp, #24]
Lloh523:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh524:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh525:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB85_30
	b	LBB85_33
LBB85_7:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	cmp	w8, #16, lsl #12
	b.hs	LBB85_38
	cbz	w8, LBB85_1
	cmp	w8, #23
	b.eq	LBB85_31
	cmp	w8, #24
	b.ne	LBB85_29
	mov	w8, #23
	b	LBB85_32
LBB85_13:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	cmp	w8, #16, lsl #12
	b.hs	LBB85_38
	cbnz	w8, LBB85_23
	b	LBB85_2
LBB85_16:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	lsr	w9, w8, #16
	cbnz	w9, LBB85_38
	cbnz	w8, LBB85_23
	b	LBB85_3
LBB85_19:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	cmp	w8, #16, lsl #12
	b.hs	LBB85_38
	cmp	w8, #22
	b.eq	LBB85_23
	cbz	w8, LBB85_5
LBB85_23:
	ldr	w0, [sp, #16]
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB85_26
LBB85_24:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	cmp	w8, #16, lsl #12
	b.hs	LBB85_38
LBB85_26:
	ldr	w0, [sp, #20]
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB85_29
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	cmp	w8, #16, lsl #12
	b.hs	LBB85_38
LBB85_29:
	mov	w8, #12
	strh	w8, [x19, #8]
	ldr	x8, [sp, #24]
Lloh526:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh527:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh528:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB85_33
LBB85_30:
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB85_31:
	.cfi_restore_state
	mov	w8, #24
LBB85_32:
	str	w8, [x19, #8]
	str	xzr, [x19]
	ldr	x8, [sp, #24]
Lloh529:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh530:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh531:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB85_30
LBB85_33:
	bl	___stack_chk_fail
LBB85_34:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB85_38
	lsr	w9, w8, #16
	cbnz	w9, LBB85_38
	cbz	w8, LBB85_6
	cmp	w8, #22
	ldr	w0, [sp, #16]
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB85_26
	b	LBB85_24
LBB85_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.loh AdrpLdrGotLdr	Lloh520, Lloh521, Lloh522
	.loh AdrpLdrGotLdr	Lloh523, Lloh524, Lloh525
	.loh AdrpLdrGotLdr	Lloh526, Lloh527, Lloh528
	.loh AdrpLdrGotLdr	Lloh529, Lloh530, Lloh531
	.cfi_endproc

	.p2align	2
l_process.Environ.createPosixBlock:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x23, x30
	mov	x22, x4
	mov	x26, x3
	mov	x25, x2
	mov	x21, x0
	str	x1, [sp, #48]
	cbz	x2, LBB86_9
	mov	x24, x1
	mov	x20, #0
Lloh532:
	adrp	x19, l___anon_7054@PAGE
Lloh533:
	add	x19, x19, l___anon_7054@PAGEOFF
LBB86_2:
	mov	x1, #0
	ldr	x8, [x24, x20, lsl #3]
LBB86_3:
	ldrb	w9, [x8, x1]
	cbz	w9, LBB86_6
	cmp	w9, #61
	b.eq	LBB86_6
	adds	x1, x1, #1
	b.lo	LBB86_3
	b	LBB86_52
LBB86_6:
	cmp	x1, #0
	csinc	x0, x8, xzr, ne
	mov	x2, x19
	mov	w3, #12
	bl	l_mem.eqlBytes
	tbnz	w0, #0, LBB86_10
	add	x20, x20, #1
	cmp	x20, x25
	b.ne	LBB86_2
	mov	x24, x22
	str	wzr, [sp, #44]
	mov	x28, x25
	adds	x19, x25, #1
	b.lo	LBB86_11
	b	LBB86_52
LBB86_9:
	mov	x24, x22
	str	wzr, [sp, #44]
	mov	x28, #0
	adds	x19, x28, #1
	b.lo	LBB86_11
	b	LBB86_52
LBB86_10:
	mov	x24, x22
	sub	x28, x25, #1
	mov	w8, #1
	str	w8, [sp, #44]
	adds	x19, x28, #1
	b.hs	LBB86_52
LBB86_11:
	lsr	x8, x19, #61
	cbnz	x8, LBB86_37
	xpaci	x23
	lsl	x20, x19, #3
	ldr	x8, [x24]
	mov	x0, x26
	mov	x1, x20
	mov	w2, #3
	mov	x27, x23
	mov	x3, x23
	blr	x8
	cbz	x0, LBB86_37
	mov	x22, x0
	mov	w1, #170
	mov	x2, x20
	bl	_memset
	tst	x22, #0x7
	b.ne	LBB86_57
	str	x22, [sp, #32]
	str	x21, [sp, #8]
	cmp	x28, x19
	mov	x0, x28
	b.hs	LBB86_58
	mov	x28, #0
	mov	x19, #0
	ldr	x8, [sp, #32]
	stp	x25, x0, [sp, #16]
	str	xzr, [x8, x0, lsl #3]
Lloh534:
	adrp	x23, l___anon_7054@PAGE
Lloh535:
	add	x23, x23, l___anon_7054@PAGEOFF
LBB86_16:
	ldr	x8, [sp, #48]
	ldr	x21, [x8, x28, lsl #3]
	cbz	x21, LBB86_38
	mov	x1, #0
LBB86_18:
	ldrb	w8, [x21, x1]
	cbz	w8, LBB86_21
	cmp	w8, #61
	b.eq	LBB86_21
	adds	x1, x1, #1
	b.lo	LBB86_18
	b	LBB86_52
LBB86_21:
	cmp	x1, #0
	csinc	x0, x21, xzr, ne
	mov	x2, x23
	mov	w3, #12
	bl	l_mem.eqlBytes
	ldr	w8, [sp, #44]
	and	w8, w8, w0
	tbnz	w8, #0, LBB86_34
	ldr	x8, [sp, #24]
	cmp	x19, x8
	b.hi	LBB86_53
	ldrb	w8, [x21]
	cbz	w8, LBB86_28
	mov	x22, #0
	add	x8, x21, #1
LBB86_25:
	cmn	x22, #1
	b.eq	LBB86_52
	ldrb	w9, [x8, x22]
	add	x22, x22, #1
	cbnz	w9, LBB86_25
	str	x19, [sp, #56]
	adds	x19, x22, #1
	b.lo	LBB86_29
	b	LBB86_52
LBB86_28:
	mov	x22, #0
	str	x19, [sp, #56]
	adds	x19, x22, #1
	b.hs	LBB86_52
LBB86_29:
	ldr	x8, [x24]
	mov	x0, x26
	mov	x1, x19
	mov	w2, #0
	mov	x3, x27
	blr	x8
	cbz	x0, LBB86_40
	mov	x20, x0
	mov	x25, x24
	mov	w1, #170
	mov	x2, x19
	bl	_memset
	add	x24, x20, x22
	add	x8, x21, x22
	cmp	x20, x8
	b.hs	LBB86_32
	cmp	x21, x24
	b.lo	LBB86_54
LBB86_32:
	mov	x0, x20
	mov	x1, x21
	mov	x2, x22
	bl	_memcpy
	cmp	x22, x19
	b.hs	LBB86_55
	strb	wzr, [x24]
	ldr	x8, [sp, #32]
	ldr	x19, [sp, #56]
	str	x20, [x8, x19, lsl #3]
	add	x19, x19, #1
	mov	x24, x25
	ldr	x25, [sp, #16]
LBB86_34:
	adds	x28, x28, #1
	b.hs	LBB86_52
	cmp	x28, x25
	b.ls	LBB86_16
	mov	x0, x28
	mov	x1, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB86_37:
	mov	w8, #64
	strh	w8, [x21, #16]
	b	LBB86_51
LBB86_38:
	ldr	x10, [sp, #24]
	cmp	x19, x10
	b.ne	LBB86_59
	ldr	x8, [sp, #8]
	strh	wzr, [x8, #16]
	ldr	x9, [sp, #32]
	stp	x9, x10, [x8]
	b	LBB86_51
LBB86_40:
	ldr	x8, [sp, #56]
	lsl	x21, x8, #3
	ldr	x23, [sp, #32]
	str	xzr, [x23, x21]
	cbz	x8, LBB86_50
	mov	x22, #0
LBB86_42:
	ldr	x19, [x23, x22, lsl #3]
	cbz	x19, LBB86_56
	ldrb	w8, [x19]
	cbz	w8, LBB86_48
	mov	w8, #1
LBB86_45:
	cbz	x8, LBB86_52
	ldrb	w9, [x19, x8]
	add	x8, x8, #1
	cbnz	w9, LBB86_45
	sub	x8, x8, #2
	adds	x20, x8, #2
	cset	w8, hs
	tbz	w8, #0, LBB86_49
	b	LBB86_52
LBB86_48:
	mov	w20, #1
	tbnz	w8, #0, LBB86_52
LBB86_49:
	mov	x0, x19
	mov	w1, #170
	mov	x2, x20
	bl	_memset
	ldr	x8, [x24, #24]
	mov	x0, x26
	mov	x1, x19
	mov	x2, x20
	mov	w3, #0
	mov	x4, x27
	blr	x8
	add	x22, x22, #1
	ldr	x8, [sp, #56]
	cmp	x22, x8
	b.ne	LBB86_42
LBB86_50:
	add	x2, x21, #8
	mov	x0, x23
	mov	w1, #170
	bl	_memset
	ldr	x8, [x24, #24]
	add	x2, x21, #8
	mov	x0, x26
	mov	x1, x23
	mov	w3, #3
	mov	x4, x27
	blr	x8
	mov	w8, #64
	ldr	x9, [sp, #8]
	strh	w8, [x9, #16]
LBB86_51:
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB86_52:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB86_53:
	mov	x0, x19
	ldr	x1, [sp, #24]
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB86_54:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB86_55:
	mov	x0, x22
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB86_56:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB86_57:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB86_58:
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB86_59:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpAdd	Lloh532, Lloh533
	.loh AdrpAdd	Lloh534, Lloh535
	.cfi_endproc

	.p2align	2
l_Io.Writer.Allocating.ensureTotalCapacityPrecise:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	ldr	x22, [x0, #32]
	cmp	x22, x1
	b.hs	LBB87_3
	mov	x21, x30
	mov	x19, x1
	mov	x20, x0
	ldr	x23, [x0, #24]
	ldrb	w24, [x0, #48]
	cbz	x22, LBB87_4
	ldp	x0, x8, [x20]
	xpaci	x21
	ldr	x8, [x8, #16]
	mov	x1, x23
	mov	x2, x22
	mov	x3, x24
	mov	x4, x19
	mov	x5, x21
	blr	x8
	mov	x8, x0
	cbnz	x0, LBB87_11
	b	LBB87_5
LBB87_3:
	mov	w0, #0
	b	LBB87_13
LBB87_4:
	xpaci	x21
LBB87_5:
	ldp	x0, x8, [x20]
	ldr	x8, [x8]
	mov	x1, x19
	mov	x2, x24
	mov	x3, x21
	blr	x8
	cbz	x0, LBB87_12
	ldr	x2, [x20, #40]
	cmp	x2, x22
	b.hi	LBB87_14
	add	x8, x0, x2
	add	x9, x23, x2
	cmp	x0, x9
	ccmp	x23, x8, #2, lo
	b.lo	LBB87_15
	mov	x25, x0
	mov	x1, x23
	bl	_memcpy
	cbz	x22, LBB87_10
	ldp	x0, x8, [x20]
	ldr	x8, [x8, #24]
	mov	x1, x23
	mov	x2, x22
	mov	x3, x24
	mov	x4, x21
	blr	x8
LBB87_10:
	mov	x8, x25
LBB87_11:
	mov	w0, #0
	stp	x8, x19, [x20, #24]
	b	LBB87_13
LBB87_12:
	mov	w0, #64
LBB87_13:
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB87_14:
	.cfi_restore_state
	mov	x0, x2
	mov	x1, x22
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB87_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI88_0:
	.quad	7
	.quad	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_process.Environ.Map.createPosixBlock:
	.cfi_startproc
	sub	sp, sp, #384
	.cfi_def_cfa_offset 384
	stp	x28, x27, [sp, #288]
	stp	x26, x25, [sp, #304]
	stp	x24, x23, [sp, #320]
	stp	x22, x21, [sp, #336]
	stp	x20, x19, [sp, #352]
	stp	x29, x30, [sp, #368]
	add	x29, sp, #368
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x21, x30
	mov	x22, x3
	mov	x28, x2
	mov	x25, x1
	mov	x20, x0
Lloh536:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh537:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh538:
	ldr	x8, [x8]
	str	x8, [sp, #80]
	stur	x8, [x29, #-96]
	ldp	x8, x23, [x1]
	str	x8, [sp, #56]
	ldp	x8, x2, [x1, #16]
	cbnz	x2, LBB88_15
	lsr	x9, x8, #60
	cbnz	x9, LBB88_93
	cmp	x8, #0
	csel	x0, xzr, x23, eq
	cbz	x8, LBB88_5
	ldr	x9, [sp, #56]
	tst	x9, #0x7
	b.ne	LBB88_101
	mov	x8, x23
	cbnz	x23, LBB88_6
	b	LBB88_22
LBB88_5:
	mov	w9, #8
	cbz	x8, LBB88_22
LBB88_6:
	add	x9, x9, #8
	mov	w10, #21072
	movk	w10, #18255, lsl #16
	mov	w11, #17746
	movk	w11, #21331, lsl #16
	mov	w12, #18778
	movk	w12, #24391, lsl #16
	mov	x13, x0
Lloh539:
	adrp	x14, l___anon_7054@PAGE
Lloh540:
	add	x14, x14, l___anon_7054@PAGEOFF
	b	LBB88_8
LBB88_7:
	add	x9, x9, #16
	sub	x13, x13, #1
	sub	x8, x8, #1
	cbz	x8, LBB88_22
LBB88_8:
	cbz	x13, LBB88_96
	ldr	x15, [x9]
	cmp	x15, #12
	b.ne	LBB88_7
	ldur	x15, [x9, #-8]
	cmp	x15, x14
	b.eq	LBB88_12
	ldp	w17, w16, [x15, #4]
	ldr	w15, [x15]
	cmp	w17, w10
	ccmp	w16, w11, #0, eq
	ccmp	w15, w12, #0, eq
	b.ne	LBB88_7
LBB88_12:
LBB88_13:
	subs	x23, x23, #1
	b.lo	LBB88_93
	mov	w8, #1
	str	w8, [sp, #68]
	b	LBB88_23
LBB88_15:
	ldr	x9, [x25, #32]
	ldrb	w10, [x2]
	cmp	w10, #9
	b.hs	LBB88_17
	ldr	x10, [sp, #56]
	stp	x10, x23, [sp, #88]
	stp	x8, x2, [sp, #104]
	str	x9, [sp, #120]
	add	x0, sp, #168
	add	x1, sp, #88
	bl	"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getIndexWithHeaderGeneric__func_182"
	ldrb	w8, [sp, #176]
	ldr	x23, [x25, #8]
	tbnz	w8, #0, LBB88_12
	b	LBB88_22
LBB88_17:
	cmp	w10, #17
	b.hs	LBB88_20
	ldr	x10, [sp, #56]
	stp	x10, x23, [sp, #128]
	stp	x8, x2, [sp, #144]
	str	x9, [sp, #160]
	add	x0, sp, #184
	add	x1, sp, #128
	bl	"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getIndexWithHeaderGeneric__func_183"
	ldrb	w8, [sp, #192]
	ldr	x23, [x25, #8]
	tbnz	w8, #0, LBB88_13
	str	wzr, [sp, #68]
	b	LBB88_23
LBB88_20:
	cmp	w10, #33
	b.hs	LBB88_104
	ldr	x10, [sp, #56]
	stp	x10, x23, [x29, #-152]
	stp	x8, x2, [x29, #-136]
	stur	x9, [x29, #-120]
	sub	x0, x29, #168
	sub	x1, x29, #152
	bl	"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getIndexWithHeaderGeneric__func_184"
	ldurb	w8, [x29, #-160]
	ldr	x23, [x25, #8]
	tbnz	w8, #0, LBB88_12
LBB88_22:
	str	wzr, [sp, #68]
LBB88_23:
	adds	x19, x23, #1
	b.hs	LBB88_93
	lsr	x8, x19, #61
	cbnz	x8, LBB88_72
	mov	x3, x21
	xpaci	x3
	lsl	x21, x19, #3
	ldr	x8, [x22]
	mov	x0, x28
	mov	x1, x21
	mov	w2, #3
	str	x3, [sp, #72]
	blr	x8
	cbz	x0, LBB88_72
	mov	x24, x0
	mov	w1, #170
	mov	x2, x21
	bl	_memset
	tst	x24, #0x7
	b.ne	LBB88_101
	cmp	x23, x19
	b.hs	LBB88_106
	str	xzr, [x24, x23, lsl #3]
	ldr	x9, [x25, #16]
	lsr	x8, x9, #60
	cbnz	x8, LBB88_93
	str	x24, [sp, #32]
	cbz	x9, LBB88_77
	ldr	x8, [x25]
	tst	x8, #0x7
	b.ne	LBB88_101
	ldr	x24, [x25, #8]
	add	x9, x8, x9, lsl #4
	cmp	x24, x24
	b.ne	LBB88_78
LBB88_32:
	str	x23, [sp, #40]
	str	x20, [sp, #8]
	mov	x25, #0
	cbz	x24, LBB88_74
	add	x23, x9, #8
	add	x20, x8, #8
Lloh541:
	adrp	x8, lCPI88_0@PAGE
Lloh542:
	ldr	q0, [x8, lCPI88_0@PAGEOFF]
	str	q0, [sp, #16]
	str	x22, [sp, #48]
	b	LBB88_35
LBB88_34:
	add	x23, x23, #16
	add	x20, x20, #16
	subs	x24, x24, #1
	b.eq	LBB88_74
LBB88_35:
	ldp	x21, x27, [x20, #-8]
	ldp	x19, x26, [x23, #-8]
	cmp	x27, #0
	csinc	x0, x21, xzr, ne
	mov	x1, x27
Lloh543:
	adrp	x2, l___anon_7054@PAGE
Lloh544:
	add	x2, x2, l___anon_7054@PAGEOFF
	mov	w3, #12
	bl	l_mem.eqlBytes
	ldr	w8, [sp, #68]
	and	w8, w8, w0
	tbnz	w8, #0, LBB88_34
	ldr	x8, [sp, #40]
	cmp	x25, x8
	b.hi	LBB88_97
	ldr	x8, [x22]
	mov	x0, x28
	mov	w1, #7
	mov	w2, #0
	ldr	x3, [sp, #72]
	blr	x8
	cbz	x0, LBB88_82
	stp	x28, x22, [x29, #-152]
Lloh545:
	adrp	x8, l_Io.Writer.Allocating.vtable@PAGE
Lloh546:
	add	x8, x8, l_Io.Writer.Allocating.vtable@PAGEOFF
	stp	x8, x0, [x29, #-136]
	ldr	q0, [sp, #16]
	stur	q0, [x29, #-120]
	sturb	wzr, [x29, #-104]
	sub	x22, x29, #152
	stur	wzr, [x22, #49]
	stur	wzr, [x22, #52]
	add	x0, x22, #16
	mov	x1, x21
	mov	x2, x27
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB88_41
	add	x0, x22, #16
Lloh547:
	adrp	x1, l___anon_8432@PAGE
Lloh548:
	add	x1, x1, l___anon_8432@PAGEOFF
	mov	w2, #1
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB88_41
	add	x0, x22, #16
	mov	x1, x19
	mov	x2, x26
	bl	l_Io.Writer.writeAll
LBB88_41:
	ands	w8, w0, #0xffff
	b.ne	LBB88_79
	mov	x22, x28
	ldur	x0, [x29, #-112]
	adds	x28, x0, #1
	b.hs	LBB88_93
	ldp	x27, x19, [x29, #-128]
	cmp	x19, x28
	b.hs	LBB88_54
	ldurb	w26, [x29, #-104]
	cbz	x19, LBB88_46
	ldp	x0, x8, [x29, #-152]
	ldr	x8, [x8, #16]
	mov	x1, x27
	mov	x2, x19
	mov	x3, x26
	mov	x4, x28
	ldr	x5, [sp, #72]
	blr	x8
	cbnz	x0, LBB88_53
LBB88_46:
	ldp	x0, x8, [x29, #-152]
	ldr	x8, [x8]
	mov	x1, x28
	mov	x2, x26
	ldr	x3, [sp, #72]
	blr	x8
	cbz	x0, LBB88_70
	ldur	x2, [x29, #-112]
	cmp	x2, x19
	b.hi	LBB88_105
	add	x8, x27, x2
	cmp	x0, x8
	b.hs	LBB88_50
	add	x8, x0, x2
	cmp	x27, x8
	b.lo	LBB88_102
LBB88_50:
	mov	x21, x0
	mov	x1, x27
	bl	_memcpy
	cbz	x19, LBB88_52
	ldp	x0, x8, [x29, #-152]
	ldr	x8, [x8, #24]
	mov	x1, x27
	mov	x2, x19
	mov	x3, x26
	ldr	x4, [sp, #72]
	blr	x8
LBB88_52:
	mov	x0, x21
LBB88_53:
	stp	x0, x28, [x29, #-128]
	mov	x27, x0
	ldur	x0, [x29, #-112]
	cmp	x0, x28
	b.lo	LBB88_55
	b	LBB88_98
LBB88_54:
	mov	x28, x19
	cmp	x0, x19
	b.hs	LBB88_98
LBB88_55:
	strb	wzr, [x27, x0]
	ldur	x8, [x29, #-112]
	adds	x27, x8, #1
	b.hs	LBB88_93
	stur	x27, [x29, #-112]
	ldp	x26, x19, [x29, #-128]
	ldurb	w28, [x29, #-104]
	cbz	x19, LBB88_58
	ldp	x0, x8, [x29, #-152]
	ldr	x8, [x8, #16]
	mov	x1, x26
	mov	x2, x19
	mov	x3, x28
	mov	x4, x27
	ldr	x5, [sp, #72]
	blr	x8
	mov	x21, x0
	cbnz	x0, LBB88_63
LBB88_58:
	ldp	x0, x8, [x29, #-152]
	ldr	x8, [x8]
	mov	x1, x27
	mov	x2, x28
	ldr	x3, [sp, #72]
	blr	x8
	cbz	x0, LBB88_68
	cmp	x27, x19
	b.hi	LBB88_103
	mov	x21, x0
	add	x8, x26, x27
	cmp	x0, x8
	b.hs	LBB88_62
	add	x8, x21, x27
	cmp	x26, x8
	b.lo	LBB88_102
LBB88_62:
	mov	x0, x21
	mov	x1, x26
	mov	x2, x27
	bl	_memcpy
	ldp	x0, x8, [x29, #-152]
	ldr	x8, [x8, #24]
	mov	x1, x26
	mov	x2, x19
	mov	x3, x28
	ldr	x4, [sp, #72]
	blr	x8
LBB88_63:
	mov	w19, #1
	stur	x19, [x29, #-128]
	sub	x8, x29, #152
	stp	xzr, xzr, [x8, #32]
	add	x8, x21, x27
	ldurb	w0, [x8, #-1]
	cbnz	w0, LBB88_99
	mov	w26, #0
	mov	x28, x22
	ldur	x2, [x29, #-120]
	ldr	x22, [sp, #48]
	cbz	x2, LBB88_66
LBB88_65:
	ldp	x0, x8, [x29, #-152]
	ldur	x1, [x29, #-128]
	ldr	x8, [x8, #24]
	ldurb	w3, [x29, #-104]
	ldr	x4, [sp, #72]
	blr	x8
LBB88_66:
	tbz	w19, #0, LBB88_83
	ldr	x8, [sp, #32]
	str	x21, [sp, #56]
	str	x21, [x8, x25, lsl #3]
	add	x25, x25, #1
	b	LBB88_34
LBB88_68:
	ldur	x8, [x29, #-112]
	subs	x8, x8, #1
	b.lo	LBB88_93
	mov	w19, #0
	stur	x8, [x29, #-112]
	b	LBB88_71
LBB88_70:
	mov	w19, #0
LBB88_71:
	mov	w26, #64
	mov	x28, x22
	ldp	x22, x21, [sp, #48]
	ldur	x2, [x29, #-120]
	cbnz	x2, LBB88_65
	b	LBB88_66
LBB88_72:
	mov	w8, #64
	strh	w8, [x20, #16]
	ldur	x8, [x29, #-96]
Lloh549:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh550:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh551:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB88_76
LBB88_73:
	.cfi_def_cfa wsp, 384
	ldp	x29, x30, [sp, #368]
	ldp	x20, x19, [sp, #352]
	ldp	x22, x21, [sp, #336]
	ldp	x24, x23, [sp, #320]
	ldp	x26, x25, [sp, #304]
	ldp	x28, x27, [sp, #288]
	add	sp, sp, #384
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB88_74:
	.cfi_restore_state
	ldr	x9, [sp, #40]
	cmp	x25, x9
	b.ne	LBB88_104
	ldr	x8, [sp, #8]
	strh	wzr, [x8, #16]
	ldr	x10, [sp, #32]
	stp	x10, x9, [x8]
	ldur	x8, [x29, #-96]
Lloh552:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh553:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh554:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB88_73
LBB88_76:
	bl	___stack_chk_fail
LBB88_77:
	mov	x24, #0
	mov	x10, #0
	mov	w8, #8
	mov	w9, #8
	cmp	x24, x10
	b.eq	LBB88_32
LBB88_78:
	bl	"l_debug.FullPanic((function 'defaultPanic')).forLenMismatch"
LBB88_79:
	cmp	w8, #102
	b.ne	LBB88_95
	ldur	x2, [x29, #-120]
	cbz	x2, LBB88_82
	ldp	x0, x8, [x29, #-152]
	ldur	x1, [x29, #-128]
	ldr	x8, [x8, #24]
	ldurb	w3, [x29, #-104]
	ldr	x4, [sp, #72]
	blr	x8
LBB88_82:
	mov	w26, #64
LBB88_83:
	lsl	x20, x25, #3
	ldr	x23, [sp, #32]
	str	xzr, [x23, x20]
	cbz	x25, LBB88_94
	mov	x22, #0
	b	LBB88_87
LBB88_85:
	mov	w21, #1
	tbnz	w8, #0, LBB88_93
LBB88_86:
	mov	x0, x19
	mov	w1, #170
	mov	x2, x21
	bl	_memset
	ldr	x8, [sp, #48]
	ldr	x8, [x8, #24]
	mov	x0, x28
	mov	x1, x19
	mov	x2, x21
	mov	w3, #0
	ldr	x4, [sp, #72]
	blr	x8
	add	x22, x22, #1
	cmp	x22, x25
	b.eq	LBB88_94
LBB88_87:
	ldr	x19, [x23, x22, lsl #3]
	cbz	x19, LBB88_100
	ldrb	w8, [x19]
	cbz	w8, LBB88_85
	mov	w8, #1
LBB88_90:
	cbz	x8, LBB88_93
	ldrb	w9, [x19, x8]
	add	x8, x8, #1
	cbnz	w9, LBB88_90
	sub	x8, x8, #2
	adds	x21, x8, #2
	cset	w8, hs
	tbz	w8, #0, LBB88_86
LBB88_93:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB88_94:
	add	x2, x20, #8
	mov	x0, x23
	mov	w1, #170
	bl	_memset
	ldr	x8, [sp, #48]
	ldr	x8, [x8, #24]
	add	x2, x20, #8
	mov	x0, x28
	mov	x1, x23
	mov	w3, #3
	ldr	x4, [sp, #72]
	blr	x8
	ldr	x8, [sp, #8]
	strh	w26, [x8, #16]
	ldur	x8, [x29, #-96]
Lloh555:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh556:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh557:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB88_73
	b	LBB88_76
LBB88_95:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB88_96:
	mov	x1, x0
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB88_97:
	mov	x0, x25
	ldr	x1, [sp, #40]
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB88_98:
	mov	x1, x28
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB88_99:
	bl	"l_debug.FullPanic((function 'defaultPanic')).sentinelMismatch__func_47"
LBB88_100:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB88_101:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB88_102:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB88_103:
	mov	x0, x27
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB88_104:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB88_105:
	mov	x0, x2
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB88_106:
	mov	x0, x23
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh536, Lloh537, Lloh538
	.loh AdrpAdd	Lloh539, Lloh540
	.loh AdrpLdr	Lloh541, Lloh542
	.loh AdrpAdd	Lloh543, Lloh544
	.loh AdrpAdd	Lloh545, Lloh546
	.loh AdrpAdd	Lloh547, Lloh548
	.loh AdrpLdrGotLdr	Lloh549, Lloh550, Lloh551
	.loh AdrpLdrGotLdr	Lloh552, Lloh553, Lloh554
	.loh AdrpLdrGotLdr	Lloh555, Lloh556, Lloh557
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).forLenMismatch":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh558:
	adrp	x0, l___anon_8446@PAGE
Lloh559:
	add	x0, x0, l___anon_8446@PAGEOFF
	mov	w1, #44
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh558, Lloh559
	.cfi_endproc

	.p2align	2
"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getIndexWithHeaderGeneric__func_184":
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh560:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh561:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh562:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	ldr	w8, [x2]
	tst	w8, #0xc0
	b.ne	LBB90_8
	mov	x19, x0
	add	x20, x2, #4
	mov	w9, #1
	lsl	x21, x9, x8
	ldp	q0, q1, [x1]
	stp	q0, q1, [sp, #16]
	ldr	x8, [x1, #32]
	str	x8, [sp, #48]
	add	x0, sp, #56
	add	x1, sp, #16
	mov	x3, x20
	mov	x4, x21
	bl	"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getSlotByKey__func_187"
	ldrb	w8, [sp, #64]
	tbz	w8, #0, LBB90_5
	ldr	x0, [sp, #56]
	cmp	x0, x21
	b.hs	LBB90_10
	lsl	x8, x0, #3
	ldr	w8, [x20, x8]
	str	x8, [x19]
	mov	w8, #1
	strb	w8, [x19, #8]
	ldur	x8, [x29, #-40]
Lloh563:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh564:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh565:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB90_9
	.cfi_def_cfa wsp, 128
	b	LBB90_7
LBB90_5:
	.cfi_restore_state
	.cfi_remember_state
	stp	xzr, xzr, [x19]
	ldur	x8, [x29, #-40]
Lloh566:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh567:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh568:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB90_9
	.cfi_def_cfa wsp, 128
LBB90_7:
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB90_8:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB90_9:
	bl	___stack_chk_fail
LBB90_10:
	mov	x1, x21
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh560, Lloh561, Lloh562
	.loh AdrpLdrGotLdr	Lloh563, Lloh564, Lloh565
	.loh AdrpLdrGotLdr	Lloh566, Lloh567, Lloh568
	.cfi_endproc

	.p2align	2
"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getSlotByKey__func_187":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	ldr	x8, [x1, #16]
	lsr	x9, x8, #60
	cbnz	x9, LBB91_19
	cbz	x8, LBB91_4
	ldr	x10, [x1]
	tst	x10, #0x7
	b.ne	LBB91_22
	ldr	x1, [x1, #8]
	ldr	w8, [x2]
	and	w9, w8, #0xc0
	cbz	w9, LBB91_5
	b	LBB91_21
LBB91_4:
	mov	x1, #0
	mov	w10, #8
	ldr	w8, [x2]
	and	w9, w8, #0xc0
	cbnz	w9, LBB91_21
LBB91_5:
	and	x9, x8, #0x3f
	cmp	w9, #32
	b.hi	LBB91_21
	mov	x11, #0
	mov	w9, #1
	lsl	x8, x9, x8
	sub	w12, w8, #1
	mov	w13, #22631
	movk	w13, #18538, lsl #16
Lloh569:
	adrp	x14, l___anon_7054@PAGE
Lloh570:
	add	x14, x14, l___anon_7054@PAGEOFF
	mov	w15, #21072
	movk	w15, #18255, lsl #16
	mov	w16, #17746
	movk	w16, #21331, lsl #16
	mov	w17, #18778
	movk	w17, #24391, lsl #16
	mov	w2, #-1
LBB91_7:
	add	x8, x11, x13
	and	x8, x12, x8
	cmp	x8, x4
	b.hs	LBB91_18
	add	x5, x3, x8, lsl #3
	ldp	w9, w5, [x5]
	cmn	w9, #1
	ccmp	w5, w11, #0, ne
	b.lo	LBB91_16
	cmp	x1, x9
	b.ls	LBB91_20
	add	x9, x10, x9, lsl #4
	ldr	x5, [x9, #8]
	cmp	x5, #12
	b.ne	LBB91_13
	ldr	x9, [x9]
	cmp	x9, x14
	b.eq	LBB91_17
	ldp	w6, w5, [x9, #4]
	ldr	w9, [x9]
	cmp	w6, w15
	ccmp	w5, w16, #0, eq
	ccmp	w9, w17, #0, eq
	b.eq	LBB91_17
LBB91_13:
	cmp	x11, x2
	b.eq	LBB91_19
	add	x11, x11, #1
	cmp	x4, x11
	b.ne	LBB91_7
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB91_16:
	stp	xzr, xzr, [x0]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB91_17:
	.cfi_restore_state
	.cfi_remember_state
	str	x8, [x0]
	mov	w8, #1
	strb	w8, [x0, #8]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB91_18:
	.cfi_restore_state
	mov	x0, x8
	mov	x1, x4
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB91_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB91_20:
	mov	x0, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB91_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB91_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpAdd	Lloh569, Lloh570
	.cfi_endproc

	.p2align	2
"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getIndexWithHeaderGeneric__func_183":
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh571:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh572:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh573:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	ldr	w8, [x2]
	tst	w8, #0xc0
	b.ne	LBB92_8
	mov	x19, x0
	add	x20, x2, #4
	mov	w9, #1
	lsl	x21, x9, x8
	ldp	q0, q1, [x1]
	stp	q0, q1, [sp, #16]
	ldr	x8, [x1, #32]
	str	x8, [sp, #48]
	add	x0, sp, #56
	add	x1, sp, #16
	mov	x3, x20
	mov	x4, x21
	bl	"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getSlotByKey__func_195"
	ldrb	w8, [sp, #64]
	tbz	w8, #0, LBB92_5
	ldr	x0, [sp, #56]
	cmp	x0, x21
	b.hs	LBB92_10
	lsl	x8, x0, #2
	ldrh	w8, [x20, x8]
	str	x8, [x19]
	mov	w8, #1
	strb	w8, [x19, #8]
	ldur	x8, [x29, #-40]
Lloh574:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh575:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh576:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB92_9
	.cfi_def_cfa wsp, 128
	b	LBB92_7
LBB92_5:
	.cfi_restore_state
	.cfi_remember_state
	stp	xzr, xzr, [x19]
	ldur	x8, [x29, #-40]
Lloh577:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh578:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh579:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB92_9
	.cfi_def_cfa wsp, 128
LBB92_7:
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB92_8:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB92_9:
	bl	___stack_chk_fail
LBB92_10:
	mov	x1, x21
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh571, Lloh572, Lloh573
	.loh AdrpLdrGotLdr	Lloh574, Lloh575, Lloh576
	.loh AdrpLdrGotLdr	Lloh577, Lloh578, Lloh579
	.cfi_endproc

	.p2align	2
"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getSlotByKey__func_195":
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	ldr	x8, [x1, #16]
	lsr	x9, x8, #60
	cbnz	x9, LBB93_21
	cbz	x8, LBB93_4
	ldr	x10, [x1]
	tst	x10, #0x7
	b.ne	LBB93_24
	ldr	x1, [x1, #8]
	ldr	w8, [x2]
	and	w9, w8, #0xc0
	cbz	w9, LBB93_5
	b	LBB93_23
LBB93_4:
	mov	x1, #0
	mov	w10, #8
	ldr	w8, [x2]
	and	w9, w8, #0xc0
	cbnz	w9, LBB93_23
LBB93_5:
	and	x9, x8, #0x3f
	cmp	w9, #32
	b.hi	LBB93_23
	mov	w11, #0
	mov	w9, #1
	lsl	x8, x9, x8
	sub	w12, w8, #1
	mov	x13, #-65535
	mov	w14, #22631
	movk	w14, #18538, lsl #16
	mov	w15, #65535
	mov	w16, #21072
	movk	w16, #18255, lsl #16
	mov	w17, #17746
	movk	w17, #21331, lsl #16
	mov	w2, #18778
	movk	w2, #24391, lsl #16
	mov	x5, x4
Lloh580:
	adrp	x6, l___anon_7054@PAGE
Lloh581:
	add	x6, x6, l___anon_7054@PAGEOFF
LBB93_7:
	and	x8, x12, x14
	cmp	x8, x4
	b.hs	LBB93_20
	add	x7, x3, x8, lsl #2
	ldrh	w9, [x7]
	cmp	x9, x15
	b.eq	LBB93_17
	ldrh	w7, [x7, #2]
	cmp	w7, w11, uxth
	b.lo	LBB93_17
	cmp	x1, x9
	b.ls	LBB93_22
	add	x9, x10, x9, lsl #4
	ldr	x7, [x9, #8]
	cmp	x7, #12
	b.ne	LBB93_14
	ldr	x9, [x9]
	cmp	x9, x6
	b.eq	LBB93_18
	ldp	w19, w7, [x9, #4]
	ldr	w9, [x9]
	cmp	w19, w16
	ccmp	w7, w17, #0, eq
	ccmp	w9, w2, #0, eq
	b.eq	LBB93_18
LBB93_14:
	cbz	x13, LBB93_21
	add	x14, x14, #1
	add	w11, w11, #1
	add	x13, x13, #1
	subs	x5, x5, #1
	b.ne	LBB93_7
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB93_17:
	stp	xzr, xzr, [x0]
	.cfi_def_cfa wsp, 32
	b	LBB93_19
LBB93_18:
	.cfi_restore_state
	.cfi_remember_state
	str	x8, [x0]
	mov	w8, #1
	strb	w8, [x0, #8]
	.cfi_def_cfa wsp, 32
LBB93_19:
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB93_20:
	.cfi_restore_state
	mov	x0, x8
	mov	x1, x4
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB93_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB93_22:
	mov	x0, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB93_23:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB93_24:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpAdd	Lloh580, Lloh581
	.cfi_endproc

	.p2align	2
"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getIndexWithHeaderGeneric__func_182":
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh582:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh583:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh584:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	ldr	w8, [x2]
	tst	w8, #0xc0
	b.ne	LBB94_8
	mov	x19, x0
	add	x20, x2, #4
	mov	w9, #1
	lsl	x21, x9, x8
	ldp	q0, q1, [x1]
	stp	q0, q1, [sp, #16]
	ldr	x8, [x1, #32]
	str	x8, [sp, #48]
	add	x0, sp, #56
	add	x1, sp, #16
	mov	x3, x20
	mov	x4, x21
	bl	"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getSlotByKey__func_197"
	ldrb	w8, [sp, #64]
	tbz	w8, #0, LBB94_5
	ldr	x0, [sp, #56]
	cmp	x0, x21
	b.hs	LBB94_10
	lsl	x8, x0, #1
	ldrb	w8, [x20, x8]
	str	x8, [x19]
	mov	w8, #1
	strb	w8, [x19, #8]
	ldur	x8, [x29, #-40]
Lloh585:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh586:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh587:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB94_9
	.cfi_def_cfa wsp, 128
	b	LBB94_7
LBB94_5:
	.cfi_restore_state
	.cfi_remember_state
	stp	xzr, xzr, [x19]
	ldur	x8, [x29, #-40]
Lloh588:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh589:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh590:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB94_9
	.cfi_def_cfa wsp, 128
LBB94_7:
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB94_8:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB94_9:
	bl	___stack_chk_fail
LBB94_10:
	mov	x1, x21
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh582, Lloh583, Lloh584
	.loh AdrpLdrGotLdr	Lloh585, Lloh586, Lloh587
	.loh AdrpLdrGotLdr	Lloh588, Lloh589, Lloh590
	.cfi_endproc

	.p2align	2
"l_array_hash_map.Custom([]const u8,[]const u8,process.Environ.Map.EnvNameHashContext,false).getSlotByKey__func_197":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	ldr	x8, [x1, #16]
	lsr	x9, x8, #60
	cbnz	x9, LBB95_20
	cbz	x8, LBB95_4
	ldr	x10, [x1]
	tst	x10, #0x7
	b.ne	LBB95_23
	ldr	x1, [x1, #8]
	ldr	w8, [x2]
	and	w9, w8, #0xc0
	cbz	w9, LBB95_5
	b	LBB95_22
LBB95_4:
	mov	x1, #0
	mov	w10, #8
	ldr	w8, [x2]
	and	w9, w8, #0xc0
	cbnz	w9, LBB95_22
LBB95_5:
	and	x9, x8, #0x3f
	cmp	w9, #32
	b.hi	LBB95_22
	mov	w11, #0
	mov	w9, #1
	lsl	x8, x9, x8
	sub	w12, w8, #1
	mov	w13, #22631
	movk	w13, #18538, lsl #16
	mov	w14, #255
Lloh591:
	adrp	x15, l___anon_7054@PAGE
Lloh592:
	add	x15, x15, l___anon_7054@PAGEOFF
	mov	w16, #21072
	movk	w16, #18255, lsl #16
	mov	w17, #17746
	movk	w17, #21331, lsl #16
	mov	w2, #18778
	movk	w2, #24391, lsl #16
LBB95_7:
	and	x8, x12, x13
	cmp	x8, x4
	b.hs	LBB95_19
	add	x5, x3, x8, lsl #1
	ldrb	w9, [x5]
	cmp	x9, #255
	b.eq	LBB95_17
	ldrb	w5, [x5, #1]
	cmp	w5, w11, uxtb
	b.lo	LBB95_17
	cmp	x1, x9
	b.ls	LBB95_21
	add	x9, x10, x9, lsl #4
	ldr	x5, [x9, #8]
	cmp	x5, #12
	b.ne	LBB95_14
	ldr	x9, [x9]
	cmp	x9, x15
	b.eq	LBB95_18
	ldp	w6, w5, [x9, #4]
	ldr	w9, [x9]
	cmp	w6, w16
	ccmp	w5, w17, #0, eq
	ccmp	w9, w2, #0, eq
	b.eq	LBB95_18
LBB95_14:
	cbz	x14, LBB95_20
	add	x13, x13, #1
	add	w11, w11, #1
	sub	x14, x14, #1
	add	x8, x4, x14
	cmp	x8, #255
	b.ne	LBB95_7
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB95_17:
	stp	xzr, xzr, [x0]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB95_18:
	.cfi_restore_state
	.cfi_remember_state
	str	x8, [x0]
	mov	w8, #1
	strb	w8, [x0, #8]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB95_19:
	.cfi_restore_state
	mov	x0, x8
	mov	x1, x4
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB95_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB95_21:
	mov	x0, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB95_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB95_23:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpAdd	Lloh591, Lloh592
	.cfi_endproc

	.p2align	2
l_Io.Threaded.processReplace:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #560
Lloh593:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh594:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh595:
	ldr	x8, [x8]
	str	x8, [sp, #168]
	stur	x8, [x29, #-104]
	add	x22, sp, #336
	ldp	q0, q1, [x1]
	stp	q0, q1, [x22, #112]
	ldp	x26, x21, [x1, #32]
	ldr	q0, [x1, #48]
	str	q0, [x22, #80]
	ldr	x8, [x1, #64]
	stur	x8, [x29, #-208]
	cbz	x0, LBB96_70
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB96_69
	mov	x19, x30
	ldp	x9, x27, [x1, #72]
	ldp	x28, x25, [x1, #88]
	ldr	x8, [x1, #104]
	stp	x8, x9, [sp, #152]
	ldrb	w23, [x1, #112]
	ldrb	w8, [x1, #113]
	str	w8, [sp, #148]
	mov	x0, x20
	bl	l_Io.Threaded.scanEnviron
	ldr	x10, [x20, #600]
	ldr	x9, [x20, #608]
	add	x8, x20, #744
	ldr	q0, [x8]
	stp	xzr, xzr, [sp, #352]
	ldr	q1, [x22, #16]
	stp	q0, q1, [sp, #176]
	adds	x24, x21, #1
	b.hs	LBB96_66
	xpaci	x19
	lsr	x8, x24, #61
	cbnz	x8, LBB96_17
	stp	x10, x9, [sp, #112]
	str	x25, [sp, #128]
	lsl	x25, x24, #3
	add	x0, sp, #176
	mov	x1, x25
	mov	w2, #3
	bl	l_heap.ArenaAllocator.alloc
	cbz	x0, LBB96_17
	mov	x22, x0
	mov	w1, #170
	mov	x2, x25
	bl	_memset
	tst	x22, #0x7
	b.ne	LBB96_69
	stp	x28, x27, [sp, #88]
	str	w23, [sp, #108]
	cmp	x21, x24
	b.hs	LBB96_72
	str	x22, [sp, #136]
	str	xzr, [x22, x21, lsl #3]
	cbz	x21, LBB96_14
	add	x28, x26, #8
	ldr	x22, [sp, #136]
LBB96_9:
	ldr	x24, [x28]
	adds	x25, x24, #1
	b.hs	LBB96_66
	ldur	x27, [x28, #-8]
	add	x0, sp, #176
	mov	x1, x25
	mov	w2, #0
	bl	l_heap.ArenaAllocator.alloc
	cbz	x0, LBB96_25
	mov	x26, x0
	mov	w1, #170
	mov	x2, x25
	bl	_memset
	add	x23, x26, x24
	add	x8, x27, x24
	cmp	x26, x8
	ccmp	x27, x23, #2, lo
	b.lo	LBB96_68
	mov	x0, x26
	mov	x1, x27
	mov	x2, x24
	bl	_memcpy
	cmp	x24, x25
	b.hs	LBB96_67
	add	x28, x28, #16
	strb	wzr, [x23]
	str	x26, [x22], #8
	subs	x21, x21, #1
	b.ne	LBB96_9
LBB96_14:
	ldr	x1, [sp, #160]
	cbz	x1, LBB96_26
Lloh596:
	adrp	x3, l___anon_4630@PAGE
Lloh597:
	add	x3, x3, l___anon_4630@PAGEOFF
	sub	x22, x29, #152
	sub	x0, x29, #152
	add	x2, sp, #176
	bl	l_process.Environ.Map.createPosixBlock
	ldurh	w21, [x29, #-136]
	ldr	w10, [sp, #108]
	ldp	x12, x11, [sp, #88]
	ldr	x13, [sp, #128]
	cbz	w21, LBB96_27
	add	x8, sp, #272
	b	LBB96_18
LBB96_17:
	mov	w21, #64
	add	x8, sp, #208
LBB96_18:
	ldp	q0, q1, [sp, #176]
	stp	q0, q1, [x8]
	ldp	x20, x22, [x8]
	ldp	x1, x23, [x8, #16]
	cbz	x1, LBB96_20
LBB96_19:
	ldr	x24, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x24
	cbnz	x24, LBB96_19
LBB96_20:
	cbz	x23, LBB96_23
	mov	x1, x23
LBB96_22:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB96_22
LBB96_23:
	ldur	x8, [x29, #-104]
Lloh598:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh599:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh600:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB96_71
	mov	x0, x21
	add	sp, sp, #560
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB96_25:
	.cfi_restore_state
	mov	w21, #64
	add	x8, sp, #240
	b	LBB96_18
LBB96_26:
	ldr	x1, [x20, #584]
	ldr	x2, [x20, #592]
Lloh601:
	adrp	x4, l___anon_4630@PAGE
Lloh602:
	add	x4, x4, l___anon_4630@PAGEOFF
	sub	x22, x29, #128
	sub	x0, x29, #128
	add	x3, sp, #176
	bl	l_process.Environ.createPosixBlock
	ldurh	w21, [x29, #-112]
	ldr	w10, [sp, #108]
	ldp	x12, x11, [sp, #88]
	ldr	x13, [sp, #128]
	cbnz	w21, LBB96_58
LBB96_27:
	ldr	x6, [x22]
Lloh603:
	adrp	x8, l___anon_7325@PAGE
Lloh604:
	add	x8, x8, l___anon_7325@PAGEOFF
	ldp	x9, x14, [sp, #112]
	cmp	x9, #0
	csel	x8, x8, x9, eq
	mov	w9, #28
	csel	x9, x9, x14, eq
	stp	x8, x9, [sp, #72]
	ldr	w8, [sp, #148]
	and	w8, w8, #0x1
	strb	w8, [sp, #69]
	strb	wzr, [sp, #68]
	ldr	x8, [sp, #152]
	stp	x13, x8, [sp, #48]
	stp	x11, x12, [sp, #32]
	strb	wzr, [sp, #24]
	mov	w8, #255
	add	x0, sp, #368
	sub	x3, x29, #192
	sub	x5, x29, #224
	and	w7, w10, #0x1
	strb	wzr, [sp, #16]
	strb	wzr, [sp, #8]
	strb	w8, [sp]
	mov	x1, x20
	mov	w2, #1
	ldr	x4, [sp, #136]
	bl	l_Io.Threaded.spawnDarwin
	ldrh	w21, [sp, #412]
	cmp	w21, #75
	b.hi	LBB96_52
Lloh605:
	adrp	x8, LJTI96_0@PAGE
Lloh606:
	add	x8, x8, LJTI96_0@PAGEOFF
	adr	x9, LBB96_29
	ldrb	w10, [x8, x21]
	add	x9, x9, x10, lsl #2
	br	x9
LBB96_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB96_30:
	ldp	x20, x21, [sp, #176]
	ldp	x1, x22, [sp, #192]
	cbz	x1, LBB96_32
LBB96_31:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x21, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB96_31
LBB96_32:
	cbz	x22, LBB96_35
	mov	x1, x22
LBB96_34:
	ldr	x22, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x21, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x22
	cbnz	x22, LBB96_34
LBB96_35:
	mov	w21, #39
	b	LBB96_23
LBB96_36:
	ldp	x20, x22, [sp, #176]
	ldp	x1, x21, [sp, #192]
	cbz	x1, LBB96_38
LBB96_37:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB96_37
LBB96_38:
	cbz	x21, LBB96_41
	mov	x1, x21
LBB96_40:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	w21, #50
	mov	x1, x23
	cbnz	x23, LBB96_40
	b	LBB96_23
LBB96_41:
	mov	w21, #50
	b	LBB96_23
LBB96_42:
	ldp	x20, x22, [sp, #176]
	ldp	x1, x21, [sp, #192]
	cbz	x1, LBB96_44
LBB96_43:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB96_43
LBB96_44:
	cbz	x21, LBB96_57
	mov	x1, x21
LBB96_46:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	w21, #4
	mov	x1, x23
	cbnz	x23, LBB96_46
	b	LBB96_23
LBB96_47:
	ldp	x20, x22, [sp, #176]
	ldp	x1, x21, [sp, #192]
	cbz	x1, LBB96_49
LBB96_48:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB96_48
LBB96_49:
	cbz	x21, LBB96_57
	mov	x1, x21
LBB96_51:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	w21, #4
	mov	x1, x23
	cbnz	x23, LBB96_51
	b	LBB96_23
LBB96_52:
	ldp	x20, x22, [sp, #176]
	ldp	x1, x23, [sp, #192]
	cbz	x1, LBB96_54
LBB96_53:
	ldr	x24, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x24
	cbnz	x24, LBB96_53
LBB96_54:
	cbz	x23, LBB96_23
	mov	x1, x23
LBB96_56:
	ldr	x23, [x1, #16]
	ldr	x8, [x1]
	ldr	x9, [x22, #24]
	and	x2, x8, #0xfffffffffffffffe
	mov	x0, x20
	mov	w3, #3
	mov	x4, x19
	blr	x9
	mov	x1, x23
	cbnz	x23, LBB96_56
	b	LBB96_23
LBB96_57:
	mov	w21, #4
	b	LBB96_23
LBB96_58:
	add	x8, sp, #304
	b	LBB96_18
LBB96_59:
	mov	w0, #72
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_60:
	mov	w0, #73
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_61:
	mov	w0, #74
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_62:
	mov	w0, #70
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_63:
	mov	w0, #75
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_64:
	mov	w0, #68
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_65:
	mov	w0, #47
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB96_66:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB96_67:
	mov	x0, x24
	mov	x1, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB96_68:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB96_69:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB96_70:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB96_71:
	bl	___stack_chk_fail
LBB96_72:
	mov	x0, x21
	mov	x1, x24
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh593, Lloh594, Lloh595
	.loh AdrpAdd	Lloh596, Lloh597
	.loh AdrpLdrGotLdr	Lloh598, Lloh599, Lloh600
	.loh AdrpAdd	Lloh601, Lloh602
	.loh AdrpAdd	Lloh603, Lloh604
	.loh AdrpAdd	Lloh605, Lloh606
	.cfi_endproc
	.section	__TEXT,__const
LJTI96_0:
	.byte	(LBB96_29-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_47-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_36-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_36-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_36-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_30-LBB96_29)>>2
	.byte	(LBB96_65-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_36-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_64-LBB96_29)>>2
	.byte	(LBB96_52-LBB96_29)>>2
	.byte	(LBB96_62-LBB96_29)>>2
	.byte	(LBB96_42-LBB96_29)>>2
	.byte	(LBB96_59-LBB96_29)>>2
	.byte	(LBB96_60-LBB96_29)>>2
	.byte	(LBB96_61-LBB96_29)>>2
	.byte	(LBB96_63-LBB96_29)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.processSetCurrentPath:
	.cfi_startproc
	stp	x28, x27, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w27, -40
	.cfi_offset w28, -48
	.cfi_remember_state
	sub	sp, sp, #1104
Lloh607:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh608:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh609:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB97_25
	tst	x0, #0x7
	b.ne	LBB97_26
	mov	x19, x2
	mov	x20, x1
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #80
	add	x3, sp, #32
	mov	x1, x20
	mov	x2, x19
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-64]
	cbnz	w0, LBB97_22
	ldur	x19, [x29, #-80]
	sub	x0, x29, #56
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-48]
	cbnz	w0, LBB97_22
	ldur	x20, [x29, #-56]
LBB97_5:
	mov	x0, x19
	bl	_chdir
	cmn	w0, #1
	b.ne	LBB97_13
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB97_24
	cmp	w8, #16, lsl #12
	b.hs	LBB97_24
	cmp	w8, #4
	b.ne	LBB97_10
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB97_5
	b	LBB97_22
LBB97_10:
	cmp	w8, #92
	b.hi	LBB97_12
	mov	w8, w8
Lloh610:
	adrp	x9, LJTI97_0@PAGE
Lloh611:
	add	x9, x9, LJTI97_0@PAGEOFF
	adr	x10, LBB97_12
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB97_12:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB97_22
LBB97_13:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB97_22
LBB97_14:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #40
	b	LBB97_22
LBB97_15:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #39
	b	LBB97_22
LBB97_16:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB97_22
LBB97_17:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #44
	b	LBB97_22
LBB97_18:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #43
	b	LBB97_22
LBB97_19:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #4
	b	LBB97_22
LBB97_20:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #50
	b	LBB97_22
LBB97_21:
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #37
LBB97_22:
	ldur	x8, [x29, #-40]
Lloh612:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh613:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh614:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB97_27
	add	sp, sp, #1104
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x28, x27, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB97_24:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB97_25:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB97_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB97_27:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh607, Lloh608, Lloh609
	.loh AdrpAdd	Lloh610, Lloh611
	.loh AdrpLdrGotLdr	Lloh612, Lloh613, Lloh614
	.cfi_endproc
	.section	__TEXT,__const
LJTI97_0:
	.byte	(LBB97_13-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_15-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_20-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_19-LBB97_12)>>2
	.byte	(LBB97_16-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_14-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_21-LBB97_12)>>2
	.byte	(LBB97_18-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_12-LBB97_12)>>2
	.byte	(LBB97_17-LBB97_12)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.processSetCurrentDir:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
Lloh615:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh616:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh617:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-24]
	cbz	x0, LBB98_26
	tst	x0, #0x7
	b.ne	LBB98_27
	ldr	w19, [x1]
	cmn	w19, #2
	b.eq	LBB98_19
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #32]
	cbnz	w0, LBB98_22
	ldr	x20, [sp, #24]
LBB98_5:
	mov	x0, x19
	bl	_fchdir
	cmn	w0, #1
	b.ne	LBB98_18
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB98_25
	cmp	w8, #16, lsl #12
	b.hs	LBB98_25
	cmp	w8, #4
	b.ne	LBB98_10
	str	x20, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB98_5
	b	LBB98_22
LBB98_10:
	cmp	w8, #8
	b.le	LBB98_15
	cmp	w8, #9
	b.eq	LBB98_21
	cmp	w8, #13
	b.eq	LBB98_24
	cmp	w8, #20
	b.ne	LBB98_21
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #40
	ldur	x8, [x29, #-24]
Lloh618:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh619:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh620:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB98_23
	b	LBB98_20
LBB98_15:
	cbz	w8, LBB98_18
	cmp	w8, #5
	b.ne	LBB98_21
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #50
	ldur	x8, [x29, #-24]
Lloh621:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh622:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh623:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB98_23
	b	LBB98_20
LBB98_18:
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
LBB98_19:
	mov	w0, #0
	ldur	x8, [x29, #-24]
Lloh624:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh625:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh626:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB98_23
LBB98_20:
	bl	___stack_chk_fail
LBB98_21:
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
LBB98_22:
	ldur	x8, [x29, #-24]
Lloh627:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh628:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh629:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB98_20
LBB98_23:
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB98_24:
	.cfi_restore_state
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	ldur	x8, [x29, #-24]
Lloh630:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh631:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh632:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB98_23
	b	LBB98_20
LBB98_25:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB98_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB98_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdrGotLdr	Lloh615, Lloh616, Lloh617
	.loh AdrpLdrGotLdr	Lloh618, Lloh619, Lloh620
	.loh AdrpLdrGotLdr	Lloh621, Lloh622, Lloh623
	.loh AdrpLdrGotLdr	Lloh624, Lloh625, Lloh626
	.loh AdrpLdrGotLdr	Lloh627, Lloh628, Lloh629
	.loh AdrpLdrGotLdr	Lloh630, Lloh631, Lloh632
	.cfi_endproc

	.p2align	2
l_Io.Threaded.processCurrentPath:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh633:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh634:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh635:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	cbz	x0, LBB99_4
	tst	x0, #0x7
	b.ne	LBB99_5
	add	x0, sp, #8
	bl	l_Io.Threaded.processCurrentPathPosix
	ldur	q0, [sp, #8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh636:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh637:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh638:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB99_6
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB99_4:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB99_5:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB99_6:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh633, Lloh634, Lloh635
	.loh AdrpLdrGotLdr	Lloh636, Lloh637, Lloh638
	.cfi_endproc

	.p2align	2
l_Io.Threaded.unlockStderr:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB100_17
	mov	x19, x0
	tst	x0, #0x7
	b.ne	LBB100_18
	ldrh	w8, [x19, #824]
	cbnz	w8, LBB100_4
	ldr	x8, [x19, #784]
	ldr	x8, [x8, #16]
	add	x0, x19, #784
	blr	x8
	ldrh	w8, [x19, #824]
LBB100_4:
	cbz	w8, LBB100_8
	cmp	w8, #2
	b.ne	LBB100_7
	bl	l_Io.Threaded.recancelInner
LBB100_7:
	strh	wzr, [x19, #824]
LBB100_8:
	mov	w8, #1
	str	x8, [x19, #792]
	movi.2d	v0, #0000000000000000
	str	q0, [x19, #800]
	ldr	x8, [x19, #728]
	subs	x8, x8, #1
	b.lo	LBB100_19
	str	x8, [x19, #728]
	cbz	x8, LBB100_11
LBB100_10:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB100_11:
	.cfi_restore_state
	.cfi_remember_state
	mov	x8, #-1
	str	x8, [x19, #736]
	add	x8, x19, #832
	swpl	wzr, w8, [x8]
	cbz	w8, LBB100_15
	cmp	w8, #1
	b.eq	LBB100_10
	cmp	w8, #2
	b.eq	LBB100_16
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB100_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB100_16:
	add	x0, x19, #832
	mov	w1, #1
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	b	l_Io.Threaded.Thread.futexWake
LBB100_17:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB100_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB100_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.tryLockStderr:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x19, x8
Lloh639:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh640:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh641:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #40]
	cbz	x0, LBB101_17
	mov	x21, x0
	tst	x0, #0x7
	b.ne	LBB101_18
	mov	x20, x1
Lloh642:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh643:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x8, [x0]
	cbz	x8, LBB101_6
	ldr	x8, [x8, #8]
	ldr	x9, [x21, #736]
	cmp	x9, x8
	b.ne	LBB101_8
LBB101_4:
	ldr	x8, [x21, #728]
	adds	x8, x8, #1
	b.lo	LBB101_11
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB101_6:
	mov	x8, #-6148914691236517206
	str	x8, [sp, #8]
	add	x1, sp, #8
	mov	x0, #0
	bl	_pthread_threadid_np
	cbnz	w0, LBB101_19
	ldr	x8, [sp, #8]
	ldr	x9, [x21, #736]
	cmp	x9, x8
	b.eq	LBB101_4
LBB101_8:
	mov	w9, #0
	add	x10, x21, #832
	mov	w11, #1
	casa	w9, w11, [x10]
	cmp	w9, #0
	b.ne	LBB101_13
	ldr	x9, [x21, #728]
	cbnz	x9, LBB101_19
	str	x8, [x21, #736]
	mov	w8, #1
LBB101_11:
	str	x8, [x21, #728]
	add	x0, sp, #16
	mov	x1, x21
	mov	x2, x20
	bl	l_Io.Threaded.initLockedStderr
	ldrh	w8, [sp, #32]
	cbnz	w8, LBB101_15
	ldr	q0, [sp, #16]
	str	q0, [x19]
	mov	w8, #1
	strb	w8, [x19, #16]
	strh	wzr, [x19, #24]
	ldr	x8, [sp, #40]
Lloh644:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh645:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh646:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB101_14
	b	LBB101_16
LBB101_13:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x19]
	ldr	x8, [sp, #40]
Lloh647:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh648:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh649:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB101_16
LBB101_14:
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB101_15:
	.cfi_restore_state
	strh	w8, [x19, #24]
	ldr	x8, [sp, #40]
Lloh650:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh651:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh652:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB101_14
LBB101_16:
	bl	___stack_chk_fail
LBB101_17:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB101_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB101_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh639, Lloh640, Lloh641
	.loh AdrpLdr	Lloh642, Lloh643
	.loh AdrpLdrGotLdr	Lloh644, Lloh645, Lloh646
	.loh AdrpLdrGotLdr	Lloh647, Lloh648, Lloh649
	.loh AdrpLdrGotLdr	Lloh650, Lloh651, Lloh652
	.cfi_endproc

	.p2align	2
l_Io.Threaded.recancelInner:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
Lloh653:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh654:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x8, [x0]
	cbz	x8, LBB102_10
	add	x8, x8, #24
	mov	w9, #1
	ldeor	x9, x8, [x8]
	and	w8, w8, #0x7
	cmp	w8, #7
	b.ne	LBB102_3
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB102_3:
	.cfi_restore_state
	cmp	w8, #2
	b.le	LBB102_6
	cmp	w8, #4
	b.gt	LBB102_8
	cmp	w8, #3
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB102_6:
	cbz	w8, LBB102_9
	cmp	w8, #1
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB102_8:
	cmp	w8, #5
LBB102_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB102_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
	.loh AdrpLdr	Lloh653, Lloh654
	.cfi_endproc

	.p2align	2
l_Io.Threaded.initLockedStderr:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
Lloh655:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh656:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh657:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	ldrb	w8, [x1, #856]
	tbz	w8, #0, LBB103_3
LBB103_1:
	strh	wzr, [x0, #16]
	add	x8, x1, #760
	str	x8, [x0]
	ldrb	w8, [x2, #1]
	add	x9, x1, #855
	tst	w8, #0x1
	csel	x8, x2, x9, ne
	ldrb	w8, [x8]
	strb	w8, [x0, #8]
	ldr	x8, [sp, #24]
Lloh658:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh659:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh660:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB103_31
LBB103_2:
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB103_3:
	.cfi_restore_state
	mov	w8, #0
	str	x1, [x1, #760]
Lloh661:
	adrp	x9, l___anon_3542@PAGE
Lloh662:
	add	x9, x9, l___anon_3542@PAGEOFF
	str	x9, [x1, #768]
	mov	w9, #1
	strb	w9, [x1, #856]
	add	x10, x1, #836
	casa	w8, w9, [x10]
	cmp	w8, #0
	b.ne	LBB103_14
LBB103_4:
	ldrb	w8, [x1, #859]
	tbz	w8, #0, LBB103_9
	add	x8, x1, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB103_13
	cmp	w8, #1
	b.ne	LBB103_11
LBB103_7:
	ldrb	w8, [x2, #1]
	tbz	w8, #0, LBB103_19
LBB103_8:
	ldrb	w8, [x2]
	strb	w8, [x1, #855]
	b	LBB103_1
LBB103_9:
	mov	x19, x2
	mov	x20, x0
	add	x0, x1, #584
	mov	x21, x1
	bl	l_Io.Threaded.Environ.scan
	mov	w8, #1
	strb	w8, [x21, #859]
	add	x8, x21, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB103_13
	mov	x1, x21
	cmp	w8, #1
	mov	x0, x20
	mov	x2, x19
	b.eq	LBB103_7
LBB103_11:
	cmp	w8, #2
	b.eq	LBB103_18
LBB103_12:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB103_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB103_14:
	cmp	w8, #2
	b.eq	LBB103_32
	add	x8, x1, #836
	mov	w20, #2
	swpa	w20, w8, [x8]
	cbz	w8, LBB103_4
LBB103_16:
Lloh663:
	adrp	x19, l___anon_2803@PAGE
Lloh664:
	add	x19, x19, l___anon_2803@PAGEOFF
LBB103_17:
	add	x24, x1, #836
	mov	x21, x0
	add	x0, x1, #836
	mov	x22, x1
	mov	w1, #2
	mov	x23, x2
	mov	x2, x19
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x1, x22
	mov	x2, x23
	mov	x0, x21
	swpa	w20, w8, [x24]
	cbnz	w8, LBB103_17
	b	LBB103_4
LBB103_18:
	mov	x19, x0
	add	x0, x1, #836
	mov	x20, x1
	mov	w1, #1
	mov	x21, x2
	bl	l_Io.Threaded.Thread.futexWake
	mov	x1, x20
	mov	x2, x21
	mov	x0, x19
	ldrb	w8, [x21, #1]
	tbnz	w8, #0, LBB103_8
LBB103_19:
	ldrb	w8, [x1, #695]
	ldrb	w9, [x1, #694]
Lloh665:
	adrp	x10, l___anon_9159@PAGE
Lloh666:
	add	x10, x10, l___anon_9159@PAGEOFF
Lloh667:
	adrp	x11, l___anon_9158@PAGE
Lloh668:
	add	x11, x11, l___anon_9158@PAGEOFF
	tst	w8, #0x1
	csel	x8, x11, x10, ne
Lloh669:
	adrp	x10, l___anon_9157@PAGE
Lloh670:
	add	x10, x10, l___anon_9157@PAGEOFF
	tst	w9, #0x1
	csel	x8, x10, x8, ne
	ldrb	w20, [x8, #1]
	ldrb	w21, [x8]
	tbz	w20, #0, LBB103_22
	tbnz	w21, #0, LBB103_22
	strb	wzr, [x1, #855]
	b	LBB103_1
LBB103_22:
	mov	x23, x2
	mov	x22, x0
	mov	x24, x1
	ldr	w19, [x1, #816]
	add	x0, sp, #20
	mov	x1, x19
	bl	l_Io.Threaded.isTty
	ldrh	w8, [sp, #20]
	cbnz	w8, LBB103_29
	ldrb	w8, [sp, #22]
	mov	x0, x22
	mov	x2, x23
	mov	x1, x24
	tbz	w8, #0, LBB103_27
	sub	w8, w19, #1
	cmp	w8, #1
	b.hi	LBB103_28
	mov	x0, x1
	bl	l_Io.Threaded.scanEnviron
	mov	x1, x24
	mov	x2, x23
	mov	x0, x22
	ldr	x8, [x24, #664]
	cbz	x8, LBB103_28
	ldr	x1, [x1, #672]
	cmp	x1, #0
	csinc	x0, x8, xzr, ne
Lloh671:
	adrp	x2, l___anon_9566@PAGE
Lloh672:
	add	x2, x2, l___anon_9566@PAGEOFF
	mov	w3, #4
	bl	l_mem.eqlBytes
	mov	x1, x24
	mov	x2, x23
	mov	x8, x0
	mov	x0, x22
	tbz	w8, #0, LBB103_28
LBB103_27:
	and	w8, w20, w21
	and	w8, w8, #0x1
	strb	w8, [x1, #855]
	b	LBB103_1
LBB103_28:
	mov	w8, #1
	strb	w8, [x1, #855]
	b	LBB103_1
LBB103_29:
	cmp	w8, #2
	b.ne	LBB103_33
	strh	w8, [x22, #16]
	ldr	x8, [sp, #24]
Lloh673:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh674:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh675:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB103_2
LBB103_31:
	bl	___stack_chk_fail
LBB103_32:
Lloh676:
	adrp	x8, l___anon_2803@PAGE
Lloh677:
	add	x8, x8, l___anon_2803@PAGEOFF
	mov	x19, x0
	add	x0, x1, #836
	mov	x20, x1
	mov	w1, #2
	mov	x21, x2
	mov	x2, x8
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x1, x20
	mov	x2, x21
	mov	x0, x19
	add	x8, x20, #836
	mov	w20, #2
	swpa	w20, w8, [x8]
	cbnz	w8, LBB103_16
	b	LBB103_4
LBB103_33:
	cmp	w8, #12
	mov	x0, x22
	mov	x2, x23
	mov	x1, x24
	b.eq	LBB103_27
	cmp	w8, #61
	b.ne	LBB103_12
	b	LBB103_27
	.loh AdrpLdrGotLdr	Lloh655, Lloh656, Lloh657
	.loh AdrpLdrGotLdr	Lloh658, Lloh659, Lloh660
	.loh AdrpAdd	Lloh661, Lloh662
	.loh AdrpAdd	Lloh663, Lloh664
	.loh AdrpAdd	Lloh669, Lloh670
	.loh AdrpAdd	Lloh667, Lloh668
	.loh AdrpAdd	Lloh665, Lloh666
	.loh AdrpAdd	Lloh671, Lloh672
	.loh AdrpLdrGotLdr	Lloh673, Lloh674, Lloh675
	.loh AdrpAdd	Lloh676, Lloh677
	.cfi_endproc

	.p2align	2
l_Io.Threaded.lockStderr:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh678:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh679:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh680:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #40]
	cbz	x0, LBB104_20
	mov	x21, x0
	tst	x0, #0x7
	b.ne	LBB104_21
	mov	x20, x1
Lloh681:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh682:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x8, [x0]
	cbz	x8, LBB104_6
	ldr	x23, [x8, #8]
	ldr	x8, [x21, #736]
	cmp	x8, x23
	b.ne	LBB104_8
LBB104_4:
	ldr	x8, [x21, #728]
	adds	x8, x8, #1
	b.lo	LBB104_11
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB104_6:
	mov	x8, #-6148914691236517206
	str	x8, [sp, #8]
	add	x1, sp, #8
	mov	x0, #0
	bl	_pthread_threadid_np
	cbnz	w0, LBB104_22
	ldr	x23, [sp, #8]
	ldr	x8, [x21, #736]
	cmp	x8, x23
	b.eq	LBB104_4
LBB104_8:
	mov	w8, #0
	add	x9, x21, #832
	mov	w10, #1
	casa	w8, w10, [x9]
	cmp	w8, #0
	b.ne	LBB104_13
LBB104_9:
	ldr	x8, [x21, #728]
	cbnz	x8, LBB104_22
	str	x23, [x21, #736]
	mov	w8, #1
LBB104_11:
	str	x8, [x21, #728]
	add	x0, sp, #16
	mov	x1, x21
	mov	x2, x20
	bl	l_Io.Threaded.initLockedStderr
	ldr	q0, [sp, #16]
	str	q0, [x19]
	ldr	x8, [sp, #32]
	str	x8, [x19, #16]
	ldr	x8, [sp, #40]
Lloh683:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh684:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh685:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB104_18
LBB104_12:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB104_13:
	.cfi_restore_state
	cmp	w8, #2
	b.eq	LBB104_19
LBB104_14:
	mov	w24, #2
Lloh686:
	adrp	x22, l___anon_2803@PAGE
Lloh687:
	add	x22, x22, l___anon_2803@PAGEOFF
LBB104_15:
	add	x8, x21, #832
	swpa	w24, w8, [x8]
	cbz	w8, LBB104_9
	add	x0, x21, #832
	mov	w1, #2
	mov	w2, #0
	mov	x3, x22
	bl	l_Io.Threaded.Thread.futexWaitInner
	tst	w0, #0xffff
	b.eq	LBB104_15
LBB104_17:
	strh	w0, [x19, #16]
	ldr	x8, [sp, #40]
Lloh688:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh689:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh690:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB104_12
LBB104_18:
	bl	___stack_chk_fail
LBB104_19:
Lloh691:
	adrp	x3, l___anon_2803@PAGE
Lloh692:
	add	x3, x3, l___anon_2803@PAGEOFF
	add	x0, x21, #832
	mov	w1, #2
	mov	w2, #0
	bl	l_Io.Threaded.Thread.futexWaitInner
	tst	w0, #0xffff
	b.eq	LBB104_14
	b	LBB104_17
LBB104_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB104_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB104_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh678, Lloh679, Lloh680
	.loh AdrpLdr	Lloh681, Lloh682
	.loh AdrpLdrGotLdr	Lloh683, Lloh684, Lloh685
	.loh AdrpAdd	Lloh686, Lloh687
	.loh AdrpLdrGotLdr	Lloh688, Lloh689, Lloh690
	.loh AdrpAdd	Lloh691, Lloh692
	.cfi_endproc

	.p2align	2
l_Io.Threaded.processExecutablePath:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	sub	sp, sp, #1072
	mov	x19, x8
Lloh693:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh694:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh695:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-56]
	cbz	x0, LBB105_14
	mov	x22, x0
	tst	x0, #0x7
	b.ne	LBB105_15
	mov	x20, x2
	mov	x21, x1
	mov	w23, #1025
	add	x0, sp, #23
	mov	w1, #170
	mov	w2, #1025
	bl	_memset
	str	w23, [sp, #12]
	add	x0, sp, #23
	add	x1, sp, #12
	bl	__NSGetExecutablePath
	cbz	w0, LBB105_4
Lloh696:
	adrp	x8, l___anon_10273@PAGE
Lloh697:
	add	x8, x8, l___anon_10273@PAGEOFF
Lloh698:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-56]
Lloh699:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh700:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh701:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB105_9
	b	LBB105_13
LBB105_4:
	mov	w23, #1025
	sub	x0, x29, #72
	add	x1, sp, #23
	mov	w2, #1025
	mov	w3, #0
	bl	l_mem.findScalar__func_124
	ldurb	w8, [x29, #-64]
	ldur	x9, [x29, #-72]
	tst	w8, #0x1
	csel	x3, x9, x23, ne
	cmp	x3, #1026
	b.hs	LBB105_16
	cbz	x3, LBB105_17
	ldrb	w8, [sp, #23]
	cmp	w8, #47
	b.ne	LBB105_17
	mov	w8, #-2
	str	w8, [sp, #16]
	sub	x8, x29, #72
	add	x1, sp, #16
	add	x2, sp, #23
	mov	x0, x22
	mov	x4, x21
	mov	x5, x20
	bl	l_Io.Threaded.dirRealPathFilePosix
	ldurh	w8, [x29, #-64]
	cbnz	w8, LBB105_10
	ldur	x8, [x29, #-72]
	str	x8, [x19]
	strh	wzr, [x19, #8]
	ldur	x8, [x29, #-56]
Lloh702:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh703:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh704:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB105_13
LBB105_9:
	add	sp, sp, #1072
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB105_10:
	.cfi_restore_state
	cmp	w8, #22
	b.eq	LBB105_19
	cmp	w8, #42
	b.eq	LBB105_18
	strh	w8, [x19, #8]
	ldur	x8, [x29, #-56]
Lloh705:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh706:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh707:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB105_9
LBB105_13:
	bl	___stack_chk_fail
LBB105_14:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB105_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB105_16:
	mov	x0, x3
	mov	w1, #1025
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB105_17:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB105_18:
	mov	w0, #42
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB105_19:
	mov	w0, #22
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
	.loh AdrpLdrGotLdr	Lloh693, Lloh694, Lloh695
	.loh AdrpLdrGotLdr	Lloh699, Lloh700, Lloh701
	.loh AdrpAddLdr	Lloh696, Lloh697, Lloh698
	.loh AdrpLdrGotLdr	Lloh702, Lloh703, Lloh704
	.loh AdrpLdrGotLdr	Lloh705, Lloh706, Lloh707
	.cfi_endproc

	.p2align	2
l_Io.Threaded.processExecutableOpen:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	.cfi_remember_state
	sub	sp, sp, #1088
	mov	x19, x8
Lloh708:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh709:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh710:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB106_8
	mov	x21, x0
	tst	x0, #0x7
	b.ne	LBB106_9
	mov	x20, x1
	mov	w22, #1025
	add	x0, sp, #39
	mov	w1, #170
	mov	w2, #1025
	bl	_memset
	str	w22, [sp, #16]
	add	x0, sp, #39
	add	x1, sp, #16
	bl	__NSGetExecutablePath
	cbz	w0, LBB106_5
	mov	w8, #43
	str	w8, [x19, #8]
	str	xzr, [x19]
	ldur	x8, [x29, #-56]
Lloh711:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh712:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh713:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB106_7
LBB106_4:
	add	sp, sp, #1088
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x28, x27, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB106_5:
	.cfi_restore_state
	mov	w22, #1025
	sub	x0, x29, #72
	add	x1, sp, #39
	mov	w2, #1025
	mov	w3, #0
	bl	l_mem.findScalar__func_124
	ldurb	w8, [x29, #-64]
	ldur	x9, [x29, #-72]
	tst	w8, #0x1
	csel	x3, x9, x22, ne
	cmp	x3, #1026
	b.hs	LBB106_10
	mov	w8, #-2
	str	w8, [sp, #20]
	add	x8, sp, #24
	add	x1, sp, #20
	add	x2, sp, #39
	mov	x0, x21
	mov	x4, x20
	bl	l_Io.Threaded.dirOpenFilePosix
	ldr	x8, [sp, #24]
	str	x8, [x19]
	ldr	w8, [sp, #32]
	str	w8, [x19, #8]
	ldur	x8, [x29, #-56]
Lloh714:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh715:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh716:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB106_4
LBB106_7:
	bl	___stack_chk_fail
LBB106_8:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB106_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB106_10:
	mov	x0, x3
	mov	w1, #1025
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh708, Lloh709, Lloh710
	.loh AdrpLdrGotLdr	Lloh711, Lloh712, Lloh713
	.loh AdrpLdrGotLdr	Lloh714, Lloh715, Lloh716
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileMemoryMapWrite:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x26, x25, [sp, #64]
	stp	x24, x23, [sp, #80]
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
Lloh717:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh718:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh719:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #56]
	cbz	x0, LBB107_36
	tst	x0, #0x7
	b.ne	LBB107_37
	ldrb	w8, [x1, #32]
	cbz	w8, LBB107_6
LBB107_3:
	mov	w0, #0
LBB107_4:
	ldr	x8, [sp, #56]
Lloh720:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh721:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh722:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB107_38
	.cfi_def_cfa wsp, 144
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	ldp	x24, x23, [sp, #80]
	ldp	x26, x25, [sp, #64]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB107_6:
	.cfi_restore_state
	ldr	w20, [x1, #24]
	ldp	x23, x19, [x1, #8]
	ldr	x24, [x1]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB107_4
	mov	x21, #0
	ldr	x22, [sp, #40]
Lloh723:
	adrp	x25, LJTI107_0@PAGE
Lloh724:
	add	x25, x25, LJTI107_0@PAGEOFF
	mov	x1, x23
LBB107_8:
	subs	x2, x19, x21
	b.eq	LBB107_20
	adds	x3, x24, x21
	b.hs	LBB107_33
	tbnz	x3, #63, LBB107_34
	mov	x0, x20
	bl	_pwrite
	cmn	x0, #1
	b.eq	LBB107_15
LBB107_12:
	adds	x21, x21, x0
	b.hs	LBB107_33
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.ne	LBB107_4
LBB107_14:
	add	x1, x23, x21
	cmp	x21, x19
	b.ls	LBB107_8
	b	LBB107_35
LBB107_15:
	mov	x26, x0
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB107_34
	cmp	w8, #16, lsl #12
	b.hs	LBB107_34
	cmp	w8, #84
	b.hi	LBB107_21
	mov	x0, x26
	adr	x9, LBB107_12
	ldrb	w10, [x25, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB107_19:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB107_14
	b	LBB107_4
LBB107_20:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	b	LBB107_3
LBB107_21:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB107_4
LBB107_22:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #57
	b	LBB107_4
LBB107_23:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #19
	b	LBB107_4
LBB107_24:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #9
	b	LBB107_4
LBB107_25:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #17
	b	LBB107_4
LBB107_26:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #16
	b	LBB107_4
LBB107_27:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
	b	LBB107_4
LBB107_28:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #14
	b	LBB107_4
LBB107_29:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #22
	b	LBB107_4
LBB107_30:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #20
	b	LBB107_4
LBB107_31:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #15
	b	LBB107_4
LBB107_32:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #3
	b	LBB107_4
LBB107_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB107_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB107_35:
	mov	x0, x21
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB107_36:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB107_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB107_38:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh717, Lloh718, Lloh719
	.loh AdrpLdrGotLdr	Lloh720, Lloh721, Lloh722
	.loh AdrpAdd	Lloh723, Lloh724
	.cfi_endproc
	.section	__TEXT,__const
LJTI107_0:
	.byte	(LBB107_12-LBB107_12)>>2
	.byte	(LBB107_27-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_19-LBB107_12)>>2
	.byte	(LBB107_32-LBB107_12)>>2
	.byte	(LBB107_22-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_30-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_25-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_29-LBB107_12)>>2
	.byte	(LBB107_31-LBB107_12)>>2
	.byte	(LBB107_26-LBB107_12)>>2
	.byte	(LBB107_22-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_23-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_24-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_28-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_21-LBB107_12)>>2
	.byte	(LBB107_22-LBB107_12)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.fileMemoryMapRead:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB108_5
	tst	x0, #0x7
	b.ne	LBB108_6
	ldrb	w8, [x1, #32]
	cbz	w8, LBB108_4
	mov	w0, #0
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB108_4:
	.cfi_restore_state
	.cfi_remember_state
	ldr	w0, [x1, #24]
	ldp	x8, x2, [x1, #8]
	ldr	x3, [x1]
	mov	x1, x8
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.mmSyncRead
LBB108_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB108_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.mmSyncRead:
	.cfi_startproc
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x28, x27, [sp, #80]
	stp	x26, x25, [sp, #96]
	stp	x24, x23, [sp, #112]
	stp	x22, x21, [sp, #128]
	stp	x20, x19, [sp, #144]
	stp	x29, x30, [sp, #160]
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x20, x3
	mov	x19, x2
	mov	x21, x1
	mov	x22, x0
Lloh725:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh726:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh727:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #72]
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #64]
	cbnz	w0, LBB109_25
	mov	x23, #0
	ldr	x26, [sp, #56]
Lloh728:
	adrp	x27, LJTI109_0@PAGE
Lloh729:
	add	x27, x27, LJTI109_0@PAGEOFF
	mov	x24, x21
LBB109_2:
	subs	x25, x19, x23
	b.eq	LBB109_17
	adds	x3, x20, x23
	b.hs	LBB109_28
	tbnz	x3, #63, LBB109_27
	mov	x0, x22
	mov	x1, x24
	mov	x2, x25
	bl	_pread
	cmn	x0, #1
	b.eq	LBB109_10
	tbnz	x0, #63, LBB109_27
	cbz	x0, LBB109_19
	adds	x23, x23, x0
	b.hs	LBB109_28
	str	x26, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB109_15
	b	LBB109_25
LBB109_10:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB109_27
	cmp	w8, #16, lsl #12
	b.hs	LBB109_27
	cmp	w8, #84
	b.hi	LBB109_18
	adr	x9, LBB109_14
	ldrb	w10, [x27, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB109_14:
	str	x26, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.ne	LBB109_25
LBB109_15:
	add	x24, x21, x23
	cmp	x23, x19
	b.ls	LBB109_2
	mov	x0, x23
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB109_17:
	str	x26, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB109_25
LBB109_18:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB109_25
LBB109_19:
	str	x26, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x24
	mov	x1, x25
	bl	_bzero
	mov	w0, #0
	b	LBB109_25
LBB109_20:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #57
	b	LBB109_25
LBB109_21:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #4
	b	LBB109_25
LBB109_22:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #5
	b	LBB109_25
LBB109_23:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #3
	b	LBB109_25
LBB109_24:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #9
LBB109_25:
	ldr	x8, [sp, #72]
Lloh730:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh731:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh732:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB109_29
	.cfi_def_cfa wsp, 176
	ldp	x29, x30, [sp, #160]
	ldp	x20, x19, [sp, #144]
	ldp	x22, x21, [sp, #128]
	ldp	x24, x23, [sp, #112]
	ldp	x26, x25, [sp, #96]
	ldp	x28, x27, [sp, #80]
	add	sp, sp, #176
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB109_27:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB109_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB109_29:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh725, Lloh726, Lloh727
	.loh AdrpAdd	Lloh728, Lloh729
	.loh AdrpLdrGotLdr	Lloh730, Lloh731, Lloh732
	.cfi_endproc
	.section	__TEXT,__const
LJTI109_0:
	.byte	(LBB109_27-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_14-LBB109_14)>>2
	.byte	(LBB109_23-LBB109_14)>>2
	.byte	(LBB109_20-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_21-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_22-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_20-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_24-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_21-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_14-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_18-LBB109_14)>>2
	.byte	(LBB109_20-LBB109_14)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.fileMemoryMapSetLength:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	cbz	x0, LBB110_20
	tst	x0, #0x7
	b.ne	LBB110_18
	mov	x19, x2
	ldr	x20, [x1, #16]
	ldrb	w8, [x1, #32]
	cbz	w8, LBB110_7
	mov	w8, #16383
	adds	x8, x19, x8
	b.hs	LBB110_19
	mov	w9, #16383
	adds	x9, x20, x9
	b.hs	LBB110_19
	eor	x8, x9, x8
	cmp	x8, #4, lsl #12
	b.hs	LBB110_11
	mov	w0, #0
	str	x19, [x1, #16]
	b	LBB110_17
LBB110_7:
	mov	x25, x1
	ldr	x21, [x1, #8]
	ldr	x22, [x0, #744]
	ldr	x26, [x0, #752]
	xpaci	x30
	ldr	x8, [x26, #16]
	mov	x0, x22
	mov	x1, x21
	mov	x2, x20
	mov	w3, #14
	mov	x4, x19
	mov	x23, x30
	mov	x5, x30
	blr	x8
	cbz	x0, LBB110_12
	mov	x8, x0
	cbz	x19, LBB110_10
	and	x9, x8, #0x3fff
	cbnz	x9, LBB110_18
LBB110_10:
	mov	w0, #0
	stp	x8, x19, [x25, #8]
	b	LBB110_17
LBB110_11:
	mov	w0, #49
	b	LBB110_17
LBB110_12:
	ldr	x8, [x26]
	mov	x0, x22
	mov	x1, x19
	mov	w2, #14
	mov	x3, x23
	blr	x8
	cbz	x0, LBB110_16
	tst	x0, #0x3fff
	b.ne	LBB110_18
	cmp	x19, x20
	csel	x2, x19, x20, lo
	add	x8, x0, x2
	add	x9, x21, x2
	cmp	x0, x9
	ccmp	x21, x8, #2, lo
	b.lo	LBB110_21
	mov	x24, x0
	mov	x1, x21
	bl	_memcpy
	stp	x24, x19, [x25, #8]
	ldr	x8, [x26, #24]
	mov	x0, x22
	mov	x1, x21
	mov	x2, x20
	mov	w3, #14
	mov	x4, x23
	blr	x8
	mov	w0, #0
	b	LBB110_17
LBB110_16:
	mov	w0, #64
LBB110_17:
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB110_18:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB110_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB110_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB110_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileMemoryMapDestroy:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB111_12
	tst	x0, #0x7
	b.ne	LBB111_13
	mov	x19, x1
	ldr	x1, [x1, #8]
	ldr	x2, [x19, #16]
	ldrb	w8, [x19, #32]
	cbz	w8, LBB111_8
	cbz	x2, LBB111_10
	mov	x0, x1
	mov	x1, x2
	bl	_munmap
	cmn	w0, #1
	b.ne	LBB111_9
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB111_7
	cmp	w8, #16, lsl #12
	b.lo	LBB111_9
LBB111_7:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB111_8:
	ldr	x8, [x0, #744]
	ldr	x9, [x0, #752]
	xpaci	x30
	ldr	x9, [x9, #24]
	mov	x0, x8
	mov	w3, #14
	mov	x4, x30
	blr	x9
LBB111_9:
	mov	x8, #-6148914691236517206
	str	x8, [x19, #32]
	movi.16b	v0, #170
	stp	q0, q0, [x19]
	.cfi_def_cfa wsp, 32
	b	LBB111_11
LBB111_10:
	.cfi_restore_state
	.cfi_remember_state
	.cfi_def_cfa wsp, 32
LBB111_11:
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB111_12:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB111_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileMemoryMapCreate:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x28, x27, [sp, #48]
	stp	x26, x25, [sp, #64]
	stp	x24, x23, [sp, #80]
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
Lloh733:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh734:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh735:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #40]
	cbz	x0, LBB112_37
	mov	x24, x0
	tst	x0, #0x7
	b.ne	LBB112_36
	mov	x21, x30
	mov	x22, x1
	ldp	x20, x23, [x2]
	ldrb	w27, [x2, #17]
	ldrb	w8, [x24, #857]
	tbz	w8, #0, LBB112_9
LBB112_3:
	ldr	x25, [x24, #744]
	ldr	x26, [x24, #752]
	xpaci	x21
	ldr	x8, [x26]
	mov	x0, x25
	mov	x1, x20
	mov	w2, #14
	mov	x3, x21
	blr	x8
	cbz	x0, LBB112_20
	mov	x24, x0
	tbnz	w27, #0, LBB112_6
	ldr	w0, [x22]
	mov	x1, x24
	mov	x2, x20
	mov	x3, x23
	bl	l_Io.Threaded.mmSyncRead
	tst	w0, #0xffff
	b.ne	LBB112_32
LBB112_6:
	strh	wzr, [x19, #40]
	ldr	x8, [x22]
	str	x8, [x19, #24]
	str	x23, [x19]
	cbz	x20, LBB112_8
	and	x8, x24, #0x3fff
	cbnz	x8, LBB112_36
LBB112_8:
	stp	x24, x20, [x19, #8]
	strb	wzr, [x19, #32]
	ldr	x8, [sp, #40]
Lloh736:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh737:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh738:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB112_28
	b	LBB112_33
LBB112_9:
	tbnz	x23, #63, LBB112_22
	str	w27, [sp, #4]
	ldrb	w28, [x2, #16]
	ldr	w25, [x22]
LBB112_11:
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #32]
	cbnz	w8, LBB112_30
	ldr	x27, [sp, #24]
	and	w2, w28, #0x7
	mov	x0, #0
	mov	x1, x20
	mov	w3, #1
	mov	x4, x25
	mov	x5, x23
	bl	_mmap
	mov	x26, x0
	str	x27, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	cmn	x26, #1
	b.ne	LBB112_24
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB112_34
	cmp	w8, #16, lsl #12
	b.hs	LBB112_34
	cmp	w8, #4
	b.eq	LBB112_11
	cmp	w8, #13
	b.eq	LBB112_26
	cmp	w8, #84
	b.eq	LBB112_23
	cbz	w8, LBB112_35
	ldr	w27, [sp, #4]
	b	LBB112_3
LBB112_20:
Lloh739:
	adrp	x8, l___anon_9350@PAGE
Lloh740:
	add	x8, x8, l___anon_9350@PAGEOFF
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldr	q0, [x8, #32]
	str	q0, [x19, #32]
	ldr	x8, [sp, #40]
Lloh741:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh742:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh743:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB112_33
	.cfi_def_cfa wsp, 144
	b	LBB112_29
LBB112_22:
	.cfi_restore_state
	.cfi_remember_state
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #32]
	cbnz	w8, LBB112_31
LBB112_23:
	mov	w8, #57
	b	LBB112_27
LBB112_24:
	tst	x26, #0x3fff
	b.ne	LBB112_36
	ldr	x8, [x22]
	stp	x23, x26, [x19]
	stp	x20, x8, [x19, #16]
	mov	w8, #1
	strb	w8, [x19, #32]
	strh	wzr, [x19, #40]
	ldr	x8, [sp, #40]
Lloh744:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh745:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh746:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB112_28
	b	LBB112_33
LBB112_26:
	mov	w8, #10
LBB112_27:
	strh	w8, [x19, #40]
	ldr	x8, [sp, #40]
Lloh747:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh748:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh749:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB112_33
LBB112_28:
	.cfi_def_cfa wsp, 144
LBB112_29:
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	ldp	x24, x23, [sp, #80]
	ldp	x26, x25, [sp, #64]
	ldp	x28, x27, [sp, #48]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB112_30:
	.cfi_restore_state
	ldr	w27, [sp, #4]
LBB112_31:
	mov	w9, w8
	cmp	w8, #57
	mov	w10, #1
	lsl	x9, x10, x9
	mov	x10, #1028
	movk	x10, #512, lsl #48
	and	x9, x9, x10
	ccmp	x9, #0, #4, ls
	b.ne	LBB112_27
	b	LBB112_3
LBB112_32:
	ldr	x8, [x26, #24]
	mov	x22, x0
	mov	x0, x25
	mov	x1, x24
	mov	x2, x20
	mov	w3, #14
	mov	x4, x21
	blr	x8
	strh	w22, [x19, #40]
	ldr	x8, [sp, #40]
Lloh750:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh751:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh752:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB112_28
LBB112_33:
	bl	___stack_chk_fail
LBB112_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB112_35:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB112_36:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB112_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
	.loh AdrpLdrGotLdr	Lloh733, Lloh734, Lloh735
	.loh AdrpLdrGotLdr	Lloh736, Lloh737, Lloh738
	.loh AdrpLdrGotLdr	Lloh741, Lloh742, Lloh743
	.loh AdrpAdd	Lloh739, Lloh740
	.loh AdrpLdrGotLdr	Lloh744, Lloh745, Lloh746
	.loh AdrpLdrGotLdr	Lloh747, Lloh748, Lloh749
	.loh AdrpLdrGotLdr	Lloh750, Lloh751, Lloh752
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileHardLink:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #49
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileDowngradeLock:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh753:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh754:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh755:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB114_15
	tst	x0, #0x7
	b.ne	LBB114_16
	ldr	w19, [x1]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w20, [sp, #48]
	cbnz	w20, LBB114_12
	ldr	x21, [sp, #40]
	add	x22, sp, #16
LBB114_4:
	mov	x0, x19
	mov	w1, #5
	bl	_flock
	cmn	w0, #1
	b.ne	LBB114_10
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB114_14
	cmp	w8, #16, lsl #12
	b.hs	LBB114_14
	cmp	w8, #4
	b.ne	LBB114_9
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w20, w0, #0xffff
	b.eq	LBB114_4
	b	LBB114_12
LBB114_9:
	mov	w9, #12
	add	x10, sp, #32
	cmp	w8, #0
	csel	w20, w8, w9, eq
	csel	x0, x22, x10, eq
	b	LBB114_11
LBB114_10:
	mov	w20, #0
	add	x0, sp, #16
LBB114_11:
	str	x21, [x0]
	bl	l_Io.Threaded.Syscall.finish
LBB114_12:
	ldur	x8, [x29, #-40]
Lloh756:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh757:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh758:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB114_17
	mov	x0, x20
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB114_14:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB114_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB114_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB114_17:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh753, Lloh754, Lloh755
	.loh AdrpLdrGotLdr	Lloh756, Lloh757, Lloh758
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileUnlock:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB115_10
	tst	x0, #0x7
	b.ne	LBB115_11
	ldr	w19, [x1]
LBB115_3:
	mov	x0, x19
	mov	w1, #8
	bl	_flock
	cmn	w0, #1
	b.ne	LBB115_8
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB115_9
	cmp	w8, #16, lsl #12
	b.hs	LBB115_9
	cmp	w8, #4
	b.eq	LBB115_3
	cmp	w8, #89
	b.eq	LBB115_3
LBB115_8:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB115_9:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB115_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB115_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileTryLock:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh759:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh760:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh761:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #56]
	cbz	x0, LBB116_29
	tst	x0, #0x7
	b.ne	LBB116_30
	ldr	w20, [x1]
	and	w8, w2, #0x3
	cmp	w8, #1
	b.gt	LBB116_4
	mov	w9, #8
	mov	w10, #5
	cmp	w8, #0
	csel	w21, w9, w10, eq
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #48]
	cbz	w8, LBB116_6
	b	LBB116_26
LBB116_4:
	cmp	w8, #2
	b.ne	LBB116_31
	mov	w21, #6
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB116_26
LBB116_6:
	ldr	x22, [sp, #40]
LBB116_7:
	mov	x0, x20
	mov	x1, x21
	bl	_flock
	cmn	w0, #1
	b.ne	LBB116_14
	bl	___error
	ldr	w23, [x0]
	tbnz	w23, #31, LBB116_28
	cmp	w23, #16, lsl #12
	b.hs	LBB116_28
	cmp	w23, #4
	b.ne	LBB116_12
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB116_7
	b	LBB116_26
LBB116_12:
	cmp	w23, #35
	b.eq	LBB116_17
	cbnz	w23, LBB116_19
LBB116_14:
	str	x22, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #65536
LBB116_15:
	str	w8, [x19]
	ldr	x8, [sp, #56]
Lloh762:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh763:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh764:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB116_18
LBB116_16:
	.cfi_def_cfa wsp, 128
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB116_17:
	.cfi_restore_state
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	str	wzr, [x19]
	ldr	x8, [sp, #56]
Lloh765:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh766:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh767:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB116_16
LBB116_18:
	bl	___stack_chk_fail
LBB116_19:
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w23, #44
	b.gt	LBB116_22
	cmp	w23, #9
	b.eq	LBB116_25
	cmp	w23, #22
	b	LBB116_25
LBB116_22:
	cmp	w23, #45
	b.eq	LBB116_27
	cmp	w23, #77
	b.ne	LBB116_25
	mov	w8, #4
	b	LBB116_15
LBB116_25:
	mov	w8, #12
LBB116_26:
	strh	w8, [x19]
	ldr	x8, [sp, #56]
Lloh768:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh769:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh770:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB116_16
	b	LBB116_18
LBB116_27:
	mov	w8, #47
	b	LBB116_15
LBB116_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB116_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB116_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB116_31:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh759, Lloh760, Lloh761
	.loh AdrpLdrGotLdr	Lloh762, Lloh763, Lloh764
	.loh AdrpLdrGotLdr	Lloh765, Lloh766, Lloh767
	.loh AdrpLdrGotLdr	Lloh768, Lloh769, Lloh770
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileLock:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh771:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh772:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh773:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB117_19
	tst	x0, #0x7
	b.ne	LBB117_20
	ldr	w19, [x1]
	and	w8, w2, #0x3
	cmp	w8, #1
	b.gt	LBB117_4
	mov	w9, #8
	cmp	w8, #0
	csinc	w20, w9, wzr, eq
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbz	w0, LBB117_6
	b	LBB117_14
LBB117_4:
	cmp	w8, #2
	b.ne	LBB117_21
	mov	w20, #2
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB117_14
LBB117_6:
	ldr	x21, [sp, #40]
LBB117_7:
	mov	x0, x19
	mov	x1, x20
	bl	_flock
	cmn	w0, #1
	b.ne	LBB117_13
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB117_18
	cmp	w22, #16, lsl #12
	b.hs	LBB117_18
	cmp	w22, #4
	b.ne	LBB117_12
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB117_7
	b	LBB117_14
LBB117_12:
	cbnz	w22, LBB117_16
LBB117_13:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB117_14:
	ldur	x8, [x29, #-40]
Lloh774:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh775:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh776:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB117_17
LBB117_15:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB117_16:
	.cfi_restore_state
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	mov	w9, #4
	cmp	w22, #77
	csel	w8, w9, w8, eq
	mov	w9, #47
	cmp	w22, #45
	csel	w0, w9, w8, eq
	ldur	x8, [x29, #-40]
Lloh777:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh778:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh779:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB117_15
LBB117_17:
	bl	___stack_chk_fail
LBB117_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB117_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB117_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB117_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh771, Lloh772, Lloh773
	.loh AdrpLdrGotLdr	Lloh774, Lloh775, Lloh776
	.loh AdrpLdrGotLdr	Lloh777, Lloh778, Lloh779
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileSetTimestamps:
	.cfi_startproc
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x24, x23, [sp, #112]
	stp	x22, x21, [sp, #128]
	stp	x20, x19, [sp, #144]
	stp	x29, x30, [sp, #160]
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
Lloh780:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh781:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh782:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB118_40
	tst	x0, #0x7
	b.ne	LBB118_41
	ldr	w19, [x1]
	ldp	x21, x24, [x2]
	ldrb	w8, [x2, #16]
	ldp	x20, x22, [x2, #32]
	ldrb	w9, [x2, #48]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #48]
	and	w23, w9, #0x3
	and	w8, w8, #0x3
	cmp	w23, #1
	ccmp	w8, #1, #0, eq
	b.eq	LBB118_6
	cmp	w8, #1
	b.gt	LBB118_7
Lloh783:
	adrp	x9, l___anon_9523@PAGE
Lloh784:
	add	x9, x9, l___anon_9523@PAGEOFF
Lloh785:
	adrp	x10, l___anon_9526@PAGE
Lloh786:
	add	x10, x10, l___anon_9526@PAGEOFF
	cmp	w8, #0
	csel	x8, x9, x10, eq
	ldr	q0, [x8]
	str	q0, [sp, #48]
	cmp	w23, #1
	b.gt	LBB118_11
LBB118_5:
Lloh787:
	adrp	x8, l___anon_9523@PAGE
Lloh788:
	add	x8, x8, l___anon_9523@PAGEOFF
Lloh789:
	adrp	x9, l___anon_9526@PAGE
Lloh790:
	add	x9, x9, l___anon_9526@PAGEOFF
	cmp	w23, #0
	csel	x8, x8, x9, eq
	b	LBB118_15
LBB118_6:
	mov	x20, #0
	b	LBB118_16
LBB118_7:
	cmp	w8, #2
	b.ne	LBB118_43
	sxtw	x1, w24
	mov	x0, x21
	mov	w2, #51712
	movk	w2, #15258, lsl #16
	mov	x3, #0
	bl	___divti3
	mov	x8, #-51712
	movk	x8, #50277, lsl #16
	umulh	x9, x0, x8
	sub	x9, x9, x0
	madd	x9, x1, x8, x9
	mul	x8, x0, x8
	adds	x8, x8, x21
	adc	x9, x9, x24
	sxtw	x10, w9
	asr	x11, x10, #63
	adds	x9, x0, x10, asr #31
	adc	x11, x11, x1
	sxtw	x11, w11
	mov	x12, #9223372036854775807
	cmp	x12, x9
	mov	x12, #-1
	sbcs	xzr, x12, x11
	b.ge	LBB118_39
	mov	x12, #-9223372036854775808
	cmp	x9, x12
	sbcs	xzr, x11, xzr
	b.ge	LBB118_39
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	and	x10, x11, x10, lsr #31
	add	x8, x10, x8
	stp	x9, x8, [sp, #32]
	add	x8, sp, #32
	ldr	q0, [x8]
	str	q0, [sp, #48]
	cmp	w23, #1
	b.le	LBB118_5
LBB118_11:
	cmp	w23, #2
	b.ne	LBB118_43
	sxtw	x1, w22
	mov	x0, x20
	mov	w2, #51712
	movk	w2, #15258, lsl #16
	mov	x3, #0
	bl	___divti3
	mov	x8, #-51712
	movk	x8, #50277, lsl #16
	umulh	x9, x0, x8
	sub	x9, x9, x0
	madd	x9, x1, x8, x9
	mul	x8, x0, x8
	adds	x8, x8, x20
	adc	x9, x9, x22
	sxtw	x10, w9
	asr	x11, x10, #63
	adds	x9, x0, x10, asr #31
	adc	x11, x11, x1
	sxtw	x11, w11
	mov	x12, #9223372036854775807
	cmp	x12, x9
	mov	x12, #-1
	sbcs	xzr, x12, x11
	b.ge	LBB118_39
	mov	x12, #-9223372036854775808
	cmp	x9, x12
	sbcs	xzr, x11, xzr
	b.ge	LBB118_39
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	and	x10, x11, x10, lsr #31
	add	x8, x10, x8
	stp	x9, x8, [sp, #32]
	add	x8, sp, #32
LBB118_15:
	add	x9, sp, #48
	ldr	q0, [x8]
	stur	q0, [x9, #16]
	add	x20, sp, #48
LBB118_16:
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-64]
	cbnz	w0, LBB118_37
	ldur	x21, [x29, #-72]
LBB118_18:
	mov	x0, x19
	mov	x1, x20
	bl	_futimens
	cmn	w0, #1
	b.ne	LBB118_30
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB118_39
	cmp	w8, #16, lsl #12
	b.hs	LBB118_39
	cmp	w8, #4
	b.ne	LBB118_23
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB118_18
	b	LBB118_37
LBB118_23:
	cmp	w8, #12
	b.le	LBB118_27
	cmp	w8, #21
	b.gt	LBB118_31
	cmp	w8, #13
	b.eq	LBB118_35
	cmp	w8, #14
	b	LBB118_34
LBB118_27:
	cbz	w8, LBB118_30
	cmp	w8, #1
	b.eq	LBB118_36
	cmp	w8, #9
	b	LBB118_34
LBB118_30:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB118_37
LBB118_31:
	cmp	w8, #22
	b.eq	LBB118_34
	cmp	w8, #30
	b.ne	LBB118_34
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #41
	b	LBB118_37
LBB118_34:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB118_37
LBB118_35:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB118_37
LBB118_36:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
LBB118_37:
	ldur	x8, [x29, #-56]
Lloh791:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh792:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh793:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB118_42
	.cfi_def_cfa wsp, 176
	ldp	x29, x30, [sp, #160]
	ldp	x20, x19, [sp, #144]
	ldp	x22, x21, [sp, #128]
	ldp	x24, x23, [sp, #112]
	add	sp, sp, #176
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB118_39:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB118_40:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB118_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB118_42:
	bl	___stack_chk_fail
LBB118_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh780, Lloh781, Lloh782
	.loh AdrpAdd	Lloh785, Lloh786
	.loh AdrpAdd	Lloh783, Lloh784
	.loh AdrpAdd	Lloh789, Lloh790
	.loh AdrpAdd	Lloh787, Lloh788
	.loh AdrpLdrGotLdr	Lloh791, Lloh792, Lloh793
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileSetLength:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh794:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh795:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh796:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB119_27
	tst	x0, #0x7
	b.ne	LBB119_28
	mov	x19, x2
	tbnz	x2, #63, LBB119_16
	ldr	w20, [x1]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB119_17
	ldr	x21, [sp, #40]
LBB119_5:
	mov	x0, x20
	mov	x1, x19
	bl	_ftruncate
	cmn	w0, #1
	b.ne	LBB119_11
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB119_26
	cmp	w22, #16, lsl #12
	b.hs	LBB119_26
	cmp	w22, #4
	b.ne	LBB119_10
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB119_5
	b	LBB119_17
LBB119_10:
	cbnz	w22, LBB119_12
LBB119_11:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB119_17
LBB119_12:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w22, #21
	b.le	LBB119_19
	cmp	w22, #22
	b.eq	LBB119_22
	cmp	w22, #26
	b.eq	LBB119_23
	cmp	w22, #27
	b.ne	LBB119_25
LBB119_16:
	mov	w0, #15
LBB119_17:
	ldur	x8, [x29, #-40]
Lloh797:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh798:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh799:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB119_29
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB119_19:
	.cfi_restore_state
	cmp	w22, #1
	b.eq	LBB119_24
	cmp	w22, #5
	b.ne	LBB119_25
	mov	w0, #3
	b	LBB119_17
LBB119_22:
	mov	w0, #62
	b	LBB119_17
LBB119_23:
	mov	w0, #22
	b	LBB119_17
LBB119_24:
	mov	w0, #18
	b	LBB119_17
LBB119_25:
	mov	w0, #12
	b	LBB119_17
LBB119_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB119_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB119_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB119_29:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh794, Lloh795, Lloh796
	.loh AdrpLdrGotLdr	Lloh797, Lloh798, Lloh799
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileSupportsAnsiEscapeCodes:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh800:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh801:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh802:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB120_10
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB120_11
	ldr	w21, [x1]
	add	x0, sp, #20
	mov	x1, x21
	bl	l_Io.Threaded.isTty
	mov	w23, #0
	ldrh	w22, [sp, #20]
	cbnz	w22, LBB120_8
	ldrb	w8, [sp, #22]
	tbz	w8, #0, LBB120_8
	sub	w8, w21, #1
	cmp	w8, #1
	b.hi	LBB120_7
	mov	x0, x20
	bl	l_Io.Threaded.scanEnviron
	ldr	x8, [x20, #664]
	mov	w23, #65536
	cbz	x8, LBB120_8
	ldr	x1, [x20, #672]
	cmp	x1, #0
	csinc	x0, x8, xzr, ne
Lloh803:
	adrp	x2, l___anon_9566@PAGE
Lloh804:
	add	x2, x2, l___anon_9566@PAGEOFF
	mov	w3, #4
	bl	l_mem.eqlBytes
	tst	w0, #0x1
	csel	w23, wzr, w23, ne
	b	LBB120_8
LBB120_7:
	mov	w23, #65536
LBB120_8:
	orr	w8, w23, w22
	str	w8, [x19]
	ldr	x8, [sp, #24]
Lloh805:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh806:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh807:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB120_12
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB120_10:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB120_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB120_12:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh800, Lloh801, Lloh802
	.loh AdrpAdd	Lloh803, Lloh804
	.loh AdrpLdrGotLdr	Lloh805, Lloh806, Lloh807
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileEnableAnsiEscapeCodes:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
Lloh808:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh809:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh810:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB121_13
	mov	x19, x0
	tst	x0, #0x7
	b.ne	LBB121_14
	ldr	w20, [x1]
	add	x0, sp, #20
	mov	x1, x20
	bl	l_Io.Threaded.isTty
	ldrh	w0, [sp, #20]
	cbnz	w0, LBB121_9
	ldrb	w8, [sp, #22]
	tbz	w8, #0, LBB121_7
	sub	w8, w20, #1
	cmp	w8, #1
	b.hi	LBB121_8
	mov	x0, x19
	bl	l_Io.Threaded.scanEnviron
	ldr	x8, [x19, #664]
	cbz	x8, LBB121_11
	ldr	x1, [x19, #672]
	cmp	x1, #0
	csinc	x0, x8, xzr, ne
Lloh811:
	adrp	x2, l___anon_9566@PAGE
Lloh812:
	add	x2, x2, l___anon_9566@PAGEOFF
	mov	w3, #4
	bl	l_mem.eqlBytes
	tst	w0, #0x1
	mov	w8, #61
	csel	w0, w8, wzr, ne
	ldr	x8, [sp, #24]
Lloh813:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh814:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh815:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB121_10
	b	LBB121_12
LBB121_7:
	mov	w0, #61
	ldr	x8, [sp, #24]
Lloh816:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh817:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh818:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB121_10
	b	LBB121_12
LBB121_8:
	mov	w0, #0
LBB121_9:
	ldr	x8, [sp, #24]
Lloh819:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh820:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh821:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB121_12
LBB121_10:
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB121_11:
	.cfi_restore_state
	mov	w0, #0
	ldr	x8, [sp, #24]
Lloh822:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh823:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh824:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB121_10
LBB121_12:
	bl	___stack_chk_fail
LBB121_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB121_14:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdrGotLdr	Lloh808, Lloh809, Lloh810
	.loh AdrpLdrGotLdr	Lloh813, Lloh814, Lloh815
	.loh AdrpAdd	Lloh811, Lloh812
	.loh AdrpLdrGotLdr	Lloh816, Lloh817, Lloh818
	.loh AdrpLdrGotLdr	Lloh819, Lloh820, Lloh821
	.loh AdrpLdrGotLdr	Lloh822, Lloh823, Lloh824
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileIsTty:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh825:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh826:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh827:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB122_4
	tst	x0, #0x7
	b.ne	LBB122_5
	ldr	w1, [x1]
	add	x0, sp, #20
	bl	l_Io.Threaded.isTty
	ldr	w8, [sp, #20]
	str	w8, [x19]
	ldr	x8, [sp, #24]
Lloh828:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh829:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh830:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB122_6
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB122_4:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB122_5:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB122_6:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh825, Lloh826, Lloh827
	.loh AdrpLdrGotLdr	Lloh828, Lloh829, Lloh830
	.cfi_endproc

	.p2align	2
l_Io.Threaded.isTty:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x20, x1
	mov	x19, x0
Lloh831:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh832:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh833:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB123_8
	ldr	x21, [sp, #40]
LBB123_2:
	mov	x0, x20
	bl	_isatty
	subs	w8, w0, #1
	b.vs	LBB123_15
	cmn	w8, #1
	b.ne	LBB123_10
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB123_14
	cmp	w8, #16, lsl #12
	b.hs	LBB123_14
	cmp	w8, #4
	b.ne	LBB123_9
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB123_2
LBB123_8:
	strh	w8, [x19]
	ldur	x8, [x29, #-40]
Lloh834:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh835:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh836:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB123_11
	b	LBB123_13
LBB123_9:
	cbnz	w8, LBB123_12
LBB123_10:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #65536
	str	w8, [x19]
	ldur	x8, [x29, #-40]
Lloh837:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh838:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh839:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB123_13
LBB123_11:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB123_12:
	.cfi_restore_state
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	str	wzr, [x19]
	ldur	x8, [x29, #-40]
Lloh840:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh841:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh842:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB123_11
LBB123_13:
	bl	___stack_chk_fail
LBB123_14:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB123_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.loh AdrpLdrGotLdr	Lloh831, Lloh832, Lloh833
	.loh AdrpLdrGotLdr	Lloh834, Lloh835, Lloh836
	.loh AdrpLdrGotLdr	Lloh837, Lloh838, Lloh839
	.loh AdrpLdrGotLdr	Lloh840, Lloh841, Lloh842
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileSyncPosix:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh843:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh844:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh845:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB124_21
	tst	x0, #0x7
	b.ne	LBB124_22
	ldr	w19, [x1]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB124_11
	ldr	x20, [sp, #40]
LBB124_4:
	mov	x0, x19
	bl	_fsync
	cmn	w0, #1
	b.ne	LBB124_10
	bl	___error
	ldr	w21, [x0]
	tbnz	w21, #31, LBB124_20
	cmp	w21, #16, lsl #12
	b.hs	LBB124_20
	cmp	w21, #4
	b.ne	LBB124_9
	str	x20, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB124_4
	b	LBB124_11
LBB124_9:
	cbnz	w21, LBB124_13
LBB124_10:
	str	x20, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB124_11:
	ldur	x8, [x29, #-40]
Lloh846:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh847:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh848:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB124_23
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB124_13:
	.cfi_restore_state
	str	x20, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w21, #5
	b.eq	LBB124_18
	cmp	w21, #69
	b.eq	LBB124_17
	cmp	w21, #28
	b.ne	LBB124_19
	mov	w0, #16
	b	LBB124_11
LBB124_17:
	mov	w0, #14
	b	LBB124_11
LBB124_18:
	mov	w0, #3
	b	LBB124_11
LBB124_19:
	mov	w0, #12
	b	LBB124_11
LBB124_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB124_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB124_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB124_23:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh843, Lloh844, Lloh845
	.loh AdrpLdrGotLdr	Lloh846, Lloh847, Lloh848
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileSeekTo:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB125_3
	tst	x0, #0x7
	b.ne	LBB125_4
	ldr	w0, [x1]
	mov	x1, x2
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.posixSeekTo
LBB125_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB125_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileSeekBy:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh849:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh850:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh851:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB126_18
	tst	x0, #0x7
	b.ne	LBB126_19
	mov	x19, x2
	ldr	w20, [x1]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB126_15
	ldr	x21, [sp, #40]
LBB126_4:
	mov	x0, x20
	mov	x1, x19
	mov	w2, #1
	bl	_lseek
	cmn	x0, #1
	b.ne	LBB126_10
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB126_17
	cmp	w22, #16, lsl #12
	b.hs	LBB126_17
	cmp	w22, #4
	b.ne	LBB126_9
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB126_4
	b	LBB126_15
LBB126_9:
	cbnz	w22, LBB126_11
LBB126_10:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB126_15
LBB126_11:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #57
	sub	w8, w22, #22
	cmp	w8, #62
	b.hi	LBB126_13
	mov	w9, #1
	lsl	x8, x9, x8
	mov	x9, #129
	movk	x9, #16384, lsl #48
	tst	x8, x9
	b.ne	LBB126_15
LBB126_13:
	cmp	w22, #6
	b.eq	LBB126_15
	mov	w0, #12
LBB126_15:
	ldur	x8, [x29, #-40]
Lloh852:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh853:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh854:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB126_20
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB126_17:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB126_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB126_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB126_20:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh849, Lloh850, Lloh851
	.loh AdrpLdrGotLdr	Lloh852, Lloh853, Lloh854
	.cfi_endproc

	.p2align	2
l_Io.Threaded.posixSeekTo:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x19, x1
	mov	x20, x0
Lloh855:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh856:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh857:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB127_13
	ldr	x21, [sp, #40]
LBB127_2:
	mov	x0, x20
	mov	x1, x19
	mov	w2, #0
	bl	_lseek
	cmn	x0, #1
	b.ne	LBB127_8
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB127_15
	cmp	w22, #16, lsl #12
	b.hs	LBB127_15
	cmp	w22, #4
	b.ne	LBB127_7
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB127_2
	b	LBB127_13
LBB127_7:
	cbnz	w22, LBB127_9
LBB127_8:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB127_13
LBB127_9:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #57
	sub	w8, w22, #22
	cmp	w8, #62
	b.hi	LBB127_11
	mov	w9, #1
	lsl	x8, x9, x8
	mov	x9, #129
	movk	x9, #16384, lsl #48
	tst	x8, x9
	b.ne	LBB127_13
LBB127_11:
	cmp	w22, #6
	b.eq	LBB127_13
	mov	w0, #12
LBB127_13:
	ldur	x8, [x29, #-40]
Lloh858:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh859:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh860:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB127_16
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB127_15:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB127_16:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh855, Lloh856, Lloh857
	.loh AdrpLdrGotLdr	Lloh858, Lloh859, Lloh860
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileReadPositional:
	.cfi_startproc
	sub	sp, sp, #272
	.cfi_def_cfa_offset 272
	stp	x26, x25, [sp, #192]
	stp	x24, x23, [sp, #208]
	stp	x22, x21, [sp, #224]
	stp	x20, x19, [sp, #240]
	stp	x29, x30, [sp, #256]
	add	x29, sp, #256
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x19, x8
Lloh861:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh862:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh863:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB128_32
	tst	x0, #0x7
	b.ne	LBB128_33
	ldr	w21, [x1]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #32]
	cbz	x3, LBB128_18
	mov	x20, x4
	mov	x22, #0
	add	x8, x2, #8
	add	x9, sp, #32
	b	LBB128_5
LBB128_4:
	add	x8, x8, #16
	subs	x3, x3, #1
	b.eq	LBB128_8
LBB128_5:
	cmp	x22, #8
	b.eq	LBB128_9
	ldr	x10, [x8]
	cbz	x10, LBB128_4
	ldur	x11, [x8, #-8]
	add	x12, x9, x22, lsl #4
	stp	x11, x10, [x12]
	add	x22, x22, #1
	b	LBB128_4
LBB128_8:
	cbz	x22, LBB128_18
LBB128_9:
	ldr	x8, [sp, #40]
	cbz	x8, LBB128_35
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-80]
	cbnz	w8, LBB128_28
	ldur	x24, [x29, #-88]
Lloh864:
	adrp	x25, LJTI128_0@PAGE
Lloh865:
	add	x25, x25, LJTI128_0@PAGEOFF
LBB128_12:
	add	x1, sp, #32
	mov	x0, x21
	mov	x2, x22
	mov	x3, x20
	bl	_preadv
	mov	x23, x0
	cmn	x0, #1
	b.ne	LBB128_20
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB128_31
	cmp	w8, #16, lsl #12
	b.hs	LBB128_31
	cmp	w8, #84
	b.hi	LBB128_19
	adr	x9, LBB128_17
	ldrb	w10, [x25, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB128_17:
	str	x24, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB128_12
	b	LBB128_28
LBB128_18:
	mov	x23, #0
	mov	w8, #0
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	b	LBB128_29
LBB128_19:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	b	LBB128_28
LBB128_20:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #0
	b	LBB128_29
LBB128_21:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #57
	b	LBB128_28
LBB128_22:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #4
	b	LBB128_28
LBB128_23:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #10
	b	LBB128_28
LBB128_24:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #7
	b	LBB128_28
LBB128_25:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #3
	b	LBB128_28
LBB128_26:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #9
	b	LBB128_28
LBB128_27:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #5
LBB128_28:
LBB128_29:
	str	x23, [x19]
	strh	w8, [x19, #8]
	ldr	w8, [sp, #24]
	stur	w8, [x19, #10]
	ldrh	w8, [sp, #28]
	strh	w8, [x19, #14]
	ldur	x8, [x29, #-72]
Lloh866:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh867:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh868:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB128_34
	.cfi_def_cfa wsp, 272
	ldp	x29, x30, [sp, #256]
	ldp	x20, x19, [sp, #240]
	ldp	x22, x21, [sp, #224]
	ldp	x24, x23, [sp, #208]
	ldp	x26, x25, [sp, #192]
	add	sp, sp, #272
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB128_31:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB128_32:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB128_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB128_34:
	bl	___stack_chk_fail
LBB128_35:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh861, Lloh862, Lloh863
	.loh AdrpAdd	Lloh864, Lloh865
	.loh AdrpLdrGotLdr	Lloh866, Lloh867, Lloh868
	.cfi_endproc
	.section	__TEXT,__const
LJTI128_0:
	.byte	(LBB128_20-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_17-LBB128_17)>>2
	.byte	(LBB128_25-LBB128_17)>>2
	.byte	(LBB128_21-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_24-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_22-LBB128_17)>>2
	.byte	(LBB128_23-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_27-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_21-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_26-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_22-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_17-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_19-LBB128_17)>>2
	.byte	(LBB128_21-LBB128_17)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.fileWriteFilePositional:
	.cfi_startproc
	sub	sp, sp, #384
	.cfi_def_cfa_offset 384
	stp	x28, x27, [sp, #288]
	stp	x26, x25, [sp, #304]
	stp	x24, x23, [sp, #320]
	stp	x22, x21, [sp, #336]
	stp	x20, x19, [sp, #352]
	stp	x29, x30, [sp, #368]
	add	x29, sp, #368
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
Lloh869:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh870:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh871:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-96]
	cbz	x0, LBB129_55
	tst	x0, #0x7
	b.ne	LBB129_56
	mov	x20, x4
	ldp	x9, x8, [x4, #64]
	subs	x24, x8, x9
	b.lo	LBB129_57
	ldr	x10, [x20, #56]
	cmp	x8, x10
	b.hi	LBB129_58
	mov	x7, x6
	mov	x21, x3
	ldr	x10, [x20, #48]
	add	x25, x10, x9
	cmp	x24, x5
	b.hs	LBB129_11
	ldr	w22, [x1]
	ldr	w23, [x20, #80]
	ldrb	w10, [x20, #32]
	tbz	w10, #0, LBB129_16
	ldp	x12, x11, [x20, #16]
	cmp	x11, x12
	b.lo	LBB129_60
	b.ne	LBB129_16
	cmp	x8, x9
	b.ne	LBB129_29
Lloh872:
	adrp	x8, l___anon_12314@PAGE
Lloh873:
	add	x8, x8, l___anon_12314@PAGEOFF
Lloh874:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-96]
Lloh875:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh876:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh877:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB129_59
	.cfi_def_cfa wsp, 384
	b	LBB129_21
LBB129_11:
	.cfi_restore_state
	.cfi_remember_state
	stp	x25, x5, [sp, #48]
	add	x8, sp, #64
	add	x4, sp, #48
	mov	x3, x21
	mov	w5, #1
	mov	w6, #1
	bl	l_Io.Threaded.fileWritePositional
	ldrh	w8, [sp, #72]
	cbnz	w8, LBB129_45
	ldr	x8, [sp, #64]
LBB129_13:
	subs	x9, x8, x21
	csel	x9, xzr, x9, lo
	ldr	x10, [x20, #64]
	adds	x9, x10, x9
	b.hs	LBB129_60
	str	x9, [x20, #64]
	ldr	x10, [x20, #72]
	cmp	x9, x10
	b.hi	LBB129_61
	str	x8, [x19]
	strh	wzr, [x19, #8]
	b	LBB129_19
LBB129_16:
	ldrb	w8, [x0, #854]
	tbz	w8, #0, LBB129_22
LBB129_17:
Lloh878:
	adrp	x8, l___anon_9773@PAGE
Lloh879:
	add	x8, x8, l___anon_9773@PAGEOFF
LBB129_18:
	ldr	q0, [x8]
	str	q0, [x19]
LBB129_19:
	ldur	x8, [x29, #-96]
Lloh880:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh881:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh882:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB129_59
	.cfi_def_cfa wsp, 384
LBB129_21:
	ldp	x29, x30, [sp, #368]
	ldp	x20, x19, [sp, #352]
	ldp	x22, x21, [sp, #336]
	ldp	x24, x23, [sp, #320]
	ldp	x26, x25, [sp, #304]
	ldp	x28, x27, [sp, #288]
	add	sp, sp, #384
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB129_22:
	.cfi_restore_state
	ldr	x8, [x20, #16]
	cbnz	x8, LBB129_17
	cbnz	x7, LBB129_17
	cmn	x5, #1
	b.ne	LBB129_17
	tbz	w10, #0, LBB129_31
	ldr	x26, [x20, #24]
	orr	x8, x24, x21
	cbz	x8, LBB129_38
LBB129_27:
	stp	x25, x24, [sp, #112]
	add	x8, sp, #128
	add	x4, sp, #112
	mov	x3, x21
	mov	w5, #1
	mov	w6, #1
	mov	x7, #0
	bl	l_Io.Threaded.fileWritePositional
	ldrh	w8, [sp, #136]
	cbnz	w8, LBB129_45
	ldr	x8, [sp, #128]
	b	LBB129_13
LBB129_29:
	stp	x25, x24, [sp, #80]
	add	x8, sp, #96
	add	x4, sp, #80
	mov	x3, x21
	mov	w5, #1
	mov	w6, #1
	bl	l_Io.Threaded.fileWritePositional
	ldrh	w8, [sp, #104]
	cbnz	w8, LBB129_45
	ldr	x8, [sp, #96]
	b	LBB129_13
LBB129_31:
	ldrh	w8, [x20, #90]
	cbnz	w8, LBB129_34
	mov	x28, x1
	mov	x27, x2
	mov	x26, x0
	ldr	x8, [x20, #80]
	str	x8, [sp, #40]
	ldp	x0, x8, [x20]
	ldr	x9, [x8, #360]
	add	x8, sp, #160
	add	x1, sp, #40
	blr	x9
	ldrh	w8, [sp, #256]
	cbz	w8, LBB129_36
	strh	w8, [x20, #90]
LBB129_34:
	cmp	w8, #2
	b.ne	LBB129_17
Lloh883:
	adrp	x8, l___anon_9662@PAGE
Lloh884:
	add	x8, x8, l___anon_9662@PAGEOFF
	b	LBB129_18
LBB129_36:
	ldrb	w8, [sp, #248]
	and	w8, w8, #0xf
	cmp	w8, #5
	b.ne	LBB129_53
	mov	x0, x26
	ldr	x26, [sp, #232]
	str	x26, [x20, #24]
	mov	w8, #1
	strb	w8, [x20, #32]
	mov	x2, x27
	mov	x1, x28
	orr	x8, x24, x21
	cbnz	x8, LBB129_27
LBB129_38:
	mov	x21, x0
	add	x0, sp, #144
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #152]
	cbnz	w8, LBB129_45
	ldr	x24, [sp, #144]
LBB129_40:
	mov	x0, x23
	mov	x1, x22
	mov	x2, #0
	mov	w3, #8
	bl	_fcopyfile
	cmn	w0, #1
	b.ne	LBB129_48
	bl	___error
	ldr	w25, [x0]
	tbnz	w25, #31, LBB129_62
	cmp	w25, #16, lsl #12
	b.hs	LBB129_62
	cmp	w25, #4
	b.ne	LBB129_46
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB129_40
LBB129_45:
	strh	w8, [x19, #8]
	b	LBB129_19
LBB129_46:
	cmp	w25, #45
	b.eq	LBB129_49
	cbnz	w25, LBB129_50
LBB129_48:
	str	x24, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	str	x26, [x20, #16]
	str	x26, [x19]
	strh	wzr, [x19, #8]
	b	LBB129_19
LBB129_49:
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #1
	strb	w8, [x21, #854]
	b	LBB129_52
LBB129_50:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w25, #12
	b.ne	LBB129_52
Lloh885:
	adrp	x8, l___anon_10325@PAGE
Lloh886:
	add	x8, x8, l___anon_10325@PAGEOFF
	b	LBB129_18
LBB129_52:
	stp	xzr, xzr, [x19]
	b	LBB129_19
LBB129_53:
	ldrb	w8, [x20, #94]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB129_63
	and	w8, w8, #0x7
	add	w8, w8, w8, lsl #1
	mov	w9, #4
	movk	w9, #72, lsl #16
	lsr	w8, w9, w8
	and	w8, w8, #0x7
	strb	w8, [x20, #94]
	mov	w8, #48
	strh	w8, [x20, #90]
	b	LBB129_17
LBB129_55:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB129_56:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB129_57:
	mov	x0, x9
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB129_58:
	mov	x0, x8
	mov	x1, x10
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB129_59:
	bl	___stack_chk_fail
LBB129_60:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB129_61:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB129_62:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB129_63:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh869, Lloh870, Lloh871
	.loh AdrpLdrGotLdr	Lloh875, Lloh876, Lloh877
	.loh AdrpAddLdr	Lloh872, Lloh873, Lloh874
	.loh AdrpAdd	Lloh878, Lloh879
	.loh AdrpLdrGotLdr	Lloh880, Lloh881, Lloh882
	.loh AdrpAdd	Lloh883, Lloh884
	.loh AdrpAdd	Lloh885, Lloh886
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileWriteFileStreaming:
	.cfi_startproc
	sub	sp, sp, #320
	.cfi_def_cfa_offset 320
	stp	x28, x27, [sp, #224]
	stp	x26, x25, [sp, #240]
	stp	x24, x23, [sp, #256]
	stp	x22, x21, [sp, #272]
	stp	x20, x19, [sp, #288]
	stp	x29, x30, [sp, #304]
	add	x29, sp, #304
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
Lloh887:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh888:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh889:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-96]
	cbz	x0, LBB130_61
	mov	x22, x0
	tst	x0, #0x7
	b.ne	LBB130_62
	mov	x20, x4
	mov	x9, x1
	ldp	x0, x1, [x4, #64]
	subs	x10, x1, x0
	b.lo	LBB130_63
	ldr	x8, [x20, #56]
	cmp	x1, x8
	b.hi	LBB130_64
	mov	x21, x3
	mov	x3, x2
	ldr	w23, [x9]
	ldr	x8, [x20, #48]
	add	x9, x8, x0
	subs	x8, x5, x10
	b.ls	LBB130_11
	ldr	w24, [x20, #80]
	ldrb	w11, [x20, #32]
	tbz	w11, #0, LBB130_18
	ldp	x12, x11, [x20, #16]
	cmp	x11, x12
	b.lo	LBB130_66
	b.ne	LBB130_18
	cmp	x1, x0
	b.ne	LBB130_25
Lloh890:
	adrp	x8, l___anon_12314@PAGE
Lloh891:
	add	x8, x8, l___anon_12314@PAGEOFF
Lloh892:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-96]
Lloh893:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh894:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh895:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB130_65
	.cfi_def_cfa wsp, 320
	b	LBB130_24
LBB130_11:
	.cfi_restore_state
	.cfi_remember_state
	stp	x9, x5, [sp, #64]
	add	x0, sp, #80
	add	x5, sp, #64
	mov	x1, x22
	mov	x2, x23
	mov	x4, x21
	mov	w6, #1
	mov	w7, #1
	bl	l_Io.Threaded.fileWriteStreaming
	ldrh	w8, [sp, #88]
	cbnz	w8, LBB130_40
	ldr	x8, [sp, #80]
LBB130_13:
	subs	x9, x8, x21
	csel	x9, xzr, x9, lo
	ldr	x10, [x20, #64]
	adds	x9, x10, x9
	b.hs	LBB130_66
	str	x9, [x20, #64]
	ldr	x10, [x20, #72]
	cmp	x9, x10
	b.hi	LBB130_67
	str	x8, [x19]
	strh	wzr, [x19, #8]
LBB130_16:
	ldur	x8, [x29, #-96]
Lloh896:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh897:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh898:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB130_65
	.cfi_def_cfa wsp, 320
	b	LBB130_24
LBB130_18:
	.cfi_restore_state
	.cfi_remember_state
	ldrb	w11, [x22, #858]
	tbnz	w11, #0, LBB130_22
	ldr	x25, [x20, #16]
	tbnz	x25, #63, LBB130_22
	movi.16b	v0, #170
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [x29, #-144]
	cbz	x21, LBB130_27
	stp	x3, x21, [x29, #-144]
	mov	w11, #1
	cmp	x1, x0
	b.ne	LBB130_30
	b	LBB130_31
LBB130_22:
Lloh899:
	adrp	x8, l___anon_9773@PAGE
Lloh900:
	add	x8, x8, l___anon_9773@PAGEOFF
Lloh901:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-96]
Lloh902:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh903:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh904:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB130_65
	.cfi_def_cfa wsp, 320
LBB130_24:
	ldp	x29, x30, [sp, #304]
	ldp	x20, x19, [sp, #288]
	ldp	x22, x21, [sp, #272]
	ldp	x24, x23, [sp, #256]
	ldp	x26, x25, [sp, #240]
	ldp	x28, x27, [sp, #224]
	add	sp, sp, #320
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB130_25:
	.cfi_restore_state
	stp	x9, x10, [sp, #96]
	add	x0, sp, #112
	add	x5, sp, #96
	mov	x1, x22
	mov	x2, x23
	mov	x4, x21
	mov	w6, #1
	mov	w7, #1
	bl	l_Io.Threaded.fileWriteStreaming
	ldrh	w8, [sp, #120]
	cbnz	w8, LBB130_40
	ldr	x8, [sp, #112]
	b	LBB130_13
LBB130_27:
	cmp	x1, x0
	b.ne	LBB130_29
	mov	x26, #0
	b	LBB130_32
LBB130_29:
	mov	w11, #0
LBB130_30:
	sub	x12, x29, #144
	add	x12, x12, w11, uxtw #4
	stp	x9, x10, [x12]
	add	w11, w11, #1
LBB130_31:
	sub	x9, x29, #144
	str	x9, [sp, #128]
	str	w11, [sp, #136]
	str	xzr, [sp, #144]
	str	wzr, [sp, #152]
	add	x26, sp, #128
LBB130_32:
	mov	w9, #2147483647
	cmp	x8, x9
	csel	x8, x8, x9, lo
	str	x8, [sp, #8]
	sub	x0, x29, #112
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-104]
	cbnz	w8, LBB130_40
	ldur	x27, [x29, #-112]
LBB130_34:
	add	x3, sp, #8
	mov	x0, x24
	mov	x1, x23
	mov	x2, x25
	mov	x4, x26
	mov	w5, #0
	bl	_sendfile
	cmn	w0, #1
	b.ne	LBB130_51
	bl	___error
	ldr	w28, [x0]
	tbnz	w28, #31, LBB130_60
	cmp	w28, #16, lsl #12
	b.hs	LBB130_60
	cmp	w28, #4
	b.ne	LBB130_41
	ldr	x8, [sp, #8]
	cbnz	x8, LBB130_56
	str	x27, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB130_34
LBB130_40:
	strh	w8, [x19, #8]
	b	LBB130_16
LBB130_41:
	cmp	w28, #37
	b.le	LBB130_47
	cmp	w28, #38
	b.eq	LBB130_45
	cmp	w28, #45
	b.eq	LBB130_45
	cmp	w28, #78
	b.ne	LBB130_52
LBB130_45:
	str	x27, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
LBB130_46:
	mov	w8, #1
	strb	w8, [x22, #858]
	stp	xzr, xzr, [x19]
	b	LBB130_16
LBB130_47:
	cbz	w28, LBB130_51
	cmp	w28, #35
	b.ne	LBB130_52
	str	x27, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	ldr	x8, [sp, #8]
	cbnz	x8, LBB130_13
Lloh905:
	adrp	x8, l___anon_9835@PAGE
Lloh906:
	add	x8, x8, l___anon_9835@PAGEOFF
	b	LBB130_58
LBB130_51:
	add	x0, sp, #16
	str	x27, [x0]
	bl	l_Io.Threaded.Syscall.finish
	ldr	x8, [sp, #8]
	cbnz	x8, LBB130_13
	b	LBB130_57
LBB130_52:
	str	x27, [sp, #56]
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
	cmp	w28, #5
	b.eq	LBB130_59
	cmp	w28, #32
	b.eq	LBB130_55
	cmp	w28, #57
	b.ne	LBB130_46
LBB130_55:
Lloh907:
	adrp	x8, l___anon_9849@PAGE
Lloh908:
	add	x8, x8, l___anon_9849@PAGEOFF
	b	LBB130_58
LBB130_56:
	add	x0, sp, #32
	str	x27, [x0]
	bl	l_Io.Threaded.Syscall.finish
	ldr	x8, [sp, #8]
	cbnz	x8, LBB130_13
LBB130_57:
	ldr	x8, [x20, #16]
	str	x8, [x20, #24]
	mov	w8, #1
	strb	w8, [x20, #32]
Lloh909:
	adrp	x8, l___anon_12314@PAGE
Lloh910:
	add	x8, x8, l___anon_12314@PAGEOFF
LBB130_58:
	ldr	q0, [x8]
	str	q0, [x19]
	b	LBB130_16
LBB130_59:
Lloh911:
	adrp	x8, l___anon_10290@PAGE
Lloh912:
	add	x8, x8, l___anon_10290@PAGEOFF
	b	LBB130_58
LBB130_60:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB130_61:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB130_62:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB130_63:
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB130_64:
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB130_65:
	bl	___stack_chk_fail
LBB130_66:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB130_67:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh887, Lloh888, Lloh889
	.loh AdrpLdrGotLdr	Lloh893, Lloh894, Lloh895
	.loh AdrpAddLdr	Lloh890, Lloh891, Lloh892
	.loh AdrpLdrGotLdr	Lloh896, Lloh897, Lloh898
	.loh AdrpLdrGotLdr	Lloh902, Lloh903, Lloh904
	.loh AdrpAddLdr	Lloh899, Lloh900, Lloh901
	.loh AdrpAdd	Lloh905, Lloh906
	.loh AdrpAdd	Lloh907, Lloh908
	.loh AdrpAdd	Lloh909, Lloh910
	.loh AdrpAdd	Lloh911, Lloh912
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileWritePositional:
	.cfi_startproc
	sub	sp, sp, #336
	.cfi_def_cfa_offset 336
	stp	x26, x25, [sp, #256]
	stp	x24, x23, [sp, #272]
	stp	x22, x21, [sp, #288]
	stp	x20, x19, [sp, #304]
	stp	x29, x30, [sp, #320]
	add	x29, sp, #320
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x19, x8
Lloh913:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh914:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh915:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB131_78
	tst	x0, #0x7
	b.ne	LBB131_79
	mov	x20, x7
	ldr	w21, [x1]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #32]
	cbz	x3, LBB131_4
	stp	x2, x3, [sp, #32]
	mov	w22, #1
	subs	x0, x5, #1
	b.hs	LBB131_5
	b	LBB131_74
LBB131_4:
	mov	w22, #0
	subs	x0, x5, #1
	b.lo	LBB131_74
LBB131_5:
	cmp	x0, x5
	b.hi	LBB131_75
	cbz	x0, LBB131_13
	add	x8, x4, #8
	add	x9, sp, #32
	mov	x10, x0
	b	LBB131_9
LBB131_8:
	add	x8, x8, #16
	subs	x10, x10, #1
	b.eq	LBB131_13
LBB131_9:
	ldr	x11, [x8]
	cbz	x11, LBB131_8
	cmp	w22, #9
	b.hs	LBB131_74
	cmp	w22, #8
	b.eq	LBB131_8
	ldur	x12, [x8, #-8]
	mov	w13, w22
	add	x13, x9, x13, lsl #4
	stp	x12, x11, [x13]
	add	w22, w22, #1
	b	LBB131_8
LBB131_13:
	cmp	x0, x5
	b.hs	LBB131_75
	add	x8, x4, x0, lsl #4
	ldp	x9, x8, [x8]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #192]
	mov	w24, w22
	mov	w10, #8
	subs	x10, x10, x24
	b.lo	LBB131_74
	cbz	x10, LBB131_37
	cbz	x6, LBB131_37
	cmp	x6, #1
	b.ne	LBB131_22
	cbz	x8, LBB131_37
	cmp	w22, #9
	b.hs	LBB131_74
	cmp	w22, #8
	b.eq	LBB131_38
LBB131_21:
	add	x10, sp, #32
	add	x10, x10, x24, lsl #4
	stp	x9, x8, [x10]
	add	w22, w22, #1
	b	LBB131_38
LBB131_22:
	cbz	x8, LBB131_37
	cmp	x8, #1
	b.ne	LBB131_50
	mov	w8, #64
	cmp	x6, #64
	mov	x25, x6
	csel	x23, x6, x8, lo
	ldrb	w1, [x9]
	add	x0, sp, #160
	mov	x2, x23
	bl	_memset
	cmp	w22, #9
	b.hs	LBB131_74
	cmp	w22, #8
	b.eq	LBB131_27
	add	x8, sp, #32
	add	x8, x8, x24, lsl #4
	add	x9, sp, #160
	stp	x9, x23, [x8]
	add	w22, w22, #1
LBB131_27:
	subs	x8, x25, x23
	b.lo	LBB131_74
	cmp	x8, #65
	b.lo	LBB131_33
	cmp	x25, #64
	b.lo	LBB131_71
	mov	w10, w22
	add	x9, sp, #32
	add	x9, x9, w22, uxtw #4
	orr	x9, x9, #0x8
	sub	x10, x10, #8
	add	x11, sp, #160
	mov	w12, #64
LBB131_31:
	cbz	x10, LBB131_73
	sub	x8, x8, #64
	stp	x11, x12, [x9, #-8]
	add	x9, x9, #16
	add	w22, w22, #1
	add	x10, x10, #1
	cmp	x8, #64
	b.hi	LBB131_31
LBB131_33:
	cbz	x8, LBB131_38
	cmp	w22, #9
	b.hs	LBB131_74
	cmp	w22, #8
	b.eq	LBB131_38
	mov	w24, w22
	add	x9, sp, #160
	b	LBB131_21
LBB131_37:
	cbz	w22, LBB131_46
LBB131_38:
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-80]
	cbnz	w8, LBB131_67
	ldur	x23, [x29, #-88]
Lloh916:
	adrp	x24, LJTI131_0@PAGE
Lloh917:
	add	x24, x24, LJTI131_0@PAGEOFF
LBB131_40:
	add	x1, sp, #32
	mov	x0, x21
	mov	x2, x22
	mov	x3, x20
	bl	_pwritev
	cmn	x0, #1
	b.ne	LBB131_55
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB131_77
	cmp	w8, #16, lsl #12
	b.hs	LBB131_77
	cmp	w8, #84
	b.hi	LBB131_48
	adr	x9, LBB131_45
	ldrb	w10, [x24, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB131_45:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB131_40
	b	LBB131_67
LBB131_46:
	stp	xzr, xzr, [x19]
	ldur	x8, [x29, #-72]
Lloh918:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh919:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh920:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB131_80
	.cfi_def_cfa wsp, 336
	b	LBB131_70
LBB131_48:
	.cfi_restore_state
	.cfi_remember_state
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	b	LBB131_67
LBB131_49:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #57
	b	LBB131_67
LBB131_50:
	cmp	x6, x10
	csel	x10, x6, x10, lo
	add	x11, sp, #32
	b	LBB131_52
LBB131_51:
	add	x13, x11, x12, lsl #4
	stp	x9, x8, [x13]
	add	w22, w12, #1
	subs	x10, x10, #1
	b.eq	LBB131_38
LBB131_52:
	cmp	w22, #9
	b.hs	LBB131_74
	mov	w12, w22
	cmp	w12, #8
	b.ne	LBB131_51
	mov	w22, #8
	subs	x10, x10, #1
	b.ne	LBB131_52
	b	LBB131_38
LBB131_55:
	str	x23, [sp, #8]
	mov	x20, x0
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x20, #63, LBB131_77
	str	x20, [x19]
	strh	wzr, [x19, #8]
	b	LBB131_68
LBB131_57:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #9
	b	LBB131_67
LBB131_58:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #14
	b	LBB131_67
LBB131_59:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #3
	b	LBB131_67
LBB131_60:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #18
	b	LBB131_67
LBB131_61:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #15
	b	LBB131_67
LBB131_62:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #20
	b	LBB131_67
LBB131_63:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #16
	b	LBB131_67
LBB131_64:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #17
	b	LBB131_67
LBB131_65:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #22
	b	LBB131_67
LBB131_66:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #19
LBB131_67:
	strh	w8, [x19, #8]
LBB131_68:
	ldur	x8, [x29, #-72]
Lloh921:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh922:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh923:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB131_80
	.cfi_def_cfa wsp, 336
LBB131_70:
	ldp	x29, x30, [sp, #320]
	ldp	x20, x19, [sp, #304]
	ldp	x22, x21, [sp, #288]
	ldp	x24, x23, [sp, #272]
	ldp	x26, x25, [sp, #256]
	add	sp, sp, #336
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB131_71:
	.cfi_restore_state
	cmp	w22, #8
	b.eq	LBB131_38
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB131_73:
	mov	w22, #8
	b	LBB131_38
LBB131_74:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB131_75:
	mov	x1, x5
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB131_76:
	str	x23, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
LBB131_77:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB131_78:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB131_79:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB131_80:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh913, Lloh914, Lloh915
	.loh AdrpAdd	Lloh916, Lloh917
	.loh AdrpLdrGotLdr	Lloh918, Lloh919, Lloh920
	.loh AdrpLdrGotLdr	Lloh921, Lloh922, Lloh923
	.cfi_endproc
	.section	__TEXT,__const
LJTI131_0:
	.byte	(LBB131_76-LBB131_45)>>2
	.byte	(LBB131_60-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_45-LBB131_45)>>2
	.byte	(LBB131_59-LBB131_45)>>2
	.byte	(LBB131_49-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_62-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_64-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_65-LBB131_45)>>2
	.byte	(LBB131_61-LBB131_45)>>2
	.byte	(LBB131_63-LBB131_45)>>2
	.byte	(LBB131_49-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_66-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_57-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_58-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_48-LBB131_45)>>2
	.byte	(LBB131_49-LBB131_45)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.fileWriteStreaming:
	.cfi_startproc
	sub	sp, sp, #336
	.cfi_def_cfa_offset 336
	stp	x28, x27, [sp, #256]
	stp	x24, x23, [sp, #272]
	stp	x22, x21, [sp, #288]
	stp	x20, x19, [sp, #304]
	stp	x29, x30, [sp, #320]
	add	x29, sp, #320
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
Lloh924:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh925:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh926:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	tst	x1, #0x7
	b.ne	LBB132_79
	mov	x20, x2
	mov	x19, x0
	movi.16b	v0, #170
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #32]
	cbz	x4, LBB132_3
	stp	x3, x4, [sp, #32]
	mov	w21, #1
	subs	x0, x6, #1
	b.hs	LBB132_4
	b	LBB132_75
LBB132_3:
	mov	w21, #0
	subs	x0, x6, #1
	b.lo	LBB132_75
LBB132_4:
	cmp	x0, x6
	b.hi	LBB132_78
	cbz	x0, LBB132_12
	add	x8, x5, #8
	add	x9, sp, #32
	mov	x10, x0
	b	LBB132_8
LBB132_7:
	add	x8, x8, #16
	subs	x10, x10, #1
	b.eq	LBB132_12
LBB132_8:
	ldr	x11, [x8]
	cbz	x11, LBB132_7
	cmp	w21, #9
	b.hs	LBB132_75
	cmp	w21, #8
	b.eq	LBB132_7
	ldur	x12, [x8, #-8]
	mov	w13, w21
	add	x13, x9, x13, lsl #4
	stp	x12, x11, [x13]
	add	w21, w21, #1
	b	LBB132_7
LBB132_12:
	cmp	x0, x6
	b.hs	LBB132_78
	add	x8, x5, x0, lsl #4
	ldp	x9, x8, [x8]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #192]
	mov	w23, w21
	mov	w10, #8
	subs	x10, x10, x23
	b.lo	LBB132_75
	cbz	x10, LBB132_36
	cbz	x7, LBB132_36
	cmp	x7, #1
	b.ne	LBB132_21
	cbz	x8, LBB132_36
	cmp	w21, #9
	b.hs	LBB132_75
	cmp	w21, #8
	b.eq	LBB132_37
LBB132_20:
	add	x10, sp, #32
	add	x10, x10, x23, lsl #4
	stp	x9, x8, [x10]
	add	w21, w21, #1
	b	LBB132_37
LBB132_21:
	cbz	x8, LBB132_36
	cmp	x8, #1
	b.ne	LBB132_53
	mov	w8, #64
	cmp	x7, #64
	mov	x24, x7
	csel	x22, x7, x8, lo
	ldrb	w1, [x9]
	add	x0, sp, #160
	mov	x2, x22
	bl	_memset
	cmp	w21, #9
	b.hs	LBB132_75
	cmp	w21, #8
	b.eq	LBB132_26
	add	x8, sp, #32
	add	x8, x8, x23, lsl #4
	add	x9, sp, #160
	stp	x9, x22, [x8]
	add	w21, w21, #1
LBB132_26:
	subs	x8, x24, x22
	b.lo	LBB132_75
	cmp	x8, #65
	b.lo	LBB132_32
	cmp	x24, #64
	b.lo	LBB132_72
	mov	w10, w21
	add	x9, sp, #32
	add	x9, x9, w21, uxtw #4
	orr	x9, x9, #0x8
	sub	x10, x10, #8
	add	x11, sp, #160
	mov	w12, #64
LBB132_30:
	cbz	x10, LBB132_74
	sub	x8, x8, #64
	stp	x11, x12, [x9, #-8]
	add	x9, x9, #16
	add	w21, w21, #1
	add	x10, x10, #1
	cmp	x8, #64
	b.hi	LBB132_30
LBB132_32:
	cbz	x8, LBB132_37
	cmp	w21, #9
	b.hs	LBB132_75
	cmp	w21, #8
	b.eq	LBB132_37
	mov	w23, w21
	add	x9, sp, #160
	b	LBB132_20
LBB132_36:
	cbz	w21, LBB132_51
LBB132_37:
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-80]
	cbnz	w8, LBB132_50
	ldur	x22, [x29, #-88]
LBB132_39:
	add	x1, sp, #32
	mov	x0, x20
	mov	x2, x21
	bl	_writev
	cmn	x0, #1
	b.ne	LBB132_44
	bl	___error
	ldr	w23, [x0]
	tbnz	w23, #31, LBB132_77
	cmp	w23, #16, lsl #12
	b.hs	LBB132_77
	cmp	w23, #4
	b.ne	LBB132_46
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB132_39
	b	LBB132_50
LBB132_44:
	str	x22, [sp, #8]
	mov	x20, x0
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x20, #63, LBB132_77
	str	x20, [x19]
	strh	wzr, [x19, #8]
	b	LBB132_69
LBB132_46:
	cbz	w23, LBB132_76
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w23, #1
	cmp	w8, #68
	b.hi	LBB132_49
Lloh927:
	adrp	x9, LJTI132_0@PAGE
Lloh928:
	add	x9, x9, LJTI132_0@PAGEOFF
	adr	x10, LBB132_49
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB132_49:
	mov	w8, #12
LBB132_50:
	strh	w8, [x19, #8]
	b	LBB132_69
LBB132_51:
	stp	xzr, xzr, [x19]
	ldur	x8, [x29, #-72]
Lloh929:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh930:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh931:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB132_80
	.cfi_def_cfa wsp, 336
	b	LBB132_71
LBB132_53:
	.cfi_restore_state
	.cfi_remember_state
	cmp	x7, x10
	csel	x10, x7, x10, lo
	add	x11, sp, #32
	b	LBB132_55
LBB132_54:
	add	x13, x11, x12, lsl #4
	stp	x9, x8, [x13]
	add	w21, w12, #1
	subs	x10, x10, #1
	b.eq	LBB132_37
LBB132_55:
	cmp	w21, #9
	b.hs	LBB132_75
	mov	w12, w21
	cmp	w12, #8
	b.ne	LBB132_54
	mov	w21, #8
	subs	x10, x10, #1
	b.ne	LBB132_55
	b	LBB132_37
LBB132_58:
Lloh932:
	adrp	x8, l___anon_9839@PAGE
Lloh933:
	add	x8, x8, l___anon_9839@PAGEOFF
	b	LBB132_68
LBB132_59:
Lloh934:
	adrp	x8, l___anon_10327@PAGE
Lloh935:
	add	x8, x8, l___anon_10327@PAGEOFF
	b	LBB132_68
LBB132_60:
Lloh936:
	adrp	x8, l___anon_10329@PAGE
Lloh937:
	add	x8, x8, l___anon_10329@PAGEOFF
	b	LBB132_68
LBB132_61:
Lloh938:
	adrp	x8, l___anon_9835@PAGE
Lloh939:
	add	x8, x8, l___anon_9835@PAGEOFF
	b	LBB132_68
LBB132_62:
Lloh940:
	adrp	x8, l___anon_10290@PAGE
Lloh941:
	add	x8, x8, l___anon_10290@PAGEOFF
	b	LBB132_68
LBB132_63:
Lloh942:
	adrp	x8, l___anon_9849@PAGE
Lloh943:
	add	x8, x8, l___anon_9849@PAGEOFF
	b	LBB132_68
LBB132_64:
Lloh944:
	adrp	x8, l___anon_9837@PAGE
Lloh945:
	add	x8, x8, l___anon_9837@PAGEOFF
	b	LBB132_68
LBB132_65:
Lloh946:
	adrp	x8, l___anon_10280@PAGE
Lloh947:
	add	x8, x8, l___anon_10280@PAGEOFF
	b	LBB132_68
LBB132_66:
Lloh948:
	adrp	x8, l___anon_10315@PAGE
Lloh949:
	add	x8, x8, l___anon_10315@PAGEOFF
	b	LBB132_68
LBB132_67:
Lloh950:
	adrp	x8, l___anon_10333@PAGE
Lloh951:
	add	x8, x8, l___anon_10333@PAGEOFF
LBB132_68:
	ldr	q0, [x8]
	str	q0, [x19]
LBB132_69:
	ldur	x8, [x29, #-72]
Lloh952:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh953:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh954:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB132_80
	.cfi_def_cfa wsp, 336
LBB132_71:
	ldp	x29, x30, [sp, #320]
	ldp	x20, x19, [sp, #304]
	ldp	x22, x21, [sp, #288]
	ldp	x24, x23, [sp, #272]
	ldp	x28, x27, [sp, #256]
	add	sp, sp, #336
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB132_72:
	.cfi_restore_state
	cmp	w21, #8
	b.eq	LBB132_37
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB132_74:
	mov	w21, #8
	b	LBB132_37
LBB132_75:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB132_76:
	str	x22, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
LBB132_77:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB132_78:
	mov	x1, x6
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB132_79:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB132_80:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh924, Lloh925, Lloh926
	.loh AdrpAdd	Lloh927, Lloh928
	.loh AdrpLdrGotLdr	Lloh929, Lloh930, Lloh931
	.loh AdrpAdd	Lloh932, Lloh933
	.loh AdrpAdd	Lloh934, Lloh935
	.loh AdrpAdd	Lloh936, Lloh937
	.loh AdrpAdd	Lloh938, Lloh939
	.loh AdrpAdd	Lloh940, Lloh941
	.loh AdrpAdd	Lloh942, Lloh943
	.loh AdrpAdd	Lloh944, Lloh945
	.loh AdrpAdd	Lloh946, Lloh947
	.loh AdrpAdd	Lloh948, Lloh949
	.loh AdrpAdd	Lloh950, Lloh951
	.loh AdrpLdrGotLdr	Lloh952, Lloh953, Lloh954
	.cfi_endproc
	.section	__TEXT,__const
LJTI132_0:
	.byte	(LBB132_60-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_62-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_64-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_65-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_67-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_66-LBB132_49)>>2
	.byte	(LBB132_59-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_63-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_61-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_49-LBB132_49)>>2
	.byte	(LBB132_58-LBB132_49)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.fileClose:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB133_10
	tst	x0, #0x7
	b.ne	LBB133_11
	mov	x19, x2
	cbz	x2, LBB133_9
	mov	x20, x1
	b	LBB133_5
LBB133_4:
	subs	x19, x19, #1
	b.eq	LBB133_9
LBB133_5:
	ldr	w0, [x20], #8
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB133_4
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB133_8
	cmp	w8, #16, lsl #12
	b.lo	LBB133_4
LBB133_8:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB133_9:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB133_10:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB133_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileLength:
	.cfi_startproc
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x20, x19, [sp, #144]
	stp	x29, x30, [sp, #160]
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh955:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh956:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh957:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-24]
	cbz	x0, LBB134_6
	tst	x0, #0x7
	b.ne	LBB134_7
	add	x8, sp, #16
	bl	l_Io.Threaded.fileStatPosix
	ldrh	w8, [sp, #112]
	cbnz	w8, LBB134_4
	ldr	x9, [sp, #88]
	str	x9, [x19]
LBB134_4:
	strh	w8, [x19, #8]
	ldur	x8, [x29, #-24]
Lloh958:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh959:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh960:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB134_8
	.cfi_def_cfa wsp, 176
	ldp	x29, x30, [sp, #160]
	ldp	x20, x19, [sp, #144]
	add	sp, sp, #176
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB134_6:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB134_7:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB134_8:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh955, Lloh956, Lloh957
	.loh AdrpLdrGotLdr	Lloh958, Lloh959, Lloh960
	.cfi_endproc

	.p2align	2
l_Io.Threaded.fileStatPosix:
	.cfi_startproc
	sub	sp, sp, #272
	.cfi_def_cfa_offset 272
	stp	x28, x27, [sp, #208]
	stp	x22, x21, [sp, #224]
	stp	x20, x19, [sp, #240]
	stp	x29, x30, [sp, #256]
	add	x29, sp, #256
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	.cfi_remember_state
	mov	x19, x8
Lloh961:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh962:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh963:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-56]
	cbz	x0, LBB135_26
	tst	x0, #0x7
	b.ne	LBB135_27
	ldr	w20, [x1]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #40]
	cbnz	w8, LBB135_20
	ldr	x21, [sp, #32]
LBB135_4:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #64]
	str	q0, [sp, #48]
	add	x1, sp, #48
	mov	x0, x20
	bl	_fstat
	cmn	w0, #1
	b.ne	LBB135_10
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB135_25
	cmp	w22, #16, lsl #12
	b.hs	LBB135_25
	cmp	w22, #4
	b.ne	LBB135_9
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB135_4
	b	LBB135_20
LBB135_9:
	cbnz	w22, LBB135_12
LBB135_10:
	str	x21, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	ldr	w8, [sp, #160]
	tbnz	w8, #31, LBB135_25
	ldrh	w9, [sp, #52]
	ldrh	w10, [sp, #54]
	ldr	x11, [sp, #144]
	ldp	x14, x12, [sp, #112]
	asr	x13, x12, #63
	ldp	x17, x15, [sp, #96]
	asr	x16, x15, #63
	ldp	x3, x0, [sp, #80]
	asr	x1, x0, #63
	ldr	x2, [sp, #56]
	mov	w4, #51712
	movk	w4, #15258, lsl #16
	smulh	x5, x14, x4
	mul	x14, x14, x4
	adds	x12, x14, x12
	adc	x13, x5, x13
	smulh	x14, x17, x4
	mul	x17, x17, x4
	adds	x15, x17, x15
	adc	x14, x14, x16
	smulh	x16, x3, x4
	mul	x17, x3, x4
	adds	x17, x17, x0
	adc	x16, x16, x1
	sxtw	x16, w16
	stp	x17, x16, [x19]
	lsr	x16, x9, #10
	and	x16, x16, #0x3c
	mov	x17, #41274
	movk	x17, #41122, lsl #16
	movk	x17, #42149, lsl #32
	movk	x17, #43686, lsl #48
	lsr	x16, x17, x16
	sxtw	x13, w13
	sxtw	x14, w14
	and	w16, w16, #0xf
	mov	w17, #1
	strb	w17, [x19, #16]
	stp	x15, x14, [x19, #32]
	stp	x12, x13, [x19, #48]
	stp	x2, x11, [x19, #64]
	str	w8, [x19, #80]
	strh	w10, [x19, #84]
	strh	w9, [x19, #86]
	strb	w16, [x19, #88]
	strh	wzr, [x19, #96]
	ldur	x8, [x29, #-56]
Lloh964:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh965:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh966:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB135_21
	b	LBB135_28
LBB135_12:
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	cmp	w22, #12
	b.gt	LBB135_17
	cmp	w22, #9
	b.eq	LBB135_19
	cmp	w22, #12
	b.ne	LBB135_19
Lloh967:
	adrp	x8, l___anon_10641@PAGE
Lloh968:
	add	x8, x8, l___anon_10641@PAGEOFF
	ldp	q0, q1, [x8, #64]
	stp	q0, q1, [x19, #64]
	ldr	q0, [x8, #96]
	str	q0, [x19, #96]
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldp	q1, q0, [x8, #32]
	stp	q1, q0, [x19, #32]
	ldur	x8, [x29, #-56]
Lloh969:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh970:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh971:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB135_28
	.cfi_def_cfa wsp, 272
	b	LBB135_22
LBB135_17:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w22, #13
	b.eq	LBB135_23
	cmp	w22, #22
LBB135_19:
	mov	w8, #12
LBB135_20:
	strh	w8, [x19, #96]
	ldur	x8, [x29, #-56]
Lloh972:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh973:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh974:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB135_28
LBB135_21:
	.cfi_def_cfa wsp, 272
LBB135_22:
	ldp	x29, x30, [sp, #256]
	ldp	x20, x19, [sp, #240]
	ldp	x22, x21, [sp, #224]
	ldp	x28, x27, [sp, #208]
	add	sp, sp, #272
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB135_23:
	.cfi_restore_state
	.cfi_remember_state
Lloh975:
	adrp	x8, l___anon_10643@PAGE
Lloh976:
	add	x8, x8, l___anon_10643@PAGEOFF
	ldp	q0, q1, [x8, #64]
	stp	q0, q1, [x19, #64]
	ldr	q0, [x8, #96]
	str	q0, [x19, #96]
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldp	q1, q0, [x8, #32]
	stp	q1, q0, [x19, #32]
	ldur	x8, [x29, #-56]
Lloh977:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh978:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh979:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB135_28
	.cfi_def_cfa wsp, 272
	b	LBB135_22
LBB135_25:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB135_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB135_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB135_28:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh961, Lloh962, Lloh963
	.loh AdrpLdrGotLdr	Lloh964, Lloh965, Lloh966
	.loh AdrpLdrGotLdr	Lloh969, Lloh970, Lloh971
	.loh AdrpAdd	Lloh967, Lloh968
	.loh AdrpLdrGotLdr	Lloh972, Lloh973, Lloh974
	.loh AdrpLdrGotLdr	Lloh977, Lloh978, Lloh979
	.loh AdrpAdd	Lloh975, Lloh976
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirHardLink:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	sub	sp, sp, #2144
Lloh980:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh981:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh982:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB136_32
	tst	x0, #0x7
	b.ne	LBB136_33
	mov	x22, x6
	mov	x23, x5
	mov	x21, x3
	mov	x24, x2
	ldr	w19, [x1]
	ldr	w20, [x4]
	ldrb	w25, [x7]
	add	x0, sp, #24
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	add	x0, sp, #1048
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #136
	add	x3, sp, #24
	mov	x1, x24
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-120]
	cbnz	w0, LBB136_29
	ldur	x21, [x29, #-136]
	sub	x0, x29, #112
	add	x3, sp, #1048
	mov	x1, x23
	mov	x2, x22
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-96]
	cbnz	w0, LBB136_29
	ldur	x22, [x29, #-112]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB136_29
	lsl	w23, w25, #6
	ldur	x24, [x29, #-88]
Lloh983:
	adrp	x25, LJTI136_0@PAGE
Lloh984:
	add	x25, x25, LJTI136_0@PAGEOFF
LBB136_6:
	mov	x0, x19
	mov	x1, x21
	mov	x2, x20
	mov	x3, x22
	mov	x4, x23
	bl	_linkat
	cmn	w0, #1
	b.ne	LBB136_13
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB136_31
	cmp	w8, #16, lsl #12
	b.hs	LBB136_31
	cmp	w8, #92
	b.hi	LBB136_12
	adr	x9, LBB136_11
	ldrb	w10, [x25, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB136_11:
	str	x24, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB136_6
	b	LBB136_29
LBB136_12:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB136_29
LBB136_13:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB136_29
LBB136_14:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #44
	b	LBB136_29
LBB136_15:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #53
	b	LBB136_29
LBB136_16:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #38
	b	LBB136_29
LBB136_17:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #40
	b	LBB136_29
LBB136_18:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #4
	b	LBB136_29
LBB136_19:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB136_29
LBB136_20:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #54
	b	LBB136_29
LBB136_21:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #36
	b	LBB136_29
LBB136_22:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #37
	b	LBB136_29
LBB136_23:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #43
	b	LBB136_29
LBB136_24:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #16
	b	LBB136_29
LBB136_25:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
	b	LBB136_29
LBB136_26:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #41
	b	LBB136_29
LBB136_27:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #39
	b	LBB136_29
LBB136_28:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #14
LBB136_29:
	ldur	x8, [x29, #-72]
Lloh985:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh986:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh987:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB136_34
	add	sp, sp, #2144
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB136_31:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB136_32:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB136_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB136_34:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh980, Lloh981, Lloh982
	.loh AdrpAdd	Lloh983, Lloh984
	.loh AdrpLdrGotLdr	Lloh985, Lloh986, Lloh987
	.cfi_endproc
	.section	__TEXT,__const
LJTI136_0:
	.byte	(LBB136_13-LBB136_11)>>2
	.byte	(LBB136_25-LBB136_11)>>2
	.byte	(LBB136_27-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_11-LBB136_11)>>2
	.byte	(LBB136_20-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_18-LBB136_11)>>2
	.byte	(LBB136_19-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_21-LBB136_11)>>2
	.byte	(LBB136_15-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_17-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_24-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_26-LBB136_11)>>2
	.byte	(LBB136_16-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_22-LBB136_11)>>2
	.byte	(LBB136_23-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_28-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_12-LBB136_11)>>2
	.byte	(LBB136_14-LBB136_11)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirSetTimestamps:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #1152
Lloh988:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh989:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh990:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-88]
	cbz	x0, LBB137_41
	tst	x0, #0x7
	b.ne	LBB137_42
	mov	x20, x3
	mov	x21, x2
	ldr	w19, [x1]
	ldp	x23, x27, [x4]
	ldrb	w8, [x4, #16]
	ldp	x22, x25, [x4, #32]
	ldrb	w9, [x4, #48]
	ldrb	w24, [x4, #64]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #48]
	and	w26, w9, #0x3
	and	w8, w8, #0x3
	cmp	w26, #1
	ccmp	w8, #1, #0, eq
	b.eq	LBB137_6
	cmp	w8, #1
	b.gt	LBB137_7
Lloh991:
	adrp	x9, l___anon_9523@PAGE
Lloh992:
	add	x9, x9, l___anon_9523@PAGEOFF
Lloh993:
	adrp	x10, l___anon_9526@PAGE
Lloh994:
	add	x10, x10, l___anon_9526@PAGEOFF
	cmp	w8, #0
	csel	x8, x9, x10, eq
	ldr	q0, [x8]
	str	q0, [sp, #48]
	cmp	w26, #1
	b.gt	LBB137_11
LBB137_5:
Lloh995:
	adrp	x8, l___anon_9523@PAGE
Lloh996:
	add	x8, x8, l___anon_9523@PAGEOFF
Lloh997:
	adrp	x9, l___anon_9526@PAGE
Lloh998:
	add	x9, x9, l___anon_9526@PAGEOFF
	cmp	w26, #0
	csel	x8, x8, x9, eq
	b	LBB137_15
LBB137_6:
	mov	x22, #0
	b	LBB137_16
LBB137_7:
	cmp	w8, #2
	b.ne	LBB137_44
	sxtw	x1, w27
	mov	x0, x23
	mov	w2, #51712
	movk	w2, #15258, lsl #16
	mov	x3, #0
	bl	___divti3
	mov	x8, #-51712
	movk	x8, #50277, lsl #16
	umulh	x9, x0, x8
	sub	x9, x9, x0
	madd	x9, x1, x8, x9
	mul	x8, x0, x8
	adds	x8, x8, x23
	adc	x9, x9, x27
	sxtw	x10, w9
	asr	x11, x10, #63
	adds	x9, x0, x10, asr #31
	adc	x11, x11, x1
	sxtw	x11, w11
	mov	x12, #9223372036854775807
	cmp	x12, x9
	mov	x12, #-1
	sbcs	xzr, x12, x11
	b.ge	LBB137_40
	mov	x12, #-9223372036854775808
	cmp	x9, x12
	sbcs	xzr, x11, xzr
	b.ge	LBB137_40
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	and	x10, x11, x10, lsr #31
	add	x8, x10, x8
	stp	x9, x8, [sp, #32]
	add	x8, sp, #32
	ldr	q0, [x8]
	str	q0, [sp, #48]
	cmp	w26, #1
	b.le	LBB137_5
LBB137_11:
	cmp	w26, #2
	b.ne	LBB137_44
	sxtw	x1, w25
	mov	x0, x22
	mov	w2, #51712
	movk	w2, #15258, lsl #16
	mov	x3, #0
	bl	___divti3
	mov	x8, #-51712
	movk	x8, #50277, lsl #16
	umulh	x9, x0, x8
	sub	x9, x9, x0
	madd	x9, x1, x8, x9
	mul	x8, x0, x8
	adds	x8, x8, x22
	adc	x9, x9, x25
	sxtw	x10, w9
	asr	x11, x10, #63
	adds	x9, x0, x10, asr #31
	adc	x11, x11, x1
	sxtw	x11, w11
	mov	x12, #9223372036854775807
	cmp	x12, x9
	mov	x12, #-1
	sbcs	xzr, x12, x11
	b.ge	LBB137_40
	mov	x12, #-9223372036854775808
	cmp	x9, x12
	sbcs	xzr, x11, xzr
	b.ge	LBB137_40
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	and	x10, x11, x10, lsr #31
	add	x8, x10, x8
	stp	x9, x8, [sp, #32]
	add	x8, sp, #32
LBB137_15:
	add	x9, sp, #48
	ldr	q0, [x8]
	stur	q0, [x9, #16]
	add	x22, sp, #48
LBB137_16:
	tst	w24, #0x1
	mov	w8, #32
	csel	w23, wzr, w8, ne
	add	x0, sp, #80
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #128
	add	x3, sp, #80
	mov	x1, x21
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-112]
	cbnz	w0, LBB137_38
	ldur	x20, [x29, #-128]
	sub	x0, x29, #104
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-96]
	cbnz	w0, LBB137_38
	ldur	x21, [x29, #-104]
LBB137_19:
	mov	x0, x19
	mov	x1, x20
	mov	x2, x22
	mov	x3, x23
	bl	_utimensat
	cmn	w0, #1
	b.ne	LBB137_31
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB137_40
	cmp	w8, #16, lsl #12
	b.hs	LBB137_40
	cmp	w8, #4
	b.ne	LBB137_24
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB137_19
	b	LBB137_38
LBB137_24:
	cmp	w8, #12
	b.le	LBB137_28
	cmp	w8, #21
	b.gt	LBB137_32
	cmp	w8, #13
	b.eq	LBB137_36
	cmp	w8, #14
	b	LBB137_35
LBB137_28:
	cbz	w8, LBB137_31
	cmp	w8, #1
	b.eq	LBB137_37
	cmp	w8, #9
	b	LBB137_35
LBB137_31:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB137_38
LBB137_32:
	cmp	w8, #22
	b.eq	LBB137_35
	cmp	w8, #30
	b.ne	LBB137_35
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #41
	b	LBB137_38
LBB137_35:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB137_38
LBB137_36:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB137_38
LBB137_37:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
LBB137_38:
	ldur	x8, [x29, #-88]
Lloh999:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1000:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1001:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB137_43
	add	sp, sp, #1152
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB137_40:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB137_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB137_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB137_43:
	bl	___stack_chk_fail
LBB137_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh988, Lloh989, Lloh990
	.loh AdrpAdd	Lloh993, Lloh994
	.loh AdrpAdd	Lloh991, Lloh992
	.loh AdrpAdd	Lloh997, Lloh998
	.loh AdrpAdd	Lloh995, Lloh996
	.loh AdrpLdrGotLdr	Lloh999, Lloh1000, Lloh1001
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirSetFilePermissions:
	.cfi_startproc
	stp	x28, x27, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
	sub	sp, sp, #1104
Lloh1002:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1003:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1004:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-72]
	cbz	x0, LBB138_28
	tst	x0, #0x7
	b.ne	LBB138_29
	mov	x19, x4
	mov	x21, x3
	mov	x22, x2
	ldr	w20, [x1]
	ldrb	w23, [x5]
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #112
	add	x3, sp, #32
	mov	x1, x22
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-96]
	cbnz	w0, LBB138_12
	ldur	x21, [x29, #-112]
	tst	w23, #0x1
	mov	w8, #32
	csel	w22, wzr, w8, ne
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB138_12
	ldur	x23, [x29, #-88]
LBB138_5:
	and	w2, w19, #0xffff
	mov	x0, x20
	mov	x1, x21
	mov	x3, x22
	bl	_fchmodat
	cmn	w0, #1
	b.ne	LBB138_11
	bl	___error
	ldr	w24, [x0]
	tbnz	w24, #31, LBB138_27
	cmp	w24, #16, lsl #12
	b.hs	LBB138_27
	cmp	w24, #4
	b.ne	LBB138_10
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB138_5
	b	LBB138_12
LBB138_10:
	cbnz	w24, LBB138_14
LBB138_11:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB138_12:
	ldur	x8, [x29, #-72]
Lloh1005:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1006:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1007:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB138_30
	add	sp, sp, #1104
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x28, x27, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB138_14:
	.cfi_restore_state
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w24, #1
	cmp	w8, #62
	b.hi	LBB138_26
	mov	w0, #10
Lloh1008:
	adrp	x9, LJTI138_0@PAGE
Lloh1009:
	add	x9, x9, LJTI138_0@PAGEOFF
	adr	x10, LBB138_12
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB138_16:
	mov	w0, #39
	b	LBB138_12
LBB138_17:
	mov	w0, #37
	b	LBB138_12
LBB138_18:
	mov	w0, #4
	b	LBB138_12
LBB138_19:
	mov	w0, #43
	b	LBB138_12
LBB138_20:
	mov	w0, #24
	b	LBB138_12
LBB138_21:
	mov	w0, #18
	b	LBB138_12
LBB138_22:
	mov	w0, #23
	b	LBB138_12
LBB138_23:
	mov	w0, #3
	b	LBB138_12
LBB138_24:
	mov	w0, #49
	b	LBB138_12
LBB138_25:
	mov	w0, #41
	b	LBB138_12
LBB138_26:
	mov	w0, #12
	b	LBB138_12
LBB138_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB138_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB138_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB138_30:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1002, Lloh1003, Lloh1004
	.loh AdrpLdrGotLdr	Lloh1005, Lloh1006, Lloh1007
	.loh AdrpAdd	Lloh1008, Lloh1009
	.cfi_endproc
	.section	__TEXT,__const
LJTI138_0:
	.byte	(LBB138_21-LBB138_12)>>2
	.byte	(LBB138_16-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_23-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_18-LBB138_12)>>2
	.byte	(LBB138_12-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_16-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_20-LBB138_12)>>2
	.byte	(LBB138_22-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_25-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_24-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_26-LBB138_12)>>2
	.byte	(LBB138_17-LBB138_12)>>2
	.byte	(LBB138_19-LBB138_12)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirSetPermissionsPosix:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh1010:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1011:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1012:
	ldr	x8, [x8]
	str	x8, [sp]
	cbz	x0, LBB139_33
	tst	x0, #0x7
	b.ne	LBB139_34
	mov	x19, x2
	ldr	w20, [x1]
	str	x8, [sp, #40]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #32]
	cbnz	w0, LBB139_11
	ldr	x22, [sp, #24]
LBB139_4:
	and	w1, w19, #0xffff
	mov	x0, x20
	bl	_fchmod
	cmn	w0, #1
	b.ne	LBB139_10
	bl	___error
	ldr	w21, [x0]
	tbnz	w21, #31, LBB139_32
	cmp	w21, #16, lsl #12
	b.hs	LBB139_32
	cmp	w21, #4
	b.ne	LBB139_9
	str	x22, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB139_4
	b	LBB139_11
LBB139_9:
	cbnz	w21, LBB139_13
LBB139_10:
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB139_11:
	ldr	x8, [sp, #40]
Lloh1013:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1014:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1015:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB139_35
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB139_13:
	.cfi_restore_state
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	cmp	w21, #12
	b.gt	LBB139_17
	cmp	w21, #4
	b.gt	LBB139_21
	cmp	w21, #1
	b.eq	LBB139_27
	cmp	w21, #2
	b.eq	LBB139_20
	b	LBB139_31
LBB139_17:
	cmp	w21, #29
	b.gt	LBB139_24
	cmp	w21, #13
	b.eq	LBB139_28
	cmp	w21, #20
	b.ne	LBB139_31
LBB139_20:
	mov	w0, #39
	b	LBB139_11
LBB139_21:
	cmp	w21, #5
	b.eq	LBB139_29
	cmp	w21, #12
	b.ne	LBB139_31
	mov	w0, #4
	b	LBB139_11
LBB139_24:
	cmp	w21, #30
	b.eq	LBB139_30
	cmp	w21, #62
	b.ne	LBB139_31
	mov	w0, #37
	b	LBB139_11
LBB139_27:
	mov	w0, #18
	b	LBB139_11
LBB139_28:
	mov	w0, #10
	b	LBB139_11
LBB139_29:
	mov	w0, #3
	b	LBB139_11
LBB139_30:
	mov	w0, #41
	b	LBB139_11
LBB139_31:
	mov	w0, #12
	b	LBB139_11
LBB139_32:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB139_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB139_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB139_35:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1010, Lloh1011, Lloh1012
	.loh AdrpLdrGotLdr	Lloh1013, Lloh1014, Lloh1015
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirSetFileOwner:
	.cfi_startproc
	stp	x28, x27, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w27, -40
	.cfi_offset w28, -48
	.cfi_remember_state
	sub	sp, sp, #1072
Lloh1016:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1017:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1018:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB140_6
	tst	x0, #0x7
	b.ne	LBB140_7
	mov	x19, x3
	mov	x20, x2
	add	x0, sp, #16
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #64
	add	x3, sp, #16
	mov	x1, x20
	mov	x2, x19
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-48]
	cbnz	w0, LBB140_4
Lloh1019:
	adrp	x0, l___anon_10117@PAGE
Lloh1020:
	add	x0, x0, l___anon_10117@PAGEOFF
	mov	w1, #30
	bl	l_debug.defaultPanic
LBB140_4:
	ldur	x8, [x29, #-40]
Lloh1021:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1022:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1023:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB140_8
	add	sp, sp, #1072
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x28, x27, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB140_6:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB140_7:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB140_8:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1016, Lloh1017, Lloh1018
	.loh AdrpAdd	Lloh1019, Lloh1020
	.loh AdrpLdrGotLdr	Lloh1021, Lloh1022, Lloh1023
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirSetOwnerPosix:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
Lloh1024:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1025:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1026:
	ldr	x8, [x8]
	str	x8, [sp]
	cbz	x0, LBB141_38
	tst	x0, #0x7
	b.ne	LBB141_39
	ldrb	w8, [x2, #4]
	tbz	w8, #0, LBB141_5
	ldr	w19, [x2]
	ldrb	w8, [x3, #4]
	tbnz	w8, #0, LBB141_6
LBB141_4:
	mov	w20, #-1
	b	LBB141_7
LBB141_5:
	mov	w19, #-1
	ldrb	w8, [x3, #4]
	tbz	w8, #0, LBB141_4
LBB141_6:
	ldr	w20, [x3]
LBB141_7:
	ldr	w21, [x1]
Lloh1027:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1028:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1029:
	ldr	x8, [x8]
	str	x8, [sp, #40]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #32]
	cbnz	w0, LBB141_16
	ldr	x23, [sp, #24]
LBB141_9:
	mov	x0, x21
	mov	x1, x19
	mov	x2, x20
	bl	_fchown
	cmn	w0, #1
	b.ne	LBB141_15
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB141_37
	cmp	w22, #16, lsl #12
	b.hs	LBB141_37
	cmp	w22, #4
	b.ne	LBB141_14
	str	x23, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB141_9
	b	LBB141_16
LBB141_14:
	cbnz	w22, LBB141_18
LBB141_15:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB141_16:
	ldr	x8, [sp, #40]
Lloh1030:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1031:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1032:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB141_40
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB141_18:
	.cfi_restore_state
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	cmp	w22, #12
	b.gt	LBB141_22
	cmp	w22, #4
	b.gt	LBB141_26
	cmp	w22, #1
	b.eq	LBB141_32
	cmp	w22, #2
	b.eq	LBB141_25
	b	LBB141_36
LBB141_22:
	cmp	w22, #29
	b.gt	LBB141_29
	cmp	w22, #13
	b.eq	LBB141_33
	cmp	w22, #20
	b.ne	LBB141_36
LBB141_25:
	mov	w0, #39
	b	LBB141_16
LBB141_26:
	cmp	w22, #5
	b.eq	LBB141_34
	cmp	w22, #12
	b.ne	LBB141_36
	mov	w0, #4
	b	LBB141_16
LBB141_29:
	cmp	w22, #30
	b.eq	LBB141_35
	cmp	w22, #62
	b.ne	LBB141_36
	mov	w0, #37
	b	LBB141_16
LBB141_32:
	mov	w0, #18
	b	LBB141_16
LBB141_33:
	mov	w0, #10
	b	LBB141_16
LBB141_34:
	mov	w0, #3
	b	LBB141_16
LBB141_35:
	mov	w0, #41
	b	LBB141_16
LBB141_36:
	mov	w0, #12
	b	LBB141_16
LBB141_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB141_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB141_39:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB141_40:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1024, Lloh1025, Lloh1026
	.loh AdrpLdrGotLdr	Lloh1027, Lloh1028, Lloh1029
	.loh AdrpLdrGotLdr	Lloh1030, Lloh1031, Lloh1032
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirReadLink:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #1104
	mov	x19, x8
Lloh1033:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1034:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1035:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-88]
	cbz	x0, LBB142_37
	tst	x0, #0x7
	b.ne	LBB142_38
	mov	x20, x5
	mov	x21, x4
	mov	x22, x3
	mov	x24, x2
	ldr	w23, [x1]
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #128
	add	x3, sp, #32
	mov	x1, x24
	mov	x2, x22
	bl	l_Io.Threaded.pathToPosix
	ldurh	w8, [x29, #-112]
	cbnz	w8, LBB142_33
	ldur	x24, [x29, #-128]
	sub	x0, x29, #104
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-96]
	cbnz	w8, LBB142_33
	ldur	x26, [x29, #-104]
LBB142_5:
	mov	x0, x23
	mov	x1, x24
	mov	x2, x21
	mov	x3, x20
	bl	_readlinkat
	mov	x22, x0
	cmn	x0, #1
	b.ne	LBB142_11
	bl	___error
	ldr	w25, [x0]
	tbnz	w25, #31, LBB142_36
	cmp	w25, #16, lsl #12
	b.hs	LBB142_36
	cmp	w25, #4
	b.ne	LBB142_10
	str	x26, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB142_5
	b	LBB142_33
LBB142_10:
	cbnz	w25, LBB142_12
LBB142_11:
	str	x26, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #0
	b	LBB142_34
LBB142_12:
	str	x26, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	cmp	w25, #19
	b.le	LBB142_18
	cmp	w25, #61
	b.le	LBB142_25
	cmp	w25, #62
	b.eq	LBB142_30
	cmp	w25, #63
	b.eq	LBB142_32
	cmp	w25, #92
	b.ne	LBB142_34
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #44
	b	LBB142_33
LBB142_18:
	cmp	w25, #11
	b.gt	LBB142_22
	cmp	w25, #2
	b.eq	LBB142_28
	cmp	w25, #5
	b.ne	LBB142_34
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #50
	b	LBB142_33
LBB142_22:
	cmp	w25, #12
	b.eq	LBB142_29
	cmp	w25, #13
	b.ne	LBB142_34
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #10
	b	LBB142_33
LBB142_25:
	cmp	w25, #20
	b.eq	LBB142_31
	cmp	w25, #22
	b.ne	LBB142_34
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #55
	b	LBB142_33
LBB142_28:
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #39
	b	LBB142_33
LBB142_29:
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #4
	b	LBB142_33
LBB142_30:
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #37
	b	LBB142_33
LBB142_31:
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #40
	b	LBB142_33
LBB142_32:
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	mov	w8, #43
LBB142_33:
LBB142_34:
	str	x22, [x19]
	strh	w8, [x19, #8]
	ldr	w8, [sp, #24]
	stur	w8, [x19, #10]
	ldrh	w8, [sp, #28]
	strh	w8, [x19, #14]
	ldur	x8, [x29, #-88]
Lloh1036:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1037:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1038:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB142_39
	add	sp, sp, #1104
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB142_36:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB142_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB142_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB142_39:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1033, Lloh1034, Lloh1035
	.loh AdrpLdrGotLdr	Lloh1036, Lloh1037, Lloh1038
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirSymLinkPosix:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	sub	sp, sp, #2160
Lloh1039:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1040:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1041:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB143_31
	tst	x0, #0x7
	b.ne	LBB143_32
	mov	x21, x5
	mov	x22, x4
	mov	x20, x3
	mov	x23, x2
	ldr	w19, [x1]
	add	x0, sp, #40
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	add	x0, sp, #1064
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #120
	add	x3, sp, #40
	mov	x1, x23
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-104]
	cbnz	w0, LBB143_13
	ldur	x20, [x29, #-120]
	sub	x0, x29, #96
	add	x3, sp, #1064
	mov	x1, x22
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB143_13
	ldur	x21, [x29, #-96]
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-64]
	cbnz	w0, LBB143_13
	ldur	x22, [x29, #-72]
LBB143_6:
	mov	x0, x20
	mov	x1, x19
	mov	x2, x21
	bl	_symlinkat
	cmn	w0, #1
	b.ne	LBB143_12
	bl	___error
	ldr	w23, [x0]
	tbnz	w23, #31, LBB143_30
	cmp	w23, #16, lsl #12
	b.hs	LBB143_30
	cmp	w23, #4
	b.ne	LBB143_11
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB143_6
	b	LBB143_13
LBB143_11:
	cbnz	w23, LBB143_15
LBB143_12:
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB143_13:
	ldur	x8, [x29, #-56]
Lloh1042:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1043:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1044:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB143_33
	add	sp, sp, #2160
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB143_15:
	.cfi_restore_state
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w23, #1
	cmp	w8, #91
	b.hi	LBB143_24
	mov	w0, #10
Lloh1045:
	adrp	x9, LJTI143_0@PAGE
Lloh1046:
	add	x9, x9, LJTI143_0@PAGEOFF
	adr	x10, LBB143_13
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB143_17:
	mov	w0, #18
	b	LBB143_13
LBB143_18:
	mov	w0, #43
	b	LBB143_13
LBB143_19:
	mov	w0, #4
	b	LBB143_13
LBB143_20:
	mov	w0, #44
	b	LBB143_13
LBB143_21:
	mov	w0, #36
	b	LBB143_13
LBB143_22:
	mov	w0, #14
	b	LBB143_13
LBB143_23:
	mov	w0, #50
	b	LBB143_13
LBB143_24:
	mov	w0, #12
	b	LBB143_13
LBB143_25:
	mov	w0, #39
	b	LBB143_13
LBB143_26:
	mov	w0, #40
	b	LBB143_13
LBB143_27:
	mov	w0, #16
	b	LBB143_13
LBB143_28:
	mov	w0, #37
	b	LBB143_13
LBB143_29:
	mov	w0, #41
	b	LBB143_13
LBB143_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB143_31:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB143_32:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB143_33:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1039, Lloh1040, Lloh1041
	.loh AdrpLdrGotLdr	Lloh1042, Lloh1043, Lloh1044
	.loh AdrpAdd	Lloh1045, Lloh1046
	.cfi_endproc
	.section	__TEXT,__const
LJTI143_0:
	.byte	(LBB143_17-LBB143_13)>>2
	.byte	(LBB143_25-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_23-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_19-LBB143_13)>>2
	.byte	(LBB143_13-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_21-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_26-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_27-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_29-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_28-LBB143_13)>>2
	.byte	(LBB143_18-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_22-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_24-LBB143_13)>>2
	.byte	(LBB143_20-LBB143_13)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirRenamePreserve:
	.cfi_startproc
	stp	x28, x27, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
	sub	sp, sp, #2144
Lloh1047:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1048:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1049:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB144_30
	tst	x0, #0x7
	b.ne	LBB144_31
	mov	x22, x6
	mov	x23, x5
	mov	x21, x3
	mov	x24, x2
	ldr	w19, [x1]
	ldr	w20, [x4]
	add	x0, sp, #24
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	add	x0, sp, #1048
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #136
	add	x3, sp, #24
	mov	x1, x24
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-120]
	cbnz	w0, LBB144_27
	ldur	x21, [x29, #-136]
	sub	x0, x29, #112
	add	x3, sp, #1048
	mov	x1, x23
	mov	x2, x22
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-96]
	cbnz	w0, LBB144_27
	ldur	x22, [x29, #-112]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB144_27
	ldur	x23, [x29, #-88]
Lloh1050:
	adrp	x24, LJTI144_0@PAGE
Lloh1051:
	add	x24, x24, LJTI144_0@PAGEOFF
LBB144_6:
	mov	x0, x19
	mov	x1, x21
	mov	x2, x20
	mov	x3, x22
	mov	w4, #4
	bl	_renameatx_np
	cmn	w0, #1
	b.ne	LBB144_13
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB144_29
	cmp	w8, #16, lsl #12
	b.hs	LBB144_29
	cmp	w8, #69
	b.hi	LBB144_12
	adr	x9, LBB144_11
	ldrb	w10, [x24, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB144_11:
	str	x23, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB144_6
	b	LBB144_27
LBB144_12:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB144_27
LBB144_13:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB144_27
LBB144_14:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB144_27
LBB144_15:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #54
	b	LBB144_27
LBB144_16:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #53
	b	LBB144_27
LBB144_17:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #49
	b	LBB144_27
LBB144_18:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #14
	b	LBB144_27
LBB144_19:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #40
	b	LBB144_27
LBB144_20:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #39
	b	LBB144_27
LBB144_21:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
	b	LBB144_27
LBB144_22:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #43
	b	LBB144_27
LBB144_23:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #41
	b	LBB144_27
LBB144_24:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #16
	b	LBB144_27
LBB144_25:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #36
	b	LBB144_27
LBB144_26:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #38
LBB144_27:
	ldur	x8, [x29, #-72]
Lloh1052:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1053:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1054:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB144_32
	add	sp, sp, #2144
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x28, x27, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB144_29:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB144_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB144_31:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB144_32:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1047, Lloh1048, Lloh1049
	.loh AdrpAdd	Lloh1050, Lloh1051
	.loh AdrpLdrGotLdr	Lloh1052, Lloh1053, Lloh1054
	.cfi_endproc
	.section	__TEXT,__const
LJTI144_0:
	.byte	(LBB144_13-LBB144_11)>>2
	.byte	(LBB144_21-LBB144_11)>>2
	.byte	(LBB144_20-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_11-LBB144_11)>>2
	.byte	(LBB144_15-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_14-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_14-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_25-LBB144_11)>>2
	.byte	(LBB144_16-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_19-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_24-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_23-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_17-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_26-LBB144_11)>>2
	.byte	(LBB144_22-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_12-LBB144_11)>>2
	.byte	(LBB144_18-LBB144_11)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirRenamePosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
	sub	sp, sp, #2144
Lloh1055:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1056:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1057:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB145_34
	tst	x0, #0x7
	b.ne	LBB145_35
	mov	x22, x6
	mov	x23, x5
	mov	x21, x3
	mov	x24, x2
	ldr	w19, [x1]
	ldr	w20, [x4]
	add	x0, sp, #24
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	add	x0, sp, #1048
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #136
	add	x3, sp, #24
	mov	x1, x24
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-120]
	cbnz	w0, LBB145_31
	ldur	x21, [x29, #-136]
	sub	x0, x29, #112
	add	x3, sp, #1048
	mov	x1, x23
	mov	x2, x22
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-96]
	cbnz	w0, LBB145_31
	ldur	x22, [x29, #-112]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB145_31
	ldur	x23, [x29, #-88]
Lloh1058:
	adrp	x24, LJTI145_0@PAGE
Lloh1059:
	add	x24, x24, LJTI145_0@PAGEOFF
LBB145_6:
	mov	x0, x19
	mov	x1, x21
	mov	x2, x20
	mov	x3, x22
	bl	_renameat
	cmn	w0, #1
	b.ne	LBB145_13
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB145_33
	cmp	w8, #16, lsl #12
	b.hs	LBB145_33
	cmp	w8, #92
	b.hi	LBB145_12
	adr	x9, LBB145_11
	ldrb	w10, [x24, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB145_11:
	str	x23, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB145_6
	b	LBB145_31
LBB145_12:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB145_31
LBB145_13:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB145_31
LBB145_14:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #52
	b	LBB145_31
LBB145_15:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #37
	b	LBB145_31
LBB145_16:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #38
	b	LBB145_31
LBB145_17:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #54
	b	LBB145_31
LBB145_18:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #43
	b	LBB145_31
LBB145_19:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #5
	b	LBB145_31
LBB145_20:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #44
	b	LBB145_31
LBB145_21:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #14
	b	LBB145_31
LBB145_22:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #53
	b	LBB145_31
LBB145_23:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #4
	b	LBB145_31
LBB145_24:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #40
	b	LBB145_31
LBB145_25:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB145_31
LBB145_26:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
	b	LBB145_31
LBB145_27:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #39
	b	LBB145_31
LBB145_28:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #41
	b	LBB145_31
LBB145_29:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #22
	b	LBB145_31
LBB145_30:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #16
LBB145_31:
	ldur	x8, [x29, #-72]
Lloh1060:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1061:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1062:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB145_36
	add	sp, sp, #2144
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x28, x27, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB145_33:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB145_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB145_35:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB145_36:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1055, Lloh1056, Lloh1057
	.loh AdrpAdd	Lloh1058, Lloh1059
	.loh AdrpLdrGotLdr	Lloh1060, Lloh1061, Lloh1062
	.cfi_endproc
	.section	__TEXT,__const
LJTI145_0:
	.byte	(LBB145_13-LBB145_11)>>2
	.byte	(LBB145_26-LBB145_11)>>2
	.byte	(LBB145_27-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_11-LBB145_11)>>2
	.byte	(LBB145_17-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_23-LBB145_11)>>2
	.byte	(LBB145_25-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_29-LBB145_11)>>2
	.byte	(LBB145_14-LBB145_11)>>2
	.byte	(LBB145_22-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_24-LBB145_11)>>2
	.byte	(LBB145_19-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_30-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_28-LBB145_11)>>2
	.byte	(LBB145_16-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_15-LBB145_11)>>2
	.byte	(LBB145_18-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_14-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_21-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_12-LBB145_11)>>2
	.byte	(LBB145_20-LBB145_11)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirDeleteDirPosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	.cfi_remember_state
	sub	sp, sp, #1104
Lloh1063:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1064:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1065:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-56]
	cbz	x0, LBB146_29
	tst	x0, #0x7
	b.ne	LBB146_30
	mov	x20, x3
	mov	x21, x2
	ldr	w19, [x1]
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #96
	add	x3, sp, #32
	mov	x1, x21
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB146_12
	ldur	x20, [x29, #-96]
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-64]
	cbnz	w0, LBB146_12
	ldur	x21, [x29, #-72]
LBB146_5:
	mov	x0, x19
	mov	x1, x20
	mov	w2, #128
	bl	_unlinkat
	cmn	w0, #1
	b.ne	LBB146_11
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB146_28
	cmp	w22, #16, lsl #12
	b.hs	LBB146_28
	cmp	w22, #4
	b.ne	LBB146_10
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB146_5
	b	LBB146_12
LBB146_10:
	cbnz	w22, LBB146_14
LBB146_11:
	str	x21, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB146_12:
	ldur	x8, [x29, #-56]
Lloh1066:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1067:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1068:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB146_31
	add	sp, sp, #1104
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x28, x27, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB146_14:
	.cfi_restore_state
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w22, #1
	cmp	w8, #91
	b.hi	LBB146_27
	mov	w0, #10
Lloh1069:
	adrp	x9, LJTI146_0@PAGE
Lloh1070:
	add	x9, x9, LJTI146_0@PAGEOFF
	adr	x10, LBB146_12
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB146_16:
	mov	w0, #18
	b	LBB146_12
LBB146_17:
	mov	w0, #52
	b	LBB146_12
LBB146_18:
	mov	w0, #39
	b	LBB146_12
LBB146_19:
	mov	w0, #22
	b	LBB146_12
LBB146_20:
	mov	w0, #44
	b	LBB146_12
LBB146_21:
	mov	w0, #40
	b	LBB146_12
LBB146_22:
	mov	w0, #41
	b	LBB146_12
LBB146_23:
	mov	w0, #50
	b	LBB146_12
LBB146_24:
	mov	w0, #4
	b	LBB146_12
LBB146_25:
	mov	w0, #43
	b	LBB146_12
LBB146_26:
	mov	w0, #37
	b	LBB146_12
LBB146_27:
	mov	w0, #12
	b	LBB146_12
LBB146_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB146_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB146_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB146_31:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1063, Lloh1064, Lloh1065
	.loh AdrpLdrGotLdr	Lloh1066, Lloh1067, Lloh1068
	.loh AdrpAdd	Lloh1069, Lloh1070
	.cfi_endproc
	.section	__TEXT,__const
LJTI146_0:
	.byte	(LBB146_16-LBB146_12)>>2
	.byte	(LBB146_18-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_23-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_24-LBB146_12)>>2
	.byte	(LBB146_12-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_19-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_21-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_22-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_26-LBB146_12)>>2
	.byte	(LBB146_25-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_17-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_27-LBB146_12)>>2
	.byte	(LBB146_20-LBB146_12)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirDeleteFilePosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w27, -56
	.cfi_offset w28, -64
	.cfi_remember_state
	sub	sp, sp, #1280
Lloh1071:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1072:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1073:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-56]
	cbz	x0, LBB147_38
	tst	x0, #0x7
	b.ne	LBB147_39
	mov	x20, x3
	mov	x21, x2
	ldr	w19, [x1]
	add	x0, sp, #56
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #248
	add	x3, sp, #56
	mov	x1, x21
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-232]
	cbnz	w0, LBB147_35
	ldur	x20, [x29, #-248]
	sub	x0, x29, #224
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-216]
	cbnz	w0, LBB147_35
	ldur	x21, [x29, #-224]
LBB147_5:
	mov	x0, x19
	mov	x1, x20
	mov	w2, #0
	bl	_unlinkat
	cmn	w0, #1
	b.ne	LBB147_12
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB147_37
	cmp	w22, #16, lsl #12
	b.hs	LBB147_37
	cmp	w22, #4
	b.ne	LBB147_10
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB147_5
	b	LBB147_35
LBB147_10:
	cmp	w22, #1
	b.eq	LBB147_13
	cbnz	w22, LBB147_21
LBB147_12:
	str	x21, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB147_35
LBB147_13:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x29, #-96]
	stp	q0, q0, [x29, #-128]
	stp	q0, q0, [x29, #-160]
	stp	q0, q0, [x29, #-192]
	stur	q0, [x29, #-208]
LBB147_14:
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.ne	LBB147_35
	sub	x2, x29, #208
	mov	x0, x19
	mov	x1, x20
	mov	w3, #32
	bl	_fstatat
	cmn	w0, #1
	b.ne	LBB147_20
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB147_37
	cmp	w8, #16, lsl #12
	b.hs	LBB147_37
	cmp	w8, #4
	b.eq	LBB147_14
	cbnz	w8, LBB147_24
LBB147_20:
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	ldurh	w8, [x29, #-204]
	and	w8, w8, #0xf000
	mov	w9, #18
	mov	w10, #5
	cmp	w8, #4, lsl #12
	csel	w0, w10, w9, eq
	b	LBB147_35
LBB147_21:
	str	x21, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w22, #2
	cmp	w8, #90
	b.hi	LBB147_34
	mov	w0, #10
Lloh1074:
	adrp	x9, LJTI147_0@PAGE
Lloh1075:
	add	x9, x9, LJTI147_0@PAGEOFF
	adr	x10, LBB147_23
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB147_23:
	mov	w0, #39
	b	LBB147_35
LBB147_24:
	str	x21, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
	b	LBB147_35
LBB147_25:
	mov	w0, #44
	b	LBB147_35
LBB147_26:
	mov	w0, #22
	b	LBB147_35
LBB147_27:
	mov	w0, #40
	b	LBB147_35
LBB147_28:
	mov	w0, #4
	b	LBB147_35
LBB147_29:
	mov	w0, #50
	b	LBB147_35
LBB147_30:
	mov	w0, #5
	b	LBB147_35
LBB147_31:
	mov	w0, #41
	b	LBB147_35
LBB147_32:
	mov	w0, #43
	b	LBB147_35
LBB147_33:
	mov	w0, #37
	b	LBB147_35
LBB147_34:
	mov	w0, #12
LBB147_35:
	ldur	x8, [x29, #-56]
Lloh1076:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1077:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1078:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB147_40
	add	sp, sp, #1280
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x28, x27, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB147_37:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB147_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB147_39:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB147_40:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1071, Lloh1072, Lloh1073
	.loh AdrpAdd	Lloh1074, Lloh1075
	.loh AdrpLdrGotLdr	Lloh1076, Lloh1077, Lloh1078
	.cfi_endproc
	.section	__TEXT,__const
LJTI147_0:
	.byte	(LBB147_23-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_29-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_28-LBB147_23)>>2
	.byte	(LBB147_35-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_26-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_27-LBB147_23)>>2
	.byte	(LBB147_30-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_31-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_33-LBB147_23)>>2
	.byte	(LBB147_32-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_34-LBB147_23)>>2
	.byte	(LBB147_25-LBB147_23)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirRealPathFilePosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #1216
	mov	x19, x8
Lloh1079:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1080:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1081:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-88]
	cbz	x0, LBB148_59
	tst	x0, #0x7
	b.ne	LBB148_60
	mov	x20, x5
	mov	x21, x4
	mov	x22, x3
	mov	x24, x2
	ldr	w23, [x1]
	add	x0, sp, #64
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #208
	add	x3, sp, #64
	mov	x1, x24
	mov	x2, x22
	bl	l_Io.Threaded.pathToPosix
	ldurh	w8, [x29, #-192]
	cbnz	w8, LBB148_39
	ldur	x22, [x29, #-208]
	cmn	w23, #2
	b.ne	LBB148_7
	cmp	x20, #1024
	b.hs	LBB148_16
LBB148_5:
Lloh1082:
	adrp	x8, l___anon_10273@PAGE
Lloh1083:
	add	x8, x8, l___anon_10273@PAGEOFF
LBB148_6:
	ldr	q0, [x8]
	b	LBB148_28
LBB148_7:
	sub	x0, x29, #120
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-112]
	cbnz	w8, LBB148_39
	ldur	x25, [x29, #-120]
LBB148_9:
	str	xzr, [sp]
	mov	x0, x23
	mov	x1, x22
	mov	w2, #4
	movk	w2, #256, lsl #16
	bl	_openat
	mov	x24, x0
	cmn	w0, #1
	b.ne	LBB148_23
	bl	___error
	ldr	w26, [x0]
	tbnz	w26, #31, LBB148_58
	cmp	w26, #16, lsl #12
	b.hs	LBB148_58
	cmp	w26, #4
	b.ne	LBB148_14
	str	x25, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB148_9
	b	LBB148_39
LBB148_14:
	cbnz	w26, LBB148_30
	mov	w22, #-1
	b	LBB148_24
LBB148_16:
	sub	x0, x29, #184
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-176]
	cbnz	w8, LBB148_39
	ldur	x23, [x29, #-184]
LBB148_18:
	mov	x0, x22
	mov	x1, x21
	bl	_realpath$DARWIN_EXTSN
	cbnz	x0, LBB148_33
	bl	___error
	ldr	w24, [x0]
	tbnz	w24, #31, LBB148_58
	cmp	w24, #16, lsl #12
	b.hs	LBB148_58
	cmp	w24, #4
	b.ne	LBB148_36
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB148_18
	b	LBB148_39
LBB148_23:
	mov	x22, x24
LBB148_24:
	str	x25, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	sub	x0, x29, #104
	mov	x1, x22
	mov	x2, x21
	mov	x3, x20
	bl	l_Io.Threaded.realPathPosix
	mov	x0, x24
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB148_27
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB148_58
	cmp	w8, #16, lsl #12
	b.hs	LBB148_58
LBB148_27:
	ldur	q0, [x29, #-104]
LBB148_28:
	str	q0, [x19]
	ldur	x8, [x29, #-88]
Lloh1084:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1085:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1086:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB148_40
LBB148_29:
	add	sp, sp, #1216
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB148_30:
	.cfi_restore_state
	str	x25, [sp, #56]
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w26, #1
	cmp	w8, #91
	b.hi	LBB148_38
Lloh1087:
	adrp	x9, LJTI148_0@PAGE
Lloh1088:
	add	x9, x9, LJTI148_0@PAGEOFF
	adr	x10, LBB148_5
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB148_32:
Lloh1089:
	adrp	x8, l___anon_10323@PAGE
Lloh1090:
	add	x8, x8, l___anon_10323@PAGEOFF
	b	LBB148_6
LBB148_33:
	str	x23, [sp, #16]
	mov	x22, x0
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	cmp	x22, x21
	b.ne	LBB148_61
	sub	x0, x29, #168
	mov	x1, x21
	mov	x2, x20
	mov	w3, #0
	bl	l_mem.findScalar__func_124
	ldurb	w8, [x29, #-160]
	tbz	w8, #0, LBB148_41
	ldur	x8, [x29, #-168]
	sturh	wzr, [x29, #-144]
	stur	x8, [x29, #-152]
	sub	x8, x29, #152
	b	LBB148_6
LBB148_36:
	str	x23, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w24, #2
	cmp	w8, #61
	b.hi	LBB148_38
Lloh1091:
	adrp	x9, LJTI148_1@PAGE
Lloh1092:
	add	x9, x9, LJTI148_1@PAGEOFF
	adr	x10, LBB148_5
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB148_38:
	mov	w8, #12
LBB148_39:
	strh	w8, [x19, #8]
	ldur	x8, [x29, #-88]
Lloh1093:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1094:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1095:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB148_29
LBB148_40:
	bl	___stack_chk_fail
LBB148_41:
	sturh	wzr, [x29, #-128]
	stur	x20, [x29, #-136]
	sub	x8, x29, #136
	b	LBB148_6
LBB148_42:
Lloh1096:
	adrp	x8, l___anon_10282@PAGE
Lloh1097:
	add	x8, x8, l___anon_10282@PAGEOFF
	b	LBB148_6
LBB148_43:
Lloh1098:
	adrp	x8, l___anon_10280@PAGE
Lloh1099:
	add	x8, x8, l___anon_10280@PAGEOFF
	b	LBB148_6
LBB148_44:
Lloh1100:
	adrp	x8, l___anon_10286@PAGE
Lloh1101:
	add	x8, x8, l___anon_10286@PAGEOFF
	b	LBB148_6
LBB148_45:
Lloh1102:
	adrp	x8, l___anon_10288@PAGE
Lloh1103:
	add	x8, x8, l___anon_10288@PAGEOFF
	b	LBB148_6
LBB148_46:
Lloh1104:
	adrp	x8, l___anon_10313@PAGE
Lloh1105:
	add	x8, x8, l___anon_10313@PAGEOFF
	b	LBB148_6
LBB148_47:
Lloh1106:
	adrp	x8, l___anon_10315@PAGE
Lloh1107:
	add	x8, x8, l___anon_10315@PAGEOFF
	b	LBB148_6
LBB148_48:
Lloh1108:
	adrp	x8, l___anon_10290@PAGE
Lloh1109:
	add	x8, x8, l___anon_10290@PAGEOFF
	b	LBB148_6
LBB148_49:
Lloh1110:
	adrp	x8, l___anon_10284@PAGE
Lloh1111:
	add	x8, x8, l___anon_10284@PAGEOFF
	b	LBB148_6
LBB148_50:
Lloh1112:
	adrp	x8, l___anon_10319@PAGE
Lloh1113:
	add	x8, x8, l___anon_10319@PAGEOFF
	b	LBB148_6
LBB148_51:
Lloh1114:
	adrp	x8, l___anon_10333@PAGE
Lloh1115:
	add	x8, x8, l___anon_10333@PAGEOFF
	b	LBB148_6
LBB148_52:
Lloh1116:
	adrp	x8, l___anon_10327@PAGE
Lloh1117:
	add	x8, x8, l___anon_10327@PAGEOFF
	b	LBB148_6
LBB148_53:
Lloh1118:
	adrp	x8, l___anon_10331@PAGE
Lloh1119:
	add	x8, x8, l___anon_10331@PAGEOFF
	b	LBB148_6
LBB148_54:
Lloh1120:
	adrp	x8, l___anon_10317@PAGE
Lloh1121:
	add	x8, x8, l___anon_10317@PAGEOFF
	b	LBB148_6
LBB148_55:
Lloh1122:
	adrp	x8, l___anon_10325@PAGE
Lloh1123:
	add	x8, x8, l___anon_10325@PAGEOFF
	b	LBB148_6
LBB148_56:
Lloh1124:
	adrp	x8, l___anon_10329@PAGE
Lloh1125:
	add	x8, x8, l___anon_10329@PAGEOFF
	b	LBB148_6
LBB148_57:
Lloh1126:
	adrp	x8, l___anon_10321@PAGE
Lloh1127:
	add	x8, x8, l___anon_10321@PAGEOFF
	b	LBB148_6
LBB148_58:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB148_59:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB148_60:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB148_61:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh1079, Lloh1080, Lloh1081
	.loh AdrpAdd	Lloh1082, Lloh1083
	.loh AdrpLdrGotLdr	Lloh1084, Lloh1085, Lloh1086
	.loh AdrpAdd	Lloh1087, Lloh1088
	.loh AdrpAdd	Lloh1089, Lloh1090
	.loh AdrpAdd	Lloh1091, Lloh1092
	.loh AdrpLdrGotLdr	Lloh1093, Lloh1094, Lloh1095
	.loh AdrpAdd	Lloh1096, Lloh1097
	.loh AdrpAdd	Lloh1098, Lloh1099
	.loh AdrpAdd	Lloh1100, Lloh1101
	.loh AdrpAdd	Lloh1102, Lloh1103
	.loh AdrpAdd	Lloh1104, Lloh1105
	.loh AdrpAdd	Lloh1106, Lloh1107
	.loh AdrpAdd	Lloh1108, Lloh1109
	.loh AdrpAdd	Lloh1110, Lloh1111
	.loh AdrpAdd	Lloh1112, Lloh1113
	.loh AdrpAdd	Lloh1114, Lloh1115
	.loh AdrpAdd	Lloh1116, Lloh1117
	.loh AdrpAdd	Lloh1118, Lloh1119
	.loh AdrpAdd	Lloh1120, Lloh1121
	.loh AdrpAdd	Lloh1122, Lloh1123
	.loh AdrpAdd	Lloh1124, Lloh1125
	.loh AdrpAdd	Lloh1126, Lloh1127
	.cfi_endproc
	.section	__TEXT,__const
LJTI148_0:
	.byte	(LBB148_56-LBB148_5)>>2
	.byte	(LBB148_42-LBB148_5)>>2
	.byte	(LBB148_42-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_32-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_55-LBB148_5)>>2
	.byte	(LBB148_43-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_51-LBB148_5)>>2
	.byte	(LBB148_53-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_32-LBB148_5)>>2
	.byte	(LBB148_44-LBB148_5)>>2
	.byte	(LBB148_54-LBB148_5)>>2
	.byte	(LBB148_46-LBB148_5)>>2
	.byte	(LBB148_57-LBB148_5)>>2
	.byte	(LBB148_50-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_47-LBB148_5)>>2
	.byte	(LBB148_52-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_45-LBB148_5)>>2
	.byte	(LBB148_5-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_47-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_46-LBB148_5)>>2
LJTI148_1:
	.byte	(LBB148_42-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_48-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_43-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_44-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_49-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_38-LBB148_5)>>2
	.byte	(LBB148_45-LBB148_5)>>2
	.byte	(LBB148_5-LBB148_5)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirRealPathPosix:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh1128:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1129:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1130:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	cbz	x0, LBB149_4
	tst	x0, #0x7
	b.ne	LBB149_5
	ldr	w1, [x1]
	add	x0, sp, #8
	bl	l_Io.Threaded.realPathPosix
	ldur	q0, [sp, #8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh1131:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1132:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1133:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB149_6
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB149_4:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB149_5:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB149_6:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1128, Lloh1129, Lloh1130
	.loh AdrpLdrGotLdr	Lloh1131, Lloh1132, Lloh1133
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirReadDarwin:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	str	x2, [sp]
	mov	x19, x8
Lloh1134:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1135:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1136:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #56]
	cbz	x0, LBB150_51
	tst	x0, #0x7
	b.ne	LBB150_52
	mov	x20, x3
	mov	x21, x1
	ldr	x23, [x1]
	ldr	x8, [x1, #16]
	cmp	x8, #8
	b.hs	LBB150_4
	mov	w8, #8
	dup.2d	v0, x8
	str	q0, [x21, #16]
	str	xzr, [x23]
LBB150_4:
	mov	x24, #0
Lloh1137:
	adrp	x25, l___anon_10369@PAGE
Lloh1138:
	add	x25, x25, l___anon_10369@PAGEOFF
	b	LBB150_7
LBB150_5:
	ldrb	w8, [x26, #20]
	lsl	x9, x8, #2
	mov	x10, #41274
	movk	x10, #41122, lsl #16
	movk	x10, #42149, lsl #32
	movk	x10, #1958, lsl #48
	lsr	x9, x10, x9
	ldr	x10, [sp]
	add	x10, x10, x24, lsl #5
	stp	x22, x27, [x10]
	and	w9, w9, #0xf
	cmp	x8, #15
	mov	w8, #10
	csel	w8, w9, w8, lo
	strb	w8, [x10, #24]
	ldr	x8, [x26]
	str	x8, [x10, #16]
	add	x24, x24, #1
LBB150_6:
	cmp	x20, x24
	b.lo	LBB150_48
LBB150_7:
	cmp	x20, x24
	b.eq	LBB150_39
	ldp	x0, x8, [x21, #16]
	cmp	x8, x0
	b.lo	LBB150_48
	b.ne	LBB150_25
	cbnz	x24, LBB150_38
	ldrb	w8, [x21, #36]
	tst	w8, #0x3
	b.ne	LBB150_14
	ldr	w0, [x21, #32]
	mov	x1, #0
	bl	l_Io.Threaded.posixSeekTo
	ands	w8, w0, #0xffff
	b.ne	LBB150_42
	mov	w8, #1
	strb	w8, [x21, #36]
LBB150_14:
	ldr	x27, [x21, #8]
	cmp	x27, #7
	b.ls	LBB150_50
	ldr	x26, [x21]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB150_34
	sub	x27, x27, #8
	ldr	x28, [sp, #40]
LBB150_17:
	ldr	w0, [x21, #32]
	add	x1, x26, #8
	mov	x2, x27
	mov	x3, x23
	bl	___getdirentries64
	cmn	x0, #1
	b.ne	LBB150_22
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB150_47
	cmp	w8, #16, lsl #12
	b.hs	LBB150_47
	cmp	w8, #4
	b.ne	LBB150_32
	str	x28, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB150_17
	b	LBB150_34
LBB150_22:
	str	x28, [sp, #16]
	mov	x22, x0
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x22, #63, LBB150_47
	mov	x8, x22
	cbz	x22, LBB150_40
	add	x8, x8, #8
	mov	w9, #8
	stp	x9, x8, [x21, #16]
	mov	w0, #8
LBB150_25:
	ldr	x1, [x21, #8]
	cmp	x0, x1
	b.hs	LBB150_49
	ldr	x8, [x21]
	add	x26, x8, x0
	ldrh	w8, [x26, #16]
	adds	x8, x0, x8
	b.hs	LBB150_48
	str	x8, [x21, #16]
	add	x22, x26, #21
	ldrh	w27, [x26, #18]
	cmp	w27, #0
	csinc	x28, x22, xzr, ne
	mov	x0, x28
	mov	x1, x27
	mov	x2, x25
	mov	w3, #1
	bl	l_mem.eqlBytes
	tbnz	w0, #0, LBB150_6
	mov	x0, x28
	mov	x1, x27
Lloh1139:
	adrp	x2, l___anon_10373@PAGE
Lloh1140:
	add	x2, x2, l___anon_10373@PAGEOFF
	mov	w3, #2
	bl	l_mem.eqlBytes
	tbnz	w0, #0, LBB150_6
	ldr	x8, [x26]
	cbz	x8, LBB150_6
	cmp	x24, x20
	b.lo	LBB150_5
	mov	x0, x24
	mov	x1, x20
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB150_32:
	cbz	w8, LBB150_46
	str	x28, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
LBB150_34:
	strh	w8, [x19, #8]
LBB150_35:
	ldr	x8, [sp, #56]
Lloh1141:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1142:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1143:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB150_53
	.cfi_def_cfa wsp, 160
LBB150_37:
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB150_38:
	.cfi_restore_state
	.cfi_remember_state
	mov	x20, x24
LBB150_39:
	str	x20, [x19]
	strh	wzr, [x19, #8]
	b	LBB150_35
LBB150_40:
	mov	w8, #2
	strb	w8, [x21, #36]
	stp	xzr, xzr, [x19]
	ldr	x8, [sp, #56]
Lloh1144:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1145:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1146:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB150_53
	.cfi_def_cfa wsp, 160
	b	LBB150_37
LBB150_42:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w8, #57
	b.ne	LBB150_45
Lloh1147:
	adrp	x8, l___anon_10351@PAGE
Lloh1148:
	add	x8, x8, l___anon_10351@PAGEOFF
Lloh1149:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #56]
Lloh1150:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1151:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1152:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB150_53
	.cfi_def_cfa wsp, 160
	b	LBB150_37
LBB150_45:
	.cfi_restore_state
	strh	w0, [x19, #8]
	b	LBB150_35
LBB150_46:
	str	x28, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
LBB150_47:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB150_48:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB150_49:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB150_50:
	mov	w0, #8
	mov	x1, x27
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB150_51:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB150_52:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB150_53:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1134, Lloh1135, Lloh1136
	.loh AdrpAdd	Lloh1137, Lloh1138
	.loh AdrpAdd	Lloh1139, Lloh1140
	.loh AdrpLdrGotLdr	Lloh1141, Lloh1142, Lloh1143
	.loh AdrpLdrGotLdr	Lloh1144, Lloh1145, Lloh1146
	.loh AdrpLdrGotLdr	Lloh1150, Lloh1151, Lloh1152
	.loh AdrpAddLdr	Lloh1147, Lloh1148, Lloh1149
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirClose:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x0, LBB151_10
	tst	x0, #0x7
	b.ne	LBB151_11
	mov	x19, x2
	cbz	x2, LBB151_9
	mov	x20, x1
	b	LBB151_5
LBB151_4:
	subs	x19, x19, #1
	b.eq	LBB151_9
LBB151_5:
	ldr	w0, [x20], #4
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB151_4
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB151_8
	cmp	w8, #16, lsl #12
	b.lo	LBB151_4
LBB151_8:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB151_9:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB151_10:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB151_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirOpenDirPosix:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	sub	sp, sp, #1120
	mov	x19, x8
Lloh1153:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1154:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1155:
	ldr	x8, [x8]
	str	x8, [sp, #16]
	stur	x8, [x29, #-72]
	cbz	x0, LBB152_28
	tst	x0, #0x7
	b.ne	LBB152_29
	mov	x21, x3
	mov	x22, x2
	ldr	w20, [x1]
	ldrb	w23, [x4, #2]
	add	x0, sp, #48
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #112
	add	x3, sp, #48
	mov	x1, x22
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w8, [x29, #-96]
	cbnz	w8, LBB152_24
	ldur	x21, [x29, #-112]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-80]
	cbnz	w8, LBB152_24
	mvn	w8, w23
	mov	w22, #17825792
	bfi	w22, w8, #8, #1
	ldur	x24, [x29, #-88]
Lloh1156:
	adrp	x25, LJTI152_0@PAGE
Lloh1157:
	add	x25, x25, LJTI152_0@PAGEOFF
LBB152_5:
	str	xzr, [sp]
	mov	x0, x20
	mov	x1, x21
	mov	x2, x22
	bl	_openat
	mov	x23, x0
	cmn	w0, #1
	b.ne	LBB152_12
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB152_27
	cmp	w8, #16, lsl #12
	b.hs	LBB152_27
	cmp	w8, #92
	b.hi	LBB152_11
	adr	x9, LBB152_10
	ldrb	w10, [x25, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB152_10:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB152_5
	b	LBB152_24
LBB152_11:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	b	LBB152_24
LBB152_12:
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	strh	wzr, [x19, #4]
	str	w23, [x19]
	b	LBB152_25
LBB152_13:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #44
	b	LBB152_24
LBB152_14:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #21
	b	LBB152_24
LBB152_15:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #40
	b	LBB152_24
LBB152_16:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #23
	b	LBB152_24
LBB152_17:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #4
	b	LBB152_24
LBB152_18:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #24
	b	LBB152_24
LBB152_19:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #43
	b	LBB152_24
LBB152_20:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #39
	b	LBB152_24
LBB152_21:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #18
	b	LBB152_24
LBB152_22:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #10
	b	LBB152_24
LBB152_23:
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #37
LBB152_24:
	strh	w8, [x19, #4]
LBB152_25:
	ldur	x8, [x29, #-72]
Lloh1158:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1159:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1160:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB152_30
	add	sp, sp, #1120
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB152_27:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB152_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB152_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB152_30:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1153, Lloh1154, Lloh1155
	.loh AdrpAdd	Lloh1156, Lloh1157
	.loh AdrpLdrGotLdr	Lloh1158, Lloh1159, Lloh1160
	.cfi_endproc
	.section	__TEXT,__const
LJTI152_0:
	.byte	(LBB152_12-LBB152_10)>>2
	.byte	(LBB152_21-LBB152_10)>>2
	.byte	(LBB152_20-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_10-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_14-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_17-LBB152_10)>>2
	.byte	(LBB152_22-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_14-LBB152_10)>>2
	.byte	(LBB152_15-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_13-LBB152_10)>>2
	.byte	(LBB152_18-LBB152_10)>>2
	.byte	(LBB152_16-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_23-LBB152_10)>>2
	.byte	(LBB152_19-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_11-LBB152_10)>>2
	.byte	(LBB152_13-LBB152_10)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirOpenFilePosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #1344
Lloh1161:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1162:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1163:
	ldr	x9, [x9]
	str	x9, [sp, #32]
	stur	x9, [x29, #-96]
	cbz	x0, LBB153_78
	mov	x21, x0
	str	x8, [sp, #24]
	tst	x0, #0x7
	b.ne	LBB153_79
	mov	x20, x3
	mov	x23, x2
	ldr	w22, [x1]
	ldrb	w24, [x4]
	ldrb	w8, [x4, #1]
	str	w8, [sp, #20]
	ldrb	w27, [x4, #3]
	ldrb	w25, [x4, #4]
	ldrb	w19, [x4, #5]
	ldrb	w26, [x4, #6]
	ldrb	w28, [x4, #7]
	add	x0, sp, #120
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	add	x0, sp, #1144
	add	x3, sp, #120
	mov	x1, x23
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldrh	w8, [sp, #1160]
	cbnz	w8, LBB153_71
	mov	w8, #3
	bics	wzr, w8, w24
	b.eq	LBB153_77
	ldr	x23, [sp, #1144]
	mvn	w8, w26
	mvn	w9, w19
	bfi	w24, w9, #17, #1
	bfi	w24, w8, #8, #1
	bfi	w24, w28, #12, #1
	orr	w8, w24, #0x1000000
	and	w9, w27, #0x3
	cmp	w9, #1
	b.gt	LBB153_6
	ubfiz	w10, w25, #2, #1
	orr	w10, w10, w8
	orr	w10, w10, #0x10
	cmp	w9, #0
	csel	w24, w8, w10, eq
	sub	x0, x29, #256
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-248]
	cbz	w8, LBB153_8
	b	LBB153_71
LBB153_6:
	cmp	w9, #2
	b.ne	LBB153_77
	ubfiz	w9, w25, #2, #1
	orr	w8, w9, w8
	orr	w24, w8, #0x20
	sub	x0, x29, #256
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-248]
	cbnz	w8, LBB153_71
LBB153_8:
	ldur	x27, [x29, #-256]
LBB153_9:
	str	xzr, [sp]
	mov	x0, x22
	mov	x1, x23
	mov	x2, x24
	bl	_openat
	mov	x20, x0
	cmn	w0, #1
	b.ne	LBB153_15
	bl	___error
	ldr	w19, [x0]
	tbnz	w19, #31, LBB153_75
	cmp	w19, #16, lsl #12
	b.hs	LBB153_75
	cmp	w19, #4
	b.ne	LBB153_14
	str	x27, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB153_9
	b	LBB153_71
LBB153_14:
	cbnz	w19, LBB153_23
LBB153_15:
	str	x27, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	ldr	w8, [sp, #20]
	tbnz	w8, #0, LBB153_45
	str	w20, [sp, #112]
	strb	wzr, [sp, #116]
	sub	x8, x29, #240
	add	x1, sp, #112
	mov	x0, x21
	bl	l_Io.Threaded.fileStatPosix
	ldurh	w19, [x29, #-144]
	cbnz	w19, LBB153_44
	ldurb	w8, [x29, #-152]
	and	w8, w8, #0xf
	cmp	w8, #2
	b.ne	LBB153_45
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB153_21
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB153_75
	cmp	w8, #16, lsl #12
	b.hs	LBB153_75
LBB153_21:
	mov	w8, #5
LBB153_22:
	ldr	x9, [sp, #24]
	str	w8, [x9, #8]
	str	xzr, [x9]
	ldur	x8, [x29, #-96]
Lloh1164:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1165:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1166:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB153_72
	b	LBB153_74
LBB153_23:
	str	x27, [sp, #56]
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w19, #1
	cmp	w8, #91
	b.hi	LBB153_70
Lloh1167:
	adrp	x9, LJTI153_0@PAGE
Lloh1168:
	add	x9, x9, LJTI153_0@PAGEOFF
	adr	x10, LBB153_21
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB153_25:
	mov	w8, #39
	b	LBB153_22
LBB153_26:
	mov	w8, #15
	b	LBB153_22
LBB153_27:
	mov	w8, #21
	b	LBB153_22
LBB153_28:
	mov	w8, #44
	b	LBB153_22
LBB153_29:
	mov	w8, #16
	b	LBB153_22
LBB153_30:
	mov	w8, #47
	b	LBB153_22
LBB153_31:
	mov	w8, #43
	b	LBB153_22
LBB153_32:
	mov	w8, #40
	b	LBB153_22
LBB153_33:
	mov	w8, #37
	b	LBB153_22
LBB153_34:
	mov	w8, #18
	b	LBB153_22
LBB153_35:
	mov	w8, #41
	b	LBB153_22
LBB153_36:
	mov	w8, #4
	b	LBB153_22
LBB153_37:
	mov	w8, #10
	b	LBB153_22
LBB153_38:
	mov	w8, #24
	b	LBB153_22
LBB153_39:
	mov	w8, #36
	b	LBB153_22
LBB153_40:
	mov	w8, #17
	b	LBB153_22
LBB153_41:
	mov	w8, #22
	b	LBB153_22
LBB153_42:
	mov	w8, #23
	b	LBB153_22
LBB153_43:
	mov	w8, #9
	b	LBB153_22
LBB153_44:
	cmp	w19, #48
	b.ne	LBB153_61
LBB153_45:
	tbz	w25, #0, LBB153_66
	sub	x0, x29, #128
	bl	l_Io.Threaded.Syscall.start
	ldurh	w19, [x29, #-120]
	cbnz	w19, LBB153_61
	ldur	x21, [x29, #-128]
LBB153_48:
	str	xzr, [sp]
	mov	x0, x20
	mov	w1, #3
	bl	_fcntl
	cmn	w0, #1
	b.ne	LBB153_53
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB153_75
	cmp	w8, #16, lsl #12
	b.hs	LBB153_75
	cmp	w8, #4
	b.ne	LBB153_62
	str	x21, [sp, #72]
	add	x0, sp, #72
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w19, w0, #0xffff
	b.eq	LBB153_48
	b	LBB153_61
LBB153_53:
	str	x21, [sp, #64]
	mov	x21, x0
	add	x0, sp, #64
	bl	l_Io.Threaded.Syscall.finish
	tbnz	w21, #31, LBB153_75
	mov	x19, x21
	sub	x0, x29, #112
	bl	l_Io.Threaded.Syscall.start
	ldurh	w21, [x29, #-104]
	cbnz	w21, LBB153_73
	and	w8, w19, #0x7fffffff
	and	w22, w8, #0xfffffffb
	ldur	x21, [x29, #-112]
LBB153_56:
	str	x22, [sp]
	mov	x0, x20
	mov	w1, #4
	bl	_fcntl
	cmn	w0, #1
	b.ne	LBB153_65
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB153_75
	cmp	w8, #16, lsl #12
	b.hs	LBB153_75
	cmp	w8, #4
	b.ne	LBB153_64
	str	x21, [sp, #96]
	add	x0, sp, #96
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w19, w0, #0xffff
	b.eq	LBB153_56
LBB153_61:
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	ldr	x8, [sp, #24]
	strh	w19, [x8, #8]
	ldur	x8, [x29, #-96]
Lloh1169:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1170:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1171:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB153_72
	b	LBB153_74
LBB153_62:
	cbz	w8, LBB153_76
	str	x21, [sp, #80]
	add	x0, sp, #80
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB153_70
	b	LBB153_68
LBB153_64:
	cbnz	w8, LBB153_67
LBB153_65:
	str	x21, [sp, #88]
	add	x0, sp, #88
	bl	l_Io.Threaded.Syscall.finish
LBB153_66:
	ldr	x8, [sp, #24]
	strh	wzr, [x8, #8]
	str	w20, [x8]
	strb	wzr, [x8, #4]
	ldur	x8, [x29, #-96]
Lloh1172:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1173:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1174:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB153_72
	b	LBB153_74
LBB153_67:
	str	x21, [sp, #104]
	add	x0, sp, #104
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB153_70
LBB153_68:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB153_75
	cmp	w8, #16, lsl #12
	b.hs	LBB153_75
LBB153_70:
	mov	w8, #12
LBB153_71:
	ldr	x9, [sp, #24]
	strh	w8, [x9, #8]
	ldur	x8, [x29, #-96]
Lloh1175:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1176:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1177:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB153_74
LBB153_72:
	add	sp, sp, #1344
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB153_73:
	.cfi_restore_state
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	ldr	x8, [sp, #24]
	strh	w21, [x8, #8]
	ldur	x8, [x29, #-96]
Lloh1178:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1179:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1180:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB153_72
LBB153_74:
	bl	___stack_chk_fail
LBB153_75:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB153_76:
	str	x21, [sp, #64]
	add	x0, sp, #64
	bl	l_Io.Threaded.Syscall.finish
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB153_77:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB153_78:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB153_79:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdrGotLdr	Lloh1161, Lloh1162, Lloh1163
	.loh AdrpLdrGotLdr	Lloh1164, Lloh1165, Lloh1166
	.loh AdrpAdd	Lloh1167, Lloh1168
	.loh AdrpLdrGotLdr	Lloh1169, Lloh1170, Lloh1171
	.loh AdrpLdrGotLdr	Lloh1172, Lloh1173, Lloh1174
	.loh AdrpLdrGotLdr	Lloh1175, Lloh1176, Lloh1177
	.loh AdrpLdrGotLdr	Lloh1178, Lloh1179, Lloh1180
	.cfi_endproc
	.section	__TEXT,__const
LJTI153_0:
	.byte	(LBB153_34-LBB153_21)>>2
	.byte	(LBB153_25-LBB153_21)>>2
	.byte	(LBB153_25-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_27-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_36-LBB153_21)>>2
	.byte	(LBB153_37-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_40-LBB153_21)>>2
	.byte	(LBB153_39-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_27-LBB153_21)>>2
	.byte	(LBB153_32-LBB153_21)>>2
	.byte	(LBB153_21-LBB153_21)>>2
	.byte	(LBB153_28-LBB153_21)>>2
	.byte	(LBB153_38-LBB153_21)>>2
	.byte	(LBB153_42-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_41-LBB153_21)>>2
	.byte	(LBB153_26-LBB153_21)>>2
	.byte	(LBB153_29-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_35-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_43-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_30-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_33-LBB153_21)>>2
	.byte	(LBB153_31-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_26-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_70-LBB153_21)>>2
	.byte	(LBB153_28-LBB153_21)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirCreateFileAtomic:
	.cfi_startproc
	sub	sp, sp, #368
	.cfi_def_cfa_offset 368
	stp	x28, x27, [sp, #272]
	stp	x26, x25, [sp, #288]
	stp	x24, x23, [sp, #304]
	stp	x22, x21, [sp, #320]
	stp	x20, x19, [sp, #336]
	stp	x29, x30, [sp, #352]
	add	x29, sp, #352
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
Lloh1181:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1182:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1183:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-96]
	cbz	x0, LBB154_49
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB154_50
	mov	x22, x3
	mov	x23, x2
	mov	x24, x1
	ldr	w27, [x1]
	ldrh	w21, [x4]
	ldrb	w28, [x4, #2]
	cbz	x3, LBB154_5
	ldrb	w8, [x23]
	cmp	w8, #47
	cset	w8, eq
	cmp	x22, x8
	b.ne	LBB154_6
	mov	w8, #1
	mov	w9, #1
	b	LBB154_11
LBB154_5:
	mov	x8, #0
	mov	x9, #0
	b	LBB154_11
LBB154_6:
	mov	x10, #0
	mov	x9, x8
LBB154_7:
	ldrb	w11, [x23, x9]
	cmp	w11, #47
	b.ne	LBB154_11
	eor	x11, x10, x8
	cmn	x11, #1
	b.eq	LBB154_48
	add	x10, x10, #1
	add	x9, x9, #1
	cmp	x22, x9
	b.ne	LBB154_7
	mov	x9, x22
LBB154_11:
	stp	x23, x22, [sp, #32]
	stp	x8, x9, [sp, #48]
	stp	x9, x9, [sp, #64]
	sub	x0, x29, #136
	add	x1, sp, #32
	bl	"l_fs.path.ComponentIterator(.posix,u8).last"
	ldurb	w8, [x29, #-104]
	tbz	w8, #0, LBB154_18
	add	x0, sp, #176
	add	x1, sp, #32
	bl	"l_fs.path.ComponentIterator(.posix,u8).previous"
	ldrb	w8, [sp, #208]
	tbz	w8, #0, LBB154_15
	ldp	x26, x25, [sp, #192]
	cbnz	x26, LBB154_19
LBB154_14:
Lloh1184:
	adrp	x2, l___anon_3542@PAGE
Lloh1185:
	add	x2, x2, l___anon_3542@PAGEOFF
	add	x0, sp, #128
	mov	x1, x20
	mov	x3, x23
	mov	x4, x22
	mov	x5, x21
	mov	x6, x24
	mov	w7, #0
	bl	l_Io.Threaded.atomicFileInit
	ldp	q0, q1, [sp, #128]
	stp	q0, q1, [x19]
	ldr	q0, [sp, #160]
	b	LBB154_34
LBB154_15:
	ldr	x8, [sp, #56]
	cbz	x8, LBB154_18
	ldp	x1, x25, [sp, #40]
	cmp	x25, x1
	b.hi	LBB154_52
	ldr	x26, [sp, #32]
	cbnz	x26, LBB154_19
	b	LBB154_14
LBB154_18:
	mov	x26, #0
	mov	x25, #0
	cbz	x26, LBB154_14
LBB154_19:
	tbz	w28, #0, LBB154_25
	str	w27, [sp, #12]
Lloh1186:
	adrp	x4, l___anon_10487@PAGE+2
Lloh1187:
	add	x4, x4, l___anon_10487@PAGEOFF+2
	add	x8, sp, #176
	add	x1, sp, #12
	mov	x0, x20
	mov	x2, x26
	mov	x3, x25
	bl	l_Io.Threaded.dirOpenDirPosix
	ldrh	w9, [sp, #180]
	cbnz	w9, LBB154_38
	ldr	w8, [sp, #176]
LBB154_22:
	add	x24, sp, #16
	str	w8, [x24]
	cbz	x22, LBB154_27
LBB154_23:
	ldrb	w8, [x23]
	cmp	w8, #47
	cset	w8, eq
	cmp	x22, x8
	b.ne	LBB154_28
	mov	w8, #1
	mov	w9, #1
	b	LBB154_33
LBB154_25:
	str	w27, [sp, #20]
Lloh1188:
	adrp	x4, l___anon_10485@PAGE
Lloh1189:
	add	x4, x4, l___anon_10485@PAGEOFF
	add	x8, sp, #32
	add	x1, sp, #20
	mov	x0, x20
	mov	x2, x26
	mov	x3, x25
	bl	l_Io.Threaded.dirOpenDirPosix
	ldr	x8, [sp, #32]
	ubfx	x9, x8, #32, #16
	cbnz	w9, LBB154_41
	add	x24, sp, #24
	str	w8, [x24]
	cbnz	x22, LBB154_23
LBB154_27:
	mov	x8, #0
	mov	x9, #0
	b	LBB154_33
LBB154_28:
	mov	x10, #0
	mov	x9, x8
LBB154_29:
	ldrb	w11, [x23, x9]
	cmp	w11, #47
	b.ne	LBB154_33
	eor	x11, x10, x8
	cmn	x11, #1
	b.eq	LBB154_48
	add	x10, x10, #1
	add	x9, x9, #1
	cmp	x22, x9
	b.ne	LBB154_29
	mov	x9, x22
LBB154_33:
	stp	x23, x22, [sp, #32]
	stp	x8, x9, [sp, #48]
	stp	x9, x9, [sp, #64]
	add	x0, sp, #176
	add	x1, sp, #32
	bl	"l_fs.path.ComponentIterator(.posix,u8).last"
	ldrb	w8, [sp, #208]
	ldp	x9, x10, [sp, #176]
	tst	w8, #0x1
	csinc	x3, x9, xzr, ne
	csel	x4, x10, xzr, ne
Lloh1190:
	adrp	x2, l___anon_3542@PAGE
Lloh1191:
	add	x2, x2, l___anon_3542@PAGEOFF
	add	x0, sp, #80
	mov	x1, x20
	mov	x5, x21
	mov	x6, x24
	mov	w7, #1
	bl	l_Io.Threaded.atomicFileInit
	ldp	q0, q1, [sp, #80]
	stp	q0, q1, [x19]
	ldr	q0, [sp, #112]
LBB154_34:
	str	q0, [x19, #32]
LBB154_35:
	ldur	x8, [x29, #-96]
Lloh1192:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1193:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1194:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB154_51
	.cfi_def_cfa wsp, 368
LBB154_37:
	ldp	x29, x30, [sp, #352]
	ldp	x20, x19, [sp, #336]
	ldp	x22, x21, [sp, #320]
	ldp	x24, x23, [sp, #304]
	ldp	x26, x25, [sp, #288]
	ldp	x28, x27, [sp, #272]
	add	sp, sp, #368
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB154_38:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w9, #39
	b.ne	LBB154_42
	str	w27, [sp, #28]
	sub	x8, x29, #136
	add	x1, sp, #28
	mov	x0, x20
	mov	x2, x26
	mov	x3, x25
	mov	w4, #511
	bl	l_Io.Threaded.dirCreateDirPath
	ldurh	w9, [x29, #-136]
	cbnz	w9, LBB154_42
Lloh1195:
	adrp	x4, l___anon_10487@PAGE+2
Lloh1196:
	add	x4, x4, l___anon_10487@PAGEOFF+2
	add	x8, sp, #32
	add	x1, sp, #12
	mov	x0, x20
	mov	x2, x26
	mov	x3, x25
	bl	l_Io.Threaded.dirOpenDirPosix
	ldr	x8, [sp, #32]
	lsr	x9, x8, #32
	and	w10, w9, #0xffff
	cmp	w10, #48
	b.ls	LBB154_43
	b	LBB154_47
LBB154_41:
	lsr	x8, x8, #32
	strh	w8, [x19, #40]
	b	LBB154_35
LBB154_42:
	mov	x8, #0
	and	w10, w9, #0xffff
	cmp	w10, #48
	b.hi	LBB154_47
LBB154_43:
	and	x10, x9, #0xffff
	mov	w11, #1
	lsl	x11, x11, x10
	mov	x12, #49184
	movk	x12, #2, lsl #16
	movk	x12, #41040, lsl #32
	movk	x12, #1, lsl #48
	tst	x11, x12
	b.eq	LBB154_46
Lloh1197:
	adrp	x8, l___anon_10498@PAGE
Lloh1198:
	add	x8, x8, l___anon_10498@PAGEOFF
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldr	q0, [x8, #32]
	str	q0, [x19, #32]
	ldur	x8, [x29, #-96]
Lloh1199:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1200:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1201:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB154_51
	.cfi_def_cfa wsp, 368
	b	LBB154_37
LBB154_46:
	.cfi_restore_state
	cbz	x10, LBB154_22
LBB154_47:
	strh	w9, [x19, #40]
	b	LBB154_35
LBB154_48:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB154_49:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB154_50:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB154_51:
	bl	___stack_chk_fail
LBB154_52:
	mov	x0, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh1181, Lloh1182, Lloh1183
	.loh AdrpAdd	Lloh1184, Lloh1185
	.loh AdrpAdd	Lloh1186, Lloh1187
	.loh AdrpAdd	Lloh1188, Lloh1189
	.loh AdrpAdd	Lloh1190, Lloh1191
	.loh AdrpLdrGotLdr	Lloh1192, Lloh1193, Lloh1194
	.loh AdrpAdd	Lloh1195, Lloh1196
	.loh AdrpLdrGotLdr	Lloh1199, Lloh1200, Lloh1201
	.loh AdrpAdd	Lloh1197, Lloh1198
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirCreateFilePosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #1216
Lloh1202:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1203:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1204:
	ldr	x9, [x9]
	str	x9, [sp, #24]
	stur	x9, [x29, #-96]
	cbz	x0, LBB155_69
	str	x8, [sp, #16]
	tst	x0, #0x7
	b.ne	LBB155_70
	mov	x20, x3
	mov	x22, x2
	ldr	w21, [x1]
	ldrh	w25, [x4]
	ldrb	w19, [x4, #2]
	ldrb	w27, [x4, #3]
	ldrb	w26, [x4, #4]
	ldrb	w23, [x4, #5]
	ldrb	w24, [x4, #6]
	ldrb	w28, [x4, #7]
	add	x0, sp, #104
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #168
	add	x3, sp, #104
	mov	x1, x22
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldurh	w8, [x29, #-152]
	cbnz	w8, LBB155_43
	ldur	x22, [x29, #-168]
	tst	w19, #0x1
	mov	w8, #513
	cinc	w8, w8, ne
	bfi	w8, w27, #10, #1
	bfi	w8, w26, #11, #1
	bfi	w8, w28, #12, #1
	orr	w8, w8, #0x1000000
	and	w9, w23, #0x3
	cmp	w9, #1
	b.gt	LBB155_5
	ubfiz	w10, w24, #2, #1
	orr	w10, w10, w8
	orr	w10, w10, #0x10
	cmp	w9, #0
	csel	w23, w8, w10, eq
	sub	x0, x29, #144
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-136]
	cbz	w8, LBB155_7
	b	LBB155_43
LBB155_5:
	cmp	w9, #2
	b.ne	LBB155_71
	ubfiz	w9, w24, #2, #1
	orr	w8, w9, w8
	orr	w23, w8, #0x20
	sub	x0, x29, #144
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-136]
	cbnz	w8, LBB155_43
LBB155_7:
	ldur	x26, [x29, #-144]
LBB155_8:
	str	x25, [sp]
	mov	x0, x21
	mov	x1, x22
	mov	x2, x23
	bl	_openat
	mov	x20, x0
	cmn	w0, #1
	b.ne	LBB155_14
	bl	___error
	ldr	w19, [x0]
	tbnz	w19, #31, LBB155_67
	cmp	w19, #16, lsl #12
	b.hs	LBB155_67
	cmp	w19, #4
	b.ne	LBB155_13
	str	x26, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB155_8
	b	LBB155_43
LBB155_13:
	cbnz	w19, LBB155_22
LBB155_14:
	str	x26, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	tbz	w24, #0, LBB155_38
	sub	x0, x29, #128
	bl	l_Io.Threaded.Syscall.start
	ldurh	w19, [x29, #-120]
	cbnz	w19, LBB155_33
	ldur	x21, [x29, #-128]
LBB155_17:
	str	xzr, [sp]
	mov	x0, x20
	mov	w1, #3
	bl	_fcntl
	cmn	w0, #1
	b.ne	LBB155_25
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB155_67
	cmp	w8, #16, lsl #12
	b.hs	LBB155_67
	cmp	w8, #4
	b.ne	LBB155_34
	str	x21, [sp, #64]
	add	x0, sp, #64
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w19, w0, #0xffff
	b.eq	LBB155_17
	b	LBB155_33
LBB155_22:
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w19, #1
	cmp	w8, #91
	b.hi	LBB155_42
Lloh1205:
	adrp	x9, LJTI155_0@PAGE
Lloh1206:
	add	x9, x9, LJTI155_0@PAGEOFF
	adr	x10, LBB155_24
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB155_24:
	mov	w8, #39
	b	LBB155_63
LBB155_25:
	str	x21, [sp, #56]
	mov	x21, x0
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
	tbnz	w21, #31, LBB155_67
	mov	x19, x21
	sub	x0, x29, #112
	bl	l_Io.Threaded.Syscall.start
	ldurh	w21, [x29, #-104]
	cbnz	w21, LBB155_65
	and	w8, w19, #0x7fffffff
	and	w22, w8, #0xfffffffb
	ldur	x21, [x29, #-112]
LBB155_28:
	str	x22, [sp]
	mov	x0, x20
	mov	w1, #4
	bl	_fcntl
	cmn	w0, #1
	b.ne	LBB155_37
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB155_67
	cmp	w8, #16, lsl #12
	b.hs	LBB155_67
	cmp	w8, #4
	b.ne	LBB155_36
	str	x21, [sp, #88]
	add	x0, sp, #88
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w19, w0, #0xffff
	b.eq	LBB155_28
LBB155_33:
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	ldr	x8, [sp, #16]
	strh	w19, [x8, #8]
	ldur	x8, [x29, #-96]
Lloh1207:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1208:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1209:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB155_64
	b	LBB155_66
LBB155_34:
	cbz	w8, LBB155_68
	str	x21, [sp, #72]
	add	x0, sp, #72
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB155_42
	b	LBB155_40
LBB155_36:
	cbnz	w8, LBB155_39
LBB155_37:
	str	x21, [sp, #80]
	add	x0, sp, #80
	bl	l_Io.Threaded.Syscall.finish
LBB155_38:
	ldr	x8, [sp, #16]
	strh	wzr, [x8, #8]
	str	w20, [x8]
	strb	wzr, [x8, #4]
	ldur	x8, [x29, #-96]
Lloh1210:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1211:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1212:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB155_64
	b	LBB155_66
LBB155_39:
	str	x21, [sp, #96]
	add	x0, sp, #96
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB155_42
LBB155_40:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB155_67
	cmp	w8, #16, lsl #12
	b.hs	LBB155_67
LBB155_42:
	mov	w8, #12
LBB155_43:
	ldr	x9, [sp, #16]
	strh	w8, [x9, #8]
	ldur	x8, [x29, #-96]
Lloh1213:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1214:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1215:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB155_64
	b	LBB155_66
LBB155_44:
	mov	w8, #15
	b	LBB155_63
LBB155_45:
	mov	w8, #21
	b	LBB155_63
LBB155_46:
	mov	w8, #44
	b	LBB155_63
LBB155_47:
	mov	w8, #16
	b	LBB155_63
LBB155_48:
	mov	w8, #47
	b	LBB155_63
LBB155_49:
	mov	w8, #43
	b	LBB155_63
LBB155_50:
	mov	w8, #18
	b	LBB155_63
LBB155_51:
	mov	w8, #5
	b	LBB155_63
LBB155_52:
	mov	w8, #4
	b	LBB155_63
LBB155_53:
	mov	w8, #37
	b	LBB155_63
LBB155_54:
	mov	w8, #40
	b	LBB155_63
LBB155_55:
	mov	w8, #41
	b	LBB155_63
LBB155_56:
	mov	w8, #10
	b	LBB155_63
LBB155_57:
	mov	w8, #17
	b	LBB155_63
LBB155_58:
	mov	w8, #24
	b	LBB155_63
LBB155_59:
	mov	w8, #36
	b	LBB155_63
LBB155_60:
	mov	w8, #22
	b	LBB155_63
LBB155_61:
	mov	w8, #23
	b	LBB155_63
LBB155_62:
	mov	w8, #9
LBB155_63:
	ldr	x9, [sp, #16]
	str	w8, [x9, #8]
	str	xzr, [x9]
	ldur	x8, [x29, #-96]
Lloh1216:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1217:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1218:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB155_66
LBB155_64:
	add	sp, sp, #1216
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB155_65:
	.cfi_restore_state
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	ldr	x8, [sp, #16]
	strh	w21, [x8, #8]
	ldur	x8, [x29, #-96]
Lloh1219:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1220:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1221:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB155_64
LBB155_66:
	bl	___stack_chk_fail
LBB155_67:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB155_68:
	str	x21, [sp, #56]
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB155_69:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB155_70:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB155_71:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh1202, Lloh1203, Lloh1204
	.loh AdrpAdd	Lloh1205, Lloh1206
	.loh AdrpLdrGotLdr	Lloh1207, Lloh1208, Lloh1209
	.loh AdrpLdrGotLdr	Lloh1210, Lloh1211, Lloh1212
	.loh AdrpLdrGotLdr	Lloh1213, Lloh1214, Lloh1215
	.loh AdrpLdrGotLdr	Lloh1216, Lloh1217, Lloh1218
	.loh AdrpLdrGotLdr	Lloh1219, Lloh1220, Lloh1221
	.cfi_endproc
	.section	__TEXT,__const
LJTI155_0:
	.byte	(LBB155_50-LBB155_24)>>2
	.byte	(LBB155_24-LBB155_24)>>2
	.byte	(LBB155_24-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_45-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_52-LBB155_24)>>2
	.byte	(LBB155_56-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_57-LBB155_24)>>2
	.byte	(LBB155_59-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_45-LBB155_24)>>2
	.byte	(LBB155_54-LBB155_24)>>2
	.byte	(LBB155_51-LBB155_24)>>2
	.byte	(LBB155_46-LBB155_24)>>2
	.byte	(LBB155_58-LBB155_24)>>2
	.byte	(LBB155_61-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_60-LBB155_24)>>2
	.byte	(LBB155_44-LBB155_24)>>2
	.byte	(LBB155_47-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_55-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_62-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_48-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_53-LBB155_24)>>2
	.byte	(LBB155_49-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_44-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_42-LBB155_24)>>2
	.byte	(LBB155_46-LBB155_24)>>2

	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0
lCPI156_0:
	.byte	0
	.byte	1
	.byte	1
	.byte	0
	.space	1
	.space	1
	.space	1
	.space	1
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.atomicFileInit:
	.cfi_startproc
	sub	sp, sp, #192
	.cfi_def_cfa_offset 192
	stp	x28, x27, [sp, #96]
	stp	x26, x25, [sp, #112]
	stp	x24, x23, [sp, #128]
	stp	x22, x21, [sp, #144]
	stp	x20, x19, [sp, #160]
	stp	x29, x30, [sp, #176]
	add	x29, sp, #176
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x21, x7
	mov	x20, x6
	mov	x24, x5
	mov	x22, x4
	mov	x23, x3
	mov	x25, x2
	mov	x26, x1
	mov	x19, x0
Lloh1222:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1223:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1224:
	ldr	x8, [x8]
	str	x8, [sp, #24]
	str	x8, [sp, #88]
	ldr	w27, [x6]
	mov	x9, #-6148914691236517206
Lloh1225:
	adrp	x28, l___anon_10541@PAGE
Lloh1226:
	add	x28, x28, l___anon_10541@PAGEOFF
Lloh1227:
	adrp	x8, lCPI156_0@PAGE
Lloh1228:
	ldr	d0, [x8, lCPI156_0@PAGEOFF]
	str	q0, [sp]
LBB156_1:
	str	x9, [sp, #32]
	ldr	x8, [x25, #728]
	add	x1, sp, #32
	mov	x0, x26
	mov	w2, #8
	blr	x8
	ldr	x8, [sp, #32]
	ubfx	x9, x8, #4, #4
	ldrb	w9, [x28, x9]
	and	x10, x8, #0xf
	ldrb	w10, [x28, x10]
	ubfx	x11, x8, #12, #4
	ldrb	w11, [x28, x11]
	ubfx	x12, x8, #8, #4
	ldrb	w12, [x28, x12]
	ubfx	x13, x8, #20, #4
	ldrb	w13, [x28, x13]
	ubfx	x14, x8, #16, #4
	ldrb	w14, [x28, x14]
	lsr	w15, w8, #28
	ldrb	w15, [x28, x15]
	ubfx	x16, x8, #24, #4
	ldrb	w16, [x28, x16]
	ubfx	x17, x8, #36, #4
	ldrb	w17, [x28, x17]
	ubfx	x0, x8, #32, #4
	ldrb	w0, [x28, x0]
	ubfx	x1, x8, #44, #4
	ldrb	w1, [x28, x1]
	strb	w9, [sp, #72]
	strb	w10, [sp, #73]
	strb	w11, [sp, #74]
	strb	w12, [sp, #75]
	strb	w13, [sp, #76]
	strb	w14, [sp, #77]
	strb	w15, [sp, #78]
	strb	w16, [sp, #79]
	strb	w17, [sp, #80]
	strb	w0, [sp, #81]
	ubfx	x9, x8, #40, #4
	ldrb	w9, [x28, x9]
	strb	w1, [sp, #82]
	ubfx	x10, x8, #52, #4
	ldrb	w10, [x28, x10]
	strb	w9, [sp, #83]
	ubfx	x9, x8, #48, #4
	ldrb	w9, [x28, x9]
	strb	w10, [sp, #84]
	lsr	x10, x8, #60
	ldrb	w10, [x28, x10]
	strb	w9, [sp, #85]
	ubfx	x8, x8, #56, #4
	ldrb	w8, [x28, x8]
	strb	w10, [sp, #86]
	strb	w8, [sp, #87]
	str	w27, [sp, #44]
	ldr	q0, [sp]
	stur	s0, [sp, #50]
	strh	wzr, [sp, #54]
	strh	w24, [sp, #48]
	ldr	x9, [x25, #208]
	add	x8, sp, #56
	add	x1, sp, #44
	add	x2, sp, #72
	add	x4, sp, #48
	mov	x0, x26
	mov	w3, #16
	blr	x9
	ldrh	w8, [sp, #64]
	cbz	w8, LBB156_9
	cmp	w8, #21
	b.le	LBB156_6
	cmp	w8, #44
	mov	x9, #-6148914691236517206
	b.gt	LBB156_12
	cmp	w8, #22
	b.eq	LBB156_1
	cmp	w8, #36
	b.eq	LBB156_1
	b	LBB156_15
LBB156_6:
	cmp	w8, #5
	b.eq	LBB156_14
	cmp	w8, #15
	b.eq	LBB156_14
	cmp	w8, #17
	mov	x9, #-6148914691236517206
	b.eq	LBB156_1
	b	LBB156_15
LBB156_9:
	ldr	x8, [sp, #56]
	strh	wzr, [x19, #40]
	ldr	x9, [sp, #32]
	stp	x9, x23, [x19]
	stp	x22, x8, [x19, #16]
	mov	w8, #257
	strh	w8, [x19, #36]
	and	w8, w21, #0x1
	strb	w8, [x19, #38]
	ldr	w8, [x20]
	str	w8, [x19, #32]
LBB156_10:
	ldr	x8, [sp, #88]
Lloh1229:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1230:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1231:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB156_16
	.cfi_def_cfa wsp, 192
	ldp	x29, x30, [sp, #176]
	ldp	x20, x19, [sp, #160]
	ldp	x22, x21, [sp, #144]
	ldp	x24, x23, [sp, #128]
	ldp	x26, x25, [sp, #112]
	ldp	x28, x27, [sp, #96]
	add	sp, sp, #192
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB156_12:
	.cfi_restore_state
	cmp	w8, #45
	b.eq	LBB156_14
	cmp	w8, #47
	b.ne	LBB156_15
LBB156_14:
Lloh1232:
	adrp	x8, l___anon_10498@PAGE
Lloh1233:
	add	x8, x8, l___anon_10498@PAGEOFF
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldr	q0, [x8, #32]
	str	q0, [x19, #32]
	b	LBB156_10
LBB156_15:
	strh	w8, [x19, #40]
	b	LBB156_10
LBB156_16:
	bl	___stack_chk_fail
	.loh AdrpLdr	Lloh1227, Lloh1228
	.loh AdrpAdd	Lloh1225, Lloh1226
	.loh AdrpLdrGotLdr	Lloh1222, Lloh1223, Lloh1224
	.loh AdrpLdrGotLdr	Lloh1229, Lloh1230, Lloh1231
	.loh AdrpAdd	Lloh1232, Lloh1233
	.cfi_endproc

	.p2align	2
"l_fs.path.ComponentIterator(.posix,u8).last":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	ldr	x10, [x1, #8]
	ldr	x8, [x1, #24]
	cbz	x10, LBB157_11
	sub	x13, x10, x8
	mov	w12, #2
LBB157_2:
	add	x9, x10, x12
	sub	x9, x9, #2
	str	x9, [x1, #40]
	add	x11, x13, x12
	cmp	x11, #2
	b.eq	LBB157_12
	subs	x11, x9, #1
	b.lo	LBB157_18
	ldr	x14, [x1]
	ldrb	w9, [x14, x11]
	sub	x12, x12, #1
	cmp	w9, #47
	b.eq	LBB157_2
	sub	x15, x12, #2
	add	x9, x10, x12
	sub	x9, x9, #1
	cmn	x10, x15
	b.lo	LBB157_13
	mov	x11, x12
	mov	x10, x9
LBB157_7:
	str	x10, [x1, #32]
	cmp	x8, x10
	b.eq	LBB157_14
	subs	x10, x10, #1
	b.lo	LBB157_18
	ldrb	w15, [x14, x10]
	sub	x11, x11, #1
	cmp	w15, #47
	b.ne	LBB157_7
	neg	x13, x11
	add	x8, x10, #1
	b	LBB157_14
LBB157_11:
	str	xzr, [x1, #40]
	cbnz	x8, LBB157_18
LBB157_12:
	str	x8, [x1, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x0]
	str	xzr, [x0, #32]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB157_13:
	.cfi_restore_state
	.cfi_remember_state
	add	x15, x13, x12
	add	x15, x15, #1
	str	x9, [x1, #32]
	cmp	x15, #2
	b.ne	LBB157_19
LBB157_14:
	add	x10, x13, x12
	cmp	x10, #1
	b.ne	LBB157_16
	str	xzr, [x0, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x0]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB157_16:
	.cfi_restore_state
	.cfi_remember_state
	mov	w10, #1
	strb	w10, [x0, #32]
	cmp	x8, x9
	b.hi	LBB157_20
	add	x8, x14, x8
	add	x10, x13, x12
	sub	x10, x10, #1
	stp	x8, x10, [x0]
	stp	x14, x9, [x0, #16]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB157_18:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB157_19:
	mov	x0, x11
	mov	x1, x10
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB157_20:
	mov	x0, x8
	mov	x1, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirAccessPosix:
	.cfi_startproc
	stp	x28, x27, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
	sub	sp, sp, #1104
Lloh1234:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1235:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1236:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-72]
	cbz	x0, LBB158_27
	tst	x0, #0x7
	b.ne	LBB158_28
	mov	x22, x4
	mov	x20, x3
	mov	x21, x2
	ldr	w19, [x1]
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #112
	add	x3, sp, #32
	mov	x1, x21
	mov	x2, x20
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-96]
	cbnz	w0, LBB158_12
	ldur	x20, [x29, #-112]
	tst	w22, #0x1
	mov	w8, #32
	csel	w21, wzr, w8, ne
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB158_12
	and	w8, w22, #0xf
	lsr	w8, w8, #1
	and	w23, w8, #0x2
	bfxil	w23, w22, #3, #1
	bfi	w23, w8, #2, #1
	ldur	x22, [x29, #-88]
LBB158_5:
	mov	x0, x19
	mov	x1, x20
	mov	x2, x23
	mov	x3, x21
	bl	_faccessat
	cmn	w0, #1
	b.ne	LBB158_11
	bl	___error
	ldr	w24, [x0]
	tbnz	w24, #31, LBB158_26
	cmp	w24, #16, lsl #12
	b.hs	LBB158_26
	cmp	w24, #4
	b.ne	LBB158_10
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB158_5
	b	LBB158_12
LBB158_10:
	cbnz	w24, LBB158_14
LBB158_11:
	str	x22, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB158_12:
	ldur	x8, [x29, #-72]
Lloh1237:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1238:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1239:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB158_29
	add	sp, sp, #1104
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x28, x27, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB158_14:
	.cfi_restore_state
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w24, #1
	cmp	w8, #91
	b.hi	LBB158_25
	mov	w0, #10
Lloh1240:
	adrp	x9, LJTI158_0@PAGE
Lloh1241:
	add	x9, x9, LJTI158_0@PAGEOFF
	adr	x10, LBB158_12
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB158_16:
	mov	w0, #39
	b	LBB158_12
LBB158_17:
	mov	w0, #37
	b	LBB158_12
LBB158_18:
	mov	w0, #22
	b	LBB158_12
LBB158_19:
	mov	w0, #44
	b	LBB158_12
LBB158_20:
	mov	w0, #18
	b	LBB158_12
LBB158_21:
	mov	w0, #3
	b	LBB158_12
LBB158_22:
	mov	w0, #4
	b	LBB158_12
LBB158_23:
	mov	w0, #41
	b	LBB158_12
LBB158_24:
	mov	w0, #43
	b	LBB158_12
LBB158_25:
	mov	w0, #12
	b	LBB158_12
LBB158_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB158_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB158_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB158_29:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1234, Lloh1235, Lloh1236
	.loh AdrpLdrGotLdr	Lloh1237, Lloh1238, Lloh1239
	.loh AdrpAdd	Lloh1240, Lloh1241
	.cfi_endproc
	.section	__TEXT,__const
LJTI158_0:
	.byte	(LBB158_20-LBB158_12)>>2
	.byte	(LBB158_16-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_21-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_22-LBB158_12)>>2
	.byte	(LBB158_12-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_16-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_18-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_23-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_17-LBB158_12)>>2
	.byte	(LBB158_24-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_25-LBB158_12)>>2
	.byte	(LBB158_19-LBB158_12)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.dirStatFilePosix:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	sub	sp, sp, #1296
	mov	x19, x8
Lloh1242:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1243:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1244:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-72]
	cbz	x0, LBB159_38
	tst	x0, #0x7
	b.ne	LBB159_39
	mov	x21, x3
	mov	x22, x2
	ldr	w20, [x1]
	ldrb	w24, [x4]
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	add	x0, sp, #1056
	add	x3, sp, #32
	mov	x1, x22
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldrh	w8, [sp, #1072]
	cbnz	w8, LBB159_35
	add	x23, sp, #1080
	ldr	x21, [sp, #1056]
	tst	w24, #0x1
	mov	w8, #32
	csel	w22, wzr, w8, ne
	sub	x0, x29, #240
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-232]
	cbnz	w8, LBB159_10
	ldur	x25, [x29, #-240]
LBB159_5:
	movi.2d	v0, #0000000000000000
	stur	q0, [x23, #184]
	stur	q0, [x23, #168]
	stur	q0, [x23, #152]
	stur	q0, [x23, #136]
	stur	q0, [x23, #120]
	stur	q0, [x23, #104]
	stur	q0, [x23, #88]
	stur	q0, [x23, #72]
	stur	q0, [x23, #56]
	sub	x2, x29, #224
	mov	x0, x20
	mov	x1, x21
	mov	x3, x22
	bl	_fstatat
	cmn	w0, #1
	b.ne	LBB159_12
	bl	___error
	ldr	w24, [x0]
	tbnz	w24, #31, LBB159_37
	cmp	w24, #16, lsl #12
	b.hs	LBB159_37
	cmp	w24, #4
	b.ne	LBB159_11
	str	x25, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB159_5
LBB159_10:
	b	LBB159_33
LBB159_11:
	cbnz	w24, LBB159_14
LBB159_12:
	str	x25, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	ldur	w10, [x29, #-112]
	tbnz	w10, #31, LBB159_37
	mov	w8, #0
	ldurh	w11, [x29, #-220]
	and	w9, w11, #0xffff
	lsr	x11, x11, #10
	and	x11, x11, #0x3c
	mov	x12, #41274
	movk	x12, #41122, lsl #16
	movk	x12, #42149, lsl #32
	movk	x12, #43686, lsl #48
	lsr	x12, x12, x11
	ldurh	w11, [x29, #-218]
	ldur	x13, [x29, #-128]
	ldp	x17, x14, [x29, #-160]
	asr	x16, x14, #63
	ldp	x2, x0, [x29, #-176]
	asr	x1, x0, #63
	ldp	x6, x3, [x29, #-192]
	asr	x4, x3, #63
	mov	w5, #51712
	movk	w5, #15258, lsl #16
	mul	x15, x17, x5
	adds	x15, x15, x14
	ldur	x14, [x29, #-216]
	smulh	x17, x17, x5
	adc	x16, x17, x16
	sxtw	x16, w16
	smulh	x7, x2, x5
	mul	x17, x2, x5
	adds	x17, x17, x0
	adc	x0, x7, x1
	sxtw	x0, w0
	smulh	x2, x6, x5
	mul	x1, x6, x5
	adds	x1, x1, x3
	adc	x2, x2, x4
	sxtw	x2, w2
	and	w12, w12, #0xf
	b	LBB159_33
LBB159_14:
	str	x25, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	cmp	w24, #19
	b.gt	LBB159_18
	cmp	w24, #11
	b.gt	LBB159_22
	cmp	w24, #1
	b.eq	LBB159_29
	cmp	w24, #2
	b.eq	LBB159_28
	b	LBB159_33
LBB159_18:
	cmp	w24, #62
	b.gt	LBB159_25
	cmp	w24, #20
	b.eq	LBB159_28
	cmp	w24, #62
	b.ne	LBB159_33
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #37
	b	LBB159_32
LBB159_22:
	cmp	w24, #12
	b.eq	LBB159_30
	cmp	w24, #13
	b.ne	LBB159_33
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #10
	b	LBB159_32
LBB159_25:
	cmp	w24, #63
	b.eq	LBB159_31
	cmp	w24, #92
	b.ne	LBB159_33
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #44
	b	LBB159_32
LBB159_28:
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #39
	b	LBB159_32
LBB159_29:
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #18
	b	LBB159_32
LBB159_30:
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #4
	b	LBB159_32
LBB159_31:
	stur	xzr, [x23, #31]
	stur	xzr, [x29, #-256]
	str	wzr, [sp, #1096]
	stur	wzr, [x23, #19]
	str	xzr, [sp, #1080]
	mov	w8, #43
LBB159_32:
	stur	xzr, [x23, #6]
LBB159_33:
	stp	x1, x2, [x19]
	mov	w1, #1
	strb	w1, [x19, #16]
	ldur	x1, [x29, #-256]
	stur	x1, [x19, #17]
	ldur	x1, [x23, #31]
	stp	x1, x17, [x19, #24]
	stp	x0, x15, [x19, #40]
	stp	x16, x14, [x19, #56]
	str	x13, [x19, #72]
	str	w10, [x19, #80]
	strh	w11, [x19, #84]
	strh	w9, [x19, #86]
	strb	w12, [x19, #88]
	ldr	w9, [sp, #1096]
	stur	w9, [x19, #89]
	ldur	w9, [x23, #19]
	str	w9, [x19, #92]
	strh	w8, [x19, #96]
	ldr	x8, [sp, #1080]
	stur	x8, [x19, #98]
	ldur	x8, [x23, #6]
	str	x8, [x19, #104]
	ldur	x8, [x29, #-72]
Lloh1245:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1246:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1247:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB159_36
LBB159_34:
	add	sp, sp, #1296
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB159_35:
	.cfi_restore_state
	strh	w8, [x19, #96]
	ldur	x8, [x29, #-72]
Lloh1248:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1249:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1250:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB159_34
LBB159_36:
	bl	___stack_chk_fail
LBB159_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB159_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB159_39:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdrGotLdr	Lloh1242, Lloh1243, Lloh1244
	.loh AdrpLdrGotLdr	Lloh1245, Lloh1246, Lloh1247
	.loh AdrpLdrGotLdr	Lloh1248, Lloh1249, Lloh1250
	.cfi_endproc

	.p2align	2
"l_fs.path.ComponentIterator(.posix,u8).previous":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x8, x1
	ldr	x1, [x1, #8]
	ldp	x9, x10, [x8, #24]
	sub	x11, x10, #1
	cmp	x11, x1
	b.hs	LBB160_16
	ldr	x12, [x8]
LBB160_2:
	cmp	x9, x10
	b.eq	LBB160_17
	subs	x10, x10, #1
	b.lo	LBB160_19
	ldrb	w11, [x12, x10]
	cmp	w11, #47
	b.eq	LBB160_2
	cmp	x10, x1
	b.hs	LBB160_21
	add	x11, x10, #1
	add	x13, x10, #1
LBB160_7:
	cmp	x9, x13
	b.eq	LBB160_11
	subs	x13, x13, #1
	b.lo	LBB160_19
	ldrb	w14, [x12, x13]
	cmp	w14, #47
	b.ne	LBB160_7
	add	x9, x13, #1
LBB160_11:
	sub	x10, x10, x9
	cmn	x10, #1
	b.hs	LBB160_17
	cmp	x9, x11
	b.hi	LBB160_22
	cmp	x11, x1
	b.hi	LBB160_23
	add	x10, x10, #1
	subs	x13, x11, x10
	b.lo	LBB160_19
	add	x9, x12, x9
	stp	x13, x11, [x8, #32]
	stp	x9, x10, [x0]
	stp	x12, x11, [x0, #16]
	mov	w8, #1
	strb	w8, [x0, #32]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB160_16:
	.cfi_restore_state
	.cfi_remember_state
	cmp	x10, x9
	b.ne	LBB160_18
LBB160_17:
	str	xzr, [x0, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x0]
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB160_18:
	.cfi_restore_state
	subs	x0, x10, #1
	b.hs	LBB160_20
LBB160_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB160_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB160_21:
	mov	x0, x10
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB160_22:
	mov	x0, x9
	mov	x1, x11
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB160_23:
	mov	x0, x11
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirStat:
	.cfi_startproc
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x20, x19, [sp, #144]
	stp	x29, x30, [sp, #160]
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x8
Lloh1251:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1252:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1253:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-24]
	cbz	x0, LBB161_4
	tst	x0, #0x7
	b.ne	LBB161_5
	ldr	w8, [x1]
	str	w8, [sp, #8]
	strb	wzr, [sp, #12]
	add	x8, sp, #16
	add	x1, sp, #8
	bl	l_Io.Threaded.fileStatPosix
	ldp	q0, q1, [sp, #80]
	stp	q0, q1, [x19, #64]
	ldr	q0, [sp, #112]
	str	q0, [x19, #96]
	ldp	q0, q1, [sp, #16]
	stp	q0, q1, [x19]
	ldp	q1, q0, [sp, #48]
	stp	q1, q0, [x19, #32]
	ldur	x8, [x29, #-24]
Lloh1254:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1255:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1256:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB161_6
	.cfi_def_cfa wsp, 176
	ldp	x29, x30, [sp, #160]
	ldp	x20, x19, [sp, #144]
	add	sp, sp, #176
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB161_4:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB161_5:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB161_6:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1251, Lloh1252, Lloh1253
	.loh AdrpLdrGotLdr	Lloh1254, Lloh1255, Lloh1256
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirCreateDirPathOpenPosix:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x26, x25, [sp, #48]
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x19, x8
Lloh1257:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1258:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1259:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #40]
	cbz	x0, LBB162_10
	mov	x24, x0
	tst	x0, #0x7
	b.ne	LBB162_11
	mov	x20, x5
	mov	x25, x4
	mov	x21, x3
	mov	x22, x2
	mov	x23, x1
	ldr	w26, [x1]
	add	x8, sp, #16
	mov	x0, x24
	mov	x4, x5
	bl	l_Io.Threaded.dirOpenDirPosix
	ldrh	w8, [sp, #20]
	cbnz	w8, LBB162_6
	ldr	w8, [sp, #16]
	str	w8, [x19]
	strh	wzr, [x19, #4]
LBB162_4:
	ldr	x8, [sp, #40]
Lloh1260:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1261:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1262:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB162_12
	.cfi_def_cfa wsp, 128
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	ldp	x26, x25, [sp, #48]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB162_6:
	.cfi_restore_state
	cmp	w8, #39
	b.ne	LBB162_9
	str	w26, [sp, #12]
	add	x8, sp, #36
	add	x1, sp, #12
	mov	x0, x24
	mov	x2, x22
	mov	x3, x21
	mov	x4, x25
	bl	l_Io.Threaded.dirCreateDirPath
	ldr	w8, [sp, #36]
	tst	w8, #0xffff
	b.ne	LBB162_9
	add	x8, sp, #24
	mov	x0, x24
	mov	x1, x23
	mov	x2, x22
	mov	x3, x21
	mov	x4, x20
	bl	l_Io.Threaded.dirOpenDirPosix
	ldr	x8, [sp, #24]
	str	x8, [x19]
	b	LBB162_4
LBB162_9:
	strh	w8, [x19, #4]
	b	LBB162_4
LBB162_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB162_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB162_12:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1257, Lloh1258, Lloh1259
	.loh AdrpLdrGotLdr	Lloh1260, Lloh1261, Lloh1262
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirCreateDirPath:
	.cfi_startproc
	sub	sp, sp, #368
	.cfi_def_cfa_offset 368
	stp	x28, x27, [sp, #272]
	stp	x26, x25, [sp, #288]
	stp	x24, x23, [sp, #304]
	stp	x22, x21, [sp, #320]
	stp	x20, x19, [sp, #336]
	stp	x29, x30, [sp, #352]
	add	x29, sp, #352
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
Lloh1263:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1264:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1265:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-88]
	cbz	x0, LBB163_44
	mov	x22, x0
	tst	x0, #0x7
	b.ne	LBB163_45
	mov	x20, x4
	mov	x21, x1
	cbz	x3, LBB163_5
	ldrb	w8, [x2]
	cmp	w8, #47
	cset	w8, eq
	cmp	x3, x8
	b.ne	LBB163_6
	mov	w8, #1
	mov	w9, #1
	b	LBB163_11
LBB163_5:
	mov	x8, #0
	mov	x9, #0
	b	LBB163_11
LBB163_6:
	mov	x10, #0
	mov	x9, x8
LBB163_7:
	ldrb	w11, [x2, x9]
	cmp	w11, #47
	b.ne	LBB163_11
	eor	x11, x10, x8
	cmn	x11, #1
	b.eq	LBB163_41
	add	x10, x10, #1
	add	x9, x9, #1
	cmp	x3, x9
	b.ne	LBB163_7
	mov	x9, x3
LBB163_11:
	stp	x2, x3, [sp, #16]
	stp	x8, x9, [sp, #32]
	stp	x9, x9, [sp, #48]
	add	x0, sp, #64
	add	x1, sp, #16
	bl	"l_fs.path.ComponentIterator(.posix,u8).last"
	ldrb	w8, [sp, #96]
	tbz	w8, #0, LBB163_34
	mov	w26, #0
	ldp	x24, x25, [sp, #80]
Lloh1266:
	adrp	x23, l___anon_10682@PAGE
Lloh1267:
	add	x23, x23, l___anon_10682@PAGEOFF
LBB163_13:
	mov	x0, x22
	mov	x1, x21
	mov	x2, x24
	mov	x3, x25
	mov	x4, x20
	bl	l_Io.Threaded.dirCreateDirPosix
	ands	w8, w0, #0xffff
	b.ne	LBB163_27
	mov	w26, #1
LBB163_15:
	ldp	x24, x1, [sp, #16]
	ldr	x0, [sp, #56]
	cmp	x0, x1
	b.hs	LBB163_18
LBB163_16:
	ldrb	w8, [x24, x0]
	cmp	w8, #47
	b.ne	LBB163_18
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	LBB163_16
	b	LBB163_36
LBB163_18:
	mov	x25, x0
	cmp	x0, x1
	b.hs	LBB163_36
LBB163_19:
	ldrb	w8, [x24, x25]
	cmp	w8, #47
	b.eq	LBB163_22
	add	x25, x25, #1
	cmp	x1, x25
	b.ne	LBB163_19
	mov	x25, x1
LBB163_22:
	subs	x8, x25, x0
	b.eq	LBB163_36
	b.lo	LBB163_43
	cmp	x25, x1
	b.hi	LBB163_42
	subs	x8, x25, x8
	b.lo	LBB163_41
	stp	x8, x25, [sp, #48]
	b	LBB163_13
LBB163_27:
	cmp	w8, #36
	b.eq	LBB163_31
	cmp	w8, #39
	b.ne	LBB163_39
	add	x0, sp, #104
	add	x1, sp, #16
	bl	"l_fs.path.ComponentIterator(.posix,u8).previous"
	ldrb	w8, [sp, #136]
	tbz	w8, #0, LBB163_40
	ldp	x24, x25, [sp, #120]
	b	LBB163_13
LBB163_31:
	add	x8, sp, #144
	mov	x0, x22
	mov	x1, x21
	mov	x2, x24
	mov	x3, x25
	mov	x4, x23
	bl	l_Io.Threaded.dirStatFilePosix
	ldrh	w8, [sp, #240]
	cbnz	w8, LBB163_47
	ldrb	w8, [sp, #232]
	and	w8, w8, #0xf
	cmp	w8, #2
	b.eq	LBB163_15
	mov	w8, #40
	b	LBB163_35
LBB163_34:
	mov	w8, #44
LBB163_35:
	str	w8, [x19]
	b	LBB163_37
LBB163_36:
	and	w8, w26, #0x1
	strh	wzr, [x19]
	strb	w8, [x19, #2]
LBB163_37:
	ldur	x8, [x29, #-88]
Lloh1268:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1269:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1270:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB163_46
	.cfi_def_cfa wsp, 368
	ldp	x29, x30, [sp, #352]
	ldp	x20, x19, [sp, #336]
	ldp	x22, x21, [sp, #320]
	ldp	x24, x23, [sp, #304]
	ldp	x26, x25, [sp, #288]
	ldp	x28, x27, [sp, #272]
	add	sp, sp, #368
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB163_39:
	.cfi_restore_state
	strh	w0, [x19]
	b	LBB163_37
LBB163_40:
	mov	w8, #39
	b	LBB163_35
LBB163_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB163_42:
	mov	x0, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB163_43:
	mov	x1, x25
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB163_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB163_45:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB163_46:
	bl	___stack_chk_fail
LBB163_47:
	strh	w8, [x19]
	b	LBB163_37
	.loh AdrpLdrGotLdr	Lloh1263, Lloh1264, Lloh1265
	.loh AdrpAdd	Lloh1266, Lloh1267
	.loh AdrpLdrGotLdr	Lloh1268, Lloh1269, Lloh1270
	.cfi_endproc

	.p2align	2
l_Io.Threaded.dirCreateDirPosix:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	sub	sp, sp, #1104
Lloh1271:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1272:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1273:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-56]
	cbz	x0, LBB164_29
	tst	x0, #0x7
	b.ne	LBB164_30
	mov	x19, x4
	mov	x21, x3
	mov	x22, x2
	ldr	w20, [x1]
	add	x0, sp, #32
	mov	w1, #170
	mov	w2, #1024
	bl	_memset
	sub	x0, x29, #96
	add	x3, sp, #32
	mov	x1, x22
	mov	x2, x21
	bl	l_Io.Threaded.pathToPosix
	ldurh	w0, [x29, #-80]
	cbnz	w0, LBB164_26
	ldur	x21, [x29, #-96]
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w0, [x29, #-64]
	cbnz	w0, LBB164_26
	ldur	x22, [x29, #-72]
Lloh1274:
	adrp	x23, LJTI164_0@PAGE
Lloh1275:
	add	x23, x23, LJTI164_0@PAGEOFF
LBB164_5:
	and	w2, w19, #0xffff
	mov	x0, x20
	mov	x1, x21
	bl	_mkdirat
	cmn	w0, #1
	b.ne	LBB164_12
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB164_28
	cmp	w8, #16, lsl #12
	b.hs	LBB164_28
	cmp	w8, #92
	b.hi	LBB164_11
	adr	x9, LBB164_10
	ldrb	w10, [x23, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB164_10:
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB164_5
	b	LBB164_26
LBB164_11:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB164_26
LBB164_12:
	str	x22, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
	b	LBB164_26
LBB164_13:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #39
	b	LBB164_26
LBB164_14:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #16
	b	LBB164_26
LBB164_15:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #43
	b	LBB164_26
LBB164_16:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #4
	b	LBB164_26
LBB164_17:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #40
	b	LBB164_26
LBB164_18:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #37
	b	LBB164_26
LBB164_19:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #44
	b	LBB164_26
LBB164_20:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #38
	b	LBB164_26
LBB164_21:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #41
	b	LBB164_26
LBB164_22:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #18
	b	LBB164_26
LBB164_23:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #10
	b	LBB164_26
LBB164_24:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #36
	b	LBB164_26
LBB164_25:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #14
LBB164_26:
	ldur	x8, [x29, #-56]
Lloh1276:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1277:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1278:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB164_31
	add	sp, sp, #1104
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB164_28:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB164_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB164_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB164_31:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1271, Lloh1272, Lloh1273
	.loh AdrpAdd	Lloh1274, Lloh1275
	.loh AdrpLdrGotLdr	Lloh1276, Lloh1277, Lloh1278
	.cfi_endproc
	.section	__TEXT,__const
LJTI164_0:
	.byte	(LBB164_12-LBB164_10)>>2
	.byte	(LBB164_22-LBB164_10)>>2
	.byte	(LBB164_13-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_10-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_16-LBB164_10)>>2
	.byte	(LBB164_23-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_24-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_17-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_14-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_21-LBB164_10)>>2
	.byte	(LBB164_20-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_13-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_18-LBB164_10)>>2
	.byte	(LBB164_15-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_25-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_11-LBB164_10)>>2
	.byte	(LBB164_19-LBB164_10)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.batchCancel:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	cbz	x0, LBB165_9
	tst	x0, #0x7
	b.ne	LBB165_8
	mov	x19, x1
	ldr	x21, [x1, #16]
	cbz	x21, LBB165_7
	tst	x21, #0x3
	b.ne	LBB165_8
	ldr	x8, [x19, #8]
	cbz	x8, LBB165_6
	mov	x20, x30
	ldr	x24, [x0, #752]
	ldr	x22, [x0, #744]
	lsl	x23, x8, #3
	mov	x0, x21
	mov	w1, #170
	mov	x2, x23
	bl	_memset
	xpaci	x20
	ldr	x8, [x24, #24]
	mov	x0, x22
	mov	x1, x21
	mov	x2, x23
	mov	w3, #2
	mov	x4, x20
	blr	x8
LBB165_6:
	str	xzr, [x19, #16]
LBB165_7:
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB165_8:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB165_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.batchAwaitConcurrent:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #1008
Lloh1279:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1280:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1281:
	ldr	x8, [x8]
	str	x8, [sp, #80]
	stur	x8, [x29, #-96]
	cbz	x0, LBB166_144
	tst	x0, #0x7
	b.ne	LBB166_145
	mov	x27, x1
	ldp	x8, x9, [x2]
	str	x8, [sp, #40]
	ldrb	w10, [x2, #16]
	ldrb	w11, [x2, #32]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #576]
	stp	q0, q0, [sp, #544]
	stp	q0, q0, [sp, #512]
	stp	q0, q0, [sp, #480]
	stp	q0, q0, [sp, #448]
	stp	q0, q0, [sp, #416]
	stp	q0, q0, [sp, #384]
	stp	q0, q0, [sp, #352]
	stp	q0, q0, [sp, #320]
	stp	q0, q0, [sp, #288]
	stp	q0, q0, [sp, #256]
	stp	q0, q0, [sp, #224]
	stp	q0, q0, [sp, #192]
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #96]
	add	x8, x0, #744
	ldr	q0, [x8]
	str	q0, [sp, #608]
	add	x8, sp, #96
	str	x1, [sp, #624]
	str	x8, [sp, #632]
	mov	w8, #64
	str	x8, [sp, #640]
	str	wzr, [sp, #648]
	ldr	w21, [x1, #32]
	cmn	w21, #1
	b.eq	LBB166_118
	str	w11, [sp, #20]
	str	x2, [sp, #8]
	str	w10, [sp, #36]
	str	x9, [sp, #24]
	stp	x0, x27, [sp, #48]
	mov	w20, #88
	mov	w24, #-1
	b	LBB166_6
LBB166_4:
	add	x0, sp, #608
	mov	x1, x22
	mov	w2, #13
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	b.ne	LBB166_92
LBB166_5:
	ldr	x8, [sp, #72]
	mov	x21, x8
	cmp	x8, x24
	b.eq	LBB166_48
LBB166_6:
	ldr	x1, [x27, #8]
	cmp	x1, x21
	b.ls	LBB166_135
	ldr	x8, [x27]
	madd	x19, x21, x20, x8
	ldrb	w0, [x19, #80]
	and	w8, w0, #0x3
	cmp	w8, #1
	b.ne	LBB166_134
	ldp	x26, x22, [x19]
	ldr	x23, [x19, #16]
	ldr	w25, [x19, #32]
	ldrb	w8, [x19, #64]
	ldr	w9, [x19, #72]
	str	x9, [sp, #72]
	and	w8, w8, #0x7
	cmp	w8, #3
	b.gt	LBB166_12
	cmp	w8, #1
	b.gt	LBB166_18
	cbnz	w8, LBB166_29
	add	x0, sp, #608
	mov	x1, x23
	mov	w2, #9
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	b.eq	LBB166_5
	b	LBB166_92
LBB166_12:
	cmp	w8, #5
	b.gt	LBB166_27
	cmp	w8, #4
	b.ne	LBB166_30
	mov	x28, x8
	lsr	x4, x23, #32
	add	x0, sp, #656
	mov	x1, x23
	mov	x2, x26
	mov	x3, x22
	mov	w5, #1
	bl	l_Io.Threaded.netSendPosix
	ldrh	w0, [sp, #656]
	ldr	x24, [sp, #664]
	cmp	w0, #2
	b.eq	LBB166_34
	cmp	w0, #9
	b.ne	LBB166_37
	cbnz	x24, LBB166_36
	add	x0, sp, #608
	mov	x1, x23
	mov	w2, #12
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	mov	w24, #-1
	b.eq	LBB166_5
	b	LBB166_92
LBB166_18:
	str	w8, [sp, #68]
	cmp	w8, #2
	b.eq	LBB166_4
	cbz	x22, LBB166_31
	mov	x24, #0
	mov	x28, #0
	ldr	x27, [x19, #24]
	ldr	w20, [x19, #36]
LBB166_21:
	subs	x3, x27, x28
	b.lo	LBB166_133
	add	x2, x23, x28
	mov	x0, x25
	mov	x1, x26
	mov	x4, x20
	mov	w5, #1
	bl	l_Io.Threaded.netReceivePosix
	ands	w8, w0, #0xffff
	b.ne	LBB166_41
	ldr	x8, [x26, #8]
	adds	x28, x28, x8
	b.hs	LBB166_132
	add	x26, x26, #72
	add	x24, x24, #1
	cmp	x22, x24
	b.ne	LBB166_21
	mov	w0, #0
	mov	x24, x22
LBB166_26:
	ldr	x27, [sp, #56]
	mov	w20, #88
	ldr	w28, [sp, #68]
	ldr	w8, [x27, #52]
	cmn	w8, #1
	b.ne	LBB166_32
	b	LBB166_45
LBB166_27:
	cmp	w8, #6
	b.ne	LBB166_139
	ldr	w1, [x19, #56]
	add	x0, sp, #608
	mov	w2, #12
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	b.eq	LBB166_5
	b	LBB166_92
LBB166_29:
	ldr	w1, [x19, #40]
	add	x0, sp, #608
	mov	w2, #12
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	b.eq	LBB166_5
	b	LBB166_92
LBB166_30:
	add	x0, sp, #608
	mov	x1, x25
	mov	w2, #9
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	b.eq	LBB166_5
	b	LBB166_92
LBB166_31:
	mov	w0, #0
	mov	x24, #0
	ldr	w28, [sp, #68]
	ldr	w8, [x27, #52]
	cmn	w8, #1
	b.eq	LBB166_45
LBB166_32:
	ldr	x1, [x27, #8]
	cmp	x1, x8
	b.ls	LBB166_140
	ldr	x9, [x27]
	umaddl	x9, w8, w20, x9
	ldrb	w8, [x9, #80]
	mov	w11, #3
	bics	wzr, w11, w8
	b.eq	LBB166_40
	b	LBB166_142
LBB166_34:
	cbz	x24, LBB166_121
	bl	l_Io.Threaded.recancelInner
LBB166_36:
	mov	w0, #0
LBB166_37:
	ldr	w8, [x27, #52]
	cmn	w8, #1
	b.eq	LBB166_45
	ldr	x1, [x27, #8]
	cmp	x1, x8
	b.ls	LBB166_140
	ldr	x9, [x27]
	umaddl	x9, w8, w20, x9
	ldrb	w8, [x9, #80]
	mov	w11, #3
	bics	wzr, w11, w8
	b.ne	LBB166_142
LBB166_40:
	str	w21, [x9, #40]
	b	LBB166_46
LBB166_41:
	cmp	w8, #2
	b.eq	LBB166_119
	cmp	w8, #9
	b.ne	LBB166_26
	ldr	x27, [sp, #56]
	mov	w20, #88
	ldr	w28, [sp, #68]
	cbz	x24, LBB166_47
	mov	w0, #0
	ldr	w8, [x27, #52]
	cmn	w8, #1
	b.ne	LBB166_32
LBB166_45:
	str	w21, [x27, #48]
LBB166_46:
	mov	w8, #3
	strb	w8, [x19, #80]
	mov	w8, #-1
	str	w8, [x19, #40]
	strh	w0, [x19]
	str	x24, [x19, #8]
	mov	w24, #-1
	strb	w28, [x19, #32]
	str	w21, [x27, #52]
	ldr	x8, [sp, #72]
	mov	x21, x8
	cmp	x8, x24
	b.ne	LBB166_6
	b	LBB166_48
LBB166_47:
	add	x0, sp, #608
	mov	x1, x25
	mov	w2, #9
	bl	l_Io.Threaded.batchAwaitConcurrent__struct_243.add
	tst	w0, #0xffff
	mov	w24, #-1
	b.eq	LBB166_5
	b	LBB166_92
LBB166_48:
	ldr	w21, [sp, #648]
	cbz	w21, LBB166_118
	cmp	w21, #1
	b.ne	LBB166_52
	ldr	x8, [sp, #8]
	ldrb	w8, [x8, #32]
	tst	w8, #0x3
	b.ne	LBB166_52
	ldr	w8, [x27, #48]
	cmn	w8, #1
	b.eq	LBB166_122
LBB166_52:
	ldr	w8, [sp, #20]
	and	w8, w8, #0x3
	cmp	w8, #1
	b.gt	LBB166_63
	ldr	w9, [sp, #36]
	cbnz	w8, LBB166_64
	ldr	x22, [sp, #632]
LBB166_55:
	ldr	w19, [x27, #48]
	add	x0, sp, #800
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #808]
	cbnz	w0, LBB166_119
LBB166_56:
	cmn	w19, #1
	csetm	w2, eq
	ldr	x19, [sp, #800]
	mov	x0, x22
	mov	x1, x21
	bl	_poll
	mov	x20, x0
	str	x19, [sp, #88]
	add	x0, sp, #88
	bl	l_Io.Threaded.Syscall.finish
	cbnz	w20, LBB166_59
	ldr	w8, [x27, #48]
	cmn	w8, #1
	b.ne	LBB166_118
	mov	w19, #-1
	add	x0, sp, #800
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #808]
	cbz	w0, LBB166_56
	b	LBB166_119
LBB166_59:
	cmn	w20, #1
	b.ne	LBB166_95
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB166_136
	cmp	w8, #16, lsl #12
	b.hs	LBB166_136
	cmp	w8, #4
	b.eq	LBB166_55
	b	LBB166_91
LBB166_63:
	cmp	w8, #2
	ldr	w8, [sp, #36]
	b.eq	LBB166_73
	b	LBB166_139
LBB166_64:
	eor	w8, w9, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB166_139
Lloh1282:
	adrp	x9, l_switch.table.Io.Threaded.futexWait@PAGE
Lloh1283:
	add	x9, x9, l_switch.table.Io.Threaded.futexWait@PAGEOFF
	and	x8, x8, #0x7
	ldr	w0, [x9, x8, lsl #2]
	mov	x8, #-6148914691236517206
	stp	x8, x8, [x29, #-144]
	sub	x1, x29, #144
	bl	_clock_gettime
	cmn	w0, #1
	ldr	x19, [sp, #24]
	b.eq	LBB166_67
LBB166_66:
	ldp	x8, x9, [x29, #-144]
	asr	x10, x9, #63
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	smulh	x12, x8, x11
	mul	x8, x8, x11
	adds	x8, x8, x9
	adc	x9, x12, x10
	b	LBB166_71
LBB166_67:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB166_136
	cmp	w8, #16, lsl #12
	b.hs	LBB166_136
	cbz	w8, LBB166_66
	mov	x8, #0
	mov	x9, #0
LBB166_71:
	sxtw	x10, w19
	sxtw	x9, w9
	ldr	x11, [sp, #40]
	adds	x11, x8, x11
	str	x11, [sp, #40]
	adc	x9, x9, x10
	sxtw	x8, w9
	str	x9, [sp, #24]
	eor	x8, x8, x9
	cbnz	x8, LBB166_132
	ldr	w8, [sp, #36]
LBB166_73:
	eor	w8, w8, #0x4
	and	x19, x8, #0x7
	ldr	x22, [sp, #632]
	mov	w8, #241
	lsr	w23, w8, w19
	mov	x24, #-6148914691236517206
	mov	w25, #51712
	movk	w25, #15258, lsl #16
	ldr	x8, [sp, #24]
	sxtw	x26, w8
	mov	w28, #2147483647
LBB166_74:
	ldr	w8, [x27, #48]
	cmn	w8, #1
	b.eq	LBB166_76
	mov	w20, #0
	add	x0, sp, #800
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #808]
	cbz	w0, LBB166_87
	b	LBB166_119
LBB166_76:
	tbz	w23, #0, LBB166_139
Lloh1284:
	adrp	x8, l_switch.table.Io.Threaded.futexWait@PAGE
Lloh1285:
	add	x8, x8, l_switch.table.Io.Threaded.futexWait@PAGEOFF
	ldr	w0, [x8, x19, lsl #2]
	stp	x24, x24, [x29, #-144]
	sub	x1, x29, #144
	bl	_clock_gettime
	cmn	w0, #1
	b.eq	LBB166_79
LBB166_78:
	ldp	x8, x9, [x29, #-144]
	asr	x10, x9, #63
	smulh	x11, x8, x25
	mul	x8, x8, x25
	adds	x8, x8, x9
	adc	x9, x11, x10
	b	LBB166_83
LBB166_79:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB166_136
	cmp	w8, #16, lsl #12
	b.hs	LBB166_136
	cbz	w8, LBB166_78
	mov	x8, #0
	mov	x9, #0
LBB166_83:
	sxtw	x9, w9
	ldr	x10, [sp, #40]
	subs	x0, x10, x8
	sbc	x8, x26, x9
	sxtw	x1, w8
	eor	x8, x1, x8
	cbnz	x8, LBB166_132
	mov	x8, #-16959
	movk	x8, #65520, lsl #16
	cmp	x0, x8
	mov	x8, #-41249
	movk	x8, #65528, lsl #16
	sbcs	xzr, x1, x8
	b.lt	LBB166_136
	mov	w8, #41247
	movk	w8, #7, lsl #16
	cmp	x1, x8
	b.gt	LBB166_136
	mov	w2, #16960
	movk	w2, #15, lsl #16
	mov	x3, #0
	bl	___divti3
	bic	x8, x0, x0, asr #63
	cmp	x8, x28
	csel	x20, x8, x28, lt
	add	x0, sp, #800
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #808]
	cbnz	w0, LBB166_119
LBB166_87:
	ldr	x27, [sp, #800]
	mov	x0, x22
	mov	x1, x21
	mov	x2, x20
	bl	_poll
	mov	x20, x0
	str	x27, [sp, #88]
	add	x0, sp, #88
	bl	l_Io.Threaded.Syscall.finish
	cmn	w20, #1
	b.ne	LBB166_93
	bl	___error
	ldr	w8, [x0]
	ldr	x27, [sp, #56]
	tbnz	w8, #31, LBB166_136
	lsr	w9, w8, #16
	cbnz	w9, LBB166_136
	cmp	w8, #4
	b.eq	LBB166_74
LBB166_91:
	cbz	w8, LBB166_95
LBB166_92:
	mov	w0, #1
	b	LBB166_119
LBB166_93:
	ldr	x27, [sp, #56]
	cbnz	w20, LBB166_95
	ldr	w8, [x27, #48]
	cmn	w8, #1
	mov	w8, #35
	csel	w0, w8, wzr, eq
	b	LBB166_119
LBB166_95:
	ldr	x1, [sp, #640]
	cmp	x1, x21
	b.lo	LBB166_135
	ldr	w23, [x27, #32]
	cbz	w21, LBB166_116
	add	x19, x22, #6
	mov	w20, #-1
	mov	w24, #88
	mov	w25, #3
	mov	w22, #-1
	b	LBB166_99
LBB166_98:
	mov	x22, x23
	mov	x23, x26
	subs	x21, x21, #1
	b.eq	LBB166_117
LBB166_99:
	cmp	x23, x20
	b.eq	LBB166_138
	ldr	x1, [x27, #8]
	cmp	x1, x23
	b.ls	LBB166_137
	ldr	x8, [x27]
	madd	x8, x23, x24, x8
	ldrb	w0, [x8, #80]
	and	w9, w0, #0x3
	cmp	w9, #1
	b.ne	LBB166_134
	ldrh	w9, [x19], #8
	ldr	w26, [x8, #72]
	cbz	w9, LBB166_98
	ldp	q0, q1, [x8, #32]
	stp	q0, q1, [sp, #848]
	ldr	x9, [x8, #64]
	str	x9, [sp, #880]
	ldp	q1, q0, [x8]
	stp	q1, q0, [sp, #816]
	sub	x8, x29, #192
	add	x1, sp, #816
	ldr	x0, [sp, #48]
	bl	l_Io.Threaded.operate
	ldurh	w0, [x29, #-152]
	cbnz	w0, LBB166_119
	cmp	x22, x20
	b.ne	LBB166_110
	str	w26, [x27, #32]
	cmn	w26, #1
	b.eq	LBB166_113
LBB166_106:
	ldr	w0, [x27, #52]
	cmn	w0, #1
	b.eq	LBB166_114
LBB166_107:
	ldr	x1, [x27, #8]
	cmp	x1, x0
	b.ls	LBB166_141
	ldr	x8, [x27]
	umaddl	x8, w0, w24, x8
	ldrb	w0, [x8, #80]
	bics	wzr, w25, w0
	b.ne	LBB166_143
	str	w23, [x8, #40]
	str	w23, [x27, #52]
	ldr	x1, [x27, #8]
	cmp	x1, x23
	b.hi	LBB166_115
	b	LBB166_137
LBB166_110:
	ldr	x1, [x27, #8]
	cmp	x1, x22
	b.ls	LBB166_147
	ldr	x8, [x27]
	madd	x8, x22, x24, x8
	ldrb	w0, [x8, #80]
	and	w9, w0, #0x3
	cmp	w9, #1
	b.ne	LBB166_134
	str	w26, [x8, #72]
	cmn	w26, #1
	b.ne	LBB166_106
LBB166_113:
	str	w22, [x27, #36]
	ldr	w0, [x27, #52]
	cmn	w0, #1
	b.ne	LBB166_107
LBB166_114:
	stp	w23, w23, [x27, #48]
	ldr	x1, [x27, #8]
	cmp	x1, x23
	b.ls	LBB166_137
LBB166_115:
	ldr	x8, [x27]
	madd	x8, x23, x24, x8
	strb	w25, [x8, #80]
	str	w20, [x8, #40]
	ldp	q0, q1, [x29, #-192]
	stp	q0, q1, [x8]
	ldur	x9, [x29, #-160]
	str	x9, [x8, #32]
	mov	x23, x26
	subs	x21, x21, #1
	b.ne	LBB166_99
	b	LBB166_117
LBB166_116:
	mov	x26, x23
LBB166_117:
	mov	w8, #-1
	cmp	x26, x8
	b.ne	LBB166_138
LBB166_118:
	mov	w0, #0
LBB166_119:
	ldur	x8, [x29, #-96]
Lloh1286:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1287:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1288:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB166_146
	add	sp, sp, #1008
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB166_121:
	.cfi_restore_state
	mov	w0, #2
	b	LBB166_119
LBB166_122:
	ldr	w21, [x27, #32]
	cmn	w21, #1
	b.eq	LBB166_138
	ldr	x1, [x27, #8]
	cmp	x1, x21
	b.ls	LBB166_135
	ldr	x8, [x27]
	mov	w9, #88
	umaddl	x19, w21, w9, x8
	ldrb	w0, [x19, #80]
	and	w8, w0, #0x3
	cmp	w8, #1
	b.ne	LBB166_134
	ldp	q0, q1, [x19, #32]
	stp	q0, q1, [sp, #704]
	ldr	x8, [x19, #64]
	str	x8, [sp, #736]
	ldp	q1, q0, [x19]
	stp	q1, q0, [sp, #672]
	add	x8, sp, #752
	add	x1, sp, #672
	ldr	x0, [sp, #48]
	bl	l_Io.Threaded.operate
	ldrh	w0, [sp, #792]
	cbnz	w0, LBB166_119
	movi.2d	v0, #0xffffffffffffffff
	str	d0, [x27, #32]
	ldr	w0, [x27, #52]
	cmn	w0, #1
	b.eq	LBB166_130
	ldr	x1, [x27, #8]
	cmp	x1, x0
	b.ls	LBB166_141
	ldr	x8, [x27]
	mov	w9, #88
	umaddl	x8, w0, w9, x8
	ldrb	w0, [x8, #80]
	mov	w9, #3
	bics	wzr, w9, w0
	b.ne	LBB166_143
	str	w21, [x8, #40]
	b	LBB166_131
LBB166_130:
	str	w21, [x27, #48]
LBB166_131:
	mov	w0, #0
	mov	w8, #3
	strb	w8, [x19, #80]
	mov	w8, #-1
	str	w8, [x19, #40]
	ldp	q0, q1, [sp, #752]
	stp	q0, q1, [x19]
	ldr	x8, [sp, #784]
	str	x8, [x19, #32]
	str	w21, [x27, #52]
	b	LBB166_119
LBB166_132:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB166_133:
	mov	x0, x28
	mov	x1, x27
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB166_134:
	mov	w1, #1
	bl	"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_244"
LBB166_135:
	mov	x0, x21
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB166_136:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB166_137:
	mov	x0, x23
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB166_138:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB166_139:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB166_140:
	mov	x0, x8
LBB166_141:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB166_142:
	mov	x0, x8
LBB166_143:
	mov	w1, #3
	bl	"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_244"
LBB166_144:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB166_145:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB166_146:
	bl	___stack_chk_fail
LBB166_147:
	mov	x0, x22
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh1279, Lloh1280, Lloh1281
	.loh AdrpAdd	Lloh1282, Lloh1283
	.loh AdrpAdd	Lloh1284, Lloh1285
	.loh AdrpLdrGotLdr	Lloh1286, Lloh1287, Lloh1288
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netSendPosix:
	.cfi_startproc
	sub	sp, sp, #272
	.cfi_def_cfa_offset 272
	stp	x28, x27, [sp, #176]
	stp	x26, x25, [sp, #192]
	stp	x24, x23, [sp, #208]
	stp	x22, x21, [sp, #224]
	stp	x20, x19, [sp, #240]
	stp	x29, x30, [sp, #256]
	add	x29, sp, #256
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x20, x3
	mov	x21, x2
	mov	x22, x1
	str	x0, [sp, #8]
	mov	x23, #0
Lloh1289:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1290:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1291:
	ldr	x8, [x8]
	str	x8, [sp, #16]
	lsl	w9, w4, #1
	stur	x8, [x29, #-96]
	and	w24, w9, #0xc
	bfxil	w24, w4, #3, #1
	tst	w5, #0x1
	mov	w8, #524288
	mov	w9, #128
	movk	w9, #8, lsl #16
	csel	w25, w9, w8, ne
	add	x12, sp, #64
	mov	w8, #40
	mov	x28, #-6148914691236517206
	add	x13, sp, #24
	mov	w14, #1
LBB167_1:
	cmp	x20, x23
	b.eq	LBB167_37
	madd	x27, x23, x8, x21
	str	w28, [sp, #88]
	stp	x28, x28, [sp, #72]
	str	x28, [sp, #64]
	ldp	x9, x8, [x27, #8]
	ldr	x10, [x27]
	stp	x9, x8, [sp, #24]
	str	x12, [sp, #96]
	ldrb	w8, [x10, #28]
	tbz	w8, #0, LBB167_4
	ldrh	w8, [x10, #8]
	rev16	w9, w8
	ldp	w8, w11, [x10]
	ldur	q0, [x10, #10]
	stur	q0, [x12, #8]
	str	w11, [sp, #88]
	mov	w10, #28
	mov	w11, #30
	b	LBB167_5
LBB167_4:
	ldur	w8, [x10, #2]
	ldrh	w9, [x10]
	rev16	w9, w9
	str	xzr, [sp, #72]
	mov	w10, #16
	mov	w11, #2
LBB167_5:
	strb	w10, [sp, #64]
	strb	w11, [sp, #65]
	strh	w9, [sp, #66]
	str	w8, [sp, #68]
	str	w10, [sp, #104]
	str	x13, [sp, #112]
	str	w14, [sp, #120]
	ldr	x8, [x27, #32]
	cbz	x8, LBB167_8
	ldr	x9, [x27, #24]
	str	x9, [sp, #128]
	lsr	x9, x8, #32
	cbnz	x9, LBB167_40
	stp	w8, wzr, [sp, #136]
	sub	x0, x29, #112
	bl	l_Io.Threaded.Syscall.start
	ldurh	w19, [x29, #-104]
	cbz	w19, LBB167_9
	b	LBB167_38
LBB167_8:
	str	xzr, [sp, #128]
	stp	w8, wzr, [sp, #136]
	sub	x0, x29, #112
	bl	l_Io.Threaded.Syscall.start
	ldurh	w19, [x29, #-104]
	cbnz	w19, LBB167_38
LBB167_9:
	ldur	x26, [x29, #-112]
LBB167_10:
	add	x1, sp, #96
	orr	w2, w25, w24
	mov	x0, x22
	bl	_sendmsg
	cmn	x0, #1
	b.ne	LBB167_15
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB167_40
	cmp	w8, #16, lsl #12
	b.hs	LBB167_40
	cmp	w8, #4
	b.ne	LBB167_19
	str	x26, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w19, w0, #0xffff
	b.eq	LBB167_10
	b	LBB167_38
LBB167_15:
	str	x26, [sp, #40]
	mov	x19, x0
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x19, #63, LBB167_40
	str	x19, [x27, #16]
	adds	x23, x23, #1
	add	x12, sp, #64
	mov	w8, #40
	add	x13, sp, #24
	mov	w14, #1
	b.hs	LBB167_18
	cmp	x20, x23
	b.hs	LBB167_1
LBB167_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB167_19:
	cmp	w8, #65
	b.hi	LBB167_33
	mov	w8, w8
Lloh1292:
	adrp	x9, LJTI167_0@PAGE
Lloh1293:
	add	x9, x9, LJTI167_0@PAGEOFF
	adr	x10, LBB167_21
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB167_21:
	mov	w19, #4
	b	LBB167_34
LBB167_22:
	mov	w19, #8
	b	LBB167_34
LBB167_23:
	mov	w19, #6
	b	LBB167_34
LBB167_24:
	mov	w19, #30
	b	LBB167_34
LBB167_25:
	mov	w19, #26
	b	LBB167_34
LBB167_26:
	mov	w19, #10
	b	LBB167_34
LBB167_27:
	mov	w19, #9
	b	LBB167_34
LBB167_28:
	mov	w19, #28
	b	LBB167_34
LBB167_29:
	mov	w19, #33
	b	LBB167_34
LBB167_30:
	mov	w19, #25
	b	LBB167_34
LBB167_31:
	mov	w19, #32
	b	LBB167_34
LBB167_32:
	mov	w19, #29
	b	LBB167_34
LBB167_33:
	mov	w19, #12
LBB167_34:
	ldr	x20, [sp, #8]
	str	x26, [sp, #56]
	add	x0, sp, #56
	bl	l_Io.Threaded.Syscall.finish
LBB167_35:
	strh	w19, [x20]
	str	x23, [x20, #8]
	ldur	x8, [x29, #-96]
Lloh1294:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1295:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1296:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB167_41
	.cfi_def_cfa wsp, 272
	ldp	x29, x30, [sp, #256]
	ldp	x20, x19, [sp, #240]
	ldp	x22, x21, [sp, #224]
	ldp	x24, x23, [sp, #208]
	ldp	x26, x25, [sp, #192]
	ldp	x28, x27, [sp, #176]
	add	sp, sp, #272
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB167_37:
	.cfi_restore_state
	mov	w19, #0
	mov	x23, x20
LBB167_38:
	ldr	x20, [sp, #8]
	b	LBB167_35
LBB167_39:
	str	x26, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
LBB167_40:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB167_41:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1289, Lloh1290, Lloh1291
	.loh AdrpAdd	Lloh1292, Lloh1293
	.loh AdrpLdrGotLdr	Lloh1294, Lloh1295, Lloh1296
	.cfi_endproc
	.section	__TEXT,__const
LJTI167_0:
	.byte	(LBB167_39-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_21-LBB167_21)>>2
	.byte	(LBB167_26-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_22-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_27-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_29-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_30-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_31-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_25-LBB167_21)>>2
	.byte	(LBB167_32-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_23-LBB167_21)>>2
	.byte	(LBB167_21-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_22-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_28-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_33-LBB167_21)>>2
	.byte	(LBB167_24-LBB167_21)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.netReceivePosix:
	.cfi_startproc
	sub	sp, sp, #272
	.cfi_def_cfa_offset 272
	stp	x28, x27, [sp, #176]
	stp	x26, x25, [sp, #192]
	stp	x24, x23, [sp, #208]
	stp	x22, x21, [sp, #224]
	stp	x20, x19, [sp, #240]
	stp	x29, x30, [sp, #256]
	add	x29, sp, #256
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
Lloh1297:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1298:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1299:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-88]
	tst	w5, #0x1
	mov	w8, #128
	csel	w24, w8, wzr, ne
	mov	x8, #-6148914691236517206
	stp	x8, x8, [sp, #48]
	str	x8, [sp, #64]
	str	w8, [sp, #72]
	stp	x2, x3, [sp, #8]
	add	x8, sp, #48
	str	x8, [sp, #80]
	mov	w8, #28
	str	w8, [sp, #88]
	add	x8, sp, #8
	str	x8, [sp, #96]
	mov	w8, #1
	str	w8, [sp, #104]
	ldp	x9, x8, [x1, #16]
	str	x9, [sp, #112]
	lsr	x9, x8, #32
	cbnz	x9, LBB168_34
	mov	x23, x4
	mov	x21, x3
	mov	x20, x2
	mov	x19, x1
	mov	x22, x0
	stp	w8, wzr, [sp, #120]
	add	x0, sp, #128
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #136]
	cbnz	w0, LBB168_31
	lsr	w8, w23, #2
	and	w25, w23, #0x3
	bfi	w25, w8, #4, #1
	ldr	x23, [sp, #128]
Lloh1300:
	adrp	x26, LJTI168_0@PAGE
Lloh1301:
	add	x26, x26, LJTI168_0@PAGEOFF
LBB168_3:
	add	x1, sp, #80
	orr	w2, w24, w25
	mov	x0, x22
	bl	_recvmsg
	cmn	x0, #1
	b.ne	LBB168_12
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB168_34
	cmp	w8, #16, lsl #12
	b.hs	LBB168_34
	cmp	w8, #60
	b.hi	LBB168_9
	adr	x9, LBB168_8
	ldrb	w10, [x26, x8]
	add	x9, x9, x10, lsl #2
	br	x9
LBB168_8:
	str	x23, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB168_3
	b	LBB168_31
LBB168_9:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #12
	b	LBB168_31
LBB168_10:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #4
	b	LBB168_31
LBB168_11:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #8
	b	LBB168_31
LBB168_12:
	str	x23, [sp, #24]
	mov	x22, x0
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x22, #63, LBB168_34
	mov	x0, x22
	cmp	x22, x21
	b.hi	LBB168_36
	ldrb	w8, [sp, #49]
	cmp	w8, #30
	b.eq	LBB168_24
	cmp	w8, #2
	b.ne	LBB168_25
	mov	w8, #0
	ldrh	w9, [sp, #50]
	ldr	w10, [sp, #52]
	rev	w9, w9
	lsr	w9, w9, #16
	orr	x9, x9, x10, lsl #16
	b	LBB168_26
LBB168_17:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #26
	b	LBB168_31
LBB168_18:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #25
	b	LBB168_31
LBB168_19:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #23
	b	LBB168_31
LBB168_20:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #9
	b	LBB168_31
LBB168_21:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #24
	b	LBB168_31
LBB168_22:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #28
	b	LBB168_31
LBB168_23:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #6
	b	LBB168_31
LBB168_24:
	ldrh	w8, [sp, #50]
	rev16	w10, w8
	ldr	w8, [sp, #52]
	ldr	w9, [sp, #72]
	orr	x9, x8, x9, lsl #32
	ldur	q0, [sp, #56]
	stur	q0, [x29, #-112]
	mov	w8, #1
	b	LBB168_27
LBB168_25:
	mov	w8, #0
	mov	x9, #8323072
	movk	x9, #256, lsl #32
LBB168_26:
LBB168_27:
	str	x9, [x19, #32]
	strh	w10, [x19, #40]
	ldur	q0, [x29, #-112]
	stur	q0, [x19, #42]
	strb	w8, [x19, #60]
	stp	x20, x0, [x19]
	ldr	x8, [sp, #112]
	cbz	x8, LBB168_29
	ldr	w9, [sp, #120]
	b	LBB168_30
LBB168_29:
	ldp	x8, x9, [x19, #16]
LBB168_30:
	mov	w0, #0
	stp	x8, x9, [x19, #16]
	ldrb	w8, [sp, #124]
	ubfx	w9, w8, #3, #3
	bfi	w9, w8, #3, #1
	strb	w9, [x19, #64]
LBB168_31:
	ldur	x8, [x29, #-88]
Lloh1302:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1303:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1304:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB168_35
	.cfi_def_cfa wsp, 272
	ldp	x29, x30, [sp, #256]
	ldp	x20, x19, [sp, #240]
	ldp	x22, x21, [sp, #224]
	ldp	x24, x23, [sp, #208]
	ldp	x26, x25, [sp, #192]
	ldp	x28, x27, [sp, #176]
	add	sp, sp, #272
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB168_33:
	.cfi_restore_state
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
LBB168_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB168_35:
	bl	___stack_chk_fail
LBB168_36:
	mov	x1, x21
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh1297, Lloh1298, Lloh1299
	.loh AdrpAdd	Lloh1300, Lloh1301
	.loh AdrpLdrGotLdr	Lloh1302, Lloh1303, Lloh1304
	.cfi_endproc
	.section	__TEXT,__const
LJTI168_0:
	.byte	(LBB168_33-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_8-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_10-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_21-LBB168_8)>>2
	.byte	(LBB168_19-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_11-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_20-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_18-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_17-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_23-LBB168_8)>>2
	.byte	(LBB168_10-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_11-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_9-LBB168_8)>>2
	.byte	(LBB168_22-LBB168_8)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.batchAwaitConcurrent__struct_243.add:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x21, x2
	mov	x22, x1
	mov	x19, x0
	ldr	w20, [x0, #40]
	cmp	w20, #64
	b.ne	LBB169_8
	ldr	x8, [x19, #16]
	ldr	x24, [x8, #16]
	cbz	x24, LBB169_13
	tst	x24, #0x3
	b.ne	LBB169_25
	ldr	x23, [x8, #8]
LBB169_4:
	cmp	x23, #63
	b.ls	LBB169_22
	ldr	x8, [x19, #32]
	cmp	x8, #64
	b.ne	LBB169_23
	ldr	x1, [x19, #24]
	add	x8, x1, #512
	add	x9, x24, #512
	cmp	x1, x9
	ccmp	x24, x8, #2, lo
	b.lo	LBB169_24
	mov	x0, x24
	mov	w2, #512
	bl	_memcpy
	stp	x24, x23, [x19, #24]
	b	LBB169_9
LBB169_8:
	ldr	x23, [x19, #32]
LBB169_9:
	cmp	x23, x20
	b.ls	LBB169_20
	ldr	x8, [x19, #24]
	add	x8, x8, x20, lsl #3
	str	w22, [x8]
	strh	w21, [x8, #4]
	adds	w8, w20, #1
	b.hs	LBB169_21
	mov	w0, #0
	str	w8, [x19, #40]
LBB169_12:
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB169_13:
	.cfi_restore_state
	ldr	x23, [x8, #8]
	lsr	x9, x23, #61
	cbz	x9, LBB169_15
LBB169_14:
	mov	w0, #1
	b	LBB169_12
LBB169_15:
	cbz	x23, LBB169_19
	ldp	x0, x8, [x19]
	xpaci	x30
	lsl	x25, x23, #3
	ldr	x8, [x8]
	mov	x1, x25
	mov	w2, #2
	mov	x3, x30
	blr	x8
	cbz	x0, LBB169_14
	mov	x24, x0
	mov	w1, #170
	mov	x2, x25
	bl	_memset
	tst	x24, #0x3
	b.ne	LBB169_25
	ldr	x8, [x19, #16]
	str	x24, [x8, #16]
	b	LBB169_4
LBB169_19:
	mov	x24, #-4
	str	x24, [x8, #16]
	b	LBB169_4
LBB169_20:
	mov	x0, x20
	mov	x1, x23
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB169_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB169_22:
	mov	w0, #64
	mov	x1, x23
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB169_23:
	bl	"l_debug.FullPanic((function 'defaultPanic')).copyLenMismatch"
LBB169_24:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB169_25:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_244":
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x0
	mov	x0, x1
	bl	"l___zig_tag_name_@typeInfo(Io.Operation.Storage).@\"union\".tag_type.?"
	mov	x20, x0
	mov	x21, x1
	mov	x0, x19
	bl	"l___zig_tag_name_@typeInfo(Io.Operation.Storage).@\"union\".tag_type.?"
	stp	x20, x21, [sp]
	stp	x0, x1, [sp, #16]
	mov	x0, sp
	bl	l_debug.panicExtra__func_257
	.cfi_endproc

	.p2align	2
"l___zig_tag_name_@typeInfo(Io.Operation.Storage).@\"union\".tag_type.?":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	and	w8, w0, #0x3
Lloh1305:
	adrp	x9, l___unnamed_1@PAGE
Lloh1306:
	add	x9, x9, l___unnamed_1@PAGEOFF
	mov	w10, #6
	cmp	w8, #2
Lloh1307:
	adrp	x11, l___unnamed_2@PAGE
Lloh1308:
	add	x11, x11, l___unnamed_2@PAGEOFF
	mov	w12, #7
Lloh1309:
	adrp	x13, l___unnamed_3@PAGE
Lloh1310:
	add	x13, x13, l___unnamed_3@PAGEOFF
	mov	w14, #10
	csel	x11, x11, x13, eq
	csel	x12, x12, x14, eq
Lloh1311:
	adrp	x13, l___unnamed_4@PAGE
Lloh1312:
	add	x13, x13, l___unnamed_4@PAGEOFF
	mov	w14, #10
	cmp	w8, #0
	csel	x9, x9, x13, eq
	csel	x10, x10, x14, eq
	cmp	w8, #1
	csel	x0, x11, x9, gt
	csel	x1, x12, x10, gt
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpAdd	Lloh1311, Lloh1312
	.loh AdrpAdd	Lloh1309, Lloh1310
	.loh AdrpAdd	Lloh1307, Lloh1308
	.loh AdrpAdd	Lloh1305, Lloh1306
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI172_0:
	.quad	4096
	.quad	0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_debug.panicExtra__func_257:
	.cfi_startproc
	stp	x28, x27, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	sub	sp, sp, #1, lsl #12
	sub	sp, sp, #48
	mov	x20, x0
	sub	x23, x29, #96
	add	x24, sp, #1
	add	x0, sp, #1
	mov	w1, #170
	mov	w2, #4111
	bl	_memset
Lloh1313:
	adrp	x8, l___anon_4078@PAGE
Lloh1314:
	add	x8, x8, l___anon_4078@PAGEOFF
	stp	x8, x24, [x23]
Lloh1315:
	adrp	x8, lCPI172_0@PAGE
Lloh1316:
	ldr	q0, [x8, lCPI172_0@PAGEOFF]
	str	q0, [x23, #16]
	ldp	x21, x22, [x20]
	ldp	x19, x20, [x20, #16]
Lloh1317:
	adrp	x1, l___anon_11143@PAGE
Lloh1318:
	add	x1, x1, l___anon_11143@PAGEOFF
	sub	x0, x29, #96
	mov	w2, #23
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB172_7
	sub	x0, x29, #96
	mov	x1, x21
	mov	x2, x22
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB172_7
Lloh1319:
	adrp	x1, l___anon_11169@PAGE
Lloh1320:
	add	x1, x1, l___anon_11169@PAGEOFF
	sub	x0, x29, #96
	mov	w2, #15
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB172_7
	sub	x0, x29, #96
	mov	x1, x19
	mov	x2, x20
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB172_7
Lloh1321:
	adrp	x1, l___anon_11189@PAGE
Lloh1322:
	add	x1, x1, l___anon_11189@PAGEOFF
	sub	x0, x29, #96
	mov	w2, #11
	bl	l_Io.Writer.writeAll
	tst	w0, #0xffff
	b.ne	LBB172_7
	ldp	x8, x1, [x23, #16]
	cmp	x1, x8
	b.ls	LBB172_11
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB172_7:
	add	x8, x24, #1, lsl #12
Lloh1323:
	adrp	x10, l___anon_3697@PAGE+15
Lloh1324:
	add	x10, x10, l___anon_3697@PAGEOFF+15
Lloh1325:
	adrp	x9, l___anon_3697@PAGE
Lloh1326:
	add	x9, x9, l___anon_3697@PAGEOFF
	cmp	x8, x10
	b.hs	LBB172_10
	mov	w10, #4111
	add	x10, x24, x10
	cmp	x10, x9
	b.ls	LBB172_10
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB172_10:
	ldr	x10, [x9]
	str	x10, [x8]
	ldur	x9, [x9, #7]
	stur	x9, [x8, #7]
	add	x0, sp, #1
	mov	w1, #4111
	bl	l_debug.defaultPanic
LBB172_11:
	ldr	x0, [x23, #8]
	bl	l_debug.defaultPanic
	.loh AdrpAdd	Lloh1317, Lloh1318
	.loh AdrpLdr	Lloh1315, Lloh1316
	.loh AdrpAdd	Lloh1313, Lloh1314
	.loh AdrpAdd	Lloh1319, Lloh1320
	.loh AdrpAdd	Lloh1321, Lloh1322
	.loh AdrpAdd	Lloh1325, Lloh1326
	.loh AdrpAdd	Lloh1323, Lloh1324
	.cfi_endproc

	.p2align	2
l_Io.Threaded.batchAwaitAsync:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	sub	sp, sp, #816
Lloh1327:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1328:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1329:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-104]
	cbz	x0, LBB173_83
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB173_84
	mov	x19, x1
	movi.16b	v0, #170
	stp	q0, q0, [sp, #496]
	stp	q0, q0, [sp, #464]
	stp	q0, q0, [sp, #432]
	stp	q0, q0, [sp, #400]
	stp	q0, q0, [sp, #368]
	stp	q0, q0, [sp, #336]
	stp	q0, q0, [sp, #304]
	stp	q0, q0, [sp, #272]
	stp	q0, q0, [sp, #240]
	stp	q0, q0, [sp, #208]
	stp	q0, q0, [sp, #176]
	stp	q0, q0, [sp, #144]
	stp	q0, q0, [sp, #112]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #48]
	stp	q0, q0, [sp, #16]
	ldr	w24, [x1, #32]
	cmn	w24, #1
	b.eq	LBB173_36
	mov	x8, #0
	sub	x23, x29, #152
	ldr	x1, [x19, #8]
	add	x9, sp, #16
	orr	x9, x9, #0x4
	mov	w10, #88
	mov	x0, x24
	b	LBB173_7
LBB173_4:
	ldr	w12, [x11, #40]
LBB173_5:
	mov	w13, #12
	stur	w12, [x9, #-4]
	strh	w13, [x9], #8
	add	x22, x8, #1
	ldr	w0, [x11, #72]
	cmn	w0, #1
	b.eq	LBB173_20
LBB173_6:
	cmp	x8, #63
	mov	x8, x22
	b.hs	LBB173_20
LBB173_7:
	cmp	x1, x0
	b.ls	LBB173_76
	ldr	x11, [x19]
	madd	x11, x0, x10, x11
	ldrb	w0, [x11, #80]
	and	w12, w0, #0x3
	cmp	w12, #1
	b.ne	LBB173_75
	ldr	w12, [x11, #16]
	ldrb	w13, [x11, #64]
	and	w13, w13, #0x7
	cmp	w13, #3
	b.gt	LBB173_12
	cmp	w13, #1
	b.gt	LBB173_14
	cbz	w13, LBB173_17
	b	LBB173_4
LBB173_12:
	cmp	w13, #5
	b.gt	LBB173_18
	cmp	w13, #4
	b.eq	LBB173_5
	b	LBB173_16
LBB173_14:
	cmp	w13, #2
	b.ne	LBB173_16
	ldr	w12, [x11, #8]
	mov	w13, #13
	stur	w12, [x9, #-4]
	strh	w13, [x9], #8
	add	x22, x8, #1
	ldr	w0, [x11, #72]
	cmn	w0, #1
	b.ne	LBB173_6
	b	LBB173_20
LBB173_16:
	ldr	w12, [x11, #32]
LBB173_17:
	mov	w13, #9
	stur	w12, [x9, #-4]
	strh	w13, [x9], #8
	add	x22, x8, #1
	ldr	w0, [x11, #72]
	cmn	w0, #1
	b.ne	LBB173_6
	b	LBB173_20
LBB173_18:
	cmp	w13, #6
	b.ne	LBB173_82
	ldr	w12, [x11, #56]
	b	LBB173_5
LBB173_20:
	subs	x25, x22, #1
	b.ne	LBB173_25
	ldr	w22, [x19, #52]
	mov	w25, #-1
	cmp	x24, x25
	b.ne	LBB173_64
LBB173_22:
	mov	x21, x22
LBB173_23:
	mov	w0, #0
	movi.2d	v0, #0xffffffffffffffff
	str	d0, [x19, #32]
	mov	x22, x21
LBB173_24:
	str	w22, [x19, #52]
	ldur	x8, [x29, #-104]
Lloh1330:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1331:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1332:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB173_62
	b	LBB173_37
LBB173_25:
	ldr	w21, [x19, #48]
	add	x0, sp, #528
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #536]
	cbnz	w0, LBB173_61
	mov	w24, #2147483647
	b	LBB173_28
LBB173_27:
	add	x0, sp, #528
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #536]
	cbnz	w0, LBB173_61
LBB173_28:
	cmn	w21, #1
	csel	w2, w24, wzr, eq
	ldr	x26, [sp, #528]
	add	x0, sp, #16
	mov	x1, x22
	bl	_poll
	mov	x21, x0
	str	x26, [sp, #8]
	add	x0, sp, #8
	bl	l_Io.Threaded.Syscall.finish
	cbz	w21, LBB173_34
	cmn	w21, #1
	b.ne	LBB173_39
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB173_80
	cmp	w8, #16, lsl #12
	b.hs	LBB173_80
	cmp	w8, #4
	b.ne	LBB173_38
	ldr	w21, [x19, #48]
	b	LBB173_27
LBB173_34:
	ldr	w8, [x19, #48]
	cmn	w8, #1
	b.ne	LBB173_36
	mov	w21, #-1
	b	LBB173_27
LBB173_36:
	mov	w0, #0
	ldur	x8, [x29, #-104]
Lloh1333:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1334:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1335:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB173_62
LBB173_37:
	bl	___stack_chk_fail
LBB173_38:
	cbnz	w8, LBB173_63
LBB173_39:
	cmp	x25, #63
	b.hi	LBB173_85
	add	x8, sp, #16
	orr	x23, x8, #0x6
	ldr	w21, [x19, #32]
	neg	x24, x22
	mov	w25, #-1
	mov	w26, #88
	mov	w22, #-1
	b	LBB173_42
LBB173_41:
	mov	x22, x21
	mov	x21, x28
	adds	x24, x24, #1
	b.hs	LBB173_59
LBB173_42:
	cmp	x21, x25
	b.eq	LBB173_78
	ldr	x1, [x19, #8]
	cmp	x1, x21
	b.ls	LBB173_77
	ldr	x8, [x19]
	madd	x27, x21, x26, x8
	ldrb	w0, [x27, #80]
	and	w8, w0, #0x3
	cmp	w8, #1
	b.ne	LBB173_75
	ldrh	w8, [x23], #8
	ldr	w28, [x27, #72]
	cbz	w8, LBB173_41
	ldp	q0, q1, [x27, #32]
	stp	q0, q1, [sp, #576]
	ldr	x8, [x27, #64]
	str	x8, [sp, #608]
	ldp	q1, q0, [x27]
	stp	q1, q0, [sp, #544]
	add	x8, sp, #624
	add	x1, sp, #544
	mov	x0, x20
	bl	l_Io.Threaded.operate
	ldrh	w0, [sp, #664]
	cbnz	w0, LBB173_61
	cmp	x22, x25
	b.ne	LBB173_54
	str	w28, [x19, #32]
	cmp	x28, x25
	b.ne	LBB173_50
LBB173_49:
	str	w22, [x19, #36]
LBB173_50:
	ldr	w0, [x19, #52]
	cmn	w0, #1
	b.eq	LBB173_57
	ldr	x1, [x19, #8]
	cmp	x1, x0
	b.ls	LBB173_76
	ldr	x8, [x19]
	umaddl	x8, w0, w26, x8
	ldrb	w0, [x8, #80]
	mov	w9, #3
	bics	wzr, w9, w0
	b.ne	LBB173_79
	str	w21, [x8, #40]
	b	LBB173_58
LBB173_54:
	ldr	x1, [x19, #8]
	cmp	x1, x22
	b.ls	LBB173_81
	ldr	x8, [x19]
	madd	x8, x22, x26, x8
	ldrb	w0, [x8, #80]
	and	w9, w0, #0x3
	cmp	w9, #1
	b.ne	LBB173_75
	str	w28, [x8, #72]
	cmp	x28, x25
	b.eq	LBB173_49
	b	LBB173_50
LBB173_57:
	str	w21, [x19, #48]
LBB173_58:
	mov	w8, #3
	strb	w8, [x27, #80]
	str	w25, [x27, #40]
	ldp	q0, q1, [sp, #624]
	stp	q0, q1, [x27]
	ldr	x8, [sp, #656]
	str	x8, [x27, #32]
	str	w21, [x19, #52]
	mov	x21, x28
	adds	x24, x24, #1
	b.lo	LBB173_42
LBB173_59:
	mov	w8, #-1
	cmp	x28, x8
	b.ne	LBB173_78
	mov	w0, #0
LBB173_61:
	ldur	x8, [x29, #-104]
Lloh1336:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1337:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1338:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB173_37
LBB173_62:
	add	sp, sp, #816
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB173_63:
	.cfi_restore_state
	ldr	w24, [x19, #32]
	ldr	w22, [x19, #52]
	mov	w25, #-1
	cmp	x24, x25
	b.eq	LBB173_22
LBB173_64:
	mov	w26, #88
	mov	w27, #3
	b	LBB173_67
LBB173_65:
	str	w21, [x19, #48]
LBB173_66:
	strb	w27, [x28, #80]
	str	w25, [x28, #40]
	ldp	q0, q1, [x23]
	stp	q0, q1, [x28]
	ldur	x8, [x29, #-120]
	str	x8, [x28, #32]
	mov	x22, x21
	cmn	w24, #1
	b.eq	LBB173_23
LBB173_67:
	mov	x21, x24
	ldr	x1, [x19, #8]
	cmp	x1, x24
	b.ls	LBB173_77
	ldr	x8, [x19]
	madd	x28, x21, x26, x8
	ldrb	w0, [x28, #80]
	and	w8, w0, #0x3
	cmp	w8, #1
	b.ne	LBB173_75
	ldr	w24, [x28, #72]
	ldp	q0, q1, [x28, #32]
	stp	q0, q1, [x29, #-192]
	ldr	x8, [x28, #64]
	stur	x8, [x29, #-160]
	ldp	q1, q0, [x28]
	stp	q1, q0, [x29, #-224]
	sub	x8, x29, #152
	sub	x1, x29, #224
	mov	x0, x20
	bl	l_Io.Threaded.operate
	ldurh	w0, [x29, #-112]
	cbnz	w0, LBB173_74
	cmp	x22, x25
	b.eq	LBB173_65
	ldr	x1, [x19, #8]
	cmp	x1, x22
	b.ls	LBB173_81
	ldr	x8, [x19]
	madd	x8, x22, x26, x8
	ldrb	w0, [x8, #80]
	bics	wzr, w27, w0
	b.ne	LBB173_79
	str	w21, [x8, #40]
	b	LBB173_66
LBB173_74:
	str	w21, [x19, #32]
	b	LBB173_24
LBB173_75:
	mov	w1, #1
	bl	"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_244"
LBB173_76:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB173_77:
	mov	x0, x21
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB173_78:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB173_79:
	mov	w1, #3
	bl	"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_244"
LBB173_80:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB173_81:
	mov	x0, x22
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB173_82:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB173_83:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB173_84:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB173_85:
	mov	x0, x22
	mov	w1, #64
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh1327, Lloh1328, Lloh1329
	.loh AdrpLdrGotLdr	Lloh1330, Lloh1331, Lloh1332
	.loh AdrpLdrGotLdr	Lloh1333, Lloh1334, Lloh1335
	.loh AdrpLdrGotLdr	Lloh1336, Lloh1337, Lloh1338
	.cfi_endproc

	.p2align	2
l_Io.Threaded.operate:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	sub	sp, sp, #512
	mov	x19, x8
Lloh1339:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1340:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1341:
	ldr	x8, [x8]
	str	x8, [sp, #16]
	stur	x8, [x29, #-72]
	cbz	x0, LBB174_179
	tst	x0, #0x7
	b.ne	LBB174_180
	ldp	x24, x23, [x1]
	ldp	x20, x6, [x1, #16]
	ldp	x21, x2, [x1, #32]
	ldrb	w8, [x1, #64]
	and	w8, w8, #0x7
	cmp	w8, #3
	b.gt	LBB174_11
	cmp	w8, #1
	b.gt	LBB174_17
	cbnz	w8, LBB174_39
	strh	wzr, [x19, #40]
	strb	wzr, [x19, #32]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #336]
	stp	q0, q0, [sp, #304]
	stp	q0, q0, [sp, #272]
	stp	q0, q0, [sp, #240]
	cbz	x23, LBB174_90
	mov	x21, #0
	add	x8, x24, #8
	add	x9, sp, #240
	b	LBB174_8
LBB174_7:
	add	x8, x8, #16
	subs	x23, x23, #1
	b.eq	LBB174_79
LBB174_8:
	cmp	x21, #8
	b.eq	LBB174_80
	ldr	x10, [x8]
	cbz	x10, LBB174_7
	ldur	x11, [x8, #-8]
	add	x12, x9, x21, lsl #4
	stp	x11, x10, [x12]
	add	x21, x21, #1
	b	LBB174_7
LBB174_11:
	cmp	w8, #5
	b.gt	LBB174_26
	cmp	w8, #4
	b.ne	LBB174_45
	strh	wzr, [x19, #40]
	strb	w8, [x19, #32]
	lsr	x4, x20, #32
	add	x0, sp, #128
	mov	x1, x20
	mov	x2, x24
	mov	x3, x23
	mov	w5, #0
	bl	l_Io.Threaded.netSendPosix
	ldrh	w8, [sp, #128]
	ldr	x20, [sp, #136]
	cbz	w8, LBB174_94
	cmp	w8, #2
	b.eq	LBB174_92
	cmp	w8, #9
	b.eq	LBB174_172
	strh	w8, [x19]
	b	LBB174_95
LBB174_17:
	cmp	w8, #2
	b.ne	LBB174_41
	strh	wzr, [x19, #40]
	strb	w8, [x19, #32]
	add	x0, sp, #240
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #248]
	cbnz	w8, LBB174_25
	ldr	x22, [sp, #240]
LBB174_20:
	str	x24, [sp]
	mov	x0, x23
	mov	x1, x20
	bl	_ioctl
	mov	x21, x0
	cmn	w0, #1
	b.ne	LBB174_59
	bl	___error
	ldr	w25, [x0]
	tbnz	w25, #31, LBB174_178
	cmp	w25, #16, lsl #12
	b.hs	LBB174_178
	cmp	w25, #4
	b.ne	LBB174_58
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB174_20
LBB174_25:
	strh	w8, [x19, #40]
	ldur	x8, [x29, #-72]
Lloh1342:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1343:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1344:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_26:
	cmp	w8, #6
	b.ne	LBB174_185
	ldr	x8, [x1, #48]
	ldr	w22, [x1, #56]
	strh	wzr, [x19, #40]
	mov	w9, #6
	strb	w9, [x19, #32]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #336]
	stp	q0, q0, [sp, #304]
	stp	q0, q0, [sp, #272]
	stp	q0, q0, [sp, #240]
	stur	xzr, [x29, #-208]
	stur	wzr, [x29, #-200]
	add	x9, sp, #240
	stur	x9, [x29, #-192]
	stur	wzr, [x29, #-184]
	cmp	x8, #0
	csel	x9, xzr, x2, eq
	lsr	x10, x8, #32
	stur	x9, [x29, #-176]
	cbnz	x10, LBB174_178
	stp	w8, wzr, [x29, #-168]
	cbz	x23, LBB174_30
	stp	x24, x23, [sp, #240]
	mov	w23, #1
	stur	w23, [x29, #-184]
LBB174_30:
	subs	x0, x6, #1
	b.lo	LBB174_173
	cmp	x0, x6
	b.hi	LBB174_182
	cbz	x0, LBB174_51
	add	x8, x20, #8
	add	x9, sp, #240
	mov	x10, x0
	mov	x11, x23
	b	LBB174_35
LBB174_34:
	add	x8, x8, #16
	subs	x10, x10, #1
	b.eq	LBB174_51
LBB174_35:
	ldr	x12, [x8]
	cbz	x12, LBB174_34
	cmp	w11, #9
	b.hs	LBB174_173
	cmp	w11, #8
	b.eq	LBB174_34
	ldur	x13, [x8, #-8]
	mov	w14, w11
	add	x14, x9, x14, lsl #4
	stp	x13, x12, [x14]
	add	w23, w11, #1
	stur	w23, [x29, #-184]
	mov	x11, x23
	b	LBB174_34
LBB174_39:
	strh	wzr, [x19, #40]
	mov	w8, #1
	strb	w8, [x19, #32]
	mov	x1, x0
	add	x0, sp, #80
	mov	x3, x24
	mov	x4, x23
	mov	x5, x20
	mov	x7, x21
	bl	l_Io.Threaded.fileWriteStreaming
	ldrh	w8, [sp, #88]
	cbnz	w8, LBB174_167
	ldr	x8, [sp, #80]
	strh	wzr, [sp, #104]
	str	x8, [sp, #96]
	add	x8, sp, #96
	b	LBB174_165
LBB174_41:
	strh	wzr, [x19, #40]
	mov	w8, #3
	strb	w8, [x19, #32]
	cbz	x23, LBB174_181
	lsr	x4, x21, #32
	mov	x0, x21
	mov	x1, x24
	mov	x2, x20
	mov	x3, x6
	mov	w5, #0
	bl	l_Io.Threaded.netReceivePosix
	ands	w8, w0, #0xffff
	b.ne	LBB174_169
	strh	wzr, [x19]
	mov	w8, #1
	str	x8, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh1345:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1346:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1347:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
LBB174_44:
	bl	___stack_chk_fail
LBB174_45:
	strh	wzr, [x19, #40]
	mov	w8, #5
	strb	w8, [x19, #32]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #336]
	stp	q0, q0, [sp, #304]
	stp	q0, q0, [sp, #272]
	stp	q0, q0, [sp, #240]
	cbz	x23, LBB174_181
	mov	x8, #0
	add	x9, x24, #8
	add	x10, sp, #240
	b	LBB174_48
LBB174_47:
	add	x9, x9, #16
	subs	x23, x23, #1
	b.eq	LBB174_60
LBB174_48:
	cmp	x8, #8
	b.eq	LBB174_61
	ldr	x11, [x9]
	cbz	x11, LBB174_47
	ldur	x12, [x9, #-8]
	add	x13, x10, x8, lsl #4
	stp	x12, x11, [x13]
	add	x8, x8, #1
	b	LBB174_47
LBB174_51:
	cmp	x0, x6
	b.hs	LBB174_182
	add	x8, x20, x0, lsl #4
	ldp	x9, x8, [x8]
	movi.16b	v0, #170
	stp	q0, q0, [x29, #-128]
	stp	q0, q0, [x29, #-160]
	cmp	w23, #8
	b.eq	LBB174_141
	cbz	x21, LBB174_141
	mov	w24, w23
	cmp	x21, #1
	b.ne	LBB174_100
	cbz	x8, LBB174_141
LBB174_56:
	add	x10, sp, #240
	add	x10, x10, x24, lsl #4
	stp	x9, x8, [x10]
	add	w23, w23, #1
LBB174_57:
	stur	w23, [x29, #-184]
	b	LBB174_141
LBB174_58:
	cbnz	w25, LBB174_78
LBB174_59:
	stur	x22, [x29, #-88]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.finish
	str	w21, [x19]
	ldur	x8, [x29, #-72]
Lloh1348:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1349:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1350:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_60:
	cbz	x8, LBB174_181
LBB174_61:
	ldr	x9, [sp, #248]
	cbz	x9, LBB174_183
	stur	xzr, [x29, #-160]
	stur	wzr, [x29, #-152]
	add	x9, sp, #240
	stur	x9, [x29, #-144]
	stur	w8, [x29, #-136]
	lsr	x8, x6, #32
	stur	x20, [x29, #-128]
	cbnz	x8, LBB174_178
	stp	w6, wzr, [x29, #-120]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-200]
	cbnz	w8, LBB174_70
	ldur	x20, [x29, #-208]
LBB174_65:
	sub	x1, x29, #160
	mov	x0, x21
	mov	w2, #0
	bl	_recvmsg
	cmn	x0, #1
	b.ne	LBB174_71
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB174_178
	cmp	w22, #16, lsl #12
	b.hs	LBB174_178
	cmp	w22, #4
	b.ne	LBB174_73
	str	x20, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB174_65
LBB174_70:
	cmp	w8, #2
	b.eq	LBB174_149
	b	LBB174_124
LBB174_71:
	ldur	w21, [x29, #-120]
	str	x20, [sp, #32]
	mov	x20, x0
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x20, #63, LBB174_178
	ldurb	w9, [x29, #-116]
	ubfx	w9, w9, #5, #1
	strh	wzr, [sp, #168]
	stp	x20, x21, [sp, #144]
	strb	w9, [sp, #160]
	add	x8, sp, #144
	b	LBB174_125
LBB174_73:
	cbz	w22, LBB174_174
	stur	x20, [x29, #-88]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	cmp	w22, #53
	b.le	LBB174_96
	cmp	w22, #56
	b.gt	LBB174_114
	cmp	w22, #54
	b.eq	LBB174_123
	cmp	w22, #55
	b.eq	LBB174_117
	b	LBB174_124
LBB174_78:
	stur	x22, [x29, #-160]
	sub	x0, x29, #160
	bl	l_Io.Threaded.Syscall.finish
	neg	w8, w25
	str	w8, [x19]
	ldur	x8, [x29, #-72]
Lloh1351:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1352:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1353:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_79:
	cbz	x21, LBB174_90
LBB174_80:
	ldr	x8, [sp, #248]
	cbz	x8, LBB174_183
	sub	x0, x29, #160
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-152]
	cbnz	w8, LBB174_89
	ldur	x22, [x29, #-160]
Lloh1354:
	adrp	x23, LJTI174_1@PAGE
Lloh1355:
	add	x23, x23, LJTI174_1@PAGEOFF
LBB174_83:
	add	x1, sp, #240
	mov	x0, x20
	mov	x2, x21
	bl	_readv
	cmn	x0, #1
	b.ne	LBB174_120
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB174_178
	cmp	w8, #16, lsl #12
	b.hs	LBB174_178
	cmp	w8, #60
	b.hi	LBB174_119
	adr	x9, LBB174_88
	ldrh	w10, [x23, x8, lsl #1]
	add	x9, x9, x10, lsl #2
	br	x9
LBB174_88:
	stur	x22, [x29, #-88]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB174_83
LBB174_89:
	cmp	w8, #2
	b.eq	LBB174_149
	b	LBB174_139
LBB174_90:
	mov	x8, #0
LBB174_91:
	strh	wzr, [sp, #56]
	str	x8, [sp, #48]
	add	x8, sp, #48
	b	LBB174_165
LBB174_92:
	cbz	x20, LBB174_149
	bl	l_Io.Threaded.recancelInner
LBB174_94:
	strh	wzr, [x19]
LBB174_95:
	str	x20, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh1356:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1357:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1358:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_96:
	cmp	w22, #12
	b.eq	LBB174_117
	cmp	w22, #32
	b.eq	LBB174_118
	cmp	w22, #50
	b.ne	LBB174_124
	mov	w8, #26
	b	LBB174_124
LBB174_100:
	cbz	x8, LBB174_141
	cmp	x8, #1
	b.ne	LBB174_126
	mov	w8, #64
	cmp	x21, #64
	csel	x20, x21, x8, lo
	ldrb	w1, [x9]
	sub	x25, x29, #160
	sub	x0, x29, #160
	mov	x2, x20
	bl	_memset
	add	x8, sp, #240
	add	x8, x8, x24, lsl #4
	stp	x25, x20, [x8]
	add	w23, w23, #1
	stur	w23, [x29, #-184]
	subs	x8, x21, x20
	b.lo	LBB174_173
	cmp	x8, #65
	b.lo	LBB174_110
	cmp	x21, #64
	b.lo	LBB174_140
	add	x9, sp, #240
	add	x9, x9, w23, uxtw #4
	orr	x9, x9, #0x8
	sub	x10, x29, #160
	mov	w11, #64
LBB174_106:
	cmp	x23, #8
	b.eq	LBB174_57
	cmp	x23, #9
	b.eq	LBB174_173
	stp	x10, x11, [x9, #-8]
	add	x23, x23, #1
	sub	x8, x8, #64
	add	x9, x9, #16
	cmp	x8, #64
	b.hi	LBB174_106
	stur	w23, [x29, #-184]
LBB174_110:
	cbz	x8, LBB174_141
	cmp	w23, #9
	b.hs	LBB174_173
	cmp	w23, #8
	b.eq	LBB174_141
	mov	w24, w23
	sub	x9, x29, #160
	b	LBB174_56
LBB174_114:
	cmp	w22, #57
	b.eq	LBB174_118
	cmp	w22, #60
	b.ne	LBB174_124
	mov	w8, #28
	b	LBB174_124
LBB174_117:
	mov	w8, #4
	b	LBB174_124
LBB174_118:
	mov	w8, #8
	b	LBB174_124
LBB174_119:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	b	LBB174_139
LBB174_120:
	str	x22, [sp, #32]
	mov	x20, x0
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cbz	x20, LBB174_138
	mov	x8, x20
	tbz	x20, #63, LBB174_91
	b	LBB174_178
LBB174_122:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #4
	b	LBB174_139
LBB174_123:
	mov	w8, #6
LBB174_124:
	strh	w8, [sp, #200]
	add	x8, sp, #176
LBB174_125:
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldur	x8, [x29, #-72]
Lloh1359:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1360:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1361:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_126:
	mov	w10, #8
	sub	x10, x10, x24
	cmp	x21, x10
	csel	x10, x21, x10, lo
	add	x11, sp, #240
	mov	x12, x23
	b	LBB174_128
LBB174_127:
	subs	x10, x10, #1
	b.eq	LBB174_57
LBB174_128:
	cmp	w12, #9
	b.hs	LBB174_173
	mov	w12, w12
	cmp	w12, #8
	b.eq	LBB174_127
	add	x13, x11, x12, lsl #4
	stp	x9, x8, [x13]
	add	w23, w12, #1
	mov	x12, x23
	b	LBB174_127
LBB174_131:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #9
	b	LBB174_139
LBB174_132:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #8
	b	LBB174_139
LBB174_133:
	str	x22, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #7
	b	LBB174_139
LBB174_134:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #6
	b	LBB174_139
LBB174_135:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #10
	b	LBB174_139
LBB174_136:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #5
	b	LBB174_139
LBB174_137:
	stur	x22, [x29, #-208]
	sub	x0, x29, #208
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #3
	b	LBB174_139
LBB174_138:
	mov	w8, #13
LBB174_139:
	strh	w8, [sp, #72]
	add	x8, sp, #64
	b	LBB174_165
LBB174_140:
	cmp	w23, #8
	b.ne	LBB174_183
LBB174_141:
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w8, [x29, #-80]
	cbnz	w8, LBB174_148
	ldur	x20, [x29, #-88]
LBB174_143:
	sub	x1, x29, #208
	mov	x0, x22
	mov	w2, #524288
	bl	_sendmsg
	cmn	x0, #1
	b.ne	LBB174_150
	bl	___error
	ldr	w21, [x0]
	tbnz	w21, #31, LBB174_178
	cmp	w21, #16, lsl #12
	b.hs	LBB174_178
	cmp	w21, #4
	b.ne	LBB174_152
	str	x20, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB174_143
LBB174_148:
	cmp	w8, #2
	b.ne	LBB174_164
LBB174_149:
Lloh1362:
	adrp	x8, l___anon_11214@PAGE
Lloh1363:
	add	x8, x8, l___anon_11214@PAGEOFF
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldr	q0, [x8, #32]
	str	q0, [x19, #32]
	ldur	x8, [x29, #-72]
Lloh1364:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1365:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1366:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_150:
	str	x20, [sp, #24]
	mov	x20, x0
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	tbnz	x20, #63, LBB174_178
	strh	wzr, [sp, #216]
	str	x20, [sp, #208]
	add	x8, sp, #208
	b	LBB174_165
LBB174_152:
	cbz	w21, LBB174_176
	str	x20, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	sub	w9, w21, #12
	cmp	w9, #53
	b.hi	LBB174_164
Lloh1367:
	adrp	x10, LJTI174_0@PAGE
Lloh1368:
	add	x10, x10, LJTI174_0@PAGEOFF
	adr	x11, LBB174_155
	ldrb	w12, [x10, x9]
	add	x11, x11, x12, lsl #2
	br	x11
LBB174_155:
	mov	w8, #4
	b	LBB174_164
LBB174_156:
	mov	w8, #8
	b	LBB174_164
LBB174_157:
	mov	w8, #28
	b	LBB174_164
LBB174_158:
	mov	w8, #29
	b	LBB174_164
LBB174_159:
	mov	w8, #30
	b	LBB174_164
LBB174_160:
	mov	w8, #6
	b	LBB174_164
LBB174_161:
	mov	w8, #32
	b	LBB174_164
LBB174_162:
	mov	w8, #26
	b	LBB174_164
LBB174_163:
	mov	w8, #33
LBB174_164:
	strh	w8, [sp, #232]
	add	x8, sp, #224
LBB174_165:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-72]
Lloh1369:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1370:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1371:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB174_44
LBB174_166:
	add	sp, sp, #512
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB174_167:
	.cfi_restore_state
	cmp	w8, #2
	b.eq	LBB174_149
	strh	w8, [sp, #120]
	add	x8, sp, #112
	b	LBB174_165
LBB174_169:
	cmp	w8, #2
	b.eq	LBB174_149
	cmp	w8, #9
	b.eq	LBB174_172
	strh	w0, [x19]
	str	xzr, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh1372:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1373:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1374:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB174_166
	b	LBB174_44
LBB174_172:
	mov	w0, #9
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB174_173:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB174_174:
	str	x20, [sp, #32]
LBB174_175:
	add	x0, sp, #32
	b	LBB174_177
LBB174_176:
	str	x20, [sp, #24]
	add	x0, sp, #24
LBB174_177:
	bl	l_Io.Threaded.Syscall.finish
LBB174_178:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB174_179:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB174_180:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB174_181:
	mov	x0, #0
	mov	x1, #0
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB174_182:
	mov	x1, x6
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB174_183:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB174_184:
	str	x22, [sp, #32]
	b	LBB174_175
LBB174_185:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh1339, Lloh1340, Lloh1341
	.loh AdrpLdrGotLdr	Lloh1342, Lloh1343, Lloh1344
	.loh AdrpLdrGotLdr	Lloh1345, Lloh1346, Lloh1347
	.loh AdrpLdrGotLdr	Lloh1348, Lloh1349, Lloh1350
	.loh AdrpLdrGotLdr	Lloh1351, Lloh1352, Lloh1353
	.loh AdrpAdd	Lloh1354, Lloh1355
	.loh AdrpLdrGotLdr	Lloh1356, Lloh1357, Lloh1358
	.loh AdrpLdrGotLdr	Lloh1359, Lloh1360, Lloh1361
	.loh AdrpLdrGotLdr	Lloh1364, Lloh1365, Lloh1366
	.loh AdrpAdd	Lloh1362, Lloh1363
	.loh AdrpAdd	Lloh1367, Lloh1368
	.loh AdrpLdrGotLdr	Lloh1369, Lloh1370, Lloh1371
	.loh AdrpLdrGotLdr	Lloh1372, Lloh1373, Lloh1374
	.cfi_endproc
	.section	__TEXT,__const
LJTI174_0:
	.byte	(LBB174_155-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_156-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_163-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_161-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_162-LBB174_155)>>2
	.byte	(LBB174_158-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_160-LBB174_155)>>2
	.byte	(LBB174_155-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_156-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_157-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_164-LBB174_155)>>2
	.byte	(LBB174_159-LBB174_155)>>2
	.p2align	1, 0x0
LJTI174_1:
	.short	(LBB174_184-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_88-LBB174_88)>>2
	.short	(LBB174_137-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_133-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_122-LBB174_88)>>2
	.short	(LBB174_135-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_136-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_131-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_134-LBB174_88)>>2
	.short	(LBB174_122-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_132-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_119-LBB174_88)>>2
	.short	(LBB174_88-LBB174_88)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.futexWake:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB175_3
	tst	x0, #0x7
	b.ne	LBB175_4
	mov	x0, x1
	mov	x1, x2
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.Thread.futexWake
LBB175_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB175_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.futexWaitUncancelable:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB176_3
	tst	x0, #0x7
	b.ne	LBB176_4
Lloh1375:
	adrp	x8, l___anon_2803@PAGE
Lloh1376:
	add	x8, x8, l___anon_2803@PAGEOFF
	mov	x0, x1
	mov	x1, x2
	mov	x2, x8
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.Thread.futexWaitUncancelable
LBB176_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB176_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpAdd	Lloh1375, Lloh1376
	.cfi_endproc

	.p2align	2
l_Io.Threaded.futexWait:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh1377:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1378:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1379:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB177_17
	tst	x0, #0x7
	b.ne	LBB177_18
	ldp	x19, x20, [x3]
	ldrb	w8, [x3, #32]
	and	w8, w8, #0x3
	cmp	w8, #1
	b.gt	LBB177_5
	cbnz	w8, LBB177_14
Lloh1380:
	adrp	x3, l___anon_2803@PAGE
Lloh1381:
	add	x3, x3, l___anon_2803@PAGEOFF
	b	LBB177_15
LBB177_5:
	cmp	w8, #2
	b.ne	LBB177_19
	ldrb	w8, [x3, #16]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB177_19
	mov	x21, x1
	mov	x22, x2
Lloh1382:
	adrp	x9, l_switch.table.Io.Threaded.futexWait@PAGE
Lloh1383:
	add	x9, x9, l_switch.table.Io.Threaded.futexWait@PAGEOFF
	and	x8, x8, #0x7
	ldr	w0, [x9, x8, lsl #2]
	mov	x8, #-6148914691236517206
	stp	x8, x8, [sp, #32]
	add	x1, sp, #32
	bl	_clock_gettime
	cmn	w0, #1
	b.ne	LBB177_11
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB177_20
	cmp	w8, #16, lsl #12
	b.hs	LBB177_20
	cbnz	w8, LBB177_12
LBB177_11:
	ldp	x8, x9, [sp, #32]
	asr	x10, x9, #63
	mov	w11, #51712
	movk	w11, #15258, lsl #16
	smulh	x12, x8, x11
	mul	x8, x8, x11
	adds	x8, x8, x9
	adc	x9, x12, x10
	b	LBB177_13
LBB177_12:
	mov	x8, #0
	mov	x9, #0
LBB177_13:
	mov	x2, x22
	mov	x1, x21
	sxtw	x10, w20
	sxtw	x9, w9
	subs	x19, x19, x8
	sbc	x20, x10, x9
	sxtw	x8, w20
	eor	x8, x8, x20
	cbnz	x8, LBB177_21
LBB177_14:
	sxtw	x8, w20
	cmp	x19, #1
	sbcs	xzr, x8, xzr
	csel	x9, xzr, x19, lt
	mov	x10, #-2
	cmp	x10, x19
	ngcs	xzr, x8
	csinv	x8, x9, xzr, ge
	str	x8, [sp, #16]
	mov	w8, #1
	strb	w8, [sp, #24]
	add	x3, sp, #16
LBB177_15:
	mov	x0, x1
	mov	x1, x2
	mov	w2, #0
	bl	l_Io.Threaded.Thread.futexWaitInner
	ldur	x8, [x29, #-40]
Lloh1384:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1385:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1386:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB177_22
	.cfi_def_cfa wsp, 144
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB177_17:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB177_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB177_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB177_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB177_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB177_22:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1377, Lloh1378, Lloh1379
	.loh AdrpAdd	Lloh1380, Lloh1381
	.loh AdrpAdd	Lloh1382, Lloh1383
	.loh AdrpLdrGotLdr	Lloh1384, Lloh1385, Lloh1386
	.cfi_endproc

	.p2align	2
l_Io.Threaded.checkCancel:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB178_3
	tst	x0, #0x7
	b.ne	LBB178_4
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.Thread.checkCancel
LBB178_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB178_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.swapCancelProtection:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB179_6
	tst	x0, #0x7
	b.ne	LBB179_7
Lloh1387:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh1388:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x9, [x0]
	cbz	x9, LBB179_4
	ldrb	w8, [x9, #552]
	and	w10, w1, #0x1
	strb	w10, [x9, #552]
	b	LBB179_5
LBB179_4:
	mov	w8, #0
LBB179_5:
	and	w0, w8, #0x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB179_6:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB179_7:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdr	Lloh1387, Lloh1388
	.cfi_endproc

	.p2align	2
l_Io.Threaded.recancel:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB180_3
	tst	x0, #0x7
	b.ne	LBB180_4
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_Io.Threaded.recancelInner
LBB180_3:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB180_4:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.groupCancel:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
Lloh1389:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1390:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1391:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB181_10
	mov	x19, x1
	mov	x1, x0
	tst	x0, #0x7
	b.ne	LBB181_11
	str	wzr, [sp, #20]
	add	x8, sp, #20
	str	x8, [x19, #8]
	mov	x8, #-4611686018427387904
	ldsetal	x8, x8, [x19]
	tbnz	x8, #62, LBB181_9
	tbnz	x8, #63, LBB181_9
	cbz	x8, LBB181_6
	add	x2, sp, #20
	mov	x0, x19
	mov	w3, #0
	bl	l_Io.Threaded.Group.waitForCancelWithSignaling
	mov	x8, #0
	b	LBB181_7
LBB181_6:
	ldr	x8, [x19]
	and	x8, x8, #0x3fffffffffffffff
LBB181_7:
	str	x8, [x19]
	ldr	x8, [sp, #24]
Lloh1392:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1393:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1394:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB181_12
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB181_9:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB181_10:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB181_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB181_12:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1389, Lloh1390, Lloh1391
	.loh AdrpLdrGotLdr	Lloh1392, Lloh1393, Lloh1394
	.cfi_endproc

	.p2align	2
l_Io.Threaded.groupAwait:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh1395:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1396:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1397:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB182_18
	tst	x0, #0x7
	b.ne	LBB182_19
	mov	x19, x1
	str	wzr, [sp, #20]
	add	x8, sp, #20
	str	x8, [x1, #8]
	mov	x8, #4611686018427387904
	ldsetal	x8, x8, [x1]
	tbnz	x8, #62, LBB182_16
	tbnz	x8, #63, LBB182_16
	cbz	x8, LBB182_9
	mov	x20, x0
Lloh1398:
	adrp	x21, l___anon_2803@PAGE
Lloh1399:
	add	x21, x21, l___anon_2803@PAGEOFF
	add	x22, sp, #20
LBB182_6:
	add	x0, sp, #20
	mov	w1, #0
	mov	w2, #0
	mov	x3, x21
	bl	l_Io.Threaded.Thread.futexWaitInner
	ands	w8, w0, #0xffff
	b.ne	LBB182_12
	ldapr	w8, [x22]
	cbz	w8, LBB182_6
	cmp	w8, #1
	b.ne	LBB182_16
LBB182_9:
	mov	w0, #0
	mov	x8, #-4611686018427387905
LBB182_10:
	ldr	x9, [x19]
	and	x8, x9, x8
	str	x8, [x19]
	ldr	x8, [sp, #24]
Lloh1400:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1401:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1402:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB182_20
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	add	sp, sp, #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB182_12:
	.cfi_restore_state
	cmp	w8, #2
	b.ne	LBB182_17
	mov	x8, #-9223372036854775808
	ldsetal	x8, x8, [x19]
	tbz	x8, #62, LBB182_16
	tbnz	x8, #63, LBB182_16
	tst	x8, #0x3fffffffffffffff
	cset	w3, eq
	add	x2, sp, #20
	mov	x0, x19
	mov	x1, x20
	bl	l_Io.Threaded.Group.waitForCancelWithSignaling
	mov	w0, #2
	mov	x8, #4611686018427387903
	b	LBB182_10
LBB182_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB182_17:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB182_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB182_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB182_20:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1395, Lloh1396, Lloh1397
	.loh AdrpAdd	Lloh1398, Lloh1399
	.loh AdrpLdrGotLdr	Lloh1400, Lloh1401, Lloh1402
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Group.waitForCancelWithSignaling:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x26, x25, [sp, #32]
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x19, x2
	mov	x20, x1
	mov	x21, x0
Lloh1403:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1404:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1405:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	tbnz	w3, #0, LBB183_4
	add	x8, x20, #576
	ldapr	x22, [x8]
	cbz	x22, LBB183_4
	mov	w24, #0
	lsr	x23, x21, #3
LBB183_3:
	add	x8, x22, #24
	ldsetl	xzr, x8, [x8]
	mov	x0, x22
	mov	x1, x23
	bl	l_Io.Threaded.Thread.cancelAwaitable
	orr	w24, w0, w24
	ldr	x22, [x22]
	cbnz	x22, LBB183_3
	b	LBB183_5
LBB183_4:
	mov	w24, #0
LBB183_5:
	mov	w22, #1024
Lloh1406:
	adrp	x23, l___anon_2803@PAGE
Lloh1407:
	add	x23, x23, l___anon_2803@PAGEOFF
	tbz	w24, #0, LBB183_15
LBB183_6:
	add	x8, x20, #576
	ldapr	x24, [x8]
	cbz	x24, LBB183_16
	mov	w25, #0
	b	LBB183_10
LBB183_8:
	ldr	x0, [x24, #16]
	mov	w1, #23
	bl	_pthread_kill
	cmp	w0, #0
	cset	w8, eq
	orr	w25, w8, w25
LBB183_9:
	ldr	x24, [x24]
	cbz	x24, LBB183_13
LBB183_10:
	ldr	x8, [x24, #24]
	eor	x9, x8, x21
	cmp	x9, #7
	b.hi	LBB183_9
	and	w8, w8, #0x7
	cmp	w8, #5
	b.eq	LBB183_8
	cmp	w8, #4
	b.ne	LBB183_9
	b	LBB183_21
LBB183_13:
	tbz	w25, #0, LBB183_15
	str	x22, [sp, #8]
	mov	w24, #1
	strb	w24, [sp, #16]
	add	x2, sp, #8
	mov	x0, x19
	mov	w1, #0
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	ldapr	w8, [x19]
	cbz	w8, LBB183_17
	b	LBB183_18
LBB183_15:
	mov	w24, #0
LBB183_16:
	mov	x2, x23
	mov	x0, x19
	mov	w1, #0
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	ldapr	w8, [x19]
	cbnz	w8, LBB183_18
LBB183_17:
	lsl	x8, x22, #1
	cmp	x22, x8, lsr #1
	csinv	x22, x8, xzr, eq
	tbnz	w24, #0, LBB183_6
	b	LBB183_15
LBB183_18:
	cmp	w8, #1
	b.ne	LBB183_21
	ldr	x8, [sp, #24]
Lloh1408:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1409:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1410:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB183_22
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	ldp	x26, x25, [sp, #32]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB183_21:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB183_22:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1403, Lloh1404, Lloh1405
	.loh AdrpAdd	Lloh1406, Lloh1407
	.loh AdrpLdrGotLdr	Lloh1408, Lloh1409, Lloh1410
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Thread.cancelAwaitable:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	and	x8, x1, #0x1fffffffffffffff
	ldr	x14, [x0, #24]
	cmp	x8, x14, lsr #3
	b.ne	LBB184_13
	lsl	x9, x8, #3
	mov	w10, #2
	bfi	x10, x8, #3, #61
	mov	w11, #4
	bfi	x11, x8, #3, #61
	mov	w12, #3
	bfi	x12, x8, #3, #61
	mov	w13, #5
	bfi	x13, x8, #3, #61
	mov	w15, #1
	bfi	x15, x8, #3, #61
	mov	w16, #6
	bfi	x16, x8, #3, #61
	b	LBB184_4
LBB184_2:
	add	x17, x0, #24
	mov	x14, x10
	cas	x14, x11, [x17]
	cmp	x14, x10
	b.eq	LBB184_11
LBB184_3:
	cmp	x8, x14, lsr #3
	b.ne	LBB184_13
LBB184_4:
	and	w14, w14, #0x7
	cmp	w14, #2
	b.lt	LBB184_8
	b.le	LBB184_2
	cmp	w14, #4
	b.ge	LBB184_12
	add	x17, x0, #24
	mov	x14, x12
	cas	x14, x13, [x17]
	cmp	x14, x12
	b.ne	LBB184_3
	b	LBB184_15
LBB184_8:
	add	x17, x0, #24
	cbnz	w14, LBB184_10
	mov	x14, x9
	cas	x14, x16, [x17]
	cmp	x14, x9
	b.ne	LBB184_3
	b	LBB184_13
LBB184_10:
	mov	x14, x15
	casa	x14, x16, [x17]
	cmp	x14, x15
	b.ne	LBB184_3
LBB184_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB184_12:
	sub	w8, w14, #6
	cmp	w8, #2
	b.hs	LBB184_16
LBB184_13:
	mov	w0, #0
LBB184_14:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB184_15:
	.cfi_restore_state
	mov	w0, #1
	b	LBB184_14
LBB184_16:
	cmp	w14, #4
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.groupConcurrent:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x28, x27, [sp, #48]
	stp	x26, x25, [sp, #64]
	stp	x24, x23, [sp, #80]
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
Lloh1411:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1412:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1413:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #40]
	cbz	x0, LBB185_41
	mov	x24, x0
	tst	x0, #0x7
	b.ne	LBB185_42
	mov	x19, x30
	mov	x7, x5
	mov	x6, x4
	mov	x5, x3
	mov	x4, x2
	mov	x25, x1
	ldr	x21, [x24, #744]
	ldr	x23, [x24, #752]
	add	x0, sp, #8
	mov	x1, x21
	mov	x2, x23
	mov	x3, x25
	bl	l_Io.Threaded.Group.Task.create
	ldrh	w8, [sp, #16]
	mov	w0, #1
	cbnz	w8, LBB185_29
	add	x20, x24, #836
	ldr	x22, [sp, #8]
	add	x9, x24, #836
	casa	w8, w0, [x9]
	cmp	w8, #0
	b.ne	LBB185_30
LBB185_4:
	ldr	x26, [x24, #568]
	ldr	x8, [x24, #560]
	cmp	x26, x8
	b.hs	LBB185_14
	add	x8, x26, #1
	str	x8, [x24, #568]
	ldr	x8, [x24, #536]
	lsr	x8, x8, #1
	cmp	x8, x26
	b.lo	LBB185_43
	b.ne	LBB185_22
	add	x8, x24, #536
	mov	w9, #2
	ldadd	x9, x8, [x8]
	cmn	x8, #2
	b.hs	LBB185_48
	ldr	x1, [x24, #528]
	add	x0, sp, #24
	mov	x2, x24
	bl	l_Thread.spawn__func_262
	ldrh	w8, [sp, #32]
	cbz	w8, LBB185_21
	add	x8, x24, #536
	mov	x9, #-2
	ldaddal	x9, x8, [x8]
	cmp	x8, #1
	b.ls	LBB185_48
	cmp	x8, #3
	b.ne	LBB185_13
	add	x8, x24, #544
	mov	w9, #2
	swpl	w9, w8, [x8]
	cbz	w8, LBB185_13
	cmp	w8, #2
	b.ne	LBB185_27
LBB185_13:
	str	x26, [x24, #568]
LBB185_14:
	add	x8, x24, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB185_48
	cmp	w8, #1
	b.eq	LBB185_18
	cmp	w8, #2
	b.ne	LBB185_26
	mov	x0, x20
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB185_18:
	ldr	x20, [x22, #32]
	cbz	x20, LBB185_20
	mov	x0, x22
	mov	w1, #170
	mov	x2, x20
	bl	_memset
	xpaci	x19
	ldr	x8, [x23, #24]
	mov	x0, x21
	mov	x1, x22
	mov	x2, x20
	mov	w3, #3
	mov	x4, x19
	blr	x8
LBB185_20:
	mov	w0, #1
	b	LBB185_38
LBB185_21:
	ldr	x0, [sp, #24]
	bl	_pthread_detach
	cbnz	w0, LBB185_46
LBB185_22:
	mov	w8, #1
	ldadd	x8, x8, [x25]
	ldr	x8, [x24]
	str	x8, [x22]
	str	x22, [x24]
	ldr	w9, [x24, #840]
	and	w8, w9, #0xffff
	cmp	w8, w9, lsr #16
	b.hi	LBB185_34
LBB185_23:
	add	x8, x24, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB185_48
	mov	w0, #0
	cmp	w8, #1
	b.eq	LBB185_38
	cmp	w8, #2
	b.eq	LBB185_37
LBB185_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB185_27:
	cmp	w8, #1
	b.ne	LBB185_26
	add	x0, x24, #544
	mov	w1, #-1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB185_13
LBB185_29:
	cmp	w8, #64
	b.eq	LBB185_38
	b	LBB185_26
LBB185_30:
	cmp	w8, #2
	b.eq	LBB185_40
	add	x8, x24, #836
	mov	w27, #2
	swpa	w27, w8, [x8]
	cbz	w8, LBB185_4
LBB185_32:
Lloh1414:
	adrp	x26, l___anon_2803@PAGE
Lloh1415:
	add	x26, x26, l___anon_2803@PAGEOFF
LBB185_33:
	add	x28, x24, #836
	add	x0, x24, #836
	mov	w1, #2
	mov	x2, x26
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	swpa	w27, w8, [x28]
	cbnz	w8, LBB185_33
	b	LBB185_4
LBB185_34:
	mov	x8, x9
LBB185_35:
	add	w10, w9, #16, lsl #12
	add	x11, x24, #840
	casl	w8, w10, [x11]
	cmp	w8, w9
	b.eq	LBB185_44
	and	w9, w8, #0xffff
	cmp	w9, w8, lsr #16
	mov	x9, x8
	b.ls	LBB185_23
	b	LBB185_35
LBB185_37:
	mov	x0, x20
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	mov	w0, #0
LBB185_38:
	ldr	x8, [sp, #40]
Lloh1416:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1417:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1418:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB185_45
	.cfi_def_cfa wsp, 144
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	ldp	x24, x23, [sp, #80]
	ldp	x26, x25, [sp, #64]
	ldp	x28, x27, [sp, #48]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB185_40:
	.cfi_restore_state
Lloh1419:
	adrp	x2, l___anon_2803@PAGE
Lloh1420:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x24, #836
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	add	x8, x24, #836
	mov	w27, #2
	swpa	w27, w8, [x8]
	cbnz	w8, LBB185_32
	b	LBB185_4
LBB185_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB185_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB185_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB185_44:
	add	x8, x24, #844
	mov	w9, #1
	ldaddl	w9, w8, [x8]
	add	x0, x20, #8
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB185_23
LBB185_45:
	bl	___stack_chk_fail
LBB185_46:
	cmp	w0, #3
	b.eq	LBB185_48
	cmp	w0, #22
LBB185_48:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh1411, Lloh1412, Lloh1413
	.loh AdrpAdd	Lloh1414, Lloh1415
	.loh AdrpLdrGotLdr	Lloh1416, Lloh1417, Lloh1418
	.loh AdrpAdd	Lloh1419, Lloh1420
	.cfi_endproc

	.p2align	2
l_Io.Threaded.groupAsync:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
Lloh1421:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1422:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1423:
	ldr	x8, [x8]
	str	x8, [sp, #16]
	str	x8, [sp, #56]
	cbz	x0, LBB186_41
	mov	x22, x0
	tst	x0, #0x7
	b.ne	LBB186_42
	mov	x20, x30
	mov	x7, x5
	mov	x6, x4
	mov	x5, x3
	mov	x19, x2
	mov	x26, x1
	ldr	x23, [x22, #744]
	ldr	x25, [x22, #752]
	add	x0, sp, #24
	mov	x1, x23
	mov	x2, x25
	mov	x3, x26
	mov	x4, x19
	str	x7, [sp, #8]
	bl	l_Io.Threaded.Group.Task.create
	ldrh	w8, [sp, #32]
	cbnz	w8, LBB186_29
	add	x21, x22, #836
	ldr	x24, [sp, #24]
	add	x9, x22, #836
	mov	w10, #1
	casa	w8, w10, [x9]
	cmp	w8, #0
	b.ne	LBB186_30
LBB186_4:
	ldr	x27, [x22, #568]
	ldr	x8, [x22, #552]
	cmp	x27, x8
	b.hs	LBB186_14
	add	x8, x27, #1
	str	x8, [x22, #568]
	ldr	x8, [x22, #536]
	lsr	x8, x8, #1
	cmp	x8, x27
	b.lo	LBB186_43
	b.ne	LBB186_23
	add	x8, x22, #536
	mov	w9, #2
	ldadd	x9, x8, [x8]
	cmn	x8, #2
	b.hs	LBB186_46
	ldr	x1, [x22, #528]
	add	x0, sp, #40
	mov	x2, x22
	bl	l_Thread.spawn__func_262
	ldrh	w8, [sp, #48]
	cbz	w8, LBB186_22
	add	x8, x22, #536
	mov	x9, #-2
	ldaddal	x9, x8, [x8]
	cmp	x8, #1
	b.ls	LBB186_46
	cmp	x8, #3
	b.ne	LBB186_13
	add	x8, x22, #544
	mov	w9, #2
	swpl	w9, w8, [x8]
	cbz	w8, LBB186_13
	cmp	w8, #2
	b.ne	LBB186_27
LBB186_13:
	str	x27, [x22, #568]
LBB186_14:
	add	x8, x22, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB186_46
	cmp	w8, #1
	b.eq	LBB186_18
	cmp	w8, #2
	b.ne	LBB186_26
	mov	x0, x21
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB186_18:
	ldr	x21, [x24, #32]
	cbz	x21, LBB186_20
	mov	x0, x24
	mov	w1, #170
	mov	x2, x21
	bl	_memset
	xpaci	x20
	ldr	x8, [x25, #24]
	mov	x0, x23
	mov	x1, x24
	mov	x2, x21
	mov	w3, #3
	mov	x4, x20
	blr	x8
LBB186_20:
	ldr	x8, [sp, #56]
Lloh1424:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1425:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1426:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB186_49
	mov	x0, x19
	ldr	x1, [sp, #8]
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	br	x1
LBB186_22:
	.cfi_restore_state
	.cfi_remember_state
	ldr	x0, [sp, #40]
	bl	_pthread_detach
	cbnz	w0, LBB186_44
LBB186_23:
	mov	w8, #1
	ldadd	x8, x8, [x26]
	ldr	x8, [x22]
	str	x8, [x24]
	str	x24, [x22]
	add	x8, x22, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB186_46
	cmp	w8, #1
	b.eq	LBB186_34
	cmp	w8, #2
	b.eq	LBB186_33
LBB186_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB186_27:
	cmp	w8, #1
	b.ne	LBB186_26
	add	x0, x22, #544
	mov	w1, #-1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB186_13
LBB186_29:
	cmp	w8, #64
	b.eq	LBB186_20
	b	LBB186_26
LBB186_30:
	cmp	w8, #2
	b.eq	LBB186_40
	add	x8, x22, #836
	mov	w28, #2
	swpa	w28, w8, [x8]
	cbz	w8, LBB186_4
LBB186_32:
	add	x27, x22, #836
	add	x0, x22, #836
	mov	w1, #2
Lloh1427:
	adrp	x2, l___anon_2803@PAGE
Lloh1428:
	add	x2, x2, l___anon_2803@PAGEOFF
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	swpa	w28, w8, [x27]
	cbnz	w8, LBB186_32
	b	LBB186_4
LBB186_33:
	add	x0, x22, #836
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB186_34:
	ldr	w9, [x22, #840]
	and	w8, w9, #0xffff
	cmp	w8, w9, lsr #16
	b.hi	LBB186_37
LBB186_35:
	ldr	x8, [sp, #56]
Lloh1429:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1430:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1431:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB186_49
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB186_37:
	.cfi_restore_state
	.cfi_remember_state
	mov	x8, x9
LBB186_38:
	add	w10, w9, #16, lsl #12
	add	x11, x22, #840
	casl	w8, w10, [x11]
	cmp	w8, w9
	b.eq	LBB186_47
	and	w9, w8, #0xffff
	cmp	w9, w8, lsr #16
	mov	x9, x8
	b.ls	LBB186_35
	b	LBB186_38
LBB186_40:
Lloh1432:
	adrp	x2, l___anon_2803@PAGE
Lloh1433:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x22, #836
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	add	x8, x22, #836
	mov	w28, #2
	swpa	w28, w8, [x8]
	cbnz	w8, LBB186_32
	b	LBB186_4
LBB186_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB186_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB186_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB186_44:
	cmp	w0, #3
	b.eq	LBB186_46
	cmp	w0, #22
LBB186_46:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB186_47:
	add	x8, x22, #844
	mov	w9, #1
	ldaddl	w9, w8, [x8]
	ldr	x8, [sp, #56]
Lloh1434:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1435:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1436:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB186_49
	add	x0, x21, #8
	mov	w1, #1
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	b	l_Io.Threaded.Thread.futexWake
LBB186_49:
	.cfi_restore_state
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1421, Lloh1422, Lloh1423
	.loh AdrpLdrGotLdr	Lloh1424, Lloh1425, Lloh1426
	.loh AdrpAdd	Lloh1427, Lloh1428
	.loh AdrpLdrGotLdr	Lloh1429, Lloh1430, Lloh1431
	.loh AdrpAdd	Lloh1432, Lloh1433
	.loh AdrpLdrGotLdr	Lloh1434, Lloh1435, Lloh1436
	.cfi_endproc

	.p2align	2
l_Thread.spawn__func_262:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x22, x2
	mov	x21, x1
	mov	x19, x0
Lloh1437:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1438:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1439:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-40]
	mov	w0, #8
	bl	_malloc
	cbz	x0, LBB187_5
	mov	x20, x0
	tst	x0, #0x7
	b.ne	LBB187_20
	str	x22, [x20]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #16]
	stp	q0, q0, [sp, #48]
	add	x0, sp, #16
	bl	_pthread_attr_init
	cbz	w0, LBB187_8
LBB187_3:
	mov	w21, #4
LBB187_4:
	mov	x0, x20
	bl	_free
	b	LBB187_6
LBB187_5:
	mov	w21, #64
LBB187_6:
	strh	w21, [x19, #8]
	ldur	x8, [x29, #-40]
Lloh1440:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1441:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1442:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB187_21
	.cfi_def_cfa wsp, 144
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB187_8:
	.cfi_restore_state
	mov	w8, #16384
	cmp	x21, #4, lsl #12
	csel	x1, x21, x8, hi
	add	x0, sp, #16
	bl	_pthread_attr_setstacksize
	cbnz	w0, LBB187_20
	add	x0, sp, #16
	mov	w1, #16384
	bl	_pthread_attr_setguardsize
	cbnz	w0, LBB187_20
	mov	x8, #-6148914691236517206
	str	x8, [sp, #8]
Lloh1443:
	adrp	x2, l_Thread.PosixThreadImpl.spawn__func_263.Instance.entryFn@PAGE
Lloh1444:
	add	x2, x2, l_Thread.PosixThreadImpl.spawn__func_263.Instance.entryFn@PAGEOFF
	add	x0, sp, #8
	add	x1, sp, #16
	mov	x3, x20
	bl	_pthread_create
	cmp	w0, #21
	b.gt	LBB187_14
	cbnz	w0, LBB187_16
	ldr	x20, [sp, #8]
	add	x0, sp, #16
	bl	_pthread_attr_destroy
	cbnz	w0, LBB187_20
	mov	w21, #0
	str	x20, [x19]
	b	LBB187_6
LBB187_14:
	cmp	w0, #35
	b.ne	LBB187_17
	add	x0, sp, #16
	bl	_pthread_attr_destroy
	cbz	w0, LBB187_3
	b	LBB187_20
LBB187_16:
	cmp	w0, #1
	b.ne	LBB187_18
	b	LBB187_20
LBB187_17:
	cmp	w0, #22
	b.eq	LBB187_20
LBB187_18:
	add	x0, sp, #16
	bl	_pthread_attr_destroy
	cbnz	w0, LBB187_20
	mov	w21, #12
	b	LBB187_4
LBB187_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB187_21:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1437, Lloh1438, Lloh1439
	.loh AdrpLdrGotLdr	Lloh1440, Lloh1441, Lloh1442
	.loh AdrpAdd	Lloh1443, Lloh1444
	.cfi_endproc

	.p2align	2
l_Thread.PosixThreadImpl.spawn__func_263.Instance.entryFn:
	.cfi_startproc
	stp	x28, x27, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
	sub	sp, sp, #592
Lloh1445:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1446:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1447:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-72]
	cbz	x0, LBB188_49
	mov	x19, x0
	tst	x0, #0x7
	b.ne	LBB188_50
	ldr	x20, [x19]
Lloh1448:
	adrp	x0, l_Thread.maybeAttachSignalStack.global.signal_stack@TLVPPAGE
Lloh1449:
	ldr	x0, [x0, l_Thread.maybeAttachSignalStack.global.signal_stack@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	mov	w8, #262144
	stp	x0, x8, [sp, #24]
	str	wzr, [sp, #40]
	add	x0, sp, #24
	mov	x1, #0
	bl	_sigaltstack
	cmn	w0, #1
	b.ne	LBB188_6
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB188_54
	cmp	w8, #16, lsl #12
	b.hs	LBB188_54
	cbnz	w8, LBB188_45
LBB188_6:
	mov	x8, #-6148914691236517206
	stp	x8, x8, [sp, #16]
	add	x1, sp, #16
	mov	x0, #0
	bl	_pthread_threadid_np
	cbnz	w0, LBB188_53
	ldr	x8, [sp, #16]
	str	x8, [sp, #32]
	bl	_pthread_self
	stp	x0, xzr, [sp, #40]
	strb	wzr, [sp, #576]
	add	x21, sp, #24
	add	x0, x21, #32
	mov	w1, #255
	mov	w2, #520
	bl	_memset
Lloh1450:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh1451:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	str	x21, [x0]
	add	x9, x20, #576
	ldr	x10, [x20, #576]
	str	x10, [sp, #24]
	mov	x8, x10
	casl	x8, x21, [x9]
	cmp	x8, x10
	b.eq	LBB188_10
	mov	x9, x8
LBB188_9:
	str	x8, [sp, #24]
	add	x10, x20, #576
	casl	x9, x21, [x10]
	cmp	x9, x8
	mov	x8, x9
	b.ne	LBB188_9
LBB188_10:
	mov	w8, #0
	add	x9, x20, #836
	mov	w22, #1
	casa	w8, w22, [x9]
	cmp	w8, #0
	b.ne	LBB188_31
LBB188_11:
Lloh1452:
	adrp	x21, l___anon_2803@PAGE
Lloh1453:
	add	x21, x21, l___anon_2803@PAGEOFF
	mov	w23, #2
LBB188_12:
	ldr	x0, [x20]
	cbz	x0, LBB188_20
	ldr	x8, [x0]
	str	x8, [x20]
	add	x8, x20, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB188_53
	cmp	w8, #1
	b.eq	LBB188_17
	cmp	w8, #2
	b.ne	LBB188_30
	mov	x24, x0
	add	x0, x20, #836
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	mov	x0, x24
LBB188_17:
	strb	wzr, [sp, #576]
	ldr	x8, [x0, #8]
	add	x1, sp, #24
	mov	x2, x20
	blr	x8
	mov	w8, #0
	add	x9, x20, #836
	casa	w8, w22, [x9]
	cmp	w8, #0
	b.ne	LBB188_22
LBB188_18:
	ldr	x8, [x20, #568]
	subs	x8, x8, #1
	b.lo	LBB188_55
	str	x8, [x20, #568]
	b	LBB188_12
LBB188_20:
	ldrb	w8, [x20, #861]
	tbnz	w8, #0, LBB188_27
	add	x0, x20, #840
	add	x1, x20, #836
	bl	l_Io.Threaded.condWait
	b	LBB188_12
LBB188_22:
	cmp	w8, #2
	b.eq	LBB188_24
	add	x24, x20, #836
	b	LBB188_26
LBB188_24:
	add	x0, x20, #836
	mov	w1, #2
	mov	x2, x21
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	add	x24, x20, #836
	b	LBB188_26
LBB188_25:
	add	x0, x20, #836
	mov	w1, #2
	mov	x2, x21
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
LBB188_26:
	swpa	w23, w8, [x24]
	cbnz	w8, LBB188_25
	b	LBB188_18
LBB188_27:
	add	x8, x20, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB188_53
	cmp	w8, #1
	b.eq	LBB188_36
	cmp	w8, #2
	b.eq	LBB188_35
LBB188_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB188_31:
	cmp	w8, #2
	b.eq	LBB188_44
	add	x8, x20, #836
	mov	w23, #2
	swpa	w23, w8, [x8]
	cbz	w8, LBB188_11
LBB188_33:
Lloh1454:
	adrp	x21, l___anon_2803@PAGE
Lloh1455:
	add	x21, x21, l___anon_2803@PAGEOFF
LBB188_34:
	add	x24, x20, #836
	add	x0, x20, #836
	mov	w1, #2
	mov	x2, x21
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	swpa	w23, w8, [x24]
	cbnz	w8, LBB188_34
	b	LBB188_11
LBB188_35:
	add	x0, x20, #836
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB188_36:
	add	x8, x20, #536
	mov	x9, #-2
	ldaddal	x9, x8, [x8]
	cmp	x8, #1
	b.ls	LBB188_53
	cmp	x8, #3
	b.ne	LBB188_40
	add	x8, x20, #544
	mov	w9, #2
	swpl	w9, w8, [x8]
	cbz	w8, LBB188_40
	cmp	w8, #2
	b.ne	LBB188_42
LBB188_40:
	mov	x0, x19
	bl	_free
	ldur	x8, [x29, #-72]
Lloh1456:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1457:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1458:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB188_58
	mov	x0, #0
	add	sp, sp, #592
	.cfi_def_cfa wsp, 80
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x28, x27, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB188_42:
	.cfi_restore_state
	cmp	w8, #1
	b.ne	LBB188_30
	add	x0, x20, #544
	mov	w1, #-1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB188_40
LBB188_44:
Lloh1459:
	adrp	x2, l___anon_2803@PAGE
Lloh1460:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x20, #836
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	add	x8, x20, #836
	mov	w23, #2
	swpa	w23, w8, [x8]
	cbnz	w8, LBB188_33
	b	LBB188_11
LBB188_45:
	cmp	w8, #13
	b.gt	LBB188_51
	cmp	w8, #1
	b.eq	LBB188_57
	cmp	w8, #12
	b.ne	LBB188_56
	mov	w0, #110
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB188_49:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB188_50:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB188_51:
	cmp	w8, #22
	b.eq	LBB188_53
	cmp	w8, #14
	b.ne	LBB188_56
LBB188_53:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB188_54:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB188_55:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB188_56:
	mov	w0, #12
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB188_57:
	mov	w0, #18
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapError"
LBB188_58:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1445, Lloh1446, Lloh1447
	.loh AdrpLdr	Lloh1448, Lloh1449
	.loh AdrpLdr	Lloh1450, Lloh1451
	.loh AdrpAdd	Lloh1452, Lloh1453
	.loh AdrpAdd	Lloh1454, Lloh1455
	.loh AdrpLdrGotLdr	Lloh1456, Lloh1457, Lloh1458
	.loh AdrpAdd	Lloh1459, Lloh1460
	.cfi_endproc

	.p2align	2
l_Io.Threaded.condWait:
	.cfi_startproc
	stp	x22, x21, [sp, #-48]!
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x8, x1
	ldapur	w1, [x0, #4]
	mov	w9, #1
	ldadd	w9, w9, [x0]
	mov	w10, #65535
	bics	wzr, w10, w9
	b.eq	LBB189_5
	swpl	wzr, w9, [x8]
	cbz	w9, LBB189_5
	mov	x19, x0
	cmp	w9, #1
	b.eq	LBB189_6
	cmp	w9, #2
	b.eq	LBB189_15
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB189_5:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB189_6:
	mov	x20, x8
LBB189_7:
Lloh1461:
	adrp	x2, l___anon_2803@PAGE
Lloh1462:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x19, #4
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	ldapur	w1, [x19, #4]
	ldr	w8, [x19]
	cmp	w8, #16, lsl #12
	b.lo	LBB189_7
	mov	x0, x20
LBB189_9:
	and	w9, w8, #0xffff
	sub	w9, w9, #1
	and	w10, w9, #0xffff
	cmp	w10, w9
	b.ne	LBB189_20
	mov	x10, x8
	bfxil	w10, w9, #0, #16
	sub	w10, w10, #16, lsl #12
	mov	x9, x8
	casa	w9, w10, [x19]
	cmp	w9, w8
	b.eq	LBB189_13
	mov	x8, x9
	cmp	w9, #16, lsl #12
	b.hs	LBB189_9
	mov	x20, x0
	b	LBB189_7
LBB189_13:
	mov	w8, #0
	mov	w9, #1
	casa	w8, w9, [x0]
	cmp	w8, #0
	b.ne	LBB189_16
LBB189_14:
	.cfi_def_cfa wsp, 48
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	ldp	x22, x21, [sp], #48
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB189_15:
	.cfi_restore_state
	mov	x20, x8
	mov	x0, x8
	mov	x21, x1
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	mov	x1, x21
	b	LBB189_7
LBB189_16:
	cmp	w8, #2
	b.eq	LBB189_21
	mov	w20, #2
	swpa	w20, w8, [x0]
	cbz	w8, LBB189_14
LBB189_18:
Lloh1463:
	adrp	x19, l___anon_2803@PAGE
Lloh1464:
	add	x19, x19, l___anon_2803@PAGEOFF
LBB189_19:
	mov	x21, x0
	mov	w1, #2
	mov	x2, x19
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x0, x21
	swpa	w20, w8, [x21]
	cbnz	w8, LBB189_19
	b	LBB189_14
LBB189_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB189_21:
Lloh1465:
	adrp	x2, l___anon_2803@PAGE
Lloh1466:
	add	x2, x2, l___anon_2803@PAGEOFF
	mov	x19, x0
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	x0, x19
	mov	w20, #2
	swpa	w20, w8, [x19]
	cbnz	w8, LBB189_18
	b	LBB189_14
	.loh AdrpAdd	Lloh1461, Lloh1462
	.loh AdrpAdd	Lloh1463, Lloh1464
	.loh AdrpAdd	Lloh1465, Lloh1466
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Group.Task.create:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x23, x6
	mov	w8, #1
	lsl	x8, x8, x6
	subs	x8, x8, #8
	csel	x8, xzr, x8, lo
	add	x8, x8, #48
	mov	x9, #-1
	lsl	x27, x9, x6
	mvn	x28, x27
	adds	x8, x8, x28
	b.hs	LBB190_15
	mov	x20, x5
	and	x8, x8, x27
	adds	x26, x8, x5
	b.hs	LBB190_15
	mov	x22, x7
	mov	x21, x4
	mov	x24, x3
	mov	x19, x0
	cbz	x26, LBB190_6
	xpaci	x30
	ldr	x8, [x2]
	mov	x0, x1
	mov	x1, x26
	mov	w2, #3
	mov	x3, x30
	blr	x8
	cbz	x0, LBB190_13
	mov	x25, x0
	mov	w1, #170
	mov	x2, x26
	bl	_memset
	tst	x25, #0x7
	b.eq	LBB190_7
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB190_6:
	mov	x25, #-8
LBB190_7:
	mov	x8, #-6148914691236517206
Lloh1467:
	adrp	x9, l_Io.Threaded.Group.Task.start@PAGE
Lloh1468:
	add	x9, x9, l_Io.Threaded.Group.Task.start@PAGEOFF
	stp	x8, x9, [x25]
	and	w8, w23, #0x3f
	stp	x24, x22, [x25, #16]
	strb	w8, [x25, #40]
	str	x26, [x25, #32]
	adds	x8, x25, #48
	b.hs	LBB190_15
	adds	x8, x8, x28
	b.hs	LBB190_15
	and	x8, x8, x27
	subs	x8, x8, x25
	b.lo	LBB190_15
	add	x0, x25, x8
	add	x8, x21, x20
	cmp	x0, x8
	b.hs	LBB190_12
	add	x8, x0, x20
	cmp	x21, x8
	b.lo	LBB190_16
LBB190_12:
	mov	x1, x21
	mov	x2, x20
	bl	_memcpy
	mov	w8, #0
	str	x25, [x19]
	b	LBB190_14
LBB190_13:
	mov	w8, #64
LBB190_14:
	strh	w8, [x19, #8]
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB190_15:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB190_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpAdd	Lloh1467, Lloh1468
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Group.Task.start:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x30
	mov	x21, x2
	mov	x22, x1
	mov	x20, x0
	ldr	x23, [x0, #16]
	add	x8, x1, #24
	swpa	x23, x8, [x8]
	ldr	x8, [x23]
	tbz	x8, #63, LBB191_2
	orr	x8, x23, #0x6
	str	x8, [x22, #24]
LBB191_2:
	adds	x8, x20, #48
	b.hs	LBB191_11
	ldrb	w9, [x20, #40]
	mov	x10, #-1
	lsl	x9, x10, x9
	mvn	x10, x9
	adds	x8, x8, x10
	b.hs	LBB191_11
	and	x8, x8, x9
	subs	x8, x8, x20
	b.lo	LBB191_11
	ldr	x9, [x20, #24]
	add	x0, x20, x8
	blr	x9
	str	xzr, [x22, #24]
	mov	x8, #-1
	ldaddal	x8, x8, [x23]
	tst	x8, #0x3fffffffffffffff
	b.eq	LBB191_12
	mov	x9, #2
	movk	x9, #32768, lsl #48
	cmp	x9, x8, lsl #1
	b.eq	LBB191_9
	ldr	x22, [x20, #32]
	cbz	x22, LBB191_10
LBB191_8:
	ldr	x23, [x21, #752]
	ldr	x21, [x21, #744]
	mov	x0, x20
	mov	w1, #170
	mov	x2, x22
	bl	_memset
	xpaci	x19
	ldr	x5, [x23, #24]
	mov	x0, x21
	mov	x1, x20
	mov	x2, x22
	mov	w3, #3
	mov	x4, x19
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	br	x5
LBB191_9:
	.cfi_restore_state
	.cfi_remember_state
	ldr	x0, [x23, #8]
	mov	x8, #-6148914691236517206
	str	x8, [x23, #8]
	mov	w8, #1
	ldaddl	w8, w8, [x0]
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	ldr	x22, [x20, #32]
	cbnz	x22, LBB191_8
LBB191_10:
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB191_11:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB191_12:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.cancel:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
Lloh1469:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1470:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1471:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB192_14
	mov	x21, x0
	tst	x0, #0x7
	b.ne	LBB192_12
	mov	x20, x1
	tst	x1, #0x7
	b.ne	LBB192_12
	mov	x19, x30
	str	wzr, [sp, #20]
	add	x8, sp, #20
	str	x8, [x20, #32]
	add	x8, x20, #24
	mov	w9, #3
	ldsetal	x9, x8, [x8]
	and	w9, w8, #0x3
	cmp	w9, #2
	b.ne	LBB192_9
LBB192_4:
	ldr	x8, [x20, #40]
	add	x1, x20, x8
	add	x8, x1, x3
	add	x9, x2, x3
	cmp	x1, x9
	ccmp	x2, x8, #2, lo
	b.lo	LBB192_15
	mov	x0, x2
	mov	x2, x3
	bl	_memcpy
	ldr	x22, [x20, #48]
	cbz	x22, LBB192_7
	ldr	x23, [x21, #752]
	ldr	x21, [x21, #744]
	mov	x0, x20
	mov	w1, #170
	mov	x2, x22
	bl	_memset
	xpaci	x19
	ldr	x8, [x23, #24]
	mov	x0, x21
	mov	x1, x20
	mov	x2, x22
	mov	w3, #3
	mov	x4, x19
	blr	x8
LBB192_7:
	ldr	x8, [sp, #24]
Lloh1472:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1473:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1474:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB192_16
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB192_9:
	.cfi_restore_state
	cbnz	w9, LBB192_13
	tbnz	w8, #2, LBB192_12
	mov	x22, x2
	mov	x23, x3
	add	x1, sp, #20
	and	x2, x8, #0xfffffffffffffff8
	mov	x0, x20
	bl	l_Io.Threaded.Future.waitForCancelWithSignaling
	mov	x3, x23
	mov	x2, x22
	b	LBB192_4
LBB192_12:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB192_13:
	cmp	w9, #1
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB192_14:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB192_15:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB192_16:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1469, Lloh1470, Lloh1471
	.loh AdrpLdrGotLdr	Lloh1472, Lloh1473, Lloh1474
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Future.waitForCancelWithSignaling:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x1
Lloh1475:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1476:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1477:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	cbz	x2, LBB193_9
	mov	x20, x2
	mov	x21, x0
	lsr	x1, x0, #3
	mov	x0, x2
	bl	l_Io.Threaded.Thread.cancelAwaitable
	mov	x22, x0
	mov	w23, #1024
Lloh1478:
	adrp	x24, l___anon_2803@PAGE
Lloh1479:
	add	x24, x24, l___anon_2803@PAGEOFF
	tbz	w22, #0, LBB193_7
LBB193_2:
	ldr	x8, [x20, #24]
	eor	x9, x8, x21
	cmp	x9, #7
	b.hi	LBB193_7
	and	w8, w8, #0x7
	cmp	w8, #5
	b.eq	LBB193_5
	cmp	w8, #4
	b.ne	LBB193_7
	b	LBB193_14
LBB193_5:
	ldr	x0, [x20, #16]
	mov	w1, #23
	bl	_pthread_kill
	cbnz	w0, LBB193_7
	str	x23, [sp, #8]
	mov	w22, #1
	strb	w22, [sp, #16]
	add	x2, sp, #8
	mov	x0, x19
	mov	w1, #0
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	ldapr	w8, [x19]
	cbz	w8, LBB193_8
	b	LBB193_11
LBB193_7:
	mov	w22, #0
	mov	x2, x24
	mov	x0, x19
	mov	w1, #0
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	ldapr	w8, [x19]
	cbnz	w8, LBB193_11
LBB193_8:
	lsl	x8, x23, #1
	cmp	x23, x8, lsr #1
	csinv	x23, x8, xzr, eq
	tbnz	w22, #0, LBB193_2
	b	LBB193_7
LBB193_9:
Lloh1480:
	adrp	x20, l___anon_2803@PAGE
Lloh1481:
	add	x20, x20, l___anon_2803@PAGEOFF
LBB193_10:
	mov	x0, x19
	mov	w1, #0
	mov	x2, x20
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	ldapr	w8, [x19]
	cbz	w8, LBB193_10
LBB193_11:
	cmp	w8, #1
	b.ne	LBB193_14
	ldr	x8, [sp, #24]
Lloh1482:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1483:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1484:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB193_15
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB193_14:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB193_15:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1475, Lloh1476, Lloh1477
	.loh AdrpAdd	Lloh1478, Lloh1479
	.loh AdrpAdd	Lloh1480, Lloh1481
	.loh AdrpLdrGotLdr	Lloh1482, Lloh1483, Lloh1484
	.cfi_endproc

	.p2align	2
l_Io.Threaded.await:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x26, x25, [sp, #32]
	stp	x24, x23, [sp, #48]
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
Lloh1485:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1486:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1487:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	cbz	x0, LBB194_29
	mov	x21, x0
	tst	x0, #0x7
	b.ne	LBB194_27
	mov	x20, x1
	tst	x1, #0x7
	b.ne	LBB194_27
	mov	x19, x30
	mov	x22, x3
	mov	x23, x2
	str	wzr, [sp, #20]
	add	x8, sp, #20
	str	x8, [x20, #32]
	add	x8, x20, #24
	mov	w9, #1
	ldsetal	x9, x8, [x8]
	and	w8, w8, #0x3
	cmp	w8, #1
	b.gt	LBB194_10
	cbnz	w8, LBB194_9
Lloh1488:
	adrp	x24, l___anon_2803@PAGE
Lloh1489:
	add	x24, x24, l___anon_2803@PAGEOFF
	add	x25, sp, #20
LBB194_6:
	add	x0, sp, #20
	mov	w1, #0
	mov	w2, #0
	mov	x3, x24
	bl	l_Io.Threaded.Thread.futexWaitInner
	ands	w8, w0, #0xffff
	b.ne	LBB194_16
	ldapr	w8, [x25]
	cbz	w8, LBB194_6
	cmp	w8, #1
	b.eq	LBB194_11
LBB194_9:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB194_10:
	cmp	w8, #2
	b.ne	LBB194_9
LBB194_11:
	ldr	x8, [x20, #40]
	add	x1, x20, x8
	add	x8, x1, x22
	add	x9, x23, x22
	cmp	x1, x9
	ccmp	x23, x8, #2, lo
	b.lo	LBB194_30
	mov	x0, x23
	mov	x2, x22
	bl	_memcpy
	ldr	x22, [x20, #48]
	cbz	x22, LBB194_14
	ldr	x23, [x21, #752]
	ldr	x21, [x21, #744]
	mov	x0, x20
	mov	w1, #170
	mov	x2, x22
	bl	_memset
	xpaci	x19
	ldr	x8, [x23, #24]
	mov	x0, x21
	mov	x1, x20
	mov	x2, x22
	mov	w3, #3
	mov	x4, x19
	blr	x8
LBB194_14:
	ldr	x8, [sp, #24]
Lloh1490:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1491:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1492:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB194_31
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	ldp	x24, x23, [sp, #48]
	ldp	x26, x25, [sp, #32]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB194_16:
	.cfi_restore_state
	cmp	w8, #2
	b.ne	LBB194_28
	add	x8, x20, #24
	mov	w9, #3
	ldsetal	x9, x24, [x8]
	and	w8, w24, #0x3
	cmp	w8, #1
	b.gt	LBB194_21
	b.ne	LBB194_9
	tbnz	w24, #2, LBB194_27
	add	x1, sp, #20
	and	x2, x24, #0xfffffffffffffff8
	mov	x0, x20
	bl	l_Io.Threaded.Future.waitForCancelWithSignaling
	ldr	x24, [x20, #24]
	b	LBB194_23
LBB194_21:
	cmp	w8, #2
	b.ne	LBB194_9
	add	x1, sp, #20
	mov	x0, x20
	mov	x2, #0
	bl	l_Io.Threaded.Future.waitForCancelWithSignaling
LBB194_23:
	and	x8, x24, #0x3
	cmp	x8, #2
	b.ne	LBB194_9
	lsr	x8, x24, #2
	cbz	x8, LBB194_26
	mov	x9, #4611686018427387903
	cmp	x8, x9
	b.eq	LBB194_11
	b	LBB194_9
LBB194_26:
	bl	l_Io.Threaded.recancelInner
	b	LBB194_11
LBB194_27:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB194_28:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB194_29:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB194_30:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB194_31:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1485, Lloh1486, Lloh1487
	.loh AdrpAdd	Lloh1488, Lloh1489
	.loh AdrpLdrGotLdr	Lloh1490, Lloh1491, Lloh1492
	.cfi_endproc

	.p2align	2
l_Io.Threaded.concurrent:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x19, x8
Lloh1493:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1494:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1495:
	ldr	x8, [x8]
	str	x8, [sp, #16]
	str	x8, [sp, #56]
	cbz	x0, LBB195_53
	mov	x25, x0
	tst	x0, #0x7
	b.ne	LBB195_54
	mov	x21, x30
	mov	x7, x5
	mov	x9, x4
	mov	x5, x3
	mov	x4, x2
	mov	x3, x1
	ldr	x23, [x25, #744]
	ldr	x24, [x25, #752]
	str	x6, [sp]
	add	x0, sp, #24
	mov	x1, x23
	mov	x2, x24
	mov	x6, x9
	bl	l_Io.Threaded.Future.create
	ldrh	w8, [sp, #32]
	cbnz	w8, LBB195_38
	add	x22, x25, #836
	ldr	x20, [sp, #24]
	add	x9, x25, #836
	mov	w10, #1
	casa	w8, w10, [x9]
	cmp	w8, #0
	b.ne	LBB195_41
LBB195_4:
	ldr	x26, [x25, #568]
	ldr	x8, [x25, #560]
	cmp	x26, x8
	b.hs	LBB195_21
	add	x8, x26, #1
	str	x8, [x25, #568]
	ldr	x8, [x25, #536]
	lsr	x8, x8, #1
	cmp	x8, x26
	b.lo	LBB195_55
	b.ne	LBB195_30
	add	x8, x25, #536
	mov	w9, #2
	ldadd	x9, x8, [x8]
	cmn	x8, #2
	b.hs	LBB195_37
	ldr	x1, [x25, #528]
	add	x0, sp, #40
	mov	x2, x25
	bl	l_Thread.spawn__func_262
	ldrh	w8, [sp, #48]
	cbz	w8, LBB195_29
	add	x8, x25, #536
	mov	x9, #-2
	ldaddal	x9, x8, [x8]
	cmp	x8, #1
	b.ls	LBB195_37
	cmp	x8, #3
	b.ne	LBB195_13
	add	x8, x25, #544
	mov	w9, #2
	swpl	w9, w8, [x8]
	cbz	w8, LBB195_13
	cmp	w8, #2
	b.ne	LBB195_35
LBB195_13:
	str	x26, [x25, #568]
	add	x8, x25, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB195_37
LBB195_14:
	cmp	w8, #1
	b.eq	LBB195_17
	cmp	w8, #2
	b.ne	LBB195_34
	mov	x0, x22
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB195_17:
	ldr	x22, [x20, #48]
	cbz	x22, LBB195_19
	mov	x0, x20
	mov	w1, #170
	mov	x2, x22
	bl	_memset
	xpaci	x21
	ldr	x8, [x24, #24]
	mov	x0, x23
	mov	x1, x20
	mov	x2, x22
	mov	w3, #3
	mov	x4, x21
	blr	x8
LBB195_19:
Lloh1496:
	adrp	x8, l___anon_11834@PAGE
Lloh1497:
	add	x8, x8, l___anon_11834@PAGEOFF
Lloh1498:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #56]
Lloh1499:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1500:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1501:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB195_57
	.cfi_def_cfa wsp, 160
	b	LBB195_51
LBB195_21:
	.cfi_restore_state
	.cfi_remember_state
	add	x8, x25, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB195_37
	cmp	w8, #1
	b.eq	LBB195_25
	cmp	w8, #2
	b.ne	LBB195_34
	mov	x0, x22
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB195_25:
	ldr	x22, [x20, #48]
	cbz	x22, LBB195_27
	mov	x0, x20
	mov	w1, #170
	mov	x2, x22
	bl	_memset
	xpaci	x21
	ldr	x8, [x24, #24]
	mov	x0, x23
	mov	x1, x20
	mov	x2, x22
	mov	w3, #3
	mov	x4, x21
	blr	x8
LBB195_27:
Lloh1502:
	adrp	x8, l___anon_11834@PAGE
Lloh1503:
	add	x8, x8, l___anon_11834@PAGEOFF
Lloh1504:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #56]
Lloh1505:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1506:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1507:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB195_57
	.cfi_def_cfa wsp, 160
	b	LBB195_51
LBB195_29:
	.cfi_restore_state
	.cfi_remember_state
	ldr	x0, [sp, #40]
	bl	_pthread_detach
	cbnz	w0, LBB195_58
LBB195_30:
	ldr	x8, [x25]
	str	x8, [x20]
	str	x20, [x25]
	ldr	w9, [x25, #840]
	and	w8, w9, #0xffff
	cmp	w8, w9, lsr #16
	b.hi	LBB195_45
LBB195_31:
	add	x8, x25, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB195_37
	cmp	w8, #1
	b.eq	LBB195_49
	cmp	w8, #2
	b.eq	LBB195_48
LBB195_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB195_35:
	cmp	w8, #1
	b.ne	LBB195_34
	add	x0, x25, #544
	mov	w1, #-1
	bl	l_Io.Threaded.Thread.futexWake
	str	x26, [x25, #568]
	add	x8, x25, #836
	swpl	wzr, w8, [x8]
	cbnz	w8, LBB195_14
LBB195_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB195_38:
	cmp	w8, #64
	b.ne	LBB195_34
Lloh1508:
	adrp	x8, l___anon_11834@PAGE
Lloh1509:
	add	x8, x8, l___anon_11834@PAGEOFF
Lloh1510:
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #56]
Lloh1511:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1512:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1513:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB195_57
	.cfi_def_cfa wsp, 160
	b	LBB195_51
LBB195_41:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w8, #2
	b.eq	LBB195_52
	add	x8, x25, #836
	mov	w27, #2
	swpa	w27, w8, [x8]
	cbz	w8, LBB195_4
LBB195_43:
Lloh1514:
	adrp	x26, l___anon_2803@PAGE
Lloh1515:
	add	x26, x26, l___anon_2803@PAGEOFF
LBB195_44:
	add	x28, x25, #836
	add	x0, x25, #836
	mov	w1, #2
	mov	x2, x26
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	swpa	w27, w8, [x28]
	cbnz	w8, LBB195_44
	b	LBB195_4
LBB195_45:
	mov	x8, x9
LBB195_46:
	add	w10, w9, #16, lsl #12
	add	x11, x25, #840
	casl	w8, w10, [x11]
	cmp	w8, w9
	b.eq	LBB195_56
	and	w9, w8, #0xffff
	cmp	w9, w8, lsr #16
	mov	x9, x8
	b.ls	LBB195_31
	b	LBB195_46
LBB195_48:
	mov	x0, x22
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB195_49:
	str	x20, [x19]
	strh	wzr, [x19, #8]
	ldr	x8, [sp, #56]
Lloh1516:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1517:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1518:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB195_57
	.cfi_def_cfa wsp, 160
LBB195_51:
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB195_52:
	.cfi_restore_state
Lloh1519:
	adrp	x2, l___anon_2803@PAGE
Lloh1520:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x25, #836
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	add	x8, x25, #836
	mov	w27, #2
	swpa	w27, w8, [x8]
	cbnz	w8, LBB195_43
	b	LBB195_4
LBB195_53:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB195_54:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB195_55:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB195_56:
	add	x8, x25, #844
	mov	w9, #1
	ldaddl	w9, w8, [x8]
	add	x0, x22, #8
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB195_31
LBB195_57:
	bl	___stack_chk_fail
LBB195_58:
	cmp	w0, #3
	b.eq	LBB195_37
	cmp	w0, #22
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh1493, Lloh1494, Lloh1495
	.loh AdrpLdrGotLdr	Lloh1499, Lloh1500, Lloh1501
	.loh AdrpAddLdr	Lloh1496, Lloh1497, Lloh1498
	.loh AdrpLdrGotLdr	Lloh1505, Lloh1506, Lloh1507
	.loh AdrpAddLdr	Lloh1502, Lloh1503, Lloh1504
	.loh AdrpLdrGotLdr	Lloh1511, Lloh1512, Lloh1513
	.loh AdrpAddLdr	Lloh1508, Lloh1509, Lloh1510
	.loh AdrpAdd	Lloh1514, Lloh1515
	.loh AdrpLdrGotLdr	Lloh1516, Lloh1517, Lloh1518
	.loh AdrpAdd	Lloh1519, Lloh1520
	.cfi_endproc

	.p2align	2
l_Io.Threaded.async:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x28, x27, [sp, #64]
	stp	x26, x25, [sp, #80]
	stp	x24, x23, [sp, #96]
	stp	x22, x21, [sp, #112]
	stp	x20, x19, [sp, #128]
	stp	x29, x30, [sp, #144]
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
Lloh1521:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1522:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1523:
	ldr	x8, [x8]
	str	x8, [sp, #16]
	str	x8, [sp, #56]
	cbz	x0, LBB196_40
	mov	x24, x0
	tst	x0, #0x7
	b.ne	LBB196_41
	mov	x23, x30
	mov	x20, x7
	mov	x7, x6
	mov	x6, x5
	mov	x22, x4
	mov	x4, x3
	mov	x3, x2
	mov	x21, x1
	ldr	x25, [x24, #744]
	ldr	x27, [x24, #752]
	str	x20, [sp]
	add	x0, sp, #24
	mov	x1, x25
	mov	x2, x27
	mov	x5, x22
	bl	l_Io.Threaded.Future.create
	ldrh	w8, [sp, #32]
	cbnz	w8, LBB196_28
	add	x26, x24, #836
	ldr	x19, [sp, #24]
	add	x9, x24, #836
	mov	w10, #1
	casa	w8, w10, [x9]
	cmp	w8, #0
	b.ne	LBB196_29
LBB196_4:
	ldr	x28, [x24, #568]
	ldr	x8, [x24, #552]
	cmp	x28, x8
	b.hs	LBB196_14
	add	x8, x28, #1
	str	x8, [x24, #568]
	ldr	x8, [x24, #536]
	lsr	x8, x8, #1
	cmp	x8, x28
	b.lo	LBB196_42
	b.ne	LBB196_22
	add	x8, x24, #536
	mov	w9, #2
	ldadd	x9, x8, [x8]
	cmn	x8, #2
	b.hs	LBB196_46
	ldr	x1, [x24, #528]
	add	x0, sp, #40
	mov	x2, x24
	bl	l_Thread.spawn__func_262
	ldrh	w8, [sp, #48]
	cbz	w8, LBB196_21
	add	x8, x24, #536
	mov	x9, #-2
	ldaddal	x9, x8, [x8]
	cmp	x8, #1
	b.ls	LBB196_46
	cmp	x8, #3
	b.ne	LBB196_13
	add	x8, x24, #544
	mov	w9, #2
	swpl	w9, w8, [x8]
	cbz	w8, LBB196_13
	cmp	w8, #2
	b.ne	LBB196_26
LBB196_13:
	str	x28, [x24, #568]
LBB196_14:
	add	x8, x24, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB196_46
	cmp	w8, #1
	b.eq	LBB196_18
	cmp	w8, #2
	b.ne	LBB196_25
	mov	x0, x26
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB196_18:
	ldr	x24, [x19, #48]
	cbz	x24, LBB196_20
	mov	x0, x19
	mov	w1, #170
	mov	x2, x24
	bl	_memset
	xpaci	x23
	ldr	x8, [x27, #24]
	mov	x0, x25
	mov	x1, x19
	mov	x2, x24
	mov	w3, #3
	mov	x4, x23
	blr	x8
LBB196_20:
	mov	x0, x22
	mov	x1, x21
	blr	x20
	mov	x19, #0
	b	LBB196_34
LBB196_21:
	ldr	x0, [sp, #40]
	bl	_pthread_detach
	cbnz	w0, LBB196_44
LBB196_22:
	ldr	x8, [x24]
	str	x8, [x19]
	str	x19, [x24]
	add	x8, x24, #836
	swpl	wzr, w8, [x8]
	cbz	w8, LBB196_46
	cmp	w8, #1
	b.eq	LBB196_33
	cmp	w8, #2
	b.eq	LBB196_32
LBB196_25:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB196_26:
	cmp	w8, #1
	b.ne	LBB196_25
	add	x0, x24, #544
	mov	w1, #-1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB196_13
LBB196_28:
	cmp	w8, #64
	b.eq	LBB196_20
	b	LBB196_25
LBB196_29:
	cmp	w8, #2
	b.eq	LBB196_39
	add	x8, x24, #836
	mov	w9, #2
	swpa	w9, w8, [x8]
	cbz	w8, LBB196_4
LBB196_31:
	add	x28, x24, #836
	add	x0, x24, #836
	mov	w1, #2
Lloh1524:
	adrp	x2, l___anon_2803@PAGE
Lloh1525:
	add	x2, x2, l___anon_2803@PAGEOFF
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	mov	w8, #2
	swpa	w8, w8, [x28]
	cbnz	w8, LBB196_31
	b	LBB196_4
LBB196_32:
	add	x0, x24, #836
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
LBB196_33:
	ldr	w9, [x24, #840]
	and	w8, w9, #0xffff
	cmp	w8, w9, lsr #16
	b.hi	LBB196_36
LBB196_34:
	ldr	x8, [sp, #56]
Lloh1526:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1527:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1528:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB196_43
	mov	x0, x19
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]
	ldp	x20, x19, [sp, #128]
	ldp	x22, x21, [sp, #112]
	ldp	x24, x23, [sp, #96]
	ldp	x26, x25, [sp, #80]
	ldp	x28, x27, [sp, #64]
	add	sp, sp, #160
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB196_36:
	.cfi_restore_state
	mov	x8, x9
LBB196_37:
	add	w10, w9, #16, lsl #12
	add	x11, x24, #840
	casl	w8, w10, [x11]
	cmp	w8, w9
	b.eq	LBB196_47
	and	w9, w8, #0xffff
	cmp	w9, w8, lsr #16
	mov	x9, x8
	b.ls	LBB196_34
	b	LBB196_37
LBB196_39:
Lloh1529:
	adrp	x2, l___anon_2803@PAGE
Lloh1530:
	add	x2, x2, l___anon_2803@PAGEOFF
	add	x0, x24, #836
	mov	w1, #2
	bl	l_Io.Threaded.Thread.futexWaitUncancelable
	add	x8, x24, #836
	mov	w9, #2
	swpa	w9, w8, [x8]
	cbnz	w8, LBB196_31
	b	LBB196_4
LBB196_40:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB196_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB196_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB196_43:
	bl	___stack_chk_fail
LBB196_44:
	cmp	w0, #3
	b.eq	LBB196_46
	cmp	w0, #22
LBB196_46:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB196_47:
	add	x8, x24, #844
	mov	w9, #1
	ldaddl	w9, w8, [x8]
	add	x0, x26, #8
	mov	w1, #1
	bl	l_Io.Threaded.Thread.futexWake
	b	LBB196_34
	.loh AdrpLdrGotLdr	Lloh1521, Lloh1522, Lloh1523
	.loh AdrpAdd	Lloh1524, Lloh1525
	.loh AdrpLdrGotLdr	Lloh1526, Lloh1527, Lloh1528
	.loh AdrpAdd	Lloh1529, Lloh1530
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI197_0:
	.quad	0
	.quad	-6148914691236517206
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.Future.create:
	.cfi_startproc
	stp	x28, x27, [sp, #-96]!
	.cfi_def_cfa_offset 96
	stp	x26, x25, [sp, #16]
	stp	x24, x23, [sp, #32]
	stp	x22, x21, [sp, #48]
	stp	x20, x19, [sp, #64]
	stp	x29, x30, [sp, #80]
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x22, x7
	mov	w8, #1
	lsl	x8, x8, x7
	subs	x8, x8, #8
	csel	x8, xzr, x8, lo
	add	x8, x8, #64
	mov	x9, #-1
	lsl	x25, x9, x7
	mvn	x27, x25
	adds	x8, x8, x27
	b.hs	LBB197_20
	mov	x20, x6
	and	x8, x8, x25
	adds	x8, x8, x6
	b.hs	LBB197_20
	lsl	x26, x9, x4
	mvn	x28, x26
	adds	x8, x8, x28
	b.hs	LBB197_20
	and	x8, x8, x26
	adds	x24, x8, x3
	b.hs	LBB197_20
	mov	x21, x5
	mov	x19, x0
	cbz	x24, LBB197_8
	xpaci	x30
	ldr	x8, [x2]
	mov	x0, x1
	mov	x1, x24
	mov	w2, #3
	mov	x3, x30
	blr	x8
	cbz	x0, LBB197_18
	mov	x23, x0
	mov	w1, #170
	mov	x2, x24
	bl	_memset
	tst	x23, #0x7
	b.eq	LBB197_9
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB197_8:
	mov	x23, #-8
LBB197_9:
	adds	x8, x23, #64
	b.hs	LBB197_20
	adds	x8, x8, x27
	b.hs	LBB197_20
	and	x8, x8, x25
	adds	x9, x8, x20
	b.hs	LBB197_20
	adds	x9, x9, x28
	b.hs	LBB197_20
	and	x9, x9, x26
	subs	x9, x9, x23
	b.lo	LBB197_20
	ldr	x10, [x29, #16]
	and	w11, w22, #0x3f
	mov	x12, #-6148914691236517206
Lloh1531:
	adrp	x13, l_Io.Threaded.Future.start@PAGE
Lloh1532:
	add	x13, x13, l_Io.Threaded.Future.start@PAGEOFF
	stp	x12, x13, [x23]
	str	x10, [x23, #16]
Lloh1533:
	adrp	x10, lCPI197_0@PAGE
Lloh1534:
	ldr	q0, [x10, lCPI197_0@PAGEOFF]
	stur	q0, [x23, #24]
	strb	w11, [x23, #56]
	stp	x9, x24, [x23, #40]
	subs	x8, x8, x23
	b.lo	LBB197_20
	add	x0, x23, x8
	add	x8, x21, x20
	cmp	x0, x8
	b.hs	LBB197_17
	add	x8, x0, x20
	cmp	x21, x8
	b.lo	LBB197_21
LBB197_17:
	mov	x1, x21
	mov	x2, x20
	bl	_memcpy
	mov	w8, #0
	str	x23, [x19]
	b	LBB197_19
LBB197_18:
	mov	w8, #64
LBB197_19:
	strh	w8, [x19, #8]
	.cfi_def_cfa wsp, 96
	ldp	x29, x30, [sp, #80]
	ldp	x20, x19, [sp, #64]
	ldp	x22, x21, [sp, #48]
	ldp	x24, x23, [sp, #32]
	ldp	x26, x25, [sp, #16]
	ldp	x28, x27, [sp], #96
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB197_20:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB197_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpLdr	Lloh1533, Lloh1534
	.loh AdrpAdd	Lloh1531, Lloh1532
	.cfi_endproc

	.p2align	2
l_Io.Threaded.crashHandler:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x0, LBB198_5
	tst	x0, #0x7
	b.ne	LBB198_6
Lloh1535:
	adrp	x0, l_Io.Threaded.Thread.current@TLVPPAGE
Lloh1536:
	ldr	x0, [x0, l_Io.Threaded.Thread.current@TLVPPAGEOFF]
	ldr	x8, [x0]
	blr	x8
	ldr	x8, [x0]
	cbz	x8, LBB198_4
	mov	w9, #7
	str	x9, [x8, #24]
	mov	w9, #1
	strb	w9, [x8, #552]
LBB198_4:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB198_5:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB198_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdr	Lloh1535, Lloh1536
	.cfi_endproc

	.p2align	2
l_Io.Threaded.Future.start:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	str	x0, [x1, #24]
	add	x8, x0, #24
	ldsetl	x1, x8, [x8]
	cmp	x8, #4
	b.hs	LBB199_20
	mov	x20, x1
	mov	x19, x0
	cmp	x8, #2
	b.lo	LBB199_4
	cmp	w8, #3
	b.ne	LBB199_20
	orr	x8, x19, #0x6
	str	x8, [x20, #24]
LBB199_4:
	adds	x8, x19, #64
	b.hs	LBB199_17
	ldrb	w9, [x19, #56]
	mov	x10, #-1
	lsl	x9, x10, x9
	mvn	x10, x9
	adds	x8, x8, x10
	b.hs	LBB199_17
	and	x8, x8, x9
	subs	x8, x8, x19
	b.lo	LBB199_17
	ldr	x9, [x19, #16]
	ldr	x10, [x19, #40]
	add	x0, x19, x8
	add	x1, x19, x10
	blr	x9
	ldr	x8, [x20, #24]
	and	w8, w8, #0x7
	cmp	w8, #4
	b.le	LBB199_14
	cmp	w8, #6
	b.eq	LBB199_15
	cmp	w8, #7
	b.ne	LBB199_20
	mov	x8, #-2
	str	xzr, [x20, #24]
	add	x9, x19, #24
	swpal	x8, x8, [x9]
	ands	w8, w8, #0x3
	b.eq	LBB199_16
LBB199_11:
	cmp	w8, #1
	b.eq	LBB199_13
	cmp	w8, #3
	b.ne	LBB199_20
LBB199_13:
	ldr	x0, [x19, #32]
	mov	w8, #1
	ldaddl	w8, w8, [x0]
	mov	w1, #1
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	b	l_Io.Threaded.Thread.futexWake
LBB199_14:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w8, #0
	b.gt	LBB199_18
LBB199_15:
	mov	w8, #2
	str	xzr, [x20, #24]
	add	x9, x19, #24
	swpal	x8, x8, [x9]
	ands	w8, w8, #0x3
	b.ne	LBB199_11
LBB199_16:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB199_17:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB199_18:
	cmp	w8, #2
	b.gt	LBB199_21
	cmp	w8, #1
LBB199_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB199_21:
	cmp	w8, #3
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netShutdownPosix:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
Lloh1537:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1538:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1539:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	cbz	x0, LBB200_19
	tst	x0, #0x7
	b.ne	LBB200_20
	mov	x19, x1
	and	w8, w2, #0x3
	cmp	w8, #1
	b.gt	LBB200_4
	cmp	w8, #0
	csinc	w20, w8, wzr, eq
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbz	w0, LBB200_6
	b	LBB200_14
LBB200_4:
	cmp	w8, #2
	b.ne	LBB200_21
	mov	w20, #2
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB200_14
LBB200_6:
	ldr	x21, [sp, #40]
LBB200_7:
	mov	x0, x19
	mov	x1, x20
	bl	_shutdown
	cmn	w0, #1
	b.ne	LBB200_13
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB200_18
	cmp	w22, #16, lsl #12
	b.hs	LBB200_18
	cmp	w22, #4
	b.ne	LBB200_12
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB200_7
	b	LBB200_14
LBB200_12:
	cbnz	w22, LBB200_16
LBB200_13:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB200_14:
	ldur	x8, [x29, #-40]
Lloh1540:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1541:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1542:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB200_17
LBB200_15:
	.cfi_def_cfa wsp, 112
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB200_16:
	.cfi_restore_state
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
	mov	w9, #4
	cmp	w22, #55
	csel	w8, w9, w8, eq
	mov	w9, #8
	cmp	w22, #57
	csel	w0, w9, w8, eq
	ldur	x8, [x29, #-40]
Lloh1543:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1544:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1545:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB200_15
LBB200_17:
	bl	___stack_chk_fail
LBB200_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB200_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB200_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB200_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh1537, Lloh1538, Lloh1539
	.loh AdrpLdrGotLdr	Lloh1540, Lloh1541, Lloh1542
	.loh AdrpLdrGotLdr	Lloh1543, Lloh1544, Lloh1545
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netConnectUnixPosix:
	.cfi_startproc
	sub	sp, sp, #256
	.cfi_def_cfa_offset 256
	stp	x24, x23, [sp, #192]
	stp	x22, x21, [sp, #208]
	stp	x20, x19, [sp, #224]
	stp	x29, x30, [sp, #240]
	add	x29, sp, #240
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh1546:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1547:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1548:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB201_52
	tst	x0, #0x7
	b.ne	LBB201_53
	mov	x21, x1
Lloh1549:
	adrp	x2, l___anon_11883@PAGE
Lloh1550:
	add	x2, x2, l___anon_11883@PAGEOFF
	mov	w22, #1
	add	x0, sp, #40
	mov	w1, #1
	bl	l_Io.Threaded.openSocketPosix
	ldrh	w8, [sp, #44]
	cbnz	w8, LBB201_44
	ldr	w20, [sp, #40]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #48]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #112]
	stur	q0, [sp, #138]
	strb	w22, [sp, #49]
	ldr	x22, [x21, #8]
	cmp	x22, #105
	b.hs	LBB201_55
	add	x8, sp, #48
	orr	x0, x8, #0x2
	ldr	x1, [x21]
	add	x21, x0, x22
	cmp	x1, x21
	b.hs	LBB201_6
	add	x8, x1, x22
	cmp	x0, x8
	b.lo	LBB201_56
LBB201_6:
	mov	x2, x22
	bl	_memcpy
	cmp	x22, #104
	b.eq	LBB201_47
	strb	wzr, [x21]
	add	w21, w22, #3
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w22, [x29, #-64]
	cbnz	w22, LBB201_38
LBB201_8:
	ldur	x23, [x29, #-72]
LBB201_9:
	add	x1, sp, #48
	mov	x0, x20
	mov	x2, x21
	bl	_connect
	cmn	w0, #1
	b.ne	LBB201_15
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB201_51
	cmp	w22, #16, lsl #12
	b.hs	LBB201_51
	cmp	w22, #4
	b.ne	LBB201_14
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w22, w0, #0xffff
	b.eq	LBB201_9
	b	LBB201_38
LBB201_14:
	cbnz	w22, LBB201_16
LBB201_15:
	str	x23, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	str	w20, [x19]
	strh	wzr, [x19, #4]
	b	LBB201_42
LBB201_16:
	str	x23, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w22, #34
	b.gt	LBB201_22
	cmp	w22, #12
	b.le	LBB201_25
	cmp	w22, #13
	b.eq	LBB201_35
	cmp	w22, #20
	b.eq	LBB201_36
	cmp	w22, #30
	b.ne	LBB201_37
	mov	w22, #41
	b	LBB201_38
LBB201_22:
	cmp	w22, #60
	b.gt	LBB201_28
	sub	w8, w22, #35
	cmp	w8, #2
	b.hs	LBB201_31
	mov	w22, #9
	b	LBB201_38
LBB201_25:
	cmp	w22, #1
	b.eq	LBB201_33
	cmp	w22, #2
	b.ne	LBB201_37
	mov	w22, #39
	b	LBB201_38
LBB201_28:
	cmp	w22, #61
	b.eq	LBB201_34
	cmp	w22, #62
	b.ne	LBB201_37
	mov	w22, #37
	b	LBB201_38
LBB201_31:
	cmp	w22, #47
	b.ne	LBB201_37
	mov	w22, #32
	b	LBB201_38
LBB201_33:
	mov	w22, #18
	b	LBB201_38
LBB201_34:
	mov	w22, #31
	b	LBB201_38
LBB201_35:
	mov	w22, #10
	b	LBB201_38
LBB201_36:
	mov	w22, #40
	b	LBB201_38
LBB201_37:
	mov	w22, #12
LBB201_38:
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB201_41
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB201_51
	cmp	w8, #16, lsl #12
	b.hs	LBB201_51
LBB201_41:
	strh	w22, [x19, #4]
LBB201_42:
	ldur	x8, [x29, #-56]
Lloh1551:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1552:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1553:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB201_54
	.cfi_def_cfa wsp, 256
	ldp	x29, x30, [sp, #240]
	ldp	x20, x19, [sp, #224]
	ldp	x22, x21, [sp, #208]
	ldp	x24, x23, [sp, #192]
	add	sp, sp, #256
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB201_44:
	.cfi_restore_state
	cmp	w8, #84
	b.eq	LBB201_48
	cmp	w8, #86
	b.ne	LBB201_50
	mov	x8, #51539607552
	b	LBB201_49
LBB201_47:
	mov	w21, #106
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w22, [x29, #-64]
	cbz	w22, LBB201_8
	b	LBB201_38
LBB201_48:
	mov	x8, #137438953472
LBB201_49:
	str	x8, [x19]
	b	LBB201_42
LBB201_50:
	strh	w8, [x19, #4]
	b	LBB201_42
LBB201_51:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB201_52:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB201_53:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB201_54:
	bl	___stack_chk_fail
LBB201_55:
	mov	x0, x22
	mov	w1, #104
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB201_56:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpLdrGotLdr	Lloh1546, Lloh1547, Lloh1548
	.loh AdrpAdd	Lloh1549, Lloh1550
	.loh AdrpLdrGotLdr	Lloh1551, Lloh1552, Lloh1553
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netConnectIpPosix:
	.cfi_startproc
	sub	sp, sp, #208
	.cfi_def_cfa_offset 208
	stp	x24, x23, [sp, #144]
	stp	x22, x21, [sp, #160]
	stp	x20, x19, [sp, #176]
	stp	x29, x30, [sp, #192]
	add	x29, sp, #192
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh1554:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1555:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1556:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	ldrb	w8, [x2, #32]
	tst	w8, #0x3
	b.ne	LBB202_46
	cbz	x0, LBB202_47
	tst	x0, #0x7
	b.ne	LBB202_48
	mov	x21, x1
	ldr	x8, [x2, #48]
	ldrb	w9, [x2, #56]
	ldrb	w10, [x1, #28]
	strh	wzr, [sp, #56]
	strb	wzr, [sp, #58]
	and	w9, w9, #0x7
	strb	w9, [sp, #59]
	str	x8, [sp, #48]
	tst	w10, #0x1
	mov	w8, #2
	mov	w9, #30
	csel	w1, w9, w8, ne
	add	x0, sp, #60
	add	x2, sp, #48
	bl	l_Io.Threaded.openSocketPosix
	ldrh	w8, [sp, #64]
	cbnz	w8, LBB202_43
	ldr	w20, [sp, #60]
	add	x22, sp, #68
	mov	x8, #-6148914691236517206
	stur	x8, [sp, #76]
	stur	x8, [sp, #84]
	str	w8, [sp, #92]
	ldrb	w8, [x21, #28]
	tbz	w8, #0, LBB202_6
	ldrh	w8, [x21, #8]
	rev16	w9, w8
	ldp	w8, w10, [x21]
	ldur	q0, [x21, #10]
	stur	q0, [x22, #8]
	str	w10, [sp, #92]
	mov	w21, #28
	mov	w10, #30
	b	LBB202_7
LBB202_6:
	ldur	w8, [x21, #2]
	ldrh	w9, [x21]
	rev16	w9, w9
	stur	xzr, [sp, #76]
	mov	w21, #16
	mov	w10, #2
LBB202_7:
	strb	w21, [sp, #68]
	strb	w10, [sp, #69]
	strh	w9, [sp, #70]
	str	w8, [sp, #72]
	str	w21, [sp, #20]
	sub	x0, x29, #72
	bl	l_Io.Threaded.Syscall.start
	ldurh	w24, [x29, #-64]
	cbnz	w24, LBB202_33
	ldur	x23, [x29, #-72]
LBB202_9:
	add	x1, sp, #68
	mov	x0, x20
	mov	x2, x21
	bl	_connect
	cmn	w0, #1
	b.ne	LBB202_17
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB202_45
	cmp	w8, #16, lsl #12
	b.hs	LBB202_45
	cmp	w8, #4
	b.ne	LBB202_14
	str	x23, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w24, w0, #0xffff
	b.eq	LBB202_9
	b	LBB202_33
LBB202_14:
	cmp	w8, #65
	b.hi	LBB202_31
	mov	w8, w8
Lloh1557:
	adrp	x9, LJTI202_0@PAGE
Lloh1558:
	add	x9, x9, LJTI202_0@PAGEOFF
	adr	x10, LBB202_16
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB202_16:
	mov	w24, #9
	b	LBB202_32
LBB202_17:
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	add	x1, sp, #68
	add	x2, sp, #20
	mov	x0, x20
	bl	l_Io.Threaded.posixGetSockName
	tst	w0, #0xffff
	b.ne	LBB202_44
	strh	wzr, [x19, #36]
	str	w20, [x19]
	ldrb	w8, [sp, #69]
	cmp	w8, #30
	b.eq	LBB202_39
	cmp	w8, #2
	b.ne	LBB202_40
	mov	w8, #0
	ldrh	w9, [sp, #70]
	ldr	w10, [sp, #72]
	rev	w9, w9
	lsr	w9, w9, #16
	orr	x9, x9, x10, lsl #16
	b	LBB202_41
LBB202_21:
	mov	w24, #30
	b	LBB202_32
LBB202_22:
	mov	w24, #10
	b	LBB202_32
LBB202_23:
	mov	w24, #91
	b	LBB202_32
LBB202_24:
	mov	w24, #32
	b	LBB202_32
LBB202_25:
	mov	w24, #29
	b	LBB202_32
LBB202_26:
	mov	w24, #82
	b	LBB202_32
LBB202_27:
	mov	w24, #35
	b	LBB202_32
LBB202_28:
	mov	w24, #6
	b	LBB202_32
LBB202_29:
	mov	w24, #26
	b	LBB202_32
LBB202_30:
	mov	w24, #31
	b	LBB202_32
LBB202_31:
	mov	w24, #12
LBB202_32:
	str	x23, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
LBB202_33:
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB202_36
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB202_45
	cmp	w8, #16, lsl #12
	b.hs	LBB202_45
LBB202_36:
	strh	w24, [x19, #36]
LBB202_37:
	ldur	x8, [x29, #-56]
Lloh1559:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1560:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1561:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB202_49
	.cfi_def_cfa wsp, 208
	ldp	x29, x30, [sp, #192]
	ldp	x20, x19, [sp, #176]
	ldp	x22, x21, [sp, #160]
	ldp	x24, x23, [sp, #144]
	add	sp, sp, #208
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB202_39:
	.cfi_restore_state
	ldrh	w8, [sp, #70]
	rev16	w10, w8
	ldr	w8, [sp, #72]
	ldr	w9, [sp, #92]
	orr	x9, x8, x9, lsl #32
	ldur	q0, [x22, #8]
	str	q0, [sp, #96]
	mov	w8, #1
	b	LBB202_42
LBB202_40:
	mov	w8, #0
	mov	x9, #8323072
	movk	x9, #256, lsl #32
LBB202_41:
LBB202_42:
	stur	x9, [x19, #4]
	strh	w10, [x19, #12]
	ldr	q0, [sp, #96]
	stur	q0, [x19, #14]
	strb	w8, [x19, #32]
	b	LBB202_37
LBB202_43:
	strh	w8, [x19, #36]
	b	LBB202_37
LBB202_44:
	mov	x21, x0
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	strh	w21, [x19, #36]
	b	LBB202_37
LBB202_45:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB202_46:
Lloh1562:
	adrp	x0, l___anon_11944@PAGE
Lloh1563:
	add	x0, x0, l___anon_11944@PAGEOFF
	mov	w1, #45
	bl	l_debug.defaultPanic
LBB202_47:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB202_48:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB202_49:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1554, Lloh1555, Lloh1556
	.loh AdrpAdd	Lloh1557, Lloh1558
	.loh AdrpLdrGotLdr	Lloh1559, Lloh1560, Lloh1561
	.loh AdrpAdd	Lloh1562, Lloh1563
	.cfi_endproc
	.section	__TEXT,__const
LJTI202_0:
	.byte	(LBB202_17-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_22-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_16-LBB202_16)>>2
	.byte	(LBB202_16-LBB202_16)>>2
	.byte	(LBB202_23-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_24-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_26-LBB202_16)>>2
	.byte	(LBB202_29-LBB202_16)>>2
	.byte	(LBB202_25-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_28-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_27-LBB202_16)>>2
	.byte	(LBB202_30-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_31-LBB202_16)>>2
	.byte	(LBB202_21-LBB202_16)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.setSocketOptionPosix:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x2
	mov	x20, x1
	mov	x21, x0
Lloh1564:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1565:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1566:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #56]
	str	w3, [sp, #12]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w22, [sp, #48]
	cbnz	w22, LBB203_10
	ldr	x23, [sp, #40]
	add	x24, sp, #16
LBB203_2:
	add	x3, sp, #12
	mov	x0, x21
	mov	x1, x20
	mov	x2, x19
	mov	w4, #4
	bl	_setsockopt
	cmn	w0, #1
	b.ne	LBB203_8
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB203_12
	cmp	w8, #16, lsl #12
	b.hs	LBB203_12
	cmp	w8, #4
	b.ne	LBB203_7
	str	x23, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w22, w0, #0xffff
	b.eq	LBB203_2
	b	LBB203_10
LBB203_7:
	mov	w9, #12
	add	x10, sp, #32
	cmp	w8, #0
	csel	w22, w8, w9, eq
	csel	x0, x24, x10, eq
	b	LBB203_9
LBB203_8:
	mov	w22, #0
	add	x0, sp, #16
LBB203_9:
	str	x23, [x0]
	bl	l_Io.Threaded.Syscall.finish
LBB203_10:
	ldr	x8, [sp, #56]
Lloh1567:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1568:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1569:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB203_13
	mov	x0, x22
	.cfi_def_cfa wsp, 128
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB203_12:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB203_13:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1564, Lloh1565, Lloh1566
	.loh AdrpLdrGotLdr	Lloh1567, Lloh1568, Lloh1569
	.cfi_endproc

	.p2align	2
l_Io.Threaded.openSocketPosix:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x26, x25, [sp, #64]
	stp	x24, x23, [sp, #80]
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
Lloh1570:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1571:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1572:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #56]
	ldrb	w8, [x2, #11]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB204_38
	mov	x21, x1
	mov	x19, x0
	ldrb	w25, [x2, #8]
	ldrb	w26, [x2, #9]
	ldr	x9, [x2]
	and	x8, x8, #0x7
Lloh1573:
	adrp	x10, l_switch.table.Io.Threaded.openSocketPosix@PAGE
Lloh1574:
	add	x10, x10, l_switch.table.Io.Threaded.openSocketPosix@PAGEOFF
	ldr	w22, [x10, x8, lsl #2]
	tst	x9, #0x100000000
	csel	w23, wzr, w9, eq
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB204_34
	ldr	x24, [sp, #40]
LBB204_3:
	and	w0, w21, #0xff
	mov	x1, x22
	mov	x2, x23
	bl	_socket
	mov	x20, x0
	cmn	w0, #1
	b.ne	LBB204_23
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB204_37
	cmp	w8, #16, lsl #12
	b.hs	LBB204_37
	cmp	w8, #4
	b.ne	LBB204_8
	str	x24, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB204_3
	b	LBB204_34
LBB204_8:
	cmp	w8, #23
	b.le	LBB204_13
	cmp	w8, #42
	b.le	LBB204_20
	cmp	w8, #43
	b.eq	LBB204_30
	cmp	w8, #47
	b.eq	LBB204_32
	cmp	w8, #55
	b.eq	LBB204_16
	b	LBB204_33
LBB204_13:
	cmp	w8, #21
	b.gt	LBB204_17
	cbz	w8, LBB204_24
	cmp	w8, #12
	b.ne	LBB204_33
LBB204_16:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #4
	b	LBB204_34
LBB204_17:
	cmp	w8, #22
	b.eq	LBB204_29
	cmp	w8, #23
	b.ne	LBB204_33
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #24
	b	LBB204_34
LBB204_20:
	cmp	w8, #24
	b.eq	LBB204_31
	cmp	w8, #41
	b.ne	LBB204_33
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #85
	b	LBB204_34
LBB204_23:
	mov	x21, x20
	b	LBB204_25
LBB204_24:
	mov	w21, #-1
LBB204_25:
	str	x24, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x21
	bl	l_Io.Threaded.setCloexec
	tst	w0, #0xffff
	b.ne	LBB204_36
	tbz	w26, #0, LBB204_28
	and	w3, w25, #0x1
	mov	x0, x20
	mov	w1, #41
	mov	w2, #27
	bl	l_Io.Threaded.setSocketOptionPosix
	tst	w0, #0xffff
	b.ne	LBB204_36
LBB204_28:
	mov	w8, #0
	str	w20, [x19]
	b	LBB204_34
LBB204_29:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #83
	b	LBB204_34
LBB204_30:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #84
	b	LBB204_34
LBB204_31:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #23
	b	LBB204_34
LBB204_32:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #32
	b	LBB204_34
LBB204_33:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	mov	w8, #12
LBB204_34:
	strh	w8, [x19, #4]
	ldr	x8, [sp, #56]
Lloh1575:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1576:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1577:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB204_39
	.cfi_def_cfa wsp, 144
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	ldp	x24, x23, [sp, #80]
	ldp	x26, x25, [sp, #64]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB204_36:
	.cfi_restore_state
	mov	x21, x0
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	mov	x8, x21
	b	LBB204_34
LBB204_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB204_38:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB204_39:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1570, Lloh1571, Lloh1572
	.loh AdrpAdd	Lloh1573, Lloh1574
	.loh AdrpLdrGotLdr	Lloh1575, Lloh1576, Lloh1577
	.cfi_endproc

	.p2align	2
l_Io.Threaded.posixBind:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x2
	mov	x20, x1
	mov	x21, x0
Lloh1578:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1579:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1580:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #56]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.start
	ldrh	w0, [sp, #48]
	cbnz	w0, LBB205_9
	ldr	x22, [sp, #40]
LBB205_2:
	mov	x0, x21
	mov	x1, x20
	mov	x2, x19
	bl	_bind
	cmn	w0, #1
	b.ne	LBB205_8
	bl	___error
	ldr	w23, [x0]
	tbnz	w23, #31, LBB205_23
	cmp	w23, #16, lsl #12
	b.hs	LBB205_23
	cmp	w23, #4
	b.ne	LBB205_7
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w0, w0, #0xffff
	b.eq	LBB205_2
	b	LBB205_9
LBB205_7:
	cbnz	w23, LBB205_11
LBB205_8:
	str	x22, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	mov	w0, #0
LBB205_9:
	ldr	x8, [sp, #56]
Lloh1581:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1582:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1583:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB205_24
	.cfi_def_cfa wsp, 128
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB205_11:
	.cfi_restore_state
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	cmp	w23, #46
	b.le	LBB205_16
	cmp	w23, #47
	b.eq	LBB205_19
	cmp	w23, #49
	b.eq	LBB205_20
	cmp	w23, #48
	b.ne	LBB205_22
	mov	w0, #81
	b	LBB205_9
LBB205_16:
	cmp	w23, #12
	b.eq	LBB205_21
	cmp	w23, #13
	b.ne	LBB205_22
	mov	w0, #10
	b	LBB205_9
LBB205_19:
	mov	w0, #32
	b	LBB205_9
LBB205_20:
	mov	w0, #82
	b	LBB205_9
LBB205_21:
	mov	w0, #4
	b	LBB205_9
LBB205_22:
	mov	w0, #12
	b	LBB205_9
LBB205_23:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB205_24:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1578, Lloh1579, Lloh1580
	.loh AdrpLdrGotLdr	Lloh1581, Lloh1582, Lloh1583
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netBindIpPosix:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x24, x23, [sp, #80]
	stp	x22, x21, [sp, #96]
	stp	x20, x19, [sp, #112]
	stp	x29, x30, [sp, #128]
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh1584:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1585:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1586:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-56]
	cbz	x0, LBB206_21
	tst	x0, #0x7
	b.ne	LBB206_22
	mov	x21, x1
	ldrb	w23, [x2, #10]
	ldrb	w8, [x1, #28]
	tst	w8, #0x1
	mov	w8, #2
	mov	w9, #30
	csel	w1, w9, w8, ne
	add	x0, sp, #12
	bl	l_Io.Threaded.openSocketPosix
	ldrh	w8, [sp, #16]
	cbnz	w8, LBB206_20
	ldr	w20, [sp, #12]
	add	x22, sp, #20
	mov	x8, #-6148914691236517206
	stur	x8, [sp, #28]
	stur	x8, [sp, #36]
	str	w8, [sp, #44]
	ldrb	w8, [x21, #28]
	tbz	w8, #0, LBB206_5
	ldrh	w8, [x21, #8]
	rev16	w9, w8
	ldp	w8, w10, [x21]
	ldur	q0, [x21, #10]
	stur	q0, [x22, #8]
	str	w10, [sp, #44]
	mov	w2, #28
	mov	w10, #30
	b	LBB206_6
LBB206_5:
	ldur	w8, [x21, #2]
	ldrh	w9, [x21]
	rev16	w9, w9
	stur	xzr, [sp, #28]
	mov	w2, #16
	mov	w10, #2
LBB206_6:
	strb	w2, [sp, #20]
	strb	w10, [sp, #21]
	strh	w9, [sp, #22]
	str	w8, [sp, #24]
	str	w2, [sp, #8]
	add	x1, sp, #20
	mov	x0, x20
	bl	l_Io.Threaded.posixBind
	tst	w0, #0xffff
	b.ne	LBB206_19
	tbz	w23, #0, LBB206_9
	mov	x0, x20
	mov	w1, #65535
	mov	w2, #32
	mov	w3, #1
	bl	l_Io.Threaded.setSocketOptionPosix
	tst	w0, #0xffff
	b.ne	LBB206_19
LBB206_9:
	add	x1, sp, #20
	add	x2, sp, #8
	mov	x0, x20
	bl	l_Io.Threaded.posixGetSockName
	tst	w0, #0xffff
	b.ne	LBB206_19
	strh	wzr, [x19, #36]
	str	w20, [x19]
	ldrb	w8, [sp, #21]
	cmp	w8, #30
	b.eq	LBB206_13
	cmp	w8, #2
	b.ne	LBB206_14
	mov	w8, #0
	ldrh	w9, [sp, #22]
	ldr	w10, [sp, #24]
	rev	w9, w9
	lsr	w9, w9, #16
	orr	x9, x9, x10, lsl #16
	b	LBB206_15
LBB206_13:
	ldrh	w8, [sp, #22]
	rev16	w10, w8
	ldr	w8, [sp, #24]
	ldr	w9, [sp, #44]
	orr	x9, x8, x9, lsl #32
	ldur	q0, [x22, #8]
	str	q0, [sp, #48]
	mov	w8, #1
	b	LBB206_16
LBB206_14:
	mov	w8, #0
	mov	x9, #8323072
	movk	x9, #256, lsl #32
LBB206_15:
LBB206_16:
	stur	x9, [x19, #4]
	strh	w10, [x19, #12]
	ldr	q0, [sp, #48]
	stur	q0, [x19, #14]
	strb	w8, [x19, #32]
LBB206_17:
	ldur	x8, [x29, #-56]
Lloh1587:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1588:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1589:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB206_23
	.cfi_def_cfa wsp, 144
	ldp	x29, x30, [sp, #128]
	ldp	x20, x19, [sp, #112]
	ldp	x22, x21, [sp, #96]
	ldp	x24, x23, [sp, #80]
	add	sp, sp, #144
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB206_19:
	.cfi_restore_state
	mov	x21, x0
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	strh	w21, [x19, #36]
	b	LBB206_17
LBB206_20:
	strh	w8, [x19, #36]
	b	LBB206_17
LBB206_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB206_22:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB206_23:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1584, Lloh1585, Lloh1586
	.loh AdrpLdrGotLdr	Lloh1587, Lloh1588, Lloh1589
	.cfi_endproc

	.p2align	2
l_Io.Threaded.netAcceptPosix:
	.cfi_startproc
	sub	sp, sp, #192
	.cfi_def_cfa_offset 192
	stp	x24, x23, [sp, #128]
	stp	x22, x21, [sp, #144]
	stp	x20, x19, [sp, #160]
	stp	x29, x30, [sp, #176]
	add	x29, sp, #176
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh1590:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1591:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1592:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB207_36
	tst	x0, #0x7
	b.ne	LBB207_37
	mov	x20, x1
	mov	x8, #-6148914691236517206
	stp	x8, x8, [sp, #56]
	str	x8, [sp, #48]
	str	w8, [sp, #72]
	mov	w8, #28
	str	w8, [sp, #20]
	add	x0, sp, #80
	bl	l_Io.Threaded.Syscall.start
	ldrh	w8, [sp, #88]
	cbnz	w8, LBB207_19
	ldr	x22, [sp, #80]
LBB207_4:
	add	x1, sp, #48
	add	x2, sp, #20
	mov	x0, x20
	bl	_accept
	mov	x21, x0
	cmn	w0, #1
	b.ne	LBB207_11
	bl	___error
	ldr	w23, [x0]
	tbnz	w23, #31, LBB207_35
	cmp	w23, #16, lsl #12
	b.hs	LBB207_35
	cmp	w23, #4
	b.ne	LBB207_9
	str	x22, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w8, w0, #0xffff
	b.eq	LBB207_4
	b	LBB207_19
LBB207_9:
	cbnz	w23, LBB207_16
	mov	w20, #-1
	b	LBB207_12
LBB207_11:
	mov	x20, x21
LBB207_12:
	str	x22, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	l_Io.Threaded.setCloexec
	tst	w0, #0xffff
	b.ne	LBB207_34
	strh	wzr, [x19, #36]
	str	w21, [x19]
	ldrb	w8, [sp, #49]
	cmp	w8, #30
	b.eq	LBB207_20
	cmp	w8, #2
	b.ne	LBB207_21
	mov	w8, #0
	ldrh	w9, [sp, #50]
	ldr	w10, [sp, #52]
	rev	w9, w9
	lsr	w9, w9, #16
	orr	x9, x9, x10, lsl #16
	b	LBB207_22
LBB207_16:
	str	x22, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w23, #1
	cmp	w8, #99
	b.hi	LBB207_18
Lloh1593:
	adrp	x9, LJTI207_0@PAGE
Lloh1594:
	add	x9, x9, LJTI207_0@PAGEOFF
	adr	x10, LBB207_18
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB207_18:
	mov	w8, #12
LBB207_19:
	strh	w8, [x19, #36]
	ldur	x8, [x29, #-56]
Lloh1595:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1596:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1597:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB207_24
	b	LBB207_33
LBB207_20:
	ldrh	w8, [sp, #50]
	rev16	w10, w8
	ldr	w8, [sp, #52]
	ldr	w9, [sp, #72]
	orr	x9, x8, x9, lsl #32
	ldur	q0, [sp, #56]
	stur	q0, [x29, #-80]
	mov	w8, #1
	b	LBB207_23
LBB207_21:
	mov	w8, #0
	mov	x9, #8323072
	movk	x9, #256, lsl #32
LBB207_22:
LBB207_23:
	stur	x9, [x19, #4]
	strh	w10, [x19, #12]
	ldur	q0, [x29, #-80]
	stur	q0, [x19, #14]
	strb	w8, [x19, #32]
	ldur	x8, [x29, #-56]
Lloh1598:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1599:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1600:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB207_33
LBB207_24:
	.cfi_def_cfa wsp, 192
	ldp	x29, x30, [sp, #176]
	ldp	x20, x19, [sp, #160]
	ldp	x22, x21, [sp, #144]
	ldp	x24, x23, [sp, #128]
	add	sp, sp, #192
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB207_25:
	.cfi_restore_state
	mov	x8, #17179869184
	str	x8, [x19, #32]
Lloh1601:
	adrp	x8, l___anon_12067@PAGE
Lloh1602:
	add	x8, x8, l___anon_12067@PAGEOFF
	b	LBB207_32
LBB207_26:
	mov	x8, #98784247808
	str	x8, [x19, #32]
Lloh1603:
	adrp	x8, l___anon_12063@PAGE
Lloh1604:
	add	x8, x8, l___anon_12063@PAGEOFF
	b	LBB207_32
LBB207_27:
	mov	x8, #386547056640
	str	x8, [x19, #32]
Lloh1605:
	adrp	x8, l___anon_12071@PAGE
Lloh1606:
	add	x8, x8, l___anon_12071@PAGEOFF
	b	LBB207_32
LBB207_28:
	mov	x8, #382252089344
	str	x8, [x19, #32]
Lloh1607:
	adrp	x8, l___anon_12075@PAGE
Lloh1608:
	add	x8, x8, l___anon_12075@PAGEOFF
	b	LBB207_32
LBB207_29:
	mov	x8, #377957122048
	str	x8, [x19, #32]
Lloh1609:
	adrp	x8, l___anon_12057@PAGE
Lloh1610:
	add	x8, x8, l___anon_12057@PAGEOFF
	b	LBB207_32
LBB207_30:
	mov	x8, #103079215104
	str	x8, [x19, #32]
Lloh1611:
	adrp	x8, l___anon_12065@PAGE
Lloh1612:
	add	x8, x8, l___anon_12065@PAGEOFF
	b	LBB207_32
LBB207_31:
	mov	x8, #373662154752
	str	x8, [x19, #32]
Lloh1613:
	adrp	x8, l___anon_12061@PAGE
Lloh1614:
	add	x8, x8, l___anon_12061@PAGEOFF
LBB207_32:
	ldp	q0, q1, [x8]
	stp	q0, q1, [x19]
	ldur	x8, [x29, #-56]
Lloh1615:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1616:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1617:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB207_24
LBB207_33:
	bl	___stack_chk_fail
LBB207_34:
	mov	x20, x0
	mov	x0, x21
	bl	l_Io.Threaded.closeFd
	strh	w20, [x19, #36]
	ldur	x8, [x29, #-56]
Lloh1618:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1619:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1620:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB207_24
	b	LBB207_33
LBB207_35:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB207_36:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB207_37:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdrGotLdr	Lloh1590, Lloh1591, Lloh1592
	.loh AdrpAdd	Lloh1593, Lloh1594
	.loh AdrpLdrGotLdr	Lloh1595, Lloh1596, Lloh1597
	.loh AdrpLdrGotLdr	Lloh1598, Lloh1599, Lloh1600
	.loh AdrpAdd	Lloh1601, Lloh1602
	.loh AdrpAdd	Lloh1603, Lloh1604
	.loh AdrpAdd	Lloh1605, Lloh1606
	.loh AdrpAdd	Lloh1607, Lloh1608
	.loh AdrpAdd	Lloh1609, Lloh1610
	.loh AdrpAdd	Lloh1611, Lloh1612
	.loh AdrpAdd	Lloh1613, Lloh1614
	.loh AdrpLdrGotLdr	Lloh1615, Lloh1616, Lloh1617
	.loh AdrpLdrGotLdr	Lloh1618, Lloh1619, Lloh1620
	.cfi_endproc
	.section	__TEXT,__const
LJTI207_0:
	.byte	(LBB207_28-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_25-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_31-LBB207_18)>>2
	.byte	(LBB207_30-LBB207_18)>>2
	.byte	(LBB207_26-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_29-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_25-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_18-LBB207_18)>>2
	.byte	(LBB207_27-LBB207_18)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.netListenUnixPosix:
	.cfi_startproc
	sub	sp, sp, #304
	.cfi_def_cfa_offset 304
	stp	x28, x27, [sp, #224]
	stp	x24, x23, [sp, #240]
	stp	x22, x21, [sp, #256]
	stp	x20, x19, [sp, #272]
	stp	x29, x30, [sp, #288]
	add	x29, sp, #288
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_remember_state
	mov	x19, x8
Lloh1621:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1622:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1623:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-72]
	cbz	x0, LBB208_64
	tst	x0, #0x7
	b.ne	LBB208_65
	mov	x21, x1
	ldr	w23, [x2]
Lloh1624:
	adrp	x2, l___anon_11883@PAGE
Lloh1625:
	add	x2, x2, l___anon_11883@PAGEOFF
	mov	w22, #1
	add	x0, sp, #56
	mov	w1, #1
	bl	l_Io.Threaded.openSocketPosix
	ldrh	w8, [sp, #60]
	cbnz	w8, LBB208_54
	add	x8, sp, #64
	ldr	w20, [sp, #56]
	movi.16b	v0, #170
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #96]
	str	q0, [sp, #128]
	str	q0, [x8, #80]
	stur	q0, [x8, #90]
	strb	w22, [sp, #65]
	ldr	x22, [x21, #8]
	cmp	x22, #105
	b.hs	LBB208_67
	add	x8, sp, #64
	orr	x0, x8, #0x2
	ldr	x1, [x21]
	add	x21, x0, x22
	cmp	x1, x21
	b.hs	LBB208_6
	add	x8, x1, x22
	cmp	x0, x8
	b.lo	LBB208_68
LBB208_6:
	mov	x2, x22
	bl	_memcpy
	cmp	x22, #104
	b.eq	LBB208_57
	strb	wzr, [x21]
	add	w21, w22, #3
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w22, [x29, #-80]
	cbnz	w22, LBB208_48
LBB208_8:
	ldur	x24, [x29, #-88]
LBB208_9:
	add	x1, sp, #64
	mov	x0, x20
	mov	x2, x21
	bl	_bind
	cmn	w0, #1
	b.ne	LBB208_15
	bl	___error
	ldr	w22, [x0]
	tbnz	w22, #31, LBB208_63
	cmp	w22, #16, lsl #12
	b.hs	LBB208_63
	cmp	w22, #4
	b.ne	LBB208_14
	str	x24, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w22, w0, #0xffff
	b.eq	LBB208_9
	b	LBB208_48
LBB208_14:
	cbnz	w22, LBB208_27
LBB208_15:
	str	x24, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.finish
	sub	x0, x29, #104
	bl	l_Io.Threaded.Syscall.start
	ldurh	w21, [x29, #-96]
	cbnz	w21, LBB208_58
	ldur	x21, [x29, #-104]
LBB208_17:
	and	w1, w23, #0x7fffffff
	mov	x0, x20
	bl	_listen
	cmn	w0, #1
	b.ne	LBB208_26
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB208_63
	cmp	w8, #16, lsl #12
	b.hs	LBB208_63
	cmp	w8, #4
	b.ne	LBB208_23
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w22, w0, #0xffff
	b.eq	LBB208_17
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	b	LBB208_51
LBB208_23:
	cmp	w8, #48
	b.eq	LBB208_34
	cmp	w8, #9
	b.eq	LBB208_30
	cbnz	w8, LBB208_30
LBB208_26:
	str	x21, [sp, #16]
	add	x0, sp, #16
	bl	l_Io.Threaded.Syscall.finish
	str	w20, [x19]
	strh	wzr, [x19, #4]
	b	LBB208_52
LBB208_27:
	str	x24, [sp, #48]
	add	x0, sp, #48
	bl	l_Io.Threaded.Syscall.finish
	sub	w8, w22, #1
	cmp	w8, #61
	b.hi	LBB208_43
	mov	w22, #10
Lloh1626:
	adrp	x9, LJTI208_0@PAGE
Lloh1627:
	add	x9, x9, LJTI208_0@PAGEOFF
	adr	x10, LBB208_29
	ldrb	w11, [x9, x8]
	add	x10, x10, x11, lsl #2
	br	x10
LBB208_29:
	mov	w22, #18
	b	LBB208_48
LBB208_30:
	stur	x21, [x29, #-88]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB208_33
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB208_63
	cmp	w8, #16, lsl #12
	b.hs	LBB208_63
LBB208_33:
	mov	w8, #12
	b	LBB208_38
LBB208_34:
	stur	x21, [x29, #-88]
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB208_37
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB208_63
	cmp	w8, #16, lsl #12
	b.hs	LBB208_63
LBB208_37:
	mov	w8, #81
LBB208_38:
	strh	w8, [x19, #4]
	b	LBB208_52
LBB208_39:
	mov	w22, #39
	b	LBB208_48
LBB208_40:
	mov	w22, #41
	b	LBB208_48
LBB208_41:
	mov	w22, #32
	b	LBB208_48
LBB208_42:
	mov	w22, #81
	b	LBB208_48
LBB208_43:
	mov	w22, #12
	b	LBB208_48
LBB208_44:
	mov	w22, #4
	b	LBB208_48
LBB208_45:
	mov	w22, #40
	b	LBB208_48
LBB208_46:
	mov	w22, #37
	b	LBB208_48
LBB208_47:
	mov	w22, #82
LBB208_48:
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB208_51
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB208_63
	cmp	w8, #16, lsl #12
	b.hs	LBB208_63
LBB208_51:
	strh	w22, [x19, #4]
LBB208_52:
	ldur	x8, [x29, #-72]
Lloh1628:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1629:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1630:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB208_66
	.cfi_def_cfa wsp, 304
	ldp	x29, x30, [sp, #288]
	ldp	x20, x19, [sp, #272]
	ldp	x22, x21, [sp, #256]
	ldp	x24, x23, [sp, #240]
	ldp	x28, x27, [sp, #224]
	add	sp, sp, #304
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB208_54:
	.cfi_restore_state
	cmp	w8, #84
	b.gt	LBB208_59
	cmp	w8, #83
	b.eq	LBB208_62
	cmp	w8, #84
	b.eq	LBB208_62
	b	LBB208_38
LBB208_57:
	mov	w21, #106
	sub	x0, x29, #88
	bl	l_Io.Threaded.Syscall.start
	ldurh	w22, [x29, #-80]
	cbz	w22, LBB208_8
	b	LBB208_48
LBB208_58:
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	strh	w21, [x19, #4]
	b	LBB208_52
LBB208_59:
	cmp	w8, #85
	b.eq	LBB208_62
	cmp	w8, #86
	b.ne	LBB208_38
	mov	x8, #51539607552
	str	x8, [x19]
	b	LBB208_52
LBB208_62:
	mov	x8, #137438953472
	str	x8, [x19]
	b	LBB208_52
LBB208_63:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB208_64:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB208_65:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB208_66:
	bl	___stack_chk_fail
LBB208_67:
	mov	x0, x22
	mov	w1, #104
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB208_68:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpLdrGotLdr	Lloh1621, Lloh1622, Lloh1623
	.loh AdrpAdd	Lloh1624, Lloh1625
	.loh AdrpAdd	Lloh1626, Lloh1627
	.loh AdrpLdrGotLdr	Lloh1628, Lloh1629, Lloh1630
	.cfi_endproc
	.section	__TEXT,__const
LJTI208_0:
	.byte	(LBB208_29-LBB208_29)>>2
	.byte	(LBB208_39-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_44-LBB208_29)>>2
	.byte	(LBB208_48-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_45-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_40-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_41-LBB208_29)>>2
	.byte	(LBB208_42-LBB208_29)>>2
	.byte	(LBB208_47-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_43-LBB208_29)>>2
	.byte	(LBB208_46-LBB208_29)>>2

	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
l_Io.Threaded.netListenIpPosix:
	.cfi_startproc
	sub	sp, sp, #208
	.cfi_def_cfa_offset 208
	stp	x24, x23, [sp, #144]
	stp	x22, x21, [sp, #160]
	stp	x20, x19, [sp, #176]
	stp	x29, x30, [sp, #192]
	add	x29, sp, #192
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	mov	x19, x8
Lloh1631:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1632:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1633:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-56]
	cbz	x0, LBB209_43
	tst	x0, #0x7
	b.ne	LBB209_44
	mov	x21, x1
	ldp	w22, w8, [x2]
	ldrb	w23, [x2, #8]
	ldrb	w9, [x2, #9]
	ldrb	w10, [x1, #28]
	strh	wzr, [sp, #56]
	strb	wzr, [sp, #58]
	and	w9, w9, #0x7
	strb	w9, [sp, #59]
	str	w8, [sp, #48]
	mov	w8, #1
	strb	w8, [sp, #52]
	tst	w10, #0x1
	mov	w8, #2
	mov	w9, #30
	csel	w1, w9, w8, ne
	add	x0, sp, #60
	add	x2, sp, #48
	bl	l_Io.Threaded.openSocketPosix
	ldrh	w8, [sp, #64]
	cbnz	w8, LBB209_33
	ldr	w20, [sp, #60]
	tbz	w23, #0, LBB209_6
	mov	x0, x20
	mov	w1, #65535
	mov	w2, #4
	mov	w3, #1
	bl	l_Io.Threaded.setSocketOptionPosix
	tst	w0, #0xffff
	b.ne	LBB209_40
	mov	x0, x20
	mov	w1, #65535
	mov	w2, #512
	mov	w3, #1
	bl	l_Io.Threaded.setSocketOptionPosix
	tst	w0, #0xffff
	b.ne	LBB209_40
LBB209_6:
	add	x23, sp, #68
	mov	x8, #-6148914691236517206
	stur	x8, [sp, #84]
	stur	x8, [sp, #76]
	str	w8, [sp, #92]
	ldrb	w8, [x21, #28]
	tbz	w8, #0, LBB209_8
	ldrh	w8, [x21, #8]
	rev16	w9, w8
	ldp	w8, w10, [x21]
	ldur	q0, [x21, #10]
	stur	q0, [x23, #8]
	str	w10, [sp, #92]
	mov	w2, #28
	mov	w10, #30
	b	LBB209_9
LBB209_8:
	ldur	w8, [x21, #2]
	ldrh	w9, [x21]
	rev16	w9, w9
	stur	xzr, [sp, #76]
	mov	w2, #16
	mov	w10, #2
LBB209_9:
	strb	w2, [sp, #68]
	strb	w10, [sp, #69]
	strh	w9, [sp, #70]
	str	w8, [sp, #72]
	str	w2, [sp, #20]
	add	x1, sp, #68
	mov	x0, x20
	bl	l_Io.Threaded.posixBind
	tst	w0, #0xffff
	b.ne	LBB209_40
	add	x0, sp, #96
	bl	l_Io.Threaded.Syscall.start
	ldrh	w21, [sp, #104]
	cbnz	w21, LBB209_41
	ldr	x21, [sp, #96]
LBB209_12:
	and	w1, w22, #0x7fffffff
	mov	x0, x20
	bl	_listen
	cmn	w0, #1
	b.ne	LBB209_21
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB209_42
	cmp	w8, #16, lsl #12
	b.hs	LBB209_42
	cmp	w8, #4
	b.ne	LBB209_18
	str	x21, [sp, #32]
	add	x0, sp, #32
	bl	l_Io.Threaded.Syscall.checkCancel
	ands	w24, w0, #0xffff
	b.eq	LBB209_12
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	strh	w24, [x19, #36]
	ldur	x8, [x29, #-56]
Lloh1634:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1635:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1636:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB209_34
	b	LBB209_39
LBB209_18:
	cmp	w8, #48
	b.eq	LBB209_29
	cmp	w8, #9
	b.eq	LBB209_25
	cbnz	w8, LBB209_25
LBB209_21:
	str	x21, [sp, #24]
	add	x0, sp, #24
	bl	l_Io.Threaded.Syscall.finish
	add	x1, sp, #68
	add	x2, sp, #20
	mov	x0, x20
	bl	l_Io.Threaded.posixGetSockName
	tst	w0, #0xffff
	b.ne	LBB209_40
	strh	wzr, [x19, #36]
	str	w20, [x19]
	ldrb	w8, [sp, #69]
	cmp	w8, #30
	b.eq	LBB209_35
	cmp	w8, #2
	b.ne	LBB209_36
	mov	w8, #0
	ldrh	w9, [sp, #70]
	ldr	w10, [sp, #72]
	rev	w9, w9
	lsr	w9, w9, #16
	orr	x9, x9, x10, lsl #16
	b	LBB209_37
LBB209_25:
	str	x21, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB209_28
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB209_42
	cmp	w8, #16, lsl #12
	b.hs	LBB209_42
LBB209_28:
	mov	w8, #12
	b	LBB209_33
LBB209_29:
	str	x21, [sp, #40]
	add	x0, sp, #40
	bl	l_Io.Threaded.Syscall.finish
	mov	x0, x20
	bl	_close$NOCANCEL
	cmn	w0, #1
	b.ne	LBB209_32
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB209_42
	cmp	w8, #16, lsl #12
	b.hs	LBB209_42
LBB209_32:
	mov	w8, #81
LBB209_33:
	strh	w8, [x19, #36]
	ldur	x8, [x29, #-56]
Lloh1637:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1638:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1639:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB209_39
LBB209_34:
	.cfi_def_cfa wsp, 208
	ldp	x29, x30, [sp, #192]
	ldp	x20, x19, [sp, #176]
	ldp	x22, x21, [sp, #160]
	ldp	x24, x23, [sp, #144]
	add	sp, sp, #208
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB209_35:
	.cfi_restore_state
	ldrh	w8, [sp, #70]
	rev16	w10, w8
	ldr	w8, [sp, #72]
	ldr	w9, [sp, #92]
	orr	x9, x8, x9, lsl #32
	ldur	q0, [x23, #8]
	stur	q0, [x29, #-80]
	mov	w8, #1
	b	LBB209_38
LBB209_36:
	mov	w8, #0
	mov	x9, #8323072
	movk	x9, #256, lsl #32
LBB209_37:
LBB209_38:
	stur	x9, [x19, #4]
	strh	w10, [x19, #12]
	ldur	q0, [x29, #-80]
	stur	q0, [x19, #14]
	strb	w8, [x19, #32]
	ldur	x8, [x29, #-56]
Lloh1640:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1641:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1642:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB209_34
LBB209_39:
	bl	___stack_chk_fail
LBB209_40:
	mov	x21, x0
LBB209_41:
	mov	x0, x20
	bl	l_Io.Threaded.closeFd
	strh	w21, [x19, #36]
	ldur	x8, [x29, #-56]
Lloh1643:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1644:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1645:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB209_34
	b	LBB209_39
LBB209_42:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB209_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).castToNull"
LBB209_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
	.loh AdrpLdrGotLdr	Lloh1631, Lloh1632, Lloh1633
	.loh AdrpLdrGotLdr	Lloh1634, Lloh1635, Lloh1636
	.loh AdrpLdrGotLdr	Lloh1637, Lloh1638, Lloh1639
	.loh AdrpLdrGotLdr	Lloh1640, Lloh1641, Lloh1642
	.loh AdrpLdrGotLdr	Lloh1643, Lloh1644, Lloh1645
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
	mov	x3, x2
	mov	x2, x1
	mov	x1, x3
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_simd_candidates.maskCopy__func_282
	.cfi_endproc

	.p2align	2
l_simd_candidates.maskCopy__func_282:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cmp	x1, x3
	b.ne	LBB211_16
	mov	x9, #0
	mov	x10, #-35747867511423104
	movk	x10, #25361
	movk	x10, #25361, lsl #32
	mov	x8, x1
LBB211_2:
	cmp	x8, #7
	b.ls	LBB211_7
	add	x8, x9, #8
	cmp	x8, x1
	b.hi	LBB211_15
	ldr	x11, [x2, x9]
	eor	x11, x11, x10
	str	x11, [x0, x9]
	cmn	x9, #8
	b.eq	LBB211_6
	mov	x9, x8
	subs	x8, x1, x8
	b.hs	LBB211_2
LBB211_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB211_7:
	cmp	x1, x9
	b.ls	LBB211_14
	mvn	x8, x9
	add	x8, x8, x1
	mov	x10, #-3689348814741910324
	movk	x10, #52429
	umulh	x10, x8, x10
	lsr	x10, x10, #2
	add	x10, x10, x10, lsl #2
	sub	x10, x8, x10
	add	x10, x10, #1
	cmp	x10, #5
	b.eq	LBB211_11
Lloh1646:
	adrp	x11, l___anon_203@PAGE
Lloh1647:
	add	x11, x11, l___anon_203@PAGEOFF
LBB211_10:
	and	x12, x9, #0x3
	ldrb	w13, [x2, x9]
	ldrb	w12, [x11, x12]
	eor	w12, w12, w13
	strb	w12, [x0, x9]
	add	x9, x9, #1
	subs	x10, x10, #1
	b.ne	LBB211_10
LBB211_11:
	cmp	x8, #4
	b.lo	LBB211_14
	add	x8, x0, #4
Lloh1648:
	adrp	x10, l___anon_203@PAGE
Lloh1649:
	add	x10, x10, l___anon_203@PAGEOFF
LBB211_13:
	add	w11, w9, #2
	add	x12, x8, x9
	and	x11, x11, #0x3
	eor	x13, x11, #0x2
	add	x14, x2, x9
	ldrb	w15, [x14]
	ldrb	w13, [x10, x13]
	eor	w15, w13, w15
	sturb	w15, [x12, #-4]
	sub	w15, w9, #1
	add	x9, x9, #5
	and	x16, x9, #0x3
	ldrb	w17, [x14, #1]
	ldrb	w16, [x10, x16]
	eor	w16, w16, w17
	sturb	w16, [x12, #-3]
	ldrb	w16, [x14, #2]
	ldrb	w11, [x10, x11]
	eor	w11, w11, w16
	sturb	w11, [x12, #-2]
	and	x11, x15, #0x3
	ldrb	w15, [x14, #3]
	ldrb	w11, [x10, x11]
	eor	w11, w11, w15
	sturb	w11, [x12, #-1]
	ldrb	w11, [x14, #4]
	eor	w11, w11, w13
	strb	w11, [x12]
	cmp	x1, x9
	b.ne	LBB211_13
LBB211_14:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB211_15:
	.cfi_restore_state
	mov	x0, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB211_16:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpAdd	Lloh1646, Lloh1647
	.loh AdrpAdd	Lloh1648, Lloh1649
	.cfi_endproc

	.p2align	2
l_Io.Writer.Allocating.drain:
	.cfi_startproc
	stp	x26, x25, [sp, #-80]!
	.cfi_def_cfa_offset 80
	stp	x24, x23, [sp, #16]
	stp	x22, x21, [sp, #32]
	stp	x20, x19, [sp, #48]
	stp	x29, x30, [sp, #64]
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	cbz	x2, LBB212_34
	mov	x20, x3
	mov	x19, x8
	mov	x8, #0
	subs	x23, x2, #1
	b.eq	LBB212_5
	add	x9, x1, #8
	mov	x10, x23
LBB212_3:
	ldr	x11, [x9], #16
	adds	x8, x8, x11
	b.hs	LBB212_31
	subs	x10, x10, #1
	b.ne	LBB212_3
LBB212_5:
	add	x25, x1, x23, lsl #4
	ldr	x9, [x25, #8]
	umulh	x10, x9, x20
	cmp	xzr, x10
	b.ne	LBB212_31
	mul	x9, x9, x20
	adds	x24, x8, x9
	b.hs	LBB212_31
	adds	x8, x24, #1
	b.hs	LBB212_31
	sub	x21, x0, #16
	ldr	x9, [x21, #40]
	adds	x8, x9, x8
	b.hs	LBB212_11
	ldr	x9, [x21, #32]
	cmp	x9, x8
	b.hs	LBB212_12
	lsr	x9, x8, #1
	add	x9, x9, #128
	adds	x8, x8, x9
	csinv	x8, x8, xzr, lo
	mov	x0, x21
	mov	x22, x1
	mov	x1, x8
	bl	l_Io.Writer.Allocating.ensureTotalCapacityPrecise
	mov	x1, x22
	tst	w0, #0xffff
	b.eq	LBB212_12
LBB212_11:
Lloh1650:
	adrp	x8, l___anon_12268@PAGE
Lloh1651:
	add	x8, x8, l___anon_12268@PAGEOFF
Lloh1652:
	ldr	q0, [x8]
	str	q0, [x19]
	.cfi_def_cfa wsp, 80
	b	LBB212_30
LBB212_12:
	.cfi_restore_state
	.cfi_remember_state
	cbz	x23, LBB212_18
	ldr	x8, [x21, #40]
	add	x26, x1, #8
LBB212_14:
	ldr	x22, [x26]
	ldr	x1, [x21, #32]
	add	x0, x22, x8
	cmp	x0, x1
	b.hi	LBB212_32
	ldur	x1, [x26, #-8]
	ldr	x9, [x21, #24]
	add	x0, x9, x8
	add	x8, x0, x22
	add	x9, x1, x22
	cmp	x0, x9
	ccmp	x1, x8, #2, lo
	b.lo	LBB212_33
	mov	x2, x22
	bl	_memcpy
	ldr	x8, [x21, #40]
	adds	x8, x8, x22
	b.hs	LBB212_31
	add	x26, x26, #16
	str	x8, [x21, #40]
	subs	x23, x23, #1
	b.ne	LBB212_14
LBB212_18:
	ldr	x23, [x25, #8]
	cbz	x23, LBB212_29
	ldr	x22, [x25]
	cmp	x23, #1
	b.ne	LBB212_23
	ldp	x1, x8, [x21, #32]
	add	x0, x8, x20
	cmp	x0, x1
	b.hi	LBB212_32
	ldr	x9, [x21, #24]
	ldrb	w1, [x22]
	add	x0, x9, x8
	mov	x2, x20
	bl	_memset
	ldr	x8, [x21, #40]
	adds	x8, x8, x20
	b.hs	LBB212_31
	str	x8, [x21, #40]
	b	LBB212_29
LBB212_23:
	cbz	x20, LBB212_29
	add	x25, x22, x23
	ldr	x8, [x21, #40]
LBB212_25:
	ldr	x1, [x21, #32]
	add	x0, x8, x23
	cmp	x0, x1
	b.hi	LBB212_32
	ldr	x9, [x21, #24]
	add	x0, x9, x8
	add	x8, x0, x23
	cmp	x0, x25
	ccmp	x22, x8, #2, lo
	b.lo	LBB212_33
	mov	x1, x22
	mov	x2, x23
	bl	_memcpy
	ldr	x8, [x21, #40]
	adds	x8, x8, x23
	b.hs	LBB212_31
	str	x8, [x21, #40]
	subs	x20, x20, #1
	b.ne	LBB212_25
LBB212_29:
	str	x24, [x19]
	strh	wzr, [x19, #8]
	.cfi_def_cfa wsp, 80
LBB212_30:
	ldp	x29, x30, [sp, #64]
	ldp	x20, x19, [sp, #48]
	ldp	x22, x21, [sp, #32]
	ldp	x24, x23, [sp, #16]
	ldp	x26, x25, [sp], #80
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB212_31:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB212_32:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB212_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB212_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpAddLdr	Lloh1650, Lloh1651, Lloh1652
	.cfi_endproc

	.p2align	2
l_Io.Writer.Allocating.growingRebase:
	.cfi_startproc
	adds	x8, x1, x2
	b.lo	LBB213_2
	mov	w0, #102
	ret
LBB213_2:
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	sub	x19, x0, #16
	ldr	x9, [x0, #16]
	cmp	x9, x8
	b.hs	LBB213_4
	lsr	x9, x8, #1
	add	x9, x9, #128
	adds	x8, x8, x9
	csinv	x1, x8, xzr, lo
	mov	x0, x19
	mov	x20, x2
	bl	l_Io.Writer.Allocating.ensureTotalCapacityPrecise
	mov	x2, x20
	tst	w0, #0xffff
	b.ne	LBB213_7
LBB213_4:
	ldr	x8, [x19, #40]
	adds	x8, x8, x2
	b.hs	LBB213_7
	ldr	x9, [x19, #32]
	cmp	x9, x8
	b.hs	LBB213_8
	lsr	x9, x8, #1
	add	x9, x9, #128
	adds	x8, x8, x9
	csinv	x1, x8, xzr, lo
	mov	x0, x19
	bl	l_Io.Writer.Allocating.ensureTotalCapacityPrecise
	tst	w0, #0xffff
	b.eq	LBB213_8
LBB213_7:
	mov	w0, #102
	b	LBB213_9
LBB213_8:
	mov	w0, #0
LBB213_9:
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
	.cfi_endproc

	.p2align	2
l_Io.Writer.Allocating.sendFile:
	.cfi_startproc
	sub	sp, sp, #240
	.cfi_def_cfa_offset 240
	stp	x26, x25, [sp, #160]
	stp	x24, x23, [sp, #176]
	stp	x22, x21, [sp, #192]
	stp	x20, x19, [sp, #208]
	stp	x29, x30, [sp, #224]
	add	x29, sp, #224
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_remember_state
	mov	x19, x8
Lloh1653:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1654:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1655:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-72]
	cbz	x2, LBB214_7
	mov	x20, x1
	ldp	x8, x9, [x1, #64]
	subs	x8, x9, x8
	b.lo	LBB214_44
	ldr	x9, [x20, #16]
	subs	x23, x9, x8
	b.lo	LBB214_44
	ldrb	w8, [x20, #32]
	tbz	w8, #0, LBB214_9
	ldr	x8, [x20, #24]
	subs	x8, x8, x23
	b.lo	LBB214_44
LBB214_5:
	cbz	x8, LBB214_36
	mov	w23, #1
	sub	x21, x0, #16
	cmp	x8, x2
	csel	x22, x8, x2, lo
	ldr	x0, [x21, #40]
	adds	x8, x0, x22
	b.lo	LBB214_17
	b	LBB214_19
LBB214_7:
	stp	xzr, xzr, [x19]
	ldur	x8, [x29, #-72]
Lloh1656:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1657:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1658:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB214_48
	.cfi_def_cfa wsp, 240
	b	LBB214_39
LBB214_9:
	.cfi_restore_state
	.cfi_remember_state
	ldrh	w8, [x20, #90]
	cbnz	w8, LBB214_16
	mov	x21, x0
	mov	x22, x2
	ldr	x8, [x20, #80]
	str	x8, [sp, #16]
	ldp	x0, x8, [x20]
	ldr	x9, [x8, #360]
	add	x8, sp, #32
	add	x1, sp, #16
	blr	x9
	ldrh	w8, [sp, #128]
	cbnz	w8, LBB214_15
	ldrb	w8, [sp, #120]
	and	w8, w8, #0xf
	cmp	w8, #5
	b.ne	LBB214_13
	ldr	x8, [sp, #104]
	str	x8, [x20, #24]
	mov	w9, #1
	strb	w9, [x20, #32]
	mov	x2, x22
	mov	x0, x21
	subs	x8, x8, x23
	b.hs	LBB214_5
	b	LBB214_44
LBB214_13:
	ldrb	w8, [x20, #94]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB214_49
	and	w8, w8, #0x7
	add	w8, w8, w8, lsl #1
	mov	w9, #4
	movk	w9, #72, lsl #16
	lsr	w8, w9, w8
	and	w8, w8, #0x7
	strb	w8, [x20, #94]
	mov	w8, #48
LBB214_15:
	strh	w8, [x20, #90]
	mov	x2, x22
	mov	x0, x21
LBB214_16:
	mov	w23, #0
	mov	w8, #128
	sub	x21, x0, #16
	cmp	x8, x2
	csel	x22, x8, x2, lo
	ldr	x0, [x21, #40]
	adds	x8, x0, x22
	b.hs	LBB214_19
LBB214_17:
	ldr	x1, [x21, #32]
	cmp	x1, x8
	b.hs	LBB214_21
	lsr	x9, x8, #1
	add	x9, x9, #128
	adds	x8, x8, x9
	csinv	x1, x8, xzr, lo
	mov	x0, x21
	mov	x24, x2
	bl	l_Io.Writer.Allocating.ensureTotalCapacityPrecise
	tst	w0, #0xffff
	b.eq	LBB214_20
LBB214_19:
Lloh1659:
	adrp	x8, l___anon_12268@PAGE
Lloh1660:
	add	x8, x8, l___anon_12268@PAGEOFF
	b	LBB214_37
LBB214_20:
	mov	x2, x24
	ldp	x1, x0, [x21, #32]
LBB214_21:
	subs	x8, x1, x0
	b.lo	LBB214_50
	ldr	x10, [x21, #24]
	tbz	w23, #0, LBB214_25
	cmp	x22, x8
	b.ls	LBB214_26
	mov	x0, x22
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB214_25:
	cmp	x8, x2
	csel	x22, x8, x2, lo
LBB214_26:
	ldp	x8, x1, [x20, #64]
	subs	x25, x1, x8
	b.lo	LBB214_51
	ldr	x9, [x20, #56]
	cmp	x1, x9
	b.hi	LBB214_52
	ldr	x9, [x20, #48]
	cmp	x22, x25
	csel	x23, x22, x25, lo
	add	x1, x9, x8
	add	x8, x1, x23
	add	x24, x10, x0
	cmp	x24, x8
	b.hs	LBB214_30
	add	x8, x24, x23
	cmp	x1, x8
	b.lo	LBB214_53
LBB214_30:
	mov	x0, x24
	mov	x2, x23
	bl	_memcpy
	ldr	x8, [x20, #64]
	adds	x8, x8, x23
	b.hs	LBB214_44
	str	x8, [x20, #64]
	cmp	x22, x25
	b.hi	LBB214_40
LBB214_32:
	mov	x23, x22
LBB214_33:
	cbz	x23, LBB214_36
	ldr	x8, [x21, #40]
	adds	x8, x8, x23
	b.hs	LBB214_44
	str	x8, [x21, #40]
	str	x23, [x19]
	strh	wzr, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh1661:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1662:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1663:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB214_38
	b	LBB214_48
LBB214_36:
Lloh1664:
	adrp	x8, l___anon_12314@PAGE
Lloh1665:
	add	x8, x8, l___anon_12314@PAGEOFF
LBB214_37:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-72]
Lloh1666:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1667:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1668:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB214_48
LBB214_38:
	.cfi_def_cfa wsp, 240
LBB214_39:
	ldp	x29, x30, [sp, #224]
	ldp	x20, x19, [sp, #208]
	ldp	x22, x21, [sp, #192]
	ldp	x24, x23, [sp, #176]
	ldp	x26, x25, [sp, #160]
	add	sp, sp, #240
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	ret
LBB214_40:
	.cfi_restore_state
	add	x8, x24, x23
	sub	x9, x22, x23
	stp	x8, x9, [sp, #16]
	add	x0, sp, #32
	add	x1, x20, #40
	add	x2, sp, #16
	bl	l_Io.Reader.readVec
	ldrh	w8, [sp, #40]
	cbnz	w8, LBB214_45
	ldr	x8, [sp, #32]
	adds	x23, x23, x8
	b.hs	LBB214_44
	cmp	x22, x23
	b.lo	LBB214_44
	cmp	x22, x23
	b.ne	LBB214_40
	b	LBB214_32
LBB214_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB214_45:
	cmp	w8, #13
	b.eq	LBB214_33
	cmp	w8, #60
	b.ne	LBB214_49
	strh	w8, [x19, #8]
	ldur	x8, [x29, #-72]
Lloh1669:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1670:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1671:
	ldr	x9, [x9]
	cmp	x9, x8
	b.eq	LBB214_38
LBB214_48:
	bl	___stack_chk_fail
LBB214_49:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB214_50:
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB214_51:
	mov	x0, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB214_52:
	mov	x0, x1
	mov	x1, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB214_53:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
	.loh AdrpLdrGotLdr	Lloh1653, Lloh1654, Lloh1655
	.loh AdrpLdrGotLdr	Lloh1656, Lloh1657, Lloh1658
	.loh AdrpAdd	Lloh1659, Lloh1660
	.loh AdrpLdrGotLdr	Lloh1661, Lloh1662, Lloh1663
	.loh AdrpAdd	Lloh1664, Lloh1665
	.loh AdrpLdrGotLdr	Lloh1666, Lloh1667, Lloh1668
	.loh AdrpLdrGotLdr	Lloh1669, Lloh1670, Lloh1671
	.cfi_endproc

	.p2align	2
l_Io.Reader.readVec:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x28, x27, [sp, #32]
	stp	x26, x25, [sp, #48]
	stp	x24, x23, [sp, #64]
	stp	x22, x21, [sp, #80]
	stp	x20, x19, [sp, #96]
	stp	x29, x30, [sp, #112]
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_remember_state
	mov	x22, x1
Lloh1672:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1673:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1674:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	ldp	x23, x1, [x1, #24]
	subs	x26, x1, x23
	b.lo	LBB215_24
	ldr	x8, [x22, #16]
	cmp	x1, x8
	b.hi	LBB215_25
	mov	x20, x2
	ldp	x21, x25, [x2]
	ldr	x8, [x22, #8]
	cmp	x26, x25
	csel	x24, x26, x25, lo
	add	x1, x8, x23
	add	x8, x1, x24
	add	x27, x21, x24
	cmp	x21, x8
	ccmp	x1, x27, #2, lo
	b.lo	LBB215_26
	mov	x19, x0
	mov	x0, x21
	mov	x2, x24
	bl	_memcpy
	adds	x8, x23, x24
	b.hs	LBB215_20
	ldr	x9, [x22, #24]
	subs	x23, x8, x9
	cset	w9, lo
	cmp	x25, x26
	b.ls	LBB215_9
	cbnz	w9, LBB215_20
	str	x8, [x22, #24]
	sub	x8, x25, x24
	stp	x27, x8, [x20]
	ldr	x8, [x22]
	ldr	x9, [x8, #16]
	add	x8, sp, #8
	mov	x0, x22
	mov	x1, x20
	mov	w2, #1
	blr	x9
	ldrh	w8, [sp, #16]
	cbnz	w8, LBB215_14
	ldr	x8, [sp, #8]
	adds	x8, x23, x8
	b.hs	LBB215_20
LBB215_8:
	stp	x21, x25, [x20]
	str	x8, [x19]
	b	LBB215_11
LBB215_9:
	tbnz	w9, #0, LBB215_20
	str	x8, [x22, #24]
	str	x23, [x19]
LBB215_11:
	strh	wzr, [x19, #8]
	ldr	x8, [sp, #24]
Lloh1675:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1676:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1677:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB215_27
	.cfi_def_cfa wsp, 128
LBB215_13:
	ldp	x29, x30, [sp, #112]
	ldp	x20, x19, [sp, #96]
	ldp	x22, x21, [sp, #80]
	ldp	x24, x23, [sp, #64]
	ldp	x26, x25, [sp, #48]
	ldp	x28, x27, [sp, #32]
	add	sp, sp, #128
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	ret
LBB215_14:
	.cfi_restore_state
	.cfi_remember_state
	cmp	w8, #13
	b.eq	LBB215_18
	cmp	w8, #60
	b.ne	LBB215_21
	adrp	x8, l___anon_12315@PAGE
	add	x8, x8, l___anon_12315@PAGEOFF
	stp	x21, x25, [x20]
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh1678:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1679:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1680:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB215_27
	.cfi_def_cfa wsp, 128
	b	LBB215_13
LBB215_18:
	.cfi_restore_state
	.cfi_remember_state
	cbz	x23, LBB215_22
	mov	x8, #0
	adds	x8, x23, x8
	b.lo	LBB215_8
LBB215_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB215_21:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB215_22:
	adrp	x8, l___anon_12314@PAGE
	add	x8, x8, l___anon_12314@PAGEOFF
	stp	x21, x25, [x20]
	ldr	q0, [x8]
	str	q0, [x19]
	ldr	x8, [sp, #24]
Lloh1681:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1682:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1683:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB215_27
	.cfi_def_cfa wsp, 128
	b	LBB215_13
LBB215_24:
	.cfi_restore_state
	mov	x0, x23
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
LBB215_25:
	mov	x0, x1
	mov	x1, x8
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB215_26:
	bl	"l_debug.FullPanic((function 'defaultPanic')).memcpyAlias"
LBB215_27:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1672, Lloh1673, Lloh1674
	.loh AdrpLdrGotLdr	Lloh1675, Lloh1676, Lloh1677
	.loh AdrpLdrGotLdr	Lloh1678, Lloh1679, Lloh1680
	.loh AdrpLdrGotLdr	Lloh1681, Lloh1682, Lloh1683
	.cfi_endproc

	.p2align	2
"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_287":
	.cfi_startproc
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, #7
	bics	wzr, w8, w0
	b.ne	LBB216_2
	bl	"l_debug.FullPanic((function 'defaultPanic')).invalidEnumValue"
LBB216_2:
	bl	"l___zig_tag_name_@typeInfo(Io.Operation).@\"union\".tag_type.?"
Lloh1684:
	adrp	x8, l___unnamed_5@PAGE
Lloh1685:
	add	x8, x8, l___unnamed_5@PAGEOFF
	mov	w9, #20
	stp	x8, x9, [sp]
	stp	x0, x1, [sp, #16]
	mov	x0, sp
	bl	l_debug.panicExtra__func_257
	.loh AdrpAdd	Lloh1684, Lloh1685
	.cfi_endproc

	.p2align	2
"l___zig_tag_name_@typeInfo(Io.Operation).@\"union\".tag_type.?":
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	and	w8, w0, #0x7
Lloh1686:
	adrp	x9, l___unnamed_6@PAGE
Lloh1687:
	add	x9, x9, l___unnamed_6@PAGEOFF
	mov	w10, #19
Lloh1688:
	adrp	x11, l___unnamed_7@PAGE
Lloh1689:
	add	x11, x11, l___unnamed_7@PAGEOFF
	mov	w12, #8
	cmp	w8, #5
Lloh1690:
	adrp	x13, l___unnamed_8@PAGE
Lloh1691:
	add	x13, x13, l___unnamed_8@PAGEOFF
	mov	w14, #8
Lloh1692:
	adrp	x15, l___unnamed_9@PAGE
Lloh1693:
	add	x15, x15, l___unnamed_9@PAGEOFF
	mov	w16, #9
	csel	x13, x13, x15, eq
	csel	x14, x14, x16, eq
	cmp	w8, #4
	csel	x11, x11, x13, eq
	csel	x12, x12, x14, eq
	cmp	w8, #2
Lloh1694:
	adrp	x13, l___unnamed_10@PAGE
Lloh1695:
	add	x13, x13, l___unnamed_10@PAGEOFF
	mov	w14, #17
Lloh1696:
	adrp	x15, l___unnamed_11@PAGE
Lloh1697:
	add	x15, x15, l___unnamed_11@PAGEOFF
	mov	w16, #11
	csel	x13, x13, x15, eq
	csel	x14, x14, x16, eq
	cmp	w8, #0
	csel	x9, x9, x13, eq
	csel	x10, x10, x14, eq
	cmp	w8, #3
	csel	x0, x11, x9, gt
	csel	x1, x12, x10, gt
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.loh AdrpAdd	Lloh1696, Lloh1697
	.loh AdrpAdd	Lloh1694, Lloh1695
	.loh AdrpAdd	Lloh1692, Lloh1693
	.loh AdrpAdd	Lloh1690, Lloh1691
	.loh AdrpAdd	Lloh1688, Lloh1689
	.loh AdrpAdd	Lloh1686, Lloh1687
	.cfi_endproc

	.p2align	2
l_heap.PageAllocator.alloc:
	.cfi_startproc
	stp	x24, x23, [sp, #-64]!
	.cfi_def_cfa_offset 64
	stp	x22, x21, [sp, #16]
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_remember_state
	cbz	x1, LBB218_30
	mov	x8, #-16386
	cmp	x1, x8
	b.ls	LBB218_3
	mov	x0, #0
	b	LBB218_29
LBB218_3:
	mov	x20, x2
	mov	w8, #1
	lsl	x23, x8, x2
	mov	w8, #16383
	add	x8, x1, x8
	and	x21, x8, #0xffffffffffffc000
	subs	x8, x23, #4, lsl #12
	csel	x8, xzr, x8, lo
	adds	x19, x21, x8
	b.hs	LBB218_31
Lloh1698:
	adrp	x9, l_heap.PageAllocator.addr_hint@PAGE
Lloh1699:
	ldr	x22, [x9, l_heap.PageAllocator.addr_hint@PAGEOFF]
	cbz	x22, LBB218_6
	sub	x9, x22, x21
	neg	x10, x23
	and	x9, x9, x10
	sub	x0, x9, x8
	tst	x0, #0x3fff
	b.eq	LBB218_7
	b	LBB218_32
LBB218_6:
	mov	x0, #0
LBB218_7:
	mov	x1, x19
	mov	w2, #3
	mov	w3, #4098
	mov	w4, #-1
	mov	x5, #0
	bl	_mmap
	cmn	x0, #1
	b.eq	LBB218_11
	mov	x8, x0
	tst	x0, #0x3fff
	b.ne	LBB218_32
	and	w9, w20, #0x3f
	cmp	w9, #15
	b.hs	LBB218_16
	mov	x20, #0
	b	LBB218_18
LBB218_11:
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB218_34
	cmp	w8, #16, lsl #12
	b.hs	LBB218_34
	mov	x0, #0
	cmp	w8, #21
	b.gt	LBB218_27
	cbz	w8, LBB218_30
	cmp	w8, #9
	b.ne	LBB218_29
	b	LBB218_30
LBB218_16:
	sub	x9, x23, #1
	adds	x9, x8, x9
	b.hs	LBB218_33
	neg	x10, x23
	and	x9, x9, x10
	subs	x20, x9, x8
	b.lo	LBB218_31
LBB218_18:
	add	x0, x8, x20
	tst	x0, #0x3fff
	b.ne	LBB218_32
	cbz	x8, LBB218_33
	cbz	x20, LBB218_23
	add	x23, x8, x20
	cmp	x20, x19
	b.hi	LBB218_35
	mov	x0, x8
	mov	x1, x20
	bl	l_posix.munmap
	mov	x0, x23
LBB218_23:
	subs	x8, x19, x20
	b.lo	LBB218_31
	cmp	x8, x21
	b.ls	LBB218_26
	sub	x1, x8, x21
	mov	x19, x0
	add	x0, x0, x21
	bl	l_posix.munmap
	mov	x0, x19
LBB218_26:
Lloh1700:
	adrp	x8, l_heap.PageAllocator.addr_hint@PAGE
Lloh1701:
	add	x8, x8, l_heap.PageAllocator.addr_hint@PAGEOFF
	cas	x22, x0, [x8]
	b	LBB218_29
LBB218_27:
	cmp	w8, #22
	b.eq	LBB218_30
	cmp	w8, #84
	b.eq	LBB218_30
LBB218_29:
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	ldp	x22, x21, [sp, #16]
	ldp	x24, x23, [sp], #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	ret
LBB218_30:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB218_31:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB218_32:
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB218_33:
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB218_34:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
LBB218_35:
	mov	x0, x20
	mov	x1, x19
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdr	Lloh1698, Lloh1699
	.loh AdrpAdd	Lloh1700, Lloh1701
	.cfi_endproc

	.p2align	2
l_heap.PageAllocator.free:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x0, x1
	cbz	x2, LBB219_2
	and	x8, x0, #0x3fff
	cbnz	x8, LBB219_4
LBB219_2:
	mov	w8, #16383
	adds	x8, x2, x8
	b.hs	LBB219_5
	and	x1, x8, #0xffffffffffffc000
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_posix.munmap
LBB219_4:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB219_5:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_posix.munmap:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	bl	_munmap
	cmn	w0, #1
	b.ne	LBB220_4
	bl	___error
	ldr	w8, [x0]
	tbnz	w8, #31, LBB220_8
	cmp	w8, #16, lsl #12
	b.hs	LBB220_8
	cbnz	w8, LBB220_5
LBB220_4:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB220_5:
	.cfi_restore_state
	cmp	w8, #12
	b.eq	LBB220_7
	cmp	w8, #22
LBB220_7:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
LBB220_8:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOutOfBounds"
	.cfi_endproc

	.p2align	2
l_heap.PageAllocator.remap:
	.cfi_startproc
	stp	x20, x19, [sp, #-32]!
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	cbz	x2, LBB221_2
	and	x8, x1, #0x3fff
	cbnz	x8, LBB221_11
LBB221_2:
	and	w8, w3, #0x3f
	cmp	w8, #14
	b.ls	LBB221_4
LBB221_3:
	mov	x1, #0
	b	LBB221_10
LBB221_4:
	mov	w8, #16383
	adds	x8, x4, x8
	b.hs	LBB221_12
	mov	w9, #16383
	adds	x10, x2, x9
	b.hs	LBB221_12
	and	x9, x8, #0xffffffffffffc000
	and	x8, x10, #0xffffffffffffc000
	subs	x8, x8, x9
	b.eq	LBB221_10
	b.ls	LBB221_3
	add	x0, x1, x9
	tst	x0, #0x3fff
	b.ne	LBB221_11
	mov	x19, x1
	mov	x1, x8
	bl	l_posix.munmap
	mov	x1, x19
LBB221_10:
	mov	x0, x1
	.cfi_def_cfa wsp, 32
	ldp	x29, x30, [sp, #16]
	ldp	x20, x19, [sp], #32
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB221_11:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB221_12:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_heap.PageAllocator.resize:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	cbz	x2, LBB222_2
	and	x8, x1, #0x3fff
	cbnz	x8, LBB222_12
LBB222_2:
	and	w8, w3, #0x3f
	cmp	w8, #14
	b.ls	LBB222_4
LBB222_3:
	mov	w0, #0
	b	LBB222_11
LBB222_4:
	mov	w8, #16383
	adds	x8, x4, x8
	b.hs	LBB222_13
	mov	w9, #16383
	adds	x10, x2, x9
	b.hs	LBB222_13
	and	x9, x8, #0xffffffffffffc000
	and	x8, x10, #0xffffffffffffc000
	subs	x8, x8, x9
	b.eq	LBB222_10
	b.ls	LBB222_3
	add	x0, x1, x9
	tst	x0, #0x3fff
	b.ne	LBB222_12
	mov	x1, x8
	bl	l_posix.munmap
LBB222_10:
	mov	w0, #1
LBB222_11:
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB222_12:
	.cfi_restore_state
	bl	"l_debug.FullPanic((function 'defaultPanic')).incorrectAlignment"
LBB222_13:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
	.cfi_endproc

	.p2align	2
l_Io.File.Writer.drain:
	.cfi_startproc
	sub	sp, sp, #192
	.cfi_def_cfa_offset 192
	stp	x22, x21, [sp, #144]
	stp	x20, x19, [sp, #160]
	stp	x29, x30, [sp, #176]
	add	x29, sp, #176
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x6, x3
	mov	x5, x2
	mov	x4, x1
	mov	x19, x8
Lloh1702:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1703:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1704:
	ldr	x8, [x8]
	str	x8, [sp]
	stur	x8, [x29, #-40]
	sub	x20, x0, #24
	ldrb	w8, [x0, #46]
	and	w8, w8, #0x7
	cmp	w8, #1
	b.le	LBB223_6
	cmp	w8, #2
	b.eq	LBB223_14
	cmp	w8, #3
	b.eq	LBB223_8
	cmp	w8, #4
	b.ne	LBB223_44
Lloh1705:
	adrp	x8, l___anon_12268@PAGE
Lloh1706:
	add	x8, x8, l___anon_12268@PAGEOFF
Lloh1707:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-40]
Lloh1708:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1709:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1710:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB223_39
	.cfi_def_cfa wsp, 192
	b	LBB223_31
LBB223_6:
	.cfi_restore_state
	.cfi_remember_state
	cbz	w8, LBB223_14
	cmp	w8, #1
	b.ne	LBB223_44
LBB223_8:
	ldp	x1, x3, [x20, #40]
	cmp	x3, x1
	b.hi	LBB223_42
	ldp	x0, x8, [x20]
	ldr	x2, [x20, #32]
	ldr	x9, [x8, #384]
	ldr	x8, [x20, #56]
	str	x8, [sp, #88]
	ldr	x7, [x20, #16]
	add	x8, sp, #16
	add	x1, sp, #88
	blr	x9
	ldrh	w8, [sp, #24]
	cbnz	w8, LBB223_32
	ldr	x9, [sp, #16]
	ldr	x8, [x20, #16]
	adds	x8, x8, x9
	b.hs	LBB223_41
	str	x8, [x20, #16]
	ldr	x0, [x20, #48]
	subs	x8, x9, x0
	b.hs	LBB223_19
	ldr	x1, [x20, #40]
	cmp	x0, x1
	b.hi	LBB223_40
	sub	x21, x0, x9
	ldr	x0, [x20, #32]
	add	x1, x0, x9
	mov	x2, x21
	bl	_memmove
	mov	x8, #0
	b	LBB223_20
LBB223_14:
	ldp	x1, x0, [x20, #40]
	cmp	x0, x1
	b.hi	LBB223_40
	ldp	x9, x8, [x20]
	ldr	x10, [x20, #32]
	ldr	x11, [x20, #56]
	stp	x10, x0, [sp, #16]
	stp	x4, x5, [sp, #32]
	stp	x6, x11, [sp, #48]
	mov	w10, #1
	strb	w10, [sp, #80]
	ldr	x10, [x8, #120]
	add	x8, sp, #88
	add	x1, sp, #16
	mov	x0, x9
	blr	x10
	ldrh	w8, [sp, #128]
	cbnz	w8, LBB223_18
	ldrb	w0, [sp, #120]
	and	w8, w0, #0x7
	cmp	w8, #1
	b.ne	LBB223_43
	ldrh	w8, [sp, #96]
	cbz	w8, LBB223_22
LBB223_18:
	strh	w8, [x20, #64]
	mov	w9, #102
	b	LBB223_28
LBB223_19:
	mov	x21, #0
LBB223_20:
	mov	w9, #0
	str	x21, [x20, #48]
LBB223_21:
	str	x8, [x19]
	strh	w9, [x19, #8]
	ldr	w8, [sp, #8]
	stur	w8, [x19, #10]
	ldrh	w8, [sp, #12]
	strh	w8, [x19, #14]
	b	LBB223_29
LBB223_22:
	ldr	x9, [sp, #88]
	ldr	x8, [x20, #16]
	adds	x8, x8, x9
	b.hs	LBB223_41
	str	x8, [x20, #16]
	ldr	x0, [x20, #48]
	subs	x8, x9, x0
	b.hs	LBB223_26
	ldr	x1, [x20, #40]
	cmp	x0, x1
	b.hi	LBB223_40
	sub	x21, x0, x9
	ldr	x0, [x20, #32]
	add	x1, x0, x9
	mov	x2, x21
	bl	_memmove
	mov	x8, #0
	b	LBB223_27
LBB223_26:
	mov	x21, #0
LBB223_27:
	mov	w9, #0
	str	x21, [x20, #48]
LBB223_28:
	str	x8, [x19]
	strh	w9, [x19, #8]
	stur	wzr, [x19, #10]
	strh	wzr, [x19, #14]
LBB223_29:
	ldur	x8, [x29, #-40]
Lloh1711:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1712:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1713:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB223_39
	.cfi_def_cfa wsp, 192
LBB223_31:
	ldp	x29, x30, [sp, #176]
	ldp	x20, x19, [sp, #160]
	ldp	x22, x21, [sp, #144]
	add	sp, sp, #192
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB223_32:
	.cfi_restore_state
	cmp	w8, #57
	b.ne	LBB223_37
	ldrb	w8, [x20, #70]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB223_44
	and	w8, w8, #0x7
	add	w8, w8, w8, lsl #1
	mov	w9, #4
	movk	w9, #72, lsl #16
	lsr	w8, w9, w8
	and	w8, w8, #0x7
	strb	w8, [x20, #70]
	ldr	x1, [x20, #16]
	cbz	x1, LBB223_38
	str	xzr, [x20, #16]
	mov	x0, x20
	bl	l_Io.File.Writer.seekTo
	tst	w0, #0xffff
	b.eq	LBB223_38
	mov	w8, #4
	strb	w8, [x20, #70]
	str	wzr, [sp, #8]
	strh	wzr, [sp, #12]
	mov	w9, #102
	b	LBB223_21
LBB223_37:
	strh	w8, [x20, #64]
	str	wzr, [sp, #8]
	mov	w9, #102
	strh	wzr, [sp, #12]
	b	LBB223_21
LBB223_38:
	mov	x8, #0
	mov	w9, #0
	strh	wzr, [sp, #12]
	str	wzr, [sp, #8]
	b	LBB223_21
LBB223_39:
	bl	___stack_chk_fail
LBB223_40:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB223_41:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB223_42:
	mov	x0, x3
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB223_43:
	bl	"l_debug.FullPanic((function 'defaultPanic')).inactiveUnionField__func_287"
LBB223_44:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
	.loh AdrpLdrGotLdr	Lloh1702, Lloh1703, Lloh1704
	.loh AdrpLdrGotLdr	Lloh1708, Lloh1709, Lloh1710
	.loh AdrpAddLdr	Lloh1705, Lloh1706, Lloh1707
	.loh AdrpLdrGotLdr	Lloh1711, Lloh1712, Lloh1713
	.cfi_endproc

	.p2align	2
l_Io.File.Writer.sendFile:
	.cfi_startproc
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x22, x21, [sp, #64]
	stp	x20, x19, [sp, #80]
	stp	x29, x30, [sp, #96]
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_remember_state
	mov	x19, x8
Lloh1714:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1715:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1716:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	stur	x8, [x29, #-40]
	ldrb	w8, [x0, #46]
	and	w8, w8, #0x7
	cmp	w8, #1
	b.le	LBB224_6
	cmp	w8, #2
	b.eq	LBB224_14
	cmp	w8, #3
	b.eq	LBB224_16
	cmp	w8, #4
	b.ne	LBB224_59
Lloh1717:
	adrp	x8, l___anon_12268@PAGE
Lloh1718:
	add	x8, x8, l___anon_12268@PAGEOFF
Lloh1719:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-40]
Lloh1720:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1721:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1722:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB224_56
	.cfi_def_cfa wsp, 112
	b	LBB224_32
LBB224_6:
	.cfi_restore_state
	.cfi_remember_state
	mov	x5, x2
	mov	x4, x1
	sub	x20, x0, #24
	cbz	w8, LBB224_18
	cmp	w8, #1
	b.ne	LBB224_59
	ldp	x1, x3, [x20, #40]
	cmp	x3, x1
	b.hi	LBB224_57
	ldp	x0, x8, [x20]
	ldr	x2, [x20, #32]
	ldr	x9, [x8, #400]
	ldr	x8, [x20, #56]
	str	x8, [sp, #16]
	ldr	x6, [x20, #16]
	add	x8, sp, #40
	add	x1, sp, #16
	blr	x9
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB224_36
	ldr	x8, [sp, #40]
	ldr	x9, [x20, #16]
	adds	x9, x9, x8
	b.hs	LBB224_58
	str	x9, [x20, #16]
	ldr	x0, [x20, #48]
	subs	x9, x8, x0
	b.hs	LBB224_27
	ldr	x1, [x20, #40]
	cmp	x0, x1
	b.hi	LBB224_60
	sub	x21, x0, x8
	ldr	x0, [x20, #32]
	add	x1, x0, x8
	mov	x2, x21
	bl	_memmove
	mov	x9, #0
	b	LBB224_28
LBB224_14:
Lloh1723:
	adrp	x8, l___anon_9773@PAGE
Lloh1724:
	add	x8, x8, l___anon_9773@PAGEOFF
Lloh1725:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-40]
Lloh1726:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1727:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1728:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB224_56
	.cfi_def_cfa wsp, 112
	b	LBB224_32
LBB224_16:
	.cfi_restore_state
	.cfi_remember_state
Lloh1729:
	adrp	x8, l___anon_9773@PAGE
Lloh1730:
	add	x8, x8, l___anon_9773@PAGEOFF
Lloh1731:
	ldr	q0, [x8]
	str	q0, [x19]
	ldur	x8, [x29, #-40]
Lloh1732:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1733:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1734:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB224_56
	.cfi_def_cfa wsp, 112
	b	LBB224_32
LBB224_18:
	.cfi_restore_state
	.cfi_remember_state
	ldp	x1, x3, [x20, #40]
	cmp	x3, x1
	b.hi	LBB224_57
	ldp	x0, x8, [x20]
	ldr	x2, [x20, #32]
	ldr	x9, [x8, #392]
	ldr	x8, [x20, #56]
	str	x8, [sp, #16]
	add	x8, sp, #40
	add	x1, sp, #16
	blr	x9
	ldrh	w8, [sp, #48]
	cbnz	w8, LBB224_33
	ldr	x8, [sp, #40]
	ldr	x9, [x20, #16]
	adds	x9, x9, x8
	b.hs	LBB224_58
	str	x9, [x20, #16]
	ldr	x0, [x20, #48]
	subs	x9, x8, x0
	b.hs	LBB224_24
	ldr	x1, [x20, #40]
	cmp	x0, x1
	b.hi	LBB224_60
	sub	x21, x0, x8
	ldr	x0, [x20, #32]
	add	x1, x0, x8
	mov	x2, x21
	bl	_memmove
	mov	x9, #0
	b	LBB224_25
LBB224_24:
	mov	x21, #0
LBB224_25:
	mov	w8, #0
	str	x21, [x20, #48]
LBB224_26:
	str	x9, [x19]
	strh	w8, [x19, #8]
	ldr	w8, [sp, #32]
	stur	w8, [x19, #10]
	ldrh	w8, [sp, #36]
	b	LBB224_30
LBB224_27:
	mov	x21, #0
LBB224_28:
	mov	w8, #0
	str	x21, [x20, #48]
LBB224_29:
	str	x9, [x19]
	strh	w8, [x19, #8]
	ldr	w8, [sp, #24]
	stur	w8, [x19, #10]
	ldrh	w8, [sp, #28]
LBB224_30:
	strh	w8, [x19, #14]
	ldur	x8, [x29, #-40]
Lloh1735:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1736:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1737:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB224_56
	.cfi_def_cfa wsp, 112
LBB224_32:
	ldp	x29, x30, [sp, #96]
	ldp	x20, x19, [sp, #80]
	ldp	x22, x21, [sp, #64]
	add	sp, sp, #112
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	ret
LBB224_33:
	.cfi_restore_state
	cmp	w8, #57
	b.gt	LBB224_41
	cmp	w8, #2
	b.eq	LBB224_47
	cmp	w8, #13
	b.eq	LBB224_48
	b	LBB224_43
LBB224_36:
	cmp	w8, #56
	b.le	LBB224_44
	cmp	w8, #57
	b.eq	LBB224_49
	cmp	w8, #58
	b.eq	LBB224_40
	cmp	w8, #60
	b.ne	LBB224_46
LBB224_40:
	b	LBB224_29
LBB224_41:
	cmp	w8, #58
	b.eq	LBB224_48
	cmp	w8, #60
	b.eq	LBB224_48
LBB224_43:
	strh	w8, [x20, #66]
	str	wzr, [sp, #32]
	mov	w8, #102
	strh	wzr, [sp, #36]
	b	LBB224_26
LBB224_44:
	cmp	w8, #2
	b.eq	LBB224_53
	cmp	w8, #13
	b.eq	LBB224_40
LBB224_46:
	strh	w8, [x20, #66]
	str	wzr, [sp, #24]
	mov	w8, #102
	strh	wzr, [sp, #28]
	b	LBB224_29
LBB224_47:
	strh	w8, [x20, #64]
	str	wzr, [sp, #32]
	strh	wzr, [sp, #36]
	mov	w8, #102
LBB224_48:
	b	LBB224_26
LBB224_49:
	ldrb	w8, [x20, #70]
	eor	w8, w8, #0x4
	and	x9, x8, #0x7
	mov	w10, #241
	lsr	w9, w10, w9
	tbz	w9, #0, LBB224_59
	and	w8, w8, #0x7
	add	w8, w8, w8, lsl #1
	mov	w9, #4
	movk	w9, #72, lsl #16
	lsr	w8, w9, w8
	and	w8, w8, #0x7
	strb	w8, [x20, #70]
	ldr	x1, [x20, #16]
	cbz	x1, LBB224_55
	str	xzr, [x20, #16]
	mov	x0, x20
	bl	l_Io.File.Writer.seekTo
	tst	w0, #0xffff
	b.eq	LBB224_55
	mov	w8, #4
	strb	w8, [x20, #70]
	b	LBB224_54
LBB224_53:
	strh	w8, [x20, #64]
LBB224_54:
	str	wzr, [sp, #24]
	strh	wzr, [sp, #28]
	mov	w8, #102
	b	LBB224_29
LBB224_55:
	mov	x9, #0
	mov	w8, #0
	strh	wzr, [sp, #28]
	str	wzr, [sp, #24]
	b	LBB224_29
LBB224_56:
	bl	___stack_chk_fail
LBB224_57:
	mov	x0, x3
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB224_58:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB224_59:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB224_60:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
	.loh AdrpLdrGotLdr	Lloh1714, Lloh1715, Lloh1716
	.loh AdrpLdrGotLdr	Lloh1720, Lloh1721, Lloh1722
	.loh AdrpAddLdr	Lloh1717, Lloh1718, Lloh1719
	.loh AdrpLdrGotLdr	Lloh1726, Lloh1727, Lloh1728
	.loh AdrpAddLdr	Lloh1723, Lloh1724, Lloh1725
	.loh AdrpLdrGotLdr	Lloh1732, Lloh1733, Lloh1734
	.loh AdrpAddLdr	Lloh1729, Lloh1730, Lloh1731
	.loh AdrpLdrGotLdr	Lloh1735, Lloh1736, Lloh1737
	.cfi_endproc

	.p2align	2
l_Io.File.Writer.seekTo:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x20, x1
	mov	x19, x0
Lloh1738:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1739:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1740:
	ldr	x8, [x8]
	str	x8, [sp, #8]
	str	x8, [sp, #24]
	ldr	x8, [x0, #24]!
	ldr	x8, [x8, #16]
	blr	x8
	tst	w0, #0xffff
	b.ne	LBB225_16
	ldp	x1, x0, [x19, #40]
	cmp	x0, x1
	b.hi	LBB225_19
	cbnz	x0, LBB225_20
	ldp	x8, x9, [x19]
	ldrb	w10, [x19, #70]
	and	w10, w10, #0x7
	cmp	w10, #1
	b.le	LBB225_9
	cmp	w10, #2
	b.eq	LBB225_12
	cmp	w10, #3
	b.eq	LBB225_15
	cmp	w10, #4
	b.ne	LBB225_11
	ldrh	w0, [x19, #68]
	cbnz	w0, LBB225_16
	bl	"l_debug.FullPanic((function 'defaultPanic')).unwrapNull"
LBB225_9:
	cbz	w10, LBB225_12
	cmp	w10, #1
	b.eq	LBB225_15
LBB225_11:
	bl	"l_debug.FullPanic((function 'defaultPanic')).corruptSwitch"
LBB225_12:
	ldrh	w0, [x19, #68]
	cbnz	w0, LBB225_16
	ldr	x9, [x9, #424]
	ldr	x10, [x19, #56]
	str	x10, [sp, #16]
	add	x1, sp, #16
	mov	x0, x8
	mov	x2, x20
	blr	x9
	tst	w0, #0xffff
	b.eq	LBB225_15
	strh	w0, [x19, #68]
	b	LBB225_16
LBB225_15:
	mov	w0, #0
	str	x20, [x19, #16]
LBB225_16:
	ldr	x8, [sp, #24]
Lloh1741:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1742:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1743:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB225_18
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB225_18:
	.cfi_restore_state
	bl	___stack_chk_fail
LBB225_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB225_20:
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpLdrGotLdr	Lloh1738, Lloh1739, Lloh1740
	.loh AdrpLdrGotLdr	Lloh1741, Lloh1742, Lloh1743
	.cfi_endproc

	.p2align	2
l_mem.Allocator.noAlloc:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x0, #0
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
	.cfi_endproc

	.p2align	2
l_mem.Allocator.unreachableFree:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_mem.Allocator.unreachableRemap:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.cfi_endproc

	.p2align	2
l_mem.Allocator.unreachableResize:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
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
	mov	x3, x2
	mov	x2, x1
	mov	x1, x3
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	b	l_simd_candidates.maskCopy__func_290
	.cfi_endproc

	.p2align	2
l_simd_candidates.maskCopy__func_290:
	.cfi_startproc
	cmp	x1, x3
	b.ne	LBB231_8
	cbz	x3, LBB231_7
	mov	x8, #0
	sub	x9, x3, #1
	mov	x10, #-3689348814741910324
	movk	x10, #52429
	umulh	x10, x9, x10
	lsr	x10, x10, #2
	add	x10, x10, x10, lsl #2
	sub	x9, x9, x10
	add	x11, x9, #1
	cmp	x11, #5
	csinc	x9, xzr, x9, eq
Lloh1744:
	adrp	x10, l___anon_203@PAGE
Lloh1745:
	add	x10, x10, l___anon_203@PAGEOFF
	cmp	x3, #5
	b.lo	LBB231_6
	mov	x12, #0
	sub	x8, x3, x9
LBB231_4:
	add	x13, x0, x12
	and	x14, x12, #0x3
	add	x15, x2, x12
	ldrb	w16, [x15]
	ldrb	w17, [x10, x14]
	eor	w16, w17, w16
	add	w1, w12, #1
	strb	w16, [x13]
	and	x16, x1, #0x3
	ldrb	w1, [x15, #1]
	ldrb	w16, [x10, x16]
	eor	w16, w16, w1
	strb	w16, [x13, #1]
	eor	x14, x14, #0x2
	ldrb	w16, [x15, #2]
	ldrb	w14, [x10, x14]
	eor	w14, w14, w16
	strb	w14, [x13, #2]
	sub	w14, w12, #1
	and	x14, x14, #0x3
	ldrb	w16, [x15, #3]
	ldrb	w14, [x10, x14]
	eor	w14, w14, w16
	strb	w14, [x13, #3]
	ldrb	w14, [x15, #4]
	eor	w14, w14, w17
	strb	w14, [x13, #4]
	add	x12, x12, #5
	cmp	x8, x12
	b.ne	LBB231_4
	cmp	x11, #5
	b.eq	LBB231_7
LBB231_6:
	and	x11, x8, #0x3
	ldrb	w12, [x2, x8]
	ldrb	w11, [x10, x11]
	eor	w11, w11, w12
	strb	w11, [x0, x8]
	add	x8, x8, #1
	subs	x9, x9, #1
	b.ne	LBB231_6
LBB231_7:
	ret
LBB231_8:
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	"l_debug.FullPanic((function 'defaultPanic')).reachedUnreachable"
	.loh AdrpAdd	Lloh1744, Lloh1745
	.cfi_endproc

	.p2align	2
l_simd_codegen.std_search:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]
	stp	x29, x30, [sp, #48]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_remember_state
	mov	x19, x1
	mov	x1, x0
Lloh1746:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1747:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh1748:
	ldr	x8, [x8]
	str	x8, [sp]
	str	x8, [sp, #24]
	add	x0, sp, #8
	mov	x2, x19
	mov	w3, #13
	bl	l_mem.findScalar__func_124
	ldrb	w8, [sp, #16]
	ldr	x9, [sp, #8]
	tst	w8, #0x1
	csel	x0, x9, x19, ne
	ldr	x8, [sp, #24]
Lloh1749:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1750:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh1751:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB232_2
	.cfi_def_cfa wsp, 64
	ldp	x29, x30, [sp, #48]
	ldp	x20, x19, [sp, #32]
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	ret
LBB232_2:
	.cfi_restore_state
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh1749, Lloh1750, Lloh1751
	.loh AdrpLdrGotLdr	Lloh1746, Lloh1747, Lloh1748
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
	b	l_simd_candidates.find__func_291
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI234_0:
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
l_simd_candidates.find__func_291:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x8, x0
	mov	x0, #0
	movi.16b	v0, #32
	movi.16b	v1, #9
	movi.16b	v2, #127
	mov	x9, x1
LBB234_1:
	cmp	x9, #16
	b.lo	LBB234_7
	add	x9, x0, #16
	cmp	x9, x1
	b.hi	LBB234_17
	ldr	q3, [x8, x0]
	cmhi.16b	v4, v0, v3
	cmeq.16b	v5, v3, v1
	bic.16b	v4, v4, v5
	cmeq.16b	v3, v3, v2
	orr.16b	v3, v3, v4
	umaxv.16b	b4, v3
	fmov	w10, s4
	tbnz	w10, #0, LBB234_14
	cmn	x0, #16
	b.eq	LBB234_6
	mov	x0, x9
	subs	x9, x1, x9
	b.hs	LBB234_1
LBB234_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB234_7:
	cmp	x1, x0
	b.lo	LBB234_18
	b.eq	LBB234_16
	mov	x9, #0
	mov	x10, x0
LBB234_10:
	adds	x11, x0, x9
	b.hs	LBB234_6
	ldrb	w13, [x8, x10]
	cmp	w13, #32
	ccmp	w13, #9, #4, lo
	cset	w12, ne
	cmp	w13, #127
	b.eq	LBB234_15
	tbnz	w12, #0, LBB234_15
	add	x10, x10, #1
	add	x9, x9, #1
	cmp	x1, x10
	b.ne	LBB234_10
	b	LBB234_16
LBB234_14:
Lloh1752:
	adrp	x8, lCPI234_0@PAGE
Lloh1753:
	ldr	q0, [x8, lCPI234_0@PAGEOFF]
	movi.16b	v1, #15
	bif.16b	v0, v1, v3
	uminv.16b	b0, v0
	fmov	w8, s0
	and	x8, x8, #0xf
	add	x1, x8, x0
	b	LBB234_16
LBB234_15:
	mov	x1, x11
LBB234_16:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB234_17:
	.cfi_restore_state
	mov	x0, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB234_18:
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.loh AdrpLdr	Lloh1752, Lloh1753
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
	b	l_simd_candidates.find__func_293
	.cfi_endproc

	.p2align	2
l_simd_candidates.find__func_293:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, LBB236_6
	mov	x8, x0
	mov	x0, #0
LBB236_2:
	ldrb	w10, [x8, x0]
	cmp	w10, #32
	ccmp	w10, #9, #4, lo
	cset	w9, ne
	cmp	w10, #127
	b.eq	LBB236_7
	tbnz	w9, #0, LBB236_7
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	LBB236_2
	mov	x0, x1
	b	LBB236_7
LBB236_6:
	mov	x0, #0
LBB236_7:
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
	b	l_simd_candidates.find__func_294
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI238_0:
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
l_simd_candidates.find__func_294:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_remember_state
	mov	x8, x0
	mov	x0, #0
	movi.16b	v0, #32
	movi.16b	v1, #34
	movi.16b	v2, #92
	mov	x9, x1
LBB238_1:
	cmp	x9, #16
	b.lo	LBB238_7
	add	x9, x0, #16
	cmp	x9, x1
	b.hi	LBB238_18
	ldr	q3, [x8, x0]
	cmhi.16b	v4, v0, v3
	cmeq.16b	v5, v3, v1
	cmeq.16b	v3, v3, v2
	orr.16b	v3, v5, v3
	orr.16b	v3, v3, v4
	umaxv.16b	b4, v3
	fmov	w10, s4
	tbnz	w10, #0, LBB238_15
	cmn	x0, #16
	b.eq	LBB238_6
	mov	x0, x9
	subs	x9, x1, x9
	b.hs	LBB238_1
LBB238_6:
	bl	"l_debug.FullPanic((function 'defaultPanic')).integerOverflow"
LBB238_7:
	cmp	x1, x0
	b.lo	LBB238_19
	b.eq	LBB238_17
	mov	x9, #0
	mov	x10, x0
LBB238_10:
	adds	x11, x0, x9
	b.hs	LBB238_6
	ldrb	w12, [x8, x10]
	and	w12, w12, #0xff
	cmp	w12, #32
	b.lo	LBB238_16
	cmp	w12, #34
	b.eq	LBB238_16
	cmp	w12, #92
	b.eq	LBB238_16
	add	x10, x10, #1
	add	x9, x9, #1
	cmp	x1, x10
	b.ne	LBB238_10
	b	LBB238_17
LBB238_15:
Lloh1754:
	adrp	x8, lCPI238_0@PAGE
Lloh1755:
	ldr	q0, [x8, lCPI238_0@PAGEOFF]
	movi.16b	v1, #15
	bif.16b	v0, v1, v3
	uminv.16b	b0, v0
	fmov	w8, s0
	and	x8, x8, #0xf
	add	x1, x8, x0
	b	LBB238_17
LBB238_16:
	mov	x1, x11
LBB238_17:
	mov	x0, x1
	.cfi_def_cfa wsp, 16
	ldp	x29, x30, [sp], #16
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	ret
LBB238_18:
	.cfi_restore_state
	mov	x0, x9
	bl	"l_debug.FullPanic((function 'defaultPanic')).outOfBounds"
LBB238_19:
	bl	"l_debug.FullPanic((function 'defaultPanic')).startGreaterThanEnd"
	.loh AdrpLdr	Lloh1754, Lloh1755
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
	b	l_simd_candidates.find__func_296
	.cfi_endproc

	.p2align	2
l_simd_candidates.find__func_296:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	cbz	x1, LBB240_7
	mov	x8, x0
	mov	x0, #0
LBB240_2:
	ldrb	w9, [x8, x0]
	and	w9, w9, #0xff
	cmp	w9, #32
	b.lo	LBB240_8
	cmp	w9, #34
	b.eq	LBB240_8
	cmp	w9, #92
	b.eq	LBB240_8
	add	x0, x0, #1
	cmp	x1, x0
	b.ne	LBB240_2
	mov	x0, x1
	b	LBB240_8
LBB240_7:
	mov	x0, #0
LBB240_8:
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

	.section	__TEXT,__cstring,cstring_literals
l___anon_691:
	.asciz	"integer overflow"

l___anon_697:
	.asciz	"reached unreachable code"

	.section	__DATA,__const
	.p2align	3, 0x0
l___anon_3542:
	.quad	l_Io.Threaded.crashHandler
	.quad	l_Io.Threaded.async
	.quad	l_Io.Threaded.concurrent
	.quad	l_Io.Threaded.await
	.quad	l_Io.Threaded.cancel
	.quad	l_Io.Threaded.groupAsync
	.quad	l_Io.Threaded.groupConcurrent
	.quad	l_Io.Threaded.groupAwait
	.quad	l_Io.Threaded.groupCancel
	.quad	l_Io.Threaded.recancel
	.quad	l_Io.Threaded.swapCancelProtection
	.quad	l_Io.Threaded.checkCancel
	.quad	l_Io.Threaded.futexWait
	.quad	l_Io.Threaded.futexWaitUncancelable
	.quad	l_Io.Threaded.futexWake
	.quad	l_Io.Threaded.operate
	.quad	l_Io.Threaded.batchAwaitAsync
	.quad	l_Io.Threaded.batchAwaitConcurrent
	.quad	l_Io.Threaded.batchCancel
	.quad	l_Io.Threaded.dirCreateDirPosix
	.quad	l_Io.Threaded.dirCreateDirPath
	.quad	l_Io.Threaded.dirCreateDirPathOpenPosix
	.quad	l_Io.Threaded.dirOpenDirPosix
	.quad	l_Io.Threaded.dirStat
	.quad	l_Io.Threaded.dirStatFilePosix
	.quad	l_Io.Threaded.dirAccessPosix
	.quad	l_Io.Threaded.dirCreateFilePosix
	.quad	l_Io.Threaded.dirCreateFileAtomic
	.quad	l_Io.Threaded.dirOpenFilePosix
	.quad	l_Io.Threaded.dirClose
	.quad	l_Io.Threaded.dirReadDarwin
	.quad	l_Io.Threaded.dirRealPathPosix
	.quad	l_Io.Threaded.dirRealPathFilePosix
	.quad	l_Io.Threaded.dirDeleteFilePosix
	.quad	l_Io.Threaded.dirDeleteDirPosix
	.quad	l_Io.Threaded.dirRenamePosix
	.quad	l_Io.Threaded.dirRenamePreserve
	.quad	l_Io.Threaded.dirSymLinkPosix
	.quad	l_Io.Threaded.dirReadLink
	.quad	l_Io.Threaded.dirSetOwnerPosix
	.quad	l_Io.Threaded.dirSetFileOwner
	.quad	l_Io.Threaded.dirSetPermissionsPosix
	.quad	l_Io.Threaded.dirSetFilePermissions
	.quad	l_Io.Threaded.dirSetTimestamps
	.quad	l_Io.Threaded.dirHardLink
	.quad	l_Io.Threaded.fileStatPosix
	.quad	l_Io.Threaded.fileLength
	.quad	l_Io.Threaded.fileClose
	.quad	l_Io.Threaded.fileWritePositional
	.quad	l_Io.Threaded.fileWriteFileStreaming
	.quad	l_Io.Threaded.fileWriteFilePositional
	.quad	l_Io.Threaded.fileReadPositional
	.quad	l_Io.Threaded.fileSeekBy
	.quad	l_Io.Threaded.fileSeekTo
	.quad	l_Io.Threaded.fileSyncPosix
	.quad	l_Io.Threaded.fileIsTty
	.quad	l_Io.Threaded.fileEnableAnsiEscapeCodes
	.quad	l_Io.Threaded.fileSupportsAnsiEscapeCodes
	.quad	l_Io.Threaded.fileSetLength
	.quad	l_Io.Threaded.dirSetOwnerPosix
	.quad	l_Io.Threaded.dirSetPermissionsPosix
	.quad	l_Io.Threaded.fileSetTimestamps
	.quad	l_Io.Threaded.fileLock
	.quad	l_Io.Threaded.fileTryLock
	.quad	l_Io.Threaded.fileUnlock
	.quad	l_Io.Threaded.fileDowngradeLock
	.quad	l_Io.Threaded.dirRealPathPosix
	.quad	l_Io.Threaded.fileHardLink
	.quad	l_Io.Threaded.fileMemoryMapCreate
	.quad	l_Io.Threaded.fileMemoryMapDestroy
	.quad	l_Io.Threaded.fileMemoryMapSetLength
	.quad	l_Io.Threaded.fileMemoryMapRead
	.quad	l_Io.Threaded.fileMemoryMapWrite
	.quad	l_Io.Threaded.processExecutableOpen
	.quad	l_Io.Threaded.processExecutablePath
	.quad	l_Io.Threaded.lockStderr
	.quad	l_Io.Threaded.tryLockStderr
	.quad	l_Io.Threaded.unlockStderr
	.quad	l_Io.Threaded.processCurrentPath
	.quad	l_Io.Threaded.processSetCurrentDir
	.quad	l_Io.Threaded.processSetCurrentPath
	.quad	l_Io.Threaded.processReplace
	.quad	l_Io.Threaded.processSpawnDarwin
	.quad	l_Io.Threaded.childWait
	.quad	l_Io.Threaded.childKill
	.quad	l_Io.Threaded.progressParentFile
	.quad	l_Io.Threaded.inheritParentDir
	.quad	l_Io.Threaded.inheritParentFile
	.quad	l_Io.Threaded.now
	.quad	l_Io.Threaded.clockResolution
	.quad	l_Io.Threaded.sleep
	.quad	l_Io.Threaded.random
	.quad	l_Io.Threaded.randomSecure
	.quad	l_Io.Threaded.netListenIpPosix
	.quad	l_Io.Threaded.netAcceptPosix
	.quad	l_Io.Threaded.netBindIpPosix
	.quad	l_Io.Threaded.netConnectIpPosix
	.quad	l_Io.Threaded.netListenUnixPosix
	.quad	l_Io.Threaded.netConnectUnixPosix
	.quad	l_Io.Threaded.netSocketCreatePair
	.quad	l_Io.Threaded.netWriteFile
	.quad	l_Io.Threaded.netClose
	.quad	l_Io.Threaded.netShutdownPosix
	.quad	l_Io.Threaded.netInterfaceNameResolve
	.quad	l_Io.Threaded.netInterfaceName
	.quad	l_Io.Threaded.netLookup

.tbss l_debug.panic_stage$tlv$init, 8, 3

	.section	__DATA,__thread_vars,thread_local_variables
l_debug.panic_stage:
	.quad	__tlv_bootstrap
	.quad	0
	.quad	l_debug.panic_stage$tlv$init

.zerofill __DATA,__bss,l_debug.panicking,1,0
	.section	__TEXT,__cstring,cstring_literals
l___anon_3670:
	.asciz	"aborting due to recursive panic\n"

l___anon_3697:
	.asciz	"(msg truncated)"

l___anon_3731:
	.asciz	"@memcpy arguments alias"

	.section	__TEXT,__const
l___anon_3841:
	.ascii	"index out of bounds: index "

l___anon_4024:
	.ascii	", len "

	.section	__DATA,__const
	.p2align	3, 0x0
l___anon_4078:
	.quad	l_Io.Writer.fixedDrain
	.quad	l_Io.Writer.unimplementedSendFile
	.quad	l_Io.Writer.noopFlush
	.quad	l_Io.Writer.failingRebase

	.p2align	3, 0x0
l___anon_4116:
	.quad	l___anon_5936
	.quad	0

	.section	__TEXT,__cstring,cstring_literals
l___anon_4145:
	.asciz	"source and destination arguments have non-equal lengths"

l___anon_4169:
	.asciz	"switch on corrupt value"

l___anon_4180:
	.asciz	"00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"

l___anon_4193:
	.asciz	"integer does not fit in destination type"

	.section	__TEXT,__const
l___anon_4232:
	.ascii	"start index "

l___anon_4273:
	.ascii	" is larger than end index "

	.section	__TEXT,__cstring,cstring_literals
l___anon_4359:
	.asciz	"invalid enum value"

	.section	__TEXT,__const
l___anon_4495:
	.ascii	"Cannot print stack trace: stack tracing is disabled\n"

	.section	__TEXT,__cstring,cstring_literals
l___anon_4560:
	.asciz	"\033[2m"

l___anon_4562:
	.asciz	"\033[0m"

	.section	__DATA,__const
	.p2align	3, 0x0
l___anon_4630:
	.quad	l_heap.ArenaAllocator.alloc
	.quad	l_heap.ArenaAllocator.resize
	.quad	l_heap.ArenaAllocator.remap
	.quad	l_heap.ArenaAllocator.free

	.section	__TEXT,__const
l___anon_4678:
	.byte	10

	.section	__TEXT,__cstring,cstring_literals
l___anon_4704:
	.asciz	"attempt to use null value"

l___anon_4710:
	.asciz	"incorrect alignment"

	.section	__TEXT,__const
l___anon_4830:
	.ascii	"thread "

	.section	__TEXT,__literal8,8byte_literals
l___anon_4850:
	.ascii	" panic: "

	.section	__DATA,__const
	.p2align	3, 0x0
l___zig_error_name_table:
	.space	16
	.quad	l___unnamed_12
	.quad	22
	.quad	l___unnamed_13
	.quad	8
	.quad	l___unnamed_14
	.quad	11
	.quad	l___unnamed_15
	.quad	15
	.quad	l___unnamed_16
	.quad	5
	.quad	l___unnamed_17
	.quad	21
	.quad	l___unnamed_18
	.quad	17
	.quad	l___unnamed_19
	.quad	17
	.quad	l___unnamed_20
	.quad	10
	.quad	l___unnamed_21
	.quad	12
	.quad	l___unnamed_22
	.quad	13
	.quad	l___unnamed_23
	.quad	10
	.quad	l___unnamed_24
	.quad	11
	.quad	l___unnamed_25
	.quad	9
	.quad	l___unnamed_26
	.quad	10
	.quad	l___unnamed_27
	.quad	11
	.quad	l___unnamed_28
	.quad	10
	.quad	l___unnamed_29
	.quad	16
	.quad	l___unnamed_30
	.quad	10
	.quad	l___unnamed_31
	.quad	17
	.quad	l___unnamed_32
	.quad	8
	.quad	l___unnamed_33
	.quad	8
	.quad	l___unnamed_34
	.quad	22
	.quad	l___unnamed_35
	.quad	21
	.quad	l___unnamed_36
	.quad	15
	.quad	l___unnamed_37
	.quad	11
	.quad	l___unnamed_38
	.quad	15
	.quad	l___unnamed_39
	.quad	18
	.quad	l___unnamed_40
	.quad	18
	.quad	l___unnamed_41
	.quad	15
	.quad	l___unnamed_42
	.quad	17
	.quad	l___unnamed_43
	.quad	24
	.quad	l___unnamed_44
	.quad	25
	.quad	l___unnamed_45
	.quad	14
	.quad	l___unnamed_46
	.quad	7
	.quad	l___unnamed_47
	.quad	17
	.quad	l___unnamed_48
	.quad	11
	.quad	l___unnamed_49
	.quad	17
	.quad	l___unnamed_50
	.quad	12
	.quad	l___unnamed_51
	.quad	6
	.quad	l___unnamed_52
	.quad	18
	.quad	l___unnamed_53
	.quad	15
	.quad	l___unnamed_54
	.quad	11
	.quad	l___unnamed_55
	.quad	11
	.quad	l___unnamed_56
	.quad	8
	.quad	l___unnamed_57
	.quad	21
	.quad	l___unnamed_58
	.quad	20
	.quad	l___unnamed_59
	.quad	9
	.quad	l___unnamed_60
	.quad	20
	.quad	l___unnamed_61
	.quad	10
	.quad	l___unnamed_62
	.quad	18
	.quad	l___unnamed_63
	.quad	11
	.quad	l___unnamed_64
	.quad	11
	.quad	l___unnamed_65
	.quad	15
	.quad	l___unnamed_66
	.quad	7
	.quad	l___unnamed_67
	.quad	27
	.quad	l___unnamed_68
	.quad	10
	.quad	l___unnamed_69
	.quad	13
	.quad	l___unnamed_70
	.quad	13
	.quad	l___unnamed_71
	.quad	10
	.quad	l___unnamed_72
	.quad	17
	.quad	l___unnamed_73
	.quad	12
	.quad	l___unnamed_74
	.quad	25
	.quad	l___unnamed_75
	.quad	11
	.quad	l___unnamed_76
	.quad	15
	.quad	l___unnamed_77
	.quad	18
	.quad	l___unnamed_78
	.quad	16
	.quad	l___unnamed_79
	.quad	11
	.quad	l___unnamed_80
	.quad	10
	.quad	l___unnamed_81
	.quad	21
	.quad	l___unnamed_82
	.quad	20
	.quad	l___unnamed_83
	.quad	13
	.quad	l___unnamed_84
	.quad	21
	.quad	l___unnamed_85
	.quad	11
	.quad	l___unnamed_86
	.quad	18
	.quad	l___unnamed_87
	.quad	20
	.quad	l___unnamed_88
	.quad	26
	.quad	l___unnamed_89
	.quad	18
	.quad	l___unnamed_90
	.quad	16
	.quad	l___unnamed_91
	.quad	18
	.quad	l___unnamed_92
	.quad	12
	.quad	l___unnamed_93
	.quad	18
	.quad	l___unnamed_94
	.quad	27
	.quad	l___unnamed_95
	.quad	34
	.quad	l___unnamed_96
	.quad	21
	.quad	l___unnamed_97
	.quad	17
	.quad	l___unnamed_98
	.quad	18
	.quad	l___unnamed_99
	.quad	17
	.quad	l___unnamed_100
	.quad	17
	.quad	l___unnamed_101
	.quad	15
	.quad	l___unnamed_102
	.quad	17
	.quad	l___unnamed_103
	.quad	17
	.quad	l___unnamed_104
	.quad	15
	.quad	l___unnamed_105
	.quad	21
	.quad	l___unnamed_106
	.quad	17
	.quad	l___unnamed_107
	.quad	20
	.quad	l___unnamed_108
	.quad	21
	.quad	l___unnamed_109
	.quad	17
	.quad	l___unnamed_110
	.quad	17
	.quad	l___unnamed_111
	.quad	35
	.quad	l___unnamed_112
	.quad	11
	.quad	l___unnamed_113
	.quad	11
	.quad	l___unnamed_114
	.quad	6
	.quad	l___unnamed_115
	.quad	14
	.quad	l___unnamed_116
	.quad	8
	.quad	l___unnamed_117
	.quad	16
	.quad	l___unnamed_118
	.quad	15
	.quad	l___unnamed_119
	.quad	20
	.quad	l___unnamed_120
	.quad	19
	.quad	l___unnamed_121
	.quad	12
	.quad	l___unnamed_122
	.quad	25

	.section	__TEXT,__const
l___anon_5134:
	.ascii	"attempt to unwrap error: "

	.section	__TEXT,__cstring,cstring_literals
l___anon_5575:
	.asciz	"exact division produced remainder"

	.section	__TEXT,__const
	.p2align	4, 0x0
l___anon_5690:
	.space	32
	.byte	0
	.space	15

.tbss l_Io.Threaded.Thread.current$tlv$init, 8, 3

	.section	__DATA,__thread_vars,thread_local_variables
l_Io.Threaded.Thread.current:
	.quad	__tlv_bootstrap
	.quad	0
	.quad	l_Io.Threaded.Thread.current$tlv$init

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_5930:
	.space	8
	.short	2
	.space	6

	.section	__TEXT,__cstring,cstring_literals
l___anon_5936:
	.space	1

	.section	__TEXT,__const
l___anon_6031:
	.ascii	"sentinel mismatch: expected "

	.section	__TEXT,__literal8,8byte_literals
l___anon_6066:
	.ascii	", found "

	.section	__TEXT,__cstring,cstring_literals
l___anon_6122:
	.asciz	"cast causes pointer to be null"

	.section	__DATA,__data
	.p2align	3, 0x0
l_Progress.global_progress:
	.space	16
	.space	16
	.byte	0
	.space	7
	.space	8
	.space	8
	.space	16
	.space	16256
	.space	8
	.long	0
	.long	255
	.long	0
	.space	512
	.space	1024
	.short	0
	.short	0
	.space	2
	.byte	0
	.space	1
	.byte	0
	.byte	0
	.byte	0
	.space	127
	.space	127
	.byte	0
	.space	2

	.section	__TEXT,__cstring,cstring_literals
l___anon_6249:
	.asciz	"\033[J\033]9;4;0\033\\"

l___anon_6259:
	.asciz	"TODO implement netInterfaceName for libc"

	.section	__TEXT,__const
	.p2align	4, 0x0
l___anon_6856:
	.space	16
	.short	79
	.space	14

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_2803:
	.space	8
	.byte	0
	.space	7

	.section	__TEXT,__cstring,cstring_literals
l___anon_7041:
	.asciz	"NO_COLOR"

l___anon_7049:
	.asciz	"CLICOLOR_FORCE"

l___anon_7054:
	.asciz	"ZIG_PROGRESS"

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_7070:
	.space	8
	.short	78
	.space	2

	.section	__TEXT,__cstring,cstring_literals
l___anon_7072:
	.asciz	"PATH"

l___anon_7081:
	.asciz	"DEBUGINFOD_CACHE_PATH"

l___anon_7084:
	.asciz	"XDG_CACHE_HOME"

l___anon_7087:
	.asciz	"HOME"

l___anon_7090:
	.asciz	"TERM"

l___anon_7325:
	.asciz	"/usr/local/bin:/bin:/usr/bin"

l___anon_7555:
	.asciz	"/dev/null"

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_7447:
	.space	44
	.short	4
	.space	2

	.section	__TEXT,__literal8,8byte_literals
	.p2align	2, 0x0
l___anon_6334:
	.space	8

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_7603:
	.space	44
	.short	43
	.space	2

	.p2align	2, 0x0
l___anon_7632:
	.space	44
	.short	73
	.space	2

	.section	__DATA,__const
	.p2align	4, 0x0
l___jmptab_2945:
	.quad	Ltmp0
	.quad	Ltmp1
	.quad	Ltmp3
	.quad	Ltmp4
	.quad	Ltmp2

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_7732:
	.space	44
	.short	39
	.space	2

	.p2align	2, 0x0
l___anon_7743:
	.space	44
	.short	10
	.space	2

	.p2align	2, 0x0
l___anon_7747:
	.space	44
	.short	50
	.space	2

	.p2align	2, 0x0
l___anon_7751:
	.space	44
	.short	69
	.space	2

	.p2align	2, 0x0
l___anon_7753:
	.space	44
	.short	40
	.space	2

	.p2align	2, 0x0
l___anon_7757:
	.space	44
	.short	22
	.space	2

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_7836:
	.space	8
	.short	66
	.space	6

	.p2align	3, 0x0
l___anon_7839:
	.space	8
	.short	67
	.space	6

	.section	__TEXT,__const
	.p2align	3, 0x0
l___anon_7963:
	.space	16
	.short	44
	.space	6

	.p2align	3, 0x0
l___anon_7965:
	.space	16
	.short	43
	.space	6

	.p2align	2, 0x0
l___anon_7988:
	.space	8
	.short	24
	.space	2

	.p2align	2, 0x0
l___anon_7990:
	.space	8
	.short	23
	.space	2

	.p2align	3, 0x0
l___anon_8315:
	.space	56
	.short	64
	.space	6

l___anon_8432:
	.byte	61

	.section	__TEXT,__cstring,cstring_literals
l___anon_8446:
	.asciz	"for loop over objects with non-equal lengths"

	.section	__TEXT,__const
l___anon_9157:
	.byte	0
	.byte	1

l___anon_9158:
	.byte	1
	.byte	1

l___anon_9159:
	.space	1
	.byte	0

	.p2align	3, 0x0
l___anon_9350:
	.space	40
	.short	64
	.space	6

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_9523:
	.quad	0
	.quad	-2

	.p2align	3, 0x0
l___anon_9526:
	.quad	0
	.quad	-1

	.section	__TEXT,__cstring,cstring_literals
l___anon_9566:
	.asciz	"dumb"

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_9662:
	.space	8
	.short	2
	.space	6

	.p2align	3, 0x0
l___anon_9706:
	.space	8
	.short	7
	.space	6

	.p2align	3, 0x0
l___anon_9773:
	.space	8
	.short	58
	.space	6

	.p2align	3, 0x0
l___anon_9835:
	.space	8
	.short	9
	.space	6

	.p2align	3, 0x0
l___anon_9837:
	.space	8
	.short	20
	.space	6

	.p2align	3, 0x0
l___anon_9839:
	.space	8
	.short	14
	.space	6

	.p2align	3, 0x0
l___anon_9849:
	.space	8
	.short	19
	.space	6

	.section	__TEXT,__cstring,cstring_literals
l___anon_10117:
	.asciz	"TODO implement dirSetFileOwner"

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_10165:
	.space	8
	.short	55
	.space	6

	.p2align	3, 0x0
l___anon_10167:
	.space	8
	.short	50
	.space	6

	.p2align	3, 0x0
l___anon_10273:
	.space	8
	.short	43
	.space	6

	.p2align	3, 0x0
l___anon_10280:
	.space	8
	.short	10
	.space	6

	.p2align	3, 0x0
l___anon_10282:
	.space	8
	.short	39
	.space	6

	.p2align	3, 0x0
l___anon_10284:
	.space	8
	.short	49
	.space	6

	.p2align	3, 0x0
l___anon_10286:
	.space	8
	.short	40
	.space	6

	.p2align	3, 0x0
l___anon_10288:
	.space	8
	.short	37
	.space	6

	.p2align	3, 0x0
l___anon_10290:
	.space	8
	.short	3
	.space	6

	.p2align	3, 0x0
l___anon_10313:
	.space	8
	.short	44
	.space	6

	.p2align	3, 0x0
l___anon_10315:
	.space	8
	.short	15
	.space	6

	.p2align	3, 0x0
l___anon_10317:
	.space	8
	.short	5
	.space	6

	.p2align	3, 0x0
l___anon_10319:
	.space	8
	.short	23
	.space	6

	.p2align	3, 0x0
l___anon_10321:
	.space	8
	.short	24
	.space	6

	.p2align	3, 0x0
l___anon_10323:
	.space	8
	.short	21
	.space	6

	.p2align	3, 0x0
l___anon_10325:
	.space	8
	.short	4
	.space	6

	.p2align	3, 0x0
l___anon_10327:
	.space	8
	.short	16
	.space	6

	.p2align	3, 0x0
l___anon_10329:
	.space	8
	.short	18
	.space	6

	.p2align	3, 0x0
l___anon_10331:
	.space	8
	.short	36
	.space	6

	.p2align	3, 0x0
l___anon_10333:
	.space	8
	.short	17
	.space	6

	.p2align	3, 0x0
l___anon_10351:
	.space	8
	.short	12
	.space	6

	.section	__TEXT,__cstring,cstring_literals
l___anon_10369:
	.asciz	"."

l___anon_10373:
	.asciz	".."

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_10428:
	.space	8
	.short	44
	.space	2

	.p2align	2, 0x0
l___anon_10430:
	.space	8
	.short	10
	.space	2

	.p2align	2, 0x0
l___anon_10432:
	.space	8
	.short	15
	.space	2

	.p2align	2, 0x0
l___anon_10434:
	.space	8
	.short	5
	.space	2

	.p2align	2, 0x0
l___anon_10436:
	.space	8
	.short	37
	.space	2

	.p2align	2, 0x0
l___anon_10438:
	.space	8
	.short	23
	.space	2

	.p2align	2, 0x0
l___anon_10440:
	.space	8
	.short	43
	.space	2

	.p2align	2, 0x0
l___anon_10442:
	.space	8
	.short	24
	.space	2

	.p2align	2, 0x0
l___anon_10444:
	.space	8
	.short	21
	.space	2

	.p2align	2, 0x0
l___anon_10446:
	.space	8
	.short	39
	.space	2

	.p2align	2, 0x0
l___anon_10448:
	.space	8
	.short	4
	.space	2

	.p2align	2, 0x0
l___anon_10450:
	.space	8
	.short	16
	.space	2

	.p2align	2, 0x0
l___anon_10452:
	.space	8
	.short	40
	.space	2

	.p2align	2, 0x0
l___anon_10454:
	.space	8
	.short	18
	.space	2

	.p2align	2, 0x0
l___anon_10456:
	.space	8
	.short	36
	.space	2

	.p2align	2, 0x0
l___anon_10458:
	.space	8
	.short	17
	.space	2

	.p2align	2, 0x0
l___anon_10460:
	.space	8
	.short	47
	.space	2

	.p2align	2, 0x0
l___anon_10462:
	.space	8
	.short	9
	.space	2

	.p2align	2, 0x0
l___anon_10464:
	.space	8
	.short	22
	.space	2

	.p2align	2, 0x0
l___anon_10466:
	.space	8
	.short	41
	.space	2

	.p2align	1, 0x0
l___anon_10487:
	.short	511
	.byte	1
	.byte	0
	.byte	1
	.space	1

	.p2align	3, 0x0
l___anon_10498:
	.space	40
	.short	12
	.space	6

l___anon_10485:
	.byte	1
	.byte	0
	.byte	1

	.section	__TEXT,__cstring,cstring_literals
l___anon_10541:
	.asciz	"0123456789abcdef"

	.section	__TEXT,__const
	.p2align	4, 0x0
l___anon_10641:
	.space	96
	.short	4
	.space	14

	.p2align	4, 0x0
l___anon_10643:
	.space	96
	.short	10
	.space	14

	.p2align	4, 0x0
l___anon_10645:
	.space	96
	.short	18
	.space	14

	.p2align	4, 0x0
l___anon_10647:
	.space	96
	.short	43
	.space	14

	.p2align	4, 0x0
l___anon_10649:
	.space	96
	.short	37
	.space	14

	.p2align	4, 0x0
l___anon_10651:
	.space	96
	.short	39
	.space	14

	.p2align	4, 0x0
l___anon_10653:
	.space	96
	.short	44
	.space	14

l___anon_10682:
	.space	1

	.section	__TEXT,__cstring,cstring_literals
l___unnamed_1:
	.asciz	"unused"

l___unnamed_4:
	.asciz	"submission"

l___unnamed_2:
	.asciz	"pending"

l___unnamed_3:
	.asciz	"completion"

	.section	__TEXT,__const
l___anon_11143:
	.ascii	"access of union field '"

l___anon_11169:
	.ascii	"' while field '"

l___anon_11189:
	.ascii	"' is active"

	.p2align	3, 0x0
l___anon_11214:
	.space	40
	.short	2
	.space	6

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_11834:
	.space	8
	.short	1
	.space	6

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_11883:
	.space	4
	.byte	0
	.space	3
	.space	1
	.byte	0
	.byte	0
	.byte	0

	.section	__TEXT,__cstring,cstring_literals
l___anon_11944:
	.asciz	"TODO implement netConnectIpPosix with timeout"

	.section	__TEXT,__const
	.p2align	2, 0x0
l___anon_12057:
	.space	36
	.short	88
	.space	2

	.p2align	2, 0x0
l___anon_12061:
	.space	36
	.short	87
	.space	2

	.p2align	2, 0x0
l___anon_12063:
	.space	36
	.short	23
	.space	2

	.p2align	2, 0x0
l___anon_12065:
	.space	36
	.short	24
	.space	2

	.p2align	2, 0x0
l___anon_12067:
	.space	36
	.short	4
	.space	2

	.p2align	2, 0x0
l___anon_12071:
	.space	36
	.short	90
	.space	2

	.p2align	2, 0x0
l___anon_12075:
	.space	36
	.short	89
	.space	2

.tbss l_Thread.maybeAttachSignalStack.global.signal_stack$tlv$init, 262144

	.section	__DATA,__thread_vars,thread_local_variables
l_Thread.maybeAttachSignalStack.global.signal_stack:
	.quad	__tlv_bootstrap
	.quad	0
	.quad	l_Thread.maybeAttachSignalStack.global.signal_stack$tlv$init

	.section	__DATA,__const
	.p2align	3, 0x0
l_Io.Writer.Allocating.vtable:
	.quad	l_Io.Writer.Allocating.drain
	.quad	l_Io.Writer.Allocating.sendFile
	.quad	l_Io.Writer.noopFlush
	.quad	l_Io.Writer.Allocating.growingRebase

	.section	__TEXT,__literal16,16byte_literals
	.p2align	3, 0x0
l___anon_12268:
	.space	8
	.short	102
	.space	6

	.p2align	3, 0x0
l___anon_12314:
	.space	8
	.short	13
	.space	6

	.p2align	3, 0x0
l___anon_12315:
	.space	8
	.short	60
	.space	6

	.section	__TEXT,__cstring,cstring_literals
l___unnamed_6:
	.asciz	"file_read_streaming"

l___unnamed_5:
	.asciz	"file_write_streaming"

l___unnamed_10:
	.asciz	"device_io_control"

l___unnamed_11:
	.asciz	"net_receive"

l___unnamed_7:
	.asciz	"net_send"

l___unnamed_8:
	.asciz	"net_read"

l___unnamed_9:
	.asciz	"net_write"

	.section	__DATA,__data
	.p2align	3, 0x0
l_debug.getDebugInfoAllocator.S.arena:
	.space	8
	.quad	l_heap.PageAllocator.vtable
	.space	16

	.section	__DATA,__const
	.p2align	3, 0x0
l_heap.PageAllocator.vtable:
	.quad	l_heap.PageAllocator.alloc
	.quad	l_heap.PageAllocator.resize
	.quad	l_heap.PageAllocator.remap
	.quad	l_heap.PageAllocator.free

.zerofill __DATA,__bss,l_heap.PageAllocator.addr_hint,8,3
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0
l___anon_12813:
	.space	8

	.section	__DATA,__const
	.p2align	3, 0x0
l___anon_12829:
	.quad	l_mem.Allocator.noAlloc
	.quad	l_mem.Allocator.unreachableResize
	.quad	l_mem.Allocator.unreachableRemap
	.quad	l_mem.Allocator.unreachableFree

	.p2align	3, 0x0
l___anon_12739:
	.quad	l_Io.File.Writer.drain
	.quad	l_Io.File.Writer.sendFile
	.quad	l_Io.Writer.defaultFlush
	.quad	l_Io.Writer.defaultRebase

	.section	__DATA,__data
	.p2align	3, 0x0
l_Io.Threaded.global_single_threaded_instance:
	.space	8
	.quad	-1
	.space	512
	.quad	16777216
	.space	8
	.long	0
	.space	4
	.quad	0
	.quad	0
	.quad	0
	.space	8
	.quad	l___anon_12813
	.quad	0
	.space	80
	.space	8
	.short	77
	.space	2
	.short	0
	.space	2
	.space	16
	.space	16
	.quad	0
	.quad	-1
	.space	8
	.quad	l___anon_12829
	.space	16
	.quad	0
	.quad	l___anon_12739
	.quad	1
	.quad	0
	.quad	0
	.long	2
	.space	1
	.space	3
	.short	0
	.short	0
	.short	0
	.byte	0
	.space	1
	.space	4
	.space	4
	.space	8
	.long	4294967295
	.short	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	1
	.byte	0
	.byte	0
	.space	2

.zerofill __DATA,__bss,l_c.dummy_execute_header,32,2
	.section	__TEXT,__cstring,cstring_literals
l___unnamed_12:
	.asciz	"ConcurrencyUnavailable"

l___unnamed_13:
	.asciz	"Canceled"

l___unnamed_14:
	.asciz	"InputOutput"

l___unnamed_15:
	.asciz	"SystemResources"

l___unnamed_16:
	.asciz	"IsDir"

l___unnamed_17:
	.asciz	"ConnectionResetByPeer"

l___unnamed_18:
	.asciz	"NotOpenForReading"

l___unnamed_19:
	.asciz	"SocketUnconnected"

l___unnamed_20:
	.asciz	"WouldBlock"

l___unnamed_21:
	.asciz	"AccessDenied"

l___unnamed_22:
	.asciz	"LockViolation"

l___unnamed_23:
	.asciz	"Unexpected"

l___unnamed_24:
	.asciz	"EndOfStream"

l___unnamed_25:
	.asciz	"DiskQuota"

l___unnamed_26:
	.asciz	"FileTooBig"

l___unnamed_27:
	.asciz	"NoSpaceLeft"

l___unnamed_28:
	.asciz	"DeviceBusy"

l___unnamed_29:
	.asciz	"PermissionDenied"

l___unnamed_30:
	.asciz	"BrokenPipe"

l___unnamed_31:
	.asciz	"NotOpenForWriting"

l___unnamed_32:
	.asciz	"NoDevice"

l___unnamed_33:
	.asciz	"FileBusy"

l___unnamed_34:
	.asciz	"ProcessFdQuotaExceeded"

l___unnamed_35:
	.asciz	"SystemFdQuotaExceeded"

l___unnamed_36:
	.asciz	"MessageOversize"

l___unnamed_37:
	.asciz	"NetworkDown"

l___unnamed_38:
	.asciz	"PortUnreachable"

l___unnamed_39:
	.asciz	"ConnectionTimedOut"

l___unnamed_40:
	.asciz	"NetworkUnreachable"

l___unnamed_41:
	.asciz	"HostUnreachable"

l___unnamed_42:
	.asciz	"ConnectionRefused"

l___unnamed_43:
	.asciz	"AddressFamilyUnsupported"

l___unnamed_44:
	.asciz	"FastOpenAlreadyInProgress"

l___unnamed_45:
	.asciz	"SocketNotBound"

l___unnamed_46:
	.asciz	"Timeout"

l___unnamed_47:
	.asciz	"PathAlreadyExists"

l___unnamed_48:
	.asciz	"SymLinkLoop"

l___unnamed_49:
	.asciz	"LinkQuotaExceeded"

l___unnamed_50:
	.asciz	"FileNotFound"

l___unnamed_51:
	.asciz	"NotDir"

l___unnamed_52:
	.asciz	"ReadOnlyFileSystem"

l___unnamed_53:
	.asciz	"NetworkNotFound"

l___unnamed_54:
	.asciz	"NameTooLong"

l___unnamed_55:
	.asciz	"BadPathName"

l___unnamed_56:
	.asciz	"PipeBusy"

l___unnamed_57:
	.asciz	"AntivirusInterference"

l___unnamed_58:
	.asciz	"FileLocksUnsupported"

l___unnamed_59:
	.asciz	"Streaming"

l___unnamed_60:
	.asciz	"OperationUnsupported"

l___unnamed_61:
	.asciz	"FileSystem"

l___unnamed_62:
	.asciz	"UnrecognizedVolume"

l___unnamed_63:
	.asciz	"DirNotEmpty"

l___unnamed_64:
	.asciz	"CrossDevice"

l___unnamed_65:
	.asciz	"HardwareFailure"

l___unnamed_66:
	.asciz	"NotLink"

l___unnamed_67:
	.asciz	"UnsupportedReparsePointType"

l___unnamed_68:
	.asciz	"Unseekable"

l___unnamed_69:
	.asciz	"Unimplemented"

l___unnamed_70:
	.asciz	"CorruptedData"

l___unnamed_71:
	.asciz	"ReadFailed"

l___unnamed_72:
	.asciz	"NotTerminalDevice"

l___unnamed_73:
	.asciz	"NonResizable"

l___unnamed_74:
	.asciz	"LockedMemoryLimitExceeded"

l___unnamed_75:
	.asciz	"OutOfMemory"

l___unnamed_76:
	.asciz	"ProcessNotFound"

l___unnamed_77:
	.asciz	"CurrentDirUnlinked"

l___unnamed_78:
	.asciz	"PathExceedsLimit"

l___unnamed_79:
	.asciz	"InvalidWtf8"

l___unnamed_80:
	.asciz	"InvalidExe"

l___unnamed_81:
	.asciz	"InvalidBatchScriptArg"

l___unnamed_82:
	.asciz	"ResourceLimitReached"

l___unnamed_83:
	.asciz	"InvalidUserId"

l___unnamed_84:
	.asciz	"InvalidProcessGroupId"

l___unnamed_85:
	.asciz	"InvalidName"

l___unnamed_86:
	.asciz	"ProcessAlreadyExec"

l___unnamed_87:
	.asciz	"UnsupportedOperation"

l___unnamed_88:
	.asciz	"EnvironmentVariableMissing"

l___unnamed_89:
	.asciz	"UnrecognizedFormat"

l___unnamed_90:
	.asciz	"ClockUnavailable"

l___unnamed_91:
	.asciz	"EntropyUnavailable"

l___unnamed_92:
	.asciz	"AddressInUse"

l___unnamed_93:
	.asciz	"AddressUnavailable"

l___unnamed_94:
	.asciz	"ProtocolUnsupportedBySystem"

l___unnamed_95:
	.asciz	"ProtocolUnsupportedByAddressFamily"

l___unnamed_96:
	.asciz	"SocketModeUnsupported"

l___unnamed_97:
	.asciz	"OptionUnsupported"

l___unnamed_98:
	.asciz	"SocketNotListening"

l___unnamed_99:
	.asciz	"ConnectionAborted"

l___unnamed_100:
	.asciz	"BlockedByFirewall"

l___unnamed_101:
	.asciz	"ProtocolFailure"

l___unnamed_102:
	.asciz	"ConnectionPending"

l___unnamed_103:
	.asciz	"InterfaceNotFound"

l___unnamed_104:
	.asciz	"UnknownHostName"

l___unnamed_105:
	.asciz	"ResolvConfParseFailed"

l___unnamed_106:
	.asciz	"InvalidDnsARecord"

l___unnamed_107:
	.asciz	"InvalidDnsAAAARecord"

l___unnamed_108:
	.asciz	"InvalidDnsCnameRecord"

l___unnamed_109:
	.asciz	"NameServerFailure"

l___unnamed_110:
	.asciz	"NoAddressReturned"

l___unnamed_111:
	.asciz	"DetectingNetworkConfigurationFailed"

l___unnamed_112:
	.asciz	"Unsupported"

l___unnamed_113:
	.asciz	"WriteFailed"

l___unnamed_114:
	.asciz	"Closed"

l___unnamed_115:
	.asciz	"WindowTooSmall"

l___unnamed_116:
	.asciz	"Overflow"

l___unnamed_117:
	.asciz	"InvalidCharacter"

l___unnamed_118:
	.asciz	"SectionOversize"

l___unnamed_119:
	.asciz	"MappingAlreadyExists"

l___unnamed_120:
	.asciz	"ThreadQuotaExceeded"

l___unnamed_121:
	.asciz	"SizeTooSmall"

l___unnamed_122:
	.asciz	"MemoryMappingNotSupported"

	.section	__TEXT,__literal16,16byte_literals
	.p2align	1, 0x0
l_switch.table.Io.Threaded.netLookup:
	.short	32
	.short	98
	.short	12
	.short	98
	.short	32
	.short	4
	.short	93
	.short	93

	.section	__TEXT,__const
	.p2align	2, 0x0
l_switch.table.Io.Threaded.futexWait:
	.long	16
	.space	4
	.space	4
	.space	4
	.long	0
	.long	8
	.long	4
	.long	12

	.p2align	2, 0x0
l_switch.table.Io.Threaded.openSocketPosix:
	.long	4
	.space	4
	.space	4
	.space	4
	.long	1
	.long	2
	.long	5
	.long	3

	.globl	_mask_vector
_mask_vector = l_simd_codegen.mask_vector
	.globl	_mask_word
_mask_word = l_simd_codegen.mask_word
	.weak_reference __mh_execute_header
__mh_execute_header = l_c.dummy_execute_header
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
