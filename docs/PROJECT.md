# 📁 VPS 优化脚本项目

> 一键完成 VPS 服务器初始化、安全加固和环境配置  
> 作者: **Kaiki** | 版本: **v2.0** | 更新: **2025-10-19**

---

## 🚀 快速开始

```bash
# 方式1: 一键启动
chmod +x start.sh && sudo ./start.sh

# 方式2: 直接运行
chmod +x vps_optimize.sh && sudo ./vps_optimize.sh
```

---

## 📚 文档导航

### 核心文件

- **[vps_optimize.sh](vps_optimize.sh)** - 主脚本文件
- **[start.sh](start.sh)** - 一键启动脚本

### 文档文件

1. **[README.md](README.md)** - 📖 完整使用文档

   - 功能介绍
   - 使用方法
   - 功能特色
   - 常见问题

2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - ⚡ 快速参考指南

   - 功能菜单速查
   - 常用命令速查
   - 配置文件位置
   - 紧急情况处理

3. **[EXAMPLES.md](EXAMPLES.md)** - 💡 使用示例

   - 5 个实战场景
   - 最佳实践
   - 问题解决方案
   - 检查清单

4. **[CHANGELOG.md](CHANGELOG.md)** - 📝 更新说明
   - 版本历史
   - 新功能详解
   - 升级指南

---

## ✨ 核心功能

### 🔧 基础优化 (必备)

```
✅ 换源加速              - 提升下载速度
✅ 账户安全配置          - 密码/用户/SSH密钥
✅ SSH安全加固           - 修改端口/防暴力破解
✅ 防火墙配置            - nftables/iptables
✅ 系统性能优化          - BBR/swap/内核参数
✅ 时间同步配置          - 时区/NTP
✅ 安全加固              - Fail2Ban/自动更新
✅ 系统清理              - 清理缓存/日志
```

### 🚀 环境配置 (可选)

```
✨ Docker环境配置        - 容器化部署 + 镜像加速
✨ Nginx + SSL证书       - Web服务器 + 自动化证书
✨ 常用工具安装          - 监控/网络/开发工具
✨ 自动备份配置          - 定时备份 + 自动清理
✨ 系统监控告警          - CPU/内存/磁盘监控
✨ SSH连接优化           - 提升连接速度
```

---

## 🎯 推荐方案

### 最小化安全配置 (5 分钟)

```bash
适合: 所有VPS服务器
步骤: 选择 0 → 基础优化全部y → 环境配置全部n
结果: 系统安全 + 性能优化
```

### Web 服务器 (10 分钟)

```bash
适合: 网站、博客
步骤: 选择 0 → Docker(n) → Nginx(y)
结果: 基础安全 + Nginx + SSL证书
```

### Docker 环境 (10 分钟)

```bash
适合: 容器化部署
步骤: 选择 0 → Docker(y) → Nginx(n)
结果: 基础安全 + Docker + 镜像加速
```

### 全栈生产环境 (15 分钟)

```bash
适合: 生产环境
步骤: 选择 0 → 全部选y
结果: 完整配置 + 监控 + 备份
```

---

## 📖 详细功能说明

### 1️⃣ Docker 环境配置 🆕

- ✅ 一键安装 Docker Engine + Compose
- ✅ 支持阿里云/清华/官方镜像源
- ✅ 配置国内镜像加速
- ✅ 优化日志配置
- ✅ 自动测试安装

### 2️⃣ Nginx + SSL 证书 🆕

- ✅ 安装并优化 Nginx
- ✅ 集成 acme.sh 证书工具
- ✅ 支持 Webroot/Standalone/DNS API 验证
- ✅ 支持 Cloudflare/阿里云/腾讯云 DNS
- ✅ 自动生成 HTTPS 配置
- ✅ 证书自动续期

### 3️⃣ 常用工具 🆕

- 📊 监控工具: htop, iotop, nload, glances
- 🌐 网络工具: curl, wget, nmap, traceroute
- ✏️ 编辑器: vim, nano
- 💻 开发工具: git, build-essential, python3-pip
- 📦 压缩工具: zip, rar, p7zip

### 4️⃣ 自动备份 🆕

- 📦 备份配置文件 + 网站数据
- ⏰ 定时备份 (每天/每周/每月)
- 🗑️ 自动清理旧备份
- 📝 生成备份日志

### 5️⃣ 系统监控 🆕

- 📊 监控 CPU/内存/磁盘使用率
- 🔍 监控关键服务状态
- ⏰ 定时自动检查
- 📝 生成监控日志

### 6️⃣ SSH 连接优化 🆕

- ⚡ 禁用 DNS 反向解析
- ⚡ 禁用 GSSAPI 认证
- ⚡ 配置连接保活
- ⚡ 提升 50%+连接速度

---

## 💻 使用演示

### 交互式菜单

```
╔═══════════════════════════════════════════════════════════╗
║           VPS 服务器优化脚本 v2.0                        ║
║       让你的服务器从"裸机"变成性能强劲的战斗机          ║
╚═══════════════════════════════════════════════════════════╝

请选择要执行的优化项目：

  [一键优化]
  0) 执行全部优化 (推荐新手)

  [基础优化]
  1) 换源加速
  2) 账户安全配置
  3) SSH安全加固
  4) 防火墙配置
  5) 系统性能优化
  6) 时间同步配置
  7) 安全加固 (Fail2Ban等)
  8) 系统清理

  [环境配置]
  9) Docker环境配置
  10) Nginx配置与SSL证书
  11) 安装常用工具
  12) 配置自动备份
  13) 配置系统监控告警
  14) 优化SSH连接速度

  [其他]
  v) 验证配置
  q) 退出脚本

请输入选项:
```

