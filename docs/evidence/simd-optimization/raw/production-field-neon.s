
/tmp/akamata-candidate-fast/bin/competitive-akamata:	file format mach-o arm64

Disassembly of section __TEXT,__text:

000000010005609c <_http.parser.validFieldValue>:
10005609c:     	stp	x29, x30, [sp, #-0x10]!
1000560a0:     	mov	x29, sp
1000560a4:     	cmp	x1, #0x10
1000560a8:     	b.lo	0x100056104 <_http.parser.validFieldValue+0x68>
1000560ac:     	and	x8, x1, #0xfffffffffffffff0
1000560b0:     	movi.16b	v0, #0x20
1000560b4:     	movi.16b	v1, #0x9
1000560b8:     	movi.16b	v2, #0x7f
1000560bc:     	mov	x10, x0
1000560c0:     	mov	x9, x1
1000560c4:     	ldr	q3, [x10], #0x10
1000560c8:     	cmhi.16b	v4, v0, v3
1000560cc:     	cmeq.16b	v5, v3, v1
1000560d0:     	bic.16b	v4, v4, v5
1000560d4:     	cmeq.16b	v3, v3, v2
1000560d8:     	orr.16b	v3, v3, v4
1000560dc:     	umaxv.16b	b3, v3
1000560e0:     	fmov	w11, s3
1000560e4:     	tbnz	w11, #0x0, 0x10005614c <_http.parser.validFieldValue+0xb0>
1000560e8:     	sub	x9, x9, #0x10
1000560ec:     	cmp	x9, #0xf
1000560f0:     	b.hi	0x1000560c4 <_http.parser.validFieldValue+0x28>
1000560f4:     	cmp	x1, x8
1000560f8:     	b.ne	0x100056114 <_http.parser.validFieldValue+0x78>
1000560fc:     	mov	w0, #0x1                ; =1
100056100:     	b	0x100056150 <_http.parser.validFieldValue+0xb4>
100056104:     	mov	x8, #0x0                ; =0
100056108:     	mov	x9, x1
10005610c:     	cmp	x1, x8
100056110:     	b.eq	0x1000560fc <_http.parser.validFieldValue+0x60>
100056114:     	add	x8, x0, x8
100056118:     	sub	x9, x9, #0x1
10005611c:     	mov	w10, #0x7f              ; =127
100056120:     	ldrb	w11, [x8], #0x1
100056124:     	cmp	w11, #0x1f
100056128:     	ccmp	w11, #0x9, #0x4, ls
10005612c:     	ccmp	w11, w10, #0x4, eq
100056130:     	cset	w0, ne
100056134:     	subs	x9, x9, #0x1
100056138:     	cset	w11, hs
10005613c:     	cmp	w0, #0x1
100056140:     	b.ne	0x100056150 <_http.parser.validFieldValue+0xb4>
100056144:     	tbnz	w11, #0x0, 0x100056120 <_http.parser.validFieldValue+0x84>
100056148:     	b	0x100056150 <_http.parser.validFieldValue+0xb4>
10005614c:     	mov	w0, #0x0                ; =0
100056150:     	ldp	x29, x30, [sp], #0x10
100056154:     	ret
