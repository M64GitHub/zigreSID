# Zig SID Soundchip Emulation 🎵✨

This project provides **SID soundchip emulation** for **Zig**, enabling you to generate and play SID audio with ease. It is built upon the powerful **reSID** C++ library, delivering authentic SID sound emulation combined with the simplicity and safety of Zig.  
🎶 Commodore 64 sound forever 🎶!!

### 🎧 **Audio Library Independence**
This project is **audio-library agnostic** by design. The **core SID emulation and playback logic** is completely independent of any audio backend. However, the **current implementation** demonstrates audio playback using **SDL2** for convenience and cross-platform support. You can easily adapt or extend the audio interface to suit other libraries or custom solutions.

## 🚀 Features

- 🎹 **SID Soundchip Emulation for Zig**: Experience the legendary SID sound directly in your Zig projects.
- ⚡ **Powered by reSID**: Leverages the proven **reSID** C++ library for high-quality sound emulation.  
(https://github.com/daglem/reSID)
- 🔧 **Simplified C++ Framework**: All complex timing calculations and internal audio buffer management are handled automatically, allowing you to focus solely on the high-level API.
- 🔗 **C Bindings for Zig**: Provides clean **C bindings** to the simplified C++ framework, making **SID sound playback in Zig** straightforward and seamless.
- 🎧 **Audio Backend Flexibility**: The framework allows easy integration with different audio libraries; SDL2 is used in the current example.
- ⚡ **Non-Blocking Audio Playback**: The audio playback runs in the background, so your application remains responsive and interactive while playing music.
- 🧵 **Threaded and Unthreaded Playback Support**: Provides two execution models—unthreaded for simple integration and threaded for performance improvements.

## 🎼 **Audio and SID Chip Details**

- 🎵 **Stereo Audio Output**: The generated audio fills a **mono buffer**, providing the SID mono signal at equal levels on the left and right channel.
- 🎚️ **Default Sampling Rate**: Set to **44.1kHz** by default. The sampling rate is **changeable at runtime** via the provided API.
- 🎛️ **SID Chip Model Selection**:
  - **SID6581**: Classic SID sound with characteristic filter behavior, more bassy sound.
  - **SID8580**: Enhanced model with improved signal-to-noise ratio (**default**).
- **Highest Emulation Quality**: The emulation quality is set to the highest possible level supported by the reSID library: `SAMPLE_RESAMPLE_INTERPOLATE`.

## 💡 How The reSID Integration Works

This project bridges the gap between C++, C, and Zig:

1. **reSID C++ Library**: Handles low-level SID emulation.
2. **Simplified C++ Framework**: A custom wrapper that manages timing, buffer generation, and playback logic, so you don’t have to.
3. **C Bindings**: Exposes key C++ functionalities through a clean C interface.
4. **Zig Wrapper**: Object-oriented style Zig code that wraps the C bindings, providing an intuitive API for playback and control.
5. **SDL2 Audio Interface**: The current demo code uses SDL2 for audio playback, but this can be replaced or extended.
6. 🧵 **Threaded and Unthreaded Execution**: Use the threaded variant to move audio buffer generation out of SDL into its own thread.

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

## 🧬 Demo Code
### main_unthreaded.zig - audio buffer calculation in the SDL callback
This is the most simple example of how to play a SID dump: the ReSIDDmpPlayer writes the SID register values of the dump on each virtual frame (synced to a virtual PAL video standard vertical sync).  
You can use a siddump utility to generate your own dumps. In this example the siddump is included via a C header file, generated via `xxd -i`.  
Once you set up the `sid` and `player` objects, you can run `player.play()` to start playback. SDL will play the sound in the background, and update the audiodata via callback. Audio generation is done within the callback in the SDL thread.

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

    try stdout.print("[MAIN] zigSID audio demo unthreaded!\n", .{});

    // -- create sid and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();
    _ = sid.setChipModel("MOS8580"); // just demo usage, this is the default

    // -- create player and initialize it with a demo sound
    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(c.demo_sid, c.demo_sid_len); // set buffer of demo sound

    // -- THAT's IT! All we have to do now is to call player.play()
    // For this SDL implementation we need SDL to callback our
    // player.sdlAudioCallback(), it is specified below.
    // The userdata is required to point to the player object

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = c.SDL_AudioSpec{
        .freq = samplingRate,
        .format = c.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
    };

    if (c.SDL_Init(c.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[MAIN] Failed to initialize SDL audio: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const dev = c.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[MAIN] Failed to open SDL audio device: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_CloseAudioDevice(dev);

    c.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play();

    for (1..10) |i| {
        stdout.print("[MAIN] Still alive! Step {d}\n", .{i}) catch {};
        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    c.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
```
### main_threaded.zig - audio buffer calculation in its own thread
This example of how to play a SID dump is a little bit more advanced. We set up the  `sid` and `player` objects like in the unthreaded version, and run `player.play()` to start playback.  
Before we do so, we need to tell the player, it shall not call the update() function in the SDL audio thread. We do so by calling `player.updateExternal(true);`.  
SDL will still play the audio buffer in the background, but this audio buffer will never get updated. We need to call the update function ourselfes. Luckily the update function will only do it's work, when the audiobuffer is consumed by SDL, else not waste time and CPU. All we need to do is to run the update() function in a timer interval smaller than the playback duration of the audio buffer (4096 samples).  
Our thread will need to exit when playback stopped, so we simply check `player.isPlaying()` in our "infinite" while loop.  
This also gives you the opportunity to access and modify the audio buffer. You can access it via `([*c]c_short) player.getPBData().buf_next`. The audio playback uses 2 buffers. When update() is called, it will fill `player.getPBData().buf_next` while SDL plays `player.getPBData().buf_playing`. When SDL consumed the playback buffer, these two buffers will be swapped internally.

```zig
const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("resid_wrapper.h");
    @cInclude("demo_sound.h");
});

const ReSID = @import("resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid.zig").ReSIDDmpPlayer;

fn playerThreadFunc(player: *ReSIDDmpPlayer) void {
    while (player.isPlaying()) {
        player.update();
        std.time.sleep(5 * std.time.ns_per_ms);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const samplingRate: i32 = 44100;

    try stdout.print("[MAIN] zigSID audio demo threaded!\n", .{});

    // -- create sid and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();
    _ = sid.setChipModel("MOS8580"); // just demo usage, this is the default

    // -- create player and initialize it with a demo sound
    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(c.demo_sid, c.demo_sid_len); // set buffer of demo sound
    player.updateExternal(true); // make sure, SDL does not call the update-
    // function

    // -- THAT's IT! All we have to do now is to call player.play()
    // For this SDL implementation we need SDL to callback our
    // player.sdlAudioCallback(), it is specified below.
    // The userdata is required to point to the player object
    // The audio callback is not calling player.update(), so we will start
    // our update thread directly after player.play
    // (to make sure, player.isPlaying will return true)

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = c.SDL_AudioSpec{
        .freq = samplingRate,
        .format = c.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
    };

    if (c.SDL_Init(c.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[MAIN] Failed to initialize SDL audio: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const dev = c.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[MAIN] Failed to open SDL audio device: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_CloseAudioDevice(dev);

    c.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play(); // now player.isPlaying() will return true
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join(); // Wait for the thread to finish (if needed)

    for (1..10) |i| {
        stdout.print("[MAIN] Still alive! Step {d}\n", .{i}) catch {};
        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    c.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
```


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

🔊 **Current Status:** *Now featuring **threaded** and **unthreaded** playback options!* The non-blocking background playback for sid-dumps is fully operational, ensuring responsive applications.

## ✨ **Roadmap & Future Enhancements**

- 🎵 **Flexible Sound Playback**: Convenience functions. (Like one for easy playback of multiple SID dumps (`player.playDump(...)`).
- 🎚️ **Audio Rendering**: Export audio as **WAV** or **RAW** into a buffer for further processing.
- 🎛️ **Real-Time Audio Mixing**: Support for mixing multiple SID streams in real time.
- 🎚️ **Volume and Panning Control**: Add runtime **volume adjustments** and **stereo panning**.
- 🔗 **Enhanced Multithreading Options**: More robust threading support for ultra-smooth playback.
- **SDL Enqueueing support**: precalculate chunks of audio and simply enqueue them. No need for audio updating later. But also no real time audio control.
- **ReSIDSDL**: Providing a dedicated object that uses SDL for playback. Internally doing SDL initialization and configuration. This will reduce the usage to a few very simple and clean API calls.
- **Low Level SID Access**: binding more of the resid original API to zig.

## 🎧 License

This project uses the **reSID** library and follows its licensing terms. The Zig and C bindings code is provided under the **MIT License**.

---

✨ *SID sound made simple. Powered by ReSID. Integrated with Zig. Now with threaded and unthreaded playback magic.* ✨
