# Main infrastructure resources for the future data platform.

locals {
  resource_prefix = "${var.project_name}-${var.environment}"
}

# Planned resources:
#
# - Amazon Kinesis Data Streams:
#   Used to ingest streaming data in real time.
#
# - Amazon Managed Service for Apache Flink:
#   Used to process streaming events from Kinesis.
#
# - Amazon S3:
#   Used as a storage layer for processed data.
#
# Additional resources will be added as the platform evolves.