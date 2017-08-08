```
$ kubectl run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=100m --expose --port=80
$ kubectl autoscale deployment php-apache --cpu-percent=10 --min=1 --max=10
```


```
$ kubectl get service
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   10.0.0.1     <none>        443/TCP   1d
php-apache   10.0.0.202   <none>        80/TCP    1h
```

Increase load
```
$ kubectl run -i --tty load-generator --image=busybox /bin/sh
$ while true; do wget -q -O- http://10.0.0.202; done
```

Run `service_disc.sh`

(Local etcd)
```
$ etcdctl get /services/php-apache
172.17.0.6
$ etcdctl get /services/php-apache
172.17.0.12 172.17.0.11 172.17.0.6 172.17.0.13
$ etcdctl get /services/php-apache
172.17.0.12 172.17.0.11 172.17.0.6 172.17.0.13
$ etcdctl get /services/php-apache
172.17.0.12 172.17.0.11 172.17.0.6 172.17.0.13
$ etcdctl get /services/php-apache
172.17.0.12 172.17.0.11 172.17.0.6 172.17.0.13
$ etcdctl get /services/php-apache
172.17.0.6
```


---

Access to API with proxy

```
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```


```
$ curl http://127.0.0.1:8001/api/v1/namespaces/default/pods?labelSelector=run=php-apache | jq -r .items[].status.podIP
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4439    0  4439    0     0  1703k      0 --:--:-- --:--:-- --:--:-- 2167k
172.17.0.5
```