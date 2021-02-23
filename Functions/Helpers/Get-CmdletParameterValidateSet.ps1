#Requires -Version 5.1

<#
.SYNOPSIS
Get ValidateSet parameter of Cmdlet.

.DESCRIPTION
Get ValidateSet parameter of Cmdlet.

.EXAMPLE
Get-CmdletParameterValidateSet -Module 'BitsTransfer' -Command 'Start-BitsTransfer' -Parameter 'TransferType'

.NOTES
Author: nekrassov01
#>

function Get-CmdletParameterValidateSet
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [string]$Module,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,

        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Parameter
    )

    begin
    {
        Set-StrictMode -Version Latest

        if (($PSBoundParameters.ContainsKey('Module')) -and ($null -eq (Get-Module -Name $module)))
        {
            Import-Module -Name $module -Force
        }

        $typeId = [System.Management.Automation.ValidateSetAttribute]
        $validateSet = ((Get-Command -Name $command).Parameters[$parameter].Attributes | Where-Object -FilterScript { $_.TypeId -eq $typeId }).ValidValues
        $PSCmdlet.WriteObject($validateSet)
    }
}
