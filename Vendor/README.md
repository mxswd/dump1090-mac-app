# Vendored dependencies

Each directory is built by a static library target in `Dump1090 Mac Server.xcodeproj`, and all three are linked into the app.

| Directory | Target | Upstream | Version | Commit | License |
|---|---|---|---|---|---|
| `libusb/` | `usb-1.0` | https://github.com/libusb/libusb | v1.0.30 | 87a55632db62c9bdc58cd31d3ccfa673f1bb017f | LGPL-2.1-or-later |
| `rtl-sdr/` | `rtlsdr` | https://github.com/osmocom/rtl-sdr | v2.0.3 | 797f8143266d983c56d8f35d2d442527529dd8a5 | GPL-2.0-or-later |
| `dump1090/` | `dump1090` | https://github.com/MalcolmRobb/dump1090 via https://github.com/mxswd/dump1090-mac | upstream HEAD (no releases) | bff92c4ad772a0a8d433f788d39dae97e00e4dbe, fork 3f9a84dccf319d90fc306d4b98f4bf3a0beec3b0 | BSD-3-Clause, fork changes BSD-2-Clause |

## libusb and rtl-sdr

These are unmodified. Only the files needed for the macOS build are copied: the core library, the Darwin and POSIX backends, and libusb's own `Xcode/config.h`. Upstream's tools, tests and other platform backends are left out.

To update, run `Vendor/vendor.sh <libusb-tag> <rtl-sdr-tag>` and then update this table, `Licenses/` and `README.md`. If upstream adds or renames source files, add them to the matching target in Xcode.

## dump1090

This is the dump1090-mac fork, changed so it runs inside the app process instead of as a separate executable:

- `main()` is now `dump1090_main()`, and `dump1090_stop()` is added (see `Dump1090API.h`). It no longer installs signal handlers or calls `sandbox_init()`, because the app has its own sandbox.
- `exit()` calls are replaced with error returns. `modesCleanup()` and `modesCleanupNet()` free all state, close sockets and the device, so it can be started again in the same process. The reader thread is joined before the device and mutexes are torn down.
- The reader thread ends the run if the device stops streaming (for example, if it is unplugged).
- `Dump1090Output.h` is the target's prefix header. It sends stdout/stderr output to a callback that the app shows in its console.
- `extra.c` (license text printed on startup) is removed. The app shows the licenses in its Acknowledgements instead.
