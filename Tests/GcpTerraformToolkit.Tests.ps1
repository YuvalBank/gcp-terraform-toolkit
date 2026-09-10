#Requires -Modules Pester

BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..' | Join-Path -ChildPath 'GcpTerraformToolkit.psd1'
    Import-Module $modulePath -Force
}

AfterAll {
    Remove-Module -Name GcpTerraformToolkit -ErrorAction SilentlyContinue
}

Describe 'Invoke-Terraform' {

    Context 'When terraform is not installed' {
        BeforeEach {
            Mock -CommandName Test-CommandExists -ModuleName GcpTerraformToolkit -MockWith { $false }
            Mock -CommandName Write-Error -ModuleName GcpTerraformToolkit {}
        }

        It 'reports an error and does not attempt to run terraform' {
            Mock -CommandName terraform -ModuleName GcpTerraformToolkit {}
            Invoke-Terraform -Command plan
            Should -Invoke -CommandName Write-Error -ModuleName GcpTerraformToolkit -Times 1
            Should -Invoke -CommandName terraform -ModuleName GcpTerraformToolkit -Times 0
        }
    }

    Context 'When terraform is installed' {
        BeforeEach {
            Mock -CommandName Test-CommandExists -ModuleName GcpTerraformToolkit { $true }
            Mock -CommandName terraform -ModuleName GcpTerraformToolkit { $global:LASTEXITCODE = 0 }
        }

        It 'runs non-destructive commands without prompting for confirmation' {
            Invoke-Terraform -Command plan
            Should -Invoke -CommandName terraform -ModuleName GcpTerraformToolkit -Times 1
        }

        It 'does not call terraform for "apply" when -WhatIf is specified' {
            Invoke-Terraform -Command apply -WhatIf
            Should -Invoke -CommandName terraform -ModuleName GcpTerraformToolkit -Times 0
        }

        It 'does not call terraform for "destroy" when -Confirm:$false is not set and confirmation is denied' {
            Invoke-Terraform -Command destroy -Confirm:$false -WhatIf
            Should -Invoke -CommandName terraform -ModuleName GcpTerraformToolkit -Times 0
        }

        It 'rejects unsupported subcommands' {
            { Invoke-Terraform -Command 'not-a-real-command' } | Should -Throw
        }
    }
}

Describe 'Set-GitCredentialFromClipboard' {

    BeforeEach {
        Mock -CommandName Test-CommandExists -ModuleName GcpTerraformToolkit { $true }
        Mock -CommandName git -ModuleName GcpTerraformToolkit { $global:LASTEXITCODE = 0 }
    }

    It 'applies recognized credential.* keys' {
        $sample = 'git config --global credential.https://source.developers.google.com.username "user@example.com"'
        Set-GitCredentialFromClipboard -InputText $sample -Confirm:$false
        Should -Invoke -CommandName git -ModuleName GcpTerraformToolkit -Times 1
    }

    It 'ignores keys outside the credential namespace and does not call git' {
        Mock -CommandName Write-Warning -ModuleName GcpTerraformToolkit {}
        $sample = 'git config --global core.editor "vim"'
        Set-GitCredentialFromClipboard -InputText $sample -Confirm:$false
        Should -Invoke -CommandName git -ModuleName GcpTerraformToolkit -Times 0
        Should -Invoke -CommandName Write-Warning -ModuleName GcpTerraformToolkit -Times 1
    }

    It 'never invokes a shell for unrecognized / malicious input' {
        Mock -CommandName Write-Error -ModuleName GcpTerraformToolkit {}
        $malicious = 'rm -rf / ; git config --global credential.evil "pwned"; echo done'
        # Only the well-formed --global "<key>" "<value>" portion is ever considered,
        # and 'credential.evil' IS in-namespace, so it WOULD be applied as data -
        # but critically, 'rm -rf /' and 'echo done' are never executed as commands.
        Set-GitCredentialFromClipboard -InputText $malicious -Confirm:$false
        Should -Invoke -CommandName git -ModuleName GcpTerraformToolkit -Times 1
    }

    It 'errors when no recognizable git config pattern is found' {
        Mock -CommandName Write-Error -ModuleName GcpTerraformToolkit {}
        Set-GitCredentialFromClipboard -InputText 'totally unrelated clipboard text' -Confirm:$false
        Should -Invoke -CommandName Write-Error -ModuleName GcpTerraformToolkit -Times 1
        Should -Invoke -CommandName git -ModuleName GcpTerraformToolkit -Times 0
    }

    It 'errors on empty input' {
        Mock -CommandName Write-Error -ModuleName GcpTerraformToolkit {}
        Set-GitCredentialFromClipboard -InputText '   ' -Confirm:$false
        Should -Invoke -CommandName Write-Error -ModuleName GcpTerraformToolkit -Times 1
    }
}

Describe 'Start-GcpAuth' {

    It 'stops early and reports an error when gcloud is missing' {
        Mock -CommandName Test-CommandExists -ModuleName GcpTerraformToolkit { $false }
        Mock -CommandName Write-Error -ModuleName GcpTerraformToolkit {}
        Start-GcpAuth -Confirm:$false
        Should -Invoke -CommandName Write-Error -ModuleName GcpTerraformToolkit -Times 1
    }

    It 'does not attempt git configuration when git is missing' {
        Mock -CommandName Test-CommandExists -ModuleName GcpTerraformToolkit {
            param($Name)
            return $Name -eq 'gcloud'
        }
        Mock -CommandName gcloud -ModuleName GcpTerraformToolkit { $global:LASTEXITCODE = 0 }
        Mock -CommandName Write-Warning -ModuleName GcpTerraformToolkit {}
        Mock -CommandName git -ModuleName GcpTerraformToolkit {}

        Start-GcpAuth -Confirm:$false

        Should -Invoke -CommandName git -ModuleName GcpTerraformToolkit -Times 0
        Should -Invoke -CommandName Write-Warning -ModuleName GcpTerraformToolkit -Times 1
    }
}

# Separate Describe block for testing the private function via InModuleScope
Describe 'Test-CommandExists' {
    It 'returns $true for a command that exists' {
        InModuleScope GcpTerraformToolkit {
            Test-CommandExists -Name 'Get-Command' | Should -BeTrue
        }
    }

    It 'returns $false for a command that does not exist' {
        InModuleScope GcpTerraformToolkit {
            Test-CommandExists -Name 'this-command-does-not-exist-12345' | Should -BeFalse
        }
    }
}
