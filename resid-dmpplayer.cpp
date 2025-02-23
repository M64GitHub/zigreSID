// resid-dmpplayer.cpp, 2023 M64

#include <stdio.h>
#include "resid-dmpplayer.h"
#include "dmpplayer-pbdata.h"

ReSIDDmpPlayer::ReSIDDmpPlayer(ReSID *r)
{
    R = r; 
    D = new ReSIDPbData;

    dmp = 0;
    dmp_len = 0;
    samples2do = 0; 

    D->buf_playing = 0;
    D->buf_next = 0;


    printf("[DMPPL] ReSID dump player initialized\n"); 
}

ReSIDDmpPlayer::~ReSIDDmpPlayer()
{
}

void ReSIDDmpPlayer::SetDmp(unsigned char *dump, unsigned int len)
{
    dmp = dump;
    dmp_len = len;
}

ReSIDPbData *ReSIDDmpPlayer::GetPBData()
{
    return D;
}

// call this frequently, to never underrun audio buffer fill
int ReSIDDmpPlayer::Update()
{
    if(!D->buf_consumed) return 0;
    if(fill_audio_buffer()) return 1; // end of dmp reached
    D->buf_consumed = 0;

    return 0;
}

void ReSIDDmpPlayer::Play()
{
    if(!dmp || !dmp_len) return;

    // prepare buffer for first playback
//    dmp_idx = 0;
    D->buf_playing = 0;
    D->buf_next = D->buf1;
    set_next_regs();
    samples2do = R->SAMPLES_PER_FRAME;
    fill_audio_buffer();
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

int ReSIDDmpPlayer::fill_audio_buffer()
{
    int bufpos    = 0;
    int remainder = 0;
    int cycles2do = 0;;

    D->buf_lock = 1;

    while( (bufpos + samples2do) < CFG_AUDIO_BUF_SIZE ) {
        cycles2do = (R->CYCLES_PER_SAMPLE * samples2do + 0.5);
        // printf("[DMPPl] frame: %lu, samples2do: %d, cycles2do: %d, ctr: %lu\n", 
        //        D->stat_framectr, 
        //        samples2do, cycles2do, D->stat_cnt);
        R->Clock(cycles2do, D->buf_next + bufpos, CFG_AUDIO_BUF_SIZE);
        bufpos += samples2do;

        // next frame
        // printf("[DMPPl] *** next frame ***\n");
        D->stat_framectr++;
        samples2do = R->SAMPLES_PER_FRAME;
        if(set_next_regs()) return 1; // end of dmp reached
    }

    remainder = CFG_AUDIO_BUF_SIZE - bufpos;
    cycles2do = ((double) remainder * R->CYCLES_PER_SAMPLE + 0.5);
    // printf("[DMPPl] remainder: %d, bufpos: %d, cycles2do: %d\n",
    //        remainder, bufpos, cycles2do);
    R->Clock(cycles2do, D->buf_next + bufpos, CFG_AUDIO_BUF_SIZE);
    samples2do -= remainder;
    bufpos = 0;
   
    D->buf_lock = 0;
    return 0;
}

int ReSIDDmpPlayer::LoadDmp(unsigned char *filename)
{

    return 0; 
}
