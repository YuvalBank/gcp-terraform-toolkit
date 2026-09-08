# GcpTerraformToolkit

[![CI](https://github.com/YuvalBank/gcp-terraform-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/YuvalBank/gcp-terraform-toolkit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell Gallery](https://img.shields.io/badge/PSGallery-not%20yet%20published-lightgrey)](https://www.powershellgallery.com/)

A small, dependency-checked PowerShell module that streamlines two everyday
DevOps chores:

- **Google Cloud authentication** — `gcloud auth login`, Application Default
  Credentials, and Git credential setup for Google Source Repositories, all
  in one command.
- **Terraform shortcuts** — short, memorable functions (`tfi`, `tfp`, `tfa`, ...)
  with built-in `-WhatIf` / `-Confirm` support for destructive operations.

Tested on **Windows**, **macOS**, and **Linux** via GitHub Actions CI.

---

## Why this exists

Authenticating against GCP and configuring Git credentials for Google Source
Repositories involves several manual steps every time: logging in, generating
Application Default Credentials, opening a browser to generate a Git
credential, and copying it into `git config` correctly. `Start-GcpAuth`
collapses that into a single guided command — and does so **without**
executing arbitrary clipboard content as a script, which is how similar
one-off scripts often introduce a real security risk.

## Installation

### Option A — Clone and import (works today)

```powershell
git clone https://github.com/YuvalBank/gcp-terraform-toolkit.git
Import-Module ./gcp-terraform-toolkit/GcpTerraformToolkit.psd1
```

To load it automatically in every session, add the `Import-Module` line to
your PowerShell profile (`$PROFILE`).

### Option B — PowerShell Gallery (once published)

```powershell
Install-Module -Name GcpTerraformToolkit -Scope CurrentUser
```

## Prerequisites

| Tool | Required for | Install |
|---|---|---|
| [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`) | `Start-GcpAuth` | — |
| [Git](https://git-scm.com/downloads) | Git credential setup | — |
| [Terraform](https://developer.hashicorp.com/terraform/install) | `tf*` shortcuts | — |
| PowerShell 5.1+ or PowerShell 7+ | Everything | Windows ships with 5.1; [install 7+](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) for macOS/Linux |

Every function checks for its required external command and fails with an
actionable message (with an install link) rather than an unhelpful error if
a dependency is missing.

## Usage

### Authenticate with GCP

```powershell
Start-GcpAuth
```

This will:
1. Run `gcloud auth login`.
2. Run `gcloud auth application-default login` (skip with `-SkipAdc`).
3. Configure `git config --global http.cookiefile`.
4. Open the Google Source Repositories password page and prompt you to copy
   the generated `git config` command, then apply it safely (see
   [Security notes](#security-notes) below).

```powershell
# Skip Application Default Credentials
Start-GcpAuth -SkipAdc

# Only authenticate, skip Git credential setup entirely
Start-GcpAuth -SkipGitCredentialSetup
```

### Terraform shortcuts

| Shortcut | Equivalent |
|---|---|
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` (prompts for confirmation) |
| `tfaa` | `terraform apply -auto-approve` (use with care) |
| `tfd` | `terraform destroy` (prompts for confirmation) |
| `tfv` | `terraform validate` |
| `tff` | `terraform fmt -recursive` |
| `tfo` | `terraform output` |

All shortcuts forward extra arguments to `terraform` unchanged:

```powershell
tfp -var-file=prod.tfvars
tfa -target=module.network
tfd -WhatIf          # preview without prompting or destroying anything
```

Destructive commands (`apply`, `destroy`) support standard PowerShell risk
mitigation via `Invoke-Terraform`:

```powershell
Invoke-Terraform -Command destroy -WhatIf
Invoke-Terraform -Command apply -Confirm
```

## Security notes

The original version of this tooling copied a `git config` command from a
browser to the clipboard and executed the *entire clipboard contents* as a
temporary batch file. That pattern is risky: anything else on the clipboard,
or a compromised/spoofed page, could result in arbitrary command execution.

`Set-GitCredentialFromClipboard` replaces that approach:

- It parses the clipboard text with a strict regular expression that matches
  **only** `git config --global <key> "<value>"` statements.
- It applies an **allow-list**: only keys under the `credential.*` namespace
  are ever passed to `git config`. Anything else is skipped with a warning.
- Values are passed to `git config` as discrete arguments — never concatenated
  into a string that a shell interprets — so shell metacharacters in the
  clipboard have no effect.

See [`Public/Set-GitCredentialFromClipboard.ps1`](Public/Set-GitCredentialFromClipboard.ps1)
for the full implementation and inline documentation.

## Cross-platform notes

- Paths use `$HOME` and `Join-Path` instead of `$env:USERPROFILE`, so they
  resolve correctly on Windows, macOS, and Linux.
- `Get-Clipboard` is a Windows-only cmdlet. On macOS/Linux, either skip the
  Git credential step (`Start-GcpAuth -SkipGitCredentialSetup`) or call
  `Set-GitCredentialFromClipboard -InputText '<pasted text>'` directly.

## Development

```powershell
# Install dev dependencies
Install-Module -Name Pester -MinimumVersion 5.5.0 -Scope CurrentUser
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser

# Lint
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1

# Test
Invoke-Pester -Path ./Tests
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines, and
[CHANGELOG.md](CHANGELOG.md) for release history.

## Project structure

```
gcp-terraform-toolkit/
├── GcpTerraformToolkit.psd1       # Module manifest
├── GcpTerraformToolkit.psm1       # Module loader
├── Public/                        # Exported functions
│   ├── Start-GcpAuth.ps1
│   ├── Set-GitCredentialFromClipboard.ps1
│   ├── Invoke-Terraform.ps1
│   └── TerraformShortcuts.ps1
├── Private/                       # Internal helpers
│   └── Test-CommandExists.ps1
├── Tests/                         # Pester test suite
│   └── GcpTerraformToolkit.Tests.ps1
├── .github/workflows/ci.yml       # Lint + test on Windows/macOS/Linux
├── PSScriptAnalyzerSettings.psd1
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## License

[MIT](LICENSE) — see the LICENSE file for details.
