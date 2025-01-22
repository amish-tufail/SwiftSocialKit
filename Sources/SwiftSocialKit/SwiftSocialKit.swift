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
    
    public init(view: any View, frame: CGSize? = nil, background: (any View)? = nil) {
        self.view = view
        self.imageFrame = frame
        self.background = background
    }
}



class InstagramShare {
    
    private var content: ShareContent
    
    init(content: ShareContent) {
        self.content = content
    }
    
    @MainActor func shareToStories(completion: @escaping (Bool) -> ()) {
        guard let appID = GlobalConfig.getMetaAppID() else {
            completion(false)
            return
        }
        
        let urlScheme = URL(string:"instagram-stories://share?source_application=\(appID)")!
        
        var imageData: Data?
        var backgroundData: Data?
        
        if let frame = content.imageFrame {
            if content.view is Text {
                imageData = content.view.frame(width: frame.width, height: frame.height).snapshot().pngData()
            } else {
                imageData = content.view.snapshot().resizeWithAspectRatio(to: frame)?.pngData()
            }
        } else {
            imageData = content.view.snapshot().pngData()
        }
      
        if let background = content.background {
            backgroundData = convertBackgroundToData(background: background)
        }
        
        if UIApplication.shared.canOpenURL(urlScheme), let imageData = imageData {
            var pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.stickerImage": imageData
            ]
            
            // Add background data if available
            if let backgroundData = backgroundData {
                pasteboardItems["com.instagram.sharedSticker.backgroundImage"] = backgroundData
            }
            
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
            completion(true)
        } else {
            completion(false)
        }
    }
}

@MainActor
func convertBackgroundToData(background: any View) -> Data? {
    return background.snapshot().pngData()
}

extension View {
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension UIImage {
    func resizeWithAspectRatio(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        return resized(to: newSize)
    }
    
    func resized(to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
