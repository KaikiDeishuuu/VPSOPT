# 语言与时间配置功能更新说明

## 📅 更新日期：2025-10-20

## 🎯 更新概述

本次更新为 VPS 优化脚本新增了**系统语言配置**和**增强时间同步**功能，使用户能够更方便地设置服务器的语言环境和时区。

---

## ✨ 新增功能

### 1. 系统语言配置（功能 6）

**位置**：主菜单 → 6) 🌍 系统语言配置

#### 支持的语言选项

| 选项 | Locale      | 说明        | 适用地区   |
| ---- | ----------- | ----------- | ---------- |
| 1    | zh_CN.UTF-8 | 简体中文    | 中国大陆   |
| 2    | en_US.UTF-8 | 美国英语    | 国际通用   |
| 3    | zh_TW.UTF-8 | 繁体中文    | 台湾、香港 |
| 4    | ja_JP.UTF-8 | 日本语      | 日本       |
| 5    | 自定义      | 任意 Locale | 高级用户   |

#### 功能特性

✅ **自动安装** locales 包  
✅ **自动生成** 所选 locale  
✅ **自动配置** 系统默认语言  
✅ **环境变量** 自动更新  
✅ **UTF-8 编码** 保证兼容性

#### 配置效果

设置语言后会影响：

- 系统提示信息
- 日期和时间格式
- 货币和数字格式
- 程序界面语言
- 排序规则

---

### 2. 增强时间同步配置（功能 7）

**位置**：主菜单 → 7) 🕐 时间同步配置

#### 新增时区选项

| 选项 | 时区             | UTC 偏移 | 说明              |
| ---- | ---------------- | -------- | ----------------- |
| 1    | Asia/Shanghai    | UTC+8    | 中国标准时间      |
| 2    | Asia/Hong_Kong   | UTC+8    | 香港时间          |
| 3    | Asia/Tokyo       | UTC+9    | 日本标准时间      |
| 4    | America/New_York | UTC-5/-4 | 美国东部时间 🆕   |
| 5    | Europe/London    | UTC+0/+1 | 英国时间 🆕       |
| 6    | UTC              | UTC+0    | 协调世界时        |
| 7    | 自定义           | -        | 任意 IANA 时区 🆕 |

#### NTP 服务器选项

**国内 NTP 服务器**（推荐国内用户）

- 阿里云 NTP: `ntp.aliyun.com`
- 国家授时中心: `ntp.ntsc.ac.cn`
- 腾讯云 NTP: `time1.cloud.tencent.com`
- 中国 NTP 池: `cn.pool.ntp.org`

**国际 NTP 服务器**（推荐海外用户）

- NTP 池: `pool.ntp.org`
- Google NTP: `time1.google.com`
- Apple NTP: `time.apple.com`
- Cloudflare NTP: `time.cloudflare.com`
- Microsoft NTP: `time.windows.com`

#### 功能增强

✅ **自动同步** 启用 systemd-timesyncd  
✅ **备选服务器** 配置多个 NTP 源  
✅ **实时验证** 显示当前时间  
✅ **状态检查** 自动验证同步状态

---

## 🔧 ARM64 版本支持

ARM64 专用版本也完全支持语言和时间配置功能：

**位置**：ARM64 菜单 → 3) 🌍 语言与时间配置

### 配置方式

```bash
# 运行 ARM64 版本
sudo ./vps_optimize_arm64.sh

# 选择菜单 3
3) 🌍 语言与时间配置 (Locale/时区/NTP)

# 或在一键优化中选择
0) 🚀 一键优化
→ 配置系统语言? (y/n): y
→ 配置时间同步? (y/n): y
```

---

## 📖 使用方法

### 方式一：通过主菜单

```bash
# 运行脚本
sudo ./vps_optimize.sh

# 选择对应功能
6) 🌍 系统语言配置
7) 🕐 时间同步配置
```

### 方式二：一键优化包含

```bash
# 运行脚本
sudo ./vps_optimize.sh

# 选择一键优化
0) 🚀 执行全部优化

# 在过程中会自动配置语言和时间
```

