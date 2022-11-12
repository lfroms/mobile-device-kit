<h1 align="center">
  &#128241;
  <br>
  MobileDeviceKit 
  <br>
</h1>

<h4 align="center">A convenient Swift API for interacting with mobile devices on macOS.</h4>

<p align="center">
  <a href="https://github.com/lfroms/mobile-device-kit/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/lfroms/mobile-device-kit"></a>
  <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/lfroms/mobile-device-kit">
  <a href="https://github.com/lfroms/mobile-device-kit/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/lfroms/mobile-device-kit"></a>
  <a href="https://github.com/lfroms/mobile-device-kit"><img alt="GitHub license" src="https://img.shields.io/github/license/lfroms/mobile-device-kit"></a>
  <img alt="Contributions welcome" src="https://img.shields.io/badge/contributions-welcome-orange">
</p>

## About

MobileDeviceKit aims to make it easy to discover and interact with mobile devices attached to the system in a Swift application. Internally, MobileDeviceKit interops with Apple's private `MobileDevice.framework` which is used internally by other Apple programs such as Xcode, Finder, and Apple Configurator.

MobileDeviceKit is incomplete and is a **work-in-progress**.

## Goals

- Asynchronous APIs by default using modern tools (such as Async Swift and Combine).
- Full abstraction for any private APIs used internally.
- Support for interacting with wirelessly-connected devices.
- Support for launching applications with `lldb`.

## Why shouldn't I use this?

- You are building a mission-critical app and can't justify debugging issues with private APIs as they change.
- You need to bundle this package in a universal binary. MobileDeviceKit links against your system's frameworks, which may not be universal.
- There are probably other more actively maintained projects available (see below).

## Why should I use this?

- You are building a macOS app in Swift and want to be able to easily interact with mobile devices.
- Your app is non-critical and you've accepted any risks with using private system APIs.
- You don't want to deal with managing reverse-engineered headers or interacting with `MobileDevice`'s cumbersome C APIs directly.

## Can I contribute?

**Yes, please!** If you have a need for this kind of package, please extend it to suit your needs. All and any contributions are welcome.

The symbol table for `MobileDevice.framework` can be dumped by running:

```bash
nm /Library/Apple/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/Current/MobileDevice
```

If you prefer to reimplement parts of `MobileDevice.framework` instead without using the private framework, suggestions are welcome.

## Alternatives

- [Apple Configurator](https://support.apple.com/en-ca/apple-configurator)
   - Apple Configurator is a **first party** application that provides a public, documented command line tool: `cfgutil`.
   - You'll probably want to use this for most things. However, it does not support wirelessly connected devices or debugging.
   
### Open source
- [ios-deploy](https://github.com/ios-control/ios-deploy) — Popular command line utility with support for launching installed apps.
- [mobile-run](https://github.com/ionic-team/native-run) — Utility for communicating with iOS devices written in TypeScript.
- [libimobiledevice](https://github.com/libimobiledevice) — Open source library written in C for communicating with iOS devices.
- [mobiledevice](https://github.com/imkira/mobiledevice) — Command line utility.
- [SDMMobileDevice](https://github.com/samdmarshall/SDMMobileDevice) — Drop-in open source replacement for `MobileDevice.framework`.
- [mobdevim](https://github.com/DerekSelander/mobdevim) — Command line utility.

## License

MobileDeviceKit is released under the [GPL-3.0 License](LICENSE) unless otherwise noted.
