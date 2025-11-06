using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
import Toybox.Lang;

class FlashlightView extends WatchUi.View {
    var _colors as Array<Number> = prepareColors();
    var _color as Number;
    var _index as Number = 0;

    var _deviceHeight as Number = 0;
    var _deviceWidth as Number = 0;
    var _autoOff as AutoOffController?;

    function initialize() {
        View.initialize();
        _color = _colors[_index];

        Utils.turnOnBacklight(1.0, 2);

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
        _deviceHeight = dc.getHeight();
        _deviceWidth = dc.getWidth();

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
        // On round displays
        var last = _colors.size() - 1;
        var canGoNext = _index > 0; // KEY_UP
        var canGoPrev = _index < last; // KEY_DOWN

        if (showHintsFlag == true && UiUtils.isRound(dc) == true) {
            if (canGoNext) {
                if (DeviceButtons.hasUpButton()) {
                    UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 180, 15, 6, bg, fg);
                    UiUtils.drawLabelPolar(dc, cx, cy, 180, rOuter, "+", fg, Graphics.FONT_TINY, 20);
                } else {
                    UiUtils.drawLabelRect(dc, "+", fg, Graphics.FONT_LARGE, 0.25, 0);
                }
            }

            if (canGoPrev) {
                if (DeviceButtons.hasDownButton()) {
                    UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 210, 15, 6, bg, fg);
                    UiUtils.drawLabelPolar(dc, cx, cy, 210, rOuter, "-", fg, Graphics.FONT_LARGE, 20);
                } else {
                    UiUtils.drawLabelRect(dc, "-", fg, Graphics.FONT_LARGE, 0.75, 0);
                }
            }
            UiUtils.drawSoftKeyStrip(dc, cx, cy, rOuter, 30, 15, 6, bg, fg);
        }
        // On rect displays
        if (showHintsFlag == true && UiUtils.isRound(dc) == false) {
            if (canGoNext) {
                UiUtils.drawLabelRect(dc, "+", fg, Graphics.FONT_LARGE, 0.25, 0);
            }

            if (canGoPrev) {
                UiUtils.drawLabelRect(dc, "-", fg, Graphics.FONT_LARGE, 0.75, 0);
            }
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

        if (key == WatchUi.KEY_ESC) {
            Utils.turnOnBacklight(1.0, 0);
            System.exit();
        }

        return false;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) {
        var h = _deviceHeight > 0 ? _deviceHeight : 100;
        var y = clickEvent.getCoordinates()[1];

        if (y < h / 2) {
            nextColor();
        } else {
            prevColor();
        }

        return true;
    }

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
        return SettingsService.getSelectedColors();
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
