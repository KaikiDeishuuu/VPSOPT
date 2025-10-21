#!/bin/bash

################################################################################
# VPS服务器优化脚本 v2.2 - 重构版
# 功能：一键完成VPS初始化配置和安全加固
# 作者：Kaiki
# 版本：2.2
# 架构：模块化设计，支持x86_64和ARM64
################################################################################

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载公共库
source "${SCRIPT_DIR}/lib/common.sh"

# 加载配置
source "${SCRIPT_DIR}/config/default.conf"

# 加载模块
source "${SCRIPT_DIR}/modules/base.sh"

# 检测架构并加载相应模块
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    if [ -f "${SCRIPT_DIR}/modules/arm64.sh" ]; then
        source "${SCRIPT_DIR}/modules/arm64.sh"
        log_info "已加载 ARM64 专用模块"
    else
        log_warning "ARM64 模块不存在，使用通用模块"
    fi
fi

# ==============================================================================
# 主菜单
# ==============================================================================

show_main_menu() {
    while true; do
        show_header
        echo -e "${BOLD}${CYAN}主菜单：${NC}"
        echo ""
        echo -e "  ${BOLD}0${NC})  🚀 一键优化 (包含所有基础功能)"
        echo ""
        echo -e "  ${BOLD}1${NC})  📦 系统基础优化 (换源/安全/性能)"
        echo -e "  ${BOLD}2${NC})  🔧 系统语言配置 (Locale/时区/NTP)"
        echo -e "  ${BOLD}3${NC})  🛡️  安全加固 (SSH/Fail2Ban/防火墙)"
        echo -e "  ${BOLD}4${NC})  🧹 系统清理"
        echo ""

        # ARM64特定选项
        if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
            echo -e "  ${BOLD}5${NC})  🔧 ARM64 专用优化 (性能/温度/电源)"
            echo ""
        fi

        echo -e "  ${BOLD}v${NC})  ✅ 验证配置"
        echo -e "  ${BOLD}q${NC})  🚪 退出脚本"
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -n -e "${BOLD}${CYAN}➤${NC} 请输入选项: "
        read choice

        case $choice in
            0)
                run_full_optimization
                break
                ;;
            1)
                run_basic_optimization
                read -p "按回车继续..."
                ;;
            2)
                run_locale_time_setup
                read -p "按回车继续..."
                ;;
            3)
                run_security_hardening
                read -p "按回车继续..."
                ;;
            4)
                system_cleanup
                read -p "按回车继续..."
                ;;
            5)
                if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
                    run_arm64_optimization
                    read -p "按回车继续..."
                else
                    log_error "无效选项，请重新选择"
                    sleep 2
                fi
                ;;
            v|V)
                validate_configuration
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

# ==============================================================================
# 优化流程
# ==============================================================================

run_full_optimization() {
    log_info "开始一键优化..."

    show_step 1 7 "系统基础优化"
    run_basic_optimization

    show_step 2 7 "语言和时间配置"
    run_locale_time_setup

    show_step 3 7 "安全加固"
    run_security_hardening

    show_step 4 7 "系统清理"
    system_cleanup

    # ARM64特定优化
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        show_step 5 7 "ARM64专用优化"
        run_arm64_optimization
        show_step 6 7 "配置验证"
        validate_configuration
        show_step 7 7 "优化完成"
    else
        show_step 5 6 "配置验证"
        validate_configuration
        show_step 6 6 "优化完成"
    fi

    show_completion
}

run_basic_optimization() {
    optimize_sources
    setup_security
    harden_ssh
    setup_firewall
    optimize_performance
}

run_locale_time_setup() {
    setup_locale
    setup_time_sync
}

run_security_hardening() {
    security_hardening
}

run_arm64_optimization() {
    if type arm64_main >/dev/null 2>&1; then
        arm64_main
    else
        log_warning "ARM64模块未正确加载，使用通用优化"
    fi
}

# ==============================================================================
# 配置验证
# ==============================================================================

