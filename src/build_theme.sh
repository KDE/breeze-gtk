#!/bin/bash

create_folders () {
  FOLDERS=(gtk-2.0 gtk-3.0 gtk-3.18 gtk-3.20)
  for j in "${FOLDERS[@]}"
    do
      if ! [ -d "$1/$j" ]
        then mkdir -p "$1/$j";
      fi
  done 
}

build_sass() {
    if command -v sassc &>/dev/null
    then
      sassc "$1" "$2"
    else
      sass --cache-location /tmp/sass-cache "$1" "$2"
    fi
}

render_theme () {
  python3 render_assets.py "$1"
  create_folders "$2"
  build_sass gtk316/gtk.scss "$2/gtk-3.0/gtk.css"
  build_sass gtk318/gtk.scss "$2/gtk-3.18/gtk.css"
  build_sass gtk320/gtk.scss "$2/gtk-3.20/gtk.css"
  mv assets "$2/"
  cp -R gtk2/* "$2/gtk-2.0/"
  if [ -d "$HOME/.local/share/themes/$2" ]
    then rm -rf "$HOME/.local/share/themes/$2";
  fi
  mv -f "$2" "$HOME/.local/share/themes/"
}

if [ -z "$1" ]
then
  if [ -f "$HOME/.config/kdeglobals" ]
  then
    render_theme "$HOME/.config/kdeglobals" Breeze
  else
    echo "$HOME/.config/kdeglobals not found, using defaults"
    render_theme /usr/share/color-schemes/Breeze.colors Breeze
  fi
else
  if [ -f "/usr/share/color-schemes/$1.colors" ]
  then
    render_theme "/usr/share/color-schemes/$1.colors" "$1"
  elif [ -f "$HOME/.local/share/color-schemes/$1.colors" ]
  then
    render_theme "$HOME/.local/share/color-schemes/$1.colors" "$1"
  else
    echo "colorscheme $1 not found"
  fi
fi
        
