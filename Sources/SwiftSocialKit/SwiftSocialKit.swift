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
    public var image: UIImage
    public var imageFrame: CGSize?
    public var background: Any?
    
    public init(image: UIImage, frame: CGSize? = nil, background: Any? = nil) {
        self.image = image
        self.imageFrame = frame
        self.background = background
    }
    
    public init(view: UIView, frame: CGSize? = nil, background: Any? = nil) {
        self.image = view.snapshot(frameSize: frame)
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
            let framedImage = applyFrameToImage(image: content.image, frameSize: frame)
            imageData = framedImage.pngData()
        } else {
            imageData = content.image.pngData()
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
func convertBackgroundToData(background: Any) -> Data? {
    if let backgroundImage = background as? UIImage {
        return backgroundImage.pngData() // Or .jpegData(compressionQuality: 1.0)
    } else if let backgroundView = background as? UIView {
        let snapshotImage = backgroundView.snapshot()
        return snapshotImage.pngData() // Or .jpegData(compressionQuality: 1.0)
    }
    return nil
}

@MainActor
func applyFrameToImage(image: UIImage, frameSize: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(frameSize, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    
    let context = UIGraphicsGetCurrentContext()
    context?.setStrokeColor(UIColor.black.cgColor)
    context?.setLineWidth(5)
    
    // Draw the image inside the frame
    image.draw(in: CGRect(origin: .zero, size: frameSize))
    
    // Draw the frame
    context?.stroke(CGRect(origin: .zero, size: frameSize))
    
    return UIGraphicsGetImageFromCurrentImageContext() ?? image
}




extension UIView {
    func snapshot(frameSize: CGSize? = nil) -> UIImage {
        let targetSize: CGSize
        
        if let frameSize = frameSize {
            targetSize = frameSize
            self.frame = CGRect(origin: .zero, size: targetSize)
        } else {
            // Important: Ensure we have a non-zero size for the view
            let size = self.frame.size
            guard size.width > 0, size.height > 0 else {
                // If view has no size, use a default reasonable size
                targetSize = CGSize(width: 300, height: 300)
                self.frame = CGRect(origin: .zero, size: targetSize)
                return self.snapshot(frameSize: targetSize)
            }
            
            // Use view's intrinsic size as the base
            targetSize = size
        }
        
        self.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            self.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
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
