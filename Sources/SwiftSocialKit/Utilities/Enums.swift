//
//  File.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 21/03/2025.
//

import Foundation

@MainActor
public enum InstagramShareDestination {
    case stories
    case reels
    
    func createURL(appID: String) throws -> URL {
        let urlSchemeString: String
        switch self {
        case .stories:
            urlSchemeString = "\(Constants.InstagramURLs.urlStoryScheme)\(appID)"
        case .reels:
            urlSchemeString = "\(Constants.InstagramURLs.urlReelScheme)\(appID)"
        }
        
        guard let url = URL(string: urlSchemeString) else {
            throw ShareError.cannotOpenInstagram
        }
        return url
    }
    
    func validateContent(_ content: ShareContent) throws {
        switch self {
        case .stories:
            break
        case .reels:
            if content.videoBackground == nil {
                throw ShareError.invalidContentForReels
            }
            if content.background != nil || content.dynamicBackground {
                throw ShareError.invalidContentForReels
            }
        }
    }
}
