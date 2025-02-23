# Zig SID Soundchip Emulation 🎵✨

This project provides **SID soundchip emulation** for **Zig**, enabling you to generate and play SID audio with ease. It is built upon the powerful **reSID** C++ library, delivering authentic SID sound emulation combined with the simplicity and safety of Zig.

### 🎧 **Audio Library Independence**
This project is **audio-library agnostic** by design. The **core SID emulation and playback logic** is completely independent of any audio backend. However, the **current implementation** demonstrates audio playback using **SDL2** for convenience and cross-platform support. You can easily adapt or extend the audio interface to suit other libraries or custom solutions.

## 🚀 Features

- 🎹 **SID Soundchip Emulation for Zig**: Experience the legendary SID sound directly in your Zig projects.
- ⚡ **Powered by reSID**: Leverages the proven **reSID** C++ library for high-quality sound emulation.  
(https://github.com/daglem/reSID)
- 🔧 **Simplified C++ Framework**: All complex timing calculations and internal audio buffer management are handled automatically, allowing you to focus solely on the high-level API.
- 🔗 **C Bindings for Zig**: Provides clean **C bindings** to the simplified C++ framework, making **SID sound playback** in Zig straightforward and seamless.
- 🎧 **Audio Backend Flexibility**: The framework allows easy integration with different audio libraries; SDL2 is used in the current example.

## 🎼 **Audio and SID Chip Details**

- 🎵 **Stereo Audio Output**: The generated audio fills a **stereo buffer**, providing the **SID mono signal** at **equal levels** on both **left and right** channels.
- 🎚️ **Default Sampling Rate**: Set to **44.1kHz** by default. The sampling rate is **changeable at runtime** via the provided API, allowing flexible playback configurations.
- 🎛️ **SID Chip Model Selection**:
  - **SID6581**: Classic SID sound with characteristic filter behavior.
  - **SID8580**: Enhanced model with improved signal-to-noise ratio (**default**).
- 🌟 **Highest Emulation Quality**: The emulation quality is **fixed** at the **highest level** supported by the reSID library: 
  
  > **SAMPLE_RESAMPLE_INTERPOLATE** – providing superior sound fidelity with resampling and interpolation techniques.

## 💡 How It Works

This project bridges the gap between C++, C, and Zig:

1. **ReSID C++ Library**: Handles low-level SID emulation.
2. **Simplified C++ Framework**: A custom wrapper that manages timing, buffer generation, and playback logic, so you don’t have to.
3. **C Bindings**: Exposes key C++ functionalities through a clean C interface.
4. **Zig Wrapper**: Object-oriented style Zig code that wraps the C bindings, providing an intuitive API for playback and control.
5. **SDL2 Audio Interface**: The current implementation uses SDL2 for audio playback, but this can be replaced or extended.

## 🎼 Example Usage

```zig
const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("resid_wrapper.h");
    @cInclude("demo_sound.h");
});

const ReSID = @import("resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const samplingRate: i32 = 44100;

    // -- create sid and player

    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    sid.setSamplingRate(samplingRate);
    sid.setDBGOutput(true);
    _ = sid.setChipModel("MOS6581");

    try stdout.print("SID instance name: {s}\\n", .{sid.getName()});

    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(c.demo_sid, c.demo_sid_len);

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = c.SDL_AudioSpec{
        .freq = samplingRate,
        .format = c.AUDIO_S16SYS,
        .channels = 2,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player),
    };

    if (c.SDL_Init(c.SDL_INIT_AUDIO) < 0) {
        try stdout.print("Failed to initialize SDL audio: {s}\\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const dev = c.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("Failed to open SDL audio device: {s}\\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_CloseAudioDevice(dev);

    c.SDL_PauseAudioDevice(dev, 0); // Start audio playback/callbacks 
    try stdout.print("Playback started at {d} Hz.\\n", .{samplingRate});

    player.play();

    std.time.sleep(5 * std.time.ns_per_s); // Let the sound play for a bit

    player.stop();

    c.SDL_PauseAudioDevice(dev, 1); // Stop audio playback/callbacks
    try stdout.print("Playback stopped.\\n", .{});
}

```

## 🛠️ Building the Project

Ensure you have **Zig 0.13.0+** and **SDL2** development libraries installed:

```bash
sudo apt install libsdl2-dev
zig build
```

To run:

```bash
zig build run
```

Or execute the binary directly:

```bash
LD_LIBRARY_PATH=. ./zig-out/bin/zig_sid_demo
```

## 🎧 **Zig API Documentation**

### 🎹 **ReSID Class** (SID Emulation)

- `init(name: [*:0]const u8) !ReSID`: Initializes a **SID instance** with a given name.
- `deinit()`: Frees the **SID instance**.
- `getName() [*:0]const u8`: Returns the **name** of the SID instance.
- `setDBGOutput(enable: bool)`: Enables (**true**) or disables (**false**) **debug output**.
- `setChipModel(model: [*:0]const u8) bool`: Sets the **SID chip model** (**"MOS6581"** or **"MOS8580"**, default is 8580).
- `setSamplingRate(rate: c_int)`: Sets the **sampling rate** (default **44100 Hz**, changeable at runtime).
- `getSamplingRate() c_int`: Returns the **current sampling rate**.

---

### 🎛️ **ReSIDDmpPlayer Class** (Playback Controller)

- `init(resid: *c.ReSID) !ReSIDDmpPlayer`: Creates a **player instance** linked to a **SID instance**.
- `deinit()`: Frees the **player instance**.
- `play()`: Starts **playback** from the beginning.
- `stop()`: **Stops** and **resets** playback.
- `pause()`: **Pauses** playback (audio generation stops).
- `continuePlayback()`: **Continues** playback after pausing.
- `update()`: **Updates** the **audio buffer**; should be called regularly.
- `fillAudioBuffer() c_int`: **Fills** the audio buffer; returns **1** when the dump finishes.
- `setDmp(dump: [*c]u8, len: c_uint)`: Loads a **SID dump** for playback (**must be called before** `play()`).
- `getPBData() *c.ReSIDPbData`: Returns a **pointer to playback data**.
- `getAudioCallback() *const fn(...)`: Provides the **SDL-compatible audio callback** for integration with **SDL2**.


## 🎧 License

This project uses the **ReSID** library and follows its licensing terms. The Zig and C bindings code is provided under the **MIT License**.

---

✨ *SID sound made simple. Powered by ReSID. Integrated with Zig.* ✨
