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

## References

### WebRTC

- [Video Chat using WebRTC and Firestore](https://medium.com/@quangtqag/video-chat-using-webrtc-and-firestore-a925de6f89f4)
  by Quang Quoc Tran 

### CallKit & PushKit

- [CallKit Tutorial for iOS](https://www.kodeco.com/1276414-callkit-tutorial-for-ios#toc-anchor-005)
- [Using CallKit: How to Integrate Voice and Video Calling Into iOS Apps](https://getstream.io/blog/integrate-callkit-ios/)
  by Amos Gyamfi
- [Using PushKit Notification: How To Show an Incoming Call on a Device](https://getstream.io/blog/pushkit-for-calls/)
  by Amos Gyamfi
  
### APNS Testing

- [Establishing a token-based connection to APNs](https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns)

## Contributions

Contributions are welcome, please read our 
[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## License

See [LICENSE.md](LICENSE.md).
