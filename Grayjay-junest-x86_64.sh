#!/usr/bin/env bash

cd "$(dirname "$(readlink -f "$0")")"
mkdir -p junest/
cd junest

# x86_64 Linux Only
# Build Requires: bash, curl, wget, unzip

# Enable unprivileged user namespaces (required by JuNest/BubbleWrap):
#sudo sysctl -w kernel.unprivileged_userns_clone=1
# To make it persistent, add to /etc/sysctl.d/99-userns.conf:
#echo "kernel.unprivileged_userns_clone=1" | sudo tee /etc/sysctl.d/99-userns.conf

# On Ubuntu 23.10+ (where AppArmor restricts unprivileged user namespaces by default), run:
#sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
# make it persistent across reboots:
#echo 'kernel.apparmor_restrict_unprivileged_userns=0' | sudo tee /etc/sysctl.d/60-apparmor-namespace.conf

# unblock outgoing connections to sync relay server port if needed: https://relay.grayjay.app:9000
# unblock outgoing & incoming connections to sync lan port: 12315

APP=grayjay-bin
BIN="grayjay"
DEPENDENCES="coreutils xkeyboard-config glibc acl alsa-lib at-spi2-core avahi brotli bzip2 cairo dbus expat fontconfig freetype2 fribidi gcc-libs gdk-pixbuf2 glib2 gmp gnutls graphite gtk3 harfbuzz icu jbigkit json-glib kde-gtk-config leancrypto libcap libcloudproviders libcups libdatrie libdeflate libdrm libelf libepoxy libffi libglvnd libidn2 libjpeg-turbo libp11-kit libpng libtasn1 libthai libtiff libunistring libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxshmfence libxxf86vm lm_sensors mesa mpfr ncurses nettle nspr nss openssl pango pcre2 pixman readline spirv-tools sqlite systemd-libs tinysparql util-linux-libs wayland xz zlib zstd libgcrypt libgpg-error lz4"
BASICSTUFF=""
COMPILERS=""

# Set keywords to search and include in names of directories and files in /usr/bin (BINSAVED), /usr/share (SHARESAVED) and /usr/lib (LIBSAVED)
BINSAVED="grayjay mktemp"
SHARESAVED="grayjay"
LIBSAVED="ld-linux-x86-64 libc libm librt libdl libpthread libgcrypt liblz4 libgpg-error libcap libgcc_s dri_gbm libcolorreload-gtk-module libwindow-decorations-gtk-module libacl libasound libatk-1.0 libatk-bridge-2.0 libatspi libavahi-client libavahi-common libblkid libbrotlicommon libbrotlidec libbrotlienc libbz2 libcairo-gobject libcairo libcloudproviders libcrypto libcups libdatrie libdbus-1 libdeflate libdrm_amdgpu libdrm libelf libepoxy libexpat libffi libfontconfig libfreeblpriv3 libfreetype libfribidi libgallium libgbm libgdk-3 libgdk_pixbuf-2.0 libgio-2.0 libGLdispatch libglib-2.0 libGL libGLX_mesa libGLX libgmodule-2.0 libgmp libgnutls libgobject-2.0 libgraphite2 libgtk-3 libharfbuzz libhogweed libicudata libicui18n libicuuc libidn2 libjbig libjpeg libjson-glib-1.0 libleancrypto liblzma libmount libmpfr libncursesw libnettle libnspr4 libnss3 libnssckbi libnssutil3 libp11-kit libpango-1.0 libpangocairo-1.0 libpangoft2-1.0 libpcre2-8 libpixman-1 libplc4 libplds4 libpng16 libreadline libsensors libsharpyuv libsmime3 libsoftokn3 libSPIRV-Tools libsqlite3 libssl libstdc++ libsystemd libtasn1 libthai libtiff libtinysparql-3.0 libudev libunistring libwayland-client libwayland-cursor libwayland-egl libwayland-server libwebp libX11 libX11-xcb libXau libxcb-dri3 libxcb-glx libxcb-present libxcb-randr libxcb-render libxcb-shm libxcb libxcb-sync libxcb-xfixes libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXinerama libXi libxkbcommon libxml2 libXrandr libXrender libxshmfence libXxf86vm libz libzstd p11-kit-trust"
# comma , seperate LIBSAVED_ARCHIVE
LIBSAVED_ARCHIVE="libgallium-*-arch1.1"

CREATE_APPDIR_X86_64_ARCHIVE=false
INCLUDE_SHARESAVED_ARCHIVE=false

