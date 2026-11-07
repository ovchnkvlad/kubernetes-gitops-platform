# Local GitOps runbook

## Preconditions

- Docker is healthy.
- `kind`, `kubectl`, and `helm` are installed from verified releases.
- The repository has a public remote that Argo CD can read without a token.
- Every `example.invalid` source has been replaced with that reviewed remote URL.
- `make check` passes.

## Create the disposable cluster

The documented baseline is Kind v0.33.0, whose default node is Kubernetes 1.37.

```bash
kind create cluster --config bootstrap/kind-config.yaml
kubectl cluster-info --context kind-gitops-lab
```

The API server binds to `127.0.0.1`, so it is not exposed to the local network.

## Install Argo CD

Install the pinned v3.6.1 manifest from the official Argo CD release, then apply the root
Application:

```bash
kubectl create namespace argocd
kubectl apply --server-side --force-conflicts \
  --namespace argocd \
  --filename https://raw.githubusercontent.com/argoproj/argo-cd/v3.6.1/manifests/install.yaml
kubectl wait --namespace argocd \
  --for=condition=Available deployment/argocd-server \
  --timeout=300s
kubectl apply --filename bootstrap/root-application.yaml
```

Do not commit the generated admin credential or a kubeconfig. UI exposure and login are
deliberately outside this repository.

## Verify reconciliation

```bash
kubectl get applications --namespace argocd
kubectl get pods --all-namespaces
kubectl rollout status deployment/platform-status \
  --namespace platform-status \
  --timeout=180s
```

Investigate an unhealthy Application before forcing a sync. Check repository reachability,
project allowlists, chart versions, and rendered manifests in that order.

## Remove the lab

```bash
kind delete cluster --name gitops-lab
```

The command removes the disposable cluster containers and its in-cluster Secrets. Verify
the active kubectl context before running any delete operation.

## Rollback principles

Git is the rollback mechanism: revert the faulty commit and let Argo CD reconcile the
reviewed state. Avoid editing managed resources by hand because self-heal will overwrite
the change. Disable auto-sync only during an incident and document why.
