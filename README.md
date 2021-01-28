# Breeze GTK

A GTK3 and GTK4 theme following the look and feel of KDE's Breeze.

# Requirements

- GTK3 or GTK4

# Install instructions
If your distribution doesn't provide a package, you can install the theme system-wide by copying it to the appropriate directory, usually "/usr/share/themes".
```
find Breeze* -type f -exec install -Dm644 '{}' "$pkgdir/usr/share/themes/{}" \;
```

To install only for the current user, copy the files to "~/.themes".

To set the theme in Plasma 5, install kde-gtk-config and use System Settings > Application Style > GNOME Application Style.
Also make sure to disable "apply colors to non-Qt applications" in System Settings > Colors > Options.
