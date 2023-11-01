cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
    version: old
  name: app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: web
      version: old
  strategy:
    type: RollingUpdate # Default value is RollingUpdate, Recreate also supported
  template:
    metadata:
      labels:
        app: web
        version: old
    spec:
      containers:
      - image: nginx:1.21.3-alpine
        name: nginx
        ports:
        - containerPort: 80
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /
            port: 80
            scheme: HTTP
          periodSeconds: 5
          successThreshold: 2
          timeoutSeconds: 10
EOF

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: web
  name: app
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: web
  type: LoadBalancer
EOF

kubectl get service -w

cat << EOF | kubectl patch service app --patch-file /dev/stdin
spec:
  selector:
    app: web
    version: old
EOF

cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
    version: new
  name: app-new
spec:
  replicas: 10
  selector:
    matchLabels:
      app: web
      version: new
  template:
    metadata:
      labels:
        app: web
        version: new
    spec:
      containers:
      - image: httpd:2.4.49-alpine3.14
        name: httpd
        ports:
        - containerPort: 80
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /
            port: 80
            scheme: HTTP
          periodSeconds: 5
          successThreshold: 2
          timeoutSeconds: 10
EOF

kubectl get deployments -w

cat << EOF | kubectl patch service app --patch-file /dev/stdin
spec:
  selector:
    app: web
    version: new
EOF


kubectl delete deployments app

kubectl patch service app --type=json --patch='[{"op": "remove", "path": "/spec/selector/version"}]'

cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
    version: canary
  name: app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
      version: canary
  template:
    metadata:
      labels:
        app: web
        version: canary
    spec:
      containers:
      - image: caddy:2.4.5-alpine
        name: caddy
        ports:
        - containerPort: 80
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /
            port: 80
            scheme: HTTP
          periodSeconds: 5
          successThreshold: 2
          timeoutSeconds: 10
EOF

service_address=$(kubectl get service app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
while true; do
    curl --silent $service_address | grep "works"
    sleep 1
done

kubectl delete deployment app-canary
kubectl set image deployment app-new *=caddy:2.4.5-alpine