#ifndef RESID_PBDATA_H
#define RESID_PBDATA_H

#include "audio-config.h"

typedef enum DP_PLAYSTATE {
    PLAYER_STOPPED = 0,
    PLAYER_PLAYING,
    PLAYER_PAUSED
} DP_PLAYSTATE;

// context for the dump-player
typedef struct S_DmpPlayerContext {
    short buf1[CFG_AUDIO_BUF_SIZE];
    short buf2[CFG_AUDIO_BUF_SIZE];
    short *buf_ptr_playing;
    short *buf_ptr_next;
    bool buf_consumed;
    bool buf_lock;
    bool buf_calculated;
    DP_PLAYSTATE play_state;
    bool updates_external;
    unsigned long stat_cnt;
    unsigned long stat_bufwrites;
    unsigned long stat_buf_underruns;
    unsigned long stat_framectr;
} DmpPlayerContext;

#endif

