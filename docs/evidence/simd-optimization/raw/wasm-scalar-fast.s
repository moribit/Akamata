	.file	"simd-codegen"
	.functype	.Lsimd_codegen.mask_vector (i32, i32, i32) -> ()
	.functype	.Lsimd_candidates.maskCopy__func_0 (i32, i32, i32) -> ()
	.functype	.Lsimd_codegen.mask_word (i32, i32, i32) -> ()
	.functype	.Lsimd_candidates.maskCopy__func_1 (i32, i32, i32) -> ()
	.functype	.Lsimd_codegen.mask_byte (i32, i32, i32) -> ()
	.functype	.Lsimd_candidates.maskCopy__func_2 (i32, i32, i32) -> ()
	.functype	.Lsimd_codegen.std_search (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.field_vector (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_6 (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.field_scalar (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_9 (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.json_vector (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_10 (i32, i32) -> (i32)
	.functype	.Lsimd_codegen.json_scalar (i32, i32) -> (i32)
	.functype	.Lsimd_candidates.find__func_12 (i32, i32) -> (i32)
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
	.local  	i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32
	i32.const	0
	local.set	3
	block   	
	local.get	1
	i32.const	16
	i32.lt_u
	br_if   	0
	i32.const	0
	local.set	3
	local.get	1
	local.set	4
.LBB1_2:
	loop    	
	local.get	2
	local.get	3
	i32.add 
	local.tee	5
	i32.load8_u	0
	local.set	6
	local.get	5
	i32.load8_u	1
	local.set	7
	local.get	5
	i32.load8_u	2
	local.set	8
	local.get	5
	i32.load8_u	3
	local.set	9
	local.get	5
	i32.load8_u	4
	local.set	10
	local.get	5
	i32.load8_u	5
	local.set	11
	local.get	5
	i32.load8_u	6
	local.set	12
	local.get	5
	i32.load8_u	7
	local.set	13
	local.get	5
	i32.load8_u	8
	local.set	14
	local.get	5
	i32.load8_u	9
	local.set	15
	local.get	5
	i32.load8_u	10
	local.set	16
	local.get	5
	i32.load8_u	11
	local.set	17
	local.get	5
	i32.load8_u	12
	local.set	18
	local.get	5
	i32.load8_u	13
	local.set	19
	local.get	5
	i32.load8_u	14
	local.set	20
	local.get	0
	local.get	3
	i32.add 
	local.tee	21
	i32.const	15
	i32.add 
	local.get	5
	i32.load8_u	15
	i32.const	-1
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	14
	i32.add 
	local.get	20
	i32.const	128
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	13
	i32.add 
	local.get	19
	i32.const	99
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	12
	i32.add 
	local.get	18
	i32.const	17
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	11
	i32.add 
	local.get	17
	i32.const	-1
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	10
	i32.add 
	local.get	16
	i32.const	128
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	9
	i32.add 
	local.get	15
	i32.const	99
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	8
	i32.add 
	local.get	14
	i32.const	17
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	7
	i32.add 
	local.get	13
	i32.const	-1
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	6
	i32.add 
	local.get	12
	i32.const	128
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	5
	i32.add 
	local.get	11
	i32.const	99
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	4
	i32.add 
	local.get	10
	i32.const	17
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	3
	i32.add 
	local.get	9
	i32.const	-1
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	2
	i32.add 
	local.get	8
	i32.const	128
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	1
	i32.add 
	local.get	7
	i32.const	99
	i32.xor 
	i32.store8	0
	local.get	21
	local.get	6
	i32.const	17
	i32.xor 
	i32.store8	0
	local.get	3
	i32.const	16
	i32.add 
	local.set	3
	local.get	4
	i32.const	-16
	i32.add 
	local.tee	4
	i32.const	15
	i32.gt_u
	br_if   	0
.LBB1_3:
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
	local.set	5
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
	local.get	5
	local.set	3
.LBB1_6:
	end_block
	local.get	1
	local.get	5
	i32.eq  
	br_if   	0
	i32.const	0
	local.get	1
	i32.sub 
	local.set	4
	local.get	3
	i32.const	4
	i32.add 
	local.set	5
.LBB1_8:
	loop    	
	local.get	0
	local.get	5
	i32.add 
	local.tee	21
	i32.const	-4
	i32.add 
	local.get	5
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	2
	local.get	5
	i32.add 
	local.tee	3
	i32.const	-4
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	21
	i32.const	-3
	i32.add 
	local.get	5
	i32.const	-3
	i32.add 
	i32.const	3
	i32.and 
	i32.load8_u	.L__anon_203
	local.get	3
	i32.const	-3
	i32.add 
	i32.load8_u	0
	i32.xor 
	i32.store8	0
	local.get	4
	local.get	5
	i32.const	2
	i32.add 
	local.tee	5
	i32.add 
	i32.const	4
	i32.ne  
	br_if   	0
.LBB1_9:
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
	.local  	i64, i32
	block   	
	block   	
	local.get	1
	br_if   	0
	i64.const	0
	local.set	2
	br      	1
.LBB6_2:
	end_block
	i32.const	0
	local.set	3
.LBB6_3:
	block   	
	loop    	
	block   	
	local.get	0
	local.get	3
	i32.add 
	i32.load8_u	0
	i32.const	13
	i32.ne  
	br_if   	0
	i64.const	4294967296
	local.set	2
	br      	2
.LBB6_5:
	end_block
	local.get	1
	local.get	3
	i32.const	1
	i32.add 
	local.tee	3
	i32.ne  
	br_if   	0
	end_loop
	i32.const	0
	local.set	3
	i64.const	0
	local.set	2
.LBB6_7:
	end_block
	local.get	2
	local.get	3
	i64.extend_i32_u
	i64.or  
	local.set	2
.LBB6_8:
	end_block
	local.get	1
	local.get	2
	i32.wrap_i64
	local.get	2
	i64.const	4294967296
	i64.and 
	i64.eqz
	i32.select
	end_function

	.section	.text..Lsimd_codegen.field_vector,"",@
	.type	.Lsimd_codegen.field_vector,@function
.Lsimd_codegen.field_vector:
	.functype	.Lsimd_codegen.field_vector (i32, i32) -> (i32)
	local.get	0
	local.get	1
	call	.Lsimd_candidates.find__func_6
	end_function

	.section	.text..Lsimd_candidates.find__func_6,"",@
	.type	.Lsimd_candidates.find__func_6,@function
.Lsimd_candidates.find__func_6:
	.functype	.Lsimd_candidates.find__func_6 (i32, i32) -> (i32)
	.local  	i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32
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
	i32.load8_u	0
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	6
	local.get	5
	i32.load8_u	1
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	7
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	3
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	8
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	2
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	9
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	local.get	5
	i32.load8_u	4
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	10
	local.get	5
	i32.load8_u	5
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	11
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	7
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	12
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	6
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	13
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	i32.const	4
	i32.shl 
	i32.or  
	i32.const	255
	i32.and 
	local.get	5
	i32.load8_u	12
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	14
	local.get	5
	i32.load8_u	13
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	15
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	15
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	14
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	16
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	i32.const	12
	i32.shl 
	local.get	5
	i32.load8_u	8
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	17
	local.get	5
	i32.load8_u	9
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	18
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	11
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	19
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	10
	local.tee	3
	i32.const	127
	i32.eq  
	local.get	3
	i32.const	32
	i32.lt_u
	local.get	3
	i32.const	9
	i32.ne  
	i32.and 
	i32.or  
	local.tee	3
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	i32.const	8
	i32.shl 
	i32.or  
	i32.or  
	i32.const	65535
	i32.and 
	i32.eqz
	br_if   	0
	i32.const	0
	i32.const	15
	local.get	6
	i32.select
	local.tee	5
	i32.const	8
	i32.const	15
	local.get	17
	i32.select
	local.tee	2
	local.get	5
	local.get	2
	i32.lt_u
	i32.select
	local.tee	5
	i32.const	4
	i32.const	15
	local.get	10
	i32.select
	local.tee	2
	i32.const	12
	i32.const	15
	local.get	14
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	5
	local.get	2
	i32.lt_u
	i32.select
	local.tee	5
	i32.const	2
	i32.const	15
	local.get	9
	i32.select
	local.tee	2
	i32.const	10
	i32.const	15
	local.get	3
	i32.select
	local.tee	3
	local.get	2
	local.get	3
	i32.lt_u
	i32.select
	local.tee	3
	i32.const	6
	i32.const	15
	local.get	13
	i32.select
	local.tee	2
	i32.const	14
	i32.const	15
	local.get	16
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	local.get	5
	local.get	3
	i32.lt_u
	i32.select
	local.tee	5
	i32.const	1
	i32.const	15
	local.get	7
	i32.select
	local.tee	3
	i32.const	9
	i32.const	15
	local.get	18
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	i32.const	5
	i32.const	15
	local.get	11
	i32.select
	local.tee	2
	i32.const	13
	i32.const	15
	local.get	15
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	i32.const	7
	i32.const	15
	local.get	12
	i32.select
	local.tee	2
	i32.const	3
	i32.const	15
	local.get	8
	i32.select
	local.tee	1
	i32.const	11
	i32.const	15
	local.get	19
	i32.select
	local.tee	0
	local.get	1
	local.get	0
	i32.lt_u
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	local.get	5
	local.get	3
	i32.lt_u
	i32.select
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
	call	.Lsimd_candidates.find__func_9
	end_function

	.section	.text..Lsimd_candidates.find__func_9,"",@
	.type	.Lsimd_candidates.find__func_9,@function
.Lsimd_candidates.find__func_9:
	.functype	.Lsimd_candidates.find__func_9 (i32, i32) -> (i32)
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
	call	.Lsimd_candidates.find__func_10
	end_function

	.section	.text..Lsimd_candidates.find__func_10,"",@
	.type	.Lsimd_candidates.find__func_10,@function
.Lsimd_candidates.find__func_10:
	.functype	.Lsimd_candidates.find__func_10 (i32, i32) -> (i32)
	.local  	i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32
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
	i32.load8_u	0
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	6
	local.get	5
	i32.load8_u	1
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	7
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	3
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	8
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	2
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	9
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	local.get	5
	i32.load8_u	4
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	10
	local.get	5
	i32.load8_u	5
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	11
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	7
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	12
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	6
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	13
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	i32.const	4
	i32.shl 
	i32.or  
	i32.const	255
	i32.and 
	local.get	5
	i32.load8_u	12
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	14
	local.get	5
	i32.load8_u	13
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	15
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	15
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	14
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	16
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	i32.const	12
	i32.shl 
	local.get	5
	i32.load8_u	8
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	17
	local.get	5
	i32.load8_u	9
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	18
	i32.const	1
	i32.shl 
	i32.or  
	local.get	5
	i32.load8_u	11
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	19
	i32.const	3
	i32.shl 
	local.get	5
	i32.load8_u	10
	local.tee	3
	i32.const	34
	i32.eq  
	local.get	3
	i32.const	92
	i32.eq  
	i32.or  
	local.get	3
	i32.const	32
	i32.lt_u
	i32.or  
	local.tee	3
	i32.const	2
	i32.shl 
	i32.or  
	i32.or  
	i32.const	8
	i32.shl 
	i32.or  
	i32.or  
	i32.const	65535
	i32.and 
	i32.eqz
	br_if   	0
	i32.const	0
	i32.const	15
	local.get	6
	i32.select
	local.tee	5
	i32.const	8
	i32.const	15
	local.get	17
	i32.select
	local.tee	2
	local.get	5
	local.get	2
	i32.lt_u
	i32.select
	local.tee	5
	i32.const	4
	i32.const	15
	local.get	10
	i32.select
	local.tee	2
	i32.const	12
	i32.const	15
	local.get	14
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	5
	local.get	2
	i32.lt_u
	i32.select
	local.tee	5
	i32.const	2
	i32.const	15
	local.get	9
	i32.select
	local.tee	2
	i32.const	10
	i32.const	15
	local.get	3
	i32.select
	local.tee	3
	local.get	2
	local.get	3
	i32.lt_u
	i32.select
	local.tee	3
	i32.const	6
	i32.const	15
	local.get	13
	i32.select
	local.tee	2
	i32.const	14
	i32.const	15
	local.get	16
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	local.get	5
	local.get	3
	i32.lt_u
	i32.select
	local.tee	5
	i32.const	1
	i32.const	15
	local.get	7
	i32.select
	local.tee	3
	i32.const	9
	i32.const	15
	local.get	18
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	i32.const	5
	i32.const	15
	local.get	11
	i32.select
	local.tee	2
	i32.const	13
	i32.const	15
	local.get	15
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	i32.const	7
	i32.const	15
	local.get	12
	i32.select
	local.tee	2
	i32.const	3
	i32.const	15
	local.get	8
	i32.select
	local.tee	1
	i32.const	11
	i32.const	15
	local.get	19
	i32.select
	local.tee	6
	local.get	1
	local.get	6
	i32.lt_u
	i32.select
	local.tee	1
	local.get	2
	local.get	1
	i32.lt_u
	i32.select
	local.tee	2
	local.get	3
	local.get	2
	i32.lt_u
	i32.select
	local.tee	3
	local.get	5
	local.get	3
	i32.lt_u
	i32.select
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
	call	.Lsimd_candidates.find__func_12
	end_function

	.section	.text..Lsimd_candidates.find__func_12,"",@
	.type	.Lsimd_candidates.find__func_12,@function
.Lsimd_candidates.find__func_12:
	.functype	.Lsimd_candidates.find__func_12 (i32, i32) -> (i32)
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
	.int8	7
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
	.section	.rodata..L__anon_203,"",@
