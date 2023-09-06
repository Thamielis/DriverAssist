#region Function Start-OSDDownloadContent
function Start-OSDDownloadContent {
    <#
    .SYNOPSIS
    Starts the OSD Download Content executable with optional arguments.
    .DESCRIPTION
    Starts the OSD Download Content executable with optional arguments. This is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process.
    .PARAMETER Path
    Path to the OSDDownloadContent executable
    .PARAMETER Parameters
    Arguments to be passed to the executable
    .PARAMETER WindowStyle
    Style of the window of the process executed. Options: Normal, Hidden, Maximized, Minimized. Default: Normal.
    Note: Not all processes honor WindowStyle. WindowStyle is a recommendation passed to the process. They can choose to ignore it.
    Only works for native Windows GUI applications. If the WindowStyle is set to Hidden, UseShellExecute should be set to $true.
    .PARAMETER CreateNoWindow
    Specifies whether the process should be started with a new window to contain it. Only works for Console mode applications. UseShellExecute should be set to $false.
    Default is false.
    .PARAMETER IgnoreExitCodes
    List the exit codes to ignore or * to ignore all exit codes.
    .PARAMETER PriorityClass
    Specifies priority class for the process. Options: Idle, Normal, High, AboveNormal, BelowNormal, RealTime. Default: Normal
    .PARAMETER ContinueOnError
    Continue if an error occured while trying to start the process. Default: $false.
    .EXAMPLE
    Start-OSDDownloadContent -Path 'C:\Temp\OSDDownloadContent.exe' -Parameters '-Command "& { Write-Host "Test" }"'
    .INPUTS
    None
    .OUTPUTS
    System.Diagnostics.Process
    .NOTES
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not State Changing')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('FilePath')]
        [ValidateNotNullorEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [Alias('Arguments')]
        [ValidateNotNullorEmpty()]
        [string[]]$Parameters,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Normal', 'Hidden', 'Maximized', 'Minimized')]
        [Diagnostics.ProcessWindowStyle]$WindowStyle = 'Normal',
        [Parameter(Mandatory = $false)]
        [ValidateNotNullorEmpty()]
        [switch]$CreateNoWindow = $false,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullorEmpty()]
        [string]$IgnoreExitCodes,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Idle', 'Normal', 'High', 'AboveNormal', 'BelowNormal', 'RealTime')]
        [Diagnostics.ProcessPriorityClass]$PriorityClass = 'Normal',
        [Parameter(Mandatory = $false)]
        [ValidateNotNullorEmpty()]
        [bool]$UseShellExecute = $false,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullorEmpty()]
        [bool]$ContinueOnError = $false
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        try {
            $private:returnCode = $null
            # If the WindowStyle parameter is set to 'Hidden', set the UseShellExecute parameter to '$true'.
            if ($WindowStyle -eq 'Hidden') { $UseShellExecute = $true }
            try {
                # Disable Zone checking to prevent warnings when running executables
                $env:SEE_MASK_NOZONECHECKS = 1
                # Using this variable allows capture of exceptions from .NET methods. Private scope only changes value for current function.
                $private:previousErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Stop'
                # Define process
                $processStartInfo = New-Object -TypeName 'System.Diagnostics.ProcessStartInfo' -ErrorAction 'Stop'
                $processStartInfo.FileName = $Path
                $processStartInfo.UseShellExecute = $UseShellExecute
                $processStartInfo.ErrorDialog = $false
                $processStartInfo.RedirectStandardOutput = $true
                $processStartInfo.RedirectStandardError = $true
                $processStartInfo.CreateNoWindow = $CreateNoWindow
                if ($Parameters) { $processStartInfo.Arguments = $Parameters }
                $processStartInfo.WindowStyle = $WindowStyle
                if ($processStartInfo.UseShellExecute -eq $true) {
                    Write-LogEntry -Value '[i] UseShellExecute is set to true, standard output and error will not be available.' -Severity 1 -Source ${CmdletName}
                    $processStartInfo.RedirectStandardOutput = $false
                    $processStartInfo.RedirectStandardError = $false
                }
                $process = New-Object -TypeName 'System.Diagnostics.Process' -ErrorAction 'Stop'
                $process.StartInfo = $processStartInfo
                if ($processStartInfo.UseShellExecute -eq $false) {
                    # Add event handler to capture process's standard output redirection
                    [scriptblock]$processEventHandler = { if (-not [string]::IsNullOrEmpty($EventArgs.Data)) { $Event.MessageData.AppendLine($EventArgs.Data) } }
                    $stdOutBuilder = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList ('')
                    $stdOutEvent = Register-ObjectEvent -InputObject $process -Action $processEventHandler -EventName 'OutputDataReceived' -MessageData $stdOutBuilder -ErrorAction 'Stop'
                    $stdErrBuilder = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList ('')
                    $stdErrEvent = Register-ObjectEvent -InputObject $process -Action $processEventHandler -EventName 'ErrorDataReceived' -MessageData $stdErrBuilder -ErrorAction 'Stop'
                }
                # Start Process
                if ($Parameters) {
                    if ($Parameters -match '-Command \&') {
                        Write-LogEntry -Value "[i] Executing [$Path [PowerShell scriptblock]]..." -Severity 1 -Source ${CmdletName}
                    }
                    else {
                        Write-LogEntry -Value "[i] Executing [$Path $Parameters]..." -Severity 1 -Source ${CmdletName}
                    }
                }
                else {
                    Write-LogEntry -Value "[i] Executing [$Path]..." -Severity 1 -Source ${CmdletName}
                }
                $null = $process.Start()
                # Set priority
                if ($PriorityClass -ne 'Normal') {
                    try {
                        if ($process.HasExited -eq $false) {
                            Write-LogEntry "[i] Changing the priority class for the process to [$PriorityClass]" -Severity 1 -Source ${CmdletName}
                            $process.PriorityClass = $PriorityClass
                        }
                        else {
                            Write-LogEntry -Value "[i] Cannot change the priority class for the process to [$PriorityClass], because the process has exited already." -Severity 1 -Source ${CmdletName}
                        }
                    }
                    catch {
                        Write-LogEntry -Value "[!] Failed to change the priority class for the process to [$PriorityClass]. $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
                    }
                }

                if ($processStartInfo.UseShellExecute -eq $false) {
                    $process.BeginOutputReadLine()
                    $process.BeginErrorReadLine()
                }
                # Instructs the Process component to wait indefinitely for the associated process to exit.
                $process.WaitForExit()
                # HasExited indicates that the associated process has terminated, either normally or abnormally. Wait until HasExited returns $true.
                while (-not $process.HasExited) {
                    $process.Refresh(); Start-Sleep -Seconds 1
                }
                # Get the exit code for the process
                try {
                    [int32]$returnCode = $process.ExitCode
                    Write-LogEntry -Value "[i] Process exit code: [$returnCode]" -Severity 1 -Source ${CmdletName}
                }
                catch [System.Management.Automation.PSInvalidCastException] {
                    # Catch exit codes that are out of int32 range
                    [int32]$returnCode = 60013
                }
                if ($processStartInfo.UseShellExecute -eq $false) {
                    # Unregister standard output and error event to retrieve process output
                    if ($stdOutEvent) {
                        Unregister-Event -SourceIdentifier $stdOutEvent.Name -ErrorAction 'Stop'; $stdOutEvent = $null
                    }
                    if ($stdErrEvent) {
                        Unregister-Event -SourceIdentifier $stdErrEvent.Name -ErrorAction 'Stop'; $stdErrEvent = $null
                    }
                    $stdOut = $stdOutBuilder.ToString() -replace $null, ''
                    $stdErr = $stdErrBuilder.ToString() -replace $null, ''
                    if ($stdErr.Length -gt 0) {
                        Write-LogEntry -Value "[!] Standard error output from the process: $stdErr" -Severity 3 -Source ${CmdletName}
                    }
                }

            }
            finally {
                if ($processStartInfo.UseShellExecute -eq $false) {
                    # Make sure the standard output and error event is unregistered
                    if ($stdOutEvent) {
                        Unregister-Event -SourceIdentifier $stdOutEvent.Name -ErrorAction 'SilentlyContinue'; $stdOutEvent = $null
                    }
                    if ($stdErrEvent) {
                        Unregister-Event -SourceIdentifier $stdErrEvent.Name -ErrorAction 'SilentlyContinue'; $stdErrEvent = $null
                    }
                }
                # Free resources associated with the process, this does not cause process to exit
                if ($process) { $process.Dispose() }
                # Re-enable Zone checking
                Remove-Item -LiteralPath 'env:SEE_MASK_NOZONECHECKS' -ErrorAction 'SilentlyContinue'
                if ($private:previousErrorActionPreference) {
                    $ErrorActionPreference = $private:previousErrorActionPreference
                }
            }
            # Check to see whether we should ignore exit codes
            $ignoreExitCodeMatch = $false
            if ($ignoreExitCodes) {
                # Check whether * was specified, which would tell us to ignore all exit codes
                if ($ignoreExitCodes.Trim() -eq '*') {
                    $ignoreExitCodeMatch = $true
                }
                else {
                    # Split the processes on a comma
                    [Int32[]]$ignoreExitCodesArray = $ignoreExitCodes -split ','
                    foreach ($ignoreCode in $ignoreExitCodesArray) {
                        if ($returnCode -eq $ignoreCode) {
                            $ignoreExitCodeMatch = $true
                        }
                    }
                }
            }
            # If the passthru switch is specified, return the exit code and any output from process
            if ($PassThru) {
                Write-LogEntry -Value "[i] PassThru parameter specified, returning execution results object. Exit code: [$returnCode]" -Severity 1 -Source ${CmdletName}
                [psobject]$ExecutionResults = New-Object -TypeName 'PSObject' -Property @{ ExitCode = $returnCode; StdOut = if ($stdOut) {
                        $stdOut
                    }
                    else {
                        ''
                    }; StdErr = if ($stdErr) {
                        $stdErr
                    }
                    else {
                        ''
                    }
                }
                Write-Output -InputObject ($ExecutionResults)
            }
            if ($ignoreExitCodeMatch) {
                Write-LogEntry -Value "[+] Execution completed and the exit code [$returncode] is being ignored." -Severity 1 -Source ${CmdletName}
            }
            elseif ($returnCode -eq 0) {
                Write-LogEntry -Value "[+] Execution completed successfully with exit code [$returnCode]." -Severity 1 -Source ${CmdletName}
            }
            else {
                Write-LogEntry -Value "[!] Execution failed with exit code [$returnCode]." -Severity 3 -Source ${CmdletName}
            }
        }
        catch {
            if ([string]::IsNullOrEmpty([string]$returnCode)) {
                [int32]$returnCode = 60002
                Write-LogEntry -Value "[!] Function failed, setting exit code to [$returnCode]." -Severity 3 -Source ${CmdletName}
                if (-not $ContinueOnError) {
                    throw "Function failed, setting exit code to [$returnCode]. $($_.Exception.Message)"
                }
            }
            else {
                Write-LogEntry "[!] Execution completed with exit code [$returnCode]. Function failed." -Severity 3 -Source ${CmdletName}
            }
            if ($PassThru) {
                [psobject]$ExecutionResults = New-Object -TypeName 'PSObject' -Property @{
                    ExitCode = $returnCode; StdOut = if ($stdOut) {
                        $stdOut
                    }
                    else {
                        ''
                    }; StdErr = if ($stdErr) {
                        $stdErr
                    }
                    else {
                        ''
                    }
                }
                Write-Output -InputObject ($ExecutionResults)
            }
        }
    }
    end {
    }
}
#endregion Function Start-OSDDownloadContent