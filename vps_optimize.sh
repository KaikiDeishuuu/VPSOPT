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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
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

# 进度条函数
show_progress() {
    local current=$1
    local total=$2
    local task_name=$3
    local percent=$((current * 100 / total))
    local completed=$((current * 50 / total))
    local remaining=$((50 - completed))
    
    # 构建进度条
    local bar=""
    for ((i=0; i<completed; i++)); do
        bar="${bar}█"
    done
    for ((i=0; i<remaining; i++)); do
        bar="${bar}░"
    done
    
    # 显示进度
    echo -ne "\r${CYAN}[${bar}]${NC} ${BOLD}${percent}%${NC} ${task_name}  "
    
    # 完成时换行
    if [ $current -eq $total ]; then
        echo -e "\n"
    fi
}

# 带进度条的任务执行
run_with_progress() {
    local task_name=$1
    local task_command=$2
    
    echo ""
    echo -e "${BOLD}${CYAN}▶${NC} 正在执行: ${YELLOW}${task_name}${NC}"
    echo ""
    
    # 启动任务
    eval "$task_command" &
    local pid=$!
    
    # 显示动态进度条
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${CYAN}${spinner[$i]}${NC} 处理中... ${GRAY}(PID: $pid)${NC}  "
        i=$(( (i+1) % 10 ))
        sleep 0.1
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\r${GREEN}✓${NC} ${task_name} ${GREEN}完成${NC}                          "
    else
        echo -e "\r${RED}✗${NC} ${task_name} ${RED}失败${NC} (退出码: $exit_code)                "
    fi
    
    return $exit_code
}

# 步骤进度显示
show_step() {
    local step=$1
    local total=$2
    local title=$3
    
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${GREEN}步骤 [$step/$total]${NC} ${YELLOW}$title${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 显示标题
show_header() {
    clear
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}         ${BOLD}${CYAN}🚀 VPS 服务器优化脚本 v2.0 🚀${NC}                  ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}     ${YELLOW}让你的服务器从裸机变成性能强劲的战斗机${NC}             ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}            ${GRAY}作者: Kaiki  |  开源项目${NC}                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
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

# 6. 系统语言配置
setup_locale() {
    log_info "开始配置系统语言..."
    
    echo ""
    echo "请选择系统语言（Locale）："
    echo "1) zh_CN.UTF-8 (简体中文 - UTF-8)"
    echo "2) en_US.UTF-8 (美国英语 - UTF-8)"
    echo "3) zh_TW.UTF-8 (繁体中文 - UTF-8)"
    echo "4) ja_JP.UTF-8 (日本语 - UTF-8)"
    echo "5) 自定义"
    echo "6) 跳过语言设置"
    read -p "请输入选项 [1-6]: " locale_choice
    
    case $locale_choice in
        1)
            LOCALE="zh_CN.UTF-8"
            ;;
        2)
            LOCALE="en_US.UTF-8"
            ;;
        3)
            LOCALE="zh_TW.UTF-8"
            ;;
        4)
            LOCALE="ja_JP.UTF-8"
            ;;
        5)
            read -p "请输入Locale (例如: en_GB.UTF-8): " LOCALE
            ;;
        6)
            log_info "跳过语言设置"
            return
            ;;
        *)
            log_warning "无效选项，使用默认配置"
            return
            ;;
    esac
    
    # 安装locales包
    log_info "安装locales包..."
    apt-get install -y locales >/dev/null 2>&1
    
    # 生成locale
    log_info "生成locale: $LOCALE"
    
    # 确保locale在/etc/locale.gen中未被注释
    sed -i "s/^# *${LOCALE}/${LOCALE}/" /etc/locale.gen 2>/dev/null
    
    # 如果locale不存在，添加它
    if ! grep -q "^${LOCALE}" /etc/locale.gen 2>/dev/null; then
        echo "${LOCALE} UTF-8" >> /etc/locale.gen
    fi
    
    # 生成locale
    locale-gen >/dev/null 2>&1
    
    # 设置系统默认locale
    update-locale LANG=$LOCALE LC_ALL=$LOCALE LANGUAGE=${LOCALE%%.*} >/dev/null 2>&1
    
    # 同时更新/etc/default/locale
    cat > /etc/default/locale <<EOF
LANG=$LOCALE
LANGUAGE=${LOCALE%%.*}
LC_ALL=$LOCALE
EOF
    
    log_success "系统语言已设置为: $LOCALE"
    log_info "当前locale: $(locale | grep LANG= | cut -d'=' -f2)"
    log_warning "语言设置将在重新登录后完全生效"
    
    sleep 2
}

# 7. 时间同步
setup_time_sync() {
    log_info "开始配置时间同步..."
    
    # 设置时区
    echo ""
    echo "请选择时区："
    echo "1) Asia/Shanghai (中国 - 推荐)"
    echo "2) Asia/Hong_Kong (香港)"
    echo "3) Asia/Tokyo (日本)"
    echo "4) America/New_York (美国东部)"
    echo "5) Europe/London (英国)"
    echo "6) UTC (协调世界时)"
    echo "7) 自定义"
    echo "8) 跳过时区设置"
    read -p "请输入选项 [1-8]: " timezone_choice
    
    case $timezone_choice in
        1) timedatectl set-timezone Asia/Shanghai ;;
        2) timedatectl set-timezone Asia/Hong_Kong ;;
        3) timedatectl set-timezone Asia/Tokyo ;;
        4) timedatectl set-timezone America/New_York ;;
        5) timedatectl set-timezone Europe/London ;;
        6) timedatectl set-timezone UTC ;;
        7) 
            echo ""
            log_info "可用时区列表: timedatectl list-timezones"
            read -p "请输入时区 (例如: Asia/Singapore): " custom_timezone
            if timedatectl set-timezone "$custom_timezone" 2>/dev/null; then
                log_success "时区已设置为: $custom_timezone"
            else
                log_error "无效的时区，保持当前设置"
            fi
            ;;
        8) log_info "跳过时区设置" ;;
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

# 16. Cloudflare Tunnel配置
setup_cloudflare_tunnel() {
    log_info "开始配置Cloudflare Tunnel..."
    
    echo ""
    echo -e "${YELLOW}Cloudflare Tunnel 说明:${NC}"
    echo "Cloudflare Tunnel 可以让您的本地服务通过Cloudflare网络安全暴露到互联网"
    echo ""
    echo "功能特性:"
    echo "  - 无需公网IP或开放端口"
    echo "  - 自动HTTPS加密"
    echo "  - DDoS防护"
    echo "  - 全球CDN加速"
    echo ""
    
    read -p "是否安装Cloudflare Tunnel (cloudflared)? (y/n): " install_cf
    if [[ "$install_cf" != "y" ]]; then
        log_info "跳过Cloudflare Tunnel安装"
        return
    fi
    
    # 检测系统架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            CF_ARCH="amd64"
            ;;
        aarch64|arm64)
            CF_ARCH="arm64"
            ;;
        armv7l)
            CF_ARCH="armhf"
            ;;
        *)
            log_error "不支持的架构: $ARCH"
            return
            ;;
    esac
    
    log_info "检测到系统架构: $ARCH (使用 $CF_ARCH 版本)"
    
    # 安装cloudflared
    log_info "下载并安装cloudflared..."
    
    # 添加Cloudflare GPG key
    mkdir -p /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    
    # 添加apt仓库
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflared.list
    
    # 安装cloudflared
    apt-get update >/dev/null 2>&1
    apt-get install -y cloudflared
    
    if command -v cloudflared >/dev/null 2>&1; then
        log_success "cloudflared 安装成功: $(cloudflared --version)"
    else
        log_error "cloudflared 安装失败"
        return
    fi
    
    # 配置向导
    echo ""
    echo -e "${YELLOW}配置选项:${NC}"
    echo "1) 快速配置 - 通过浏览器登录Cloudflare账户"
    echo "2) 手动配置 - 使用已有的Tunnel Token"
    echo "3) 仅安装，稍后配置"
    read -p "请选择 [1-3]: " cf_config_choice
    
    case $cf_config_choice in
        1)
            log_info "启动快速配置..."
            echo ""
            echo -e "${YELLOW}请按照以下步骤操作:${NC}"
            echo "1. 运行: cloudflared tunnel login"
            echo "2. 在浏览器中授权"
            echo "3. 创建tunnel: cloudflared tunnel create mytunnel"
            echo "4. 配置路由: cloudflared tunnel route dns mytunnel example.com"
            echo "5. 创建配置文件 /etc/cloudflared/config.yml"
            echo "6. 运行: cloudflared tunnel run mytunnel"
            echo ""
            log_info "详细文档: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/"
            ;;
        2)
            read -p "请输入Tunnel Token: " tunnel_token
            if [[ -n "$tunnel_token" ]]; then
                # 创建systemd服务
                cat > /etc/systemd/system/cloudflared.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/cloudflared tunnel run --token $tunnel_token
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
                
                systemctl daemon-reload
                systemctl enable cloudflared
                systemctl start cloudflared
                
                log_success "Cloudflared 服务已启动"
                log_info "查看状态: systemctl status cloudflared"
            else
                log_warning "未输入Token，请手动配置"
            fi
            ;;
        3)
            log_info "已安装cloudflared，使用以下命令配置:"
            echo "  cloudflared tunnel login"
            echo "  cloudflared tunnel create <NAME>"
            echo "  cloudflared tunnel route dns <NAME> <DOMAIN>"
            ;;
    esac
    
    log_success "Cloudflare Tunnel配置完成"
    sleep 2
}

