output "OKECluster" {
  value = {
    id                 = oci_containerengine_cluster.kubeOKECluster.id
    kubernetes_version = oci_containerengine_cluster.kubeOKECluster.kubernetes_version
    name               = oci_containerengine_cluster.kubeOKECluster.name
  }
}

output "OKENodePool" {
  value = {
    id                 = oci_containerengine_node_pool.kubeOKENodePool.id
    kubernetes_version = oci_containerengine_node_pool.kubeOKENodePool.kubernetes_version
    name               = oci_containerengine_node_pool.kubeOKENodePool.name
    subnet_ids         = oci_containerengine_node_pool.kubeOKENodePool.subnet_ids
  }
}

output "Cluster_Kubernetes_Versions" {
  value = [data.oci_containerengine_cluster_option.OKEClusterOption.kubernetes_versions]
}

output "Cluster_NodePool_Kubernetes_Version" {
  value = [data.oci_containerengine_node_pool_option.OKEClusterNodePoolOption.kubernetes_versions]
}
