#!/bin/bash

################################################################################
# VPS优化脚本 - 基础优化模块
# 包含系统基础配置、换源、安全设置等功能
################################################################################

# 加载公共库
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config/default.conf"

# ==============================================================================
# 换源功能
# ==============================================================================

optimize_sources() {
    log_info "开始换源优化..."

    # 备份原始源配置
    backup_file "/etc/apt/sources.list"

    # 安装HTTPS证书支持
    install_package "ca-certificates"
    install_package "lsb-release"

    # 获取系统版本代号
    local codename=$(lsb_release -cs)
    log_info "系统版本代号: $codename"

    echo ""
    show_menu "请选择软件源类型：" \
        "阿里云源 (推荐国内用户)" \
        "中科大源 (教育网用户)" \
        "清华源 (老牌稳定)" \
        "官方源 (海外用户)" \
        "香港源 (亚洲地区)" \
        "跳过换源"

    local choice=$(get_menu_choice 6)

    case $choice in
        1) configure_mirror "aliyun" "$codename" ;;
        2) configure_mirror "ustc" "$codename" ;;
        3) configure_mirror "tsinghua" "$codename" ;;
        4) configure_mirror "official" "$codename" ;;
        5) configure_mirror "hk" "$codename" ;;
        6) log_info "跳过换源操作"; return ;;
    esac

    # 更新软件包列表
    log_info "更新软件包列表..."
    safe_exec "apt update" "更新软件包列表失败"

    log_success "换源完成！"
}

configure_mirror() {
    local mirror=$1
    local codename=$2

    case $mirror in
        aliyun)
            cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ ${codename} main contrib non-free non-free-firmware
deb-src http://mirrors.aliyun.com/debian/ ${codename} main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian-security ${codename}-security main contrib non-free non-free-firmware
deb-src http://mirrors.aliyun.com/debian-security ${codename}-security main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian/ ${codename}-updates main contrib non-free non-free-firmware
deb-src http://mirrors.aliyun.com/debian/ ${codename}-updates main contrib non-free non-free-firmware
EOF
            ;;
        ustc)
            cat > /etc/apt/sources.list <<EOF
deb http://mirrors.ustc.edu.cn/debian/ ${codename} main contrib non-free non-free-firmware
deb-src http://mirrors.ustc.edu.cn/debian/ ${codename} main contrib non-free non-free-firmware
deb http://mirrors.ustc.edu.cn/debian-security ${codename}-security main contrib non-free non-free-firmware
deb-src http://mirrors.ustc.edu.cn/debian-security ${codename}-security main contrib non-free non-free-firmware
deb http://mirrors.ustc.edu.cn/debian/ ${codename}-updates main contrib non-free non-free-firmware
deb-src http://mirrors.ustc.edu.cn/debian/ ${codename}-updates main contrib non-free non-free-firmware
EOF
            ;;
        tsinghua)
            cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename} main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename} main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${codename}-security main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security ${codename}-security main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename}-updates main contrib non-free non-free-firmware
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename}-updates main contrib non-free non-free-firmware
EOF
            ;;
        official)
            cat > /etc/apt/sources.list <<EOF
deb https://deb.debian.org/debian/ ${codename} main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ ${codename} main contrib non-free non-free-firmware
deb https://deb.debian.org/debian-security ${codename}-security main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian-security ${codename}-security main contrib non-free non-free-firmware
deb https://deb.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware
EOF
            ;;
        hk)
            cat > /etc/apt/sources.list <<EOF
deb http://ftp.hk.debian.org/debian/ ${codename} main contrib non-free non-free-firmware
deb-src http://ftp.hk.debian.org/debian/ ${codename} main contrib non-free non-free-firmware
deb http://ftp.hk.debian.org/debian-security ${codename}-security main contrib non-free non-free-firmware
deb-src http://ftp.hk.debian.org/debian-security ${codename}-security main contrib non-free non-free-firmware
deb http://ftp.hk.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware
deb-src http://ftp.hk.debian.org/debian/ ${codename}-updates main contrib non-free non-free-firmware
EOF
            ;;
    esac

    log_success "已配置 ${mirror} 源"
}

# ==============================================================================
# 账户安全
# ==============================================================================

