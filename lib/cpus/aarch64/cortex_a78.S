/*
 * Copyright (c) 2019-2023, ARM Limited. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <arch.h>
#include <asm_macros.S>
#include <common/bl_common.h>
#include <cortex_a78.h>
#include <cpu_macros.S>
#include <plat_macros.S>
#include "wa_cve_2022_23960_bhb_vector.S"

/* Hardware handled coherency */
#if HW_ASSISTED_COHERENCY == 0
#error "cortex_a78 must be compiled with HW_ASSISTED_COHERENCY enabled"
#endif

.globl cortex_a78_reset_func
.globl cortex_a78_core_pwr_dwn

#if WORKAROUND_CVE_2022_23960
	wa_cve_2022_23960_bhb_vector_table CORTEX_A78_BHB_LOOP_COUNT, cortex_a78
#endif /* WORKAROUND_CVE_2022_23960 */

/* --------------------------------------------------
 * Errata Workaround for A78 Erratum 1688305.
 * This applies to revision r0p0 and r1p0 of A78.
 * Inputs:
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * --------------------------------------------------
 */
func errata_a78_1688305_wa
	/* Compare x0 against revision r1p0 */
	mov	x17, x30
	bl	check_errata_1688305
	cbz	x0, 1f
	mrs     x1, CORTEX_A78_ACTLR2_EL1
	orr	x1, x1, #CORTEX_A78_ACTLR2_EL1_BIT_1
	msr     CORTEX_A78_ACTLR2_EL1, x1
	isb
1:
	ret	x17
endfunc errata_a78_1688305_wa

func check_errata_1688305
	/* Applies to r0p0 and r1p0 */
	mov	x1, #0x10
	b	cpu_rev_var_ls
endfunc check_errata_1688305

/* --------------------------------------------------
 * Errata Workaround for Cortex A78 Errata #1941498.
 * This applies to revisions r0p0, r1p0, and r1p1.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * --------------------------------------------------
 */
func errata_a78_1941498_wa
	/* Compare x0 against revision <= r1p1 */
	mov	x17, x30
	bl	check_errata_1941498
	cbz	x0, 1f

	/* Set bit 8 in ECTLR_EL1 */
	mrs	x1, CORTEX_A78_CPUECTLR_EL1
	orr	x1, x1, #CORTEX_A78_CPUECTLR_EL1_BIT_8
	msr	CORTEX_A78_CPUECTLR_EL1, x1
	isb
1:
	ret	x17
endfunc errata_a78_1941498_wa

func check_errata_1941498
	/* Check for revision <= r1p1, might need to be updated later. */
	mov	x1, #0x11
	b	cpu_rev_var_ls
endfunc check_errata_1941498

/* --------------------------------------------------
 * Errata Workaround for A78 Erratum 1951500.
 * This applies to revisions r1p0 and r1p1 of A78.
 * The issue also exists in r0p0 but there is no fix
 * in that revision.
 * Inputs:
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * --------------------------------------------------
 */
func errata_a78_1951500_wa
	/* Compare x0 against revisions r1p0 - r1p1 */
	mov	x17, x30
	bl	check_errata_1951500
	cbz	x0, 1f

	msr	S3_6_c15_c8_0, xzr
	ldr	x0, =0x10E3900002
	msr	S3_6_c15_c8_2, x0
	ldr	x0, =0x10FFF00083
	msr	S3_6_c15_c8_3, x0
	ldr	x0, =0x2001003FF
	msr	S3_6_c15_c8_1, x0

	mov	x0, #1
	msr	S3_6_c15_c8_0, x0
	ldr	x0, =0x10E3800082
	msr	S3_6_c15_c8_2, x0
	ldr	x0, =0x10FFF00083
	msr	S3_6_c15_c8_3, x0
	ldr	x0, =0x2001003FF
	msr	S3_6_c15_c8_1, x0

	mov	x0, #2
	msr	S3_6_c15_c8_0, x0
	ldr	x0, =0x10E3800200
	msr	S3_6_c15_c8_2, x0
	ldr	x0, =0x10FFF003E0
	msr	S3_6_c15_c8_3, x0
	ldr	x0, =0x2001003FF
	msr	S3_6_c15_c8_1, x0

	isb
