cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: coin-toss
spec:
  containers:
  - name: coin-toss
    image: busybox:1.33.1
    command: ["/bin/sh", "-c"]
    args:
    - >
      while true;
      do
        # Record coint tosses
        if [[ $(($RANDOM % 2)) -eq 0 ]]; then echo Heads; else echo Tails; fi >> /var/log/tosses.txt;
        sleep 1;
      done
    # Mount the log directory /var/log using a volume
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  # Declare log directory volume an emptyDir ephemeral volume
  volumes:
  - name: varlog
    emptyDir: {}
EOF


pod_node=$(kubectl get pod coin-toss -o jsonpath='{.status.hostIP}')
pod_id=$(kubectl get pod coin-toss -o jsonpath='{.metadata.uid}')
ssh $pod_node -oStrictHostKeyChecking=no sudo ls /var/lib/kubelet/pods/$pod_id/volumes/kubernetes.io~empty-dir/varlog



cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cache
spec:
  containers:
  - name: cache
    image: redis:6.2.5-alpine
    resources:
      requests:
        ephemeral-storage: "1Ki"
      limits:
        ephemeral-storage: "1Ki"
    volumeMounts:
    - name: ephemeral
      mountPath: "/data"
  volumes:
    - name: ephemeral
      emptyDir:
        sizeLimit: 1Ki
EOF