### Set min/max node size for your cluster

```
kops edit ig nodes
```

```
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: 2017-07-20T04:44:39Z
  labels:
    kops.k8s.io/cluster: kubernetes-cluster.k8s.local
  name: nodes
spec:
  image: kope.io/k8s-1.6-debian-jessie-amd64-hvm-ebs-2017-05-02
  machineType: t2.micro
  maxSize: 5
  minSize: 2
  role: Node
  subnets:
  - us-west-1a
```


### Create policy for auto-scaler


policy-cluster-autoscaler.json
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
```


```
aws iam put-role-policy --role-name nodes.kubernetes-cluster.k8s.local --policy-name asg-nodes.kubernetes-cluster.k8s.local --policy-document file://policy-cluster-autoscaler.json
```

### Deploy cluster autoscaler addon


```
kubectl apply -f cluster-autoscaler-deploy.yaml
```

```
$ kubectl get pods --namespace kube-system
NAME                                                                 READY     STATUS    RESTARTS   AGE
cluster-autoscaler-462496643-8p7ps                                   1/1       Running   0          2h
...
```

Create the autoscaler for the hugo-app application, which will maintain between 2 to 20 Pods and increase/decrease the amount of Pods in order to maintain an average CPU utilization across all Pods of 5%

```
kubectl autoscale deployment hugo-app --cpu-percent=5 --min=2 --max=20
```


```
$ kubectl get hpa hugo-app
NAME       REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
hugo-app   Deployment/hugo-app   0% / 3%   2         20        2          1h
```


Pods during stress test

```
$ kubectl get pods -w
NAME                        READY     STATUS    RESTARTS   AGE
hugo-app-3450081761-06zww   1/1       Running   0          3h
hugo-app-3450081761-492pg   1/1       Running   0          5m
hugo-app-3450081761-4db24   1/1       Running   0          3h
hugo-app-3450081761-b5qmh   1/1       Running   0          13m
hugo-app-3450081761-bz19c   1/1       Running   0          9m
hugo-app-3450081761-c0rhd   1/1       Running   0          5m
hugo-app-3450081761-fwtgw   1/1       Running   0          5m
hugo-app-3450081761-jp1xx   1/1       Running   0          9m
hugo-app-3450081761-k3p65   1/1       Running   0          1m
hugo-app-3450081761-kfbhs   1/1       Running   0          5m
hugo-app-3450081761-kmc1r   1/1       Running   0          5m
hugo-app-3450081761-l32fc   0/1       Pending   0          1m
hugo-app-3450081761-nrnrc   1/1       Running   0          5m
hugo-app-3450081761-nsjgr   1/1       Running   0          9m
hugo-app-3450081761-qzhqh   1/1       Running   0          1m
hugo-app-3450081761-ss6qg   1/1       Running   0          13m
hugo-app-3450081761-tcpwj   1/1       Running   0          5m
hugo-app-3450081761-x6nxq   0/1       Pending   0          1m
hugo-app-3450081761-xfhlx   1/1       Running   0          5m
hugo-app-3450081761-xtfcx   1/1       Running   0          9m
```

Get hpa events

```
$ kubectl describe hpa
Name:							hugo-app
Namespace:						default
Labels:							<none>
Annotations:						<none>
CreationTimestamp:					Fri, 21 Jul 2017 14:16:03 +0600
Reference:						Deployment/hugo-app
Metrics:						( current / target )
  resource cpu on pods  (as a percentage of request):	0% (0) / 3%
Min replicas:						2
Max replicas:						20
Events:
  FirstSeen	LastSeen	Count	From				SubObjectPath	Type		Reason			Message
  ---------	--------	-----	----				-------------	--------	------			-------
  29m		29m		1	horizontal-pod-autoscaler			Normal		SuccessfulRescale	New size: 4; reason: cpu resource utilization (percentage of request) above target
  25m		25m		1	horizontal-pod-autoscaler			Normal		SuccessfulRescale	New size: 8; reason: cpu resource utilization (percentage of request) above target
  21m		21m		1	horizontal-pod-autoscaler			Normal		SuccessfulRescale	New size: 16; reason: cpu resource utilization (percentage of request) above target
  17m		17m		1	horizontal-pod-autoscaler			Normal		SuccessfulRescale	New size: 20; reason: cpu resource utilization (percentage of request) above target
```

Get autoscaler logs

```
$ kubectl logs cluster-autoscaler-462496643-8p7ps -n kube-system
I0721 07:31:37.495759       1 main.go:208] Cluster Autoscaler 0.5.1
I0721 07:31:37.791403       1 leaderelection.go:179] attempting to acquire leader lease...
I0721 07:31:37.796865       1 leaderelection.go:189] successfully acquired lease kube-system/cluster-autoscaler
...
```