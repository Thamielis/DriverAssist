#region Function Confirm-OSVersion
function Confirm-OSVersion {
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
        [parameter(Mandatory = $true, HelpMessage = "Specify the OS version value from the driver package object.")]
        [ValidateNotNullOrEmpty()]
        [string]$DriverPackageInput,
        [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$OSImageData,
        [parameter(Mandatory = $false, HelpMessage = "Set to True to check for drivers packages that matches earlier versions of Windows than what's detected from web service call.")]
        [ValidateNotNullOrEmpty()]
        [bool]$OSVersionFallback = $false
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        if ($OSVersionFallback -eq $true) {
			# Attempt to convert 2XHX build version into digit, 2XH1 into 2X05 and 2XH2 into 2X10 for simplified version comparison
			$DriverPackageInputConversion = $DriverPackageInput.Replace("H1", "05").Replace("H2", 10)
			$OSImageDataVersionConversion = $OSImageData.Version.Replace("H1", "05").Replace("H2", 10)
			if ([int]$DriverPackageInputConversion -lt [int]$OSImageDataVersionConversion) {
				# OS version match found where driver package input was less than input from OSImageData version
				Write-LogEntry -Value "[+] Matched operating system version: $($DriverPackageInput)" -Severity 1 -Source ${CmdletName}
				return $true
			}
			else {
				# OS version match was not found
				return $false
			}
		}
		else {
			if ($DriverPackageInput -like $OSImageData.Version) {
				# OS version match found
				Write-LogEntry -Value "[+] Matched operating system version: $($OSImageData.Version)" -Severity 1
				return $true
			}
			else {
				# OS version match was not found
				return $false
			}
		}
    }
    end {
    }
}
#endregion Function Confirm-OSVersion
