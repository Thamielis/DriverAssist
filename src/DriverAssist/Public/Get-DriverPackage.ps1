#region Function Get-DriverPackage
function Get-DriverPackage {
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
        try {
			# Retrieve driver packages but filter out matches depending on script operational mode
			switch ($OperationalMode) {
				"Production" {
					if ($script:PSCmdlet.ParameterSetName -like "XMLPackage") {
						Write-LogEntry -Value "[i] Reading XML content logic file driver package entries" -Severity 1 -Source ${CmdletName}
						$packages = (([xml]$(Get-Content -Path $XMLPackageLogicFile -Raw)).ArrayOfCMPackage).CMPackage | Where-Object {
							$_.Name -notmatch "Pilot" -and $_.Name -notmatch "Legacy" -and $_.Name -match $Filter
						}
					}
					else {
						Write-LogEntry -Value "[i] Querying AdminService for driver package instances" -Severity 1 -Source ${CmdletName}
						$packages = Get-AdminServiceItem -Resource "/SMS_Package?`$filter=contains(Name,'$($Filter)')" | Where-Object {
							$_.Name -notmatch "Pilot" -and $_.Name -notmatch "Retired"
						}
					}

				}
				"Pilot" {
					if ($script:PSCmdlet.ParameterSetName -like "XMLPackage") {
						Write-LogEntry -Value "[i] Reading XML content logic file driver package entries" -Severity 1 -Source ${CmdletName}
						$Packages = (([xml]$(Get-Content -Path $XMLPackageLogicFile -Raw)).ArrayOfCMPackage).CMPackage | Where-Object {
							$_.Name -match "Pilot" -and $_.Name -match $Filter
						}
					}
					else {
						Write-LogEntry -Value "[i] Querying AdminService for driver package instances" -Severity 1 -Source ${CmdletName}
						$Packages = Get-AdminServiceItem -Resource "/SMS_Package?`$filter=contains(Name,'$($Filter)')" | Where-Object {
							$_.Name -match "Pilot"
						}
					}
				}
			}
			# Handle return value
			if ($null -ne $Packages) {
				Write-LogEntry -Value "[+] Retrieved a total of '$(($Packages | Measure-Object).Count)' driver packages from $($script:PackageSource) matching operational mode: $($OperationalMode)" -Severity 1 -Source ${CmdletName}
				return $Packages
			}
			else {
				Write-LogEntry -Value "[!] Retrieved a total of '0' driver packages from $($script:PackageSource) matching operational mode: $($OperationalMode)" -Severity 3 -Source ${CmdletName}
				$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
			}
		}
		catch [System.Exception] {
			Write-LogEntry -Value "[!] An error occurred while calling $($script:PackageSource) for a list of available driver packages. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
			$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
		}
    }
    end {
    }
}
#endregion Function Get-DriverPackage
