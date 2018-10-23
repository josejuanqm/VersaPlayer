//
//  VersaPlayerDecryptionDelegate.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/23/18.
//

import Foundation

public protocol VersaPlayerDecryptionDelegate {
    func urlFor(player: VPlayer) -> URL
    func contentIdFor(player: VPlayer) -> String
    func contentKeyContextURLFor(player: VPlayer) -> URL
}
