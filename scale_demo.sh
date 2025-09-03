#!/usr/bin/env bash
set -Eeuo pipefail

NS="voting"
APP="vote"
HPA_NAME="vote-hpa"
LOG="scale_evidence_$(date +%Y%m%d_%H%M%S).log"

echo "==[1/8] Checking cluster and namespace…"
kubectl cluster-info >/dev/null
kubectl get ns "${NS}" >/dev/null

echo "==[2/8] Ensure ${APP} has CPU requests/limits (required for HPA)…"
kubectl -n "${NS}" set resources deployment/${APP} \
  --containers=${APP} \
  --requests=cpu=50m,memory=64Mi \
  --limits=cpu=200m,memory=256Mi
kubectl -n "${NS}" rollout status deploy/${APP} --timeout=120s

echo "==[3/8] Create/Update HPA ${HPA_NAME} (min=2, max=6, target 70% CPU)…"
cat <<'YAML' | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: vote-hpa
  namespace: voting
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vote
  minReplicas: 2
  maxReplicas: 6
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
YAML

echo "==[4/8] Add header via Ingress so you SEE which pod serves requests…"
# Adds: X-Upstream-Addr: <pod-ip:port>
kubectl -n "${NS}" patch ingress voting-app-ingress \
  --type='json' \
  -p='[
    {"op":"add","path":"/metadata/annotations/nginx.ingress.kubernetes.io~1configuration-snippet","value":"add_header X-Upstream-Addr $upstream_addr always;"}
  ]' || true

echo "==[5/8] Resolve Ingress hostname…"
INGRESS_HOST="$(kubectl -n "${NS}" get ingress voting-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
if [[ -z "${INGRESS_HOST}" ]]; then
  echo "ERROR: Ingress hostname not ready."
  exit 1
fi
APP_URL="http://${INGRESS_HOST}/vote"
echo "Ingress: ${INGRESS_HOST}"
echo "Vote URL: ${APP_URL}"

echo "==[6/8] Start load for ~3 minutes (this should drive CPU up)…"
# Try hey first (smaller image). If image pull fails, fallback to curl loop.
kubectl -n "${NS}" delete pod loadgen --ignore-not-found >/dev/null 2>&1 || true
if kubectl -n "${NS}" run loadgen --image=ghcr.io/rakyll/hey:latest --restart=Never -- -z 180s -c 30 "${APP_URL}"; then
  echo "Started loadgen with hey."
else
  echo "hey image failed to pull; using curl loop fallback."
  kubectl -n "${NS}" run loadgen --image=curlimages/curl:8.9.1 --restart=Never -- /bin/sh -lc \
    "i=0; while [ \$i -lt 600 ]; do for j in 1 2 3 4 5; do curl -s \"${APP_URL}\" >/dev/null & done; sleep 1; i=\$((i+1)); done; wait"
fi

echo "==[7/8] Record evidence while HPA reacts (about 8 minutes)…"
{
  echo "===== SCALE DEMO START $(date -u) ====="
  echo "Vote URL: ${APP_URL}"
  echo "--- Initial state"
  kubectl -n "${NS}" get hpa "${HPA_NAME}" || true
  kubectl -n "${NS}" get deploy "${APP}" -o wide || true
  kubectl -n "${NS}" get pods -l app="${APP}" -o wide || true
  echo

  for i in $(seq 1 48); do
    echo "--- T+$((${i}*10))s $(date -u)"
    kubectl -n "${NS}" get hpa "${HPA_NAME}"
    kubectl -n "${NS}" get deploy "${APP}"
    kubectl -n "${NS}" get pods -l app="${APP}" -o wide

    # Grab which pod answered via the custom header (through Ingress)
    hdr="$(curl -sI "${APP_URL}" | awk 'BEGIN{IGNORECASE=1}/^X-Upstream-Addr:/{print $0}')"
    echo "Ingress header: ${hdr:-<none>}"

    # Optional: show CPU metrics if available
    kubectl -n "${NS}" top pods -l app="${APP}" 2>/dev/null || true
    echo
    sleep 10
  done
  echo "===== SCALE DEMO END $(date -u) ====="
} | tee -a "${LOG}"

echo "==[8/8] Done. Evidence saved to: ${LOG}"
echo
echo "Tips:"
echo "- Watch live:  kubectl -n ${NS} get hpa ${HPA_NAME} -w"
echo "- Pods live:   kubectl -n ${NS} get pods -l app=${APP} -w"
echo "- If you want to clean up HPA later: kubectl -n ${NS} delete hpa ${HPA_NAME}"
