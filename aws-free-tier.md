# Creating Kubernetes cluster on aws (free tier)


### Install Amazon CLI <https://aws.amazon.com/cli/>

Configure aws cli

```
$ aws configure
AWS Access Key ID [None]: ABCDEFGHIJKLMEXAMPLE
AWS Secret Access Key [None]: ABCEXAMPLEKEY/EXAMPLEKEY/ABCDEFGHEXAMPLEKEY
Default region name [None]: us-west-1
Default output format [None]: ENTER
```

### Install Kops <https://github.com/kubernetes/kops>

Create S3 bucket

```
aws s3api create-bucket --bucket kube-state-store-abcdef --region us-west-1
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
  --state=s3://kube-state-store-abcdef --zones=us-west-1 \
  --node-count=2 --node-size=t2.micro --master-size=t2.micro
```

```.local``` - Experimental support to create a gossip-based cluster. Otherwise top-level domain or a subdomain is required to create the cluster. This domain allows the worker nodes to discover the master and the master to discover all the etcd servers.

Choose your favorite editor (default - vim)

```
export EDITOR=gedit
```

Review/edit cluster

```
kops edit cluster kubernetes-cluster.k8s.local
```

Deploy cluster

```
kops update cluster kubernetes-cluster.k8s.local --yes
```

### Install kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>

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

Delete cluster

```
kops delete cluster kubernetes-cluster.k8s.local --yes
```

Delete S3 bucket

```
aws s3api delete-bucket --bucket kube-state-store-abcdef
```

---

<https://aws.amazon.com/blogs/compute/kubernetes-clusters-aws-kops/>