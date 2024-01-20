//
//  swift-cloud-kit-oskey-dev
// Copyright (c) OSKEY SAS. All rights reserved.
//
//  The source code is protected under international copyright law.  All rights
//  reserved and protected by the copyright holders.
//
//  The source code is confidential and only available to authorized individuals
//  with the permission of the copyright holders.  If you encounter this this source
//  code and do not have permission, please contact the copyright holders and delete
//  this file.
//

import Foundation

public struct GPWCKEmulatorConfig {
    public let authEmulator: GPWCKEmulator?
    public let firestoreEmulator: GPWCKEmulator?
    public let functionsEmulator: GPWCKFunctionsEmulator?
    public let storageEmulator: GPWCKEmulator?

    public init(authEmulator: GPWCKEmulator?, firestoreEmulator: GPWCKEmulator?, functionsEmulator: GPWCKFunctionsEmulator?, storageEmulator: GPWCKEmulator?) {
        self.authEmulator = authEmulator
        self.firestoreEmulator = firestoreEmulator
        self.functionsEmulator = functionsEmulator
        self.storageEmulator = storageEmulator
    }
}
