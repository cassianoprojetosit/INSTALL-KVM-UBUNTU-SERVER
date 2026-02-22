# 🖥️ Automação KVM: Instalação + Provisionamento Cloud-Init (Ubuntu 24.04)

<div align="center"> 
    <img src="https://img.shields.io/badge/KVM-Hypervisor-red?style=for-the-badge&logo=linux" alt="KVM"> 
    <img src="https://img.shields.io/badge/Ubuntu_Server-24.04_LTS-orange?style=for-the-badge&logo=ubuntu" alt="Ubuntu 24.04"> 
    <img src="https://img.shields.io/badge/Cloud--Init-Automated-blue?style=for-the-badge&logo=canonical" alt="Cloud-Init"> 
    <img src="https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge" alt="Status"> 
</div>

---

### 📝 Descrição
Este projeto oferece uma solução de **automação completa** para transformar um servidor Ubuntu 24.04 em um host de virtualização de alta performance. Através de scripts Bash inteligentes, o sistema realiza desde a instalação do **KVM/QEMU** até o provisionamento dinâmico de Máquinas Virtuais utilizando **Cloud-Init** e imagens oficiais da Canonical.

---

## 📋 Índice
1. [📌 Visão Geral](#-visão-geral)
2. [🧠 Arquitetura da Solução](#-arquitetura-da-solução)
3. [🥇 Parte 1: Instalação do Ambiente (KVM)](#-parte-1--instalação-do-ambiente-kvm)
4. [🥈 Parte 2: Criação da VM (Cloud-Init)](#-parte-2--criação-da-vm-ubuntu-2404)
5. [🔐 Segurança e Criptografia](#-como-gerar-o-hash-da-senha)
6. [🚀 Operação e Conectividade](#-descobrir-o-ip-da-vm)
7. [⚠️ Boas Práticas e Requisitos](#-pré-requisitos)
8. [🎯 Resultado Final](#-resultado-final)

---

## 📌 Visão Geral
O fluxo de trabalho foi desenhado para ser modular e escalável, dividido em duas etapas fundamentais:
1.  **`install_kvm.sh`**: Prepara o "esqueleto" do servidor, instalando drivers, daemons e configurando a rede virtual.
2.  **`create_vm.sh`**: O "músculo" da automação, que baixa imagens, configura o Cloud-Init (user-data) e sobe a VM em segundos.

---

## 🧠 Arquitetura da Solução
Abaixo, o fluxo de provisionamento automatizado:

```mermaid
graph LR
    A[Host Ubuntu 24.04] --> B[KVM/Libvirt Engine]
    B --> C[Network: Default NAT virbr0]
    C --> D[Storage: /vms/disks]
    D --> E[VM: Ubuntu 24.04 Cloud-Image]
    E --> F[Provisioning: Cloud-Init seed.iso]
```

---

## 🥇 PARTE 1 — Instalação do Ambiente KVM
### 📄 Script: `install_kvm.sh`
Este script realiza a preparação "bare metal" do servidor.

| Recurso | Ação Realizada |
| :--- | :--- |
| **Validação** | Verifica suporte a VT-x (Intel) ou AMD-V. |
| **Core** | Instala `qemu-kvm`, `libvirt-daemon-system` e `virtinst`. |
| **Rede** | Ativa a rede `default` (NAT) e a interface `virbr0`. |
| **Permissões** | Adiciona o usuário atual aos grupos `libvirt` e `kvm`. |

#### ▶️ Execução:
```bash
chmod +x install_kvm.sh
sudo ./install_kvm.sh
# Importante: Reinicie após a conclusão
sudo reboot
```

---

## 🥈 PARTE 2 — Criação da VM Ubuntu 24.04
### 📄 Script: `create_vm.sh`
Provisionamento inteligente baseado em imagens de nuvem (Cloud Images).

**Funcionalidades Principais:**
- **Customização Dinâmica:** Solicita Nome, RAM, vCPUs e Disco via CLI.
- **Cloud-Init:** Gera automaticamente os arquivos `user-data` e `meta-data`.
- **Idempotência:** Verifica se a imagem ISO já existe antes de baixar (economiza banda).
- **Auto-Console:** Conecta ao console serial imediatamente após o boot.

#### 🔐 Gerando o Hash da Senha (Obrigatório)
O Cloud-Init exige senhas criptografadas em **SHA-512**. Gere o hash antes de rodar o script:
```bash
openssl passwd -6
# Copie o hash gerado para colar no script quando solicitado.
```

#### ▶️ Execução:
```bash
chmod +x create_vm.sh
sudo ./create_vm.sh
```

---

## 🚀 Operação e Conectividade
Após a criação da VM, utilize os comandos abaixo para gestão:

### 🌐 Descobrir o IP da VM
```bash
# Método 1 (Direto pela interface)
virsh domifaddr NOME_DA_VM

# Método 2 (Leases do DHCP)
virsh net-dhcp-leases default
```

### 🔑 Conexão SSH
```bash
ssh seu_usuario@IP_DA_VM
```

---

## ⚠️ Pré-requisitos
- **Hardware:** Virtualização habilitada na BIOS (Intel VT-x ou AMD-V).
- **OS:** Ubuntu Server 20.04 ou superior (Otimizado para 24.04).
- **Acesso:** Privilégios de `sudo` ou `root`.
- **Espaço:** Pelo menos 20GB livres em `/` para o diretório `/vms`.

---

## 🎯 Resultado Final
Ao utilizar este conjunto de automação, você garante:
- **Padronização:** Todas as VMs seguem a mesma estrutura de diretórios e segurança.
- **Velocidade:** Criação de servidores prontos para uso em menos de 2 minutos.
- **Escalabilidade:** Base sólida para ambientes de teste, lab ou produção leve.
- **Modernidade:** Uso de Cloud-Init, eliminando a necessidade de instalações manuais via ISO interativa.

---
> **Autor:** Cassiano Projetos IT  
> **Documento:** README.md  
> **Versão:** 1.0.0  
> **Data:** 13 de Fevereiro de 2026
