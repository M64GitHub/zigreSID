// resid-dmpplayer.cpp, 2023 M64

#include <stdio.h>
#include <string.h>
#include "resid-dmpplayer.h"

ReSIDDmpPlayer::ReSIDDmpPlayer(ReSID *r) :
    R(r), dmp(0), dmp_idx(0), dmp_len(0),samples2do(0)
{
    D = new DmpPlayerContext();

    D->buf_playing = 0;
    D->buf_next = 0;
    D->updates_external = 0;
}

ReSIDDmpPlayer::~ReSIDDmpPlayer()
{
    delete D;
}

void ReSIDDmpPlayer::SetDmp(unsigned char *dump, unsigned int len)
{
    dmp = dump;
    dmp_len = len;
}

DmpPlayerContext *ReSIDDmpPlayer::GetPlayerContext() const
{
    return D;
}

// call this frequently, to never underrun audio buffer fill
// returns 1 on end of playback
int ReSIDDmpPlayer::Update()
{
    if(!D->buf_consumed) return 0;
    if(FillAudioBuffer()) return true; // end of dmp reached
    D->buf_consumed = 0;

    return 0;
}

void ReSIDDmpPlayer::Play()
{
    if(!dmp || !dmp_len) return;

    D->buf_playing = 0;
    D->buf_next = D->buf1;
    set_next_regs();
    samples2do = R->SAMPLES_PER_FRAME;
    FillAudioBuffer();
    D->buf_lock = 0;

    // start audio playback
    D->play = 1;
}

void ReSIDDmpPlayer::Stop()
{
    D->play = 0;
    dmp_idx = 0;
}

void ReSIDDmpPlayer::Pause()
{
    D->play = 0;
}

void ReSIDDmpPlayer::Continue()
{
    D->play = 1;
}

bool ReSIDDmpPlayer::IsPlaying()
{
    if(D->play) return true;
    return false;
}

void ReSIDDmpPlayer::UpdateExternal(bool b)
{
    if(b) D->updates_external = 1;
    else D->updates_external = 0;
}

int ReSIDDmpPlayer::set_next_regs()
{
    // dmp format stores 25 reg vals
    int numregs = 25;

    if(!dmp || !dmp_len) return 2;
    if( (dmp_idx + numregs) > dmp_len) return 1;

    R->WriteRegs(dmp + dmp_idx, numregs);
    dmp_idx += numregs;

    return 0;
}

bool ReSIDDmpPlayer::FillAudioBuffer()
{
    int bufpos    = 0;
    int remainder = 0;
    int cycles2do = 0;;

    D->buf_lock = 1;

    while( (bufpos + samples2do) < CFG_AUDIO_BUF_SIZE ) {
        cycles2do = (R->CYCLES_PER_SAMPLE * samples2do + 0.5);
        R->Clock(cycles2do, D->buf_next + bufpos, CFG_AUDIO_BUF_SIZE);
        bufpos += samples2do;
        D->stat_framectr++;
        samples2do = R->SAMPLES_PER_FRAME;
        if(set_next_regs()) return true; // end of dmp reached
    }

    remainder = CFG_AUDIO_BUF_SIZE - bufpos;
    cycles2do = ((double) remainder * R->CYCLES_PER_SAMPLE + 0.5);
    R->Clock(cycles2do, D->buf_next + bufpos, CFG_AUDIO_BUF_SIZE);
    samples2do -= remainder;
    bufpos = 0;
   
    D->buf_lock = 0;
    return false;
}

int ReSIDDmpPlayer::LoadDmp(unsigned char *filename)
{
    return 0; 
}

void ReSIDDmpPlayer::SDL_audio_callback(void *userdata, 
                                        unsigned char *stream, 
                                        int len)
{
    D->stat_cnt++;

    if (!D->play) return;

    if (D->buf_lock) {
        D->stat_buf_underruns++;
        return;
    }

    // play audio buffer
    memcpy(stream, D->buf_next, len);

    // switch buffers
    if (D->buf_next == D->buf1) {
        D->buf_next = D->buf2;
        D->buf_playing = D->buf1;
    } else {
        D->buf_next = D->buf1;
        D->buf_playing = D->buf2;
    }

    D->stat_bufwrites++;
    D->buf_consumed = 1;

    if(!D->updates_external) {
        if(Update()) {
            D->play = 0;
            memset(stream, 0, len);
        }
    }
}


