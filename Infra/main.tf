# Use this data source to access information about an existing Resource Group.
data "azurerm_resource_group" "maaz_rg" {
  name = var.resource_group_name
}

data "azurerm_ssh_public_key" "maaz_pubic_key" {
  name                = "terrakube"
  resource_group_name = var.resource_group_name
}

locals {
  tags = {
    Resource_Owner    = "Maaz Patel",
    Delivery_Manager  = "Shahid Raza",
    Sub_Business_Unit = "PES-IA",
    Business_Unit     = "einfochips",
    Project_Name      = "Training and Learning",
    Environment       = var.env,
    Create_Date       = "02 Jan 2025"
  }
}

# Creating Virtual Network
resource "azurerm_virtual_network" "terrakube_vnet" {
  name                = "${var.env}-${var.prefix}-vnet"
  address_space       = var.subnet_range
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name
}

# Creating Subnet
resource "azurerm_subnet" "terrakube_subnet" {
  name                 = "${var.env}-${var.prefix}-vm-subnet"
  resource_group_name  = data.azurerm_resource_group.maaz_rg.name
  virtual_network_name = azurerm_virtual_network.terrakube_vnet.name
  address_prefixes     = var.subnet_range
}

# Create public IPs
resource "azurerm_public_ip" "terrakube_public_ip" {
  name                = "${var.env}-${var.prefix}-public-ip"
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terrakube_nsg" {
  name                = "${var.env}${var.prefix}NetworkSecurityGroup"
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Creating Network interface
resource "azurerm_network_interface" "terrakube_nic" {
  name                = var.network_interface_name
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name

  ip_configuration {
    name                          = "my_nic_internal"
    subnet_id                     = azurerm_subnet.terrakube_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terrakube_public_ip.id
  }
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "terrakube_linux_vm" {
  name                = "${var.env}-${var.prefix}-Linux-vm"
  resource_group_name = data.azurerm_resource_group.maaz_rg.name
  location            = data.azurerm_resource_group.maaz_rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.vm_username
  network_interface_ids = [
    azurerm_network_interface.terrakube_nic.id,
  ]

  admin_ssh_key {
    username   = var.vm_username
    public_key = data.azurerm_ssh_public_key.maaz_pubic_key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = local.tags
}

# Create Local Inventory File
resource "local_file" "inventory" {
  content  = <<-EOT
  [webserver]
  ${var.vm_username}@${azurerm_linux_virtual_machine.terrakube_linux_vm.public_ip_address} ansible_ssh_private_key_file=../maaz_id_rsa.pem
  EOT
  filename = abspath("../wordpress-auto-config/inventory.ini")
}
