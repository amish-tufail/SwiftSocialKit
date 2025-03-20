//
//  ShareError.swift
//  SwiftSocialKit
//
//  Created by Amish Tufail on 21/03/2025.
//

import Foundation

public enum ShareError: Error {
     case missingAppID
     case cannotOpenInstagram
     case imageProcessingFailed
     case videoProcessingFailed
     case backgroundProcessingFailed
     
     public var localizedDescription: String {
         switch self {
         case .missingAppID:
             return "Meta App ID is not configured properly"
         case .cannotOpenInstagram:
             return "Instagram app is not installed or URL scheme is invalid"
         case .imageProcessingFailed:
             return "Failed to process the image for sharing"
         case .videoProcessingFailed:
             return "Failed to process the video background"
         case .backgroundProcessingFailed:
             return "Failed to process the background"
         }
     }
 }
