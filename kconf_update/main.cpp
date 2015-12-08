/*
 Copyright 2014 Jonathan Riddell <jriddell@ubuntu.com>

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either 
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public 
 License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

// Wee program to be run at login by kconf_update
// checks if gtk theme is set
// if not or if it is set to oxygen, update to new theme which matches breeze theme

#include <QCoreApplication>
#include <QStandardPaths>
#include <QDebug>
#include <QFile>
#include <QLoggingCategory>
#include <QSettings>
#include <QDir>

Q_DECLARE_LOGGING_CATEGORY(GTKBREEZE)
Q_LOGGING_CATEGORY(GTKBREEZE, "gtkbreeze")

/*
 * returns a path to the installed gtk if it can be found
 * themeName: gtk theme
 * settingsFile: a file installed with the theme to set default options
 */
QString isGtkThemeInstalled(QString themeName, QString settingsFile)
{
    foreach (const QString& themesDir, QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, "themes", QStandardPaths::LocateDirectory)) {
        if (QFile::exists(themesDir + QDir::separator() + themeName + QDir::separator() + settingsFile)) {
            return themesDir + "/" + themeName;
        }
    }
    return 0;
}

/*
 * Check if gtk theme is already set to oxygen or Orion, if it is then we want to upgrade to the breeze theme
 * gtkSettingsFile: filename to use
 * settingsKey: ini group to read from
 * returns: full path to settings file
 */
bool isGtkThemeSetToOldTheme(QString gtkSettingsFile, QString settingsKey)
{
    QString home = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first();
    QString gtkSettingsPath;
    if (!gtkSettingsFile.startsWith(home)) {
        gtkSettingsPath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first() + QDir::separator() + gtkSettingsFile;
    } else {
        gtkSettingsPath = gtkSettingsFile;
    }
    qCDebug(GTKBREEZE) << "looking for" << gtkSettingsPath;
    if (QFile::exists(gtkSettingsPath)) {
        qCDebug(GTKBREEZE) << "found settings file" << gtkSettingsPath;
        QSettings gtkrcSettings(gtkSettingsPath, QSettings::IniFormat);
        if (!settingsKey.isNull()) {
            gtkrcSettings.beginGroup(settingsKey);
        }
        //if it is set to Oxygen or Orion then we want to upgrade it to Breeze
        if (gtkrcSettings.value("gtk-theme-name") == QLatin1String("oxygen-gtk") || gtkrcSettings.value("gtk-theme-name") == QLatin1String("Orion")) {
            qCDebug(GTKBREEZE) << "using oxygen or orion " << gtkrcSettings.value("gtk-theme-name");
            return true;
        } else {
            return false;
        }
    }
    //if it doesn't exist then we also want to upgrade it
    return true;
}

/*
 * Set gtk2 theme if no theme is set or if oxygen is set and gtk theme is installed
 */