setup_security() {
    log_info "开始配置账户安全..."

    # 设置root密码
    echo ""
    if get_confirmation "是否设置新的root密码?"; then
        setup_root_password
    fi

    # 创建普通用户
    echo ""
    if get_confirmation "是否创建新的普通用户?"; then
        create_user
    fi

    # 配置SSH密钥
    echo ""
    if get_confirmation "是否配置SSH密钥认证?"; then
        setup_ssh_keys
    fi

    log_success "账户安全配置完成"
}

setup_root_password() {
    local password password_confirm

    read -sp "请输入新的root密码: " password
    echo ""
    read -sp "请再次确认密码: " password_confirm
    echo ""

    if [[ "$password" != "$password_confirm" ]]; then
        log_error "两次密码不一致，跳过密码设置"
        return 1
    fi

    echo "root:$password" | chpasswd
    log_success "Root密码设置成功"
}

create_user() {
    local username password

    read -p "请输入用户名: " username

    if id "$username" &>/dev/null; then
        log_warning "用户 $username 已存在，跳过创建"
        return
    fi

    useradd -m -s /bin/bash "$username"

    read -sp "请输入用户密码: " password
    echo ""
    echo "$username:$password" | chpasswd

    # 添加sudo权限
    if usermod -aG sudo "$username" 2>/dev/null; then
        log_success "已添加sudo权限"
    elif usermod -aG wheel "$username" 2>/dev/null; then
        log_success "已添加wheel权限"
    fi

    log_success "用户 $username 创建成功"
}

setup_ssh_keys() {
    local ssh_key

    mkdir -p /root/.ssh
    chmod 700 /root/.ssh

    echo "请粘贴你的SSH公钥（完成后按回车）:"
    read ssh_key

    if [[ -n "$ssh_key" ]]; then
        echo "$ssh_key" >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys

        # 修改SSH配置支持密钥认证
        sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

        log_success "SSH密钥配置完成"
    else
        log_warning "未输入公钥，跳过配置"
    fi
}

# ==============================================================================
# SSH安全加固
# ==============================================================================

harden_ssh() {
    log_info "开始SSH安全加固..."

    # 备份SSH配置
    backup_file "/etc/ssh/sshd_config"

    # 修改SSH端口
    echo ""
    if get_confirmation "是否修改SSH端口?"; then
        change_ssh_port
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
    safe_service_restart "ssh"

    log_success "SSH安全加固完成"
}

change_ssh_port() {
    local ssh_port

    read -p "请输入新的SSH端口 (建议10000-65535): " ssh_port

    if ! validate_input "$ssh_port" "port"; then
        log_error "无效的端口号"
        return 1
    fi

    sed -i "s/^#*Port .*/Port $ssh_port/" /etc/ssh/sshd_config
    log_success "SSH端口已修改为: $ssh_port"
    log_warning "请记住新端口号，下次连接使用: ssh -p $ssh_port user@ip"

    # 保存配置
    save_config "SSH_PORT" "$ssh_port"
}

# ==============================================================================
# 防火墙配置
# ==============================================================================

setup_firewall() {
    log_info "开始配置防火墙..."

    echo ""
    show_menu "请选择防火墙类型：" \
        "nftables (推荐，更现代)" \
        "iptables (传统方式)" \
        "跳过防火墙配置"

    local choice=$(get_menu_choice 3)

    case $choice in
        1) setup_nftables_firewall ;;
        2) setup_iptables_firewall ;;
        3) log_info "跳过防火墙配置"; return ;;
    esac

    log_success "防火墙配置完成"
}

setup_nftables_firewall() {
    log_info "配置nftables防火墙..."

    # 卸载ufw（如果存在）
    if is_package_installed "ufw"; then
        ufw --force reset >/dev/null 2>&1
        apt-get purge -y ufw >/dev/null 2>&1
        log_info "已卸载ufw"
    fi

    install_package "nftables"

    # 获取SSH端口
    local ssh_port=$(load_config "SSH_PORT" "$DEFAULT_SSH_PORT")

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
    safe_service_enable "nftables"
    safe_service_restart "nftables"

    log_success "nftables配置完成，SSH端口 $ssh_port 已开放"
}

setup_iptables_firewall() {
    log_info "配置iptables防火墙..."

    # 安装iptables-persistent
    echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
    echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
    install_package "iptables-persistent"

    # 获取SSH端口
    local ssh_port=$(load_config "SSH_PORT" "$DEFAULT_SSH_PORT")

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

# ==============================================================================
# 系统性能优化
# ==============================================================================

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
    safe_exec "sysctl --system" "应用系统参数失败"
    log_success "系统参数优化完成"

    # 配置swap
    echo ""
    if get_confirmation "是否配置虚拟内存(swap)? 建议内存小于4GB的服务器配置"; then
        setup_swap
    fi

    log_success "系统性能优化完成"
}

