#1
# Create a deployment named webapp in the zap namespace. Use the nginx:1.17.8 image and set the number of replicas initially to 2
kubectl -n zap create deployment --image=nginx:1.17.8 --replicas=2 webapp
# Next, scale the current deployment up from 2 to 4.
kubectl -n zap scale deployment --replicas=4 webapp
# Finally, update the deployment to use the newer nginx:1.19.0 image.
kubectl -n zap set image deployment webapp nginx=nginx:1.19.0


#2
# Add an additional label app=cloudacademy to all pods currently running in the gzz namespace that have the label env=prod
kubectl -n gzz label pods --selector env=prod app=cloudacademy

#3
# The nginx container running within the cloudforce deployment in the fre namespace needs to be updated to use the nginx:1.19.0-perl image. Perform this deployment update and ensure that the command used to perform it is recorded in the tracked rollout history.
kubectl -n fre set image deployment cloudforce nginx=nginx:1.19.0-perl
# To manage the deployment history, use the annotate command to create a message.
kubectl -n fre annotate deployment cloudforce kubernetes.io/change-cause="set image to nginx:1.19.0-perl" --overwrite=true

#4
# A deployment named eclipse has been created in the xx1 namespace. This deployment currently consists of 2 replicas. Configure this deployment to autoscale based on CPU utilisation. The autoscaling should be set for a minimum of 2, maximum of 4, and CPU usage of 65%.
kubectl -n xx1 autoscale deployment --min=2 --max=4 --cpu-percent=65 eclipse

#5
# Create a cronjob named matrix in the saas namespace. Use the radial/busyboxplus:curl image and set the schedule to */10 * * * *. The job should run the following command: curl www.google.com
kubectl -n saas create cronjob --image=radial/busyboxplus:curl --schedule='*/10 * * * *' matrix -- curl www.google.com

#6
# Get a list of all pod names running in the rep namespace which have their colour label set to either orange, red, or yellow. The returned pod name list should contain only the pod names and nothing else. The pods names should be ordered by the cluster IP address assigned to each pod. The resulting pod name list should be saved out to the file /home/ubuntu/pod001
kubectl -n rep get pods --selector 'colour in (orange,red,yellow)' --sort-by=.status.podIP -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' > /home/ubuntu/pod001
## or
k get po -n rep --sort-by=.status.podIP -l 'colour in(orange,red,yellow)' -o custom-columns=NAME:.metadata.name | tail -n +2  > /home/ubuntu/pod001