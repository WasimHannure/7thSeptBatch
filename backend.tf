terraform {
  backend "azurerm" {
    resource_group_name  = "manual-rg"
    storage_account_name = "mybackendtfstorage"
    container_name       = "backend"
    key                  = "terraform.tfstate"
  }
}
