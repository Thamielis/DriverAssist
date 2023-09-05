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
if (Get-Module -Name $ProjectName -ErrorAction 'SilentlyContinue') { Remove-Module -Name $ProjectName -Force }
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

Describe Start-DownloadDriverPackageContent -Tag 'Unit' {
InModuleScope $ProjectName {
    BeforeAll {
        Mock Write-LogEntry { }
    }
    Context 'When attempting to download driver package content files' {
        It 'Should successfully return the download location path' {
            $testPackageList = [PSCustomObject]@{
                PackageName    = "TestDriverPackage"
                PackageID      = "ABC12345"
            }
            Mock Get-TSValue { return "C:\Windows\Temp\DriverPackage\$($testPackageList.PackageID)" }
            Mock Start-CMDownloadContent {  }
            $testContentLocation = Start-DownloadDriverPackageContent -DriverPackageList $testPackageList
            Should -Invoke Write-LogEntry -Times 2 -Exactly
            Should -Invoke Get-TSValue -Times 1 -Exactly
            Should -Invoke Start-CMDownloadContent -Times 1 -Exactly
            $testContentLocation | Should -Be "C:\Windows\Temp\DriverPackage\$($testPackageList.PackageID)"

        }
    }
}
}
