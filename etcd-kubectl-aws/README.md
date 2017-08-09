1. Create etcd-cluster deployment:

```
kubectl create -f etcd-cluster-deployment-aws.yaml
kubectl create -f five-nodes-etcd-cluster.yaml
```


2. Create service-discovery deployment:

```
kubectl create -f service-discovery-deployment.yaml
```