#!/bin/bash

################################################################################
# VPS优化脚本 - 公共库文件
# 包含所有脚本共享的函数、变量和配置
# 作者：Kaiki
# 版本：2.2
################################################################################

# ==============================================================================
# 颜色定义
# ==============================================================================

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export GRAY='\033[0;90m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# ==============================================================================
# 日志函数
# ==============================================================================

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

# ==============================================================================
# 进度条和显示函数
# ==============================================================================

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

show_header() {
    clear
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}         ${BOLD}${CYAN}🚀 VPS 服务器优化脚本 v2.2 🚀${NC}                  ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}     ${YELLOW}让你的服务器从裸机变成性能强劲的战斗机${NC}             ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}            ${GRAY}作者: Kaiki  |  开源项目${NC}                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==============================================================================
# 系统检测和权限检查
# ==============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行，请使用 sudo 或以root用户身份运行"
        exit 1
    fi
}

detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        export OS=$ID
        export VERSION=$VERSION_ID
        export PRETTY_NAME=$PRETTY_NAME
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

detect_architecture() {
    export ARCH=$(uname -m)
    log_info "检测到系统架构: $ARCH"
}

# ==============================================================================
# 错误处理和安全函数
# ==============================================================================

# 安全的命令执行（带错误检查）
safe_exec() {
    local cmd="$1"
    local error_msg="${2:-命令执行失败}"

    if ! eval "$cmd"; then
        log_error "$error_msg"
        return 1
    fi
    return 0
}

# 备份文件
backup_file() {
    local file="$1"
    local backup_suffix="${2:-$(date +%Y%m%d_%H%M%S)}"

    if [ -f "$file" ]; then
        local backup="${file}.backup.${backup_suffix}"
        cp "$file" "$backup"
        log_success "已备份: $backup"
        return 0
    else
        log_warning "文件不存在，跳过备份: $file"
        return 1
    fi
}

# 验证输入
validate_input() {
    local input="$1"
    local type="$2"  # ip, port, domain, path, user

    case "$type" in
        port)
            [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le 65535 ]
            ;;
        ip)
            [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
            ;;
        domain)
            [[ "$input" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        path)
            [ -e "$input" ]
            ;;
        user)
            [[ "$input" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]
            ;;
        *)
            [ -n "$input" ]
            ;;
    esac
}

# 检查网络连接
check_network() {
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        log_warning "网络连接异常，某些功能可能无法正常工作"
        return 1
    fi
    return 0
}

# 检查包是否已安装
is_package_installed() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# 安装包（带依赖检查）
install_package() {
    local package="$1"

    if is_package_installed "$package"; then
        log_info "包 $package 已安装，跳过"
        return 0
    fi

    log_info "安装包: $package"
    if ! apt-get install -y "$package" >/dev/null 2>&1; then
        log_error "安装包失败: $package"
        return 1
    fi

    log_success "包 $package 安装完成"
    return 0
}

# ==============================================================================
# 配置管理
# ==============================================================================

# 全局配置变量
export CONFIG_DIR="/etc/vps-optimize"
export LOG_DIR="/var/log/vps-optimize"
export BACKUP_DIR="/var/backups/vps-optimize"
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 创建必要的目录
create_directories() {
    mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$BACKUP_DIR"
    chmod 755 "$CONFIG_DIR" "$LOG_DIR"
    chmod 700 "$BACKUP_DIR"
}

# 保存配置
save_config() {
    local key="$1"
    local value="$2"
    local config_file="$CONFIG_DIR/settings.conf"

    # 创建配置目录
    create_directories

    # 保存配置
    if grep -q "^${key}=" "$config_file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$config_file"
    else
        echo "${key}=\"${value}\"" >> "$config_file"
    fi
}

# 读取配置
load_config() {
    local key="$1"
    local default="${2:-}"
    local config_file="$CONFIG_DIR/settings.conf"

    if [ -f "$config_file" ]; then
        local value=$(grep "^${key}=" "$config_file" | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//')
        echo "${value:-$default}"
    else
        echo "$default"
    fi
}

# ==============================================================================
# 服务管理
# ==============================================================================

# 安全的服务重启
safe_service_restart() {
    local service="$1"

    if systemctl is-active --quiet "$service" 2>/dev/null; then
        log_info "重启服务: $service"
        if systemctl restart "$service"; then
            log_success "服务 $service 重启成功"
            return 0
        else
            log_error "服务 $service 重启失败"
            return 1
        fi
    else
        log_info "启动服务: $service"
        if systemctl start "$service"; then
            log_success "服务 $service 启动成功"
            return 0
        else
            log_error "服务 $service 启动失败"
            return 1
        fi
    fi
}

# 安全的服务启用
safe_service_enable() {
    local service="$1"

    log_info "启用服务: $service"
    if systemctl enable "$service" >/dev/null 2>&1; then
        log_success "服务 $service 已启用"
        return 0
    else
        log_error "服务 $service 启用失败"
        return 1
    fi
}

# ==============================================================================
# 工具函数
# ==============================================================================

# 获取用户确认
get_confirmation() {
    local prompt="${1:-是否继续?}"
    local default="${2:-n}"

    read -p "$prompt (y/n): " choice
    choice="${choice:-$default}"

    [[ "$choice" =~ ^[Yy]$ ]]
}

# 显示菜单选择
show_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo ""
    echo -e "${BOLD}${CYAN}$title${NC}"
    echo ""

    for i in "${!options[@]}"; do
        echo -e "  ${BOLD}$((i+1))${NC}) ${options[$i]}"
    done

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 获取菜单选择
get_menu_choice() {
    local max_choice=$1
    local choice

    while true; do
        echo -n -e "${BOLD}${CYAN}➤${NC} 请输入选项 [1-$max_choice]: "
        read choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_choice" ]; then
            echo "$choice"
            return 0
        else
            log_error "无效选项，请输入 1-$max_choice"
        fi
    done
}

# ==============================================================================
# 初始化
# ==============================================================================

# 初始化环境
init_environment() {
    # 设置 PATH
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

    # 设置语言环境
    export LANG=${LANG:-en_US.UTF-8}
    export LC_ALL=${LC_ALL:-en_US.UTF-8}

    # 创建必要的目录
    create_directories

    # 检查网络
    check_network
}

# 清理函数
cleanup() {
    # 清理临时文件
    local temp_files=(
        "/tmp/vps-optimize-*"
        "/var/tmp/vps-optimize-*"
    )

    for pattern in "${temp_files[@]}"; do
        rm -f $pattern 2>/dev/null
    done
}

# 陷阱设置
trap cleanup EXIT

# ==============================================================================
# 导出所有函数（确保在子脚本中可用）
# ==============================================================================

# 导出所有定义的函数
export -f log_info
export -f log_success
export -f log_warning
export -f log_error
export -f show_progress
export -f run_with_progress
export -f show_step
export -f show_header
export -f check_root
export -f detect_system
export -f detect_architecture
export -f safe_exec
export -f backup_file
export -f validate_input
export -f check_network
export -f is_package_installed
export -f install_package
export -f create_directories
export -f save_config
export -f load_config
export -f safe_service_restart
export -f safe_service_enable
export -f get_confirmation
export -f show_menu
export -f get_menu_choice
export -f init_environment
export -f cleanup