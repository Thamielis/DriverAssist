#region Function Start-DownloadDriverPackageContent
function Start-DownloadDriverPackageContent {
    <#
    .SYNOPSIS
    Start the download process for the driver package content files using the Start-CMDownloadContent function. Returns the download location path.
    .DESCRIPTION
    Start the download process for the driver package content files using the Start-CMDownloadContent function. Returns the download location path.
    .PARAMETER DriverPackageList
    Specify a DriverPackageList that will be downloaded. This is the output from the Confirm-DriverPackage function.
    .PARAMETER DestinationLocationType
    Specify the destination location type. Valid values are: Custom, Package, or TaskSequence.
    .PARAMETER DestinationVariableName
    Specify the destination Task Sequence variable name.
    .PARAMETER CustomLocationPath
    Specify the custom location path.
    .EXAMPLE
    Start-DownloadDriverPackageContent -DriverPackageList $DriverPackageList
    .INPUTS
    None
    .OUTPUTS
    [string]DriverPackageContentLocation path
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
        [ValidateNotNullOrEmpty()]$DriverPackageList,
        # Destination Location Type
        [Parameter(Mandatory = $false, HelpMessage = "Specify the destination location type. Valid values are: Custom, Package, or TaskSequence.")]
        [ValidateSet("Custom", "Package", "TaskSequence")]
        [string]$DestinationLocationType = "Custom",
        # Destination Variable Name
        [Parameter(Mandatory = $false, HelpMessage = "Specify the destination variable name.")]
        [string]$DestinationVariableName = "XOSDDriverPackage",
        # Custom Location Path
        [Parameter(Mandatory = $false, HelpMessage = "Specify the custom location path.")]
        [string]$CustomLocationPath = "%_SMSTSMDataPath%\DriverPackage"
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        Write-LogEntry -Value "[i] Attempting to download content files for matched driver package: $($DriverPackageList[0].PackageName)" -Severity 1 -Source ${CmdletName}
        Start-CMDownloadContent -PackageID $DriverPackageList[0].PackageID -DestinationLocationType $DestinationLocationType -DestinationVariableName $DestinationVariableName -CustomLocationPath $CustomLocationPath
        # If download process was successful, meaning exit code from above function was 0, return the download location path
        $DriverPackageContentLocation = Get-TSValue -Name "$($DriverVariableName)01"
        Write-LogEntry -Value "[+] Driver package content files was successfully downloaded to: $($DriverPackageContentLocation)" -Severity 1 -Source ${CmdletName}

    }
    end {
        # Handle return value for successful download of driver package content files
        return $DriverPackageContentLocation
    }
}
#endregion Function Start-DownloadDriverPackageContent