1:
	ret	x17
endfunc errata_a78_1951500_wa

func check_errata_1951500
	/* Applies to revisions r1p0 and r1p1. */
	mov	x1, #CPU_REV(1, 0)
	mov	x2, #CPU_REV(1, 1)
	b	cpu_rev_var_range
endfunc check_errata_1951500

/* --------------------------------------------------
 * Errata Workaround for Cortex A78 Errata #1821534.
 * This applies to revisions r0p0 and r1p0.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * --------------------------------------------------
 */
func errata_a78_1821534_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_1821534
	cbz	x0, 1f

	/* Set bit 2 in ACTLR2_EL1 */
	mrs     x1, CORTEX_A78_ACTLR2_EL1
	orr	x1, x1, #CORTEX_A78_ACTLR2_EL1_BIT_2
	msr     CORTEX_A78_ACTLR2_EL1, x1
	isb
1:
	ret	x17
endfunc errata_a78_1821534_wa

func check_errata_1821534
	/* Applies to r0p0 and r1p0 */
	mov	x1, #0x10
	b	cpu_rev_var_ls
endfunc check_errata_1821534

/* --------------------------------------------------
 * Errata Workaround for Cortex A78 Errata 1952683.
 * This applies to revision r0p0.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * --------------------------------------------------
 */
func errata_a78_1952683_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_1952683
	cbz	x0, 1f

	ldr	x0,=0x5
	msr	S3_6_c15_c8_0,x0
	ldr	x0,=0xEEE10A10
	msr	S3_6_c15_c8_2,x0
	ldr	x0,=0xFFEF0FFF
	msr	S3_6_c15_c8_3,x0
	ldr	x0,=0x0010F000
	msr	S3_6_c15_c8_4,x0
	ldr	x0,=0x0010F000
	msr	S3_6_c15_c8_5,x0
	ldr	x0,=0x40000080023ff
	msr	S3_6_c15_c8_1,x0
	ldr	x0,=0x6
	msr	S3_6_c15_c8_0,x0
	ldr	x0,=0xEE640F34
	msr	S3_6_c15_c8_2,x0
	ldr	x0,=0xFFEF0FFF
	msr	S3_6_c15_c8_3,x0
	ldr	x0,=0x40000080023ff
	msr	S3_6_c15_c8_1,x0
	isb
1:
	ret	x17
endfunc errata_a78_1952683_wa

func check_errata_1952683
	/* Applies to r0p0 only */
	mov	x1, #0x00
	b	cpu_rev_var_ls
endfunc check_errata_1952683

/* --------------------------------------------------
 * Errata Workaround for Cortex A78 Errata 2132060.
 * This applies to revisions r0p0, r1p0, r1p1, and r1p2.
 * It is still open.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x1, x17
 * --------------------------------------------------
 */
func errata_a78_2132060_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_2132060
	cbz	x0, 1f

	/* Apply the workaround. */
	mrs	x1, CORTEX_A78_CPUECTLR_EL1
	mov	x0, #CORTEX_A78_CPUECTLR_EL1_PF_MODE_CNSRV
	bfi	x1, x0, #CPUECTLR_EL1_PF_MODE_LSB, #CPUECTLR_EL1_PF_MODE_WIDTH
	msr	CORTEX_A78_CPUECTLR_EL1, x1
1:
	ret	x17
endfunc errata_a78_2132060_wa

func check_errata_2132060
	/* Applies to r0p0, r0p1, r1p1, and r1p2 */
	mov	x1, #0x12
	b	cpu_rev_var_ls
endfunc check_errata_2132060

