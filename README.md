# Dump1090 Mac Server

A macOS app dump1090 BEAST server.

Based on https://github.com/MalcolmRobb/dump1090 but wrapped in a GUI with a big start / stop button. Sandboxed to only have network server and usb access.

## Usage

Open the Mac App, plug in a USB dongle and click start.

No dependencies to install, no drivers. Just plug in any rtl-sdr compatible device and you are good to go. It starts a bonjour service for quick discovery in apps.

## License

This software contains an executable copy of dump1090-mac which statically links libusb, rtl-sdr and is heavily based off dump1090.
Licenses are included inside the Licenses/ directory.
It is up to you and your lawyers to determine what they mean.

libusb version 1.0.22_0 built from commit 270bef4002e3a34e234bda12915c1da2b1e9af88 is included, the source code to this may be downloaded from https://github.com/libusb/libusb. rtl-sdr was built from commit f68bb2fa772ad94f58c59babd78353667570630b which may be downloaded from https://github.com/osmocom/rtl-sdr.
