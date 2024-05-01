//
//  File.swift
//  
//
//  Created by Sahib Hussain on 22/09/23.
//

import Foundation

internal extension Bundle {
    
    var releaseVersionNumber: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown App Version"
    }
    
    var buildVersionNumber: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown Bundle Version"
    }
    
}
