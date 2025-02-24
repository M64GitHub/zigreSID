# Zig SID Soundchip Emulation 🎵✨

This project provides **SID soundchip emulation** for **Zig**, enabling you to generate and play SID audio with ease. It is built upon the powerful **reSID** C++ library, delivering authentic SID sound emulation combined with the simplicity and safety of Zig.  
Commodore 64 sound forever 🎶!!

### 🎧 **Audio Library Independence**
This project is **audio-library agnostic** by design. The **core SID emulation and playback logic** is completely independent of any audio backend. However, the **current implementation** demonstrates audio playback using **SDL2** for convenience and cross-platform support. You can easily adapt or extend the audio interface to suit other libraries or custom solutions.

## 🚀 Features

- 🎹 **SID Soundchip Emulation for Zig**: Experience the legendary SID sound directly in your Zig projects.
- ⚡ **Powered by reSID**: Leverages the proven **reSID** C++ library for high-quality sound emulation.  
(https://github.com/daglem/reSID)
- 🔧 **Simplified C++ Framework**: All complex timing calculations and internal audio buffer management are handled automatically, allowing you to focus solely on the high-level API.
- 🔗 **C Bindings for Zig**: Provides clean **C bindings** to the simplified C++ framework, making **SID sound playback in Zig** straightforward and seamless.
- 🎧 **Audio Backend Flexibility**: The framework allows easy integration with different audio libraries; SDL2 is used in the current example.
- ⚡ **Non-Blocking Audio Playback**: The audio playback runs **in the background**, so your application remains responsive and interactive while playing music.
- 🧵 **Threaded and Unthreaded Playback Support**: Provides two execution models—**unthreaded** for simple integration and **threaded** for performance improvements.

## 🎼 **Audio and SID Chip Details**

- 🎵 **Stereo Audio Output**: The generated audio fills a **mono buffer**, providing the SID mono signal at equal levels on the left and right channel.
- 🎚️ **Default Sampling Rate**: Set to **44.1kHz** by default. The sampling rate is **changeable at runtime** via the provided API.
- 🎛️ **SID Chip Model Selection**:
  - **SID6581**: Classic SID sound with characteristic filter behavior, more bassy sound.
  - **SID8580**: Enhanced model with improved signal-to-noise ratio (**default**).
- **Highest Emulation Quality**: The emulation quality is set to the **highest level** supported by the reSID library: **SAMPLE_RESAMPLE_INTERPOLATE**.

## 💡 How It Works

This project bridges the gap between C++, C, and Zig:

1. **ReSID C++ Library**: Handles low-level SID emulation.
2. **Simplified C++ Framework**: A custom wrapper that manages timing, buffer generation, and playback logic, so you don’t have to.
3. **C Bindings**: Exposes key C++ functionalities through a clean C interface.
4. **Zig Wrapper**: Object-oriented style Zig code that wraps the C bindings, providing an intuitive API for playback and control.
5. **SDL2 Audio Interface**: The current demo code uses SDL2 for audio playback, but this can be replaced or extended.
6. 🧵 **Threaded and Unthreaded Execution**: Compare performance using two provided executables.

## 🎼 Example Usage

Two examples are available for demonstration:

- 🏃 **Unthreaded Playback:** `src/main_unthreaded.zig`
- ⚡ **Threaded Playback:** `src/main_threaded.zig`

### 🏃 **Run Unthreaded Playback**
```bash
zig build run-unthreaded
```

### ⚡ **Run Threaded Playback**
```bash
zig build run-threaded
```

## 🛠️ Building the Project

Ensure you have **Zig 0.13.0+** and **SDL2** development libraries installed:

```bash
sudo apt install libsdl2-dev
zig build
```

Both executables will be available in `zig-out/bin/`:

- `zig_sid_demo_unthreaded`
- `zig_sid_demo_threaded`

## 🎧 **Zig API Documentation**

### 🎹 **ReSID Class** (SID Emulation)

- `init(name: [*:0]const u8) !ReSID`: Initializes a **SID instance** with a given name.
- `deinit()`: Frees the **SID instance**.
- `getName() [*:0]const u8`: Returns the **name** of the SID instance.
- `setDBGOutput(enable: bool)`: Enables (**true**) or disables (**false**) **debug output**.
- `setChipModel(model: [*:0]const u8) bool`: Sets the **SID chip model** (**"MOS6581"** or **"MOS8580"**, default is MOS8580).
- `setSamplingRate(rate: c_int)`: Sets the **sampling rate** (default **44100 Hz**).
- `getSamplingRate() c_int`: Returns the **current sampling rate**.
- `writeRegs(self: *ReSID, regs: [*c]u8, len: c_int) void`: Bulk register write function for direct SID manipulation.

---

### 🎛️ **ReSIDDmpPlayer Class** (Playback Controller)

- `init(resid: *c.ReSID) !ReSIDDmpPlayer`: Creates a **player instance** linked to a **SID instance**.
- `deinit()`: Frees the **player instance**.
- `play()`: Starts **playback** from the beginning.
- `stop()`: **Stops** and **resets** playback.
- `pause()`: **Pauses** playback (audio generation stops).
- `continue_play()`: **Continues** playback after pausing.
- `update()`: **Updates** the **audio buffer**; call this when not using callbacks. Returns 1 when playback ends.
- `setDmp(dump: [*c]u8, len: c_uint)`: Loads a **SID dump** for playback (**must be called before** `play()`).
- `getPBData() *c.ReSIDPbData`: Returns a **pointer to playback data**.
- `getAudioCallback() *const fn(...)`: Provides the **SDL-compatible audio callback**.
- `updateExternal(b: bool)`: Allows external control of the audio update process.
- `isPlaying() bool`: Checks if playback is currently active.

## 💾 **Status**

🔊 **Current Status:** *Now featuring **threaded** and **unthreaded** playback options!* 🚀 Both versions are available for performance comparison. The **non-blocking background playback** is fully operational, ensuring responsive applications.

## ✨ **Roadmap & Future Enhancements**

- 🎵 **Flexible Sound Playback**: Easy playback of multiple SID dumps (`player.playDump(...)`).
- 🎚️ **Advanced Audio Rendering**: Export audio as **WAV** for further processing.
- 🎛️ **Real-Time Audio Mixing**: Support for mixing multiple SID streams in real time.
- 🎚️ **Volume and Panning Control**: Add runtime **volume adjustments** and **stereo panning**.
- 🔗 **Enhanced Multithreading Options**: More robust threading support for ultra-smooth playback.

## 🎧 License

This project uses the **reSID** library and follows its licensing terms. The Zig and C bindings code is provided under the **MIT License**.

---

✨ *SID sound made simple. Powered by ReSID. Integrated with Zig. Now with threaded and unthreaded playback magic.* ✨
