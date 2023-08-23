#region Function Start-DownloadDriverPackageContent
function Start-DownloadDriverPackageContent {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
    .INPUTS
    .OUTPUTS
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        Write-LogEntry -Value "[i] Attempting to download content files for matched driver package: $($DriverPackageList[0].PackageName)" -Severity 1 -Source ${CmdletName}
        # Depending on current deployment type, attempt to download driver package content
        switch ($script:PSCmdlet.ParameterSetName) {
            "PreCache" {
                if ($script:PSBoundParameters["PreCachePath"]) {
                    if (-not (Test-Path -Path $script:PreCachePath)) {
                        Write-LogEntry -Value "[i] Attempting to create PreCachePath directory, as it doesn't exist: $($script:PreCachePath)" -Severity 1 -Source ${CmdletName}
                        try {
                            New-Item -Path $PreCachePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                        }
                        catch [System.Exception] {
                            Write-LogEntry -Value "[!] Failed to create PreCachePath directory '$($script:PreCachePath)'. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
                            $PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
                        }
                    }
                    if (Test-Path -Path $script:PreCachePath) {
                        $DownloadInvocation = Start-CMDownloadContent -PackageID $DriverPackageList[0].PackageID -DestinationLocationType "Custom" -DestinationVariableName "OSDDriverPackage" -CustomLocationPath "$($script:PreCachePath)"
                    }
                }
                else {
                    $DownloadInvocation = Start-CMDownloadContent -PackageID $DriverPackageList[0].PackageID -DestinationLocationType "CCMCache" -DestinationVariableName "OSDDriverPackage"
                }
            }
            default {
                $DownloadInvocation = Start-CMDownloadContent -PackageID $DriverPackageList[0].PackageID -DestinationLocationType "Custom" -DestinationVariableName "OSDDriverPackage" -CustomLocationPath "%_SMSTSMDataPath%\DriverPackage"
            }
        }
        # If download process was successful, meaning exit code from above function was 0, return the download location path
        if ($DownloadInvocation -eq 0) {
            $DriverPackageContentLocation = $TSEnvironment.Value("OSDDriverPackage01")
            Write-LogEntry -Value "[+] Driver package content files was successfully downloaded to: $($DriverPackageContentLocation)" -Severity 1 -Source ${CmdletName}
            # Handle return value for successful download of driver package content files
            return $DriverPackageContentLocation
        }
        else {
            Write-LogEntry -Value "[!] Driver package content download process returned an unhandled exit code: $($DownloadInvocation)" -Severity 3 -Source ${CmdletName}
            $PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
        }
    }
    end {
    }
}
#endregion Function Start-DownloadDriverPackageContent
