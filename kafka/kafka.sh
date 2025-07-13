#!/bin/bash

namespace='kafka'
helm install kafka bitnami/kafka   -n $namespace   -f ./values.yaml