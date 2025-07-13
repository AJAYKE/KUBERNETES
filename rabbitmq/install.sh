#!/bin/bash

namespace='rabbitmq'
helm install rabbitmq bitnami/rabbitmq -f values.yaml --version 15.5.3 -n $namespace

