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
const ReSID = @import("reSID.zig").ReSID;
const ReSIDDmpPlayer = @import("reSID.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    sid.setDBGOutput(true);
    _ = sid.setChipModel("MOS6581");

    try stdout.print("SID instance name: {s}\\n", .{sid.getName()});

    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();

    player.play();
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
./zig-out/bin/zig_sid_demo
```

## 🎧 License

This project uses the **reSID** library and follows its licensing terms. The Zig and C bindings code is provided under the **MIT License**.

---

✨ *SID sound made simple. Powered by reSID. Integrated with Zig.* ✨
