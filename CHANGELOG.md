# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-08

### Added
- Initial public release as a proper PowerShell module (`GcpTerraformToolkit`).
- `Start-GcpAuth`: cross-platform-aware GCP authentication flow with dependency checks.
- `Set-GitCredentialFromClipboard`: safe, regex-based credential parser replacing
  the original clipboard-to-batch-file execution approach.
- `Invoke-Terraform` and shortcut functions `tfi`, `tfp`, `tfa`, `tfaa`, `tfd`,
  `tfv`, `tff`, `tfo`, with `-WhatIf`/`-Confirm` support for destructive operations.
- Pester test suite covering success paths, missing dependencies, and malicious
  input handling.
- GitHub Actions CI running PSScriptAnalyzer and Pester on Windows, macOS, and Linux.
- Comment-based help for every public function (`Get-Help <FunctionName> -Full`).

### Changed
- Replaced execution of arbitrary clipboard content as a temporary `.cmd` script
  with a strict, allow-listed `git config` parser (see [SECURITY.md](SECURITY.md)
  in the original discussion — no shell interpretation of clipboard text occurs).
- Replaced hardcoded `$env:USERPROFILE` paths with `$HOME`, which resolves
  correctly on Windows, macOS, and Linux.
- Replaced `-Encoding UTF8` (which emits a byte-order mark on Windows PowerShell 5.1)
  with direct argument passing to `git config`, removing the encoding concern entirely.

### Removed
- The VS Code-specific `PSReadLine` history path override from the original script
  (left as a user-level profile customization rather than a module default).
