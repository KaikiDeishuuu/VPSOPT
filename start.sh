#!/bin/bash

# VPS优化脚本 - 一键启动
# 作者: Kaiki
# 版本: v2.1

echo "========================================"
echo "    VPS服务器优化脚本 v2.1"
echo "    作者: Kaiki"
echo "========================================"
echo ""

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
    echo "错误: 此脚本需要root权限运行"
    echo "请使用: sudo ./start.sh"
    exit 1
fi

# 检测系统架构
ARCH=$(uname -m)
echo "检测到系统架构: $ARCH"
echo ""

# 根据架构选择脚本
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo "检测到 ARM64 架构"
    echo ""
    echo "请选择要使用的脚本:"
    echo "1) ARM64 专用版 (推荐，包含ARM64优化)"
    echo "2) 通用版本"
    echo "3) 退出"
    read -p "请输入选项 [1-3]: " choice
    
    case $choice in
        1)
            SCRIPT="vps_optimize_arm64.sh"
            echo ""
            echo "使用 ARM64 专用版本"
            ;;
        2)
            SCRIPT="vps_optimize.sh"
            echo ""
            echo "使用通用版本"
            ;;
        3)
            echo "退出"
            exit 0
            ;;
        *)
            echo "无效选项，使用 ARM64 专用版本"
            SCRIPT="vps_optimize_arm64.sh"
            ;;
    esac
else
    # x86_64 架构直接使用通用版本
    SCRIPT="vps_optimize.sh"
fi

# 检查脚本是否存在
if [ ! -f "./$SCRIPT" ]; then
    echo "错误: 找不到 $SCRIPT"
    echo "请确保在正确的目录中运行此脚本"
    exit 1
fi

# 赋予执行权限
chmod +x "$SCRIPT"

echo ""
echo "正在启动: $SCRIPT"
echo ""
sleep 1

# 运行脚本
./"$SCRIPT"
