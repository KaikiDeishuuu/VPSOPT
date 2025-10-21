#!/bin/bash

################################################################################
# VPS优化脚本 - ARM64专用模块
# 专门针对ARM64架构的优化和配置
################################################################################

# 加载公共库
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# 加载配置
source "$(dirname "${BASH_SOURCE[0]}")/../config/default.conf"

# ==============================================================================
# ARM64架构检测和系统支持
# ==============================================================================

# 支持的ARM64架构变体
ARM64_ARCHITECTURES=(
    "aarch64"
    "arm64"
)

# 支持的ARM64系统
ARM64_SUPPORTED_SYSTEMS=(
    "debian:12:bookworm"
    "debian:11:bullseye"
    "ubuntu:22.04:jammy"
    "ubuntu:20.04:focal"
    "ubuntu:24.04:noble"
)

# ARM64设备类型检测
detect_arm64_device_type() {
    local model_info=""

    # 检测常见ARM64设备
    if [ -f /proc/device-tree/model ]; then
        model_info=$(tr -d '\0' < /proc/device-tree/model 2>/dev/null)
    elif [ -f /sys/firmware/devicetree/base/model ]; then
        model_info=$(tr -d '\0' < /sys/firmware/devicetree/base/model 2>/dev/null)
    fi

    # 基于型号信息判断设备类型
    case "$model_info" in
        *"Raspberry Pi"*)
            echo "raspberry_pi"
            ;;
        *"Orange Pi"*)
            echo "orange_pi"
            ;;
        *"NanoPi"*)
            echo "nanopi"
            ;;
        *"Khadas"*)
            echo "khadas"
            ;;
        *"Rockchip"*)
            echo "rockchip"
            ;;
        *"Amlogic"*)
            echo "amlogic"
            ;;
        *"Allwinner"*)
            echo "allwinner"
            ;;
        *"Oracle Cloud"*)
            echo "oracle_cloud"
            ;;
        *"AWS Graviton"*)
            echo "aws_graviton"
            ;;
        *"Google Cloud"*)
            echo "gcp"
            ;;
        *"Azure"*)
            echo "azure"
            ;;
        *)
            echo "generic_arm64"
            ;;
    esac
}

# 增强的ARM64架构检测
detect_arm64_architecture() {
    local arch=$(uname -m)
    local cpu_info=""

    # 检查是否为ARM64架构
    if [[ ! " ${ARM64_ARCHITECTURES[@]} " =~ " ${arch} " ]]; then
        log_error "此模块仅支持ARM64架构"
        log_info "检测到架构: $arch"
        return 1
    fi

    log_success "ARM64架构检测: $arch ✓"

    # 获取CPU详细信息
    if [ -f /proc/cpuinfo ]; then
        cpu_info=$(grep -E "model name|Hardware|CPU implementer" /proc/cpuinfo | head -3)
        log_info "CPU信息: $cpu_info"
    fi

    # 检测设备类型
    local device_type=$(detect_arm64_device_type)
    log_info "检测到设备类型: $device_type"

    # 保存设备信息
    save_config "ARM64_ARCH" "$arch"
    save_config "ARM64_DEVICE_TYPE" "$device_type"
    save_config "ARM64_CPU_INFO" "$cpu_info"

    return 0
}

# ARM64系统兼容性检查
check_arm64_system_compatibility() {
    local os_id="$OS"
    local os_version="$VERSION"
    local os_codename="$VERSION_CODENAME"

    local system_key="${os_id}:${os_version}:${os_codename}"

    # 检查是否在支持列表中
    local supported=false
    for supported_system in "${ARM64_SUPPORTED_SYSTEMS[@]}"; do
        if [[ "$system_key" == *"$supported_system"* ]]; then
            supported=true
            break
        fi
    done

    if [ "$supported" = true ]; then
        log_success "系统兼容性检查: $PRETTY_NAME ✓"
        return 0
    else
        log_warning "系统 $PRETTY_NAME 未经过充分测试"
        log_info "支持的系统: ${ARM64_SUPPORTED_SYSTEMS[*]}"

        if ! get_confirmation "是否继续? (可能存在兼容性问题)"; then
            return 1
        fi
    fi

    return 0
}

# ==============================================================================
# ARM64性能优化
# ==============================================================================

