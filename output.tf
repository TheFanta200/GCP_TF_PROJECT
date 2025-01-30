# outputs.tf
output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_cluster_host" {
  value = google_container_cluster.primary.endpoint
}

output "vpn_gateway_ip" {
  value = google_compute_address.vpn_static_ip.address
}

output "gcp_network_ranges" {
  value = {
    primary_subnet = google_compute_subnetwork.subnet_1.ip_cidr_range
    pod_range      = google_compute_subnetwork.subnet_1.secondary_ip_range[0].ip_cidr_range
    service_range  = google_compute_subnetwork.subnet_1.secondary_ip_range[1].ip_cidr_range
  }
}
