#!/usr/bin/env bash
set -euo pipefail

PRI_REGION=${1:-us-east-1}
SEC_REGION=${2:-us-west-2}

ACCELERATOR_ARN=$(aws globalaccelerator list-accelerators --query 'Accelerators[0].AcceleratorArn' --output text)
LISTENER_ARN=$(aws globalaccelerator list-listeners --accelerator-arn "$ACCELERATOR_ARN" --query 'Listeners[0].ListenerArn' --output text)

PRI_EPG=$(aws globalaccelerator list-endpoint-groups --listener-arn "$LISTENER_ARN"   --query "EndpointGroups[?EndpointGroupRegion=='$PRI_REGION'].EndpointGroupArn | [0]" --output text)

aws globalaccelerator update-endpoint-group   --endpoint-group-arn "$PRI_EPG"   --traffic-dial-percentage 0

echo "[OK] Tráfico de región primaria reducido a 0% (failover)."
