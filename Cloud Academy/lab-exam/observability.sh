#1
# Solution commands
kubectl run nginx -n ca1 --image=nginx --restart=Never --port=80 --dry-run=client -o yaml > pod-livenessprobe.yaml
# Edit and save the file using vim
vim pod-livenessprobe.yaml
apiVersion: v1
kind: Pod
metadata:
 creationTimestamp: null
 labels:
   run: nginx
 name: nginx
 namespace: ca1
spec:
 containers:
 - image: nginx
   name: nginx
   ports:
   - containerPort: 80
   resources: {}
   livenessProbe:
     httpGet:
       path: /
       port: 80
     initialDelaySeconds: 10
     periodSeconds: 5
 dnsPolicy: ClusterFirst
 restartPolicy: Never
status: {}
# Apply the manifest to create the Pod within the cluster
kubectl apply -f pod-livenessprobe.yaml

#2
# Solution commands
cat << EOF > patch.yaml
spec:
  template:
    spec:
      containers:
      - name: web2
        readinessProbe:
          httpGet:
            port: 80
EOF
kubectl -n hosting patch deployments web2 --patch "$(cat patch.yaml)"

#3
# Solution commands
kubectl logs -n ca2 -l app=prod | wc -l > /home/ubuntu/combined-row-count-prod.txt

#4
# Solution commands
kubectl exec -n ca2 skynet -- cat /skynet/t2-specs.txt > /home/ubuntu/t2-specs.txt

#5
# Solution commands
kubectl top pods -n matrix --sort-by=cpu --no-headers=true | head -n1 | cut -d" " -f1 > /home/ubuntu/max-cpu-podname.txt