// sid_wrapper.cpp (C++ wrapper implementation) - NEW WRAPPER FILE ADDED TO LIB
#include "resid_wrapper.h"
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

    void ReSIDDmpPlayer_update(ReSIDDmpPlayer* dmpply)
    {
        dmpply->Update();
    }

    ReSIDPbData    *ReSIDDmpPlayer_getPBData(ReSIDDmpPlayer* dmpply)
    {
        return dmpply->GetPBData();
    }

}
