# ⚡ ARM64 快速参考

> VPS 优化脚本 ARM64 专用版快速指南

---

## 🚀 快速开始

```bash
# 下载并运行 ARM64 版本
wget https://raw.githubusercontent.com/KaikiDeishuuu/VPSOPT/main/vps_optimize_arm64.sh
chmod +x vps_optimize_arm64.sh
sudo ./vps_optimize_arm64.sh

# 或使用 start.sh (自动检测架构)
chmod +x start.sh
sudo ./start.sh
```

---

## 📋 支持的设备

| 设备类型 | 架构 | 系统要求 | 状态 |
|---------|------|----------|------|
| 树莓派 4/5 | ARM64 | Debian 12 / Ubuntu 22.04+ | ✅ 完全支持 |
| 甲骨文云 ARM | Ampere Altra | Debian 12 / Ubuntu 22.04+ | ✅ 完全支持 |
| AWS Graviton | ARM64 | Amazon Linux / Ubuntu | ✅ 完全支持 |
| Azure ARM | Ampere Altra | Ubuntu Server | ✅ 完全支持 |
| Google Cloud | Tau T2A | Debian / Ubuntu | ✅ 完全支持 |

---

## 🎯 功能对比

| 功能 | 通用版本 | ARM64版本 | 说明 |
|------|---------|----------|------|
| 基础优化 | ✅ | ✅ | 完全相同 |
| Docker | ✅ | ✅ | ARM64 镜像 |
| Nginx | ✅ | ✅ | 完全支持 |
| Cloudflare Tunnel | ✅ | ✅ | 自动适配 |
| Cloudflare WARP | ✅ | ✅ | wgcf 方式 |
| 网络优化 | ✅ | ✅ | 完全支持 |
| **温度监控** | ❌ | ✅ | ARM64 专属 |
| **性能调优** | ⚠️ | ✅ | ARM64 专属 |
| **内存优化** | ⚠️ | ✅ | 自适应 |

---

## 🔧 ARM64 特有功能

### 1. 温度监控

```bash
# 查看 CPU 温度
/usr/local/bin/temp_monitor.sh

# 或直接读取
cat /sys/class/thermal/thermal_zone0/temp
# 输出单位: 毫摄氏度 (除以1000得到摄氏度)

# 示例输出
# 45000 = 45°C
```

### 2. 性能优化参数

```bash
# 查看优化参数
sysctl -a | grep sched

# ARM64 专属参数
kernel.sched_latency_ns = 6000000
kernel.sched_min_granularity_ns = 750000
kernel.sched_wakeup_granularity_ns = 1000000
kernel.sched_energy_aware = 1
```

### 3. 内存自适应

| 内存大小 | Swappiness | 说明 |
|---------|-----------|------|
| < 2GB | 10 | 小内存设备 |
| ≥ 2GB | 3 | 标准配置 |

---

## 🐳 Docker ARM64

### 常用镜像

```bash
# 基础镜像
docker pull arm64v8/ubuntu
docker pull arm64v8/debian
docker pull arm64v8/alpine

# 应用镜像
docker pull arm64v8/nginx
docker pull arm64v8/python
docker pull arm64v8/node
docker pull arm64v8/mysql
docker pull arm64v8/redis
docker pull arm64v8/postgres

# 运行容器
docker run --platform linux/arm64 -d arm64v8/nginx
```

### Dockerfile 示例

```dockerfile
# 指定 ARM64 平台
FROM arm64v8/ubuntu:22.04

# 或使用多架构支持
FROM --platform=linux/arm64 ubuntu:22.04

RUN apt-get update && \
    apt-get install -y nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose

```yaml
version: '3'
services:
  web:
    image: arm64v8/nginx
    platform: linux/arm64
    ports:
      - "80:80"
```

---

## 🌡️ 温度管理

### 温度阈值

| 温度范围 | 状态 | 建议 |
|---------|------|------|
| < 60°C | 正常 | 无需操作 |
| 60-75°C | 警告 | 检查散热 |
| > 75°C | 过热 | 立即处理 |

### 散热建议

**树莓派:**
- 使用散热片
- 添加风扇
- 确保通风良好
- 避免密闭空间

**云服务器:**
- 降低 CPU 使用率
- 减少并发进程
- 监控告警
- 联系技术支持

### 监控脚本

```bash
# 创建定时监控
cat > /usr/local/bin/temp_alert.sh <<'EOF'
#!/bin/bash
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
TEMP_C=$((TEMP / 1000))

