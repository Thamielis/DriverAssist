#region Function Start-Executable
function Start-Executable {
    <#
    .SYNOPSIS
    Starts a Windows executable with optional arguments.
    .DESCRIPTION
    Starts a Windows executable with optional arguments.
    .PARAMETER Path
    Path to the executable
    .PARAMETER Parameters
    Arguments to be passed to the executable
    .PARAMETER ContinueOnError
    Continue if an error occured while trying to start the process. Default: $false.
    .EXAMPLE
    Start-Executable -Path 'executable.exe' -Parameters '/run'
    .INPUTS
    None
    You cannot pipe objects to this function.
    .OUTPUTS
    None
    This function does not generate any output.
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('Path')]
        [ValidateNotNullorEmpty()]
        [string]$FilePath,
        [Parameter(Mandatory = $false)]
        [Alias('Parameters')]
        [ValidateNotNull()]
        [string[]]$Arguments
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        $SplatArgs = @{
			FilePath = $FilePath
			NoNewWindow = $true
			Passthru = $true
			ErrorAction = "Stop"
		}
    }
    process {
        # Add ArgumentList param if present
		if (-not([System.String]::IsNullOrEmpty($Arguments))) {
			$SplatArgs.Add("ArgumentList", $Arguments)
		}
		# start the executable and wait for the process to exit
		try {
			$Invocation = Start-Process @SplatArgs
			#$Handle = $Invocation.Handle
			$Invocation.WaitForExit()
		}
		catch [System.Exception] {
			Write-Warning -Message $_.Exception.Message; break
		}
    }
    end {
        return $Invocation.ExitCode
    }
}
#endregion Function Start-Executable
