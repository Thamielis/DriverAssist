#region Function Confirm-DriverPackage
function Confirm-DriverPackage {
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
        [PSCustomObject]$OSImageData,
        [parameter(Mandatory = $true, HelpMessage = "Specify the driver package object to be validated.")]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]$DriverPackage,
        [parameter(Mandatory = $false, HelpMessage = "Set to True to check for drivers packages that matches earlier versions of Windows than what's detected from admin service call.")]
        [ValidateNotNullOrEmpty()]
        [bool]$OSVersionFallback = $false
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        # Sort all driver package objects by package name property
		$DriverPackages = $DriverPackage | Sort-Object -Property PackageName
		$DriverPackagesCount = ($DriverPackages | Measure-Object).Count
		Write-LogEntry -Value "[i] Initial count of driver packages before starting filtering process: $($DriverPackagesCount)" -Severity 1 -Source ${CmdletName}
		# Filter out driver packages that does not match with the vendor
		Write-LogEntry -Value "[i] Filtering driver package results to detected computer manufacturer: $($ComputerData.Manufacturer)" -Severity 1 -Source ${CmdletName}
		$DriverPackages = $DriverPackages | Where-Object { $_.Manufacturer -like $ComputerData.Manufacturer }
		$DriverPackagesCount = ($DriverPackages | Measure-Object).Count
		Write-LogEntry -Value "[i] Count of driver packages after filter processing: $($DriverPackagesCount)" -Severity 1 -Source ${CmdletName}
		# Filter out driver packages that does not contain any value in the package description
		Write-LogEntry -Value "[i] Filtering driver package results to only include packages that have details added to the description field" -Severity 1 -Source ${CmdletName}
		$DriverPackages = $DriverPackages | Where-Object { $_.Description -ne ([string]::Empty) }
		$DriverPackagesCount = ($DriverPackages | Measure-Object).Count
		Write-LogEntry -Value "[i] Count of driver packages after filter processing: $($DriverPackagesCount)" -Severity 1 -Source ${CmdletName}
		foreach ($DriverPackageItem in $DriverPackages) {
			# Construct custom object to hold values for current driver package properties used for matching with current computer details
			$DriverPackageDetails = [PSCustomObject]@{
				PackageName = $DriverPackageItem.Name
				PackageID = $DriverPackageItem.PackageID
				PackageVersion = $DriverPackageItem.Version
				DateCreated = $DriverPackageItem.SourceDate
				Manufacturer = $DriverPackageItem.Manufacturer
				Model = $null
				SystemSKU = $DriverPackageItem.Description.Split(":").Replace("(", "").Replace(")", "")[1]
				OSName = $null
				OSVersion = $null
				Architecture = $null
			}
			# Add driver package model details depending on manufacturer to custom driver package details object
			# - HP computer models require the manufacturer name to be a part of the model name, other manufacturers do not
			try {
				switch ($DriverPackageItem.Manufacturer) {
					"Hewlett-Packard" {
						$DriverPackageDetails.Model = $DriverPackageItem.Name.Replace("Hewlett-Packard", "HP").Replace(" - ", ":").Split(":").Trim()[1]
					}
					"HP" {
						$DriverPackageDetails.Model = $DriverPackageItem.Name.Replace(" - ", ":").Split(":").Trim()[1]
					}
					default {
						$DriverPackageDetails.Model = $DriverPackageItem.Name.Replace($DriverPackageItem.Manufacturer, "").Replace(" - ", ":").Split(":").Trim()[1]
					}
				}
			}
			catch [System.Exception] {
				Write-LogEntry -Value "[!] Failed. Error: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
			}
			# Add driver package OS architecture details to custom driver package details object
			if ($DriverPackageItem.Name -match "^.*(?<Architecture>(x86|x64)).*") {
				$DriverPackageDetails.Architecture = $Matches.Architecture
			}
			# Add driver package OS name details to custom driver package details object
			if ($DriverPackageItem.Name -match "^.*Windows.*(?<OSName>(10|11)).*") {
				$DriverPackageDetails.OSName = -join @("Windows ", $Matches.OSName)
			}
			# Add driver package OS version details to custom driver package details object
			if ($DriverPackageItem.Name -match "^.*Windows.*(?<OSVersion>(\d){4}).*|^.*Windows.*(?<OSVersion>(\d){2}(\D){1}(\d){1}).*") {
				$DriverPackageDetails.OSVersion = $Matches.OSVersion
			}
			# Set counters for logging output of how many matching checks was successfull
			$DetectionCounter = 0
			if ($null -ne $DriverPackageDetails.OSVersion) {
				$DetectionMethodsCount = 4
			}
			else {
				$DetectionMethodsCount = 3
			}
			Write-LogEntry -Value "[i] [DriverPackage:$($DriverPackageDetails.PackageID)]: Processing driver package with $($DetectionMethodsCount) detection methods: $($DriverPackageDetails.PackageName)" -Severity 1 -Source ${CmdletName}
			switch ($ComputerDetectionMethod) {
				"SystemSKU" {
					if ([string]::IsNullOrEmpty($DriverPackageDetails.SystemSKU)) {
						Write-LogEntry -Value "[i] [DriverPackage:$($DriverPackageDetails.PackageID)]: Driver package was skipped due to missing SystemSKU values in description field" -Severity 2 -Source ${CmdletName}
					}
					else {
						# Attempt to match against SystemSKU
						$ComputerDetectionMethodResult = Confirm-SystemSKU -DriverPackageInput $DriverPackageDetails.SystemSKU -ComputerData $ComputerData -ErrorAction Stop
						# Fall back to using computer model as the detection method instead of SystemSKU
						if ($ComputerDetectionMethodResult.Detected -eq $false) {
							$ComputerDetectionMethodResult = Confirm-ComputerModel -DriverPackageInput $DriverPackageDetails.Model -ComputerData $ComputerData
						}
					}
				}
				"ComputerModel" {
					# Attempt to match against computer model
					$ComputerDetectionMethodResult = Confirm-ComputerModel -DriverPackageInput $DriverPackageDetails.Model -ComputerData $ComputerData
				}
			}
			if ($ComputerDetectionMethodResult.Detected -eq $true) {
				# Increase detection counter since computer detection was successful
				$DetectionCounter++
				# Attempt to match against OS name
				$OSNameDetectionResult = Confirm-OSName -DriverPackageInput $DriverPackageDetails.OSName -OSImageData $OSImageData
				if ($OSNameDetectionResult -eq $true) {
					# Increase detection counter since OS name detection was successful
					$DetectionCounter++
					$OSArchitectureDetectionResult = Confirm-Architecture -DriverPackageInput $DriverPackageDetails.Architecture -OSImageData $OSImageData
					if ($OSArchitectureDetectionResult -eq $true) {
						# Increase detection counter since OS architecture detection was successful
						$DetectionCounter++
						if ($null -ne $DriverPackageDetails.OSVersion) {
							# Handle if OS version should check for fallback versions or match with data from OSImageData variable
							if ($OSVersionFallback -eq $true) {
								$OSVersionDetectionResult = Confirm-OSVersion -DriverPackageInput $DriverPackageDetails.OSVersion -OSImageData $OSImageData -OSVersionFallback $true
							}
							else {
								$OSVersionDetectionResult = Confirm-OSVersion -DriverPackageInput $DriverPackageDetails.OSVersion -OSImageData $OSImageData
							}

							if ($OSVersionDetectionResult -eq $true) {
								# Increase detection counter since OS version detection was successful
								$DetectionCounter++
								# Match found for all critiera including OS version
								Write-LogEntry -Value "[+] [DriverPackage:$($DriverPackageItem.PackageID)]: Driver package was created on: $($DriverPackageDetails.DateCreated)" -Severity 1
								Write-LogEntry -Value "[+] [DriverPackage:$($DriverPackageItem.PackageID)]: Match found between driver package and computer for $($DetectionCounter)/$($DetectionMethodsCount) checks, adding to list for post-processing of matched driver packages" -Severity 1
								# Update the SystemSKU value for the custom driver package details object to account for multiple values from original driver package data
								if ($ComputerDetectionMethod -like "SystemSKU") {
									$DriverPackageDetails.SystemSKU = $ComputerDetectionMethodResult.SystemSKUValue
								}
								# Add custom driver package details object to list of driver packages for post-processing
								$DriverPackageList.Add($DriverPackageDetails) | Out-Null
							}
							else {
								Write-LogEntry -Value "[i] [DriverPackage:$($DriverPackageItem.PackageID)]: Skipping driver package since only $($DetectionCounter)/$($DetectionMethodsCount) checks was matched" -Severity 2 -Source ${CmdletName}
							}
						}
						else {
							# Match found for all critiera except for OS version, assuming here that the vendor does not provide OS version specific driver packages
							Write-LogEntry -Value "[+] [DriverPackage:$($DriverPackageItem.PackageID)]: Driver package was created on: $($DriverPackageDetails.DateCreated)" -Severity 1 -Source ${CmdletName}
							Write-LogEntry -Value "[+] [DriverPackage:$($DriverPackageItem.PackageID)]: Match found between driver package and computer, adding to list for post-processing of matched driver packages" -Severity 1 -Source ${CmdletName}
							# Update the SystemSKU value for the custom driver package details object to account for multiple values from original driver package data
							if ($ComputerDetectionMethod -like "SystemSKU") {
								$DriverPackageDetails.SystemSKU = $ComputerDetectionMethodResult.SystemSKUValue
							}
							# Add custom driver package details object to list of driver packages for post-processing
							$DriverPackageList.Add($DriverPackageDetails) | Out-Null
						}
					}
				}
			}
		}
    }
    end {
    }
}
#endregion Function Confirm-DriverPackage
