#
# ���W���[�� 'PSPersonalFunctions' �̃��W���[�� �}�j�t�F�X�g
#
# ������: nekrassov01
#
# ������: 2021/02/20
#

@{

# ���̃}�j�t�F�X�g�Ɋ֘A�t�����Ă���X�N���v�g ���W���[�� �t�@�C���܂��̓o�C�i�� ���W���[�� �t�@�C���B
RootModule = 'PSPersonalFunctions.psm1'

# ���̃��W���[���̃o�[�W�����ԍ��ł��B
ModuleVersion = '0.1.0.0'

# �T�|�[�g����Ă��� PSEditions
# CompatiblePSEditions = @()

# ���̃��W���[������ӂɎ��ʂ��邽�߂Ɏg�p����� ID
GUID = 'b756a832-66e7-4773-a495-7b1e5c34c7ca'

# ���̃��W���[���̍쐬��
Author = 'nekrassov01'

# ���̃��W���[���̉�Ђ܂��̓x���_�[
CompanyName = 'nekrassov01'

# ���̃��W���[���̒��쌠���
Copyright = '(c) nekrassov01 All rights reserved.'

# ���̃��W���[���̋@�\�̐���
Description = 'A collection of personal functions.'

# ���̃��W���[���ɕK�v�� Windows PowerShell �G���W���̍ŏ��o�[�W����
PowerShellVersion = '5.1'

# ���̃��W���[���ɕK�v�� Windows PowerShell �z�X�g�̖��O
# PowerShellHostName = ''

# ���̃��W���[���ɕK�v�� Windows PowerShell �z�X�g�̍ŏ��o�[�W����
# PowerShellHostVersion = ''

# ���̃��W���[���ɕK�v�� Microsoft .NET Framework �̍ŏ��o�[�W�����B ���̑O������́APowerShell Desktop �G�f�B�V�����ɂ��Ă̂ݗL���ł��B
DotNetFrameworkVersion = '4.5'

# ���̃��W���[���ɕK�v�ȋ��ʌ��ꃉ���^�C�� (CLR) �̍ŏ��o�[�W�����B ���̑O������́APowerShell Desktop �G�f�B�V�����ɂ��Ă̂ݗL���ł��B
CLRVersion = '4.0.0.0'

# ���̃��W���[���ɕK�v�ȃv���Z�b�T �A�[�L�e�N�`�� (�Ȃ��AX86�AAmd64)
# ProcessorArchitecture = ''

# ���̃��W���[�����C���|�[�g����O�ɃO���[�o�����ɃC���|�[�g����Ă���K�v�����郂�W���[��
RequiredModules = @('BitsTransfer', 
               'Microsoft.PowerShell.Archive')

# ���̃��W���[�����C���|�[�g����O�ɓǂݍ��܂�Ă���K�v������A�Z���u��
# RequiredAssemblies = @()

# ���̃��W���[�����C���|�[�g����O�ɌĂяo�����̊��Ŏ��s�����X�N���v�g �t�@�C�� (.ps1)�B
# ScriptsToProcess = @()

# ���̃��W���[�����C���|�[�g����Ƃ��ɓǂݍ��܂��^�t�@�C�� (.ps1xml)
# TypesToProcess = @()

# ���̃��W���[�����C���|�[�g����Ƃ��ɓǂݍ��܂�鏑���t�@�C�� (.ps1xml)
# FormatsToProcess = @()

# RootModule/ModuleToProcess �Ɏw�肳��Ă��郂�W���[���̓���q�ɂȂ������W���[���Ƃ��ăC���|�[�g���郂�W���[��
# NestedModules = @()

# ���̃��W���[������G�N�X�|�[�g����֐��ł��B�œK�ȃp�t�H�[�}���X�𓾂�ɂ́A���C���h�J�[�h���g�p�����A�G�N�X�|�[�g����֐����Ȃ��ꍇ�́A�G���g�����폜���Ȃ��ŋ�̔z����g�p���Ă��������B
FunctionsToExport = 'Convert-FileContent', 'Convert-FileName', 
               'Convert-ScriptToBase64String', 'Convert-SID', 'Convert-UnixTime', 
               'Get-AceList', 'Get-ItemPropertyDetails', 'Invoke-AsyncExecution', 
               'Invoke-AutoBitsTransfer', 'New-DirectoryEnvironment', 
               'New-DirectoryStructure', 'Remove-UserProfile', 
               'Remove-ZoneIdentifier', 'Reset-ItemPropertyTime', 'Write-Log', 
               'Get-CmdletParameterValidateSet', 'New-DynamicParameter'

# ���̃��W���[������G�N�X�|�[�g����R�}���h���b�g�ł��B�œK�ȃp�t�H�[�}���X�𓾂�ɂ́A���C���h�J�[�h���g�p�����A�G�N�X�|�[�g����R�}���h���b�g���Ȃ��ꍇ�́A�G���g�����폜���Ȃ��ŋ�̔z����g�p���Ă��������B
CmdletsToExport = '*'

# ���̃��W���[������G�N�X�|�[�g����ϐ�
VariablesToExport = '*'

# ���̃��W���[������G�N�X�|�[�g����G�C���A�X�ł��B�œK�ȃp�t�H�[�}���X�𓾂�ɂ́A���C���h�J�[�h���g�p�����A�G�N�X�|�[�g����G�C���A�X���Ȃ��ꍇ�́A�G���g�����폜���Ȃ��ŋ�̔z����g�p���Ă��������B
AliasesToExport = '*'

# ���̃��W���[������G�N�X�|�[�g���� DSC ���\�[�X
# DscResourcesToExport = @()

# ���̃��W���[���ɓ�������Ă��邷�ׂẴ��W���[���̃��X�g
# ModuleList = @()

# ���̃��W���[���ɓ�������Ă��邷�ׂẴt�@�C���̃��X�g
# FileList = @()

# RootModule/ModuleToProcess �Ɏw�肳��Ă��郂�W���[���ɓn���v���C�x�[�g �f�[�^�B����ɂ́APowerShell �Ŏg�p�����ǉ��̃��W���[�� ���^�f�[�^���܂� PSData �n�b�V���e�[�u�����܂܂��ꍇ������܂��B
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# ���̃��W���[���� HelpInfo URI
# HelpInfoURI = ''

# ���̃��W���[������G�N�X�|�[�g���ꂽ�R�}���h�̊���̃v���t�B�b�N�X�B����̃v���t�B�b�N�X���I�[�o�[���C�h����ꍇ�́AImport-Module -Prefix ���g�p���܂��B
# DefaultCommandPrefix = ''

}

