# CoreOS

### etcd

(The Raft Consensus Algorithm) <https://raft.github.io/>


<https://github.com/coreos/etcd>

Distributed reliable key-value store for the most critical data of a distributed system 

etcd is an open-source distributed key value store that provides shared configuration and service discovery for Container Linux clusters. etcd runs on each machine in a cluster and gracefully handles leader election during network partitions and the loss of the current leader.


<https://futurestud.io/tutorials/coreos-platform-introduction-and-components>

CoreOS uses etcd for automatic host detection for a cluster. Each CoreOS cluster has its own cluster identifier and etcd handles the connection of new hosts into the cluster. Further, etcd is targeted towards service discovery to let applications announce itself to etcd.

A common use-case is to store the database connection details into etcd as key-value data. All hosts within the cluster can read the information and also watch for changes to reconfigure apps dependent on the database connection.

etcd is shipped with CoreOS by default. Additionally, a command line tool called etcdctl is integrated with CoreOS as well. You can interact with etcd using either the HTTP/JSON-API or the etcdctl utility. The HTTP/JSON-API is exposed by default on http://127.0.0.1:4001/v2/keys/ and also available for every docker container running on a local machine. You can take advantage of the values stored within etcd from your apps running inside a container.

> **etcd uses the Raft consensus algorithm and is robust against leader failures**

> CoreOS installs system updates and reboots automatically. These reboots are handled with etcd and locksmith. If you’re running a cluster with 10 machines and all machines are rebooting at the same time right after the update, there won’t be any service available to handle requests and the sense of high-availability vanishes. To prevent a reboot of the entire cluster, CoreOS uses etcd to handle restarts of machines (by default one machine at a time).

### etcdctl

<https://github.com/coreos/etcd/blob/master/etcdctl/READMEv2.md>

etcdctl is a command line client for etcd. It can be used in scripts or for administrators to explore an etcd cluster.



### Fleet (*Depricated*)

<https://coreos.com/fleet/docs/latest/>

> fleet is no longer actively developed or maintained by CoreOS

For single servers you can use systemd to start services and for CoreOS clusters, there is a tool called fleet.

fleet is a cluster-level service scheduler and enables cluster orchestration. With fleet you can manage your cluster of machines as if they share a single init system. Imagine fleet as follows: instead of starting services on a specific machine, you use fleet to submit services into your cluster and the cluster manager (fleet itself) decides on the machine to start it.

CoreOS ships with fleet and also the command line tool fleetctl for management purposes. With the help of fleetctl, you’re able to get the state and information of your services submitted and running within your cluster. Besides the fact that you start applications (called services) on your cluster, you can define additional service conditions. A condition can be the placement of services on a specific host next to another service.

fleet uses systemd to start processes on machines. The processes require a defined systemd unit file with custom options. Once a service configuration is passed into fleet, you can manage them at cluster level from any other cluster machine.	


<https://github.com/coreos/fleet/blob/master/Documentation/fleet-k8s-compared.md>


### Kubernetes

<https://www.infoq.com/articles/scaling-docker-with-kubernetes>

Kubernetes is the container cluster manager from Google that offers a unique workflow for managing containers across multiple machines. Kubernetes introduces the concept of a pod, which represents a group of containers that should be deployed as a single logical service. The pod concept tends to fit well with the popular pattern of running a single service per container. Kubernetes makes it easy to run multiple pods on a single machine or across an entire cluster for better resource utilization and high availability. Kubernetes also actively monitors the health of pods to ensure they are always running within the cluster.


# JUJU

**Model, configure and manage services with Juju and deploy to all major public and private clouds with only a few commands.**


```
sudo add-apt-repository -u ppa:juju/stable
sudo apt install juju lxd zfsutils-linux
```

```
groups
newgrp lxd
sudo lxd init
```

```
Name of the storage backend to use (dir or zfs) zfs: 
Create a new ZFS pool (yes/no) [default=yes]? 
Name of the new ZFS pool [default=lxd]: zfslxd
Would you like to use an existing block device (yes/no) [default=no]? 
Size in GB of the new loop device (1GB minimum) : 50
Would you like LXD to be available over the network (yes/no) [default=no]? 
Do you want to configure the LXD bridge (yes/no) [default=yes]?
```



