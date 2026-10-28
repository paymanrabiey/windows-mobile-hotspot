
# Test-MobileHotspotSupport.ps1
# Read-only diagnostic for Windows Mobile Hotspot.
# Does not start/stop hotspot or modify network configuration.

$ErrorActionPreference = 'Continue'
$script:Results = New-Object System.Collections.ArrayList

function Add-Result {
    param(
        [string]$Name,
        [string]$Status,
        [string]$Details = ''
    )

    $null = $script:Results.Add([PSCustomObject]@{
        Name    = $Name
        Status  = $Status
        Details = $Details
    })
}

function Write-Result {
    param(
        [string]$Name,
        [string]$Status,
        [string]$Details = '',
        [switch]$Blink
    )

    $color = switch -Exact ($Status) {
        'SUPPORTED'      { 'Green' }
        'AVAILABLE'      { 'Green' }
        'RUNNING'        { 'Green' }
        'PASS'           { 'Green' }
        'ACTIVE'         { 'Green' }
        'NOT SUPPORTED'  { 'Red' }
        'FAIL'           { 'Red' }
        'WARNING'        { 'Yellow' }
        'UNKNOWN'        { 'Yellow' }
        'NOT RUNNING'    { 'Yellow' }
        'NEEDS TESTING'  { 'Yellow' }
        default          { 'Gray' }
    }

    $message = '{0,-34} {1}' -f $Name, $Status

    if ($Blink) {
        for ($i = 0; $i -lt 3; $i++) {
            Write-Host "`r$message" -ForegroundColor Red -NoNewline
            Start-Sleep -Milliseconds 250
            Write-Host "`r$(' ' * $message.Length)" -NoNewline
            Start-Sleep -Milliseconds 200
        }
        Write-Host "`r$message" -ForegroundColor Red
    }
    else {
        Write-Host $message -ForegroundColor $color
    }

    if ($Details) {
        Write-Host "  $Details" -ForegroundColor DarkGray
    }
}

function Add-And-ShowResult {
    param(
        [string]$Name,
        [string]$Status,
        [string]$Details = '',
        [switch]$Blink
    )

    Add-Result -Name $Name -Status $Status -Details $Details
    Write-Result -Name $Name -Status $Status -Details $Details -Blink:$Blink
}

Clear-Host

Write-Host ''
Write-Host '====================================================' -ForegroundColor Cyan
Write-Host '       WINDOWS MOBILE HOTSPOT SUPPORT CHECK' -ForegroundColor Cyan
Write-Host '====================================================' -ForegroundColor Cyan
Write-Host 'Read-only diagnostic: no network settings are changed.' -ForegroundColor Gray

# ----------------------------------------------------
# 1. Windows version
# ----------------------------------------------------

Write-Host "`n[1] WINDOWS VERSION" -ForegroundColor Cyan

try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop

    Write-Host "Product : $($os.Caption)"
    Write-Host "Version : $($os.Version)"
    Write-Host "Build   : $($os.BuildNumber)"

    if ([int]$os.BuildNumber -ge 22000) {
        Add-And-ShowResult 'Windows version' 'SUPPORTED' 'Windows 11 build detected.'
    }
    elseif ([int]$os.BuildNumber -ge 10240) {
        Add-And-ShowResult 'Windows version' 'WARNING' 'Windows 10 detected; behavior may differ.'
    }
    else {
        Add-And-ShowResult 'Windows version' 'UNKNOWN' 'Verify Windows and WinRT compatibility.'
    }
}
catch {
    Add-And-ShowResult 'Windows version' 'UNKNOWN' $_.Exception.Message
}

# ----------------------------------------------------
# 2. Physical Wi-Fi adapter
# ----------------------------------------------------

Write-Host "`n[2] WI-FI ADAPTER" -ForegroundColor Cyan

$wifiAdapters = @()

try {
    $wifiAdapters = @(
        Get-NetAdapter -IncludeHidden -ErrorAction Stop |
        Where-Object {
            $_.InterfaceDescription -match 'Wi-Fi|Wireless|802\.11' -and
            $_.InterfaceDescription -notmatch 'Wi-Fi Direct'
        }
    )

    if ($wifiAdapters.Count -gt 0) {
        foreach ($adapter in $wifiAdapters) {
            Write-Host "Name        : $($adapter.Name)"
            Write-Host "Description : $($adapter.InterfaceDescription)"
            Write-Host "Status      : $($adapter.Status)"
            Write-Host "MAC         : $($adapter.MacAddress)"
        }

        $upAdapters = @($wifiAdapters | Where-Object { $_.Status -eq 'Up' })

        if ($upAdapters.Count -gt 0) {
            Add-And-ShowResult 'Physical Wi-Fi adapter' 'PASS' 'At least one adapter is Up.'
        }
        else {
            Add-And-ShowResult 'Physical Wi-Fi adapter' 'WARNING' 'Adapter detected, but none is Up.'
        }
    }
    else {
        Add-And-ShowResult 'Physical Wi-Fi adapter' 'UNKNOWN' 'No matching adapter was identified.'
    }
}
catch {
    Add-And-ShowResult 'Physical Wi-Fi adapter' 'UNKNOWN' $_.Exception.Message
}

