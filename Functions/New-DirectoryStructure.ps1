#Requires -Version 5.1

<#
.SYNOPSIS
Build directory structure based on Array List.

.DESCRIPTION
Build directory structure based on Array List.
You can only create directories.

.EXAMPLE
New-DirectoryStructure -Name 'folder-1', 'folder-2\sub-folder' -Root 'C:\Work'

.EXAMPLE
'folder-1', 'folder-2\sub-folder' | New-DirectoryStructure -Root 'C:\Work'

.NOTES
Author: nekrassov01
#>

function New-DirectoryStructure
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.IO.FileInfo[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [System.IO.FileInfo]$Root = $PSScriptRoot
    )

    begin
    {
        Set-StrictMode -Version Latest
    }

    process
    {
        try
        {
            foreach ($n in $name)
            {
                $target = Join-Path -Path $root -ChildPath $n

                if ($PSCmdlet.ShouldProcess($target))
                {
                    if (-not (Test-Path -Path $target))
                    {
                        $obj = New-Item -Path $target -ItemType Directory -Force -Confirm:$false -WhatIf:$false
                        $PSCmdlet.WriteObject($obj)
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
