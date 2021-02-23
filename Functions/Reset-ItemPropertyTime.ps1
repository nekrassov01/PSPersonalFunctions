#Requires -Version 5.1

<#
.SYNOPSIS
Reset the timestamp of the file or folder.

.DESCRIPTION
Reset the timestamp of the file or folder.
You can select properties from 'CreationTime', 'LastWriteTime' and 'LastAccessTime'. The default parameter is 'CreationTime'.
You can select the time unit from Year, Month, Day, Hour, Minute, Second, Millisecond or directly select DateTime.

.EXAMPLE
Reset-ItemPropertyTime -Path 'C:\test\folder\file1.txt', 'C:\test\folder\file2.txt' -Property LastWriteTime -RollbackYear 5

.EXAMPLE
Reset-ItemPropertyTime -Path 'C:\test\folder1', 'C:\test\folder2' -Property CreationTime -RollbackDay 365 -Recurse -Confirm:$false

.EXAMPLE
'C:\test\folder1', 'C:\test\folder2' | Reset-ItemPropertyTime -Property LastAccessTime -RollbackHour 3 -Confirm:$false

.EXAMPLE
'C:\test\folder1', 'C:\test\folder2' | Reset-ItemPropertyTime -Property LastAccessTime -RollbackDateTime '2020/1/1 0:0:0' -Recurse -Confirm:$false

.NOTES
Author: nekrassov01
#>

function Reset-ItemPropertyTime
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Day')]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('CreationTime', 'LastWriteTime', 'LastAccessTime')]
        [string]$Property = 'CreationTime',

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Year')]
        [int]$RollbackYear,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Month')]
        [int]$RollbackMonth,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Day')]
        [int]$RollbackDay,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Hour')]
        [int]$RollbackHour,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Minute')]
        [int]$RollbackMinute,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Second')]
        [int]$RollbackSecond,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Millisecond')]
        [int]$RollbackMillisecond,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'DateTime')]
        [string]$RollbackDateTime,

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
                $target = switch ($PSBoundParameters.ContainsKey('Recurse'))
                {
                    $true  { Get-ChildItem -LiteralPath $p -Recurse }
                    $false { Get-ChildItem -LiteralPath $p }
                }

                foreach ($t in $target)
                {
                    $beforeRollback = $t.$property

                    $afterRollback = switch ($PSCmdlet.ParameterSetName)
                    {
                        'Year'        { $beforeRollback.AddYears(-$rollbackYear) }
                        'Month'       { $beforeRollback.AddMonths(-$rollbackMonth) }
                        'Day'         { $beforeRollback.AddDays(-$rollbackDay) }
                        'Hour'        { $beforeRollback.AddHours(-$rollbackHour) }
                        'Minute'      { $beforeRollback.AddMinutes(-$rollbackMinute) }
                        'Second'      { $beforeRollback.AddSeconds(-$rollbackSecond) }
                        'Millisecond' { $beforeRollback.AddMilliseconds(-$rollbackMillisecond) }
                        'DateTime'    { [datetime]$RollbackDateTime }
                    }

                    if ($PSCmdlet.ShouldProcess($t.FullName))
                    {
                        $obj = Set-ItemProperty -LiteralPath $t.FullName -Name $property -Value $afterRollback -PassThru -Confirm:$false -WhatIf:$false                
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
