#Requires -Version 5.1

<#
.SYNOPSIS
Batch conversion of the strings of file names in the selected folder.

.DESCRIPTION
Batch conversion of the strings of file names in the selected folder.

.EXAMPLE
Convert-FileName -Path 'C:\Work\test-1','C:\Work\test-2' -TargetString '_' -NewString '-' -Confirm:$false

.EXAMPLE
'C:\Work\test-1','C:\Work\test-2' | Convert-FileName -TargetString '_' -NewString '-' -Confirm:$false

.NOTES
Author: nekrassov01
#>

function Convert-FileName
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.IO.FileInfo[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetString,

        [Parameter(Position = 2, Mandatory = $true)]
        [AllowEmptyString()]
        [string]$NewString,

        [Parameter(Position = 3, Mandatory = $false)]
        [switch]$Recurse
    )

    begin
    {
        Set-StrictMode -Version Latest
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
                    $parentDir = Split-Path -Path $c.FullName -Parent
                    $newName = $c.Name -replace $targetString, $newString
                    $newFilePath = Join-Path -Path $parentDir -ChildPath $newName

                    if ($PSCmdlet.ShouldProcess($c.FullName))
                    {
                        $isValid = (
                                       ($null         -ne $targetString) -or `
                                       ($null         -ne $newString) -or `
                                       ($targetString -notin [System.IO.Path]::GetInvalidFileNameChars()) -or `
                                       ($newString    -notin [System.IO.Path]::GetInvalidFileNameChars()) -or `
                                       ($targetString -ne $newString) -or `
                                       ($c.FullName   -ne $newFilePath)
                                   )

                        if ($isValid)
                        {
                            $obj = Rename-Item -LiteralPath $c.FullName -NewName $newName -Force -PassThru -Confirm:$false -WhatIf:$false
                            $PSCmdlet.WriteObject($obj)
                        }
                        else
                        {
                            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                                [System.Management.Automation.PSArgumentException]::new(),
                                'InvalidConversion',
                                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                                $c
                            )
                            $PSCmdlet.ThrowTerminatingError($errorRecord)
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
