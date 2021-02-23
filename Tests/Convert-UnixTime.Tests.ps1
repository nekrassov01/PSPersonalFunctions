Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'GConvert-UnixTime' {

    BeforeAll {
        $ErrorActionPreferenceOriginal = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '正常系' {

        It 'DateTime を UnixTime に変換' {
            Convert-UnixTime -Target '2020/10/01 0:0:0' | Should -BeTrue
        }

        It 'DateTime を UnixTime に変換＋パイプで渡す' {
            '2020/10/01 0:0:0' | Convert-UnixTime | Should -BeTrue
        }

        It '複数の DateTime を UnixTime に変換' {
            Convert-UnixTime -Target '2020/10/01 0:0:0', '2020/11/01 0:0:0' | Should -BeTrue
        }

        It '複数の DateTime を UnixTime に変換＋パイプで渡す' {
           '2020/10/01 0:0:0', '2020/11/01 0:0:0' | Convert-UnixTime | Should -BeTrue
        }

        It 'UnixTime を DateTime に変換' {
            Convert-UnixTime -Target 1601478000 -Reverse | Should -BeTrue
        }

        It 'UnixTime を DateTime に変換＋パイプで渡す' {
            1601478000 | Convert-UnixTime -Reverse | Should -BeTrue
        }

        It '複数の UnixTime を DateTime に変換' {
            Convert-UnixTime -Target 1601478000, 1604156400 -Reverse | Should -BeTrue
        }

        It '複数の UnixTime を DateTime に変換＋パイプで渡す' {
            1601478000, 1604156400 | Convert-UnixTime -Reverse | Should -BeTrue
        }
    }

    Context '異常系' {

        It 'DateTime を UnixTime に変換＋パラメータが範囲外' {
            { Convert-UnixTime -Target '0000/10/01 0:0:0' } | Should -Throw
        }

        It 'DateTime を UnixTime に変換＋パラメータが$null' {
            { Convert-UnixTime -Target $null } | Should -Throw
        }

        It 'DateTime を UnixTime に変換＋パラメータが範囲外' {
            { Convert-UnixTime -Target 16014780000000 -Reverse } | Should -Throw
        }

        It 'DateTime を UnixTime に変換＋パラメータが$null' {
            { Convert-UnixTime -Target $null -Reverse } | Should -Throw
        }
    }
}

Pop-Location
