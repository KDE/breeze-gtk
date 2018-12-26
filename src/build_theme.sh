#!/bin/sh
# Usage: build_theme.sh [<colorscheme> [<install-target>]]
# If <colorscheme> is unset or empty, colors from kdeglobals are used
# If <install-target> is unset or empty, the theme is installed into ~/.local/share/themes/<theme name>
set -e

# Usage: create_folders <target-directory>
create_folders () {
  for j in gtk-2.0 gtk-3.18 gtk-3.20; do
    if ! [ -d "$1/$j" ]; then
        mkdir -p "$1/$j"
    fi
  done 
}

# Usage: build_sass <source-directory> <target-directory> <include-directory>
build_sass() {
  if command -v sassc >/dev/null 2>&1; then
      sassc -I "$3" "$1" "$2"
  else
      sass -I "$3" --cache-location /tmp/sass-cache "$1" "$2"
  fi
}

# Usage: install_theme <theme-directory> <theme-name> <install-target-dir>
# If <insall-target-dir> is unset empty, install to $HOME/.local/share/themes/$THEME_NAME
install_theme () {
  THEME_INSTALL_TARGET="$3"
  if [ -z "${THEME_INSTALL_TARGET}" ]; then
    THEME_INSTALL_TARGET="${HOME}/.local/share/themes/$2"
  fi
  mkdir -p "${THEME_INSTALL_TARGET}"
  for dir in assets gtk-2.0 gtk-3.18 gtk-3.20; do
    if [ -d "${THEME_INSTALL_TARGET}/$dir" ]; then
      rm -rf "${THEME_INSTALL_TARGET:?}/$dir"
    fi
    mv -f "$1/$dir" "${THEME_INSTALL_TARGET}"
  done
  rmdir "$1"
}

# Usage render_theme <colorscheme> <theme-name> <theme-install-target>
render_theme () {
  THEME_BUILD_DIR="$(mktemp -d)"
  create_folders "${THEME_BUILD_DIR}"
  cp -R gtk2/* "${THEME_BUILD_DIR}/gtk-2.0/"
  python3 render_assets.py -c "$1" -a "${THEME_BUILD_DIR}/assets" \
    -g "${THEME_BUILD_DIR}/gtk-2.0" -G "${THEME_BUILD_DIR}"
  build_sass gtk318/gtk.scss "${THEME_BUILD_DIR}/gtk-3.18/gtk.css" "${THEME_BUILD_DIR}"
  build_sass gtk320/gtk.scss "${THEME_BUILD_DIR}/gtk-3.20/gtk.css" "${THEME_BUILD_DIR}"
  rm -f "${THEME_BUILD_DIR}/_global.scss"
  install_theme "${THEME_BUILD_DIR}" "$2" "$3"
}

# TODO : add --help and improve parameter parsing

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
