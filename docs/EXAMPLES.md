# 使用示例和最佳实践

## 🎯 实战场景

### 场景 1: 新购买的 VPS 初始化

**背景：** 刚购买了一台 Debian 12 的 VPS，需要快速配置成安全可用的状态

**操作步骤：**

```bash
# 1. 连接到VPS
ssh root@your-vps-ip

# 2. 下载并运行脚本
wget https://your-server.com/vps_optimize.sh
chmod +x vps_optimize.sh
sudo ./vps_optimize.sh

# 3. 选择一键优化
选择: 0

# 4. 按提示进行配置
选择软件源: 1 (阿里云，国内用户)
设置root密码: y → 输入强密码
创建普通用户: y → 用户名: admin → 设置密码
配置SSH密钥: n (暂不配置)
修改SSH端口: y → 54321
防火墙类型: 1 (nftables)
配置swap: y → 2GB
时区: 1 (Asia/Shanghai)
NTP服务器: 1 (国内)
安装Fail2Ban: y
自动更新: y
系统清理: y

# 5. 环境配置 (可选)
Docker: n (暂不需要)
Nginx: n (暂不需要)
常用工具: y → 6 (全部安装)
自动备份: y → 每天凌晨2点
系统监控: y → 每小时检查
SSH优化: y

# 6. 等待完成，查看配置报告
cat /root/vps_setup_info.txt
```

**配置完成后：**

```bash
# 7. 测试新的SSH连接（重要！）
# 不要关闭当前SSH，打开新终端测试
ssh -p 54321 root@your-vps-ip

# 8. 确认可以连接后，断开旧连接
```

**结果：**

- ✅ 系统安全加固完成
- ✅ 性能优化完成
- ✅ 常用工具已安装
- ✅ 自动备份已配置
- ✅ 监控已启用

---

### 场景 2: 搭建个人博客网站

**背景：** 需要搭建 WordPress 博客，需要 Nginx + SSL 证书

**操作步骤：**

```bash
# 1. 运行脚本
sudo ./vps_optimize.sh

# 2. 先完成基础优化（如果还没做）
选择: 1-8 (按需执行)

# 3. 配置Nginx和SSL
选择: 10

# 4. Nginx配置流程
是否安装Nginx: y
是否优化配置: y
是否配置SSL: y

# 5. SSL证书配置
输入域名: blog.example.com
选择验证方式: 3 (DNS API，最推荐)
选择DNS提供商: 1 (Cloudflare)
输入Cloudflare API Key: [你的API Key]
输入Cloudflare Email: [你的邮箱]
是否安装证书到Nginx: y
是否开放80/443端口: y

# 6. 配置网站目录
mkdir -p /var/www/blog.example.com
```

**创建博客配置：**

```bash
# 编辑Nginx配置
nano /etc/nginx/sites-available/blog.example.com
```

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name blog.example.com www.blog.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name blog.example.com www.blog.example.com;

    ssl_certificate /etc/nginx/ssl/blog.example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/blog.example.com.key;

    root /var/www/blog.example.com;
    index index.php index.html;

    # WordPress伪静态规则
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # PHP处理
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }

    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 365d;
    }
}
```

```bash
# 启用配置
ln -s /etc/nginx/sites-available/blog.example.com /etc/nginx/sites-enabled/
nginx -t && nginx -s reload
```

**结果：**

- ✅ Nginx 已配置并优化
- ✅ SSL 证书已自动申请并配置
- ✅ HTTPS 已启用
- ✅ 防火墙已开放 Web 端口

---

### 场景 3: Docker 容器化部署

**背景：** 需要部署多个 Docker 应用，需要 Docker 环境

**操作步骤：**

```bash
# 1. 运行脚本
sudo ./vps_optimize.sh

# 2. 配置Docker环境
选择: 9

# 3. Docker配置流程
是否安装Docker: y
选择Docker源: 1 (阿里云)
是否配置镜像加速: y
是否添加用户到docker组: y → admin

# 4. 重新登录以应用docker组权限
exit
ssh -p 54321 admin@your-vps-ip

# 5. 测试Docker
docker --version
docker run hello-world
```

**部署示例应用：**

```bash
# 部署Nginx容器
docker run -d \
  --name my-nginx \
  -p 80:80 \
  -v /var/www/html:/usr/share/nginx/html:ro \
  nginx:alpine

# 部署MySQL数据库
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=your_password \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# 使用Docker Compose
cat > docker-compose.yml <<EOF
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: your_password
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
EOF

