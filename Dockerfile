FROM python:3.12-alpine as base

RUN apk add --no-cache ca-certificates git

WORKDIR /app
COPY requirements.txt /requirements.txt
COPY flux_local/ ./flux_local
COPY setup.py .
COPY setup.cfg .

RUN pip install --no-cache-dir -r /requirements.txt
RUN pip install -e .

COPY --from=ghcr.io/fluxcd/flux-cli:v2.2.3              /usr/local/bin/flux              /usr/local/bin/flux
COPY --from=docker.io/alpine/helm:3.14.4                /usr/bin/helm                    /usr/local/bin/helm
COPY --from=docker.io/bitnami/kubectl:1.30.0            /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
COPY --from=registry.k8s.io/kustomize/kustomize:v5.4.1  /app/kustomize                   /usr/local/bin/kustomize
COPY --from=ghcr.io/kyverno/kyverno-cli:v1.12.1         /ko-app/kubectl-kyverno          /usr/local/bin/kyverno

USER 1001
ENTRYPOINT ["/usr/local/bin/flux-local"]