validate_configuration() {
    log_info "开始验证配置..."

    echo ""
    echo -e "${YELLOW}系统信息:${NC}"
    echo "  架构: $(uname -m)"
    echo "  内核: $(uname -r)"
    echo "  系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "  Uptime: $(uptime -p)"

    echo ""
    echo -e "${YELLOW}网络配置:${NC}"
    echo "  主机名: $(hostname)"
    echo "  IP地址: $(hostname -I | awk '{print $1}')"
    echo "  默认网关: $(ip route | grep default | awk '{print $3}')"

    echo ""
    echo -e "${YELLOW}SSH配置:${NC}"
    local ssh_port=$(load_config "SSH_PORT" "22")
    echo "  SSH端口: $ssh_port"
    echo "  SSH状态: $(systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || echo '未知')"

    echo ""
    echo -e "${YELLOW}防火墙状态:${NC}"
    if systemctl is-active --quiet nftables 2>/dev/null; then
        echo "  防火墙: nftables (活跃)"
    elif systemctl is-active --quiet ufw 2>/dev/null; then
        echo "  防火墙: ufw (活跃)"
    elif command -v iptables >/dev/null 2>&1 && iptables -L >/dev/null 2>&1; then
        echo "  防火墙: iptables (活跃)"
    else
        echo "  防火墙: 未配置"
    fi

    echo ""
    echo -e "${YELLOW}时间同步:${NC}"
    echo "  当前时间: $(date)"
    echo "  时区: $(timedatectl | grep "Time zone" | cut -d: -f2 | xargs)"
    echo "  NTP状态: $(timedatectl | grep "NTP service" | cut -d: -f2 | xargs)"

    echo ""
    echo -e "${YELLOW}系统资源:${NC}"
    echo "  CPU使用率: $(top -bn1 | grep "Cpu(s)" | awk '{print $2"%"}')"
    echo "  内存使用: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo "  磁盘使用: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5" used)"}')"

    # ARM64特定信息
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        echo ""
        echo -e "${YELLOW}ARM64状态:${NC}"
        if [ -x /usr/local/bin/arm64_temp_monitor.sh ]; then
            echo "  温度监控: 已配置"
            # 显示当前温度
            /usr/local/bin/arm64_temp_monitor.sh show 2>/dev/null | head -3 | while read line; do
                echo "  $line"
            done
        else
            echo "  温度监控: 未配置"
        fi
        echo "  设备类型: $(load_config "ARM64_DEVICE_TYPE" "generic_arm64")"
    fi

    echo ""
    echo -e "${YELLOW}服务状态:${NC}"
    for service in "${MONITOR_SERVICES[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "  $service: ✓ 运行中"
        elif systemctl list-unit-files | grep -q "^${service}.service"; then
            echo "  $service: ⚠ 已安装但未运行"
        else
            echo "  $service: ✗ 未安装"
        fi
    done

    log_success "配置验证完成"
}

# ==============================================================================
# 完成信息
# ==============================================================================

show_completion() {
    show_header
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              🎉 VPS 优化完成 🎉                        ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${YELLOW}优化摘要:${NC}"
    echo "  ✅ 系统源已优化"
    echo "  ✅ SSH服务已加固"
    echo "  ✅ 防火墙已配置"
    echo "  ✅ 系统性能已优化"
    echo "  ✅ 语言和时区已配置"
    echo "  ✅ 安全加固已完成"
    echo "  ✅ 系统已清理"

    # ARM64特定摘要
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        echo "  ✅ ARM64性能优化"
        echo "  ✅ 温度监控已配置"
        echo "  ✅ 电源管理已优化"
    fi

    echo ""
    echo -e "${BLUE}重要提醒:${NC}"
    echo "  1. 请重新连接SSH (如果修改了端口)"
    echo "  2. 建议重启系统以应用所有更改"
    echo "  3. 定期更新系统和检查日志"
    echo "  4. 备份重要数据"

    # ARM64特定提醒
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        echo "  5. ARM64设备请注意散热和温度监控"
        echo "  6. 检查温度监控日志: /var/log/arm64_temp.log"
    fi

    echo ""
    echo -e "${CYAN}获取帮助:${NC}"
    echo "  📖 文档: ${SCRIPT_DIR}/docs/"
    echo "  🐛 问题反馈: 请查看日志文件"
    echo "  🔄 更新: 定期检查项目更新"

    # ARM64特定工具
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        echo "  🔧 ARM64工具: /usr/local/bin/arm64_temp_monitor.sh"
    fi

    echo ""
    read -p "按回车键退出..."
}

# ==============================================================================
# 主函数
# ==============================================================================

main() {
    # 初始化环境
    init_environment

    # 检查权限和系统
    check_root
    detect_system
    detect_architecture

    # 显示欢迎信息
    echo ""
    echo -e "${YELLOW}VPS 优化脚本 v${SCRIPT_VERSION}${NC}"
    echo -e "${GRAY}支持架构: x86_64, ARM64${NC}"
    echo -e "${GRAY}当前架构: $ARCH${NC}"
    echo ""

    # 检查依赖
    if ! command -v curl >/dev/null 2>&1; then
        log_warning "建议安装 curl 以获得更好的体验"
    fi

    read -p "按回车键继续..."

    # 显示主菜单
    show_main_menu
}

# 执行主函数
main "$@"