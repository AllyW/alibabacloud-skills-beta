#!/bin/bash
# ECS Plugin Command Examples

# Note: Replace placeholder values before running

set -e

echo "=== ECS Plugin Examples ==="
echo ""

# 1. List instances
echo "1. List all ECS instances in a region:"
echo "   aliyun ecs describe-instances --region-id cn-hangzhou"
echo ""

# 2. List instances with specific status
echo "2. List running instances:"
echo "   aliyun ecs describe-instances \\"
echo "     --region-id cn-hangzhou \\"
echo "     --status Running"
echo ""

# 3. Get specific instance details
echo "3. Get details of specific instances:"
echo "   aliyun ecs describe-instances \\"
echo "     --region-id cn-hangzhou \\"
echo "     --instance-id i-abc123 \\"
echo "     --instance-id i-def456"
echo ""

# 4. Filter instances by tags
echo "4. Filter instances by tags:"
echo "   aliyun ecs describe-instances \\"
echo "     --region-id cn-hangzhou \\"
echo "     --tag key=env value=prod"
echo ""

# 5. Create instance with structured parameters
echo "5. Create instance with tags and disks:"
echo "   aliyun ecs create-instance \\"
echo "     --region-id cn-hangzhou \\"
echo "     --instance-type ecs.g6.large \\"
echo "     --image-id ubuntu_20_04_x64 \\"
echo "     --security-group-id sg-abc123 \\"
echo "     --v-switch-id vsw-abc123 \\"
echo "     --system-disk category=cloud_essd size=40 \\"
echo "     --data-disk category=cloud_essd size=100 \\"
echo "     --data-disk category=cloud_ssd size=200 \\"
echo "     --tag key=env value=prod \\"
echo "     --tag key=app value=web"
echo ""

# 6. Start instance
echo "6. Start an instance:"
echo "   aliyun ecs start-instance --instance-id i-abc123"
echo ""

# 7. Stop instance
echo "7. Stop an instance (gracefully):"
echo "   aliyun ecs stop-instance \\"
echo "     --instance-id i-abc123 \\"
echo "     --force-stop false"
echo ""

# 8. Reboot instance
echo "8. Reboot an instance:"
echo "   aliyun ecs reboot-instance --instance-id i-abc123"
echo ""

# 9. Query with output formatting
echo "9. List instances with custom output columns:"
echo "   aliyun ecs describe-instances \\"
echo "     --region-id cn-hangzhou \\"
echo "     --output cols=InstanceId,InstanceName,Status,PublicIpAddress"
echo ""

# 10. Query with JMESPath
echo "10. Filter output with JMESPath query:"
echo "    aliyun ecs describe-instances \\"
echo "      --region-id cn-hangzhou \\"
echo "      --query \"Instances.Instance[?Status=='Running'].{ID:InstanceId,Name:InstanceName}\""
echo ""

# 11. Modify instance attributes
echo "11. Modify instance name and description:"
echo "    aliyun ecs modify-instance-attribute \\"
echo "      --instance-id i-abc123 \\"
echo "      --instance-name my-web-server \\"
echo "      --description 'Production web server'"
echo ""

# 12. Debug mode
echo "12. Run command with debug logging:"
echo "    aliyun ecs describe-instances \\"
echo "      --region-id cn-hangzhou \\"
echo "      --log-level=debug"
echo ""

echo "=== End of Examples ==="
echo ""
echo "Remember to:"
echo "  1. Install the plugin: aliyun plugin install --names ecs"
echo "  2. Configure credentials: aliyun configure"
echo "  3. Replace placeholder values (region-id, instance-id, etc.)"
