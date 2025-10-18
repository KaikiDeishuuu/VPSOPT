#!/bin/bash

################################################################################
# VPS服务器优化脚本
# 功能：一键完成VPS初始化配置和安全加固
# 作者：Kaiki
# 日期：2025-10-19
# 使用方法：chmod +x vps_optimize.sh && sudo ./vps_optimize.sh
################################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 显示标题
show_header() {
    clear
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║           VPS 服务器优化脚本 v1.0                        ║"
    echo "║       让你的服务器从"裸机"变成性能强劲的战斗机          ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查root权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行，请使用 sudo 或以root用户身份运行"
        exit 1
    fi
}

# 检测系统版本
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        log_info "检测到系统: $PRETTY_NAME"
    else
        log_error "无法检测系统版本"
        exit 1
    fi
    
    if [[ "$OS" != "debian" && "$OS" != "ubuntu" ]]; then
        log_warning "此脚本主要针对Debian/Ubuntu系统优化"
        read -p "是否继续? (y/n): " continue_choice
        [[ "$continue_choice" != "y" ]] && exit 0
    fi
}

# 1. 换源加速
optimize_sources() {
    log_info "开始换源优化..."
    
    # 备份原始源配置
    if [ -f /etc/apt/sources.list ]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)
        log_success "已备份原始源配置"
    fi
    
    # 安装HTTPS证书支持
    apt-get install -y ca-certificates lsb-release >/dev/null 2>&1
    
    # 获取系统版本代号
    CODENAME=$(lsb_release -cs)
    log_info "系统版本代号: $CODENAME"
    
    echo ""
    echo "请选择软件源类型："
    echo "1) 阿里云源 (推荐国内用户)"
    echo "2) 中科大源 (教育网用户)"
    echo "3) 清华源 (老牌稳定)"
    echo "4) 官方源 (海外用户)"
    echo "5) 香港源 (亚洲地区)"
    echo "6) 跳过换源"
    read -p "请输入选项 [1-6]: " source_choice
    
    case $source_choice in
        1)
            log_info "配置阿里云源..."
            cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb-src http://mirrors.aliyun.com/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb-src http://mirrors.aliyun.com/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
deb-src http://mirrors.aliyun.com/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
EOF
            ;;
        2)
            log_info "配置中科大源..."
            cat > /etc/apt/sources.list <<EOF
deb http://mirrors.ustc.edu.cn/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb-src http://mirrors.ustc.edu.cn/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb http://mirrors.ustc.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb-src http://mirrors.ustc.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb http://mirrors.ustc.edu.cn/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
deb-src http://mirrors.ustc.edu.cn/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
EOF
            ;;
        3)
            log_info "配置清华源..."
            cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
EOF
            ;;
        4)
            log_info "配置官方源..."
            cat > /etc/apt/sources.list <<EOF
deb https://deb.debian.org/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb https://deb.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb https://deb.debian.org/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
EOF
            ;;
        5)
            log_info "配置香港源..."
            cat > /etc/apt/sources.list <<EOF
deb http://ftp.hk.debian.org/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb-src http://ftp.hk.debian.org/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb http://ftp.hk.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb-src http://ftp.hk.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb http://ftp.hk.debian.org/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
deb-src http://ftp.hk.debian.org/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
EOF
            ;;
        6)
            log_info "跳过换源操作"
            return
            ;;
        *)
            log_warning "无效选项，跳过换源"
            return
            ;;
    esac
    
    log_info "更新软件包列表..."
    apt update
    log_success "换源完成！"
    sleep 2
}

# 2. 账户安全
setup_security() {
    log_info "开始配置账户安全..."
    
    # 设置root密码
    echo ""
    read -p "是否设置新的root密码? (y/n): " set_root_pwd
    if [[ "$set_root_pwd" == "y" ]]; then
        read -sp "请输入新的root密码: " root_password
        echo ""
        read -sp "请再次确认密码: " root_password_confirm
        echo ""
        
        if [[ "$root_password" == "$root_password_confirm" ]]; then
            echo "root:$root_password" | chpasswd
            log_success "Root密码设置成功"
        else
            log_error "两次密码不一致，跳过密码设置"
        fi
    fi
    
    # 创建普通用户
    echo ""
    read -p "是否创建新的普通用户? (y/n): " create_user
    if [[ "$create_user" == "y" ]]; then
        read -p "请输入用户名: " username
        
        if id "$username" &>/dev/null; then
            log_warning "用户 $username 已存在，跳过创建"
        else
            useradd -m -s /bin/bash "$username"
            
            read -sp "请输入用户密码: " user_password
            echo ""
            echo "$username:$user_password" | chpasswd
            
            # 添加sudo权限
            usermod -aG sudo "$username" 2>/dev/null || usermod -aG wheel "$username" 2>/dev/null
            
            log_success "用户 $username 创建成功并已添加sudo权限"
        fi
    fi
    
    # 配置SSH密钥
    echo ""
    read -p "是否配置SSH密钥认证? (y/n): " setup_ssh_key
    if [[ "$setup_ssh_key" == "y" ]]; then
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        
        echo "请粘贴你的SSH公钥（完成后按回车）:"
        read ssh_public_key
        
        if [[ -n "$ssh_public_key" ]]; then
            echo "$ssh_public_key" >> /root/.ssh/authorized_keys
            chmod 600 /root/.ssh/authorized_keys
            
            # 修改SSH配置支持密钥认证
            sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
            sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
            sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
            
            log_success "SSH密钥配置完成"
        else
            log_warning "未输入公钥，跳过配置"
        fi
    fi
    
    log_success "账户安全配置完成"
    sleep 2
}

# 3. SSH安全加固
harden_ssh() {
    log_info "开始SSH安全加固..."
    
    # 备份SSH配置
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)
    log_success "已备份SSH配置文件"
    
    # 修改SSH端口
    echo ""
    read -p "是否修改SSH端口? (y/n): " change_port
    if [[ "$change_port" == "y" ]]; then
        read -p "请输入新的SSH端口 (建议10000-65535): " ssh_port
        
        if [[ "$ssh_port" =~ ^[0-9]+$ ]] && [ "$ssh_port" -ge 1 ] && [ "$ssh_port" -le 65535 ]; then
            sed -i "s/^#*Port .*/Port $ssh_port/" /etc/ssh/sshd_config
            log_success "SSH端口已修改为: $ssh_port"
            log_warning "请记住新端口号，下次连接使用: ssh -p $ssh_port user@ip"
            SSH_PORT=$ssh_port
        else
            log_error "无效的端口号"
            SSH_PORT=22
        fi
    else
        SSH_PORT=22
    fi
    
    # 强化SSH安全设置
    log_info "配置SSH安全参数..."
    
    cat >> /etc/ssh/sshd_config <<EOF

