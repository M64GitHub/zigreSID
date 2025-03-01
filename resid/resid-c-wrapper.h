// sid_wrapper.h - 2025, m64
#ifndef SID_WRAPPER_H
#define SID_WRAPPER_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "resid-dmpplayer-ctx.h"
typedef struct ReSID ReSID;
typedef struct ReSIDDmpPlayer ReSIDDmpPlayer;

// -- C-compatible interface for class ReSID

ReSID *ReSID_create(const char *name);
void ReSID_destroy(ReSID *resid);
const char *ReSID_getName(ReSID *resid);
void ReSID_setDBGOutput(ReSID *resid, bool b);
bool ReSID_setChipModel(ReSID *resid, const char *m);
void ReSID_setSamplingRate(ReSID *resid, int r);
int ReSID_getSamplingRate(ReSID *resid);
void ReSID_writeRegs(ReSID *resid, unsigned char *regs, int len);
unsigned char *Resid_getRegs(ReSID *resid);
int ReSID_clock(ReSID *resid, unsigned int cycle_count, short *buf, int buflen);

// -- C-compatible interface for class ReSIDDmpPlayer

ReSIDDmpPlayer *ReSIDDmpPlayer_create(ReSID *r);
void ReSIDDmpPlayer_destroy(ReSIDDmpPlayer *dmpply);
void ReSIDDmpPlayer_play(ReSIDDmpPlayer *dmpply);
void ReSIDDmpPlayer_stop(ReSIDDmpPlayer *dmpply);
void ReSIDDmpPlayer_pause(ReSIDDmpPlayer *dmpply);
void ReSIDDmpPlayer_continue(ReSIDDmpPlayer *dmpply);
bool ReSIDDmpPlayer_update(ReSIDDmpPlayer *dmpply);
DmpPlayerContext *ReSIDDmpPlayer_getPlayerContext(ReSIDDmpPlayer *dmpply);
bool ReSIDDmpPlayer_fillAudioBuffer(ReSIDDmpPlayer *dmpply);
unsigned long ReSIDDmpPlayer_RenderAudio(ReSIDDmpPlayer *dmpply,
                                         unsigned int start_step,
                                         unsigned int num_steps,
                                         unsigned int buf_size, short *buffer);
void ReSIDDmpPlayer_SDL_audio_callback(ReSIDDmpPlayer *dmpply, void *userdata,
                                       unsigned char *stream, int len);
void ReSIDDmpPlayer_setdmp(ReSIDDmpPlayer *dmpply, unsigned char *dump,
                           unsigned int len);
void ReSIDDmpPlayer_updateExternal(ReSIDDmpPlayer *dmpply, bool b);
bool ReSIDDmpPlayer_isPlaying(ReSIDDmpPlayer *dmpply);

int ReSIDDmpPlayer_getPlayerStatus(ReSIDDmpPlayer *dmpply);

#ifdef __cplusplus
}
#endif

#endif // SID_WRAPPER_H