docker compose up -d
```

**结果：**

- ✅ Docker 环境已配置
- ✅ 镜像加速已启用
- ✅ 可以无 sudo 运行 docker 命令
- ✅ Docker Compose 可用

---

### 场景 4: 生产环境全栈配置

**背景：** 需要部署生产环境，要求安全、稳定、可监控

**操作步骤：**

```bash
# 1. 完整配置
sudo ./vps_optimize.sh
选择: 0 (一键优化)

# 2. 全部选择 y
基础优化: 全部 y
Docker: y
Nginx: y
常用工具: y → 6 (全部安装)
自动备份: y → 每天凌晨2点
系统监控: y → 每小时检查
SSH优化: y

# 3. 配置完成后的检查
```

**安全加固检查：**

```bash
# 检查SSH配置
sshd -T | grep -E "port|permitroot|password"

# 检查防火墙规则
nft list ruleset

# 检查Fail2Ban
fail2ban-client status

# 检查服务状态
systemctl status ssh nginx docker

# 查看监控状态
/usr/local/bin/system_monitor.sh
```

**性能测试：**

```bash
# 网络速度
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -

# 磁盘IO
dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync
rm /tmp/test

# CPU性能
sysbench cpu --cpu-max-prime=20000 run

# 内存性能
sysbench memory --memory-total-size=10G run
```

**配置应用部署：**

```bash
# 创建项目目录
mkdir -p /var/www/myapp

