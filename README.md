# Kubernetes GitOps Platform

A local-first GitOps reference project built around Helm, Argo CD, Kubernetes security
controls, and observability.

> Status: repository scaffold. Workload, GitOps, validation, and documentation milestones
> are added as separate commits.

## Safety principles

- No passwords, tokens, kubeconfigs, personal usernames, or real repository URLs
- No plaintext Kubernetes `Secret` resources
- No automatic production deployment
- Namespaced Argo CD permissions and explicit source allowlists
- Render and policy checks before any cluster reconciliation
