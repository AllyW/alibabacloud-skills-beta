#!/bin/bash
# Function Compute Plugin Command Examples

set -e

echo "=== Function Compute Plugin Examples ==="
echo ""

# 1. List functions
echo "1. List all functions:"
echo "   aliyun fc list-functions"
echo ""

# 2. Get function details
echo "2. Get function details:"
echo "   aliyun fc get-function --function-name my-function"
echo ""

# 3. Create function (structured body parameters)
echo "3. Create function with structured parameters:"
echo "   aliyun fc create-function \\"
echo "     --function-name my-python-func \\"
echo "     --runtime python3.9 \\"
echo "     --handler index.handler \\"
echo "     --memory-size 512 \\"
echo "     --timeout 60 \\"
echo "     --description 'My Python function' \\"
echo "     --environment-variables KEY1=value1 KEY2=value2 \\"
echo "     --code zipFile=@./function.zip"
echo ""

# 4. Update function
echo "4. Update function configuration:"
echo "   aliyun fc update-function \\"
echo "     --function-name my-python-func \\"
echo "     --memory-size 1024 \\"
echo "     --timeout 120 \\"
echo "     --environment-variables KEY1=new_value1 KEY2=new_value2"
echo ""

# 5. Invoke function (with header parameters)
echo "5. Invoke function synchronously:"
echo "   aliyun fc invoke-function \\"
echo "     --function-name my-python-func \\"
echo "     --x-fc-invocation-type Sync \\"
echo "     --x-fc-log-type Tail \\"
echo "     --body '{\"key\":\"value\"}'"
echo ""

# 6. Invoke function asynchronously
echo "6. Invoke function asynchronously:"
echo "   aliyun fc invoke-function \\"
echo "     --function-name my-python-func \\"
echo "     --x-fc-invocation-type Async \\"
echo "     --body '{\"key\":\"value\"}'"
echo ""

# 7. Create trigger
echo "7. Create OSS trigger:"
echo "   aliyun fc create-trigger \\"
echo "     --function-name my-python-func \\"
echo"     --trigger-name oss-trigger \\"
echo "     --trigger-type oss \\"
echo "     --trigger-config '{\"events\":[\"oss:ObjectCreated:*\"],\"filter\":{\"key\":{\"prefix\":\"source/\",\"suffix\":\".jpg\"}}}'"
echo ""

# 8. List triggers
echo "8. List function triggers:"
echo "   aliyun fc list-triggers --function-name my-python-func"
echo ""

# 9. Create alias
echo "9. Create function alias:"
echo "   aliyun fc create-alias \\"
echo "     --function-name my-python-func \\"
echo "     --alias-name prod \\"
echo "     --version-id 1 \\"
echo "     --description 'Production alias'"
echo ""

# 10. Publish function version
echo "10. Publish function version:"
echo "    aliyun fc publish-function-version \\"
echo "      --function-name my-python-func \\"
echo "      --description 'Version 1.0.0'"
echo ""

# 11. List function versions
echo "11. List function versions:"
echo "    aliyun fc list-function-versions --function-name my-python-func"
echo ""

# 12. Create custom domain
echo "12. Create custom domain:"
echo "    aliyun fc create-custom-domain \\"
echo "      --domain-name api.example.com \\"
echo "      --protocol HTTP \\"
echo "      --route-config '{\"routes\":[{\"path\":\"/api/*\",\"functionName\":\"my-python-func\"}]}'"
echo ""

# 13. Update function code
echo "13. Update function code:"
echo "    aliyun fc update-function \\"
echo "      --function-name my-python-func \\"
echo "      --code zipFile=@./new-code.zip"
echo ""

# 14. Delete function
echo "14. Delete function:"
echo "    aliyun fc delete-function --function-name my-python-func"
echo ""

# 15. Debug mode
echo "15. Run with debug logging:"
echo "    aliyun fc list-functions --log-level=debug"
echo ""

echo "=== End of Examples ==="
echo ""
echo "Key differences from old CLI:"
echo "  1. Body parameters are flattened: --function-name, --runtime, etc."
echo "  2. Header parameters are visible: --x-fc-invocation-type"
echo "  3. All parameters use kebab-case: --function-name (not --FunctionName)"
echo ""
echo "Remember to:"
echo "  1. Install the plugin: aliyun plugin install --names fc"
echo "  2. Configure credentials: aliyun configure"
