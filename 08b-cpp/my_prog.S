	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 13
	.intel_syntax noprefix
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3
LCPI0_0:
	.quad	4611686018427387904     ## double 2
LCPI0_1:
	.quad	4613937818241073152     ## double 3
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	4, 0x90
_main:                                  ## @main
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
	xor	eax, eax
	movsd	xmm0, qword ptr [rip + LCPI0_0] ## xmm0 = mem[0],zero
	movsd	xmm1, qword ptr [rip + LCPI0_1] ## xmm1 = mem[0],zero
	mov	dword ptr [rbp - 4], 0
	movsd	qword ptr [rbp - 16], xmm1
	movsd	qword ptr [rbp - 24], xmm0
	movsd	xmm0, qword ptr [rbp - 16] ## xmm0 = mem[0],zero
	addsd	xmm0, qword ptr [rbp - 24]
	movsd	qword ptr [rbp - 32], xmm0
	pop	rbp
	ret
	.cfi_endproc


.subsections_via_symbols
