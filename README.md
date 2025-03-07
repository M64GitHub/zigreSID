# Zig SID Soundchip Emulation

This project provides **SID soundchip emulation** for **Zig**, enabling you to generate and play SID audio with ease. It is built upon the powerful **reSID** C++ library, delivering authentic SID sound emulation combined with the simplicity and safety of Zig.  

🎶🎵 **Reviving Commodore 64 SID sound with the power of Zig!** 🎵🎶

<br>

## 🚀 Project Features

- 🎹 **SID Soundchip Emulation for Zig**: Experience the legendary SID retro sound directly in your Zig projects!
- ⚡ **Powered by reSID**: Leverages the proven **reSID** C++ library for high-quality sound emulation.  
(https://github.com/daglem/reSID)
- 🎼 **Dynamic Audio Buffer Rendering**: Generate high-fidelity PCM buffers from SID audio directly in Zig, allowing flexible post-processing, playback, and analysis.
- 📀 **WAV Export (Mono & Stereo)**: Save your pure SID-generated audio as .wav files, perfect for archival, visualization, music production, or integration into retro-inspired projects.
- 🎧 **Audio Backend Flexibility**: The framework allows easy integration with different audio libraries
- ⚡ **Non-Blocking Audio Playback**: The audio playback runs in the background, so your application remains responsive and interactive while playing music.
- 🧵 **Playback Support for a dedicated thread**: Provides two execution models — one for simple integration, and an advanced and multi threaded one for performance improvements, **realtime audio visualization** and -**modification** possibilities.
- 🔧 **Simplified API**: All complex timing calculations and internal audio buffer management are handled automatically, allowing you to focus solely on the high-level API.

<br>

### 🎧 **Audio Library Independence**
This project is **audio-library agnostic** by design. The **core SID emulation and playback logic** is completely independent of any audio backend. However, the **current implementation** demonstrates audio playback using **SDL2** for convenience and cross-platform support. You can easily adapt or extend the audio interface to suit other libraries or custom solutions. The playback engine supports both **automatic audio callbacks** for seamless integration and **manual audio buffer generation** for full control and customization of the audio stream.

<br>

### Minimal Example Wav-File Rendering

```zig
const std = @import("std");

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;
const WavWriter = @import("resid/wavwriter.zig").WavWriter;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const sampling_rate = 44100;

    const pcm_buffer = try gpa.alloc(i16, sampling_rate * 10); // audio buffer
    defer gpa.free(pcm_buffer);

    try stdout.print("[MAIN] zigSID audio rendering wav writer demo!\n", .{});

    // create a ReSID instance
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    // create a ReSIDDmpPlayer, and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    try player.loadDmp("data/plasmaghost.sid.dmp");

    // render 10 * 50 frames into PCM audio buffer
    // sid updates (audio frames) are executed at virtually 50.125 Hz
    // this will create 10 seconds of audio
    const steps_rendered = player.renderAudio(0, 10 * 50, pcm_buffer);
    try stdout.print("[MAIN] Steps rendered {d}\n", .{steps_rendered});

    // create a stereo wav file and write it to disk
    var mywav = WavWriter.init(gpa, "sid-out.wav");
    mywav.setMonoBuffer(pcm_buffer);
    try mywav.writeStereo();
}
```

<br>

### Minimal Example Playback-Code (SDL specific)
If you’re working with SDL, the `SDLreSIDDmpPlayer` struct provides a convenient way to handle playback. It fully manages SDL initialization, audio callbacks, and buffer generation internally, making playback effortless. Since it runs in the background, playback is non-blocking. More detailed examples can be found in the sections below.

```zig
const std = @import("std");

const SDLreSIDDmpPlayer = @import("resid/residsdl.zig").SDLreSIDDmpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[MAIN] zigSID audio demo sdl dump player!\n", .{});

    var player = try SDLreSIDDmpPlayer.init(gpa, "MY SID Player");
    defer player.deinit();

    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.play();

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();
}
```

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
3. **C Bindings**: Exposes the simpliefied framework through a clean C interface.
4. **Zig Wrapper**: A clear and explicit Zig interface built with structs and associated methods, wrapping C bindings for seamless SID playback and control. 

<br>

## 🛠️ Building the Project

Ensure you have **Zig 0.13.0+** and **SDL2** development libraries installed:

```bash
sudo apt install libsdl2-dev
zig build
```

5 examples are available for demonstration:

- 🎹 **Integrated SDL Playback:** `src/main_sdlplayer.zig`
     automatic SDL configuration, simple playback
- 🎛️ **Unthreaded Playback:** `src/main_unthreaded.zig`
     manual SDL configuration, and access to SID registers
- ⚡ **Threaded Playback:** `src/main_threaded.zig`
     manual SDL configuration, access to SID registers, and player internals, playback in custom thread
- 📀 **WAV Writing Example**: `src/main_wavwriter.zig`
     demonstrates how to generate a SID-based PCM buffer and save it as a .wav file
- 🎧 **Custom PCM Buffer Generation and Playback**: `src/main_renderaudio.zig`
     generates a raw SID audio PCM buffer and plays it directly (via SDL_QueueAudio())

Executables will be available in `zig-out/bin/`:

- `zig_sid_demo_sdl`
- `zig_sid_demo_unthreaded`
- `zig_sid_demo_threaded`
- `zig_sid_demo_renderaudio`
- `zig_sid_demo_wavwriter`

<br>

## 🎼 Running the demos

### 🎹 **Run Integrated SDL Playback** demo
```bash
zig build run-sdl
```

### 🎛️ **Run Unthreaded Playback** demo 
```bash
zig build run-unthreaded
```

### ⚡ **Run Threaded Playback** demo
```bash
zig build run-threaded
```

### 📀 **Run WAV Writing Example** demo
```bash
zig build run-wavwriter
```

### 🎧 **Custom PCM Buffer Generation and Playback** demo
```bash
zig build run-renderaudio
```

<br>
  
## 🎼 About the **ReSIDDmpPlayer**  
#### Realtime Audio Buffer Generation via Callback
**`ReSIDDmpPlayer`**  is the primary method for playing back complete SID tunes or sound effects. It provides a simple way to handle SID sound playback (see demo code below). Internally, it manages audio buffer generation and SID register updates, continuously reading and processing register values from a dump file in steps triggered by the audio-callback.


### 🧬 **How Realtime Audio Buffer Generation Works**  

#### 🔄 **Frame-Based SID Register Processing**  
- **SID dumps** contain **SID register values** representing audio frames.
- The player receives a dump via the `setDmp()` function
- For each **virtual PAL frame** (**50.125 Hz**, synchronized to a virtual vertical sync), the **player** reads a set of **25 SID register values** from the dump.  
- These registers are **bulk-written** to the **reSID engine** using `writeRegs()`.  
- The **`fillAudioBuffer()`** function clocks the **reSID engine** internally, generating **audio samples** that form the **audio buffer**.  

#### 🎵 **Audio Buffer Structure and Playback**  
- The generated audio is stored in **double buffers**:  
  - `buf_ptr_playing`: Currently being played by the **audio backend** (e.g., SDL2).  
  - `buf_ptr_next`: Prepared by the player for **future playback**.  
- Once the **audio backend** finishes playing `buf_ptr_playing`, the buffers are **swapped** internally to ensure **gapless playback**.  

<br>

### ⚡ **Buffer Generation Approaches**  

#### 🏃 **Unthreaded Mode** (Default, SDL Audio Callback Driven)  
- The **audio buffer** is updated **automatically** within the **SDL audio thread**.  
- The **SDL audio callback** invokes the player's internal audio generation methods, ensuring **continuous playback** without manual intervention.  
- Suitable for **simpler use cases** where **real-time audio control** is **not required**.
- No extra code is required. All required for audio playback is to call `player.play()`


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
  update() returns false, when the end of buffer playback is reached.
- Use **Zig’s threading API**:  
  ```zig
  const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
  defer playerThread.join(); 
  ``` 
- Example threaded update loop:  
  ```zig
    fn playerThreadFunc(player: *ReSIDDmpPlayer) !void {
        while (player.isPlaying()) {
            if (!player.update()) {
                player.stop();
                const stdout = std.io.getStdOut().writer();
                try stdout.print("[PLAYER] Player stopped!\n", .{});
            }
            std.time.sleep(30 * std.time.ns_per_ms);
        }
    }
  ```


<br>

### 🎛️ **Playback State and Audio Buffer Access**  

#### 🔍 **Playback Control Functions**  
- `player.play()`: Start playback from the beginning.  
- `player.stop()`: Stop playback and reset internal buffers.  
- `player.pause()`: Pause audio generation.  
- `player.continuePlayback()`: Resume playback after pause.  

#### 🎚️ **Accessing Audio Buffers**  
- Access **audio data buffers** for **real-time manipulation**:  
  ```zig
  const nextBuffer = ([*c]c_short) player.getPlayerContext().buf_ptr_next;
  const playingBuffer = ([*c]c_short) player.getPlayerContext().buf_ptr_playing;
  ```  
- Modify the buffer at `buf_ptr_next` during playback for **dynamic audio effects** or **custom processing**.  


<br>

### 🔄 **SID Register Handling**  

- The player reads **SID register values** per frame and writes them to the **reSID** engine using:
  ```zig
  sid.writeRegs(registers[0..]);
  ```  
- For **register inspection** (e.g., visualizations), the current **SID state** can be queried:
  ```zig
  const regs = sid.getRegs(); // Returns [25]u8 array
  ```  

<br>




## 🧬 **Demo Code**

### main_unthreaded.zig
#### audio buffer calculation in the SDL callback

This example demonstrates the simplest way to play a SID dump using the `ReSIDDmpPlayer`.  
The player processes SID register values for each virtual frame, synchronized to a virtual PAL video standard vertical sync for accurate timing. That means it reads a set of SID register values from the dump and writes them to reSID, for each step.   The internal audio generation clocks the SID in the background and uses the output to fill an audio buffer. When the vertical sync frequency is reached, the next set of register values is read from the dump.

You can generate your own SID dumps using a siddump utility. In this demo, the SID dump is included via a C header file generated using the `xxd -i` tool.
- After initializing the `sid` and `player` struct instances, set the []u8 dump for the player:  
  ```zig
  player.setDmp(sounddata);
  ```
- And to start playback, simply call:  
  ```zig
  player.play();
  ```  
- SDL2 handles audio playback in the background using its audio callback mechanism. The audiodata is also updated in the callback routine.
- Audio generation runs entirely within the SDL audio thread.

```zig
const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL.h");
});

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[MAIN] zigSID audio demo unthreaded!\n", .{});

    // create a ReSID instance and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    // create a ReSIDDmpPlayer instance and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    // init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = &ReSIDDmpPlayer.sdlAudioCallback,
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

    SDL.SDL_PauseAudioDevice(dev, 0); // Start SDL audio
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{sid.getSamplingRate()});
    // end of SDL initialization

    player.play();

    // do something in main: print the SID registers, and player stats
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[MAIN] SID Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});

        try stdout.print("[MAIN] {d} buffers played, {d} buffer underruns, {d} SID frames\n", .{ player.getPlayerContext().stat_bufwrites, player.getPlayerContext().stat_buf_underruns, player.getPlayerContext().stat_framectr });

        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
```

<br>

### main_threaded.zig
#### audio buffer calculation in a dedicated thread

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
([*c]c_short) player.getPlayerContext().buf_ptr_playing
```

The playback mechanism uses a **double-buffering strategy**:  
- While SDL plays `player.getPlayerContext().buf_ptr_playing`,  
- `player.getPlayerContext().buf_ptr_next` is prepared by `update()`. By modifying this buffer you can control the audio!    
Once the playback buffer is fully consumed, the buffers are **swapped internally** to maintain seamless playback.


```zig
const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL.h");
});

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;
const DP_PLAYSTATE = @import("resid/resid.zig").DP_PLAYSTATE;

