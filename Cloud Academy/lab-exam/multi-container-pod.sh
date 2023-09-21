#1
# A Pod in the mcp namespace has a single container named random hat writes its logs to the /var/log/random.log file. Add a second container named second that uses the busybox image to allow the following command to display the logs written to the random container's /var/log/random.log file: kubectl -n mcp logs random second
# Start by saving the original Pod manifest so you don't lose any information
kubectl -n mcp get pod random -o yaml > original.yaml
# Create a copy for you to modify
cp original.yaml second.yaml
# Edit the file to be equivalent to the following
cat << EOF > second.yaml
apiVersion: v1
kind: Pod
metadata:
  name: random
  namespace: mcp
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - while true; do shuf -i 0-1 -n 1 >> /var/log/random.log; sleep 1; done
    image: busybox
    name: random
    volumeMounts:
    - mountPath: /var/log
      name: logs
  - name: second
    image: busybox
    args: [/bin/sh, -c, 'tail -n+1 -f /var/log/random.log']
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    emptyDir: {}
EOF
# Delete the original Pod
kubectl delete -f second.yaml
# Create the modified version
kubectl create -f second.yaml


#2
# Containers within the same Pod share the same Pod IP address, and can communicate via loopback network interface - therefore any of the following values can be used for the <REPLACE_HOST_HERE> placeholder
* localhost
* 127.0.0.1
* webpod
* <pod.assigned.ip.address>
* <pod-assigned-ip-address>.<namespace>.pod.cluster.local
# Update and deploy the provided manifest using localhost for <REPLACE_HOST_HERE>
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
 name: webpod
 namespace: app1
spec:
 restartPolicy: Never
 volumes:
 - name: vol1
   emptyDir: {}
 containers:
 - name: c1
   image: nginx
   volumeMounts:
   - name: vol1
     mountPath: /usr/share/nginx/html
   lifecycle:
     postStart:
       exec:
         command:
           - "bash"
           - "-c"
           - |
             date | sha256sum | tr -d " *-" > /usr/share/nginx/html/index.html
 - name: c2
   image: appropriate/curl
   command: ["/bin/sh", "-c", "curl -s http://localhost && sleep 3600"]
EOF
# Confirm that the pod is up and running
kubectl get pod -n app1 webpod
# Confirm that container c2 is correctly working (able to communicate with container c1)
kubectl logs -n app1 webpod -c c2
# Write out the log result for c2 to the /home/ubuntu/webpod-log.txt file
kubectl logs -n app1 webpod -c c2 > /home/ubuntu/webpod-log.txt

#3
# Update and save the provided Pod manifest /home/ubuntu/md5er-app.yaml with the extra c2 container as per given specs
apiVersion: v1
kind: Pod
metadata:
 name: md5er
 namespace: app2
spec:
 restartPolicy: Never
 volumes:
 - name: vol1
   emptyDir: {}
 containers:
 - name: c1
   image: bash
   env:
   - name: DATA
     valueFrom:
       configMapKeyRef:
         name: cm1
         key: data
   volumeMounts:
   - name: vol1
     mountPath: /data
   command: ["/usr/local/bin/bash", "-c", "echo $DATA > /data/file.txt"]
 - name: c2
   image: bash
   volumeMounts:
   - name: vol1
     mountPath: /data
     readOnly: true
   command:
     - "/usr/local/bin/bash"
     - "-c"
     - |
       for word in $(</data/file.txt)
       do
       echo $word | md5sum | awk '{print $1}'
       done
# Apply the update Pod manifest into the K8s cluster
kubectl apply -f/home/ubuntu/md5er-app.yaml
# Check that the new c2 container is correctly generating MD5s
kubectl logs -n app2 md5er c2
# Save the stdout output from the c2 container as per given instructions
kubectl logs -n app2 md5er c2 > /home/ubuntu/md5er-output.log


