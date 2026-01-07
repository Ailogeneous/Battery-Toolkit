//
// Copyright (C) 2022 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

public enum BTService {
    @MainActor
    public static func main() {
        BTServiceXPCServer.start()
    }
}
