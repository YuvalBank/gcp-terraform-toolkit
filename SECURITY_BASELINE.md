# Public security engineering baseline

**Revision:** 2026-11-24.2
**Status:** Target baseline for public PowerShell/Terraform tooling; it is not a claim of current compliance or release readiness.

Security is a mandatory design-time requirement for every new code path and every change, from planning through implementation, independent review, acceptance and release. It is not a final checklist item.

## Applicability

| Surface | Required profile |
| --- | --- |
| Public CLI and module functions | NIST SSDF SP 800-218 Rev. 1.1 and OpenSSF OSPS Baseline 2026.08.28 |
| External command/process execution | Explicit command existence checks, argument separation, output/error handling and safe failure |
| Clipboard, file, network or user-controlled input | Strict parsing, allow-lists, no arbitrary execution and malicious-input tests |
| Credentials and cloud authentication | No secrets in source, logs, tests, issues or examples; least privilege and clear user prompts |
| Destructive operations | `-WhatIf`/`-Confirm`, explicit scope and tested rollback/abort paths where feasible |
| Dependencies and release artifacts | Locking/version review where applicable, vulnerability review, provenance, signed/published artifacts as supported |

Primary references:
- [NIST SSDF SP 800-218 Rev. 1.1](https://csrc.nist.gov/pubs/sp/800/218/r1/final)
- [OpenSSF OSPS Baseline 2026.08.28 checklist](https://baseline.openssf.org/versions/2026-08-28-checklist.md)

## Evidence rule

Record each applicable control with one status: **UNASSESSED**, **NOT_RUN**, **FAIL**, **PARTIAL**, **PASS**, **BLOCKED**, **EXPIRED_EVIDENCE** or **NOT APPLICABLE** with reason. Evidence names the exact commit/revision, environment, method, date, owner/reviewer and artifact. Green CI, lint, a scanner, a library's reputation or this file alone is not **PASS**.

Evidence expires when the relevant code, dependency, workflow, environment, threat model or assumptions change. The owner must set a review date for accepted residual risk.

## Release boundary

Before acceptance or release, record the baseline revision, applicable profile, evidence status for each applicable control, exception owner/expiry where used, and the release decision. Critical credential handling, arbitrary-input execution, destructive-operation, dependency/supply-chain, isolation or recovery unknowns block the affected release until resolved.

This baseline sets engineering targets and evidence requirements. It does not claim certification, regulatory compliance or current implementation completeness.
