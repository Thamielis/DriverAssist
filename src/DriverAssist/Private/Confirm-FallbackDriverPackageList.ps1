#region Function Confirm-FallbackDriverPackageList
function Confirm-FallbackDriverPackageList {
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
        if ($Script:SkipFallbackDriverPackageValidation -eq $false) {
			switch ($DriverPackageList.Count) {
				0 {
					Write-LogEntry -Value "[!] Amount of fallback driver packages detected by validation process: $($DriverPackageList.Count)" -Severity 3 -Source ${CmdletName}
					Write-LogEntry -Value "[!]  Validation failed with empty list of matched fallback driver packages, script execution will be terminated" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
				1 {
					Write-LogEntry -Value "[+] Amount of fallback driver packages detected by validation process: $($DriverPackageList.Count)" -Severity 1 -Source ${CmdletName}
					Write-LogEntry -Value "[+] Successfully completed validation with a single driver package, script execution is allowed to continue" -Severity 1 -Source ${CmdletName}
				}
				default {
					Write-LogEntry -Value "[i] Amount of fallback driver packages detected by validation process: $($DriverPackageList.Count)" -Severity 1 -Source ${CmdletName}
					Write-LogEntry -Value "[i] NOTICE: Multiple fallback driver packages have been matched, validation process will automatically choose the most recently created fallback driver package by the DateCreated property" -Severity 1 -Source ${CmdletName}
					# Sort driver packages descending based on DateCreated property and select the most recently created one
					$script:DriverPackageList = $DriverPackageList | Sort-Object -Property DateCreated -Descending | Select-Object -First 1
					Write-LogEntry -Value "[+] Selected fallback driver package '$($DriverPackageList[0].PackageID)' with name: $($DriverPackageList[0].PackageName)" -Severity 1
				}
			}
		}
		else {
			Write-LogEntry -Value "[+] Fallback driver package validation process is being skipped since 'SkipFallbackDriverPackageValidation' variable was set to True" -Severity 1
		}
    }
    end {
    }
}
#endregion Function Confirm-FallbackDriverPackageList
