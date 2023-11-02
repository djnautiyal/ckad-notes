cat << 'EOF' > pod-configmap.yaml
apiVersion: v1
kind: Pod
metadata:
  name: db
spec:
  containers:
  - image: mongo:4.0.6
    name: mongodb
    # Mount as volume
    volumeMounts:
    - name: config
      mountPath: /config
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: config
    # Declare the configMap to use for the volume
    configMap:
      name: app-config
EOF
kubectl create -f pod-configmap.yaml

cat << EOF > pod-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret
spec:
  containers:
  - image: busybox:1.30.1
    name: busybox
    args:
    - sleep
    - "3600"
    env:
    - name: PASSWORD      # Name of environment variable
      valueFrom:
        secretKeyRef:
          name: app-secret  # Name of secret
          key: password     # Name of secret key
EOF

kubectl create -f pod-secret.yaml