//
//  VersaRewindButton.swift
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
public typealias Button = NSButton
#else
public typealias Button = UIButton
#endif

@IBDesignable
open class VersaStatefulButton: Button {
    
    #if os(macOS)
    open override var state: NSControl.StateValue {
        didSet {
            if state == .on {
                image = activeImage
            }else {
                image = inactiveImage
            }
        }
    }
    
    @IBInspectable public var activeImage: NSImage? = nil
    @IBInspectable public var inactiveImage: NSImage? = nil
    #else
    @IBInspectable public var activeImage: UIImage? = nil
    @IBInspectable public var inactiveImage: UIImage? = nil {
        didSet {
            setImage(inactiveImage, for: .normal)
        }
    }
    #endif
    
    open func set(active: Bool) {
        #if os(macOS)
        state = active ? .on : .off
        #else
        if active {
            setImage(activeImage, for: .normal)
        }else {
            setImage(inactiveImage, for: .normal)
        }
        #endif
    }
        
}

