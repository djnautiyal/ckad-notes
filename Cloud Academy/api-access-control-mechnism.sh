kubectl get pods --v=6


less /home/ubuntu/.kube/config

# Client key and certificate is the default way to authenticate requests in Kubernetes clusters although other authentication modules are supported, including passwords and tokens.
# A request will pass authenticate if any of the authentication modules successfully authenticates the request.

kubectl config --help

grep "client-cert" ~/.kube/config | \
  sed 's/\(.*client-certificate-data: \)\(.*\)/\2/' | \
  base64 --decode \
  > cert.pem
openssl x509 -in cert.pem -text -noout

kubectl run nginx --image=nginx
kubectl describe pod nginx | grep -A 5 Volumes
#The projected volume consists of:
#   A token acquired from kube-apiserver that will expire after 1 hour by default or when the pod is deleted. The token is bound to the pod and allows communication with the kube-apiserver.
#    A ConfigMap containing a CA bundle used for verifying connections to the kube-apiserver.

cat /var/run/secrets/kubernetes.io/serviceaccount/token && echo
#User requests must pass the same authentication and other access control layers regardless of if they are sent from kubectl,
# using client libraries or REST API requests (in fact kubectl and client libraries are also sending REST API requests but abstracting the details away from you).

#The second layer in Kubernetes API access control is authorization. At this stage the request is authenticated and the requesting user is known. Authorization needs to determine if the authenticated user is allowed to perform the action requested.
# The default authorization mechanism in Kubernetes is role-based access control (RBAC). In RBAC, subjects (users, groups, ServiceAccounts) are bound to roles and the roles describe what actions the subject is allowed to perform.
# There are two kinds of roles in Kubernetes RBAC:
#
#    Role: A namespaced resource specifying allowed actions
#    ClusterRole: A non-namespaced resource specifying allowed actions
#
#Roles include a Namespace where the actions are allowed in contrast to ClusterRoles which don't include a Namespace and can be bound to any and all Namespaces. ClusterRoles can also allow actions on non-namespaced resources, such a Nodes.
#
#There are two resources available for binding roles to subjects:
#
#    RoleBinding: Bind a Role or ClusterRole to a subject(s) in a Namespace
#    ClusterRoleBinding: Bind a ClusterRole to a subject(s) cluster-wide

kubectl get roles --all-namespaces
kubectl get -n kube-system role kube-proxy -o yaml
kubectl get clusterroles
kubectl get clusterrole cluster-admin -o yaml
kubectl get clusterrolebinding cluster-admin -o yaml


kubectl auth can-i list nodes
kubectl auth can-i --help
kubectl auth can-i list nodes --as=Tracy

#Admission control is the final layer of access control in the Kubernetes API. A Kubernetes cluster can have many admission control modules and the modules used by a cluster can be configured.
# None of the modules in use must reject the request for a request to be allowed.
# For example, the ResourceQuota admission controller enforces resource quotas configured in a Namespace. Admission controllers can also modify requests before they are accepted.
# For example, the LimitRanger admission controller allows you to specify default cpu and memory limits for Pods that don't specify any.
kubectl exec -n kube-system kube-apiserver-ip-10-0-0-100.us-west-2.compute.internal -- kube-apiserver -h | grep "enable-admission-plugins strings"

ps -ef | grep kube-apiserver | grep enable-admission-plugins

