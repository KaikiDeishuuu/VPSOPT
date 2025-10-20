#!/bin/bash

################################################################################
# VPS 优化脚本 - 语言与时间配置测试
# 用于验证新功能是否正常工作
################################################################################

echo "================================"
echo "VPS 优化脚本 - 功能测试"
echo "================================"
echo ""

echo "📋 测试项目："
echo "1. 系统语言配置功能（功能 6）"
echo "2. 时间同步配置功能（功能 7）"
echo "3. ARM64 版本语言时间配置"
echo ""

echo "🔍 检查脚本文件..."
echo ""

# 检查主脚本
if [ -f "vps_optimize.sh" ]; then
    echo "✅ 主脚本存在: vps_optimize.sh"
    
    # 检查 setup_locale 函数
    if grep -q "setup_locale()" vps_optimize.sh; then
        echo "  ✅ setup_locale 函数已添加"
    else
        echo "  ❌ setup_locale 函数未找到"
    fi
    
    # 检查菜单项
    if grep -q "系统语言配置" vps_optimize.sh; then
        echo "  ✅ 语言配置菜单项已添加"
    else
        echo "  ❌ 语言配置菜单项未找到"
    fi
    
    # 检查时区增强
    if grep -q "America/New_York" vps_optimize.sh; then
        echo "  ✅ 新增时区选项已添加"
    else
        echo "  ❌ 新增时区选项未找到"
    fi
else
    echo "❌ 主脚本不存在"
fi

echo ""

# 检查 ARM64 脚本
if [ -f "vps_optimize_arm64.sh" ]; then
    echo "✅ ARM64脚本存在: vps_optimize_arm64.sh"
    
    # 检查菜单项
    if grep -q "语言与时间配置" vps_optimize_arm64.sh; then
        echo "  ✅ 语言时间配置菜单项已添加"
    else
        echo "  ❌ 语言时间配置菜单项未找到"
    fi
else
    echo "❌ ARM64脚本不存在"
fi

echo ""

# 检查文档
echo "📚 检查文档文件..."
echo ""

if [ -f "docs/LOCALE_TIME_GUIDE.md" ]; then
    echo "✅ 语言时间配置指南已创建"
else
    echo "❌ 语言时间配置指南未找到"
fi

if [ -f "docs/LOCALE_TIME_UPDATE.md" ]; then
    echo "✅ 更新说明文档已创建"
else
    echo "❌ 更新说明文档未找到"
fi

if grep -q "语言与时间配置" README.md 2>/dev/null; then
    echo "✅ README 已更新"
else
    echo "⚠️  README 可能未更新"
fi

echo ""
echo "================================"
echo "测试完成"
echo "================================"
echo ""

echo "📝 功能说明："
echo ""
echo "1. 系统语言配置（功能 6）"
echo "   - 支持简体中文、英语、繁体中文、日语"
echo "   - 自定义 Locale 支持"
echo "   - 自动配置系统环境"
echo ""
echo "2. 时间同步配置（功能 7）"
echo "   - 新增美国、英国等时区"
echo "   - 支持自定义时区"
echo "   - 国内外 NTP 服务器选项"
echo ""
echo "3. ARM64 版本支持"
echo "   - 完整语言时间配置功能"
echo "   - 集成在菜单选项 3"
echo ""

echo "🚀 使用方法："
echo ""
echo "通用版本："
echo "  sudo ./vps_optimize.sh"
echo "  选择: 6) 系统语言配置"
echo "  选择: 7) 时间同步配置"
echo ""
echo "ARM64 版本："
echo "  sudo ./vps_optimize_arm64.sh"
echo "  选择: 3) 语言与时间配置"
echo ""