# 17. Cloudflare WARP配置
setup_cloudflare_warp() {
    log_info "开始配置Cloudflare WARP..."
    
    echo ""
    echo -e "${YELLOW}Cloudflare WARP 说明:${NC}"
    echo "WARP 可以加速网络连接，提供更好的隐私保护"
    echo ""
    echo "功能特性:"
    echo "  - 加速国际网络访问"
    echo "  - 隐藏真实IP"
    echo "  - 基于WireGuard协议"
    echo "  - 免费使用"
    echo ""
    
    read -p "是否配置Cloudflare WARP? (y/n): " install_warp
    if [[ "$install_warp" != "y" ]]; then
        log_info "跳过WARP配置"
        return
    fi
    
    echo ""
    echo "请选择安装方式:"
    echo "1) 官方WARP客户端 (推荐，需要Ubuntu 20.04+或Debian 11+)"
    echo "2) wgcf + WireGuard (兼容性更好，支持所有系统)"
    read -p "请选择 [1-2]: " warp_method
    
    case $warp_method in
        1)
            setup_warp_official
            ;;
        2)
            setup_warp_wgcf
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    log_success "WARP配置完成"
    sleep 2
}

# WARP官方客户端安装
setup_warp_official() {
    log_info "安装官方WARP客户端..."
    
    # 添加Cloudflare GPG key
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    
    # 添加apt仓库
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
    
    # 安装
    apt-get update >/dev/null 2>&1
    apt-get install -y cloudflare-warp
    
    if command -v warp-cli >/dev/null 2>&1; then
        log_success "WARP客户端安装成功"
        
        # 注册和连接
        echo ""
        read -p "是否立即注册并连接WARP? (y/n): " connect_now
        if [[ "$connect_now" == "y" ]]; then
            log_info "注册WARP..."
            warp-cli register
            
            log_info "连接WARP..."
            warp-cli connect
            
            sleep 3
            
            log_info "WARP状态:"
            warp-cli status
        fi
        
        echo ""
        echo -e "${YELLOW}常用命令:${NC}"
        echo "  warp-cli connect     - 连接"
        echo "  warp-cli disconnect  - 断开"
        echo "  warp-cli status      - 查看状态"
        echo "  warp-cli settings    - 查看设置"
    else
        log_error "WARP客户端安装失败"
    fi
}

# wgcf + WireGuard安装
setup_warp_wgcf() {
    log_info "安装wgcf + WireGuard..."
    
    # 安装WireGuard
    log_info "安装WireGuard..."
    apt-get install -y wireguard-tools
    
    # 下载wgcf
    log_info "下载wgcf..."
    
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            WGCF_ARCH="amd64"
            ;;
        aarch64|arm64)
            WGCF_ARCH="arm64"
            ;;
        armv7l)
            WGCF_ARCH="armv7"
            ;;
        *)
            log_error "不支持的架构: $ARCH"
            return
            ;;
    esac
    
    # 获取最新版本
    WGCF_VERSION=$(curl -s https://api.github.com/repos/ViRb3/wgcf/releases/latest | grep "tag_name" | cut -d'"' -f4)
    
    if [[ -z "$WGCF_VERSION" ]]; then
        log_warning "无法获取最新版本，使用v2.2.18"
        WGCF_VERSION="v2.2.18"
    fi
    
    log_info "下载wgcf $WGCF_VERSION ($WGCF_ARCH)..."
    curl -fsSL "https://github.com/ViRb3/wgcf/releases/download/${WGCF_VERSION}/wgcf_${WGCF_VERSION#v}_linux_${WGCF_ARCH}" -o /usr/local/bin/wgcf
    chmod +x /usr/local/bin/wgcf
    
    if command -v wgcf >/dev/null 2>&1; then
        log_success "wgcf安装成功: $(wgcf version 2>&1 || echo 'installed')"
    else
        log_error "wgcf安装失败"
        return
    fi
    
    # 配置WARP
    echo ""
    read -p "是否立即配置WARP? (y/n): " config_now
    if [[ "$config_now" == "y" ]]; then
        cd /etc/wireguard || exit
        
        log_info "注册WARP账户..."
        wgcf register
        
        log_info "生成WireGuard配置..."
        wgcf generate
        
        # 重命名配置文件
        if [ -f wgcf-profile.conf ]; then
            mv wgcf-profile.conf wgcf.conf
            log_success "配置文件已生成: /etc/wireguard/wgcf.conf"
            
            echo ""
            echo -e "${YELLOW}启用WARP:${NC}"
            echo "  wg-quick up wgcf"
            echo ""
            echo -e "${YELLOW}停止WARP:${NC}"
            echo "  wg-quick down wgcf"
            echo ""
            echo -e "${YELLOW}开机自启:${NC}"
            echo "  systemctl enable wg-quick@wgcf"
            echo ""
            
            read -p "是否立即启用WARP? (y/n): " enable_now
            if [[ "$enable_now" == "y" ]]; then
                wg-quick up wgcf
                log_success "WARP已启用"
                
                read -p "是否设置开机自启? (y/n): " auto_start
                if [[ "$auto_start" == "y" ]]; then
                    systemctl enable wg-quick@wgcf
                    log_success "已设置开机自启"
                fi
            fi
        else
            log_error "配置文件生成失败"
        fi
        
        cd - >/dev/null || exit
    fi
}

# 18. 网络优化工具集
setup_network_optimization() {
    log_info "开始配置网络优化工具..."
    
    echo ""
    echo -e "${YELLOW}网络优化工具集:${NC}"
    echo "1) DNS优化 (配置更快的DNS服务器)"
    echo "2) MTU优化 (优化网络传输单元)"
    echo "3) TCP Fast Open (加速TCP连接)"
    echo "4) 网络诊断工具 (mtr, iperf3, tcpdump)"
    echo "5) 全部配置"
    echo "6) 返回"
    read -p "请选择 [1-6]: " net_choice
    
    case $net_choice in
        1)
            optimize_dns
            ;;
        2)
            optimize_mtu
            ;;
        3)
            optimize_tcp_fastopen
            ;;
        4)
            install_network_tools
            ;;
        5)
            optimize_dns
            optimize_mtu
            optimize_tcp_fastopen
            install_network_tools
            ;;
        6)
            return
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    log_success "网络优化配置完成"
    sleep 2
}

