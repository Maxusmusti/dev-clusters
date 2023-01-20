#! /bin/bash

set -o pipefail
set -o errexit
set -o nounset

KUBECONFIG=${KUBECONFIG:-}

if [[ -z "${KUBECONFIG}" ]]; then
    echo "ENV variable KUBECONFIG not set, required. Please see command above."
    exit 1
else
    echo -n "Proceed with KUBECONFIG=${KUBECONFIG}? (y/[n]): "
    read response
    if [[ "${response}" != "Y" && "${response}" != "y" ]]; then
        exit 1
    fi
fi

# NFD Operator, GPU Operator, and RHODS
git clone https://github.com/openshift-psap/ci-artifacts.git
cd ci-artifacts
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./run_toolbox.py nfd_operator deploy_from_operatorhub
./run_toolbox.py gpu_operator deploy_from_operatorhub
oc create namespace "anonymous" -oyaml --dry-run=client | oc apply -f- #Remove this line if skipping RHODS installation
./run_toolbox.py cluster deploy_operator redhat-operators rhods-operator all #Remove this line to skip RHODS installation
#./run_toolbox.py rhods wait_ods
deactivate -f
cd ..
rm -rf ci-artifacts

# HELM (Ensure installation and correct version)
HELM_VERSION=$(helm version 2>/dev/null |  perl -pe 's/^.*Version:"v(.+?)",.*$/$1/')
if [[ "${HELM_VERSION:0:1}" < 3 ]]; then
    rm -f $(command -v helm)
    rm -rf $HOME/.cache/helm
    rm -rf $HOME/.config/helm
    rm -rf $HOME/.local/share/helm
    HELM_VERSION=""
fi
if [ "" = "${HELM_VERSION}" ]; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm -f get_helm.sh
fi

# MCAD
git clone https://github.com/project-codeflare/multi-cluster-app-dispatcher.git 
helm list -n kube-system
cd multi-cluster-app-dispatcher/deployment/mcad-controller/
helm upgrade --install --wait mcad . --namespace kube-system --set loglevel=4 --set image.repository=darroyo/mcad-controller --set image.tag=quota-management-v1.29.40 --set image.pullPolicy=Always --set configMap.name=mcad-controller-configmap --set configMap.quotaEnabled='"false"' --set coscheduler.rbac.apiGroup="scheduling.sigs.k8s.io" --set coscheduler.rbac.resource="podgroups"
cd ../../..
rm -rf multi-cluster-app-dispatcher

# INSTASCALE
git clone https://github.com/project-codeflare/instascale.git
cd instascale/deployment/
oc apply -f instascale-configmap.yaml
oc apply -f instascale-sa.yaml
oc apply -f instascale-clusterrole.yaml
oc apply -f instascale-clusterrolebinding.yaml
oc apply -f deployment.yaml
cd ../..
rm -rf instascale

# RAY (via KubeRay Operator)
oc create -k "github.com/ray-project/kuberay/ray-operator/config/crd?ref=v0.3.0"
helm install kuberay-operator --namespace ray-system --create-namespace $(curl -s https://api.github.com/repos/ray-project/kuberay/releases/tags/v0.3.0 | grep '"browser_download_url":' | sort | grep -om1 'https.*helm-chart-kuberay-operator.*tgz')

# ClusterRole Patch
git clone https://github.com/project-codeflare/multi-cluster-app-dispatcher.git
cd multi-cluster-app-dispatcher/doc/usage/examples/kuberay/config
oc delete ClusterRole system:controller:xqueuejob-controller || true
oc apply -f xqueuejob-controller.yaml
oc delete clusterrolebinding kuberay-operator
oc create clusterrolebinding kuberay-operator --clusterrole=cluster-admin --user="system:serviceaccount:ray-system:kuberay-operator"
cd ../../../../../..
rm -rf multi-cluster-app-dispatcher
