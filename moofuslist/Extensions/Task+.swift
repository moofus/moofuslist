//
//  Task+.swift
//  PartyMeet
//
//  Created by Lamar Williams III on 5/7/24.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
