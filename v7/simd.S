/* https://github.com/cirosantilli/arm-assembly-cheat#advanced-simd-instructions */

#include "common.h"

ENTRY
    /* Add 4 32-bit unsigned integers in one go.
     *
     * q means 128-bits.
     *
     * u32 means that we treat memory as uint32_t types.
     *
     * 4 is deduced: in 128 bits you can fit 4 u32.
     *
     * Observe how the carry is propagated within u32 integers,
     * but not across them.
     */
.data
    u32_0:          .word 0xF111F111, 0xF222F222, 0xF333F333, 0xF444F444
    u32_1:          .word 0x15551555, 0x16661666, 0x17771777, 0x18881888
    u32_sum_expect: .word 0x06670666, 0x08890888, 0x0AAB0AAA, 0x0CCD0CCC
.bss
    u32_sum: .skip 16
.text
    ldr r0, =u32_0
    vld1.u32 {q0}, [r0]
    ldr r0, =u32_1
    vld1.u32 {q1}, [r0]
    vadd.u32 q2, q0, q1
    ldr r0, =u32_sum
    vst1.u32 {q2}, [r0]
    ASSERT_MEMCMP(u32_sum, u32_sum_expect, 0x10)

    /* 2x 64-bit add. */
.data
    u64_0:          .quad 0xF1111111F1111111, 0xF2222222F2222222
    u64_1:          .quad 0x1555555515555555, 0x1666666616666666
    u64_sum_expect: .quad 0x0666666706666666, 0x0888888908888888
.bss
    u64_sum: .skip 16
.text
    ldr r0, =u64_0
    vld1.u64 {q0}, [r0]
    ldr r0, =u64_1
    vld1.u64 {q1}, [r0]
    vadd.u64 q2, q0, q1
    ldr r0, =u64_sum
    vst1.u64 {q2}, [r0]
    ASSERT_MEMCMP(u64_sum, u64_sum_expect, 0x10)

    /* 4x 32-bit float add. */
.data
    f32_0:          .float 1.5, 2.5,  3.5,  4.5
    f32_1:          .float 5.5, 6.5,  7.5,  8.5
    f32_sum_expect: .float 7.0, 9.0, 11.0, 13.0
.bss
    f32_sum: .skip 16
.text
    ldr r0, =f32_0
    vld1.f32 {q0}, [r0]
    ldr r0, =f32_1
    vld1.f32 {q1}, [r0]
    vadd.f32 q2, q0, q1
    ldr r0, =f32_sum
    vst1.f32 {q2}, [r0]
    ASSERT_MEMCMP(f32_sum, f32_sum_expect, 0x10)

    /* 2x 64-bit float add: appears not possible.
     *
     * https://stackoverflow.com/questions/36052564/does-arm-support-simd-operations-for-64-bit-floating-point-numbers
     */
.data
    f64_0:          .double 1.5, 2.5
    f64_1:          .double 5.5, 6.5
    f64_sum_expect: .double 7.0, 9.0
.bss
    f64_sum: .skip 16
.text
    ldr r0, =f64_0
    vld1.f64 {q0}, [r0]
    ldr r0, =f64_1
    vld1.f64 {q1}, [r0]
#if 0
    /* bad type in Neon instruction -- `vadd.f64 q2,q0,q1' */
    vadd.f64 q2, q0, q1
    ldr r0, =f64_sum
    vst1.f64 {q2}, [r0]
    ASSERT_MEMCMP(f64_sum, f64_sum_expect, 0x10)
#endif
EXIT
