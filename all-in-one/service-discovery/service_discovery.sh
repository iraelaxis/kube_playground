#!/bin/sh

ETCD_ENDPOINT="http://example-etcd-cluster-client:2379"

while true; do
	ETCD_SERVICE=$(kubectl get pods --selector=app=etcd -o jsonpath="{.items[*].status.podIP}")
	etcdctl --endpoint "$ETCD_ENDPOINT" set /services/etcd-cluster "$ETCD_SERVICE"
	
	sleep 10;
done;