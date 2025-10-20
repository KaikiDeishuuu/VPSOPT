#!/bin/bash

################################################################################
# VPS服务器扩展功能脚本
# 包含高级功能：系统快照、入侵检测、流量监控、文件同步等
# 作者：Kaiki
# 日期：2025-10-20
################################################################################

# 引入主脚本的颜色定义（如果需要）
source "$(dirname "$0")/vps_optimize.sh" 2>/dev/null || true

# 24. 系统快照与恢复
setup_system_snapshot() {
    log_info "配置系统快照功能..."
    
    echo ""
    echo -e "${YELLOW}系统快照方案:${NC}"
    echo "1) Timeshift (类似Windows还原点)"
    echo "2) 自定义rsync快照"
    echo "3) 返回"
    read -p "请选择 [1-3]: " snapshot_choice
    
    case $snapshot_choice in
        1) install_timeshift ;;
        2) setup_rsync_snapshot ;;
        3) return ;;
        *) log_warning "无效选项" ;;
    esac
}

# 安装Timeshift
install_timeshift() {
    log_info "安装Timeshift..."
    
    # 添加PPA仓库
    add-apt-repository -y ppa:teejee2008/timeshift
    apt-get update >/dev/null 2>&1
    apt-get install -y timeshift
    
    log_success "Timeshift安装完成"
    
    echo ""
    echo -e "${YELLOW}Timeshift使用方法:${NC}"
    echo "  timeshift --create --comments '描述'  - 创建快照"
    echo "  timeshift --list                      - 列出快照"
    echo "  timeshift --restore                   - 恢复快照"
    echo "  timeshift --delete --snapshot '名称'  - 删除快照"
}

