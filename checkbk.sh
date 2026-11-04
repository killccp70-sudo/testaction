#!/bin/bash
# semaphore-monitor.sh
# 用法: ./semaphore-monitor.sh <project-name> [interval_seconds]

PROJECT="testaction"
INTERVAL="120"          # 默认每 120 秒检查一次
WORKFLOW_NAME_OR_BRANCH="main"   # 可选：过滤特定 branch

echo "🚀 开始监控 Semaphore 项目: $PROJECT (间隔 ${INTERVAL}s)"

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检查中..."

  # 获取最近的 workflows，并过滤 RUNNING 状态
  RUNNING=$(sem get pipelines -p "$PROJECT" 2>/dev/null | grep -E 'RUNNING|running' | wc -l)

  if [ "$RUNNING" -eq 0 ]; then
    echo "⚠️  当前没有正在运行的 Workflow，准备重启..."

    # 获取最新的 workflow ID（推荐使用最近的 DONE 或特定 branch）
    LATEST_WF=$(sem get workflows -p "$PROJECT" | head -n 5 | grep -E 'DONE|FINISHED|PASSED|FAILED' | head -n 1 | awk '{print $1}')
    LATEST_WF="d6150469-362d-4b97-9db9-ad2214f94262"

    if [ -n "$LATEST_WF" ]; then
      echo "🔄 重启 Workflow: $LATEST_WF"
      sem rebuild workflow "$LATEST_WF"
      echo "✅ 重启完成"
    else
      echo "❌ 未找到可重启的 Workflow"
    fi
  else
    echo "✅ 有 $RUNNING 个 Workflow 正在运行"
  fi

  sleep "$INTERVAL"
done
