#Requires -Version 5.1

<#
.SYNOPSIS
Run Bits Transfer jobs asynchronously with a simple syntax.

.DESCRIPTION
Run BitsTransfer jobs asynchronously with a single Cmdlet.
If the source contains directories, zip and transfer them.
If the destination directory does not exist, create it and then transfer it.

.EXAMPLE
Invoke-AutoBitsTransfer -Source C:\Temp\test1.txt, C:\Temp\test2.txt -Destination \\RemoteHost01\Destination, \\RemoteHost02\Destination -Priority High -Description 'This is Bits Test' -DisplayName 'Test Job 1'

.EXAMPLE
Invoke-AutoBitsTransfer -Source C:\Temp\folder1, C:\Temp\folder2 -Destination \\RemoteHost01\Destination, \\RemoteHost02\Destination -Priority High -Description 'This is Directories Transfer Test' -DisplayName 'Test Job 2' -IncludeDirectory

.NOTES
Author: nekrassov01
#>

function Invoke-AutoBitsTransfer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([Microsoft.BackgroundIntelligentTransfer.Management.BitsJob])]
    param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Source,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Destination,

        [Parameter(Position = 2, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [Parameter(Position = 3, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Position = 4, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName = 'Bits Transfer',

        [Parameter(Position = 5, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ProxyBypass,

        [Parameter(Position = 6, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$ProxyCredential,

        [Parameter(Position = 7, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [uri[]]$ProxyList,

        [Parameter(Position = 8, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int]$RetryInterval,

        [Parameter(Position = 9, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int]$RetryTimeout,

        [Parameter(Position = 10, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.BackgroundIntelligentTransfer.Management.CostStates]$TransferPolicy = 'NoSurcharge',

        [Parameter(Position = 11, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.BackgroundIntelligentTransfer.Management.AuthenticationTargetValue]$UseStoredCredential,

        [Parameter(Position = 12, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [switch]$IncludeDirectory
    )

    dynamicParam
    {
        $dynamicParameter = @(
            @{
                Position = 13
                Mandatory = $false
                ValueFromPipeline = $false
                ValueFromPipelineByPropertyName = $false
                ValueFromRemainingArguments = $false
                ParameterSetName = '__AllParameterSets'
                HelpMessage = $false
                ParameterName = 'Authentication'
                ParameterType = [string]
                ValidateSet = { Get-CmdletParameterValidateSet -Module 'BitsTransfer' -Command 'Start-BitsTransfer' -Parameter 'Authentication' }
            }
            @{
                Position = 14
                Mandatory = $false
                ValueFromPipeline = $false
                ValueFromPipelineByPropertyName = $false
                ValueFromRemainingArguments = $false
                ParameterSetName = '__AllParameterSets'
                HelpMessage = $false
                ParameterName = 'Priority'
                ParameterType = [string]
                ValidateSet = { Get-CmdletParameterValidateSet -Module 'BitsTransfer' -Command 'Start-BitsTransfer' -Parameter 'Priority' }
            }
            @{
                Position = 15
                Mandatory = $false
                ValueFromPipeline = $false
                ValueFromPipelineByPropertyName = $false
                ValueFromRemainingArguments = $false
                ParameterSetName = '__AllParameterSets'
                HelpMessage = $false
                ParameterName = 'ProxyAuthentication'
                ParameterType = [string]
                ValidateSet = { Get-CmdletParameterValidateSet -Module 'BitsTransfer' -Command 'Start-BitsTransfer' -Parameter 'ProxyAuthentication' }
            }
            @{
                Position = 16
                Mandatory = $false
                ValueFromPipeline = $false
                ValueFromPipelineByPropertyName = $false
                ValueFromRemainingArguments = $false
                ParameterSetName = '__AllParameterSets'
                HelpMessage = $false
                ParameterName = 'ProxyUsage'
                ParameterType = [string]
                ValidateSet = { Get-CmdletParameterValidateSet -Module 'BitsTransfer' -Command 'Start-BitsTransfer' -Parameter 'ProxyUsage' }
            }
            @{
                Position = 17
                Mandatory = $false
                ValueFromPipeline = $false
                ValueFromPipelineByPropertyName = $false
                ValueFromRemainingArguments = $false
                ParameterSetName = '__AllParameterSets'
                HelpMessage = $false
                ParameterName = 'TransferType'
                ParameterType = [string]
                ValidateSet = { Get-CmdletParameterValidateSet -Module 'BitsTransfer' -Command 'Start-BitsTransfer' -Parameter 'TransferType' }
            }
        )

        New-DynamicParameter -DynamicParameter $dynamicParameter
    }

    begin
    {
        try
        {
            if ($PSCmdlet.ShouldProcess($displayName))
            {
                Set-StrictMode -Version Latest

                $job = $null

                $excludeParams = @('IncludeDirectory')
                $cmdParams = ($PSCmdlet.MyInvocation.MyCommand.Parameters.Keys).Where{ $_ -notin $excludeParams }

                $param = @{ 'Asynchronous' = $true }

                # Bundle the parameters
                foreach ($cmdParam in $cmdParams)
                {
                    if ($PSBoundParameters.ContainsKey($cmdParam))
                    {
                        $param.Add($cmdParam, $PSBoundParameters[$cmdParam])
                    }
                }

                # If 'Priority' is not set, set it 'High'
                if (-not $PSBoundParameters.ContainsKey('Priority'))
                {
                    $param.Priority = 'High'
                }

                # If 'TransferPolicy' is not set, set it 'NoSurcharge'
                if (-not $PSBoundParameters.ContainsKey('TransferPolicy'))
                {
                    $param.TransferPolicy = 'NoSurcharge'
                }

                # If even one source does not exist, make it an exit error
                $source | ForEach-Object -Process {
                    if (-not (Test-Path -LiteralPath $_))
                    {
                        $message = [System.String]::Format('Cannot detect path ''{0}'' because it does not exist.', $_)

                        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                            [System.Management.Automation.ItemNotFoundException]::new($message),
                            'PathNotFound',
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                            $_
                        )
                        $PSCmdlet.ThrowTerminatingError($errorRecord)
                    }
                }

                # Use the 'IncludeDirectory' switch if you want to transfer directory with ZIP compression.
                if ($IncludeDirectory)
                {
                    $sourceWithZip = New-Object -TypeName System.Collections.Generic.List[string]

                    $source | ForEach-Object -Process {

                        if ((Get-Item -Path $_).PSIsContainer)
                        {
                            if (Get-ChildItem -Path $_)
                            {
                                Compress-Archive -Path $_ -DestinationPath $_ -Force
                                $sourceWithZip.Add('{0}.zip' -f $_)
                            }
                            else
                            {
                                $message = 'Cannot compress empty directory'

                                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                                    [System.Management.Automation.PSInvalidOperationException]::new($message),
                                    'DirectoryIsEmpty',
                                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                                    $_
                                )
                                $PSCmdlet.ThrowTerminatingError($errorRecord)
                            }
                        }
                        else
                        {
                            $sourceWithZip.Add($_)
                        }
                    }

                    $param.Source = $sourceWithZip
                }

                # If the destination parent folder does not exist, create it
                $destination | ForEach-Object -Process {
                    if ($null -ne $_)
                    {
                        $targetDir = Split-Path -Path $_ -Parent
                        if ((-not (Test-Path -Path $_)) -and (-not (Test-Path -Path $targetDir)))
                        {
                            Invoke-Item -Path $targetDir -ItemType Directory -Force | Out-Null
                        }
                    }
                }

                Write-Progress -Activity $displayName -Status 'transferring...'

                # Start the transfer with the passed parameters
                $job = Start-BitsTransfer @param -Confirm:$false -WhatIf:$false

                # Wait for job transfer to complete
                while ($job.JobState -ne 'Transferred')
                {
                    Start-Sleep -Milliseconds 5
                }

                # Return the object before the job is completed
                $obj = $job | Select-Object -Property *
                $PSCmdlet.WriteObject($obj)

                # If the source contains directories, delete the local zip file
                $param.Source | ForEach-Object -Process {

                    if ([System.IO.Path]::GetExtension($_) -eq '.zip')
                    {
                        Remove-Item -Path $_ -Force
                    }
                }

                # Complete the job
                $job | Complete-BitsTransfer -Confirm:$false -WhatIf:$false
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
        finally
        {
            if (($null -ne $job) -and (Get-BitsTransfer -JobId $job.JobId -ErrorAction Ignore))
            {
                $job | Remove-BitsTransfer
            }
        }
    }
}
