# Validation record

Validation date: 2026-11-07

## Passed checks

| Check | Result |
| --- | --- |
| Helm 4.3.1 lint | Passed: 1 chart, 0 failures |
| Workload render | Passed: 7 resources generated |
| Kubeconform 0.8.0 | Passed: 7 valid, 0 invalid, 0 errors |
| Trivy 0.76.2 | Passed: 0 HIGH/CRITICAL findings |
| Argo CD manifest processing | Passed: 6 CRD resources parsed, schemas skipped |
| kube-prometheus-stack 92.22.0 | Pinned chart rendered successfully |
| Loki 7.5.0 | Pinned chart rendered successfully |

The Argo CD `Application` and `AppProject` resources were syntax-processed with
Kubeconform's missing-schema mode because their CRD schemas are not part of the built-in
Kubernetes schema catalog. The locally authored workload resources were all checked in
strict mode.

## Runtime boundary

A disposable Kind test was attempted with verified Kind v0.33.0, but the Kubernetes 1.37
node image did not finish downloading within the validation window. The operation was
stopped before any cluster container or kubeconfig-backed environment was created. No
runtime rollout claim is made in this record.

Reproduce the complete static and render suite with:

```bash
make check
make clean
```

Chart repositories, policies, and schema catalogs evolve, so this is dated evidence, not
a permanent guarantee.
