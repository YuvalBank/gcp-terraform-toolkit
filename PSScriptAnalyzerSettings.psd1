@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # tfi/tfp/tfa/etc. are intentional short, non-Verb-Noun shortcuts documented
        # in TerraformShortcuts.ps1 and the README; suppress the naming-convention
        # warning for this file only via inline justification instead of globally.
    )
    Rules        = @{
        PSAvoidUsingWriteHost = @{
            Enable = $false  # Write-Host is used intentionally for colored, interactive CLI feedback.
        }
    }
}
