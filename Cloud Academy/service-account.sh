cat << 'EOF' > pod-custom-sa.yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-sa-pod
spec:
  containers:
  - image: mongo:4.0.6
    name: mongodb
  serviceAccount: app-sa
EOF
kubectl create -f pod-custom-sa.yaml