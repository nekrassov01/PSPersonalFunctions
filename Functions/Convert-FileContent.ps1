#Requires -Version 5.1

<#
.SYNOPSIS
Batch conversion of the contents of files in the selected folder.

.DESCRIPTION
Batch conversion of the contents of files in the selected folder.
You can use regular expressions to replace strings.
IMPORTANT: This function cannot determine whether the target is a binary file or not,
so use the 'IncludeExtension' parameter or 'ExcludeExtension' parameter to determine the file extension.
The default setting is to use the 'IncludeExtension' parameter to target only '.txt' files.
If you want to include files that do not have an extension, please check the contents carefully beforehand.

.EXAMPLE
Convert-FileContent -Path 'C:\Folder1', 'C:\Folder2' -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false

.EXAMPLE
Convert-FileContent -Path 'C:\Folder1', 'C:\Folder2' -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Confirm:$false

.EXAMPLE
Convert-FileContent -Path 'C:\Folder1', 'C:\Folder2' -TargetString '-' -NewString '_' -Raw -Confirm:$false

.EXAMPLE
'C:\Folder1', 'C:\Folder2' | Convert-FileContent -TargetString '-' -NewString '_' -IncludeExtension '.txt', '.bat' -Confirm:$false

.EXAMPLE
'C:\Folder1', 'C:\Folder2' | Convert-FileContent -TargetString '-' -NewString '_' -ExcludeExtension '.exe', '.zip' -Confirm:$false

.EXAMPLE
'C:\Folder1', 'C:\Folder2' | Convert-FileContent -TargetString '-' -NewString '_' -Raw -Confirm:$false

.NOTES
Author: nekrassov01
#>

function Convert-FileContent
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$Path,

        [Parameter(Position = 1, Mandatory = $false)]
        [regex]$FilterExpression,

        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetString,

        [Parameter(Position = 3, Mandatory = $true)]
        [AllowEmptyString()]
        [string]$NewString,

        [Parameter(Position = 4, Mandatory = $false)]
        [switch]$Raw,

        [Parameter(Position = 5, Mandatory = $false)]
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
                $childItem = switch ($PSBoundParameters.ContainsKey('Recurse'))
                {
                    $true  { Get-ChildItem -LiteralPath $p -File -Recurse }
                    $false { Get-ChildItem -LiteralPath $p -File }
                }

                $target = switch ($PSBoundParameters.ContainsKey('FilterExpression'))
                {
                    $null   { $childItem }
                    default { ($childItem).Where{ $_.Name -match $filterExpression } }
                }
                
                foreach ($t in $target)
                {
                    if ($PSCmdlet.ShouldProcess($t.FullName))
                    {
                        $sourceContent = switch ($PSBoundParameters.ContainsKey('Raw'))
                        {
                            $true  { Get-Content -LiteralPath $t.FullName -Raw }
                            $false { Get-Content -LiteralPath $t.FullName }
                        }

                        if ($null -ne $sourceContent)
                        {
                            $destinationContent = $sourceContent -replace $targetString, $newString
                            Set-Content -LiteralPath $t.FullName -Value $destinationContent
                        }

                        # Using '$?' to generate a return value
                        if ($?)
                        {
                            $obj = [PSCustomObject]@{
                                TargetFile    = $t
                                TargetString  = $targetString
                                NewString     = $newString
                                BeforeContent = $sourceContent
                                AfterContent  = $destinationContent
                            }
                        
                            $PSCmdlet.WriteObject($obj)
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
