Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Convert-SID' {
    
    BeforeAll {
        $ErrorActionPreferenceOriginal = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

        # Parameters for Tests    
        $env = Get-Content -Path .\.env | ConvertFrom-Json
    }
    
    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }
    
    Context '����n' {
        
        It '�ʏ�' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env.UserDomain[0], $env.UserName[0])) | Should -BeTrue
        }
        
        It '�h���C���\�L�̏ȗ�' {
            Convert-SID -Target $env.UserName[0] | Should -BeTrue
        }
        
        It '����' {
            Convert-SID -Target $env.UserName[0], $env.UserName[1] | Should -BeTrue
        }

        It '�p�C�v�œn��' {
            $env.UserName[0] | Convert-SID | Should -BeTrue
        }

        It '�p�C�v�œn���{����' {
            $env.UserName[0], ([System.String]::Format('{0}\{1}', $env:USERDOMAIN, $env.UserName[0])) | Convert-SID | Should -BeTrue
        }

        It '�����[�g�R���s���[�^�[' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env.ComputerName[0], $env.UserName[0])) -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It '�����[�g�R���s���[�^�[�{�h���C���\�L�̏ȗ�' {
            Convert-SID -Target $env.UserName[0] -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It '�����[�g�R���s���[�^�[�{�h���C���\�L�̏ȗ��{����' {
            Convert-SID -Target $env.UserName[0], $env.UserName[1] -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It '�����[�g�R���s���[�^�[�{�p�C�v�œn��' {
            $env.UserName[0] | Convert-SID -ComputerName $env.ComputerName[0] | Should -BeTrue
        }

        It '�����[�g�R���s���[�^�[�{�p�C�v�œn���{����' {
            $env.UserName[0], ([System.String]::Format('{0}\{1}', $env.ComputerName[0], $env.UserName[1])) | Convert-SID -ComputerName $env.ComputerName[0] | Should -BeTrue
        }
    }

    Context '�ُ�n' {

        It '���݂��Ȃ����[�U�[�̏ꍇ$null���Ԃ�' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env.ComputerName[0], 'InvaliddUser')) | Should -BeNullOrEmpty
        }

        It '���݂��Ȃ��h���C���̏ꍇ$null���Ԃ�' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', 'InvalidDomain', $env.UserName[0])) | Should -BeNullOrEmpty
        }

        It '���[�J���R���s���[�^�[�̃��[�J���A�J�E���g�Ń����[�g�R���s���[�^�[��SID���擾���悤�Ƃ����ꍇ$null���Ԃ�' {
            Convert-SID -Target ([System.String]::Format('{0}\{1}', $env:COMPUTERNAME, $env.UserName[0])) -ComputerName $env.ComputerName[0] | Should -BeNullOrEmpty
        }
    }
}

Pop-Location
