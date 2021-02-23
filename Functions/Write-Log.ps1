#Requires -Version 5.1

<#
.SYNOPSIS
Displays the date and time along with 'Write-Verbose'.

.DESCRIPTION
Displays the date and time along with 'Write-Verbose'.
The formatting is flexible.

.EXAMPLE
Write-Log -InputObject 'test'

.EXAMPLE
Write-Log 'test'

.EXAMPLE
Write-Log -InputObject 'test' -DateTimeFormat 'yyyy-MM-dd' -Prefix '# ' -Separator ' | ' -Suffix ' -LOG'

.EXAMPLE
Write-Log -InputObject 'Initialize settings.' -DateTimeFormat 'yyyy/MM/dd HH:mm:ss' -Prefix $null -Separator ' | ' -Status 'Completed'

.EXAMPLE
Write-Log -InputObject 'Load modules.' -Status 'Completed' -GridLine

.NOTES
Author: nekrassov01
#>

function Write-Log
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [psobject]$InputObject,

        [Parameter(Position = 1, Mandatory = $false)]
        [AllowNull()]
        [string]$DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',

        [Parameter(Position = 2, Mandatory = $false)]
        [AllowNull()]
        [string]$Prefix = '[',

        [Parameter(Position = 3, Mandatory = $false)]
        [AllowNull()]
        [string]$Separator = '] ',

        [Parameter(Position = 4, Mandatory = $false)]
        [AllowNull()]
        [string]$Suffix,

        [Parameter(Position = 5, Mandatory = $false)]
        [AllowNull()]
        [string]$Status,

        [Parameter(Position = 6, Mandatory = $false)]
        [AllowNull()]
        [switch]$GridLine
    )

    begin
    {
        $logTime = Get-Date -Format $dateTimeFormat
        $grid = New-Object -TypeName System.Collections.Generic.List[string]

        $length = switch ($PSBoundParameters['Status'])
        {
            $null
            {
                ([string]$InputObject).Length + $DateTimeFormat.Length + $Prefix.Length + $Separator.Length + $Suffix.Length
            }
            default
            {
                ([string]$InputObject).Length + $DateTimeFormat.Length + $Prefix.Length + $Separator.Length + $Suffix.Length + $status.ToString().Length + 2
            }
        }

        if (-not $Status)
        {
            $length = $length - 1
        }
        
        (1..$length).ForEach{ $grid.Add('-') }
        $grid = $grid -join $null

        $line = switch ($PSBoundParameters['Status'])
        {
            $null
            {
                $prefix, $logTime, $separator, $inputObject, $suffix -join $null
            }
            default
            {
                $prefix, $logTime, $separator, $inputObject, ': ', $Status, $suffix -join $null
            }
        }

        switch ($PSBoundParameters['GridLine'])
        {
            $null
            {
                $PSCmdlet.WriteObject($line)
            }
            default
            {
                $PSCmdlet.WriteObject($grid)
                $PSCmdlet.WriteObject($line)
                $PSCmdlet.WriteObject($grid)
            }
        }
    }
}
