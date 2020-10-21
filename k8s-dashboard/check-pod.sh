#!/bin/bash
running=$(kubectl get pods -n kubernetes-dashboard | grep kubernetes-dashboard | awk '{print $3}')
while [[ "${running}" != "Running" ]]; do
    echo "Dashboard pod not ready, sleep for 5s.."
    sleep 5s
    running=$(kubectl get pods -n kubernetes-dashboard | grep kubernetes-dashboard | awk '{print $3}')
done