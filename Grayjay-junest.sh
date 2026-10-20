#!/usr/bin/env bash

APP=grayjay-bin
BIN="grayjay"
DEPENDENCES="acl alsa-lib at-spi2-core avahi brotli bzip2 cairo dbus expat fontconfig freetype2 fribidi gcc-libs gdk-pixbuf2 glib2 glibc gmp gnutls graphite gtk3 harfbuzz icu jbigkit json-glib kde-gtk-config leancrypto libcap libcloudproviders libcups libdatrie libdeflate libdrm libelf libepoxy libffi libglvnd libidn2 libjpeg-turbo libp11-kit libpng libtasn1 libthai libtiff libunistring libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxshmfence libxxf86vm lm_sensors mesa mpfr ncurses nettle nspr nss openssl pango pcre2 pixman readline spirv-tools sqlite systemd-libs tinysparql util-linux-libs wayland xz zlib zstd libgcrypt libgpg-error lz4"
BASICSTUFF=""
COMPILERS=""

# Set keywords to search and include in names of directories and files in /usr/bin (BINSAVED), /usr/share (SHARESAVED) and /usr/lib (LIBSAVED)
BINSAVED="grayjay"
SHARESAVED="grayjay"
# LIBSAVED is libraries to include in AppImage
LIBSAVED="linux-vdso ld-linux-x86-64 libgcrypt liblz4 libgpg-error libcap libc libgcc_s dri_gbm libcolorreload-gtk-module libwindow-decorations-gtk-module libacl libasound libatk-1.0 libatk-bridge-2.0 libatspi libavahi-client libavahi-common libblkid libbrotlicommon libbrotlidec libbrotlienc libbz2 libcairo-gobject libcairo libcloudproviders libcrypto libcups libdatrie libdbus-1 libdeflate libdl libdrm_amdgpu libdrm libelf libepoxy libexpat libffi libfontconfig libfreeblpriv3 libfreetype libfribidi libgallium libgbm libgdk-3 libgdk_pixbuf-2.0 libgio-2.0 libGLdispatch libglib-2.0 libGL libGLX_mesa libGLX libgmodule-2.0 libgmp libgnutls libgobject-2.0 libgraphite2 libgtk-3 libharfbuzz libhogweed libicudata libicui18n libicuuc libidn2 libjbig libjpeg libjson-glib-1.0 libleancrypto liblzma libmount libmpfr libm libncursesw libnettle libnspr4 libnss3 libnssckbi libnssutil3 libp11-kit libpango-1.0 libpangocairo-1.0 libpangoft2-1.0 libpcre2-8 libpixman-1 libplc4 libplds4 libpng16 libpthread libreadline librt libsensors libsharpyuv libsmime3 libsoftokn3 libSPIRV-Tools libsqlite3 libssl libstdc++ libsystemd libtasn1 libthai libtiff libtinysparql-3.0 libudev libunistring libwayland-client libwayland-cursor libwayland-egl libwayland-server libwebp libX11 libX11-xcb libXau libxcb-dri3 libxcb-glx libxcb-present libxcb-randr libxcb-render libxcb-shm libxcb libxcb-sync libxcb-xfixes libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXinerama libXi libxkbcommon libxml2 libXrandr libXrender libxshmfence libXxf86vm libz libzstd"
# Set the items you want to manually REMOVE.
ETC_REMOVED="makepkg.conf pacman"
BIN_REMOVED="gcc"
LIB_REMOVED="gcc"
PYTHON_REMOVED="__pycache__/"
SHARE_REMOVED="gcc icons/AdwaitaLegacy icons/Adwaita/cursors/ terminfo"

mountpoint_files=""
mountpoint_dirs=""

# Post-installation processes
_post_installation_processes() {
cat > AppDir/.junest/usr/bin/grayjay <<'EOF'
#!/bin/sh
APP_DIR="$HOME/.local/share/grayjay"
mkdir -p "$HOME/.local/share"
if [ ! -d "$APP_DIR" ]; then
    cp -a /usr/share/grayjay "$APP_DIR"
fi
cd "$APP_DIR"
exec ./Grayjay $GRAYJAY_ARGS "$GRAYJAY_HOST_RULES" "$@"
EOF
chmod 755 AppDir/.junest/usr/bin/grayjay

# to update appimage unofficially uncomment
#ZIP="Grayjay.Desktop-linux-x64.zip"
#if [ ! -f "$ZIP" ]; then
#    curl -fLo "Grayjay.Desktop-linux-x64.zip" https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-linux-x64.zip
#fi
#    VERSION=$(unzip -l "$ZIP" | grep -oP 'Grayjay\.Desktop-linux-x64-v\K[0-9][0-9.a-z]*' | head -1)
#    rm -rf AppDir/.junest/usr/share/grayjay
#    unzip -q "$ZIP" -d AppDir/.junest/usr/share
#    INNER=$(find AppDir/.junest/usr/share -maxdepth 1 -type d -name 'Grayjay.Desktop-linux-x64-v*' | head -1)
#    mv "$INNER" AppDir/.junest/usr/share/grayjay

}

