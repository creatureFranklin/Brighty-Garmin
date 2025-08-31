using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.Math;

class FlashlightView extends WatchUi.View {
    var _colors as Array<Integer> = [
        0xffffff, // white
        0xcccccc, // light gray
        0x999999, // dark gray
        Graphics.COLOR_RED, // red
        Graphics.COLOR_BLACK, // black
    ];
    var _color as Integer;
    var _index as Integer = 0;

    function initialize() {
        View.initialize();
        _color = _colors[_index];
    }

    function onShow() {}

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
        drawSoftKeyStrip(dc, cx, cy, rOuter, 30, 15, 6, bg, fg);

        drawSoftKeyStrip(dc, cx, cy, rOuter, 180, 15, 6, bg, fg);
        drawLabel(dc, cx, cy, 180, rOuter, "+", fg, bg, Graphics.FONT_TINY, 20);
        drawSoftKeyStrip(dc, cx, cy, rOuter, 210, 15, 6, bg, fg);
        drawLabel(dc, cx, cy, 210, rOuter, "-", fg, bg, Graphics.FONT_LARGE, 20);
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

    function onHide() {}

    function nextColor() {
        _index = (_index + 1) % _colors.size();
        WatchUi.requestUpdate();
    }

    function prevColor() {
        _index = (_index - 1 + _colors.size()) % _colors.size();
        WatchUi.requestUpdate();
    }

    /**
     * Opens the app’s internal settings on the watch (implement a SettingsView).
     */
    function openSettings() {
        WatchUi.pushView(new SettingsView(), null, WatchUi.SLIDE_IMMEDIATE);
    }

    /**
     * Draws a short arc along the edge plus an optional icon.
     * angleDeg = the central angle in degrees (0° is to the right, increases anticlockwise)
     */
    function drawSoftKeyStrip(
        dc as Graphics.Dc, // drawing context
        cx, // center X
        cy, // center Y
        r as Lang.Numeric, // radius of the ring
        angleDeg as Lang.Numeric, // central angle of the segment
        arcLenDeg as Lang.Numeric, // length of the segment (in degrees)
        ringWidth as Lang.Numeric, // thickness of the ring
        bgColor as Lang.Numeric, // background color (fills the ring)
        segColor as Lang.Numeric // color of the short arc (e.g. Graphics.COLOR_BLACK)
    ) as Void {
        var startDeg = angleDeg - arcLenDeg / 2.0;
        var endDeg = angleDeg + arcLenDeg / 2.0;

        dc.setPenWidth(ringWidth);
        dc.setColor(segColor, bgColor);
        dc.drawArc(cx, cy, r, Graphics.ARC_COUNTER_CLOCKWISE, startDeg, endDeg);
    }

    function drawLabel(
        dc as Graphics.Dc,
        cx as Numeric,
        cy as Numeric,
        angleDeg as Numeric,
        r as Numeric,
        text as String,
        fg as Graphics.ColorType,
        bg as Graphics.ColorType,
        font as Graphics.FontDefinition,
        offset as Numeric
    ) {
        var rad = (angleDeg * Math.PI) / 180.0;
        var rIcon = r - offset;
        var x = cx + rIcon * Math.cos(rad);
        var y = cy - rIcon * Math.sin(rad);

        dc.setColor(fg, bg);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function min(a, b) {
        return a < b ? a : b;
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
