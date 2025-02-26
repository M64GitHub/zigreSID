// sid_wrapper.h - 2025, m64
#ifndef SID_WRAPPER_H
#define SID_WRAPPER_H

#include <stdbool.h>
#include "resid-dmpplayer-ctx.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ReSID ReSID;
typedef struct ReSIDDmpPlayer ReSIDDmpPlayer;

// -- C-compatible interface for class ReSID

ReSID*          ReSID_create(const char* name);
void            ReSID_destroy(ReSID* resid);
const char*     ReSID_getName(ReSID* resid);
void            ReSID_setDBGOutput(ReSID *resid, bool b);
bool            ReSID_setChipModel(ReSID *resid, const char *m);
void            ReSID_setSamplingRate(ReSID *resid, int r);
int             ReSID_getSamplingRate(ReSID *resid);
void            ReSID_writeRegs(ReSID *resid, unsigned char*regs, int len);
unsigned char  *Resid_getRegs(ReSID *resid);

// -- C-compatible interface for class ReSIDDmpPlayer

ReSIDDmpPlayer* ReSIDDmpPlayer_create(ReSID *r);
void            ReSIDDmpPlayer_destroy(ReSIDDmpPlayer* dmpply);
void            ReSIDDmpPlayer_play(ReSIDDmpPlayer* dmpply);
void            ReSIDDmpPlayer_stop(ReSIDDmpPlayer* dmpply);
void            ReSIDDmpPlayer_pause(ReSIDDmpPlayer* dmpply);
void            ReSIDDmpPlayer_continue(ReSIDDmpPlayer* dmpply);
bool            ReSIDDmpPlayer_update(ReSIDDmpPlayer* dmpply);
DmpPlayerContext *ReSIDDmpPlayer_getPlayerContext(ReSIDDmpPlayer* dmpply);
bool            ReSIDDmpPlayer_fillAudioBuffer(ReSIDDmpPlayer* dmpply);
void            ReSIDDmpPlayer_SDL_audio_callback(ReSIDDmpPlayer* dmpply, 
                                                  void *userdata, 
                                                  unsigned char *stream, 
                                                  int len);
void            ReSIDDmpPlayer_setdmp(ReSIDDmpPlayer* dmpply, 
                                      unsigned char *dump, unsigned int len);
void            ReSIDDmpPlayer_updateExternal(ReSIDDmpPlayer* dmpply,
                                              bool b);
bool            ReSIDDmpPlayer_isPlaying(ReSIDDmpPlayer* dmpply);

#ifdef __cplusplus
}
#endif

#endif // SID_WRAPPER_H