fn playerThreadFunc(player: *ReSIDDmpPlayer) !void {
    while (player.isPlaying()) {
        if (!player.update()) {
            player.stop();
        }
        std.time.sleep(35 * std.time.ns_per_ms);
    }
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[MAIN] zigSID audio demo threaded!\n", .{});

    // create a ReSID instance and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    // create a ReSIDDmpPlayer instance and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.updateExternal(true); // make sure, SDL does not call the update function

    // init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = &ReSIDDmpPlayer.sdlAudioCallback,
        .userdata = @ptrCast(&player),
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

    SDL.SDL_PauseAudioDevice(dev, 0); // Start SDL audio
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{sid.getSamplingRate()});
    // end of SDL initialization

    // start the playback, and thread for calling the update function
    player.play();
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join(); // Wait for the thread to finish (if needed)

    // do something in main: print the SID registers, and player stats
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[MAIN] SID Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});

        try stdout.print("[MAIN] {d} buffers played, {d} buffer underruns, {d} SID frames\n", .{ player.getPlayerContext().stat_bufwrites, player.getPlayerContext().stat_buf_underruns, player.getPlayerContext().stat_framectr });

        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    if (player.getPlayState() == DP_PLAYSTATE.stopped) {
        try stdout.print("[PLAYER] Player stopped!\n", .{});
    }

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
```

<br>


## 🎧 **Zig API Documentation**

### 🎹 **ReSID Struct** (SID Emulation)

- `init(allocator: std.mem.Allocator, name: [*:0]const u8) !ReSID`: Initializes a **SID instance** with a given name.
- `deinit()`: Frees the **SID instance**.
- `getName() [*:0]const u8`: Returns the **name** of the SID instance.
- `setChipModel(model: [*:0]const u8) bool`: Sets the **SID chip model** (**"MOS6581"** or **"MOS8580"**, default is MOS8580).
- `setSamplingRate(rate: c_int)`: Sets the **sampling rate** (default **44100 Hz**).
- `getSamplingRate() c_int`: Returns the **current sampling rate**.
- `writeRegs(self: *ReSID, regs: *[25]u8) void`: Bulk register write function for direct SID manipulation.
- `getRegs(self: *ReSID) [25]u8`: Read the current values of the SID registers

<br>


### 🎛️ **ReSIDDmpPlayer Struct** (Playback Controller)

- `init(allocator: std.mem.Allocator, resid: *c.ReSID) !ReSIDDmpPlayer`: Creates a **player instance** linked to a **SID instance**.
- `deinit()`: Frees the **player instance**.
- `play()`: Starts **playback** from the beginning.
- `stop()`: **Stops** and **resets** playback.
- `pause()`: **Pauses** playback (audio generation stops).
- `continue_play()`: **Continues** playback after pausing.
- `update()`: **Updates** the **audio buffer**; call this when not using callbacks. Returns false when playback ends.
- `setDmp(dump: []u8)`: Loads a **SID dump** for playback (**must be called before** `play()`).
- `loadDmp(filename: []const u8) !void`: **load dump** from file.
- `getPlayerContext() *c.DmpPlayerContext`: Returns a **pointer to playback data**.
- `updateExternal(b: bool)`: Allows external control of the audio update process.
- `isPlaying() bool`: Checks if playback is currently active.
- `fillAudioBuffer() bool`: internal function called by `update()`. Returns true at end of dump reached.
- `getPlayState() DP_PLAYSTATE`: Returns the **current playback state** as an enum:
  - `DP_PLAYSTATE.stopped`
  - `DP_PLAYSTATE.playing`
  - `DP_PLAYSTATE.paused`
 - `renderAudio(start_step: u32, num_steps: u32, buffer: []i16) u32`:
    Generates a mono raw PCM buffer (signed 16 bit) from the dump, or a part of it. `start_step` and `num_steps` specify the part of the dump (25 register values per step). The buffer will allways be completely filled while clocking the sid. This means when the end of dump is reached before buffer end, the sid is clocked without any register changes until the end of the buffer is reached. It also stops at the end of the buffer in case the steps would not fit into the buffer. The function returns the number of steps processed.

<br>

### 🎹 **SDLreSIDDmpPlayer Struct** (Simplified SDL Player)

- `init(allocator: std.mem.Allocator, name: [*:0]const u8) !*SDLreSIDDmpPlayer`: Creates a new SDLreSIDDmpPlayer instance, initializes ReSID, ReSIDDmpPlayer, and SDL.
- `deinit(self: *SDLreSIDDmpPlayer) void`: Cleans up the instance by stopping playback, closing SDL, and freeing memory.
- `setDmp(dump: []u8)`: Loads a **SID dump** for playback (**must be called before** `play()`).
- `loadDmp(filename: []const u8) !void`: **load dump** from file.
- `play() void`: Starts playing the loaded SID dump.
- `stop() void`: Stops playback.

<br>

### 🎛️ **DmpPlayerContext Struct**  

The `DmpPlayerContext` struct represents the **internal state** and **buffer management** for the `ReSIDDmpPlayer`. It manages **audio buffer double-buffering**, **playback state**, and **runtime statistics** to ensure **smooth and continuous SID sound playback**.

#### 🧩 **Zig Struct Definition**:
```zig
const CFG_AUDIO_BUF_SIZE = 4096; // Adjust if needed

