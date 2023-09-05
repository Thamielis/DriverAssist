#region Function Confirm-ComputerModel
function Confirm-ComputerModel {
    <#
    .SYNOPSIS
    Confirm the computer model matches the driver package
    .DESCRIPTION
    Confirm the computer model matches the driver package
    .PARAMETER DriverPackageInput
    Specify the computer model value from the driver package object
    .EXAMPLE
    Confirm-ComputerModel -DriverPackageInput $DriverPackage.Model -ComputerData $ComputerData
    .INPUTS
    [string]DriverPackageInput
    .OUTPUTS
    [bool]True or False
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the computer model value from the driver package object.")]
        [ValidateNotNullOrEmpty()]
        [string]$DriverPackageInput,
        [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$ComputerData
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        # Construct custom object for return value
        $ModelDetectionResult = [PSCustomObject]@{ Detected = $null }
        if ($DriverPackageInput -like $ComputerData.Model) {
            # Computer model match found
            Write-LogEntry -Value "[+] Matched computer model: $($ComputerData.Model)" -Severity 1 -Source ${CmdletName}
            # Set properties for custom object for return value
            $ModelDetectionResult.Detected = $true
        }
        else {
            # Computer model match was not found
            Write-LogEntry -Value "[!] Did not match computer model" -Severity 1 -Source ${CmdletName}
            # Set properties for custom object for return value
            $ModelDetectionResult.Detected = $false
        }
    }
    end {
        return $ModelDetectionResult
    }
}
#endregion Function Confirm-ComputerModel
