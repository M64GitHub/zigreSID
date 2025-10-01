# SID Soundchip Emulation in Zig  
![License](https://img.shields.io/badge/license-MIT-brightgreen?style=flat)
![Version](https://img.shields.io/badge/version-0.3.0-8a2be2?style=flat)
![Zig](https://img.shields.io/badge/Zig-0.14.0-orange?style=flat)  

Experience authentic MOS 6581/8580 SID soundchip emulation with Zig! This project provides SID audio generation, processing, and playback, designed for precision and flexibility.

### **Powered by reSID**
The proven C++ SID emulation library, which forms the core of the audio processing and ensures authentic sound.

### **Powered by zig64!**
Seamless `.sid` file support enables you to load and execute real **C64 SID music** with full playback precision. A **Zig-native, cycle-accurate MOS 6510 CPU emulator** ensures faithful replication of C64 hardware behavior. With precise PAL & NTSC timing, full register state tracking, and real-time playback integration, it provides everything you need for accurate SID music playback, debugging, and deep analysis.  

The generated audio can be played in real-time or exported as high-quality `.wav` files, making it ideal for both live playback and post-processing. 

Whether you're composing retro music, analyzing SID tunes, or integrating SID emulation into your projects, this sets out to become your ultimate tool!  

<br>

## **Features**  

- **`.sid` File Support** – Load and execute real C64 SID music effortlessly!
  
- **`.wav` File Support (Mono & Stereo)** – Save your SID-generated audio as `.wav` files, ideal for archiving, music production, and retro inspired projects.
  
- **Flexible Audio Backends** – Seamlessly integrates with various audio libraries for playback.
  
- **Non-Blocking Audio Playback** – Music playback fully runs in the background keeping your code responsive!
   
- **Dynamic Audio Buffer Rendering** – Generate high-fidelity PCM audio buffers from SID music, perfect for playback, processing, and visualization.
  
- **Dedicated Thread Support** – Choose between simple single-threaded playback or advanced multi-threaded execution for performance gains, real-time audio visualization, and modifications.
  
- **Simplified API** – All complex timing calculations and buffer management are handled automatically!
  
- **Full 6510 CPU Emulation** – Features a cycle-accurate 6510 CPU emulator with real C64 timing and behavior.
  
- **Lots of Examples!** - Create SID `register dumps`, `convert` SID songs `to wav audio` files, and examples for all major structs!
  
- **Fully Integrated in Zig** – A seamless Zig-native implementation, making SID emulation more accessible than ever!
  
- **Powered by reSID** – Uses the proven reSID C++ library for high-quality sound emulation. ([reSID on GitHub](https://github.com/daglem/reSID))
  
- **Powered by zig64** – A high-accuracy C64 emulator core written in Zig. ([zig64 on GitHub](https://github.com/M64GitHub/zig64))  

<br>

### **Audio Library Independence**  
The SID emulation and playback logic are **fully independent of any audio library**. While examples use **SDL2** for cross-platform playback, you can easily integrate other audio backends or custom solutions. The playback engine supports both **automatic callbacks** for seamless integration and **manual buffer generation** for full control over the audio stream.

<br>

## Getting Started  

Getting started is easy! Below are two minimal examples demonstrating how to generate WAV files or play back SID audio in real-time with just a few lines of code.  

These examples use a `SID register dump`, a file containing the raw register changes of a `.sid` tune.  
You can create your own SID dumps from `.sid` files using the included `sid-dump.zig` utility (see below).  

> **Note:** SID dumps are powerful because they eliminate CPU processing overhead compared to full `.sid` execution.  
> They can be treated like **audio samples**, allowing you to extract, rearrange, and reuse specific parts of SID tunes or isolate particular sounds for creative remixing! A powerful tool for music experimentation and sound design! 



### Example: Real-Time Playback (SDL)
If you're using SDL, the `SdlDumpPlayer` struct offers a hassle-free way to handle playback.  
It fully manages SDL initialization, audio callbacks, and buffer generation, making playback effortless and non-blocking. Since it runs in the background, your program remains fully responsive.  

For more detailed examples, check the sections below.

**How It Works:**  
- A **SdlDumpPlayer** instance is created and linked to an SDL audio stream internally.  
- The **SID dump file** (`.dmp`) is loaded, containing all SID register changes from a `.sid` tune.  
- Calling `player.play()` starts playback, with SDL handling audio processing in the background.  

```zig
const std = @import("std");
const ReSid = @import("resid");

const Player = ReSid.SdlDumpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    // create SDL sid dump player and configure it
    var player = try Player.init(gpa, "player#1");
    defer player.deinit();

    // load sid dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.play();

    try stdout.print("[EXE] press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();
}
```

<br>

### Example: Render a SID Dump to a WAV File 

This example demonstrates how to **convert** a SID register dump into a WAV file.  
It initializes a SID chip instance, loads a SID dump file (`.dmp`), and **renders PCM audio** from it.  
The rendered audio is stored in a **stereo WAV file**, making it easy to use for playback, archiving, or further processing.  

**How It Works:**  
- A **SID instance** is created for audio synthesis.  
- A **DumpPlayer** loads and plays the `.dmp` file, simulating SID playback.  
- The SID is **rendered frame-by-frame** at **50.125 Hz**, generating **10 seconds** of audio.  
- The resulting PCM data is stored and saved to `sid-out.wav`.  

```zig
const std = @import("std");
const ReSid = @import("resid");

const Sid = ReSid.Sid;
const DumpPlayer = ReSid.DumpPlayer;
const WavWriter = ReSid.WavWriter;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const sampling_rate = 44100;

    const pcm_buffer = try gpa.alloc(i16, sampling_rate * 10); // audio buffer
    defer gpa.free(pcm_buffer);

    // create a Sid instance and configure it
    var sid = try Sid.init("sid#1");
    defer sid.deinit();

    // create a DumpPlayer instance and initialize it with the Sid instance
    var player = try DumpPlayer.init(gpa, sid);
    defer player.deinit();

    try player.loadDmp("data/plasmaghost.sid.dmp");

    // render 50 * 10 frames into PCM audio buffer, from frame 0.
    // sid updates (audio frames) are executed at virtually 50.125 Hz
    // this will create 10 seconds audio
    const steps_rendered = player.renderAudio(0, 50 * 10, pcm_buffer);
    try stdout.print("[EXE] Steps rendered {d}\n", .{steps_rendered});

    // create a stereo wav file and write it to disk
    var mywav = WavWriter.init(gpa, "sid-out.wav");
    mywav.setMonoBuffer(pcm_buffer);
    try mywav.writeStereo();
}
```

<br>

## Building the Project
#### Requirements
- **Zig** 0.14.0
- **SDL2** (optional, required for SDL-based playback, and building examples)

#### Build
```sh
sudo apt install libsdl2-dev  # Ubuntu/Debian, optional
zig build
```

## Using zigreSID In Your Project
To add zigreSID as a dependency, use:
```sh
zig fetch --save https://github.com/M64GitHub/zigreSID/archive/refs/tags/v0.3.0-alpha.tar.gz
```
This will add the dependency to your `build.zig.zon`:
```zig
.dependencies = .{
    .resid = .{
        .url = "https://github.com/M64GitHub/zigreSID/archive/refs/tags/v0.3.0-alpha.tar.gz",
        .hash = "resid-0.3.0-LzaBAvQpCwD3HuPRq4UHYf_V1MEILa1z5hIdZZhY_Ulg",
    },
},
```

In your `build.zig`, import the `resid` module as follows:
```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add zigreSID as a dependency
    const dep_resid = b.dependency("resid", .{}); 
    const mod_resid = dep_resid.module("resid");  

    // Define an example executable
    const exe = b.addExecutable(.{
        .name = "sid-dump",
        .root_source_file = b.path("src/sid-dump.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link the resid module
    exe.root_module.addImport("resid", mod_resid); 

    b.installArtifact(exe);
}
```
After adding the dependency, simply run `zig build` to compile your project!

## Examples Included

The following examples demonstrate different ways to use the **SID emulation and playback capabilities**.  
Each example is built automatically and placed in `zig-out/bin/`.

| **Executable**                 | **Description**                                                                 | **Source File**                                      |
|--------------------------------|---------------------------------------------------------------------------------|------------------------------------------------------|
| `sdl-dump-player`           | Automatic SDL configuration, simple SID dump playback.                         | `src/examples/sdl-sid-dump-player.zig`             |
| `dump-player`               | Manual SDL configuration, access to SID registers.                             | `src/examples/sid-dump-player.zig`                 |
| `dump-player-threaded`       | Manual SDL configuration, SID register access, and playback in a custom thread. | `src/examples/sid-dump-player-threaded.zig`        |
| `siddump-wav-writer`        | Generate a SID-based PCM buffer and save it as a `.wav` file.                   | `src/examples/wav-writer-example.zig`              |
| `sid-render-audio`          | Generate a raw SID PCM buffer and play it directly using `SDL_QueueAudio()`.    | `src/examples/render-audio-example.zig`            |
| `sid-dump`                  | Convert `.sid` files into SID register dumps for further processing.             | `src/examples/sidfile-dump.zig`                    |

### **Where to Find the Executables?**
After building the project, the compiled executables are placed in:
```sh
zig-out/bin/
```

<br>

## Playback Example Code
Working with zigreSID is best demonstrated by examples. The following two examples show the usage of the `DumpPlayer` struct, in two different modes of operation. You will see it is quite simple to setup playback. Most of the code deals with setting up an SDL audio stream.  

### SID Dump Player (`sid-dump-player.zig`)

This is a full example, and it demonstrates the simplest way to play a SID dump using the `DumpPlayer`.  
The player processes SID register values for each virtual frame, synchronized to a virtual PAL video standard vertical sync for accurate timing. That means it reads a set of SID register values from the dump and writes them to reSID, for each step.   
The internal audio generation clocks the SID in the background and uses the output to fill an audio buffer. When the vertical sync frequency is reached, the next set of register values is read from the dump.  

You can generate your own SID dumps using a siddump utility. In this demo, the SID dump is loaded from a file:
- After initializing the `sid` and `player` struct instances, load the []u8 dump for the player:  
  ```zig
  try player.loadDmp("data/plasmaghost.sid.dmp");
  ```
- And to start playback, simply call:  
  ```zig
  player.play();
  ```  
- SDL2 handles audio playback in the background using its audio callback mechanism, the audiodata is updated in the callback routine.
- -> Audio generation runs entirely within the SDL audio thread.

`Code`:
Include zigreSID, define and init `Sid` and a `DumpPlayer`
```zig
const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h"); // we setup the DumpPlayer to use SDL audio callbacks
});
const ReSid = @import("resid");      // import zigreSID
```
```zig
const Sid = ReSid.Sid;               // struct Sid for audio generation
const DumpPlayer = ReSid.DumpPlayer; // struct DumpPlayer for controlling the Sid using a buffer
```
```zig
pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
```
```zig
    // create a Sid instance and configure it
    var sid = try Sid.init("zigsid#1");
    defer sid.deinit();
```
```zig
    // create a DumpPlayer instance and initialize it with the ReSid instance
    var player = try DumpPlayer.init(gpa, sid);
    defer player.deinit();
    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");
```
Setup and initialize SDL with an audio-callback to the `DumpPlayer`
```zig
    // -- init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = &DumpPlayer.sdlAudioCallback,
        .userdata = @ptrCast(&player), // reference to player
    };

    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[EXE] failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_Quit();

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[EXE] failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    SDL.SDL_PauseAudioDevice(dev, 0); // Start SDL audio
    try stdout.print("[EXE] sdl audio started at {d} Hz.\n", .{sid.getSamplingRate()});
    // -- end of SDL initialization
```
Start playback
```zig
    player.play();
```
Dummy code to display the main thread is not blocked
```zig
    // do something in main: print the Sid registers, and player stats
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[EXE] sid registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});

        try stdout.print("[EXE] {d} buffers played, {d} buffer underruns, {d} Sid frames\n", .{
            player.getPlayerContext().stat_bufwrites,
            player.getPlayerContext().stat_buf_underruns,
            player.getPlayerContext().stat_framectr,
        });

        std.time.sleep(0.5 * std.time.ns_per_s);
    }
```
Stop playback
```zig
    try stdout.print("[EXE] press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[EXE] sdl audio stopped.\n", .{});
}
```

<br>

### Threaded SID Dump Player (`sid-dump-player-threaded.zig`)

This example demonstrates a more advanced approach to playing a SID dump. It performs the audio buffer calculation in a **dedicated thread**.
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

#### For Realtime audio visualization and modification

Running `update()` in a separate thread enables the possibility to access, and modify audio during playback.  
The active audio buffer can be accessed via:  
```zig
player.getPlayerContext().buf_ptr_playing : []i16
```

The playback mechanism uses a double-buffering strategy:  
- While SDL plays `player.getPlayerContext().buf_ptr_playing`,  
- `player.getPlayerContext().buf_ptr_next` is prepared by `update()`. By modifying this buffer you can control the audio!    
Once the playback buffer is fully consumed, the buffers are swapped internally to maintain seamless playback.

`Code:` main parts, differences to the example above
```zig
const ReSid = @import("resid");
```
```zig
const Sid = ReSid.Sid;
const DumpPlayer = ReSid.DumpPlayer;
const Playstate = DumpPlayer.Playstate;
```
```zig
fn playerThreadFunc(player: *DumpPlayer) !void {
    while (player.isPlaying()) {
        if (!player.update()) {
            player.stop();
        }
        std.time.sleep(35 * std.time.ns_per_ms);
    }
}
```
```zig
    // create a ReSid instance and configure it
    var sid = try Sid.init("zigsid#1");
    defer sid.deinit();

    // create a DumpPlayer instance and initialize it with the ReSid instance
    var player = try DumpPlayer.init(gpa, sid);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");
```
```zig
    player.updateExternal(true); // make sure, SDL does not call the update function
```
```zig
    // -- init sdl with a callback to our player
    // ...
    // -- end of SDL initialization
```
```zig
    // start the playback, and thread for calling the update function
    player.play();
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join(); // Wait for the thread to finish (if needed)
```
```zig
    // do something in main: print the Sid registers, and player stats
    // ...
```
```zig
    player.stop();
    // ...
}
```

<br>

## **Documentation**
### Introduction
#### Structure of the reSID Zig Integration

This project bridges the gap between C++, C, and Zig:

1. **reSID C++ Library**: Handles low-level SID emulation.
2. **Simplified C++ Framework**: A custom wrapper that manages timing, buffer generation, and playback logic, so you don’t have to.
3. **C Bindings**: Exposes the simpliefied framework through a clean C interface.
4. **Zig Wrapper**: A clear and explicit Zig interface built with structs and associated functions, wrapping C bindings for seamless SID playback and control. 

#### **Audio and SID Chip Details**

- **Stereo Audio Output**: The generated audio fills a **mono buffer**, providing the **16bit** signed SID mono signal at equal levels on both channels.
- **Sampling Rate**: Set to **44.1kHz** by default. The sampling rate is **changeable at runtime** via the provided API.
- **SID Chip Model Selection**: both models are available:
  - **SID6581**: Classic SID sound with characteristic filter behavior, more bassy sound.
  - **SID8580**: Enhanced model with improved signal-to-noise ratio (**default**).
- **Emulation Quality**: The emulation quality is set to the highest possible level supported by the reSID library: `SAMPLE_RESAMPLE_INTERPOLATE`.

<br>

### Working with zigreSID
#### About the **DumpPlayer**  
**`DumpPlayer`**  is the most efficient method for playing back complete SID tunes or sound effects. It provides a simple way to handle SID sound playback (see example code). Internally, it manages audio buffer generation and SID register updates, continuously reading and processing register values from a dump file in steps triggered by the audio-callback.  

##### Realtime Audio Buffer Generation  

###### DumpPlayers Frame-Based SID Register Processing  
- **SID dumps** contain SID register values representing audio frames.
- The player receives a dump via the `setDmp()` function
- For each virtual PAL frame (50.125 Hz, synchronized to a virtual vertical sync), the **player** reads a set of **25 SID register values** from the dump.  
- These registers are bulk-written to the reSID engine using `writeRegs()`.  
- The **`fillAudioBuffer()`** function clocks the reSID engine internally, generating audio samples that form the audio buffer.  

###### Audio Buffer Structure and Playback  
- The generated audio is stored in double buffers:  
  - `buf_ptr_playing`: Currently being played by the audio backend (e.g., SDL2).  
  - `buf_ptr_next`: Prepared by the player for future playback.  
- Once the audio backend finishes playing `buf_ptr_playing`, the buffers are swapped internally to ensure gapless playback.  

##### Buffer Generation Approaches  
###### Default Mode (SDL Audio Callback Driven)  
- The audio buffer** is updated automatically within the **SDL audio thread**.  
- The **SDL audio callback** invokes the player's internal audio generation methods, ensuring continuous playback without manual intervention.  
- Suitable for **simpler use cases** where real-time audio control is not required.
- No extra code is required. All required for audio playback is to call `player.play()`

###### Threaded Mode (Manual Audio Buffer Updates)  
- The user gains full control over buffer updates by calling:  
  ```zig
  player.updateExternal(true);
  ```  
- In this mode, the audio backend (SDL2) plays audio from the buffer but **does not trigger buffer generation**.
- This approach allows for:  
  - **Real-time audio visualization**  
  - **Live audio manipulation**  
  - **Performance optimization** via **multithreading**  
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
    fn playerThreadFunc(player: *DumpPlayer) !void {
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

##### Playback State and Audio Buffer Access  

###### Playback Control Functions  
- `player.play()`: Start playback from the beginning.  
- `player.stop()`: Stop playback and reset internal buffers.  
- `player.pause()`: Pause audio generation.  
- `player.continuePlayback()`: Resume playback after pause.  

###### Audio Buffers Access  
- Access **audio data buffers** for **real-time manipulation**:  
  ```zig
  const nextBuffer = ([]i16) player.getPlayerContext().buf_ptr_next;
  const playingBuffer = ([]i16) player.getPlayerContext().buf_ptr_playing;
  ```  
- Modify the buffer at `buf_ptr_next` during playback for **dynamic audio effects** or **custom processing**.  

##### SID Register Access  

- The player reads **SID register values** per frame and writes them to the **reSID** engine using:
  ```zig
  sid.writeRegs(registers[0..]);
  ```  
- For **register inspection** (e.g., visualizations), the current **SID state** can be queried:
  ```zig
  const regs = sid.getRegs(); // Returns [25]u8 array
  ```  

<br>

## **API Reference**

... switched to zig doc, will be linked soon ...

<br>

## License

This project uses the **reSID** library and follows its licensing terms. The Zig, C++, and C bindings code is provided under the **MIT License**.

<br>

## Credits
Developed with ❤️ by **M64**. Credits to the amazing `resid` library and its authors!  
