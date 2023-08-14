
resource "oci_containerengine_cluster" "kubeOKECluster" {
  #depends_on = [oci_identity_policy.FoggyKitchenOKEPolicy1]
  compartment_id     = oci_identity_compartment.kubeCompartment.id
  kubernetes_version = var.kubernetes_version
  name               = var.ClusterName
  vcn_id             = oci_core_vcn.kubeVCN.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.kubeClusterSubnet.id]

    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.svc_cidr
    }
  }
}

locals {
  all_sources = data.oci_containerengine_node_pool_option.OKEClusterNodePoolOption.sources
  oracle_linux_images = [for source in local.all_sources : source.image_id if length(regexall("Oracle-Linux-[0-9]*.[0-9]*-20[0-9]*",source.source_name)) > 0]
}

resource "oci_containerengine_node_pool" "kubeOKENodePool" {
  #depends_on = [oci_identity_policy.kubeOKEPolicy1]
  cluster_id         = oci_containerengine_cluster.kubeOKECluster.id
  compartment_id     = oci_identity_compartment.kubeCompartment.id
  kubernetes_version = var.kubernetes_version
  name               = "kubeOKENodePool"
  node_shape         = var.Shape
  
  node_source_details {
    image_id = "ocid1.image.oc1.iad.aaaaaaaayrldglwozuedpvfllelnmthkcbd5irmjyeih56a4tslst2rne6jq"
    source_type = "IMAGE"
  }

  node_shape_config {
    ocpus = 2
    memory_in_gbs = 40
  }

  node_config_details {
    size      = var.node_pool_size

    placement_configs {
      availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
      subnet_id           = oci_core_subnet.kubeNodePoolSubnet.id
    }  
  }

  initial_node_labels {
    key   = "key"
    value = "value"
  }

  ssh_public_key      = file(var.public_key_oci)
}