optimize_arm64_performance() {
    log_info "开始ARM64性能优化..."

    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    # 基础ARM64优化
    cat > /etc/sysctl.d/99-arm64-performance.conf <<EOF
# ARM64通用性能优化
kernel.sched_latency_ns = 6000000
kernel.sched_min_granularity_ns = 750000
kernel.sched_wakeup_granularity_ns = 1000000

# 大小核调度优化（适用于big.LITTLE架构）
kernel.sched_energy_aware = 1

# 内存性能优化
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.vfs_cache_pressure = 50
vm.swappiness = 10

# 网络优化
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.core.somaxconn = 4096
EOF

    # 设备特定优化
    case "$device_type" in
        raspberry_pi)
            optimize_raspberry_pi_performance
            ;;
        oracle_cloud)
            optimize_oracle_cloud_performance
            ;;
        aws_graviton)
            optimize_aws_graviton_performance
            ;;
        *)
            log_info "应用通用ARM64优化"
            ;;
    esac

    # 应用配置
    safe_exec "sysctl --system" "应用系统参数失败"

    log_success "ARM64性能优化完成"
}

# 树莓派特定优化
optimize_raspberry_pi_performance() {
    log_info "应用树莓派特定优化..."

    # 树莓派GPU内存分配
    if [ -f /boot/config.txt ]; then
        backup_file "/boot/config.txt"

        # 增加GPU内存（如果未设置）
        if ! grep -q "^gpu_mem" /boot/config.txt; then
            echo "gpu_mem=128" >> /boot/config.txt
        fi

        # 启用USB启动（如果适用）
        if ! grep -q "^program_usb_boot_mode" /boot/config.txt; then
            echo "# program_usb_boot_mode=1" >> /boot/config.txt
        fi
    fi

    # 树莓派特有的sysctl参数
    cat >> /etc/sysctl.d/99-arm64-performance.conf <<EOF

# 树莓派特定优化
vm.min_free_kbytes = 16384
kernel.panic = 10
EOF

    log_success "树莓派优化完成"
}

# Oracle Cloud ARM64优化
optimize_oracle_cloud_performance() {
    log_info "应用Oracle Cloud ARM64优化..."

    # Oracle特有的网络优化
    cat >> /etc/sysctl.d/99-arm64-performance.conf <<EOF

# Oracle Cloud网络优化
net.ipv4.tcp_congestion_control = bbr
net.core.netdev_max_backlog = 250000
EOF

    log_success "Oracle Cloud优化完成"
}

# AWS Graviton优化
optimize_aws_graviton_performance() {
    log_info "应用AWS Graviton优化..."

    # Graviton特有的性能参数
    cat >> /etc/sysctl.d/99-arm64-performance.conf <<EOF

# AWS Graviton优化
kernel.numa_balancing = 0
vm.zone_reclaim_mode = 0
EOF

    log_success "AWS Graviton优化完成"
}

# ==============================================================================
# ARM64温度监控和散热管理
# ==============================================================================

setup_arm64_temperature_monitoring() {
    log_info "配置ARM64温度监控..."

    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    # 安装温度监控工具
    install_arm64_temp_tools

    # 创建高级温度监控脚本
    create_advanced_temp_monitor

    # 配置温度告警
    setup_temperature_alerts "$device_type"

    # 设置定时监控
    setup_temp_monitoring_cron

    log_success "温度监控配置完成"
}

# 安装ARM64温度监控工具
install_arm64_temp_tools() {
    log_info "安装温度监控工具..."

    # 基础工具
    install_package "lm-sensors"
    install_package "bc"  # 用于浮点运算

    # 设备特定工具
    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    case "$device_type" in
        raspberry_pi)
            # 树莓派vcgencmd工具
            if ! command -v vcgencmd >/dev/null 2>&1; then
                log_warning "vcgencmd工具不可用，请确保安装了raspberrypi-userland包"
            fi
            ;;
    esac

    # 尝试检测传感器
    safe_exec "sensors-detect --auto" "传感器检测失败"
}

