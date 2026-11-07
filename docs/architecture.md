# Architecture

## Reconciliation model

The root Argo CD Application recursively reads only `gitops/projects/*.yaml` and
`gitops/applications/*.yaml`. It creates two explicit permission boundaries:

- `workloads` accepts only the portfolio repository and can target only the
  `platform-status` namespace.
- `observability` accepts the official Prometheus and Grafana chart repositories plus the
  portfolio repository used as a values source. It can target only `observability`.

Automated sync prunes removed resources and repairs drift. `ApplyOutOfSyncOnly` avoids
unnecessary writes; server-side apply is used for the large observability resource set.

## Workload security

The example chart creates a namespace at the Restricted Pod Security level. Its Pods:

- run as UID/GID 101;
- cannot gain privileges;
- use the runtime-default seccomp profile;
- drop every Linux capability;
- mount the root filesystem read-only;
- write only to size-limited `emptyDir` volumes;
- do not receive a service-account token;
- declare CPU and memory requests and limits.

Ingress is allowed only from namespaces named `ingress-nginx` and `observability`.
Egress is denied because the static workload has no outbound dependency. The Service is
ClusterIP-only.

## Availability controls

Two replicas, a zero-unavailable rolling update, readiness and liveness probes, and a
PodDisruptionBudget protect normal updates and voluntary disruption. This is an
educational local design, not a claim of multi-region availability.

## Observability trade-offs

The local stack pins `kube-prometheus-stack` and Loki rather than tracking floating chart
versions. Persistence is disabled to keep the lab disposable. Prometheus and Alertmanager
retain only 24 hours in ephemeral storage; Loki uses single-binary filesystem storage.

The observability namespace uses Privileged Pod Security enforcement because node
exporter requires host-level visibility. That exception is isolated from the restricted
workload namespace and documented rather than silently weakening every namespace.

## Secret boundary

No plaintext Secret resource is authored here. Grafana and other upstream components may
create runtime credentials during installation. Those values live only in the cluster.
Any future Git-managed secret must be encrypted before commit or resolved from an
external secret manager.
