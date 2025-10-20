# 🎉 VPS 优化脚本 - 全部实用功能部署完成

## 📋 更新概述

本次更新为 VPS 优化脚本添加了**10 个全新的高级功能**，使脚本功能从 19 项扩展到 28 项，全面覆盖 VPS 管理的各个方面！

**更新时间**: 2025-10-20  
**版本**: v2.2  
**新增功能数量**: 10 个

---

## ✨ 新增功能列表

### 🔥 **核心功能** (功能 20-24)

#### 20. 📈 性能基准测试 ⭐

**位置**: 主菜单 → 20

**功能说明**:

- 集成多个专业测试工具
- 全方位评估 VPS 性能
- 生成详细测试报告

**支持的测试工具**:
| 工具 | 特点 | 测试内容 |
|------|------|----------|
| Superbench | 综合测试（推荐） | CPU/内存/硬盘 IO/网络 |
| YABS | 轻量快速 | CPU/硬盘/网络速度 |
| Bench.sh | 经典工具 | 系统信息/IO/网速 |
| UnixBench | 深度测试 | 全面性能评分 |
| 自定义组合 | 灵活选择 | 按需测试 |

**使用场景**:

- ✅ 购买 VPS 后验证性能
- ✅ 优化前后性能对比
- ✅ 定期性能监控
- ✅ 寻找性能瓶颈

#### 21. 📧 邮件告警配置

**位置**: 主菜单 → 21

**功能说明**:

- 系统异常自动发送邮件通知
- 支持多种邮件服务
- 自定义告警阈值

**支持的邮件服务**:

- Gmail (应用专用密码)
- QQ 邮箱 (授权码)
- 163 邮箱 (授权码)
- 阿里云邮箱
- 自定义 SMTP 服务器

**告警类型**:

- 🔴 CPU 使用率过高 (>80%)
- 🔴 内存使用率过高 (>80%)
- 🔴 磁盘使用率过高 (>85%)
- 🔴 系统负载过高 (>5.0)
- 🔴 关键服务停止 (SSH/Nginx/Docker)

**检查频率**: 每 10 分钟自动检查

#### 22. 🗄️ 数据库一键部署

**位置**: 主菜单 → 22

**功能说明**:

- 一键安装配置主流数据库
- 自动安全加固
- 快速创建数据库和用户

**支持的数据库**:

| 数据库     | 版本 | 特点       | 适用场景            |
| ---------- | ---- | ---------- | ------------------- |
| MySQL      | 8.0  | 最流行     | Web 应用、WordPress |
| MariaDB    | 最新 | MySQL 分支 | 替代 MySQL          |
| PostgreSQL | 最新 | 企业级     | 复杂查询、大数据    |
| Redis      | 最新 | 缓存数据库 | 缓存、队列          |
| MongoDB    | 6.0  | 文档数据库 | NoSQL、JSON 数据    |

**自动配置**:

- ✅ 安全密码设置
- ✅ 远程访问控制
- ✅ 性能优化配置
- ✅ 自动备份建议

#### 23. 🔧 开发环境管理

**位置**: 主菜单 → 23

**功能说明**:

- 快速配置开发环境
- 版本管理工具
- 常用工具一键安装

**支持的开发环境**:

##### Python 环境

- **版本管理**: pyenv
- **包管理**: pip, virtualenv, pipenv, poetry
- **常用框架**: Flask, Django, FastAPI
- **特点**: 多版本并存，虚拟环境隔离

##### Node.js 环境

- **版本管理**: nvm
- **包管理**: npm, yarn, pnpm
- **全局工具**: pm2, typescript, nodemon
- **镜像**: 国内淘宝镜像加速

##### Go 语言环境

- **版本**: Go 1.21+
- **代理**: goproxy.cn 国内加速
- **环境**: GOPATH 自动配置

##### Java 环境

- **版本**: OpenJDK 8/11/17 LTS
- **构建工具**: Maven
- **适用**: Java 开发、Spring 项目

#### 24. 🌐 反向代理管理

**位置**: 主菜单 → 24

**功能说明**:

- 简化 Nginx 反向代理配置
- 向导式配置流程
- 自动 SSL 证书支持

**配置向导**:

```bash
/usr/local/bin/add_proxy.sh

输入：
- 域名: example.com
- 后端地址: 127.0.0.1
- 后端端口: 3000
- 是否启用SSL: y/n

输出：
- Nginx配置文件
- 自动测试配置
- 自动重载Nginx
```

**使用场景**:

- Web 应用反向代理
- 负载均衡配置
- SSL 终止
- 多服务统一入口

### 🛡️ **安全与维护** (功能 25-28 + 扩展菜单)

#### 25. 💾 系统快照与恢复

**位置**: 主菜单 → 25

**功能说明**:

- 创建系统完整快照
- 快速回滚到之前状态
- 自动管理快照数量

**支持的方案**:

##### 方案 1: Timeshift

- 类似 Windows 系统还原点
- 图形化界面
- 定时自动快照

##### 方案 2: rsync 快照

- 自定义脚本
- 轻量高效
- 保留最近 5 个快照

**快照内容**:

- 系统文件
- 配置文件
- 用户数据
- 排除临时文件

**使用命令**:

```bash
# 创建快照
/usr/local/bin/create_snapshot.sh

# 恢复快照
/usr/local/bin/restore_snapshot.sh
```

#### 26. 🛡️ 入侵检测系统

**位置**: 主菜单 → 26

**功能说明**:

- 多层次安全检测
- 自动扫描和报告
- 定时安全审计

**检测工具组合**:

| 工具     | 功能         | 检查内容         |
| -------- | ------------ | ---------------- |
| AIDE     | 文件完整性   | 系统文件变更检测 |
| rkhunter | Rootkit 检测 | 后门、木马扫描   |
| ClamAV   | 病毒扫描     | 恶意软件检测     |
| Lynis    | 安全审计     | 系统安全评分     |

**自动任务**:

- AIDE: 每天凌晨 2 点检查
- rkhunter: 每天凌晨 3 点扫描
- ClamAV: 手动扫描或定时
- Lynis: 手动审计

#### 27. 📊 流量监控

**位置**: 主菜单 → 27

**功能说明**:

- 实时流量监控
- 历史数据统计
- 流量使用分析

**监控工具**:

##### vnstat - 流量统计

- 轻量级
- 按小时/天/月统计
- 数据持久化

```bash
vnstat          # 查看总览
vnstat -h       # 按小时
vnstat -d       # 按天
vnstat -m       # 按月
```

##### iftop - 实时监控

- 实时连接显示
- 带宽使用排序
- 按连接分类

```bash
iftop           # 启动监控
iftop -i eth0   # 指定网卡
```

##### NetData - 全面监控

- Web 界面
- 实时图表
- 系统全面监控
- 访问地址: http://IP:19999

#### 28. 📁 文件同步服务

**位置**: 主菜单 → 28

**功能说明**:

- 自动文件同步
- 云存储集成
- 多设备同步

**同步方案**:

##### Syncthing - 去中心化同步

- P2P 直连
- 无需中心服务器
- 加密传输
- Web 管理界面: http://IP:8384

**特点**:

- 多设备同步
- 版本控制
- 选择性同步
- 跨平台支持

##### Rclone - 云存储同步

- 支持 50+云存储
- 挂载云盘
- 定时同步
- 加密传输

**支持的云存储**:

- Google Drive
- Dropbox
- OneDrive
- Amazon S3
- 阿里云 OSS
- 腾讯云 COS
- 七牛云
- 又拍云

### 🎯 **扩展功能菜单** (e)

**位置**: 主菜单 → e (扩展功能菜单)

提供独立的扩展功能界面，包含：

1. 💾 系统快照与恢复
2. 🛡️ 入侵检测系统
3. 📊 流量监控
4. 📁 文件同步服务
5. 🌐 反向代理管理
6. 🔍 日志分析工具

### 🔍 **日志分析工具** (l)

**位置**: 主菜单 → l

**功能说明**:

- 智能分析系统日志
- 异常行为检测
- 生成分析报告

**分析内容**:

- SSH 登录统计（成功/失败）
- 登录失败 IP TOP10
- 系统错误日志
- 磁盘和内存使用
- CPU/内存占用 TOP10
- Nginx 访问统计（如有）

**使用命令**:

```bash
/usr/local/bin/analyze_logs.sh
```

---

## 📊 功能总览