##########################################################################################################################################################
#	SETUP THE ENVIRONMENT
##########################################################################################################################################################

# Download archimage-builder.sh
if [ ! -f ./archimage-builder.sh ]; then
	ARCHIMAGE_BUILDER="https://raw.githubusercontent.com/ivan-hc/ArchImage/refs/heads/main/core/archimage-builder.sh"
	wget --retry-connrefused --tries=30 "$ARCHIMAGE_BUILDER" -O ./archimage-builder.sh || exit 0
fi

# Create and enter the AppDir
mkdir -p AppDir archlinux && cd archlinux || exit 1

_JUNEST_CMD() {
	./.local/share/junest/bin/junest "$@"
}

# Set archlinux as a temporary $HOME directory
HOME="$(dirname "$(readlink -f "$0")")"

##########################################################################################################################################################
#	DOWNLOAD, INSTALL AND CONFIGURE JUNEST
##########################################################################################################################################################

_enable_archlinuxcn() {	ARCHLINUXCN_ON="1"; }
_enable_chaoticaur() { CHAOTICAUR_ON="1"; }
_enable_multilib() { MULTILIB_ON="1"; }

#_enable_archlinuxcn
#_enable_chaoticaur
#_enable_multilib

[ -f ../archimage-builder.sh ] && source ../archimage-builder.sh junest-setup "$@"

##########################################################################################################################################################
#	INSTALL PROGRAMS USING YAY
##########################################################################################################################################################

[ -f ../archimage-builder.sh ] && source ../archimage-builder.sh install "$@"

cd ..

##########################################################################################################################################################
#	APPDIR
##########################################################################################################################################################

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh appdir "$@"

# Overwrite .desktop file
DESKTOP_CONTENT='[Desktop Entry]
Name=Grayjay
Comment=Privacy-respecting client for YouTube, Rumble, Twitch, Spotify etc
Exec=/usr/bin/grayjay
Icon=grayjay
Terminal=false
Type=Application
Categories=Network;Video;AudioVideo;
StartupNotify=true
StartupWMClass=Grayjay
'
echo "$DESKTOP_CONTENT" > "AppDir/$BIN.desktop"

##########################################################################################################################################################
#	APPRUN
##########################################################################################################################################################

rm -f AppDir/AppRun

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh apprun "$@"

# AppRun footer
cat <<-'HEREDOC' >> AppDir/AppRun

# Install icon + desktop entry when AppImage lives in ~/Applications/
if [ "$(dirname "$APPIMAGE")" = "$HOME/Applications" ]; then
    ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
    if [ ! -f "$ICON_DIR/grayjay.png" ]; then
        mkdir -p "$ICON_DIR"
        cp "${HERE}/grayjay.png" "$ICON_DIR/grayjay.png"
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
        rm -f "$HOME/.cache/icon-cache.kcache"
    fi

    DESKTOP_FILE="$HOME/.local/share/applications/grayjay.desktop"
    if [ ! -f "$DESKTOP_FILE" ]; then
        mkdir -p "$HOME/.local/share/applications"
        cat > "$DESKTOP_FILE" <<DEOF
[Desktop Entry]
Name=Grayjay
Comment=Privacy-respecting client for YouTube, Rumble, Twitch, Spotify etc
Exec=$APPIMAGE
Icon=grayjay
Terminal=false
Type=Application
Categories=Network;Video;AudioVideo;
StartupNotify=true
StartupWMClass=Grayjay
DEOF
        chmod +x "$DESKTOP_FILE"
        update-desktop-database ~/.local/share/applications
    fi
fi
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
if ! echo "$EXEC" | grep -q "/usr/bin"; then EXEC="/usr/bin/$EXEC"; fi