# 安全配置 - 由VPS优化脚本添加
ChallengeResponseAuthentication no

# 登录限速（防止暴力破解）
LoginGraceTime 30
MaxAuthTries 3

# 安全横幅
Banner /etc/issue.net
EOF
    
    # 创建安全横幅
    cat > /etc/issue.net <<EOF
*******************************************************************
                    WARNING / 警告
*******************************************************************
Unauthorized access to this server is prohibited.
未经授权访问本服务器是被禁止的。

All connections are monitored and recorded.
所有连接都被监控和记录。

Disconnect immediately if you are not an authorized user.
如果您不是授权用户，请立即断开连接。
*******************************************************************
EOF
    
    # 重启SSH服务
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    
    log_success "SSH安全加固完成"
    sleep 2
}

# 4. 防火墙配置
setup_firewall() {
    log_info "开始配置防火墙..."
    
    echo ""
    echo "请选择防火墙类型："
    echo "1) nftables (推荐，更现代)"
    echo "2) iptables (传统方式)"
    echo "3) 跳过防火墙配置"
    read -p "请输入选项 [1-3]: " firewall_choice
    
    case $firewall_choice in
        1)
            setup_nftables
            ;;
        2)
            setup_iptables
            ;;
        3)
            log_info "跳过防火墙配置"
            return
            ;;
        *)
            log_warning "无效选项，跳过防火墙配置"
            return
            ;;
    esac
    
    log_success "防火墙配置完成"
    sleep 2
}

# 配置nftables防火墙
setup_nftables() {
    log_info "配置nftables防火墙..."
    
    # 卸载ufw（如果存在）
    if command -v ufw >/dev/null 2>&1; then
        ufw --force reset >/dev/null 2>&1
        ufw disable >/dev/null 2>&1
        apt-get purge -y ufw >/dev/null 2>&1
        log_info "已卸载ufw"
    fi
    
    # 安装nftables
    apt-get install -y nftables >/dev/null 2>&1
    
    # 获取SSH端口
    local ssh_port=${SSH_PORT:-22}
    
    # 创建nftables配置文件
    cat > /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        # 允许本地回环
        iif lo accept

        # 允许已建立的连接
        ct state established,related accept

        # 允许ICMP (ping)
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept

        # 开放SSH端口
        tcp dport $ssh_port accept
        udp dport $ssh_port accept
        
        # 可以在这里添加其他需要开放的端口
        # tcp dport 80 accept
        # tcp dport 443 accept
    }
    
    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }
    
    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}

# 流量监控表
table inet mangle {
    chain prerouting {
        type filter hook prerouting priority mangle;
        policy accept;
    }
    chain output {
        type route hook output priority mangle;
        policy accept;
    }
    chain input {
        type filter hook input priority mangle;
        policy accept;
    }
}
EOF
    
    # 启用并启动nftables
    systemctl enable nftables >/dev/null 2>&1
    systemctl restart nftables
    
    log_success "nftables配置完成，SSH端口 $ssh_port 已开放"
}

# 配置iptables防火墙
setup_iptables() {
    log_info "配置iptables防火墙..."
    
    # 安装iptables-persistent
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    apt-get install -y iptables-persistent >/dev/null 2>&1
    
    # 获取SSH端口
    local ssh_port=${SSH_PORT:-22}
    
    # 清空现有规则
    iptables -F
    iptables -X
    iptables -Z
    
    # 设置默认策略
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # 允许本地回环
    iptables -A INPUT -i lo -j ACCEPT
    
    # 允许已建立的连接
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # 允许ICMP
    iptables -A INPUT -p icmp -j ACCEPT
    
    # 开放SSH端口
    iptables -A INPUT -p tcp --dport $ssh_port -j ACCEPT
    
    # 保存规则
    netfilter-persistent save >/dev/null 2>&1
    
    log_success "iptables配置完成，SSH端口 $ssh_port 已开放"
}

# 5. 系统性能优化
optimize_performance() {
    log_info "开始系统性能优化..."
    
    # 系统参数调优
    log_info "配置系统参数..."
    cat > /etc/sysctl.d/99-custom.conf <<EOF
# 网络性能优化
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_rmem = 4096 1048576 33554432
net.ipv4.tcp_wmem = 4096 1048576 33554432
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1

# 系统参数优化
kernel.panic = 1
vm.swappiness = 3
EOF
    
    # 应用系统参数
    sysctl --system >/dev/null 2>&1
    log_success "系统参数优化完成"
    
    # 配置swap
    echo ""
    read -p "是否配置虚拟内存(swap)? 建议内存小于4GB的服务器配置 (y/n): " setup_swap
    if [[ "$setup_swap" == "y" ]]; then
        # 检查是否已存在swap
        if swapon --show | grep -q '/swapfile'; then
            log_warning "Swap已存在，跳过配置"
        else
            read -p "请输入swap大小(GB) [建议2-4]: " swap_size
            swap_size=${swap_size:-2}
            
            log_info "创建 ${swap_size}GB swap文件..."
            fallocate -l ${swap_size}G /swapfile
            chmod 600 /swapfile
            mkswap /swapfile >/dev/null 2>&1
            swapon /swapfile
            
            # 添加到fstab
            if ! grep -q '/swapfile' /etc/fstab; then
                echo "/swapfile none swap sw 0 0" >> /etc/fstab
            fi
            
            log_success "Swap配置完成: ${swap_size}GB"
        fi
    fi
    
    log_success "系统性能优化完成"
    sleep 2
}

