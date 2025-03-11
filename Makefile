# 本文件应使用 UTF-8 编码，LF 换行符

# [Windows only]
# 手动对比并从导出内容中删除不需要的内容，以更新 winget-export.json
Windows\winget-export.json: Windows\winget-export.temp.json
	code --diff $< $@
	del $<
Windows\winget-export.temp.json:
	winget export --source winget --output $@