setup_swap() {
    # 检查是否已存在swap
    if swapon --show | grep -q '/swapfile'; then
        log_warning "Swap已存在，跳过配置"
        return
    fi

    local swap_size
    read -p "请输入swap大小(GB) [建议2-4]: " swap_size
    swap_size=${swap_size:-2}

    log_info "创建 ${swap_size}GB swap文件..."
    safe_exec "fallocate -l ${swap_size}G /swapfile" "创建swap文件失败"
    safe_exec "chmod 600 /swapfile" "设置swap文件权限失败"
    safe_exec "mkswap /swapfile" "格式化swap文件失败"
    safe_exec "swapon /swapfile" "启用swap失败"

    # 添加到fstab
    if ! grep -q '/swapfile' /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
    fi

    log_success "Swap配置完成: ${swap_size}GB"
}

# ==============================================================================
# 系统语言配置
# ==============================================================================

setup_locale() {
    log_info "开始配置系统语言..."

    echo ""
    show_menu "请选择系统语言（Locale）：" \
        "zh_CN.UTF-8 (简体中文 - UTF-8)" \
        "en_US.UTF-8 (美国英语 - UTF-8)" \
        "zh_TW.UTF-8 (繁体中文 - UTF-8)" \
        "ja_JP.UTF-8 (日本语 - UTF-8)" \
        "自定义" \
        "跳过语言设置"

    local choice=$(get_menu_choice 6)

    case $choice in
        1) configure_locale "zh_CN.UTF-8" ;;
        2) configure_locale "en_US.UTF-8" ;;
        3) configure_locale "zh_TW.UTF-8" ;;
        4) configure_locale "ja_JP.UTF-8" ;;
        5) configure_custom_locale ;;
        6) log_info "跳过语言设置"; return ;;
    esac
}

configure_locale() {
    local locale=$1

    # 安装locales包
    install_package "locales"

    # 生成locale
    log_info "生成locale: $locale"

    # 确保locale在/etc/locale.gen中未被注释
    sed -i "s/^# *${locale}/${locale}/" /etc/locale.gen 2>/dev/null

    # 如果locale不存在，添加它
    if ! grep -q "^${locale}" /etc/locale.gen 2>/dev/null; then
        echo "${locale} UTF-8" >> /etc/locale.gen
    fi

    # 生成locale
    safe_exec "locale-gen" "生成locale失败"

    # 设置系统默认locale
    update-locale LANG=$locale LC_ALL=$locale LANGUAGE=${locale%%.*} >/dev/null 2>&1

    # 同时更新/etc/default/locale
    cat > /etc/default/locale <<EOF
LANG=$locale
LANGUAGE=${locale%%.*}
LC_ALL=$locale
EOF

    log_success "系统语言已设置为: $locale"
    log_info "当前locale: $(locale | grep LANG= | cut -d'=' -f2)"
    log_warning "语言设置将在重新登录后完全生效"
}

configure_custom_locale() {
    local locale
    read -p "请输入Locale (例如: en_GB.UTF-8): " locale

    if [[ -n "$locale" ]]; then
        configure_locale "$locale"
    else
        log_warning "未输入locale，跳过配置"
    fi
}

# ==============================================================================
# 时间同步
# ==============================================================================

setup_time_sync() {
    log_info "开始配置时间同步..."

    # 设置时区
    echo ""
    show_menu "请选择时区：" \
        "Asia/Shanghai (中国 - 推荐)" \
        "Asia/Hong_Kong (香港)" \
        "Asia/Tokyo (日本)" \
        "America/New_York (美国东部)" \
        "Europe/London (英国)" \
        "UTC (协调世界时)" \
        "自定义" \
        "跳过时区设置"

    local choice=$(get_menu_choice 8)

    case $choice in
        1) timedatectl set-timezone "Asia/Shanghai" ;;
        2) timedatectl set-timezone "Asia/Hong_Kong" ;;
        3) timedatectl set-timezone "Asia/Tokyo" ;;
        4) timedatectl set-timezone "America/New_York" ;;
        5) timedatectl set-timezone "Europe/London" ;;
        6) timedatectl set-timezone "UTC" ;;
        7) configure_custom_timezone ;;
        8) log_info "跳过时区设置" ;;
    esac

    # 安装时间同步服务
    install_package "systemd-timesyncd"

    # 配置NTP服务器
    echo ""
    show_menu "请选择NTP服务器：" \
        "国内NTP服务器 (推荐国内用户)" \
        "国际NTP服务器 (推荐海外用户)" \
        "跳过NTP配置"

    local ntp_choice=$(get_menu_choice 3)

    case $ntp_choice in
        1) configure_ntp_servers "cn" ;;
        2) configure_ntp_servers "global" ;;
        3) log_info "跳过NTP配置"; return ;;
    esac

    # 启用时间同步
    systemctl unmask systemd-timesyncd.service >/dev/null 2>&1
    safe_service_enable "systemd-timesyncd"
    safe_service_restart "systemd-timesyncd"
    timedatectl set-ntp yes

    log_success "时间同步配置完成"
    log_info "当前时间: $(date)"
}

