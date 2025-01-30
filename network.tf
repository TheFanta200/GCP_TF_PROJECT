# network.tf
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "${var.network_name}-subnet-1"
  network       = google_compute_network.vpc.self_link
  region        = var.region
  ip_cidr_range = "192.168.200.0/24"

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "192.168.210.0/24"
  }

  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "192.168.220.0/24"
  }
}

# Firewall rule to allow internal communication
resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["192.168.200.0/24", "192.168.210.0/24", "192.168.0.0/16"]
}
