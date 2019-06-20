FROM alpine:3.9

ENV KUBE_LATEST_VERSION="v1.13.4"
ENV HELM_VERSION="v2.12.2"
ENV KSONNET_VERSION="0.13.1"
ENV KNCTL_VERSION="v0.3.0"
ENV KUBEFWD_VERSION="v1.8.2"

RUN apk update \
	&& apk add --update py-pip ca-certificates wget \
	&& pip install 'docker-compose==1.10' \
	&& update-ca-certificates \
	&& apk --update add --no-cache qemu-system-x86_64 libvirt openrc make ca-certificates bash git curl docker gcc autoconf findutils pkgconf libtool g++ automake linux-headers \
	&& wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
	&& chmod +x /usr/local/bin/kubectl \
	&& wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
	&& chmod +x /usr/local/bin/helm \
	&& wget -q https://github.com/ksonnet/ksonnet/releases/download/v${KSONNET_VERSION}/ks_${KSONNET_VERSION}_linux_amd64.tar.gz \
	&& tar zxvf ks_${KSONNET_VERSION}_linux_amd64.tar.gz \
	&& cp ks_${KSONNET_VERSION}_linux_amd64/ks /usr/local/bin \
	&& chmod +x /usr/local/bin/ks \
	&& rm -r ks_${KSONNET_VERSION}_linux_amd64/ \
        && wget -q https://github.com/cppforlife/knctl/releases/download/${KNCTL_VERSION}/knctl-linux-amd64 -O /usr/local/bin/kubectl-kn \
	&& chmod +x /usr/local/bin/kubectl-kn \
        && wget -q https://github.com/txn2/kubefwd/releases/download/1.8.2/kubefwd_linux_amd64.tar.gz -O - | tar -xzO kubefwd > /usr/local/bin/kubefwd \
	&& chmod +x /usr/local/bin/kubefwd \
        && wget -q https://github.com/txn2/kubefwd/releases/download/1.8.2/kubefwd_linux_amd64.tar.gz -O - | tar -xzO kubefwd > /usr/local/bin/kubefwd \
	&& chmod +x /usr/local/bin/kubefwd \
	&& git clone https://github.com/ahmetb/kubectx /opt/kubectx \
	&& ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx \
	&& ln -s /opt/kubectx/kubens /usr/local/bin/kubens \
	&& chmod +x /usr/local/bin/kubectx \
	&& chmod +x /usr/local/bin/kubens

CMD ["bash"]
