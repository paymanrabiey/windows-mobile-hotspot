
# Test-MobileHotspotSupport.ps1
# Read-only diagnostic for Windows Mobile Hotspot.

$ErrorActionPreference = "Continue"

Write-Host "`n=== Windows Mobile Hotspot Support Check ===" -ForegroundColor Cyan

# 1. Windows version
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "`n[Windows]"
Write-Host "Product : $($os.Caption)"
Write-Host "Version : $($os.Version)"
Write-Host "Build   : $($os.BuildNumber)"

# 2. Wi-Fi adapters and drivers
Write-Host "`n[Wi-Fi adapters and drivers]"

$wifiAdapters = Get-CimInstance Win32_NetworkAdapter |
    Where-Object {
        $_.Name -match 'Wi-Fi|Wireless|802\.11' -or
        $_.Description -match 'Wi-Fi|Wireless|802\.11'
    }

if (-not $wifiAdapters) {
    Write-Host "No Wi-Fi adapter was identified." -ForegroundColor Red
} else {
    foreach ($adapter in $wifiAdapters) {
        Write-Host "`nAdapter : $($adapter.Name)"
        Write-Host "Device  : $($adapter.Description)"
        Write-Host "Status  : $($adapter.NetConnectionStatus)"
        Write-Host "PNP ID  : $($adapter.PNPDeviceID)"
    }
}

$wifiDrivers = Get-CimInstance Win32_PnPSignedDriver |
    Where-Object {
        $_.DeviceClass -eq 'NET' -and
        ($_.DeviceName -match 'Wi-Fi|Wireless|802\.11')
    }

foreach ($driver in $wifiDrivers) {
    Write-Host "`nDriver  : $($driver.DeviceName)"
    Write-Host "Version : $($driver.DriverVersion)"
    Write-Host "Date    : $($driver.DriverDate)"
}

# 3. Legacy Hosted Network support
Write-Host "`n[Legacy Hosted Network]"
$netshOutput = netsh wlan show drivers 2>&1
$hostedLine = $netshOutput |
    Select-String 'Hosted network supported'

if ($hostedLine) {
    $hostedLine | ForEach-Object { Write-Host $_.Line }
} else {
    Write-Host "Hosted Network support could not be determined."
}

Write-Host "Note: Legacy Hosted Network is different from modern Mobile Hotspot."

# 4. Wi-Fi Direct virtual adapters
Write-Host "`n[Wi-Fi Direct adapters]"

$virtualAdapters = Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue |
    Where-Object {
        $_.InterfaceDescription -match 'Wi-Fi Direct'
    }

if ($virtualAdapters) {
    $virtualAdapters |
        Format-Table Name, Status, InterfaceDescription -AutoSize
} else {
    Write-Host "No Wi-Fi Direct virtual adapter was found."
}

# 5. Relevant services
Write-Host "`n[Relevant services]"

Get-Service -Name WlanSvc, SharedAccess -ErrorAction SilentlyContinue |
    Format-Table Name, Status, StartType -AutoSize

# 6. Modern Mobile Hotspot API availability
Write-Host "`n[Modern Mobile Hotspot API]"

try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction Stop

    $managerType = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]

    $profileType = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]

    Write-Host "WinRT tethering type: Available" -ForegroundColor Green

    $profile = $profileType::GetInternetConnectionProfile()

    if ($null -eq $profile) {
        Write-Host "Internet connection profile: Not found" -ForegroundColor Yellow
    } else {
        Write-Host "Internet connection profile: Found"
        Write-Host "Profile name: $($profile.ProfileName)"

        try {
            $manager = $managerType::CreateFromConnectionProfile($profile)
            Write-Host "Tethering manager: Created"
            Write-Host "Operational state: $($manager.TetheringOperationalState)"
            Write-Host "Connected clients: $($manager.ClientCount)"
        } catch {
            Write-Host "Tethering manager could not be created."
            Write-Host $_.Exception.Message
        }
    }
} catch {
    Write-Host "WinRT tethering API could not be loaded." -ForegroundColor Yellow
    Write-Host $_.Exception.Message
}

Write-Host "`n=== Check completed ===" -ForegroundColor Cyan
Write-Host "This diagnostic does not guarantee hotspot or DHCP functionality."
