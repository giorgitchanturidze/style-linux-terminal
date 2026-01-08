# 🚀 Style Ubuntu Terminal

![image](https://user-images.githubusercontent.com/101937929/230771726-9eb8fb60-510a-459d-9bc3-be6accb3f59e.png)

## 🛠 Install core components

* [ZSH](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
* [Oh My Zsh](https://ohmyz.sh/#install)
* [PL10K](https://github.com/romkatv/powerlevel10k)
* [Dracula theme](https://draculatheme.com/gnome-terminal)

## 🛠 Install Plugins

* [Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)
* [Syntax Highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)

## ❓ Troubleshooting

### **My icons are weird squares with question marks**

You skipped the **Font Installation** step in [PL10K](https://github.com/romkatv/powerlevel10k).
1. Install `MesloLGS NF`.
2. Ensure your terminal is actually using that font in `Edit` -> `Preferences`.

### **The terminal asks me to configure "p10k" every time?**

Run this command once to finish the wizard:
```
p10k configure
```

### **How do I go back to Bash?**

If you decide this isn't for you:
```
chsh -s $(which bash)
```
