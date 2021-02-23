Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Convert-ScriptToBase64String' {

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
        $targetFile1 = New-Item -Path $env.Path[0] -Name 'test1.ps1' -ItemType File -Value 'Get-Service' -Force
        $targetFile2 = New-Item -Path $env.Path[0] -Name 'test2.ps1' -ItemType File -Value 'Get-Process' -Force
        $outputDir1  = Join-Path -Path $env.Path[0] -ChildPath 'output1'
        $outputDir2  = Join-Path -Path $env.Path[0] -ChildPath 'output2'
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '正常系' {

        It 'ベース' {
            Convert-ScriptToBase64String -Path $targetFile1 -Confirm:$false | Should -BeTrue
        }

        It 'ファイルパス複数指定' {
            Convert-ScriptToBase64String -Path $targetFile1, $targetFile2 -Confirm:$false | Should -BeTrue
        }

        It '出力先指定' {
            Convert-ScriptToBase64String -Path $targetFile1 -OutputDirectory (Join-Path -Path $env.Path[0] -ChildPath 'output1') -Confirm:$false | Should -BeTrue
        }

        It 'ファイルパス複数指定＋出力先指定' {
            Convert-ScriptToBase64String -Path $targetFile1, $targetFile2 -OutputDirectory $outputDir1 -Confirm:$false | Should -BeTrue
        }

        It '存在しない出力先フォルダーが指定された場合は作成される' {
            Convert-ScriptToBase64String -Path $targetFile1, $targetFile2 -OutputDirectory $outputDir2 -Confirm:$false | Should -BeTrue
        }

        It 'パイプで渡す' {
            $targetFile1, $targetFile2 | Convert-ScriptToBase64String -Confirm:$false | Should -BeTrue
        }
    }

    Context '異常系' {
    
        It '存在しない.ps1ファイル' {
            { Convert-ScriptToBase64String -Path (Join-Path -Path $env.Path[0] -ChildPath 'test9.ps1') -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