/* --------------------------------------------------------------------
 * Errata Workaround for A78 Erratum 2242635.
 * This applies to revisions r1p0, r1p1, and r1p2 of the Cortex A78
 * processor and is still open.
 * The issue also exists in r0p0 but there is no fix in that revision.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * --------------------------------------------------------------------
 */
func errata_a78_2242635_wa
	/* Compare x0 against revisions r1p0 - r1p2 */
	mov	x17, x30
	bl	check_errata_2242635
	cbz	x0, 1f

	ldr	x0, =0x5
	msr	S3_6_c15_c8_0, x0 /* CPUPSELR_EL3 */
	ldr	x0, =0x10F600E000
	msr	S3_6_c15_c8_2, x0 /* CPUPOR_EL3 */
	ldr	x0, =0x10FF80E000
	msr	S3_6_c15_c8_3, x0 /* CPUPMR_EL3 */
	ldr	x0, =0x80000000003FF
	msr	S3_6_c15_c8_1, x0 /* CPUPCR_EL3 */

	isb
1:
	ret	x17
endfunc errata_a78_2242635_wa

func check_errata_2242635
	/* Applies to revisions r1p0 through r1p2. */
	mov	x1, #CPU_REV(1, 0)
	mov	x2, #CPU_REV(1, 2)
	b	cpu_rev_var_range
endfunc check_errata_2242635

/* --------------------------------------------------
 * Errata Workaround for Cortex A78 Errata 2376745.
 * This applies to revisions r0p0, r1p0, r1p1, and r1p2.
 * It is still open.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x1, x17
 * --------------------------------------------------
 */
func errata_a78_2376745_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_2376745
	cbz	x0, 1f

	/* Apply the workaround. */
	mrs	x1, CORTEX_A78_ACTLR2_EL1
	orr	x1, x1, #BIT(0)
	msr	CORTEX_A78_ACTLR2_EL1, x1
1:
	ret	x17
endfunc errata_a78_2376745_wa

func check_errata_2376745
	/* Applies to r0p0, r0p1, r1p1, and r1p2 */
	mov	x1, #CPU_REV(1, 2)
	b	cpu_rev_var_ls
endfunc check_errata_2376745

/* --------------------------------------------------
 * Errata Workaround for Cortex A78 Errata 2395406.
 * This applies to revisions r0p0, r1p0, r1p1, and r1p2.
 * It is still open.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x1, x17
 * --------------------------------------------------
 */
func errata_a78_2395406_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_2395406
	cbz	x0, 1f

	/* Apply the workaround. */
	mrs	x1, CORTEX_A78_ACTLR2_EL1
	orr	x1, x1, #BIT(40)
	msr	CORTEX_A78_ACTLR2_EL1, x1
1:
	ret	x17
endfunc errata_a78_2395406_wa

func check_errata_2395406
	/* Applies to r0p0, r0p1, r1p1, and r1p2 */
	mov	x1, #CPU_REV(1, 2)
	b	cpu_rev_var_ls
endfunc check_errata_2395406

/* ----------------------------------------------------
 * Errata Workaround for Cortex A78 Errata 2742426.
 * This applies to revisions r0p0, r1p0, r1p1 and r1p2.
 * It is still open.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x1, x17
 * ----------------------------------------------------
 */
func errata_a78_2742426_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_2742426
	cbz	x0, 1f

	/* Apply the workaround */
	mrs	x1, CORTEX_A78_ACTLR5_EL1
	bic	x1, x1, #BIT(56)
	orr	x1, x1, #BIT(55)
	msr	CORTEX_A78_ACTLR5_EL1, x1

1:
	ret	x17
endfunc errata_a78_2742426_wa

func check_errata_2742426
	/* Applies to r0p0, r1p0, r1p1, r1p2 */
	mov	x1, #CPU_REV(1, 2)
	b	cpu_rev_var_ls
endfunc check_errata_2742426

/* ----------------------------------------------------
 * Errata Workaround for Cortex-A78 Errata 2772019
 * This applies to revisions <= r1p2 and is still open.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x17
 * ----------------------------------------------------
 */
