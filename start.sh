#!/bin/bash

# VPS优化脚本 - 一键启动 (重构版)
# 作者: Kaiki
# 版本: v2.2

echo "========================================"
echo "    VPS服务器优化脚本 v2.2"
echo "    重构版 - 模块化设计"
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

# 检查新版本脚本是否存在
if [ -f "./vps_optimize_new.sh" ]; then
    echo "发现重构版脚本，使用新版本..."
    echo ""
    chmod +x "./vps_optimize_new.sh"
    exec "./vps_optimize_new.sh"
else
    echo "错误: 未找到重构版脚本 (vps_optimize_new.sh)"
    echo "请确保所有文件都已正确安装"
    exit 1
fi
