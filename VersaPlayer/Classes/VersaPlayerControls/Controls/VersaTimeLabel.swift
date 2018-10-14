//
//  VersaTimeLabel.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import UIKit

open class VersaTimeLabel: UILabel {
    
    public var timeFormat: String = "HH:mm:ss"

    public func update(toTime: TimeInterval) {
        let date = Date(timeIntervalSince1970: toTime)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = timeFormat
        text = formatter.string(from: date)
    }

}
