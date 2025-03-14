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
        InstagramShare(content: storyContent).shareToStories { success in
            completion(success)
        }
    }
}

@MainActor
public struct ShareContent {
    public var view: any View
    public var imageFrame: CGSize?
    public var background: (any View)?
    public var dynamicBackground: Bool
    
    public init(view: any View, frame: CGSize? = nil, background: (any View)? = nil, dynamicBackground: Bool = false) {
        self.view = view
        self.imageFrame = frame
        self.background = background
        self.dynamicBackground = dynamicBackground
    }
}





@MainActor
func convertBackgroundToData(background: any View) -> Data? {
    return background.snapshot().pngData()
}





