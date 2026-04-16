# AWS Hotel Infrastructure Migration Lab (Terraform)

## 📌 Project Overview
This project simulates migrating a hotel’s on-premises infrastructure to AWS using Terraform. The environment includes a cloud-based network connected to a simulated on-prem network using VPC peering, allowing secure communication between systems.

---

## 🏗 Architecture

This environment consists of two networks:

### 🔹 AWS Cloud (Lab VPC)
- VPC: 10.0.0.0/16
- Private Subnet: 10.0.1.0/24
- EC2 Instances:
  - Printer Server
  - Keycard Server
  - Music Server

### 🔹 Simulated On-Prem Network
- VPC: 192.168.0.0/16
- Public Subnet: 192.168.1.0/24
- EC2 Instance:
  - Hotel Client (acts as on-prem workstation)

---

## 🔗 Connectivity

- VPC Peering connects the Lab VPC and On-Prem VPC
- Route tables allow traffic between both networks
- Internet Gateway allows the On-Prem VPC to access the internet
- Hotel Client can SSH into internal AWS servers

---

## 🔐 Security Configuration

### Lab Security Group
- Allows SSH (port 22) from On-Prem network
- Allows ICMP (ping) from On-Prem network
- Allows all outbound traffic

### On-Prem Security Group
- Allows SSH only from your personal IP
- Allows ICMP from your laptop
- Allows full access to Lab VPC
- Allows all outbound traffic

---

## ⚙️ Infrastructure Components

- VPCs (Lab + On-Prem)
- Subnets (Private + Public)
- Internet Gateway
- VPC Peering Connection
- Route Tables & Associations
- Security Groups
- EC2 Instances (4 total)

---

## 🛠 Tools & Technologies
- AWS
- Terraform
- VS Code
- Git & GitHub

---
