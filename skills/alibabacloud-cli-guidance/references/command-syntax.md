# Command Syntax Guide

## Basic Command Structure for Product Plugin

```bash
aliyun <product> <command> [--parameter value] [--global-flag value]
```

- `<product>`: Plugin name (ecs, fc, rds, oss, sls, etc.)
- `<command>`: Operation in kebab-case (describe-instances, create-function)
- `--parameter`: Command-specific parameters in kebab-case
- `--global-flag`: Global flags like --region-id, --output, --log-level

## Parameter Types for Product Plugin

### 1. Simple String/Number/Boolean

```bash
aliyun ecs describe-instances \
  --instance-id i-abc123 \
  --biz-region-id cn-hangzhou \
  --page-size 50
```

### 2. Array of Primitives

Multiple values by repeating the parameter:
```bash
aliyun ecs describe-instances \
  --instance-id i-abc123 \
  --instance-id i-def456 \
  --instance-id i-ghi789
```

Or space-separated:
```bash
aliyun ecs stop-instances \
  --instance-ids i-abc123 i-def456 i-ghi789
```

### 3. Array of Objects

Repeat the parameter with key=value pairs:
```bash
aliyun ecs create-instance \
  --tag key=env value=prod \
  --tag key=app value=web \
  --tag key=team value=backend
```

### 4. Object Parameters

Use key=value pairs:
```bash
aliyun ecs create-instance \
  --data-disk category=cloud_essd size=100 \
  --data-disk category=cloud_ssd size=200
```

### 5. JSON Parameters (when needed)

For very complex structures, JSON is still supported:
```bash
aliyun fc create-function \
  --function-name test \
  --code '{"zipFile":"base64encoded..."}'
```

## Special Parameter Handling for Product Plugin

### File Upload

Use `@` prefix to read from file:
```bash
aliyun fc create-function \
  --function-name test \
  --code zipFile=@./function.zip
```

### Query/Filter Output

Use `--cli-query` for JMESPath filtering:
```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[?Status=='Running'].{ID:InstanceId,Name:InstanceName}"
```

Use `--output` for format selection:
```bash
aliyun ecs describe-instances --output json
aliyun ecs describe-instances --output yaml
aliyun ecs describe-instances --output table
aliyun ecs describe-instances --output cols=InstanceId,InstanceName,Status
```

## Global Flags for Product Plugin

Available across all commands:

```bash
--cli-dry-run                 # Enable dry-run mode: print request details without sending the actual API call
--region-id <string>          # Aliyun region
--cli-query <jmespath>        # JMESPath query to filter output
--log-level <string>          # Set log level: DEBUG, INFO, WARN, ERROR (default: ERROR)
--endpoint <url>              # Override service endpoint
--retry <count>               # Retry count for failed requests
--quiet                       # Suppress output (quiet mode)
```

## Multi-Version API Usage for Product Plugin

### Check Available Versions

```bash
aliyun ess list-api-versions
```

### Specify Version via Flag

```bash
aliyun ess describe-scaling-groups \
  --api-version 2022-02-22 \
  --biz-region-id cn-hangzhou
```

### Specify Version via Environment Variable

```bash
export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22
aliyun ess describe-scaling-groups --biz-region-id cn-hangzhou
```

### Check Help for Specific Version

```bash
aliyun ess describe-scaling-groups --api-version 2022-02-22 --help
```

## Debugging Commands for Product Plugin

### Enable Debug Logging

```bash
aliyun ecs describe-instances \
  --region-id cn-hangzhou \
  --log-level debug
```

### Use Development Log Config

```bash
# Shows colored output with timestamps
aliyun fc list-functions --log-level dev
```

### Set Global Log Config

```bash
export ALIBABA_CLOUD_CLI_LOG_CONFIG=dev
aliyun fc list-functions
```

## Help System for Product Plugin

### Product-Level Help

```bash
aliyun ecs --help
```

### Command-Level Help

```bash
aliyun ecs describe-instances --help
```

### List All Commands for a Product

```bash
aliyun ecs --help | grep "Available Commands"
```

## Plugin Management

### List Installed Plugins

```bash
aliyun plugin list
```

### List Available Plugins

```bash
aliyun plugin list-remote
```

### Install Plugin

```bash
aliyun plugin install --names <plugin-name>
```

### Update Plugin

```bash
aliyun plugin update <plugin-name>
```

### Uninstall Plugin

```bash
aliyun plugin uninstall <plugin-name>
```

## Common Patterns for Product Plugin

### Pagination

Many list commands support pagination:
```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --page-number 1 \
  --page-size 50
```

### Filtering by Tags

```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --tag key=env value=prod
```

### Resource Creation with Tags

```bash
aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --instance-type ecs.g6.large \
  --image-id ubuntu_20_04_x64 \
  --tag key=env value=prod \
  --tag key=owner value=team-a
```

### Waiting for Resource Status

Some commands support built-in waiters:
```bash
aliyun ecs start-instance \
  --instance-id i-abc123 \
  --waiter expr='Status' to='running'
```

## Error Handling for Product Plugin

### Common Error Messages

1. **Plugin not found**
   ```
   Error: plugin 'xxx' not found
   Solution: aliyun plugin install --names xxx
   ```

2. **Missing required parameter**
   ```
   Error: required parameter '--instance-id' not provided
   Solution: Add the required parameter
   ```

3. **Invalid parameter value**
   ```
   Error: invalid value for '--instance-type'
   Solution: Check valid values with --help
   ```

4. **API version not supported**
   ```
   Error: unsupported API version
   Solution: Check supported versions with 'aliyun <product> list-api-versions'
   ```

### Getting More Information

Always add `--log-level debug` when troubleshooting:
```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --log-level debug
```
