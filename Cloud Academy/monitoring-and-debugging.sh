cat << 'EOF' > pod-readiness.yaml
apiVersion: v1
kind: Pod
metadata:
labels:
  test: readiness
name: readiness-http
spec:
  containers:
  - name: readiness
    image: httpd:2.4.38-alpine
    ports:
    - containerPort: 80
    # Sleep for 30 seconds before starting the server
    command: ["/bin/sh","-c"]
    args: ["sleep 30 && httpd-foreground"]
    readinessProbe:
      httpGet:
      path: /
      port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
EOF
kubectl create -f pod-readiness.yaml


cat << 'EOF' > pod-liveness.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-tcp
spec:
containers:
- name: liveness
  image: busybox:1.30.1
  ports:
  - containerPort: 8888
  # Listen on port 8888 for 30 seconds, then sleep
  command: ["/bin/sh", "-c"]
  args: ["timeout 30 nc -p 8888 -lke echo hi && sleep 600"]
  livenessProbe:
    tcpSocket:
    port: 8888
    initialDelaySeconds: 3
    periodSeconds: 5
EOF
kubectl create -f pod-liveness.yaml