`zpool destroy zfslxd` - destroy pool

---

в случае косяков с lxd

As a workaround, you can delete /var/lib/lxd after purging it and that should get rid of any references.

---

juju bootstrap localhost lxd-test
juju controllers
juju whoami

juju deploy cs:bundle/mediawiki-single
juju status

juju destroy-model default



---



# MINIKUBE

<https://github.com/kubernetes/minikube>


Начало работы в Kubernetes с помощью Minikube
<https://habrahabr.ru/company/flant/blog/333470/>

---

Если проблемы с докером:

<https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/getting-started-guides/docker.md>



You need to have docker installed on one machine.

Your kernel should support memory and swap accounting. Ensure that the following configs are turned on in your linux kernel:

```
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
```

Enable the memory and swap accounting in the kernel, at boot, as command line parameters as follows:

```
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
```

NOTE: The above is specifically for GRUB2. You can check the command line parameters passed to your kernel by looking at the output of /proc/cmdline:

```
$cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-3.18.4-aufs root=/dev/sda5 ro cgroup_enable=memory
swapaccount=1
```

---

Действия после <https://habrahabr.ru/company/flant/blog/333470/>

Удалить всё - `minikube delete`


Показать всё - `kubectl get all --all-namespaces`


Запуск dashboard - `minikube dashboard`

Запускается на виртульном ip (```minikube ip```), gui на 30000 порту  

Показать все сервисы - ```minikube service list```


Monitor pods - `kubectl get pods -w`


Доступ к dashboard из kubectl из любого места:

```
kubectl proxy --port=8091
kubectl -s=http://127.0.0.1:8091 get pods
```



### Load Balancer

```
crn@sm-crn:/$  kubectl run hello-world --replicas=2 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
deployment "hello-world" created
```

```
crn@sm-crn:/$ kubectl get pods --selector="run=load-balancer-example"
NAME                           READY     STATUS              RESTARTS   AGE
hello-world-3272482377-93qc5   0/1       ContainerCreating   0          1s
hello-world-3272482377-zscgm   0/1       ContainerCreating   0          1s
```

```
crn@sm-crn:/$ kubectl get pods --selector="run=load-balancer-example"
NAME                           READY     STATUS              RESTARTS   AGE
hello-world-3272482377-93qc5   0/1       ContainerCreating   0          25s
hello-world-3272482377-zscgm   0/1       ContainerCreating   0          25s
```

```
crn@sm-crn:/$ kubectl get replicasets --selector="run=load-balancer-example"
NAME                     DESIRED   CURRENT   READY     AGE
hello-world-3272482377   2         2         0         26s
```

```
crn@sm-crn:/$ kubectl expose rs hello-world-3272482377 --type="LoadBalancer" --name="example-service"
service "example-service" exposed
```

```
crn@sm-crn:/$ kubectl get services example-service
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
example-service   10.0.0.13    <pending>     8080:30203/TCP   3m
```


```
crn@sm-crn:/$ minikube service example-service --url
http://192.168.99.100:30203
```

```
crn@sm-crn:/$ kubectl describe services example-service
Name:			example-service
Namespace:		default
Labels:			pod-template-hash=3272482377
			run=load-balancer-example
Annotations:		<none>
Selector:		pod-template-hash=3272482377,run=load-balancer-example
Type:			LoadBalancer
IP:			10.0.0.13
Port:			<unset>	8080/TCP
NodePort:		<unset>	30203/TCP
Endpoints:		172.17.0.7:8080,172.17.0.8:8080
Session Affinity:	None
Events:			<none>
```

```
crn@sm-crn:/$ curl $(minikube service example-service --url)
Hello Kubernetes!
```


Internal load balancer on AWS
<https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer>



### Autoscale

<https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>

<https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/>

<https://kubernetes.io/docs/user-guide/kubectl/v1.6/#autoscale>

<https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler>

---

*Работающий пример. Скейлинг по числу реквестов:*

<https://github.com/influxdata/k8s-kapacitor-autoscale/blob/master/README.md>


### k8s monitoring

cAdvisor <https://github.com/google/cadvisor>

Heapster <https://github.com/kubernetes/heapster>

InfluxDB\Grafana <https://portal.influxdata.com/downloads>

Kubedash <https://github.com/kubernetes/dashboard>



