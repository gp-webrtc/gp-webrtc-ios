// swift-tools-version:5.9
//
// gp-webrtc/swift-cloud-kit
// Copyright (c) 2024, Greg PFISTER. MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import PackageDescription

let version = "1.0.0"

let package = Package(
    name: "GPWCloudKit",
    platforms: [.iOS(.v17), .watchOS(.v10), .macCatalyst(.v17)],
    products: [
        .library(
            name: "GPWCloudKit",
            targets: ["GPWCloudKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.20.0")),
    ],
    targets: [
        .target(
            name: "GPWCloudKit",
            dependencies: [
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk", condition: .when(platforms: [.iOS])),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "GPWCloudKitTests",
            dependencies: [
                "GPWCloudKit",
            ]
        ),
    ]
)