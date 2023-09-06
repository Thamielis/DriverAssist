#region Function Get-AuthCredential
function Get-AuthCredential {
    <#
    .SYNOPSIS
    Constructs a PSCredential object for authentication
    .DESCRIPTION
    Constructs a PSCredential object for authentication.  The UserName and Password variables must be set prior to calling this function.
    .PARAMETER user
    UserName to use for authentication.
    .PARAMETER pass
    Password to use for authentication.
    .EXAMPLE
    $creds = Get-AuthCredential
    .INPUTS
    None
    .OUTPUTS
    System.Management.Automation.PSCredential
    .NOTES
    This function is only useful within a Task Sequence.
    Part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'SecureString is constructed from a variable that is not a literal string.')]
    param (
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-LogEntry -Value "[i] Attempting to read service account credentials from TS environment variables" -Severity 1 -Source ${CmdletName}
        $user = Get-TSValue -Name "MDMUserName"
        $pass = Get-TSValue -Name "MDMPassword"
    }
    process {
        #region Validation
        if (-not ([string]::IsNullOrEmpty($user))) {
            Write-LogEntry -Value "[+] Successfully read service account user name from TS environment variable 'MDMUserName'" -Severity 1 -Source ${CmdletName}
        }
        else {
            Write-LogEntry -Value "[!] Required service account user name could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
            throw "Required service account user name could not be determined from TS environment variable"
        }
        if (-not([string]::IsNullOrEmpty($pass))) {
            Write-LogEntry -Value "[+] Successfully read service account password from TS environment variable 'MDMPassword'" -Severity 1 -Source ${CmdletName}
        }
        else {
            Write-LogEntry -Value "[!] Required service account password could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
            throw "Required service account password could not be determined from TS environment variable"
        }
        #endregion Validation
        # Construct PSCredential object for authentication and scope to the current session
        $encryptedPass = ConvertTo-SecureString -String $pass -AsPlainText -Force
        $script:credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($user, $encryptedPass)
        Write-LogEntry -Value "[+] Set 'Credential' variable" -Severity 1 -Source ${CmdletName}
    }
    end {
        return $script:credential
    }
}
#endregion Function Get-AuthCredential