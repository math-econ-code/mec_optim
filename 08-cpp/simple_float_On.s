	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 13
	.intel_syntax noprefix
	.globl	__Z7add_vecPfS_fi       ## -- Begin function _Z7add_vecPfS_fi
	.p2align	4, 0x90
__Z7add_vecPfS_fi:                      ## @_Z7add_vecPfS_fi
	.cfi_startproc
## BB#0:
	push	rbp
Lcfi0:
	.cfi_def_cfa_offset 16
Lcfi1:
	.cfi_offset rbp, -16
	mov	rbp, rsp
Lcfi2:
	.cfi_def_cfa_register rbp
                                        ## kill: %EDX<def> %EDX<kill> %RDX<def>
	test	edx, edx
	jle	LBB0_8
## BB#1:
	mov	r9d, edx
	cmp	edx, 31
	ja	LBB0_5
## BB#2:
	xor	r8d, r8d
	jmp	LBB0_3
LBB0_5:
	and	edx, 31
	mov	r8, r9
	sub	r8, rdx
	vbroadcastss	ymm1, xmm0
	lea	rcx, [rsi + 96]
	lea	rax, [rdi + 96]
	mov	r10, r8
	.p2align	4, 0x90
LBB0_6:                                 ## =>This Inner Loop Header: Depth=1
	vmovups	ymm2, ymmword ptr [rcx - 96]
	vmovups	ymm3, ymmword ptr [rcx - 64]
	vmovups	ymm4, ymmword ptr [rcx - 32]
	vmovups	ymm5, ymmword ptr [rcx]
	vfmadd213ps	ymm2, ymm1, ymmword ptr [rax - 96]
	vfmadd213ps	ymm3, ymm1, ymmword ptr [rax - 64]
	vfmadd213ps	ymm4, ymm1, ymmword ptr [rax - 32]
	vfmadd213ps	ymm5, ymm1, ymmword ptr [rax]
	vmovups	ymmword ptr [rax - 96], ymm2
	vmovups	ymmword ptr [rax - 64], ymm3
	vmovups	ymmword ptr [rax - 32], ymm4
	vmovups	ymmword ptr [rax], ymm5
	sub	rcx, -128
	sub	rax, -128
	add	r10, -32
	jne	LBB0_6
## BB#7:
	test	edx, edx
	je	LBB0_8
LBB0_3:
	lea	rax, [rsi + 4*r8]
	lea	rcx, [rdi + 4*r8]
	sub	r9, r8
	.p2align	4, 0x90
LBB0_4:                                 ## =>This Inner Loop Header: Depth=1
	vmovss	xmm1, dword ptr [rax]   ## xmm1 = mem[0],zero,zero,zero
	vfmadd213ss	xmm1, xmm0, dword ptr [rcx]
	vmovss	dword ptr [rcx], xmm1
	add	rax, 4
	add	rcx, 4
	add	r9, -1
	jne	LBB0_4
LBB0_8:
	pop	rbp
	vzeroupper
	ret
	.cfi_endproc
                                        ## -- End function

.subsections_via_symbols
