	.file	"simd-codegen"
	.functype	.Lsimd_codegen.mask_vector (i32, i32, i32) -> ()
	.functype	.Lsimd_candidates.maskCopy__func_0 (i32, i32, i32) -> ()
	.functype	.Lsimd_codegen.mask_word (i32, i32, i32) -> ()
	.functype	.Lsimd_candidates.maskCopy__func_1 (i32, i32, i32) -> ()
	.functype	.Lsimd_codegen.mask_byte (i32, i32, i32) -> ()
	.functype	.Lsimd_candidates.maskCopy__func_2 (i32, i32, i32) -> ()
	.functype	.Lsimd_codegen.std_search (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.field_vector (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_8 (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.field_scalar (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_10 (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.json_vector (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_11 (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.json_scalar (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_13 (i32, i32) -> (i32)
	.section	.text..Lsimd_codegen.mask_vector,"",@
	.type	.Lsimd_codegen.mask_vector,@function
.Lsimd_codegen.mask_vector:
	.functype	.Lsimd_codegen.mask_vector (i32, i32, i32) -> ()
	local.get	0
	local.get	2
	local.get	1
	call	.Lsimd_candidates.maskCopy__func_0
	end_function

	.section	.text..Lsimd_candidates.maskCopy__func_0,"",@
	.type	.Lsimd_candidates.maskCopy__func_0,@function
.Lsimd_candidates.maskCopy__func_0:
	.functype	.Lsimd_candidates.maskCopy__func_0 (i32, i32, i32) -> ()
	.local  	i32, i32, i32, i32, i32, i32, v128
	i32.const	0
	local.set	3
	block   	
	local.get	1
	i32.const	16
	i32.lt_u
	br_if   	0
	block   	
	block   	
	local.get	1
	i32.const	-16
	i32.add 
	local.tee	4
	i32.const	4
	i32.shr_u
	local.tee	3
	br_if   	0
	i32.const	0
	local.set	3
	br      	1
.LBB1_3:
	end_block
	block   	
	block   	
	block   	
	local.get	3
	i32.const	-1
	i32.add 
	i32.const	1
	i32.shr_u
	local.tee	3
	br_if   	0
	i32.const	0
	local.set	3
	br      	1
.LBB1_5:
	end_block
	local.get	3
	i32.const	1
	i32.add 
	local.tee	3
	i32.const	1
	i32.and 
	local.set	5
	local.get	3
	i32.const	-2
	i32.and 
	local.set	6
	i32.const	0
	local.set	3
.LBB1_6:
	loop    	
	local.get	0
	local.get	3
	i32.add 
	local.tee	7
	local.get	2
	local.get	3
	i32.add 
	local.tee	8
	v128.load	0:p2align=0
	v128.const	17, 99, 128, 255, 17, 99, 128, 255, 17, 99, 128, 255, 17, 99, 128, 255
	local.tee	9
	v128.xor
	v128.store	0:p2align=0
	local.get	7
	i32.const	16
	i32.add 
	local.get	8
	i32.const	16
	i32.add 
	v128.load	0:p2align=0
	local.get	9
	v128.xor
	v128.store	0:p2align=0
	local.get	7
	i32.const	32
	i32.add 
	local.get	8
	i32.const	32
	i32.add 
	v128.load	0:p2align=0
	local.get	9
	v128.xor
	v128.store	0:p2align=0
	local.get	7
	i32.const	48
	i32.add 
	local.get	8
	i32.const	48
	i32.add 
	v128.load	0:p2align=0
	local.get	9
	v128.xor
	v128.store	0:p2align=0
	local.get	3
	i32.const	64
	i32.add 
	local.set	3
	local.get	6
	i32.const	-2
	i32.add 
	local.tee	6
	br_if   	0
	end_loop
	local.get	5
	i32.eqz
	br_if   	1
.LBB1_8:
	end_block
	local.get	0
	local.get	3
	i32.add 
	local.tee	7
	local.get	2
	local.get	3
	i32.add 
	local.tee	8
	v128.load	0:p2align=0
	v128.const	17, 99, 128, 255, 17, 99, 128, 255, 17, 99, 128, 255, 17, 99, 128, 255
	local.tee	9
	v128.xor
	v128.store	0:p2align=0
	local.get	7
	i32.const	16
	i32.add 
	local.get	8
	i32.const	16
	i32.add 
	v128.load	0:p2align=0
	local.get	9
	v128.xor
	v128.store	0:p2align=0
	local.get	3
	i32.const	32
	i32.add 
	local.set	3
.LBB1_9:
	end_block
	local.get	4
	i32.const	16
	i32.and 
	br_if   	1
.LBB1_10:
	end_block
	local.get	0
	local.get	3
	i32.add 
	local.get	2
	local.get	3
	i32.add 
	v128.load	0:p2align=0
	v128.const	17, 99, 128, 255, 17, 99, 128, 255, 17, 99, 128, 255, 17, 99, 128, 255
	v128.xor
	v128.store	0:p2align=0
	local.get	3
	i32.const	16
	i32.add 
	local.set	3
.LBB1_11:
	end_block
	block   	
	local.get	1
	local.get	3
	i32.le_u
	br_if   	0
	local.get	3
	i32.const	1
	i32.add 
	local.set	7
	block   	
	local.get	1
	local.get	3
	i32.sub 
	i32.const	1
	i32.and 
	i32.eqz
	br_if   	0
	local.get	0
	local.get	3
	i32.add 
	local.get	3
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	3
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	7
	local.set	3
.LBB1_14:
	end_block
	local.get	1
	local.get	7
	i32.eq  
	br_if   	0
	i32.const	0
	local.get	1
	i32.sub 
	local.set	6
	local.get	3
	i32.const	4
	i32.add 
	local.set	3
.LBB1_16:
	loop    	
	local.get	0
	local.get	3
	i32.add 
	local.tee	7
	i32.const	-4
	i32.add 
	local.get	3
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	3
	i32.add 
	local.tee	8
	i32.const	-4
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	7
	i32.const	-3
	i32.add 
	local.get	3
	i32.const	-3
	i32.add 
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	8
	i32.const	-3
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	6
	local.get	3
	i32.const	2
	i32.add 
	local.tee	3
	i32.add 
	i32.const	4
	i32.ne  
	br_if   	0
.LBB1_17:
	end_loop
	end_block
	end_function

	.section	.text..Lsimd_codegen.mask_word,"",@
	.type	.Lsimd_codegen.mask_word,@function
.Lsimd_codegen.mask_word:
	.functype	.Lsimd_codegen.mask_word (i32, i32, i32) -> ()
	local.get	0
	local.get	2
	local.get	1
	call	.Lsimd_candidates.maskCopy__func_1
	end_function

	.section	.text..Lsimd_candidates.maskCopy__func_1,"",@
	.type	.Lsimd_candidates.maskCopy__func_1,@function
.Lsimd_candidates.maskCopy__func_1:
	.functype	.Lsimd_candidates.maskCopy__func_1 (i32, i32, i32) -> ()
	.local  	i32, i32, i32, i32, i32
	i32.const	0
	local.set	3
	block   	
	local.get	1
	i32.const	8
	i32.lt_u
	br_if   	0
	local.get	1
	i32.const	-8
	i32.add 
	local.tee	4
	i32.const	3
	i32.shr_u
	i32.const	1
	i32.add 
	local.tee	5
	i32.const	3
	i32.and 
	local.set	6
	i32.const	0
	local.set	3
	block   	
	local.get	4
	i32.const	24
	i32.lt_u
	br_if   	0
	i32.const	0
	local.set	3
	i32.const	0
	local.get	5
	i32.const	1073741820
	i32.and 
	i32.sub 
	local.set	7
.LBB3_3:
	loop    	
	local.get	0
	local.get	3
	i32.add 
	local.tee	4
	local.get	2
	local.get	3
	i32.add 
	local.tee	5
	i64.load	0:p2align=0
	i64.const	-35919868066766063
	i64.xor 
	i64.store	0:p2align=0
	local.get	4
	i32.const	8
	i32.add 
	local.get	5
	i32.const	8
	i32.add 
	i64.load	0:p2align=0
	i64.const	-35919868066766063
	i64.xor 
	i64.store	0:p2align=0
	local.get	4
	i32.const	16
	i32.add 
	local.get	5
	i32.const	16
	i32.add 
	i64.load	0:p2align=0
	i64.const	-35919868066766063
	i64.xor 
	i64.store	0:p2align=0
	local.get	4
	i32.const	24
	i32.add 
	local.get	5
	i32.const	24
	i32.add 
	i64.load	0:p2align=0
	i64.const	-35919868066766063
	i64.xor 
	i64.store	0:p2align=0
	local.get	3
	i32.const	32
	i32.add 
	local.set	3
	local.get	7
	i32.const	4
	i32.add 
	local.tee	7
	br_if   	0
	end_loop
	local.get	6
	i32.eqz
	br_if   	1
.LBB3_5:
	end_block
.LBB3_6:
	loop    	
	local.get	0
	local.get	3
	i32.add 
	local.get	2
	local.get	3
	i32.add 
	i64.load	0:p2align=0
	i64.const	-35919868066766063
	i64.xor 
	i64.store	0:p2align=0
	local.get	3
	i32.const	8
	i32.add 
	local.set	3
	local.get	6
	i32.const	-1
	i32.add 
	local.tee	6
	br_if   	0
.LBB3_7:
	end_loop
	end_block
	block   	
	local.get	1
	local.get	3
	i32.le_u
	br_if   	0
	local.get	3
	i32.const	1
	i32.add 
	local.set	4
	block   	
	local.get	1
	local.get	3
	i32.sub 
	i32.const	1
	i32.and 
	i32.eqz
	br_if   	0
	local.get	0
	local.get	3
	i32.add 
	local.get	3
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	3
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	4
	local.set	3
.LBB3_10:
	end_block
	local.get	1
	local.get	4
	i32.eq  
	br_if   	0
	i32.const	0
	local.get	1
	i32.sub 
	local.set	6
	local.get	3
	i32.const	4
	i32.add 
	local.set	3
.LBB3_12:
	loop    	
	local.get	0
	local.get	3
	i32.add 
	local.tee	4
	i32.const	-4
	i32.add 
	local.get	3
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	3
	i32.add 
	local.tee	5
	i32.const	-4
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	4
	i32.const	-3
	i32.add 
	local.get	3
	i32.const	-3
	i32.add 
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	5
	i32.const	-3
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	6
	local.get	3
	i32.const	2
	i32.add 
	local.tee	3
	i32.add 
	i32.const	4
	i32.ne  
	br_if   	0
.LBB3_13:
	end_loop
	end_block
	end_function

	.section	.text..Lsimd_codegen.mask_byte,"",@
	.type	.Lsimd_codegen.mask_byte,@function
.Lsimd_codegen.mask_byte:
	.functype	.Lsimd_codegen.mask_byte (i32, i32, i32) -> ()
	local.get	0
	local.get	2
	local.get	1
	call	.Lsimd_candidates.maskCopy__func_2
	end_function

	.section	.text..Lsimd_candidates.maskCopy__func_2,"",@
	.type	.Lsimd_candidates.maskCopy__func_2,@function
.Lsimd_candidates.maskCopy__func_2:
	.functype	.Lsimd_candidates.maskCopy__func_2 (i32, i32, i32) -> ()
	.local  	i32, i32, i32, i32, i32, i32
	block   	
	local.get	1
	i32.eqz
	br_if   	0
	i32.const	0
	local.set	3
	block   	
	local.get	1
	i32.const	1
	i32.eq  
	br_if   	0
	local.get	1
	i32.const	1
	i32.and 
	local.set	4
	block   	
	block   	
	block   	
	local.get	1
	i32.const	-2
	i32.add 
	i32.const	1
	i32.shr_u
	local.tee	3
	br_if   	0
	i32.const	0
	local.set	3
	br      	1
.LBB5_4:
	end_block
	local.get	3
	i32.const	1
	i32.add 
	local.tee	3
	i32.const	1
	i32.and 
	local.set	5
	local.get	3
	i32.const	-2
	i32.and 
	local.set	6
	i32.const	0
	local.set	3
.LBB5_5:
	loop    	
	local.get	0
	local.get	3
	i32.add 
	local.tee	7
	local.get	2
	local.get	3
	i32.add 
	local.tee	8
	i32.load8_u	0
	i32.const	17
	i32.xor 
	i32.store8	0
	local.get	7
	i32.const	1
	i32.add 
	local.get	8
	i32.const	1
	i32.add 
	i32.load8_u	0
	i32.const	99
	i32.xor 
	i32.store8	0
	local.get	7
	i32.const	2
	i32.add 
	local.get	8
	i32.const	2
	i32.add 
	i32.load8_u	0
	i32.const	128
	i32.xor 
	i32.store8	0
	local.get	7
	i32.const	3
	i32.add 
	local.get	8
	i32.const	3
	i32.add 
	i32.load8_u	0
	i32.const	-1
	i32.xor 
	i32.store8	0
	local.get	3
	i32.const	4
	i32.add 
	local.set	3
	local.get	6
	i32.const	-2
	i32.add 
	local.tee	6
	br_if   	0
	end_loop
	local.get	5
	i32.eqz
	br_if   	1
.LBB5_7:
	end_block
	local.get	0
	local.get	3
	i32.add 
	local.tee	7
	local.get	3
	i32.const	2
	i32.and 
	local.tee	8
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	3
	i32.add 
	local.tee	3
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	7
	i32.const	1
	i32.add 
	local.get	8
	i32.load8_u	.L__anon_203+1
	local.get	3
	i32.const	1
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
.LBB5_8:
	end_block
	local.get	4
	i32.eqz
	br_if   	1
	local.get	1
	i32.const	-2
	i32.and 
	local.set	3
.LBB5_10:
	end_block
	local.get	0
	local.get	3
	i32.add 
	local.get	3
	i32.const	2
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	3
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
.LBB5_11:
	end_block
	end_function

	.section	.text..Lsimd_codegen.std_search,"",@
	.type	.Lsimd_codegen.std_search,@function
.Lsimd_codegen.std_search:
	.functype	.Lsimd_codegen.std_search (i32, i32) -> (i32)
	.local  	i32, i32, i32, v128, v128
	block   	
	local.get	1
	br_if   	0
	i32.const	0
	return
.LBB6_2:
	end_block
	i32.const	0
	local.set	2
	block   	
	local.get	1
	i32.const	33
	i32.lt_u
	br_if   	0
	i32.const	0
	local.set	3
.LBB6_4:
	loop    	
	block   	
	local.get	0
	local.get	3
	i32.add 
	local.tee	4
	v128.load	0:p2align=0
	v128.const	13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
	local.tee	5
	i8x16.eq
	local.tee	6
	v128.any_true
	i32.eqz
	br_if   	0
	v128.const	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	v128.const	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
	local.tee	5
	local.get	6
	v128.bitselect
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	8, 9, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	i8x16.extract_lane_u	0
	local.get	3
	i32.add 
	return
.LBB6_6:
	end_block
	block   	
	local.get	4
	i32.const	16
	i32.add 
	v128.load	0:p2align=0
	local.get	5
	i8x16.eq
	local.tee	5
	v128.any_true
	br_if   	0
	local.get	3
	i32.const	64
	i32.add 
	local.set	4
	local.get	3
	i32.const	32
	i32.add 
	local.tee	2
	local.set	3
	local.get	4
	local.get	1
	i32.ge_u
	br_if   	2
	br      	1
.LBB6_8:
	end_block
	end_loop
	v128.const	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	v128.const	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
	local.tee	6
	local.get	5
	v128.bitselect
	local.tee	5
	local.get	5
	local.get	5
	i8x16.shuffle	8, 9, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	6
	v128.and
	i8x16.min_u
	local.tee	5
	local.get	5
	local.get	5
	i8x16.shuffle	4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	6
	v128.and
	i8x16.min_u
	local.tee	5
	local.get	5
	local.get	5
	i8x16.shuffle	2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	6
	v128.and
	i8x16.min_u
	local.tee	5
	local.get	5
	local.get	5
	i8x16.shuffle	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	6
	v128.and
	i8x16.min_u
	i8x16.extract_lane_u	0
	local.get	3
	i32.add 
	i32.const	16
	i32.add 
	return
.LBB6_9:
	end_block
	block   	
	block   	
	local.get	2
	i32.const	16
	i32.add 
	local.tee	4
	local.get	1
	i32.lt_u
	br_if   	0
	local.get	2
	local.set	4
	br      	1
.LBB6_11:
	end_block
	local.get	0
	local.get	2
	i32.add 
	v128.load	0:p2align=0
	v128.const	13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
	i8x16.eq
	local.tee	6
	v128.any_true
	i32.eqz
	br_if   	0
	local.get	2
	v128.const	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	v128.const	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
	local.tee	5
	local.get	6
	v128.bitselect
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	8, 9, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	5
	v128.and
	i8x16.min_u
	i8x16.extract_lane_u	0
	i32.add 
	return
.LBB6_13:
	end_block
	block   	
	block   	
	local.get	4
	i32.const	8
	i32.add 
	local.tee	3
	local.get	1
	i32.lt_u
	br_if   	0
	local.get	4
	local.set	3
	br      	1
.LBB6_15:
	end_block
	local.get	0
	local.get	4
	i32.add 
	v128.load64_zero	0:p2align=0
	v128.const	13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
	i8x16.eq
	i16x8.extend_low_i8x16_s
	local.tee	6
	v128.any_true
	i32.eqz
	br_if   	0
	local.get	4
	v128.const	0, 1, 2, 3, 4, 5, 6, 7
	v128.const	7, 7, 7, 7, 7, 7, 7, 7
	local.tee	5
	local.get	6
	v128.bitselect
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 0, 1, 0, 1, 0, 1
	local.get	5
	v128.and
	i16x8.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	4, 5, 6, 7, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
	local.get	5
	v128.and
	i16x8.min_u
	local.tee	6
	local.get	6
	local.get	5
	i8x16.shuffle	2, 3, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
	local.get	5
	v128.and
	i16x8.min_u
	i16x8.extract_lane_u	0
	i32.add 
	return
.LBB6_17:
	end_block
	block   	
	local.get	1
	local.get	3
	i32.eq  
	br_if   	0
.LBB6_19:
	loop    	
	block   	
	local.get	0
	local.get	3
	i32.add 
	i32.load8_u	0
	i32.const	13
	i32.ne  
	br_if   	0
	local.get	3
	return
.LBB6_21:
	end_block
	local.get	1
	local.get	3
	i32.const	1
	i32.add 
	local.tee	3
	i32.ne  
	br_if   	0
.LBB6_22:
	end_loop
	end_block
	local.get	1
	end_function

	.section	.text..Lsimd_codegen.field_vector,"",@
	.type	.Lsimd_codegen.field_vector,@function
.Lsimd_codegen.field_vector:
	.functype	.Lsimd_codegen.field_vector (i32, i32) -> (i32)
	local.get	0
	local.get	1
	call	.Lsimd_candidates.find__func_8
	end_function

	.section	.text..Lsimd_candidates.find__func_8,"",@
	.type	.Lsimd_candidates.find__func_8,@function
.Lsimd_candidates.find__func_8:
	.functype	.Lsimd_candidates.find__func_8 (i32, i32) -> (i32)
	.local  	i32, i32, i32, i32, v128, v128
	i32.const	0
	local.set	2
	local.get	1
	local.set	3
	block   	
	block   	
	local.get	1
	i32.const	16
	i32.lt_u
	br_if   	0
	local.get	1
	i32.const	-16
	i32.and 
	local.set	2
	i32.const	0
	local.set	4
	local.get	0
	local.set	5
.LBB8_2:
	loop    	
	block   	
	local.get	5
	v128.load	0:p2align=0
	local.tee	6
	v128.const	127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127
	i8x16.eq
	local.get	6
	v128.const	32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	i8x16.lt_u
	local.get	6
	v128.const	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	i8x16.ne
	v128.and
	v128.or
	local.tee	6
	v128.any_true
	i32.eqz
	br_if   	0
	v128.const	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	v128.const	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
	local.tee	7
	local.get	6
	v128.bitselect
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	8, 9, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	i8x16.extract_lane_u	0
	local.get	4
	i32.sub 
	local.set	1
	br      	3
.LBB8_4:
	end_block
	local.get	5
	i32.const	16
	i32.add 
	local.set	5
	local.get	1
	local.get	4
	i32.const	-16
	i32.add 
	local.tee	4
	i32.add 
	local.tee	3
	i32.const	15
	i32.gt_u
	br_if   	0
.LBB8_5:
	end_loop
	end_block
	local.get	3
	i32.eqz
	br_if   	0
.LBB8_7:
	loop    	
	block   	
	local.get	0
	local.get	2
	i32.add 
	i32.load8_u	0
	local.tee	5
	i32.const	127
	i32.ne  
	br_if   	0
	local.get	2
	return
.LBB8_9:
	end_block
	block   	
	local.get	5
	i32.const	32
	i32.lt_u
	local.get	5
	i32.const	9
	i32.ne  
	i32.and 
	i32.eqz
	br_if   	0
	local.get	2
	return
.LBB8_11:
	end_block
	local.get	2
	i32.const	1
	i32.add 
	local.set	2
	local.get	3
	i32.const	-1
	i32.add 
	local.tee	3
	br_if   	0
.LBB8_12:
	end_loop
	end_block
	local.get	1
	end_function

	.section	.text..Lsimd_codegen.field_scalar,"",@
	.type	.Lsimd_codegen.field_scalar,@function
.Lsimd_codegen.field_scalar:
	.functype	.Lsimd_codegen.field_scalar (i32, i32) -> (i32)
	local.get	0
	local.get	1
	call	.Lsimd_candidates.find__func_10
	end_function

	.section	.text..Lsimd_candidates.find__func_10,"",@
	.type	.Lsimd_candidates.find__func_10,@function
.Lsimd_candidates.find__func_10:
	.functype	.Lsimd_candidates.find__func_10 (i32, i32) -> (i32)
	.local  	i32, i32
	i32.const	0
	local.set	2
	block   	
	local.get	1
	i32.eqz
	br_if   	0
.LBB10_2:
	loop    	
	local.get	0
	local.get	2
	i32.add 
	i32.load8_u	0
	local.tee	3
	i32.const	127
	i32.eq  
	br_if   	1
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	br_if   	1
	local.get	1
	local.get	2
	i32.const	1
	i32.add 
	local.tee	2
	i32.ne  
	br_if   	0
	end_loop
	local.get	1
	local.set	2
.LBB10_6:
	end_block
	local.get	2
	end_function

	.section	.text..Lsimd_codegen.json_vector,"",@
	.type	.Lsimd_codegen.json_vector,@function
.Lsimd_codegen.json_vector:
	.functype	.Lsimd_codegen.json_vector (i32, i32) -> (i32)
	local.get	0
	local.get	1
	call	.Lsimd_candidates.find__func_11
	end_function

	.section	.text..Lsimd_candidates.find__func_11,"",@
	.type	.Lsimd_candidates.find__func_11,@function
.Lsimd_candidates.find__func_11:
	.functype	.Lsimd_candidates.find__func_11 (i32, i32) -> (i32)
	.local  	i32, i32, i32, i32, v128, v128
	i32.const	0
	local.set	2
	local.get	1
	local.set	3
	block   	
	block   	
	local.get	1
	i32.const	16
	i32.lt_u
	br_if   	0
	local.get	1
	i32.const	-16
	i32.and 
	local.set	2
	i32.const	0
	local.set	4
	local.get	0
	local.set	5
.LBB12_2:
	loop    	
	block   	
	local.get	5
	v128.load	0:p2align=0
	local.tee	6
	v128.const	34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34
	i8x16.eq
	local.get	6
	v128.const	92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92
	i8x16.eq
	v128.or
	local.get	6
	v128.const	32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	i8x16.lt_u
	v128.or
	local.tee	6
	v128.any_true
	i32.eqz
	br_if   	0
	v128.const	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	v128.const	15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
	local.tee	7
	local.get	6
	v128.bitselect
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	8, 9, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	local.tee	6
	local.get	6
	local.get	6
	i8x16.shuffle	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local.get	7
	v128.and
	i8x16.min_u
	i8x16.extract_lane_u	0
	local.get	4
	i32.sub 
	local.set	1
	br      	3
.LBB12_4:
	end_block
	local.get	5
	i32.const	16
	i32.add 
	local.set	5
	local.get	1
	local.get	4
	i32.const	-16
	i32.add 
	local.tee	4
	i32.add 
	local.tee	3
	i32.const	15
	i32.gt_u
	br_if   	0
.LBB12_5:
	end_loop
	end_block
	local.get	3
	i32.eqz
	br_if   	0
.LBB12_7:
	loop    	
	block   	
	local.get	0
	local.get	2
	i32.add 
	i32.load8_u	0
	i32.const	255
	i32.and 
	local.tee	5
	i32.const	32
	i32.ge_u
	br_if   	0
	local.get	2
	return
.LBB12_9:
	end_block
	block   	
	local.get	5
	i32.const	34
	i32.ne  
	br_if   	0
	local.get	2
	return
.LBB12_11:
	end_block
	block   	
	local.get	5
	i32.const	92
	i32.ne  
	br_if   	0
	local.get	2
	return
.LBB12_13:
	end_block
	local.get	2
	i32.const	1
	i32.add 
	local.set	2
	local.get	3
	i32.const	-1
	i32.add 
	local.tee	3
	br_if   	0
.LBB12_14:
	end_loop
	end_block
	local.get	1
	end_function

	.section	.text..Lsimd_codegen.json_scalar,"",@
	.type	.Lsimd_codegen.json_scalar,@function
.Lsimd_codegen.json_scalar:
	.functype	.Lsimd_codegen.json_scalar (i32, i32) -> (i32)
	local.get	0
	local.get	1
	call	.Lsimd_candidates.find__func_13
	end_function

	.section	.text..Lsimd_candidates.find__func_13,"",@
	.type	.Lsimd_candidates.find__func_13,@function
.Lsimd_candidates.find__func_13:
	.functype	.Lsimd_candidates.find__func_13 (i32, i32) -> (i32)
	.local  	i32, i32
	i32.const	0
	local.set	2
	block   	
	local.get	1
	i32.eqz
	br_if   	0
.LBB14_2:
	loop    	
	local.get	0
	local.get	2
	i32.add 
	i32.load8_u	0
	i32.const	255
	i32.and 
	local.tee	3
	i32.const	32
	i32.lt_u
	br_if   	1
	local.get	3
	i32.const	34
	i32.eq  
	br_if   	1
	local.get	3
	i32.const	92
	i32.eq  
	br_if   	1
	local.get	1
	local.get	2
	i32.const	1
	i32.add 
	local.tee	2
	i32.ne  
	br_if   	0
	end_loop
	local.get	1
	local.set	2
.LBB14_7:
	end_block
	local.get	2
	end_function

	.type	.L__anon_203,@object
	.section	.rodata..L__anon_203,"",@
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
	.no_dead_strip	__indirect_function_table
	.section	.custom_section.target_features,"",@
	.int8	8
	.int8	43
	.int8	15
	.ascii	"bulk-memory-opt"
	.int8	43
	.int8	22
	.ascii	"call-indirect-overlong"
	.int8	43
	.int8	14
	.ascii	"extended-const"
	.int8	43
	.int8	10
	.ascii	"multivalue"
	.int8	43
	.int8	15
	.ascii	"mutable-globals"
	.int8	43
	.int8	19
	.ascii	"nontrapping-fptoint"
	.int8	43
	.int8	8
	.ascii	"sign-ext"
	.int8	43
	.int8	7
	.ascii	"simd128"
	.section	.rodata..L__anon_203,"",@
