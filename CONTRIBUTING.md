# Contributing to GcpTerraformToolkit

Thanks for considering a contribution! This project aims to stay small, safe,
and dependency-light, so please keep pull requests focused.

## Getting started

1. Fork and clone the repository.
2. Install the development dependencies:
   ```powershell
   Install-Module -Name Pester -MinimumVersion 5.5.0 -Scope CurrentUser
   Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
   ```
3. Import the module locally for manual testing:
   ```powershell
   Import-Module ./GcpTerraformToolkit.psd1 -Force
   ```

## Before opening a pull request

- **Run the linter** and fix any errors (warnings should be addressed where reasonable):
  ```powershell
  Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
  ```
- **Run the test suite** and ensure all tests pass:
  ```powershell
  Invoke-Pester -Path ./Tests
  ```
- **Add or update tests** for any new behavior, especially anything that touches
  external commands (`gcloud`, `git`, `terraform`) — mock them, never call them
  for real in tests.
- **Update `CHANGELOG.md`** under an `[Unreleased]` heading.
- **Add comment-based help** (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`)
  to any new public function.

## Security-sensitive changes

Any change touching `Set-GitCredentialFromClipboard` or anything that parses
external input (clipboard, files, network responses) requires extra scrutiny:

- Never reintroduce execution of arbitrary text as a script or command line.
- Prefer explicit allow-lists over deny-lists when validating input.
- Pass values as discrete arguments to external commands rather than building
  strings that get interpreted by a shell.

If you believe you've found a security issue, please open a private security
advisory on GitHub rather than a public issue.

## Style

- Use approved PowerShell verbs (`Get-Verb`) for new public functions, except
  for the intentionally short `tf*` shortcuts, which are documented exceptions.
- Use `[CmdletBinding()]` on every function; use `SupportsShouldProcess` for
  anything that changes state or calls a destructive external command.
- Prefer `$HOME` and `Join-Path` over hardcoded, OS-specific paths.
