#region Function Test-ComputerDetails
function Test-ComputerDetails {
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
        [PSCustomObject]$InputObject
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        # Construct custom object for computer details validation
		$script:ComputerDetection = [PSCustomObject]@{
			"ModelDetected" = $false
			"SystemSKUDetected" = $false
		}
		if (($null -ne $InputObject.Model) -and (-not ([System.String]::IsNullOrEmpty($InputObject.Model)))) {
			Write-LogEntry -Value "[+] Computer model detection was successful" -Severity 1 -Source ${CmdletName}
			$ComputerDetection.ModelDetected = $true
		}
		if (($null -ne $InputObject.SystemSKU) -and (-not ([System.String]::IsNullOrEmpty($InputObject.SystemSKU)))) {
			Write-LogEntry -Value "[-] Computer SystemSKU detection was successful" -Severity 1 -Source ${CmdletName}
			$ComputerDetection.SystemSKUDetected = $true
		}

		if (($ComputerDetection.ModelDetected -eq $false) -and ($ComputerDetection.SystemSKUDetected -eq $false)) {
			Write-LogEntry -Value "[!] Computer model and SystemSKU values are missing, script execution is not allowed since required values to continue could not be gathered" -Severity 3 -Source ${CmdletName}
			$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
		}
		else {
			Write-LogEntry -Value "[+] Computer details successfully verified" -Severity 1 -Source ${CmdletName}
		}
    }
    end {
    }
}
#endregion Function Test-ComputerDetails
