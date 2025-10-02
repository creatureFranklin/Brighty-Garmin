using Toybox.System;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;

// ---- Fallback QR view ----
class BmcQrView extends WatchUi.View {
    function onUpdate(dc as Graphics.Dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(w / 2, 16, Graphics.FONT_XTINY, Utils._t(Rez.Strings.supportMe), Graphics.TEXT_JUSTIFY_CENTER);

        var bmp = WatchUi.loadResource(Rez.Drawables.img_bmc_qr);

        var bw = bmp.getWidth();
        var bh = bmp.getHeight();
        dc.drawBitmap((w - bw) / 2, (h - bh) / 2, bmp);
    }
}

class DonateHelper {
    const BMC_URL = "https://buymeacoffee.com/reminektomq";

    hidden var _opening = false;

    function openBuyMeACoffee() {
        if (_opening) {
            return;
        }
        _opening = true;

        try {
            // Open „Check your phone“ and run mobile browser
            Communications.openWebPage(BMC_URL, {}, {});
        } catch (e) {
            _opening = false;
        } finally {
            WatchUi.pushView(new BmcQrView(), new WatchUi.InputDelegate(), WatchUi.SLIDE_LEFT);
            _opening = false;
        }
    }
}
