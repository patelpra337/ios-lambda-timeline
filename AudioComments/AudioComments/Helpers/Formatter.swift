//
//  Formatter.swift
//  AudioComments
//
//  Created by patelpra on 7/12/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import Foundation

struct Formatter {
    static private let durationFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    static private let timestampDateFormatter: DateFormatter = {
        let formatting = DateFormatter()
        formatting.dateStyle = .medium // Nov 3, 2001  MMM d, yyyy
        formatting.timeStyle = .none
        return formatting
    }()
    
    static private let timestampTimeFormatter: DateFormatter = {
        let formatting = DateFormatter()
        formatting.dateStyle = .none
        formatting.timeStyle = .short // 1:26 PM  h:mm a
        return formatting
    }()
    
    static func string(from duration: TimeInterval) -> String {
        return durationFormatter.string(from: duration) ?? "--:--"
    }
    
    static func string(from timestamp: Date) -> String {
        let timestampIsFromToday = Calendar.current.isDate(timestamp, equalTo: Date(), toGranularity: .day)
        
        if timestampIsFromToday {
            return timestampTimeFormatter.string(from: timestamp)
        } else {
            return timestampDateFormatter.string(from: timestamp)
        }
    }
}
