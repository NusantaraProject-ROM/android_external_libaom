/*
 * Copyright (c) 2016, Alliance for Open Media. All rights reserved
 *
 * This source code is subject to the terms of the BSD 2 Clause License and
 * the Alliance for Open Media Patent License 1.0. If the BSD 2 Clause License
 * was not distributed with this source code in the LICENSE file, you can
 * obtain it at www.aomedia.org/license/software. If the Alliance for Open
 * Media Patent License 1.0 was not distributed with this source code in the
 * PATENTS file, you can obtain it at www.aomedia.org/license/patent.
 */
#include "aom/aom_codec.h"
static const char* const cfg = "cmake ../../libaom -G \"Unix Makefiles\" -DAOM_TARGET_CPU=x86_64 -DCONFIG_AV1_ENCODER=0 -DCONFIG_LIBYUV=0 -DCONFIG_LOWBITDEPTH=0 -DENABLE_SSE3=0 -DENABLE_SSSE3=0 -DENABLE_SSE4_1=0 -DENABLE_SSE4_2=0 -DENABLE_AVX=0 -DENABLE_AVX2=0";
const char *aom_codec_build_config(void) {return cfg;}


// manually defined here as a NOP until we fix the scripts that auto-generate
// makefiles so that we get the right assembly files included

void aom_reset_mmx_state(void) {
    return;
}