func errata_a78_2772019_wa
	mov	x17, x30
	bl	check_errata_2772019
	cbz	x0, 1f


	/* dsb before isb of power down sequence */
	dsb	sy
1:
	ret	x17
endfunc errata_a78_2772019_wa

func check_errata_2772019
	/* Applies to all revisions <= r1p2 */
	mov	x1, #0x12
	b	cpu_rev_var_ls
endfunc check_errata_2772019

/* ----------------------------------------------------
 * Errata Workaround for Cortex A78 Errata 2779479.
 * This applies to revisions r0p0, r1p0, r1p1, and r1p2.
 * It is still open.
 * x0: variant[4:7] and revision[0:3] of current cpu.
 * Shall clobber: x0-x1, x17
 * ----------------------------------------------------
 */
func errata_a78_2779479_wa
	/* Check revision. */
	mov	x17, x30
	bl	check_errata_2779479
	cbz	x0, 1f

	/* Apply the workaround */
	mrs	x1, CORTEX_A78_ACTLR3_EL1
	orr	x1, x1, #BIT(47)
	msr	CORTEX_A78_ACTLR3_EL1, x1

1:
	ret	x17
endfunc errata_a78_2779479_wa

func check_errata_2779479
	/* Applies to r0p0, r1p0, r1p1, r1p2 */
	mov	x1, #CPU_REV(1, 2)
	b	cpu_rev_var_ls
endfunc check_errata_2779479

func check_errata_cve_2022_23960
#if WORKAROUND_CVE_2022_23960
	mov	x0, #ERRATA_APPLIES
#else
	mov	x0, #ERRATA_MISSING
#endif
	ret
endfunc check_errata_cve_2022_23960

	/* -------------------------------------------------
	 * The CPU Ops reset function for Cortex-A78
	 * -------------------------------------------------
	 */
func cortex_a78_reset_func
	mov	x19, x30
	bl	cpu_get_rev_var
	mov	x18, x0

#if ERRATA_A78_1688305
	mov     x0, x18
	bl	errata_a78_1688305_wa
#endif

#if ERRATA_A78_1941498
	mov     x0, x18
	bl	errata_a78_1941498_wa
#endif

#if ERRATA_A78_1951500
	mov	x0, x18
	bl	errata_a78_1951500_wa
#endif

#if ERRATA_A78_1821534
	mov	x0, x18
	bl	errata_a78_1821534_wa
#endif

#if ERRATA_A78_1952683
	mov	x0, x18
	bl	errata_a78_1952683_wa
#endif

#if ERRATA_A78_2132060
	mov	x0, x18
	bl	errata_a78_2132060_wa
#endif

#if ERRATA_A78_2242635
	mov	x0, x18
	bl	errata_a78_2242635_wa
#endif

#if ERRATA_A78_2376745
	mov	x0, x18
	bl	errata_a78_2376745_wa
#endif

#if ERRATA_A78_2395406
	mov	x0, x18
	bl	errata_a78_2395406_wa
#endif

#if ERRATA_A78_2742426
	mov	x0, x18
	bl	errata_a78_2742426_wa
#endif

#if ERRATA_A78_2779479
	mov	x0, x18
	bl	errata_a78_2779479_wa
#endif

#if ENABLE_AMU
	/* Make sure accesses from EL0/EL1 and EL2 are not trapped to EL3 */
	mrs	x0, actlr_el3
	bic	x0, x0, #CORTEX_A78_ACTLR_TAM_BIT
	msr	actlr_el3, x0

	/* Make sure accesses from non-secure EL0/EL1 are not trapped to EL2 */
	mrs	x0, actlr_el2
	bic	x0, x0, #CORTEX_A78_ACTLR_TAM_BIT
	msr	actlr_el2, x0

	/* Enable group0 counters */
	mov	x0, #CORTEX_A78_AMU_GROUP0_MASK
	msr	CPUAMCNTENSET0_EL0, x0

	/* Enable group1 counters */
	mov	x0, #CORTEX_A78_AMU_GROUP1_MASK
	msr	CPUAMCNTENSET1_EL0, x0
