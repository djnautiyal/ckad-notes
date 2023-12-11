k get crd

k get app --all-namespaces
k describe app guestbook | less

nohup kubectl port-forward service/my-argo-cd-argocd-server -n default --address 0.0.0.0 8001:443 &>/dev/null &


# Get the bastion's public IP
bastion_ip=$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4)
# Output the Argo web address
echo "http://$bastion_ip:8001"


kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo