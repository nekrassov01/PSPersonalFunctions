#Requires -Version 5.1

<#
.SYNOPSIS
Build a directory structure based on HashTable.

.DESCRIPTION
Build a directory structure based on HashTable.
You can select the item type from 'Directory', 'File', 'Junction', 'Hard Link' and 'Symbolic Link'.

.EXAMPLE
$env = @(
@{
    Root      = 'C:\Temp'
    Name      = 'folder'
    ItemType  = 'Directory'
}             
@{            
    Root      = 'C:\Temp'
    Name      = '.trigger'
    ItemType  = 'File'
}             
@{            
    Root      = 'C:\Temp\conf'
    Name      = 'init.bat'
    ItemType  = 'File'
    ItemValue = '@echo off'
}
@{
    Root      = 'C:\Temp'
    Name      = 'symlink1'
    ItemType  = 'SymbolicLink'
    ItemValue = 'C:\Temp\conf'
}             
@{            
    Root      = 'C:\Temp'
    Name      = 'symlink2'
    ItemType  = 'SymbolicLink'
    ItemValue = 'C:\Temp\conf\init.bat'
}             
@{            
    Root      = 'C:\Temp'
    Name      = 'junction'
    ItemType  = 'Junction'
    ItemValue = 'C:\Temp\conf'
}             
@{            
    Root      = 'C:\Temp'
    Name      = 'init.bat'
    ItemType  = 'HardLink'
    ItemValue = 'C:\Temp\conf\init.bat'
}
)
New-DirectoryEnvironment -Definition $env

.NOTES
Author: nekrassov01
#>

function New-DirectoryEnvironment
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.IO.FileInfo[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable[]]$Definition
    )

    begin
    {
        Set-StrictMode -Version Latest
        $isValid = @('Root', 'Name', 'ItemType', 'ItemValue')
    }

    process
    {
        try
        {
            foreach ($key in $definition.Keys)
            {
                if ($key -notin $isValid)
                {
                    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.Management.Automation.PSInvalidOperationException]::new(),
                        'InvalidHashKey',
                        [System.Management.Automation.ErrorCategory]::InvalidData,
                        $key
                    )
                    $PSCmdlet.ThrowTerminatingError($errorRecord)
                }
            }

            foreach ($def in $definition)
            {
                $target = Join-Path -Path $def.Root -ChildPath $def.Name

                if ($PSCmdlet.ShouldProcess($target))
                {
                    if ($def.ContainsKey('ItemValue'))
                    {
                        $itemValue = $def.ItemValue
                    }
                    else
                    {
                        $itemValue = $null
                    }
                    
                    $obj = New-Item -Path $target -ItemType $def.ItemType -Value $itemValue -Force -Confirm:$false -WhatIf:$false
                    $PSCmdlet.WriteObject($obj)
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
