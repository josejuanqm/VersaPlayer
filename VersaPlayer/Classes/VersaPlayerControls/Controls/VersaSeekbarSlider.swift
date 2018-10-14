//
//  VersaSeekbarSlider.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import UIKit

@IBDesignable
open class VersaSeekbarSlider: UISlider {

    @IBInspectable public var thumbImage: UIImage? = nil {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }

}
