//
//  File.swift
//  
//
//  Created by Sahib Hussain on 22/09/23.
//

import Foundation

internal extension Date {
    
    private static var dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    func toString() -> String {
        return Date.dateFormatter.string(from: self as Date)
    }
    
}