# 6. 时间同步
setup_time_sync() {
    log_info "开始配置时间同步..."
    
    # 设置时区
    echo ""
    echo "请选择时区："
    echo "1) Asia/Shanghai (中国 - 推荐)"
    echo "2) Asia/Hong_Kong (香港)"
    echo "3) Asia/Tokyo (日本)"
    echo "4) UTC (协调世界时)"
    echo "5) 跳过时区设置"
    read -p "请输入选项 [1-5]: " timezone_choice
    
    case $timezone_choice in
        1) timedatectl set-timezone Asia/Shanghai ;;
        2) timedatectl set-timezone Asia/Hong_Kong ;;
        3) timedatectl set-timezone Asia/Tokyo ;;
        4) timedatectl set-timezone UTC ;;
        5) log_info "跳过时区设置" ;;
        *) log_warning "无效选项，使用默认时区" ;;
    esac
    
    # 安装时间同步服务
    apt-get install -y systemd-timesyncd >/dev/null 2>&1
    
    # 配置NTP服务器
    echo ""
    echo "请选择NTP服务器："
    echo "1) 国内NTP服务器 (推荐国内用户)"
    echo "2) 国际NTP服务器 (推荐海外用户)"
    echo "3) 跳过NTP配置"
    read -p "请输入选项 [1-3]: " ntp_choice
    
    case $ntp_choice in
        1)
            log_info "配置国内NTP服务器..."
            cat > /etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=ntp.aliyun.com ntp.ntsc.ac.cn time1.cloud.tencent.com cn.pool.ntp.org
FallbackNTP=ntp1.aliyun.com ntp2.aliyun.com time2.cloud.tencent.com
EOF
            ;;
        2)
            log_info "配置国际NTP服务器..."
            cat > /etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=pool.ntp.org time1.google.com time.apple.com time.cloudflare.com time.windows.com
FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org
EOF
            ;;
        3)
            log_info "跳过NTP配置"
            return
            ;;
        *)
            log_warning "无效选项，跳过NTP配置"
            return
            ;;
    esac
    
    # 启用时间同步
    systemctl unmask systemd-timesyncd.service >/dev/null 2>&1
    systemctl enable systemd-timesyncd.service >/dev/null 2>&1
    systemctl restart systemd-timesyncd.service
    timedatectl set-ntp yes
    
    log_success "时间同步配置完成"
    log_info "当前时间: $(date)"
    sleep 2
}

# 7. 安全加固
security_hardening() {
    log_info "开始安全加固..."
    
    # 安装Fail2Ban
    echo ""
    read -p "是否安装Fail2Ban防暴力破解? (y/n): " install_fail2ban
    if [[ "$install_fail2ban" == "y" ]]; then
        log_info "安装Fail2Ban..."
        apt-get install -y fail2ban >/dev/null 2>&1
        
        # 获取SSH端口
        local ssh_port=${SSH_PORT:-22}
        
        # 配置SSH保护
        cat > /etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 10m
bantime = 30m
backend = systemd
EOF
        
        # 启动Fail2Ban
        systemctl enable fail2ban >/dev/null 2>&1
        systemctl restart fail2ban
        
        log_success "Fail2Ban安装完成 (5次错误封禁30分钟)"
    fi
    
    # 配置自动安全更新
    echo ""
    read -p "是否启用自动安全更新? (y/n): " auto_update
    if [[ "$auto_update" == "y" ]]; then
        log_info "配置自动安全更新..."
        apt-get install -y unattended-upgrades >/dev/null 2>&1
        echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
        dpkg-reconfigure -plow unattended-upgrades >/dev/null 2>&1
        log_success "自动安全更新已启用"
    fi
    
    # ICMP Ping控制
    echo ""
    read -p "是否禁用ICMP Ping响应? (不推荐新手) (y/n): " disable_ping
    if [[ "$disable_ping" == "y" ]]; then
        cat > /etc/sysctl.d/99-vpsbox-icmp.conf <<EOF
net.ipv4.icmp_echo_ignore_all = 1
EOF
        sysctl -w net.ipv4.icmp_echo_ignore_all=1 >/dev/null 2>&1
        log_success "已禁用ICMP Ping响应"
    fi
    
    log_success "安全加固完成"
    sleep 2
}

# 8. 系统清理
system_cleanup() {
    log_info "开始系统清理..."
    
    echo ""
    read -p "是否进行系统清理? (y/n): " do_cleanup
    if [[ "$do_cleanup" != "y" ]]; then
        log_info "跳过系统清理"
        return
    fi
    
    # 清理软件包缓存
    log_info "清理软件包缓存..."
    apt-get clean >/dev/null 2>&1
    apt-get autoremove -y >/dev/null 2>&1
    apt-get autoclean >/dev/null 2>&1
    
    # 清理日志文件
    log_info "清理旧日志文件..."
    find /var/log -type f -name "*.gz" -delete 2>/dev/null
    find /var/log -type f -name "*.old" -delete 2>/dev/null
    find /var/log -type f -name "*.1" -delete 2>/dev/null
    journalctl --vacuum-time=7d >/dev/null 2>&1
    
    # 清理临时文件
    log_info "清理临时文件..."
    find /tmp -type f -atime +7 -delete 2>/dev/null
    find /var/tmp -type f -atime +7 -delete 2>/dev/null
    
    log_success "系统清理完成"
    sleep 2
}

# 9. Docker环境配置
setup_docker() {
    log_info "开始配置Docker环境..."
    
    echo ""
    read -p "是否安装Docker? (y/n): " install_docker
    if [[ "$install_docker" != "y" ]]; then
        log_info "跳过Docker安装"
        return
    fi
    
    # 检查是否已安装Docker
    if command -v docker >/dev/null 2>&1; then
        log_warning "Docker已安装，版本: $(docker --version)"
        read -p "是否重新安装? (y/n): " reinstall
        if [[ "$reinstall" != "y" ]]; then
            return
        fi
    fi
    
    log_info "安装Docker依赖..."
    apt-get update >/dev/null 2>&1
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release >/dev/null 2>&1
    
    # 选择Docker源
    echo ""
    echo "请选择Docker安装源："
    echo "1) 阿里云源 (推荐国内用户)"
    echo "2) 清华源"
    echo "3) 官方源 (推荐海外用户)"
    read -p "请输入选项 [1-3]: " docker_source
    
    # 添加Docker的官方GPG密钥
    mkdir -p /etc/apt/keyrings
    
    case $docker_source in
        1)
            log_info "使用阿里云Docker源..."
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            ;;
        2)
            log_info "使用清华Docker源..."
            curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            ;;
        3)
            log_info "使用官方Docker源..."
            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            ;;
        *)
            log_error "无效选项，使用官方源"
            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            ;;
    esac
    
    # 安装Docker
    log_info "安装Docker Engine..."
    apt-get update >/dev/null 2>&1
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # 启动Docker
    systemctl enable docker >/dev/null 2>&1
    systemctl start docker
    
    log_success "Docker安装完成: $(docker --version)"
    
    # 配置Docker镜像加速
    echo ""
    read -p "是否配置Docker镜像加速? (推荐国内用户) (y/n): " docker_mirror
    if [[ "$docker_mirror" == "y" ]]; then
        log_info "配置Docker镜像加速..."
        
        mkdir -p /etc/docker
        cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "default-address-pools": [
        {
            "base": "172.17.0.0/12",
            "size": 24
        }
    ]
}
EOF
        
        systemctl daemon-reload
        systemctl restart docker
        log_success "Docker镜像加速配置完成"
    fi
    
    # 添加用户到docker组
    echo ""
    read -p "是否将当前用户添加到docker组? (y/n): " add_docker_group
    if [[ "$add_docker_group" == "y" ]]; then
        read -p "请输入用户名 (留空则跳过): " docker_user
        if [[ -n "$docker_user" ]]; then
            usermod -aG docker "$docker_user"
            log_success "用户 $docker_user 已添加到docker组"
            log_warning "需要重新登录才能生效"
        fi
    fi
    
    # 测试Docker
    log_info "测试Docker安装..."
    if docker run --rm hello-world >/dev/null 2>&1; then
        log_success "Docker运行正常"
    else
        log_warning "Docker测试失败，请检查配置"
    fi
    
    log_success "Docker环境配置完成"
    sleep 2
}

