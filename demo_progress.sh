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

# 动态加载动画
show_spinner() {
    local task_name=$1
    local duration=$2
    
    echo ""
    echo -e "${BOLD}${CYAN}▶${NC} 正在执行: ${YELLOW}${task_name}${NC}"
    echo ""
    
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    local elapsed=0
    
    while [ $elapsed -lt $duration ]; do
        echo -ne "\r${CYAN}${spinner[$i]}${NC} 处理中... ${GRAY}(${elapsed}s/${duration}s)${NC}  "
        i=$(( (i+1) % 10 ))
        sleep 0.1
        elapsed=$((elapsed + 1))
        if [ $((elapsed % 10)) -eq 0 ]; then
            elapsed=$((elapsed / 10))
        fi
    done
    
    echo -e "\r${GREEN}✓${NC} ${task_name} ${GREEN}完成${NC}                          "
}

# 演示开始
clear
echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}              ${GREEN}🚀 VPS 优化脚本进度条演示 🚀${NC}                 ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}这是一个进度条功能演示，展示优化过程中的视觉效果${NC}"
echo ""

# 演示1: 基本进度条
echo -e "${BOLD}${PURPLE}═══ 演示 1: 基本进度条 ═══${NC}"
echo ""
for i in {1..8}; do
    show_progress $i 8 "执行基础优化任务 $i/8"
    sleep 0.3
done

sleep 1

# 演示2: 步骤显示
echo -e "${BOLD}${PURPLE}═══ 演示 2: 步骤显示 + 进度条 ═══${NC}"

tasks=(
    "换源加速"
    "账户安全配置"
    "SSH安全加固"
    "防火墙配置"
    "系统性能优化"
)

total_steps=${#tasks[@]}

for i in "${!tasks[@]}"; do
    step=$((i + 1))
    show_step $step $total_steps "${tasks[$i]}"
    show_progress $step $total_steps "${tasks[$i]}中..."
    sleep 0.5
done

sleep 1

# 演示3: 旋转加载器
echo ""
echo -e "${BOLD}${PURPLE}═══ 演示 3: 动态加载器 ═══${NC}"
show_spinner "下载并安装软件包" 3
sleep 0.5

# 完成提示
echo ""
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}✓ 所有演示已完成！${NC}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}这些进度条和加载效果已集成到主脚本中！${NC}"
echo -e "${GRAY}运行 ${BOLD}sudo ./vps_optimize.sh${NC}${GRAY} 并选择 ${BOLD}0${NC}${GRAY} 查看完整效果${NC}"
echo ""
