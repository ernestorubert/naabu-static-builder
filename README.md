# 🛠️ Compilador de `naabu` 100% Estático 🚀

Este repositorio contiene un `Dockerfile` y un script (`compilar.sh`) para compilar un binario de **naabu** completamente estático, incluyendo **libpcap** y **libc**, ideal para entornos minimalistas, `chroot`, contenedores `scratch` o sistemas sin librerías dinámicas.

---

## 🤔 ¿Por qué existe esto?

Si alguna vez has estado en un CTF 🚩 o has auditado un entorno `chroot` o un contenedor Docker minimalista (como `alpine` o `scratch`), probablemente viste este error:

```bash
🚫 sh: ./naabu: not found
```

Esto ocurre porque el binario estándar de `naabu` está **enlazado dinámicamente**, y en sistemas mínimos no existen las librerías necesarias (como `/lib64/ld-linux-x86-64.so.2`).

Compilarlo **estáticamente** es complicado debido a dependencias como `libpcap`, `dbus`, `flex`, `bison`, etc.

✅ **Este proyecto automatiza todo ese proceso de compilación** para que obtengas un binario funcional y portable.

---

## 🧰 Prerrequisitos: Instalar Docker 🐳

Necesitas tener Docker instalado en tu sistema para poder compilar el binario.

### 🐧 En Linux

#### Debian / Ubuntu / Kali / Parrot

```bash
sudo apt update
sudo apt install docker.io
```

#### Arch / Manjaro

```bash
sudo pacman -S docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### Fedora

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
```

> 💡 **Recomendado:** Añade tu usuario al grupo `docker` para no tener que usar `sudo` cada vez:
>
> ```bash
> sudo usermod -aG docker $USER
> ```
> 🔄 Cierra sesión y vuelve a iniciarla (o reinicia) para aplicar los cambios.

---

## 🚀 Uso Rápido

1. **Clona este repositorio:**

```bash
git clone https://github.com/TU-USUARIO/naabu-static-builder.git
cd naabu-static-builder
```

2. **Dale permisos al script y ejecútalo:**

```bash
chmod +x ./compilar.sh
./compilar.sh
# o, si no estás en el grupo docker:
# sudo ./compilar.sh
```

3. **¡Listo!**
Al finalizar, tendrás un binario llamado **naabu-static** en tu carpeta actual.

---

## 🎁 ¿Qué obtienes?

El script usa Docker para compilar todo de forma aislada.  
Tras unos minutos (solo la primera vez), obtendrás un binario **portátil** y **estático**.

Prueba rápida:

```bash
file ./naabu-static
```

Salida esperada:

```
./naabu-static: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, ...
```

---

## ⚙️ ¿Cómo funciona?

1. El `Dockerfile` usa una imagen base de **Ubuntu**.  
2. Instala todas las dependencias de compilación (`gcc`, `flex`, `bison`, etc.).  
3. Descarga y compila `libpcap` desde cero como **librería estática**, evitando dependencias innecesarias como `dbus`.  
4. Clona el repositorio oficial de `naabu`.  
5. Compila `naabu` **forzando el enlazado estático** con la `libpcap` recién compilada.  
6. Usa un **build multi-stage** para dejar solo el binario final en una imagen `scratch` (ultraligera).  
7. El script `compilar.sh` extrae ese binario y lo guarda localmente.

---

## 🧩 Estructura del repositorio

```
naabu-static-builder/
├── Dockerfile
├── compilar.sh
└── README.md
```

---

## 🧑‍💻 Créditos

- Basado en [ProjectDiscovery/naabu](https://github.com/projectdiscovery/naabu)
- Script y entorno de compilación estática creados por la comunidad ❤️
- Inspirado en la necesidad de binarios ligeros para CTFs y auditorías de red.

---

## ⚖️ Licencia

Este proyecto se distribuye bajo la **MIT License**.  
Consulta el archivo `LICENSE` para más información.

---
