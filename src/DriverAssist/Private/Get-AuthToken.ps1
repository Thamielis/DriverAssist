#region Function Get-AuthToken
function Get-AuthToken {
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
			# Attempt to install PSIntuneAuth module, if already installed ensure the latest version is being used
			#Install-AuthModule TODO: Add this function to DriverAssist
			# Retrieve authentication token
			Write-LogEntry -Value "[i] Attempting to retrieve authentication token using native client with ID: $($ClientID)" -Severity 1 -Source ${CmdletName}
			$script:AuthToken = Get-MSIntuneAuthToken -TenantName $TenantName -ClientID $ClientID -Credential $Credential -Resource $ApplicationIDURI -RedirectUri "https://login.microsoftonline.com/common/oauth2/nativeclient" -ErrorAction Stop
			Write-LogEntry -Value "[+] Successfully retrieved authentication token" -Severity 1 -Source ${CmdletName}
		}
		catch [System.Exception] {
			Write-LogEntry -Value "[!] Failed to retrieve authentication token. Error message: $($PSItem.Exception.Message)" -Severity 3 -Source ${CmdletName}
			$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
		}
    }
    end {
    }
}
#endregion Function Get-AuthToken
