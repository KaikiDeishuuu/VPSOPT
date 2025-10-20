#!/bin/bash

################################################################################
# VPS服务器优化脚本 - ARM64 Debian 12 专用版
# 功能：一键完成ARM64 VPS初始化配置和安全加固
# 作者：Kaiki
# 日期：2025-10-20
# 支持：ARM64 (aarch64) + Debian 12 (Bookworm)
# 使用方法：chmod +x vps_optimize_arm64.sh && sudo ./vps_optimize_arm64.sh
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

# 显示标题
show_header() {
    clear
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}      ${BOLD}${CYAN}🚀 VPS 优化脚本 v2.1 - ARM64 专用版 🚀${NC}          ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}     ${YELLOW}专为 ARM64 Debian 12 (Bookworm) 优化${NC}               ${GREEN}║${NC}"
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

# 检测系统架构和版本
detect_system() {
    # 检测架构
    ARCH=$(uname -m)
    if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
        log_error "此脚本仅支持 ARM64/aarch64 架构"
        log_info "检测到架构: $ARCH"
        log_info "请使用通用版本: vps_optimize.sh"
        exit 1
    fi
    
    log_success "架构检测: $ARCH ✓"
    
    # 检测系统版本
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        CODENAME=$VERSION_CODENAME
        
        log_info "检测到系统: $PRETTY_NAME"
        
        # 检查是否为Debian 12
        if [[ "$OS" == "debian" && "$VERSION" == "12" ]]; then
            log_success "系统版本检测: Debian 12 (Bookworm) ✓"
        else
            log_warning "此脚本针对 Debian 12 优化，当前系统: $PRETTY_NAME"
            read -p "是否继续? (y/n): " continue_choice
            [[ "$continue_choice" != "y" ]] && exit 0
        fi
    else
        log_error "无法检测系统版本"
        exit 1
    fi
}

# 包含主脚本的所有函数（从vps_optimize.sh继承）
# 这里我们使用source命令加载主脚本的函数

# 检查主脚本是否存在
if [ -f "$(dirname "$0")/vps_optimize.sh" ]; then
    log_info "加载主脚本函数..."
    # 提取主脚本中的函数定义（排除main函数）
    source <(grep -A 9999 "^# 进度条函数" "$(dirname "$0")/vps_optimize.sh" | grep -B 9999 "^# 主函数" | head -n -2)
else
    log_warning "未找到主脚本，使用内置函数"
fi

# ARM64特定优化
arm64_specific_optimizations() {
    log_info "开始ARM64特定优化..."
    
    echo ""
    echo -e "${YELLOW}ARM64优化选项:${NC}"
    echo "1) 启用ARM64性能优化"
    echo "2) 配置温度监控（适用于树莓派等设备）"
    echo "3) 优化内存管理"
    echo "4) 全部配置"
    echo "5) 跳过"
    read -p "请选择 [1-5]: " arm_choice
    
    case $arm_choice in
        1)
            optimize_arm64_performance
            ;;
        2)
            setup_temperature_monitoring
            ;;
        3)
            optimize_arm64_memory
            ;;
        4)
            optimize_arm64_performance
            setup_temperature_monitoring
            optimize_arm64_memory
            ;;
        5)
            log_info "跳过ARM64特定优化"
            return
            ;;
        *)
            log_warning "无效选项"
            return
            ;;
    esac
    
    log_success "ARM64特定优化完成"
    sleep 2
}

# ARM64性能优化
optimize_arm64_performance() {
    log_info "配置ARM64性能优化..."
    
    # ARM64 CPU调度器优化
    cat >> /etc/sysctl.d/99-arm64-custom.conf <<EOF
# ARM64性能优化
kernel.sched_latency_ns = 6000000
kernel.sched_min_granularity_ns = 750000
kernel.sched_wakeup_granularity_ns = 1000000

# 大小核调度优化（适用于big.LITTLE架构）
kernel.sched_energy_aware = 1

# 内存性能
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.vfs_cache_pressure = 50
EOF
    
    sysctl --system >/dev/null 2>&1
    log_success "ARM64性能参数已优化"
}

