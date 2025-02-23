#ifndef RESID_PBDATA_H
#define RESID_PBDATA_H

#include "audio-config.h"

typedef struct S_ReSIDPbData {
    short buf1[CFG_AUDIO_BUF_SIZE+1];
    short buf2[CFG_AUDIO_BUF_SIZE+1];
    short *buf_playing;
    short *buf_next;
    char buf_consumed;
    char buf_lock;
    char play;
    unsigned long stat_cnt;
    unsigned long stat_bufwrites;
    unsigned long stat_buf_underruns;
    unsigned long stat_framectr;
} ReSIDPbData;

#endif

