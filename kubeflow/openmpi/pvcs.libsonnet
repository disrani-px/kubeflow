local assets = import "kubeflow/openmpi/assets.libsonnet";
local service = import "kubeflow/openmpi/service.libsonnet";
local serviceaccount = import "kubeflow/openmpi/serviceaccount.libsonnet";
local util = import "kubeflow/openmpi/util.libsonnet";

local ROLE_WORKER = "worker";
local ACCESS_MODE_NONSHARED = "ReadWriteOnce";
local ACCESS_MODE_SHARED = "ReadWriteMany";

{
  all(params)::
    $.master(params) + $.worker(params),

  master(params)::
    [$.pvc(params, "masterDataVolume", ACCESS_MODE_SHARED, "shared-storage-class")],

  worker(params)::
    std.map(
      function(index) $.pvc(params, ACCESS_MODE_NONSHARED, $.pvcName(params, index), "non-shared-storage-class"),
      std.range(0, params.workers - 1)
    ),

  pvcName(params, index)::
    "%s-%s-%d" % [params.name, ROLE_WORKER, index],

  pvc(params, pvcName, accessMode, storageClass):: {
    kind: "PersistentVolumeClaim",
    apiVersion: "v1",
    metadata: {
      name: pvcName,
      namespace: params.namespace,
      labels: {
        app: params.name,
      },
    },
    spec: {
      accessModes: [accessMode],
      storageClassName: storageClass,
      resources: {
          requests: {
            storage: "10Gi",
          },
      },
    },
  },
}
