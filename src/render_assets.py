#!/usr/bin/env python3
import cairo
import colorsys
from math import pi
import os
import errno
import sys
import re
import argparse


def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except FileExistsError as exception:
        pass
    pass


class ReadKdeGlobals():
    def __init__(self, base_file_name):
        self._colors = {}
        self._colors = self.read_globals(base_file_name)

    def read_globals(self, filename):
        with open(filename, 'r', encoding="utf-8") as _kde:
            for widget in ['Disabled', 'Inactive', 'Button', 'Selection',
                           'Tooltip', 'View', 'Window', 'WM']:
                for line in _kde:
                    if line.strip().split(':')[-1].strip('[]') == widget:
                        break
                for line in _kde:
                    if line == '\n':
                        break
                    key = '{0}{1}'.format(widget, line.strip().split('=')[0])
                    value = line.strip().split('=')[1]
                    if value == '':
                        continue
                    self._colors[key] = value
        return self._colors


class Color(object):
    def __init__(self, colordict, name, name2=None, amount=0):
        color = colordict[name]
        self.colordict = colordict

        r = float(color.split(',')[0])
        g = float(color.split(',')[1])
        b = float(color.split(',')[2])
        if name2 is not None:
            color2 = colordict[name2]
            r = r * amount + float(color2.split(',')[0]) * (1 - amount)
            g = g * amount + float(color2.split(',')[1]) * (1 - amount)
            b = b * amount + float(color2.split(',')[2]) * (1 - amount)

        self.rgb255 = (int(r), int(g), int(b))
        self.rgb = (r/255, g/255, b/255)
        self.html = '#%02x%02x%02x' % self.rgb255
        self.insensitive = self._color_effect(
            self._intensity_effect(self.rgb, 'Disabled'), 'Disabled')
        self.insensitive_alpha = self._contrast_effect(self.rgb, 'Disabled')

        if self.colordict['InactiveEnable'] == 'false':
            self.inactive = self.rgb
            self.inactive_alpha = 1.0
        else:
            self.inactive = self._color_effect(
                self._intensity_effect(self.rgb, 'Inactive'), 'Inactive')
            self.inactive_alpha = self._contrast_effect(self.rgb, 'Inactive')
        self.inactive_insensitive = self._color_effect(
            self._intensity_effect(self.inactive, 'Disabled'), 'Disabled')
        self.inactive_insensitive_alpha = max(
            self.inactive_alpha - (1 - self.insensitive_alpha), 0)

    def _mix(self, color, mix_color, amount):
        r = color[0] * amount + mix_color[0] * (1 - amount)
        g = color[1] * amount + mix_color[1] * (1 - amount)
        b = color[2] * amount + mix_color[2] * (1 - amount)
        return (r, g, b)

    def _lighter(self, color, amount):
        h, s, v = colorsys.rgb_to_hsv(color[0], color[1], color[2])
        v = min((1+amount)*v, 1)
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        return (r, g, b)

    def _darker(self, color, amount):
        h, s, v = colorsys.rgb_to_hsv(color[0], color[1], color[2])
        if amount == -1:
            v = 1
        else:
            v = min(v/(1+amount), 1)
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        return (r, g, b)

    def _desaturate(self, color, amount):
        h, s, v = colorsys.rgb_to_hsv(color[0], color[1], color[2])
        s = min(s * (1 - amount), 1)
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        return (r, g, b)

    def _intensity_effect(self, color, state):
        effect = int(self.colordict[state + 'IntensityEffect'])
        amount = float(self.colordict[state + 'IntensityAmount'])
        if effect == 0:
            (r, g, b) = color
        elif effect == 1:
            if amount >= 0:
                (r, g, b) = self._mix((1.0, 1.0, 1.0), color, amount)
            else:
                (r, g, b) = self._mix((0.0, 0.0, 0.0), color, amount)
        elif effect == 2:
            (r, g, b) = self._darker(color, amount)
        elif effect == 3:
            (r, g, b) = self._lighter(color, amount)
        return (r, g, b)

    def _color_effect(self, color, state):
        effect = int(self.colordict[state + 'ColorEffect'])
        amount = float(self.colordict[state + 'ColorAmount'])
        effect_color = self.colordict[state + 'Color']
        effect_color = (float(effect_color.split(',')[0])/255,
                        float(effect_color.split(',')[1])/255,
                        float(effect_color.split(',')[2])/255)
        if effect == 0:
            (r, g, b) = color
        elif effect == 1:
            (r, g, b) = self._desaturate(color, amount)
        else:
            (r, g, b) = self._mix(effect_color, color, amount)
        return (r, g, b)

    def _contrast_effect(self, color, state):
        effect = int(self.colordict[state + 'ContrastEffect'])
        amount = float(self.colordict[state + 'ContrastAmount'])
        if effect == 0:
            return 1.0
        else:
            return 1.0 - amount

    def lighten_color(self, amount):
        h, s, v = colorsys.rgb_to_hsv(self.rgb[0], self.rgb[1], self.rgb[2])
        v = (1+amount)*v
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        self.rgb = (r, g, b)
        self.rgb255 = (int(r*255), int(g*255), int(b*255))

    def gradient(self, state='', alpha=1.0):
        if state == 'active':
            stop1 = self._lighter(self.rgb, 0.03)
            stop2 = self._darker(self.rgb, 0.10)
            linear = cairo.LinearGradient(1, 1, 1, 19)
            linear.add_color_stop_rgba(
                0.0, stop1[0], stop1[1], stop1[2], alpha)
            linear.add_color_stop_rgba(
                1.0, stop2[0], stop2[1], stop2[2], alpha)
        else:
            stop1 = self._lighter(self.rgb, 0.01)
            stop2 = self._darker(self.rgb, 0.03)
            linear = cairo.LinearGradient(1, 1, 1, 19)
            linear.add_color_stop_rgba(
                0.0, stop1[0], stop1[1], stop1[2], alpha)
            linear.add_color_stop_rgba(
                1.0, stop2[0], stop2[1], stop2[2], alpha)
        return linear


