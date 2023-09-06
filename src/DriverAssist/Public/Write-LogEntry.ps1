#region Function Write-LogEntry
function Write-LogEntry {
    <#
    .SYNOPSIS
    Writes a detailed and informational log entry
    .DESCRIPTION
    Writes a detailed and informational log entry
    .PARAMETER Value
    Writes an informational log entry
    .PARAMETER Severity
    Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.
    .PARAMETER Source
    Source of the log entry used for debugging purposes.
    .PARAMETER FileName
    Name of the log file that the entry will written to.
    .PARAMETER LogsDirectory
    Path to the logging directory.
    .EXAMPLE
    Write-LogEntry -Value "This is a message" -Severity 2
    Writes a log entry
    .INPUTS
    None
    .OUTPUTS
    None
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Writes to the console for debugging purposes')]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Value added to the log file.")]
        [ValidateNotNullOrEmpty()]
        [Alias("Message")]
        [string]$Value,
        [Parameter(Mandatory = $false, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("1", "2", "3")]
        [string]$Severity = 1,
        # Parameter help description
        [Parameter(Mandatory = $false, HelpMessage = "Source of the log entry used for debugging purposes.")]
        [ValidateNotNullOrEmpty()]
        [string]$Source = $([string]$parentFunctionName = [IO.Path]::GetFileNameWithoutExtension((Get-Variable -Name 'MyInvocation' -Scope 1 -ErrorAction 'SilentlyContinue').Value.MyCommand.Name); if ($parentFunctionName) {$parentFunctionName} else { 'Unknown' }),
        [Parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "DriverAssist.log", # Default the value for testing
        [Parameter(Mandatory = $false)]
        [string]$LogsDirectory
    )
    begin {
        # Get the logging file path
        if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT) {
            $LogsDirectory = 'X:\Windows\TEMP'
        }
        else {
            $LogsDirectory = $env:TEMP
        }
        $logFilePath = Join-Path -Path $LogsDirectory -ChildPath $FileName
    }
    process {
        $Time = Get-Date -Format "HH:mm:ss.fff"
        $Date = Get-Date -Format "MM-dd-yyyy"
        $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        $logText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""OSD"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
        try {
            Out-File -InputObject $logText -Append -NoClobber -FilePath $logFilePath -ErrorAction Stop -Encoding default
            Write-Host "$($Value) :: Cmdlet : $($Source)"
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to append log entry to $($FileName) file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        }
    }
    end {
    }
}
#endregion Function Write-LogEntry