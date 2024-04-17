#!/usr/bin/env bash
hsts=$(echo "$1" | tr "," "\n")
for addr in $hsts; do
  echo "$addr cat-app.k3d.local"
  echo "$addr argocd.k3d.local"
done
