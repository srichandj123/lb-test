terraform {
  required_version = "~> 1.7"
  cloud {
    organization = "jakka"
    workspaces {
      name = "lb-test-wkspc"
    }
  }
}


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false # This is to handle MCAPS or other policy driven resource creation.
    }
  }
}
