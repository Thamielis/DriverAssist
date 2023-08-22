#region Function Set-AdminServiceURL
function Set-AdminServiceURL {
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
        switch ($script:AdminServiceEndpointType) {
			"Internal" {
				$script:AdminServiceURL = "https://{0}/AdminService/wmi" -f $Endpoint
			}
			"External" {
				$script:AdminServiceURL = "{0}/wmi" -f $ExternalEndpoint
			}
		}
		Write-LogEntry -Value "[+] Setting 'AdminServiceURL' variable to: $($script:AdminServiceURL)" -Severity 1 -Source ${CmdletName}
    }
    end {
    }
}
#endregion Function Set-AdminServiceURL
