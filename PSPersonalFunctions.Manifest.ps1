Push-Location -Path $PSScriptRoot

# Variables
$module                 = 'PSPersonalFunctions'
$author                 = 'nekrassov01'
$copyright              = '(c) {0} All rights reserved.' -f $author
$moduleVersion          = '0.1.0.0'
$description            = 'A collection of personal functions.'
$powerShellVersion      = '5.1'
$dotNetFrameworkVersion = '4.5'
$clrVersion             = '4.0.0.0'
$psd1Path               = '{0}.psd1' -f $module
$psm1Path               = '{0}.psm1' -f $module
$requiredModules        = @('BitsTransfer', 'Microsoft.PowerShell.Archive')
$requiredAssemblies     = @()
$aliases                = @()
$functions              = (Get-ChildItem -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'Functions') -Filter '*.ps1' -Recurse).ForEach({ [System.IO.Path]::GetFileNameWithoutExtension($_.Name) })

# Manifest parameters
$script:moduleManifest = @{
    Path                   = $psd1Path
    Author                 = $author
    CompanyName            = $author
    Copyright              = $copyright
    RootModule             = $psm1Path
    ModuleVersion          = $moduleVersion
    Description            = $description
    PowerShellVersion      = $powerShellVersion
    DotNetFrameworkVersion = $dotNetFrameworkVersion
    ClrVersion             = $clrVersion
    RequiredModules        = $requiredModules
    #RequiredAssemblies     = $requiredAssemblies
    CmdletsToExport        = '*'
    FunctionsToExport      = $functions
    #VariablesToExport      = $module
    #AliasesToExport        = $aliases
}

if (Test-Path -Path $psd1Path)
{
    Update-ModuleManifest @moduleManifest
}
else
{
    New-ModuleManifest @moduleManifest
}

Pop-Location