# 10. Nginx配置与SSL证书
setup_nginx() {
    log_info "开始配置Nginx..."
    
    echo ""
    read -p "是否安装并配置Nginx? (y/n): " install_nginx
    if [[ "$install_nginx" != "y" ]]; then
        log_info "跳过Nginx安装"
        return
    fi
    
    # 检查是否已安装Nginx
    if command -v nginx >/dev/null 2>&1; then
        log_warning "Nginx已安装，版本: $(nginx -v 2>&1 | cut -d'/' -f2)"
        read -p "是否继续配置? (y/n): " continue_nginx
        if [[ "$continue_nginx" != "y" ]]; then
            return
        fi
    else
        # 安装Nginx
        log_info "安装Nginx..."
        apt-get update >/dev/null 2>&1
        apt-get install -y nginx
        
        systemctl enable nginx >/dev/null 2>&1
        systemctl start nginx
        
        log_success "Nginx安装完成: $(nginx -v 2>&1 | cut -d'/' -f2)"
    fi
    
    # 优化Nginx配置
    echo ""
    read -p "是否优化Nginx配置? (y/n): " optimize_nginx
    if [[ "$optimize_nginx" == "y" ]]; then
        log_info "备份Nginx配置..."
        cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)
        
        log_info "优化Nginx配置..."
        cat > /etc/nginx/nginx.conf <<'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # 基础设置
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    
    # 文件大小限制
    client_max_body_size 100M;
    client_body_buffer_size 128k;
    
    # MIME类型
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # 日志设置
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
    gzip_disable "msie6";
    
    # 缓存设置
    open_file_cache max=10000 inactive=30s;
    open_file_cache_valid 60s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # SSL设置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 包含其他配置文件
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
        
        # 测试配置
        if nginx -t >/dev/null 2>&1; then
            systemctl reload nginx
            log_success "Nginx配置优化完成"
        else
            log_error "Nginx配置测试失败，已恢复备份"
            mv /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S) /etc/nginx/nginx.conf
        fi
    fi
    
    # SSL证书配置
    echo ""
    read -p "是否配置SSL证书自动化 (使用acme.sh)? (y/n): " setup_ssl
    if [[ "$setup_ssl" == "y" ]]; then
        setup_acme_ssl
    fi
    
    # 防火墙开放端口
    echo ""
    read -p "是否在防火墙中开放HTTP(80)和HTTPS(443)端口? (y/n): " open_web_ports
    if [[ "$open_web_ports" == "y" ]]; then
        if systemctl is-active --quiet nftables; then
            # 备份当前配置
            cp /etc/nftables.conf /etc/nftables.conf.backup.$(date +%Y%m%d_%H%M%S)
            
            # 在input链中添加HTTP和HTTPS规则
            sed -i '/# 开放SSH端口/i\        # 开放HTTP和HTTPS端口\n        tcp dport { 80, 443 } accept' /etc/nftables.conf
            
            systemctl restart nftables
            log_success "已在防火墙中开放80和443端口"
        elif command -v iptables >/dev/null 2>&1; then
            iptables -I INPUT -p tcp --dport 80 -j ACCEPT
            iptables -I INPUT -p tcp --dport 443 -j ACCEPT
            netfilter-persistent save >/dev/null 2>&1
            log_success "已在防火墙中开放80和443端口"
        else
            log_warning "未检测到防火墙，请手动开放80和443端口"
        fi
    fi
    
    log_success "Nginx配置完成"
    sleep 2
}

