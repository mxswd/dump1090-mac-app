# Dump1090 Mac Server

A macOS app dump1090 BEAST server.

Based on https://github.com/MalcolmRobb/dump1090 but wrapped in a GUI with a big start / stop button. Sandboxed to only have network server and usb access.

## Usage

Open the Mac App, plug in a USB dongle and click start.

No dependencies to install, no drivers. Just plug in any rtl-sdr compatible device and you are good to go. It starts a bonjour service for quick discovery in apps.

## Building

Open `Dump1090 Mac Server.xcodeproj` and build the `Dump1090 Mac Server` scheme. libusb, rtl-sdr and dump1090 are vendored as source in `Vendor/` and built as static library targets that are linked into the app, so there is nothing else to install. See [Vendor/README.md](Vendor/README.md) for the versions and how to update them.

## License

Copyright (c) 2019 Max Technology Labs PTY LTD

Dump1090 Mac Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version. See [LICENSE](LICENSE).

The app statically links:

- [libusb](https://github.com/libusb/libusb) 1.0.30, GNU LGPL 2.1 or later
- [rtl-sdr](https://github.com/osmocom/rtl-sdr) 2.0.3, GNU GPL 2 or later
- [dump1090](https://github.com/MalcolmRobb/dump1090), BSD 3-Clause, with the changes from [dump1090-mac](https://github.com/mxswd/dump1090-mac) (BSD 2-Clause)

Their license texts are in the `Licenses/` directory and the app's Acknowledgements. The complete corresponding source code for every build of the app, including these libraries, is this repository: https://github.com/mxswd/dump1090-mac-app
