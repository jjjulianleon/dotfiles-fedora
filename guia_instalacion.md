# 🚀 Instalación Limpia - Entorno Minimalista

Instrucciones para replicar mi entorno esencial en Linux Mint.

## 1. Base y Herramientas CLI
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl zsh fastfetch neovim gh
```

## 2. Navegador Vivaldi
```bash
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi-archive.list
sudo apt update && sudo apt install vivaldi-stable
```

## 3. Zoom
Descarga el `.deb` oficial de [zoom.us/download](https://zoom.us/download?os=linux) e instálalo:
```bash
sudo apt install ./zoom_amd64.deb
```

## 4. Terminal Estética (Zsh + P10K)
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Aplicar configs
cp ~/dotfiles/zsh/dot-zshrc ~/.zshrc
cp ~/dotfiles/zsh/dot-p10k.zsh ~/.p10k.zsh
cp ~/dotfiles/git-config ~/.gitconfig
```

## 5. Neovim y Fastfetch
```bash
mkdir -p ~/.config/nvim ~/.config/fastfetch
cp -r ~/dotfiles/config/nvim/* ~/.config/nvim/
cp -r ~/dotfiles/config/fastfetch/* ~/.config/fastfetch/
```

## 6. Nerd Fonts (OBLIGATORIO)
Instala **JetBrainsMono Nerd Font** para ver los iconos correctamente.
