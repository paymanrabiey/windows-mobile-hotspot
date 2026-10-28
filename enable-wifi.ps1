Add-Type -AssemblyName System.Runtime.WindowsRuntime

$asTaskGeneric = [System.WindowsRuntimeSystemExtensions].GetMethods() |
    Where-Object {
        $_.Name -eq 'AsTask' -and
        $_.GetParameters().Count -eq 1 -and
        $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
    } |
    Select-Object -First 1

if ($null -eq $asTaskGeneric) {
    throw "WinRT AsTask method was not found."
}

function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))

    if (-not $netTask.Wait(30000)) {
        throw "Operation timed out after 30 seconds."
    }

    $netTask.GetAwaiter().GetResult()
}

$connectionProfile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetInternetConnectionProfile()

if ($null -eq $connectionProfile) {
    throw "No internet connection profile was found."
}

$tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($connectionProfile)

Write-Host "Current state:" $tetheringManager.TetheringOperationalState

$result = Await ($tetheringManager.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])

$result | Format-List Status, AdditionalErrorMessage

Write-Host "Final state:" $tetheringManager.TetheringOperationalState