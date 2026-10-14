#!/usr/bin/env bash

APP=grayjay-bin
BIN="grayjay"
DEPENDENCES="at-spi2-core gtk3 libappindicator-gtk3 libnotify libsecret libxss libxtst nss unzip xdg-utils utils-git \
alsa-lib libcups avahi mesa"
BASICSTUFF=""
COMPILERS=""

# Set keywords to search and include in names of directories and files in /usr/bin (BINSAVED), /usr/share (SHARESAVED) and /usr/lib (LIBSAVED)
BINSAVED="grayjay"
SHARESAVED="grayjay"
# LIBSAVED is libraries to include in AppImage
LIBSAVED="glib-2.0 gobject-2.0 gio-2.0 gmodule-2.0 ffi nspr4 nss3 nssutil3 smime3 plds4 plc4 gnutls p11-kit tasn1 idn2 unistring nettle hogweed gmp gcrypt gpg-error brotlienc brotlidec brotlicommon X11 Xcomposite Xdamage Xext Xfixes Xrandr Xrender Xau Xdmcp Xi xcb xkbcommon wayland-server cairo pango freetype fontconfig pixman fribidi thai harfbuzz graphite2 datrie png16 expat asound udev systemd mount blkid cap gbm drm dbus-1 atk-1.0 atk-bridge-2.0 atspi cups avahi-common avahi-client z bz2 lz4 lzma zstd pcre2-8 stdc++ gcc_s icuuc icui18n icudata ssl crypto GL EGL GLX"

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
export GDK_BACKEND=x11
cd "$APP_DIR" && exec ./Grayjay --ozone-platform=x11 --class=Grayjay --disable-gpu "$@"
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
StartupWMClass=Grayjay
'
echo "$DESKTOP_CONTENT" > "AppDir/$BIN.desktop"
echo "$DESKTOP_CONTENT" > "AppDir/.junest/usr/share/applications/$BIN.desktop"

##########################################################################################################################################################
#	APPRUN
##########################################################################################################################################################

rm -f AppDir/AppRun

# Set to "1" if you want to add Nvidia drivers manager in the AppRun
export NVIDIA_ON=0

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh apprun "$@"

# AppRun footer
cat <<-'HEREDOC' >> AppDir/AppRun

EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
if ! echo "$EXEC" | grep -q "/usr/bin"; then EXEC="/usr/bin/$EXEC"; fi

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
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|$REPO|$TAG|*x64.AppImage.zsync"

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

ARCH=x86_64 _appimagetool --runtime-file "$RUNTIME" -u "$UPINFO" AppDir "$APPNAME"_"$VERSION"-"$ARCHIMAGE_VERSION"-x64.AppImage
