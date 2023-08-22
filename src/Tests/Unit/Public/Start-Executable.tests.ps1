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

Describe Start-Executable -Tag 'Unit' {
InModuleScope $ProjectName {
    Context "When given a valid path and parameters" {
        It "Runs the executable with the given path and parameters" {
            Mock Start-Process {  }
            $path = "C:\Windows\System32\notepad.exe"
            $arguments = @("/run /now")
            $result = Start-Executable -FilePath $path -Arguments $arguments
            $result | Should -Be 0
        }
    }

    Context "When given an invalid path" {
        It "Throws an error" {
            # Arrange
            $path = "Z:\Invalid\Path.exe"
            $arguments = @("Z:\Users\JohnDoe\Documents\example.txt")
            # Act & Assert
            Start-Executable -Path $path -Arguments $arguments -ErrorVariable error
            $error.Count | Should -Not -Be 0
        }
    }
    Context "When given no parameters" {
        It "Runs the executable with no parameters" {
            Mock Start-Process { return 0 }
            $path = "C:\Windows\System32\notepad.exe"
            $result = Start-Executable -Path $path
            $result | Should -Be 0
        }
    }
    # Context "When an error occurs" {
    #     It "Throws an error" {
    #         Mock Start-Process { return 1 }
    #         $path = "C:\Windows\System32\notepad.exe"
    #         $arguments = @("C:\Invalid\File.txt")
    #         # Act & Assert
    #         { Start-Executable -Path $path -Arguments $arguments } | Should -Throw
    #     }
    # }
}
}
