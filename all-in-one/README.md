# Creating Kubernetes cluster on aws

### Install kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>

### Install Amazon CLI <https://aws.amazon.com/cli/>

Configure aws cli

```
$ aws configure
AWS Access Key ID [None]: ABCDEFGHIJKLMEXAMPLE
AWS Secret Access Key [None]: ABCEXAMPLEKEY/EXAMPLEKEY/ABCDEFGHEXAMPLEKEY
Default region name [None]: eu-west-1
Default output format [None]: json
```

### Install Kops <https://github.com/kubernetes/kops>

Create S3 bucket

```
aws s3api create-bucket --bucket kube-state-store-abcdef
```

Enable bucket versioning

```
aws s3api put-bucket-versioning --bucket kube-state-store-abcdef  --versioning-configuration Status=Enabled
```


```
export KOPS_STATE_STORE=s3://kube-state-store-abcdef
```

Create cluster

```
kops create cluster --name=kubernetes-cluster.k8s.local \
  --state=s3://kube-state-store-abcdef --zones=eu-west-1a \
  --node-count=2 --node-size=t2.micro --master-size=t2.micro
```

Deploy cluster

```
kops update cluster kubernetes-cluster.k8s.local --yes
```

Check kubeconfig (~/.kube/config)

```
...
current-context: kubernetes-cluster.k8s.local
kind: Config
preferences: {}
users:
- name: kubernetes-cluster.k8s.local

...

- name: kubernetes-cluster.k8s.local-basic-auth
  user:
    password: abcdefghijklmnopqrstuvwxyz
    username: admin
...
```

Get cluster info

```
$ kubectl cluster-info
Kubernetes master is running at https://api-kubernetes-cluster-k8-1ud5n8-7777777777.us-west-1.elb.amazonaws.com
Heapster is running at https://api-kubernetes-cluster-k8-1ud5n8-7777777777.us-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://api-kubernetes-cluster-k8-1ud5n8-7777777777.us-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns/proxy
```

You can login into kubernetes dashboard ui on

```
https://api-kubernetes-cluster-k8-1ud5n8-7777777777.us-west-1.elb.amazonaws.com/ui/
```

with password ```abcdefghijklmnopqrstuvwxyz```  
username ```admin```

---

# Apply aws autoscale to claster

Set min/max node size for your cluster

`kops edit ig nodes`

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
  - eu-west-1a
```

Create policy for auto-scaler

`autoscale/policy-cluster-autoscaler.json`

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

```aws iam put-role-policy --role-name nodes.kubernetes-cluster.k8s.local --policy-name asg-nodes.kubernetes-cluster.k8s.local --policy-document file://autoscale/policy-cluster-autoscaler.json```

Deploy cluster autoscaler addon

```kubectl apply -f autoscale/cluster-autoscaler-deploy.yaml```

Apply autoscale for some deployment

```kubectl autoscale deployment my-deployment --cpu-percent=20 --min=2 --max=10```


---
# Using cluster
---

## ETCD cluster (5 nodes)


```
kubectl create -f etcd-cluster-deployment-aws.yaml
kubectl create -f five-nodes-etcd-cluster.yaml
```


## Service discovery

```service-discovery.sh``` - example with etcd (PoC)


```
kubectl create -f service-discovery-deployment.yaml
```


## Monitoring

```
kubectl create -f monitoring/influxdb/
kubectl create -f monitoring/rbac/
```

---

# Cluster Info

ETCD default endpoint in cluster - `http://example-etcd-cluster-client:2379`

Grafana Url:

```
$ kubectl cluster-info
Kubernetes master is running at https://api-cluster-secret-name.eu-west-1.elb.amazonaws.com
Heapster is running at https://api-cluster-secret-name.eu-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://api-cluster-secret-name.eu-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns/proxy
monitoring-grafana is running at https://api-cluster-secret-name.eu-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
monitoring-influxdb is running at https://api-cluster-secret-name.eu-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/monitoring-influxdb/proxy
```

User: Admin
Password: `$kubectl config view` -> password