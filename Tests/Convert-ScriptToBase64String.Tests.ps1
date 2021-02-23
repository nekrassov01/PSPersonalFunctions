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

    Context '����n' {

        It '�x�[�X' {
            Convert-ScriptToBase64String -Path $targetFile1 -Confirm:$false | Should -BeTrue
        }

        It '�t�@�C���p�X�����w��' {
            Convert-ScriptToBase64String -Path $targetFile1, $targetFile2 -Confirm:$false | Should -BeTrue
        }

        It '�o�͐�w��' {
            Convert-ScriptToBase64String -Path $targetFile1 -OutputDirectory (Join-Path -Path $env.Path[0] -ChildPath 'output1') -Confirm:$false | Should -BeTrue
        }

        It '�t�@�C���p�X�����w��{�o�͐�w��' {
            Convert-ScriptToBase64String -Path $targetFile1, $targetFile2 -OutputDirectory $outputDir1 -Confirm:$false | Should -BeTrue
        }

        It '���݂��Ȃ��o�͐�t�H���_�[���w�肳�ꂽ�ꍇ�͍쐬�����' {
            Convert-ScriptToBase64String -Path $targetFile1, $targetFile2 -OutputDirectory $outputDir2 -Confirm:$false | Should -BeTrue
        }

        It '�p�C�v�œn��' {
            $targetFile1, $targetFile2 | Convert-ScriptToBase64String -Confirm:$false | Should -BeTrue
        }
    }

    Context '�ُ�n' {
    
        It '���݂��Ȃ�.ps1�t�@�C��' {
            { Convert-ScriptToBase64String -Path (Join-Path -Path $env.Path[0] -ChildPath 'test9.ps1') -Confirm:$false } | Should -Throw
        }
    }
}

Pop-Location