# 创建高级温度监控脚本
create_advanced_temp_monitor() {
    log_info "创建高级温度监控脚本..."

    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    cat > /usr/local/bin/arm64_temp_monitor.sh <<EOF
#!/bin/bash

# ARM64高级温度监控脚本
# 支持多种ARM64设备和传感器

# 配置参数
WARNING_TEMP=70
CRITICAL_TEMP=85
LOG_FILE="/var/log/arm64_temp.log"
DEVICE_TYPE="$device_type"

# 颜色输出
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_temp() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S') \$*" >> "\$LOG_FILE"
}

get_temperature_readings() {
    local readings=""

    case "\$DEVICE_TYPE" in
        raspberry_pi)
            # 树莓派温度读取
            if command -v vcgencmd >/dev/null 2>&1; then
                local cpu_temp=\$(vcgencmd measure_temp 2>/dev/null | cut -d'=' -f2 | sed 's/..\$//')
                readings="CPU: \${cpu_temp}°C"
            fi
            ;;
        *)
            # 通用thermal_zone读取
            local zone=0
            while [ -f "/sys/class/thermal/thermal_zone\$zone/temp" ]; do
                local temp_raw=\$(cat "/sys/class/thermal/thermal_zone\$zone/temp" 2>/dev/null)
                if [ -n "\$temp_raw" ] && [ "\$temp_raw" -gt 0 ]; then
                    local temp_c=\$((temp_raw / 1000))
                    local zone_type=\$(cat "/sys/class/thermal/thermal_zone\$zone/type" 2>/dev/null || echo "Zone\$zone")
                    readings="\${readings}\${readings:+, }\${zone_type}: \${temp_c}°C"
                fi
                ((zone++))
            done
            ;;
    esac

    # 如果没有读取到温度，尝试其他方法
    if [ -z "\$readings" ]; then
        # 尝试使用sensors命令
        if command -v sensors >/dev/null 2>&1; then
            readings=\$(sensors 2>/dev/null | grep -E "temp|Temp" | head -3 | tr '\n' ', ' | sed 's/,$//')
        fi
    fi

    echo "\$readings"
}

check_temperature_alerts() {
    local readings="\$1"

    # 解析温度值并检查告警
    echo "\$readings" | grep -oE "[0-9]+\.[0-9]+|[0-9]+" | while read -r temp; do
        # 转换为整数进行比较
        local temp_int=\${temp%.*}

        if [ "\$temp_int" -ge "\$CRITICAL_TEMP" ]; then
            echo -e "\${RED}[严重] 温度过高: \${temp}°C\${NC}"
            log_temp "CRITICAL: Temperature \${temp}°C exceeds critical threshold"
            return 1
        elif [ "\$temp_int" -ge "\$WARNING_TEMP" ]; then
            echo -e "\${YELLOW}[警告] 温度偏高: \${temp}°C\${NC}"
            log_temp "WARNING: Temperature \${temp}°C exceeds warning threshold"
        fi
    done

    return 0
}

show_temperature_info() {
    local readings="\$(get_temperature_readings)"

    if [ -n "\$readings" ]; then
        echo "📊 当前温度状态:"
        echo "   \$readings"

        if check_temperature_alerts "\$readings"; then
            echo -e "\${GREEN}✅ 温度正常\${NC}"
        fi
    else
        echo "❌ 无法读取温度信息"
        echo "   请检查传感器配置或设备兼容性"
    fi
}

# 主函数
main() {
    case "\${1:-show}" in
        show)
            show_temperature_info
            ;;
        log)
            log_temp "\${2:-Manual log entry}"
            ;;
        alert)
            local readings="\$(get_temperature_readings)"
            check_temperature_alerts "\$readings"
            ;;
        *)
            echo "用法: \$0 {show|log|alert}"
            echo "  show  - 显示当前温度"
            echo "  log   - 记录日志"
            echo "  alert - 检查温度告警"
            ;;
    esac
}

main "\$@"
EOF

    chmod +x /usr/local/bin/arm64_temp_monitor.sh

    log_success "高级温度监控脚本已创建"
}

# 配置温度告警
setup_temperature_alerts() {
    local device_type="$1"

    log_info "配置温度告警..."

    # 根据设备类型设置不同的温度阈值
    case "$device_type" in
        raspberry_pi)
            # 树莓派温度阈值
            save_config "TEMP_WARNING" "65"
            save_config "TEMP_CRITICAL" "80"
            ;;
        oracle_cloud|aws_graviton)
            # 云服务器通常有更好的散热
            save_config "TEMP_WARNING" "75"
            save_config "TEMP_CRITICAL" "90"
            ;;
        *)
            # 默认阈值
            save_config "TEMP_WARNING" "70"
            save_config "TEMP_CRITICAL" "85"
            ;;
    esac

    log_success "温度告警配置完成"
}

