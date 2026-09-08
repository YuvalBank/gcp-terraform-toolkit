function Test-CommandExists {
    <#
        .SYNOPSIS
            Checks whether a given command is available on the current PATH.

        .DESCRIPTION
            Thin wrapper around Get-Command used to verify that external
            dependencies (gcloud, git, terraform) are installed before the
            module attempts to invoke them. Centralizing this check makes it
            easy to mock in unit tests.

        .PARAMETER Name
            The name of the command to look for (e.g. 'gcloud', 'git', 'terraform').

        .OUTPUTS
            System.Boolean

        .EXAMPLE
            Test-CommandExists -Name 'terraform'
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}
