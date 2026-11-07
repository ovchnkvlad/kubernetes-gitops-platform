# Security policy

## Trust boundaries

Pull requests and rendered manifests are untrusted. CI has read-only repository
permissions, receives no kubeconfig or deployment credential, and never connects to a
cluster. Tool containers receive repository and render directories as read-only except
for their dedicated generated-output mounts.

Argo CD sources, destinations, and cluster-scoped resource types are allowlisted in
AppProjects. The workload project does not permit arbitrary cluster RBAC.

## Never commit

- Kubernetes Secrets or exported runtime credentials
- Kubeconfigs, service-account tokens, client certificates, or private keys
- Personal usernames or private repository URLs
- Argo CD admin passwords or repository credentials
- `.env` files or generated rendered manifests

Use short-lived identity and an external secret manager in a real environment. If SOPS is
introduced, commit only encrypted data and store its decryption key outside Git and CI
logs.

## Automated controls

- Helm validates the chart and its JSON values schema.
- Kubeconform checks rendered resources against Kubernetes schemas.
- Trivy blocks HIGH and CRITICAL Kubernetes misconfigurations.
- Pinned upstream charts are rendered from scratch on every CI run.
- Gitleaks scans the complete Git history.

## Reporting

Before publication, use the hosting platform's private vulnerability reporting feature.
Do not place credentials or exploitable cluster details in a public issue.
