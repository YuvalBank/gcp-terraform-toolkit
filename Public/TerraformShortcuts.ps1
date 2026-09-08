<#
    TerraformShortcuts.ps1

    Short, muscle-memory-friendly wrappers around Invoke-Terraform, modeled on
    common shell alias conventions (e.g. posh-git's git aliases). Each shortcut
    forwards all remaining arguments to `terraform` unchanged.

    These intentionally do not follow the PowerShell Verb-Noun naming convention:
    they exist purely as fast, interactive CLI shortcuts, analogous to `gco`/`gcm`
    style aliases in popular git tooling. The underlying implementation
    (Invoke-Terraform) does follow standard naming and safety conventions.
#>

function tfi {
    <#
        .SYNOPSIS
            Shortcut for 'terraform init'.
        .EXAMPLE
            tfi -upgrade
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command init @Arguments
}

function tfp {
    <#
        .SYNOPSIS
            Shortcut for 'terraform plan'.
        .EXAMPLE
            tfp -var-file=prod.tfvars
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command plan @Arguments
}

function tfa {
    <#
        .SYNOPSIS
            Shortcut for 'terraform apply' (prompts for confirmation).
        .EXAMPLE
            tfa
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command apply @Arguments
}

function tfaa {
    <#
        .SYNOPSIS
            Shortcut for 'terraform apply -auto-approve'. Use with caution.
        .EXAMPLE
            tfaa
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Write-Warning "Running 'terraform apply -auto-approve' — changes will be applied without further confirmation."
    Invoke-Terraform -Command apply -Arguments (@('-auto-approve') + $Arguments)
}

function tfd {
    <#
        .SYNOPSIS
            Shortcut for 'terraform destroy' (prompts for confirmation).
        .EXAMPLE
            tfd
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command destroy @Arguments
}

function tfv {
    <#
        .SYNOPSIS
            Shortcut for 'terraform validate'.
        .EXAMPLE
            tfv
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command validate @Arguments
}

function tff {
    <#
        .SYNOPSIS
            Shortcut for 'terraform fmt -recursive'.
        .EXAMPLE
            tff
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command fmt @Arguments
}

function tfo {
    <#
        .SYNOPSIS
            Shortcut for 'terraform output'.
        .EXAMPLE
            tfo -json
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )
    Invoke-Terraform -Command output @Arguments
}
