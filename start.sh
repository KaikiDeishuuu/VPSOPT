#!/bin/bash

# VPS优化脚本 - 一键启动
# 作者: Kaiki
# 版本: v2.0

echo "========================================"
echo "    VPS服务器优化脚本 v2.0"
echo "    作者: Kaiki"
echo "========================================"
echo ""

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
    echo "错误: 此脚本需要root权限运行"
    echo "请使用: sudo ./start.sh"
    exit 1
fi

# 检查主脚本是否存在
if [ ! -f "./vps_optimize.sh" ]; then
    echo "错误: 找不到 vps_optimize.sh"
    echo "请确保在正确的目录中运行此脚本"
    exit 1
fi

# 赋予执行权限
chmod +x vps_optimize.sh

echo "正在启动VPS优化脚本..."
echo ""

# 运行主脚本
./vps_optimize.sh
