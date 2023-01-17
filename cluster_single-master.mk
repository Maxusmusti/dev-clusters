cluster_single-master:
	@make all
	@make has_installer
	@make config_new_install
	@make config_single-master
	@make config_dev
	@make manifest
	@make manifest_single-master
	@make install
	@make kubeconfig

cluster: cluster_single-master

# ---

config_single-master:
	yq -yi '.controlPlane.replicas=1' "${CLUSTER_PATH}/install-config.yaml"

config_dev:
	yq -yi '.compute[0].replicas=1' "${CLUSTER_PATH}/install-config.yaml"
	yq -yi '.compute[0].platform.aws.type="m5.4xlarge"' "${CLUSTER_PATH}/install-config.yaml"
	yq -yi '.controlPlane.platform.aws.type="m5.4xlarge"' "${CLUSTER_PATH}/install-config.yaml"

manifest_single-master:
	cp -v ${SINGLE_MASTER_MANIFESTS} ${SINGLE_MASTER_DST}
	cat "${SINGLE_MASTER_CVO_OVERRIDE}" >> "${CLUSTER_PATH}/manifests/cvo-overrides.yaml"

install_single-master_fix-authentication:
	env KUBECONFIG="${CLUSTER_PATH}/auth/kubeconfig" \
	oc apply -f "${SINGLE_MASTER_DIR}/single-authentication.yaml"
