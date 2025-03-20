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
    
    @MainActor public func shareToInstagramStories(storyContent: ShareContent, completion: @escaping (Bool) -> ()) {
//        InstagramShare(content: storyContent).shareToStories { success in
//            completion(success)
//        }
        InstagramShare(content: storyContent).shareToStories { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}












