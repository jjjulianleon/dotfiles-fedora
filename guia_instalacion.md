# 🚀 Guía de Instalación - Dotfiles Fedora a Mint

Este repositorio contiene la configuración optimizada de mi entorno de trabajo. Sigue estos pasos para replicarlo en Linux Mint (XFCE/Cinnamon).

## 1. Preparación del Sistema
Actualiza los repositorios e instala las herramientas base:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl zsh fastfetch neovim build-essential
```

## 2. Configuración de la Terminal (Zsh + P10K)
Instala Oh My Zsh y el tema Powerlevel10k:
```bash
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Luego, aplica mis configuraciones:
```bash
cp ~/dotfiles/zsh/dot-zshrc ~/.zshrc
cp ~/dotfiles/zsh/dot-p10k.zsh ~/.p10k.zsh
```

## 3. Configuración de Neovim
Copia la configuración de Neovim y asegúrate de tener las dependencias para plugins:
```bash
mkdir -p ~/.config/nvim
cp -r ~/dotfiles/config/nvim/* ~/.config/nvim/
```

## 4. Estética (Fastfetch + Pokemon)
Para que el fastfetch se vea igual que en Fedora:
```bash
mkdir -p ~/.config/fastfetch
cp -r ~/dotfiles/config/fastfetch/* ~/.config/fastfetch/

# Instalar Pokemon Colorscripts (si quieres los logos)
git clone https://github.com/phitux/pokemon-colorscripts.git
cd pokemon-colorscripts && sudo ./install.sh
```

## 5. Scripts y Configuración de Git
Copia tus scripts y tu configuración de Git para mantener tu identidad:
```bash
# Scripts
mkdir -p ~/scripts
cp ~/dotfiles/scripts/* ~/scripts/
chmod +x ~/scripts/*.sh

# Git
cp ~/dotfiles/git-config ~/.gitconfig
```

## 6. Herramientas Modernas (CLI de alto rendimiento)
Instala estas alternativas ligeras para mejorar la experiencia en la terminal:
```bash
sudo apt install -y bat btop
# Nota: en Ubuntu/Mint, 'bat' se instala como 'batcat'
# Crea un alias: alias cat='batcat'

# Para eza y zoxide (recomendado descargar binarios o usar cargo/npx si no están en apt)
sudo apt install -y eza zoxide
```

## 7. Paso Crucial: Nerd Fonts
Para que los iconos de Neovim y P10k funcionen, DEBES instalar una Nerd Font en el sistema operativo:
1. Descarga [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip).
2. Descomprime en `~/.local/share/fonts`.
3. Ejecuta `fc-cache -fv`.
4. En la configuración de la terminal (XFCE Terminal/Cinnamon), selecciona "JetBrainsMono Nerd Font" como fuente.

---
*Nota: Recuerda cambiar tu shell por defecto a zsh ejecutando `chsh -s $(which zsh)`.*