### 按类别分类

| 类别     | 功能数量 | 功能编号 |
| -------- | -------- | -------- |
| 基础优化 | 9        | 1-9      |
| 环境配置 | 11       | 10-20    |
| 高级功能 | 8        | 21-28    |
| **总计** | **28**   | **1-28** |

### 功能完整列表

#### 基础优化 (1-9)

1. 📦 换源加速
2. 👤 账户安全配置
3. 🔐 SSH 安全加固
4. 🔥 防火墙配置
5. ⚙️ 系统性能优化
6. 🌍 系统语言配置
7. 🕐 时间同步配置
8. 🛡️ 安全加固 (Fail2Ban)
9. 🧹 系统清理

#### 环境配置 (10-20)

10. 🐳 Docker 环境配置
11. 🌐 Nginx 配置与 SSL 证书
12. 🛠️ 安装常用工具
13. 💾 配置自动备份
14. 📊 配置系统监控告警
15. ⚡ 优化 SSH 连接速度
16. 🚀 BBR V3 终极优化 ⭐
17. ☁️ Cloudflare Tunnel
18. 🔒 Cloudflare WARP
19. 🌐 网络优化工具集
20. 📈 **性能基准测试** ⭐🆕

#### 高级功能 (21-28)

21. 📧 **邮件告警配置** 🆕
22. 🗄️ **数据库一键部署** 🆕
23. 🔧 **开发环境管理** 🆕
24. 🌐 **反向代理管理** 🆕
25. 💾 **系统快照与恢复** 🆕
26. 🛡️ **入侵检测系统** 🆕
27. 📊 **流量监控** 🆕
28. 📁 **文件同步服务** 🆕

#### 特殊功能

- e) 🌟 扩展功能菜单
- l) 🔍 日志分析
- v) ✅ 验证配置
- q) 🚪 退出脚本

---

## 🚀 使用方法

### 快速开始

```bash
# 运行主脚本
sudo ./vps_optimize.sh

# 新功能快速访问
选择对应编号：
20 - 性能测试
21 - 邮件告警
22 - 数据库部署
23 - 开发环境
24 - 反向代理
25 - 系统快照
26 - 入侵检测
27 - 流量监控
28 - 文件同步

# 扩展功能菜单
选择 e 进入扩展功能界面

# 日志分析
选择 l 查看日志分析
```

### 推荐配置方案

#### 方案 1: 开发服务器

```
基础: 0 (一键优化)
环境: 23 (Python/Node.js)
数据库: 22 (MySQL/Redis)
监控: 21 (邮件告警) + 27 (流量监控)
```

#### 方案 2: Web 服务器

```
基础: 0 (一键优化)
环境: 11 (Nginx + SSL)
代理: 24 (反向代理)
数据库: 22 (MySQL)
安全: 26 (入侵检测)
```

#### 方案 3: 生产环境

```
基础: 0 (一键优化)
测试: 20 (性能基准)
告警: 21 (邮件告警)
备份: 25 (系统快照)
安全: 26 (入侵检测)
监控: 27 (流量监控)
```

#### 方案 4: 文件服务器

```
基础: 0 (一键优化)
同步: 28 (Syncthing/Rclone)
监控: 27 (流量统计)
备份: 13 + 25 (自动备份 + 快照)
```

---

## 📁 文件结构

```
VPS_SH/
├── vps_optimize.sh           # 主脚本 (增强版)
├── vps_optimize_arm64.sh     # ARM64专用版
├── vps_extend_functions.sh   # 扩展功能脚本 🆕
├── start.sh                  # 启动脚本
├── test_locale_time.sh       # 测试脚本
├── README.md                 # 项目说明
├── LICENSE                   # 许可证
└── docs/                     # 文档目录
    ├── LOCALE_TIME_GUIDE.md  # 语言时间配置指南
    ├── ALL_FEATURES_GUIDE.md # 全功能说明 🆕
    ├── CHANGELOG.md          # 更新日志
    ├── EXAMPLES.md           # 使用示例
    └── ...
```

---

## 🎯 功能亮点

### 1. 性能基准测试

- ✅ 多工具集成
- ✅ 一键测试
- ✅ 详细报告
- ✅ 性能对比

### 2. 邮件告警

