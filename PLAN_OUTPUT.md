
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)
 Nota: se redactó el ID de cuenta AWS para publicar esta evidencia. El resumen del plan no fue modificado.

Terraform will perform the following actions:

  # aws_s3_bucket.data_lake will be created
  + resource "aws_s3_bucket" "data_lake" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "datalake-[AWS_ACCOUNT_ID_REDACTED]-dev-coder-data"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "Name"        = "datalake-raw-dev"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "datalake-raw-dev"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket_public_access_block.security will be created
  + resource "aws_s3_bucket_public_access_block" "security" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.data_lake will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm     = "AES256"
                # (1 unchanged attribute hidden)
            }
        }
    }

  # aws_s3_bucket_versioning.data_lake will be created
  + resource "aws_s3_bucket_versioning" "data_lake" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

  # module.identity.data.aws_iam_policy_document.data_processing_s3_permissions will be read during apply
  # (config refers to values not yet known)
 <= data "aws_iam_policy_document" "data_processing_s3_permissions" {
      + id            = (known after apply)
      + json          = (known after apply)
      + minified_json = (known after apply)

      + statement {
          + actions   = [
              + "s3:GetObject",
              + "s3:PutObject",
            ]
          + effect    = "Allow"
          + resources = [
              + (known after apply),
            ]
        }
      + statement {
          + actions   = [
              + "s3:ListBucket",
            ]
          + effect    = "Allow"
          + resources = [
              + (known after apply),
            ]

          + condition {
              + test     = "StringLike"
              + values   = [
                  + "raw/",
                  + "raw/*",
                ]
              + variable = "s3:prefix"
            }
        }
    }

  # module.identity.aws_iam_policy.control_plane_audit_read_only will be created
  + resource "aws_iam_policy" "control_plane_audit_read_only" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Acciones expl├¡citas de lectura para auditor├¡a de infraestructura"
      + id               = (known after apply)
      + name             = "control-plane-audit-read-only-dev"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ListAllMyBuckets",
                          + "s3:GetEncryptionConfiguration",
                          + "s3:GetBucketVersioning",
                          + "s3:GetBucketPolicyStatus",
                          + "s3:GetBucketLocation",
                          + "iam:ListRoles",
                          + "iam:ListRolePolicies",
                          + "iam:ListPolicies",
                          + "iam:ListAttachedRolePolicies",
                          + "iam:GetRole",
                          + "iam:GetPolicyVersion",
                          + "iam:GetPolicy",
                          + "iam:GetAccountAuthorizationDetails",
                          + "ec2:DescribeVpcs",
                          + "ec2:DescribeVpcEndpoints",
                          + "ec2:DescribeSubnets",
                          + "ec2:DescribeRouteTables",
                          + "ec2:DescribeAvailabilityZones",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # module.identity.aws_iam_policy.data_processing_s3 will be created
  + resource "aws_iam_policy" "data_processing_s3" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Permite listar y leer/escribir objetos solo bajo el prefijo configurado"
      + id               = (known after apply)
      + name             = "data-processing-s3-policy-dev"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # module.identity.aws_iam_role.control_plane_audit will be created
  + resource "aws_iam_role" "control_plane_audit" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::[AWS_ACCOUNT_ID_REDACTED]:root"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "control-plane-audit-role-dev"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Environment" = "dev"
          + "Name"        = "control-plane-audit-role-dev"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "Name"        = "control-plane-audit-role-dev"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.identity.aws_iam_role.data_processing will be created
  + resource "aws_iam_role" "data_processing" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = [
                              + "lambda.amazonaws.com",
                              + "kinesisanalytics.amazonaws.com",
                            ]
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "data-processing-execution-role-dev"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Environment" = "dev"
          + "Name"        = "data-processing-execution-role-dev"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "Name"        = "data-processing-execution-role-dev"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.identity.aws_iam_role_policy_attachment.control_plane_audit_read_only will be created
  + resource "aws_iam_role_policy_attachment" "control_plane_audit_read_only" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "control-plane-audit-role-dev"
    }

  # module.identity.aws_iam_role_policy_attachment.data_processing_s3 will be created
  + resource "aws_iam_role_policy_attachment" "data_processing_s3" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "data-processing-execution-role-dev"
    }

  # module.network.aws_route_table.private_rt will be created
  + resource "aws_route_table" "private_rt" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "Name"        = "rt-data-private-dev"
        }
      + tags_all         = {
          + "Environment" = "dev"
          + "Name"        = "rt-data-private-dev"
        }
      + vpc_id           = (known after apply)
    }

  # module.network.aws_route_table_association.private_assoc[0] will be created
  + resource "aws_route_table_association" "private_assoc" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.aws_route_table_association.private_assoc[1] will be created
  + resource "aws_route_table_association" "private_assoc" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.aws_subnet.private_subnets[0] will be created
  + resource "aws_subnet" "private_subnets" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-2a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Environment" = "dev"
          + "Name"        = "subnet-data-private-1-dev"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "Name"        = "subnet-data-private-1-dev"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_subnet.private_subnets[1] will be created
  + resource "aws_subnet" "private_subnets" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-2b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Environment" = "dev"
          + "Name"        = "subnet-data-private-2-dev"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "Name"        = "subnet-data-private-2-dev"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_vpc.data_vpc will be created
  + resource "aws_vpc" "data_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Environment" = "dev"
          + "Name"        = "vpc-data-dev"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "Name"        = "vpc-data-dev"
        }
    }

  # module.network.aws_vpc_endpoint.s3_gateway will be created
  + resource "aws_vpc_endpoint" "s3_gateway" {
      + arn                   = (known after apply)
      + cidr_blocks           = (known after apply)
      + dns_entry             = (known after apply)
      + id                    = (known after apply)
      + ip_address_type       = (known after apply)
      + network_interface_ids = (known after apply)
      + owner_id              = (known after apply)
      + policy                = (known after apply)
      + prefix_list_id        = (known after apply)
      + private_dns_enabled   = (known after apply)
      + requester_managed     = (known after apply)
      + route_table_ids       = (known after apply)
      + security_group_ids    = (known after apply)
      + service_name          = "com.amazonaws.us-east-2.s3"
      + service_region        = (known after apply)
      + state                 = (known after apply)
      + subnet_ids            = (known after apply)
      + tags                  = {
          + "Environment" = "dev"
          + "Name"        = "vpce-s3-gateway-dev"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "Name"        = "vpce-s3-gateway-dev"
        }
      + vpc_endpoint_type     = "Gateway"
      + vpc_id                = (known after apply)

      + dns_options (known after apply)

      + subnet_configuration (known after apply)
    }

Plan: 17 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + control_plane_audit_role_arn = (known after apply)
  + data_lake_bucket_arn         = (known after apply)
  + data_processing_role_arn     = (known after apply)
  + private_subnet_ids           = [
      + (known after apply),
      + (known after apply),
    ]
  + s3_endpoint_id               = (known after apply)
  + vpc_id                       = (known after apply)