if [ $TEMP_C -gt 75 ]; then
    echo "警告: CPU温度过高 ${TEMP_C}°C" | wall
    # 可以添加邮件通知
fi
EOF

chmod +x /usr/local/bin/temp_alert.sh

# 添加定时任务 (每5分钟检查一次)
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/temp_alert.sh") | crontab -
```

---

## 🌐 Cloudflare 支持

### Tunnel 安装

```bash
# ARM64 自动安装
sudo ./vps_optimize_arm64.sh
# 选择: 4 → Cloudflare Tunnel

# 手动下载 ARM64 版本
curl -fsSL https://pkg.cloudflare.com/cloudflared-stable-linux-arm64.deb -o cloudflared.deb
dpkg -i cloudflared.deb
```

### WARP 配置

```bash
# 推荐使用 wgcf 方式 (ARM64 兼容性更好)
sudo ./vps_optimize_arm64.sh
# 选择: 4 → WARP → wgcf方式

# 手动安装 wgcf
WGCF_VERSION="v2.2.18"
wget "https://github.com/ViRb3/wgcf/releases/download/${WGCF_VERSION}/wgcf_2.2.18_linux_arm64" -O /usr/local/bin/wgcf
chmod +x /usr/local/bin/wgcf
```

---

## 📊 性能优化

### CPU 调度器

```bash
# 查看当前调度器
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# 设置性能模式 (高性能)
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 设置节能模式
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 设置按需模式 (推荐)
echo ondemand | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### 内存优化

```bash
# 查看当前配置
sysctl vm.swappiness
sysctl vm.vfs_cache_pressure

# ARM64 推荐值
sysctl -w vm.swappiness=3
sysctl -w vm.vfs_cache_pressure=50
sysctl -w vm.dirty_background_ratio=5
sysctl -w vm.dirty_ratio=10
```

---

## 🔍 故障排查

### 常见问题

#### 1. 脚本提示架构不支持

```bash
# 检查架构
uname -m
# 应该输出: aarch64 或 arm64

# 如果是 armv7l (32位)
echo "请使用 64 位系统"
```

#### 2. Docker 镜像拉取失败

```bash
# 确认使用 ARM64 镜像
docker pull arm64v8/镜像名

# 或指定平台
docker pull --platform linux/arm64 镜像名

# 检查镜像架构
docker inspect 镜像名 | grep Architecture
```

#### 3. 温度读取失败

```bash
# 检查传感器
ls /sys/class/thermal/

# 尝试其他温度源
sensors
vcgencmd measure_temp  # 树莓派专用
```

#### 4. 性能不佳

```bash
# 检查 CPU 频率
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

# 检查进程
htop
top

# 检查内存
free -h
```

---

## 📝 快速命令

```bash
# 系统信息
uname -a                    # 完整系统信息
cat /proc/cpuinfo          # CPU 详细信息
free -h                    # 内存使用
df -h                      # 磁盘使用

# 温度监控
/usr/local/bin/temp_monitor.sh
cat /sys/class/thermal/thermal_zone0/temp

# Docker ARM64
docker pull arm64v8/镜像名
docker run --platform linux/arm64 镜像名

# Cloudflare
cloudflared tunnel run mytunnel
wg-quick up wgcf

# 网络优化
speedtest-cli              # 测速
mtr google.com            # 路由追踪
```

---

## 💡 最佳实践

### 树莓派部署

1. **使用 64 位系统**
   - Raspberry Pi OS (64-bit)
   - Ubuntu Server 22.04 ARM64

2. **添加散热装置**
   - 散热片 + 风扇
   - 保持通风

3. **使用高质量电源**
   - 官方电源适配器
   - 稳定供电很重要

4. **SD 卡选择**
   - A2 级别 SD 卡
   - 或使用 USB SSD

### 云服务器优化

1. **选择合适实例**
   - 甲骨文: VM.Standard.A1.Flex
   - AWS: t4g 系列
   - Azure: Dpsv5 系列

2. **配置监控告警**
   - CPU 使用率
   - 内存使用率
   - 温度告警

3. **定期维护**
   - 系统更新
   - 日志清理
   - 性能检查

---

## 🆘 获取帮助

- 📖 [完整文档](../README.md)
- 🌐 [网络优化指南](NETWORK_OPTIMIZATION.md)
- 📝 [更新日志](CHANGELOG.md)
- 💡 [使用示例](EXAMPLES.md)

---

**ARM64 优化，性能倍增！** 🚀
