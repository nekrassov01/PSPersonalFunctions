#Requires -Version 5.1

<#
.SYNOPSIS
Encode the PowerShell script to Base64 and convert it to a batch file.

.DESCRIPTION
Encode the PowerShell script to Base64 and convert it to a batch file.

.EXAMPLE
Convert-ScriptToBase64String -Path 'C:\Temp\test1.ps1', 'C:\Temp\test2.ps1'

.EXAMPLE
Convert-ScriptToBase64String -Path 'C:\Temp\test1.ps1', 'C:\Temp\test2.ps1' -Destination 'D:\output'

.EXAMPLE
Convert-ScriptToBase64String -Path 'C:\Temp\test1.ps1', 'C:\Temp\test2.ps1' -Destination 'D:\output' -Encoding default

.EXAMPLE
'C:\Temp\test1.ps1', 'C:\Temp\test2.ps1' | Convert-ScriptToBase64String

.EXAMPLE
'C:\Temp\test1.ps1', 'C:\Temp\test2.ps1' | Convert-ScriptToBase64String -Destination 'D:\output'

.EXAMPLE
'C:\Temp\test1.ps1', 'C:\Temp\test2.ps1' | Convert-ScriptToBase64String -Destination 'D:\output' -Encoding default

.NOTES
Author: nekrassov01
#>

function Convert-ScriptToBase64String
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Position = 1, Mandatory = $false)]
        [AllowNull()]
        [string]$OutputDirectory,

        [Parameter(Position = 2, Mandatory = $false)]
        [switch]$Recurse
    )

    dynamicParam
    {
        $dynamicParameter = @{
            Position = 2
            Mandatory = $false
            ValueFromPipeline = $false
            ValueFromPipelineByPropertyName = $false
            ValueFromRemainingArguments = $false
            ParameterSetName = '__AllParameterSets'
            HelpMessage = $false
            ParameterName = 'Encoding'
            ParameterType = [string]
            ValidateSet = { Get-CmdletParameterValidateSet -Command 'Out-File' -Parameter 'Encoding' }
        }

        New-DynamicParameter -DynamicParameter $dynamicParameter
    }

    begin
    {
        Set-StrictMode -Version Latest
        $encoding = $PSBoundParameters.Encoding = 'default'
    }

    process
    {
        try
        {
            foreach ($p in $path)
            {
                $childItem = switch ($PSBoundParameters.ContainsKey('Recurse'))
                {
                    $true  { Get-ChildItem -LiteralPath $p -File -Recurse }
                    $false { Get-ChildItem -LiteralPath $p -File }
                }

                foreach ($c in $childItem)
                {
                    if ([System.IO.Path]::GetExtension($c) -eq '.ps1')
                    {
                        if ($PSCmdlet.ShouldProcess($c.FullName))
                        {
                            if (-not $PSBoundParameters.ContainsKey('OutputDirectory'))
                            {
                                $OutputDirectory = [System.IO.Path]::GetDirectoryName($c.FullName)
                            }

                            if (-not (Test-Path -LiteralPath $OutputDirectory))
                            {
                                New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
                            }

                            $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($c.FullName)
                            $destinationPath = (Join-Path -Path $OutputDirectory -ChildPath $fileNameWithoutExtension) + '.bat'

                            $encode =  [System.Text.Encoding]::GetEncoding('utf-16')
                            $output =  '@echo off'
                            $output += [System.Environment]::NewLine
                            $output += 'PowerShell -NoProfile -ExecutionPolicy Unrestricted -EncodedCommand '
                            $output += [System.Convert]::ToBase64String($encode.GetBytes([System.IO.File]::ReadAllText($c.FullName)))

                            $output | Out-File -LiteralPath $destinationPath -Encoding $encoding -Confirm:$false -WhatIf:$false
                            $output = $null

                            $obj = [PSCustomObject]@{
                                PSScriptFile = $c.FullName
                                Base64EncodedFile = $destinationPath
                            }

                            $PSCmdlet.WriteObject($obj)
                        }
                    }
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
