---
name: alibabacloud-cli-guidance
description: >
  Guide users to manage Alibaba Cloud resources using the Aliyun CLI command-line tool.
  Covers CLI installation, credential configuration, plugin management, command construction,
  and error troubleshooting. Use this skill when the user wants to operate Alibaba Cloud
  services from the terminal — including ECS (云服务器, cloud servers),
  Function Compute (函数计算, serverless), RDS (云数据库, databases),
  OSS (对象存储, object storage), SLS (日志服务, log service),
  VPC (专有网络, networking), ESS (弹性伸缩, auto scaling),
  and any other Alibaba Cloud product. Also use when the user mentions "aliyun", "阿里云",
  "阿里云CLI", "命令行", asks about CLI plugin installation, encounters Aliyun CLI errors
  (InvalidAccessKeyId, SignatureDoesNotMatch, Throttling), or needs help constructing
  aliyun commands with correct parameter syntax.
license: Apache-2.0
metadata:
  domain: aliyun-cli
  owner: sdk-team
  contact: sdk-team@alibabacloud.com
allowed-tools: Bash, aliyun cli
---

# Aliyun CLI Expert

Guide users to manage Alibaba Cloud resources effectively using the `aliyun` command-line tool.

## Instructions

### 1. Install and configure the CLI

If the user hasn't installed or configured the CLI, guide them through setup.
See `./references/installation-guide.md` for full details. Quick path:

```bash
# Install or update (macOS / Linux — one command)
/bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/setup.sh)"
```

```bash
# Configure with Access Key (most common)
aliyun configure set \
  --mode AK \
  --access-key-id <your-key-id> \
  --access-key-secret <your-key-secret> \
  --region cn-hangzhou

# Verify
aliyun version      # Should be >= 3.3.0
aliyun ecs describe-regions   # Tests authentication
```

Aliyun CLI 3.3.0+ supports all published Alibaba Cloud product plugins.

#### Authentication modes

Choose the mode that fits the deployment context:

| Mode | When to use | Command |
| ---- | ----------- | ------- |
| **AK** | Development, long-lived credentials | `aliyun configure set --mode AK --access-key-id ... --access-key-secret ... --region ...` |
| **StsToken** | CI/CD pipelines, temporary credentials | `aliyun configure set --mode StsToken --access-key-id ... --access-key-secret ... --sts-token ... --region ...` |
| **EcsRamRole** | Running on an ECS instance with attached RAM role — **no credentials needed** | `aliyun configure set --mode EcsRamRole --ram-role-name <role> --region ...` |
| **RamRoleArn** | Cross-account access, role assumption | `aliyun configure set --mode RamRoleArn --access-key-id ... --access-key-secret ... --ram-role-arn ... --region ...` |

Environment variables override config file (useful for CI/CD):

```bash
export ALIBABA_CLOUD_ACCESS_KEY_ID=<key-id>
export ALIBABA_CLOUD_ACCESS_KEY_SECRET=<key-secret>
export ALIBABA_CLOUD_SECURITY_TOKEN=<sts-token>   # Only for StsToken mode
export ALIBABA_CLOUD_REGION_ID=cn-hangzhou
```

#### Named profiles

Manage multiple accounts/environments with profiles:

```bash
aliyun configure set --profile prod \
  --mode AK --access-key-id ... --access-key-secret ... --region cn-hangzhou
aliyun configure set --profile staging \
  --mode AK --access-key-id ... --access-key-secret ... --region cn-shanghai

aliyun ecs describe-instances --profile prod          # Use specific profile
aliyun configure switch --profile prod                # Switch default
```

### 2. Consult `--help` before constructing any command

Built-in commands have inconsistent parameter naming across APIs — some use PascalCase,
others camelCase, and the exact names are not predictable. Guessing parameter names frequently
leads to errors that require multiple retries. Running `--help` first takes seconds:

```bash
aliyun <product> --help                # Discover available subcommands
aliyun <product> <subcommand> --help   # Get exact parameter names, types, structure
```

Help output is the authoritative source. Plugin help is especially rich — it includes type
info, structure fields, format hints, and constraints for every parameter.

When a plugin is installed, `aliyun <product> --help` automatically shows plugin help. To view
the legacy built-in (OpenAPI-style) help instead:

```bash
ALIBABA_CLOUD_ORIGINAL_PRODUCT_HELP=true aliyun ecs --help
```

### 3. Ensure service plugins are available

Each Alibaba Cloud product has a CLI plugin. Plugins provide consistent kebab-case commands
with comprehensive help, while the legacy built-in system has inconsistent naming and minimal
help. If you know which product to use, install the plugin directly — `plugin install` is
idempotent (safe to run even if already installed):

```bash
aliyun plugin install --names ecs     # Install (short name, case-insensitive)
aliyun plugin install --names ECS VPC RDS   # Multiple at once
```

To discover or verify plugins:

```bash
aliyun plugin list                    # Installed plugins
aliyun plugin list-remote             # All available plugins
aliyun plugin search <keyword>        # Search by keyword
```

Plugin names accept both short form (`ecs`) and full form (`aliyun-cli-ecs`), case-insensitive.

