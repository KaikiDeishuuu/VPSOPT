#!/bin/bash

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

# 显示菜单
show_menu() {
    show_header
    echo -e "${BOLD}${CYAN}📋 请选择要执行的优化项目：${NC}"
    echo ""
    echo -e "  ${GREEN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${GREEN}│${NC} ${BOLD}${GREEN}⚡ 一键优化${NC}                                            ${GREEN}│${NC}"
    echo -e "  ${GREEN}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "    ${BOLD}0${NC})  ${CYAN}🚀 执行全部优化${NC} ${GRAY}(推荐新手，一键搞定)${NC}"
    echo ""
    echo -e "  ${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${BLUE}│${NC} ${BOLD}${BLUE}🔧 基础优化${NC}                                            ${BLUE}│${NC}"
    echo -e "  ${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "    ${BOLD}1${NC})  📦 换源加速                 ${BOLD}5${NC})  ⚙️  系统性能优化"
    echo -e "    ${BOLD}2${NC})  👤 账户安全配置             ${BOLD}6${NC})  🕐 时间同步配置"
    echo -e "    ${BOLD}3${NC})  🔐 SSH安全加固              ${BOLD}7${NC})  🛡️  安全加固 (Fail2Ban)"
    echo -e "    ${BOLD}4${NC})  🔥 防火墙配置                ${BOLD}8${NC})  🧹 系统清理"
    echo ""
    echo -e "  ${YELLOW}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}│${NC} ${BOLD}${YELLOW}🌟 环境配置${NC}                                            ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "    ${BOLD}9${NC})  🐳 Docker环境配置            ${BOLD}13${NC}) 📊 配置系统监控告警"
    echo -e "    ${BOLD}10${NC}) 🌐 Nginx配置与SSL证书        ${BOLD}14${NC}) ⚡ 优化SSH连接速度"
    echo -e "    ${BOLD}11${NC}) 🛠️  安装常用工具             ${BOLD}15${NC}) ${RED}${BOLD}🚀 BBR V3 终极优化 ⭐${NC}"
    echo -e "    ${BOLD}12${NC}) 💾 配置自动备份"
    echo ""
    echo -e "  ${PURPLE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${PURPLE}│${NC} ${BOLD}${PURPLE}📚 其他选项${NC}                                            ${PURPLE}│${NC}"
    echo -e "  ${PURPLE}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "    ${BOLD}v${NC})  ✅ 验证配置                  ${BOLD}q${NC})  🚪 退出脚本"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n -e "${BOLD}${CYAN}➤${NC} 请输入选项: "
}

# 显示菜单并等待
show_menu
read choice
echo ""
echo -e "${GREEN}✨ 您选择了选项: ${BOLD}$choice${NC}"
echo ""
echo -e "${YELLOW}提示: 这只是菜单预览，实际功能请运行主脚本 vps_optimize.sh${NC}"
echo ""
