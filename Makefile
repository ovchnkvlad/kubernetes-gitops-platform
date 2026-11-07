HELM_IMAGE := alpine/helm:4.3.1
KUBECONFORM_IMAGE := ghcr.io/yannh/kubeconform:v0.8.0
TRIVY_IMAGE := aquasec/trivy:0.76.2
RENDER_DIR := $(CURDIR)/.rendered

.PHONY: prepare lint render schema security gitops external check clean

prepare:
	rm -rf "$(RENDER_DIR)"
	mkdir -p "$(RENDER_DIR)/workload" "$(RENDER_DIR)/monitoring" "$(RENDER_DIR)/logging"

lint:
	docker run --rm --volume "$(CURDIR):/workspace:ro" --workdir /workspace $(HELM_IMAGE) lint charts/platform-status

render: prepare
	docker run --rm --volume "$(CURDIR):/workspace:ro" --volume "$(RENDER_DIR)/workload:/output" --workdir /workspace $(HELM_IMAGE) template platform-status charts/platform-status --namespace platform-status --output-dir /output

schema: render
	docker run --rm --volume "$(RENDER_DIR)/workload:/manifests:ro" $(KUBECONFORM_IMAGE) -strict -summary /manifests

security: render
	docker run --rm --volume "$(RENDER_DIR)/workload:/manifests:ro" $(TRIVY_IMAGE) config --exit-code 1 --severity HIGH,CRITICAL /manifests

gitops:
	docker run --rm --volume "$(CURDIR):/workspace:ro" $(KUBECONFORM_IMAGE) -strict -ignore-missing-schemas -summary /workspace/bootstrap/root-application.yaml /workspace/gitops/projects/workloads.yaml /workspace/gitops/projects/observability.yaml /workspace/gitops/applications/platform-status.yaml /workspace/gitops/applications/monitoring.yaml /workspace/gitops/applications/logging.yaml

external: prepare
	docker run --rm --volume "$(CURDIR):/workspace:ro" --volume "$(RENDER_DIR)/monitoring:/output" --workdir /workspace $(HELM_IMAGE) template monitoring kube-prometheus-stack --repo https://prometheus-community.github.io/helm-charts --version 92.22.0 --namespace observability --values gitops/values/monitoring.yaml --output-dir /output
	docker run --rm --volume "$(CURDIR):/workspace:ro" --volume "$(RENDER_DIR)/logging:/output" --workdir /workspace $(HELM_IMAGE) template loki loki --repo https://grafana.github.io/helm-charts --version 7.5.0 --namespace observability --values gitops/values/loki.yaml --output-dir /output

check: lint schema security gitops external

clean:
	rm -rf "$(RENDER_DIR)"
