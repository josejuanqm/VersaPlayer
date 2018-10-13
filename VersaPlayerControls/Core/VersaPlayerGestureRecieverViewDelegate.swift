//
//  VersaPlayerGestureRecieverViewDelegate.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import UIKit

public protocol VersaPlayerGestureRecieverViewDelegate {
    func didPinch(with scale: CGFloat)
    func didTap(at point: CGPoint)
    func didPan(with translation: CGPoint, initially at: CGPoint)
}