int setGtk2()
{
    const QString gtk2Theme = QStringLiteral("Breeze");
    const QString gtkrc2path = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first() + QDir::separator() + QStringLiteral(".gtkrc-2.0");
    const QString gtk2ThemeSettings = QStringLiteral("gtk-2.0/gtkrc"); // system installed file to check for

    const QString gtkThemeDirectory = isGtkThemeInstalled(gtk2Theme, gtk2ThemeSettings);

    if (gtkThemeDirectory == 0) {
        qCDebug(GTKBREEZE) << "Breeze GTK 3 not found, quitting";
        return 0;
    }
    qCDebug(GTKBREEZE) << "found gtktheme: " << gtkThemeDirectory;

    bool needsUpdate = isGtkThemeSetToOldTheme(gtkrc2path, QString());
    if (needsUpdate == false) {
        qCDebug(GTKBREEZE) << "gtkrc2 already exists and is not using oxygen or orion, quitting";
        return 0;
    }

    qCDebug(GTKBREEZE) << "no gtkrc2 file or oxygen/orion being used, setting to new theme";
    QFile gtkrc2writer(gtkrc2path);
    bool opened = gtkrc2writer.open(QIODevice::WriteOnly | QIODevice::Text);
    if (!opened) {
        qCWarning(GTKBREEZE) << "failed to open " << gtkrc2path;
        return 1;
    }
    QTextStream out(&gtkrc2writer);
    out << QStringLiteral("include \"") << gtkThemeDirectory << QStringLiteral("/gtk-2.0/gtkrc\"\n");
    out << QStringLiteral("style \"user-font\"\n");
    out << QStringLiteral("{\n");
    out << QStringLiteral("    font_name=\"Noto Sans Regular\"\n");
    out << QStringLiteral("}\n");
    out << QStringLiteral("widget_class \"*\" style \"user-font\"\n");
    out << QStringLiteral("gtk-font-name=\"Noto Sans Regular 10\"\n"); // matches plasma-workspace:startkde/startkde.cmake
    out << QStringLiteral("gtk-theme-name=\"Breeze\"\n");
    out << QStringLiteral("gtk-icon-theme-name=\"breeze\"\n");
    out << QStringLiteral("gtk-fallback-icon-theme=\"gnome\"\n");
    out << QStringLiteral("gtk-toolbar-style=GTK_TOOLBAR_ICONS\n");
    out << QStringLiteral("gtk-menu-images=1\n");
    out << QStringLiteral("gtk-button-images=1\n");
    qCDebug(GTKBREEZE) << "gtk2rc written";
    return 0;
}

/*
 * Set gtk3 theme if no theme is set or if oxygen is set and gtk theme is installed
 */
int setGtk3()
{
    const QString gtk3Theme = QStringLiteral("Breeze");
    const QString gtk3ThemeSettings = QStringLiteral("gtk-3.0/gtk.css"); // check for installed /usr/share/themes/Breeze/gtk-3.0/gtk.css

    const QString gtkThemeDirectory = isGtkThemeInstalled(gtk3Theme, gtk3ThemeSettings);
    if (gtkThemeDirectory == 0) {
        qCDebug(GTKBREEZE) << "not found, quitting";
        return 0;
    }
    qCDebug(GTKBREEZE) << "found gtk3theme:" << gtkThemeDirectory;
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    QString gtkrc3path = configPath + "/gtk-3.0/settings.ini";
    bool needsUpdate = isGtkThemeSetToOldTheme(gtkrc3path, "Settings");
    if ( !needsUpdate ) {
        qCDebug(GTKBREEZE) << "gtkrc3 already exists and is not using oxygen/orion, quitting";
        return 0;
    }
    QDir dir = QFileInfo(gtkrc3path).dir();
    dir.mkpath(dir.path());

    qCDebug(GTKBREEZE) << "no gtkrc3 file or oxygen/orion being used, setting to new theme";
    QFile gtkrc3writer(gtkrc3path);
    bool opened = gtkrc3writer.open(QIODevice::WriteOnly | QIODevice::Text);
    if (!opened) {
        qCWarning(GTKBREEZE) << "failed to open " << gtkrc3path;
        return 1;
    }
    QTextStream out(&gtkrc3writer);
    out << QStringLiteral("[Settings]\n");
    out << QStringLiteral("gtk-font-name=Noto Sans 10\n"); // matches plasma-workspace:startkde/startkde.cmake
    out << QStringLiteral("gtk-theme-name=")+gtk3Theme+QStringLiteral("\n");
    out << QStringLiteral("gtk-icon-theme-name=breeze\n");
    out << QStringLiteral("gtk-fallback-icon-theme=gnome\n");
    out << QStringLiteral("gtk-toolbar-style=GTK_TOOLBAR_ICONS\n");
    out << QStringLiteral("gtk-menu-images=1\n");
    out << QStringLiteral("gtk-button-images=1\n");
    qCDebug(GTKBREEZE) << "gtk3rc written";

    return 0;
}

int main(/*int argc, char **argv*/)
{
    QString home = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first();
    int resultGTK2 = 0;
    int resultGTK3 = 0;
    resultGTK2 = setGtk2();
    resultGTK3 = setGtk3();

    return resultGTK2 | resultGTK3;
}
