resource "oci_core_vcn" "kubeVCN" {
  cidr_block     = var.VCN-CIDR
  compartment_id = oci_identity_compartment.kubeCompartment.id
  display_name   = "kubeVCN"
}

resource "oci_core_internet_gateway" "kubeInternetGateway" {
  compartment_id = oci_identity_compartment.kubeCompartment.id
  display_name   = "kubeInternetGateway"
  vcn_id         = oci_core_vcn.kubeVCN.id
}

resource "oci_core_nat_gateway" "oke_nat_gateway" {
    #Required
    compartment_id = oci_identity_compartment.kubeCompartment.id
    vcn_id = oci_core_vcn.kubeVCN.id

    #Optional
    display_name = "OKE-NAT-Gateway"
   # route_table_id = oci_core_route_table.kubeOKEPublic.id
}

resource "oci_core_route_table" "kubeOKEPublic" {
  compartment_id = oci_identity_compartment.kubeCompartment.id
  vcn_id         = oci_core_vcn.kubeVCN.id
  display_name   = "kubeOKEPublic"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id =  oci_core_internet_gateway.kubeInternetGateway.id
  }
}

resource "oci_core_route_table" "kubeOKEPrivate" {
  compartment_id = oci_identity_compartment.kubeCompartment.id
  vcn_id         = oci_core_vcn.kubeVCN.id
  display_name   = "kubeOKEPrivate"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id =  oci_core_nat_gateway.oke_nat_gateway.id
  }
}

# cluster security group
resource "oci_core_security_list" "clusterSecurityList" {
    compartment_id = oci_identity_compartment.kubeCompartment.id
    display_name = "clusterSecurityList"
    vcn_id = oci_core_vcn.kubeVCN.id
    
    egress_security_rules {
        protocol = "All"
        destination = "0.0.0.0/0"
    }

    /* This entry is necesary for DNS resolving (open UDP traffic). */
    ingress_security_rules {
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
          max = 6443
          min = 6443
      }
        
    }
    ingress_security_rules {
        protocol = "6"
        source = var.kubeNodePoolSubnet-CIDR
        tcp_options {
          max = 6443
          min = 6443
      }
    }
    
    ingress_security_rules {
        protocol = "6"
        source = var.kubeNodePoolSubnet-CIDR
        tcp_options {
          max = 12250
          min = 12250
      }
    }
    
    ingress_security_rules {
        protocol = "1"
        source = var.kubeNodePoolSubnet-CIDR

    }
}

# node security group

resource "oci_core_security_list" "NodeSecurityList" {
    compartment_id = oci_identity_compartment.kubeCompartment.id
    display_name = "NodeSecurityList"
    vcn_id = oci_core_vcn.kubeVCN.id

    egress_security_rules {
        protocol = "All"
        destination = "0.0.0.0/0"
    }
    egress_security_rules {
        protocol = "All"
        destination = var.kubeNodePoolSubnet-CIDR
    }
    egress_security_rules {
        protocol = "6"
        destination = var.kubeClusterSubnet-CIDR 
        tcp_options {
          max = 6443
          min = 6443
      }   
 }

    egress_security_rules {
        protocol = "6"
        destination = var.kubeClusterSubnet-CIDR
        tcp_options {
          max = 12250
          min = 12250
      }
    }
    egress_security_rules {
        protocol = "1"
        destination = "0.0.0.0/0"
    }
    egress_security_rules {
        protocol = "All"
        destination = "0.0.0.0/0"
    }


    /* This entry is necesary for DNS resolving (open UDP traffic). */
    ingress_security_rules {
        protocol = "All"
        source = var.kubeNodePoolSubnet-CIDR

    }
    ingress_security_rules {
        protocol = "All"
        source = var.kubeClusterSubnet-CIDR

    }

    ingress_security_rules {
        protocol = "1"
        source = var.kubeClusterSubnet-CIDR

    }
}


resource "oci_core_subnet" "kubeClusterSubnet" {
  cidr_block          = var.kubeClusterSubnet-CIDR
  compartment_id      = oci_identity_compartment.kubeCompartment.id
  vcn_id              = oci_core_vcn.kubeVCN.id
  display_name        = "kubeClusterSubnet"

  security_list_ids = [oci_core_vcn.kubeVCN.default_security_list_id, oci_core_security_list.clusterSecurityList.id]
  route_table_id    = oci_core_route_table.kubeOKEPublic.id
}

resource "oci_core_subnet" "kubeNodePoolSubnet" {
  cidr_block          = var.kubeNodePoolSubnet-CIDR
  compartment_id      = oci_identity_compartment.kubeCompartment.id
  vcn_id              = oci_core_vcn.kubeVCN.id
  display_name        = "kubeNodePoolSubnet"

  security_list_ids = [oci_core_vcn.kubeVCN.default_security_list_id, oci_core_security_list.NodeSecurityList.id]
  route_table_id    = oci_core_route_table.kubeOKEPrivate.id
}

