#Requires -Version 5.1

<#
.SYNOPSIS
Convert UserName to SID. Or do the reverse.

.DESCRIPTION
Convert UserName to SID. Or do the reverse.

.EXAMPLE
Convert-SID -Target '$env:COMPUTERNAME\User-01', '$env:USERDOMAIN\User-02'

.EXAMPLE
'$env:COMPUTERNAME\User-01', '$env:USERDOMAIN\User-02' | Convert-SID

.EXAMPLE
Convert-SID -Target 'S-1-5-21-000000000-1111111111-222222222-500', 'S-1-5-21-000000000-1111111111-222222222-1000' -Reverse

.EXAMPLE
'S-1-5-21-000000000-1111111111-222222222-500', 'S-1-5-21-000000000-1111111111-222222222-1000' | Convert-SID

.NOTES
Author: nekrassov01
#>

function Convert-SID
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Target,

        [Parameter(Position = 1, Mandatory = $false)]
        [string]$ComputerName = 'localhost',

        [Parameter(Position = 2, Mandatory = $false)]
        [switch]$Reverse
    )

    begin
    {
        Set-StrictMode -Version Latest

        $cimSessionOption = New-CimSessionOption -Protocol Dcom
        $cimSession = New-CimSession -ComputerName $computerName -SessionOption $cimSessionOption
    }

    process
    {
        try
        {
            foreach ($t in $target)
            {
                if (-not $reverse)
                {
                    if ($t -match '\\')
                    {
                        $_userName = $t -replace '\\', '\\'
                        $filter = [System.String]::Format('Caption=''{0}''', $_userName)
                    }
                    else
                    {
                        $_userName = $t
                        $filter = [System.String]::Format('Name=''{0}''', $_userName)
                    }

                    $obj = Get-CimInstance -CimSession $cimSession -ClassName Win32_UserAccount -Filter $filter
                }
                else
                {
                    $filter = [System.String]::Format('SID=''{0}''', $t)
                    $obj = Get-CimInstance -CimSession $cimSession -ClassName Win32_UserAccount -Filter $filter
                }

                $PSCmdlet.WriteObject($obj)
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end
    {
        $cimSession | Remove-CimSession
    }
}
