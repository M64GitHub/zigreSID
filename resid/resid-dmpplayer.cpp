// resid-dmpplayer.cpp, 2023 M64

#include "resid-dmpplayer.h"
#include "resid-dmpplayer-ctx.h"
#include <stdio.h>
#include <string.h>

ReSIDDmpPlayer::ReSIDDmpPlayer(ReSID *r)
    : R(r), dmp(0), dmp_idx(0), dmp_len(0), samples2do(0)
{
    D = new DmpPlayerContext();

    D->buf_ptr_playing = 0;
    D->buf_ptr_next = 0;
    D->updates_external = false;
    D->buf_consumed = false;
    D->buf_lock = false;
    D->stat_cnt = 0;
    D->stat_bufwrites = 0;
    D->stat_framectr = 0;
    D->stat_buf_underruns = 0;
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

DP_PLAYSTATE ReSIDDmpPlayer::GetPlayerStatus()
{
    return D->play_state;
}

void ReSIDDmpPlayer::Play()
{
    if (!dmp || !dmp_len) return;

    D->buf_ptr_playing = 0;
    D->buf_ptr_next = D->buf1;
    set_next_regs();
    samples2do = R->SAMPLES_PER_FRAME;
    FillAudioBuffer();
    D->buf_lock = false;

    // start audio playback
    D->play_state = PLAYER_PLAYING;
}

void ReSIDDmpPlayer::Stop()
{
    D->play_state = PLAYER_STOPPED;
    dmp_idx = 0;
}

void ReSIDDmpPlayer::Pause()
{
    D->play_state = PLAYER_PAUSED;
}

void ReSIDDmpPlayer::Continue()
{
    D->play_state = PLAYER_PLAYING;
}

bool ReSIDDmpPlayer::IsPlaying()
{
    if (D->play_state == PLAYER_PLAYING) return true;
    return false;
}

void ReSIDDmpPlayer::UpdateExternal(bool b)
{
    D->updates_external = b;
}

int ReSIDDmpPlayer::set_next_regs()
{
    // dmp format stores 25 reg vals
    int numregs = 25;

    if (!dmp || !dmp_len) return 2;
    if ((dmp_idx + numregs) > dmp_len) return 1;

    R->WriteRegs(dmp + dmp_idx, numregs);
    dmp_idx += numregs;

    return 0;
}

bool ReSIDDmpPlayer::FillAudioBuffer()
{
    int bufpos = 0;
    int remainder = 0;
    int cycles2do = 0;

    D->buf_lock = true;

    while ((bufpos + samples2do) < CFG_AUDIO_BUF_SIZE) {
        cycles2do = (R->CYCLES_PER_SAMPLE * samples2do + 0.5);
        R->Clock(cycles2do, D->buf_ptr_next + bufpos, CFG_AUDIO_BUF_SIZE);
        bufpos += samples2do;
        D->stat_framectr++;
        samples2do = R->SAMPLES_PER_FRAME;
        if (set_next_regs()) return true; // end of dmp reached
    }

    remainder = CFG_AUDIO_BUF_SIZE - bufpos;
    cycles2do = ((double)remainder * R->CYCLES_PER_SAMPLE + 0.5);
    R->Clock(cycles2do, D->buf_ptr_next + bufpos, CFG_AUDIO_BUF_SIZE);
    samples2do -= remainder;
    bufpos = 0;

    D->buf_lock = false;
    return false;
}

unsigned long ReSIDDmpPlayer::RenderAudio(unsigned int start_step,
                                          unsigned int num_steps,
                                          unsigned int buf_size, short *buffer)
{
    unsigned int steps_done = 0;
    unsigned long bufpos = 0;
    unsigned long remainder = 0;
    unsigned long cycles2do = 0;
    int l_samples2do = R->SAMPLES_PER_FRAME;

    set_next_regs();

    // skip to start_pos
    for (int i = 0; i < ((int)start_step - 1); i++) {
        if (set_next_regs()) return 0;
    }

    D->buf_lock = true;

    bool end_reached = false;
    while (((bufpos + l_samples2do) < buf_size) && steps_done < num_steps) {
        cycles2do = (R->CYCLES_PER_SAMPLE * l_samples2do + 0.5);
        R->Clock(cycles2do, buffer + bufpos, buf_size - bufpos);
        bufpos += l_samples2do;
        D->stat_framectr++;
        l_samples2do = R->SAMPLES_PER_FRAME;
        if (set_next_regs()) {
            end_reached = true;
            break;
        }; // end of dmp reached
        steps_done++;
    }

    // if end reached we do nothing but let the audio buffer be rendered to
    // its end, while clocking the sid
    remainder = CFG_AUDIO_BUF_SIZE - bufpos;
    cycles2do = ((double)remainder * R->CYCLES_PER_SAMPLE + 0.5);
    R->Clock(cycles2do, buffer + bufpos, buf_size - bufpos);

    return steps_done;
}

// call this frequently, to never underrun audio buffer fill
// returns true on end of playback
bool ReSIDDmpPlayer::Update()
{
    D->buf_calculated = false;
    if (D->buf_consumed) {
        // switch buffers
        if (D->buf_ptr_next == D->buf1) {
            D->buf_ptr_next = D->buf2;
            D->buf_ptr_playing = D->buf1;
        } else {
            D->buf_ptr_next = D->buf1;
            D->buf_ptr_playing = D->buf2;
        }
        D->buf_consumed = false;
        D->buf_calculated = true;
        if (FillAudioBuffer()) return false;
    }

    return true;
}

void ReSIDDmpPlayer::SDL_audio_callback(void *userdata, unsigned char *stream,
                                        int len)
{
    D->stat_cnt++;

    if (D->play_state != PLAYER_PLAYING) {
        memset(stream, 0, len);
        return;
    }

    if (D->buf_lock) {
        // FillAuduiBuffer still running
        D->stat_buf_underruns++;
        return;
    }

    // play audio buffer
    memcpy(stream, D->buf_ptr_next, len);

    D->stat_bufwrites++;
    D->buf_consumed = true;

    if (!D->updates_external) {
        if (!Update()) {
            D->play_state = PLAYER_STOPPED;
            memset(stream, 0, len);
        }
    }
}

int ReSIDDmpPlayer::LoadDmp(unsigned char *filename)
{
    return 0;
}
