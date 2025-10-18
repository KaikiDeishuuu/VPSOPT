# VPS 优化脚本 - 快速参考

## 🚀 快速开始

```bash
chmod +x vps_optimize.sh && sudo ./vps_optimize.sh
```

## 📋 功能菜单

### 基础优化 (1-8)

```
1  - 换源加速           → 提升下载速度
2  - 账户安全配置       → 密码/用户/SSH密钥
3  - SSH安全加固        → 修改端口/安全参数
4  - 防火墙配置         → nftables/iptables
5  - 系统性能优化       → BBR/swap/内核参数
6  - 时间同步配置       → 时区/NTP服务器
7  - 安全加固           → Fail2Ban/自动更新
8  - 系统清理           → 清理缓存/日志/临时文件
```

### 环境配置 (9-14)

```
9  - Docker环境         → 安装Docker + 镜像加速
10 - Nginx + SSL        → Web服务器 + 自动化证书
11 - 常用工具           → 监控/网络/开发/压缩工具
12 - 自动备份           → 定时备份配置和数据
13 - 系统监控           → CPU/内存/磁盘/服务监控
14 - SSH连接优化        → 提升SSH连接速度
```

### 其他

```
0  - 一键优化           → 执行全部基础 + 可选环境
v  - 验证配置           → 查看系统状态
q  - 退出脚本
```

## 💡 推荐配置方案

### 方案 1: 最小化安全配置 (5 分钟)

适合：所有 VPS 服务器

```bash
运行脚本 → 选择 0 → 全部选 y → 环境配置全部选 n
```

完成：

- ✅ 系统源优化
- ✅ SSH 安全加固
- ✅ 防火墙配置
- ✅ 系统性能优化
- ✅ 安全防护

### 方案 2: Web 服务器配置 (10 分钟)

适合：部署网站、博客

```bash
运行脚本 → 选择 0 → 基础优化 → Docker选n → Nginx选y
```

完成：

- ✅ 基础安全优化
- ✅ Nginx Web 服务器
- ✅ SSL 证书自动化
- ✅ HTTP/HTTPS 配置

### 方案 3: Docker 开发环境 (10 分钟)

适合：容器化部署

```bash
运行脚本 → 选择 0 → 基础优化 → Docker选y → Nginx选n
```

完成：

- ✅ 基础安全优化
- ✅ Docker 环境
- ✅ 镜像加速
- ✅ 常用工具

### 方案 4: 全栈配置 (15 分钟)

适合：生产环境

```bash
运行脚本 → 选择 0 → 全部选 y
```

完成：

- ✅ 全部基础优化
- ✅ Docker + Nginx
- ✅ 自动备份
- ✅ 系统监控
- ✅ 常用工具

## 🎯 常用命令速查

### 系统管理

```bash
# 更新系统
apt update && apt upgrade -y

# 查看系统资源
htop                    # CPU/内存实时监控
df -h                   # 磁盘使用
free -h                 # 内存使用
uptime                  # 系统负载

# 查看进程
ps aux                  # 所有进程
top                     # 实时进程监控
```

### 防火墙管理

```bash
# nftables
nft list ruleset                    # 查看规则
systemctl restart nftables          # 重启防火墙
nano /etc/nftables.conf            # 编辑配置

# 添加端口示例 (编辑 /etc/nftables.conf)
tcp dport 8080 accept              # 开放8080端口
```

### SSH 管理

```bash
# 连接SSH (修改端口后)
ssh -p 端口号 user@ip

# 查看SSH配置
cat /etc/ssh/sshd_config

# 重启SSH
systemctl restart ssh

# 查看SSH日志
tail -f /var/log/auth.log
```

### Docker 管理

```bash
# 基础命令
docker ps                       # 运行中容器
docker ps -a                    # 所有容器
docker images                   # 镜像列表
docker logs 容器名              # 查看日志

# 容器操作
docker start 容器名             # 启动
docker stop 容器名              # 停止
docker restart 容器名           # 重启
docker rm 容器名                # 删除

# 镜像操作
docker pull 镜像名              # 拉取镜像
docker rmi 镜像名               # 删除镜像

# 清理
docker system prune -a          # 清理未使用资源
```

### Nginx 管理

```bash
# 基础命令
nginx -t                        # 测试配置
nginx -s reload                 # 重载配置
systemctl restart nginx         # 重启Nginx

# 配置文件
/etc/nginx/nginx.conf           # 主配置
/etc/nginx/sites-available/     # 可用站点
/etc/nginx/sites-enabled/       # 启用站点

# 日志
tail -f /var/log/nginx/access.log   # 访问日志
tail -f /var/log/nginx/error.log    # 错误日志

# 添加新站点
nano /etc/nginx/sites-available/域名
ln -s /etc/nginx/sites-available/域名 /etc/nginx/sites-enabled/
nginx -t && nginx -s reload
```

### SSL 证书管理

```bash
# 查看证书
~/.acme.sh/acme.sh --list

# 申请证书
~/.acme.sh/acme.sh --issue -d 域名 -w /var/www/html

# 强制续期
~/.acme.sh/acme.sh --renew -d 域名 --force

# 查看证书信息
openssl x509 -in /etc/nginx/ssl/域名.crt -text -noout
```

