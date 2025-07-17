# React AWS Deployment Project 🚀

Este proyecto contiene una aplicación **React** desplegada en una instancia **EC2** de AWS, con infraestructura gestionada por **Terraform** y despliegues automáticos a través de **GitHub Actions**.

---

## 🏗️ Arquitectura

- **Frontend:** React (creado con Vite o Create React App)  
- **Backend/Infraestructura:** AWS EC2 para servir la app, S3 para almacenamiento estático (opcional)  
- **Infraestructura as Code:** Terraform para aprovisionar recursos AWS (EC2, S3, Security Groups, etc.)  
- **CI/CD:** GitHub Actions para construir, testear y desplegar automáticamente la app en EC2 vía SSH

---

## 🚀 Características principales

- Despliegue automatizado al hacer push en la rama protegida `main`  
- Seguridad reforzada con reglas de protección de ramas en GitHub  
- Servidor web Nginx configurado para servir archivos estáticos React  
- Gestión declarativa de infraestructura con Terraform  
- Clave SSH protegida y almacenada en GitHub Secrets para despliegue seguro  

---

## 🔧 Cómo usar este proyecto

### Pre-requisitos

- Cuenta de AWS con permisos para crear EC2, S3 y Security Groups  
- Terraform instalado localmente  
- Clave SSH configurada y subida como secreto (`EC2_SSH_PRIVATE_KEY`) en GitHub  
- Configurar branch protection rules en GitHub para la rama `main`  

### Pasos para levantar infraestructura

```bash
terraform init
terraform apply -auto-approve
