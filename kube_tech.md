### Kubernetes + Letsencrypt

<https://github.com/kubernetes/ingress/blob/master/controllers/nginx/README.md>

<https://github.com/kubernetes/ingress/tree/master/examples>

---

<http://blog.ployst.com/development/2015/12/22/letsencrypt-on-kubernetes.html>

<https://github.com/tazjin/kubernetes-letsencrypt>

---

<https://github.com/jetstack/kube-lego>

kube-lego automatically requests certificates for Kubernetes Ingress resources from Let's Encrypt

<https://blog.jetstack.io/blog/kube-lego/>

---

<https://github.com/kelseyhightower/kube-cert-manager>

For GAE

---

<https://github.com/choffmeister/kubernetes-certbot>

Uses certbot to obtain an X.509 certificate from Let's encrypt and stores it as secret in Kubernetes.

---
**!**

<https://runnable.com/blog/how-to-use-lets-encrypt-on-kubernetes>

<https://github.com/thejsj/kubernetes-letsencrypt-demo>

---

### NGINX configmap

The first thing we’ll do is define our endpoint by creating a ConfigMap that stores our Nginx configuration

<https://kubernetes.io/docs/tasks/configure-pod-container/configmap/>

---

### REDIS configmap

<https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/>


Scalable Redis

<https://github.com/kubernetes/examples/blob/master/staging/storage/redis/README.md>

---

The Kubernetes scheduler runs as a process alongside the other master components such as the API server. Its interface to the API server is to watch for Pods with an empty PodSpec.NodeName, and for each Pod, it posts a binding indicating where the Pod should be scheduled.

<https://github.com/kubernetes/community/blob/master/contributors/devel/scheduler.md>

<https://kubernetes.io/docs/concepts/configuration/assign-pod-node/>

<https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/>


---

### Stateful examples

<https://github.com/saturnism/akka-kubernetes-example>

<https://www.stratoscale.com/blog/kubernetes/kubernetes-how-to-share-disk-storage-between-containers-in-a-pod/>

<https://kubernetes.io/docs/concepts/storage/persistent-volumes/>