# 设置定时温度监控
setup_temp_monitoring_cron() {
    log_info "设置定时温度监控..."

    # 每5分钟检查一次温度
    local cron_job="*/5 * * * * /usr/local/bin/arm64_temp_monitor.sh alert >> /var/log/arm64_temp_monitor.log 2>&1"

    # 添加到crontab（避免重复）
    (crontab -l 2>/dev/null | grep -v "arm64_temp_monitor.sh"; echo "$cron_job") | crontab -

    log_success "定时温度监控已设置 (每5分钟)"
}

# ==============================================================================
# ARM64内存优化
# ==============================================================================

optimize_arm64_memory() {
    log_info "开始ARM64内存优化..."

    local total_mem=$(free -m | grep Mem: | awk '{print $2}')
    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    log_info "检测到总内存: ${total_mem}MB"

    # 根据内存大小和设备类型调整配置
    local swappiness=10
    local min_free_kbytes=16384

    if [ $total_mem -lt 1024 ]; then
        # 小内存设备（1GB以下）
        swappiness=5
        min_free_kbytes=8192
        log_info "小内存设备优化配置"
    elif [ $total_mem -lt 2048 ]; then
        # 中等内存设备（1-2GB）
        swappiness=10
        min_free_kbytes=16384
        log_info "中等内存设备优化配置"
    else
        # 大内存设备（2GB以上）
        swappiness=15
        min_free_kbytes=32768
        log_info "大内存设备优化配置"
    fi

    # 设备特定调整
    case "$device_type" in
        raspberry_pi)
            # 树莓派内存优化
            swappiness=1  # 树莓派建议较低的swappiness
            ;;
        oracle_cloud|aws_graviton)
            # 云服务器通常内存充足
            swappiness=20
            ;;
    esac

    # 应用内存优化配置
    cat > /etc/sysctl.d/99-arm64-memory.conf <<EOF
# ARM64内存优化配置
vm.swappiness = $swappiness
vm.min_free_kbytes = $min_free_kbytes
vm.vfs_cache_pressure = 50
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10

# ARM64特定内存参数
vm.page-cluster = 0
EOF

    # 应用配置
    safe_exec "sysctl --system" "应用内存参数失败"

    log_success "ARM64内存优化完成 (swappiness=$swappiness)"
}

# ==============================================================================
# ARM64 Docker配置
# ==============================================================================

setup_arm64_docker() {
    log_info "开始配置ARM64 Docker环境..."

    if ! get_confirmation "是否安装Docker (ARM64版)?"; then
        log_info "跳过Docker安装"
        return
    fi

    # 检查是否已安装
    if command -v docker >/dev/null 2>&1; then
        log_warning "Docker已安装: $(docker --version)"
        if ! get_confirmation "是否重新安装?"; then
            return
        fi
    fi

    # 安装Docker依赖
    install_arm64_docker_dependencies

    # 添加Docker仓库
    setup_arm64_docker_repo

    # 安装Docker
    install_arm64_docker_engine

    # 配置Docker
    configure_arm64_docker

    # 测试Docker
    test_arm64_docker

    log_success "ARM64 Docker配置完成"
}

# 安装ARM64 Docker依赖
install_arm64_docker_dependencies() {
    log_info "安装Docker依赖..."

    local deps=(
        "apt-transport-https"
        "ca-certificates"
        "curl"
        "gnupg"
        "lsb-release"
    )

    for dep in "${deps[@]}"; do
        install_package "$dep"
    done
}

# 设置ARM64 Docker仓库
setup_arm64_docker_repo() {
    log_info "配置Docker仓库..."

    # 创建keyrings目录
    mkdir -p /etc/apt/keyrings

    # 添加Docker GPG密钥
    safe_exec "curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" \
        "下载Docker GPG密钥失败"

    # 添加Docker仓库
    local codename=$(lsb_release -cs)
    echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${codename} stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 更新包索引
    safe_exec "apt-get update" "更新包索引失败"
}

