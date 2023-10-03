# Hands-ON lab
## Kubernetes Pod Design for Application Developers
### Definition Basics
- alias k=kubectl
- alias k_ns='kubectl config set-context --current'
- watch kubectl get nodes
- source <(kubectl completion bash)
- kubectl explain Pod.spec.containers.image
- kubectl get pod first-pod -o yaml | less
- k config current-context
- k explain deploy --recursive=true | less

### Labels, Selectors, and Annotations
- kubectl get pods -L color,tier
- kubectl get pods -l color
- kubectl get pods -L color,tier -l color
- kubectl get pods -L color,tier -l color --show-labels
- kubectl get pods -l color=redk config
- kubectl get pods -L color,tier -l '!color'
- kubectl get pods -l color!=red -L color,tier --show-labels
- kubectl get pods -l color!=red,tier=frontend -L color,tier --show-labels
- kubectl get pods -L color,tier -l 'color in (blue,green)'
- kubectl describe pod red-frontend | grep Annotations
- kubectl annotate pod red-frontend Lab- && kubectl describe pod red-frontend | grep Annotations -A 2

### Deployments
- kubectl config set-context --current  --namespace=deployment
- kubectl explain deployment.spec.selector
- kubectl explain deployments.spec.strategy.rollingUpdate
- kubectl create deployment --image=httpd:2.4.38 web-server --dry-run=client -o yaml
- kubectl rollout history deployment web-server

### Jobs and Cronjobs
- kubectl explain job.spec | less
- kubectl create job one-off --image=alpine -- sleep 30

## Kubernetes Observability
### Logging
- kubectl logs pod-logs server
- kubectl logs -f --tail=1 --timestamps pod-logs client
- kubectl exec webserver-logs -- tail -10 conf/httpd.conf
- kubectl cp webserver-logs:conf/httpd.conf local-copy-of-httpd.conf
- s3_bucket=$(aws s3api list-buckets --query "Buckets[].Name" --output table | grep logs | tr -d \|)

### Monitoring and Debugging
Readiness probes are used to detect when a Pod is unable to serve traffic, such as during startup when large amounts of data are being loaded or caches are being warmed. When a readiness probe fails, it means that the Pod needs more time to become ready to serve traffic. When the Pod is accessed through a Kubernetes Service, the Service will not serve traffic to any Pods that have a failing readiness probe.
Liveness probes are used to detect when a Pod fails to make progress after entering a broken state, such as deadlock. The issues causing the Pod to enter such a broken state are bugs, but by detecting a Pod is in a broken state allows Kubernetes to restart the Pod and allow progress to be made, perhaps only temporarily until arriving at the broken state again. The application availability is improved compared to leaving the Pod in the broken state.
Startup probes are used when an application starts slowly and may otherwise be killed due to failed liveness probes. The startup probe runs before both readiness and liveness probes. The startup probe can be configured with a startup time that is longer than the time needed to detect a broken state for a container after it has started.

- kubectl exec readiness-http -- pkill httpd
- kubectl get pods --all-namespaces
- kubectl explain pod.spec.containers.resources
- kubectl top pod -n kube-system --containers

See if you can identify which container uses the most CPU or memory in the kube-system namespace.
- kubectl top pod -n kube-system --containers --sort-by=memory
- kubectl top pod -n kube-system --containers --sort-by=cpu

See if you can get the last 10 lines out of one of kube-proxy Pods' /etc/mtab file.
1. kubectl get pods --namespace=kube-system | grep kube-proxy
2. kubectl exec -n kube-system kube-proxy-t24jr -- tail -n 10 /etc/mtab

## Mastering Kubernetes Pod Configuration
### Defining Resource Requirements
- k top nodes
- k top pods


    The resources key is added to specify the limits and requests. The Pod will only be scheduled on a Node with 0.35 CPU cores and 10MiB of memory available. It's important to note that the scheduler doesn't consider the actual resource utilization of the node. Rather, it bases its decision upon the sum of container resource requests on the node. For example, if a container requests all the CPU of a node but is actually 0% CPU, the scheduler would treat the node as not having any CPU available. In the context of this lab, the load Pod is consuming 2 CPUs on a Node but because it didn't make any request for the CPU, its usage doesn't impact following scheduling requests.
    Containers that exceed their memory limits will be terminated and restarted if possible.
    Containers that exceed their memory request may be evicted when the node runs out of memory.
    Containers that exceed their CPU limits may be allowed to exceed the limit depending on the other Pods on the node. Containers will not be terminated for exceeding CPU limits.

### Security Contexts
- kubectl explain pod.spec.securityContext | less
- kubectl explain pod.spec.containers.securityContext | less
- kubectl exec security-context-test-2 -- ls /dev
- kubectl exec security-context-test-3 -it -- /bin/sh