### 备份管理

```bash
# 手动备份
/usr/local/bin/auto_backup.sh

# 查看备份
ls -lh /backup/

# 恢复配置文件示例
cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config

# 解压备份
tar -xzf /backup/backup_*.tar.gz -C /restore/
```

### 监控管理

```bash
# 手动监控
/usr/local/bin/system_monitor.sh

# 查看监控日志
tail -f /var/log/monitor.log

# 查看备份日志
tail -f /var/log/backup.log

# 查看Fail2Ban状态
fail2ban-client status
fail2ban-client status sshd     # SSH保护状态
```

### 定时任务

```bash
# 查看定时任务
crontab -l

# 编辑定时任务
crontab -e

# 常用定时任务示例
0 2 * * * /usr/local/bin/auto_backup.sh        # 每天2点备份
0 * * * * /usr/local/bin/system_monitor.sh     # 每小时监控
0 3 * * 0 apt update && apt upgrade -y         # 每周日3点更新
```

## 🔧 配置文件位置

### 系统配置

```
/etc/apt/sources.list              # 软件源
/etc/sysctl.conf                   # 内核参数
/etc/sysctl.d/99-custom.conf       # 自定义内核参数
/etc/fstab                         # 文件系统挂载
```

### 安全配置

```
/etc/ssh/sshd_config               # SSH配置
/etc/nftables.conf                 # 防火墙规则
/etc/fail2ban/jail.d/              # Fail2Ban配置
```

### 服务配置

```
/etc/docker/daemon.json            # Docker配置
/etc/nginx/nginx.conf              # Nginx主配置
/etc/nginx/sites-available/        # Nginx站点配置
/etc/systemd/timesyncd.conf        # 时间同步配置
```

### 脚本和工具

```
/usr/local/bin/auto_backup.sh      # 备份脚本
/usr/local/bin/system_monitor.sh   # 监控脚本
~/.acme.sh/                        # SSL证书工具
```

### 日志文件

```
/var/log/auth.log                  # 认证日志
/var/log/syslog                    # 系统日志
/var/log/nginx/                    # Nginx日志
/var/log/backup.log                # 备份日志
/var/log/monitor.log               # 监控日志
```

## 🚨 紧急情况处理

### SSH 无法连接

```bash
# 通过VPS控制面板进入VNC/控制台
# 检查SSH服务
systemctl status ssh
systemctl restart ssh

# 检查防火墙
nft list ruleset
# 临时关闭防火墙测试
systemctl stop nftables

# 恢复SSH配置
cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
systemctl restart ssh
```

### 防火墙锁死

```bash
# 通过控制台登录
# 临时关闭防火墙
systemctl stop nftables

# 恢复配置
cp /etc/nftables.conf.backup.* /etc/nftables.conf
systemctl start nftables
```

### 磁盘空间不足

```bash
# 查看磁盘使用
df -h
du -sh /* | sort -rh | head -10

# 清理日志
journalctl --vacuum-time=1d
find /var/log -type f -name "*.log" -size +100M -delete

# 清理Docker
docker system prune -a

# 清理包缓存
apt clean
```

### 服务无法启动

```bash
# 查看服务状态
systemctl status 服务名

# 查看详细日志
journalctl -u 服务名 -n 100 --no-pager

# 测试配置文件
nginx -t                 # Nginx
sshd -T                  # SSH
docker info              # Docker
```

## 📊 性能优化检查

### 网络性能

```bash
# 检查BBR是否启用
sysctl net.ipv4.tcp_congestion_control

# 网络速度测试
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -

# 查看网络连接
ss -tuln
netstat -tuln
```

### 系统性能

```bash
# CPU信息
lscpu
cat /proc/cpuinfo

# 内存信息
free -h
cat /proc/meminfo

# 磁盘IO
iostat -x 1
iotop
```

## 💡 小技巧

### 快速测试端口

```bash
# 测试端口是否开放
telnet IP 端口
nc -zv IP 端口

# 查看监听端口
ss -tuln | grep LISTEN
netstat -tuln | grep LISTEN
```

### 快速查找大文件

```bash
# 查找大于100MB的文件
find / -type f -size +100M -exec ls -lh {} \;

# 查看目录大小
du -sh /var/* | sort -rh | head -10
```

### 批量操作

```bash
# 批量停止容器
docker stop $(docker ps -q)

# 批量删除日志
find /var/log -name "*.log" -type f -delete

# 批量更改权限
find /path -type f -exec chmod 644 {} \;
```

## 📞 获取帮助

### 查看帮助文档

```bash
man 命令名              # 查看命令手册
命令名 --help          # 查看命令帮助
```

### 在线资源

- Docker 文档: https://docs.docker.com/
- Nginx 文档: https://nginx.org/en/docs/
- acme.sh 文档: https://github.com/acmesh-official/acme.sh
- Fail2Ban 文档: https://www.fail2ban.org/

---

**作者:** Kaiki  
**更新:** 2025-10-19
