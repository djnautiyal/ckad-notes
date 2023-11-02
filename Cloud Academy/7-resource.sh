cat << 'EOF' > load.yaml
apiVersion: v1
kind: Pod
metadata:
  name: load
spec:
  containers:
  - name: cpu-load
    image: cloudacademydevops/stress
    args:
    - -cpus
    - "2"
EOF

cat << 'EOF' > load-limited.yaml
apiVersion: v1
kind: Pod
metadata:
  name: load-limited
spec:
  containers:
  - name: cpu-load-limited
    image: cloudacademydevops/stress
    args:
    - -cpus
    - "2"
    resources:
      limits:
        cpu: "0.5" # half a core
        memory: "20Mi" # 20 mebibytes
      requests:
        cpu: "0.35" # 35% of a core
        memory: "10Mi" # 20 mebibytes
EOF

cat << 'EOF' > load.yaml
apiVersion: v1
kind: Pod
metadata:
  name: load
spec:
  containers:
  - name: cpu-load
    image: cloudacademydevops/stress
    args:
    - -cpus
    - "2"
    resources:
      requests:
        cpu: "1.7"
EOF