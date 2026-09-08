@{
    # Script module associated with this manifest.
    RootModule        = 'GcpTerraformToolkit.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # Unique identifier for this module.
    GUID              = '5c972c2c-ce41-4850-a21b-7a8a5161c5bd'

    Author            = 'Your Name'
    CompanyName       = 'Unknown'
    Copyright         = '(c) 2026 Your Name. Licensed under the MIT License.'

    Description       = 'PowerShell shortcuts for Google Cloud (gcloud) authentication and everyday Terraform workflows, designed to work consistently across Windows, macOS, and Linux.'

    # Minimum PowerShell version required.
    PowerShellVersion = '5.1'

    # Functions to export from this module. Wildcards are avoided for explicit control
    # and faster module import.
    FunctionsToExport = @(
        'Start-GcpAuth',
        'Set-GitCredentialFromClipboard',
        'Invoke-Terraform',
        'tfi',
        'tfp',
        'tfa',
        'tfaa',
        'tfd',
        'tfv',
        'tff',
        'tfo'
    )

    # Cmdlets to export from this module.
    CmdletsToExport   = @()

    # Variables to export from this module.
    VariablesToExport = @()

    # Aliases to export from this module.
    AliasesToExport   = @('glog')

    PrivateData = @{
        PSData = @{
            Tags         = @('GCP', 'GoogleCloud', 'Terraform', 'DevOps', 'CLI', 'Automation', 'Windows', 'Linux', 'macOS')
            LicenseUri   = 'https://github.com/YOUR_USERNAME/gcp-terraform-toolkit/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/YOUR_USERNAME/gcp-terraform-toolkit'
            ReleaseNotes = 'See CHANGELOG.md for release history.'
        }
    }
}
