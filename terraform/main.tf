terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
  backend "gcs" {
    bucket = "jenkins-project-sasc"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "jenkins-project-388812"
  region  = "us-central1"
}

resource "google_storage_bucket" "bucket" {
  name          = "jenkins-project-sasc"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "uploaded_objects" {
  for_each = {
    for obj_name, obj in var.objects_to_upload : obj_name => obj
  }

  name   = each.value.remote_path
  bucket = google_storage_bucket.bucket.name
  source = each.value.local_path
}

resource "google_dns_managed_zone" "sa-gcp" {
  name          = "gcp"
  dns_name      = "gcp.sergioatenciano.es."
  force_destroy = true
  visibility    = "public"

  cloud_logging_config {
    enable_logging = false
  }

  timeouts {}
}

resource "google_dns_record_set" "A-jenkins" {
  managed_zone = google_dns_managed_zone.sa-gcp.name
  name         = "jenkins.gcp.sergioatenciano.es."
  rrdatas = [
    "35.224.190.233",
  ]
  ttl  = 300
  type = "A"
}

resource "google_dns_record_set" "A-test" {
  managed_zone = google_dns_managed_zone.sa-gcp.name
  name         = "test.gcp.sergioatenciano.es."
  rrdatas = [
    "35.224.190.233",
  ]
  ttl  = 300
  type = "A"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_project_metadata" "ssh_key" {
  metadata = {
    ssh-keys = format("sshuser:%s", tls_private_key.ssh_key.public_key_openssh)
  }
}

resource "local_file" "ssh_key" {
  filename        = ".ssh/sshkey.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
}

resource "google_compute_instance" "jenkins" {
  name                = "jenkins-vm"
  machine_type        = "g1-small"
  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false
  zone                = "us-central1-a"

  labels = {
    "goog-dm" = "jenkins"
  }

  metadata = {
    "google-logging-enable"    = "0"
    "google-monitoring-enable" = "0"
    "status-uptime-deadline"   = "1800"
    "status-variable-path"     = "status"
    "startup-script-url"       = format("gs://%s/%s", google_storage_bucket.bucket.name, var.objects_to_upload.bitnami-script.remote_path)
    "status-config-url"        = "https://runtimeconfig.googleapis.com/v1beta1/projects/jenkins-project-388812/configs/jenkins-config"
    "block-project-ssh-keys"   = "true"
    "ssh-keys"                 = <<SSH
mainhabbo:${chomp(tls_private_key.ssh_key.public_key_openssh)} mainhabbo@gmail.com
SSH
  }


  tags = [
    "jenkins-deployment",
  ]

  boot_disk {
    auto_delete = true
    device_name = "jenkins-packaged-by-vm-tmpl-boot-disk"
    mode        = "READ_WRITE"
    source      = "https://www.googleapis.com/compute/v1/projects/jenkins-project-388812/zones/us-central1-a/disks/jenkins-vm"

    initialize_params {
      image  = "https://www.googleapis.com/compute/v1/projects/bitnami-launchpad/global/images/bitnami-jenkins-2-387-3-0-r01-linux-debian-11-x86-64-nami"
      labels = {}
      size   = 10
      type   = "pd-standard"
    }
  }

  network_interface {
    network            = "https://www.googleapis.com/compute/v1/projects/jenkins-project-388812/global/networks/default"
    network_ip         = "10.128.0.3"
    queue_count        = 0
    stack_type         = "IPV4_ONLY"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/jenkins-project-388812/regions/us-central1/subnetworks/default"
    subnetwork_project = "jenkins-project-388812"

    access_config {
      nat_ip       = "35.224.190.233"
      network_tier = "PREMIUM"
    }
  }

  service_account {
    email = "1045040505707-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/cloudruntimeconfig",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  depends_on = [
    google_storage_bucket.bucket
  ]

  timeouts {}
}