# ----------------------------------------------------
# 3. Wi-Fi driver details
# ----------------------------------------------------

Write-Host "`n[3] WI-FI DRIVER" -ForegroundColor Cyan

$wifiDrivers = @()

try {
    $wifiDrivers = @(
        Get-CimInstance Win32_PnPSignedDriver -ErrorAction Stop |
        Where-Object {
            $_.DeviceClass -eq 'NET' -and
            $_.DeviceName -match 'Wi-Fi|Wireless|802\.11'
        }
    )

    if ($wifiDrivers.Count -gt 0) {
        foreach ($driver in $wifiDrivers) {
            Write-Host "Device  : $($driver.DeviceName)"
            Write-Host "Version : $($driver.DriverVersion)"
            Write-Host "Date    : $($driver.DriverDate)"
            Write-Host "Provider: $($driver.DriverProviderName)"
            Write-Host ''
        }

        Add-And-ShowResult 'Wi-Fi driver information' 'PASS' 'Driver information retrieved.'
    }
    else {
        Add-And-ShowResult 'Wi-Fi driver information' 'UNKNOWN' 'Matching signed driver information not found.'
    }
}
catch {
    Add-And-ShowResult 'Wi-Fi driver information' 'UNKNOWN' $_.Exception.Message
}

# ----------------------------------------------------
# 4. Legacy Hosted Network
# ----------------------------------------------------

Write-Host "`n[4] LEGACY HOSTED NETWORK" -ForegroundColor Cyan

$hostedSupport = 'Unknown'

