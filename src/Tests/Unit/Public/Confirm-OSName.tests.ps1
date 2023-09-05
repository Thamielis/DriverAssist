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

Describe Confirm-OSName -Tag 'Unit' {
InModuleScope $ProjectName {
    Context 'When confirming the OS name' {
        BeforeAll {
            Mock Write-LogEntry { }
        }
        It 'it should return true if the OS name matches' {
            $DriverPackageDetails = [PSCustomObject]@{ OSName = 'Windows 10'}
            $result = Confirm-OSName -DriverPackageInput $DriverPackageDetails.OSName -OSName 'Windows 10'
            $result | Should -Be $true
            Should -Invoke Write-LogEntry -Exactly -Times 1
        }
        It 'it should return false if the OS name does not match' {
            $DriverPackageDetails = [PSCustomObject]@{ OSName = 'Windows 11'}
            $result = Confirm-OSName -DriverPackageInput $DriverPackageDetails.OSName -OSName 'Windows 10'
            $result | Should -Be $false
            Should -Invoke Write-LogEntry -Exactly -Times 1

        }
    }
}
}
