#!/usr/bin/env bash
set -e

echo "=== Minecraft mcbot OneKey Uninstall ==="
echo

# ---------- 停止并删除 mcbot（即使 pm2 不存在也不报错） ----------
if command -v pm2 >/dev/null 2>&1; then
  echo "[*] Detected pm2, stopping mcbot..."
  pm2 delete mcbot >/dev/null 2>&1 || true
  pm2 save >/dev/null 2>&1 || true
else
  echo "[*] pm2 not found, skip pm2 cleanup"
fi

# ---------- 删除项目依赖 ----------
rm -rf node_modules
rm -f package-lock.json

echo "[✓] mcbot files removed"
echo

# ---------- 询问是否卸载 Node.js / npm ----------
read -rp "是否同时卸载 Node.js / npm？(y/N): " REMOVE_NODE

if [[ "$REMOVE_NODE" =~ ^[Yy]$ ]]; then
  echo
  echo "[*] Preparing to uninstall Node.js / npm..."

  # apt 安装的情况
  if command -v apt >/dev/null 2>&1 && dpkg -l | grep -q nodejs; then
    echo "[*] Removing nodejs via apt..."
    apt purge -y nodejs npm || true
    apt autoremove -y || true
  fi

  # 手动 / NodeSource / npm -g 安装的情况
  if [ -f /usr/local/bin/node ]; then
    echo "[*] Removing manual Node.js binaries..."
    rm -f /usr/local/bin/node
    rm -f /usr/local/bin/npm
    rm -f /usr/local/bin/npx
    rm -rf /usr/local/lib/node_modules
  fi

  # 清理用户缓存
  rm -rf ~/.npm ~/.node-gyp

  echo "[✓] Node.js / npm removed"
else
  echo
  echo "[*] Skip removing Node.js / npm"
fi

echo
echo "=== Uninstall Completed ==="