# 温度监控
setup_temperature_monitoring() {
    log_info "配置温度监控..."
    
    # 安装监控工具
    apt-get install -y lm-sensors >/dev/null 2>&1
    
    # 创建温度监控脚本
    cat > /usr/local/bin/temp_monitor.sh <<'EOF'
#!/bin/bash

# 温度监控脚本
TEMP_THRESHOLD=75

# 获取CPU温度（树莓派和大多数ARM设备）
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP_C=$((TEMP / 1000))
    
    echo "CPU温度: ${TEMP_C}°C"
    
    if [ $TEMP_C -gt $TEMP_THRESHOLD ]; then
        echo "[警告] CPU温度过高: ${TEMP_C}°C"
    fi
else
    echo "无法读取温度信息"
fi

# 尝试使用sensors命令
if command -v sensors >/dev/null 2>&1; then
    echo ""
    sensors
fi
EOF
    
    chmod +x /usr/local/bin/temp_monitor.sh
    
    log_success "温度监控脚本已创建: /usr/local/bin/temp_monitor.sh"
    log_info "使用方法: /usr/local/bin/temp_monitor.sh"
}

# ARM64内存优化
optimize_arm64_memory() {
    log_info "配置ARM64内存优化..."
    
    # 获取总内存
    TOTAL_MEM=$(free -m | grep Mem: | awk '{print $2}')
    log_info "检测到总内存: ${TOTAL_MEM}MB"
    
    # 根据内存大小调整swap配置
    if [ $TOTAL_MEM -lt 2048 ]; then
        SWAPPINESS=10
        log_info "小内存设备，设置swappiness=10"
    else
        SWAPPINESS=3
        log_info "标准配置，设置swappiness=3"
    fi
    
    echo "vm.swappiness = $SWAPPINESS" >> /etc/sysctl.d/99-arm64-custom.conf
    sysctl -w vm.swappiness=$SWAPPINESS >/dev/null 2>&1
    
    log_success "内存优化已配置"
}

# Docker ARM64版本安装
setup_docker_arm64() {
    log_info "开始配置Docker环境 (ARM64版)..."
    
    echo ""
    read -p "是否安装Docker (ARM64版)? (y/n): " install_docker
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
    
    # 添加Docker GPG密钥
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # 添加Docker仓库（ARM64）
    echo \
      "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装Docker
    log_info "安装Docker Engine (ARM64)..."
    apt-get update >/dev/null 2>&1
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # 启动Docker
    systemctl enable docker >/dev/null 2>&1
    systemctl start docker
    
    log_success "Docker安装完成: $(docker --version)"
    
    # 配置Docker镜像加速
    echo ""
    read -p "是否配置Docker镜像加速? (推荐) (y/n): " docker_mirror
    if [[ "$docker_mirror" == "y" ]]; then
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
    }
}
EOF
        
        systemctl daemon-reload
        systemctl restart docker
        log_success "Docker镜像加速配置完成"
    fi
    
    # 测试Docker
    log_info "测试Docker安装..."
    if docker run --rm arm64v8/hello-world >/dev/null 2>&1; then
        log_success "Docker运行正常 (ARM64)"
    else
        log_warning "Docker测试失败，请检查配置"
    fi
    
    log_success "Docker环境配置完成"
    sleep 2
}

# 显示完成信息（ARM64版）
show_completion_arm64() {
    show_header
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              🎉 ARM64 优化完成 🎉                        ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}系统信息:${NC}"
    echo "  架构: $(uname -m)"
    echo "  内核: $(uname -r)"
    echo "  系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    
    # CPU温度
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP_C=$((TEMP / 1000))
        echo "  CPU温度: ${TEMP_C}°C"
    fi
    
    echo ""
    echo -e "${BLUE}ARM64特定工具:${NC}"
    echo "  - 温度监控: /usr/local/bin/temp_monitor.sh"
    
    if command -v docker >/dev/null 2>&1; then
        echo "  - Docker (ARM64): $(docker --version | cut -d' ' -f3 | tr -d ',')"
    fi
    
    echo ""
    echo -e "${YELLOW}重要提醒:${NC}"
    echo "  1. ARM64设备请注意散热"
    echo "  2. 定期检查温度: /usr/local/bin/temp_monitor.sh"
    echo "  3. 使用ARM64镜像: docker pull arm64v8/镜像名"
    
    echo ""
    read -p "按回车键退出..."
}

