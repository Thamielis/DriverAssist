#region Function Get-AdminServiceItem
function Get-AdminServiceItem {
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
        [Parameter(Mandatory = $true, HelpMessage = "Specify the resource for the AdminService API call, e.g. '/SMS_Package'.")]
        [ValidateNotNullOrEmpty()]
        [string]$Resource
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        $packageArray = New-Object -TypeName System.Collections.ArrayList
    }
    process {
        switch ($script:AdminServiceEndpointType) {
			"External" {
				try {
					$adminServiceUri = $AdminServiceURL + $Resource
					Write-LogEntry -Value "[i] Calling AdminService endpoint with URI: $($adminServiceUri)" -Severity 1 -Source ${CmdletName}
					$adminServiceResponse = Invoke-RestMethod -Method Get -Uri $adminServiceUri -Headers $AuthToken -ErrorAction Stop
				}
				catch [System.Exception] {
					Write-LogEntry -Value "[!] Failed to retrieve available package items from AdminService endpoint. Error message: $($PSItem.Exception.Message)" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
			}
			"Internal" {
				$adminServiceUri = $AdminServiceURL + $Resource
				Write-LogEntry -Value "[i] Calling AdminService endpoint with URI: $($AdminServiceUri)" -Severity 1 -Source ${CmdletName}
				try {
					# Call AdminService endpoint to retrieve package data
					$adminServiceResponse = Invoke-RestMethod -Method Get -Uri $adminServiceUri -Credential $credential -ErrorAction Stop
				}
				catch [System.Security.Authentication.AuthenticationException] {
					Write-LogEntry -Value "[!] The remote AdminService endpoint certificate is invalid according to the validation procedure. Error message: $($PSItem.Exception.Message)" -Severity 2 -Source ${CmdletName}
					Write-LogEntry -Value "[i] Will attempt to set the current session to ignore self-signed certificates and retry AdminService endpoint connection" -Severity 2 -Source ${CmdletName}
					# Attempt to ignore self-signed certificate binding for AdminService. Convert encoded base64 string for ignore self-signed certificate validation functionality
					$certificationValidationCallbackEncoded = "DQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAdQBzAGkAbgBnACAAUwB5AHMAdABlAG0AOwANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB1AHMAaQBuAGcAIABTAHkAcwB0AGUAbQAuAE4AZQB0ADsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAdQBzAGkAbgBnACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAZQBjAHUAcgBpAHQAeQA7AA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHUAcwBpAG4AZwAgAFMAeQBzAHQAZQBtAC4AUwBlAGMAdQByAGkAdAB5AC4AQwByAHkAcAB0AG8AZwByAGEAcABoAHkALgBYADUAMAA5AEMAZQByAHQAaQBmAGkAYwBhAHQAZQBzADsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAcAB1AGIAbABpAGMAIABjAGwAYQBzAHMAIABTAGUAcgB2AGUAcgBDAGUAcgB0AGkAZgBpAGMAYQB0AGUAVgBhAGwAaQBkAGEAdABpAG8AbgBDAGEAbABsAGIAYQBjAGsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAewANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHAAdQBiAGwAaQBjACAAcwB0AGEAdABpAGMAIAB2AG8AaQBkACAASQBnAG4AbwByAGUAKAApAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAewANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAaQBmACgAUwBlAHIAdgBpAGMAZQBQAG8AaQBuAHQATQBhAG4AYQBnAGUAcgAuAFMAZQByAHYAZQByAEMAZQByAHQAaQBmAGkAYwBhAHQAZQBWAGEAbABpAGQAYQB0AGkAbwBuAEMAYQBsAGwAYgBhAGMAawAgAD0APQBuAHUAbABsACkADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAUwBlAHIAdgBpAGMAZQBQAG8AaQBuAHQATQBhAG4AYQBnAGUAcgAuAFMAZQByAHYAZQByAEMAZQByAHQAaQBmAGkAYwBhAHQAZQBWAGEAbABpAGQAYQB0AGkAbwBuAEMAYQBsAGwAYgBhAGMAawAgACsAPQAgAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAZABlAGwAZQBnAGEAdABlAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAKAANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAATwBiAGoAZQBjAHQAIABvAGIAagAsACAADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFgANQAwADkAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBlAHIAdABpAGYAaQBjAGEAdABlACwAIAANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAWAA1ADAAOQBDAGgAYQBpAG4AIABjAGgAYQBpAG4ALAAgAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABTAHMAbABQAG8AbABpAGMAeQBFAHIAcgBvAHIAcwAgAGUAcgByAG8AcgBzAA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAKQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHIAZQB0AHUAcgBuACAAdAByAHUAZQA7AA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQA7AA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAA"
					$certificationValidationCallback = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($certificationValidationCallbackEncoded))
					# Load required type definition to be able to ignore self-signed certificate to circumvent issues with AdminService running with ConfigMgr self-signed certificate binding
					Add-Type -TypeDefinition $certificationValidationCallback
					[ServerCertificateValidationCallback]::Ignore()
					try {
						# Call AdminService endpoint to retrieve package data
						$adminServiceResponse = Invoke-RestMethod -Method Get -Uri $AdminServiceUri -Credential $Credential -ErrorAction Stop
					}
					catch [System.Exception] {
						Write-LogEntry -Value "[i] Failed to retrieve available package items from AdminService endpoint. Error message: $($PSItem.Exception.Message)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
				catch {
					Write-LogEntry -Value "[!] Failed to retrieve available package items from AdminService endpoint. Error message: $($PSItem.Exception.Message)" -Severity 3 -Source ${CmdletName}
                    $PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
			}
		}
		# Add returned driver package objects to array list
		if ($null -ne $adminServiceResponse.value) {
			foreach ($package in $AdminServiceResponse.value) {
				$packageArray.Add($package) | Out-Null
			}
		}
    }
    end {
        return $packageArray
    }
}
#endregion Function Get-AdminServiceItem
