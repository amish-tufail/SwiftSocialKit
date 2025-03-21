//
//  InstagramShare.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 12/03/2025.
//

import SwiftUI

@MainActor
 public class InstagramShare {
     private let content: ShareContent
     
     public init(content: ShareContent) {
         self.content = content
     }
     
     @MainActor
     public func shareToStories(completion: @escaping (Result<Void, ShareError>) -> Void) {
         do {
             guard let appID = GlobalConfig.getMetaAppID() else {
                 throw ShareError.missingAppID
             }
             
             let urlScheme = try createInstagramStoryURL(appID: appID)
             
             guard UIApplication.shared.canOpenURL(urlScheme) else {
                 throw ShareError.cannotOpenInstagram
             }
             
             guard let imageData = try prepareImageData() else {
                 throw ShareError.imageProcessingFailed
             }
             
             var pasteboardItems: [String: Any] = [
                 Constants.InstaFBCommonURls.stickerURL: imageData,
                 Constants.InstaFBCommonURls.appIdURL : appID
             ]
             
             if let backgroundItems = try? prepareBackgroundItems() {
                 pasteboardItems.merge(backgroundItems) { (_, new) in new }
             }
             
             shareToInstagram(urlScheme: urlScheme, items: pasteboardItems)
             completion(.success(()))
         } catch let error as ShareError {
             completion(.failure(error))
         } catch {
             completion(.failure(.cannotOpenInstagram))
         }
     }
     
     @MainActor
     public func shareToReels(completion: @escaping (Result<Void, ShareError>) -> Void) {
         do {
             guard let appID = GlobalConfig.getMetaAppID() else {
                 throw ShareError.missingAppID
             }
             
             let urlScheme = try createInstagramReelsURL(appID: appID)
             
             guard UIApplication.shared.canOpenURL(urlScheme) else {
                 throw ShareError.cannotOpenInstagram
             }
             
             guard let imageData = try prepareImageData() else {
                 throw ShareError.imageProcessingFailed
             }
             
             var pasteboardItems: [String: Any] = [
                 Constants.InstaFBCommonURls.stickerURL: imageData,
                 Constants.InstaFBCommonURls.appIdURL : appID
             ]
             
             if let backgroundItems = try? prepareBackgroundItems() {
                 pasteboardItems.merge(backgroundItems) { (_, new) in new }
             }
             
             shareToInstagram(urlScheme: urlScheme, items: pasteboardItems)
             completion(.success(()))
         } catch let error as ShareError {
             completion(.failure(error))
         } catch {
             completion(.failure(.cannotOpenInstagram))
         }
     }
     
     // MARK: - Private Helper Methods
     
     private func createInstagramStoryURL(appID: String) throws -> URL {
         guard let url = URL(string: "\(Constants.InstagramURLs.urlStoryScheme)\(appID)") else {
             throw ShareError.cannotOpenInstagram
         }
         return url
     }
     
     private func createInstagramReelsURL(appID: String) throws -> URL {
         guard let url = URL(string: "\(Constants.InstagramURLs.urlReelScheme)\(appID)") else {
             throw ShareError.cannotOpenInstagram
         }
         return url
     }
     
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
             return [Constants.InstaFBCommonURls.backroundImageURL: backgroundData]
         }
         else if content.dynamicBackground {
             let (topColor, bottomColor) = content.view.snapshot().getDominantColors()
             return [
                 Constants.InstaFBCommonURls.backroundTopColorURL: topColor,
                 Constants.InstaFBCommonURls.backgroundBottomColorURL: bottomColor
             ]
         }
         else if let videoURL = content.videoBackground {
             do {
                 let videoData = try Data(contentsOf: videoURL)
                 return [Constants.InstaFBCommonURls.backgroundVideoURL: videoData]
             } catch {
                 throw ShareError.videoProcessingFailed
             }
         }
         
         return nil
     }
     
     private func shareToInstagram(urlScheme: URL, items: [String: Any]) {
         let pasteboardOptions = [
             UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
         ]
         
         UIPasteboard.general.setItems([items], options: pasteboardOptions)
         UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
     }
 }

//class InstagramShare {
//    private var content: ShareContent
//    
//    init(content: ShareContent) { self.content = content }
//    
//    @MainActor func shareToStories(completion: @escaping (Bool) -> ()) {
//        guard let appID = GlobalConfig.getMetaAppID() else {
//            completion(false)
//            return
//        }
//        
//        let urlScheme = URL(string: "\(Constants.InstagramURLs.urlStoryScheme)\(appID)")!
//        
//        var imageData: Data?
//        var backgroundData: Data?
//        
//        if let frame = content.imageFrame {
//            if content.view is Text {
//                imageData = content.view.frame(width: frame.width, height: frame.height).snapshot().pngData()
//            } else {
//                imageData = content.view.snapshot().resizeWithAspectRatio(to: frame)?.pngData()
//            }
//        } else {
//            imageData = content.view.snapshot().pngData()
//        }
//      
//        if let background = content.background {
//            backgroundData = background.convertBackgroundToData()
//        }
//        
//        if UIApplication.shared.canOpenURL(urlScheme), let imageData = imageData {
//            var pasteboardItems: [String: Any] = [
//                Constants.InstaFBCommonURls.stickerURL: imageData
//            ]
//            
//            if let backgroundData = backgroundData {
//                pasteboardItems[Constants.InstaFBCommonURls.backroundImageURL] = backgroundData
//            } else {
//                if content.dynamicBackground {
//                    let (topColor, bottomColor) = content.view.snapshot().getDominantColors()
//                    pasteboardItems[Constants.InstaFBCommonURls.backroundTopColorURL] =  topColor
//                    pasteboardItems[ Constants.InstaFBCommonURls.backgroundBottomColorURL] = bottomColor
//                } else if content.videoBackground != nil {
//                    guard let video = content.videoBackground else { return }
//                    guard let backgroundVideoData = try? Data(contentsOf: video) else {
//                        print("Failed to load merged video.")
//                        return
//                    }
//                    
//                    pasteboardItems[Constants.InstaFBCommonURls.backgroundVideoURL] = backgroundVideoData
//                }
//            }
//            
//            let pasteboardOptions = [
//                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
//            ]
//            
//            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
//            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
//            completion(true)
//        } else {
//            completion(false)
//        }
//    }
//}



 


 
