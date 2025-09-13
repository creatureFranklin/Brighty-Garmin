using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
import Toybox.Lang;

class FlashlightView extends WatchUi.View {
    var _colors = prepareColors();
    var _color as Number;
    var _index as Number = 0;
    // var currentColor as Number;
    var _autoOff as AutoOffController;

    function initialize() {
        View.initialize();
        _color = _colors[_index];

        _autoOff = new AutoOffController(method(:setActiveColor), /*vibrateOnExpire=*/ true);
        _autoOff.rearm(_color);
    }

    function onShow() {
        _colors = prepareColors();

        var last = _colors.size() - 1;
        if (_index > last) {
            _index = last;
        }
        if (_index < 0) {
            _index = 0;
        }

        setActiveColor(_index);
    }

    function onUpdate(dc as Graphics.Dc) {
        // 1) Fill background
        var bg = _colors[_index];
        var fg = contrastColor(bg);

        dc.setColor(Graphics.COLOR_WHITE, bg);
        dc.clear();

        // 2) Count geometry
        var w = dc.getWidth(),
            h = dc.getHeight();
        var cx = w / 2.0,
            cy = h / 2.0;
        var rOuter = (w < h ? w : h) / 2.0 - 8.0;

        // 3) hints
        var showHintsFlag = SettingsService.getHintsEnabled();

        if (showHintsFlag == true) {
            var last = _colors.size() - 1;
            var canGoNext = _index > 0; // KEY_UP
            var canGoPrev = _index < last; // KEY_DOWN

            if (canGoNext) {
                UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 180, 15, 6, bg, fg);
                UiUtils.drawLabel(dc, cx, cy, 180, rOuter, "+", fg, bg, Graphics.FONT_TINY, 20);
            }

            if (canGoPrev) {
                UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 210, 15, 6, bg, fg);
                UiUtils.drawLabel(dc, cx, cy, 210, rOuter, "-", fg, bg, Graphics.FONT_LARGE, 20);
            }
            UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 30, 15, 6, bg, fg);
        }
    }

    function onKey(key as WatchUi.Key) as Boolean {
        if (key == WatchUi.KEY_ENTER) {
            openSettings();
            return true;
        }
        if (key == WatchUi.KEY_UP) {
            nextColor();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            prevColor();
            return true;
        }

        return false;
    }

    // TODO: consider if it is good idea
    // function onTap(clickEvent) {
    //     System.println("on tap");
    //     nextColor();
    //     return true;
    // }

    function onHide() {
        if (_autoOff != null) {
            _autoOff.cancel();
        }
    }

    function onBack() as Boolean {
        return false;
    }

    function setActiveColor(colorIndex as Number) as Void {
        _index = colorIndex;
        _color = _colors[_index];
        WatchUi.requestUpdate();
        if (_autoOff != null) {
            _autoOff.rearm(_color); // on black color stop timer
        }
    }

    function nextColor() {
        // KEY_UP
        if (_index > 0) {
            _index -= 1;
            setActiveColor(_index);
        }
    }

    function prevColor() {
        // KEY_DOWN
        var last = _colors.size() - 1;
        if (_index < last) {
            _index += 1;
            setActiveColor(_index);
        }
    }

    /**
     * Opens the app’s internal settings on the watch (implement a SettingsView).
     */
    function openSettings() {
        SettingsMenu.open();
    }

    function prepareColors() as Array<Number> {
        var settingColors = SettingsService.getSelectedColors();
        var whiteShades = [0xbfbfbf, 0x808080];

        var result = [] as Array<Number>;

        for (var i = 0; i < settingColors.size(); i += 1) {
            var col = settingColors[i];
            result.add(col);

            if (col == Graphics.COLOR_WHITE) {
                // insert white shades after white color
                for (var j = 0; j < whiteShades.size(); j += 1) {
                    result.add(whiteShades[j]);
                }
            }
        }

        result.add(Graphics.COLOR_BLACK);

        return result;
    }

    function contrastColor(bg as Number) as Number {
        if (bg == 0xffffff) {
            return Graphics.COLOR_BLACK;
        } else if (bg == 0xcccccc) {
            return Graphics.COLOR_BLACK;
        } else if (bg == 0x999999) {
            return Graphics.COLOR_WHITE;
        } else if (bg == Graphics.COLOR_RED) {
            return Graphics.COLOR_WHITE;
        } else if (bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_WHITE;
    }
}
