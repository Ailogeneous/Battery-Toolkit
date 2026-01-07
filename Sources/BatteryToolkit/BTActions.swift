//
// Copyright (C) 2022 - 2025 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import BTPreprocessor
import Foundation
import BTShared

public enum BTActions {
    @BTBackgroundActor public static func startDaemon() async -> BTDaemonManagement.Status {
        return await BTDaemonManagement.start()
    }

    public static func approveDaemon(timeout: UInt8) async throws {
        try await BTDaemonManagement.approve(timeout: timeout)
    }

    @BTBackgroundActor public static func upgradeDaemon() async -> BTDaemonManagement.Status {
        return await BTDaemonManagement.upgrade()
    }

    @BTBackgroundActor public static func stop() {
        BTDaemonXPCClient.disconnectDaemon()
    }

    @BTBackgroundActor public static func disablePowerAdapter() async throws {
        try await BTDaemonXPCClient.disablePowerAdapter()
    }

    @BTBackgroundActor public static func enablePowerAdapter() async throws {
        try await BTDaemonXPCClient.enablePowerAdapter()
    }

    @BTBackgroundActor public static func chargeToLimit() async throws {
        try await BTDaemonXPCClient.chargeToLimit()
    }

    @BTBackgroundActor public static func chargeToFull() async throws {
        try await BTDaemonXPCClient.chargeToFull()
    }

    @BTBackgroundActor public static func disableCharging() async throws {
        try await BTDaemonXPCClient.disableCharging()
    }

    @BTBackgroundActor public static func getState() async throws -> [String: NSObject & Sendable] {
        return try await BTDaemonXPCClient.getState()
    }

    @BTBackgroundActor public static func getSettings() async throws -> [String: NSObject & Sendable] {
        return try await BTDaemonXPCClient.getSettings()
    }

    @BTBackgroundActor public static func setSettings(settings: [String: NSObject & Sendable]) async throws {
        try await BTDaemonXPCClient.setSettings(settings: settings)
    }

    @BTBackgroundActor public static func removeDaemon() async throws {
        try await BTDaemonManagement.remove()
    }

    @BTBackgroundActor public static func pauseActivity() async throws {
        try await BTDaemonXPCClient.pauseActivity()
    }

    @BTBackgroundActor public static func resumeActiivty() async throws {
        try await BTDaemonXPCClient.resumeActivity()
    }
}
