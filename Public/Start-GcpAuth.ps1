function Start-GcpAuth {
    <#
        .SYNOPSIS
            Authenticates with Google Cloud and optionally configures Git credentials
            for Google Source Repositories.

        .DESCRIPTION
            Runs `gcloud auth login`, optionally followed by
            `gcloud auth application-default login`, then configures the global Git
            cookie file. If Git credential setup is not skipped, it opens the Google
            Source Repositories password page and delegates credential configuration
            to Set-GitCredentialFromClipboard.

            The function verifies that `gcloud` (and, where relevant, `git`) are
            installed before doing any work, and fails fast with an actionable
            message if they are not.

        .PARAMETER SkipAdc
            Skip the `gcloud auth application-default login` step. Use this if you
            only need user-level authentication (e.g. for `gcloud` CLI commands) and
            do not need Application Default Credentials for client libraries or
            Terraform's Google provider.

        .PARAMETER GitCookieFilePath
            Path to the Git cookie file used by http.cookiefile. Defaults to
            '<home>/.gitcookies' and works on Windows, macOS, and Linux.

        .PARAMETER CredentialPageUrl
            URL of the Google Source Repositories password generation page.
            Exposed as a parameter so it can be overridden or tested without
            editing the function body.

        .PARAMETER SkipGitCredentialSetup
            Skip the browser step and Git credential configuration entirely.
            Use this if you only need `gcloud` authentication.

        .EXAMPLE
            Start-GcpAuth

            Runs the full authentication flow: gcloud login, ADC login, and
            Git credential setup.

        .EXAMPLE
            Start-GcpAuth -SkipAdc -SkipGitCredentialSetup

            Runs only `gcloud auth login`, skipping Application Default
            Credentials and Git credential configuration.

        .NOTES
            The interactive clipboard-based credential step (Set-GitCredentialFromClipboard)
            requires Get-Clipboard, which is only available on Windows by default.
            On macOS/Linux, pass -SkipGitCredentialSetup and configure Git credentials
            manually, or call Set-GitCredentialFromClipboard -InputText directly.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$SkipAdc,

        [ValidateNotNullOrEmpty()]
        [string]$GitCookieFilePath = (Join-Path -Path $HOME -ChildPath '.gitcookies'),

        [ValidateNotNullOrEmpty()]
        [string]$CredentialPageUrl = 'https://source.developers.google.com/new-password',

        [switch]$SkipGitCredentialSetup
    )

    if (-not (Test-CommandExists -Name 'gcloud')) {
        Write-Error "The 'gcloud' CLI was not found on PATH. Install the Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
        return
    }

    Write-Host "`n=== GCP Authentication ===" -ForegroundColor Cyan

    if ($PSCmdlet.ShouldProcess('gcloud', 'auth login')) {
        gcloud auth login
        if ($LASTEXITCODE -ne 0) {
            Write-Error "'gcloud auth login' failed with exit code $LASTEXITCODE. Stopping here."
            return
        }
    }

    if (-not $SkipAdc) {
        if ($PSCmdlet.ShouldProcess('gcloud', 'auth application-default login')) {
            gcloud auth application-default login
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "'gcloud auth application-default login' failed with exit code $LASTEXITCODE. Continuing anyway."
            }
        }
    }

    if (-not (Test-CommandExists -Name 'git')) {
        Write-Warning "'git' was not found on PATH. Skipping Git credential configuration."
        return
    }

    if ($PSCmdlet.ShouldProcess($GitCookieFilePath, 'Set git http.cookiefile')) {
        git config --global http.cookiefile "$GitCookieFilePath"
        Write-Host "Configured git cookie file at '$GitCookieFilePath'." -ForegroundColor Green
    }

    if ($SkipGitCredentialSetup) {
        return
    }

    Write-Host "Opening the Google Source Repositories password page in your browser..." -ForegroundColor Yellow
    try {
        Start-Process -FilePath $CredentialPageUrl
    }
    catch {
        Write-Warning "Could not open the browser automatically. Please open this URL manually: $CredentialPageUrl"
    }

    Set-GitCredentialFromClipboard
}
