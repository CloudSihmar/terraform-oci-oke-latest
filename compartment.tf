resource "oci_identity_compartment" "kubeCompartment" {
  name = "kube"
  description = "Kube Compartment"
  compartment_id="ocid1.tenancy.oc1..aaaaaaaak2bppm6h6xpghpco4evq7kzyb6z54sa4piforkfto6khbcu7aota"
}
