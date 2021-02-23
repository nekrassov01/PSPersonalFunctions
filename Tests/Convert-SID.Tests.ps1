Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Convert-SID' {
    
    BeforeAll {
        $ErrorActionPreferenceOriginal = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

        # Parameters for Tests    
        $env = Get-Content -Path .\.env | ConvertFrom-Json
    }
    
    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }
    
    Context '正常系' {
        
        It '通常' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env.UserDomain[0], $env.UserName[0])) | Should -BeTrue
        }
        
        It 'ドメイン表記の省略' {
            Convert-SID -Target $env.UserName[0] | Should -BeTrue
        }
        
        It '複数' {
            Convert-SID -Target $env.UserName[0], $env.UserName[1] | Should -BeTrue
        }

        It 'パイプで渡す' {
            $env.UserName[0] | Convert-SID | Should -BeTrue
        }

        It 'パイプで渡す＋複数' {
            $env.UserName[0], ([System.String]::Format('{0}\{1}', $env:USERDOMAIN, $env.UserName[0])) | Convert-SID | Should -BeTrue
        }

        It 'リモートコンピューター' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env.ComputerName[0], $env.UserName[0])) -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It 'リモートコンピューター＋ドメイン表記の省略' {
            Convert-SID -Target $env.UserName[0] -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It 'リモートコンピューター＋ドメイン表記の省略＋複数' {
            Convert-SID -Target $env.UserName[0], $env.UserName[1] -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It 'リモートコンピューター＋パイプで渡す' {
            $env.UserName[0] | Convert-SID -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It 'リモートコンピューター＋パイプで渡す＋複数' {
            $env.UserName[0], ([System.String]::Format('{0}\{1}', $env.ComputerName[0], $env.UserName[1])) | Convert-SID -ComputerName $env.ComputerName[0] | Should -BeTrue
        }
    }

    Context '異常系' {

        It '存在しないユーザーの場合$nullが返る' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env.ComputerName[0], 'InvaliddUser')) | Should -BeNullOrEmpty
        }

        It '存在しないドメインの場合$nullが返る' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', 'InvalidDomain', $env.UserName[0])) | Should -BeNullOrEmpty
        }

        It 'ローカルコンピューターのローカルアカウントでリモートコンピューターのSIDを取得しようとした場合$nullが返る' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env:COMPUTERNAME, $env.UserName[0])) -ComputerName $env.ComputerName[0] | Should -BeNullOrEmpty
        }
    }
}

Pop-Location
