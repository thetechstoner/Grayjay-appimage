# Grayjay AppImage

Portable [ArchImage](https://github.com/ivan-hc/ArchImage) build of [Grayjay Desktop](https://grayjay.app/desktop/) — a privacy-respecting, multi-platform media client for YouTube, Twitch, Rumble, Spotify and more.

Built on top of [JuNest](https://github.com/fsquillace/junest), a lightweight Arch Linux container that runs without root on any Linux distribution.

## Features

- **Multi-platform** — watch content from YouTube, Twitch, Rumble, Spotify, PeerTube and more in a single unified feed
- **Privacy-first** — subscriptions, playlists, history and downloads are stored locally on your device
- **Ad-free** — bypasses platform advertisements
- **Portable** — no system installation required; just download and run
- **Works on any distro** — bundles its own Arch Linux userland via JuNest

## Requirements

- **Architecture:** x86_64
- **Linux** with unrestricted user namespaces (required by JuNest's BubbleWrap sandbox)
> If your distro blocks unprivileged user namespaces, enable them via sysctl:
> ```
> sudo sysctl -w kernel.unprivileged_userns_clone=1
> ```

## Install

1. Download the latest `.AppImage` from the [Releases](../../releases) page.
2. Make it executable:
   ```bash
   chmod +x Grayjay_*.AppImage
3. Run:
    ```bash
    ./Grayjay_*.AppImage
 > ```
 > On first launch the app data is copied to `~/.local/share/grayjay/`.
 > Subsequent runs use that directory directly, so updates to the AppImage won't wipe your data.

## Building from Source
```bash
# Prerequisites:
# bash`, `curl`, `wget`, `unzip`, & 64-bit Linux with user namespaces
# Clone the repo
git clone https://github.com/thetechstoner/Grayjay-appimage.git
cd Grayjay-appimage
# Make it executable
chmod +x grayjay-junest.sh
# Run the build script
./grayjay-junest.sh
```
>```
> Downloads and sets up JuNest inside a temporary Arch Linux environment
> Installs `grayjay-bin` from the AUR via `yay`
> Assembles the AppDir, prunes unnecessary files, and generates the `.desktop` entry
> Packages everything into a Type 2 AppImage using `appimagetool`
> The resulting file is named Grayjay_<version>-<archimage_version>-x64.AppImage
