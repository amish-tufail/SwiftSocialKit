//
//  GlobalConfig.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 22/01/2025.
//

import Foundation

@MainActor
internal class GlobalConfig {
    
    static let shared = GlobalConfig()

    private var metaAppID: String?

    private init() {}

    func setMetaAppID(_ appID: String) {
        guard metaAppID == nil else { return }
        metaAppID = appID
    }

    static func getMetaAppID() -> String? {
        return shared.metaAppID
    }
}
