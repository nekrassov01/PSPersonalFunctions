Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Convert-FileContent' {

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
        $testFolder1 = Join-Path -Path $env.Path[0] -ChildPath 'grep-test1'
        $testFolder2 = Join-Path -Path $env.Path[0] -ChildPath 'grep-test2'
        $testFolder1, $testFolder2 | ForEach-Object -Process {
            $testFolder = (New-Item -Path $_ -ItemType Directory -Force).FullName
            1..3 | ForEach-Object -Process { New-Item -Path $testFolder -Name ([System.String]::Format('test-{0}.txt', $_.ToString('00'))) -Value "test-1`r`ntest-2`r`ntest-3`r`ntest-4`r`ntest-5`r`n" -Force }
            1..3 | ForEach-Object -Process { New-Item -Path $testFolder -Name ([System.String]::Format('test-{0}.bat', $_.ToString('00'))) -Value "test-1`r`ntest-2`r`ntest-3`r`ntest-4`r`ntest-5`r`n" -Force }
            1..3 | ForEach-Object -Process { New-Item -Path $testFolder -Name ([System.String]::Format('test-{0}.ps1', $_.ToString('00'))) -Value "test-1`r`ntest-2`r`ntest-3`r`ntest-4`r`ntest-5`r`n" -Force }
            1..3 | ForEach-Object -Process { New-Item -Path $testFolder -Name ([System.String]::Format('test-{0}.exe', $_.ToString('00'))) -Value "test-1`r`ntest-2`r`ntest-3`r`ntest-4`r`ntest-5`r`n" -Force }
            1..3 | ForEach-Object -Process { New-Item -Path $testFolder -Name ([System.String]::Format('test-{0}.zip', $_.ToString('00'))) -Value "test-1`r`ntest-2`r`ntest-3`r`ntest-4`r`ntest-5`r`n" -Force }
        }
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '正常系' {

        It 'Include で拡張子を指定' {
            Convert-FileContent -Path $testFolder1 -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
            Convert-FileContent -Path $testFolder1 -TargetString '_' -NewString '-' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
        }

        It 'Include で拡張子を指定＋複数フォルダ' {
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '_' -NewString '-' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
        }

        It 'Include で拡張子を指定＋複数フォルダ＋Rawスイッチ' {
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Raw -Confirm:$false | Should -BeTrue
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '_' -NewString '-' -IncludeExtension '.txt', '.bat' -Raw -Confirm:$false | Should -BeTrue
        }

        It 'Exclude で拡張子を指定' {
            Convert-FileContent -Path $testFolder1 -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
            Convert-FileContent -Path $testFolder1 -TargetString '_' -NewString '-' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
        }

        It 'Exclude で拡張子を指定＋複数フォルダ' {
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '_' -NewString '-' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
        }

        It 'Exclude で拡張子を指定＋複数フォルダ＋Rawスイッチ' {
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Raw -Confirm:$false | Should -BeTrue
            Convert-FileContent -Path $testFolder1, $testFolder2 -TargetString '_' -NewString '-' -ExcludeExtension '.exe', '.zip' -Raw -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋Include で拡張子を指定' {
            $testFolder1 | Convert-FileContent -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
            $testFolder1 | Convert-FileContent -TargetString '_' -NewString '-' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋Include で拡張子を指定＋複数フォルダ' {
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '_' -NewString '-' -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋Include で拡張子を指定＋複数フォルダ＋Rawスイッチ' {
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Raw -Confirm:$false | Should -BeTrue
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '_' -NewString '-' -IncludeExtension '.txt', '.bat' -Raw -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋Exclude で拡張子を指定' {
            $testFolder1 | Convert-FileContent -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
            $testFolder1 | Convert-FileContent -TargetString '_' -NewString '-' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋Exclude で拡張子を指定＋複数フォルダ' {
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '_' -NewString '-' -ExcludeExtension '.exe', '.zip' -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す＋Exclude で拡張子を指定＋複数フォルダ＋Rawスイッチ' {
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Raw -Confirm:$false | Should -BeTrue
            $testFolder1, $testFolder2 | Convert-FileContent -TargetString '_' -NewString '-' -ExcludeExtension '.exe', '.zip' -Raw -Confirm:$false | Should -BeTrue
        }
    }

    Context '異常系' {

        It 'NewString が $null の場合は文字を削除する動作になる' {
            Convert-FileContent -Path $testFolder1 -TargetString '-' -NewString $null -IncludeExtension '.txt', '.bat' -Confirm:$false | Should -BeTrue
        }

        It 'TaragetString が $null の場合は例外が発生' {
            { Convert-FileContent -Path $testFolder1 -TargetString $null -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
