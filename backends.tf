terraform {
  backend "remote" {
    organization = "inft01"

    workspaces {
      name = "terransible"
    }
  }
}