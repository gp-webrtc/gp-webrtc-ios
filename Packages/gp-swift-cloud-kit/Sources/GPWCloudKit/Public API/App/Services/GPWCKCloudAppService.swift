//
// gp-webrtc-ios/swift-cloud-kit
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

#if canImport(FirebaseAppCheck)
import FirebaseAppCheck
#endif
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
import FirebaseCore
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
#if canImport(FirebaseFunctions)
import FirebaseFunctions
#endif
#if canImport(FirebaseStorage)
import FirebaseStorage
#endif
import Foundation
import os.log

public class GPWCKCloudAppService {
    public static var shared: GPWCKCloudAppService {
        GPWCKCloudAppService.instance
    }

    private static let instance = GPWCKCloudAppService()

    private var _configuration: GPWCKConfiguration?
    public var configuration: GPWCKConfiguration { _configuration! }

    #if canImport(FirebaseAppCheck)
    class GPWCKAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
        func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
            AppAttestProvider(app: app)
        }
    }
    #endif

    public enum GPWCKConfiguration: String {
        case local
        case release
    }

    private init() {}

    public func configure(withConfiguration configuration: GPWCKConfiguration, usingEmulatorConfig emulatorConfig: GPWCKEmulatorConfig? = nil) {
        guard _configuration == nil else {
            Logger().error("[GPWCKCloudAppService] GPWCloudKit has already been configured")
            return
        }

        // Only local configuration can be used if using emulator
        #if targetEnvironment(simulator)
        _configuration = .local
        #else
        _configuration = configuration
        #endif

        // User AppCheck debug when configuration is .local or when running via emulators
        #if canImport(FirebaseAppCheck)
        if _configuration == .local {
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        } else {
            let providerFactory = GPWCKAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        }
        #endif

        // Configure Firebase
        FirebaseApp.configure()

        // Configure Emulators, if required
        if let emulatorConfig {
            // Auth emulator
            #if canImport(FirebaseAuth)
            if let authEmulator = emulatorConfig.authEmulator {
                Logger().info("[GPWCKCloudAppService] GPWCloudKit will connect to Auth emulator on \(authEmulator.hostname):\(authEmulator.port ?? 9099)")
                Auth.auth().useEmulator(withHost: authEmulator.hostname, port: authEmulator.port ?? 9099)
            }
            #endif

            #if canImport(FirebaseFirestore)
            // Firestore Emulator
            if let firestoreEmulator = emulatorConfig.firestoreEmulator {
                Logger().info("[GPWCKCloudAppService] GPWCloudKit will connect to Firestore emulator on \(firestoreEmulator.hostname):\(firestoreEmulator.port ?? 8080)")
                let settings = Firestore.firestore().settings
                settings.host = "\(firestoreEmulator.hostname):\(firestoreEmulator.port ?? 8080)"
                settings.cacheSettings = MemoryCacheSettings()
                settings.isSSLEnabled = false
                Firestore.firestore().settings = settings
            }
            #endif

            #if canImport(FirebaseFunctions)
            // Functions emulator
            if let functionsEmulator = emulatorConfig.functionsEmulator {
                Logger().info("[GPWCKCloudAppService] GPWCloudKit will connect to Function emulator on \(functionsEmulator.hostname):\(functionsEmulator.port ?? 5001)")
                Functions.functions(region: functionsEmulator.region).useEmulator(withHost: functionsEmulator.hostname, port: functionsEmulator.port ?? 5001)
            }
            #endif

            #if canImport(FirebaseStorage)
            // Storage emulator
            if let storageEmulator = emulatorConfig.storageEmulator {
                Logger().info("[GPWCKCloudAppService] GPWCloudKit will connectto Storage emulator on \(storageEmulator.hostname):\(storageEmulator.port ?? 5001)")
                Storage.storage().useEmulator(withHost: storageEmulator.hostname, port: storageEmulator.port ?? 9199)
            }
            #endif
        }
    }
}
