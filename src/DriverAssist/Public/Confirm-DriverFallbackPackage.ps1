#region Function Confirm-DriverFallbackPackage
function Confirm-DriverFallbackPackage {
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
        [parameter(Mandatory = $true, HelpMessage = "Specify the computer details object from Get-ComputerDetails function.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$ComputerData,
        [parameter(Mandatory = $true, HelpMessage = "Specify the OS Image details object from Get-OSImageDetails function.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$OSImageData
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        if ($script:DriverPackageList.Count -eq 0) {
			Write-LogEntry -Value "[i] Previous validation process could not find a match for a specific driver package, starting fallback driver package matching process" -Severity 1 -Source ${CmdletName}
			try {
				# Attempt to retrieve fallback driver packages from ConfigMgr WebService
				$FallbackDriverPackages = Get-AdminServiceItem -Resource "/SMS_Package?`$filter=contains(Name,'Driver Fallback Package')" | Where-Object {
					$_.Name -notmatch "Pilot" -and $_.Name -notmatch "Retired"
				}

				if ($null -ne $FallbackDriverPackages) {
					Write-LogEntry -Value "[i] Retrieved a total of '$(($FallbackDriverPackages | Measure-Object).Count)' fallback driver packages from AdminService matching 'Driver Fallback Package' within the name" -Severity 1 -Source ${CmdletName}
					# Sort all fallback driver package objects by package name property
					$FallbackDriverPackages = $FallbackDriverPackages | Sort-Object -Property PackageName
					# Filter out driver packages that does not match with the vendor
					Write-LogEntry -Value "[i] Filtering fallback driver package results to detected computer manufacturer: $($ComputerData.Manufacturer)" -Severity 1 -Source ${CmdletName}
					$FallbackDriverPackages = $FallbackDriverPackages | Where-Object {
						$_.Manufacturer -like $ComputerData.Manufacturer
					}
					foreach ($DriverPackageItem in $FallbackDriverPackages) {
						# Construct custom object to hold values for current driver package properties used for matching with current computer details
						$DriverPackageDetails = [PSCustomObject]@{
							PackageName = $DriverPackageItem.Name
							PackageID = $DriverPackageItem.PackageID
							DateCreated = $DriverPackageItem.SourceDate
							Manufacturer = $DriverPackageItem.Manufacturer
							OSName = $null
							Architecture = $null
						}
						# Add driver package OS architecture details to custom driver package details object
						if ($DriverPackageItem.Name -match "^.*(?<Architecture>(x86|x64)).*") {
							$DriverPackageDetails.Architecture = $Matches.Architecture
						}
						# Add driver package OS name details to custom driver package details object
						if ($DriverPackageItem.Name -match "^.*Windows.*(?<OSName>(10|11)).*") {
							$DriverPackageDetails.OSName = -join @("Windows ", $Matches.OSName)
						}
						# Set counters for logging output of how many matching checks was successfull
						$DetectionCounter = 0
						$DetectionMethodsCount = 2
						Write-LogEntry -Value "[i[ [DriverPackageFallback:$($DriverPackageItem.PackageID)]: Processing fallback driver package with $($DetectionMethodsCount) detection methods: $($DriverPackageItem.PackageName)" -Severity 1 -Source ${CmdletName}
						# Attempt to match against OS name
						$OSNameDetectionResult = Confirm-OSName -DriverPackageInput $DriverPackageDetails.OSName -OSImageData $OSImageData
						if ($OSNameDetectionResult -eq $true) {
							# Increase detection counter since OS name detection was successful
							$DetectionCounter++
							$OSArchitectureDetectionResult = Confirm-Architecture -DriverPackageInput $DriverPackageDetails.Architecture -OSImageData $OSImageData
							if ($OSArchitectureDetectionResult -eq $true) {
								# Increase detection counter since OS architecture detection was successful
								$DetectionCounter++
								# Match found for all critiera including OS version
								Write-LogEntry -Value "[+] [DriverPackageFallback:$($DriverPackageItem.PackageID)]: Fallback driver package was created on: $($DriverPackageDetails.DateCreated)" -Severity 1 -Source ${CmdletName}
								Write-LogEntry -Value "[+] [DriverPackageFallback:$($DriverPackageItem.PackageID)]: Match found for fallback driver package with $($DetectionCounter)/$($DetectionMethodsCount) checks, adding to list for post-processing of matched fallback driver packages" -Severity 1 -Source ${CmdletName}
								# Add custom driver package details object to list of fallback driver packages for post-processing
								$DriverPackageList.Add($DriverPackageDetails) | Out-Null
							}
						}
					}
				}
				else {
					Write-LogEntry -Value "[!] Retrieved a total of '0' fallback driver packages from AdminService matching operational mode: $($OperationalMode)" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
			}
			catch [System.Exception] {
				Write-LogEntry -Value "[!] An error occurred while attempting to retrieve a list of available fallback driver packages from AdminService endpoint. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
				$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
			}
		}
		else {
			Write-LogEntry -Value "[+] Fallback driver package process will not continue since a matching driver package was already found" -Severity 1 -Source ${CmdletName}
			$script:SkipFallbackDriverPackageValidation = $true
		}
    }
    end {
    }
}
#endregion Function Confirm-DriverFallbackPackage