class Assets(object):
    def __init__(self, width, height, scl=1, rotation=0, filename='png'):
        self.w = width
        self.h = height
        if filename == 'png':
            self.surface = cairo.ImageSurface(
                cairo.FORMAT_ARGB32, scl*width, scl*height)
        else:
            self.surface = cairo.SVGSurface(os.path.join(
                assets_path, filename), scl*width, scl*height)
        cr = self.cr = cairo.Context(self.surface)
        if rotation != 0:
            cr.translate(scl*width/2, scl*height/2)
            cr.rotate(rotation*pi/2)
            cr.translate(-scl*width/2, -scl*height/2)
        cr.scale(scl, scl)

    def background(self, color):
        self.cr.rectangle(0, 0, self.w, self.h)
        self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.fill()

    def line(self, color, x, y, width, height):
        self.cr.rectangle(x, y, width, height)
        self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.fill()

    def rounded_rectancle(self, color, width, height, x, y, radius, alpha=1.0,
                          gradient=False):
        self.cr.new_sub_path()
        self.cr.arc(x + width - radius, y + radius, radius, -pi/2, 0)
        self.cr.arc(x + width - radius, y + height - radius, radius, 0, pi/2)
        self.cr.arc(x + radius, y + height - radius, radius, pi/2, pi)
        self.cr.arc(x + radius, y + radius, radius, pi, 3*pi/2)
        self.cr.close_path()
        if gradient:
            self.cr.set_source(color)
        elif color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        elif color == 'shadow':
            self.cr.set_source_rgba(0.0, 0.0, 0.0, 0.15)
        else:
            self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.fill()

    def rounded_triangle(self, color, width, height, x, y, radius, alpha=1.0):
        self.cr.new_sub_path()
        self.cr.move_to(x + width, y)
        self.cr.line_to(x + width, y + height - radius)
        self.cr.arc(x + width - radius, y + height - radius, radius, 0, pi/2)
        self.cr.line_to(x, y + height)
        self.cr.close_path()
        self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.fill()

    def circle(self, color, x, y, radius, alpha=1.0, gradient=False):
        self.cr.new_sub_path()
        self.cr.arc(x, y, radius, 0, 2*pi)
        self.cr.close_path()
        if gradient:
            self.cr.set_source(color)
        elif color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        elif color == 'shadow':
            self.cr.set_source_rgba(0.0, 0.0, 0.0, 0.15)
        else:
            self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.fill()

    def half_circle(self, color, x, y, radius, alpha=1.0):
        self.cr.new_sub_path()
        self.cr.arc(x, y, radius, -pi/4, 3*pi/4)
        self.cr.close_path()
        self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.fill()

    def arrow(self, color, alpha=1.0, shiftx=0, shifty=0):
        self.cr.new_sub_path()
        self.cr.move_to(shiftx + 1, shifty + 8)
        self.cr.line_to(shiftx + 6, shifty + 3)
        self.cr.line_to(shiftx + 11, shifty + 8)
        self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.set_line_width(1.0)
        self.cr.stroke()

    def arrow_small(self, color, alpha=1.0):
        self.cr.new_sub_path()
        self.cr.move_to(1, 6)
        self.cr.line_to(4, 3)
        self.cr.line_to(7, 6)
        self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.set_line_width(1.0)
        self.cr.stroke()

    def tab(self, color, width, height, x, y, radius, alpha=1.0):
        self.cr.move_to(width + x, y)
        self.cr.line_to(width + x, height - radius + y)
        self.cr.arc(width - radius + x, height - radius + y, radius, 0, pi/2)
        self.cr.line_to(radius + x, height + y)
        self.cr.arc(radius + x, height - radius + y, radius, pi/2, pi)
        self.cr.line_to(x, y)
        self.cr.close_path
        if color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        else:
            self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.fill()

    def spinbutton(self, color, width, height, x, y, radius, alpha=1.0):
        self.cr.move_to(width + x, y)
        self.cr.line_to(width + x, height - radius + y)
        self.cr.arc(width - radius + x, height - radius + y, radius, 0, pi/2)
        self.cr.line_to(x, height + y)
        self.cr.line_to(x, y)
        self.cr.close_path()
        if color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        else:
            self.cr.set_source_rgba(color[0], color[1], color[2], alpha)
        self.cr.fill()

    def notebook(self, color, width, height, x, y, radius):
        self.cr.move_to(x, y)
        self.cr.line_to(x + width - radius, y)
        self.cr.arc(x + width - radius, y + radius, radius, -pi/2, 0)
        self.cr.line_to(x + width, y + height-radius)
        self.cr.arc(x + width - radius, y + height - radius, radius, 0, pi/2)
        self.cr.line_to(x + radius, y + height)
        self.cr.arc(x + radius, y + height - radius, radius, pi/2, pi)
        self.cr.close_path()
        self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.fill()

    def minimize(self, color=None):
        self.cr.move_to(4, 7)
        self.cr.line_to(9, 12)
        self.cr.line_to(14, 7)
        if color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        else:
            self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.set_line_width(1.0)
        self.cr.stroke()

    def maximize(self, color=None):
        self.cr.move_to(4, 11)
        self.cr.line_to(9, 6)
        self.cr.line_to(14, 11)
        if color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        else:
            self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.set_line_width(1.0)
        self.cr.stroke()

    def maximize_maximized(self, color=None):
        self.cr.move_to(4.5, 9)
        self.cr.line_to(9, 4.5)
        self.cr.line_to(13.5, 9)
        self.cr.line_to(9, 13.5)
        self.cr.close_path()
        if color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        else:
            self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.set_line_width(1.0)
        self.cr.stroke()

    def close(self, color=None):
        self.cr.move_to(5, 5)
        self.cr.line_to(13, 13)
        self.cr.move_to(13, 5)
        self.cr.line_to(5, 13)
        if color is None:
            self.cr.set_operator(cairo.OPERATOR_CLEAR)
        else:
            self.cr.set_source_rgb(color[0], color[1], color[2])
        self.cr.set_line_width(1.0)
        self.cr.stroke()

    def save(self, filename):
        self.surface.write_to_png(os.path.join(assets_path, filename))

