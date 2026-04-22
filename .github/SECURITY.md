# Security Policy

## Supported Versions

Security fixes are applied to the active branch line and then promoted through sit -> uat -> main.

## Reporting a Vulnerability

Please do not open public issues for security reports.

1. Email the maintainer directly with reproduction details.
2. Include impact, affected flows, and proof of concept.
3. Allow time for triage and coordinated disclosure.

## Secrets Handling

- Never commit API keys, tokens, certificates, or private keys.
- Store deployment credentials only in GitHub Actions secrets.
- Keep signing material out of the repository.
