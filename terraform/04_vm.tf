
resource "azurerm_linux_virtual_machine" "cicd_vm" {
  name                = "cicd-vm"
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = "Standard_F2"
  admin_username      = var.vm_username
  #disable_password_authentication = false
  identity {type = "SystemAssigned"}
  network_interface_ids = [
    azurerm_network_interface.cicd_vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.vm_username
    public_key = "${file("${var.public_key_path}")}"

  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/adminuser/roles"
    ]

    connection {
      type        = "ssh"
      user        = "adminuser"
      private_key = "${file("${var.private_key_path}")}"
      host        = self.public_ip_address
    }
  }

  provisioner "file" {
    source      = "dirs_to_upload/"
    destination = "/home/adminuser/"
 
    connection {
     user         = "adminuser"
     type         = "ssh"
     private_key = "${file("${var.private_key_path}")}"
     host         = self.public_ip_address
     }
  }

  provisioner "remote-exec" {
    inline = [
      "mv /home/adminuser/roles/Jenkins_Jobs /home/adminuser/Jenkins_Jobs",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "ansible-playbook /home/adminuser/roles/pkg_installs/install-pkgs.yml",
      "sudo usermod -aG docker adminuser",
      "sudo usermod -aG docker jenkins",
      "ansible-playbook /home/adminuser/roles/create_jenkins_jobs/create-jenkins-jobs.yml",
      "sudo systemctl restart jenkins",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      "kubectl_latest_ver=$(curl -L -s https://dl.k8s.io/release/stable.txt)",
      "curl -LO https://dl.k8s.io/release/$kubectl_latest_ver/bin/linux/amd64/kubectl",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
      "sudo mv /home/adminuser/k8s_deployment.yaml /var/lib/jenkins/k8s_deployment.yaml",
      "sudo chown jenkins:jenkins /var/lib/jenkins/k8s_deployment.yaml"
    ]
    connection {
     user        = "adminuser"
     private_key = "${file("${var.private_key_path}")}"
     type     = "ssh"
     host     = self.public_ip_address
     }
  } 


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }


}

resource "azurerm_role_assignment" "aks_cluster_user_role" {
  principal_id         = azurerm_linux_virtual_machine.cicd_vm.identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_kubernetes_cluster.aks_web.id
}
