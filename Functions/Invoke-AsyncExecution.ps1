#Requires -Version 5.1

<#
.SYNOPSIS
Using RunspacePool to execute multiple scriptblocks asynchronously.

.DESCRIPTION
Using RunspacePool to execute multiple scriptblocks asynchronously.
Using Parameter 'Target' and 'ParameterName', You can define parameters for array of scriptblock.
You can define parameters as array, and the product of the parameter length and the scriptblock length is the thread length.
So, need to be careful not to make the process too heavy.

.EXAMPLE
$scriptBlock = @(
{ param($ComputerName) Get-EventLog -ComputerName $ComputerName -LogName Application }
{ param($ComputerName) Get-EventLog -ComputerName $ComputerName -LogName System }
)
Invoke-AsyncExecution -Target 'Computer1', 'Computer2' -ParameterName ComputerName -ScriptBlock $scriptBlock -TimeInfo

.NOTES
Author: nekrassov01
#>

function Invoke-AsyncExecution
{
    [CmdletBinding()]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [scriptblock[]]$ScriptBlock,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [object[]]$Target,

        [Parameter(Position = 2, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterName,

        [Parameter(Position = 3, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int]$PoolSize = 30,

        [Parameter(Position = 4, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [switch]$TimeInfo
    )

    begin
    {
        try
        {
            Set-StrictMode -Version Latest

            $isValid = ($PSBoundParameters.ContainsKey('Target') -and $PSBoundParameters.ContainsKey('ParameterName'))

            if ($isValid)
            {
                $length = $remainingJobs = $ScriptBlock.Length * $Target.Length
            }
            else
            {
                $length = $remainingJobs = $ScriptBlock.Length
            }
        
            if ($length -lt $poolSize){ $PoolSize = $length }

            $runspaces = New-Object -TypeName System.Collections.Generic.List[psobject]
            $return    = New-Object -TypeName System.Collections.Generic.List[psobject]

            <#
            $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
            $sessionState.ApartmentState = [System.Threading.ApartmentState]::MTA
            $sessionState.ThrowOnRunspaceOpenError = $true
            $sessionState.ExecutionPolicy = [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned
            $runspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool($poolSize, $poolSize, $sessionState, $Host)
            #>
            $runspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool($poolSize, $poolSize)
            $runspacePool.ApartmentState = [System.Threading.ApartmentState]::MTA
            $runspacePool.Open()

            while ($remainingJobs)
            {
                $scriptBlock | ForEach-Object -Process {
                
                    $script = $_
                
                    $target | ForEach-Object -Process {
                
                        $powerShell = [PowerShell]::Create().AddScript($script)
                
                        if ($isValid)
                        {
                            [void]$powerShell.AddParameter($parameterName, $_)
                        }
                
                        $powerShell.RunspacePool = $runspacePool
                
                        $obj = [PSCustomObject]@{
                            StartTime = (Get-Date)
                            EndTime = $null
                            PowerShell = $powerShell
                            Runspace = $powerShell.BeginInvoke()
                        }
                
                        [void]$runspaces.Add($obj)
                
                        $commandText = (($obj.PowerShell.Commands.Commands.CommandText.Trim() -split ([System.Environment]::NewLine)).Trim() -join '; ')
                        Write-Log -InputObject ([System.String]::Format('''{0}''', $commandText)) -Status Started
                    }
                }

                $runspaces | ForEach-Object -Process {

                    if ($_.PowerShell.InvocationStateInfo.State -eq 'Failed')
                    {
                        $output = $_.PowerShell.InvocationStateInfo.Reason

                        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                            [System.Management.Automation.Runspaces.InvalidRunspaceStateException]::new($output),
                            'AsynchronousOperationException',
                            [System.Management.Automation.ErrorCategory]::NotSpecified,
                            $_
                        )
                        $PSCmdlet.ThrowTerminatingError($errorRecord)
                    }
                    else
                    {
                        $output = $_.PowerShell.EndInvoke($_.Runspace)
                    }

                    $_.EndTime = (Get-Date)
                    $timeSpan = New-TimeSpan -Start $_.StartTime -End $_.EndTime

                    if ($timeInfo)
                    {
                        $result = [PSCustomObject]@{
                            TimeSpan = $timeSpan
                            Output = $output
                        }
                    }
                    else
                    {
                        $result = $output
                    }

                    $remainingJobs--

                    $commandText = (($_.PowerShell.Commands.Commands.CommandText.Trim() -split ([System.Environment]::NewLine)).Trim() -join '; ')
                    Write-Log -InputObject ([System.String]::Format('''{0}''', $commandText)) -Status Completed -Suffix ([System.String]::Format(' in {0}', $timeSpan))

                    Write-Progress -Activity $commandText -Status ([System.String]::Format('{0} jobs remaining', $remainingJobs)) -PercentComplete (($length - $remainingJobs) / $length * 100)
                    $return.Add($result)
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
        finally
        {
            $runspaces | ForEach-Object -Process { $_.PowerShell.Dispose() }
            $runspacePool.Close()
            $runspacePool.Dispose()
        }
    }

    end
    {
       return $return
    }
}
