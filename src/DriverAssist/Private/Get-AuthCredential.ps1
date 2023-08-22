#region Function Get-AuthCredential
function Get-AuthCredential {
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
        # Construct PSCredential object for authentication
		$EncryptedPassword = ConvertTo-SecureString -String $Script:Password -AsPlainText -Force
		$script:Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($Script:UserName, $EncryptedPassword)
        Write-LogEntry -Value "[+] Setting 'Credential' variable" -Severity 1 -Source ${CmdletName}
    }
    end {
    }
}
#endregion Function Get-AuthCredential
