🛠️ **Auto-instalador para Arch Linux** con `Hyprland`, `nix` y mi configuración personal.

<p float="center">
<img src="https://raw.githubusercontent.com/aleister888/archinstall/refs/heads/main/assets/images/screenshot1.png" width="49%" />
<img src="https://raw.githubusercontent.com/aleister888/archinstall/refs/heads/main/assets/images/screenshot2.png" width="49%" />
</p>

## 🚀 Instalación

🔧 Ejecuta como **root** desde la ISO de Arch Linux:

Para usar la versión testeada más reciente:
```bash
bash <(curl https://raw.githubusercontent.com/aleister888/archinstall/main/stable.sh)
```
Para usar la versión de desarrollo (no recomendado):
```bash
bash <(curl https://raw.githubusercontent.com/aleister888/archinstall/main/install.sh)
```

> [!WARNING]
> Se recomienda usar la ultima versión de la ISO: [Mirror](https://fastly.mirror.pkgbuild.com/iso/), [Torrent](https://archlinux.org/releng/releases/)

> [!NOTE]
> La instalación toma unos `30-45 minutos` aproximadamente.

### ⚙️ Automatización

El script puede ejecutarse de forma completamente automática estableciendo los distintos valores necesarios como opciones:

```
bash <(curl https://raw.githubusercontent.com/aleister888/archinstall/main/install.sh) \
  -U <nombre_usuario> \
  -u <contraseña_usuario> \
  -r <contraseña_root> \
  -l <contraseña_disco> \
  -t <zona_horaria> \
  -h <hostname> \
  -D <disco>
```

- La versión estable también soporta el uso de flags.
- También puede usarse el flag `-d` para activar el modo depurado, que hace que el script se detenga completamente ante cualquier error.

## 🧩 Características

- 🔐 **LUKS y LVM**: `swap` y `/` encriptados (`/boot` sin encriptar)
- 📦 Integración con [nixpkgs](https://github.com/NixOS/nixpkgs)
- 💻 Compatible solo con **UEFI**.
- 📁 Entorno organizado según el estándar [XDG Base Directory](https://wiki.archlinux.org/title/XDG_Base_Directory).
