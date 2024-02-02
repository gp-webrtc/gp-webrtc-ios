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

public struct GPWCKFunctionsEmulator: Decodable {
    public let hostname: String
    public let port: Int?
    public let region: String

    public init(hostname: String = "localhost", port: Int? = nil, region: String = "europe-west1") {
        self.hostname = hostname
        self.port = port
        self.region = region
    }
}
