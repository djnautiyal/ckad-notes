#1
# Create a Pod in the red Namespace with the following configuration: The Pod is named basic, the Pod uses the nginx:stable-alpine-perl image for its only container, restart the Pod only OnFailure, and ensure port 80 is open to TCP traffic
kubectl run -n red --image=nginx:stable-alpine-perl --restart=OnFailure --port=80 basic

#2

# Expose a Pod in the red Namespace with the following configuration: The Service name is cloudacademy, the Service port is 8080, the Target port is 80, the Service type is ClusterIP
kubectl expose pod basic -n red --name=cloudacademy-svc --port=8080 --target-port=80

#3
# Expose a deployment as a NodePort based service using the following settings: The Service name is cloudforce-svc, the Service type is NodePort, the Service port is 80, and the NodePort is 32080
kubectl expose deployment -n ca1 cloudforce --name=cloudforce-svc --port=80 --type=NodePort
kubectl patch -n ca1 svc cloudforce-svc --patch '{"spec": {"ports": [{"port": 80, "nodePort": 32080}]}}'

#4
# Examine both the Deployment and Service, confirming that the Service selector uses the correct pod labels as specified in the Deployment
kubectl describe deployments.apps -n skynet t2
kubectl describe svc -n skynet t2-svc
# Check the t2-svc Service Endpoints are correctly registered - note that no endpoints are currently registered
kubectl get ep -n skynet t2-svc
# Update the t2-svc Service selector to use the correct Deployment pod label (app=t2)
kubectl edit svc -n skynet t2-svc
# Check the t2-svc Service Endpoints are now correctly registered
kubectl get ep -n skynet t2-svc
# Curl the updated t2-svc Service and save the HTTP response
kubectl run client -n skynet --image=appropriate/curl -it --rm --restart=Never -- curl http://t2-svc:8080 > /home/ubuntu/svc-output.txt


#5
# Confirm that pod2 traffic sent to pod1 is as stated currently blocked
pod1IP=$(kubectl get pods pod1 -n sec1 -o jsonpath='{.status.podIP}')
kubectl -n sec1 exec -it pod2 -- ping $pod1IP
# Examine the pod labels for pod1 (receiver) and pod2 (sender)
kubectl get pods -n sec1 --show-labels
# Examine the existing NetworkPolicy
kubectl -n sec1 describe netpol netpol1
# Edit and update the NetworkPolicy with correct ingress pod selector label
kubectl edit -n sec1 netpol netpol1
# Confirm that pod2 can now send traffic to pod1
pod1IP=$(kubectl get pods pod1 -n sec1 -o jsonpath='{.status.podIP}')
kubectl -n sec1 exec -it pod2 -- ping $pod1IP