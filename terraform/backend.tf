terraform {
  backend "local" {
    path = "/opt/terraform-state/provisioning-lab/terraform.tfstate"
  }
}