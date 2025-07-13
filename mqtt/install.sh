#!/bin/bash

namespace='mqtt'
helm repo add eclipse-mosquitto https://k8s-at-home.com/charts/
helm repo update
helm install mosquitto eclipse-mosquitto/mosquitto -f values.yaml -n $namespace

