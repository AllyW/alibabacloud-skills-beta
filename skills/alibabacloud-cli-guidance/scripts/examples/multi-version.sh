#!/bin/bash
# Multi-Version API Support Examples

set -e

echo "=== Multi-Version API Support Examples ==="
echo ""

# ESS (Auto Scaling) supports multiple API versions
echo "Product: ESS (Auto Scaling)"
echo ""

# 1. Check available versions
echo "1. Check available API versions:"
echo "   aliyun ess api-versions"
echo ""
echo "   Output example:"
echo "   Available API versions for ESS:"
echo "   - 2014-08-28 (default)"
echo "   - 2022-02-22"
echo ""

# 2. Use default version
echo "2. Use default version (implicit):"
echo "   aliyun ess describe-scaling-groups --region-id cn-hangzhou"
echo ""
echo "   This uses the default version (2014-08-28)"
echo ""

# 3. Specify version via flag
echo "3. Specify API version via flag:"
echo "   aliyun ess describe-scaling-groups \\"
echo "     --api-version 2022-02-22 \\"
echo "     --region-id cn-hangzhou"
echo ""

# 4. Set version via environment variable
echo "4. Set API version via environment variable:"
echo "   export ESS_API_VERSION=2022-02-22"
echo "   aliyun ess describe-scaling-groups --region-id cn-hangzhou"
echo ""

# 5. View help for specific version
echo "5. View help for specific API version:"
echo "   aliyun ess describe-scaling-groups \\"
echo "     --api-version 2022-02-22 \\"
echo "     --help"
echo ""
echo "   The help output will show parameters specific to version 2022-02-22"
echo ""

# 6. Version-specific features
echo "6. Use version-specific features:"
echo "   # 2022-02-22 introduces new parameters"
echo "   aliyun ess describe-scaling-groups \\"
echo "     --api-version 2022-02-22 \\"
echo "     --region-id cn-hangzhou \\"
echo "     --group-type ECS"
echo ""

# 7. Version priority
echo "7. Version selection priority:"
echo "   Priority (high to low):"
echo "   1. --api-version flag"
echo "   2. {PRODUCT}_API_VERSION environment variable"
echo "   3. Default version from plugin manifest"
echo ""

# 8. Debugging version routing
echo "8. Debug version routing:"
echo "   aliyun ess describe-scaling-groups \\"
echo "     --api-version 2022-02-22 \\"
echo "     --region-id cn-hangzhou \\"
echo "     --log-level=debug"
echo ""
echo "   Debug output will show:"
echo "   - Selected API version"
echo "   - Version router decision process"
echo "   - Command routing details"
echo ""

# 9. Per-command version specification
echo "9. Different versions for different commands:"
echo "   # Command 1 uses default version"
echo "   aliyun ess describe-scaling-groups --region-id cn-hangzhou"
echo ""
echo "   # Command 2 uses specific version"
echo "   aliyun ess create-scaling-group \\"
echo "     --api-version 2022-02-22 \\"
echo "     --region-id cn-hangzhou \\"
echo "     --scaling-group-name my-group"
echo ""

# 10. Version compatibility check
echo "10. Check version compatibility:"
echo "    # Some commands may only be available in certain versions"
echo "    aliyun ess quick-scale --help"
echo ""
echo "    If command is not available in default version:"
echo "    Error: command 'quick-scale' not found in version 2014-08-28"
echo "    Try: aliyun ess quick-scale --api-version 2022-02-22 --help"
echo ""

# 11. Persistent version configuration
echo "11. Set persistent version preference:"
echo "    # Add to shell profile (~/.bashrc, ~/.zshrc)"
echo "    export ESS_API_VERSION=2022-02-22"
echo ""
echo "    # Or use aliyun configure to set per-profile"
echo "    aliyun configure set ess.api_version 2022-02-22 --profile myprofile"
echo ""

echo "=== End of Examples ==="
echo ""
echo "Benefits of multi-version support:"
echo "  ✓ Use new API features without breaking existing scripts"
echo "  ✓ Gradual migration from old to new API versions"
echo "  ✓ Test new API versions before making them default"
echo "  ✓ Support different versions in different environments"
echo ""
echo "Comparison with old CLI:"
echo "  Old CLI: Only default version, --force required for others, no help"
echo "  Plugin CLI: All versions supported, easy switching, complete help"
