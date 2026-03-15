---
name: alibabacloud-cli-guidance
description: >
  Guide users to manage Alibaba Cloud resources using the Aliyun CLI command-line tool.
  Covers CLI installation, credential configuration, plugin management, command construction,
  and error troubleshooting. Use this skill when the user wants to operate Alibaba Cloud
  services from the terminal — including ECS (cloud servers), Function Compute (serverless),
  RDS (databases), OSS (object storage), SLS (log service), VPC (networking), ESS (auto scaling),
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

### 1. Verify CLI readiness

If the user hasn't installed or configured the CLI, guide them through setup. Refer to
`./references/installation-guide.md` for detailed steps. Quick verification:

```bash
aliyun version      # Should be >= 3.3.0
aliyun ecs describe-regions   # Tests authentication
```

Aliyun CLI 3.3.0+ supports all published Alibaba Cloud product plugins.

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
| Help | Comprehensive with structure | Basic |

### 5. Handle global parameter conflicts

CLI has global parameters (`--region-id`, `--profile`, `--api-version`, etc.). When an API's own
parameter has the same name, the plugin renames it to avoid ambiguity — otherwise the CLI can't
tell whether the user means the global flag or the API parameter:

- First choice: `--biz-region-id` (add `biz-` prefix)
- Fallback: `--<product>-region-id` (add product prefix if `biz-` also conflicts)

Always check `--help` to see the actual parameter name for a given command.

### 6. Use structured parameter syntax

Plugins support structured input that the framework serializes automatically. This avoids
the error-prone legacy `--Tag.N.Key` / `--Param.N=value` syntax:

```bash
--security-group-ids sg-001 sg-002 sg-003              # list
--tag Key=env Value=prod --tag Key=app Value=web        # key-value (repeatable)
--data-disk '{"DiskName":"d1","Size":100}'              # complex structure (JSON)
```

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

### 8. Debugging

When troubleshooting command failures, these flags reveal what's happening under the hood —
the full HTTP request/response and parameter validation details:

- `--log-level debug` — detailed request/response logs
- `--cli-dry-run` — validate command without executing (checks parameter parsing)

### 9. Multi-version API support

Some products have multiple API versions with different capabilities. Using the wrong version
may result in missing parameters or deprecated behavior:

```bash
aliyun <product> list-api-versions                    # Check available versions
aliyun <product> <cmd> --api-version 2022-02-22       # Specify per command
```

## Common Workflows

### ECS Instances

```bash
aliyun plugin list | grep ecs
# If missing: aliyun plugin install --names ecs

aliyun ecs describe-instances --biz-region-id cn-hangzhou

aliyun ecs create-instance \
  --biz-region-id cn-hangzhou \
  --instance-type ecs.g6.large \
  --image-id ubuntu_20_04_x64 \
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
  --memory-size 512 \
  --timeout 60
```

### Multi-Version API (ESS)

```bash
aliyun ess list-api-versions
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
- `./references/plugin-advantages.md` — Plugin vs built-in feature comparison
- `./references/command-syntax.md` — Complete command syntax guide
- `./references/global-flags.md` — Global flags reference
- `./references/common-scenarios.md` — Practical usage scenarios
- `./scripts/examples/` — Executable demo scripts
