# Infraestructura base de Data Engineering

Este repositorio define la infraestructura inicial de AWS con Terraform:

- Una VPC con dos subredes privadas en Availability Zones distintas y sin rutas a Internet.
- Un S3 Gateway Endpoint asociado a la tabla de rutas privada para acceder a S3 sin NAT Gateway.
- Un bucket de Data Lake cuyo nombre incluye el ID de la cuenta, con bloqueo de acceso público, cifrado SSE-S3 y versionado.
- Un rol de procesamiento asumible por Lambda o Managed Service for Apache Flink, limitado a listar y leer/escribir objetos bajo `raw/`.
- Un rol del plano de control con acciones explícitas de solo lectura para auditoría.
- Un backend remoto S3 cifrado y locking con DynamoDB.

## Estructura

```text
modules/
  network/       VPC, subredes, tablas de rutas y endpoint S3
  identity/      Roles y políticas IAM
environments/
  dev/           Configuración del entorno, backend, variables y outputs
```

## Prerrequisitos

- Terraform `>= 1.5.0`.
- AWS CLI configurado con credenciales para crear los recursos indicados y consultar la identidad de la cuenta.
- Una cuenta AWS y una región con al menos dos Availability Zones disponibles.

El backend S3 debe existir **antes** de ejecutar `terraform init`. El bucket configurado en `environments/dev/backend.tf` debe ser globalmente único. Si cambiás su nombre o región, actualizá también los comandos de bootstrap y el archivo de backend.

## Bootstrap del backend (una sola vez)

Los siguientes comandos usan PowerShell y la región `us-east-2` configurada en este ejemplo. Ejecutalos con una identidad de AWS autorizada para crear y administrar estos recursos:

```powershell
$env:AWS_PROFILE = "dev"
$Bucket = "tfstate-datalake-dev-coder"
$Region = "us-east-2"
$Table = "terraform-locks-dev"

aws sso login --profile dev
aws sts get-caller-identity --profile dev
aws s3api create-bucket --bucket $Bucket --region $Region --create-bucket-configuration LocationConstraint=$Region --profile dev
aws s3api put-public-access-block --bucket $Bucket --region $Region --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true --profile dev
aws s3api put-bucket-versioning --bucket $Bucket --region $Region --versioning-configuration Status=Enabled --profile dev
aws s3api put-bucket-encryption --bucket $Bucket --region $Region --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' --profile dev
aws dynamodb create-table --table-name $Table --region $Region --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --sse-specification Enabled=true --profile dev
aws dynamodb wait table-exists --table-name $Table --region $Region --profile dev
```

El nombre del bucket S3 debe ser único en todo AWS. Si el comando `create-bucket` informa que ya existe o pertenece a otra cuenta, elegí otro nombre y actualizá `backend.tf`. No elimines el bucket ni la tabla mientras haya estados Terraform que dependan de ellos.

## Inicializar y validar

Desde la raíz del repositorio:

```powershell
$env:AWS_PROFILE = "dev"
aws sso login --profile dev
terraform -chdir=environments/dev init
terraform fmt -check -recursive
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev plan -out=tfplan
```

Para aplicar después de revisar el plan:

```powershell
terraform -chdir=environments/dev apply tfplan
```

También podés copiar `environments/dev/terraform.tfvars.example` como `environments/dev/terraform.tfvars` y ajustar los valores para tu cuenta/región. Los archivos `.tfvars` con valores locales no se suben al repositorio.

## Roles IAM y alcance

- `data_processing_role_arn`: rol asumible por Lambda y Managed Service for Apache Flink. Puede ejecutar `s3:ListBucket` solo con el prefijo `raw/`, y `s3:GetObject`/`s3:PutObject` sobre objetos dentro de ese prefijo. Si otro servicio lo va a asumir, agregá su principal de servicio a la trust policy y revisá sus permisos específicos.
- `control_plane_audit_role_arn`: rol de auditoría. Su trust policy permite la asunción desde la cuenta AWS donde se despliega; el principal que lo asuma también necesita permiso `sts:AssumeRole`. La política enumera acciones de lectura y no permite cambios. Algunas APIs de lectura de AWS no admiten limitar el recurso y por eso requieren `Resource = "*"`, pero no hay acciones IAM comodín.

Los outputs de red incluyen `vpc_id`, `private_subnet_ids` y `s3_endpoint_id`. Los outputs del entorno exponen los ARN necesarios para integrar estos recursos en entregas posteriores.

## Evidencia del plan

`PLAN_OUTPUT.md` contiene el procedimiento para guardar evidencia. El plan debe generarse con el backend inicializado y credenciales válidas; no se incluye un resultado simulado.

## Higiene del repositorio

El `.gitignore` excluye el directorio local `.terraform/`, los estados y los archivos `.tfvars`. El archivo `.terraform.lock.hcl` se versiona para mantener fijadas las versiones exactas de los proveedores.
