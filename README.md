# ✨ Arch < dotfiles

🛠️ **Auto-instalador para Arch Linux** con `Hyprland` y mi configuración personal.

<p float="center">
<img src="https://raw.githubusercontent.com/aleister888/archinstall/refs/heads/main/assets/images/screenshot1.png" width="49%" />
<img src="https://raw.githubusercontent.com/aleister888/archinstall/refs/heads/main/assets/images/screenshot2.png" width="49%" />
</p>

---

#### 🚀 Instalación

🔧 Ejecuta los siguientes comandos como **root**:

- Para usar la versión testeada más reciente:
```bash
bash <(curl https://raw.githubusercontent.com/aleister888/archinstall/main/stable.sh)
```
- Para usar la versión de desarrollo (no recomendado):
```bash
bash <(curl https://raw.githubusercontent.com/aleister888/archinstall/main/install.sh)
```

> [!NOTE]
> ⚠️ La instalación toma unos `30-45 minutos` aproximadamente.

---

#### 🧩 Características

- 🔐 **LUKS y LVM**: `swap` y `/` encriptados (`/boot` sin encriptar)
- 💻 Compatible solo con **UEFI**.
- 📁 Entorno organizado según el estándar [XDG Base Directory](https://wiki.archlinux.org/title/XDG_Base_Directory).