# SSL证书自动化配置
setup_acme_ssl() {
    log_info "配置SSL证书自动化..."
    
    # 检查是否已安装acme.sh
    if [ -f ~/.acme.sh/acme.sh ]; then
        log_warning "acme.sh已安装"
        read -p "是否重新安装? (y/n): " reinstall_acme
        if [[ "$reinstall_acme" != "y" ]]; then
            return
        fi
    fi
    
    # 安装acme.sh
    log_info "安装acme.sh..."
    curl -s https://get.acme.sh | sh -s email=my@example.com >/dev/null 2>&1
    
    # 设置别名
    alias acme.sh=~/.acme.sh/acme.sh
    
    log_success "acme.sh安装完成"
    
    # 配置证书申请
    echo ""
    read -p "是否现在申请SSL证书? (y/n): " apply_cert
    if [[ "$apply_cert" != "y" ]]; then
        log_info "跳过证书申请，您可以稍后使用以下命令申请："
        echo ""
        echo "  方式1 - Webroot模式 (需要Web服务器运行):"
        echo "  ~/.acme.sh/acme.sh --issue -d yourdomain.com -w /var/www/html"
        echo ""
        echo "  方式2 - Standalone模式 (需要暂停Web服务器):"
        echo "  ~/.acme.sh/acme.sh --issue -d yourdomain.com --standalone"
        echo ""
        echo "  方式3 - DNS API模式 (推荐，需要配置DNS API):"
        echo "  ~/.acme.sh/acme.sh --issue -d yourdomain.com --dns dns_cf"
        echo ""
        return
    fi
    
    # 输入域名
    read -p "请输入您的域名 (例如: example.com): " domain
    if [[ -z "$domain" ]]; then
        log_error "域名不能为空"
        return
    fi
    
    # 选择验证方式
    echo ""
    echo "请选择证书验证方式："
    echo "1) Webroot模式 (推荐，需要Web服务器运行)"
    echo "2) Standalone模式 (需要暂停Web服务器)"
    echo "3) DNS API模式 (最推荐，需要DNS API配置)"
    read -p "请输入选项 [1-3]: " cert_mode
    
    case $cert_mode in
        1)
            # Webroot模式
            read -p "请输入网站根目录 [默认: /var/www/html]: " webroot
            webroot=${webroot:-/var/www/html}
            
            mkdir -p "$webroot"
            ~/.acme.sh/acme.sh --issue -d "$domain" -w "$webroot"
            ;;
        2)
            # Standalone模式
            log_warning "将暂停Nginx服务..."
            systemctl stop nginx
            ~/.acme.sh/acme.sh --issue -d "$domain" --standalone
            systemctl start nginx
            ;;
        3)
            # DNS API模式
            echo ""
            echo "常用DNS提供商："
            echo "1) Cloudflare"
            echo "2) 阿里云"
            echo "3) 腾讯云"
            echo "4) 其他 (需要手动配置)"
            read -p "请选择DNS提供商 [1-4]: " dns_provider
            
            case $dns_provider in
                1)
                    read -p "请输入Cloudflare API Key: " cf_key
                    read -p "请输入Cloudflare Email: " cf_email
                    export CF_Key="$cf_key"
                    export CF_Email="$cf_email"
                    ~/.acme.sh/acme.sh --issue -d "$domain" --dns dns_cf
                    ;;
                2)
                    read -p "请输入阿里云Key: " ali_key
                    read -p "请输入阿里云Secret: " ali_secret
                    export Ali_Key="$ali_key"
                    export Ali_Secret="$ali_secret"
                    ~/.acme.sh/acme.sh --issue -d "$domain" --dns dns_ali
                    ;;
                3)
                    read -p "请输入腾讯云SecretId: " tencent_id
                    read -p "请输入腾讯云SecretKey: " tencent_key
                    export Tencent_SecretId="$tencent_id"
                    export Tencent_SecretKey="$tencent_key"
                    ~/.acme.sh/acme.sh --issue -d "$domain" --dns dns_tencent
                    ;;
                *)
                    log_info "请参考 https://github.com/acmesh-official/acme.sh/wiki/dnsapi 配置DNS API"
                    return
                    ;;
            esac
            ;;
        *)
            log_error "无效选项"
            return
            ;;
    esac
    
    # 安装证书到Nginx
    if [ $? -eq 0 ]; then
        log_success "证书申请成功"
        
        read -p "是否安装证书到Nginx? (y/n): " install_cert
        if [[ "$install_cert" == "y" ]]; then
            mkdir -p /etc/nginx/ssl
            
            ~/.acme.sh/acme.sh --install-cert -d "$domain" \
                --key-file /etc/nginx/ssl/"$domain".key \
                --fullchain-file /etc/nginx/ssl/"$domain".crt \
                --reloadcmd "systemctl reload nginx"
            
            # 创建Nginx配置示例
            cat > /etc/nginx/sites-available/"$domain" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain www.$domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $domain www.$domain;
    
    ssl_certificate /etc/nginx/ssl/$domain.crt;
    ssl_certificate_key /etc/nginx/ssl/$domain.key;
    
    root /var/www/$domain;
    index index.html index.htm index.php;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    access_log /var/log/nginx/${domain}_access.log;
    error_log /var/log/nginx/${domain}_error.log;
}
EOF
            
            log_success "证书已安装到 /etc/nginx/ssl/"
            log_info "Nginx配置示例已创建: /etc/nginx/sites-available/$domain"
            log_warning "请根据需要修改配置并执行: ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/"
        fi
    else
        log_error "证书申请失败，请检查域名DNS解析"
    fi
}

# 11. 安装常用工具
install_useful_tools() {
    log_info "开始安装常用工具..."
    
    echo ""
    echo "请选择要安装的工具类别："
    echo "1) 系统监控工具 (htop, iotop, nload, glances)"
    echo "2) 网络工具 (curl, wget, net-tools, dnsutils, traceroute)"
    echo "3) 编辑器 (vim, nano)"
    echo "4) 开发工具 (git, build-essential, python3-pip)"
    echo "5) 压缩工具 (zip, unzip, rar, p7zip)"
    echo "6) 全部安装"
    echo "7) 自定义选择"
    read -p "请输入选项 [1-7]: " tools_choice
    
    case $tools_choice in
        1)
            log_info "安装系统监控工具..."
            apt-get install -y htop iotop nload glances
            ;;
        2)
            log_info "安装网络工具..."
            apt-get install -y curl wget net-tools dnsutils traceroute telnet nmap
            ;;
        3)
            log_info "安装编辑器..."
            apt-get install -y vim nano
            ;;
        4)
            log_info "安装开发工具..."
            apt-get install -y git build-essential python3-pip
            ;;
        5)
            log_info "安装压缩工具..."
            apt-get install -y zip unzip rar unrar p7zip-full
            ;;
        6)
            log_info "安装全部工具..."
            apt-get install -y htop iotop nload glances \
                curl wget net-tools dnsutils traceroute telnet nmap \
                vim nano \
                git build-essential python3-pip \
                zip unzip rar unrar p7zip-full
            ;;
        7)
            echo ""
            read -p "安装系统监控工具? (y/n): " install_monitor
            [[ "$install_monitor" == "y" ]] && apt-get install -y htop iotop nload glances
            
            read -p "安装网络工具? (y/n): " install_network
            [[ "$install_network" == "y" ]] && apt-get install -y curl wget net-tools dnsutils traceroute telnet nmap
            
            read -p "安装编辑器? (y/n): " install_editor
            [[ "$install_editor" == "y" ]] && apt-get install -y vim nano
            
            read -p "安装开发工具? (y/n): " install_dev
            [[ "$install_dev" == "y" ]] && apt-get install -y git build-essential python3-pip
            
            read -p "安装压缩工具? (y/n): " install_compress
            [[ "$install_compress" == "y" ]] && apt-get install -y zip unzip rar unrar p7zip-full
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    log_success "工具安装完成"
    sleep 2
}

