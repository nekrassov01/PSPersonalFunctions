#Requires -Version 5.1

<#
.SYNOPSIS
Get the details of file properties using ComObject.

.DESCRIPTION
Get the details of file properties using ComObject.

.EXAMPLE
Get-ItemPropertyDetails -FilePath C:\Temp\image.jpg

.EXAMPLE
'C:\Temp\image.jpg' | Get-ItemPropertyDetails

.NOTES
Author: nekrassov01
#>

function Get-ItemPropertyDetails
{
    [CmdletBinding()]
    [OutputType([object[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$FilePath,

        [Parameter(Position = 1, Mandatory = $false)]
        [int]$LoopCount = 320
    )

    begin
    {
        try
        {
            Set-StrictMode -Version Latest

            if ($null -eq (Get-Variable -Name objShell -ErrorAction Ignore))
            {
                $objShell = New-Object -COMObject Shell.Application -ErrorAction Stop
            }

            $targetFolder = Split-Path -Path $filePath -Parent
            $targetFile = Split-Path -Path $filePath -Leaf

            $objShellFolder = $objShell.NameSpace($targetFolder)
            $objShellFile = $objShellFolder.ParseName($targetFile)

            1..$loopCount | ForEach-Object -Process {
                $obj = [PSCustomObject]@{
                    Index = $_
                    Name  = $objShellFolder.GetDetailsOf($Null, $_)
                    Value = $objShellFolder.GetDetailsOf($objShellFile, $_)
                }
            
                $PSCmdlet.WriteObject($obj)
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
        finally
        {
            # Clear the variable referring to __ComObject.
            Get-Variable | Where-Object -FilterScript { $_.Value -is [__ComObject]} | Clear-Variable -WhatIf:$false

            # Release __ComObject.
            $objShellFile, $objShellFolder, $objShell | ForEach-Object -Process {
                if ($null -ne $_)
                {
                    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($_)
                }
            }
        
            # When called by the parent, memory is not collected by this function. It will be collected by the parent.
            if ([system.string]::IsNullOrEmpty($MyInvocation.ScriptName))
            {
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
                1 | ForEach-Object -Process { $_ } | Out-Null
                [System.GC]::Collect()
            }
        }
    }
}