# DNS优化
optimize_dns() {
    log_info "配置DNS优化..."
    
    echo ""
    echo "请选择DNS服务器:"
    echo "1) Cloudflare DNS (1.1.1.1) - 推荐国际用户"
    echo "2) Google DNS (8.8.8.8) - 稳定可靠"
    echo "3) 阿里DNS (223.5.5.5) - 推荐国内用户"
    echo "4) 腾讯DNS (119.29.29.29) - 国内备选"
    echo "5) 自定义"
    read -p "请选择 [1-5]: " dns_choice
    
    case $dns_choice in
        1)
            DNS1="1.1.1.1"
            DNS2="1.0.0.1"
            ;;
        2)
            DNS1="8.8.8.8"
            DNS2="8.8.4.4"
            ;;
        3)
            DNS1="223.5.5.5"
            DNS2="223.6.6.6"
            ;;
        4)
            DNS1="119.29.29.29"
            DNS2="182.254.116.116"
            ;;
        5)
            read -p "请输入主DNS: " DNS1
            read -p "请输入备用DNS: " DNS2
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    # 备份原始配置
    cp /etc/resolv.conf /etc/resolv.conf.backup.$(date +%Y%m%d_%H%M%S)
    
    # 配置DNS
    cat > /etc/resolv.conf <<EOF
# DNS配置 - 由VPS优化脚本配置
nameserver $DNS1
nameserver $DNS2

# 选项
options timeout:2
options attempts:3
options rotate
options single-request-reopen
EOF
    
    # 防止被覆盖
    chattr +i /etc/resolv.conf 2>/dev/null || log_warning "无法锁定resolv.conf"
    
    log_success "DNS已配置: $DNS1, $DNS2"
    
    # 测试DNS
    echo ""
    log_info "测试DNS解析..."
    if nslookup google.com >/dev/null 2>&1; then
        log_success "DNS解析正常"
    else
        log_warning "DNS解析可能存在问题"
    fi
}

# MTU优化
optimize_mtu() {
    log_info "配置MTU优化..."
    
    # 获取默认网络接口
    DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    
    if [[ -z "$DEFAULT_INTERFACE" ]]; then
        log_error "无法检测默认网络接口"
        return
    fi
    
    log_info "检测到默认网络接口: $DEFAULT_INTERFACE"
    
    # 当前MTU
    CURRENT_MTU=$(ip link show "$DEFAULT_INTERFACE" | grep mtu | awk '{print $5}')
    log_info "当前MTU: $CURRENT_MTU"
    
    echo ""
    echo "MTU优化建议:"
    echo "  - PPPoE连接: 1492"
    echo "  - 以太网: 1500 (默认)"
    echo "  - Jumbo帧: 9000 (局域网)"
    echo "  - VPN/隧道: 1400-1450"
    echo ""
    
    read -p "是否修改MTU? (y/n): " change_mtu
    if [[ "$change_mtu" != "y" ]]; then
        return
    fi
    
    read -p "请输入新的MTU值 [1400-1500]: " new_mtu
    
    if [[ "$new_mtu" =~ ^[0-9]+$ ]] && [ "$new_mtu" -ge 1200 ] && [ "$new_mtu" -le 9000 ]; then
        # 临时设置
        ip link set "$DEFAULT_INTERFACE" mtu "$new_mtu"
        
        # 永久设置
        if [ -f /etc/network/interfaces ]; then
            if grep -q "mtu" /etc/network/interfaces; then
                sed -i "s/mtu .*/mtu $new_mtu/" /etc/network/interfaces
            else
                echo "    mtu $new_mtu" >> /etc/network/interfaces
            fi
        fi
        
        # 对于systemd-networkd
        if [ -d /etc/systemd/network ]; then
            cat > /etc/systemd/network/10-mtu.link <<EOF
[Match]
Name=$DEFAULT_INTERFACE

[Link]
MTUBytes=$new_mtu
EOF
        fi
        
        log_success "MTU已设置为: $new_mtu"
    else
        log_error "无效的MTU值"
    fi
}

# TCP Fast Open优化
optimize_tcp_fastopen() {
    log_info "配置TCP Fast Open..."
    
    # 检查当前状态
    CURRENT_TFO=$(cat /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null || echo "0")
    log_info "当前TCP Fast Open值: $CURRENT_TFO"
    
    echo ""
    echo "TCP Fast Open说明:"
    echo "  0 = 禁用"
    echo "  1 = 仅作为客户端"
    echo "  2 = 仅作为服务器"
    echo "  3 = 客户端和服务器 (推荐)"
    echo ""
    
    read -p "是否启用TCP Fast Open? (y/n): " enable_tfo
    if [[ "$enable_tfo" != "y" ]]; then
        return
    fi
    
    # 设置为3 (客户端+服务器)
    sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1
    
    # 写入配置文件
    if ! grep -q "net.ipv4.tcp_fastopen" /etc/sysctl.d/99-custom.conf 2>/dev/null; then
        echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.d/99-custom.conf
    else
        sed -i 's/net.ipv4.tcp_fastopen.*/net.ipv4.tcp_fastopen = 3/' /etc/sysctl.d/99-custom.conf
    fi
    
    log_success "TCP Fast Open已启用"
}

# 安装网络诊断工具
install_network_tools() {
    log_info "安装网络诊断工具..."
    
    echo ""
    echo "将安装以下工具:"
    echo "  - mtr: 网络路由追踪"
    echo "  - iperf3: 带宽测试"
    echo "  - tcpdump: 数据包分析"
    echo "  - speedtest-cli: 网速测试"
    echo ""
    
    read -p "是否继续? (y/n): " install_tools
    if [[ "$install_tools" != "y" ]]; then
        return
    fi
    
    apt-get install -y mtr iperf3 tcpdump speedtest-cli
    
    log_success "网络诊断工具安装完成"
    
    echo ""
    echo -e "${YELLOW}使用示例:${NC}"
    echo "  mtr google.com           - 路由追踪"
    echo "  iperf3 -s                - 启动带宽测试服务器"
    echo "  iperf3 -c <server_ip>    - 带宽测试客户端"
    echo "  speedtest-cli            - 测试网速"
    echo "  tcpdump -i eth0          - 抓包分析"
}

# 20. 性能基准测试
performance_benchmark() {
    log_info "开始性能基准测试..."
    
    echo ""
    echo -e "${YELLOW}性能基准测试工具:${NC}"
    echo "1) Superbench - 综合测试 (推荐)"
    echo "2) YABS - Yet Another Bench Script"
    echo "3) Bench.sh - 经典测试脚本"
    echo "4) UnixBench - 深度性能测试"
    echo "5) 自定义测试组合"
    echo "6) 全部运行 (耗时较长)"
    read -p "请选择 [1-6]: " bench_choice
    
    case $bench_choice in
        1)
            run_superbench
            ;;
        2)
            run_yabs
            ;;
        3)
            run_bench_sh
            ;;
        4)
            run_unixbench
            ;;
        5)
            run_custom_benchmark
            ;;
        6)
            log_info "运行全部测试..."
            run_superbench
            run_yabs
            run_bench_sh
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    log_success "性能测试完成"
}

# Superbench测试
run_superbench() {
    log_info "运行Superbench综合测试..."
    echo ""
    echo -e "${CYAN}测试内容: CPU/内存/硬盘IO/网络${NC}"
    echo ""
    
    if curl -fsL https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash; then
        log_success "Superbench测试完成"
    else
        log_error "Superbench测试失败"
    fi
}

# YABS测试
run_yabs() {
    log_info "运行YABS测试..."
    echo ""
    echo -e "${CYAN}测试内容: CPU/硬盘/网络速度${NC}"
    echo ""
    
    if curl -sL yabs.sh | bash; then
        log_success "YABS测试完成"
    else
        log_error "YABS测试失败"
    fi
}

# Bench.sh测试
run_bench_sh() {
    log_info "运行Bench.sh测试..."
    echo ""
    echo -e "${CYAN}测试内容: 系统信息/IO/网速${NC}"
    echo ""
    
    if wget -qO- bench.sh | bash; then
        log_success "Bench.sh测试完成"
    else
        log_error "Bench.sh测试失败"
    fi
}

# UnixBench测试
run_unixbench() {
    log_info "运行UnixBench深度测试..."
    echo ""
    echo -e "${YELLOW}警告: 此测试耗时较长 (15-30分钟)${NC}"
    read -p "是否继续? (y/n): " continue_test
    
    if [[ "$continue_test" != "y" ]]; then
        return
    fi
    
    # 安装依赖
    apt-get install -y gcc make perl perl-modules >/dev/null 2>&1
    
    # 下载并运行
    cd /tmp
    wget https://github.com/kdlucas/byte-unixbench/archive/v5.1.3.tar.gz
    tar -xzf v5.1.3.tar.gz
    cd byte-unixbench-5.1.3/UnixBench
    ./Run
    
    log_success "UnixBench测试完成"
}