# 12. 配置自动备份
setup_backup() {
    log_info "开始配置自动备份..."
    
    echo ""
    read -p "是否配置自动备份脚本? (y/n): " setup_backup_script
    if [[ "$setup_backup_script" != "y" ]]; then
        log_info "跳过备份配置"
        return
    fi
    
    # 创建备份目录
    read -p "请输入备份目录 [默认: /backup]: " backup_dir
    backup_dir=${backup_dir:-/backup}
    mkdir -p "$backup_dir"
    
    # 创建备份脚本
    cat > /usr/local/bin/auto_backup.sh <<'EOF'
#!/bin/bash

# 备份配置
BACKUP_DIR="/backup"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${BACKUP_DATE}"
RETENTION_DAYS=7

# 创建备份目录
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"

# 备份重要配置文件
echo "开始备份配置文件..."
cp -r /etc/ssh "${BACKUP_DIR}/${BACKUP_NAME}/" 2>/dev/null
cp -r /etc/nginx "${BACKUP_DIR}/${BACKUP_NAME}/" 2>/dev/null
cp /etc/fstab "${BACKUP_DIR}/${BACKUP_NAME}/" 2>/dev/null
cp -r /etc/systemd/system "${BACKUP_DIR}/${BACKUP_NAME}/" 2>/dev/null

# 备份网站数据 (根据需要修改)
if [ -d /var/www ]; then
    echo "备份网站数据..."
    tar -czf "${BACKUP_DIR}/${BACKUP_NAME}/www_data.tar.gz" /var/www 2>/dev/null
fi

# 备份数据库 (如果有)
if command -v mysqldump >/dev/null 2>&1; then
    echo "备份MySQL数据库..."
    # 需要配置MySQL密码
    # mysqldump -u root -p'password' --all-databases > "${BACKUP_DIR}/${BACKUP_NAME}/mysql_backup.sql"
fi

# 压缩备份
echo "压缩备份文件..."
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

# 删除旧备份
echo "清理旧备份..."
find "${BACKUP_DIR}" -name "backup_*.tar.gz" -mtime +${RETENTION_DAYS} -delete

echo "备份完成: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
EOF
    
    # 修改备份目录
    sed -i "s|BACKUP_DIR=\"/backup\"|BACKUP_DIR=\"$backup_dir\"|" /usr/local/bin/auto_backup.sh
    
    chmod +x /usr/local/bin/auto_backup.sh
    
    log_success "备份脚本创建成功: /usr/local/bin/auto_backup.sh"
    
    # 配置定时任务
    echo ""
    read -p "是否配置定时自动备份? (y/n): " setup_cron
    if [[ "$setup_cron" == "y" ]]; then
        echo ""
        echo "请选择备份频率："
        echo "1) 每天凌晨2点"
        echo "2) 每周日凌晨2点"
        echo "3) 每月1号凌晨2点"
        echo "4) 自定义"
        read -p "请输入选项 [1-4]: " cron_choice
        
        case $cron_choice in
            1)
                cron_schedule="0 2 * * *"
                ;;
            2)
                cron_schedule="0 2 * * 0"
                ;;
            3)
                cron_schedule="0 2 1 * *"
                ;;
            4)
                read -p "请输入cron表达式 (例如: 0 2 * * *): " cron_schedule
                ;;
            *)
                log_warning "无效选项"
                return
                ;;
        esac
        
        # 添加到crontab
        (crontab -l 2>/dev/null | grep -v "auto_backup.sh"; echo "$cron_schedule /usr/local/bin/auto_backup.sh >> /var/log/backup.log 2>&1") | crontab -
        
        log_success "定时备份任务已添加"
        log_info "备份日志: /var/log/backup.log"
    fi
    
    log_success "备份配置完成"
    sleep 2
}

# 13. 配置系统监控告警
setup_monitoring() {
    log_info "开始配置系统监控..."
    
    echo ""
    read -p "是否配置系统监控脚本? (y/n): " setup_monitor
    if [[ "$setup_monitor" != "y" ]]; then
        log_info "跳过监控配置"
        return
    fi
    
    # 创建监控脚本
    cat > /usr/local/bin/system_monitor.sh <<'EOF'
#!/bin/bash

# 监控配置
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85

# 获取系统信息
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

# 检查CPU使用率
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "[警告] CPU使用率过高: ${CPU_USAGE}%"
fi

# 检查内存使用率
if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    echo "[警告] 内存使用率过高: ${MEM_USAGE}%"
fi

# 检查磁盘使用率
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "[警告] 磁盘使用率过高: ${DISK_USAGE}%"
fi

# 检查系统负载
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | cut -d',' -f1)
echo "系统负载: $LOAD_AVG"

# 检查关键服务
SERVICES=("ssh" "nginx" "docker")
for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "[正常] $service 服务运行正常"
    elif systemctl list-unit-files | grep -q "^${service}.service"; then
        echo "[警告] $service 服务未运行"
    fi
done
EOF
    
    chmod +x /usr/local/bin/system_monitor.sh
    
    log_success "监控脚本创建成功: /usr/local/bin/system_monitor.sh"
    
    # 配置定时监控
    echo ""
    read -p "是否配置定时监控 (每小时检查一次)? (y/n): " setup_monitor_cron
    if [[ "$setup_monitor_cron" == "y" ]]; then
        (crontab -l 2>/dev/null | grep -v "system_monitor.sh"; echo "0 * * * * /usr/local/bin/system_monitor.sh >> /var/log/monitor.log 2>&1") | crontab -
        log_success "定时监控任务已添加"
        log_info "监控日志: /var/log/monitor.log"
    fi
    
    log_success "监控配置完成"
    sleep 2
}

