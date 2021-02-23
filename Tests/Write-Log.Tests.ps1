Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Write-Log' {

    BeforeAll {
        $ErrorActionPreferenceOriginal = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '����n' {

        It '�p�����[�^�Ȃ�' {
            Write-Log | Should -BeTrue
        }

        It '�p�����[�^�w��A��������' {
            Write-Log -InputObject 'test' | Should -BeTrue
        }

        It '�p�����[�^�w��A�����Ȃ�' {
            Write-Log 'test' | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Status���w��' {
            Write-Log -InputObject 'test' -Prefix '# ' -Separator ' | ' -Suffix ',' -Status 'Started' | Should -BeTrue
        }

        It '���Prefix/Separator/Suffix/Status���w��' {
            Write-Log -InputObject 'test' -Prefix '' -Separator '' -Suffix '' -Status 'Completed' | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Status��$null�Ŏw��' {
            Write-Log -InputObject 'test' -Prefix $null -Separator $null -Suffix $null -Status $null | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Status���w��{GridLine' {
            Write-Log -InputObject 'test' -Prefix '# ' -Separator ' | ' -Suffix ',' -Status 'Started' -GridLine | Should -BeTrue
        }

        It '���Prefix/Separator/Suffix/Status���w��{GridLine' {
            Write-Log -InputObject 'test' -Prefix '' -Separator '' -Suffix '' -Status 'Completed' -GridLine | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Status��$null�Ŏw��{GridLine' {
            Write-Log -InputObject 'test' -Prefix $null -Separator $null -Suffix $null -Status $null -GridLine | Should -BeTrue
        }

        It '�z���n��' {
            Write-Log -InputObject @('a', 'b', 'c') | Should -BeTrue
        }

        It 'HashTable��n��' {
            Write-Log -InputObject (@{ a = '1'; b = '2'; c = '3' }) | Should -BeTrue
        }

        It 'PSCustomObject��n��' {
            Write-Log -InputObject ([PsCustomObject]@{ a = '1'; b = '2'; c = '3' }) | Should -BeTrue
        }

        It '�z��̗v�f��n��' {
            Write-Log -InputObject @('a', 'b', 'c')[0] | Should -BeTrue
        }

        It 'HashTable�̃L�[��n��' {
            Write-Log -InputObject ([ordered]@{ a = '1'; b = '2'; c = '3' }).Keys | Should -BeTrue
        }

        It 'HashTable�̃o�����[��n��' {
            Write-Log -InputObject ([ordered]@{ a = '1'; b = '2'; c = '3' }).Values | Should -BeTrue
        }

        It 'PSCustomObject�̃v���p�e�B��n��' {
            Write-Log -InputObject ([PsCustomObject]@{ a = '1'; b = '2'; c = '3' }).a | Should -BeTrue
        }

        It '��̈�����n��' {
            Write-Log -InputObject '' | Should -BeTrue
        }

        It '$null��n��' {
            Write-Log -InputObject $null | Should -BeTrue
        }

        It '���ׂẴt�H�[�}�b�g�n�p�����[�^��$null��n��' {
            Write-Log -InputObject $null -Prefix $null -Separator $null -Suffix $null -Status $null | Should -BeTrue
        }

        It '���t�t�H�[�}�b�g���w�肷��' {
            Write-Log -InputObject 'test' -DateTimeFormat 'yyyyMMddHHmmss' | Should -BeTrue
        }

        It '��̓��t�t�H�[�}�b�g���w�肷��' {
            Write-Log -InputObject 'test' -DateTimeFormat '' | Should -BeTrue
        }

        It '��̓��t�t�H�[�}�b�g��$null��n��' {
            Write-Log -InputObject 'test' -DateTimeFormat $null | Should -BeTrue
        }
    }
}

Pop-Location