# 自定义测试
run_custom_benchmark() {
    log_info "自定义性能测试..."
    
    echo ""
    echo "选择要测试的项目:"
    
    read -p "测试CPU性能? (y/n): " test_cpu
    if [[ "$test_cpu" == "y" ]]; then
        log_info "CPU性能测试..."
        echo ""
        
        # 安装sysbench
        if ! command -v sysbench >/dev/null 2>&1; then
            apt-get install -y sysbench >/dev/null 2>&1
        fi
        
        echo -e "${CYAN}单核测试:${NC}"
        sysbench cpu --cpu-max-prime=20000 --threads=1 run
        
        echo ""
        echo -e "${CYAN}多核测试:${NC}"
        CORES=$(nproc)
        sysbench cpu --cpu-max-prime=20000 --threads=$CORES run
    fi
    
    read -p "测试硬盘IO? (y/n): " test_io
    if [[ "$test_io" == "y" ]]; then
        log_info "硬盘IO测试..."
        echo ""
        
        # dd写入测试
        echo -e "${CYAN}写入速度测试:${NC}"
        dd if=/dev/zero of=/tmp/test_write bs=1M count=1024 conv=fdatasync 2>&1 | tail -1
        
        # dd读取测试
        echo ""
        echo -e "${CYAN}读取速度测试:${NC}"
        dd if=/tmp/test_write of=/dev/null bs=1M 2>&1 | tail -1
        
        rm -f /tmp/test_write
        
        # fio测试(如果可用)
        if command -v fio >/dev/null 2>&1; then
            echo ""
            echo -e "${CYAN}FIO随机读写测试:${NC}"
            fio --name=random-rw --ioengine=libaio --iodepth=32 --rw=randrw --rwmixread=70 --bs=4k --direct=1 --size=1G --numjobs=4 --runtime=60 --group_reporting
        fi
    fi
    
    read -p "测试网络速度? (y/n): " test_network
    if [[ "$test_network" == "y" ]]; then
        log_info "网络速度测试..."
        echo ""
        
        # 安装speedtest-cli
        if ! command -v speedtest-cli >/dev/null 2>&1; then
            apt-get install -y speedtest-cli >/dev/null 2>&1
        fi
        
        if command -v speedtest-cli >/dev/null 2>&1; then
            speedtest-cli --simple
        else
            log_warning "speedtest-cli安装失败"
        fi
    fi
    
    read -p "测试国内网络延迟? (y/n): " test_ping
    if [[ "$test_ping" == "y" ]]; then
        log_info "测试国内主要城市延迟..."
        echo ""
        
        declare -A CITIES=(
            ["北京"]="www.baidu.com"
            ["上海"]="www.aliyun.com"
            ["广州"]="www.tencent.com"
            ["香港"]="www.hkex.com.hk"
        )
        
        for city in "${!CITIES[@]}"; do
            host="${CITIES[$city]}"
            echo -n "$city: "
            ping -c 4 "$host" 2>/dev/null | tail -1 | awk '{print $4}' | cut -d'/' -f2 | xargs echo "ms"
        done
    fi
    
    log_success "自定义测试完成"
}

# 21. 邮件告警配置
setup_email_alerts() {
    log_info "开始配置邮件告警..."
    
    echo ""
    echo -e "${YELLOW}邮件告警功能说明:${NC}"
    echo "可以在系统异常时自动发送邮件通知"
    echo ""
    echo "支持的邮件服务:"
    echo "1) Gmail"
    echo "2) QQ邮箱"
    echo "3) 163邮箱"
    echo "4) 阿里云邮箱"
    echo "5) 自定义SMTP服务器"
    echo "6) 跳过配置"
    read -p "请选择 [1-6]: " email_choice
    
    case $email_choice in
        1)
            setup_gmail_smtp
            ;;
        2)
            setup_qq_smtp
            ;;
        3)
            setup_163_smtp
            ;;
        4)
            setup_aliyun_smtp
            ;;
        5)
            setup_custom_smtp
            ;;
        6)
            log_info "跳过邮件配置"
            return
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    # 配置告警脚本
    setup_alert_scripts
    
    log_success "邮件告警配置完成"
}

# Gmail SMTP配置
setup_gmail_smtp() {
    log_info "配置Gmail SMTP..."
    
    # 安装msmtp
    apt-get install -y msmtp msmtp-mta mailutils >/dev/null 2>&1
    
    read -p "请输入Gmail地址: " gmail_user
    read -sp "请输入Gmail应用专用密码: " gmail_pass
    echo ""
    
    # 配置msmtp
    cat > /etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           ${gmail_user}
user           ${gmail_user}
password       ${gmail_pass}

account default : gmail
EOF
    
    chmod 600 /etc/msmtprc
    
    # 测试发送
    echo "系统邮件告警测试" | mail -s "VPS告警测试" "$gmail_user"
    
    log_success "Gmail SMTP配置完成"
}

# QQ邮箱SMTP配置
setup_qq_smtp() {
    log_info "配置QQ邮箱SMTP..."
    
    apt-get install -y msmtp msmtp-mta mailutils >/dev/null 2>&1
    
    read -p "请输入QQ邮箱: " qq_user
    read -sp "请输入QQ邮箱授权码: " qq_pass
    echo ""
    
    cat > /etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        qq
host           smtp.qq.com
port           587
from           ${qq_user}
user           ${qq_user}
password       ${qq_pass}

account default : qq
EOF
    
    chmod 600 /etc/msmtprc
    
    echo "系统邮件告警测试" | mail -s "VPS告警测试" "$qq_user"
    
    log_success "QQ邮箱SMTP配置完成"
}

# 163邮箱SMTP配置
setup_163_smtp() {
    log_info "配置163邮箱SMTP..."
    
    apt-get install -y msmtp msmtp-mta mailutils >/dev/null 2>&1
    
    read -p "请输入163邮箱: " email_163
    read -sp "请输入163邮箱授权码: " pass_163
    echo ""
    
    cat > /etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        163
host           smtp.163.com
port           587
from           ${email_163}
user           ${email_163}
password       ${pass_163}

account default : 163
EOF
    
    chmod 600 /etc/msmtprc
    
    echo "系统邮件告警测试" | mail -s "VPS告警测试" "$email_163"
    
    log_success "163邮箱SMTP配置完成"
}

# 阿里云邮箱SMTP配置
setup_aliyun_smtp() {
    log_info "配置阿里云邮箱SMTP..."
    
    apt-get install -y msmtp msmtp-mta mailutils >/dev/null 2>&1
    
    read -p "请输入阿里云邮箱: " aliyun_email
    read -sp "请输入邮箱密码: " aliyun_pass
    echo ""
    
    cat > /etc/msmtprc <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        aliyun
host           smtp.aliyun.com
port           465
tls_starttls   off
from           ${aliyun_email}
user           ${aliyun_email}
password       ${aliyun_pass}

account default : aliyun
EOF
    
    chmod 600 /etc/msmtprc
    
    echo "系统邮件告警测试" | mail -s "VPS告警测试" "$aliyun_email"
    
    log_success "阿里云邮箱SMTP配置完成"
}

# 自定义SMTP配置
setup_custom_smtp() {
    log_info "配置自定义SMTP..."
    
    apt-get install -y msmtp msmtp-mta mailutils >/dev/null 2>&1
    
    read -p "SMTP服务器地址: " smtp_host
    read -p "SMTP端口 (通常587或465): " smtp_port
    read -p "发件人邮箱: " smtp_from
    read -p "用户名: " smtp_user
    read -sp "密码: " smtp_pass
    echo ""
    read -p "使用TLS? (y/n): " use_tls
    
    cat > /etc/msmtprc <<EOF
defaults
auth           on
logfile        /var/log/msmtp.log

account        custom
host           ${smtp_host}
port           ${smtp_port}
from           ${smtp_from}
user           ${smtp_user}
password       ${smtp_pass}
EOF
    
    if [[ "$use_tls" == "y" ]]; then
        cat >> /etc/msmtprc <<EOF
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
EOF
    fi
    
    echo "account default : custom" >> /etc/msmtprc
    
    chmod 600 /etc/msmtprc
    
    read -p "输入接收测试邮件的地址: " test_email
    echo "系统邮件告警测试" | mail -s "VPS告警测试" "$test_email"
    
    log_success "自定义SMTP配置完成"
}

