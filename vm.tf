############################################################
# Windows 11 Virtual Machine with Bastion Access
############################################################

# Public IP for VM
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-vm-win11"
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Network Interface for VM in snet_app
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-vm-win11"
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnets["snet-app"].resource_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# Windows 11 Virtual Machine
resource "azurerm_windows_virtual_machine" "win11_vm" {
  name                = var.vm_name
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_os_disk_type
    disk_size_gb         = var.vm_os_disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }

  # Optional: Enable boot diagnostics
  boot_diagnostics {
    storage_account_uri = null # Uses managed storage account
  }
}

############################################################
# Azure Bastion for Secure RDP Access
############################################################

# Dedicated subnet for Azure Bastion (must be named AzureBastionSubnet)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

# Public IP for Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion"
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  sku                 = var.bastion_sku
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

############################################################
# Outputs
############################################################

output "vm_id" {
  description = "ID of the Windows 11 VM"
  value       = azurerm_windows_virtual_machine.win11_vm.id
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "bastion_fqdn" {
  description = "FQDN of the Azure Bastion"
  value       = azurerm_bastion_host.bastion.dns_name
}
