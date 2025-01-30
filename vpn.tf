# vpn.tf
resource "google_compute_router" "router" {
  name    = "vpn-router"
  network = google_compute_network.vpc.name
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_vpn_gateway" "gateway" {
  name    = "vpn-gateway"
  network = google_compute_network.vpc.name
  region  = var.region
}

resource "google_compute_address" "vpn_static_ip" {
  name   = "vpn-static-ip"
  region = var.region
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "vpn-tunnel1"
  peer_ip       = var.onprem_ip_address
  shared_secret = "your-secret-key-here"

  target_vpn_gateway = google_compute_vpn_gateway.gateway.id

  remote_traffic_selector = ["192.168.0.0/16"]  # Your on-premise network
  local_traffic_selector  = ["192.168.200.0/24", "192.168.210.0/24"]  # GCP networks

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway.id
}

resource "google_compute_route" "route1" {
  name       = "vpn-route1"
  network    = google_compute_network.vpc.name
  dest_range = "192.168.0.0/16"  # Your on-premise network
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
}
