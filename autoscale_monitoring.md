# Custom metrics autoscaler & monitoring

Based on <https://github.com/influxdata/k8s-kapacitor-autoscale/blob/master/README.md>


## 1. Install Minikube

<https://github.com/kubernetes/minikube#installation>

## 2. Start Minikube

`minikube start`

## 3. The Example Application

3.0 Download repo

```
$ git clone https://github.com/influxdata/k8s-kapacitor-autoscale.git
$ cd k8s-kapacitor-autoscale
```


<https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/>

3.1 Create the application replica set

`$ kubectl create -f replicasets/app.yaml`



3.2 Expose the application as a service

`$ kubectl create -f services/app.yaml`


3.3 Create replica set and service for kapacitor

```
$ kubectl create -f replicasets/kapacitor.yaml
$ kubectl create -f services/kapacitor.yaml
```

3.4 Set environment variables

```
APP_URL=$(minikube service app --url)
export KAPACITOR_URL=$(minikube service kapacitor --url)
```

3.5 Run kapacitor client in docker

```
$ docker run -it --rm -v $(pwd):/k8s-kapacitor-autoscale:ro -e KAPACITOR_URL="$KAPACITOR_URL" kapacitor:1.1.0-rc2 bash
$ cd /k8s-kapacitor-autoscale
$ kapacitor define autoscale -tick autoscale.tick -type stream -dbrp autoscale.autogen
$ kapacitor enable autoscale
```

## 4. Monitoring

Check addons in minikube

```
$ minikube addons list
- default-storageclass: enabled
- kube-dns: enabled
- heapster: enabled
- ingress: enabled
- registry: disabled
- registry-creds: disabled
- addon-manager: enabled
- dashboard: enabled
```

If heapster is disabled, enable heapster

```
minikube addons enable heapster
```

Check heapster/influxdb/grafana in services/pods

```
$ kubectl get services --all-namespaces
NAMESPACE     NAME                   CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
default       app                    10.0.0.183   <nodes>       8000:30073/TCP      2h
default       kapacitor              10.0.0.153   <nodes>       9092:31101/TCP      2h
default       kubernetes             10.0.0.1     <none>        443/TCP             23h
kube-system   default-http-backend   10.0.0.83    <nodes>       80:30001/TCP        23h
kube-system   heapster               10.0.0.216   <nodes>       80:31275/TCP        3h
kube-system   kube-dns               10.0.0.10    <none>        53/UDP,53/TCP       23h
kube-system   kubernetes-dashboard   10.0.0.3     <nodes>       80:30000/TCP        23h
kube-system   monitoring-grafana     10.0.0.228   <nodes>       80:31467/TCP        3h
kube-system   monitoring-influxdb    10.0.0.122   <none>        8083/TCP,8086/TCP   3h
```


```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                             READY     STATUS    RESTARTS   AGE
default       app-gxkb8                        1/1       Running   0          2h
default       kapacitor-qcmnd                  1/1       Running   0          2h
kube-system   default-http-backend-s7991       1/1       Running   2          23h
kube-system   heapster-9k6qm                   1/1       Running   1          3h
kube-system   influxdb-grafana-m8svr           2/2       Running   0          1h
kube-system   kube-addon-manager-minikube      1/1       Running   2          23h
kube-system   kube-dns-1301475494-7g298        3/3       Running   6          23h
kube-system   kubernetes-dashboard-rwn6n       1/1       Running   2          23h
kube-system   nginx-ingress-controller-r44zg   1/1       Running   2          23h
```

Get grafana monitoring url with minikube

```
$ minikube -n kube-system service monitoring-grafana --url
http://192.168.99.100:31467
```

Get grafana monitoring url with kubectl

```
$ kubectl -n kube-system describe service monitoring-grafana 
Name:			monitoring-grafana
Namespace:		kube-system
Labels:			addonmanager.kubernetes.io/mode=Reconcile
			kubernetes.io/minikube-addons=heapster
			kubernetes.io/minikube-addons-endpoint=heapster
			kubernetes.io/name=monitoring-grafana
Annotations:		kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"addonmanager.kubernetes.io/mode":"Reconcile","kubernetes.io/minikube-addons...
Selector:		addonmanager.kubernetes.io/mode=Reconcile,name=influxGrafana
Type:			NodePort
IP:			10.0.0.228
Port:			<unset>	80/TCP
NodePort:		<unset>	31467/TCP
Endpoints:		172.17.0.10:3000
Session Affinity:	None
```

Open grafana in browser

```
$ minikube addons open heapster
Opening kubernetes service kube-system/monitoring-grafana in default browser...
```

[[images/grafana.png]]


## 5. Generate some load and watch the application autoscale

Install **hey**	(HTTP load generation tool)
```
$ go get -u github.com/rakyll/hey
$ ./ramp.sh $APP_URL
```

Watch autoscaling in progress
```
$ kubectl get pods -w
NAME              READY     STATUS    RESTARTS   AGE
app-gxkb8         1/1       Running   0          2h
kapacitor-qcmnd   1/1       Running   0          2h
```
...

```
$ kubectl get pods -w
NAME              READY     STATUS    RESTARTS   AGE
app-cfb8z         1/1       Running   0          1m
app-gxkb8         1/1       Running   0          2h
app-stlq3         1/1       Running   0          11s
kapacitor-qcmnd   1/1       Running   0          2h
```