def html(color):
    return '#%02x%02x%02x' % (int(color[0]*255),
                              int(color[1]*255),
                              int(color[2]*255))


def mix(color, mix_color, amount):
    r = color[0] * amount + mix_color[0] * (1 - amount)
    g = color[1] * amount + mix_color[1] * (1 - amount)
    b = color[2] * amount + mix_color[2] * (1 - amount)
    return (r, g, b)
# ___________________________________________________________________________________


parser = argparse.ArgumentParser(
    description='Generates Breeze assets according to the specified color '
                'scheme.')
parser.add_argument('--colorscheme', '-c', action='store',
                    default='/usr/share/color-schemes/Breeze.colors',
                    help='color scheme to use')
parser.add_argument('--basecolorscheme', '-b', action='store',
                    default='/usr/share/color-schemes/Breeze.colors',
                    help='base color scheme')

parser.add_argument('--assets-dir', '-a', action='store',
                    default='assets',
                    help='location of the directory to place assets')
parser.add_argument('--gtk3-scss-dir', '-G', action='store', default='.',
                    help='location of global.scss to define the color '
                         'scheme variables')

args = parser.parse_args()

assets_path = args.assets_dir
make_sure_path_exists(assets_path)

_colors = ReadKdeGlobals(args.basecolorscheme).read_globals(args.colorscheme)

