#!/bin/sh

create_folders () {
  for j in gtk-2.0 gtk-3.0 gtk-3.20; do
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

render_theme () {
  python3 render_assets.py "$1"
  create_folders "$2"
  build_sass gtk318/gtk.scss "$2/gtk-3.0/gtk.css"
  build_sass gtk320/gtk.scss "$2/gtk-3.20/gtk.css"
  mv assets "$2/"
  cp -R gtk2/* "$2/gtk-2.0/"
  if [ -d "$HOME/.local/share/themes/$2" ]; then
    rm -rf "$HOME/.local/share/themes/$2";
  fi
  mv -f "$2" "$HOME/.local/share/themes/"
}

COLOR_SCHEME="$1"

if [ -z "$COLOR_SCHEME" ]; then
  if [ -f "$HOME/.config/kdeglobals" ]; then
    render_theme "$HOME/.config/kdeglobals" Breeze
  else
    echo "$HOME/.config/kdeglobals not found, using defaults"
    render_theme /usr/share/color-schemes/Breeze.colors Breeze
  fi
else
  if [ -f "/usr/share/color-schemes/$COLOR_SCHEME.colors" ]; then
    render_theme "/usr/share/color-schemes/$COLOR_SCHEME.colors" "$COLOR_SCHEME"
  elif [ -f "$HOME/.local/share/color-schemes/$COLOR_SCHEME.colors" ]; then
    render_theme "$HOME/.local/share/color-schemes/$COLOR_SCHEME.colors" "$COLOR_SCHEME"
  else
    echo "colorscheme $COLOR_SCHEME not found"
  fi
fi
        
