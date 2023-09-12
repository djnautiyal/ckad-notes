cat << 'EOF' > pod-fail.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pod-fail
spec:
  backoffLimit: 3
  completions: 6
  parallelism: 2
template:
  spec:
    containers:
    - image: alpine
      name: fail
      command: ['sleep 20 && exit 1']
      restartPolicy: Never
EOF
kubectl create -f pod-fail.yaml

cat << 'EOF' > cronjob-example.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cronjob-example
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
  spec:
    template:
    spec:
    containers:
    - image: alpine
      name: fail
      command: ['date']
      restartPolicy: Never
EOF
kubectl create -f cronjob-example.yaml