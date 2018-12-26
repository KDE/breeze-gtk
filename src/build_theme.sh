#!/bin/sh
# Usage: build_theme.sh [<colorscheme> [<install-target>]]
# If <colorscheme> is unset or empty, colors from kdeglobals are used
# If <install-target> is unset or empty, the theme is installed into ~/.local/share/themes/<theme name>
set -e

create_folders () {
  for j in gtk-2.0 gtk-3.18 gtk-3.20; do
    if ! [ -d "$1/$j" ]; then
        mkdir -p "$1/$j"
    fi
  done 
}

build_sass() {
  if command -v sassc >/dev/null 2>&1; then
      sassc "$1" "$2"
  else
      sass --cache-location /tmp/sass-cache "$1" "$2"
  fi
}

install_theme () {
  COLOR_SCHEME="$1"
  INSTALL_TARGET="$2"
  if [ -z "$INSTALL_TARGET" ]; then
    INSTALL_TARGET="$HOME/.local/share/themes/$COLOR_SCHEME"
  fi
  mkdir -p "$INSTALL_TARGET"
  for dir in assets gtk-2.0 gtk-3.18 gtk-3.20; do
    if [ -d "$INSTALL_TARGET/$dir" ]; then
      rm -rf "${INSTALL_TARGET:?}/$dir"
    fi
    mv -f "$COLOR_SCHEME/$dir" "$INSTALL_TARGET"
  done
  rmdir "$COLOR_SCHEME"
}

render_theme () {
  create_folders "$2"
  python3 render_assets.py "$1" "$2/assets"
  build_sass gtk318/gtk.scss "$2/gtk-3.18/gtk.css"
  build_sass gtk320/gtk.scss "$2/gtk-3.20/gtk.css"
  cp -R gtk2/* "$2/gtk-2.0/"
  install_theme "$2" "$3"
}

COLOR_SCHEME="$1"
INSTALL_TARGET="$2"

if [ -z "$COLOR_SCHEME" ]; then
  if [ -f "$HOME/.config/kdeglobals" ]; then
    render_theme "$HOME/.config/kdeglobals" Breeze "$INSTALL_TARGET"
  else
    echo "$HOME/.config/kdeglobals not found, using defaults"
    render_theme /usr/share/color-schemes/Breeze.colors Breeze "$INSTALL_TARGET"
  fi
else
  if [ -f "/usr/share/color-schemes/$COLOR_SCHEME.colors" ]; then
    render_theme "/usr/share/color-schemes/$COLOR_SCHEME.colors" "$COLOR_SCHEME" "$INSTALL_TARGET"
  elif [ -f "$HOME/.local/share/color-schemes/$COLOR_SCHEME.colors" ]; then
    render_theme "$HOME/.local/share/color-schemes/$COLOR_SCHEME.colors" "$COLOR_SCHEME" "$INSTALL_TARGET"
  else
    echo "colorscheme $COLOR_SCHEME not found"
  fi
fi
        
