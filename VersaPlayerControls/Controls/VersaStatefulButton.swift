//
//  VersaRewindButton.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import UIKit

@IBDesignable
open class VersaStatefulButton: UIButton {
    
    @IBInspectable public var activeImage: UIImage? = nil
    @IBInspectable public var inactiveImage: UIImage? = nil {
        didSet {
            setImage(inactiveImage, for: .normal)
        }
    }
    
    public func set(active: Bool) {
        if active {
            setImage(activeImage, for: .normal)
        }else {
            setImage(inactiveImage, for: .normal)
        }
    }
        
}

