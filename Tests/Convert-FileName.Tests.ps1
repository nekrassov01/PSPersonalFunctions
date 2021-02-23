Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Convert-FileName' {

    BeforeAll {
        $ErrorActionPreferenceOriginal = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

        # Parameters for Tests
        $env = Get-Content -Path .\.env | ConvertFrom-Json

        # Force Cleanup
        $targetItems = Get-ChildItem -Path $env.Path[0]

        try
        {
            $targetItems.Delete($true)
        }
        catch
        {
            $targetItems | Remove-Item -Recurse -Force -ErrorAction Ignore
        }

        # Create target files
        $testFolder1 = Join-Path -Path $env.Path[0] -ChildPath 'rename-test1'
        $testFolder2 = Join-Path -Path $env.Path[0] -ChildPath 'rename-test2'
        $testFolder1, $testFolder2 | ForEach-Object -Process {
            $testFolder = (New-Item -Path $_ -ItemType Directory -Force).FullName
            1..10 | ForEach-Object -Process { New-Item -Path $testFolder -Name ([System.String]::Format('test-{0}.txt', $_.ToString('00'))) -Force }
        }
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '����n' {

        It '��{' {
            Convert-FileName -Path $testFolder1 -TargetString '-' -NewString '_' -Confirm:$false | Should -BeTrue
        }

        It '����' {
            Convert-FileName -Path $testFolder1, $testFolder2 -TargetString '_' -NewString '-' -Confirm:$false | Should -BeTrue
        }

        It 'TargetString��NewString������̏ꍇ�͓ǂݔ�΂�' {
            Convert-FileName -Path $testFolder1, $testFolder2 -TargetString '_' -NewString '_' -Confirm:$false | Should -BeTrue
        }

        It 'TargetString���t�@�C�����Ɋ܂܂�Ă��Ȃ��ꍇ�͓ǂݔ�΂�' {
            Convert-FileName -Path $testFolder1, $testFolder2 -TargetString 'abcdefg' -NewString '_' -Confirm:$false | Should -BeTrue
        }

        It 'NewString����ł�����ɒu������' {
            Convert-FileName -Path $testFolder1, $testFolder2 -TargetString '-' -NewString '' -Confirm:$false | Should -BeTrue
        }

        It 'NewString��`$null�ł�����ɒu������' {
            Convert-FileName -Path $testFolder1, $testFolder2 -TargetString '-' -NewString $null -Confirm:$false | Should -BeTrue
        }

    }

    Context '�ُ�n' {

        It 'TargetString�Ƀp�X�Ŏg�p�ł��Ȃ��������w�肵���ꍇ�͗�O����������' {
            { Convert-FileName -Path $testFolder1, $testFolder2 -TargetString '*' -NewString '_' -Confirm:$false } | Should -Throw
        }

        It 'NewString�Ƀp�X�Ŏg�p�ł��Ȃ��������w�肵���ꍇ�͗�O����������' {
            { Convert-FileName -Path $testFolder1, $testFolder2 -TargetString 'test' -NewString '*' -Confirm:$false } | Should -Throw
        }

        It 'TargetString����̏ꍇ�͗�O����������' {
            { Convert-FileName -Path $testFolder1, $testFolder2 -TargetString '' -NewString '_' -Confirm:$false } | Should -Throw
        }

        It 'TargetString��`$null�̏ꍇ�͗�O����������' {
            { Convert-FileName -Path $testFolder1, $testFolder2 -TargetString $null -NewString '_' -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