# 安装ARM64 Docker引擎
install_arm64_docker_engine() {
    log_info "安装Docker Engine..."

    local packages=(
        "docker-ce"
        "docker-ce-cli"
        "containerd.io"
        "docker-buildx-plugin"
        "docker-compose-plugin"
    )

    safe_exec "apt-get install -y ${packages[*]}" "安装Docker失败"

    # 启动并启用Docker服务
    safe_service_enable "docker"
    safe_service_restart "docker"

    log_success "Docker Engine安装完成: $(docker --version)"
}

# 配置ARM64 Docker
configure_arm64_docker() {
    log_info "配置Docker..."

    # 创建Docker配置目录
    mkdir -p /etc/docker

    # 配置镜像加速
    if get_confirmation "是否配置Docker镜像加速?"; then
        cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com",
        "https://registry.docker-cn.com"
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

        safe_service_restart "docker"
        log_success "Docker镜像加速配置完成"
    fi

    # 添加用户到docker组
    if get_confirmation "是否将当前用户添加到docker组?"; then
        local current_user=$(whoami)
        if [ "$current_user" != "root" ]; then
            usermod -aG docker "$current_user"
            log_success "用户 $current_user 已添加到docker组"
            log_warning "需要重新登录才能生效"
        fi
    fi
}

# 测试ARM64 Docker
test_arm64_docker() {
    log_info "测试Docker安装..."

    # 等待Docker服务启动
    sleep 3

    # 测试Docker运行
    if safe_exec "docker run --rm --platform linux/arm64 hello-world" "Docker测试失败"; then
        log_success "Docker运行正常 (ARM64)"
    else
        log_warning "Docker测试失败，请检查配置"
    fi
}

# ==============================================================================
# ARM64电源管理
# ==============================================================================

setup_arm64_power_management() {
    log_info "配置ARM64电源管理..."

    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    # 启用CPU频率调节
    setup_arm64_cpu_scaling

    # 配置电源管理策略
    configure_arm64_power_policy "$device_type"

    # 设置休眠策略
    setup_arm64_suspend_policy

    log_success "ARM64电源管理配置完成"
}

# 设置ARM64 CPU频率调节
setup_arm64_cpu_scaling() {
    log_info "配置CPU频率调节..."

    # 安装cpufreq工具
    install_package "cpufrequtils"

    # 检查可用的调节器
    if [ -d "/sys/devices/system/cpu/cpu0/cpufreq" ]; then
        local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null | awk '{print $1}')

        if [ -n "$governor" ]; then
            # 设置为ondemand调节器（平衡性能和功耗）
            echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true

            # 为所有CPU核心应用
            for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
                if [ -f "$cpu/cpufreq/scaling_governor" ]; then
                    echo "ondemand" > "$cpu/cpufreq/scaling_governor" 2>/dev/null || true
                fi
            done

            log_success "CPU频率调节器设置为: ondemand"
        fi
    else
        log_warning "CPU频率调节器不可用"
    fi
}

# 配置ARM64电源策略
configure_arm64_power_policy() {
    local device_type="$1"

    case "$device_type" in
        raspberry_pi)
            # 树莓派电源优化
            if [ -f /boot/config.txt ]; then
                backup_file "/boot/config.txt"

                # 禁用HDMI（如果不需要）
                if ! grep -q "^hdmi_blanking" /boot/config.txt; then
                    echo "# 电源优化: 禁用HDMI空白" >> /boot/config.txt
                    echo "hdmi_blanking=1" >> /boot/config.txt
                fi

                # 设置以太网电源管理
                if ! grep -q "^smsc95xx.turbo_mode" /boot/config.txt; then
                    echo "# 电源优化: USB以太网节能" >> /boot/config.txt
                    echo "smsc95xx.turbo_mode=N" >> /boot/config.txt
                fi
            fi
            ;;
        *)
            log_info "应用通用电源策略"
            ;;
    esac
}

# 设置休眠策略
setup_arm64_suspend_policy() {
    log_info "配置休眠策略..."

    # 对于ARM64设备，通常不推荐休眠
    # 设置为freeze模式（最轻量的休眠）
    if [ -f /sys/power/state ]; then
        echo "freeze" > /sys/power/disk 2>/dev/null || true
    fi

    # 配置systemd电源管理
    mkdir -p /etc/systemd/sleep.conf.d
    cat > /etc/systemd/sleep.conf.d/arm64.conf <<EOF
[Sleep]
# ARM64设备使用freeze模式
SuspendMode=freeze
EOF

    log_success "休眠策略配置完成"
}

