Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'New-DirectoryEnvironment' {

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

        $targetDir = Join-Path -Path $env.Path[0] 'dir1'
        $targetFile = Join-Path -Path $env.Path[0] 'test.bat'
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '����n' {

        It '�f�B���N�g��' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'dir1'; ItemType = 'Directory' } -Confirm:$false | Should -BeTrue
        }
        
        It '�t�@�C��' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test.bat'; ItemType = 'File'; ItemValue = '@echo off' } -Confirm:$false | Should -BeTrue
        }
        
        It '�W�����N�V����' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'dir1-junction'; ItemType = 'Junction'; ItemValue = $targetDir } -Confirm:$false | Should -BeTrue
        }
        
        It '�n�[�h�����N' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test.bat-hardlink.bat'; ItemType = 'HardLink'; ItemValue = $targetFile } -Confirm:$false | Should -BeTrue
        }
        
        It '�V���{���b�N�����N:�t�@�C��' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test.bat-symlink'; ItemType = 'SymbolicLink'; ItemValue = $targetFile } -Confirm:$false | Should -BeTrue
        }

        It '�V���{���b�N�����N:�f�B���N�g��' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'dir1-symlink'; ItemType = 'SymbolicLink'; ItemValue = $targetDir } -Confirm:$false | Should -BeTrue
        }
    }

    Context '�ُ�n' {

        It '���݂��Ȃ�ItemType' {
            { New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test'; ItemType = 'test' } -Confirm:$false } | Should -Throw
        }

        It '�����f�B���N�g������낤�Ƃ����ꍇ�͏㏑������' {
            New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'dir1'; ItemType = 'Directory' }; [ordered]@{ Root = $env.Path[0]; Name = 'dir1'; ItemType = 'Directory' }) -Confirm:$false | Should -BeTrue
        }

        It '�����t�@�C������낤�Ƃ����ꍇ�͏㏑������' {
            New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'test.txt'; ItemType = 'File'; ItemValue = 'test1' }; [ordered]@{ Root = $env.Path[0]; Name = 'test.txt'; ItemType = 'File'; ItemValue = 'test2' }) -Confirm:$false | Should -BeTrue
        }

        It '���łɑ��݂���t�@�C���Ɠ����̃f�B���N�g������낤�Ƃ����ꍇ�͗�O����������' {
             { New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'Directory' }; [ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'File'; ItemValue = 'test3' }; ) -Confirm:$false } | Should -Throw
        }

        It '���łɑ��݂���f�B���N�g���Ɠ����̃t�@�C������낤�Ƃ����ꍇ�͗�O����������' {
             { New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'File'; ItemValue = 'test3' }; [ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'Directory' }; ) -Confirm:$false } | Should -Throw
        }

        It '�W�����N�V�������t�@�C���Ƀ����N���悤�Ƃ����ꍇ�͗�O����������' {
             { New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'junction'; ItemType = 'Junction'; ItemValue = $targetFile } -Confirm:$false } | Should -Throw
        }

        It '�n�[�h�����N���f�B���N�g���Ƀ����N���悤�Ƃ����ꍇ�͗�O����������' {
             { New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'hardlink'; ItemType = 'HardLink'; ItemValue = $targetDir } -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
