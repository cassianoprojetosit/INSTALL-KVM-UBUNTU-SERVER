# 🖥️ Guia Profissional: Instalação do KVM + Criação de VM Ubuntu 24.04 com Cloud-Init

Autor: Cassiano Projetos IT

---

# 📌 Objetivo

Este documento descreve o processo profissional completo para:

* Instalar e configurar KVM no Ubuntu Server 24.04 LTS
* Configurar libvirt corretamente
* Criar pools de armazenamento
* Baixar Ubuntu Cloud Image oficial
* Criar VM utilizando cloud-init
* Provisionar automaticamente usuário e configurações

Ambiente validado e funcional.

---

# 1️⃣ Ambiente Base

Servidor:

* Ubuntu 24.04 LTS
* Acesso SSH ativo
* Internet funcional
* Virtualização habilitada na BIOS

Verificar suporte à virtualização:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

Se retornar número maior que 0, a virtualização está ativa.

---

# 2️⃣ Instalação do KVM e Ferramentas

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
bridge-utils virt-manager cloud-image-utils virtinst
```

Adicionar usuário ao grupo libvirt:

```bash
sudo usermod -aG libvirt $USER
```

Reiniciar sessão ou servidor.

Verificar se libvirt está ativo:

```bash
sudo systemctl status libvirtd
```

---

# 3️⃣ Ativar Rede NAT Padrão

Verificar redes:

```bash
virsh net-list --all
```

Se "default" não estiver ativa:

```bash
virsh net-start default
virsh net-autostart default
```

Rede NAT padrão utiliza a interface `virbr0`.

---

# 4️⃣ Criar Estrutura Profissional de Diretórios

```bash
mkdir -p /vms/isos
mkdir -p /vms/disks
mkdir -p /vms/autoinstall
```

Estrutura:

```
/vms
 ├── isos
 ├── disks
 └── autoinstall
```

---

# 5️⃣ Baixar Ubuntu 24.04 Cloud Image Oficial

```bash
cd /vms/isos
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

Verificar:

```bash
ls -lh
```

---

# 6️⃣ Criar Disco da VM

Copiar imagem base:

```bash
cp /vms/isos/noble-server-cloudimg-amd64.img \
/vms/disks/ubuntu2404-vm1.qcow2
```

Expandir disco para 30GB:

```bash
qemu-img resize /vms/disks/ubuntu2404-vm1.qcow2 30G
```

---

# 7️⃣ Criar Cloud-Init

Entrar na pasta:

```bash
cd /vms/autoinstall
```

## 7.1 Gerar Hash de Senha

```bash
openssl passwd -6
```

Copiar o hash completo gerado.

---

## 7.2 Criar user-data

```bash
nano user-data
```

Conteúdo:

```yaml
#cloud-config
hostname: ubuntu2404-vm1
users:
  - name: SEU_USUARIO
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    lock_passwd: false
    passwd: "COLE_AQUI_O_HASH_GERADO"
ssh_pwauth: true
disable_root: false
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
```

---

## 7.3 Criar meta-data

```bash
nano meta-data
```

Conteúdo:

```yaml
instance-id: ubuntu2404-vm1
local-hostname: ubuntu2404-vm1
```

---

## 7.4 Gerar seed.iso

```bash
cloud-localds seed.iso user-data meta-data
```

Verificar:

```bash
ls -lh
```

---

# 8️⃣ Garantir que a Rede Default está Ativa (Passo Obrigatório Antes da VM)

Antes de criar a VM, confirme que a rede NAT padrão do libvirt está ativa.

Verificar redes disponíveis:

```bash
virsh net-list --all
```

Se a rede "default" não estiver ativa, execute:

```bash
virsh net-start default
virsh net-autostart default
```

Isso garante que a interface `virbr0` esteja funcionando corretamente e evita erro durante o `virt-install`.

---

# 9️⃣ Criar VM com virt-install

Comando validado e funcional:

```bash
virt-install \
  --name ubuntu2404-vm1 \
  --memory 4096 \
  --vcpus 2 \
  --disk path=/vms/disks/ubuntu2404-vm1.qcow2,format=qcow2,bus=virtio \
  --disk path=/vms/autoinstall/seed.iso,device=cdrom \
  --os-variant ubuntu24.04 \
  --network network=default,model=virtio \
  --import \
  --graphics none
```

Observações:

* `--import` utiliza imagem pronta
* `--graphics none` conecta no console serial
* `--os-variant ubuntu24.04` obrigatório para performance correta

---

# 9️⃣ Verificar VM

Listar VMs:

```bash
virsh list --all
```

Ver IP:

```bash
virsh net-dhcp-leases default
```

Ou:

```bash
virsh domifaddr ubuntu2404-vm1
```

---

# 🔑 Acesso via SSH

```bash
ssh SEU_USUARIO@IP_DA_VM
```

Senha: a definida no hash.

---

# ✅ Resultado Final

Ambiente validado:

* KVM instalado
* libvirt ativo
* Rede NAT funcional
* Pool de discos estruturado
* Ubuntu 24.04 Cloud Image em uso
* Cloud-init aplicando configurações
* VM criada via import
* Acesso SSH funcional

---

# 🚀 Próximos Passos Profissionais

* Criar template base
* Clonagem rápida de VMs
* Migrar NAT para Bridge
* Criar mini ambiente estilo datacenter

---

📌 Documento validado em Ubuntu 24.04 LTS

---

**Cassiano Projetos IT**
Infraestrutura • Virtualização • Cloud • Linux