configure_custom_timezone() {
    local timezone
    echo ""
    log_info "可用时区列表: timedatectl list-timezones"
    read -p "请输入时区 (例如: Asia/Singapore): " timezone

    if timedatectl set-timezone "$timezone" 2>/dev/null; then
        log_success "时区已设置为: $timezone"
    else
        log_error "无效的时区，保持当前设置"
    fi
}

configure_ntp_servers() {
    local region=$1

    if [[ "$region" == "cn" ]]; then
        cat > /etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=${NTP_SERVERS_CN[0]} ${NTP_SERVERS_CN[1]} ${NTP_SERVERS_CN[2]} ${NTP_SERVERS_CN[3]}
FallbackNTP=${NTP_SERVERS_CN[0]} ${NTP_SERVERS_CN[1]}
EOF
    else
        cat > /etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=${NTP_SERVERS_GLOBAL[0]} ${NTP_SERVERS_GLOBAL[1]} ${NTP_SERVERS_GLOBAL[2]} ${NTP_SERVERS_GLOBAL[3]}
FallbackNTP=${NTP_SERVERS_GLOBAL[0]} ${NTP_SERVERS_GLOBAL[1]}
EOF
    fi
}

# ==============================================================================
# 安全加固
# ==============================================================================

security_hardening() {
    log_info "开始安全加固..."

    # 安装Fail2Ban
    echo ""
    if get_confirmation "是否安装Fail2Ban防暴力破解?"; then
        setup_fail2ban
    fi

    # 配置自动安全更新
    echo ""
    if get_confirmation "是否启用自动安全更新?"; then
        setup_auto_updates
    fi

    # ICMP Ping控制
    echo ""
    if get_confirmation "是否禁用ICMP Ping响应? (不推荐新手)"; then
        disable_ping
    fi

    log_success "安全加固完成"
}

setup_fail2ban() {
    install_package "fail2ban"

    # 获取SSH端口
    local ssh_port=$(load_config "SSH_PORT" "$DEFAULT_SSH_PORT")

    # 配置SSH保护
    cat > /etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = $FAIL2BAN_MAXRETRY
findtime = $FAIL2BAN_FINDTIME
bantime = $FAIL2BAN_BANTIME
backend = systemd
EOF

    # 启动Fail2Ban
    safe_service_enable "fail2ban"
    safe_service_restart "fail2ban"

    log_success "Fail2Ban安装完成 (5次错误封禁30分钟)"
}

setup_auto_updates() {
    install_package "unattended-upgrades"

    echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
    dpkg-reconfigure -plow unattended-upgrades >/dev/null 2>&1

    log_success "自动安全更新已启用"
}

disable_ping() {
    cat > /etc/sysctl.d/99-vpsbox-icmp.conf <<EOF
net.ipv4.icmp_echo_ignore_all = 1
EOF

    safe_exec "sysctl -w net.ipv4.icmp_echo_ignore_all=1" "禁用ICMP失败"

    log_success "已禁用ICMP Ping响应"
}

# ==============================================================================
# 系统清理
# ==============================================================================

system_cleanup() {
    log_info "开始系统清理..."

    if ! get_confirmation "是否进行系统清理?"; then
        log_info "跳过系统清理"
        return
    fi

    # 清理软件包缓存
    log_info "清理软件包缓存..."
    safe_exec "apt-get clean" "清理软件包缓存失败"
    safe_exec "apt-get autoremove -y" "自动移除无用包失败"
    safe_exec "apt-get autoclean" "清理过时包失败"

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
}