#!/bin/bash

clear
echo "==============================================="
echo "      CRIADOR PROFISSIONAL DE VM KVM"
echo "==============================================="
echo

# Verificar root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root: sudo ./create_vm.sh"
  exit 1
fi

# Inputs do usuário
read -p "Nome da VM: " VM_NAME
read -p "Memória em MB (ex: 4096): " VM_RAM
read -p "Número de vCPUs: " VM_CPU
read -p "Tamanho do disco em GB (ex: 30): " VM_DISK
read -p "Nome do usuário da VM: " VM_USER

echo
echo "----------------------------------------------"
echo "Para gerar a senha com hash execute em outro terminal:"
echo "openssl passwd -6"
echo "Cole o HASH completo abaixo:"
echo "----------------------------------------------"
echo

read -p "Cole o HASH da senha: " VM_PASS_HASH

# Criar diretórios se não existirem
mkdir -p /vms/isos
mkdir -p /vms/disks
mkdir -p /vms/autoinstall

cd /vms/isos

# Baixar imagem se não existir
if [ ! -f noble-server-cloudimg-amd64.img ]; then
  echo "Baixando Ubuntu 24.04 Cloud Image..."
  wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
fi

# Criar disco
cp noble-server-cloudimg-amd64.img /vms/disks/${VM_NAME}.qcow2
qemu-img resize /vms/disks/${VM_NAME}.qcow2 ${VM_DISK}G

# Criar cloud-init
cd /vms/autoinstall

cat > user-data <<EOF
#cloud-config
hostname: ${VM_NAME}
users:
  - name: ${VM_USER}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    lock_passwd: false
    passwd: "${VM_PASS_HASH}"
ssh_pwauth: true
disable_root: false
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF

cat > meta-data <<EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

cloud-localds seed.iso user-data meta-data

# Garantir rede ativa
virsh net-start default 2>/dev/null
virsh net-autostart default 2>/dev/null

# Criar VM
virt-install \
  --name ${VM_NAME} \
  --memory ${VM_RAM} \
  --vcpus ${VM_CPU} \
  --disk path=/vms/disks/${VM_NAME}.qcow2,format=qcow2,bus=virtio \
  --disk path=/vms/autoinstall/seed.iso,device=cdrom \
  --os-variant ubuntu24.04 \
  --network network=default,model=virtio \
  --import \
  --graphics none

echo
echo "==============================================="
echo "✅ VM ${VM_NAME} criada com sucesso!"
echo "Use: virsh domifaddr ${VM_NAME}"
echo "Para descobrir o IP."
echo "==============================================="
