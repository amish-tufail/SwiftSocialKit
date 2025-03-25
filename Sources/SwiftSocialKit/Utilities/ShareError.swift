//
//  ShareError.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 21/03/2025.
//

import Foundation

public enum ShareError: Error {
    case missingAppID
    case cannotOpenApp
    case imageProcessingFailed
    case videoProcessingFailed
    case backgroundProcessingFailed
    case invalidContentForPlatform
    case unsupportedFeature

    public var localizedDescription: String {
        switch self {
        case .missingAppID:
            return "App ID is not configured properly."
        case .cannotOpenApp:
            return "The target app is not installed or its URL scheme is invalid."
        case .imageProcessingFailed:
            return "Failed to process the image for sharing."
        case .videoProcessingFailed:
            return "Failed to process the video for sharing."
        case .backgroundProcessingFailed:
            return "Failed to process the background."
        case .invalidContentForPlatform:
            return "The selected content type is not supported on this platform."
        case .unsupportedFeature:
            return "This feature is not available on the selected platform."
        }
    }
}
