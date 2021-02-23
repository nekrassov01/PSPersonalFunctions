#Requires -Version 5.1

<#
.SYNOPSIS
Remove the user profile with the WMI class.

.DESCRIPTION
Remove the user profile with the WMI class.
You can set the 'ComputerName' parameter to run on a remote computer.

.EXAMPLE
Remove-UserProfile -UserName 'User-01', 'User-02'

.EXAMPLE
Remove-UserProfile -UserName 'User-01', 'User-02' -ComputerName 'RemoteHost'

.EXAMPLE
'User-01', 'User-02' | Remove-UserProfile

.EXAMPLE
'User-01', 'User-02' | Remove-UserProfile -ComputerName 'RemoteHost'

.NOTES
Author: nekrassov01
#>

function Remove-UserProfile
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$UserName,

        [Parameter(Position = 1, Mandatory = $false)]
        [string]$ComputerName = 'localhost'
    )

    begin
    {
        Set-StrictMode -Version Latest

        $cimSessionOption = New-CimSessionOption -Protocol Dcom
        $cimSession = New-CimSession -ComputerName $computerName -SessionOption $cimSessionOption
    }

    Process
    {
        try
        {
            foreach ($u in $userName)
            {
                if ($PSCmdlet.ShouldProcess($u))
                {
                    $_userName = if ($u -match '\\')
                    {
                        $u -replace '\\', '\\'
                    }
                    else
                    {
                        $u
                    }

                    $filter = [System.String]::Format('Name=''{0}'' or Caption=''{0}''', $u)
                    $target = Get-CimInstance -CimSession $cimSession -ClassName Win32_UserAccount -Filter $filter

                    if ($null -ne $target)
                    {
                        $filter = [System.String]::Format('SID=''{0}''', $target.SID)
                        Get-CimInstance -CimSession $cimSession -ClassName Win32_UserProfile -Filter $filter | Remove-WmiObject 

                        # Using '$?' to generate a return value
                        if ($?)
                        {
                            $obj = [PSCustomObject]@{
                                ComputreName = if ($computerName -ne 'localhost') { $computerName } else { $env:COMPUTERNAME }
                                UserName = $target.Caption
                                SID = $target.SID
                            }

                           $PSCmdlet.WriteObject($obj)
                        }
                    }
                    else
                    {
                        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                            [Microsoft.Management.Infrastructure.CimException]::new(),
                            'UserNotFound',
                            [System.Management.Automation.ErrorCategory]::InvalidArgument,
                            $target
                        )
                        $PSCmdlet.ThrowTerminatingError($errorRecord)
                    }
                }
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
