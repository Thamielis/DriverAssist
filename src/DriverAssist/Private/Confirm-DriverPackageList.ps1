#region Function Confirm-DriverPackageList
function Confirm-DriverPackageList {
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
        switch ($DriverPackageList.Count) {
			0 {
				Write-LogEntry -Value "[i] Amount of driver packages detected by validation process: $($DriverPackageList.Count)" -Severity 2 -Source ${CmdletName}
				if ($script:PSBoundParameters["OSVersionFallback"]) {
					Write-LogEntry -Value "[i] Validation process detected empty list of matched driver packages, however OSVersionFallback switch was passed on the command line" -Severity 2 -Source ${CmdletName}
					Write-LogEntry -Value "[i] Starting re-matching process of driver packages for older Windows versions" -Severity 1 -Source ${CmdletName}
					# Attempt to match all drivers packages again but this time where OSVersion from driver packages is lower than what's detected from web service call
					Write-LogEntry -Value "[i] [DriverPackageFallback]: Starting driver package OS version fallback matching phase" -Severity 1 -Source ${CmdletName}
					Confirm-DriverPackage -ComputerData $ComputerData -OSImageData $OSImageDetails -DriverPackage $DriverPackages -OSVersionFallback $true
					if ($DriverPackageList.Count -ge 1) {
						# Sort driver packages descending based on OSVersion, DateCreated properties and select the most recently created one
						$script:DriverPackageList = $DriverPackageList | Sort-Object -Property OSVersion, DateCreated -Descending | Select-Object -First 1
						Write-LogEntry -Value "[+] Selected driver package '$($DriverPackageList[0].PackageID)' with name: $($DriverPackageList[0].PackageName)" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[+] Successfully completed validation after fallback process and detected a single driver package, script execution is allowed to continue" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[+] [DriverPackageFallback]: Completed driver package OS version fallback matching phase" -Severity 1 -Source ${CmdletName}
					}
					else {
						if ($script:PSBoundParameters["UseDriverFallback"]) {
							Write-LogEntry -Value "[i] Validation process detected an empty list of matched driver packages, however the UseDriverFallback parameter was specified" -Severity 1 -Source ${CmdletName}
						}
						else {
							Write-LogEntry -Value "[!] Validation after fallback process failed with empty list of matched driver packages, script execution will be terminated" -Severity 3 -Source ${CmdletName}
							$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
						}
					}
				}
				else {
					if ($script:PSBoundParameters["UseDriverFallback"]) {
						Write-LogEntry -Value "[i] Validation process detected an empty list of matched driver packages, however the UseDriverFallback parameter was specified" -Severity 1 -Source ${CmdletName}
					}
					else {
						Write-LogEntry -Value "[!] Validation failed with empty list of matched driver packages, script execution will be terminated" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
			1 {
				Write-LogEntry -Value "[+] Amount of driver packages detected by validation process: $($DriverPackageList.Count)" -Severity 1 -Source ${CmdletName}
				Write-LogEntry -Value "[+] Successfully completed validation with a single driver package, script execution is allowed to continue" -Severity 1 -Source ${CmdletName}
			}
			default {
				Write-LogEntry -Value "[i] Amount of driver packages detected by validation process: $($DriverPackageList.Count)" -Severity 1 -Source ${CmdletName}
				if ($ComputerDetectionMethod -like "SystemSKU") {
					if ($null -eq ($DriverPackageList | Where-Object { $_.SystemSKU -notlike $DriverPackageList[0].SystemSKU })) {
						Write-LogEntry -Value "[-] NOTICE: Computer detection method is currently '$($ComputerDetectionMethod)', and multiple packages have been matched with the same SystemSKU value" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[-] NOTICE: This is a supported scenario where the vendor use the same driver package for multiple models" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[-] NOTICE: Validation process will automatically choose the most recently created driver package, even if it means that the computer model names may not match" -Severity 1 -Source ${CmdletName}
						# Sort driver packages descending based on DateCreated property and select the most recently created one
						$script:DriverPackageList = $DriverPackageList | Sort-Object -Property DateCreated -Descending | Select-Object -First 1
						Write-LogEntry -Value "[+] Selected driver package '$($DriverPackageList[0].PackageID)' with name: $($DriverPackageList[0].PackageName)" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[+] Successfully completed validation with multiple detected driver packages, script execution is allowed to continue" -Severity 1 -Source ${CmdletName}
					}
					else {
						# This should not be possible, but added to handle output to log file
						Write-LogEntry -Value "[!] WARNING: Computer detection method is currently '$($ComputerDetectionMethod)', and multiple packages have been matched but with different SystemSKU value" -Severity 2 -Source ${CmdletName}
						Write-LogEntry -Value "[!] WARNING: This should not be a possible scenario, please reach out to the developers of this script" -Severity 2 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
				else {
					Write-LogEntry -Value "[!] NOTICE: Computer detection method is currently '$($ComputerDetectionMethod)', and multiple packages have been matched with the same Model value" -Severity 1 -Source ${CmdletName}
					Write-LogEntry -Value "[!] NOTICE: Validation process will automatically choose the most recently created driver package by the DateCreated property" -Severity 1 -Source ${CmdletName}
					# Sort driver packages descending based on DateCreated property and select the most recently created one
					$script:DriverPackageList = $DriverPackageList | Sort-Object -Property DateCreated -Descending | Select-Object -First 1
					Write-LogEntry -Value "[+] Selected driver package '$($DriverPackageList[0].PackageID)' with name: $($DriverPackageList[0].PackageName)" -Severity 1
				}
			}
		}
    }
    end {
    }
}
#endregion Function Confirm-DriverPackageList