# 配置rsync快照
setup_rsync_snapshot() {
    log_info "配置rsync系统快照..."
    
    # 创建快照目录
    SNAPSHOT_DIR="/backup/snapshots"
    mkdir -p "$SNAPSHOT_DIR"
    
    # 创建快照脚本
    cat > /usr/local/bin/create_snapshot.sh <<'EOF'
#!/bin/bash

SNAPSHOT_DIR="/backup/snapshots"
SNAPSHOT_NAME="snapshot_$(date +%Y%m%d_%H%M%S)"
SNAPSHOT_PATH="$SNAPSHOT_DIR/$SNAPSHOT_NAME"

echo "创建系统快照: $SNAPSHOT_NAME"

# 创建快照目录
mkdir -p "$SNAPSHOT_PATH"

# 使用rsync备份系统
rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/backup/*"} / "$SNAPSHOT_PATH/"

echo "快照创建完成: $SNAPSHOT_PATH"
echo "快照信息:" > "$SNAPSHOT_PATH/snapshot.info"
echo "创建时间: $(date)" >> "$SNAPSHOT_PATH/snapshot.info"
echo "主机名: $(hostname)" >> "$SNAPSHOT_PATH/snapshot.info"
echo "内核: $(uname -r)" >> "$SNAPSHOT_PATH/snapshot.info"

# 只保留最近5个快照
cd "$SNAPSHOT_DIR"
ls -t | tail -n +6 | xargs -r rm -rf

echo "旧快照已清理，保留最近5个"
EOF
    
    chmod +x /usr/local/bin/create_snapshot.sh
    
    # 创建恢复脚本
    cat > /usr/local/bin/restore_snapshot.sh <<'EOF'
#!/bin/bash

SNAPSHOT_DIR="/backup/snapshots"

echo "可用的快照:"
ls -1 "$SNAPSHOT_DIR"
echo ""
read -p "输入要恢复的快照名称: " SNAPSHOT_NAME

if [ ! -d "$SNAPSHOT_DIR/$SNAPSHOT_NAME" ]; then
    echo "错误: 快照不存在"
    exit 1
fi

echo "警告: 此操作将恢复整个系统到快照状态"
read -p "确认恢复? (输入YES确认): " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "取消恢复"
    exit 0
fi

echo "开始恢复快照..."
rsync -aAXv --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/backup/*"} "$SNAPSHOT_DIR/$SNAPSHOT_NAME/" /

echo "快照恢复完成，建议重启系统"
EOF
    
    chmod +x /usr/local/bin/restore_snapshot.sh
    
    log_success "快照脚本配置完成"
    
    echo ""
    echo -e "${YELLOW}快照管理:${NC}"
    echo "  创建快照: /usr/local/bin/create_snapshot.sh"
    echo "  恢复快照: /usr/local/bin/restore_snapshot.sh"
    echo "  快照位置: $SNAPSHOT_DIR"
    
    # 询问是否立即创建快照
    echo ""
    read -p "是否立即创建第一个快照? (y/n): " create_now
    if [[ "$create_now" == "y" ]]; then
        /usr/local/bin/create_snapshot.sh
    fi
}

# 25. 入侵检测系统
setup_intrusion_detection() {
    log_info "配置入侵检测系统..."
    
    echo ""
    echo -e "${YELLOW}入侵检测工具:${NC}"
    echo "1) AIDE (文件完整性检查)"
    echo "2) rkhunter (Rootkit检测)"
    echo "3) ClamAV (病毒扫描)"
    echo "4) Lynis (安全审计)"
    echo "5) 全部安装 (推荐)"
    echo "6) 返回"
    read -p "请选择 [1-6]: " ids_choice
    
    case $ids_choice in
        1) install_aide ;;
        2) install_rkhunter ;;
        3) install_clamav ;;
        4) install_lynis ;;
        5)
            install_aide
            install_rkhunter
            install_clamav
            install_lynis
            ;;
        6) return ;;
        *) log_warning "无效选项" ;;
    esac
    
    log_success "入侵检测系统配置完成"
}

# 安装AIDE
install_aide() {
    log_info "安装AIDE (Advanced Intrusion Detection Environment)..."
    
    apt-get install -y aide aide-common
    
    # 初始化数据库
    log_info "初始化AIDE数据库 (可能需要几分钟)..."
    aideinit
    
    # 移动数据库
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    
    # 创建检查脚本
    cat > /usr/local/bin/aide_check.sh <<'EOF'
#!/bin/bash
echo "AIDE文件完整性检查"
aide --check
EOF
    
    chmod +x /usr/local/bin/aide_check.sh
    
    # 添加定时任务
    (crontab -l 2>/dev/null | grep -v "aide_check.sh"; echo "0 2 * * * /usr/local/bin/aide_check.sh | mail -s 'AIDE检查报告' root") | crontab -
    
    log_success "AIDE安装完成"
    echo "  检查命令: /usr/local/bin/aide_check.sh"
    echo "  定时检查: 每天凌晨2点"
}

# 安装rkhunter
install_rkhunter() {
    log_info "安装rkhunter (Rootkit Hunter)..."
    
    apt-get install -y rkhunter
    
    # 更新数据库
    rkhunter --update
    rkhunter --propupd
    
    # 创建扫描脚本
    cat > /usr/local/bin/rkhunter_scan.sh <<'EOF'
#!/bin/bash
echo "rkhunter扫描开始"
rkhunter --check --skip-keypress --report-warnings-only
EOF
    
    chmod +x /usr/local/bin/rkhunter_scan.sh
    
    # 添加定时任务
    (crontab -l 2>/dev/null | grep -v "rkhunter_scan.sh"; echo "0 3 * * * /usr/local/bin/rkhunter_scan.sh | mail -s 'rkhunter扫描报告' root") | crontab -
    
    log_success "rkhunter安装完成"
    echo "  扫描命令: /usr/local/bin/rkhunter_scan.sh"
    echo "  定时扫描: 每天凌晨3点"
}

# 安装ClamAV
install_clamav() {
    log_info "安装ClamAV (病毒扫描)..."
    
    apt-get install -y clamav clamav-daemon
    
    # 停止服务以更新病毒库
    systemctl stop clamav-freshclam
    
    # 更新病毒库
    log_info "更新病毒库 (可能需要几分钟)..."
    freshclam
    
    # 启动服务
    systemctl start clamav-freshclam
    systemctl enable clamav-freshclam
    
    # 创建扫描脚本
    cat > /usr/local/bin/clamscan_system.sh <<'EOF'
#!/bin/bash
echo "ClamAV系统扫描开始"
clamscan -r --exclude-dir="^/sys" --exclude-dir="^/proc" --exclude-dir="^/dev" / -l /var/log/clamav/scan.log
echo "扫描完成，日志: /var/log/clamav/scan.log"
EOF
    
    chmod +x /usr/local/bin/clamscan_system.sh
    
    log_success "ClamAV安装完成"
    echo "  扫描命令: /usr/local/bin/clamscan_system.sh"
    echo "  日志文件: /var/log/clamav/scan.log"
}

# 安装Lynis
install_lynis() {
    log_info "安装Lynis (安全审计工具)..."
    
    apt-get install -y lynis
    
    # 创建审计脚本
    cat > /usr/local/bin/lynis_audit.sh <<'EOF'
#!/bin/bash
echo "Lynis安全审计开始"
lynis audit system --quick
EOF
    
    chmod +x /usr/local/bin/lynis_audit.sh
    
    log_success "Lynis安装完成"
    echo "  审计命令: /usr/local/bin/lynis_audit.sh"
    echo "  完整审计: lynis audit system"
}

# 26. 流量监控
setup_traffic_monitoring() {
    log_info "配置流量监控..."
    
    echo ""
    echo -e "${YELLOW}流量监控工具:${NC}"
    echo "1) vnstat (轻量级流量统计)"
    echo "2) iftop (实时流量监控)"
    echo "3) NetData (全面监控面板)"
    echo "4) 全部安装"
    echo "5) 返回"
    read -p "请选择 [1-5]: " traffic_choice
    
    case $traffic_choice in
        1) install_vnstat ;;
        2) install_iftop ;;
        3) install_netdata ;;
        4)
            install_vnstat
            install_iftop
            install_netdata
            ;;
        5) return ;;
        *) log_warning "无效选项" ;;
    esac
    
    log_success "流量监控配置完成"
}

# 安装vnstat
install_vnstat() {
    log_info "安装vnstat..."
    
    apt-get install -y vnstat
    
    # 检测网络接口
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    
    # 初始化数据库
    vnstat -u -i $INTERFACE
    
    # 启动服务
    systemctl enable vnstat
    systemctl start vnstat
    
    log_success "vnstat安装完成"
    
    echo ""
    echo -e "${YELLOW}vnstat使用方法:${NC}"
    echo "  vnstat           - 查看流量统计"
    echo "  vnstat -h        - 按小时统计"
    echo "  vnstat -d        - 按天统计"
    echo "  vnstat -m        - 按月统计"
    echo "  vnstat -l        - 实时流量"
}

# 安装iftop
install_iftop() {
    log_info "安装iftop..."
    
    apt-get install -y iftop
    
    log_success "iftop安装完成"
    
    echo ""
    echo -e "${YELLOW}iftop使用方法:${NC}"
    echo "  iftop            - 启动实时监控"
    echo "  iftop -i eth0    - 指定网卡监控"
}

# 安装NetData
install_netdata() {
    log_info "安装NetData..."
    
    # 使用官方安装脚本
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
    
    log_success "NetData安装完成"
    
    # 获取服务器IP
    SERVER_IP=$(curl -s ifconfig.me)
    
    echo ""
    echo -e "${YELLOW}NetData信息:${NC}"
    echo "  访问地址: http://${SERVER_IP}:19999"
    echo "  配置文件: /etc/netdata/netdata.conf"
    echo ""
    echo -e "${CYAN}提示: 建议配置Nginx反向代理以增强安全性${NC}"
    
    # 询问是否在防火墙开放端口
    echo ""
    read -p "是否在防火墙开放19999端口? (y/n): " open_port
    if [[ "$open_port" == "y" ]]; then
        if systemctl is-active --quiet nftables; then
            nft add rule inet filter input tcp dport 19999 accept
            nft list ruleset > /etc/nftables.conf
        elif command -v iptables >/dev/null 2>&1; then
            iptables -I INPUT -p tcp --dport 19999 -j ACCEPT
            netfilter-persistent save >/dev/null 2>&1
        fi
        log_success "端口19999已开放"
    fi
}

# 27. 文件同步服务
setup_file_sync() {
    log_info "配置文件同步服务..."
    
    echo ""
    echo -e "${YELLOW}文件同步方案:${NC}"
    echo "1) Syncthing (去中心化同步)"
    echo "2) Rclone (云存储同步)"
    echo "3) 两者都安装"
    echo "4) 返回"
    read -p "请选择 [1-4]: " sync_choice
    
    case $sync_choice in
        1) install_syncthing ;;
        2) install_rclone ;;
        3)
            install_syncthing
            install_rclone
            ;;
        4) return ;;
        *) log_warning "无效选项" ;;
    esac
}

# 安装Syncthing
install_syncthing() {
    log_info "安装Syncthing..."
    
    # 添加仓库
    curl -s https://syncthing.net/release-key.txt | apt-key add -
    echo "deb https://apt.syncthing.net/ syncthing stable" | tee /etc/apt/sources.list.d/syncthing.list
    
    # 安装
    apt-get update >/dev/null 2>&1
    apt-get install -y syncthing
    
    # 创建系统服务
    cat > /etc/systemd/system/syncthing@.service <<'EOF'
[Unit]
Description=Syncthing
After=network.target

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -gui-address=0.0.0.0:8384
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    
    # 启动服务
    systemctl enable syncthing@root
    systemctl start syncthing@root
    
    log_success "Syncthing安装完成"
    
    SERVER_IP=$(curl -s ifconfig.me)
    echo ""
    echo -e "${YELLOW}Syncthing信息:${NC}"
    echo "  Web界面: http://${SERVER_IP}:8384"
    echo "  首次访问需要设置用户名和密码"
}

# 安装Rclone
install_rclone() {
    log_info "安装Rclone..."
    
    # 安装rclone
    curl https://rclone.org/install.sh | bash
    
    log_success "Rclone安装完成"
    
    echo ""
    echo -e "${YELLOW}Rclone使用指南:${NC}"
    echo "1. 配置云存储: rclone config"
    echo "2. 列出远程文件: rclone ls remote:path"
    echo "3. 同步文件: rclone sync source remote:dest"
    echo "4. 挂载云盘: rclone mount remote:path /mnt/path"
    echo ""
    echo -e "${CYAN}支持的云存储:${NC}"
    echo "  - Google Drive, Dropbox, OneDrive"
    echo "  - Amazon S3, 阿里云OSS, 腾讯云COS"
    echo "  - 以及50+其他云存储服务"
    
    # 询问是否立即配置
    echo ""
    read -p "是否立即配置云存储? (y/n): " config_now
    if [[ "$config_now" == "y" ]]; then
        rclone config
    fi
}

# 28. 反向代理管理器
setup_reverse_proxy() {
    log_info "配置反向代理管理..."
    
    echo ""
    echo -e "${YELLOW}反向代理功能:${NC}"
    echo "此功能将帮助您快速配置Nginx反向代理"
    echo ""
    
    # 检查Nginx
    if ! command -v nginx >/dev/null 2>&1; then
        log_warning "Nginx未安装"
        read -p "是否安装Nginx? (y/n): " install_nginx
        if [[ "$install_nginx" == "y" ]]; then
            apt-get install -y nginx
            systemctl enable nginx
            systemctl start nginx
        else
            return
        fi
    fi
    
    # 创建反向代理配置脚本
    cat > /usr/local/bin/add_proxy.sh <<'EOF'
#!/bin/bash

echo "=== Nginx反向代理配置向导 ==="
echo ""

read -p "域名 (如: example.com): " DOMAIN
read -p "后端地址 (如: 127.0.0.1): " BACKEND_IP
read -p "后端端口 (如: 3000): " BACKEND_PORT
read -p "是否启用SSL? (y/n): " ENABLE_SSL

# 创建配置文件
CONFIG_FILE="/etc/nginx/sites-available/${DOMAIN}"

cat > "$CONFIG_FILE" <<EOL
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

EOL

if [ "$ENABLE_SSL" = "y" ]; then
    cat >> "$CONFIG_FILE" <<EOL
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    ssl_certificate /etc/nginx/ssl/${DOMAIN}.crt;
    ssl_certificate_key /etc/nginx/ssl/${DOMAIN}.key;

EOL
fi

cat >> "$CONFIG_FILE" <<EOL
    location / {
        proxy_pass http://${BACKEND_IP}:${BACKEND_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# 启用配置
ln -sf "$CONFIG_FILE" /etc/nginx/sites-enabled/

# 测试配置
if nginx -t; then
    systemctl reload nginx
    echo ""
    echo "✓ 反向代理配置成功!"
    echo "  域名: ${DOMAIN}"
    echo "  后端: ${BACKEND_IP}:${BACKEND_PORT}"
    if [ "$ENABLE_SSL" = "y" ]; then
        echo "  SSL: 已启用 (请确保证书文件存在)"
    fi
else
    echo "✗ 配置测试失败，请检查配置"
    rm "/etc/nginx/sites-enabled/${DOMAIN}"
fi
EOF
    
    chmod +x /usr/local/bin/add_proxy.sh
    
    log_success "反向代理管理器配置完成"
    
    echo ""
    echo -e "${YELLOW}使用方法:${NC}"
    echo "  /usr/local/bin/add_proxy.sh - 添加反向代理"
    echo ""
    
    read -p "是否立即配置反向代理? (y/n): " config_now
    if [[ "$config_now" == "y" ]]; then
        /usr/local/bin/add_proxy.sh
    fi
}

# 29. 日志分析工具
setup_log_analysis() {
    log_info "配置日志分析工具..."
    
    # 创建日志分析脚本
    cat > /usr/local/bin/analyze_logs.sh <<'EOF'
#!/bin/bash

echo "=== 系统日志分析报告 ==="
echo "生成时间: $(date)"
echo ""

# SSH登录分析
echo "【SSH登录统计】"
echo "最近10次成功登录:"
grep "Accepted" /var/log/auth.log 2>/dev/null | tail -10 | awk '{print $1,$2,$3,$9,$11}'

echo ""
echo "最近10次失败登录:"
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 | awk '{print $1,$2,$3,$9,$11}'

echo ""
echo "登录失败次数TOP10 IP:"
grep "Failed password" /var/log/auth.log 2>/dev/null | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -10

# 系统错误
echo ""
echo "【系统错误】"
echo "最近20条错误:"
journalctl -p err -n 20 --no-pager

# 磁盘使用
echo ""
echo "【磁盘使用】"
df -h | grep -v tmpfs

# 内存使用
echo ""
echo "【内存使用】"
free -h

# 进程TOP10
echo ""
echo "【CPU使用TOP10】"
ps aux --sort=-%cpu | head -11

echo ""
echo "【内存使用TOP10】"
ps aux --sort=-%mem | head -11

# Nginx访问统计 (如果有)
if [ -f /var/log/nginx/access.log ]; then
    echo ""
    echo "【Nginx访问统计】"
    echo "今日访问量:"
    cat /var/log/nginx/access.log | grep $(date +%d/%b/%Y) | wc -l
    
    echo ""
    echo "访问TOP10 IP:"
    awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10
fi

echo ""
echo "=== 分析完成 ==="
EOF
    
    chmod +x /usr/local/bin/analyze_logs.sh
    
    log_success "日志分析工具配置完成"
    
    echo ""
    echo -e "${YELLOW}使用方法:${NC}"
    echo "  /usr/local/bin/analyze_logs.sh - 生成分析报告"
    echo ""
    
    read -p "是否立即生成分析报告? (y/n): " run_now
    if [[ "$run_now" == "y" ]]; then
        /usr/local/bin/analyze_logs.sh | less
    fi
}

# 主函数（扩展功能菜单）
show_extend_menu() {
    while true; do
        clear
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}         ${BOLD}${CYAN}🌟 VPS 扩展功能菜单 🌟${NC}                        ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BOLD}${CYAN}选择扩展功能：${NC}"
        echo ""
        echo -e "  ${BOLD}1${NC})  💾 系统快照与恢复"
        echo -e "  ${BOLD}2${NC})  🛡️  入侵检测系统"
        echo -e "  ${BOLD}3${NC})  📊 流量监控"
        echo -e "  ${BOLD}4${NC})  📁 文件同步服务"
        echo -e "  ${BOLD}5${NC})  🌐 反向代理管理"
        echo -e "  ${BOLD}6${NC})  🔍 日志分析工具"
        echo ""
        echo -e "  ${BOLD}q${NC})  🚪 返回主菜单"
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -n -e "${BOLD}${CYAN}➤${NC} 请输入选项: "
        read choice
        
        case $choice in
            1) setup_system_snapshot ;;
            2) setup_intrusion_detection ;;
            3) setup_traffic_monitoring ;;
            4) setup_file_sync ;;
            5) setup_reverse_proxy ;;
            6) setup_log_analysis ;;
            q|Q) return ;;
            *) echo "无效选项，请重试" ; sleep 2 ;;
        esac
        
        echo ""
        read -p "按回车继续..."
    done
}

# 如果直接运行此脚本，显示扩展菜单
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    show_extend_menu
fi
