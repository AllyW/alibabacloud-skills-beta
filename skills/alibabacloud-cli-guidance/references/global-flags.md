# Global Flags Reference

Complete reference for all global flags supported by the Aliyun CLI plugin system.

## Visible Global Flags

These flags are shown in `--help` output and commonly used:

### --log-level

Control logging level for CLI execution.

**Values**: `DEBUG`, `INFO`, `WARN`, `ERROR`, `dev`, `production`, `debug`, `quiet`

**Default**: `ERROR`

**Usage**:
```bash
# Debug mode (most detailed)
aliyun ecs describe-instances --log-level DEBUG

# Development mode (colored output with timestamps)
aliyun fc create-function --log-level dev

# Production mode (only errors)
aliyun fc list-functions --log-level production
```

**What it logs**:
- Parameter parsing and validation
- API request construction and serialization
- HTTP request/response details
- Error stack traces

### --cli-dry-run

**Enable dry-run mode**: Print request details WITHOUT sending the actual API call.

**Perfect for**:
- Debugging command syntax
- Validating parameters before execution
- Learning API request structure
- Testing commands safely

**Usage**:
```bash
# See what would be sent without actually calling the API
aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --instance-type ecs.g6.large \
  --image-id ubuntu_20_04_x64 \
  --cli-dry-run

# Output shows:
# - Endpoint URL
# - HTTP method
# - Request headers
# - Serialized parameters
# - Request body (if any)
```

**Example Output**:
```
[DRY-RUN] API call would be made with the following details:
  Endpoint: https://ecs.cn-hangzhou.aliyuncs.com
  Method: POST
  Headers:
    Content-Type: application/x-www-form-urlencoded
    x-acs-action: CreateInstance
  Parameters:
    RegionId=cn-hangzhou
    InstanceType=ecs.g6.large
    ImageId=ubuntu_20_04_x64
```

### --cli-query

Filter output with JMESPath expression (replaces `--query` from old CLI).

**Usage**:
```bash
# Get only instance IDs
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[].InstanceId"

# Filter running instances
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[?Status=='Running']"

# Custom output structure
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[].{id: InstanceId, name: InstanceName, status: Status}"
```

### --output, -o

Control output format or display table with specific columns.

**Formats**:
- `json` - JSON format (default for most commands)
- `yaml` - YAML format
- `table` - Automatic table format
- `cols=Field1,Field2` - Custom table columns

**Usage**:
```bash
# JSON output
aliyun ecs describe-instances --output json

# Custom table columns
aliyun ecs describe-instances \
  --output cols=InstanceId,InstanceName,Status,PublicIpAddress

# With row filtering
aliyun ecs describe-instances \
  --output cols=InstanceId,Status rows='Instances.Instance[]'
```

### --region

Override region ID of service endpoint for the API call.

**Usage**:
```bash
aliyun ecs describe-instances --region cn-hangzhou
aliyun fc list-functions --region cn-beijing
```

### --endpoint

Override service endpoint URL.

**Usage**:
```bash
# Custom endpoint
aliyun ecs describe-instances \
  --endpoint https://ecs.cn-hangzhou.aliyuncs.com

# Internal/VPC endpoint
aliyun ecs describe-instances \
  --endpoint https://ecs-vpc.cn-hangzhou.aliyuncs.com
```

### --quiet, -q

Suppress output (quiet mode). Useful in scripts.

**Usage**:
```bash
# Only show errors
aliyun ecs start-instance --instance-id i-xxx --quiet

# In scripts
if aliyun ecs stop-instance --instance-id i-xxx --quiet; then
  echo "Stopped successfully"
fi
```

---

## Hidden Global Flags

These flags are available but hidden from `--help` for advanced use cases:

### --pager (alias: --all-pages)

Automatically merge all pages for pageable APIs.

**Usage**:
```bash
# Fetch all pages automatically
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --pager path='Instances.Instance[]' PageNumber=PageNumber PageSize=PageSize

# Using alias
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --all-pages path=Instances.Instance[]
```

### --waiter

Poll API until result matches expected value.

**Usage**:
```bash
# Wait for instance to be Running
aliyun ecs start-instance --instance-id i-xxx
aliyun ecs describe-instances \
  --instance-id i-xxx \
  --waiter expr='Instances.Instance[0].Status' to=Running timeout=180 interval=5
```