---

## 📊 配置完成后效果

### 系统状态

```
✅ 系统源：已优化 (阿里云/官方)
✅ SSH端口：已修改 (自定义端口)
✅ 防火墙：运行中 (nftables)
✅ BBR：已启用
✅ Fail2Ban：运行中
✅ 时间同步：已配置
```

### 可选环境

```
✅ Docker：已安装 (v24.0+) + 镜像加速
✅ Nginx：已安装 (v1.24+) + 性能优化
✅ SSL证书：已配置 + 自动续期
✅ 自动备份：已配置 + 定时任务
✅ 系统监控：已配置 + 告警
✅ 常用工具：已安装
```

---

## 📁 生成的文件

### 配置文件

```
/etc/apt/sources.list              # 软件源配置
/etc/ssh/sshd_config               # SSH配置
/etc/nftables.conf                 # 防火墙规则
/etc/docker/daemon.json            # Docker配置
/etc/nginx/nginx.conf              # Nginx配置
/etc/nginx/ssl/                    # SSL证书目录
```

### 脚本文件

```
/usr/local/bin/auto_backup.sh      # 自动备份脚本
/usr/local/bin/system_monitor.sh   # 系统监控脚本
~/.acme.sh/                        # acme.sh证书工具
```

### 日志文件

```
/var/log/backup.log                # 备份日志
/var/log/monitor.log               # 监控日志
/var/log/auth.log                  # 认证日志
/root/vps_setup_info.txt           # 配置报告
```

---

## 🔧 常用命令

### 日常维护

```bash
# 更新系统
apt update && apt upgrade -y

# 查看系统状态
htop
df -h
free -h

# 查看防火墙
nft list ruleset

# 查看服务状态
systemctl status ssh nginx docker
```

### Docker 操作

```bash
docker ps                  # 查看容器
docker images              # 查看镜像
docker logs 容器名         # 查看日志
docker system prune -a     # 清理资源
```

### Nginx 操作

```bash
nginx -t                   # 测试配置
nginx -s reload            # 重载配置
tail -f /var/log/nginx/access.log  # 查看日志
```

### 备份和监控

```bash
/usr/local/bin/auto_backup.sh      # 手动备份
/usr/local/bin/system_monitor.sh   # 查看监控
tail -f /var/log/backup.log        # 备份日志
tail -f /var/log/monitor.log       # 监控日志
```

---

## ⚠️ 重要提醒

### 修改 SSH 端口后

```bash
# ❗ 不要关闭当前SSH连接
# ❗ 先在新终端测试连接
ssh -p 新端口 root@your-vps-ip

# ✅ 确认可以连接后再断开旧连接
```

### 防火墙配置后

```bash
# ❗ 确保SSH端口已开放
# ❗ 新开服务需要在防火墙中开放端口
```

### SSL 证书申请

```bash
# ❗ 确保域名已正确解析
# ❗ DNS API方式最稳定（推荐）
```

---

## 🆘 故障排查

### SSH 无法连接

```bash
# 通过VPS控制面板进入VNC/控制台
systemctl status ssh
systemctl restart ssh
# 检查防火墙是否开放SSH端口
```

### 服务无法启动

```bash
# 查看服务状态
systemctl status 服务名
# 查看详细日志
journalctl -u 服务名 -n 100
```

### 磁盘空间不足

```bash
# 清理日志
journalctl --vacuum-time=7d
# 清理Docker
docker system prune -a
# 清理包缓存
apt clean
```

---

## 🌟 特色亮点

### 🎯 用户友好

- ✅ 彩色输出，清晰易读
- ✅ 交互式菜单，操作简单
- ✅ 详细提示，步骤清晰
- ✅ 自动备份，安全可靠

### ⚡ 功能强大

- ✅ 14 项优化功能
- ✅ 支持 Docker + Nginx
- ✅ SSL 证书自动化
- ✅ 自动备份和监控

### 🔒 安全可靠

- ✅ 配置文件自动备份
- ✅ 防火墙自动配置
- ✅ Fail2Ban 防暴力破解
- ✅ SSH 安全加固

### 📊 完整文档

- ✅ README - 完整说明
- ✅ QUICK_REFERENCE - 快速参考
- ✅ EXAMPLES - 实战示例
- ✅ CHANGELOG - 更新说明

---

## 📞 获取帮助

### 查看文档

```bash
cat README.md              # 完整文档
cat QUICK_REFERENCE.md     # 快速参考
cat EXAMPLES.md            # 使用示例
cat CHANGELOG.md           # 更新说明
```

### 在线资源

- Docker: https://docs.docker.com/
- Nginx: https://nginx.org/en/docs/
- acme.sh: https://github.com/acmesh-official/acme.sh

---

## 📝 版本信息

**当前版本:** v2.0  
**发布日期:** 2025-10-19  
**作者:** Kaiki

### 更新内容

- ✨ 新增 6 大实用功能
- 🎨 优化菜单结构
- 📚 完善文档系统
- 🐛 修复已知问题

---

## 📄 许可证

MIT License

---

## ⭐ 支持项目

如果这个脚本对你有帮助：

- ⭐ 给个 Star
- 🔀 Fork 项目
- 📢 分享给朋友
- 💬 提供反馈

---

**感谢使用！祝你的 VPS 运行愉快！** 🚀
