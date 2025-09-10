# STS2S3 - GCS to S3 Transfer with AWS DataSync

A Terraform module for setting up Google Cloud Storage (GCS) to Amazon S3 data transfer using AWS DataSync in enhanced mode (no agent required).

## Overview

This project creates:
- A Google Cloud Storage bucket (source)
- An Amazon S3 bucket (destination)
- AWS DataSync task for transferring data from GCS to S3
- Required IAM roles and policies
- Manual trigger setup (no automatic scheduling)

## Architecture

```
┌─────────────────┐    AWS DataSync    ┌─────────────────┐
│   GCS Bucket    │ ─────────────────► │   S3 Bucket     │
│   (Source)      │    Enhanced Mode   │ (Destination)   │
└─────────────────┘                    └─────────────────┘
```

## References

* [Choosing a task mode for your data transfer](https://docs.aws.amazon.com/datasync/latest/userguide/choosing-task-mode.html)
* [AWS DataSync pricing](https://aws.amazon.com/datasync/pricing/)
* [Configuring AWS DataSync transfers with Google Cloud Storage](https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_transfer-google-cloud-storage.html)
* [Transfer Google Cloud Storage to Amazon S3 using AWS DataSync Enhanced Mode | Amazon Web Services](https://www.youtube.com/watch?v=lxXGhROqkaQ)

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Google Cloud Project** with GCS API enabled
3. **Terraform** >= 1.0
4. **AWS CLI** configured
5. **Google Cloud SDK** (gcloud) configured
6. **GCS Interoperability Keys** (for DataSync access)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/nikolaybotev/sts2s3.git
cd sts2s3
```

### 2. Configure GCS Interoperability

To use AWS DataSync with GCS, you need to create interoperability keys:

```bash
# Create interoperability keys for your GCS service account
gsutil hmac create <service-account-email>
```

This will provide you with:
- Access Key ID
- Secret Access Key

### 3. Configure Terraform Variables

Copy the example file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Project Configuration
project_name = "my-transfer-project"
environment  = "dev"

# AWS Configuration
aws_region = "us-east-1"

# GCP Configuration
gcp_project_id = "your-gcp-project-id"
gcp_region     = "us-east4"

# DataSync Configuration
gcs_access_key_id     = "your-gcs-access-key-id"
gcs_secret_access_key = "your-gcs-secret-access-key"

# Transfer Options
datasync_verify_mode              = "POINT_IN_TIME_CONSISTENT"
datasync_overwrite_mode           = "NEVER"
datasync_preserve_deleted_files   = "PRESERVE"
datasync_bandwidth_limit          = 0
datasync_log_level               = "BASIC"
```

### 4. Initialize and Apply Terraform

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Usage

### Manual Transfer Execution

The DataSync task is created without a schedule and must be triggered manually:

```bash
# Get the task ARN from Terraform outputs
TASK_ARN=$(terraform output -raw datasync_task_arn)

# Start the transfer
aws datasync start-task-execution --task-arn $TASK_ARN
```

### Monitor Transfer Progress

```bash
# List task executions
aws datasync list-task-executions --task-arn $TASK_ARN

# Get execution details
EXECUTION_ARN=$(aws datasync list-task-executions --task-arn $TASK_ARN --query 'TaskExecutions[0].TaskExecutionArn' --output text)
aws datasync describe-task-execution --task-execution-arn $EXECUTION_ARN
```

## Configuration Options

### DataSync Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `datasync_verify_mode` | Verification mode for transferred data | `POINT_IN_TIME_CONSISTENT` |
| `datasync_overwrite_mode` | How to handle existing files | `NEVER` |
| `datasync_preserve_deleted_files` | Keep files deleted from source | `PRESERVE` |
| `datasync_bandwidth_limit` | Transfer rate limit (0 = unlimited) | `0` |
| `datasync_log_level` | Logging detail level | `BASIC` |

### Available Options

**Verify Mode:**
- `POINT_IN_TIME_CONSISTENT` - Verify data integrity
- `ONLY_FILES_TRANSFERRED` - Verify only transferred files
- `NONE` - No verification

**Overwrite Mode:**
- `ALWAYS` - Always overwrite existing files
- `NEVER` - Never overwrite existing files

**Preserve Deleted Files:**
- `PRESERVE` - Keep files that don't exist in source
- `REMOVE` - Delete files that don't exist in source

**Log Level:**
- `OFF` - No logging
- `BASIC` - Basic logging
- `TRANSFER` - Detailed transfer logging

## Outputs

The module provides these outputs:

- `gcs_bucket_name` - Name of the source GCS bucket
- `gcs_bucket_url` - URL of the source GCS bucket
- `s3_bucket_name` - Name of the destination S3 bucket
- `s3_bucket_arn` - ARN of the destination S3 bucket
- `datasync_task_arn` - ARN of the DataSync task
- `datasync_task_name` - Name of the DataSync task

## File Structure

```
.
├── README.md                     # This file
├── provider.tf                   # Provider configurations
├── variables.tf                  # Input variables
├── outputs.tf                    # Output values
├── gcp_gcs_bucket.tf            # GCS bucket resources
├── aws_s3_bucket.tf             # S3 bucket resources
├── aws_datasync.tf              # DataSync resources
├── backend.tf                   # Terraform backend config
├── terraform.tfvars.example     # Example variables file
└── .vscode/settings.json        # VS Code settings
```

## Limitations

1. **GCS to S3 Direction Only**: This setup transfers FROM GCS TO S3
2. **No Object Tags**: GCS doesn't support object tags, so `object_tags` is set to `NONE`
3. **Manual Execution**: No automatic scheduling - transfers must be triggered manually
4. **Enhanced Mode Only**: Uses DataSync enhanced mode (no agent required)

## Troubleshooting

### Common Issues

1. **GCS Access Denied**
   - Verify your GCS interoperability keys are correct
   - Ensure the service account has Storage Object Viewer permissions

2. **S3 Access Denied**
   - Check AWS credentials and permissions
   - Verify the DataSync IAM role has proper S3 permissions

3. **Task Execution Fails**
   - Check DataSync task logs in CloudWatch
   - Verify both source and destination locations are accessible

### Useful Commands

```bash
# Check DataSync task status
aws datasync describe-task --task-arn $TASK_ARN

# List all task executions
aws datasync list-task-executions --task-arn $TASK_ARN

# Get CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix /aws/datasync
```

## Cost Considerations

- **AWS DataSync**: Charged per GB transferred
- **Cross-Cloud Transfer**: Data egress charges from GCS
- **S3 Storage**: Standard S3 storage costs
- **GCS Storage**: Standard GCS storage costs

## Security

- GCS credentials are marked as sensitive in Terraform
- AWS credentials use IAM roles with least privilege
- All resources are tagged for easy identification
- S3 bucket has versioning enabled for data protection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
