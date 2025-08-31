using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
import Toybox.Lang;

class SettingsView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {}

    function onUpdate(dc as Graphics.Dc) {
        var w = dc.getWidth(),
            h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(w / 2, h / 2, Graphics.FONT_MEDIUM, "Nastavení", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // dc.drawText(w / 2, h - 24, Graphics.FONT_TINY, "BACK = zpět", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onKey(key as WatchUi.Key) as Boolean {
        if (key == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        return false;
    }
}
