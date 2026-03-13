# Common Aliyun CLI Scenarios

Quick reference for common cloud operations using the plugin-based Aliyun CLI.

## Scenario 1: Instance Management

### List and Filter Instances

```bash
# List all instances in a region
aliyun ecs describe-instances --biz-region-id cn-hangzhou

# Filter by status
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --status Running

# Filter by tags
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --tag key=env value=prod

# Custom output columns
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --output cols=InstanceId,InstanceName,Status,PublicIpAddress rows="Instances.Instance[]"
```

### Batch Operations

```bash
# Start multiple instances
aliyun ecs start-instances \
  --instance-ids i-abc123 i-def456 i-ghi789

# Stop instances gracefully
aliyun ecs stop-instances \
  --instance-ids i-abc123 i-def456 \
  --force-stop false

# Reboot instances
aliyun ecs reboot-instances \
  --instance-ids i-abc123 i-def456
```

## Scenario 2: Resource Creation with Tags

### Create ECS Instance

```bash
aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --zone-id cn-hangzhou-h \
  --instance-type ecs.g6.large \
  --image-id ubuntu_20_04_x64 \
  --security-group-id sg-abc123 \
  --vswitch-id vsw-abc123 \
  --instance-name web-server-01 \
  --data-disk Category=cloud_essd Size=100 \
  --data-disk Category=cloud_ssd Size=200 \
  --tag key=env value=prod \
  --tag key=app value=web \
  --tag key=team value=backend
```

### Create Function

```bash
aliyun fc create-function \
  --function-name image-processor \
  --runtime python3.9 \
  --handler index.handler \
  --memory-size 512 \
  --timeout 60 \
  --description "Process uploaded images" \
  --environment-variables \
    OSS_BUCKET=my-bucket \
    REGION=cn-hangzhou \
  --code zipFile=@./function.zip
```

## Scenario 3: Monitoring and Diagnostics

### Check Instance Metrics

```bash
# CPU utilization
aliyun cms describe-metric-last \
  --namespace acs_ecs_dashboard \
  --metric-name CPUUtilization \
  --dimensions "[{\"instanceId\":\"i-abc123\"}]"

# Memory usage
aliyun cms describe-metric-last \
  --namespace acs_ecs_dashboard \
  --metric-name memory_usedutilization \
  --dimensions "[{\"instanceId\":\"i-abc123\"}]"

# Disk usage
aliyun cms describe-metric-last \
  --namespace acs_ecs_dashboard \
  --metric-name diskusage_utilization \
  --dimensions "[{\"instanceId\":\"i-abc123\"}]"
```

### Query Metric History

```bash
aliyun cms describe-metric-list \
  --namespace acs_ecs_dashboard \
  --metric-name CPUUtilization \
  --dimensions "[{\"instanceId\":\"i-abc123\"}]" \
  --start-time "2024-03-01 00:00:00" \
  --end-time "2024-03-10 23:59:59" \
  --period 60
```

## Scenario 4: Function Compute Deployment

### Complete Function Deployment

```bash
# 1. Create function
aliyun fc create-function \
  --function-name api-handler \
  --runtime nodejs16 \
  --handler index.handler \
  --memory-size 512 \
  --timeout 30 \
  --code zipFile=@./dist/function.zip

# 2. Create HTTP trigger
aliyun fc create-trigger \
  --function-name api-handler \
  --trigger-name http-trigger \
  --trigger-type http \
  --trigger-config '{"authType":"anonymous","methods":["GET","POST"]}'

# 3. Test function
aliyun fc invoke-function \
  --function-name api-handler \
  --x-fc-invocation-type Sync \
  --body '{"test":true}'

# 4. Create production alias
aliyun fc publish-function-version \
  --function-name api-handler \
  --description "v1.0.0"

aliyun fc create-alias \
  --function-name api-handler \
  --alias-name prod \
  --version-id 1
```

## Scenario 5: RDS Database Management

### Create and Configure RDS Instance

```bash
# 1. Create RDS instance
aliyun rds create-db-instance \
  --region-id cn-hangzhou \
  --engine MySQL \
  --engine-version 8.0 \
  --db-instance-class mysql.n2.small.1 \
  --db-instance-storage 20 \
  --db-instance-storage-type cloud_essd \
  --security-ip-list "192.168.0.0/16" \
  --pay-type Postpaid

# 2. Create database
aliyun rds create-database \
  --db-instance-id rm-abc123 \
  --db-name myapp \
  --character-set-name utf8mb4

# 3. Create account
aliyun rds create-account \
  --db-instance-id rm-abc123 \
  --account-name myuser \
  --account-password 'MySecurePass123!' \
  --account-type Normal

# 4. Grant privileges
aliyun rds grant-account-privilege \
  --db-instance-id rm-abc123 \
  --account-name myuser \
  --db-name myapp \
  --account-privilege ReadWrite
```

