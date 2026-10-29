# Security policy

Tabibu handles health information: pathology cases, results, appointments and outbreak alerts.
I take reports about it seriously and handle them privately.

## Supported versions

| Version | Supported |
|---|---|
| The latest release, and `main` | Yes |
| Any earlier build | No: update to the latest release |

## Reporting a vulnerability

Report privately through GitHub:
**[Report a vulnerability](https://github.com/Wauguzi/tabibu/security/advisories/new)** (the
**Security** tab, then **Report a vulnerability**). Only the repository admins can see the
report.

Please do not open a public issue, pull request or discussion about a vulnerability.

A useful report includes:

- what is affected: the app (and which role: patient, doctor or pathologist), the Firestore or
  Storage rules, the Cloud Functions, or the AI service;
- the steps to reproduce it, and what you expected instead;
- the impact as you see it: whose data, or which action, it exposes.

**Never include real patient information**: no names, phone numbers, results, or images of
slides or smears. Use your own test account and made-up data.

## What happens next

- I acknowledge the report within 3 working days.
- I confirm or rule out the issue, with a severity, within 10 working days.
- A confirmed issue is fixed in a private fork of the advisory, then released. I publish the
  advisory once a fixed release is out, and credit you unless you ask me not to.

## Scope

In scope: this repository's app, its `firestore.rules` and `storage.rules`, the code under
`functions/`, and the AI service under `ai_service/`. The design these protect is in the
[threat model](docs/security/reports/firebase_and_ai_service_threat_model.md).

Out of scope: vulnerabilities in the third-party services Tabibu runs on (report those to
their vendors), denial of service, social engineering, and findings that need a rooted or
jailbroken device.

## Good-faith research

I will not pursue research that follows this policy: it uses only accounts you own, stops at
the first sign of someone else's data and does not keep or share it, and gives me time to fix
the issue before it is disclosed.
