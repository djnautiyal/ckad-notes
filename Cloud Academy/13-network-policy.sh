cat > app-policy.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-tiers
  namespace: test
spec:
  podSelector:
    matchLabels:
      app-tier: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app-tier: cache
    ports:
    - port: 80
EOF