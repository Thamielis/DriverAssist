#region Function Confirm-ComputerModel
function Confirm-ComputerModel {
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
		$ModelDetectionResult = [PSCustomObject]@{
			Detected = $null
		}
		if ($DriverPackageInput -like $ComputerData.Model) {
			# Computer model match found
			Write-CMLogEntry -Value "[+] Matched computer model: $($ComputerData.Model)" -Severity 1 -Source ${CmdletName}
			# Set properties for custom object for return value
			$ModelDetectionResult.Detected = $true
			return $ModelDetectionResult
		}
		else {
			# Computer model match was not found
			# Set properties for custom object for return value
			$ModelDetectionResult.Detected = $false
			return $ModelDetectionResult
		}
    }
    end {
    }
}
#endregion Function Confirm-ComputerModel
