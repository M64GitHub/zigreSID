# Zig SID Soundchip Emulation 🎵✨

This project provides **SID soundchip emulation** for **Zig**, enabling you to generate and play SID audio with ease. It is built upon the powerful **ReSID** C++ library, delivering authentic SID sound emulation combined with the simplicity and safety of Zig.

## 🚀 Features

- 🎹 **SID Soundchip Emulation for Zig**: Experience the legendary SID sound directly in your Zig projects.
- ⚡ **Powered by ReSID**: Leverages the proven **reSID** C++ library (https://github.com/daglem/reSID) for high-quality sound emulation.
- 🔧 **Simplified C++ Framework**: All complex timing calculations and internal audio buffer management are handled automatically, allowing you to focus solely on the high-level API.
- 🔗 **C Bindings for Zig**: Provides clean **C bindings** to the simplified C++ framework, making **SID sound playback** in Zig straightforward and seamless.

## 💡 How It Works

This project bridges the gap between C++, C, and Zig:

1. **ReSID C++ Library**: Handles low-level SID emulation.
2. **Simplified C++ Framework**: A custom wrapper that manages timing, buffer generation, and playback logic, so you don’t have to.
3. **C Bindings**: Exposes key C++ functionalities through a clean C interface.
4. **Zig Wrapper**: Object-oriented style Zig code that wraps the C bindings, providing an intuitive API for playback and control.

## 🎼 Example Usage

```zig
const std = @import("std");
const ReSID = @import("ReSID.zig").ReSID;
const ReSIDDmpPlayer = @import("ReSIDDmpPlayer.zig").ReSIDDmpPlayer;

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
    while (true) {
        player.update();
        // Add playback logic or break conditions if needed
    }
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
