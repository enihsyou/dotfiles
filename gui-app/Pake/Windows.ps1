# 使用小于 960px 的宽度，默认不显示侧边栏
pake https://gemini.google.com/ --name Gemini --width 959 --height 1280 `
  --enable-drag-drop --installer-language zh-CN `
  --activation-shortcut "Super+Alt+C" `
  --inject ./gemini.css

pake https://grok.com/ --name Grok --width 1024 --height 1280 `
  --enable-drag-drop --installer-language zh-CN `
  --inject ./grok.css

pake https://www.qianwen.com/chat/ --name Qwen --width 1024 --height 1280 `
  --enable-drag-drop --installer-language zh-CN `
  --inject ./Qwen.css

pake https://chat.deepseek.com/ --name DeepSeek --width 1024 --height 1280 `
  --enable-drag-drop --installer-language zh-CN `
  --inject ./deepseek.css

wget https://copilot.microsoft.com/static/cmc/favicon.svg -O copilot-favicon.svg
magick -density 256x256 -background transparent copilot-favicon.svg -define icon:auto-resize -colors 256 copilot-favicon.ico
pake https://copilot.microsoft.com/ --name Copilot --width 1024 --height 1280 `
  --icon copilot-favicon.ico `
  --enable-drag-drop --installer-language zh-CN `
  --inject ./copilot.css
