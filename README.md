# CodeFlare Dev Cluster Setup

OCP cluster installation derived from Kevin Pouget's [daily-cluster work](https://github.com/openshift-psap/ci-artifacts/tree/main/subprojects/deploy-cluster)

## Instructions

If on a Mac:
 - Set env var `LOCAL_OS=mac`
 - Default is `linux`

To set up a new cluster run:
 - `make cluster`
 - `make dev-setup` (installs CodeFlare bits/prereqs, OLD/OUTDATED)

To uninstall and clean up when finished, run:
 - `make uninstall`
