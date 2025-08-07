//
//  File.swift
//  
//
//  Created by Sahib Hussain on 22/09/23.
//

import Foundation

public extension Bundle {
    
    public var releaseVersionNumber: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown App Version"
    }
    
    public var buildVersionNumber: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown Bundle Version"
    }
    
}