# 配置Nginx反向代理
cat > /etc/nginx/sites-available/myapp <<EOF
server {
    listen 80;
    server_name app.example.com;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.example.com;

    ssl_certificate /etc/nginx/ssl/app.example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/app.example.com.key;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
nginx -t && nginx -s reload
```

**配置数据库备份：**

```bash
# 编辑备份脚本，添加MySQL备份
nano /usr/local/bin/auto_backup.sh

# 在适当位置添加：
# if command -v mysqldump >/dev/null 2>&1; then
#     mysqldump -u root -p'your_password' --all-databases > "${BACKUP_DIR}/${BACKUP_NAME}/mysql_backup.sql"
# fi
```

**结果：**

- ✅ 全部安全措施已部署
- ✅ 性能优化已完成
- ✅ Docker + Nginx 环境就绪
- ✅ 自动备份和监控已启用
- ✅ 生产环境已就绪

---

### 场景 5: 维护现有服务器

**背景：** 服务器已运行一段时间，需要增强安全性和监控

**操作步骤：**

```bash
# 1. 运行脚本
sudo ./vps_optimize.sh

# 2. 选择性配置
选择: 7 (安全加固)
→ 安装Fail2Ban: y
→ 自动更新: y

选择: 12 (配置自动备份)
→ 配置备份: y

选择: 13 (配置系统监控)
→ 配置监控: y

选择: 14 (SSH连接优化)
→ 优化SSH: y

# 3. 验证配置
选择: v
```

**定期维护任务：**

```bash
# 每周执行一次
# 1. 更新系统
apt update && apt upgrade -y

# 2. 清理系统
apt autoremove -y
apt autoclean
journalctl --vacuum-time=7d

# 3. 检查磁盘空间
df -h

# 4. 检查备份
ls -lh /backup/

# 5. 查看监控日志
tail -100 /var/log/monitor.log

# 6. 查看安全日志
fail2ban-client status
tail -100 /var/log/auth.log | grep Failed

# 7. 检查Docker容器
docker ps -a
docker system df
```

**结果：**

- ✅ 安全性得到增强
- ✅ 自动备份已启用
- ✅ 系统监控已配置
- ✅ SSH 连接更快
- ✅ 定期维护流程建立

---

## 💡 最佳实践

### 1. 安全性最佳实践

```bash
# ✅ 使用SSH密钥认证
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-copy-id -p 54321 admin@your-vps-ip

# ✅ 禁用密码登录（配置密钥后）
nano /etc/ssh/sshd_config
# PasswordAuthentication no
systemctl restart ssh

# ✅ 定期更新系统
# 添加到crontab
0 3 * * 0 apt update && apt upgrade -y

# ✅ 定期检查安全日志
grep "Failed password" /var/log/auth.log
fail2ban-client status sshd

# ✅ 使用强密码
# 至少16位，包含大小写字母、数字、特殊字符
```

### 2. 性能优化最佳实践

```bash
# ✅ 定期清理日志
journalctl --vacuum-time=7d
find /var/log -name "*.gz" -delete

# ✅ 清理Docker
docker system prune -a --volumes -f

# ✅ 监控资源使用
htop
iotop
nload

# ✅ 优化数据库
# MySQL优化
mysqlcheck -u root -p --auto-repair --optimize --all-databases
```

### 3. 备份策略最佳实践

```bash
# ✅ 3-2-1备份原则
# 3份备份，2种介质，1份异地

# 本地备份（自动）
/usr/local/bin/auto_backup.sh

# 下载到本地（每周）
scp -P 54321 root@vps:/backup/backup_*.tar.gz ~/vps-backups/

# 上传到云存储（可选）
# 使用rclone同步到云盘
```

### 4. 监控告警最佳实践

```bash
# ✅ 配置邮件告警
# 安装mailutils
apt install -y mailutils

# 修改监控脚本，添加邮件通知
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "CPU使用率过高: ${CPU_USAGE}%" | mail -s "服务器告警" your@email.com
fi

# ✅ 配置Webhook通知（可选）
# 发送到Telegram/钉钉/企业微信等
```

### 5. Docker 使用最佳实践

```bash
# ✅ 使用docker-compose管理应用
# ✅ 限制容器资源
docker run -d --memory="512m" --cpus="0.5" nginx

# ✅ 定期清理
docker system prune -a --volumes

# ✅ 使用健康检查
docker run -d \
  --health-cmd="curl -f http://localhost || exit 1" \
  --health-interval=30s \
  nginx

# ✅ 数据持久化使用volume
docker volume create mydata
docker run -v mydata:/data nginx
```

---

## 🔍 常见问题解决

### 问题 1: SSH 端口修改后无法连接

**原因：** 防火墙未开放新端口

**解决：**

```bash
# 通过VPS控制台登录
# 检查防火墙规则
nft list ruleset

# 开放SSH端口
nano /etc/nftables.conf
# 添加: tcp dport 54321 accept
systemctl restart nftables

# 或临时关闭防火墙测试
systemctl stop nftables
```

### 问题 2: Docker 镜像拉取失败

**原因：** 镜像源配置问题或网络问题

**解决：**

```bash
# 检查Docker配置
cat /etc/docker/daemon.json

# 测试网络
ping -c 4 docker.io

# 更换镜像源
nano /etc/docker/daemon.json
# 添加更多镜像源
systemctl restart docker

# 使用代理（如果需要）
# 编辑 /etc/systemd/system/docker.service.d/http-proxy.conf
```

### 问题 3: SSL 证书申请失败

**原因：** 域名解析未正确配置

**解决：**

```bash
# 检查域名解析
dig example.com
nslookup example.com

# 确保域名指向VPS IP
# A记录: example.com → VPS_IP

# 使用DNS API方式（最稳定）
~/.acme.sh/acme.sh --issue -d example.com --dns dns_cf

# 查看详细错误
~/.acme.sh/acme.sh --issue -d example.com -w /var/www/html --debug
```

### 问题 4: 磁盘空间不足

**解决：**

```bash
# 查看磁盘使用
df -h
du -sh /* | sort -rh | head -10

# 清理日志
journalctl --vacuum-time=3d
find /var/log -name "*.gz" -delete
find /var/log -name "*.log" -size +100M -delete

# 清理Docker
docker system prune -a --volumes -f

# 清理包缓存
apt clean

# 清理旧备份
find /backup -name "backup_*.tar.gz" -mtime +7 -delete
```

---

## 📝 检查清单

### 部署后检查清单

```
□ SSH可以正常连接（新端口）
□ 防火墙规则正确
□ Fail2Ban运行正常
□ 时间同步正常
□ BBR已启用
□ Docker运行正常（如果安装）
□ Nginx运行正常（如果安装）
□ SSL证书有效（如果配置）
□ 备份脚本正常（如果配置）
□ 监控脚本正常（如果配置）
□ 已创建普通用户
□ 已配置SSH密钥（推荐）
□ 已测试应用部署
□ 已将重要信息记录到本地
```

### 安全检查清单

```
□ Root密码已修改为强密码
□ SSH端口已修改
□ 防火墙已启用
□ Fail2Ban已配置
□ 不必要的服务已关闭
□ 系统已更新到最新
□ 已配置自动安全更新
□ 已配置SSH密钥认证
□ 已禁用密码登录（可选）
□ 已配置日志监控
```

---

**作者：** Kaiki  
**更新：** 2025-10-19
