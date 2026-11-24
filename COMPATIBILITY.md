# Compatibility baseline

This repository keeps a self-contained public baseline; it does not depend on private Golden links.

**Owner requirement (2026-11-25):** every platform, site, application, tool or template we build is designed for the broad practical matrix of devices, versions, browsers and operating systems it claims to support. This file records target and evidence rules; it does not claim universal or untested compatibility.

| Field | Current project record |
| --- | --- |
| Profile | Public PowerShell/Terraform CLI module |
| Target matrix | Windows, macOS and Linux shells, PowerShell 5.1/7+ where claimed, Terraform/gcloud/git versions and terminal capabilities; no GUI/browser surface is claimed. |
| Current compatibility claim | None beyond separately dated, exact-commit evidence. Unknown combinations remain NOT_RUN or BLOCKED. |
| Release boundary | A critical layout, input, accessibility, startup, data-loss, export/openability or rollback unknown blocks the affected support claim and broader release until resolved. |

Record each applicable row as **UNASSESSED**, **NOT_RUN**, **FAIL**, **PARTIAL**, **PASS**, **BLOCKED**, **EXPIRED_EVIDENCE** or **NOT APPLICABLE** with reason. Evidence names the exact commit/artifact, device/emulator/browser/OS/runtime version, method, date, owner/reviewer and artifact. One local browser, emulator, screenshot or green CI run is not broad compatibility PASS.

Unsupported or unknown combinations must be explicit in release notes or user-facing status. Keep target, current evidence and release decision separate.
