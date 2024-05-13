# resource "azurerm_resource_group" "maaz_rg" {
#   name     = "sa1_test_eic_MaazPatel"
#   location = "Southeast Asia"
# }

# Use this data source to access information about an existing Resource Group.
data "azurerm_resource_group" "maaz_rg" {
  name = var.resource_group_name
  #   location = var.resource_group_location
}

data "azurerm_ssh_public_key" "maaz_pubic_key" {
  name                = "maaz_id_rsa"
  resource_group_name = var.resource_group_name
}


# output "id" {
#   value = data.azurerm_resource_group.maaz_rg.id
# }

# Creating Virtual Network
resource "azurerm_virtual_network" "example_vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name
}

# Creating Subnet
resource "azurerm_subnet" "example_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.maaz_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "example_public_ip" {
  name                = var.public_ip_name
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
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
resource "azurerm_network_interface" "example_nic" {
  name                = var.network_interface_name
  location            = data.azurerm_resource_group.maaz_rg.location
  resource_group_name = data.azurerm_resource_group.maaz_rg.name

  ip_configuration {
    name                          = "my_nic_internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example_public_ip.id
  }
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "example_linux_vm" {
  name                = "testingExample-vm"
  resource_group_name = data.azurerm_resource_group.maaz_rg.name
  location            = data.azurerm_resource_group.maaz_rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.example_nic.id,
  ]

  admin_ssh_key {
    username = var.username
    # public_key = file("../.ssh/id_rsa.pub") # location of my ssh-pubilic key.
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

  tags = {
    Resource_Owner : "Maaz"
    Delivery_Manager : "Shriram Deshpande"
    Sub_Business_Unit : "PES-IA"
    Business_Unit : "einfochips"
    Project_Name : "Training and learning"
    Create_Date : "01 May 2024"
  }
}

resource "local_file" "foo" {
  content  = "[webserver]\n${var.username}@${azurerm_linux_virtual_machine.example_linux_vm.public_ip_address} ansible_ssh_private_key_file=../maaz_id_rsa.pem"
  filename = abspath("../wordpress-auto-config/inventory.ini")
}

# resource "null_resource" "example_null" {
#   provisioner "local-exec" {
#     command = "echo '[webserver]' > ../wordpress-auto-config/inventory.ini \necho '${var.username}@${azurerm_linux_virtual_machine.example_linux_vm.public_ip_address} ansible_ssh_private_key_file=../maaz_id_rsa.pem' >> ../wordpress-auto-config/inventory.ini"
#   }

#   triggers = {
#     always_run = timestamp()
#   }
# }
