// resid.h, 2023, m64
#ifndef SDL_RESID_H
#define SDL_RESID_H

#include "audio-config.h"
#include "resid/sid.h"
#include "resid/siddefs.h"

class ReSID
{
public:
    ReSID(const char *name);
    ~ReSID();

    const char *GetName() const;
    const char *GetModel() const;

    void SetChipModel(chip_model m);
    bool SetChipModel(const char *m);
    void SetSamplingRate(int r);
    int GetSamplingRate() const;

    void WriteRegs(unsigned char *regs, int len);
    unsigned char *GetRegs();

    // dumb audio rendering, not frame aware
    int Clock(unsigned int cycles, short *buf, int buflen);

    // calculated CONSTANTS
    // no getters for fast access
    int SAMPLES_PER_FRAME;
    int CYCLES_PER_FRAME;
    double CYCLES_PER_SAMPLE;

private:
    void precalc_constants();
    char name[1024];
    SID sid;
    chip_model model;
    int sampling_rate;
    unsigned char shadow_regs[32];
};

#endif
