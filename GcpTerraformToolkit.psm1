#Requires -Version 5.1
<#
    GcpTerraformToolkit.psm1

    Module loader. Dot-sources every function file under Private/ and Public/,
    then exports only the intended public surface (declared explicitly in the
    module manifest, GcpTerraformToolkit.psd1).

    Loading Private/ before Public/ ensures helper functions (e.g. Test-CommandExists)
    are available before the public functions that call them are defined.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleRoot = $PSScriptRoot

foreach ($folder in @('Private', 'Public')) {
    $folderPath = Join-Path -Path $moduleRoot -ChildPath $folder

    if (-not (Test-Path -Path $folderPath)) {
        continue
    }

    $functionFiles = Get-ChildItem -Path $folderPath -Filter '*.ps1' -File -Recurse

    foreach ($file in $functionFiles) {
        try {
            . $file.FullName
        }
        catch {
            Write-Error "Failed to load '$($file.FullName)': $($_.Exception.Message)"
            throw
        }
    }
}

# Aliases. Functions themselves are exported via FunctionsToExport in the module manifest.
Set-Alias -Name glog -Value Start-GcpAuth

Export-ModuleMember -Function * -Alias glog