# ==============================================================================
# ARM64特定优化菜单
# ==============================================================================

show_arm64_optimization_menu() {
    while true; do
        show_header
        echo -e "${BOLD}${CYAN}🔧 ARM64 特定优化菜单${NC}"
        echo ""
        echo -e "${YELLOW}检测到设备类型: $(load_config "ARM64_DEVICE_TYPE" "generic_arm64")${NC}"
        echo ""

        echo -e "  ${BOLD}1${NC})  ⚡ ARM64性能优化 (CPU调度/内存/网络)"
        echo -e "  ${BOLD}2${NC})  🌡️  温度监控与告警 (多传感器支持)"
        echo -e "  ${BOLD}3${NC})  🧠 内存优化 (根据设备类型调整)"
        echo -e "  ${BOLD}4${NC})  🐳 Docker环境 (ARM64专用配置)"
        echo -e "  ${BOLD}5${NC})  🔋 电源管理 (CPU频率/休眠策略)"
        echo -e "  ${BOLD}6${NC})  🔧 设备特定优化 (根据设备类型)"
        echo -e "  ${BOLD}7${NC})  📊 运行状态监控"
        echo ""
        echo -e "  ${BOLD}0${NC})  🚀 一键ARM64优化 (推荐)"
        echo ""
        echo -e "  ${BOLD}q${NC})  🔙 返回主菜单"
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        local choice=$(get_menu_choice 7)

        case $choice in
            0)
                run_full_arm64_optimization
                break
                ;;
            1)
                optimize_arm64_performance
                ;;
            2)
                setup_arm64_temperature_monitoring
                ;;
            3)
                optimize_arm64_memory
                ;;
            4)
                setup_arm64_docker
                ;;
            5)
                setup_arm64_power_management
                ;;
            6)
                run_device_specific_optimization
                ;;
            7)
                show_arm64_status
                ;;
            q|Q)
                return
                ;;
        esac

        echo ""
        read -p "按回车键继续..."
    done
}

# 一键ARM64优化
run_full_arm64_optimization() {
    log_info "开始一键ARM64优化..."

    show_step 1 5 "性能优化"
    optimize_arm64_performance

    show_step 2 5 "温度监控"
    setup_arm64_temperature_monitoring

    show_step 3 5 "内存优化"
    optimize_arm64_memory

    show_step 4 5 "电源管理"
    setup_arm64_power_management

    show_step 5 5 "设备特定优化"
    run_device_specific_optimization

    show_arm64_completion
}

# 设备特定优化
run_device_specific_optimization() {
    local device_type=$(load_config "ARM64_DEVICE_TYPE" "generic_arm64")

    log_info "运行设备特定优化: $device_type"

    case "$device_type" in
        raspberry_pi)
            optimize_raspberry_pi_specific
            ;;
        oracle_cloud)
            optimize_oracle_cloud_specific
            ;;
        aws_graviton)
            optimize_aws_graviton_specific
            ;;
        *)
            log_info "通用ARM64设备，无特定优化"
            ;;
    esac
}

# 树莓派特定优化
optimize_raspberry_pi_specific() {
    log_info "应用树莓派特定优化..."

    # 启用I2C（如果需要）
    if [ -f /boot/config.txt ]; then
        if ! grep -q "^dtparam=i2c_arm" /boot/config.txt; then
            echo "dtparam=i2c_arm=on" >> /boot/config.txt
        fi
    fi

    # 优化USB电源
    if [ -f /boot/config.txt ]; then
        if ! grep -q "^max_usb_current" /boot/config.txt; then
            echo "max_usb_current=1" >> /boot/config.txt
        fi
    fi

    log_success "树莓派特定优化完成"
}

# Oracle Cloud特定优化
optimize_oracle_cloud_specific() {
    log_info "应用Oracle Cloud特定优化..."

    # Oracle Cloud网络优化
    cat >> /etc/sysctl.d/99-arm64-performance.conf <<EOF

# Oracle Cloud特定优化
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_base_mss = 1024
EOF

    safe_exec "sysctl --system" "应用Oracle Cloud优化失败"

    log_success "Oracle Cloud特定优化完成"
}

