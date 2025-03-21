//
//  SwiftSocialKit.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 22/01/2025.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
public class SwiftSocialKit {
    public func configureMeta(appID: String) {
        GlobalConfig.shared.setMetaAppID(appID)
    }
    
    public init() {}
    
    public func shareToInstagram(destination: InstagramShareDestination, storyContent: ShareContent, completion: @escaping (Bool) -> ()) {
        InstagramShare(content: storyContent).share(destination: destination) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
}












