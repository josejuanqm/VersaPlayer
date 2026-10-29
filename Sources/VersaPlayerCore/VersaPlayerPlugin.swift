//
//  VersaPlayerPlugin.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Foundation

/// Adds behavior to a `VersaPlayerModel`.
@MainActor
public protocol VersaPlayerPlugin: AnyObject {
    func attach(to model: VersaPlayerModel)
    func detach(from model: VersaPlayerModel)
}

extension VersaPlayerPlugin {
    public func detach(from model: VersaPlayerModel) {}
}