border_color = Color(_colors, 'WindowBackgroundNormal',
                     'WindowForegroundNormal', 0.75)
window_bg = Color(_colors, 'WindowBackgroundNormal')
window_fg = Color(_colors, 'WindowForegroundNormal')
check_color = Color(_colors, 'WindowBackgroundNormal',
                    'WindowForegroundNormal', 0.5)
button_bg = Color(_colors, 'ButtonBackgroundNormal')
button_fg = Color(_colors, 'ButtonForegroundNormal')
button_hover = Color(_colors, 'ButtonDecorationHover')
button_active = Color(_colors, 'ButtonDecorationFocus')
selection_bg = Color(_colors, 'SelectionBackgroundNormal')
selection_fg = Color(_colors, 'SelectionForegroundNormal')
view_bg = Color(_colors, 'ViewBackgroundNormal')
view_fg = Color(_colors, 'ViewForegroundNormal')
view_hover = Color(_colors, 'ViewDecorationHover')
view_active = Color(_colors, 'ViewDecorationFocus')
titlebutton = Color(_colors, 'WMactiveForeground')
titlebutton_active = Color(_colors, 'WMactiveForeground')
closebutton_hover = Color(_colors, 'ViewForegroundNegative')
closebutton_hover.lighten_color(0.5)
closebutton_active = Color(_colors, 'ViewForegroundNegative')
titlebutton_inactive = Color(_colors, 'WMinactiveForeground')
titlebutton_inactive_active = Color(_colors, 'WMinactiveForeground')
tooltip_fg = Color(_colors, 'TooltipForegroundNormal')
tooltip_bg = Color(_colors, 'TooltipBackgroundNormal')

gtk3 = open(os.path.join(args.gtk3_scss_dir, '_global.scss'), 'w')
for key in sorted(_colors):
    if key == 'DisabledColor' or key == 'InactiveColor':
        gtk3.write('${0}:rgb({1});\n'.format(key, _colors[key]))
    elif 'Disabled' in key or 'Inactive' in key:
        gtk3.write('${0}:{1};\n'.format(key, _colors[key]))
    elif re.match('[0-9]+,[0-9]+,[0-9]+', _colors[key]):
        gtk3.write('${0}:rgb({1});\n'.format(key, _colors[key]))
gtk3.close()
