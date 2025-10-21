#!/bin/bash

################################################################################
# VPS优化脚本 - 测试脚本
# 用于验证重构后的功能是否正常
################################################################################

echo "================================"
echo "VPS 优化脚本 - 重构版测试"
echo "================================"
echo ""

# 测试项目
tests=(
    "脚本文件存在性"
    "脚本语法检查"
    "模块加载测试"
    "配置加载测试"
    "函数可用性测试"
)

total_tests=${#tests[@]}
passed=0

echo "开始测试..."
echo ""

# 1. 检查脚本文件
echo "1. 检查脚本文件..."
if [ -f "vps_optimize_new.sh" ]; then
    echo "   ✅ 主脚本存在"
    ((passed++))
else
    echo "   ❌ 主脚本不存在"
fi

if [ -f "lib/common.sh" ]; then
    echo "   ✅ 公共库存在"
    ((passed++))
else
    echo "   ❌ 公共库不存在"
fi

if [ -f "config/default.conf" ]; then
    echo "   ✅ 配置文件存在"
    ((passed++))
else
    echo "   ❌ 配置文件不存在"
fi

if [ -f "modules/base.sh" ]; then
    echo "   ✅ 基础模块存在"
    ((passed++))
else
    echo "   ❌ 基础模块不存在"
fi

# 检查ARM64模块
if [ -f "modules/arm64.sh" ]; then
    echo "   ✅ ARM64模块存在"
    ((passed++))
else
    echo "   ❌ ARM64模块不存在"
fi

echo ""

# 2. 语法检查
echo "2. 语法检查..."
if bash -n vps_optimize_new.sh 2>/dev/null; then
    echo "   ✅ 主脚本语法正确"
    ((passed++))
else
    echo "   ❌ 主脚本语法错误"
fi

if bash -n lib/common.sh 2>/dev/null; then
    echo "   ✅ 公共库语法正确"
    ((passed++))
else
    echo "   ❌ 公共库语法错误"
fi

if bash -n modules/base.sh 2>/dev/null; then
    echo "   ✅ 基础模块语法正确"
    ((passed++))
else
    echo "   ❌ 基础模块语法错误"
fi

if bash -n modules/arm64.sh 2>/dev/null; then
    echo "   ✅ ARM64模块语法正确"
    ((passed++))
else
    echo "   ❌ ARM64模块语法错误"
fi

echo ""

# 3. 模块加载测试
echo "3. 模块加载测试..."
if source lib/common.sh 2>/dev/null && source config/default.conf 2>/dev/null; then
    echo "   ✅ 公共库和配置加载成功"
    ((passed++))
else
    echo "   ❌ 公共库和配置加载失败"
fi

if source modules/base.sh 2>/dev/null; then
    echo "   ✅ 基础模块加载成功"
    ((passed++))
else
    echo "   ❌ 基础模块加载失败"
fi

# 检测架构并测试ARM64模块
ARCH=$(uname -m)
echo "   检测到架构: $ARCH"

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    if source modules/arm64.sh 2>/dev/null; then
        echo "   ✅ ARM64模块加载成功"
        ((passed++))
    else
        echo "   ❌ ARM64模块加载失败"
    fi
else
    echo "   非ARM64架构，跳过ARM64模块测试"
fi

echo ""

# 4. 函数测试
echo "4. 函数可用性测试..."
if command -v log_info >/dev/null 2>&1; then
    echo "   ✅ log_info 函数可用"
    ((passed++))
else
    echo "   ❌ log_info 函数不可用"
fi

if command -v show_header >/dev/null 2>&1; then
    echo "   ✅ show_header 函数可用"
    ((passed++))
else
    echo "   ❌ show_header 函数不可用"
fi

if command -v check_root >/dev/null 2>&1; then
    echo "   ✅ check_root 函数可用"
    ((passed++))
else
    echo "   ❌ check_root 函数不可用"
fi

# 测试ARM64函数（如果适用）
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    if command -v detect_arm64_architecture >/dev/null 2>&1; then
        echo "   ✅ ARM64架构检测函数可用"
        ((passed++))
    else
        echo "   ❌ ARM64架构检测函数不可用"
    fi
fi

echo ""

# 5. 配置测试
echo "5. 配置测试..."
if [ -n "$SCRIPT_NAME" ]; then
    echo "   ✅ 脚本名称配置正确: $SCRIPT_NAME"
    ((passed++))
else
    echo "   ❌ 脚本名称配置缺失"
fi

if [ -n "$SCRIPT_VERSION" ]; then
    echo "   ✅ 脚本版本配置正确: $SCRIPT_VERSION"
    ((passed++))
else
    echo "   ❌ 脚本版本配置缺失"
fi

echo ""

# 测试结果
echo "================================"
echo "测试结果: $passed/$total_tests 通过"
echo "================================"

if [ $passed -eq $total_tests ]; then
    echo "🎉 所有测试通过！重构版脚本准备就绪。"
    echo ""
    echo "使用方法："
    echo "  sudo ./start.sh          # 启动脚本（自动检测新版本）"
    echo "  sudo ./vps_optimize_new.sh  # 直接运行新版本"
else
    echo "⚠️  部分测试失败，请检查上述错误。"
fi

echo ""
echo "重构改进："
echo "  ✅ 消除重复代码（颜色定义、日志函数等）"
echo "  ✅ 模块化设计（公共库 + 功能模块）"
echo "  ✅ 统一配置管理"
echo "  ✅ 增强错误处理和输入验证"
echo "  ✅ 改进用户界面和交互"
echo "  ✅ 更好的可维护性和扩展性"