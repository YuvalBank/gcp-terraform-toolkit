function Invoke-Terraform {
    <#
        .SYNOPSIS
            Thin wrapper around the terraform CLI shared by all tf* shortcut functions.

        .DESCRIPTION
            Centralizes calls to the terraform binary so that every shortcut
            (tfi, tfp, tfa, tfaa, tfd, tfv, tff, tfo) shares one PATH check and one
            confirmation story for destructive subcommands (apply, destroy).

            Supports -WhatIf and -Confirm for 'apply' and 'destroy' via
            SupportsShouldProcess, so destructive operations can be previewed or
            require explicit confirmation in accordance with PowerShell best practices.

        .PARAMETER Command
            The terraform subcommand to run.

        .PARAMETER Arguments
            Additional arguments passed through to terraform unchanged
            (e.g. '-auto-approve', '-var-file=prod.tfvars').

        .EXAMPLE
            Invoke-Terraform -Command plan

        .EXAMPLE
            Invoke-Terraform -Command apply -Arguments '-auto-approve'

        .EXAMPLE
            Invoke-Terraform -Command destroy -WhatIf

            Shows what would run without actually invoking terraform destroy.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('init', 'plan', 'apply', 'destroy', 'validate', 'fmt', 'output')]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    if (-not (Test-CommandExists -Name 'terraform')) {
        Write-Error "The 'terraform' CLI was not found on PATH. Install it from: https://developer.hashicorp.com/terraform/install"
        return
    }

    $destructiveCommands = @('apply', 'destroy')

    if ($Command -in $destructiveCommands) {
        $currentDirectory = (Get-Location).Path
        if (-not $PSCmdlet.ShouldProcess($currentDirectory, "terraform $Command")) {
            return
        }
    }

    if ($Command -eq 'fmt') {
        terraform fmt -recursive @Arguments
    }
    else {
        terraform $Command @Arguments
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "'terraform $Command' exited with code $LASTEXITCODE."
    }
}
