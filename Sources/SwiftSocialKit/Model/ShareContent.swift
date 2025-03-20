//
//  ShareContent.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 21/03/2025.
//

import SwiftUI

@MainActor
public struct ShareContent {
    public var view: any View
    public var imageFrame: CGSize?
    public var background: (any View)?
    public var dynamicBackground: Bool
    public var videoBackground: URL?
    
    public init(view: any View, frame: CGSize? = nil, background: (any View)? = nil, dynamicBackground: Bool = false, videoBackground: URL? = nil) {
        self.view = view
        self.imageFrame = frame
        self.background = background
        self.dynamicBackground = dynamicBackground
        self.videoBackground = videoBackground
    }
}
