$ProjectRoot = "$PSScriptRoot\..\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectRoot\*\*\*.psd1).Where{
    ($_.Directory.Name -match 'src' -or $_.Directory.Name -eq $_.BaseName) -and
    $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
}).BaseName
#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ProjectName, "$ProjectName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ProjectName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ProjectName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

Describe Start-OSDDownloadContent -Tag 'Unit' {
InModuleScope $ProjectName {
    Context "When calling the function with valid input" {
        BeforeAll {
            $script:testEXE = "D:\repos\DriverAssist\testdata\EchoArgs.exe"
            Import-Module -Name Microsoft.PowerShell.Management
            # Mock Write-LogEntry function
            Mock Write-LogEntry { }
        }
        It "Should execute the specified file path" {
            Start-OSDDownloadContent -FilePath $script:testEXE
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[i] Executing [$testEXE]..." } -Times 1
        }
    #     It "Should execute the specified file path with parameters" {
    #         $parameters = "-Parameter1 Value1 -Parameter2 Value2"
    #         Start-OSDDownloadContent -FilePath $script:testEXE -Parameters $parameters
    #         Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[i] Executing [$filePath $parameters]..." } -Times 1
    #     }
    #     It "Should execute the specified PowerShell scriptblock" {
    #         $scriptBlock = { Write-Host "Test" }
    #         Start-OSDDownloadContent -ScriptBlock $scriptBlock
    #         Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[i] Executing [$scriptBlock [PowerShell scriptblock]]..." } -Times 1
    #     }
    #     It "Should set the process priority class to the specified value" {
    #         $filePath = "C:\Test\FilePath.exe"
    #         $priorityClass = "High"
    #         Mock System.Diagnostics.Process {
    #             Mock PriorityClass {}
    #             Mock WaitForExit {}
    #             Mock HasExited { return $true }
    #             Mock ExitCode { return 0 }
    #         }
    #         Start-OSDDownloadContent -FilePath $filePath -PriorityClass $priorityClass
    #         Assert-MockCalled PriorityClass -ParameterFilter { $Value -eq $priorityClass } -Times 1
    #     }
    #     It "Should return the process exit code" {
    #         $filePath = "C:\Test\FilePath.exe"
    #         $exitCode = 0
    #         Mock System.Diagnostics.Process {
    #             Mock PriorityClass {}
    #             Mock WaitForExit {}
    #             Mock HasExited { return $true }
    #             Mock ExitCode { return $exitCode }
    #         }
    #         $result = Start-OSDDownloadContent -FilePath $filePath
    #         $result.ExitCode | Should -Be $exitCode
    #     }
    # }
    # Context "When calling the function with invalid input" {
    #     It "Should throw an error when the specified file path does not exist" {
    #         $filePath = "C:\Nonexistent\File\Path.exe"
    #         { Start-OSDDownloadContent -FilePath $filePath } | Should -Throw
    #     }
    #     It "Should throw an error when the specified PowerShell scriptblock is null" {
    #         $scriptBlock = $null
    #         { Start-OSDDownloadContent -ScriptBlock $scriptBlock } | Should -Throw
    #     }
    #     It "Should throw an error when the specified PowerShell scriptblock is empty" {
    #         $scriptBlock = { }
    #         { Start-OSDDownloadContent -ScriptBlock $scriptBlock } | Should -Throw
    #     }
    }
}
}
