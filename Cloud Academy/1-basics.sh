cat << 'EOF' > first-pod.yaml
apiVersion: v1            # The API path for the Pod resource
kind: Pod                 # The kind of resource (Pod)
metadata:
  name: first-pod         # Name of the Pod
spec:
  containers:             # List of containers in the Pod
  - image: httpd:2.4.38   # Container image (using a tag to specify version 2.4.38)
    name: first-container # Name of the container
EOF