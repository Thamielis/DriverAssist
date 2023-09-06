#region Function Confirm-SystemSKU
function Confirm-SystemSKU {
    <#
    .SYNOPSIS
    Confirm the driver package matches the computer data from the Get-ComputerData function based upon SystemSKU
    .DESCRIPTION
    Confirm the driver package matches the computer data from the Get-ComputerData function based upon SystemSKU
    .PARAMETER DriverPackageInput
    Specify the SystemSKU value from the driver package object.
    .PARAMETER ComputerData
    Specify the computer data object from the Get-ComputerData function
    .EXAMPLE
    Confirm-SystemSKU -DriverPackageInput "20FQ" -ComputerData $ComputerData
    .INPUTS
    System.String, System.Management.Automation.PSCustomObject
    .OUTPUTS
    System.Boolean
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the SystemSKU value from the driver package object.")]
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
        # Handle multiple SystemSKU's from driver package input and determine the proper delimiter
        if ($DriverPackageInput -match ",") { $SystemSKUDelimiter = "," }
        if ($DriverPackageInput -match ";") { $SystemSKUDelimiter = ";" }
        # Remove any space characters from driver package input data, replace them with a comma instead and ensure there's no duplicate entries
        $DriverPackageInputArray = $DriverPackageInput.Replace(" ", ",").Split($SystemSKUDelimiter) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
        # Construct custom object for return value
        $SystemSKUDetectionResult = [PSCustomObject]@{
            Detected       = $null
            SystemSKUValue = $null
        }
        # Attempt to determine if the driver package input matches with the computer data input and account for multiple SystemSKU's by separating them with the detected delimiter
        if (-not ([string]::IsNullOrEmpty($SystemSKUDelimiter))) {
            # Construct table for keeping track of matched SystemSKU items
            $SystemSKUTable = @{ }
            # Attempt to match for each SystemSKU item based on computer data input
            foreach ($SystemSKUItem in $DriverPackageInputArray) {
                if ((-not([string]::IsNullOrEmpty($ComputerData.SystemSKU))) -and ($ComputerData.SystemSKU -eq $SystemSKUItem)) {
                    # Add key value pair with match success
                    $SystemSKUTable.Add($SystemSKUItem, $true)
                    # Set custom object property with SystemSKU value that was matched on the detection result object
                    $SystemSKUDetectionResult.SystemSKUValue = $SystemSKUItem
                }
                else {
                    # Add key value pair with match failure
                    $SystemSKUTable.Add($SystemSKUItem, $false)
                }
            }
            # Check if table contains a matched SystemSKU
            if ($SystemSKUTable.Values -contains $true) {
                # SystemSKU match found based upon multiple items detected in computer data input
                Write-LogEntry -Value "[+] Matched SystemSKU: $($ComputerData.SystemSKU)" -Severity 1 -Source ${CmdletName}
                # Set custom object property that SystemSKU value that was matched on the detection result object
                $SystemSKUDetectionResult.Detected = $true
                return $SystemSKUDetectionResult
            }
            else {
                # SystemSKU match was not found based upon multiple items detected in computer data input
                # Set properties for custom object for return value
                $SystemSKUDetectionResult.SystemSKUValue = ""
                $SystemSKUDetectionResult.Detected = $false
                return $SystemSKUDetectionResult
            }
        }
        elseif ($DriverPackageInput -match $ComputerData.SystemSKU) {
            # SystemSKU match found based upon single item detected in computer data input
            Write-LogEntry -Value "[+] Matched SystemSKU: $($ComputerData.SystemSKU)" -Severity 1 -Source ${CmdletName}
            # Set properties for custom object for return value
            $SystemSKUDetectionResult.SystemSKUValue = $ComputerData.SystemSKU
            $SystemSKUDetectionResult.Detected = $true
            return $SystemSKUDetectionResult
        }
        else {
            # None of the above methods worked to match SystemSKU from driver package input with computer data input
            # Set properties for custom object for return value
            $SystemSKUDetectionResult.SystemSKUValue = ""
            $SystemSKUDetectionResult.Detected = $false
            return $SystemSKUDetectionResult
        }
    }
    end {
    }
}
#endregion Function Confirm-SystemSKU