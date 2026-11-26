
/tmp/akamata-baseline-server-fast:	file format mach-o arm64

Disassembly of section __TEXT,__text:

00000001000467cc <_http.session.Session.next>:
1000467cc:     	stp	x28, x27, [sp, #-0x60]!
1000467d0:     	stp	x26, x25, [sp, #0x10]
1000467d4:     	stp	x24, x23, [sp, #0x20]
1000467d8:     	stp	x22, x21, [sp, #0x30]
1000467dc:     	stp	x20, x19, [sp, #0x40]
1000467e0:     	stp	x29, x30, [sp, #0x50]
1000467e4:     	add	x29, sp, #0x50
1000467e8:     	sub	sp, sp, #0x1a0
1000467ec:     	mov	x21, x2
1000467f0:     	mov	x20, x1
1000467f4:     	mov	x19, x0
1000467f8:     	ldrb	w8, [x1, #0x65]
1000467fc:     	tbnz	w8, #0x0, 0x100046878 <_http.session.Session.next+0xac>
100046800:     	ldr	x8, [x20, #0x38]
100046804:     	cmp	x8, #0x4
100046808:     	b.lo	0x100046844 <_http.session.Session.next+0x78>
10004680c:     	ldr	x9, [x20, #0x30]
100046810:     	mov	w10, #0xa0d             ; =2573
100046814:     	movk	w10, #0xa0d, lsl #16
100046818:     	adrp	x11, 0x100158000 <_sqlite3LogEst.a+0x2>
10004681c:     	add	x11, x11, #0xce1
100046820:     	sub	x11, x11, x9
100046824:     	sub	x12, x8, #0x3
100046828:     	cbz	x11, 0x100046870 <_http.session.Session.next+0xa4>
10004682c:     	ldr	w13, [x9], #0x1
100046830:     	cmp	w13, w10
100046834:     	b.eq	0x100046870 <_http.session.Session.next+0xa4>
100046838:     	sub	x11, x11, #0x1
10004683c:     	sub	x12, x12, #0x1
100046840:     	cbnz	x12, 0x100046828 <_http.session.Session.next+0x5c>
100046844:     	ldr	x22, [x20, #0x48]
100046848:     	strh	wzr, [x19, #0x78]
10004684c:     	cmp	x8, x22
100046850:     	b.hs	0x10004692c <_http.session.Session.next+0x160>
100046854:     	strb	wzr, [x19, #0x70]
100046858:     	ldrb	w8, [x20, #0x64]
10004685c:     	tbz	w8, #0x0, 0x100046938 <_http.session.Session.next+0x16c>
100046860:     	ldr	w8, [x20, #0x60]
100046864:     	cbz	w8, 0x100046938 <_http.session.Session.next+0x16c>
100046868:     	mov	w8, #0x78               ; =120
10004686c:     	b	0x10004693c <_http.session.Session.next+0x170>
100046870:     	mov	w8, #0x1                ; =1
100046874:     	strb	w8, [x20, #0x65]
100046878:     	add	x22, x20, #0x10
10004687c:     	add	x0, x20, #0x10
100046880:     	bl	0x100058a3c <_heap.ArenaAllocator.reset>
100046884:     	adrp	x8, 0x100185000 <___anon_9403+0x230>
100046888:     	add	x8, x8, #0xc98
10004688c:     	stp	x22, x8, [sp, #0x88]
100046890:     	ldr	x27, [x20, #0x38]
100046894:     	cmp	x27, #0x4
100046898:     	b.lo	0x1000468e4 <_http.session.Session.next+0x118>
10004689c:     	mov	x9, #0x0                ; =0
1000468a0:     	ldr	x22, [x20, #0x30]
1000468a4:     	ldp	x25, x8, [x21, #0x20]
1000468a8:     	ldr	x23, [x21, #0x30]
1000468ac:     	mov	w10, #0xa0d             ; =2573
1000468b0:     	movk	w10, #0xa0d, lsl #16
1000468b4:     	adrp	x11, 0x100158000 <_sqlite3LogEst.a+0x2>
1000468b8:     	add	x11, x11, #0xce1
1000468bc:     	sub	x26, x11, x22
1000468c0:     	sub	x11, x27, #0x3
1000468c4:     	cmp	x26, x9
1000468c8:     	b.eq	0x1000469e8 <_http.session.Session.next+0x21c>
1000468cc:     	ldr	w12, [x22, x9]
1000468d0:     	cmp	w12, w10
1000468d4:     	b.eq	0x1000469e4 <_http.session.Session.next+0x218>
1000468d8:     	add	x9, x9, #0x1
1000468dc:     	cmp	x11, x9
1000468e0:     	b.ne	0x1000468c4 <_http.session.Session.next+0xf8>
1000468e4:     	ldr	x8, [x20, #0x38]
1000468e8:     	ldr	x3, [x20, #0x50]
1000468ec:     	strh	wzr, [x19, #0x78]
1000468f0:     	cmp	x8, x3
1000468f4:     	b.hs	0x100046920 <_http.session.Session.next+0x154>
1000468f8:     	strb	wzr, [x19, #0x70]
1000468fc:     	add	x0, sp, #0x98
100046900:     	mov	x1, x20
100046904:     	mov	x2, x21
100046908:     	bl	0x100056568 <_http.session.Session.need>
10004690c:     	ldur	q0, [sp, #0x98]
100046910:     	str	q0, [x19]
100046914:     	ldr	x8, [sp, #0xa8]
100046918:     	str	x8, [x19, #0x10]
10004691c:     	b	0x100047378 <_http.session.Session.next+0xbac>
100046920:     	mov	w8, #0x2                ; =2
100046924:     	strb	w8, [x19, #0x70]
100046928:     	b	0x10004734c <_http.session.Session.next+0xb80>
10004692c:     	mov	w8, #0x2                ; =2
100046930:     	strb	w8, [x19, #0x70]
100046934:     	b	0x100047360 <_http.session.Session.next+0xb94>
100046938:     	mov	w8, #0x70               ; =112
10004693c:     	ldr	w8, [x21, x8]
100046940:     	ldr	w9, [x21, #0x7c]
100046944:     	cmp	w8, w9
100046948:     	csel	w21, w8, w9, lo
10004694c:     	ldr	x23, [x20, #0x58]
100046950:     	stp	xzr, xzr, [sp, #0xb0]
100046954:     	add	x1, sp, #0xb0
100046958:     	mov	w0, #0x6                ; =6
10004695c:     	bl	0x100149b70 <dyld_stub_binder+0x100149b70>
100046960:     	mov	x10, #0x0               ; =0
100046964:     	cbnz	w0, 0x100046998 <_http.session.Session.next+0x1cc>
100046968:     	mov	w8, #0xca00             ; =51712
10004696c:     	movk	w8, #0x3b9a, lsl #16
100046970:     	ldp	x9, x10, [sp, #0xb0]
100046974:     	madd	x8, x9, x8, x10
100046978:     	subs	x8, x8, x23
10004697c:     	csel	x8, xzr, x8, lo
100046980:     	mov	x9, #0x34db             ; =13531
100046984:     	movk	x9, #0xd7b6, lsl #16
100046988:     	movk	x9, #0xde82, lsl #32
10004698c:     	movk	x9, #0x431b, lsl #48
100046990:     	umulh	x8, x8, x9
100046994:     	lsr	x10, x8, #18
100046998:     	mov	w8, #0x0                ; =0
10004699c:     	ldr	x9, [x20, #0x58]
1000469a0:     	mov	w11, #0x4240            ; =16960
1000469a4:     	movk	w11, #0xf, lsl #16
1000469a8:     	umull	x11, w21, w11
1000469ac:     	adds	x9, x9, x11
1000469b0:     	csinv	x9, x9, xzr, lo
1000469b4:     	sub	w11, w21, w10
1000469b8:     	cmp	x10, x21
1000469bc:     	csel	w10, w11, wzr, lo
1000469c0:     	ldrb	w11, [x20, #0x64]
1000469c4:     	tbz	w11, #0x0, 0x1000469d4 <_http.session.Session.next+0x208>
1000469c8:     	ldr	x8, [x20, #0x38]
1000469cc:     	cmp	x8, #0x0
1000469d0:     	cset	w8, eq
1000469d4:     	stp	x22, x9, [x19]
1000469d8:     	str	w10, [x19, #0x10]
1000469dc:     	strb	w8, [x19, #0x14]
1000469e0:     	b	0x100047378 <_http.session.Session.next+0xbac>
1000469e4:     	mov	x26, x9
1000469e8:     	cmp	x26, x8
1000469ec:     	b.ls	0x1000469f8 <_http.session.Session.next+0x22c>
1000469f0:     	mov	w9, #0x43               ; =67
1000469f4:     	b	0x100047310 <_http.session.Session.next+0xb44>
1000469f8:     	stp	x22, x26, [sp, #0xb0]
1000469fc:     	adrp	x8, 0x10014d000 <___anon_12342+0x120>
100046a00:     	add	x8, x8, #0xd20
100046a04:     	ldr	q0, [x8]
100046a08:     	str	q0, [sp, #0xc0]
100046a0c:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
100046a10:     	add	x8, x8, #0xba6
100046a14:     	mov	w9, #0x2                ; =2
100046a18:     	stp	x8, x9, [sp, #0xd0]
100046a1c:     	cmp	x26, #0x2
100046a20:     	b.lo	0x100046a5c <_http.session.Session.next+0x290>
100046a24:     	mov	x9, #0x0                ; =0
100046a28:     	sub	x8, x8, x22
100046a2c:     	sub	x10, x26, #0x1
100046a30:     	cmp	x8, x9
100046a34:     	b.eq	0x100046b8c <_http.session.Session.next+0x3c0>
100046a38:     	add	x11, x22, x9
100046a3c:     	ldrb	w12, [x11]
100046a40:     	ldrb	w11, [x11, #0x1]
100046a44:     	cmp	w12, #0xd
100046a48:     	ccmp	w11, #0xa, #0x0, eq
100046a4c:     	b.eq	0x100046b88 <_http.session.Session.next+0x3bc>
100046a50:     	add	x9, x9, #0x1
100046a54:     	cmp	x10, x9
100046a58:     	b.ne	0x100046a30 <_http.session.Session.next+0x264>
100046a5c:     	add	x8, sp, #0xb0
100046a60:     	stp	xzr, xzr, [x8, #0x10]
100046a64:     	mov	x8, x26
100046a68:     	cbz	x26, 0x100046ba0 <_http.session.Session.next+0x3d4>
100046a6c:     	cmp	x8, #0x21
100046a70:     	b.lo	0x100046ac0 <_http.session.Session.next+0x2f4>
100046a74:     	mov	x10, #0x0               ; =0
100046a78:     	movi.16b	v1, #0xd
100046a7c:     	ldr	q2, [x22, x10]
100046a80:     	cmeq.16b	v2, v2, v1
100046a84:     	umaxv.16b	b2, v2
100046a88:     	fmov	w9, s2
100046a8c:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046a90:     	add	x9, x22, x10
100046a94:     	ldr	q2, [x9, #0x10]
100046a98:     	cmeq.16b	v2, v2, v1
100046a9c:     	umaxv.16b	b2, v2
100046aa0:     	fmov	w9, s2
100046aa4:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046aa8:     	add	x9, x10, #0x20
100046aac:     	add	x11, x10, #0x40
100046ab0:     	mov	x10, x9
100046ab4:     	cmp	x11, x8
100046ab8:     	b.lo	0x100046a7c <_http.session.Session.next+0x2b0>
100046abc:     	b	0x100046ac4 <_http.session.Session.next+0x2f8>
100046ac0:     	mov	x9, #0x0                ; =0
100046ac4:     	add	x10, x9, #0x10
100046ac8:     	cmp	x10, x8
100046acc:     	b.hs	0x100046aec <_http.session.Session.next+0x320>
100046ad0:     	ldr	q1, [x22, x9]
100046ad4:     	movi.16b	v2, #0xd
100046ad8:     	cmeq.16b	v1, v1, v2
100046adc:     	umaxv.16b	b1, v1
100046ae0:     	fmov	w9, s1
100046ae4:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046ae8:     	mov	x9, x10
100046aec:     	add	x10, x9, #0x8
100046af0:     	cmp	x10, x8
100046af4:     	b.hs	0x100046b14 <_http.session.Session.next+0x348>
100046af8:     	ldr	d1, [x22, x9]
100046afc:     	movi.8b	v2, #0xd
100046b00:     	cmeq.8b	v1, v1, v2
100046b04:     	umaxv.8b	b1, v1
100046b08:     	fmov	w9, s1
100046b0c:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046b10:     	mov	x9, x10
100046b14:     	subs	x10, x8, x9
100046b18:     	b.eq	0x100046b34 <_http.session.Session.next+0x368>
100046b1c:     	add	x9, x22, x9
100046b20:     	ldrb	w11, [x9], #0x1
100046b24:     	cmp	w11, #0xd
100046b28:     	b.eq	0x10004730c <_http.session.Session.next+0xb40>
100046b2c:     	subs	x10, x10, #0x1
100046b30:     	b.ne	0x100046b20 <_http.session.Session.next+0x354>
100046b34:     	cmp	x8, #0x21
100046b38:     	b.lo	0x100046c34 <_http.session.Session.next+0x468>
100046b3c:     	mov	x10, #0x0               ; =0
100046b40:     	movi.16b	v1, #0xa
100046b44:     	ldr	q2, [x22, x10]
100046b48:     	cmeq.16b	v2, v2, v1
100046b4c:     	umaxv.16b	b2, v2
100046b50:     	fmov	w9, s2
100046b54:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046b58:     	add	x9, x22, x10
100046b5c:     	ldr	q2, [x9, #0x10]
100046b60:     	cmeq.16b	v2, v2, v1
100046b64:     	umaxv.16b	b2, v2
100046b68:     	fmov	w9, s2
100046b6c:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046b70:     	add	x9, x10, #0x20
100046b74:     	add	x11, x10, #0x40
100046b78:     	mov	x10, x9
100046b7c:     	cmp	x11, x8
100046b80:     	b.lo	0x100046b44 <_http.session.Session.next+0x378>
100046b84:     	b	0x100046c38 <_http.session.Session.next+0x46c>
100046b88:     	mov	x8, x9
100046b8c:     	add	x9, x8, #0x2
100046b90:     	str	x9, [sp, #0xc0]
100046b94:     	mov	w9, #0x1                ; =1
100046b98:     	strb	w9, [sp, #0xc8]
100046b9c:     	cbnz	x8, 0x100046a6c <_http.session.Session.next+0x2a0>
100046ba0:     	stp	x22, xzr, [sp, #0xe0]
100046ba4:     	add	x9, sp, #0xe0
100046ba8:     	add	x9, x9, #0x10
100046bac:     	mov	w10, #0x20              ; =32
100046bb0:     	strb	w10, [sp, #0x100]
100046bb4:     	mov	x13, #0x0               ; =0
100046bb8:     	mov	x15, #0x0               ; =0
100046bbc:     	stp	xzr, xzr, [x9]
100046bc0:     	mov	x14, x8
100046bc4:     	cbz	x13, 0x10004730c <_http.session.Session.next+0xb40>
100046bc8:     	ldrb	w9, [sp, #0xf8]
100046bcc:     	tbz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046bd0:     	ldr	x9, [sp, #0xf0]
100046bd4:     	cmp	x9, x8
100046bd8:     	b.hs	0x100046ecc <_http.session.Session.next+0x700>
100046bdc:     	add	x10, x9, #0x20
100046be0:     	cmp	x10, x8
100046be4:     	b.hs	0x100046d14 <_http.session.Session.next+0x548>
100046be8:     	movi.16b	v0, #0x20
100046bec:     	mov	x11, x9
100046bf0:     	ldr	q1, [x22, x11]
100046bf4:     	cmeq.16b	v2, v1, v0
100046bf8:     	umaxv.16b	b2, v2
100046bfc:     	fmov	w10, s2
100046c00:     	tbnz	w10, #0x0, 0x100046da4 <_http.session.Session.next+0x5d8>
100046c04:     	add	x10, x22, x11
100046c08:     	ldr	q1, [x10, #0x10]
100046c0c:     	cmeq.16b	v2, v1, v0
100046c10:     	umaxv.16b	b2, v2
100046c14:     	fmov	w10, s2
100046c18:     	tbnz	w10, #0x0, 0x100046dcc <_http.session.Session.next+0x600>
100046c1c:     	add	x10, x11, #0x20
100046c20:     	add	x12, x11, #0x40
100046c24:     	mov	x11, x10
100046c28:     	cmp	x12, x8
100046c2c:     	b.lo	0x100046bf0 <_http.session.Session.next+0x424>
100046c30:     	b	0x100046d18 <_http.session.Session.next+0x54c>
100046c34:     	mov	x9, #0x0                ; =0
100046c38:     	add	x10, x9, #0x10
100046c3c:     	cmp	x10, x8
100046c40:     	b.hs	0x100046c60 <_http.session.Session.next+0x494>
100046c44:     	ldr	q1, [x22, x9]
100046c48:     	movi.16b	v2, #0xa
100046c4c:     	cmeq.16b	v1, v1, v2
100046c50:     	umaxv.16b	b1, v1
100046c54:     	fmov	w9, s1
100046c58:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046c5c:     	mov	x9, x10
100046c60:     	add	x10, x9, #0x8
100046c64:     	cmp	x10, x8
100046c68:     	b.hs	0x100046c88 <_http.session.Session.next+0x4bc>
100046c6c:     	ldr	d1, [x22, x9]
100046c70:     	movi.8b	v2, #0xa
100046c74:     	cmeq.8b	v1, v1, v2
100046c78:     	umaxv.8b	b1, v1
100046c7c:     	fmov	w9, s1
100046c80:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046c84:     	mov	x9, x10
100046c88:     	subs	x10, x8, x9
100046c8c:     	b.eq	0x100046ca8 <_http.session.Session.next+0x4dc>
100046c90:     	add	x9, x22, x9
100046c94:     	ldrb	w11, [x9], #0x1
100046c98:     	cmp	w11, #0xa
100046c9c:     	b.eq	0x10004730c <_http.session.Session.next+0xb40>
100046ca0:     	subs	x10, x10, #0x1
100046ca4:     	b.ne	0x100046c94 <_http.session.Session.next+0x4c8>
100046ca8:     	stp	x22, x8, [sp, #0xe0]
100046cac:     	add	x9, sp, #0xe0
100046cb0:     	add	x9, x9, #0x10
100046cb4:     	str	q0, [sp, #0xf0]
100046cb8:     	mov	w10, #0x20              ; =32
100046cbc:     	strb	w10, [sp, #0x100]
100046cc0:     	cmp	x8, #0x21
100046cc4:     	b.lo	0x100046d5c <_http.session.Session.next+0x590>
100046cc8:     	mov	x10, #0x0               ; =0
100046ccc:     	movi.16b	v0, #0x20
100046cd0:     	ldr	q1, [x22, x10]
100046cd4:     	cmeq.16b	v2, v1, v0
100046cd8:     	umaxv.16b	b2, v2
100046cdc:     	fmov	w11, s2
100046ce0:     	tbnz	w11, #0x0, 0x100046e50 <_http.session.Session.next+0x684>
100046ce4:     	add	x11, x22, x10
100046ce8:     	ldr	q1, [x11, #0x10]
100046cec:     	cmeq.16b	v2, v1, v0
100046cf0:     	umaxv.16b	b2, v2
100046cf4:     	fmov	w11, s2
100046cf8:     	tbnz	w11, #0x0, 0x100046e7c <_http.session.Session.next+0x6b0>
100046cfc:     	add	x14, x10, #0x20
100046d00:     	add	x11, x10, #0x40
100046d04:     	mov	x10, x14
100046d08:     	cmp	x11, x8
100046d0c:     	b.lo	0x100046cd0 <_http.session.Session.next+0x504>
100046d10:     	b	0x100046d60 <_http.session.Session.next+0x594>
100046d14:     	mov	x10, x9
100046d18:     	add	x11, x10, #0x10
100046d1c:     	cmp	x11, x8
100046d20:     	b.hs	0x100046e00 <_http.session.Session.next+0x634>
100046d24:     	ldr	q0, [x22, x10]
100046d28:     	movi.16b	v1, #0x20
100046d2c:     	cmeq.16b	v0, v0, v1
100046d30:     	umaxv.16b	b1, v0
100046d34:     	fmov	w12, s1
100046d38:     	tbz	w12, #0x0, 0x100046dfc <_http.session.Session.next+0x630>
100046d3c:     	adrp	x11, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046d40:     	ldr	q1, [x11, #0x9f0]
100046d44:     	movi.16b	v2, #0xf
100046d48:     	bsl.16b	v0, v1, v2
100046d4c:     	uminv.16b	b0, v0
100046d50:     	fmov	w11, s0
100046d54:     	and	x11, x11, #0xf
100046d58:     	b	0x100046e40 <_http.session.Session.next+0x674>
100046d5c:     	mov	x14, #0x0               ; =0
100046d60:     	add	x10, x14, #0x10
100046d64:     	cmp	x10, x8
100046d68:     	b.hs	0x100047084 <_http.session.Session.next+0x8b8>
100046d6c:     	ldr	q0, [x22, x14]
100046d70:     	movi.16b	v1, #0x20
100046d74:     	cmeq.16b	v0, v0, v1
100046d78:     	umaxv.16b	b1, v0
100046d7c:     	fmov	w11, s1
100046d80:     	tbz	w11, #0x0, 0x100047080 <_http.session.Session.next+0x8b4>
100046d84:     	adrp	x10, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046d88:     	ldr	q1, [x10, #0x9f0]
100046d8c:     	movi.16b	v2, #0xf
100046d90:     	bsl.16b	v0, v1, v2
100046d94:     	uminv.16b	b0, v0
100046d98:     	fmov	w10, s0
100046d9c:     	and	x10, x10, #0xf
100046da0:     	b	0x1000470c4 <_http.session.Session.next+0x8f8>
100046da4:     	movi.16b	v0, #0x20
100046da8:     	cmeq.16b	v0, v1, v0
100046dac:     	adrp	x10, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046db0:     	ldr	q1, [x10, #0x9f0]
100046db4:     	movi.16b	v2, #0xf
100046db8:     	bsl.16b	v0, v1, v2
100046dbc:     	uminv.16b	b0, v0
100046dc0:     	fmov	w10, s0
100046dc4:     	and	x10, x10, #0xf
100046dc8:     	b	0x100046e40 <_http.session.Session.next+0x674>
100046dcc:     	movi.16b	v0, #0x20
100046dd0:     	cmeq.16b	v0, v1, v0
100046dd4:     	adrp	x10, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046dd8:     	ldr	q1, [x10, #0x9f0]
100046ddc:     	movi.16b	v2, #0xf
100046de0:     	bsl.16b	v0, v1, v2
100046de4:     	uminv.16b	b0, v0
100046de8:     	fmov	w10, s0
100046dec:     	and	x10, x10, #0xf
100046df0:     	add	x10, x10, x11
100046df4:     	add	x10, x10, #0x10
100046df8:     	b	0x100046e44 <_http.session.Session.next+0x678>
100046dfc:     	mov	x10, x11
100046e00:     	add	x11, x10, #0x8
100046e04:     	cmp	x11, x8
100046e08:     	b.hs	0x100046ec4 <_http.session.Session.next+0x6f8>
100046e0c:     	ldr	d0, [x22, x10]
100046e10:     	movi.8b	v1, #0x20
100046e14:     	cmeq.8b	v0, v0, v1
100046e18:     	umaxv.8b	b1, v0
100046e1c:     	fmov	w12, s1
100046e20:     	tbz	w12, #0x0, 0x100046eac <_http.session.Session.next+0x6e0>
100046e24:     	adrp	x11, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046e28:     	ldr	d1, [x11, #0xb90]
100046e2c:     	movi.8b	v2, #0x7
100046e30:     	bsl.8b	v0, v1, v2
100046e34:     	uminv.8b	b0, v0
100046e38:     	fmov	w11, s0
100046e3c:     	and	x11, x11, #0x7
100046e40:     	add	x10, x10, x11
100046e44:     	add	x11, x10, #0x1
100046e48:     	mov	w12, #0x1               ; =1
100046e4c:     	b	0x100046ed8 <_http.session.Session.next+0x70c>
100046e50:     	movi.16b	v0, #0x20
100046e54:     	cmeq.16b	v0, v1, v0
100046e58:     	adrp	x11, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046e5c:     	ldr	q1, [x11, #0x9f0]
100046e60:     	movi.16b	v2, #0xf
100046e64:     	bsl.16b	v0, v1, v2
100046e68:     	uminv.16b	b0, v0
100046e6c:     	fmov	w11, s0
100046e70:     	and	x11, x11, #0xf
100046e74:     	add	x14, x11, x10
100046e78:     	b	0x1000470c8 <_http.session.Session.next+0x8fc>
100046e7c:     	movi.16b	v0, #0x20
100046e80:     	cmeq.16b	v0, v1, v0
100046e84:     	adrp	x11, 0x10014a000 <dyld_stub_binder+0x10014a000>
100046e88:     	ldr	q1, [x11, #0x9f0]
100046e8c:     	movi.16b	v2, #0xf
100046e90:     	bsl.16b	v0, v1, v2
100046e94:     	uminv.16b	b0, v0
100046e98:     	fmov	w11, s0
100046e9c:     	and	x11, x11, #0xf
100046ea0:     	add	x10, x11, x10
100046ea4:     	add	x14, x10, #0x10
100046ea8:     	b	0x1000470c8 <_http.session.Session.next+0x8fc>
100046eac:     	mov	x10, x11
100046eb0:     	b	0x100046ec4 <_http.session.Session.next+0x6f8>
100046eb4:     	ldrb	w11, [x22, x10]
100046eb8:     	cmp	w11, #0x20
100046ebc:     	b.eq	0x100046e44 <_http.session.Session.next+0x678>
100046ec0:     	add	x10, x10, #0x1
100046ec4:     	cmp	x8, x10
100046ec8:     	b.ne	0x100046eb4 <_http.session.Session.next+0x6e8>
100046ecc:     	mov	w12, #0x0               ; =0
100046ed0:     	mov	x11, #0x0               ; =0
100046ed4:     	mov	x10, x8
100046ed8:     	cbz	x22, 0x10004730c <_http.session.Session.next+0xb40>
100046edc:     	cbz	w12, 0x100046f44 <_http.session.Session.next+0x778>
100046ee0:     	mov	w9, #0x40               ; =64
100046ee4:     	cmp	x11, x8
100046ee8:     	b.hs	0x100047310 <_http.session.Session.next+0xb44>
100046eec:     	add	x10, x11, #0x20
100046ef0:     	cmp	x10, x8
100046ef4:     	b.hs	0x100047310 <_http.session.Session.next+0xb44>
100046ef8:     	add	x9, x11, x22
100046efc:     	add	x10, x9, #0x10
100046f00:     	add	x11, x11, #0x20
100046f04:     	movi.16b	v0, #0x20
100046f08:     	ldur	q1, [x10, #-0x10]
100046f0c:     	cmeq.16b	v1, v1, v0
100046f10:     	umaxv.16b	b1, v1
100046f14:     	fmov	w9, s1
100046f18:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046f1c:     	ldr	q1, [x10], #0x20
100046f20:     	cmeq.16b	v1, v1, v0
100046f24:     	umaxv.16b	b1, v1
100046f28:     	fmov	w9, s1
100046f2c:     	tbnz	w9, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046f30:     	add	x11, x11, #0x20
100046f34:     	mov	w9, #0x40               ; =64
100046f38:     	cmp	x11, x8
100046f3c:     	b.lo	0x100046f08 <_http.session.Session.next+0x73c>
100046f40:     	b	0x100047310 <_http.session.Session.next+0xb44>
100046f44:     	stp	x14, x15, [sp, #0x70]
100046f48:     	str	x13, [sp, #0x80]
100046f4c:     	add	x24, x22, x9
100046f50:     	sub	x28, x10, x9
100046f54:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
100046f58:     	add	x2, x2, #0xce6
100046f5c:     	mov	x0, x24
100046f60:     	mov	x1, x28
100046f64:     	mov	w3, #0x8                ; =8
100046f68:     	bl	0x100061bec <_mem.eql__func_47>
100046f6c:     	tbnz	w0, #0x0, 0x100046f8c <_http.session.Session.next+0x7c0>
100046f70:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
100046f74:     	add	x2, x2, #0xcef
100046f78:     	mov	x0, x24
100046f7c:     	mov	x1, x28
100046f80:     	mov	w3, #0x8                ; =8
100046f84:     	bl	0x100061bec <_mem.eql__func_47>
100046f88:     	tbz	w0, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046f8c:     	stp	x28, x24, [sp, #0x60]
100046f90:     	ldp	x28, x0, [sp, #0x78]
100046f94:     	mov	x1, x28
100046f98:     	bl	0x100056410 <_http.parser.validRequestTarget>
100046f9c:     	tbz	w0, #0x0, 0x10004730c <_http.session.Session.next+0xb40>
100046fa0:     	sub	x0, x29, #0xe2
100046fa4:     	mov	x1, x22
100046fa8:     	ldr	x2, [sp, #0x70]
100046fac:     	bl	0x1000562e4 <_http.status.Method.parse>
100046fb0:     	ldurb	w8, [x29, #-0xe1]
100046fb4:     	tbz	w8, #0x0, 0x100047078 <_http.session.Session.next+0x8ac>
100046fb8:     	ldurb	w8, [x29, #-0xe2]
100046fbc:     	str	w8, [sp, #0x44]
100046fc0:     	sub	x0, x29, #0xe0
100046fc4:     	ldr	x24, [sp, #0x80]
100046fc8:     	mov	x1, x24
100046fcc:     	mov	x2, x28
100046fd0:     	mov	w3, #0x3f               ; =63
100046fd4:     	bl	0x1000130fc <_mem.findScalar__func_139>
100046fd8:     	ldurb	w8, [x29, #-0xd8]
100046fdc:     	ldur	x9, [x29, #-0xe0]
100046fe0:     	add	x10, x9, #0x1
100046fe4:     	add	x11, x24, x10
100046fe8:     	sub	x10, x28, x10
100046fec:     	tst	w8, #0x1
100046ff0:     	csel	x8, x10, xzr, ne
100046ff4:     	str	x8, [sp, #0x38]
100046ff8:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
100046ffc:     	add	x8, x8, #0x877
100047000:     	csel	x10, x11, x8, ne
100047004:     	csel	x8, x9, x28, ne
100047008:     	stp	x8, x10, [sp, #0x28]
10004700c:     	stur	xzr, [x29, #-0xc0]
100047010:     	adrp	x8, 0x10014f000 <___anon_24395>
100047014:     	add	x8, x8, #0x320
100047018:     	ldr	q0, [x8]
10004701c:     	stur	q0, [x29, #-0xd0]
100047020:     	sub	x0, x29, #0xd0
100047024:     	add	x1, sp, #0x88
100047028:     	mov	w2, #0x10               ; =16
10004702c:     	bl	0x1000561b8 <_array_list.Aligned(http.request.Header,null).ensureTotalCapacity>
100047030:     	ands	w9, w0, #0xffff
100047034:     	b.ne	0x100047b0c <_http.session.Session.next+0x1340>
100047038:     	add	x8, x26, #0x4
10004703c:     	str	x8, [sp, #0x48]
100047040:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
100047044:     	add	x2, x2, #0xce6
100047048:     	ldp	x1, x0, [sp, #0x60]
10004704c:     	mov	w3, #0x8                ; =8
100047050:     	bl	0x100061bec <_mem.eql__func_47>
100047054:     	str	w0, [sp, #0x54]
100047058:     	add	x0, sp, #0xb0
10004705c:     	bl	0x1000564cc <_mem.SplitIterator(u8,.sequence).next>
100047060:     	cbz	x0, 0x10004718c <_http.session.Session.next+0x9c0>
100047064:     	mov	x24, x0
100047068:     	mov	x28, x1
10004706c:     	str	wzr, [sp, #0x1c]
100047070:     	str	xzr, [sp, #0x20]
100047074:     	b	0x10004740c <_http.session.Session.next+0xc40>
100047078:     	mov	w9, #0x42               ; =66
10004707c:     	b	0x100047310 <_http.session.Session.next+0xb44>
100047080:     	mov	x14, x10
100047084:     	add	x10, x14, #0x8
100047088:     	cmp	x10, x8
10004708c:     	b.hs	0x100047180 <_http.session.Session.next+0x9b4>
100047090:     	ldr	d0, [x22, x14]
100047094:     	movi.8b	v1, #0x20
100047098:     	cmeq.8b	v0, v0, v1
10004709c:     	umaxv.8b	b1, v0
1000470a0:     	fmov	w11, s1
1000470a4:     	tbz	w11, #0x0, 0x100047168 <_http.session.Session.next+0x99c>
1000470a8:     	adrp	x10, 0x10014a000 <dyld_stub_binder+0x10014a000>
1000470ac:     	ldr	d1, [x10, #0xb90]
1000470b0:     	movi.8b	v2, #0x7
1000470b4:     	bsl.8b	v0, v1, v2
1000470b8:     	uminv.8b	b0, v0
1000470bc:     	fmov	w10, s0
1000470c0:     	and	x10, x10, #0x7
1000470c4:     	add	x14, x14, x10
1000470c8:     	add	x10, x14, #0x1
1000470cc:     	cmp	x10, x8
1000470d0:     	b.hs	0x1000472f8 <_http.session.Session.next+0xb2c>
1000470d4:     	add	x12, x14, #0x21
1000470d8:     	add	x11, x14, #0x1
1000470dc:     	cmp	x12, x8
1000470e0:     	b.hs	0x100047124 <_http.session.Session.next+0x958>
1000470e4:     	movi.16b	v0, #0x20
1000470e8:     	add	x11, x22, x12
1000470ec:     	ldur	q1, [x11, #-0x20]
1000470f0:     	cmeq.16b	v2, v1, v0
1000470f4:     	umaxv.16b	b2, v2
1000470f8:     	fmov	w13, s2
1000470fc:     	tbnz	w13, #0x0, 0x1000471b4 <_http.session.Session.next+0x9e8>
100047100:     	ldur	q1, [x11, #-0x10]
100047104:     	cmeq.16b	v2, v1, v0
100047108:     	umaxv.16b	b2, v2
10004710c:     	fmov	w11, s2
100047110:     	tbnz	w11, #0x0, 0x1000471e4 <_http.session.Session.next+0xa18>
100047114:     	add	x12, x12, #0x20
100047118:     	cmp	x12, x8
10004711c:     	b.lo	0x1000470e8 <_http.session.Session.next+0x91c>
100047120:     	sub	x11, x12, #0x20
100047124:     	add	x12, x11, #0x10
100047128:     	cmp	x12, x8
10004712c:     	b.hs	0x100047218 <_http.session.Session.next+0xa4c>
100047130:     	ldr	q0, [x22, x11]
100047134:     	movi.16b	v1, #0x20
100047138:     	cmeq.16b	v0, v0, v1
10004713c:     	umaxv.16b	b1, v0
100047140:     	fmov	w13, s1
100047144:     	tbz	w13, #0x0, 0x100047214 <_http.session.Session.next+0xa48>
100047148:     	adrp	x9, 0x10014a000 <dyld_stub_binder+0x10014a000>
10004714c:     	ldr	q1, [x9, #0x9f0]
100047150:     	movi.16b	v2, #0xf
100047154:     	bsl.16b	v0, v1, v2
100047158:     	uminv.16b	b0, v0
10004715c:     	fmov	w9, s0
100047160:     	and	x9, x9, #0xf
100047164:     	b	0x100047258 <_http.session.Session.next+0xa8c>
100047168:     	mov	x14, x10
10004716c:     	b	0x100047180 <_http.session.Session.next+0x9b4>
100047170:     	ldrb	w10, [x22, x14]
100047174:     	cmp	w10, #0x20
100047178:     	b.eq	0x1000470c8 <_http.session.Session.next+0x8fc>
10004717c:     	add	x14, x14, #0x1
100047180:     	cmp	x8, x14
100047184:     	b.ne	0x100047170 <_http.session.Session.next+0x9a4>
100047188:     	b	0x100046bb4 <_http.session.Session.next+0x3e8>
10004718c:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
100047190:     	add	x2, x2, #0xce6
100047194:     	ldp	x21, x20, [sp, #0x60]
100047198:     	mov	x0, x20
10004719c:     	mov	x1, x21
1000471a0:     	mov	w3, #0x8                ; =8
1000471a4:     	bl	0x100061bec <_mem.eql__func_47>
1000471a8:     	tbz	w0, #0x0, 0x100047270 <_http.session.Session.next+0xaa4>
1000471ac:     	mov	w9, #0x41               ; =65
1000471b0:     	b	0x100047310 <_http.session.Session.next+0xb44>
1000471b4:     	movi.16b	v0, #0x20
1000471b8:     	cmeq.16b	v0, v1, v0
1000471bc:     	adrp	x9, 0x10014a000 <dyld_stub_binder+0x10014a000>
1000471c0:     	ldr	q1, [x9, #0x9f0]
1000471c4:     	movi.16b	v2, #0xf
1000471c8:     	bsl.16b	v0, v1, v2
1000471cc:     	uminv.16b	b0, v0
1000471d0:     	fmov	w9, s0
1000471d4:     	and	x9, x9, #0xf
1000471d8:     	add	x9, x9, x12
1000471dc:     	sub	x11, x9, #0x20
1000471e0:     	b	0x10004725c <_http.session.Session.next+0xa90>
1000471e4:     	movi.16b	v0, #0x20
1000471e8:     	cmeq.16b	v0, v1, v0
1000471ec:     	adrp	x9, 0x10014a000 <dyld_stub_binder+0x10014a000>
1000471f0:     	ldr	q1, [x9, #0x9f0]
1000471f4:     	movi.16b	v2, #0xf
1000471f8:     	bsl.16b	v0, v1, v2
1000471fc:     	uminv.16b	b0, v0
100047200:     	fmov	w9, s0
100047204:     	and	x9, x9, #0xf
100047208:     	add	x9, x9, x12
10004720c:     	sub	x11, x9, #0x10
100047210:     	b	0x10004725c <_http.session.Session.next+0xa90>
100047214:     	mov	x11, x12
100047218:     	add	x12, x11, #0x8
10004721c:     	cmp	x12, x8
100047220:     	b.hs	0x1000472f0 <_http.session.Session.next+0xb24>
100047224:     	ldr	d0, [x22, x11]
100047228:     	movi.8b	v1, #0x20
10004722c:     	cmeq.8b	v0, v0, v1
100047230:     	umaxv.8b	b1, v0
100047234:     	fmov	w13, s1
100047238:     	tbz	w13, #0x0, 0x1000472d8 <_http.session.Session.next+0xb0c>
10004723c:     	adrp	x9, 0x10014a000 <dyld_stub_binder+0x10014a000>
100047240:     	ldr	d1, [x9, #0xb90]
100047244:     	movi.8b	v2, #0x7
100047248:     	bsl.8b	v0, v1, v2
10004724c:     	uminv.8b	b0, v0
100047250:     	fmov	w9, s0
100047254:     	and	x9, x9, #0x7
100047258:     	add	x11, x11, x9
10004725c:     	add	x9, x11, #0x1
100047260:     	str	x9, [sp, #0xf0]
100047264:     	mov	w9, #0x1                ; =1
100047268:     	strb	w9, [sp, #0xf8]
10004726c:     	b	0x100047300 <_http.session.Session.next+0xb34>
100047270:     	mov	x8, #0x0                ; =0
100047274:     	adrp	x9, 0x100158000 <_sqlite3LogEst.a+0x2>
100047278:     	add	x9, x9, #0x877
10004727c:     	ldr	w10, [sp, #0x44]
100047280:     	and	w10, w10, #0x7
100047284:     	ldp	x11, x12, [x29, #-0xd0]
100047288:     	ldr	w13, [sp, #0x54]
10004728c:     	and	w13, w13, #0x1
100047290:     	strh	wzr, [x19, #0x78]
100047294:     	mov	w14, #0x1               ; =1
100047298:     	strb	w14, [x19, #0x70]
10004729c:     	ldr	x14, [sp, #0x70]
1000472a0:     	stp	x22, x14, [x19]
1000472a4:     	ldr	x15, [sp, #0x80]
1000472a8:     	ldr	x14, [sp, #0x28]
1000472ac:     	stp	x15, x14, [x19, #0x10]
1000472b0:     	ldp	x15, x14, [sp, #0x30]
1000472b4:     	stp	x15, x14, [x19, #0x20]
1000472b8:     	stp	x20, x21, [x19, #0x30]
1000472bc:     	stp	x11, x12, [x19, #0x40]
1000472c0:     	stp	x9, x8, [x19, #0x50]
1000472c4:     	strb	w10, [x19, #0x60]
1000472c8:     	strb	w13, [x19, #0x61]
1000472cc:     	ldr	x8, [sp, #0x48]
1000472d0:     	str	x8, [x19, #0x68]
1000472d4:     	b	0x100047378 <_http.session.Session.next+0xbac>
1000472d8:     	mov	x11, x12
1000472dc:     	b	0x1000472f0 <_http.session.Session.next+0xb24>
1000472e0:     	ldrb	w12, [x22, x11]
1000472e4:     	cmp	w12, #0x20
1000472e8:     	b.eq	0x10004725c <_http.session.Session.next+0xa90>
1000472ec:     	add	x11, x11, #0x1
1000472f0:     	cmp	x8, x11
1000472f4:     	b.ne	0x1000472e0 <_http.session.Session.next+0xb14>
1000472f8:     	stp	xzr, xzr, [x9]
1000472fc:     	mov	x11, x8
100047300:     	add	x13, x22, x10
100047304:     	sub	x15, x11, x10
100047308:     	cbnz	x13, 0x100046bc8 <_http.session.Session.next+0x3fc>
10004730c:     	mov	w9, #0x40               ; =64
100047310:     	strh	wzr, [x19, #0x78]
100047314:     	mov	w8, #0x2                ; =2
100047318:     	strb	w8, [x19, #0x70]
10004731c:     	cmp	w9, #0x43
100047320:     	b.eq	0x100047360 <_http.session.Session.next+0xb94>
100047324:     	cmp	w9, #0x44
100047328:     	b.eq	0x10004734c <_http.session.Session.next+0xb80>
10004732c:     	cmp	w9, #0x45
100047330:     	b.ne	0x100047398 <_http.session.Session.next+0xbcc>
100047334:     	mov	w8, #0x1f5              ; =501
100047338:     	strh	w8, [x19, #0x10]
10004733c:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
100047340:     	add	x8, x8, #0x9a7
100047344:     	mov	w9, #0x1d               ; =29
100047348:     	b	0x100047374 <_http.session.Session.next+0xba8>
10004734c:     	mov	w8, #0x19d              ; =413
100047350:     	strh	w8, [x19, #0x10]
100047354:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
100047358:     	add	x8, x8, #0x995
10004735c:     	b	0x100047370 <_http.session.Session.next+0xba4>
100047360:     	mov	w8, #0x1af              ; =431
100047364:     	strh	w8, [x19, #0x10]
100047368:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
10004736c:     	add	x8, x8, #0x983
100047370:     	mov	w9, #0x11               ; =17
100047374:     	stp	x8, x9, [x19]
100047378:     	add	sp, sp, #0x1a0
10004737c:     	ldp	x29, x30, [sp, #0x50]
100047380:     	ldp	x20, x19, [sp, #0x40]
100047384:     	ldp	x22, x21, [sp, #0x30]
100047388:     	ldp	x24, x23, [sp, #0x20]
10004738c:     	ldp	x26, x25, [sp, #0x10]
100047390:     	ldp	x28, x27, [sp], #0x60
100047394:     	ret
100047398:     	mov	w8, #0x190              ; =400
10004739c:     	strh	w8, [x19, #0x10]
1000473a0:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
1000473a4:     	add	x8, x8, #0x598
1000473a8:     	mov	w9, #0xb                ; =11
1000473ac:     	b	0x100047374 <_http.session.Session.next+0xba8>
1000473b0:     	ldp	x24, x28, [sp, #0x8]
1000473b4:     	mov	x0, x28
1000473b8:     	mov	x1, x24
1000473bc:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
1000473c0:     	add	x2, x2, #0xcfb
1000473c4:     	mov	w3, #0x5                ; =5
1000473c8:     	bl	0x100055ae0 <_http.request.containsIgnoreCase>
1000473cc:     	eor	w8, w0, #0x1
1000473d0:     	ldr	w9, [sp, #0x54]
1000473d4:     	and	w26, w8, w9
1000473d8:     	mov	x0, x28
1000473dc:     	mov	x1, x24
1000473e0:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
1000473e4:     	add	x2, x2, #0xd01
1000473e8:     	mov	w3, #0xa                ; =10
1000473ec:     	bl	0x100055ae0 <_http.request.containsIgnoreCase>
1000473f0:     	orr	w8, w0, w26
1000473f4:     	str	w8, [sp, #0x54]
1000473f8:     	add	x0, sp, #0xb0
1000473fc:     	bl	0x1000564cc <_mem.SplitIterator(u8,.sequence).next>
100047400:     	mov	x24, x0
100047404:     	mov	x28, x1
100047408:     	cbz	x0, 0x100047a54 <_http.session.Session.next+0x1288>
10004740c:     	cbz	x28, 0x1000473f8 <_http.session.Session.next+0xc2c>
100047410:     	ldur	x8, [x29, #-0xc8]
100047414:     	cmp	x8, x25
100047418:     	b.hs	0x1000469f0 <_http.session.Session.next+0x224>
10004741c:     	sub	x0, x29, #0xb8
100047420:     	mov	x1, x24
100047424:     	mov	x2, x28
100047428:     	mov	w3, #0x3a               ; =58
10004742c:     	bl	0x1000130fc <_mem.findScalar__func_139>
100047430:     	ldurb	w8, [x29, #-0xb0]
100047434:     	tbz	w8, #0x0, 0x1000471ac <_http.session.Session.next+0x9e0>
100047438:     	ldur	x8, [x29, #-0xb8]
10004743c:     	str	x8, [sp, #0x58]
100047440:     	add	x8, x8, #0x1
100047444:     	sub	x1, x28, x8
100047448:     	add	x0, x24, x8
10004744c:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
100047450:     	add	x2, x2, #0xcf8
100047454:     	mov	w3, #0x2                ; =2
100047458:     	bl	0x100066fa4 <_mem.trim__func_22>
10004745c:     	mov	x26, x0
100047460:     	mov	x28, x1
100047464:     	str	x24, [sp, #0x78]
100047468:     	mov	x0, x24
10004746c:     	ldr	x1, [sp, #0x58]
100047470:     	mov	x24, x1
100047474:     	bl	0x100056130 <_http.parser.validFieldName>
100047478:     	tbz	w0, #0x0, 0x1000471ac <_http.session.Session.next+0x9e0>
10004747c:     	mov	x8, x26
100047480:     	mov	x10, x28
100047484:     	mov	w13, #0x1               ; =1
100047488:     	mov	w14, #0x2401            ; =9217
10004748c:     	mov	x15, x28
100047490:     	cbz	x28, 0x1000474d0 <_http.session.Session.next+0xd04>
100047494:     	ldrb	w11, [x8], #0x1
100047498:     	cmp	w11, #0xd
10004749c:     	lsl	w9, w13, w11
1000474a0:     	and	w9, w9, w14
1000474a4:     	ccmp	w9, #0x0, #0x4, ls
1000474a8:     	b.ne	0x1000471ac <_http.session.Session.next+0x9e0>
1000474ac:     	cmp	w11, #0x20
1000474b0:     	ccmp	w11, #0x9, #0x4, lo
1000474b4:     	cset	w12, ne
1000474b8:     	mov	w9, #0x41               ; =65
1000474bc:     	cmp	w11, #0x7f
1000474c0:     	b.eq	0x100047310 <_http.session.Session.next+0xb44>
1000474c4:     	tbnz	w12, #0x0, 0x100047310 <_http.session.Session.next+0xb44>
1000474c8:     	subs	x10, x10, #0x1
1000474cc:     	b.ne	0x100047494 <_http.session.Session.next+0xcc8>
1000474d0:     	mov	w28, #0x20              ; =32
1000474d4:     	ldr	x8, [sp, #0x78]
1000474d8:     	stp	x8, x24, [x29, #-0xa8]
1000474dc:     	stp	x15, x26, [sp, #0x8]
1000474e0:     	stp	x26, x15, [x29, #-0x98]
1000474e4:     	sub	x0, x29, #0xd0
1000474e8:     	add	x1, sp, #0x88
1000474ec:     	sub	x2, x29, #0xa8
1000474f0:     	bl	0x100030340 <_array_list.Aligned(debug.Dwarf.expression.StackMachine(.{ .addr_size = 8, .endian = .little, .call_frame_context = true }).Value,null).append>
1000474f4:     	ands	w9, w0, #0xffff
1000474f8:     	b.ne	0x100047b0c <_http.session.Session.next+0x1340>
1000474fc:     	cmp	x24, #0xd
100047500:     	b.gt	0x100047568 <_http.session.Session.next+0xd9c>
100047504:     	cmp	x24, #0x4
100047508:     	ldr	x12, [sp, #0x78]
10004750c:     	mov	w14, #0x20              ; =32
100047510:     	b.eq	0x1000479f4 <_http.session.Session.next+0x1228>
100047514:     	cmp	x24, #0xa
100047518:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004751c:     	mov	x8, #0x0                ; =0
100047520:     	ldrb	w9, [x12, x8]
100047524:     	adrp	x10, 0x100158000 <_sqlite3LogEst.a+0x2>
100047528:     	add	x10, x10, #0xa04
10004752c:     	ldrb	w10, [x10, x8]
100047530:     	sub	w11, w9, #0x41
100047534:     	cmp	w11, #0x1a
100047538:     	csel	w11, w14, wzr, lo
10004753c:     	orr	w9, w11, w9
100047540:     	sub	w11, w10, #0x41
100047544:     	cmp	w11, #0x1a
100047548:     	csel	w11, w14, wzr, lo
10004754c:     	orr	w10, w11, w10
100047550:     	cmp	w9, w10
100047554:     	b.ne	0x1000479ec <_http.session.Session.next+0x1220>
100047558:     	add	x8, x8, #0x1
10004755c:     	cmp	x24, x8
100047560:     	b.ne	0x100047520 <_http.session.Session.next+0xd54>
100047564:     	b	0x1000473b0 <_http.session.Session.next+0xbe4>
100047568:     	cmp	x24, #0xe
10004756c:     	b.eq	0x1000477b4 <_http.session.Session.next+0xfe8>
100047570:     	cmp	x24, #0x11
100047574:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047578:     	ldr	x8, [sp, #0x78]
10004757c:     	ldrb	w8, [x8]
100047580:     	sub	w9, w8, #0x41
100047584:     	cmp	w9, #0x1a
100047588:     	mov	w10, #0x20              ; =32
10004758c:     	csel	w9, w28, wzr, lo
100047590:     	orr	w8, w9, w8
100047594:     	cmp	w8, #0x74
100047598:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004759c:     	ldr	x8, [sp, #0x78]
1000475a0:     	ldrb	w8, [x8, #0x1]
1000475a4:     	sub	w9, w8, #0x41
1000475a8:     	cmp	w9, #0x1a
1000475ac:     	csel	w9, w10, wzr, lo
1000475b0:     	orr	w8, w9, w8
1000475b4:     	cmp	w8, #0x72
1000475b8:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000475bc:     	ldr	x8, [sp, #0x78]
1000475c0:     	ldrb	w8, [x8, #0x2]
1000475c4:     	sub	w9, w8, #0x41
1000475c8:     	cmp	w9, #0x1a
1000475cc:     	csel	w9, w10, wzr, lo
1000475d0:     	orr	w8, w9, w8
1000475d4:     	cmp	w8, #0x61
1000475d8:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000475dc:     	ldr	x8, [sp, #0x78]
1000475e0:     	ldrb	w8, [x8, #0x3]
1000475e4:     	sub	w9, w8, #0x41
1000475e8:     	cmp	w9, #0x1a
1000475ec:     	csel	w9, w10, wzr, lo
1000475f0:     	orr	w8, w9, w8
1000475f4:     	cmp	w8, #0x6e
1000475f8:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000475fc:     	ldr	x8, [sp, #0x78]
100047600:     	ldrb	w8, [x8, #0x4]
100047604:     	sub	w9, w8, #0x41
100047608:     	cmp	w9, #0x1a
10004760c:     	csel	w9, w10, wzr, lo
100047610:     	orr	w8, w9, w8
100047614:     	cmp	w8, #0x73
100047618:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004761c:     	ldr	x8, [sp, #0x78]
100047620:     	ldrb	w8, [x8, #0x5]
100047624:     	sub	w9, w8, #0x41
100047628:     	cmp	w9, #0x1a
10004762c:     	csel	w9, w10, wzr, lo
100047630:     	orr	w8, w9, w8
100047634:     	cmp	w8, #0x66
100047638:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004763c:     	ldr	x8, [sp, #0x78]
100047640:     	ldrb	w8, [x8, #0x6]
100047644:     	sub	w9, w8, #0x41
100047648:     	cmp	w9, #0x1a
10004764c:     	csel	w9, w10, wzr, lo
100047650:     	orr	w8, w9, w8
100047654:     	cmp	w8, #0x65
100047658:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004765c:     	ldr	x8, [sp, #0x78]
100047660:     	ldrb	w8, [x8, #0x7]
100047664:     	sub	w9, w8, #0x41
100047668:     	cmp	w9, #0x1a
10004766c:     	csel	w9, w10, wzr, lo
100047670:     	orr	w8, w9, w8
100047674:     	cmp	w8, #0x72
100047678:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004767c:     	ldr	x8, [sp, #0x78]
100047680:     	ldrb	w8, [x8, #0x8]
100047684:     	sub	w9, w8, #0x41
100047688:     	cmp	w9, #0x1a
10004768c:     	csel	w9, w10, wzr, lo
100047690:     	orr	w8, w9, w8
100047694:     	cmp	w8, #0x2d
100047698:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004769c:     	ldr	x8, [sp, #0x78]
1000476a0:     	ldrb	w8, [x8, #0x9]
1000476a4:     	sub	w9, w8, #0x41
1000476a8:     	cmp	w9, #0x1a
1000476ac:     	csel	w9, w10, wzr, lo
1000476b0:     	orr	w8, w9, w8
1000476b4:     	cmp	w8, #0x65
1000476b8:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000476bc:     	ldr	x8, [sp, #0x78]
1000476c0:     	ldrb	w8, [x8, #0xa]
1000476c4:     	sub	w9, w8, #0x41
1000476c8:     	cmp	w9, #0x1a
1000476cc:     	csel	w9, w10, wzr, lo
1000476d0:     	orr	w8, w9, w8
1000476d4:     	cmp	w8, #0x6e
1000476d8:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000476dc:     	ldr	x8, [sp, #0x78]
1000476e0:     	ldrb	w8, [x8, #0xb]
1000476e4:     	sub	w9, w8, #0x41
1000476e8:     	cmp	w9, #0x1a
1000476ec:     	csel	w9, w10, wzr, lo
1000476f0:     	orr	w8, w9, w8
1000476f4:     	cmp	w8, #0x63
1000476f8:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000476fc:     	ldr	x8, [sp, #0x78]
100047700:     	ldrb	w8, [x8, #0xc]
100047704:     	sub	w9, w8, #0x41
100047708:     	cmp	w9, #0x1a
10004770c:     	csel	w9, w10, wzr, lo
100047710:     	orr	w8, w9, w8
100047714:     	cmp	w8, #0x6f
100047718:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004771c:     	ldr	x8, [sp, #0x78]
100047720:     	ldrb	w8, [x8, #0xd]
100047724:     	sub	w9, w8, #0x41
100047728:     	cmp	w9, #0x1a
10004772c:     	csel	w9, w10, wzr, lo
100047730:     	orr	w8, w9, w8
100047734:     	cmp	w8, #0x64
100047738:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004773c:     	ldr	x8, [sp, #0x78]
100047740:     	ldrb	w8, [x8, #0xe]
100047744:     	sub	w9, w8, #0x41
100047748:     	cmp	w9, #0x1a
10004774c:     	csel	w9, w10, wzr, lo
100047750:     	orr	w8, w9, w8
100047754:     	cmp	w8, #0x69
100047758:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004775c:     	ldr	x8, [sp, #0x78]
100047760:     	ldrb	w8, [x8, #0xf]
100047764:     	sub	w9, w8, #0x41
100047768:     	cmp	w9, #0x1a
10004776c:     	csel	w9, w10, wzr, lo
100047770:     	orr	w8, w9, w8
100047774:     	cmp	w8, #0x6e
100047778:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004777c:     	ldr	x8, [sp, #0x78]
100047780:     	ldrb	w8, [x8, #0x10]
100047784:     	sub	w9, w8, #0x41
100047788:     	cmp	w9, #0x1a
10004778c:     	csel	w9, w10, wzr, lo
100047790:     	orr	w8, w9, w8
100047794:     	cmp	w8, #0x67
100047798:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
10004779c:     	ldp	x1, x0, [sp, #0x8]
1000477a0:     	bl	0x100055d8c <_http.parser.isOnlyChunked>
1000477a4:     	tbz	w0, #0x0, 0x100047b4c <_http.session.Session.next+0x1380>
1000477a8:     	mov	w8, #0x1                ; =1
1000477ac:     	str	w8, [sp, #0x20]
1000477b0:     	b	0x1000473f8 <_http.session.Session.next+0xc2c>
1000477b4:     	ldr	x8, [sp, #0x78]
1000477b8:     	ldrb	w8, [x8]
1000477bc:     	sub	w9, w8, #0x41
1000477c0:     	cmp	w9, #0x1a
1000477c4:     	mov	w10, #0x20              ; =32
1000477c8:     	csel	w9, w28, wzr, lo
1000477cc:     	orr	w8, w9, w8
1000477d0:     	cmp	w8, #0x63
1000477d4:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000477d8:     	ldr	x8, [sp, #0x78]
1000477dc:     	ldrb	w8, [x8, #0x1]
1000477e0:     	sub	w9, w8, #0x41
1000477e4:     	cmp	w9, #0x1a
1000477e8:     	csel	w9, w10, wzr, lo
1000477ec:     	orr	w8, w9, w8
1000477f0:     	cmp	w8, #0x6f
1000477f4:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000477f8:     	ldr	x8, [sp, #0x78]
1000477fc:     	ldrb	w8, [x8, #0x2]
100047800:     	sub	w9, w8, #0x41
100047804:     	cmp	w9, #0x1a
100047808:     	csel	w9, w10, wzr, lo
10004780c:     	orr	w8, w9, w8
100047810:     	cmp	w8, #0x6e
100047814:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047818:     	ldr	x8, [sp, #0x78]
10004781c:     	ldrb	w8, [x8, #0x3]
100047820:     	sub	w9, w8, #0x41
100047824:     	cmp	w9, #0x1a
100047828:     	csel	w9, w10, wzr, lo
10004782c:     	orr	w8, w9, w8
100047830:     	cmp	w8, #0x74
100047834:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047838:     	ldr	x8, [sp, #0x78]
10004783c:     	ldrb	w8, [x8, #0x4]
100047840:     	sub	w9, w8, #0x41
100047844:     	cmp	w9, #0x1a
100047848:     	csel	w9, w10, wzr, lo
10004784c:     	orr	w8, w9, w8
100047850:     	cmp	w8, #0x65
100047854:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047858:     	ldr	x8, [sp, #0x78]
10004785c:     	ldrb	w8, [x8, #0x5]
100047860:     	sub	w9, w8, #0x41
100047864:     	cmp	w9, #0x1a
100047868:     	csel	w9, w10, wzr, lo
10004786c:     	orr	w8, w9, w8
100047870:     	cmp	w8, #0x6e
100047874:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047878:     	ldr	x8, [sp, #0x78]
10004787c:     	ldrb	w8, [x8, #0x6]
100047880:     	sub	w9, w8, #0x41
100047884:     	cmp	w9, #0x1a
100047888:     	csel	w9, w10, wzr, lo
10004788c:     	orr	w8, w9, w8
100047890:     	cmp	w8, #0x74
100047894:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047898:     	ldr	x8, [sp, #0x78]
10004789c:     	ldrb	w8, [x8, #0x7]
1000478a0:     	sub	w9, w8, #0x41
1000478a4:     	cmp	w9, #0x1a
1000478a8:     	csel	w9, w10, wzr, lo
1000478ac:     	orr	w8, w9, w8
1000478b0:     	cmp	w8, #0x2d
1000478b4:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000478b8:     	ldr	x8, [sp, #0x78]
1000478bc:     	ldrb	w8, [x8, #0x8]
1000478c0:     	sub	w9, w8, #0x41
1000478c4:     	cmp	w9, #0x1a
1000478c8:     	csel	w9, w10, wzr, lo
1000478cc:     	orr	w8, w9, w8
1000478d0:     	cmp	w8, #0x6c
1000478d4:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000478d8:     	ldr	x8, [sp, #0x78]
1000478dc:     	ldrb	w8, [x8, #0x9]
1000478e0:     	sub	w9, w8, #0x41
1000478e4:     	cmp	w9, #0x1a
1000478e8:     	csel	w9, w10, wzr, lo
1000478ec:     	orr	w8, w9, w8
1000478f0:     	cmp	w8, #0x65
1000478f4:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000478f8:     	ldr	x8, [sp, #0x78]
1000478fc:     	ldrb	w8, [x8, #0xa]
100047900:     	sub	w9, w8, #0x41
100047904:     	cmp	w9, #0x1a
100047908:     	csel	w9, w10, wzr, lo
10004790c:     	orr	w8, w9, w8
100047910:     	cmp	w8, #0x6e
100047914:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047918:     	ldr	x8, [sp, #0x78]
10004791c:     	ldrb	w8, [x8, #0xb]
100047920:     	sub	w9, w8, #0x41
100047924:     	cmp	w9, #0x1a
100047928:     	csel	w9, w10, wzr, lo
10004792c:     	orr	w8, w9, w8
100047930:     	cmp	w8, #0x67
100047934:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047938:     	ldr	x8, [sp, #0x78]
10004793c:     	ldrb	w8, [x8, #0xc]
100047940:     	sub	w9, w8, #0x41
100047944:     	cmp	w9, #0x1a
100047948:     	csel	w9, w10, wzr, lo
10004794c:     	orr	w8, w9, w8
100047950:     	cmp	w8, #0x74
100047954:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047958:     	ldr	x8, [sp, #0x78]
10004795c:     	ldrb	w8, [x8, #0xd]
100047960:     	sub	w9, w8, #0x41
100047964:     	cmp	w9, #0x1a
100047968:     	csel	w9, w10, wzr, lo
10004796c:     	orr	w8, w9, w8
100047970:     	cmp	w8, #0x68
100047974:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047978:     	ldr	x8, [sp, #0x8]
10004797c:     	cbz	x8, 0x1000471ac <_http.session.Session.next+0x9e0>
100047980:     	mov	x9, #0x0                ; =0
100047984:     	ldr	x8, [sp, #0x8]
100047988:     	sub	x8, x8, #0x1
10004798c:     	ldr	x10, [sp, #0x10]
100047990:     	ldrb	w10, [x10, x9]
100047994:     	sub	w10, w10, #0x30
100047998:     	cmp	w10, #0x9
10004799c:     	ccmp	x8, x9, #0x4, ls
1000479a0:     	add	x9, x9, #0x1
1000479a4:     	b.ne	0x10004798c <_http.session.Session.next+0x11c0>
1000479a8:     	cmp	w10, #0x9
1000479ac:     	b.hi	0x1000471ac <_http.session.Session.next+0x9e0>
1000479b0:     	sub	x0, x29, #0x88
1000479b4:     	ldp	x2, x1, [sp, #0x8]
1000479b8:     	mov	w3, #0xa                ; =10
1000479bc:     	bl	0x100055edc <_fmt.parseInt__func_914>
1000479c0:     	ldurh	w8, [x29, #-0x80]
1000479c4:     	cmp	w8, #0x0
1000479c8:     	cset	w8, ne
1000479cc:     	ldr	w9, [sp, #0x1c]
1000479d0:     	orr	w8, w8, w9
1000479d4:     	tbnz	w8, #0x0, 0x100047b3c <_http.session.Session.next+0x1370>
1000479d8:     	mov	w8, #0x1                ; =1
1000479dc:     	str	w8, [sp, #0x1c]
1000479e0:     	ldur	x8, [x29, #-0x88]
1000479e4:     	str	x8, [sp]
1000479e8:     	b	0x1000473f8 <_http.session.Session.next+0xc2c>
1000479ec:     	cmp	x24, #0x4
1000479f0:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
1000479f4:     	adrp	x8, 0x100158000 <_sqlite3LogEst.a+0x2>
1000479f8:     	add	x8, x8, #0xd0c
1000479fc:     	ldrb	w9, [x12], #0x1
100047a00:     	ldrb	w10, [x8], #0x1
100047a04:     	sub	w11, w9, #0x41
100047a08:     	cmp	w11, #0x1a
100047a0c:     	csel	w11, w14, wzr, lo
100047a10:     	orr	w9, w11, w9
100047a14:     	sub	w11, w10, #0x41
100047a18:     	cmp	w11, #0x1a
100047a1c:     	csel	w11, w14, wzr, lo
100047a20:     	orr	w10, w11, w10
100047a24:     	cmp	w9, w10
100047a28:     	b.ne	0x1000473f8 <_http.session.Session.next+0xc2c>
100047a2c:     	subs	x24, x24, #0x1
100047a30:     	b.ne	0x1000479fc <_http.session.Session.next+0x1230>
100047a34:     	ldr	w8, [sp, #0x24]
100047a38:     	tbnz	w8, #0x0, 0x1000471ac <_http.session.Session.next+0x9e0>
100047a3c:     	ldp	x1, x0, [sp, #0x8]
100047a40:     	bl	0x100055680 <_http.parser.validHost>
100047a44:     	tbz	w0, #0x0, 0x1000471ac <_http.session.Session.next+0x9e0>
100047a48:     	mov	w8, #0x1                ; =1
100047a4c:     	str	w8, [sp, #0x24]
100047a50:     	b	0x1000473f8 <_http.session.Session.next+0xc2c>
100047a54:     	adrp	x2, 0x100158000 <_sqlite3LogEst.a+0x2>
100047a58:     	add	x2, x2, #0xce6
100047a5c:     	ldp	x1, x0, [sp, #0x60]
100047a60:     	mov	w3, #0x8                ; =8
100047a64:     	bl	0x100061bec <_mem.eql__func_47>
100047a68:     	ldr	w8, [sp, #0x24]
100047a6c:     	orn	w8, w8, w0
100047a70:     	tbz	w8, #0x0, 0x1000471ac <_http.session.Session.next+0x9e0>
100047a74:     	ldp	w9, w8, [sp, #0x1c]
100047a78:     	and	w8, w8, w9
100047a7c:     	tbz	w8, #0x0, 0x100047a88 <_http.session.Session.next+0x12bc>
100047a80:     	mov	w9, #0x46               ; =70
100047a84:     	b	0x100047310 <_http.session.Session.next+0xb44>
100047a88:     	ldr	w8, [sp, #0x20]
100047a8c:     	tbz	w8, #0x0, 0x100047acc <_http.session.Session.next+0x1300>
100047a90:     	ldr	x8, [sp, #0x48]
100047a94:     	sub	x3, x27, x8
100047a98:     	sub	x0, x29, #0x78
100047a9c:     	add	x1, sp, #0x88
100047aa0:     	add	x2, x22, x8
100047aa4:     	mov	x4, x23
100047aa8:     	bl	0x1000547b8 <_http.parser.decodeChunked>
100047aac:     	ldurh	w9, [x29, #-0x60]
100047ab0:     	cbnz	w9, 0x100047b0c <_http.session.Session.next+0x1340>
100047ab4:     	ldp	x9, x8, [x29, #-0x78]
100047ab8:     	ldur	x10, [x29, #-0x68]
100047abc:     	ldr	x11, [sp, #0x48]
100047ac0:     	add	x11, x10, x11
100047ac4:     	str	x11, [sp, #0x48]
100047ac8:     	b	0x100047b04 <_http.session.Session.next+0x1338>
100047acc:     	ldr	w8, [sp, #0x1c]
100047ad0:     	tbz	w8, #0x0, 0x100047af8 <_http.session.Session.next+0x132c>
100047ad4:     	ldr	x8, [sp]
100047ad8:     	cmp	x8, x23
100047adc:     	b.hi	0x100047af0 <_http.session.Session.next+0x1324>
100047ae0:     	ldr	x8, [sp, #0x48]
100047ae4:     	ldr	x9, [sp]
100047ae8:     	adds	x10, x8, x9
100047aec:     	b.lo	0x100047b20 <_http.session.Session.next+0x1354>
100047af0:     	mov	w9, #0x44               ; =68
100047af4:     	b	0x100047310 <_http.session.Session.next+0xb44>
100047af8:     	mov	x8, #0x0                ; =0
100047afc:     	adrp	x9, 0x100158000 <_sqlite3LogEst.a+0x2>
100047b00:     	add	x9, x9, #0x877
100047b04:     	ldp	x21, x20, [sp, #0x60]
100047b08:     	b	0x10004727c <_http.session.Session.next+0xab0>
100047b0c:     	cmp	w9, #0x1a
100047b10:     	b.ne	0x100047b54 <_http.session.Session.next+0x1388>
100047b14:     	mov	w8, #0x1a               ; =26
100047b18:     	strh	w8, [x19, #0x78]
100047b1c:     	b	0x100047378 <_http.session.Session.next+0xbac>
100047b20:     	cmp	x27, x10
100047b24:     	b.lo	0x1000468e4 <_http.session.Session.next+0x118>
100047b28:     	ldr	x8, [sp, #0x48]
100047b2c:     	add	x9, x22, x8
100047b30:     	sub	x8, x10, x8
100047b34:     	str	x10, [sp, #0x48]
100047b38:     	b	0x100047b04 <_http.session.Session.next+0x1338>
100047b3c:     	mov	w8, #0x46               ; =70
100047b40:     	mov	w9, #0x41               ; =65
100047b44:     	csel	w9, w9, w8, ne
100047b48:     	b	0x100047310 <_http.session.Session.next+0xb44>
100047b4c:     	mov	w9, #0x45               ; =69
100047b50:     	b	0x100047310 <_http.session.Session.next+0xb44>
100047b54:     	cmp	w9, #0x2d
100047b58:     	b.eq	0x1000468e4 <_http.session.Session.next+0x118>
100047b5c:     	b	0x100047310 <_http.session.Session.next+0xb44>
