## Convención de nombres

Para mantener consistencia entre ambientes y facilitar la identificación de recursos, se utilizará la siguiente estructura:

```text
<project_name>-<environment>-<resource>
```

Donde:

- `project_name`: nombre del proyecto.
- `environment`: entorno (dev, qa, prod).
- `resource`: tipo de recurso AWS.

### Ejemplos

Kinesis Stream:

```text
data-platform-dev-kinesis
data-platform-qa-kinesis
data-platform-prod-kinesis
```

Aplicaciones Apache Flink:

```text
data-platform-dev-flink
data-platform-qa-flink
data-platform-prod-flink
```

Buckets S3:

```text
data-platform-dev-raw
data-platform-dev-processed

data-platform-prod-raw
data-platform-prod-processed
```

IAM Roles:

```text
data-platform-dev-role
data-platform-prod-role
```

### Beneficios

- Permite identificar rápidamente el proyecto al que pertenece un recurso.
- Facilita distinguir ambientes de desarrollo, pruebas y producción.
- Mantiene una nomenclatura consistente en toda la infraestructura.
- Simplifica tareas de monitoreo, auditoría y mantenimiento.