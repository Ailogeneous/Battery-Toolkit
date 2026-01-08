<p align="center">
 <img alt="Battery Toolkit logo" src="Resources/LogoCaption.png" width=500 align="center">
</p>

<p align="center">A Swift package to control the platform power state of your Apple Silicon Mac.</p>

<p align="center"><a href="#features">Features</a> &bull; <a href="#installation">Installation</a> &bull; <a href="#usage">Usage</a> &bull; <a href="#api-reference">API Reference</a> &bull; <a href="#limitations"> Limitations </a> &bull; <a href="#technical-details"> Technical Details </a> &bull; <a href="#donate"> Donate </a></p>

-----
## For Developers Who Wish To Utilize Their Own Interface:

# Features

*   **Limit Battery Charge:** Set an upper limit for the battery charge to prevent it from being always at 100%.
*   **Drain to Lower Limit:** Set a lower limit for the battery charge to prevent short charging cycles.
*   **Disable Power Adapter:** Discharge the battery by turning off the power adapter without unplugging it.
*   **Manual Control:** A comprehensive set of functions to manually control the power state of the Mac.

# Installation

To integrate Battery Toolkit as a Swift Package into your Xcode project for development and customization, follow these steps:

**Important! ⚠️ Do Not Add Package via SPM from Git URL**

The `Battery-Toolkit-SP` package needs to be a subdirectory of your consuming application's Xcode project to correctly configure the necessary paths for XPC communication and code signing.

1.  **Clone the Repository Directly into Your Xcode Project Folder:**
    Open your terminal, navigate to the root directory of your consuming application's Xcode project (e.g., where your `.xcodeproj` file is located), and then clone the `Battery-Toolkit-SP` repository:
    ```bash
    cd /path/to/your/consuming/app/project/
    git clone https://github.com/Ailogeneous/Battery-Toolkit-SP.git
    ```
    This will create a `Battery-Toolkit-SP` folder inside your project's root directory.

2.  **Add as a Local Package Dependency in Xcode:**
    *   Open your consuming application's Xcode project.
    *   Go to `File > Add Packages...`.
    *   In the package dialog, click the `Add Local...` button.
    *   Navigate to and select the `Battery-Toolkit-SP` directory now located inside your project (e.g., `/path/to/your/consuming/app/project/Battery-Toolkit-SP`).
    *   Follow the prompts to add the package. Ensure you choose the desired version (e.g., `Up to Next Major Version`).
    *   Add the `BatteryToolkit` library product to your application target's "Frameworks, Libraries, and Embedded Content" section.

3.  **Run the Configuration Script (`configure.sh`):**
    This script is crucial for customizing the Swift Package to integrate correctly with your application's specific identifiers. It modifies the package's source files to match your consuming application's bundle identifier, team ID, and code-signing information.

    *   Open your terminal.
    *   Navigate to the `Battery-Toolkit-SP` directory, which is inside your project's root:
        ```bash
        cd /path/to/your/consuming/app/project/Battery-Toolkit-SP
        ```
    *   Run the configuration script:
        ```bash
        ./configure.sh
        ```
    *   The script will automatically detect your Xcode project's bundle identifier and team ID by looking in the parent directory (`..`). If it cannot find these values, it will prompt you to enter them manually. **Ensure you provide the correct bundle identifier and team ID of your *consuming application* (the one you are building with your UI).**

4.  **Clean and Rebuild Your Application:**
    *   After running the `configure.sh` script, go back to Xcode.
    *   Perform a **Clean Build Folder** (`Product > Clean Build Folder`) to ensure all old build artifacts are removed and the package is recompiled with the new configuration.
    *   Then, try to **Build** your consuming application project again (`Product > Build`).

These steps ensure that your local `Battery-Toolkit-SP` package is correctly configured for your application, allowing for secure XPC communication and proper daemon/service registration.

**Important! ⚠️ Please keep in mind that because of the nature of handling the XPC service within the package, SPM cannot automatically update your local copy of this package. You will need to manually pull changes for any updates, and rerun the configuration script.** 

# Usage

