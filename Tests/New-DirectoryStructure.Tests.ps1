Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'New-DirectoryStructure' {

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
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '����n' {

        It '�ʏ�' {
            New-DirectoryStructure -Name 'test1' -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '����' {
            New-DirectoryStructure -Name 'test2', 'test3' -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '�T�u�t�H���_�܂Ŋђʂ�����' {
            New-DirectoryStructure -Name 'test1\sub' -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '�p�C�v�œn��' {
            'test4' | New-DirectoryStructure -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '�p�C�v�œn���{����' {
            'test5', 'test6' | New-DirectoryStructure -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '�p�C�v�œn���{�T�u�t�H���_�܂Ŋђʂ�����' {
            'test2\sub' | New-DirectoryStructure -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '���łɑ��݂���t�H���_����낤�Ƃ����$null���Ԃ�' {
            New-DirectoryStructure -Name 'test1' -Root $env.Path[0] -Confirm:$false | Should -BeNullOrEmpty
        }
    }

    Context '�ُ�n' {

        It '���C���h�J�[�h���w��' {
            New-DirectoryStructure -Name '*' -Root $env.Path[0] -Confirm:$false | Should -BeNullOrEmpty
        }

        It '�p�X�Ɏg���Ȃ�����' {
            { New-DirectoryStructure -Name ':' -Root $env.Path[0] -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
