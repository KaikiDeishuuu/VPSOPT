# 系统语言与时间配置指南

## 📋 目录

- [语言配置 (Locale)](#语言配置-locale)
- [时间配置 (Time & Timezone)](#时间配置-time--timezone)
- [常见问题](#常见问题)
- [手动配置方法](#手动配置方法)

---

## 🌍 语言配置 (Locale)

### 功能说明

系统语言配置决定了系统界面、日期格式、货币符号等显示方式。

### 支持的语言选项

#### 1. 简体中文 (zh_CN.UTF-8)

- **适用场景**: 中国大陆用户
- **特点**:
  - 日期格式: YYYY-MM-DD
  - 货币符号: ¥
  - 数字分隔符: 逗号

#### 2. 美国英语 (en_US.UTF-8)

- **适用场景**: 国际用户、英文环境
- **特点**:
  - 日期格式: MM/DD/YYYY
  - 货币符号: $
  - 系统默认推荐

#### 3. 繁体中文 (zh_TW.UTF-8)

- **适用场景**: 台湾、香港用户
- **特点**:
  - 日期格式: YYYY/MM/DD
  - 货币符号: NT$

#### 4. 日本语 (ja_JP.UTF-8)

- **适用场景**: 日本用户
- **特点**:
  - 日期格式: YYYY 年 MM 月 DD 日
  - 货币符号: ¥

#### 5. 自定义 Locale

支持任意标准 locale 格式，如：

- `en_GB.UTF-8` - 英国英语
- `de_DE.UTF-8` - 德语
- `fr_FR.UTF-8` - 法语
- `ko_KR.UTF-8` - 韩语

### 配置效果

设置 locale 后会影响：

- ✅ 系统提示信息语言
- ✅ 日期和时间显示格式
- ✅ 货币和数字格式
- ✅ 排序规则
- ✅ 程序界面语言（如支持）

### 配置步骤

1. 运行脚本选择 **"6) 系统语言配置"**
2. 从列表中选择所需语言
3. 脚本会自动：
   - 安装 locales 包
   - 生成所选 locale
   - 更新系统默认设置
   - 配置环境变量

### 验证配置

```bash
# 查看当前 locale 设置
locale

# 查看可用的 locale
locale -a

# 查看系统默认 locale
cat /etc/default/locale
```

---

## 🕐 时间配置 (Time & Timezone)

### 时区配置

#### 支持的时区选项

1. **Asia/Shanghai (中国标准时间 CST)**

   - UTC+8
   - 覆盖: 中国大陆
   - 推荐: 国内用户

2. **Asia/Hong_Kong (香港时间 HKT)**

   - UTC+8
   - 覆盖: 香港特别行政区

3. **Asia/Tokyo (日本标准时间 JST)**

   - UTC+9
   - 覆盖: 日本

4. **America/New_York (美国东部时间 EST/EDT)**

   - UTC-5 (冬季) / UTC-4 (夏季)
   - 覆盖: 美国东部

5. **Europe/London (英国时间 GMT/BST)**

   - UTC+0 (冬季) / UTC+1 (夏季)
   - 覆盖: 英国

6. **UTC (协调世界时)**

   - UTC+0
   - 不使用夏令时
   - 推荐: 服务器默认

7. **自定义时区**
   - 支持所有 IANA 时区数据库中的时区
   - 示例: Asia/Singapore, America/Los_Angeles

### NTP 时间同步

#### 国内 NTP 服务器 (推荐国内用户)

- **阿里云 NTP**: `ntp.aliyun.com`
- **国家授时中心**: `ntp.ntsc.ac.cn`
- **腾讯云 NTP**: `time1.cloud.tencent.com`
- **中国 NTP 池**: `cn.pool.ntp.org`

**优点**:

- ✅ 低延迟
- ✅ 高稳定性
- ✅ 国内访问快

#### 国际 NTP 服务器 (推荐海外用户)

- **NTP 池**: `pool.ntp.org`
- **Google NTP**: `time1.google.com`
- **Apple NTP**: `time.apple.com`
- **Cloudflare NTP**: `time.cloudflare.com`
- **Microsoft NTP**: `time.windows.com`

**优点**:

- ✅ 全球分布
- ✅ 高可用性
- ✅ 大厂维护

### 配置步骤

1. 运行脚本选择 **"7) 时间同步配置"**
2. 选择时区
3. 选择 NTP 服务器类型
4. 脚本会自动：
   - 设置系统时区
   - 安装 systemd-timesyncd
   - 配置 NTP 服务器
   - 启用自动时间同步

### 验证配置

```bash
# 查看当前时间和时区
timedatectl

# 查看时间同步状态
timedatectl status

# 查看 NTP 同步详情
timedatectl timesync-status

# 手动触发时间同步
systemctl restart systemd-timesyncd

# 查看 NTP 配置
cat /etc/systemd/timesyncd.conf
```

---

## ❓ 常见问题

### Q1: 修改语言后没有生效？

**A**: 语言设置需要重新登录 SSH 才能完全生效。

```bash
# 重新登录或执行
source /etc/default/locale
```

### Q2: 如何查看所有可用的时区？

**A**: 使用以下命令：

```bash
timedatectl list-timezones
# 或搜索特定区域
timedatectl list-timezones | grep Asia
```

### Q3: 时间不准确怎么办？

**A**: 检查时间同步状态：

```bash
# 查看同步状态
timedatectl timesync-status

# 重启时间同步服务
systemctl restart systemd-timesyncd

# 强制同步
timedatectl set-ntp true
```

### Q4: 能否设置多个 locale？

**A**: 可以生成多个 locale，但系统只能有一个默认：

```bash
# 生成多个 locale
locale-gen zh_CN.UTF-8
locale-gen en_US.UTF-8

# 切换默认 locale
update-locale LANG=zh_CN.UTF-8
```

### Q5: VPS 时区设置会影响日志记录吗？

**A**: 是的，所有系统日志和应用日志的时间戳都会使用设置的时区。建议：

- 生产环境统一使用 UTC
- 个人使用可选本地时区

### Q6: 如何只改变部分 locale 设置？

**A**: 可以单独设置环境变量：

```bash
# 只改变时间格式
export LC_TIME=en_US.UTF-8

# 只改变货币格式
export LC_MONETARY=zh_CN.UTF-8
```

---

## 🛠️ 手动配置方法

### 手动配置 Locale

#### 方法一：使用 dpkg-reconfigure

```bash
# 交互式配置
dpkg-reconfigure locales
```

#### 方法二：手动编辑

```bash
# 1. 编辑 locale.gen
nano /etc/locale.gen

# 2. 取消注释需要的 locale，例如：
# zh_CN.UTF-8 UTF-8
# en_US.UTF-8 UTF-8

# 3. 生成 locale
locale-gen

# 4. 设置系统默认
update-locale LANG=zh_CN.UTF-8
```

#### 方法三：使用 localectl（systemd）

```bash
# 设置系统 locale
localectl set-locale LANG=zh_CN.UTF-8

# 查看当前设置
localectl status
```

### 手动配置时区

#### 方法一：使用 timedatectl

```bash
# 设置时区
timedatectl set-timezone Asia/Shanghai

# 启用 NTP
timedatectl set-ntp true
```

#### 方法二：使用 ln 链接

```bash
# 删除旧的时区链接
rm /etc/localtime

# 创建新的时区链接
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

#### 方法三：使用 dpkg-reconfigure

```bash
dpkg-reconfigure tzdata
```

### 手动配置 NTP

#### 编辑 timesyncd 配置

```bash
# 编辑配置文件
nano /etc/systemd/timesyncd.conf

# 添加以下内容：
[Time]
NTP=ntp.aliyun.com ntp.ntsc.ac.cn
FallbackNTP=cn.pool.ntp.org

# 重启服务
systemctl restart systemd-timesyncd
```

#### 使用 ntpdate（一次性同步）

```bash
# 安装 ntpdate
apt-get install ntpdate

# 手动同步时间
ntpdate ntp.aliyun.com
```

---

## 📊 配置文件位置

### Locale 相关文件

- `/etc/default/locale` - 系统默认 locale
- `/etc/locale.gen` - locale 生成配置
- `/usr/share/i18n/locales/` - locale 定义文件

### 时区相关文件

- `/etc/localtime` - 当前时区（符号链接）
- `/etc/timezone` - 时区名称文本文件
- `/usr/share/zoneinfo/` - 时区数据库
- `/etc/systemd/timesyncd.conf` - NTP 配置

---

## 🎯 最佳实践

### Locale 设置建议

1. **服务器环境**: 建议使用 `en_US.UTF-8`

   - 避免字符编码问题
   - 更好的软件兼容性
   - 日志更易分析

2. **桌面环境**: 使用本地语言

   - 提升用户体验
   - 符合使用习惯

3. **多用户环境**:
   - 系统保持英文
   - 用户目录设置个人语言

### 时区设置建议

1. **单服务器**: 使用本地时区

   - 方便日志查看
   - 符合业务时间

2. **分布式系统**: 统一使用 UTC

   - 避免时区混乱
   - 便于跨区域协作
   - 简化日志分析

3. **必须启用 NTP**:
   - 保证时间准确
   - 避免证书问题
   - 确保日志顺序

---

## 🔗 相关资源

- [IANA 时区数据库](https://www.iana.org/time-zones)
- [GNU Locale 文档](https://www.gnu.org/software/libc/manual/html_node/Locales.html)
- [systemd-timesyncd 文档](https://www.freedesktop.org/software/systemd/man/systemd-timesyncd.service.html)
- [NTP Pool Project](https://www.ntppool.org/)

---

## 📝 更新日志

### v2.1 (2025-10-20)

- ✨ 新增系统语言配置功能
- ✨ 增强时间同步配置选项
- ✨ 添加更多时区选项
- ✨ 支持自定义 locale 和时区
- 📚 完善配置文档

---

**作者**: Kaiki  
**项目**: VPS 优化脚本  
**更新**: 2025-10-20
