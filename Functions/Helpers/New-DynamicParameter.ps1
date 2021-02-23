#Requires -Version 5.1

<#
.SYNOPSIS
Create multiple DynamicParam from HashTable array.

.DESCRIPTION
Create multiple DynamicParam from HashTable array.
You can easily implement the complex syntax of DynamicParam using a HashTable array.

.EXAMPLE
$DynamicParameter = @(
@{
    Position                        = 0
    Mandatory                       = $false
    ValueFromPipeline               = $false
    ValueFromPipelineByPropertyName = $false
    ValueFromRemainingArguments     = $false
    ParameterSetName                = '__AllParameterSets'
    HelpMessage                     = $false
    ParameterName                   = 'TargetText'
    ParameterType                   = [string]
    ValidateSet                     = { Get-ChildItem -Path C:\Temp -Filter '*.txt' }
}
@{
    Position                        = 1
    Mandatory                       = $false
    ValueFromPipeline               = $false
    ValueFromPipelineByPropertyName = $false
    ValueFromRemainingArguments     = $false
    ParameterSetName                = '__AllParameterSets'
    HelpMessage                     = $false
    ParameterName                   = 'TargetScript'
    ParameterType                   = [string]
    ValidateSet                     = { Get-ChildItem -Path C:\Temp -Filter '*.ps1' }
}
)

New-DynamicParameter -DynamicParameter $DynamicParameter

.NOTES
Author: nekrassov01
#>

function New-DynamicParameter
{    
    [CmdletBinding()]
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable[]]$DynamicParameter
    )

    begin
    {
        $result  = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $isValid = New-Object -TypeName System.Collections.Generic.List[string]

        $properties = ((New-Object -TypeName System.Management.Automation.ParameterAttribute | Get-Member -MemberType Property).Where{ $_.Name -notin 'TypeId', 'HelpMessageBaseName', 'HelpMessageResourceId', 'DontShow' }).Name
        $properties | ForEach-Object -Process { $isValid.Add($_) }

        $additionalProperties = 'ParameterName', 'ParameterType', 'ValidateSet'
        $additionalProperties | ForEach-Object -Process { $isValid.Add($_) }
    }

    process
    {
        try
        {
            # Validate keys
            foreach ($key in $dynamicParameter.Keys)
            {
                if ($key -notin $isValid)
                {
                    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.Management.Automation.PSInvalidOperationException]::new(),
                        'InvalidHashKey',
                        [System.Management.Automation.ErrorCategory]::InvalidData,
                        $key
                    )
                    $PSCmdlet.ThrowTerminatingError($errorRecord)
                }
            }

            # Create DynamicParam
            foreach ($param in $dynamicParameter)
            {
                $parameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $properties | ForEach-Object -Process { $parameterAttribute.$_ = $param.$_ }

                $attributeCollection = New-Object -TypeName Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($parameterAttribute)

                $validateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute(Invoke-Command -ScriptBlock $param.ValidateSet)
                $attributeCollection.Add($validateSetAttribute)

                $runtimeDefinedParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter @($param.ParameterName, $param.ParameterType, $attributeCollection)
                $result.Add($param.ParameterName, $runtimeDefinedParameter)            
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end
    {
        $PSCmdlet.WriteObject($result)
    }
}
