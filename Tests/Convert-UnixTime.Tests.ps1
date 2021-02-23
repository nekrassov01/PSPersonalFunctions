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

    Context '����n' {

        It 'DateTime �� UnixTime �ɕϊ�' {
            Convert-UnixTime -Target '2020/10/01 0:0:0' | Should -BeTrue
        }

        It 'DateTime �� UnixTime �ɕϊ��{�p�C�v�œn��' {
            '2020/10/01 0:0:0' | Convert-UnixTime | Should -BeTrue
        }

        It '������ DateTime �� UnixTime �ɕϊ�' {
            Convert-UnixTime -Target '2020/10/01 0:0:0', '2020/11/01 0:0:0' | Should -BeTrue
        }

        It '������ DateTime �� UnixTime �ɕϊ��{�p�C�v�œn��' {
           '2020/10/01 0:0:0', '2020/11/01 0:0:0' | Convert-UnixTime | Should -BeTrue
        }

        It 'UnixTime �� DateTime �ɕϊ�' {
            Convert-UnixTime -Target 1601478000 -Reverse | Should -BeTrue
        }

        It 'UnixTime �� DateTime �ɕϊ��{�p�C�v�œn��' {
            1601478000 | Convert-UnixTime -Reverse | Should -BeTrue
        }

        It '������ UnixTime �� DateTime �ɕϊ�' {
            Convert-UnixTime -Target 1601478000, 1604156400 -Reverse | Should -BeTrue
        }

        It '������ UnixTime �� DateTime �ɕϊ��{�p�C�v�œn��' {
            1601478000, 1604156400 | Convert-UnixTime -Reverse | Should -BeTrue
        }
    }

    Context '�ُ�n' {

        It 'DateTime �� UnixTime �ɕϊ��{�p�����[�^���͈͊O' {
            { Convert-UnixTime -Target '0000/10/01 0:0:0' } | Should -Throw
        }

        It 'DateTime �� UnixTime �ɕϊ��{�p�����[�^��$null' {
            { Convert-UnixTime -Target $null } | Should -Throw
        }

        It 'DateTime �� UnixTime �ɕϊ��{�p�����[�^���͈͊O' {
            { Convert-UnixTime -Target 16014780000000 -Reverse } | Should -Throw
        }

        It 'DateTime �� UnixTime �ɕϊ��{�p�����[�^��$null' {
            { Convert-UnixTime -Target $null -Reverse } | Should -Throw
        }
    }
}

Pop-Location