# AWS Graviton特定优化
optimize_aws_graviton_specific() {
    log_info "应用AWS Graviton特定优化..."

    # Graviton实例优化
    cat >> /etc/sysctl.d/99-arm64-performance.conf <<EOF

# AWS Graviton特定优化
kernel.sched_migration_cost_ns = 500000
kernel.sched_nr_migrate = 32
EOF

    safe_exec "sysctl --system" "应用AWS Graviton优化失败"

    log_success "AWS Graviton特定优化完成"
}

# 显示ARM64状态
show_arm64_status() {
    log_info "ARM64系统状态监控"

    echo ""
    echo -e "${YELLOW}系统信息:${NC}"
    echo "  架构: $(uname -m)"
    echo "  设备类型: $(load_config "ARM64_DEVICE_TYPE" "generic_arm64")"
    echo "  内核版本: $(uname -r)"
    echo "  系统负载: $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1,$2,$3}')"

    echo ""
    echo -e "${YELLOW}温度状态:${NC}"
    if [ -x /usr/local/bin/arm64_temp_monitor.sh ]; then
        /usr/local/bin/arm64_temp_monitor.sh show
    else
        echo "  温度监控未配置"
    fi

    echo ""
    echo -e "${YELLOW}内存状态:${NC}"
    echo "  $(free -h | grep Mem | awk '{print "总计: "$2", 已用: "$3", 可用: "$7}')"
    echo "  Swap使用: $(free -h | grep Swap | awk '{print $3"/"$2}')"

    echo ""
    echo -e "${YELLOW}服务状态:${NC}"
    local services=("docker" "cron")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo -e "  $service: ${GREEN}运行中${NC}"
        else
            echo -e "  $service: ${GRAY}未运行${NC}"
        fi
    done

    echo ""
    echo -e "${YELLOW}ARM64特定配置:${NC}"
    local configs=(
        "/etc/sysctl.d/99-arm64-performance.conf"
        "/etc/sysctl.d/99-arm64-memory.conf"
        "/usr/local/bin/arm64_temp_monitor.sh"
    )

    for config in "${configs[@]}"; do
        if [ -f "$config" ]; then
            echo -e "  $(basename "$config"): ${GREEN}已配置${NC}"
        else
            echo -e "  $(basename "$config"): ${GRAY}未配置${NC}"
        fi
    done
}

# ARM64优化完成信息
show_arm64_completion() {
    show_header
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              🎉 ARM64 优化完成 🎉                        ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${YELLOW}ARM64优化摘要:${NC}"
    echo "  ✅ ARM64性能优化 (CPU调度/内存/网络)"
    echo "  ✅ 温度监控与告警系统"
    echo "  ✅ 内存优化 (根据设备类型调整)"
    echo "  ✅ 电源管理 (CPU频率/休眠策略)"
    echo "  ✅ 设备特定优化"

    echo ""
    echo -e "${BLUE}ARM64专用工具:${NC}"
    echo "  📊 温度监控: /usr/local/bin/arm64_temp_monitor.sh"
    echo "  🔍 状态查看: ./modules/arm64.sh status"

    echo ""
    echo -e "${CYAN}重要提醒:${NC}"
    echo "  1. ARM64设备请注意散热，定期检查温度"
    echo "  2. 不同设备类型可能有特定的优化配置"
    echo "  3. 建议重启系统以应用所有优化"

    echo ""
    read -p "按回车键退出..."
}

# ==============================================================================
# 主函数
# ==============================================================================

# ARM64模块主函数
arm64_main() {
    # 检测ARM64架构
    if ! detect_arm64_architecture; then
        return 1
    fi

    # 检查系统兼容性
    if ! check_arm64_system_compatibility; then
        return 1
    fi

    # 显示ARM64优化菜单
    show_arm64_optimization_menu
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    # 加载公共库
    if [ -f "$(dirname "$0")/../lib/common.sh" ]; then
        source "$(dirname "$0")/../lib/common.sh"
        source "$(dirname "$0")/../config/default.conf"
        arm64_main
    else
        echo "错误: 找不到公共库文件"
        exit 1
    fi
fi