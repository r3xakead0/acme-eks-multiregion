#!/usr/bin/env bash
set -euo pipefail

GA_DNS=$(aws globalaccelerator list-accelerators --query 'Accelerators[0].DnsName' --output text)
URL=${1:-"http://$GA_DNS"}
echo "Probing $URL"
for i in $(seq 1 5); do
  echo -n "$i: "
  curl -s -m 5 "$URL" | sed -n 's/.*Región: \(.*\)<.*/\1/p'
  sleep 1
done
