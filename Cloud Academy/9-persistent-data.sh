cat << 'EOF' > pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: db-data
spec:
  # Only one node can mount the volume in Read/Write
  # mode at a time
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF
kubectl create -f pvc.yaml

cat << 'EOF' > db.yaml
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
    - name: data
      mountPath: /data/db
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: data
    # Declare the PVC to use for the volume
    persistentVolumeClaim:
      claimName: db-data
EOF
kubectl create -f db.yaml