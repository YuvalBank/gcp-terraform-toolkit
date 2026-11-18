function Test-CommandExists {
    <#
        .SYNOPSIS
            Checks whether a given command is available on the current PATH.

        .DESCRIPTION
            Thin wrapper around Get-Command used to verify that external
            dependencies (gcloud, git, terraform) are installed before the
            module attempts to invoke them. Centralizing this check makes it
            easy to mock in unit tests.
            
            Results are cached in the session to avoid repeated calls to Get-Command.

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

    # Initialize cache if it doesn't exist
    if (-not (Get-Variable -Name 'GcpTkCommandCache' -Scope Script -ErrorAction SilentlyContinue)) {
        $script:GcpTkCommandCache = @{}
    }

    # Return cached result if available
    if ($script:GcpTkCommandCache.ContainsKey($Name)) {
        return $script:GcpTkCommandCache[$Name]
    }

    # Check if command exists and cache result
    $result = [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
    $script:GcpTkCommandCache[$Name] = $result
    
    return $result
}