#endif

#if IMAGE_BL31 && WORKAROUND_CVE_2022_23960
	/*
	 * The Cortex-A78 generic vectors are overridden to apply errata
	 * mitigation on exception entry from lower ELs.
	 */
	adr	x0, wa_cve_vbar_cortex_a78
	msr	vbar_el3, x0
#endif /* IMAGE_BL31 && WORKAROUND_CVE_2022_23960 */

	isb
	ret	x19
endfunc cortex_a78_reset_func

	/* ---------------------------------------------
	 * HW will do the cache maintenance while powering down
	 * ---------------------------------------------
	 */
func cortex_a78_core_pwr_dwn
	/* ---------------------------------------------
	 * Enable CPU power down bit in power control register
	 * ---------------------------------------------
	 */
	mrs	x0, CORTEX_A78_CPUPWRCTLR_EL1
	orr	x0, x0, #CORTEX_A78_CPUPWRCTLR_EL1_CORE_PWRDN_EN_BIT
	msr	CORTEX_A78_CPUPWRCTLR_EL1, x0
#if ERRATA_A78_2772019
	mov	x15, x30
	bl	cpu_get_rev_var
	bl	errata_a78_2772019_wa
	mov	x30, x15
#endif /* ERRATA_A78_2772019 */
	isb
	ret
endfunc cortex_a78_core_pwr_dwn

	/*
	 * Errata printing function for cortex_a78. Must follow AAPCS.
	 */
#if REPORT_ERRATA
func cortex_a78_errata_report
	stp	x8, x30, [sp, #-16]!

	bl	cpu_get_rev_var
	mov	x8, x0

	/*
	 * Report all errata. The revision-variant information is passed to
	 * checking functions of each errata.
	 */
	report_errata ERRATA_A78_1688305, cortex_a78, 1688305
	report_errata ERRATA_A78_1941498, cortex_a78, 1941498
	report_errata ERRATA_A78_1951500, cortex_a78, 1951500
	report_errata ERRATA_A78_1821534, cortex_a78, 1821534
	report_errata ERRATA_A78_1952683, cortex_a78, 1952683
	report_errata ERRATA_A78_2132060, cortex_a78, 2132060
	report_errata ERRATA_A78_2242635, cortex_a78, 2242635
	report_errata ERRATA_A78_2376745, cortex_a78, 2376745
	report_errata ERRATA_A78_2395406, cortex_a78, 2395406
	report_errata ERRATA_A78_2742426, cortex_a78, 2742426
	report_errata ERRATA_A78_2772019, cortex_a78, 2772019
	report_errata ERRATA_A78_2779479, cortex_a78, 2779479
	report_errata WORKAROUND_CVE_2022_23960, cortex_a78, cve_2022_23960

	ldp	x8, x30, [sp], #16
	ret
endfunc cortex_a78_errata_report
#endif

	/* ---------------------------------------------
	 * This function provides cortex_a78 specific
	 * register information for crash reporting.
	 * It needs to return with x6 pointing to
	 * a list of register names in ascii and
	 * x8 - x15 having values of registers to be
	 * reported.
	 * ---------------------------------------------
	 */
.section .rodata.cortex_a78_regs, "aS"
cortex_a78_regs:  /* The ascii list of register names to be reported */
	.asciz	"cpuectlr_el1", ""

func cortex_a78_cpu_reg_dump
	adr	x6, cortex_a78_regs
	mrs	x8, CORTEX_A78_CPUECTLR_EL1
	ret
endfunc cortex_a78_cpu_reg_dump

declare_cpu_ops cortex_a78, CORTEX_A78_MIDR, \
	cortex_a78_reset_func, \
	cortex_a78_core_pwr_dwn