# 配置告警脚本
setup_alert_scripts() {
    log_info "配置告警监控脚本..."
    
    # 获取告警邮箱
    read -p "请输入接收告警的邮箱地址: " alert_email
    
    # 创建告警脚本
    cat > /usr/local/bin/system_alert.sh <<EOF
#!/bin/bash

# 告警邮箱
ALERT_EMAIL="${alert_email}"

# 阈值设置
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85
LOAD_THRESHOLD=5.0

# 获取系统信息
HOSTNAME=\$(hostname)
CPU_USAGE=\$(top -bn1 | grep "Cpu(s)" | awk '{print \$2}' | cut -d'%' -f1 | cut -d'.' -f1)
MEM_USAGE=\$(free | grep Mem | awk '{printf("%.0f", \$3/\$2 * 100.0)}')
DISK_USAGE=\$(df -h / | tail -1 | awk '{print \$5}' | cut -d'%' -f1)
LOAD_AVG=\$(uptime | awk -F'load average:' '{print \$2}' | awk '{print \$1}' | cut -d',' -f1)

# CPU告警
if [ "\$CPU_USAGE" -gt "\$CPU_THRESHOLD" ]; then
    echo "服务器: \$HOSTNAME
CPU使用率过高: \${CPU_USAGE}%
时间: \$(date '+%Y-%m-%d %H:%M:%S')" | mail -s "⚠️ CPU告警 - \$HOSTNAME" "\$ALERT_EMAIL"
fi

# 内存告警
if [ "\$MEM_USAGE" -gt "\$MEM_THRESHOLD" ]; then
    echo "服务器: \$HOSTNAME
内存使用率过高: \${MEM_USAGE}%
时间: \$(date '+%Y-%m-%d %H:%M:%S')" | mail -s "⚠️ 内存告警 - \$HOSTNAME" "\$ALERT_EMAIL"
fi

# 磁盘告警
if [ "\$DISK_USAGE" -gt "\$DISK_THRESHOLD" ]; then
    echo "服务器: \$HOSTNAME
磁盘使用率过高: \${DISK_USAGE}%
时间: \$(date '+%Y-%m-%d %H:%M:%S')" | mail -s "⚠️ 磁盘告警 - \$HOSTNAME" "\$ALERT_EMAIL"
fi

# 系统负载告警
if (( \$(echo "\$LOAD_AVG > \$LOAD_THRESHOLD" | bc -l) )); then
    echo "服务器: \$HOSTNAME
系统负载过高: \${LOAD_AVG}
时间: \$(date '+%Y-%m-%d %H:%M:%S')" | mail -s "⚠️ 负载告警 - \$HOSTNAME" "\$ALERT_EMAIL"
fi

# 检查关键服务
SERVICES=("ssh" "nginx" "docker")
for service in "\${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^\${service}.service" 2>/dev/null; then
        if ! systemctl is-active --quiet "\$service" 2>/dev/null; then
            echo "服务器: \$HOSTNAME
服务停止: \${service}
时间: \$(date '+%Y-%m-%d %H:%M:%S')" | mail -s "⚠️ 服务告警 - \$HOSTNAME" "\$ALERT_EMAIL"
        fi
    fi
done
EOF
    
    chmod +x /usr/local/bin/system_alert.sh
    
    # 添加到crontab (每10分钟检查一次)
    (crontab -l 2>/dev/null | grep -v "system_alert.sh"; echo "*/10 * * * * /usr/local/bin/system_alert.sh") | crontab -
    
    log_success "告警脚本配置完成"
    log_info "告警邮件将发送到: $alert_email"
    log_info "检查间隔: 每10分钟"
}

# 22. 数据库一键部署
setup_database() {
    log_info "开始配置数据库环境..."
    
    echo ""
    echo -e "${YELLOW}数据库部署选项:${NC}"
    echo "1) MySQL 8.0 (最流行)"
    echo "2) MariaDB (MySQL分支)"
    echo "3) PostgreSQL (企业级)"
    echo "4) Redis (缓存数据库)"
    echo "5) MongoDB (文档数据库)"
    echo "6) 多个数据库组合"
    echo "7) 返回"
    read -p "请选择 [1-7]: " db_choice
    
    case $db_choice in
        1) install_mysql ;;
        2) install_mariadb ;;
        3) install_postgresql ;;
        4) install_redis ;;
        5) install_mongodb ;;
        6) install_multiple_databases ;;
        7) return ;;
        *) log_warning "无效选项" ;;
    esac
    
    log_success "数据库配置完成"
}

# 安装MySQL
install_mysql() {
    log_info "安装MySQL 8.0..."
    
    # 安装MySQL
    apt-get update >/dev/null 2>&1
    apt-get install -y mysql-server
    
    # 启动MySQL
    systemctl enable mysql >/dev/null 2>&1
    systemctl start mysql
    
    log_success "MySQL安装完成"
    
    # 安全配置
    echo ""
    read -p "是否进行安全配置? (y/n): " secure_mysql
    if [[ "$secure_mysql" == "y" ]]; then
        log_info "开始MySQL安全配置..."
        
        read -sp "设置root密码: " mysql_root_pass
        echo ""
        
        # 设置root密码并配置安全选项
        mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_root_pass}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
        
        log_success "MySQL安全配置完成"
        
        # 保存密码
        echo "MySQL root密码: $mysql_root_pass" >> /root/vps_setup_info.txt
        chmod 600 /root/vps_setup_info.txt
    fi
    
    # 创建数据库
    echo ""
    read -p "是否创建新数据库? (y/n): " create_db
    if [[ "$create_db" == "y" ]]; then
        read -p "数据库名称: " db_name
        read -p "数据库用户: " db_user
        read -sp "用户密码: " db_pass
        echo ""
        
        mysql -u root -p"${mysql_root_pass}" <<EOF
CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
EOF
        
        log_success "数据库创建完成: $db_name"
        echo "数据库: $db_name, 用户: $db_user, 密码: $db_pass" >> /root/vps_setup_info.txt
    fi
    
    echo ""
    echo -e "${YELLOW}MySQL信息:${NC}"
    echo "版本: $(mysql --version)"
    echo "状态: $(systemctl is-active mysql)"
    echo "配置文件: /etc/mysql/mysql.conf.d/mysqld.cnf"
}

# 安装MariaDB
install_mariadb() {
    log_info "安装MariaDB..."
    
    apt-get update >/dev/null 2>&1
    apt-get install -y mariadb-server mariadb-client
    
    systemctl enable mariadb >/dev/null 2>&1
    systemctl start mariadb
    
    log_success "MariaDB安装完成"
    
    # 安全配置
    echo ""
    read -p "运行安全配置向导? (y/n): " run_secure
    if [[ "$run_secure" == "y" ]]; then
        mysql_secure_installation
    fi
    
    echo ""
    echo -e "${YELLOW}MariaDB信息:${NC}"
    echo "版本: $(mysql --version)"
    echo "状态: $(systemctl is-active mariadb)"
}

# 安装PostgreSQL
install_postgresql() {
    log_info "安装PostgreSQL..."
    
    # 添加PostgreSQL仓库
    apt-get install -y gnupg2 wget >/dev/null 2>&1
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    
    # 安装PostgreSQL
    apt-get update >/dev/null 2>&1
    apt-get install -y postgresql postgresql-contrib
    
    systemctl enable postgresql >/dev/null 2>&1
    systemctl start postgresql
    
    log_success "PostgreSQL安装完成"
    
    # 创建用户和数据库
    echo ""
    read -p "是否创建数据库和用户? (y/n): " create_pg_db
    if [[ "$create_pg_db" == "y" ]]; then
        read -p "数据库名称: " pg_dbname
        read -p "用户名称: " pg_user
        read -sp "用户密码: " pg_pass
        echo ""
        
        sudo -u postgres psql <<EOF
CREATE DATABASE ${pg_dbname};
CREATE USER ${pg_user} WITH ENCRYPTED PASSWORD '${pg_pass}';
GRANT ALL PRIVILEGES ON DATABASE ${pg_dbname} TO ${pg_user};
EOF
        
        log_success "PostgreSQL数据库创建完成"
        echo "PostgreSQL - 数据库: $pg_dbname, 用户: $pg_user, 密码: $pg_pass" >> /root/vps_setup_info.txt
    fi
    
    echo ""
    echo -e "${YELLOW}PostgreSQL信息:${NC}"
    echo "版本: $(sudo -u postgres psql --version)"
    echo "状态: $(systemctl is-active postgresql)"
    echo "配置: /etc/postgresql/*/main/postgresql.conf"
}

