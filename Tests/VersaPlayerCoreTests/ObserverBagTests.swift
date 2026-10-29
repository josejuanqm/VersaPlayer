//
//  ObserverBagTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Foundation
import Testing
@testable import VersaPlayerCore

@MainActor
struct ObserverBagTests {
    @Test func releasedOffMainStillRemovesObservers() async throws {
        let name = Notification.Name("ObserverBagTests")
        let counter = Counter()
        await Task.detached {
            let bag = ObserverBag()
            bag.add(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
                MainActor.assumeIsolated { counter.value += 1 }
            })
            NotificationCenter.default.post(name: name, object: nil)
        }.value
        try await waitUntil { counter.value == 1 }
        try await Task.sleep(for: .milliseconds(100))

        NotificationCenter.default.post(name: name, object: nil)
        #expect(counter.value == 1)
    }
}

@MainActor
private final class Counter {
    var value = 0
}
