## 如何在另一个设备上使用 skillshare

```bash
skillshare init --no-git --no-copy --no-skill --targets universal --mode merge --source ~/.config/skillshare/skills --subdir '.'

wget https://github.com/enihsyou/dotfiles/raw/refs/heads/Windows/cli-app/skillshare/skills/metadata.json -O ~/.config/skillshare/skills/.metadata.json

skillshare install
skillshare sync
```
