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

    Context '正常系' {

        It '通常' {
            New-DirectoryStructure -Name 'test1' -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It '複数' {
            New-DirectoryStructure -Name 'test2', 'test3' -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It 'サブフォルダまで貫通させる' {
            New-DirectoryStructure -Name 'test1\sub' -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す' {
            'test4' | New-DirectoryStructure -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋複数' {
            'test5', 'test6' | New-DirectoryStructure -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋サブフォルダまで貫通させる' {
            'test2\sub' | New-DirectoryStructure -Root $env.Path[0] -Confirm:$false | Should -BeTrue
        }

        It 'すでに存在するフォルダを作ろうとすると$nullが返る' {
            New-DirectoryStructure -Name 'test1' -Root $env.Path[0] -Confirm:$false | Should -BeNullOrEmpty
        }
    }

    Context '異常系' {

        It 'ワイルドカードを指定' {
            New-DirectoryStructure -Name '*' -Root $env.Path[0] -Confirm:$false | Should -BeNullOrEmpty
        }

        It 'パスに使えない文字' {
            { New-DirectoryStructure -Name ':' -Root $env.Path[0] -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