# 14. 优化SSH连接速度
optimize_ssh_speed() {
    log_info "开始优化SSH连接速度..."
    
    echo ""
    read -p "是否优化SSH连接速度? (y/n): " optimize_ssh
    if [[ "$optimize_ssh" != "y" ]]; then
        log_info "跳过SSH优化"
        return
    fi
    
    # 备份配置
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.ssh_speed.$(date +%Y%m%d_%H%M%S)
    
    # 优化SSH配置
    log_info "配置SSH加速参数..."
    
    # 禁用DNS反向解析
    sed -i 's/^#*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
    if ! grep -q "^UseDNS" /etc/ssh/sshd_config; then
        echo "UseDNS no" >> /etc/ssh/sshd_config
    fi
    
    # 禁用GSSAPI认证
    sed -i 's/^#*GSSAPIAuthentication.*/GSSAPIAuthentication no/' /etc/ssh/sshd_config
    if ! grep -q "^GSSAPIAuthentication" /etc/ssh/sshd_config; then
        echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
    fi
    
    # 启用TCP KeepAlive
    sed -i 's/^#*TCPKeepAlive.*/TCPKeepAlive yes/' /etc/ssh/sshd_config
    if ! grep -q "^TCPKeepAlive" /etc/ssh/sshd_config; then
        echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
    fi
    
    # 配置客户端保活
    if ! grep -q "ClientAliveInterval" /etc/ssh/sshd_config; then
        cat >> /etc/ssh/sshd_config <<EOF

# SSH连接保活配置
ClientAliveInterval 60
ClientAliveCountMax 3
EOF
    fi
    
    # 重启SSH服务
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    
    log_success "SSH连接速度优化完成"
    log_info "已禁用DNS反向解析和GSSAPI认证，SSH连接将更快"
    sleep 2
}

# 15. BBR V3 终极优化
install_bbr_v3() {
    log_info "开始配置BBR V3终极优化..."
    
    echo ""
    echo -e "${YELLOW}BBR V3 终极优化说明:${NC}"
    echo "此功能将安装 Eric86777 的 vps-tcp-tune 优化脚本"
    echo "项目地址: https://github.com/Eric86777/vps-tcp-tune"
    echo ""
    echo "特性:"
    echo "  - BBR v3 最新版本"
    echo "  - 针对VPS网络环境深度优化"
    echo "  - 简单易用的命令行工具"
    echo "  - 详细的性能监控"
    echo ""
    
    read -p "是否安装BBR V3优化脚本? (y/n): " install_bbr
    if [[ "$install_bbr" != "y" ]]; then
        log_info "跳过BBR V3安装"
        return
    fi
    
    # 检查curl是否安装
    if ! command -v curl >/dev/null 2>&1; then
        log_info "安装curl..."
        apt-get install -y curl >/dev/null 2>&1
    fi
    
    log_info "下载并安装BBR V3优化脚本..."
    
    # 安装别名脚本
    if bash <(curl -fsSL "https://raw.githubusercontent.com/Eric86777/vps-tcp-tune/main/install-alias.sh?$(date +%s)"); then
        log_success "BBR V3优化脚本安装成功"
        
        # 检测shell类型
        if [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        else
            SHELL_RC="$HOME/.bashrc"
        fi
        
        log_info "配置文件: $SHELL_RC"
        
        echo ""
        echo -e "${GREEN}安装完成！${NC}"
        echo ""
        echo -e "${YELLOW}使用方法:${NC}"
        echo "1. 重新加载配置:"
        echo "   source $SHELL_RC"
        echo ""
        echo "2. 运行BBR优化:"
        echo "   bbr"
        echo ""
        echo "3. 或者重新登录SSH后直接运行: bbr"
        echo ""
        
        read -p "是否立即重新加载配置并运行BBR优化? (y/n): " run_now
        if [[ "$run_now" == "y" ]]; then
            log_info "重新加载配置..."
            source "$SHELL_RC" 2>/dev/null || true
            
            if command -v bbr >/dev/null 2>&1; then
                log_info "启动BBR优化..."
                bbr
            else
                log_warning "需要重新登录SSH后才能使用 bbr 命令"
            fi
        fi
        
    else
        log_error "BBR V3优化脚本安装失败"
        log_warning "请检查网络连接或手动安装："
        echo "  bash <(curl -fsSL 'https://raw.githubusercontent.com/Eric86777/vps-tcp-tune/main/install-alias.sh')"
    fi
    
    log_success "BBR V3配置完成"
    sleep 2
}

# 验证配置
verify_setup() {
    show_header
    log_info "开始验证配置..."
    echo ""
    
    echo -e "${GREEN}════════════════ 系统状态 ════════════════${NC}"
    
    # 系统信息
    echo -e "${BLUE}系统版本:${NC}"
    lsb_release -d 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME
    
    # 内核版本
    echo -e "\n${BLUE}内核版本:${NC}"
    uname -r
    
    # 时间信息
    echo -e "\n${BLUE}系统时间:${NC}"
    date
    timedatectl status | grep "Time zone"
    
    # 内存信息
    echo -e "\n${BLUE}内存使用:${NC}"
    free -h
    
    # 磁盘信息
    echo -e "\n${BLUE}磁盘使用:${NC}"
    df -h / | tail -1
    
    # SSH配置
    echo -e "\n${BLUE}SSH配置:${NC}"
    SSH_ACTUAL_PORT=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}')
    SSH_ACTUAL_PORT=${SSH_ACTUAL_PORT:-22}
    echo "端口: $SSH_ACTUAL_PORT"
    sshd -T 2>/dev/null | grep -E "permitrootlogin|pubkeyauthentication|passwordauthentication" | head -3
    
    # 防火墙状态
    echo -e "\n${BLUE}防火墙状态:${NC}"
    if systemctl is-active --quiet nftables; then
        echo "nftables: 运行中"
    elif systemctl is-active --quiet iptables; then
        echo "iptables: 运行中"
    else
        echo "防火墙: 未配置"
    fi
    
    # Fail2Ban状态
    if command -v fail2ban-client >/dev/null 2>&1; then
        echo -e "\n${BLUE}Fail2Ban状态:${NC}"
        systemctl is-active fail2ban && echo "运行中" || echo "未运行"
    fi
    
    # BBR状态
    echo -e "\n${BLUE}BBR状态:${NC}"
    if sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q bbr; then
        echo "已启用"
    else
        echo "未启用"
    fi
    
    # Docker状态
    if command -v docker >/dev/null 2>&1; then
        echo -e "\n${BLUE}Docker状态:${NC}"
        echo "版本: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')"
        systemctl is-active docker >/dev/null 2>&1 && echo "状态: 运行中" || echo "状态: 未运行"
    fi
    
    # Nginx状态
    if command -v nginx >/dev/null 2>&1; then
        echo -e "\n${BLUE}Nginx状态:${NC}"
        echo "版本: $(nginx -v 2>&1 | cut -d'/' -f2)"
        systemctl is-active nginx >/dev/null 2>&1 && echo "状态: 运行中" || echo "状态: 未运行"
    fi
    
    echo -e "\n${GREEN}════════════════════════════════════════${NC}"
    
    # 保存重要信息
    cat > /root/vps_setup_info.txt <<EOF
VPS优化配置完成报告
生成时间: $(date)

SSH端口: $SSH_ACTUAL_PORT
连接命令: ssh -p $SSH_ACTUAL_PORT root@your-server-ip

重要提醒:
1. 请立即测试SSH连接，确保可以正常登录
2. 如果修改了SSH端口，请使用新端口连接
3. 配置备份已保存在相应目录的.backup文件中
4. 建议定期执行系统更新: apt update && apt upgrade
5. 查看防火墙状态: nft list ruleset 或 iptables -L

安全建议:
- 定期更新系统和软件包
- 监控系统日志: journalctl -xe
- 查看登录记录: last
- 检查Fail2Ban: fail2ban-client status
EOF
    
    log_success "配置信息已保存到 /root/vps_setup_info.txt"
}

