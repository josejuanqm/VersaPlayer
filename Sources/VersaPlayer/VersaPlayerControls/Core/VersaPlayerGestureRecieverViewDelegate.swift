//
//  VersaPlayerGestureRecieverViewDelegate.swift
//  VersaPlayerView Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import Foundation

public protocol VersaPlayerGestureRecieverViewDelegate: AnyObject {
    
    /// Pinch was recognized
    ///
    /// - Parameters:
    ///     - scale: CGFloat scale
    func didPinch(with scale: CGFloat)
    
    /// Tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at wich touch was recognized
    func didTap(at point: CGPoint)
    
    /// Double tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at wich touch was recognized
    func didDoubleTap(at point: CGPoint)

    /// Pan was recognized
    ///
    /// - Parameters:
    ///     - translation: translation in view
    ///     - at: initial point recognized
    func didPan(with translation: CGPoint, initially at: CGPoint)
    
    #if os(tvOS)
    /// Swipe was recognized
    ///
    /// - Parameters:
    ///     - direction: gestureDirection
    func didSwipe(with direction: UISwipeGestureRecognizer.Direction)
    #endif
}