Plugin lifecycle:

```bash
aliyun plugin update --name ecs              # Update a plugin
aliyun plugin uninstall --name ecs           # Remove a plugin
```

### 4. Prefer plugin commands over built-in commands

The CLI has two command styles, and the **subcommand casing** determines which system handles it:

- **All-lowercase subcommand** → routed to plugin (CLI Native style)
- **Contains uppercase** → routed to built-in (OpenAPI style)

Plugin commands use consistent kebab-case naming for both subcommands and parameters, making
them predictable. Built-in commands use PascalCase subcommands with mixed/inconsistent parameter
naming that varies by API — you must check `--help` for every command to know the exact names.

```bash
# Plugin (preferred): consistent kebab-case
aliyun ecs describe-instances --biz-region-id cn-hangzhou

# Built-in (fallback): PascalCase subcommand, inconsistent params
aliyun ecs DescribeInstances --RegionId cn-hangzhou
```

Mixing styles causes silent failures — the CLI routes to different backends based on subcommand
casing. A kebab-case subcommand with PascalCase parameters will be sent to the plugin system,
which doesn't recognize PascalCase parameter names.

Product code is always case-insensitive (`ecs`, `Ecs`, `ECS` all work).

| Aspect | Plugin (CLI Native) | Built-in (OpenAPI) |
| ------ | ------------------- | ------------------ |
| Subcommand | `describe-instances` | `DescribeInstances` |
| Parameters | kebab-case (consistent) | Mixed (inconsistent) |
| ROA Body | Expanded to individual params | Single `--body` JSON |
| Header params | Visible in help, usable directly | Hidden, manual `--header` only |
| Help | Comprehensive with structure | Basic |

### 5. Understand global vs business parameter naming

The CLI plugin system reserves certain global parameters for its own use:

- `--region-id` / `--region` — controls which **API endpoint** the request is sent to (e.g.
  `ecs.cn-hangzhou.aliyuncs.com`). This is a routing concern, not a business field.
- Other globals include `--profile`, `--api-version`, `--output`, etc.

Many APIs also define their own `RegionId` or `Region` parameter in the API spec — these are
**business parameters** with API-specific meaning (e.g. "the region to create this resource in").
The global `--region-id` and the API's `RegionId` serve different purposes, but they would
collide on the command line.

The plugin system resolves this automatically during code generation:

1. **`--biz-` prefix (default)**: the API parameter `RegionId` becomes `--biz-region-id`
2. **`--<product>-` prefix (fallback)**: if `--biz-region-id` is already taken by another
   parameter, the plugin falls back to `--<product>-region-id` (e.g. `--ecs-region-id`)

This means in plugin commands, `--region-id` is **always** the global endpoint selector, and
the business region is `--biz-region-id` (or `--<product>-region-id`). Using `--region-id` where
you meant the business parameter silently changes the endpoint without setting the intended field.

Always check `--help` to see the actual parameter name — it is the authoritative source for
whether a given command uses `--biz-region-id`, `--<product>-region-id`, or something else.

### 6. Use structured parameter syntax

Plugins support structured input that the framework serializes automatically. This avoids
the error-prone legacy `--Tag.N.Key` / `--Param.N=value` syntax.

**Primitives and lists:**

```bash
--instance-id i-abc123                                  # single value
--security-group-ids sg-001 sg-002 sg-003               # space-separated list
--instance-id i-abc --instance-id i-def                 # repeated param (also valid)
```

**Key-value objects and repeatable structures:**

```bash
--tag Key=env Value=prod --tag Key=app Value=web        # repeatable key-value
--capacity-options OnDemandBaseCapacity=12 CompensateWithOnDemand=true  # object
--data-disk '{"DiskName":"d1","Size":100}'              # complex structure (JSON)
```

Check `--help` for each command — it shows the exact type, structure fields, and whether a
parameter is repeatable.

### 7. OSS uses custom commands

Unlike other products, OSS has a hand-written implementation with custom command syntax.
API-style commands like `PutBucket` or `GetObject` do not exist for OSS — using them will fail
silently or produce confusing errors. Always check help first:

```bash
aliyun oss --help        # Basic operations (cp, ls, mb, rm, etc.)
aliyun ossutil --help    # Advanced utilities (sync, stat, etc.)

aliyun oss cp local.txt oss://bucket/      # Upload
aliyun oss mb oss://my-bucket              # Create bucket
aliyun ossutil sync ./local/ oss://bucket/ # Sync directory
```

### 8. Filter and format output

Use `--cli-query` (JMESPath) to extract specific fields from API responses, and `--output`
to control the format. This avoids piping large JSON blobs through external tools:

```bash
# JMESPath filter: only running instances, selected fields
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --cli-query "Instances.Instance[?Status=='Running'].{ID:InstanceId,Name:InstanceName}"

# Output formats
aliyun ecs describe-instances --output json              # default
aliyun ecs describe-instances --output table             # human-readable table
aliyun ecs describe-instances --output cols=InstanceId,InstanceName,Status  # custom columns
```

### 9. Pagination

Many list commands return paginated results. Use `--page-number` and `--page-size` to control:

