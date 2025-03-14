//
//  File.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 12/03/2025.
//

import SwiftUI

extension UIImage {
    public func resizeWithAspectRatio(to targetSize: CGSize) -> UIImage? {
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
    
    public func resized(to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func getDominantColors() -> (String, String) {
        let colors = self.dominantColors(count: 2) ?? [.black, .black]
        let topColor = colors[0].toHexString()
        let bottomColor = colors[1].toHexString()
        return (topColor, bottomColor)
    }
    
    public func dominantColors(count: Int) -> [UIColor]? {
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
