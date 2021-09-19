//
//  VersaPlayerDecryptionDelegate.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/23/18.
//

import Foundation

public protocol VersaPlayerDecryptionDelegate: AnyObject {
    func urlFor(player: VersaPlayer) -> URL
    func contentIdFor(player: VersaPlayer) -> String
    func contentKeyContextURLFor(player: VersaPlayer) -> URL
}
