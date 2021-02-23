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

    Context '正常系' {

        It 'ディレクトリ' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'dir1'; ItemType = 'Directory' } -Confirm:$false | Should -BeTrue
        }
        
        It 'ファイル' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test.bat'; ItemType = 'File'; ItemValue = '@echo off' } -Confirm:$false | Should -BeTrue
        }
        
        It 'ジャンクション' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'dir1-junction'; ItemType = 'Junction'; ItemValue = $targetDir } -Confirm:$false | Should -BeTrue
        }
        
        It 'ハードリンク' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test.bat-hardlink.bat'; ItemType = 'HardLink'; ItemValue = $targetFile } -Confirm:$false | Should -BeTrue
        }
        
        It 'シンボリックリンク:ファイル' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test.bat-symlink'; ItemType = 'SymbolicLink'; ItemValue = $targetFile } -Confirm:$false | Should -BeTrue
        }

        It 'シンボリックリンク:ディレクトリ' {
            New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'dir1-symlink'; ItemType = 'SymbolicLink'; ItemValue = $targetDir } -Confirm:$false | Should -BeTrue
        }
    }

    Context '異常系' {

        It '存在しないItemType' {
            { New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'test'; ItemType = 'test' } -Confirm:$false } | Should -Throw
        }

        It '同じディレクトリを作ろうとした場合は上書きする' {
            New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'dir1'; ItemType = 'Directory' }; [ordered]@{ Root = $env.Path[0]; Name = 'dir1'; ItemType = 'Directory' }) -Confirm:$false | Should -BeTrue
        }

        It '同じファイルを作ろうとした場合は上書きする' {
            New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'test.txt'; ItemType = 'File'; ItemValue = 'test1' }; [ordered]@{ Root = $env.Path[0]; Name = 'test.txt'; ItemType = 'File'; ItemValue = 'test2' }) -Confirm:$false | Should -BeTrue
        }

        It 'すでに存在するファイルと同名のディレクトリを作ろうとした場合は例外が発生する' {
             { New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'Directory' }; [ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'File'; ItemValue = 'test3' }; ) -Confirm:$false } | Should -Throw
        }

        It 'すでに存在するディレクトリと同名のファイルを作ろうとした場合は例外が発生する' {
             { New-DirectoryEnvironment @([ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'File'; ItemValue = 'test3' }; [ordered]@{ Root = $env.Path[0]; Name = 'item'; ItemType = 'Directory' }; ) -Confirm:$false } | Should -Throw
        }

        It 'ジャンクションをファイルにリンクしようとした場合は例外が発生する' {
             { New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'junction'; ItemType = 'Junction'; ItemValue = $targetFile } -Confirm:$false } | Should -Throw
        }

        It 'ハードリンクをディレクトリにリンクしようとした場合は例外が発生する' {
             { New-DirectoryEnvironment @{ Root = $env.Path[0]; Name = 'hardlink'; ItemType = 'HardLink'; ItemValue = $targetDir } -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
