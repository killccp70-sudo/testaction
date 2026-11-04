#!/bin/bash
curl -o rc.deb -sL https://github.com/rclone/rclone/releases/download/v1.74.1/rclone-v1.74.1-linux-amd64.deb
curl -o ty -sL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64
curl -o cf -sL https://github.com/cloudflare/cloudflared/releases/download/2026.5.0/cloudflared-linux-amd64
chmod +x ty cf && sudo apt install ./rc.deb

nohup ./cf tunnel run --token $CF_TOKEN >/dev/null &
nohup ./ty -p 58000 -c test:$TY_PWD -W bash >/dev/null &
rm -rf rc.deb ty cf

for i in {1..360}; do
  echo "check-service Keep-alive heartbeat $i/360   $(date)"
  sleep 60
done