## Scenario 6: SLS (Log Service) Setup

### Create Log Project and Store

```bash
# Create project
aliyun sls create-project \
  --project-name my-app-logs \
  --description "Application logs" \
  --region cn-hangzhou

# Create logstore
aliyun sls create-logstore \
  --project-name my-app-logs \
  --logstore-name access-log \
  --ttl 30 \
  --shard-count 2

# Create index
aliyun sls create-index \
  --project-name my-app-logs \
  --logstore-name access-log \
  --index-config '{
    "line": {
      "token": [" ", "\t", "\n"],
      "caseSensitive": false,
      "chn": false
    }
  }'
```

## Scenario 7: Multi-Version API Usage

### Using Different ESS Versions

```bash
# Check available versions
aliyun ess list-api-versions

# Use default version (2014-08-28)
aliyun ess describe-scaling-groups --region-id cn-hangzhou

# Use newer version (2022-02-22) with new features
aliyun ess describe-scaling-groups \
  --api-version 2022-02-22 \
  --region-id cn-hangzhou \
  --group-type ECS

# Set version preference for session
export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22
aliyun ess describe-scaling-groups --region-id cn-hangzhou
```

## Scenario 8: Resource Tagging Strategy

### Tag-Based Resource Management

```bash
# Add tags to existing instance
aliyun ecs tag-resources \
  --resource-type instance \
  --resource-id i-abc123 \
  --tag key=project value=website \
  --tag key=cost-center value=engineering \
  --tag key=environment value=production

# List resources by tag
aliyun ecs describe-instances \
  --region-id cn-hangzhou \
  --tag key=project value=website

# Remove tags
aliyun ecs untag-resources \
  --resource-type instance \
  --resource-id i-abc123 \
  --tag-key project \
  --tag-key cost-center
```

## Scenario 9: Debugging and Troubleshooting

### Using Debug Logging

```bash
# Enable debug logging for detailed output
aliyun ecs describe-instances \
  --region-id cn-hangzhou \
  --log-level debug

# Development mode with colored output
aliyun fc list-functions --log-level dev

# Set global debug mode
export ALIBABA_CLOUD_CLI_LOG_CONFIG=debug
aliyun ecs describe-instances --region-id cn-hangzhou
```

### Verify Request Details

```bash
# Use debug mode to see:
# - API endpoint being called
# - Request parameters (before serialization)
# - Serialized request (actual API format)
# - Response status and headers
# - Response body

aliyun fc create-function \
  --function-name test \
  --runtime python3.9 \
  --handler index.handler \
  --code zipFile=@./code.zip \
  --log-level=debug
```

## Tips and Best Practices

### 1. Use Structured Parameters
Always use the simplified structured format instead of manual JSON:
```bash
# Good
--tag key=env value=prod

# Avoid (old style)
--Tag.1.Key=env --Tag.1.Value=prod
```

### 2. Check Plugin Status First
Before running commands, ensure the plugin is installed:
```bash
aliyun plugin list | grep ecs
# Search available plugins:
aliyun plugin search ecs
# If not found:
aliyun plugin install --names ecs
```

### 3. Use Query Filters
Filter output to get only what you need:
```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[?Status=='Running'].InstanceId" \
  --output json
```

### 4. Leverage Environment Variables
Set common parameters via environment:
```bash
export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22
```

### 5. Save Output for Processing
Redirect output to files for further processing:
```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --output json > instances.json

# Process with jq
cat instances.json | jq '.Instances.Instance[] | {id: .InstanceId, name: .InstanceName}'
```

## Quick Command Reference

| Task | Command |
|------|---------|
| Check plugin status | `aliyun plugin list` |
| Install plugin | `aliyun plugin install --names <name>` |
| List commands | `aliyun <product> --help` |
| Command help | `aliyun <product> <command> --help` |
| Debug mode | `--log-level debug` |
| Output format | `--output json\|yaml\|table` |
| Filter output | `--cli-query "<jmespath>"` |
| API version | `--api-version <version>` |

For more details, see:
- `./plugin-advantages.md` for feature explanations
- `./command-syntax.md` for complete syntax guide of product plugin
- `../scripts/examples/` for executable examples
