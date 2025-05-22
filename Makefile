# 本文件应使用 UTF-8 编码，LF 换行符

# [Windows only]
# 手动对比并从导出内容中删除不需要的内容，以更新 winget-export.json
Windows/winget-export.json:
	winget export --source winget --output $@
.PHONY: Windows/winget-export.json

cli-app/aria2/aria2.pfx:
	mkcert -key-file cli-app/aria2/aria2.key.pem -cert-file cli-app/aria2/aria2.crt.pem enihsyou.synology.me localhost 127.0.0.1 ::1
	openssl pkcs12 -export -inkey cli-app/aria2/aria2.key.pem -in cli-app/aria2/aria2.crt.pem -out cli-app/aria2/aria2.pfx -passout pass:
