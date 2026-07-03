#!/bin/bash

# Compatibility script retained for earlier workflows.
# Prefer ./infrastructure/scripts/02_connect-eks.sh for command checks and structured output.

echo "Updating kubeconfig..."

aws eks update-kubeconfig \
--region ap-south-1 \
--name capstone-eks


echo "Checking nodes..."

kubectl get nodes
