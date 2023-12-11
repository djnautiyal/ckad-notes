## Check 1: Created Specified Deployment
    Create a deployment named chk1 in the cal namespace. Use the image nginx:1.15.12-alpine and set the number of replicas to 3. Finally, ensure the revision history limit is set to 50.

## Check 2: Resolve Configuration Issues
    The site deployment in the pwn namespace is supposed to be exposed to clients outside of the Kubernetes cluster by the sitelb service. However, requests sent to the service do not reach the deployment's pods. Resolve the service configuration issue so the requests sent to the service do reach the deployment's pods.

## Check 3: Highest CPU Pod
    Write the name of the pod in zz8 namespace consuming the most CPU to /home/ubuntu/hcp001. The content of the file should be only the name of the Pod and nothing more.

## Check 4: Pod Secret
    In the sjq namespace, create a secret named xh8jqk7z that stores a generic secret with the key of tkn and the value of hy8szK2iu. Create a pod named server using the httpd:2.4.39-alpine image and give the pod's container access to the tkn key in the xh8jqk7z secret through an environment variable named SECRET_TKN.

## Check 5: Service Account
Create a service account named inspector in the dwx7eq namespace. Then create a deployment named calins in the same namespace. Use the image busybox:1.31.1 for the only pod container and pass the arguments sleep and 24h to the container. Set the number of replicas to 1. Lastly, make sure that the deployments' pod is using the inspector service account.

## Check 6: Evictions
The mission-critical deployment in the bk0c2d namespace has been getting evicted when the Kubernetes cluster is consuming a lot of memory. Modify the deployment so that it will not be evicted when the cluster is under memory pressure unless there are higher priority pods running in the cluster (Guaranteed Quality of Service). It is known that the container for the deployment's pod requires and will not use more than 200 milliCPU (200m) and 200 mebibytes (200Mi) of memory.

## Check 7: Persisting Data
A legacy application runs via a deployment in the zuc0co namespace. The deployment's pod uses a multi-container pod to convert the legacy application's raw metric output into a format that can be consumed by a metric aggregation system. However, the data is currently lost every time the pod is deleted. Modify the deployment to use a persistent volume claim with 2GiB of storage and access mode of ReadWriteOnce so the data is persisted if the pod is deleted.

## Check 8: Multi-Container Pattern
Write the name of the multi-container pod design pattern used by the pod in the previous task to a file at /home/ubuntu/mcpod.