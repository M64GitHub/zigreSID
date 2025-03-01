// resid-dmpplayer.h, 2023 M64

#ifndef RESID_DMPPLAYER_H
#define RESID_DMPPLAYER_H

#include "resid-dmpplayer-ctx.h"
#include "resid.h"

class ReSIDDmpPlayer
{
public:
    // instanciate with resid and playback data struct only
    ReSIDDmpPlayer(ReSID *r);
    ~ReSIDDmpPlayer();

    // set sid dump to playback
    void SetDmp(unsigned char *dump, unsigned int len);
    int LoadDmp(unsigned char *filename);

    // playback control
    void Play();     // always start from beginning
    void Stop();     // stops and resets playback data
    void Pause();    // stops generation of new audio buffers only
    void Continue(); // continues updating audio buffer

    bool IsPlaying();
    void UpdateExternal(bool b);

    // continuously call this from outside, to ensure
    // audio buffer is filled and ready for playback
    // (compare to teensy audio library)
    // when called not often enough, buffer underrun will be
    // detected
    // returns false on end of dump
    bool Update();

    bool FillAudioBuffer(); // audio buffer fill: samples until next frame

    unsigned long RenderAudio(unsigned int start_step, unsigned int num_steps,
                              unsigned int buf_size, short *buffer);

    void SDL_audio_callback(void *userdata, unsigned char *stream, int len);

    DmpPlayerContext *GetPlayerContext() const;
    DP_PLAYSTATE GetPlayerStatus();

    short outputs[3]; // channel amplitude for visualizers, etc.

private:
    unsigned int dmp_idx; // inted into played sid dump
    int set_next_regs();  // called on each frame by fill_audio_buffer

    ReSID *R;
    DmpPlayerContext *D;

    // sid dmp
    unsigned char *dmp;
    unsigned int dmp_len;
    int samples2do; // 882
};

#endif
