
## Installing grafana via helm
- kubectl create namespace helm-test-install
- helm repo add grafana https://grafana.github.io/helm-charts
- helm repo update
- helm search repo grafana
- helm -n helm-test-install install my-grafana  grafana/grafana
- export POD_NAME=$(kubectl get pods --namespace helm-test-install -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=my-grafana" -o jsonpath="{.items[0].metadata.name}")
- kubectl --namespace helm-test-install port-forward $POD_NAME 3000
- helm -n helm-test-install delete my-grafana
- kubectl delete namespace helm-test-install

