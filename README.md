# Zig SID Soundchip Emulation

This project provides **SID soundchip emulation** for **Zig**, enabling you to generate and play SID audio with ease.  
It is built upon the powerful **reSID** C++ library, delivering authentic SID sound emulation combined with the simplicity and safety of Zig.  

🎶 Because we love the Commodore 64 🎶

### 🎧 **Audio Library Independence**
This project is **audio-library agnostic** by design. The **core SID emulation and playback logic** is completely independent of any audio backend. However, the **current implementation** demonstrates audio playback using **SDL2** for convenience and cross-platform support. You can easily adapt or extend the audio interface to suit other libraries or custom solutions. The playback engine supports both **automatic audio callbacks** for seamless integration and **manual audio buffer generation** for full control and customization of the audio stream.  

<br>

## 🚀 Features

- 🎹 **SID Soundchip Emulation for Zig**: Experience the legendary SID sound directly in your Zig projects.
- ⚡ **Powered by reSID**: Leverages the proven **reSID** C++ library for high-quality sound emulation.  
(https://github.com/daglem/reSID)
- 🔧 **Simplified Framework**: All complex timing calculations and internal audio buffer management are handled automatically, allowing you to focus solely on the high-level API.
- 🔗 **C Bindings for Zig**: Provides clean **reSID C bindings** and integrates a clear and explicit Zig interface making **SID sound playback in Zig** straightforward and seamless.
- 🎧 **Audio Backend Flexibility**: The framework allows easy integration with different audio libraries
- ⚡ **Non-Blocking Audio Playback**: The audio playback runs in the background, so your application remains responsive and interactive while playing music.
- 🧵 **Playback Support for a dedicated thread**: Provides two execution models—"unthreaded" for simple integration and multi threaded for performance improvements, **audio visualization** and -**modification** possibilities.

<br>

## 🎼 **Audio and SID Chip Details**

- 🎵 **Stereo Audio Output**: The generated audio fills a **mono buffer**, providing the SID mono signal at equal levels on the left and right audio channel. A dual SID for a 6 voice true stereo sound is in progress.
- 🎚️ **Sampling Rate**: Set to **44.1kHz** by default. The sampling rate is **changeable at runtime** via the provided API.
- 🎛️ **SID Chip Model Selection**:
  - **SID6581**: Classic SID sound with characteristic filter behavior, more bassy sound.
  - **SID8580**: Enhanced model with improved signal-to-noise ratio (**default**).
- **Emulation Quality**: The emulation quality is set to the highest possible level supported by the reSID library: `SAMPLE_RESAMPLE_INTERPOLATE`.

<br>

## 💡 How The reSID Zig Integration Works

This project bridges the gap between C++, C, and Zig:

1. **reSID C++ Library**: Handles low-level SID emulation.
2. **Simplified C++ Framework**: A custom wrapper that manages timing, buffer generation, and playback logic, so you don’t have to.
3. **C Bindings**: Exposes the simpliefied framework functionalities through a clean C interface.
4. **Zig Wrapper**: A clear and explicit Zig interface built with structs and associated methods, wrapping C bindings for seamless SID playback and control.
5. **SDL2 Audio Interface**: The current demo code uses SDL2 for audio playback, but this can be replaced or extended.
6. 🧵 **Threaded and Unthreaded Execution**: Use the threaded variant to move audio buffer generation out of SDL into its own thread.

<br>

## 🛠️ Building the Project

Ensure you have **Zig 0.13.0+** and **SDL2** development libraries installed:

```bash
sudo apt install libsdl2-dev
zig build
```

Two examples are available for demonstration:

- 🏃 **Unthreaded Playback:** `src/main_unthreaded.zig`
- ⚡ **Threaded Playback:** `src/main_threaded.zig`

Both executables will be available in `zig-out/bin/`:

- `zig_sid_demo_unthreaded`
- `zig_sid_demo_threaded`

<br>

## 🎼 Running the demos

### 🏃 **Run Unthreaded Playback**
```bash
zig build run-unthreaded
```

### ⚡ **Run Threaded Playback**
```bash
zig build run-threaded
```

<br>
  
## 🎼 **ReSIDDmpPlayer Audio Buffer Generation**  

**`ReSIDDmpPlayer`** is currently the main method to playback whole SID tunes, or sound effects. Is designed to handle SID sound playback in the most simple way (see demo code below). Internally it operates by managing audio buffer generation and SID register updates based on reading the registers values from a dump, in repeated steps.


### 🧬 **How Audio Buffer Generation Works**  

#### 🔄 **Frame-Based SID Register Processing**  
- **SID dumps** contain **SID register values** representing audio frames.
- The player receives a dump via the `setDmp()` function
- For each **virtual PAL frame** (**50.125 Hz**, synchronized to a virtual vertical sync), the **player** reads a set of **25 SID register values** from the dump.  
- These registers are **bulk-written** to the **reSID engine** using `writeRegs()`.  
- The **`fillAudioBuffer()`** function clocks the **reSID engine** internally, generating **audio samples** that form the **audio buffer**.  

#### 🎵 **Audio Buffer Structure and Playback**  
- The generated audio is stored in **double buffers**:  
  - `buf_playing`: Currently being played by the **audio backend** (e.g., SDL2).  
  - `buf_next`: Prepared by the player for **future playback**.  
- Once the **audio backend** finishes playing `buf_playing`, the buffers are **swapped** internally to ensure **gapless playback**.  

<br>

### ⚡ **Buffer Generation Approaches**  

#### 🏃 **Unthreaded Mode** (Default, SDL Audio Callback Driven)  
- The **audio buffer** is updated **automatically** within the **SDL audio thread**.  
- The **SDL audio callback** invokes the player's internal audio generation methods, ensuring **continuous playback** without manual intervention.  
- Suitable for **simpler use cases** where **real-time audio control** is **not required**.  
<br>
#### 🧵 **Threaded Mode** (Manual Audio Buffer Updates)  
- The **user** gains full control over **buffer updates** by calling:  
  ```zig
  player.updateExternal(true);
  ```  
- In this mode, the **audio backend** (SDL2) plays audio from the buffer but **does not trigger buffer generation**.
- This approach allows for:  
  - 💡 **Real-time audio visualization**  
  - 🎚️ **Live audio manipulation**  
  - 🚀 **Performance optimization** via **multithreading**  
- The user must run:
  ```zig
  player.update();
  ```  
  at **regular intervals** (shorter than the buffer playback time, typically 4096 samples at 44.1kHz).
- Use **Zig’s threading API**:  
  ```zig
  const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
  defer playerThread.join(); 
  ``` 
- Example threaded update loop:  
  ```zig
  while (player.isPlaying()) {
      player.update();
      std.time.sleep(5 * std.time.ns_per_ms); // Small delay for CPU optimization
  }
  ```


<br>

### 🎛️ **Playback State and Audio Buffer Access**  

#### 🔍 **Playback Control Functions**  
- `player.play()`: Start playback from the beginning.  
- `player.stop()`: Stop playback and reset internal buffers.  
- `player.pause()`: Pause audio generation.  
- `player.continue_play()`: Resume playback after pause.  

#### 🎚️ **Accessing Audio Buffers**  
- Access **audio data buffers** for **real-time manipulation**:  
  ```zig
  const nextBuffer = ([*c]c_short) player.getPBData().buf_next;
  const playingBuffer = ([*c]c_short) player.getPBData().buf_playing;
  ```  
- Modify `buf_next` during playback for **dynamic audio effects** or **custom processing**.  


<br>

### 🔄 **SID Register Handling**  

- The player reads **SID register values** per frame and writes them to the **reSID** engine using:
  ```zig
  sid.writeRegs(registers[0..], 25);
  ```  
- For **register inspection** (e.g., visualizations), the current **SID state** can be queried:
  ```zig
  const regs = sid.getRegs(); // Returns [25]u8 array
  ```  

<br>

## 🧬 **Demo Code**

### main_unthreaded.zig - audio buffer calculation in the SDL callback

This example demonstrates the simplest way to play a SID dump using the `ReSIDDmpPlayer`.  
The player processes SID register values for each virtual frame, synchronized to a virtual PAL video standard vertical sync for accurate timing. That means it reads a set of SID register values from the dump and writes them to reSID, for each step.   The internal audio generation clocks the SID in the background and uses the output to fill an audio buffer. When the vertical sync frequency is reached, the next set of register values is read from the dump.

You can generate your own SID dumps using a siddump utility. In this demo, the SID dump is included via a C header file generated using the `xxd -i` tool.
- After initializing the `sid` and `player` struct instances, set the dump for the player:  
  ```zig
  player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len);
  ```
- And to start playback, simply call:  
  ```zig
  player.play();
  ```  
- SDL2 handles audio playback in the background using its audio callback mechanism. The audiodata is also updated in the callback routine.
- Audio generation runs entirely within the SDL audio thread.

```zig
const std = @import("std");
const sounddata = @cImport({
    @cInclude("demo_sound.h");
});
const SDL = @cImport({
    @cInclude("SDL.h");
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
    player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len); // set buffer of demo sound

    // -- THAT's IT! All we have to do now is to call player.play()
    // For this SDL implementation we need SDL to callback our
    // player.sdlAudioCallback(), it is specified below.
    // The userdata is required to point to the player object

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = SDL.SDL_AudioSpec{
        .freq = samplingRate,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
    };

    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[MAIN] Failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_Quit();

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[MAIN] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    SDL.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play();

    // print the SID registers
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[MAIN] SID Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});
        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
```

<br>

### main_threaded.zig - audio buffer calculation in a dedicated thread

This example demonstrates a more advanced approach to playing a SID dump.  
The `sid` and `player` struct instances are initialized the same way as in the unthreaded version. Playback also starts by calling `player.play()`.  

Before starting playback, the player must be instructed **not** to update the audio buffer within the SDL audio thread. This is done by calling:  
```zig
player.updateExternal(true);
```

SDL2 continues handling audio playback in the background. However, the audio buffer will no longer be updated automatically. The responsibility to call `player.update()` now lies with the user.  

The `update()` function only performs computations when the audio buffer has been consumed by SDL, ensuring efficient CPU usage. To maintain continuous playback, `update()` must be called at intervals shorter than the playback duration of the audio buffer (**4096 samples**).

The dedicated thread runs this `update()` function in a loop and exits gracefully once playback is complete. It runs until the player has stopped playing. It will check the player state via:  
```zig
player.isPlaying();
```

#### Realtime audio visualization and modification

Running `update()` in a separate thread enables **real-time audio visualization** and **manipulation**.  
The active audio buffer can be accessed via:  
```zig
([*c]c_short) player.getPBData().buf_playing
```

The playback mechanism uses a **double-buffering strategy**:  
- While SDL plays `player.getPBData().buf_playing`,  
- `player.getPBData().buf_next` is prepared by `update()`. By modifying this buffer you can control the audio!    
Once the playback buffer is fully consumed, the buffers are **swapped internally** to maintain seamless playback.


```zig
const std = @import("std");
const sounddata = @cImport({
    @cInclude("demo_sound.h");
});
const SDL = @cImport({
    @cInclude("SDL.h");
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
    player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len); // set buffer of demo sound
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
    var spec = SDL.SDL_AudioSpec{
        .freq = samplingRate,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
    };

    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[MAIN] Failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_Quit();

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[MAIN] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    SDL.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play(); // now player.isPlaying() will return true
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join(); // Wait for the thread to finish (if needed)

    // print the SID registers
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[MAIN] SID Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});
        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
```

<br>


## 🎧 **Zig API Documentation**

### 🎹 **ReSID Struct** (SID Emulation)

- `init(name: [*:0]const u8) !ReSID`: Initializes a **SID instance** with a given name.
- `deinit()`: Frees the **SID instance**.
- `getName() [*:0]const u8`: Returns the **name** of the SID instance.
- `setDBGOutput(enable: bool)`: Enables (**true**) or disables (**false**) **debug output**.
- `setChipModel(model: [*:0]const u8) bool`: Sets the **SID chip model** (**"MOS6581"** or **"MOS8580"**, default is MOS8580).
- `setSamplingRate(rate: c_int)`: Sets the **sampling rate** (default **44100 Hz**).
- `getSamplingRate() c_int`: Returns the **current sampling rate**.
- `writeRegs(self: *ReSID, regs: [*c]u8, len: c_int) void`: Bulk register write function for direct SID manipulation.
- `getRegs(self: *ReSID) [25]u8`: Read the current values of the SID registers

<br>


### 🎛️ **ReSIDDmpPlayer Struct** (Playback Controller)

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
- `fillAudioBuffer() i32`: internal function called by `update()`. Returns 1 at end of dump reached.

<br>

## 💾 **Status**

🔊 **Current Status:** The non-blocking background playback for sid-dumps is fully operational.

<br>

## ✨ **Roadmap & Future Enhancements**

- 🎵 **Flexible Sound Playback**: Convenience functions. (Like one for easy playback of multiple SID dumps (`player.playDump(...)`).
- 🎚️ **Audio Rendering**: Export audio as **WAV** or **RAW** into a buffer for further processing.
- 🎛️ **Real-Time Audio Mixing**: Support for mixing multiple SID streams in real time.
- 🎚️ **Volume and Panning Control**: Add runtime **volume adjustments** and **stereo panning**.
- **SDL Enqueueing support**: precalculate chunks of audio and simply enqueue them. No need for audio updating later. But also no real time audio control.
- **ReSIDSDL**: Providing a dedicated object that uses SDL for playback. Internally doing SDL initialization and configuration. This will reduce the usage to a few very simple and clean API calls.
- **Low Level SID Access**: binding the full resid original API to zig.

<br>

## 🎧 License

This project uses the **reSID** library and follows its licensing terms. The Zig and C bindings code is provided under the **MIT License**.

---

✨ *SID sound made simple. Powered by ReSID. Integrated with Zig. ✨
