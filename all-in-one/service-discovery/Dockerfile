FROM alpine:3.6

ENV KUBE_VERSION="v1.7.0"

RUN apk add --update ca-certificates openssl tar && \
wget https://storage.googleapis.com/etcd/v3.2.3/etcd-v3.2.3-linux-amd64.tar.gz && \
tar zxvf etcd-v3.2.3-linux-amd64.tar.gz && \
mv etcd-v3.2.3-linux-amd64/etcd* /bin/ && \
apk del --purge tar openssl && \
rm -Rf etcd-v3.2.3-linux-amd64* /var/cache/apk/*


ADD https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

ADD service_discovery.sh /discovery.sh
CMD ["/bin/sh", "./discovery.sh"]