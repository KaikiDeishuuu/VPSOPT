# 🌐 网络优化工具使用指南

> VPS 优化脚本 v2.1 网络功能详细说明

---

## 📚 目录

1. [Cloudflare Tunnel](#cloudflare-tunnel)
2. [Cloudflare WARP](#cloudflare-warp)
3. [网络优化工具集](#网络优化工具集)
4. [ARM64 支持说明](#arm64-支持说明)
5. [常见问题](#常见问题)

---

## ☁️ Cloudflare Tunnel

### 功能介绍

Cloudflare Tunnel 允许您在不暴露公网IP的情况下，安全地将本地服务暴露到互联网。

### 主要特性

- ✅ 无需公网IP或端口转发
- ✅ 自动HTTPS加密
- ✅ 内置DDoS防护
- ✅ 全球CDN加速
- ✅ 支持多种协议 (HTTP/HTTPS/SSH/RDP等)
- ✅ 完整支持 x86_64 和 ARM64 架构

### 安装方式

#### 1. 使用脚本安装

```bash
# 通用版本
sudo ./vps_optimize.sh
# 选择: 16

# ARM64版本
sudo ./vps_optimize_arm64.sh
# 选择: 4 → Cloudflare Tunnel
```

#### 2. 配置选项

**选项 1: 快速配置** (推荐新手)
- 通过浏览器登录 Cloudflare 账户
- 图形化界面操作
- 适合第一次使用

**选项 2: 手动配置** (适合高级用户)
- 使用已有的 Tunnel Token
- 自动创建 systemd 服务
- 适合批量部署

**选项 3: 仅安装**
- 只安装 cloudflared
- 稍后手动配置
- 适合自定义需求

### 使用步骤

#### 快速配置流程

1. **登录 Cloudflare**
```bash
cloudflared tunnel login
```
这会打开浏览器，授权访问您的 Cloudflare 账户

2. **创建隧道**
```bash
cloudflared tunnel create mytunnel
```
记下生成的 Tunnel ID

3. **配置路由**
```bash
cloudflared tunnel route dns mytunnel example.com
```
将域名 example.com 路由到隧道

4. **创建配置文件**
```bash
mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml <<EOF
tunnel: <Tunnel-ID>
credentials-file: /root/.cloudflared/<Tunnel-ID>.json

ingress:
  - hostname: example.com
    service: http://localhost:8080
  - service: http_status:404
EOF
```

5. **运行隧道**
```bash
cloudflared tunnel run mytunnel
```

#### 使用 Token 快速部署

如果您已经有 Tunnel Token：

```bash
# 手动运行
cloudflared tunnel run --token <YOUR_TOKEN>

# 或使用脚本自动创建服务
sudo ./vps_optimize.sh
# 选择: 16 → 2 → 输入Token
```

### 实用示例

#### 示例 1: 暴露 Web 服务

```yaml
# ~/.cloudflared/config.yml
tunnel: abc123...
credentials-file: /root/.cloudflared/abc123.json

ingress:
  - hostname: blog.example.com
    service: http://localhost:80
  - hostname: api.example.com
    service: http://localhost:3000
  - service: http_status:404
```

#### 示例 2: SSH 访问

```yaml
ingress:
  - hostname: ssh.example.com
    service: ssh://localhost:22
  - service: http_status:404
```

#### 示例 3: 多服务代理

```yaml
ingress:
  - hostname: www.example.com
    service: http://localhost:80
  - hostname: app.example.com
    service: http://localhost:8080
  - hostname: ws.example.com
    service: ws://localhost:9000
  - service: http_status:404
```

### 服务管理

```bash
# 查看服务状态
systemctl status cloudflared

# 启动服务
systemctl start cloudflared

# 停止服务
systemctl stop cloudflared

# 重启服务
systemctl restart cloudflared

# 查看日志
journalctl -u cloudflared -f
```

---

## 🔒 Cloudflare WARP

### 功能介绍

Cloudflare WARP 基于 WireGuard 协议，提供快速、安全的网络连接。

### 主要特性

- ✅ 加速国际网络访问
- ✅ 隐藏真实 IP 地址
- ✅ 基于 WireGuard 协议
- ✅ 免费使用
- ✅ 支持两种安装方式

### 安装方式

#### 方式 1: 官方客户端 (推荐)

**系统要求:**
- Ubuntu 20.04+ 或 Debian 11+
- x86_64 架构

**使用脚本安装:**
```bash
sudo ./vps_optimize.sh
# 选择: 17 → 1
```

**手动安装:**
```bash
# 添加仓库
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

# 安装
apt update
apt install cloudflare-warp

# 注册和连接
warp-cli register
warp-cli connect
```

#### 方式 2: wgcf + WireGuard (通用)

**系统要求:**
- 任何 Debian/Ubuntu 系统
- 支持 x86_64 和 ARM64

**使用脚本安装:**
```bash
# 通用版本
sudo ./vps_optimize.sh
# 选择: 17 → 2

# ARM64版本
sudo ./vps_optimize_arm64.sh
# 选择: 4 → WARP → 2
```

### 使用方法

#### 官方客户端命令

```bash
# 注册账户
warp-cli register

# 连接 WARP
warp-cli connect

# 断开连接
warp-cli disconnect

# 查看状态
warp-cli status

# 查看设置
warp-cli settings

# 启用/禁用
warp-cli enable-always-on
warp-cli disable-always-on
```

#### wgcf 方式命令

```bash
# 启用 WARP
wg-quick up wgcf

# 停止 WARP
wg-quick down wgcf

# 查看状态
wg show

# 开机自启
systemctl enable wg-quick@wgcf

# 禁用自启
systemctl disable wg-quick@wgcf
```

### 测试 WARP 连接

```bash
# 查看当前 IP
curl ip.sb

# 查看 Cloudflare 连接信息
curl https://www.cloudflare.com/cdn-cgi/trace/
```

### 故障排查

#### 无法连接

```bash
# 检查服务状态
systemctl status wg-quick@wgcf

# 查看日志
journalctl -u wg-quick@wgcf

# 重新生成配置
cd /etc/wireguard
wgcf register
wgcf generate
```

#### 网络冲突

如果 WARP 与现有网络冲突：

```bash
# 修改 MTU
ip link set wgcf mtu 1420

# 或编辑配置文件
nano /etc/wireguard/wgcf.conf
# 添加: MTU = 1420
```

---

## 🌐 网络优化工具集

### DNS 优化

#### 支持的 DNS 服务商

| 服务商 | 主DNS | 备用DNS | 推荐地区 |
|--------|-------|---------|----------|
| Cloudflare | 1.1.1.1 | 1.0.0.1 | 国际 |
| Google | 8.8.8.8 | 8.8.4.4 | 国际 |
| 阿里云 | 223.5.5.5 | 223.6.6.6 | 中国 |
| 腾讯云 | 119.29.29.29 | 182.254.116.116 | 中国 |
| 自定义 | - | - | - |

#### 使用方法

```bash
# 使用脚本配置
sudo ./vps_optimize.sh
# 选择: 18 → 1

# 手动配置
cat > /etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
options timeout:2
options attempts:3
EOF

# 锁定配置防止被覆盖
chattr +i /etc/resolv.conf

# 解锁
chattr -i /etc/resolv.conf
```

#### 测试 DNS

```bash
# 测试解析速度
nslookup google.com
dig google.com

# 测试多个DNS
dig @1.1.1.1 google.com
dig @8.8.8.8 google.com
dig @223.5.5.5 google.com
```

### MTU 优化

#### MTU 值建议

- **PPPoE 连接:** 1492
- **标准以太网:** 1500 (默认)
- **Jumbo 帧:** 9000 (局域网)
- **VPN/隧道:** 1400-1450

#### 使用方法

```bash
# 使用脚本配置
sudo ./vps_optimize.sh
# 选择: 18 → 2

# 手动检测最佳MTU
ping -M do -s 1472 -c 4 google.com
# 如果成功，MTU = 1472 + 28 = 1500
# 如果失败，减小数值重试

# 临时设置
ip link set eth0 mtu 1450

# 永久设置 (systemd-networkd)
cat > /etc/systemd/network/10-mtu.link <<EOF
[Match]
Name=eth0

[Link]
MTUBytes=1450
EOF
```

### TCP Fast Open

#### 功能说明

TCP Fast Open (TFO) 可以减少 TCP 连接建立时间，加速网络连接。

#### 配置说明

```
值 | 说明
---|-----
0  | 禁用
1  | 仅作为客户端
2  | 仅作为服务器
3  | 客户端和服务器 (推荐)
```

#### 使用方法

```bash
# 使用脚本配置
sudo ./vps_optimize.sh
# 选择: 18 → 3

# 手动配置
sysctl -w net.ipv4.tcp_fastopen=3

# 永久保存
echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.d/99-custom.conf
sysctl -p /etc/sysctl.d/99-custom.conf
```

### 网络诊断工具

#### mtr - 路由追踪

```bash
# 基本用法
mtr google.com

# 显示IP地址
mtr -n google.com

# 报告模式
mtr -r -c 10 google.com
```

#### iperf3 - 带宽测试

```bash
# 服务器端
iperf3 -s

# 客户端测试
iperf3 -c SERVER_IP

# 双向测试
iperf3 -c SERVER_IP -d

# 指定时间
iperf3 -c SERVER_IP -t 60
```

#### speedtest-cli - 网速测试

```bash
# 基本测试
speedtest-cli

# 显示服务器列表
speedtest-cli --list

# 指定服务器
speedtest-cli --server 12345

# 简化输出
speedtest-cli --simple
```

#### tcpdump - 数据包分析

```bash
# 捕获所有接口
tcpdump -i any

# 捕获特定端口
tcpdump -i eth0 port 80

# 保存到文件
tcpdump -i eth0 -w capture.pcap

# 读取文件
tcpdump -r capture.pcap
```

---

## 🔧 ARM64 支持说明

### 架构检测

脚本会自动检测系统架构：

```bash
# 支持的架构
- aarch64
- arm64

# 不支持的架构会提示使用通用版本
```

### ARM64 特定功能

#### 1. 温度监控

```bash
# 查看温度
/usr/local/bin/temp_monitor.sh

# 温度传感器位置
cat /sys/class/thermal/thermal_zone0/temp
# 输出单位: 毫摄氏度 (需要除以1000)
```

#### 2. 性能优化

ARM64 专用性能参数：

```bash
# 调度器优化
kernel.sched_latency_ns = 6000000
kernel.sched_min_granularity_ns = 750000
kernel.sched_wakeup_granularity_ns = 1000000

# big.LITTLE 架构支持
kernel.sched_energy_aware = 1

# 内存优化
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.vfs_cache_pressure = 50
```

#### 3. Docker ARM64

```bash
# 拉取 ARM64 镜像
docker pull arm64v8/ubuntu
docker pull arm64v8/nginx
docker pull arm64v8/python

# 运行容器
docker run --platform linux/arm64 arm64v8/ubuntu

# 查看镜像架构
docker inspect arm64v8/ubuntu | grep Architecture
```

### 支持的设备

- ✅ 树莓派 4/5 (64位系统)
- ✅ 甲骨文云 ARM 实例 (Ampere)
- ✅ AWS Graviton 2/3
- ✅ Azure Dpsv5/Epsv5 (Ampere)
- ✅ Google Cloud Tau T2A
- ✅ 其他 ARM64 服务器

---

## ❓ 常见问题

### Cloudflare Tunnel

**Q: 需要域名吗？**  
A: 是的，需要在 Cloudflare 管理的域名。

**Q: 免费吗？**  
A: Cloudflare Tunnel 完全免费使用。

**Q: 支持哪些协议？**  
A: HTTP/HTTPS/WebSocket/SSH/RDP/TCP 等。

**Q: ARM64 支持吗？**  
A: 完全支持，脚本会自动下载对应架构的版本。

### Cloudflare WARP

**Q: WARP 免费吗？**  
A: 基础版本免费，有流量限制。

**Q: 会影响网速吗？**  
A: 通常会略微提升国际访问速度，但可能降低本地访问速度。

**Q: 可以选择节点吗？**  
A: 官方客户端会自动选择最优节点。

**Q: 两种安装方式有什么区别？**  
A: 官方客户端更稳定，wgcf 方式兼容性更好。

### 网络优化

**Q: 修改 DNS 后无法上网？**  
A: 检查 DNS 服务器是否可达，可以临时改回：
```bash
chattr -i /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

**Q: MTU 设置多少合适？**  
A: 大多数情况下 1500 即可，VPN 环境建议 1420-1450。

**Q: TCP Fast Open 有副作用吗？**  
A: 极少数情况可能与某些防火墙不兼容，可以随时关闭。

### ARM64 相关

**Q: 树莓派可以用吗？**  
A: 可以，但建议使用 64 位系统。

**Q: 温度多少算正常？**  
A: 通常 60°C 以下正常，超过 75°C 需要注意散热。

**Q: ARM64 版本功能完整吗？**  
A: 除了少数 x86 专用软件外，大部分功能完全支持。

---

## 📞 获取帮助

- 📖 查看完整文档: [README.md](../README.md)
- 📝 查看更新日志: [CHANGELOG.md](CHANGELOG.md)
- 💡 查看使用示例: [EXAMPLES.md](EXAMPLES.md)
- ⚡ 查看命令速查: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

**感谢使用 VPS 优化脚本！** 🚀
