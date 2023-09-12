### Image location
gcr.io/kuar-demo/kuard-amd64:blue

### Basic windows commads for file
- mkdir pods
- rmdir jobs
- rmdir file.txt
- type NUL > file.txt

## Commands I run to create docker runtime instance
- docker run -d --name kuard -p 8080:8080 --memory 200m --memory-swap 1G gcr.io/kuar-demo/kuard-amd64:blue
- docker stop kuard
- docker rm kuard

## node-related commands
- kubectl get componentstatus
- kubectl version
- kubectl get nodes
- kubectl describe node docker-deskop
- kubectl get ns
- kubectl get daemonSets --namespace=kube-system kube-proxy
- kubectl get deployments --namespace=kube-system coredns
- kubectl get services --namespace=kube-system kube-dns

## namespace-related commands
- kubectl get ns
- kubectl create ns kuard-demo
- kubectl config get-contexts
- kubectl config set-context my-context --namespace=kuard-demo --user=docker-desktop --cluster=docker-desktop
- kubectl config view
- kubectl config use-context my-context

## K8s pod-related commands
- kubectl run kuard --image=gcr.io/kuar-demo/kuard-amd64:blue
- kubectl get pods
- kubectl apply -f kuard-pod.yaml
- kubectl describe pods kuard
- kubectl logs kuard
- kubectl exec -it kuard -- ash
- kubectl port-forward kuard 8080:8080
- kubectl delete pods/kuard

## Label-related commands
- kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:blue --port=8080 --replicas=2
- kubectl label deployments alpaca-prod "ver=1"
- kubectl label deployments alpaca-prod "env=prod"
- kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:blue --port=8080 --labels="ver=1,app=alpaca,env=prod" #doesn't work

- kubectl create deployment alpaca-test --image=gcr.io/kuar-demo/kuard-amd64:green  --replicas=1  --port=8080 #labels added "ver=2,env=test"
- kubectl create deployment bandicoot-prod --image=gcr.io/kuar-demo/kuard-amd64:green --replicas=2 #labels added "ver=2,env=prod"
- kubectl create deployment bandicoot-staging --image=gcr.io/kuar-demo/kuard-amd64:green --replicas=1 #labels added"ver=2,env=staging"
        
## Replicas and scaling related commands
- kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:blue --port=8080 --replicas=2
- kubectl scale deployment alpaca-prod --replicas 3

## Service Discovery related commands
- kubectl expose deployment alpaca-prod
- kubectl describe service alpaca-prod

| Key               | Value                       |
|-------------------|-----------------------------|
| Name:             | alpaca-prod                 |
| Namespace:        | kuard-demo                  |
| Labels:           | app=alpaca-prod             |
| Annotations:      | <none>                      |
| Selector:         | app=alpaca-prod             |
| Type:             | ClusterIP                   |
| IP Family Policy: | SingleStack                 |
| IP Families:      | IPv4                        |
| IP:               | 10.110.252.70               |
| IPs:              | 10.110.252.70               |
| Port:             | <unset>  8080/TCP           |
| TargetPort:       | 8080/TCP                    |
| Endpoints:        | 10.1.0.6:8080,10.1.0.7:8080 |
| Session Affinity: | None                        |
| Events:           | None                        |

- kubectl get pods -l app=alpaca-prod -o jsonpath='{.items[0].metadata.name}'    #to fetch pods name ALPACA_POD
- All commands are same, required only for cluster IPs        #Required only for service type clusterIP
  - kubectl port-forward pods/alpaca-prod-7786f5894c-cb9s5 48858:8080  
  - kubectl port-forward alpaca-prod-7786f5894c-cb9s5 48858:8080
  - kubectl port-forward deployment/alpaca-prod 48858:8080
  - kubectl port-forward replicaset/alpaca-prod-7786f5894c 48858:8080
  - kubectl port-forward service/alpaca-prod 48858:8080
- kubectl expose deployment alpaca-prod --type=NodePort
- kubectl describe service alpaca-prod

| Key                      | Value                       |
|--------------------------|-----------------------------|
| Name:                    | alpaca-prod                 |
| Namespace:               | kuard-demo                  |
| Labels:                  | app=alpaca-prod             |
| Annotations:             | <none>                      |
| Selector:                | app=alpaca-prod             |
| Type:                    | NodePort                    |
| IP Family Policy:        | SingleStack                 |
| IP Families:             | IPv4                        |
| IP:                      | 10.99.82.174                |
| IPs:                     | 10.99.82.174                |
| LoadBalancer Ingress:    | localhost                   |
| Port:                    | <unset>  8080/TCP           |
| TargetPort:              | 8080/TCP                    |
| NodePort:                | <unset>  30272/TCP          |    # You call this in localhost
| Endpoints:               | 10.1.0.6:8080,10.1.0.7:8080 |
| Session Affinity:        | None                        |
| External Traffic Policy: | Cluster                     |
| Events:                  | <none>                      |

- kubectl expose deployment alpaca-prod --type=LoadBalancer