# 安装Redis
install_redis() {
    log_info "安装Redis..."
    
    apt-get update >/dev/null 2>&1
    apt-get install -y redis-server
    
    # 配置Redis
    sed -i 's/^supervised no/supervised systemd/' /etc/redis/redis.conf
    
    systemctl enable redis-server >/dev/null 2>&1
    systemctl restart redis-server
    
    log_success "Redis安装完成"
    
    # 安全配置
    echo ""
    read -p "是否设置Redis密码? (推荐) (y/n): " set_redis_pass
    if [[ "$set_redis_pass" == "y" ]]; then
        read -sp "设置Redis密码: " redis_pass
        echo ""
        
        # 设置密码
        sed -i "s/^# requirepass foobared/requirepass ${redis_pass}/" /etc/redis/redis.conf
        
        systemctl restart redis-server
        
        log_success "Redis密码设置完成"
        echo "Redis密码: $redis_pass" >> /root/vps_setup_info.txt
    fi
    
    echo ""
    echo -e "${YELLOW}Redis信息:${NC}"
    echo "版本: $(redis-server --version)"
    echo "状态: $(systemctl is-active redis-server)"
    echo "端口: 6379"
    echo "配置: /etc/redis/redis.conf"
}

# 安装MongoDB
install_mongodb() {
    log_info "安装MongoDB..."
    
    # 导入MongoDB GPG密钥
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
    
    # 添加MongoDB仓库
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    
    # 安装MongoDB
    apt-get update >/dev/null 2>&1
    apt-get install -y mongodb-org
    
    systemctl enable mongod >/dev/null 2>&1
    systemctl start mongod
    
    log_success "MongoDB安装完成"
    
    echo ""
    echo -e "${YELLOW}MongoDB信息:${NC}"
    echo "版本: $(mongod --version | head -1)"
    echo "状态: $(systemctl is-active mongod)"
    echo "端口: 27017"
    echo "配置: /etc/mongod.conf"
}

# 安装多个数据库
install_multiple_databases() {
    echo ""
    echo "选择要安装的数据库 (可多选):"
    
    read -p "安装MySQL? (y/n): " install_mysql_choice
    read -p "安装PostgreSQL? (y/n): " install_pg_choice
    read -p "安装Redis? (y/n): " install_redis_choice
    read -p "安装MongoDB? (y/n): " install_mongo_choice
    
    [[ "$install_mysql_choice" == "y" ]] && install_mysql
    [[ "$install_pg_choice" == "y" ]] && install_postgresql
    [[ "$install_redis_choice" == "y" ]] && install_redis
    [[ "$install_mongo_choice" == "y" ]] && install_mongodb
    
    log_success "数据库组合安装完成"
}

# 23. 开发环境管理
setup_dev_environment() {
    log_info "开始配置开发环境..."
    
    echo ""
    echo -e "${YELLOW}开发环境选项:${NC}"
    echo "1) Python环境 (pyenv + pip)"
    echo "2) Node.js环境 (nvm + npm)"
    echo "3) Go语言环境"
    echo "4) Java环境 (OpenJDK)"
    echo "5) 全栈环境 (Python + Node.js)"
    echo "6) 返回"
    read -p "请选择 [1-6]: " dev_choice
    
    case $dev_choice in
        1) setup_python_env ;;
        2) setup_nodejs_env ;;
        3) setup_go_env ;;
        4) setup_java_env ;;
        5) 
            setup_python_env
            setup_nodejs_env
            ;;
        6) return ;;
        *) log_warning "无效选项" ;;
    esac
    
    log_success "开发环境配置完成"
}

# 配置Python环境
setup_python_env() {
    log_info "配置Python开发环境..."
    
    # 安装依赖
    apt-get install -y build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev git >/dev/null 2>&1
    
    # 安装pyenv
    if [ ! -d "$HOME/.pyenv" ]; then
        log_info "安装pyenv..."
        curl https://pyenv.run | bash
        
        # 配置环境变量
        cat >> ~/.bashrc <<'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
        
        # 立即生效
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        
        log_success "pyenv安装完成"
    else
        log_info "pyenv已安装"
    fi
    
    # 安装Python版本
    echo ""
    read -p "是否安装Python? (y/n): " install_python
    if [[ "$install_python" == "y" ]]; then
        echo ""
        echo "常用Python版本:"
        echo "1) Python 3.11 (最新稳定版)"
        echo "2) Python 3.10"
        echo "3) Python 3.9"
        echo "4) 自定义版本"
        read -p "请选择 [1-4]: " py_version_choice
        
        case $py_version_choice in
            1) PY_VERSION="3.11.0" ;;
            2) PY_VERSION="3.10.0" ;;
            3) PY_VERSION="3.9.0" ;;
            4) read -p "输入Python版本 (如3.11.0): " PY_VERSION ;;
            *) PY_VERSION="3.11.0" ;;
        esac
        
        log_info "安装Python $PY_VERSION..."
        $HOME/.pyenv/bin/pyenv install $PY_VERSION
        $HOME/.pyenv/bin/pyenv global $PY_VERSION
        
        log_success "Python $PY_VERSION 安装完成"
    fi
    
    # 安装常用包
    echo ""
    read -p "是否安装常用Python包? (y/n): " install_packages
    if [[ "$install_packages" == "y" ]]; then
        log_info "安装常用包..."
        $HOME/.pyenv/shims/pip install --upgrade pip
        $HOME/.pyenv/shims/pip install virtualenv pipenv poetry requests flask django fastapi
        log_success "常用包安装完成"
    fi
    
    echo ""
    echo -e "${YELLOW}Python环境信息:${NC}"
    echo "pyenv版本: $($HOME/.pyenv/bin/pyenv --version 2>/dev/null || echo '需要重新登录')"
    echo "Python版本: $($HOME/.pyenv/shims/python --version 2>/dev/null || echo '需要重新登录')"
    echo ""
    echo -e "${CYAN}使用方法:${NC}"
    echo "  pyenv install 3.11.0  - 安装Python版本"
    echo "  pyenv global 3.11.0   - 设置全局版本"
    echo "  pyenv versions        - 查看已安装版本"
}

# 配置Node.js环境
setup_nodejs_env() {
    log_info "配置Node.js开发环境..."
    
    # 安装nvm
    if [ ! -d "$HOME/.nvm" ]; then
        log_info "安装nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # 配置环境变量
        cat >> ~/.bashrc <<'EOF'

# nvm configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
        
        # 立即生效
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        log_success "nvm安装完成"
    else
        log_info "nvm已安装"
    fi
    
    # 安装Node.js
    echo ""
    read -p "是否安装Node.js? (y/n): " install_node
    if [[ "$install_node" == "y" ]]; then
        echo ""
        echo "Node.js版本选择:"
        echo "1) Node.js 20 LTS (推荐)"
        echo "2) Node.js 18 LTS"
        echo "3) Node.js 最新版"
        echo "4) 自定义版本"
        read -p "请选择 [1-4]: " node_version_choice
        
        # 加载nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        case $node_version_choice in
            1) 
                log_info "安装Node.js 20 LTS..."
                nvm install 20
                nvm use 20
                nvm alias default 20
                ;;
            2) 
                log_info "安装Node.js 18 LTS..."
                nvm install 18
                nvm use 18
                nvm alias default 18
                ;;
            3) 
                log_info "安装最新版Node.js..."
                nvm install node
                nvm use node
                nvm alias default node
                ;;
            4) 
                read -p "输入Node.js版本 (如18.17.0): " NODE_VERSION
                nvm install $NODE_VERSION
                nvm use $NODE_VERSION
                nvm alias default $NODE_VERSION
                ;;
        esac
        
        log_success "Node.js安装完成"
    fi
    
    # 配置npm镜像
    echo ""
    read -p "是否配置npm淘宝镜像? (国内推荐) (y/n): " set_npm_mirror
    if [[ "$set_npm_mirror" == "y" ]]; then
        npm config set registry https://registry.npmmirror.com
        log_success "npm镜像配置完成"
    fi
    
    # 安装常用全局包
    echo ""
    read -p "是否安装常用全局包? (y/n): " install_npm_packages
    if [[ "$install_npm_packages" == "y" ]]; then
        log_info "安装常用包..."
        npm install -g yarn pnpm pm2 typescript ts-node nodemon
        log_success "常用包安装完成"
    fi
    
    echo ""
    echo -e "${YELLOW}Node.js环境信息:${NC}"
    echo "nvm版本: $(nvm --version 2>/dev/null || echo '需要重新登录')"
    echo "Node.js版本: $(node --version 2>/dev/null || echo '需要重新登录')"
    echo "npm版本: $(npm --version 2>/dev/null || echo '需要重新登录')"
    echo ""
    echo -e "${CYAN}使用方法:${NC}"
    echo "  nvm install 20    - 安装Node.js 20"
    echo "  nvm use 20        - 使用Node.js 20"
    echo "  nvm ls            - 查看已安装版本"
}

