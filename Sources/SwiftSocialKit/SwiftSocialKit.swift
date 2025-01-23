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
            } else {
                if content.dynamicBackground {
                    let (topColor, bottomColor) = getDominantColors(from: content.view.snapshot())
                    pasteboardItems["com.instagram.sharedSticker.backgroundTopColor"] =  topColor
                    pasteboardItems[ "com.instagram.sharedSticker.backgroundBottomColor"] = bottomColor
                }
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
    
    func getDominantColors(from image: UIImage) -> (String, String) {
        let colors = image.dominantColors(count: 2) ?? [.black, .black]
        let topColor = colors[0].toHexString()
        let bottomColor = colors[1].toHexString()
        return (topColor, bottomColor)
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



extension UIImage {
    func dominantColors(count: Int) -> [UIColor]? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        
        let extent = inputImage.extent
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: inputImage,
            kCIInputExtentKey: CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        ])
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let averageColor = UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
        
        // Adjust the brightness and saturation to make the colors darker
        let darkenedColor1 = adjustBrightnessAndSaturation(color: averageColor, brightness: 0.1, saturation: 0.8)
        let darkenedColor2 = adjustBrightnessAndSaturation(color: averageColor, brightness: 0.2, saturation: 0.6)
        
        return [darkenedColor1, darkenedColor2]
    }
    
    private func adjustBrightnessAndSaturation(color: UIColor, brightness: CGFloat, saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturationValue: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturationValue, brightness: &brightnessValue, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}
