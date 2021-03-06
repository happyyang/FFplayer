/*
 * Copyright (c) 2008 Mans Rullgard <mans@mansr.com>
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "asm.S"

        preserve8
        .text

function ff_h264_idct_add_neon, export=1
        vld1.64         {d0-d3},  [r1,:128]

        vswp            d1,  d2
        vadd.i16        d4,  d0,  d1
        vshr.s16        q8,  q1,  #1
        vsub.i16        d5,  d0,  d1
        vadd.i16        d6,  d2,  d17
        vsub.i16        d7,  d16, d3
        vadd.i16        q0,  q2,  q3
        vsub.i16        q1,  q2,  q3

        vtrn.16         d0,  d1
        vtrn.16         d3,  d2
        vtrn.32         d0,  d3
        vtrn.32         d1,  d2

        vadd.i16        d4,  d0,  d3
        vld1.32         {d18[0]}, [r0,:32], r2
        vswp            d1,  d3
        vshr.s16        q8,  q1,  #1
        vld1.32         {d19[1]}, [r0,:32], r2
        vsub.i16        d5,  d0,  d1
        vld1.32         {d18[1]}, [r0,:32], r2
        vadd.i16        d6,  d16, d3
        vld1.32         {d19[0]}, [r0,:32], r2
        vsub.i16        d7,  d2,  d17
        sub             r0,  r0,  r2, lsl #2
        vadd.i16        q0,  q2,  q3
        vsub.i16        q1,  q2,  q3

        vrshr.s16       q0,  q0,  #6
        vrshr.s16       q1,  q1,  #6

        vaddw.u8        q0,  q0,  d18
        vaddw.u8        q1,  q1,  d19

        vqmovun.s16     d0,  q0
        vqmovun.s16     d1,  q1

        vst1.32         {d0[0]},  [r0,:32], r2
        vst1.32         {d1[1]},  [r0,:32], r2
        vst1.32         {d0[1]},  [r0,:32], r2
        vst1.32         {d1[0]},  [r0,:32], r2

        bx              lr
endfunc

function ff_h264_idct_dc_add_neon, export=1
        vld1.16         {d2[],d3[]}, [r1,:16]
        vrshr.s16       q1,  q1,  #6
        vld1.32         {d0[0]},  [r0,:32], r2
        vld1.32         {d0[1]},  [r0,:32], r2
        vaddw.u8        q2,  q1,  d0
        vld1.32         {d1[0]},  [r0,:32], r2
        vld1.32         {d1[1]},  [r0,:32], r2
        vaddw.u8        q1,  q1,  d1
        vqmovun.s16     d0,  q2
        vqmovun.s16     d1,  q1
        sub             r0,  r0,  r2, lsl #2
        vst1.32         {d0[0]},  [r0,:32], r2
        vst1.32         {d0[1]},  [r0,:32], r2
        vst1.32         {d1[0]},  [r0,:32], r2
        vst1.32         {d1[1]},  [r0,:32], r2
        bx              lr
endfunc

function ff_h264_idct_add16_neon, export=1
        push            {r4-r8,lr}
        mov             r4,  r0
        mov             r5,  r1
        mov             r1,  r2
        mov             r2,  r3
        ldr             r6,  [sp, #24]
        movrel          r7,  scan8
        mov             ip,  #16
1:      ldrb            r8,  [r7], #1
        ldr             r0,  [r5], #4
        ldrb            r8,  [r6, r8]
        subs            r8,  r8,  #1
        blt             2f
        ldrsh           lr,  [r1]
        add             r0,  r0,  r4
        movne           lr,  #0
        cmp             lr,  #0
        adrne           lr,  ff_h264_idct_dc_add_neon
        adreq           lr,  ff_h264_idct_add_neon
        blx             lr
2:      subs            ip,  ip,  #1
        add             r1,  r1,  #32
        bne             1b
        pop             {r4-r8,pc}
endfunc

function ff_h264_idct_add16intra_neon, export=1
        push            {r4-r8,lr}
        mov             r4,  r0
        mov             r5,  r1
        mov             r1,  r2
        mov             r2,  r3
        ldr             r6,  [sp, #24]
        movrel          r7,  scan8
        mov             ip,  #16
1:      ldrb            r8,  [r7], #1
        ldr             r0,  [r5], #4
        ldrb            r8,  [r6, r8]
        add             r0,  r0,  r4
        cmp             r8,  #0
        ldrsh           r8,  [r1]
        adrne           lr,  ff_h264_idct_add_neon
        adreq           lr,  ff_h264_idct_dc_add_neon
        cmpeq           r8,  #0
        blxne           lr
        subs            ip,  ip,  #1
        add             r1,  r1,  #32
        bne             1b
        pop             {r4-r8,pc}
endfunc

function ff_h264_idct_add8_neon, export=1
        push            {r4-r10,lr}
        ldm             r0,  {r4,r9}
        add             r5,  r1,  #16*4
        add             r1,  r2,  #16*32
        mov             r2,  r3
        ldr             r6,  [sp, #32]
        movrel          r7,  scan8+16
        mov             ip,  #8
1:      ldrb            r8,  [r7], #1
        ldr             r0,  [r5], #4
        ldrb            r8,  [r6, r8]
        tst             ip,  #4
        addeq           r0,  r0,  r4
        addne           r0,  r0,  r9
        cmp             r8,  #0
        ldrsh           r8,  [r1]
        adrne           lr,  ff_h264_idct_add_neon
        adreq           lr,  ff_h264_idct_dc_add_neon
        cmpeq           r8,  #0
        blxne           lr
        subs            ip,  ip,  #1
        add             r1,  r1,  #32
        bne             1b
        pop             {r4-r10,pc}
endfunc

        .section .rodata
scan8:  .byte           4+1*8, 5+1*8, 4+2*8, 5+2*8
        .byte           6+1*8, 7+1*8, 6+2*8, 7+2*8
        .byte           4+3*8, 5+3*8, 4+4*8, 5+4*8
        .byte           6+3*8, 7+3*8, 6+4*8, 7+4*8
        .byte           1+1*8, 2+1*8
        .byte           1+2*8, 2+2*8
        .byte           1+4*8, 2+4*8
        .byte           1+5*8, 2+5*8
