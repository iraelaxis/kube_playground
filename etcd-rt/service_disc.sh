#!/bin/bash


#echo "hostIP"
#kubectl get pods -o wide -o json | jq -r .items[].status.hostIP
#echo "podIP"
#kubectl get pods -o wide -o json | jq -r .items[].status.podIP
#echo "Status"
#kubectl get pods -o wide -o json | jq -r .items[].status.phase
#echo "Name"
#kubectl get pods -o wide -o json | jq -r .items[].status.containerStatuses[].name

while true; do
	APACHE_SERVICE=$(kubectl get pods --selector=run=php-apache -o jsonpath="{.items[*].status.podIP}")
	etcdctl set /services/php-apache "$APACHE_SERVICE"
	sleep 5;
done;