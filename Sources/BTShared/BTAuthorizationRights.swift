//
// Copyright (C) 2022 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import BTPreprocessor
import Foundation

public enum BTAuthorizationRights {
    /// Right that guards privileged Battery Toolkit daemon operations.
    public static let manage = BT_DAEMON_ID + ".manage"
}
