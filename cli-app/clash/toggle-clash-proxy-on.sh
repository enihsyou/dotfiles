#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Clash Proxy On
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Proxy Control

# Documentation:
# @raycast.description 切换本地代理开启
# @raycast.author 九条涼果
# @raycast.authorURL https://github.com/enihsyou

# networksetup -switchtolocation "本地代理" > /dev/null

networksetup -setwebproxy            'Wi-Fi' 127.0.0.1 7890
networksetup -setsecurewebproxy      'Wi-Fi' 127.0.0.1 7890
networksetup -setwebproxystate       'Wi-Fi' on
networksetup -setsecurewebproxystate 'Wi-Fi' on

networksetup -setwebproxy            'USB 10/100/1000 LAN' 127.0.0.1 7890
networksetup -setsecurewebproxy      'USB 10/100/1000 LAN' 127.0.0.1 7890
networksetup -setwebproxystate       'USB 10/100/1000 LAN' on
networksetup -setsecurewebproxystate 'USB 10/100/1000 LAN' on