# 配置Go环境
setup_go_env() {
    log_info "配置Go语言环境..."
    
    # 获取最新版本
    GO_VERSION="1.21.0"
    
    echo ""
    read -p "安装Go $GO_VERSION? (y/n): " install_go
    if [[ "$install_go" != "y" ]]; then
        return
    fi
    
    # 下载Go
    log_info "下载Go $GO_VERSION..."
    cd /tmp
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
    
    # 安装Go
    rm -rf /usr/local/go
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    
    # 配置环境变量
    cat >> ~/.bashrc <<'EOF'

# Go configuration
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
    
    # 立即生效
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go
    
    log_success "Go安装完成"
    
    # 配置国内代理
    echo ""
    read -p "是否配置Go国内代理? (y/n): " set_go_proxy
    if [[ "$set_go_proxy" == "y" ]]; then
        go env -w GO111MODULE=on
        go env -w GOPROXY=https://goproxy.cn,direct
        log_success "Go代理配置完成"
    fi
    
    echo ""
    echo -e "${YELLOW}Go环境信息:${NC}"
    echo "Go版本: $(go version 2>/dev/null || echo '需要重新登录')"
    echo "GOPATH: $GOPATH"
}

# 配置Java环境
setup_java_env() {
    log_info "配置Java开发环境..."
    
    echo ""
    echo "Java版本选择:"
    echo "1) OpenJDK 17 (LTS, 推荐)"
    echo "2) OpenJDK 11 (LTS)"
    echo "3) OpenJDK 8 (LTS, 旧项目)"
    read -p "请选择 [1-3]: " java_version_choice
    
    case $java_version_choice in
        1)
            apt-get install -y openjdk-17-jdk openjdk-17-jre
            ;;
        2)
            apt-get install -y openjdk-11-jdk openjdk-11-jre
            ;;
        3)
            apt-get install -y openjdk-8-jdk openjdk-8-jre
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    log_success "Java安装完成"
    
    # 安装Maven
    echo ""
    read -p "是否安装Maven? (y/n): " install_maven
    if [[ "$install_maven" == "y" ]]; then
        apt-get install -y maven
        log_success "Maven安装完成"
    fi
    
    echo ""
    echo -e "${YELLOW}Java环境信息:${NC}"
    echo "Java版本: $(java -version 2>&1 | head -1)"
    echo "Maven版本: $(mvn -version 2>&1 | head -1 || echo '未安装')"
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
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║${NC}               ${BOLD}📋 请选择要执行的优化项目${NC}                    ${BOLD}${CYAN}║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${GREEN}╔═════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${GREEN}║${NC}  ${BOLD}${GREEN}⚡ 一键优化${NC}                                                    ${GREEN}║${NC}"
        echo -e "  ${GREEN}╚═════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "    ${BOLD}${WHITE} 0)${NC}  ${CYAN}🚀 执行全部优化${NC} ${GRAY}(推荐新手，一键完成所有基础配置)${NC}"
        echo ""
        echo -e "  ${BLUE}╔═════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${BLUE}║${NC}  ${BOLD}${BLUE}🔧 基础优化 (功能 1-9)${NC}                                        ${BLUE}║${NC}"
        echo -e "  ${BLUE}╚═════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "    ${BOLD}${WHITE} 1)${NC}  📦 换源加速            ${BOLD}${WHITE} 6)${NC}  🌍 系统语言配置"
        echo -e "    ${BOLD}${WHITE} 2)${NC}  👤 账户安全配置        ${BOLD}${WHITE} 7)${NC}  🕐 时间同步配置"
        echo -e "    ${BOLD}${WHITE} 3)${NC}  🔐 SSH安全加固         ${BOLD}${WHITE} 8)${NC}  🛡️  安全加固 (Fail2Ban)"
        echo -e "    ${BOLD}${WHITE} 4)${NC}  🔥 防火墙配置          ${BOLD}${WHITE} 9)${NC}  🧹 系统清理"
        echo -e "    ${BOLD}${WHITE} 5)${NC}  ⚙️  系统性能优化"
        echo ""
        echo -e "  ${YELLOW}╔═════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${YELLOW}║${NC}  ${BOLD}${YELLOW}🌟 环境配置 (功能 10-20)${NC}                                      ${YELLOW}║${NC}"
        echo -e "  ${YELLOW}╚═════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "    ${BOLD}${WHITE}10)${NC}  🐳 Docker环境配置      ${BOLD}${WHITE}16)${NC}  ${RED}🚀 BBR V3 终极优化 ⭐${NC}"
        echo -e "    ${BOLD}${WHITE}11)${NC}  🌐 Nginx+SSL证书       ${BOLD}${WHITE}17)${NC}  ☁️  Cloudflare Tunnel"
        echo -e "    ${BOLD}${WHITE}12)${NC}  🛠️  安装常用工具       ${BOLD}${WHITE}18)${NC}  🔒 Cloudflare WARP"
        echo -e "    ${BOLD}${WHITE}13)${NC}  💾 配置自动备份        ${BOLD}${WHITE}19)${NC}  🌐 网络优化工具集"
        echo -e "    ${BOLD}${WHITE}14)${NC}  📊 系统监控告警        ${BOLD}${WHITE}20)${NC}  ${GREEN}📈 性能基准测试 ⭐${NC}"
        echo -e "    ${BOLD}${WHITE}15)${NC}  ⚡ SSH连接优化"
        echo ""
        echo -e "  ${PURPLE}╔═════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${PURPLE}║${NC}  ${BOLD}${PURPLE}🎯 高级功能 (功能 21-28)${NC}                                      ${PURPLE}║${NC}"
        echo -e "  ${PURPLE}╚═════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "    ${BOLD}${WHITE}21)${NC}  📧 邮件告警配置        ${BOLD}${WHITE}25)${NC}  💾 系统快照与恢复"
        echo -e "    ${BOLD}${WHITE}22)${NC}  🗄️  数据库一键部署     ${BOLD}${WHITE}26)${NC}  🛡️  入侵检测系统"
        echo -e "    ${BOLD}${WHITE}23)${NC}  🔧 开发环境管理        ${BOLD}${WHITE}27)${NC}  📊 流量监控"
        echo -e "    ${BOLD}${WHITE}24)${NC}  🌐 反向代理管理        ${BOLD}${WHITE}28)${NC}  📁 文件同步服务"
        echo ""
        echo -e "  ${GRAY}╔═════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${GRAY}║${NC}  ${BOLD}${WHITE}📚 其他选项${NC}                                                    ${GRAY}║${NC}"
        echo -e "  ${GRAY}╚═════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "    ${BOLD}${WHITE} e)${NC}  🌟 扩展功能菜单        ${BOLD}${WHITE} v)${NC}  ✅ 验证配置"
        echo -e "    ${BOLD}${WHITE} l)${NC}  🔍 日志分析            ${BOLD}${WHITE} q)${NC}  🚪 退出脚本"
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -n -e "${BOLD}${CYAN}➤${NC} 请输入选项编号: "
        read choice
        
        case $choice in
            0)
                clear
                echo ""
                echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${BOLD}${CYAN}║${NC}              ${GREEN}🚀 开始一键优化 VPS 服务器 🚀${NC}                 ${BOLD}${CYAN}║${NC}"
                echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
                echo ""
                
                # 统计总步骤数
                local total_steps=9
                local current_step=0
                
                # 基础优化 (8步)
                ((current_step++))
                show_step $current_step $total_steps "换源加速"
                show_progress $current_step $total_steps "换源优化..."
                optimize_sources
                
                ((current_step++))
                show_step $current_step $total_steps "账户安全配置"
                show_progress $current_step $total_steps "配置账户安全..."
                setup_security
                
                ((current_step++))
                show_step $current_step $total_steps "SSH安全加固"
                show_progress $current_step $total_steps "加固SSH安全..."
                harden_ssh
                
                ((current_step++))
                show_step $current_step $total_steps "防火墙配置"
                show_progress $current_step $total_steps "配置防火墙..."
                setup_firewall
                
                ((current_step++))
                show_step $current_step $total_steps "系统性能优化"
                show_progress $current_step $total_steps "优化系统性能..."
                optimize_performance
                
                ((current_step++))
                show_step $current_step $total_steps "系统语言配置"
                show_progress $current_step $total_steps "配置系统语言..."
                setup_locale
                
                ((current_step++))
                show_step $current_step $total_steps "时间同步配置"
                show_progress $current_step $total_steps "配置时间同步..."
                setup_time_sync
                
                ((current_step++))
                show_step $current_step $total_steps "安全加固"
                show_progress $current_step $total_steps "加固系统安全..."
                security_hardening
                
                ((current_step++))
                show_step $current_step $total_steps "系统清理"
                show_progress $current_step $total_steps "清理系统..."
                system_cleanup
                
                # 基础优化完成提示
                echo ""
                echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${BOLD}${GREEN}✓${NC} 基础优化已完成！${GREEN}(9/9)${NC}"
                echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                
                # 可选的高级配置
                log_info "是否继续配置环境? (可选功能)"
                echo ""
                
                read -p "配置Docker环境? (y/n): " do_docker
                if [[ "$do_docker" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 配置 Docker 环境..."
                    setup_docker
                fi
                
                read -p "配置Nginx? (y/n): " do_nginx
                if [[ "$do_nginx" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 配置 Nginx..."
                    setup_nginx
                fi
                
                read -p "安装常用工具? (y/n): " do_tools
                if [[ "$do_tools" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 安装常用工具..."
                    install_useful_tools
                fi
                
                read -p "配置自动备份? (y/n): " do_backup
                if [[ "$do_backup" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 配置自动备份..."
                    setup_backup
                fi
                
                read -p "配置系统监控? (y/n): " do_monitor
                if [[ "$do_monitor" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 配置系统监控..."
                    setup_monitoring
                fi
                
                read -p "优化SSH连接速度? (y/n): " do_ssh_speed
                if [[ "$do_ssh_speed" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 优化SSH连接速度..."
                    optimize_ssh_speed
                fi
                
                read -p "安装BBR V3终极优化? (y/n): " do_bbr_v3
                if [[ "$do_bbr_v3" == "y" ]]; then
                    echo ""
                    echo -e "${YELLOW}▶${NC} 安装BBR V3终极优化..."
                    install_bbr_v3
                fi
                
                echo ""
                echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${BOLD}${GREEN}✓ 所有优化已完成！${NC}"
                echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                
                verify_setup
                show_completion
                break
                ;;
            1) 
                show_step 1 1 "换源加速"
                optimize_sources 
                read -p "按回车继续..."
                ;;
            2) 
                show_step 1 1 "账户安全配置"
                setup_security 
                read -p "按回车继续..."
                ;;
            3) 
                show_step 1 1 "SSH安全加固"
                harden_ssh 
                read -p "按回车继续..."
                ;;
            4) 
                show_step 1 1 "防火墙配置"
                setup_firewall 
                read -p "按回车继续..."
                ;;
            5) 
                show_step 1 1 "系统性能优化"
                optimize_performance 
                read -p "按回车继续..."
                ;;
            6) 
                show_step 1 1 "系统语言配置"
                setup_locale 
                read -p "按回车继续..."
                ;;
            7) 
                show_step 1 1 "时间同步配置"
                setup_time_sync 
                read -p "按回车继续..."
                ;;
            8) 
                show_step 1 1 "安全加固"
                security_hardening 
                read -p "按回车继续..."
                ;;
            9) 
                show_step 1 1 "系统清理"
                system_cleanup 
                read -p "按回车继续..."
                ;;
            10) 
                show_step 1 1 "Docker环境配置"
                setup_docker 
                read -p "按回车继续..."
                ;;
            11) 
                show_step 1 1 "Nginx配置与SSL证书"
                setup_nginx 
                read -p "按回车继续..."
                ;;
            12) 
                show_step 1 1 "安装常用工具"
                install_useful_tools 
                read -p "按回车继续..."
                ;;
            13) 
                show_step 1 1 "配置自动备份"
                setup_backup 
                read -p "按回车继续..."
                ;;
            14) 
                show_step 1 1 "配置系统监控告警"
                setup_monitoring 
                read -p "按回车继续..."
                ;;
            15) 
                show_step 1 1 "优化SSH连接速度"
                optimize_ssh_speed 
                read -p "按回车继续..."
                ;;
            16) 
                show_step 1 1 "BBR V3 终极优化"
                install_bbr_v3 
                read -p "按回车继续..."
                ;;
            17) 
                show_step 1 1 "Cloudflare Tunnel配置"
                setup_cloudflare_tunnel 
                read -p "按回车继续..."
                ;;
            18) 
                show_step 1 1 "Cloudflare WARP配置"
                setup_cloudflare_warp 
                read -p "按回车继续..."
                ;;
            19) 
                show_step 1 1 "网络优化工具集"
                setup_network_optimization 
                read -p "按回车继续..."
                ;;
            20)
                show_step 1 1 "性能基准测试"
                performance_benchmark
                read -p "按回车继续..."
                ;;
            21)
                show_step 1 1 "邮件告警配置"
                setup_email_alerts
                read -p "按回车继续..."
                ;;
            22)
                show_step 1 1 "数据库一键部署"
                setup_database
                read -p "按回车继续..."
                ;;
            23)
                show_step 1 1 "开发环境管理"
                setup_dev_environment
                read -p "按回车继续..."
                ;;
            24)
                show_step 1 1 "反向代理管理"
                setup_reverse_proxy
                read -p "按回车继续..."
                ;;
            25)
                show_step 1 1 "系统快照与恢复"
                source "$(dirname "$0")/vps_extend_functions.sh"
                setup_system_snapshot
                read -p "按回车继续..."
                ;;
            26)
                show_step 1 1 "入侵检测系统"
                source "$(dirname "$0")/vps_extend_functions.sh"
                setup_intrusion_detection
                read -p "按回车继续..."
                ;;
            27)
                show_step 1 1 "流量监控"
                source "$(dirname "$0")/vps_extend_functions.sh"
                setup_traffic_monitoring
                read -p "按回车继续..."
                ;;
            28)
                show_step 1 1 "文件同步服务"
                source "$(dirname "$0")/vps_extend_functions.sh"
                setup_file_sync
                read -p "按回车继续..."
                ;;
            e|E)
                # 扩展功能菜单
                source "$(dirname "$0")/vps_extend_functions.sh"
                show_extend_menu
                ;;
            l|L)
                # 日志分析
                source "$(dirname "$0")/vps_extend_functions.sh"
                setup_log_analysis
                read -p "按回车继续..."
                ;;
            v|V) 
                show_step 1 1 "验证配置"
                verify_setup 
                read -p "按回车继续..." 
                ;;
            q|Q) 
                echo ""
                log_info "感谢使用 VPS 优化脚本！👋"
                echo ""
                exit 0
                ;;
            *)
                log_error "无效选项，请重新选择"
                sleep 2
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