---

## 🎯 使用场景

### 场景 1：国内服务器

```
语言：zh_CN.UTF-8（简体中文）
时区：Asia/Shanghai
NTP：国内服务器（阿里云/腾讯云）
```

**适用于**：

- 国内 VPS
- 面向中国用户的服务
- 需要中文日志的场景

### 场景 2：国际服务器

```
语言：en_US.UTF-8（美国英语）
时区：UTC 或服务所在地时区
NTP：国际服务器（Google/Cloudflare）
```

**适用于**：

- 海外 VPS
- 国际化服务
- 多地区协作

### 场景 3：生产环境

```
语言：en_US.UTF-8（推荐）
时区：UTC（推荐）
NTP：多个备用服务器
```

**原因**：

- 避免字符编码问题
- 统一时间基准
- 更好的兼容性

---

## ✅ 验证配置

### 检查语言设置

```bash
# 查看当前 locale
locale

# 查看系统默认 locale
cat /etc/default/locale

# 查看所有可用 locale
locale -a
```

### 检查时间设置

```bash
# 查看完整时间信息
timedatectl

# 查看时间同步状态
timedatectl timesync-status

# 查看 NTP 配置
cat /etc/systemd/timesyncd.conf
```

---

## 🔄 修改配置

### 修改语言

1. 再次运行脚本选择功能 6
2. 或手动修改：

```bash
# 编辑配置
sudo nano /etc/default/locale

# 重新生成
sudo locale-gen

# 重新登录生效
```

### 修改时区

1. 再次运行脚本选择功能 7
2. 或手动修改：

```bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

# 或列出所有时区
timedatectl list-timezones
```

### 修改 NTP 服务器

```bash
# 编辑配置
sudo nano /etc/systemd/timesyncd.conf

# 重启服务
sudo systemctl restart systemd-timesyncd
```

---

## 📝 配置文件位置

### 语言相关

- `/etc/default/locale` - 系统默认语言
- `/etc/locale.gen` - Locale 生成配置
- `/usr/share/i18n/locales/` - Locale 定义文件

### 时间相关

- `/etc/localtime` - 当前时区（符号链接）
- `/etc/timezone` - 时区名称
- `/etc/systemd/timesyncd.conf` - NTP 配置
- `/usr/share/zoneinfo/` - 时区数据库

---

## ⚠️ 注意事项

### 语言配置

1. **重新登录生效**

   - 语言设置需要重新登录 SSH 才能完全生效
   - 或执行 `source /etc/default/locale`

2. **编码建议**

   - 推荐使用 UTF-8 编码
   - 避免使用旧的编码格式

3. **服务器环境**
   - 生产环境建议使用 en_US.UTF-8
   - 避免因语言导致的兼容性问题

### 时间配置

1. **重要性**

   - 时间不准确会导致 SSL 证书验证失败
   - 影响日志记录和时间戳
   - 某些服务依赖准确时间

2. **NTP 同步**

   - 必须启用 NTP 自动同步
   - 定期检查同步状态
   - 使用可靠的 NTP 服务器

3. **分布式系统**
   - 建议统一使用 UTC 时区
   - 避免时区混乱
   - 简化跨区域协作

---

## 📚 相关文档

- [完整配置指南](LOCALE_TIME_GUIDE.md) - 详细的配置说明和最佳实践
- [快速参考](QUICK_REFERENCE.md) - 常用命令速查
- [项目文档](PROJECT.md) - 完整功能介绍

---

## 🔗 参考链接

- [Debian Locale 文档](https://wiki.debian.org/Locale)
- [systemd-timesyncd 手册](https://www.freedesktop.org/software/systemd/man/systemd-timesyncd.service.html)
- [IANA 时区数据库](https://www.iana.org/time-zones)
- [NTP Pool Project](https://www.ntppool.org/)

---

**更新作者**: Kaiki  
**更新日期**: 2025-10-20  
**脚本版本**: v2.1
