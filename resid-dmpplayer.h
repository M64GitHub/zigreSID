// resid-dmpplayer.h, 2023 M64

#ifndef RESID_DMPPLAYER_H
#define RESID_DMPPLAYER_H

#include "resid.h"
#include "dmpplayer-pbdata.h"


class ReSIDDmpPlayer
{
public:
    // instanciate with resid and playback data struct only
    ReSIDDmpPlayer(ReSID *r);
    ~ReSIDDmpPlayer();

    // set sid dump to playback
    void SetDmp(unsigned char *dump, unsigned int len);
    int  LoadDmp(unsigned char *filename);

    // playback control
    void Play(); // always start from beginning
    void Stop(); // stops and resets playback data
    void Pause();// stops generation of new audio buffers only
    void Continue(); // continues updating audio buffer

    // continuously call this from outside, to ensure
    // audio buffer is filled and ready for playback
    // (compare to teensy audio library)
    // when called not often enough, buffer underrun will be 
    // detected
    // returns 1 on end of dump
    int Update();

    int FillAudioBuffer(); // audio buffer fill: samples until next frame
    void SDL_audio_callback(void *userdata, unsigned char *stream, int len);

    ReSIDPbData *GetPBData() const;

    short outputs[3]; // channel amplitude for visualizers, etc.

private:
    unsigned int dmp_idx; // inted into played sid dump
    int set_next_regs(); // called on each frame by fill_audio_buffer

    ReSID *R;
    ReSIDPbData *D;

    // sid dmp
    unsigned char *dmp;
    unsigned int dmp_len;
    int samples2do; // 882
};

#endif

