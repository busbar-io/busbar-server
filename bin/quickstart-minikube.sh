#!/bin/bash

#
# quickstart-minikube.sh - Single command Busbar Setup for minikube
#

### Validations
# minikube
# kubectl
# helm
# docker

### Action! o/
# Start Minikube
echo -n "Starting Minikube... "
minikube start --extra-config=apiserver.service-node-port-range=1-50000 > /dev/null 2>&1 || exit 1
echo "Ok!"

# Setup Helm
echo -n "Setting up Helm... "
helm init > /dev/null 2>&1
helm update > /dev/null 2>&1
until kubectl --namespace kube-system get pods | grep tiller-deploy | grep -q Running ; do sleep 1 ; done > /dev/null 2>&1
sleep 5
echo "Ok!"

# Setup Private Registry
echo -n "Setting up Private Docker Registry..."
until helm install stable/docker-registry --name busbario-registry --namespace busbar --set persistence.enabled=true --set service.type=NodePort --set service.nodePort=5000 > /dev/null 2>&1; do
    echo -n '.'
done
echo " Ok!"

# Install Busbar
echo -n "Setting up Busbar... "
git clone https://github.com/busbar-io/helm-charts /tmp/busbar-io/helm-charts > /dev/null 2>&1
pushd /tmp/busbar-io/helm-charts > /dev/null 2>&1
git fetch > /dev/null 2>&1
git co feature/minikube-support > /dev/null 2>&1

#busbar_setup_output=$(helm install busbar-minikube --name busbario --namespace busbar --set minikubeIp=$(minikube ip) || exit 1)
busbar_setup_output=$(helm install busbar-minikube --name busbario --namespace busbar --set image.busbar.repository=127.0.0.1:5000/busbar --set minikubeIp=$(minikube ip) || exit 1)

kubectl create clusterrolebinding BusbarDefault \
    --clusterrole=cluster-admin \
    --serviceaccount=busbar:default > /dev/null 2>&1
popd > /dev/null 2>&1
rm -rf /tmp/busbar-io/helm-charts > /dev/null 2>&1
echo "Ok!"

# Setup Kubeconfig
echo -n "Setting up Kubeconfig... "
git clone https://github.com/busbar-io/kubeconfig-server /tmp/busbar-io/kubeconfig-server > /dev/null 2>&1
pushd /tmp/busbar-io/kubeconfig-server > /dev/null 2>&1
echo "$busbar_setup_output" | tail -n 6 > busbar.config
./build_and_push.sh $(minikube ip):5000  > /dev/null 2>&1
popd > /dev/null 2>&1
rm -rf /tmp/busbar-io/kubeconfig-server > /dev/null 2>&1
echo "Ok!"

# Setup Busbar-CLI
echo -n "Setting up Busbar CLI... "
gem install busbar-cli  > /dev/null 2>&1
busbar -u http://$(minikube ip):8001/busbar.config  > /dev/null 2>&1 || busbar busbar-setup -u http://$(minikube ip):8001/busbar.config  > /dev/null 2>&1
echo "Ok!"

# Setup test application

# Echo Local Registry and test application url
