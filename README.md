# REDEEM SERVICE

This is a repository that simulates a 3rd Party Rewards System. 

# Build image
docker build . -t webnodeapp

# Run as container 
docker-compose up 

# Kubernetes deployment

kubectl apply -f deployment/

Note: we can create secrets for mysql password instead of hardcoding in yaml

Healthcheck API is included

