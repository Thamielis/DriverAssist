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

Describe Get-AuthCredential -Tag 'Unit' {
InModuleScope $ProjectName {
    BeforeAll {
        Mock Write-LogEntry { }
    }
    Context 'When validating the service account' {
        BeforeEach {
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMUserName' } -MockWith { 'UserName' }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMPassword' } -MockWith { 'Password' }
        }
        It 'Validates if the password exists' {
            Get-AuthCredential
            Should -Invoke Write-LogEntry -Times 2
            #Assert-MockCalled Write-LogEntry -Exactly 1 -ParameterFilter { $Value -eq '[+] Successfully read service account password from TS environment variable' }
        }
    }
    Context 'When an error occurs validating the service account' {
        It 'Throws if the user name is missing' {
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMUserName' } -MockWith { $null }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMPassword' } -MockWith { 'Password' }
            { Get-AuthCredential } | Should -Throw
            Should -Invoke Write-LogEntry -Times 1

        }
        It 'Throws if the password is missing' {
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMUserName' } -MockWith { 'UserName' }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMPassword' } -MockWith { $null }
            { Get-AuthCredential } | Should -Throw
            Should -Invoke Write-LogEntry -Times 1
        }
    }
    Context 'When constructing the PSCredential object' {
        BeforeEach {
            $mockCredsObject = [PSCustomObject]@{
                UserName = 'UserName'
                Password = 'EncryptedPassword'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMUserName' } -MockWith { 'UserName' }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'MDMPassword' } -MockWith { 'Password' }
            Mock ConvertTo-SecureString -ParameterFilter { $String -eq 'Password' } -MockWith { 'EncryptedPassword' }
            Mock New-Object { $mockCredsObject }
        }
        It 'Constructs the PSCredential object' {
            Get-AuthCredential
            Should -Invoke ConvertTo-SecureString -Times 1
            Should -Invoke New-Object -Times 1
            Should -Invoke Write-LogEntry -Times 1
        }
    }
}
}