| Key                      | Value                       |
|--------------------------|-----------------------------|
| Name:                    | alpaca-prod                 |
| Namespace:               | kuard-demo                  |
| Labels:                  | app=alpaca-prod             |
| Annotations:             | <none>                      |
| Selector:                | app=alpaca-prod             |
| Type:                    | LoadBalancer                |
| IP Family Policy:        | SingleStack                 |
| IP Families:             | IPv4                        |
| IP:                      | 10.110.245.27               |
| IPs:                     | 10.110.245.27               |
| LoadBalancer Ingress:    | localhost                   |
| Port:                    | <unset>  8080/TCP           |
| TargetPort:              | 8080/TCP                    |    
| NodePort:                | <unset>  31951/TCP          |
| Endpoints:               | 10.1.0.6:8080,10.1.0.7:8080 |
| Session Affinity:        | None                        |
| External Traffic Policy: | Cluster                     |
| Events:                  | <none>                      |

- kubectl describe endpoints alpaca-prod


## Ingress related commands
- kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
- kubectl describe  service envoy -n projectcontour 
- kubectl get service envoy -o wide -n projectcontour

- kubectl create deployment be-default --image=gcr.io/kuar-demo/kuard-amd64:blue --port=8080 --replicas=3
- kubectl create deployment alpaca --image=gcr.io/kuar-demo/kuard-amd64:green --port=8080 --replicas=3
- kubectl create deployment bandicoot --image=gcr.io/kuar-demo/kuard-amd64:purple --port=8080 --replicas=3
- kubectl expose deployment be-default
- kubectl expose deployment alpaca
- kubectl expose deployment bandicoot
- kubectl get services -o wide

- kubectl apply -f simple-ingress.yaml
- kubectl get ing
- kubectl describe ing simple-ingress
- kubectl apply -f host-ingress.yaml

## Replicaset related commands
- kubectl apply -f kuard-rs.yaml
- kubect describe rs kuard
- kubectl get pods -l app=kaurd,version=2
- kubectl get pods kuard-csj26 -o=jsonpath='{.metadata.ownerReferences[0].name}'
- kubectl scale replicasets kuard --replicas=3
- kubectl get pods -n kube-system | findstr metrics-server  # should fail
- kubectl top node           # it should fail. Enable metrics-server
- kubectl delete rs kuard --cascade=false

## Deployment related commands
- kubectl create -f .\kuard-deployment.yaml
- kubectl get deployments kuard -o=jsonpath='{.spec.selector.matchLabels}'
- kubectl get rs --selector=run=kuard
- kubectl scale deployments kuard --replicas=2
- kubectl scale rs kuard-645b4bff86 --replicas=1    #doesn't work because of deployments
- kubectl get deployments kuard -o yaml > kuard-deployment.yaml
- kubectl replace -f kuard-deployment.yaml --save-config
- kubectl rollout status deployments kuard
- kubectl get replicasets -o wide
- kubectl rollout pause deployments kuard
- kubectl rollout resume deployments kuard
- kubectl rollout history deployments kuard
- kubectl rollout history deployments kuard --revision=3
- kubectl rollout undo deployments kuard
- kubectl rollout undo deployments kuard --to-revision=3

## DaemonSet related commands
- kubectl apply -f fluentd.yaml
- kubectl describe daemonset fluentd
- kubectl get pods -o wide -l app=fluent
- kubectl label nodes docker-desktop ssd=true
- kubectl get nodes --selector ssd=true 
- kubectl rollout status daemonSets

### To run script, download git bash
## Jobs related commands
- kubectl run -i oneshot --image=gcr.io/kuar-demo/kuard-amd64:blue --restart=OnFailure --command /kuard -- --keygen-enable --keygen-exit-on-complete --keygen-num-to-gen 10
- kubectl get jobs -A
- kubectl delete pods oneshot
- kubectl logs oneshot-jr9j4
- kubectl logs oneshot-jr9j4 --tail=100
- kubectl get pods -l job-name=oneshot -A
- kubectl get pods --watch
- kubctl apply -f rs-queue.yaml

## Configmap and secret related commands
- kubectl create configmap my-config --from-file=my-config.txt --from-literal=extra-param=extra-value --from-literal=another-param=another-value
- kubectl delete  configmap my-config
- kubectl get configmaps my-config -o yaml
- kubectl apply -f kuard-config.yaml
- kubectl port-forward kuard-config 8080
- curl -o kuard.crt https://storage.googleapis.com/kuar-demo/kuard.crt
- curl -o kuard.key https://storage.googleapis.com/kuar-demo/kuard.key
- kubectl create secret generic kuard-tls --from-file=kuard.crt --from-file=kuard.key
- kubectl describe secrets kuard-tls
- kubectl apply -f kuard-secret.yaml
- kubectl port-forward kuard-tls 8443:8443
- kubectl replace -f file.yaml
- kubectl delete pods --all


cat << 'EOF' > pod-logs.yaml
apiVersion: v1
kind: Pod
metadata:
labels:
test: logs
name: pod-logs
spec:
containers:
- name: server
  image: busybox:1.30.1
  ports:
  - containerPort: 8888
  # Listen on port 8888
  command: ["/bin/sh", "-c"]
  # -v for verbose mode
  args: ["nc -p 8888 -v -lke echo Received request"]
  readinessProbe:
  tcpSocket:
  port: 8888
  - name: client
    image: busybox:1.30.1
    # Send requests to server every 5 seconds
    command: ["/bin/sh", "-c"]
    args: ["while true; do sleep 5; nc localhost 8888; done"]
EOF
kubectl create -f pod-logs.yaml




