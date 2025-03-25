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
            throw ShareError.cannotOpenApp
        }
        return url
    }
    
    func validateContent(_ content: ShareContent) throws {
        switch self {
        case .stories:
            break
        case .reels:
            if content.videoBackground == nil {
                throw ShareError.invalidContentForPlatform
            }
            if content.background != nil || content.dynamicBackground {
                throw ShareError.invalidContentForPlatform
            }
        }
    }
}

@MainActor
public enum FacebookShareDestination {
    case stories
    case reels
    
    func createURL(appID: String) throws -> URL {
        let urlSchemeString: String
        switch self {
        case .stories:
            urlSchemeString = "\(Constants.FacebookURLs.urlStoryScheme)\(appID)"
        case .reels:
            urlSchemeString = "\(Constants.FacebookURLs.urlReelScheme)\(appID)"
        }
        
        guard let url = URL(string: urlSchemeString) else {
            throw ShareError.cannotOpenApp
        }
        
        return url
    }
    
    func validateContent(_ content: ShareContent) throws {
        switch self {
        case .stories:
            break
        case .reels:
            if content.videoBackground == nil {
                throw ShareError.invalidContentForPlatform
            }
            if content.background != nil || content.dynamicBackground {
                throw ShareError.invalidContentForPlatform
            }
        }
    }
}