### Persistent Data
- kubectl get pvc
- kubectl exec db -it -- mongo testdb --quiet --eval \
  'db.messages.insert({"message": "I was here"}); db.messages.findOne().message'
- kubectl exec db -it -- mongo testdb --quiet --eval 'db.messages.findOne().message'

### Config Maps and Secrets
- kubectl create configmap app-config --from-literal=DB_NAME=testdb \
    --from-literal=COLLECTION_NAME=messages
- kubectl get configmaps app-config -o yaml
- kubectl exec db -it -- ls /config
- kubectl exec db -it -- cat /config/DB_NAME && echo
- kubectl create configmap --help | less
- k create secret generic app-secret --from-literal=password=1234567
- kubectl get secret app-secret -o yaml #base-64 encoded
- kubectl explain secret
- kubectl get secret app-secret -o jsonpath="{.data.password}" \
  | base64 --decode \
  && echo
- kubectl exec pod-secret -- /bin/sh -c 'echo $PASSWORD'

### Service Accounts
- kubectl run default-pod --image=mongo:4.0.6
- kubectl get pod default-pod -o yaml | less
- k create sa app-sa


### Utilizing Ephemeral Volume Types in Kubernetes
- kubectl exec coin-toss -- wc -l /var/log/tosses.txt
- kubectl set image pod coin-toss coin-toss=busybox:1.34.0
- kubectl get pods -w
- kubectl explain pod.spec.volumes.emptyDir

### Control Kubernetes Network traffic with Network policies
- kubectl get networkpolicy deny-metadata -o yaml
- kubectl explain networkpolicy.spec.egress
- kubectl explain networkpolicy.spec.egress.to
- kubectl explain networkpolicy.spec.egress.to.ipBlock
- kubectl run busybox --image=busybox --rm -it /bin/sh
- kubectl attach busybox -c busybox -i -t
- kubectl run busybox --image=busybox --rm -it -n test /bin/sh
- role=$(wget -qO- 169.254.169.254/latest/meta-data/iam/security-credentials)
  wget -qO- 169.254.169.254/latest/meta-data/iam/security-credentials/$role
- kubectl run web-server -n test -l app-tier=web --image=nginx:1.15.1 --port 80
- web_ip=$(kubectl get pod -n test -o jsonpath='{.items[0].status.podIP}')
- kubectl run busybox -n test -l app-tier=cache --image=busybox --env="web_ip=$web_ip" --rm -it /bin/sh
  wget $web_ip
- kubectl run busybox -n test --image=busybox --env="web_ip=$web_ip" --rm -it /bin/sh
  wget $web_ip

## All the components of the cluster are running in pods in the kube-system namespace:
- calico: The container network used to connect each node to every other node in the cluster. Calico also supports network policy. Calico is one of many possible container networks that can be used by Kubernetes. 
- coredns: Provides DNS services to nodes in the cluster 
- etcd: The primary data store of all cluster state 
- kube-apiserver: The REST API server for managing the Kubernetes cluster 
- kube-controller-manager: Manager of all of the controllers in the cluster that monitor and change the cluster state when necessary 
- kube-proxy: Network proxy that runs on each node 
- kube-scheduler: Control plane process which assigns Pods to Nodes 
- metrics-server: Not an essential component of a Kubernetes cluster but it is used in this lab to provide metrics for viewing in the Kubernetes dashboard. 
- ebs-csi: Not an essential component of a Kubernetes cluster but is used to manage the lifecycle of Amazon EBS volumes for persistent volumes.

## Headless service
Headless Service: A headless service is a Kubernetes service resource that won't load balance behind a single service IP. 
Instead, a headless service returns a list of DNS records that point directly to the pods that back the service. A headless service is defined by declaring the clusterIP property in a service spec and setting the value to None. 
StatefulSets currently require a headless service to identify pods in the cluster network.

## Stateful sets
Similar to Deployments in Kubernetes, StatefulSets manage the deployment and scaling of pods given a container spec. 
StatefulSets differ from Deployments in that the Pods in a stateful set are not interchangeable. 
Each pod in a StatefulSet has a persistent identifier that it maintains across any rescheduling. 
The pods in a StatefulSet are also ordered. This provides a guarantee that one pod can be created before following pods. 

## PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs)
PVs are Kubernetes resources that represent storage in the cluster. 
Unlike regular Volumes which exist only until while containing pod exists, PVs do not have a lifetime connected to a pod. 
Thus, they can be used by multiple pods over time, or even at the same time. 
Different types of storage can be used by PVs including NFS, iSCSI, and cloud-provided storage volumes, such as AWS EBS volumes. Pods claim PV resources through PVCs.




