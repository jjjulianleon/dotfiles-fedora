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

## 5. Scripts Personales
Dar permisos de ejecución a los scripts útiles:
```bash
mkdir -p ~/scripts
cp ~/dotfiles/scripts/* ~/scripts/
chmod +x ~/scripts/*.sh
```

---
*Nota: Recuerda cambiar tu shell por defecto a zsh ejecutando `chsh -s $(which zsh)`.*
