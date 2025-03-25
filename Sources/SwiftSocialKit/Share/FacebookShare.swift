//
//  FacebookShare.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 26/03/2025.
//

import SwiftUI

@MainActor
public class FacebookShare {
    private let content: ShareContent
    
    public init(content: ShareContent) {
        self.content = content
    }
    
    @MainActor
    public func share(destination: FacebookShareDestination, completion: @escaping (Result<Void, ShareError>) -> Void) {
        do {
            
            try destination.validateContent(content)
            
            guard let appID = GlobalConfig.getMetaAppID() else {
                throw ShareError.missingAppID
            }
            
            let urlScheme = try destination.createURL(appID: appID)
            
            guard UIApplication.shared.canOpenURL(urlScheme) else {
                throw ShareError.cannotOpenApp
            }
            
            guard let imageData = try prepareImageData() else {
                throw ShareError.imageProcessingFailed
            }
            
            var pasteboardItems: [String: Any] = [
                Constants.FacebookURLs.stickerURL : imageData,
                Constants.FacebookURLs.appIdURL : appID
            ]
            
            if let backgroundItems = try? prepareBackgroundItems() {
                pasteboardItems.merge(backgroundItems) { (_, new) in new }
            }
            
            shareToFacebook(urlScheme: urlScheme, items: pasteboardItems)
            completion(.success(()))
            
        } catch let error as ShareError {
            completion(.failure(error))
        } catch {
            completion(.failure(.cannotOpenApp))
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func prepareImageData() throws -> Data? {
        do {
            if let frame = content.imageFrame {
                if content.view is Text {
                    guard let data = content.view.frame(width: frame.width, height: frame.height).snapshot().pngData() else {
                        throw ShareError.imageProcessingFailed
                    }
                    return data
                } else {
                    guard let resizedImage = content.view.snapshot().resizeWithAspectRatio(to: frame),
                          let data = resizedImage.pngData() else {
                        throw ShareError.imageProcessingFailed
                    }
                    return data
                }
            } else {
                guard let data = content.view.snapshot().pngData() else {
                    throw ShareError.imageProcessingFailed
                }
                return data
            }
        } catch {
            throw ShareError.imageProcessingFailed
        }
    }
    
    private func prepareBackgroundItems() throws -> [String: Any]? {
        if let background = content.background {
            guard let backgroundData = background.convertBackgroundToData() else {
                throw ShareError.backgroundProcessingFailed
            }
            return [Constants.FacebookURLs.backroundImageURL: backgroundData]
        }
        else if content.dynamicBackground {
            let (topColor, bottomColor) = content.view.snapshot().getDominantColors()
            return [
                Constants.FacebookURLs.backroundTopColorURL: topColor,
                Constants.FacebookURLs.backgroundBottomColorURL: bottomColor
            ]
        }
        else if let videoURL = content.videoBackground {
            do {
                let videoData = try Data(contentsOf: videoURL)
                return [Constants.FacebookURLs.backgroundVideoURL: videoData]
            } catch {
                throw ShareError.videoProcessingFailed
            }
        }
        
        return nil
    }
    
    private func shareToFacebook(urlScheme: URL, items: [String: Any]) {
        let pasteboardOptions = [
            UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
        ]
        
        UIPasteboard.general.setItems([items], options: pasteboardOptions)
        UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
    }
}
