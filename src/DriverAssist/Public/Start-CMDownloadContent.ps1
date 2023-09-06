#region Function Start-CMDownloadContent
function Start-CMDownloadContent {
    <#
    .SYNOPSIS
    This function is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process.
    .DESCRIPTION
    This function is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process. Specifically, it is used to download content during the Apply Driver Package step in the task sequence.
    .PARAMETER PackageID
    Specify a PackageID that will be downloaded during the OSD process.
    .PARAMETER DestinationLocationType
    Specify the download location type. Valid values are Custom, TSCache, and CCMCache.
    .PARAMETER DestinationVariableName
    Save the download location to the specified task sequence variable name.
    .PARAMETER CustomLocationPath
    When location type is specified as Custom, specify the custom path.
    .EXAMPLE
    Start-CMDownloadContent -PackageID "ABC00000" -DestinationLocationType "Custom" -DestinationVariableName "CustomLocation" -CustomLocationPath "C:\Temp"
    .INPUTS
    None
    .OUTPUTS
    None
    .NOTES
    This function is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process.
    It is only used during OSD and will not work outside of the OSD process or outside of a task sequence.
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not State Changing')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify a PackageID that will be downloaded.")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^[A-Z0-9]{3}[A-F0-9]{5}$")]
        [string]$PackageID,
        [parameter(Mandatory = $true, HelpMessage = "Specify the download location type.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Custom", "TSCache", "CCMCache")]
        [string]$DestinationLocationType,
        [parameter(Mandatory = $true, HelpMessage = "Save the download location to the specified variable name.")]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationVariableName,
        [parameter(Mandatory = $true, HelpMessage = "When location type is specified as Custom, specify the custom path.")]
        [ValidateNotNullOrEmpty()]
        [string]$CustomLocationPath
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        # Set the task sequence variable: OSDDownloadDownloadPackages
        Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDownloadPackages to: $($PackageID)" -Severity 1 -Source ${CmdletName}
        Set-TSVariable -Name "OSDDownloadDownloadPackages" -Value "$($PackageID)"
        # Set the task sequence variable: OSDDownloadDestinationLocationType
        Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationLocationType to: $($DestinationLocationType)" -Severity 1 -Source ${CmdletName}
        Set-TSVariable -Name "OSDDownloadDestinationLocationType" -Value "$($DestinationLocationType)"
        # Set the task sequence variable: OSDDownloadDestinationVariable
        Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationVariable to: $($DestinationVariableName)" -Severity 1 -Source ${CmdletName}
        Set-TSVariable -Value "$($DestinationVariableName)" -Name "OSDDownloadDestinationVariable"
        # Set the task sequence variable: OSDDownloadDestinationPath
        if ($DestinationLocationType -like "Custom") {
            Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationPath to: $($CustomLocationPath)" -Severity 1 -Source ${CmdletName}
            Set-TSVariable -Name "OSDDownloadDestinationPath" -Value "$($CustomLocationPath)"
        }
        # Set SMSTSDownloadRetryCount to 1000 to overcome potential BranchCache issue that will cause 'SendWinHttpRequest failed. 80072efe'
        Set-TSVariable -Name "SMSTSDownloadRetryCount" -Value 1000
        try {
            if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT) {
                # We are in WinPE, so we need to use the OSDDownloadContent.exe executable from the boot image
                Write-LogEntry -Value "[+] Starting package content download process (WinPE), this might take some time" -Severity 1
                Start-OSDDownloadContent -FilePath "OSDDownloadContent.exe"
            }
            else {
                # We are in Windows, so we need to use the OSDDownloadContent.exe executable from the CCM folder
                Write-LogEntry -Value "[+] Starting package content download process (Windows), this might take some time" -Severity 1 -Source ${CmdletName}
                Start-OSDDownloadContent -FilePath (Join-Path -Path $env:WINDIR -ChildPath "CCM\OSDDownloadContent.exe")
            }
            # Reset SMSTSDownloadRetryCount to 5 after attempted download
            Set-TSVariable -Name "SMSTSDownloadRetryCount" -Value 5
        }
        catch {
            Write-LogEntry -Value "[!] An error occurred while attempting to download package content." -Severity 3 -Source ${CmdletName}
            # Throw terminating error
            throw "An error occurred while attempting to download package content."
        }
    }
    end {
    }
}
#endregion Function Start-CMDownloadContent