- ✅ 实时监控
- ✅ 自动告警
- ✅ 多邮箱支持
- ✅ 自定义阈值

### 3. 数据库部署

- ✅ 一键安装
- ✅ 安全配置
- ✅ 多数据库支持
- ✅ 快速创建

### 4. 开发环境

- ✅ 版本管理
- ✅ 多语言支持
- ✅ 工具链完整
- ✅ 国内加速

### 5. 系统快照

- ✅ 快速备份
- ✅ 一键恢复
- ✅ 自动管理
- ✅ 空间优化

### 6. 入侵检测

- ✅ 多层防护
- ✅ 定时扫描
- ✅ 自动报告
- ✅ 安全审计

### 7. 流量监控

- ✅ 实时显示
- ✅ 历史统计
- ✅ 可视化界面
- ✅ 流量分析

### 8. 文件同步

- ✅ 多设备同步
- ✅ 云存储集成
- ✅ 加密传输
- ✅ 自动同步

---

## 🔧 配置文件位置

### 新功能相关配置

| 功能       | 配置文件           | 路径                        |
| ---------- | ------------------ | --------------------------- |
| 邮件告警   | msmtprc            | /etc/msmtprc                |
| 告警脚本   | system_alert.sh    | /usr/local/bin/             |
| MySQL      | my.cnf             | /etc/mysql/                 |
| PostgreSQL | postgresql.conf    | /etc/postgresql/            |
| Redis      | redis.conf         | /etc/redis/                 |
| Python     | .bashrc            | ~/.bashrc                   |
| Node.js    | .bashrc            | ~/.bashrc                   |
| 系统快照   | create_snapshot.sh | /usr/local/bin/             |
| AIDE       | aide.conf          | /etc/aide/                  |
| ClamAV     | clamd.conf         | /etc/clamav/                |
| vnstat     | vnstat.conf        | /etc/vnstat.conf            |
| NetData    | netdata.conf       | /etc/netdata/               |
| Syncthing  | config.xml         | ~/.config/syncthing/        |
| Rclone     | rclone.conf        | ~/.config/rclone/           |
| 反向代理   | nginx 配置         | /etc/nginx/sites-available/ |
| 日志分析   | analyze_logs.sh    | /usr/local/bin/             |

---

## 📝 常用命令速查

### 性能测试

```bash
# 主菜单选择 20，或运行脚本后选择测试工具
```

### 邮件告警

```bash
# 查看告警配置
cat /etc/msmtprc

# 手动触发告警检查
/usr/local/bin/system_alert.sh

# 查看告警日志
tail -f /var/log/msmtp.log
```

### 数据库管理

```bash
# MySQL
mysql -u root -p
systemctl status mysql

# PostgreSQL
sudo -u postgres psql
systemctl status postgresql

# Redis
redis-cli
systemctl status redis-server

# MongoDB
mongosh
systemctl status mongod
```

### 开发环境

```bash
# Python
pyenv versions
pyenv install 3.11.0
pyenv global 3.11.0

# Node.js
nvm ls
nvm install 20
nvm use 20

# Go
go version
go env

# Java
java -version
mvn -version
```

### 系统快照

```bash
# 创建快照
/usr/local/bin/create_snapshot.sh

# 恢复快照
/usr/local/bin/restore_snapshot.sh

# 查看快照
ls -lh /backup/snapshots/
```

### 入侵检测

```bash
# AIDE检查
/usr/local/bin/aide_check.sh

# rkhunter扫描
/usr/local/bin/rkhunter_scan.sh

# ClamAV扫描
/usr/local/bin/clamscan_system.sh

# Lynis审计
/usr/local/bin/lynis_audit.sh
```

### 流量监控

```bash
# vnstat统计
vnstat
vnstat -h  # 按小时
vnstat -d  # 按天
vnstat -m  # 按月

# iftop实时
iftop

# NetData
访问: http://服务器IP:19999
```

### 文件同步

```bash
# Syncthing
systemctl status syncthing@root
访问: http://服务器IP:8384

# Rclone
rclone config
rclone ls remote:
rclone sync local/ remote:backup/
```

### 反向代理

```bash
# 添加代理
/usr/local/bin/add_proxy.sh

# 测试配置
nginx -t

# 重载Nginx
nginx -s reload
```

