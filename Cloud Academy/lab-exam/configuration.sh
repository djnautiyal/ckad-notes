## My Answers
#1
k create secret generic  app-secret --from-literal=password=abnaoieb2073xsj -n yqe
k run app -n yqe --image=memcached --dry-run=client -o yaml > app.yaml
#edit using vim
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: app
  namespace: yqe
  name: app
spec:
  containers:
  - image: memcached
    name: app
    volumeMounts:
    - mountPath: /etc/app
      name: sex
  volumes:
  - name: sex
    secret:
      secretName: app-secret
k apply -f app.yaml


#2
k create sa secure-svc -n app
k get deploy -n app
k edit deploy/secapp
https://stackoverflow.com/questions/44505461/how-to-configure-a-non-default-serviceaccount-on-a-deployment

#3
## See below

#4
k run app --image=nginx --labels="env=prod,type=processor" --port=80 --dry-run=client -o yaml > app.yaml
## edited app.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    env: prod
    type: processor
  name: app
spec:
  containers:
  - image: nginx
    name: app
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "100Mi"
      limits:
        memory: "200Mi"

#5
k run redfastcar --image=busybox --dry-run=client -o yaml  -- /bin/sh -c "env | grep -E 'COLOUR|SPEED'; sleep 3600"  > redfastcar.yaml
## edited redfastcar.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: redfastcar
  name: redfastcar
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - env | grep -E 'COLOUR|SPEED'; sleep 3600
    image: busybox
    name: redfastcar
    env:
    - name: COLOUR
      valueFrom:
        configMapKeyRef:
          name: config1
          key: COLOUR
    - name: SPEED
      valueFrom:
        configMapKeyRef:
          name: config1
          key: SPEED
    volumeMounts:
    - name: sex
      mountPath: /config
  volumes:
  - name: sex
    configMap:
      name: config1




#CloudAcademy answers
#1
# Create a secret named app-secret in the yqe Namespace that stores key-value pair of password=abnaoieb2073xsj
kubectl -n yqe create secret generic --from-literal=password=abnaoieb2073xsj app-secret
# Create a Pod that consumes the app-secret Secret using a Volume that mounts the Secret in the /etc/app directory. The Pod should be named app and run a memcached container.
cat << EOF | kubectl apply -n yqe -f -
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: memcached
    volumeMounts:
    - name: secret
      mountPath: "/etc/app"
  volumes:
  - name: secret
    secret:
      secretName: app-secret
EOF


#2
# Create a new ServiceAccount named secure-svc in the same namespace where the deployment currently exists
kubectl create serviceaccount -n app secure-svc
# Create a file named patch.yaml and configure the replicas serviceAccountName to be secure-svc
spec:
  template:
    spec:
      serviceAccountName: secure-svc
# Patch the existing Deployment
kubectl patch deployment -n app secapp --patch "$(cat patch.yaml)"

#3
# Start by generating a Pod manifest template specifying as many parameters possible when using kubectl run - redirect and save the output into a file named pod.yaml
(kubectl run --image=bash -n dnn secpod -l env=prod --dry-run=client -o yaml -- /usr/local/bin/bash -c 'sleep 3600') > pod.yaml
# pod.yaml contains
apiVersion: v1
kind: Pod
metadata:
 creationTimestamp: null
 labels:
  env: prod
 name: secpod
 namespace: dnn
spec:
 containers:
  - args:
  - /usr/local/bin/bash
  - -c
  - sleep 3600
  image: bash
  name: secpod
  resources: {}
 dnsPolicy: ClusterFirst
 restartPolicy: Always
status: {}
# Using vim open up and modify the pod.yaml template, first duplicate the container section to create containers c1 and c2, and then add in the required security context configuration, finally save the updated pod.yaml manifest:
apiVersion: v1
kind: Pod
metadata:
 creationTimestamp: null
 labels:
  env: prod
 name: secpod
 namespace: dnn
spec:
 securityContext:
  fsGroup: 3000
 containers:
 - name: c1
   securityContext:
    runAsUser: 1000
   args:
   - /usr/local/bin/bash
   - -c
   - sleep 3600
   image: bash
   resources: {}
 - name: c2
   securityContext:
    runAsUser: 2000
   args:
   - /usr/local/bin/bash
   - -c
   - sleep 3600
   image: bash
   resources: {}
 dnsPolicy: ClusterFirst
 restartPolicy: Always
status: {}
# Using kubectl apply - create the pod resource within the cluster
kubectl apply -f pod.yaml
# Confirm that the pod has been successfully created
kubectl get pods -n dnn
# Confirm the the pod contains 2 containers c1 and c2 and that they have been configured with the required security context
kubectl exec -it -n dnn secpod -c c1 -- id
uid=1000 gid=0(root) groups=0(root),3000
kubectl exec -it -n dnn secpod -c c2 -- id
uid=2000 gid=0(root) groups=0(root),3000