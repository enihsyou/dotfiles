#!/usr/bin/env -S brew bundle --no-lock --file
# 首行的 shebang 让本文件可以直接在shell里执行
# 阅读 https://stackoverflow.com/a/52979955 学习更多关于
# 如何让 shebang 支持多参数的命令

# 添加 --no-lock 参数，避免自动创建 Brewfile.lock.json 文件
# 因为不需要这个特性，只要安装了就好

# macOS Quick Look 插件的 homebrew bundle 
# 直接在 shell 里执行本文件来安装
# 列表来自 https://github.com/sindresorhus/quick-look-plugins
# 其他可用 https://www.quicklookplugins.com


# qlcolorcode 在 macOS 10.15 开始已经失效了
# https://sayzlim.net/qlcolorcode-not-working-catalina/
# 现在替换成 syntax-highlight
cask "syntax-highlight", args: { no_quarantine: true } if OS.mac?

cask "qlstephen"      if OS.mac?
cask "quicklook-json" if OS.mac?