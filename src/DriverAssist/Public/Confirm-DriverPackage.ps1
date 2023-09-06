#region Function Confirm-DriverPackage
function Confirm-DriverPackage {
    <#
    .SYNOPSIS
    Confirm the driver package matches the computer data from the Get-ComputerData function
    .DESCRIPTION
    Confirm the driver package matches the computer data from the Get-ComputerData function
    .PARAMETER ComputerData
    Specify the computer data object from Get-ComputerData function
    .PARAMETER OSImageData
    Specify the OS Image data object from Get-OSImageDetails function
    .PARAMETER DriverPackage
    Specify the driver package object to be validated. This is the output from the Get-AdminServicePackage function.
    .EXAMPLE
    Confirm-DriverPackage -ComputerData $ComputerData -DriverPackage $DriverPackage
    .INPUTS
    System.Management.Automation.PSCustomObject, System.Object[]
    .OUTPUTS
    [System.Object[]]DriverPackage
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object from Get-ComputerDetails function.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$ComputerData,
        [parameter(Mandatory = $true, HelpMessage = "Specify the driver package object to be validated. This is the output from the Get-AdminServicePackage function.")]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]$DriverPackage,
        [Parameter(Mandatory = $false, HelpMessage = "Specify the detection method to use for matching driver packages with computer data.")]
        [string]$ComputerDetectionMethod = "SystemSKU"
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        # Construct an new array list object to hold the returned driver package objects for filtering
        $DriverPackageList = New-Object -TypeName "System.Collections.ArrayList"
    }
    process {
        #region Filter Driver Packages
        # Sort all driver package objects by package name property
        $driverPackages = $DriverPackage | Sort-Object -Property PackageName
        $driverPackagesCount = ($driverPackages | Measure-Object).Count
        Write-LogEntry -Value "[i] Initial count of driver packages before starting filtering process: $($driverPackagesCount)" -Severity 1 -Source ${CmdletName}

        # Filter out driver packages that do not match with the vendor
        Write-LogEntry -Value "[i] Filtering driver package results to detected computer manufacturer: $($ComputerData.Manufacturer)" -Severity 1 -Source ${CmdletName}
        $driverPackages = $driverPackages | Where-Object { $_.Manufacturer -like $ComputerData.Manufacturer }
        $driverPackagesCount = ($driverPackages | Measure-Object).Count
        Write-LogEntry -Value "[i] Count of driver packages after filter processing: $($driverPackagesCount)" -Severity 1 -Source ${CmdletName}

        # Filter out driver packages that do not contain any value in the package description
        Write-LogEntry -Value "[i] Filtering driver package results to only include packages that have data added to the description field" -Severity 1 -Source ${CmdletName}
        $driverPackages = $driverPackages | Where-Object { $_.Description -ne ([string]::Empty) }
        $driverPackagesCount = ($driverPackages | Measure-Object).Count
        Write-LogEntry -Value "[i] Count of driver packages after filter processing: $($driverPackagesCount)" -Severity 1 -Source ${CmdletName}
        #endregion Filter Driver Packages

        foreach ($driverPackageItem in $driverPackages) {
            # Construct custom object to hold values for current driver package properties used for matching with current computer data
            $driverPackageDetails = [PSCustomObject]@{
                PackageName    = $driverPackageItem.Name
                PackageID      = $driverPackageItem.PackageID
                PackageVersion = $driverPackageItem.Version
                DateCreated    = $driverPackageItem.SourceDate
                Manufacturer   = $driverPackageItem.Manufacturer
                Model          = $null
                SystemSKU      = $driverPackageItem.Description.Split(":").Replace("(", "").Replace(")", "")[1]
                OSName         = $null
            }

            # Add driver package model data depending on manufacturer to custom driver package data object
            $driverPackageDetails.Model = $driverPackageItem.Name.Replace($driverPackageItem.Manufacturer, "").Replace(" - ", ":").Split(":").Trim()[1]

            # Add driver package OS name data to custom driver package data object
            if ($driverPackageItem.Name -match "^.*Windows.*(?<OSName>(10|11)).*") { $driverPackageDetails.OSName = -join @("Windows ", $Matches.OSName) }
            switch ($ComputerDetectionMethod) {
                "SystemSKU" {
                    if ([string]::IsNullOrEmpty($driverPackageDetails.SystemSKU)) {
                        Write-LogEntry -Value "[i] [DriverPackage:$($driverPackageDetails.PackageID)]: Driver package was skipped due to missing SystemSKU values in description field" -Severity 2 -Source ${CmdletName}
                    }
                    else {
                        # Attempt to match against SystemSKU
                        $ComputerDetectionMethodResult = Confirm-SystemSKU -DriverPackageInput $driverPackageDetails.SystemSKU -ComputerData $ComputerData -ErrorAction Stop
                        # Fall back to using computer model as the detection method instead of SystemSKU
                        if ($ComputerDetectionMethodResult.Detected -eq $false) {
                            $ComputerDetectionMethodResult = Confirm-ComputerModel -DriverPackageInput $driverPackageDetails.Model -ComputerData $ComputerData
                        }
                    }
                }
                "ComputerModel" {
                    # Attempt to match against computer model
                    $ComputerDetectionMethodResult = Confirm-ComputerModel -DriverPackageInput $driverPackageDetails.Model -ComputerData $ComputerData
                }
            }
            if ($ComputerDetectionMethodResult.Detected -eq $true) {
                # Attempt to match against OS name
                $OSNameDetectionResult = Confirm-OSName -DriverPackageInput $driverPackageDetails.OSName -OSName 'Windows 10'
                if ($OSNameDetectionResult -eq $true) {
                    # Increase detection counter since OS name detection was successful
                    # Update the SystemSKU value for the custom driver package data object to account for multiple values from original driver package data
                    if ($ComputerDetectionMethod -like "SystemSKU") {
                        $driverPackageDetails.SystemSKU = $ComputerDetectionMethodResult.SystemSKUValue
                    }
                }
                $driverPackageList.Add($driverPackageDetails) | Out-Null
            }
        }
    }
    end {
        return $driverPackageList
    }
}
#endregion Function Confirm-DriverPackage