# 主菜单（精简版）
show_menu_arm64() {
    while true; do
        show_header
        echo -e "${BOLD}${CYAN}📋 ARM64 优化菜单：${NC}"
        echo ""
        echo -e "  ${BOLD}0${NC})  🚀 一键优化 (包含ARM64特定优化)"
        echo ""
        echo -e "  ${BOLD}1${NC})  📦 系统基础优化 (换源/安全/性能)"
        echo -e "  ${BOLD}2${NC})  🔧 ARM64特定优化 (性能/温度/内存)"
        echo -e "  ${BOLD}3${NC})  🐳 Docker环境 (ARM64版)"
        echo -e "  ${BOLD}4${NC})  ☁️  Cloudflare服务 (Tunnel/WARP)"
        echo -e "  ${BOLD}5${NC})  🌐 网络优化工具"
        echo ""
        echo -e "  ${BOLD}v${NC})  ✅ 验证配置"
        echo -e "  ${BOLD}q${NC})  🚪 退出脚本"
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -n -e "${BOLD}${CYAN}➤${NC} 请输入选项: "
        read choice
        
        case $choice in
            0)
                # 一键优化
                log_info "开始一键优化..."
                
                # 基础优化（简化版）
                optimize_sources 2>/dev/null || log_warning "换源跳过"
                setup_security 2>/dev/null || log_warning "安全配置跳过"
                harden_ssh 2>/dev/null || log_warning "SSH加固跳过"
                setup_firewall 2>/dev/null || log_warning "防火墙跳过"
                optimize_performance 2>/dev/null || log_warning "性能优化跳过"
                
                # ARM64特定优化
                arm64_specific_optimizations
                
                # 可选组件
                read -p "安装Docker (ARM64)? (y/n): " do_docker
                [[ "$do_docker" == "y" ]] && setup_docker_arm64
                
                show_completion_arm64
                break
                ;;
            1)
                log_info "请运行主脚本进行基础优化: ./vps_optimize.sh"
                read -p "按回车继续..."
                ;;
            2)
                arm64_specific_optimizations
                read -p "按回车继续..."
                ;;
            3)
                setup_docker_arm64
                read -p "按回车继续..."
                ;;
            4)
                echo ""
                read -p "配置Cloudflare Tunnel? (y/n): " do_cf
                [[ "$do_cf" == "y" ]] && setup_cloudflare_tunnel 2>/dev/null
                
                read -p "配置Cloudflare WARP? (y/n): " do_warp
                [[ "$do_warp" == "y" ]] && setup_cloudflare_warp 2>/dev/null
                
                read -p "按回车继续..."
                ;;
            5)
                setup_network_optimization 2>/dev/null
                read -p "按回车继续..."
                ;;
            v|V)
                # 验证配置
                log_info "系统架构: $(uname -m)"
                log_info "内核版本: $(uname -r)"
                
                if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
                    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
                    TEMP_C=$((TEMP / 1000))
                    log_info "CPU温度: ${TEMP_C}°C"
                fi
                
                command -v docker >/dev/null && log_success "Docker: 已安装 ($(docker --version | cut -d' ' -f3))"
                
                read -p "按回车继续..."
                ;;
            q|Q)
                echo ""
                log_info "感谢使用 ARM64 优化脚本！👋"
                echo ""
                exit 0
                ;;
            *)
                log_error "无效选项"
                sleep 2
                ;;
        esac
    done
}

# 主函数
main() {
    check_root
    detect_system
    
    echo ""
    echo -e "${YELLOW}ARM64 专用脚本功能说明:${NC}"
    echo "  ✅ 针对ARM64架构优化"
    echo "  ✅ Debian 12 (Bookworm) 专用"
    echo "  ✅ 支持树莓派、甲骨文ARM等设备"
    echo "  ✅ 包含温度监控和性能优化"
    echo ""
    read -p "按回车继续..."
    
    show_menu_arm64
}

# 执行主函数
main
