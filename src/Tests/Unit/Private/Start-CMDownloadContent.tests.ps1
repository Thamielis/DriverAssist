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

Describe Start-CMDownloadContent -Tag 'Unit' {
InModuleScope $ProjectName {
    BeforeAll {
        Import-Module -Name TaskSequenceModule -Force
    }
    BeforeEach {
        # Mock the required functions and cmdlets
        Mock Set-TSValue -ModuleName TaskSequenceModule -MockWith { }
        Mock Set-TSVariable { }
        Mock Write-LogEntry { }
        Mock Start-Executable {  }
    }

    Context "When given a valid package ID and custom location path" {
        It "Downloads the package content successfully" {
            $packageID = "ABC001"
            $customLocationPath = "C:\Temp\Downloads"
            $result = Start-CMDownloadContent -PackageID $packageID -CustomLocationPath $customLocationPath
            # Assert
            $result | Should -Be 0
            Assert-MockCalled Set-TSValue -ParameterFilter { $Variable -eq "OSDDownloadDestinationPath" -and $Value -eq $customLocationPath } -Exactly 1 -Scope It
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "SMSTSDownloadRetryCount" -and $Value -eq 1000 } -Exactly 1 -Scope It
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[+] Starting package content download process (WinPE), this might take some time" -and $Severity -eq 1 } -Exactly 1 -Scope It
            Assert-MockCalled Start-Executable -ParameterFilter { $FilePath -eq "OSDDownloadContent.exe" } -Exactly 1 -Scope It
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "SMSTSDownloadRetryCount" -and $Value -eq 5 } -Exactly 1 -Scope It
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[+] Successfully downloaded package content with PackageID: $packageID" -and $Severity -eq 1 } -Exactly 1 -Scope It
        }
    }

    Context "When given an invalid package ID" {
        It "Throws a terminating error" {
            # Arrange
            $packageID = "InvalidPackageID"
            $customLocationPath = "C:\Temp\Downloads"

            # Act & Assert
            { Start-CMDownloadContent -PackageID $packageID -CustomLocationPath $customLocationPath } | Should -Throw
            Assert-MockCalled Set-TSValue -ParameterFilter { $Variable -eq "OSDDownloadDestinationPath" -and $Value -eq $customLocationPath } -Exactly 1 -Scope It
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "SMSTSDownloadRetryCount" -and $Value -eq 1000 } -Exactly 1 -Scope It
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[+] Starting package content download process (WinPE), this might take some time" -and $Severity -eq 1 } -Exactly 1 -Scope It
            Assert-MockCalled Start-Executable -ParameterFilter { $FilePath -eq "OSDDownloadContent.exe" } -Exactly 1 -Scope It
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "SMSTSDownloadRetryCount" -and $Value -eq 5 } -Exactly 0 -Scope It
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[!] Failed to download package content with PackageID '$packageID'. Return code was: 1" -and $Severity -eq 3 } -Exactly 1 -Scope It
        }
    }

    Context "When an error occurs during download" {
        It "Throws a terminating error" {
            # Arrange
            $packageID = "ABC001"
            $customLocationPath = "C:\Temp\Downloads"
            Mock Start-Executable { throw "Failed to start OSDDownloadContent.exe" }

            # Act & Assert
            { Start-CMDownloadContent -PackageID $packageID -CustomLocationPath $customLocationPath } | Should -Throw
            Assert-MockCalled Set-TSValue -ParameterFilter { $Variable -eq "OSDDownloadDestinationPath" -and $Value -eq $customLocationPath } -Exactly 1 -Scope It
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "SMSTSDownloadRetryCount" -and $Value -eq 1000 } -Exactly 1 -Scope It
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[+] Starting package content download process (WinPE), this might take some time" -and $Severity -eq 1 } -Exactly 1 -Scope It
            Assert-MockCalled Start-Executable -ParameterFilter { $FilePath -eq "OSDDownloadContent.exe" } -Exactly 1 -Scope It
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "SMSTSDownloadRetryCount" -and $Value -eq 5 } -Exactly 0 -Scope It
            Assert-MockCalled Write-LogEntry -ParameterFilter { $Value -eq "[!] An error occurred while attempting to download package content. Error message: Failed to start OSDDownloadContent.exe" -and $Severity -eq 3 } -Exactly 1 -Scope It
        }
    }
}
}
