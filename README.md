# ACME – Plataforma EKS Multi‑Región (Demo)

Esta demo despliega **dos clústeres EKS** (región primaria/secundaria) con una app NGINX
expuesta mediante **NLB** en cada región y **balanceo global** con **AWS Global Accelerator (GA)**.
Incluye IaC con **Terraform**, manifiestos de Kubernetes y **GitHub Actions**.
Pensado para ser **simple y económico**.

## Requisitos previos
- AWS CLI y `kubectl` instalados
- Terraform >= 1.6
- GitHub repo con OIDC configurado (rol en AWS)
- Permisos en AWS para EKS/VPC/GA/IAM

## Regiones por defecto
- Primaria: `us-east-1`
- Secundaria: `us-west-2`

Puedes cambiarlas en `terraform/envs/demo/variables.tf`.

## Pasos rápidos
1. `terraform init && terraform apply` dentro de `terraform/envs/demo/`
2. Ejecuta el workflow **app** para desplegar NGINX en ambos clústeres.
3. Obtén el **DNS** de GA y prueba:
   ```bash
   bash scripts/smoke.sh
   ```
4. Simula failover:
   ```bash
   bash scripts/fail_primary.sh
   bash scripts/smoke.sh
   ```

> Nota: Usamos **NLB** (no ALB) para evitar instalar el AWS Load Balancer Controller.
> El nombre del NLB se define en el Service con la anotación
> `service.beta.kubernetes.io/aws-load-balancer-name` para que Terraform pueda referenciarlo y
> conectarlo a Global Accelerator.
