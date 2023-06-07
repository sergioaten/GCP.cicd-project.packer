variable "objects_to_upload" {
  default = {
    bitnami-script = {
      remote_path = "scripts/bitnami-startup.sh"
      local_path  = "scripts/bitnami-startup.sh"
    }
  }
}

