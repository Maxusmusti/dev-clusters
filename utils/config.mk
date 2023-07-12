TODAY ?= $(shell date '+%Y%m%d')
CLUSTER_NAME ?= ${USER}-${TODAY}
CLUSTER_PATH ?= ${PWD}/clusters/${CLUSTER_NAME}

ENTITLEMENT_PEM ?= #Unused

OCP_VERSION ?= 4.13.0
LOCAL_OS ?= linux

# --- #

UTILS_DIR = ${PWD}/utils

# --- #

ENTITLEMENT_RHSM = ${UTILS_DIR}/entitlement/rhsm.conf
ENTITLEMENT_TEMPLATE = ${UTILS_DIR}/entitlement/cluster-wide.entitlement.machineconfigs.yaml.template
ENTITLEMENT_DST_BASENAME = ${CLUSTER_PATH}/openshift/99-openshift-machineconfig-worker-entitlement

# --- #

BASE_INSTALL_CONFIG = ${UTILS_DIR}/install-config.yaml
INSTALL_CONFIG = ${CLUSTER_PATH}/install-config.yaml

# --- #

# https://github.com/vrutkovs/okd-installer/tree/master/manifests/singlenode
SINGLE_MASTER_DIR := ${UTILS_DIR}/single-master
SINGLE_MASTER_MANIFESTS := ${SINGLE_MASTER_DIR}/{single-ingress.yaml,single-node-etcd.yaml,single-authentication.yaml}
SINGLE_MASTER_CVO_OVERRIDE := ${SINGLE_MASTER_DIR}/cvo_override.yml
SINGLE_MASTER_DST := ${CLUSTER_PATH}/manifests/

# --- #

# https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/pre-release/
# https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.6/

OPENSHIFT_INSTALLER ?= ${UTILS_DIR}/installers/${OCP_VERSION}/openshift-install
OPENSHIFT_INSTALLER_URL = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-${LOCAL_OS}-${OCP_VERSION}.tar.gz"

# unset to skip diff confirmation in 'config_base_install'
DIFF_TOOL := meld
