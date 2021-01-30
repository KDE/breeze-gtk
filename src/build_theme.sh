#!/bin/sh
set -e

# Usage: create_folders <target-directory>
create_folders () {
  for j in gtk-2.0 gtk-3.0 gtk-4.0; do
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
# If <install-target-dir> is unset or empty, install to $HOME/.local/share/themes/$THEME_NAME
install_theme () {
  THEME_INSTALL_TARGET="$3"
  if [ -z "${THEME_INSTALL_TARGET}" ]; then
    THEME_INSTALL_TARGET="${HOME}/.local/share/themes/$2"
  fi
  echo "Installing into ${THEME_INSTALL_TARGET}"
  mkdir -p "${THEME_INSTALL_TARGET}"
  for dir in assets gtk-2.0 gtk-3.0 gtk-4.0; do
    if [ -d "${THEME_INSTALL_TARGET}/$dir" ]; then
      rm -rf "${THEME_INSTALL_TARGET:?}/$dir"
    fi
    mv -f "$1/$dir" "${THEME_INSTALL_TARGET}"
  done
  rmdir "$1"
}

# Usage render_theme <colorscheme> <theme-name> <theme-install-target> <colorschemebase>
render_theme () {
  THEME_BUILD_DIR="$(mktemp -d)"
  create_folders "${THEME_BUILD_DIR}"
  cp -R gtk2/* "${THEME_BUILD_DIR}/gtk-2.0/"
  python3 render_assets.py -c "$1" -a "${THEME_BUILD_DIR}/assets" \
    -g "${THEME_BUILD_DIR}/gtk-2.0" -G "${THEME_BUILD_DIR}" -b "$4"
  build_sass gtk3/gtk.scss "${THEME_BUILD_DIR}/gtk-3.0/gtk.css" "${THEME_BUILD_DIR}"
  build_sass gtk4/gtk.scss "${THEME_BUILD_DIR}/gtk-4.0/gtk.css" "${THEME_BUILD_DIR}"
  rm -f "${THEME_BUILD_DIR}/_global.scss"
  install_theme "${THEME_BUILD_DIR}" "$2" "$3"
}

COLOR_SCHEME=""
INSTALL_TARGET=""
THEME_NAME=""
COLOR_SCHEME_ROOT="/usr/share/color-schemes"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "$0: build Breeze theme"
      echo "Usage: $0 [-c COLOR_SCHEME] [-r COLOR_SCHEME_ROOT] [-t TARGET_DIRECTORY]"
      echo
      echo "Arguments:"
      echo "  -h, --help           show this help"
      echo "  -c COLOR_SCHEME      use color scheme with name COLOR_SCHEME. If unset or"
      echo "                       empty, the value from ~/.config/kdeglobals is used"
      echo "  -r COLOR_SCHEME_ROOT The base path of all color schemes or"
      echo "                       /usr/share/color-schemes if unset"
      echo "  -t TARGET_DIRECTORY  the directory to install the color scheme. If unset or"
      echo "                       empty, it is installed into"
      echo "                       ~/.local/share/themes/THEME_NAME"
      exit 0
    ;;
    -c)
      shift
      COLOR_SCHEME="$1"
    ;;
    -t)
      shift
      INSTALL_TARGET="$1"
    ;;
    -r)
      shift
      COLOR_SCHEME_ROOT="$1"
    ;;
  esac
  shift
done

if [ -z "${COLOR_SCHEME}" ]; then
  THEME_NAME="Breeze"
  if [ -f "${HOME}/.config/kdeglobals" ]; then
    COLOR_SCHEME="${HOME}/.config/kdeglobals"
  else
    echo "${HOME}/.config/kdeglobals not found, using defaults"
    COLOR_SCHEME="${COLOR_SCHEME_ROOT}/Breeze.colors"
  fi
else
  THEME_NAME="${COLOR_SCHEME}"
  if [ -f "${COLOR_SCHEME_ROOT}/${COLOR_SCHEME}.colors" ]; then
    COLOR_SCHEME="${COLOR_SCHEME_ROOT}/${COLOR_SCHEME}.colors"
  elif [ -f "${HOME}/.local/share/color-schemes/${COLOR_SCHEME}.colors" ]; then
    COLOR_SCHEME="${HOME}/.local/share/color-schemes/${COLOR_SCHEME}.colors"
  else
    echo "colorscheme ${COLOR_SCHEME} not found"
    exit 1
  fi
fi

render_theme "${COLOR_SCHEME}" "${THEME_NAME}" "${INSTALL_TARGET}" "${COLOR_SCHEME_ROOT}/Breeze.colors"
[ -z "${INSTALL_TARGET}" ] && INSTALL_TARGET="${HOME}/.local/share/themes/${THEME_NAME}"
cp -r assets/ "${INSTALL_TARGET}"
