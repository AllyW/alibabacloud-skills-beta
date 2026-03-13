# Plugin-Based CLI Advantages

Quick reference for the key advantages of the Aliyun plugin-based CLI system.

> **Aliyun CLI 3.3.0+**: All published Alibaba Cloud product plugins are available for installation and use.

## 1. Unified Parameter Input

### Old CLI Problem
Different parameter styles (json, flat, repeatList, simple) required different input formats:
- RPC APIs: `--Tag.1.Key=k1 --Tag.1.Value=v1 --Tag.2.Key=k2 --Tag.2.Value=v2`
- ROA APIs: `--Tag '[{"Key":"k1","Value":"v1"},{"Key":"k2","Value":"v2"}]'`

### Plugin CLI Solution
Unified structured input for all API styles:
```bash
aliyun fc list-tag-resources \
  --tag key=k1 value=v1 \
  --tag key=k2 value=v2
```

Framework automatically handles serialization based on API style.

## 2. Consistent Naming (kebab-case)

### Old CLI
Mixed naming styles:
- Commands: `DescribeInstances`, `CreateFunction`
- Parameters: `--InstanceId`, `--functionName`, `--resource_group_id`

### Plugin CLI
Unified kebab-case:
- Commands: `describe-instances`, `create-function`
- Parameters: `--instance-id`, `--function-name`, `--resource-group-id`

## 3. Body/Header Parameter Visibility

### Old CLI Problem
- ROA API body parameters shown only as `--body <Json>` in help
- Header parameters not shown in help at all
- Users had to manually construct JSON

### Plugin CLI Solution
- Body object fields expanded as individual parameters
- Header parameters visible in help
- Auto-construction of JSON body from individual parameters

Example:
```bash
# Old: manual JSON construction
aliyun fc CreateFunction --body '{"functionName":"test","runtime":"python3"}'

# New: structured parameters
aliyun fc create-function --function-name test --runtime python3
```

## 4. Multi-Version API Support

### Old CLI Limitation
- Only one API version supported per product
- Non-default versions require `--force --api-version`
- No help available for non-default versions

### Plugin CLI Capability
- Multiple versions coexist in single plugin
- Easy version switching via `--api-version` or env var
- Complete help for all versions
- Version discovery: `aliyun ess list-api-versions`

## 5. Enhanced Logging

### Old CLI
- Only SDK-level logs via `DEBUG=sdk` env var
- No CLI execution process visibility

### Plugin CLI
- Multi-level logging: DEBUG, INFO, WARN, ERROR
- CLI-side execution logs (parameter parsing, serialization, routing)
- Flexible control via `--log-level` flag
- Preset configs: dev, production, debug, quiet

Example:
```bash
aliyun fc invoke-function --function-name test --log-level debug
```

## 6. Modular Plugin Architecture

### Benefits
- **Full coverage (v3.3.0+)**: All published Alibaba Cloud product plugins are supported
- Install only needed plugins: `aliyun plugin install --names ecs`
- Independent plugin updates
- Smaller CLI core
- Faster startup time

### Plugin Lifecycle
```bash
# List all available plugins (v3.3.0+ covers all published products)
aliyun plugin list-remote

# Search for plugins by keyword
aliyun plugin search fc

# Install plugin
aliyun plugin install --names fc

# Update plugin
aliyun plugin update --name fc

# List installed
aliyun plugin list
```

## Summary Comparison

| Feature | Old CLI | Plugin CLI |
|---------|---------|------------|
| Parameter input | Style-dependent, manual serialization | Unified structured format |
| Naming convention | Mixed (PascalCase, camelCase, snake_case) | Consistent kebab-case |
| Body parameters | Manual JSON construction | Auto-built from structured params |
| Header parameters | Hidden, manual via --header | Visible in help, direct usage |
| Multi-version | Single version, --force needed | Native multi-version support |
| Logging | SDK-only, env var control | Multi-level, CLI+SDK, flag control |
| Architecture | Monolithic | Modular plugins |
| Updates | Full CLI update | Per-plugin update |
