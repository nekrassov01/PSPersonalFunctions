#Requires -Version 5.1

<#
.SYNOPSIS
Converts DateTime to UnixTime. Or do the reverse.

.DESCRIPTION
Converts DateTime to UnixTime. Or do the reverse.

.EXAMPLE
Convert-UnixTime -Target '2020/10/01 0:0:0', '2020/11/01 0:0:0'

.EXAMPLE
'2020/10/01 0:0:0', '2020/11/01 0:0:0' | Convert-UnixTime

.EXAMPLE
Convert-UnixTime -Target 1601478000, 1604156400 -Reverse

.EXAMPLE
1601478000, 1604156400 | Convert-UnixTime -Reverse

.NOTES
Author: nekrassov01
#>

function Convert-UnixTime
{
    [CmdletBinding()]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Target = (Get-Date).ToString('yyyy/MM/dd HH:mm:ss'),

        [Parameter(Position = 1, Mandatory = $false)]
        [switch]$Reverse
    )

    begin
    {
        Set-StrictMode -Version Latest

        $baseTime = Get-Date -Date '1970/1/1 0:0:0 GMT'
        $timeZone = (Get-TimeZone).Id
    }

    process
    {
        try
        {
            foreach ($t in $target)
            {
                if (-not $reverse)
                {
                    $resultTime = [datetime]$t
                    $obj = [PSCustomObject]@{
                        #TimeZone = $timeZone
                        #DateTime = $resultTime
                        UnixTime = ($resultTime - $baseTime).TotalSeconds
                        #UTC      = $resultTime.ToUniversalTime()
                    }
                }
                else
                {
                    $resultTime = $baseTime.AddSeconds([int]$t)
                    $obj = [PSCustomObject]@{
                        TimeZone = $timeZone
                        DateTime = $resultTime
                        UnixTime = $t
                        UTC      = $resultTime.ToUniversalTime()
                    }
                }     

                $PSCmdlet.WriteObject($obj)
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
