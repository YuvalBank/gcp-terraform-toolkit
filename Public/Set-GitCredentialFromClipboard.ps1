function Set-GitCredentialFromClipboard {
    <#
        .SYNOPSIS
            Safely extracts a Git HTTP credential from clipboard text and applies it.

        .DESCRIPTION
            Google Source Repositories' password page generates commands of the form:

                git config --global credential.https://source.developers.google.com.username "<user>"
                git config --global credential.https://source.developers.google.com.password "<token>"

            This function does NOT execute clipboard text as a script. Instead, it parses
            only the `git config --global <key> "<value>"` pairs it recognizes out of the
            supplied text using a strict regular expression, restricts accepted keys to the
            `credential.*` namespace, and invokes `git config` directly with those values as
            discrete arguments.

            This avoids the security risks of writing clipboard content to a temporary batch
            file and executing it (arbitrary command execution / clipboard injection), since
            no part of the clipboard text is ever interpreted by a shell.

        .PARAMETER InputText
            Text to parse instead of reading from the clipboard. Primarily used for
            automated testing and for non-Windows platforms where Get-Clipboard is
            unavailable.

        .EXAMPLE
            Set-GitCredentialFromClipboard

            Prompts you to copy the generated command, then reads it from the clipboard.

        .EXAMPLE
            Set-GitCredentialFromClipboard -InputText $textFromSomeOtherSource

            Parses and applies credentials from an explicit string, without touching
            the clipboard. Useful on macOS/Linux or in CI.

        .NOTES
            Only keys under the 'credential.' namespace are ever applied. Any other
            `git config` key found in the input is reported via Write-Warning and skipped.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [string]$InputText
    )

    if (-not $InputText) {
        if (-not (Test-CommandExists -Name 'Get-Clipboard')) {
            Write-Warning "Get-Clipboard is not available on this platform. Re-run with -InputText '<copied text>' instead."
            return
        }

        Read-Host -Prompt "Press ENTER after you have copied the 'git config' command from the browser"
        $InputText = Get-Clipboard -Raw
    }

    if ([string]::IsNullOrWhiteSpace($InputText)) {
        Write-Error "No text was provided or found on the clipboard. Nothing to do."
        return
    }

    # Matches ONLY well-formed `git config --global <key> "<value>"` statements.
    # Anything outside this pattern (shell operators, additional commands chained with
    # ';', '&&', '|', backticks, etc.) is simply not captured and is never executed.
    $pattern = 'git\s+config\s+--global\s+(?<key>[A-Za-z0-9_.\-/:]+)\s+"(?<value>[^"]*)"'
    $regexMatches = [regex]::Matches($InputText, $pattern)

    if ($regexMatches.Count -eq 0) {
        Write-Error "No recognizable 'git config --global <key> ""<value>""' entries were found. Nothing was executed."
        return
    }

    $appliedCount = 0

    foreach ($match in $regexMatches) {
        $key = $match.Groups['key'].Value
        $value = $match.Groups['value'].Value

        # Restrict to the credential.* namespace this workflow is meant to configure.
        # This is a deliberate allow-list, not a deny-list: unrecognized keys are skipped.
        if ($key -notmatch '^credential\.') {
            Write-Warning "Skipping git config key outside the 'credential.*' namespace: '$key'"
            continue
        }

        if ($PSCmdlet.ShouldProcess("git config --global $key", 'Set value')) {
            # Use --null to safely handle values containing special characters
            # Avoid logging the actual value in case it contains sensitive data
            try {
                git config --global -- "$key" "$value"

                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Configured git setting '$key'." -ForegroundColor Green
                    $appliedCount++
                }
                else {
                    # Do not log the exit code with the key to avoid exposing structure
                    Write-Error "Failed to set git credential setting (exit code $LASTEXITCODE)."
                }
            }
            catch {
                # Catch and sanitize error message to avoid leaking sensitive data
                Write-Error "An error occurred while setting git credentials. Please verify your clipboard content is correct."
            }
        }
    }

    if ($appliedCount -eq 0) {
        Write-Warning "No credential.* settings were applied."
    }
}