### Structure

Each Pod gets it’s own virtual IP address, but these IP addresses aren’t useful to the outside world.

*ReplicationControllers* in particular create and destroy Pods dynamically (e.g. when scaling up or down or when doing rolling updates). While each Pod gets its own IP address, even those IP addresses cannot be relied upon to be stable over time. This leads to a problem: if some set of Pods (let’s call them backends) provides functionality to other Pods (let’s call them frontends) inside the Kubernetes cluster, how do those frontends find out and keep track of which backends are in that set?


A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. The set of Pods targeted by a Service is (usually) determined by a *Label Selector*


Ingress controllers are applications that watch Ingresses in the cluster and configure a balancer to apply those rules. You can configure any of the third party balancers like HAProxy, NGINX, Vulcand or Traefik to create your version of the Ingress controller.  Ingress controller should track the changes in ingress resources, services and pods and accordingly update configuration of the balancer.


### Load-balance layers

*Service* can be used to load-balance traffic to *pods* al layer 4.

*Ingress* are used to load-balance traffic between *pods* at layer 7.



ClusterIP: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. This is the default ServiceType

NodePort: Exposes the service on each Node’s IP at a static port (the NodePort). A ClusterIP service, to which the NodePort service will route, is automatically created. You’ll be able to contact the NodePort service, from outside the cluster, by requesting <NodeIP>:<NodePort>.

LoadBalancer: Exposes the service externally using a cloud provider’s load balancer. NodePort and ClusterIP services, to which the external load balancer will route, are automatically created.



>You'll need to specify the namespace also, since its not in the default namespace.

```
$ kubectl get all --all-namespaces
NAMESPACE     NAME                                      READY     STATUS    RESTARTS   AGE
default       po/app-rhqnt                              1/1       Running   3          22h
default       po/kapacitor-q1f4l                        1/1       Running   3          23h
kube-system   po/default-http-backend-mfjf3             1/1       Running   3          23h
kube-system   po/kube-addon-manager-minikube            1/1       Running   4          23h
kube-system   po/kube-dns-1301475494-ph68j              3/3       Running   9          23h
kube-system   po/kubernetes-dashboard-7svwr             1/1       Running   4          23h
kube-system   po/monitoring-influxdb-grafana-v4-6j8q3   2/2       Running   2          5m
kube-system   po/nginx-ingress-controller-rnng1         1/1       Running   4          23h

NAMESPACE     NAME                                DESIRED   CURRENT   READY     AGE
kube-system   rc/default-http-backend             1         1         1         23h
kube-system   rc/kubernetes-dashboard             1         1         1         23h
kube-system   rc/monitoring-influxdb-grafana-v4   1         1         1         5m
kube-system   rc/nginx-ingress-controller         1         1         1         23h

NAMESPACE     NAME                       CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
default       svc/app                    10.0.0.205   <nodes>       8000:31878/TCP      23h
default       svc/kapacitor              10.0.0.232   <nodes>       9092:30713/TCP      23h
default       svc/kubernetes             10.0.0.1     <none>        443/TCP             23h
kube-system   svc/default-http-backend   10.0.0.137   <nodes>       80:30001/TCP        23h
kube-system   svc/heapster               10.0.0.9     <none>        80/TCP              5m
kube-system   svc/kube-dns               10.0.0.10    <none>        53/UDP,53/TCP       23h
kube-system   svc/kubernetes-dashboard   10.0.0.178   <nodes>       80:30000/TCP        23h
kube-system   svc/monitoring-grafana     10.0.0.168   <none>        80/TCP              6m
kube-system   svc/monitoring-influxdb    10.0.0.144   <none>        8083/TCP,8086/TCP   5m

NAMESPACE     NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kube-system   deploy/kube-dns   1         1         1            1           23h

NAMESPACE     NAME                     DESIRED   CURRENT   READY     AGE
default       rs/app                   1         1         1         23h
default       rs/kapacitor             1         1         1         23h
kube-system   rs/kube-dns-1301475494   1         1         1         23h
```

---

<https://kubernetes.io/docs/concepts/configuration/secret/>

Objects of type *secret* are intended to hold sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a pod definition or in a docker image. 



---

Update docker image

<https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/>

---

Load-balancer

<https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/>