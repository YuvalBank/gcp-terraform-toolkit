# Security Policy

## Overview

This project prioritizes security, especially in functions that handle external input
like clipboard content, credentials, or subprocess output.

## Security Design Principles

### 1. Never Execute Arbitrary Input as Code

The predecessor version of this tooling copied a `git config` command from the browser
clipboard directly into a temporary batch file and executed it — a serious risk.

**How we fixed it:**

- `Set-GitCredentialFromClipboard` uses a **strict regular expression** that matches
  **only** `git config --global <key> "<value>"` statements.
- An **allow-list** enforces that only keys under the `credential.*` namespace are
  passed to `git config`. Anything else is skipped with a warning.
- Values are passed to `git config` as **discrete arguments**, never concatenated into
  a string for shell interpretation. This means shell metacharacters in clipboard
  content have no effect.

See [`Public/Set-GitCredentialFromClipboard.ps1`](Public/Set-GitCredentialFromClipboard.ps1)
for the full implementation and inline security comments.

### 2. Validate External Command Availability

Every public function checks for its required external command (`gcloud`, `git`,
`terraform`) **before** attempting to use it, and fails with an actionable message
(including an install link) rather than a cryptic error.

### 3. Use Cross-Platform, OS-Agnostic Paths

Paths use `$HOME` and `Join-Path` instead of Windows-specific variables like
`$env:USERPROFILE`. This prevents path-related security issues on cross-platform systems.

### 4. Fail Safely on External Command Failure

Functions check `$LASTEXITCODE` after calling external commands. Destructive operations
like `terraform apply` and `terraform destroy` support PowerShell's `-WhatIf` and
`-Confirm` flags via `[CmdletBinding(SupportsShouldProcess)]`.

## Reporting a Security Issue

If you discover a security vulnerability, **please do not open a public issue**.
Instead, open a **private security advisory** on GitHub:

1. Go to your repository.
2. Click **Security** → **Advisories**.
3. Click **Report a vulnerability** (or **New draft security advisory**).
4. Provide details and allow the maintainers time to respond before public disclosure.

GitHub's private security advisory process ensures responsible disclosure and gives
maintainers time to develop and release a fix.

## Testing and Validation

- **Dependency checks** are covered by the test suite (see `Tests/GcpTerraformToolkit.Tests.ps1`).
- **Malicious input handling** is tested via hardcoded clipboard-text scenarios.
- All functions are linted via **PSScriptAnalyzer** (see `PSScriptAnalyzerSettings.psd1`).
- CI/CD runs on **Windows, macOS, and Linux** to ensure cross-platform correctness.

## Security Contact

For security issues, contact the repository maintainer via private security advisory.
For general support, open a public issue or discussion.
