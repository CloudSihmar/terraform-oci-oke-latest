variable "tenancy_ocid" {}
#variable "user_ocid" {}
#variable "fingerprint" {}
#variable "private_key_path" {}
#variable "compartment_ocid" {}
variable "region" {
default = "us-ashburn-1"
}
variable "private_key_oci" {}
variable "public_key_oci" {}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "pods_cidr" {
  default = "10.1.0.0/16"
}

variable "svc_cidr" {
  default = "10.2.0.0/16"
}

variable "kubeClusterSubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "kubeNodePoolSubnet-CIDR" {
  default = "10.0.3.0/24"
}

variable "node_pool_quantity_per_subnet" {
  default = 2
}

variable "kubernetes_version" {
#  default = "v1.14.8"
   default = "v1.24.1"
}

variable "node_pool_size" {
  default = 3
}

variable "Shape" {
 default = "VM.Standard.E3.Flex"
}

variable "ClusterName" {
  default = "kubeOKECluster"
}


