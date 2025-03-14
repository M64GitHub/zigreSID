// resid.cpp - 2023, m64
#include "resid.h"
#include "resid/siddefs.h"
#include <stdio.h>
#include <string.h>

ReSID::ReSID(const char *n) : sampling_rate(44100)
{
    strncpy(name, n, 1024);
    SetSamplingRate(sampling_rate);
    SetChipModel(MOS8580);
}

ReSID::~ReSID() {}

const char *ReSID::GetName() const
{
    return name;
}

const char *ReSID::GetModel() const
{
    if (model == MOS6581) return "MOS6581";
    if (model == MOS8580) return "MOS8580";
    return "UNKNOWN";
}

void ReSID::SetChipModel(enum chip_model m)
{
    sid.set_chip_model(m);
    model = m;
}

bool ReSID::SetChipModel(const char *m)
{
    bool model_known = false;

    if (!strncmp(m, "MOS6581", 10)) {
        SetChipModel(MOS6581);
        model_known = true;
    }
    if (!strncmp(m, "MOS8580", 10)) {
        SetChipModel(MOS8580);
        model_known = true;
    }

    return model_known;
}

void ReSID::SetSamplingRate(int r)
{
    sampling_rate = r;
    sid.set_sampling_parameters(985248, SAMPLE_RESAMPLE_INTERPOLATE,
                                sampling_rate);
    precalc_constants();
}

int ReSID::GetSamplingRate() const
{
    return sampling_rate;
}

void ReSID::WriteRegs(unsigned char *regs, int len)
{
    for (int i = 0; i < len; i++) {
        if (regs[i] != shadow_regs[i]) {
            sid.write(i, regs[i]);
            shadow_regs[i] = regs[i];
        }
    }
}

unsigned char *ReSID::GetRegs()
{
    return shadow_regs;
}

int ReSID::Clock(unsigned int cycles, short *buf, int buflen)
{
    cycle_count delta_t = cycles;
    return sid.clock(delta_t, buf, buflen);
}

// --

void ReSID::precalc_constants()
{
    double d1, d2, d3;

    // SAMPLES_PER_FRAME
    //
    // 44.1 kHz =  22.676... us
    d1 = ((double)1000.0) / ((double)sampling_rate);
    // 50 Hz = 20ms. => 20000us / 22.676 us = 882.00144
    d1 = ((double)20.0) / d1;
    SAMPLES_PER_FRAME = (int)d1;

    // CYCLES_PER_FRAME
    //
    // 50 Hz = 20ms. 1 cycle = 1,015us => 20000 / 1.015
    d2 = ((double)20000.0) / ((double)1.015) + 0.5;
    CYCLES_PER_FRAME = (int)d2;

    // CYCLES_PER_SAMPLE
    //
    // 44.1 kHz =  22.676 us
    d3 = ((double)1000000.0) / ((double)sampling_rate);
    // 1 cycle = 1,015us => 22676 / 1.015
    d3 = d3 / ((double)1.015);
    CYCLES_PER_SAMPLE = d3;

    // prepare shadow regs
    for (int i = 0; i < 32; i++) {
        shadow_regs[i] = 0;
    }
}