# 显示完成信息
show_completion() {
    show_header
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                   🎉 优化完成 🎉                         ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}重要提醒:${NC}"
    echo "1. ⚠️  请立即测试SSH连接，确保可以正常登录"
    
    SSH_ACTUAL_PORT=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}')
    SSH_ACTUAL_PORT=${SSH_ACTUAL_PORT:-22}
    
    if [[ "$SSH_ACTUAL_PORT" != "22" ]]; then
        echo "2. 🔑 SSH端口已修改为: ${GREEN}$SSH_ACTUAL_PORT${NC}"
        echo "   连接命令: ${GREEN}ssh -p $SSH_ACTUAL_PORT root@your-server-ip${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}日常维护命令:${NC}"
    echo "- 更新系统: ${GREEN}apt update && apt upgrade${NC}"
    echo "- 查看防火墙: ${GREEN}nft list ruleset${NC}"
    echo "- 查看Fail2Ban: ${GREEN}fail2ban-client status${NC}"
    echo "- 查看系统状态: ${GREEN}htop${NC}"
    echo "- 查看配置信息: ${GREEN}cat /root/vps_setup_info.txt${NC}"
    
    if command -v docker >/dev/null 2>&1; then
        echo "- Docker容器: ${GREEN}docker ps${NC}"
        echo "- Docker镜像: ${GREEN}docker images${NC}"
    fi
    
    if [ -f /usr/local/bin/auto_backup.sh ]; then
        echo "- 手动备份: ${GREEN}/usr/local/bin/auto_backup.sh${NC}"
    fi
    
    if [ -f /usr/local/bin/system_monitor.sh ]; then
        echo "- 系统监控: ${GREEN}/usr/local/bin/system_monitor.sh${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}快速工具:${NC}"
    if [ -f ~/.acme.sh/acme.sh ]; then
        echo "- SSL证书: ${GREEN}~/.acme.sh/acme.sh --list${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}下一步建议:${NC}"
    echo "1. 测试所有服务是否正常运行"
    echo "2. 配置应用程序部署"
    echo "3. 设置定期数据备份"
    echo "4. 建立监控和告警机制"
    
    echo ""
    read -p "按回车键退出..."
}

# 交互式菜单
show_menu() {
    while true; do
        show_header
        echo "请选择要执行的优化项目："
        echo ""
        echo "  ${GREEN}[一键优化]${NC}"
        echo "  0) 执行全部优化 (推荐新手)"
        echo ""
        echo "  ${BLUE}[基础优化]${NC}"
        echo "  1) 换源加速"
        echo "  2) 账户安全配置"
        echo "  3) SSH安全加固"
        echo "  4) 防火墙配置"
        echo "  5) 系统性能优化"
        echo "  6) 时间同步配置"
        echo "  7) 安全加固 (Fail2Ban等)"
        echo "  8) 系统清理"
        echo ""
        echo "  ${YELLOW}[环境配置]${NC}"
        echo "  9) Docker环境配置"
        echo "  10) Nginx配置与SSL证书"
        echo "  11) 安装常用工具"
        echo "  12) 配置自动备份"
        echo "  13) 配置系统监控告警"
        echo "  14) 优化SSH连接速度"
        echo "  15) BBR V3 终极优化 ⭐"
        echo ""
        echo "  ${GREEN}[其他]${NC}"
        echo "  v) 验证配置"
        echo "  q) 退出脚本"
        echo ""
        read -p "请输入选项: " choice
        
        case $choice in
            0)
                # 基础优化
                optimize_sources
                setup_security
                harden_ssh
                setup_firewall
                optimize_performance
                setup_time_sync
                security_hardening
                system_cleanup
                
                # 可选的高级配置
                echo ""
                log_info "基础优化完成，是否继续配置环境?"
                read -p "配置Docker环境? (y/n): " do_docker
                [[ "$do_docker" == "y" ]] && setup_docker
                
                read -p "配置Nginx? (y/n): " do_nginx
                [[ "$do_nginx" == "y" ]] && setup_nginx
                
                read -p "安装常用工具? (y/n): " do_tools
                [[ "$do_tools" == "y" ]] && install_useful_tools
                
                read -p "配置自动备份? (y/n): " do_backup
                [[ "$do_backup" == "y" ]] && setup_backup
                
                read -p "配置系统监控? (y/n): " do_monitor
                [[ "$do_monitor" == "y" ]] && setup_monitoring
                
                read -p "优化SSH连接速度? (y/n): " do_ssh_speed
                [[ "$do_ssh_speed" == "y" ]] && optimize_ssh_speed
                
                read -p "安装BBR V3终极优化? (y/n): " do_bbr_v3
                [[ "$do_bbr_v3" == "y" ]] && install_bbr_v3
                
                verify_setup
                show_completion
                break
                ;;
            1) optimize_sources ;;
            2) setup_security ;;
            3) harden_ssh ;;
            4) setup_firewall ;;
            5) optimize_performance ;;
            6) setup_time_sync ;;
            7) security_hardening ;;
            8) system_cleanup ;;
            9) setup_docker ;;
            10) setup_nginx ;;
            11) install_useful_tools ;;
            12) setup_backup ;;
            13) setup_monitoring ;;
            14) optimize_ssh_speed ;;
            15) install_bbr_v3 ;;
            v|V) verify_setup ; read -p "按回车继续..." ;;
            q|Q) 
                log_info "退出脚本"
                exit 0
                ;;
            *)
                log_error "无效选项"
                sleep 1
                ;;
        esac
    done
}

# 主函数
main() {
    check_root
    detect_system
    show_menu
}

# 执行主函数
main