### --header

Add custom HTTP headers.

**Usage**:
```bash
aliyun ecs describe-instances \
  --region-id cn-hangzhou \
  --header X-Custom-Header=value \
  --header X-Another-Header=value2
```

### --body

Provide raw HTTP request body (for advanced use).

**Usage**:
```bash
aliyun fc invoke-function \
  --function-name test \
  --body '{"key":"value"}'
```

### --body-file

Read HTTP request body from file.

**Usage**:
```bash
aliyun fc create-function \
  --function-name test \
  --body-file ./function-config.json
```

### --secure

Force use of HTTPS protocol.

**Usage**:
```bash
aliyun ecs describe-instances --secure
```

### --insecure

Force use of HTTP protocol (not recommended).

**Usage**:
```bash
aliyun ecs describe-instances --insecure
```

### --no-stream

For SSE APIs: aggregate all events instead of streaming.

**Usage**:
```bash
# Collect all SSE events before displaying
aliyun <product> <sse-command> --no-stream
```

---

## Common Combinations

### Debugging Command Syntax

```bash
# Perfect combination for testing and debugging
aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --instance-type ecs.g6.large \
  --cli-dry-run \
  --log-level DEBUG
```

### Production Safe Execution

```bash
# Validate first, then execute
aliyun ecs stop-instance \
  --instance-id i-xxx \
  --cli-dry-run

# If looks good, execute
aliyun ecs stop-instance \
  --instance-id i-xxx
```

### Output Processing Pipeline

```bash
# Filter, format, and process
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[?Status=='Running']" \
  --output json | jq '.[] | .InstanceId'
```

### Script-Friendly Mode

```bash
# Quiet mode with error handling
if ! aliyun ecs start-instance \
  --instance-id i-xxx \
  --quiet \
  --log-level ERROR 2>&1; then
  echo "Failed to start instance"
  exit 1
fi
```

---

## Environment Variables

Some global flags can be set via environment variables:

```bash
# Log level (use preset config names: dev, debug, production, quiet, ci)
export ALIBABA_CLOUD_CLI_LOG_CONFIG=debug

# Region
export ALIBABA_CLOUD_REGION_ID=cn-hangzhou

# API version (product-specific)
export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22

# Profile
export ALIBABA_CLOUD_PROFILE=production 
```

---

## Flag Priority

When the same parameter is set in multiple ways, priority order:

1. **Command-line flag** (highest priority)
2. **Environment variable**
3. **Config file**
4. **Default value** (lowest priority)

Example:
```bash
# Even if env var is set
export ALIBABA_CLOUD_REGION_ID=cn-beijing

# Command-line flag takes precedence
aliyun ecs describe-instances --region cn-hangzhou
# Uses cn-hangzhou, not cn-beijing
```

---

## Tips

💡 **Start with --cli-dry-run**: Always test complex commands with `--cli-dry-run` first

💡 **Use --log-level=dev**: During development, use `--log-level=dev` for best visibility

💡 **Combine --cli-query with jq**: For complex JSON processing, use `--cli-query` for initial filtering and `jq` for advanced manipulation

💡 **Save dry-run output**: `--cli-dry-run` output helps document API requirements

💡 **Quiet mode in scripts**: Always use `--quiet` in production scripts to avoid parsing issues

---

## Quick Reference Table

| Flag | Purpose | Common Use |
|------|---------|------------|
| `--log-level` | Control logging | Debugging: `--log-level=DEBUG` |
| `--cli-dry-run` | Test without executing | Validation: `--cli-dry-run` |
| `--cli-query` | Filter output | Extract data: `--cli-query "..."` |
| `--output` | Format output | Table view: `--output cols=...` |
| `--region` | Set region | Override: `--region cn-hangzhou` |
| `--endpoint` | Custom endpoint | VPC: `--endpoint https://...` |
| `--quiet` | Suppress output | Scripts: `--quiet` |
| `--pager` | Auto-pagination | Fetch all: `--all-pages ...` |
| `--waiter` | Poll until ready | Wait: `--waiter expr=... to=...` |

---

For more information:
- [Command Syntax Guide](./command-syntax.md)
- [Common Scenarios](./common-scenarios.md)
- [Plugin Advantages](./plugin-advantages.md)
