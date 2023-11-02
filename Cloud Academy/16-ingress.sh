cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blue-app
spec:
  selector:
    matchLabels:
      app: blue-app
  replicas: 2
  template:
    metadata:
      labels:
        app: blue-app
    spec:
      containers:
      - name: blue-app
        image: public.ecr.aws/cloudacademy-labs/cloudacademy/labs/k8s-ingress-app:f9a36c8
        env:
        - name: COLOR
          value: '#A7C7E7'
        ports:
        - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: blue-app
spec:
  selector:
    app: blue-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
EOF

cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: red-app
spec:
  selector:
    matchLabels:
      app: red-app
  replicas: 2
  template:
    metadata:
      labels:
        app: red-app
    spec:
      containers:
      - name: red-app
        image: public.ecr.aws/cloudacademy-labs/cloudacademy/labs/k8s-ingress-app:f9a36c8
        env:
        - name: COLOR
          value: '#FAA0A0'
        ports:
        - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: red-app
spec:
  selector:
    app: red-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
EOF

cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lab-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /blue
        pathType: Prefix
        backend:
          service:
            name: blue-app
            port:
              number: 80
      - path: /red
        pathType: Prefix
        backend:
          service:
            name: red-app
            port:
              number: 80
EOF

cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lab-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: blue.example.com
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: blue-app
            port:
              number: 80
  - host: red.example.com
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: red-app
            port:
              number: 80
EOF

load_balancer_dns=$(kubectl -n ingress-nginx get service ingress-nginx-controller -o jsonpath={.status.loadBalancer.ingress[0].hostname})
curl --header "Host: blue.example.com" http://$load_balancer_dns
curl --header "Host: red.example.com" http://$load_balancer_dns