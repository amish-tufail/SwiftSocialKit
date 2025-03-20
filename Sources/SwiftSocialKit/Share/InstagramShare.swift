//
//  InstagramShare.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 12/03/2025.
//

import SwiftUI

class InstagramShare {
    private var content: ShareContent
    
    init(content: ShareContent) { self.content = content }
    
    @MainActor func shareToStories(completion: @escaping (Bool) -> ()) {
        guard let appID = GlobalConfig.getMetaAppID() else {
            completion(false)
            return
        }
        
        let urlScheme = URL(string: "\(Constants.InstagramURLs.urlStoryScheme)(appID)")!
        
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
            backgroundData = background.convertBackgroundToData()
        }
        
        if UIApplication.shared.canOpenURL(urlScheme), let imageData = imageData {
            var pasteboardItems: [String: Any] = [
                Constants.InstaFBCommonURls.stickerURL: imageData
            ]
            
            if let backgroundData = backgroundData {
                pasteboardItems[Constants.InstaFBCommonURls.backroundImageURL] = backgroundData
            } else {
                if content.dynamicBackground {
                    let (topColor, bottomColor) = content.view.snapshot().getDominantColors()
                    pasteboardItems[Constants.InstaFBCommonURls.backroundTopColorURL] =  topColor
                    pasteboardItems[ Constants.InstaFBCommonURls.backgroundBottomColorURL] = bottomColor
                } else if content.videoBackground != nil {
                    guard let video = content.videoBackground else { return }
                    guard let backgroundVideoData = try? Data(contentsOf: video) else {
                        print("Failed to load merged video.")
                        return
                    }
                    
                    pasteboardItems[Constants.InstaFBCommonURls.backgroundVideoURL] = backgroundVideoData
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
}