# DNS pinning for relay
RELAY_IP=$(getent ahostsv4 relay.grayjay.app 2>/dev/null | head -1 | awk '{print $1}')
[ -n "$RELAY_IP" ] && export GRAYJAY_HOST_RULES="--host-resolver-rules=MAP relay.grayjay.app $RELAY_IP"

# DBus session bus
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ] || [ -S /run/user/$(id -u)/bus ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

export GDK_BACKEND=wayland,x11,broadway

# GPU detection
JUNEST_GPU_ARGS="--bind /dev/dri /dev/dri --bind /usr/lib/dri /usr/lib/dri"
if [ -e /dev/nvidia0 ]; then
    JUNEST_GPU_ARGS="$JUNEST_GPU_ARGS --bind /dev/nvidia0 /dev/nvidia0 --bind /dev/nvidiactl /dev/nvidiactl --bind /dev/nvidia-modeset /dev/nvidia-modeset"
    for lib in $(find /usr/lib /usr/lib64 /usr/lib/x86_64-linux-gnu -maxdepth 1 \( -name 'libnvidia*.so*' -o -name 'libcuda.so*' -o -name 'libnvcuvid.so*' -o -name 'libnvoptix.so*' \) 2>/dev/null); do
        JUNEST_GPU_ARGS="$JUNEST_GPU_ARGS --bind $lib $lib"
    done
fi
export JUNEST_ARGS="$JUNEST_GPU_ARGS --bind /run/dbus /run/dbus"

# Set Arguments
GRAYJAY_ARGS="--ozone-platform=x11 --enable-features=UseOzonePlatform --class=Grayjay --no-sandbox --disable-dev-shm-usage --disable-gpu-compositing --use-gl=angle"
# box64 tuning (ARM → x86 emulation)
if grep -q box64 /proc/self/maps 2>/dev/null; then
    BOX64_MAXCPU="${BOX64_MAXCPU:-$(( $(nproc) > 8 ? 8 : $(nproc) ))}"
    export BOX64_MAXCPU               # Limit visible cores (Chromium spawns per-core threads;too many wastes memory under emulation)
    export BOX64_DYNAREC_BIGBLOCK=3   # Aggressive block fusion (biggest single win)
    export BOX64_DYNAREC_XABS=1       # Use XABS for absolute addressing
    export BOX64_DYNAREC_FORWARD=1024 # Longer forward jumps
    export BOX64_DYNAREC_CALLRET=1    # Optimize call/return pairs
    export BOX64_DYNAREC_SAFEFLAGS=0  # Skip some flag preservation (safe for most apps)
    export BOX64_X87DOUBLE=1          # Use double for x87 (faster, slight precision loss)
    #export BOX64_MMAP32=1             # Forces box64 to prefer 32-bit-compatible addresses for mmap calls from external libraries
    export BOX64_LD_LIBRARY_PATH="$APPDIR/.junest/usr/lib:$APP_DIR"
    GRAYJAY_ARGS="$GRAYJAY_ARGS --use-angle=swiftshader --disable-gpu"
else
    GRAYJAY_ARGS="$GRAYJAY_ARGS --use-angle=default"
fi
export GRAYJAY_ARGS

_JUNEST_CMD -- $EXEC "$@"

HEREDOC

chmod a+x AppDir/AppRun

##########################################################################################################################################################
#	COMPILE
##########################################################################################################################################################

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh compile "$@"

##########################################################################################################################################################
#	CREATE THE APPIMAGE
##########################################################################################################################################################

if test -f ./*.AppImage; then rm -Rf ./*archimage*.AppImage; fi

APPNAME=$(cat AppDir/*.desktop | grep '^Name=' | head -1 | cut -c 6- | sed 's/ /-/g')
REPO="$APPNAME-appimage"
TAG="latest"
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|$REPO|$TAG|*x86_64.AppImage.zsync"

echo "$VERSION" > ./version

RUNTIME="runtime-x86_64"
if [ ! -f "$RUNTIME" ]; then
    curl -fLo "$RUNTIME" https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
fi

_appimagetool() {
	if ! command -v appimagetool 1>/dev/null; then
		if [ ! -f ./appimagetool ]; then
			echo " Downloading appimagetool..." && curl -#Lo appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-"$ARCH".AppImage && chmod a+x ./appimagetool || exit 1
		fi
		./appimagetool "$@"
	else
		appimagetool "$@"
	fi
}

ARCH=x86_64 _appimagetool --runtime-file "$RUNTIME" -u "$UPINFO" AppDir "$APPNAME"_"$VERSION"-"$ARCHIMAGE_VERSION"-x86_64.AppImage
