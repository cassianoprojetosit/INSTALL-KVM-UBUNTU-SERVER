#!/bin/bash

clear
echo "==============================================="
echo "   INSTALADOR PROFISSIONAL KVM - Ubuntu Only"
echo "==============================================="
echo

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root: sudo ./install_kvm.sh"
  exit 1
fi

# Verificar sistema operacional
if ! grep -qi ubuntu /etc/os-release; then
  echo "❌ Sistema não suportado."
  echo "Este script é compatível apenas com Ubuntu."
  exit 1
fi

# Verificar virtualização
VIRT=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
if [ "$VIRT" -eq 0 ]; then
  echo "❌ Virtualização não habilitada na BIOS."
  exit 1
fi

echo "✅ Sistema Ubuntu detectado"
echo "✅ Virtualização suportada"
echo
read -p "Deseja continuar com a instalação do KVM? (s/n): " CONFIRM

if [[ "$CONFIRM" != "s" ]]; then
  echo "Instalação cancelada."
  exit 0
fi

echo
echo "Instalando pacotes..."

apt update
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
bridge-utils virtinst cloud-image-utils

echo
echo "Adicionando usuário ao grupo libvirt..."
usermod -aG libvirt $SUDO_USER

echo
echo "Ativando e iniciando libvirt..."
systemctl enable libvirtd
systemctl start libvirtd

echo
echo "Ativando rede default..."
virsh net-start default 2>/dev/null
virsh net-autostart default 2>/dev/null

echo
echo "==============================================="
echo "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO"
echo "Reinicie o servidor para aplicar permissões."
echo "==============================================="