try {
    $netshOutput = @(netsh wlan show drivers 2>&1 | ForEach-Object { "$_" })

    $hostedLine = $netshOutput |
        Select-String 'Hosted network supported\s*:\s*(Yes|No)' |
        Select-Object -First 1

    if ($hostedLine -and $hostedLine.Line -match ':\s*(Yes|No)\s*$') {
        $hostedSupport = $Matches[1]

        if ($hostedSupport -eq 'Yes') {
            Add-And-ShowResult 'Legacy Hosted Network' 'SUPPORTED'
        }
        else {
            Add-And-ShowResult 'Legacy Hosted Network' 'NOT SUPPORTED' `
                'This applies only to the legacy Hosted Network feature.' -Blink
        }
    }
    else {
        Add-And-ShowResult 'Legacy Hosted Network' 'UNKNOWN' `
            'The result could not be parsed. Windows language or driver output may differ.'
    }
}
catch {
    Add-And-ShowResult 'Legacy Hosted Network' 'UNKNOWN' $_.Exception.Message
}

Write-Host 'Important: Legacy Hosted Network support does not determine modern Mobile Hotspot support.' -ForegroundColor Yellow

# ----------------------------------------------------
# 5. Wi-Fi Direct virtual adapters
# ----------------------------------------------------

Write-Host "`n[5] WI-FI DIRECT VIRTUAL ADAPTERS" -ForegroundColor Cyan

$virtualAdapters = @()

try {
    $virtualAdapters = @(
        Get-NetAdapter -IncludeHidden -ErrorAction Stop |
        Where-Object {
            $_.InterfaceDescription -match 'Wi-Fi Direct'
        }
    )

    if ($virtualAdapters.Count -gt 0) {
        $virtualAdapters |
            Format-Table Name, Status, InterfaceDescription -AutoSize

        $virtualUp = @($virtualAdapters | Where-Object { $_.Status -eq 'Up' })

        if ($virtualUp.Count -gt 0) {
            Add-And-ShowResult 'Wi-Fi Direct adapter' 'AVAILABLE' `
                'At least one Wi-Fi Direct virtual adapter is Up.'
        }
        else {
            Add-And-ShowResult 'Wi-Fi Direct adapter' 'WARNING' `
                'Virtual adapter found, but none is Up.'
        }
    }
    else {
        Add-And-ShowResult 'Wi-Fi Direct adapter' 'UNKNOWN' `
            'No Wi-Fi Direct virtual adapter was found. This alone does not prove incompatibility.'
    }
}
catch {
    Add-And-ShowResult 'Wi-Fi Direct adapter' 'UNKNOWN' $_.Exception.Message
}

# ----------------------------------------------------
# 6. Relevant Windows services
# ----------------------------------------------------

Write-Host "`n[6] WINDOWS SERVICES" -ForegroundColor Cyan

foreach ($serviceName in @('WlanSvc', 'SharedAccess')) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop

        Write-Host "$serviceName : $($service.Status) (Startup: $($service.StartType))"

        if ($service.Status -eq 'Running') {
            Add-Result $serviceName 'RUNNING' 'Service is running.'
            Write-Result $serviceName 'RUNNING' 'Service is running.'
        }
        else {
            Add-And-ShowResult $serviceName 'NOT RUNNING' `
                'Service is not running; this may affect Wi-Fi or Internet Connection Sharing.'
        }
    }
    catch {
        Add-And-ShowResult $serviceName 'UNKNOWN' $_.Exception.Message
    }
}

# ----------------------------------------------------
# 7. Modern Mobile Hotspot WinRT API
# ----------------------------------------------------

Write-Host "`n[7] MODERN MOBILE HOTSPOT API" -ForegroundColor Cyan

$apiAvailable = $false
$profileFound = $false
$tetheringState = 'Unknown'
$clientCount = $null
$profileName = $null

try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction Stop

    $networkInfoType = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]

    $managerType = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]

    Add-And-ShowResult 'WinRT tethering API' 'AVAILABLE' `
        'The required WinRT types were loaded.'

    $connectionProfile = $networkInfoType::GetInternetConnectionProfile()

    if ($null -eq $connectionProfile) {
        Add-And-ShowResult 'Internet connection profile' 'UNKNOWN' `
            'No default internet connection profile was returned.'
    }
    else {
        $profileFound = $true
        $profileName = $connectionProfile.ProfileName

        Add-And-ShowResult 'Internet connection profile' 'AVAILABLE' `
            "Profile: $profileName"

        try {
            $manager = $managerType::CreateFromConnectionProfile($connectionProfile)
            $apiAvailable = $true
            $tetheringState = "$($manager.TetheringOperationalState)"

            try {
                $clientCount = $manager.ClientCount
            }
            catch {
                $clientCount = $null
            }

            Add-And-ShowResult 'Tethering manager' 'AVAILABLE' `
                'Manager created successfully.'

            if ($tetheringState -match 'On') {
                Add-And-ShowResult 'Mobile Hotspot state' 'ACTIVE' `
                    "Reported state: $tetheringState"
            }
            elseif ($tetheringState -match 'Off') {
                Add-And-ShowResult 'Mobile Hotspot state' 'WARNING' `
                    'API is available, but the hotspot is currently Off.'
            }
            else {
                Add-And-ShowResult 'Mobile Hotspot state' 'UNKNOWN' `
                    "Reported state: $tetheringState"
            }

            if ($null -ne $clientCount) {
                Add-And-ShowResult 'Connected client count' 'PASS' "$clientCount client(s) reported."
            }
            else {
                Add-And-ShowResult 'Connected client count' 'UNKNOWN' `
                    'Client count could not be read.'
            }
        }
        catch {
            Add-And-ShowResult 'Tethering manager' 'UNKNOWN' `
                $_.Exception.Message
        }
    }
}
catch {
    Add-And-ShowResult 'WinRT tethering API' 'UNKNOWN' `
        "API could not be loaded in this PowerShell environment: $($_.Exception.Message)"
}

# ----------------------------------------------------
# 8. Overall assessment
# ----------------------------------------------------

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host '                 FINAL REPORT' -ForegroundColor Cyan
Write-Host '====================================================' -ForegroundColor Cyan

foreach ($item in $script:Results) {
    Write-Result -Name $item.Name -Status $item.Status -Details $item.Details
}

Write-Host "`n[Overall assessment]" -ForegroundColor Cyan

if ($apiAvailable -and $wifiAdapters.Count -gt 0) {
    if ($tetheringState -match 'On') {
        Write-Host 'Initial checks passed: modern tethering API is available and reports On.' -ForegroundColor Green
    }
    else {
        Write-Host 'Modern tethering API is available. Further hotspot testing is required.' -ForegroundColor Yellow
    }
}
elseif (-not $apiAvailable) {
    Write-Host 'Could not confirm that the modern tethering manager is available in this environment.' -ForegroundColor Yellow
    Write-Host 'This does not conclusively prove that the Wi-Fi adapter is incompatible.' -ForegroundColor Yellow
}
else {
    Write-Host 'The API may be available, but a physical Wi-Fi adapter was not identified.' -ForegroundColor Yellow
}

Write-Host "`n[Limitations]" -ForegroundColor Cyan
Write-Host '- Legacy Hosted Network and modern Mobile Hotspot are different features.'
Write-Host '- API availability does not guarantee that hotspot startup will succeed.'
Write-Host '- A reported On state does not guarantee that clients receive an IP address.'
Write-Host '- DHCP, Internet Connection Sharing, driver behavior, and upstream connectivity require separate testing.'
Write-Host '- No network configuration was intentionally changed by this script.'

Write-Host "`nDiagnostic completed." -ForegroundColor Cyan
