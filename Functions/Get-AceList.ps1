#Requires -Version 5.1

<#
.SYNOPSIS
Lists the properties of each ACE, including the properties of its parent ACL.

.DESCRIPTION
Lists the properties of each ACE, including the properties of its parent ACL.
 - Output objects are optimized for CSV format.
 - Select the property you want to expand from 'Access' or 'Audit'.

.EXAMPLE
Get-AceList -Path C:\Temp, C:\Work

.EXAMPLE
Get-AceList -Path C:\Temp, C:\Work -Audit

.EXAMPLE
'C:\Temp', 'C:\Work' | Get-AceList

.EXAMPLE
'C:\Temp', 'C:\Work' | Get-AceList -Audit

.NOTES
Author: nekrassov01
#>

function Get-AceList
{
    [CmdletBinding(DefaultParameterSetName = 'Access')]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Position = 1, Mandatory = $false, ParameterSetName = 'Access')]
        [ValidateNotNullOrEmpty()]
        [switch]$Access,

        [Parameter(Position = 1, Mandatory = $false, ParameterSetName = 'Audit')]
        [ValidateNotNullOrEmpty()]
        [switch]$Audit
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
                $parent = Get-Acl -LiteralPath $p -Audit

                $parent | Select-Object -ExpandProperty $PSCmdlet.ParameterSetName -PipelineVariable child | ForEach-Object -Process {
                
                    $obj = [PSCustomObject]@{}

                    $parent | Get-Member Path, Group, Owner | ForEach-Object -Process {
                        $obj | Add-Member -MemberType NoteProperty -Name $_.Name -Value $parent.$($_.Name)
                    }

                    $child | Get-Member -MemberType Properties | ForEach-Object -Process {
                        $obj | Add-Member -MemberType NoteProperty -Name $_.Name -Value $child.$($_.Name)
                    }

                    $obj.Path = $p

                    $obj = switch ($PSCmdlet.ParameterSetName)
                    {
                        'Access'
                        {
                            $obj | Select-Object -Property Path, Group, Owner, AccessControlType, IdentityReference, FileSystemRights, InheritanceFlags, IsInherited, PropagationFlags
                        }
                        'Audit'
                        {
                            $obj | Select-Object -Property Path, Group, Owner, AuditFlags, IdentityReference, FileSystemRights, InheritanceFlags, IsInherited, PropagationFlags
                        }
                    }
                
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
