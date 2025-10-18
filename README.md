# VPS 服务器优化脚本

> 一键完成 VPS 服务器初始化、安全加固和环境配置  
> **作者:** Kaiki | **版本:** v2.0 | **更新:** 2025-10-19

[![GitHub stars](https://img.shields.io/github/stars/KaikiDeishuuu/VPSOPT?style=social)](https://github.com/KaikiDeishuuu/VPSOPT)
[![GitHub forks](https://img.shields.io/github/forks/KaikiDeishuuu/VPSOPT?style=social)](https://github.com/KaikiDeishuuu/VPSOPT)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📖 简介

这是一个功能强大的 VPS 服务器一键优化脚本，帮助你快速完成服务器的初始化配置、安全加固和环境部署。

## 🚀 快速开始

```bash
# 下载脚本
git clone https://github.com/KaikiDeishuuu/VPSOPT.git
cd VPSOPT

# 运行脚本
chmod +x start.sh
sudo ./start.sh
```

或者直接下载：

```bash
wget https://raw.githubusercontent.com/KaikiDeishuuu/VPSOPT/main/vps_optimize.sh
chmod +x vps_optimize.sh
sudo ./vps_optimize.sh
```

## ✨ 核心功能

### 🔧 基础优化（8 项）

- ✅ 换源加速 - 支持 6 个镜像源
- ✅ 账户安全 - 密码/用户/SSH 密钥
- ✅ SSH 加固 - 端口修改/防暴力破解
- ✅ 防火墙 - nftables/iptables
- ✅ 性能优化 - BBR/swap/内核参数
- ✅ 时间同步 - 时区/NTP
- ✅ 安全加固 - Fail2Ban/自动更新
- ✅ 系统清理 - 缓存/日志/临时文件

### 🚀 环境配置（7 项）🆕

- ✨ **Docker 环境** - 一键安装 + 镜像加速
- ✨ **Nginx + SSL** - Web 服务器 + 自动化证书
- ✨ **常用工具** - 监控/网络/开发工具
- ✨ **自动备份** - 定时备份 + 自动清理
- ✨ **系统监控** - CPU/内存/磁盘监控
- ✨ **SSH 优化** - 提升连接速度
- ✨ **BBR V3 优化** ⭐ - 终极网络性能优化

## 📚 文档导航

- 📖 [完整文档](docs/PROJECT.md) - 项目总览和功能介绍
- ⚡ [快速参考](docs/QUICK_REFERENCE.md) - 命令速查和配置位置
- 💡 [使用示例](docs/EXAMPLES.md) - 实战场景和最佳实践
- 📝 [更新日志](docs/CHANGELOG.md) - 版本历史和新功能说明

## 🎯 推荐配置方案

### 方案 1: 最小化安全（5 分钟）

```bash
选择: 0 → 基础优化全y → 环境配置全n
结果: 系统安全 + 性能优化
```

### 方案 2: Web 服务器（10 分钟）

```bash
选择: 0 → Docker(n) → Nginx(y) → SSL证书(y)
结果: 基础安全 + Nginx + HTTPS
```

### 方案 3: Docker 环境（10 分钟）

```bash
选择: 0 → Docker(y) → 镜像加速(y) → 工具(y)
结果: 基础安全 + Docker + 开发工具
```

### 方案 4: 全栈生产（15 分钟）

```bash
选择: 0 → 全部选y
结果: 完整安全 + 环境 + 监控 + 备份
```

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

## � 常用命令

```bash
# 系统管理
apt update && apt upgrade    # 更新系统
htop                         # 查看资源
nft list ruleset            # 查看防火墙

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

## ⚠️ 重要提醒

1. **SSH 端口修改后，先测试新端口连接再断开当前会话**
2. **配置防火墙后，确保 SSH 端口已开放**
3. **所有配置文件修改前都会自动备份**
4. **SSL 证书申请前确保域名已正确解析**
5. **Docker 组权限需要重新登录才能生效**

## � 获取帮助

- 查看[完整文档](docs/PROJECT.md)了解详细功能
- 查看[快速参考](docs/QUICK_REFERENCE.md)获取命令速查
- 查看[使用示例](docs/EXAMPLES.md)学习实战场景
- 提交[Issue](https://github.com/KaikiDeishuuu/VPSOPT/issues)反馈问题

## 🔄 更新日志

**v2.0** (2025-10-19) - [查看详情](docs/CHANGELOG.md)

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
