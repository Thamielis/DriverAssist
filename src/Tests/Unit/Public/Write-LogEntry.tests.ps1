$ProjectRoot = "$PSScriptRoot\..\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectRoot\*\*\*.psd1).Where{
    ($_.Directory.Name -match 'src' -or $_.Directory.Name -eq $_.BaseName) -and
    $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
}).BaseName
#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ProjectName, "$($ProjectName).psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ProjectName -ErrorAction 'SilentlyContinue') { Remove-Module -Name $ProjectName -Force }
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

Describe Write-LogEntry -Tag 'Unit' {
    Context "When writing log entries" {
        InModuleScope $ProjectName {
            It "it should write the log entries to the correct directory in WinPE" {
                Mock Test-Path { $true }
                Mock Join-Path { "TestDrive:\OSDkit.log" }
                $logMessage = "This is an informational log entry"
                $severity = "1"
                Write-LogEntry -Value $logMessage -Severity $severity
                $logFile = "TestDrive:\OSDkit.log"
                $logFile | Should -FileContentMatch $logMessage
                $logFile | Should -FileContentMatch "type=""$($severity)"""
            }
        }
        InModuleScope $ProjectName {
            It "it should write a log entry with Informational severity to the default log file" {
                $logMessage = "This is an informational log entry"
                $severity = "1"
                Write-LogEntry -Value $logMessage -Severity $severity -LogsDirectory 'TestDrive:\'
                $logFile = "TestDrive:\OSDkit.log"
                $logFile | Should -FileContentMatch $logMessage
                $logFile | Should -FileContentMatch "type=""$($severity)"""
            }
        }
        InModuleScope $ProjectName {
            It "it should write a log entry with Warning severity to a specified log file" {
                Write-LogEntry -Value "This is a warning log entry" -Severity 2 -FileName "CustomLog.log" -LogsDirectory "TestDrive:\"
                $logFilePath = Join-Path -Path "TestDrive:\" -ChildPath "CustomLog.log"
                $logFilePath | Should -FileContentMatch "This is a warning log entry"
                $logFilePath | Should -FileContentMatch "type=""2"""
            }
        }
        InModuleScope $ProjectName {
            It "it should write a log entry with Error severity to a specified log file in a custom log directory" {
                $logMessage = "This is an error log entry"
                $severity = "3"
                $logFileName = "CustomErrorLog.log"
                $customLogDirectory = "TestDrive:\"
                Write-LogEntry -Value $logMessage -Severity $severity -FileName $logFileName -LogsDirectory $customLogDirectory
                $logFilePath = Join-Path -Path $customLogDirectory -ChildPath $logFileName
                $logFilePath | Should -FileContentMatch $logMessage
                $logFilePath | Should -FileContentMatch "type=""$($severity)"""
            }
        }
        InModuleScope $ProjectName {
            It "it should throw a warning if it cannot write to the log file" {
                Mock Out-File { throw }
                Write-LogEntry -Value "This is a warning log entry" -LogsDirectory "TestDrive:\"  3>&1 | Should -Match "Error"
            }
        }
    }
}
