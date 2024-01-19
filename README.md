[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

# Greg's WebRTC - iOS App

> Copyright © 2024, Greg PFISTER. MIT License.

## About

This repository is providing an iOS app client for WebRTC, supported by a
[Firebase](https://firebase.google.com) backend (repository 
[here](https://github.com/gp-webrtc/firebase)).

This is not production ready, but a test implementation.

- Step 1 (in development): Support peer-to-peer WebRTC, CallKit and Notifications
- Step 2 (upcomming): Support TURN server

This project relies on a Firebase backend to support client registration.

## Build and run

To build and run using emulators, we recommend using `Xcode` 15.2 or more and an 
iPhone with iOS 17.2 or more.

To get started:

- Change the iOS team and bundle identifier
- Change the watchOS team and bundle identifier
- Download the `GoogleService-Info.plist` file of the Firebase project
  (see this [Firebase project](https://github.com/gp-webrtc/firebase) to get you 
  started). It must be stored in the `iOS/Resources` folder.
- Install `SwiftFormat` by running `brew install swiftformat swiftformat-for-xcode`.

## Contributions

Contributions are welcome, please read our 
[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## License

See [LICENSE.md](LICENSE.md).
