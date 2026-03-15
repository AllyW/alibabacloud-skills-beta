# Common Aliyun CLI Scenarios

Supplementary examples for operations not fully covered in SKILL.md.
For core instructions (plugin management, structured params, output filtering,
debugging, multi-version), see SKILL.md directly.

## Scenario 1: Instance Management

### List and Filter Instances

```bash
# Filter by status
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --status Running

# Filter by tags
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --tag key=env value=prod

# Custom output columns with row path
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

## Scenario 2: Resource Creation (detailed)

### Create ECS Instance (full example)

```bash
aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --zone-id cn-hangzhou-h \
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

### Create Function with Environment Variables

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
    REGION=cn-hangzhou
```

## Scenario 3: SLS (Log Service) Setup

```bash
# Create project
aliyun sls create-project \
  --project-name my-app-logs \
  --description "Application logs" \
  --region cn-hangzhou

# Create logstore
aliyun sls create-log-store \
  --project my-app-logs \
  --logstore-name access-log \
  --ttl 30 \
  --shard-count 2
```

## Scenario 4: Resource Tagging Strategy

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
  --biz-region-id cn-hangzhou \
  --tag key=project value=website

# Remove tags
aliyun ecs untag-resources \
  --resource-type instance \
  --resource-id i-abc123 \
  --tag-key project \
  --tag-key cost-center
```
