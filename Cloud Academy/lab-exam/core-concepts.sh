# My answers
#1
k run basic --image=nginx:stable-alpine-perl --restart=OnFailure --port=80 -n cre

#2
k run worker  -n workers --image=busybox --restart=Never --labels='company=acme,speed=fast,type=async' -- /bin/sh -c "echo working... && sleep 3600"

#3
kubectl label --overwrite pods compiler language=python -n ca200
kubectl get pod compiler -n ca200 -o yaml | grep -A 3 labels

#4
k get pod ip-podzoid -o jsonpath='{$..status.podIP}' -n ca300

#5 - wrote in vim - didn't work

#6 - isn't working
k run web-zeroshutdown --image=nginx --restart=Never --grace-period=0 -n sys2



# Cloud academy answers
## Check 1
 # Create a Pod in the cre Namespace with the following configuration: the Pod is named basic, the Pod uses the nginx:stable-alpine-perl image for its only container, restart the Pod only OnFailure, ensure port 80 is open to TCP traffic
 kubectl run -n cre --image=nginx:stable-alpine-perl --restart=OnFailure --port=80 basic


## Check 2
# Create a new Namespace named workers and then create a Pod within it using the following configuration: the Pod is named worker, the Pod uses the busybox image for its only container, the Pod has the labels company=acme, speed=fast, type=async, the Pod runs the command /bin/sh -c "echo working... && sleep 3600"
kubectl create ns workers
kubectl run -n workers worker --image=busybox --labels="company=acme,speed=fast,type=async" -- /bin/sh -c "echo working... && sleep 3600"


## Check 3
# Edit and save pod - this will update the pod without restarting it
kubectl edit pod -n ca200 compiler


## Check 4
# Step 1 - examine the json structure for the pod in question, in particular look to see where the pod assigned ip address is located - it is in the .status.podIP field
kubectl get pods -n ca300 ip-podzoid -o json
# Step 2 - using the information from the previous step, build out the actual jsonpath based expression to return only the pod ip address
kubectl get pods -n ca300 ip-podzoid -o jsonpath='{.status.podIP}'
# Step 3 - write out the working kubectl command to the file /home/ubuntu/podip.sh
echo "kubectl get pods -n ca300 ip-podzoid -o jsonpath={.status.podIP}" > /home/ubuntu/podip.sh


## Check 5
# Use kubectl run command specifically with the --dry-run=client and -o yaml parameters - and then redirect the output to file
kubectl run -n core-system borg1 --image=busybox --restart=Always --labels="platform=prod" --env system=borg -o yaml --dry-run=client -- /bin/sh -c "echo borg.running... && sleep 3600" > /home/ubuntu/pod.yaml


## Check 6
# Step 1 - Use kubectl run command specifically with the --dry-run=client and -o yaml parameters - and then redirect the output to file
kubectl run web-zeroshutdown -n sys2 --image=nginx --restart=Never --port=80 -o yaml --dry-run=client > pod-zeroshutdown.yaml
# Step 2 - use kubectl explain pod.spec to check the syntax and how the terminationGracePeriodSeconds attribute should be configured
kubectl explain pod.spec
# Step 3 - use vim and edit and update the pod-zeroshutdown.yaml file, adding in -> terminationGracePeriodSeconds: 0
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: web-zeroshutdown
  name: web-zeroshutdown
  namespace: sys2
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - image: nginx
    name: web-zeroshutdown
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
# Step 4 - use kubectl apply -f pod-zeroshutdown.yaml to create the pod resource within the cluster
kubectl apply -f pod-zeroshutdown.yaml --force

