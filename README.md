
# Windows Mobile Hotspot

A PowerShell utility to start Windows Mobile Hotspot using the Windows Runtime (WinRT) API.

## Features

- Starts Windows Mobile Hotspot through WinRT.
- Reports the current and final tethering state.
- Displays the operation result and any additional error message.

## Requirements

- Windows with support for the Windows Runtime networking APIs.
- PowerShell with access to `System.Runtime.WindowsRuntime`.
- A compatible Wi-Fi adapter and driver.
- An available network connection profile.

## Usage

Run `enable-wifi.ps1` in PowerShell.

The script reports whether the tethering operation succeeded. A successful result does not guarantee that connected devices will receive an IP address or have internet access.

C:\ .\enable-wifi.ps1

## Compatibility Notes

The legacy `netsh wlan hostednetwork` feature and the modern Windows Mobile Hotspot feature are different. A driver reporting `Hosted network supported: No` does not necessarily mean that Mobile Hotspot is unsupported.

Hardware, driver, Windows configuration, internet connection sharing, and DHCP behavior may affect the result.

## Disclaimer

Provided as-is, without warranty. Test in your own environment before relying on it.
