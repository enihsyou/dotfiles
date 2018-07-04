# Install powerlevel9k theme
git submodule init
git submodule update

# Install zsh
! exist zsh &&
install_prompt "Will install zsh." && 
sudo apt install zsh

# If oh-my-zsh not exist download it.
! -d "$HOME/.oh-my-zsh/" &&
install_prompt "Will install oh-my-zsh." &&
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

