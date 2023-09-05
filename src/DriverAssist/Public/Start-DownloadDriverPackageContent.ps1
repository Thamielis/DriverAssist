#region Function Start-DownloadDriverPackageContent
function Start-DownloadDriverPackageContent {
    <#
    .SYNOPSIS
    Start the download process for the driver package content files using the Start-CMDownloadContent function. Returns the download location path.
    .DESCRIPTION
    Start the download process for the driver package content files using the Start-CMDownloadContent function. Returns the download location path.
    .PARAMETER DriverPackageList
    Specify a DriverPackageList that will be downloaded. This is the output from the Confirm-DriverPackage function.
    .EXAMPLE
    Start-DownloadDriverPackageContent -DriverPackageList $DriverPackageList
    .INPUTS
    None
    .OUTPUTS
    [string]DriverPackageContentLocation
    .NOTES
    This function is a wrapper for the Start-CMDownloadContent function. It is only used during OSD and will not work outside of the OSD process or outside of a task sequence.
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not State Changing')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify a DriverPackageList that will be downloaded. This is the output from the Confirm-DriverPackage function.")]
        [ValidateNotNullOrEmpty()]$DriverPackageList
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        Write-LogEntry -Value "[i] Attempting to download content files for matched driver package: $($DriverPackageList[0].PackageName)" -Severity 1 -Source ${CmdletName}
        Start-CMDownloadContent -PackageID $DriverPackageList[0].PackageID -DestinationLocationType "Custom" -DestinationVariableName "OSDDriverPackage" -CustomLocationPath "%_SMSTSMDataPath%\DriverPackage"
        # If download process was successful, meaning exit code from above function was 0, return the download location path
        $DriverPackageContentLocation = Get-TSValue -Name "OSDDriverPackage01"
        Write-LogEntry -Value "[+] Driver package content files was successfully downloaded to: $($DriverPackageContentLocation)" -Severity 1 -Source ${CmdletName}

    }
    end {
        # Handle return value for successful download of driver package content files
        return $DriverPackageContentLocation
    }
}
#endregion Function Start-DownloadDriverPackageContent
