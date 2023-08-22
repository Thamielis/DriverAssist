#region Function New-TerminatingErrorRecord
function New-TerminatingErrorRecord {
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
        [parameter(Mandatory = $false, HelpMessage = "Specify the exception message details.")]
        [ValidateNotNullOrEmpty()]
        [string]$Message = "InnerTerminatingFailure",
        [parameter(Mandatory = $false, HelpMessage = "Specify the violation exception causing the error.")]
        [ValidateNotNullOrEmpty()]
        [string]$Exception = "System.Management.Automation.RuntimeException",
        [parameter(Mandatory = $false, HelpMessage = "Specify the error category of the exception causing the error.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ErrorCategory]$ErrorCategory = [System.Management.Automation.ErrorCategory]::NotImplemented,
        [parameter(Mandatory = $false, HelpMessage = "Specify the target object causing the error.")]
        [ValidateNotNullOrEmpty()]
        [string]$TargetObject = ([string]::Empty)
    )
    begin {
    }
    process {
        # Construct new error record to be returned from function based on parameter inputs
		$SystemException = New-Object -TypeName $Exception -ArgumentList $Message
		$ErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @($SystemException, $ErrorID, $ErrorCategory, $TargetObject)
    }
    end {
        return $ErrorRecord
    }
}
#endregion Function New-TerminatingErrorRecord