```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --page-number 1 \
  --page-size 50
```

To fetch all pages automatically without manual loops, use `--pager`:

```bash
aliyun ecs describe-instances \
  --biz-region-id cn-hangzhou \
  --pager path='Instances.Instance[]' PageNumber=PageNumber PageSize=PageSize
```

`--all-pages` is an alias for `--pager`. The `path` argument specifies which JSON field
contains the page data to merge.

### 10. Wait for resource state

Some commands support built-in waiters for automation — poll until a resource reaches the
desired state:

```bash
aliyun vpc describe-vpc-attribute \
  --biz-region-id cn-shanghai \
  --vpc-id vpc-abc123 \
  --waiter expr='Status' to='Available'
```

### 11. Debugging

When troubleshooting command failures, these flags reveal what's happening under the hood —
the full HTTP request/response and parameter validation details:

- `--log-level debug` — detailed request/response logs (shows endpoint, serialized params, response)
- `--cli-dry-run` — validate command without executing (checks parameter parsing)
- `ALIBABA_CLOUD_CLI_LOG_CONFIG=debug` — environment variable to set log level globally

### 12. Multi-version API support

Some products (e.g. ESS, SLB) ship multiple API versions with different command sets and
capabilities. Using the wrong version may cause missing parameters, deprecated behavior, or
entirely different command availability. Not all products have multiple versions — if
`list-api-versions` returns an error, the product is single-version and no action is needed.

#### Discover versions

```bash
aliyun <product> list-api-versions
```

Example output (ESS):

```text
Product: ESS
Supported API versions:
* 2014-08-28 (default)
  2016-07-22
  2022-02-22
```

The `*` marks the default version. Each version may expose a different set of commands — newer
versions often add commands or change parameter names.

#### Specify version per command

```bash
aliyun ess describe-scaling-groups --api-version 2022-02-22 --biz-region-id cn-hangzhou
```

#### Set a default version via environment variable

To avoid passing `--api-version` on every call, set the default for a product:

```bash
export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22
export ALIBABA_CLOUD_SLB_API_VERSION=2014-05-15
```

The pattern is `ALIBABA_CLOUD_<PRODUCT_CODE>_API_VERSION` (product code in uppercase).
This is especially useful in scripts or CI/CD where you want consistent version behavior
across multiple commands.

#### View commands for a specific version

Different API versions may have different command sets. To see what's available:

```bash
aliyun ess --api-version 2022-02-22    # List commands in this version
aliyun ess <cmd> --api-version 2022-02-22 --help   # Help for a specific command in this version
```

#### When to specify version

- **Default version works for most cases** — only specify when you need features from a newer version
- **Check `--help` output** — if a parameter you expect is missing, it may exist in a different version
- **Pinning versions in scripts** — use the environment variable to ensure reproducible behavior

## Global Flags Reference

These flags are available on all plugin commands:

| Flag | Purpose |
| ---- | ------- |
| `--region <region>` | API endpoint region (global, not business region) |
| `--profile <name>` | Use a named credential profile |
| `--api-version <ver>` | Override API version for this command |
| `--output json\|table\|cols=...` | Response format |
| `--cli-query <jmespath>` | JMESPath filter on response |
| `--log-level debug` | Verbose request/response logging |
| `--cli-dry-run` | Validate without executing |
| `--endpoint <url>` | Override service endpoint |
| `--retry <n>` | Retry count for failed requests |
| `--quiet` | Suppress output |
| `--pager` / `--all-pages` | Auto-merge all pages for pageable APIs |

## Common Workflows

### ECS Instances

```bash
aliyun plugin list | grep ecs
# If missing: aliyun plugin install --names ecs

aliyun ecs describe-instances --biz-region-id cn-hangzhou

aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --instance-type ecs.g7.large \
  --image-id ubuntu_20_04_arm64_20G_alibase_20250625.vhd \
  --data-disk Category=cloud_essd Size=100 \
  --tag Key=env Value=prod --tag Key=app Value=web
```

### Function Compute (ROA Body Expansion)

```bash
# Plugin expands ROA body fields into individual params (no --body JSON needed)
aliyun fc create-function \
  --function-name my-function \
  --runtime python3.9 \
  --handler index.handler \
  --memory-size 512
```

### Multi-Version API (ESS)

```bash
# Check available versions
aliyun ess list-api-versions

# Use the latest version for new features
export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22
aliyun ess describe-scaling-groups --biz-region-id cn-hangzhou

# Or specify per command without env var
aliyun ess describe-scaling-groups --api-version 2022-02-22 --biz-region-id cn-hangzhou
```

## Response Format

When providing CLI commands:

1. Explain what the command does and why specific parameters are used
2. Show the complete command with all required parameters
3. Call out non-obvious values — especially `--biz-` prefixed parameters and their reason
4. Suggest `--log-level debug` when the user is troubleshooting

## References

- `./references/installation-guide.md` — Installation, configuration modes, credential setup
- `./references/command-syntax.md` — Complete command syntax guide
- `./references/global-flags.md` — Global flags reference
- `./references/common-scenarios.md` — Practical usage scenarios
- `./scripts/examples/` — Executable demo scripts
