#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Clash Proxy Off
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Proxy Control

# Documentation:
# @raycast.description 切换本地代理关闭
# @raycast.author 九条涼果
# @raycast.authorURL https://github.com/enihsyou

# networksetup -switchtolocation "Automatic" > /dev/null
# echo "切换到 Automatic 网络地区"
networksetup -setwebproxystate       'Wi-Fi' off
networksetup -setsecurewebproxystate 'Wi-Fi' off
networksetup -setwebproxystate       'USB 10/100/1000 LAN' off
networksetup -setsecurewebproxystate 'USB 10/100/1000 LAN' off