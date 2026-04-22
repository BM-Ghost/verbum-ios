# Verbum iOS - CI/CD Pipeline Setup Guide

Audience: Repository owner only. This covers secrets, environments, and branch protection for the workflows in .github/workflows.

## Pipeline Overview

| Workflow file | Trigger | Environment | Manual approval | Destination |
|---|---|---|---|---|
| 01-pr-validation.yml | PR -> dev / sit / uat / main | - | No | Status checks on PR |
| 02-ci-dev.yml | Push -> dev | - | No | Simulator build + test artifacts |
| 03-deploy-sit.yml | Push -> sit / manual | sit | No | Signed SIT IPA artifact |
| 04-deploy-uat.yml | Push -> uat / manual | uat | Yes | Signed UAT IPA artifact |
| 05-deploy-production.yml | Push -> main / manual | production | Yes | Signed production IPA + GitHub Release |
| 06-security-scan.yml | Weekly / Push -> main|uat / manual | - | No | Security analysis reports |

## Step 1 - Required GitHub Secrets

Go to Settings -> Secrets and variables -> Actions and add:

### Signing Secrets

| Secret name | Value |
|---|---|
| IOS_CERTIFICATE_P12_BASE64 | base64 of distribution .p12 certificate |
| IOS_CERTIFICATE_PASSWORD | certificate password |
| IOS_PROVISIONING_PROFILE_BASE64 | base64 of .mobileprovision profile |
| IOS_TEAM_ID | Apple Developer Team ID |

### App Store Connect (optional now, required for store upload)

| Secret name | Value |
|---|---|
| APP_STORE_CONNECT_KEY_ID | App Store Connect API key ID |
| APP_STORE_CONNECT_ISSUER_ID | App Store Connect issuer ID |
| APP_STORE_CONNECT_PRIVATE_KEY | Full private key text (.p8) |

## Step 2 - GitHub Environments

Create these environments in Settings -> Environments:

1. sit
- No required reviewers
- Deployment branches: sit only

2. uat
- Required reviewers: owner
- Deployment branches: uat only

3. production
- Required reviewers: owner
- Deployment branches: main only

## Step 3 - Branch Protection Rules

Create branch rules for dev, sit, uat, main.

For dev require status checks:

- Branch Naming Convention
- Engineering Guidelines
- Unit Tests
- Build Verification
- Dependency Review
- PR Gate

For sit, uat, and main use the same checks and restrict push access to owner.

Recommended on main:

- Require linear history
- Require signed commits

## Step 4 - Workflow Notes

- The signing material is imported to a temporary keychain during SIT/UAT/Production workflows.
- IPA export depends on an ExportOptions.plist generated in CI.
- Deployment to TestFlight/App Store is not enabled by default in these workflows; release artifacts are generated and attached to the workflow and GitHub Release.

## Step 5 - Quick Branching Strategy

feature-* / ft-* -> dev -> sit -> uat -> main

Contributor scope ends at opening clean PRs to dev with all local checks passing.