Once integrated, you can use the `BatteryToolkit` module in your application to control the charging features. The main entry point for interacting with the core functionalities is through the `BTActions` enum.

Here are some examples:

```swift
import BatteryToolkit

// To start the daemon
Task {
    let status = await BTActions.startDaemon()
    print("Daemon start status: \(status)")
}

// To disable the power adapter
Task {
    do {
        try await BTActions.disablePowerAdapter()
        print("Power adapter disabled.")
    } catch {
        print("Failed to disable power adapter: \(error)")
    }
}

// To get current battery state
Task {
    do {
        let state = try await BTActions.getState()
        print("Current state: \(state)")
    } catch {
        print("Failed to get state: \(error)")
    }
}

// To get current settings
Task {
    do {
        let settings = try await BTActions.getSettings()
        print("Current settings: \(settings)")
    } catch {
        print("Failed to get settings: \(error)")
    }
}

// To set new settings (e.g., max charge)
Task {
    do {
        let newSettings: [String: NSObject & Sendable] = [
            BTSettingsInfo.Keys.maxCharge: NSNumber(value: 85)
        ]
        try await BTActions.setSettings(settings: newSettings)
        print("Settings updated.")
    } catch {
        print("Failed to set settings: \(error)")
    }
}
```

# API Reference

The `BTActions` enum provides a set of static functions to interact with the Battery-Toolkit daemon.

## Daemon Management

*   `startDaemon() async -> BTDaemonManagement.Status`: Starts the background daemon.
*   `approveDaemon(timeout: UInt8) async throws`: Approves the background daemon.
*   `upgradeDaemon() async -> BTDaemonManagement.Status`: Upgrades the background daemon.
*   `removeDaemon() async throws`: Removes the background daemon.
*   `stop()`: Disconnects the XPC connection to the daemon.

## Power Control

*   `disablePowerAdapter() async throws`: Disables the power adapter.
*   `enablePowerAdapter() async throws`: Enables the power adapter.
*   `chargeToLimit() async throws`: Charges the battery to the specified limit.
*   `chargeToFull() async throws`: Charges the battery to 100%.
*   `disableCharging() async throws`: Stops charging the battery.

## Background Activity

*   `pauseActivity() async throws`: Pauses the daemon's background activity.
*   `resumeActiivty() async throws`: Resumes the daemon's background activity.

## State and Settings

*   `getState() async throws -> [String: NSObject & Sendable]`: Retrieves the current power state.
*   `getSettings() async throws -> [String: NSObject & Sendable]`: Retrieves the current settings.
*   `setSettings(settings: [String: NSObject & Sendable]) async throws`: Sets new values for the settings.

# Limitations

Battery Toolkit disables sleep while it is charging, because it has to actively disable charging once reaching the maximum. Sleep is re-enabled once charging is stopped for any reason, e.g., reaching the maximum charge level, manual cancellation, or unplugging the MacBook.

Apps, including Battery Toolkit, cannot control the charge state when the machine is shut down. If the charger remains plugged in while the Mac is off, the battery will charge to 100&nbsp;%.

Note that sleep should usually be disabled when the power adapter is disabled, as this will exit Clamshell mode and the machine will sleep immediately if the lid is closed. Refer to the toggle in the Settings dialog (see **Fig. 1**).

# Technical Details

*   Based on IOPowerManagement events to minimize resource usage, especially when not connected to power
*   Support for macOS Ventura daemons and login items for a more reliable experience

## Security
*   Privileged operations are authenticated by the daemon
*   Privileged daemon exposes only a minimal protocol via XPC
*   XPC communication uses the latest macOS codesign features

# Credits
*   Icon based on [reference icon by Streamline](https://seekicon.com/free-icon/rechargable-battery_1)
*   README overhauled by [rogue](https://github.com/realrogue)

# Donate
For various reasons, I will not accept personal donations. However, if you would like to support my work with the [Kinderschutzbund Kaiserslautern-Kusel](https://www.kinderschutzbund-kaiserslautern.de/) child protection association, you may donate [here](https://www.kinderschutzbund-kaiserslautern.de/helfen-sie-mit/spenden/).