# Set the items you want to manually REMOVE.
ETC_REMOVED="makepkg.conf pacman"
BIN_REMOVED="gcc"
LIB_REMOVED="gcc"
PYTHON_REMOVED="__pycache__/"
SHARE_REMOVED="gcc icons/AdwaitaLegacy icons/Adwaita/cursors/ terminfo"

# Quick reference:
# Command:                        Purpose:
# pacman -Ql glibc                  All files in the glibc package
# pacman -Ql glibc | grep '\.so'    Only shared libs
# pacman -Qo /lib/libc.so.6         Which package owns this file
# pacman -Qs glibc                  Search installed packages by name
# pacman -Qk glibc                  Verify glibc files are intact (not modified)

mountpoint_files=""
mountpoint_dirs=""

# Post-installation processes
_post_installation_processes() {
    printf "\n◆ User's processes: \n\n"
    echo " - None"
    # to update appimage unofficially uncomment lines
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
#    SETUP THE ENVIRONMENT
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
#    DOWNLOAD, INSTALL AND CONFIGURE JUNEST
##########################################################################################################################################################

_enable_archlinuxcn() {    ARCHLINUXCN_ON="1"; }
_enable_chaoticaur() { CHAOTICAUR_ON="1"; }
_enable_multilib() { MULTILIB_ON="1"; }

#_enable_archlinuxcn
#_enable_chaoticaur
#_enable_multilib

[ -f ../archimage-builder.sh ] && source ../archimage-builder.sh junest-setup "$@"

##########################################################################################################################################################
#    INSTALL PROGRAMS USING YAY
##########################################################################################################################################################

[ -f ../archimage-builder.sh ] && source ../archimage-builder.sh install "$@"

cd ..

##########################################################################################################################################################
#    APPDIR
##########################################################################################################################################################

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh appdir "$@"

# Overwrite .desktop file
DESKTOP_CONTENT='[Desktop Entry]
Name=Grayjay
Comment=Privacy-respecting client for YouTube, Rumble, Twitch, Spotify etc
Exec=AppRun
Icon=grayjay
Terminal=false
Type=Application
Categories=Network;Video;AudioVideo;
StartupNotify=true
StartupWMClass=Grayjay
'
echo "$DESKTOP_CONTENT" > "AppDir/app.grayjay.grayjay.desktop"

##########################################################################################################################################################
#    APPRUN
##########################################################################################################################################################

rm -f AppDir/AppRun

# Set to "1" if you want to add Nvidia drivers manager in the AppRun
export NVIDIA_ON=0

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh apprun "$@"

# AppRun footer
cat <<-'HEREDOC' >> AppDir/AppRun
#!/bin/sh

if [ "$1" = "--uninstall" ]; then
    APP_NAME="grayjay"
    rm -f "$HOME/.local/share/applications/app.grayjay.grayjay.desktop"
    rm -f "$HOME/.local/share/icons/hicolor/512x512/apps/${APP_NAME}.png"
    rm -rf "$HOME/.local/share/${APP_NAME}"
    rm -rf "$HOME/.config/${APP_NAME}"
    rm -rf "$HOME/.cache/${APP_NAME}"
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
    rm -f "$HOME/.cache/icon-cache.kcache"
    update-desktop-database ~/.local/share/applications
    echo "Uninstalled ${APP_NAME} AppImage."
    exit 0
fi

if [ "$1" = "--remove-integration" ]; then
    APP_NAME="grayjay"
    rm -f "$HOME/.local/share/applications/app.grayjay.grayjay.desktop"
    rm -f "$HOME/.local/share/icons/hicolor/512x512/apps/${APP_NAME}.png"
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
    rm -f "$HOME/.cache/icon-cache.kcache"
    update-desktop-database ~/.local/share/applications
    echo "Removed ${APP_NAME} AppImage integration in application launcher."
    exit 0
fi

HERE="$(dirname "$(readlink -f "$0")")"
APP_DATA="$HOME/.local/share/grayjay"

# in junest / is resolved to .junest: .junest/usr/lib/gtk-3.0/modules
export LD_LIBRARY_PATH="$APP_DATA:$APP_DATA/cef:/usr/lib/gtk-3.0/modules:$LD_LIBRARY_PATH"
export GDK_BACKEND=wayland,x11,broadway

# ── DBus session bus ──
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ] || [ -S /run/user/$(id -u)/bus ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

# ── First-run: copy app data to user dir (enables self-updater) ──
if [ ! -d "$APP_DATA" ]; then
    mkdir -p "$APP_DATA"
    cp -a "$HERE/usr/share/grayjay/." "$APP_DATA/"
    chmod u+w -R "$APP_DATA"
fi

# Install icon + desktop entry when AppImage lives in ~/Applications/
if [ "$(dirname "$APPIMAGE")" = "$HOME/Applications" ]; then
    ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
    if [ ! -f "$ICON_DIR/grayjay.png" ]; then
        mkdir -p "$ICON_DIR"
        cp "${HERE}/grayjay.png" "$ICON_DIR/grayjay.png"
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
        rm -f "$HOME/.cache/icon-cache.kcache"
    fi

    DESKTOP_FILE="$HOME/.local/share/applications/app.grayjay.grayjay.desktop"
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

# Set Junest Arguments
JUNEST_ARGS="--bind /run/dbus /run/dbus --bind /run/user/$(id -u) /run/user/$(id -u)"
export JUNEST_ARGS

# ── Chromium flags ──
GRAYJAY_ARGS="--ozone-platform=x11 --enable-features=UseOzonePlatform --class=Grayjay --no-sandbox --disable-dev-shm-usage --disable-features=DbusObjectManager --disable-gpu --disable-gpu-compositing"
export GRAYJAY_ARGS

# ── DNS pinning for relay ──
RELAY_IP=$(getent ahostsv4 relay.grayjay.app 2>/dev/null | head -1 | awk '{print $1}')
[ -n "$RELAY_IP" ] && export GRAYJAY_HOST_RULES="--host-resolver-rules=MAP relay.grayjay.app $RELAY_IP"

cd "$APP_DATA"
_JUNEST_CMD -- ./Grayjay "$@"

HEREDOC

chmod a+x AppDir/AppRun

##########################################################################################################################################################
#    COMPILE
##########################################################################################################################################################

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh compile "$@"

# ─── AppDir_x86_64.tar.xz ──────────────────────────────────────────────────
LIBS=($(echo "$LIBSAVED $LIBSAVED_ARCHIVE" | tr ',' ' '))
BINS=($BINSAVED)

if [ "$CREATE_APPDIR_X86_64_ARCHIVE" = "true" ]; then
    echo "Creating AppDir_x86_64.tar.xz..."
    {
        for bin in "${BINS[@]}"; do
            find AppDir/.junest/usr/bin -type f -name "${bin}"
        done
        for lib in "${LIBS[@]}"; do
            find AppDir/.junest/usr/lib -type f -name "${lib}.so*"
        done
        if [ "$INCLUDE_SHARESAVED_ARCHIVE" = "true" ]; then
            for share in $SHARESAVED; do
                find "AppDir/.junest/usr/share/${share}" -type f
            done
        fi
    } > file_path.txt
    tar -c -I "xz -6" -f AppDir_x86_64.tar.xz -h --transform 's|/\.junest/|/|' -T file_path.txt
    rm file_path.txt
fi

# ─── Create Appstream metadata ─────────────────────────────────────────────────────────────────────
mkdir -p AppDir/.junest/usr/share/metainfo
cat > AppDir/.junest/usr/share/metainfo/app.grayjay.grayjay.appdata.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>app.grayjay.grayjay</id>
  <launchable type="desktop-id">app.grayjay.grayjay.desktop</launchable>
  <url type="bugtracker">https://github.com/futo-org/Grayjay.Desktop/issues</url>
  <url type="homepage">https://grayjay.app/desktop/</url>
  <url type="vcs-browser">https://gitlab.futo.org/videostreaming/Grayjay.Desktop</url>
  <name>GrayJay</name>
  <summary>Universal media aggregator</summary>
  <metadata_license>CC-BY-SA-4.0</metadata_license>
  <project_license>LicenseRef-Source-First-1.1=https://github.com/futo-org/Grayjay.Desktop/blob/master/LICENSE.md</project_license>
  <description>
    <p>
      Grayjay is a multi-platform media application that allows you to watch content from multiple
      platforms in a single application.
    </p>
    <p>
      Grayjay enables you to create and watch video content in your own terms by allowing you to
      follow creators, not platforms, giving you full ownership and control over what you watch.
    </p>
    <p>
      Add or import video sources including: YouTube, PeerTube, Odysee, Nebula, Patreon, and more
      (via custom plugins)
    </p>
    <p>
      The universal feed enables you to access all of your subscriptions and content in one place,
      storing your history and playlists entirely locally and allowing you to download content for
      offline playback.
    </p>
  </description>
  <categories>
    <category>Network</category>
    <category>Video</category>
    <category>AudioVideo</category>
  </categories>
  <developer id="org.futo">
    <name>FUTO</name>
  </developer>
  <content_rating type="oars-1.0">
    <content_attribute id="violence-cartoon">intense</content_attribute>
    <content_attribute id="violence-fantasy">intense</content_attribute>
    <content_attribute id="violence-realistic">intense</content_attribute>
    <content_attribute id="violence-bloodshed">intense</content_attribute>
    <content_attribute id="drugs-alcohol">moderate</content_attribute>
    <content_attribute id="drugs-narcotics">moderate</content_attribute>
    <content_attribute id="drugs-tobacco">moderate</content_attribute>
    <content_attribute id="sex-nudity">intense</content_attribute>
    <content_attribute id="sex-themes">intense</content_attribute>
    <content_attribute id="language-profanity">intense</content_attribute>
    <content_attribute id="language-humor">intense</content_attribute>
    <content_attribute id="language-discrimination">intense</content_attribute>
    <content_attribute id="social-chat">intense</content_attribute>
    <content_attribute id="social-info">moderate</content_attribute>
    <content_attribute id="money-advertising">intense</content_attribute>
    <content_attribute id="money-gambling">intense</content_attribute>
  </content_rating>
  <releases>
    <!-- TODO: add to this section when future versions are released -->
    <release version="20" date="2026-10-13">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/20</url>
    </release>
    <release version="19" date="2026-09-27">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/19</url>
    </release>
    <release version="17" date="2026-02-15">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/17</url>
    </release>
    <release version="16" date="2026-02-04">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/16</url>
    </release>
    <release version="15" date="2026-01-30">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/15</url>
    </release>
    <release version="14" date="2026-01-26">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/14</url>
    </release>
    <release version="13" date="2026-01-01">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/13</url>
    </release>
    <release version="12" date="2025-10-28">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/12</url>
    </release>
    <release version="11" date="2025-10-15">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/11</url>
    </release>
    <release version="10" date="2025-10-01">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/10</url>
    </release>
    <release version="9" date="2025-07-14">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/9</url>
    </release>
    <release version="8" date="2025-06-10">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/8</url>
    </release>
    <release version="7" date="2025-05-06">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/7</url>
    </release>
    <release version="6" date="2025-05-03">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/6</url>
    </release>
    <release version="5" date="2025-01-09">
      <url type="details">https://github.com/futo-org/Grayjay.Desktop/releases/tag/5</url>
    </release>
  </releases>
  <screenshots>
    <screenshot type="default">
      <caption>home screen</caption>
      <image>https://gitlab.futo.org/videostreaming/Grayjay.Desktop/-/raw/b2d0cb4507bee98eb976c2894b9d3005c775441c/imgs/home.PNG</image>
    </screenshot>
    <screenshot>
     <caption>sources</caption>
      <image>https://gitlab.futo.org/videostreaming/Grayjay.Desktop/-/raw/b2d0cb4507bee98eb976c2894b9d3005c775441c/imgs/sources.PNG</image>
    </screenshot>
    <screenshot>
     <caption>channel</caption>
      <image>https://gitlab.futo.org/videostreaming/Grayjay.Desktop/-/raw/b2d0cb4507bee98eb976c2894b9d3005c775441c/imgs/channel.PNG</image>
    </screenshot>
    <screenshot>
      <caption>detail</caption>
      <image>https://gitlab.futo.org/videostreaming/Grayjay.Desktop/-/raw/b2d0cb4507bee98eb976c2894b9d3005c775441c/imgs/detail1.PNG</image>
    </screenshot>
    <screenshot>
      <caption>download</caption>
      <image>https://gitlab.futo.org/videostreaming/Grayjay.Desktop/-/raw/b2d0cb4507bee98eb976c2894b9d3005c775441c/imgs/download.PNG</image>
    </screenshot>
  </screenshots>
</component>
EOF

##########################################################################################################################################################
#    CREATE THE APPIMAGE
##########################################################################################################################################################

if test -f ./*.AppImage; then rm -Rf ./*archimage*.AppImage; fi

APPNAME=$(cat AppDir/*.desktop | grep '^Name=' | head -1 | cut -c 6- | sed 's/ /-/g')

echo "$VERSION" > ./version

RUNTIME="runtime-x86_64"
if [ ! -f "$RUNTIME" ]; then
    curl -fLo "$RUNTIME" https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
fi

_appimagetool() {
    if ! command -v appimagetool 1>/dev/null; then
        if [ ! -f ./appimagetool-x86_64 ]; then
            echo " Downloading appimagetool..." && curl -#Lo appimagetool-x86_64 https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage && chmod a+x ./appimagetool-x86_64 || exit 1
        fi
        ./appimagetool-x86_64 "$@"
    else
        appimagetool-x86_64 "$@"
    fi
}

ARCH=x86_64 _appimagetool --runtime-file "$RUNTIME" -n AppDir "$APPNAME"_"$VERSION"-"$ARCHIMAGE_VERSION"-x86_64.AppImage
