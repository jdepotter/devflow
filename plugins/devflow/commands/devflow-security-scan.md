---
name: devflow-security-scan
description: Scan changed files for security issues — secrets, injection risks, debug code, dependency vulnerabilities.
argument-hint: "[base-ref]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*) Edit(*)
---

Security scan on the current branch.

Read `.claude/devflow.yaml`.

## Flow

1. Gather diff and read each changed file in full.

2. Check for:
   - **Secrets**: API keys (`sk-`, `AKIA`, `ghp_`), tokens, passwords, private keys
   - **Env exposure**: `.env` files staged, secrets in committed config
   - **Debug code**: `console.log`, `print()`, `fmt.Println`, `dbg!` in non-test paths
   - **Injection**: SQL string concatenation, unsanitized HTML
   - **Hardcoded URLs**: production URLs/IPs in source
   - **Permissions**: `chmod 777`, world-readable
   - **Credentials in URLs**: `https://user:pass@host`

3. Report with severity (🔴 HIGH / 🟡 LOW). No issues → "Scan passed." Stop.

4. Ask:
   - `Fix all automatically`
   - `Show details`
   - `Ignore and continue`

5. Fix, commit: `fix: address security scan findings`
