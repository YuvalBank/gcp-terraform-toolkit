@{
    Severity     = @('Error', 'Warning')

    # Rules intentionally excluded, with justification for each:
    #
    #  - PSAvoidUsingWriteHost: Write-Host is used deliberately throughout this
    #    module for colored, interactive CLI feedback (this is a CLI toolkit,
    #    not a library meant to return objects down a pipeline).
    #
    #  - PSShouldProcess: the tf* shortcut functions in TerraformShortcuts.ps1
    #    declare SupportsShouldProcess to expose -WhatIf/-Confirm, but the
    #    actual $PSCmdlet.ShouldProcess() call lives in Invoke-Terraform, which
    #    they delegate to. $WhatIfPreference/$ConfirmPreference cascade
    #    correctly to that inner call via PowerShell's normal preference
    #    variable inheritance, so this is a known analyzer false positive for
    #    thin delegating wrapper functions.
    #
    #  - PSUseSingularNouns: Test-CommandExists's noun ends in 's' but is not
    #    a plural noun (it's a verb form, "exists"). Renaming it to the
    #    grammatically awkward 'Test-CommandExist' would hurt readability for
    #    no real benefit.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSShouldProcess',
        'PSUseSingularNouns'
    )
}
