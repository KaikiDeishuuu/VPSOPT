<div align="center">

# 🚀 VPS 服务器优化脚本

**一键完成 VPS 服务器初始化、安全加固和环境配置**

[![GitHub stars](https://img.shields.io/github/stars/KaikiDeishuuu/VPSOPT?style=social)](https://github.com/KaikiDeishuuu/VPSOPT)
[![GitHub forks](https://img.shields.io/github/forks/KaikiDeishuuu/VPSOPT?style=social)](https://github.com/KaikiDeishuuu/VPSOPT)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v2.2-brightgreen.svg)](https://github.com/KaikiDeishuuu/VPSOPT)

**作者:** [Kaiki](https://github.com/KaikiDeishuuu) | **版本:** v2.2 | **更新:** 2025-10-20

</div>

---

## 📖 简介

这是一个**功能全面、专业强大**的 VPS 服务器一键优化脚本，帮助你快速完成服务器的初始化配置、安全加固和环境部署。

💡 **适用场景**：开发环境、生产环境、测试环境、个人项目、企业部署  
🎯 **核心理念**：简单易用、安全可靠、功能完整、持续更新

---

## � 版本更新

<details open>
<summary><b>�🆕 v2.2 重大更新 (2025-10-20)</b> - 点击展开</summary>

### 新增 10 个高级功能，功能总数扩展至 28+ 项！

#### 🔥 核心新功能

| 功能                | 描述                                   | 亮点         |
| ------------------- | -------------------------------------- | ------------ |
| 📈 **性能基准测试** | Superbench/YABS/bench.sh/UnixBench     | 全面性能评估 |
| 📧 **邮件告警配置** | Gmail/QQ/163/阿里云 SMTP               | 实时系统监控 |
| 🗄️ **数据库部署**   | MySQL/MariaDB/PostgreSQL/Redis/MongoDB | 一键安装配置 |
| 🔧 **开发环境**     | Python/Node.js/Go/Java                 | 版本管理工具 |
| 🌐 **反向代理**     | Nginx 代理助手                         | 向导式配置   |
| 💾 **系统快照**     | Timeshift/rsync                        | 快速备份恢复 |
| 🛡️ **入侵检测**     | AIDE/rkhunter/ClamAV/Lynis             | 多层防护     |
| 📊 **流量监控**     | vnstat/iftop/NetData                   | 实时统计     |
| 📁 **文件同步**     | Syncthing/Rclone                       | 多设备同步   |
| 🔍 **日志分析**     | 智能日志分析工具                       | 异常检测     |

#### ✨ 其他改进

- 🎨 新增扩展功能菜单 (选项 e)
- 📊 优化菜单布局，分类更清晰
- 📦 模块化设计 (vps_extend_functions.sh)
- 📖 新增[全功能使用指南](docs/ALL_FEATURES_GUIDE.md)

</details>

<details>
<summary><b>v2.1 更新内容 (2025-10-19)</b> - 点击展开</summary>

- ✨ 系统语言配置（Locale）- 支持多语言环境
- ✨ 时间同步增强 - 更多时区选项和 NTP 服务器
- ✨ Cloudflare Tunnel 配置 - 无需公网 IP
- ✨ Cloudflare WARP 配置 - 网络加速
- ✨ 网络优化工具集 - DNS/MTU/TCP 优化
- ✨ ARM64 Debian 12 专用版本

</details>

---

## 🚀 快速开始

### 通用版本 (x86_64)

```bash
# 下载脚本
git clone https://github.com/KaikiDeishuuu/VPSOPT.git
cd VPSOPT

# 运行脚本
chmod +x start.sh
sudo ./start.sh
```

### ARM64 专用版本 🆕

```bash
# 适用于: 树莓派、甲骨文ARM、AWS Graviton等ARM64设备

# 运行ARM64专用版本
chmod +x vps_optimize_arm64.sh
sudo ./vps_optimize_arm64.sh
```

或者直接下载：

```bash
# 通用版本
wget https://raw.githubusercontent.com/KaikiDeishuuu/VPSOPT/main/vps_optimize.sh
chmod +x vps_optimize.sh
sudo ./vps_optimize.sh

# ARM64版本
wget https://raw.githubusercontent.com/KaikiDeishuuu/VPSOPT/main/vps_optimize_arm64.sh
chmod +x vps_optimize_arm64.sh
sudo ./vps_optimize_arm64.sh
```

## ✨ 核心功能

<div align="center">

### � 功能总览

|       类别       |  功能数量  | 说明                    |
| :--------------: | :--------: | :---------------------- |
| �🔧 **基础优化** |    9 项    | 系统初始化、安全加固    |
| 🌟 **环境配置**  |   11 项    | Docker、Nginx、工具安装 |
| 🎯 **高级功能**  |    8 项    | 数据库、监控、开发环境  |
|     **总计**     | **28+ 项** | **全方位 VPS 管理**     |

</div>

---

### 🔧 基础优化（功能 1-9）

<table>
<tr>
<td width="50%">

#### 核心安全

- ✅ **换源加速** - 6 个镜像源
- ✅ **账户安全** - 密码/用户/SSH 密钥
- ✅ **SSH 加固** - 端口/防暴力
- ✅ **防火墙** - nftables/iptables
- ✅ **性能优化** - BBR/swap/内核

</td>
<td width="50%">

#### 系统配置

- ✅ **语言配置** - 多语言支持 🆕
- ✅ **时间同步** - 时区/NTP 🆕
- ✅ **安全加固** - Fail2Ban
- ✅ **系统清理** - 缓存/日志

</td>
</tr>
</table>

---

### 🚀 环境配置（功能 10-20）

<table>
<tr>
<td width="50%">

#### 📦 基础环境

- ✨ **Docker** - 一键安装 + 镜像加速
- ✨ **Nginx + SSL** - Web 服务器 + 证书
- ✨ **常用工具** - 监控/网络/开发
- ✨ **自动备份** - 定时备份 + 清理
- ✨ **系统监控** - CPU/内存/磁盘
- ✨ **SSH 优化** - 连接速度提升

</td>
<td width="50%">

#### 🌐 网络增强

- ✨ **BBR V3** ⭐ - 终极网络优化
- ✨ **CF Tunnel** - 无需公网 IP
- ✨ **CF WARP** - 网络加速
- ✨ **网络工具** - DNS/MTU/TCP
- ✨ **性能测试** ⭐🆕 - 全面评估

</td>
</tr>
</table>

---

### 🔥 高级功能（功能 21-28）🆕

<table>
<tr>
<td width="50%">

#### � 监控与告警

**📧 邮件告警配置**

- Gmail/QQ/163/阿里云
- CPU/内存/磁盘监控
- 10 分钟自动检查

**📊 流量监控**

- vnstat 流量统计
- iftop 实时监控
- NetData 可视化

#### 💾 备份与安全

**� 系统快照恢复**

- Timeshift 图形化
- rsync 命令行

**🛡️ 入侵检测系统**

- AIDE 完整性监控
- rkhunter Rootkit 检测
- ClamAV 病毒扫描
- Lynis 安全审计

</td>
<td width="50%">

#### 🔧 开发与部署

**🗄️ 数据库部署**

- MySQL 8.0 / MariaDB
- PostgreSQL / Redis
- MongoDB
- 自动安全配置

**🔧 开发环境管理**

- Python (pyenv + 包)
- Node.js (nvm + yarn)
- Go (国内加速)
- Java (OpenJDK + Maven)

#### 🌐 其他工具

**🌐 反向代理管理**

- Nginx 配置助手
- SSL 自动支持

** 文件同步服务**

- Syncthing P2P 同步
- Rclone 云存储 (50+平台)

</td>
</tr>
</table>

---

### � 特色功能

<table>
<tr>
<td width="33%" align="center">

**🌟 扩展菜单**

独立高级功能界面  
选项 **e** 进入

</td>
<td width="33%" align="center">

**🔍 日志分析**

智能系统日志分析  
选项 **l** 启动

</td>
<td width="33%" align="center">

**✅ 配置验证**

检查所有配置状态  
选项 **v** 验证

</td>
</tr>
</table>

---

## 📚 文档导航

<table>
<tr>
<td width="33%" align="center">

### 📖 项目文档

[完整文档](docs/PROJECT.md)  
项目总览和功能介绍

</td>
<td width="33%" align="center">

### ⚡ 快速参考

[命令速查](docs/QUICK_REFERENCE.md)  
常用命令和配置位置

</td>
<td width="33%" align="center">

### 💡 使用示例

[实战场景](docs/EXAMPLES.md)  
真实案例和最佳实践

</td>
</tr>
<tr>
<td width="33%" align="center">

### 🌍 语言时间

[Locale 配置](docs/LOCALE_TIME_GUIDE.md)  
语言和时区设置详解

</td>
<td width="33%" align="center">

### 🎯 完整指南 🆕

[全功能说明](docs/ALL_FEATURES_GUIDE.md)  
28+ 功能完整使用手册

</td>
<td width="33%" align="center">

### 📝 更新日志

[版本历史](docs/CHANGELOG.md)  
更新记录和新功能

</td>
</tr>
</table>

---

## 🎯 推荐配置方案

<table>
<tr>
<td width="50%">

### 方案 1: 最小化安全 ⚡

**用时**: 5 分钟  
**适合**: 快速部署、基础保护

```bash
选择: 0 → 基础优化全y → 环境配置全n
```

**结果**: 系统安全 + 性能优化

---

### 方案 2: Web 服务器 🌐

**用时**: 10 分钟  
**适合**: 网站部署、博客搭建

```bash
选择: 0 → Docker(n) → Nginx(y) → SSL(y)
```

**结果**: 基础安全 + Nginx + HTTPS

---

### 方案 3: Docker 环境 🐳

**用时**: 10 分钟  
**适合**: 容器化应用

```bash
选择: 0 → Docker(y) → 镜像加速(y) → 工具(y)
```

**结果**: 基础安全 + Docker + 开发工具

---

### 方案 4: 全栈生产 🏭

**用时**: 15 分钟  
**适合**: 完整生产环境

```bash
选择: 0 → 全部选y
```

**结果**: 完整安全 + 环境 + 监控 + 备份

</td>
<td width="50%">

### 方案 5: 网络优化 🚀

**用时**: 15 分钟  
**适合**: 网络加速、突破限制

```bash
选择: 17 → Cloudflare Tunnel
选择: 18 → Cloudflare WARP
选择: 19 → 网络优化工具
```

**结果**: Tunnel 代理 + WARP + 优化

---

### 方案 6: 开发环境 💻

**用时**: 20 分钟  
**适合**: 开发测试、项目部署

```bash
选择: 0 → 基础优化
选择: 22 → MySQL + Redis
选择: 23 → Python + Node.js
选择: 24 → 反向代理
```

**结果**: 开发环境 + 数据库 + 代理

---

### 方案 7: 生产级部署 🛡️

**用时**: 25 分钟  
**适合**: 企业级应用、关键业务

```bash
选择: 0 → 全部基础优化
选择: 21 → 邮件告警
选择: 25 → 系统快照
选择: 26 → 入侵检测
选择: 27 → 流量监控
```

**结果**: 安全防护 + 监控 + 备份

---

### 方案 8: ARM64 完整版 📱

**用时**: 20 分钟  
**适合**: 树莓派、ARM 服务器

```bash
ARM64版本脚本:
选择: 0 → 一键优化(含ARM64特性)
```

**结果**: ARM64 优化 + 温度监控

</td>
</tr>
</table>

---

## 📊 配置完成后效果

```
✅ 系统源：已优化
✅ SSH端口：已修改
✅ 防火墙：运行中
✅ BBR：已启用
✅ Fail2Ban：运行中
✅ Docker：已安装（可选）
✅ Nginx：已安装（可选）
✅ SSL证书：已配置（可选）
✅ 自动备份：已配置（可选）
✅ 系统监控：已配置（可选）
```

## 🛠️ 常用命令

### 基础系统命令

```bash
# 系统管理
apt update && apt upgrade    # 更新系统
htop                         # 查看资源
nft list ruleset            # 查看防火墙

# 语言和时间
locale                       # 查看当前语言设置
timedatectl                  # 查看时间和时区
timedatectl list-timezones   # 列出所有时区
locale -a                    # 查看可用语言

# Docker操作
docker ps                    # 查看容器
docker images                # 查看镜像

# Nginx操作
nginx -t                     # 测试配置
nginx -s reload             # 重载配置

# 备份和监控
/usr/local/bin/auto_backup.sh      # 手动备份
/usr/local/bin/system_monitor.sh   # 查看监控
```

### 性能基准测试 🆕

```bash
# 主脚本选择 20，或直接运行测试工具
superbench                   # 综合性能测试（推荐）
wget -qO- bench.sh | bash   # 经典bench.sh测试
curl -sL yabs.sh | bash     # YABS测试
```

### 邮件告警 🆕

```bash
# 查看配置
cat /etc/msmtprc

# 手动触发检查
/usr/local/bin/system_alert.sh

# 测试发送邮件
echo "test" | mail -s "test" your@email.com

# 查看日志
tail -f /var/log/msmtp.log
```

### 数据库管理 🆕

```bash
# MySQL
mysql -u root -p             # 登录MySQL
systemctl status mysql       # 查看状态
systemctl restart mysql      # 重启服务

# PostgreSQL
sudo -u postgres psql        # 登录PostgreSQL
systemctl status postgresql

# Redis
redis-cli                    # Redis命令行
systemctl status redis-server

# MongoDB
mongosh                      # MongoDB Shell
systemctl status mongod
```

### 开发环境 🆕

```bash
# Python环境
pyenv versions               # 查看已安装版本
pyenv install 3.11.0        # 安装Python 3.11
pyenv global 3.11.0         # 设置全局版本
pip list                     # 查看已安装包

# Node.js环境
nvm ls                       # 查看已安装版本
nvm install 20              # 安装Node.js 20
nvm use 20                  # 切换版本
npm list -g --depth=0       # 查看全局包

# Go环境
go version                   # 查看版本
go env                       # 查看环境变量

# Java环境
java -version                # 查看Java版本
mvn -version                # 查看Maven版本
```

### 系统快照 🆕

```bash
# 创建快照
/usr/local/bin/create_snapshot.sh

# 恢复快照
/usr/local/bin/restore_snapshot.sh

# 查看快照
ls -lh /backup/snapshots/

# Timeshift（如已安装）
timeshift --list            # 列出快照
timeshift --create          # 创建快照
timeshift --restore         # 恢复快照
```

### 入侵检测 🆕

```bash
# AIDE文件完整性检查
/usr/local/bin/aide_check.sh
aide --check                 # 手动检查

# rkhunter扫描
/usr/local/bin/rkhunter_scan.sh
rkhunter --check            # 手动扫描

# ClamAV病毒扫描
/usr/local/bin/clamscan_system.sh
clamscan -r /home           # 扫描指定目录

# Lynis安全审计
/usr/local/bin/lynis_audit.sh
lynis audit system          # 手动审计
```

### 流量监控 🆕

```bash
# vnstat统计
vnstat                       # 查看总览
vnstat -h                   # 按小时
vnstat -d                   # 按天
vnstat -m                   # 按月
vnstat -l                   # 实时监控

# iftop实时监控
iftop                        # 启动监控
iftop -i eth0               # 指定网卡
iftop -n                    # 不解析主机名

# NetData监控
访问: http://服务器IP:19999
systemctl status netdata    # 查看服务状态
```

### 文件同步 🆕

```bash
# Syncthing
systemctl status syncthing@root    # 查看服务状态
访问: http://服务器IP:8384         # Web界面

# Rclone
rclone config               # 配置云存储
rclone ls remote:           # 列出远程文件
rclone sync local/ remote:backup/  # 同步文件
rclone mount remote: /mnt/cloud --daemon  # 挂载云盘
```

### 反向代理 🆕

```bash
# 添加反向代理
/usr/local/bin/add_proxy.sh

# 测试Nginx配置
nginx -t

# 重载Nginx
nginx -s reload

# 查看代理配置
cat /etc/nginx/sites-available/proxy_配置名
```

### 日志分析 🆕

```bash
# 生成分析报告
/usr/local/bin/analyze_logs.sh

# 查看系统日志
journalctl -xe              # 查看最新系统日志
tail -f /var/log/syslog    # 实时查看系统日志
tail -f /var/log/auth.log  # 实时查看认证日志

# 查看特定服务日志
journalctl -u nginx -n 50  # 查看Nginx日志
journalctl -u docker -n 50 # 查看Docker日志
```

### Cloudflare 工具命令 🆕

```bash
# Cloudflare Tunnel
cloudflared tunnel login           # 登录账户
cloudflared tunnel create NAME     # 创建隧道
cloudflared tunnel route dns NAME DOMAIN  # 配置DNS
systemctl status cloudflared       # 查看服务状态

# Cloudflare WARP (官方客户端)
warp-cli register                  # 注册
warp-cli connect                   # 连接
warp-cli disconnect                # 断开
warp-cli status                    # 查看状态

# WARP (wgcf方式)
wg-quick up wgcf                   # 启用WARP
wg-quick down wgcf                 # 停止WARP
systemctl enable wg-quick@wgcf     # 开机自启

# 网络诊断
mtr google.com                     # 路由追踪
iperf3 -s                          # 带宽测试服务器
speedtest-cli                      # 网速测试
tcpdump -i eth0                    # 抓包分析
```

### ARM64 专用命令 🆕

```bash
# 温度监控
/usr/local/bin/temp_monitor.sh     # 查看CPU温度

# Docker ARM64
docker pull arm64v8/镜像名          # 拉取ARM64镜像
docker run --platform linux/arm64   # 运行ARM64容器

# 系统信息
uname -m                            # 查看架构
cat /sys/class/thermal/thermal_zone0/temp  # 读取温度
```

## ⚠️ 重要提醒

1. **SSH 端口修改后，先测试新端口连接再断开当前会话**
2. **配置防火墙后，确保 SSH 端口已开放**
3. **所有配置文件修改前都会自动备份**
4. **SSL 证书申请前确保域名已正确解析**
5. **Docker 组权限需要重新登录才能生效**
6. **ARM64 设备请注意散热，定期检查温度** 🆕
7. **Cloudflare Tunnel 需要有效的 Cloudflare 账户** 🆕
8. **WARP 在某些地区可能需要额外配置** 🆕

## 🌟 支持的系统

### 通用版本

- ✅ Debian 10/11/12 (x86_64)
- ✅ Ubuntu 20.04/22.04/24.04 (x86_64)
- ⚠️ 其他 Debian 系发行版（部分功能可能不兼容）

### ARM64 专用版本 🆕

- ✅ Debian 12 (Bookworm) ARM64
- ✅ 树莓派 OS (64 位)
- ✅ Ubuntu Server 22.04+ ARM64
- ✅ 甲骨文云 ARM 实例
- ✅ AWS Graviton 处理器
- ✅ 其他 ARM64 Debian/Ubuntu 系统

## � 获取帮助

- 查看[完整文档](docs/PROJECT.md)了解详细功能
- 查看[快速参考](docs/QUICK_REFERENCE.md)获取命令速查
- 查看[使用示例](docs/EXAMPLES.md)学习实战场景
- 提交[Issue](https://github.com/KaikiDeishuuu/VPSOPT/issues)反馈问题

## 🔄 更新日志

**v2.2** (2025-10-20) - [查看详情](docs/CHANGELOG.md) | [完整指南](docs/ALL_FEATURES_GUIDE.md)

- ✨ **新增 10 个全新高级功能**
  - 性能基准测试 (Superbench/YABS/bench.sh/UnixBench)
  - 邮件告警配置 (Gmail/QQ/163/阿里云/自定义 SMTP)
  - 数据库一键部署 (MySQL/MariaDB/PostgreSQL/Redis/MongoDB)
  - 开发环境管理 (Python/Node.js/Go/Java)
  - 反向代理管理 (Nginx 配置助手)
  - 系统快照与恢复 (Timeshift + rsync)
  - 入侵检测系统 (AIDE/rkhunter/ClamAV/Lynis)
  - 流量监控 (vnstat/iftop/NetData)
  - 文件同步服务 (Syncthing/Rclone)
  - 日志分析工具 (智能日志分析)
- 🎨 新增扩展功能菜单 (选项 e)
- 📈 功能总数从 19 项扩展到 28+ 项
- 📝 新增全功能使用指南文档
- 🔧 优化菜单布局和用户体验
- 📦 新增 vps_extend_functions.sh 模块化设计

**v2.1** (2025-10-20) - [查看详情](docs/CHANGELOG.md)

- ✨ 新增系统语言配置（功能 6）
  - 支持简体中文、英语、繁体中文、日语等
  - 自定义 Locale 支持
  - 自动配置系统环境
- ✨ 增强时间同步配置（功能 7）
  - 新增美国东部、英国等时区
  - 自定义时区支持
  - 更多 NTP 服务器选项
- ✨ 新增 Cloudflare Tunnel 配置（功能 17）
- ✨ 新增 Cloudflare WARP 配置（功能 18）
- ✨ 新增网络优化工具集（功能 19）
  - DNS 优化支持 5 种服务商
  - MTU 自动检测与优化
  - TCP Fast Open 配置
  - 网络诊断工具安装
- ✨ 新增 ARM64 Debian 12 专用版本
  - 架构自动检测
  - ARM64 性能优化
  - 温度监控功能
  - Docker ARM64 支持
  - 语言与时间配置支持
- 🎨 优化菜单布局（基础优化从 8 项增至 9 项）
- 📝 新增语言与时间配置指南文档
- 🐛 修复已知问题

**v2.0** (2025-10-19)

- ✨ 新增 7 大实用功能（Docker/Nginx/工具/备份/监控/SSH 优化/BBR V3）
- 🎨 优化菜单结构和交互体验
- 📝 完善文档系统
- ⭐ 集成 BBR V3 终极网络优化（功能 15）

## 🚀 BBR V3 终极优化 ⭐

脚本已集成 [Eric86777 的 BBR V3 优化](https://github.com/Eric86777/vps-tcp-tune) 作为**功能 15**！

在脚本菜单中选择 `15` 即可一键安装 BBR V3 优化。

**特性：**

- ✅ BBR v3 最新版本
- ✅ 针对 VPS 网络环境深度优化
- ✅ 简单易用的命令行工具
- ✅ 详细的性能监控和调优
- ✅ 安装后可使用 `bbr` 命令直接调用

**手动安装方式：**

```bash
# 方式1: 使用本脚本（推荐）
sudo ./vps_optimize.sh
# 选择: 15

# 方式2: 手动安装
bash <(curl -fsSL "https://raw.githubusercontent.com/Eric86777/vps-tcp-tune/main/install-alias.sh?$(date +%s)")
source ~/.bashrc  # 重新加载配置
bbr              # 运行优化
```

更多信息请访问：https://github.com/Eric86777/vps-tcp-tune

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🌟 支持项目

如果这个脚本对你有帮助：

- ⭐ 给个 [Star](https://github.com/KaikiDeishuuu/VPSOPT)
- 🔀 Fork 项目
- 📢 分享给朋友
- 💬 [提交反馈](https://github.com/KaikiDeishuuu/VPSOPT/issues)

## 👨‍💻 作者

**Kaiki**

感谢使用！祝你的 VPS 运行愉快！ 🚀

---

**相关项目推荐：**

- [vps-tcp-tune](https://github.com/Eric86777/vps-tcp-tune) - BBR V3 终极优化脚本 by Eric86777
