#Requires -Version 5.1

<#
.SYNOPSIS
Converts or removes the 'ZoneIdentifier' assigned to files downloaded from the Internet, so that security warnings are no longer displayed.

.DESCRIPTION
Converts or removes the 'ZoneIdentifier' assigned to files downloaded from the Internet, so that security warnings are no longer displayed.

.EXAMPLE
Remove-ZoneIdentifier -Path C:\test1, C:\test2 -Conversion -Raw -Recurse

.EXAMPLE
Remove-ZoneIdentifier -Path C:\test1, C:\test2 -Deletion -Recurse

.NOTES
Author: nekrassov01
#>

function Remove-ZoneIdentifier
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Conversion')]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Position = 1, Mandatory = $false)]
        [switch]$Recurse,

        [Parameter(Position = 2, Mandatory = $false, ParameterSetName = 'Conversion')]
        [switch]$Conversion,

        [Parameter(Position = 3, Mandatory = $false, ParameterSetName = 'Deletion')]
        [switch]$Deletion,

        [Parameter(Position = 4, Mandatory = $false, ParameterSetName = 'Conversion')]
        [switch]$Raw
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
                    $true  { Get-ChildItem -LiteralPath $p -File -Recurse }
                    $false { Get-ChildItem -LiteralPath $p -File }
                }

                foreach ($t in $target)
                {
                    $stream = 'Zone.Identifier'
                    $zoneId = $t.FullName, $stream -join ':'
                    $targetString = 'ZoneId=3'
                    $newString = 'AppZoneId=4'

                    $isValid = Get-Item -Path $t.FullName -Stream $stream

                    $obj = [PSCustomObject]@{
                        Path   = $zoneId
                        Action = $PSCmdlet.ParameterSetName
                    }

                    if( $PSBoundParameters.ContainsKey('Raw'))
                    {
                        $targetContent = Get-Content -LiteralPath $zoneId -Raw
                    }
                    else
                    {
                        $targetContent = Get-Content -LiteralPath $zoneId
                    }

                    if ($null -ne ($isValid))
                    {
                        if ($PSCmdlet.ShouldProcess($zoneId))
                        {
                            if ($PSCmdlet.ParameterSetName.Equals('Conversion'))
                            {
                                $newContent = $targetContent -replace $targetString, $newString
                                Set-Content -LiteralPath $zoneId -Value $newContent

                                # Using '$?' to generate a return value
                                if ($?)
                                {
                                    $additionalMembers = [ordered]@{
                                        TargetString  = $targetString
                                        NewString     = $newString
                                        TargetContent = $targetContent
                                        NewContent    = $newContent
                                    }
                                
                                    $obj | Add-Member -NotePropertyMembers $additionalMembers -Force
                                    $PSCmdlet.WriteObject($obj)
                                }
                            }

                            if ($PSCmdlet.ParameterSetName.Equals('Deletion'))
                            {
                                Remove-Item -LiteralPath $t.FullName -Stream $stream

                                # Using '$?' to generate a return value
                                if ($?)
                                {
                                    $PSCmdlet.WriteObject($obj)
                                }
                            }
                        }
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
