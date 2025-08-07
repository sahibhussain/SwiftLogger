//
//  File.swift
//  
//
//  Created by Sahib Hussain on 22/09/23.
//

import Foundation

internal class Profile {
    
    static let shared = Profile()
    private init() {}
    
    private(set) var userID: String = ""
    private(set) var name: String = ""
    private(set) var phone: String = ""
    private(set) var extraInfo: [String: String] = [:]
    
    public func addValues(_ userID: String = "", name: String = "", phone: String = "", extra: [String: String] = [:]) {
        self.userID = userID
        self.name = name
        self.phone = phone
        self.extraInfo = extra
    }
    
}