### 日志分析

```bash
# 生成分析报告
/usr/local/bin/analyze_logs.sh

# 查看特定日志
journalctl -xe
tail -f /var/log/syslog
tail -f /var/log/auth.log
```

---

## ⚠️ 注意事项

### 性能测试

- 测试会占用系统资源
- UnixBench 耗时 15-30 分钟
- 建议在低峰期测试

### 邮件告警

- 需要正确配置 SMTP
- Gmail 需要应用专用密码
- QQ/163 需要授权码
- 测试发送确认配置

### 数据库

- 记住所有密码
- 密码保存在 /root/vps_setup_info.txt
- 定期备份数据库
- 注意端口安全

### 开发环境

- 需要重新登录生效
- pyenv/nvm 修改 PATH
- Go 需要配置 GOPATH
- Java 占用内存较大

### 系统快照

- 快照占用大量空间
- 定期清理旧快照
- 恢复前请慎重
- 重要数据额外备份

### 入侵检测

- 初始化需要时间
- 定期更新病毒库
- 查看扫描报告
- 处理告警提示

### 流量监控

- NetData 占用端口 19999
- 注意防火墙配置
- 定期查看流量
- 警惕异常流量

### 文件同步

- 确保网络稳定
- 检查存储空间
- 配置同步规则
- 重要文件备份

---

## 🎓 最佳实践

### 1. 首次部署建议

```
1. 运行一键优化 (选项 0)
2. 配置邮件告警 (选项 21)
3. 创建系统快照 (选项 25)
4. 运行性能测试 (选项 20)
5. 安装入侵检测 (选项 26)
```

### 2. 开发环境配置

```
1. 安装开发环境 (选项 23)
2. 部署数据库 (选项 22)
3. 配置Docker (选项 10)
4. 设置反向代理 (选项 24)
```

### 3. 安全加固建议

```
1. 完成基础优化 (选项 0)
2. 配置入侵检测 (选项 26)
3. 设置邮件告警 (选项 21)
4. 定期日志分析 (选项 l)
```

### 4. 定期维护任务

```
每日:
- 查看告警邮件
- 检查系统日志

每周:
- 运行日志分析
- 查看流量统计
- 检查磁盘空间

每月:
- 创建系统快照
- 运行安全扫描
- 性能基准测试
- 更新病毒库
```

---

## 🆘 故障排除

### 邮件告警不工作

```bash
# 检查配置
cat /etc/msmtprc

# 测试发送
echo "test" | mail -s "test" your@email.com

# 查看日志
tail -f /var/log/msmtp.log
```

### 数据库无法启动

```bash
# 查看状态
systemctl status mysql
systemctl status postgresql

# 查看日志
journalctl -u mysql -n 50
journalctl -u postgresql -n 50
```

### 开发环境不生效

```bash
# 重新加载配置
source ~/.bashrc

# 或重新登录SSH
```

### 快照创建失败

```bash
# 检查磁盘空间
df -h

# 检查权限
ls -la /backup/snapshots/
```

---

## 📚 相关资源

- [主项目 README](../README.md)
- [语言与时间配置指南](LOCALE_TIME_GUIDE.md)
- [快速参考手册](QUICK_REFERENCE.md)
- [更新日志](CHANGELOG.md)

---

## 🌟 总结

本次更新成功为 VPS 优化脚本添加了**10 个全新的实用功能**：

✅ **性能基准测试** - 全面评估 VPS 性能  
✅ **邮件告警配置** - 实时系统监控通知  
✅ **数据库一键部署** - MySQL/PostgreSQL/Redis/MongoDB  
✅ **开发环境管理** - Python/Node.js/Go/Java  
✅ **反向代理管理** - 简化 Nginx 配置  
✅ **系统快照与恢复** - 快速备份回滚  
✅ **入侵检测系统** - 多层安全防护  
✅ **流量监控** - vnstat/iftop/NetData  
✅ **文件同步服务** - Syncthing/Rclone  
✅ **日志分析工具** - 智能日志分析

现在 VPS 优化脚本已经成为一个**功能完整、专业强大**的 VPS 管理工具！🚀

---

**作者**: Kaiki  
**更新时间**: 2025-10-20  
**版本**: v2.2  
**功能数量**: 28+