const DP_PLAYSTATE = enum(c_int) {
    stopped = 0,
    playing = 1,
    paused = 2,
};

const DmpPlayerContext = extern struct {
    buf1: [CFG_AUDIO_BUF_SIZE]i16,       // First audio buffer
    buf2: [CFG_AUDIO_BUF_SIZE]i16,       // Second audio buffer
    buf_ptr_playing: *i16,               // Pointer to currently playing buffer
    buf_ptr_next: *i16,                  // Pointer to next buffer
    buf_consumed: bool,                  // Buffer consumed flag (true/false) (ie when written to SDL audio stream)
    buf_lock: bool,                      // Buffer lock flag, set while calculating and writing new audio
    buf_calculated: bool,                // Buffer calculation flag, set when update() calculated new audio
    play_state: DP_PLAYSTATE,            // Playback state enum
    updates_external: bool,              // External update control flag
    stat_cnt: u64,                       // Playback cycle counter
    stat_bufwrites: u64,                 // Buffer write count
    stat_buf_underruns: u64,             // Buffer underrun occurrences
    stat_framectr: u64,                  // Frame counter (synchronized at 50.125 Hz)
};
```

#### **Fields Overview**:

- **🎼 Audio Buffers**:  
  - **`buf1`, `buf2`** (`[CFG_AUDIO_BUF_SIZE]i16`):  
    Double audio buffers storing **16-bit PCM audio samples**. Used alternately for continuous playback.  
  - **`buf_ptr_playing`** (`*i16`):  
    Pointer to the **currently playing** buffer.  
  - **`buf_ptr_next`** (`*i16`):  
    Pointer to the **next buffer** to be played after `buf_ptr_playing` is consumed.

<br>

- **🔒 Buffer Management Flags**:  
  - **`buf_consumed`** (`bool`):  
    **Flag** indicating whether the **current buffer** has been fully consumed (ie by SDL).  
  - **`buf_lock`** (`bool`):  
    Used to **lock the buffer** during updates to prevent **race conditions**.  
  - **`play_state`** (`DP_PLAYSTATE`):  
    **Playback state flag** see enum `DP_PLAYSTATE`.  
  - **`updates_external`** (`bool`):  
    Indicates if **buffer updates** are controlled **externally** (e.g., in **threaded mode**).
  - **`buf_calculated`** (`bool`):  
    Indicates if the last call to the `player.update()` function calculated new audio
    

<br>

- **📊 Playback Statistics**:  
  - **`stat_cnt`** (`u64`):  
    **Playback cycle counter**, tracking the total number of processed cycles.  
  - **`stat_bufwrites`** (`u64`):  
    Counts the **total buffer writes**, useful for **performance monitoring**.  
  - **`stat_buf_underruns`** (`u64`):  
    Tracks **buffer underruns**, which occur when buffer generation takes longer than buffer playback.  
  - **`stat_framectr`** (`u64`):  
    **Frame counter** number of SID audio frames played, synchronized to the **50.125 Hz** **PAL vertical sync**.
    
<br>

## 🎧 License

This project uses the **reSID** library and follows its licensing terms. The Zig and C bindings code is provided under the **MIT License**.

---

✨ *SID sound made simple. Powered by ReSID. Integrated with Zig. ✨
