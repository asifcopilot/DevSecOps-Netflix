# create azure vm for jenkins with public ip
# install jenkins on azure vm
# install docker on azure vm
# install kubectl on azure vm
# install helm on azure vm
# create aks cluster 
# without any terraform modules


resource "azurerm_virtual_network" "az-vn" {
  name                = "${var.prefix}-network"
  address_space       = var.virtualnetwork
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
    tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "az-subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.az-vn.name
  address_prefixes     = var.subnet
    
}


resource "azurerm_public_ip" "publicIP" {
  name                = "${var.prefix}-pubIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
    tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ip_configuration1"
    subnet_id                     = azurerm_subnet.az-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP.id
  }
    tags = {
    environment = var.environment
  }
}

resource "azurerm_network_security_group" "network-sg" {
  name                = "${var.prefix}-sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "jenkins"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "sonarqube"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


    tags = {
    environment = var.environment
  }
}


resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.network-sg.id
}


resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = var.vm_size
  admin_username        = var.prefix
  admin_password        = var.admin-password
  computer_name         = var.prefix
  boot_diagnostics {
    # enabled = "true"
    # storage_uri = "${azurerm_storage_account.diagstorage2.primary_blob_endpoint}"
}

  source_image_reference  {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  # custom_data = filebase64("startup.sh.base64") # base64 -w 0 startup.sh > startup.sh.base64

connection {
    type        = "ssh"
    user        = var.prefix
    password    = var.admin-password
    host        = self.public_ip_address
  }

provisioner "file" {
  source      = "startup.sh"
  destination = "/tmp/startup.sh"

}

provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/startup.sh",
    "/tmp/startup.sh"
  ]

}

  disable_password_authentication = false

  tags = {
    environment = var.environment
  }
  
}



output "vm-publicip" {
  value = azurerm_public_ip.publicIP.ip_address

}

output "Jenkins-url" {
  value = "http://${azurerm_public_ip.publicIP.ip_address}:8080/"
}
