//
//  VersaTimeLabel.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

#if os(macOS)
public typealias TextField = NSTextField
#else
public typealias TextField = UITextField
#endif

open class VersaTimeLabel: TextField {

    open func update(toTime: TimeInterval) {
        var timeFormat: String = "HH:mm:ss"
        if toTime <= 3599{
            timeFormat = "mm:ss"
        }
        let date = Date(timeIntervalSince1970: toTime)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = timeFormat
        
        #if os(macOS)
        stringValue = formatter.string(from: date)
        #else
        text = formatter.string(from: date)
        #endif
    }

}
