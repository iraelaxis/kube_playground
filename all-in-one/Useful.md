### Rolling-update docker image with one replica

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: webserver

spec:
  minReadySeconds: 60 # the bootup time of application
  replicas: 1

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0


  template:
    metadata:
      labels:
        app: webserver

    spec:
      containers:
       - name: webserver-image
         image: nginx:1.7.9
         imagePullPolicy: Always
         ports:
         - name: http
           containerPort: 80
```

```
$ kubectl expose deployment webserver --type=LoadBalancer --name=lb-nginx
```

```
$ kubectl set image deployment/webserver webserver-image=nginx:1.9.1
```

```
$ kubectl get pods -w
NAME                        READY     STATUS    RESTARTS   AGE
webserver-531659468-lvlsc   1/1       Running   0          1m
webserver-1514103833-39r8r   0/1       Pending   0         0s
webserver-1514103833-39r8r   0/1       Pending   0         0s
webserver-1514103833-39r8r   0/1       ContainerCreating   0         0s
webserver-1514103833-39r8r   1/1       Running   0         9s

-------60 sec...-------

webserver-531659468-lvlsc   1/1       Terminating   0         2m
webserver-531659468-lvlsc   0/1       Terminating   0         2m
```

