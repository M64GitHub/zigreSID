// sid_wrapper.cpp  - 2025, m64
#include "resid-c-wrapper.h"
#include "resid-dmpplayer-ctx.h"
#include "resid.h"
#include "resid-dmpplayer.h"

extern "C" {

// -- ReSID

    ReSID* ReSID_create(const char* name) {
        return new ReSID(name);
    }

    void ReSID_destroy(ReSID* resid) {
        delete resid;
    }

    const char* ReSID_getName(ReSID* resid) {
        return resid->GetName();
    }

    void ReSID_setDBGOutput(ReSID *resid, bool b)
    {
        resid->SetDbgOutput(b);
    }

    bool ReSID_setChipModel(ReSID *resid, const char *m)
    {
        return resid->SetChipModel(m);
    }

    
    void ReSID_setSamplingRate(ReSID *resid, int r)
    {
        resid->SetSamplingRate(r);
    }

    int  ReSID_getSamplingRate(ReSID *resid)
    {
        return resid->GetSamplingRate();
    }

    void ReSID_writeRegs(ReSID *resid, unsigned char *regs, int len)
    {
        resid->WriteRegs(regs, len);
    }


    unsigned char  *Resid_getRegs(ReSID *resid)
    {
        return resid->GetRegs();
    }

// -- ReSIDDmpPlayer

    ReSIDDmpPlayer* ReSIDDmpPlayer_create(ReSID *r)
    {
        return new ReSIDDmpPlayer(r);
    }

    void ReSIDDmpPlayer_destroy(ReSIDDmpPlayer* dmpply)
    {
        delete dmpply;
    }

    void ReSIDDmpPlayer_play(ReSIDDmpPlayer* dmpply)
    {
        dmpply->Play();
    }

    void ReSIDDmpPlayer_stop(ReSIDDmpPlayer* dmpply)
    {
        dmpply->Stop();
    }

    void ReSIDDmpPlayer_pause(ReSIDDmpPlayer* dmpply)
    {
        dmpply->Pause();
    }

    void ReSIDDmpPlayer_continue(ReSIDDmpPlayer* dmpply)
    {
        dmpply->Continue();
    }

    bool ReSIDDmpPlayer_update(ReSIDDmpPlayer* dmpply)
    {
        return dmpply->Update();
    }

    DmpPlayerContext *ReSIDDmpPlayer_getPlayerContext(ReSIDDmpPlayer* dmpply)
    {
        return dmpply->GetPlayerContext();
    }

    bool ReSIDDmpPlayer_fillAudioBuffer(ReSIDDmpPlayer* dmpply)
    {
        return dmpply->FillAudioBuffer();
    }
    
    void ReSIDDmpPlayer_SDL_audio_callback(ReSIDDmpPlayer* dmpply, 
                                                      void *userdata, 
                                                      unsigned char *stream, 
                                                      int len)
    {
       dmpply->SDL_audio_callback(userdata, stream, len);
    }

    void ReSIDDmpPlayer_setdmp(ReSIDDmpPlayer* dmpply, 
                               unsigned char *dump, unsigned int len)
    {
        dmpply->SetDmp(dump, len);
    }

    void ReSIDDmpPlayer_updateExternal(ReSIDDmpPlayer* dmpply,
                                              bool b)
    {
        dmpply->UpdateExternal(b);
    }

    bool ReSIDDmpPlayer_isPlaying(ReSIDDmpPlayer* dmpply)
    {
        return dmpply->IsPlaying();
    }
}
